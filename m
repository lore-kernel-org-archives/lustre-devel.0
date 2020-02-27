From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:20 -0500
Subject: [lustre-devel] [PATCH 092/622] lnet: remove obsolete health
 functions
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-93-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Removed obsolete health functions that were originally added
during the Multi-Rail project. Some assumptions were made about
the health implementation back then, that are no longer true.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: ba05b3a98a0c ("LU-9120 lnet: remove obsolete health functions")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32862
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h | 40 ----------------------------------------
 net/lnet/lnet/api-ni.c        |  9 ---------
 net/lnet/lnet/lib-move.c      |  6 ------
 net/lnet/lnet/peer.c          |  8 --------
 4 files changed, 63 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index ba237df..74660d3 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -494,7 +494,6 @@ struct lnet_ni *
 struct lnet_ni *lnet_nid2ni_addref(lnet_nid_t nid);
 struct lnet_ni *lnet_net2ni_locked(u32 net, int cpt);
 struct lnet_ni *lnet_net2ni_addref(u32 net);
-bool lnet_is_ni_healthy_locked(struct lnet_ni *ni);
 struct lnet_net *lnet_get_net_locked(u32 net_id);
 
 extern unsigned int lnet_transaction_timeout;
@@ -825,45 +824,6 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 			  u32 *peer_tx_qnob);
 int lnet_get_peer_ni_hstats(struct lnet_ioctl_peer_ni_hstats *stats);
 
-static inline bool
-lnet_is_peer_ni_healthy_locked(struct lnet_peer_ni *lpni)
-{
-	return lpni->lpni_healthy;
-}
-
-static inline void
-lnet_set_peer_ni_health_locked(struct lnet_peer_ni *lpni, bool health)
-{
-	lpni->lpni_healthy = health;
-}
-
-static inline bool
-lnet_is_peer_net_healthy_locked(struct lnet_peer_net *peer_net)
-{
-	struct lnet_peer_ni *lpni;
-
-	list_for_each_entry(lpni, &peer_net->lpn_peer_nis,
-			    lpni_peer_nis) {
-		if (lnet_is_peer_ni_healthy_locked(lpni))
-			return true;
-	}
-
-	return false;
-}
-
-static inline bool
-lnet_is_peer_healthy_locked(struct lnet_peer *peer)
-{
-	struct lnet_peer_net *peer_net;
-
-	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_peer_nets) {
-		if (lnet_is_peer_net_healthy_locked(peer_net))
-			return true;
-	}
-
-	return false;
-}
-
 static inline struct lnet_peer_net *
 lnet_find_peer_net_locked(struct lnet_peer *peer, u32 net_id)
 {
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 14a8f2c..1ee24c7 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1155,15 +1155,6 @@ struct lnet_net *
 	return !!net;
 }
 
-bool
-lnet_is_ni_healthy_locked(struct lnet_ni *ni)
-{
-	if (ni->ni_state & LNET_NI_STATE_ACTIVE)
-		return true;
-
-	return false;
-}
-
 struct lnet_ni *
 lnet_nid2ni_locked(lnet_nid_t nid, int cpt)
 {
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 8d5f1e5..c33cf8d 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -2323,12 +2323,6 @@ struct lnet_ni *
 	}
 	lnet_peer_ni_decref_locked(lpni);
 
-	/* If peer is not healthy then can not send anything to it */
-	if (!lnet_is_peer_healthy_locked(peer)) {
-		lnet_net_unlock(cpt);
-		return -EHOSTUNREACH;
-	}
-
 	/* Identify the different send cases
 	 */
 	if (src_nid == LNET_NID_ANY)
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 4a38ca6..b20230b 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -135,7 +135,6 @@
 	lpni->lpni_nid = nid;
 	lpni->lpni_cpt = cpt;
 	atomic_set(&lpni->lpni_healthv, LNET_MAX_HEALTH_VALUE);
-	lnet_set_peer_ni_health_locked(lpni, true);
 
 	net = lnet_get_net_locked(LNET_NIDNET(nid));
 	lpni->lpni_net = net;
@@ -2694,8 +2693,6 @@ static lnet_nid_t lnet_peer_select_nid(struct lnet_peer *lp)
 	/* Look for a direct-connected NID for this peer. */
 	lpni = NULL;
 	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL) {
-		if (!lnet_is_peer_ni_healthy_locked(lpni))
-			continue;
 		if (!lnet_get_net_locked(lpni->lpni_peer_net->lpn_net_id))
 			continue;
 		break;
@@ -2706,8 +2703,6 @@ static lnet_nid_t lnet_peer_select_nid(struct lnet_peer *lp)
 	/* Look for a routed-connected NID for this peer. */
 	lpni = NULL;
 	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL) {
-		if (!lnet_is_peer_ni_healthy_locked(lpni))
-			continue;
 		if (!lnet_find_rnet_locked(lpni->lpni_peer_net->lpn_net_id))
 			continue;
 		break;
@@ -3082,9 +3077,6 @@ static int lnet_peer_discovery(void *arg)
 			 * forever, in case the GET message (for ping)
 			 * doesn't get a REPLY or the PUT message (for
 			 * push) doesn't get an ACK.
-			 *
-			 * TODO: LNet Health will deal with this scenario
-			 * in a generic way.
 			 */
 			lp->lp_last_queued = ktime_get_real_seconds();
 			lnet_net_unlock(LNET_LOCK_EX);
-- 
1.8.3.1
