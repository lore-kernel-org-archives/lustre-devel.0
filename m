From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:25 -0500
Subject: [lustre-devel] [PATCH 337/622] lnet: peer aliveness
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-338-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Peer NI aliveness is now solely dependent on the health
infrastructure. With the addition of router_sensitivity_percentage,
peer NI is considered dead if its health drops below the percentage
specified of the total health. Setting the percentage to 100% means
that a peer_ni is considered dead if it's interface is less than
fully healthy.

Removed obsolete code that queries the peer NI every second since
the health infrastructure introduces the recovery mechanism which
is designed to recover the health of peer NIs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11300
Lustre-commit: 8e498d3f23ea ("LU-11300 lnet: peer aliveness")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33186
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |  25 ++++++---
 include/linux/lnet/lib-types.h |   2 -
 net/lnet/lnet/lib-move.c       | 124 +++++------------------------------------
 net/lnet/lnet/peer.c           |   7 ++-
 net/lnet/lnet/router.c         |  11 ++--
 net/lnet/lnet/router_proc.c    |   3 +-
 6 files changed, 42 insertions(+), 130 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index eae55d5..d5704b7 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -846,15 +846,6 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 	return NULL;
 }
 
-static inline void
-lnet_peer_set_alive(struct lnet_peer_ni *lp)
-{
-	lp->lpni_last_query = ktime_get_seconds();
-	lp->lpni_last_alive = lp->lpni_last_query;
-	if (!lp->lpni_alive)
-		lnet_notify_locked(lp, 0, 1, lp->lpni_last_alive);
-}
-
 static inline bool
 lnet_peer_is_multi_rail(struct lnet_peer *lp)
 {
@@ -889,6 +880,22 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 	return false;
 }
 
+/*
+ * A peer is alive if it satisfies the following two conditions:
+ *  1. peer health >= LNET_MAX_HEALTH_VALUE * router_sensitivity_percentage
+ *  2. the cached NI status received when we discover the peer is UP
+ */
+static inline bool
+lnet_is_peer_ni_alive(struct lnet_peer_ni *lpni)
+{
+	bool halive = false;
+
+	halive = (atomic_read(&lpni->lpni_healthv) >=
+		 (LNET_MAX_HEALTH_VALUE * router_sensitivity_percentage / 100));
+
+	return halive && lpni->lpni_ns_status == LNET_NI_STATUS_UP;
+}
+
 static inline void
 lnet_inc_healthv(atomic_t *healthv)
 {
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index ecc6dee..9a09fad 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -553,8 +553,6 @@ struct lnet_peer_ni {
 	int			 lpni_rtrcredits;
 	/* low water mark */
 	int			 lpni_minrtrcredits;
-	/* alive/dead? */
-	bool			 lpni_alive;
 	/* notification outstanding? */
 	bool			 lpni_notify;
 	/* outstanding notification for LND? */
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 99ff882..af3cd1e 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -609,86 +609,16 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 }
 
 /*
- * This function can be called from two paths:
- *	1. when sending a message
- *	2. when decommiting a message (lnet_msg_decommit_tx())
- * In both these cases the peer_ni should have it's reference count
- * acquired by the caller and therefore it is safe to drop the spin
- * lock before calling lnd_query()
- */
-static void
-lnet_ni_query_locked(struct lnet_ni *ni, struct lnet_peer_ni *lp)
-{
-	time64_t last_alive = 0;
-	int cpt = lnet_cpt_of_nid_locked(lp->lpni_nid, ni);
-
-	LASSERT(lnet_peer_aliveness_enabled(lp));
-	LASSERT(ni->ni_net->net_lnd->lnd_query);
-
-	lnet_net_unlock(cpt);
-	ni->ni_net->net_lnd->lnd_query(ni, lp->lpni_nid, &last_alive);
-	lnet_net_lock(cpt);
-
-	lp->lpni_last_query = ktime_get_seconds();
-
-	if (last_alive) /* NI has updated timestamp */
-		lp->lpni_last_alive = last_alive;
-}
-
-/* NB: always called with lnet_net_lock held */
-static inline int
-lnet_peer_is_alive(struct lnet_peer_ni *lp, unsigned long now)
-{
-	int alive;
-	time64_t deadline;
-
-	LASSERT(lnet_peer_aliveness_enabled(lp));
-
-	/* Trust lnet_notify() if it has more recent aliveness news, but
-	 * ignore the initial assumed death (see lnet_peers_start_down()).
-	 */
-	spin_lock(&lp->lpni_lock);
-	if (!lp->lpni_alive && lp->lpni_alive_count > 0 &&
-	    lp->lpni_timestamp >= lp->lpni_last_alive) {
-		spin_unlock(&lp->lpni_lock);
-		return 0;
-	}
-
-	deadline = lp->lpni_last_alive +
-		   lp->lpni_net->net_tunables.lct_peer_timeout;
-	alive = deadline > now;
-
-	/* Update obsolete lpni_alive except for routers assumed to be dead
-	 * initially, because router checker would update aliveness in this
-	 * case, and moreover lpni_last_alive at peer creation is assumed.
-	 */
-	if (alive && !lp->lpni_alive &&
-	    !(lnet_isrouter(lp) && !lp->lpni_alive_count)) {
-		spin_unlock(&lp->lpni_lock);
-		lnet_notify_locked(lp, 0, 1, lp->lpni_last_alive);
-	} else {
-		spin_unlock(&lp->lpni_lock);
-	}
-
-	return alive;
-}
-
-/*
  * NB: returns 1 when alive, 0 when dead, negative when error;
  *     may drop the lnet_net_lock
  */
 static int
-lnet_peer_alive_locked(struct lnet_ni *ni, struct lnet_peer_ni *lp,
+lnet_peer_alive_locked(struct lnet_ni *ni, struct lnet_peer_ni *lpni,
 		       struct lnet_msg *msg)
 {
-	time64_t now = ktime_get_seconds();
-
-	if (!lnet_peer_aliveness_enabled(lp))
+	if (!lnet_peer_aliveness_enabled(lpni))
 		return -ENODEV;
 
-	if (lnet_peer_is_alive(lp, now))
-		return 1;
-
 	/*
 	 * If we're resending a message, let's attempt to send it even if
 	 * the peer is down to fulfill our resend quota on the message
@@ -696,35 +626,16 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	if (msg->msg_retry_count > 0)
 		return 1;
 
-	/*
-	 * Peer appears dead, but we should avoid frequent NI queries (at
-	 * most once per lnet_queryinterval seconds).
-	 */
-	if (lp->lpni_last_query) {
-		static const int lnet_queryinterval = 1;
-		time64_t next_query;
-
-		next_query = lp->lpni_last_query + lnet_queryinterval;
-
-		if (now < next_query) {
-			if (lp->lpni_alive)
-				CWARN("Unexpected aliveness of peer %s: %lld < %lld (%d/%d)\n",
-				      libcfs_nid2str(lp->lpni_nid),
-				      now, next_query,
-				      lnet_queryinterval,
-				      lp->lpni_net->net_tunables.lct_peer_timeout);
-			return 0;
-		}
-	}
-
-	/* query NI for latest aliveness news */
-	lnet_ni_query_locked(ni, lp);
+	/* try and send recovery messages irregardless */
+	if (msg->msg_recovery)
+		return 1;
 
-	if (lnet_peer_is_alive(lp, now))
+	/* always send any responses */
+	if (msg->msg_type == LNET_MSG_ACK ||
+	    msg->msg_type == LNET_MSG_REPLY)
 		return 1;
 
-	lnet_notify_locked(lp, 0, 0, lp->lpni_last_alive);
-	return 0;
+	return lnet_is_peer_ni_alive(lpni);
 }
 
 /**
@@ -4184,18 +4095,11 @@ void lnet_monitor_thr_stop(void)
 	/* Multi-Rail: Primary NID of source. */
 	msg->msg_initiator = lnet_peer_primary_nid_locked(src_nid);
 
-	if (lnet_isrouter(msg->msg_rxpeer)) {
-		lnet_peer_set_alive(msg->msg_rxpeer);
-		if (avoid_asym_router_failure &&
-		    LNET_NIDNET(src_nid) != LNET_NIDNET(from_nid)) {
-			/* received a remote message from router, update
-			 * remote NI status on this router.
-			 * NB: multi-hop routed message will be ignored.
-			 */
-			lnet_router_ni_update_locked(msg->msg_rxpeer,
-						     LNET_NIDNET(src_nid));
-		}
-	}
+	/* mark the status of this lpni as UP since we received a message
+	 * from it. The ping response reports back the ns_status which is
+	 * marked on the remote as up or down and we cache it here.
+	 */
+	msg->msg_rxpeer->lpni_ns_status = LNET_NI_STATUS_UP;
 
 	lnet_msg_commit(msg, cpt);
 
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 91ad6b4..8669fbb 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3296,7 +3296,7 @@ void lnet_peer_discovery_stop(void)
 	}
 
 	if (lnet_isrouter(lp) || lnet_peer_aliveness_enabled(lp))
-		aliveness = lp->lpni_alive ? "up" : "down";
+		aliveness = (lnet_is_peer_ni_alive(lp)) ? "up" : "down";
 
 	CDEBUG(D_WARNING, "%-24s %4d %5s %5d %5d %5d %5d %5d %ld\n",
 	       libcfs_nid2str(lp->lpni_nid), atomic_read(&lp->lpni_refcount),
@@ -3353,7 +3353,8 @@ void lnet_peer_discovery_stop(void)
 			if (lnet_isrouter(lp) ||
 			    lnet_peer_aliveness_enabled(lp))
 				snprintf(aliveness, LNET_MAX_STR_LEN,
-					 lp->lpni_alive ? "up" : "down");
+					 lnet_is_peer_ni_alive(lp)
+					 ? "up" : "down");
 
 			*nid = lp->lpni_nid;
 			*refcount = atomic_read(&lp->lpni_refcount);
@@ -3439,7 +3440,7 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 		if (lnet_isrouter(lpni) ||
 		    lnet_peer_aliveness_enabled(lpni))
 			snprintf(lpni_info->cr_aliveness, LNET_MAX_STR_LEN,
-				 lpni->lpni_alive ? "up" : "down");
+				 lnet_is_peer_ni_alive(lpni) ? "up" : "down");
 
 		lpni_info->cr_refcount = atomic_read(&lpni->lpni_refcount);
 		lpni_info->cr_ni_peer_tx_credits = lpni->lpni_net ?
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 40725d2..d5b4914 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -165,8 +165,10 @@ static int rtr_sensitivity_set(const char *val,
 
 	lp->lpni_timestamp = when;		/* update timestamp */
 
-	if (lp->lpni_alive_count &&		/* got old news */
-	    (!lp->lpni_alive) == (!alive)) {	/* new date for old news */
+	/* got old news */
+	if (lp->lpni_alive_count != 0 &&
+	    /* new date for old news */
+	    (!lnet_is_peer_ni_alive(lp)) == !alive) {
 		spin_unlock(&lp->lpni_lock);
 		CDEBUG(D_NET, "Old news\n");
 		return;
@@ -175,10 +177,9 @@ static int rtr_sensitivity_set(const char *val,
 	/* Flag that notification is outstanding */
 
 	lp->lpni_alive_count++;
-	lp->lpni_alive = !!alive;	/* 1 bit! */
 	lp->lpni_notify = 1;
 	lp->lpni_notifylnd = notifylnd;
-	if (lp->lpni_alive)
+	if (lnet_is_peer_ni_alive(lp))
 		lp->lpni_ping_feats = LNET_PING_FEAT_INVAL; /* reset */
 
 	spin_unlock(&lp->lpni_lock);
@@ -214,7 +215,7 @@ static int rtr_sensitivity_set(const char *val,
 	 * lnet_notify_locked().
 	 */
 	while (lp->lpni_notify) {
-		alive = lp->lpni_alive;
+		alive = lnet_is_peer_ni_alive(lp);
 		notifylnd = lp->lpni_notifylnd;
 
 		lp->lpni_notifylnd = 0;
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index d41ff00..e9aef1e 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -529,7 +529,8 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 
 			if (lnet_isrouter(peer) ||
 			    lnet_peer_aliveness_enabled(peer))
-				aliveness = peer->lpni_alive ? "up" : "down";
+				aliveness = lnet_is_peer_ni_alive(peer) ?
+					"up" : "down";
 
 			if (lnet_peer_aliveness_enabled(peer)) {
 				time64_t now = ktime_get_seconds();
-- 
1.8.3.1
