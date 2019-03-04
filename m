From: NeilBrown <neilb@suse.com>
Date: Mon, 04 Mar 2019 17:31:38 +1100
Subject: [lustre-devel] [PATCH 02/28] lustre: collect all resource releasing
 for obj_type.
In-Reply-To: <155168107971.31333.14345309795939467246.stgit@noble.brown>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
Message-ID: <155168109814.31333.18020605502462728324.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Now that obj_type is managed as a kobject, move all
the freeing and deregistering into class_sysfs_release().

Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/genops.c |   27 +++++++++++------------
 1 file changed, 13 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 7b3432f43a40..8dd217c888a5 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -148,6 +148,18 @@ static void class_sysfs_release(struct kobject *kobj)
 {
 	struct obd_type *type = container_of(kobj, struct obd_type, typ_kobj);
 
+	debugfs_remove_recursive(type->typ_debugfs_entry);
+
+	if (type->typ_lu)
+		lu_device_type_fini(type->typ_lu);
+
+	spin_lock(&obd_types_lock);
+	list_del(&type->typ_chain);
+	spin_unlock(&obd_types_lock);
+
+	kfree(type->typ_name);
+	kfree(type->typ_md_ops);
+	kfree(type->typ_dt_ops);
 	kfree(type);
 }
 
@@ -200,6 +212,7 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 
 	type->typ_kobj.kset = lustre_kset;
 	kobject_init(&type->typ_kobj, &class_ktype);
+	INIT_LIST_HEAD(&type->typ_chain);
 
 	type->typ_dt_ops = kzalloc(sizeof(*type->typ_dt_ops), GFP_NOFS);
 	type->typ_md_ops = kzalloc(sizeof(*type->typ_md_ops), GFP_NOFS);
@@ -239,9 +252,6 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	return 0;
 
 failed:
-	kfree(type->typ_name);
-	kfree(type->typ_md_ops);
-	kfree(type->typ_dt_ops);
 	kobject_put(&type->typ_kobj);
 
 	return rc;
@@ -266,17 +276,6 @@ int class_unregister_type(const char *name)
 		return -EBUSY;
 	}
 
-	debugfs_remove_recursive(type->typ_debugfs_entry);
-
-	if (type->typ_lu)
-		lu_device_type_fini(type->typ_lu);
-
-	spin_lock(&obd_types_lock);
-	list_del(&type->typ_chain);
-	spin_unlock(&obd_types_lock);
-	kfree(type->typ_name);
-	kfree(type->typ_dt_ops);
-	kfree(type->typ_md_ops);
 	kobject_put(&type->typ_kobj);
 
 	return 0;
