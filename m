From: NeilBrown <neilb@suse.com>
Date: Thu, 12 Apr 2018 07:54:48 +1000
Subject: [lustre-devel] [PATCH 09/20] staging: lustre: convert ldlm_resource
 hash to rhashtable.
In-Reply-To: <152348312863.12394.11915752362061083241.stgit@noble>
References: <152348312863.12394.11915752362061083241.stgit@noble>
Message-ID: <152348368883.12394.3134707122101129408.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Using an rhashtable allows lockless lookup at the cost
of rcu freeing of entries.

When we find an entry, we need to atomically check the
reference hasn't dropped to zero.

When adding an entry, we might find an existing entry which is in the
process of being removed - with a zero refcount.  In that case
we loop around and repeat the lookup.  To ensure this doesn't
spin, the 'cmp' function will fail any comparison with a resource
which has a zero refcount.

Now that we are using resizing hash tables, we don't need to preconfig
suitable sizes for each namespace.  We can just use the default and
let it grow or shrink as needed.  We keep the pre-configured sizes
for the bucket array.  Previously the sizeof the bucket array was the
difference between nsd_all_bits and nsd_bkt_bits.  As we don't need
nsd_all_bits any more, nsd_bkt_bits is changed to the number of bits
used to choose a bucket.

Walking an rhashtable requires that we manage refcounts ourself, so
a new function, ldlm_resource_for_each() is added to do that.

Note that with this patch we now update a per-table counter
on every insert/remove, which might cause more contention
between CPUs on a busy system.  Hopefully rhashtable will
be enhanced in the new future to support a per-CPU counter
for nelems.

ldlm_namespace_cleanup() will sometimes iterate over the hash table
and remove everything.  If we enable automatic shrinking, the table
will be resized during this process.  There is currently a bug
in rhashtable_walk_start() which means that when that happens,
we can miss entires so not everything gets deleted.  A fix for the
bug has been accepted but has not yet landed upstream.  Rather than
wait, automatic_shrinking has been disabled for now.  Once the bug fix
lands we can enable automatic_shrinking.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   10 +
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   31 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  268 +++++++++-----------
 drivers/staging/lustre/lustre/osc/osc_request.c    |   12 -
 4 files changed, 138 insertions(+), 183 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 500dda854564..b60170a11d26 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -368,7 +368,7 @@ struct ldlm_namespace {
 	char			*ns_name;
 
 	/** Resource hash table for namespace. */
-	struct cfs_hash		*ns_rs_hash;
+	struct rhashtable	ns_rs_hash;
 	struct ldlm_ns_bucket	*ns_rs_buckets;
 	unsigned int		ns_bucket_bits;
 
@@ -828,9 +828,8 @@ struct ldlm_resource {
 
 	/**
 	 * List item for list in namespace hash.
-	 * protected by ns_lock
 	 */
-	struct hlist_node	lr_hash;
+	struct rhash_head	lr_hash;
 
 	/** Spinlock to protect locks under this resource. */
 	spinlock_t		lr_lock;
@@ -874,8 +873,13 @@ struct ldlm_resource {
 	struct lu_ref		lr_reference;
 
 	struct inode		*lr_lvb_inode;
+	struct rcu_head		lr_rcu;
 };
 
+void ldlm_resource_for_each(struct ldlm_namespace *ns,
+			    int cb(struct ldlm_resource *res, void *data),
+			    void *data);
+
 static inline bool ldlm_has_layout(struct ldlm_lock *lock)
 {
 	return lock->l_resource->lr_type == LDLM_IBITS &&
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index f573de9cf45d..1daeaf76ef89 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1680,11 +1680,8 @@ struct ldlm_cli_cancel_arg {
 	void   *lc_opaque;
 };
 
-static int ldlm_cli_hash_cancel_unused(struct cfs_hash *hs,
-				       struct cfs_hash_bd *bd,
-				       struct hlist_node *hnode, void *arg)
+static int ldlm_cli_hash_cancel_unused(struct ldlm_resource *res, void *arg)
 {
-	struct ldlm_resource	   *res = cfs_hash_object(hs, hnode);
 	struct ldlm_cli_cancel_arg     *lc = arg;
 
 	ldlm_cli_cancel_unused_resource(ldlm_res_to_ns(res), &res->lr_name,
@@ -1718,8 +1715,7 @@ int ldlm_cli_cancel_unused(struct ldlm_namespace *ns,
 						       LCK_MINMODE, flags,
 						       opaque);
 	} else {
-		cfs_hash_for_each_nolock(ns->ns_rs_hash,
-					 ldlm_cli_hash_cancel_unused, &arg, 0);
+		ldlm_resource_for_each(ns, ldlm_cli_hash_cancel_unused, &arg);
 		return ELDLM_OK;
 	}
 }
@@ -1768,27 +1764,21 @@ static int ldlm_iter_helper(struct ldlm_lock *lock, void *closure)
 	return helper->iter(lock, helper->closure);
 }
 
-static int ldlm_res_iter_helper(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-				struct hlist_node *hnode, void *arg)
-
+static int ldlm_res_iter_helper(struct ldlm_resource *res, void *arg)
 {
-	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
-
 	return ldlm_resource_foreach(res, ldlm_iter_helper, arg) ==
 	       LDLM_ITER_STOP;
 }
 
 static void ldlm_namespace_foreach(struct ldlm_namespace *ns,
 				   ldlm_iterator_t iter, void *closure)
-
 {
 	struct iter_helper_data helper = {
 		.iter		= iter,
 		.closure	= closure,
 	};
 
-	cfs_hash_for_each_nolock(ns->ns_rs_hash,
-				 ldlm_res_iter_helper, &helper, 0);
+	ldlm_resource_for_each(ns, ldlm_res_iter_helper, &helper);
 }
 
 /* non-blocking function to manipulate a lock whose cb_data is being put away.
@@ -1823,11 +1813,14 @@ static int ldlm_chain_lock_for_replay(struct ldlm_lock *lock, void *closure)
 {
 	struct list_head *list = closure;
 
-	/* we use l_pending_chain here, because it's unused on clients. */
-	LASSERTF(list_empty(&lock->l_pending_chain),
-		 "lock %p next %p prev %p\n",
-		 lock, &lock->l_pending_chain.next,
-		 &lock->l_pending_chain.prev);
+	/*
+	 * We use l_pending_chain here, because it's unused on clients.
+	 * As rhashtable_walk_next() can repeat elements when a resize event
+	 * happens, we skip locks that have already been added to the chain
+	 */
+	if (!list_empty(&lock->l_pending_chain))
+		return LDLM_ITER_CONTINUE;
+
 	/* bug 9573: don't replay locks left after eviction, or
 	 * bug 17614: locks being actively cancelled. Get a reference
 	 * on a lock so that it does not disappear under us (e.g. due to cancel)
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 4288a81fd62b..b30ad212e967 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -62,6 +62,7 @@ static LIST_HEAD(ldlm_cli_inactive_namespace_list);
 static struct dentry *ldlm_debugfs_dir;
 static struct dentry *ldlm_ns_debugfs_dir;
 struct dentry *ldlm_svc_debugfs_dir;
+static void __ldlm_resource_putref_final(struct ldlm_resource *res);
 
 /* during debug dump certain amount of granted locks for one resource to avoid
  * DDOS.
@@ -453,28 +454,6 @@ static int ldlm_namespace_debugfs_register(struct ldlm_namespace *ns)
 
 #undef MAX_STRING_SIZE
 
-static struct ldlm_resource *ldlm_resource_getref(struct ldlm_resource *res)
-{
-	LASSERT(res);
-	LASSERT(res != LP_POISON);
-	atomic_inc(&res->lr_refcount);
-	CDEBUG(D_INFO, "getref res: %p count: %d\n", res,
-	       atomic_read(&res->lr_refcount));
-	return res;
-}
-
-static unsigned int ldlm_res_hop_hash(struct cfs_hash *hs,
-				      const void *key, unsigned int mask)
-{
-	const struct ldlm_res_id     *id  = key;
-	unsigned int		val = 0;
-	unsigned int		i;
-
-	for (i = 0; i < RES_NAME_SIZE; i++)
-		val += id->name[i];
-	return val & mask;
-}
-
 static unsigned int ldlm_res_hop_fid_hash(const struct ldlm_res_id *id, unsigned int bits)
 {
 	struct lu_fid       fid;
@@ -496,84 +475,52 @@ static unsigned int ldlm_res_hop_fid_hash(const struct ldlm_res_id *id, unsigned
 	return hash_32(hash, bits);
 }
 
-static void *ldlm_res_hop_key(struct hlist_node *hnode)
-{
-	struct ldlm_resource   *res;
-
-	res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
-	return &res->lr_name;
-}
-
-static int ldlm_res_hop_keycmp(const void *key, struct hlist_node *hnode)
-{
-	struct ldlm_resource   *res;
-
-	res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
-	return ldlm_res_eq((const struct ldlm_res_id *)key,
-			   (const struct ldlm_res_id *)&res->lr_name);
-}
-
-static void *ldlm_res_hop_object(struct hlist_node *hnode)
-{
-	return hlist_entry(hnode, struct ldlm_resource, lr_hash);
-}
-
-static void ldlm_res_hop_get_locked(struct cfs_hash *hs,
-				    struct hlist_node *hnode)
-{
-	struct ldlm_resource *res;
-
-	res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
-	ldlm_resource_getref(res);
-}
-
-static void ldlm_res_hop_put(struct cfs_hash *hs, struct hlist_node *hnode)
+static int rs_cmp(struct rhashtable_compare_arg *arg, const void *obj)
 {
-	struct ldlm_resource *res;
+	/*
+	 * Don't allow entries with lr_refcount==0 to be found.
+	 * rhashtable_remove doesn't use this function, so they
+	 * can still be deleted.
+	 */
+	const struct ldlm_res_id *name = arg->key;
+	const struct ldlm_resource *res = obj;
 
-	res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
-	ldlm_resource_putref(res);
+	if (!ldlm_res_eq(name, &res->lr_name))
+		return -ESRCH;
+	return atomic_read(&res->lr_refcount) > 0 ? 0 : -EBUSY;
 }
 
-static struct cfs_hash_ops ldlm_ns_hash_ops = {
-	.hs_hash	= ldlm_res_hop_hash,
-	.hs_key		= ldlm_res_hop_key,
-	.hs_keycmp      = ldlm_res_hop_keycmp,
-	.hs_keycpy      = NULL,
-	.hs_object      = ldlm_res_hop_object,
-	.hs_get		= ldlm_res_hop_get_locked,
-	.hs_put		= ldlm_res_hop_put
+static const struct rhashtable_params ns_rs_hash_params = {
+	.key_len	= sizeof(struct ldlm_res_id),
+	.key_offset	= offsetof(struct ldlm_resource, lr_name),
+	.head_offset	= offsetof(struct ldlm_resource, lr_hash),
+	.obj_cmpfn	= rs_cmp,
+/* automatic_shrinking cannot be enabled until a bug
+ * in rhashtable_walk_start() is fixed
+	.automatic_shrinking = true,
+ */
 };
 
 static struct {
-	/** hash bucket bits */
 	unsigned int	nsd_bkt_bits;
-	/** hash bits */
-	unsigned int	nsd_all_bits;
 } ldlm_ns_hash_defs[] = {
 	[LDLM_NS_TYPE_MDC] = {
-		.nsd_bkt_bits   = 11,
-		.nsd_all_bits   = 16,
+		.nsd_bkt_bits   = 5,
 	},
 	[LDLM_NS_TYPE_MDT] = {
-		.nsd_bkt_bits   = 14,
-		.nsd_all_bits   = 21,
+		.nsd_bkt_bits   = 7,
 	},
 	[LDLM_NS_TYPE_OSC] = {
-		.nsd_bkt_bits   = 8,
-		.nsd_all_bits   = 12,
+		.nsd_bkt_bits   = 4,
 	},
 	[LDLM_NS_TYPE_OST] = {
-		.nsd_bkt_bits   = 11,
-		.nsd_all_bits   = 17,
+		.nsd_bkt_bits   = 6,
 	},
 	[LDLM_NS_TYPE_MGC] = {
-		.nsd_bkt_bits   = 3,
-		.nsd_all_bits   = 4,
+		.nsd_bkt_bits   = 1,
 	},
 	[LDLM_NS_TYPE_MGT] = {
-		.nsd_bkt_bits   = 3,
-		.nsd_all_bits   = 4,
+		.nsd_bkt_bits   = 1,
 	},
 };
 
@@ -618,23 +565,11 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	if (!ns)
 		goto out_ref;
 
-	ns->ns_rs_hash = cfs_hash_create(name,
-					 ldlm_ns_hash_defs[ns_type].nsd_all_bits,
-					 ldlm_ns_hash_defs[ns_type].nsd_all_bits,
-					 ldlm_ns_hash_defs[ns_type].nsd_bkt_bits,
-					 0,
-					 CFS_HASH_MIN_THETA,
-					 CFS_HASH_MAX_THETA,
-					 &ldlm_ns_hash_ops,
-					 CFS_HASH_DEPTH |
-					 CFS_HASH_BIGNAME |
-					 CFS_HASH_SPIN_BKTLOCK |
-					 CFS_HASH_NO_ITEMREF);
-	if (!ns->ns_rs_hash)
-		goto out_ns;
-	ns->ns_bucket_bits = ldlm_ns_hash_defs[ns_type].nsd_all_bits -
-			      ldlm_ns_hash_defs[ns_type].nsd_bkt_bits;
+	rc = rhashtable_init(&ns->ns_rs_hash, &ns_rs_hash_params);
 
+	if (rc)
+		goto out_ns;
+	ns->ns_bucket_bits = ldlm_ns_hash_defs[ns_type].nsd_bkt_bits;
 	ns->ns_rs_buckets = kvmalloc_array(1 << ns->ns_bucket_bits,
 					   sizeof(ns->ns_rs_buckets[0]),
 					   GFP_KERNEL);
@@ -698,7 +633,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 out_hash:
 	kfree(ns->ns_name);
 	kvfree(ns->ns_rs_buckets);
-	cfs_hash_putref(ns->ns_rs_hash);
+	rhashtable_destroy(&ns->ns_rs_hash);
 out_ns:
 	kfree(ns);
 out_ref:
@@ -786,23 +721,18 @@ static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
 	} while (1);
 }
 
-static int ldlm_resource_clean(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-			       struct hlist_node *hnode, void *arg)
+static int ldlm_resource_clean(struct ldlm_resource *res, void *arg)
 {
-	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
-	__u64 flags = *(__u64 *)arg;
+	__u64 *flags = arg;
 
-	cleanup_resource(res, &res->lr_granted, flags);
-	cleanup_resource(res, &res->lr_waiting, flags);
+	cleanup_resource(res, &res->lr_granted, *flags);
+	cleanup_resource(res, &res->lr_waiting, *flags);
 
 	return 0;
 }
 
-static int ldlm_resource_complain(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-				  struct hlist_node *hnode, void *arg)
+static int ldlm_resource_complain(struct ldlm_resource *res, void *arg)
 {
-	struct ldlm_resource  *res = cfs_hash_object(hs, hnode);
-
 	lock_res(res);
 	CERROR("%s: namespace resource " DLDLMRES
 	       " (%p) refcount nonzero (%d) after lock cleanup; forcing cleanup.\n",
@@ -814,6 +744,39 @@ static int ldlm_resource_complain(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 	return 0;
 }
 
+void ldlm_resource_for_each(struct ldlm_namespace *ns,
+			    int cb(struct ldlm_resource *res, void *data),
+			    void *data)
+{
+	struct rhashtable_iter iter;
+	struct ldlm_resource *res, *to_put = NULL;
+
+	rhashtable_walk_enter(&ns->ns_rs_hash, &iter);
+	rhashtable_walk_start(&iter);
+	while ((res = rhashtable_walk_next(&iter)) != NULL) {
+		if (IS_ERR(res))
+			continue;
+		if (!atomic_inc_not_zero(&res->lr_refcount))
+			continue;
+		rhashtable_walk_stop(&iter);
+		if (to_put) {
+			__ldlm_resource_putref_final(to_put);
+			to_put = NULL;
+		}
+		if (cb(res, data)) {
+			ldlm_resource_putref(res);
+			goto exit;
+		}
+		rhashtable_walk_start(&iter);
+		if (atomic_dec_and_test(&res->lr_refcount))
+			to_put = res;
+	}
+	rhashtable_walk_stop(&iter);
+exit:
+	rhashtable_walk_exit(&iter);
+	if (to_put)
+		__ldlm_resource_putref_final(to_put);
+}
 /**
  * Cancel and destroy all locks in the namespace.
  *
@@ -828,10 +791,9 @@ int ldlm_namespace_cleanup(struct ldlm_namespace *ns, __u64 flags)
 		return ELDLM_OK;
 	}
 
-	cfs_hash_for_each_nolock(ns->ns_rs_hash, ldlm_resource_clean,
-				 &flags, 0);
-	cfs_hash_for_each_nolock(ns->ns_rs_hash, ldlm_resource_complain,
-				 NULL, 0);
+	ldlm_resource_for_each(ns, ldlm_resource_clean, &flags);
+	ldlm_resource_for_each(ns, ldlm_resource_complain, NULL);
+
 	return ELDLM_OK;
 }
 EXPORT_SYMBOL(ldlm_namespace_cleanup);
@@ -960,7 +922,7 @@ void ldlm_namespace_free_post(struct ldlm_namespace *ns)
 
 	ldlm_namespace_debugfs_unregister(ns);
 	ldlm_namespace_sysfs_unregister(ns);
-	cfs_hash_putref(ns->ns_rs_hash);
+	rhashtable_destroy(&ns->ns_rs_hash);
 	kvfree(ns->ns_rs_buckets);
 	kfree(ns->ns_name);
 	/* Namespace \a ns should be not on list at this time, otherwise
@@ -1062,27 +1024,22 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 		  const struct ldlm_res_id *name, enum ldlm_type type,
 		  int create)
 {
-	struct hlist_node     *hnode;
 	struct ldlm_resource *res = NULL;
-	struct cfs_hash_bd	 bd;
-	__u64		 version;
+	struct ldlm_resource *res2;
 	int		      ns_refcount = 0;
 	int rc;
 	int hash;
 
 	LASSERT(!parent);
-	LASSERT(ns->ns_rs_hash);
 	LASSERT(name->name[0] != 0);
 
-	cfs_hash_bd_get_and_lock(ns->ns_rs_hash, (void *)name, &bd, 0);
-	hnode = cfs_hash_bd_lookup_locked(ns->ns_rs_hash, &bd, (void *)name);
-	if (hnode) {
-		cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 0);
+	rcu_read_lock();
+	res = rhashtable_lookup(&ns->ns_rs_hash, name, ns_rs_hash_params);
+	if (res && atomic_inc_not_zero(&res->lr_refcount)) {
+		rcu_read_unlock();
 		goto lvbo_init;
 	}
-
-	version = cfs_hash_bd_version_get(&bd);
-	cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 0);
+	rcu_read_unlock();
 
 	if (create == 0)
 		return ERR_PTR(-ENOENT);
@@ -1098,20 +1055,30 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 	res->lr_name       = *name;
 	res->lr_type       = type;
 
-	cfs_hash_bd_lock(ns->ns_rs_hash, &bd, 1);
-	hnode = (version == cfs_hash_bd_version_get(&bd)) ?  NULL :
-		cfs_hash_bd_lookup_locked(ns->ns_rs_hash, &bd, (void *)name);
-
-	if (hnode) {
+	/*
+	 * If we find an existing entry with a refcount of zero, we need to
+	 * try again.
+	 */
+	rcu_read_lock();
+	do {
+		res2 = rhashtable_lookup_get_insert_fast(&ns->ns_rs_hash, &res->lr_hash,
+							 ns_rs_hash_params);
+	} while (!IS_ERR_OR_NULL(res2) && !atomic_inc_not_zero(&res2->lr_refcount));
+	rcu_read_unlock();
+	if (res2) {
+		/* Insertion failed: an error occurred or              */
 		/* Someone won the race and already added the resource. */
-		cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 1);
+
 		/* Clean lu_ref for failed resource. */
 		lu_ref_fini(&res->lr_reference);
 		/* We have taken lr_lvb_mutex. Drop it. */
 		mutex_unlock(&res->lr_lvb_mutex);
 		kmem_cache_free(ldlm_resource_slab, res);
+
+		if (IS_ERR(res2))
+			return ERR_PTR(-ENOMEM);
+		res = res2;
 lvbo_init:
-		res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
 		/* Synchronize with regard to resource creation. */
 		if (ns->ns_lvbo && ns->ns_lvbo->lvbo_init) {
 			mutex_lock(&res->lr_lvb_mutex);
@@ -1125,12 +1092,9 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 		}
 		return res;
 	}
-	/* We won! Let's add the resource. */
-	cfs_hash_bd_add_locked(ns->ns_rs_hash, &bd, &res->lr_hash);
 	if (atomic_inc_return(&res->lr_ns_bucket->nsb_count) == 1)
 		ns_refcount = ldlm_namespace_get_return(ns);
 
-	cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 1);
 	if (ns->ns_lvbo && ns->ns_lvbo->lvbo_init) {
 		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CREATE_RESOURCE, 2);
 		rc = ns->ns_lvbo->lvbo_init(res);
@@ -1163,8 +1127,14 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 }
 EXPORT_SYMBOL(ldlm_resource_get);
 
-static void __ldlm_resource_putref_final(struct cfs_hash_bd *bd,
-					 struct ldlm_resource *res)
+static void ldlm_resource_free(struct rcu_head *rcu)
+{
+	struct ldlm_resource *res = container_of(rcu, struct ldlm_resource,
+						 lr_rcu);
+	kmem_cache_free(ldlm_resource_slab, res);
+}
+
+static void __ldlm_resource_putref_final(struct ldlm_resource *res)
 {
 	struct ldlm_ns_bucket *nsb = res->lr_ns_bucket;
 	struct ldlm_namespace *ns = nsb->nsb_namespace;
@@ -1179,29 +1149,24 @@ static void __ldlm_resource_putref_final(struct cfs_hash_bd *bd,
 		LBUG();
 	}
 
-	cfs_hash_bd_del_locked(ns->ns_rs_hash,
-			       bd, &res->lr_hash);
+	rhashtable_remove_fast(&ns->ns_rs_hash,
+			       &res->lr_hash, ns_rs_hash_params);
 	lu_ref_fini(&res->lr_reference);
-	cfs_hash_bd_unlock(ns->ns_rs_hash, bd, 1);
 	if (ns->ns_lvbo && ns->ns_lvbo->lvbo_free)
 		ns->ns_lvbo->lvbo_free(res);
 	if (atomic_dec_and_test(&nsb->nsb_count))
 		ldlm_namespace_put(ns);
-	kmem_cache_free(ldlm_resource_slab, res);
+	call_rcu(&res->lr_rcu, ldlm_resource_free);
 }
 
 void ldlm_resource_putref(struct ldlm_resource *res)
 {
-	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
-	struct cfs_hash_bd   bd;
-
 	LASSERT_ATOMIC_GT_LT(&res->lr_refcount, 0, LI_POISON);
 	CDEBUG(D_INFO, "putref res: %p count: %d\n",
 	       res, atomic_read(&res->lr_refcount) - 1);
 
-	cfs_hash_bd_get(ns->ns_rs_hash, &res->lr_name, &bd);
-	if (cfs_hash_bd_dec_and_lock(ns->ns_rs_hash, &bd, &res->lr_refcount))
-		__ldlm_resource_putref_final(&bd, res);
+	if (atomic_dec_and_test(&res->lr_refcount))
+		__ldlm_resource_putref_final(res);
 }
 EXPORT_SYMBOL(ldlm_resource_putref);
 
@@ -1263,14 +1228,12 @@ void ldlm_dump_all_namespaces(enum ldlm_side client, int level)
 	mutex_unlock(ldlm_namespace_lock(client));
 }
 
-static int ldlm_res_hash_dump(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-			      struct hlist_node *hnode, void *arg)
+static int ldlm_res_hash_dump(struct ldlm_resource *res, void *arg)
 {
-	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
-	int    level = (int)(unsigned long)arg;
+	int    *level = arg;
 
 	lock_res(res);
-	ldlm_resource_dump(level, res);
+	ldlm_resource_dump(*level, res);
 	unlock_res(res);
 
 	return 0;
@@ -1291,9 +1254,8 @@ void ldlm_namespace_dump(int level, struct ldlm_namespace *ns)
 	if (time_before(jiffies, ns->ns_next_dump))
 		return;
 
-	cfs_hash_for_each_nolock(ns->ns_rs_hash,
-				 ldlm_res_hash_dump,
-				 (void *)(unsigned long)level, 0);
+	ldlm_resource_for_each(ns, ldlm_res_hash_dump, &level);
+
 	spin_lock(&ns->ns_lock);
 	ns->ns_next_dump = jiffies + 10 * HZ;
 	spin_unlock(&ns->ns_lock);
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 0038e555e905..06dc52dfb671 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2479,13 +2479,10 @@ static int osc_disconnect(struct obd_export *exp)
 	return rc;
 }
 
-static int osc_ldlm_resource_invalidate(struct cfs_hash *hs,
-					struct cfs_hash_bd *bd,
-					struct hlist_node *hnode, void *arg)
+static int osc_ldlm_resource_invalidate(struct ldlm_resource *res, void *data)
 {
-	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
+	struct lu_env *env = data;
 	struct osc_object *osc = NULL;
-	struct lu_env *env = arg;
 	struct ldlm_lock *lock;
 
 	lock_res(res);
@@ -2545,9 +2542,8 @@ static int osc_import_event(struct obd_device *obd,
 		if (!IS_ERR(env)) {
 			osc_io_unplug(env, &obd->u.cli, NULL);
 
-			cfs_hash_for_each_nolock(ns->ns_rs_hash,
-						 osc_ldlm_resource_invalidate,
-						 env, 0);
+			ldlm_resource_for_each(ns, osc_ldlm_resource_invalidate, env);
+
 			cl_env_put(env, &refcheck);
 
 			ldlm_namespace_cleanup(ns, LDLM_FL_LOCAL_ONLY);
