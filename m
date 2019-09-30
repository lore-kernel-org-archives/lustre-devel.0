From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:43 -0400
Subject: [lustre-devel] [PATCH 144/151] lustre: ptlrpc: use list_move where
 appropriate.
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-145-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

There are several places in lustre where "list_del" (or occasionally
"list_del_init") is followed by "list_add" or "list_add_tail" which
moves the object to a different list.
These can be combined into "list_move" or "list_move_tail".

WC-bug-id: https://jira.whamcloud.com/browse/LU-4423
Lustre-commit: a71948a4e6de ("LU-4423 ptlrpc: use list_move where appropriate")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35507
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lib.c     |  5 ++---
 fs/lustre/ldlm/ldlm_request.c |  3 +--
 fs/lustre/ptlrpc/client.c     | 10 ++++------
 fs/lustre/ptlrpc/import.c     |  3 +--
 fs/lustre/ptlrpc/service.c    | 13 ++++---------
 5 files changed, 12 insertions(+), 22 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 45dc70d..7bc1d10 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -86,9 +86,8 @@ static int import_set_conn(struct obd_import *imp, struct obd_uuid *uuid,
 	list_for_each_entry(item, &imp->imp_conn_list, oic_item) {
 		if (obd_uuid_equals(uuid, &item->oic_uuid)) {
 			if (priority) {
-				list_del(&item->oic_item);
-				list_add(&item->oic_item,
-					 &imp->imp_conn_list);
+				list_move(&item->oic_item,
+					  &imp->imp_conn_list);
 				item->oic_last_attempt = 0;
 			}
 			CDEBUG(D_HA, "imp %p@%s: found existing conn %s%s\n",
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 4c6db33..00336ca 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1132,8 +1132,7 @@ int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
 		 */
 		if (!(flags & LCF_BL_AST) && (rc == LDLM_FL_BL_AST)) {
 			LDLM_DEBUG(lock, "Cancel lock separately");
-			list_del_init(&lock->l_bl_ast);
-			list_add(&lock->l_bl_ast, &head);
+			list_move(&lock->l_bl_ast, &head);
 			bl_ast++;
 			continue;
 		}
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index e3aee32..6055980 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1833,9 +1833,8 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 					 * put on delay list - only if we wait
 					 * recovery finished - before send
 					 */
-					list_del_init(&req->rq_list);
-					list_add_tail(&req->rq_list,
-						      &imp->imp_delayed_list);
+					list_move_tail(&req->rq_list,
+						       &imp->imp_delayed_list);
 					spin_unlock(&imp->imp_lock);
 					continue;
 				}
@@ -1856,9 +1855,8 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 					goto interpret;
 				}
 
-				list_del_init(&req->rq_list);
-				list_add_tail(&req->rq_list,
-					      &imp->imp_sending_list);
+				list_move_tail(&req->rq_list,
+					       &imp->imp_sending_list);
 
 				spin_unlock(&imp->imp_lock);
 
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 32bd218..eb19ca6 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -753,8 +753,7 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 	static bool warned;
 
 	spin_lock(&imp->imp_lock);
-	list_del(&imp->imp_conn_current->oic_item);
-	list_add(&imp->imp_conn_current->oic_item, &imp->imp_conn_list);
+	list_move(&imp->imp_conn_current->oic_item, &imp->imp_conn_list);
 	imp->imp_last_success_conn = imp->imp_conn_current->oic_last_attempt;
 
 	spin_unlock(&imp->imp_lock);
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index e0cce15..c2a00de 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -307,11 +307,10 @@ void ptlrpc_dispatch_difficult_reply(struct ptlrpc_reply_state *rs)
 		rqbd = list_first_entry(&svcpt->scp_rqbd_idle,
 					struct ptlrpc_request_buffer_desc,
 					rqbd_list);
-		list_del(&rqbd->rqbd_list);
 
 		/* assume we will post successfully */
 		svcpt->scp_nrqbds_posted++;
-		list_add(&rqbd->rqbd_list, &svcpt->scp_rqbd_posted);
+		list_move(&rqbd->rqbd_list, &svcpt->scp_rqbd_posted);
 
 		spin_unlock(&svcpt->scp_lock);
 
@@ -325,8 +324,7 @@ void ptlrpc_dispatch_difficult_reply(struct ptlrpc_reply_state *rs)
 	spin_lock(&svcpt->scp_lock);
 
 	svcpt->scp_nrqbds_posted--;
-	list_del(&rqbd->rqbd_list);
-	list_add_tail(&rqbd->rqbd_list, &svcpt->scp_rqbd_idle);
+	list_move_tail(&rqbd->rqbd_list, &svcpt->scp_rqbd_idle);
 
 	/* Don't complain if no request buffers are posted right now; LNET
 	 * won't drop requests because we set the portal lazy!
@@ -769,9 +767,7 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 	refcount = --(rqbd->rqbd_refcount);
 	if (refcount == 0) {
 		/* request buffer is now idle: add to history */
-		list_del(&rqbd->rqbd_list);
-
-		list_add_tail(&rqbd->rqbd_list, &svcpt->scp_hist_rqbds);
+		list_move_tail(&rqbd->rqbd_list, &svcpt->scp_hist_rqbds);
 		svcpt->scp_hist_nrqbds++;
 
 		/* cull some history?
@@ -2416,8 +2412,7 @@ static void ptlrpc_svcpt_stop_threads(struct ptlrpc_service_part *svcpt)
 						  struct ptlrpc_thread,
 						  t_link)) != NULL) {
 		if (thread_is_stopped(thread)) {
-			list_del(&thread->t_link);
-			list_add(&thread->t_link, &zombie);
+			list_move(&thread->t_link, &zombie);
 			continue;
 		}
 		spin_unlock(&svcpt->scp_lock);
-- 
1.8.3.1
