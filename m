From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 5 Apr 2017 10:14:39 +0000
Subject: [lustre-devel] [PATCH] Staging: lustre cleanup macros in
	libcfs_private.h
In-Reply-To: <20170403211329.20264-1-Craig@craiginches.com>
References: <20170403211329.20264-1-Craig@craiginches.com>
Message-ID: <60C0D42C-256A-4883-A0AF-C7E2CFA904BD@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Craig Inches <craig@craiginches.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, "jsimmons@infradead.org" <jsimmons@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "Hammond, John" <john.hammond@intel.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Apr 3, 2017, at 15:13, Craig Inches <craig@craiginches.com> wrote:
> 
> This resolves a checkpatch warning that "Single statement macros should
> not use a do {} while (0) loop" by removing the loop and adjusting line
> length accordingly.
> 
> Signed-off-by: Craig Inches <Craig@craiginches.com>
> ---
> .../lustre/include/linux/libcfs/libcfs_private.h   | 51 +++++++---------------
> 1 file changed, 15 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> index 2dae857..150454f 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> @@ -87,12 +87,9 @@ do {								    \
> #define LIBCFS_VMALLOC_SIZE	(2 << PAGE_SHIFT) /* 2 pages */
> #endif
> 
> -#define LIBCFS_ALLOC_PRE(size, mask)					    \
> -do {									    \
> -	LASSERT(!in_interrupt() ||					    \
> -		((size) <= LIBCFS_VMALLOC_SIZE &&			    \
> -		 !gfpflags_allow_blocking(mask)));			    \
> -} while (0)
> +#define LIBCFS_ALLOC_PRE(size, mask)					\
> +	LASSERT(!in_interrupt() || ((size) <= LIBCFS_VMALLOC_SIZE	\
> +		&& !gfpflags_allow_blocking(mask)))

(style) keep operators at the end of the previous line, rather than the start
of the continued line

> 
> #define LIBCFS_ALLOC_POST(ptr, size)					    \
> do {									    \
> @@ -187,46 +184,28 @@ void  cfs_array_free(void *vars);
> #if LASSERT_ATOMIC_ENABLED
> 
> /** assert value of @a is equal to @v */
> -#define LASSERT_ATOMIC_EQ(a, v)				 \
> -do {							    \
> -	LASSERTF(atomic_read(a) == v,		       \
> -		 "value: %d\n", atomic_read((a)));	  \
> -} while (0)
> +#define LASSERT_ATOMIC_EQ(a, v) LASSERTF(atomic_read(a) == v,		\
> +					 "value: %d\n", atomic_read((a)))

Minor nit - in cases like this where you need to split the line anyway, it
is cleaner (IMHO) to keep the whole statement together:

#define LASSERT_ATOMIC_EQ(a, v)						\
	LASSERTF(atomic_read(a) == v, "value: %d\n", atomic_read((a)))

Cheers, Andreas

> 
> /** assert value of @a is unequal to @v */
> -#define LASSERT_ATOMIC_NE(a, v)				 \
> -do {							    \
> -	LASSERTF(atomic_read(a) != v,		       \
> -		 "value: %d\n", atomic_read((a)));	  \
> -} while (0)
> +#define LASSERT_ATOMIC_NE(a, v) LASSERTF(atomic_read(a) != v,		\
> +					 "value: %d\n", atomic_read((a)))
> 
> /** assert value of @a is little than @v */
> -#define LASSERT_ATOMIC_LT(a, v)				 \
> -do {							    \
> -	LASSERTF(atomic_read(a) < v,			\
> -		 "value: %d\n", atomic_read((a)));	  \
> -} while (0)
> +#define LASSERT_ATOMIC_LT(a, v) LASSERTF(atomic_read(a) < v,		\
> +					 "value: %d\n", atomic_read((a)))
> 
> /** assert value of @a is little/equal to @v */
> -#define LASSERT_ATOMIC_LE(a, v)				 \
> -do {							    \
> -	LASSERTF(atomic_read(a) <= v,		       \
> -		 "value: %d\n", atomic_read((a)));	  \
> -} while (0)
> +#define LASSERT_ATOMIC_LE(a, v) LASSERTF(atomic_read(a) <= v,		\
> +					 "value: %d\n", atomic_read((a)))
> 
> /** assert value of @a is great than @v */
> -#define LASSERT_ATOMIC_GT(a, v)				 \
> -do {							    \
> -	LASSERTF(atomic_read(a) > v,			\
> -		 "value: %d\n", atomic_read((a)));	  \
> -} while (0)
> +#define LASSERT_ATOMIC_GT(a, v) LASSERTF(atomic_read(a) > v,		\
> +					 "value: %d\n", atomic_read((a)))
> 
> /** assert value of @a is great/equal to @v */
> -#define LASSERT_ATOMIC_GE(a, v)				 \
> -do {							    \
> -	LASSERTF(atomic_read(a) >= v,		       \
> -		 "value: %d\n", atomic_read((a)));	  \
> -} while (0)
> +#define LASSERT_ATOMIC_GE(a, v) LASSERTF(atomic_read(a) >= v,		\
> +					 "value: %d\n", atomic_read((a)))
> 
> /** assert value of @a is great than @v1 and little than @v2 */
> #define LASSERT_ATOMIC_GT_LT(a, v1, v2)			 \
> -- 
> 2.10.2
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
