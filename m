From: snnw at gruttepier.net <snnw@gruttepier.net>
Date: Mon, 19 Oct 2015 13:56:51 +0200
Subject: [lustre-devel] [PATCH V3] staging: lustre: kernel style neating
	(block comments)
In-Reply-To: <20151012234606.GA16427@kroah.com>
References: <20151012234606.GA16427@kroah.com>
Message-ID: <1445255811-8275-1-git-send-email-snnw@gruttepier.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sanne Wouda <snnw@gruttepier.net>

Fix lustre/ptlrpc/client.c block comments following the Coding Style
preferred format for multi-line and single-line comments:

        /*
         * This is the preferred style for multi-line
         * comments in the Linux kernel source code.
         * Please use it consistently.
         *
         * Description:  A column of asterisks on the left side,
         * with beginning and ending almost-blank lines.
         */

Included some minor textual fixes to get some comments on a single line.

Signed-off-by: Sanne Wouda <snnw@gruttepier.net>
---

Greg:
> This doesn't apply to my tree anymore, can you please redo it against
> the staging-testing branch of my staging.git tree on git.kernel.org and
> resend it?

Applies cleanly to c3af8a28f43
"staging: IB/hfi1: use TASK_COMM_LEN in hfi1_ctxtdata"

Comments by Andreas have been addressed.

 drivers/staging/lustre/lustre/ptlrpc/client.c | 322 +++++++++++++++-----------
 1 file changed, 182 insertions(+), 140 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 9bf13d7..083f99c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -72,9 +72,11 @@ struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid)
 	lnet_process_id_t peer;
 	int err;
 
-	/* ptlrpc_uuid_to_peer() initializes its 2nd parameter
-	 * before accessing its values. */
-	/* coverity[uninit_use_in_call] */
+	/*
+	 * ptlrpc_uuid_to_peer() initializes its 2nd parameter
+	 * before accessing its values.
+	 * coverity[uninit_use_in_call]
+	 */
 	err = ptlrpc_uuid_to_peer(uuid, &peer, &self);
 	if (err != 0) {
 		CNETERR("cannot find peer %s!\n", uuid->uuid);
@@ -117,8 +119,10 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned npages, unsigned max_brw,
 	desc->bd_md_count = 0;
 	LASSERT(max_brw > 0);
 	desc->bd_md_max_brw = min(max_brw, PTLRPC_BULK_OPS_COUNT);
-	/* PTLRPC_BULK_OPS_COUNT is the compile-time transfer limit for this
-	 * node. Negotiated ocd_brw_size will always be <= this number. */
+	/*
+	 * PTLRPC_BULK_OPS_COUNT is the compile-time transfer limit for this
+	 * node. Negotiated ocd_brw_size will always be <= this number.
+	 */
 	for (i = 0; i < PTLRPC_BULK_OPS_COUNT; i++)
 		LNetInvalidateHandle(&desc->bd_mds[i]);
 
@@ -223,8 +227,9 @@ void ptlrpc_at_set_req_timeout(struct ptlrpc_request *req)
 	LASSERT(req->rq_import);
 
 	if (AT_OFF) {
-		/* non-AT settings */
-		/**
+		/*
+		 * non-AT settings
+		 *
 		 * \a imp_server_timeout means this is reverse import and
 		 * we send (currently only) ASTs to the client and cannot afford
 		 * to wait too long for the reply, otherwise the other client
@@ -240,11 +245,15 @@ void ptlrpc_at_set_req_timeout(struct ptlrpc_request *req)
 		serv_est = at_get(&at->iat_service_estimate[idx]);
 		req->rq_timeout = at_est2timeout(serv_est);
 	}
-	/* We could get even fancier here, using history to predict increased
-	   loading... */
+	/*
+	 * We could get even fancier here, using history to predict increased
+	 * loading...
+	 */
 
-	/* Let the server know what this RPC timeout is by putting it in the
-	   reqmsg*/
+	/*
+	 * Let the server know what this RPC timeout is by putting it in the
+	 * reqmsg
+	 */
 	lustre_msg_set_timeout(req->rq_reqmsg, req->rq_timeout);
 }
 EXPORT_SYMBOL(ptlrpc_at_set_req_timeout);
@@ -261,8 +270,10 @@ static void ptlrpc_at_adj_service(struct ptlrpc_request *req,
 	at = &req->rq_import->imp_at;
 
 	idx = import_at_get_index(req->rq_import, req->rq_request_portal);
-	/* max service estimates are tracked on the server side,
-	   so just keep minimal history here */
+	/*
+	 * max service estimates are tracked on the server side,
+	 * so just keep minimal history here
+	 */
 	oldse = at_measured(&at->iat_service_estimate[idx], serv_est);
 	if (oldse != 0)
 		CDEBUG(D_ADAPTTO, "The RPC service estimate for %s ptl %d has changed from %d to %d\n",
@@ -287,7 +298,8 @@ static void ptlrpc_at_adj_net_latency(struct ptlrpc_request *req,
 	LASSERT(req->rq_import);
 
 	if (service_time > now - req->rq_sent + 3) {
-		/* bz16408, however, this can also happen if early reply
+		/*
+		 * bz16408, however, this can also happen if early reply
 		 * is lost and client RPC is expired and resent, early reply
 		 * or reply of original RPC can still be fit in reply buffer
 		 * of resent RPC, now client is measuring time from the
@@ -376,8 +388,10 @@ static int ptlrpc_at_recv_early_reply(struct ptlrpc_request *req)
 
 	spin_lock(&req->rq_lock);
 	olddl = req->rq_deadline;
-	/* server assumes it now has rq_timeout from when it sent the
-	 * early reply, so client should give it at least that long. */
+	/*
+	 * server assumes it now has rq_timeout from when it sent the
+	 * early reply, so client should give it at least that long.
+	 */
 	req->rq_deadline = ktime_get_real_seconds() + req->rq_timeout +
 			   ptlrpc_at_get_net_latency(req);
 
@@ -503,8 +517,10 @@ ptlrpc_init_rq_pool(int num_rq, int msgsize,
 	if (!pool)
 		return NULL;
 
-	/* Request next power of two for the allocation, because internally
-	   kernel would do exactly this */
+	/*
+	 * Request next power of two for the allocation, because internally
+	 * kernel would do exactly this
+	 */
 
 	spin_lock_init(&pool->prp_lock);
 	INIT_LIST_HEAD(&pool->prp_req_list);
@@ -531,10 +547,12 @@ ptlrpc_prep_req_from_pool(struct ptlrpc_request_pool *pool)
 
 	spin_lock(&pool->prp_lock);
 
-	/* See if we have anything in a pool, and bail out if nothing,
+	/*
+	 * See if we have anything in a pool, and bail out if nothing,
 	 * in writeout path, where this matters, this is safe to do, because
 	 * nothing is lost in this case, and when some in-flight requests
-	 * complete, this code will be called again. */
+	 * complete, this code will be called again.
+	 */
 	if (unlikely(list_empty(&pool->prp_req_list))) {
 		spin_unlock(&pool->prp_lock);
 		return NULL;
@@ -665,7 +683,8 @@ int ptlrpc_request_pack(struct ptlrpc_request *request,
 	if (rc)
 		return rc;
 
-	/* For some old 1.8 clients (< 1.8.7), they will LASSERT the size of
+	/*
+	 * For some old 1.8 clients (< 1.8.7), they will LASSERT the size of
 	 * ptlrpc_body sent from server equal to local ptlrpc_body size, so we
 	 * have to send old ptlrpc_body to keep interoperability with these
 	 * clients.
@@ -936,8 +955,10 @@ void ptlrpc_set_add_req(struct ptlrpc_request_set *set,
 		lustre_msg_set_jobid(req->rq_reqmsg, NULL);
 
 	if (set->set_producer != NULL)
-		/* If the request set has a producer callback, the RPC must be
-		 * sent straight away */
+		/*
+		 * If the request set has a producer callback, the RPC must be
+		 * sent straight away
+		 */
 		ptlrpc_send_new_req(req);
 }
 EXPORT_SYMBOL(ptlrpc_set_add_req);
@@ -957,9 +978,7 @@ void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
 	LASSERT(test_bit(LIOD_STOP, &pc->pc_flags) == 0);
 
 	spin_lock(&set->set_new_req_lock);
-	/*
-	 * The set takes over the caller's request reference.
-	 */
+	/* The set takes over the caller's request reference.  */
 	req->rq_set = set;
 	req->rq_queued_time = cfs_time_current();
 	list_add_tail(&req->rq_set_chain, &set->set_new_requests);
@@ -970,9 +989,11 @@ void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
 	if (count == 1) {
 		wake_up(&set->set_waitq);
 
-		/* XXX: It maybe unnecessary to wakeup all the partners. But to
+		/*
+		 * XXX: It maybe unnecessary to wakeup all the partners. But to
 		 *      guarantee the async RPC can be processed ASAP, we have
-		 *      no other better choice. It maybe fixed in future. */
+		 *      no other better choice. It maybe fixed in future.
+		 */
 		for (i = 0; i < pc->pc_npartners; i++)
 			wake_up(&pc->pc_partners[i]->pc_set->set_waitq);
 	}
@@ -1060,8 +1081,10 @@ static int ptlrpc_console_allow(struct ptlrpc_request *req)
 	LASSERT(req->rq_reqmsg != NULL);
 	opc = lustre_msg_get_opc(req->rq_reqmsg);
 
-	/* Suppress particular reconnect errors which are to be expected.  No
-	 * errors are suppressed for the initial connection on an import */
+	/*
+	 * Suppress particular reconnect errors which are to be expected.  No
+	 * errors are suppressed for the initial connection on an import
+	 */
 	if ((lustre_handle_is_used(&req->rq_import->imp_remote_handle)) &&
 	    (opc == OST_CONNECT || opc == MDS_CONNECT || opc == MGS_CONNECT)) {
 
@@ -1156,10 +1179,11 @@ static int after_reply(struct ptlrpc_request *req)
 		}
 
 		sptlrpc_cli_free_repbuf(req);
-		/* Pass the required reply buffer size (include
-		 * space for early reply).
-		 * NB: no need to roundup because alloc_repbuf
-		 * will roundup it */
+		/*
+		 * Pass the required reply buffer size (include space for early
+		 * reply).  NB: no need to round up because alloc_repbuf will
+		 * round it up
+		 */
 		req->rq_replen       = req->rq_nob_received;
 		req->rq_nob_received = 0;
 		spin_lock(&req->rq_lock);
@@ -1178,9 +1202,7 @@ static int after_reply(struct ptlrpc_request *req)
 		return rc;
 	}
 
-	/*
-	 * Security layer unwrap might ask resend this request.
-	 */
+	/* Security layer unwrap might ask resend this request. */
 	if (req->rq_resend)
 		return 0;
 
@@ -1201,18 +1223,19 @@ static int after_reply(struct ptlrpc_request *req)
 
 		/* allocate new xid to avoid reply reconstruction */
 		if (!req->rq_bulk) {
-			/* new xid is already allocated for bulk in
-			 * ptlrpc_check_set() */
+			/* new xid is already allocated for bulk in ptlrpc_check_set() */
 			req->rq_xid = ptlrpc_next_xid();
 			DEBUG_REQ(D_RPCTRACE, req, "Allocating new xid for resend on EINPROGRESS");
 		}
 
 		/* Readjust the timeout for current conditions */
 		ptlrpc_at_set_req_timeout(req);
-		/* delay resend to give a chance to the server to get ready.
+		/*
+		 * delay resend to give a chance to the server to get ready.
 		 * The delay is increased by 1s on every resend and is capped to
 		 * the current request timeout (i.e. obd_timeout if AT is off,
-		 * or AT service time x 125% + 5s, see at_est2timeout) */
+		 * or AT service time x 125% + 5s, see at_est2timeout)
+		 */
 		if (req->rq_nr_resend > req->rq_timeout)
 			req->rq_sent = now + req->rq_timeout;
 		else
@@ -1268,9 +1291,7 @@ static int after_reply(struct ptlrpc_request *req)
 		ldlm_cli_update_pool(req);
 	}
 
-	/*
-	 * Store transno in reqmsg for replay.
-	 */
+	/* Store transno in reqmsg for replay. */
 	if (!(lustre_msg_get_flags(req->rq_reqmsg) & MSG_REPLAY)) {
 		req->rq_transno = lustre_msg_get_transno(req->rq_repmsg);
 		lustre_msg_set_transno(req->rq_reqmsg, req->rq_transno);
@@ -1286,22 +1307,22 @@ static int after_reply(struct ptlrpc_request *req)
 		    (req->rq_transno >
 		     lustre_msg_get_last_committed(req->rq_repmsg) ||
 		     req->rq_replay)) {
-			/** version recovery */
+			/* version recovery */
 			ptlrpc_save_versions(req);
 			ptlrpc_retain_replayable_request(req, imp);
 		} else if (req->rq_commit_cb != NULL &&
 			   list_empty(&req->rq_replay_list)) {
-			/* NB: don't call rq_commit_cb if it's already on
+			/*
+			 * NB: don't call rq_commit_cb if it's already on
 			 * rq_replay_list, ptlrpc_free_committed() will call
-			 * it later, see LU-3618 for details */
+			 * it later, see LU-3618 for details
+			 */
 			spin_unlock(&imp->imp_lock);
 			req->rq_commit_cb(req);
 			spin_lock(&imp->imp_lock);
 		}
 
-		/*
-		 * Replay-enabled imports return commit-status information.
-		 */
+		/* Replay-enabled imports return commit-status information. */
 		if (lustre_msg_get_last_committed(req->rq_repmsg)) {
 			imp->imp_peer_committed_transno =
 				lustre_msg_get_last_committed(req->rq_repmsg);
@@ -1420,8 +1441,10 @@ static inline int ptlrpc_set_producer(struct ptlrpc_request_set *set)
 
 	remaining = atomic_read(&set->set_remaining);
 
-	/* populate the ->set_requests list with requests until we
-	 * reach the maximum number of RPCs in flight for this set */
+	/*
+	 * populate the ->set_requests list with requests until we
+	 * reach the maximum number of RPCs in flight for this set
+	 */
 	while (atomic_read(&set->set_remaining) < set->set_max_inflight) {
 		rc = set->set_producer(set, set->set_producer_arg);
 		if (rc == -ENOENT) {
@@ -1461,7 +1484,8 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 		int unregistered = 0;
 		int rc = 0;
 
-		/* This schedule point is mainly for the ptlrpcd caller of this
+		/*
+		 * This schedule point is mainly for the ptlrpcd caller of this
 		 * function.  Most ptlrpc sets are not long-lived and unbounded
 		 * in length, but at the least the set used by the ptlrpcd is.
 		 * Since the processing time is unbounded, we need to insert an
@@ -1520,8 +1544,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 						     OBD_FAIL_ONCE);
 			}
 
-			/*
-			 * Move to next phase if reply was successfully
+			/* Move to next phase if reply was successfully
 			 * unlinked.
 			 */
 			ptlrpc_rqphase_move(req, req->rq_next_phase);
@@ -1535,15 +1558,11 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 		if (req->rq_phase == RQ_PHASE_INTERPRET)
 			goto interpret;
 
-		/*
-		 * Note that this also will start async reply unlink.
-		 */
+		/* Note that this also will start async reply unlink. */
 		if (req->rq_net_err && !req->rq_timedout) {
 			ptlrpc_expire_one_request(req, 1);
 
-			/*
-			 * Check if we still need to wait for unlink.
-			 */
+			/* Check if we still need to wait for unlink. */
 			if (ptlrpc_client_recv_or_unlink(req) ||
 			    ptlrpc_client_bulk_active(req))
 				continue;
@@ -1568,7 +1587,8 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 			goto interpret;
 		}
 
-		/* ptlrpc_set_wait->l_wait_event sets lwi_allow_intr
+		/*
+		 * ptlrpc_set_wait->l_wait_event sets lwi_allow_intr
 		 * so it sets rq_intr regardless of individual rpc
 		 * timeouts. The synchronous IO waiting path sets
 		 * rq_intr irrespective of whether ptlrpcd
@@ -1595,8 +1615,10 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 				spin_lock(&imp->imp_lock);
 				if (ptlrpc_import_delay_req(imp, req,
 							    &status)) {
-					/* put on delay list - only if we wait
-					 * recovery finished - before send */
+					/*
+					 * put on delay list - only if we wait
+					 * recovery finished - before send
+					 */
 					list_del_init(&req->rq_list);
 					list_add_tail(&req->rq_list,
 							  &imp->
@@ -1632,8 +1654,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 				spin_unlock(&req->rq_lock);
 
 				if (req->rq_timedout || req->rq_resend) {
-					/* This is re-sending anyways,
-					 * let's mark req as resend. */
+					/* This is re-sending anyway, let's mark req as resend. */
 					spin_lock(&req->rq_lock);
 					req->rq_resend = 1;
 					spin_unlock(&req->rq_lock);
@@ -1711,8 +1732,10 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 
 			spin_unlock(&req->rq_lock);
 
-			/* unlink from net because we are going to
-			 * swab in-place of reply buffer */
+			/*
+			 * unlink from net because we are going to
+			 * swab in-place of reply buffer
+			 */
 			unregistered = ptlrpc_unregister_reply(req, 1);
 			if (!unregistered)
 				continue;
@@ -1721,7 +1744,8 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 			if (req->rq_resend)
 				continue;
 
-			/* If there is no bulk associated with this request,
+			/*
+			 * If there is no bulk associated with this request,
 			 * then we're done and should let the interpreter
 			 * process the reply. Similarly if the RPC returned
 			 * an error, and therefore the bulk will never arrive.
@@ -1739,10 +1763,12 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 			continue;
 
 		if (req->rq_bulk->bd_failure) {
-			/* The RPC reply arrived OK, but the bulk screwed
+			/*
+			 * The RPC reply arrived OK, but the bulk screwed
 			 * up!  Dead weird since the server told us the RPC
 			 * was good after getting the REPLY for her GET or
-			 * the ACK for her PUT. */
+			 * the ACK for her PUT.
+			 */
 			DEBUG_REQ(D_ERROR, req, "bulk transfer failed");
 			req->rq_status = -EIO;
 		}
@@ -1752,8 +1778,10 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 interpret:
 		LASSERT(req->rq_phase == RQ_PHASE_INTERPRET);
 
-		/* This moves to "unregistering" phase we need to wait for
-		 * reply unlink. */
+		/*
+		 * This moves to "unregistering" phase we need to wait for
+		 * reply unlink.
+		 */
 		if (!unregistered && !ptlrpc_unregister_reply(req, 1)) {
 			/* start async bulk unlink too */
 			ptlrpc_unregister_bulk(req, 1);
@@ -1763,8 +1791,7 @@ interpret:
 		if (!ptlrpc_unregister_bulk(req, 1))
 			continue;
 
-		/* When calling interpret receiving already should be
-		 * finished. */
+		/* When calling interpret receive should already be finished. */
 		LASSERT(!req->rq_receiving_reply);
 
 		ptlrpc_req_interpret(env, req, req->rq_status);
@@ -1783,10 +1810,12 @@ interpret:
 		       lustre_msg_get_opc(req->rq_reqmsg));
 
 		spin_lock(&imp->imp_lock);
-		/* Request already may be not on sending or delaying list. This
+		/*
+		 * Request already may be not on sending or delaying list. This
 		 * may happen in the case of marking it erroneous for the case
 		 * ptlrpc_import_delay_req(req, status) find it impossible to
-		 * allow sending this rpc and returns *status != 0. */
+		 * allow sending this rpc and returns *status != 0.
+		 */
 		if (!list_empty(&req->rq_list)) {
 			list_del_init(&req->rq_list);
 			atomic_dec(&imp->imp_inflight);
@@ -1801,8 +1830,10 @@ interpret:
 			if (ptlrpc_set_producer(set) > 0)
 				force_timer_recalc = 1;
 
-			/* free the request that has just been completed
-			 * in order not to pollute set->set_requests */
+			/*
+			 * free the request that has just been completed
+			 * in order not to pollute set->set_requests
+			 */
 			list_del_init(&req->rq_set_chain);
 			spin_lock(&req->rq_lock);
 			req->rq_set = NULL;
@@ -1818,8 +1849,10 @@ interpret:
 		}
 	}
 
-	/* move completed request at the head of list so it's easier for
-	 * caller to find them */
+	/*
+	 * move completed request at the head of list so it's easier for
+	 * caller to find them
+	 */
 	list_splice(&comp_reqs, &set->set_requests);
 
 	/* If we hit an error, we want to recover promptly. */
@@ -1869,8 +1902,10 @@ int ptlrpc_expire_one_request(struct ptlrpc_request *req, int async_unlink)
 	if (imp->imp_dlm_fake)
 		return 1;
 
-	/* If this request is for recovery or other primordial tasks,
-	 * then error it out here. */
+	/*
+	 * If this request is for recovery or other primordial tasks,
+	 * then error it out here.
+	 */
 	if (req->rq_ctx_init || req->rq_ctx_fini ||
 	    req->rq_send_state != LUSTRE_IMP_FULL ||
 	    imp->imp_obd->obd_no_recov) {
@@ -1884,8 +1919,10 @@ int ptlrpc_expire_one_request(struct ptlrpc_request *req, int async_unlink)
 		return 1;
 	}
 
-	/* if a request can't be resent we can't wait for an answer after
-	   the timeout */
+	/*
+	 * if a request can't be resent we can't wait for an answer after
+	 * the timeout
+	 */
 	if (ptlrpc_no_resend(req)) {
 		DEBUG_REQ(D_RPCTRACE, req, "TIMEOUT-NORESEND:");
 		rc = 1;
@@ -1909,9 +1946,7 @@ int ptlrpc_expired_set(void *data)
 
 	LASSERT(set != NULL);
 
-	/*
-	 * A timeout expired. See which reqs it applies to...
-	 */
+	/* A timeout expired. See which reqs it applies to...  */
 	list_for_each(tmp, &set->set_requests) {
 		struct ptlrpc_request *req =
 			list_entry(tmp, struct ptlrpc_request,
@@ -1931,8 +1966,10 @@ int ptlrpc_expired_set(void *data)
 		    req->rq_deadline > now) /* not expired */
 			continue;
 
-		/* Deal with this guy. Do it asynchronously to not block
-		 * ptlrpcd thread. */
+		/*
+		 * Deal with this guy. Do it asynchronously to not block
+		 * ptlrpcd thread.
+		 */
 		ptlrpc_expire_one_request(req, 1);
 	}
 
@@ -1996,23 +2033,17 @@ int ptlrpc_set_next_timeout(struct ptlrpc_request_set *set)
 	list_for_each(tmp, &set->set_requests) {
 		req = list_entry(tmp, struct ptlrpc_request, rq_set_chain);
 
-		/*
-		 * Request in-flight?
-		 */
+		/* Request in-flight? */
 		if (!(((req->rq_phase == RQ_PHASE_RPC) && !req->rq_waiting) ||
 		      (req->rq_phase == RQ_PHASE_BULK) ||
 		      (req->rq_phase == RQ_PHASE_NEW)))
 			continue;
 
-		/*
-		 * Already timed out.
-		 */
+		/* Already timed out. */
 		if (req->rq_timedout)
 			continue;
 
-		/*
-		 * Waiting for ctx.
-		 */
+		/* Waiting for ctx. */
 		if (req->rq_wait_ctx)
 			continue;
 
@@ -2061,8 +2092,10 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 	do {
 		timeout = ptlrpc_set_next_timeout(set);
 
-		/* wait until all complete, interrupted, or an in-flight
-		 * req times out */
+		/*
+		 * wait until all complete, interrupted, or an in-flight
+		 * req times out
+		 */
 		CDEBUG(D_RPCTRACE, "set %p going to sleep for %d seconds\n",
 		       set, timeout);
 
@@ -2087,18 +2120,22 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 
 		rc = l_wait_event(set->set_waitq, ptlrpc_check_set(NULL, set), &lwi);
 
-		/* LU-769 - if we ignored the signal because it was already
+		/*
+		 * LU-769 - if we ignored the signal because it was already
 		 * pending when we started, we need to handle it now or we risk
-		 * it being ignored forever */
+		 * it being ignored forever
+		 */
 		if (rc == -ETIMEDOUT && !lwi.lwi_allow_intr &&
 		    cfs_signal_pending()) {
 			sigset_t blocked_sigs =
 					   cfs_block_sigsinv(LUSTRE_FATAL_SIGS);
 
-			/* In fact we only interrupt for the "fatal" signals
+			/*
+			 * In fact we only interrupt for the "fatal" signals
 			 * like SIGINT or SIGKILL. We still ignore less
 			 * important signals since ptlrpc set is not easily
-			 * reentrant from userspace again */
+			 * reentrant from userspace again
+			 */
 			if (cfs_signal_pending())
 				ptlrpc_interrupted_set(set);
 			cfs_restore_sigs(blocked_sigs);
@@ -2106,13 +2143,15 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 
 		LASSERT(rc == 0 || rc == -EINTR || rc == -ETIMEDOUT);
 
-		/* -EINTR => all requests have been flagged rq_intr so next
+		/*
+		 * -EINTR => all requests have been flagged rq_intr so next
 		 * check completes.
 		 * -ETIMEDOUT => someone timed out.  When all reqs have
 		 * timed out, signals are enabled allowing completion with
 		 * EINTR.
 		 * I don't really care if we go once more round the loop in
-		 * the error cases -eeb. */
+		 * the error cases -eeb.
+		 */
 		if (rc == 0 && atomic_read(&set->set_remaining) == 0) {
 			list_for_each(tmp, &set->set_requests) {
 				req = list_entry(tmp, struct ptlrpc_request,
@@ -2178,8 +2217,10 @@ static void __ptlrpc_free_req(struct ptlrpc_request *request, int locked)
 
 	req_capsule_fini(&request->rq_pill);
 
-	/* We must take it off the imp_replay_list first.  Otherwise, we'll set
-	 * request->rq_reqmsg to NULL while osc_close is dereferencing it. */
+	/*
+	 * We must take it off the imp_replay_list first.  Otherwise, we'll set
+	 * request->rq_reqmsg to NULL while osc_close is dereferencing it.
+	 */
 	if (request->rq_import != NULL) {
 		if (!locked)
 			spin_lock(&request->rq_import->imp_lock);
@@ -2280,40 +2321,28 @@ int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 	wait_queue_head_t *wq;
 	struct l_wait_info lwi;
 
-	/*
-	 * Might sleep.
-	 */
+	/* Might sleep. */
 	LASSERT(!in_interrupt());
 
-	/*
-	 * Let's setup deadline for reply unlink.
-	 */
+	/* Let's setup deadline for reply unlink. */
 	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_REPL_UNLINK) &&
 	    async && request->rq_reply_deadline == 0)
 		request->rq_reply_deadline = ktime_get_real_seconds()+LONG_UNLINK;
 
-	/*
-	 * Nothing left to do.
-	 */
+	/* Nothing left to do. */
 	if (!ptlrpc_client_recv_or_unlink(request))
 		return 1;
 
 	LNetMDUnlink(request->rq_reply_md_h);
 
-	/*
-	 * Let's check it once again.
-	 */
+	/* Let's check it once again. */
 	if (!ptlrpc_client_recv_or_unlink(request))
 		return 1;
 
-	/*
-	 * Move to "Unregistering" phase as reply was not unlinked yet.
-	 */
+	/* Move to "Unregistering" phase as reply was not unlinked yet. */
 	ptlrpc_rqphase_move(request, RQ_PHASE_UNREGISTERING);
 
-	/*
-	 * Do not wait for unlink to finish.
-	 */
+	/* Do not wait for unlink to finish. */
 	if (async)
 		return 0;
 
@@ -2328,8 +2357,10 @@ int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 		wq = &request->rq_reply_waitq;
 
 	for (;;) {
-		/* Network access will complete in finite time but the HUGE
-		 * timeout lets us CWARN for visibility of sluggish NALs */
+		/*
+		 * Network access will complete in finite time but the HUGE
+		 * timeout lets us CWARN for visibility of sluggish NALs
+		 */
 		lwi = LWI_TIMEOUT_INTERVAL(cfs_time_seconds(LONG_UNLINK),
 					   cfs_time_seconds(1), NULL, NULL);
 		rc = l_wait_event(*wq, !ptlrpc_client_recv_or_unlink(request),
@@ -2472,8 +2503,10 @@ void ptlrpc_resend_req(struct ptlrpc_request *req)
 	DEBUG_REQ(D_HA, req, "going to resend");
 	spin_lock(&req->rq_lock);
 
-	/* Request got reply but linked to the import list still.
-	   Let ptlrpc_check_set() to process it. */
+	/*
+	 * Request got reply but linked to the import list still.
+	 * Let ptlrpc_check_set() to process it.
+	 */
 	if (ptlrpc_client_replied(req)) {
 		spin_unlock(&req->rq_lock);
 		DEBUG_REQ(D_HA, req, "it has reply, so skip it");
@@ -2525,8 +2558,10 @@ void ptlrpc_retain_replayable_request(struct ptlrpc_request *req,
 		LBUG();
 	}
 
-	/* clear this for new requests that were resent as well
-	   as resent replayed requests. */
+	/*
+	 * clear this for new requests that were resent as well
+	 * as resent replayed requests.
+	 */
 	lustre_msg_clear_flags(req->rq_reqmsg, MSG_RESENT);
 
 	/* don't re-add requests that have been replayed */
@@ -2543,7 +2578,8 @@ void ptlrpc_retain_replayable_request(struct ptlrpc_request *req,
 			list_entry(tmp, struct ptlrpc_request,
 				       rq_replay_list);
 
-		/* We may have duplicate transnos if we create and then
+		/*
+		 * We may have duplicate transnos if we create and then
 		 * open a file, or for closes retained if to match creating
 		 * opens, so use req->rq_xid as a secondary key.
 		 * (See bugs 684, 685, and 428.)
@@ -2728,8 +2764,10 @@ int ptlrpc_replay_req(struct ptlrpc_request *req)
 	/* Readjust the timeout for current conditions */
 	ptlrpc_at_set_req_timeout(req);
 
-	/* Tell server the net_latency, so the server can calculate how long
-	 * it should wait for next replay */
+	/*
+	 * Tell server the net_latency, so the server can calculate how long
+	 * it should wait for next replay
+	 */
 	lustre_msg_set_service_time(req->rq_reqmsg,
 				    ptlrpc_at_get_net_latency(req));
 	DEBUG_REQ(D_HA, req, "REPLAY");
@@ -2749,13 +2787,15 @@ void ptlrpc_abort_inflight(struct obd_import *imp)
 {
 	struct list_head *tmp, *n;
 
-	/* Make sure that no new requests get processed for this import.
+	/*
+	 * Make sure that no new requests get processed for this import.
 	 * ptlrpc_{queue,set}_wait must (and does) hold imp_lock while testing
 	 * this flag and then putting requests on sending_list or delayed_list.
 	 */
 	spin_lock(&imp->imp_lock);
 
-	/* XXX locking?  Maybe we should remove each request with the list
+	/*
+	 * XXX locking?  Maybe we should remove each request with the list
 	 * locked?  Also, how do we know if the requests on the list are
 	 * being freed at this time?
 	 */
@@ -2789,8 +2829,10 @@ void ptlrpc_abort_inflight(struct obd_import *imp)
 		spin_unlock(&req->rq_lock);
 	}
 
-	/* Last chance to free reqs left on the replay list, but we
-	 * will still leak reqs that haven't committed.  */
+	/*
+	 * Last chance to free reqs left on the replay list, but we
+	 * will still leak reqs that haven't committed.
+	 */
 	if (imp->imp_replayable)
 		ptlrpc_free_committed(imp);
 
-- 
2.4.3
