From: NeilBrown <neilb@suse.com>
Date: Thu, 02 Aug 2018 14:18:57 +1000
Subject: [lustre-devel] [PATCH 7/7] lustre: change TASK_NOLOAD to
 TASK_IDLE.
In-Reply-To: <alpine.LFD.2.21.1808020448170.5677@casper.infradead.org>
References: <153292249340.26496.13985174182824912332.stgit@noble>
 <153292257303.26496.13996008210683917463.stgit@noble>
 <alpine.LFD.2.21.1808020448170.5677@casper.infradead.org>
Message-ID: <87lg9ppfim.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Aug 02 2018, James Simmons wrote:

>> TASK_NOLOAD is not a task state to be use by
>> itself, it should only be used together with
>> TASK_UNINTERRUPTIBLE, which easily done
>> by using TASK_IDLE.
>> 
>> So convert to TASK_IDLE.
>
> Sad only the latest kernel support this :-(

So?  The patch to add support is trivial.

commit 80ed87c8a9ca0cad7ca66cf3bbdfb17559a66dcf
Author: Peter Zijlstra <peterz@infradead.org>
Date:   Fri May 8 14:23:45 2015 +0200

    sched/wait: Introduce TASK_NOLOAD and TASK_IDLE

....
 include/linux/sched.h        | 10 +++++++---
 include/trace/events/sched.h |  3 ++-
 2 files changed, 9 insertions(+), 4 deletions(-)

You would then need to add some macors like wait_event_idle(), but they
could go in the lustre code.

If you need it in any vendor kernel I'd be quite surprised if they
wouldn't accept it, at least in a service-pack.
I just checked SLES and the only release that isn't in long-term-support
(no new features) that doesn't already have this patch (linux 4.2 and
later) is SLE11-SP4.
Do you still provide new features for older kernels, or just bug-fix
updates?

NeilBrown

>
> Reviewed-by: James Simmons <jsimmons@infradead.org>
>  
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  drivers/staging/lustre/lnet/lnet/lib-eq.c |    4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
>> index 8347cc44e47d..f085388895ea 100644
>> --- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
>> +++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
>> @@ -349,7 +349,7 @@ __must_hold(&the_lnet.ln_eq_wait_lock)
>>   * \param timeout Time in jiffies to wait for an event to occur on
>>   * one of the EQs. The constant MAX_SCHEDULE_TIMEOUT can be used to indicate an
>>   * infinite timeout.
>> - * \param interruptible, if true, use TASK_INTERRUPTIBLE, else TASK_NOLOAD
>> + * \param interruptible, if true, use TASK_INTERRUPTIBLE, else TASK_IDLE
>>   * \param event,which On successful return (1 or -EOVERFLOW), \a event will
>>   * hold the next event in the EQs, and \a which will contain the index of the
>>   * EQ from which the event was taken.
>> @@ -406,7 +406,7 @@ LNetEQPoll(struct lnet_handle_eq *eventqs, int neq, signed long timeout,
>>  		 */
>>  		wait = lnet_eq_wait_locked(&timeout,
>>  					   interruptible ? TASK_INTERRUPTIBLE
>> -					   : TASK_NOLOAD);
>> +					   : TASK_IDLE);
>>  		if (wait < 0) /* no new event */
>>  			break;
>>  	}
>> 
>> 
>> 
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180802/d6a9462e/attachment.sig>
