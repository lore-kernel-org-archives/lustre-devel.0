From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Sat, 5 Mar 2016 02:55:55 +0000
Subject: [lustre-devel] [PATCH 07/10] staging: lustre: add last missing
 sparse annotation __user
In-Reply-To: <1457143790-19422-8-git-send-email-jsimmons@infradead.org>
References: <1457143790-19422-1-git-send-email-jsimmons@infradead.org>
	<1457143790-19422-8-git-send-email-jsimmons@infradead.org>
Message-ID: <1D5C2B0A-E454-44BD-BC8B-2D1CC6058C9D@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "<devel@driverdev.osuosl.org>" <devel@driverdev.osuosl.org>, "Dilger, Andreas" <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Frank Zago <fzago@cray.com>


On Mar 4, 2016, at 9:09 PM, James Simmons wrote:

> From: Frank Zago <fzago@cray.com>
> 
> One of the __user was missed in being applied to upstream
> client. This is broken out of patch 11819.

It was not, the bug was fixed in another way.

> Signed-off-by: Frank Zago <fzago@cray.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5396
> Reviewed-on: http://review.whamcloud.com/11819
> Reviewed-by: James Simmons <uja.ornl@gmail.com>
> Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> ---
> drivers/staging/lustre/lnet/lnet/api-ni.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index a666d49..7395985 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -2041,7 +2041,7 @@ LNetCtl(unsigned int cmd, void *arg)
> 		id.nid = data->ioc_nid;
> 		id.pid = data->ioc_u32[0];
> 		rc = lnet_ping(id, data->ioc_u32[1], /* timeout */
> -			       data->ioc_pbuf1,
> +			       (lnet_process_id_t __user *)data->ioc_pbuf1,

We do not need this one anymore, since ioc_pbuf1 is defned as user now:
drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h:     void __user *ioc_pbuf1;

> 			       data->ioc_plen1 / sizeof(lnet_process_id_t));
> 		if (rc < 0)
> 			return rc;
> -- 
> 1.7.1
> 
