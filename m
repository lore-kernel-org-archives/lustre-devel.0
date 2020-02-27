From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:03 -0500
Subject: [lustre-devel] [PATCH 255/622] lustre: ptlrpc: IR doesn't reconnect
 after EAGAIN
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-256-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sergey Cheremencev <c17829@cray.com>

There is a chance that client is connecting to OST
before recovery start when OST is not configured.
In such case OST returns EAGAIN(target->obd_no_conn == 1).
There is no problem when pinger_recov is enabled
because ptlrpc_pinger_main will reconnect later.
But it doesn't reconnect when pinger_recov is 0.

Move setting imp_connect_error to ptlrpc_connect_interpret.
It is needed to store there only connection errors.

Cray-bug-id: LUS-2034
WC-bug-id: https://jira.whamcloud.com/browse/LU-11601
Lustre-commit: 3341c8c31871 ("LU-11601 ptlrpc: IR doesn't reconnect after EAGAIN")
Signed-off-by: Sergey Cheremencev <c17829@cray.com>
Reviewed-on: https://es-gerrit.dev.cray.com/153542
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-on: https://review.whamcloud.com/33557
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h | 1 +
 fs/lustre/ptlrpc/client.c       | 1 -
 fs/lustre/ptlrpc/import.c       | 1 +
 fs/lustre/ptlrpc/pinger.c       | 3 ++-
 4 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 36955e8..9ebdcb6 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -264,6 +264,7 @@
 #define OBD_FAIL_OST_STATFS_EINPROGRESS			0x231
 #define OBD_FAIL_OST_SET_INFO_NET			0x232
 #define OBD_FAIL_OST_DISCONNECT_DELAY	 0x245
+#define OBD_FAIL_OST_PREPARE_DELAY	 0x247
 
 #define OBD_FAIL_LDLM					0x300
 #define OBD_FAIL_LDLM_NAMESPACE_NEW			0x301
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index f57ec1883..0f5aa92 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1457,7 +1457,6 @@ static int after_reply(struct ptlrpc_request *req)
 				  lustre_msg_get_service_time(req->rq_repmsg));
 
 	rc = ptlrpc_check_status(req);
-	imp->imp_connect_error = rc;
 
 	if (rc) {
 		/*
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 39d9e3e..a75856a 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -944,6 +944,7 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		return 0;
 	}
 
+	imp->imp_connect_error = rc;
 	if (rc) {
 		struct ptlrpc_request *free_req;
 		struct ptlrpc_request *tmp;
diff --git a/fs/lustre/ptlrpc/pinger.c b/fs/lustre/ptlrpc/pinger.c
index c565e2d..c3fbddc 100644
--- a/fs/lustre/ptlrpc/pinger.c
+++ b/fs/lustre/ptlrpc/pinger.c
@@ -228,7 +228,8 @@ static void ptlrpc_pinger_process_import(struct obd_import *imp,
 	if (level == LUSTRE_IMP_DISCON && !imp_is_deactive(imp)) {
 		/* wait for a while before trying recovery again */
 		imp->imp_next_ping = ptlrpc_next_reconnect(imp);
-		if (!imp->imp_no_pinger_recover)
+		if (!imp->imp_no_pinger_recover ||
+		    imp->imp_connect_error == -EAGAIN)
 			ptlrpc_initiate_recovery(imp);
 	} else if (level != LUSTRE_IMP_FULL ||
 		   imp->imp_obd->obd_no_recov ||
-- 
1.8.3.1
