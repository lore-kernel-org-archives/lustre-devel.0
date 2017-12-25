From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 25 Dec 2017 06:58:04 +0000
Subject: [lustre-devel] [PATCH v4] staging: lustre: Replace 'uint32_t'
 with 'u32' and 'uint64_t' with 'u64'
In-Reply-To: <20171219175654.GA13794@home>
References: <20171219175654.GA13794@home>
Message-ID: <42FB61E1-3C0B-44C8-999E-7FE17F55D821@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Dec 19, 2017, at 10:56, Roman Storozhenko <romeusmeister@gmail.com> wrote:
> 
> There are two reasons for replacing 'uint32_t' with 'u32'
> and 'uint64_t' with 'u64':
> 
> 1) As Linus Torvalds have said we should use kernel types:
> http://lkml.iu.edu/hypermail//linux/kernel/1506.0/00160.html
> 
> 2) There are only few places in the lustre codebase that use such types.
> In the most cases it uses 'u32' and 'u64'.
> 
> Signed-off-by: Roman Storozhenko <romeusmeister@gmail.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> 
> ---
> In the third version of that patch Dan Carpenter pointed out that the patch
> body should be self-explanatory:
> "
>> There are two reasons for that:
> What I'm asking is there are two reasons for what?  Where is the first
> part of that paragraph?
> "
> 
> In the second version of this patch I forgot to add subsystem and
> driver. As Greg K-H mentioned:
> "Please fix up the subject to have the subsystem and driver name in it:
>        Subject: [PATCH] staging: lustre: ..."
> 
> In the first version of this patch I replaced 'uint32_t' with '__u32' and
> 'uint64_t' with '__u64'. I was suggested to fix that by Greg K-H:
> 
> "The __ types are only needed for when you cross the user/kernel boundry.
> Otherwise just use the "normal" types of u32 and u64.
> 
> Do the changes you made here all cross that boundry?  If not, please fix
> this up."
> 
> I asked lustre community whether those code used only in the kernel
> space and Andreas Dilger said:
> 
> "These headers are for kernel code only, so should use the "u32" and
> similar
> types, rather than the "__u32" that are used for user-kernel
> structures."
> 
> So I have replaced my first patch version with this one.
> 
> drivers/staging/lustre/lustre/include/lustre_sec.h |  4 ++--
> drivers/staging/lustre/lustre/llite/vvp_dev.c      |  2 +-
> drivers/staging/lustre/lustre/lov/lov_internal.h   | 12 ++++++------
> drivers/staging/lustre/lustre/osc/osc_internal.h   |  6 +++---
> 4 files changed, 12 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
> index a40f706..64b6fd4 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_sec.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_sec.h
> @@ -341,8 +341,8 @@ void sptlrpc_conf_client_adapt(struct obd_device *obd);
> #define SPTLRPC_MAX_PAYLOAD     (1024)
> 
> struct vfs_cred {
> -	uint32_t	vc_uid;
> -	uint32_t	vc_gid;
> +	u32	vc_uid;
> +	u32	vc_gid;
> };
> 
> struct ptlrpc_ctx_ops {
> diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
> index 8ccc8b7..987c03b 100644
> --- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
> +++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
> @@ -384,7 +384,7 @@ int cl_sb_fini(struct super_block *sb)
> struct vvp_pgcache_id {
> 	unsigned int		 vpi_bucket;
> 	unsigned int		 vpi_depth;
> -	uint32_t		 vpi_index;
> +	u32			 vpi_index;
> 
> 	unsigned int		 vpi_curdep;
> 	struct lu_object_header *vpi_obj;
> diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
> index ae28ddf..a56d71c 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_internal.h
> +++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
> @@ -115,19 +115,19 @@ static inline const struct lsm_operations *lsm_op_find(int magic)
>  */
> #if BITS_PER_LONG == 64
> # define lov_do_div64(n, base) ({					\
> -	uint64_t __base = (base);					\
> -	uint64_t __rem;							\
> -	__rem = ((uint64_t)(n)) % __base;				\
> -	(n) = ((uint64_t)(n)) / __base;					\
> +	u64 __base = (base);					\
> +	u64 __rem;							\
> +	__rem = ((u64)(n)) % __base;				\
> +	(n) = ((u64)(n)) / __base;					\
> 	__rem;								\
> })
> #elif BITS_PER_LONG == 32
> # define lov_do_div64(n, base) ({					\
> -	uint64_t __rem;							\
> +	u64 __rem;							\
> 	if ((sizeof(base) > 4) && (((base) & 0xffffffff00000000ULL) != 0)) {  \
> 		int __remainder;					      \
> 		LASSERTF(!((base) & (LOV_MIN_STRIPE_SIZE - 1)), "64 bit lov " \
> -			 "division %llu / %llu\n", (n), (uint64_t)(base));    \
> +			 "division %llu / %llu\n", (n), (u64)(base));    \
> 		__remainder = (n) & (LOV_MIN_STRIPE_SIZE - 1);		\
> 		(n) >>= LOV_MIN_STRIPE_BITS;				\
> 		__rem = do_div(n, (base) >> LOV_MIN_STRIPE_BITS);	\
> diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
> index feda61b..32db150 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_internal.h
> +++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
> @@ -168,9 +168,9 @@ struct osc_device {
> 
> 	/* Write stats is actually protected by client_obd's lock. */
> 	struct osc_stats {
> -		uint64_t     os_lockless_writes;	  /* by bytes */
> -		uint64_t     os_lockless_reads;	   /* by bytes */
> -		uint64_t     os_lockless_truncates;       /* by times */
> +		u64	os_lockless_writes;	  /* by bytes */
> +		u64	os_lockless_reads;	  /* by bytes */
> +		u64	os_lockless_truncates;    /* by times */
> 	} od_stats;
> 
> 	/* configuration item(s) */
> -- 
> 2.7.4
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
