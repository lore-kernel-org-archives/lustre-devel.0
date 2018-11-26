From: James Simmons <jsimmons@infradead.org>
Date: Sun, 25 Nov 2018 21:48:25 -0500
Subject: [lustre-devel] [PATCH 09/12] lustre: obdclass: obd_device
 improvement
In-Reply-To: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1543200508-6838-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

The patch removes self exports from obd's reference counting which
allows to avoid freeing of self exports by zombie thread.
A pair of functions class_register_device()/class_unregister_device()
is to make sure that an obd can not be referenced again once its
refcount reached 0.

Signed-off-by: Vladimir Saveliev Vladimir Saveliev <c17830@cray.com>
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Signed-off-by: Alexander Boyko <c17825@cray.com>
Signed-off-by: Yang Sheng <ys@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4134
Seagate-bug-id: MRP-2139 MRP-3267
Reviewed-on: https://review.whamcloud.com/8045
Reviewed-on: https://review.whamcloud.com/29967
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd_class.h  |   9 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    | 284 +++++++++++++++------
 .../staging/lustre/lustre/obdclass/obd_config.c    | 143 ++++-------
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   6 +-
 4 files changed, 261 insertions(+), 181 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 567189c..cc00915 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -65,8 +65,11 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 			const char *name, struct lu_device_type *ldt);
 int class_unregister_type(const char *name);
 
-struct obd_device *class_newdev(const char *type_name, const char *name);
-void class_release_dev(struct obd_device *obd);
+struct obd_device *class_newdev(const char *type_name, const char *name,
+				const char *uuid);
+int class_register_device(struct obd_device *obd);
+void class_unregister_device(struct obd_device *obd);
+void class_free_dev(struct obd_device *obd);
 
 int class_name2dev(const char *name);
 struct obd_device *class_name2obd(const char *name);
@@ -230,6 +233,8 @@ void __class_export_del_lock_ref(struct obd_export *exp,
 void class_export_put(struct obd_export *exp);
 struct obd_export *class_new_export(struct obd_device *obddev,
 				    struct obd_uuid *cluuid);
+struct obd_export *class_new_export_self(struct obd_device *obd,
+					 struct obd_uuid *uuid);
 void class_unlink_export(struct obd_export *exp);
 
 struct obd_import *class_import_get(struct obd_import *imp);
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 59891a8..cdd44f7 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -38,6 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 #include <obd_class.h>
+#include <lustre_log.h>
 #include <lprocfs_status.h>
 #include <lustre_kernelcomm.h>
 
@@ -273,21 +274,20 @@ int class_unregister_type(const char *name)
 /**
  * Create a new obd device.
  *
- * Find an empty slot in ::obd_devs[], create a new obd device in it.
+ * Allocate the new obd_device and initialize it.
  *
  * \param[in] type_name obd device type string.
  * \param[in] name      obd device name.
+ * @uuid		obd device UUID.
  *
- * \retval NULL if create fails, otherwise return the obd device
- *	 pointer created.
+ * RETURN newdev	 pointer to created obd_device
+ * RETURN ERR_PTR(errno) on error
  */
-struct obd_device *class_newdev(const char *type_name, const char *name)
+struct obd_device *class_newdev(const char *type_name, const char *name,
+				const char *uuid)
 {
-	struct obd_device *result = NULL;
 	struct obd_device *newdev;
 	struct obd_type *type = NULL;
-	int i;
-	int new_obd_minor = 0;
 
 	if (strlen(name) >= MAX_OBD_NAME) {
 		CERROR("name/uuid must be < %u bytes long\n", MAX_OBD_NAME);
@@ -302,87 +302,167 @@ struct obd_device *class_newdev(const char *type_name, const char *name)
 
 	newdev = obd_device_alloc();
 	if (!newdev) {
-		result = ERR_PTR(-ENOMEM);
-		goto out_type;
+		class_put_type(type);
+		return ERR_PTR(-ENOMEM);
 	}
 
 	LASSERT(newdev->obd_magic == OBD_DEVICE_MAGIC);
+	strncpy(newdev->obd_name, name, sizeof(newdev->obd_name) - 1);
+	newdev->obd_type = type;
+	newdev->obd_minor = -1;
+
+	rwlock_init(&newdev->obd_pool_lock);
+	newdev->obd_pool_limit = 0;
+	newdev->obd_pool_slv = 0;
+
+	INIT_LIST_HEAD(&newdev->obd_exports);
+	INIT_LIST_HEAD(&newdev->obd_unlinked_exports);
+	INIT_LIST_HEAD(&newdev->obd_delayed_exports);
+	spin_lock_init(&newdev->obd_nid_lock);
+	spin_lock_init(&newdev->obd_dev_lock);
+	mutex_init(&newdev->obd_dev_mutex);
+	spin_lock_init(&newdev->obd_osfs_lock);
+	/* newdev->obd_osfs_age must be set to a value in the distant
+	 * past to guarantee a fresh statfs is fetched on mount.
+	 */
+	newdev->obd_osfs_age = get_jiffies_64() - 1000 * HZ;
 
-	write_lock(&obd_dev_lock);
-	for (i = 0; i < class_devno_max(); i++) {
-		struct obd_device *obd = class_num2obd(i);
+	/* XXX belongs in setup not attach  */
+	init_rwsem(&newdev->obd_observer_link_sem);
+	/* recovery data */
+	init_waitqueue_head(&newdev->obd_evict_inprogress_waitq);
 
-		if (obd && (strcmp(name, obd->obd_name) == 0)) {
-			CERROR("Device %s already exists at %d, won't add\n",
-			       name, i);
-			if (result) {
-				LASSERTF(result->obd_magic == OBD_DEVICE_MAGIC,
-					 "%p obd_magic %08x != %08x\n", result,
-					 result->obd_magic, OBD_DEVICE_MAGIC);
-				LASSERTF(result->obd_minor == new_obd_minor,
-					 "%p obd_minor %d != %d\n", result,
-					 result->obd_minor, new_obd_minor);
-
-				obd_devs[result->obd_minor] = NULL;
-				result->obd_name[0] = '\0';
-			 }
-			result = ERR_PTR(-EEXIST);
-			break;
-		}
-		if (!result && !obd) {
-			result = newdev;
-			result->obd_minor = i;
-			new_obd_minor = i;
-			result->obd_type = type;
-			strncpy(result->obd_name, name,
-				sizeof(result->obd_name) - 1);
-			obd_devs[i] = result;
-		}
-	}
-	write_unlock(&obd_dev_lock);
+	llog_group_init(&newdev->obd_olg);
+	/* Detach drops this */
+        atomic_set(&newdev->obd_refcount, 1);
+        lu_ref_init(&newdev->obd_reference);
+        lu_ref_add(&newdev->obd_reference, "newdev", newdev);
 
-	if (!result && i >= class_devno_max()) {
-		CERROR("all %u OBD devices used, increase MAX_OBD_DEVICES\n",
-		       class_devno_max());
-		result = ERR_PTR(-EOVERFLOW);
-		goto out;
-	}
+	newdev->obd_conn_inprogress = 0;
 
-	if (IS_ERR(result))
-		goto out;
+	strncpy(newdev->obd_uuid.uuid, uuid, strlen(uuid));
 
-	CDEBUG(D_IOCTL, "Adding new device %s (%p)\n",
-	       result->obd_name, result);
+	CDEBUG(D_IOCTL, "Allocate new device %s (%p)\n",
+	       newdev->obd_name, newdev);
 
-	return result;
-out:
-	obd_device_free(newdev);
-out_type:
-	class_put_type(type);
-	return result;
+	return newdev;
 }
 
-void class_release_dev(struct obd_device *obd)
+/**
+ * Free obd device.
+ *
+ * @obd obd_device to be freed
+ *
+ * RETURN none
+ */
+void class_free_dev(struct obd_device *obd)
 {
 	struct obd_type *obd_type = obd->obd_type;
 
 	LASSERTF(obd->obd_magic == OBD_DEVICE_MAGIC, "%p obd_magic %08x != %08x\n",
 		 obd, obd->obd_magic, OBD_DEVICE_MAGIC);
-	LASSERTF(obd == obd_devs[obd->obd_minor], "obd %p != obd_devs[%d] %p\n",
+	LASSERTF(obd->obd_minor == -1 || obd == obd_devs[obd->obd_minor],
+		 "obd %p != obd_devs[%d] %p\n",
 		 obd, obd->obd_minor, obd_devs[obd->obd_minor]);
+	LASSERTF(atomic_read(&obd->obd_refcount) == 0,
+		 "obd_refcount should be 0, not %d\n",
+		 atomic_read(&obd->obd_refcount));
 	LASSERT(obd_type);
 
-	CDEBUG(D_INFO, "Release obd device %s at %d obd_type name =%s\n",
-	       obd->obd_name, obd->obd_minor, obd->obd_type->typ_name);
+	CDEBUG(D_INFO, "Release obd device %s obd_type name =%s\n",
+	       obd->obd_name, obd->obd_type->typ_name);
+
+	CDEBUG(D_CONFIG, "finishing cleanup of obd %s (%s)\n",
+	       obd->obd_name, obd->obd_uuid.uuid);
+	if (obd->obd_stopping) {
+		int err;
+
+		/* If we're not stopping, we were never set up */
+		err = obd_cleanup(obd);
+		if (err)
+			CERROR("Cleanup %s returned %d\n",
+			       obd->obd_name, err);
+	}
 
-	write_lock(&obd_dev_lock);
-	obd_devs[obd->obd_minor] = NULL;
-	write_unlock(&obd_dev_lock);
 	obd_device_free(obd);
 
 	class_put_type(obd_type);
 }
 
+/**
+ * Unregister obd device.
+ *
+ * Free slot in obd_dev[] used by \a obd.
+ *
+ * @new_obd	obd_device to be unregistered
+ *
+ * RETURN	none
+ */
+void class_unregister_device(struct obd_device *obd)
+{
+	write_lock(&obd_dev_lock);
+	if (obd->obd_minor >= 0) {
+		LASSERT(obd_devs[obd->obd_minor] == obd);
+		obd_devs[obd->obd_minor] = NULL;
+		obd->obd_minor = -1;
+	}
+	write_unlock(&obd_dev_lock);
+}
+
+/**
+ * Register obd device.
+ *
+ * Find free slot in obd_devs[], fills it with \a new_obd.
+ *
+ * @new_obd	obd_device to be registered
+ *
+ * RETURN	0		success
+ *		-EEXIST		device with this name is registered
+ *		-EOVERFLOW	obd_devs[] is full
+ */
+int class_register_device(struct obd_device *new_obd)
+{
+	int new_obd_minor = 0;
+	bool minor_assign = false;
+	int ret = 0;
+	int i;
+
+	write_lock(&obd_dev_lock);
+	for (i = 0; i < class_devno_max(); i++) {
+		struct obd_device *obd = class_num2obd(i);
+
+		if (obd && (strcmp(new_obd->obd_name, obd->obd_name) == 0)) {
+			CERROR("%s: already exists, won't add\n",
+			       obd->obd_name);
+			/* in case we found a free slot before duplicate */
+			minor_assign = false;
+			ret = -EEXIST;
+			break;
+		}
+		if (!minor_assign && !obd) {
+			new_obd_minor = i;
+			minor_assign = true;
+		}
+	}
+
+	if (minor_assign) {
+		new_obd->obd_minor = new_obd_minor;
+		LASSERTF(!obd_devs[new_obd_minor], "obd_devs[%d] %p\n",
+			 new_obd_minor, obd_devs[new_obd_minor]);
+		obd_devs[new_obd_minor] = new_obd;
+	} else {
+		if (ret == 0) {
+			ret = -EOVERFLOW;
+			CERROR("%s: all %u/%u devices used, increase MAX_OBD_DEVICES: rc = %d\n",
+			       new_obd->obd_name, i, class_devno_max(), ret);
+		}
+	}
+	write_unlock(&obd_dev_lock);
+
+	return ret;
+}
+
+
 int class_name2dev(const char *name)
 {
 	int i;
@@ -677,7 +757,11 @@ static void class_export_destroy(struct obd_export *exp)
 	LASSERT(list_empty(&exp->exp_req_replay_queue));
 	LASSERT(list_empty(&exp->exp_hp_rpcs));
 	obd_destroy_export(exp);
-	class_decref(obd, "export", exp);
+	/* self export doesn't hold a reference to an obd, although it
+	 * exists until freeing of the obd
+	 */
+	if (exp != obd->obd_self_export)
+		class_decref(obd, "export", exp);
 
 	OBD_FREE_RCU(exp, sizeof(*exp), &exp->exp_handle);
 }
@@ -708,11 +792,27 @@ void class_export_put(struct obd_export *exp)
 	       atomic_read(&exp->exp_refcount) - 1);
 
 	if (atomic_dec_and_test(&exp->exp_refcount)) {
-		LASSERT(!list_empty(&exp->exp_obd_chain));
+		struct obd_device *obd = exp->exp_obd;
+
 		CDEBUG(D_IOCTL, "final put %p/%s\n",
 		       exp, exp->exp_client_uuid.uuid);
 
-		obd_zombie_export_add(exp);
+		if (exp == obd->obd_self_export) {
+			/* self export should be destroyed without
+			 * zombie thread as it doesn't hold a
+			 * reference to obd and doesn't hold any
+			 * resources
+			 */
+			class_export_destroy(exp);
+			/* self export is destroyed, no class
+			 * references exist and it is safe to free
+			 * obd
+			 */
+			class_free_dev(obd);
+		} else {
+			LASSERT(!list_empty(&exp->exp_obd_chain));
+			obd_zombie_export_add(exp);
+		}
 	}
 }
 EXPORT_SYMBOL(class_export_put);
@@ -728,8 +828,9 @@ static void obd_zombie_exp_cull(struct work_struct *ws)
  * pointer to it. The refcount is 2: one for the hash reference, and
  * one for the pointer returned by this function.
  */
-struct obd_export *class_new_export(struct obd_device *obd,
-				    struct obd_uuid *cluuid)
+static struct obd_export *__class_new_export(struct obd_device *obd,
+					     struct obd_uuid *cluuid,
+					     bool is_self)
 {
 	struct obd_export *export;
 	int rc = 0;
@@ -739,6 +840,7 @@ struct obd_export *class_new_export(struct obd_device *obd,
 		return ERR_PTR(-ENOMEM);
 
 	export->exp_conn_cnt = 0;
+	/* 2 = class_handle_hash + last */
 	atomic_set(&export->exp_refcount, 2);
 	atomic_set(&export->exp_rpc_count, 0);
 	atomic_set(&export->exp_cb_count, 0);
@@ -767,41 +869,65 @@ struct obd_export *class_new_export(struct obd_device *obd,
 	export->exp_client_uuid = *cluuid;
 	obd_init_export(export);
 
-	spin_lock(&obd->obd_dev_lock);
-	/* shouldn't happen, but might race */
-	if (obd->obd_stopping) {
-		rc = -ENODEV;
-		goto exit_unlock;
-	}
-
 	if (!obd_uuid_equals(cluuid, &obd->obd_uuid)) {
+		spin_lock(&obd->obd_dev_lock);
+		/* shouldn't happen, but might race */
+		if (obd->obd_stopping) {
+			rc = -ENODEV;
+			goto exit_unlock;
+		}
+		spin_unlock(&obd->obd_dev_lock);
+
 		rc = obd_uuid_add(obd, export);
 		if (rc) {
 			LCONSOLE_WARN("%s: denying duplicate export for %s, %d\n",
 				      obd->obd_name, cluuid->uuid, rc);
-			goto exit_unlock;
+			goto exit_err;
 		}
 	}
 
-	class_incref(obd, "export", export);
-	list_add(&export->exp_obd_chain, &export->exp_obd->obd_exports);
-	export->exp_obd->obd_num_exports++;
+	spin_lock(&obd->obd_dev_lock);
+	if (!is_self) {
+		class_incref(obd, "export", export);
+		list_add(&export->exp_obd_chain, &export->exp_obd->obd_exports);
+		obd->obd_num_exports++;
+	} else {
+		INIT_LIST_HEAD(&export->exp_obd_chain);
+	}
 	spin_unlock(&obd->obd_dev_lock);
 	return export;
 
 exit_unlock:
 	spin_unlock(&obd->obd_dev_lock);
+exit_err:
 	class_handle_unhash(&export->exp_handle);
 	obd_destroy_export(export);
 	kfree(export);
 	return ERR_PTR(rc);
 }
+
+struct obd_export *class_new_export(struct obd_device *obd,
+				    struct obd_uuid *uuid)
+{
+	return __class_new_export(obd, uuid, false);
+}
 EXPORT_SYMBOL(class_new_export);
 
+struct obd_export *class_new_export_self(struct obd_device *obd,
+					 struct obd_uuid *uuid)
+{
+	return __class_new_export(obd, uuid, true);
+}
+
 void class_unlink_export(struct obd_export *exp)
 {
 	class_handle_unhash(&exp->exp_handle);
 
+	if (exp->exp_obd->obd_self_export == exp) {
+		class_export_put(exp);
+		return;
+	}
+
 	spin_lock(&exp->exp_obd->obd_dev_lock);
 	/* delete an uuid-export hashitem from hashtables */
 	if (exp != exp->exp_obd->obd_self_export)
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 9e46eb2..8be8751 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -280,6 +280,7 @@ static int class_attach(struct lustre_cfg *lcfg)
 {
 	struct obd_device *obd = NULL;
 	char *typename, *name, *uuid;
+	struct obd_export *exp;
 	int rc, len;
 
 	if (!LUSTRE_CFG_BUFLEN(lcfg, 1)) {
@@ -298,78 +299,50 @@ static int class_attach(struct lustre_cfg *lcfg)
 		CERROR("No UUID passed!\n");
 		return -EINVAL;
 	}
-	uuid = lustre_cfg_string(lcfg, 2);
 
-	CDEBUG(D_IOCTL, "attach type %s name: %s uuid: %s\n",
-	       typename, name, uuid);
+	uuid = lustre_cfg_string(lcfg, 2);
+	len = strlen(uuid);
+	if (len >= sizeof(obd->obd_uuid)) {
+		CERROR("uuid must be < %d bytes long\n",
+		       (int)sizeof(obd->obd_uuid));
+		return -EINVAL;
+	}
 
-	obd = class_newdev(typename, name);
+	obd = class_newdev(typename, name, uuid);
 	if (IS_ERR(obd)) {
 		/* Already exists or out of obds */
 		rc = PTR_ERR(obd);
-		obd = NULL;
 		CERROR("Cannot create device %s of type %s : %d\n",
 		       name, typename, rc);
-		goto out;
+		return rc;
 	}
-	LASSERTF(obd, "Cannot get obd device %s of type %s\n",
-		 name, typename);
 	LASSERTF(obd->obd_magic == OBD_DEVICE_MAGIC,
 		 "obd %p obd_magic %08X != %08X\n",
 		 obd, obd->obd_magic, OBD_DEVICE_MAGIC);
 	LASSERTF(strncmp(obd->obd_name, name, strlen(name)) == 0,
 		 "%p obd_name %s != %s\n", obd, obd->obd_name, name);
 
-	rwlock_init(&obd->obd_pool_lock);
-	obd->obd_pool_limit = 0;
-	obd->obd_pool_slv = 0;
-
-	INIT_LIST_HEAD(&obd->obd_exports);
-	INIT_LIST_HEAD(&obd->obd_unlinked_exports);
-	INIT_LIST_HEAD(&obd->obd_delayed_exports);
-	spin_lock_init(&obd->obd_nid_lock);
-	spin_lock_init(&obd->obd_dev_lock);
-	mutex_init(&obd->obd_dev_mutex);
-	spin_lock_init(&obd->obd_osfs_lock);
-	/* obd->obd_osfs_age must be set to a value in the distant
-	 * past to guarantee a fresh statfs is fetched on mount.
-	 */
-	obd->obd_osfs_age = get_jiffies_64() - 1000 * HZ;
-
-	/* XXX belongs in setup not attach  */
-	init_rwsem(&obd->obd_observer_link_sem);
-	/* recovery data */
-	init_waitqueue_head(&obd->obd_evict_inprogress_waitq);
-
-	llog_group_init(&obd->obd_olg);
+	exp = class_new_export_self(obd, &obd->obd_uuid);
+	if (IS_ERR(exp)) {
+		rc = PTR_ERR(exp);
+		class_free_dev(obd);
+		return rc;
+	}
 
-	obd->obd_conn_inprogress = 0;
+	obd->obd_self_export = exp;
+	class_export_put(exp);
 
-	len = strlen(uuid);
-	if (len >= sizeof(obd->obd_uuid)) {
-		CERROR("uuid must be < %d bytes long\n",
-		       (int)sizeof(obd->obd_uuid));
-		rc = -EINVAL;
-		goto out;
+	rc = class_register_device(obd);
+	if (rc) {
+		class_decref(obd, "newdev", obd);
+		return rc;
 	}
-	memcpy(obd->obd_uuid.uuid, uuid, len);
-
-	/* Detach drops this */
-	spin_lock(&obd->obd_dev_lock);
-	atomic_set(&obd->obd_refcount, 1);
-	spin_unlock(&obd->obd_dev_lock);
-	lu_ref_init(&obd->obd_reference);
-	lu_ref_add(&obd->obd_reference, "attach", obd);
 
 	obd->obd_attached = 1;
 	CDEBUG(D_IOCTL, "OBD: dev %d attached type %s with refcount %d\n",
 	       obd->obd_minor, typename, atomic_read(&obd->obd_refcount));
-	return 0;
- out:
-	if (obd)
-		class_release_dev(obd);
 
-	return rc;
+	return 0;
 }
 
 /** Create hashes, self-export, and call type-specific setup.
@@ -378,7 +351,6 @@ static int class_attach(struct lustre_cfg *lcfg)
 static int class_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 {
 	int err = 0;
-	struct obd_export *exp;
 
 	LASSERT(obd);
 	LASSERTF(obd == class_num2obd(obd->obd_minor),
@@ -420,18 +392,9 @@ static int class_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	if (err)
 		goto err_hash;
 
-	exp = class_new_export(obd, &obd->obd_uuid);
-	if (IS_ERR(exp)) {
-		err = PTR_ERR(exp);
-		goto err_new;
-	}
-
-	obd->obd_self_export = exp;
-	class_export_put(exp);
-
 	err = obd_setup(obd, lcfg);
 	if (err)
-		goto err_exp;
+		goto err_setup;
 
 	obd->obd_set_up = 1;
 
@@ -444,12 +407,7 @@ static int class_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	       obd->obd_name, obd->obd_uuid.uuid);
 
 	return 0;
-err_exp:
-	if (obd->obd_self_export) {
-		class_unlink_export(obd->obd_self_export);
-		obd->obd_self_export = NULL;
-	}
-err_new:
+err_setup:
 	rhashtable_destroy(&obd->obd_uuid_hash);
 err_hash:
 	obd->obd_starting = 0;
@@ -476,10 +434,13 @@ static int class_detach(struct obd_device *obd, struct lustre_cfg *lcfg)
 	obd->obd_attached = 0;
 	spin_unlock(&obd->obd_dev_lock);
 
+	/* cleanup in progress. we don't like to find this device after now */
+	class_unregister_device(obd);
+
 	CDEBUG(D_IOCTL, "detach on obd %s (uuid %s)\n",
 	       obd->obd_name, obd->obd_uuid.uuid);
 
-	class_decref(obd, "attach", obd);
+	class_decref(obd, "newdev", obd);
 	return 0;
 }
 
@@ -507,6 +468,10 @@ static int class_cleanup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	}
 	/* Leave this on forever */
 	obd->obd_stopping = 1;
+	/* function can't return error after that point, so clear setup flag
+	 * as early as possible to avoid finding via obd_devs / hash
+	 */
+	obd->obd_set_up = 0;
 	spin_unlock(&obd->obd_dev_lock);
 
 	while (obd->obd_conn_inprogress > 0)
@@ -567,43 +532,27 @@ struct obd_device *class_incref(struct obd_device *obd,
 
 void class_decref(struct obd_device *obd, const char *scope, const void *source)
 {
-	int err;
-	int refs;
+	int last;
 
-	spin_lock(&obd->obd_dev_lock);
-	atomic_dec(&obd->obd_refcount);
-	refs = atomic_read(&obd->obd_refcount);
-	spin_unlock(&obd->obd_dev_lock);
+	CDEBUG(D_INFO, "Decref %s (%p) now %d - %s\n", obd->obd_name, obd,
+	       atomic_read(&obd->obd_refcount), scope);
+
+	LASSERT(obd->obd_num_exports >= 0);
+	last = atomic_dec_and_test(&obd->obd_refcount);
 	lu_ref_del(&obd->obd_reference, scope, source);
 
-	CDEBUG(D_INFO, "Decref %s (%p) now %d\n", obd->obd_name, obd, refs);
+	if (last) {
+		struct obd_export *exp;
 
-	if ((refs == 1) && obd->obd_stopping) {
+		LASSERT(!obd->obd_attached);
 		/* All exports have been destroyed; there should
 		 * be no more in-progress ops by this point.
 		 */
-
-		spin_lock(&obd->obd_self_export->exp_lock);
-		obd->obd_self_export->exp_flags |= exp_flags_from_obd(obd);
-		spin_unlock(&obd->obd_self_export->exp_lock);
-
-		/* note that we'll recurse into class_decref again */
-		class_unlink_export(obd->obd_self_export);
-		return;
-	}
-
-	if (refs == 0) {
-		CDEBUG(D_CONFIG, "finishing cleanup of obd %s (%s)\n",
-		       obd->obd_name, obd->obd_uuid.uuid);
-		LASSERT(!obd->obd_attached);
-		if (obd->obd_stopping) {
-			/* If we're not stopping, we were never set up */
-			err = obd_cleanup(obd);
-			if (err)
-				CERROR("Cleanup %s returned %d\n",
-				       obd->obd_name, err);
+		exp = obd->obd_self_export;
+		if (exp) {
+			exp->exp_flags |= exp_flags_from_obd(obd);
+			class_unlink_export(exp);
 		}
-		class_release_dev(obd);
 	}
 }
 EXPORT_SYMBOL(class_decref);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 5ed1758..db5e1b5 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -214,7 +214,7 @@ int lustre_start_mgc(struct super_block *sb)
 	struct lustre_sb_info *lsi = s2lsi(sb);
 	struct obd_device *obd;
 	struct obd_export *exp;
-	struct obd_uuid *uuid;
+	struct obd_uuid *uuid = NULL;
 	class_uuid_t uuidc;
 	lnet_nid_t nid;
 	char nidstr[LNET_NIDSTR_SIZE];
@@ -342,7 +342,6 @@ int lustre_start_mgc(struct super_block *sb)
 	rc = lustre_start_simple(mgcname, LUSTRE_MGC_NAME,
 				 (char *)uuid->uuid, LUSTRE_MGS_OBDNAME,
 				 niduuid, NULL, NULL);
-	kfree(uuid);
 	if (rc)
 		goto out_free;
 
@@ -404,7 +403,7 @@ int lustre_start_mgc(struct super_block *sb)
 	    lsi->lsi_lmd->lmd_flags & LMD_FLG_NOIR)
 		data->ocd_connect_flags &= ~OBD_CONNECT_IMP_RECOV;
 	data->ocd_version = LUSTRE_VERSION_CODE;
-	rc = obd_connect(NULL, &exp, obd, &obd->obd_uuid, data, NULL);
+	rc = obd_connect(NULL, &exp, obd, uuid, data, NULL);
 	if (rc) {
 		CERROR("connect failed %d\n", rc);
 		goto out;
@@ -420,6 +419,7 @@ int lustre_start_mgc(struct super_block *sb)
 out_free:
 	mutex_unlock(&mgc_start_lock);
 
+	kfree(uuid);
 	kfree(data);
 	kfree(mgcname);
 	kfree(niduuid);
-- 
1.8.3.1
