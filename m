From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 8 Mar 2018 19:22:08 +0000
Subject: [lustre-devel] [PATCH 09/17] staging: lustre: ldlm: use
 delayed_work for pools_recalc
In-Reply-To: <151994708534.7628.3824921218925924808.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
 <151994708534.7628.3824921218925924808.stgit@noble>
Message-ID: <45DCA0E5-F003-416C-9CA8-3C9CC7B06CDE@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mar 1, 2018, at 16:31, NeilBrown <neilb@suse.com> wrote:
> 
> ldlm currenty has a kthread which wakes up every so often
> and calls ldlm_pools_recalc().
> The thread is started and stopped, but no other external interactions
> happen.
> 
> This can trivially be replaced by a delayed_work if we have
> ldlm_pools_recalc() reschedule the work rather than just report
> when to do that.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/ldlm/ldlm_pool.c |   99 +++---------------------
> 1 file changed, 11 insertions(+), 88 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> index a0e486b57e08..53b8f33e54b5 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> @@ -784,9 +784,6 @@ static int ldlm_pool_granted(struct ldlm_pool *pl)
> 	return atomic_read(&pl->pl_granted);
> }
> 
> -static struct ptlrpc_thread *ldlm_pools_thread;
> -static struct completion ldlm_pools_comp;
> -
> /*
>  * count locks from all namespaces (if possible). Returns number of
>  * cached locks.
> @@ -899,8 +896,12 @@ static unsigned long ldlm_pools_cli_scan(struct shrinker *s,
> 			       sc->gfp_mask);
> }
> 
> -static int ldlm_pools_recalc(enum ldlm_side client)
> +static void ldlm_pools_recalc(struct work_struct *ws);
> +static DECLARE_DELAYED_WORK(ldlm_recalc_pools, ldlm_pools_recalc);
> +
> +static void ldlm_pools_recalc(struct work_struct *ws)
> {
> +	enum ldlm_side client = LDLM_NAMESPACE_CLIENT;
> 	struct ldlm_namespace *ns;
> 	struct ldlm_namespace *ns_old = NULL;
> 	/* seconds of sleep if no active namespaces */
> @@ -982,92 +983,19 @@ static int ldlm_pools_recalc(enum ldlm_side client)
> 	/* Wake up the blocking threads from time to time. */
> 	ldlm_bl_thread_wakeup();
> 
> -	return time;
> -}
> -
> -static int ldlm_pools_thread_main(void *arg)
> -{
> -	struct ptlrpc_thread *thread = (struct ptlrpc_thread *)arg;
> -	int c_time;
> -
> -	thread_set_flags(thread, SVC_RUNNING);
> -	wake_up(&thread->t_ctl_waitq);
> -
> -	CDEBUG(D_DLMTRACE, "%s: pool thread starting, process %d\n",
> -	       "ldlm_poold", current_pid());
> -
> -	while (1) {
> -		/*
> -		 * Recal all pools on this tick.
> -		 */
> -		c_time = ldlm_pools_recalc(LDLM_NAMESPACE_CLIENT);
> -
> -		/*
> -		 * Wait until the next check time, or until we're
> -		 * stopped.
> -		 */
> -		wait_event_idle_timeout(thread->t_ctl_waitq,
> -					thread_is_stopping(thread) ||
> -					thread_is_event(thread),
> -					c_time * HZ);
> -
> -		if (thread_test_and_clear_flags(thread, SVC_STOPPING))
> -			break;
> -		thread_test_and_clear_flags(thread, SVC_EVENT);
> -	}
> -
> -	thread_set_flags(thread, SVC_STOPPED);
> -	wake_up(&thread->t_ctl_waitq);
> -
> -	CDEBUG(D_DLMTRACE, "%s: pool thread exiting, process %d\n",
> -	       "ldlm_poold", current_pid());
> -
> -	complete_and_exit(&ldlm_pools_comp, 0);
> +	schedule_delayed_work(&ldlm_recalc_pools, time * HZ);
> }
> 
> static int ldlm_pools_thread_start(void)
> {
> -	struct task_struct *task;
> -
> -	if (ldlm_pools_thread)
> -		return -EALREADY;
> -
> -	ldlm_pools_thread = kzalloc(sizeof(*ldlm_pools_thread), GFP_NOFS);
> -	if (!ldlm_pools_thread)
> -		return -ENOMEM;
> -
> -	init_completion(&ldlm_pools_comp);
> -	init_waitqueue_head(&ldlm_pools_thread->t_ctl_waitq);
> +	schedule_delayed_work(&ldlm_recalc_pools, 0);
> 
> -	task = kthread_run(ldlm_pools_thread_main, ldlm_pools_thread,
> -			   "ldlm_poold");
> -	if (IS_ERR(task)) {
> -		CERROR("Can't start pool thread, error %ld\n", PTR_ERR(task));
> -		kfree(ldlm_pools_thread);
> -		ldlm_pools_thread = NULL;
> -		return PTR_ERR(task);
> -	}
> -	wait_event_idle(ldlm_pools_thread->t_ctl_waitq,
> -			thread_is_running(ldlm_pools_thread));
> 	return 0;
> }
> 
> static void ldlm_pools_thread_stop(void)
> {
> -	if (!ldlm_pools_thread)
> -		return;
> -
> -	thread_set_flags(ldlm_pools_thread, SVC_STOPPING);
> -	wake_up(&ldlm_pools_thread->t_ctl_waitq);
> -
> -	/*
> -	 * Make sure that pools thread is finished before freeing @thread.
> -	 * This fixes possible race and oops due to accessing freed memory
> -	 * in pools thread.
> -	 */
> -	wait_for_completion(&ldlm_pools_comp);
> -	kfree(ldlm_pools_thread);
> -	ldlm_pools_thread = NULL;
> +	cancel_delayed_work_sync(&ldlm_recalc_pools);
> }
> 
> static struct shrinker ldlm_pools_cli_shrinker = {
> @@ -1081,20 +1009,15 @@ int ldlm_pools_init(void)
> 	int rc;
> 
> 	rc = ldlm_pools_thread_start();
> -	if (rc)
> -		return rc;
> -
> -	rc = register_shrinker(&ldlm_pools_cli_shrinker);
> -	if (rc)
> -		ldlm_pools_thread_stop();
> +	if (!rc)
> +		rc = register_shrinker(&ldlm_pools_cli_shrinker);
> 
> 	return rc;
> }
> 
> void ldlm_pools_fini(void)
> {
> -	if (ldlm_pools_thread)
> -		unregister_shrinker(&ldlm_pools_cli_shrinker);
> +	unregister_shrinker(&ldlm_pools_cli_shrinker);
> 
> 	ldlm_pools_thread_stop();
> }
> 
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
