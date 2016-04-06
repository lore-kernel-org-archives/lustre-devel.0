From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:37 -0400
Subject: [lustre-devel] [PATCH 11/24] staging: lustre: selftest: convert
	sfw_test_instance_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef sfw_test_instance_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c  |    8 +++---
 drivers/staging/lustre/lnet/selftest/framework.c |   26 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/ping_test.c |    8 +++---
 drivers/staging/lustre/lnet/selftest/selftest.h  |    6 ++--
 4 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 5cba2c3..90fabd0 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -49,7 +49,7 @@ module_param(brw_inject_errors, int, 0644);
 MODULE_PARM_DESC(brw_inject_errors, "# data errors to inject randomly, zero by default");
 
 static void
-brw_client_fini(sfw_test_instance_t *tsi)
+brw_client_fini(struct sfw_test_instance *tsi)
 {
 	struct srpc_bulk *bulk;
 	sfw_test_unit_t	*tsu;
@@ -67,7 +67,7 @@ brw_client_fini(sfw_test_instance_t *tsi)
 }
 
 static int
-brw_client_init(sfw_test_instance_t *tsi)
+brw_client_init(struct sfw_test_instance *tsi)
 {
 	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	int flags;
@@ -258,7 +258,7 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 		    lnet_process_id_t dest, struct srpc_client_rpc **rpcpp)
 {
 	struct srpc_bulk *bulk = tsu->tsu_private;
-	sfw_test_instance_t *tsi = tsu->tsu_instance;
+	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	struct srpc_client_rpc *rpc;
 	srpc_brw_reqst_t *req;
@@ -316,7 +316,7 @@ static void
 brw_client_done_rpc(sfw_test_unit_t *tsu, struct srpc_client_rpc *rpc)
 {
 	__u64 magic = BRW_MAGIC;
-	sfw_test_instance_t *tsi = tsu->tsu_instance;
+	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	srpc_msg_t *msg = &rpc->crpc_replymsg;
 	srpc_brw_reply_t *reply = &msg->msg_body.brw_reply;
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index d42ee18..5cc4807 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -529,7 +529,7 @@ static void
 sfw_test_rpc_fini(struct srpc_client_rpc *rpc)
 {
 	sfw_test_unit_t *tsu = rpc->crpc_priv;
-	sfw_test_instance_t *tsi = tsu->tsu_instance;
+	struct sfw_test_instance *tsi = tsu->tsu_instance;
 
 	/* Called with hold of tsi->tsi_lock */
 	LASSERT(list_empty(&rpc->crpc_list));
@@ -537,7 +537,7 @@ sfw_test_rpc_fini(struct srpc_client_rpc *rpc)
 }
 
 static inline int
-sfw_test_buffers(sfw_test_instance_t *tsi)
+sfw_test_buffers(struct sfw_test_instance *tsi)
 {
 	struct sfw_test_case *tsc;
 	struct srpc_service *svc;
@@ -614,7 +614,7 @@ sfw_unload_test(struct sfw_test_instance *tsi)
 }
 
 static void
-sfw_destroy_test_instance(sfw_test_instance_t *tsi)
+sfw_destroy_test_instance(struct sfw_test_instance *tsi)
 {
 	struct srpc_client_rpc *rpc;
 	sfw_test_unit_t *tsu;
@@ -650,14 +650,14 @@ clean:
 static void
 sfw_destroy_batch(struct sfw_batch *tsb)
 {
-	sfw_test_instance_t *tsi;
+	struct sfw_test_instance *tsi;
 
 	LASSERT(!sfw_batch_active(tsb));
 	LASSERT(list_empty(&tsb->bat_list));
 
 	while (!list_empty(&tsb->bat_tests)) {
 		tsi = list_entry(tsb->bat_tests.next,
-				 sfw_test_instance_t, tsi_list);
+				 struct sfw_test_instance, tsi_list);
 		list_del_init(&tsi->tsi_list);
 		sfw_destroy_test_instance(tsi);
 	}
@@ -736,7 +736,7 @@ sfw_add_test_instance(struct sfw_batch *tsb, struct srpc_server_rpc *rpc)
 	struct srpc_bulk *bk = rpc->srpc_bulk;
 	int ndest = req->tsr_ndest;
 	sfw_test_unit_t *tsu;
-	sfw_test_instance_t *tsi;
+	struct sfw_test_instance *tsi;
 	int i;
 	int rc;
 
@@ -826,7 +826,7 @@ error:
 static void
 sfw_test_unit_done(sfw_test_unit_t *tsu)
 {
-	sfw_test_instance_t *tsi = tsu->tsu_instance;
+	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct sfw_batch *tsb = tsi->tsi_batch;
 	struct sfw_session *sn = tsb->bat_session;
 
@@ -869,7 +869,7 @@ static void
 sfw_test_rpc_done(struct srpc_client_rpc *rpc)
 {
 	sfw_test_unit_t *tsu = rpc->crpc_priv;
-	sfw_test_instance_t *tsi = tsu->tsu_instance;
+	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	int done = 0;
 
 	tsi->tsi_ops->tso_done_rpc(tsu, rpc);
@@ -905,7 +905,7 @@ sfw_create_test_rpc(sfw_test_unit_t *tsu, lnet_process_id_t peer,
 		    struct srpc_client_rpc **rpcpp)
 {
 	struct srpc_client_rpc *rpc = NULL;
-	sfw_test_instance_t *tsi = tsu->tsu_instance;
+	struct sfw_test_instance *tsi = tsu->tsu_instance;
 
 	spin_lock(&tsi->tsi_lock);
 
@@ -945,7 +945,7 @@ static int
 sfw_run_test(struct swi_workitem *wi)
 {
 	sfw_test_unit_t *tsu = wi->swi_workitem.wi_data;
-	sfw_test_instance_t *tsi = tsu->tsu_instance;
+	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct srpc_client_rpc *rpc = NULL;
 
 	LASSERT(wi == &tsu->tsu_worker);
@@ -995,7 +995,7 @@ sfw_run_batch(struct sfw_batch *tsb)
 {
 	struct swi_workitem *wi;
 	sfw_test_unit_t *tsu;
-	sfw_test_instance_t *tsi;
+	struct sfw_test_instance *tsi;
 
 	if (sfw_batch_active(tsb)) {
 		CDEBUG(D_NET, "Batch already active: %llu (%d)\n",
@@ -1028,7 +1028,7 @@ sfw_run_batch(struct sfw_batch *tsb)
 int
 sfw_stop_batch(struct sfw_batch *tsb, int force)
 {
-	sfw_test_instance_t *tsi;
+	struct sfw_test_instance *tsi;
 	struct srpc_client_rpc *rpc;
 
 	if (!sfw_batch_active(tsb)) {
@@ -1070,7 +1070,7 @@ sfw_stop_batch(struct sfw_batch *tsb, int force)
 static int
 sfw_query_batch(struct sfw_batch *tsb, int testidx, srpc_batch_reply_t *reply)
 {
-	sfw_test_instance_t *tsi;
+	struct sfw_test_instance *tsi;
 
 	if (testidx < 0)
 		return -EINVAL;
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index be13004..4e45428 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -56,7 +56,7 @@ struct lst_ping_data {
 static struct lst_ping_data  lst_ping_data;
 
 static int
-ping_client_init(sfw_test_instance_t *tsi)
+ping_client_init(struct sfw_test_instance *tsi)
 {
 	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 
@@ -70,7 +70,7 @@ ping_client_init(sfw_test_instance_t *tsi)
 }
 
 static void
-ping_client_fini(sfw_test_instance_t *tsi)
+ping_client_fini(struct sfw_test_instance *tsi)
 {
 	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	int errors;
@@ -90,7 +90,7 @@ ping_client_prep_rpc(sfw_test_unit_t *tsu, lnet_process_id_t dest,
 		     struct srpc_client_rpc **rpc)
 {
 	srpc_ping_reqst_t *req;
-	sfw_test_instance_t *tsi = tsu->tsu_instance;
+	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	struct timespec64 ts;
 	int rc;
@@ -120,7 +120,7 @@ ping_client_prep_rpc(sfw_test_unit_t *tsu, lnet_process_id_t dest,
 static void
 ping_client_done_rpc(sfw_test_unit_t *tsu, struct srpc_client_rpc *rpc)
 {
-	sfw_test_instance_t *tsi = tsu->tsu_instance;
+	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	srpc_ping_reqst_t *reqst = &rpc->crpc_reqstmsg.msg_body.ping_reqst;
 	srpc_ping_reply_t *reply = &rpc->crpc_replymsg.msg_body.ping_reply;
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index b536e98..75743dd 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -362,7 +362,7 @@ struct sfw_test_client_ops {
 			     struct srpc_client_rpc *rpc);	/* done a test rpc */
 };
 
-typedef struct sfw_test_instance {
+struct sfw_test_instance {
 	struct list_head	   tsi_list;		/* chain on batch */
 	int			   tsi_service;		/* test type */
 	struct sfw_batch		*tsi_batch;	/* batch */
@@ -389,7 +389,7 @@ typedef struct sfw_test_instance {
 		test_bulk_req_t    bulk_v0; /* bulk parameter */
 		test_bulk_req_v1_t bulk_v1; /* bulk v1 parameter */
 	} tsi_u;
-} sfw_test_instance_t;
+};
 
 /* XXX: trailing (PAGE_CACHE_SIZE % sizeof(lnet_process_id_t)) bytes at
  * the end of pages are not used */
@@ -402,7 +402,7 @@ typedef struct sfw_test_unit {
 	struct list_head    tsu_list;	   /* chain on lst_test_instance */
 	lnet_process_id_t   tsu_dest;	   /* id of dest node */
 	int		    tsu_loop;	   /* loop count of the test */
-	sfw_test_instance_t *tsu_instance; /* pointer to test instance */
+	struct sfw_test_instance	*tsu_instance; /* pointer to test instance */
 	void		    *tsu_private;  /* private data */
 	struct swi_workitem	tsu_worker;	/* workitem of the test unit */
 } sfw_test_unit_t;
-- 
1.7.1
