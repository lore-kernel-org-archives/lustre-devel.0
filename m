From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:41 -0500
Subject: [lustre-devel] [PATCH 293/622] lustre: ptlrpc: ocd_connect_flags
 are wrong during reconnect
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-294-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

Import connect flags are reset to original ones during
reconnect, so a request can be created with unsupported
features.

Use separate obd_connect_data to send connect request.

Cray-bug-id: LUS-6397
WC-bug-id: https://jira.whamcloud.com/browse/LU-12095
Lustre-commit: 1224084c6300 ("LU-12095 ptlrpc: ocd_connect_flags are wrong during reconnect")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-on: https://review.whamcloud.com/34480
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/import.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index a75856a..6f13ec1 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -602,11 +602,12 @@ int ptlrpc_connect_import(struct obd_import *imp)
 	int set_transno = 0;
 	u64 committed_before_reconnect = 0;
 	struct ptlrpc_request *request;
+	struct obd_connect_data ocd;
 	char *bufs[] = { NULL,
 			 obd2cli_tgt(imp->imp_obd),
 			 obd->obd_uuid.uuid,
 			 (char *)&imp->imp_dlm_handle,
-			 (char *)&imp->imp_connect_data,
+			 (char *)&ocd,
 			 NULL };
 	struct ptlrpc_connect_async_args *aa;
 	int rc;
@@ -653,15 +654,16 @@ int ptlrpc_connect_import(struct obd_import *imp)
 	/* Reset connect flags to the originally requested flags, in case
 	 * the server is updated on-the-fly we will get the new features.
 	 */
-	imp->imp_connect_data.ocd_connect_flags = imp->imp_connect_flags_orig;
-	imp->imp_connect_data.ocd_connect_flags2 = imp->imp_connect_flags2_orig;
+	ocd = imp->imp_connect_data;
+	ocd.ocd_connect_flags = imp->imp_connect_flags_orig;
+	ocd.ocd_connect_flags2 = imp->imp_connect_flags2_orig;
 	/* Reset ocd_version each time so the server knows the exact versions */
-	imp->imp_connect_data.ocd_version = LUSTRE_VERSION_CODE;
+	ocd.ocd_version = LUSTRE_VERSION_CODE;
 	imp->imp_msghdr_flags &= ~MSGHDR_AT_SUPPORT;
 	imp->imp_msghdr_flags &= ~MSGHDR_CKSUM_INCOMPAT18;
 
 	rc = obd_reconnect(NULL, imp->imp_obd->obd_self_export, obd,
-			   &obd->obd_uuid, &imp->imp_connect_data, NULL);
+			   &obd->obd_uuid, &ocd, NULL);
 	if (rc)
 		goto out;
 
-- 
1.8.3.1
