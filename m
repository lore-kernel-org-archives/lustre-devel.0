From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:53 -0500
Subject: [lustre-devel] [PATCH 365/622] lustre: ptlrpc: Add more flags to
 DEBUG_REQ_FLAGS macro
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-366-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vitaly Fertman <c17818@cray.com>

Add rq_no_reply flag to the DEBUG_REQ_FLAGS macro for debug purposes
Also, add another debug message to check_write_rcs

WC-bug-id: https://jira.whamcloud.com/browse/LU-12333
Lustre-commit: 3e43d06810e6 ("LU-12333 ptlrpc: Add more flags to DEBUG_REQ_FLAGS macro")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Reviewed-on: https://review.whamcloud.com/35090
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h | 4 ++--
 fs/lustre/osc/osc_request.c    | 5 ++++-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 383d59e..7ed2d99 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1066,7 +1066,7 @@ static inline void lustre_set_rep_swabbed(struct ptlrpc_request *req,
 	FLAG(req->rq_err, "E"),	FLAG(req->rq_net_err, "e"),		      \
 	FLAG(req->rq_timedout, "X") /* eXpired */, FLAG(req->rq_resend, "S"), \
 	FLAG(req->rq_restart, "T"), FLAG(req->rq_replay, "P"),		      \
-	FLAG(req->rq_no_resend, "N"),					      \
+	FLAG(req->rq_no_resend, "N"), FLAG(req->rq_no_reply, "n"),	      \
 	FLAG(req->rq_waiting, "W"),					      \
 	FLAG(req->rq_wait_ctx, "C"), FLAG(req->rq_hp, "H"),		      \
 	FLAG(req->rq_committed, "M"),                                          \
@@ -1074,7 +1074,7 @@ static inline void lustre_set_rep_swabbed(struct ptlrpc_request *req,
 	FLAG(req->rq_reply_unlinked, "U"),                                     \
 	FLAG(req->rq_receiving_reply, "r")
 
-#define REQ_FLAGS_FMT "%s:%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s"
+#define REQ_FLAGS_FMT "%s:%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s"
 
 void _debug_req(struct ptlrpc_request *req,
 		struct libcfs_debug_msg_data *data, const char *fmt, ...)
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index f929908..6b066e5 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1064,8 +1064,11 @@ static int check_write_rcs(struct ptlrpc_request *req,
 
 	/* return error if any niobuf was in error */
 	for (i = 0; i < niocount; i++) {
-		if ((int)remote_rcs[i] < 0)
+		if ((int)remote_rcs[i] < 0) {
+			CDEBUG(D_INFO, "rc[%d]: %d req %p\n",
+			       i, remote_rcs[i], req);
 			return remote_rcs[i];
+		}
 
 		if (remote_rcs[i] != 0) {
 			CDEBUG(D_INFO, "rc[%d] invalid (%d) req %p\n",
-- 
1.8.3.1
