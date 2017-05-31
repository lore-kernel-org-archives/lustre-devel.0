From: Oleg Drokin <oleg.drokin@intel.com>
Date: Wed, 31 May 2017 09:36:56 -0400
Subject: [lustre-devel] [PATCH V2] libcfs: Fix a sleep-in-atomic bug in
	cfs_wi_deschedule
In-Reply-To: <1496217420-16868-1-git-send-email-baijiaju1990@163.com>
References: <1496217420-16868-1-git-send-email-baijiaju1990@163.com>
Message-ID: <C018CB68-5485-4EC7-ABE1-B15D5DD7DE64@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jia-Ju Bai <baijiaju1990@163.com>
Cc: andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, bobijam.xu@intel.com, dmitry.eremin@intel.com, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Hello!

On May 31, 2017, at 3:57 AM, Jia-Ju Bai wrote:

> The driver may sleep under a spin lock, and the function call path is:
> cfs_wi_deschedule (acquire the lock by spin_lock)
>  LASSERT
>    lbug_with_loc
>      libcfs_debug_dumplog
>        schedule and kthread_run --> may sleep
> 
> To fix it, all "LASSERT" is placed out of the spin_lock and spin_unlock.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> ---
> drivers/staging/lustre/lnet/libcfs/workitem.c |   12 ++++++------
> 1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/libcfs/workitem.c b/drivers/staging/lustre/lnet/libcfs/workitem.c
> index dbc2a9b..9c530cf 100644
> --- a/drivers/staging/lustre/lnet/libcfs/workitem.c
> +++ b/drivers/staging/lustre/lnet/libcfs/workitem.c
> @@ -140,6 +140,10 @@ struct cfs_wi_sched {
> 
> 	LASSERT(!in_interrupt()); /* because we use plain spinlock */
> 	LASSERT(!sched->ws_stopping);
> +	if (wi->wi_scheduled) {
> +		LASSERT(!list_empty(&wi->wi_list));
> +		LASSERT(sched->ws_nscheduled > 0);
> +	}

I don't think you can do this,
this was under spinlock because those values could change from a different thread
and we do need to look at them all together.

You are correct that LASSET/LBUG might schedule to dump a debug log
into a file and even if not it does sleep indefinitely after that.
But in reality the default option is "panic_on_lbug=1" which simply converts
LASSERT() into panic().

This is certainly not a normal condition and as such I think we can leave the code
as is.

Thanks.


> 
> 	/*
> 	 * return 0 if it's running already, otherwise return 1, which
> @@ -151,18 +155,14 @@ struct cfs_wi_sched {
> 	rc = !(wi->wi_running);
> 
> 	if (wi->wi_scheduled) { /* cancel pending schedules */
> -		LASSERT(!list_empty(&wi->wi_list));
> 		list_del_init(&wi->wi_list);
> -
> -		LASSERT(sched->ws_nscheduled > 0);
> 		sched->ws_nscheduled--;
> -
> 		wi->wi_scheduled = 0;
> 	}
> 
> -	LASSERT(list_empty(&wi->wi_list));
> -
> 	spin_unlock(&sched->ws_lock);
> +
> +	LASSERT(list_empty(&wi->wi_list));
> 	return rc;
> }
> EXPORT_SYMBOL(cfs_wi_deschedule);
> -- 
> 1.7.9.5
> 
