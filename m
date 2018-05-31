From: NeilBrown <neilb@suse.com>
Date: Thu, 31 May 2018 15:17:32 +1000
Subject: [lustre-devel] [PATCH] staging: lustre: include linux/highmem.h
 when needed
In-Reply-To: <20180530213941.772006-1-arnd@arndb.de>
References: <20180530213941.772006-1-arnd@arndb.de>
Message-ID: <874liov1xv.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Doug Oucharek <dougso@me.com>, Dmitry Eremin <dmitry.eremin@intel.com>, Ingo Molnar <mingo@kernel.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Wed, May 30 2018, Arnd Bergmann wrote:

> Something in recent linux-next kernels caused linux/highmem.h to
> no longer be included implicitly from o2iblnd_cb.c, causing a build
> failure:
>
> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c: In function 'kiblnd_kvaddr_to_page':
> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:549:15: error: 'PKMAP_BASE' undeclared (first use in this function); did you mean 'RTM_BASE'?
>   if (vaddr >= PKMAP_BASE &&
>                ^~~~~~~~~~
>                RTM_BASE
> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:549:15: note: each undeclared identifier is reported only once for each function it appears in
> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:550:28: error: 'LAST_PKMAP' undeclared (first use in this function); did you mean 'AT_HWCAP'?
>       vaddr < (PKMAP_BASE + LAST_PKMAP * PAGE_SIZE)) {
>                             ^~~~~~~~~~
>                             AT_HWCAP
>
> This adds back an explicit include for the header.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks for finding and fixing this.  I did recently reduce the number
of include files that were automatically included everywhere.  Clearly
some config combinations didn't get tested properly.

Reviewed-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown


> ---
>  drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> index 47eb8b4c28db..65b7a62943ad 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> @@ -35,6 +35,7 @@
>   * Author: Eric Barton <eric@bartonsoftware.com>
>   */
>  
> +#include <linux/highmem.h>
>  #include "o2iblnd.h"
>  
>  #define MAX_CONN_RACES_BEFORE_ABORT 20
> -- 
> 2.9.0
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180531/474c0ec7/attachment.sig>
