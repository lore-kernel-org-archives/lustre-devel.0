From: James Simmons <jsimmons@infradead.org>
Date: Thu, 8 Dec 2016 00:22:02 +0000 (GMT)
Subject: [lustre-devel] [PATCH 5/8] staging/lustre/osc: extern declare
 osc_caches in a header
In-Reply-To: <1481150494-1853127-6-git-send-email-green@linuxhacker.ru>
References: <1481150494-1853127-1-git-send-email-green@linuxhacker.ru>
	<1481150494-1853127-6-git-send-email-green@linuxhacker.ru>
Message-ID: <alpine.LFD.2.20.1612080021490.14850@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> This avoids frowned upon extern in the C file, and also
> shuts down a sparse warning of
> drivers/staging/lustre/lustre/osc/osc_dev.c:55:22: warning: symbol 'osc_caches' was not declared. Should it be static?

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
>  drivers/staging/lustre/lustre/osc/osc_internal.h | 2 ++
>  drivers/staging/lustre/lustre/osc/osc_request.c  | 2 --
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
> index 688783d..5cce82b 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_internal.h
> +++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
> @@ -181,6 +181,8 @@ static inline struct osc_device *obd2osc_dev(const struct obd_device *d)
>  	return container_of0(d->obd_lu_dev, struct osc_device, od_cl.cd_lu_dev);
>  }
>  
> +extern struct lu_kmem_descr osc_caches[];
> +
>  extern struct kmem_cache *osc_quota_kmem;
>  struct osc_quota_info {
>  	/** linkage for quota hash table */
> diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
> index 7143564..f691297 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_request.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_request.c
> @@ -2766,8 +2766,6 @@ static struct obd_ops osc_obd_ops = {
>  	.quotactl       = osc_quotactl,
>  };
>  
> -extern struct lu_kmem_descr osc_caches[];
> -
>  static int __init osc_init(void)
>  {
>  	struct lprocfs_static_vars lvars = { NULL };
> -- 
> 2.7.4
> 
> 
