From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:01 -0500
Subject: [lustre-devel] [PATCH 493/622] lnet: Don't queue msg when discovery
 has completed
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-494-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

In lnet_initiate_peer_discovery(), it is possible for the peer object
to change after the call to lnet_discover_peer_locked(), and it is
also possible for the peer to complete discovery between the first
call to lnet_peer_is_uptodate() and our placing the lnet_msg onto
the peer's lp_dc_pendq. After the call to lnet_discover_peer_locked()
check whether the, potentially new, peer object is up to date while
holding the lp_lock. If the peer is up to date, then we needn't
queue the message. Otherwise, we continue to hold the lock to place
the message on the peer's lp_dc_pendq.

Cray-bug-id: LUS-7596
WC-bug-id: https://jira.whamcloud.com/browse/LU-12739
Lustre-commit: 4ef62976448d ("LU-12739 lnet: Don't queue msg when discovery has completed")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/36139
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  1 +
 net/lnet/lnet/lib-move.c      | 19 +++++++++++++------
 net/lnet/lnet/peer.c          | 16 +++++++++++++---
 3 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index f2f5455..db1b7e5 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -876,6 +876,7 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 }
 
 bool lnet_peer_is_uptodate(struct lnet_peer *lp);
+bool lnet_peer_is_uptodate_locked(struct lnet_peer *lp);
 bool lnet_is_discovery_disabled(struct lnet_peer *lp);
 bool lnet_peer_gw_discovery(struct lnet_peer *lp);
 
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 2f31f06..6da0be4 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1807,15 +1807,21 @@ struct lnet_ni *
 	}
 	/* The peer may have changed. */
 	peer = lpni->lpni_peer_net->lpn_peer;
+	spin_lock(&peer->lp_lock);
+	if (lnet_peer_is_uptodate_locked(peer)) {
+		spin_unlock(&peer->lp_lock);
+		lnet_peer_ni_decref_locked(lpni);
+		return 0;
+	}
 	/* queue message and return */
 	msg->msg_rtr_nid_param = rtr_nid;
 	msg->msg_sending = 0;
 	msg->msg_txpeer = NULL;
-	spin_lock(&peer->lp_lock);
 	list_add_tail(&msg->msg_list, &peer->lp_dc_pendq);
+	primary_nid = peer->lp_primary_nid;
 	spin_unlock(&peer->lp_lock);
+
 	lnet_peer_ni_decref_locked(lpni);
-	primary_nid = peer->lp_primary_nid;
 
 	CDEBUG(D_NET, "msg %p delayed. %s pending discovery\n",
 	       msg, libcfs_nid2str(primary_nid));
@@ -2428,11 +2434,10 @@ struct lnet_ni *
 	 */
 	msg->msg_src_nid_param = src_nid;
 
-	/* Now that we have a peer_ni, check if we want to discover
-	 * the peer. Traffic to the LNET_RESERVED_PORTAL should not
-	 * trigger discovery.
+	/* If necessary, perform discovery on the peer that owns this peer_ni.
+	 * Note, this can result in the ownership of this peer_ni changing
+	 * to another peer object.
 	 */
-	peer = lpni->lpni_peer_net->lpn_peer;
 	rc = lnet_initiate_peer_discovery(lpni, msg, rtr_nid, cpt);
 	if (rc) {
 		lnet_peer_ni_decref_locked(lpni);
@@ -2441,6 +2446,8 @@ struct lnet_ni *
 	}
 	lnet_peer_ni_decref_locked(lpni);
 
+	peer = lpni->lpni_peer_net->lpn_peer;
+
 	/* Identify the different send cases
 	 */
 	if (src_nid == LNET_NID_ANY)
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 088bb62..0d33ade 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1831,6 +1831,17 @@ struct lnet_peer_ni *
 	return rc;
 }
 
+bool
+lnet_peer_is_uptodate(struct lnet_peer *lp)
+{
+	bool rc;
+
+	spin_lock(&lp->lp_lock);
+	rc = lnet_peer_is_uptodate_locked(lp);
+	spin_unlock(&lp->lp_lock);
+	return rc;
+}
+
 /*
  * Is a peer uptodate from the point of view of discovery?
  *
@@ -1840,11 +1851,11 @@ struct lnet_peer_ni *
  * Otherwise look at whether the peer needs rediscovering.
  */
 bool
-lnet_peer_is_uptodate(struct lnet_peer *lp)
+lnet_peer_is_uptodate_locked(struct lnet_peer *lp)
+__must_hold(&lp->lp_lock)
 {
 	bool rc;
 
-	spin_lock(&lp->lp_lock);
 	if (lp->lp_state & (LNET_PEER_DISCOVERING |
 			    LNET_PEER_FORCE_PING |
 			    LNET_PEER_FORCE_PUSH)) {
@@ -1861,7 +1872,6 @@ struct lnet_peer_ni *
 	} else {
 		rc = false;
 	}
-	spin_unlock(&lp->lp_lock);
 
 	return rc;
 }
-- 
1.8.3.1
