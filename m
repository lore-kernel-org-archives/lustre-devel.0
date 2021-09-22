Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A96A5C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:19 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 61D6361168
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 61D6361168
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6169021F280;
	Tue, 21 Sep 2021 19:20:14 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0503121C8F2
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:05 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 0665F34F;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EB351FF4A8; Tue, 21 Sep 2021 22:20:03 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:38 -0400
Message-Id: <1632277201-6920-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/24] lnet: Lock primary NID logic
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

WC-bug-id: https://jira.whamcloud.com/browse/LU-14668
Lustre-commit: 024f9303bc6f32a31 ("LU-14668 lnet: Lock primary NID logic")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43563
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 69 ++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 53 insertions(+), 16 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index c2f5d8b..720af99 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -530,6 +530,16 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 			goto out;
 		}
 	}
+
+	/* If we're asked to lock down the primary NID we shouldn't be
+	 * deleting it
+	 */
+	if (lp->lp_state & LNET_PEER_LOCK_PRIMARY &&
+	    primary_nid == nid) {
+		rc = -EPERM;
+		goto out;
+	}
+
 	lpni = lnet_find_peer_ni_locked(nid);
 	if (!lpni) {
 		rc = -ENOENT;
@@ -1388,13 +1398,18 @@ struct lnet_peer_ni *
 	 * down then this discovery can introduce long delays into the mount
 	 * process, so skip it if it isn't necessary.
 	 */
-	while (!lnet_peer_discovery_disabled && !lnet_peer_is_uptodate(lp)) {
+	if (!lnet_peer_discovery_disabled && !lnet_peer_is_uptodate(lp)) {
 		spin_lock(&lp->lp_lock);
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
@@ -1408,14 +1423,6 @@ struct lnet_peer_ni *
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
 	}
 	primary_nid = lp->lp_primary_nid;
 out_decref:
@@ -1522,6 +1529,8 @@ struct lnet_peer_net *
 			lnet_peer_clr_non_mr_pref_nids(lp);
 		}
 	}
+	if (flags & LNET_PEER_LOCK_PRIMARY)
+		lp->lp_state |= LNET_PEER_LOCK_PRIMARY;
 	spin_unlock(&lp->lp_lock);
 
 	lp->lp_nnis++;
@@ -1676,9 +1685,27 @@ struct lnet_peer_net *
 		}
 		/* If this is the primary NID, destroy the peer. */
 		if (lnet_peer_ni_is_primary(lpni)) {
-			struct lnet_peer *rtr_lp =
+			struct lnet_peer *lp2 =
 				lpni->lpni_peer_net->lpn_peer;
-			int rtr_refcount = rtr_lp->lp_rtr_refcount;
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
@@ -1686,9 +1713,9 @@ struct lnet_peer_net *
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
@@ -1746,7 +1773,8 @@ struct lnet_peer_net *
 	if (lp->lp_primary_nid == nid)
 		goto out;
 
-	lp->lp_primary_nid = nid;
+	if (!(lp->lp_state & LNET_PEER_LOCK_PRIMARY))
+		lp->lp_primary_nid = nid;
 
 	rc = lnet_peer_add_nid(lp, nid, flags);
 	if (rc) {
@@ -1754,8 +1782,17 @@ struct lnet_peer_net *
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
 	       libcfs_nid2str(old), libcfs_nid2str(nid), rc);
+
 	return rc;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
