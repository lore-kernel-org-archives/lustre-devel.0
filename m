From: NeilBrown <neilb@suse.com>
Date: Thu, 12 Apr 2018 07:54:48 +1000
Subject: [lustre-devel] [PATCH 03/20] staging: lustre: convert obd uuid hash
 to rhashtable
In-Reply-To: <152348312863.12394.11915752362061083241.stgit@noble>
References: <152348312863.12394.11915752362061083241.stgit@noble>
Message-ID: <152348368861.12394.17231763587470085829.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

The rhashtable data type is a perfect fit for the
export uuid hash table, so use that instead of
cfs_hash (which will eventually be removed).

As rhashtable supports lookups and insertions in atomic
context, there is no need to drop a spinlock while
inserting a new entry, which simplifies code quite a bit.

As there are no simple lookups on this hash table (only
insertions which might fail and take a spinlock), there is
no need to use rcu to free the exports.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_export.h  |    2 
 drivers/staging/lustre/lustre/include/obd.h        |    5 -
 .../staging/lustre/lustre/include/obd_support.h    |    3 
 drivers/staging/lustre/lustre/obdclass/genops.c    |   34 +---
 .../staging/lustre/lustre/obdclass/obd_config.c    |  161 +++++++++-----------
 5 files changed, 80 insertions(+), 125 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index 19ce13bc8ee6..79ad5aae86b9 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -89,7 +89,7 @@ struct obd_export {
 	struct list_head		exp_obd_chain;
 	/** work_struct for destruction of export */
 	struct work_struct	exp_zombie_work;
-	struct hlist_node	  exp_uuid_hash; /** uuid-export hash*/
+	struct rhash_head	exp_uuid_hash; /** uuid-export hash*/
 	/** Obd device of this export */
 	struct obd_device	*exp_obd;
 	/**
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index ad265db48b76..1818fe6a7a2f 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -558,7 +558,7 @@ struct obd_device {
 	 */
 	unsigned long obd_recovery_expired:1;
 	/* uuid-export hash body */
-	struct cfs_hash	     *obd_uuid_hash;
+	struct rhashtable	obd_uuid_hash;
 	wait_queue_head_t	     obd_refcount_waitq;
 	struct list_head	      obd_exports;
 	struct list_head	      obd_unlinked_exports;
@@ -622,6 +622,9 @@ struct obd_device {
 	struct completion	obd_kobj_unregister;
 };
 
+int obd_uuid_add(struct obd_device *obd, struct obd_export *export);
+void obd_uuid_del(struct obd_device *obd, struct obd_export *export);
+
 /* get/set_info keys */
 #define KEY_ASYNC	       "async"
 #define KEY_CHANGELOG_CLEAR     "changelog_clear"
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 730a6ee71565..a4c7a2ee9738 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -61,9 +61,6 @@ extern atomic_long_t obd_dirty_transit_pages;
 extern char obd_jobid_var[];
 
 /* Some hash init argument constants */
-#define HASH_UUID_BKT_BITS 5
-#define HASH_UUID_CUR_BITS 7
-#define HASH_UUID_MAX_BITS 12
 /* Timeout definitions */
 #define OBD_TIMEOUT_DEFAULT	     100
 /* Time to wait for all clients to reconnect during recovery (hard limit) */
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 86e22472719a..af233b868742 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -713,7 +713,6 @@ struct obd_export *class_new_export(struct obd_device *obd,
 				    struct obd_uuid *cluuid)
 {
 	struct obd_export *export;
-	struct cfs_hash *hash = NULL;
 	int rc = 0;
 
 	export = kzalloc(sizeof(*export), GFP_NOFS);
@@ -740,7 +739,6 @@ struct obd_export *class_new_export(struct obd_device *obd,
 	class_handle_hash(&export->exp_handle, &export_handle_ops);
 	spin_lock_init(&export->exp_lock);
 	spin_lock_init(&export->exp_rpc_lock);
-	INIT_HLIST_NODE(&export->exp_uuid_hash);
 	spin_lock_init(&export->exp_bl_list_lock);
 	INIT_LIST_HEAD(&export->exp_bl_list);
 	INIT_WORK(&export->exp_zombie_work, obd_zombie_exp_cull);
@@ -757,44 +755,24 @@ struct obd_export *class_new_export(struct obd_device *obd,
 		goto exit_unlock;
 	}
 
-	hash = cfs_hash_getref(obd->obd_uuid_hash);
-	if (!hash) {
-		rc = -ENODEV;
-		goto exit_unlock;
-	}
-	spin_unlock(&obd->obd_dev_lock);
-
 	if (!obd_uuid_equals(cluuid, &obd->obd_uuid)) {
-		rc = cfs_hash_add_unique(hash, cluuid, &export->exp_uuid_hash);
-		if (rc != 0) {
+		rc = obd_uuid_add(obd, export);
+		if (rc) {
 			LCONSOLE_WARN("%s: denying duplicate export for %s, %d\n",
 				      obd->obd_name, cluuid->uuid, rc);
-			rc = -EALREADY;
-			goto exit_err;
+			goto exit_unlock;
 		}
 	}
 
-	spin_lock(&obd->obd_dev_lock);
-	if (obd->obd_stopping) {
-		cfs_hash_del(hash, cluuid, &export->exp_uuid_hash);
-		rc = -ENODEV;
-		goto exit_unlock;
-	}
-
 	class_incref(obd, "export", export);
 	list_add(&export->exp_obd_chain, &export->exp_obd->obd_exports);
 	export->exp_obd->obd_num_exports++;
 	spin_unlock(&obd->obd_dev_lock);
-	cfs_hash_putref(hash);
 	return export;
 
 exit_unlock:
 	spin_unlock(&obd->obd_dev_lock);
-exit_err:
-	if (hash)
-		cfs_hash_putref(hash);
 	class_handle_unhash(&export->exp_handle);
-	LASSERT(hlist_unhashed(&export->exp_uuid_hash));
 	obd_destroy_export(export);
 	kfree(export);
 	return ERR_PTR(rc);
@@ -807,10 +785,8 @@ void class_unlink_export(struct obd_export *exp)
 
 	spin_lock(&exp->exp_obd->obd_dev_lock);
 	/* delete an uuid-export hashitem from hashtables */
-	if (!hlist_unhashed(&exp->exp_uuid_hash))
-		cfs_hash_del(exp->exp_obd->obd_uuid_hash,
-			     &exp->exp_client_uuid,
-			     &exp->exp_uuid_hash);
+	if (exp != exp->exp_obd->obd_self_export)
+		obd_uuid_del(exp->exp_obd, exp);
 
 	list_move(&exp->exp_obd_chain, &exp->exp_obd->obd_unlinked_exports);
 	exp->exp_obd->obd_num_exports--;
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index eab03766236f..ffc1814398a5 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -48,7 +48,69 @@
 
 #include "llog_internal.h"
 
-static struct cfs_hash_ops uuid_hash_ops;
+/*
+ * uuid<->export lustre hash operations
+ */
+/*
+ * NOTE: It is impossible to find an export that is in failed
+ *       state with this function
+ */
+static int
+uuid_keycmp(struct rhashtable_compare_arg *arg, const void *obj)
+{
+	const struct obd_uuid *uuid = arg->key;
+	const struct obd_export *exp = obj;
+
+	if (obd_uuid_equals(uuid, &exp->exp_client_uuid) &&
+	    !exp->exp_failed)
+		return 0;
+	return -ESRCH;
+}
+
+static void
+uuid_export_exit(void *vexport, void *data)
+{
+	struct obd_export *exp = vexport;
+
+	class_export_put(exp);
+}
+
+static const struct rhashtable_params uuid_hash_params = {
+	.key_len	= sizeof(struct obd_uuid),
+	.key_offset	= offsetof(struct obd_export, exp_client_uuid),
+	.head_offset	= offsetof(struct obd_export, exp_uuid_hash),
+	.obj_cmpfn	= uuid_keycmp,
+	.automatic_shrinking = true,
+};
+
+int obd_uuid_add(struct obd_device *obd, struct obd_export *export)
+{
+	int rc;
+
+	rc = rhashtable_lookup_insert_fast(&obd->obd_uuid_hash,
+					   &export->exp_uuid_hash,
+					   uuid_hash_params);
+	if (rc == 0)
+		class_export_get(export);
+	else if (rc == -EEXIST)
+		rc = -EALREADY;
+	else
+		/* map obscure error codes to -ENOMEM */
+		rc = -ENOMEM;
+	return rc;
+}
+
+void obd_uuid_del(struct obd_device *obd, struct obd_export *export)
+{
+	int rc;
+
+	rc = rhashtable_remove_fast(&obd->obd_uuid_hash,
+				    &export->exp_uuid_hash,
+				    uuid_hash_params);
+
+	if (rc == 0)
+		class_export_put(export);
+}
 
 /*********** string parsing utils *********/
 
@@ -347,26 +409,18 @@ static int class_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	 * other fns check that status, and we're not actually set up yet.
 	 */
 	obd->obd_starting = 1;
-	obd->obd_uuid_hash = NULL;
 	spin_unlock(&obd->obd_dev_lock);
 
 	/* create an uuid-export lustre hash */
-	obd->obd_uuid_hash = cfs_hash_create("UUID_HASH",
-					     HASH_UUID_CUR_BITS,
-					     HASH_UUID_MAX_BITS,
-					     HASH_UUID_BKT_BITS, 0,
-					     CFS_HASH_MIN_THETA,
-					     CFS_HASH_MAX_THETA,
-					     &uuid_hash_ops, CFS_HASH_DEFAULT);
-	if (!obd->obd_uuid_hash) {
-		err = -ENOMEM;
+	err = rhashtable_init(&obd->obd_uuid_hash, &uuid_hash_params);
+
+	if (err)
 		goto err_hash;
-	}
 
 	exp = class_new_export(obd, &obd->obd_uuid);
 	if (IS_ERR(exp)) {
 		err = PTR_ERR(exp);
-		goto err_hash;
+		goto err_new;
 	}
 
 	obd->obd_self_export = exp;
@@ -392,11 +446,9 @@ static int class_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		class_unlink_export(obd->obd_self_export);
 		obd->obd_self_export = NULL;
 	}
+err_new:
+	rhashtable_destroy(&obd->obd_uuid_hash);
 err_hash:
-	if (obd->obd_uuid_hash) {
-		cfs_hash_putref(obd->obd_uuid_hash);
-		obd->obd_uuid_hash = NULL;
-	}
 	obd->obd_starting = 0;
 	CERROR("setup %s failed (%d)\n", obd->obd_name, err);
 	return err;
@@ -490,10 +542,7 @@ static int class_cleanup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		       obd->obd_name, err);
 
 	/* destroy an uuid-export hash body */
-	if (obd->obd_uuid_hash) {
-		cfs_hash_putref(obd->obd_uuid_hash);
-		obd->obd_uuid_hash = NULL;
-	}
+	rhashtable_free_and_destroy(&obd->obd_uuid_hash, uuid_export_exit, NULL);
 
 	class_decref(obd, "setup", obd);
 	obd->obd_set_up = 0;
@@ -1487,73 +1536,3 @@ int class_manual_cleanup(struct obd_device *obd)
 	return rc;
 }
 EXPORT_SYMBOL(class_manual_cleanup);
-
-/*
- * uuid<->export lustre hash operations
- */
-
-static unsigned int
-uuid_hash(struct cfs_hash *hs, const void *key, unsigned int mask)
-{
-	return cfs_hash_djb2_hash(((struct obd_uuid *)key)->uuid,
-				  sizeof(((struct obd_uuid *)key)->uuid), mask);
-}
-
-static void *
-uuid_key(struct hlist_node *hnode)
-{
-	struct obd_export *exp;
-
-	exp = hlist_entry(hnode, struct obd_export, exp_uuid_hash);
-
-	return &exp->exp_client_uuid;
-}
-
-/*
- * NOTE: It is impossible to find an export that is in failed
- *       state with this function
- */
-static int
-uuid_keycmp(const void *key, struct hlist_node *hnode)
-{
-	struct obd_export *exp;
-
-	LASSERT(key);
-	exp = hlist_entry(hnode, struct obd_export, exp_uuid_hash);
-
-	return obd_uuid_equals(key, &exp->exp_client_uuid) &&
-	       !exp->exp_failed;
-}
-
-static void *
-uuid_export_object(struct hlist_node *hnode)
-{
-	return hlist_entry(hnode, struct obd_export, exp_uuid_hash);
-}
-
-static void
-uuid_export_get(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-	struct obd_export *exp;
-
-	exp = hlist_entry(hnode, struct obd_export, exp_uuid_hash);
-	class_export_get(exp);
-}
-
-static void
-uuid_export_put_locked(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-	struct obd_export *exp;
-
-	exp = hlist_entry(hnode, struct obd_export, exp_uuid_hash);
-	class_export_put(exp);
-}
-
-static struct cfs_hash_ops uuid_hash_ops = {
-	.hs_hash	= uuid_hash,
-	.hs_key		= uuid_key,
-	.hs_keycmp      = uuid_keycmp,
-	.hs_object      = uuid_export_object,
-	.hs_get		= uuid_export_get,
-	.hs_put_locked  = uuid_export_put_locked,
-};
