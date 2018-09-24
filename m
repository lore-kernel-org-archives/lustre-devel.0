From: NeilBrown <neilb@suse.com>
Date: Mon, 24 Sep 2018 13:35:36 +1000
Subject: [lustre-devel] [PATCH 08/30] lustre: mgc: Remove unnecessary
 checks for config_log_put()
In-Reply-To: <1537205440-6656-9-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
 <1537205440-6656-9-git-send-email-jsimmons@infradead.org>
Message-ID: <878t3r5zzr.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Sep 17 2018, James Simmons wrote:

> From: Steve Guminski <stephenx.guminski@intel.com>
>
> Make config_log_put() check if its parameter is NULL, which makes
> it is unnecessary to perform the check prior to calling it.
> This patch removes the redundant checks.
>
> Signed-off-by: Steve Guminski <stephenx.guminski@intel.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9152
> Reviewed-on: https://review.whamcloud.com/25854
> Reviewed-by: Bob Glossman <bob.glossman@intel.com>
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/mgc/mgc_request.c | 36 +++++++++++--------------
>  1 file changed, 16 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> index 4552cc5..e6f8d9e 100644
> --- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
> +++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> @@ -131,6 +131,9 @@ static int config_log_get(struct config_llog_data *cld)
>   */
>  static void config_log_put(struct config_llog_data *cld)
>  {
> +	if (unlikely(!cld))
> +		return;
> +

I've removed the "unlikely()" call.

Partly because use of likely/unlikely is discouraged where the
difference cannot be measured (or clearly justified some other way),
and partly because .....

> @@ -387,6 +387,9 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
>  
>  static inline void config_mark_cld_stop(struct config_llog_data *cld)
>  {
> +	if (!cld)
> +		return;
> +

.... there is no "unlikely()" here, and I like consistency.

Thanks,
NeilBrown


>  	mutex_lock(&cld->cld_lock);
>  	spin_lock(&config_list_lock);
>  	cld->cld_stopping = 1;
> @@ -436,18 +439,13 @@ static int config_log_end(char *logname, struct config_llog_instance *cfg)
>  	cld->cld_sptlrpc = NULL;
>  	mutex_unlock(&cld->cld_lock);
>  
> -	if (cld_recover) {
> -		config_mark_cld_stop(cld_recover);
> -		config_log_put(cld_recover);
> -	}
> +	config_mark_cld_stop(cld_recover);
> +	config_log_put(cld_recover);
>  
> -	if (cld_params) {
> -		config_mark_cld_stop(cld_params);
> -		config_log_put(cld_params);
> -	}
> +	config_mark_cld_stop(cld_params);
> +	config_log_put(cld_params);
>  
> -	if (cld_sptlrpc)
> -		config_log_put(cld_sptlrpc);
> +	config_log_put(cld_sptlrpc);
>  
>  	/* drop the ref from the find */
>  	config_log_put(cld);
> @@ -593,8 +591,7 @@ static int mgc_requeue_thread(void *data)
>  			cld->cld_lostlock = 0;
>  			spin_unlock(&config_list_lock);
>  
> -			if (cld_prev)
> -				config_log_put(cld_prev);
> +			config_log_put(cld_prev);
>  			cld_prev = cld;
>  
>  			if (likely(!(rq_state & RQ_STOP))) {
> @@ -606,8 +603,7 @@ static int mgc_requeue_thread(void *data)
>  			}
>  		}
>  		spin_unlock(&config_list_lock);
> -		if (cld_prev)
> -			config_log_put(cld_prev);
> +		config_log_put(cld_prev);
>  
>  		/* Wait a bit to see if anyone else needs a requeue */
>  		wait_event_idle(rq_waitq, rq_state & (RQ_NOW | RQ_STOP));
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180924/14be13eb/attachment.sig>
