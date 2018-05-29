From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:21:51 -0400
Subject: [lustre-devel] [PATCH v2 11/25] staging: lustre: libcfs: provide
 debugfs files for distance handling
In-Reply-To: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1527603725-30560-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

On systems with large number of NUMA nodes and cores it is easy
to incorrectly configure their use with Lustre. Provide debugfs
files which can help track down any issues.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18916
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
Changelog:

v1) Initial patch
v2) Rebased patch. No code changes from original patch

 drivers/staging/lustre/lnet/libcfs/module.c | 53 +++++++++++++++++++++++++++++
 1 file changed, 53 insertions(+)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index b438d456..d2dfc29 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -468,6 +468,53 @@ static int proc_cpt_table(struct ctl_table *table, int write,
 				    __proc_cpt_table);
 }
 
+static int __proc_cpt_distance(void *data, int write,
+			       loff_t pos, void __user *buffer, int nob)
+{
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
+static int proc_cpt_distance(struct ctl_table *table, int write,
+			     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return lprocfs_call_handler(table->data, write, ppos, buffer, lenp,
+				    __proc_cpt_distance);
+}
+
 static struct ctl_table lnet_table[] = {
 	{
 		.procname = "debug",
@@ -497,6 +544,12 @@ static int proc_cpt_table(struct ctl_table *table, int write,
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
