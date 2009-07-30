From: Andreas Dilger <adilger@sun.com>
Date: Thu, 30 Jul 2009 17:19:19 -0600
Subject: [Lustre-devel] SMP Scalability, MDS, reducing cpu pingpong
In-Reply-To: <4A716720.6030504@sun.com>
References: <7580C3C1-7634-47C8-827B-C93157C1301A@Sun.COM>
	<002001ca1062$7b526fc0$71f74f40$@com>
	<20090730014012.GQ4231@webber.adilger.int> <4A716720.6030504@sun.com>
Message-ID: <20090730231919.GJ4231@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 30, 2009  17:25 +0800, Liang Zhen wrote:
> Andreas Dilger wrote:
>> The IRQ handler puts incoming requests on a CPU-affine list of some sort.
>> Each request is put into into a CPU-affine list by NID hash to minimize
>> peer processing overhead (credits, etc).  We get a list of requests
>> that need to be scheduled to a CPU based on the content of the message,
>> and that scheduling has to be done outside of the IRQ context.
>>
>>
>> The LNET code now does the receive processing (still on the same CPU)
>> to call the req_in handler (CPU request scheduler, possibly the very same
>> as the NRS) to determine which core will do the full Lustre processing of
>> the request.  The CPU request scheduler will add these requests to one of
>> $num_active_cpus() _local_ queuelets (q$cpunr.$batchnr) until it is full,
>> or some deadline (possibly load related) is passed.  At that point the
>> finished queuelet is moved to the target CPU's local staging area (S$cpunr).

Note also that some kinds of replies (OBD_PING, for example) could be
completed entirely by ptlrpc_server_handle_req_in() without invoking
any context switching.

>> As the service threads process requests they periodically check for new
>> queuelets in their CPU-local staging area and move them to their local
>> request queue (Q$cpunr).  The requests are processed one-at-a-time by
>> the CPU-local service threads as they are today from their request queue Q.
>
> So the queuelets could be: a) popped to target CPU if local CPU got  
> enough messages for target; b) poll  by target CPU if target CPU is idle.
> for a) it's good and can reduce contention, but for b), If service  
> thread (of each CPU) make periodically poll from all other CPUs, there  
> could be a unnecessary delay (interval of poll) if those queuelets are  
> always not full at all, unless local-CPU "peek" the message queue on  
> target CPU in callback, and post message to there directly (instead of  
> queuelet of local CPU) when the queue is empty. However, there could be  
> another problem, the "peek" is not a light operation even don't need any  
> lock, target CPU is likely changing it's own request queue (exclusive  
> access), so the "peek" is already a cache syncup.

I don't think ALL service threads would necessarily poll for queuelets.
As you suggest, any polling would be lightweight.  We might not have
polling at all, however.  The LNET code could make a decision (based
on message arrival rate, whether there are other unhandled queuelets
in the staging list, maximum delay (deadline).  That said, if the
service threads are idle and there are requests to be processed then
some lock contention is acceptable, since the system cannot be too
busy at that time.  That wouldn't have to be polling, but rather a
wakeup of a single thread waiting on the request queue.

>>>> (of course we can try to encode this information somewhere in actual
>>>> message header like xid now where lnet interrupt handler can access
>>>> it and use in its hash algorithm, but that way we give away a lot of
>>>> flexibility, so this is not the best solution, I would think).
>>>>       
>>> It would be better to add an additional "hints" field to LNET messages
>>> which could be used for this purpose.
>
> I'm quite confusing at here, I think Oleg was talking about incoming  
> request, but LNet message is totally invisible in interrupt handlers, as  
> LNet message is created by lnet_parse() which is called by LND scheduler  
> later(after woken up by interrupt handler).

Would the hints have to be down at the LND-specific headers?  In any
case, something that can be accessed as easily as the NID.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
