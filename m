From: NeilBrown <neilb@suse.com>
Date: Mon, 04 Mar 2019 17:31:38 +1100
Subject: [lustre-devel] [PATCH 01/28] lustre: embed typ_kobj in obd_type
In-Reply-To: <155168107971.31333.14345309795939467246.stgit@noble.brown>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
Message-ID: <155168109809.31333.15940683087805106878.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

As there is a 1-1 mapping between obd_types and their ->typ_kobj, it
is simple and more normal to embed the kobj in the obd_type, rather
than allocate it separately.

This requires calling "kobject_init()" earlier, so we open-code
relevant part of class_setup_tunables() in class_register_type().

A new simple_class_ktype is needed for the remaining user of
class_setup_tunables().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/obd.h        |    2 +
 drivers/staging/lustre/lustre/obdclass/genops.c    |   38 +++++++++++++-------
 .../lustre/lustre/obdclass/lprocfs_status.c        |    2 +
 3 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index f62669573717..f20c2468712a 100644
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
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index bc1f9792cf0b..7b3432f43a40 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -134,11 +134,23 @@ void class_put_type(struct obd_type *type)
 	spin_unlock(&type->obd_type_lock);
 }
 
-static void class_sysfs_release(struct kobject *kobj)
+static void simple_class_release(struct kobject *kobj)
 {
 	kfree(kobj);
 }
 
+static struct kobj_type simple_class_ktype = {
+	.sysfs_ops	= &lustre_sysfs_ops,
+	.release	= simple_class_release,
+};
+
+static void class_sysfs_release(struct kobject *kobj)
+{
+	struct obd_type *type = container_of(kobj, struct obd_type, typ_kobj);
+
+	kfree(type);
+}
+
 static struct kobj_type class_ktype = {
 	.sysfs_ops	= &lustre_sysfs_ops,
 	.release	= class_sysfs_release,
@@ -154,7 +166,7 @@ struct kobject *class_setup_tunables(const char *name)
 		return ERR_PTR(-ENOMEM);
 
 	kobj->kset = lustre_kset;
-	kobject_init(kobj, &class_ktype);
+	kobject_init(kobj, &simple_class_ktype);
 	rc = kobject_add(kobj, &lustre_kset->kobj, "%s", name);
 	if (rc) {
 		kobject_put(kobj);
@@ -186,6 +198,9 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	if (!type)
 		return rc;
 
+	type->typ_kobj.kset = lustre_kset;
+	kobject_init(&type->typ_kobj, &class_ktype);
+
 	type->typ_dt_ops = kzalloc(sizeof(*type->typ_dt_ops), GFP_NOFS);
 	type->typ_md_ops = kzalloc(sizeof(*type->typ_md_ops), GFP_NOFS);
 	type->typ_name = kzalloc(strlen(name) + 1, GFP_NOFS);
@@ -205,19 +220,16 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
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
@@ -230,7 +242,8 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	kfree(type->typ_name);
 	kfree(type->typ_md_ops);
 	kfree(type->typ_dt_ops);
-	kfree(type);
+	kobject_put(&type->typ_kobj);
+
 	return rc;
 }
 EXPORT_SYMBOL(class_register_type);
@@ -253,8 +266,6 @@ int class_unregister_type(const char *name)
 		return -EBUSY;
 	}
 
-	kobject_put(type->typ_kobj);
-
 	debugfs_remove_recursive(type->typ_debugfs_entry);
 
 	if (type->typ_lu)
@@ -266,7 +277,8 @@ int class_unregister_type(const char *name)
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
index 11fddc88d532..71bf409240f5 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1036,7 +1036,7 @@ int lprocfs_obd_setup(struct obd_device *obd, bool uuid_only)
 	obd->obd_ktype.sysfs_ops = &lustre_sysfs_ops;
 	obd->obd_ktype.release = obd_sysfs_release;
 
-	obd->obd_kset.kobj.parent = obd->obd_type->typ_kobj;
+	obd->obd_kset.kobj.parent = &obd->obd_type->typ_kobj;
 	obd->obd_kset.kobj.ktype = &obd->obd_ktype;
 	init_completion(&obd->obd_kobj_unregister);
 	rc = kset_register(&obd->obd_kset);
