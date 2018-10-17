From: NeilBrown <neilb@suse.com>
Date: Thu, 18 Oct 2018 10:20:37 +1100
Subject: [lustre-devel] [PATCH 06/28] lustre: ldlm: ELC shouldn't wait
 on lock flush
In-Reply-To: <1539543498-29105-7-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
 <1539543498-29105-7-git-send-email-jsimmons@infradead.org>
Message-ID: <87sh14cg8q.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Oct 14 2018, James Simmons wrote:

> From: Andriy Skulysh <c17819@cray.com>
>
> The commit 08fd034670b5 ("staging: lustre: ldlm: revert the changes
> for lock canceling policy") removed the fix for LU-4300 when lru_resize
> is disabled.
>
> Introduce ldlm_cancel_aged_no_wait_policy to be used by ELC.
>
> Signed-off-by: Andriy Skulysh <c17819@cray.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-8578
> Seagate-bug-id: MRP-3662
> Reviewed-on: https://review.whamcloud.com/22286
> Reviewed-by: Vitaly Fertman <c17818@cray.com>
> Reviewed-by: Patrick Farrell <paf@cray.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  1 -
>  drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 51 +++++++++++++++-------
>  2 files changed, 35 insertions(+), 17 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
> index 1d7c727..709c527 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
> @@ -96,7 +96,6 @@ enum {
>  	LDLM_LRU_FLAG_NO_WAIT	= BIT(4), /* Cancel locks w/o blocking (neither
>  					   * sending nor waiting for any rpcs)
>  					   */
> -	LDLM_LRU_FLAG_LRUR_NO_WAIT = BIT(5), /* LRUR + NO_WAIT */
>  };
>  
>  int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> index 80260b07..3eb5036 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> @@ -579,8 +579,8 @@ int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
>  		req_capsule_filled_sizes(pill, RCL_CLIENT);
>  		avail = ldlm_capsule_handles_avail(pill, RCL_CLIENT, canceloff);
>  
> -		flags = ns_connect_lru_resize(ns) ?
> -			LDLM_LRU_FLAG_LRUR_NO_WAIT : LDLM_LRU_FLAG_AGED;
> +		flags = LDLM_LRU_FLAG_NO_WAIT | ns_connect_lru_resize(ns) ?
> +			LDLM_LRU_FLAG_LRUR : LDLM_LRU_FLAG_AGED;
>  		to_free = !ns_connect_lru_resize(ns) &&
>  			  opc == LDLM_ENQUEUE ? 1 : 0;

Bug.
The commit in SFS-lustre (7ca60f33893) is correct, but you dropped the
parentheses which introduces a bug.

While the SFS code is correct, it is formatted badly.
It should be

	lru_flags = LDLM_LRU_FLAG_NO_WAIT |
        	(ns_connect_lru_resize(ns) ?
                 LDLM_LRU_FLAG_LRUR : LDLM_LRU_FLAG_AGED);
or similar.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181018/177d4600/attachment.sig>
