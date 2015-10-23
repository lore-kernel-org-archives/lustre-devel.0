From: Julia Lawall <julia.lawall@lip6.fr>
Date: Fri, 23 Oct 2015 11:59:41 +0200 (CEST)
Subject: [lustre-devel] [Outreachy kernel] [PATCH] Staging: lustre:
 obdclass: Remove unused header files
In-Reply-To: <1445594277-14421-1-git-send-email-shraddha.6596@gmail.com>
References: <1445594277-14421-1-git-send-email-shraddha.6596@gmail.com>
Message-ID: <alpine.DEB.2.10.1510231158450.2437@hadrien>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



On Fri, 23 Oct 2015, Shraddha Barke wrote:

> Remove unused header files that are already included in 'lu_object.h'
> and 'obd.h'
>
> Signed-off-by: Shraddha Barke <shraddha.6596@gmail.com>
> ---
>  drivers/staging/lustre/lustre/obdclass/lu_object.c | 1 -
>  drivers/staging/lustre/lustre/obdclass/lu_ref.c    | 1 -
>  2 files changed, 2 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> index 0d15bd5..549df95 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> @@ -55,7 +55,6 @@
>  #include "../include/lustre_disk.h"
>  #include "../include/lustre_fid.h"
>  #include "../include/lu_object.h"
> -#include "../include/lu_ref.h"

If things from lu_ref.h are directly referred to in the .c file, it may be
better to keep the include, rather than relying on some other include file
(that could change in the future) to include it.

julia

>  #include <linux/list.h>
>
>  static void lu_object_free(const struct lu_env *env, struct lu_object *o);
> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_ref.c b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
> index 993697b..df2d8b9 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lu_ref.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
> @@ -47,4 +47,3 @@
>  #include "../include/obd.h"
>  #include "../include/obd_class.h"
>  #include "../include/obd_support.h"
> -#include "../include/lu_ref.h"
> --
> 2.1.4
>
> --
> You received this message because you are subscribed to the Google Groups "outreachy-kernel" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to outreachy-kernel+unsubscribe at googlegroups.com.
> To post to this group, send email to outreachy-kernel at googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/outreachy-kernel/1445594277-14421-1-git-send-email-shraddha.6596%40gmail.com.
> For more options, visit https://groups.google.com/d/optout.
>
