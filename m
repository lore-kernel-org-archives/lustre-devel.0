From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:55 -0400
Subject: [lustre-devel] [PATCH 036/151] lustre: ldlm: don't use jiffies as
 sysfs parameter
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-37-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The ldlm sysfs file handles lru_max_age in jiffies which is wrong
since jiffies are not consistent across machine since HZ is
configurable at compile time. Talking to most users they thought
lru_max_age was in seconds which is incorrect. The best way to
fix this is to move lru_max_age to millisecs since most systems
lustre deals with sets HZ to 1000. To make it clear it is in
milliseconds print out lru_max_age with "ms". Since users tend
to think in seconds allow passing in seconds besides milliseconds
and internally converting them to nanaseconds. Since we have to
support milliseconds move to ktime_t since we can't use time64_t.
Unfortunately, this makes a relatively large patch, but I could
not find a way to split it up some more without breaking atomicity
of the change.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8541
Lustre-commit: 800ffd471186 ("LU-8541 ldlm: don't use jiffies as sysfs parameter")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/28370
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h | 10 +++++-----
 fs/lustre/ldlm/ldlm_internal.h |  5 +++--
 fs/lustre/ldlm/ldlm_lock.c     |  7 ++++---
 fs/lustre/ldlm/ldlm_lockd.c    |  5 +++--
 fs/lustre/ldlm/ldlm_request.c  | 16 ++++++++--------
 fs/lustre/ldlm/ldlm_resource.c | 23 ++++++++++++++++++-----
 6 files changed, 41 insertions(+), 25 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 1c286eb..b13e0cc 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -59,7 +59,7 @@
 #define OBD_LDLM_DEVICENAME  "ldlm"
 
 #define LDLM_DEFAULT_LRU_SIZE (100 * num_online_cpus())
-#define LDLM_DEFAULT_MAX_ALIVE (65 * 60 * HZ) /* 65 min */
+#define LDLM_DEFAULT_MAX_ALIVE (64 * 60)	/* 65 min */
 #define LDLM_DEFAULT_PARALLEL_AST_LIMIT 1024
 
 /**
@@ -410,8 +410,9 @@ struct ldlm_namespace {
 	 * controlled by available memory on this client and on server.
 	 */
 	unsigned int		ns_max_unused;
+
 	/** Maximum allowed age (last used time) for locks in the LRU */
-	unsigned int		ns_max_age;
+	ktime_t			ns_max_age;
 
 	/**
 	 * Used to rate-limit ldlm_namespace_dump calls.
@@ -702,10 +703,9 @@ struct ldlm_lock {
 	time64_t			l_last_activity;
 
 	/**
-	 * Time last used by e.g. being matched by lock match.
-	 * Jiffies. Should be converted to time if needed.
+	 * Time, in nanoseconds, last used by e.g. being matched by lock match.
 	 */
-	unsigned long			l_last_used;
+	ktime_t				l_last_used;
 
 	/** Originally requested extent for the extent lock. */
 	struct ldlm_extent		l_req_extent;
diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index a6dee9f..c3788c2 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -147,8 +147,9 @@ void ldlm_lock_decref_internal_nolock(struct ldlm_lock *lock,
 struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock);
 int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
 		      enum ldlm_desc_ast_t ast_type);
-int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, time_t last_use);
-#define ldlm_lock_remove_from_lru(lock) ldlm_lock_remove_from_lru_check(lock, 0)
+int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, ktime_t last_use);
+#define ldlm_lock_remove_from_lru(lock) \
+		ldlm_lock_remove_from_lru_check(lock, ktime_set(0, 0))
 int ldlm_lock_remove_from_lru_nolock(struct ldlm_lock *lock);
 void ldlm_lock_destroy_nolock(struct ldlm_lock *lock);
 
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index ddebcf6..235a137 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -224,13 +224,14 @@ int ldlm_lock_remove_from_lru_nolock(struct ldlm_lock *lock)
  *
  *		1 the lock was in LRU list and removed.
  */
-int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, time_t last_use)
+int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, ktime_t last_use)
 {
 	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
 	int rc = 0;
 
 	spin_lock(&ns->ns_lock);
-	if (last_use == 0 || last_use == lock->l_last_used)
+	if (!ktime_compare(last_use, ktime_set(0, 0)) ||
+	    !ktime_compare(last_use, lock->l_last_used))
 		rc = ldlm_lock_remove_from_lru_nolock(lock);
 	spin_unlock(&ns->ns_lock);
 
@@ -244,7 +245,7 @@ static void ldlm_lock_add_to_lru_nolock(struct ldlm_lock *lock)
 {
 	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
 
-	lock->l_last_used = jiffies;
+	lock->l_last_used = ktime_get();
 	LASSERT(list_empty(&lock->l_lru));
 	LASSERT(lock->l_resource->lr_type != LDLM_FLOCK);
 	list_add_tail(&lock->l_lru, &ns->ns_unused_list);
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 56f042c..83f5a22 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -303,8 +303,9 @@ static void ldlm_handle_gl_callback(struct ptlrpc_request *req,
 	lock_res_and_lock(lock);
 	if (lock->l_granted_mode == LCK_PW &&
 	    !lock->l_readers && !lock->l_writers &&
-	    time_after(jiffies,
-		       lock->l_last_used + 10 * HZ)) {
+	    ktime_after(ktime_get(),
+			ktime_add(lock->l_last_used,
+				  ktime_set(10, 0)))) {
 		unlock_res_and_lock(lock);
 		if (ldlm_bl_to_thread_lock(ns, NULL, lock))
 			ldlm_handle_bl_callback(ns, NULL, lock);
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index b7dcfda..4185d42 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1166,10 +1166,10 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 						    int unused, int added,
 						    int count)
 {
-	unsigned long cur = jiffies;
+	ktime_t cur = ktime_get();
 	struct ldlm_pool *pl = &ns->ns_pool;
 	u64 slv, lvf, lv;
-	unsigned long la;
+	s64 la;
 
 	/* Stop LRU processing when we reach past @count or have checked all
 	 * locks in LRU.
@@ -1181,12 +1181,13 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 	 * Despite of the LV, It doesn't make sense to keep the lock which
 	 * is unused for ns_max_age time.
 	 */
-	if (time_after(jiffies, lock->l_last_used + ns->ns_max_age))
+	if (ktime_after(ktime_get(),
+			ktime_add(lock->l_last_used, ns->ns_max_age)))
 		return LDLM_POLICY_CANCEL_LOCK;
 
 	slv = ldlm_pool_get_slv(pl);
 	lvf = ldlm_pool_get_lvf(pl);
-	la = (cur - lock->l_last_used) / HZ;
+	la = ktime_to_ns(ktime_sub(cur, lock->l_last_used)) / NSEC_PER_SEC;
 	lv = lvf * la * unused;
 
 	/* Inform pool about current CLV to see it via debugfs. */
@@ -1235,7 +1236,8 @@ static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
 						    int count)
 {
 	if ((added >= count) &&
-	    time_before(jiffies, lock->l_last_used + ns->ns_max_age))
+	    ktime_before(ktime_get(),
+			 ktime_add(lock->l_last_used, ns->ns_max_age)))
 		return LDLM_POLICY_KEEP_LOCK;
 
 	return LDLM_POLICY_CANCEL_LOCK;
@@ -1382,7 +1384,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 
 	while (!list_empty(&ns->ns_unused_list)) {
 		enum ldlm_policy_res result;
-		time_t last_use = 0;
+		ktime_t last_use = ktime_set(0, 0);
 
 		/* all unused locks */
 		if (remained-- <= 0)
@@ -1402,8 +1404,6 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 				continue;
 
 			last_use = lock->l_last_used;
-			if (last_use == jiffies)
-				continue;
 
 			/* Somebody is already doing CANCEL. No need for this
 			 * lock in LRU, do not traverse it again.
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 372a290..bf8abd4 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -263,7 +263,7 @@ static ssize_t lru_max_age_show(struct kobject *kobj, struct attribute *attr,
 	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
 						 ns_kobj);
 
-	return sprintf(buf, "%u\n", ns->ns_max_age);
+	return sprintf(buf, "%lld\n", ktime_to_ms(ns->ns_max_age));
 }
 
 static ssize_t lru_max_age_store(struct kobject *kobj, struct attribute *attr,
@@ -271,14 +271,27 @@ static ssize_t lru_max_age_store(struct kobject *kobj, struct attribute *attr,
 {
 	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
 						 ns_kobj);
-	unsigned long tmp;
+	int scale = NSEC_PER_MSEC;
+	unsigned long long tmp;
+	char *buf;
 	int err;
 
-	err = kstrtoul(buffer, 10, &tmp);
+	/* Did the user ask in seconds or milliseconds. Default is in ms */
+	buf = strstr(buffer, "ms");
+	if (!buf) {
+		buf = strchr(buffer, 's');
+		if (buf)
+			scale = NSEC_PER_SEC;
+	}
+
+	if (buf)
+		*buf = '\0';
+
+	err = kstrtoull(buffer, 10, &tmp);
 	if (err != 0)
 		return -EINVAL;
 
-	ns->ns_max_age = tmp;
+	ns->ns_max_age = ktime_set(0, tmp * scale);
 
 	return count;
 }
@@ -639,7 +652,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	ns->ns_max_parallel_ast = LDLM_DEFAULT_PARALLEL_AST_LIMIT;
 	ns->ns_nr_unused = 0;
 	ns->ns_max_unused = LDLM_DEFAULT_LRU_SIZE;
-	ns->ns_max_age = LDLM_DEFAULT_MAX_ALIVE;
+	ns->ns_max_age = ktime_set(LDLM_DEFAULT_MAX_ALIVE, 0);
 	ns->ns_orig_connect_flags = 0;
 	ns->ns_connect_flags = 0;
 	ns->ns_stopping = 0;
-- 
1.8.3.1
