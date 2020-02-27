From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:05 -0500
Subject: [lustre-devel] [PATCH 017/622] lustre: obdclass: new wrapper to
 convert NID to string
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Liang Zhen <liang.zhen@intel.com>

This patch includes a couple of changes:
- add new wrapper function obd_import_nid2str
- use obd_import_nid2str and obd_export_nid2str to replace all
  libcfs_nid2str conversions for NID of export/import connection

WC-bug-id: https://jira.whamcloud.com/browse/LU-6032
Lustre-commit: 61f9847a812f ("LU-6032 obdclass: new wrapper to convert NID to string")
Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-on: https://review.whamcloud.com/12956
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h | 12 ++++++++++++
 fs/lustre/ldlm/ldlm_lock.c    |  4 ++--
 fs/lustre/ptlrpc/client.c     |  5 ++---
 fs/lustre/ptlrpc/import.c     |  6 +++---
 4 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 146c37e..d896049 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -86,6 +86,18 @@ struct obd_device *class_devices_in_group(struct obd_uuid *grp_uuid,
 int obd_connect_flags2str(char *page, int count, u64 flags, u64 flags2,
 			  const char *sep);
 
+static inline char *obd_export_nid2str(struct obd_export *exp)
+{
+	return exp->exp_connection ?
+		libcfs_nid2str(exp->exp_connection->c_peer.nid) : "<unknown>";
+}
+
+static inline char *obd_import_nid2str(struct obd_import *imp)
+{
+	return imp->imp_connection ?
+		libcfs_nid2str(imp->imp_connection->c_peer.nid) : "<unknown>";
+}
+
 int obd_zombie_impexp_init(void);
 void obd_zombie_impexp_stop(void);
 void obd_zombie_barrier(void);
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 7242cd1..aa19b89 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -1987,11 +1987,11 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 	vaf.va = &args;
 
 	if (exp && exp->exp_connection) {
-		nid = libcfs_nid2str(exp->exp_connection->c_peer.nid);
+		nid = obd_export_nid2str(exp);
 	} else if (exp && exp->exp_obd) {
 		struct obd_import *imp = exp->exp_obd->u.cli.cl_import;
 
-		nid = libcfs_nid2str(imp->imp_connection->c_peer.nid);
+		nid = obd_import_nid2str(imp);
 	}
 
 	if (!resource) {
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index a533cbb..424db55 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1605,8 +1605,7 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 	       current->comm,
 	       imp->imp_obd->obd_uuid.uuid,
 	       lustre_msg_get_status(req->rq_reqmsg), req->rq_xid,
-	       libcfs_nid2str(imp->imp_connection->c_peer.nid),
-	       lustre_msg_get_opc(req->rq_reqmsg));
+	       obd_import_nid2str(imp), lustre_msg_get_opc(req->rq_reqmsg));
 
 	rc = ptl_send_rpc(req, 0);
 	if (rc == -ENOMEM) {
@@ -2017,7 +2016,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 			       current->comm, imp->imp_obd->obd_uuid.uuid,
 			       lustre_msg_get_status(req->rq_reqmsg),
 			       req->rq_xid,
-			       libcfs_nid2str(imp->imp_connection->c_peer.nid),
+			       obd_import_nid2str(imp),
 			       lustre_msg_get_opc(req->rq_reqmsg));
 
 		spin_lock(&imp->imp_lock);
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index d032962..dca4aa0 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -171,13 +171,13 @@ int ptlrpc_set_import_discon(struct obd_import *imp, u32 conn_cnt)
 			LCONSOLE_WARN("%s: Connection to %.*s (at %s) was lost; in progress operations using this service will wait for recovery to complete\n",
 				      imp->imp_obd->obd_name,
 				      target_len, target_start,
-				      libcfs_nid2str(imp->imp_connection->c_peer.nid));
+				      obd_import_nid2str(imp));
 		} else {
 			LCONSOLE_ERROR_MSG(0x166,
 					   "%s: Connection to %.*s (at %s) was lost; in progress operations using this service will fail\n",
 					   imp->imp_obd->obd_name,
 					   target_len, target_start,
-					   libcfs_nid2str(imp->imp_connection->c_peer.nid));
+					   obd_import_nid2str(imp));
 		}
 		IMPORT_SET_STATE_NOLOCK(imp, LUSTRE_IMP_DISCON);
 		spin_unlock(&imp->imp_lock);
@@ -1461,7 +1461,7 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 		LCONSOLE_INFO("%s: Connection restored to %.*s (at %s)\n",
 			      imp->imp_obd->obd_name,
 			      target_len, target_start,
-			      libcfs_nid2str(imp->imp_connection->c_peer.nid));
+			      obd_import_nid2str(imp));
 	}
 
 	if (imp->imp_state == LUSTRE_IMP_FULL) {
-- 
1.8.3.1
