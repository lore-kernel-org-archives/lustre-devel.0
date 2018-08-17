From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:39 -0400
Subject: [lustre-devel] [PATCH 36/38] lustre: lmv: update sysfs handling
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-37-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Move all the sysfs/debugfs handling to lproc_lmv.c. Properly
handle failure cases for sysfs/debugfs bring up. Change desc_uuid
into a sysfs files since its a simple one item file so we don't
clutter debugfs.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/28460
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_internal.h |  4 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c      | 17 +++++----
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c    | 48 +++++++++++++-----------
 3 files changed, 37 insertions(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 1b51dfb..f2c41c7 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -157,8 +157,6 @@ struct lmv_tgt_desc
 *lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
 		struct lu_fid *fid);
 /* lproc_lmv.c */
-void lprocfs_lmv_init_vars(struct obd_device *obd);
-
-extern const struct file_operations lmv_proc_target_fops;
+int lmv_tunables_init(struct obd_device *obd);
 
 #endif
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 7d5d03b..cf2a4c6 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -211,6 +211,10 @@ static int lmv_connect(const struct lu_env *env,
 
 	lmv->lmv_tgts_kobj = kobject_create_and_add("target_obds",
 						    &obd->obd_kset.kobj);
+	if (!lmv->lmv_tgts_kobj)
+		CERROR("%s: cannot create /sys/fs/lustre/%s/%s/target_obds\n",
+		       obd->obd_name, obd->obd_type->typ_name, obd->obd_name);
+
 	rc = lmv_check_connect(obd);
 	if (rc)
 		goto out_sysfs;
@@ -1254,22 +1258,19 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	spin_lock_init(&lmv->lmv_lock);
 	mutex_init(&lmv->lmv_init_mutex);
 
-	lprocfs_lmv_init_vars(obd);
+	rc = lmv_tunables_init(obd);
+	if (rc)
+		CWARN("%s: error adding LMV sysfs/debugfs files: rc = %d\n",
+		      obd->obd_name, rc);
 
-	lprocfs_obd_setup(obd, true);
-	debugfs_create_file("target_obd", 0444, obd->obd_debugfs_entry, obd,
-			    &lmv_proc_target_fops);
 	rc = fld_client_init(&lmv->lmv_fld, obd->obd_name,
 			     LUSTRE_CLI_FLD_HASH_DHT);
 	if (rc) {
 		CERROR("Can't init FLD, err %d\n", rc);
-		goto out;
+		return rc;
 	}
 
 	return 0;
-
-out:
-	return rc;
 }
 
 static int lmv_cleanup(struct obd_device *obd)
diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
index 6aae298..efc12ad 100644
--- a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
+++ b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
@@ -37,6 +37,7 @@
 #include <linux/statfs.h>
 #include <lprocfs_status.h>
 #include <obd_class.h>
+
 #include "lmv_internal.h"
 
 static ssize_t numobd_show(struct kobject *kobj, struct attribute *attr,
@@ -63,18 +64,17 @@ static ssize_t activeobd_show(struct kobject *kobj, struct attribute *attr,
 }
 LUSTRE_RO_ATTR(activeobd);
 
-static int lmv_desc_uuid_seq_show(struct seq_file *m, void *v)
+static ssize_t desc_uuid_show(struct kobject *kobj, struct attribute *attr,
+			      char *buf)
 {
-	struct obd_device *dev = (struct obd_device *)m->private;
-	struct lmv_obd	  *lmv;
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct lmv_desc *desc;
 
-	LASSERT(dev);
-	lmv = &dev->u.lmv;
-	seq_printf(m, "%s\n", lmv->desc.ld_uuid.uuid);
-	return 0;
+	desc = &dev->u.lmv.desc;
+	return sprintf(buf, "%s\n", desc->ld_uuid.uuid);
 }
-
-LPROC_SEQ_FOPS_RO(lmv_desc_uuid);
+LUSTRE_RO_ATTR(desc_uuid);
 
 static void *lmv_tgt_seq_start(struct seq_file *p, loff_t *pos)
 {
@@ -115,6 +115,7 @@ static int lmv_tgt_seq_show(struct seq_file *p, void *v)
 
 	if (!tgt)
 		return 0;
+
 	seq_printf(p, "%u: %s %sACTIVE\n",
 		   tgt->ltd_idx, tgt->ltd_uuid.uuid,
 		   tgt->ltd_active ? "" : "IN");
@@ -143,27 +144,32 @@ static int lmv_target_seq_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static struct lprocfs_vars lprocfs_lmv_obd_vars[] = {
-	{ "desc_uuid",	  &lmv_desc_uuid_fops,    NULL, 0 },
-	{ NULL }
-};
-
-const struct file_operations lmv_proc_target_fops = {
+static const struct file_operations lmv_debugfs_target_fops = {
 	.owner		= THIS_MODULE,
-	.open		 = lmv_target_seq_open,
-	.read		 = seq_read,
-	.llseek	       = seq_lseek,
-	.release	      = seq_release,
+	.open		= lmv_target_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
 };
 
 static struct attribute *lmv_attrs[] = {
 	&lustre_attr_activeobd.attr,
+	&lustre_attr_desc_uuid.attr,
 	&lustre_attr_numobd.attr,
 	NULL,
 };
 
-void lprocfs_lmv_init_vars(struct obd_device *obd)
+int lmv_tunables_init(struct obd_device *obd)
 {
-	obd->obd_vars = lprocfs_lmv_obd_vars;
+	int rc;
+
 	obd->obd_ktype.default_attrs = lmv_attrs;
+	rc = lprocfs_obd_setup(obd, true);
+	if (rc)
+		return rc;
+
+	debugfs_create_file("target_obd", 0444, obd->obd_debugfs_entry, obd,
+			    &lmv_debugfs_target_fops);
+
+	return 0;
 }
-- 
1.8.3.1
