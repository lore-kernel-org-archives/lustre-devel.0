From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:17 -0400
Subject: [lustre-devel] [PATCH 14/38] lustre: llite: don't handle success
 case for kbyte* sysfs code
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The proper thing to due is return on failure so reverse the logic
to conform to kernel standards.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/32497
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/lproc_llite.c | 51 ++++++++++++-----------
 1 file changed, 27 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 7bd557b..72a8f8d 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -154,22 +154,23 @@ static ssize_t kbytestotal_show(struct kobject *kobj, struct attribute *attr,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 	struct obd_statfs osfs;
+	u32 blk_size;
+	u64 result;
 	int rc;
 
 	rc = ll_statfs_internal(sbi, &osfs,
 				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 				OBD_STATFS_NODELAY);
-	if (!rc) {
-		__u32 blk_size = osfs.os_bsize >> 10;
-		__u64 result = osfs.os_blocks;
+	if (rc)
+		return rc;
 
-		while (blk_size >>= 1)
-			result <<= 1;
+	blk_size = osfs.os_bsize >> 10;
+	result = osfs.os_blocks;
 
-		rc = sprintf(buf, "%llu\n", result);
-	}
+	while (blk_size >>= 1)
+		result <<= 1;
 
-	return rc;
+	return sprintf(buf, "%llu\n", result);
 }
 LUSTRE_RO_ATTR(kbytestotal);
 
@@ -179,22 +180,23 @@ static ssize_t kbytesfree_show(struct kobject *kobj, struct attribute *attr,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 	struct obd_statfs osfs;
+	u32 blk_size;
+	u64 result;
 	int rc;
 
 	rc = ll_statfs_internal(sbi, &osfs,
 				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 				OBD_STATFS_NODELAY);
-	if (!rc) {
-		__u32 blk_size = osfs.os_bsize >> 10;
-		__u64 result = osfs.os_bfree;
+	if (rc)
+		return rc;
 
-		while (blk_size >>= 1)
-			result <<= 1;
+	blk_size = osfs.os_bsize >> 10;
+	result = osfs.os_bfree;
 
-		rc = sprintf(buf, "%llu\n", result);
-	}
+	while (blk_size >>= 1)
+		result <<= 1;
 
-	return rc;
+	return sprintf(buf, "%llu\n", result);
 }
 LUSTRE_RO_ATTR(kbytesfree);
 
@@ -204,22 +206,23 @@ static ssize_t kbytesavail_show(struct kobject *kobj, struct attribute *attr,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 	struct obd_statfs osfs;
+	u32 blk_size;
+	u64 result;
 	int rc;
 
 	rc = ll_statfs_internal(sbi, &osfs,
 				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 				OBD_STATFS_NODELAY);
-	if (!rc) {
-		__u32 blk_size = osfs.os_bsize >> 10;
-		__u64 result = osfs.os_bavail;
+	if (rc)
+		return rc;
 
-		while (blk_size >>= 1)
-			result <<= 1;
+	blk_size = osfs.os_bsize >> 10;
+	result = osfs.os_bavail;
 
-		rc = sprintf(buf, "%llu\n", result);
-	}
+	while (blk_size >>= 1)
+		result <<= 1;
 
-	return rc;
+	return sprintf(buf, "%llu\n", result);
 }
 LUSTRE_RO_ATTR(kbytesavail);
 
-- 
1.8.3.1
