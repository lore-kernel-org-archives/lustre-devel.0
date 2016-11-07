From: James Simmons <jsimmons@infradead.org>
Date: Mon, 7 Nov 2016 01:53:41 +0000 (GMT)
Subject: [lustre-devel] [PATCH 07/14] staging/lustre/ldlm: Reinstate
 ldlm_enqueue_pack()
In-Reply-To: <1478136304-867780-8-git-send-email-green@linuxhacker.ru>
References: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
	<1478136304-867780-8-git-send-email-green@linuxhacker.ru>
Message-ID: <alpine.LFD.2.20.1611070153200.21293@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> The function becomes used again with the next patch, so bring it back
> from dead, only this time make it static.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Reverts: bf2a033360f7 ("staging/lustre/ldlm: Remove unused ldlm_enqueue_pack()")
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
>  drivers/staging/lustre/lustre/ldlm/ldlm_request.c | 21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> index 6e704c7..1b9ae77 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> @@ -657,6 +657,27 @@ int ldlm_prep_enqueue_req(struct obd_export *exp, struct ptlrpc_request *req,
>  }
>  EXPORT_SYMBOL(ldlm_prep_enqueue_req);
>  
> +static struct ptlrpc_request *ldlm_enqueue_pack(struct obd_export *exp,
> +						int lvb_len)
> +{
> +	struct ptlrpc_request *req;
> +	int rc;
> +
> +	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_LDLM_ENQUEUE);
> +	if (!req)
> +		return ERR_PTR(-ENOMEM);
> +
> +	rc = ldlm_prep_enqueue_req(exp, req, NULL, 0);
> +	if (rc) {
> +		ptlrpc_request_free(req);
> +		return ERR_PTR(rc);
> +	}
> +
> +	req_capsule_set_size(&req->rq_pill, &RMF_DLM_LVB, RCL_SERVER, lvb_len);
> +	ptlrpc_request_set_replen(req);
> +	return req;
> +}
> +
>  /**
>   * Client-side lock enqueue.
>   *
> -- 
> 2.7.4
> 
> 
