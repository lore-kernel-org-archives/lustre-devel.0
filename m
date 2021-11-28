Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 20F83C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:12 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8586820134F;
	Sun, 28 Nov 2021 15:28:07 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 851AF200F3F
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:28:01 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A0F6324C;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9D0D8C1ACE; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:44 -0500
Message-Id: <1638142074-5945-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/19] lnet: Reset ni_ping_count only on
 receive
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

The lnet_ni:ni_ping_count is currently reset on every (healthy) tx.
We should only reset it when receiving a message over the NI. Taking
net_lock 0 on every tx results in a performance loss for certain
workloads.

Fixes: 885dab4e09 ("lnet: Recover local NI w/exponential backoff interval")
HPE-bug-id: LUS-10427
WC-bug-id: https://jira.whamcloud.com/browse/LU-15102
Lustre-commit: 9cc0a5ff5fc8f45aa ("LU-15102 lnet: Reset ni_ping_count only on receive")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/45235
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-msg.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 3c8b7c3..12768b2 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -888,8 +888,6 @@
 		 * faster recovery.
 		 */
 		lnet_inc_healthv(&ni->ni_healthv, lnet_health_sensitivity);
-		lnet_net_lock(0);
-		ni->ni_ping_count = 0;
 		/* It's possible msg_txpeer is NULL in the LOLND
 		 * case. Only increment the peer's health if we're
 		 * receiving a message from it. It's the only sure way to
@@ -898,7 +896,9 @@
 		 * as indication that the router is fully healthy.
 		 */
 		if (lpni && msg->msg_rx_committed) {
+			lnet_net_lock(0);
 			lpni->lpni_ping_count = 0;
+			ni->ni_ping_count = 0;
 			/* If we're receiving a message from the router or
 			 * I'm a router, then set that lpni's health to
 			 * maximum so we can commence communication
@@ -925,8 +925,8 @@
 								     &the_lnet.ln_mt_peerNIRecovq,
 								     ktime_get_seconds());
 			}
+			lnet_net_unlock(0);
 		}
-		lnet_net_unlock(0);
 
 		/* we can finalize this message */
 		return -1;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
