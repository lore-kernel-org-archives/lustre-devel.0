From: James Simmons <jsimmons@infradead.org>
Date: Wed, 28 Oct 2015 12:54:24 -0400
Subject: [lustre-devel] [PATCH 03/10] staging: lustre: change cfs_hash_ops_t
	to struct
In-Reply-To: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
References: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446051271-25189-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

Change cfs_hash_ops_t to struct cfs_hash_ops.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |   21 ++++++++++---------
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   18 ++++++++--------
 drivers/staging/lustre/lustre/libcfs/hash.c        |    2 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |    2 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |    6 ++--
 drivers/staging/lustre/lustre/obdclass/cl_object.c |    6 ++--
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    6 ++--
 .../staging/lustre/lustre/obdclass/obd_config.c    |    8 +++---
 drivers/staging/lustre/lustre/osc/osc_quota.c      |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/connection.c  |    8 +++---
 10 files changed, 40 insertions(+), 39 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 6ac54a0..200b760 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -211,13 +211,13 @@ enum cfs_hash_tag {
 struct cfs_hash {
 	/** serialize with rehash, or serialize all operations if
 	 * the hash-table has CFS_HASH_NO_BKTLOCK */
-	union cfs_hash_lock	     hs_lock;
+	union cfs_hash_lock		 hs_lock;
 	/** hash operations */
-	struct cfs_hash_ops	*hs_ops;
+	struct cfs_hash_ops		*hs_ops;
 	/** hash lock operations */
-	struct cfs_hash_lock_ops   *hs_lops;
+	struct cfs_hash_lock_ops	*hs_lops;
 	/** hash list operations */
-	struct cfs_hash_hlist_ops  *hs_hops;
+	struct cfs_hash_hlist_ops	*hs_hops;
 	/** hash buckets-table */
 	struct cfs_hash_bucket	 **hs_buckets;
 	/** total number of items on this hash-table */
@@ -296,7 +296,7 @@ struct cfs_hash_hlist_ops {
 			     struct cfs_hash_bd *bd, struct hlist_node *hnode);
 };
 
-typedef struct cfs_hash_ops {
+struct cfs_hash_ops {
 	/** return hashed value from @key */
 	unsigned (*hs_hash)(struct cfs_hash *hs, const void *key, unsigned mask);
 	/** return key address of @hnode */
@@ -318,7 +318,7 @@ typedef struct cfs_hash_ops {
 	void     (*hs_put_locked)(struct cfs_hash *hs, struct hlist_node *hnode);
 	/** it's called before removing of @hnode */
 	void     (*hs_exit)(struct cfs_hash *hs, struct hlist_node *hnode);
-} cfs_hash_ops_t;
+};
 
 /** total number of buckets in @hs */
 #define CFS_HASH_NBKT(hs)       \
@@ -668,10 +668,11 @@ struct hlist_node *cfs_hash_dual_bd_finddel_locked(struct cfs_hash *hs,
 						  struct hlist_node *hnode);
 
 /* Hash init/cleanup functions */
-struct cfs_hash *cfs_hash_create(char *name, unsigned cur_bits, unsigned max_bits,
-				 unsigned bkt_bits, unsigned extra_bytes,
-			    unsigned min_theta, unsigned max_theta,
-			    cfs_hash_ops_t *ops, unsigned flags);
+struct cfs_hash *cfs_hash_create(char *name, unsigned cur_bits,
+				 unsigned max_bits, unsigned bkt_bits,
+				 unsigned extra_bytes, unsigned min_theta,
+				 unsigned max_theta, struct cfs_hash_ops *ops,
+				 unsigned flags);
 
 struct cfs_hash *cfs_hash_getref(struct cfs_hash *hs);
 void cfs_hash_putref(struct cfs_hash *hs);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 342c465..c0a54bf 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -531,26 +531,26 @@ static void ldlm_res_hop_put(struct cfs_hash *hs, struct hlist_node *hnode)
 	ldlm_resource_putref(res);
 }
 
-static cfs_hash_ops_t ldlm_ns_hash_ops = {
+static struct cfs_hash_ops ldlm_ns_hash_ops = {
 	.hs_hash	= ldlm_res_hop_hash,
-	.hs_key	 = ldlm_res_hop_key,
+	.hs_key		= ldlm_res_hop_key,
 	.hs_keycmp      = ldlm_res_hop_keycmp,
 	.hs_keycpy      = NULL,
 	.hs_object      = ldlm_res_hop_object,
-	.hs_get	 = ldlm_res_hop_get_locked,
+	.hs_get		= ldlm_res_hop_get_locked,
 	.hs_put_locked  = ldlm_res_hop_put_locked,
-	.hs_put	 = ldlm_res_hop_put
+	.hs_put		= ldlm_res_hop_put
 };
 
-static cfs_hash_ops_t ldlm_ns_fid_hash_ops = {
+static struct cfs_hash_ops ldlm_ns_fid_hash_ops = {
 	.hs_hash	= ldlm_res_hop_fid_hash,
-	.hs_key	 = ldlm_res_hop_key,
+	.hs_key		= ldlm_res_hop_key,
 	.hs_keycmp      = ldlm_res_hop_keycmp,
 	.hs_keycpy      = NULL,
 	.hs_object      = ldlm_res_hop_object,
-	.hs_get	 = ldlm_res_hop_get_locked,
+	.hs_get		= ldlm_res_hop_get_locked,
 	.hs_put_locked  = ldlm_res_hop_put_locked,
-	.hs_put	 = ldlm_res_hop_put
+	.hs_put		= ldlm_res_hop_put
 };
 
 struct ldlm_ns_hash_def {
@@ -560,7 +560,7 @@ struct ldlm_ns_hash_def {
 	/** hash bits */
 	unsigned	nsd_all_bits;
 	/** hash operations */
-	cfs_hash_ops_t *nsd_hops;
+	struct cfs_hash_ops *nsd_hops;
 };
 
 static struct ldlm_ns_hash_def ldlm_ns_hash_defs[] = {
diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index 63c4434..f8026e1 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -1019,7 +1019,7 @@ struct cfs_hash *
 cfs_hash_create(char *name, unsigned cur_bits, unsigned max_bits,
 		unsigned bkt_bits, unsigned extra_bytes,
 		unsigned min_theta, unsigned max_theta,
-		cfs_hash_ops_t *ops, unsigned flags)
+		struct cfs_hash_ops *ops, unsigned flags)
 {
 	struct cfs_hash *hs;
 	int	 len;
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index bdee0a6..515a5c1 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -234,7 +234,7 @@ void lprocfs_lov_init_vars(struct lprocfs_static_vars *lvars);
 extern struct lu_device_type lov_device_type;
 
 /* pools */
-extern cfs_hash_ops_t pool_hash_operations;
+extern struct cfs_hash_ops pool_hash_operations;
 /* ost_pool methods */
 int lov_ost_pool_init(struct ost_pool *op, unsigned int count);
 int lov_ost_pool_extend(struct ost_pool *op, unsigned int min_count);
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 2234321..b03827e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -142,12 +142,12 @@ static void pool_hashrefcount_put_locked(struct cfs_hash *hs,
 	lov_pool_putref_locked(pool);
 }
 
-cfs_hash_ops_t pool_hash_operations = {
+struct cfs_hash_ops pool_hash_operations = {
 	.hs_hash	= pool_hashfn,
-	.hs_key	 = pool_key,
+	.hs_key		= pool_key,
 	.hs_keycmp      = pool_hashkey_keycmp,
 	.hs_object      = pool_hashobject,
-	.hs_get	 = pool_hashrefcount_get,
+	.hs_get		= pool_hashrefcount_get,
 	.hs_put_locked  = pool_hashrefcount_put_locked,
 
 };
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index f59c03c..a1a6024 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -586,12 +586,12 @@ static void cl_env_hops_noop(struct cfs_hash *hs, struct hlist_node *hn)
 	LASSERT(cle->ce_magic == &cl_env_init0);
 }
 
-static cfs_hash_ops_t cl_env_hops = {
+static struct cfs_hash_ops cl_env_hops = {
 	.hs_hash	= cl_env_hops_hash,
-	.hs_key	 = cl_env_hops_obj,
+	.hs_key		= cl_env_hops_obj,
 	.hs_keycmp      = cl_env_hops_keycmp,
 	.hs_object      = cl_env_hops_obj,
-	.hs_get	 = cl_env_hops_noop,
+	.hs_get		= cl_env_hops_noop,
 	.hs_put_locked  = cl_env_hops_noop,
 };
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 0d15bd5..0193608 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -916,12 +916,12 @@ static void lu_obj_hop_put_locked(struct cfs_hash *hs, struct hlist_node *hnode)
 	LBUG(); /* we should never called it */
 }
 
-cfs_hash_ops_t lu_site_hash_ops = {
+struct cfs_hash_ops lu_site_hash_ops = {
 	.hs_hash	= lu_obj_hop_hash,
-	.hs_key	 = lu_obj_hop_key,
+	.hs_key		= lu_obj_hop_key,
 	.hs_keycmp      = lu_obj_hop_keycmp,
 	.hs_object      = lu_obj_hop_object,
-	.hs_get	 = lu_obj_hop_get,
+	.hs_get		= lu_obj_hop_get,
 	.hs_put_locked  = lu_obj_hop_put_locked,
 };
 
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 64753b3..c231e0d 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -47,7 +47,7 @@
 
 #include "llog_internal.h"
 
-static cfs_hash_ops_t uuid_hash_ops;
+static struct cfs_hash_ops uuid_hash_ops;
 
 /*********** string parsing utils *********/
 
@@ -1473,11 +1473,11 @@ uuid_export_put_locked(struct cfs_hash *hs, struct hlist_node *hnode)
 	class_export_put(exp);
 }
 
-static cfs_hash_ops_t uuid_hash_ops = {
+static struct cfs_hash_ops uuid_hash_ops = {
 	.hs_hash	= uuid_hash,
-	.hs_key	 = uuid_key,
+	.hs_key		= uuid_key,
 	.hs_keycmp      = uuid_keycmp,
 	.hs_object      = uuid_export_object,
-	.hs_get	 = uuid_export_get,
+	.hs_get		= uuid_export_get,
 	.hs_put_locked  = uuid_export_put_locked,
 };
diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
index df8cfb4..1997831 100644
--- a/drivers/staging/lustre/lustre/osc/osc_quota.c
+++ b/drivers/staging/lustre/lustre/osc/osc_quota.c
@@ -193,7 +193,7 @@ oqi_exit(struct cfs_hash *hs, struct hlist_node *hnode)
 #define HASH_QUOTA_CUR_BITS 5
 #define HASH_QUOTA_MAX_BITS 15
 
-static cfs_hash_ops_t quota_hash_ops = {
+static struct cfs_hash_ops quota_hash_ops = {
 	.hs_hash	= oqi_hashfn,
 	.hs_keycmp	= oqi_keycmp,
 	.hs_key		= oqi_key,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/connection.c b/drivers/staging/lustre/lustre/ptlrpc/connection.c
index 1ba1f5f..da1f0b1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/connection.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/connection.c
@@ -42,7 +42,7 @@
 #include "ptlrpc_internal.h"
 
 static struct cfs_hash *conn_hash;
-static cfs_hash_ops_t conn_hash_ops;
+static struct cfs_hash_ops conn_hash_ops;
 
 struct ptlrpc_connection *
 ptlrpc_connection_get(lnet_process_id_t peer, lnet_nid_t self,
@@ -230,12 +230,12 @@ conn_exit(struct cfs_hash *hs, struct hlist_node *hnode)
 	kfree(conn);
 }
 
-static cfs_hash_ops_t conn_hash_ops = {
+static struct cfs_hash_ops conn_hash_ops = {
 	.hs_hash	= conn_hashfn,
 	.hs_keycmp      = conn_keycmp,
-	.hs_key	 = conn_key,
+	.hs_key		= conn_key,
 	.hs_object      = conn_object,
-	.hs_get	 = conn_get,
+	.hs_get		= conn_get,
 	.hs_put_locked  = conn_put_locked,
 	.hs_exit	= conn_exit,
 };
-- 
1.7.1
