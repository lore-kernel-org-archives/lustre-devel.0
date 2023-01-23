Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6D77AC05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:30:35 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Ql3kbwz215b;
	Mon, 23 Jan 2023 15:09:35 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15PV2pK4z22SK
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:08:30 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 9CB1BE01;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9A56558994; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:46 -0500
Message-Id: <1674514855-15399-34-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 33/42] lnet: asym route inconsistency warning
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Gian-Carlo DeFazio <defazio1@llnl.gov>

remove LNET_UNDEFINED_HOPS from lnet_check_route_inconsistency()
where it is being treated as equivalent to 1 for the
value of lr_hops.

Due to the changes made in commit 3f2844dc9
"LU-14945 lnet: don't use hops to determine the route state",
LNET_UNDEFINED_HOPS is no longer considered equivalent to 1
for lr_hops in all cases, and it is valid to leave hops undefined
for multi-hop routes.

Therefore, having a multi-hop route with a hops of
LNET_UNDEFINED_HOPS is no longer inconsistent.

Fixes: 546bdd11a7 ("lnet: asym route inconsistency warning")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14555
Lustre-commit: 6aed5df1771c299b5 ("LU-14555 lnet: asym route inconsistency warning")
Signed-off-by: Gian-Carlo DeFazio <defazio1@llnl.gov>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49352
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 88a5b69e1f2e..c73e649fe07b 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -369,8 +369,7 @@ lnet_consolidate_routes_locked(struct lnet_peer *orig_lp,
 static inline void
 lnet_check_route_inconsistency(struct lnet_route *route)
 {
-	if (!route->lr_single_hop &&
-	    (route->lr_hops == 1 || route->lr_hops == LNET_UNDEFINED_HOPS) &&
+	if (!route->lr_single_hop && route->lr_hops == 1 &&
 	    avoid_asym_router_failure) {
 		CWARN("route %s->%s is detected to be multi-hop but hop count is set to %d\n",
 		      libcfs_net2str(route->lr_net),
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
