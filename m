From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:38 -0400
Subject: [lustre-devel] [PATCH 28/30] lustre: ptlrpc: free reply buffer
 earlier for open RPC
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Fan Yong <fan.yong@intel.com>

It is unnecessary to keep the reply buffer for open RPC. Replay
related data has already been saved in the request buffer when
the RPC replied. If the open replay really happen, the replay
logic will alloc the reply buffer when needed.

On the other hand, the client always tries to alloc big enough
space to hold the open RPC reply since the client does not exactly
know how much data the server will reply to the client. So the reply
buffer may be quite larger than the real needed. Under such case,
keeping the large reply buffer for the open RPC will occupy a lot
of RAM as to OOM if the are too many open RPCs to be replayed.

This patch frees the reply buffer for the open RPC when only
the replay logic holds the last reference of the RPC.

Signed-off-by: Fan Yong <fan.yong@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9514
Reviewed-on: https://review.whamcloud.com/27208
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |  6 ++-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    | 20 ++++++++-
 drivers/staging/lustre/lustre/ptlrpc/client.c      | 49 +++++++++++++++++-----
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    | 26 ++++++++----
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |  1 +
 5 files changed, 80 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index cf630db..e755e99 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -738,7 +738,8 @@ struct ptlrpc_request {
 	/** Lock to protect request flags and some other important bits, like
 	 * rq_list
 	 */
-	spinlock_t rq_lock;
+	spinlock_t			 rq_lock;
+	spinlock_t			 rq_early_free_lock;
 	/** client-side flags are serialized by rq_lock @{ */
 	unsigned int rq_intr:1, rq_replied:1, rq_err:1,
 		rq_timedout:1, rq_resend:1, rq_restart:1,
@@ -770,7 +771,8 @@ struct ptlrpc_request {
 		 */
 		rq_allow_replay:1,
 		/* bulk request, sent to server, but uncommitted */
-		rq_unstable:1;
+		rq_unstable:1,
+		rq_early_free_repbuf:1; /* free reply buffer in advance */
 	/** @} */
 
 	/** server-side flags @{ */
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 37bf486..2108877 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -573,8 +573,15 @@ void mdc_replay_open(struct ptlrpc_request *req)
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 
+	spin_lock(&req->rq_lock);
 	och = mod->mod_och;
-	if (och) {
+	if (och && och->och_fh.cookie)
+		req->rq_early_free_repbuf = 1;
+	else
+		req->rq_early_free_repbuf = 0;
+	spin_unlock(&req->rq_lock);
+
+	if (req->rq_early_free_repbuf) {
 		struct lustre_handle *file_fh;
 
 		LASSERT(och->och_magic == OBD_CLIENT_HANDLE_MAGIC);
@@ -585,6 +592,7 @@ void mdc_replay_open(struct ptlrpc_request *req)
 		old = *file_fh;
 		*file_fh = body->mbo_handle;
 	}
+
 	close_req = mod->mod_close_req;
 	if (close_req) {
 		__u32 opc = lustre_msg_get_opc(close_req->rq_reqmsg);
@@ -595,8 +603,9 @@ void mdc_replay_open(struct ptlrpc_request *req)
 					       &RMF_MDT_EPOCH);
 		LASSERT(epoch);
 
-		if (och)
+		if (req->rq_early_free_repbuf)
 			LASSERT(!memcmp(&old, &epoch->mio_handle, sizeof(old)));
+
 		DEBUG_REQ(D_HA, close_req, "updating close body with new fh");
 		epoch->mio_handle = body->mbo_handle;
 	}
@@ -677,6 +686,7 @@ int mdc_set_open_replay_data(struct obd_export *exp,
 		mod->mod_open_req = open_req;
 		open_req->rq_cb_data = mod;
 		open_req->rq_commit_cb = mdc_commit_open;
+		open_req->rq_early_free_repbuf = 1;
 		spin_unlock(&open_req->rq_lock);
 	}
 
@@ -731,6 +741,12 @@ static int mdc_clear_open_replay_data(struct obd_export *exp,
 
 	LASSERT(mod != LP_POISON);
 	LASSERT(mod->mod_open_req);
+
+	spin_lock(&mod->mod_open_req->rq_lock);
+	if (mod->mod_och)
+		mod->mod_och->och_fh.cookie = 0;
+	mod->mod_open_req->rq_early_free_repbuf = 0;
+	spin_unlock(&mod->mod_open_req->rq_lock);
 	mdc_free_open(mod);
 
 	mod->mod_och = NULL;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 6d503d7..8fafc8d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -2413,28 +2413,54 @@ static void __ptlrpc_free_req(struct ptlrpc_request *request, int locked)
  * Drops one reference count for request \a request.
  * \a locked set indicates that caller holds import imp_lock.
  * Frees the request when reference count reaches zero.
+ *
+ * RETURN 1	the request is freed
+ * RETURN 0	some others still hold references on the request
  */
 static int __ptlrpc_req_finished(struct ptlrpc_request *request, int locked)
 {
+	int count;
+
 	if (!request)
 		return 1;
 
-	if (request == LP_POISON ||
-	    request->rq_reqmsg == LP_POISON) {
-		CERROR("dereferencing freed request (bug 575)\n");
-		LBUG();
-		return 1;
-	}
+	LASSERT(request != LP_POISON);
+	LASSERT(request->rq_reqmsg != LP_POISON);
 
 	DEBUG_REQ(D_INFO, request, "refcount now %u",
 		  atomic_read(&request->rq_refcount) - 1);
 
-	if (atomic_dec_and_test(&request->rq_refcount)) {
-		__ptlrpc_free_req(request, locked);
-		return 1;
+	spin_lock(&request->rq_lock);
+	count = atomic_dec_return(&request->rq_refcount);
+	LASSERTF(count >= 0, "Invalid ref count %d\n", count);
+
+	/* For open RPC, the client does not know the EA size (LOV, ACL, and
+	 * so on) before replied, then the client has to reserve very large
+	 * reply buffer. Such buffer will not be released until the RPC freed.
+	 * Since The open RPC is replayable, we need to keep it in the replay
+	 * list until close. If there are a lot of files opened concurrently,
+	 * then the client may be OOM.
+	 *
+	 * If fact, it is unnecessary to keep reply buffer for open replay,
+	 * related EAs have already been saved via mdc_save_lovea() before
+	 * coming here. So it is safe to free the reply buffer some earlier
+	 * before releasing the RPC to avoid client OOM. LU-9514
+	 */
+	if (count == 1 && request->rq_early_free_repbuf && request->rq_repbuf) {
+		spin_lock(&request->rq_early_free_lock);
+		sptlrpc_cli_free_repbuf(request);
+		request->rq_repbuf = NULL;
+		request->rq_repbuf_len = 0;
+		request->rq_repdata = NULL;
+		request->rq_reqdata_len = 0;
+		spin_unlock(&request->rq_early_free_lock);
 	}
+	spin_unlock(&request->rq_lock);
 
-	return 0;
+	if (!count)
+		__ptlrpc_free_req(request, locked);
+
+	return !count;
 }
 
 /**
@@ -2920,6 +2946,9 @@ int ptlrpc_replay_req(struct ptlrpc_request *req)
 	DEBUG_REQ(D_HA, req, "REPLAY");
 
 	atomic_inc(&req->rq_import->imp_replay_inflight);
+	spin_lock(&req->rq_lock);
+	req->rq_early_free_repbuf = 0;
+	spin_unlock(&req->rq_lock);
 	ptlrpc_request_addref(req); /* ptlrpcd needs a ref */
 
 	ptlrpcd_add_req(req);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 86a64a6..96d0377 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -2169,7 +2169,8 @@ static inline int req_ptlrpc_body_swabbed(struct ptlrpc_request *req)
 
 static inline int rep_ptlrpc_body_swabbed(struct ptlrpc_request *req)
 {
-	LASSERT(req->rq_repmsg);
+	if (unlikely(!req->rq_repmsg))
+		return 0;
 
 	switch (req->rq_repmsg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
@@ -2181,19 +2182,30 @@ static inline int rep_ptlrpc_body_swabbed(struct ptlrpc_request *req)
 }
 
 void _debug_req(struct ptlrpc_request *req,
-		struct libcfs_debug_msg_data *msgdata,
-		const char *fmt, ...)
+		struct libcfs_debug_msg_data *msgdata, const char *fmt, ...)
 {
-	int req_ok = req->rq_reqmsg != NULL;
-	int rep_ok = req->rq_repmsg != NULL;
+	bool req_ok = req->rq_reqmsg != NULL;
+	bool rep_ok = false;
 	lnet_nid_t nid = LNET_NID_ANY;
+	int rep_flags = -1;
+	int rep_status = -1;
 	va_list args;
 
+	spin_lock(&req->rq_early_free_lock);
+	if (req->rq_repmsg)
+		rep_ok = true;
+
 	if (ptlrpc_req_need_swab(req)) {
 		req_ok = req_ok && req_ptlrpc_body_swabbed(req);
 		rep_ok = rep_ok && rep_ptlrpc_body_swabbed(req);
 	}
 
+	if (rep_ok) {
+		rep_flags = lustre_msg_get_flags(req->rq_repmsg);
+		rep_status = lustre_msg_get_status(req->rq_repmsg);
+	}
+	spin_unlock(&req->rq_early_free_lock);
+
 	if (req->rq_import && req->rq_import->imp_connection)
 		nid = req->rq_import->imp_connection->c_peer.nid;
 	else if (req->rq_export && req->rq_export->exp_connection)
@@ -2218,9 +2230,7 @@ void _debug_req(struct ptlrpc_request *req,
 			   atomic_read(&req->rq_refcount),
 			   DEBUG_REQ_FLAGS(req),
 			   req_ok ? lustre_msg_get_flags(req->rq_reqmsg) : -1,
-			   rep_ok ? lustre_msg_get_flags(req->rq_repmsg) : -1,
-			   req->rq_status,
-			   rep_ok ? lustre_msg_get_status(req->rq_repmsg) : -1);
+			   rep_flags, req->rq_status, rep_status);
 	va_end(args);
 }
 EXPORT_SYMBOL(_debug_req);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index 134b742..0e4a215 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -309,6 +309,7 @@ static inline void ptlrpc_reqset_put(struct ptlrpc_request_set *set)
 static inline void ptlrpc_req_comm_init(struct ptlrpc_request *req)
 {
 	spin_lock_init(&req->rq_lock);
+	spin_lock_init(&req->rq_early_free_lock);
 	atomic_set(&req->rq_refcount, 1);
 	INIT_LIST_HEAD(&req->rq_list);
 	INIT_LIST_HEAD(&req->rq_replay_list);
-- 
1.8.3.1
