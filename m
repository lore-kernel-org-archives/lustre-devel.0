From: Andreas Dilger <adilger@sun.com>
Date: Wed, 29 Jul 2009 19:40:12 -0600
Subject: [Lustre-devel] SMP Scalability, MDS, reducing cpu pingpong
In-Reply-To: <002001ca1062$7b526fc0$71f74f40$@com>
References: <7580C3C1-7634-47C8-827B-C93157C1301A@Sun.COM>
	<002001ca1062$7b526fc0$71f74f40$@com>
Message-ID: <20090730014012.GQ4231@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 29, 2009  16:37 +0100, Eric Barton wrote:
> > Now consider that we decide to implement somewhat better cpu
> > scheduling than that for MDS (and possibly OSTs too, though that is
> > debatable and needs some measurements), we definitely want hashing
> > based on object IDs.
> 
> The advantage of hashing on client NID is that we can hash
> consistently at all stack levels without layering violations.  If
> clients aren't contending for the same objects, do we get the same
> benefits with hashing on NID as we get hashing on object ID?

The problem with hashing on the NID, and only doing micro-benchmarks
that parallelize trivially is that we are missing very important factors
in the overall performance.  I don't at all object to optimizing the
LNET code to be very scalable in this way, but this isn't the end goal.

I can imagine that keeping the initial message handling (LND processing,
credits, etc) on a per-NID basis to be CPU local is fine.  However,
the amount of state and locks involved at the Lustre level will far
exceed the connection state at the LNET level, and we need to optimize
the place that has the most overhead.  IMHO, that means having request
processing affinity at a FID level (parent directory, target inode,
file offset, etc).

As can be seen with the echo client graphs, sure we "lose" a lot of
"no-op getattr" performance when we go to 100% ping-pong requests
(i.e. no NID affinity at all), but in absolute terms we still get 250k
RPCs/sec even with no NID affinity.  In contrast, the file read and
write with 1MB RPCs will saturate the network with 1000-2000 RPCs/sec,
so whether we can handle 250k or 650k RPCs/sec empty requests is totally
meaningless.

I suspect the same would hold true with the getattr tests if they had
to actually do an inode lookup and read actual data.  If the getattr
requests are scheduled to the CPU where the inode is cached then the
real life performance will be maximized.  It won't be 650k RPCs/sec,
but I don't think that is achievable in most real workloads anyway.

> > The idea was to offload this task to lustre-provided event callback,
> > but that seems to mean we add another cpu rescheduling point that
> > way (in addition to one described above). Liang told me that we
> > cannot avoid the first switch since interrupt handler cannot process
> > the actual message received as this involves accessing and updating
> > per-NID information (credits and stuff) and if we do it on multiple
> > CPUs (in case of ofed 1.4 and other lnds that can have multiple cpus
> > serving interrupts), that means a lot of lock contention potentially
> > when single client's requests arrive on multiple cpus.
> 
> My own belief is that most if not all performance-critical use cases
> involve many more clients than there are server CPUs - i.e. we don't
> lose by trying to keep a single client's RPCs local to 1 CPU.  Note
> that this means looking through the LND protocol level into the LNET
> header as early as possible.

Let us separate the initial handling of the request in the LNET/LND
level from the hand-off of the request structure itself to the Lustre
service thread.  If we can process the LNET-level locking/accounting
in a NID/CPU-affine manner, and all that is cross-CPU is the request
buffer maybe that is the lowest-cost "request context switch" that
is possible.

AFAIK, it is the OST service thread that is doing the initialization
of the bulk buffers, and not the LNET code, so we don't have a huge
amount of data that needs to be shipped between cores.  If we can
also avoid lock ping-pong on the request queues as requests are
being assigned at the Lustre level that is ideal.


I think this would be possible by e.g. having multiple per-CPU request
"queuelets" (batches of requests that are handled as a unit, instead of
having per-request processing).  See the ASCII art below for reference.

The IRQ handler puts incoming requests on a CPU-affine list of some sort.
Each request is put into into a CPU-affine list by NID hash to minimize
peer processing overhead (credits, etc).  We get a list of requests
that need to be scheduled to a CPU based on the content of the message,
and that scheduling has to be done outside of the IRQ context.


The LNET code now does the receive processing (still on the same CPU)
to call the req_in handler (CPU request scheduler, possibly the very same
as the NRS) to determine which core will do the full Lustre processing of
the request.  The CPU request scheduler will add these requests to one of
$num_active_cpus() _local_ queuelets (q$cpunr.$batchnr) until it is full,
or some deadline (possibly load related) is passed.  At that point the
finished queuelet is moved to the target CPU's local staging area (S$cpunr).

IRQ handler          LNET/req_sched           OST thread
-----------          --------------           ----------
[request]
    |
    v
CPU-affine list(s)
                     CPU-affine list(s)
                     |    |    |    |
                     v    v    v    v   
                     q0.4 q1.3 q2.2 q3.4
                                               S0->q0.1->Q0 (CPU 0 threads)
                                               S0->q0.2->Q0 (CPU 0 threads)
                     q0.3 (finished) -> S0
                                               S0->q0.3->Q0 (CPU 0 threads)
                                               S1->q1.0->Q0 (CPU 1 threads)
                     q1.1 (finished) -> S1
                                               S1->q1.1->Q0 (CPU 1 threads)
                     q1.2 (finished) -> S1
                                               S1->q1.2->Q0 (CPU 1 threads)
                                               S2->q1.1->Q0 (CPU 2 threads)
                     q2.1 (finished) -> S2
                                               S2->q2.1->Q0 (CPU 2 threads)
                                               S3->q3.1->Q0 (CPU 3 threads)
                     q3.2 (finished) -> S3
                                               S3->q3.2->Q0 (CPU 3 threads)
                     q3.3 (finished) -> S3
                                               S3->q3.3->Q0 (CPU 3 threads)

As the service threads process requests they periodically check for new
queuelets in their CPU-local staging area and move them to their local
request queue (Q$cpunr).  The requests are processed one-at-a-time by
the CPU-local service threads as they are today from their request queue Q.


What is important is that the cross-CPU lock contention is limited
to the handoff of a large number of requests at a time (i.e. the
whole queuelet) instead of on a per-request basis, so the lock
contention on the Lustre request queue is orders of magnitude lower.
Also, since the per-CPU service threads can remove whole queuelets
from the staging area at one time they will also not be holding this
lock for any length of time, ensuring the LNET threads are not blocked.


> > (of course we can try to encode this information somewhere in actual
> > message header like xid now where lnet interrupt handler can access
> > it and use in its hash algorithm, but that way we give away a lot of
> > flexibility, so this is not the best solution, I would think).
> 
> It would be better to add an additional "hints" field to LNET messages
> which could be used for this purpose.

I'm not against this either.  I think it is a reasonable approach,
but the hints need to be independent of whatever mechanism the
server is using for scheduling.  That means a hint is not a CPU
number or anything, but rather e.g. a parent FID number (MDS) or
an (object number XOR file offset in GB).  We might want to have
a "major" hint (e.g. parent FID, object number) and a "minor"
hint (e.g. child hash, file offset in GB) to let the server do
load balancing as appropriate.

Consider the OSS case where a large file is being read by many
clients.  With NID affinity, there will essentially be completely
random cross-CPU memory accesses.  With object number + offset-in-GB
affinity the file extent locking and memory accesses will be CPU
affine, so minimal cross-CPU memory access.

> > Another scenario that I have not seen discussed but that is
> > potentially pretty important for MDS is ability to route expected
> > messages (the ones like rep-ack reply) to a specific cpu regardless
> > of what NID did it come from. E.g. if we did rescheduling of MDS
> > request to some CPU and this is a difficult reply, we definitely
> > want the confirmation to be processed on that same cpu that sent the
> > reply originally, since it references all the locks supposedly
> > served by that CPU, etc. This is better to happen within LNET. I
> > guess similar thing might be beneficial to clients too where a reply
> > is received on the same CPU that sent original request in hopes that
> > the cache is still valid and the processing would be so much faster
> > as a result.
> 
> You could use a "hints" field in the LNET header for this.

These should really be "cookies" provided by the server, rather than
hints generated by the client, but the mechanism could be the same.

> These threads are required in case all normal service threads are
> blocking.  I don't suppose this can be a performance critical case, so
> voilating CPU affinity for the sake of deadlock avoidance seems OK.
> However is 1 extra thread per CPU such a big deal?  We'll have
> 10s-100s of them in any case.

I agree.  Until this is shown to be a major issue I don't think it
is worth the investment of any time to fix.

> > Do anybody else have any extra thoughts for lustre side  
> > improvements we can get off this?
> 
> I think we need measurements to prove/disprove whether object affinity
> trumps client affinity.

Yes, that is the critical question.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
