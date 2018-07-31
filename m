From: NeilBrown <neilb@suse.com>
Date: Wed, 01 Aug 2018 08:41:34 +1000
Subject: [lustre-devel] [PATCH 13/31] lustre: config: don't attach sub
 logs for LWP
In-Reply-To: <1533003983-29311-14-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
 <1533003983-29311-14-git-send-email-jsimmons@infradead.org>
Message-ID: <874lgfrpsx.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 30 2018, James Simmons wrote:

> From: Niu Yawei <yawei.niu@intel.com>
>
> Lustre target processes client log to retrieve MDT NIDs and start
> LWPs, it goes the same code path of mgc_process_config() just like
> processing the target config log, so that sub clds for security,
> nodemap, param & recovery will be attached unnecessarily.
>
> The mgc subsystem is used by both server and client. This change
> allows us to cleanly handle the future case when the mgc layer
> would be built with server code. This way server specific config
> logs will only be processed when a server mount occurs.
>
> Signed-off-by: Niu Yawei <yawei.niu@intel.com>
> WC-id: https://jira.whamcloud.com/browse/LU-9081
> Reviewed-on: https://review.whamcloud.com/25293
> Reviewed-by: Fan Yong <fan.yong@intel.com>
> Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/include/obd_class.h | 19 +++++++-----
>  drivers/staging/lustre/lustre/llite/llite_lib.c   |  1 +
>  drivers/staging/lustre/lustre/mgc/mgc_request.c   | 37 +++++++++++++----------
>  3 files changed, 34 insertions(+), 23 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
> index adfe2ab..e772e3d 100644
> --- a/drivers/staging/lustre/lustre/include/obd_class.h
> +++ b/drivers/staging/lustre/lustre/include/obd_class.h
> @@ -153,17 +153,22 @@ struct config_llog_instance {
>  	llog_cb_t	    cfg_callback;
>  	int		    cfg_last_idx; /* for partial llog processing */
>  	int		    cfg_flags;
> +	u32		    cfg_sub_clds;
>  };
>  
>  int class_config_parse_llog(const struct lu_env *env, struct llog_ctxt *ctxt,
>  			    char *name, struct config_llog_instance *cfg);
> -enum {
> -	CONFIG_T_CONFIG  = 0,
> -	CONFIG_T_SPTLRPC = 1,
> -	CONFIG_T_RECOVER = 2,
> -	CONFIG_T_PARAMS  = 3,
> -	CONFIG_T_MAX     = 4
> -};
> +
> +#define CONFIG_T_CONFIG		BIT(0)
> +#define CONFIG_T_SPTLRPC	BIT(1)
> +#define CONFIG_T_RECOVER	BIT(2)
> +#define CONFIG_T_PARAMS		BIT(3)

This could still be an enum:

enum {
	CONFIG_T_CONFIG  = BIT(0),
	CONFIG_T_SPTLRPC = BIT(1),
	CONFIG_T_RECOVER = BIT(2),
	CONFIG_T_PARAMS  = BIT(3),
};

and I'm glad "CONFIG_T_MAX" is gone - as the MAX was clearly '3', not '4'.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180801/167df322/attachment.sig>
