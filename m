From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 2 Feb 2017 07:50:24 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: shut up clang warnings
	on CLASSERT()
In-Reply-To: <20170201165314.2588373-1-arnd@arndb.de>
References: <20170201165314.2588373-1-arnd@arndb.de>
Message-ID: <C39A7DE9-5D89-4B98-A61F-1BB766ADEFC0@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Eremin, Dmitry" <dmitry.eremin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, LKML <linux-kernel@vger.kernel.org>

On Feb 1, 2017, at 09:52, Arnd Bergmann <arnd@arndb.de> wrote:
> 
> lustre uses a fake switch() statement as a compile-time assert, but unfortunately
> each use of that causes a warning when building with clang:
> 
> drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c:2907:2: warning: no case matching constant switch condition '42'
> drivers/staging/lustre/lnet/klnds/socklnd/../../../include/linux/libcfs/libcfs_private.h:294:36: note: expanded from macro 'CLASSERT'
> #define CLASSERT(cond) do {switch (42) {case (cond): case 0: break; } } while (0)
> 
> Adding a 'default:' label in there shuts up the warning.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/include/linux/libcfs/libcfs_private.h | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> index aab15d8112a4..2d5435029185 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> @@ -291,7 +291,7 @@ do {							    \
>  *       value  after  conversion...
>  *
>  */
> -#define CLASSERT(cond) do {switch (42) {case (cond): case 0: break; } } while (0)
> +#define CLASSERT(cond) do {switch (42) {case (cond): case 0: default: break; } } while (0)
> 
> /* max value for numeric network address */
> #define MAX_NUMERIC_VALUE 0xffffffff
> -- 
> 2.9.0
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
