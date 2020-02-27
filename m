From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:03 -0500
Subject: [lustre-devel] [PATCH 375/622] lustre: ldlm: Fix style issues for
 ldlm_lib.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-376-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch fixes issues reported by checkpatch for
file fs/lustre/ldlm/ldlm_lib.c

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 939cdd034e7b ("LU-6142 ldlm: Fix style issues for ldlm_lib.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/34495
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lib.c | 35 +++++++++++++++++++++++------------
 1 file changed, 23 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 4a982ab..af74f97 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -48,7 +48,8 @@
 #include <lustre_sec.h>
 #include "ldlm_internal.h"
 
-/* @priority: If non-zero, move the selected connection to the list head.
+/*
+ * @priority: If non-zero, move the selected connection to the list head.
  * @create: If zero, only search in existing connections.
  */
 static int import_set_conn(struct obd_import *imp, struct obd_uuid *uuid,
@@ -223,7 +224,8 @@ int client_import_find_conn(struct obd_import *imp, lnet_nid_t peer,
 
 void client_destroy_import(struct obd_import *imp)
 {
-	/* Drop security policy instance after all RPCs have finished/aborted
+	/*
+	 * Drop security policy instance after all RPCs have finished/aborted
 	 * to let all busy contexts be released.
 	 */
 	class_import_get(imp);
@@ -233,7 +235,8 @@ void client_destroy_import(struct obd_import *imp)
 }
 EXPORT_SYMBOL(client_destroy_import);
 
-/* Configure an RPC client OBD device.
+/*
+ * Configure an RPC client OBD device.
  *
  * lcfg parameters:
  * 1 - client UUID
@@ -255,7 +258,8 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	};
 	int rc;
 
-	/* In a more perfect world, we would hang a ptlrpc_client off of
+	/*
+	 * In a more perfect world, we would hang a ptlrpc_client off of
 	 * obd_type and just use the values from there.
 	 */
 	if (!strcmp(name, LUSTRE_OSC_NAME)) {
@@ -630,7 +634,8 @@ int client_disconnect_export(struct obd_export *exp)
 		goto out_disconnect;
 	}
 
-	/* Mark import deactivated now, so we don't try to reconnect if any
+	/*
+	 * Mark import deactivated now, so we don't try to reconnect if any
 	 * of the cleanup RPCs fails (e.g. LDLM cancel, etc).  We don't
 	 * fully deactivate the import, or that would drop all requests.
 	 */
@@ -638,7 +643,8 @@ int client_disconnect_export(struct obd_export *exp)
 	imp->imp_deactive = 1;
 	spin_unlock(&imp->imp_lock);
 
-	/* Some non-replayable imports (MDS's OSCs) are pinged, so just
+	/*
+	 * Some non-replayable imports (MDS's OSCs) are pinged, so just
 	 * delete it regardless.  (It's safe to delete an import that was
 	 * never added.)
 	 */
@@ -652,7 +658,8 @@ int client_disconnect_export(struct obd_export *exp)
 					  obd->obd_force);
 	}
 
-	/* There's no need to hold sem while disconnecting an import,
+	/*
+	 * There's no need to hold sem while disconnecting an import,
 	 * and it may actually cause deadlock in GSS.
 	 */
 	up_write(&cli->cl_sem);
@@ -662,7 +669,8 @@ int client_disconnect_export(struct obd_export *exp)
 	ptlrpc_invalidate_import(imp);
 
 out_disconnect:
-	/* Use server style - class_disconnect should be always called for
+	/*
+	 * Use server style - class_disconnect should be always called for
 	 * o_disconnect.
 	 */
 	err = class_disconnect(exp);
@@ -680,9 +688,10 @@ int client_disconnect_export(struct obd_export *exp)
  */
 int target_pack_pool_reply(struct ptlrpc_request *req)
 {
-	struct obd_device *obd;
+struct obd_device *obd;
 
-	/* Check that we still have all structures alive as this may
+	/*
+	 * Check that we still have all structures alive as this may
 	 * be some late RPC at shutdown time.
 	 */
 	if (unlikely(!req->rq_export || !req->rq_export->exp_obd ||
@@ -711,7 +720,8 @@ int target_pack_pool_reply(struct ptlrpc_request *req)
 		DEBUG_REQ(D_ERROR, req, "dropping reply");
 		return -ECOMM;
 	}
-	/* We can have a null rq_reqmsg in the event of bad signature or
+	/*
+	 * We can have a null rq_reqmsg in the event of bad signature or
 	 * no context when unwrapping
 	 */
 	if (req->rq_reqmsg &&
@@ -792,7 +802,8 @@ void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id)
 	atomic_inc(&svcpt->scp_nreps_difficult);
 
 	if (netrc != 0) {
-		/* error sending: reply is off the net.  Also we need +1
+		/*
+		 * error sending: reply is off the net.  Also we need +1
 		 * reply ref until ptlrpc_handle_rs() is done
 		 * with the reply state (if the send was successful, there
 		 * would have been +1 ref for the net, which
-- 
1.8.3.1
