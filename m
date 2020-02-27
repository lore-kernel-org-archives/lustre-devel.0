From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:48 -0500
Subject: [lustre-devel] [PATCH 420/622] lustre: ptlrpc: Don't get jobid in
 body_v2
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-421-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

Some Lustre messages are still sent with ptlrpc_body_v2,
which does not have space for the jobid.

This results in errors like this when getting the jobid
from these messages, which we do now that the jobid is in
all RPC debug:
LustreError: 6817:0:(pack_generic.c:425:lustre_msg_buf_v2()) msg
000000005c83b7a2 buffer[0] size 152 too small (required 184, opc=-1)

While we should stop sending ptlrpc_body_v2 messages, we
we still have to support these messages from older servers.
So put a check in lustre_msg_get_jobid so it won't try to
get the jobid if it's the old, smaller RPC body.

Fixes: 9eabc4eaba47 ("lustre: ptlrpc: Add jobid to rpctrace debug messages")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12523
Lustre-commit: 544701a782fb ("LU-12523 ptlrpc: Don't get jobid in body_v2")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35584
Reviewed-by: Ann Koehler <amk@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c       | 4 ++--
 fs/lustre/ptlrpc/pack_generic.c | 3 ++-
 fs/lustre/ptlrpc/service.c      | 4 ++--
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index bd641cc..9920a95 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1644,7 +1644,7 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 	       imp->imp_obd->obd_uuid.uuid,
 	       lustre_msg_get_status(req->rq_reqmsg), req->rq_xid,
 	       obd_import_nid2str(imp), lustre_msg_get_opc(req->rq_reqmsg),
-	       lustre_msg_get_jobid(req->rq_reqmsg));
+	       lustre_msg_get_jobid(req->rq_reqmsg) ?: "");
 
 	rc = ptl_send_rpc(req, 0);
 	if (rc == -ENOMEM) {
@@ -2065,7 +2065,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 			       req->rq_xid,
 			       obd_import_nid2str(imp),
 			       lustre_msg_get_opc(req->rq_reqmsg),
-			       lustre_msg_get_jobid(req->rq_reqmsg));
+			       lustre_msg_get_jobid(req->rq_reqmsg) ?: "");
 
 		spin_lock(&imp->imp_lock);
 		/*
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 7acb4a8..b066113 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -2429,7 +2429,8 @@ void _debug_req(struct ptlrpc_request *req,
 			 DEBUG_REQ_FLAGS(req),
 			 req_ok ? lustre_msg_get_flags(req->rq_reqmsg) : -1,
 			 rep_flags, req->rq_status, rep_status,
-			 req_ok ? lustre_msg_get_jobid(req->rq_reqmsg) : "");
+			 req_ok ? lustre_msg_get_jobid(req->rq_reqmsg) ?: ""
+				: "");
 	va_end(args);
 }
 EXPORT_SYMBOL(_debug_req);
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 3132a1e..f40cb8d 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1765,7 +1765,7 @@ static int ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	       lustre_msg_get_status(request->rq_reqmsg), request->rq_xid,
 	       libcfs_id2str(request->rq_peer),
 	       lustre_msg_get_opc(request->rq_reqmsg),
-	       lustre_msg_get_jobid(request->rq_reqmsg));
+	       lustre_msg_get_jobid(request->rq_reqmsg) ?: "");
 
 	if (lustre_msg_get_opc(request->rq_reqmsg) != OBD_PING)
 		CFS_FAIL_TIMEOUT_MS(OBD_FAIL_PTLRPC_PAUSE_REQ, cfs_fail_val);
@@ -1807,7 +1807,7 @@ static int ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	       request->rq_xid,
 	       libcfs_id2str(request->rq_peer),
 	       lustre_msg_get_opc(request->rq_reqmsg),
-	       lustre_msg_get_jobid(request->rq_reqmsg),
+	       lustre_msg_get_jobid(request->rq_reqmsg) ?: "",
 	       timediff_usecs,
 	       arrived_usecs,
 	       (request->rq_repmsg ?
-- 
1.8.3.1
