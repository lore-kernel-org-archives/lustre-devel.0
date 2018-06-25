From: NeilBrown <neilb@suse.com>
Date: Mon, 25 Jun 2018 11:42:44 +1000
Subject: [lustre-devel] [PATCH 1/8] staging: lustre: lnet: simplify
 lnet_eq_wait_locked
In-Reply-To: <1529877232-15582-2-git-send-email-jsimmons@infradead.org>
References: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
 <1529877232-15582-2-git-send-email-jsimmons@infradead.org>
Message-ID: <87in678wvf.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jun 24 2018, James Simmons wrote:

> We can simplify the code by taking advantage of the behavior
> of schedule_timeout_interruptible(). Instead of testing if
> tms is less than zero we can pass in a signed long that
> schedule_timeout_interruptible is expecting and for the case
> of no timeout we can pass in MAX_SCHEDULE_TIMEOUT.
>
> Signed-off-by: James Simmons <uja.ornl@yahoo.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9019
> Reviewed-on: https://review.whamcloud.com/23147
> Reviewed-by: Doug Oucharek <dougso@me.com>
> Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/include/linux/lnet/api.h    |  2 +-
>  .../lustre/include/uapi/linux/lnet/lnet-types.h    |  2 --
>  drivers/staging/lustre/lnet/lnet/api-ni.c          | 38 ++++++++++++++--------
>  drivers/staging/lustre/lnet/lnet/lib-eq.c          | 26 +++++----------
>  4 files changed, 33 insertions(+), 35 deletions(-)
>
> diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
> index dae2e4f..2242921 100644
> --- a/drivers/staging/lustre/include/linux/lnet/api.h
> +++ b/drivers/staging/lustre/include/linux/lnet/api.h
> @@ -168,7 +168,7 @@ int LNetEQAlloc(unsigned int       count_in,
>  
>  int LNetEQPoll(struct lnet_handle_eq *eventqs_in,
>  	       int		 neq_in,
> -	       int		 timeout_ms,
> +	       signed long	 timeout,
>  	       int		 interruptible,
>  	       struct lnet_event *event_out,
>  	       int		*which_eq_out);
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> index 1be9b7a..14715a8 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> @@ -77,8 +77,6 @@
>  #define LNET_PID_USERFLAG 0x80000000 /* set in userspace peers */
>  #define LNET_PID_LUSTRE	  12345
>  
> -#define LNET_TIME_FOREVER (-1)
> -
>  /* how an LNET NID encodes net:address */
>  /** extract the address part of an lnet_nid_t */
>  
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index f9ed697..878c92c 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -59,7 +59,7 @@
>  module_param(rnet_htable_size, int, 0444);
>  MODULE_PARM_DESC(rnet_htable_size, "size of remote network hash table");
>  
> -static int lnet_ping(struct lnet_process_id id, int timeout_ms,
> +static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  		     struct lnet_process_id __user *ids, int n_ids);
>  
>  static char *
> @@ -2052,17 +2052,29 @@ void lnet_lib_exit(void)
>  	case IOC_LIBCFS_LNET_FAULT:
>  		return lnet_fault_ctl(data->ioc_flags, data);
>  
> -	case IOC_LIBCFS_PING:
> +	case IOC_LIBCFS_PING: {
> +		signed long timeout;
> +
>  		id.nid = data->ioc_nid;
>  		id.pid = data->ioc_u32[0];
> -		rc = lnet_ping(id, data->ioc_u32[1], /* timeout */
> -			       data->ioc_pbuf1,
> +
> +		/* Don't block longer than 2 minutes */
> +		if (data->ioc_u32[1] > 120 * MSEC_PER_SEC)
> +			return -EINVAL;
> +
> +		/* If timestamp is negative then disable timeout */
> +		if ((s32)data->ioc_u32[1] < 0)
> +			timeout = MAX_SCHEDULE_TIMEOUT;
> +		else
> +			timeout = msecs_to_jiffies(data->ioc_u32[1]);
> +
> +		rc = lnet_ping(id, timeout, data->ioc_pbuf1,
>  			       data->ioc_plen1 / sizeof(struct lnet_process_id));
>  		if (rc < 0)
>  			return rc;
>  		data->ioc_count = rc;
>  		return 0;
> -
> +	}
>  	default:
>  		ni = lnet_net2ni(data->ioc_net);
>  		if (!ni)
> @@ -2126,7 +2138,7 @@ void LNetDebugPeer(struct lnet_process_id id)
>  }
>  EXPORT_SYMBOL(LNetGetId);
>  
> -static int lnet_ping(struct lnet_process_id id, int timeout_ms,
> +static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  		     struct lnet_process_id __user *ids, int n_ids)
>  {
>  	struct lnet_handle_eq eqh;
> @@ -2136,7 +2148,7 @@ static int lnet_ping(struct lnet_process_id id, int timeout_ms,
>  	int which;
>  	int unlinked = 0;
>  	int replied = 0;
> -	const int a_long_time = 60000; /* mS */
> +	const signed long a_long_time = msecs_to_jiffies(60 * MSEC_PER_SEC);

I've changed this to
	a_long_toime = 60*HZ;

as that is the more common pattern in the kernel.

>  	int infosz;
>  	struct lnet_ping_info *info;
>  	struct lnet_process_id tmpid;
> @@ -2147,10 +2159,8 @@ static int lnet_ping(struct lnet_process_id id, int timeout_ms,
>  
>  	infosz = offsetof(struct lnet_ping_info, pi_ni[n_ids]);
>  
> -	if (n_ids <= 0 ||
> -	    id.nid == LNET_NID_ANY ||
> -	    timeout_ms > 500000 ||	      /* arbitrary limit! */
> -	    n_ids > 20)			 /* arbitrary limit! */
> +	/* n_ids limit is arbitrary */
> +	if (n_ids <= 0 || n_ids > 20 || id.nid == LNET_NID_ANY)
>  		return -EINVAL;
>  
>  	if (id.pid == LNET_PID_ANY)
> @@ -2194,13 +2204,13 @@ static int lnet_ping(struct lnet_process_id id, int timeout_ms,
>  
>  		/* NB must wait for the UNLINK event below... */
>  		unlinked = 1;
> -		timeout_ms = a_long_time;
> +		timeout = a_long_time;
>  	}
>  
>  	do {
>  		/* MUST block for unlink to complete */
>  
> -		rc2 = LNetEQPoll(&eqh, 1, timeout_ms, !unlinked,
> +		rc2 = LNetEQPoll(&eqh, 1, timeout, !unlinked,
>  				 &event, &which);
>  
>  		CDEBUG(D_NET, "poll %d(%d %d)%s\n", rc2,
> @@ -2222,7 +2232,7 @@ static int lnet_ping(struct lnet_process_id id, int timeout_ms,
>  				LNetMDUnlink(mdh);
>  				/* No assertion (racing with network) */
>  				unlinked = 1;
> -				timeout_ms = a_long_time;
> +				timeout = a_long_time;
>  			} else if (!rc2) {
>  				/* timed out waiting for unlink */
>  				CWARN("ping %s: late network completion\n",
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
> index c78e703..366ad8a 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
> @@ -308,13 +308,12 @@
>   */
>  
>  static int
> -lnet_eq_wait_locked(int *timeout_ms, long state)
> +lnet_eq_wait_locked(signed long *timeout, long state)
>  __must_hold(&the_lnet.ln_eq_wait_lock)
>  {
> -	int tms = *timeout_ms;
> +	signed long tms = *timeout;
>  	int wait;
>  	wait_queue_entry_t wl;
> -	unsigned long now;
>  
>  	if (!tms)
>  		return -ENXIO; /* don't want to wait and no new event */
> @@ -325,18 +324,9 @@
>  
>  	lnet_eq_wait_unlock();
>  
> -	if (tms < 0) {
> -		schedule();
> -	} else {
> -		now = jiffies;
> -		schedule_timeout(msecs_to_jiffies(tms));
> -		tms -= jiffies_to_msecs(jiffies - now);
> -		if (tms < 0) /* no more wait but may have new event */
> -			tms = 0;
> -	}
> -
> +	tms = schedule_timeout_interruptible(tms);

I've changed this to schedule_timeout().
The task state has already been set (to INTERRUPTIBLE or NOLOAD) and
we don't want to set it again.

Thanks,
NeilBrown


>  	wait = tms; /* might need to call here again */
> -	*timeout_ms = tms;
> +	*timeout = tms;
>  
>  	lnet_eq_wait_lock();
>  	remove_wait_queue(&the_lnet.ln_eq_waitq, &wl);
> @@ -356,8 +346,8 @@
>   * fixed period, or block indefinitely.
>   *
>   * \param eventqs,neq An array of EQ handles, and size of the array.
> - * \param timeout_ms Time in milliseconds to wait for an event to occur on
> - * one of the EQs. The constant LNET_TIME_FOREVER can be used to indicate an
> + * \param timeout Time in jiffies to wait for an event to occur on
> + * one of the EQs. The constant MAX_SCHEDULE_TIMEOUT can be used to indicate an
>   * infinite timeout.
>   * \param interruptible, if true, use TASK_INTERRUPTIBLE, else TASK_NOLOAD
>   * \param event,which On successful return (1 or -EOVERFLOW), \a event will
> @@ -372,7 +362,7 @@
>   * \retval -ENOENT    If there's an invalid handle in \a eventqs.
>   */
>  int
> -LNetEQPoll(struct lnet_handle_eq *eventqs, int neq, int timeout_ms,
> +LNetEQPoll(struct lnet_handle_eq *eventqs, int neq, signed long timeout,
>  	   int interruptible,
>  	   struct lnet_event *event, int *which)
>  {
> @@ -414,7 +404,7 @@
>  		 *  0 : don't want to wait anymore, but might have new event
>  		 *      so need to call dequeue again
>  		 */
> -		wait = lnet_eq_wait_locked(&timeout_ms,
> +		wait = lnet_eq_wait_locked(&timeout,
>  					   interruptible ? TASK_INTERRUPTIBLE
>  					   : TASK_NOLOAD);
>  		if (wait < 0) /* no new event */
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180625/42a1c406/attachment.sig>
