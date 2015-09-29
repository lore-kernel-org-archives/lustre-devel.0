From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:49 -0400
Subject: [lustre-devel] [PATCH 06/29] staging/lustre: Remove high-priority
	request callbacks
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-7-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

This function is only used on the server where real high-priority
requests actually exist.
This deletes ptlrpc_hpreq_handler() and ptlrpc_request_change_export()

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |  3 --
 drivers/staging/lustre/lustre/ptlrpc/service.c     | 53 ----------------------
 2 files changed, 56 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index e7faf0e..090484b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -2526,7 +2526,6 @@ struct ptlrpc_service_conf {
  */
 void ptlrpc_dispatch_difficult_reply(struct ptlrpc_reply_state *rs);
 void ptlrpc_schedule_difficult_reply(struct ptlrpc_reply_state *rs);
-int ptlrpc_hpreq_handler(struct ptlrpc_request *req);
 struct ptlrpc_service *ptlrpc_register_service(
 				struct ptlrpc_service_conf *conf,
 				struct kset *parent,
@@ -2538,8 +2537,6 @@ int ptlrpc_unregister_service(struct ptlrpc_service *service);
 int liblustre_check_services(void *arg);
 void ptlrpc_daemonize(char *name);
 void ptlrpc_server_drop_request(struct ptlrpc_request *req);
-void ptlrpc_request_change_export(struct ptlrpc_request *req,
-				  struct obd_export *export);
 
 int ptlrpc_hr_init(void);
 void ptlrpc_hr_fini(void);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 506fc36..353ac22 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -819,35 +819,6 @@ void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 	}
 }
 
-/** Change request export and move hp request from old export to new */
-void ptlrpc_request_change_export(struct ptlrpc_request *req,
-				  struct obd_export *export)
-{
-	if (req->rq_export != NULL) {
-		if (!list_empty(&req->rq_exp_list)) {
-			/* remove rq_exp_list from last export */
-			spin_lock_bh(&req->rq_export->exp_rpc_lock);
-			list_del_init(&req->rq_exp_list);
-			spin_unlock_bh(&req->rq_export->exp_rpc_lock);
-
-			/* export has one reference already, so it`s safe to
-			 * add req to export queue here and get another
-			 * reference for request later */
-			spin_lock_bh(&export->exp_rpc_lock);
-			list_add(&req->rq_exp_list, &export->exp_hp_rpcs);
-			spin_unlock_bh(&export->exp_rpc_lock);
-		}
-		class_export_rpc_dec(req->rq_export);
-		class_export_put(req->rq_export);
-	}
-
-	/* request takes one export refcount */
-	req->rq_export = class_export_get(export);
-	class_export_rpc_inc(export);
-
-	return;
-}
-
 /**
  * to finish a request: stop sending more early replies, and release
  * the request.
@@ -1329,30 +1300,6 @@ static void ptlrpc_server_hpreq_fini(struct ptlrpc_request *req)
 	}
 }
 
-static int ptlrpc_hpreq_check(struct ptlrpc_request *req)
-{
-	return 1;
-}
-
-static struct ptlrpc_hpreq_ops ptlrpc_hpreq_common = {
-	.hpreq_check       = ptlrpc_hpreq_check,
-};
-
-/* Hi-Priority RPC check by RPC operation code. */
-int ptlrpc_hpreq_handler(struct ptlrpc_request *req)
-{
-	int opc = lustre_msg_get_opc(req->rq_reqmsg);
-
-	/* Check for export to let only reconnects for not yet evicted
-	 * export to become a HP rpc. */
-	if ((req->rq_export != NULL) &&
-	    (opc == OBD_PING || opc == MDS_CONNECT || opc == OST_CONNECT))
-		req->rq_ops = &ptlrpc_hpreq_common;
-
-	return 0;
-}
-EXPORT_SYMBOL(ptlrpc_hpreq_handler);
-
 static int ptlrpc_server_request_add(struct ptlrpc_service_part *svcpt,
 				     struct ptlrpc_request *req)
 {
-- 
2.1.0
