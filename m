From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:48 -0400
Subject: [lustre-devel] [PATCH 22/24] staging: lustre: selftest: convert
	srpc_msg_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef struct srpc_msg to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c  |    8 ++++----
 drivers/staging/lustre/lnet/selftest/conrpc.c    |   14 +++++++-------
 drivers/staging/lustre/lnet/selftest/conrpc.h    |    2 +-
 drivers/staging/lustre/lnet/selftest/console.c   |   10 +++++-----
 drivers/staging/lustre/lnet/selftest/framework.c |   14 +++++++-------
 drivers/staging/lustre/lnet/selftest/ping_test.c |    4 ++--
 drivers/staging/lustre/lnet/selftest/rpc.c       |   11 ++++++-----
 drivers/staging/lustre/lnet/selftest/rpc.h       |    6 +++---
 drivers/staging/lustre/lnet/selftest/selftest.h  |   10 +++++-----
 9 files changed, 40 insertions(+), 39 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 3455990..02c8dae 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -318,7 +318,7 @@ brw_client_done_rpc(struct sfw_test_unit *tsu, struct srpc_client_rpc *rpc)
 	__u64 magic = BRW_MAGIC;
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct sfw_session *sn = tsi->tsi_batch->bat_session;
-	srpc_msg_t *msg = &rpc->crpc_replymsg;
+	struct srpc_msg *msg = &rpc->crpc_replymsg;
 	srpc_brw_reply_t *reply = &msg->msg_body.brw_reply;
 	srpc_brw_reqst_t *reqst = &rpc->crpc_reqstmsg.msg_body.brw_reqst;
 
@@ -384,7 +384,7 @@ brw_bulk_ready(struct srpc_server_rpc *rpc, int status)
 	__u64 magic = BRW_MAGIC;
 	srpc_brw_reply_t *reply = &rpc->srpc_replymsg.msg_body.brw_reply;
 	srpc_brw_reqst_t *reqst;
-	srpc_msg_t *reqstmsg;
+	struct srpc_msg *reqstmsg;
 
 	LASSERT(rpc->srpc_bulk);
 	LASSERT(rpc->srpc_reqstbuf);
@@ -418,8 +418,8 @@ static int
 brw_server_handle(struct srpc_server_rpc *rpc)
 {
 	struct srpc_service *sv = rpc->srpc_scd->scd_svc;
-	srpc_msg_t *replymsg = &rpc->srpc_replymsg;
-	srpc_msg_t *reqstmsg = &rpc->srpc_reqstbuf->buf_msg;
+	struct srpc_msg *replymsg = &rpc->srpc_replymsg;
+	struct srpc_msg *reqstmsg = &rpc->srpc_reqstbuf->buf_msg;
 	srpc_brw_reply_t *reply = &replymsg->msg_body.brw_reply;
 	srpc_brw_reqst_t *reqst = &reqstmsg->msg_body.brw_reqst;
 	int npg;
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 5cec1c9..caaae8c 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -46,7 +46,7 @@
 #include "conrpc.h"
 #include "console.h"
 
-void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, srpc_msg_t *,
+void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 			   struct lstcon_node *, lstcon_trans_stat_t *);
 
 static void
@@ -386,7 +386,7 @@ lstcon_rpc_trans_postwait(struct lstcon_rpc_trans *trans, int timeout)
 }
 
 static int
-lstcon_rpc_get_reply(struct lstcon_rpc *crpc, srpc_msg_t **msgpp)
+lstcon_rpc_get_reply(struct lstcon_rpc *crpc, struct srpc_msg **msgpp)
 {
 	struct lstcon_node *nd = crpc->crp_node;
 	struct srpc_client_rpc *rpc = crpc->crp_rpc;
@@ -426,7 +426,7 @@ void
 lstcon_rpc_trans_stat(struct lstcon_rpc_trans *trans, lstcon_trans_stat_t *stat)
 {
 	struct lstcon_rpc *crpc;
-	srpc_msg_t *rep;
+	struct srpc_msg *rep;
 	int error;
 
 	LASSERT(stat);
@@ -475,7 +475,7 @@ lstcon_rpc_trans_interpreter(struct lstcon_rpc_trans *trans,
 	lstcon_rpc_ent_t *ent;
 	srpc_generic_reply_t *rep;
 	struct lstcon_rpc *crpc;
-	srpc_msg_t *msg;
+	struct srpc_msg *msg;
 	struct lstcon_node *nd;
 	long dur;
 	struct timeval tv;
@@ -916,7 +916,7 @@ lstcon_testrpc_prep(struct lstcon_node *nd, int transop, unsigned feats,
 
 static int
 lstcon_sesnew_stat_reply(struct lstcon_rpc_trans *trans,
-			 struct lstcon_node *nd, srpc_msg_t *reply)
+			 struct lstcon_node *nd, struct srpc_msg *reply)
 {
 	srpc_mksn_reply_t *mksn_rep = &reply->msg_body.mksn_reply;
 	int status = mksn_rep->mksn_status;
@@ -962,7 +962,7 @@ lstcon_sesnew_stat_reply(struct lstcon_rpc_trans *trans,
 }
 
 void
-lstcon_rpc_stat_reply(struct lstcon_rpc_trans *trans, srpc_msg_t *msg,
+lstcon_rpc_stat_reply(struct lstcon_rpc_trans *trans, struct srpc_msg *msg,
 		      struct lstcon_node *nd, lstcon_trans_stat_t *stat)
 {
 	srpc_rmsn_reply_t *rmsn_rep;
@@ -1172,7 +1172,7 @@ lstcon_rpc_pinger(void *arg)
 	struct stt_timer *ptimer = (struct stt_timer *)arg;
 	struct lstcon_rpc_trans *trans;
 	struct lstcon_rpc *crpc;
-	srpc_msg_t *rep;
+	struct srpc_msg *rep;
 	srpc_debug_reqst_t *drq;
 	struct lstcon_ndlink *ndl;
 	struct lstcon_node *nd;
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index 7281abd..90c3385 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -106,7 +106,7 @@ struct lstcon_rpc_trans {
 #define LST_TRANS_STATQRY	0x21
 
 typedef int (*lstcon_rpc_cond_func_t)(int, struct lstcon_node *, void *);
-typedef int (*lstcon_rpc_readent_func_t)(int, srpc_msg_t *,
+typedef int (*lstcon_rpc_readent_func_t)(int, struct srpc_msg *,
 					 lstcon_rpc_ent_t __user *);
 
 int  lstcon_sesrpc_prep(struct lstcon_node *nd, int transop,
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index cdbcee7..6568e8e 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -370,7 +370,7 @@ lstcon_sesrpc_condition(int transop, struct lstcon_node *nd, void *arg)
 }
 
 static int
-lstcon_sesrpc_readent(int transop, srpc_msg_t *msg,
+lstcon_sesrpc_readent(int transop, struct srpc_msg *msg,
 		      lstcon_rpc_ent_t __user *ent_up)
 {
 	srpc_debug_reply_t *rep;
@@ -1383,7 +1383,7 @@ lstcon_test_find(struct lstcon_batch *batch, int idx, struct lstcon_test **testp
 }
 
 static int
-lstcon_tsbrpc_readent(int transop, srpc_msg_t *msg,
+lstcon_tsbrpc_readent(int transop, struct srpc_msg *msg,
 		      lstcon_rpc_ent_t __user *ent_up)
 {
 	srpc_batch_reply_t *rep = &msg->msg_body.bat_reply;
@@ -1462,7 +1462,7 @@ lstcon_test_batch_query(char *name, int testidx, int client,
 }
 
 static int
-lstcon_statrpc_readent(int transop, srpc_msg_t *msg,
+lstcon_statrpc_readent(int transop, struct srpc_msg *msg,
 		       lstcon_rpc_ent_t __user *ent_up)
 {
 	srpc_stat_reply_t *rep = &msg->msg_body.stat_reply;
@@ -1905,8 +1905,8 @@ lstcon_session_feats_check(unsigned feats)
 static int
 lstcon_acceptor_handle(struct srpc_server_rpc *rpc)
 {
-	srpc_msg_t *rep	= &rpc->srpc_replymsg;
-	srpc_msg_t *req	= &rpc->srpc_reqstbuf->buf_msg;
+	struct srpc_msg *rep	= &rpc->srpc_replymsg;
+	struct srpc_msg *req	= &rpc->srpc_reqstbuf->buf_msg;
 	srpc_join_reqst_t *jreq = &req->msg_body.join_reqst;
 	srpc_join_reply_t *jrep = &rep->msg_body.join_reply;
 	struct lstcon_group *grp = NULL;
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 56bcc8c..f66da54 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -405,7 +405,7 @@ int
 sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
-	srpc_msg_t *msg = container_of(request, srpc_msg_t,
+	struct srpc_msg *msg = container_of(request, struct srpc_msg,
 				       msg_body.mksn_reqst);
 	int cplen = 0;
 
@@ -438,7 +438,7 @@ sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
 	/*
 	 * reject the request if it requires unknown features
 	 * NB: old version will always accept all features because it's not
-	 * aware of srpc_msg_t::msg_ses_feats, it's a defect but it's also
+	 * aware of srpc_msg::msg_ses_feats, it's a defect but it's also
 	 * harmless because it will return zero feature to console, and it's
 	 * console's responsibility to make sure all nodes in a session have
 	 * same feature mask.
@@ -685,7 +685,7 @@ sfw_destroy_session(struct sfw_session *sn)
 }
 
 static void
-sfw_unpack_addtest_req(srpc_msg_t *msg)
+sfw_unpack_addtest_req(struct srpc_msg *msg)
 {
 	srpc_test_reqst_t *req = &msg->msg_body.tes_reqst;
 
@@ -731,7 +731,7 @@ sfw_unpack_addtest_req(srpc_msg_t *msg)
 static int
 sfw_add_test_instance(struct sfw_batch *tsb, struct srpc_server_rpc *rpc)
 {
-	srpc_msg_t *msg = &rpc->srpc_reqstbuf->buf_msg;
+	struct srpc_msg *msg = &rpc->srpc_reqstbuf->buf_msg;
 	srpc_test_reqst_t *req = &msg->msg_body.tes_reqst;
 	struct srpc_bulk *bk = rpc->srpc_bulk;
 	int ndest = req->tsr_ndest;
@@ -1227,8 +1227,8 @@ static int
 sfw_handle_server_rpc(struct srpc_server_rpc *rpc)
 {
 	struct srpc_service *sv = rpc->srpc_scd->scd_svc;
-	srpc_msg_t *reply = &rpc->srpc_replymsg;
-	srpc_msg_t *request = &rpc->srpc_reqstbuf->buf_msg;
+	struct srpc_msg *reply = &rpc->srpc_replymsg;
+	struct srpc_msg *request = &rpc->srpc_reqstbuf->buf_msg;
 	unsigned features = LST_FEATS_MASK;
 	int rc = 0;
 
@@ -1415,7 +1415,7 @@ sfw_create_rpc(lnet_process_id_t peer, int service,
 }
 
 void
-sfw_unpack_message(srpc_msg_t *msg)
+sfw_unpack_message(struct srpc_msg *msg)
 {
 	if (msg->msg_magic == SRPC_MSG_MAGIC)
 		return; /* no flipping needed */
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index c6f2caa..8a9d7a4 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -171,8 +171,8 @@ static int
 ping_server_handle(struct srpc_server_rpc *rpc)
 {
 	struct srpc_service *sv = rpc->srpc_scd->scd_svc;
-	srpc_msg_t *reqstmsg = &rpc->srpc_reqstbuf->buf_msg;
-	srpc_msg_t *replymsg = &rpc->srpc_replymsg;
+	struct srpc_msg *reqstmsg = &rpc->srpc_reqstbuf->buf_msg;
+	struct srpc_msg *replymsg = &rpc->srpc_replymsg;
 	srpc_ping_reqst_t *req = &reqstmsg->msg_body.ping_reqst;
 	srpc_ping_reply_t *rep = &rpc->srpc_replymsg.msg_body.ping_reply;
 
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 1e2fd8a..d9f8c64 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -803,7 +803,7 @@ srpc_send_request(struct srpc_client_rpc *rpc)
 
 	 rc = srpc_post_active_rdma(srpc_serv_portal(rpc->crpc_service),
 				    rpc->crpc_service, &rpc->crpc_reqstmsg,
-				    sizeof(srpc_msg_t), LNET_MD_OP_PUT,
+				    sizeof(struct srpc_msg), LNET_MD_OP_PUT,
 				    rpc->crpc_dest, LNET_NID_ANY,
 				    &rpc->crpc_reqstmdh, ev);
 	if (rc) {
@@ -827,7 +827,8 @@ srpc_prepare_reply(struct srpc_client_rpc *rpc)
 	*id = srpc_next_id();
 
 	rc = srpc_post_passive_rdma(SRPC_RDMA_PORTAL, 0, *id,
-				    &rpc->crpc_replymsg, sizeof(srpc_msg_t),
+				    &rpc->crpc_replymsg,
+				    sizeof(struct srpc_msg),
 				    LNET_MD_OP_PUT, rpc->crpc_dest,
 				    &rpc->crpc_replymdh, ev);
 	if (rc) {
@@ -995,7 +996,7 @@ srpc_handle_rpc(struct swi_workitem *wi)
 	default:
 		LBUG();
 	case SWI_STATE_NEWBORN: {
-		srpc_msg_t *msg;
+		struct srpc_msg *msg;
 		srpc_generic_reply_t *reply;
 
 		msg = &rpc->srpc_reqstbuf->buf_msg;
@@ -1179,7 +1180,7 @@ srpc_send_rpc(struct swi_workitem *wi)
 {
 	int rc = 0;
 	struct srpc_client_rpc *rpc;
-	srpc_msg_t *reply;
+	struct srpc_msg *reply;
 	int do_bulk;
 
 	LASSERT(wi);
@@ -1415,7 +1416,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 	struct srpc_server_rpc *srpc;
 	struct srpc_buffer *buffer;
 	struct srpc_service *sv;
-	srpc_msg_t *msg;
+	struct srpc_msg *msg;
 	srpc_msg_type_t type;
 
 	LASSERT(!in_interrupt());
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index a79c315..fdf881f 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -242,7 +242,7 @@ typedef struct {
 #define SRPC_MSG_MAGIC		0xeeb0f00d
 #define SRPC_MSG_VERSION	1
 
-typedef struct srpc_msg {
+struct srpc_msg {
 	__u32	msg_magic;     /* magic number */
 	__u32	msg_version;   /* message version number */
 	__u32	msg_type;      /* type of message body: srpc_msg_type_t */
@@ -273,10 +273,10 @@ typedef struct srpc_msg {
 		srpc_brw_reqst_t     brw_reqst;
 		srpc_brw_reply_t     brw_reply;
 	}     msg_body;
-} WIRE_ATTR srpc_msg_t;
+} WIRE_ATTR;
 
 static inline void
-srpc_unpack_msg_hdr(srpc_msg_t *msg)
+srpc_unpack_msg_hdr(struct srpc_msg *msg)
 {
 	if (msg->msg_magic == SRPC_MSG_MAGIC)
 		return; /* no flipping needed */
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 1a47772..2bc7f9f 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -166,7 +166,7 @@ struct srpc_bulk {
 /* message buffer descriptor */
 struct srpc_buffer {
 	struct list_head  buf_list; /* chain on srpc_service::*_msgq */
-	srpc_msg_t	  buf_msg;
+	struct srpc_msg	  buf_msg;
 	lnet_handle_md_t  buf_mdh;
 	lnet_nid_t	  buf_self;
 	lnet_process_id_t buf_peer;
@@ -191,7 +191,7 @@ struct srpc_server_rpc {
 	struct srpc_event	srpc_ev;	/* bulk/reply event */
 	lnet_nid_t	       srpc_self;
 	lnet_process_id_t      srpc_peer;
-	srpc_msg_t	       srpc_replymsg;
+	struct srpc_msg		srpc_replymsg;
 	lnet_handle_md_t       srpc_replymdh;
 	struct srpc_buffer	*srpc_reqstbuf;
 	struct srpc_bulk	*srpc_bulk;
@@ -227,8 +227,8 @@ struct srpc_client_rpc {
 	struct srpc_event	crpc_replyev;	/* reply event */
 
 	/* bulk, request(reqst), and reply exchanged on wire */
-	srpc_msg_t	  crpc_reqstmsg;
-	srpc_msg_t	  crpc_replymsg;
+	struct srpc_msg		crpc_reqstmsg;
+	struct srpc_msg		crpc_replymsg;
 	lnet_handle_md_t  crpc_reqstmdh;
 	lnet_handle_md_t  crpc_replymdh;
 	struct srpc_bulk	crpc_bulk;
@@ -423,7 +423,7 @@ int sfw_create_test_rpc(struct sfw_test_unit *tsu,
 void sfw_abort_rpc(struct srpc_client_rpc *rpc);
 void sfw_post_rpc(struct srpc_client_rpc *rpc);
 void sfw_client_rpc_done(struct srpc_client_rpc *rpc);
-void sfw_unpack_message(srpc_msg_t *msg);
+void sfw_unpack_message(struct srpc_msg *msg);
 void sfw_free_pages(struct srpc_server_rpc *rpc);
 void sfw_add_bulk_page(struct srpc_bulk *bk, struct page *pg, int i);
 int sfw_alloc_pages(struct srpc_server_rpc *rpc, int cpt, int npages, int len,
-- 
1.7.1
