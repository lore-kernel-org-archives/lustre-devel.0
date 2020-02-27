From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:33 -0500
Subject: [lustre-devel] [PATCH 345/622] lnet: allow deleting router
 primary_nid
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-346-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Discovery doesn't allow deleting a primary_nid of a peer. This
is necessary because upper layers only know to reach the peer by
using the primary_nid. For routers this is not the case. So
if a router changes its interfaces and comes back up again, the
peer_ni should be adjusted.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11475
Lustre-commit: 086962e37737 ("LU-11475 lnet: allow deleting router primary_nid")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33300
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  3 +++
 net/lnet/lnet/peer.c           | 29 ++++++++++++++++++++++-------
 2 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 9662c9e..97d35e0 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -716,6 +716,9 @@ struct lnet_peer {
 #define LNET_PEER_FORCE_PING	BIT(13)	/* Forced Ping */
 #define LNET_PEER_FORCE_PUSH	BIT(14)	/* Forced Push */
 
+/* force delete even if router */
+#define LNET_PEER_RTR_NI_FORCE_DEL BIT(15)
+
 /* gw undergoing alive discovery */
 #define LNET_PEER_RTR_DISCOVERY	BIT(16)
 
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index b804d78..a81fee2 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -323,12 +323,12 @@
 
 /* called with lnet_net_lock LNET_LOCK_EX held */
 static int
-lnet_peer_ni_del_locked(struct lnet_peer_ni *lpni)
+lnet_peer_ni_del_locked(struct lnet_peer_ni *lpni, bool force)
 {
 	struct lnet_peer_table *ptable = NULL;
 
 	/* don't remove a peer_ni if it's also a gateway */
-	if (lnet_isrouter(lpni)) {
+	if (lnet_isrouter(lpni) && !force) {
 		CERROR("Peer NI %s is a gateway. Can not delete it\n",
 		       libcfs_nid2str(lpni->lpni_nid));
 		return -EBUSY;
@@ -384,7 +384,7 @@ void lnet_peer_uninit(void)
 	/* remove all peer_nis from the remote peer and the hash list */
 	list_for_each_entry_safe(lpni, tmp, &the_lnet.ln_remote_peer_ni_list,
 				 lpni_on_remote_peer_ni_list)
-		lnet_peer_ni_del_locked(lpni);
+		lnet_peer_ni_del_locked(lpni, false);
 
 	lnet_peer_tables_destroy();
 
@@ -439,7 +439,7 @@ void lnet_peer_uninit(void)
 	lpni = lnet_get_next_peer_ni_locked(peer, NULL, lpni);
 	while (lpni) {
 		lpni2 = lnet_get_next_peer_ni_locked(peer, NULL, lpni);
-		rc = lnet_peer_ni_del_locked(lpni);
+		rc = lnet_peer_ni_del_locked(lpni, false);
 		if (rc != 0)
 			rc2 = rc;
 		lpni = lpni2;
@@ -473,6 +473,7 @@ void lnet_peer_uninit(void)
 	struct lnet_peer_ni *lpni;
 	lnet_nid_t primary_nid = lp->lp_primary_nid;
 	int rc = 0;
+	bool force = (flags & LNET_PEER_RTR_NI_FORCE_DEL) ? true : false;
 
 	if (!(flags & LNET_PEER_CONFIGURED)) {
 		if (lp->lp_state & LNET_PEER_CONFIGURED) {
@@ -495,14 +496,21 @@ void lnet_peer_uninit(void)
 	 * This function only allows deletion of the primary NID if it
 	 * is the only NID.
 	 */
-	if (nid == lp->lp_primary_nid && lp->lp_nnis != 1) {
+	if (nid == lp->lp_primary_nid && lp->lp_nnis != 1 && !force) {
 		rc = -EBUSY;
 		goto out;
 	}
 
 	lnet_net_lock(LNET_LOCK_EX);
 
-	rc = lnet_peer_ni_del_locked(lpni);
+	if (nid == lp->lp_primary_nid && lp->lp_nnis != 1 && force) {
+		struct lnet_peer_ni *lpni2;
+		/* assign the next peer_ni to be the primary */
+		lpni2 = lnet_get_next_peer_ni_locked(lp, NULL, lpni);
+		LASSERT(lpni2);
+		lp->lp_primary_nid = lpni->lpni_nid;
+	}
+	rc = lnet_peer_ni_del_locked(lpni, force);
 
 	lnet_net_unlock(LNET_LOCK_EX);
 
@@ -530,7 +538,7 @@ void lnet_peer_uninit(void)
 
 			peer = lpni->lpni_peer_net->lpn_peer;
 			if (peer->lp_primary_nid != lpni->lpni_nid) {
-				lnet_peer_ni_del_locked(lpni);
+				lnet_peer_ni_del_locked(lpni, false);
 				continue;
 			}
 			/*
@@ -2545,6 +2553,13 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	}
 
 	for (i = 0; i < ndelnis; i++) {
+		/* for routers it's okay to delete the primary_nid because
+		 * the upper layers don't really rely on it. So if we're
+		 * being told that the router changed its primary_nid
+		 * then it's okay to delete it.
+		 */
+		if (lp->lp_rtr_refcount > 0)
+			flags |= LNET_PEER_RTR_NI_FORCE_DEL;
 		rc = lnet_peer_del_nid(lp, delnis[i], flags);
 		if (rc) {
 			CERROR("Error deleting NID %s from peer %s: %d\n",
-- 
1.8.3.1
