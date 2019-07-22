From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:52:08 -0400
Subject: [lustre-devel] [PATCH 01/11] lustre: ptlrpc: checkpatch cleanup
In-Reply-To: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
References: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563760338-806-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Many checkpatch errors exist in the ptlrpc layer. This address
a good chuck of them. Other are left since future patches will
cleanup those areas. Others will need more code rework so this
patch handles the simple cases. This is a good step forward
toward proper kernel code style compliance.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c          | 67 +++++++++++++++++++++++-------------
 fs/lustre/ptlrpc/connection.c      |  2 +-
 fs/lustre/ptlrpc/events.c          |  5 +--
 fs/lustre/ptlrpc/import.c          | 69 +++++++++++++++++++++-----------------
 fs/lustre/ptlrpc/layout.c          | 19 ++++++-----
 fs/lustre/ptlrpc/llog_client.c     |  3 +-
 fs/lustre/ptlrpc/lproc_ptlrpc.c    | 21 ++++++++----
 fs/lustre/ptlrpc/niobuf.c          | 12 ++++---
 fs/lustre/ptlrpc/nrs.c             |  2 +-
 fs/lustre/ptlrpc/pack_generic.c    |  6 ++--
 fs/lustre/ptlrpc/pinger.c          |  6 ++--
 fs/lustre/ptlrpc/ptlrpc_internal.h |  5 ++-
 fs/lustre/ptlrpc/ptlrpc_module.c   |  6 ++--
 fs/lustre/ptlrpc/ptlrpcd.c         |  3 +-
 fs/lustre/ptlrpc/recover.c         |  3 +-
 fs/lustre/ptlrpc/sec.c             | 21 +++++++-----
 fs/lustre/ptlrpc/sec_config.c      | 15 ++++++---
 fs/lustre/ptlrpc/sec_lproc.c       |  3 +-
 fs/lustre/ptlrpc/service.c         | 40 +++++++++++++---------
 19 files changed, 188 insertions(+), 120 deletions(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index da1ccd8..364c61f 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -204,7 +204,8 @@ struct ptlrpc_bulk_desc *ptlrpc_prep_bulk_imp(struct ptlrpc_request *req,
 EXPORT_SYMBOL(ptlrpc_prep_bulk_imp);
 
 void __ptlrpc_prep_bulk_page(struct ptlrpc_bulk_desc *desc,
-			     struct page *page, int pageoffset, int len, int pin)
+			     struct page *page, int pageoffset, int len,
+			     int pin)
 {
 	struct bio_vec *kiov;
 
@@ -342,9 +343,11 @@ static void ptlrpc_at_adj_service(struct ptlrpc_request *req,
 	 */
 	oldse = at_measured(&at->iat_service_estimate[idx], serv_est);
 	if (oldse != 0)
-		CDEBUG(D_ADAPTTO, "The RPC service estimate for %s ptl %d has changed from %d to %d\n",
-		       req->rq_import->imp_obd->obd_name, req->rq_request_portal,
-		       oldse, at_get(&at->iat_service_estimate[idx]));
+		CDEBUG(D_ADAPTTO,
+		       "The RPC service estimate for %s ptl %d has changed from %d to %d\n",
+		       req->rq_import->imp_obd->obd_name,
+		       req->rq_request_portal, oldse,
+		       at_get(&at->iat_service_estimate[idx]));
 }
 
 /* Expected network latency per remote node (secs) */
@@ -386,10 +389,10 @@ void ptlrpc_at_adj_net_latency(struct ptlrpc_request *req,
 
 	oldnl = at_measured(&at->iat_net_latency, nl);
 	if (oldnl != 0)
-		CDEBUG(D_ADAPTTO, "The network latency for %s (nid %s) has changed from %d to %d\n",
+		CDEBUG(D_ADAPTTO,
+		       "The network latency for %s (nid %s) has changed from %d to %d\n",
 		       req->rq_import->imp_obd->obd_name,
-		       obd_uuid2str(
-			       &req->rq_import->imp_connection->c_remote_uuid),
+		       obd_uuid2str(&req->rq_import->imp_connection->c_remote_uuid),
 		       oldnl, at_get(&at->iat_net_latency));
 }
 
@@ -513,7 +516,8 @@ void ptlrpc_free_rq_pool(struct ptlrpc_request_pool *pool)
 	struct ptlrpc_request *req;
 
 	while ((req = list_first_entry_or_null(&pool->prp_req_list,
-					       struct ptlrpc_request, rq_list))) {
+					       struct ptlrpc_request,
+					       rq_list))) {
 		list_del(&req->rq_list);
 		LASSERT(req->rq_reqbuf);
 		LASSERT(req->rq_reqbuf_len == pool->prp_rq_size);
@@ -665,7 +669,8 @@ void ptlrpc_add_unreplied(struct ptlrpc_request *req)
 	LASSERT(list_empty(&req->rq_unreplied_list));
 
 	/* unreplied list is sorted by xid in ascending order */
-	list_for_each_entry_reverse(iter, &imp->imp_unreplied_list, rq_unreplied_list) {
+	list_for_each_entry_reverse(iter, &imp->imp_unreplied_list,
+				    rq_unreplied_list) {
 		LASSERT(req->rq_xid != iter->rq_xid);
 		if (req->rq_xid < iter->rq_xid)
 			continue;
@@ -1136,7 +1141,9 @@ static int ptlrpc_import_delay_req(struct obd_import *imp,
 			  D_HA : D_ERROR, req, "IMP_CLOSED ");
 		*status = -EIO;
 	} else if (ptlrpc_send_limit_expired(req)) {
-		/* probably doesn't need to be a D_ERROR after initial testing */
+		/* probably doesn't need to be a D_ERROR after initial
+		 * testing
+		 */
 		DEBUG_REQ(D_HA, req, "send limit expired ");
 		*status = -ETIMEDOUT;
 	} else if (req->rq_send_state == LUSTRE_IMP_CONNECTING &&
@@ -1230,7 +1237,8 @@ static int ptlrpc_check_status(struct ptlrpc_request *req)
 		/* -EAGAIN is normal when using POSIX flocks */
 		if (ptlrpc_console_allow(req) &&
 		    !(opc == LDLM_ENQUEUE && err == -EAGAIN))
-			LCONSOLE_ERROR_MSG(0x011, "%s: operation %s to node %s failed: rc = %d\n",
+			LCONSOLE_ERROR_MSG(0x011,
+					   "%s: operation %s to node %s failed: rc = %d\n",
 					   imp->imp_obd->obd_name,
 					   ll_opcode2str(opc),
 					   libcfs_nid2str(nid), err);
@@ -1306,7 +1314,8 @@ static int after_reply(struct ptlrpc_request *req)
 
 	if (req->rq_reply_truncated) {
 		if (ptlrpc_no_resend(req)) {
-			DEBUG_REQ(D_ERROR, req, "reply buffer overflow, expected: %d, actual size: %d",
+			DEBUG_REQ(D_ERROR, req,
+				  "reply buffer overflow, expected: %d, actual size: %d",
 				  req->rq_nob_received, req->rq_repbuf_len);
 			return -EOVERFLOW;
 		}
@@ -1520,7 +1529,8 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 		req->rq_waiting = 1;
 		spin_unlock(&req->rq_lock);
 
-		DEBUG_REQ(D_HA, req, "req from PID %d waiting for recovery: (%s != %s)",
+		DEBUG_REQ(D_HA, req,
+			  "req from PID %d waiting for recovery: (%s != %s)",
 			  lustre_msg_get_status(req->rq_reqmsg),
 			  ptlrpc_import_state_name(req->rq_send_state),
 			  ptlrpc_import_state_name(imp->imp_state));
@@ -1574,7 +1584,8 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 		return 0;
 	}
 
-	CDEBUG(D_RPCTRACE, "Sending RPC pname:cluuid:pid:xid:nid:opc %s:%s:%d:%llu:%s:%d\n",
+	CDEBUG(D_RPCTRACE,
+	       "Sending RPC pname:cluuid:pid:xid:nid:opc %s:%s:%d:%llu:%s:%d\n",
 	       current->comm,
 	       imp->imp_obd->obd_uuid.uuid,
 	       lustre_msg_get_status(req->rq_reqmsg), req->rq_xid,
@@ -1837,7 +1848,9 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 				spin_unlock(&req->rq_lock);
 
 				if (req->rq_timedout || req->rq_resend) {
-					/* This is re-sending anyway, let's mark req as resend. */
+					/* This is re-sending anyway,
+					 * let's mark req as resend.
+					 */
 					spin_lock(&req->rq_lock);
 					req->rq_resend = 1;
 					spin_unlock(&req->rq_lock);
@@ -2158,10 +2171,9 @@ void ptlrpc_expired_set(struct ptlrpc_request_set *set)
 static void ptlrpc_interrupted_set(struct ptlrpc_request_set *set)
 {
 	struct ptlrpc_request *req;
-	CDEBUG(D_RPCTRACE, "INTERRUPTED SET %p\n", set);
 
+	CDEBUG(D_RPCTRACE, "INTERRUPTED SET %p\n", set);
 	list_for_each_entry(req, &set->set_requests, rq_set_chain) {
-
 		if (req->rq_phase != RQ_PHASE_RPC &&
 		    req->rq_phase != RQ_PHASE_UNREG_RPC)
 			continue;
@@ -2260,8 +2272,9 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 			} else if (rc < 0) {
 				rc = -EINTR;
 				ptlrpc_interrupted_set(set);
-			} else
+			} else {
 				rc = 0;
+			}
 		} else {
 			/*
 			 * At least one request is in flight, so no
@@ -2283,8 +2296,9 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 				 */
 				if (l_fatal_signal_pending(current))
 					ptlrpc_interrupted_set(set);
-			} else
+			} else {
 				rc = 0;
+			}
 		}
 
 		LASSERT(rc == 0 || rc == -EINTR || rc == -ETIMEDOUT);
@@ -2299,7 +2313,8 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 		 * the error cases -eeb.
 		 */
 		if (rc == 0 && atomic_read(&set->set_remaining) == 0) {
-			list_for_each_entry(req, &set->set_requests, rq_set_chain) {
+			list_for_each_entry(req, &set->set_requests,
+					    rq_set_chain) {
 				spin_lock(&req->rq_lock);
 				req->rq_invalid_rqset = 1;
 				spin_unlock(&req->rq_lock);
@@ -2513,7 +2528,7 @@ static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 		return 0;
 
 	/*
-	 * We have to wait_event_idle_timeout() whatever the result, to give liblustre
+	 * We have to wait_event_idle_timeout() whatever the result, to get
 	 * a chance to run reply_in_callback(), and to make sure we've
 	 * unlinked before returning a req to the pool.
 	 */
@@ -2528,6 +2543,7 @@ static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 		 * timeout lets us CWARN for visibility of sluggish NALs
 		 */
 		int cnt = 0;
+
 		while (cnt < LONG_UNLINK &&
 		       (rc = wait_event_idle_timeout(*wq,
 						     !ptlrpc_client_recv_or_unlink(request),
@@ -2716,6 +2732,7 @@ void ptlrpc_retain_replayable_request(struct ptlrpc_request *req,
 				      struct obd_import *imp)
 {
 	struct ptlrpc_request *iter;
+
 	assert_spin_locked(&imp->imp_lock);
 
 	if (req->rq_transno == 0) {
@@ -2742,7 +2759,8 @@ void ptlrpc_retain_replayable_request(struct ptlrpc_request *req,
 	LASSERT(imp->imp_replayable);
 	/* Balanced in ptlrpc_free_committed, usually. */
 	ptlrpc_request_addref(req);
-	list_for_each_entry_reverse(iter, &imp->imp_replay_list, rq_replay_list) {
+	list_for_each_entry_reverse(iter, &imp->imp_replay_list,
+				    rq_replay_list) {
 		/*
 		 * We may have duplicate transnos if we create and then
 		 * open a file, or for closes retained if to match creating
@@ -3110,7 +3128,8 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 		 * 'resend for the -EINPROGRESS resend'. To make it simple,
 		 * we opt to generate mbits for all resend cases.
 		 */
-		if (OCD_HAS_FLAG(&bd->bd_import->imp_connect_data, BULK_MBITS)) {
+		if (OCD_HAS_FLAG(&bd->bd_import->imp_connect_data,
+				 BULK_MBITS)) {
 			req->rq_mbits = ptlrpc_next_xid();
 		} else {
 			/* old version transfers rq_xid to peer as matchbits */
@@ -3188,7 +3207,7 @@ u64 ptlrpc_sample_next_xid(void)
  *    have delay before it really runs by ptlrpcd thread.
  */
 struct ptlrpc_work_async_args {
-	int (*cb)(const struct lu_env *, void *);
+	int (*cb)(const struct lu_env *env, void *cbdata);
 	void *cbdata;
 };
 
diff --git a/fs/lustre/ptlrpc/connection.c b/fs/lustre/ptlrpc/connection.c
index ca9b4ca..5466755 100644
--- a/fs/lustre/ptlrpc/connection.c
+++ b/fs/lustre/ptlrpc/connection.c
@@ -105,7 +105,7 @@ struct ptlrpc_connection *
 	 */
 	conn2 = rhashtable_lookup_get_insert_fast(&conn_hash, &conn->c_hash,
 						  conn_hash_params);
-	if (conn2 != NULL) {
+	if (conn2) {
 		/* insertion failed */
 		kfree(conn);
 		if (IS_ERR(conn2))
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index 0c16a2c..fc3c7f0 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -254,13 +254,14 @@ static void ptlrpc_req_add_history(struct ptlrpc_service_part *svcpt,
 				   struct ptlrpc_request *req)
 {
 	u64 sec = req->rq_arrival_time.tv_sec;
-	u32 usec = req->rq_arrival_time.tv_nsec / NSEC_PER_USEC / 16; /* usec / 16 */
 	u64 new_seq;
+	u32 usec;
 
+	/* usec /16 */
+	usec = req->rq_arrival_time.tv_nsec / NSEC_PER_USEC / 16;
 	/* set sequence ID for request and add it to history list,
 	 * it must be called with hold svcpt::scp_lock
 	 */
-
 	new_seq = (sec << REQS_SEC_SHIFT) |
 		  (usec << REQS_USEC_SHIFT) |
 		  (svcpt->scp_cpt < 0 ? 0 : svcpt->scp_cpt);
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 18823d5..d49707a 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -105,7 +105,6 @@ static void __import_set_state(struct obd_import *imp,
 static int ptlrpc_connect_interpret(const struct lu_env *env,
 				    struct ptlrpc_request *request,
 				    void *data, int rc);
-int ptlrpc_import_recovery_state_machine(struct obd_import *imp);
 
 /* Only this function is allowed to change the import state when it is
  * CLOSED. I would rather refcount the import and free it after
@@ -170,10 +169,12 @@ int ptlrpc_set_import_discon(struct obd_import *imp, u32 conn_cnt)
 
 		if (imp->imp_replayable) {
 			LCONSOLE_WARN("%s: Connection to %.*s (at %s) was lost; in progress operations using this service will wait for recovery to complete\n",
-				      imp->imp_obd->obd_name, target_len, target_start,
+				      imp->imp_obd->obd_name,
+				      target_len, target_start,
 				      libcfs_nid2str(imp->imp_connection->c_peer.nid));
 		} else {
-			LCONSOLE_ERROR_MSG(0x166, "%s: Connection to %.*s (at %s) was lost; in progress operations using this service will fail\n",
+			LCONSOLE_ERROR_MSG(0x166,
+					   "%s: Connection to %.*s (at %s) was lost; in progress operations using this service will fail\n",
 					   imp->imp_obd->obd_name,
 					   target_len, target_start,
 					   libcfs_nid2str(imp->imp_connection->c_peer.nid));
@@ -317,8 +318,9 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 
 			spin_lock(&imp->imp_lock);
 			if (atomic_read(&imp->imp_inflight) == 0) {
-				int count = atomic_read(&imp->imp_unregistering);
+				int count;
 
+				count = atomic_read(&imp->imp_unregistering);
 				/* We know that "unregistering" rpcs only can
 				 * survive in sending or delaying lists (they
 				 * maybe waiting for long reply unlink in
@@ -326,7 +328,8 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 				 * is no inflight and unregistering != 0, this
 				 * is bug.
 				 */
-				LASSERTF(count == 0, "Some RPCs are still unregistering: %d\n",
+				LASSERTF(count == 0,
+					 "Some RPCs are still unregistering: %d\n",
 					 count);
 
 				/* Let's save one loop as soon as inflight have
@@ -348,8 +351,7 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 
 				CERROR("%s: Unregistering RPCs found (%d). Network is sluggish? Waiting them to error out.\n",
 				       cli_tgt,
-				       atomic_read(&imp->
-						   imp_unregistering));
+				       atomic_read(&imp->imp_unregistering));
 			}
 			spin_unlock(&imp->imp_lock);
 		}
@@ -405,7 +407,8 @@ void ptlrpc_fail_import(struct obd_import *imp, u32 conn_cnt)
 
 	if (ptlrpc_set_import_discon(imp, conn_cnt)) {
 		if (!imp->imp_replayable) {
-			CDEBUG(D_HA, "import %s@%s for %s not replayable, auto-deactivating\n",
+			CDEBUG(D_HA,
+			       "import %s@%s for %s not replayable, auto-deactivating\n",
 			       obd2cli_tgt(imp->imp_obd),
 			       imp->imp_connection->c_remote_uuid.uuid,
 			       imp->imp_obd->obd_name);
@@ -466,7 +469,7 @@ static int import_select_connection(struct obd_import *imp)
 		 */
 		if ((conn->oic_last_attempt == 0) ||
 		    time_before_eq64(conn->oic_last_attempt,
-					imp->imp_last_success_conn)) {
+				     imp->imp_last_success_conn)) {
 			imp_conn = conn;
 			tried_all = 0;
 			break;
@@ -506,7 +509,8 @@ static int import_select_connection(struct obd_import *imp)
 				at_reset(at, CONNECTION_SWITCH_MAX);
 		}
 		LASSERT(imp_conn->oic_last_attempt);
-		CDEBUG(D_HA, "%s: tried all connections, increasing latency to %ds\n",
+		CDEBUG(D_HA,
+		       "%s: tried all connections, increasing latency to %ds\n",
 		       imp->imp_obd->obd_name, at_get(at));
 	}
 
@@ -526,7 +530,8 @@ static int import_select_connection(struct obd_import *imp)
 			deuuidify(obd2cli_tgt(imp->imp_obd), NULL,
 				  &target_start, &target_len);
 
-			CDEBUG(D_HA, "%s: Connection changing to %.*s (at %s)\n",
+			CDEBUG(D_HA,
+			       "%s: Connection changing to %.*s (at %s)\n",
 			       imp->imp_obd->obd_name,
 			       target_len, target_start,
 			       libcfs_nid2str(imp_conn->oic_conn->c_peer.nid));
@@ -819,9 +824,8 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 				      ocd->ocd_cksum_types,
 				      cksum_types_supported_client());
 			return -EPROTO;
-		} else {
-			cli->cl_supp_cksum_types = ocd->ocd_cksum_types;
 		}
+		cli->cl_supp_cksum_types = ocd->ocd_cksum_types;
 	} else {
 		/*
 		 * The server does not support OBD_CONNECT_CKSUM.
@@ -862,7 +866,8 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 	 * disable lru_resize, etc.
 	 */
 	if (old_connect_flags != exp_connect_flags(exp) || init_connect) {
-		CDEBUG(D_HA, "%s: Resetting ns_connect_flags to server flags: %#llx\n",
+		CDEBUG(D_HA,
+		       "%s: Resetting ns_connect_flags to server flags: %#llx\n",
 		       imp->imp_obd->obd_name, ocd->ocd_connect_flags);
 		imp->imp_obd->obd_namespace->ns_connect_flags =
 			ocd->ocd_connect_flags;
@@ -1113,20 +1118,18 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 			 * with server again
 			 */
 			if ((msg_flags & MSG_CONNECT_RECOVERING)) {
-				CDEBUG(level, "%s@%s changed server handle from %#llx to %#llx but is still in recovery\n",
+				CDEBUG(level,
+				       "%s@%s changed server handle from %#llx to %#llx but is still in recovery\n",
 				       obd2cli_tgt(imp->imp_obd),
 				       imp->imp_connection->c_remote_uuid.uuid,
 				       imp->imp_remote_handle.cookie,
-				       lustre_msg_get_handle(
-				       request->rq_repmsg)->cookie);
+				       lustre_msg_get_handle(request->rq_repmsg)->cookie);
 			} else {
 				LCONSOLE_WARN("Evicted from %s (at %s) after server handle changed from %#llx to %#llx\n",
 					      obd2cli_tgt(imp->imp_obd),
-					      imp->imp_connection-> \
-					      c_remote_uuid.uuid,
+					      imp->imp_connection->c_remote_uuid.uuid,
 					      imp->imp_remote_handle.cookie,
-					      lustre_msg_get_handle(
-						      request->rq_repmsg)->cookie);
+					      lustre_msg_get_handle(request->rq_repmsg)->cookie);
 			}
 
 			imp->imp_remote_handle =
@@ -1145,7 +1148,8 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		}
 
 		if (imp->imp_invalid) {
-			CDEBUG(D_HA, "%s: reconnected but import is invalid; marking evicted\n",
+			CDEBUG(D_HA,
+			       "%s: reconnected but import is invalid; marking evicted\n",
 			       imp->imp_obd->obd_name);
 			IMPORT_SET_STATE(imp, LUSTRE_IMP_EVICTED);
 		} else if (msg_flags & MSG_CONNECT_RECOVERING) {
@@ -1169,7 +1173,8 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		imp->imp_replay_cursor = &imp->imp_committed_list;
 		IMPORT_SET_STATE(imp, LUSTRE_IMP_REPLAY);
 	} else {
-		DEBUG_REQ(D_HA, request, "%s: evicting (reconnect/recover flags not set: %x)",
+		DEBUG_REQ(D_HA, request,
+			  "%s: evicting (reconnect/recover flags not set: %x)",
 			  imp->imp_obd->obd_name, msg_flags);
 		imp->imp_remote_handle =
 				*lustre_msg_get_handle(request->rq_repmsg);
@@ -1191,7 +1196,8 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 	ptlrpc_prepare_replay(imp);
 	rc = ptlrpc_import_recovery_state_machine(imp);
 	if (rc == -ENOTCONN) {
-		CDEBUG(D_HA, "evicted/aborted by %s@%s during recovery; invalidating and reconnecting\n",
+		CDEBUG(D_HA,
+		       "evicted/aborted by %s@%s during recovery; invalidating and reconnecting\n",
 		       obd2cli_tgt(imp->imp_obd),
 		       imp->imp_connection->c_remote_uuid.uuid);
 		ptlrpc_connect_import(imp);
@@ -1236,7 +1242,8 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 				 * connection from liblustre clients, so we
 				 * should never see this from VFS context
 				 */
-				LCONSOLE_ERROR_MSG(0x16a, "Server %s version (%d.%d.%d.%d) refused connection from this client with an incompatible version (%s).  Client must be recompiled\n",
+				LCONSOLE_ERROR_MSG(0x16a,
+						   "Server %s version (%d.%d.%d.%d) refused connection from this client with an incompatible version (%s).  Client must be recompiled\n",
 						   obd2cli_tgt(imp->imp_obd),
 						   OBD_OCD_VERSION_MAJOR(ocd->ocd_version),
 						   OBD_OCD_VERSION_MINOR(ocd->ocd_version),
@@ -1278,7 +1285,8 @@ static int completed_replay_interpret(const struct lu_env *env,
 			       "%s: version recovery fails, reconnecting\n",
 			       req->rq_import->imp_obd->obd_name);
 		} else {
-			CDEBUG(D_HA, "%s: LAST_REPLAY message error: %d, reconnecting\n",
+			CDEBUG(D_HA,
+			       "%s: LAST_REPLAY message error: %d, reconnecting\n",
 			       req->rq_import->imp_obd->obd_name,
 			       req->rq_status);
 		}
@@ -1383,7 +1391,8 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 		/* Don't care about MGC eviction */
 		if (strcmp(imp->imp_obd->obd_type->typ_name,
 			   LUSTRE_MGC_NAME) != 0) {
-			LCONSOLE_ERROR_MSG(0x167, "%s: This client was evicted by %.*s; in progress operations using this service will fail.\n",
+			LCONSOLE_ERROR_MSG(0x167,
+					   "%s: This client was evicted by %.*s; in progress operations using this service will fail.\n",
 					   imp->imp_obd->obd_name, target_len,
 					   target_start);
 		}
@@ -1638,9 +1647,9 @@ int at_measured(struct adaptive_timeout *at, unsigned int val)
 	at->at_current =  max(at->at_current, at_min);
 
 	if (at->at_current != old)
-		CDEBUG(D_OTHER, "AT %p change: old=%u new=%u delta=%d (val=%u) hist %u %u %u %u\n",
-		       at,
-		       old, at->at_current, at->at_current - old, val,
+		CDEBUG(D_OTHER,
+		       "AT %p change: old=%u new=%u delta=%d (val=%u) hist %u %u %u %u\n",
+		       at, old, at->at_current, at->at_current - old, val,
 		       at->at_hist[0], at->at_hist[1], at->at_hist[2],
 		       at->at_hist[3]);
 
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 3bebfd7..da315f7 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -775,8 +775,8 @@ struct req_msg_field {
 	 * but the actual size must be a whole multiple of @rmf_size.
 	 */
 	const int   rmf_size;
-	void	(*rmf_swabber)(void *);
-	void	(*rmf_dumper)(void *);
+	void	(*rmf_swabber)(void *value);
+	void	(*rmf_dumper)(void *value);
 	int	 rmf_offset[ARRAY_SIZE(req_formats)][RCL_NR];
 };
 
@@ -1053,7 +1053,8 @@ struct req_msg_field RMF_LAYOUT_INTENT =
  */
 struct req_msg_field RMF_OST_BODY =
 	DEFINE_MSGF("ost_body", 0,
-		    sizeof(struct ost_body), lustre_swab_ost_body, dump_ost_body);
+		    sizeof(struct ost_body), lustre_swab_ost_body,
+		    dump_ost_body);
 EXPORT_SYMBOL(RMF_OST_BODY);
 
 struct req_msg_field RMF_OBD_IOOBJ =
@@ -1868,7 +1869,8 @@ u32 __req_capsule_offset(const struct req_capsule *pill,
 	     i < n;
 	     i++, p += field->rmf_size) {
 		if (dump) {
-			CDEBUG(D_RPCTRACE, "Dump of %sarray field %s, element %d follows\n",
+			CDEBUG(D_RPCTRACE,
+			       "Dump of %sarray field %s, element %d follows\n",
 			       do_swab ? "unswabbed " : "", field->rmf_name, i);
 			field->rmf_dumper(p);
 		}
@@ -1876,7 +1878,8 @@ u32 __req_capsule_offset(const struct req_capsule *pill,
 			continue;
 		swabber(p);
 		if (dump) {
-			CDEBUG(D_RPCTRACE, "Dump of swabbed array field %s, element %d follows\n",
+			CDEBUG(D_RPCTRACE,
+			       "Dump of swabbed array field %s, element %d follows\n",
 			       field->rmf_name, i);
 			field->rmf_dumper(value);
 		}
@@ -2145,8 +2148,7 @@ u32 req_capsule_fmt_size(u32 magic, const struct req_format *fmt,
 
 	for (; i < fmt->rf_fields[loc].nr; ++i)
 		if (fmt->rf_fields[loc].d[i]->rmf_size != -1)
-			size += cfs_size_round(fmt->rf_fields[loc].d[i]->
-					       rmf_size);
+			size += cfs_size_round(fmt->rf_fields[loc].d[i]->rmf_size);
 	return size;
 }
 
@@ -2185,8 +2187,9 @@ void req_capsule_extend(struct req_capsule *pill, const struct req_format *fmt)
 	for (i = 0; i < RCL_NR; ++i) {
 		LASSERT(fmt->rf_fields[i].nr >= old->rf_fields[i].nr);
 		for (j = 0; j < old->rf_fields[i].nr - 1; ++j) {
-			const struct req_msg_field *ofield = FMT_FIELD(old, i, j);
+			const struct req_msg_field *ofield;
 
+			ofield = FMT_FIELD(old, i, j);
 			/* "opaque" fields can be transmogrified */
 			if (!ofield->rmf_swabber &&
 			    (ofield->rmf_flags & ~RMF_F_NO_SIZE_CHECK) == 0 &&
diff --git a/fs/lustre/ptlrpc/llog_client.c b/fs/lustre/ptlrpc/llog_client.c
index 8ca6959..e5ff080 100644
--- a/fs/lustre/ptlrpc/llog_client.c
+++ b/fs/lustre/ptlrpc/llog_client.c
@@ -278,7 +278,8 @@ static int llog_client_read_header(const struct lu_env *env,
 	int rc;
 
 	LLOG_CLIENT_ENTRY(handle->lgh_ctxt, imp);
-	req = ptlrpc_request_alloc_pack(imp, &RQF_LLOG_ORIGIN_HANDLE_READ_HEADER,
+	req = ptlrpc_request_alloc_pack(imp,
+					&RQF_LLOG_ORIGIN_HANDLE_READ_HEADER,
 					LUSTRE_LOG_VERSION,
 					LLOG_ORIGIN_HANDLE_READ_HEADER);
 	if (!req) {
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 0d56704..bc5dc3f 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -282,7 +282,8 @@ static const char *ll_eopcode2str(u32 opcode)
 					 const char __user *buffer,
 					 size_t count, loff_t *off)
 {
-	struct ptlrpc_service *svc = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *m = file->private_data;
+	struct ptlrpc_service *svc = m->private;
 	int bufpages;
 	int val;
 	int rc;
@@ -628,7 +629,8 @@ static ssize_t ptlrpc_lprocfs_nrs_seq_write(struct file *file,
 					    const char __user *buffer,
 					    size_t count, loff_t *off)
 {
-	struct ptlrpc_service *svc = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *m = file->private_data;
+	struct ptlrpc_service *svc = m->private;
 	enum ptlrpc_nrs_queue_type queue = PTLRPC_NRS_QUEUE_BOTH;
 	char *cmd;
 	char *cmd_copy = NULL;
@@ -1180,7 +1182,8 @@ void ptlrpc_lprocfs_unregister_obd(struct obd_device *obd)
 int lprocfs_wr_ping(struct file *file, const char __user *buffer,
 		    size_t count, loff_t *off)
 {
-	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *m = file->private_data;
+	struct obd_device *obd = m->private;
 	struct ptlrpc_request *req;
 	int rc;
 
@@ -1211,7 +1214,8 @@ int lprocfs_wr_ping(struct file *file, const char __user *buffer,
 int lprocfs_wr_import(struct file *file, const char __user *buffer,
 		      size_t count, loff_t *off)
 {
-	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *m = file->private_data;
+	struct obd_device *obd = m->private;
 	struct obd_import *imp = obd->u.cli.cl_import;
 	char *kbuf = NULL;
 	char *uuid;
@@ -1253,12 +1257,14 @@ int lprocfs_wr_import(struct file *file, const char __user *buffer,
 		if (*endptr) {
 			CERROR("config: wrong instance # %s\n", ptr);
 		} else if (inst != imp->imp_connect_data.ocd_instance) {
-			CDEBUG(D_INFO, "IR: %s is connecting to an obsoleted target(%u/%u), reconnecting...\n",
+			CDEBUG(D_INFO,
+			       "IR: %s is connecting to an obsoleted target(%u/%u), reconnecting...\n",
 			       imp->imp_obd->obd_name,
 			       imp->imp_connect_data.ocd_instance, inst);
 			do_reconn = 1;
 		} else {
-			CDEBUG(D_INFO, "IR: %s has already been connecting to new target(%u)\n",
+			CDEBUG(D_INFO,
+			       "IR: %s has already been connecting to new target(%u)\n",
 			       imp->imp_obd->obd_name, inst);
 		}
 	}
@@ -1292,7 +1298,8 @@ int lprocfs_rd_pinger_recov(struct seq_file *m, void *n)
 int lprocfs_wr_pinger_recov(struct file *file, const char __user *buffer,
 			    size_t count, loff_t *off)
 {
-	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *m = file->private_data;
+	struct obd_device *obd = m->private;
 	struct client_obd *cli = &obd->u.cli;
 	struct obd_import *imp = cli->cl_import;
 	int rc, val;
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index c279fb1..033d628 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -220,7 +220,8 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 		      total_md - desc->bd_md_count);
 	spin_unlock(&desc->bd_lock);
 
-	CDEBUG(D_NET, "Setup %u bulk %s buffers: %u pages %u bytes, mbits x%#llx-%#llx, portal %u\n",
+	CDEBUG(D_NET,
+	       "Setup %u bulk %s buffers: %u pages %u bytes, mbits x%#llx-%#llx, portal %u\n",
 	       desc->bd_md_count,
 	       ptlrpc_is_bulk_op_get(desc->bd_type) ? "get-source" : "put-sink",
 	       desc->bd_iov_count, desc->bd_nob,
@@ -335,7 +336,8 @@ static void ptlrpc_at_set_reply(struct ptlrpc_request *req, int flags)
 
 	if (req->rq_reqmsg &&
 	    !(lustre_msghdr_get_flags(req->rq_reqmsg) & MSGHDR_AT_SUPPORT)) {
-		CDEBUG(D_ADAPTTO, "No early reply support: flags=%#x req_flags=%#x magic=%x/%x len=%d\n",
+		CDEBUG(D_ADAPTTO,
+		       "No early reply support: flags=%#x req_flags=%#x magic=%x/%x len=%d\n",
 		       flags, lustre_msg_get_flags(req->rq_reqmsg),
 		       lustre_msg_get_magic(req->rq_reqmsg),
 		       lustre_msg_get_magic(req->rq_repmsg), req->rq_replen);
@@ -542,7 +544,8 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 		spin_unlock(&imp->imp_lock);
 
 		lustre_msg_set_last_xid(request->rq_reqmsg, min_xid);
-		DEBUG_REQ(D_RPCTRACE, request, "Allocating new xid for resend on EINPROGRESS");
+		DEBUG_REQ(D_RPCTRACE, request,
+			  "Allocating new xid for resend on EINPROGRESS");
 	}
 
 	if (request->rq_bulk) {
@@ -667,7 +670,8 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 			goto cleanup_me;
 		}
 
-		CDEBUG(D_NET, "Setup reply buffer: %u bytes, xid %llu, portal %u\n",
+		CDEBUG(D_NET,
+		       "Setup reply buffer: %u bytes, xid %llu, portal %u\n",
 		       request->rq_repbuf_len, request->rq_xid,
 		       request->rq_reply_portal);
 	}
diff --git a/fs/lustre/ptlrpc/nrs.c b/fs/lustre/ptlrpc/nrs.c
index a56b7b3..953a0b8 100644
--- a/fs/lustre/ptlrpc/nrs.c
+++ b/fs/lustre/ptlrpc/nrs.c
@@ -79,7 +79,7 @@ static int nrs_policy_ctl_locked(struct ptlrpc_nrs_policy *policy,
 
 	return policy->pol_desc->pd_ops->op_policy_ctl ?
 	       policy->pol_desc->pd_ops->op_policy_ctl(policy, opc, arg) :
-	       -ENOSYS;
+	       -ENXIO;
 }
 
 static void __nrs_policy_stop(struct ptlrpc_nrs_policy *policy)
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 2cbb855..6d61cc7 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1799,7 +1799,8 @@ void lustre_swab_mgs_nidtbl_entry(struct mgs_nidtbl_entry *entry)
 	__swab32s(&entry->mne_length);
 
 	/* mne_nid_(count|type) must be one byte size because we're gonna
-	 * access it w/o swapping. */
+	 * access it w/o swapping:
+	 */
 	BUILD_BUG_ON(sizeof(entry->mne_nid_count) != sizeof(u8));
 	BUILD_BUG_ON(sizeof(entry->mne_nid_type) != sizeof(u8));
 
@@ -2175,7 +2176,8 @@ static void dump_obdo(struct obdo *oa)
 
 	CDEBUG(D_RPCTRACE, "obdo: o_valid = %08x\n", valid);
 	if (valid & OBD_MD_FLID)
-		CDEBUG(D_RPCTRACE, "obdo: id = " DOSTID "\n", POSTID(&oa->o_oi));
+		CDEBUG(D_RPCTRACE, "obdo: id = " DOSTID "\n",
+		       POSTID(&oa->o_oi));
 	if (valid & OBD_MD_FLFID)
 		CDEBUG(D_RPCTRACE, "obdo: o_parent_seq = %#llx\n",
 		       oa->o_parent_seq);
diff --git a/fs/lustre/ptlrpc/pinger.c b/fs/lustre/ptlrpc/pinger.c
index b3297b5..6a437f4 100644
--- a/fs/lustre/ptlrpc/pinger.c
+++ b/fs/lustre/ptlrpc/pinger.c
@@ -190,7 +190,8 @@ static void ptlrpc_pinger_process_import(struct obd_import *imp,
 
 	spin_unlock(&imp->imp_lock);
 
-	CDEBUG(level == LUSTRE_IMP_FULL ? D_INFO : D_HA, "%s->%s: level %s/%u force %u force_next %u deactive %u pingable %u suppress %u\n",
+	CDEBUG(level == LUSTRE_IMP_FULL ? D_INFO : D_HA,
+	       "%s->%s: level %s/%u force %u force_next %u deactive %u pingable %u suppress %u\n",
 	       imp->imp_obd->obd_uuid.uuid, obd2cli_tgt(imp->imp_obd),
 	       ptlrpc_import_state_name(level), level, force, force_next,
 	       imp->imp_deactive, imp->imp_pingable, suppress);
@@ -203,7 +204,8 @@ static void ptlrpc_pinger_process_import(struct obd_import *imp,
 	} else if (level != LUSTRE_IMP_FULL ||
 		   imp->imp_obd->obd_no_recov ||
 		   imp_is_deactive(imp)) {
-		CDEBUG(D_HA, "%s->%s: not pinging (in recovery or recovery disabled: %s)\n",
+		CDEBUG(D_HA,
+		       "%s->%s: not pinging (in recovery or recovery disabled: %s)\n",
 		       imp->imp_obd->obd_uuid.uuid, obd2cli_tgt(imp->imp_obd),
 		       ptlrpc_import_state_name(level));
 		if (force) {
diff --git a/fs/lustre/ptlrpc/ptlrpc_internal.h b/fs/lustre/ptlrpc/ptlrpc_internal.h
index 5383b68..201ccdd 100644
--- a/fs/lustre/ptlrpc/ptlrpc_internal.h
+++ b/fs/lustre/ptlrpc/ptlrpc_internal.h
@@ -224,8 +224,8 @@ struct ptlrpc_nrs_policy *nrs_request_policy(struct ptlrpc_nrs_request *nrq)
  * a separating space character.
  */
 #define LPROCFS_NRS_WR_QUANTUM_MAX_CMD					       \
- sizeof(NRS_LPROCFS_QUANTUM_NAME_REG __stringify(LPROCFS_NRS_QUANTUM_MAX) " "  \
-	NRS_LPROCFS_QUANTUM_NAME_HP __stringify(LPROCFS_NRS_QUANTUM_MAX))
+	sizeof(NRS_LPROCFS_QUANTUM_NAME_REG __stringify(LPROCFS_NRS_QUANTUM_MAX) " "  \
+	       NRS_LPROCFS_QUANTUM_NAME_HP __stringify(LPROCFS_NRS_QUANTUM_MAX))
 
 /* ptlrpc/nrs_fifo.c */
 extern struct ptlrpc_nrs_pol_conf nrs_conf_fifo;
@@ -301,7 +301,6 @@ static inline int tgt_mod_init(void)
 
 static inline void tgt_mod_exit(void)
 {
-	return;
 }
 
 static inline void ptlrpc_reqset_put(struct ptlrpc_request_set *set)
diff --git a/fs/lustre/ptlrpc/ptlrpc_module.c b/fs/lustre/ptlrpc/ptlrpc_module.c
index 5c32b657..f73ba41 100644
--- a/fs/lustre/ptlrpc/ptlrpc_module.c
+++ b/fs/lustre/ptlrpc/ptlrpc_module.c
@@ -46,7 +46,7 @@
 #endif
 
 DEFINE_MUTEX(ptlrpc_startup);
-static int ptlrpc_active = 0;
+static int ptlrpc_active;
 
 int ptlrpc_inc_ref(void)
 {
@@ -58,7 +58,7 @@ int ptlrpc_inc_ref(void)
 
 		rc = ptlrpc_init_portals();
 		if (!rc) {
-			rc= ptlrpc_start_pinger();
+			rc = ptlrpc_start_pinger();
 			if (rc)
 				ptlrpc_exit_portals();
 		}
@@ -160,7 +160,7 @@ static int __init ptlrpc_init(void)
 		req_layout_fini();
 		/* Fall through */
 	default:
-		;
+		break;
 	}
 
 	return rc;
diff --git a/fs/lustre/ptlrpc/ptlrpcd.c b/fs/lustre/ptlrpc/ptlrpcd.c
index f0ac296..92b477d 100644
--- a/fs/lustre/ptlrpc/ptlrpcd.c
+++ b/fs/lustre/ptlrpc/ptlrpcd.c
@@ -362,7 +362,8 @@ static int ptlrpcd_check(struct lu_env *env, struct ptlrpcd_ctl *pc)
 				if (atomic_read(&ps->set_new_count)) {
 					rc = ptlrpcd_steal_rqset(set, ps);
 					if (rc > 0)
-						CDEBUG(D_RPCTRACE, "transfer %d async RPCs [%d->%d]\n",
+						CDEBUG(D_RPCTRACE,
+						       "transfer %d async RPCs [%d->%d]\n",
 						       rc, partner->pc_index,
 						       pc->pc_index);
 				}
diff --git a/fs/lustre/ptlrpc/recover.c b/fs/lustre/ptlrpc/recover.c
index af672ab..5548049 100644
--- a/fs/lustre/ptlrpc/recover.c
+++ b/fs/lustre/ptlrpc/recover.c
@@ -232,7 +232,8 @@ void ptlrpc_request_handle_notconn(struct ptlrpc_request *failed_req)
 	if (ptlrpc_set_import_discon(imp,
 			      lustre_msg_get_conn_cnt(failed_req->rq_reqmsg))) {
 		if (!imp->imp_replayable) {
-			CDEBUG(D_HA, "import %s@%s for %s not replayable, auto-deactivating\n",
+			CDEBUG(D_HA,
+			       "import %s@%s for %s not replayable, auto-deactivating\n",
 			       obd2cli_tgt(imp->imp_obd),
 			       imp->imp_connection->c_remote_uuid.uuid,
 			       imp->imp_obd->obd_name);
diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index 1cf0e9b..a0d6732 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -427,7 +427,8 @@ int sptlrpc_req_ctx_switch(struct ptlrpc_request *req,
 	LASSERT(req->rq_reqlen);
 	LASSERT(req->rq_replen);
 
-	CDEBUG(D_SEC, "req %p: switch ctx %p(%u->%s) -> %p(%u->%s), switch sec %p(%s) -> %p(%s)\n",
+	CDEBUG(D_SEC,
+	       "req %p: switch ctx %p(%u->%s) -> %p(%u->%s), switch sec %p(%s) -> %p(%s)\n",
 	       req,
 	       oldctx, oldctx->cc_vcred.vc_uid, sec2target_str(oldctx->cc_sec),
 	       newctx, newctx->cc_vcred.vc_uid, sec2target_str(newctx->cc_sec),
@@ -515,7 +516,8 @@ static int sptlrpc_req_replace_dead_ctx(struct ptlrpc_request *req)
 		       newctx, newctx->cc_flags);
 
 		schedule_timeout_interruptible(HZ);
-	} else if (unlikely(!test_bit(PTLRPC_CTX_UPTODATE_BIT, &newctx->cc_flags))) {
+	} else if (unlikely(!test_bit(PTLRPC_CTX_UPTODATE_BIT,
+				      &newctx->cc_flags))) {
 		/*
 		 * new ctx not up to date yet
 		 */
@@ -1819,7 +1821,8 @@ int sptlrpc_target_export_check(struct obd_export *exp,
 							req->rq_svc_ctx,
 							&flavor);
 		} else {
-			CDEBUG(D_SEC, "exp %p (%x|%x|%x): is current flavor, install rvs ctx\n",
+			CDEBUG(D_SEC,
+			       "exp %p (%x|%x|%x): is current flavor, install rvs ctx\n",
 			       exp, exp->exp_flvr.sf_rpc,
 			       exp->exp_flvr_old[0].sf_rpc,
 			       exp->exp_flvr_old[1].sf_rpc);
@@ -1833,8 +1836,9 @@ int sptlrpc_target_export_check(struct obd_export *exp,
 	if (exp->exp_flvr_expire[0]) {
 		if (exp->exp_flvr_expire[0] >= ktime_get_real_seconds()) {
 			if (flavor_allowed(&exp->exp_flvr_old[0], req)) {
-				CDEBUG(D_SEC, "exp %p (%x|%x|%x): match the middle one (%lld)\n", exp,
-				       exp->exp_flvr.sf_rpc,
+				CDEBUG(D_SEC,
+				       "exp %p (%x|%x|%x): match the middle one (%lld)\n",
+				       exp, exp->exp_flvr.sf_rpc,
 				       exp->exp_flvr_old[0].sf_rpc,
 				       exp->exp_flvr_old[1].sf_rpc,
 				       (s64)(exp->exp_flvr_expire[0] -
@@ -1846,8 +1850,8 @@ int sptlrpc_target_export_check(struct obd_export *exp,
 			CDEBUG(D_SEC, "mark middle expired\n");
 			exp->exp_flvr_expire[0] = 0;
 		}
-		CDEBUG(D_SEC, "exp %p (%x|%x|%x): %x not match middle\n", exp,
-		       exp->exp_flvr.sf_rpc,
+		CDEBUG(D_SEC, "exp %p (%x|%x|%x): %x not match middle\n",
+		       exp, exp->exp_flvr.sf_rpc,
 		       exp->exp_flvr_old[0].sf_rpc, exp->exp_flvr_old[1].sf_rpc,
 		       req->rq_flvr.sf_rpc);
 	}
@@ -1858,7 +1862,8 @@ int sptlrpc_target_export_check(struct obd_export *exp,
 	if (exp->exp_flvr_changed == 0 && exp->exp_flvr_expire[1]) {
 		if (exp->exp_flvr_expire[1] >= ktime_get_real_seconds()) {
 			if (flavor_allowed(&exp->exp_flvr_old[1], req)) {
-				CDEBUG(D_SEC, "exp %p (%x|%x|%x): match the oldest one (%lld)\n",
+				CDEBUG(D_SEC,
+				       "exp %p (%x|%x|%x): match the oldest one (%lld)\n",
 				       exp,
 				       exp->exp_flvr.sf_rpc,
 				       exp->exp_flvr_old[0].sf_rpc,
diff --git a/fs/lustre/ptlrpc/sec_config.c b/fs/lustre/ptlrpc/sec_config.c
index 35ebd56..d3c949d 100644
--- a/fs/lustre/ptlrpc/sec_config.c
+++ b/fs/lustre/ptlrpc/sec_config.c
@@ -416,11 +416,16 @@ struct sptlrpc_conf_tgt {
 struct sptlrpc_conf {
 	struct list_head		sc_list;
 	char				sc_fsname[MTI_NAME_MAXLEN];
-	unsigned int			sc_modified;	/* modified during updating */
-	unsigned int			sc_updated:1,	/* updated copy from MGS */
-					sc_local:1;	/* local copy from target */
-	struct sptlrpc_rule_set		sc_rset;	/* fs general rules */
-	struct list_head		sc_tgts;	/* target-specific rules */
+	/* modified during updating */
+	unsigned int			sc_modified;
+	unsigned int			sc_updated:1, /* updated copy from
+						       * MGS
+						       */
+					sc_local:1; /* local copy from target */
+	/* fs general rules */
+	struct sptlrpc_rule_set		sc_rset;
+	/* target-specific rules */
+	struct list_head		sc_tgts;
 };
 
 static struct mutex sptlrpc_conf_lock;
diff --git a/fs/lustre/ptlrpc/sec_lproc.c b/fs/lustre/ptlrpc/sec_lproc.c
index 2bb75eb..df7c667 100644
--- a/fs/lustre/ptlrpc/sec_lproc.c
+++ b/fs/lustre/ptlrpc/sec_lproc.c
@@ -160,7 +160,8 @@ int sptlrpc_lprocfs_cliobd_attach(struct obd_device *dev)
 
 void sptlrpc_lproc_init(void)
 {
-	sptlrpc_debugfs_dir = debugfs_create_dir("sptlrpc", debugfs_lustre_root);
+	sptlrpc_debugfs_dir = debugfs_create_dir("sptlrpc",
+						 debugfs_lustre_root);
 	ldebugfs_add_vars(sptlrpc_debugfs_dir, sptlrpc_lprocfs_vars, NULL);
 }
 
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 5a7e9fa..a40e964 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -445,7 +445,8 @@ static void ptlrpc_at_timer(struct timer_list *t)
 	svc->srv_nthrs_cpt_init = init;
 
 	if (nthrs * svc->srv_ncpts > tc->tc_nthrs_max) {
-		CDEBUG(D_OTHER, "%s: This service may have more threads (%d) than the given soft limit (%d)\n",
+		CDEBUG(D_OTHER,
+		       "%s: This service may have more threads (%d) than the given soft limit (%d)\n",
 		       svc->srv_name, nthrs * svc->srv_ncpts,
 		       tc->tc_nthrs_max);
 	}
@@ -1042,7 +1043,8 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 		return 0;
 
 	if (olddl < 0) {
-		DEBUG_REQ(D_WARNING, req, "Already past deadline (%+lds), not sending early reply. Consider increasing at_early_margin (%d)?",
+		DEBUG_REQ(D_WARNING, req,
+			  "Already past deadline (%+lds), not sending early reply. Consider increasing at_early_margin (%d)?",
 			  olddl, at_early_margin);
 
 		/* Return an error so we're not re-added to the timed list. */
@@ -1050,7 +1052,8 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	}
 
 	if (!(lustre_msghdr_get_flags(req->rq_reqmsg) & MSGHDR_AT_SUPPORT)) {
-		DEBUG_REQ(D_INFO, req, "Wanted to ask client for more time, but no AT support");
+		DEBUG_REQ(D_INFO, req,
+			  "Wanted to ask client for more time, but no AT support");
 		return -ENOSYS;
 	}
 
@@ -1098,7 +1101,8 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	LASSERT(atomic_read(&req->rq_refcount));
 	/** if it is last refcount then early reply isn't needed */
 	if (atomic_read(&req->rq_refcount) == 1) {
-		DEBUG_REQ(D_ADAPTTO, reqcopy, "Normal reply already sent out, abort sending early reply\n");
+		DEBUG_REQ(D_ADAPTTO, reqcopy,
+			  "Normal reply already sent out, abort sending early reply\n");
 		rc = -EINVAL;
 		goto out;
 	}
@@ -1223,7 +1227,8 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 
 	spin_unlock(&svcpt->scp_at_lock);
 
-	CDEBUG(D_ADAPTTO, "timeout in %+ds, asking for %d secs on %d early replies\n",
+	CDEBUG(D_ADAPTTO,
+	       "timeout in %+ds, asking for %d secs on %d early replies\n",
 	       first, at_extra, counter);
 	if (first < 0) {
 		/* We're already past request deadlines before we even get a
@@ -1566,7 +1571,8 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 		if (rc == 0) {
 			rc = sptlrpc_target_export_check(req->rq_export, req);
 			if (rc)
-				DEBUG_REQ(D_ERROR, req, "DROPPING req with illegal security flavor,");
+				DEBUG_REQ(D_ERROR, req,
+					  "DROPPING req with illegal security flavor,");
 		}
 
 		if (rc)
@@ -1684,7 +1690,8 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 	 * The deadline is increased if we send an early reply.
 	 */
 	if (ktime_get_real_seconds() > request->rq_deadline) {
-		DEBUG_REQ(D_ERROR, request, "Dropping timed-out request from %s: deadline %lld:%llds ago\n",
+		DEBUG_REQ(D_ERROR, request,
+			  "Dropping timed-out request from %s: deadline %lld:%llds ago\n",
 			  libcfs_id2str(request->rq_peer),
 			  request->rq_deadline -
 			  request->rq_arrival_time.tv_sec,
@@ -1692,7 +1699,8 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 		goto put_conn;
 	}
 
-	CDEBUG(D_RPCTRACE, "Handling RPC pname:cluuid+ref:pid:xid:nid:opc %s:%s+%d:%d:x%llu:%s:%d\n",
+	CDEBUG(D_RPCTRACE,
+	       "Handling RPC pname:cluuid+ref:pid:xid:nid:opc %s:%s+%d:%d:x%llu:%s:%d\n",
 	       current->comm,
 	       (request->rq_export ?
 		(char *)request->rq_export->exp_client_uuid.uuid : "0"),
@@ -1722,8 +1730,7 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 put_conn:
 	if (unlikely(ktime_get_real_seconds() > request->rq_deadline)) {
 		DEBUG_REQ(D_WARNING, request,
-			  "Request took longer than estimated (%lld:%llds); "
-			  "client may timeout.",
+			  "Request took longer than estimated (%lld:%llds); client may timeout.",
 			  (s64)request->rq_deadline -
 			       request->rq_arrival_time.tv_sec,
 			  (s64)ktime_get_real_seconds() - request->rq_deadline);
@@ -1736,7 +1743,8 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 	arrived = timespec64_sub(work_end, request->rq_arrival_time);
 	arrived_usecs = arrived.tv_sec * USEC_PER_SEC +
 			 arrived.tv_nsec / NSEC_PER_USEC;
-	CDEBUG(D_RPCTRACE, "Handled RPC pname:cluuid+ref:pid:xid:nid:opc %s:%s+%d:%d:x%llu:%s:%d Request processed in %ldus (%ldus total) trans %llu rc %d/%d\n",
+	CDEBUG(D_RPCTRACE,
+	       "Handled RPC pname:cluuid+ref:pid:xid:nid:opc %s:%s+%d:%d:x%llu:%s:%d Request processed in %ldus (%ldus total) trans %llu rc %d/%d\n",
 	       current->comm,
 	       (request->rq_export ?
 		(char *)request->rq_export->exp_client_uuid.uuid : "0"),
@@ -1841,9 +1849,9 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 		/* If we see this, we should already have seen the warning
 		 * in mds_steal_ack_locks()
 		 */
-		CDEBUG(D_HA, "All locks stolen from rs %p x%lld.t%lld o%d NID %s\n",
-		       rs,
-		       rs->rs_xid, rs->rs_transno, rs->rs_opc,
+		CDEBUG(D_HA,
+		       "All locks stolen from rs %p x%lld.t%lld o%d NID %s\n",
+		       rs, rs->rs_xid, rs->rs_transno, rs->rs_opc,
 		       libcfs_nid2str(exp->exp_connection->c_peer.nid));
 	}
 
@@ -1995,7 +2003,7 @@ static __attribute__((__noinline__)) int
 						      false) ||
 			ptlrpc_rqbd_pending(svcpt) ||
 			ptlrpc_at_check(svcpt));
-	else if (0 == wait_event_idle_exclusive_lifo_timeout(
+	else if (wait_event_idle_exclusive_lifo_timeout(
 			 svcpt->scp_waitq,
 			 ptlrpc_thread_stopping(thread) ||
 			 ptlrpc_server_request_incoming(svcpt) ||
@@ -2003,7 +2011,7 @@ static __attribute__((__noinline__)) int
 						       false) ||
 			 ptlrpc_rqbd_pending(svcpt) ||
 			 ptlrpc_at_check(svcpt),
-			 svcpt->scp_rqbd_timeout))
+			 svcpt->scp_rqbd_timeout) == 0)
 		svcpt->scp_rqbd_timeout = 0;
 
 	if (ptlrpc_thread_stopping(thread))
-- 
1.8.3.1
