From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:30 -0500
Subject: [lustre-devel] [PATCH 042/622] lustre: ldlm: speed up preparation
 for list of lock cancel
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-43-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Yang Sheng <ys@whamcloud.com>

Keep the skipped locks in lru list will cause serious
contention for ns_lock. Since we have to travel them
every time in the ldlm_prepare_lru_list(). So we will
use a cursor to record position that last accessed
lock in lru list.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9230
Lustre-commit: 651f2cdd2d8d ("LU-9230 ldlm: speed up preparation for list of lock cancel")
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Signed-off-by: Sergey Cheremencev <c17829@cray.com>
Reviewed-on: https://review.whamcloud.com/26327
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h       |  1 +
 fs/lustre/include/lustre_dlm_flags.h |  9 -----
 fs/lustre/ldlm/ldlm_lock.c           |  3 +-
 fs/lustre/ldlm/ldlm_request.c        | 72 ++++++++++++++++--------------------
 fs/lustre/ldlm/ldlm_resource.c       |  1 +
 5 files changed, 35 insertions(+), 51 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 66608a9..1a19b35 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -406,6 +406,7 @@ struct ldlm_namespace {
 	struct list_head	ns_unused_list;
 	/** Number of locks in the LRU list above */
 	int			ns_nr_unused;
+	struct list_head	*ns_last_pos;
 
 	/**
 	 * Maximum number of locks permitted in the LRU. If 0, means locks
diff --git a/fs/lustre/include/lustre_dlm_flags.h b/fs/lustre/include/lustre_dlm_flags.h
index c8667c8..3d69c49 100644
--- a/fs/lustre/include/lustre_dlm_flags.h
+++ b/fs/lustre/include/lustre_dlm_flags.h
@@ -200,15 +200,6 @@
 #define ldlm_set_fail_loc(_l)		LDLM_SET_FLAG((_l), 1ULL << 32)
 #define ldlm_clear_fail_loc(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 32)
 
-/**
- * Used while processing the unused list to know that we have already
- * handled this lock and decided to skip it.
- */
-#define LDLM_FL_SKIPPED			0x0000000200000000ULL /* bit 33 */
-#define ldlm_is_skipped(_l)		LDLM_TEST_FLAG((_l), 1ULL << 33)
-#define ldlm_set_skipped(_l)		LDLM_SET_FLAG((_l), 1ULL << 33)
-#define ldlm_clear_skipped(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 33)
-
 /** this lock is being destroyed */
 #define LDLM_FL_CBPENDING		0x0000000400000000ULL /* bit 34 */
 #define ldlm_is_cbpending(_l)		LDLM_TEST_FLAG((_l), 1ULL << 34)
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 9847c43..894b99b 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -204,6 +204,8 @@ int ldlm_lock_remove_from_lru_nolock(struct ldlm_lock *lock)
 		struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
 
 		LASSERT(lock->l_resource->lr_type != LDLM_FLOCK);
+		if (ns->ns_last_pos == &lock->l_lru)
+			ns->ns_last_pos = lock->l_lru.prev;
 		list_del_init(&lock->l_lru);
 		LASSERT(ns->ns_nr_unused > 0);
 		ns->ns_nr_unused--;
@@ -249,7 +251,6 @@ void ldlm_lock_add_to_lru_nolock(struct ldlm_lock *lock)
 	LASSERT(list_empty(&lock->l_lru));
 	LASSERT(lock->l_resource->lr_type != LDLM_FLOCK);
 	list_add_tail(&lock->l_lru, &ns->ns_unused_list);
-	ldlm_clear_skipped(lock);
 	LASSERT(ns->ns_nr_unused >= 0);
 	ns->ns_nr_unused++;
 }
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 5ec0da5..dd4d958 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1368,9 +1368,6 @@ int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
 		/* fall through */
 	default:
 		result = LDLM_POLICY_SKIP_LOCK;
-		lock_res_and_lock(lock);
-		ldlm_set_skipped(lock);
-		unlock_res_and_lock(lock);
 		break;
 	}
 
@@ -1592,54 +1589,47 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 				 int flags)
 {
 	ldlm_cancel_lru_policy_t pf;
-	struct ldlm_lock *lock, *next;
-	int added = 0, unused, remained;
+	int added = 0;
 	int no_wait = flags & LDLM_LRU_FLAG_NO_WAIT;
 
-	spin_lock(&ns->ns_lock);
-	unused = ns->ns_nr_unused;
-	remained = unused;
-
 	if (!ns_connect_lru_resize(ns))
-		count += unused - ns->ns_max_unused;
+		count += ns->ns_nr_unused - ns->ns_max_unused;
 
 	pf = ldlm_cancel_lru_policy(ns, flags);
 	LASSERT(pf);
 
-	while (!list_empty(&ns->ns_unused_list)) {
+	/* For any flags, stop scanning if @max is reached. */
+	while (!list_empty(&ns->ns_unused_list) && (max == 0 || added < max)) {
+		struct ldlm_lock *lock;
+		struct list_head *item, *next;
 		enum ldlm_policy_res result;
 		ktime_t last_use = ktime_set(0, 0);
 
-		/* all unused locks */
-		if (remained-- <= 0)
-			break;
-
-		/* For any flags, stop scanning if @max is reached. */
-		if (max && added >= max)
-			break;
+		spin_lock(&ns->ns_lock);
+		item = no_wait ? ns->ns_last_pos : &ns->ns_unused_list;
+		for (item = item->next, next = item->next;
+		     item != &ns->ns_unused_list;
+		     item = next, next = item->next) {
+			lock = list_entry(item, struct ldlm_lock, l_lru);
 
-		list_for_each_entry_safe(lock, next, &ns->ns_unused_list,
-					 l_lru) {
 			/* No locks which got blocking requests. */
 			LASSERT(!ldlm_is_bl_ast(lock));
 
-			if (no_wait && ldlm_is_skipped(lock))
-				/* already processed */
-				continue;
-
-			last_use = lock->l_last_used;
-
-			/* Somebody is already doing CANCEL. No need for this
-			 * lock in LRU, do not traverse it again.
-			 */
 			if (!ldlm_is_canceling(lock) ||
 			    !ldlm_is_converting(lock))
 				break;
 
+			/* Somebody is already doing CANCEL. No need for this
+			 * lock in LRU, do not traverse it again.
+			 */
 			ldlm_lock_remove_from_lru_nolock(lock);
 		}
-		if (&lock->l_lru == &ns->ns_unused_list)
+		if (item == &ns->ns_unused_list) {
+			spin_unlock(&ns->ns_lock);
 			break;
+		}
+
+		last_use = lock->l_last_used;
 
 		LDLM_LOCK_GET(lock);
 		spin_unlock(&ns->ns_lock);
@@ -1659,19 +1649,23 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		 * their weight. Big extent locks will stay in
 		 * the cache.
 		 */
-		result = pf(ns, lock, unused, added, count);
+		result = pf(ns, lock, ns->ns_nr_unused, added, count);
 		if (result == LDLM_POLICY_KEEP_LOCK) {
-			lu_ref_del(&lock->l_reference,
-				   __func__, current);
+			lu_ref_del(&lock->l_reference, __func__, current);
 			LDLM_LOCK_RELEASE(lock);
-			spin_lock(&ns->ns_lock);
 			break;
 		}
+
 		if (result == LDLM_POLICY_SKIP_LOCK) {
-			lu_ref_del(&lock->l_reference,
-				   __func__, current);
+			lu_ref_del(&lock->l_reference, __func__, current);
 			LDLM_LOCK_RELEASE(lock);
-			spin_lock(&ns->ns_lock);
+			if (no_wait) {
+				spin_lock(&ns->ns_lock);
+				if (!list_empty(&lock->l_lru) &&
+				    lock->l_lru.prev == ns->ns_last_pos)
+					ns->ns_last_pos = &lock->l_lru;
+				spin_unlock(&ns->ns_lock);
+			}
 			continue;
 		}
 
@@ -1690,7 +1684,6 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 			lu_ref_del(&lock->l_reference,
 				   __func__, current);
 			LDLM_LOCK_RELEASE(lock);
-			spin_lock(&ns->ns_lock);
 			continue;
 		}
 		LASSERT(!lock->l_readers && !lock->l_writers);
@@ -1728,11 +1721,8 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		list_add(&lock->l_bl_ast, cancels);
 		unlock_res_and_lock(lock);
 		lu_ref_del(&lock->l_reference, __func__, current);
-		spin_lock(&ns->ns_lock);
 		added++;
-		unused--;
 	}
-	spin_unlock(&ns->ns_lock);
 	return added;
 }
 
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 5e0dd53..7fe8a8b 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -682,6 +682,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	ns->ns_connect_flags = 0;
 	ns->ns_dirty_age_limit = LDLM_DIRTY_AGE_LIMIT;
 	ns->ns_stopping = 0;
+	ns->ns_last_pos = &ns->ns_unused_list;
 
 	rc = ldlm_namespace_sysfs_register(ns);
 	if (rc != 0) {
-- 
1.8.3.1
