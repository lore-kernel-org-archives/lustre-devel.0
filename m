From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:44 -0500
Subject: [lustre-devel] [PATCH 596/622] lustre: ptlrpc: show target name in
 req_history
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-597-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Currently the req_history tracing shows the "self" NID as the second
field.  However, this is not very useful since there may be a number
of different targets on the same server, and since the logs are all
collected directly on the server we already know the local NID.

Instead of printing the "self" NID, store the target name as the
second field, if that is available, so that we can determine which
target the RPC was intended for.  This makes it easier to debug
problems with bad clients and isolate traffic for a specific target.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11644
Lustre-commit: 83b6c6608e94 ("LU-11644 ptlrpc: show target name in req_history")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/37193
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Nathaniel Clark <nclark@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/lproc_ptlrpc.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index d52a08a..f34aec3 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -956,7 +956,6 @@ static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 
 		req = srhi->srhi_req;
 
-		libcfs_nid2str_r(req->rq_self, nidstr, sizeof(nidstr));
 		arrival.tv_sec = req->rq_arrival_time.tv_sec;
 		arrival.tv_nsec = req->rq_arrival_time.tv_nsec;
 		sent.tv_sec = req->rq_sent;
@@ -970,8 +969,13 @@ static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 		 * parser. Currently I only print stuff here I know is OK
 		 * to look at coz it was set up in request_in_callback()!!!
 		 */
-		seq_printf(s, "%lld:%s:%s:x%llu:%d:%s:%lld.%06lld:%lld.%06llds(%+lld.0s) ",
-			   req->rq_history_seq, nidstr,
+		seq_printf(s,
+			   "%lld:%s:%s:x%llu:%d:%s:%lld.%06lld:%lld.%06llds(%+lld.0s) ",
+			   req->rq_history_seq,
+			   req->rq_export && req->rq_export->exp_obd ?
+				req->rq_export->exp_obd->obd_name :
+				libcfs_nid2str_r(req->rq_self, nidstr,
+						 sizeof(nidstr)),
 			   libcfs_id2str(req->rq_peer), req->rq_xid,
 			   req->rq_reqlen, ptlrpc_rqphase2str(req),
 			   (s64)req->rq_arrival_time.tv_sec,
-- 
1.8.3.1
