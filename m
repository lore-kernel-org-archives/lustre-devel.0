From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:23 -0500
Subject: [lustre-devel] [PATCH 395/622] lustre: ptlrpc: Add jobid to
 rpctrace debug messages
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-396-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Ann Koehler <amk@cray.com>

This mod adds the jobid string found in the ptlrpc_body of an rpc
to the output of rpctrace messages. If jobids are not in use the
string will be empty. If jobids are in use, the string can be
useful in analyzing Lustre activity.

Cray-bug-id: LUS-7557
WC-bug-id: https://jira.whamcloud.com/browse/LU-12523
Lustre-commit: 9ae40e4c5ecb ("LU-12523 ptlrpc: Add jobid to rpctrace debug messages")
Signed-off-by: Ann Koehler <amk@cray.com>
Reviewed-on: https://review.whamcloud.com/35445
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h  |  1 +
 fs/lustre/ptlrpc/client.c       | 15 +++++++++------
 fs/lustre/ptlrpc/pack_generic.c | 30 ++++++++++++++++++++++++++++--
 fs/lustre/ptlrpc/service.c      | 12 +++++++-----
 4 files changed, 45 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 7ed2d99..d03e8c6 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -2074,6 +2074,7 @@ int lustre_shrink_msg(struct lustre_msg *msg, int segment,
 u32 lustre_msg_get_magic(struct lustre_msg *msg);
 u32 lustre_msg_get_timeout(struct lustre_msg *msg);
 u32 lustre_msg_get_service_time(struct lustre_msg *msg);
+char *lustre_msg_get_jobid(struct lustre_msg *msg);
 u32 lustre_msg_get_cksum(struct lustre_msg *msg);
 u32 lustre_msg_calc_cksum(struct lustre_msg *msg);
 void lustre_msg_set_handle(struct lustre_msg *msg,
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index ac16878..bd641cc 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1639,11 +1639,12 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 	}
 
 	CDEBUG(D_RPCTRACE,
-	       "Sending RPC pname:cluuid:pid:xid:nid:opc %s:%s:%d:%llu:%s:%d\n",
-	       current->comm,
+	       "Sending RPC req@%p pname:cluuid:pid:xid:nid:opc:job %s:%s:%d:%llu:%s:%d:%s\n",
+	       req, current->comm,
 	       imp->imp_obd->obd_uuid.uuid,
 	       lustre_msg_get_status(req->rq_reqmsg), req->rq_xid,
-	       obd_import_nid2str(imp), lustre_msg_get_opc(req->rq_reqmsg));
+	       obd_import_nid2str(imp), lustre_msg_get_opc(req->rq_reqmsg),
+	       lustre_msg_get_jobid(req->rq_reqmsg));
 
 	rc = ptl_send_rpc(req, 0);
 	if (rc == -ENOMEM) {
@@ -2057,12 +2058,14 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 
 		if (req->rq_reqmsg)
 			CDEBUG(D_RPCTRACE,
-			       "Completed RPC pname:cluuid:pid:xid:nid:opc %s:%s:%d:%llu:%s:%d\n",
-			       current->comm, imp->imp_obd->obd_uuid.uuid,
+			       "Completed RPC req@%p pname:cluuid:pid:xid:nid:opc:job %s:%s:%d:%llu:%s:%d:%s\n",
+			       req, current->comm,
+			       imp->imp_obd->obd_uuid.uuid,
 			       lustre_msg_get_status(req->rq_reqmsg),
 			       req->rq_xid,
 			       obd_import_nid2str(imp),
-			       lustre_msg_get_opc(req->rq_reqmsg));
+			       lustre_msg_get_opc(req->rq_reqmsg),
+			       lustre_msg_get_jobid(req->rq_reqmsg));
 
 		spin_lock(&imp->imp_lock);
 		/*
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index a4f28f3..f687ecc 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1183,6 +1183,31 @@ u32 lustre_msg_get_service_time(struct lustre_msg *msg)
 	}
 }
 
+char *lustre_msg_get_jobid(struct lustre_msg *msg)
+{
+	switch (msg->lm_magic) {
+	case LUSTRE_MSG_MAGIC_V2: {
+		struct ptlrpc_body *pb;
+
+		/* the old pltrpc_body_v2 is smaller; doesn't include jobid */
+		if (msg->lm_buflens[MSG_PTLRPC_BODY_OFF] <
+		    sizeof(struct ptlrpc_body))
+			return NULL;
+
+		pb = lustre_msg_buf_v2(msg, MSG_PTLRPC_BODY_OFF,
+					  sizeof(struct ptlrpc_body));
+		if (!pb)
+			return NULL;
+
+		return pb->pb_jobid;
+	}
+	default:
+		CERROR("incorrect message magic: %08x\n", msg->lm_magic);
+		return NULL;
+	}
+}
+EXPORT_SYMBOL(lustre_msg_get_jobid);
+
 u32 lustre_msg_get_cksum(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
@@ -2337,7 +2362,7 @@ void _debug_req(struct ptlrpc_request *req,
 	vaf.fmt = fmt;
 	vaf.va = &args;
 	libcfs_debug_msg(msgdata,
-			 "%pV req@%p x%llu/t%lld(%lld) o%d->%s@%s:%d/%d lens %d/%d e %d to %lld dl %lld ref %d fl " REQ_FLAGS_FMT "/%x/%x rc %d/%d\n",
+			 "%pV req@%p x%llu/t%lld(%lld) o%d->%s@%s:%d/%d lens %d/%d e %d to %lld dl %lld ref %d fl " REQ_FLAGS_FMT "/%x/%x rc %d/%d job:'%s'\n",
 			 &vaf,
 			 req, req->rq_xid, req->rq_transno,
 			 req_ok ? lustre_msg_get_transno(req->rq_reqmsg) : 0,
@@ -2355,7 +2380,8 @@ void _debug_req(struct ptlrpc_request *req,
 			 atomic_read(&req->rq_refcount),
 			 DEBUG_REQ_FLAGS(req),
 			 req_ok ? lustre_msg_get_flags(req->rq_reqmsg) : -1,
-			 rep_flags, req->rq_status, rep_status);
+			 rep_flags, req->rq_status, rep_status,
+			 req_ok ? lustre_msg_get_jobid(req->rq_reqmsg) : "");
 	va_end(args);
 }
 EXPORT_SYMBOL(_debug_req);
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 8e6013a..3132a1e 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1756,15 +1756,16 @@ static int ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	}
 
 	CDEBUG(D_RPCTRACE,
-	       "Handling RPC pname:cluuid+ref:pid:xid:nid:opc %s:%s+%d:%d:x%llu:%s:%d\n",
-	       current->comm,
+	       "Handling RPC req@%p pname:cluuid+ref:pid:xid:nid:opc:job %s:%s+%d:%d:x%llu:%s:%d:%s\n",
+	       request, current->comm,
 	       (request->rq_export ?
 		(char *)request->rq_export->exp_client_uuid.uuid : "0"),
 	       (request->rq_export ?
 		refcount_read(&request->rq_export->exp_refcount) : -99),
 	       lustre_msg_get_status(request->rq_reqmsg), request->rq_xid,
 	       libcfs_id2str(request->rq_peer),
-	       lustre_msg_get_opc(request->rq_reqmsg));
+	       lustre_msg_get_opc(request->rq_reqmsg),
+	       lustre_msg_get_jobid(request->rq_reqmsg));
 
 	if (lustre_msg_get_opc(request->rq_reqmsg) != OBD_PING)
 		CFS_FAIL_TIMEOUT_MS(OBD_FAIL_PTLRPC_PAUSE_REQ, cfs_fail_val);
@@ -1796,8 +1797,8 @@ static int ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	timediff_usecs = ktime_us_delta(work_end, work_start);
 	arrived_usecs = ktime_us_delta(work_end, arrived);
 	CDEBUG(D_RPCTRACE,
-	       "Handled RPC pname:cluuid+ref:pid:xid:nid:opc %s:%s+%d:%d:x%llu:%s:%d Request processed in %lldus (%lldus total) trans %llu rc %d/%d\n",
-	       current->comm,
+	       "Handled RPC req@%p pname:cluuid+ref:pid:xid:nid:opc:job %s:%s+%d:%d:x%llu:%s:%d:%s Request processed in %lldus (%lldus total) trans %llu rc %d/%d\n",
+	       request, current->comm,
 	       (request->rq_export ?
 		(char *)request->rq_export->exp_client_uuid.uuid : "0"),
 	       (request->rq_export ?
@@ -1806,6 +1807,7 @@ static int ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	       request->rq_xid,
 	       libcfs_id2str(request->rq_peer),
 	       lustre_msg_get_opc(request->rq_reqmsg),
+	       lustre_msg_get_jobid(request->rq_reqmsg),
 	       timediff_usecs,
 	       arrived_usecs,
 	       (request->rq_repmsg ?
-- 
1.8.3.1
