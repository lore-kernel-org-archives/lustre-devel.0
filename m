From: James Simmons <jsimmons@infradead.org>
Date: Wed, 17 Jan 2018 15:34:46 +0000 (GMT)
Subject: [lustre-devel] [PATCH 14/19] staging: lustre: improve waiting
 in sptlrpc_req_refresh_ctx
In-Reply-To: <151538209383.23920.18027403730394945280.stgit@noble>
References: <151538168618.23920.8261096424342988792.stgit@noble>
 <151538209383.23920.18027403730394945280.stgit@noble>
Message-ID: <alpine.LFD.2.21.1801171534340.11282@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>


> Replace l_wait_event with wait_event_idle_timeout() and call the
> handler function explicitly.  This makes it more clear
> what is happening.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/ptlrpc/sec.c |   34 ++++++++++++++++++++--------
>  1 file changed, 24 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
> index 617e004d00f8..90e3b3022106 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
> @@ -554,9 +554,8 @@ int ctx_check_refresh(struct ptlrpc_cli_ctx *ctx)
>  }
>  
>  static
> -int ctx_refresh_timeout(void *data)
> +int ctx_refresh_timeout(struct ptlrpc_request *req)
>  {
> -	struct ptlrpc_request *req = data;
>  	int rc;
>  
>  	/* conn_cnt is needed in expire_one_request */
> @@ -575,10 +574,8 @@ int ctx_refresh_timeout(void *data)
>  }
>  
>  static
> -void ctx_refresh_interrupt(void *data)
> +void ctx_refresh_interrupt(struct ptlrpc_request *req)
>  {
> -	struct ptlrpc_request *req = data;
> -
>  	spin_lock(&req->rq_lock);
>  	req->rq_intr = 1;
>  	spin_unlock(&req->rq_lock);
> @@ -611,7 +608,6 @@ int sptlrpc_req_refresh_ctx(struct ptlrpc_request *req, long timeout)
>  {
>  	struct ptlrpc_cli_ctx *ctx = req->rq_cli_ctx;
>  	struct ptlrpc_sec *sec;
> -	struct l_wait_info lwi;
>  	int rc;
>  
>  	LASSERT(ctx);
> @@ -743,10 +739,28 @@ int sptlrpc_req_refresh_ctx(struct ptlrpc_request *req, long timeout)
>  	req->rq_restart = 0;
>  	spin_unlock(&req->rq_lock);
>  
> -	lwi = LWI_TIMEOUT_INTR(msecs_to_jiffies(timeout * MSEC_PER_SEC),
> -			       ctx_refresh_timeout, ctx_refresh_interrupt,
> -			       req);
> -	rc = l_wait_event(req->rq_reply_waitq, ctx_check_refresh(ctx), &lwi);
> +	rc = wait_event_idle_timeout(req->rq_reply_waitq,
> +				     ctx_check_refresh(ctx),
> +				     timeout * HZ);
> +	if (rc == 0 && ctx_refresh_timeout(req) == 0) {
> +		/* Keep waiting, but enable some signals */
> +		rc = l_wait_event_abortable(req->rq_reply_waitq,
> +					    ctx_check_refresh(ctx));
> +		if (rc == 0)
> +			rc = 1;
> +	}
> +
> +	if (rc > 0)
> +		/* condition is true */
> +		rc = 0;
> +	else if (rc == 0)
> +		/* Timed out */
> +		rc = -ETIMEDOUT;
> +	else {
> +		/* Aborted by signal */
> +		rc = -EINTR;
> +		ctx_refresh_interrupt(req);
> +	}
>  
>  	/*
>  	 * following cases could lead us here:
> 
> 
> 
