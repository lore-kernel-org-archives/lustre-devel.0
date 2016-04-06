From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:34 -0400
Subject: [lustre-devel] [PATCH 08/24] staging: lustre: selftest: convert
	sfw_session_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef sfw_session_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c  |    6 ++--
 drivers/staging/lustre/lnet/selftest/framework.c |   40 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/ping_test.c |    8 ++--
 drivers/staging/lustre/lnet/selftest/selftest.h  |    6 ++--
 4 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index d2a8379..8e789ba 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -69,7 +69,7 @@ brw_client_fini(sfw_test_instance_t *tsi)
 static int
 brw_client_init(sfw_test_instance_t *tsi)
 {
-	sfw_session_t *sn = tsi->tsi_batch->bat_session;
+	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	int flags;
 	int npg;
 	int len;
@@ -259,7 +259,7 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 {
 	struct srpc_bulk *bulk = tsu->tsu_private;
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
-	sfw_session_t *sn = tsi->tsi_batch->bat_session;
+	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	struct srpc_client_rpc *rpc;
 	srpc_brw_reqst_t *req;
 	int flags;
@@ -317,7 +317,7 @@ brw_client_done_rpc(sfw_test_unit_t *tsu, struct srpc_client_rpc *rpc)
 {
 	__u64 magic = BRW_MAGIC;
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
-	sfw_session_t *sn = tsi->tsi_batch->bat_session;
+	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	srpc_msg_t *msg = &rpc->crpc_replymsg;
 	srpc_brw_reply_t *reply = &msg->msg_body.brw_reply;
 	srpc_brw_reqst_t *reqst = &rpc->crpc_reqstmsg.msg_body.brw_reqst;
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 0eb275f..3a20598 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -109,14 +109,14 @@ static struct smoketest_framework {
 	struct list_head  fw_tests;	      /* registered test cases */
 	atomic_t	  fw_nzombies;	      /* # zombie sessions */
 	spinlock_t	  fw_lock;	      /* serialise */
-	sfw_session_t	  *fw_session;	      /* _the_ session */
+	struct sfw_session	  *fw_session;	      /* _the_ session */
 	int		  fw_shuttingdown;    /* shutdown in progress */
 	struct srpc_server_rpc *fw_active_srpc;/* running RPC */
 } sfw_data;
 
 /* forward ref's */
 int sfw_stop_batch(sfw_batch_t *tsb, int force);
-void sfw_destroy_session(sfw_session_t *sn);
+void sfw_destroy_session(struct sfw_session *sn);
 
 static inline sfw_test_case_t *
 sfw_find_test_case(int id)
@@ -159,7 +159,7 @@ sfw_register_test(struct srpc_service *service, sfw_test_client_ops_t *cliops)
 static void
 sfw_add_session_timer(void)
 {
-	sfw_session_t *sn = sfw_data.fw_session;
+	struct sfw_session *sn = sfw_data.fw_session;
 	struct stt_timer *timer = &sn->sn_timer;
 
 	LASSERT(!sfw_data.fw_shuttingdown);
@@ -177,7 +177,7 @@ sfw_add_session_timer(void)
 static int
 sfw_del_session_timer(void)
 {
-	sfw_session_t *sn = sfw_data.fw_session;
+	struct sfw_session *sn = sfw_data.fw_session;
 
 	if (!sn || !sn->sn_timer_active)
 		return 0;
@@ -196,7 +196,7 @@ static void
 sfw_deactivate_session(void)
 __must_hold(&sfw_data.fw_lock)
 {
-	sfw_session_t *sn = sfw_data.fw_session;
+	struct sfw_session *sn = sfw_data.fw_session;
 	int nactive = 0;
 	sfw_batch_t *tsb;
 	sfw_test_case_t *tsc;
@@ -239,7 +239,7 @@ __must_hold(&sfw_data.fw_lock)
 static void
 sfw_session_expired(void *data)
 {
-	sfw_session_t *sn = data;
+	struct sfw_session *sn = data;
 
 	spin_lock(&sfw_data.fw_lock);
 
@@ -257,12 +257,12 @@ sfw_session_expired(void *data)
 }
 
 static inline void
-sfw_init_session(sfw_session_t *sn, lst_sid_t sid,
+sfw_init_session(struct sfw_session *sn, lst_sid_t sid,
 		 unsigned features, const char *name)
 {
 	struct stt_timer *timer = &sn->sn_timer;
 
-	memset(sn, 0, sizeof(sfw_session_t));
+	memset(sn, 0, sizeof(struct sfw_session));
 	INIT_LIST_HEAD(&sn->sn_list);
 	INIT_LIST_HEAD(&sn->sn_batches);
 	atomic_set(&sn->sn_refcount, 1);	/* +1 for caller */
@@ -321,7 +321,7 @@ sfw_client_rpc_fini(struct srpc_client_rpc *rpc)
 static sfw_batch_t *
 sfw_find_batch(lst_bid_t bid)
 {
-	sfw_session_t *sn = sfw_data.fw_session;
+	struct sfw_session *sn = sfw_data.fw_session;
 	sfw_batch_t *bat;
 
 	LASSERT(sn);
@@ -337,7 +337,7 @@ sfw_find_batch(lst_bid_t bid)
 static sfw_batch_t *
 sfw_bid2batch(lst_bid_t bid)
 {
-	sfw_session_t *sn = sfw_data.fw_session;
+	struct sfw_session *sn = sfw_data.fw_session;
 	sfw_batch_t *bat;
 
 	LASSERT(sn);
@@ -363,7 +363,7 @@ sfw_bid2batch(lst_bid_t bid)
 static int
 sfw_get_stats(srpc_stat_reqst_t *request, srpc_stat_reply_t *reply)
 {
-	sfw_session_t *sn = sfw_data.fw_session;
+	struct sfw_session *sn = sfw_data.fw_session;
 	sfw_counters_t *cnt = &reply->str_fw;
 	sfw_batch_t *bat;
 
@@ -404,7 +404,7 @@ sfw_get_stats(srpc_stat_reqst_t *request, srpc_stat_reply_t *reply)
 int
 sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
 {
-	sfw_session_t *sn = sfw_data.fw_session;
+	struct sfw_session *sn = sfw_data.fw_session;
 	srpc_msg_t *msg = container_of(request, srpc_msg_t,
 				       msg_body.mksn_reqst);
 	int cplen = 0;
@@ -449,7 +449,7 @@ sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
 	}
 
 	/* brand new or create by force */
-	LIBCFS_ALLOC(sn, sizeof(sfw_session_t));
+	LIBCFS_ALLOC(sn, sizeof(struct sfw_session));
 	if (!sn) {
 		CERROR("dropping RPC mksn under memory pressure\n");
 		return -ENOMEM;
@@ -475,7 +475,7 @@ sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
 static int
 sfw_remove_session(srpc_rmsn_reqst_t *request, srpc_rmsn_reply_t *reply)
 {
-	sfw_session_t *sn = sfw_data.fw_session;
+	struct sfw_session *sn = sfw_data.fw_session;
 
 	reply->rmsn_sid = !sn ? LST_INVALID_SID : sn->sn_id;
 
@@ -507,7 +507,7 @@ sfw_remove_session(srpc_rmsn_reqst_t *request, srpc_rmsn_reply_t *reply)
 static int
 sfw_debug_session(srpc_debug_reqst_t *request, srpc_debug_reply_t *reply)
 {
-	sfw_session_t *sn = sfw_data.fw_session;
+	struct sfw_session *sn = sfw_data.fw_session;
 
 	if (!sn) {
 		reply->dbg_status = ESRCH;
@@ -666,7 +666,7 @@ sfw_destroy_batch(sfw_batch_t *tsb)
 }
 
 void
-sfw_destroy_session(sfw_session_t *sn)
+sfw_destroy_session(struct sfw_session *sn)
 {
 	sfw_batch_t *batch;
 
@@ -828,7 +828,7 @@ sfw_test_unit_done(sfw_test_unit_t *tsu)
 {
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
 	sfw_batch_t *tsb = tsi->tsi_batch;
-	sfw_session_t *sn = tsb->bat_session;
+	struct sfw_session *sn = tsb->bat_session;
 
 	LASSERT(sfw_test_active(tsi));
 
@@ -1115,7 +1115,7 @@ sfw_alloc_pages(struct srpc_server_rpc *rpc, int cpt, int npages, int len,
 static int
 sfw_add_test(struct srpc_server_rpc *rpc)
 {
-	sfw_session_t *sn = sfw_data.fw_session;
+	struct sfw_session *sn = sfw_data.fw_session;
 	srpc_test_reply_t *reply = &rpc->srpc_replymsg.msg_body.tes_reply;
 	srpc_test_reqst_t *request;
 	int rc;
@@ -1185,7 +1185,7 @@ sfw_add_test(struct srpc_server_rpc *rpc)
 static int
 sfw_control_batch(srpc_batch_reqst_t *request, srpc_batch_reply_t *reply)
 {
-	sfw_session_t *sn = sfw_data.fw_session;
+	struct sfw_session *sn = sfw_data.fw_session;
 	int rc = 0;
 	sfw_batch_t *bat;
 
@@ -1261,7 +1261,7 @@ sfw_handle_server_rpc(struct srpc_server_rpc *rpc)
 
 	if (sv->sv_id != SRPC_SERVICE_MAKE_SESSION &&
 	    sv->sv_id != SRPC_SERVICE_DEBUG) {
-		sfw_session_t *sn = sfw_data.fw_session;
+		struct sfw_session *sn = sfw_data.fw_session;
 
 		if (sn &&
 		    sn->sn_features != request->msg_ses_feats) {
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index c09b599..df33a13 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -58,7 +58,7 @@ static struct lst_ping_data  lst_ping_data;
 static int
 ping_client_init(sfw_test_instance_t *tsi)
 {
-	sfw_session_t *sn = tsi->tsi_batch->bat_session;
+	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 
 	LASSERT(tsi->tsi_is_client);
 	LASSERT(sn && !(sn->sn_features & ~LST_FEATS_MASK));
@@ -72,7 +72,7 @@ ping_client_init(sfw_test_instance_t *tsi)
 static void
 ping_client_fini(sfw_test_instance_t *tsi)
 {
-	sfw_session_t *sn = tsi->tsi_batch->bat_session;
+	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	int errors;
 
 	LASSERT(sn);
@@ -91,7 +91,7 @@ ping_client_prep_rpc(sfw_test_unit_t *tsu, lnet_process_id_t dest,
 {
 	srpc_ping_reqst_t *req;
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
-	sfw_session_t *sn = tsi->tsi_batch->bat_session;
+	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	struct timespec64 ts;
 	int rc;
 
@@ -121,7 +121,7 @@ static void
 ping_client_done_rpc(sfw_test_unit_t *tsu, struct srpc_client_rpc *rpc)
 {
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
-	sfw_session_t *sn = tsi->tsi_batch->bat_session;
+	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	srpc_ping_reqst_t *reqst = &rpc->crpc_reqstmsg.msg_body.ping_reqst;
 	srpc_ping_reply_t *reply = &rpc->crpc_replymsg.msg_body.ping_reply;
 	struct timespec64 ts;
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 0ad6e53..eee36b1 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -323,7 +323,7 @@ struct srpc_service {
 	int (*sv_bulk_ready)(struct srpc_server_rpc *, int);
 };
 
-typedef struct {
+struct sfw_session {
 	struct list_head sn_list;    /* chain on fw_zombie_sessions */
 	lst_sid_t	 sn_id;      /* unique identifier */
 	unsigned int	 sn_timeout; /* # seconds' inactivity to expire */
@@ -336,7 +336,7 @@ typedef struct {
 	atomic_t	 sn_brw_errors;
 	atomic_t	 sn_ping_errors;
 	unsigned long	 sn_started;
-} sfw_session_t;
+};
 
 #define sfw_sid_equal(sid0, sid1)     ((sid0).ses_nid == (sid1).ses_nid && \
 				       (sid0).ses_stamp == (sid1).ses_stamp)
@@ -345,7 +345,7 @@ typedef struct {
 	struct list_head bat_list;	/* chain on sn_batches */
 	lst_bid_t	 bat_id;	/* batch id */
 	int		 bat_error;	/* error code of batch */
-	sfw_session_t	 *bat_session;	/* batch's session */
+	struct sfw_session	*bat_session;	/* batch's session */
 	atomic_t	 bat_nactive;	/* # of active tests */
 	struct list_head bat_tests;	/* test instances */
 } sfw_batch_t;
-- 
1.7.1
