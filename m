From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:50 -0400
Subject: [lustre-devel] [PATCH 11/42] lustre: ldlm: cancel LRU improvement
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vitaly Fertman <c17818@cray.com>

Add @batch parameter to cancel LRU, which means if at least 1 lock is
cancelled, try to cancel at least a batch locks. This functionality
will be used in later patches.

Limit the LRU cancel by 1 thread only, however, not for those which
have the @max limit given (ELC), as LRU may be left not cleaned up
in full.

HPE-bug-id: LUS-8678
WC-bug-id: https://jira.whamcloud.com/browse/LU-11518
Lustre-commit: 3d4b5dacb3053 ("LU-11518 ldlm: cancel LRU improvement")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Reviewed-on: https://es-gerrit.dev.cray.com/157067
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Tested-by: Alexander Lezhoev <c17454@cray.com>
Reviewed-on: https://review.whamcloud.com/39561
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h | 13 +++++++++++++
 fs/lustre/ldlm/ldlm_request.c  | 33 ++++++++++++++++++++++++++++++---
 fs/lustre/ldlm/ldlm_resource.c |  1 +
 3 files changed, 44 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 28e766b..e2a7b6b 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -333,6 +333,14 @@ enum ldlm_ns_type {
 	LDLM_NS_TYPE_MGT,
 };
 
+enum ldlm_namespace_flags {
+	/**
+	 * Flag to indicate the LRU cancel is in progress.
+	 * Used to limit the process by 1 thread only.
+	 */
+	LDLM_LRU_CANCEL = 0
+};
+
 /**
  * LDLM Namespace.
  *
@@ -476,6 +484,11 @@ struct ldlm_namespace {
 
 	struct kobject		ns_kobj; /* sysfs object */
 	struct completion	ns_kobj_unregister;
+
+	/**
+	 * To avoid another ns_lock usage, a separate bitops field.
+	 */
+	unsigned long		ns_flags;
 };
 
 /**
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 4bd7372..901e505 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1476,6 +1476,7 @@ static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
  *   redundant unused locks are canceled locally;
  * - also cancel locally unused aged locks;
  * - do not cancel more than @max locks;
+ * - if some locks are cancelled, try to cancel at least @batch locks
  * - GET the found locks and add them into the @cancels list.
  *
  * A client lock can be added to the l_bl_ast list only when it is
@@ -1501,18 +1502,37 @@ static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
  */
 static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 				 struct list_head *cancels,
-				 int min, int max,
+				 int min, int max, int batch,
 				 enum ldlm_lru_flags lru_flags)
 {
 	ldlm_cancel_lru_policy_t pf;
 	int added = 0;
 	int no_wait = lru_flags & LDLM_LRU_FLAG_NO_WAIT;
 
+	/*
+	 * Let only 1 thread to proceed. However, not for those which have the
+	 * @max limit given (ELC), as LRU may be left not cleaned up in full.
+	 */
+	if (max == 0) {
+		if (test_and_set_bit(LDLM_LRU_CANCEL, &ns->ns_flags))
+			return 0;
+	} else if (test_bit(LDLM_LRU_CANCEL, &ns->ns_flags)) {
+		return 0;
+	}
+
 	LASSERT(ergo(max, min <= max));
+	/* No sense to give @batch for ELC */
+	LASSERT(ergo(max, batch == 0));
 
 	if (!ns_connect_lru_resize(ns))
 		min = max_t(int, min, ns->ns_nr_unused - ns->ns_max_unused);
 
+	/* If at least 1 lock is to be cancelled, cancel at least @batch
+	 * locks
+	 */
+	if (min && min < batch)
+		min = batch;
+
 	pf = ldlm_cancel_lru_policy(ns, lru_flags);
 	LASSERT(pf);
 
@@ -1646,7 +1666,14 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		unlock_res_and_lock(lock);
 		lu_ref_del(&lock->l_reference, __func__, current);
 		added++;
+		/* Once a lock added, batch the requested amount */
+		if (min == 0)
+			min = batch;
 	}
+
+	if (max == 0)
+		clear_bit(LDLM_LRU_CANCEL, &ns->ns_flags);
+
 	return added;
 }
 
@@ -1657,7 +1684,7 @@ int ldlm_cancel_lru_local(struct ldlm_namespace *ns, struct list_head *cancels,
 {
 	int added;
 
-	added = ldlm_prepare_lru_list(ns, cancels, min, max, lru_flags);
+	added = ldlm_prepare_lru_list(ns, cancels, min, max, 0, lru_flags);
 	if (added <= 0)
 		return added;
 	return ldlm_cli_cancel_list_local(cancels, added, cancel_flags);
@@ -1682,7 +1709,7 @@ int ldlm_cancel_lru(struct ldlm_namespace *ns, int min,
 	 * Just prepare the list of locks, do not actually cancel them yet.
 	 * Locks are cancelled later in a separate thread.
 	 */
-	count = ldlm_prepare_lru_list(ns, &cancels, min, 0, lru_flags);
+	count = ldlm_prepare_lru_list(ns, &cancels, min, 0, 0, lru_flags);
 	rc = ldlm_bl_to_thread_list(ns, NULL, &cancels, count, cancel_flags);
 	if (rc == 0)
 		return count;
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 4cf4358..31e7513 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -641,6 +641,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	ns->ns_dirty_age_limit = ktime_set(LDLM_DIRTY_AGE_LIMIT, 0);
 	ns->ns_stopping = 0;
 	ns->ns_last_pos = &ns->ns_unused_list;
+	ns->ns_flags = 0;
 
 	rc = ldlm_namespace_sysfs_register(ns);
 	if (rc != 0) {
-- 
1.8.3.1
