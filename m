From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:16 -0400
Subject: [lustre-devel] [PATCH 077/124] staging: lustre: ptlrpc: quiet
	errors on initial connection
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-78-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

It may be that a client or MDS is trying to connect to a target (OST
or peer MDT) before that target is finished setup. Rather than
spamming the console logs during initial connection, only print a
console error message if there are repeated failures trying to
connect to the target, which may indicate an error on that node.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3456
Reviewed-on: http://review.whamcloud.com/10057
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   52 +++++++++++---------
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    2 +-
 2 files changed, 30 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index a29ccaa..f3914cc 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1075,36 +1075,42 @@ static int ptlrpc_import_delay_req(struct obd_import *imp,
 }
 
 /**
- * Decide if the error message regarding provided request \a req
- * should be printed to the console or not.
- * Makes it's decision on request status and other properties.
- * Returns 1 to print error on the system console or 0 if not.
+ * Decide if the error message should be printed to the console or not.
+ * Makes its decision based on request type, status, and failure frequency.
+ *
+ * \param[in] req  request that failed and may need a console message
+ *
+ * \retval false if no message should be printed
+ * \retval true  if console message should be printed
  */
-static int ptlrpc_console_allow(struct ptlrpc_request *req)
+static bool ptlrpc_console_allow(struct ptlrpc_request *req)
 {
 	__u32 opc;
-	int err;
 
 	LASSERT(req->rq_reqmsg);
 	opc = lustre_msg_get_opc(req->rq_reqmsg);
 
-	/*
-	 * Suppress particular reconnect errors which are to be expected.  No
-	 * errors are suppressed for the initial connection on an import
-	 */
-	if ((lustre_handle_is_used(&req->rq_import->imp_remote_handle)) &&
-	    (opc == OST_CONNECT || opc == MDS_CONNECT || opc == MGS_CONNECT)) {
+	/* Suppress particular reconnect errors which are to be expected. */
+	if (opc == OST_CONNECT || opc == MDS_CONNECT || opc == MGS_CONNECT) {
+		int err;
+
 		/* Suppress timed out reconnect requests */
-		if (req->rq_timedout)
-			return 0;
+		if (lustre_handle_is_used(&req->rq_import->imp_remote_handle) ||
+		    req->rq_timedout)
+			return false;
 
-		/* Suppress unavailable/again reconnect requests */
+		/*
+		 * Suppress most unavailable/again reconnect requests, but
+		 * print occasionally so it is clear client is trying to
+		 * connect to a server where no target is running.
+		 */
 		err = lustre_msg_get_status(req->rq_repmsg);
-		if (err == -ENODEV || err == -EAGAIN)
-			return 0;
+		if ((err == -ENODEV || err == -EAGAIN) &&
+		    req->rq_import->imp_conn_cnt % 30 != 20)
+			return false;
 	}
 
-	return 1;
+	return true;
 }
 
 /**
@@ -1118,14 +1124,14 @@ static int ptlrpc_check_status(struct ptlrpc_request *req)
 	err = lustre_msg_get_status(req->rq_repmsg);
 	if (lustre_msg_get_type(req->rq_repmsg) == PTL_RPC_MSG_ERR) {
 		struct obd_import *imp = req->rq_import;
+		lnet_nid_t nid = imp->imp_connection->c_peer.nid;
 		__u32 opc = lustre_msg_get_opc(req->rq_reqmsg);
 
 		if (ptlrpc_console_allow(req))
-			LCONSOLE_ERROR_MSG(0x011, "%s: Communicating with %s, operation %s failed with %d.\n",
+			LCONSOLE_ERROR_MSG(0x011, "%s: operation %s to node %s failed: rc = %d\n",
 					   imp->imp_obd->obd_name,
-					   libcfs_nid2str(
-						   imp->imp_connection->c_peer.nid),
-					   ll_opcode2str(opc), err);
+					   ll_opcode2str(opc),
+					   libcfs_nid2str(nid), err);
 		return err < 0 ? err : -EINVAL;
 	}
 
@@ -1282,7 +1288,7 @@ static int after_reply(struct ptlrpc_request *req)
 		 * some reason. Try to reconnect, and if that fails, punt to
 		 * the upcall.
 		 */
-		if (ll_rpc_recoverable_error(rc)) {
+		if (ptlrpc_recoverable_error(rc)) {
 			if (req->rq_send_state != LUSTRE_IMP_FULL ||
 			    imp->imp_obd->obd_no_recov || imp->imp_dlm_fake) {
 				return rc;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index 29cfac2..b420aa8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -270,7 +270,7 @@ void sptlrpc_conf_fini(void);
 int  sptlrpc_init(void);
 void sptlrpc_fini(void);
 
-static inline int ll_rpc_recoverable_error(int rc)
+static inline bool ptlrpc_recoverable_error(int rc)
 {
 	return (rc == -ENOTCONN || rc == -ENODEV);
 }
-- 
1.7.1
