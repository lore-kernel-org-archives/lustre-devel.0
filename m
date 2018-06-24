From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:20:35 -0400
Subject: [lustre-devel] [PATCH v3 11/26] staging: lustre: libcfs: invert
 error handling for cfs_cpt_table_print
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529875250-11531-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

Instead of setting rc to -EFBIG for several cases in the loop lets
just go to the out label on error which returns -E2BIG directly.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18916
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 29 ++++++++++---------------
 1 file changed, 12 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 3b4a9dc..cdfa77b 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -194,29 +194,26 @@ struct cfs_cpt_table *
 cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
 {
 	char *tmp = buf;
-	int rc = 0;
+	int rc;
 	int i;
 	int j;
 
 	for (i = 0; i < cptab->ctb_nparts; i++) {
-		if (len > 0) {
-			rc = snprintf(tmp, len, "%d\t:", i);
-			len -= rc;
-		}
+		if (len <= 0)
+			goto err;
 
-		if (len <= 0) {
-			rc = -EFBIG;
-			goto out;
-		}
+		rc = snprintf(tmp, len, "%d\t:", i);
+		len -= rc;
+
+		if (len <= 0)
+			goto err;
 
 		tmp += rc;
 		for_each_cpu(j, cptab->ctb_parts[i].cpt_cpumask) {
 			rc = snprintf(tmp, len, "%d ", j);
 			len -= rc;
-			if (len <= 0) {
-				rc = -EFBIG;
-				goto out;
-			}
+			if (len <= 0)
+				goto err;
 			tmp += rc;
 		}
 
@@ -225,11 +222,9 @@ struct cfs_cpt_table *
 		len--;
 	}
 
- out:
-	if (rc < 0)
-		return rc;
-
 	return tmp - buf;
+err:
+	return -E2BIG;
 }
 EXPORT_SYMBOL(cfs_cpt_table_print);
 
-- 
1.8.3.1
