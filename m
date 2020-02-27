From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:35 -0500
Subject: [lustre-devel] [PATCH 047/622] lustre: llog: remove obsolete llog
 handlers
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-48-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

Remove the obsolete llog RPC handling for cancel, close, and
destroy. Remove llog handling from ldlm_callback_handler(). Remove the
unused client side method llog_client_destroy().

WC-bug-id: https://jira.whamcloud.com/browse/LU-10855
Lustre-commit: 85011d372dfb ("LU-10855 llog: remove obsolete llog handlers")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32202
Reviewed-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_req_layout.h  |  3 ---
 fs/lustre/ptlrpc/layout.c              | 26 --------------------------
 include/uapi/linux/lustre/lustre_idl.h | 12 ++++++------
 3 files changed, 6 insertions(+), 35 deletions(-)

diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index 2348569..2737240 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -212,13 +212,10 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_format RQF_LDLM_GL_CALLBACK;
 extern struct req_format RQF_LDLM_GL_CALLBACK_DESC;
 /* LOG req_format */
-extern struct req_format RQF_LOG_CANCEL;
 extern struct req_format RQF_LLOG_ORIGIN_HANDLE_CREATE;
-extern struct req_format RQF_LLOG_ORIGIN_HANDLE_DESTROY;
 extern struct req_format RQF_LLOG_ORIGIN_HANDLE_NEXT_BLOCK;
 extern struct req_format RQF_LLOG_ORIGIN_HANDLE_PREV_BLOCK;
 extern struct req_format RQF_LLOG_ORIGIN_HANDLE_READ_HEADER;
-extern struct req_format RQF_LLOG_ORIGIN_CONNECT;
 
 extern struct req_format RQF_CONNECT;
 
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 4909b30..8fe661d 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -88,11 +88,6 @@
 	&RMF_MGS_CONFIG_RES
 };
 
-static const struct req_msg_field *log_cancel_client[] = {
-	&RMF_PTLRPC_BODY,
-	&RMF_LOGCOOKIES
-};
-
 static const struct req_msg_field *mdt_body_only[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_MDT_BODY
@@ -547,11 +542,6 @@
 	&RMF_LLOG_LOG_HDR
 };
 
-static const struct req_msg_field *llogd_conn_body_only[] = {
-	&RMF_PTLRPC_BODY,
-	&RMF_LLOGD_CONN_BODY
-};
-
 static const struct req_msg_field *llog_origin_handle_next_block_server[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_LLOGD_BODY,
@@ -766,13 +756,10 @@
 	&RQF_LDLM_INTENT_CREATE,
 	&RQF_LDLM_INTENT_UNLINK,
 	&RQF_LDLM_INTENT_GETXATTR,
-	&RQF_LOG_CANCEL,
 	&RQF_LLOG_ORIGIN_HANDLE_CREATE,
-	&RQF_LLOG_ORIGIN_HANDLE_DESTROY,
 	&RQF_LLOG_ORIGIN_HANDLE_NEXT_BLOCK,
 	&RQF_LLOG_ORIGIN_HANDLE_PREV_BLOCK,
 	&RQF_LLOG_ORIGIN_HANDLE_READ_HEADER,
-	&RQF_LLOG_ORIGIN_CONNECT,
 	&RQF_CONNECT,
 };
 
@@ -1254,10 +1241,6 @@ struct req_format RQF_FLD_READ =
 	DEFINE_REQ_FMT0("FLD_READ", fld_read_client, fld_read_server);
 EXPORT_SYMBOL(RQF_FLD_READ);
 
-struct req_format RQF_LOG_CANCEL =
-	DEFINE_REQ_FMT0("OBD_LOG_CANCEL", log_cancel_client, empty);
-EXPORT_SYMBOL(RQF_LOG_CANCEL);
-
 struct req_format RQF_MDS_QUOTACTL =
 	DEFINE_REQ_FMT0("MDS_QUOTACTL", quotactl_only, quotactl_only);
 EXPORT_SYMBOL(RQF_MDS_QUOTACTL);
@@ -1511,11 +1494,6 @@ struct req_format RQF_LLOG_ORIGIN_HANDLE_CREATE =
 			llog_origin_handle_create_client, llogd_body_only);
 EXPORT_SYMBOL(RQF_LLOG_ORIGIN_HANDLE_CREATE);
 
-struct req_format RQF_LLOG_ORIGIN_HANDLE_DESTROY =
-	DEFINE_REQ_FMT0("LLOG_ORIGIN_HANDLE_DESTROY",
-			llogd_body_only, llogd_body_only);
-EXPORT_SYMBOL(RQF_LLOG_ORIGIN_HANDLE_DESTROY);
-
 struct req_format RQF_LLOG_ORIGIN_HANDLE_NEXT_BLOCK =
 	DEFINE_REQ_FMT0("LLOG_ORIGIN_HANDLE_NEXT_BLOCK",
 			llogd_body_only, llog_origin_handle_next_block_server);
@@ -1531,10 +1509,6 @@ struct req_format RQF_LLOG_ORIGIN_HANDLE_READ_HEADER =
 			llogd_body_only, llog_log_hdr_only);
 EXPORT_SYMBOL(RQF_LLOG_ORIGIN_HANDLE_READ_HEADER);
 
-struct req_format RQF_LLOG_ORIGIN_CONNECT =
-	DEFINE_REQ_FMT0("LLOG_ORIGIN_CONNECT", llogd_conn_body_only, empty);
-EXPORT_SYMBOL(RQF_LLOG_ORIGIN_CONNECT);
-
 struct req_format RQF_CONNECT =
 	DEFINE_REQ_FMT0("CONNECT", obd_connect_client, obd_connect_server);
 EXPORT_SYMBOL(RQF_CONNECT);
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index f437614..7cf7307 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2312,7 +2312,7 @@ struct cfg_marker {
 
 enum obd_cmd {
 	OBD_PING = 400,
-	OBD_LOG_CANCEL,
+	OBD_LOG_CANCEL,	/* Obsolete since 1.5. */
 	OBD_QC_CALLBACK, /* not used since 2.4 */
 	OBD_IDX_READ,
 	OBD_LAST_OPC
@@ -2624,12 +2624,12 @@ enum llogd_rpc_ops {
 	LLOG_ORIGIN_HANDLE_CREATE	= 501,
 	LLOG_ORIGIN_HANDLE_NEXT_BLOCK	= 502,
 	LLOG_ORIGIN_HANDLE_READ_HEADER	= 503,
-	LLOG_ORIGIN_HANDLE_WRITE_REC	= 504,
-	LLOG_ORIGIN_HANDLE_CLOSE	= 505,
-	LLOG_ORIGIN_CONNECT		= 506,
-	LLOG_CATINFO			= 507,  /* deprecated */
+	LLOG_ORIGIN_HANDLE_WRITE_REC	= 504,	/* Obsolete by 2.1. */
+	LLOG_ORIGIN_HANDLE_CLOSE	= 505,	/* Obsolete by 1.8. */
+	LLOG_ORIGIN_CONNECT		= 506,	/* Obsolete by 2.4. */
+	LLOG_CATINFO			= 507,  /* Obsolete by 2.3. */
 	LLOG_ORIGIN_HANDLE_PREV_BLOCK	= 508,
-	LLOG_ORIGIN_HANDLE_DESTROY	= 509,  /* for destroy llog object*/
+	LLOG_ORIGIN_HANDLE_DESTROY	= 509,  /* Obsolete. */
 	LLOG_LAST_OPC,
 	LLOG_FIRST_OPC			= LLOG_ORIGIN_HANDLE_CREATE
 };
-- 
1.8.3.1
