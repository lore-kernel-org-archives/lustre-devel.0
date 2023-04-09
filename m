Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E1162C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:41:50 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWSZ6nZRz22WQ;
	Sun,  9 Apr 2023 05:22:06 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWMk4q8Nz21bB
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:17:54 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 3EBF41008489;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3D8782B2; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:07 -0400
Message-Id: <1681042400-15491-28-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 27/40] lnet: Lock primary NID logic
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Cc: Amir Shehata <ashehata@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Amir Shehata <ashehata@whamcloud.com>

If a peer is created by Lustre make sure to lock that peer's
primary NID. This peer can be discovered in the background.
There is no need to block until discovery is complete, as Lustre
can continue on with the primary NID it provided.

Discovery will populate the peer with other interfaces the peer has
but will not change the peer's primary NID. It can also delete
peer's NIDs which Lustre told it about (not the Primary NID).

If a peer has been manually discovered via
   lnetctl discover <nid>
command, then make sure to delete the manually discovered
 peer and recreate it with the Lustre NID information
provided for us.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14668
Lustre-commit: aacb16191a72bc6db ("LU-14668 lnet: Lock primary NID logic")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50106
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 106 +++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 86 insertions(+), 20 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index da1f8d4..0539cb4 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -534,6 +534,15 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 		}
 	}
 
+	/* If we're asked to lock down the primary NID we shouldn't be
+	 * deleting it
+	 */
+	if (lp->lp_state & LNET_PEER_LOCK_PRIMARY &&
+	    nid_same(&primary_nid, nid)) {
+		rc = -EPERM;
+		goto out;
+	}
+
 	lpni = lnet_peer_ni_find_locked(nid);
 	if (!lpni) {
 		rc = -ENOENT;
@@ -1358,6 +1367,19 @@ struct lnet_peer_ni *
 		if (LNET_NID_IS_ANY(&pnid)) {
 			lnet_nid4_to_nid(nids[i], &pnid);
 			rc = lnet_add_peer_ni(&pnid, &LNET_ANY_NID, mr, true);
+			if (rc == -EALREADY) {
+				struct lnet_peer *lp;
+
+				CDEBUG(D_NET, "A peer exists for NID %s\n",
+				       libcfs_nidstr(&pnid));
+				rc = 0;
+				/* Adds a refcount */
+				lp = lnet_find_peer(&pnid);
+				LASSERT(lp);
+				pnid = lp->lp_primary_nid;
+				/* Drop refcount from lookup */
+				lnet_peer_decref_locked(lp);
+			}
 		} else if (lnet_peer_discovery_disabled) {
 			lnet_nid4_to_nid(nids[i], &nid);
 			rc = lnet_add_peer_ni(&nid, &LNET_ANY_NID, mr, true);
@@ -1405,13 +1427,20 @@ void LNetPrimaryNID(struct lnet_nid *nid)
 	 * down then this discovery can introduce long delays into the mount
 	 * process, so skip it if it isn't necessary.
 	 */
-	while (!lnet_peer_discovery_disabled && !lnet_peer_is_uptodate(lp)) {
-		spin_lock(&lp->lp_lock);
+	spin_lock(&lp->lp_lock);
+	if (!lnet_peer_discovery_disabled &&
+	    (!(lp->lp_state & LNET_PEER_LOCK_PRIMARY) ||
+	     !lnet_peer_is_uptodate_locked(lp))) {
 		/* force a full discovery cycle */
-		lp->lp_state |= LNET_PEER_FORCE_PING | LNET_PEER_FORCE_PUSH;
+		lp->lp_state |= LNET_PEER_FORCE_PING | LNET_PEER_FORCE_PUSH |
+				LNET_PEER_LOCK_PRIMARY;
 		spin_unlock(&lp->lp_lock);
 
-		rc = lnet_discover_peer_locked(lpni, cpt, true);
+		/* start discovery in the background. Messages to that
+		 * peer will not go through until the discovery is
+		 * complete
+		 */
+		rc = lnet_discover_peer_locked(lpni, cpt, false);
 		if (rc)
 			goto out_decref;
 		/* The lpni (or lp) for this NID may have changed and our ref is
@@ -1425,14 +1454,8 @@ void LNetPrimaryNID(struct lnet_nid *nid)
 			goto out_unlock;
 		}
 		lp = lpni->lpni_peer_net->lpn_peer;
-
-		/* If we find that the peer has discovery disabled then we will
-		 * not modify whatever primary NID is currently set for this
-		 * peer. Thus, we can break out of this loop even if the peer
-		 * is not fully up to date.
-		 */
-		if (lnet_is_discovery_disabled(lp))
-			break;
+	} else {
+		spin_unlock(&lp->lp_lock);
 	}
 	*nid = lp->lp_primary_nid;
 out_decref:
@@ -1538,6 +1561,8 @@ struct lnet_peer_net *
 			lnet_peer_clr_non_mr_pref_nids(lp);
 		}
 	}
+	if (flags & LNET_PEER_LOCK_PRIMARY)
+		lp->lp_state |= LNET_PEER_LOCK_PRIMARY;
 	spin_unlock(&lp->lp_lock);
 
 	lp->lp_nnis++;
@@ -1599,13 +1624,28 @@ struct lnet_peer_net *
 			else if ((lp->lp_state ^ flags) & LNET_PEER_MULTI_RAIL)
 				rc = -EPERM;
 			goto out;
-		} else if (!(flags & LNET_PEER_CONFIGURED)) {
+		} else if (lp->lp_state & LNET_PEER_LOCK_PRIMARY) {
 			if (nid_same(&lp->lp_primary_nid, nid)) {
 				rc = -EEXIST;
 				goto out;
 			}
+			/* we're trying to recreate an existing peer which
+			 * has already been created and its primary
+			 * locked. This is likely due to two servers
+			 * existing on the same node. So we'll just refer
+			 * to that node with the primary NID which was
+			 * first added by Lustre
+			 */
+			rc = -EALREADY;
+			goto out;
 		}
-		/* Delete and recreate as a configured peer. */
+		/* Delete and recreate the peer.
+		 * We can get here:
+		 * 1. If the peer is being recreated as a configured NID
+		 * 2. if there already exists a peer which
+		 *    was discovered manually, but is recreated via Lustre
+		 *    with PRIMARY_lock
+		 */
 		rc = lnet_peer_del(lp);
 		if (rc)
 			goto out;
@@ -1695,19 +1735,36 @@ struct lnet_peer_net *
 		}
 		/* If this is the primary NID, destroy the peer. */
 		if (lnet_peer_ni_is_primary(lpni)) {
-			struct lnet_peer *rtr_lp =
+			struct lnet_peer *lp2 =
 				lpni->lpni_peer_net->lpn_peer;
-			int rtr_refcount = rtr_lp->lp_rtr_refcount;
-
+			int rtr_refcount = lp2->lp_rtr_refcount;
+
+			/* If the new peer that this NID belongs to is
+			 * a primary NID for another peer which we're
+			 * suppose to preserve the Primary for then we
+			 * don't want to mess with it. But the
+			 * configuration is wrong at this point, so we
+			 * should flag both of these peers as in a bad
+			 * state
+			 */
+			if (lp2->lp_state & LNET_PEER_LOCK_PRIMARY) {
+				spin_lock(&lp->lp_lock);
+				lp->lp_state |= LNET_PEER_BAD_CONFIG;
+				spin_unlock(&lp->lp_lock);
+				spin_lock(&lp2->lp_lock);
+				lp2->lp_state |= LNET_PEER_BAD_CONFIG;
+				spin_unlock(&lp2->lp_lock);
+				goto out_free_lpni;
+			}
 			/* if we're trying to delete a router it means
 			 * we're moving this peer NI to a new peer so must
 			 * transfer router properties to the new peer
 			 */
 			if (rtr_refcount > 0) {
 				flags |= LNET_PEER_RTR_NI_FORCE_DEL;
-				lnet_rtr_transfer_to_peer(rtr_lp, lp);
+				lnet_rtr_transfer_to_peer(lp2, lp);
 			}
-			lnet_peer_del(lpni->lpni_peer_net->lpn_peer);
+			lnet_peer_del(lp2);
 			lnet_peer_ni_decref_locked(lpni);
 			lpni = lnet_peer_ni_alloc(nid);
 			if (!lpni) {
@@ -1765,7 +1822,8 @@ struct lnet_peer_net *
 	if (nid_same(&lp->lp_primary_nid, nid))
 		goto out;
 
-	lp->lp_primary_nid = *nid;
+	if (!(lp->lp_state & LNET_PEER_LOCK_PRIMARY))
+		lp->lp_primary_nid = *nid;
 
 	rc = lnet_peer_add_nid(lp, nid, flags);
 	if (rc) {
@@ -1773,6 +1831,14 @@ struct lnet_peer_net *
 		goto out;
 	}
 out:
+	/* if this is a configured peer or the primary for that peer has
+	 * been locked, then we don't want to flag this scenario as
+	 * a failure
+	 */
+	if (lp->lp_state & LNET_PEER_CONFIGURED ||
+	    lp->lp_state & LNET_PEER_LOCK_PRIMARY)
+		return 0;
+
 	CDEBUG(D_NET, "peer %s NID %s: %d\n",
 	       libcfs_nidstr(&old), libcfs_nidstr(nid), rc);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
