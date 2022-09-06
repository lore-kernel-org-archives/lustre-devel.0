Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 18223ECAAD3
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:56:10 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7lY4nDlz1yBy;
	Mon,  5 Sep 2022 18:56:09 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7l82q4Fz1y2G
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:48 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id BDC3E100B004;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B96D458999; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:23 -0400
Message-Id: <1662429337-18737-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/24] lnet: selftest: use preallocate bulk
 for server
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Alexey Lyashkov <alexey.lyashkov@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexey Lyashkov <alexey.lyashkov@hpe.com>

Server side want to have a preallocate bulk to avoid large lock
contention on the page cache.
Without it LST limited with 35Gb/s speed with 3 rail host (HDR each)
due large CPU usage.
Preallocate bulks increase a memory consumption for small bulk,
but performance improved dramatically up to 74Gb/s with very low
cpu usage.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16011
Lustre-commit: 2447564e120cf6226 ("LU-16011 lnet: use preallocate bulk for server")
Signed-off-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-on: https://review.whamcloud.com/47952
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/selftest/brw_test.c  | 67 ++++++++++++++++++++++++++++++-------------
 net/lnet/selftest/framework.c | 18 +++++-------
 net/lnet/selftest/rpc.c       | 51 +++++++++++++++++++++-----------
 net/lnet/selftest/selftest.h  | 15 ++++++----
 4 files changed, 99 insertions(+), 52 deletions(-)

diff --git a/net/lnet/selftest/brw_test.c b/net/lnet/selftest/brw_test.c
index 87ad765..a00b731 100644
--- a/net/lnet/selftest/brw_test.c
+++ b/net/lnet/selftest/brw_test.c
@@ -124,11 +124,12 @@
 
 	list_for_each_entry(tsu, &tsi->tsi_units, tsu_list) {
 		bulk = srpc_alloc_bulk(lnet_cpt_of_nid(tsu->tsu_dest.nid, NULL),
-				       off, npg, len, opc == LST_BRW_READ);
+				       npg);
 		if (!bulk) {
 			brw_client_fini(tsi);
 			return -ENOMEM;
 		}
+		srpc_init_bulk(bulk, off, npg, len, opc == LST_BRW_READ);
 
 		tsu->tsu_private = bulk;
 	}
@@ -389,8 +390,6 @@ static int brw_inject_one_error(void)
 		CDEBUG(D_NET, "Transferred %d pages bulk data %s %s\n",
 		       blk->bk_niov, blk->bk_sink ? "from" : "to",
 		       libcfs_id2str(rpc->srpc_peer));
-
-	sfw_free_pages(rpc);
 }
 
 static int
@@ -438,7 +437,6 @@ static int brw_inject_one_error(void)
 	struct srpc_brw_reply *reply = &replymsg->msg_body.brw_reply;
 	struct srpc_brw_reqst *reqst = &reqstmsg->msg_body.brw_reqst;
 	int npg;
-	int rc;
 
 	LASSERT(sv->sv_id == SRPC_SERVICE_BRW);
 
@@ -489,11 +487,8 @@ static int brw_inject_one_error(void)
 		return 0;
 	}
 
-	rc = sfw_alloc_pages(rpc, rpc->srpc_scd->scd_cpt, npg,
-			     reqst->brw_len,
-			     reqst->brw_rw == LST_BRW_WRITE);
-	if (rc)
-		return rc;
+	srpc_init_bulk(rpc->srpc_bulk, 0, npg, reqst->brw_len,
+		       reqst->brw_rw == LST_BRW_WRITE);
 
 	if (reqst->brw_rw == LST_BRW_READ)
 		brw_fill_bulk(rpc->srpc_bulk, reqst->brw_flags, BRW_MAGIC);
@@ -503,23 +498,55 @@ static int brw_inject_one_error(void)
 	return 0;
 }
 
-struct sfw_test_client_ops brw_test_client;
+static int
+brw_srpc_init(struct srpc_server_rpc *rpc, int cpt)
+{
+	/* just alloc a maximal size - actual values will be adjusted later */
+	rpc->srpc_bulk = srpc_alloc_bulk(cpt, LNET_MAX_IOV);
+	if (!rpc->srpc_bulk)
+		return -ENOMEM;
+
+	srpc_init_bulk(rpc->srpc_bulk, 0, LNET_MAX_IOV, 0, 0);
+
+	return 0;
+}
 
-void brw_init_test_client(void)
+static void
+brw_srpc_fini(struct srpc_server_rpc *rpc)
 {
-	brw_test_client.tso_init = brw_client_init;
-	brw_test_client.tso_fini = brw_client_fini;
-	brw_test_client.tso_prep_rpc = brw_client_prep_rpc;
-	brw_test_client.tso_done_rpc = brw_client_done_rpc;
+	/* server RPC have just MAX_IOV size */
+	srpc_init_bulk(rpc->srpc_bulk, 0, LNET_MAX_IOV, 0, 0);
+
+	srpc_free_bulk(rpc->srpc_bulk);
+	rpc->srpc_bulk = NULL;
+}
+
+struct sfw_test_client_ops brw_test_client = {
+	.tso_init	= brw_client_init,
+	.tso_fini	= brw_client_fini,
+	.tso_prep_rpc	= brw_client_prep_rpc,
+	.tso_done_rpc	= brw_client_done_rpc,
 };
 
-struct srpc_service brw_test_service;
+struct srpc_service brw_test_service = {
+	.sv_id		= SRPC_SERVICE_BRW,
+	.sv_name	= "brw_test",
+	.sv_handler	= brw_server_handle,
+	.sv_bulk_ready	= brw_bulk_ready,
+
+	.sv_srpc_init	= brw_srpc_init,
+	.sv_srpc_fini	= brw_srpc_fini,
+};
 
 void brw_init_test_service(void)
 {
-	brw_test_service.sv_id = SRPC_SERVICE_BRW;
-	brw_test_service.sv_name = "brw_test";
-	brw_test_service.sv_handler = brw_server_handle;
-	brw_test_service.sv_bulk_ready = brw_bulk_ready;
+	unsigned long cache_size = totalram_pages() >> 1;
+
+	/* brw prealloc cache should don't eat more than half memory */
+	cache_size /= LNET_MAX_IOV;
+
 	brw_test_service.sv_wi_total = brw_srv_workitems;
+
+	if (brw_test_service.sv_wi_total > cache_size)
+		brw_test_service.sv_wi_total = cache_size;
 }
diff --git a/net/lnet/selftest/framework.c b/net/lnet/selftest/framework.c
index e84904e..121bdf0 100644
--- a/net/lnet/selftest/framework.c
+++ b/net/lnet/selftest/framework.c
@@ -290,8 +290,10 @@
 	       swi_state2str(rpc->srpc_wi.swi_state),
 	       status);
 
-	if (rpc->srpc_bulk)
-		sfw_free_pages(rpc);
+	if (rpc->srpc_bulk) {
+		srpc_free_bulk(rpc->srpc_bulk);
+		rpc->srpc_bulk = NULL;
+	}
 }
 
 static void
@@ -1088,13 +1090,6 @@
 	return -ENOENT;
 }
 
-void
-sfw_free_pages(struct srpc_server_rpc *rpc)
-{
-	srpc_free_bulk(rpc->srpc_bulk);
-	rpc->srpc_bulk = NULL;
-}
-
 int
 sfw_alloc_pages(struct srpc_server_rpc *rpc, int cpt, int npages, int len,
 		int sink)
@@ -1102,10 +1097,12 @@
 	LASSERT(!rpc->srpc_bulk);
 	LASSERT(npages > 0 && npages <= LNET_MAX_IOV);
 
-	rpc->srpc_bulk = srpc_alloc_bulk(cpt, 0, npages, len, sink);
+	rpc->srpc_bulk = srpc_alloc_bulk(cpt, npages);
 	if (!rpc->srpc_bulk)
 		return -ENOMEM;
 
+	srpc_init_bulk(rpc->srpc_bulk, 0, npages, len, sink);
+
 	return 0;
 }
 
@@ -1629,7 +1626,6 @@ struct srpc_client_rpc *
 	INIT_LIST_HEAD(&sfw_data.fw_zombie_rpcs);
 	INIT_LIST_HEAD(&sfw_data.fw_zombie_sessions);
 
-	brw_init_test_client();
 	brw_init_test_service();
 	rc = sfw_register_test(&brw_test_service, &brw_test_client);
 	LASSERT(!rc);
diff --git a/net/lnet/selftest/rpc.c b/net/lnet/selftest/rpc.c
index c376019..b9d8211 100644
--- a/net/lnet/selftest/rpc.c
+++ b/net/lnet/selftest/rpc.c
@@ -109,14 +109,12 @@ void srpc_get_counters(struct srpc_counters *cnt)
 }
 
 static int
-srpc_add_bulk_page(struct srpc_bulk *bk, struct page *pg, int i, int off,
-		   int nob)
+srpc_init_bulk_page(struct srpc_bulk *bk, int i, int off, int nob)
 {
 	LASSERT(off < PAGE_SIZE);
 	LASSERT(nob > 0 && nob <= PAGE_SIZE);
 
 	bk->bk_iovs[i].bv_offset = off;
-	bk->bk_iovs[i].bv_page = pg;
 	bk->bk_iovs[i].bv_len = nob;
 	return nob;
 }
@@ -140,9 +138,7 @@ void srpc_get_counters(struct srpc_counters *cnt)
 	kfree(bk);
 }
 
-struct srpc_bulk *
-srpc_alloc_bulk(int cpt, unsigned int bulk_off, unsigned int bulk_npg,
-		unsigned int bulk_len, int sink)
+struct srpc_bulk *srpc_alloc_bulk(int cpt, unsigned int bulk_npg)
 {
 	struct srpc_bulk *bk;
 	int i;
@@ -157,13 +153,10 @@ struct srpc_bulk *
 	}
 
 	memset(bk, 0, offsetof(struct srpc_bulk, bk_iovs[bulk_npg]));
-	bk->bk_sink = sink;
-	bk->bk_len = bulk_len;
 	bk->bk_niov = bulk_npg;
 
 	for (i = 0; i < bulk_npg; i++) {
 		struct page *pg;
-		int nob;
 
 		pg = alloc_pages_node(cfs_cpt_spread_node(lnet_cpt_table(),
 							  cpt),
@@ -173,15 +166,37 @@ struct srpc_bulk *
 			srpc_free_bulk(bk);
 			return NULL;
 		}
+		bk->bk_iovs[i].bv_page   = pg;
+	}
+
+	return bk;
+}
+
+void
+srpc_init_bulk(struct srpc_bulk *bk, unsigned int bulk_off,
+	       unsigned int bulk_npg, unsigned int bulk_len, int sink)
+{
+	int i;
+
+	LASSERT(bk);
+	LASSERT(bulk_npg > 0 && bulk_npg <= LNET_MAX_IOV);
+
+	bk->bk_sink = sink;
+	bk->bk_len = bulk_len;
+	bk->bk_niov = bulk_npg;
+
+	for (i = 0; i < bulk_npg && bulk_len > 0; i++) {
+		int nob;
+
+		LASSERT(bk->bk_iovs[i].bv_page);
 
 		nob = min_t(unsigned int, bulk_off + bulk_len, PAGE_SIZE) -
 		      bulk_off;
-		srpc_add_bulk_page(bk, pg, i, bulk_off, nob);
+
+		srpc_init_bulk_page(bk, i, bulk_off, nob);
 		bulk_len -= nob;
 		bulk_off = 0;
 	}
-
-	return bk;
 }
 
 static inline u64
@@ -195,7 +210,6 @@ struct srpc_bulk *
 		     struct srpc_service_cd *scd,
 		     struct srpc_buffer *buffer)
 {
-	memset(rpc, 0, sizeof(*rpc));
 	swi_init_workitem(&rpc->srpc_wi, srpc_handle_rpc,
 			  srpc_serv_is_framework(scd->scd_svc) ?
 			  lst_serial_wq : lst_test_wq[scd->scd_cpt]);
@@ -207,6 +221,9 @@ struct srpc_bulk *
 	rpc->srpc_peer = buffer->buf_peer;
 	rpc->srpc_self = buffer->buf_self;
 	LNetInvalidateMDHandle(&rpc->srpc_replymdh);
+
+	rpc->srpc_aborted  = 0;
+	rpc->srpc_status   = 0;
 }
 
 static void
@@ -244,6 +261,8 @@ struct srpc_bulk *
 						       struct srpc_server_rpc,
 						       srpc_list)) != NULL) {
 			list_del(&rpc->srpc_list);
+			if (svc->sv_srpc_fini)
+				svc->sv_srpc_fini(rpc);
 			kfree(rpc);
 		}
 	}
@@ -314,7 +333,8 @@ struct srpc_bulk *
 
 		for (j = 0; j < nrpcs; j++) {
 			rpc = kzalloc_cpt(sizeof(*rpc), GFP_NOFS, i);
-			if (!rpc) {
+			if (!rpc ||
+			    (svc->sv_srpc_init && svc->sv_srpc_init(rpc, i))) {
 				srpc_service_fini(svc);
 				return -ENOMEM;
 			}
@@ -946,8 +966,7 @@ struct srpc_bulk *
 		atomic_inc(&RPC_STAT32(SRPC_RPC_DROP));
 
 	if (rpc->srpc_done)
-		(*rpc->srpc_done) (rpc);
-	LASSERT(!rpc->srpc_bulk);
+		(*rpc->srpc_done)(rpc);
 
 	spin_lock(&scd->scd_lock);
 
diff --git a/net/lnet/selftest/selftest.h b/net/lnet/selftest/selftest.h
index 223a432..8ae258d 100644
--- a/net/lnet/selftest/selftest.h
+++ b/net/lnet/selftest/selftest.h
@@ -316,6 +316,12 @@ struct srpc_service {
 	 */
 	int (*sv_handler)(struct srpc_server_rpc *);
 	int (*sv_bulk_ready)(struct srpc_server_rpc *, int);
+
+	/** Service side srpc constructor/destructor.
+	 *  used for the bulk preallocation as usual.
+	 */
+	int (*sv_srpc_init)(struct srpc_server_rpc *rpc, int cpt);
+	void (*sv_srpc_fini)(struct srpc_server_rpc *rpc);
 };
 
 struct sfw_session {
@@ -424,7 +430,6 @@ int sfw_create_test_rpc(struct sfw_test_unit *tsu,
 void sfw_post_rpc(struct srpc_client_rpc *rpc);
 void sfw_client_rpc_done(struct srpc_client_rpc *rpc);
 void sfw_unpack_message(struct srpc_msg *msg);
-void sfw_free_pages(struct srpc_server_rpc *rpc);
 void sfw_add_bulk_page(struct srpc_bulk *bk, struct page *pg, int i);
 int sfw_alloc_pages(struct srpc_server_rpc *rpc, int cpt, int npages, int len,
 		    int sink);
@@ -439,9 +444,10 @@ struct srpc_client_rpc *
 void srpc_post_rpc(struct srpc_client_rpc *rpc);
 void srpc_abort_rpc(struct srpc_client_rpc *rpc, int why);
 void srpc_free_bulk(struct srpc_bulk *bk);
-struct srpc_bulk *srpc_alloc_bulk(int cpt, unsigned int off,
-				  unsigned int bulk_npg, unsigned int bulk_len,
-				  int sink);
+struct srpc_bulk *srpc_alloc_bulk(int cpt, unsigned int bulk_npg);
+void srpc_init_bulk(struct srpc_bulk *bk, unsigned int off,
+		    unsigned int bulk_npg, unsigned int bulk_len, int sink);
+
 void srpc_send_rpc(struct swi_workitem *wi);
 int srpc_send_reply(struct srpc_server_rpc *rpc);
 int srpc_add_service(struct srpc_service *sv);
@@ -605,7 +611,6 @@ struct srpc_bulk *srpc_alloc_bulk(int cpt, unsigned int off,
 }
 
 extern struct sfw_test_client_ops brw_test_client;
-void brw_init_test_client(void);
 
 extern struct srpc_service brw_test_service;
 void brw_init_test_service(void);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
