From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:18 -0400
Subject: [lustre-devel] [PATCH 15/38] lustre: llite: don't handle success
 case for file* sysfs code
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-16-git-send-email-jsimmons@infradead.org>
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
 drivers/staging/lustre/lustre/llite/lproc_llite.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 72a8f8d..02a09e7 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -237,10 +237,10 @@ static ssize_t filestotal_show(struct kobject *kobj, struct attribute *attr,
 	rc = ll_statfs_internal(sbi, &osfs,
 				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 				OBD_STATFS_NODELAY);
-	if (!rc)
-		return sprintf(buf, "%llu\n", osfs.os_files);
+	if (rc)
+		return rc;
 
-	return rc;
+	return sprintf(buf, "%llu\n", osfs.os_files);
 }
 LUSTRE_RO_ATTR(filestotal);
 
@@ -255,10 +255,10 @@ static ssize_t filesfree_show(struct kobject *kobj, struct attribute *attr,
 	rc = ll_statfs_internal(sbi, &osfs,
 				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 				OBD_STATFS_NODELAY);
-	if (!rc)
-		return sprintf(buf, "%llu\n", osfs.os_ffree);
+	if (rc)
+		return rc;
 
-	return rc;
+	return sprintf(buf, "%llu\n", osfs.os_ffree);
 }
 LUSTRE_RO_ATTR(filesfree);
 
-- 
1.8.3.1
