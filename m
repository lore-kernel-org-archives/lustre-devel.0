From: James Simmons <jsimmons@infradead.org>
Date: Fri, 11 Mar 2016 20:29:46 -0500
Subject: [lustre-devel] [PATCH 05/10] staging: lustre: remove extra spacing
	when setting variable for lnet selftest
In-Reply-To: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
References: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457746191-27981-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Remove any extra spacing for the lines of code setting variables to
some value.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c  |   40 ++++++------
 drivers/staging/lustre/lnet/selftest/conrpc.c    |   68 ++++++++++----------
 drivers/staging/lustre/lnet/selftest/console.c   |   78 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/framework.c |   60 ++++++++--------
 drivers/staging/lustre/lnet/selftest/ping_test.c |   14 ++--
 drivers/staging/lustre/lnet/selftest/rpc.c       |   68 ++++++++++----------
 drivers/staging/lustre/lnet/selftest/selftest.h  |   20 +++---
 7 files changed, 174 insertions(+), 174 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 6b1f983..0d0c22c 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -83,14 +83,14 @@ brw_client_init(sfw_test_instance_t *tsi)
 	if (!(sn->sn_features & LST_FEAT_BULK_LEN)) {
 		test_bulk_req_t *breq = &tsi->tsi_u.bulk_v0;
 
-		opc   = breq->blk_opc;
+		opc = breq->blk_opc;
 		flags = breq->blk_flags;
-		npg   = breq->blk_npg;
+		npg = breq->blk_npg;
 		/*
 		 * NB: this is not going to work for variable page size,
 		 * but we have to keep it for compatibility
 		 */
-		len   = npg * PAGE_CACHE_SIZE;
+		len = npg * PAGE_CACHE_SIZE;
 
 	} else {
 		test_bulk_req_v1_t *breq = &tsi->tsi_u.bulk_v1;
@@ -101,10 +101,10 @@ brw_client_init(sfw_test_instance_t *tsi)
 		 */
 		LASSERT(!(sn->sn_features & ~LST_FEATS_MASK));
 
-		opc   = breq->blk_opc;
+		opc = breq->blk_opc;
 		flags = breq->blk_flags;
-		len   = breq->blk_len;
-		npg   = (len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+		len = breq->blk_len;
+		npg = (len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	}
 
 	if (npg > LNET_MAX_IOV || npg <= 0)
@@ -275,10 +275,10 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 	if (!(sn->sn_features & LST_FEAT_BULK_LEN)) {
 		test_bulk_req_t *breq = &tsi->tsi_u.bulk_v0;
 
-		opc   = breq->blk_opc;
+		opc = breq->blk_opc;
 		flags = breq->blk_flags;
-		npg   = breq->blk_npg;
-		len   = npg * PAGE_CACHE_SIZE;
+		npg = breq->blk_npg;
+		len = npg * PAGE_CACHE_SIZE;
 
 	} else {
 		test_bulk_req_v1_t *breq = &tsi->tsi_u.bulk_v1;
@@ -289,10 +289,10 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 		 */
 		LASSERT(!(sn->sn_features & ~LST_FEATS_MASK));
 
-		opc   = breq->blk_opc;
+		opc = breq->blk_opc;
 		flags = breq->blk_flags;
-		len   = breq->blk_len;
-		npg   = (len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+		len = breq->blk_len;
+		npg = (len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	}
 
 	rc = sfw_create_test_rpc(tsu, dest, sn->sn_features, npg, len, &rpc);
@@ -307,8 +307,8 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 
 	req = &rpc->crpc_reqstmsg.msg_body.brw_reqst;
 	req->brw_flags = flags;
-	req->brw_rw    = opc;
-	req->brw_len   = len;
+	req->brw_rw = opc;
+	req->brw_len = len;
 
 	*rpcpp = rpc;
 	return 0;
@@ -493,8 +493,8 @@ brw_server_handle(struct srpc_server_rpc *rpc)
 sfw_test_client_ops_t brw_test_client;
 void brw_init_test_client(void)
 {
-	brw_test_client.tso_init     = brw_client_init;
-	brw_test_client.tso_fini     = brw_client_fini;
+	brw_test_client.tso_init = brw_client_init;
+	brw_test_client.tso_fini = brw_client_fini;
 	brw_test_client.tso_prep_rpc = brw_client_prep_rpc;
 	brw_test_client.tso_done_rpc = brw_client_done_rpc;
 };
@@ -502,9 +502,9 @@ void brw_init_test_client(void)
 srpc_service_t brw_test_service;
 void brw_init_test_service(void)
 {
-	brw_test_service.sv_id         = SRPC_SERVICE_BRW;
-	brw_test_service.sv_name       = "brw_test";
-	brw_test_service.sv_handler    = brw_server_handle;
+	brw_test_service.sv_id = SRPC_SERVICE_BRW;
+	brw_test_service.sv_name = "brw_test";
+	brw_test_service.sv_handler = brw_server_handle;
 	brw_test_service.sv_bulk_ready = brw_bulk_ready;
-	brw_test_service.sv_wi_total   = brw_srv_workitems;
+	brw_test_service.sv_wi_total = brw_srv_workitems;
 }
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 77ea41b..cdb660e 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -78,7 +78,7 @@ lstcon_rpc_done(srpc_client_rpc_t *rpc)
 		/* not aborted */
 		LASSERT(!crpc->crp_status);
 
-		crpc->crp_stamp  = cfs_time_current();
+		crpc->crp_stamp = cfs_time_current();
 		crpc->crp_status = rpc->crpc_status;
 	}
 
@@ -99,13 +99,13 @@ lstcon_rpc_init(lstcon_node_t *nd, int service, unsigned feats,
 	if (!crpc->crp_rpc)
 		return -ENOMEM;
 
-	crpc->crp_trans    = NULL;
-	crpc->crp_node     = nd;
-	crpc->crp_posted   = 0;
+	crpc->crp_trans = NULL;
+	crpc->crp_node = nd;
+	crpc->crp_posted = 0;
 	crpc->crp_finished = 0;
 	crpc->crp_unpacked = 0;
-	crpc->crp_status   = 0;
-	crpc->crp_stamp    = 0;
+	crpc->crp_status = 0;
+	crpc->crp_stamp = 0;
 	crpc->crp_embedded = embedded;
 	INIT_LIST_HEAD(&crpc->crp_link);
 
@@ -306,7 +306,7 @@ lstcon_rpc_trans_abort(lstcon_rpc_trans_t *trans, int error)
 			continue;
 		}
 
-		crpc->crp_stamp  = cfs_time_current();
+		crpc->crp_stamp = cfs_time_current();
 		crpc->crp_status = error;
 
 		spin_unlock(&rpc->crpc_lock);
@@ -571,7 +571,7 @@ lstcon_rpc_trans_destroy(lstcon_rpc_trans_t *trans)
 		 */
 		LASSERT(crpc->crp_status);
 
-		crpc->crp_node  = NULL;
+		crpc->crp_node = NULL;
 		crpc->crp_trans = NULL;
 		list_del_init(&crpc->crp_link);
 		count++;
@@ -609,8 +609,8 @@ lstcon_sesrpc_prep(lstcon_node_t *nd, int transop,
 			return rc;
 
 		msrq = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.mksn_reqst;
-		msrq->mksn_sid     = console_session.ses_id;
-		msrq->mksn_force   = console_session.ses_force;
+		msrq->mksn_sid = console_session.ses_id;
+		msrq->mksn_force = console_session.ses_force;
 		strlcpy(msrq->mksn_name, console_session.ses_name,
 			sizeof(msrq->mksn_name));
 		break;
@@ -644,7 +644,7 @@ lstcon_dbgrpc_prep(lstcon_node_t *nd, unsigned feats, lstcon_rpc_t **crpc)
 
 	drq = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.dbg_reqst;
 
-	drq->dbg_sid   = console_session.ses_id;
+	drq->dbg_sid = console_session.ses_id;
 	drq->dbg_flags = 0;
 
 	return rc;
@@ -664,10 +664,10 @@ lstcon_batrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 
 	brq = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.bat_reqst;
 
-	brq->bar_sid     = console_session.ses_id;
-	brq->bar_bid     = tsb->tsb_id;
+	brq->bar_sid = console_session.ses_id;
+	brq->bar_bid = tsb->tsb_id;
 	brq->bar_testidx = tsb->tsb_index;
-	brq->bar_opc     = transop == LST_TRANS_TSBRUN ? SRPC_BATCH_OPC_RUN :
+	brq->bar_opc = transop == LST_TRANS_TSBRUN ? SRPC_BATCH_OPC_RUN :
 			   (transop == LST_TRANS_TSBSTOP ? SRPC_BATCH_OPC_STOP :
 			    SRPC_BATCH_OPC_QUERY);
 
@@ -695,7 +695,7 @@ lstcon_statrpc_prep(lstcon_node_t *nd, unsigned feats, lstcon_rpc_t **crpc)
 
 	srq = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.stat_reqst;
 
-	srq->str_sid  = console_session.ses_id;
+	srq->str_sid = console_session.ses_id;
 	srq->str_type = 0; /* XXX remove it */
 
 	return 0;
@@ -735,7 +735,7 @@ lstcon_dstnodes_prep(lstcon_group_t *grp, int idx,
 		return -EINVAL;
 
 	start = ((idx / dist) * span) % grp->grp_nnode;
-	end   = ((idx / dist) * span + span - 1) % grp->grp_nnode;
+	end = ((idx / dist) * span + span - 1) % grp->grp_nnode;
 
 	list_for_each_entry(ndl, &grp->grp_ndl_list, ndl_link) {
 		nd = ndl->ndl_node;
@@ -775,7 +775,7 @@ lstcon_pingrpc_prep(lst_test_ping_param_t *param, srpc_test_reqst_t *req)
 {
 	test_ping_req_t *prq = &req->tsr_u.ping;
 
-	prq->png_size  = param->png_size;
+	prq->png_size = param->png_size;
 	prq->png_flags = param->png_flags;
 	/* TODO dest */
 	return 0;
@@ -786,9 +786,9 @@ lstcon_bulkrpc_v0_prep(lst_test_bulk_param_t *param, srpc_test_reqst_t *req)
 {
 	test_bulk_req_t *brq = &req->tsr_u.bulk_v0;
 
-	brq->blk_opc   = param->blk_opc;
-	brq->blk_npg   = (param->blk_size + PAGE_CACHE_SIZE - 1) /
-			  PAGE_CACHE_SIZE;
+	brq->blk_opc = param->blk_opc;
+	brq->blk_npg = (param->blk_size + PAGE_CACHE_SIZE - 1) /
+			PAGE_CACHE_SIZE;
 	brq->blk_flags = param->blk_flags;
 
 	return 0;
@@ -799,9 +799,9 @@ lstcon_bulkrpc_v1_prep(lst_test_bulk_param_t *param, srpc_test_reqst_t *req)
 {
 	test_bulk_req_v1_t *brq = &req->tsr_u.bulk_v1;
 
-	brq->blk_opc	= param->blk_opc;
-	brq->blk_flags	= param->blk_flags;
-	brq->blk_len	= param->blk_size;
+	brq->blk_opc = param->blk_opc;
+	brq->blk_flags = param->blk_flags;
+	brq->blk_len = param->blk_size;
 	brq->blk_offset	= 0; /* reserved */
 
 	return 0;
@@ -818,7 +818,7 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 	int i;
 	int npg = 0;
 	int nob = 0;
-	int rc  = 0;
+	int rc = 0;
 
 	if (transop == LST_TRANS_TSBCLIADD) {
 		npg = sfw_id_pages(test->tes_span);
@@ -831,7 +831,7 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 	if (rc)
 		return rc;
 
-	trq  = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.tes_reqst;
+	trq = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.tes_reqst;
 
 	if (transop == LST_TRANS_TSBSRVADD) {
 		int ndist = (sgrp->grp_nnode + test->tes_dist - 1) /
@@ -841,7 +841,7 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 		int nmax = (ndist + nspan - 1) / nspan;
 
 		trq->tsr_ndest = 0;
-		trq->tsr_loop  = nmax * test->tes_dist * test->tes_concur;
+		trq->tsr_loop = nmax * test->tes_dist * test->tes_concur;
 
 	} else {
 		bulk = &(*crpc)->crp_rpc->crpc_bulk;
@@ -857,8 +857,8 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 			nob -= len;
 
 			bulk->bk_iovs[i].kiov_offset = 0;
-			bulk->bk_iovs[i].kiov_len    = len;
-			bulk->bk_iovs[i].kiov_page   =
+			bulk->bk_iovs[i].kiov_len = len;
+			bulk->bk_iovs[i].kiov_page =
 				alloc_page(GFP_KERNEL);
 
 			if (!bulk->bk_iovs[i].kiov_page) {
@@ -882,13 +882,13 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 		}
 
 		trq->tsr_ndest = test->tes_span;
-		trq->tsr_loop  = test->tes_loop;
+		trq->tsr_loop = test->tes_loop;
 	}
 
-	trq->tsr_sid        = console_session.ses_id;
-	trq->tsr_bid        = test->tes_hdr.tsb_id;
-	trq->tsr_concur     = test->tes_concur;
-	trq->tsr_is_client  = (transop == LST_TRANS_TSBCLIADD) ? 1 : 0;
+	trq->tsr_sid = console_session.ses_id;
+	trq->tsr_bid = test->tes_hdr.tsb_id;
+	trq->tsr_concur = test->tes_concur;
+	trq->tsr_is_client = (transop == LST_TRANS_TSBCLIADD) ? 1 : 0;
 	trq->tsr_stop_onerr = !!test->tes_stop_onerr;
 
 	switch (test->tes_type) {
@@ -1262,7 +1262,7 @@ lstcon_rpc_pinger(void *arg)
 
 		drq = &crpc->crp_rpc->crpc_reqstmsg.msg_body.dbg_reqst;
 
-		drq->dbg_sid   = console_session.ses_id;
+		drq->dbg_sid = console_session.ses_id;
 		drq->dbg_flags = 0;
 
 		lstcon_rpc_trans_addreq(trans, crpc);
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index aac159b..15cd830 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -97,8 +97,8 @@ lstcon_node_find(lnet_process_id_t id, lstcon_node_t **ndpp, int create)
 
 	ndl->ndl_node = *ndpp;
 
-	ndl->ndl_node->nd_ref   = 1;
-	ndl->ndl_node->nd_id    = id;
+	ndl->ndl_node->nd_ref = 1;
+	ndl->ndl_node->nd_id = id;
 	ndl->ndl_node->nd_stamp = cfs_time_current();
 	ndl->ndl_node->nd_state = LST_NODE_UNKNOWN;
 	ndl->ndl_node->nd_timeout = 0;
@@ -179,7 +179,7 @@ lstcon_ndlink_find(struct list_head *hash,
 	INIT_LIST_HEAD(&ndl->ndl_link);
 	list_add_tail(&ndl->ndl_hlink, &hash[idx]);
 
-	return  0;
+	return 0;
 }
 
 static void
@@ -978,8 +978,8 @@ lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
 		entp->u.tbe_batch.bae_state = bat->bat_state;
 
 	} else {
-		entp->u.tbe_test.tse_type   = test->tes_type;
-		entp->u.tbe_test.tse_loop   = test->tes_loop;
+		entp->u.tbe_test.tse_type = test->tes_type;
+		entp->u.tbe_test.tse_loop = test->tes_loop;
 		entp->u.tbe_test.tse_concur = test->tes_concur;
 	}
 
@@ -1196,7 +1196,7 @@ lstcon_test_nodes_add(lstcon_test_t *test, struct list_head __user *result_up)
 	LASSERT(test->tes_dst_grp);
 
 	transop = LST_TRANS_TSBSRVADD;
-	grp  = test->tes_dst_grp;
+	grp = test->tes_dst_grp;
 again:
 	rc = lstcon_rpc_trans_ndlist(&grp->grp_ndl_list,
 				     &test->tes_trans_list, transop,
@@ -1317,18 +1317,18 @@ lstcon_test_add(char *batch_name, int type, int loop,
 		goto out;
 	}
 
-	test->tes_hdr.tsb_id	= batch->bat_hdr.tsb_id;
-	test->tes_batch		= batch;
-	test->tes_type		= type;
-	test->tes_oneside	= 0; /* TODO */
-	test->tes_loop		= loop;
-	test->tes_concur	= concur;
-	test->tes_stop_onerr	= 1; /* TODO */
-	test->tes_span		= span;
-	test->tes_dist		= dist;
-	test->tes_cliidx	= 0; /* just used for creating RPC */
-	test->tes_src_grp	= src_grp;
-	test->tes_dst_grp	= dst_grp;
+	test->tes_hdr.tsb_id = batch->bat_hdr.tsb_id;
+	test->tes_batch	= batch;
+	test->tes_type = type;
+	test->tes_oneside = 0; /* TODO */
+	test->tes_loop = loop;
+	test->tes_concur = concur;
+	test->tes_stop_onerr = 1; /* TODO */
+	test->tes_span = span;
+	test->tes_dist = dist;
+	test->tes_cliidx = 0; /* just used for creating RPC */
+	test->tes_src_grp = src_grp;
+	test->tes_dst_grp = dst_grp;
 	INIT_LIST_HEAD(&test->tes_trans_list);
 
 	if (param) {
@@ -1420,8 +1420,8 @@ lstcon_test_batch_query(char *name, int testidx, int client,
 
 	if (!testidx) {
 		translist = &batch->bat_trans_list;
-		ndlist    = &batch->bat_cli_list;
-		hdr       = &batch->bat_hdr;
+		ndlist = &batch->bat_cli_list;
+		hdr = &batch->bat_hdr;
 
 	} else {
 		/* query specified test only */
@@ -1432,8 +1432,8 @@ lstcon_test_batch_query(char *name, int testidx, int client,
 		}
 
 		translist = &test->tes_trans_list;
-		ndlist    = &test->tes_src_grp->grp_ndl_list;
-		hdr       = &test->tes_hdr;
+		ndlist = &test->tes_src_grp->grp_ndl_list;
+		hdr = &test->tes_hdr;
 	}
 
 	transop = client ? LST_TRANS_TSBCLIQRY : LST_TRANS_TSBSRVQRY;
@@ -1689,7 +1689,7 @@ lstcon_nodes_debug(int timeout,
 int
 lstcon_session_match(lst_sid_t sid)
 {
-	return (console_session.ses_id.ses_nid   == sid.ses_nid &&
+	return (console_session.ses_id.ses_nid == sid.ses_nid &&
 		console_session.ses_id.ses_stamp == sid.ses_stamp) ?  1 : 0;
 }
 
@@ -1701,7 +1701,7 @@ lstcon_new_session_id(lst_sid_t *sid)
 	LASSERT(console_session.ses_state == LST_SESSION_NONE);
 
 	LNetGetId(1, &id);
-	sid->ses_nid   = id.nid;
+	sid->ses_nid = id.nid;
 	sid->ses_stamp = cfs_time_current();
 }
 
@@ -1839,9 +1839,9 @@ lstcon_session_end(void)
 	/* waiting for orphan rpcs to die */
 	lstcon_rpc_cleanup_wait();
 
-	console_session.ses_id    = LST_INVALID_SID;
+	console_session.ses_id = LST_INVALID_SID;
 	console_session.ses_state = LST_SESSION_NONE;
-	console_session.ses_key   = 0;
+	console_session.ses_key = 0;
 	console_session.ses_force = 0;
 	console_session.ses_feats_updated = 0;
 
@@ -1866,7 +1866,7 @@ lstcon_session_end(void)
 	LASSERT(list_empty(&console_session.ses_ndl_list));
 
 	console_session.ses_shutdown = 0;
-	console_session.ses_expired  = 0;
+	console_session.ses_expired = 0;
 
 	return rc;
 }
@@ -1965,7 +1965,7 @@ lstcon_acceptor_handle(struct srpc_server_rpc *rpc)
 		goto out;
 	}
 
-	ndl->ndl_node->nd_state   = LST_NODE_ACTIVE;
+	ndl->ndl_node->nd_state = LST_NODE_ACTIVE;
 	ndl->ndl_node->nd_timeout = console_session.ses_timeout;
 
 	if (!grp->grp_userland)
@@ -1974,7 +1974,7 @@ lstcon_acceptor_handle(struct srpc_server_rpc *rpc)
 	strlcpy(jrep->join_session, console_session.ses_name,
 		sizeof(jrep->join_session));
 	jrep->join_timeout = console_session.ses_timeout;
-	jrep->join_status  = 0;
+	jrep->join_status = 0;
 
 out:
 	rep->msg_ses_feats = console_session.ses_features;
@@ -1990,9 +1990,9 @@ static srpc_service_t lstcon_acceptor_service;
 static void lstcon_init_acceptor_service(void)
 {
 	/* initialize selftest console acceptor service table */
-	lstcon_acceptor_service.sv_name     = "join session";
-	lstcon_acceptor_service.sv_handler  = lstcon_acceptor_handle;
-	lstcon_acceptor_service.sv_id       = SRPC_SERVICE_JOIN;
+	lstcon_acceptor_service.sv_name = "join session";
+	lstcon_acceptor_service.sv_handler = lstcon_acceptor_handle;
+	lstcon_acceptor_service.sv_id = SRPC_SERVICE_JOIN;
 	lstcon_acceptor_service.sv_wi_total = SFW_FRWK_WI_MAX;
 }
 
@@ -2009,14 +2009,14 @@ lstcon_console_init(void)
 
 	memset(&console_session, 0, sizeof(struct lstcon_session));
 
-	console_session.ses_id		  = LST_INVALID_SID;
-	console_session.ses_state	  = LST_SESSION_NONE;
-	console_session.ses_timeout	  = 0;
-	console_session.ses_force	  = 0;
-	console_session.ses_expired	  = 0;
+	console_session.ses_id = LST_INVALID_SID;
+	console_session.ses_state = LST_SESSION_NONE;
+	console_session.ses_timeout = 0;
+	console_session.ses_force = 0;
+	console_session.ses_expired = 0;
 	console_session.ses_feats_updated = 0;
-	console_session.ses_features	  = LST_FEATS_MASK;
-	console_session.ses_laststamp	  = ktime_get_real_seconds();
+	console_session.ses_features = LST_FEATS_MASK;
+	console_session.ses_laststamp = ktime_get_real_seconds();
 
 	mutex_init(&console_session.ses_mutex);
 
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 04bab32..a3ccd78 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -149,7 +149,7 @@ sfw_register_test(srpc_service_t *service, sfw_test_client_ops_t *cliops)
 	if (!tsc)
 		return -ENOMEM;
 
-	tsc->tsc_cli_ops     = cliops;
+	tsc->tsc_cli_ops = cliops;
 	tsc->tsc_srv_service = service;
 
 	list_add_tail(&tsc->tsc_list, &sfw_data.fw_tests);
@@ -271,10 +271,10 @@ sfw_init_session(sfw_session_t *sn, lst_sid_t sid,
 	strlcpy(&sn->sn_name[0], name, sizeof(sn->sn_name));
 
 	sn->sn_timer_active = 0;
-	sn->sn_id           = sid;
-	sn->sn_features	    = features;
-	sn->sn_timeout      = session_timeout;
-	sn->sn_started      = cfs_time_current();
+	sn->sn_id = sid;
+	sn->sn_features = features;
+	sn->sn_timeout = session_timeout;
+	sn->sn_started = cfs_time_current();
 
 	timer->stt_data = sn;
 	timer->stt_func = sfw_session_expired;
@@ -350,9 +350,9 @@ sfw_bid2batch(lst_bid_t bid)
 	if (!bat)
 		return NULL;
 
-	bat->bat_error    = 0;
-	bat->bat_session  = sn;
-	bat->bat_id       = bid;
+	bat->bat_error = 0;
+	bat->bat_session = sn;
+	bat->bat_id = bid;
 	atomic_set(&bat->bat_nactive, 0);
 	INIT_LIST_HEAD(&bat->bat_tests);
 
@@ -386,9 +386,9 @@ sfw_get_stats(srpc_stat_reqst_t *request, srpc_stat_reply_t *reply)
 	 * send over the msecs since the session was started
 	 * with 32 bits to send, this is ~49 days
 	 */
-	cnt->running_ms	     = jiffies_to_msecs(jiffies - sn->sn_started);
-	cnt->brw_errors      = atomic_read(&sn->sn_brw_errors);
-	cnt->ping_errors     = atomic_read(&sn->sn_ping_errors);
+	cnt->running_ms = jiffies_to_msecs(jiffies - sn->sn_started);
+	cnt->brw_errors = atomic_read(&sn->sn_brw_errors);
+	cnt->ping_errors = atomic_read(&sn->sn_ping_errors);
 	cnt->zombie_sessions = atomic_read(&sfw_data.fw_nzombies);
 
 	cnt->active_batches = 0;
@@ -416,8 +416,8 @@ sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
 	}
 
 	if (sn) {
-		reply->mksn_status  = 0;
-		reply->mksn_sid     = sn->sn_id;
+		reply->mksn_status = 0;
+		reply->mksn_sid = sn->sn_id;
 		reply->mksn_timeout = sn->sn_timeout;
 
 		if (sfw_sid_equal(request->mksn_sid, sn->sn_id)) {
@@ -466,8 +466,8 @@ sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
 
 	spin_unlock(&sfw_data.fw_lock);
 
-	reply->mksn_status  = 0;
-	reply->mksn_sid     = sn->sn_id;
+	reply->mksn_status = 0;
+	reply->mksn_sid = sn->sn_id;
 	reply->mksn_timeout = sn->sn_timeout;
 	return 0;
 }
@@ -499,7 +499,7 @@ sfw_remove_session(srpc_rmsn_reqst_t *request, srpc_rmsn_reply_t *reply)
 	spin_unlock(&sfw_data.fw_lock);
 
 	reply->rmsn_status = 0;
-	reply->rmsn_sid    = LST_INVALID_SID;
+	reply->rmsn_sid = LST_INVALID_SID;
 	LASSERT(!sfw_data.fw_session);
 	return 0;
 }
@@ -511,12 +511,12 @@ sfw_debug_session(srpc_debug_reqst_t *request, srpc_debug_reply_t *reply)
 
 	if (!sn) {
 		reply->dbg_status = ESRCH;
-		reply->dbg_sid    = LST_INVALID_SID;
+		reply->dbg_sid = LST_INVALID_SID;
 		return 0;
 	}
 
-	reply->dbg_status  = 0;
-	reply->dbg_sid     = sn->sn_id;
+	reply->dbg_status = 0;
+	reply->dbg_sid = sn->sn_id;
 	reply->dbg_timeout = sn->sn_timeout;
 	if (strlcpy(reply->dbg_name, &sn->sn_name[0], sizeof(reply->dbg_name))
 	    >= sizeof(reply->dbg_name))
@@ -753,12 +753,12 @@ sfw_add_test_instance(sfw_batch_t *tsb, struct srpc_server_rpc *rpc)
 	INIT_LIST_HEAD(&tsi->tsi_free_rpcs);
 	INIT_LIST_HEAD(&tsi->tsi_active_rpcs);
 
-	tsi->tsi_stopping      = 0;
-	tsi->tsi_batch         = tsb;
-	tsi->tsi_loop          = req->tsr_loop;
-	tsi->tsi_concur        = req->tsr_concur;
-	tsi->tsi_service       = req->tsr_service;
-	tsi->tsi_is_client     = !!(req->tsr_is_client);
+	tsi->tsi_stopping = 0;
+	tsi->tsi_batch = tsb;
+	tsi->tsi_loop = req->tsr_loop;
+	tsi->tsi_concur = req->tsr_concur;
+	tsi->tsi_service = req->tsr_service;
+	tsi->tsi_is_client = !!(req->tsr_is_client);
 	tsi->tsi_stoptsu_onerr = !!(req->tsr_stop_onerr);
 
 	rc = sfw_load_test(tsi);
@@ -806,7 +806,7 @@ sfw_add_test_instance(sfw_batch_t *tsb, struct srpc_server_rpc *rpc)
 			tsu->tsu_dest.nid = id.nid;
 			tsu->tsu_dest.pid = id.pid;
 			tsu->tsu_instance = tsi;
-			tsu->tsu_private  = NULL;
+			tsu->tsu_private = NULL;
 			list_add_tail(&tsu->tsu_list, &tsi->tsi_units);
 		}
 	}
@@ -1269,7 +1269,7 @@ sfw_handle_server_rpc(struct srpc_server_rpc *rpc)
 			CNETERR("Features of framework RPC don't match features of current session: %x/%x\n",
 				request->msg_ses_feats, sn->sn_features);
 			reply->msg_body.reply.status = EPROTO;
-			reply->msg_body.reply.sid    = sn->sn_id;
+			reply->msg_body.reply.sid = sn->sn_id;
 			goto out;
 		}
 
@@ -1652,7 +1652,7 @@ sfw_startup(void)
 
 	memset(&sfw_data, 0, sizeof(struct smoketest_framework));
 
-	sfw_data.fw_session     = NULL;
+	sfw_data.fw_session = NULL;
 	sfw_data.fw_active_srpc = NULL;
 	spin_lock_init(&sfw_data.fw_lock);
 	atomic_set(&sfw_data.fw_nzombies, 0);
@@ -1689,8 +1689,8 @@ sfw_startup(void)
 			break;
 
 		sv->sv_bulk_ready = NULL;
-		sv->sv_handler    = sfw_handle_server_rpc;
-		sv->sv_wi_total   = SFW_FRWK_WI_MAX;
+		sv->sv_handler = sfw_handle_server_rpc;
+		sv->sv_wi_total = SFW_FRWK_WI_MAX;
 		if (sv->sv_id == SRPC_SERVICE_TEST)
 			sv->sv_bulk_ready = sfw_bulk_ready;
 
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index b5e69a7..cb2707a 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -111,7 +111,7 @@ ping_client_prep_rpc(sfw_test_unit_t *tsu,
 	spin_unlock(&lst_ping_data.pnd_lock);
 
 	ktime_get_real_ts64(&ts);
-	req->pnr_time_sec  = ts.tv_sec;
+	req->pnr_time_sec = ts.tv_sec;
 	req->pnr_time_usec = ts.tv_nsec / NSEC_PER_USEC;
 
 	return rc;
@@ -194,7 +194,7 @@ ping_server_handle(struct srpc_server_rpc *rpc)
 		return -EINVAL;
 	}
 
-	rep->pnr_seq   = req->pnr_seq;
+	rep->pnr_seq = req->pnr_seq;
 	rep->pnr_magic = LST_PING_TEST_MAGIC;
 
 	if (reqstmsg->msg_ses_feats & ~LST_FEATS_MASK) {
@@ -213,8 +213,8 @@ ping_server_handle(struct srpc_server_rpc *rpc)
 sfw_test_client_ops_t ping_test_client;
 void ping_init_test_client(void)
 {
-	ping_test_client.tso_init     = ping_client_init;
-	ping_test_client.tso_fini     = ping_client_fini;
+	ping_test_client.tso_init = ping_client_init;
+	ping_test_client.tso_fini = ping_client_fini;
 	ping_test_client.tso_prep_rpc = ping_client_prep_rpc;
 	ping_test_client.tso_done_rpc = ping_client_done_rpc;
 }
@@ -222,8 +222,8 @@ void ping_init_test_client(void)
 srpc_service_t ping_test_service;
 void ping_init_test_service(void)
 {
-	ping_test_service.sv_id       = SRPC_SERVICE_PING;
-	ping_test_service.sv_name     = "ping_test";
-	ping_test_service.sv_handler  = ping_server_handle;
+	ping_test_service.sv_id = SRPC_SERVICE_PING;
+	ping_test_service.sv_name = "ping_test";
+	ping_test_service.sv_handler = ping_server_handle;
 	ping_test_service.sv_wi_total = ping_srv_workitems;
 }
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 1af978f..f344d56 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -96,8 +96,8 @@ srpc_add_bulk_page(srpc_bulk_t *bk, struct page *pg, int i, int nob)
 	LASSERT(i >= 0 && i < bk->bk_niov);
 
 	bk->bk_iovs[i].kiov_offset = 0;
-	bk->bk_iovs[i].kiov_page   = pg;
-	bk->bk_iovs[i].kiov_len    = nob;
+	bk->bk_iovs[i].kiov_page = pg;
+	bk->bk_iovs[i].kiov_len = nob;
 	return nob;
 }
 
@@ -136,9 +136,9 @@ srpc_alloc_bulk(int cpt, unsigned bulk_npg, unsigned bulk_len, int sink)
 	}
 
 	memset(bk, 0, offsetof(srpc_bulk_t, bk_iovs[bulk_npg]));
-	bk->bk_sink   = sink;
-	bk->bk_len    = bulk_len;
-	bk->bk_niov   = bulk_npg;
+	bk->bk_sink = sink;
+	bk->bk_len = bulk_len;
+	bk->bk_niov = bulk_npg;
 
 	for (i = 0; i < bulk_npg; i++) {
 		struct page *pg;
@@ -182,10 +182,10 @@ srpc_init_server_rpc(struct srpc_server_rpc *rpc,
 
 	rpc->srpc_ev.ev_fired = 1; /* no event expected now */
 
-	rpc->srpc_scd      = scd;
+	rpc->srpc_scd = scd;
 	rpc->srpc_reqstbuf = buffer;
-	rpc->srpc_peer     = buffer->buf_peer;
-	rpc->srpc_self     = buffer->buf_self;
+	rpc->srpc_peer = buffer->buf_peer;
+	rpc->srpc_self = buffer->buf_self;
 	LNetInvalidateHandle(&rpc->srpc_replymdh);
 }
 
@@ -372,10 +372,10 @@ srpc_post_passive_rdma(int portal, int local, __u64 matchbits, void *buf,
 	}
 
 	md.threshold = 1;
-	md.user_ptr  = ev;
-	md.start     = buf;
-	md.length    = len;
-	md.options   = options;
+	md.user_ptr = ev;
+	md.start = buf;
+	md.length = len;
+	md.options = options;
 	md.eq_handle = srpc_data.rpc_lnet_eq;
 
 	rc = LNetMDAttach(meh, md, LNET_UNLINK, mdh);
@@ -401,12 +401,12 @@ srpc_post_active_rdma(int portal, __u64 matchbits, void *buf, int len,
 	int rc;
 	lnet_md_t md;
 
-	md.user_ptr  = ev;
-	md.start     = buf;
-	md.length    = len;
+	md.user_ptr = ev;
+	md.start = buf;
+	md.length = len;
 	md.eq_handle = srpc_data.rpc_lnet_eq;
 	md.threshold = options & LNET_MD_OP_GET ? 2 : 1;
-	md.options   = options & ~(LNET_MD_OP_PUT | LNET_MD_OP_GET);
+	md.options = options & ~(LNET_MD_OP_PUT | LNET_MD_OP_GET);
 
 	rc = LNetMDBind(md, LNET_UNLINK, mdh);
 	if (rc) {
@@ -798,8 +798,8 @@ srpc_send_request(srpc_client_rpc_t *rpc)
 	int rc;
 
 	ev->ev_fired = 0;
-	ev->ev_data  = rpc;
-	ev->ev_type  = SRPC_REQUEST_SENT;
+	ev->ev_data = rpc;
+	ev->ev_type = SRPC_REQUEST_SENT;
 
 	 rc = srpc_post_active_rdma(srpc_serv_portal(rpc->crpc_service),
 				    rpc->crpc_service, &rpc->crpc_reqstmsg,
@@ -821,8 +821,8 @@ srpc_prepare_reply(srpc_client_rpc_t *rpc)
 	int rc;
 
 	ev->ev_fired = 0;
-	ev->ev_data  = rpc;
-	ev->ev_type  = SRPC_REPLY_RCVD;
+	ev->ev_data = rpc;
+	ev->ev_type = SRPC_REPLY_RCVD;
 
 	*id = srpc_next_id();
 
@@ -855,8 +855,8 @@ srpc_prepare_bulk(srpc_client_rpc_t *rpc)
 	opt |= LNET_MD_KIOV;
 
 	ev->ev_fired = 0;
-	ev->ev_data  = rpc;
-	ev->ev_type  = SRPC_BULK_REQ_RCVD;
+	ev->ev_data = rpc;
+	ev->ev_type = SRPC_BULK_REQ_RCVD;
 
 	*id = srpc_next_id();
 
@@ -885,8 +885,8 @@ srpc_do_bulk(struct srpc_server_rpc *rpc)
 	opt |= LNET_MD_KIOV;
 
 	ev->ev_fired = 0;
-	ev->ev_data  = rpc;
-	ev->ev_type  = bk->bk_sink ? SRPC_BULK_GET_RPLD : SRPC_BULK_PUT_SENT;
+	ev->ev_data = rpc;
+	ev->ev_type = bk->bk_sink ? SRPC_BULK_GET_RPLD : SRPC_BULK_PUT_SENT;
 
 	rc = srpc_post_active_rdma(SRPC_RDMA_PORTAL, id,
 				   &bk->bk_iovs[0], bk->bk_niov, opt,
@@ -1104,8 +1104,8 @@ srpc_add_client_rpc_timer(srpc_client_rpc_t *rpc)
 		return;
 
 	INIT_LIST_HEAD(&timer->stt_list);
-	timer->stt_data    = rpc;
-	timer->stt_func    = srpc_client_rpc_expired;
+	timer->stt_data = rpc;
+	timer->stt_func = srpc_client_rpc_expired;
 	timer->stt_expires = ktime_get_real_seconds() + rpc->crpc_timeout;
 	stt_add_timer(timer);
 }
@@ -1341,7 +1341,7 @@ srpc_abort_rpc(srpc_client_rpc_t *rpc, int why)
 	       swi_state2str(rpc->crpc_wi.swi_state), why);
 
 	rpc->crpc_aborted = 1;
-	rpc->crpc_status  = why;
+	rpc->crpc_status = why;
 	swi_schedule_workitem(&rpc->crpc_wi);
 }
 
@@ -1389,12 +1389,12 @@ srpc_send_reply(struct srpc_server_rpc *rpc)
 	spin_unlock(&scd->scd_lock);
 
 	ev->ev_fired = 0;
-	ev->ev_data  = rpc;
-	ev->ev_type  = SRPC_REPLY_SENT;
+	ev->ev_data = rpc;
+	ev->ev_type = SRPC_REPLY_SENT;
 
-	msg->msg_magic   = SRPC_MSG_MAGIC;
+	msg->msg_magic = SRPC_MSG_MAGIC;
 	msg->msg_version = SRPC_MSG_VERSION;
-	msg->msg_type    = srpc_service2reply(sv->sv_id);
+	msg->msg_type = srpc_service2reply(sv->sv_id);
 
 	rc = srpc_post_active_rdma(SRPC_RDMA_PORTAL, rpyid, msg,
 				   sizeof(*msg), LNET_MD_OP_PUT,
@@ -1464,7 +1464,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 		spin_lock(&crpc->crpc_lock);
 
 		LASSERT(!rpcev->ev_fired);
-		rpcev->ev_fired  = 1;
+		rpcev->ev_fired = 1;
 		rpcev->ev_status = (ev->type == LNET_EVENT_UNLINK) ?
 						-EINTR : ev->status;
 		swi_schedule_workitem(&crpc->crpc_wi);
@@ -1582,13 +1582,13 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 		}
 	case SRPC_REPLY_SENT:
 		srpc = rpcev->ev_data;
-		scd  = srpc->srpc_scd;
+		scd = srpc->srpc_scd;
 
 		LASSERT(rpcev == &srpc->srpc_ev);
 
 		spin_lock(&scd->scd_lock);
 
-		rpcev->ev_fired  = 1;
+		rpcev->ev_fired = 1;
 		rpcev->ev_status = (ev->type == LNET_EVENT_UNLINK) ?
 				   -EINTR : ev->status;
 		swi_schedule_workitem(&srpc->srpc_wi);
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index b605f7f..7a22bd3 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -472,9 +472,9 @@ static inline void
 swi_init_workitem(swi_workitem_t *swi, void *data,
 		  swi_action_t action, struct cfs_wi_sched *sched)
 {
-	swi->swi_sched  = sched;
+	swi->swi_sched = sched;
 	swi->swi_action = action;
-	swi->swi_state  = SWI_STATE_NEWBORN;
+	swi->swi_state = SWI_STATE_NEWBORN;
 	cfs_wi_init(&swi->swi_workitem, data, swi_wi_action);
 }
 
@@ -531,13 +531,13 @@ srpc_init_client_rpc(srpc_client_rpc_t *rpc, lnet_process_id_t peer,
 	spin_lock_init(&rpc->crpc_lock);
 	atomic_set(&rpc->crpc_refcount, 1); /* 1 ref for caller */
 
-	rpc->crpc_dest         = peer;
-	rpc->crpc_priv         = priv;
-	rpc->crpc_service      = service;
-	rpc->crpc_bulk.bk_len  = bulklen;
+	rpc->crpc_dest = peer;
+	rpc->crpc_priv = priv;
+	rpc->crpc_service = service;
+	rpc->crpc_bulk.bk_len = bulklen;
 	rpc->crpc_bulk.bk_niov = nbulkiov;
-	rpc->crpc_done         = rpc_done;
-	rpc->crpc_fini         = rpc_fini;
+	rpc->crpc_done = rpc_done;
+	rpc->crpc_fini = rpc_fini;
 	LNetInvalidateHandle(&rpc->crpc_reqstmdh);
 	LNetInvalidateHandle(&rpc->crpc_replymdh);
 	LNetInvalidateHandle(&rpc->crpc_bulk.bk_mdh);
@@ -547,9 +547,9 @@ srpc_init_client_rpc(srpc_client_rpc_t *rpc, lnet_process_id_t peer,
 	rpc->crpc_reqstev.ev_fired = 1;
 	rpc->crpc_replyev.ev_fired = 1;
 
-	rpc->crpc_reqstmsg.msg_magic   = SRPC_MSG_MAGIC;
+	rpc->crpc_reqstmsg.msg_magic = SRPC_MSG_MAGIC;
 	rpc->crpc_reqstmsg.msg_version = SRPC_MSG_VERSION;
-	rpc->crpc_reqstmsg.msg_type    = srpc_service2request(service);
+	rpc->crpc_reqstmsg.msg_type = srpc_service2request(service);
 }
 
 static inline const char *
-- 
1.7.1
