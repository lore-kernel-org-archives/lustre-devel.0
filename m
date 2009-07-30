From: Liang Zhen <Zhen.Liang@Sun.COM>
Date: Thu, 30 Jul 2009 17:25:52 +0800
Subject: [Lustre-devel] SMP Scalability, MDS, reducing cpu pingpong
In-Reply-To: <20090730014012.GQ4231@webber.adilger.int>
References: <7580C3C1-7634-47C8-827B-C93157C1301A@Sun.COM>
	<002001ca1062$7b526fc0$71f74f40$@com>
	<20090730014012.GQ4231@webber.adilger.int>
Message-ID: <4A716720.6030504@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reply inline.....

Andreas Dilger wrote:
> Let us separate the initial handling of the request in the LNET/LND
> level from the hand-off of the request structure itself to the Lustre
> service thread.  If we can process the LNET-level locking/accounting
> in a NID/CPU-affine manner, and all that is cross-CPU is the request
> buffer maybe that is the lowest-cost "request context switch" that
> is possible.
>
> AFAIK, it is the OST service thread that is doing the initialization
> of the bulk buffers, and not the LNET code, so we don't have a huge
> amount of data that needs to be shipped between cores.  If we can
> also avoid lock ping-pong on the request queues as requests are
> being assigned at the Lustre level that is ideal.
>
>
> I think this would be possible by e.g. having multiple per-CPU request
> "queuelets" (batches of requests that are handled as a unit, instead of
> having per-request processing).  See the ASCII art below for reference.
>
> The IRQ handler puts incoming requests on a CPU-affine list of some sort.
> Each request is put into into a CPU-affine list by NID hash to minimize
> peer processing overhead (credits, etc).  We get a list of requests
> that need to be scheduled to a CPU based on the content of the message,
> and that scheduling has to be done outside of the IRQ context.
>
>
> The LNET code now does the receive processing (still on the same CPU)
> to call the req_in handler (CPU request scheduler, possibly the very same
> as the NRS) to determine which core will do the full Lustre processing of
> the request.  The CPU request scheduler will add these requests to one of
> $num_active_cpus() _local_ queuelets (q$cpunr.$batchnr) until it is full,
> or some deadline (possibly load related) is passed.  At that point the
> finished queuelet is moved to the target CPU's local staging area (S$cpunr).
>
> IRQ handler          LNET/req_sched           OST thread
> -----------          --------------           ----------
> [request]
>     |
>     v
> CPU-affine list(s)
>                      CPU-affine list(s)
>                      |    |    |    |
>                      v    v    v    v   
>                      q0.4 q1.3 q2.2 q3.4
>                                                S0->q0.1->Q0 (CPU 0 threads)
>                                                S0->q0.2->Q0 (CPU 0 threads)
>                      q0.3 (finished) -> S0
>                                                S0->q0.3->Q0 (CPU 0 threads)
>                                                S1->q1.0->Q0 (CPU 1 threads)
>                      q1.1 (finished) -> S1
>                                                S1->q1.1->Q0 (CPU 1 threads)
>                      q1.2 (finished) -> S1
>                                                S1->q1.2->Q0 (CPU 1 threads)
>                                                S2->q1.1->Q0 (CPU 2 threads)
>                      q2.1 (finished) -> S2
>                                                S2->q2.1->Q0 (CPU 2 threads)
>                                                S3->q3.1->Q0 (CPU 3 threads)
>                      q3.2 (finished) -> S3
>                                                S3->q3.2->Q0 (CPU 3 threads)
>                      q3.3 (finished) -> S3
>                                                S3->q3.3->Q0 (CPU 3 threads)
>
> As the service threads process requests they periodically check for new
> queuelets in their CPU-local staging area and move them to their local
> request queue (Q$cpunr).  The requests are processed one-at-a-time by
> the CPU-local service threads as they are today from their request queue Q.
>   

So the queuelets could be: a) popped to target CPU if local CPU got 
enough messages for target; b) poll  by target CPU if target CPU is idle.
for a) it's good and can reduce contention, but for b), If service 
thread (of each CPU) make periodically poll from all other CPUs, there 
could be a unnecessary delay (interval of poll) if those queuelets are 
always not full at all, unless local-CPU "peek" the message queue on 
target CPU in callback, and post message to there directly (instead of 
queuelet of local CPU) when the queue is empty. However, there could be 
another problem, the "peek" is not a light operation even don't need any 
lock, target CPU is likely changing it's own request queue (exclusive 
access), so the "peek" is already a cache syncup.


>
> What is important is that the cross-CPU lock contention is limited
> to the handoff of a large number of requests at a time (i.e. the
> whole queuelet) instead of on a per-request basis, so the lock
> contention on the Lustre request queue is orders of magnitude lower.
> Also, since the per-CPU service threads can remove whole queuelets
> from the staging area at one time they will also not be holding this
> lock for any length of time, ensuring the LNET threads are not blocked.
>
>
>   
>>> (of course we can try to encode this information somewhere in actual
>>> message header like xid now where lnet interrupt handler can access
>>> it and use in its hash algorithm, but that way we give away a lot of
>>> flexibility, so this is not the best solution, I would think).
>>>       
>> It would be better to add an additional "hints" field to LNET messages
>> which could be used for this purpose.
>>     

I'm quite confusing at here, I think Oleg was talking about incoming 
request, but LNet message is totally invisible in interrupt handlers, as 
LNet message is created by lnet_parse() which is called by LND scheduler 
later(after woken up by interrupt handler).

>
> I'm not against this either.  I think it is a reasonable approach,
> but the hints need to be independent of whatever mechanism the
> server is using for scheduling.  That means a hint is not a CPU
> number or anything, but rather e.g. a parent FID number (MDS) or
> an (object number XOR file offset in GB).  We might want to have
> a "major" hint (e.g. parent FID, object number) and a "minor"
> hint (e.g. child hash, file offset in GB) to let the server do
> load balancing as appropriate.
>
> Consider the OSS case where a large file is being read by many
> clients.  With NID affinity, there will essentially be completely
> random cross-CPU memory accesses.  With object number + offset-in-GB
> affinity the file extent locking and memory accesses will be CPU
> affine, so minimal cross-CPU memory access.
>
>   
>>> Another scenario that I have not seen discussed but that is
>>> potentially pretty important for MDS is ability to route expected
>>> messages (the ones like rep-ack reply) to a specific cpu regardless
>>> of what NID did it come from. E.g. if we did rescheduling of MDS
>>> request to some CPU and this is a difficult reply, we definitely
>>> want the confirmation to be processed on that same cpu that sent the
>>> reply originally, since it references all the locks supposedly
>>> served by that CPU, etc. This is better to happen within LNET. I
>>> guess similar thing might be beneficial to clients too where a reply
>>> is received on the same CPU that sent original request in hopes that
>>> the cache is still valid and the processing would be so much faster
>>> as a result.
>>>       
>> You could use a "hints" field in the LNET header for this.
>>     

That's about outgoing LNet message when sending reply, however, sending 
a message still need go through "connection" & "peer" of LNet and LND as 
well, and finally go out from the connection of network stack, which are 
all bound on CPU hashed by NID (again).
So I think unless we create connections on all CPUs for each client, 
otherwise switch like that is unavoidable.
Actually, I think the fact is, LNet & LND are using NID affinity for 
connection & peer, Lustre is using object affinity, so we need switch 
CPU. If we want to go through the stack without switching of CPU, then 
we have to cancel NID affinity from LNet, that means we need a global 
peer table and a global lock to serialize, then we can schedule 
send/receive on any of CPU as we want, but "global" come back again...

>
>   
>>>  get off this?
>>>       
>> I think we need measurements to prove/disprove whether object affinity
>> trumps client affinity.
>>     
>
> Yes, that is the critical question.
>   

Totally agree....

Regards
Liang


> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
>
>   
