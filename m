From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Feb 2017 15:46:25 +0000 (GMT)
Subject: [lustre-devel] [PATCH] staging: lustre: Fix incompatible
 argument in osc_match_base
In-Reply-To: <1487242226-14972-1-git-send-email-mrossibellom@gmail.com>
References: <1487242226-14972-1-git-send-email-mrossibellom@gmail.com>
Message-ID: <alpine.LFD.2.20.1702161544060.32586@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Maxime Rossi Bellom <mrossibellom@gmail.com>
> 
> sparse warn about _u32 used for two arguments in function
> osc_match_base instead of enum ldlm_type and enum ldlm_mode as
> used in the prototype.
> 
> Signed-off-by: Maxime Rossi Bellom <mrossibellom@gmail.com>

One of the pieces of a earlier patch I broke up that got lost :-(
Thanks for finding it.

Reviewed-by: James Simmons <jsimmons@infradead.org>

> ---
>  drivers/staging/lustre/lustre/osc/osc_request.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
> index 62c743b..c4cfe18 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_request.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_request.c
> @@ -2081,9 +2081,9 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
>  }
>  
>  int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
> -		   __u32 type, union ldlm_policy_data *policy, __u32 mode,
> -		   __u64 *flags, void *data, struct lustre_handle *lockh,
> -		   int unref)
> +		   enum ldlm_type type, union ldlm_policy_data *policy,
> +		   enum ldlm_mode mode, __u64 *flags, void *data,
> +		   struct lustre_handle *lockh, int unref)
>  {
>  	struct obd_device *obd = exp->exp_obd;
>  	__u64 lflags = *flags;
> -- 
> 2.7.4
> 
> 
