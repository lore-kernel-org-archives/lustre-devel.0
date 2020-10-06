From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:14 -0400
Subject: [lustre-devel] [PATCH 35/42] lustre: ldlm: pool recalc forceful call
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-36-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vitaly Fertman <c17818@cray.com>

Let pool recalc to be able to be called forcefully independently of
the last recalc time;

Call the pool recalc forcefully on the lock decref instead of LRU
cancel to take into account the fresh SLV obtained from the server.

Call LRU recalc from after_reply if a significant SLV change occurs.
Add a sysfs attribute to control what 'a significant SLV change' is.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11518
Lustre-commit: dd43ff345254f2 ("LU-11518 ldlm: pool recalc forceful call")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Reviewed-on: https://es-gerrit.dev.cray.com/157134
Reviewed-on: https://review.whamcloud.com/39564
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h | 31 +++++++++++++++++++++++++++++--
 fs/lustre/ldlm/ldlm_internal.h | 14 +-------------
 fs/lustre/ldlm/ldlm_lock.c     |  2 +-
 fs/lustre/ldlm/ldlm_lockd.c    | 13 ++++++++++++-
 fs/lustre/ldlm/ldlm_pool.c     | 12 ++++++------
 fs/lustre/ldlm/ldlm_request.c  | 35 +++++++++++++++++++++++++++++------
 fs/lustre/ldlm/ldlm_resource.c | 31 +++++++++++++++++++++++++++++++
 7 files changed, 109 insertions(+), 29 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index bc6785f..f056c2d 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -66,6 +66,7 @@
 #define LDLM_DIRTY_AGE_LIMIT (10)
 #define LDLM_DEFAULT_PARALLEL_AST_LIMIT 1024
 #define LDLM_DEFAULT_LRU_SHRINK_BATCH (16)
+#define LDLM_DEFAULT_SLV_RECALC_PCT (10)
 
 /**
  * LDLM non-error return states
@@ -193,6 +194,19 @@ static inline int lockmode_compat(enum ldlm_mode exist_mode,
  *
  */
 
+/* Cancel lru flag, it indicates we cancel aged locks. */
+enum ldlm_lru_flags {
+	LDLM_LRU_FLAG_NO_WAIT	= 0x1,	/* Cancel locks w/o blocking (neither
+					 * sending nor waiting for any RPCs)
+					 */
+	LDLM_LRU_FLAG_CLEANUP   = 0x2,	/* Used when clearing lru, tells
+					 * prepare_lru_list to set discard flag
+					 * on PR extent locks so we don't waste
+					 * time saving pages that will be
+					 * discarded momentarily
+					 */
+};
+
 struct ldlm_pool;
 struct ldlm_lock;
 struct ldlm_resource;
@@ -208,7 +222,7 @@ static inline int lockmode_compat(enum ldlm_mode exist_mode,
  */
 struct ldlm_pool_ops {
 	/** Recalculate pool @pl usage */
-	int (*po_recalc)(struct ldlm_pool *pl);
+	int (*po_recalc)(struct ldlm_pool *pl, bool force);
 	/** Cancel at least @nr locks from pool @pl */
 	int (*po_shrink)(struct ldlm_pool *pl, int nr,
 			 gfp_t gfp_mask);
@@ -430,6 +444,12 @@ struct ldlm_namespace {
 	 */
 	unsigned int		ns_cancel_batch;
 
+	/**
+	 * How much the SLV should decrease in %% to trigger LRU cancel
+	 * urgently.
+	 */
+	unsigned int		ns_recalc_pct;
+
 	/** Maximum allowed age (last used time) for locks in the LRU. Set in
 	 * seconds from userspace, but stored in ns to avoid repeat conversions.
 	 */
@@ -487,7 +507,13 @@ struct ldlm_namespace {
 	 * Flag to indicate namespace is being freed. Used to determine if
 	 * recalculation of LDLM pool statistics should be skipped.
 	 */
-	unsigned		ns_stopping:1;
+	unsigned int		ns_stopping:1,
+
+	/**
+	 * Flag to indicate the LRU recalc on RPC reply is in progress.
+	 * Used to limit the process by 1 thread only.
+	 */
+				ns_rpc_recalc:1;
 
 	struct kobject		ns_kobj; /* sysfs object */
 	struct completion	ns_kobj_unregister;
@@ -1404,6 +1430,7 @@ static inline void check_res_locked(struct ldlm_resource *res)
 int ldlm_pool_init(struct ldlm_pool *pl, struct ldlm_namespace *ns,
 		   int idx, enum ldlm_side client);
 void ldlm_pool_fini(struct ldlm_pool *pl);
+timeout_t ldlm_pool_recalc(struct ldlm_pool *pl, bool force);
 void ldlm_pool_add(struct ldlm_pool *pl, struct ldlm_lock *lock);
 void ldlm_pool_del(struct ldlm_pool *pl, struct ldlm_lock *lock);
 /** @} */
diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index 788983f..9dc0561 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -86,19 +86,6 @@ void ldlm_namespace_move_to_inactive_locked(struct ldlm_namespace *ns,
 struct ldlm_namespace *ldlm_namespace_first_locked(enum ldlm_side client);
 
 /* ldlm_request.c */
-/* Cancel lru flag, it indicates we cancel aged locks. */
-enum ldlm_lru_flags {
-	LDLM_LRU_FLAG_NO_WAIT	= BIT(1), /* Cancel locks w/o blocking (neither
-					   * sending nor waiting for any rpcs)
-					   */
-	LDLM_LRU_FLAG_CLEANUP	= BIT(2), /* Used when clearing lru, tells
-					   * prepare_lru_list to set discard
-					   * flag on PR extent locks so we
-					   * don't waste time saving pages
-					   * that will be discarded momentarily
-					   */
-};
-
 int ldlm_cancel_lru(struct ldlm_namespace *ns, int min,
 		    enum ldlm_cancel_flags cancel_flags,
 		    enum ldlm_lru_flags lru_flags);
@@ -163,6 +150,7 @@ int ldlm_bl_to_thread_list(struct ldlm_namespace *ns,
 			   struct ldlm_lock_desc *ld,
 			   struct list_head *cancels, int count,
 			   enum ldlm_cancel_flags cancel_flags);
+int ldlm_bl_to_thread_ns(struct ldlm_namespace *ns);
 int ldlm_bl_thread_wakeup(void);
 
 void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 2931873..0dbd4f3 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -808,7 +808,7 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
 		if (ldlm_is_fail_loc(lock))
 			OBD_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
 
-		ldlm_cancel_lru(ns, 0, LCF_ASYNC, 0);
+		ldlm_pool_recalc(&ns->ns_pool, true);
 	} else {
 		LDLM_DEBUG(lock, "do not add lock into lru list");
 		unlock_res_and_lock(lock);
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 7df7af2..4a91a7f 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -504,6 +504,11 @@ int ldlm_bl_to_thread_list(struct ldlm_namespace *ns, struct ldlm_lock_desc *ld,
 	return ldlm_bl_to_thread(ns, ld, NULL, cancels, count, cancel_flags);
 }
 
+int ldlm_bl_to_thread_ns(struct ldlm_namespace *ns)
+{
+	return ldlm_bl_to_thread(ns, NULL, NULL, NULL, 0, LCF_ASYNC);
+}
+
 int ldlm_bl_thread_wakeup(void)
 {
 	wake_up(&ldlm_state->ldlm_bl_pool->blp_waitq);
@@ -856,9 +861,15 @@ static int ldlm_bl_thread_blwi(struct ldlm_bl_pool *blp,
 						   LCF_BL_AST);
 		ldlm_cli_cancel_list(&blwi->blwi_head, count, NULL,
 				     blwi->blwi_flags);
-	} else {
+	} else if (blwi->blwi_lock) {
 		ldlm_handle_bl_callback(blwi->blwi_ns, &blwi->blwi_ld,
 					blwi->blwi_lock);
+	} else {
+		ldlm_pool_recalc(&blwi->blwi_ns->ns_pool, true);
+		spin_lock(&blwi->blwi_ns->ns_lock);
+		blwi->blwi_ns->ns_rpc_recalc = 0;
+		spin_unlock(&blwi->blwi_ns->ns_lock);
+		ldlm_namespace_put(blwi->blwi_ns);
 	}
 	if (blwi->blwi_mem_pressure)
 		memalloc_noreclaim_restore(flags);
diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index c37948a..9cee24b 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -252,13 +252,13 @@ static void ldlm_cli_pool_pop_slv(struct ldlm_pool *pl)
 /**
  * Recalculates client size pool @pl according to current SLV and Limit.
  */
-static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
+static int ldlm_cli_pool_recalc(struct ldlm_pool *pl, bool force)
 {
 	timeout_t recalc_interval_sec;
 	int ret;
 
 	recalc_interval_sec = ktime_get_seconds() - pl->pl_recalc_time;
-	if (recalc_interval_sec < pl->pl_recalc_period)
+	if (!force && recalc_interval_sec < pl->pl_recalc_period)
 		return 0;
 
 	spin_lock(&pl->pl_lock);
@@ -266,7 +266,7 @@ static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
 	 * Check if we need to recalc lists now.
 	 */
 	recalc_interval_sec = ktime_get_seconds() - pl->pl_recalc_time;
-	if (recalc_interval_sec < pl->pl_recalc_period) {
+	if (!force && recalc_interval_sec < pl->pl_recalc_period) {
 		spin_unlock(&pl->pl_lock);
 		return 0;
 	}
@@ -346,7 +346,7 @@ static int ldlm_cli_pool_shrink(struct ldlm_pool *pl,
  *
  * Returns	time in seconds for the next recalc of this pool
  */
-static timeout_t ldlm_pool_recalc(struct ldlm_pool *pl)
+timeout_t ldlm_pool_recalc(struct ldlm_pool *pl, bool force)
 {
 	timeout_t recalc_interval_sec;
 	int count;
@@ -373,7 +373,7 @@ static timeout_t ldlm_pool_recalc(struct ldlm_pool *pl)
 	}
 
 	if (pl->pl_ops->po_recalc) {
-		count = pl->pl_ops->po_recalc(pl);
+		count = pl->pl_ops->po_recalc(pl, force);
 		lprocfs_counter_add(pl->pl_stats, LDLM_POOL_RECALC_STAT,
 				    count);
 	}
@@ -976,7 +976,7 @@ static void ldlm_pools_recalc(struct work_struct *ws)
 		 */
 		if (!skip) {
 			delay = min(delay,
-				    ldlm_pool_recalc(&ns->ns_pool));
+				    ldlm_pool_recalc(&ns->ns_pool, false));
 			ldlm_namespace_put(ns);
 		}
 	}
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index a8d6df1..dd897ec 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1129,8 +1129,9 @@ static inline struct ldlm_pool *ldlm_imp2pl(struct obd_import *imp)
  */
 int ldlm_cli_update_pool(struct ptlrpc_request *req)
 {
+	struct ldlm_namespace *ns;
 	struct obd_device *obd;
-	u64 new_slv;
+	u64 new_slv, ratio;
 	u32 new_limit;
 
 	if (unlikely(!req->rq_import || !req->rq_import->imp_obd ||
@@ -1170,17 +1171,39 @@ int ldlm_cli_update_pool(struct ptlrpc_request *req)
 	read_unlock(&obd->obd_pool_lock);
 
 	/*
-	 * Set new SLV and limit in OBD fields to make them accessible
-	 * to the pool thread. We do not access obd_namespace and pool
-	 * directly here as there is no reliable way to make sure that
-	 * they are still alive at cleanup time. Evil races are possible
-	 * which may cause Oops at that time.
+	 * OBD device keeps the new pool attributes before they are handled by
+	 * the pool.
 	 */
 	write_lock(&obd->obd_pool_lock);
 	obd->obd_pool_slv = new_slv;
 	obd->obd_pool_limit = new_limit;
 	write_unlock(&obd->obd_pool_lock);
 
+	/*
+	 * Check if an urgent pool recalc is needed, let it to be a change of
+	 * SLV on 10%. It is applicable to LRU resize enabled case only.
+	 */
+	ns = obd->obd_namespace;
+	if (!ns_connect_lru_resize(ns) ||
+	    ldlm_pool_get_slv(&ns->ns_pool) < new_slv)
+		return 0;
+
+	ratio = 100 * new_slv / ldlm_pool_get_slv(&ns->ns_pool);
+	if (100 - ratio >= ns->ns_recalc_pct &&
+	    !ns->ns_stopping && !ns->ns_rpc_recalc) {
+		bool recalc = false;
+
+		spin_lock(&ns->ns_lock);
+		if (!ns->ns_stopping && !ns->ns_rpc_recalc) {
+			ldlm_namespace_get(ns);
+			recalc = true;
+			ns->ns_rpc_recalc = 1;
+		}
+		spin_unlock(&ns->ns_lock);
+		if (recalc)
+			ldlm_bl_to_thread_ns(ns);
+	}
+
 	return 0;
 }
 
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 3527e15..dab837d 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -273,6 +273,35 @@ static ssize_t lru_cancel_batch_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(lru_cancel_batch);
 
+static ssize_t ns_recalc_pct_show(struct kobject *kobj,
+				  struct attribute *attr, char *buf)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+
+	return scnprintf(buf, sizeof(buf) - 1, "%u\n", ns->ns_recalc_pct);
+}
+
+static ssize_t ns_recalc_pct_store(struct kobject *kobj,
+				   struct attribute *attr,
+				   const char *buffer, size_t count)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+	unsigned long tmp;
+
+	if (kstrtoul(buffer, 10, &tmp))
+		return -EINVAL;
+
+	if (tmp > 100)
+		return -ERANGE;
+
+	ns->ns_recalc_pct = (unsigned int)tmp;
+
+	return count;
+}
+LUSTRE_RW_ATTR(ns_recalc_pct);
+
 static ssize_t lru_max_age_show(struct kobject *kobj, struct attribute *attr,
 				char *buf)
 {
@@ -375,6 +404,7 @@ static ssize_t dirty_age_limit_store(struct kobject *kobj,
 	&lustre_attr_resource_count.attr,
 	&lustre_attr_lock_count.attr,
 	&lustre_attr_lock_unused_count.attr,
+	&lustre_attr_ns_recalc_pct.attr,
 	&lustre_attr_lru_size.attr,
 	&lustre_attr_lru_cancel_batch.attr,
 	&lustre_attr_lru_max_age.attr,
@@ -663,6 +693,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	ns->ns_nr_unused = 0;
 	ns->ns_max_unused = LDLM_DEFAULT_LRU_SIZE;
 	ns->ns_cancel_batch = LDLM_DEFAULT_LRU_SHRINK_BATCH;
+	ns->ns_recalc_pct = LDLM_DEFAULT_SLV_RECALC_PCT;
 	ns->ns_max_age = ktime_set(LDLM_DEFAULT_MAX_ALIVE, 0);
 	ns->ns_orig_connect_flags = 0;
 	ns->ns_connect_flags = 0;
-- 
1.8.3.1
