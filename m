From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:19 -0400
Subject: [lustre-devel] [PATCH 16/38] lustre: llite: user kstrtobool for
 some sysfs handling
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Some of the llite sysfs files only allow 1 or 0 which was
retrieved with kstrtoul(). A much better fit would be to
use kstrtobool(). This adds 'Y' or 'N' as valid options
as well.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9325
Reviewed-on: https://review.whamcloud.com/30539
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/lproc_llite.c | 33 ++++++++++++-----------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 02a09e7..e35b3ea 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -593,25 +593,28 @@ static ssize_t checksum_pages_store(struct kobject *kobj,
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
+	bool val;
+	int tmp;
 	int rc;
-	unsigned long val;
 
 	if (!sbi->ll_dt_exp)
 		/* Not set up yet */
 		return -EAGAIN;
 
-	rc = kstrtoul(buffer, 10, &val);
+	rc = kstrtobool(buffer, &val);
 	if (rc)
 		return rc;
+
 	spin_lock(&sbi->ll_lock);
 	if (val)
 		sbi->ll_flags |= LL_SBI_CHECKSUM;
 	else
 		sbi->ll_flags &= ~LL_SBI_CHECKSUM;
 	spin_unlock(&sbi->ll_lock);
+	tmp = val;
 
 	rc = obd_set_info_async(NULL, sbi->ll_dt_exp, sizeof(KEY_CHECKSUM),
-				KEY_CHECKSUM, sizeof(val), &val, NULL);
+				KEY_CHECKSUM, sizeof(tmp), &tmp, NULL);
 	if (rc)
 		CWARN("Failed to set OSC checksum flags: %d\n", rc);
 
@@ -753,10 +756,10 @@ static ssize_t statahead_agl_store(struct kobject *kobj,
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
+	bool val;
 	int rc;
-	unsigned long val;
 
-	rc = kstrtoul(buffer, 10, &val);
+	rc = kstrtobool(buffer, &val);
 	if (rc)
 		return rc;
 
@@ -805,10 +808,10 @@ static ssize_t lazystatfs_store(struct kobject *kobj,
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
+	bool val;
 	int rc;
-	unsigned long val;
 
-	rc = kstrtoul(buffer, 10, &val);
+	rc = kstrtobool(buffer, &val);
 	if (rc)
 		return rc;
 
@@ -948,17 +951,14 @@ static ssize_t xattr_cache_store(struct kobject *kobj,
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
+	bool val;
 	int rc;
-	unsigned long val;
 
-	rc = kstrtoul(buffer, 10, &val);
+	rc = kstrtobool(buffer, &val);
 	if (rc)
 		return rc;
 
-	if (val != 0 && val != 1)
-		return -ERANGE;
-
-	if (val == 1 && !(sbi->ll_flags & LL_SBI_XATTR_CACHE))
+	if (val && !(sbi->ll_flags & LL_SBI_XATTR_CACHE))
 		return -ENOTSUPP;
 
 	sbi->ll_xattr_cache_enabled = val;
@@ -1030,7 +1030,8 @@ static ssize_t ll_unstable_stats_seq_write(struct file *file,
 	struct super_block *sb = ((struct seq_file *)file->private_data)->private;
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	char kernbuf[128];
-	int val, rc;
+	bool val;
+	int rc;
 
 	if (!count)
 		return 0;
@@ -1043,13 +1044,13 @@ static ssize_t ll_unstable_stats_seq_write(struct file *file,
 
 	buffer += lprocfs_find_named_value(kernbuf, "unstable_check:", &count) -
 		  kernbuf;
-	rc = lprocfs_write_helper(buffer, count, &val);
+	rc = kstrtobool_from_user(buffer, count, &val);
 	if (rc < 0)
 		return rc;
 
 	/* borrow lru lock to set the value */
 	spin_lock(&sbi->ll_cache->ccc_lru_lock);
-	sbi->ll_cache->ccc_unstable_check = !!val;
+	sbi->ll_cache->ccc_unstable_check = val;
 	spin_unlock(&sbi->ll_cache->ccc_lru_lock);
 
 	return count;
-- 
1.8.3.1
