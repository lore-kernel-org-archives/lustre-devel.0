From: NeilBrown <neilb@suse.com>
Date: Fri, 02 Nov 2018 13:36:43 +1100
Subject: [lustre-devel] [PATCH RFC] lustre: obd: convert obd_nid_hash to
 rhashtable
In-Reply-To: <alpine.LFD.2.21.1811011955300.11470@casper.infradead.org>
References: <alpine.LFD.2.21.1811011955300.11470@casper.infradead.org>
Message-ID: <87tvl019z8.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Nov 01 2018, James Simmons wrote:

> This patch converts the struct obd_export obd_nid_hash used by the servr
> to use rhltables. The reason is that the NID hash can have multiple obd 
> exports using the same NID key. In the process we gain lockless lookup 
> which  should improve performance. This should also address the rare 
> crashes:
>
> [<ffffffffc0913388>] ? cfs_hash_bd_from_key+0x38/0xb0 [libcfs]
> [74844.507416]  [<ffffffffc0913425>] cfs_hash_bd_get+0x25/0x70 [libcfs]
> [74844.516384]  [<ffffffffc09166d2>] cfs_hash_add+0x52/0x1a0 [libcfs]
> [74844.525211]  [<ffffffffc0d8a765>] target_handle_connect+0x1fe5/0x29b0 [ptlrpc]
>
> Pre 4.8 kernels do not support rhltables so wrappers have been created.
>
> ***
> My testing has been positive so far but I do need to figure out the 
> debugfs file mapping from the old libcfs hash to rhashtables.
>
> ***
>
> Signed-off-by: James Simmons <uja.ornl@yahoo.com>
> ---
>  libcfs/autoconf/lustre-libcfs.m4         |  21 +++
>  libcfs/include/libcfs/linux/linux-hash.h |  88 ++++++++++++
>  lustre/include/lustre_export.h           |   2 +-
>  lustre/include/obd.h                     |   8 +-
>  lustre/include/obd_support.h             |   3 -
>  lustre/ldlm/ldlm_flock.c                 |  18 ++-
>  lustre/ldlm/ldlm_lib.c                   |  14 +-
>  lustre/mdt/mdt_lproc.c                   |  21 ++-
>  lustre/obdclass/genops.c                 |  76 ++++++-----
>  lustre/obdclass/lprocfs_status_server.c  | 133 +++++++++++-------
>  lustre/obdclass/obd_config.c             | 225 ++++++++++++++++++-------------
>  11 files changed, 394 insertions(+), 215 deletions(-)
>
> diff --git a/libcfs/autoconf/lustre-libcfs.m4 b/libcfs/autoconf/lustre-libcfs.m4
> index d437331..147ecb3 100644
> --- a/libcfs/autoconf/lustre-libcfs.m4
> +++ b/libcfs/autoconf/lustre-libcfs.m4
> @@ -761,6 +761,26 @@ LB_CHECK_LINUX_HEADER([linux/stringhash.h], [
>  ]) # LIBCFS_STRINGHASH
>  
>  #
> +# LIBCFS_RHLTABLE
> +# Kernel version 4.8 commit ca26893f05e86497a86732768ec53cd38c0819ca
> +# created the rhlist interface to allow inserting duplicate objects
> +# into the same table.
> +#
> +AC_DEFUN([LIBCFS_RHLTABLE], [
> +LB_CHECK_COMPILE([if 'struct rhltable' exist],
> +rhtable, [
> +	#include <linux/rhashtable.h>
> +],[
> +	struct rhltable *hlt = NULL;
> +
> +	rhltable_destroy(hlt);
> +],[
> +	AC_DEFINE(HAVE_RHLTABLE, 1,
> +		  [struct rhltable exist])
> +])
> +]) # LIBCFS_RHLTABLE
> +
> +#
>  # LIBCFS_STACKTRACE_OPS
>  #
>  # Kernel version 4.8 commit c8fe4609827aedc9c4b45de80e7cdc8ccfa8541b
> @@ -999,6 +1019,7 @@ LIBCFS_STACKTRACE_OPS_ADDRESS_RETURN_INT
>  LIBCFS_GET_USER_PAGES_6ARG
>  LIBCFS_STRINGHASH
>  # 4.8
> +LIBCFS_RHLTABLE
>  LIBCFS_STACKTRACE_OPS
>  # 4.9
>  LIBCFS_GET_USER_PAGES_GUP_FLAGS
> diff --git a/libcfs/include/libcfs/linux/linux-hash.h b/libcfs/include/libcfs/linux/linux-hash.h
> index 1227ec8..0453cd9 100644
> --- a/libcfs/include/libcfs/linux/linux-hash.h
> +++ b/libcfs/include/libcfs/linux/linux-hash.h
> @@ -38,6 +38,94 @@ u64 cfs_hashlen_string(const void *salt, const char *name);
>  #endif
>  #endif /* !HAVE_STRINGHASH */
>  
> +#ifndef HAVE_RHLTABLE
> +struct rhlist_head {
> +	struct rhash_head		rhead;
> +	struct rhlist_head __rcu	*next;
> +};
> +
> +struct rhltable {
> +	struct rhashtable ht;
> +};
> +
> +#define rhl_for_each_entry_rcu(tpos, pos, list, member)                 \
> +	for (pos = list; pos && rht_entry(tpos, pos, member);           \
> +		pos = rcu_dereference_raw(pos->next))
> +
> +static inline int rhltable_init(struct rhltable *hlt, const struct rhashtable_params *params)
> +{
> +	return rhashtable_init(&hlt->ht, params);
> +}
> +
> +static inline struct rhlist_head *rhltable_lookup(
> +	struct rhltable *hlt, const void *key,
> +	const struct rhashtable_params params)
> +{
> +	struct rhashtable *ht = &hlt->ht;
> +	struct rhashtable_compare_arg arg = {
> +		.ht = ht,
> +		.key = key,
> +	};
> +	struct bucket_table *tbl;
> +	struct rhash_head *he;
> +	unsigned int hash;
> +
> +	tbl = rht_dereference_rcu(ht->tbl, ht);
> +restart:
> +	hash = rht_key_hashfn(ht, tbl, key, params);
> +	rht_for_each_rcu(he, tbl, hash) {
> +		if (params.obj_cmpfn ?
> +		    params.obj_cmpfn(&arg, rht_obj(ht, he)) :
> +		    rhashtable_compare(&arg, rht_obj(ht, he)))
> +			continue;
> +		return he ? container_of(he, struct rhlist_head, rhead) : NULL;
> +	}
> +
> +	/* Ensure we see any new tables. */
> +	smp_rmb();
> +
> +	tbl = rht_dereference_rcu(tbl->future_tbl, ht);
> +	if (unlikely(tbl))
> +		goto restart;
> +
> +	return NULL;
> +}
> +
> +static inline int rhltable_insert_key(
> +	struct rhltable *hlt, const void *key, struct rhlist_head *list,
> +	const struct rhashtable_params params)
> +{
> +	return PTR_ERR(__rhashtable_insert_fast(&hlt->ht, key, &list->rhead,
> +						params));
> +}
> +
> +static inline int rhltable_remove(
> +	struct rhltable *hlt, struct rhlist_head *list,
> +	const struct rhashtable_params params)
> +{
> +	return rhashtable_remove_fast(&hlt->ht, &list->rhead, params);
> +}
> +
> +static inline void rhltable_free_and_destroy(struct rhltable *hlt,
> +					     void (*free_fn)(void *ptr,
> +							     void *arg),
> +					     void *arg)
> +{
> +	return rhashtable_free_and_destroy(&hlt->ht, free_fn, arg);
> +}
> +
> +static inline void rhltable_destroy(struct rhltable *hlt)
> +{
> +	return rhltable_free_and_destroy(hlt, NULL, NULL);
> +}
> +
> +static inline void rhltable_walk_enter(struct rhltable *hlt,
> +				       struct rhashtable_iter *iter)
> +{
> +	rhashtable_walk_init(&hlt->ht, iter);
> +}
> +#endif /* !HAVE_RHLTABLE */
> +
>  #ifndef HAVE_RHASHTABLE_LOOKUP_GET_INSERT_FAST
>  /**
>   * rhashtable_lookup_get_insert_fast - lookup and insert object into hash table
> diff --git a/lustre/include/lustre_export.h b/lustre/include/lustre_export.h
> index 5ead593..54887c9 100644
> --- a/lustre/include/lustre_export.h
> +++ b/lustre/include/lustre_export.h
> @@ -209,7 +209,7 @@ struct obd_export {
>  	/* Unlinked export list */
>  	struct list_head	exp_stale_list;
>  	struct hlist_node	exp_uuid_hash;	/** uuid-export hash*/
> -	struct hlist_node	exp_nid_hash;	/** nid-export hash */
> +	struct rhlist_head	exp_nid_hash;	/** nid-export hash */
>  	struct hlist_node	exp_gen_hash;   /** last_rcvd clt gen hash */
>          /**
>           * All exports eligible for ping evictor are linked into a list
> diff --git a/lustre/include/obd.h b/lustre/include/obd.h
> index 1fcf0a2..8219710 100644
> --- a/lustre/include/obd.h
> +++ b/lustre/include/obd.h
> @@ -639,7 +639,7 @@ struct obd_device {
>          /* uuid-export hash body */
>  	struct cfs_hash             *obd_uuid_hash;
>          /* nid-export hash body */
> -	struct cfs_hash             *obd_nid_hash;
> +	struct rhltable			obd_nid_hash;
>  	/* nid stats body */
>  	struct cfs_hash             *obd_nid_stats_hash;
>  	/* client_generation-export hash body */
> @@ -750,6 +750,12 @@ struct obd_device {
>  	struct completion		obd_kobj_unregister;
>  };
>  
> +int obd_nid_export_for_each(struct obd_device *obd, lnet_nid_t nid,
> +			    int cb(struct obd_export *exp, void *data),
> +			    void *data);
> +int obd_nid_add(struct obd_device *obd, struct obd_export *exp);
> +void obd_nid_del(struct obd_device *obd, struct obd_export *exp);
> +
>  /* get/set_info keys */
>  #define KEY_ASYNC               "async"
>  #define KEY_CHANGELOG_CLEAR     "changelog_clear"
> diff --git a/lustre/include/obd_support.h b/lustre/include/obd_support.h
> index e9dd33e..0175cf8 100644
> --- a/lustre/include/obd_support.h
> +++ b/lustre/include/obd_support.h
> @@ -78,9 +78,6 @@ extern char obd_jobid_var[];
>  #define HASH_UUID_BKT_BITS 5
>  #define HASH_UUID_CUR_BITS 7
>  #define HASH_UUID_MAX_BITS 12
> -#define HASH_NID_BKT_BITS 5
> -#define HASH_NID_CUR_BITS 7
> -#define HASH_NID_MAX_BITS 12
>  #define HASH_NID_STATS_BKT_BITS 5
>  #define HASH_NID_STATS_CUR_BITS 7
>  #define HASH_NID_STATS_MAX_BITS 12
> diff --git a/lustre/ldlm/ldlm_flock.c b/lustre/ldlm/ldlm_flock.c
> index f848a36..4c1603a 100644
> --- a/lustre/ldlm/ldlm_flock.c
> +++ b/lustre/ldlm/ldlm_flock.c
> @@ -161,20 +161,18 @@ ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode, __u64 flags)
>   */
>  
>  struct ldlm_flock_lookup_cb_data {
> -	__u64 *bl_owner;
> +	u64 *bl_owner;

Arrrggg.   Please don't do this.

>  	lock = cfs_hash_lookup(exp->exp_flock_hash, cb_data->bl_owner);
> -	if (lock == NULL)
> +	if (!lock)

Or this.

If you want to fix up this stuff, do it in a separate patch.
A patch should just do one thing.
I would actually prefer that the "add compatibilty code so we can use
rhltables in old kernels" was a separate patch from "use rhltables for
obd_nid_hash", but at least those two are conceptually related.

It is much harder to read a patch if I keep having to say to myself "Oh,
that change is irrelevant here,  I can ignore it".

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181102/8d11f411/attachment.sig>
