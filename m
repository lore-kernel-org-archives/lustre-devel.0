From: James Simmons <jsimmons@infradead.org>
Date: Fri, 11 Mar 2016 20:29:45 -0500
Subject: [lustre-devel] [PATCH 04/10] staging: lustre: remove extra spacing
	of variable declartions for lnet selftest
In-Reply-To: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
References: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457746191-27981-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Remove any extra spacing such as "int   rc" to "int rc" to match
the proper kernel style

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c  |   28 ++++++++--------
 drivers/staging/lustre/lnet/selftest/conctl.c    |   36 ++++++++++----------
 drivers/staging/lustre/lnet/selftest/conrpc.c    |   40 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/console.c   |   30 ++++++++--------
 drivers/staging/lustre/lnet/selftest/ping_test.c |    2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c       |    8 ++--
 6 files changed, 72 insertions(+), 72 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 18c7422..6b1f983 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -51,8 +51,8 @@ MODULE_PARM_DESC(brw_inject_errors, "# data errors to inject randomly, zero by d
 static void
 brw_client_fini(sfw_test_instance_t *tsi)
 {
-	srpc_bulk_t     *bulk;
-	sfw_test_unit_t *tsu;
+	srpc_bulk_t *bulk;
+	sfw_test_unit_t	*tsu;
 
 	LASSERT(tsi->tsi_is_client);
 
@@ -69,19 +69,19 @@ brw_client_fini(sfw_test_instance_t *tsi)
 static int
 brw_client_init(sfw_test_instance_t *tsi)
 {
-	sfw_session_t	 *sn = tsi->tsi_batch->bat_session;
-	int		  flags;
-	int		  npg;
-	int		  len;
-	int		  opc;
-	srpc_bulk_t	 *bulk;
-	sfw_test_unit_t	 *tsu;
+	sfw_session_t *sn = tsi->tsi_batch->bat_session;
+	int flags;
+	int npg;
+	int len;
+	int opc;
+	srpc_bulk_t *bulk;
+	sfw_test_unit_t *tsu;
 
 	LASSERT(sn);
 	LASSERT(tsi->tsi_is_client);
 
 	if (!(sn->sn_features & LST_FEAT_BULK_LEN)) {
-		test_bulk_req_t  *breq = &tsi->tsi_u.bulk_v0;
+		test_bulk_req_t *breq = &tsi->tsi_u.bulk_v0;
 
 		opc   = breq->blk_opc;
 		flags = breq->blk_flags;
@@ -155,7 +155,7 @@ static void
 brw_fill_page(struct page *pg, int pattern, __u64 magic)
 {
 	char *addr = page_address(pg);
-	int   i;
+	int i;
 
 	LASSERT(addr);
 
@@ -184,9 +184,9 @@ brw_fill_page(struct page *pg, int pattern, __u64 magic)
 static int
 brw_check_page(struct page *pg, int pattern, __u64 magic)
 {
-	char  *addr = page_address(pg);
-	__u64  data = 0; /* make compiler happy */
-	int    i;
+	char *addr = page_address(pg);
+	__u64 data = 0; /* make compiler happy */
+	int i;
 
 	LASSERT(addr);
 
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 62cacb6..9793bc6 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -115,9 +115,9 @@ lst_session_info_ioctl(lstio_session_info_args_t *args)
 static int
 lst_debug_ioctl(lstio_debug_args_t *args)
 {
-	char   *name   = NULL;
-	int     client = 1;
-	int     rc;
+	char *name = NULL;
+	int client = 1;
+	int rc;
 
 	if (args->lstio_dbg_key != console_session.ses_key)
 		return -EACCES;
@@ -229,8 +229,8 @@ lst_group_add_ioctl(lstio_group_add_args_t *args)
 static int
 lst_group_del_ioctl(lstio_group_del_args_t *args)
 {
-	int     rc;
-	char   *name;
+	int rc;
+	char *name;
 
 	if (args->lstio_grp_key != console_session.ses_key)
 		return -EACCES;
@@ -262,8 +262,8 @@ lst_group_del_ioctl(lstio_group_del_args_t *args)
 static int
 lst_group_update_ioctl(lstio_group_update_args_t *args)
 {
-	int     rc;
-	char   *name;
+	int rc;
+	char *name;
 
 	if (args->lstio_grp_key != console_session.ses_key)
 		return -EACCES;
@@ -547,8 +547,8 @@ lst_batch_stop_ioctl(lstio_batch_stop_args_t *args)
 static int
 lst_batch_query_ioctl(lstio_batch_query_args_t *args)
 {
-	char   *name;
-	int     rc;
+	char *name;
+	int rc;
 
 	if (args->lstio_bat_key != console_session.ses_key)
 		return -EACCES;
@@ -714,12 +714,12 @@ lst_stat_query_ioctl(lstio_stat_args_t *args)
 
 static int lst_test_add_ioctl(lstio_test_args_t *args)
 {
-	char		*batch_name;
-	char		*src_name = NULL;
-	char		*dst_name = NULL;
-	void		*param = NULL;
-	int		ret = 0;
-	int		rc = -ENOMEM;
+	char *batch_name;
+	char *src_name = NULL;
+	char *dst_name = NULL;
+	void *param = NULL;
+	int ret = 0;
+	int rc = -ENOMEM;
 
 	if (!args->lstio_tes_resultp ||
 	    !args->lstio_tes_retp ||
@@ -807,10 +807,10 @@ out:
 int
 lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
 {
-	char   *buf;
+	char *buf;
 	struct libcfs_ioctl_data *data;
-	int     opc;
-	int     rc;
+	int opc;
+	int rc;
 
 	if (cmd != IOC_LIBCFS_LNETST)
 		return -EINVAL;
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index f2afa13..77ea41b 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -288,8 +288,8 @@ void
 lstcon_rpc_trans_abort(lstcon_rpc_trans_t *trans, int error)
 {
 	srpc_client_rpc_t *rpc;
-	lstcon_rpc_t      *crpc;
-	lstcon_node_t     *nd;
+	lstcon_rpc_t *crpc;
+	lstcon_node_t *nd;
 
 	list_for_each_entry(crpc, &trans->tas_rpcs_list, crp_link) {
 		rpc = crpc->crp_rpc;
@@ -388,7 +388,7 @@ lstcon_rpc_trans_postwait(lstcon_rpc_trans_t *trans, int timeout)
 static int
 lstcon_rpc_get_reply(lstcon_rpc_t *crpc, srpc_msg_t **msgpp)
 {
-	lstcon_node_t *nd  = crpc->crp_node;
+	lstcon_node_t *nd = crpc->crp_node;
 	srpc_client_rpc_t *rpc = crpc->crp_rpc;
 	srpc_generic_reply_t *rep;
 
@@ -425,7 +425,7 @@ lstcon_rpc_get_reply(lstcon_rpc_t *crpc, srpc_msg_t **msgpp)
 void
 lstcon_rpc_trans_stat(lstcon_rpc_trans_t *trans, lstcon_trans_stat_t *stat)
 {
-	lstcon_rpc_t  *crpc;
+	lstcon_rpc_t *crpc;
 	srpc_msg_t *rep;
 	int error;
 
@@ -654,9 +654,9 @@ int
 lstcon_batrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 		   lstcon_tsb_hdr_t *tsb, lstcon_rpc_t **crpc)
 {
-	lstcon_batch_t	   *batch;
+	lstcon_batch_t *batch;
 	srpc_batch_reqst_t *brq;
-	int		    rc;
+	int rc;
 
 	rc = lstcon_rpc_prep(nd, SRPC_SERVICE_BATCH, feats, 0, 0, crpc);
 	if (rc)
@@ -687,7 +687,7 @@ int
 lstcon_statrpc_prep(lstcon_node_t *nd, unsigned feats, lstcon_rpc_t **crpc)
 {
 	srpc_stat_reqst_t *srq;
-	int		   rc;
+	int rc;
 
 	rc = lstcon_rpc_prep(nd, SRPC_SERVICE_QUERY_STAT, feats, 0, 0, crpc);
 	if (rc)
@@ -811,14 +811,14 @@ int
 lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 		    lstcon_test_t *test, lstcon_rpc_t **crpc)
 {
-	lstcon_group_t    *sgrp = test->tes_src_grp;
-	lstcon_group_t    *dgrp = test->tes_dst_grp;
+	lstcon_group_t *sgrp = test->tes_src_grp;
+	lstcon_group_t *dgrp = test->tes_dst_grp;
 	srpc_test_reqst_t *trq;
-	srpc_bulk_t       *bulk;
-	int                i;
-	int		   npg = 0;
-	int		   nob = 0;
-	int		   rc  = 0;
+	srpc_bulk_t *bulk;
+	int i;
+	int npg = 0;
+	int nob = 0;
+	int rc  = 0;
 
 	if (transop == LST_TRANS_TSBCLIADD) {
 		npg = sfw_id_pages(test->tes_span);
@@ -847,7 +847,7 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 		bulk = &(*crpc)->crp_rpc->crpc_bulk;
 
 		for (i = 0; i < npg; i++) {
-			int	len;
+			int len;
 
 			LASSERT(nob > 0);
 
@@ -922,7 +922,7 @@ lstcon_sesnew_stat_reply(lstcon_rpc_trans_t *trans,
 			 lstcon_node_t *nd, srpc_msg_t *reply)
 {
 	srpc_mksn_reply_t *mksn_rep = &reply->msg_body.mksn_reply;
-	int		   status   = mksn_rep->mksn_status;
+	int status = mksn_rep->mksn_status;
 
 	if (!status &&
 	    (reply->msg_ses_feats & ~LST_FEATS_MASK)) {
@@ -968,12 +968,12 @@ void
 lstcon_rpc_stat_reply(lstcon_rpc_trans_t *trans, srpc_msg_t *msg,
 		      lstcon_node_t *nd, lstcon_trans_stat_t *stat)
 {
-	srpc_rmsn_reply_t  *rmsn_rep;
+	srpc_rmsn_reply_t *rmsn_rep;
 	srpc_debug_reply_t *dbg_rep;
 	srpc_batch_reply_t *bat_rep;
-	srpc_test_reply_t  *test_rep;
-	srpc_stat_reply_t  *stat_rep;
-	int                rc = 0;
+	srpc_test_reply_t *test_rep;
+	srpc_stat_reply_t *stat_rep;
+	int rc = 0;
 
 	switch (trans->tas_opc) {
 	case LST_TRANS_SESNEW:
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index b0c9acd..aac159b 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -71,7 +71,7 @@ lstcon_node_get(lstcon_node_t *nd)
 static int
 lstcon_node_find(lnet_process_id_t id, lstcon_node_t **ndpp, int create)
 {
-	lstcon_ndlink_t *ndl;
+	lstcon_ndlink_t	*ndl;
 	unsigned int idx = LNET_NIDADDR(id.nid) % LST_GLOBAL_HASHSIZE;
 
 	LASSERT(id.nid != LNET_NID_ANY);
@@ -403,7 +403,7 @@ lstcon_group_nodes_add(lstcon_group_t *grp,
 		       unsigned *featp, struct list_head __user *result_up)
 {
 	lstcon_rpc_trans_t *trans;
-	lstcon_ndlink_t *ndl;
+	lstcon_ndlink_t	*ndl;
 	lstcon_group_t *tmp;
 	lnet_process_id_t id;
 	int i;
@@ -935,7 +935,7 @@ lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
 	struct list_head *srvlst;
 	lstcon_test_t *test = NULL;
 	lstcon_batch_t *bat;
-	lstcon_ndlink_t *ndl;
+	lstcon_ndlink_t	*ndl;
 	int rc;
 
 	rc = lstcon_batch_find(name, &bat);
@@ -1258,7 +1258,7 @@ static int
 lstcon_verify_group(const char *name, lstcon_group_t **grp)
 {
 	int rc;
-	lstcon_ndlink_t *ndl;
+	lstcon_ndlink_t	*ndl;
 
 	rc = lstcon_group_find(name, grp);
 	if (rc) {
@@ -1283,11 +1283,11 @@ lstcon_test_add(char *batch_name, int type, int loop,
 		void *param, int paramlen, int *retp,
 		struct list_head __user *result_up)
 {
-	lstcon_test_t	 *test	 = NULL;
-	int		 rc;
-	lstcon_group_t	 *src_grp = NULL;
-	lstcon_group_t	 *dst_grp = NULL;
-	lstcon_batch_t	 *batch = NULL;
+	lstcon_test_t *test = NULL;
+	int rc;
+	lstcon_group_t *src_grp = NULL;
+	lstcon_group_t *dst_grp = NULL;
+	lstcon_batch_t *batch = NULL;
 
 	/*
 	 * verify that a batch of the given name exists, and the groups
@@ -1535,7 +1535,7 @@ int
 lstcon_nodes_stat(int count, lnet_process_id_t __user *ids_up,
 		  int timeout, struct list_head __user *result_up)
 {
-	lstcon_ndlink_t *ndl;
+	lstcon_ndlink_t	*ndl;
 	lstcon_group_t *tmp;
 	lnet_process_id_t id;
 	int i;
@@ -1581,7 +1581,7 @@ lstcon_debug_ndlist(struct list_head *ndlist,
 		    int timeout, struct list_head __user *result_up)
 {
 	lstcon_rpc_trans_t *trans;
-	int		 rc;
+	int rc;
 
 	rc = lstcon_rpc_trans_ndlist(ndlist, translist, LST_TRANS_SESQRY,
 				     NULL, lstcon_sesrpc_condition, &trans);
@@ -1905,13 +1905,13 @@ lstcon_session_feats_check(unsigned feats)
 static int
 lstcon_acceptor_handle(struct srpc_server_rpc *rpc)
 {
-	srpc_msg_t *rep  = &rpc->srpc_replymsg;
-	srpc_msg_t *req  = &rpc->srpc_reqstbuf->buf_msg;
+	srpc_msg_t *rep	= &rpc->srpc_replymsg;
+	srpc_msg_t *req	= &rpc->srpc_reqstbuf->buf_msg;
 	srpc_join_reqst_t *jreq = &req->msg_body.join_reqst;
 	srpc_join_reply_t *jrep = &rep->msg_body.join_reply;
-	lstcon_group_t *grp  = NULL;
+	lstcon_group_t *grp = NULL;
 	lstcon_ndlink_t *ndl;
-	int rc   = 0;
+	int rc = 0;
 
 	sfw_unpack_message(req);
 
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index 33c758a..b5e69a7 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -170,7 +170,7 @@ ping_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 static int
 ping_server_handle(struct srpc_server_rpc *rpc)
 {
-	struct srpc_service *sv  = rpc->srpc_scd->scd_svc;
+	struct srpc_service *sv = rpc->srpc_scd->scd_svc;
 	srpc_msg_t *reqstmsg = &rpc->srpc_reqstbuf->buf_msg;
 	srpc_msg_t *replymsg = &rpc->srpc_replymsg;
 	srpc_ping_reqst_t *req = &reqstmsg->msg_body.ping_reqst;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 08a0ad5..1af978f 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -451,7 +451,7 @@ static int
 srpc_post_passive_rqtbuf(int service, int local, void *buf, int len,
 			 lnet_handle_md_t *mdh, srpc_event_t *ev)
 {
-	lnet_process_id_t any = {0};
+	lnet_process_id_t any = { 0 };
 
 	any.nid = LNET_NID_ANY;
 	any.pid = LNET_PID_ANY;
@@ -466,7 +466,7 @@ srpc_service_post_buffer(struct srpc_service_cd *scd, struct srpc_buffer *buf)
 	__must_hold(&scd->scd_lock)
 {
 	struct srpc_service *sv = scd->scd_svc;
-	struct srpc_msg *msg = &buf->buf_msg;
+	struct srpc_msg	*msg = &buf->buf_msg;
 	int rc;
 
 	LNetInvalidateHandle(&buf->buf_mdh);
@@ -842,7 +842,7 @@ srpc_prepare_bulk(srpc_client_rpc_t *rpc)
 {
 	srpc_bulk_t *bk = &rpc->crpc_bulk;
 	srpc_event_t *ev = &rpc->crpc_bulkev;
-	__u64	*id = &rpc->crpc_reqstmsg.msg_body.reqst.bulkid;
+	__u64 *id = &rpc->crpc_reqstmsg.msg_body.reqst.bulkid;
 	int rc;
 	int opt;
 
@@ -902,7 +902,7 @@ static void
 srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 {
 	struct srpc_service_cd *scd = rpc->srpc_scd;
-	struct srpc_service *sv  = scd->scd_svc;
+	struct srpc_service *sv = scd->scd_svc;
 	srpc_buffer_t *buffer;
 
 	LASSERT(status || rpc->srpc_wi.swi_state == SWI_STATE_DONE);
-- 
1.7.1
