From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:07 -0500
Subject: [lustre-devel] [PATCH 079/622] lnet: handle local ni failure
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-80-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Added an enumerated type listing the different errors which
the LND can propagate up to LNet for further handling.

All local timeout errors will trigger a resend if the
system is configured for resends. Remote errors will
not trigger a resend to avoid creating duplicate message
scenario on the receiving end. If a transmit error is encountered
where we're sure the message wasn't received by the remote end
we will attempt a resend.

LNet level logic to handle local NI failure. When the LND finalizes
a message lnet_finalize() will check if the message completed
successfully, if so it increments the healthv of the local NI, but
not beyond the max, and if it failed then it'll decrement the healthv
but not below 0 and put the message on the resend queue.

On local NI failure the local NI is placed on a recovery queue.

The monitor thread will wake up and resend all the messages pending.
The selection algorithm will properly select the local and remote NIs
based on the new healthv.

The monitor thread will ping each NI on the local recovery queue. On
reply it will check if the NIs healthv is back to maximum, if it is
then it will remove it from the recovery queue, otherwise it'll
keep it there until it's fully recovered.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 70616605dd44 ("LU-9120 lnet: handle local ni failure")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32764
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/api.h       |   3 +-
 include/linux/lnet/lib-lnet.h  |   3 +
 include/linux/lnet/lib-types.h |  54 +++--
 net/lnet/lnet/api-ni.c         |  30 ++-
 net/lnet/lnet/config.c         |   3 +-
 net/lnet/lnet/lib-move.c       | 516 +++++++++++++++++++++++++++++++++++++++--
 net/lnet/lnet/lib-msg.c        | 281 +++++++++++++++++++++-
 net/lnet/lnet/peer.c           |  57 ++---
 net/lnet/lnet/router.c         |   2 +-
 net/lnet/selftest/rpc.c        |   2 +-
 10 files changed, 862 insertions(+), 89 deletions(-)

diff --git a/include/linux/lnet/api.h b/include/linux/lnet/api.h
index 7cc1d04..a57ecc8 100644
--- a/include/linux/lnet/api.h
+++ b/include/linux/lnet/api.h
@@ -195,7 +195,8 @@ int LNetGet(lnet_nid_t self,
 	    struct lnet_process_id target_in,
 	    unsigned int portal_in,
 	    u64	match_bits_in,
-	    unsigned int offset_in);
+	    unsigned int offset_in,
+	    bool recovery);
 /** @} lnet_data */
 
 /** \defgroup lnet_misc Miscellaneous operations.
diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 2c3f665..965fc5f 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -536,6 +536,8 @@ void lnet_prep_send(struct lnet_msg *msg, int type,
 		    struct lnet_process_id target, unsigned int offset,
 		    unsigned int len);
 int lnet_send(lnet_nid_t nid, struct lnet_msg *msg, lnet_nid_t rtr_nid);
+int lnet_send_ping(lnet_nid_t dest_nid, struct lnet_handle_md *mdh, int nnis,
+		   void *user_ptr, struct lnet_handle_eq eqh, bool recovery);
 void lnet_return_tx_credits_locked(struct lnet_msg *msg);
 void lnet_return_rx_credits_locked(struct lnet_msg *msg);
 void lnet_schedule_blocked_locked(struct lnet_rtrbufpool *rbp);
@@ -623,6 +625,7 @@ void lnet_drop_message(struct lnet_ni *ni, int cpt, void *private,
 void lnet_msg_containers_destroy(void);
 int lnet_msg_containers_create(void);
 
+char *lnet_health_error2str(enum lnet_msg_hstatus hstatus);
 char *lnet_msgtyp2str(int type);
 void lnet_print_hdr(struct lnet_hdr *hdr);
 int lnet_fail_nid(lnet_nid_t nid, unsigned int threshold);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index e1a56a1..8c3bf34 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -61,6 +61,20 @@
 /* forward refs */
 struct lnet_libmd;
 
+enum lnet_msg_hstatus {
+	LNET_MSG_STATUS_OK = 0,
+	LNET_MSG_STATUS_LOCAL_INTERRUPT,
+	LNET_MSG_STATUS_LOCAL_DROPPED,
+	LNET_MSG_STATUS_LOCAL_ABORTED,
+	LNET_MSG_STATUS_LOCAL_NO_ROUTE,
+	LNET_MSG_STATUS_LOCAL_ERROR,
+	LNET_MSG_STATUS_LOCAL_TIMEOUT,
+	LNET_MSG_STATUS_REMOTE_ERROR,
+	LNET_MSG_STATUS_REMOTE_DROPPED,
+	LNET_MSG_STATUS_REMOTE_TIMEOUT,
+	LNET_MSG_STATUS_NETWORK_TIMEOUT
+};
+
 struct lnet_msg {
 	struct list_head	msg_activelist;
 	struct list_head	msg_list;	/* Q for credits/MD */
@@ -85,6 +99,13 @@ struct lnet_msg {
 	 */
 	ktime_t			msg_deadline;
 
+	/* The message health status. */
+	enum lnet_msg_hstatus	msg_health_status;
+	/* This is a recovery message */
+	bool			msg_recovery;
+	/* flag to indicate that we do not want to resend this message */
+	bool			msg_no_resend;
+
 	/* committed for sending */
 	unsigned int		msg_tx_committed:1;
 	/* CPT # this message committed for sending */
@@ -277,18 +298,11 @@ struct lnet_tx_queue {
 	struct list_head	tq_delayed;	/* delayed TXs */
 };
 
-enum lnet_ni_state {
-	/* set when NI block is allocated */
-	LNET_NI_STATE_INIT	= 0,
-	/* set when NI is started successfully */
-	LNET_NI_STATE_ACTIVE,
-	/* set when LND notifies NI failed */
-	LNET_NI_STATE_FAILED,
-	/* set when LND notifies NI degraded */
-	LNET_NI_STATE_DEGRADED,
-	/* set when shuttding down NI */
-	LNET_NI_STATE_DELETING
-};
+#define LNET_NI_STATE_INIT		(1 << 0)
+#define LNET_NI_STATE_ACTIVE		(1 << 1)
+#define LNET_NI_STATE_FAILED		(1 << 2)
+#define LNET_NI_STATE_RECOVERY_PENDING	(1 << 3)
+#define LNET_NI_STATE_DELETING		(1 << 4)
 
 enum lnet_stats_type {
 	LNET_STATS_TYPE_SEND	= 0,
@@ -351,6 +365,12 @@ struct lnet_ni {
 	/* chain on the lnet_net structure */
 	struct list_head	ni_netlist;
 
+	/* chain on the recovery queue */
+	struct list_head	ni_recovery;
+
+	/* MD handle for recovery ping */
+	struct lnet_handle_md	ni_ping_mdh;
+
 	/* number of CPTs */
 	int			ni_ncpts;
 
@@ -382,7 +402,7 @@ struct lnet_ni {
 	struct lnet_ni_status	*ni_status;
 
 	/* NI FSM */
-	enum lnet_ni_state	ni_state;
+	u32			ni_state;
 
 	/* per NI LND tunables */
 	struct lnet_lnd_tunables ni_lnd_tunables;
@@ -1063,6 +1083,14 @@ struct lnet {
 	 * checking routes, timedout messages and resending messages.
 	 */
 	wait_queue_head_t		ln_mt_waitq;
+
+	/* per-cpt resend queues */
+	struct list_head		**ln_mt_resendqs;
+	/* local NIs to recover */
+	struct list_head		ln_mt_localNIRecovq;
+	/* recovery eq handler */
+	struct lnet_handle_eq		ln_mt_eqh;
+
 };
 
 #endif
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 418d65e..deef404 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -831,6 +831,7 @@ struct lnet_libhandle *
 	INIT_LIST_HEAD(&the_lnet.ln_dc_request);
 	INIT_LIST_HEAD(&the_lnet.ln_dc_working);
 	INIT_LIST_HEAD(&the_lnet.ln_dc_expired);
+	INIT_LIST_HEAD(&the_lnet.ln_mt_localNIRecovq);
 	init_waitqueue_head(&the_lnet.ln_dc_waitq);
 
 	rc = lnet_descriptor_setup();
@@ -1072,8 +1073,7 @@ struct lnet_net *
 bool
 lnet_is_ni_healthy_locked(struct lnet_ni *ni)
 {
-	if (ni->ni_state == LNET_NI_STATE_ACTIVE ||
-	    ni->ni_state == LNET_NI_STATE_DEGRADED)
+	if (ni->ni_state & LNET_NI_STATE_ACTIVE)
 		return true;
 
 	return false;
@@ -1650,7 +1650,7 @@ static void lnet_push_target_fini(void)
 		list_del_init(&ni->ni_netlist);
 		/* the ni should be in deleting state. If it's not it's
 		 * a bug */
-		LASSERT(ni->ni_state == LNET_NI_STATE_DELETING);
+		LASSERT(ni->ni_state & LNET_NI_STATE_DELETING);
 		cfs_percpt_for_each(ref, j, ni->ni_refs) {
 			if (!*ref)
 				continue;
@@ -1697,7 +1697,10 @@ static void lnet_push_target_fini(void)
 	struct lnet_net *net = ni->ni_net;
 
 	lnet_net_lock(LNET_LOCK_EX);
-	ni->ni_state = LNET_NI_STATE_DELETING;
+	lnet_ni_lock(ni);
+	ni->ni_state |= LNET_NI_STATE_DELETING;
+	ni->ni_state &= ~LNET_NI_STATE_ACTIVE;
+	lnet_ni_unlock(ni);
 	lnet_ni_unlink_locked(ni);
 	lnet_incr_dlc_seq();
 	lnet_net_unlock(LNET_LOCK_EX);
@@ -1789,6 +1792,7 @@ static void lnet_push_target_fini(void)
 
 	list_for_each_entry_safe(msg, tmp, &resend, msg_list) {
 		list_del_init(&msg->msg_list);
+		msg->msg_no_resend = true;
 		lnet_finalize(msg, -ECANCELED);
 	}
 
@@ -1827,7 +1831,10 @@ static void lnet_push_target_fini(void)
 		goto failed0;
 	}
 
-	ni->ni_state = LNET_NI_STATE_ACTIVE;
+	lnet_ni_lock(ni);
+	ni->ni_state |= LNET_NI_STATE_ACTIVE;
+	ni->ni_state &= ~LNET_NI_STATE_INIT;
+	lnet_ni_unlock(ni);
 
 	/* We keep a reference on the loopback net through the loopback NI */
 	if (net->net_lnd->lnd_type == LOLND) {
@@ -2554,11 +2561,17 @@ struct lnet_ni *
 	struct lnet_ni *ni;
 	struct lnet_net *net = mynet;
 
+	/* It is possible that the net has been cleaned out while there is
+	 * a message being sent. This function accessed the net without
+	 * checking if the list is empty
+	 */
 	if (!prev) {
 		if (!net)
 			net = list_first_entry(&the_lnet.ln_nets,
 					       struct lnet_net,
 					       net_list);
+		if (list_empty(&net->net_ni_list))
+			return NULL;
 		ni = list_first_entry(&net->net_ni_list, struct lnet_ni,
 				      ni_netlist);
 
@@ -2580,6 +2593,8 @@ struct lnet_ni *
 		/* get the next net */
 		net = list_first_entry(&prev->ni_net->net_list, struct lnet_net,
 				       net_list);
+		if (list_empty(&net->net_ni_list))
+			return NULL;
 		/* get the ni on it */
 		ni = list_first_entry(&net->net_ni_list, struct lnet_ni,
 				      ni_netlist);
@@ -2587,6 +2602,9 @@ struct lnet_ni *
 		return ni;
 	}
 
+	if (list_empty(&prev->ni_netlist))
+		return NULL;
+
 	/* there are more nis left */
 	ni = list_first_entry(&prev->ni_netlist, struct lnet_ni, ni_netlist);
 
@@ -3571,7 +3589,7 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 
 	rc = LNetGet(LNET_NID_ANY, mdh, id,
 		     LNET_RESERVED_PORTAL,
-		     LNET_PROTO_PING_MATCHBITS, 0);
+		     LNET_PROTO_PING_MATCHBITS, 0, false);
 	if (rc) {
 		/* Don't CERROR; this could be deliberate! */
 		rc2 = LNetMDUnlink(mdh);
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 0560215..ea62d36 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -442,6 +442,7 @@ struct lnet_net *
 
 	spin_lock_init(&ni->ni_lock);
 	INIT_LIST_HEAD(&ni->ni_netlist);
+	INIT_LIST_HEAD(&ni->ni_recovery);
 	ni->ni_refs = cfs_percpt_alloc(lnet_cpt_table(),
 				       sizeof(*ni->ni_refs[0]));
 	if (!ni->ni_refs)
@@ -466,7 +467,7 @@ struct lnet_net *
 		ni->ni_net_ns = NULL;
 
 	ni->ni_last_alive = ktime_get_real_seconds();
-	ni->ni_state = LNET_NI_STATE_INIT;
+	ni->ni_state |= LNET_NI_STATE_INIT;
 	list_add_tail(&ni->ni_netlist, &net->net_ni_added);
 
 	/*
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 418e3ad..f3f4b84 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -579,8 +579,10 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		(msg->msg_txcredit && msg->msg_peertxcredit));
 
 	rc = ni->ni_net->net_lnd->lnd_send(ni, priv, msg);
-	if (rc < 0)
+	if (rc < 0) {
+		msg->msg_no_resend = true;
 		lnet_finalize(msg, rc);
+	}
 }
 
 static int
@@ -759,8 +761,10 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 		CNETERR("Dropping message for %s: peer not alive\n",
 			libcfs_id2str(msg->msg_target));
-		if (do_send)
+		if (do_send) {
+			msg->msg_health_status = LNET_MSG_STATUS_LOCAL_DROPPED;
 			lnet_finalize(msg, -EHOSTUNREACH);
+		}
 
 		lnet_net_lock(cpt);
 		return -EHOSTUNREACH;
@@ -772,8 +776,10 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 		CNETERR("Aborting message for %s: LNetM[DE]Unlink() already called on the MD/ME.\n",
 			libcfs_id2str(msg->msg_target));
-		if (do_send)
+		if (do_send) {
+			msg->msg_no_resend = true;
 			lnet_finalize(msg, -ECANCELED);
+		}
 
 		lnet_net_lock(cpt);
 		return -ECANCELED;
@@ -1059,6 +1065,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		lnet_ni_recv(msg->msg_rxni, msg->msg_private, NULL,
 			     0, 0, 0, msg->msg_hdr.payload_length);
 		list_del_init(&msg->msg_list);
+		msg->msg_no_resend = true;
 		lnet_finalize(msg, -ECANCELED);
 	}
 
@@ -2273,6 +2280,14 @@ struct lnet_ni *
 		return PTR_ERR(lpni);
 	}
 
+	/* Cache the original src_nid. If we need to resend the message
+	 * then we'll need to know whether the src_nid was originally
+	 * specified for this message. If it was originally specified,
+	 * then we need to keep using the same src_nid since it's
+	 * continuing the same sequence of messages.
+	 */
+	msg->msg_src_nid_param = src_nid;
+
 	/* Now that we have a peer_ni, check if we want to discover
 	 * the peer. Traffic to the LNET_RESERVED_PORTAL should not
 	 * trigger discovery.
@@ -2290,7 +2305,6 @@ struct lnet_ni *
 		/* The peer may have changed. */
 		peer = lpni->lpni_peer_net->lpn_peer;
 		/* queue message and return */
-		msg->msg_src_nid_param = src_nid;
 		msg->msg_rtr_nid_param = rtr_nid;
 		msg->msg_sending = 0;
 		list_add_tail(&msg->msg_list, &peer->lp_dc_pendq);
@@ -2323,7 +2337,11 @@ struct lnet_ni *
 	else
 		send_case |= REMOTE_DST;
 
-	if (!lnet_peer_is_multi_rail(peer))
+	/* if this is a non-MR peer or if we're recovering a peer ni then
+	 * let's consider this an NMR case so we can hit the destination
+	 * NID.
+	 */
+	if (!lnet_peer_is_multi_rail(peer) || msg->msg_recovery)
 		send_case |= NMR_DST;
 	else
 		send_case |= MR_DST;
@@ -2370,6 +2388,7 @@ struct lnet_ni *
 	 */
 	/* NB: !ni == interface pre-determined (ACK/REPLY) */
 	LASSERT(!msg->msg_txpeer);
+	LASSERT(!msg->msg_txni);
 	LASSERT(!msg->msg_sending);
 	LASSERT(!msg->msg_target_is_router);
 	LASSERT(!msg->msg_receiving);
@@ -2389,6 +2408,314 @@ struct lnet_ni *
 	return 0;
 }
 
+static void
+lnet_resend_pending_msgs_locked(struct list_head *resendq, int cpt)
+{
+	struct lnet_msg *msg;
+
+	while (!list_empty(resendq)) {
+		struct lnet_peer_ni *lpni;
+
+		msg = list_entry(resendq->next, struct lnet_msg,
+				 msg_list);
+
+		list_del_init(&msg->msg_list);
+
+		lpni = lnet_find_peer_ni_locked(msg->msg_hdr.dest_nid);
+		if (!lpni) {
+			lnet_net_unlock(cpt);
+			CERROR("Expected that a peer is already created for %s\n",
+			       libcfs_nid2str(msg->msg_hdr.dest_nid));
+			msg->msg_no_resend = true;
+			lnet_finalize(msg, -EFAULT);
+			lnet_net_lock(cpt);
+		} else {
+			struct lnet_peer *peer;
+			int rc;
+			lnet_nid_t src_nid = LNET_NID_ANY;
+
+			/* if this message is not being routed and the
+			 * peer is non-MR then we must use the same
+			 * src_nid that was used in the original send.
+			 * Otherwise if we're routing the message (IE
+			 * we're a router) then we can use any of our
+			 * local interfaces. It doesn't matter to the
+			 * final destination.
+			 */
+			peer = lpni->lpni_peer_net->lpn_peer;
+			if (!msg->msg_routing &&
+			    !lnet_peer_is_multi_rail(peer))
+				src_nid = le64_to_cpu(msg->msg_hdr.src_nid);
+
+			/* If we originally specified a src NID, then we
+			 * must attempt to reuse it in the resend as well.
+			 */
+			if (msg->msg_src_nid_param != LNET_NID_ANY)
+				src_nid = msg->msg_src_nid_param;
+			lnet_peer_ni_decref_locked(lpni);
+
+			lnet_net_unlock(cpt);
+			rc = lnet_send(src_nid, msg, LNET_NID_ANY);
+			if (rc) {
+				CERROR("Error sending %s to %s: %d\n",
+				       lnet_msgtyp2str(msg->msg_type),
+				       libcfs_id2str(msg->msg_target), rc);
+				msg->msg_no_resend = true;
+				lnet_finalize(msg, rc);
+			}
+			lnet_net_lock(cpt);
+		}
+	}
+}
+
+static void
+lnet_resend_pending_msgs(void)
+{
+	int i;
+
+	cfs_cpt_for_each(i, lnet_cpt_table()) {
+		lnet_net_lock(i);
+		lnet_resend_pending_msgs_locked(the_lnet.ln_mt_resendqs[i], i);
+		lnet_net_unlock(i);
+	}
+}
+
+/* called with cpt and ni_lock held */
+static void
+lnet_unlink_ni_recovery_mdh_locked(struct lnet_ni *ni, int cpt)
+{
+	struct lnet_handle_md recovery_mdh;
+
+	LNetInvalidateMDHandle(&recovery_mdh);
+
+	if (ni->ni_state & LNET_NI_STATE_RECOVERY_PENDING) {
+		recovery_mdh = ni->ni_ping_mdh;
+		LNetInvalidateMDHandle(&ni->ni_ping_mdh);
+	}
+	lnet_ni_unlock(ni);
+	lnet_net_unlock(cpt);
+	if (!LNetMDHandleIsInvalid(recovery_mdh))
+		LNetMDUnlink(recovery_mdh);
+	lnet_net_lock(cpt);
+	lnet_ni_lock(ni);
+}
+
+static void
+lnet_recover_local_nis(void)
+{
+	struct list_head processed_list;
+	struct list_head local_queue;
+	struct lnet_handle_md mdh;
+	struct lnet_ni *tmp;
+	struct lnet_ni *ni;
+	lnet_nid_t nid;
+	int healthv;
+	int rc;
+
+	INIT_LIST_HEAD(&local_queue);
+	INIT_LIST_HEAD(&processed_list);
+
+	/* splice the recovery queue on a local queue. We will iterate
+	 * through the local queue and update it as needed. Once we're
+	 * done with the traversal, we'll splice the local queue back on
+	 * the head of the ln_mt_localNIRecovq. Any newly added local NIs
+	 * will be traversed in the next iteration.
+	 */
+	lnet_net_lock(0);
+	list_splice_init(&the_lnet.ln_mt_localNIRecovq,
+			 &local_queue);
+	lnet_net_unlock(0);
+
+	list_for_each_entry_safe(ni, tmp, &local_queue, ni_recovery) {
+		/* if an NI is being deleted or it is now healthy, there
+		 * is no need to keep it around in the recovery queue.
+		 * The monitor thread is the only thread responsible for
+		 * removing the NI from the recovery queue.
+		 * Multiple threads can be adding NIs to the recovery
+		 * queue.
+		 */
+		healthv = atomic_read(&ni->ni_healthv);
+
+		lnet_net_lock(0);
+		lnet_ni_lock(ni);
+		if (!(ni->ni_state & LNET_NI_STATE_ACTIVE) ||
+		    healthv == LNET_MAX_HEALTH_VALUE) {
+			list_del_init(&ni->ni_recovery);
+			lnet_unlink_ni_recovery_mdh_locked(ni, 0);
+			lnet_ni_unlock(ni);
+			lnet_ni_decref_locked(ni, 0);
+			lnet_net_unlock(0);
+			continue;
+		}
+		lnet_ni_unlock(ni);
+		lnet_net_unlock(0);
+
+		/* protect the ni->ni_state field. Once we call the
+		 * lnet_send_ping function it's possible we receive
+		 * a response before we check the rc. The lock ensures
+		 * a stable value for the ni_state RECOVERY_PENDING bit
+		 */
+		lnet_ni_lock(ni);
+		if (!(ni->ni_state & LNET_NI_STATE_RECOVERY_PENDING)) {
+			ni->ni_state |= LNET_NI_STATE_RECOVERY_PENDING;
+			lnet_ni_unlock(ni);
+			mdh = ni->ni_ping_mdh;
+			/* Invalidate the ni mdh in case it's deleted.
+			 * We'll unlink the mdh in this case below.
+			 */
+			LNetInvalidateMDHandle(&ni->ni_ping_mdh);
+			nid = ni->ni_nid;
+
+			/* remove the NI from the local queue and drop the
+			 * reference count to it while we're recovering
+			 * it. The reason for that, is that the NI could
+			 * be deleted, and the way the code is structured
+			 * is if we don't drop the NI, then the deletion
+			 * code will enter a loop waiting for the
+			 * reference count to be removed while holding the
+			 * ln_mutex_lock(). When we look up the peer to
+			 * send to in lnet_select_pathway() we will try to
+			 * lock the ln_mutex_lock() as well, leading to
+			 * a deadlock. By dropping the refcount and
+			 * removing it from the list, we allow for the NI
+			 * to be removed, then we use the cached NID to
+			 * look it up again. If it's gone, then we just
+			 * continue examining the rest of the queue.
+			 */
+			lnet_net_lock(0);
+			list_del_init(&ni->ni_recovery);
+			lnet_ni_decref_locked(ni, 0);
+			lnet_net_unlock(0);
+
+			rc = lnet_send_ping(nid, &mdh,
+					    LNET_INTERFACES_MIN, (void *)nid,
+					    the_lnet.ln_mt_eqh, true);
+			/* lookup the nid again */
+			lnet_net_lock(0);
+			ni = lnet_nid2ni_locked(nid, 0);
+			if (!ni) {
+				/* the NI has been deleted when we dropped
+				 * the ref count
+				 */
+				lnet_net_unlock(0);
+				LNetMDUnlink(mdh);
+				continue;
+			}
+			/* Same note as in lnet_recover_peer_nis(). When
+			 * we're sending the ping, the NI is free to be
+			 * deleted or manipulated. By this point it
+			 * could've been added back on the recovery queue,
+			 * and a refcount taken on it.
+			 * So we can't just add it blindly again or we'll
+			 * corrupt the queue. We must check under lock if
+			 * it's not on any list and if not then add it
+			 * to the processed list, which will eventually be
+			 * spliced back on to the recovery queue.
+			 */
+			ni->ni_ping_mdh = mdh;
+			if (list_empty(&ni->ni_recovery)) {
+				list_add_tail(&ni->ni_recovery,
+					      &processed_list);
+				lnet_ni_addref_locked(ni, 0);
+			}
+			lnet_net_unlock(0);
+
+			lnet_ni_lock(ni);
+			if (rc)
+				ni->ni_state &= ~LNET_NI_STATE_RECOVERY_PENDING;
+		}
+		lnet_ni_unlock(ni);
+	}
+
+	/* put back the remaining NIs on the ln_mt_localNIRecovq to be
+	 * reexamined in the next iteration.
+	 */
+	list_splice_init(&processed_list, &local_queue);
+	lnet_net_lock(0);
+	list_splice(&local_queue, &the_lnet.ln_mt_localNIRecovq);
+	lnet_net_unlock(0);
+}
+
+static struct list_head **
+lnet_create_array_of_queues(void)
+{
+	struct list_head **qs;
+	struct list_head *q;
+	int i;
+
+	qs = cfs_percpt_alloc(lnet_cpt_table(),
+			      sizeof(struct list_head));
+	if (!qs) {
+		CERROR("Failed to allocate queues\n");
+		return NULL;
+	}
+
+	cfs_percpt_for_each(q, i, qs)
+		INIT_LIST_HEAD(q);
+
+	return qs;
+}
+
+static int
+lnet_resendqs_create(void)
+{
+	struct list_head **resendqs;
+
+	resendqs = lnet_create_array_of_queues();
+	if (!resendqs)
+		return -ENOMEM;
+
+	lnet_net_lock(LNET_LOCK_EX);
+	the_lnet.ln_mt_resendqs = resendqs;
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	return 0;
+}
+
+static void
+lnet_clean_local_ni_recoveryq(void)
+{
+	struct lnet_ni *ni;
+
+	/* This is only called when the monitor thread has stopped */
+	lnet_net_lock(0);
+
+	while (!list_empty(&the_lnet.ln_mt_localNIRecovq)) {
+		ni = list_entry(the_lnet.ln_mt_localNIRecovq.next,
+				struct lnet_ni, ni_recovery);
+		list_del_init(&ni->ni_recovery);
+		lnet_ni_lock(ni);
+		lnet_unlink_ni_recovery_mdh_locked(ni, 0);
+		lnet_ni_unlock(ni);
+		lnet_ni_decref_locked(ni, 0);
+	}
+
+	lnet_net_unlock(0);
+}
+
+static void
+lnet_clean_resendqs(void)
+{
+	struct lnet_msg *msg, *tmp;
+	struct list_head msgs;
+	int i;
+
+	INIT_LIST_HEAD(&msgs);
+
+	cfs_cpt_for_each(i, lnet_cpt_table()) {
+		lnet_net_lock(i);
+		list_splice_init(the_lnet.ln_mt_resendqs[i], &msgs);
+		lnet_net_unlock(i);
+		list_for_each_entry_safe(msg, tmp, &msgs, msg_list) {
+			list_del_init(&msg->msg_list);
+			msg->msg_no_resend = true;
+			lnet_finalize(msg, -ESHUTDOWN);
+		}
+	}
+
+	cfs_percpt_free(the_lnet.ln_mt_resendqs);
+}
+
 static int
 lnet_monitor_thread(void *arg)
 {
@@ -2405,6 +2732,10 @@ struct lnet_ni *
 		if (lnet_router_checker_active())
 			lnet_check_routers();
 
+		lnet_resend_pending_msgs();
+
+		lnet_recover_local_nis();
+
 		/* TODO do we need to check if we should sleep without
 		 * timeout?  Technically, an active system will always
 		 * have messages in flight so this check will always
@@ -2429,42 +2760,180 @@ struct lnet_ni *
 	return 0;
 }
 
-int lnet_monitor_thr_start(void)
+/* lnet_send_ping
+ * Sends a ping.
+ * Returns == 0 if success
+ * Returns > 0 if LNetMDBind or prior fails
+ * Returns < 0 if LNetGet fails
+ */
+int
+lnet_send_ping(lnet_nid_t dest_nid,
+	       struct lnet_handle_md *mdh, int nnis,
+	       void *user_data, struct lnet_handle_eq eqh, bool recovery)
 {
+	struct lnet_md md = { NULL };
+	struct lnet_process_id id;
+	struct lnet_ping_buffer *pbuf;
 	int rc;
+
+	if (dest_nid == LNET_NID_ANY) {
+		rc = -EHOSTUNREACH;
+		goto fail_error;
+	}
+
+	pbuf = lnet_ping_buffer_alloc(nnis, GFP_NOFS);
+	if (!pbuf) {
+		rc = ENOMEM;
+		goto fail_error;
+	}
+
+	/* initialize md content */
+	md.start = &pbuf->pb_info;
+	md.length = LNET_PING_INFO_SIZE(nnis);
+	md.threshold = 2; /* GET/REPLY */
+	md.max_size = 0;
+	md.options = LNET_MD_TRUNCATE;
+	md.user_ptr = user_data;
+	md.eq_handle = eqh;
+
+	rc = LNetMDBind(md, LNET_UNLINK, mdh);
+	if (rc) {
+		lnet_ping_buffer_decref(pbuf);
+		CERROR("Can't bind MD: %d\n", rc);
+		rc = -rc; /* change the rc to positive */
+		goto fail_error;
+	}
+	id.pid = LNET_PID_LUSTRE;
+	id.nid = dest_nid;
+
+	rc = LNetGet(LNET_NID_ANY, *mdh, id,
+		     LNET_RESERVED_PORTAL,
+		     LNET_PROTO_PING_MATCHBITS, 0, recovery);
+	if (rc)
+		goto fail_unlink_md;
+
+	return 0;
+
+fail_unlink_md:
+	LNetMDUnlink(*mdh);
+	LNetInvalidateMDHandle(mdh);
+fail_error:
+	return rc;
+}
+
+static void
+lnet_mt_event_handler(struct lnet_event *event)
+{
+	lnet_nid_t nid = (lnet_nid_t)event->md.user_ptr;
+	struct lnet_ni *ni;
+	struct lnet_ping_buffer *pbuf;
+
+	/* TODO: remove assert */
+	LASSERT(event->type == LNET_EVENT_REPLY ||
+		event->type == LNET_EVENT_SEND ||
+		event->type == LNET_EVENT_UNLINK);
+
+	CDEBUG(D_NET, "Received event: %d status: %d\n", event->type,
+	       event->status);
+
+	switch (event->type) {
+	case LNET_EVENT_REPLY:
+		/* If the NI has been restored completely then remove from
+		 * the recovery queue
+		 */
+		lnet_net_lock(0);
+		ni = lnet_nid2ni_locked(nid, 0);
+		if (!ni) {
+			lnet_net_unlock(0);
+			break;
+		}
+		lnet_ni_lock(ni);
+		ni->ni_state &= ~LNET_NI_STATE_RECOVERY_PENDING;
+		lnet_ni_unlock(ni);
+		lnet_net_unlock(0);
+		break;
+	case LNET_EVENT_SEND:
+		CDEBUG(D_NET, "%s recovery message sent %s:%d\n",
+		       libcfs_nid2str(nid),
+		       (event->status) ? "unsuccessfully" :
+		       "successfully", event->status);
+		break;
+	case LNET_EVENT_UNLINK:
+		/* nothing to do */
+		CDEBUG(D_NET, "%s recovery ping unlinked\n",
+		       libcfs_nid2str(nid));
+		break;
+	default:
+		CERROR("Unexpected event: %d\n", event->type);
+		return;
+	}
+	if (event->unlinked) {
+		pbuf = LNET_PING_INFO_TO_BUFFER(event->md.start);
+		lnet_ping_buffer_decref(pbuf);
+	}
+}
+
+int lnet_monitor_thr_start(void)
+{
+	int rc = 0;
 	struct task_struct *task;
 
-	LASSERT(the_lnet.ln_mt_state == LNET_MT_STATE_SHUTDOWN);
+	if (the_lnet.ln_mt_state != LNET_MT_STATE_SHUTDOWN)
+		return -EALREADY;
 
-	init_completion(&the_lnet.ln_mt_signal);
+	rc = lnet_resendqs_create();
+	if (rc)
+		return rc;
+
+	rc = LNetEQAlloc(0, lnet_mt_event_handler, &the_lnet.ln_mt_eqh);
+	if (rc != 0) {
+		CERROR("Can't allocate monitor thread EQ: %d\n", rc);
+		goto clean_queues;
+	}
 
 	/* Pre monitor thread start processing */
 	rc = lnet_router_pre_mt_start();
-	if (!rc)
-		return rc;
+	if (rc)
+		goto free_mem;
+
+	init_completion(&the_lnet.ln_mt_signal);
 
 	the_lnet.ln_mt_state = LNET_MT_STATE_RUNNING;
 	task = kthread_run(lnet_monitor_thread, NULL, "monitor_thread");
 	if (IS_ERR(task)) {
 		rc = PTR_ERR(task);
 		CERROR("Can't start monitor thread: %d\n", rc);
-		/* block until event callback signals exit */
-		wait_for_completion(&the_lnet.ln_mt_signal);
-
-		/* clean up */
-		lnet_router_cleanup();
-		the_lnet.ln_mt_state = LNET_MT_STATE_SHUTDOWN;
-		return -ENOMEM;
+		goto clean_thread;
 	}
 
 	/* post monitor thread start processing */
 	lnet_router_post_mt_start();
 
 	return 0;
+
+clean_thread:
+	the_lnet.ln_mt_state = LNET_MT_STATE_STOPPING;
+	/* block until event callback signals exit */
+	wait_for_completion(&the_lnet.ln_mt_signal);
+	/* clean up */
+	lnet_router_cleanup();
+free_mem:
+	the_lnet.ln_mt_state = LNET_MT_STATE_SHUTDOWN;
+	lnet_clean_resendqs();
+	lnet_clean_local_ni_recoveryq();
+	LNetEQFree(the_lnet.ln_mt_eqh);
+	LNetInvalidateEQHandle(&the_lnet.ln_mt_eqh);
+	return rc;
+clean_queues:
+	lnet_clean_resendqs();
+	lnet_clean_local_ni_recoveryq();
+	return rc;
 }
 
 void lnet_monitor_thr_stop(void)
 {
+	int rc;
+
 	if (the_lnet.ln_mt_state == LNET_MT_STATE_SHUTDOWN)
 		return;
 
@@ -2478,7 +2947,12 @@ void lnet_monitor_thr_stop(void)
 	wait_for_completion(&the_lnet.ln_mt_signal);
 	LASSERT(the_lnet.ln_mt_state == LNET_MT_STATE_SHUTDOWN);
 
+	/* perform cleanup tasks */
 	lnet_router_cleanup();
+	lnet_clean_resendqs();
+	lnet_clean_local_ni_recoveryq();
+	rc = LNetEQFree(the_lnet.ln_mt_eqh);
+	LASSERT(rc == 0);
 }
 
 void
@@ -3173,6 +3647,8 @@ void lnet_monitor_thr_stop(void)
 		lnet_drop_message(msg->msg_rxni, msg->msg_rx_cpt,
 				  msg->msg_private, msg->msg_len,
 				  msg->msg_type);
+
+		msg->msg_no_resend = true;
 		/*
 		 * NB: message will not generate event because w/o attached MD,
 		 * but we still should give error code so lnet_msg_decommit()
@@ -3338,6 +3814,7 @@ void lnet_monitor_thr_stop(void)
 	if (rc) {
 		CNETERR("Error sending PUT to %s: %d\n",
 			libcfs_id2str(target), rc);
+		msg->msg_no_resend = true;
 		lnet_finalize(msg, rc);
 	}
 
@@ -3476,7 +3953,7 @@ struct lnet_msg *
 int
 LNetGet(lnet_nid_t self, struct lnet_handle_md mdh,
 	struct lnet_process_id target, unsigned int portal,
-	u64 match_bits, unsigned int offset)
+	u64 match_bits, unsigned int offset, bool recovery)
 {
 	struct lnet_msg *msg;
 	struct lnet_libmd *md;
@@ -3499,6 +3976,8 @@ struct lnet_msg *
 		return -ENOMEM;
 	}
 
+	msg->msg_recovery = recovery;
+
 	cpt = lnet_cpt_of_cookie(mdh.cookie);
 	lnet_res_lock(cpt);
 
@@ -3542,6 +4021,7 @@ struct lnet_msg *
 	if (rc < 0) {
 		CNETERR("Error sending GET to %s: %d\n",
 			libcfs_id2str(target), rc);
+		msg->msg_no_resend = true;
 		lnet_finalize(msg, rc);
 	}
 
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 7869b96..e7f7469 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -469,6 +469,234 @@
 	return 0;
 }
 
+static void
+lnet_dec_healthv_locked(atomic_t *healthv)
+{
+	int h = atomic_read(healthv);
+
+	if (h < lnet_health_sensitivity) {
+		atomic_set(healthv, 0);
+	} else {
+		h -= lnet_health_sensitivity;
+		atomic_set(healthv, h);
+	}
+}
+
+static inline void
+lnet_inc_healthv(atomic_t *healthv)
+{
+	atomic_add_unless(healthv, 1, LNET_MAX_HEALTH_VALUE);
+}
+
+static void
+lnet_handle_local_failure(struct lnet_msg *msg)
+{
+	struct lnet_ni *local_ni;
+
+	local_ni = msg->msg_txni;
+
+	/* the lnet_net_lock(0) is used to protect the addref on the ni
+	 * and the recovery queue.
+	 */
+	lnet_net_lock(0);
+	/* the mt could've shutdown and cleaned up the queues */
+	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING) {
+		lnet_net_unlock(0);
+		return;
+	}
+
+	lnet_dec_healthv_locked(&local_ni->ni_healthv);
+	/* add the NI to the recovery queue if it's not already there
+	 * and it's health value is actually below the maximum. It's
+	 * possible that the sensitivity might be set to 0, and the health
+	 * value will not be reduced. In this case, there is no reason to
+	 * invoke recovery
+	 */
+	if (list_empty(&local_ni->ni_recovery) &&
+	    atomic_read(&local_ni->ni_healthv) < LNET_MAX_HEALTH_VALUE) {
+		CERROR("ni %s added to recovery queue. Health = %d\n",
+		       libcfs_nid2str(local_ni->ni_nid),
+		       atomic_read(&local_ni->ni_healthv));
+		list_add_tail(&local_ni->ni_recovery,
+			      &the_lnet.ln_mt_localNIRecovq);
+		lnet_ni_addref_locked(local_ni, 0);
+	}
+	lnet_net_unlock(0);
+}
+
+/* Do a health check on the message:
+ * return -1 if we're not going to handle the error
+ *   success case will return -1 as well
+ * return 0 if it the message is requeued for send
+ */
+static int
+lnet_health_check(struct lnet_msg *msg)
+{
+	enum lnet_msg_hstatus hstatus = msg->msg_health_status;
+
+	/* TODO: lnet_incr_hstats(hstatus); */
+
+	LASSERT(msg->msg_txni);
+
+	if (hstatus != LNET_MSG_STATUS_OK &&
+	    ktime_compare(ktime_get(), msg->msg_deadline) >= 0)
+		return -1;
+
+	/* if we're shutting down no point in handling health. */
+	if (the_lnet.ln_state != LNET_STATE_RUNNING)
+		return -1;
+
+	switch (hstatus) {
+	case LNET_MSG_STATUS_OK:
+		lnet_inc_healthv(&msg->msg_txni->ni_healthv);
+		/* we can finalize this message */
+		return -1;
+	case LNET_MSG_STATUS_LOCAL_INTERRUPT:
+	case LNET_MSG_STATUS_LOCAL_DROPPED:
+	case LNET_MSG_STATUS_LOCAL_ABORTED:
+	case LNET_MSG_STATUS_LOCAL_NO_ROUTE:
+	case LNET_MSG_STATUS_LOCAL_TIMEOUT:
+		lnet_handle_local_failure(msg);
+		/* add to the re-send queue */
+		goto resend;
+
+		/* TODO: since the remote dropped the message we can
+		 * attempt a resend safely.
+		 */
+	case LNET_MSG_STATUS_REMOTE_DROPPED:
+		break;
+
+		/* These errors will not trigger a resend so simply
+		 * finalize the message
+		 */
+	case LNET_MSG_STATUS_LOCAL_ERROR:
+		lnet_handle_local_failure(msg);
+		return -1;
+	case LNET_MSG_STATUS_REMOTE_ERROR:
+	case LNET_MSG_STATUS_REMOTE_TIMEOUT:
+	case LNET_MSG_STATUS_NETWORK_TIMEOUT:
+		return -1;
+	}
+
+resend:
+	/* don't resend recovery messages */
+	if (msg->msg_recovery)
+		return -1;
+
+	/* if we explicitly indicated we don't want to resend then just
+	 * return
+	 */
+	if (msg->msg_no_resend)
+		return -1;
+
+	lnet_net_lock(msg->msg_tx_cpt);
+
+	/* remove message from the active list and reset it in preparation
+	 * for a resend. Two exception to this
+	 *
+	 * 1. the router case, when a message is committed for rx when
+	 * received, then tx when it is sent. When committed to both tx and
+	 * rx we don't want to remove it from the active list.
+	 *
+	 * 2. The REPLY case since it uses the same msg block for the GET
+	 * that was received.
+	 */
+	if (!msg->msg_routing && msg->msg_type != LNET_MSG_REPLY) {
+		list_del_init(&msg->msg_activelist);
+		msg->msg_onactivelist = 0;
+	}
+
+	/* The msg_target.nid which was originally set
+	 * when calling LNetGet() or LNetPut() might've
+	 * been overwritten if we're routing this message.
+	 * Call lnet_return_tx_credits_locked() to return
+	 * the credit this message consumed. The message will
+	 * consume another credit when it gets resent.
+	 */
+	msg->msg_target.nid = msg->msg_hdr.dest_nid;
+	lnet_msg_decommit_tx(msg, -EAGAIN);
+	msg->msg_sending = 0;
+	msg->msg_receiving = 0;
+	msg->msg_target_is_router = 0;
+
+	CDEBUG(D_NET, "%s->%s:%s:%s - queuing for resend\n",
+	       libcfs_nid2str(msg->msg_hdr.src_nid),
+	       libcfs_nid2str(msg->msg_hdr.dest_nid),
+	       lnet_msgtyp2str(msg->msg_type),
+	       lnet_health_error2str(hstatus));
+
+	list_add_tail(&msg->msg_list, the_lnet.ln_mt_resendqs[msg->msg_tx_cpt]);
+	lnet_net_unlock(msg->msg_tx_cpt);
+
+	wake_up(&the_lnet.ln_mt_waitq);
+	return 0;
+}
+
+static void
+lnet_detach_md(struct lnet_msg *msg, int status)
+{
+	int cpt = lnet_cpt_of_cookie(msg->msg_md->md_lh.lh_cookie);
+
+	lnet_res_lock(cpt);
+	lnet_msg_detach_md(msg, status);
+	lnet_res_unlock(cpt);
+}
+
+static bool
+lnet_is_health_check(struct lnet_msg *msg)
+{
+	bool hc;
+	int status = msg->msg_ev.status;
+
+	/* perform a health check for any message committed for transmit */
+	hc = msg->msg_tx_committed;
+
+	/* Check for status inconsistencies */
+	if (hc &&
+	    ((!status && msg->msg_health_status != LNET_MSG_STATUS_OK) ||
+	     (status && msg->msg_health_status == LNET_MSG_STATUS_OK))) {
+		CERROR("Msg is in inconsistent state, don't perform health checking (%d, %d)\n",
+		       status, msg->msg_health_status);
+		hc = false;
+	}
+
+	CDEBUG(D_NET, "health check = %d, status = %d, hstatus = %d\n",
+	       hc, status, msg->msg_health_status);
+
+	return hc;
+}
+
+char *
+lnet_health_error2str(enum lnet_msg_hstatus hstatus)
+{
+	switch (hstatus) {
+	case LNET_MSG_STATUS_LOCAL_INTERRUPT:
+		return "LOCAL_INTERRUPT";
+	case LNET_MSG_STATUS_LOCAL_DROPPED:
+		return "LOCAL_DROPPED";
+	case LNET_MSG_STATUS_LOCAL_ABORTED:
+		return "LOCAL_ABORTED";
+	case LNET_MSG_STATUS_LOCAL_NO_ROUTE:
+		return "LOCAL_NO_ROUTE";
+	case LNET_MSG_STATUS_LOCAL_TIMEOUT:
+		return "LOCAL_TIMEOUT";
+	case LNET_MSG_STATUS_LOCAL_ERROR:
+		return "LOCAL_ERROR";
+	case LNET_MSG_STATUS_REMOTE_DROPPED:
+		return "REMOTE_DROPPED";
+	case LNET_MSG_STATUS_REMOTE_ERROR:
+		return "REMOTE_ERROR";
+	case LNET_MSG_STATUS_REMOTE_TIMEOUT:
+		return "REMOTE_TIMEOUT";
+	case LNET_MSG_STATUS_NETWORK_TIMEOUT:
+		return "NETWORK_TIMEOUT";
+	case LNET_MSG_STATUS_OK:
+		return "OK";
+	default:
+		return "<UNKNOWN>";
+	}
+}
+
 void
 lnet_finalize(struct lnet_msg *msg, int status)
 {
@@ -477,6 +705,7 @@
 	int cpt;
 	int rc;
 	int i;
+	bool hc;
 
 	LASSERT(!in_interrupt());
 
@@ -485,15 +714,27 @@
 
 	msg->msg_ev.status = status;
 
-	if (msg->msg_md) {
-		cpt = lnet_cpt_of_cookie(msg->msg_md->md_lh.lh_cookie);
-
-		lnet_res_lock(cpt);
-		lnet_msg_detach_md(msg, status);
-		lnet_res_unlock(cpt);
-	}
+	/* if the message is successfully sent, no need to keep the MD around */
+	if (msg->msg_md && !status)
+		lnet_detach_md(msg, status);
 
 again:
+	hc = lnet_is_health_check(msg);
+
+	/* the MD would've been detached from the message if it was
+	 * successfully sent. However, if it wasn't successfully sent the
+	 * MD would be around. And since we recalculate whether to
+	 * health check or not, it's possible that we change our minds and
+	 * we don't want to health check this message. In this case also
+	 * free the MD.
+	 *
+	 * If the message is successful we're going to
+	 * go through the lnet_health_check() function, but that'll just
+	 * increment the appropriate health value and return.
+	 */
+	if (msg->msg_md && !hc)
+		lnet_detach_md(msg, status);
+
 	rc = 0;
 	if (!msg->msg_tx_committed && !msg->msg_rx_committed) {
 		/* not committed to network yet */
@@ -502,6 +743,28 @@
 		return;
 	}
 
+	if (hc) {
+		/* Check the health status of the message. If it has one
+		 * of the errors that we're supposed to handle, and it has
+		 * not timed out, then
+		 *	1. Decrement the appropriate health_value
+		 *	2. queue the message on the resend queue
+		 *
+		 * if the message send is success, timed out or failed in the
+		 * health check for any reason then we'll just finalize the
+		 * message. Otherwise just return since the message has been
+		 * put on the resend queue.
+		 */
+		if (!lnet_health_check(msg))
+			return;
+
+		/* if we get here then we need to clean up the md because we're
+		 * finalizing the message.
+		 */
+		if (msg->msg_md)
+			lnet_detach_md(msg, status);
+	}
+
 	/*
 	 * NB: routed message can be committed for both receiving and sending,
 	 * we should finalize in LIFO order and keep counters correct.
@@ -536,7 +799,7 @@
 	while ((msg = list_first_entry_or_null(&container->msc_finalizing,
 					       struct lnet_msg,
 					       msg_list)) != NULL) {
-		list_del(&msg->msg_list);
+		list_del_init(&msg->msg_list);
 
 		/*
 		 * NB drops and regains the lnet lock if it actually does
@@ -575,7 +838,7 @@
 					       msg_activelist)) != NULL) {
 		LASSERT(msg->msg_onactivelist);
 		msg->msg_onactivelist = 0;
-		list_del(&msg->msg_activelist);
+		list_del_init(&msg->msg_activelist);
 		kfree(msg);
 		count++;
 	}
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 1534ab2..121876e 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2713,9 +2713,7 @@ static lnet_nid_t lnet_peer_select_nid(struct lnet_peer *lp)
 static int lnet_peer_send_ping(struct lnet_peer *lp)
 __must_hold(&lp->lp_lock)
 {
-	struct lnet_md md = { NULL };
-	struct lnet_process_id id;
-	struct lnet_ping_buffer *pbuf;
+	lnet_nid_t pnid;
 	int nnis;
 	int rc;
 	int cpt;
@@ -2724,54 +2722,35 @@ static int lnet_peer_send_ping(struct lnet_peer *lp)
 	lp->lp_state &= ~LNET_PEER_FORCE_PING;
 	spin_unlock(&lp->lp_lock);
 
-	nnis = max_t(int, lp->lp_data_nnis, LNET_INTERFACES_MIN);
-	pbuf = lnet_ping_buffer_alloc(nnis, GFP_NOFS);
-	if (!pbuf) {
-		rc = -ENOMEM;
-		goto fail_error;
-	}
-
-	/* initialize md content */
-	md.start = &pbuf->pb_info;
-	md.length = LNET_PING_INFO_SIZE(nnis);
-	md.threshold = 2; /* GET/REPLY */
-	md.max_size = 0;
-	md.options = LNET_MD_TRUNCATE;
-	md.user_ptr = lp;
-	md.eq_handle = the_lnet.ln_dc_eqh;
-
-	rc = LNetMDBind(md, LNET_UNLINK, &lp->lp_ping_mdh);
-	if (rc != 0) {
-		lnet_ping_buffer_decref(pbuf);
-		CERROR("Can't bind MD: %d\n", rc);
-		goto fail_error;
-	}
 	cpt = lnet_net_lock_current();
 	/* Refcount for MD. */
 	lnet_peer_addref_locked(lp);
-	id.pid = LNET_PID_LUSTRE;
-	id.nid = lnet_peer_select_nid(lp);
+	pnid = lnet_peer_select_nid(lp);
 	lnet_net_unlock(cpt);
 
-	if (id.nid == LNET_NID_ANY) {
-		rc = -EHOSTUNREACH;
-		goto fail_unlink_md;
-	}
+	nnis = max_t(int, lp->lp_data_nnis, LNET_INTERFACES_MIN);
 
-	rc = LNetGet(LNET_NID_ANY, lp->lp_ping_mdh, id,
-		     LNET_RESERVED_PORTAL,
-		     LNET_PROTO_PING_MATCHBITS, 0);
-	if (rc)
-		goto fail_unlink_md;
+	rc = lnet_send_ping(pnid, &lp->lp_ping_mdh, nnis, lp,
+			    the_lnet.ln_dc_eqh, false);
+	/* if LNetMDBind in lnet_send_ping fails we need to decrement the
+	 * refcount on the peer, otherwise LNetMDUnlink will be called
+	 * which will eventually do that.
+	 */
+	if (rc > 0) {
+		lnet_net_lock(cpt);
+		lnet_peer_decref_locked(lp);
+		lnet_net_unlock(cpt);
+		rc = -rc; /* change the rc to negative value */
+		goto fail_error;
+	} else if (rc < 0) {
+		goto fail_error;
+	}
 
 	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
 
 	spin_lock(&lp->lp_lock);
 	return 0;
 
-fail_unlink_md:
-	LNetMDUnlink(lp->lp_ping_mdh);
-	LNetInvalidateMDHandle(&lp->lp_ping_mdh);
 fail_error:
 	CDEBUG(D_NET, "peer %s: %d\n", libcfs_nid2str(lp->lp_primary_nid), rc);
 	/*
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 3f9d8c5..7c3bbd8 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1079,7 +1079,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 		lnet_net_unlock(rtr->lpni_cpt);
 
 		rc = LNetGet(LNET_NID_ANY, mdh, id, LNET_RESERVED_PORTAL,
-			     LNET_PROTO_PING_MATCHBITS, 0);
+			     LNET_PROTO_PING_MATCHBITS, 0, false);
 
 		lnet_net_lock(rtr->lpni_cpt);
 		if (rc)
diff --git a/net/lnet/selftest/rpc.c b/net/lnet/selftest/rpc.c
index 295d704..a5941e4 100644
--- a/net/lnet/selftest/rpc.c
+++ b/net/lnet/selftest/rpc.c
@@ -425,7 +425,7 @@ struct srpc_bulk *
 	} else {
 		LASSERT(options & LNET_MD_OP_GET);
 
-		rc = LNetGet(self, *mdh, peer, portal, matchbits, 0);
+		rc = LNetGet(self, *mdh, peer, portal, matchbits, 0, false);
 	}
 
 	if (rc) {
-- 
1.8.3.1
