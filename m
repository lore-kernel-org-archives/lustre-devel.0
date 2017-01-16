From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:34 -0500
Subject: [lustre-devel] [PATCH 31/34] staging: lustre: lnet: change
	lst_test_bulk_param_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lst_test_bulk_param_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 4 ++--
 drivers/staging/lustre/lnet/selftest/conrpc.c      | 8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index 0279e09..d59d7ba 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -485,14 +485,14 @@ enum lst_brw_flags {
 	LST_BRW_CHECK_FULL	= 3
 };
 
-typedef struct {
+struct lst_test_bulk_param {
 	int	blk_opc;	/* bulk operation code */
 	int	blk_size;       /* size (bytes) */
 	int	blk_time;       /* time of running the test*/
 	int	blk_flags;      /* reserved flags */
 	int	blk_cli_off;	/* bulk offset on client */
 	int	blk_srv_off;	/* reserved: bulk offset on server */
-} lst_test_bulk_param_t;
+};
 
 typedef struct {
 	int	png_size;	/* size of ping message */
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 3b97915..bcbe84e 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -779,7 +779,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 }
 
 static int
-lstcon_bulkrpc_v0_prep(lst_test_bulk_param_t *param,
+lstcon_bulkrpc_v0_prep(struct lst_test_bulk_param *param,
 		       struct srpc_test_reqst *req)
 {
 	struct test_bulk_req *brq = &req->tsr_u.bulk_v0;
@@ -793,7 +793,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 }
 
 static int
-lstcon_bulkrpc_v1_prep(lst_test_bulk_param_t *param, bool is_client,
+lstcon_bulkrpc_v1_prep(struct lst_test_bulk_param *param, bool is_client,
 		       struct srpc_test_reqst *req)
 {
 	struct test_bulk_req_v1 *brq = &req->tsr_u.bulk_v1;
@@ -898,10 +898,10 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 	case LST_TEST_BULK:
 		trq->tsr_service = SRPC_SERVICE_BRW;
 		if (!(feats & LST_FEAT_BULK_LEN)) {
-			rc = lstcon_bulkrpc_v0_prep((lst_test_bulk_param_t *)
+			rc = lstcon_bulkrpc_v0_prep((struct lst_test_bulk_param *)
 						    &test->tes_param[0], trq);
 		} else {
-			rc = lstcon_bulkrpc_v1_prep((lst_test_bulk_param_t *)
+			rc = lstcon_bulkrpc_v1_prep((struct lst_test_bulk_param *)
 						    &test->tes_param[0],
 						    trq->tsr_is_client, trq);
 		}
-- 
1.8.3.1
