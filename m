From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:29 -0400
Subject: [lustre-devel] [PATCH 03/24] staging: lustre: selftest: convert
	srpc_bulk_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef srpc_bulk_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c  |   14 +++++++-------
 drivers/staging/lustre/lnet/selftest/conrpc.c    |    4 ++--
 drivers/staging/lustre/lnet/selftest/framework.c |    2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c       |   18 +++++++++---------
 drivers/staging/lustre/lnet/selftest/selftest.h  |   17 +++++++++--------
 5 files changed, 28 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 1988cee..a3dec89 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -51,7 +51,7 @@ MODULE_PARM_DESC(brw_inject_errors, "# data errors to inject randomly, zero by d
 static void
 brw_client_fini(sfw_test_instance_t *tsi)
 {
-	srpc_bulk_t *bulk;
+	struct srpc_bulk *bulk;
 	sfw_test_unit_t	*tsu;
 
 	LASSERT(tsi->tsi_is_client);
@@ -74,7 +74,7 @@ brw_client_init(sfw_test_instance_t *tsi)
 	int npg;
 	int len;
 	int opc;
-	srpc_bulk_t *bulk;
+	struct srpc_bulk *bulk;
 	sfw_test_unit_t *tsu;
 
 	LASSERT(sn);
@@ -224,7 +224,7 @@ bad_data:
 }
 
 static void
-brw_fill_bulk(srpc_bulk_t *bk, int pattern, __u64 magic)
+brw_fill_bulk(struct srpc_bulk *bk, int pattern, __u64 magic)
 {
 	int i;
 	struct page *pg;
@@ -236,7 +236,7 @@ brw_fill_bulk(srpc_bulk_t *bk, int pattern, __u64 magic)
 }
 
 static int
-brw_check_bulk(srpc_bulk_t *bk, int pattern, __u64 magic)
+brw_check_bulk(struct srpc_bulk *bk, int pattern, __u64 magic)
 {
 	int i;
 	struct page *pg;
@@ -257,7 +257,7 @@ static int
 brw_client_prep_rpc(sfw_test_unit_t *tsu,
 		    lnet_process_id_t dest, srpc_client_rpc_t **rpcpp)
 {
-	srpc_bulk_t *bulk = tsu->tsu_private;
+	struct srpc_bulk *bulk = tsu->tsu_private;
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
 	sfw_session_t *sn = tsi->tsi_batch->bat_session;
 	srpc_client_rpc_t *rpc;
@@ -297,7 +297,7 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 	if (rc)
 		return rc;
 
-	memcpy(&rpc->crpc_bulk, bulk, offsetof(srpc_bulk_t, bk_iovs[npg]));
+	memcpy(&rpc->crpc_bulk, bulk, offsetof(struct srpc_bulk, bk_iovs[npg]));
 	if (opc == LST_BRW_WRITE)
 		brw_fill_bulk(&rpc->crpc_bulk, flags, BRW_MAGIC);
 	else
@@ -361,7 +361,7 @@ brw_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 static void
 brw_server_rpc_done(struct srpc_server_rpc *rpc)
 {
-	srpc_bulk_t *blk = rpc->srpc_bulk;
+	struct srpc_bulk *blk = rpc->srpc_bulk;
 
 	if (!blk)
 		return;
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 3908c10..53da5cb 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -150,7 +150,7 @@ lstcon_rpc_prep(lstcon_node_t *nd, int service, unsigned feats,
 void
 lstcon_rpc_put(lstcon_rpc_t *crpc)
 {
-	srpc_bulk_t *bulk = &crpc->crp_rpc->crpc_bulk;
+	struct srpc_bulk *bulk = &crpc->crp_rpc->crpc_bulk;
 	int i;
 
 	LASSERT(list_empty(&crpc->crp_link));
@@ -812,7 +812,7 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 	lstcon_group_t *sgrp = test->tes_src_grp;
 	lstcon_group_t *dgrp = test->tes_dst_grp;
 	srpc_test_reqst_t *trq;
-	srpc_bulk_t *bulk;
+	struct srpc_bulk *bulk;
 	int i;
 	int npg = 0;
 	int nob = 0;
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index aa646a7..40a3da9 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -733,7 +733,7 @@ sfw_add_test_instance(sfw_batch_t *tsb, struct srpc_server_rpc *rpc)
 {
 	srpc_msg_t *msg = &rpc->srpc_reqstbuf->buf_msg;
 	srpc_test_reqst_t *req = &msg->msg_body.tes_reqst;
-	srpc_bulk_t *bk = rpc->srpc_bulk;
+	struct srpc_bulk *bk = rpc->srpc_bulk;
 	int ndest = req->tsr_ndest;
 	sfw_test_unit_t *tsu;
 	sfw_test_instance_t *tsi;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index ba75b34..387c306 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -88,7 +88,7 @@ void srpc_set_counters(const srpc_counters_t *cnt)
 }
 
 static int
-srpc_add_bulk_page(srpc_bulk_t *bk, struct page *pg, int i, int nob)
+srpc_add_bulk_page(struct srpc_bulk *bk, struct page *pg, int i, int nob)
 {
 	nob = min_t(int, nob, PAGE_CACHE_SIZE);
 
@@ -102,7 +102,7 @@ srpc_add_bulk_page(srpc_bulk_t *bk, struct page *pg, int i, int nob)
 }
 
 void
-srpc_free_bulk(srpc_bulk_t *bk)
+srpc_free_bulk(struct srpc_bulk *bk)
 {
 	int i;
 	struct page *pg;
@@ -117,25 +117,25 @@ srpc_free_bulk(srpc_bulk_t *bk)
 		__free_page(pg);
 	}
 
-	LIBCFS_FREE(bk, offsetof(srpc_bulk_t, bk_iovs[bk->bk_niov]));
+	LIBCFS_FREE(bk, offsetof(struct srpc_bulk, bk_iovs[bk->bk_niov]));
 }
 
-srpc_bulk_t *
+struct srpc_bulk *
 srpc_alloc_bulk(int cpt, unsigned bulk_npg, unsigned bulk_len, int sink)
 {
-	srpc_bulk_t *bk;
+	struct srpc_bulk *bk;
 	int i;
 
 	LASSERT(bulk_npg > 0 && bulk_npg <= LNET_MAX_IOV);
 
 	LIBCFS_CPT_ALLOC(bk, lnet_cpt_table(), cpt,
-			 offsetof(srpc_bulk_t, bk_iovs[bulk_npg]));
+			 offsetof(struct srpc_bulk, bk_iovs[bulk_npg]));
 	if (!bk) {
 		CERROR("Can't allocate descriptor for %d pages\n", bulk_npg);
 		return NULL;
 	}
 
-	memset(bk, 0, offsetof(srpc_bulk_t, bk_iovs[bulk_npg]));
+	memset(bk, 0, offsetof(struct srpc_bulk, bk_iovs[bulk_npg]));
 	bk->bk_sink = sink;
 	bk->bk_len = bulk_len;
 	bk->bk_niov = bulk_npg;
@@ -840,7 +840,7 @@ srpc_prepare_reply(srpc_client_rpc_t *rpc)
 static int
 srpc_prepare_bulk(srpc_client_rpc_t *rpc)
 {
-	srpc_bulk_t *bk = &rpc->crpc_bulk;
+	struct srpc_bulk *bk = &rpc->crpc_bulk;
 	struct srpc_event *ev = &rpc->crpc_bulkev;
 	__u64 *id = &rpc->crpc_reqstmsg.msg_body.reqst.bulkid;
 	int rc;
@@ -874,7 +874,7 @@ static int
 srpc_do_bulk(struct srpc_server_rpc *rpc)
 {
 	struct srpc_event *ev = &rpc->srpc_ev;
-	srpc_bulk_t *bk = rpc->srpc_bulk;
+	struct srpc_bulk *bk = rpc->srpc_bulk;
 	__u64 id = rpc->srpc_reqstbuf->buf_msg.msg_body.reqst.bulkid;
 	int rc;
 	int opt;
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 43972eb..fdf62cc 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -154,13 +154,14 @@ struct srpc_event {
 	void		  *ev_data;  /* owning server/client RPC */
 };
 
-typedef struct {
+/* bulk descriptor */
+struct srpc_bulk {
 	int		 bk_len;     /* len of bulk data */
 	lnet_handle_md_t bk_mdh;
 	int		 bk_sink;    /* sink/source */
 	int		 bk_niov;    /* # iov in bk_iovs */
 	lnet_kiov_t	 bk_iovs[0];
-} srpc_bulk_t; /* bulk descriptor */
+};
 
 /* message buffer descriptor */
 typedef struct srpc_buffer {
@@ -193,7 +194,7 @@ struct srpc_server_rpc {
 	srpc_msg_t	       srpc_replymsg;
 	lnet_handle_md_t       srpc_replymdh;
 	srpc_buffer_t	       *srpc_reqstbuf;
-	srpc_bulk_t	       *srpc_bulk;
+	struct srpc_bulk	*srpc_bulk;
 
 	unsigned int	       srpc_aborted; /* being given up */
 	int		       srpc_status;
@@ -230,7 +231,7 @@ typedef struct srpc_client_rpc {
 	srpc_msg_t	  crpc_replymsg;
 	lnet_handle_md_t  crpc_reqstmdh;
 	lnet_handle_md_t  crpc_replymdh;
-	srpc_bulk_t	  crpc_bulk;
+	struct srpc_bulk	crpc_bulk;
 } srpc_client_rpc_t;
 
 #define srpc_client_rpc_size(rpc)					\
@@ -424,7 +425,7 @@ void sfw_post_rpc(srpc_client_rpc_t *rpc);
 void sfw_client_rpc_done(srpc_client_rpc_t *rpc);
 void sfw_unpack_message(srpc_msg_t *msg);
 void sfw_free_pages(struct srpc_server_rpc *rpc);
-void sfw_add_bulk_page(srpc_bulk_t *bk, struct page *pg, int i);
+void sfw_add_bulk_page(struct srpc_bulk *bk, struct page *pg, int i);
 int sfw_alloc_pages(struct srpc_server_rpc *rpc, int cpt, int npages, int len,
 		    int sink);
 int sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply);
@@ -436,9 +437,9 @@ srpc_create_client_rpc(lnet_process_id_t peer, int service,
 		       void (*rpc_fini)(srpc_client_rpc_t *), void *priv);
 void srpc_post_rpc(srpc_client_rpc_t *rpc);
 void srpc_abort_rpc(srpc_client_rpc_t *rpc, int why);
-void srpc_free_bulk(srpc_bulk_t *bk);
-srpc_bulk_t *srpc_alloc_bulk(int cpt, unsigned bulk_npg, unsigned bulk_len,
-			     int sink);
+void srpc_free_bulk(struct srpc_bulk *bk);
+struct srpc_bulk *srpc_alloc_bulk(int cpt, unsigned bulk_npg,
+				  unsigned bulk_len, int sink);
 int srpc_send_rpc(swi_workitem_t *wi);
 int srpc_send_reply(struct srpc_server_rpc *rpc);
 int srpc_add_service(srpc_service_t *sv);
-- 
1.7.1
