From: James Simmons <jsimmons@infradead.org>
Date: Tue, 12 Apr 2016 12:16:02 -0400
Subject: [lustre-devel] [PATCH v2 2/2] staging: lustre: selftest: convert
	wire protocol to use struct
In-Reply-To: <1460477762-14167-1-git-send-email-jsimmons@infradead.org>
References: <1460477762-14167-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460477762-14167-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Change all the wire protocol typedefs to proper structures

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c  |   22 ++--
 drivers/staging/lustre/lnet/selftest/conrpc.c    |   44 +++---
 drivers/staging/lustre/lnet/selftest/console.c   |   10 +-
 drivers/staging/lustre/lnet/selftest/framework.c |   54 ++++----
 drivers/staging/lustre/lnet/selftest/ping_test.c |   10 +-
 drivers/staging/lustre/lnet/selftest/rpc.c       |    6 +-
 drivers/staging/lustre/lnet/selftest/rpc.h       |  150 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/selftest.h  |   13 +-
 8 files changed, 155 insertions(+), 154 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 7f539f9..a63d86c 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -81,7 +81,7 @@ brw_client_init(struct sfw_test_instance *tsi)
 	LASSERT(tsi->tsi_is_client);
 
 	if (!(sn->sn_features & LST_FEAT_BULK_LEN)) {
-		test_bulk_req_t *breq = &tsi->tsi_u.bulk_v0;
+		struct test_bulk_req *breq = &tsi->tsi_u.bulk_v0;
 
 		opc = breq->blk_opc;
 		flags = breq->blk_flags;
@@ -92,7 +92,7 @@ brw_client_init(struct sfw_test_instance *tsi)
 		 */
 		len = npg * PAGE_SIZE;
 	} else {
-		test_bulk_req_v1_t *breq = &tsi->tsi_u.bulk_v1;
+		struct test_bulk_req_v1 *breq = &tsi->tsi_u.bulk_v1;
 
 		/*
 		 * I should never get this step if it's unknown feature
@@ -261,7 +261,7 @@ brw_client_prep_rpc(struct sfw_test_unit *tsu,
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	struct srpc_client_rpc *rpc;
-	srpc_brw_reqst_t *req;
+	struct srpc_brw_reqst *req;
 	int flags;
 	int npg;
 	int len;
@@ -272,14 +272,14 @@ brw_client_prep_rpc(struct sfw_test_unit *tsu,
 	LASSERT(bulk);
 
 	if (!(sn->sn_features & LST_FEAT_BULK_LEN)) {
-		test_bulk_req_t *breq = &tsi->tsi_u.bulk_v0;
+		struct test_bulk_req *breq = &tsi->tsi_u.bulk_v0;
 
 		opc = breq->blk_opc;
 		flags = breq->blk_flags;
 		npg = breq->blk_npg;
 		len = npg * PAGE_SIZE;
 	} else {
-		test_bulk_req_v1_t *breq = &tsi->tsi_u.bulk_v1;
+		struct test_bulk_req_v1 *breq = &tsi->tsi_u.bulk_v1;
 
 		/*
 		 * I should never get this step if it's unknown feature
@@ -319,8 +319,8 @@ brw_client_done_rpc(struct sfw_test_unit *tsu, struct srpc_client_rpc *rpc)
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	struct srpc_msg *msg = &rpc->crpc_replymsg;
-	srpc_brw_reply_t *reply = &msg->msg_body.brw_reply;
-	srpc_brw_reqst_t *reqst = &rpc->crpc_reqstmsg.msg_body.brw_reqst;
+	struct srpc_brw_reply *reply = &msg->msg_body.brw_reply;
+	struct srpc_brw_reqst *reqst = &rpc->crpc_reqstmsg.msg_body.brw_reqst;
 
 	LASSERT(sn);
 
@@ -382,8 +382,8 @@ static int
 brw_bulk_ready(struct srpc_server_rpc *rpc, int status)
 {
 	__u64 magic = BRW_MAGIC;
-	srpc_brw_reply_t *reply = &rpc->srpc_replymsg.msg_body.brw_reply;
-	srpc_brw_reqst_t *reqst;
+	struct srpc_brw_reply *reply = &rpc->srpc_replymsg.msg_body.brw_reply;
+	struct srpc_brw_reqst *reqst;
 	struct srpc_msg *reqstmsg;
 
 	LASSERT(rpc->srpc_bulk);
@@ -420,8 +420,8 @@ brw_server_handle(struct srpc_server_rpc *rpc)
 	struct srpc_service *sv = rpc->srpc_scd->scd_svc;
 	struct srpc_msg *replymsg = &rpc->srpc_replymsg;
 	struct srpc_msg *reqstmsg = &rpc->srpc_reqstbuf->buf_msg;
-	srpc_brw_reply_t *reply = &replymsg->msg_body.brw_reply;
-	srpc_brw_reqst_t *reqst = &reqstmsg->msg_body.brw_reqst;
+	struct srpc_brw_reply *reply = &replymsg->msg_body.brw_reply;
+	struct srpc_brw_reqst *reqst = &reqstmsg->msg_body.brw_reqst;
 	int npg;
 	int rc;
 
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index bc96ef8..6f68758 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -390,7 +390,7 @@ lstcon_rpc_get_reply(struct lstcon_rpc *crpc, struct srpc_msg **msgpp)
 {
 	struct lstcon_node *nd = crpc->crp_node;
 	struct srpc_client_rpc *rpc = crpc->crp_rpc;
-	srpc_generic_reply_t *rep;
+	struct srpc_generic_reply *rep;
 
 	LASSERT(nd && rpc);
 	LASSERT(crpc->crp_stamp);
@@ -473,7 +473,7 @@ lstcon_rpc_trans_interpreter(struct lstcon_rpc_trans *trans,
 	struct list_head tmp;
 	struct list_head __user *next;
 	lstcon_rpc_ent_t *ent;
-	srpc_generic_reply_t *rep;
+	struct srpc_generic_reply *rep;
 	struct lstcon_rpc *crpc;
 	struct srpc_msg *msg;
 	struct lstcon_node *nd;
@@ -520,7 +520,7 @@ lstcon_rpc_trans_interpreter(struct lstcon_rpc_trans *trans,
 			continue;
 
 		/* RPC is done */
-		rep = (srpc_generic_reply_t *)&msg->msg_body.reply;
+		rep = (struct srpc_generic_reply *)&msg->msg_body.reply;
 
 		if (copy_to_user(&ent->rpe_sid, &rep->sid, sizeof(lst_sid_t)) ||
 		    copy_to_user(&ent->rpe_fwk_errno, &rep->status,
@@ -595,8 +595,8 @@ int
 lstcon_sesrpc_prep(struct lstcon_node *nd, int transop,
 		   unsigned feats, struct lstcon_rpc **crpc)
 {
-	srpc_mksn_reqst_t *msrq;
-	srpc_rmsn_reqst_t *rsrq;
+	struct srpc_mksn_reqst *msrq;
+	struct srpc_rmsn_reqst *rsrq;
 	int rc;
 
 	switch (transop) {
@@ -633,7 +633,7 @@ lstcon_sesrpc_prep(struct lstcon_node *nd, int transop,
 int
 lstcon_dbgrpc_prep(struct lstcon_node *nd, unsigned feats, struct lstcon_rpc **crpc)
 {
-	srpc_debug_reqst_t *drq;
+	struct srpc_debug_reqst *drq;
 	int rc;
 
 	rc = lstcon_rpc_prep(nd, SRPC_SERVICE_DEBUG, feats, 0, 0, crpc);
@@ -653,7 +653,7 @@ lstcon_batrpc_prep(struct lstcon_node *nd, int transop, unsigned feats,
 		   struct lstcon_tsb_hdr *tsb, struct lstcon_rpc **crpc)
 {
 	struct lstcon_batch *batch;
-	srpc_batch_reqst_t *brq;
+	struct srpc_batch_reqst *brq;
 	int rc;
 
 	rc = lstcon_rpc_prep(nd, SRPC_SERVICE_BATCH, feats, 0, 0, crpc);
@@ -684,7 +684,7 @@ lstcon_batrpc_prep(struct lstcon_node *nd, int transop, unsigned feats,
 int
 lstcon_statrpc_prep(struct lstcon_node *nd, unsigned feats, struct lstcon_rpc **crpc)
 {
-	srpc_stat_reqst_t *srq;
+	struct srpc_stat_reqst *srq;
 	int rc;
 
 	rc = lstcon_rpc_prep(nd, SRPC_SERVICE_QUERY_STAT, feats, 0, 0, crpc);
@@ -769,9 +769,9 @@ lstcon_dstnodes_prep(struct lstcon_group *grp, int idx,
 }
 
 static int
-lstcon_pingrpc_prep(lst_test_ping_param_t *param, srpc_test_reqst_t *req)
+lstcon_pingrpc_prep(lst_test_ping_param_t *param, struct srpc_test_reqst *req)
 {
-	test_ping_req_t *prq = &req->tsr_u.ping;
+	struct test_ping_req *prq = &req->tsr_u.ping;
 
 	prq->png_size = param->png_size;
 	prq->png_flags = param->png_flags;
@@ -780,9 +780,9 @@ lstcon_pingrpc_prep(lst_test_ping_param_t *param, srpc_test_reqst_t *req)
 }
 
 static int
-lstcon_bulkrpc_v0_prep(lst_test_bulk_param_t *param, srpc_test_reqst_t *req)
+lstcon_bulkrpc_v0_prep(lst_test_bulk_param_t *param, struct srpc_test_reqst *req)
 {
-	test_bulk_req_t *brq = &req->tsr_u.bulk_v0;
+	struct test_bulk_req *brq = &req->tsr_u.bulk_v0;
 
 	brq->blk_opc = param->blk_opc;
 	brq->blk_npg = (param->blk_size + PAGE_SIZE - 1) /
@@ -793,9 +793,9 @@ lstcon_bulkrpc_v0_prep(lst_test_bulk_param_t *param, srpc_test_reqst_t *req)
 }
 
 static int
-lstcon_bulkrpc_v1_prep(lst_test_bulk_param_t *param, srpc_test_reqst_t *req)
+lstcon_bulkrpc_v1_prep(lst_test_bulk_param_t *param, struct srpc_test_reqst *req)
 {
-	test_bulk_req_v1_t *brq = &req->tsr_u.bulk_v1;
+	struct test_bulk_req_v1 *brq = &req->tsr_u.bulk_v1;
 
 	brq->blk_opc = param->blk_opc;
 	brq->blk_flags = param->blk_flags;
@@ -811,7 +811,7 @@ lstcon_testrpc_prep(struct lstcon_node *nd, int transop, unsigned feats,
 {
 	struct lstcon_group *sgrp = test->tes_src_grp;
 	struct lstcon_group *dgrp = test->tes_dst_grp;
-	srpc_test_reqst_t *trq;
+	struct srpc_test_reqst *trq;
 	struct srpc_bulk *bulk;
 	int i;
 	int npg = 0;
@@ -918,7 +918,7 @@ static int
 lstcon_sesnew_stat_reply(struct lstcon_rpc_trans *trans,
 			 struct lstcon_node *nd, struct srpc_msg *reply)
 {
-	srpc_mksn_reply_t *mksn_rep = &reply->msg_body.mksn_reply;
+	struct srpc_mksn_reply *mksn_rep = &reply->msg_body.mksn_reply;
 	int status = mksn_rep->mksn_status;
 
 	if (!status &&
@@ -965,11 +965,11 @@ void
 lstcon_rpc_stat_reply(struct lstcon_rpc_trans *trans, struct srpc_msg *msg,
 		      struct lstcon_node *nd, lstcon_trans_stat_t *stat)
 {
-	srpc_rmsn_reply_t *rmsn_rep;
-	srpc_debug_reply_t *dbg_rep;
-	srpc_batch_reply_t *bat_rep;
-	srpc_test_reply_t *test_rep;
-	srpc_stat_reply_t *stat_rep;
+	struct srpc_rmsn_reply *rmsn_rep;
+	struct srpc_debug_reply *dbg_rep;
+	struct srpc_batch_reply *bat_rep;
+	struct srpc_test_reply *test_rep;
+	struct srpc_stat_reply *stat_rep;
 	int rc = 0;
 
 	switch (trans->tas_opc) {
@@ -1173,7 +1173,7 @@ lstcon_rpc_pinger(void *arg)
 	struct lstcon_rpc_trans *trans;
 	struct lstcon_rpc *crpc;
 	struct srpc_msg *rep;
-	srpc_debug_reqst_t *drq;
+	struct srpc_debug_reqst *drq;
 	struct lstcon_ndlink *ndl;
 	struct lstcon_node *nd;
 	int intv;
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 6568e8e..a03e52d 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -373,7 +373,7 @@ static int
 lstcon_sesrpc_readent(int transop, struct srpc_msg *msg,
 		      lstcon_rpc_ent_t __user *ent_up)
 {
-	srpc_debug_reply_t *rep;
+	struct srpc_debug_reply *rep;
 
 	switch (transop) {
 	case LST_TRANS_SESNEW:
@@ -1386,7 +1386,7 @@ static int
 lstcon_tsbrpc_readent(int transop, struct srpc_msg *msg,
 		      lstcon_rpc_ent_t __user *ent_up)
 {
-	srpc_batch_reply_t *rep = &msg->msg_body.bat_reply;
+	struct srpc_batch_reply *rep = &msg->msg_body.bat_reply;
 
 	LASSERT(transop == LST_TRANS_TSBCLIQRY ||
 		transop == LST_TRANS_TSBSRVQRY);
@@ -1465,7 +1465,7 @@ static int
 lstcon_statrpc_readent(int transop, struct srpc_msg *msg,
 		       lstcon_rpc_ent_t __user *ent_up)
 {
-	srpc_stat_reply_t *rep = &msg->msg_body.stat_reply;
+	struct srpc_stat_reply *rep = &msg->msg_body.stat_reply;
 	sfw_counters_t __user *sfwk_stat;
 	srpc_counters_t __user *srpc_stat;
 	lnet_counters_t __user *lnet_stat;
@@ -1907,8 +1907,8 @@ lstcon_acceptor_handle(struct srpc_server_rpc *rpc)
 {
 	struct srpc_msg *rep	= &rpc->srpc_replymsg;
 	struct srpc_msg *req	= &rpc->srpc_reqstbuf->buf_msg;
-	srpc_join_reqst_t *jreq = &req->msg_body.join_reqst;
-	srpc_join_reply_t *jrep = &rep->msg_body.join_reply;
+	struct srpc_join_reqst *jreq = &req->msg_body.join_reqst;
+	struct srpc_join_reply *jrep = &rep->msg_body.join_reply;
 	struct lstcon_group *grp = NULL;
 	struct lstcon_ndlink *ndl;
 	int rc = 0;
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index ef3cc82..30e4f71 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -361,7 +361,7 @@ sfw_bid2batch(lst_bid_t bid)
 }
 
 static int
-sfw_get_stats(srpc_stat_reqst_t *request, srpc_stat_reply_t *reply)
+sfw_get_stats(struct srpc_stat_reqst *request, struct srpc_stat_reply *reply)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
 	sfw_counters_t *cnt = &reply->str_fw;
@@ -402,7 +402,7 @@ sfw_get_stats(srpc_stat_reqst_t *request, srpc_stat_reply_t *reply)
 }
 
 int
-sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
+sfw_make_session(struct srpc_mksn_reqst *request, struct srpc_mksn_reply *reply)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
 	struct srpc_msg *msg = container_of(request, struct srpc_msg,
@@ -473,7 +473,7 @@ sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
 }
 
 static int
-sfw_remove_session(srpc_rmsn_reqst_t *request, srpc_rmsn_reply_t *reply)
+sfw_remove_session(struct srpc_rmsn_reqst *request, struct srpc_rmsn_reply *reply)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
 
@@ -505,7 +505,7 @@ sfw_remove_session(srpc_rmsn_reqst_t *request, srpc_rmsn_reply_t *reply)
 }
 
 static int
-sfw_debug_session(srpc_debug_reqst_t *request, srpc_debug_reply_t *reply)
+sfw_debug_session(struct srpc_debug_reqst *request, struct srpc_debug_reply *reply)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
 
@@ -687,7 +687,7 @@ sfw_destroy_session(struct sfw_session *sn)
 static void
 sfw_unpack_addtest_req(struct srpc_msg *msg)
 {
-	srpc_test_reqst_t *req = &msg->msg_body.tes_reqst;
+	struct srpc_test_reqst *req = &msg->msg_body.tes_reqst;
 
 	LASSERT(msg->msg_type == SRPC_MSG_TEST_REQST);
 	LASSERT(req->tsr_is_client);
@@ -699,14 +699,14 @@ sfw_unpack_addtest_req(struct srpc_msg *msg)
 
 	if (req->tsr_service == SRPC_SERVICE_BRW) {
 		if (!(msg->msg_ses_feats & LST_FEAT_BULK_LEN)) {
-			test_bulk_req_t *bulk = &req->tsr_u.bulk_v0;
+			struct test_bulk_req *bulk = &req->tsr_u.bulk_v0;
 
 			__swab32s(&bulk->blk_opc);
 			__swab32s(&bulk->blk_npg);
 			__swab32s(&bulk->blk_flags);
 
 		} else {
-			test_bulk_req_v1_t *bulk = &req->tsr_u.bulk_v1;
+			struct test_bulk_req_v1 *bulk = &req->tsr_u.bulk_v1;
 
 			__swab16s(&bulk->blk_opc);
 			__swab16s(&bulk->blk_flags);
@@ -718,7 +718,7 @@ sfw_unpack_addtest_req(struct srpc_msg *msg)
 	}
 
 	if (req->tsr_service == SRPC_SERVICE_PING) {
-		test_ping_req_t *ping = &req->tsr_u.ping;
+		struct test_ping_req *ping = &req->tsr_u.ping;
 
 		__swab32s(&ping->png_size);
 		__swab32s(&ping->png_flags);
@@ -732,7 +732,7 @@ static int
 sfw_add_test_instance(struct sfw_batch *tsb, struct srpc_server_rpc *rpc)
 {
 	struct srpc_msg *msg = &rpc->srpc_reqstbuf->buf_msg;
-	srpc_test_reqst_t *req = &msg->msg_body.tes_reqst;
+	struct srpc_test_reqst *req = &msg->msg_body.tes_reqst;
 	struct srpc_bulk *bk = rpc->srpc_bulk;
 	int ndest = req->tsr_ndest;
 	struct sfw_test_unit *tsu;
@@ -1068,7 +1068,7 @@ sfw_stop_batch(struct sfw_batch *tsb, int force)
 }
 
 static int
-sfw_query_batch(struct sfw_batch *tsb, int testidx, srpc_batch_reply_t *reply)
+sfw_query_batch(struct sfw_batch *tsb, int testidx, struct srpc_batch_reply *reply)
 {
 	struct sfw_test_instance *tsi;
 
@@ -1116,8 +1116,8 @@ static int
 sfw_add_test(struct srpc_server_rpc *rpc)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
-	srpc_test_reply_t *reply = &rpc->srpc_replymsg.msg_body.tes_reply;
-	srpc_test_reqst_t *request;
+	struct srpc_test_reply *reply = &rpc->srpc_replymsg.msg_body.tes_reply;
+	struct srpc_test_reqst *request;
 	int rc;
 	struct sfw_batch *bat;
 
@@ -1183,7 +1183,7 @@ sfw_add_test(struct srpc_server_rpc *rpc)
 }
 
 static int
-sfw_control_batch(srpc_batch_reqst_t *request, srpc_batch_reply_t *reply)
+sfw_control_batch(struct srpc_batch_reqst *request, struct srpc_batch_reply *reply)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
 	int rc = 0;
@@ -1424,7 +1424,7 @@ sfw_unpack_message(struct srpc_msg *msg)
 	LASSERT(msg->msg_magic == __swab32(SRPC_MSG_MAGIC));
 
 	if (msg->msg_type == SRPC_MSG_STAT_REQST) {
-		srpc_stat_reqst_t *req = &msg->msg_body.stat_reqst;
+		struct srpc_stat_reqst *req = &msg->msg_body.stat_reqst;
 
 		__swab32s(&req->str_type);
 		__swab64s(&req->str_rpyid);
@@ -1433,7 +1433,7 @@ sfw_unpack_message(struct srpc_msg *msg)
 	}
 
 	if (msg->msg_type == SRPC_MSG_STAT_REPLY) {
-		srpc_stat_reply_t *rep = &msg->msg_body.stat_reply;
+		struct srpc_stat_reply *rep = &msg->msg_body.stat_reply;
 
 		__swab32s(&rep->str_status);
 		sfw_unpack_sid(rep->str_sid);
@@ -1444,7 +1444,7 @@ sfw_unpack_message(struct srpc_msg *msg)
 	}
 
 	if (msg->msg_type == SRPC_MSG_MKSN_REQST) {
-		srpc_mksn_reqst_t *req = &msg->msg_body.mksn_reqst;
+		struct srpc_mksn_reqst *req = &msg->msg_body.mksn_reqst;
 
 		__swab64s(&req->mksn_rpyid);
 		__swab32s(&req->mksn_force);
@@ -1453,7 +1453,7 @@ sfw_unpack_message(struct srpc_msg *msg)
 	}
 
 	if (msg->msg_type == SRPC_MSG_MKSN_REPLY) {
-		srpc_mksn_reply_t *rep = &msg->msg_body.mksn_reply;
+		struct srpc_mksn_reply *rep = &msg->msg_body.mksn_reply;
 
 		__swab32s(&rep->mksn_status);
 		__swab32s(&rep->mksn_timeout);
@@ -1462,7 +1462,7 @@ sfw_unpack_message(struct srpc_msg *msg)
 	}
 
 	if (msg->msg_type == SRPC_MSG_RMSN_REQST) {
-		srpc_rmsn_reqst_t *req = &msg->msg_body.rmsn_reqst;
+		struct srpc_rmsn_reqst *req = &msg->msg_body.rmsn_reqst;
 
 		__swab64s(&req->rmsn_rpyid);
 		sfw_unpack_sid(req->rmsn_sid);
@@ -1470,7 +1470,7 @@ sfw_unpack_message(struct srpc_msg *msg)
 	}
 
 	if (msg->msg_type == SRPC_MSG_RMSN_REPLY) {
-		srpc_rmsn_reply_t *rep = &msg->msg_body.rmsn_reply;
+		struct srpc_rmsn_reply *rep = &msg->msg_body.rmsn_reply;
 
 		__swab32s(&rep->rmsn_status);
 		sfw_unpack_sid(rep->rmsn_sid);
@@ -1478,7 +1478,7 @@ sfw_unpack_message(struct srpc_msg *msg)
 	}
 
 	if (msg->msg_type == SRPC_MSG_DEBUG_REQST) {
-		srpc_debug_reqst_t *req = &msg->msg_body.dbg_reqst;
+		struct srpc_debug_reqst *req = &msg->msg_body.dbg_reqst;
 
 		__swab64s(&req->dbg_rpyid);
 		__swab32s(&req->dbg_flags);
@@ -1487,7 +1487,7 @@ sfw_unpack_message(struct srpc_msg *msg)
 	}
 
 	if (msg->msg_type == SRPC_MSG_DEBUG_REPLY) {
-		srpc_debug_reply_t *rep = &msg->msg_body.dbg_reply;
+		struct srpc_debug_reply *rep = &msg->msg_body.dbg_reply;
 
 		__swab32s(&rep->dbg_nbatch);
 		__swab32s(&rep->dbg_timeout);
@@ -1496,7 +1496,7 @@ sfw_unpack_message(struct srpc_msg *msg)
 	}
 
 	if (msg->msg_type == SRPC_MSG_BATCH_REQST) {
-		srpc_batch_reqst_t *req = &msg->msg_body.bat_reqst;
+		struct srpc_batch_reqst *req = &msg->msg_body.bat_reqst;
 
 		__swab32s(&req->bar_opc);
 		__swab64s(&req->bar_rpyid);
@@ -1508,7 +1508,7 @@ sfw_unpack_message(struct srpc_msg *msg)
 	}
 
 	if (msg->msg_type == SRPC_MSG_BATCH_REPLY) {
-		srpc_batch_reply_t *rep = &msg->msg_body.bat_reply;
+		struct srpc_batch_reply *rep = &msg->msg_body.bat_reply;
 
 		__swab32s(&rep->bar_status);
 		sfw_unpack_sid(rep->bar_sid);
@@ -1516,7 +1516,7 @@ sfw_unpack_message(struct srpc_msg *msg)
 	}
 
 	if (msg->msg_type == SRPC_MSG_TEST_REQST) {
-		srpc_test_reqst_t *req = &msg->msg_body.tes_reqst;
+		struct srpc_test_reqst *req = &msg->msg_body.tes_reqst;
 
 		__swab64s(&req->tsr_rpyid);
 		__swab64s(&req->tsr_bulkid);
@@ -1530,7 +1530,7 @@ sfw_unpack_message(struct srpc_msg *msg)
 	}
 
 	if (msg->msg_type == SRPC_MSG_TEST_REPLY) {
-		srpc_test_reply_t *rep = &msg->msg_body.tes_reply;
+		struct srpc_test_reply *rep = &msg->msg_body.tes_reply;
 
 		__swab32s(&rep->tsr_status);
 		sfw_unpack_sid(rep->tsr_sid);
@@ -1538,7 +1538,7 @@ sfw_unpack_message(struct srpc_msg *msg)
 	}
 
 	if (msg->msg_type == SRPC_MSG_JOIN_REQST) {
-		srpc_join_reqst_t *req = &msg->msg_body.join_reqst;
+		struct srpc_join_reqst *req = &msg->msg_body.join_reqst;
 
 		__swab64s(&req->join_rpyid);
 		sfw_unpack_sid(req->join_sid);
@@ -1546,7 +1546,7 @@ sfw_unpack_message(struct srpc_msg *msg)
 	}
 
 	if (msg->msg_type == SRPC_MSG_JOIN_REPLY) {
-		srpc_join_reply_t *rep = &msg->msg_body.join_reply;
+		struct srpc_join_reply *rep = &msg->msg_body.join_reply;
 
 		__swab32s(&rep->join_status);
 		__swab32s(&rep->join_timeout);
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index 8a9d7a4..ad26fe9 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -89,7 +89,7 @@ static int
 ping_client_prep_rpc(struct sfw_test_unit *tsu, lnet_process_id_t dest,
 		     struct srpc_client_rpc **rpc)
 {
-	srpc_ping_reqst_t *req;
+	struct srpc_ping_reqst *req;
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	struct timespec64 ts;
@@ -122,8 +122,8 @@ ping_client_done_rpc(struct sfw_test_unit *tsu, struct srpc_client_rpc *rpc)
 {
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct sfw_session *sn = tsi->tsi_batch->bat_session;
-	srpc_ping_reqst_t *reqst = &rpc->crpc_reqstmsg.msg_body.ping_reqst;
-	srpc_ping_reply_t *reply = &rpc->crpc_replymsg.msg_body.ping_reply;
+	struct srpc_ping_reqst *reqst = &rpc->crpc_reqstmsg.msg_body.ping_reqst;
+	struct srpc_ping_reply *reply = &rpc->crpc_replymsg.msg_body.ping_reply;
 	struct timespec64 ts;
 
 	LASSERT(sn);
@@ -173,8 +173,8 @@ ping_server_handle(struct srpc_server_rpc *rpc)
 	struct srpc_service *sv = rpc->srpc_scd->scd_svc;
 	struct srpc_msg *reqstmsg = &rpc->srpc_reqstbuf->buf_msg;
 	struct srpc_msg *replymsg = &rpc->srpc_replymsg;
-	srpc_ping_reqst_t *req = &reqstmsg->msg_body.ping_reqst;
-	srpc_ping_reply_t *rep = &rpc->srpc_replymsg.msg_body.ping_reply;
+	struct srpc_ping_reqst *req = &reqstmsg->msg_body.ping_reqst;
+	struct srpc_ping_reply *rep = &rpc->srpc_replymsg.msg_body.ping_reply;
 
 	LASSERT(sv->sv_id == SRPC_SERVICE_PING);
 
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 561e28c..3c45a7c 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -997,7 +997,7 @@ srpc_handle_rpc(struct swi_workitem *wi)
 		LBUG();
 	case SWI_STATE_NEWBORN: {
 		struct srpc_msg *msg;
-		srpc_generic_reply_t *reply;
+		struct srpc_generic_reply *reply;
 
 		msg = &rpc->srpc_reqstbuf->buf_msg;
 		reply = &rpc->srpc_replymsg.msg_body.reply;
@@ -1238,7 +1238,7 @@ srpc_send_rpc(struct swi_workitem *wi)
 		wi->swi_state = SWI_STATE_REQUEST_SENT;
 		/* perhaps more events, fall thru */
 	case SWI_STATE_REQUEST_SENT: {
-		srpc_msg_type_t type = srpc_service2reply(rpc->crpc_service);
+		enum srpc_msg_type type = srpc_service2reply(rpc->crpc_service);
 
 		if (!rpc->crpc_replyev.ev_fired)
 			break;
@@ -1417,7 +1417,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 	struct srpc_buffer *buffer;
 	struct srpc_service *sv;
 	struct srpc_msg *msg;
-	srpc_msg_type_t type;
+	enum srpc_msg_type type;
 
 	LASSERT(!in_interrupt());
 
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index fdf881f..c9b904c 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -44,7 +44,7 @@
  *
  * XXX: *REPLY == *REQST + 1
  */
-typedef enum {
+enum srpc_msg_type {
 	SRPC_MSG_MKSN_REQST	= 0,
 	SRPC_MSG_MKSN_REPLY	= 1,
 	SRPC_MSG_RMSN_REQST	= 2,
@@ -63,7 +63,7 @@ typedef enum {
 	SRPC_MSG_PING_REPLY	= 15,
 	SRPC_MSG_JOIN_REQST	= 16,
 	SRPC_MSG_JOIN_REPLY	= 17,
-} srpc_msg_type_t;
+};
 
 /* CAVEAT EMPTOR:
  * All srpc_*_reqst_t's 1st field must be matchbits of reply buffer,
@@ -72,122 +72,122 @@ typedef enum {
  * All srpc_*_reply_t's 1st field must be a __u32 status, and 2nd field
  * session id if needed.
  */
-typedef struct {
+struct srpc_generic_reqst {
 	__u64			rpyid;		/* reply buffer matchbits */
 	__u64			bulkid;		/* bulk buffer matchbits */
-} WIRE_ATTR srpc_generic_reqst_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct srpc_generic_reply {
 	__u32			status;
 	lst_sid_t		sid;
-} WIRE_ATTR srpc_generic_reply_t;
+} WIRE_ATTR;
 
 /* FRAMEWORK RPCs */
-typedef struct {
+struct srpc_mksn_reqst {
 	__u64			mksn_rpyid;	/* reply buffer matchbits */
 	lst_sid_t		mksn_sid;	/* session id */
 	__u32			mksn_force;	/* use brute force */
 	char			mksn_name[LST_NAME_SIZE];
-} WIRE_ATTR srpc_mksn_reqst_t; /* make session request */
+} WIRE_ATTR; /* make session request */
 
-typedef struct {
+struct srpc_mksn_reply {
 	__u32			mksn_status;	/* session status */
 	lst_sid_t		mksn_sid;	/* session id */
 	__u32			mksn_timeout;	/* session timeout */
 	char			mksn_name[LST_NAME_SIZE];
-} WIRE_ATTR srpc_mksn_reply_t; /* make session reply */
+} WIRE_ATTR; /* make session reply */
 
-typedef struct {
+struct srpc_rmsn_reqst {
 	__u64			rmsn_rpyid;	/* reply buffer matchbits */
 	lst_sid_t		rmsn_sid;	/* session id */
-} WIRE_ATTR srpc_rmsn_reqst_t; /* remove session request */
+} WIRE_ATTR; /* remove session request */
 
-typedef struct {
+struct srpc_rmsn_reply {
 	__u32			rmsn_status;
 	lst_sid_t		rmsn_sid;	/* session id */
-} WIRE_ATTR srpc_rmsn_reply_t; /* remove session reply */
+} WIRE_ATTR; /* remove session reply */
 
-typedef struct {
+struct srpc_join_reqst {
 	__u64			join_rpyid;	/* reply buffer matchbits */
 	lst_sid_t		join_sid;	/* session id to join */
 	char			join_group[LST_NAME_SIZE]; /* group name */
-} WIRE_ATTR srpc_join_reqst_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct srpc_join_reply {
 	__u32			join_status;	/* returned status */
 	lst_sid_t		join_sid;	/* session id */
 	__u32			join_timeout;	/* # seconds' inactivity to
 						 * expire */
 	char			join_session[LST_NAME_SIZE]; /* session name */
-} WIRE_ATTR srpc_join_reply_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct srpc_debug_reqst {
 	__u64			dbg_rpyid;	/* reply buffer matchbits */
 	lst_sid_t		dbg_sid;	/* session id */
 	__u32			dbg_flags;	/* bitmap of debug */
-} WIRE_ATTR srpc_debug_reqst_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct srpc_debug_reply {
 	__u32			dbg_status;	/* returned code */
 	lst_sid_t		dbg_sid;	/* session id */
 	__u32			dbg_timeout;	/* session timeout */
 	__u32			dbg_nbatch;	/* # of batches in the node */
 	char			dbg_name[LST_NAME_SIZE]; /* session name */
-} WIRE_ATTR srpc_debug_reply_t;
+} WIRE_ATTR;
 
 #define SRPC_BATCH_OPC_RUN	1
 #define SRPC_BATCH_OPC_STOP	2
 #define SRPC_BATCH_OPC_QUERY	3
 
-typedef struct {
+struct srpc_batch_reqst {
 	__u64		   bar_rpyid;	   /* reply buffer matchbits */
 	lst_sid_t	   bar_sid;	   /* session id */
 	lst_bid_t	   bar_bid;	   /* batch id */
 	__u32		   bar_opc;	   /* create/start/stop batch */
 	__u32		   bar_testidx;    /* index of test */
 	__u32		   bar_arg;	   /* parameters */
-} WIRE_ATTR srpc_batch_reqst_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct srpc_batch_reply {
 	__u32		   bar_status;	   /* status of request */
 	lst_sid_t	   bar_sid;	   /* session id */
 	__u32		   bar_active;	   /* # of active tests in batch/test */
 	__u32		   bar_time;	   /* remained time */
-} WIRE_ATTR srpc_batch_reply_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct srpc_stat_reqst {
 	__u64		   str_rpyid;	   /* reply buffer matchbits */
 	lst_sid_t	   str_sid;	   /* session id */
 	__u32		   str_type;	   /* type of stat */
-} WIRE_ATTR srpc_stat_reqst_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct srpc_stat_reply {
 	__u32		   str_status;
 	lst_sid_t	   str_sid;
 	sfw_counters_t	   str_fw;
 	srpc_counters_t    str_rpc;
 	lnet_counters_t    str_lnet;
-} WIRE_ATTR srpc_stat_reply_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct test_bulk_req {
 	__u32		   blk_opc;	   /* bulk operation code */
 	__u32		   blk_npg;	   /* # of pages */
 	__u32		   blk_flags;	   /* reserved flags */
-} WIRE_ATTR test_bulk_req_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct test_bulk_req_v1 {
 	__u16		   blk_opc;	   /* bulk operation code */
 	__u16		   blk_flags;	   /* data check flags */
 	__u32		   blk_len;	   /* data length */
 	__u32		   blk_offset;	   /* reserved: offset */
-} WIRE_ATTR test_bulk_req_v1_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct test_ping_req {
 	__u32		   png_size;	   /* size of ping message */
 	__u32		   png_flags;	   /* reserved flags */
-} WIRE_ATTR test_ping_req_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct srpc_test_reqst {
 	__u64			tsr_rpyid;	/* reply buffer matchbits */
 	__u64			tsr_bulkid;	/* bulk buffer matchbits */
 	lst_sid_t		tsr_sid;	/* session id */
@@ -201,43 +201,43 @@ typedef struct {
 	__u32			tsr_ndest;	/* # of dest nodes */
 
 	union {
-		test_ping_req_t		ping;
-		test_bulk_req_t		bulk_v0;
-		test_bulk_req_v1_t	bulk_v1;
-	}		tsr_u;
-} WIRE_ATTR srpc_test_reqst_t;
+		struct test_ping_req	ping;
+		struct test_bulk_req	bulk_v0;
+		struct test_bulk_req_v1	bulk_v1;
+	} tsr_u;
+} WIRE_ATTR;
 
-typedef struct {
+struct srpc_test_reply {
 	__u32			tsr_status;	/* returned code */
 	lst_sid_t		tsr_sid;
-} WIRE_ATTR srpc_test_reply_t;
+} WIRE_ATTR;
 
 /* TEST RPCs */
-typedef struct {
+struct srpc_ping_reqst {
 	__u64		   pnr_rpyid;
 	__u32		   pnr_magic;
 	__u32		   pnr_seq;
 	__u64		   pnr_time_sec;
 	__u64		   pnr_time_usec;
-} WIRE_ATTR srpc_ping_reqst_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct srpc_ping_reply {
 	__u32		   pnr_status;
 	__u32		   pnr_magic;
 	__u32		   pnr_seq;
-} WIRE_ATTR srpc_ping_reply_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct srpc_brw_reqst {
 	__u64		   brw_rpyid;	   /* reply buffer matchbits */
 	__u64		   brw_bulkid;	   /* bulk buffer matchbits */
 	__u32		   brw_rw;	   /* read or write */
 	__u32		   brw_len;	   /* bulk data len */
 	__u32		   brw_flags;	   /* bulk data patterns */
-} WIRE_ATTR srpc_brw_reqst_t; /* bulk r/w request */
+} WIRE_ATTR; /* bulk r/w request */
 
-typedef struct {
+struct srpc_brw_reply {
 	__u32		   brw_status;
-} WIRE_ATTR srpc_brw_reply_t; /* bulk r/w reply */
+} WIRE_ATTR; /* bulk r/w reply */
 
 #define SRPC_MSG_MAGIC		0xeeb0f00d
 #define SRPC_MSG_VERSION	1
@@ -245,33 +245,33 @@ typedef struct {
 struct srpc_msg {
 	__u32	msg_magic;     /* magic number */
 	__u32	msg_version;   /* message version number */
-	__u32	msg_type;      /* type of message body: srpc_msg_type_t */
+	__u32	msg_type;      /* type of message body: srpc_msg_type */
 	__u32	msg_reserved0;
 	__u32	msg_reserved1;
 	__u32	msg_ses_feats; /* test session features */
 	union {
-		srpc_generic_reqst_t reqst;
-		srpc_generic_reply_t reply;
-
-		srpc_mksn_reqst_t    mksn_reqst;
-		srpc_mksn_reply_t    mksn_reply;
-		srpc_rmsn_reqst_t    rmsn_reqst;
-		srpc_rmsn_reply_t    rmsn_reply;
-		srpc_debug_reqst_t   dbg_reqst;
-		srpc_debug_reply_t   dbg_reply;
-		srpc_batch_reqst_t   bat_reqst;
-		srpc_batch_reply_t   bat_reply;
-		srpc_stat_reqst_t    stat_reqst;
-		srpc_stat_reply_t    stat_reply;
-		srpc_test_reqst_t    tes_reqst;
-		srpc_test_reply_t    tes_reply;
-		srpc_join_reqst_t    join_reqst;
-		srpc_join_reply_t    join_reply;
-
-		srpc_ping_reqst_t    ping_reqst;
-		srpc_ping_reply_t    ping_reply;
-		srpc_brw_reqst_t     brw_reqst;
-		srpc_brw_reply_t     brw_reply;
+		struct srpc_generic_reqst	reqst;
+		struct srpc_generic_reply	reply;
+
+		struct srpc_mksn_reqst		mksn_reqst;
+		struct srpc_mksn_reply		mksn_reply;
+		struct srpc_rmsn_reqst		rmsn_reqst;
+		struct srpc_rmsn_reply		rmsn_reply;
+		struct srpc_debug_reqst		dbg_reqst;
+		struct srpc_debug_reply		dbg_reply;
+		struct srpc_batch_reqst		bat_reqst;
+		struct srpc_batch_reply		bat_reply;
+		struct srpc_stat_reqst		stat_reqst;
+		struct srpc_stat_reply		stat_reply;
+		struct srpc_test_reqst		tes_reqst;
+		struct srpc_test_reply		tes_reply;
+		struct srpc_join_reqst		join_reqst;
+		struct srpc_join_reply		join_reply;
+
+		struct srpc_ping_reqst		ping_reqst;
+		struct srpc_ping_reply		ping_reply;
+		struct srpc_brw_reqst		brw_reqst;
+		struct srpc_brw_reply		brw_reply;
 	}     msg_body;
 } WIRE_ATTR;
 
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 1dac777..4eac1c9 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -93,7 +93,7 @@ struct sfw_test_instance;
 /* all reply/bulk RDMAs go to this portal */
 #define SRPC_RDMA_PORTAL		52
 
-static inline srpc_msg_type_t
+static inline enum srpc_msg_type
 srpc_service2request(int service)
 {
 	switch (service) {
@@ -128,7 +128,7 @@ srpc_service2request(int service)
 	}
 }
 
-static inline srpc_msg_type_t
+static inline enum srpc_msg_type
 srpc_service2reply(int service)
 {
 	return srpc_service2request(service) + 1;
@@ -385,9 +385,9 @@ struct sfw_test_instance {
 	struct list_head	   tsi_active_rpcs;	/* active rpcs */
 
 	union {
-		test_ping_req_t	   ping;    /* ping parameter */
-		test_bulk_req_t    bulk_v0; /* bulk parameter */
-		test_bulk_req_v1_t bulk_v1; /* bulk v1 parameter */
+		struct test_ping_req	ping;		/* ping parameter */
+		struct test_bulk_req	bulk_v0;	/* bulk parameter */
+		struct test_bulk_req_v1	bulk_v1;	/* bulk v1 parameter */
 	} tsi_u;
 };
 
@@ -428,7 +428,8 @@ void sfw_free_pages(struct srpc_server_rpc *rpc);
 void sfw_add_bulk_page(struct srpc_bulk *bk, struct page *pg, int i);
 int sfw_alloc_pages(struct srpc_server_rpc *rpc, int cpt, int npages, int len,
 		    int sink);
-int sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply);
+int sfw_make_session(struct srpc_mksn_reqst *request,
+		     struct srpc_mksn_reply *reply);
 
 struct srpc_client_rpc *
 srpc_create_client_rpc(lnet_process_id_t peer, int service,
-- 
1.7.1
