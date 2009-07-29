From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Wed, 29 Jul 2009 12:01:30 -0400
Subject: [Lustre-devel] SMP Scalability, MDS, reducing cpu pingpong
In-Reply-To: <002001ca1062$7b526fc0$71f74f40$@com>
References: <7580C3C1-7634-47C8-827B-C93157C1301A@Sun.COM>
	<002001ca1062$7b526fc0$71f74f40$@com>
Message-ID: <31A2D6F1-C723-4EB5-8515-D155FE923C9A@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Jul 29, 2009, at 11:37 AM, Eric Barton wrote:

>> Now consider that we decide to implement somewhat better cpu
>> scheduling than that for MDS (and possibly OSTs too, though that is
>> debatable and needs some measurements), we definitely want hashing
>> based on object IDs.
> The advantage of hashing on client NID is that we can hash
> consistently at all stack levels without layering violations.  If
> clients aren't contending for the same objects, do we get the same
> benefits with hashing on NID as we get hashing on object ID?

Yes. If clients are not contending, we have same benefits, but
this never happens in the real world.
Creates in a same dir is a contention point on the dir and there is
no point in scheduling all clients on different cpus and let them
serialize, where we can free those cpus for some other set of clients
doing something else.
I guess this is less important for OSTs, since we do not recommend
letting multiple clients to access same objects anyway, but in the
case where this happens the benefit of serializing still might be there
(though for non-recommended usecase) due to reduced contention.

>> The idea was to offload this task to lustre-provided event callback,
>> but that seems to mean we add another cpu rescheduling point that
>> way (in addition to one described above). Liang told me that we
>> cannot avoid the first switch since interrupt handler cannot process
>> the actual message received as this involves accessing and updating
>> per-NID information (credits and stuff) and if we do it on multiple
>> CPUs (in case of ofed 1.4 and other lnds that can have multiple cpus
>> serving interrupts), that means a lot of lock contention potentially
>> when single client's requests arrive on multiple cpus.
> My own belief is that most if not all performance-critical use cases
> involve many more clients than there are server CPUs - i.e. we don't
> lose by trying to keep a single client's RPCs local to 1 CPU.  Note
> that this means looking through the LND protocol level into the LNET
> header as early as possible.

Absolutely. I am mostly in agreeing with you on this, except for the
above mentioned shared create (or any shared access, really) case.

>> (of course we can try to encode this information somewhere in actual
>> message header like xid now where lnet interrupt handler can access
>> it and use in its hash algorithm, but that way we give away a lot of
>> flexibility, so this is not the best solution, I would think).
> It would be better to add an additional "hints" field to LNET messages
> which could be used for this purpose.

Yup. We need an API for lustre to specify those hints when passing
a message to lnet.
The big part here is - should we then allow lnet to actually use this
hint? If yes - we lose a lot of flexibility (suppose we have a contended
object1 with a big queue of request piled for this object1.
Theoretically in the future we might have an ability to detect this
situation and when a request arrives for another object2 whose hash  
would
also redistribute it to the same cpu that is now busy with working  
through
all the request1 accesses, we can schedule it to different cpu (and  
remember
that all requests for object2 should now go to that different cpu)  
that is
completely idle a the moment.

>> Another scenario that I have not seen discussed but that is
>> potentially pretty important for MDS is ability to route expected
>> messages (the ones like rep-ack reply) to a specific cpu regardless
>> of what NID did it come from. E.g. if we did rescheduling of MDS
>> request to some CPU and this is a difficult reply, we definitely
>> want the confirmation to be processed on that same cpu that sent the
>> reply originally, since it references all the locks supposedly
>> served by that CPU, etc. This is better to happen within LNET. I
>> guess similar thing might be beneficial to clients too where a reply
>> is received on the same CPU that sent original request in hopes that
>> the cache is still valid and the processing would be so much faster
>> as a result.
> You could use a "hints" field in the LNET header for this.

Actually, the big difference with above-mentioned hints is that in this
case we need no API. Essentially lnet need to be smart enough to
recognize a reply as something that should go to the same cpu from
where original message was sent.

>> I wonder if there are any ways to influence what CPU would receive
>> interrupt initially that we can exploit to avoid the cpu switches
>> completely if possible? Should we investigate polling after certain
>> threshold of incoming messages is met?
> Layers below the LND should already be doing interrupt coalescing.
>
> Have we got any measurements to show the impact of handling the
> message on a different CPU from the initial interrupt?  If we can keep
> everything on 1 CPU once we're in thread context, is 1 switch like
> this such a big deal

I do not have any measurements, but I remember Liang did some tests
and each cpu switch is pretty expensive.
And this would be second cpu switch already.

>> Perhaps for RDMA-noncapable LNDs we can save on switches by
>> redirecting transfer straight into the buffer registered by target
>> processing CPU and signal that thread in a cheaper way than double
>> spinlock taking + wakeup, or does that becomes irrelevant due to all
>> the overhead of non-RDMA transfer?
> RDMA shouldn't be involved in the message handling for which we need
> to improve SMP scaling.  Since RDMA always involves an additional
> network round-trip to set up the transfer and may also require mapping
> buffers into network VM, anything "small" (<= 4K including LND and
> LNET protocol overhead) is transferred by message passing -
> i.e. received first into dedicated network buffers and then copied
> out.  This copying is done in thread context in the LND as is the
> event callback.

Well, I guess I used wrong word. By RDMA I meant a process in which
message arrives to registered buffer and then we are signalled that the
message is there. As opposed to a scheme where first we get a signal
that message is about to arrive and we still have a chance to decide
where to land it.

>> Also on lustre front - something I plan to tackle, though not yet
>> completely sure how: Lustre has a concept of reserving one thread for
>> difficult replies handling + one thread for high priority messages
>> handling (if enabled). In SMP scalability branch that becomes 2x
>> num_cpus reserved threads potentially per service since naturally
>> rep_ack reply or high prio message might arrive on any cpu separately
>> now (and message queues are per cpu) - seems like huge overkill to
>> me. I see that there is a handle reply separate threads in HEAD now,
>> so perhaps this could be greatly simplified by proper usage of those.
>> the high prio seems to be harder to improve, though.
> These threads are required in case all normal service threads are
> blocking.  I don't suppose this can be a performance critical case, so
> voilating CPU affinity for the sake of deadlock avoidance seems OK.
> However is 1 extra thread per CPU such a big deal?  We'll have
> 10s-100s of them in any case.

Well, I am not sure if this is a big deal or not yet. That's why I am
raising a question.

>> Do anybody else have any extra thoughts for lustre side
>> improvements we can get off this?
> I think we need measurements to prove/disprove whether object affinity
> trumps client affinity.

Absolutely. And we need to make sure we measure both kind of workloads,
shared and nonshared.

Bye,
     Oleg
