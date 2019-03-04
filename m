From: NeilBrown <neilb@suse.com>
Date: Mon, 04 Mar 2019 17:31:38 +1100
Subject: [lustre-devel] [PATCH 04/28] lustre: obd_type: discard obd_types
 linked list.
In-Reply-To: <155168107971.31333.14345309795939467246.stgit@noble.brown>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
Message-ID: <155168109822.31333.9434810900527856527.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

As all obd_types are kobjects in the lustre_kset kset,
they are linked together in that kset and don't
need any extra linkage.

There are non-obd_type objects in lustre_kset, added by
class_setup_tunables().  These have a different ->ktype, so we are
careful to only return objects with the correct ->ktype.

As kset_find_obj() returns a counted reference, we need
to put that reference when done.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/obd.h     |    1 -
 drivers/staging/lustre/lustre/obdclass/genops.c |   42 +++++++++++------------
 2 files changed, 20 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 6bf052a5ac5a..4c58b916e0a3 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -99,7 +99,6 @@ struct obd_info {
 };
 
 struct obd_type {
-	struct list_head	 typ_chain;
 	struct obd_ops		*typ_dt_ops;
 	struct md_ops		*typ_md_ops;
 	struct dentry		*typ_debugfs_entry;
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 8f683313acf2..74195de639e4 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -42,8 +42,6 @@
 #include <lprocfs_status.h>
 #include <lustre_kernelcomm.h>
 
-static DEFINE_SPINLOCK(obd_types_lock);
-static LIST_HEAD(obd_types);
 DEFINE_RWLOCK(obd_dev_lock);
 static struct obd_device *obd_devs[MAX_OBD_DEVICES];
 
@@ -52,6 +50,7 @@ struct kmem_cache *obdo_cachep;
 EXPORT_SYMBOL(obdo_cachep);
 static struct kmem_cache *import_cachep;
 
+static struct kobj_type class_ktype;
 static struct workqueue_struct *zombie_wq;
 static void obd_zombie_export_add(struct obd_export *exp);
 static void obd_zombie_import_add(struct obd_import *imp);
@@ -88,22 +87,19 @@ static void obd_device_free(struct obd_device *obd)
 
 static struct obd_type *class_search_type(const char *name)
 {
-	struct obd_type *type;
+	struct kobject *kobj = kset_find_obj(lustre_kset, name);
+
+	if (kobj && kobj->ktype == &class_ktype)
+		return container_of(kobj, struct obd_type, typ_kobj);
 
-	spin_lock(&obd_types_lock);
-	list_for_each_entry(type, &obd_types, typ_chain) {
-		if (strcmp(type->typ_name, name) == 0) {
-			spin_unlock(&obd_types_lock);
-			return type;
-		}
-	}
-	spin_unlock(&obd_types_lock);
 	return NULL;
 }
 
 static struct obd_type *class_get_type(const char *name)
 {
-	struct obd_type *type = class_search_type(name);
+	struct obd_type *type;
+
+	type = class_search_type(name);
 
 	if (!type) {
 		const char *modname = name;
@@ -121,6 +117,11 @@ static struct obd_type *class_get_type(const char *name)
 		type->typ_refcnt++;
 		try_module_get(type->typ_dt_ops->owner);
 		spin_unlock(&type->obd_type_lock);
+		/* class_search_type() returned a counted reference,
+		 * but we don't need that count any more as
+		 * we have one through typ_refcnt.
+		 */
+		kobject_put(&type->typ_kobj);
 	}
 	return type;
 }
@@ -153,10 +154,6 @@ static void class_sysfs_release(struct kobject *kobj)
 	if (type->typ_lu)
 		lu_device_type_fini(type->typ_lu);
 
-	spin_lock(&obd_types_lock);
-	list_del(&type->typ_chain);
-	spin_unlock(&obd_types_lock);
-
 	kfree(type->typ_md_ops);
 	kfree(type->typ_dt_ops);
 	kfree(type);
@@ -199,8 +196,10 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	/* sanity check */
 	LASSERT(strnlen(name, CLASS_MAX_NAME) < CLASS_MAX_NAME);
 
-	if (class_search_type(name)) {
+	type = class_search_type(name);
+	if (type) {
 		CDEBUG(D_IOCTL, "Type %s already registered\n", name);
+		kobject_put(&type->typ_kobj);
 		return -EEXIST;
 	}
 
@@ -211,7 +210,6 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 
 	type->typ_kobj.kset = lustre_kset;
 	kobject_init(&type->typ_kobj, &class_ktype);
-	INIT_LIST_HEAD(&type->typ_chain);
 
 	type->typ_dt_ops = kzalloc(sizeof(*type->typ_dt_ops), GFP_NOFS);
 	type->typ_md_ops = kzalloc(sizeof(*type->typ_md_ops), GFP_NOFS);
@@ -240,10 +238,6 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 			goto failed;
 	}
 
-	spin_lock(&obd_types_lock);
-	list_add(&type->typ_chain, &obd_types);
-	spin_unlock(&obd_types_lock);
-
 	return 0;
 
 failed:
@@ -268,9 +262,13 @@ int class_unregister_type(const char *name)
 		/* Remove ops, but leave the name for debugging */
 		kfree(type->typ_dt_ops);
 		kfree(type->typ_md_ops);
+		kobject_put(&type->typ_kobj);
 		return -EBUSY;
 	}
 
+	/* Put the ref returned by class_search_type() */
+	kobject_put(&type->typ_kobj);
+	/* Put the final ref */
 	kobject_put(&type->typ_kobj);
 
 	return 0;
