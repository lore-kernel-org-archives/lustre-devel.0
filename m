From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:19:59 -0400
Subject: [lustre-devel] [PATCH 03/23] lustre: ptlrpc: make
 ptlrpc_connection_put() static inline
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

This function needs to be called from the obdclass modules,
but is currently defined in a module that depends on that module.
The get around this interdependence, a global variable
  ptlrpc_put_connection_superhack
is used to make a pointer to the function available.

Rather than this hack, we can make ptlrpc_connection_put()
static-inline.  This does expose some details of ptlrpc to obdclass,
but there is already a fairly tight connection.

Also change the return value to 'void' as it is never used,
and don't bother checking for NULL before calling, as the
function has its own test for NULL.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9679
Lustre-commit: 0a03e51b7e49a ("LU-9679 lustre: make ptlrpc_connection_put() static inline")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39291
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h   | 32 +++++++++++++++++++++++++++++++-
 fs/lustre/include/obd_class.h    |  8 --------
 fs/lustre/obdclass/genops.c      | 11 +++--------
 fs/lustre/ptlrpc/connection.c    | 35 -----------------------------------
 fs/lustre/ptlrpc/import.c        |  6 ++----
 fs/lustre/ptlrpc/ptlrpc_module.c |  2 --
 6 files changed, 36 insertions(+), 58 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 2d58f13e..dd482bc 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1777,7 +1777,37 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 struct ptlrpc_connection *ptlrpc_connection_get(struct lnet_process_id peer,
 						lnet_nid_t self,
 						struct obd_uuid *uuid);
-int ptlrpc_connection_put(struct ptlrpc_connection *c);
+
+static inline void  ptlrpc_connection_put(struct ptlrpc_connection *conn)
+{
+	if (!conn)
+		return;
+
+	LASSERT(atomic_read(&conn->c_refcount) > 0);
+
+	/*
+	 * We do not remove connection from hashtable and
+	 * do not free it even if last caller released ref,
+	 * as we want to have it cached for the case it is
+	 * needed again.
+	 *
+	 * Deallocating it and later creating new connection
+	 * again would be wastful. This way we also avoid
+	 * expensive locking to protect things from get/put
+	 * race when found cached connection is freed by
+	 * ptlrpc_connection_put().
+	 *
+	 * It will be freed later in module unload time,
+	 * when ptlrpc_connection_fini()->lh_exit->conn_exit()
+	 * path is called.
+	 */
+	atomic_dec(&conn->c_refcount);
+
+	CDEBUG(D_INFO, "PUT conn=%p refcount %d to %s\n",
+	       conn, atomic_read(&conn->c_refcount),
+	       libcfs_nid2str(conn->c_peer.nid));
+}
+
 struct ptlrpc_connection *ptlrpc_connection_addref(struct ptlrpc_connection *);
 int ptlrpc_connection_init(void);
 void ptlrpc_connection_fini(void);
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index e8168bc5..187553d 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1691,14 +1691,6 @@ struct lwp_register_item {
 	char			lri_name[MTI_NAME_MAXLEN];
 };
 
-/*
- * I'm as embarrassed about this as you are.
- *
- * <shaver> // XXX do not look into _superhack with remaining eye
- * <shaver> // XXX if this were any uglier, I'd get my own show on MTV
- */
-extern int (*ptlrpc_put_connection_superhack)(struct ptlrpc_connection *c);
-
 /* obd_mount.c */
 int lustre_check_exclusion(struct super_block *sb, char *svname);
 
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 759d97e..7bc4dab 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -53,9 +53,6 @@
 static void obd_zombie_export_add(struct obd_export *exp);
 static void obd_zombie_import_add(struct obd_import *imp);
 
-int (*ptlrpc_put_connection_superhack)(struct ptlrpc_connection *c);
-EXPORT_SYMBOL(ptlrpc_put_connection_superhack);
-
 /*
  * support functions: we could use inter-module communication, but this
  * is more portable to other OS's
@@ -717,9 +714,7 @@ static void class_export_destroy(struct obd_export *exp)
 	CDEBUG(D_IOCTL, "destroying export %p/%s for %s\n", exp,
 	       exp->exp_client_uuid.uuid, obd->obd_name);
 
-	/* "Local" exports (lctl, LOV->{mdc,osc}) have no connection. */
-	if (exp->exp_connection)
-		ptlrpc_put_connection_superhack(exp->exp_connection);
+	ptlrpc_connection_put(exp->exp_connection);
 
 	LASSERT(list_empty(&exp->exp_outstanding_replies));
 	LASSERT(list_empty(&exp->exp_uncommitted_replies));
@@ -907,13 +902,13 @@ static void obd_zombie_import_free(struct obd_import *imp)
 
 	LASSERT(refcount_read(&imp->imp_refcount) == 0);
 
-	ptlrpc_put_connection_superhack(imp->imp_connection);
+	ptlrpc_connection_put(imp->imp_connection);
 
 	while ((imp_conn = list_first_entry_or_null(&imp->imp_conn_list,
 						    struct obd_import_conn,
 						    oic_item)) != NULL) {
 		list_del_init(&imp_conn->oic_item);
-		ptlrpc_put_connection_superhack(imp_conn->oic_conn);
+		ptlrpc_connection_put(imp_conn->oic_conn);
 		kfree(imp_conn);
 	}
 
diff --git a/fs/lustre/ptlrpc/connection.c b/fs/lustre/ptlrpc/connection.c
index a548d99..1551a9a 100644
--- a/fs/lustre/ptlrpc/connection.c
+++ b/fs/lustre/ptlrpc/connection.c
@@ -130,41 +130,6 @@ struct ptlrpc_connection *
 	return conn;
 }
 
-int ptlrpc_connection_put(struct ptlrpc_connection *conn)
-{
-	int rc = 0;
-
-	if (!conn)
-		return rc;
-
-	LASSERT(atomic_read(&conn->c_refcount) > 0);
-
-	/*
-	 * We do not remove connection from hashtable and
-	 * do not free it even if last caller released ref,
-	 * as we want to have it cached for the case it is
-	 * needed again.
-	 *
-	 * Deallocating it and later creating new connection
-	 * again would be wastful. This way we also avoid
-	 * expensive locking to protect things from get/put
-	 * race when found cached connection is freed by
-	 * ptlrpc_connection_put().
-	 *
-	 * It will be freed later in module unload time,
-	 * when ptlrpc_connection_fini()->lh_exit->conn_exit()
-	 * path is called.
-	 */
-	if (atomic_dec_return(&conn->c_refcount) == 0)
-		rc = 1;
-
-	CDEBUG(D_INFO, "PUT conn=%p refcount %d to %s\n",
-	       conn, atomic_read(&conn->c_refcount),
-	       libcfs_nid2str(conn->c_peer.nid));
-
-	return rc;
-}
-
 struct ptlrpc_connection *
 ptlrpc_connection_addref(struct ptlrpc_connection *conn)
 {
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 1490dcf..4e573cd 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -571,8 +571,7 @@ static int import_select_connection(struct obd_import *imp)
 	imp_conn->oic_last_attempt = ktime_get_seconds();
 
 	/* switch connection, don't mind if it's same as the current one */
-	if (imp->imp_connection)
-		ptlrpc_connection_put(imp->imp_connection);
+	ptlrpc_connection_put(imp->imp_connection);
 	imp->imp_connection = ptlrpc_connection_addref(imp_conn->oic_conn);
 
 	dlmexp = class_conn2export(&imp->imp_dlm_handle);
@@ -580,8 +579,7 @@ static int import_select_connection(struct obd_import *imp)
 		rc = -EINVAL;
 		goto out_unlock;
 	}
-	if (dlmexp->exp_connection)
-		ptlrpc_connection_put(dlmexp->exp_connection);
+	ptlrpc_connection_put(dlmexp->exp_connection);
 	dlmexp->exp_connection = ptlrpc_connection_addref(imp_conn->oic_conn);
 	class_export_put(dlmexp);
 
diff --git a/fs/lustre/ptlrpc/ptlrpc_module.c b/fs/lustre/ptlrpc/ptlrpc_module.c
index 0c988ae..85fb0fa 100644
--- a/fs/lustre/ptlrpc/ptlrpc_module.c
+++ b/fs/lustre/ptlrpc/ptlrpc_module.c
@@ -49,8 +49,6 @@ int ptlrpc_inc_ref(void)
 
 	mutex_lock(&ptlrpc_startup);
 	if (ptlrpc_active++ == 0) {
-		ptlrpc_put_connection_superhack = ptlrpc_connection_put;
-
 		rc = ptlrpc_init_portals();
 		if (!rc) {
 			rc = ptlrpc_start_pinger();
-- 
1.8.3.1
