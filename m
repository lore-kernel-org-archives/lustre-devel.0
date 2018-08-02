From: Patrick Farrell <paf@cray.com>
Date: Thu, 2 Aug 2018 12:48:35 +0000
Subject: [lustre-devel] [PATCH 7/7] lustre: change TASK_NOLOAD to
 TASK_IDLE.
In-Reply-To: <87lg9ppfim.fsf@notabene.neil.brown.name>
References: <153292249340.26496.13985174182824912332.stgit@noble>
 <153292257303.26496.13996008210683917463.stgit@noble>
 <alpine.LFD.2.21.1808020448170.5677@casper.infradead.org>,
 <87lg9ppfim.fsf@notabene.neil.brown.name>
Message-ID: <DM3PR1101MB1213C8CF4EF19F9BC64C59BECB2C0@DM3PR1101MB1213.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We generally provide full updates for older kernels, until we don?t.  There?s a gradually moving window of kernel support for new versions of Lustre, with a heavy eye on the major enterprise distro versions.

But when a feature depends on something new, we wrap it in config stuff and either disable it when not found, or we copy the required bits in to Lustre if they?re small or hard to do without.

So, kind of what you?re suggesting.  No problem at all.
________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
Sent: Wednesday, August 1, 2018 11:18:57 PM
To: James Simmons
Cc: Lustre Development List
Subject: Re: [lustre-devel] [PATCH 7/7] lustre: change TASK_NOLOAD to TASK_IDLE.

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
>>                */
>>               wait = lnet_eq_wait_locked(&timeout,
>>                                          interruptible ? TASK_INTERRUPTIBLE
>> -                                       : TASK_NOLOAD);
>> +                                       : TASK_IDLE);
>>               if (wait < 0) /* no new event */
>>                       break;
>>       }
>>
>>
>>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180802/6942a578/attachment-0001.html>
