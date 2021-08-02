Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E237C4320E
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:54 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D021D60FC2
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org D021D60FC2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 33F4F352ED2;
	Mon,  2 Aug 2021 12:51:38 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CE5A535286A
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:56 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 60D341007B47;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 5CE14C2F4C; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:28 -0400
Message-Id: <1627933851-7603-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/25] lnet: Protect lpni deref in
 lnet_health_check
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

Discovery thread can modify peer NI/peer net/peer relationship
so we need to be careful when dereferencing the peer NI pointer in
lnet_health_check(). Discovery thread operations under net lock, so
move the peer NI dereference under the net lock which is taken for
incrementing the health stats.

Move some of the other code that is only relevant for messages with a
health status != LNET_MSG_STATUS_OK under the appropriate condition.

HPE-bug-id: LUS-9962
WC-bug-id: https://jira.whamcloud.com/browse/LU-14655
Lustre-commit: d87af24452a2e883 ("LU-14655 lnet: Protect lpni deref in lnet_health_check")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/43503
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-msg.c | 71 ++++++++++++++++++++++++++-----------------------
 1 file changed, 38 insertions(+), 33 deletions(-)

diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 580ddf6..e471848 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -821,38 +821,6 @@
 		attempt_remote_resend = false;
 	}
 
-	/* Don't further decrement the health value if a recovery message
-	 * failed.
-	 */
-	if (msg->msg_recovery) {
-		handle_local_health = false;
-		handle_remote_health = false;
-	} else {
-		handle_local_health = false;
-		handle_remote_health = true;
-	}
-
-	/* For local failures, health/recovery/resends are not needed if I only
-	 * have a single (non-lolnd) interface. NB: pb_nnis includes the lolnd
-	 * interface, so a single-rail node would have pb_nnis == 2.
-	 */
-	if (the_lnet.ln_ping_target->pb_nnis <= 2) {
-		handle_local_health = false;
-		attempt_local_resend = false;
-	}
-
-	/* For remote failures, health/recovery/resends are not needed if the
-	 * peer only has a single interface. Special case for routers where we
-	 * rely on health feature to manage route aliveness. NB: unlike pb_nnis
-	 * above, lp_nnis does _not_ include the lolnd, so a single-rail node
-	 * would have lp_nnis == 1.
-	 */
-	if (lpni && lpni->lpni_peer_net->lpn_peer->lp_nnis <= 1) {
-		attempt_remote_resend = false;
-		if (!lnet_isrouter(lpni))
-			handle_remote_health = false;
-	}
-
 	if (!lo)
 		LASSERT(ni && lpni);
 	else
@@ -865,11 +833,48 @@
 	       lnet_health_error2str(hstatus));
 
 	/* stats are only incremented for errors so avoid wasting time
-	 * incrementing statistics if there is no error.
+	 * incrementing statistics if there is no error. Similarly, whether to
+	 * update health values or perform resends is only applicable for
+	 * messages with a health status != OK.
 	 */
 	if (hstatus != LNET_MSG_STATUS_OK) {
+		/* Don't further decrement the health value if a recovery
+		 * message failed.
+		 */
+		if (msg->msg_recovery) {
+			handle_local_health = false;
+			handle_remote_health = false;
+		} else {
+			handle_local_health = true;
+			handle_remote_health = true;
+		}
+
+		/* For local failures, health/recovery/resends are not needed if
+		 * I only have a single (non-lolnd) interface. NB: pb_nnis
+		 * includes the lolnd interface, so a single-rail node would
+		 * have pb_nnis == 2.
+		 */
+		if (the_lnet.ln_ping_target->pb_nnis <= 2) {
+			handle_local_health = false;
+			attempt_local_resend = false;
+		}
+
 		lnet_net_lock(0);
 		lnet_incr_hstats(ni, lpni, hstatus);
+		/* For remote failures, health/recovery/resends are not needed
+		 * if the peer only has a single interface. Special case for
+		 * routers where we rely on health feature to manage route
+		 * aliveness. NB: unlike pb_nnis above, lp_nnis does _not_
+		 * include the lolnd, so a single-rail node would have
+		 * lp_nnis == 1.
+		 */
+		if (lpni && lpni->lpni_peer_net &&
+		    lpni->lpni_peer_net->lpn_peer &&
+		    lpni->lpni_peer_net->lpn_peer->lp_nnis <= 1) {
+			attempt_remote_resend = false;
+			if (!lnet_isrouter(lpni))
+				handle_remote_health = false;
+		}
 		lnet_net_unlock(0);
 	}
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
