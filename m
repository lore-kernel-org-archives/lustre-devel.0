From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Dec 2017 11:00:45 +1100
Subject: [lustre-devel] [PATCH 07/12] staging: lustre: libcfs: simplify
 memory allocation.
In-Reply-To: <151313495497.27582.5451400666802627086.stgit@noble>
References: <151313493380.27582.16490205348451477393.stgit@noble>
 <151313495497.27582.5451400666802627086.stgit@noble>
Message-ID: <87d13inpoy.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Wed, Dec 13 2017, NeilBrown wrote:

> 1/ Use kvmalloc() instead of kmalloc or vmalloc
> 2/ Discard the _GFP() interfaces that are never used.
>   We only ever do GFP_NOFS and GFP_ATOMIC allocations,
>   so support each of those explicitly.

Hi,
 I just remembered that posting this patch was, maybe, a little premature.
vmalloc() doesn't support GFP_NOFS, so kvmalloc() warns about an attempt
to use GFP_NOFS.
lustre potentially used vmalloc in GFP_NOFS context, and so now calls
kvmalloc() with GFP_NOFS, which triggers a warning.

I haven't yet looking into how to remove the warning.  Maybe all
GFP_NOFS usages should use kmalloc(), not kvmalloc(), and accept the
increased chance of failure.
I'll dig deeper and hope to have a clearer opinion soon.

As it is only a warning, it is probably OK to keep the patch in
staging-next, but I wouldn't object if it was dropped.

Thanks,
NeilBrown

 

>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../lustre/include/linux/libcfs/libcfs_private.h   |   42 ++++++--------------
>  1 file changed, 12 insertions(+), 30 deletions(-)
>
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> index 2f4ff595fac9..c874f9d15c72 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> @@ -84,14 +84,6 @@ do {								    \
>  	lbug_with_loc(&msgdata);					\
>  } while (0)
>  
> -#ifndef LIBCFS_VMALLOC_SIZE
> -#define LIBCFS_VMALLOC_SIZE	(2 << PAGE_SHIFT) /* 2 pages */
> -#endif
> -
> -#define LIBCFS_ALLOC_PRE(size, mask)					\
> -	LASSERT(!in_interrupt() || ((size) <= LIBCFS_VMALLOC_SIZE &&	\
> -				    !gfpflags_allow_blocking(mask)))
> -
>  #define LIBCFS_ALLOC_POST(ptr, size)					    \
>  do {									    \
>  	if (unlikely(!(ptr))) {						    \
> @@ -103,46 +95,36 @@ do {									    \
>  } while (0)
>  
>  /**
> - * allocate memory with GFP flags @mask
> + * default allocator
>   */
> -#define LIBCFS_ALLOC_GFP(ptr, size, mask)				    \
> +#define LIBCFS_ALLOC(ptr, size)						    \
>  do {									    \
> -	LIBCFS_ALLOC_PRE((size), (mask));				    \
> -	(ptr) = (size) <= LIBCFS_VMALLOC_SIZE ?				    \
> -		kmalloc((size), (mask)) : vmalloc(size);	    \
> +	LASSERT(!in_interrupt());					    \
> +	(ptr) = kvmalloc((size), GFP_NOFS);				    \
>  	LIBCFS_ALLOC_POST((ptr), (size));				    \
>  } while (0)
>  
> -/**
> - * default allocator
> - */
> -#define LIBCFS_ALLOC(ptr, size) \
> -	LIBCFS_ALLOC_GFP(ptr, size, GFP_NOFS)
> -
>  /**
>   * non-sleeping allocator
>   */
> -#define LIBCFS_ALLOC_ATOMIC(ptr, size) \
> -	LIBCFS_ALLOC_GFP(ptr, size, GFP_ATOMIC)
> +#define LIBCFS_ALLOC_ATOMIC(ptr, size)					\
> +do {									\
> +	(ptr) = kmalloc((size), GFP_ATOMIC);				\
> +	LIBCFS_ALLOC_POST(ptr, size);					\
> +} while (0)
>  
>  /**
>   * allocate memory for specified CPU partition
>   *   \a cptab != NULL, \a cpt is CPU partition id of \a cptab
>   *   \a cptab == NULL, \a cpt is HW NUMA node id
>   */
> -#define LIBCFS_CPT_ALLOC_GFP(ptr, cptab, cpt, size, mask)		    \
> +#define LIBCFS_CPT_ALLOC(ptr, cptab, cpt, size)				    \
>  do {									    \
> -	LIBCFS_ALLOC_PRE((size), (mask));				    \
> -	(ptr) = (size) <= LIBCFS_VMALLOC_SIZE ?				    \
> -		kmalloc_node((size), (mask), cfs_cpt_spread_node(cptab, cpt)) :\
> -		vmalloc_node(size, cfs_cpt_spread_node(cptab, cpt));	    \
> +	LASSERT(!in_interrupt());					    \
> +	(ptr) = kvmalloc_node((size), GFP_NOFS, cfs_cpt_spread_node(cptab, cpt)); \
>  	LIBCFS_ALLOC_POST((ptr), (size));				    \
>  } while (0)
>  
> -/** default numa allocator */
> -#define LIBCFS_CPT_ALLOC(ptr, cptab, cpt, size)				    \
> -	LIBCFS_CPT_ALLOC_GFP(ptr, cptab, cpt, size, GFP_NOFS)
> -
>  #define LIBCFS_FREE(ptr, size)					  \
>  do {								    \
>  	if (unlikely(!(ptr))) {						\
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20171214/896f674f/attachment.sig>
