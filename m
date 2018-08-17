From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:05 -0400
Subject: [lustre-devel] [PATCH 02/38] lustre: llite: change
 ll_statfs_internal to use struct ll_sb_info
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The only reason ll_statfs_internal() needs struct super_block is
for the super block magic. We can use LL_SUPER_MAGIC directly
thus removing the need to pass in struct super_block. This will
help to remove ll_sb in struct ll_sb_info.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24031
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_internal.h |  4 ++--
 drivers/staging/lustre/lustre/llite/llite_lib.c      |  9 ++++-----
 drivers/staging/lustre/lustre/llite/lproc_llite.c    | 12 ++++++------
 3 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index b2cdf75..4053314 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -832,8 +832,8 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 		   unsigned int xvalid, bool hsm_import);
 int ll_setattr(struct dentry *de, struct iattr *attr);
 int ll_statfs(struct dentry *de, struct kstatfs *sfs);
-int ll_statfs_internal(struct super_block *sb, struct obd_statfs *osfs,
-		       __u64 max_age, __u32 flags);
+int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
+		       u64 max_age, u32 flags);
 int ll_update_inode(struct inode *inode, struct lustre_md *md);
 int ll_read_inode2(struct inode *inode, void *opaque);
 void ll_delete_inode(struct inode *inode);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 50ea5fb..437f4cc 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1643,10 +1643,9 @@ int ll_setattr(struct dentry *de, struct iattr *attr)
 	return ll_setattr_raw(de, attr, xvalid, false);
 }
 
-int ll_statfs_internal(struct super_block *sb, struct obd_statfs *osfs,
-		       __u64 max_age, __u32 flags)
+int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
+		       u64 max_age, u32 flags)
 {
-	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct obd_statfs obd_osfs;
 	int rc;
 
@@ -1656,7 +1655,7 @@ int ll_statfs_internal(struct super_block *sb, struct obd_statfs *osfs,
 		return rc;
 	}
 
-	osfs->os_type = sb->s_magic;
+	osfs->os_type = LL_SUPER_MAGIC;
 
 	CDEBUG(D_SUPER, "MDC blocks %llu/%llu objects %llu/%llu\n",
 	       osfs->os_bavail, osfs->os_blocks, osfs->os_ffree,
@@ -1703,7 +1702,7 @@ int ll_statfs(struct dentry *de, struct kstatfs *sfs)
 	ll_stats_ops_tally(ll_s2sbi(sb), LPROC_LL_STAFS, 1);
 
 	/* Some amount of caching on the client is allowed */
-	rc = ll_statfs_internal(sb, &osfs,
+	rc = ll_statfs_internal(ll_s2sbi(sb), &osfs,
 				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 				0);
 	if (rc)
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 996703d..cae483f 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -52,7 +52,7 @@ static ssize_t blocksize_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_statfs osfs;
 	int rc;
 
-	rc = ll_statfs_internal(sbi->ll_sb, &osfs,
+	rc = ll_statfs_internal(sbi, &osfs,
 				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 				OBD_STATFS_NODELAY);
 	if (!rc)
@@ -70,7 +70,7 @@ static ssize_t kbytestotal_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_statfs osfs;
 	int rc;
 
-	rc = ll_statfs_internal(sbi->ll_sb, &osfs,
+	rc = ll_statfs_internal(sbi, &osfs,
 				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 				OBD_STATFS_NODELAY);
 	if (!rc) {
@@ -95,7 +95,7 @@ static ssize_t kbytesfree_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_statfs osfs;
 	int rc;
 
-	rc = ll_statfs_internal(sbi->ll_sb, &osfs,
+	rc = ll_statfs_internal(sbi, &osfs,
 				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 				OBD_STATFS_NODELAY);
 	if (!rc) {
@@ -120,7 +120,7 @@ static ssize_t kbytesavail_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_statfs osfs;
 	int rc;
 
-	rc = ll_statfs_internal(sbi->ll_sb, &osfs,
+	rc = ll_statfs_internal(sbi, &osfs,
 				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 				OBD_STATFS_NODELAY);
 	if (!rc) {
@@ -145,7 +145,7 @@ static ssize_t filestotal_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_statfs osfs;
 	int rc;
 
-	rc = ll_statfs_internal(sbi->ll_sb, &osfs,
+	rc = ll_statfs_internal(sbi, &osfs,
 				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 				OBD_STATFS_NODELAY);
 	if (!rc)
@@ -163,7 +163,7 @@ static ssize_t filesfree_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_statfs osfs;
 	int rc;
 
-	rc = ll_statfs_internal(sbi->ll_sb, &osfs,
+	rc = ll_statfs_internal(sbi, &osfs,
 				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 				OBD_STATFS_NODELAY);
 	if (!rc)
-- 
1.8.3.1
