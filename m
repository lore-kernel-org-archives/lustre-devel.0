From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:29 -0500
Subject: [lustre-devel] [PATCH 401/622] lustre: ldlm: always cancel aged
 locks regardless enabling or disabling lru resize
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-402-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Gu Zheng <gzheng@ddn.com>

Currently cancelling aged locks is handled by of ldlm_pool_recalc routine,
and it only works when lru resize is enabled, means if we disabled lru
resize, old aged locks are still cached even though they reach the
ns_max_age.

But theoretically, even lru resize disabled, lru_max_age should behave
same as enabling lru resize. At the end, lru_size is like hard limit of
number of locks, but ns_max_age/lru_max_age is a elimination mechanism,
regardless enabling or disabling lru resize meaning once it gets
lru_max_age, locks need to be cancelled.

So fix it here with changing the lru flags when invoking ldlm_cancel_lru
to do the real cancel work, if lru resize is enabled, set flag to
LDLM_LRU_FLAG_LRUR, otherwise LDLM_LRU_FLAG_AGED.

Change lru_flags into a proper enum

WC-bug-id: https://jira.whamcloud.com/browse/LU-11672
Lustre-commit: e4c490bac770 ("LU-11672 ldlm: awalys cancel aged locks regardless enabling or disabling lru resize")
Signed-off-by: Gu Zheng <gzheng@ddn.com>
Reviewed-on: https://review.whamcloud.com/35467
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_internal.h |  8 +++++---
 fs/lustre/ldlm/ldlm_pool.c     | 14 +++++++-------
 fs/lustre/ldlm/ldlm_request.c  | 40 ++++++++++++++++++++++------------------
 3 files changed, 34 insertions(+), 28 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index 3789496..4844a9b 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -87,7 +87,7 @@ void ldlm_namespace_move_to_inactive_locked(struct ldlm_namespace *ns,
 
 /* ldlm_request.c */
 /* Cancel lru flag, it indicates we cancel aged locks. */
-enum {
+enum ldlm_lru_flags {
 	LDLM_LRU_FLAG_AGED	= BIT(0), /* Cancel old non-LRU resize locks */
 	LDLM_LRU_FLAG_PASSED	= BIT(1), /* Cancel passed number of locks. */
 	LDLM_LRU_FLAG_SHRINK	= BIT(2), /* Cancel locks from shrinker. */
@@ -104,10 +104,12 @@ enum {
 };
 
 int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
-		    enum ldlm_cancel_flags sync, int flags);
+		    enum ldlm_cancel_flags cancel_flags,
+		    enum ldlm_lru_flags lru_flags);
 int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
 			  struct list_head *cancels, int count, int max,
-			  enum ldlm_cancel_flags cancel_flags, int flags);
+			  enum ldlm_cancel_flags cancel_flags,
+			  enum ldlm_lru_flags lru_flags);
 extern unsigned int ldlm_enqueue_min;
 extern unsigned int ldlm_cancel_unused_locks_before_replay;
 
diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index b2b3ead..9185dc93 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -255,6 +255,7 @@ static void ldlm_cli_pool_pop_slv(struct ldlm_pool *pl)
 static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
 {
 	time64_t recalc_interval_sec;
+	enum ldlm_lru_flags lru_flags;
 	int ret;
 
 	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
@@ -279,13 +280,13 @@ static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
 	spin_unlock(&pl->pl_lock);
 
 	/*
-	 * Do not cancel locks in case lru resize is disabled for this ns.
+	 * Cancel aged locks if lru resize is disabled for this ns.
 	 */
 	if (!ns_connect_lru_resize(container_of(pl, struct ldlm_namespace,
-						ns_pool))) {
-		ret = 0;
-		goto out;
-	}
+						ns_pool)))
+		lru_flags = LDLM_LRU_FLAG_LRUR;
+	else
+		lru_flags = LDLM_LRU_FLAG_AGED;
 
 	/*
 	 * In the time of canceling locks on client we do not need to maintain
@@ -294,9 +295,8 @@ static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
 	 * take into account pl->pl_recalc_time here.
 	 */
 	ret = ldlm_cancel_lru(container_of(pl, struct ldlm_namespace, ns_pool),
-			      0, LCF_ASYNC, LDLM_LRU_FLAG_LRUR);
+			      0, LCF_ASYNC, lru_flags);
 
-out:
 	spin_lock(&pl->pl_lock);
 	/*
 	 * Time of LRU resizing might be longer than period,
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 5a7026d..75492f6 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -590,7 +590,8 @@ int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
 	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
 	struct req_capsule *pill = &req->rq_pill;
 	struct ldlm_request *dlm = NULL;
-	int flags, avail, to_free, pack = 0;
+	enum ldlm_lru_flags lru_flags;
+	int avail, to_free, pack = 0;
 	LIST_HEAD(head);
 	int rc;
 
@@ -601,9 +602,9 @@ int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
 		req_capsule_filled_sizes(pill, RCL_CLIENT);
 		avail = ldlm_capsule_handles_avail(pill, RCL_CLIENT, canceloff);
 
-		flags = LDLM_LRU_FLAG_NO_WAIT |
-			(ns_connect_lru_resize(ns) ?
-			 LDLM_LRU_FLAG_LRUR : LDLM_LRU_FLAG_AGED);
+		lru_flags = LDLM_LRU_FLAG_NO_WAIT |
+			    (ns_connect_lru_resize(ns) ?
+			     LDLM_LRU_FLAG_LRUR : LDLM_LRU_FLAG_AGED);
 		to_free = !ns_connect_lru_resize(ns) &&
 			  opc == LDLM_ENQUEUE ? 1 : 0;
 
@@ -614,7 +615,8 @@ int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
 		 */
 		if (avail > count)
 			count += ldlm_cancel_lru_local(ns, cancels, to_free,
-						       avail - count, 0, flags);
+						       avail - count, 0,
+						       lru_flags);
 		if (avail > count)
 			pack = count;
 		else
@@ -1279,7 +1281,8 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		    enum ldlm_cancel_flags cancel_flags)
 {
 	struct obd_export *exp;
-	int avail, flags, count = 1;
+	enum ldlm_lru_flags lru_flags;
+	int avail, count = 1;
 	u64 rc = 0;
 	struct ldlm_namespace *ns;
 	struct ldlm_lock *lock;
@@ -1354,10 +1357,10 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		LASSERT(avail > 0);
 
 		ns = ldlm_lock_to_ns(lock);
-		flags = ns_connect_lru_resize(ns) ?
-			LDLM_LRU_FLAG_LRUR : LDLM_LRU_FLAG_AGED;
+		lru_flags = ns_connect_lru_resize(ns) ?
+			    LDLM_LRU_FLAG_LRUR : LDLM_LRU_FLAG_AGED;
 		count += ldlm_cancel_lru_local(ns, &cancels, 0, avail - 1,
-					       LCF_BL_AST, flags);
+					       LCF_BL_AST, lru_flags);
 	}
 	ldlm_cli_cancel_list(&cancels, count, NULL, cancel_flags);
 	return 0;
@@ -1593,7 +1596,7 @@ typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(struct ldlm_namespace *
 							 int, int, int);
 
 static ldlm_cancel_lru_policy_t
-ldlm_cancel_lru_policy(struct ldlm_namespace *ns, int lru_flags)
+ldlm_cancel_lru_policy(struct ldlm_namespace *ns, enum ldlm_lru_flags lru_flags)
 {
 	if (ns_connect_lru_resize(ns)) {
 		if (lru_flags & LDLM_LRU_FLAG_SHRINK) {
@@ -1662,16 +1665,16 @@ typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(struct ldlm_namespace *
  */
 static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 				 struct list_head *cancels, int count, int max,
-				 int flags)
+				 enum ldlm_lru_flags lru_flags)
 {
 	ldlm_cancel_lru_policy_t pf;
 	int added = 0;
-	int no_wait = flags & LDLM_LRU_FLAG_NO_WAIT;
+	int no_wait = lru_flags & LDLM_LRU_FLAG_NO_WAIT;
 
 	if (!ns_connect_lru_resize(ns))
 		count += ns->ns_nr_unused - ns->ns_max_unused;
 
-	pf = ldlm_cancel_lru_policy(ns, flags);
+	pf = ldlm_cancel_lru_policy(ns, lru_flags);
 	LASSERT(pf);
 
 	/* For any flags, stop scanning if @max is reached. */
@@ -1787,7 +1790,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		 */
 		lock->l_flags |= LDLM_FL_CBPENDING | LDLM_FL_CANCELING;
 
-		if ((flags & LDLM_LRU_FLAG_CLEANUP) &&
+		if ((lru_flags & LDLM_LRU_FLAG_CLEANUP) &&
 		    (lock->l_resource->lr_type == LDLM_EXTENT ||
 		     ldlm_has_dom(lock)) && lock->l_granted_mode == LCK_PR)
 			ldlm_set_discard_data(lock);
@@ -1811,11 +1814,12 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 
 int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
 			  struct list_head *cancels, int count, int max,
-			  enum ldlm_cancel_flags cancel_flags, int flags)
+			  enum ldlm_cancel_flags cancel_flags,
+			  enum ldlm_lru_flags lru_flags)
 {
 	int added;
 
-	added = ldlm_prepare_lru_list(ns, cancels, count, max, flags);
+	added = ldlm_prepare_lru_list(ns, cancels, count, max, lru_flags);
 	if (added <= 0)
 		return added;
 	return ldlm_cli_cancel_list_local(cancels, added, cancel_flags);
@@ -1831,7 +1835,7 @@ int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
  */
 int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
 		    enum ldlm_cancel_flags cancel_flags,
-		    int flags)
+		    enum ldlm_lru_flags lru_flags)
 {
 	LIST_HEAD(cancels);
 	int count, rc;
@@ -1840,7 +1844,7 @@ int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
 	 * Just prepare the list of locks, do not actually cancel them yet.
 	 * Locks are cancelled later in a separate thread.
 	 */
-	count = ldlm_prepare_lru_list(ns, &cancels, nr, 0, flags);
+	count = ldlm_prepare_lru_list(ns, &cancels, nr, 0, lru_flags);
 	rc = ldlm_bl_to_thread_list(ns, NULL, &cancels, count, cancel_flags);
 	if (rc == 0)
 		return count;
-- 
1.8.3.1
