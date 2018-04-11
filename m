From: NeilBrown <neilb@suse.com>
Date: Thu, 12 Apr 2018 07:54:48 +1000
Subject: [lustre-devel] [PATCH 02/20] staging: lustre: convert lov_pool to
 use rhashtable
In-Reply-To: <152348312863.12394.11915752362061083241.stgit@noble>
References: <152348312863.12394.11915752362061083241.stgit@noble>
Message-ID: <152348368857.12394.13530263723383915776.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

The pools hashtable can be implemented using
the rhashtable implementation in lib.
This has the benefit that lookups are lock-free.

We need to use kfree_rcu() to free a pool so
that a lookup racing with a deletion will not access
freed memory.

rhashtable has no combined lookup-and-delete interface,
but as the lookup is lockless and the chains are short,
this brings little cost.  Even if a lookup finds a pool,
we must be prepared for the delete to fail to find it,
as we might race with another thread doing a delete.

We use atomic_inc_not_zero() after finding a pool in the
hash table and if that fails, we must have raced with a
deletion, so we treat the lookup as a failure.

Use hashlen_string() rather than a hand-crafted hash
function.
Note that the pool_name, and the search key, are
guaranteed to be nul terminated.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/obd.h        |    4 -
 .../staging/lustre/lustre/include/obd_support.h    |    3 
 drivers/staging/lustre/lustre/lov/lov_internal.h   |   11 +
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   12 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  159 ++++++++------------
 5 files changed, 80 insertions(+), 109 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index f1233ca7d337..ad265db48b76 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -46,6 +46,8 @@
 #include <lustre_intent.h>
 #include <cl_object.h>
 
+#include <linux/rhashtable.h>
+
 #define MAX_OBD_DEVICES 8192
 
 struct osc_async_rc {
@@ -383,7 +385,7 @@ struct lov_obd {
 	__u32		   lov_tgt_size;   /* size of tgts array */
 	int		     lov_connects;
 	int		     lov_pool_count;
-	struct cfs_hash	     *lov_pools_hash_body; /* used for key access */
+	struct rhashtable	lov_pools_hash_body; /* used for key access */
 	struct list_head	lov_pool_list; /* used for sequential access */
 	struct dentry		*lov_pool_debugfs_entry;
 	enum lustre_sec_part    lov_sp_me;
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index aebcab191442..730a6ee71565 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -61,9 +61,6 @@ extern atomic_long_t obd_dirty_transit_pages;
 extern char obd_jobid_var[];
 
 /* Some hash init argument constants */
-#define HASH_POOLS_BKT_BITS 3
-#define HASH_POOLS_CUR_BITS 3
-#define HASH_POOLS_MAX_BITS 7
 #define HASH_UUID_BKT_BITS 5
 #define HASH_UUID_CUR_BITS 7
 #define HASH_UUID_MAX_BITS 12
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 27f60dd7ab9a..47042f27ca90 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -149,11 +149,16 @@ struct pool_desc {
 	char			 pool_name[LOV_MAXPOOLNAME + 1];
 	struct ost_pool		 pool_obds;
 	atomic_t		 pool_refcount;
-	struct hlist_node	 pool_hash;		/* access by poolname */
-	struct list_head	 pool_list;		/* serial access */
+	struct rhash_head	 pool_hash;		/* access by poolname */
+	union {
+		struct list_head	pool_list;	/* serial access */
+		struct rcu_head		rcu;		/* delayed free */
+	};
 	struct dentry		*pool_debugfs_entry;	/* file in debugfs */
 	struct obd_device	*pool_lobd;		/* owner */
 };
+int lov_pool_hash_init(struct rhashtable *tbl);
+void lov_pool_hash_destroy(struct rhashtable *tbl);
 
 struct lov_request {
 	struct obd_info	  rq_oi;
@@ -241,8 +246,6 @@ void lprocfs_lov_init_vars(struct lprocfs_static_vars *lvars);
 /* lov_cl.c */
 extern struct lu_device_type lov_device_type;
 
-/* pools */
-extern struct cfs_hash_ops pool_hash_operations;
 /* ost_pool methods */
 int lov_ost_pool_init(struct ost_pool *op, unsigned int count);
 int lov_ost_pool_extend(struct ost_pool *op, unsigned int min_count);
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 355e87ecc62d..94da35e673f7 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -795,15 +795,11 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 
 	init_rwsem(&lov->lov_notify_lock);
 
-	lov->lov_pools_hash_body = cfs_hash_create("POOLS", HASH_POOLS_CUR_BITS,
-						   HASH_POOLS_MAX_BITS,
-						   HASH_POOLS_BKT_BITS, 0,
-						   CFS_HASH_MIN_THETA,
-						   CFS_HASH_MAX_THETA,
-						   &pool_hash_operations,
-						   CFS_HASH_DEFAULT);
 	INIT_LIST_HEAD(&lov->lov_pool_list);
 	lov->lov_pool_count = 0;
+	rc = lov_pool_hash_init(&lov->lov_pools_hash_body);
+	if (rc)
+		goto out;
 	rc = lov_ost_pool_init(&lov->lov_packed, 0);
 	if (rc)
 		goto out;
@@ -839,7 +835,7 @@ static int lov_cleanup(struct obd_device *obd)
 		/* coverity[overrun-buffer-val] */
 		lov_pool_del(obd, pool->pool_name);
 	}
-	cfs_hash_putref(lov->lov_pools_hash_body);
+	lov_pool_hash_destroy(&lov->lov_pools_hash_body);
 	lov_ost_pool_free(&lov->lov_packed);
 
 	lprocfs_obd_cleanup(obd);
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index ecd9329cd073..b673b4fd305b 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -49,6 +49,28 @@
 #define pool_tgt(_p, _i) \
 		_p->pool_lobd->u.lov.lov_tgts[_p->pool_obds.op_array[_i]]
 
+static u32 pool_hashfh(const void *data, u32 len, u32 seed)
+{
+	const char *pool_name = data;
+	return hashlen_hash(hashlen_string((void*)(unsigned long)seed, pool_name));
+}
+
+static int pool_cmpfn(struct rhashtable_compare_arg *arg, const void *obj)
+{
+	const struct pool_desc *pool = obj;
+	const char *pool_name = arg->key;
+	return strcmp(pool_name, pool->pool_name);
+}
+
+static const struct rhashtable_params pools_hash_params = {
+	.key_len	= 1, /* actually variable */
+	.key_offset	= offsetof(struct pool_desc, pool_name),
+	.head_offset	= offsetof(struct pool_desc, pool_hash),
+	.hashfn		= pool_hashfh,
+	.obj_cmpfn	= pool_cmpfn,
+	.automatic_shrinking = true,
+};
+
 static void lov_pool_getref(struct pool_desc *pool)
 {
 	CDEBUG(D_INFO, "pool %p\n", pool);
@@ -59,96 +81,13 @@ void lov_pool_putref(struct pool_desc *pool)
 {
 	CDEBUG(D_INFO, "pool %p\n", pool);
 	if (atomic_dec_and_test(&pool->pool_refcount)) {
-		LASSERT(hlist_unhashed(&pool->pool_hash));
 		LASSERT(list_empty(&pool->pool_list));
 		LASSERT(!pool->pool_debugfs_entry);
 		lov_ost_pool_free(&pool->pool_obds);
-		kfree(pool);
-	}
-}
-
-static void lov_pool_putref_locked(struct pool_desc *pool)
-{
-	CDEBUG(D_INFO, "pool %p\n", pool);
-	LASSERT(atomic_read(&pool->pool_refcount) > 1);
-
-	atomic_dec(&pool->pool_refcount);
-}
-
-/*
- * hash function using a Rotating Hash algorithm
- * Knuth, D. The Art of Computer Programming,
- * Volume 3: Sorting and Searching,
- * Chapter 6.4.
- * Addison Wesley, 1973
- */
-static __u32 pool_hashfn(struct cfs_hash *hash_body, const void *key,
-			 unsigned int mask)
-{
-	int i;
-	__u32 result;
-	char *poolname;
-
-	result = 0;
-	poolname = (char *)key;
-	for (i = 0; i < LOV_MAXPOOLNAME; i++) {
-		if (poolname[i] == '\0')
-			break;
-		result = (result << 4) ^ (result >> 28) ^  poolname[i];
+		kfree_rcu(pool, rcu);
 	}
-	return (result % mask);
-}
-
-static void *pool_key(struct hlist_node *hnode)
-{
-	struct pool_desc *pool;
-
-	pool = hlist_entry(hnode, struct pool_desc, pool_hash);
-	return pool->pool_name;
-}
-
-static int pool_hashkey_keycmp(const void *key, struct hlist_node *compared_hnode)
-{
-	char *pool_name;
-	struct pool_desc *pool;
-
-	pool_name = (char *)key;
-	pool = hlist_entry(compared_hnode, struct pool_desc, pool_hash);
-	return !strncmp(pool_name, pool->pool_name, LOV_MAXPOOLNAME);
-}
-
-static void *pool_hashobject(struct hlist_node *hnode)
-{
-	return hlist_entry(hnode, struct pool_desc, pool_hash);
-}
-
-static void pool_hashrefcount_get(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-	struct pool_desc *pool;
-
-	pool = hlist_entry(hnode, struct pool_desc, pool_hash);
-	lov_pool_getref(pool);
-}
-
-static void pool_hashrefcount_put_locked(struct cfs_hash *hs,
-					 struct hlist_node *hnode)
-{
-	struct pool_desc *pool;
-
-	pool = hlist_entry(hnode, struct pool_desc, pool_hash);
-	lov_pool_putref_locked(pool);
 }
 
-struct cfs_hash_ops pool_hash_operations = {
-	.hs_hash	= pool_hashfn,
-	.hs_key		= pool_key,
-	.hs_keycmp      = pool_hashkey_keycmp,
-	.hs_object      = pool_hashobject,
-	.hs_get		= pool_hashrefcount_get,
-	.hs_put_locked  = pool_hashrefcount_put_locked,
-
-};
-
 /*
  * pool debugfs seq_file methods
  */
@@ -396,6 +335,23 @@ int lov_ost_pool_free(struct ost_pool *op)
 	return 0;
 }
 
+static void
+pools_hash_exit(void *vpool, void *data)
+{
+	struct pool_desc *pool = vpool;
+	lov_pool_putref(pool);
+}
+
+int lov_pool_hash_init(struct rhashtable *tbl)
+{
+	return rhashtable_init(tbl, &pools_hash_params);
+}
+
+void lov_pool_hash_destroy(struct rhashtable *tbl)
+{
+	rhashtable_free_and_destroy(tbl, pools_hash_exit, NULL);
+}
+
 int lov_pool_new(struct obd_device *obd, char *poolname)
 {
 	struct lov_obd *lov;
@@ -421,8 +377,6 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 	if (rc)
 		goto out_err;
 
-	INIT_HLIST_NODE(&new_pool->pool_hash);
-
 	/* get ref for debugfs file */
 	lov_pool_getref(new_pool);
 	new_pool->pool_debugfs_entry = ldebugfs_add_simple(
@@ -443,11 +397,16 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 	lov->lov_pool_count++;
 	spin_unlock(&obd->obd_dev_lock);
 
-	/* add to find only when it fully ready  */
-	rc = cfs_hash_add_unique(lov->lov_pools_hash_body, poolname,
-				 &new_pool->pool_hash);
+	/* Add to hash table only when it is fully ready.  */
+	rc = rhashtable_lookup_insert_fast(&lov->lov_pools_hash_body,
+					   &new_pool->pool_hash, pools_hash_params);
 	if (rc) {
-		rc = -EEXIST;
+		if (rc != -EEXIST)
+			/*
+			 * Hide -E2BIG and -EBUSY which
+			 * are not helpful.
+			 */
+			rc = -ENOMEM;
 		goto out_err;
 	}
 
@@ -476,7 +435,13 @@ int lov_pool_del(struct obd_device *obd, char *poolname)
 	lov = &obd->u.lov;
 
 	/* lookup and kill hash reference */
-	pool = cfs_hash_del_key(lov->lov_pools_hash_body, poolname);
+	rcu_read_lock();
+	pool = rhashtable_lookup(&lov->lov_pools_hash_body, poolname, pools_hash_params);
+	if (pool)
+		if (rhashtable_remove_fast(&lov->lov_pools_hash_body,
+					   &pool->pool_hash, pools_hash_params) != 0)
+			pool = NULL;
+	rcu_read_unlock();
 	if (!pool)
 		return -ENOENT;
 
@@ -507,7 +472,11 @@ int lov_pool_add(struct obd_device *obd, char *poolname, char *ostname)
 
 	lov = &obd->u.lov;
 
-	pool = cfs_hash_lookup(lov->lov_pools_hash_body, poolname);
+	rcu_read_lock();
+	pool = rhashtable_lookup(&lov->lov_pools_hash_body, poolname, pools_hash_params);
+	if (pool && !atomic_inc_not_zero(&pool->pool_refcount))
+		pool = NULL;
+	rcu_read_unlock();
 	if (!pool)
 		return -ENOENT;
 
@@ -551,7 +520,11 @@ int lov_pool_remove(struct obd_device *obd, char *poolname, char *ostname)
 
 	lov = &obd->u.lov;
 
-	pool = cfs_hash_lookup(lov->lov_pools_hash_body, poolname);
+	rcu_read_lock();
+	pool = rhashtable_lookup(&lov->lov_pools_hash_body, poolname, pools_hash_params);
+	if (pool && !atomic_inc_not_zero(&pool->pool_refcount))
+		pool = NULL;
+	rcu_read_unlock();
 	if (!pool)
 		return -ENOENT;
 
