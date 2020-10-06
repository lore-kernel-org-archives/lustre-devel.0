From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:12 -0400
Subject: [lustre-devel] [PATCH 33/42] lustre: ldlm: control lru_size for
 extent lock
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@uber.com>

We register ELC for extent locks to be canceled at enqueue time,
but it can't make positive effect to locks that have dirty pages
under it. To keep the semantics of lru_size, the client should
check how many unused locks are cached after adding a lock into
lru list. If it has already exceeded the hard limit
(ns_max_unused), the client will initiate async lock cancellation
process in batch mode (ns->ns_cancel_batch).

To do it, re-use the new batching LRU cancel functionality.

Wherever unlimited LRU cancel is called (not ELC), try to cancel in
batched mode.

And a new field named new sysfs attribute named *lru_cancel_batch*
is introduced into ldlm namespace to control the batch count.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11518
Lustre-commit: 6052cc88eb1232 ("LU-11518 ldlm: control lru_size for extent lock")
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Shuichi Ihara <sihara@ddn.com>
Signed-off-by: Gu Zheng <gzheng@ddn.com>
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Reviewed-on: https://review.whamcloud.com/39562
Reviewed-on: https://es-gerrit.dev.cray.com/157068
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h |  7 +++++++
 fs/lustre/ldlm/ldlm_lock.c     | 17 +++++++----------
 fs/lustre/ldlm/ldlm_request.c  |  3 ++-
 fs/lustre/ldlm/ldlm_resource.c | 28 ++++++++++++++++++++++++++++
 4 files changed, 44 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 871d4ff..682035a 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -65,6 +65,7 @@
  */
 #define LDLM_DIRTY_AGE_LIMIT (10)
 #define LDLM_DEFAULT_PARALLEL_AST_LIMIT 1024
+#define LDLM_DEFAULT_LRU_SHRINK_BATCH (16)
 
 /**
  * LDLM non-error return states
@@ -423,6 +424,12 @@ struct ldlm_namespace {
 	 */
 	unsigned int		ns_max_unused;
 
+	/**
+	 * Cancel batch, if unused lock count exceed lru_size
+	 * Only be used if LRUR disable.
+	 */
+	unsigned int		ns_cancel_batch;
+
 	/** Maximum allowed age (last used time) for locks in the LRU. Set in
 	 * seconds from userspace, but stored in ns to avoid repeat conversions.
 	 */
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index f5dedc9..2931873 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -776,10 +776,14 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
 	}
 
 	if (!lock->l_readers && !lock->l_writers && ldlm_is_cbpending(lock)) {
+		unsigned int mask = D_DLMTRACE;
+
 		/* If we received a blocked AST and this was the last reference,
 		 * run the callback.
 		 */
-		LDLM_DEBUG(lock, "final decref done on cbpending lock");
+		LDLM_DEBUG_LIMIT(mask, lock,
+				 "final decref done on %sCBPENDING lock",
+				 mask & D_WARNING ? "non-local " : "");
 
 		LDLM_LOCK_GET(lock); /* dropped by bl thread */
 		ldlm_lock_remove_from_lru(lock);
@@ -794,24 +798,17 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
 	} else if (!lock->l_readers && !lock->l_writers &&
 		   !ldlm_is_no_lru(lock) && !ldlm_is_bl_ast(lock) &&
 		   !ldlm_is_converting(lock)) {
-		LDLM_DEBUG(lock, "add lock into lru list");
-
 		/* If this is a client-side namespace and this was the last
 		 * reference, put it on the LRU.
 		 */
 		ldlm_lock_add_to_lru(lock);
 		unlock_res_and_lock(lock);
+		LDLM_DEBUG(lock, "add lock into lru list");
 
 		if (ldlm_is_fail_loc(lock))
 			OBD_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
 
-		/* Call ldlm_cancel_lru() only if EARLY_CANCEL and LRU RESIZE
-		 * are not supported by the server, otherwise, it is done on
-		 * enqueue.
-		 */
-		if (!exp_connect_cancelset(lock->l_conn_export) &&
-		    !ns_connect_lru_resize(ns))
-			ldlm_cancel_lru(ns, 0, LCF_ASYNC, 0);
+		ldlm_cancel_lru(ns, 0, LCF_ASYNC, 0);
 	} else {
 		LDLM_DEBUG(lock, "do not add lock into lru list");
 		unlock_res_and_lock(lock);
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 901e505..c235915 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1709,7 +1709,8 @@ int ldlm_cancel_lru(struct ldlm_namespace *ns, int min,
 	 * Just prepare the list of locks, do not actually cancel them yet.
 	 * Locks are cancelled later in a separate thread.
 	 */
-	count = ldlm_prepare_lru_list(ns, &cancels, min, 0, 0, lru_flags);
+	count = ldlm_prepare_lru_list(ns, &cancels, min, 0,
+				      ns->ns_cancel_batch, lru_flags);
 	rc = ldlm_bl_to_thread_list(ns, NULL, &cancels, count, cancel_flags);
 	if (rc == 0)
 		return count;
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 31e7513..3527e15 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -247,6 +247,32 @@ static ssize_t lru_size_store(struct kobject *kobj, struct attribute *attr,
 }
 LUSTRE_RW_ATTR(lru_size);
 
+static ssize_t lru_cancel_batch_show(struct kobject *kobj,
+				     struct attribute *attr, char *buf)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+
+	return scnprintf(buf, sizeof(buf) - 1, "%u\n", ns->ns_cancel_batch);
+}
+
+static ssize_t lru_cancel_batch_store(struct kobject *kobj,
+				      struct attribute *attr,
+				      const char *buffer, size_t count)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+	unsigned long tmp;
+
+	if (kstrtoul(buffer, 10, &tmp))
+		return -EINVAL;
+
+	ns->ns_cancel_batch = (unsigned int)tmp;
+
+	return count;
+}
+LUSTRE_RW_ATTR(lru_cancel_batch);
+
 static ssize_t lru_max_age_show(struct kobject *kobj, struct attribute *attr,
 				char *buf)
 {
@@ -350,6 +376,7 @@ static ssize_t dirty_age_limit_store(struct kobject *kobj,
 	&lustre_attr_lock_count.attr,
 	&lustre_attr_lock_unused_count.attr,
 	&lustre_attr_lru_size.attr,
+	&lustre_attr_lru_cancel_batch.attr,
 	&lustre_attr_lru_max_age.attr,
 	&lustre_attr_early_lock_cancel.attr,
 	&lustre_attr_dirty_age_limit.attr,
@@ -635,6 +662,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	ns->ns_max_parallel_ast = LDLM_DEFAULT_PARALLEL_AST_LIMIT;
 	ns->ns_nr_unused = 0;
 	ns->ns_max_unused = LDLM_DEFAULT_LRU_SIZE;
+	ns->ns_cancel_batch = LDLM_DEFAULT_LRU_SHRINK_BATCH;
 	ns->ns_max_age = ktime_set(LDLM_DEFAULT_MAX_ALIVE, 0);
 	ns->ns_orig_connect_flags = 0;
 	ns->ns_connect_flags = 0;
-- 
1.8.3.1
