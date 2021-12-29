Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E25B6C433F5
	for <lustre-devel@archiver.kernel.org>; Wed, 29 Dec 2021 14:51:33 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 389573AD50E;
	Wed, 29 Dec 2021 06:51:33 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9E3393AD371
 for <lustre-devel@lists.lustre.org>; Wed, 29 Dec 2021 06:51:30 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 81F051006F03;
 Wed, 29 Dec 2021 09:51:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7C6D8D9E6F; Wed, 29 Dec 2021 09:51:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed, 29 Dec 2021 09:51:16 -0500
Message-Id: <1640789487-22279-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
References: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/13] lnet: Revert "lnet: Lock primary NID
 logic"
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

This patch breaks client mounts under certain LNet configurations.

This reverts commit f2f168e3daf12850f40f991d74e04eb283c2376f

WC-bug-id: https://jira.whamcloud.com/browse/LU-15169
Lustre-commit: f2f168e3daf12850f ("LU-15169 Revert "LU-14668 lnet: Lock primary NID logic")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/45386
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 67 +++++++++++++---------------------------------------
 1 file changed, 16 insertions(+), 51 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index a9f33c0..cca458f 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -535,15 +535,6 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 		}
 	}
 
-	/* If we're asked to lock down the primary NID we shouldn't be
-	 * deleting it
-	 */
-	if (lp->lp_state & LNET_PEER_LOCK_PRIMARY &&
-	    nid_same(&primary_nid, &nid)) {
-		rc = -EPERM;
-		goto out;
-	}
-
 	lpni = lnet_peer_ni_find_locked(&nid);
 	if (!lpni) {
 		rc = -ENOENT;
@@ -1448,18 +1439,13 @@ struct lnet_peer_ni *
 	 * down then this discovery can introduce long delays into the mount
 	 * process, so skip it if it isn't necessary.
 	 */
-	if (!lnet_peer_discovery_disabled && !lnet_peer_is_uptodate(lp)) {
+	while (!lnet_peer_discovery_disabled && !lnet_peer_is_uptodate(lp)) {
 		spin_lock(&lp->lp_lock);
 		/* force a full discovery cycle */
-		lp->lp_state |= LNET_PEER_FORCE_PING | LNET_PEER_FORCE_PUSH |
-				LNET_PEER_LOCK_PRIMARY;
+		lp->lp_state |= LNET_PEER_FORCE_PING | LNET_PEER_FORCE_PUSH;
 		spin_unlock(&lp->lp_lock);
 
-		/* start discovery in the background. Messages to that
-		 * peer will not go through until the discovery is
-		 * complete
-		 */
-		rc = lnet_discover_peer_locked(lpni, cpt, false);
+		rc = lnet_discover_peer_locked(lpni, cpt, true);
 		if (rc)
 			goto out_decref;
 		/* The lpni (or lp) for this NID may have changed and our ref is
@@ -1473,6 +1459,14 @@ struct lnet_peer_ni *
 			goto out_unlock;
 		}
 		lp = lpni->lpni_peer_net->lpn_peer;
+
+		/* If we find that the peer has discovery disabled then we will
+		 * not modify whatever primary NID is currently set for this
+		 * peer. Thus, we can break out of this loop even if the peer
+		 * is not fully up to date.
+		 */
+		if (lnet_is_discovery_disabled(lp))
+			break;
 	}
 	primary_nid = lnet_nid_to_nid4(&lp->lp_primary_nid);
 out_decref:
@@ -1579,8 +1573,6 @@ struct lnet_peer_net *
 			lnet_peer_clr_non_mr_pref_nids(lp);
 		}
 	}
-	if (flags & LNET_PEER_LOCK_PRIMARY)
-		lp->lp_state |= LNET_PEER_LOCK_PRIMARY;
 	spin_unlock(&lp->lp_lock);
 
 	lp->lp_nnis++;
@@ -1742,27 +1734,9 @@ struct lnet_peer_net *
 		}
 		/* If this is the primary NID, destroy the peer. */
 		if (lnet_peer_ni_is_primary(lpni)) {
-			struct lnet_peer *lp2 =
+			struct lnet_peer *rtr_lp =
 				lpni->lpni_peer_net->lpn_peer;
-			int rtr_refcount = lp2->lp_rtr_refcount;
-
-			/* If the new peer that this NID belongs to is
-			 * a primary NID for another peer which we're
-			 * suppose to preserve the Primary for then we
-			 * don't want to mess with it. But the
-			 * configuration is wrong at this point, so we
-			 * should flag both of these peers as in a bad
-			 * state
-			 */
-			if (lp2->lp_state & LNET_PEER_LOCK_PRIMARY) {
-				spin_lock(&lp->lp_lock);
-				lp->lp_state |= LNET_PEER_BAD_CONFIG;
-				spin_unlock(&lp->lp_lock);
-				spin_lock(&lp2->lp_lock);
-				lp2->lp_state |= LNET_PEER_BAD_CONFIG;
-				spin_unlock(&lp2->lp_lock);
-				goto out_free_lpni;
-			}
+			int rtr_refcount = rtr_lp->lp_rtr_refcount;
 
 			/* if we're trying to delete a router it means
 			 * we're moving this peer NI to a new peer so must
@@ -1770,9 +1744,9 @@ struct lnet_peer_net *
 			 */
 			if (rtr_refcount > 0) {
 				flags |= LNET_PEER_RTR_NI_FORCE_DEL;
-				lnet_rtr_transfer_to_peer(lp2, lp);
+				lnet_rtr_transfer_to_peer(rtr_lp, lp);
 			}
-			lnet_peer_del(lp2);
+			lnet_peer_del(lpni->lpni_peer_net->lpn_peer);
 			lnet_peer_ni_decref_locked(lpni);
 			lpni = lnet_peer_ni_alloc(&nid);
 			if (!lpni) {
@@ -1830,8 +1804,7 @@ struct lnet_peer_net *
 	if (lnet_nid_to_nid4(&lp->lp_primary_nid) == nid)
 		goto out;
 
-	if (!(lp->lp_state & LNET_PEER_LOCK_PRIMARY))
-		lnet_nid4_to_nid(nid, &lp->lp_primary_nid);
+	lnet_nid4_to_nid(nid, &lp->lp_primary_nid);
 
 	rc = lnet_peer_add_nid(lp, nid, flags);
 	if (rc) {
@@ -1839,14 +1812,6 @@ struct lnet_peer_net *
 		goto out;
 	}
 out:
-	/* if this is a configured peer or the primary for that peer has
-	 * been locked, then we don't want to flag this scenario as
-	 * a failure
-	 */
-	if (lp->lp_state & LNET_PEER_CONFIGURED ||
-	    lp->lp_state & LNET_PEER_LOCK_PRIMARY)
-		return 0;
-
 	CDEBUG(D_NET, "peer %s NID %s: %d\n",
 	       libcfs_nidstr(&old), libcfs_nid2str(nid), rc);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
