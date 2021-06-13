Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08055C48BDF
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:44 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C6F106136E
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6F106136E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5A24C21F3E6;
	Sun, 13 Jun 2021 16:12:18 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B306321F2F4
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:47 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id EF132100BAE3;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EE1939C306; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:36 -0400
Message-Id: <1623625897-17706-27-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 26/27] lnet: Check if discovery toggled off
 in ping reply
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

If a peer is initially discovered and found to have discovery
enabled, but the peer later reloads LNet with discovery disabled,
then we can delete the peer and re-create it the next time the peer
is discovered.

It is safe to delete and re-create the peer as long as it wasn't
configured manually.

In lnet_peer_deletion(), we need to use lnet_del_init() when removing
the peer from the discovery queue because the lnet_peer_del() code
path can result in a call to lnet_peer_queue_for_discovery() where
we check if the lp_dc_list is empty.

HPE-bug-id: LUS-9178
Fixes: 7ec94557b1 ("lnet: Prevent discovery on peer marked deletion")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14661
Lustre-commit: 143893381d428466 ("LU-14661 lnet: Check if discovery toggled off in ping reply")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/43508
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 28 ++++++++++++++++++++--------
 1 file changed, 20 insertions(+), 8 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 7630aff..2fc784d 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2254,22 +2254,34 @@ void lnet_peer_push_event(struct lnet_event *ev)
 	/* The peer may have discovery disabled at its end. Set
 	 * NO_DISCOVERY as appropriate.
 	 */
-	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_DISCOVERY)) {
+	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_DISCOVERY) ||
+	    lnet_peer_discovery_disabled) {
 		CDEBUG(D_NET, "Peer %s has discovery disabled\n",
 		       libcfs_nid2str(lp->lp_primary_nid));
-		/* Mark the peer for deletion if we already know about it
-		 * and it's going from discovery set to no discovery set
+
+		/* Detect whether this peer has toggled discovery from on to
+		 * off and whether we can delete and re-create the peer. Peers
+		 * that were manually configured cannot be deleted by discovery.
+		 * We need to delete this peer and re-create it if the peer was
+		 * not configured manually, is currently considered DD capable,
+		 * and either:
+		 * 1. We've already discovered the peer (the peer has toggled
+		 *    the discovery feature from on to off), or
+		 * 2. The peer is considered MR, but it was not user configured
+		 *    (this was a "temporary" peer created via the kernel APIs
+		 *     that we're discovering for the first time)
 		 */
-		if (!(lp->lp_state & (LNET_PEER_NO_DISCOVERY |
-				      LNET_PEER_DISCOVERING)) &&
-		    lp->lp_state & LNET_PEER_DISCOVERED) {
+		if (!(lp->lp_state & (LNET_PEER_CONFIGURED |
+				      LNET_PEER_NO_DISCOVERY)) &&
+		    (lp->lp_state & (LNET_PEER_DISCOVERED |
+				     LNET_PEER_MULTI_RAIL))) {
 			CDEBUG(D_NET, "Marking %s:0x%x for deletion\n",
 			       libcfs_nid2str(lp->lp_primary_nid),
 			       lp->lp_state);
 			lp->lp_state |= LNET_PEER_MARK_DELETION;
 		}
 		lp->lp_state |= LNET_PEER_NO_DISCOVERY;
-	} else if (lp->lp_state & LNET_PEER_NO_DISCOVERY) {
+	} else {
 		CDEBUG(D_NET, "Peer %s has discovery enabled\n",
 		       libcfs_nid2str(lp->lp_primary_nid));
 		lp->lp_state &= ~LNET_PEER_NO_DISCOVERY;
@@ -3083,7 +3095,7 @@ static int lnet_peer_deletion(struct lnet_peer *lp)
 	 * of deleting it.
 	 */
 	if (!list_empty(&lp->lp_dc_list))
-		list_del(&lp->lp_dc_list);
+		list_del_init(&lp->lp_dc_list);
 	list_for_each_entry_safe(route, tmp,
 				 &lp->lp_routes,
 				 lr_gwlist)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
