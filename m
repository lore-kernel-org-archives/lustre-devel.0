From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:38 -0400
Subject: [lustre-devel] [PATCH 12/24] staging: lustre: selftest: convert
	sfw_test_unit_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef sfw_test_unit_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c  |    8 ++++----
 drivers/staging/lustre/lnet/selftest/framework.c |   20 ++++++++++----------
 drivers/staging/lustre/lnet/selftest/ping_test.c |    4 ++--
 drivers/staging/lustre/lnet/selftest/selftest.h  |    6 +++---
 4 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 90fabd0..3455990 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -52,7 +52,7 @@ static void
 brw_client_fini(struct sfw_test_instance *tsi)
 {
 	struct srpc_bulk *bulk;
-	sfw_test_unit_t	*tsu;
+	struct sfw_test_unit	*tsu;
 
 	LASSERT(tsi->tsi_is_client);
 
@@ -75,7 +75,7 @@ brw_client_init(struct sfw_test_instance *tsi)
 	int len;
 	int opc;
 	struct srpc_bulk *bulk;
-	sfw_test_unit_t *tsu;
+	struct sfw_test_unit *tsu;
 
 	LASSERT(sn);
 	LASSERT(tsi->tsi_is_client);
@@ -254,7 +254,7 @@ brw_check_bulk(struct srpc_bulk *bk, int pattern, __u64 magic)
 }
 
 static int
-brw_client_prep_rpc(sfw_test_unit_t *tsu,
+brw_client_prep_rpc(struct sfw_test_unit *tsu,
 		    lnet_process_id_t dest, struct srpc_client_rpc **rpcpp)
 {
 	struct srpc_bulk *bulk = tsu->tsu_private;
@@ -313,7 +313,7 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 }
 
 static void
-brw_client_done_rpc(sfw_test_unit_t *tsu, struct srpc_client_rpc *rpc)
+brw_client_done_rpc(struct sfw_test_unit *tsu, struct srpc_client_rpc *rpc)
 {
 	__u64 magic = BRW_MAGIC;
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 5cc4807..8d364b0 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -528,7 +528,7 @@ sfw_debug_session(srpc_debug_reqst_t *request, srpc_debug_reply_t *reply)
 static void
 sfw_test_rpc_fini(struct srpc_client_rpc *rpc)
 {
-	sfw_test_unit_t *tsu = rpc->crpc_priv;
+	struct sfw_test_unit *tsu = rpc->crpc_priv;
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
 
 	/* Called with hold of tsi->tsi_lock */
@@ -617,7 +617,7 @@ static void
 sfw_destroy_test_instance(struct sfw_test_instance *tsi)
 {
 	struct srpc_client_rpc *rpc;
-	sfw_test_unit_t *tsu;
+	struct sfw_test_unit *tsu;
 
 	if (!tsi->tsi_is_client)
 		goto clean;
@@ -630,7 +630,7 @@ sfw_destroy_test_instance(struct sfw_test_instance *tsi)
 
 	while (!list_empty(&tsi->tsi_units)) {
 		tsu = list_entry(tsi->tsi_units.next,
-				 sfw_test_unit_t, tsu_list);
+				 struct sfw_test_unit, tsu_list);
 		list_del(&tsu->tsu_list);
 		LIBCFS_FREE(tsu, sizeof(*tsu));
 	}
@@ -735,7 +735,7 @@ sfw_add_test_instance(struct sfw_batch *tsb, struct srpc_server_rpc *rpc)
 	srpc_test_reqst_t *req = &msg->msg_body.tes_reqst;
 	struct srpc_bulk *bk = rpc->srpc_bulk;
 	int ndest = req->tsr_ndest;
-	sfw_test_unit_t *tsu;
+	struct sfw_test_unit *tsu;
 	struct sfw_test_instance *tsi;
 	int i;
 	int rc;
@@ -795,7 +795,7 @@ sfw_add_test_instance(struct sfw_batch *tsb, struct srpc_server_rpc *rpc)
 			sfw_unpack_id(id);
 
 		for (j = 0; j < tsi->tsi_concur; j++) {
-			LIBCFS_ALLOC(tsu, sizeof(sfw_test_unit_t));
+			LIBCFS_ALLOC(tsu, sizeof(struct sfw_test_unit));
 			if (!tsu) {
 				rc = -ENOMEM;
 				CERROR("Can't allocate tsu for %d\n",
@@ -824,7 +824,7 @@ error:
 }
 
 static void
-sfw_test_unit_done(sfw_test_unit_t *tsu)
+sfw_test_unit_done(struct sfw_test_unit *tsu)
 {
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct sfw_batch *tsb = tsi->tsi_batch;
@@ -868,7 +868,7 @@ sfw_test_unit_done(sfw_test_unit_t *tsu)
 static void
 sfw_test_rpc_done(struct srpc_client_rpc *rpc)
 {
-	sfw_test_unit_t *tsu = rpc->crpc_priv;
+	struct sfw_test_unit *tsu = rpc->crpc_priv;
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	int done = 0;
 
@@ -900,7 +900,7 @@ sfw_test_rpc_done(struct srpc_client_rpc *rpc)
 }
 
 int
-sfw_create_test_rpc(sfw_test_unit_t *tsu, lnet_process_id_t peer,
+sfw_create_test_rpc(struct sfw_test_unit *tsu, lnet_process_id_t peer,
 		    unsigned features, int nblk, int blklen,
 		    struct srpc_client_rpc **rpcpp)
 {
@@ -944,7 +944,7 @@ sfw_create_test_rpc(sfw_test_unit_t *tsu, lnet_process_id_t peer,
 static int
 sfw_run_test(struct swi_workitem *wi)
 {
-	sfw_test_unit_t *tsu = wi->swi_workitem.wi_data;
+	struct sfw_test_unit *tsu = wi->swi_workitem.wi_data;
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct srpc_client_rpc *rpc = NULL;
 
@@ -994,7 +994,7 @@ static int
 sfw_run_batch(struct sfw_batch *tsb)
 {
 	struct swi_workitem *wi;
-	sfw_test_unit_t *tsu;
+	struct sfw_test_unit *tsu;
 	struct sfw_test_instance *tsi;
 
 	if (sfw_batch_active(tsb)) {
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index 4e45428..c6f2caa 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -86,7 +86,7 @@ ping_client_fini(struct sfw_test_instance *tsi)
 }
 
 static int
-ping_client_prep_rpc(sfw_test_unit_t *tsu, lnet_process_id_t dest,
+ping_client_prep_rpc(struct sfw_test_unit *tsu, lnet_process_id_t dest,
 		     struct srpc_client_rpc **rpc)
 {
 	srpc_ping_reqst_t *req;
@@ -118,7 +118,7 @@ ping_client_prep_rpc(sfw_test_unit_t *tsu, lnet_process_id_t dest,
 }
 
 static void
-ping_client_done_rpc(sfw_test_unit_t *tsu, struct srpc_client_rpc *rpc)
+ping_client_done_rpc(struct sfw_test_unit *tsu, struct srpc_client_rpc *rpc)
 {
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct sfw_session *sn = tsi->tsi_batch->bat_session;
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 75743dd..f08bc70 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -398,14 +398,14 @@ struct sfw_test_instance {
 #define SFW_MAX_NDESTS	   (LNET_MAX_IOV * SFW_ID_PER_PAGE)
 #define sfw_id_pages(n)    (((n) + SFW_ID_PER_PAGE - 1) / SFW_ID_PER_PAGE)
 
-typedef struct sfw_test_unit {
+struct sfw_test_unit {
 	struct list_head    tsu_list;	   /* chain on lst_test_instance */
 	lnet_process_id_t   tsu_dest;	   /* id of dest node */
 	int		    tsu_loop;	   /* loop count of the test */
 	struct sfw_test_instance	*tsu_instance; /* pointer to test instance */
 	void		    *tsu_private;  /* private data */
 	struct swi_workitem	tsu_worker;	/* workitem of the test unit */
-} sfw_test_unit_t;
+};
 
 typedef struct sfw_test_case {
 	struct list_head      tsc_list;		/* chain on fw_tests */
@@ -417,7 +417,7 @@ struct srpc_client_rpc *
 sfw_create_rpc(lnet_process_id_t peer, int service,
 	       unsigned features, int nbulkiov, int bulklen,
 	       void (*done)(struct srpc_client_rpc *), void *priv);
-int sfw_create_test_rpc(sfw_test_unit_t *tsu,
+int sfw_create_test_rpc(struct sfw_test_unit *tsu,
 			lnet_process_id_t peer, unsigned features,
 			int nblk, int blklen, struct srpc_client_rpc **rpc);
 void sfw_abort_rpc(struct srpc_client_rpc *rpc);
-- 
1.7.1
