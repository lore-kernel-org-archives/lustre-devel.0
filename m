From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:44:09 -0400
Subject: [lustre-devel] [PATCH 26/29] staging/lustre: Remove server-only
	recovery-related bits
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-27-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

This patch is a first stab at trying to remove structure fields
from obd_export and obd structures that are only used on the
server or make sense on the server. These include tracking
requests in recovery, various recovery stages, lists of
recovered and not yet recovered clients and so on.
Also prune functions that use these fields.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/lustre_export.h  | 17 +-----
 drivers/staging/lustre/lustre/include/obd.h        | 27 ---------
 drivers/staging/lustre/lustre/include/obd_class.h  |  1 -
 drivers/staging/lustre/lustre/obdclass/genops.c    | 50 +----------------
 .../staging/lustre/lustre/obdclass/obd_config.c    |  6 --
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  3 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     | 64 ++++++++--------------
 7 files changed, 28 insertions(+), 140 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index 5b8f4e8..1daf4c5 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -183,25 +183,10 @@ struct obd_export {
 	struct obd_connect_data   exp_connect_data;
 	enum obd_option	   exp_flags;
 	unsigned long	     exp_failed:1,
-				  exp_in_recovery:1,
 				  exp_disconnected:1,
 				  exp_connecting:1,
-				  /** VBR: export missed recovery */
-				  exp_delayed:1,
-				  /** VBR: failed version checking */
-				  exp_vbr_failed:1,
-				  exp_req_replay_needed:1,
-				  exp_lock_replay_needed:1,
-				  exp_need_sync:1,
 				  exp_flvr_changed:1,
-				  exp_flvr_adapt:1,
-				  exp_libclient:1, /* liblustre client? */
-				  /* client timed out and tried to reconnect,
-				   * but couldn't because of active rpcs */
-				  exp_abort_active_req:1,
-				  /* if to swap nidtbl entries for 2.2 clients.
-				   * Only used by the MGS to fix LU-1644. */
-				  exp_need_mne_swab:1;
+				  exp_flvr_adapt:1;
 	/* also protected by exp_lock */
 	enum lustre_sec_part      exp_sp_peer;
 	struct sptlrpc_flavor     exp_flvr;	     /* current */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 3fb72dc..314f5c7 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -725,8 +725,6 @@ struct obd_device {
 	/* bitfield modification is protected by obd_dev_lock */
 	unsigned long obd_attached:1,      /* finished attach */
 		      obd_set_up:1,	/* finished setup */
-		      obd_recovering:1,    /* there are recoverable clients */
-		      obd_abort_recovery:1,/* recovery expired */
 		      obd_version_recov:1, /* obd uses version checking */
 		      obd_replayable:1,    /* recovery is enabled; inform clients */
 		      obd_no_transno:1,    /* no committed-transno notification */
@@ -769,31 +767,6 @@ struct obd_device {
 	struct obd_notify_upcall obd_upcall;
 	struct obd_export       *obd_self_export;
 
-	int			      obd_max_recoverable_clients;
-	atomic_t		     obd_connected_clients;
-	int			      obd_stale_clients;
-	int			      obd_delayed_clients;
-	/* this lock protects all recovery list_heads, timer and
-	 * obd_next_recovery_transno value */
-	spinlock_t			 obd_recovery_task_lock;
-	__u64			    obd_next_recovery_transno;
-	int			      obd_replayed_requests;
-	int			      obd_requests_queued_for_recovery;
-	wait_queue_head_t		      obd_next_transno_waitq;
-	/* protected by obd_recovery_task_lock */
-	int			      obd_recovery_timeout;
-
-	/* new recovery stuff from CMD2 */
-	struct target_recovery_data      obd_recovery_data;
-	int			      obd_replayed_locks;
-	atomic_t		     obd_req_replay_clients;
-	atomic_t		     obd_lock_replay_clients;
-	/* all lists are protected by obd_recovery_task_lock */
-	struct list_head		       obd_req_replay_queue;
-	struct list_head		       obd_lock_replay_queue;
-	struct list_head		       obd_final_req_queue;
-	int			      obd_recovery_stage;
-
 	union {
 		struct client_obd cli;
 		struct echo_client_obd echo_client;
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 73fb29f..6fb67a6 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -273,7 +273,6 @@ static inline enum obd_option exp_flags_from_obd(struct obd_device *obd)
 {
 	return ((obd->obd_fail ? OBD_OPT_FAILOVER : 0) |
 		(obd->obd_force ? OBD_OPT_FORCE : 0) |
-		(obd->obd_abort_recovery ? OBD_OPT_ABORT_RECOV : 0) |
 		0);
 }
 
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 681312e..c1bffcd 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -1034,51 +1034,6 @@ int class_connect(struct lustre_handle *conn, struct obd_device *obd,
 }
 EXPORT_SYMBOL(class_connect);
 
-/* if export is involved in recovery then clean up related things */
-static void class_export_recovery_cleanup(struct obd_export *exp)
-{
-	struct obd_device *obd = exp->exp_obd;
-
-	spin_lock(&obd->obd_recovery_task_lock);
-	if (exp->exp_delayed)
-		obd->obd_delayed_clients--;
-	if (obd->obd_recovering) {
-		if (exp->exp_in_recovery) {
-			spin_lock(&exp->exp_lock);
-			exp->exp_in_recovery = 0;
-			spin_unlock(&exp->exp_lock);
-			LASSERT_ATOMIC_POS(&obd->obd_connected_clients);
-			atomic_dec(&obd->obd_connected_clients);
-		}
-
-		/* if called during recovery then should update
-		 * obd_stale_clients counter,
-		 * lightweight exports are not counted */
-		if (exp->exp_failed &&
-		    (exp_connect_flags(exp) & OBD_CONNECT_LIGHTWEIGHT) == 0)
-			exp->exp_obd->obd_stale_clients++;
-	}
-	spin_unlock(&obd->obd_recovery_task_lock);
-
-	spin_lock(&exp->exp_lock);
-	/** Cleanup req replay fields */
-	if (exp->exp_req_replay_needed) {
-		exp->exp_req_replay_needed = 0;
-
-		LASSERT(atomic_read(&obd->obd_req_replay_clients));
-		atomic_dec(&obd->obd_req_replay_clients);
-	}
-
-	/** Cleanup lock replay data */
-	if (exp->exp_lock_replay_needed) {
-		exp->exp_lock_replay_needed = 0;
-
-		LASSERT(atomic_read(&obd->obd_lock_replay_clients));
-		atomic_dec(&obd->obd_lock_replay_clients);
-	}
-	spin_unlock(&exp->exp_lock);
-}
-
 /* This function removes 1-3 references from the export:
  * 1 - for export pointer passed
  * and if disconnect really need
@@ -1108,7 +1063,6 @@ int class_disconnect(struct obd_export *export)
 	CDEBUG(D_IOCTL, "disconnect: cookie %#llx\n",
 	       export->exp_handle.h_cookie);
 
-	class_export_recovery_cleanup(export);
 	class_unlink_export(export);
 no_disconn:
 	class_export_put(export);
@@ -1184,13 +1138,13 @@ static void print_export_data(struct obd_export *exp, const char *status,
 	}
 	spin_unlock(&exp->exp_lock);
 
-	CDEBUG(D_HA, "%s: %s %p %s %s %d (%d %d %d) %d %d %d %d: %p %s %llu\n",
+	CDEBUG(D_HA, "%s: %s %p %s %s %d (%d %d %d) %d %d %d: %p %s %llu\n",
 	       exp->exp_obd->obd_name, status, exp, exp->exp_client_uuid.uuid,
 	       obd_export_nid2str(exp), atomic_read(&exp->exp_refcount),
 	       atomic_read(&exp->exp_rpc_count),
 	       atomic_read(&exp->exp_cb_count),
 	       atomic_read(&exp->exp_locks_count),
-	       exp->exp_disconnected, exp->exp_delayed, exp->exp_failed,
+	       exp->exp_disconnected, exp->exp_failed,
 	       nreplies, first_reply, nreplies > 3 ? "..." : "",
 	       exp->exp_last_committed);
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 48c712e..66fafd3 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -237,13 +237,7 @@ int class_attach(struct lustre_cfg *lcfg)
 	/* XXX belongs in setup not attach  */
 	init_rwsem(&obd->obd_observer_link_sem);
 	/* recovery data */
-	spin_lock_init(&obd->obd_recovery_task_lock);
-	init_waitqueue_head(&obd->obd_next_transno_waitq);
 	init_waitqueue_head(&obd->obd_evict_inprogress_waitq);
-	INIT_LIST_HEAD(&obd->obd_req_replay_queue);
-	INIT_LIST_HEAD(&obd->obd_lock_replay_queue);
-	INIT_LIST_HEAD(&obd->obd_final_req_queue);
-	INIT_LIST_HEAD(&obd->obd_evict_list);
 
 	llog_group_init(&obd->obd_olg, FID_SEQ_LLOG);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 8db62d0..13632cd 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -328,8 +328,7 @@ static void ptlrpc_at_set_reply(struct ptlrpc_request *req, int flags)
 	/* Report service time estimate for future client reqs, but report 0
 	 * (to be ignored by client) if it's a error reply during recovery.
 	 * (bz15815) */
-	if (req->rq_type == PTL_RPC_MSG_ERR &&
-	    (req->rq_export == NULL || req->rq_export->exp_obd->obd_recovering))
+	if (req->rq_type == PTL_RPC_MSG_ERR && !req->rq_export)
 		lustre_msg_set_timeout(req->rq_repmsg, 0);
 	else
 		lustre_msg_set_timeout(req->rq_repmsg,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 353ac22..44fde0b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -880,18 +880,16 @@ static int ptlrpc_check_req(struct ptlrpc_request *req)
 		       req, (obd != NULL) ? obd->obd_name : "unknown");
 		rc = -ENODEV;
 	} else if (lustre_msg_get_flags(req->rq_reqmsg) &
-		   (MSG_REPLAY | MSG_REQ_REPLAY_DONE) &&
-		   !obd->obd_recovering) {
-			DEBUG_REQ(D_ERROR, req,
-				  "Invalid replay without recovery");
-			class_fail_export(req->rq_export);
-			rc = -ENODEV;
-	} else if (lustre_msg_get_transno(req->rq_reqmsg) != 0 &&
-		   !obd->obd_recovering) {
-			DEBUG_REQ(D_ERROR, req, "Invalid req with transno %llu without recovery",
-				  lustre_msg_get_transno(req->rq_reqmsg));
-			class_fail_export(req->rq_export);
-			rc = -ENODEV;
+		   (MSG_REPLAY | MSG_REQ_REPLAY_DONE)) {
+		DEBUG_REQ(D_ERROR, req, "Invalid replay without recovery");
+		class_fail_export(req->rq_export);
+		rc = -ENODEV;
+	} else if (lustre_msg_get_transno(req->rq_reqmsg) != 0) {
+		DEBUG_REQ(D_ERROR, req,
+			  "Invalid req with transno %llu without recovery",
+			  lustre_msg_get_transno(req->rq_reqmsg));
+		class_fail_export(req->rq_export);
+		rc = -ENODEV;
 	}
 
 	if (unlikely(rc < 0)) {
@@ -1030,34 +1028,20 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 		return -ENOSYS;
 	}
 
-	if (req->rq_export &&
-	    lustre_msg_get_flags(req->rq_reqmsg) &
-	    (MSG_REPLAY | MSG_REQ_REPLAY_DONE | MSG_LOCK_REPLAY_DONE)) {
-		/* During recovery, we don't want to send too many early
-		 * replies, but on the other hand we want to make sure the
-		 * client has enough time to resend if the rpc is lost. So
-		 * during the recovery period send at least 4 early replies,
-		 * spacing them every at_extra if we can. at_estimate should
-		 * always equal this fixed value during recovery. */
-		at_measured(&svcpt->scp_at_estimate, min(at_extra,
-			    req->rq_export->exp_obd->obd_recovery_timeout / 4));
-	} else {
-		/* Fake our processing time into the future to ask the clients
-		 * for some extra amount of time */
-		at_measured(&svcpt->scp_at_estimate, at_extra +
-			    ktime_get_real_seconds() -
-			    req->rq_arrival_time.tv_sec);
-
-		/* Check to see if we've actually increased the deadline -
-		 * we may be past adaptive_max */
-		if (req->rq_deadline >= req->rq_arrival_time.tv_sec +
-		    at_get(&svcpt->scp_at_estimate)) {
-			DEBUG_REQ(D_WARNING, req, "Couldn't add any time (%ld/%lld), not sending early reply\n",
-				  olddl, req->rq_arrival_time.tv_sec +
-				  at_get(&svcpt->scp_at_estimate) -
-				  ktime_get_real_seconds());
-			return -ETIMEDOUT;
-		}
+	/* Fake our processing time into the future to ask the clients
+	 * for some extra amount of time */
+	at_measured(&svcpt->scp_at_estimate, at_extra +
+		    ktime_get_real_seconds() - req->rq_arrival_time.tv_sec);
+
+	/* Check to see if we've actually increased the deadline -
+	 * we may be past adaptive_max */
+	if (req->rq_deadline >= req->rq_arrival_time.tv_sec +
+	    at_get(&svcpt->scp_at_estimate)) {
+		DEBUG_REQ(D_WARNING, req, "Couldn't add any time (%ld/%lld), not sending early reply\n",
+			  olddl, req->rq_arrival_time.tv_sec +
+			  at_get(&svcpt->scp_at_estimate) -
+			  ktime_get_real_seconds());
+		return -ETIMEDOUT;
 	}
 	newdl = ktime_get_real_seconds() + at_get(&svcpt->scp_at_estimate);
 
-- 
2.1.0
