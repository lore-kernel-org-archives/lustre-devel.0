Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C81CBC433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:25 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7DC47610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DC47610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EA78A32F7C4;
	Wed, 14 Apr 2021 21:03:11 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D9E6C32F3FA
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:48 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 5BD8D100F339;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 5369891894; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:01:59 -0400
Message-Id: <1618459361-17909-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/49] lnet: Transfer disc src NID when
 merging peers
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

If we're merging two peers in lnet_peer_data_present() then we need
to transfer the src NID stored in the peer whose ping buffer we are
processing to the peer that actually owns the NIDs in the ping
buffer. Otherwise it is possible that the subsequent push to the peer
that is being discovered will go out over an interface that the peer
does not know about and it will be dropped.

HPE-bug-id: LUS-9193
WC-bug-id: https://jira.whamcloud.com/browse/LU-13894
Lustre-commit: e65d8ba583858ae1 ("LU-13894 lnet: Transfer disc src NID when merging peers")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39607
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 34153a8..1b240f1 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3116,7 +3116,7 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 		rc = lnet_peer_merge_data(lp, pbuf);
 	} else {
 		lpni = lnet_find_peer_ni_locked(nid);
-		if (!lpni) {
+		if (!lpni || lp == lpni->lpni_peer_net->lpn_peer) {
 			rc = lnet_peer_set_primary_nid(lp, nid, flags);
 			if (rc) {
 				CERROR("Primary NID error %s versus %s: %d\n",
@@ -3125,6 +3125,8 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 			} else {
 				rc = lnet_peer_merge_data(lp, pbuf);
 			}
+			if (lpni)
+				lnet_peer_ni_decref_locked(lpni);
 		} else {
 			struct lnet_peer *new_lp;
 
@@ -3133,10 +3135,22 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 			 * should have discovery/MR enabled as well, since
 			 * it's the same peer, which we're about to merge
 			 */
+			spin_lock(&lp->lp_lock);
+			spin_lock(&new_lp->lp_lock);
 			if (!(lp->lp_state & LNET_PEER_NO_DISCOVERY))
 				new_lp->lp_state &= ~LNET_PEER_NO_DISCOVERY;
 			if (lp->lp_state & LNET_PEER_MULTI_RAIL)
 				new_lp->lp_state |= LNET_PEER_MULTI_RAIL;
+			/* If we're processing a ping reply then we may be
+			 * about to send a push to the peer that we ping'd.
+			 * Since the ping reply that we're processing was
+			 * received by lp, we need to set the discovery source
+			 * NID for new_lp to the NID stored in lp.
+			 */
+			if (lp->lp_disc_src_nid != LNET_NID_ANY)
+				new_lp->lp_disc_src_nid = lp->lp_disc_src_nid;
+			spin_unlock(&new_lp->lp_lock);
+			spin_unlock(&lp->lp_lock);
 
 			rc = lnet_peer_set_primary_data(new_lp, pbuf);
 			lnet_consolidate_routes_locked(lp, new_lp);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
