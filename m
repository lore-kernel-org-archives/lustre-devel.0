From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 19 Dec 2017 10:37:23 +0000
Subject: [lustre-devel] [PATCH 02/16] staging: lustre: replace simple
 cases of l_wait_event() with wait_event().
In-Reply-To: <D65D5D21.C5BF8%paf@cray.com>
References: <151358127190.5099.12792810096274074963.stgit@noble>
 <151358147981.5099.13114335078693829049.stgit@noble>
 <D65D5D21.C5BF8%paf@cray.com>
Message-ID: <9A64B5D7-C979-4400-9AFA-9C2AFC486129@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Farrell <paf@cray.com>
Cc: NeilBrown <neilb@suse.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

On Dec 18, 2017, at 11:03, Patrick Farrell <paf@cray.com> wrote:
> 
> The wait calls in ll_statahead_thread are done in a service thread, and
> should probably *not* contribute to load.
> 
> The one in osc_extent_wait is perhaps tough - It is called both from user
> threads & daemon threads depending on the situation.  The effect of adding
> that to load average could be significant for some activities, even when
> no user threads are busy.  Thoughts from other Lustre people would be
> welcome here.

The main reasons we started using l_wait_event() were:
- it is used by the request handling threads, and wait_event() caused the
  load average to always be == number of service threads, which was
  wrong if those threads were idle waiting for requests to arrive.
  That is mostly a server problem, but a couple of request handlers are
  on the client also (DLM lock cancellation threads, etc.) that shouldn't
  contribute to load.  It looks like there is a better solution for this
  today with TASK_IDLE.
- we want the userspace threads to be interruptible if the server is not
  functional, but the client should at least get a chance to complete the
  RPC if the server is just busy.  Since Lustre needs to work in systems
  with 10,000+ clients pounding a server, the server response time is not
  necessarily fast.  The l_wait_event() behavior is that it blocks signals
  until the RPC timeout, which will normally succeed, but after the timeout
  the signals are unblocked and the user thread can be interrupted if the
  user wants, but it will keep waiting for the RPC to finish if not.  This
  is half-way between NFS soft and hard mounts.  I don't think there is an
  equivalent wait_event_* for that behaviour.

Cheers, Andreas

> Similar issues for osc_object_invalidate.
> 
> (If no one else speaks up, my vote is no contribution to load for those
> OSC waits.)
> 
> Otherwise this one looks good...
> 
> On 12/18/17, 1:17 AM, "lustre-devel on behalf of NeilBrown"
> <lustre-devel-bounces at lists.lustre.org on behalf of neilb@suse.com> wrote:
> 
>> @@ -968,7 +964,6 @@ static int ll_statahead_thread(void *arg)
>> 	int		       first  = 0;
>> 	int		       rc     = 0;
>> 	struct md_op_data *op_data;
>> -	struct l_wait_info	lwi    = { 0 };
>> 	sai = ll_sai_get(dir);
>> 	sa_thread = &sai->sai_thread;
>> @@ -1069,12 +1064,11 @@ static int ll_statahead_thread(void *arg)
>> 			/* wait for spare statahead window */
>> 			do {
>> -				l_wait_event(sa_thread->t_ctl_waitq,
>> -					     !sa_sent_full(sai) ||
>> -					     sa_has_callback(sai) ||
>> -					     !list_empty(&sai->sai_agls) ||
>> -					     !thread_is_running(sa_thread),
>> -					     &lwi);
>> +				wait_event(sa_thread->t_ctl_waitq,
>> +					   !sa_sent_full(sai) ||
>> +					   sa_has_callback(sai) ||
>> +					   !list_empty(&sai->sai_agls) ||
>> +					   !thread_is_running(sa_thread));
>> 				sa_handle_callback(sai);
>> 				spin_lock(&lli->lli_agl_lock);
>> @@ -1128,11 +1122,10 @@ static int ll_statahead_thread(void *arg)
>> 	 * for file release to stop me.
>> 	 */
>> 	while (thread_is_running(sa_thread)) {
>> -		l_wait_event(sa_thread->t_ctl_waitq,
>> -			     sa_has_callback(sai) ||
>> -			     !agl_list_empty(sai) ||
>> -			     !thread_is_running(sa_thread),
>> -			     &lwi);
>> +		wait_event(sa_thread->t_ctl_waitq,
>> +			   sa_has_callback(sai) ||
>> +			   !agl_list_empty(sai) ||
>> +			   !thread_is_running(sa_thread));
>> 		sa_handle_callback(sai);
>> 	}
>> @@ -1145,9 +1138,8 @@ static int ll_statahead_thread(void *arg)
>> 		CDEBUG(D_READA, "stop agl thread: sai %p pid %u\n",
>> 		       sai, (unsigned int)agl_thread->t_pid);
>> -		l_wait_event(agl_thread->t_ctl_waitq,
>> -			     thread_is_stopped(agl_thread),
>> -			     &lwi);
>> +		wait_event(agl_thread->t_ctl_waitq,
>> +			   thread_is_stopped(agl_thread));
>> 	} else {
>> 		/* Set agl_thread flags anyway. */
>> 		thread_set_flags(agl_thread, SVC_STOPPED);
>> @@ -1159,8 +1151,8 @@ static int ll_statahead_thread(void *arg)
>> 	 */
>> 	while (sai->sai_sent != sai->sai_replied) {
>> 		/* in case we're not woken up, timeout wait */
>> -		lwi = LWI_TIMEOUT(msecs_to_jiffies(MSEC_PER_SEC >> 3),
>> -				  NULL, NULL);
>> +		struct l_wait_info lwi = LWI_TIMEOUT(msecs_to_jiffies(MSEC_PER_SEC >>
>> 3),
>> +						     NULL, NULL);
>> 		l_wait_event(sa_thread->t_ctl_waitq,
>> 			     sai->sai_sent == sai->sai_replied, &lwi);
>> 	}
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
