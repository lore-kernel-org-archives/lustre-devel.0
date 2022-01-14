Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9BF5FC433EF
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:19 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C0E9C3B60F7;
	Thu, 13 Jan 2022 17:38:16 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5BBC13AD861
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:11 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id DE219100F335;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id DCC2EA8102; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:55 -0500
Message-Id: <1642124283-10148-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/24] lnet: Skip router discovery on send
 path
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

When the router checker is enabled, routes are regularly marked as out
of date w.r.t. discovery. This can cause upper level messages to be
delayed while the router undergoes discovery. We can avoid delaying
messages by relying on the router checker to initiate discovery of
routers. If we happen to send a message to a router before it has
been discovered then the worst case scenario is that the route is
actually down or we end up utilizing a subset of a multi-rail router's
interfaces. Both situations can be remedied by utilizing the
check_routers_before_use parameter.

Change the logic in lnet_handle_find_routed_path() so that we only
initiate discovery if the alive_router_check_interval is <= 0 (i.e.
router checker pings are disabled).

WC-bug-id: https://jira.whamcloud.com/browse/LU-15275
Lustre-commit: c8e74c395d5634dbb ("LU-15275 lnet: Skip router discovery on send path")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/45684
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 133397e..8d4fd4d 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -2104,13 +2104,23 @@ struct lnet_ni *
 		LASSERT(gw == gwni->lpni_peer_net->lpn_peer);
 	}
 
-	/* Discover this gateway if it hasn't already been discovered.
-	 * This means we might delay the message until discovery has
-	 * completed
+	/* If the router checker is not active then discover the gateway here.
+	 * This ensures we are able to take advantage of multi-rail routing, but
+	 * if the router checker is active then we do not unecessarily delay
+	 * messages while the gateway is being checked by the dedicated monitor
+	 * thread.
+	 *
+	 * NB: We're only checking the alive_router_check_interval here, rather
+	 * than calling lnet_router_checker_active(), because the other
+	 * conditions that are checked by that function are either
+	 * irrelevant (the_lnet.ln_routing) or must be true (list of routers
+	 * is not empty)
 	 */
-	rc = lnet_initiate_peer_discovery(gwni, sd->sd_msg, sd->sd_cpt);
-	if (rc)
-		return rc;
+	if (alive_router_check_interval <= 0) {
+		rc = lnet_initiate_peer_discovery(gwni, sd->sd_msg, sd->sd_cpt);
+		if (rc)
+			return rc;
+	}
 
 	if (!sd->sd_best_ni) {
 		lpn = gwni->lpni_peer_net;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
