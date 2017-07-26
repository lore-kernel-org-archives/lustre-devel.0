From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:29 -0400
Subject: [lustre-devel] [PATCH 13/20] staging: lustre: ptlrpc: restore
	64-bit time for struct ptlrpc_cli_req
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>, Liang Zhen <liang.zhen@intel.com>

During the reorganization of ptlrpc_request some of the
time64_t fields were incorrectly turned into time_t.
Restore those fields back to time_64_t.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/24977
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4423
Fixes: 32c8728d87dc ("staging/lustre/ptlrpc: reorganize ptlrpc_request")
CC: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_net.h | 10 +++++-----
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index d61b000..05f02b1 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -558,13 +558,13 @@ struct ptlrpc_cli_req {
 	/** request sent timeval */
 	struct timespec64		 cr_sent_tv;
 	/** time for request really sent out */
-	time_t				 cr_sent_out;
+	time64_t			 cr_sent_out;
 	/** when req reply unlink must finish. */
-	time_t				 cr_reply_deadline;
+	time64_t			 cr_reply_deadline;
 	/** when req bulk unlink must finish. */
-	time_t				 cr_bulk_deadline;
+	time64_t			 cr_bulk_deadline;
 	/** when req unlink must finish. */
-	time_t				 cr_req_deadline;
+	time64_t			 cr_req_deadline;
 	/** Portal to which this request would be sent */
 	short				 cr_req_ptl;
 	/** Portal where to wait for reply and where reply would be sent */
@@ -663,7 +663,7 @@ struct ptlrpc_srv_req {
 	/** history sequence # */
 	__u64				sr_hist_seq;
 	/** the index of service's srv_at_array into which request is linked */
-	time_t				sr_at_index;
+	time64_t			sr_at_index;
 	/** authed uid */
 	uid_t				sr_auth_uid;
 	/** authed uid mapped to */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 1247686..9f4f17a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -742,7 +742,7 @@ int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 
 	/* Let's setup deadline for req/reply/bulk unlink for opcode. */
 	if (cfs_fail_val == opcode) {
-		time_t *fail_t = NULL, *fail2_t = NULL;
+		time64_t *fail_t = NULL, *fail2_t = NULL;
 
 		if (CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_BULK_UNLINK)) {
 			fail_t = &request->rq_bulk_deadline;
-- 
1.8.3.1
