Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6C770C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:33:26 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1797321FC89;
	Sun, 20 Mar 2022 06:32:22 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 75DC221F9CF
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:22 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 9E9EE102F;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9A3CBDD6ED; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:31:02 -0400
Message-Id: <1647783064-20688-49-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 48/50] lnet: Stop discovery on deleted peer NI
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

lnet_discover_peer_locked() needs to check whether the peer NI that is
undergoing discovery has been deleted (i.e. its assocaited peer has
LNET_PEER_MARK_DELETED state). Otherwise, we may enter an infinite
loop because this peer will never be considered up to date.

Fixes: 4f69acf8aa ("lnet: Prevent discovery on deleted peer")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15512
Lustre-commit: 94f4e1f517d71ffd6 ("LU-15512 lnet: Stop discovery on deleted peer NI")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/46429
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 16a694c..98f71dd 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2578,6 +2578,8 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 			break;
 		if (lnet_peer_is_uptodate(lp))
 			break;
+		if (lp->lp_state & LNET_PEER_MARK_DELETED)
+			break;
 		lnet_peer_queue_for_discovery(lp);
 		count++;
 		CDEBUG(D_NET, "Discovery attempt # %d\n", count);
@@ -2620,7 +2622,9 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 		rc = lp->lp_dc_error;
 	else if (!block)
 		CDEBUG(D_NET, "non-blocking discovery\n");
-	else if (!lnet_peer_is_uptodate(lp) && !lnet_is_discovery_disabled(lp))
+	else if (!lnet_peer_is_uptodate(lp) &&
+		 !(lnet_is_discovery_disabled(lp) ||
+		   (lp->lp_state & LNET_PEER_MARK_DELETED)))
 		goto again;
 
 	CDEBUG(D_NET, "peer %s NID %s: %d. %s\n",
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
