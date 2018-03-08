From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 8 Mar 2018 23:53:42 +0000
Subject: [lustre-devel] [PATCH 11/17] staging: lustre: ptlrpc: use
 workqueue for pinger
In-Reply-To: <151994708541.7628.5813099904100247526.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
 <151994708541.7628.5813099904100247526.stgit@noble>
Message-ID: <63D7C945-5CBC-4434-BAF1-F3EBA912CDEF@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mar 1, 2018, at 16:31, NeilBrown <neilb@suse.com> wrote:
> 
> lustre has a "Pinger" kthread which periodically pings peers
> to ensure all hosts are functioning.
> 
> This can more easily be done using a work queue.
> 
> As maintaining contact with other peers is import for
> keeping the filesystem running, and as the filesystem might
> be involved in freeing memory, it is safest to have a
> separate WQ_MEM_RECLAIM workqueue.
> 
> The SVC_EVENT functionality to wake up the thread can be
> replaced with mod_delayed_work().
> 
> Also use round_jiffies_up_relative() rather than setting a
> minimum of 1 second delay.  The PING_INTERVAL is measured in
> seconds so this meets the need is allow the workqueue to
> keep wakeups synchronized.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Looks reasonable.  Fortunately, pinging the server does not need
to be very accurate since it is only done occasionally when the
client is otherwise idle, so it shouldn't matter if the workqueue
operation is delayed by a few seconds.

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/ptlrpc/pinger.c |   81 +++++++------------------
> 1 file changed, 24 insertions(+), 57 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
> index b5f3cfee8e75..0775b7a048bb 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
> @@ -217,21 +217,18 @@ static void ptlrpc_pinger_process_import(struct obd_import *imp,
> 	}
> }
> 
> -static int ptlrpc_pinger_main(void *arg)
> -{
> -	struct ptlrpc_thread *thread = arg;
> -
> -	/* Record that the thread is running */
> -	thread_set_flags(thread, SVC_RUNNING);
> -	wake_up(&thread->t_ctl_waitq);
> +static struct workqueue_struct *pinger_wq;
> +static void ptlrpc_pinger_main(struct work_struct *ws);
> +static DECLARE_DELAYED_WORK(ping_work, ptlrpc_pinger_main);
> 
> -	/* And now, loop forever, pinging as needed. */
> -	while (1) {
> -		unsigned long this_ping = cfs_time_current();
> -		long time_to_next_wake;
> -		struct timeout_item *item;
> -		struct obd_import *imp;
> +static void ptlrpc_pinger_main(struct work_struct *ws)
> +{
> +	unsigned long this_ping = cfs_time_current();
> +	long time_to_next_wake;
> +	struct timeout_item *item;
> +	struct obd_import *imp;
> 
> +	do {
> 		mutex_lock(&pinger_mutex);
> 		list_for_each_entry(item, &timeout_list, ti_chain) {
> 			item->ti_cb(item, item->ti_cb_data);
> @@ -260,50 +257,24 @@ static int ptlrpc_pinger_main(void *arg)
> 		       time_to_next_wake,
> 		       cfs_time_add(this_ping,
> 				    PING_INTERVAL * HZ));
> -		if (time_to_next_wake > 0) {
> -			wait_event_idle_timeout(thread->t_ctl_waitq,
> -						thread_is_stopping(thread) ||
> -						thread_is_event(thread),
> -						max_t(long, time_to_next_wake, HZ));
> -			if (thread_test_and_clear_flags(thread, SVC_STOPPING))
> -				break;
> -			/* woken after adding import to reset timer */
> -			thread_test_and_clear_flags(thread, SVC_EVENT);
> -		}
> -	}
> +	} while (time_to_next_wake <= 0);
> 
> -	thread_set_flags(thread, SVC_STOPPED);
> -	wake_up(&thread->t_ctl_waitq);
> -
> -	CDEBUG(D_NET, "pinger thread exiting, process %d\n", current_pid());
> -	return 0;
> +	queue_delayed_work(pinger_wq, &ping_work,
> +			   round_jiffies_up_relative(time_to_next_wake));
> }
> 
> -static struct ptlrpc_thread pinger_thread;
> -
> int ptlrpc_start_pinger(void)
> {
> -	struct task_struct *task;
> -	int rc;
> -
> -	if (!thread_is_init(&pinger_thread) &&
> -	    !thread_is_stopped(&pinger_thread))
> +	if (pinger_wq)
> 		return -EALREADY;
> 
> -	init_waitqueue_head(&pinger_thread.t_ctl_waitq);
> -
> -	strcpy(pinger_thread.t_name, "ll_ping");
> -
> -	task = kthread_run(ptlrpc_pinger_main, &pinger_thread,
> -			   pinger_thread.t_name);
> -	if (IS_ERR(task)) {
> -		rc = PTR_ERR(task);
> -		CERROR("cannot start pinger thread: rc = %d\n", rc);
> -		return rc;
> +	pinger_wq = alloc_workqueue("ptlrpc_pinger", WQ_MEM_RECLAIM, 1);
> +	if (!pinger_wq) {
> +		CERROR("cannot start pinger workqueue\n");
> +		return -ENOMEM;
> 	}
> -	wait_event_idle(pinger_thread.t_ctl_waitq,
> -			thread_is_running(&pinger_thread));
> 
> +	queue_delayed_work(pinger_wq, &ping_work, 0);
> 	return 0;
> }
> 
> @@ -313,16 +284,13 @@ int ptlrpc_stop_pinger(void)
> {
> 	int rc = 0;
> 
> -	if (thread_is_init(&pinger_thread) ||
> -	    thread_is_stopped(&pinger_thread))
> +	if (!pinger_wq)
> 		return -EALREADY;
> 
> 	ptlrpc_pinger_remove_timeouts();
> -	thread_set_flags(&pinger_thread, SVC_STOPPING);
> -	wake_up(&pinger_thread.t_ctl_waitq);
> -
> -	wait_event_idle(pinger_thread.t_ctl_waitq,
> -			thread_is_stopped(&pinger_thread));
> +	cancel_delayed_work_sync(&ping_work);
> +	destroy_workqueue(pinger_wq);
> +	pinger_wq = NULL;
> 
> 	return rc;
> }
> @@ -505,6 +473,5 @@ static int ptlrpc_pinger_remove_timeouts(void)
> 
> void ptlrpc_pinger_wake_up(void)
> {
> -	thread_add_flags(&pinger_thread, SVC_EVENT);
> -	wake_up(&pinger_thread.t_ctl_waitq);
> +	mod_delayed_work(pinger_wq, &ping_work, 0);
> }
> 
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
