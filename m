From: Mathias Rav <mathiasrav@gmail.com>
Date: Thu, 18 May 2017 22:49:21 -0400
Subject: [lustre-devel] [PATCH v2 1/2] staging: lustre: Use
	kstrtouint_from_user in ldlm_rw_uint
In-Reply-To: <20170519024922.15222-1-mathiasrav@gmail.com>
References: <20170519024922.15222-1-mathiasrav@gmail.com>
Message-ID: <20170519024922.15222-2-mathiasrav@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: mathiasrav@gmail.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Clean up the helper functions used to implement "dump_granted_max" in
debugfs.

Replace the lprocfs_rd_uint() and lprocfs_wr_uint() generic callbacks
with a simpler, more direct implementation of ldlm_rw_uint_fops.

There's a slight change in lustre debugfs write semantics: Using kstrtox
causes EINVAL when the written number is followed by other (garbage)
characters, whereas previously the garbage would be ignored and such a
write would succeed.

Signed-off-by: Mathias Rav <mathiasrav@gmail.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 20 ++++++++++++-
 .../lustre/lustre/obdclass/lprocfs_status.c        | 34 ----------------------
 2 files changed, 19 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 633f65b078eb..1c8b0ea10c32 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -78,7 +78,25 @@ lprocfs_wr_dump_ns(struct file *file, const char __user *buffer,
 
 LPROC_SEQ_FOPS_WR_ONLY(ldlm, dump_ns);
 
-LPROC_SEQ_FOPS_RW_TYPE(ldlm_rw, uint);
+static int ldlm_rw_uint_seq_show(struct seq_file *m, void *v)
+{
+	seq_printf(m, "%u\n", *(unsigned int *)m->private);
+	return 0;
+}
+
+static ssize_t
+ldlm_rw_uint_seq_write(struct file *file, const char __user *buffer,
+		       size_t count, loff_t *off)
+{
+	struct seq_file *seq = file->private_data;
+
+	if (count == 0)
+		return 0;
+	return kstrtouint_from_user(buffer, count, 0,
+				    (unsigned int *)seq->private);
+}
+
+LPROC_SEQ_FOPS(ldlm_rw_uint);
 
 static struct lprocfs_vars ldlm_debugfs_list[] = {
 	{ "dump_namespaces", &ldlm_dump_ns_fops, NULL, 0222 },
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 1ec6e3767d81..b42c4092bf22 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -389,40 +389,6 @@ struct dentry *ldebugfs_register(const char *name,
 EXPORT_SYMBOL_GPL(ldebugfs_register);
 
 /* Generic callbacks */
-int lprocfs_rd_uint(struct seq_file *m, void *data)
-{
-	seq_printf(m, "%u\n", *(unsigned int *)data);
-	return 0;
-}
-EXPORT_SYMBOL(lprocfs_rd_uint);
-
-int lprocfs_wr_uint(struct file *file, const char __user *buffer,
-		    unsigned long count, void *data)
-{
-	unsigned *p = data;
-	char dummy[MAX_STRING_SIZE + 1], *end;
-	unsigned long tmp;
-
-	if (count >= sizeof(dummy))
-		return -EINVAL;
-
-	if (count == 0)
-		return 0;
-
-	if (copy_from_user(dummy, buffer, count))
-		return -EFAULT;
-
-	dummy[count] = '\0';
-
-	tmp = simple_strtoul(dummy, &end, 0);
-	if (dummy == end)
-		return -EINVAL;
-
-	*p = (unsigned int)tmp;
-	return count;
-}
-EXPORT_SYMBOL(lprocfs_wr_uint);
-
 static ssize_t uuid_show(struct kobject *kobj, struct attribute *attr,
 			 char *buf)
 {
-- 
2.13.0
