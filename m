From: James Simmons <jsimmons@infradead.org>
Date: Fri, 30 Mar 2018 20:07:36 +0100 (BST)
Subject: [lustre-devel] [PATCH 17/17] staging: lustre: remove cruft from
 libcfs/linux/libcfs.h
In-Reply-To: <152229760887.27689.4035189219478811109.stgit@noble>
References: <152229732768.27689.4800156943561963977.stgit@noble>
 <152229760887.27689.4035189219478811109.stgit@noble>
Message-ID: <alpine.LFD.2.21.1803302006410.9681@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> These defines are unused or nearly unused, and do not
> help at all.

Reviewed-by: James Simmons <jsimmons@infradead.org>

> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/libcfs/curproc.h  |    2 --
>  .../lustre/include/linux/libcfs/linux/libcfs.h     |   17 -----------------
>  drivers/staging/lustre/lnet/libcfs/tracefile.c     |    2 +-
>  3 files changed, 1 insertion(+), 20 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/curproc.h b/drivers/staging/lustre/include/linux/libcfs/curproc.h
> index 4702956805a6..d6e4f47b5daf 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/curproc.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/curproc.h
> @@ -43,8 +43,6 @@
>  /*
>   * Plus, platform-specific constant
>   *
> - * CFS_CURPROC_COMM_MAX,
> - *
>   * and opaque scalar type
>   *
>   * kernel_cap_t
> diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
> index c39c34d74382..0dbd01617865 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
> @@ -81,8 +81,6 @@
>  #include <stdarg.h>
>  #include "linux-cpu.h"
>  
> -#define LUSTRE_TRACE_SIZE (THREAD_SIZE >> 5)
> -
>  #if !defined(__x86_64__)
>  # ifdef __ia64__
>  #  define CDEBUG_STACK() (THREAD_SIZE -				 \
> @@ -114,19 +112,4 @@ do {								    \
>  #define CDEBUG_STACK() (0L)
>  #endif /* __x86_64__ */
>  
> -#define __current_nesting_level() (0)
> -
> -/**
> - * Platform specific declarations for cfs_curproc API (libcfs/curproc.h)
> - *
> - * Implementation is in linux-curproc.c
> - */
> -#define CFS_CURPROC_COMM_MAX (sizeof((struct task_struct *)0)->comm)
> -
> -#include <linux/capability.h>
> -
> -#ifndef WITH_WATCHDOG
> -#define WITH_WATCHDOG
> -#endif
> -
>  #endif /* _LINUX_LIBCFS_H */
> diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
> index 129430e74d00..514e1845740e 100644
> --- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
> +++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
> @@ -328,7 +328,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
>  		goto console;
>  	}
>  
> -	depth = __current_nesting_level();
> +	depth = 0;
>  	known_size = strlen(file) + 1 + depth;
>  	if (msgdata->msg_fn)
>  		known_size += strlen(msgdata->msg_fn) + 1;
> 
> 
> 
