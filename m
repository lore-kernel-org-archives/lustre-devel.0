From: NeilBrown <neilb@suse.com>
Date: Thu, 07 Feb 2019 11:03:33 +1100
Subject: [lustre-devel] [PATCH 08/21] lustre: use list_first_entry()
 throughout
In-Reply-To: <154949776249.10620.1215070753973826063.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
Message-ID: <154949781303.10620.10579175228046856433.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Convert
  list_entry(foo->next .....)
to
  list_first_entry(foo, ....)

in remainder of lustre.

In several cases the call is combined with a list_empty() test and
list_first_entry_or_null() is used

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |   12 +++--
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    5 +-
 drivers/staging/lustre/lnet/selftest/console.c     |   39 ++++++++----------
 drivers/staging/lustre/lnet/selftest/framework.c   |   44 ++++++++++----------
 drivers/staging/lustre/lnet/selftest/rpc.c         |   27 ++++++------
 drivers/staging/lustre/lnet/selftest/timer.c       |    4 +-
 6 files changed, 62 insertions(+), 69 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index 5fb85247525d..ae17b4d44cac 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -468,11 +468,11 @@ EXPORT_SYMBOL(cfs_expr_list_values);
 void
 cfs_expr_list_free(struct cfs_expr_list *expr_list)
 {
-	while (!list_empty(&expr_list->el_exprs)) {
-		struct cfs_range_expr *expr;
+	struct cfs_range_expr *expr;
 
-		expr = list_entry(expr_list->el_exprs.next,
-				  struct cfs_range_expr, re_link);
+	while ((expr = list_first_entry_or_null(&expr_list->el_exprs,
+						struct cfs_range_expr,
+						re_link)) != NULL) {
 		list_del(&expr->re_link);
 		kfree(expr);
 	}
@@ -553,8 +553,8 @@ cfs_expr_list_free_list(struct list_head *list)
 {
 	struct cfs_expr_list *el;
 
-	while (!list_empty(list)) {
-		el = list_entry(list->next, struct cfs_expr_list, el_link);
+	while ((el = list_first_entry_or_null(list, struct cfs_expr_list,
+					      el_link)) != NULL) {
 		list_del(&el->el_link);
 		cfs_expr_list_free(el);
 	}
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index d9bcfa8c92ae..af0d2aa3b6e8 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -1362,9 +1362,8 @@ lstcon_rpc_cleanup_wait(void)
 
 	spin_unlock(&console_session.ses_rpc_lock);
 
-	while (!list_empty(&zlist)) {
-		crpc = list_entry(zlist.next, struct lstcon_rpc, crp_link);
-
+	while ((crpc = list_first_entry_or_null(&zlist, struct lstcon_rpc,
+					       crp_link)) != NULL) {
 		list_del(&crpc->crp_link);
 		kfree(crpc);
 	}
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 045d79f44321..abc342c6a842 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -330,11 +330,10 @@ lstcon_group_move(struct lstcon_group *old, struct lstcon_group *new)
 {
 	struct lstcon_ndlink *ndl;
 
-	while (!list_empty(&old->grp_ndl_list)) {
-		ndl = list_entry(old->grp_ndl_list.next,
-				 struct lstcon_ndlink, ndl_link);
+	while ((ndl = list_first_entry_or_null(&old->grp_ndl_list,
+					       struct lstcon_ndlink,
+					       ndl_link)) != NULL)
 		lstcon_group_ndlink_move(old, new, ndl);
-	}
 }
 
 static int
@@ -1095,9 +1094,9 @@ lstcon_batch_destroy(struct lstcon_batch *bat)
 
 	list_del(&bat->bat_link);
 
-	while (!list_empty(&bat->bat_test_list)) {
-		test = list_entry(bat->bat_test_list.next,
-				  struct lstcon_test, tes_link);
+	while ((test = list_first_entry_or_null(&bat->bat_test_list,
+						struct lstcon_test,
+						tes_link)) != NULL) {
 		LASSERT(list_empty(&test->tes_trans_list));
 
 		list_del(&test->tes_link);
@@ -1110,17 +1109,17 @@ lstcon_batch_destroy(struct lstcon_batch *bat)
 
 	LASSERT(list_empty(&bat->bat_trans_list));
 
-	while (!list_empty(&bat->bat_cli_list)) {
-		ndl = list_entry(bat->bat_cli_list.next,
-				 struct lstcon_ndlink, ndl_link);
+	while ((ndl = list_first_entry_or_null(&bat->bat_cli_list,
+					       struct lstcon_ndlink,
+					       ndl_link)) != NULL) {
 		list_del_init(&ndl->ndl_link);
 
 		lstcon_ndlink_release(ndl);
 	}
 
-	while (!list_empty(&bat->bat_srv_list)) {
-		ndl = list_entry(bat->bat_srv_list.next,
-				 struct lstcon_ndlink, ndl_link);
+	while ((ndl = list_first_entry_or_null(&bat->bat_srv_list,
+					       struct lstcon_ndlink,
+					       ndl_link)) != NULL) {
 		list_del_init(&ndl->ndl_link);
 
 		lstcon_ndlink_release(ndl);
@@ -1844,17 +1843,15 @@ lstcon_session_end(void)
 	console_session.ses_feats_updated = 0;
 
 	/* destroy all batches */
-	while (!list_empty(&console_session.ses_bat_list)) {
-		bat = list_entry(console_session.ses_bat_list.next,
-				 struct lstcon_batch, bat_link);
-
+	while ((bat = list_first_entry_or_null(&console_session.ses_bat_list,
+					       struct lstcon_batch,
+					       bat_link)) != NULL)
 		lstcon_batch_destroy(bat);
-	}
 
 	/* destroy all groups */
-	while (!list_empty(&console_session.ses_grp_list)) {
-		grp = list_entry(console_session.ses_grp_list.next,
-				 struct lstcon_group, grp_link);
+	while ((grp = list_first_entry_or_null(&console_session.ses_grp_list,
+					       struct lstcon_group,
+					       grp_link)) != NULL) {
 		LASSERT(grp->grp_ref == 1);
 
 		lstcon_group_decref(grp);
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index a82efc394659..958f627580e7 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -628,16 +628,16 @@ sfw_destroy_test_instance(struct sfw_test_instance *tsi)
 	LASSERT(list_empty(&tsi->tsi_active_rpcs));
 	LASSERT(!sfw_test_active(tsi));
 
-	while (!list_empty(&tsi->tsi_units)) {
-		tsu = list_entry(tsi->tsi_units.next,
-				 struct sfw_test_unit, tsu_list);
+	while ((tsu = list_first_entry_or_null(&tsi->tsi_units,
+					       struct sfw_test_unit,
+					       tsu_list)) != NULL) {
 		list_del(&tsu->tsu_list);
 		kfree(tsu);
 	}
 
-	while (!list_empty(&tsi->tsi_free_rpcs)) {
-		rpc = list_entry(tsi->tsi_free_rpcs.next,
-				 struct srpc_client_rpc, crpc_list);
+	while ((rpc = list_first_entry_or_null(&tsi->tsi_free_rpcs,
+					       struct srpc_client_rpc,
+					       crpc_list)) != NULL) {
 		list_del(&rpc->crpc_list);
 		kfree(rpc);
 	}
@@ -655,9 +655,9 @@ sfw_destroy_batch(struct sfw_batch *tsb)
 	LASSERT(!sfw_batch_active(tsb));
 	LASSERT(list_empty(&tsb->bat_list));
 
-	while (!list_empty(&tsb->bat_tests)) {
-		tsi = list_entry(tsb->bat_tests.next,
-				 struct sfw_test_instance, tsi_list);
+	while ((tsi = list_first_entry_or_null(&tsb->bat_tests,
+					       struct sfw_test_instance,
+					       tsi_list)) != NULL) {
 		list_del_init(&tsi->tsi_list);
 		sfw_destroy_test_instance(tsi);
 	}
@@ -673,9 +673,9 @@ sfw_destroy_session(struct sfw_session *sn)
 	LASSERT(list_empty(&sn->sn_list));
 	LASSERT(sn != sfw_data.fw_session);
 
-	while (!list_empty(&sn->sn_batches)) {
-		batch = list_entry(sn->sn_batches.next,
-				   struct sfw_batch, bat_list);
+	while ((batch = list_first_entry_or_null(&sn->sn_batches,
+						 struct sfw_batch,
+						 bat_list)) != NULL) {
 		list_del_init(&batch->bat_list);
 		sfw_destroy_batch(batch);
 	}
@@ -1389,8 +1389,8 @@ sfw_create_rpc(struct lnet_process_id peer, int service,
 	LASSERT(service <= SRPC_FRAMEWORK_SERVICE_MAX_ID);
 
 	if (!nbulkiov && !list_empty(&sfw_data.fw_zombie_rpcs)) {
-		rpc = list_entry(sfw_data.fw_zombie_rpcs.next,
-				 struct srpc_client_rpc, crpc_list);
+		rpc = list_first_entry(&sfw_data.fw_zombie_rpcs,
+				       struct srpc_client_rpc, crpc_list);
 		list_del(&rpc->crpc_list);
 
 		srpc_init_client_rpc(rpc, peer, service, 0, 0,
@@ -1722,6 +1722,7 @@ sfw_shutdown(void)
 {
 	struct srpc_service *sv;
 	struct sfw_test_case	*tsc;
+	struct srpc_client_rpc *rpc;
 	int i;
 
 	spin_lock(&sfw_data.fw_lock);
@@ -1757,11 +1758,9 @@ sfw_shutdown(void)
 		srpc_remove_service(sv);
 	}
 
-	while (!list_empty(&sfw_data.fw_zombie_rpcs)) {
-		struct srpc_client_rpc *rpc;
-
-		rpc = list_entry(sfw_data.fw_zombie_rpcs.next,
-				 struct srpc_client_rpc, crpc_list);
+	while ((rpc = list_first_entry_or_null(&sfw_data.fw_zombie_rpcs,
+					       struct srpc_client_rpc,
+					       crpc_list)) != NULL) {
 		list_del(&rpc->crpc_list);
 
 		kfree(rpc);
@@ -1775,10 +1774,9 @@ sfw_shutdown(void)
 		srpc_wait_service_shutdown(sv);
 	}
 
-	while (!list_empty(&sfw_data.fw_tests)) {
-		tsc = list_entry(sfw_data.fw_tests.next,
-				 struct sfw_test_case, tsc_list);
-
+	while ((tsc = list_first_entry_or_null(&sfw_data.fw_tests,
+					       struct sfw_test_case,
+					       tsc_list)) != NULL) {
 		srpc_wait_service_shutdown(tsc->tsc_srv_service);
 
 		list_del(&tsc->tsc_list);
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 2a3010774dbe..abb6f8fb011e 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -210,9 +210,9 @@ srpc_service_fini(struct srpc_service *svc)
 			else
 				break;
 
-			while (!list_empty(q)) {
-				buf = list_entry(q->next, struct srpc_buffer,
-						 buf_list);
+			while ((buf = list_first_entry_or_null(
+					q, struct srpc_buffer,
+					buf_list)) != NULL) {
 				list_del(&buf->buf_list);
 				kfree(buf);
 			}
@@ -220,10 +220,9 @@ srpc_service_fini(struct srpc_service *svc)
 
 		LASSERT(list_empty(&scd->scd_rpc_active));
 
-		while (!list_empty(&scd->scd_rpc_free)) {
-			rpc = list_entry(scd->scd_rpc_free.next,
-					 struct srpc_server_rpc,
-					 srpc_list);
+		while ((rpc = list_first_entry_or_null(&scd->scd_rpc_free,
+						       struct srpc_server_rpc,
+						       srpc_list)) != NULL) {
 			list_del(&rpc->srpc_list);
 			kfree(rpc);
 		}
@@ -674,8 +673,8 @@ srpc_finish_service(struct srpc_service *sv)
 			continue;
 		}
 
-		rpc = list_entry(scd->scd_rpc_active.next,
-				 struct srpc_server_rpc, srpc_list);
+		rpc = list_first_entry(&scd->scd_rpc_active,
+				       struct srpc_server_rpc, srpc_list);
 		CNETERR("Active RPC %p on shutdown: sv %s, peer %s, wi %s, ev fired %d type %d status %d lnet %d\n",
 			rpc, sv->sv_name, libcfs_id2str(rpc->srpc_peer),
 			swi_state2str(rpc->srpc_wi.swi_state),
@@ -943,8 +942,8 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 	LASSERT(rpc->srpc_ev.ev_fired);
 
 	if (!sv->sv_shuttingdown && !list_empty(&scd->scd_buf_blocked)) {
-		buffer = list_entry(scd->scd_buf_blocked.next,
-				    struct srpc_buffer, buf_list);
+		buffer = list_first_entry(&scd->scd_buf_blocked,
+					  struct srpc_buffer, buf_list);
 		list_del(&buffer->buf_list);
 
 		srpc_init_server_rpc(rpc, scd, buffer);
@@ -1535,9 +1534,9 @@ srpc_lnet_ev_handler(struct lnet_event *ev)
 		}
 
 		if (!list_empty(&scd->scd_rpc_free)) {
-			srpc = list_entry(scd->scd_rpc_free.next,
-					  struct srpc_server_rpc,
-					  srpc_list);
+			srpc = list_first_entry(&scd->scd_rpc_free,
+						struct srpc_server_rpc,
+						srpc_list);
 			list_del(&srpc->srpc_list);
 
 			srpc_init_server_rpc(srpc, scd, buffer);
diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
index c83473ebb368..bb61e3aa11e9 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.c
+++ b/drivers/staging/lustre/lnet/selftest/timer.c
@@ -125,8 +125,8 @@ stt_expire_list(struct list_head *slot, time64_t now)
 	int expired = 0;
 	struct stt_timer *timer;
 
-	while (!list_empty(slot)) {
-		timer = list_entry(slot->next, struct stt_timer, stt_list);
+	while ((timer = list_first_entry_or_null(slot, struct stt_timer,
+						 stt_list)) != NULL) {
 
 		if (timer->stt_expires > now)
 			break;
