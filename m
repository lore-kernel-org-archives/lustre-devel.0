From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:57 -0400
Subject: [lustre-devel] [PATCH 23/29] staging: lustre: ptlrpc: do not sleep
	if encpool reached max capacity
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sebastien.buisson@bull.net>, James Simmons <jsimmons@infradead.org>

From: Sebastien Buisson <sebastien.buisson@bull.net>

When encryption is enabled RPCs are encrypted just before being
sent. The encryption requires allocating memory in the encoding pool.
The current implementation in sptlrpc_enc_pool_get_pages() is
deadlock-prone. Indeed, if there is no more free pages in the pool,
all ptlrpcd threads can end up waiting in a queue, so there is no
thread available to process other requests. It means client is not
able to process replies from servers that yet contain last committed
transno useful to release memory allocated by previous requests,
including enc_pool pages.

To fix this, in sptlrpc_enc_pool_get_pages(), do not make ptlrpcd
threads wait in queue if encoding pool has already reached its maximum
capacity. Instead, return -ENOMEM. If functions calling ptl_send_rpc()
get -ENOMEM, then put back request in queue by moving it back to
RQ_PHASE_NEW phase.

As an optimization, do not call ptl_send_rpc() again for requests that
already failed to allocate in the enc_pool, as long as there is not
enough memory in the enc_pool to satisfy theirs needs.

In /sys/fs/lustre/sptlrpc/encrypt_page_pools, add a new 'out of mem'
stat to track how many requests fail to allocate memory in the
enc_pool.

Signed-off-by: Sebastien Buisson <sebastien.buisson@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6356
Reviewed-on: http://review.whamcloud.com/15070
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_sec.h |    2 +
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   25 +++++++++++++++++
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |    9 +++++-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |   29 +++++++++++++++++---
 4 files changed, 60 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
index 90c1834..89658e0 100644
--- a/drivers/staging/lustre/lustre/include/lustre_sec.h
+++ b/drivers/staging/lustre/lustre/include/lustre_sec.h
@@ -1029,6 +1029,8 @@ int  sptlrpc_target_export_check(struct obd_export *exp,
 
 /* bulk security api */
 void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc);
+int get_free_pages_in_pool(void);
+int pool_is_at_full_capacity(void);
 
 int sptlrpc_cli_wrap_bulk(struct ptlrpc_request *req,
 			  struct ptlrpc_bulk_desc *desc);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index bda925e..cc4b129 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1440,6 +1440,13 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 	int rc;
 
 	LASSERT(req->rq_phase == RQ_PHASE_NEW);
+
+	/* do not try to go further if there is not enough memory in enc_pool */
+	if (req->rq_sent && req->rq_bulk)
+		if (req->rq_bulk->bd_iov_count > get_free_pages_in_pool() &&
+		    pool_is_at_full_capacity())
+			return -ENOMEM;
+
 	if (req->rq_sent && (req->rq_sent > ktime_get_real_seconds()) &&
 	    (!req->rq_generation_set ||
 	     req->rq_import_generation == imp->imp_generation))
@@ -1533,6 +1540,16 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 	       lustre_msg_get_opc(req->rq_reqmsg));
 
 	rc = ptl_send_rpc(req, 0);
+	if (rc == -ENOMEM) {
+		spin_lock(&imp->imp_lock);
+		if (!list_empty(&req->rq_list)) {
+			list_del_init(&req->rq_list);
+			atomic_dec(&req->rq_import->imp_inflight);
+		}
+		spin_unlock(&imp->imp_lock);
+		ptlrpc_rqphase_move(req, RQ_PHASE_NEW);
+		return rc;
+	}
 	if (rc) {
 		DEBUG_REQ(D_HA, req, "send failed (%d); expect timeout", rc);
 		spin_lock(&req->rq_lock);
@@ -1822,6 +1839,14 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 				}
 
 				rc = ptl_send_rpc(req, 0);
+				if (rc == -ENOMEM) {
+					spin_lock(&imp->imp_lock);
+					if (!list_empty(&req->rq_list))
+						list_del_init(&req->rq_list);
+					spin_unlock(&imp->imp_lock);
+					ptlrpc_rqphase_move(req, RQ_PHASE_NEW);
+					continue;
+				}
 				if (rc) {
 					DEBUG_REQ(D_HA, req,
 						  "send failed: rc = %d", rc);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index c2dd948..4e80ba9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -536,8 +536,15 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 		mpflag = cfs_memory_pressure_get_and_set();
 
 	rc = sptlrpc_cli_wrap_request(request);
-	if (rc)
+	if (rc) {
+		/*
+		 * set rq_sent so that this request is treated
+		 * as a delayed send in the upper layers
+		 */
+		if (rc == -ENOMEM)
+			request->rq_sent = ktime_get_seconds();
 		goto out;
+	}
 
 	/* bulk register should be done after wrap_request() */
 	if (request->rq_bulk) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index ceb805d..2fe9085 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -108,6 +108,7 @@
 	unsigned long    epp_st_lowfree;	/* lowest free pages reached */
 	unsigned int     epp_st_max_wqlen;      /* highest waitqueue length */
 	unsigned long       epp_st_max_wait;       /* in jiffies */
+	unsigned long	 epp_st_outofmem;	/* # of out of mem requests */
 	/*
 	 * pointers to pools
 	 */
@@ -139,7 +140,8 @@ int sptlrpc_proc_enc_pool_seq_show(struct seq_file *m, void *v)
 		   "cache missing:	   %lu\n"
 		   "low free mark:	   %lu\n"
 		   "max waitqueue depth:     %u\n"
-		   "max wait time:	   %ld/%lu\n",
+		   "max wait time:	   %ld/%lu\n"
+		   "out of mem:		 %lu\n",
 		   totalram_pages,
 		   PAGES_PER_POOL,
 		   page_pools.epp_max_pages,
@@ -158,7 +160,8 @@ int sptlrpc_proc_enc_pool_seq_show(struct seq_file *m, void *v)
 		   page_pools.epp_st_lowfree,
 		   page_pools.epp_st_max_wqlen,
 		   page_pools.epp_st_max_wait,
-		   msecs_to_jiffies(MSEC_PER_SEC));
+		   msecs_to_jiffies(MSEC_PER_SEC),
+		   page_pools.epp_st_outofmem);
 
 	spin_unlock(&page_pools.epp_lock);
 
@@ -306,6 +309,22 @@ static inline void enc_pools_wakeup(void)
 	}
 }
 
+/*
+ * Export the number of free pages in the pool
+ */
+int get_free_pages_in_pool(void)
+{
+	return page_pools.epp_free_pages;
+}
+
+/*
+ * Let outside world know if enc_pool full capacity is reached
+ */
+int pool_is_at_full_capacity(void)
+{
+	return (page_pools.epp_total_pages == page_pools.epp_max_pages);
+}
+
 void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc)
 {
 	int p_idx, g_idx;
@@ -406,6 +425,7 @@ int sptlrpc_enc_pool_init(void)
 	page_pools.epp_st_lowfree = 0;
 	page_pools.epp_st_max_wqlen = 0;
 	page_pools.epp_st_max_wait = 0;
+	page_pools.epp_st_outofmem = 0;
 
 	enc_pools_alloc();
 	if (!page_pools.epp_pools)
@@ -433,13 +453,14 @@ void sptlrpc_enc_pool_fini(void)
 
 	if (page_pools.epp_st_access > 0) {
 		CDEBUG(D_SEC,
-		       "max pages %lu, grows %u, grow fails %u, shrinks %u, access %lu, missing %lu, max qlen %u, max wait %ld/%ld\n",
+		       "max pages %lu, grows %u, grow fails %u, shrinks %u, access %lu, missing %lu, max qlen %u, max wait %ld/%ld, out of mem %lu\n",
 		       page_pools.epp_st_max_pages, page_pools.epp_st_grows,
 		       page_pools.epp_st_grow_fails,
 		       page_pools.epp_st_shrinks, page_pools.epp_st_access,
 		       page_pools.epp_st_missings, page_pools.epp_st_max_wqlen,
 		       page_pools.epp_st_max_wait,
-		       msecs_to_jiffies(MSEC_PER_SEC));
+		       msecs_to_jiffies(MSEC_PER_SEC),
+		       page_pools.epp_st_outofmem);
 	}
 }
 
-- 
1.7.1
