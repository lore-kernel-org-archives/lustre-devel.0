From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:50 -0500
Subject: [lustre-devel] [PATCH 302/622] lustre: ptlrpc: Add more flags to
 DEBUG_REQ_FLAGS macro
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-303-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

The rq_req_unlinked, rq_reply_unlinked and rq_receiving_reply flags
determine whether a PtlRPC request can transition out of
RQ_PHASE_UNREG_RPC. Add these flags to the DEBUG_REQ_FLAGS macro to
aid in debugging issues where requests are stuck in this unregistering
state.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12333
Lustre-commit: 5bcc3a330e21 ("LU-12333 ptlrpc: Add more flags to DEBUG_REQ_FLAGS macro")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/34949
Reviewed-by: Ann Koehler <amk@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index f96265b..383d59e 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1069,9 +1069,12 @@ static inline void lustre_set_rep_swabbed(struct ptlrpc_request *req,
 	FLAG(req->rq_no_resend, "N"),					      \
 	FLAG(req->rq_waiting, "W"),					      \
 	FLAG(req->rq_wait_ctx, "C"), FLAG(req->rq_hp, "H"),		      \
-	FLAG(req->rq_committed, "M")
+	FLAG(req->rq_committed, "M"),                                          \
+	FLAG(req->rq_req_unlinked, "Q"),                                       \
+	FLAG(req->rq_reply_unlinked, "U"),                                     \
+	FLAG(req->rq_receiving_reply, "r")
 
-#define REQ_FLAGS_FMT "%s:%s%s%s%s%s%s%s%s%s%s%s%s%s"
+#define REQ_FLAGS_FMT "%s:%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s"
 
 void _debug_req(struct ptlrpc_request *req,
 		struct libcfs_debug_msg_data *data, const char *fmt, ...)
-- 
1.8.3.1
