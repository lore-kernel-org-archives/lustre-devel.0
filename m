From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:10 -0400
Subject: [lustre-devel] [PATCH 33/45] lustre: ldlm: use proper units for
 timeouts
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Use ktime_t for ns_dirty_age_limit internally, even though the user
interface is in seconds, since this is frequenty used together with
other ktime_t values in the kernel.

Fixes: fdeeed2fb547 ("lustre: ldlm: migrate the rest of the code to 64 bit time")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12931
Lustre-commit: 3108bbb0b8485 ("LU-12931 ldlm: use proper units for timeouts")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38365
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h | 15 +++++++++------
 fs/lustre/ldlm/ldlm_lockd.c    |  3 +--
 fs/lustre/ldlm/ldlm_resource.c |  7 ++++---
 fs/lustre/llite/namei.c        |  3 +--
 4 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index dda59d7..f67b612 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -415,15 +415,18 @@ struct ldlm_namespace {
 	 */
 	unsigned int		ns_max_unused;
 
-	/** Maximum allowed age (last used time) for locks in the LRU */
+	/** Maximum allowed age (last used time) for locks in the LRU. Set in
+	 * seconds from userspace, but stored in ns to avoid repeat conversions.
+	 */
 	ktime_t			ns_max_age;
 	/**
-	 * Number of seconds since the lock was last used. The client may
-	 * cancel the lock limited by this age and flush related data if
-	 * any other client shows interest in it doing glimpse request.
-	 * This allows to cache stat data locally for such files early.
+	 * Number of (nano)seconds since the lock was last used. The client
+	 * may cancel the lock older than this age and flush related data if
+	 * another client shows interest in this lock by doing glimpse request.
+	 * This allows to cache stat data locally for such files early. Set in
+	 * seconds from userspace, but stored in ns to avoid repeat conversions.
 	 */
-	time64_t		ns_dirty_age_limit;
+	ktime_t			ns_dirty_age_limit;
 	/**
 	 * Used to rate-limit ldlm_namespace_dump calls.
 	 * \see ldlm_namespace_dump. Increased by 10 seconds every time
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index bd5331d..7df7af2 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -378,8 +378,7 @@ static void ldlm_handle_gl_callback(struct ptlrpc_request *req,
 	if (lock->l_granted_mode == LCK_PW &&
 	    !lock->l_readers && !lock->l_writers &&
 	    ktime_after(ktime_get(),
-			ktime_add(lock->l_last_used,
-				  ktime_set(ns->ns_dirty_age_limit, 0)))) {
+			ktime_add(lock->l_last_used, ns->ns_dirty_age_limit))) {
 		unlock_res_and_lock(lock);
 
 		/* For MDS glimpse it is always DOM lock, set corresponding
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 0a3d861..a6572af 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -332,7 +332,8 @@ static ssize_t dirty_age_limit_show(struct kobject *kobj,
 	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
 						 ns_kobj);
 
-	return sprintf(buf, "%llu\n", ns->ns_dirty_age_limit);
+	return scnprintf(buf, PAGE_SIZE, "%llu\n",
+			 ktime_divns(ns->ns_dirty_age_limit, NSEC_PER_SEC));
 }
 
 static ssize_t dirty_age_limit_store(struct kobject *kobj,
@@ -346,7 +347,7 @@ static ssize_t dirty_age_limit_store(struct kobject *kobj,
 	if (kstrtoull(buffer, 10, &tmp))
 		return -EINVAL;
 
-	ns->ns_dirty_age_limit = tmp;
+	ns->ns_dirty_age_limit = ktime_set(tmp, 0);
 
 	return count;
 }
@@ -646,7 +647,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	ns->ns_max_age = ktime_set(LDLM_DEFAULT_MAX_ALIVE, 0);
 	ns->ns_orig_connect_flags = 0;
 	ns->ns_connect_flags = 0;
-	ns->ns_dirty_age_limit = LDLM_DIRTY_AGE_LIMIT;
+	ns->ns_dirty_age_limit = ktime_set(LDLM_DIRTY_AGE_LIMIT, 0);
 	ns->ns_stopping = 0;
 	ns->ns_last_pos = &ns->ns_unused_list;
 
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 2ca6bd2..16c3bc5 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -418,8 +418,7 @@ int ll_md_need_convert(struct ldlm_lock *lock)
 	/* is lock is too old to be converted? */
 	lock_res_and_lock(lock);
 	if (ktime_after(ktime_get(),
-			ktime_add(lock->l_last_used,
-				  ktime_set(ns->ns_dirty_age_limit, 0)))) {
+			ktime_add(lock->l_last_used, ns->ns_dirty_age_limit))) {
 		unlock_res_and_lock(lock);
 		return 0;
 	}
-- 
1.8.3.1
