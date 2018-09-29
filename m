From: James Simmons <jsimmons@infradead.org>
Date: Sat, 29 Sep 2018 22:05:34 +0100 (BST)
Subject: [lustre-devel] [PATCH 11/34] LU-7734 lnet: configure local NI
 from DLC
In-Reply-To: <153783763527.32103.6166409833321456335.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
 <153783763527.32103.6166409833321456335.stgit@noble>
Message-ID: <alpine.LFD.2.21.1809292150580.25547@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Amir Shehata <amir.shehata@intel.com>
> 
> This patch adds the ability to configure multiple network interfaces
> on the same network. This can be done via the lnetctl CLI interface
> or through a YAML configuration. Refer to the multi-rail HLD for
> more details on the syntax.
> 
> It also deprecates ip2nets kernel parsing. All string parsing and
> network maching now happens in the DLC userspace library.
> 
> New IOCTLs are added for adding/deleting local NIs, to keep backwards
> compatibility with older version of the DLC and lnetctl.
> 
> The changes also include parsing and matching ip2nets syntax at the
> user level and then passing down the network interfaces down to the
> kernel to be configured.

Nak. This patch introduces a regression in lnet_ioctl() found in
module.c
 
> Signed-off-by: Amir Shehata <amir.shehata@intel.com>
> Change-Id: I19ee7dc76514beb6f34de6517d19654d6468bcec
> Reviewed-on: http://review.whamcloud.com/18886
> Tested-by: Maloo <hpdd-maloo@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../lustre/include/linux/libcfs/libcfs_string.h    |   12 -
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |   13 -
>  .../lustre/include/uapi/linux/lnet/libcfs_ioctl.h  |    6 
>  .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |   57 ++
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    3 
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |  479 +++++++++++++++++---
>  drivers/staging/lustre/lnet/lnet/config.c          |  107 +++-
>  drivers/staging/lustre/lnet/lnet/module.c          |   70 ++-
>  drivers/staging/lustre/lnet/lnet/peer.c            |   21 +
>  drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    2 
>  drivers/staging/lustre/lustre/ptlrpc/service.c     |    4 
>  11 files changed, 650 insertions(+), 124 deletions(-)

.....

> diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
> index 9d06664f0c17..c82d27592391 100644
> --- a/drivers/staging/lustre/lnet/lnet/module.c
> +++ b/drivers/staging/lustre/lnet/lnet/module.c
> @@ -92,7 +92,7 @@ lnet_unconfigure(void)
>  }
>  
>  static int
> -lnet_dyn_configure(struct libcfs_ioctl_hdr *hdr)
> +lnet_dyn_configure_net(struct libcfs_ioctl_hdr *hdr)
>  {
>  	struct lnet_ioctl_config_data *conf =
>  		(struct lnet_ioctl_config_data *)hdr;
> @@ -102,19 +102,17 @@ lnet_dyn_configure(struct libcfs_ioctl_hdr *hdr)
>  		return -EINVAL;
>  
>  	mutex_lock(&lnet_config_mutex);
> -	if (!the_lnet.ln_niinit_self) {
> +	if (the_lnet.ln_niinit_self)
> +		rc = lnet_dyn_add_net(conf);
> +	else
>  		rc = -EINVAL;
> -		goto out_unlock;
> -	}
> -	rc = lnet_dyn_add_ni(LNET_PID_LUSTRE, conf);
> -out_unlock:
>  	mutex_unlock(&lnet_config_mutex);
>  
>  	return rc;
>  }
>  
>  static int
> -lnet_dyn_unconfigure(struct libcfs_ioctl_hdr *hdr)
> +lnet_dyn_unconfigure_net(struct libcfs_ioctl_hdr *hdr)
>  {
>  	struct lnet_ioctl_config_data *conf =
>  		(struct lnet_ioctl_config_data *)hdr;
> @@ -124,12 +122,50 @@ lnet_dyn_unconfigure(struct libcfs_ioctl_hdr *hdr)
>  		return -EINVAL;
>  
>  	mutex_lock(&lnet_config_mutex);
> -	if (!the_lnet.ln_niinit_self) {
> +	if (the_lnet.ln_niinit_self)
> +		rc = lnet_dyn_del_net(conf->cfg_net);
> +	else
> +		rc = -EINVAL;
> +	mutex_unlock(&lnet_config_mutex);
> +
> +	return rc;
> +}
> +
> +static int
> +lnet_dyn_configure_ni(struct libcfs_ioctl_hdr *hdr)
> +{
> +	struct lnet_ioctl_config_ni *conf =
> +		(struct lnet_ioctl_config_ni *)hdr;
> +	int rc;
> +
> +	if (conf->lic_cfg_hdr.ioc_len < sizeof(*conf))
> +		return -EINVAL;
> +
> +	mutex_lock(&lnet_config_mutex);
> +	if (the_lnet.ln_niinit_self)
> +		rc = lnet_dyn_add_ni(conf);
> +	else
> +		rc = -EINVAL;
> +	mutex_unlock(&lnet_config_mutex);
> +
> +	return rc;
> +}
> +
> +static int
> +lnet_dyn_unconfigure_ni(struct libcfs_ioctl_hdr *hdr)
> +{
> +	struct lnet_ioctl_config_ni *conf =
> +		(struct lnet_ioctl_config_ni *)hdr;
> +	int rc;
> +
> +	if (conf->lic_cfg_hdr.ioc_len < sizeof(*conf))
> +		return -EINVAL;
> +
> +	mutex_lock(&lnet_config_mutex);
> +	if (the_lnet.ln_niinit_self)
> +		rc = lnet_dyn_del_ni(conf);
> +	else
>  		rc = -EINVAL;
> -		goto out_unlock;
> -	}
> -	rc = lnet_dyn_del_ni(conf->cfg_net);
> -out_unlock:
>  	mutex_unlock(&lnet_config_mutex);
>  
>  	return rc;
> @@ -161,11 +197,17 @@ lnet_ioctl(struct notifier_block *nb,
>  		break;
>  
>  	case IOC_LIBCFS_ADD_NET:
> -		rc = lnet_dyn_configure(hdr);
> +		rc = lnet_dyn_configure_net(hdr);
>  		break;
>  
>  	case IOC_LIBCFS_DEL_NET:
> -		rc = lnet_dyn_unconfigure(hdr);
> +		rc = lnet_dyn_unconfigure_net(hdr);
> +
> +	case IOC_LIBCFS_ADD_LOCAL_NI:
> +		return lnet_dyn_configure_ni(hdr);
> +
> +	case IOC_LIBCFS_DEL_LOCAL_NI:
> +		return lnet_dyn_unconfigure_ni(hdr);
>  		break;
>  
>  	default:

While the above is mostly correct for the OpenSFS branch that is
not the case for the linux client version. The above code assumes
we are using libc_register_ioctl() but that was replace by the
block_notifier handling for ioctls instead. What we want instead is

        case IOC_LIBCFS_DEL_NET:
                rc = lnet_dyn_unconfigure_net(hdr);
                break;

        case IOC_LIBCFS_ADD_LOCAL_NI:
                rc = lnet_dyn_configure_ni(hdr);
                break;

        case IOC_LIBCFS_DEL_LOCAL_NI:
                rc = lnet_dyn_unconfigure_ni(hdr);
                break;

that way the return value is generated by notifier_from_ioctl_errno(rc).
This resolves the last bug in see in this patch set with my testing.
