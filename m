From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 16:25:03 +0100 (BST)
Subject: [lustre-devel] [PATCH] staging: lustre: mgc: fix potential use
 after free in error path
In-Reply-To: <1502102580-29556-1-git-send-email-cakturk@gmail.com>
References: <1502102580-29556-1-git-send-email-cakturk@gmail.com>
Message-ID: <alpine.LFD.2.20.1708141622350.14369@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Cihangir Akturk <cakturk@gmail.com>
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org



On Mon, 7 Aug 2017, Cihangir Akturk wrote:

> The config_log_add() function first calls config_log_put() with the
> variable 'cld' and then jumps to label 'out_cld', which will call
> the same function with the same 'cld' variable. However, at this
> point, 'cld' might have been already freed by the first invocation
> of config_log_put(). Even if we remove the invocation at that point,
> we will still get into trouble. This is because, in the error path,
> just below the label 'out_cld', we try to put 'params_cls' and
> 'sptlrpc_cld', which might also have been freed by config_log_put().
> 
> The point is that, config_llog_data::cld_sptlrpc and
> config_llog_data::cld_params members are assigned at the beginning
> of this function.
> 
> To avoid this, do not call config_log_put() inside the else block,
> immediately jump to 'out_cld' instead. Moreover, remove assignments
> to config_llog_data::cld_sptlrpc and config_llog_data::cld_params at
> the beginning, since we already assign them below in the function
> with 'cld_lock' held.
> 
> As an additional benefit, code size gets smaller.
> 
> before:
> text    data     bss     dec     hex filename
> 26188   2256    4208   32652    7f8c drivers/staging/lustre/lustre/mgc/mgc_request.o
> 
> after:
> text    data     bss     dec     hex filename
> 26092   2256    4208   32556    7f2c drivers/staging/lustre/lustre/mgc/mgc_request.o
> 
> Signed-off-by: Cihangir Akturk <cakturk@gmail.com>
> ---
>  drivers/staging/lustre/lustre/mgc/mgc_request.c | 16 +++-------------
>  1 file changed, 3 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> index eee0b66..36c3049 100644
> --- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
> +++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> @@ -288,7 +288,7 @@ config_log_add(struct obd_device *obd, char *logname,
>  	struct config_llog_data *cld;
>  	struct config_llog_data *sptlrpc_cld;
>  	struct config_llog_data *params_cld;
> -	bool locked = false;
> +	struct config_llog_data *recover_cld = NULL;
>  	char			seclogname[32];
>  	char			*ptr;
>  	int			rc;
> @@ -333,20 +333,14 @@ config_log_add(struct obd_device *obd, char *logname,
>  		goto out_params;
>  	}
>  
> -	cld->cld_sptlrpc = sptlrpc_cld;
> -	cld->cld_params = params_cld;
> -
>  	LASSERT(lsi->lsi_lmd);
>  	if (!(lsi->lsi_lmd->lmd_flags & LMD_FLG_NOIR)) {
> -		struct config_llog_data *recover_cld;
> -
>  		ptr = strrchr(seclogname, '-');
>  		if (ptr) {
>  			*ptr = 0;
>  		} else {
>  			CERROR("%s: sptlrpc log name not correct, %s: rc = %d\n",
>  			       obd->obd_name, seclogname, -EINVAL);
> -			config_log_put(cld);
>  			rc = -EINVAL;
>  			goto out_cld;
>  		}
> @@ -355,14 +349,10 @@ config_log_add(struct obd_device *obd, char *logname,
>  			rc = PTR_ERR(recover_cld);
>  			goto out_cld;
>  		}
> -
> -		mutex_lock(&cld->cld_lock);
> -		locked = true;
> -		cld->cld_recover = recover_cld;
>  	}
>  
> -	if (!locked)
> -		mutex_lock(&cld->cld_lock);
> +	mutex_lock(&cld->cld_lock);
> +	cld->cld_recover = recover_cld;
>  	cld->cld_params = params_cld;
>  	cld->cld_sptlrpc = sptlrpc_cld;
>  	mutex_unlock(&cld->cld_lock);
> -- 
> 2.7.4

Reviewed-by: James Simmons <jsimmons@infradead.org>
