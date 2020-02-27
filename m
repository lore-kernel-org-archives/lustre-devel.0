From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:25 -0500
Subject: [lustre-devel] [PATCH 037/622] lustre: ldlm: expose dirty age limit
 for flush-on-glimpse
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-38-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Glimpse request may cancel old lock and cause data flush.
That helps to cache stat results on client locally early.
The time limit was hardcoded to 10s and is exposed now
as ns_dirty_age_limit namespace value, it can be set/check
via /sys/fs/lustre/ldlm/namespaces/<namespace>/dirty_age_limit

WC-bug-id: https://jira.whamcloud.com/browse/LU-10413
Lustre-commit: 69727e45b4c0 ("LU-10413 ldlm: expose dirty age limit for flush-on-glimpse")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32113
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h | 12 +++++++++++-
 fs/lustre/ldlm/ldlm_lockd.c    |  2 +-
 fs/lustre/ldlm/ldlm_resource.c | 28 ++++++++++++++++++++++++++++
 3 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index b1a37f0..8dea9ab 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -60,6 +60,10 @@
 
 #define LDLM_DEFAULT_LRU_SIZE (100 * num_online_cpus())
 #define LDLM_DEFAULT_MAX_ALIVE (64 * 60)	/* 65 min */
+/* if client lock is unused for that time it can be cancelled if any other
+ * client shows interest in that lock, e.g. glimpse is occurred.
+ */
+#define LDLM_DIRTY_AGE_LIMIT (10)
 #define LDLM_DEFAULT_PARALLEL_AST_LIMIT 1024
 
 /**
@@ -412,7 +416,13 @@ struct ldlm_namespace {
 
 	/** Maximum allowed age (last used time) for locks in the LRU */
 	ktime_t			ns_max_age;
-
+	/**
+	 * Number of seconds since the lock was last used. The client may
+	 * cancel the lock limited by this age and flush related data if
+	 * any other client shows interest in it doing glimpse request.
+	 * This allows to cache stat data locally for such files early.
+	 */
+	time64_t		ns_dirty_age_limit;
 	/**
 	 * Used to rate-limit ldlm_namespace_dump calls.
 	 * \see ldlm_namespace_dump. Increased by 10 seconds every time
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 84d73e6..481719b 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -305,7 +305,7 @@ static void ldlm_handle_gl_callback(struct ptlrpc_request *req,
 	    !lock->l_readers && !lock->l_writers &&
 	    ktime_after(ktime_get(),
 			ktime_add(lock->l_last_used,
-				  ktime_set(10, 0)))) {
+				  ktime_set(ns->ns_dirty_age_limit, 0)))) {
 		unlock_res_and_lock(lock);
 		if (ldlm_bl_to_thread_lock(ns, NULL, lock))
 			ldlm_handle_bl_callback(ns, NULL, lock);
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 4e3c6e7..5e0dd53 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -327,6 +327,32 @@ static ssize_t early_lock_cancel_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(early_lock_cancel);
 
+static ssize_t dirty_age_limit_show(struct kobject *kobj,
+				    struct attribute *attr, char *buf)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+
+	return sprintf(buf, "%llu\n", ns->ns_dirty_age_limit);
+}
+
+static ssize_t dirty_age_limit_store(struct kobject *kobj,
+				     struct attribute *attr,
+				     const char *buffer, size_t count)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+	unsigned long long tmp;
+
+	if (kstrtoull(buffer, 10, &tmp))
+		return -EINVAL;
+
+	ns->ns_dirty_age_limit = tmp;
+
+	return count;
+}
+LUSTRE_RW_ATTR(dirty_age_limit);
+
 /* These are for namespaces in /sys/fs/lustre/ldlm/namespaces/ */
 static struct attribute *ldlm_ns_attrs[] = {
 	&lustre_attr_resource_count.attr,
@@ -335,6 +361,7 @@ static ssize_t early_lock_cancel_store(struct kobject *kobj,
 	&lustre_attr_lru_size.attr,
 	&lustre_attr_lru_max_age.attr,
 	&lustre_attr_early_lock_cancel.attr,
+	&lustre_attr_dirty_age_limit.attr,
 	NULL,
 };
 
@@ -653,6 +680,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	ns->ns_max_age = ktime_set(LDLM_DEFAULT_MAX_ALIVE, 0);
 	ns->ns_orig_connect_flags = 0;
 	ns->ns_connect_flags = 0;
+	ns->ns_dirty_age_limit = LDLM_DIRTY_AGE_LIMIT;
 	ns->ns_stopping = 0;
 
 	rc = ldlm_namespace_sysfs_register(ns);
-- 
1.8.3.1
