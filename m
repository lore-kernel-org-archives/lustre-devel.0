From: Eric Barton <eeb@sun.com>
Date: Wed, 29 Jul 2009 16:37:29 +0100
Subject: [Lustre-devel] SMP Scalability, MDS, reducing cpu pingpong
In-Reply-To: <7580C3C1-7634-47C8-827B-C93157C1301A@Sun.COM>
References: <7580C3C1-7634-47C8-827B-C93157C1301A@Sun.COM>
Message-ID: <002001ca1062$7b526fc0$71f74f40$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Oleg,

I'm replying via lustre-devel since this is of general interest.
Comments inline...

> Hello!
> 
> I looked into the current lnet code for smp scalability and had some
> discussion with Liang and I think there are some topics we need to
> cover.
> 
> with ofed 1.3 all interrupts arrive to single cpu, that cpu looks
> into some data (currently - sending NID), and puts that message into
> a processing queue for some CPU that happens to match he hash.  This
> is already quite not ideal (even with all the boost we are
> supposedly getting) - this means each queue lock is constantly
> bouncing between interrupt-receiving cpu and handling CPU.  with
> ofed 1.4 interrupts would be distributed across many cpus, which in
> my opinion has a potential to make above case even worse, now the
> locks would be bouncing across multiple cpus (not sure if it makes
> for more overhead or the same).
> 
> Now consider that we decide to implement somewhat better cpu
> scheduling than that for MDS (and possibly OSTs too, though that is
> debatable and needs some measurements), we definitely want hashing
> based on object IDs.

The advantage of hashing on client NID is that we can hash
consistently at all stack levels without layering violations.  If
clients aren't contending for the same objects, do we get the same
benefits with hashing on NID as we get hashing on object ID?

> The idea was to offload this task to lustre-provided event callback,
> but that seems to mean we add another cpu rescheduling point that
> way (in addition to one described above). Liang told me that we
> cannot avoid the first switch since interrupt handler cannot process
> the actual message received as this involves accessing and updating
> per-NID information (credits and stuff) and if we do it on multiple
> CPUs (in case of ofed 1.4 and other lnds that can have multiple cpus
> serving interrupts), that means a lot of lock contention potentially
> when single client's requests arrive on multiple cpus.

My own belief is that most if not all performance-critical use cases
involve many more clients than there are server CPUs - i.e. we don't
lose by trying to keep a single client's RPCs local to 1 CPU.  Note
that this means looking through the LND protocol level into the LNET
header as early as possible.

> I wonder if this could be relieved somehow? Ability to call lustre
> request callback from interrupt so that we do only one cpu
> rescheduling would be great.

This is not an option.  Ensuring that the only code allowed to block
interrupts is the LND has avoided _many_ nasty real-time issues which
will return immediately if we relax this rule.

> (of course we can try to encode this information somewhere in actual
> message header like xid now where lnet interrupt handler can access
> it and use in its hash algorithm, but that way we give away a lot of
> flexibility, so this is not the best solution, I would think).

It would be better to add an additional "hints" field to LNET messages
which could be used for this purpose.

> Another scenario that I have not seen discussed but that is
> potentially pretty important for MDS is ability to route expected
> messages (the ones like rep-ack reply) to a specific cpu regardless
> of what NID did it come from. E.g. if we did rescheduling of MDS
> request to some CPU and this is a difficult reply, we definitely
> want the confirmation to be processed on that same cpu that sent the
> reply originally, since it references all the locks supposedly
> served by that CPU, etc. This is better to happen within LNET. I
> guess similar thing might be beneficial to clients too where a reply
> is received on the same CPU that sent original request in hopes that
> the cache is still valid and the processing would be so much faster
> as a result.

You could use a "hints" field in the LNET header for this.

> I wonder if there are any ways to influence what CPU would receive
> interrupt initially that we can exploit to avoid the cpu switches
> completely if possible? Should we investigate polling after certain
> threshold of incoming messages is met?  

Layers below the LND should already be doing interrupt coalescing.

Have we got any measurements to show the impact of handling the
message on a different CPU from the initial interrupt?  If we can keep
everything on 1 CPU once we're in thread context, is 1 switch like
this such a big deal

> Perhaps for RDMA-noncapable LNDs we can save on switches by
> redirecting transfer straight into the buffer registered by target
> processing CPU and signal that thread in a cheaper way than double
> spinlock taking + wakeup, or does that becomes irrelevant due to all
> the overhead of non-RDMA transfer?

RDMA shouldn't be involved in the message handling for which we need
to improve SMP scaling.  Since RDMA always involves an additional
network round-trip to set up the transfer and may also require mapping
buffers into network VM, anything "small" (<= 4K including LND and
LNET protocol overhead) is transferred by message passing -
i.e. received first into dedicated network buffers and then copied
out.  This copying is done in thread context in the LND as is the
event callback.

So if we do as much as possible in request_in_callback() (e.g. initial
unpacking - AT processing etc) we'll be running on the same CPU LNET
used to handle the message.

I've attached Liang's measurements where he changed
request_in_callback() to enqueue incoming requests on per-CPU queues.
The measurements were taken with a 16 core server and 40 clients using
DDR IB.  The results show similar performance gains to those seen with
LNET self-test when requests are always queued to the same CPU.  When
requests are queued to a different CPU, total throughput can fall by
as much ~60%.  However keep in mind that even with this unnecessary
switch, the total throughput is still getting on for 10x better than
current releases.

Lustre      LNET           LND

GETATTR     PUT(request)   client->server: IMMEDIATE
            PUT(reply)     server->client: IMMEDIATE

BRW WRITE   PUT(request)   client->server: IMMEDIATE
            GET(bulk)      server->client: GET_REQ
                           client->server: RDMA + GET_DONE
            PUT(reply)     server->client: IMMEDIATE

BRW READ    PUT(request)   client->server: IMMEDIATE
            PUT(bulk)      server->client: PUT_REQ
                           client->server: PUT_ACK
                           server->client: RDMA + PUT_DONE
            PUT(reply)     server->client: IMMEDIATE

Peak getattr performance of ~630,000 RPCs/sec translates into the same
number of LND messages per second in both directions.

Peak write performance of ~990MB/s with 4K requests translates to
253,440 write RPCs/sec and 506,880 LND messages per second in both
directions.  

Similarly ~640MB/s reads translates to 163840 read RPCs/sec, 327,680
incoming LND messages per second and 491,520 outgoing LND messages per
second.

> Also on lustre front - something I plan to tackle, though not yet
> completely sure how: Lustre has a concept of reserving one thread for
> difficult replies handling + one thread for high priority messages
> handling (if enabled). In SMP scalability branch that becomes 2x
> num_cpus reserved threads potentially per service since naturally
> rep_ack reply or high prio message might arrive on any cpu separately
> now (and message queues are per cpu) - seems like huge overkill to
> me. I see that there is a handle reply separate threads in HEAD now,
> so perhaps this could be greatly simplified by proper usage of those.
> the high prio seems to be harder to improve, though.

These threads are required in case all normal service threads are
blocking.  I don't suppose this can be a performance critical case, so
voilating CPU affinity for the sake of deadlock avoidance seems OK.
However is 1 extra thread per CPU such a big deal?  We'll have
10s-100s of them in any case.

> Do anybody else have any extra thoughts for lustre side  
> improvements we can get off this?

I think we need measurements to prove/disprove whether object affinity
trumps client affinity.

> 
> Bye,
>      Oleg

-- 

        Cheers,
                   Eric
-------------- next part --------------
A non-text attachment was scrubbed...
Name: echo_perf.pdf
Type: application/pdf
Size: 108069 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090729/a3f70e67/attachment.pdf>
