From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 8 Mar 2018 19:23:20 +0000
Subject: [lustre-devel] [PATCH 10/17] staging: lustre: ptlrpc: use
 delayed_work in sec_gc
In-Reply-To: <151994708538.7628.11965951418635189732.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
 <151994708538.7628.11965951418635189732.stgit@noble>
Message-ID: <D6D3EC01-6338-4285-A4FE-9F9C54EC1586@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mar 1, 2018, at 16:31, NeilBrown <neilb@suse.com> wrote:
> 
> The garbage collection for security contexts currently
> has a dedicated kthread which wakes up every 30 minutes
> to discard old garbage.
> 
> Replace this with a simple delayed_work item on the
> system work queue.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/ptlrpc/sec_gc.c |   90 ++++++++-----------------
> 1 file changed, 28 insertions(+), 62 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
> index 48f1a72afd77..2c8bad7b7877 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
> @@ -55,7 +55,6 @@ static spinlock_t sec_gc_list_lock;
> static LIST_HEAD(sec_gc_ctx_list);
> static spinlock_t sec_gc_ctx_list_lock;
> 
> -static struct ptlrpc_thread sec_gc_thread;
> static atomic_t sec_gc_wait_del = ATOMIC_INIT(0);
> 
> void sptlrpc_gc_add_sec(struct ptlrpc_sec *sec)
> @@ -139,86 +138,53 @@ static void sec_do_gc(struct ptlrpc_sec *sec)
> 	sec->ps_gc_next = ktime_get_real_seconds() + sec->ps_gc_interval;
> }
> 
> -static int sec_gc_main(void *arg)
> -{
> -	struct ptlrpc_thread *thread = arg;
> -
> -	unshare_fs_struct();
> +static void sec_gc_main(struct work_struct *ws);
> +static DECLARE_DELAYED_WORK(sec_gc_work, sec_gc_main);
> 
> -	/* Record that the thread is running */
> -	thread_set_flags(thread, SVC_RUNNING);
> -	wake_up(&thread->t_ctl_waitq);
> -
> -	while (1) {
> -		struct ptlrpc_sec *sec;
> +static void sec_gc_main(struct work_struct *ws)
> +{
> +	struct ptlrpc_sec *sec;
> 
> -		sec_process_ctx_list();
> +	sec_process_ctx_list();
> again:
> -		/* go through sec list do gc.
> -		 * FIXME here we iterate through the whole list each time which
> -		 * is not optimal. we perhaps want to use balanced binary tree
> -		 * to trace each sec as order of expiry time.
> -		 * another issue here is we wakeup as fixed interval instead of
> -		 * according to each sec's expiry time
> +	/* go through sec list do gc.
> +	 * FIXME here we iterate through the whole list each time which
> +	 * is not optimal. we perhaps want to use balanced binary tree
> +	 * to trace each sec as order of expiry time.
> +	 * another issue here is we wakeup as fixed interval instead of
> +	 * according to each sec's expiry time
> +	 */
> +	mutex_lock(&sec_gc_mutex);
> +	list_for_each_entry(sec, &sec_gc_list, ps_gc_list) {
> +		/* if someone is waiting to be deleted, let it
> +		 * proceed as soon as possible.
> 		 */
> -		mutex_lock(&sec_gc_mutex);
> -		list_for_each_entry(sec, &sec_gc_list, ps_gc_list) {
> -			/* if someone is waiting to be deleted, let it
> -			 * proceed as soon as possible.
> -			 */
> -			if (atomic_read(&sec_gc_wait_del)) {
> -				CDEBUG(D_SEC, "deletion pending, start over\n");
> -				mutex_unlock(&sec_gc_mutex);
> -				goto again;
> -			}
> -
> -			sec_do_gc(sec);
> +		if (atomic_read(&sec_gc_wait_del)) {
> +			CDEBUG(D_SEC, "deletion pending, start over\n");
> +			mutex_unlock(&sec_gc_mutex);
> +			goto again;
> 		}
> -		mutex_unlock(&sec_gc_mutex);
> -
> -		/* check ctx list again before sleep */
> -		sec_process_ctx_list();
> -		wait_event_idle_timeout(thread->t_ctl_waitq,
> -					thread_is_stopping(thread),
> -					SEC_GC_INTERVAL * HZ);
> 
> -		if (thread_test_and_clear_flags(thread, SVC_STOPPING))
> -			break;
> +		sec_do_gc(sec);
> 	}
> +	mutex_unlock(&sec_gc_mutex);
> 
> -	thread_set_flags(thread, SVC_STOPPED);
> -	wake_up(&thread->t_ctl_waitq);
> -	return 0;
> +	/* check ctx list again before sleep */
> +	sec_process_ctx_list();
> +	schedule_delayed_work(&sec_gc_work, SEC_GC_INTERVAL * HZ);
> }
> 
> int sptlrpc_gc_init(void)
> {
> -	struct task_struct *task;
> -
> 	mutex_init(&sec_gc_mutex);
> 	spin_lock_init(&sec_gc_list_lock);
> 	spin_lock_init(&sec_gc_ctx_list_lock);
> 
> -	/* initialize thread control */
> -	memset(&sec_gc_thread, 0, sizeof(sec_gc_thread));
> -	init_waitqueue_head(&sec_gc_thread.t_ctl_waitq);
> -
> -	task = kthread_run(sec_gc_main, &sec_gc_thread, "sptlrpc_gc");
> -	if (IS_ERR(task)) {
> -		CERROR("can't start gc thread: %ld\n", PTR_ERR(task));
> -		return PTR_ERR(task);
> -	}
> -
> -	wait_event_idle(sec_gc_thread.t_ctl_waitq,
> -			thread_is_running(&sec_gc_thread));
> +	schedule_delayed_work(&sec_gc_work, 0);
> 	return 0;
> }
> 
> void sptlrpc_gc_fini(void)
> {
> -	thread_set_flags(&sec_gc_thread, SVC_STOPPING);
> -	wake_up(&sec_gc_thread.t_ctl_waitq);
> -
> -	wait_event_idle(sec_gc_thread.t_ctl_waitq,
> -			thread_is_stopped(&sec_gc_thread));
> +	cancel_delayed_work_sync(&sec_gc_work);
> }
> 
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
