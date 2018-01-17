From: James Simmons <jsimmons@infradead.org>
Date: Wed, 17 Jan 2018 15:34:20 +0000 (GMT)
Subject: [lustre-devel] [PATCH 13/19] staging: lustre: use
 wait_event_idle_timeout in ptlrpcd()
In-Reply-To: <151538209379.23920.12930052742997185181.stgit@noble>
References: <151538168618.23920.8261096424342988792.stgit@noble>
 <151538209379.23920.12930052742997185181.stgit@noble>
Message-ID: <alpine.LFD.2.21.1801171534000.11282@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>


> We can replace l_wait_event() with
> wait_event_idle_timeout() here providing we call the
> timeout function when wait_event_idle_timeout() returns zero.
> 
> As ptlrpc_expired_set() returns 1, the l_wait_event() aborts of the
> first timeout.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/ptlrpc/client.c      |   12 ++++++++----
>  .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    2 +-
>  drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    9 +++++----
>  3 files changed, 14 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
> index 81b7a7046d82..f70176c6db08 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/client.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
> @@ -2125,9 +2125,8 @@ int ptlrpc_expire_one_request(struct ptlrpc_request *req, int async_unlink)
>   * Callback used when waiting on sets with l_wait_event.
>   * Always returns 1.
>   */
> -int ptlrpc_expired_set(void *data)
> +void ptlrpc_expired_set(struct ptlrpc_request_set *set)
>  {
> -	struct ptlrpc_request_set *set = data;
>  	struct list_head *tmp;
>  	time64_t now = ktime_get_real_seconds();
>  
> @@ -2156,7 +2155,12 @@ int ptlrpc_expired_set(void *data)
>  		 */
>  		ptlrpc_expire_one_request(req, 1);
>  	}
> +}
> +static int ptlrpc_expired_set_void(void *data)
> +{
> +	struct ptlrpc_request_set *set = data;
>  
> +	ptlrpc_expired_set(set);
>  	/*
>  	 * When waiting for a whole set, we always break out of the
>  	 * sleep so we can recalculate the timeout, or enable interrupts
> @@ -2286,7 +2290,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
>  			 * so we allow interrupts during the timeout.
>  			 */
>  			lwi = LWI_TIMEOUT_INTR_ALL(HZ,
> -						   ptlrpc_expired_set,
> +						   ptlrpc_expired_set_void,
>  						   ptlrpc_interrupted_set, set);
>  		else
>  			/*
> @@ -2295,7 +2299,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
>  			 * complete, or an in-flight req times out.
>  			 */
>  			lwi = LWI_TIMEOUT((timeout ? timeout : 1) * HZ,
> -					  ptlrpc_expired_set, set);
> +					  ptlrpc_expired_set_void, set);
>  
>  		rc = l_wait_event(set->set_waitq, ptlrpc_check_set(NULL, set), &lwi);
>  
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
> index f9decbd1459d..b7a8d7537a66 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
> +++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
> @@ -68,7 +68,7 @@ void ptlrpc_request_cache_free(struct ptlrpc_request *req);
>  void ptlrpc_init_xid(void);
>  void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
>  			    struct ptlrpc_request *req);
> -int ptlrpc_expired_set(void *data);
> +void ptlrpc_expired_set(struct ptlrpc_request_set *set);
>  int ptlrpc_set_next_timeout(struct ptlrpc_request_set *set);
>  void ptlrpc_resend_req(struct ptlrpc_request *request);
>  void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req);
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
> index 437b4b2a9072..6ed77521d025 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
> @@ -435,16 +435,17 @@ static int ptlrpcd(void *arg)
>  	 * new_req_list and ptlrpcd_check() moves them into the set.
>  	 */
>  	do {
> -		struct l_wait_info lwi;
>  		int timeout;
>  
>  		timeout = ptlrpc_set_next_timeout(set);
> -		lwi = LWI_TIMEOUT((timeout ? timeout : 1) * HZ,
> -				  ptlrpc_expired_set, set);
>  
>  		lu_context_enter(&env.le_ctx);
>  		lu_context_enter(env.le_ses);
> -		l_wait_event(set->set_waitq, ptlrpcd_check(&env, pc), &lwi);
> +		if (wait_event_idle_timeout(set->set_waitq,
> +					    ptlrpcd_check(&env, pc),
> +					    (timeout ? timeout : 1) * HZ) == 0)
> +			ptlrpc_expired_set(set);
> +
>  		lu_context_exit(&env.le_ctx);
>  		lu_context_exit(env.le_ses);
>  
> 
> 
> 
