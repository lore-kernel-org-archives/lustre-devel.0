Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7144BC4332F
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:38:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXl30xgcz21Jw;
	Sun, 20 Nov 2022 06:21:35 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXkv5rvlz1yC5
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:21:27 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id DFD4D10087CA;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id DD8E3E8B88; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:17:01 -0500
Message-Id: <1668953828-10909-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/22] lnet: fix debug message in
 lnet_discovery_event_reply
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

The message in lnet_discovery_event_reply currently says
"Peer X has discovery disabled" even though the same path
may be taken if discovery is disabled locally.
Change the debug message to indicate whether discovery is
disabled on the peer side or locally.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16282
Lustre-commit: 9f45a79e983c11def ("LU-16282 lnet: fix debug message in lnet_discovery_event_reply")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48997
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 52ad791..35b135e 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2592,6 +2592,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	struct lnet_ping_buffer *pbuf;
 	int infobytes;
 	int rc;
+	bool ping_feat_disc;
 
 	spin_lock(&lp->lp_lock);
 
@@ -2629,14 +2630,15 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 		goto out;
 	}
 
-	/*
-	 * The peer may have discovery disabled at its end. Set
+	/* The peer may have discovery disabled at its end. Set
 	 * NO_DISCOVERY as appropriate.
 	 */
-	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_DISCOVERY) &&
-	    lnet_peer_discovery_disabled) {
-		CDEBUG(D_NET, "Peer %s has discovery enabled\n",
-		       libcfs_nidstr(&lp->lp_primary_nid));
+	ping_feat_disc = pbuf->pb_info.pi_features & LNET_PING_FEAT_DISCOVERY;
+	if (!ping_feat_disc || lnet_peer_discovery_disabled) {
+		CDEBUG(D_NET, "Peer %s has discovery %s, local discovery %s\n",
+		       libcfs_nidstr(&lp->lp_primary_nid),
+		       ping_feat_disc ? "enabled" : "disabled",
+		       lnet_peer_discovery_disabled ? "disabled" : "enabled");
 
 		/* Detect whether this peer has toggled discovery from on to
 		 * off and whether we can delete and re-create the peer. Peers
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
