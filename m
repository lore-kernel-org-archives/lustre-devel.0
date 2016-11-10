From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 17:49:18 +0000 (GMT)
Subject: [lustre-devel] [patch] staging/lustre/osc: indent an if
	statement
In-Reply-To: <20161110125050.GA18577@mwanda>
References: <20161110125050.GA18577@mwanda>
Message-ID: <alpine.LFD.2.20.1611101748270.31600@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> We accidentally removed a tab here.  Let's add it back, and some curly
> braces as well since this is a muti-line indent.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
> index e337e87..bfc8d38 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_lock.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
> @@ -607,9 +607,11 @@ static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
>  			lvb = req_capsule_server_get(cap, &RMF_DLM_LVB);
>  			result = cl_object_glimpse(env, obj, lvb);
>  		}
> -		if (!exp_connect_lvb_type(req->rq_export))
> -		req_capsule_shrink(&req->rq_pill, &RMF_DLM_LVB,
> -				   sizeof(struct ost_lvb_v1), RCL_SERVER);
> +		if (!exp_connect_lvb_type(req->rq_export)) {
> +			req_capsule_shrink(&req->rq_pill, &RMF_DLM_LVB,
> +					   sizeof(struct ost_lvb_v1),
> +					   RCL_SERVER);
> +		}
>  		cl_object_put(env, obj);
>  	} else {
>  		/*
> 
