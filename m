From: James Simmons <jsimmons@infradead.org>
Date: Thu, 8 Sep 2016 18:59:24 +0100 (BST)
Subject: [lustre-devel] [PATCH] staging/lustre/lov: add missing header
	dependencies
In-Reply-To: <1473324508-9294-1-git-send-email-baoyou.xie@linaro.org>
References: <1473324508-9294-1-git-send-email-baoyou.xie@linaro.org>
Message-ID: <alpine.LFD.2.20.1609081851520.14646@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Baoyou Xie <baoyou.xie@linaro.org>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, bobijam.xu@intel.com, jinshan.xiong@intel.com, lai.siyao@intel.com, mike.rapoport@gmail.com, amitoj1606@gmail.com, devel@driverdev.osuosl.org, arnd@arndb.de, xie.baoyou@zte.com.cn, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org


> We get 1 warning when building kernel with W=1:
> drivers/staging/lustre/lustre/lov/lov_object.c:956:23: warning: no previous prototype for 'lov_lsm_get' [-Wmissing-prototypes]
> drivers/staging/lustre/lustre/lov/lov_object.c:972:6: warning: no previous prototype for 'lov_lsm_put' [-Wmissing-prototypes]
> drivers/staging/lustre/lustre/lov/lov_object.c:979:5: warning: no previous prototype for 'lov_read_and_clear_async_rc' [-Wmissing-prototypes]
> 
> In fact, these functions are declared in ../llite/vvp_internal.h,
> so this patch add missing header dependencies.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Nak. The header vvp_internal.h is meant to private to the llite layer.
Looking at the coming patch updates I see lov_lsm_[put|get] will not be
used in the lov later. Now lov_read_and_clear_async is still used in
both layers. The header used for this case is cl_object.h. Might rename 
that function to be consistent with the rest of the header. I will look 
into a cleanup for this.

> ---
>  drivers/staging/lustre/lustre/lov/lov_object.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
> index f9621b0..912c416 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_object.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_object.c
> @@ -38,6 +38,7 @@
>  #define DEBUG_SUBSYSTEM S_LOV
>  
>  #include "lov_cl_internal.h"
> +#include "../llite/vvp_internal.h"
>  
>  /** \addtogroup lov
>   *  @{
> -- 
> 2.7.4
> 
> _______________________________________________
> devel mailing list
> devel at linuxdriverproject.org
> http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel
> 
