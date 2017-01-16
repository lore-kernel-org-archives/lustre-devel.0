From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:35 -0500
Subject: [lustre-devel] [PATCH 32/34] staging: lustre: lnet: change
	lst_test_ping_param_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-33-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lst_test_ping_param_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 4 ++--
 drivers/staging/lustre/lnet/selftest/conrpc.c      | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index d59d7ba..a9c5b6d 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -494,12 +494,12 @@ struct lst_test_bulk_param {
 	int	blk_srv_off;	/* reserved: bulk offset on server */
 };
 
-typedef struct {
+struct lst_test_ping_param {
 	int	png_size;	/* size of ping message */
 	int	png_time;	/* time */
 	int	png_loop;	/* loop */
 	int	png_flags;	/* reserved flags */
-} lst_test_ping_param_t;
+};
 
 typedef struct {
 	__u32 errors;
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index bcbe84e..3d325ea 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -768,7 +768,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 }
 
 static int
-lstcon_pingrpc_prep(lst_test_ping_param_t *param, struct srpc_test_reqst *req)
+lstcon_pingrpc_prep(struct lst_test_ping_param *param, struct srpc_test_reqst *req)
 {
 	struct test_ping_req *prq = &req->tsr_u.ping;
 
@@ -891,7 +891,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 	switch (test->tes_type) {
 	case LST_TEST_PING:
 		trq->tsr_service = SRPC_SERVICE_PING;
-		rc = lstcon_pingrpc_prep((lst_test_ping_param_t *)
+		rc = lstcon_pingrpc_prep((struct lst_test_ping_param *)
 					 &test->tes_param[0], trq);
 		break;
 
-- 
1.8.3.1
