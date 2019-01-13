From: Andreas Dilger <adilger@whamcloud.com>
Date: Sun, 13 Jan 2019 20:40:26 +0000
Subject: [lustre-devel] [PATCH 1/4] lustre: osc: change some foo0() to
 __foo()
In-Reply-To: <154716484583.28978.14863799416083470252.stgit@noble>
References: <154716475327.28978.3817067697027604609.stgit@noble>
 <154716484583.28978.14863799416083470252.stgit@noble>
Message-ID: <31E3F1E2-37ED-4BCA-85ED-D210DC1BAF21@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 10, 2019, at 16:00, NeilBrown <neilb@suse.com> wrote:
> 
> It is standard practice in Linux, when naming a
> helper-function which is not meant to be called directly,
> to use a name starting __.
> e.g. foo() and foo_too() might call __foo(), which is otherwise
> not directly called.
> Lustre has a similar convention, but instead uses names like foo0().
> 
> This patch convert
> osc_extent_tree_dump0 -> __osc_extent_tree_dump
> osc_extent_sanity_check0 -> __osc_extent_sanity_check
> osc_io_unplug0 -> __osc_io_unplug
> osc_dlm_blocking_ast0 -> __osc_dlm_blocking_ast
> 
> Suggested-by: Andreas Dilger <adilger@whamcloud.com>
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

> ---
> drivers/staging/lustre/lustre/osc/osc_cache.c |   44 +++++++++++++------------
> drivers/staging/lustre/lustre/osc/osc_lock.c  |    8 ++---
> 2 files changed, 26 insertions(+), 26 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index 1ce9f673f1bf..57046d355eda 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -57,10 +57,10 @@ static int osc_io_unplug_async(const struct lu_env *env,
> static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
> 			   unsigned int lost_grant, unsigned int dirty_grant);
> 
> -static void osc_extent_tree_dump0(int level, struct osc_object *obj,
> -				  const char *func, int line);
> +static void __osc_extent_tree_dump(int level, struct osc_object *obj,
> +				   const char *func, int line);
> #define osc_extent_tree_dump(lvl, obj) \
> -	osc_extent_tree_dump0(lvl, obj, __func__, __LINE__)
> +	__osc_extent_tree_dump(lvl, obj, __func__, __LINE__)
> 
> static void osc_unreserve_grant(struct client_obd *cli, unsigned int reserved,
> 				unsigned int unused);
> @@ -173,8 +173,8 @@ static inline struct osc_extent *first_extent(struct osc_object *obj)
> }
> 
> /* object must be locked by caller. */
> -static int osc_extent_sanity_check0(struct osc_extent *ext,
> -				    const char *func, const int line)
> +static int __osc_extent_sanity_check(struct osc_extent *ext,
> +				     const char *func, const int line)
> {
> 	struct osc_object *obj = ext->oe_obj;
> 	struct osc_async_page *oap;
> @@ -302,13 +302,13 @@ static int osc_extent_sanity_check0(struct osc_extent *ext,
> 	return rc;
> }
> 
> -#define sanity_check_nolock(ext) \
> -	osc_extent_sanity_check0(ext, __func__, __LINE__)
> +#define osc_extent_sanity_check_nolock(ext) \
> +	__osc_extent_sanity_check(ext, __func__, __LINE__)
> 
> -#define sanity_check(ext) ({						\
> +#define osc_extent_sanity_check(ext) ({					\
> 	int __res;							\
> 	osc_object_lock((ext)->oe_obj);					\
> -	__res = sanity_check_nolock(ext);				\
> +	__res = osc_extent_sanity_check_nolock(ext);			\
> 	osc_object_unlock((ext)->oe_obj);				\
> 	__res;								\
> })
> @@ -342,7 +342,7 @@ static void osc_extent_state_set(struct osc_extent *ext, int state)
> 	LASSERT(state >= OES_INV && state < OES_STATE_MAX);
> 
> 	/* Never try to sanity check a state changing extent :-) */
> -	/* LASSERT(sanity_check_nolock(ext) == 0); */
> +	/* LASSERT(osc_extent_sanity_check_nolock(ext) == 0); */
> 
> 	/* TODO: validate the state machine */
> 	ext->oe_state = state;
> @@ -600,7 +600,7 @@ void osc_extent_release(const struct lu_env *env, struct osc_extent *ext)
> 	struct client_obd *cli = osc_cli(obj);
> 
> 	LASSERT(atomic_read(&ext->oe_users) > 0);
> -	LASSERT(sanity_check(ext) == 0);
> +	LASSERT(osc_extent_sanity_check(ext) == 0);
> 	LASSERT(ext->oe_grants > 0);
> 
> 	if (atomic_dec_and_lock(&ext->oe_users, &obj->oo_lock)) {
> @@ -729,7 +729,7 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
> 		pgoff_t ext_chk_start = ext->oe_start >> ppc_bits;
> 		pgoff_t ext_chk_end = ext->oe_end >> ppc_bits;
> 
> -		LASSERT(sanity_check_nolock(ext) == 0);
> +		LASSERT(osc_extent_sanity_check_nolock(ext) == 0);
> 		if (chunk > ext_chk_end + 1)
> 			break;
> 
> @@ -969,7 +969,7 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
> 	int rc = 0;
> 
> 	osc_object_lock(obj);
> -	LASSERT(sanity_check_nolock(ext) == 0);
> +	LASSERT(osc_extent_sanity_check_nolock(ext) == 0);
> 	/* `Kick' this extent only if the caller is waiting for it to be
> 	 * written out.
> 	 */
> @@ -1025,7 +1025,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
> 	int rc = 0;
> 	u16 refcheck;
> 
> -	LASSERT(sanity_check(ext) == 0);
> +	LASSERT(osc_extent_sanity_check(ext) == 0);
> 	EASSERT(ext->oe_state == OES_TRUNC, ext);
> 	EASSERT(!ext->oe_urgent, ext);
> 
> @@ -1141,7 +1141,7 @@ static int osc_extent_make_ready(const struct lu_env *env,
> 	int rc;
> 
> 	/* we're going to grab page lock, so object lock must not be taken. */
> -	LASSERT(sanity_check(ext) == 0);
> +	LASSERT(osc_extent_sanity_check(ext) == 0);
> 	/* in locking state, any process should not touch this extent. */
> 	EASSERT(ext->oe_state == OES_LOCKING, ext);
> 	EASSERT(ext->oe_owner, ext);
> @@ -1229,7 +1229,7 @@ static int osc_extent_expand(struct osc_extent *ext, pgoff_t index,
> 
> 	LASSERT(ext->oe_max_end >= index && ext->oe_start <= index);
> 	osc_object_lock(obj);
> -	LASSERT(sanity_check_nolock(ext) == 0);
> +	LASSERT(osc_extent_sanity_check_nolock(ext) == 0);
> 	end_chunk = ext->oe_end >> ppc_bits;
> 	if (chunk > end_chunk + 1) {
> 		rc = -ERANGE;
> @@ -1273,8 +1273,8 @@ static int osc_extent_expand(struct osc_extent *ext, pgoff_t index,
> 	return rc;
> }
> 
> -static void osc_extent_tree_dump0(int level, struct osc_object *obj,
> -				  const char *func, int line)
> +static void __osc_extent_tree_dump(int level, struct osc_object *obj,
> +				   const char *func, int line)
> {
> 	struct osc_extent *ext;
> 	int cnt;
> @@ -2355,8 +2355,8 @@ static void osc_check_rpcs(const struct lu_env *env, struct client_obd *cli)
> 	}
> }
> 
> -static int osc_io_unplug0(const struct lu_env *env, struct client_obd *cli,
> -			  struct osc_object *osc, int async)
> +static int __osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
> +			   struct osc_object *osc, int async)
> {
> 	int rc = 0;
> 
> @@ -2378,13 +2378,13 @@ static int osc_io_unplug0(const struct lu_env *env, struct client_obd *cli,
> static int osc_io_unplug_async(const struct lu_env *env,
> 			       struct client_obd *cli, struct osc_object *osc)
> {
> -	return osc_io_unplug0(env, cli, osc, 1);
> +	return __osc_io_unplug(env, cli, osc, 1);
> }
> 
> void osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
> 		   struct osc_object *osc)
> {
> -	(void)osc_io_unplug0(env, cli, osc, 0);
> +	(void)__osc_io_unplug(env, cli, osc, 0);
> }
> 
> int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
> diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
> index 824c655b4ce0..01b6bf7df3b7 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_lock.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
> @@ -413,9 +413,9 @@ static int osc_lock_flush(struct osc_object *obj, pgoff_t start, pgoff_t end,
>  * Helper for osc_dlm_blocking_ast() handling discrepancies between cl_lock
>  * and ldlm_lock caches.
>  */
> -static int osc_dlm_blocking_ast0(const struct lu_env *env,
> -				 struct ldlm_lock *dlmlock,
> -				 void *data, int flag)
> +static int __osc_dlm_blocking_ast(const struct lu_env *env,
> +				  struct ldlm_lock *dlmlock,
> +				  void *data, int flag)
> {
> 	enum cl_lock_mode mode = CLM_READ;
> 	struct cl_object *obj = NULL;
> @@ -556,7 +556,7 @@ static int osc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
> 			break;
> 		}
> 
> -		result = osc_dlm_blocking_ast0(env, dlmlock, data, flag);
> +		result = __osc_dlm_blocking_ast(env, dlmlock, data, flag);
> 		cl_env_put(env, &refcheck);
> 		break;
> 		}
> 
> 

Cheers, Andreas
---
Andreas Dilger
CTO Whamcloud
