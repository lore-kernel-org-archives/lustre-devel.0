From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:48:13 -0400
Subject: [lustre-devel] [PATCH 41/43] staging/lustre/ldlm: ELC picks locks
	in a safer policy
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-42-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Change the policy of ELC to pick locks that have no dirty pages,
no page in writeback state, and no locked pages.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/9175
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4300
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 13 ++++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 28 +++++++++++++++-------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  4 ++--
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  4 +++-
 drivers/staging/lustre/lustre/osc/osc_request.c    | 19 ++++++---------
 5 files changed, 39 insertions(+), 29 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index b1abdc2..9cade14 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -270,7 +270,7 @@ struct ldlm_pool {
 	struct completion	 pl_kobj_unregister;
 };
 
-typedef int (*ldlm_cancel_for_recovery)(struct ldlm_lock *lock);
+typedef int (*ldlm_cancel_cbt)(struct ldlm_lock *lock);
 
 /**
  * LVB operations.
@@ -447,8 +447,11 @@ struct ldlm_namespace {
 	/** Limit of parallel AST RPC count. */
 	unsigned		ns_max_parallel_ast;
 
-	/** Callback to cancel locks before replaying it during recovery. */
-	ldlm_cancel_for_recovery ns_cancel_for_recovery;
+	/**
+	 * Callback to check if a lock is good to be canceled by ELC or
+	 * during recovery.
+	 */
+	ldlm_cancel_cbt		ns_cancel;
 
 	/** LDLM lock stats */
 	struct lprocfs_stats	*ns_stats;
@@ -480,9 +483,9 @@ static inline int ns_connect_lru_resize(struct ldlm_namespace *ns)
 }
 
 static inline void ns_register_cancel(struct ldlm_namespace *ns,
-				      ldlm_cancel_for_recovery arg)
+				      ldlm_cancel_cbt arg)
 {
-	ns->ns_cancel_for_recovery = arg;
+	ns->ns_cancel = arg;
 }
 
 struct ldlm_lock;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 42925ac..2f12194 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1137,7 +1137,6 @@ static ldlm_policy_res_t ldlm_cancel_no_wait_policy(struct ldlm_namespace *ns,
 						    int count)
 {
 	ldlm_policy_res_t result = LDLM_POLICY_CANCEL_LOCK;
-	ldlm_cancel_for_recovery cb = ns->ns_cancel_for_recovery;
 
 	/* don't check added & count since we want to process all locks
 	 * from unused list.
@@ -1147,7 +1146,7 @@ static ldlm_policy_res_t ldlm_cancel_no_wait_policy(struct ldlm_namespace *ns,
 	switch (lock->l_resource->lr_type) {
 	case LDLM_EXTENT:
 	case LDLM_IBITS:
-		if (cb && cb(lock))
+			if (ns->ns_cancel && ns->ns_cancel(lock) != 0)
 			break;
 	default:
 		result = LDLM_POLICY_SKIP_LOCK;
@@ -1197,8 +1196,13 @@ static ldlm_policy_res_t ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 	/* Stop when SLV is not yet come from server or lv is smaller than
 	 * it is.
 	 */
-	return (slv == 0 || lv < slv) ?
-		LDLM_POLICY_KEEP_LOCK : LDLM_POLICY_CANCEL_LOCK;
+	if (slv == 0 || lv < slv)
+		return LDLM_POLICY_KEEP_LOCK;
+
+	if (ns->ns_cancel && ns->ns_cancel(lock) == 0)
+		return LDLM_POLICY_KEEP_LOCK;
+
+	return LDLM_POLICY_CANCEL_LOCK;
 }
 
 /**
@@ -1236,11 +1240,17 @@ static ldlm_policy_res_t ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
 						 int unused, int added,
 						 int count)
 {
-	/* Stop LRU processing if young lock is found and we reach past count */
-	return ((added >= count) &&
-		time_before(cfs_time_current(),
-			    cfs_time_add(lock->l_last_used, ns->ns_max_age))) ?
-		LDLM_POLICY_KEEP_LOCK : LDLM_POLICY_CANCEL_LOCK;
+	if (added >= count)
+		return LDLM_POLICY_KEEP_LOCK;
+
+	if (time_before(cfs_time_current(),
+			cfs_time_add(lock->l_last_used, ns->ns_max_age)))
+		return LDLM_POLICY_KEEP_LOCK;
+
+	if (ns->ns_cancel && ns->ns_cancel(lock) == 0)
+		return LDLM_POLICY_KEEP_LOCK;
+
+	return LDLM_POLICY_CANCEL_LOCK;
 }
 
 /**
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 55dd8ef..98b27f1 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2249,7 +2249,7 @@ static struct obd_uuid *mdc_get_uuid(struct obd_export *exp)
  * recovery, non zero value will be return if the lock can be canceled,
  * or zero returned for not
  */
-static int mdc_cancel_for_recovery(struct ldlm_lock *lock)
+static int mdc_cancel_weight(struct ldlm_lock *lock)
 {
 	if (lock->l_resource->lr_type != LDLM_IBITS)
 		return 0;
@@ -2331,7 +2331,7 @@ static int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 	sptlrpc_lprocfs_cliobd_attach(obd);
 	ptlrpc_lprocfs_register_obd(obd);
 
-	ns_register_cancel(obd->obd_namespace, mdc_cancel_for_recovery);
+	ns_register_cancel(obd->obd_namespace, mdc_cancel_weight);
 
 	obd->obd_namespace->ns_lvbo = &inode_lvbo;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 68c5013..49dfe9f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -635,7 +635,9 @@ static int weigh_cb(const struct lu_env *env, struct cl_io *io,
 {
 	struct cl_page *page = ops->ops_cl.cpl_page;
 
-	if (cl_page_is_vmlocked(env, page)) {
+	if (cl_page_is_vmlocked(env, page) ||
+	    PageDirty(page->cp_vmpage) || PageWriteback(page->cp_vmpage)
+	   ) {
 		(*(unsigned long *)cbdata)++;
 		return CLP_GANG_ABORT;
 	}
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 368b997..a6dc517 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2292,15 +2292,13 @@ no_match:
 	if (*flags & LDLM_FL_TEST_LOCK)
 		return -ENOLCK;
 	if (intent) {
-		LIST_HEAD(cancels);
-
 		req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 					   &RQF_LDLM_ENQUEUE_LVB);
 		if (!req)
 			return -ENOMEM;
 
-		rc = ldlm_prep_enqueue_req(exp, req, &cancels, 0);
-		if (rc) {
+		rc = ptlrpc_request_pack(req, LUSTRE_DLM_VERSION, LDLM_ENQUEUE);
+		if (rc < 0) {
 			ptlrpc_request_free(req);
 			return rc;
 		}
@@ -3110,17 +3108,14 @@ static int osc_import_event(struct obd_device *obd,
  * \retval zero the lock can't be canceled
  * \retval other ok to cancel
  */
-static int osc_cancel_for_recovery(struct ldlm_lock *lock)
+static int osc_cancel_weight(struct ldlm_lock *lock)
 {
 	/*
-	 * Cancel all unused extent lock in granted mode LCK_PR or LCK_CR.
-	 *
-	 * XXX as a future improvement, we can also cancel unused write lock
-	 * if it doesn't have dirty data and active mmaps.
+	 * Cancel all unused and granted extent lock.
 	 */
 	if (lock->l_resource->lr_type == LDLM_EXTENT &&
-	    (lock->l_granted_mode == LCK_PR ||
-	     lock->l_granted_mode == LCK_CR) && osc_ldlm_weigh_ast(lock) == 0)
+	    lock->l_granted_mode == lock->l_req_mode &&
+	    osc_ldlm_weigh_ast(lock) == 0)
 		return 1;
 
 	return 0;
@@ -3197,7 +3192,7 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	}
 
 	INIT_LIST_HEAD(&cli->cl_grant_shrink_list);
-	ns_register_cancel(obd->obd_namespace, osc_cancel_for_recovery);
+	ns_register_cancel(obd->obd_namespace, osc_cancel_weight);
 	return rc;
 
 out_ptlrpcd_work:
-- 
2.1.0
