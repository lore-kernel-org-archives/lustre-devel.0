From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:32 -0400
Subject: [lustre-devel] [PATCH 06/24] staging: lustre: selftest: convert
	srpc_client_rpc_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef srpc_client_rpc_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c  |    6 ++--
 drivers/staging/lustre/lnet/selftest/conrpc.c    |    8 ++--
 drivers/staging/lustre/lnet/selftest/conrpc.h    |    2 +-
 drivers/staging/lustre/lnet/selftest/framework.c |   36 +++++++++---------
 drivers/staging/lustre/lnet/selftest/ping_test.c |    4 +-
 drivers/staging/lustre/lnet/selftest/rpc.c       |   32 ++++++++--------
 drivers/staging/lustre/lnet/selftest/selftest.h  |   42 +++++++++++-----------
 7 files changed, 65 insertions(+), 65 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index a3dec89..442f431 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -255,12 +255,12 @@ brw_check_bulk(struct srpc_bulk *bk, int pattern, __u64 magic)
 
 static int
 brw_client_prep_rpc(sfw_test_unit_t *tsu,
-		    lnet_process_id_t dest, srpc_client_rpc_t **rpcpp)
+		    lnet_process_id_t dest, struct srpc_client_rpc **rpcpp)
 {
 	struct srpc_bulk *bulk = tsu->tsu_private;
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
 	sfw_session_t *sn = tsi->tsi_batch->bat_session;
-	srpc_client_rpc_t *rpc;
+	struct srpc_client_rpc *rpc;
 	srpc_brw_reqst_t *req;
 	int flags;
 	int npg;
@@ -313,7 +313,7 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 }
 
 static void
-brw_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
+brw_client_done_rpc(sfw_test_unit_t *tsu, struct srpc_client_rpc *rpc)
 {
 	__u64 magic = BRW_MAGIC;
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 53da5cb..0032457 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -50,7 +50,7 @@ void lstcon_rpc_stat_reply(lstcon_rpc_trans_t *, srpc_msg_t *,
 			   lstcon_node_t *, lstcon_trans_stat_t *);
 
 static void
-lstcon_rpc_done(srpc_client_rpc_t *rpc)
+lstcon_rpc_done(struct srpc_client_rpc *rpc)
 {
 	lstcon_rpc_t *crpc = (lstcon_rpc_t *)rpc->crpc_priv;
 
@@ -287,7 +287,7 @@ lstcon_rpc_trans_addreq(lstcon_rpc_trans_t *trans, lstcon_rpc_t *crpc)
 void
 lstcon_rpc_trans_abort(lstcon_rpc_trans_t *trans, int error)
 {
-	srpc_client_rpc_t *rpc;
+	struct srpc_client_rpc *rpc;
 	lstcon_rpc_t *crpc;
 	lstcon_node_t *nd;
 
@@ -389,7 +389,7 @@ static int
 lstcon_rpc_get_reply(lstcon_rpc_t *crpc, srpc_msg_t **msgpp)
 {
 	lstcon_node_t *nd = crpc->crp_node;
-	srpc_client_rpc_t *rpc = crpc->crp_rpc;
+	struct srpc_client_rpc *rpc = crpc->crp_rpc;
 	srpc_generic_reply_t *rep;
 
 	LASSERT(nd && rpc);
@@ -541,7 +541,7 @@ lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
 void
 lstcon_rpc_trans_destroy(lstcon_rpc_trans_t *trans)
 {
-	srpc_client_rpc_t *rpc;
+	struct srpc_client_rpc *rpc;
 	lstcon_rpc_t *crpc;
 	lstcon_rpc_t *tmp;
 	int count = 0;
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index 3e7839d..6ddf088 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -65,7 +65,7 @@ struct lstcon_node;
 
 typedef struct lstcon_rpc {
 	struct list_head	 crp_link;	/* chain on rpc transaction */
-	srpc_client_rpc_t	*crp_rpc;	/* client rpc */
+	struct srpc_client_rpc	*crp_rpc;	/* client rpc */
 	struct lstcon_node	*crp_node;	/* destination node */
 	struct lstcon_rpc_trans *crp_trans;	/* conrpc transaction */
 
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index b2df184..6c0af58 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -298,7 +298,7 @@ sfw_server_rpc_done(struct srpc_server_rpc *rpc)
 }
 
 static void
-sfw_client_rpc_fini(srpc_client_rpc_t *rpc)
+sfw_client_rpc_fini(struct srpc_client_rpc *rpc)
 {
 	LASSERT(!rpc->crpc_bulk.bk_niov);
 	LASSERT(list_empty(&rpc->crpc_list));
@@ -526,7 +526,7 @@ sfw_debug_session(srpc_debug_reqst_t *request, srpc_debug_reply_t *reply)
 }
 
 static void
-sfw_test_rpc_fini(srpc_client_rpc_t *rpc)
+sfw_test_rpc_fini(struct srpc_client_rpc *rpc)
 {
 	sfw_test_unit_t *tsu = rpc->crpc_priv;
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
@@ -616,7 +616,7 @@ sfw_unload_test(struct sfw_test_instance *tsi)
 static void
 sfw_destroy_test_instance(sfw_test_instance_t *tsi)
 {
-	srpc_client_rpc_t *rpc;
+	struct srpc_client_rpc *rpc;
 	sfw_test_unit_t *tsu;
 
 	if (!tsi->tsi_is_client)
@@ -637,7 +637,7 @@ sfw_destroy_test_instance(sfw_test_instance_t *tsi)
 
 	while (!list_empty(&tsi->tsi_free_rpcs)) {
 		rpc = list_entry(tsi->tsi_free_rpcs.next,
-				 srpc_client_rpc_t, crpc_list);
+				 struct srpc_client_rpc, crpc_list);
 		list_del(&rpc->crpc_list);
 		LIBCFS_FREE(rpc, srpc_client_rpc_size(rpc));
 	}
@@ -866,7 +866,7 @@ sfw_test_unit_done(sfw_test_unit_t *tsu)
 }
 
 static void
-sfw_test_rpc_done(srpc_client_rpc_t *rpc)
+sfw_test_rpc_done(struct srpc_client_rpc *rpc)
 {
 	sfw_test_unit_t *tsu = rpc->crpc_priv;
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
@@ -902,9 +902,9 @@ sfw_test_rpc_done(srpc_client_rpc_t *rpc)
 int
 sfw_create_test_rpc(sfw_test_unit_t *tsu, lnet_process_id_t peer,
 		    unsigned features, int nblk, int blklen,
-		    srpc_client_rpc_t **rpcpp)
+		    struct srpc_client_rpc **rpcpp)
 {
-	srpc_client_rpc_t *rpc = NULL;
+	struct srpc_client_rpc *rpc = NULL;
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
 
 	spin_lock(&tsi->tsi_lock);
@@ -912,7 +912,7 @@ sfw_create_test_rpc(sfw_test_unit_t *tsu, lnet_process_id_t peer,
 	LASSERT(sfw_test_active(tsi));
 		/* pick request from buffer */
 	rpc = list_first_entry_or_null(&tsi->tsi_free_rpcs,
-				       srpc_client_rpc_t, crpc_list);
+				       struct srpc_client_rpc, crpc_list);
 	if (rpc) {
 		LASSERT(nblk == rpc->crpc_bulk.bk_niov);
 		list_del_init(&rpc->crpc_list);
@@ -946,7 +946,7 @@ sfw_run_test(struct swi_workitem *wi)
 {
 	sfw_test_unit_t *tsu = wi->swi_workitem.wi_data;
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
-	srpc_client_rpc_t *rpc = NULL;
+	struct srpc_client_rpc *rpc = NULL;
 
 	LASSERT(wi == &tsu->tsu_worker);
 
@@ -1029,7 +1029,7 @@ int
 sfw_stop_batch(sfw_batch_t *tsb, int force)
 {
 	sfw_test_instance_t *tsi;
-	srpc_client_rpc_t *rpc;
+	struct srpc_client_rpc *rpc;
 
 	if (!sfw_batch_active(tsb)) {
 		CDEBUG(D_NET, "Batch %llu inactive\n", tsb->bat_id.bat_id);
@@ -1377,12 +1377,12 @@ sfw_bulk_ready(struct srpc_server_rpc *rpc, int status)
 	return rc;
 }
 
-srpc_client_rpc_t *
+struct srpc_client_rpc *
 sfw_create_rpc(lnet_process_id_t peer, int service,
 	       unsigned features, int nbulkiov, int bulklen,
-	       void (*done)(srpc_client_rpc_t *), void *priv)
+	       void (*done)(struct srpc_client_rpc *), void *priv)
 {
-	srpc_client_rpc_t *rpc = NULL;
+	struct srpc_client_rpc *rpc = NULL;
 
 	spin_lock(&sfw_data.fw_lock);
 
@@ -1391,7 +1391,7 @@ sfw_create_rpc(lnet_process_id_t peer, int service,
 
 	if (!nbulkiov && !list_empty(&sfw_data.fw_zombie_rpcs)) {
 		rpc = list_entry(sfw_data.fw_zombie_rpcs.next,
-				 srpc_client_rpc_t, crpc_list);
+				 struct srpc_client_rpc, crpc_list);
 		list_del(&rpc->crpc_list);
 
 		srpc_init_client_rpc(rpc, peer, service, 0, 0,
@@ -1558,7 +1558,7 @@ sfw_unpack_message(srpc_msg_t *msg)
 }
 
 void
-sfw_abort_rpc(srpc_client_rpc_t *rpc)
+sfw_abort_rpc(struct srpc_client_rpc *rpc)
 {
 	LASSERT(atomic_read(&rpc->crpc_refcount) > 0);
 	LASSERT(rpc->crpc_service <= SRPC_FRAMEWORK_SERVICE_MAX_ID);
@@ -1569,7 +1569,7 @@ sfw_abort_rpc(srpc_client_rpc_t *rpc)
 }
 
 void
-sfw_post_rpc(srpc_client_rpc_t *rpc)
+sfw_post_rpc(struct srpc_client_rpc *rpc)
 {
 	spin_lock(&rpc->crpc_lock);
 
@@ -1759,10 +1759,10 @@ sfw_shutdown(void)
 	}
 
 	while (!list_empty(&sfw_data.fw_zombie_rpcs)) {
-		srpc_client_rpc_t *rpc;
+		struct srpc_client_rpc *rpc;
 
 		rpc = list_entry(sfw_data.fw_zombie_rpcs.next,
-				 srpc_client_rpc_t, crpc_list);
+				 struct srpc_client_rpc, crpc_list);
 		list_del(&rpc->crpc_list);
 
 		LIBCFS_FREE(rpc, srpc_client_rpc_size(rpc));
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index c7c50be..1f2ddf6 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -87,7 +87,7 @@ ping_client_fini(sfw_test_instance_t *tsi)
 
 static int
 ping_client_prep_rpc(sfw_test_unit_t *tsu, lnet_process_id_t dest,
-		     srpc_client_rpc_t **rpc)
+		     struct srpc_client_rpc **rpc)
 {
 	srpc_ping_reqst_t *req;
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
@@ -118,7 +118,7 @@ ping_client_prep_rpc(sfw_test_unit_t *tsu, lnet_process_id_t dest,
 }
 
 static void
-ping_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
+ping_client_done_rpc(sfw_test_unit_t *tsu, struct srpc_client_rpc *rpc)
 {
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
 	sfw_session_t *sn = tsi->tsi_batch->bat_session;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index b0d5a89..e711571 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -792,7 +792,7 @@ srpc_shutdown_service(srpc_service_t *sv)
 }
 
 static int
-srpc_send_request(srpc_client_rpc_t *rpc)
+srpc_send_request(struct srpc_client_rpc *rpc)
 {
 	struct srpc_event *ev = &rpc->crpc_reqstev;
 	int rc;
@@ -814,7 +814,7 @@ srpc_send_request(srpc_client_rpc_t *rpc)
 }
 
 static int
-srpc_prepare_reply(srpc_client_rpc_t *rpc)
+srpc_prepare_reply(struct srpc_client_rpc *rpc)
 {
 	struct srpc_event *ev = &rpc->crpc_replyev;
 	__u64 *id = &rpc->crpc_reqstmsg.msg_body.reqst.rpyid;
@@ -838,7 +838,7 @@ srpc_prepare_reply(srpc_client_rpc_t *rpc)
 }
 
 static int
-srpc_prepare_bulk(srpc_client_rpc_t *rpc)
+srpc_prepare_bulk(struct srpc_client_rpc *rpc)
 {
 	struct srpc_bulk *bk = &rpc->crpc_bulk;
 	struct srpc_event *ev = &rpc->crpc_bulkev;
@@ -1077,7 +1077,7 @@ srpc_handle_rpc(struct swi_workitem *wi)
 static void
 srpc_client_rpc_expired(void *data)
 {
-	srpc_client_rpc_t *rpc = data;
+	struct srpc_client_rpc *rpc = data;
 
 	CWARN("Client RPC expired: service %d, peer %s, timeout %d.\n",
 	      rpc->crpc_service, libcfs_id2str(rpc->crpc_dest),
@@ -1096,7 +1096,7 @@ srpc_client_rpc_expired(void *data)
 }
 
 static void
-srpc_add_client_rpc_timer(srpc_client_rpc_t *rpc)
+srpc_add_client_rpc_timer(struct srpc_client_rpc *rpc)
 {
 	struct stt_timer *timer = &rpc->crpc_timer;
 
@@ -1117,7 +1117,7 @@ srpc_add_client_rpc_timer(srpc_client_rpc_t *rpc)
  * running on any CPU.
  */
 static void
-srpc_del_client_rpc_timer(srpc_client_rpc_t *rpc)
+srpc_del_client_rpc_timer(struct srpc_client_rpc *rpc)
 {
 	/* timer not planted or already exploded */
 	if (!rpc->crpc_timeout)
@@ -1138,7 +1138,7 @@ srpc_del_client_rpc_timer(srpc_client_rpc_t *rpc)
 }
 
 static void
-srpc_client_rpc_done(srpc_client_rpc_t *rpc, int status)
+srpc_client_rpc_done(struct srpc_client_rpc *rpc, int status)
 {
 	struct swi_workitem *wi = &rpc->crpc_wi;
 
@@ -1178,7 +1178,7 @@ int
 srpc_send_rpc(struct swi_workitem *wi)
 {
 	int rc = 0;
-	srpc_client_rpc_t *rpc;
+	struct srpc_client_rpc *rpc;
 	srpc_msg_t *reply;
 	int do_bulk;
 
@@ -1308,15 +1308,15 @@ abort:
 	return 0;
 }
 
-srpc_client_rpc_t *
+struct srpc_client_rpc *
 srpc_create_client_rpc(lnet_process_id_t peer, int service,
 		       int nbulkiov, int bulklen,
-		       void (*rpc_done)(srpc_client_rpc_t *),
-		       void (*rpc_fini)(srpc_client_rpc_t *), void *priv)
+		       void (*rpc_done)(struct srpc_client_rpc *),
+		       void (*rpc_fini)(struct srpc_client_rpc *), void *priv)
 {
-	srpc_client_rpc_t *rpc;
+	struct srpc_client_rpc *rpc;
 
-	LIBCFS_ALLOC(rpc, offsetof(srpc_client_rpc_t,
+	LIBCFS_ALLOC(rpc, offsetof(struct srpc_client_rpc,
 				   crpc_bulk.bk_iovs[nbulkiov]));
 	if (!rpc)
 		return NULL;
@@ -1328,7 +1328,7 @@ srpc_create_client_rpc(lnet_process_id_t peer, int service,
 
 /* called with rpc->crpc_lock held */
 void
-srpc_abort_rpc(srpc_client_rpc_t *rpc, int why)
+srpc_abort_rpc(struct srpc_client_rpc *rpc, int why)
 {
 	LASSERT(why);
 
@@ -1347,7 +1347,7 @@ srpc_abort_rpc(srpc_client_rpc_t *rpc, int why)
 
 /* called with rpc->crpc_lock held */
 void
-srpc_post_rpc(srpc_client_rpc_t *rpc)
+srpc_post_rpc(struct srpc_client_rpc *rpc)
 {
 	LASSERT(!rpc->crpc_aborted);
 	LASSERT(srpc_data.rpc_state == SRPC_STATE_RUNNING);
@@ -1411,7 +1411,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 {
 	struct srpc_service_cd *scd;
 	struct srpc_event *rpcev = ev->md.user_ptr;
-	srpc_client_rpc_t *crpc;
+	struct srpc_client_rpc *crpc;
 	struct srpc_server_rpc *srpc;
 	struct srpc_buffer *buffer;
 	srpc_service_t *sv;
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index d6799b6..55f8154 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -202,7 +202,7 @@ struct srpc_server_rpc {
 };
 
 /* client-side state of a RPC */
-typedef struct srpc_client_rpc {
+struct srpc_client_rpc {
 	struct list_head  crpc_list;	  /* chain on user's lists */
 	spinlock_t	  crpc_lock;	  /* serialize */
 	int		  crpc_service;
@@ -232,10 +232,10 @@ typedef struct srpc_client_rpc {
 	lnet_handle_md_t  crpc_reqstmdh;
 	lnet_handle_md_t  crpc_replymdh;
 	struct srpc_bulk	crpc_bulk;
-} srpc_client_rpc_t;
+};
 
 #define srpc_client_rpc_size(rpc)					\
-offsetof(srpc_client_rpc_t, crpc_bulk.bk_iovs[(rpc)->crpc_bulk.bk_niov])
+offsetof(struct srpc_client_rpc, crpc_bulk.bk_iovs[(rpc)->crpc_bulk.bk_niov])
 
 #define srpc_client_rpc_addref(rpc)					\
 do {									\
@@ -357,9 +357,9 @@ typedef struct {
 							  * client */
 	int  (*tso_prep_rpc)(struct sfw_test_unit *tsu,
 			     lnet_process_id_t dest,
-			     srpc_client_rpc_t **rpc);	 /* prep a tests rpc */
+			     struct srpc_client_rpc **rpc);	/* prep a tests rpc */
 	void (*tso_done_rpc)(struct sfw_test_unit *tsu,
-			     srpc_client_rpc_t *rpc);	 /* done a test rpc */
+			     struct srpc_client_rpc *rpc);	/* done a test rpc */
 } sfw_test_client_ops_t;
 
 typedef struct sfw_test_instance {
@@ -413,16 +413,16 @@ typedef struct sfw_test_case {
 	sfw_test_client_ops_t *tsc_cli_ops;	/* ops of test client */
 } sfw_test_case_t;
 
-srpc_client_rpc_t *
+struct srpc_client_rpc *
 sfw_create_rpc(lnet_process_id_t peer, int service,
 	       unsigned features, int nbulkiov, int bulklen,
-	       void (*done)(srpc_client_rpc_t *), void *priv);
+	       void (*done)(struct srpc_client_rpc *), void *priv);
 int sfw_create_test_rpc(sfw_test_unit_t *tsu,
 			lnet_process_id_t peer, unsigned features,
-			int nblk, int blklen, srpc_client_rpc_t **rpc);
-void sfw_abort_rpc(srpc_client_rpc_t *rpc);
-void sfw_post_rpc(srpc_client_rpc_t *rpc);
-void sfw_client_rpc_done(srpc_client_rpc_t *rpc);
+			int nblk, int blklen, struct srpc_client_rpc **rpc);
+void sfw_abort_rpc(struct srpc_client_rpc *rpc);
+void sfw_post_rpc(struct srpc_client_rpc *rpc);
+void sfw_client_rpc_done(struct srpc_client_rpc *rpc);
 void sfw_unpack_message(srpc_msg_t *msg);
 void sfw_free_pages(struct srpc_server_rpc *rpc);
 void sfw_add_bulk_page(struct srpc_bulk *bk, struct page *pg, int i);
@@ -430,13 +430,13 @@ int sfw_alloc_pages(struct srpc_server_rpc *rpc, int cpt, int npages, int len,
 		    int sink);
 int sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply);
 
-srpc_client_rpc_t *
+struct srpc_client_rpc *
 srpc_create_client_rpc(lnet_process_id_t peer, int service,
 		       int nbulkiov, int bulklen,
-		       void (*rpc_done)(srpc_client_rpc_t *),
-		       void (*rpc_fini)(srpc_client_rpc_t *), void *priv);
-void srpc_post_rpc(srpc_client_rpc_t *rpc);
-void srpc_abort_rpc(srpc_client_rpc_t *rpc, int why);
+		       void (*rpc_done)(struct srpc_client_rpc *),
+		       void (*rpc_fini)(struct srpc_client_rpc *), void *priv);
+void srpc_post_rpc(struct srpc_client_rpc *rpc);
+void srpc_abort_rpc(struct srpc_client_rpc *rpc, int why);
 void srpc_free_bulk(struct srpc_bulk *bk);
 struct srpc_bulk *srpc_alloc_bulk(int cpt, unsigned bulk_npg,
 				  unsigned bulk_len, int sink);
@@ -505,7 +505,7 @@ void sfw_shutdown(void);
 void srpc_shutdown(void);
 
 static inline void
-srpc_destroy_client_rpc(srpc_client_rpc_t *rpc)
+srpc_destroy_client_rpc(struct srpc_client_rpc *rpc)
 {
 	LASSERT(rpc);
 	LASSERT(!srpc_event_pending(rpc));
@@ -518,14 +518,14 @@ srpc_destroy_client_rpc(srpc_client_rpc_t *rpc)
 }
 
 static inline void
-srpc_init_client_rpc(srpc_client_rpc_t *rpc, lnet_process_id_t peer,
+srpc_init_client_rpc(struct srpc_client_rpc *rpc, lnet_process_id_t peer,
 		     int service, int nbulkiov, int bulklen,
-		     void (*rpc_done)(srpc_client_rpc_t *),
-		     void (*rpc_fini)(srpc_client_rpc_t *), void *priv)
+		     void (*rpc_done)(struct srpc_client_rpc *),
+		     void (*rpc_fini)(struct srpc_client_rpc *), void *priv)
 {
 	LASSERT(nbulkiov <= LNET_MAX_IOV);
 
-	memset(rpc, 0, offsetof(srpc_client_rpc_t,
+	memset(rpc, 0, offsetof(struct srpc_client_rpc,
 				crpc_bulk.bk_iovs[nbulkiov]));
 
 	INIT_LIST_HEAD(&rpc->crpc_list);
-- 
1.7.1
