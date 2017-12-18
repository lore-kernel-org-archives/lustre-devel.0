From: Patrick Farrell <paf@cray.com>
Date: Mon, 18 Dec 2017 18:03:30 +0000
Subject: [lustre-devel] [PATCH 02/16] staging: lustre: replace simple
 cases of l_wait_event() with wait_event().
In-Reply-To: <151358147981.5099.13114335078693829049.stgit@noble>
References: <151358127190.5099.12792810096274074963.stgit@noble>
 <151358147981.5099.13114335078693829049.stgit@noble>
Message-ID: <D65D5D21.C5BF8%paf@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

The wait calls in ll_statahead_thread are done in a service thread, and
should probably *not* contribute to load.

The one in osc_extent_wait is perhaps tough - It is called both from user
threads & daemon threads depending on the situation.  The effect of adding
that to load average could be significant for some activities, even when
no user threads are busy.  Thoughts from other Lustre people would be
welcome here.


Similar issues for osc_object_invalidate.

(If no one else speaks up, my vote is no contribution to load for those
OSC waits.)

Otherwise this one looks good...

On 12/18/17, 1:17 AM, "lustre-devel on behalf of NeilBrown"
<lustre-devel-bounces at lists.lustre.org on behalf of neilb@suse.com> wrote:

>@@ -968,7 +964,6 @@ static int ll_statahead_thread(void *arg)
>	int		       first  = 0;
>	int		       rc     = 0;
>	struct md_op_data *op_data;
>-	struct l_wait_info	lwi    = { 0 };
>	sai = ll_sai_get(dir);
>	sa_thread = &sai->sai_thread;
>@@ -1069,12 +1064,11 @@ static int ll_statahead_thread(void *arg)
>			/* wait for spare statahead window */
>			do {
>-				l_wait_event(sa_thread->t_ctl_waitq,
>-					     !sa_sent_full(sai) ||
>-					     sa_has_callback(sai) ||
>-					     !list_empty(&sai->sai_agls) ||
>-					     !thread_is_running(sa_thread),
>-					     &lwi);
>+				wait_event(sa_thread->t_ctl_waitq,
>+					   !sa_sent_full(sai) ||
>+					   sa_has_callback(sai) ||
>+					   !list_empty(&sai->sai_agls) ||
>+					   !thread_is_running(sa_thread));
>				sa_handle_callback(sai);
>				spin_lock(&lli->lli_agl_lock);
>@@ -1128,11 +1122,10 @@ static int ll_statahead_thread(void *arg)
>	 * for file release to stop me.
>	 */
>	while (thread_is_running(sa_thread)) {
>-		l_wait_event(sa_thread->t_ctl_waitq,
>-			     sa_has_callback(sai) ||
>-			     !agl_list_empty(sai) ||
>-			     !thread_is_running(sa_thread),
>-			     &lwi);
>+		wait_event(sa_thread->t_ctl_waitq,
>+			   sa_has_callback(sai) ||
>+			   !agl_list_empty(sai) ||
>+			   !thread_is_running(sa_thread));
>		sa_handle_callback(sai);
>	}
>@@ -1145,9 +1138,8 @@ static int ll_statahead_thread(void *arg)
>		CDEBUG(D_READA, "stop agl thread: sai %p pid %u\n",
>		       sai, (unsigned int)agl_thread->t_pid);
>-		l_wait_event(agl_thread->t_ctl_waitq,
>-			     thread_is_stopped(agl_thread),
>-			     &lwi);
>+		wait_event(agl_thread->t_ctl_waitq,
>+			   thread_is_stopped(agl_thread));
>	} else {
>		/* Set agl_thread flags anyway. */
>		thread_set_flags(agl_thread, SVC_STOPPED);
>@@ -1159,8 +1151,8 @@ static int ll_statahead_thread(void *arg)
>	 */
>	while (sai->sai_sent != sai->sai_replied) {
>		/* in case we're not woken up, timeout wait */
>-		lwi = LWI_TIMEOUT(msecs_to_jiffies(MSEC_PER_SEC >> 3),
>-				  NULL, NULL);
>+		struct l_wait_info lwi = LWI_TIMEOUT(msecs_to_jiffies(MSEC_PER_SEC >>
>3),
>+						     NULL, NULL);
>		l_wait_event(sa_thread->t_ctl_waitq,
>			     sai->sai_sent == sai->sai_replied, &lwi);
>	}
