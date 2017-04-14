From: Greg KH <gregkh@linuxfoundation.org>
Date: Fri, 14 Apr 2017 10:15:05 +0200
Subject: [lustre-devel] [PATCH RESEND v2] Staging: lustre cleanup macros
 in libcfs_private.h
In-Reply-To: <20170413092441.GA22444@starbase.xayto.local>
References: <20170413092441.GA22444@starbase.xayto.local>
Message-ID: <20170414081505.GA16598@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Craig Inches <Craig@craiginches.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, john.hammond@intel.com, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Thu, Apr 13, 2017 at 10:24:41AM +0100, Craig Inches wrote:
> This resolves a checkpatch warning that "Single statement macros should
> not use a do {} while (0) loop" by removing the loop and adjusting line
> length accordingly.
> 
> Signed-off-by: Craig Inches <Craig@craiginches.com>
> ---
> Changes in v2:
>     - Kept statements together
>     - Kept operator on previous line

Why RESEND?

> 
>  .../lustre/include/linux/libcfs/libcfs_private.h   | 51 +++++++---------------
>  1 file changed, 15 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> index 2dae857..e774c75 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> @@ -87,12 +87,9 @@ do {								    \
>  #define LIBCFS_VMALLOC_SIZE	(2 << PAGE_SHIFT) /* 2 pages */
>  #endif
>  
> -#define LIBCFS_ALLOC_PRE(size, mask)					    \
> -do {									    \
> -	LASSERT(!in_interrupt() ||					    \
> -		((size) <= LIBCFS_VMALLOC_SIZE &&			    \
> -		 !gfpflags_allow_blocking(mask)));			    \
> -} while (0)
> +#define LIBCFS_ALLOC_PRE(size, mask)					\
> +	LASSERT(!in_interrupt() || ((size) <= LIBCFS_VMALLOC_SIZE &&	\
> +				    !gfpflags_allow_blocking(mask)))
>  
>  #define LIBCFS_ALLOC_POST(ptr, size)					    \
>  do {									    \
> @@ -187,46 +184,28 @@ void  cfs_array_free(void *vars);
>  #if LASSERT_ATOMIC_ENABLED
>  
>  /** assert value of @a is equal to @v */
> -#define LASSERT_ATOMIC_EQ(a, v)				 \
> -do {							    \
> -	LASSERTF(atomic_read(a) == v,		       \
> -		 "value: %d\n", atomic_read((a)));	  \
> -} while (0)
> +#define LASSERT_ATOMIC_EQ(a, v)			\
> +	LASSERTF(atomic_read(a) == v, "value: %d\n", atomic_read((a)))
>  
>  /** assert value of @a is unequal to @v */
> -#define LASSERT_ATOMIC_NE(a, v)				 \
> -do {							    \
> -	LASSERTF(atomic_read(a) != v,		       \
> -		 "value: %d\n", atomic_read((a)));	  \
> -} while (0)
> +#define LASSERT_ATOMIC_NE(a, v)		\
> +	LASSERTF(atomic_read(a) != v, "value: %d\n", atomic_read((a)))
>  
>  /** assert value of @a is little than @v */
> -#define LASSERT_ATOMIC_LT(a, v)				 \
> -do {							    \
> -	LASSERTF(atomic_read(a) < v,			\
> -		 "value: %d\n", atomic_read((a)));	  \
> -} while (0)
> +#define LASSERT_ATOMIC_LT(a, v)		\
> +	LASSERTF(atomic_read(a) < v, "value: %d\n", atomic_read((a)))
>  
>  /** assert value of @a is little/equal to @v */
> -#define LASSERT_ATOMIC_LE(a, v)				 \
> -do {							    \
> -	LASSERTF(atomic_read(a) <= v,		       \
> -		 "value: %d\n", atomic_read((a)));	  \
> -} while (0)
> +#define LASSERT_ATOMIC_LE(a, v)		\
> +	LASSERTF(atomic_read(a) <= v, "value: %d\n", atomic_read((a)))
>  
>  /** assert value of @a is great than @v */
> -#define LASSERT_ATOMIC_GT(a, v)				 \
> -do {							    \
> -	LASSERTF(atomic_read(a) > v,			\
> -		 "value: %d\n", atomic_read((a)));	  \
> -} while (0)
> +#define LASSERT_ATOMIC_GT(a, v)		\
> +	LASSERTF(atomic_read(a) > v, "value: %d\n", atomic_read((a)))
>  
>  /** assert value of @a is great/equal to @v */
> -#define LASSERT_ATOMIC_GE(a, v)				 \
> -do {							    \
> -	LASSERTF(atomic_read(a) >= v,		       \
> -		 "value: %d\n", atomic_read((a)));	  \
> -} while (0)
> +#define LASSERT_ATOMIC_GE(a, v)		\
> +	LASSERTF(atomic_read(a) >= v, "value: %d\n", atomic_read((a)))
>  
>  /** assert value of @a is great than @v1 and little than @v2 */
>  #define LASSERT_ATOMIC_GT_LT(a, v1, v2)			 \

I need a lustre maintainer to ack this one before I can take it.
Perhaps there was a good reasaon do { } while is used here...

thanks,

greg k-h
