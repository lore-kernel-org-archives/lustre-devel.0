From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:44:08 -0400
Subject: [lustre-devel] [PATCH 25/29] staging/lustre/obdclass: Remove unused
	nid_hash
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-26-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

nid_hash is used on export to faster find clients based on
their NID. There's no use for that on the client.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/lustre_export.h  |  1 -
 drivers/staging/lustre/lustre/include/obd.h        |  2 -
 drivers/staging/lustre/lustre/obdclass/genops.c    | 10 +--
 .../staging/lustre/lustre/obdclass/obd_config.c    | 95 ----------------------
 4 files changed, 1 insertion(+), 107 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index 7634dea..5b8f4e8 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -147,7 +147,6 @@ struct obd_export {
 	/** To link all exports on an obd device */
 	struct list_head		exp_obd_chain;
 	struct hlist_node	  exp_uuid_hash; /** uuid-export hash*/
-	struct hlist_node	  exp_nid_hash; /** nid-export hash */
 	/** Obd device of this export */
 	struct obd_device	*exp_obd;
 	/**
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index e8317b8..3fb72dc 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -746,8 +746,6 @@ struct obd_device {
 	unsigned long obd_recovery_expired:1;
 	/* uuid-export hash body */
 	struct cfs_hash	     *obd_uuid_hash;
-	/* nid-export hash body */
-	struct cfs_hash	     *obd_nid_hash;
 	atomic_t	    obd_refcount;
 	wait_queue_head_t	     obd_refcount_waitq;
 	struct list_head	      obd_exports;
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 4467baa..681312e 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -757,7 +757,6 @@ struct obd_export *class_new_export(struct obd_device *obd,
 	spin_lock_init(&export->exp_lock);
 	spin_lock_init(&export->exp_rpc_lock);
 	INIT_HLIST_NODE(&export->exp_uuid_hash);
-	INIT_HLIST_NODE(&export->exp_nid_hash);
 	spin_lock_init(&export->exp_bl_list_lock);
 	INIT_LIST_HEAD(&export->exp_bl_list);
 
@@ -1103,19 +1102,12 @@ int class_disconnect(struct obd_export *export)
 	/* class_cleanup(), abort_recovery(), and class_fail_export()
 	 * all end up in here, and if any of them race we shouldn't
 	 * call extra class_export_puts(). */
-	if (already_disconnected) {
-		LASSERT(hlist_unhashed(&export->exp_nid_hash));
+	if (already_disconnected)
 		goto no_disconn;
-	}
 
 	CDEBUG(D_IOCTL, "disconnect: cookie %#llx\n",
 	       export->exp_handle.h_cookie);
 
-	if (!hlist_unhashed(&export->exp_nid_hash))
-		cfs_hash_del(export->exp_obd->obd_nid_hash,
-			     &export->exp_connection->c_peer.nid,
-			     &export->exp_nid_hash);
-
 	class_export_recovery_cleanup(export);
 	class_unlink_export(export);
 no_disconn:
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index a8a1cb7..48c712e 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -48,7 +48,6 @@
 #include "llog_internal.h"
 
 static cfs_hash_ops_t uuid_hash_ops;
-static cfs_hash_ops_t nid_hash_ops;
 
 /*********** string parsing utils *********/
 
@@ -327,7 +326,6 @@ int class_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	   other fns check that status, and we're not actually set up yet. */
 	obd->obd_starting = 1;
 	obd->obd_uuid_hash = NULL;
-	obd->obd_nid_hash = NULL;
 	spin_unlock(&obd->obd_dev_lock);
 
 	/* create an uuid-export lustre hash */
@@ -343,19 +341,6 @@ int class_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		goto err_hash;
 	}
 
-	/* create a nid-export lustre hash */
-	obd->obd_nid_hash = cfs_hash_create("NID_HASH",
-					    HASH_NID_CUR_BITS,
-					    HASH_NID_MAX_BITS,
-					    HASH_NID_BKT_BITS, 0,
-					    CFS_HASH_MIN_THETA,
-					    CFS_HASH_MAX_THETA,
-					    &nid_hash_ops, CFS_HASH_DEFAULT);
-	if (!obd->obd_nid_hash) {
-		err = -ENOMEM;
-		goto err_hash;
-	}
-
 	exp = class_new_export(obd, &obd->obd_uuid);
 	if (IS_ERR(exp)) {
 		err = PTR_ERR(exp);
@@ -390,10 +375,6 @@ err_hash:
 		cfs_hash_putref(obd->obd_uuid_hash);
 		obd->obd_uuid_hash = NULL;
 	}
-	if (obd->obd_nid_hash) {
-		cfs_hash_putref(obd->obd_nid_hash);
-		obd->obd_nid_hash = NULL;
-	}
 	obd->obd_starting = 0;
 	CERROR("setup %s failed (%d)\n", obd->obd_name, err);
 	return err;
@@ -499,12 +480,6 @@ int class_cleanup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		obd->obd_uuid_hash = NULL;
 	}
 
-	/* destroy a nid-export hash body */
-	if (obd->obd_nid_hash) {
-		cfs_hash_putref(obd->obd_nid_hash);
-		obd->obd_nid_hash = NULL;
-	}
-
 	class_decref(obd, "setup", obd);
 	obd->obd_set_up = 0;
 
@@ -1516,73 +1491,3 @@ static cfs_hash_ops_t uuid_hash_ops = {
 	.hs_get	 = uuid_export_get,
 	.hs_put_locked  = uuid_export_put_locked,
 };
-
-
-/*
- * nid<->export hash operations
- */
-
-static unsigned
-nid_hash(struct cfs_hash *hs, const void *key, unsigned mask)
-{
-	return cfs_hash_djb2_hash(key, sizeof(lnet_nid_t), mask);
-}
-
-static void *
-nid_key(struct hlist_node *hnode)
-{
-	struct obd_export *exp;
-
-	exp = hlist_entry(hnode, struct obd_export, exp_nid_hash);
-
-	return &exp->exp_connection->c_peer.nid;
-}
-
-/*
- * NOTE: It is impossible to find an export that is in failed
- *       state with this function
- */
-static int
-nid_kepcmp(const void *key, struct hlist_node *hnode)
-{
-	struct obd_export *exp;
-
-	LASSERT(key);
-	exp = hlist_entry(hnode, struct obd_export, exp_nid_hash);
-
-	return exp->exp_connection->c_peer.nid == *(lnet_nid_t *)key &&
-	       !exp->exp_failed;
-}
-
-static void *
-nid_export_object(struct hlist_node *hnode)
-{
-	return hlist_entry(hnode, struct obd_export, exp_nid_hash);
-}
-
-static void
-nid_export_get(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-	struct obd_export *exp;
-
-	exp = hlist_entry(hnode, struct obd_export, exp_nid_hash);
-	class_export_get(exp);
-}
-
-static void
-nid_export_put_locked(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-	struct obd_export *exp;
-
-	exp = hlist_entry(hnode, struct obd_export, exp_nid_hash);
-	class_export_put(exp);
-}
-
-static cfs_hash_ops_t nid_hash_ops = {
-	.hs_hash	= nid_hash,
-	.hs_key	 = nid_key,
-	.hs_keycmp      = nid_kepcmp,
-	.hs_object      = nid_export_object,
-	.hs_get	 = nid_export_get,
-	.hs_put_locked  = nid_export_put_locked,
-};
-- 
2.1.0
