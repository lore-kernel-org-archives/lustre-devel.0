From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:29 -0500
Subject: [lustre-devel] [PATCH 341/622] lnet: modify lnd notification
 mechanism
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-342-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

LND notifies when a peer is up or down. If the LND notifies
LNet that the peer is up and sets the "reset" flag to true
then this indicates to LNet that the LND knows about the health
of the peer and is telling LNet that the peer is fully healthy.
LNet will set the health value of the peer to maximum, otherwise
it will increment the health by one.

If the LND notifies the LNet that the peer is down, LNet will
decrement the health of the peer by sensitivity value configured.

LNet then turns around and rechecks the peer aliveness and if its
dead it'll notify the LND. This code is only used by the socklnd
because it needs to tear down connections. This is in keeping with
the original functionality.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11299
Lustre-commit: b34e754c1a0b ("LU-11299 lnet: modify lnd notification mechanism")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33453
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h       |  8 ++++-
 include/linux/lnet/lib-types.h      |  4 +--
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c |  2 +-
 net/lnet/klnds/socklnd/socklnd.c    | 21 ++++++-------
 net/lnet/klnds/socklnd/socklnd.h    |  2 +-
 net/lnet/lnet/api-ni.c              |  2 +-
 net/lnet/lnet/router.c              | 60 +++++++++++++++++++++++++------------
 7 files changed, 62 insertions(+), 37 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 8730670..94918d3 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -506,7 +506,7 @@ struct lnet_ni *
 
 void lnet_mt_event_handler(struct lnet_event *event);
 
-int lnet_notify(struct lnet_ni *ni, lnet_nid_t peer, int alive,
+int lnet_notify(struct lnet_ni *ni, lnet_nid_t peer, bool alive, bool reset,
 		time64_t when);
 void lnet_notify_locked(struct lnet_peer_ni *lp, int notifylnd, int alive,
 			time64_t when);
@@ -886,6 +886,12 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 }
 
 static inline void
+lnet_set_healthv(atomic_t *healthv, int value)
+{
+	atomic_set(healthv, value);
+}
+
+static inline void
 lnet_inc_healthv(atomic_t *healthv)
 {
 	atomic_add_unless(healthv, 1, LNET_MAX_HEALTH_VALUE);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 495e805..2d5ae21 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -298,8 +298,8 @@ struct lnet_lnd {
 	int (*lnd_eager_recv)(struct lnet_ni *ni, void *private,
 			      struct lnet_msg *msg, void **new_privatep);
 
-	/* notification of peer health */
-	void (*lnd_notify)(struct lnet_ni *ni, lnet_nid_t peer, int alive);
+	/* notification of peer down */
+	void (*lnd_notify_peer_down)(lnet_nid_t peer);
 
 	/* query of peer aliveness */
 	void (*lnd_query)(struct lnet_ni *ni, lnet_nid_t peer, time64_t *when);
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index a3abbb6..69918cf 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1960,7 +1960,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	if (error)
 		lnet_notify(peer_ni->ibp_ni,
-			    peer_ni->ibp_nid, 0, last_alive);
+			    peer_ni->ibp_nid, false, false, last_alive);
 }
 
 void
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 8b283ac..0f5c7fc 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -1518,8 +1518,8 @@ struct ksock_peer *
 	read_unlock(&ksocknal_data.ksnd_global_lock);
 
 	if (notify)
-		lnet_notify(peer_ni->ksnp_ni, peer_ni->ksnp_id.nid, 0,
-			    last_alive);
+		lnet_notify(peer_ni->ksnp_ni, peer_ni->ksnp_id.nid,
+			    false, false, last_alive);
 }
 
 void
@@ -1787,7 +1787,7 @@ struct ksock_peer *
 }
 
 void
-ksocknal_notify(struct lnet_ni *ni, lnet_nid_t gw_nid, int alive)
+ksocknal_notify_gw_down(lnet_nid_t gw_nid)
 {
 	/*
 	 * The router is telling me she's been notified of a change in
@@ -1798,17 +1798,14 @@ struct ksock_peer *
 	id.nid = gw_nid;
 	id.pid = LNET_PID_ANY;
 
-	CDEBUG(D_NET, "gw %s %s\n", libcfs_nid2str(gw_nid),
-	       alive ? "up" : "down");
+	CDEBUG(D_NET, "gw %s down\n", libcfs_nid2str(gw_nid));
 
-	if (!alive) {
-		/* If the gateway crashed, close all open connections... */
-		ksocknal_close_matching_conns(id, 0);
-		return;
-	}
+	/* If the gateway crashed, close all open connections... */
+	ksocknal_close_matching_conns(id, 0);
+	return;
 
 	/*
-	 * ...otherwise do nothing.  We can only establish new connections
+	 * We can only establish new connections
 	 * if we have autroutes, and these connect on demand.
 	 */
 }
@@ -2839,7 +2836,7 @@ static int __init ksocklnd_init(void)
 	the_ksocklnd.lnd_ctl = ksocknal_ctl;
 	the_ksocklnd.lnd_send = ksocknal_send;
 	the_ksocklnd.lnd_recv = ksocknal_recv;
-	the_ksocklnd.lnd_notify = ksocknal_notify;
+	the_ksocklnd.lnd_notify_peer_down = ksocknal_notify_gw_down;
 	the_ksocklnd.lnd_query = ksocknal_query;
 	the_ksocklnd.lnd_accept = ksocknal_accept;
 
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 2e292f0..80c2e19 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -659,7 +659,7 @@ int ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 void ksocknal_next_tx_carrier(struct ksock_conn *conn);
 void ksocknal_queue_tx_locked(struct ksock_tx *tx, struct ksock_conn *conn);
 void ksocknal_txlist_done(struct lnet_ni *ni, struct list_head *txlist, int error);
-void ksocknal_notify(struct lnet_ni *ni, lnet_nid_t gw_nid, int alive);
+void ksocknal_notify(lnet_nid_t gw_nid);
 void ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when);
 int ksocknal_thread_start(int (*fn)(void *arg), void *arg, char *name);
 void ksocknal_thread_fini(void);
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 32b4b4f..4dc9514 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3767,7 +3767,7 @@ u32 lnet_get_dlc_seq_locked(void)
 		 * that deadline to the wall clock.
 		 */
 		deadline += ktime_get_seconds();
-		return lnet_notify(NULL, data->ioc_nid, data->ioc_flags,
+		return lnet_notify(NULL, data->ioc_nid, data->ioc_flags, false,
 				   deadline);
 	}
 
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 1399545..22a3018 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1199,12 +1199,26 @@ bool lnet_router_checker_active(void)
 	lnet_rtrpools_free(1);
 }
 
+static inline void
+lnet_notify_peer_down(struct lnet_ni *ni, lnet_nid_t nid)
+{
+	if (ni->ni_net->net_lnd->lnd_notify_peer_down)
+		ni->ni_net->net_lnd->lnd_notify_peer_down(nid);
+}
+
+/* ni: local NI used to communicate with the peer
+ * nid: peer NID
+ * alive: true if peer is alive, false otherwise
+ * reset: reset health value. This is requested by the LND.
+ * when: notificaiton time.
+ */
 int
-lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, int alive, time64_t when)
+lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, bool alive, bool reset,
+	    time64_t when)
 {
-	struct lnet_peer_ni *lp = NULL;
+	struct lnet_peer_ni *lpni = NULL;
 	time64_t now = ktime_get_seconds();
-	int cpt = lnet_cpt_of_nid(nid, ni);
+	int cpt;
 
 	LASSERT(!in_interrupt());
 
@@ -1235,36 +1249,44 @@ bool lnet_router_checker_active(void)
 		return 0;
 	}
 
-	lnet_net_lock(cpt);
+	/* must lock 0 since this is used for synchronization */
+	lnet_net_lock(0);
 
 	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
-		lnet_net_unlock(cpt);
+		lnet_net_unlock(0);
 		return -ESHUTDOWN;
 	}
 
-	lp = lnet_find_peer_ni_locked(nid);
-	if (!lp) {
+	lpni = lnet_find_peer_ni_locked(nid);
+	if (!lpni) {
 		/* nid not found */
-		lnet_net_unlock(cpt);
+		lnet_net_unlock(0);
 		CDEBUG(D_NET, "%s not found\n", libcfs_nid2str(nid));
 		return 0;
 	}
 
-	/*
-	 * It is possible for this function to be called for the same peer
-	 * but with different NIs. We want to synchronize the notification
-	 * between the different calls. So we will use the lpni_cpt to
-	 * grab the net lock.
-	 */
-	if (lp->lpni_cpt != cpt) {
-		lnet_net_unlock(cpt);
-		cpt = lp->lpni_cpt;
-		lnet_net_lock(cpt);
+	if (alive) {
+		if (reset)
+			lnet_set_healthv(&lpni->lpni_healthv,
+					 LNET_MAX_HEALTH_VALUE);
+		else
+			lnet_inc_healthv(&lpni->lpni_healthv);
+	} else {
+		lnet_handle_remote_failure_locked(lpni);
 	}
 
-	lnet_peer_ni_decref_locked(lp);
+	/* recalculate aliveness */
+	alive = lnet_is_peer_ni_alive(lpni);
+	lnet_net_unlock(0);
 
+	if (ni && !alive)
+		lnet_notify_peer_down(ni, lpni->lpni_nid);
+
+	cpt = lpni->lpni_cpt;
+	lnet_net_lock(cpt);
+	lnet_peer_ni_decref_locked(lpni);
 	lnet_net_unlock(cpt);
+
 	return 0;
 }
 EXPORT_SYMBOL(lnet_notify);
-- 
1.8.3.1
