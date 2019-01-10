From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 10 Jan 2019 01:56:08 +0000
Subject: [lustre-devel] [PATCH 02/29] lustre: osc_cache: use
 assert_spin_locked()
In-Reply-To: <154701504098.26726.7180667249484886220.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
 <154701504098.26726.7180667249484886220.stgit@noble>
Message-ID: <87942812-3A47-49E3-B7C9-75DC2D426305@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 8, 2019, at 23:24, NeilBrown <neilb@suse.com> wrote:
> 
> assert_spin_locked() is preferred to
> spin_is_locked() for affirming that a
> spinlock is locked.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

We used to have an LASSERT_SPIN_LOCKED() macro, but it was removed a few
years ago.  It is nice to get better checking in the kernel.

One question inline below:

> ---
> drivers/staging/lustre/lustre/osc/osc_cache.c      |   29 +++++++++-----------
> .../staging/lustre/lustre/osc/osc_cl_internal.h    |   15 +---------
> 2 files changed, 15 insertions(+), 29 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index fbf16547003d..1ce9f673f1bf 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -181,10 +181,7 @@ static int osc_extent_sanity_check0(struct osc_extent *ext,
> 	size_t page_count;
> 	int rc = 0;
> 
> -	if (!osc_object_is_locked(obj)) {
> -		rc = 9;
> -		goto out;
> -	}
> +	assert_osc_object_is_locked(obj);

Is this actually a fatal error?  It looks like if the object is not
locked then the checking isn't consistent and could just be skipped?

There is a macro that lends credence to this:

#define sanity_check_nolock(ext) \
        osc_extent_sanity_check0(ext, __func__, __LINE__)

#define sanity_check(ext) ({                                   \
        int __res;                                             \
        osc_object_lock((ext)->oe_obj);                        \
        __res = sanity_check_nolock(ext);                      \
        osc_object_unlock((ext)->oe_obj);                      \
        __res;                                                 \
})

However, reading deeper into the code sanity_check_nolock() looks
like is only ever called when the object is already locked, so
indeed it does seem like a valid change that should be described
in the commit message like:

    __osc_extent_sanity_check() is only ever called with obj
    already locked, so change the check into an assertion.

It might also be an improvement to rename sanity_check{,_nolock}()
to osc_extent_sanity_check() and osc_extent_sanity_check_nolock(),
and use __osc_extent_sanity_check() instead of ...0() (which is not
standard)?  I was going to suggest making sanity_check() an inline
function, but that would break the __func__ and __LINE__ expansion
and isn't onerous.

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

> 
> 	if (ext->oe_state >= OES_STATE_MAX) {
> 		rc = 10;
> @@ -324,7 +321,7 @@ static int osc_extent_is_overlapped(struct osc_object *obj,
> {
> 	struct osc_extent *tmp;
> 
> -	LASSERT(osc_object_is_locked(obj));
> +	assert_osc_object_is_locked(obj);
> 
> 	if (!extent_debug)
> 		return 0;
> @@ -341,7 +338,7 @@ static int osc_extent_is_overlapped(struct osc_object *obj,
> 
> static void osc_extent_state_set(struct osc_extent *ext, int state)
> {
> -	LASSERT(osc_object_is_locked(ext->oe_obj));
> +	assert_osc_object_is_locked(ext->oe_obj);
> 	LASSERT(state >= OES_INV && state < OES_STATE_MAX);
> 
> 	/* Never try to sanity check a state changing extent :-) */
> @@ -414,7 +411,7 @@ static void osc_extent_put(const struct lu_env *env, struct osc_extent *ext)
> static void osc_extent_put_trust(struct osc_extent *ext)
> {
> 	LASSERT(atomic_read(&ext->oe_refc) > 1);
> -	LASSERT(osc_object_is_locked(ext->oe_obj));
> +	assert_osc_object_is_locked(ext->oe_obj);
> 	atomic_dec(&ext->oe_refc);
> }
> 
> @@ -428,7 +425,7 @@ static struct osc_extent *osc_extent_search(struct osc_object *obj,
> 	struct rb_node *n = obj->oo_root.rb_node;
> 	struct osc_extent *tmp, *p = NULL;
> 
> -	LASSERT(osc_object_is_locked(obj));
> +	assert_osc_object_is_locked(obj);
> 	while (n) {
> 		tmp = rb_extent(n);
> 		if (index < tmp->oe_start) {
> @@ -467,7 +464,7 @@ static void osc_extent_insert(struct osc_object *obj, struct osc_extent *ext)
> 
> 	LASSERT(RB_EMPTY_NODE(&ext->oe_node));
> 	LASSERT(ext->oe_obj == obj);
> -	LASSERT(osc_object_is_locked(obj));
> +	assert_osc_object_is_locked(obj);
> 	while (*n) {
> 		tmp = rb_extent(*n);
> 		parent = *n;
> @@ -489,7 +486,7 @@ static void osc_extent_erase(struct osc_extent *ext)
> {
> 	struct osc_object *obj = ext->oe_obj;
> 
> -	LASSERT(osc_object_is_locked(obj));
> +	assert_osc_object_is_locked(obj);
> 	if (!RB_EMPTY_NODE(&ext->oe_node)) {
> 		rb_erase(&ext->oe_node, &obj->oo_root);
> 		RB_CLEAR_NODE(&ext->oe_node);
> @@ -502,7 +499,7 @@ static struct osc_extent *osc_extent_hold(struct osc_extent *ext)
> {
> 	struct osc_object *obj = ext->oe_obj;
> 
> -	LASSERT(osc_object_is_locked(obj));
> +	assert_osc_object_is_locked(obj);
> 	LASSERT(ext->oe_state == OES_ACTIVE || ext->oe_state == OES_CACHE);
> 	if (ext->oe_state == OES_CACHE) {
> 		osc_extent_state_set(ext, OES_ACTIVE);
> @@ -515,7 +512,7 @@ static struct osc_extent *osc_extent_hold(struct osc_extent *ext)
> 
> static void __osc_extent_remove(struct osc_extent *ext)
> {
> -	LASSERT(osc_object_is_locked(ext->oe_obj));
> +	assert_osc_object_is_locked(ext->oe_obj);
> 	LASSERT(list_empty(&ext->oe_pages));
> 	osc_extent_erase(ext);
> 	list_del_init(&ext->oe_link);
> @@ -546,7 +543,7 @@ static int osc_extent_merge(const struct lu_env *env, struct osc_extent *cur,
> 	int ppc_bits;
> 
> 	LASSERT(cur->oe_state == OES_CACHE);
> -	LASSERT(osc_object_is_locked(obj));
> +	assert_osc_object_is_locked(obj);
> 	if (!victim)
> 		return -EINVAL;
> 
> @@ -2079,7 +2076,7 @@ static unsigned int get_write_extents(struct osc_object *obj,
> 		.erd_max_extents = 256,
> 	};
> 
> -	LASSERT(osc_object_is_locked(obj));
> +	assert_osc_object_is_locked(obj);
> 	while (!list_empty(&obj->oo_hp_exts)) {
> 		ext = list_entry(obj->oo_hp_exts.next, struct osc_extent,
> 				 oe_link);
> @@ -2146,7 +2143,7 @@ osc_send_write_rpc(const struct lu_env *env, struct client_obd *cli,
> 	int srvlock = 0;
> 	int rc = 0;
> 
> -	LASSERT(osc_object_is_locked(osc));
> +	assert_osc_object_is_locked(osc);
> 
> 	page_count = get_write_extents(osc, &rpclist);
> 	LASSERT(equi(page_count == 0, list_empty(&rpclist)));
> @@ -2224,7 +2221,7 @@ osc_send_read_rpc(const struct lu_env *env, struct client_obd *cli,
> 	};
> 	int rc = 0;
> 
> -	LASSERT(osc_object_is_locked(osc));
> +	assert_osc_object_is_locked(osc);
> 	list_for_each_entry_safe(ext, next, &osc->oo_reading_exts, oe_link) {
> 		EASSERT(ext->oe_state == OES_LOCK_DONE, ext);
> 		if (!try_to_add_extent_for_io(cli, ext, &data))
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
> index b78deef3963a..aa1b753fc88d 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
> +++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
> @@ -183,19 +183,8 @@ static inline void osc_object_unlock(struct osc_object *obj)
> 	spin_unlock(&obj->oo_lock);
> }
> 
> -static inline int osc_object_is_locked(struct osc_object *obj)
> -{
> -#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
> -	return spin_is_locked(&obj->oo_lock);
> -#else
> -	/*
> -	 * It is not perfect to return true all the time.
> -	 * But since this function is only used for assertion
> -	 * and checking, it seems OK.
> -	 */
> -	return 1;
> -#endif
> -}
> +#define assert_osc_object_is_locked(obj)	\
> +	assert_spin_locked(&obj->oo_lock)
> 
> /*
>  * Lock "micro-states" for osc layer.
> 
> 

Cheers, Andreas
---
Andreas Dilger
CTO Whamcloud
