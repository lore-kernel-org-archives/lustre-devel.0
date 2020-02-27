From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:10 -0500
Subject: [lustre-devel] [PATCH 082/622] lnet: handle remote errors in LNet
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-83-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Add health value in the peer NI structure. Decrement the
value whenever there is an error sending to the peer.
Modify the selection algorithm to look at the peer NI health
value when selecting the best peer NI to send to.

Put the peer NI on the recovery queue whenever there is
an error sending to it. Attempt only to resend on REMOTE
DROPPED since we're sure the message was never received by
the peer. For other errors finalize the message.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 76fad19c2dea ("LU-9120 lnet: handle remote errors in LNet")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32767
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |   6 +
 include/linux/lnet/lib-types.h |  12 ++
 net/lnet/lnet/api-ni.c         |   1 +
 net/lnet/lnet/lib-move.c       | 311 +++++++++++++++++++++++++++++++++++------
 net/lnet/lnet/lib-msg.c        |  87 ++++++++++--
 net/lnet/lnet/peer.c           |   9 ++
 6 files changed, 368 insertions(+), 58 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 965fc5f..b8ca114 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -894,6 +894,12 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 	return false;
 }
 
+static inline void
+lnet_inc_healthv(atomic_t *healthv)
+{
+	atomic_add_unless(healthv, 1, LNET_MAX_HEALTH_VALUE);
+}
+
 void lnet_incr_stats(struct lnet_element_stats *stats,
 		     enum lnet_msg_type msg_type,
 		     enum lnet_stats_type stats_type);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 8c3bf34..19b83a4 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -478,6 +478,8 @@ struct lnet_peer_ni {
 	struct list_head	 lpni_peer_nis;
 	/* chain on remote peer list */
 	struct list_head	 lpni_on_remote_peer_ni_list;
+	/* chain on recovery queue */
+	struct list_head	 lpni_recovery;
 	/* chain on peer hash */
 	struct list_head	 lpni_hashlist;
 	/* messages blocking for tx credits */
@@ -529,6 +531,10 @@ struct lnet_peer_ni {
 	lnet_nid_t		 lpni_nid;
 	/* # refs */
 	atomic_t		 lpni_refcount;
+	/* health value for the peer */
+	atomic_t		 lpni_healthv;
+	/* recovery ping mdh */
+	struct lnet_handle_md	 lpni_recovery_ping_mdh;
 	/* CPT this peer attached on */
 	int			 lpni_cpt;
 	/* state flags -- protected by lpni_lock */
@@ -558,6 +564,10 @@ struct lnet_peer_ni {
 
 /* Preferred path added due to traffic on non-MR peer_ni */
 #define LNET_PEER_NI_NON_MR_PREF	BIT(0)
+/* peer is being recovered. */
+#define LNET_PEER_NI_RECOVERY_PENDING	BIT(1)
+/* peer is being deleted */
+#define LNET_PEER_NI_DELETING		BIT(2)
 
 struct lnet_peer {
 	/* chain on pt_peer_list */
@@ -1088,6 +1098,8 @@ struct lnet {
 	struct list_head		**ln_mt_resendqs;
 	/* local NIs to recover */
 	struct list_head		ln_mt_localNIRecovq;
+	/* local NIs to recover */
+	struct list_head		ln_mt_peerNIRecovq;
 	/* recovery eq handler */
 	struct lnet_handle_eq		ln_mt_eqh;
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index deef404..97d9be5 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -832,6 +832,7 @@ struct lnet_libhandle *
 	INIT_LIST_HEAD(&the_lnet.ln_dc_working);
 	INIT_LIST_HEAD(&the_lnet.ln_dc_expired);
 	INIT_LIST_HEAD(&the_lnet.ln_mt_localNIRecovq);
+	INIT_LIST_HEAD(&the_lnet.ln_mt_peerNIRecovq);
 	init_waitqueue_head(&the_lnet.ln_dc_waitq);
 
 	rc = lnet_descriptor_setup();
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index f3f4b84..5224490 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1025,15 +1025,6 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	}
 
 	if (txpeer) {
-		/*
-		 * TODO:
-		 * Once the patch for the health comes in we need to set
-		 * the health of the peer ni to bad when we fail to send
-		 * a message.
-		 * int status = msg->msg_ev.status;
-		 * if (status != 0)
-		 *	lnet_set_peer_ni_health_locked(txpeer, false)
-		 */
 		msg->msg_txpeer = NULL;
 		lnet_peer_ni_decref_locked(txpeer);
 	}
@@ -1545,6 +1536,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	int best_lpni_credits = INT_MIN;
 	bool preferred = false;
 	bool ni_is_pref;
+	int best_lpni_healthv = 0;
+	int lpni_healthv;
 
 	while ((lpni = lnet_get_next_peer_ni_locked(peer, peer_net, lpni))) {
 		/* if the best_ni we've chosen aleady has this lpni
@@ -1553,6 +1546,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		ni_is_pref = lnet_peer_is_pref_nid_locked(lpni,
 							  best_ni->ni_nid);
 
+		lpni_healthv = atomic_read(&lpni->lpni_healthv);
+
 		CDEBUG(D_NET, "%s ni_is_pref = %d\n",
 		       libcfs_nid2str(best_ni->ni_nid), ni_is_pref);
 
@@ -1562,8 +1557,13 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 			       lpni->lpni_txcredits, best_lpni_credits,
 			       lpni->lpni_seq, best_lpni->lpni_seq);
 
+		/* pick the healthiest peer ni */
+		if (lpni_healthv < best_lpni_healthv) {
+			continue;
+		} else if (lpni_healthv > best_lpni_healthv) {
+			best_lpni_healthv = lpni_healthv;
 		/* if this is a preferred peer use it */
-		if (!preferred && ni_is_pref) {
+		} else if (!preferred && ni_is_pref) {
 			preferred = true;
 		} else if (preferred && !ni_is_pref) {
 			/*
@@ -2408,6 +2408,16 @@ struct lnet_ni *
 	return 0;
 }
 
+enum lnet_mt_event_type {
+	MT_TYPE_LOCAL_NI = 0,
+	MT_TYPE_PEER_NI
+};
+
+struct lnet_mt_event_info {
+	enum lnet_mt_event_type mt_type;
+	lnet_nid_t mt_nid;
+};
+
 static void
 lnet_resend_pending_msgs_locked(struct list_head *resendq, int cpt)
 {
@@ -2503,6 +2513,7 @@ struct lnet_ni *
 static void
 lnet_recover_local_nis(void)
 {
+	struct lnet_mt_event_info *ev_info;
 	struct list_head processed_list;
 	struct list_head local_queue;
 	struct lnet_handle_md mdh;
@@ -2550,15 +2561,24 @@ struct lnet_ni *
 		lnet_ni_unlock(ni);
 		lnet_net_unlock(0);
 
-		/* protect the ni->ni_state field. Once we call the
-		 * lnet_send_ping function it's possible we receive
-		 * a response before we check the rc. The lock ensures
-		 * a stable value for the ni_state RECOVERY_PENDING bit
-		 */
+		CDEBUG(D_NET, "attempting to recover local ni: %s\n",
+		       libcfs_nid2str(ni->ni_nid));
+
 		lnet_ni_lock(ni);
 		if (!(ni->ni_state & LNET_NI_STATE_RECOVERY_PENDING)) {
 			ni->ni_state |= LNET_NI_STATE_RECOVERY_PENDING;
 			lnet_ni_unlock(ni);
+
+			ev_info = kzalloc(sizeof(*ev_info), GFP_NOFS);
+			if (!ev_info) {
+				CERROR("out of memory. Can't recover %s\n",
+				       libcfs_nid2str(ni->ni_nid));
+				lnet_ni_lock(ni);
+				ni->ni_state &= ~LNET_NI_STATE_RECOVERY_PENDING;
+				lnet_ni_unlock(ni);
+				continue;
+			}
+
 			mdh = ni->ni_ping_mdh;
 			/* Invalidate the ni mdh in case it's deleted.
 			 * We'll unlink the mdh in this case below.
@@ -2587,9 +2607,10 @@ struct lnet_ni *
 			lnet_ni_decref_locked(ni, 0);
 			lnet_net_unlock(0);
 
-			rc = lnet_send_ping(nid, &mdh,
-					    LNET_INTERFACES_MIN, (void *)nid,
-					    the_lnet.ln_mt_eqh, true);
+			ev_info->mt_type = MT_TYPE_LOCAL_NI;
+			ev_info->mt_nid = nid;
+			rc = lnet_send_ping(nid, &mdh, LNET_INTERFACES_MIN,
+					    ev_info, the_lnet.ln_mt_eqh, true);
 			/* lookup the nid again */
 			lnet_net_lock(0);
 			ni = lnet_nid2ni_locked(nid, 0);
@@ -2694,6 +2715,44 @@ struct lnet_ni *
 }
 
 static void
+lnet_unlink_lpni_recovery_mdh_locked(struct lnet_peer_ni *lpni, int cpt)
+{
+	struct lnet_handle_md recovery_mdh;
+
+	LNetInvalidateMDHandle(&recovery_mdh);
+
+	if (lpni->lpni_state & LNET_PEER_NI_RECOVERY_PENDING) {
+		recovery_mdh = lpni->lpni_recovery_ping_mdh;
+		LNetInvalidateMDHandle(&lpni->lpni_recovery_ping_mdh);
+	}
+	spin_unlock(&lpni->lpni_lock);
+	lnet_net_unlock(cpt);
+	if (!LNetMDHandleIsInvalid(recovery_mdh))
+		LNetMDUnlink(recovery_mdh);
+	lnet_net_lock(cpt);
+	spin_lock(&lpni->lpni_lock);
+}
+
+static void
+lnet_clean_peer_ni_recoveryq(void)
+{
+	struct lnet_peer_ni *lpni, *tmp;
+
+	lnet_net_lock(LNET_LOCK_EX);
+
+	list_for_each_entry_safe(lpni, tmp, &the_lnet.ln_mt_peerNIRecovq,
+				 lpni_recovery) {
+		list_del_init(&lpni->lpni_recovery);
+		spin_lock(&lpni->lpni_lock);
+		lnet_unlink_lpni_recovery_mdh_locked(lpni, LNET_LOCK_EX);
+		spin_unlock(&lpni->lpni_lock);
+		lnet_peer_ni_decref_locked(lpni);
+	}
+
+	lnet_net_unlock(LNET_LOCK_EX);
+}
+
+static void
 lnet_clean_resendqs(void)
 {
 	struct lnet_msg *msg, *tmp;
@@ -2716,6 +2775,128 @@ struct lnet_ni *
 	cfs_percpt_free(the_lnet.ln_mt_resendqs);
 }
 
+static void
+lnet_recover_peer_nis(void)
+{
+	struct lnet_mt_event_info *ev_info;
+	struct list_head processed_list;
+	struct list_head local_queue;
+	struct lnet_handle_md mdh;
+	struct lnet_peer_ni *lpni;
+	struct lnet_peer_ni *tmp;
+	lnet_nid_t nid;
+	int healthv;
+	int rc;
+
+	INIT_LIST_HEAD(&local_queue);
+	INIT_LIST_HEAD(&processed_list);
+
+	/* Always use cpt 0 for locking across all interactions with
+	 * ln_mt_peerNIRecovq
+	 */
+	lnet_net_lock(0);
+	list_splice_init(&the_lnet.ln_mt_peerNIRecovq,
+			 &local_queue);
+	lnet_net_unlock(0);
+
+	list_for_each_entry_safe(lpni, tmp, &local_queue,
+				 lpni_recovery) {
+		/* The same protection strategy is used here as is in the
+		 * local recovery case.
+		 */
+		lnet_net_lock(0);
+		healthv = atomic_read(&lpni->lpni_healthv);
+		spin_lock(&lpni->lpni_lock);
+		if (lpni->lpni_state & LNET_PEER_NI_DELETING ||
+		    healthv == LNET_MAX_HEALTH_VALUE) {
+			list_del_init(&lpni->lpni_recovery);
+			lnet_unlink_lpni_recovery_mdh_locked(lpni, 0);
+			spin_unlock(&lpni->lpni_lock);
+			lnet_peer_ni_decref_locked(lpni);
+			lnet_net_unlock(0);
+			continue;
+		}
+		spin_unlock(&lpni->lpni_lock);
+		lnet_net_unlock(0);
+
+		/* NOTE: we're racing with peer deletion from user space.
+		 * It's possible that a peer is deleted after we check its
+		 * state. In this case the recovery can create a new peer
+		 */
+		spin_lock(&lpni->lpni_lock);
+		if (!(lpni->lpni_state & LNET_PEER_NI_RECOVERY_PENDING) &&
+		    !(lpni->lpni_state & LNET_PEER_NI_DELETING)) {
+			lpni->lpni_state |= LNET_PEER_NI_RECOVERY_PENDING;
+			spin_unlock(&lpni->lpni_lock);
+
+			ev_info = kzalloc(sizeof(*ev_info), GFP_NOFS);
+			if (!ev_info) {
+				CERROR("out of memory. Can't recover %s\n",
+				       libcfs_nid2str(lpni->lpni_nid));
+				spin_lock(&lpni->lpni_lock);
+				lpni->lpni_state &=
+					~LNET_PEER_NI_RECOVERY_PENDING;
+				spin_unlock(&lpni->lpni_lock);
+				continue;
+			}
+
+			/* look at the comments in lnet_recover_local_nis() */
+			mdh = lpni->lpni_recovery_ping_mdh;
+			LNetInvalidateMDHandle(&lpni->lpni_recovery_ping_mdh);
+			nid = lpni->lpni_nid;
+			lnet_net_lock(0);
+			list_del_init(&lpni->lpni_recovery);
+			lnet_peer_ni_decref_locked(lpni);
+			lnet_net_unlock(0);
+
+			ev_info->mt_type = MT_TYPE_PEER_NI;
+			ev_info->mt_nid = nid;
+			rc = lnet_send_ping(nid, &mdh, LNET_INTERFACES_MIN,
+					    ev_info, the_lnet.ln_mt_eqh, true);
+			lnet_net_lock(0);
+			/* lnet_find_peer_ni_locked() grabs a refcount for
+			 * us. No need to take it explicitly.
+			 */
+			lpni = lnet_find_peer_ni_locked(nid);
+			if (!lpni) {
+				lnet_net_unlock(0);
+				LNetMDUnlink(mdh);
+				continue;
+			}
+
+			lpni->lpni_recovery_ping_mdh = mdh;
+			/* While we're unlocked the lpni could've been
+			 * readded on the recovery queue. In this case we
+			 * don't need to add it to the local queue, since
+			 * it's already on there and the thread that added
+			 * it would've incremented the refcount on the
+			 * peer, which means we need to decref the refcount
+			 * that was implicitly grabbed by find_peer_ni_locked.
+			 * Otherwise, if the lpni is still not on
+			 * the recovery queue, then we'll add it to the
+			 * processed list.
+			 */
+			if (list_empty(&lpni->lpni_recovery))
+				list_add_tail(&lpni->lpni_recovery,
+					      &processed_list);
+			else
+				lnet_peer_ni_decref_locked(lpni);
+			lnet_net_unlock(0);
+
+			spin_lock(&lpni->lpni_lock);
+			if (rc)
+				lpni->lpni_state &=
+					~LNET_PEER_NI_RECOVERY_PENDING;
+		}
+		spin_unlock(&lpni->lpni_lock);
+	}
+
+	list_splice_init(&processed_list, &local_queue);
+	lnet_net_lock(0);
+	list_splice(&local_queue, &the_lnet.ln_mt_peerNIRecovq);
+	lnet_net_unlock(0);
+}
+
 static int
 lnet_monitor_thread(void *arg)
 {
@@ -2736,6 +2917,8 @@ struct lnet_ni *
 
 		lnet_recover_local_nis();
 
+		lnet_recover_peer_nis();
+
 		/* TODO do we need to check if we should sleep without
 		 * timeout?  Technically, an active system will always
 		 * have messages in flight so this check will always
@@ -2822,10 +3005,61 @@ struct lnet_ni *
 }
 
 static void
+lnet_handle_recovery_reply(struct lnet_mt_event_info *ev_info,
+			   int status)
+{
+	lnet_nid_t nid = ev_info->mt_nid;
+
+	if (ev_info->mt_type == MT_TYPE_LOCAL_NI) {
+		struct lnet_ni *ni;
+
+		lnet_net_lock(0);
+		ni = lnet_nid2ni_locked(nid, 0);
+		if (!ni) {
+			lnet_net_unlock(0);
+			return;
+		}
+		lnet_ni_lock(ni);
+		ni->ni_state &= ~LNET_NI_STATE_RECOVERY_PENDING;
+		lnet_ni_unlock(ni);
+		lnet_net_unlock(0);
+
+		if (status != 0) {
+			CERROR("local NI recovery failed with %d\n", status);
+			return;
+		}
+		/* need to increment healthv for the ni here, because in
+		 * the lnet_finalize() path we don't have access to this
+		 * NI. And in order to get access to it, we'll need to
+		 * carry forward too much information.
+		 * In the peer case, it'll naturally be incremented
+		 */
+		lnet_inc_healthv(&ni->ni_healthv);
+	} else {
+		struct lnet_peer_ni *lpni;
+		int cpt;
+
+		cpt = lnet_net_lock_current();
+		lpni = lnet_find_peer_ni_locked(nid);
+		if (!lpni) {
+			lnet_net_unlock(cpt);
+			return;
+		}
+		spin_lock(&lpni->lpni_lock);
+		lpni->lpni_state &= ~LNET_PEER_NI_RECOVERY_PENDING;
+		spin_unlock(&lpni->lpni_lock);
+		lnet_peer_ni_decref_locked(lpni);
+		lnet_net_unlock(cpt);
+
+		if (status != 0)
+			CERROR("peer NI recovery failed with %d\n", status);
+	}
+}
+
+static void
 lnet_mt_event_handler(struct lnet_event *event)
 {
-	lnet_nid_t nid = (lnet_nid_t)event->md.user_ptr;
-	struct lnet_ni *ni;
+	struct lnet_mt_event_info *ev_info = event->md.user_ptr;
 	struct lnet_ping_buffer *pbuf;
 
 	/* TODO: remove assert */
@@ -2837,37 +3071,25 @@ struct lnet_ni *
 	       event->status);
 
 	switch (event->type) {
+	case LNET_EVENT_UNLINK:
+		CDEBUG(D_NET, "%s recovery ping unlinked\n",
+		       libcfs_nid2str(ev_info->mt_nid));
+		/* fall-through */
 	case LNET_EVENT_REPLY:
-		/* If the NI has been restored completely then remove from
-		 * the recovery queue
-		 */
-		lnet_net_lock(0);
-		ni = lnet_nid2ni_locked(nid, 0);
-		if (!ni) {
-			lnet_net_unlock(0);
-			break;
-		}
-		lnet_ni_lock(ni);
-		ni->ni_state &= ~LNET_NI_STATE_RECOVERY_PENDING;
-		lnet_ni_unlock(ni);
-		lnet_net_unlock(0);
+		lnet_handle_recovery_reply(ev_info, event->status);
 		break;
 	case LNET_EVENT_SEND:
 		CDEBUG(D_NET, "%s recovery message sent %s:%d\n",
-		       libcfs_nid2str(nid),
+		       libcfs_nid2str(ev_info->mt_nid),
 		       (event->status) ? "unsuccessfully" :
 		       "successfully", event->status);
 		break;
-	case LNET_EVENT_UNLINK:
-		/* nothing to do */
-		CDEBUG(D_NET, "%s recovery ping unlinked\n",
-		       libcfs_nid2str(nid));
-		break;
 	default:
 		CERROR("Unexpected event: %d\n", event->type);
-		return;
+		break;
 	}
 	if (event->unlinked) {
+		kfree(ev_info);
 		pbuf = LNET_PING_INFO_TO_BUFFER(event->md.start);
 		lnet_ping_buffer_decref(pbuf);
 	}
@@ -2919,14 +3141,16 @@ int lnet_monitor_thr_start(void)
 	lnet_router_cleanup();
 free_mem:
 	the_lnet.ln_mt_state = LNET_MT_STATE_SHUTDOWN;
-	lnet_clean_resendqs();
 	lnet_clean_local_ni_recoveryq();
+	lnet_clean_peer_ni_recoveryq();
+	lnet_clean_resendqs();
 	LNetEQFree(the_lnet.ln_mt_eqh);
 	LNetInvalidateEQHandle(&the_lnet.ln_mt_eqh);
 	return rc;
 clean_queues:
-	lnet_clean_resendqs();
 	lnet_clean_local_ni_recoveryq();
+	lnet_clean_peer_ni_recoveryq();
+	lnet_clean_resendqs();
 	return rc;
 }
 
@@ -2949,8 +3173,9 @@ void lnet_monitor_thr_stop(void)
 
 	/* perform cleanup tasks */
 	lnet_router_cleanup();
-	lnet_clean_resendqs();
 	lnet_clean_local_ni_recoveryq();
+	lnet_clean_peer_ni_recoveryq();
+	lnet_clean_resendqs();
 	rc = LNetEQFree(the_lnet.ln_mt_eqh);
 	LASSERT(rc == 0);
 }
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index e7f7469..046923b 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -482,12 +482,6 @@
 	}
 }
 
-static inline void
-lnet_inc_healthv(atomic_t *healthv)
-{
-	atomic_add_unless(healthv, 1, LNET_MAX_HEALTH_VALUE);
-}
-
 static void
 lnet_handle_local_failure(struct lnet_msg *msg)
 {
@@ -524,6 +518,43 @@
 	lnet_net_unlock(0);
 }
 
+static void
+lnet_handle_remote_failure(struct lnet_msg *msg)
+{
+	struct lnet_peer_ni *lpni;
+
+	lpni = msg->msg_txpeer;
+
+	/* lpni could be NULL if we're in the LOLND case */
+	if (!lpni)
+		return;
+
+	lnet_net_lock(0);
+	/* the mt could've shutdown and cleaned up the queues */
+	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING) {
+		lnet_net_unlock(0);
+		return;
+	}
+
+	lnet_dec_healthv_locked(&lpni->lpni_healthv);
+	/* add the peer NI to the recovery queue if it's not already there
+	 * and it's health value is actually below the maximum. It's
+	 * possible that the sensitivity might be set to 0, and the health
+	 * value will not be reduced. In this case, there is no reason to
+	 * invoke recovery
+	 */
+	if (list_empty(&lpni->lpni_recovery) &&
+	    atomic_read(&lpni->lpni_healthv) < LNET_MAX_HEALTH_VALUE) {
+		CERROR("lpni %s added to recovery queue. Health = %d\n",
+		       libcfs_nid2str(lpni->lpni_nid),
+		       atomic_read(&lpni->lpni_healthv));
+		list_add_tail(&lpni->lpni_recovery,
+			      &the_lnet.ln_mt_peerNIRecovq);
+		lnet_peer_ni_addref_locked(lpni);
+	}
+	lnet_net_unlock(0);
+}
+
 /* Do a health check on the message:
  * return -1 if we're not going to handle the error
  *   success case will return -1 as well
@@ -533,11 +564,20 @@
 lnet_health_check(struct lnet_msg *msg)
 {
 	enum lnet_msg_hstatus hstatus = msg->msg_health_status;
+	bool lo = false;
 
 	/* TODO: lnet_incr_hstats(hstatus); */
 
 	LASSERT(msg->msg_txni);
 
+	/* if we're sending to the LOLND then the msg_txpeer will not be
+	 * set. So no need to sanity check it.
+	 */
+	if (LNET_NETTYP(LNET_NIDNET(msg->msg_txni->ni_nid)) != LOLND)
+		LASSERT(msg->msg_txpeer);
+	else
+		lo = true;
+
 	if (hstatus != LNET_MSG_STATUS_OK &&
 	    ktime_compare(ktime_get(), msg->msg_deadline) >= 0)
 		return -1;
@@ -546,9 +586,21 @@
 	if (the_lnet.ln_state != LNET_STATE_RUNNING)
 		return -1;
 
+	CDEBUG(D_NET, "health check: %s->%s: %s: %s\n",
+	       libcfs_nid2str(msg->msg_txni->ni_nid),
+	       (lo) ? "self" : libcfs_nid2str(msg->msg_txpeer->lpni_nid),
+	       lnet_msgtyp2str(msg->msg_type),
+	       lnet_health_error2str(hstatus));
+
 	switch (hstatus) {
 	case LNET_MSG_STATUS_OK:
 		lnet_inc_healthv(&msg->msg_txni->ni_healthv);
+		/* It's possible msg_txpeer is NULL in the LOLND
+		 * case.
+		 */
+		if (msg->msg_txpeer)
+			lnet_inc_healthv(&msg->msg_txpeer->lpni_healthv);
+
 		/* we can finalize this message */
 		return -1;
 	case LNET_MSG_STATUS_LOCAL_INTERRUPT:
@@ -560,22 +612,27 @@
 		/* add to the re-send queue */
 		goto resend;
 
-		/* TODO: since the remote dropped the message we can
-		 * attempt a resend safely.
-		 */
-	case LNET_MSG_STATUS_REMOTE_DROPPED:
-		break;
-
-		/* These errors will not trigger a resend so simply
-		 * finalize the message
-		 */
+	/* These errors will not trigger a resend so simply
+	 * finalize the message
+	 */
 	case LNET_MSG_STATUS_LOCAL_ERROR:
 		lnet_handle_local_failure(msg);
 		return -1;
+
+	/* TODO: since the remote dropped the message we can
+	 * attempt a resend safely.
+	 */
+	case LNET_MSG_STATUS_REMOTE_DROPPED:
+		lnet_handle_remote_failure(msg);
+		goto resend;
+
 	case LNET_MSG_STATUS_REMOTE_ERROR:
 	case LNET_MSG_STATUS_REMOTE_TIMEOUT:
 	case LNET_MSG_STATUS_NETWORK_TIMEOUT:
+		lnet_handle_remote_failure(msg);
 		return -1;
+	default:
+		LBUG();
 	}
 
 resend:
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 121876e..4a62f9a 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -124,6 +124,7 @@
 	INIT_LIST_HEAD(&lpni->lpni_routes);
 	INIT_LIST_HEAD(&lpni->lpni_hashlist);
 	INIT_LIST_HEAD(&lpni->lpni_peer_nis);
+	INIT_LIST_HEAD(&lpni->lpni_recovery);
 	INIT_LIST_HEAD(&lpni->lpni_on_remote_peer_ni_list);
 
 	spin_lock_init(&lpni->lpni_lock);
@@ -133,6 +134,7 @@
 	lpni->lpni_ping_feats = LNET_PING_FEAT_INVAL;
 	lpni->lpni_nid = nid;
 	lpni->lpni_cpt = cpt;
+	atomic_set(&lpni->lpni_healthv, LNET_MAX_HEALTH_VALUE);
 	lnet_set_peer_ni_health_locked(lpni, true);
 
 	net = lnet_get_net_locked(LNET_NIDNET(nid));
@@ -331,6 +333,13 @@
 	/* remove peer ni from the hash list. */
 	list_del_init(&lpni->lpni_hashlist);
 
+	/* indicate the peer is being deleted so the monitor thread can
+	 * remove it from the recovery queue.
+	 */
+	spin_lock(&lpni->lpni_lock);
+	lpni->lpni_state |= LNET_PEER_NI_DELETING;
+	spin_unlock(&lpni->lpni_lock);
+
 	/* decrement the ref count on the peer table */
 	ptable = the_lnet.ln_peer_tables[lpni->lpni_cpt];
 	LASSERT(atomic_read(&ptable->pt_number) > 0);
-- 
1.8.3.1
