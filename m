From: Oleg Drokin <oleg.drokin@intel.com>
Date: Wed, 31 May 2017 09:39:51 -0400
Subject: [lustre-devel] [PATCH V2] libcfs: Fix a sleep-in-atomic bug in
	cfs_wi_exit
In-Reply-To: <1496217641-17002-1-git-send-email-baijiaju1990@163.com>
References: <1496217641-17002-1-git-send-email-baijiaju1990@163.com>
Message-ID: <440F74B1-2F94-4C08-A9F9-EDF039BE6565@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jia-Ju Bai <baijiaju1990@163.com>
Cc: andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, bobijam.xu@intel.com, dmitry.eremin@intel.com, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Hello!

On May 31, 2017, at 4:00 AM, Jia-Ju Bai wrote:

> The driver may sleep under a spin lock, and the function call path is:
> cfs_wi_exit (acquire the lock by spin_lock)
>  LASSERT
>    lbug_with_loc
>      libcfs_debug_dumplog
>        schedule and kthread_run --> may sleep
> 
> To fix it, all "LASSERT" is placed out of the spin_lock and spin_unlock.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> ---
> drivers/staging/lustre/lnet/libcfs/workitem.c |   13 +++++++------
> 1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/libcfs/workitem.c b/drivers/staging/lustre/lnet/libcfs/workitem.c
> index dbc2a9b..928d06d 100644
> --- a/drivers/staging/lustre/lnet/libcfs/workitem.c
> +++ b/drivers/staging/lustre/lnet/libcfs/workitem.c
> @@ -111,22 +111,23 @@ struct cfs_wi_sched {
> {
> 	LASSERT(!in_interrupt()); /* because we use plain spinlock */
> 	LASSERT(!sched->ws_stopping);
> +	LASSERT(wi->wi_running);
> +	if (wi->wi_scheduled) {
> +		LASSERT(!list_empty(&wi->wi_list));
> +		LASSERT(sched->ws_nscheduled > 0);
> +	}

Similarly here and in all other patches about LASSERT calls under spinlocks() from you,
just think of them as a panic() call, no operations are expected to continue
after it triggers.

Thanks.

> 
> 	spin_lock(&sched->ws_lock);
> 
> -	LASSERT(wi->wi_running);
> 	if (wi->wi_scheduled) { /* cancel pending schedules */
> -		LASSERT(!list_empty(&wi->wi_list));
> 		list_del_init(&wi->wi_list);
> -
> -		LASSERT(sched->ws_nscheduled > 0);
> 		sched->ws_nscheduled--;
> 	}
> 
> -	LASSERT(list_empty(&wi->wi_list));
> -
> 	wi->wi_scheduled = 1; /* LBUG future schedule attempts */
> 	spin_unlock(&sched->ws_lock);
> +
> +	LASSERT(list_empty(&wi->wi_list));
> }
> EXPORT_SYMBOL(cfs_wi_exit);
> 
> -- 
> 1.7.9.5
> 
