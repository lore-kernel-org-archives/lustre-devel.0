From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:33 -0500
Subject: [lustre-devel] [PATCH 55/56] staging/lustre/ptlrpc: Adjust comments
	to better conform to coding style
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-56-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This patch fixes "Block comments use a trailing */ on a separate line"
warnings from checkpatch

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ptlrpc/connection.c  |   3 +-
 drivers/staging/lustre/lustre/ptlrpc/events.c      |  51 ++++++---
 drivers/staging/lustre/lustre/ptlrpc/import.c      | 114 ++++++++++++--------
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |   8 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |   9 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  42 +++++---
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |   6 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |  33 ++++--
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |  11 +-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |   2 -
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |   9 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |  18 ++--
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |  27 +++--
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |   6 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c    |   3 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |   6 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     | 117 ++++++++++++++-------
 17 files changed, 301 insertions(+), 164 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/connection.c b/drivers/staging/lustre/lustre/ptlrpc/connection.c
index 062db13..a14daff 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/connection.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/connection.c
@@ -72,7 +72,8 @@ ptlrpc_connection_get(lnet_process_id_t peer, lnet_nid_t self,
 	 * returned and may be compared against out object.
 	 */
 	/* In the function below, .hs_keycmp resolves to
-	 * conn_keycmp() */
+	 * conn_keycmp()
+	 */
 	/* coverity[overrun-buffer-val] */
 	conn2 = cfs_hash_findadd_unique(conn_hash, &peer, &conn->c_hash);
 	if (conn != conn2) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index ffceba5..47be21a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -71,7 +71,8 @@ void request_out_callback(lnet_event_t *ev)
 	if (ev->type == LNET_EVENT_UNLINK || ev->status != 0) {
 
 		/* Failed send: make it seem like the reply timed out, just
-		 * like failing sends in client.c does currently...  */
+		 * like failing sends in client.c does currently...
+		 */
 
 		req->rq_net_err = 1;
 		ptlrpc_client_wake_req(req);
@@ -95,7 +96,8 @@ void reply_in_callback(lnet_event_t *ev)
 	LASSERT(ev->md.start == req->rq_repbuf);
 	LASSERT(ev->offset + ev->mlength <= req->rq_repbuf_len);
 	/* We've set LNET_MD_MANAGE_REMOTE for all outgoing requests
-	   for adaptive timeouts' early reply. */
+	 * for adaptive timeouts' early reply.
+	 */
 	LASSERT((ev->md.options & LNET_MD_MANAGE_REMOTE) != 0);
 
 	spin_lock(&req->rq_lock);
@@ -151,7 +153,8 @@ void reply_in_callback(lnet_event_t *ev)
 		req->rq_reply_off = ev->offset;
 		req->rq_nob_received = ev->mlength;
 		/* LNetMDUnlink can't be called under the LNET_LOCK,
-		   so we must unlink in ptlrpc_unregister_reply */
+		 * so we must unlink in ptlrpc_unregister_reply
+		 */
 		DEBUG_REQ(D_INFO, req,
 			  "reply in flags=%x mlen=%u offset=%d replen=%d",
 			  lustre_msg_get_flags(req->rq_reqmsg),
@@ -162,7 +165,8 @@ void reply_in_callback(lnet_event_t *ev)
 
 out_wake:
 	/* NB don't unlock till after wakeup; req can disappear under us
-	 * since we don't have our own ref */
+	 * since we don't have our own ref
+	 */
 	ptlrpc_client_wake_req(req);
 	spin_unlock(&req->rq_lock);
 }
@@ -213,7 +217,8 @@ void client_bulk_callback(lnet_event_t *ev)
 		desc->bd_failure = 1;
 
 	/* NB don't unlock till after wakeup; desc can disappear under us
-	 * otherwise */
+	 * otherwise
+	 */
 	if (desc->bd_md_count == 0)
 		ptlrpc_client_wake_req(desc->bd_req);
 
@@ -250,7 +255,8 @@ static void ptlrpc_req_add_history(struct ptlrpc_service_part *svcpt,
 	__u64 new_seq;
 
 	/* set sequence ID for request and add it to history list,
-	 * it must be called with hold svcpt::scp_lock */
+	 * it must be called with hold svcpt::scp_lock
+	 */
 
 	new_seq = (sec << REQS_SEC_SHIFT) |
 		  (usec << REQS_USEC_SHIFT) |
@@ -258,7 +264,8 @@ static void ptlrpc_req_add_history(struct ptlrpc_service_part *svcpt,
 
 	if (new_seq > svcpt->scp_hist_seq) {
 		/* This handles the initial case of scp_hist_seq == 0 or
-		 * we just jumped into a new time window */
+		 * we just jumped into a new time window
+		 */
 		svcpt->scp_hist_seq = new_seq;
 	} else {
 		LASSERT(REQS_SEQ_SHIFT(svcpt) < REQS_USEC_SHIFT);
@@ -266,7 +273,8 @@ static void ptlrpc_req_add_history(struct ptlrpc_service_part *svcpt,
 		 * however, it's possible that we used up all bits for
 		 * sequence and jumped into the next usec bucket (future time),
 		 * then we hope there will be less RPCs per bucket@some
-		 * point, and sequence will catch up again */
+		 * point, and sequence will catch up again
+		 */
 		svcpt->scp_hist_seq += (1U << REQS_SEQ_SHIFT(svcpt));
 		new_seq = svcpt->scp_hist_seq;
 	}
@@ -302,7 +310,8 @@ void request_in_callback(lnet_event_t *ev)
 		 * request buffer we can use the request object embedded in
 		 * rqbd.  Note that if we failed to allocate a request,
 		 * we'd have to re-post the rqbd, which we can't do in this
-		 * context. */
+		 * context.
+		 */
 		req = &rqbd->rqbd_req;
 		memset(req, 0, sizeof(*req));
 	} else {
@@ -322,7 +331,8 @@ void request_in_callback(lnet_event_t *ev)
 
 	/* NB we ABSOLUTELY RELY on req being zeroed, so pointers are NULL,
 	 * flags are reset and scalars are zero.  We only set the message
-	 * size to non-zero if this was a successful receive. */
+	 * size to non-zero if this was a successful receive.
+	 */
 	req->rq_xid = ev->match_bits;
 	req->rq_reqbuf = ev->md.start + ev->offset;
 	if (ev->type == LNET_EVENT_PUT && ev->status == 0)
@@ -352,7 +362,8 @@ void request_in_callback(lnet_event_t *ev)
 		       svcpt->scp_nrqbds_posted);
 
 		/* Normally, don't complain about 0 buffers posted; LNET won't
-		 * drop incoming reqs since we set the portal lazy */
+		 * drop incoming reqs since we set the portal lazy
+		 */
 		if (test_req_buffer_pressure &&
 		    ev->type != LNET_EVENT_UNLINK &&
 		    svcpt->scp_nrqbds_posted == 0)
@@ -369,7 +380,8 @@ void request_in_callback(lnet_event_t *ev)
 	svcpt->scp_nreqs_incoming++;
 
 	/* NB everything can disappear under us once the request
-	 * has been queued and we unlock, so do the wake now... */
+	 * has been queued and we unlock, so do the wake now...
+	 */
 	wake_up(&svcpt->scp_waitq);
 
 	spin_unlock(&svcpt->scp_lock);
@@ -390,7 +402,8 @@ void reply_out_callback(lnet_event_t *ev)
 
 	if (!rs->rs_difficult) {
 		/* 'Easy' replies have no further processing so I drop the
-		 * net's ref on 'rs' */
+		 * net's ref on 'rs'
+		 */
 		LASSERT(ev->unlinked);
 		ptlrpc_rs_decref(rs);
 		return;
@@ -400,7 +413,8 @@ void reply_out_callback(lnet_event_t *ev)
 
 	if (ev->unlinked) {
 		/* Last network callback. The net's ref on 'rs' stays put
-		 * until ptlrpc_handle_rs() is done with it */
+		 * until ptlrpc_handle_rs() is done with it
+		 */
 		spin_lock(&svcpt->scp_rep_lock);
 		spin_lock(&rs->rs_lock);
 
@@ -483,7 +497,8 @@ static void ptlrpc_ni_fini(void)
 	/* Wait for the event queue to become idle since there may still be
 	 * messages in flight with pending events (i.e. the fire-and-forget
 	 * messages == client requests and "non-difficult" server
-	 * replies */
+	 * replies
+	 */
 
 	for (retries = 0;; retries++) {
 		rc = LNetEQFree(ptlrpc_eq_h);
@@ -533,11 +548,13 @@ static int ptlrpc_ni_init(void)
 	}
 
 	/* CAVEAT EMPTOR: how we process portals events is _radically_
-	 * different depending on... */
+	 * different depending on...
+	 */
 	/* kernel LNet calls our master callback when there are new event,
 	 * because we are guaranteed to get every event via callback,
 	 * so we just set EQ size to 0 to avoid overhead of serializing
-	 * enqueue/dequeue operations in LNet. */
+	 * enqueue/dequeue operations in LNet.
+	 */
 	rc = LNetEQAlloc(0, ptlrpc_master_callback, &ptlrpc_eq_h);
 	if (rc == 0)
 		return 0;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index bd0fa3c..70fcac1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -112,7 +112,8 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp);
  * CLOSED. I would rather refcount the import and free it after
  * disconnection like we do with exports. To do that, the client_obd
  * will need to save the peer info somewhere other than in the import,
- * though. */
+ * though.
+ */
 int ptlrpc_init_import(struct obd_import *imp)
 {
 	spin_lock(&imp->imp_lock);
@@ -282,11 +283,13 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 	/* Wait forever until inflight == 0. We really can't do it another
 	 * way because in some cases we need to wait for very long reply
 	 * unlink. We can't do anything before that because there is really
-	 * no guarantee that some rdma transfer is not in progress right now. */
+	 * no guarantee that some rdma transfer is not in progress right now.
+	 */
 	do {
 		/* Calculate max timeout for waiting on rpcs to error
 		 * out. Use obd_timeout if calculated value is smaller
-		 * than it. */
+		 * than it.
+		 */
 		if (!OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_REPL_UNLINK)) {
 			timeout = ptlrpc_inflight_timeout(imp);
 			timeout += timeout / 3;
@@ -304,7 +307,8 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 
 		/* Wait for all requests to error out and call completion
 		 * callbacks. Cap it at obd_timeout -- these should all
-		 * have been locally cancelled by ptlrpc_abort_inflight. */
+		 * have been locally cancelled by ptlrpc_abort_inflight.
+		 */
 		lwi = LWI_TIMEOUT_INTERVAL(
 			cfs_timeout_cap(cfs_time_seconds(timeout)),
 			(timeout > 1)?cfs_time_seconds(1):cfs_time_seconds(1)/2,
@@ -328,13 +332,15 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 				 * maybe waiting for long reply unlink in
 				 * sluggish nets). Let's check this. If there
 				 * is no inflight and unregistering != 0, this
-				 * is bug. */
+				 * is bug.
+				 */
 				LASSERTF(count == 0, "Some RPCs are still unregistering: %d\n",
 					 count);
 
 				/* Let's save one loop as soon as inflight have
 				 * dropped to zero. No new inflights possible at
-				 * this point. */
+				 * this point.
+				 */
 				rc = 0;
 			} else {
 				list_for_each_safe(tmp, n,
@@ -501,7 +507,8 @@ static int import_select_connection(struct obd_import *imp)
 		       conn->oic_last_attempt);
 
 		/* If we have not tried this connection since
-		   the last successful attempt, go with this one */
+		 * the last successful attempt, go with this one
+		 */
 		if ((conn->oic_last_attempt == 0) ||
 		    cfs_time_beforeq_64(conn->oic_last_attempt,
 				       imp->imp_last_success_conn)) {
@@ -511,8 +518,9 @@ static int import_select_connection(struct obd_import *imp)
 		}
 
 		/* If all of the connections have already been tried
-		   since the last successful connection; just choose the
-		   least recently used */
+		 * since the last successful connection; just choose the
+		 * least recently used
+		 */
 		if (!imp_conn)
 			imp_conn = conn;
 		else if (cfs_time_before_64(conn->oic_last_attempt,
@@ -529,10 +537,11 @@ static int import_select_connection(struct obd_import *imp)
 	LASSERT(imp_conn->oic_conn);
 
 	/* If we've tried everything, and we're back to the beginning of the
-	   list, increase our timeout and try again. It will be reset when
-	   we do finally connect. (FIXME: really we should wait for all network
-	   state associated with the last connection attempt to drain before
-	   trying to reconnect on it.) */
+	 * list, increase our timeout and try again. It will be reset when
+	 * we do finally connect. (FIXME: really we should wait for all network
+	 * state associated with the last connection attempt to drain before
+	 * trying to reconnect on it.)
+	 */
 	if (tried_all && (imp->imp_conn_list.next == &imp_conn->oic_item)) {
 		struct adaptive_timeout *at = &imp->imp_at.iat_net_latency;
 
@@ -589,7 +598,8 @@ static int ptlrpc_first_transno(struct obd_import *imp, __u64 *transno)
 	struct list_head *tmp;
 
 	/* The requests in committed_list always have smaller transnos than
-	 * the requests in replay_list */
+	 * the requests in replay_list
+	 */
 	if (!list_empty(&imp->imp_committed_list)) {
 		tmp = imp->imp_committed_list.next;
 		req = list_entry(tmp, struct ptlrpc_request, rq_replay_list);
@@ -673,7 +683,8 @@ int ptlrpc_connect_import(struct obd_import *imp)
 		goto out;
 
 	/* Reset connect flags to the originally requested flags, in case
-	 * the server is updated on-the-fly we will get the new features. */
+	 * the server is updated on-the-fly we will get the new features.
+	 */
 	imp->imp_connect_data.ocd_connect_flags = imp->imp_connect_flags_orig;
 	/* Reset ocd_version each time so the server knows the exact versions */
 	imp->imp_connect_data.ocd_version = LUSTRE_VERSION_CODE;
@@ -699,7 +710,8 @@ int ptlrpc_connect_import(struct obd_import *imp)
 	}
 
 	/* Report the rpc service time to the server so that it knows how long
-	 * to wait for clients to join recovery */
+	 * to wait for clients to join recovery
+	 */
 	lustre_msg_set_service_time(request->rq_reqmsg,
 				    at_timeout2est(request->rq_timeout));
 
@@ -707,7 +719,8 @@ int ptlrpc_connect_import(struct obd_import *imp)
 	 * import_select_connection will increase the net latency on
 	 * repeated reconnect attempts to cover slow networks.
 	 * We override/ignore the server rpc completion estimate here,
-	 * which may be large if this is a reconnect attempt */
+	 * which may be large if this is a reconnect attempt
+	 */
 	request->rq_timeout = INITIAL_CONNECT_TIMEOUT;
 	lustre_msg_set_timeout(request->rq_reqmsg, request->rq_timeout);
 
@@ -798,7 +811,8 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 
 	if (rc) {
 		/* if this reconnect to busy export - not need select new target
-		 * for connecting*/
+		 * for connecting
+		 */
 		imp->imp_force_reconnect = ptlrpc_busy_reconnect(rc);
 		spin_unlock(&imp->imp_lock);
 		ptlrpc_maybe_ping_import_soon(imp);
@@ -850,7 +864,8 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 
 	if (!exp) {
 		/* This could happen if export is cleaned during the
-		   connect attempt */
+		 * connect attempt
+		 */
 		CERROR("%s: missing export after connect\n",
 		       imp->imp_obd->obd_name);
 		rc = -ENODEV;
@@ -876,14 +891,16 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		}
 
 		/* if applies, adjust the imp->imp_msg_magic here
-		 * according to reply flags */
+		 * according to reply flags
+		 */
 
 		imp->imp_remote_handle =
 				*lustre_msg_get_handle(request->rq_repmsg);
 
 		/* Initial connects are allowed for clients with non-random
 		 * uuids when servers are in recovery.  Simply signal the
-		 * servers replay is complete and wait in REPLAY_WAIT. */
+		 * servers replay is complete and wait in REPLAY_WAIT.
+		 */
 		if (msg_flags & MSG_CONNECT_RECOVERING) {
 			CDEBUG(D_HA, "connect to %s during recovery\n",
 			       obd2cli_tgt(imp->imp_obd));
@@ -922,7 +939,8 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 			 * already erased all of our state because of previous
 			 * eviction. If it is in recovery - we are safe to
 			 * participate since we can reestablish all of our state
-			 * with server again */
+			 * with server again
+			 */
 			if ((msg_flags & MSG_CONNECT_RECOVERING)) {
 				CDEBUG(level, "%s@%s changed server handle from %#llx to %#llx but is still in recovery\n",
 				       obd2cli_tgt(imp->imp_obd),
@@ -1038,7 +1056,8 @@ finish:
 		     ocd->ocd_version < LUSTRE_VERSION_CODE -
 					LUSTRE_VERSION_OFFSET_WARN)) {
 			/* Sigh, some compilers do not like #ifdef in the middle
-			   of macro arguments */
+			 * of macro arguments
+			 */
 			const char *older = "older. Consider upgrading server or downgrading client"
 				;
 			const char *newer = "newer than client version. Consider upgrading client"
@@ -1060,7 +1079,8 @@ finish:
 		 * fixup is version-limited, because we don't want to carry the
 		 * OBD_CONNECT_MNE_SWAB flag around forever, just so long as we
 		 * need interop with unpatched 2.2 servers.  For newer servers,
-		 * the client will do MNE swabbing only as needed.  LU-1644 */
+		 * the client will do MNE swabbing only as needed.  LU-1644
+		 */
 		if (unlikely((ocd->ocd_connect_flags & OBD_CONNECT_VERSION) &&
 			     !(ocd->ocd_connect_flags & OBD_CONNECT_MNE_SWAB) &&
 			     OBD_OCD_VERSION_MAJOR(ocd->ocd_version) == 2 &&
@@ -1078,7 +1098,8 @@ finish:
 		if (ocd->ocd_connect_flags & OBD_CONNECT_CKSUM) {
 			/* We sent to the server ocd_cksum_types with bits set
 			 * for algorithms we understand. The server masked off
-			 * the checksum types it doesn't support */
+			 * the checksum types it doesn't support
+			 */
 			if ((ocd->ocd_cksum_types &
 			     cksum_types_supported_client()) == 0) {
 				LCONSOLE_WARN("The negotiation of the checksum algorithm to use with server %s failed (%x/%x), disabling checksums\n",
@@ -1092,7 +1113,8 @@ finish:
 			}
 		} else {
 			/* The server does not support OBD_CONNECT_CKSUM.
-			 * Enforce ADLER for backward compatibility*/
+			 * Enforce ADLER for backward compatibility
+			 */
 			cli->cl_supp_cksum_types = OBD_CKSUM_ADLER;
 		}
 		cli->cl_cksum_type = cksum_type_select(cli->cl_supp_cksum_types);
@@ -1108,7 +1130,8 @@ finish:
 		/* Reset ns_connect_flags only for initial connect. It might be
 		 * changed in while using FS and if we reset it in reconnect
 		 * this leads to losing user settings done before such as
-		 * disable lru_resize, etc. */
+		 * disable lru_resize, etc.
+		 */
 		if (old_connect_flags != exp_connect_flags(exp) ||
 		    aa->pcaa_initial_connect) {
 			CDEBUG(D_HA, "%s: Resetting ns_connect_flags to server flags: %#llx\n",
@@ -1122,13 +1145,14 @@ finish:
 		if ((ocd->ocd_connect_flags & OBD_CONNECT_AT) &&
 		    (imp->imp_msg_magic == LUSTRE_MSG_MAGIC_V2))
 			/* We need a per-message support flag, because
-			   a. we don't know if the incoming connect reply
-			      supports AT or not (in reply_in_callback)
-			      until we unpack it.
-			   b. failovered server means export and flags are gone
-			      (in ptlrpc_send_reply).
-			   Can only be set when we know AT is supported at
-			   both ends */
+			 * a. we don't know if the incoming connect reply
+			 *    supports AT or not (in reply_in_callback)
+			 *    until we unpack it.
+			 * b. failovered server means export and flags are gone
+			 *    (in ptlrpc_send_reply).
+			 * Can only be set when we know AT is supported at
+			 * both ends
+			 */
 			imp->imp_msghdr_flags |= MSGHDR_AT_SUPPORT;
 		else
 			imp->imp_msghdr_flags &= ~MSGHDR_AT_SUPPORT;
@@ -1338,7 +1362,8 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 		/* bug 17802:  XXX client_disconnect_export vs connect request
 		 * race. if client will evicted at this time, we start
 		 * invalidate thread without reference to import and import can
-		 * be freed at same time. */
+		 * be freed at same time.
+		 */
 		class_import_get(imp);
 		task = kthread_run(ptlrpc_invalidate_import_thread, imp,
 				     "ll_imp_inval");
@@ -1470,11 +1495,13 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
 	if (req) {
 		/* We are disconnecting, do not retry a failed DISCONNECT rpc if
 		 * it fails.  We can get through the above with a down server
-		 * if the client doesn't know the server is gone yet. */
+		 * if the client doesn't know the server is gone yet.
+		 */
 		req->rq_no_resend = 1;
 
 		/* We want client umounts to happen quickly, no matter the
-		   server state... */
+		 * server state...
+		 */
 		req->rq_timeout = min_t(int, req->rq_timeout,
 					INITIAL_CONNECT_TIMEOUT);
 
@@ -1506,9 +1533,10 @@ EXPORT_SYMBOL(ptlrpc_disconnect_import);
 extern unsigned int at_min, at_max, at_history;
 
 /* Bin into timeslices using AT_BINS bins.
-   This gives us a max of the last binlimit*AT_BINS secs without the storage,
-   but still smoothing out a return to normalcy from a slow response.
-   (E.g. remember the maximum latency in each minute of the last 4 minutes.) */
+ * This gives us a max of the last binlimit*AT_BINS secs without the storage,
+ * but still smoothing out a return to normalcy from a slow response.
+ * (E.g. remember the maximum latency in each minute of the last 4 minutes.)
+ */
 int at_measured(struct adaptive_timeout *at, unsigned int val)
 {
 	unsigned int old = at->at_current;
@@ -1522,7 +1550,8 @@ int at_measured(struct adaptive_timeout *at, unsigned int val)
 
 	if (val == 0)
 		/* 0's don't count, because we never want our timeout to
-		   drop to 0, and because 0 could mean an error */
+		 * drop to 0, and because 0 could mean an error
+		 */
 		return 0;
 
 	spin_lock(&at->at_lock);
@@ -1564,7 +1593,8 @@ int at_measured(struct adaptive_timeout *at, unsigned int val)
 
 	if (at->at_flags & AT_FLG_NOHIST)
 		/* Only keep last reported val; keeping the rest of the history
-		   for proc only */
+		 * for debugfs only
+		 */
 		at->at_current = val;
 
 	if (at_max > 0)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
index 8ef5e45..a23ac5f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
@@ -75,7 +75,8 @@
 } while (0)
 
 /* This is a callback from the llog_* functions.
- * Assumes caller has already pushed us into the kernel context. */
+ * Assumes caller has already pushed us into the kernel context.
+ */
 static int llog_client_open(const struct lu_env *env,
 			    struct llog_handle *lgh, struct llog_logid *logid,
 			    char *name, enum llog_open_param open_param)
@@ -316,8 +317,9 @@ static int llog_client_close(const struct lu_env *env,
 			     struct llog_handle *handle)
 {
 	/* this doesn't call LLOG_ORIGIN_HANDLE_CLOSE because
-	   the servers all close the file at the end of every
-	   other LLOG_ RPC. */
+	 *  the servers all close the file at the end of every
+	 * other LLOG_ RPC.
+	 */
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 1036400..fcaa289 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -306,7 +306,8 @@ ptlrpc_lprocfs_req_history_max_seq_write(struct file *file,
 
 	/* This sanity check is more of an insanity check; we can still
 	 * hose a kernel by allowing the request history to grow too
-	 * far. */
+	 * far.
+	 */
 	bufpages = (svc->srv_buf_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	if (val > totalram_pages / (2 * bufpages))
 		return -ERANGE;
@@ -737,7 +738,8 @@ ptlrpc_lprocfs_svc_req_history_seek(struct ptlrpc_service_part *svcpt,
 		 * recent), search from it onwards.
 		 * Since the service history is LRU (i.e. culled reqs will
 		 * be near the head), we shouldn't have to do long
-		 * re-scans */
+		 * re-scans
+		 */
 		LASSERTF(srhi->srhi_seq == srhi->srhi_req->rq_history_seq,
 			 "%s:%d: seek seq %llu, request seq %llu\n",
 			 svcpt->scp_service->srv_name, svcpt->scp_cpt,
@@ -915,7 +917,8 @@ static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 		 * here.  The request could contain any old crap, so you
 		 * must be just as careful as the service's request
 		 * parser. Currently I only print stuff here I know is OK
-		 * to look at coz it was set up in request_in_callback()!!! */
+		 * to look at coz it was set up in request_in_callback()!!!
+		 */
 		seq_printf(s, "%lld:%s:%s:x%llu:%d:%s:%lld:%lds(%+lds) ",
 			   req->rq_history_seq, nidstr,
 			   libcfs_id2str(req->rq_peer), req->rq_xid,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 47f53b4..c5bbf7b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -87,7 +87,8 @@ static int ptl_send_buf(lnet_handle_md_t *mdh, void *base, int len,
 		int rc2;
 		/* We're going to get an UNLINK event when I unlink below,
 		 * which will complete just like any other failed send, so
-		 * I fall through and return success here! */
+		 * I fall through and return success here!
+		 */
 		CERROR("LNetPut(%s, %d, %lld) failed: %d\n",
 		       libcfs_id2str(conn->c_peer), portal, xid, rc);
 		rc2 = LNetMDUnlink(*mdh);
@@ -152,7 +153,8 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	 * using the same RDMA match bits after an error.
 	 *
 	 * For multi-bulk RPCs, rq_xid is the last XID needed for bulks. The
-	 * first bulk XID is power-of-two aligned before rq_xid. LU-1431 */
+	 * first bulk XID is power-of-two aligned before rq_xid. LU-1431
+	 */
 	xid = req->rq_xid & ~((__u64)desc->bd_md_max_brw - 1);
 	LASSERTF(!(desc->bd_registered &&
 		   req->rq_send_state != LUSTRE_IMP_REPLAY) ||
@@ -208,7 +210,8 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	}
 
 	/* Set rq_xid to matchbits of the final bulk so that server can
-	 * infer the number of bulks that were prepared */
+	 * infer the number of bulks that were prepared
+	 */
 	req->rq_xid = --xid;
 	LASSERTF(desc->bd_last_xid == (req->rq_xid & PTLRPC_BULK_OPS_MASK),
 		 "bd_last_xid = x%llu, rq_xid = x%llu\n",
@@ -259,7 +262,8 @@ int ptlrpc_unregister_bulk(struct ptlrpc_request *req, int async)
 	/* the unlink ensures the callback happens ASAP and is the last
 	 * one.  If it fails, it must be because completion just happened,
 	 * but we must still l_wait_event() in this case to give liblustre
-	 * a chance to run client_bulk_callback() */
+	 * a chance to run client_bulk_callback()
+	 */
 	mdunlink_iterate_helper(desc->bd_mds, desc->bd_md_max_brw);
 
 	if (ptlrpc_client_bulk_active(req) == 0)	/* completed or */
@@ -279,7 +283,8 @@ int ptlrpc_unregister_bulk(struct ptlrpc_request *req, int async)
 
 	for (;;) {
 		/* Network access will complete in finite time but the HUGE
-		 * timeout lets us CWARN for visibility of sluggish NALs */
+		 * timeout lets us CWARN for visibility of sluggish LNDs
+		 */
 		lwi = LWI_TIMEOUT_INTERVAL(cfs_time_seconds(LONG_UNLINK),
 					   cfs_time_seconds(1), NULL, NULL);
 		rc = l_wait_event(*wq, !ptlrpc_client_bulk_active(req), &lwi);
@@ -309,7 +314,8 @@ static void ptlrpc_at_set_reply(struct ptlrpc_request *req, int flags)
 	      (MSG_RESENT | MSG_REPLAY |
 	       MSG_REQ_REPLAY_DONE | MSG_LOCK_REPLAY_DONE))) {
 		/* early replies, errors and recovery requests don't count
-		 * toward our service time estimate */
+		 * toward our service time estimate
+		 */
 		int oldse = at_measured(&svcpt->scp_at_estimate, service_time);
 
 		if (oldse != 0) {
@@ -323,7 +329,8 @@ static void ptlrpc_at_set_reply(struct ptlrpc_request *req, int flags)
 	lustre_msg_set_service_time(req->rq_repmsg, service_time);
 	/* Report service time estimate for future client reqs, but report 0
 	 * (to be ignored by client) if it's a error reply during recovery.
-	 * (bz15815) */
+	 * (bz15815)
+	 */
 	if (req->rq_type == PTL_RPC_MSG_ERR && !req->rq_export)
 		lustre_msg_set_timeout(req->rq_repmsg, 0);
 	else
@@ -496,7 +503,8 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	LASSERT(request->rq_wait_ctx == 0);
 
 	/* If this is a re-transmit, we're required to have disengaged
-	 * cleanly from the previous attempt */
+	 * cleanly from the previous attempt
+	 */
 	LASSERT(!request->rq_receiving_reply);
 	LASSERT(!((lustre_msg_get_flags(request->rq_reqmsg) & MSG_REPLAY) &&
 		(request->rq_import->imp_state == LUSTRE_IMP_FULL)));
@@ -548,7 +556,8 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 						      request->rq_replen);
 			if (rc) {
 				/* this prevents us from looping in
-				 * ptlrpc_queue_wait */
+				 * ptlrpc_queue_wait
+				 */
 				spin_lock(&request->rq_lock);
 				request->rq_err = 1;
 				spin_unlock(&request->rq_lock);
@@ -600,7 +609,8 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 		reply_md.eq_handle = ptlrpc_eq_h;
 
 		/* We must see the unlink callback to unset rq_reply_unlink,
-		   so we can't auto-unlink */
+		 * so we can't auto-unlink
+		 */
 		rc = LNetMDAttach(reply_me_h, reply_md, LNET_RETAIN,
 				  &request->rq_reply_md_h);
 		if (rc != 0) {
@@ -630,7 +640,8 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	ktime_get_real_ts64(&request->rq_arrival_time);
 	request->rq_sent = ktime_get_real_seconds();
 	/* We give the server rq_timeout secs to process the req, and
-	   add the network latency for our local timeout. */
+	 * add the network latency for our local timeout.
+	 */
 	request->rq_deadline = request->rq_sent + request->rq_timeout +
 		ptlrpc_at_get_net_latency(request);
 
@@ -654,7 +665,8 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
  cleanup_me:
 	/* MEUnlink is safe; the PUT didn't even get off the ground, and
 	 * nobody apart from the PUT's target has the right nid+XID to
-	 * access the reply buffer. */
+	 * access the reply buffer.
+	 */
 	rc2 = LNetMEUnlink(reply_me_h);
 	LASSERT(rc2 == 0);
 	/* UNLINKED callback called synchronously */
@@ -662,7 +674,8 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 
  cleanup_bulk:
 	/* We do sync unlink here as there was no real transfer here so
-	 * the chance to have long unlink to sluggish net is smaller here. */
+	 * the chance to have long unlink to sluggish net is smaller here.
+	 */
 	ptlrpc_unregister_bulk(request, 0);
  out:
 	if (request->rq_memalloc)
@@ -690,7 +703,8 @@ int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 
 	/* NB: CPT affinity service should use new LNet flag LNET_INS_LOCAL,
 	 * which means buffer can only be attached on local CPT, and LND
-	 * threads can find it by grabbing a local lock */
+	 * threads can find it by grabbing a local lock
+	 */
 	rc = LNetMEAttach(service->srv_req_portal,
 			  match_id, 0, ~0, LNET_UNLINK,
 			  rqbd->rqbd_svcpt->scp_cpt >= 0 ?
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index d603a57..58e5d86 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -43,9 +43,6 @@
 #include "../../include/linux/libcfs/libcfs.h"
 #include "ptlrpc_internal.h"
 
-/* XXX: This is just for liblustre. Remove the #if defined directive when the
- * "cfs_" prefix is dropped from cfs_list_head. */
-
 /**
  * NRS core object.
  */
@@ -1358,7 +1355,8 @@ void ptlrpc_nrs_req_finalize(struct ptlrpc_request *req)
 	if (req->rq_nrq.nr_initialized) {
 		nrs_resource_put_safe(req->rq_nrq.nr_res_ptrs);
 		/* no protection on bit nr_initialized because no
-		 * contention at this late stage */
+		 * contention at this late stage
+		 */
 		req->rq_nrq.nr_finalized = 1;
 	}
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 88bad09..f3ac810 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -133,7 +133,8 @@ EXPORT_SYMBOL(lustre_msg_size_v2);
  * NOTE: this should only be used for NEW requests, and should always be
  *       in the form of a v2 request.  If this is a connection to a v1
  *       target then the first buffer will be stripped because the ptlrpc
- *       data is part of the lustre_msg_v1 header. b=14043 */
+ *       data is part of the lustre_msg_v1 header. b=14043
+ */
 int lustre_msg_size(__u32 magic, int count, __u32 *lens)
 {
 	__u32 size[] = { sizeof(struct ptlrpc_body) };
@@ -157,7 +158,8 @@ int lustre_msg_size(__u32 magic, int count, __u32 *lens)
 EXPORT_SYMBOL(lustre_msg_size);
 
 /* This is used to determine the size of a buffer that was already packed
- * and will correctly handle the different message formats. */
+ * and will correctly handle the different message formats.
+ */
 int lustre_packed_msg_size(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
@@ -267,7 +269,8 @@ lustre_get_emerg_rs(struct ptlrpc_service_part *svcpt)
 
 		spin_unlock(&svcpt->scp_rep_lock);
 		/* If we cannot get anything for some long time, we better
-		 * bail out instead of waiting infinitely */
+		 * bail out instead of waiting infinitely
+		 */
 		lwi = LWI_TIMEOUT(cfs_time_seconds(10), NULL, NULL);
 		rc = l_wait_event(svcpt->scp_rep_waitq,
 				  !list_empty(&svcpt->scp_rep_idle), &lwi);
@@ -676,7 +679,8 @@ int lustre_msg_buflen(struct lustre_msg *m, int n)
 EXPORT_SYMBOL(lustre_msg_buflen);
 
 /* NB return the bufcount for lustre_msg_v2 format, so if message is packed
- * in V1 format, the result is one bigger. (add struct ptlrpc_body). */
+ * in V1 format, the result is one bigger. (add struct ptlrpc_body).
+ */
 int lustre_msg_bufcount(struct lustre_msg *m)
 {
 	switch (m->lm_magic) {
@@ -797,7 +801,8 @@ __u32 lustre_msg_get_flags(struct lustre_msg *msg)
 	/* no break */
 	default:
 		/* flags might be printed in debug code while message
-		 * uninitialized */
+		 * uninitialized
+		 */
 		return 0;
 	}
 }
@@ -1030,7 +1035,8 @@ int lustre_msg_get_status(struct lustre_msg *msg)
 	/* no break */
 	default:
 		/* status might be printed in debug code while message
-		 * uninitialized */
+		 * uninitialized
+		 */
 		return -EINVAL;
 	}
 }
@@ -1366,7 +1372,8 @@ void lustre_msg_set_jobid(struct lustre_msg *msg, char *jobid)
 		struct ptlrpc_body *pb;
 
 		/* Don't set jobid for ldlm ast RPCs, they've been shrunk.
-		 * See the comment in ptlrpc_request_pack(). */
+		 * See the comment in ptlrpc_request_pack().
+		 */
 		if (!opc || opc == LDLM_BL_CALLBACK ||
 		    opc == LDLM_CP_CALLBACK || opc == LDLM_GL_CALLBACK)
 			return;
@@ -1486,7 +1493,8 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *b)
 	 * clients and servers without ptlrpc_body_v2 (< 2.3)
 	 * do not swab any fields beyond pb_jobid, as we are
 	 * using this swab function for both ptlrpc_body
-	 * and ptlrpc_body_v2. */
+	 * and ptlrpc_body_v2.
+	 */
 	CLASSERT(offsetof(typeof(*b), pb_jobid) != 0);
 }
 EXPORT_SYMBOL(lustre_swab_ptlrpc_body);
@@ -1500,7 +1508,8 @@ void lustre_swab_connect(struct obd_connect_data *ocd)
 	__swab32s(&ocd->ocd_index);
 	__swab32s(&ocd->ocd_brw_size);
 	/* ocd_blocksize and ocd_inodespace don't need to be swabbed because
-	 * they are 8-byte values */
+	 * they are 8-byte values
+	 */
 	__swab16s(&ocd->ocd_grant_extent);
 	__swab32s(&ocd->ocd_unused);
 	__swab64s(&ocd->ocd_transno);
@@ -1510,7 +1519,8 @@ void lustre_swab_connect(struct obd_connect_data *ocd)
 	/* Fields after ocd_cksum_types are only accessible by the receiver
 	 * if the corresponding flag in ocd_connect_flags is set. Accessing
 	 * any field after ocd_maxbytes on the receiver without a valid flag
-	 * may result in out-of-bound memory access and kernel oops. */
+	 * may result in out-of-bound memory access and kernel oops.
+	 */
 	if (ocd->ocd_connect_flags & OBD_CONNECT_MAX_EASIZE)
 		__swab32s(&ocd->ocd_max_easize);
 	if (ocd->ocd_connect_flags & OBD_CONNECT_MAXBYTES)
@@ -1970,7 +1980,8 @@ static void lustre_swab_ldlm_policy_data(ldlm_wire_policy_data_t *d)
 {
 	/* the lock data is a union and the first two fields are always an
 	 * extent so it's ok to process an LDLM_EXTENT and LDLM_FLOCK lock
-	 * data the same way. */
+	 * data the same way.
+	 */
 	__swab64s(&d->l_extent.start);
 	__swab64s(&d->l_extent.end);
 	__swab64s(&d->l_extent.gid);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 21616ac..44bf026 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -257,11 +257,12 @@ static int ptlrpc_pinger_main(void *arg)
 		/* Wait until the next ping time, or until we're stopped. */
 		time_to_next_wake = pinger_check_timeout(this_ping);
 		/* The ping sent by ptlrpc_send_rpc may get sent out
-		   say .01 second after this.
-		   ptlrpc_pinger_sending_on_import will then set the
-		   next ping time to next_ping + .01 sec, which means
-		   we will SKIP the next ping at next_ping, and the
-		   ping will get sent 2 timeouts from now!  Beware. */
+		 * say .01 second after this.
+		 * ptlrpc_pinger_sending_on_import will then set the
+		 * next ping time to next_ping + .01 sec, which means
+		 * we will SKIP the next ping at next_ping, and the
+		 * ping will get sent 2 timeouts from now!  Beware.
+		 */
 		CDEBUG(D_INFO, "next wakeup in " CFS_DURATION_T " (%ld)\n",
 		       time_to_next_wake,
 		       cfs_time_add(this_ping,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index 8f67e05..6ca26c9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -101,8 +101,6 @@ struct nrs_core {
 	 * registration/unregistration, and NRS core lprocfs operations.
 	 */
 	struct mutex nrs_mutex;
-	/* XXX: This is just for liblustre. Remove the #if defined directive
-	 * when the * "cfs_" prefix is dropped from cfs_list_head. */
 	/**
 	 * List of all policy descriptors registered with NRS core; protected
 	 * by nrs_core::nrs_mutex.
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index f847383..0c36663 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -241,7 +241,8 @@ void ptlrpcd_add_req(struct ptlrpc_request *req)
 		l_wait_event(req->rq_set_waitq, !req->rq_set, &lwi);
 	} else if (req->rq_set) {
 		/* If we have a valid "rq_set", just reuse it to avoid double
-		 * linked. */
+		 * linked.
+		 */
 		LASSERT(req->rq_phase == RQ_PHASE_NEW);
 		LASSERT(req->rq_send_state == LUSTRE_IMP_REPLAY);
 
@@ -319,7 +320,8 @@ static int ptlrpcd_check(struct lu_env *env, struct ptlrpcd_ctl *pc)
 		rc |= ptlrpc_check_set(env, set);
 
 	/* NB: ptlrpc_check_set has already moved completed request at the
-	 * head of seq::set_requests */
+	 * head of seq::set_requests
+	 */
 	list_for_each_safe(pos, tmp, &set->set_requests) {
 		req = list_entry(pos, struct ptlrpc_request, rq_set_chain);
 		if (req->rq_phase != RQ_PHASE_COMPLETE)
@@ -337,7 +339,8 @@ static int ptlrpcd_check(struct lu_env *env, struct ptlrpcd_ctl *pc)
 		rc = atomic_read(&set->set_new_count);
 
 		/* If we have nothing to do, check whether we can take some
-		 * work from our partner threads. */
+		 * work from our partner threads.
+		 */
 		if (rc == 0 && pc->pc_npartners > 0) {
 			struct ptlrpcd_ctl *partner;
 			struct ptlrpc_request_set *ps;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index d923197..e5d344d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -114,7 +114,8 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 		if (req->rq_transno > last_transno) {
 			/* Since the imp_committed_list is immutable before
 			 * all of it's requests being replayed, it's safe to
-			 * use a cursor to accelerate the search */
+			 * use a cursor to accelerate the search
+			 */
 			imp->imp_replay_cursor = imp->imp_replay_cursor->next;
 
 			while (imp->imp_replay_cursor !=
@@ -137,7 +138,8 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 	}
 
 	/* All the requests in committed list have been replayed, let's replay
-	 * the imp_replay_list */
+	 * the imp_replay_list
+	 */
 	if (!req) {
 		list_for_each_safe(tmp, pos, &imp->imp_replay_list) {
 			req = list_entry(tmp, struct ptlrpc_request,
@@ -152,7 +154,8 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 	/* If need to resend the last sent transno (because a reconnect
 	 * has occurred), then stop on the matching req and send it again.
 	 * If, however, the last sent transno has been committed then we
-	 * continue replay from the next request. */
+	 * continue replay from the next request.
+	 */
 	if (req && imp->imp_resend_replay)
 		lustre_msg_add_flags(req->rq_reqmsg, MSG_RESENT);
 
@@ -249,7 +252,8 @@ void ptlrpc_request_handle_notconn(struct ptlrpc_request *failed_req)
 	}
 
 	/* Wait for recovery to complete and resend. If evicted, then
-	   this request will be errored out later.*/
+	 * this request will be errored out later.
+	 */
 	spin_lock(&failed_req->rq_lock);
 	if (!failed_req->rq_no_resend)
 		failed_req->rq_resend = 1;
@@ -271,13 +275,15 @@ int ptlrpc_set_import_active(struct obd_import *imp, int active)
 	LASSERT(obd);
 
 	/* When deactivating, mark import invalid, and abort in-flight
-	 * requests. */
+	 * requests.
+	 */
 	if (!active) {
 		LCONSOLE_WARN("setting import %s INACTIVE by administrator request\n",
 			      obd2cli_tgt(imp->imp_obd));
 
 		/* set before invalidate to avoid messages about imp_inval
-		 * set without imp_deactive in ptlrpc_import_delay_req */
+		 * set without imp_deactive in ptlrpc_import_delay_req
+		 */
 		spin_lock(&imp->imp_lock);
 		imp->imp_deactive = 1;
 		spin_unlock(&imp->imp_lock);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index c91e131..85f8f7c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -445,7 +445,8 @@ int sptlrpc_req_ctx_switch(struct ptlrpc_request *req,
 
 	/* alloc new request buffer
 	 * we don't need to alloc reply buffer here, leave it to the
-	 * rest procedure of ptlrpc */
+	 * rest procedure of ptlrpc
+	 */
 	if (reqmsg_size != 0) {
 		rc = sptlrpc_cli_alloc_reqbuf(req, reqmsg_size);
 		if (!rc) {
@@ -798,7 +799,8 @@ void sptlrpc_req_set_flavor(struct ptlrpc_request *req, int opcode)
 	spin_unlock(&sec->ps_lock);
 
 	/* force SVC_NULL for context initiation rpc, SVC_INTG for context
-	 * destruction rpc */
+	 * destruction rpc
+	 */
 	if (unlikely(req->rq_ctx_init))
 		flvr_set_svc(&req->rq_flvr.sf_rpc, SPTLRPC_SVC_NULL);
 	else if (unlikely(req->rq_ctx_fini))
@@ -1688,7 +1690,8 @@ int sptlrpc_target_export_check(struct obd_export *exp,
 		return 0;
 
 	/* client side export has no imp_reverse, skip
-	 * FIXME maybe we should check flavor this as well??? */
+	 * FIXME maybe we should check flavor this as well???
+	 */
 	if (!exp->exp_imp_reverse)
 		return 0;
 
@@ -1702,11 +1705,13 @@ int sptlrpc_target_export_check(struct obd_export *exp,
 	 * the first req with the new flavor, then treat it as current flavor,
 	 * adapt reverse sec according to it.
 	 * note the first rpc with new flavor might not be with root ctx, in
-	 * which case delay the sec_adapt by leaving exp_flvr_adapt == 1. */
+	 * which case delay the sec_adapt by leaving exp_flvr_adapt == 1.
+	 */
 	if (unlikely(exp->exp_flvr_changed) &&
 	    flavor_allowed(&exp->exp_flvr_old[1], req)) {
 		/* make the new flavor as "current", and old ones as
-		 * about-to-expire */
+		 * about-to-expire
+		 */
 		CDEBUG(D_SEC, "exp %p: just changed: %x->%x\n", exp,
 		       exp->exp_flvr.sf_rpc, exp->exp_flvr_old[1].sf_rpc);
 		flavor = exp->exp_flvr_old[1];
@@ -1742,10 +1747,12 @@ int sptlrpc_target_export_check(struct obd_export *exp,
 	}
 
 	/* if it equals to the current flavor, we accept it, but need to
-	 * dealing with reverse sec/ctx */
+	 * dealing with reverse sec/ctx
+	 */
 	if (likely(flavor_allowed(&exp->exp_flvr, req))) {
 		/* most cases should return here, we only interested in
-		 * gss root ctx init */
+		 * gss root ctx init
+		 */
 		if (!req->rq_auth_gss || !req->rq_ctx_init ||
 		    (!req->rq_auth_usr_root && !req->rq_auth_usr_mdt &&
 		     !req->rq_auth_usr_ost)) {
@@ -1755,7 +1762,8 @@ int sptlrpc_target_export_check(struct obd_export *exp,
 
 		/* if flavor just changed, we should not proceed, just leave
 		 * it and current flavor will be discovered and replaced
-		 * shortly, and let _this_ rpc pass through */
+		 * shortly, and let _this_ rpc pass through
+		 */
 		if (exp->exp_flvr_changed) {
 			LASSERT(exp->exp_flvr_adapt);
 			spin_unlock(&exp->exp_lock);
@@ -1809,7 +1817,8 @@ int sptlrpc_target_export_check(struct obd_export *exp,
 	}
 
 	/* now it doesn't match the current flavor, the only chance we can
-	 * accept it is match the old flavors which is not expired. */
+	 * accept it is match the old flavors which is not expired.
+	 */
 	if (exp->exp_flvr_changed == 0 && exp->exp_flvr_expire[1]) {
 		if (exp->exp_flvr_expire[1] >= ktime_get_real_seconds()) {
 			if (flavor_allowed(&exp->exp_flvr_old[1], req)) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index 6e58d5f..d5afc4f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -166,11 +166,13 @@ again:
 		 * is not optimal. we perhaps want to use balanced binary tree
 		 * to trace each sec as order of expiry time.
 		 * another issue here is we wakeup as fixed interval instead of
-		 * according to each sec's expiry time */
+		 * according to each sec's expiry time
+		 */
 		mutex_lock(&sec_gc_mutex);
 		list_for_each_entry(sec, &sec_gc_list, ps_gc_list) {
 			/* if someone is waiting to be deleted, let it
-			 * proceed as soon as possible. */
+			 * proceed as soon as possible.
+			 */
 			if (atomic_read(&sec_gc_wait_del)) {
 				CDEBUG(D_SEC, "deletion pending, start over\n");
 				mutex_unlock(&sec_gc_mutex);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
index 446837d..40e5349 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
@@ -258,7 +258,8 @@ int null_enlarge_reqbuf(struct ptlrpc_sec *sec,
 		 * imp_replay_list traversing threads. See LU-3333
 		 * This is a bandaid at best, we really need to deal with this
 		 * in request enlarging code before unpacking that's already
-		 * there */
+		 * there
+		 */
 		if (req->rq_import)
 			spin_lock(&req->rq_import->imp_lock);
 		memcpy(newbuf, req->rq_reqbuf, req->rq_reqlen);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index cffddc0..6276bf5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -264,7 +264,8 @@ int plain_ctx_verify(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 		}
 	} else {
 		/* whether we sent with bulk or not, we expect the same
-		 * in reply, except for early reply */
+		 * in reply, except for early reply
+		 */
 		if (!req->rq_early &&
 		    !equi(req->rq_pack_bulk == 1,
 			  phdr->ph_flags & PLAIN_FL_BULK)) {
@@ -673,7 +674,8 @@ int plain_enlarge_reqbuf(struct ptlrpc_sec *sec,
 		 * imp_replay_list traversing threads. See LU-3333
 		 * This is a bandaid at best, we really need to deal with this
 		 * in request enlarging code before unpacking that's already
-		 * there */
+		 * there
+		 */
 		if (req->rq_import)
 			spin_lock(&req->rq_import->imp_lock);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index dff9663..6f71ecc 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -144,7 +144,8 @@ ptlrpc_grow_req_bufs(struct ptlrpc_service_part *svcpt, int post)
 
 	for (i = 0; i < svc->srv_nbuf_per_group; i++) {
 		/* NB: another thread might have recycled enough rqbds, we
-		 * need to make sure it wouldn't over-allocate, see LU-1212. */
+		 * need to make sure it wouldn't over-allocate, see LU-1212.
+		 */
 		if (svcpt->scp_nrqbds_posted >= svc->srv_nbuf_per_group)
 			break;
 
@@ -322,7 +323,8 @@ ptlrpc_server_post_idle_rqbds(struct ptlrpc_service_part *svcpt)
 	list_add_tail(&rqbd->rqbd_list, &svcpt->scp_rqbd_idle);
 
 	/* Don't complain if no request buffers are posted right now; LNET
-	 * won't drop requests because we set the portal lazy! */
+	 * won't drop requests because we set the portal lazy!
+	 */
 
 	spin_unlock(&svcpt->scp_lock);
 
@@ -363,13 +365,15 @@ ptlrpc_server_nthreads_check(struct ptlrpc_service *svc,
 	init = max_t(int, init, tc->tc_nthrs_init);
 
 	/* NB: please see comments in lustre_lnet.h for definition
-	 * details of these members */
+	 * details of these members
+	 */
 	LASSERT(tc->tc_nthrs_max != 0);
 
 	if (tc->tc_nthrs_user != 0) {
 		/* In case there is a reason to test a service with many
 		 * threads, we give a less strict check here, it can
-		 * be up to 8 * nthrs_max */
+		 * be up to 8 * nthrs_max
+		 */
 		total = min(tc->tc_nthrs_max * 8, tc->tc_nthrs_user);
 		nthrs = total / svc->srv_ncpts;
 		init = max(init, nthrs);
@@ -379,7 +383,8 @@ ptlrpc_server_nthreads_check(struct ptlrpc_service *svc,
 	total = tc->tc_nthrs_max;
 	if (tc->tc_nthrs_base == 0) {
 		/* don't care about base threads number per partition,
-		 * this is most for non-affinity service */
+		 * this is most for non-affinity service
+		 */
 		nthrs = total / svc->srv_ncpts;
 		goto out;
 	}
@@ -390,7 +395,8 @@ ptlrpc_server_nthreads_check(struct ptlrpc_service *svc,
 
 		/* NB: Increase the base number if it's single partition
 		 * and total number of cores/HTs is larger or equal to 4.
-		 * result will always < 2 * nthrs_base */
+		 * result will always < 2 * nthrs_base
+		 */
 		weight = cfs_cpt_weight(svc->srv_cptable, CFS_CPT_ANY);
 		for (i = 1; (weight >> (i + 1)) != 0 && /* >= 4 cores/HTs */
 			    (tc->tc_nthrs_base >> i) != 0; i++)
@@ -506,7 +512,8 @@ ptlrpc_service_part_init(struct ptlrpc_service *svc,
 		    (unsigned long)svcpt);
 
 	/* At SOW, service time should be quick; 10s seems generous. If client
-	 * timeout is less than this, we'll be sending an early reply. */
+	 * timeout is less than this, we'll be sending an early reply.
+	 */
 	at_init(&svcpt->scp_at_estimate, 10, 0);
 
 	/* assign this before call ptlrpc_grow_req_bufs */
@@ -514,7 +521,8 @@ ptlrpc_service_part_init(struct ptlrpc_service *svc,
 	/* Now allocate the request buffers, but don't post them now */
 	rc = ptlrpc_grow_req_bufs(svcpt, 0);
 	/* We shouldn't be under memory pressure at startup, so
-	 * fail if we can't allocate all our buffers at this time. */
+	 * fail if we can't allocate all our buffers at this time.
+	 */
 	if (rc != 0)
 		goto free_reqs_count;
 
@@ -696,7 +704,8 @@ static void ptlrpc_server_free_request(struct ptlrpc_request *req)
 	LASSERT(list_empty(&req->rq_timed_list));
 
 	 /* DEBUG_REQ() assumes the reply state of a request with a valid
-	  * ref will not be destroyed until that reference is dropped. */
+	  * ref will not be destroyed until that reference is dropped.
+	  */
 	ptlrpc_req_drop_rs(req);
 
 	sptlrpc_svc_ctx_decref(req);
@@ -704,7 +713,8 @@ static void ptlrpc_server_free_request(struct ptlrpc_request *req)
 	if (req != &req->rq_rqbd->rqbd_req) {
 		/* NB request buffers use an embedded
 		 * req if the incoming req unlinked the
-		 * MD; this isn't one of them! */
+		 * MD; this isn't one of them!
+		 */
 		ptlrpc_request_cache_free(req);
 	}
 }
@@ -728,7 +738,8 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 	if (req->rq_at_linked) {
 		spin_lock(&svcpt->scp_at_lock);
 		/* recheck with lock, in case it's unlinked by
-		 * ptlrpc_at_check_timed() */
+		 * ptlrpc_at_check_timed()
+		 */
 		if (likely(req->rq_at_linked))
 			ptlrpc_at_remove_timed(req);
 		spin_unlock(&svcpt->scp_at_lock);
@@ -755,7 +766,8 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 		svcpt->scp_hist_nrqbds++;
 
 		/* cull some history?
-		 * I expect only about 1 or 2 rqbds need to be recycled here */
+		 * I expect only about 1 or 2 rqbds need to be recycled here
+		 */
 		while (svcpt->scp_hist_nrqbds > svc->srv_hist_nrqbds_cpt_max) {
 			rqbd = list_entry(svcpt->scp_hist_rqbds.next,
 					      struct ptlrpc_request_buffer_desc,
@@ -765,7 +777,8 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 			svcpt->scp_hist_nrqbds--;
 
 			/* remove rqbd's reqs from svc's req history while
-			 * I've got the service lock */
+			 * I've got the service lock
+			 */
 			list_for_each(tmp, &rqbd->rqbd_reqs) {
 				req = list_entry(tmp, struct ptlrpc_request,
 						     rq_list);
@@ -942,7 +955,8 @@ static int ptlrpc_at_add_timed(struct ptlrpc_request *req)
 	div_u64_rem(req->rq_deadline, array->paa_size, &index);
 	if (array->paa_reqs_count[index] > 0) {
 		/* latest rpcs will have the latest deadlines in the list,
-		 * so search backward. */
+		 * so search backward.
+		 */
 		list_for_each_entry_reverse(rq,
 						&array->paa_reqs_array[index],
 						rq_timed_list) {
@@ -1003,7 +1017,8 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	int rc;
 
 	/* deadline is when the client expects us to reply, margin is the
-	   difference between clients' and servers' expectations */
+	 * difference between clients' and servers' expectations
+	 */
 	DEBUG_REQ(D_ADAPTTO, req,
 		  "%ssending early reply (deadline %+lds, margin %+lds) for %d+%d",
 		  AT_OFF ? "AT off - not " : "",
@@ -1027,12 +1042,14 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	}
 
 	/* Fake our processing time into the future to ask the clients
-	 * for some extra amount of time */
+	 * for some extra amount of time
+	 */
 	at_measured(&svcpt->scp_at_estimate, at_extra +
 		    ktime_get_real_seconds() - req->rq_arrival_time.tv_sec);
 
 	/* Check to see if we've actually increased the deadline -
-	 * we may be past adaptive_max */
+	 * we may be past adaptive_max
+	 */
 	if (req->rq_deadline >= req->rq_arrival_time.tv_sec +
 	    at_get(&svcpt->scp_at_estimate)) {
 		DEBUG_REQ(D_WARNING, req, "Couldn't add any time (%ld/%lld), not sending early reply\n",
@@ -1102,7 +1119,8 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	}
 
 	/* Free the (early) reply state from lustre_pack_reply.
-	   (ptlrpc_send_reply takes it's own rs ref, so this is safe here) */
+	 * (ptlrpc_send_reply takes it's own rs ref, so this is safe here)
+	 */
 	ptlrpc_req_drop_rs(reqcopy);
 
 out_put:
@@ -1117,7 +1135,8 @@ out_free:
 }
 
 /* Send early replies to everybody expiring within at_early_margin
-   asking for at_extra time */
+ * asking for at_extra time
+ */
 static int ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 {
 	struct ptlrpc_at_array *array = &svcpt->scp_at_array;
@@ -1152,7 +1171,8 @@ static int ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 	}
 
 	/* We're close to a timeout, and we don't know how much longer the
-	   server will take. Send early replies to everyone expiring soon. */
+	 * server will take. Send early replies to everyone expiring soon.
+	 */
 	INIT_LIST_HEAD(&work_list);
 	deadline = -1;
 	div_u64_rem(array->paa_deadline, array->paa_size, &index);
@@ -1194,7 +1214,8 @@ static int ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 	       first, at_extra, counter);
 	if (first < 0) {
 		/* We're already past request deadlines before we even get a
-		   chance to send early replies */
+		 * chance to send early replies
+		 */
 		LCONSOLE_WARN("%s: This server is not able to keep up with request traffic (cpu-bound).\n",
 			      svcpt->scp_service->srv_name);
 		CWARN("earlyQ=%d reqQ=%d recA=%d, svcEst=%d, delay=%ld(jiff)\n",
@@ -1204,7 +1225,8 @@ static int ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 	}
 
 	/* we took additional refcount so entries can't be deleted from list, no
-	 * locking is needed */
+	 * locking is needed
+	 */
 	while (!list_empty(&work_list)) {
 		rq = list_entry(work_list.next, struct ptlrpc_request,
 				    rq_timed_list);
@@ -1237,7 +1259,8 @@ static int ptlrpc_server_hpreq_init(struct ptlrpc_service_part *svcpt,
 	if (req->rq_export && req->rq_ops) {
 		/* Perform request specific check. We should do this check
 		 * before the request is added into exp_hp_rpcs list otherwise
-		 * it may hit swab race at LU-1044. */
+		 * it may hit swab race at LU-1044.
+		 */
 		if (req->rq_ops->hpreq_check) {
 			rc = req->rq_ops->hpreq_check(req);
 			/**
@@ -1272,7 +1295,8 @@ static void ptlrpc_server_hpreq_fini(struct ptlrpc_request *req)
 {
 	if (req->rq_export && req->rq_ops) {
 		/* refresh lock timeout again so that client has more
-		 * room to send lock cancel RPC. */
+		 * room to send lock cancel RPC.
+		 */
 		if (req->rq_ops->hpreq_fini)
 			req->rq_ops->hpreq_fini(req);
 
@@ -1461,7 +1485,8 @@ ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 	list_del_init(&req->rq_list);
 	svcpt->scp_nreqs_incoming--;
 	/* Consider this still a "queued" request as far as stats are
-	 * concerned */
+	 * concerned
+	 */
 	spin_unlock(&svcpt->scp_lock);
 
 	/* go through security check/transform */
@@ -1652,7 +1677,8 @@ ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	}
 
 	/* Discard requests queued for longer than the deadline.
-	   The deadline is increased if we send an early reply. */
+	 * The deadline is increased if we send an early reply.
+	 */
 	if (ktime_get_real_seconds() > request->rq_deadline) {
 		DEBUG_REQ(D_ERROR, request, "Dropping timed-out request from %s: deadline " CFS_DURATION_T ":" CFS_DURATION_T "s ago\n",
 			  libcfs_id2str(request->rq_peer),
@@ -1804,7 +1830,8 @@ ptlrpc_handle_rs(struct ptlrpc_reply_state *rs)
 
 	if (nlocks == 0 && !been_handled) {
 		/* If we see this, we should already have seen the warning
-		 * in mds_steal_ack_locks()  */
+		 * in mds_steal_ack_locks()
+		 */
 		CDEBUG(D_HA, "All locks stolen from rs %p x%lld.t%lld o%d NID %s\n",
 		       rs,
 		       rs->rs_xid, rs->rs_transno, rs->rs_opc,
@@ -1858,7 +1885,8 @@ ptlrpc_check_rqbd_pool(struct ptlrpc_service_part *svcpt)
 	/* CAVEAT EMPTOR: We might be allocating buffers here because we've
 	 * allowed the request history to grow out of control.  We could put a
 	 * sanity check on that here and cull some history if we need the
-	 * space. */
+	 * space.
+	 */
 
 	if (avail <= low_water)
 		ptlrpc_grow_req_bufs(svcpt, 1);
@@ -1992,7 +2020,8 @@ static int ptlrpc_main(void *arg)
 
 	/* NB: we will call cfs_cpt_bind() for all threads, because we
 	 * might want to run lustre server only on a subset of system CPUs,
-	 * in that case ->scp_cpt is CFS_CPT_ANY */
+	 * in that case ->scp_cpt is CFS_CPT_ANY
+	 */
 	rc = cfs_cpt_bind(svc->srv_cptable, svcpt->scp_cpt);
 	if (rc != 0) {
 		CWARN("%s: failed to bind %s on CPT %d\n",
@@ -2057,7 +2086,8 @@ static int ptlrpc_main(void *arg)
 	/* SVC_STOPPING may already be set here if someone else is trying
 	 * to stop the service while this new thread has been dynamically
 	 * forked. We still set SVC_RUNNING to let our creator know that
-	 * we are now running, however we will exit as soon as possible */
+	 * we are now running, however we will exit as soon as possible
+	 */
 	thread_add_flags(thread, SVC_RUNNING);
 	svcpt->scp_nthrs_running++;
 	spin_unlock(&svcpt->scp_lock);
@@ -2116,7 +2146,8 @@ static int ptlrpc_main(void *arg)
 		    ptlrpc_server_post_idle_rqbds(svcpt) < 0) {
 			/* I just failed to repost request buffers.
 			 * Wait for a timeout (unless something else
-			 * happens) before I try again */
+			 * happens) before I try again
+			 */
 			svcpt->scp_rqbd_timeout = cfs_time_seconds(1) / 10;
 			CDEBUG(D_RPCTRACE, "Posted buffers: %d\n",
 			       svcpt->scp_nrqbds_posted);
@@ -2411,7 +2442,8 @@ int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 
 	if (svcpt->scp_nthrs_starting != 0) {
 		/* serialize starting because some modules (obdfilter)
-		 * might require unique and contiguous t_id */
+		 * might require unique and contiguous t_id
+		 */
 		LASSERT(svcpt->scp_nthrs_starting == 1);
 		spin_unlock(&svcpt->scp_lock);
 		kfree(thread);
@@ -2595,7 +2627,8 @@ ptlrpc_service_unlink_rqbd(struct ptlrpc_service *svc)
 	int i;
 
 	/* All history will be culled when the next request buffer is
-	 * freed in ptlrpc_service_purge_all() */
+	 * freed in ptlrpc_service_purge_all()
+	 */
 	svc->srv_hist_nrqbds_cpt_max = 0;
 
 	rc = LNetClearLazyPortal(svc->srv_req_portal);
@@ -2606,7 +2639,8 @@ ptlrpc_service_unlink_rqbd(struct ptlrpc_service *svc)
 			break;
 
 		/* Unlink all the request buffers.  This forces a 'final'
-		 * event with its 'unlink' flag set for each posted rqbd */
+		 * event with its 'unlink' flag set for each posted rqbd
+		 */
 		list_for_each_entry(rqbd, &svcpt->scp_rqbd_posted,
 					rqbd_list) {
 			rc = LNetMDUnlink(rqbd->rqbd_md_h);
@@ -2619,13 +2653,15 @@ ptlrpc_service_unlink_rqbd(struct ptlrpc_service *svc)
 			break;
 
 		/* Wait for the network to release any buffers
-		 * it's currently filling */
+		 * it's currently filling
+		 */
 		spin_lock(&svcpt->scp_lock);
 		while (svcpt->scp_nrqbds_posted != 0) {
 			spin_unlock(&svcpt->scp_lock);
 			/* Network access will complete in finite time but
 			 * the HUGE timeout lets us CWARN for visibility
-			 * of sluggish NALs */
+			 * of sluggish LNDs
+			 */
 			lwi = LWI_TIMEOUT_INTERVAL(
 					cfs_time_seconds(LONG_UNLINK),
 					cfs_time_seconds(1), NULL, NULL);
@@ -2666,7 +2702,8 @@ ptlrpc_service_purge_all(struct ptlrpc_service *svc)
 
 		/* purge the request queue.  NB No new replies (rqbds
 		 * all unlinked) and no service threads, so I'm the only
-		 * thread noodling the request queue now */
+		 * thread noodling the request queue now
+		 */
 		while (!list_empty(&svcpt->scp_req_incoming)) {
 			req = list_entry(svcpt->scp_req_incoming.next,
 					     struct ptlrpc_request, rq_list);
@@ -2685,11 +2722,13 @@ ptlrpc_service_purge_all(struct ptlrpc_service *svc)
 		LASSERT(svcpt->scp_nreqs_incoming == 0);
 		LASSERT(svcpt->scp_nreqs_active == 0);
 		/* history should have been culled by
-		 * ptlrpc_server_finish_request */
+		 * ptlrpc_server_finish_request
+		 */
 		LASSERT(svcpt->scp_hist_nrqbds == 0);
 
 		/* Now free all the request buffers since nothing
-		 * references them any more... */
+		 * references them any more...
+		 */
 
 		while (!list_empty(&svcpt->scp_rqbd_idle)) {
 			rqbd = list_entry(svcpt->scp_rqbd_idle.next,
-- 
2.1.0
