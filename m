From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:06 +1100
Subject: [lustre-devel] [PATCH 28/37] lustre: remove scope and source from
 class_incref and class_decref.
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494637.24125.716197573687357279.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

These arguments are no longer used, so we can discard them.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/obd_class.h  |    6 ++----
 drivers/staging/lustre/lustre/obdclass/genops.c    |   12 ++++++------
 .../staging/lustre/lustre/obdclass/obd_config.c    |   17 ++++++++---------
 drivers/staging/lustre/lustre/obdclass/obd_sysfs.c |    4 ++--
 4 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index dd480501d7df..a913ef76a008 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -133,10 +133,8 @@ int class_parse_net(char *buf, u32 *net, char **endh);
 int class_match_nid(char *buf, char *key, lnet_nid_t nid);
 int class_match_net(char *buf, char *key, u32 net);
 
-struct obd_device *class_incref(struct obd_device *obd,
-				const char *scope, const void *source);
-void class_decref(struct obd_device *obd,
-		  const char *scope, const void *source);
+struct obd_device *class_incref(struct obd_device *obd);
+void class_decref(struct obd_device *obd);
 int class_config_llog_handler(const struct lu_env *env,
 			      struct llog_handle *handle,
 			      struct llog_rec_hdr *rec, void *data);
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index ce92c8c1dc75..fc7985a2922c 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -622,13 +622,13 @@ int class_notify_sptlrpc_conf(const char *fsname, int namelen)
 		if (strncmp(obd->obd_name, fsname, namelen))
 			continue;
 
-		class_incref(obd, __func__, obd);
+		class_incref(obd);
 		read_unlock(&obd_dev_lock);
 		rc2 = obd_set_info_async(NULL, obd->obd_self_export,
 					 sizeof(KEY_SPTLRPC_CONF),
 					 KEY_SPTLRPC_CONF, 0, NULL, NULL);
 		rc = rc ? rc : rc2;
-		class_decref(obd, __func__, obd);
+		class_decref(obd);
 		read_lock(&obd_dev_lock);
 	}
 	read_unlock(&obd_dev_lock);
@@ -737,7 +737,7 @@ static void class_export_destroy(struct obd_export *exp)
 	 * exists until freeing of the obd
 	 */
 	if (exp != obd->obd_self_export)
-		class_decref(obd, "export", exp);
+		class_decref(obd);
 
 	OBD_FREE_RCU(exp, sizeof(*exp), &exp->exp_handle);
 }
@@ -863,7 +863,7 @@ static struct obd_export *__class_new_export(struct obd_device *obd,
 	}
 
 	if (!is_self) {
-		class_incref(obd, "export", export);
+		class_incref(obd);
 		list_add(&export->exp_obd_chain, &export->exp_obd->obd_exports);
 		obd->obd_num_exports++;
 	} else {
@@ -934,7 +934,7 @@ static void class_import_destroy(struct obd_import *imp)
 	}
 
 	LASSERT(!imp->imp_sec);
-	class_decref(imp->imp_obd, "import", imp);
+	class_decref(imp->imp_obd);
 	OBD_FREE_RCU(imp, sizeof(*imp), &imp->imp_handle);
 }
 
@@ -1017,7 +1017,7 @@ struct obd_import *class_new_import(struct obd_device *obd)
 	spin_lock_init(&imp->imp_lock);
 	imp->imp_last_success_conn = 0;
 	imp->imp_state = LUSTRE_IMP_NEW;
-	imp->imp_obd = class_incref(obd, "import", imp);
+	imp->imp_obd = class_incref(obd);
 	mutex_init(&imp->imp_sec_mutex);
 	init_waitqueue_head(&imp->imp_recovery_waitq);
 	INIT_WORK(&imp->imp_zombie_work, obd_zombie_imp_cull);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 45e8f03dec80..776f251e9f43 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -334,7 +334,7 @@ static int class_attach(struct lustre_cfg *lcfg)
 
 	rc = class_register_device(obd);
 	if (rc) {
-		class_decref(obd, "newdev", obd);
+		class_decref(obd);
 		return rc;
 	}
 
@@ -399,7 +399,7 @@ static int class_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 
 	spin_lock(&obd->obd_dev_lock);
 	/* cleanup drops this */
-	class_incref(obd, "setup", obd);
+	class_incref(obd);
 	spin_unlock(&obd->obd_dev_lock);
 
 	CDEBUG(D_IOCTL, "finished setup of obd %s (uuid %s)\n",
@@ -439,7 +439,7 @@ static int class_detach(struct obd_device *obd, struct lustre_cfg *lcfg)
 	CDEBUG(D_IOCTL, "detach on obd %s (uuid %s)\n",
 	       obd->obd_name, obd->obd_uuid.uuid);
 
-	class_decref(obd, "newdev", obd);
+	class_decref(obd);
 	return 0;
 }
 
@@ -511,14 +511,13 @@ static int class_cleanup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	/* destroy an uuid-export hash body */
 	rhashtable_free_and_destroy(&obd->obd_uuid_hash, uuid_export_exit, NULL);
 
-	class_decref(obd, "setup", obd);
+	class_decref(obd);
 	obd->obd_set_up = 0;
 
 	return 0;
 }
 
-struct obd_device *class_incref(struct obd_device *obd,
-				const char *scope, const void *source)
+struct obd_device *class_incref(struct obd_device *obd)
 {
 	atomic_inc(&obd->obd_refcount);
 	CDEBUG(D_INFO, "incref %s (%p) now %d\n", obd->obd_name, obd,
@@ -528,12 +527,12 @@ struct obd_device *class_incref(struct obd_device *obd,
 }
 EXPORT_SYMBOL(class_incref);
 
-void class_decref(struct obd_device *obd, const char *scope, const void *source)
+void class_decref(struct obd_device *obd)
 {
 	int last;
 
-	CDEBUG(D_INFO, "Decref %s (%p) now %d - %s\n", obd->obd_name, obd,
-	       atomic_read(&obd->obd_refcount), scope);
+	CDEBUG(D_INFO, "Decref %s (%p) now %d\n", obd->obd_name, obd,
+	       atomic_read(&obd->obd_refcount));
 
 	LASSERT(obd->obd_num_exports >= 0);
 	last = atomic_dec_and_test(&obd->obd_refcount);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
index e9e0bcf39d4e..57a6f2c2da1c 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
@@ -188,12 +188,12 @@ health_check_show(struct kobject *kobj, struct attribute *attr, char *buf)
 		if (obd->obd_stopping)
 			continue;
 
-		class_incref(obd, __func__, current);
+		class_incref(obd);
 		read_unlock(&obd_dev_lock);
 
 		if (obd_health_check(NULL, obd))
 			healthy = false;
-		class_decref(obd, __func__, current);
+		class_decref(obd);
 		read_lock(&obd_dev_lock);
 	}
 	read_unlock(&obd_dev_lock);
