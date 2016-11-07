From: James Simmons <jsimmons@infradead.org>
Date: Mon, 7 Nov 2016 01:56:28 +0000 (GMT)
Subject: [lustre-devel] [PATCH 14/14] staging/lustre: Get rid of
 LIBLUSTRE_CLIENT and its users
In-Reply-To: <1478136304-867780-15-git-send-email-green@linuxhacker.ru>
References: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
	<1478136304-867780-15-git-send-email-green@linuxhacker.ru>
Message-ID: <alpine.LFD.2.20.1611070156050.21293@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> This define only made sense in a userspace library client, not in the kernel.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
>  drivers/staging/lustre/lustre/include/lustre_lib.h |  2 --
>  drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 15 +--------------
>  2 files changed, 1 insertion(+), 16 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
> index 6b23191..27f3148 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_lib.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
> @@ -350,8 +350,6 @@ do {									   \
>  	l_wait_event_exclusive_head(wq, condition, &lwi);       \
>  })
>  
> -#define LIBLUSTRE_CLIENT (0)
> -
>  /** @} lib */
>  
>  #endif /* _LUSTRE_LIB_H */
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> index c5d00d1..6a96f2c 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> @@ -475,12 +475,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
>  				   "client-side enqueue, new policy data");
>  	}
>  
> -	if ((*flags) & LDLM_FL_AST_SENT ||
> -	    /* Cancel extent locks as soon as possible on a liblustre client,
> -	     * because it cannot handle asynchronous ASTs robustly (see
> -	     * bug 7311).
> -	     */
> -	    (LIBLUSTRE_CLIENT && type == LDLM_EXTENT)) {
> +	if ((*flags) & LDLM_FL_AST_SENT) {
>  		lock_res_and_lock(lock);
>  		lock->l_flags |= LDLM_FL_CBPENDING |  LDLM_FL_BL_AST;
>  		unlock_res_and_lock(lock);
> @@ -775,14 +770,6 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
>  	body->lock_flags = ldlm_flags_to_wire(*flags);
>  	body->lock_handle[0] = *lockh;
>  
> -	/*
> -	 * Liblustre client doesn't get extent locks, except for O_APPEND case
> -	 * where [0, OBD_OBJECT_EOF] lock is taken, or truncate, where
> -	 * [i_size, OBD_OBJECT_EOF] lock is taken.
> -	 */
> -	LASSERT(ergo(LIBLUSTRE_CLIENT, einfo->ei_type != LDLM_EXTENT ||
> -		     policy->l_extent.end == OBD_OBJECT_EOF));
> -
>  	if (async) {
>  		LASSERT(reqp);
>  		return 0;
> -- 
> 2.7.4
> 
> 
