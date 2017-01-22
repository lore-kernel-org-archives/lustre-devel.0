From: James Simmons <jsimmons@infradead.org>
Date: Sat, 21 Jan 2017 19:40:28 -0500
Subject: [lustre-devel] [PATCH 4/8] staging: lustre: lnet: change
	lnet_process_id_packed_t to proper structure
In-Reply-To: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
References: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485045632-5886-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_process_id_packed_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24566
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/types.h |  4 ++--
 drivers/staging/lustre/lnet/selftest/conrpc.c     | 10 +++++-----
 drivers/staging/lustre/lnet/selftest/framework.c  |  8 ++++----
 drivers/staging/lustre/lnet/selftest/selftest.h   |  2 +-
 4 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 405bbc6..3c3b6676 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -115,11 +115,11 @@ static inline __u32 LNET_MKNET(__u32 type, __u32 num)
 #define WIRE_ATTR	__packed
 
 /* Packed version of lnet_process_id_t to transfer via network */
-typedef struct {
+struct lnet_process_id_packed {
 	/* node id / process id */
 	lnet_nid_t	nid;
 	lnet_pid_t	pid;
-} WIRE_ATTR lnet_process_id_packed_t;
+} WIRE_ATTR;
 
 /*
  * The wire handle's interface cookie only matches one network interface in
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 3d325ea..c6a683b 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -698,17 +698,17 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 	return 0;
 }
 
-static lnet_process_id_packed_t *
+static struct lnet_process_id_packed *
 lstcon_next_id(int idx, int nkiov, lnet_kiov_t *kiov)
 {
-	lnet_process_id_packed_t *pid;
+	struct lnet_process_id_packed *pid;
 	int i;
 
 	i = idx / SFW_ID_PER_PAGE;
 
 	LASSERT(i < nkiov);
 
-	pid = (lnet_process_id_packed_t *)page_address(kiov[i].bv_page);
+	pid = (struct lnet_process_id_packed *)page_address(kiov[i].bv_page);
 
 	return &pid[idx % SFW_ID_PER_PAGE];
 }
@@ -717,7 +717,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 lstcon_dstnodes_prep(struct lstcon_group *grp, int idx,
 		     int dist, int span, int nkiov, lnet_kiov_t *kiov)
 {
-	lnet_process_id_packed_t *pid;
+	struct lnet_process_id_packed *pid;
 	struct lstcon_ndlink *ndl;
 	struct lstcon_node *nd;
 	int start;
@@ -823,7 +823,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 		npg = sfw_id_pages(test->tes_span);
 		nob = !(feats & LST_FEAT_BULK_LEN) ?
 		      npg * PAGE_SIZE :
-		      sizeof(lnet_process_id_packed_t) * test->tes_span;
+		      sizeof(struct lnet_process_id_packed) * test->tes_span;
 	}
 
 	rc = lstcon_rpc_prep(nd, SRPC_SERVICE_TEST, feats, npg, nob, crpc);
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 436aef3..9dd4e1a 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -777,14 +777,14 @@
 	LASSERT(bk);
 	LASSERT(bk->bk_niov * SFW_ID_PER_PAGE >= (unsigned int)ndest);
 	LASSERT((unsigned int)bk->bk_len >=
-		sizeof(lnet_process_id_packed_t) * ndest);
+		sizeof(struct lnet_process_id_packed) * ndest);
 
 	sfw_unpack_addtest_req(msg);
 	memcpy(&tsi->tsi_u, &req->tsr_u, sizeof(tsi->tsi_u));
 
 	for (i = 0; i < ndest; i++) {
-		lnet_process_id_packed_t *dests;
-		lnet_process_id_packed_t id;
+		struct lnet_process_id_packed *dests;
+		struct lnet_process_id_packed id;
 		int j;
 
 		dests = page_address(bk->bk_iovs[i / SFW_ID_PER_PAGE].bv_page);
@@ -1164,7 +1164,7 @@
 			len = npg * PAGE_SIZE;
 
 		} else {
-			len = sizeof(lnet_process_id_packed_t) *
+			len = sizeof(struct lnet_process_id_packed) *
 			      request->tsr_ndest;
 		}
 
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 1e5526c..f259480 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -396,7 +396,7 @@ struct sfw_test_instance {
  * pages are not used
  */
 #define SFW_MAX_CONCUR	   LST_MAX_CONCUR
-#define SFW_ID_PER_PAGE    (PAGE_SIZE / sizeof(lnet_process_id_packed_t))
+#define SFW_ID_PER_PAGE    (PAGE_SIZE / sizeof(struct lnet_process_id_packed))
 #define SFW_MAX_NDESTS	   (LNET_MAX_IOV * SFW_ID_PER_PAGE)
 #define sfw_id_pages(n)    (((n) + SFW_ID_PER_PAGE - 1) / SFW_ID_PER_PAGE)
 
-- 
1.8.3.1
