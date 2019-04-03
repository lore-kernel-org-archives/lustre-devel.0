From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 3 Apr 2019 20:43:38 +0000
Subject: [lustre-devel] [PATCH 28/32] lustre: don't declare extern
 variables in C files.
In-Reply-To: <155252231164.26912.14871078632567032600.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
 <155252231164.26912.14871078632567032600.stgit@noble.brown>
Message-ID: <E8286834-9920-48A2-895B-8B6365388920@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 13, 2019, at 18:11, NeilBrown <neilb@suse.com> wrote:
> 
> 'extern' declarations should only appear in .h files.
> All these names are declared in .h files as needed,
> and these duplicate declarations in .c files can
> be removed.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Totally agree on this.  It can be a source of hard-to-find bugs.

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>


> ---
> drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    2 --
> drivers/staging/lustre/lustre/ptlrpc/import.c      |    1 -
> .../staging/lustre/lustre/ptlrpc/ptlrpc_module.c   |    5 -----
> 3 files changed, 8 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> index d79f70d17220..82ec936a6e80 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> @@ -681,8 +681,6 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
> }
> EXPORT_SYMBOL(ldlm_namespace_new);
> 
> -extern struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock);
> -
> /**
>  * Cancel and destroy all locks on a resource.
>  *
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
> index b2a57d2bdde7..a6f15429eda2 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/import.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
> @@ -1558,7 +1558,6 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
> EXPORT_SYMBOL(ptlrpc_disconnect_import);
> 
> /* Adaptive Timeout utils */
> -extern unsigned int at_min, at_max, at_history;
> 
> /*
>  *Update at_current with the specified value (bounded by at_min and at_max),
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
> index 5c32b657b3b5..76018805f0ce 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
> @@ -40,11 +40,6 @@
> 
> #include "ptlrpc_internal.h"
> 
> -extern spinlock_t ptlrpc_last_xid_lock;
> -#if RS_DEBUG
> -extern spinlock_t ptlrpc_rs_debug_lock;
> -#endif
> -
> DEFINE_MUTEX(ptlrpc_startup);
> static int ptlrpc_active = 0;
> 
> 
> 

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
