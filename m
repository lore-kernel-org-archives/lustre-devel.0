From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:05 +1100
Subject: [lustre-devel] [PATCH 03/37] lustre: embed typ_kobj if obd_type
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494494.24125.2449884893355897376.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

As there is a 1-1 ammping between obd_types and their ->typ_kobj, it
is simple and more normal to embed the kobj in the obd_type, rather
than allocate it separately.

This requires calling "kobject_init()" earlier, so we discard
class_setup_tunables() and move the content to appropriate places in
the only caller.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/obd.h        |    2 -
 drivers/staging/lustre/lustre/include/obd_class.h  |    1 
 drivers/staging/lustre/lustre/obdclass/genops.c    |   46 ++++++--------------
 .../lustre/lustre/obdclass/lprocfs_status.c        |    2 -
 4 files changed, 16 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 171d2c214be6..b161542855fc 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -107,7 +107,7 @@ struct obd_type {
 	int			 typ_refcnt;
 	struct lu_device_type	*typ_lu;
 	spinlock_t		 obd_type_lock;
-	struct kobject		*typ_kobj;
+	struct kobject		 typ_kobj;
 };
 
 struct brw_page {
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 32d4ab6e78a0..e4695f5b748d 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -60,7 +60,6 @@ struct lu_device_type;
 
 /* genops.c */
 struct obd_export *class_conn2export(struct lustre_handle *conn);
-struct kobject *class_setup_tunables(const char *name);
 int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 			const char *name, struct lu_device_type *ldt);
 int class_unregister_type(const char *name);
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 75d25b7206fc..2bd72f8a38eb 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -136,7 +136,9 @@ void class_put_type(struct obd_type *type)
 
 static void class_sysfs_release(struct kobject *kobj)
 {
-	kfree(kobj);
+	struct obd_type *type = container_of(kobj, struct obd_type, typ_kobj);
+
+	kfree(type);
 }
 
 static struct kobj_type class_ktype = {
@@ -144,26 +146,6 @@ static struct kobj_type class_ktype = {
 	.release	= class_sysfs_release,
 };
 
-struct kobject *class_setup_tunables(const char *name)
-{
-	struct kobject *kobj;
-	int rc;
-
-	kobj = kzalloc(sizeof(*kobj), GFP_KERNEL);
-	if (!kobj)
-		return ERR_PTR(-ENOMEM);
-
-	kobj->kset = lustre_kset;
-	kobject_init(kobj, &class_ktype);
-	rc = kobject_add(kobj, &lustre_kset->kobj, "%s", name);
-	if (rc) {
-		kobject_put(kobj);
-		return ERR_PTR(rc);
-	}
-	return kobj;
-}
-EXPORT_SYMBOL(class_setup_tunables);
-
 #define CLASS_MAX_NAME 1024
 
 int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
@@ -186,6 +168,9 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	if (!type)
 		return rc;
 
+	type->typ_kobj.kset = lustre_kset;
+	kobject_init(&type->typ_kobj, &class_ktype);
+
 	type->typ_dt_ops = kzalloc(sizeof(*type->typ_dt_ops), GFP_NOFS);
 	type->typ_md_ops = kzalloc(sizeof(*type->typ_md_ops), GFP_NOFS);
 	type->typ_name = kzalloc(strlen(name) + 1, GFP_NOFS);
@@ -205,19 +190,16 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	type->typ_debugfs_entry = debugfs_create_dir(type->typ_name,
 						     debugfs_lustre_root);
 
-	type->typ_kobj = class_setup_tunables(type->typ_name);
-	if (IS_ERR(type->typ_kobj)) {
-		rc = PTR_ERR(type->typ_kobj);
+	rc = kobject_add(&type->typ_kobj, &lustre_kset->kobj, "%s", name);
+
+	if (rc)
 		goto failed;
-	}
 
 	if (ldt) {
 		type->typ_lu = ldt;
 		rc = lu_device_type_init(ldt);
-		if (rc != 0) {
-			kobject_put(type->typ_kobj);
+		if (rc != 0)
 			goto failed;
-		}
 	}
 
 	spin_lock(&obd_types_lock);
@@ -230,7 +212,8 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	kfree(type->typ_name);
 	kfree(type->typ_md_ops);
 	kfree(type->typ_dt_ops);
-	kfree(type);
+	kobject_put(&type->typ_kobj);
+
 	return rc;
 }
 EXPORT_SYMBOL(class_register_type);
@@ -253,8 +236,6 @@ int class_unregister_type(const char *name)
 		return -EBUSY;
 	}
 
-	kobject_put(type->typ_kobj);
-
 	debugfs_remove_recursive(type->typ_debugfs_entry);
 
 	if (type->typ_lu)
@@ -266,7 +247,8 @@ int class_unregister_type(const char *name)
 	kfree(type->typ_name);
 	kfree(type->typ_dt_ops);
 	kfree(type->typ_md_ops);
-	kfree(type);
+	kobject_put(&type->typ_kobj);
+
 	return 0;
 } /* class_unregister_type */
 EXPORT_SYMBOL(class_unregister_type);
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index e1ac610eaed5..568e6623e0c8 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1050,7 +1050,7 @@ int lprocfs_obd_setup(struct obd_device *obd, bool uuid_only)
 	obd->obd_ktype.sysfs_ops = &lustre_sysfs_ops;
 	obd->obd_ktype.release = obd_sysfs_release;
 
-	obd->obd_kset.kobj.parent = obd->obd_type->typ_kobj;
+	obd->obd_kset.kobj.parent = &obd->obd_type->typ_kobj;
 	obd->obd_kset.kobj.ktype = &obd->obd_ktype;
 	init_completion(&obd->obd_kobj_unregister);
 	rc = kset_register(&obd->obd_kset);
