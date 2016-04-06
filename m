From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:40 -0400
Subject: [lustre-devel] [PATCH 14/24] staging: lustre: selftest: convert
	lstcon_rpc_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef lstcon_rpc_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/conrpc.c  |   50 ++++++++++++------------
 drivers/staging/lustre/lnet/selftest/conrpc.h  |   18 ++++----
 drivers/staging/lustre/lnet/selftest/console.c |    2 +-
 3 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 0032457..edef693 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -52,7 +52,7 @@ void lstcon_rpc_stat_reply(lstcon_rpc_trans_t *, srpc_msg_t *,
 static void
 lstcon_rpc_done(struct srpc_client_rpc *rpc)
 {
-	lstcon_rpc_t *crpc = (lstcon_rpc_t *)rpc->crpc_priv;
+	struct lstcon_rpc *crpc = (struct lstcon_rpc *)rpc->crpc_priv;
 
 	LASSERT(crpc && rpc == crpc->crp_rpc);
 	LASSERT(crpc->crp_posted && !crpc->crp_finished);
@@ -91,7 +91,7 @@ lstcon_rpc_done(struct srpc_client_rpc *rpc)
 
 static int
 lstcon_rpc_init(lstcon_node_t *nd, int service, unsigned feats,
-		int bulk_npg, int bulk_len, int embedded, lstcon_rpc_t *crpc)
+		int bulk_npg, int bulk_len, int embedded, struct lstcon_rpc *crpc)
 {
 	crpc->crp_rpc = sfw_create_rpc(nd->nd_id, service,
 				       feats, bulk_npg, bulk_len,
@@ -116,15 +116,15 @@ lstcon_rpc_init(lstcon_node_t *nd, int service, unsigned feats,
 
 static int
 lstcon_rpc_prep(lstcon_node_t *nd, int service, unsigned feats,
-		int bulk_npg, int bulk_len, lstcon_rpc_t **crpcpp)
+		int bulk_npg, int bulk_len, struct lstcon_rpc **crpcpp)
 {
-	lstcon_rpc_t *crpc = NULL;
+	struct lstcon_rpc *crpc = NULL;
 	int rc;
 
 	spin_lock(&console_session.ses_rpc_lock);
 
 	crpc = list_first_entry_or_null(&console_session.ses_rpc_freelist,
-					lstcon_rpc_t, crp_link);
+					struct lstcon_rpc, crp_link);
 	if (crpc)
 		list_del_init(&crpc->crp_link);
 
@@ -148,7 +148,7 @@ lstcon_rpc_prep(lstcon_node_t *nd, int service, unsigned feats,
 }
 
 void
-lstcon_rpc_put(lstcon_rpc_t *crpc)
+lstcon_rpc_put(struct lstcon_rpc *crpc)
 {
 	struct srpc_bulk *bulk = &crpc->crp_rpc->crpc_bulk;
 	int i;
@@ -183,7 +183,7 @@ lstcon_rpc_put(lstcon_rpc_t *crpc)
 }
 
 static void
-lstcon_rpc_post(lstcon_rpc_t *crpc)
+lstcon_rpc_post(struct lstcon_rpc *crpc)
 {
 	lstcon_rpc_trans_t *trans = crpc->crp_trans;
 
@@ -278,7 +278,7 @@ lstcon_rpc_trans_prep(struct list_head *translist, int transop,
 }
 
 void
-lstcon_rpc_trans_addreq(lstcon_rpc_trans_t *trans, lstcon_rpc_t *crpc)
+lstcon_rpc_trans_addreq(lstcon_rpc_trans_t *trans, struct lstcon_rpc *crpc)
 {
 	list_add_tail(&crpc->crp_link, &trans->tas_rpcs_list);
 	crpc->crp_trans = trans;
@@ -288,7 +288,7 @@ void
 lstcon_rpc_trans_abort(lstcon_rpc_trans_t *trans, int error)
 {
 	struct srpc_client_rpc *rpc;
-	lstcon_rpc_t *crpc;
+	struct lstcon_rpc *crpc;
 	lstcon_node_t *nd;
 
 	list_for_each_entry(crpc, &trans->tas_rpcs_list, crp_link) {
@@ -338,7 +338,7 @@ lstcon_rpc_trans_check(lstcon_rpc_trans_t *trans)
 int
 lstcon_rpc_trans_postwait(lstcon_rpc_trans_t *trans, int timeout)
 {
-	lstcon_rpc_t *crpc;
+	struct lstcon_rpc *crpc;
 	int rc;
 
 	if (list_empty(&trans->tas_rpcs_list))
@@ -386,7 +386,7 @@ lstcon_rpc_trans_postwait(lstcon_rpc_trans_t *trans, int timeout)
 }
 
 static int
-lstcon_rpc_get_reply(lstcon_rpc_t *crpc, srpc_msg_t **msgpp)
+lstcon_rpc_get_reply(struct lstcon_rpc *crpc, srpc_msg_t **msgpp)
 {
 	lstcon_node_t *nd = crpc->crp_node;
 	struct srpc_client_rpc *rpc = crpc->crp_rpc;
@@ -425,7 +425,7 @@ lstcon_rpc_get_reply(lstcon_rpc_t *crpc, srpc_msg_t **msgpp)
 void
 lstcon_rpc_trans_stat(lstcon_rpc_trans_t *trans, lstcon_trans_stat_t *stat)
 {
-	lstcon_rpc_t *crpc;
+	struct lstcon_rpc *crpc;
 	srpc_msg_t *rep;
 	int error;
 
@@ -474,7 +474,7 @@ lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
 	struct list_head __user *next;
 	lstcon_rpc_ent_t *ent;
 	srpc_generic_reply_t *rep;
-	lstcon_rpc_t *crpc;
+	struct lstcon_rpc *crpc;
 	srpc_msg_t *msg;
 	lstcon_node_t *nd;
 	long dur;
@@ -542,8 +542,8 @@ void
 lstcon_rpc_trans_destroy(lstcon_rpc_trans_t *trans)
 {
 	struct srpc_client_rpc *rpc;
-	lstcon_rpc_t *crpc;
-	lstcon_rpc_t *tmp;
+	struct lstcon_rpc *crpc;
+	struct lstcon_rpc *tmp;
 	int count = 0;
 
 	list_for_each_entry_safe(crpc, tmp, &trans->tas_rpcs_list, crp_link) {
@@ -593,7 +593,7 @@ lstcon_rpc_trans_destroy(lstcon_rpc_trans_t *trans)
 
 int
 lstcon_sesrpc_prep(lstcon_node_t *nd, int transop,
-		   unsigned feats, lstcon_rpc_t **crpc)
+		   unsigned feats, struct lstcon_rpc **crpc)
 {
 	srpc_mksn_reqst_t *msrq;
 	srpc_rmsn_reqst_t *rsrq;
@@ -631,7 +631,7 @@ lstcon_sesrpc_prep(lstcon_node_t *nd, int transop,
 }
 
 int
-lstcon_dbgrpc_prep(lstcon_node_t *nd, unsigned feats, lstcon_rpc_t **crpc)
+lstcon_dbgrpc_prep(lstcon_node_t *nd, unsigned feats, struct lstcon_rpc **crpc)
 {
 	srpc_debug_reqst_t *drq;
 	int rc;
@@ -650,7 +650,7 @@ lstcon_dbgrpc_prep(lstcon_node_t *nd, unsigned feats, lstcon_rpc_t **crpc)
 
 int
 lstcon_batrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
-		   lstcon_tsb_hdr_t *tsb, lstcon_rpc_t **crpc)
+		   lstcon_tsb_hdr_t *tsb, struct lstcon_rpc **crpc)
 {
 	lstcon_batch_t *batch;
 	srpc_batch_reqst_t *brq;
@@ -682,7 +682,7 @@ lstcon_batrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 }
 
 int
-lstcon_statrpc_prep(lstcon_node_t *nd, unsigned feats, lstcon_rpc_t **crpc)
+lstcon_statrpc_prep(lstcon_node_t *nd, unsigned feats, struct lstcon_rpc **crpc)
 {
 	srpc_stat_reqst_t *srq;
 	int rc;
@@ -807,7 +807,7 @@ lstcon_bulkrpc_v1_prep(lst_test_bulk_param_t *param, srpc_test_reqst_t *req)
 
 int
 lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
-		    lstcon_test_t *test, lstcon_rpc_t **crpc)
+		    lstcon_test_t *test, struct lstcon_rpc **crpc)
 {
 	lstcon_group_t *sgrp = test->tes_src_grp;
 	lstcon_group_t *dgrp = test->tes_dst_grp;
@@ -1088,7 +1088,7 @@ lstcon_rpc_trans_ndlist(struct list_head *ndlist,
 	lstcon_rpc_trans_t *trans;
 	lstcon_ndlink_t *ndl;
 	lstcon_node_t *nd;
-	lstcon_rpc_t *rpc;
+	struct lstcon_rpc *rpc;
 	unsigned feats;
 	int rc;
 
@@ -1169,7 +1169,7 @@ lstcon_rpc_pinger(void *arg)
 {
 	struct stt_timer *ptimer = (struct stt_timer *)arg;
 	lstcon_rpc_trans_t *trans;
-	lstcon_rpc_t *crpc;
+	struct lstcon_rpc *crpc;
 	srpc_msg_t *rep;
 	srpc_debug_reqst_t *drq;
 	lstcon_ndlink_t *ndl;
@@ -1326,8 +1326,8 @@ void
 lstcon_rpc_cleanup_wait(void)
 {
 	lstcon_rpc_trans_t *trans;
-	lstcon_rpc_t *crpc;
-	lstcon_rpc_t *temp;
+	struct lstcon_rpc *crpc;
+	struct lstcon_rpc *temp;
 	struct list_head *pacer;
 	struct list_head zlist;
 
@@ -1369,7 +1369,7 @@ lstcon_rpc_cleanup_wait(void)
 
 	list_for_each_entry_safe(crpc, temp, &zlist, crp_link) {
 		list_del(&crpc->crp_link);
-		LIBCFS_FREE(crpc, sizeof(lstcon_rpc_t));
+		LIBCFS_FREE(crpc, sizeof(struct lstcon_rpc));
 	}
 }
 
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index 6ddf088..abd7bb0 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -63,7 +63,7 @@ struct lstcon_tsb_hdr;
 struct lstcon_test;
 struct lstcon_node;
 
-typedef struct lstcon_rpc {
+struct lstcon_rpc {
 	struct list_head	 crp_link;	/* chain on rpc transaction */
 	struct srpc_client_rpc	*crp_rpc;	/* client rpc */
 	struct lstcon_node	*crp_node;	/* destination node */
@@ -76,7 +76,7 @@ typedef struct lstcon_rpc {
 	unsigned int		 crp_embedded:1;
 	int			 crp_status;	/* console rpc errors */
 	unsigned long		 crp_stamp;	/* replied time stamp */
-} lstcon_rpc_t;
+};
 
 typedef struct lstcon_rpc_trans {
 	struct list_head  tas_olink;	     /* link chain on owner list */
@@ -110,16 +110,16 @@ typedef int (*lstcon_rpc_readent_func_t)(int, srpc_msg_t *,
 					 lstcon_rpc_ent_t __user *);
 
 int  lstcon_sesrpc_prep(struct lstcon_node *nd, int transop,
-			unsigned version, lstcon_rpc_t **crpc);
+			unsigned version, struct lstcon_rpc **crpc);
 int  lstcon_dbgrpc_prep(struct lstcon_node *nd,
-			unsigned version, lstcon_rpc_t **crpc);
+			unsigned version, struct lstcon_rpc **crpc);
 int  lstcon_batrpc_prep(struct lstcon_node *nd, int transop, unsigned version,
-			struct lstcon_tsb_hdr *tsb, lstcon_rpc_t **crpc);
+			struct lstcon_tsb_hdr *tsb, struct lstcon_rpc **crpc);
 int  lstcon_testrpc_prep(struct lstcon_node *nd, int transop, unsigned version,
-			 struct lstcon_test *test, lstcon_rpc_t **crpc);
+			 struct lstcon_test *test, struct lstcon_rpc **crpc);
 int  lstcon_statrpc_prep(struct lstcon_node *nd, unsigned version,
-			 lstcon_rpc_t **crpc);
-void lstcon_rpc_put(lstcon_rpc_t *crpc);
+			 struct lstcon_rpc **crpc);
+void lstcon_rpc_put(struct lstcon_rpc *crpc);
 int  lstcon_rpc_trans_prep(struct list_head *translist,
 			   int transop, lstcon_rpc_trans_t **transpp);
 int  lstcon_rpc_trans_ndlist(struct list_head *ndlist,
@@ -133,7 +133,7 @@ int  lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
 				  lstcon_rpc_readent_func_t readent);
 void lstcon_rpc_trans_abort(lstcon_rpc_trans_t *trans, int error);
 void lstcon_rpc_trans_destroy(lstcon_rpc_trans_t *trans);
-void lstcon_rpc_trans_addreq(lstcon_rpc_trans_t *trans, lstcon_rpc_t *req);
+void lstcon_rpc_trans_addreq(lstcon_rpc_trans_t *trans, struct lstcon_rpc *req);
 int  lstcon_rpc_trans_postwait(lstcon_rpc_trans_t *trans, int timeout);
 int  lstcon_rpc_pinger_start(void);
 void lstcon_rpc_pinger_stop(void);
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 1352310..23696e7 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -103,7 +103,7 @@ lstcon_node_find(lnet_process_id_t id, lstcon_node_t **ndpp, int create)
 	ndl->ndl_node->nd_stamp = cfs_time_current();
 	ndl->ndl_node->nd_state = LST_NODE_UNKNOWN;
 	ndl->ndl_node->nd_timeout = 0;
-	memset(&ndl->ndl_node->nd_ping, 0, sizeof(lstcon_rpc_t));
+	memset(&ndl->ndl_node->nd_ping, 0, sizeof(struct lstcon_rpc));
 
 	/*
 	 * queued in global hash & list, no refcount is taken by
-- 
1.7.1
