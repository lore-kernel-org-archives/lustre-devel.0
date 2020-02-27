From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:19 -0500
Subject: [lustre-devel] [PATCH 031/622] lustre: ldlm: change
 LDLM_POOL_ADD_VAR macro to inline function
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Simple cleanup to create inline funciton ldlm_pool_add_var().

WC-bug-id: https://jira.hpdd.intel.com/browse/LU-8066
Lustre-commit: 05a36534ba2d ("LU-8066 ldlm: move all remaining files from procfs to debugfs")
Signed-off-by: Dmitry Eremin <dmiter4ever@gmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/29255
WC-bug-id: https://jira.hpdd.intel.com/browse/LU-3319
Lustre-commit: 4ad445ccd54 ("LU-3319 procfs: move ldlm proc handling over to seq_file")
Reviewed-on: http://review.whamcloud.com/7293
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Peng Tao <bergwolf@gmail.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_internal.h | 10 ++++++++++
 fs/lustre/ldlm/ldlm_pool.c     | 11 ++---------
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index 6e54521..96dff1d 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -292,6 +292,16 @@ enum ldlm_policy_res {
 	}								    \
 	struct __##var##__dummy_write {; } /* semicolon catcher */
 
+static inline void
+ldlm_add_var(struct lprocfs_vars *vars, struct dentry *debugfs_entry,
+	     const char *name, void *data, const struct file_operations *ops)
+{
+	vars->name = name;
+	vars->data = data;
+	vars->fops = ops;
+	ldebugfs_add_vars(debugfs_entry, vars, NULL);
+}
+
 static inline int is_granted_or_cancelled(struct ldlm_lock *lock)
 {
 	int ret = 0;
diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index 04bf5de..d2149a6 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -504,14 +504,6 @@ static ssize_t grant_speed_show(struct kobject *kobj, struct attribute *attr,
 LDLM_POOL_SYSFS_WRITER_NOLOCK_STORE(lock_volume_factor, atomic);
 LUSTRE_RW_ATTR(lock_volume_factor);
 
-#define LDLM_POOL_ADD_VAR(_name, var, ops)			\
-	do {							\
-		pool_vars[0].name = #_name;			\
-		pool_vars[0].data = var;			\
-		pool_vars[0].fops = ops;			\
-		ldebugfs_add_vars(pl->pl_debugfs_entry, pool_vars, NULL);\
-	} while (0)
-
 /* These are for pools in /sys/fs/lustre/ldlm/namespaces/.../pool */
 static struct attribute *ldlm_pl_attrs[] = {
 	&lustre_attr_grant_speed.attr,
@@ -571,7 +563,8 @@ static int ldlm_pool_debugfs_init(struct ldlm_pool *pl)
 
 	memset(pool_vars, 0, sizeof(pool_vars));
 
-	LDLM_POOL_ADD_VAR(state, pl, &lprocfs_pool_state_fops);
+	ldlm_add_var(&pool_vars[0], pl->pl_debugfs_entry, "state", pl,
+		     &lprocfs_pool_state_fops);
 
 	pl->pl_stats = lprocfs_alloc_stats(LDLM_POOL_LAST_STAT -
 					   LDLM_POOL_FIRST_STAT, 0);
-- 
1.8.3.1
