From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:26 -0400
Subject: [lustre-devel] [PATCH 127/151] lustre: obd: fix statfs handling
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-128-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The comment 'use the value of cfs_time_current + HZ' for
obd_statfs() and obd_statfs_async() needs to updated to
the time64_t case.

Simplify llite_statfs_internal() handling by calculating
max_age inside of llite_statfs_internal(). This makes the
code cleaner.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10570
Lustre-commit: 87577f4988c1 ("LU-10570 obd: fix statfs handling")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/31158
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h    |  8 ++++----
 fs/lustre/llite/llite_internal.h |  2 +-
 fs/lustre/llite/llite_lib.c      |  9 +++++----
 fs/lustre/llite/lproc_llite.c    | 24 ++++++------------------
 4 files changed, 16 insertions(+), 27 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 0bbf777..9e07853 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -868,9 +868,9 @@ static inline int obd_destroy_export(struct obd_export *exp)
 }
 
 /*
- * @max_age is the oldest time in jiffies that we accept using a cached data.
+ * @max_age is the oldest time in seconds that we accept using a cached data.
  * If the cache is older than @max_age we will get a new value from the
- * target.  Use a value of "jiffies + HZ" to guarantee freshness.
+ * target. Use a value of 'ktime_get_seconds() + X' to guarantee freshness.
  */
 static inline int obd_statfs_async(struct obd_export *exp,
 				   struct obd_info *oinfo,
@@ -910,9 +910,9 @@ static inline int obd_statfs_async(struct obd_export *exp,
 }
 
 /*
- * @max_age is the oldest time in jiffies that we accept using a cached data.
+ * @max_age is the oldest time in seconds that we accept using a cached data.
  * If the cache is older than @max_age we will get a new value from the
- * target.  Use a value of "jiffies + HZ" to guarantee freshness.
+ * target. Use a value of 'ktime_get_seconds() + X' to guarantee freshness.
  */
 static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
 			     struct obd_statfs *osfs, time64_t max_age,
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index fc4c4db..f23cf65 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -878,7 +878,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 int ll_setattr(struct dentry *de, struct iattr *attr);
 int ll_statfs(struct dentry *de, struct kstatfs *sfs);
 int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
-		       time64_t max_age, __u32 flags);
+		       u32 flags);
 int ll_update_inode(struct inode *inode, struct lustre_md *md);
 void ll_update_inode_flags(struct inode *inode, int ext_flags);
 int ll_read_inode2(struct inode *inode, void *opaque);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index efd1093..758f856 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1716,11 +1716,14 @@ int ll_setattr(struct dentry *de, struct iattr *attr)
 }
 
 int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
-		       time64_t max_age, u32 flags)
+		       u32 flags)
 {
 	struct obd_statfs obd_osfs;
+	time64_t max_age;
 	int rc;
 
+	max_age = ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS;
+
 	rc = obd_statfs(NULL, sbi->ll_md_exp, osfs, max_age, flags);
 	if (rc) {
 		CERROR("md_statfs fails: rc = %d\n", rc);
@@ -1774,9 +1777,7 @@ int ll_statfs(struct dentry *de, struct kstatfs *sfs)
 	ll_stats_ops_tally(ll_s2sbi(sb), LPROC_LL_STAFS, 1);
 
 	/* Some amount of caching on the client is allowed */
-	rc = ll_statfs_internal(ll_s2sbi(sb), &osfs,
-				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
-				0);
+	rc = ll_statfs_internal(ll_s2sbi(sb), &osfs, 0);
 	if (rc)
 		return rc;
 
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 9173d94..b69e5d7 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -140,9 +140,7 @@ static ssize_t blocksize_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_statfs osfs;
 	int rc;
 
-	rc = ll_statfs_internal(sbi, &osfs,
-				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
-				OBD_STATFS_NODELAY);
+	rc = ll_statfs_internal(sbi, &osfs, OBD_STATFS_NODELAY);
 	if (rc)
 		return rc;
 
@@ -192,9 +190,7 @@ static ssize_t kbytestotal_show(struct kobject *kobj, struct attribute *attr,
 	u64 result;
 	int rc;
 
-	rc = ll_statfs_internal(sbi, &osfs,
-				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
-				OBD_STATFS_NODELAY);
+	rc = ll_statfs_internal(sbi, &osfs, OBD_STATFS_NODELAY);
 	if (rc)
 		return rc;
 
@@ -218,9 +214,7 @@ static ssize_t kbytesfree_show(struct kobject *kobj, struct attribute *attr,
 	u64 result;
 	int rc;
 
-	rc = ll_statfs_internal(sbi, &osfs,
-				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
-				OBD_STATFS_NODELAY);
+	rc = ll_statfs_internal(sbi, &osfs, OBD_STATFS_NODELAY);
 	if (rc)
 		return rc;
 
@@ -244,9 +238,7 @@ static ssize_t kbytesavail_show(struct kobject *kobj, struct attribute *attr,
 	u64 result;
 	int rc;
 
-	rc = ll_statfs_internal(sbi, &osfs,
-				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
-				OBD_STATFS_NODELAY);
+	rc = ll_statfs_internal(sbi, &osfs, OBD_STATFS_NODELAY);
 	if (rc)
 		return rc;
 
@@ -268,9 +260,7 @@ static ssize_t filestotal_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_statfs osfs;
 	int rc;
 
-	rc = ll_statfs_internal(sbi, &osfs,
-				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
-				OBD_STATFS_NODELAY);
+	rc = ll_statfs_internal(sbi, &osfs, OBD_STATFS_NODELAY);
 	if (rc)
 		return rc;
 
@@ -286,9 +276,7 @@ static ssize_t filesfree_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_statfs osfs;
 	int rc;
 
-	rc = ll_statfs_internal(sbi, &osfs,
-				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
-				OBD_STATFS_NODELAY);
+	rc = ll_statfs_internal(sbi, &osfs, OBD_STATFS_NODELAY);
 	if (rc)
 		return rc;
 
-- 
1.8.3.1
