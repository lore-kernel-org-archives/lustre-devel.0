From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:26 -0400
Subject: [lustre-devel] [PATCH 23/38] lustre: obd: create
 class_setup_tunables() function
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Creat class_setup_tunables() so sysfs kobject creation is handled
for both obd_devices and llite.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/28108
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |  3 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |  2 ++
 drivers/staging/lustre/lustre/llite/lproc_llite.c  | 30 +++-------------
 drivers/staging/lustre/lustre/obdclass/genops.c    | 40 +++++++++++++++-------
 .../lustre/lustre/obdclass/lprocfs_status.c        |  2 +-
 5 files changed, 36 insertions(+), 41 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 36f6c10..385a88d 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -111,8 +111,7 @@ struct obd_type {
 	int  typ_refcnt;
 	struct lu_device_type *typ_lu;
 	spinlock_t obd_type_lock;
-	struct kobject		typ_kobj;
-	struct completion	typ_kobj_unregister;
+	struct kobject		*typ_kobj;
 };
 
 struct brw_page {
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index fd9d99b..e994c968 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -33,6 +33,7 @@
 #ifndef __CLASS_OBD_H
 #define __CLASS_OBD_H
 
+#include <linux/kobject.h>
 #include <obd_support.h>
 #include <lustre_import.h>
 #include <lustre_net.h>
@@ -59,6 +60,7 @@
 
 /* genops.c */
 struct obd_export *class_conn2export(struct lustre_handle *conn);
+struct kobject *class_setup_tunables(const char *name);
 int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 			const char *name, struct lu_device_type *ldt);
 int class_unregister_type(const char *name);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index ab2f102..30873fc 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -43,40 +43,20 @@
 static struct kobject *llite_kobj;
 static struct dentry *llite_root;
 
-static void class_sysfs_release(struct kobject *kobj)
-{
-	kfree(kobj);
-}
-
-static struct kobj_type class_ktype = {
-	.sysfs_ops	= &lustre_sysfs_ops,
-	.release	= class_sysfs_release,
-};
-
 int llite_tunables_register(void)
 {
-	const char *name = "llite";
-	struct kobject *kobj;
 	int rc = 0;
 
-	kobj = kzalloc(sizeof(*kobj), GFP_KERNEL);
-	if (!kobj)
-		return -ENOMEM;
-
-	kobj->kset = lustre_kset;
-	kobject_init(kobj, &class_ktype);
-	rc = kobject_add(kobj, &lustre_kset->kobj, "%s", name);
-	if (rc) {
-		kobject_put(kobj);
-		return -ENOMEM;
-	}
-	llite_kobj = kobj;
+	llite_kobj = class_setup_tunables("llite");
+	if (IS_ERR(llite_kobj))
+		return PTR_ERR(llite_kobj);
 
 	llite_root = debugfs_create_dir("llite", debugfs_lustre_root);
 	if (IS_ERR_OR_NULL(llite_root)) {
 		rc = llite_root ? PTR_ERR(llite_root) : -ENOMEM;
 		llite_root = NULL;
-		kobject_put(kobj);
+		kobject_put(llite_kobj);
+		llite_kobj = NULL;
 	}
 
 	return rc;
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index bf182e5..29ed498 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -135,10 +135,7 @@ void class_put_type(struct obd_type *type)
 
 static void class_sysfs_release(struct kobject *kobj)
 {
-	struct obd_type *type = container_of(kobj, struct obd_type,
-					     typ_kobj);
-
-	complete(&type->typ_kobj_unregister);
+	kfree(kobj);
 }
 
 static struct kobj_type class_ktype = {
@@ -146,6 +143,26 @@ static void class_sysfs_release(struct kobject *kobj)
 	.release	= class_sysfs_release,
 };
 
+struct kobject *class_setup_tunables(const char *name)
+{
+	struct kobject *kobj;
+	int rc;
+
+	kobj = kzalloc(sizeof(*kobj), GFP_KERNEL);
+	if (!kobj)
+		return ERR_PTR(-ENOMEM);
+
+	kobj->kset = lustre_kset;
+	kobject_init(kobj, &class_ktype);
+	rc = kobject_add(kobj, &lustre_kset->kobj, "%s", name);
+	if (rc) {
+		kobject_put(kobj);
+		return ERR_PTR(rc);
+	}
+	return kobj;
+}
+EXPORT_SYMBOL(class_setup_tunables);
+
 #define CLASS_MAX_NAME 1024
 
 int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
@@ -187,19 +204,17 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	type->typ_debugfs_entry = debugfs_create_dir(type->typ_name,
 						     debugfs_lustre_root);
 
-	type->typ_kobj.kset = lustre_kset;
-	init_completion(&type->typ_kobj_unregister);
-	rc = kobject_init_and_add(&type->typ_kobj, &class_ktype,
-				  &lustre_kset->kobj, "%s", type->typ_name);
-	if (rc)
+	type->typ_kobj = class_setup_tunables(type->typ_name);
+	if (IS_ERR(type->typ_kobj)) {
+		rc = PTR_ERR(type->typ_kobj);
 		goto failed;
-
+	}
 
 	if (ldt) {
 		type->typ_lu = ldt;
 		rc = lu_device_type_init(ldt);
 		if (rc != 0) {
-			kobject_put(&type->typ_kobj);
+			kobject_put(type->typ_kobj);
 			goto failed;
 		}
 	}
@@ -237,8 +252,7 @@ int class_unregister_type(const char *name)
 		return -EBUSY;
 	}
 
-	kobject_put(&type->typ_kobj);
-	wait_for_completion(&type->typ_kobj_unregister);
+	kobject_put(type->typ_kobj);
 
 	debugfs_remove_recursive(type->typ_debugfs_entry);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index b3ba554..f889fb8 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1027,7 +1027,7 @@ int lprocfs_obd_setup(struct obd_device *obd, bool uuid_only)
 	obd->obd_ktype.sysfs_ops = &lustre_sysfs_ops;
 	obd->obd_ktype.release = obd_sysfs_release;
 
-	obd->obd_kset.kobj.parent = &obd->obd_type->typ_kobj;
+	obd->obd_kset.kobj.parent = obd->obd_type->typ_kobj;
 	obd->obd_kset.kobj.ktype = &obd->obd_ktype;
 	init_completion(&obd->obd_kobj_unregister);
 	rc = kset_register(&obd->obd_kset);
-- 
1.8.3.1
