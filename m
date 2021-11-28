Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E1298C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:43 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 331F421C905;
	Sun, 28 Nov 2021 15:28:27 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 012F9200F3F
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:28:01 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A7BC525D;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A4C30C1ADA; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:46 -0500
Message-Id: <1638142074-5945-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/19] lnet: Fail peer add for existing gw
 peer
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

If there's an existing peer entry for a peer that is being added
via CLI, and that existing peer was not created via the CLI, then
DLC will attempt to delete the existing peer before creating a new
one. The exit status of the peer deletion was not being checked.
This results in the ability to add duplicate peers for gateways,
because gateways cannot be deleted via lnetctl unless the routes
for that gateway have been removed first.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15138
Lustre-commit: 79a4b69adb1e365b1 ("LU-15138 lnet: Fail peer add for existing gw peer")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/45337
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 1853388..a9f33c0 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -499,12 +499,14 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 static int
 lnet_peer_del(struct lnet_peer *peer)
 {
+	int rc;
+
 	lnet_peer_cancel_discovery(peer);
 	lnet_net_lock(LNET_LOCK_EX);
-	lnet_peer_del_locked(peer);
+	rc = lnet_peer_del_locked(peer);
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	return 0;
+	return rc;
 }
 
 /*
@@ -1648,7 +1650,9 @@ struct lnet_peer_net *
 			}
 		}
 		/* Delete and recreate as a configured peer. */
-		lnet_peer_del(lp);
+		rc = lnet_peer_del(lp);
+		if (rc)
+			goto out;
 	}
 
 	/* Create peer, peer_net, and peer_ni. */
@@ -3238,6 +3242,7 @@ static int lnet_peer_deletion(struct lnet_peer *lp)
 	struct list_head rlist;
 	struct lnet_route *route, *tmp;
 	int sensitivity = lp->lp_health_sensitivity;
+	int rc;
 
 	INIT_LIST_HEAD(&rlist);
 
@@ -3271,7 +3276,10 @@ static int lnet_peer_deletion(struct lnet_peer *lp)
 	lnet_net_unlock(LNET_LOCK_EX);
 
 	/* lnet_peer_del() deletes all the peer NIs owned by this peer */
-	lnet_peer_del(lp);
+	rc = lnet_peer_del(lp);
+	if (rc)
+		CNETERR("Internal error: Unable to delete peer %s rc %d\n",
+			libcfs_nidstr(&lp->lp_primary_nid), rc);
 
 	list_for_each_entry_safe(route, tmp,
 				 &rlist, lr_list) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
