From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:31:04 -0500
Subject: [lustre-devel] [PATCH 34/35] staging: lustre: lnet: add offset for
	selftest brw
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-35-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>, James Simmons <jsimmons@infradead.org>

From: Liang Zhen <liang.zhen@intel.com>

In current lnet selftest, both client and server side bulk have
no offset and we can only test page aligned IO, this patch changed
this:

- user can set brw offset by lst add_test ... brw off=OFFSET ...
- offset is only effective on client side so far
- to simply implementation, offset needs to be eight bytes aligned

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5718
Reviewed-on: http://review.whamcloud.com/12496
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h |    2 +
 drivers/staging/lustre/lnet/selftest/brw_test.c    |   73 ++++++++++++-------
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    8 ++-
 drivers/staging/lustre/lnet/selftest/framework.c   |    2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |   19 +++--
 drivers/staging/lustre/lnet/selftest/rpc.h         |    2 +-
 drivers/staging/lustre/lnet/selftest/selftest.h    |    5 +-
 7 files changed, 69 insertions(+), 42 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index 4170445..78f825d 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -490,6 +490,8 @@
 	int	blk_size;       /* size (bytes) */
 	int	blk_time;       /* time of running the test*/
 	int	blk_flags;      /* reserved flags */
+	int	blk_cli_off;	/* bulk offset on client */
+	int	blk_srv_off;	/* reserved: bulk offset on server */
 } lst_test_bulk_param_t;
 
 typedef struct {
diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index b20c5d3..67b460f 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -44,6 +44,10 @@
 module_param(brw_inject_errors, int, 0644);
 MODULE_PARM_DESC(brw_inject_errors, "# data errors to inject randomly, zero by default");
 
+#define BRW_POISON	0xbeefbeefbeefbeefULL
+#define BRW_MAGIC	0xeeb0eeb1eeb2eeb3ULL
+#define BRW_MSIZE	sizeof(u64)
+
 static void
 brw_client_fini(struct sfw_test_instance *tsi)
 {
@@ -67,6 +71,7 @@
 {
 	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	int flags;
+	int off;
 	int npg;
 	int len;
 	int opc;
@@ -87,6 +92,7 @@
 		 * but we have to keep it for compatibility
 		 */
 		len = npg * PAGE_SIZE;
+		off = 0;
 	} else {
 		struct test_bulk_req_v1 *breq = &tsi->tsi_u.bulk_v1;
 
@@ -99,9 +105,13 @@
 		opc = breq->blk_opc;
 		flags = breq->blk_flags;
 		len = breq->blk_len;
-		npg = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
+		off = breq->blk_offset & ~PAGE_MASK;
+		npg = (off + len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	}
 
+	if (off % BRW_MSIZE)
+		return -EINVAL;
+
 	if (npg > LNET_MAX_IOV || npg <= 0)
 		return -EINVAL;
 
@@ -114,7 +124,7 @@
 
 	list_for_each_entry(tsu, &tsi->tsi_units, tsu_list) {
 		bulk = srpc_alloc_bulk(lnet_cpt_of_nid(tsu->tsu_dest.nid),
-				       npg, len, opc == LST_BRW_READ);
+				       off, npg, len, opc == LST_BRW_READ);
 		if (!bulk) {
 			brw_client_fini(tsi);
 			return -ENOMEM;
@@ -126,12 +136,7 @@
 	return 0;
 }
 
-#define BRW_POISON	0xbeefbeefbeefbeefULL
-#define BRW_MAGIC	0xeeb0eeb1eeb2eeb3ULL
-#define BRW_MSIZE	sizeof(__u64)
-
-static int
-brw_inject_one_error(void)
+int brw_inject_one_error(void)
 {
 	struct timespec64 ts;
 
@@ -147,12 +152,13 @@
 }
 
 static void
-brw_fill_page(struct page *pg, int pattern, __u64 magic)
+brw_fill_page(struct page *pg, int off, int len, int pattern, __u64 magic)
 {
-	char *addr = page_address(pg);
+	char *addr = page_address(pg) + off;
 	int i;
 
 	LASSERT(addr);
+	LASSERT(!(off % BRW_MSIZE) && !(len % BRW_MSIZE));
 
 	if (pattern == LST_BRW_CHECK_NONE)
 		return;
@@ -162,14 +168,16 @@
 
 	if (pattern == LST_BRW_CHECK_SIMPLE) {
 		memcpy(addr, &magic, BRW_MSIZE);
-		addr += PAGE_SIZE - BRW_MSIZE;
-		memcpy(addr, &magic, BRW_MSIZE);
+		if (len > BRW_MSIZE) {
+			addr += PAGE_SIZE - BRW_MSIZE;
+			memcpy(addr, &magic, BRW_MSIZE);
+		}
 		return;
 	}
 
 	if (pattern == LST_BRW_CHECK_FULL) {
-		for (i = 0; i < PAGE_SIZE / BRW_MSIZE; i++)
-			memcpy(addr + i * BRW_MSIZE, &magic, BRW_MSIZE);
+		for (i = 0; i < len; i += BRW_MSIZE)
+			memcpy(addr + i, &magic, BRW_MSIZE);
 		return;
 	}
 
@@ -177,13 +185,14 @@
 }
 
 static int
-brw_check_page(struct page *pg, int pattern, __u64 magic)
+brw_check_page(struct page *pg, int off, int len, int pattern, __u64 magic)
 {
-	char *addr = page_address(pg);
+	char *addr = page_address(pg) + off;
 	__u64 data = 0; /* make compiler happy */
 	int i;
 
 	LASSERT(addr);
+	LASSERT(!(off % BRW_MSIZE) && !(len % BRW_MSIZE));
 
 	if (pattern == LST_BRW_CHECK_NONE)
 		return 0;
@@ -193,21 +202,21 @@
 		if (data != magic)
 			goto bad_data;
 
-		addr += PAGE_SIZE - BRW_MSIZE;
-		data = *((__u64 *)addr);
-		if (data != magic)
-			goto bad_data;
-
+		if (len > BRW_MSIZE) {
+			addr += PAGE_SIZE - BRW_MSIZE;
+			data = *((__u64 *)addr);
+			if (data != magic)
+				goto bad_data;
+		}
 		return 0;
 	}
 
 	if (pattern == LST_BRW_CHECK_FULL) {
-		for (i = 0; i < PAGE_SIZE / BRW_MSIZE; i++) {
-			data = *(((__u64 *)addr) + i);
+		for (i = 0; i < len; i += BRW_MSIZE) {
+			data = *(u64 *)(addr + i);
 			if (data != magic)
 				goto bad_data;
 		}
-
 		return 0;
 	}
 
@@ -226,8 +235,12 @@
 	struct page *pg;
 
 	for (i = 0; i < bk->bk_niov; i++) {
+		int off, len;
+
 		pg = bk->bk_iovs[i].bv_page;
-		brw_fill_page(pg, pattern, magic);
+		off = bk->bk_iovs[i].bv_offset;
+		len = bk->bk_iovs[i].bv_len;
+		brw_fill_page(pg, off, len, pattern, magic);
 	}
 }
 
@@ -238,8 +251,12 @@
 	struct page *pg;
 
 	for (i = 0; i < bk->bk_niov; i++) {
+		int off, len;
+
 		pg = bk->bk_iovs[i].bv_page;
-		if (brw_check_page(pg, pattern, magic)) {
+		off = bk->bk_iovs[i].bv_offset;
+		len = bk->bk_iovs[i].bv_len;
+		if (brw_check_page(pg, off, len, pattern, magic)) {
 			CERROR("Bulk page %p (%d/%d) is corrupted!\n",
 			       pg, i, bk->bk_niov);
 			return 1;
@@ -276,6 +293,7 @@
 		len = npg * PAGE_SIZE;
 	} else {
 		struct test_bulk_req_v1 *breq = &tsi->tsi_u.bulk_v1;
+		int off;
 
 		/*
 		 * I should never get this step if it's unknown feature
@@ -286,7 +304,8 @@
 		opc = breq->blk_opc;
 		flags = breq->blk_flags;
 		len = breq->blk_len;
-		npg = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
+		off = breq->blk_offset;
+		npg = (off + len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	}
 
 	rc = sfw_create_test_rpc(tsu, dest, sn->sn_features, npg, len, &rpc);
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 55afb53..8a3a2da 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -789,14 +789,15 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 }
 
 static int
-lstcon_bulkrpc_v1_prep(lst_test_bulk_param_t *param, struct srpc_test_reqst *req)
+lstcon_bulkrpc_v1_prep(lst_test_bulk_param_t *param, bool is_client,
+		       struct srpc_test_reqst *req)
 {
 	struct test_bulk_req_v1 *brq = &req->tsr_u.bulk_v1;
 
 	brq->blk_opc = param->blk_opc;
 	brq->blk_flags = param->blk_flags;
 	brq->blk_len = param->blk_size;
-	brq->blk_offset	= 0; /* reserved */
+	brq->blk_offset	= is_client ? param->blk_cli_off : param->blk_srv_off;
 
 	return 0;
 }
@@ -897,7 +898,8 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 						    &test->tes_param[0], trq);
 		} else {
 			rc = lstcon_bulkrpc_v1_prep((lst_test_bulk_param_t *)
-						    &test->tes_param[0], trq);
+						    &test->tes_param[0],
+						    trq->tsr_is_client, trq);
 		}
 
 		break;
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index abbd628..2774327 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -1101,7 +1101,7 @@
 	LASSERT(!rpc->srpc_bulk);
 	LASSERT(npages > 0 && npages <= LNET_MAX_IOV);
 
-	rpc->srpc_bulk = srpc_alloc_bulk(cpt, npages, len, sink);
+	rpc->srpc_bulk = srpc_alloc_bulk(cpt, 0, npages, len, sink);
 	if (!rpc->srpc_bulk)
 		return -ENOMEM;
 
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index f5619d8..0498c56 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -84,14 +84,13 @@ void srpc_set_counters(const srpc_counters_t *cnt)
 }
 
 static int
-srpc_add_bulk_page(struct srpc_bulk *bk, struct page *pg, int i, int nob)
+srpc_add_bulk_page(struct srpc_bulk *bk, struct page *pg, int i, int off,
+		   int nob)
 {
-	nob = min_t(int, nob, PAGE_SIZE);
+	LASSERT(off < PAGE_SIZE);
+	LASSERT(nob > 0 && nob <= PAGE_SIZE);
 
-	LASSERT(nob > 0);
-	LASSERT(i >= 0 && i < bk->bk_niov);
-
-	bk->bk_iovs[i].bv_offset = 0;
+	bk->bk_iovs[i].bv_offset = off;
 	bk->bk_iovs[i].bv_page = pg;
 	bk->bk_iovs[i].bv_len = nob;
 	return nob;
@@ -117,7 +116,8 @@ void srpc_set_counters(const srpc_counters_t *cnt)
 }
 
 struct srpc_bulk *
-srpc_alloc_bulk(int cpt, unsigned bulk_npg, unsigned bulk_len, int sink)
+srpc_alloc_bulk(int cpt, unsigned int bulk_off, unsigned int bulk_npg,
+		unsigned int bulk_len, int sink)
 {
 	struct srpc_bulk *bk;
 	int i;
@@ -148,8 +148,11 @@ struct srpc_bulk *
 			return NULL;
 		}
 
-		nob = srpc_add_bulk_page(bk, pg, i, bulk_len);
+		nob = min_t(unsigned int, bulk_off + bulk_len, PAGE_SIZE) -
+		      bulk_off;
+		srpc_add_bulk_page(bk, pg, i, bulk_off, nob);
 		bulk_len -= nob;
+		bulk_off = 0;
 	}
 
 	return bk;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index 4ab2ee2..8a0c18e 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -175,7 +175,7 @@ struct test_bulk_req_v1 {
 	__u16		   blk_opc;	   /* bulk operation code */
 	__u16		   blk_flags;	   /* data check flags */
 	__u32		   blk_len;	   /* data length */
-	__u32		   blk_offset;	   /* reserved: offset */
+	__u32		   blk_offset;	   /* offset */
 } WIRE_ATTR;
 
 struct test_ping_req {
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index d033ac0..877bb36 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -434,8 +434,9 @@ struct srpc_client_rpc *
 void srpc_post_rpc(struct srpc_client_rpc *rpc);
 void srpc_abort_rpc(struct srpc_client_rpc *rpc, int why);
 void srpc_free_bulk(struct srpc_bulk *bk);
-struct srpc_bulk *srpc_alloc_bulk(int cpt, unsigned bulk_npg,
-				  unsigned bulk_len, int sink);
+struct srpc_bulk *srpc_alloc_bulk(int cpt, unsigned int off,
+				  unsigned int bulk_npg, unsigned int bulk_len,
+				  int sink);
 int srpc_send_rpc(struct swi_workitem *wi);
 int srpc_send_reply(struct srpc_server_rpc *rpc);
 int srpc_add_service(struct srpc_service *sv);
-- 
1.7.1
