Return-Path: <SRS0=WSMT=J7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C284C433B4
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:11:00 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D363361185
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D363361185
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 70AC921F82C;
	Mon,  3 May 2021 17:10:43 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B83C721F597
 for <lustre-devel@lists.lustre.org>; Mon,  3 May 2021 17:10:24 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 36A51EE4;
 Mon,  3 May 2021 20:10:20 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3573F8AD3E; Mon,  3 May 2021 20:10:20 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  3 May 2021 20:10:12 -0400
Message-Id: <1620087016-17857-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
References: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/14] lnet: Skip discovery in LNetPrimaryNID
 if DD disabled
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

If discovery is disabled locally then the discovery thread will not
modify any peer objects as a result of the discovery process. Thus,
the primary NID of any peer we're asked to discover will not change
as a result of discovery. Therefore, we do not need to actually
perform discovery in LNetPrimaryNID() if discovery is disabled
locally. Since this routine can result in long client mount times
when a Lustre server is down we should avoid this unnecessary
discovery.

HPE-bug-id: LUS-9887
WC-bug-id: https://jira.whamcloud.com/browse/LU-14566
Lustre-commit: 16264da9e3c43a63 ("LU-14566 lnet: Skip discovery in LNetPrimaryNID if DD disabled")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/43141
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index db00514..d66a302 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1336,7 +1336,13 @@ struct lnet_peer_ni *
 	}
 	lp = lpni->lpni_peer_net->lpn_peer;
 
-	while (!lnet_peer_is_uptodate(lp)) {
+	/* If discovery is disabled locally then we needn't bother running
+	 * discovery here because discovery will not modify whatever
+	 * primary NID is currently set for this peer. If the specified peer is
+	 * down then this discovery can introduce long delays into the mount
+	 * process, so skip it if it isn't necessary.
+	 */
+	while (!lnet_peer_discovery_disabled && !lnet_peer_is_uptodate(lp)) {
 		spin_lock(&lp->lp_lock);
 		/* force a full discovery cycle */
 		lp->lp_state |= LNET_PEER_FORCE_PING | LNET_PEER_FORCE_PUSH;
@@ -1357,7 +1363,11 @@ struct lnet_peer_ni *
 		}
 		lp = lpni->lpni_peer_net->lpn_peer;
 
-		/* Only try once if discovery is disabled */
+		/* If we find that the peer has discovery disabled then we will
+		 * not modify whatever primary NID is currently set for this
+		 * peer. Thus, we can break out of this loop even if the peer
+		 * is not fully up to date.
+		 */
 		if (lnet_is_discovery_disabled(lp))
 			break;
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
