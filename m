From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:40 -0400
Subject: [lustre-devel] [PATCH 37/38] lustre: lov: update sysfs handling
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-38-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Move all the sysfs/debugfs handling to lproc_lov.c. Properly
handle failure cases for sysfs/debugfs bring up. Migrate all
the debugfs files to sys so we don't clutter debugfs.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/30960
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_internal.h |   3 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c      |  40 +++--
 drivers/staging/lustre/lustre/lov/lproc_lov.c    | 213 +++++++++++------------
 3 files changed, 131 insertions(+), 125 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 7e0b9ac..dbb79d4 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -240,8 +240,7 @@ struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, struct lov_mds_md *lmm,
 void dump_lsm(unsigned int level, const struct lov_stripe_md *lsm);
 
 /* lproc_lov.c */
-extern const struct file_operations lov_proc_target_fops;
-void lprocfs_lov_init_vars(struct obd_device *obd);
+int lov_tunables_init(struct obd_device *obd);
 
 /* lov_cl.c */
 extern struct lu_device_type lov_device_type;
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 28b7d91..3483f9b 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -189,12 +189,19 @@ int lov_connect_obd(struct obd_device *obd, __u32 index, int activate,
 	CDEBUG(D_CONFIG, "Connected tgt idx %d %s (%s) %sactive\n", index,
 	       obd_uuid2str(tgt_uuid), tgt_obd->obd_name, activate ? "":"in");
 
-	if (lov->lov_tgts_kobj)
+	if (lov->lov_tgts_kobj) {
 		/* Even if we failed, that's ok */
 		rc = sysfs_create_link(lov->lov_tgts_kobj,
 				       &tgt_obd->obd_kset.kobj,
 				       tgt_obd->obd_name);
-
+		if (rc) {
+			CERROR("%s: can't register LOV target /sys/fs/lustre/%s/%s/target_obds/%s : rc = %d\n",
+			       obd->obd_name, obd->obd_type->typ_name,
+			       obd->obd_name,
+			       lov->lov_tgts[index]->ltd_exp->exp_obd->obd_name,
+			       rc);
+		}
+	}
 	return 0;
 }
 
@@ -764,22 +771,23 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	lov->lov_pool_count = 0;
 	rc = lov_pool_hash_init(&lov->lov_pools_hash_body);
 	if (rc)
-		goto out;
+		goto out_hash;
+
 	rc = lov_ost_pool_init(&lov->lov_packed, 0);
 	if (rc)
-		goto out;
-
-	lprocfs_lov_init_vars(obd);
-	lprocfs_obd_setup(obd, false);
+		goto out_pool;
 
-	debugfs_create_file("target_obd", 0444, obd->obd_debugfs_entry, obd,
-			    &lov_proc_target_fops);
+	rc = lov_tunables_init(obd);
+	if (rc)
+		goto out_tunables;
 
-	lov->lov_pool_debugfs_entry = debugfs_create_dir("pools",
-							 obd->obd_debugfs_entry);
 	return 0;
 
-out:
+out_tunables:
+	lov_ost_pool_free(&lov->lov_packed);
+out_pool:
+	lov_pool_hash_destroy(&lov->lov_pools_hash_body);
+out_hash:
 	return rc;
 }
 
@@ -873,16 +881,16 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
 	}
 	case LCFG_PARAM: {
 		struct lov_desc *desc = &obd->u.lov.desc;
+		ssize_t count;
 
 		if (!desc) {
 			rc = -EINVAL;
 			goto out;
 		}
 
-		rc = class_process_proc_param(PARAM_LOV, obd->obd_vars,
-					      lcfg, obd);
-		if (rc > 0)
-			rc = 0;
+		count = class_modify_config(lcfg, PARAM_LOV,
+					    &obd->obd_kset.kobj);
+		rc = count < 0 ? count : 0;
 		goto out;
 	}
 	case LCFG_POOL_NEW:
diff --git a/drivers/staging/lustre/lustre/lov/lproc_lov.c b/drivers/staging/lustre/lustre/lov/lproc_lov.c
index 9c5d6fc..771c6f8 100644
--- a/drivers/staging/lustre/lustre/lov/lproc_lov.c
+++ b/drivers/staging/lustre/lustre/lov/lproc_lov.c
@@ -38,134 +38,131 @@
 #include <linux/seq_file.h>
 #include "lov_internal.h"
 
-static int lov_stripesize_seq_show(struct seq_file *m, void *v)
+static ssize_t stripesize_show(struct kobject *kobj, struct attribute *attr,
+			       char *buf)
 {
-	struct obd_device *dev = (struct obd_device *)m->private;
-	struct lov_desc *desc;
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct lov_desc *desc = &dev->u.lov.desc;
 
-	LASSERT(dev);
-	desc = &dev->u.lov.desc;
-	seq_printf(m, "%llu\n", desc->ld_default_stripe_size);
-	return 0;
+	return sprintf(buf, "%llu\n", desc->ld_default_stripe_size);
 }
 
-static ssize_t lov_stripesize_seq_write(struct file *file,
-					const char __user *buffer,
-					size_t count, loff_t *off)
+static ssize_t stripesize_store(struct kobject *kobj, struct attribute *attr,
+				const char *buf, size_t count)
 {
-	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
-	struct lov_desc *desc;
-	__u64 val;
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct lov_desc *desc = &dev->u.lov.desc;
+	u64 val;
 	int rc;
 
-	LASSERT(dev);
-	desc = &dev->u.lov.desc;
-	rc = lprocfs_write_u64_helper(buffer, count, &val);
+	rc = kstrtoull(buf, 10, &val);
 	if (rc)
 		return rc;
 
 	lov_fix_desc_stripe_size(&val);
 	desc->ld_default_stripe_size = val;
+
 	return count;
 }
+LUSTRE_RW_ATTR(stripesize);
 
-LPROC_SEQ_FOPS(lov_stripesize);
-
-static int lov_stripeoffset_seq_show(struct seq_file *m, void *v)
+static ssize_t stripeoffset_show(struct kobject *kobj, struct attribute *attr,
+				 char *buf)
 {
-	struct obd_device *dev = (struct obd_device *)m->private;
-	struct lov_desc *desc;
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct lov_desc *desc = &dev->u.lov.desc;
 
-	LASSERT(dev);
-	desc = &dev->u.lov.desc;
-	seq_printf(m, "%llu\n", desc->ld_default_stripe_offset);
-	return 0;
+	return sprintf(buf, "%llu\n", desc->ld_default_stripe_offset);
 }
 
-static ssize_t lov_stripeoffset_seq_write(struct file *file,
-					  const char __user *buffer,
-					  size_t count, loff_t *off)
+static ssize_t stripeoffset_store(struct kobject *kobj, struct attribute *attr,
+				  const char *buf, size_t count)
 {
-	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
-	struct lov_desc *desc;
-	__u64 val;
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct lov_desc *desc = &dev->u.lov.desc;
+	long val;
 	int rc;
 
-	LASSERT(dev);
-	desc = &dev->u.lov.desc;
-	rc = lprocfs_write_u64_helper(buffer, count, &val);
+	rc = kstrtol(buf, 0, &val);
 	if (rc)
 		return rc;
 
+	if (val < -1 || val > LOV_MAX_STRIPE_COUNT)
+		return -ERANGE;
+
 	desc->ld_default_stripe_offset = val;
+
 	return count;
 }
+LUSTRE_RW_ATTR(stripeoffset);
 
-LPROC_SEQ_FOPS(lov_stripeoffset);
-
-static int lov_stripetype_seq_show(struct seq_file *m, void *v)
+static ssize_t stripetype_show(struct kobject *kobj, struct attribute *attr,
+			       char *buf)
 {
-	struct obd_device *dev = (struct obd_device *)m->private;
-	struct lov_desc *desc;
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct lov_desc *desc = &dev->u.lov.desc;
 
-	LASSERT(dev);
-	desc = &dev->u.lov.desc;
-	seq_printf(m, "%u\n", desc->ld_pattern);
-	return 0;
+	return sprintf(buf, "%u\n", desc->ld_pattern);
 }
 
-static ssize_t lov_stripetype_seq_write(struct file *file,
-					const char __user *buffer,
-					size_t count, loff_t *off)
+static ssize_t stripetype_store(struct kobject *kobj, struct attribute *attr,
+				const char *buffer, size_t count)
 {
-	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
-	struct lov_desc *desc;
-	int val, rc;
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct lov_desc *desc = &dev->u.lov.desc;
+	u32 pattern;
+	int rc;
 
-	LASSERT(dev);
-	desc = &dev->u.lov.desc;
-	rc = lprocfs_write_helper(buffer, count, &val);
+	rc = kstrtouint(buffer, 0, &pattern);
 	if (rc)
 		return rc;
 
-	lov_fix_desc_pattern(&val);
-	desc->ld_pattern = val;
+	lov_fix_desc_pattern(&pattern);
+	desc->ld_pattern = pattern;
+
 	return count;
 }
+LUSTRE_RW_ATTR(stripetype);
 
-LPROC_SEQ_FOPS(lov_stripetype);
-
-static int lov_stripecount_seq_show(struct seq_file *m, void *v)
+static ssize_t stripecount_show(struct kobject *kobj, struct attribute *attr,
+				char *buf)
 {
-	struct obd_device *dev = (struct obd_device *)m->private;
-	struct lov_desc *desc;
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct lov_desc *desc = &dev->u.lov.desc;
 
-	LASSERT(dev);
-	desc = &dev->u.lov.desc;
-	seq_printf(m, "%d\n", (__s16)(desc->ld_default_stripe_count + 1) - 1);
-	return 0;
+	return sprintf(buf, "%d\n",
+		       (s16)(desc->ld_default_stripe_count + 1) - 1);
 }
 
-static ssize_t lov_stripecount_seq_write(struct file *file,
-					 const char __user *buffer,
-					 size_t count, loff_t *off)
+static ssize_t stripecount_store(struct kobject *kobj, struct attribute *attr,
+				 const char *buffer, size_t count)
 {
-	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
-	struct lov_desc *desc;
-	int val, rc;
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct lov_desc *desc = &dev->u.lov.desc;
+	int stripe_count;
+	int rc;
 
-	LASSERT(dev);
-	desc = &dev->u.lov.desc;
-	rc = lprocfs_write_helper(buffer, count, &val);
+	rc = kstrtoint(buffer, 0, &stripe_count);
 	if (rc)
 		return rc;
 
-	lov_fix_desc_stripe_count(&val);
-	desc->ld_default_stripe_count = val;
+	if (stripe_count < -1)
+		return -ERANGE;
+
+	lov_fix_desc_stripe_count(&stripe_count);
+	desc->ld_default_stripe_count = stripe_count;
+
 	return count;
 }
-
-LPROC_SEQ_FOPS(lov_stripecount);
+LUSTRE_RW_ATTR(stripecount);
 
 static ssize_t numobd_show(struct kobject *kobj, struct attribute *attr,
 			   char *buf)
@@ -191,18 +188,16 @@ static ssize_t activeobd_show(struct kobject *kobj, struct attribute *attr,
 }
 LUSTRE_RO_ATTR(activeobd);
 
-static int lov_desc_uuid_seq_show(struct seq_file *m, void *v)
+static ssize_t desc_uuid_show(struct kobject *kobj, struct attribute *attr,
+			      char *buf)
 {
-	struct obd_device *dev = (struct obd_device *)m->private;
-	struct lov_obd *lov;
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct lov_desc *desc = &dev->u.lov.desc;
 
-	LASSERT(dev);
-	lov = &dev->u.lov;
-	seq_printf(m, "%s\n", lov->desc.ld_uuid.uuid);
-	return 0;
+	return sprintf(buf, "%s\n", desc->ld_uuid.uuid);
 }
-
-LPROC_SEQ_FOPS_RO(lov_desc_uuid);
+LUSTRE_RO_ATTR(desc_uuid);
 
 static void *lov_tgt_seq_start(struct seq_file *p, loff_t *pos)
 {
@@ -264,36 +259,40 @@ static int lov_target_seq_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static struct lprocfs_vars lprocfs_lov_obd_vars[] = {
-	{ "stripesize",   &lov_stripesize_fops,   NULL },
-	{ "stripeoffset", &lov_stripeoffset_fops, NULL },
-	{ "stripecount",  &lov_stripecount_fops,  NULL },
-	{ "stripetype",   &lov_stripetype_fops,   NULL },
-	/*{ "filegroups", lprocfs_rd_filegroups,  NULL, 0 },*/
-	{ "desc_uuid",    &lov_desc_uuid_fops,    NULL, 0 },
-	{ NULL }
+static const struct file_operations lov_debugfs_target_fops = {
+	.owner   = THIS_MODULE,
+	.open    = lov_target_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = lprocfs_seq_release,
 };
 
 static struct attribute *lov_attrs[] = {
 	&lustre_attr_activeobd.attr,
 	&lustre_attr_numobd.attr,
+	&lustre_attr_desc_uuid.attr,
+	&lustre_attr_stripesize.attr,
+	&lustre_attr_stripeoffset.attr,
+	&lustre_attr_stripetype.attr,
+	&lustre_attr_stripecount.attr,
 	NULL,
 };
 
-static const struct attribute_group lov_attr_group = {
-	.attrs = lov_attrs,
-};
-
-void lprocfs_lov_init_vars(struct obd_device *obd)
+int lov_tunables_init(struct obd_device *obd)
 {
-	obd->obd_vars = lprocfs_lov_obd_vars;
+	struct lov_obd *lov = &obd->u.lov;
+	int rc;
+
 	obd->obd_ktype.default_attrs = lov_attrs;
-}
+	rc = lprocfs_obd_setup(obd, false);
+	if (rc)
+		return rc;
 
-const struct file_operations lov_proc_target_fops = {
-	.owner   = THIS_MODULE,
-	.open    = lov_target_seq_open,
-	.read    = seq_read,
-	.llseek  = seq_lseek,
-	.release = lprocfs_seq_release,
-};
+	debugfs_create_file("target_obd", 0444, obd->obd_debugfs_entry, obd,
+			    &lov_debugfs_target_fops);
+
+	lov->lov_pool_debugfs_entry = debugfs_create_dir("pools",
+							 obd->obd_debugfs_entry);
+
+	return 0;
+}
-- 
1.8.3.1
