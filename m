From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:51 -0500
Subject: [lustre-devel] [PATCH 243/622] lustre: ptlrpc: manage SELinux
 policy info at connect time
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-244-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

At connect time, compute SELinux policy info on client side, and
send it over the wire.
On server side, get SELinux policy info from nodemap and compare
it with the one received from client.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8955
Lustre-commit: dd200e5530fd ("LU-8955 ptlrpc: manage SELinux policy info at connect time")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/24422
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_req_layout.h |  1 +
 fs/lustre/llite/llite_lib.c           |  4 ++++
 fs/lustre/ptlrpc/import.c             | 16 +++++++++++++++-
 fs/lustre/ptlrpc/layout.c             |  7 ++++++-
 4 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index 36656c6..9b618fe 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -269,6 +269,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_msg_field RMF_HSM_STATE_SET;
 extern struct req_msg_field RMF_MDS_HSM_CURRENT_ACTION;
 extern struct req_msg_field RMF_MDS_HSM_REQUEST;
+extern struct req_msg_field RMF_SELINUX_POL;
 
 /* seq-mgr fields */
 extern struct req_msg_field RMF_SEQ_OPC;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 4d41981a..10d9180 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -256,6 +256,10 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	obd_connect_set_secctx(data);
 
+#if defined(CONFIG_SECURITY)
+	data->ocd_connect_flags2 |= OBD_CONNECT2_SELINUX_POLICY;
+#endif
+
 	data->ocd_brw_size = MD_MAX_BRW_SIZE;
 
 	err = obd_connect(NULL, &sbi->ll_md_exp, sbi->ll_md_obd,
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 34a2cb0..39d9e3e 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -606,7 +606,8 @@ int ptlrpc_connect_import(struct obd_import *imp)
 			 obd2cli_tgt(imp->imp_obd),
 			 obd->obd_uuid.uuid,
 			 (char *)&imp->imp_dlm_handle,
-			 (char *)&imp->imp_connect_data };
+			 (char *)&imp->imp_connect_data,
+			 NULL };
 	struct ptlrpc_connect_async_args *aa;
 	int rc;
 
@@ -670,6 +671,19 @@ int ptlrpc_connect_import(struct obd_import *imp)
 		goto out;
 	}
 
+	/* get SELinux policy info if any */
+	rc = sptlrpc_get_sepol(request);
+	if (rc < 0) {
+		ptlrpc_request_free(request);
+		goto out;
+	}
+
+	bufs[5] = request->rq_sepol;
+
+	req_capsule_set_size(&request->rq_pill, &RMF_SELINUX_POL, RCL_CLIENT,
+			     strlen(request->rq_sepol) ?
+			     strlen(request->rq_sepol) + 1 : 0);
+
 	rc = ptlrpc_request_bufs_pack(request, LUSTRE_OBD_VERSION,
 				      imp->imp_connect_op, bufs, NULL);
 	if (rc) {
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 1dd18b9..f80c627 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -315,7 +315,8 @@
 	&RMF_TGTUUID,
 	&RMF_CLUUID,
 	&RMF_CONN,
-	&RMF_CONNECT_DATA
+	&RMF_CONNECT_DATA,
+	&RMF_SELINUX_POL,
 };
 
 static const struct req_msg_field *obd_connect_server[] = {
@@ -1039,6 +1040,10 @@ struct req_msg_field RMF_LAYOUT_INTENT =
 		    NULL);
 EXPORT_SYMBOL(RMF_LAYOUT_INTENT);
 
+struct req_msg_field RMF_SELINUX_POL =
+	DEFINE_MSGF("selinux_pol", RMF_F_STRING, -1, NULL, NULL);
+EXPORT_SYMBOL(RMF_SELINUX_POL);
+
 /*
  * OST request field.
  */
-- 
1.8.3.1
