From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:02 -0500
Subject: [lustre-devel] [PATCH 374/622] lnet: prevent loop in
 LNetPrimaryNID()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-375-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

If discovery is disabled locally or at the remote end, then attempt
discovery only once. Do not update the internal database when
discovery is disabled and do not repeat discovery.

This change prevents LNet from getting hung waiting for
discovery to complete.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12424
Lustre-commit: 439520f762b0 ("LU-12424 lnet: prevent loop in LNetPrimaryNID()")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35191
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 73 ++++++++++++++++++++++++++++++----------------------
 1 file changed, 42 insertions(+), 31 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 55ff01d..e5cce2f 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1137,6 +1137,34 @@ struct lnet_peer_ni *
 	return primary_nid;
 }
 
+bool
+lnet_is_discovery_disabled_locked(struct lnet_peer *lp)
+{
+	if (lnet_peer_discovery_disabled)
+		return true;
+
+	if (!(lp->lp_state & LNET_PEER_MULTI_RAIL) ||
+	    (lp->lp_state & LNET_PEER_NO_DISCOVERY)) {
+		return true;
+	}
+
+	return false;
+}
+
+/* Peer Discovery
+ */
+bool
+lnet_is_discovery_disabled(struct lnet_peer *lp)
+{
+	bool rc = false;
+
+	spin_lock(&lp->lp_lock);
+	rc = lnet_is_discovery_disabled_locked(lp);
+	spin_unlock(&lp->lp_lock);
+
+	return rc;
+}
+
 lnet_nid_t
 LNetPrimaryNID(lnet_nid_t nid)
 {
@@ -1153,11 +1181,16 @@ struct lnet_peer_ni *
 		goto out_unlock;
 	}
 	lp = lpni->lpni_peer_net->lpn_peer;
+
 	while (!lnet_peer_is_uptodate(lp)) {
 		rc = lnet_discover_peer_locked(lpni, cpt, true);
 		if (rc)
 			goto out_decref;
 		lp = lpni->lpni_peer_net->lpn_peer;
+
+		/* Only try once if discovery is disabled */
+		if (lnet_is_discovery_disabled(lp))
+			break;
 	}
 	primary_nid = lp->lp_primary_nid;
 out_decref:
@@ -1784,35 +1817,6 @@ struct lnet_peer_ni *
 }
 
 bool
-lnet_is_discovery_disabled_locked(struct lnet_peer *lp)
-{
-	if (lnet_peer_discovery_disabled)
-		return true;
-
-	if (!(lp->lp_state & LNET_PEER_MULTI_RAIL) ||
-	    (lp->lp_state & LNET_PEER_NO_DISCOVERY)) {
-		return true;
-	}
-
-	return false;
-}
-
-/*
- * Peer Discovery
- */
-bool
-lnet_is_discovery_disabled(struct lnet_peer *lp)
-{
-	bool rc = false;
-
-	spin_lock(&lp->lp_lock);
-	rc = lnet_is_discovery_disabled_locked(lp);
-	spin_unlock(&lp->lp_lock);
-
-	return rc;
-}
-
-bool
 lnet_peer_gw_discovery(struct lnet_peer *lp)
 {
 	bool rc = false;
@@ -2157,8 +2161,6 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 			break;
 		lnet_peer_queue_for_discovery(lp);
 
-		if (lnet_is_discovery_disabled(lp))
-			break;
 		/*
 		 * if caller requested a non-blocking operation then
 		 * return immediately. Once discovery is complete then the
@@ -2176,6 +2178,15 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 		lnet_peer_decref_locked(lp);
 		/* Peer may have changed */
 		lp = lpni->lpni_peer_net->lpn_peer;
+
+		/* Wait for discovery to complete, but don't repeat if
+		 * discovery is disabled. This is done to ensure we can
+		 * use discovery as a standard ping as well for backwards
+		 * compatibility with routers which do not have discovery
+		 * or have discovery disabled
+		 */
+		if (lnet_is_discovery_disabled(lp))
+			break;
 	}
 	finish_wait(&lp->lp_dc_waitq, &wait);
 
-- 
1.8.3.1
