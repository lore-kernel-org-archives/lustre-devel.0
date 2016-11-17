From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed, 16 Nov 2016 20:05:29 -0500
Subject: [lustre-devel] [PATCH 1/2] staging/lustre/ptlrpc: track unreplied
	requests
In-Reply-To: <1479344730-1131617-1-git-send-email-green@linuxhacker.ru>
References: <1479344730-1131617-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1479344730-1131617-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Niu Yawei <yawei.niu@intel.com>

The request xid was used to make sure the ost object timestamps
being updated by the out of order setattr/punch/write requests
properly. However, this mechanism is broken by the multiple rcvd
slot feature, where we deferred the xid assignment from request
packing to request sending.

This patch moved back the xid assignment to request packing, and
the manner of finding lowest unreplied xid is changed from scan
sending & delay list to scan a unreplied requests list.

This patch also skipped packing the known replied XID in connect
and disconnect request, so that we can make sure the known replied
XID is increased only on both server & client side.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-on: http://review.whamcloud.com/16759
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5951
Reviewed-by: Gregoire Pichon <gregoire.pichon@bull.net>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/lustre_import.h  |   5 +
 drivers/staging/lustre/lustre/include/lustre_net.h |   3 +
 drivers/staging/lustre/lustre/obdclass/genops.c    |   2 +
 drivers/staging/lustre/lustre/ptlrpc/client.c      | 112 +++++++++++++++------
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  34 +++++++
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  29 +++++-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |  24 +++++
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |  12 +++
 8 files changed, 185 insertions(+), 36 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index 5461ba3..4499c69 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -185,6 +185,11 @@ struct obd_import {
 	struct list_head	       *imp_replay_cursor;
 	/** @} */
 
+	/** List of not replied requests */
+	struct list_head	imp_unreplied_list;
+	/** Known maximal replied XID */
+	__u64			imp_known_replied_xid;
+
 	/** obd device for this import */
 	struct obd_device	*imp_obd;
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index d2cbec3..2be135d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -596,6 +596,8 @@ struct ptlrpc_cli_req {
 	union ptlrpc_async_args		 cr_async_args;
 	/** Opaq data for replay and commit callbacks. */
 	void				*cr_cb_data;
+	/** Link to the imp->imp_unreplied_list */
+	struct list_head		 cr_unreplied_list;
 	/**
 	 * Commit callback, called when request is committed and about to be
 	 * freed.
@@ -635,6 +637,7 @@ struct ptlrpc_cli_req {
 #define rq_interpret_reply	rq_cli.cr_reply_interp
 #define rq_async_args		rq_cli.cr_async_args
 #define rq_cb_data		rq_cli.cr_cb_data
+#define rq_unreplied_list	rq_cli.cr_unreplied_list
 #define rq_commit_cb		rq_cli.cr_commit_cb
 #define rq_replay_cb		rq_cli.cr_replay_cb
 
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 438d619..fa0d38d 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -907,6 +907,8 @@ struct obd_import *class_new_import(struct obd_device *obd)
 	INIT_LIST_HEAD(&imp->imp_sending_list);
 	INIT_LIST_HEAD(&imp->imp_delayed_list);
 	INIT_LIST_HEAD(&imp->imp_committed_list);
+	INIT_LIST_HEAD(&imp->imp_unreplied_list);
+	imp->imp_known_replied_xid = 0;
 	imp->imp_replay_cursor = &imp->imp_committed_list;
 	spin_lock_init(&imp->imp_lock);
 	imp->imp_last_success_conn = 0;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index d2f4cd5..ac959ef 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -652,6 +652,42 @@ static void __ptlrpc_free_req_to_pool(struct ptlrpc_request *request)
 	spin_unlock(&pool->prp_lock);
 }
 
+void ptlrpc_add_unreplied(struct ptlrpc_request *req)
+{
+	struct obd_import	*imp = req->rq_import;
+	struct list_head	*tmp;
+	struct ptlrpc_request	*iter;
+
+	assert_spin_locked(&imp->imp_lock);
+	LASSERT(list_empty(&req->rq_unreplied_list));
+
+	/* unreplied list is sorted by xid in ascending order */
+	list_for_each_prev(tmp, &imp->imp_unreplied_list) {
+		iter = list_entry(tmp, struct ptlrpc_request,
+				  rq_unreplied_list);
+
+		LASSERT(req->rq_xid != iter->rq_xid);
+		if (req->rq_xid < iter->rq_xid)
+			continue;
+		list_add(&req->rq_unreplied_list, &iter->rq_unreplied_list);
+		return;
+	}
+	list_add(&req->rq_unreplied_list, &imp->imp_unreplied_list);
+}
+
+void ptlrpc_assign_next_xid_nolock(struct ptlrpc_request *req)
+{
+	req->rq_xid = ptlrpc_next_xid();
+	ptlrpc_add_unreplied(req);
+}
+
+static inline void ptlrpc_assign_next_xid(struct ptlrpc_request *req)
+{
+	spin_lock(&req->rq_import->imp_lock);
+	ptlrpc_assign_next_xid_nolock(req);
+	spin_unlock(&req->rq_import->imp_lock);
+}
+
 int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 			     __u32 version, int opcode, char **bufs,
 			     struct ptlrpc_cli_ctx *ctx)
@@ -701,6 +737,7 @@ int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 	ptlrpc_at_set_req_timeout(request);
 
 	lustre_msg_set_opc(request->rq_reqmsg, opcode);
+	ptlrpc_assign_next_xid(request);
 
 	/* Let's setup deadline for req/reply/bulk unlink for opcode. */
 	if (cfs_fail_val == opcode) {
@@ -1230,6 +1267,24 @@ static void ptlrpc_save_versions(struct ptlrpc_request *req)
 	       versions[0], versions[1]);
 }
 
+__u64 ptlrpc_known_replied_xid(struct obd_import *imp)
+{
+	struct ptlrpc_request *req;
+
+	assert_spin_locked(&imp->imp_lock);
+	if (list_empty(&imp->imp_unreplied_list))
+		return 0;
+
+	req = list_entry(imp->imp_unreplied_list.next, struct ptlrpc_request,
+			 rq_unreplied_list);
+	LASSERTF(req->rq_xid >= 1, "XID:%llu\n", req->rq_xid);
+
+	if (imp->imp_known_replied_xid < req->rq_xid - 1)
+		imp->imp_known_replied_xid = req->rq_xid - 1;
+
+	return req->rq_xid - 1;
+}
+
 /**
  * Callback function called when client receives RPC reply for \a req.
  * Returns 0 on success or error code.
@@ -1317,6 +1372,11 @@ static int after_reply(struct ptlrpc_request *req)
 		else
 			req->rq_sent = now + req->rq_nr_resend;
 
+		/* Resend for EINPROGRESS will use a new XID */
+		spin_lock(&imp->imp_lock);
+		list_del_init(&req->rq_unreplied_list);
+		spin_unlock(&imp->imp_lock);
+
 		return 0;
 	}
 
@@ -1430,8 +1490,7 @@ static int after_reply(struct ptlrpc_request *req)
 static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 {
 	struct obd_import *imp = req->rq_import;
-	struct list_head *tmp;
-	u64 min_xid = ~0ULL;
+	u64 min_xid = 0;
 	int rc;
 
 	LASSERT(req->rq_phase == RQ_PHASE_NEW);
@@ -1451,17 +1510,8 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 
 	spin_lock(&imp->imp_lock);
 
-	/*
-	 * the very first time we assign XID. it's important to assign XID
-	 * and put it on the list atomically, so that the lowest assigned
-	 * XID is always known. this is vital for multislot last_rcvd
-	 */
-	if (req->rq_send_state == LUSTRE_IMP_REPLAY) {
-		LASSERT(req->rq_xid);
-	} else {
-		LASSERT(!req->rq_xid);
-		req->rq_xid = ptlrpc_next_xid();
-	}
+	LASSERT(req->rq_xid);
+	LASSERT(!list_empty(&req->rq_unreplied_list));
 
 	if (!req->rq_generation_set)
 		req->rq_import_generation = imp->imp_generation;
@@ -1493,25 +1543,23 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 	list_add_tail(&req->rq_list, &imp->imp_sending_list);
 	atomic_inc(&req->rq_import->imp_inflight);
 
-	/* find the lowest unreplied XID */
-	list_for_each(tmp, &imp->imp_delayed_list) {
-		struct ptlrpc_request *r;
-
-		r = list_entry(tmp, struct ptlrpc_request, rq_list);
-		if (r->rq_xid < min_xid)
-			min_xid = r->rq_xid;
-	}
-	list_for_each(tmp, &imp->imp_sending_list) {
-		struct ptlrpc_request *r;
-
-		r = list_entry(tmp, struct ptlrpc_request, rq_list);
-		if (r->rq_xid < min_xid)
-			min_xid = r->rq_xid;
-	}
+	/* find the known replied XID from the unreplied list, CONNECT
+	 * and DISCONNECT requests are skipped to make the sanity check
+	 * on server side happy. see process_req_last_xid().
+	 *
+	 * For CONNECT: Because replay requests have lower XID, it'll
+	 * break the sanity check if CONNECT bump the exp_last_xid on
+	 * server.
+	 *
+	 * For DISCONNECT: Since client will abort inflight RPC before
+	 * sending DISCONNECT, DISCONNECT may carry an XID which higher
+	 * than the inflight RPC.
+	 */
+	if (!ptlrpc_req_is_connect(req) && !ptlrpc_req_is_disconnect(req))
+		min_xid = ptlrpc_known_replied_xid(imp);
 	spin_unlock(&imp->imp_lock);
 
-	if (likely(min_xid != ~0ULL))
-		lustre_msg_set_last_xid(req->rq_reqmsg, min_xid - 1);
+	lustre_msg_set_last_xid(req->rq_reqmsg, min_xid);
 
 	lustre_msg_set_status(req->rq_reqmsg, current_pid());
 
@@ -1956,6 +2004,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 			list_del_init(&req->rq_list);
 			atomic_dec(&imp->imp_inflight);
 		}
+		list_del_init(&req->rq_unreplied_list);
 		spin_unlock(&imp->imp_lock);
 
 		atomic_dec(&set->set_remaining);
@@ -2353,6 +2402,7 @@ static void __ptlrpc_free_req(struct ptlrpc_request *request, int locked)
 		if (!locked)
 			spin_lock(&request->rq_import->imp_lock);
 		list_del_init(&request->rq_replay_list);
+		list_del_init(&request->rq_unreplied_list);
 		if (!locked)
 			spin_unlock(&request->rq_import->imp_lock);
 	}
@@ -3060,7 +3110,7 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 
 	LASSERT(bd);
 
-	if (!req->rq_resend || req->rq_nr_resend) {
+	if (!req->rq_resend) {
 		/* this request has a new xid, just use it as bulk matchbits */
 		req->rq_mbits = req->rq_xid;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index babb80d..66f5b49 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -904,6 +904,39 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 }
 
 /**
+ * Add all replay requests back to unreplied list before start replay,
+ * so that we can make sure the known replied XID is always increased
+ * only even if when replaying requests.
+ */
+static void ptlrpc_prepare_replay(struct obd_import *imp)
+{
+	struct ptlrpc_request *req;
+
+	if (imp->imp_state != LUSTRE_IMP_REPLAY ||
+	    imp->imp_resend_replay)
+		return;
+
+	/*
+	 * If the server was restart during repaly, the requests may
+	 * have been added to the unreplied list in former replay.
+	 */
+	spin_lock(&imp->imp_lock);
+
+	list_for_each_entry(req, &imp->imp_committed_list, rq_replay_list) {
+		if (list_empty(&req->rq_unreplied_list))
+			ptlrpc_add_unreplied(req);
+	}
+
+	list_for_each_entry(req, &imp->imp_replay_list, rq_replay_list) {
+		if (list_empty(&req->rq_unreplied_list))
+			ptlrpc_add_unreplied(req);
+	}
+
+	imp->imp_known_replied_xid = ptlrpc_known_replied_xid(imp);
+	spin_unlock(&imp->imp_lock);
+}
+
+/**
  * interpret_reply callback for connect RPCs.
  * Looks into returned status of connect operation and decides
  * what to do with the import - i.e enter recovery, promote it to
@@ -1154,6 +1187,7 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 	}
 
 finish:
+	ptlrpc_prepare_replay(imp);
 	rc = ptlrpc_import_recovery_state_machine(imp);
 	if (rc == -ENOTCONN) {
 		CDEBUG(D_HA, "evicted/aborted by %s@%s during recovery; invalidating and reconnecting\n",
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 5810565..da1209e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -509,20 +509,39 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	lustre_msg_set_conn_cnt(request->rq_reqmsg, imp->imp_conn_cnt);
 	lustre_msghdr_set_flags(request->rq_reqmsg, imp->imp_msghdr_flags);
 
-	if (request->rq_nr_resend) {
+	/*
+	 * If it's the first time to resend the request for EINPROGRESS,
+	 * we need to allocate a new XID (see after_reply()), it's different
+	 * from the resend for reply timeout.
+	 */
+	if (request->rq_nr_resend && list_empty(&request->rq_unreplied_list)) {
+		__u64 min_xid = 0;
 		/*
 		 * resend for EINPROGRESS, allocate new xid to avoid reply
 		 * reconstruction
 		 */
-		request->rq_xid = ptlrpc_next_xid();
-		DEBUG_REQ(D_RPCTRACE, request, "Allocating new xid for resend on EINPROGRESS");
-	}
+		spin_lock(&imp->imp_lock);
+		ptlrpc_assign_next_xid_nolock(request);
+		request->rq_mbits = request->rq_xid;
+		min_xid = ptlrpc_known_replied_xid(imp);
+		spin_unlock(&imp->imp_lock);
 
-	if (request->rq_bulk) {
+		lustre_msg_set_last_xid(request->rq_reqmsg, min_xid);
+		DEBUG_REQ(D_RPCTRACE, request, "Allocating new xid for resend on EINPROGRESS");
+	} else if (request->rq_bulk) {
 		ptlrpc_set_bulk_mbits(request);
 		lustre_msg_set_mbits(request->rq_reqmsg, request->rq_mbits);
 	}
 
+	if (list_empty(&request->rq_unreplied_list) ||
+	    request->rq_xid <= imp->imp_known_replied_xid) {
+		DEBUG_REQ(D_ERROR, request,
+			  "xid: %llu, replied: %llu, list_empty:%d\n",
+			  request->rq_xid, imp->imp_known_replied_xid,
+			  list_empty(&request->rq_unreplied_list));
+		LBUG();
+	}
+
 	/**
 	 * For enabled AT all request should have AT_SUPPORT in the
 	 * FULL import state when OBD_CONNECT_AT is set
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index f056c82..e0f859c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -71,6 +71,9 @@ int ptlrpc_expired_set(void *data);
 int ptlrpc_set_next_timeout(struct ptlrpc_request_set *);
 void ptlrpc_resend_req(struct ptlrpc_request *request);
 void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req);
+void ptlrpc_assign_next_xid_nolock(struct ptlrpc_request *req);
+__u64 ptlrpc_known_replied_xid(struct obd_import *imp);
+void ptlrpc_add_unreplied(struct ptlrpc_request *req);
 
 /* events.c */
 int ptlrpc_init_portals(void);
@@ -324,6 +327,7 @@ static inline void ptlrpc_cli_req_init(struct ptlrpc_request *req)
 
 	INIT_LIST_HEAD(&cr->cr_set_chain);
 	INIT_LIST_HEAD(&cr->cr_ctx_chain);
+	INIT_LIST_HEAD(&cr->cr_unreplied_list);
 	init_waitqueue_head(&cr->cr_reply_waitq);
 	init_waitqueue_head(&cr->cr_set_waitq);
 }
@@ -340,4 +344,24 @@ static inline void ptlrpc_srv_req_init(struct ptlrpc_request *req)
 	INIT_LIST_HEAD(&sr->sr_hist_list);
 }
 
+static inline bool ptlrpc_req_is_connect(struct ptlrpc_request *req)
+{
+	if (lustre_msg_get_opc(req->rq_reqmsg) == MDS_CONNECT ||
+	    lustre_msg_get_opc(req->rq_reqmsg) == OST_CONNECT ||
+	    lustre_msg_get_opc(req->rq_reqmsg) == MGS_CONNECT)
+		return true;
+	else
+		return false;
+}
+
+static inline bool ptlrpc_req_is_disconnect(struct ptlrpc_request *req)
+{
+	if (lustre_msg_get_opc(req->rq_reqmsg) == MDS_DISCONNECT ||
+	    lustre_msg_get_opc(req->rq_reqmsg) == OST_DISCONNECT ||
+	    lustre_msg_get_opc(req->rq_reqmsg) == MGS_DISCONNECT)
+		return true;
+	else
+		return false;
+}
+
 #endif /* PTLRPC_INTERNAL_H */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 9144cd8..344aedd 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -157,10 +157,22 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 		lustre_msg_add_flags(req->rq_reqmsg, MSG_RESENT);
 
 	spin_lock(&imp->imp_lock);
+	/* The resend replay request may have been removed from the
+	 * unreplied list.
+	 */
+	if (req && imp->imp_resend_replay &&
+	    list_empty(&req->rq_unreplied_list))
+		ptlrpc_add_unreplied(req);
+
 	imp->imp_resend_replay = 0;
 	spin_unlock(&imp->imp_lock);
 
 	if (req) {
+		/* The request should have been added back in unreplied list
+		 * by ptlrpc_prepare_replay().
+		 */
+		LASSERT(!list_empty(&req->rq_unreplied_list));
+
 		rc = ptlrpc_replay_req(req);
 		if (rc) {
 			CERROR("recovery replay error %d for req %llu\n",
-- 
2.7.4
