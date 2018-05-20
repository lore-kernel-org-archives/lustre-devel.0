From: Greg KH <gregkh@linuxfoundation.org>
Date: Sun, 20 May 2018 14:41:58 +0200
Subject: [lustre-devel] [PATCH 1/5] staging: lustre: Fix inclusion of
 local headers
In-Reply-To: <20180516182636.5137-1-sabin.rapan@gmail.com>
References: <20180516182636.5137-1-sabin.rapan@gmail.com>
Message-ID: <20180520124158.GC10031@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sabin Mihai Rapan <sabin.rapan@gmail.com>
Cc: jsimmons@infradead.org, andreas.dilger@intel.com, oleg.drokin@intel.com, lustre-devel@lists.lustre.org, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, May 16, 2018 at 08:26:36PM +0200, Sabin Mihai Rapan wrote:
> This patch fixes the checkpatch.pl error:
> 
> ERROR:UAPI_INCLUDE: No #include in ...include/uapi/... should use a uapi/ path
> prefix
> 
> Signed-off-by: Sabin Mihai Rapan <sabin.rapan@gmail.com>
> ---
>  drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h     | 4 ++--
>  drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h      | 2 +-
>  drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h       | 2 +-
>  drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h | 2 +-
>  drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h | 2 +-
>  drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h | 4 ++--
>  .../staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h   | 2 +-
>  .../staging/lustre/include/uapi/linux/lustre/lustre_ostid.h   | 2 +-
>  .../staging/lustre/include/uapi/linux/lustre/lustre_user.h    | 2 +-
>  9 files changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
> index c1619f411d81..1530ac26b449 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
> @@ -29,8 +29,8 @@
>  #ifndef LNET_DLC_H
>  #define LNET_DLC_H
>  
> -#include <uapi/linux/lnet/libcfs_ioctl.h>
> -#include <uapi/linux/lnet/lnet-types.h>
> +#include "libcfs_ioctl.h"
> +#include "lnet-types.h"

Ick, no, please leave as-is, the uapi "rules" are a bit different for
staging drivers.

thanks,

greg k-h
