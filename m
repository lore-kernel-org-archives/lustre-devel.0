From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:25 -0400
Subject: [lustre-devel] [PATCH 22/38] lustre: obd: migrate to ksets
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre's obd_device sysfs only uses kobjects but with the introduction of
ksets we can use functionality like kset_find_kobj() and uevents.
Currently lustre is layered as lustre_kobj -> class -> obd device.
This patch changes the obd devices and the top level lustre_kobj
into ksets. The class level is kept as kobjects but are bound to
the top level lustre kset so they searchable and uevents can be
created for them. Also much of the class functionality can be
replaced with what ksets can do.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/28948
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lprocfs_status.h |  3 +-
 drivers/staging/lustre/lustre/include/obd.h        |  9 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |  2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  4 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  3 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  5 ++-
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c      |  4 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |  5 ++-
 drivers/staging/lustre/lustre/lov/lproc_lov.c      |  4 +-
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      | 14 +++---
 drivers/staging/lustre/lustre/obdclass/genops.c    | 35 ++++++++++-----
 .../lustre/lustre/obdclass/lprocfs_status.c        | 41 +++++++++++-------
 drivers/staging/lustre/lustre/obdclass/module.c    | 17 ++++----
 drivers/staging/lustre/lustre/obdclass/sysctl.c    |  2 +-
 drivers/staging/lustre/lustre/osc/lproc_osc.c      | 50 +++++++++++-----------
 15 files changed, 116 insertions(+), 82 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index f428ce0..3863fff 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -339,7 +339,7 @@ enum {
 #define EXTRA_FIRST_OPC LDLM_GLIMPSE_ENQUEUE
 /* class_obd.c */
 extern struct dentry *debugfs_lustre_root;
-extern struct kobject *lustre_kobj;
+extern struct kset *lustre_kset;
 
 struct obd_device;
 struct obd_histogram;
@@ -572,6 +572,7 @@ struct lustre_attr {
 #define LUSTRE_ATTR(name, mode, show, store) \
 static struct lustre_attr lustre_attr_##name = __ATTR(name, mode, show, store)
 
+#define LUSTRE_WO_ATTR(name) LUSTRE_ATTR(name, 0200, NULL, name##_store)
 #define LUSTRE_RO_ATTR(name) LUSTRE_ATTR(name, 0444, name##_show, NULL)
 #define LUSTRE_RW_ATTR(name) LUSTRE_ATTR(name, 0644, name##_show, name##_store)
 
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 55aa035..36f6c10 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -34,7 +34,9 @@
 #ifndef __OBD_H
 #define __OBD_H
 
+#include <linux/kobject.h>
 #include <linux/spinlock.h>
+#include <linux/sysfs.h>
 
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <lustre_lib.h>
@@ -109,7 +111,8 @@ struct obd_type {
 	int  typ_refcnt;
 	struct lu_device_type *typ_lu;
 	spinlock_t obd_type_lock;
-	struct kobject *typ_kobj;
+	struct kobject		typ_kobj;
+	struct completion	typ_kobj_unregister;
 };
 
 struct brw_page {
@@ -623,9 +626,9 @@ struct obd_device {
 	 */
 	struct lu_ref	  obd_reference;
 
-	struct kobject		obd_kobj; /* sysfs object */
+	struct kset			obd_kset; /* sysfs object collection */
 	struct kobj_type		obd_ktype;
-	struct completion	obd_kobj_unregister;
+	struct completion		obd_kobj_unregister;
 };
 
 int obd_uuid_add(struct obd_device *obd, struct obd_export *export);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 0ee4798..adc96b6 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -956,7 +956,7 @@ static int ldlm_setup(void)
 	if (!ldlm_state)
 		return -ENOMEM;
 
-	ldlm_kobj = kobject_create_and_add("ldlm", lustre_kobj);
+	ldlm_kobj = kobject_create_and_add("ldlm", &lustre_kset->kobj);
 	if (!ldlm_kobj) {
 		rc = -ENOMEM;
 		goto out;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index ce072da..7765060 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -574,7 +574,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	if (sbi->ll_dt_obd) {
 		err = sysfs_create_link(&sbi->ll_kset.kobj,
-					&sbi->ll_dt_obd->obd_kobj,
+					&sbi->ll_dt_obd->obd_kset.kobj,
 					sbi->ll_dt_obd->obd_type->typ_name);
 		if (err < 0) {
 			CERROR("%s: could not register %s in llite: rc = %d\n",
@@ -585,7 +585,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	if (sbi->ll_md_obd) {
 		err = sysfs_create_link(&sbi->ll_kset.kobj,
-					&sbi->ll_md_obd->obd_kobj,
+					&sbi->ll_md_obd->obd_kset.kobj,
 					sbi->ll_md_obd->obd_type->typ_name);
 		if (err < 0) {
 			CERROR("%s: could not register %s in llite: rc = %d\n",
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index c2d27d7..ab2f102 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -63,8 +63,9 @@ int llite_tunables_register(void)
 	if (!kobj)
 		return -ENOMEM;
 
+	kobj->kset = lustre_kset;
 	kobject_init(kobj, &class_ktype);
-	rc = kobject_add(kobj, lustre_kobj, "%s", name);
+	rc = kobject_add(kobj, &lustre_kset->kobj, "%s", name);
 	if (rc) {
 		kobject_put(kobj);
 		return -ENOMEM;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index c36ecb7..7d5d03b 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -210,7 +210,7 @@ static int lmv_connect(const struct lu_env *env,
 	lmv->conn_data = *data;
 
 	lmv->lmv_tgts_kobj = kobject_create_and_add("target_obds",
-						    &obd->obd_kobj);
+						    &obd->obd_kset.kobj);
 	rc = lmv_check_connect(obd);
 	if (rc)
 		goto out_sysfs;
@@ -349,7 +349,8 @@ static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 
 	if (lmv->lmv_tgts_kobj)
 		/* Even if we failed to create the link, that's fine */
-		rc = sysfs_create_link(lmv->lmv_tgts_kobj, &mdc_obd->obd_kobj,
+		rc = sysfs_create_link(lmv->lmv_tgts_kobj,
+				       &mdc_obd->obd_kset.kobj,
 				       mdc_obd->obd_name);
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
index c54227d..6aae298 100644
--- a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
+++ b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
@@ -43,7 +43,7 @@ static ssize_t numobd_show(struct kobject *kobj, struct attribute *attr,
 			   char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct lmv_desc *desc;
 
 	desc = &dev->u.lmv.desc;
@@ -55,7 +55,7 @@ static ssize_t activeobd_show(struct kobject *kobj, struct attribute *attr,
 			      char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct lmv_desc *desc;
 
 	desc = &dev->u.lmv.desc;
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 751bf64..28b7d91 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -191,7 +191,8 @@ int lov_connect_obd(struct obd_device *obd, __u32 index, int activate,
 
 	if (lov->lov_tgts_kobj)
 		/* Even if we failed, that's ok */
-		rc = sysfs_create_link(lov->lov_tgts_kobj, &tgt_obd->obd_kobj,
+		rc = sysfs_create_link(lov->lov_tgts_kobj,
+				       &tgt_obd->obd_kset.kobj,
 				       tgt_obd->obd_name);
 
 	return 0;
@@ -226,7 +227,7 @@ static int lov_connect(const struct lu_env *env,
 	obd_getref(obd);
 
 	lov->lov_tgts_kobj = kobject_create_and_add("target_obds",
-						    &obd->obd_kobj);
+						    &obd->obd_kset.kobj);
 
 	for (i = 0; i < lov->desc.ld_tgt_count; i++) {
 		tgt = lov->lov_tgts[i];
diff --git a/drivers/staging/lustre/lustre/lov/lproc_lov.c b/drivers/staging/lustre/lustre/lov/lproc_lov.c
index ca86f16..9c5d6fc 100644
--- a/drivers/staging/lustre/lustre/lov/lproc_lov.c
+++ b/drivers/staging/lustre/lustre/lov/lproc_lov.c
@@ -171,7 +171,7 @@ static ssize_t numobd_show(struct kobject *kobj, struct attribute *attr,
 			   char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct lov_desc *desc;
 
 	desc = &dev->u.lov.desc;
@@ -183,7 +183,7 @@ static ssize_t activeobd_show(struct kobject *kobj, struct attribute *attr,
 			      char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct lov_desc *desc;
 
 	desc = &dev->u.lov.desc;
diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index fc5f3a3..47f23d6 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -41,7 +41,7 @@ static ssize_t active_show(struct kobject *kobj, struct attribute *attr,
 			   char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 
 	return sprintf(buf, "%u\n", !dev->u.cli.cl_import->imp_deactive);
 }
@@ -50,7 +50,7 @@ static ssize_t active_store(struct kobject *kobj, struct attribute *attr,
 			    const char *buffer, size_t count)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	unsigned long val;
 	int rc;
 
@@ -79,7 +79,7 @@ static ssize_t max_rpcs_in_flight_show(struct kobject *kobj,
 {
 	int len;
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	__u32 max;
 
 	max = obd_get_max_rpcs_in_flight(&dev->u.cli);
@@ -94,7 +94,7 @@ static ssize_t max_rpcs_in_flight_store(struct kobject *kobj,
 					size_t count)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	int rc;
 	unsigned long val;
 
@@ -115,7 +115,7 @@ static ssize_t max_mod_rpcs_in_flight_show(struct kobject *kobj,
 					   char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	u16 max;
 	int len;
 
@@ -131,7 +131,7 @@ static ssize_t max_mod_rpcs_in_flight_store(struct kobject *kobj,
 					    size_t count)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	u16 val;
 	int rc;
 
@@ -187,7 +187,7 @@ static ssize_t max_pages_per_rpc_show(struct kobject *kobj,
 				      char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
 
 	return sprintf(buf, "%d\n", cli->cl_max_pages_per_rpc);
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 532418e..bf182e5 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -133,6 +133,19 @@ void class_put_type(struct obd_type *type)
 	spin_unlock(&type->obd_type_lock);
 }
 
+static void class_sysfs_release(struct kobject *kobj)
+{
+	struct obd_type *type = container_of(kobj, struct obd_type,
+					     typ_kobj);
+
+	complete(&type->typ_kobj_unregister);
+}
+
+static struct kobj_type class_ktype = {
+	.sysfs_ops	= &lustre_sysfs_ops,
+	.release	= class_sysfs_release,
+};
+
 #define CLASS_MAX_NAME 1024
 
 int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
@@ -174,17 +187,21 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	type->typ_debugfs_entry = debugfs_create_dir(type->typ_name,
 						     debugfs_lustre_root);
 
-	type->typ_kobj = kobject_create_and_add(type->typ_name, lustre_kobj);
-	if (!type->typ_kobj) {
-		rc = -ENOMEM;
+	type->typ_kobj.kset = lustre_kset;
+	init_completion(&type->typ_kobj_unregister);
+	rc = kobject_init_and_add(&type->typ_kobj, &class_ktype,
+				  &lustre_kset->kobj, "%s", type->typ_name);
+	if (rc)
 		goto failed;
-	}
+
 
 	if (ldt) {
 		type->typ_lu = ldt;
 		rc = lu_device_type_init(ldt);
-		if (rc != 0)
+		if (rc != 0) {
+			kobject_put(&type->typ_kobj);
 			goto failed;
+		}
 	}
 
 	spin_lock(&obd_types_lock);
@@ -193,9 +210,7 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 
 	return 0;
 
- failed:
-	if (type->typ_kobj)
-		kobject_put(type->typ_kobj);
+failed:
 	kfree(type->typ_name);
 	kfree(type->typ_md_ops);
 	kfree(type->typ_dt_ops);
@@ -222,8 +237,8 @@ int class_unregister_type(const char *name)
 		return -EBUSY;
 	}
 
-	if (type->typ_kobj)
-		kobject_put(type->typ_kobj);
+	kobject_put(&type->typ_kobj);
+	wait_for_completion(&type->typ_kobj_unregister);
 
 	debugfs_remove_recursive(type->typ_debugfs_entry);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 91d37fc..b3ba554 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -353,7 +353,7 @@ static ssize_t uuid_show(struct kobject *kobj, struct attribute *attr,
 			 char *buf)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 
 	return sprintf(buf, "%s\n", obd->obd_uuid.uuid);
 }
@@ -363,7 +363,7 @@ static ssize_t blocksize_show(struct kobject *kobj, struct attribute *attr,
 			      char *buf)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct obd_statfs  osfs;
 	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
 			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
@@ -379,7 +379,7 @@ static ssize_t kbytestotal_show(struct kobject *kobj, struct attribute *attr,
 				char *buf)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct obd_statfs  osfs;
 	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
 			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
@@ -402,7 +402,7 @@ static ssize_t kbytesfree_show(struct kobject *kobj, struct attribute *attr,
 			       char *buf)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct obd_statfs  osfs;
 	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
 			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
@@ -425,7 +425,7 @@ static ssize_t kbytesavail_show(struct kobject *kobj, struct attribute *attr,
 				char *buf)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct obd_statfs  osfs;
 	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
 			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
@@ -448,7 +448,7 @@ static ssize_t filestotal_show(struct kobject *kobj, struct attribute *attr,
 			       char *buf)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct obd_statfs  osfs;
 	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
 			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
@@ -464,7 +464,7 @@ static ssize_t filesfree_show(struct kobject *kobj, struct attribute *attr,
 			      char *buf)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct obd_statfs  osfs;
 	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
 			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
@@ -1008,7 +1008,7 @@ int lprocfs_rd_connect_flags(struct seq_file *m, void *data)
 static void obd_sysfs_release(struct kobject *kobj)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 
 	complete(&obd->obd_kobj_unregister);
 }
@@ -1017,13 +1017,20 @@ int lprocfs_obd_setup(struct obd_device *obd, bool uuid_only)
 {
 	int rc;
 
+	if (!obd || obd->obd_magic != OBD_DEVICE_MAGIC)
+		return -ENODEV;
+
+	rc = kobject_set_name(&obd->obd_kset.kobj, "%s", obd->obd_name);
+	if (rc)
+		return rc;
+
 	obd->obd_ktype.sysfs_ops = &lustre_sysfs_ops;
 	obd->obd_ktype.release = obd_sysfs_release;
 
+	obd->obd_kset.kobj.parent = &obd->obd_type->typ_kobj;
+	obd->obd_kset.kobj.ktype = &obd->obd_ktype;
 	init_completion(&obd->obd_kobj_unregister);
-	rc = kobject_init_and_add(&obd->obd_kobj, &obd->obd_ktype,
-				  obd->obd_type->typ_kobj,
-				  "%s", obd->obd_name);
+	rc = kset_register(&obd->obd_kset);
 	if (rc)
 		return rc;
 
@@ -1032,9 +1039,9 @@ int lprocfs_obd_setup(struct obd_device *obd, bool uuid_only)
 	else
 		obd->obd_attrs = obd_def_attrs;
 
-	rc = sysfs_create_files(&obd->obd_kobj, obd->obd_attrs);
+	rc = sysfs_create_files(&obd->obd_kset.kobj, obd->obd_attrs);
 	if (rc) {
-		kobject_put(&obd->obd_kobj);
+		kset_unregister(&obd->obd_kset);
 		return rc;
 	}
 
@@ -1053,12 +1060,16 @@ int lprocfs_obd_cleanup(struct obd_device *obd)
 
 	debugfs_remove_recursive(obd->obd_debugfs_entry);
 
+	/* obd device never allocated a kset */
+	if (!obd->obd_kset.kobj.state_initialized)
+		return 0;
+
 	if (obd->obd_attrs) {
-		sysfs_remove_files(&obd->obd_kobj, obd->obd_attrs);
+		sysfs_remove_files(&obd->obd_kset.kobj, obd->obd_attrs);
 		obd->obd_attrs = NULL;
 	}
 
-	kobject_put(&obd->obd_kobj);
+	kset_unregister(&obd->obd_kset);
 	wait_for_completion(&obd->obd_kobj_unregister);
 
 	return 0;
diff --git a/drivers/staging/lustre/lustre/obdclass/module.c b/drivers/staging/lustre/lustre/obdclass/module.c
index 9c80058..0ce2617 100644
--- a/drivers/staging/lustre/lustre/obdclass/module.c
+++ b/drivers/staging/lustre/lustre/obdclass/module.c
@@ -471,8 +471,8 @@ static int obd_device_list_open(struct inode *inode, struct file *file)
 	.release = seq_release,
 };
 
-struct kobject *lustre_kobj;
-EXPORT_SYMBOL_GPL(lustre_kobj);
+struct kset *lustre_kset;
+EXPORT_SYMBOL_GPL(lustre_kset);
 
 static const struct attribute_group lustre_attr_group = {
 	.attrs = lustre_attrs,
@@ -482,14 +482,14 @@ int class_procfs_init(void)
 {
 	int rc = -ENOMEM;
 
-	lustre_kobj = kobject_create_and_add("lustre", fs_kobj);
-	if (!lustre_kobj)
+	lustre_kset = kset_create_and_add("lustre", NULL, fs_kobj);
+	if (!lustre_kset)
 		goto out;
 
 	/* Create the files associated with this kobject */
-	rc = sysfs_create_group(lustre_kobj, &lustre_attr_group);
+	rc = sysfs_create_group(&lustre_kset->kobj, &lustre_attr_group);
 	if (rc) {
-		kobject_put(lustre_kobj);
+		kset_unregister(lustre_kset);
 		goto out;
 	}
 
@@ -507,8 +507,9 @@ int class_procfs_clean(void)
 
 	debugfs_lustre_root = NULL;
 
-	sysfs_remove_group(lustre_kobj, &lustre_attr_group);
-	kobject_put(lustre_kobj);
+	sysfs_remove_group(&lustre_kset->kobj, &lustre_attr_group);
+
+	kset_unregister(lustre_kset);
 
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/sysctl.c b/drivers/staging/lustre/lustre/obdclass/sysctl.c
index e5e8687..f8760b2 100644
--- a/drivers/staging/lustre/lustre/obdclass/sysctl.c
+++ b/drivers/staging/lustre/lustre/obdclass/sysctl.c
@@ -158,5 +158,5 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj, struct attribute *attr,
 
 int obd_sysctl_init(void)
 {
-	return sysfs_create_group(lustre_kobj, &lustre_attr_group);
+	return sysfs_create_group(&lustre_kset->kobj, &lustre_attr_group);
 }
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 3bcb36b..4ed289b 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -44,7 +44,7 @@ static ssize_t active_show(struct kobject *kobj, struct attribute *attr,
 			   char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 
 	return sprintf(buf, "%d\n", !dev->u.cli.cl_import->imp_deactive);
 }
@@ -54,7 +54,7 @@ static ssize_t active_store(struct kobject *kobj, struct attribute *attr,
 			    size_t count)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	int rc;
 	unsigned long val;
 
@@ -80,7 +80,7 @@ static ssize_t max_rpcs_in_flight_show(struct kobject *kobj,
 				       char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
 
 	return sprintf(buf, "%u\n", cli->cl_max_rpcs_in_flight);
@@ -92,7 +92,7 @@ static ssize_t max_rpcs_in_flight_store(struct kobject *kobj,
 					size_t count)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
 	int rc;
 	unsigned long val;
@@ -133,7 +133,7 @@ static ssize_t max_dirty_mb_show(struct kobject *kobj,
 				 char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
 	long val;
 	int mult;
@@ -149,7 +149,7 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj,
 				  size_t count)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
 	int rc;
 	unsigned long pages_number;
@@ -247,7 +247,7 @@ static ssize_t cur_dirty_bytes_show(struct kobject *kobj,
 				    char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
 
 	return sprintf(buf, "%lu\n", cli->cl_dirty_pages << PAGE_SHIFT);
@@ -260,7 +260,7 @@ static ssize_t cur_grant_bytes_show(struct kobject *kobj,
 				    char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
 
 	return sprintf(buf, "%lu\n", cli->cl_avail_grant);
@@ -272,7 +272,7 @@ static ssize_t cur_grant_bytes_store(struct kobject *kobj,
 				     size_t count)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct client_obd *cli = &obd->u.cli;
 	int rc;
 	unsigned long long val;
@@ -298,7 +298,7 @@ static ssize_t cur_lost_grant_bytes_show(struct kobject *kobj,
 					 char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
 
 	return sprintf(buf, "%lu\n", cli->cl_lost_grant);
@@ -310,7 +310,7 @@ static ssize_t cur_dirty_grant_bytes_show(struct kobject *kobj,
 					  char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
 
 	return sprintf(buf, "%lu\n", cli->cl_dirty_grant);
@@ -322,7 +322,7 @@ static ssize_t grant_shrink_interval_show(struct kobject *kobj,
 					  char *buf)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 
 	return sprintf(buf, "%d\n", obd->u.cli.cl_grant_shrink_interval);
 }
@@ -333,7 +333,7 @@ static ssize_t grant_shrink_interval_store(struct kobject *kobj,
 					   size_t count)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	int rc;
 	unsigned long val;
 
@@ -355,7 +355,7 @@ static ssize_t checksums_show(struct kobject *kobj,
 			      char *buf)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 
 	return sprintf(buf, "%d\n", obd->u.cli.cl_checksum ? 1 : 0);
 }
@@ -366,7 +366,7 @@ static ssize_t checksums_store(struct kobject *kobj,
 			       size_t count)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	int rc;
 	unsigned long val;
 
@@ -442,7 +442,7 @@ static ssize_t resend_count_show(struct kobject *kobj,
 				 char *buf)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 
 	return sprintf(buf, "%u\n", atomic_read(&obd->u.cli.cl_resends));
 }
@@ -453,7 +453,7 @@ static ssize_t resend_count_store(struct kobject *kobj,
 				  size_t count)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	int rc;
 	unsigned long val;
 
@@ -472,7 +472,7 @@ static ssize_t contention_seconds_show(struct kobject *kobj,
 				       char *buf)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct osc_device *od  = obd2osc_dev(obd);
 
 	return sprintf(buf, "%u\n", od->od_contention_time);
@@ -484,7 +484,7 @@ static ssize_t contention_seconds_store(struct kobject *kobj,
 					size_t count)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct osc_device *od  = obd2osc_dev(obd);
 	int rc;
 	int val;
@@ -507,7 +507,7 @@ static ssize_t lockless_truncate_show(struct kobject *kobj,
 				      char *buf)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct osc_device *od  = obd2osc_dev(obd);
 
 	return sprintf(buf, "%u\n", od->od_lockless_truncate);
@@ -519,7 +519,7 @@ static ssize_t lockless_truncate_store(struct kobject *kobj,
 				       size_t count)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct osc_device *od  = obd2osc_dev(obd);
 	int rc;
 	unsigned int val;
@@ -539,7 +539,7 @@ static ssize_t destroys_in_flight_show(struct kobject *kobj,
 				       char *buf)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 
 	return sprintf(buf, "%u\n",
 		       atomic_read(&obd->u.cli.cl_destroy_in_flight));
@@ -551,7 +551,7 @@ static ssize_t max_pages_per_rpc_show(struct kobject *kobj,
 				      char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
 
 	return sprintf(buf, "%d\n", cli->cl_max_pages_per_rpc);
@@ -563,7 +563,7 @@ static ssize_t max_pages_per_rpc_store(struct kobject *kobj,
 				       size_t count)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
 	struct obd_connect_data *ocd = &cli->cl_import->imp_connect_data;
 	int chunk_mask, rc;
@@ -598,7 +598,7 @@ static ssize_t unstable_stats_show(struct kobject *kobj,
 				   char *buf)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kobj);
+					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
 	long pages;
 	int mb;
-- 
1.8.3.1
