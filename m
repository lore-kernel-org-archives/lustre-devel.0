From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:53 -0400
Subject: [lustre-devel] [PATCH 09/10] lustre: libcfs: return ssize_t for
 lnet_debugfs_*
In-Reply-To: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
References: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573894-20592-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The debugfs layer expects both lnet_debugfs_read() and
lnet_debugfs_write() to return ssize_t instead of int.
Change the return type.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24688
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/module.c | 30 ++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 0d36121..793cc03 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -583,37 +583,37 @@ static ssize_t lnet_debugfs_read(struct file *filp, char __user *buf,
 				 size_t count, loff_t *ppos)
 {
 	struct ctl_table *table = filp->private_data;
-	int error;
 	loff_t old_pos = *ppos;
+	ssize_t rc;
 
-	error = table->proc_handler(table, 0, (void __user *)buf, &count, ppos);
+	rc = table->proc_handler(table, 0, (void __user *)buf, &count, ppos);
 	/*
 	 * On success, the length read is either in error or in count.
 	 * If ppos changed, then use count, else use error
 	 */
-	if (!error && *ppos != old_pos)
-		error = count;
-	else if (error > 0)
-		*ppos += error;
+	if (!rc && *ppos != old_pos)
+		rc = count;
+	else if (rc > 0)
+		*ppos += rc;
 
-	return error;
+	return rc;
 }
 
 static ssize_t lnet_debugfs_write(struct file *filp, const char __user *buf,
 				  size_t count, loff_t *ppos)
 {
 	struct ctl_table *table = filp->private_data;
-	int error;
 	loff_t old_pos = *ppos;
+	ssize_t rc;
 
-	error = table->proc_handler(table, 1, (void __user *)buf, &count, ppos);
-	if (!error) {
-		error = count;
-		if (*ppos == old_pos)
-			*ppos += count;
-	}
+	rc = table->proc_handler(table, 1, (void __user *)buf, &count, ppos);
+	if (rc)
+		return rc;
+
+	if (*ppos == old_pos)
+		*ppos += count;
 
-	return error;
+	return count;
 }
 
 static const struct file_operations lnet_debugfs_file_operations_rw = {
-- 
1.8.3.1
