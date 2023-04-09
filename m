Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4A4F2C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:39:05 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWRm6jGHz22Vc;
	Sun,  9 Apr 2023 05:21:24 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWNc3dykz22Q0
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:18:40 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 49352100848B;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 47B482AB; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:09 -0400
Message-Id: <1681042400-15491-30-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 29/40] lnet: don't delete peer created by
 Lustre
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

Peers created by Lustre have their primary NIDs locked.
If that peer is deleted, it'll confuse lustre. So when manually
deleting a peer using:
   lnetctl peer del --prim_nid ...
We must continue to preserve the primary NID. Therefore we delete
all the constituent NIDs, but keep the primary NID. We then
flag the peer for rediscovery.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14668
Lustre-commit: 7cc5b4329fc2eecbf ("LU-14668 lnet: don't delete peer created by Lustre")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/43565
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 45 +++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 43 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index fa2ca54..0a5e73a 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1983,6 +1983,40 @@ int lnet_user_add_peer_ni(struct lnet_nid *prim_nid, struct lnet_nid *nid, bool
 	return lnet_add_peer_ni(prim_nid, nid, mr, LNET_PEER_CONFIGURED);
 }
 
+static int
+lnet_reset_peer(struct lnet_peer *lp)
+{
+	struct lnet_peer_net *lpn, *lpntmp;
+	struct lnet_peer_ni *lpni, *lpnitmp;
+	unsigned int flags;
+	int rc;
+
+	lnet_peer_cancel_discovery(lp);
+
+	flags = LNET_PEER_CONFIGURED;
+	if (lp->lp_state & LNET_PEER_MULTI_RAIL)
+		flags |= LNET_PEER_MULTI_RAIL;
+
+	list_for_each_entry_safe(lpn, lpntmp, &lp->lp_peer_nets, lpn_peer_nets) {
+		list_for_each_entry_safe(lpni, lpnitmp, &lpn->lpn_peer_nis,
+					 lpni_peer_nis) {
+			if (nid_same(&lpni->lpni_nid, &lp->lp_primary_nid))
+				continue;
+
+			rc = lnet_peer_del_nid(lp, &lpni->lpni_nid, flags);
+			if (rc) {
+				CERROR("Failed to delete %s from peer %s\n",
+				       libcfs_nidstr(&lpni->lpni_nid),
+				       libcfs_nidstr(&lp->lp_primary_nid));
+			}
+		}
+	}
+
+	/* mark it for discovery the next time we use it */
+	lp->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
+	return 0;
+}
+
 /*
  * Implementation of IOC_LIBCFS_DEL_PEER_NI.
  *
@@ -2026,8 +2060,15 @@ int lnet_user_add_peer_ni(struct lnet_nid *prim_nid, struct lnet_nid *nid, bool
 	}
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	if (LNET_NID_IS_ANY(nid) || nid_same(nid, &lp->lp_primary_nid))
-		return lnet_peer_del(lp);
+	if (LNET_NID_IS_ANY(nid) || nid_same(nid, &lp->lp_primary_nid)) {
+		if (lp->lp_state & LNET_PEER_LOCK_PRIMARY) {
+			CERROR("peer %s created by Lustre. Must preserve primary NID, but will remove other NIDs\n",
+			       libcfs_nidstr(&lp->lp_primary_nid));
+			return lnet_reset_peer(lp);
+		} else {
+			return lnet_peer_del(lp);
+		}
+	}
 
 	flags = LNET_PEER_CONFIGURED;
 	if (lp->lp_state & LNET_PEER_MULTI_RAIL)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
