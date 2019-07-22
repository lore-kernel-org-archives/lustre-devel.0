From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:52:11 -0400
Subject: [lustre-devel] [PATCH 04/11] lustre: mgc: checkpatch cleanup
In-Reply-To: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
References: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563760338-806-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Many checkpatch errors exist in the mgc layer. This address
a good chuck of them. Other are left since future patches will
cleanup those areas. Others will need more code rework so this
patch handles the simple cases. This is a good step forward
toward proper kernel code style compliance.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mgc/mgc_request.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 5ce49e7..fa0be5c 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -96,7 +96,8 @@ int mgc_fsname2resid(char *fsname, struct ldlm_res_id *res_id, int type)
 }
 EXPORT_SYMBOL(mgc_fsname2resid);
 
-static int mgc_logname2resid(char *logname, struct ldlm_res_id *res_id, int type)
+static int mgc_logname2resid(char *logname, struct ldlm_res_id *res_id,
+			     int type)
 {
 	char *name_end;
 	int len;
@@ -474,7 +475,7 @@ int lprocfs_mgc_rd_ir_state(struct seq_file *m, void *data)
 
 	seq_printf(m, "imperative_recovery: %s\n",
 		   OCD_HAS_FLAG(ocd, IMP_RECOV) ? "ENABLED" : "DISABLED");
-	seq_printf(m, "client_state:\n");
+	seq_puts(m, "client_state:\n");
 
 	spin_lock(&config_list_lock);
 	list_for_each_entry(cld, &config_llog_list, cld_list_chain) {
@@ -821,7 +822,8 @@ static int mgc_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		 */
 		if (!lock->l_conn_export ||
 		    !lock->l_conn_export->exp_obd->u.cli.cl_conn_count) {
-			CDEBUG(D_MGC, "log %.8s: disconnecting, won't requeue\n",
+			CDEBUG(D_MGC,
+			       "log %.8s: disconnecting, won't requeue\n",
 			       cld->cld_logname);
 			config_log_put(cld);
 			break;
@@ -874,7 +876,8 @@ static int mgc_set_mgs_param(struct obd_export *exp,
 	req->rq_delay_limit = MGC_SEND_PARAM_LIMIT;
 	rc = ptlrpc_queue_wait(req);
 	if (!rc) {
-		rep_msp = req_capsule_server_get(&req->rq_pill, &RMF_MGS_SEND_PARAM);
+		rep_msp = req_capsule_server_get(&req->rq_pill,
+						 &RMF_MGS_SEND_PARAM);
 		memcpy(msp, rep_msp, sizeof(*rep_msp));
 	}
 
@@ -1733,7 +1736,7 @@ static int mgc_process_config(struct obd_device *obd, u32 len, void *buf)
 	case LCFG_LOV_DEL_OBD:
 		/* Unregister has no meaning at the moment. */
 		CERROR("lov_del_obd unimplemented\n");
-		rc = -ENOSYS;
+		rc = -ENXIO;
 		break;
 	case LCFG_SPTLRPC_CONF: {
 		rc = sptlrpc_process_config(lcfg);
@@ -1765,8 +1768,8 @@ static int mgc_process_config(struct obd_device *obd, u32 len, void *buf)
 
 		rc = mgc_process_log(obd, cld);
 		if (rc == 0 && cld->cld_recover) {
-			if (OCD_HAS_FLAG(&obd->u.cli.cl_import->
-					 imp_connect_data, IMP_RECOV)) {
+			if (OCD_HAS_FLAG(&obd->u.cli.cl_import->imp_connect_data,
+					 IMP_RECOV)) {
 				rc = mgc_process_log(obd, cld->cld_recover);
 			} else {
 				struct config_llog_data *cir;
-- 
1.8.3.1
