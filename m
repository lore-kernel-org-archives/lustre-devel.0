From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:14 -0400
Subject: [lustre-devel] [PATCH 11/38] lustre: llite: create
 ll_stats_pid_write()
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Steve Guminski <stephenx.guminski@intel.com>

Several repeated code blocks are consolidated into a new function,
ll_stats_pid_write(), to reduce duplication.

Signed-off-by: Steve Guminski <stephenx.guminski@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8767
Reviewed-on: https://review.whamcloud.com/23942
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/lproc_llite.c | 90 +++++++++++------------
 1 file changed, 41 insertions(+), 49 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 0dc4d00..f57ad15 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -95,6 +95,41 @@ void llite_tunables_unregister(void)
 static const struct file_operations ll_rw_extents_stats_pp_fops;
 static const struct file_operations ll_rw_offset_stats_fops;
 
+/**
+ * ll_stats_pid_write() - Determine if stats collection should be enabled
+ * @buf: Buffer containing the data written
+ * @len: Number of bytes in the buffer
+ *
+ * Several proc files begin collecting stats when a value is written, and stop
+ * collecting when either '0' or 'disable' is written. This function checks the
+ * written value to see if collection should be enabled or disabled.
+ *
+ * Return: If '0' or 'disable' is provided, 0 is returned. If the text
+ * equivalent of a number is written, that number is returned. Otherwise,
+ * 1 is returned. Non-zero return values indicate collection should be enabled.
+ */
+static s64 ll_stats_pid_write(const char __user *buf, size_t len)
+{
+	unsigned long long value = 1;
+	char kernbuf[16];
+	int rc;
+
+	rc = kstrtoull_from_user(buf, len, 0, &value);
+	if (rc < 0 && len < sizeof(kernbuf)) {
+		if (copy_from_user(kernbuf, buf, len))
+			return -EFAULT;
+		kernbuf[len] = 0;
+
+		if (kernbuf[len - 1] == '\n')
+			kernbuf[len - 1] = 0;
+
+		if (strncasecmp(kernbuf, "disable", 7) == 0)
+			value = 0;
+	}
+
+	return value;
+}
+
 static ssize_t blocksize_show(struct kobject *kobj, struct attribute *attr,
 			      char *buf)
 {
@@ -1425,26 +1460,12 @@ static ssize_t ll_rw_extents_stats_pp_seq_write(struct file *file,
 	struct ll_sb_info *sbi = seq->private;
 	struct ll_rw_extents_info *io_extents = &sbi->ll_rw_extents_info;
 	int i;
-	int value = 1, rc = 0;
+	s64 value;
 
 	if (len == 0)
 		return -EINVAL;
 
-	rc = lprocfs_write_helper(buf, len, &value);
-	if (rc < 0 && len < 16) {
-		char kernbuf[16];
-
-		if (copy_from_user(kernbuf, buf, len))
-			return -EFAULT;
-		kernbuf[len] = 0;
-
-		if (kernbuf[len - 1] == '\n')
-			kernbuf[len - 1] = 0;
-
-		if (strcmp(kernbuf, "disabled") == 0 ||
-		    strcmp(kernbuf, "Disabled") == 0)
-			value = 0;
-	}
+	value = ll_stats_pid_write(buf, len);
 
 	if (value == 0)
 		sbi->ll_rw_stats_on = 0;
@@ -1498,26 +1519,12 @@ static ssize_t ll_rw_extents_stats_seq_write(struct file *file,
 	struct ll_sb_info *sbi = seq->private;
 	struct ll_rw_extents_info *io_extents = &sbi->ll_rw_extents_info;
 	int i;
-	int value = 1, rc = 0;
+	s64 value;
 
 	if (len == 0)
 		return -EINVAL;
 
-	rc = lprocfs_write_helper(buf, len, &value);
-	if (rc < 0 && len < 16) {
-		char kernbuf[16];
-
-		if (copy_from_user(kernbuf, buf, len))
-			return -EFAULT;
-		kernbuf[len] = 0;
-
-		if (kernbuf[len - 1] == '\n')
-			kernbuf[len - 1] = 0;
-
-		if (strcmp(kernbuf, "disabled") == 0 ||
-		    strcmp(kernbuf, "Disabled") == 0)
-			value = 0;
-	}
+	value = ll_stats_pid_write(buf, len);
 
 	if (value == 0)
 		sbi->ll_rw_stats_on = 0;
@@ -1702,27 +1709,12 @@ static ssize_t ll_rw_offset_stats_seq_write(struct file *file,
 	struct ll_sb_info *sbi = seq->private;
 	struct ll_rw_process_info *process_info = sbi->ll_rw_process_info;
 	struct ll_rw_process_info *offset_info = sbi->ll_rw_offset_info;
-	int value = 1, rc = 0;
+	s64 value;
 
 	if (len == 0)
 		return -EINVAL;
 
-	rc = lprocfs_write_helper(buf, len, &value);
-
-	if (rc < 0 && len < 16) {
-		char kernbuf[16];
-
-		if (copy_from_user(kernbuf, buf, len))
-			return -EFAULT;
-		kernbuf[len] = 0;
-
-		if (kernbuf[len - 1] == '\n')
-			kernbuf[len - 1] = 0;
-
-		if (strcmp(kernbuf, "disabled") == 0 ||
-		    strcmp(kernbuf, "Disabled") == 0)
-			value = 0;
-	}
+	value = ll_stats_pid_write(buf, len);
 
 	if (value == 0)
 		sbi->ll_rw_stats_on = 0;
-- 
1.8.3.1
