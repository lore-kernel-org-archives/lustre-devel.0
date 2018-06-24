From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:20:34 -0400
Subject: [lustre-devel] [PATCH v3 10/26] staging: lustre: libcfs: provide
 debugfs files for distance handling
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529875250-11531-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

On systems with large number of NUMA nodes and cores it is easy
to incorrectly configure their use with Lustre. Provide debugfs
files which can help track down any issues.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18916
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/module.c | 48 +++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 02c404c..2281f08 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -425,6 +425,48 @@ static int proc_cpt_table(struct ctl_table *table, int write,
 	return rc;
 }
 
+static int proc_cpt_distance(struct ctl_table *table, int write,
+			     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	size_t nob = *lenp;
+	loff_t pos = *ppos;
+	char *buf = NULL;
+	int len = 4096;
+	int rc = 0;
+
+	if (write)
+		return -EPERM;
+
+	LASSERT(cfs_cpt_tab);
+
+	while (1) {
+		buf = kzalloc(len, GFP_KERNEL);
+		if (!buf)
+			return -ENOMEM;
+
+		rc = cfs_cpt_distance_print(cfs_cpt_tab, buf, len);
+		if (rc >= 0)
+			break;
+
+		if (rc == -EFBIG) {
+			kfree(buf);
+			len <<= 1;
+			continue;
+		}
+		goto out;
+	}
+
+	if (pos >= rc) {
+		rc = 0;
+		goto out;
+	}
+
+	rc = cfs_trace_copyout_string(buffer, nob, buf + pos, NULL);
+out:
+	kfree(buf);
+	return rc;
+}
+
 static struct ctl_table lnet_table[] = {
 	{
 		.procname = "debug",
@@ -454,6 +496,12 @@ static int proc_cpt_table(struct ctl_table *table, int write,
 		.proc_handler = &proc_cpt_table,
 	},
 	{
+		.procname = "cpu_partition_distance",
+		.maxlen	  = 128,
+		.mode	  = 0444,
+		.proc_handler = &proc_cpt_distance,
+	},
+	{
 		.procname = "debug_log_upcall",
 		.data     = lnet_debug_log_upcall,
 		.maxlen   = sizeof(lnet_debug_log_upcall),
-- 
1.8.3.1
