From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:23 -0500
Subject: [lustre-devel] [PATCH 335/622] lnet: cache ni status
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-336-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When processing the data in the PUSH or the REPLY make sure to cache
the ns_status. This is the status of the peer_ni as reported by the
peer itself.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11300
Lustre-commit: 398f4071dc17 ("LU-11300 lnet: cache ni status")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33450
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  2 ++
 net/lnet/lnet/peer.c           | 42 +++++++++++++++++++++++++++++++-----------
 2 files changed, 33 insertions(+), 11 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 31fe22a..a551005 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -585,6 +585,8 @@ struct lnet_peer_ni {
 	int			 lpni_cpt;
 	/* state flags -- protected by lpni_lock */
 	unsigned int		 lpni_state;
+	/* status of the peer NI as reported by the peer */
+	u32			lpni_ns_status;
 	/* sequence number used to round robin over peer nis within a net */
 	u32			 lpni_seq;
 	/* sequence number used to round robin over gateways */
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index cb70bc7..cba3da2 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -128,8 +128,10 @@
 
 	spin_lock_init(&lpni->lpni_lock);
 
-	lpni->lpni_alive = !lnet_peers_start_down(); /* 1 bit!! */
-	lpni->lpni_last_alive = ktime_get_seconds(); /* assumes alive */
+	if (lnet_peers_start_down())
+		lpni->lpni_ns_status = LNET_NI_STATUS_DOWN;
+	else
+		lpni->lpni_ns_status = LNET_NI_STATUS_UP;
 	lpni->lpni_ping_feats = LNET_PING_FEAT_INVAL;
 	lpni->lpni_nid = nid;
 	lpni->lpni_cpt = cpt;
@@ -2410,7 +2412,7 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 {
 	struct lnet_peer_ni *lpni;
 	lnet_nid_t *curnis = NULL;
-	lnet_nid_t *addnis = NULL;
+	struct lnet_ni_status *addnis = NULL;
 	lnet_nid_t *delnis = NULL;
 	unsigned int flags;
 	int ncurnis;
@@ -2426,9 +2428,9 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 		flags |= LNET_PEER_MULTI_RAIL;
 
 	nnis = max_t(int, lp->lp_nnis, pbuf->pb_info.pi_nnis);
-	curnis = kmalloc_array(nnis, sizeof(lnet_nid_t), GFP_NOFS);
-	addnis = kmalloc_array(nnis, sizeof(lnet_nid_t), GFP_NOFS);
-	delnis = kmalloc_array(nnis, sizeof(lnet_nid_t), GFP_NOFS);
+	curnis = kmalloc_array(nnis, sizeof(*curnis), GFP_NOFS);
+	addnis = kmalloc_array(nnis, sizeof(*addnis), GFP_NOFS);
+	delnis = kmalloc_array(nnis, sizeof(*delnis), GFP_NOFS);
 	if (!curnis || !addnis || !delnis) {
 		rc = -ENOMEM;
 		goto out;
@@ -2451,7 +2453,7 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 			if (pbuf->pb_info.pi_ni[i].ns_nid == curnis[j])
 				break;
 		if (j == ncurnis)
-			addnis[naddnis++] = pbuf->pb_info.pi_ni[i].ns_nid;
+			addnis[naddnis++] = pbuf->pb_info.pi_ni[i];
 	}
 	/*
 	 * Check for NIDs in curnis[] not present in pbuf.
@@ -2463,23 +2465,41 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	for (i = 0; i < ncurnis; i++) {
 		if (LNET_NETTYP(LNET_NIDNET(curnis[i])) == LOLND)
 			continue;
-		for (j = 1; j < pbuf->pb_info.pi_nnis; j++)
-			if (curnis[i] == pbuf->pb_info.pi_ni[j].ns_nid)
+		for (j = 1; j < pbuf->pb_info.pi_nnis; j++) {
+			if (curnis[i] == pbuf->pb_info.pi_ni[j].ns_nid) {
+				/* update the information we cache for the
+				 * peer with the latest information we
+				 * received
+				 */
+				lpni = lnet_find_peer_ni_locked(curnis[i]);
+				if (lpni) {
+					lpni->lpni_ns_status =
+						pbuf->pb_info.pi_ni[j].ns_status;
+					lnet_peer_ni_decref_locked(lpni);
+				}
 				break;
+			}
+		}
 		if (j == pbuf->pb_info.pi_nnis)
 			delnis[ndelnis++] = curnis[i];
 	}
 
 	for (i = 0; i < naddnis; i++) {
-		rc = lnet_peer_add_nid(lp, addnis[i], flags);
+		rc = lnet_peer_add_nid(lp, addnis[i].ns_nid, flags);
 		if (rc) {
 			CERROR("Error adding NID %s to peer %s: %d\n",
-			       libcfs_nid2str(addnis[i]),
+			       libcfs_nid2str(addnis[i].ns_nid),
 			       libcfs_nid2str(lp->lp_primary_nid), rc);
 			if (rc == -ENOMEM)
 				goto out;
 		}
+		lpni = lnet_find_peer_ni_locked(addnis[i].ns_nid);
+		if (lpni) {
+			lpni->lpni_ns_status = addnis[i].ns_status;
+			lnet_peer_ni_decref_locked(lpni);
+		}
 	}
+
 	for (i = 0; i < ndelnis; i++) {
 		rc = lnet_peer_del_nid(lp, delnis[i], flags);
 		if (rc) {
-- 
1.8.3.1
