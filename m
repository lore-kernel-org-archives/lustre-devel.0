From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:35 -0400
Subject: [lustre-devel] [PATCH 09/24] staging: lustre: selftest: convert
	sfw_batch_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef sfw_batch_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/framework.c |   38 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/selftest.h  |    6 ++--
 2 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 3a20598..0d7c3c5 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -115,7 +115,7 @@ static struct smoketest_framework {
 } sfw_data;
 
 /* forward ref's */
-int sfw_stop_batch(sfw_batch_t *tsb, int force);
+int sfw_stop_batch(struct sfw_batch *tsb, int force);
 void sfw_destroy_session(struct sfw_session *sn);
 
 static inline sfw_test_case_t *
@@ -198,7 +198,7 @@ __must_hold(&sfw_data.fw_lock)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
 	int nactive = 0;
-	sfw_batch_t *tsb;
+	struct sfw_batch *tsb;
 	sfw_test_case_t *tsc;
 
 	if (!sn)
@@ -318,11 +318,11 @@ sfw_client_rpc_fini(struct srpc_client_rpc *rpc)
 	spin_unlock(&sfw_data.fw_lock);
 }
 
-static sfw_batch_t *
+static struct sfw_batch *
 sfw_find_batch(lst_bid_t bid)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
-	sfw_batch_t *bat;
+	struct sfw_batch *bat;
 
 	LASSERT(sn);
 
@@ -334,11 +334,11 @@ sfw_find_batch(lst_bid_t bid)
 	return NULL;
 }
 
-static sfw_batch_t *
+static struct sfw_batch *
 sfw_bid2batch(lst_bid_t bid)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
-	sfw_batch_t *bat;
+	struct sfw_batch *bat;
 
 	LASSERT(sn);
 
@@ -346,7 +346,7 @@ sfw_bid2batch(lst_bid_t bid)
 	if (bat)
 		return bat;
 
-	LIBCFS_ALLOC(bat, sizeof(sfw_batch_t));
+	LIBCFS_ALLOC(bat, sizeof(struct sfw_batch));
 	if (!bat)
 		return NULL;
 
@@ -365,7 +365,7 @@ sfw_get_stats(srpc_stat_reqst_t *request, srpc_stat_reply_t *reply)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
 	sfw_counters_t *cnt = &reply->str_fw;
-	sfw_batch_t *bat;
+	struct sfw_batch *bat;
 
 	reply->str_sid = !sn ? LST_INVALID_SID : sn->sn_id;
 
@@ -648,7 +648,7 @@ clean:
 }
 
 static void
-sfw_destroy_batch(sfw_batch_t *tsb)
+sfw_destroy_batch(struct sfw_batch *tsb)
 {
 	sfw_test_instance_t *tsi;
 
@@ -662,20 +662,20 @@ sfw_destroy_batch(sfw_batch_t *tsb)
 		sfw_destroy_test_instance(tsi);
 	}
 
-	LIBCFS_FREE(tsb, sizeof(sfw_batch_t));
+	LIBCFS_FREE(tsb, sizeof(struct sfw_batch));
 }
 
 void
 sfw_destroy_session(struct sfw_session *sn)
 {
-	sfw_batch_t *batch;
+	struct sfw_batch *batch;
 
 	LASSERT(list_empty(&sn->sn_list));
 	LASSERT(sn != sfw_data.fw_session);
 
 	while (!list_empty(&sn->sn_batches)) {
 		batch = list_entry(sn->sn_batches.next,
-				   sfw_batch_t, bat_list);
+				   struct sfw_batch, bat_list);
 		list_del_init(&batch->bat_list);
 		sfw_destroy_batch(batch);
 	}
@@ -729,7 +729,7 @@ sfw_unpack_addtest_req(srpc_msg_t *msg)
 }
 
 static int
-sfw_add_test_instance(sfw_batch_t *tsb, struct srpc_server_rpc *rpc)
+sfw_add_test_instance(struct sfw_batch *tsb, struct srpc_server_rpc *rpc)
 {
 	srpc_msg_t *msg = &rpc->srpc_reqstbuf->buf_msg;
 	srpc_test_reqst_t *req = &msg->msg_body.tes_reqst;
@@ -827,7 +827,7 @@ static void
 sfw_test_unit_done(sfw_test_unit_t *tsu)
 {
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
-	sfw_batch_t *tsb = tsi->tsi_batch;
+	struct sfw_batch *tsb = tsi->tsi_batch;
 	struct sfw_session *sn = tsb->bat_session;
 
 	LASSERT(sfw_test_active(tsi));
@@ -991,7 +991,7 @@ test_done:
 }
 
 static int
-sfw_run_batch(sfw_batch_t *tsb)
+sfw_run_batch(struct sfw_batch *tsb)
 {
 	struct swi_workitem *wi;
 	sfw_test_unit_t *tsu;
@@ -1026,7 +1026,7 @@ sfw_run_batch(sfw_batch_t *tsb)
 }
 
 int
-sfw_stop_batch(sfw_batch_t *tsb, int force)
+sfw_stop_batch(struct sfw_batch *tsb, int force)
 {
 	sfw_test_instance_t *tsi;
 	struct srpc_client_rpc *rpc;
@@ -1068,7 +1068,7 @@ sfw_stop_batch(sfw_batch_t *tsb, int force)
 }
 
 static int
-sfw_query_batch(sfw_batch_t *tsb, int testidx, srpc_batch_reply_t *reply)
+sfw_query_batch(struct sfw_batch *tsb, int testidx, srpc_batch_reply_t *reply)
 {
 	sfw_test_instance_t *tsi;
 
@@ -1119,7 +1119,7 @@ sfw_add_test(struct srpc_server_rpc *rpc)
 	srpc_test_reply_t *reply = &rpc->srpc_replymsg.msg_body.tes_reply;
 	srpc_test_reqst_t *request;
 	int rc;
-	sfw_batch_t *bat;
+	struct sfw_batch *bat;
 
 	request = &rpc->srpc_reqstbuf->buf_msg.msg_body.tes_reqst;
 	reply->tsr_sid = !sn ? LST_INVALID_SID : sn->sn_id;
@@ -1187,7 +1187,7 @@ sfw_control_batch(srpc_batch_reqst_t *request, srpc_batch_reply_t *reply)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
 	int rc = 0;
-	sfw_batch_t *bat;
+	struct sfw_batch *bat;
 
 	reply->bar_sid = !sn ? LST_INVALID_SID : sn->sn_id;
 
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index eee36b1..50237bc 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -341,14 +341,14 @@ struct sfw_session {
 #define sfw_sid_equal(sid0, sid1)     ((sid0).ses_nid == (sid1).ses_nid && \
 				       (sid0).ses_stamp == (sid1).ses_stamp)
 
-typedef struct {
+struct sfw_batch {
 	struct list_head bat_list;	/* chain on sn_batches */
 	lst_bid_t	 bat_id;	/* batch id */
 	int		 bat_error;	/* error code of batch */
 	struct sfw_session	*bat_session;	/* batch's session */
 	atomic_t	 bat_nactive;	/* # of active tests */
 	struct list_head bat_tests;	/* test instances */
-} sfw_batch_t;
+};
 
 typedef struct {
 	int  (*tso_init)(struct sfw_test_instance *tsi); /* initialize test
@@ -365,7 +365,7 @@ typedef struct {
 typedef struct sfw_test_instance {
 	struct list_head	   tsi_list;		/* chain on batch */
 	int			   tsi_service;		/* test type */
-	sfw_batch_t		   *tsi_batch;		/* batch */
+	struct sfw_batch		*tsi_batch;	/* batch */
 	sfw_test_client_ops_t	   *tsi_ops;		/* test client operation
 							 */
 
-- 
1.7.1
