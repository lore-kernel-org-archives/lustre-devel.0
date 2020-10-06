From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:49 -0400
Subject: [lustre-devel] [PATCH 10/42] lustre: ldlm: lru code cleanup
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vitaly Fertman <c17818@cray.com>

cleanup includes:
- no need in unused locks parameter in the lru policy, better to
  take the current value right in the policy if needed;
- no need in a special SHRINKER policy, the same as the PASSED one
- no need in a special DEFAULT policy, the same as the PASSED one;
- no need in a special PASSED policy, LRU is to be cleaned anyway
  according to LRU resize or AGED policy;

bug fixes:
- if the @min amount is given, it should not be increased on the
  amount of locks exceeding the limit, but the max of them is to
  be taken instead;
- do not do ELC on enqueue if no LRU limits are reached;
- do not keep lock in LRUR policy once we have cancelled @min locks,
  try to cancel instead until we reach the @max limit if given;
- cancel locks from LRU with the new policy, if changed in sysfs;

HPE-bug-id: LUS-8678
WC-bug-id: https://jira.whamcloud.com/browse/LU-11518
Lustre-commit: 209a112eb153b ("LU-11518 ldlm: lru code cleanup")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Reviewed-on: https://es-gerrit.dev.cray.com/157066
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-on: https://review.whamcloud.com/39560
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_internal.h |  12 +--
 fs/lustre/ldlm/ldlm_pool.c     |  14 +--
 fs/lustre/ldlm/ldlm_request.c  | 205 +++++++++++++----------------------------
 fs/lustre/ldlm/ldlm_resource.c |  19 +---
 4 files changed, 76 insertions(+), 174 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index 0dce219..788983f 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -88,14 +88,10 @@ void ldlm_namespace_move_to_inactive_locked(struct ldlm_namespace *ns,
 /* ldlm_request.c */
 /* Cancel lru flag, it indicates we cancel aged locks. */
 enum ldlm_lru_flags {
-	LDLM_LRU_FLAG_AGED	= BIT(0), /* Cancel old non-LRU resize locks */
-	LDLM_LRU_FLAG_PASSED	= BIT(1), /* Cancel passed number of locks. */
-	LDLM_LRU_FLAG_SHRINK	= BIT(2), /* Cancel locks from shrinker. */
-	LDLM_LRU_FLAG_LRUR	= BIT(3), /* Cancel locks from lru resize. */
-	LDLM_LRU_FLAG_NO_WAIT	= BIT(4), /* Cancel locks w/o blocking (neither
+	LDLM_LRU_FLAG_NO_WAIT	= BIT(1), /* Cancel locks w/o blocking (neither
 					   * sending nor waiting for any rpcs)
 					   */
-	LDLM_LRU_FLAG_CLEANUP	= BIT(5), /* Used when clearing lru, tells
+	LDLM_LRU_FLAG_CLEANUP	= BIT(2), /* Used when clearing lru, tells
 					   * prepare_lru_list to set discard
 					   * flag on PR extent locks so we
 					   * don't waste time saving pages
@@ -103,11 +99,11 @@ enum ldlm_lru_flags {
 					   */
 };
 
-int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
+int ldlm_cancel_lru(struct ldlm_namespace *ns, int min,
 		    enum ldlm_cancel_flags cancel_flags,
 		    enum ldlm_lru_flags lru_flags);
 int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
-			  struct list_head *cancels, int count, int max,
+			  struct list_head *cancels, int min, int max,
 			  enum ldlm_cancel_flags cancel_flags,
 			  enum ldlm_lru_flags lru_flags);
 extern unsigned int ldlm_enqueue_min;
diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index 40585f7..9e2a006 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -255,7 +255,6 @@ static void ldlm_cli_pool_pop_slv(struct ldlm_pool *pl)
 static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
 {
 	time64_t recalc_interval_sec;
-	enum ldlm_lru_flags lru_flags;
 	int ret;
 
 	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
@@ -280,22 +279,13 @@ static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
 	spin_unlock(&pl->pl_lock);
 
 	/*
-	 * Cancel aged locks if lru resize is disabled for this ns.
-	 */
-	if (!ns_connect_lru_resize(container_of(pl, struct ldlm_namespace,
-						ns_pool)))
-		lru_flags = LDLM_LRU_FLAG_LRUR;
-	else
-		lru_flags = LDLM_LRU_FLAG_AGED;
-
-	/*
 	 * In the time of canceling locks on client we do not need to maintain
 	 * sharp timing, we only want to cancel locks asap according to new SLV.
 	 * It may be called when SLV has changed much, this is why we do not
 	 * take into account pl->pl_recalc_time here.
 	 */
 	ret = ldlm_cancel_lru(container_of(pl, struct ldlm_namespace, ns_pool),
-			      0, LCF_ASYNC, lru_flags);
+			      0, LCF_ASYNC, 0);
 
 	spin_lock(&pl->pl_lock);
 	/*
@@ -340,7 +330,7 @@ static int ldlm_cli_pool_shrink(struct ldlm_pool *pl,
 	if (nr == 0)
 		return (unused / 100) * sysctl_vfs_cache_pressure;
 	else
-		return ldlm_cancel_lru(ns, nr, LCF_ASYNC, LDLM_LRU_FLAG_SHRINK);
+		return ldlm_cancel_lru(ns, nr, LCF_ASYNC, 0);
 }
 
 static const struct ldlm_pool_ops ldlm_cli_pool_ops = {
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 6318137..4bd7372 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -606,8 +606,7 @@ int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
 	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
 	struct req_capsule *pill = &req->rq_pill;
 	struct ldlm_request *dlm = NULL;
-	enum ldlm_lru_flags lru_flags;
-	int avail, to_free, pack = 0;
+	int avail, to_free = 0, pack = 0;
 	LIST_HEAD(head);
 	int rc;
 
@@ -618,11 +617,10 @@ int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
 		req_capsule_filled_sizes(pill, RCL_CLIENT);
 		avail = ldlm_capsule_handles_avail(pill, RCL_CLIENT, canceloff);
 
-		lru_flags = LDLM_LRU_FLAG_NO_WAIT |
-			    (ns_connect_lru_resize(ns) ?
-			     LDLM_LRU_FLAG_LRUR : LDLM_LRU_FLAG_AGED);
-		to_free = !ns_connect_lru_resize(ns) &&
-			  opc == LDLM_ENQUEUE ? 1 : 0;
+		/* If we have reached the limit, free +1 slot for the new one */
+		if (!ns_connect_lru_resize(ns) && opc == LDLM_ENQUEUE &&
+		    ns->ns_nr_unused >= ns->ns_max_unused)
+			to_free = 1;
 
 		/*
 		 * Cancel LRU locks here _only_ if the server supports
@@ -632,7 +630,7 @@ int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
 		if (avail > count)
 			count += ldlm_cancel_lru_local(ns, cancels, to_free,
 						       avail - count, 0,
-						       lru_flags);
+						       LDLM_LRU_FLAG_NO_WAIT);
 		if (avail > count)
 			pack = count;
 		else
@@ -1216,7 +1214,6 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		    enum ldlm_cancel_flags cancel_flags)
 {
 	struct obd_export *exp;
-	enum ldlm_lru_flags lru_flags;
 	int avail, count = 1;
 	u64 rc = 0;
 	struct ldlm_namespace *ns;
@@ -1271,10 +1268,8 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		LASSERT(avail > 0);
 
 		ns = ldlm_lock_to_ns(lock);
-		lru_flags = ns_connect_lru_resize(ns) ?
-			    LDLM_LRU_FLAG_LRUR : LDLM_LRU_FLAG_AGED;
 		count += ldlm_cancel_lru_local(ns, &cancels, 0, avail - 1,
-					       LCF_BL_AST, lru_flags);
+					       LCF_BL_AST, 0);
 	}
 	ldlm_cli_cancel_list(&cancels, count, NULL, cancel_flags);
 	return 0;
@@ -1338,12 +1333,12 @@ int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
  */
 static enum ldlm_policy_res
 ldlm_cancel_no_wait_policy(struct ldlm_namespace *ns, struct ldlm_lock *lock,
-			   int unused, int added, int count)
+			   int added, int min)
 {
 	enum ldlm_policy_res result = LDLM_POLICY_CANCEL_LOCK;
 
 	/*
-	 * don't check added & count since we want to process all locks
+	 * don't check @added & @min since we want to process all locks
 	 * from unused list.
 	 * It's fine to not take lock to access lock->l_resource since
 	 * the lock has already been granted so it won't change.
@@ -1364,42 +1359,36 @@ int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
 
 /**
  * Callback function for LRU-resize policy. Decides whether to keep
- * @lock in LRU for current @LRU size @unused, added in current
- * scan @added and number of locks to be preferably canceled @count.
+ * @lock in LRU for @added in current scan and @min number of locks
+ * to be preferably canceled.
  *
  * Retun:	LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
  *		LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
  */
 static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 						    struct ldlm_lock *lock,
-						    int unused, int added,
-						    int count)
+						    int added, int min)
 {
 	ktime_t cur = ktime_get();
 	struct ldlm_pool *pl = &ns->ns_pool;
 	u64 slv, lvf, lv;
 	s64 la;
 
-	/*
-	 * Stop LRU processing when we reach past @count or have checked all
-	 * locks in LRU.
-	 */
-	if (count && added >= count)
-		return LDLM_POLICY_KEEP_LOCK;
+	if (added < min)
+		return LDLM_POLICY_CANCEL_LOCK;
 
 	/*
 	 * Despite of the LV, It doesn't make sense to keep the lock which
 	 * is unused for ns_max_age time.
 	 */
-	if (ktime_after(ktime_get(),
-			ktime_add(lock->l_last_used, ns->ns_max_age)))
+	if (ktime_after(cur, ktime_add(lock->l_last_used, ns->ns_max_age)))
 		return LDLM_POLICY_CANCEL_LOCK;
 
 	slv = ldlm_pool_get_slv(pl);
 	lvf = ldlm_pool_get_lvf(pl);
 	la = div_u64(ktime_to_ns(ktime_sub(cur, lock->l_last_used)),
 		     NSEC_PER_SEC);
-	lv = lvf * la * unused;
+	lv = lvf * la * ns->ns_nr_unused;
 
 	/* Inform pool about current CLV to see it via debugfs. */
 	ldlm_pool_set_clv(pl, lv);
@@ -1414,41 +1403,33 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 	return LDLM_POLICY_CANCEL_LOCK;
 }
 
-/**
- * Callback function for debugfs used policy. Makes decision whether to keep
- * @lock in LRU for current @LRU size @unused, added in current scan
- * @added and number of locks to be preferably canceled @count.
- *
- * Return:	LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
- *		LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
- */
-static enum ldlm_policy_res ldlm_cancel_passed_policy(struct ldlm_namespace *ns,
-						      struct ldlm_lock *lock,
-						      int unused, int added,
-						      int count)
+static enum ldlm_policy_res
+ldlm_cancel_lrur_no_wait_policy(struct ldlm_namespace *ns,
+				struct ldlm_lock *lock,
+				int added, int min)
 {
-	/*
-	 * Stop LRU processing when we reach past @count or have checked all
-	 * locks in LRU.
-	 */
-	return (added >= count) ?
-		LDLM_POLICY_KEEP_LOCK : LDLM_POLICY_CANCEL_LOCK;
+	enum ldlm_policy_res result;
+
+	result = ldlm_cancel_lrur_policy(ns, lock, added, min);
+	if (result == LDLM_POLICY_KEEP_LOCK)
+		return result;
+
+	return ldlm_cancel_no_wait_policy(ns, lock, added, min);
 }
 
 /**
- * Callback function for aged policy. Makes decision whether to keep @lock in
- * LRU for current LRU size @unused, added in current scan @added and
- * number of locks to be preferably canceled @count.
+ * Callback function for aged policy. Decides whether to keep
+ * @lock in LRU for @added in current scan and @min number of locks
+ * to be preferably canceled.
  *
  * Return:	LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
  *		LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
  */
 static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
 						    struct ldlm_lock *lock,
-						    int unused, int added,
-						    int count)
+						    int added, int min)
 {
-	if ((added >= count) &&
+	if ((added >= min) &&
 	    ktime_before(ktime_get(),
 			 ktime_add(lock->l_last_used, ns->ns_max_age)))
 		return LDLM_POLICY_KEEP_LOCK;
@@ -1457,90 +1438,41 @@ static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
 }
 
 static enum ldlm_policy_res
-ldlm_cancel_lrur_no_wait_policy(struct ldlm_namespace *ns,
-				struct ldlm_lock *lock,
-				int unused, int added,
-				int count)
-{
-	enum ldlm_policy_res result;
-
-	result = ldlm_cancel_lrur_policy(ns, lock, unused, added, count);
-	if (result == LDLM_POLICY_KEEP_LOCK)
-		return result;
-
-	return ldlm_cancel_no_wait_policy(ns, lock, unused, added, count);
-}
-
-static enum ldlm_policy_res
 ldlm_cancel_aged_no_wait_policy(struct ldlm_namespace *ns,
 				struct ldlm_lock *lock,
-				int unused, int added, int count)
+				int added, int min)
 {
 	enum ldlm_policy_res result;
 
-	result = ldlm_cancel_aged_policy(ns, lock, unused, added, count);
+	result = ldlm_cancel_aged_policy(ns, lock, added, min);
 	if (result == LDLM_POLICY_KEEP_LOCK)
 		return result;
 
-	return ldlm_cancel_no_wait_policy(ns, lock, unused, added, count);
-}
-
-/**
- * Callback function for default policy. Makes decision whether to keep @lock
- * in LRU for current LRU size @unused, added in current scan @added and
- * number of locks to be preferably canceled @count.
- *
- * Return:	LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
- *		LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
- */
-static enum ldlm_policy_res
-ldlm_cancel_default_policy(struct ldlm_namespace *ns, struct ldlm_lock *lock,
-			   int unused, int added, int count)
-{
-	/*
-	 * Stop LRU processing when we reach past count or have checked all
-	 * locks in LRU.
-	 */
-	return (added >= count) ?
-		LDLM_POLICY_KEEP_LOCK : LDLM_POLICY_CANCEL_LOCK;
+	return ldlm_cancel_no_wait_policy(ns, lock, added, min);
 }
 
-typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(struct ldlm_namespace *,
-							 struct ldlm_lock *,
-							 int, int, int);
+typedef enum ldlm_policy_res
+(*ldlm_cancel_lru_policy_t)(struct ldlm_namespace *ns, struct ldlm_lock *lock,
+			    int added, int min);
 
 static ldlm_cancel_lru_policy_t
 ldlm_cancel_lru_policy(struct ldlm_namespace *ns, enum ldlm_lru_flags lru_flags)
 {
 	if (ns_connect_lru_resize(ns)) {
-		if (lru_flags & LDLM_LRU_FLAG_SHRINK) {
-			/* We kill passed number of old locks. */
-			return ldlm_cancel_passed_policy;
-		} else if (lru_flags & LDLM_LRU_FLAG_LRUR) {
-			if (lru_flags & LDLM_LRU_FLAG_NO_WAIT)
-				return ldlm_cancel_lrur_no_wait_policy;
-			else
-				return ldlm_cancel_lrur_policy;
-		} else if (lru_flags & LDLM_LRU_FLAG_PASSED) {
-			return ldlm_cancel_passed_policy;
-		}
+		if (lru_flags & LDLM_LRU_FLAG_NO_WAIT)
+			return ldlm_cancel_lrur_no_wait_policy;
+		else
+			return ldlm_cancel_lrur_policy;
 	} else {
-		if (lru_flags & LDLM_LRU_FLAG_AGED) {
-			if (lru_flags & LDLM_LRU_FLAG_NO_WAIT)
-				return ldlm_cancel_aged_no_wait_policy;
-			else
-				return ldlm_cancel_aged_policy;
-		}
+		if (lru_flags & LDLM_LRU_FLAG_NO_WAIT)
+			return ldlm_cancel_aged_no_wait_policy;
+		else
+			return ldlm_cancel_aged_policy;
 	}
-
-	if (lru_flags & LDLM_LRU_FLAG_NO_WAIT)
-		return ldlm_cancel_no_wait_policy;
-
-	return ldlm_cancel_default_policy;
 }
 
 /**
- * - Free space in LRU for @count new locks,
+ * - Free space in LRU for @min new locks,
  *   redundant unused locks are canceled locally;
  * - also cancel locally unused aged locks;
  * - do not cancel more than @max locks;
@@ -1554,39 +1486,32 @@ typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(struct ldlm_namespace *
  * attempt to cancel a lock rely on this flag, l_bl_ast list is accessed
  * later without any special locking.
  *
- * Calling policies for enabled LRU resize:
- * ----------------------------------------
- * flags & LDLM_LRU_FLAG_LRUR	- use LRU resize policy (SLV from server) to
- *				  cancel not more than @count locks;
- *
- * flags & LDLM_LRU_FLAG_PASSED - cancel @count number of old locks (located
- *				  at the beginning of LRU list);
+ * Locks are cancelled according to the LRU resize policy (SLV from server)
+ * if LRU resize is enabled; otherwise, the "aged policy" is used;
  *
- * flags & LDLM_LRU_FLAG_SHRINK - cancel not more than @count locks according
- *				  to memory pressure policy function;
- *
- * flags & LDLM_LRU_FLAG_AGED   - cancel @count locks according to
- *				  "aged policy".
+ * LRU flags:
+ * ----------------------------------------
  *
- * flags & LDLM_LRU_FLAG_NO_WAIT - cancel as many unused locks as possible
- *				   (typically before replaying locks) w/o
- *				   sending any RPCs or waiting for any
- *				   outstanding RPC to complete.
+ * flags & LDLM_LRU_FLAG_NO_WAIT - cancel locks w/o sending any RPCs or waiting
+ *				   for any outstanding RPC to complete.
  *
  * flags & LDLM_CANCEL_CLEANUP - when cancelling read locks, do not check for
  *				 other read locks covering the same pages, just
  *				 discard those pages.
  */
 static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
-				 struct list_head *cancels, int count, int max,
+				 struct list_head *cancels,
+				 int min, int max,
 				 enum ldlm_lru_flags lru_flags)
 {
 	ldlm_cancel_lru_policy_t pf;
 	int added = 0;
 	int no_wait = lru_flags & LDLM_LRU_FLAG_NO_WAIT;
 
+	LASSERT(ergo(max, min <= max));
+
 	if (!ns_connect_lru_resize(ns))
-		count += ns->ns_nr_unused - ns->ns_max_unused;
+		min = max_t(int, min, ns->ns_nr_unused - ns->ns_max_unused);
 
 	pf = ldlm_cancel_lru_policy(ns, lru_flags);
 	LASSERT(pf);
@@ -1643,7 +1568,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		 * their weight. Big extent locks will stay in
 		 * the cache.
 		 */
-		result = pf(ns, lock, ns->ns_nr_unused, added, count);
+		result = pf(ns, lock, added, min);
 		if (result == LDLM_POLICY_KEEP_LOCK) {
 			lu_ref_del(&lock->l_reference, __func__, current);
 			LDLM_LOCK_RELEASE(lock);
@@ -1725,28 +1650,28 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 	return added;
 }
 
-int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
-			  struct list_head *cancels, int count, int max,
+int ldlm_cancel_lru_local(struct ldlm_namespace *ns, struct list_head *cancels,
+			  int min, int max,
 			  enum ldlm_cancel_flags cancel_flags,
 			  enum ldlm_lru_flags lru_flags)
 {
 	int added;
 
-	added = ldlm_prepare_lru_list(ns, cancels, count, max, lru_flags);
+	added = ldlm_prepare_lru_list(ns, cancels, min, max, lru_flags);
 	if (added <= 0)
 		return added;
 	return ldlm_cli_cancel_list_local(cancels, added, cancel_flags);
 }
 
 /**
- * Cancel at least @nr locks from given namespace LRU.
+ * Cancel@least @min locks from given namespace LRU.
  *
  * When called with LCF_ASYNC the blocking callback will be handled
  * in a thread and this function will return after the thread has been
  * asked to call the callback.  When called with LCF_ASYNC the blocking
  * callback will be performed in this function.
  */
-int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
+int ldlm_cancel_lru(struct ldlm_namespace *ns, int min,
 		    enum ldlm_cancel_flags cancel_flags,
 		    enum ldlm_lru_flags lru_flags)
 {
@@ -1757,7 +1682,7 @@ int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
 	 * Just prepare the list of locks, do not actually cancel them yet.
 	 * Locks are cancelled later in a separate thread.
 	 */
-	count = ldlm_prepare_lru_list(ns, &cancels, nr, 0, lru_flags);
+	count = ldlm_prepare_lru_list(ns, &cancels, min, 0, lru_flags);
 	rc = ldlm_bl_to_thread_list(ns, NULL, &cancels, count, cancel_flags);
 	if (rc == 0)
 		return count;
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index d0a59a8..4cf4358 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -191,17 +191,8 @@ static ssize_t lru_size_store(struct kobject *kobj, struct attribute *attr,
 		CDEBUG(D_DLMTRACE,
 		       "dropping all unused locks from namespace %s\n",
 		       ldlm_ns_name(ns));
-		if (ns_connect_lru_resize(ns)) {
-			ldlm_cancel_lru(ns, ns->ns_nr_unused, 0,
-					LDLM_LRU_FLAG_PASSED |
-					LDLM_LRU_FLAG_CLEANUP);
-		} else {
-			tmp = ns->ns_max_unused;
-			ns->ns_max_unused = 0;
-			ldlm_cancel_lru(ns, 0, 0, LDLM_LRU_FLAG_PASSED |
-					LDLM_LRU_FLAG_CLEANUP);
-			ns->ns_max_unused = tmp;
-		}
+		/* Try to cancel all @ns_nr_unused locks. */
+		ldlm_cancel_lru(ns, INT_MAX, 0, LDLM_LRU_FLAG_CLEANUP);
 		return count;
 	}
 
@@ -224,7 +215,6 @@ static ssize_t lru_size_store(struct kobject *kobj, struct attribute *attr,
 		       "changing namespace %s unused locks from %u to %u\n",
 		       ldlm_ns_name(ns), ns->ns_nr_unused,
 		       (unsigned int)tmp);
-		ldlm_cancel_lru(ns, tmp, LCF_ASYNC, LDLM_LRU_FLAG_PASSED);
 
 		if (!lru_resize) {
 			CDEBUG(D_DLMTRACE,
@@ -232,13 +222,12 @@ static ssize_t lru_size_store(struct kobject *kobj, struct attribute *attr,
 			       ldlm_ns_name(ns));
 			ns->ns_connect_flags &= ~OBD_CONNECT_LRU_RESIZE;
 		}
+		ldlm_cancel_lru(ns, tmp, LCF_ASYNC, 0);
 	} else {
 		CDEBUG(D_DLMTRACE,
 		       "changing namespace %s max_unused from %u to %u\n",
 		       ldlm_ns_name(ns), ns->ns_max_unused,
 		       (unsigned int)tmp);
-		ns->ns_max_unused = (unsigned int)tmp;
-		ldlm_cancel_lru(ns, 0, LCF_ASYNC, LDLM_LRU_FLAG_PASSED);
 
 		/* Make sure that LRU resize was originally supported before
 		 * turning it on here.
@@ -250,6 +239,8 @@ static ssize_t lru_size_store(struct kobject *kobj, struct attribute *attr,
 			       ldlm_ns_name(ns));
 			ns->ns_connect_flags |= OBD_CONNECT_LRU_RESIZE;
 		}
+		ns->ns_max_unused = (unsigned int)tmp;
+		ldlm_cancel_lru(ns, 0, LCF_ASYNC, 0);
 	}
 
 	return count;
-- 
1.8.3.1
