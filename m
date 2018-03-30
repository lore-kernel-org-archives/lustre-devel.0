From: James Simmons <jsimmons@infradead.org>
Date: Fri, 30 Mar 2018 19:57:54 +0100 (BST)
Subject: [lustre-devel] [PATCH 05/17] staging: lustre: remove unneeded
 include.
In-Reply-To: <152229760838.27689.7863544405084944270.stgit@noble>
References: <152229732768.27689.4800156943561963977.stgit@noble>
 <152229760838.27689.7863544405084944270.stgit@noble>
Message-ID: <alpine.LFD.2.21.1803301957470.9681@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> cfs_hash usage was removed from cl_object.c
> some time ago, so remove the #include as well.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/obdclass/cl_object.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
> index 7809f6ae1809..f1641645acae 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
> @@ -53,7 +53,6 @@
>  #include <obd_support.h>
>  #include <lustre_fid.h>
>  #include <linux/list.h>
> -#include <linux/libcfs/libcfs_hash.h>	/* for cfs_hash stuff */
>  #include <cl_object.h>
>  #include <lu_object.h>
>  #include "cl_internal.h"
> 
> 
> 
