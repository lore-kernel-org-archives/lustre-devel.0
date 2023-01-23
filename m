Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 21B39C05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:04:49 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15G72dxGz1yCy;
	Mon, 23 Jan 2023 15:02:07 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15Dy4cf2z1wcg
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:01:06 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 21F4A6C7;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1CA1758994; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:16 -0500
Message-Id: <1674514855-15399-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/42] lnet: router_discover - handle large
 addrs in ping
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

From: Mr NeilBrown <neilb@suse.de>

lnet_router_discover_ping_reply() now considers the large
nids in the ping message.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 2d916eec68e8a7d35 ("LU-10391 lnet: router_discover - handle large addrs in ping")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/44631
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 358c3f1fcb1c..88a5b69e1f2e 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -388,12 +388,13 @@ lnet_router_discovery_ping_reply(struct lnet_peer *lp,
 				 struct lnet_ping_buffer *pbuf)
 __must_hold(&the_lnet.ln_api_mutex)
 {
+	struct lnet_ping_iter piter;
 	struct lnet_peer_net *llpn;
 	struct lnet_route *route;
+	struct lnet_nid nid;
 	bool single_hop = false;
 	bool net_up = false;
-	u32 net;
-	int i;
+	u32 *stp;
 
 	if (pbuf->pb_info.pi_features & LNET_PING_FEAT_RTE_DISABLED) {
 		CERROR("Peer %s is being used as a gateway but routing feature is not turned on\n",
@@ -427,13 +428,12 @@ __must_hold(&the_lnet.ln_api_mutex)
 
 		single_hop = false;
 		net_up = false;
-		for (i = 1; i < pbuf->pb_info.pi_nnis; i++) {
-			net = LNET_NIDNET(pbuf->pb_info.pi_ni[i].ns_nid);
-
-			if (route->lr_net == net) {
+		for (stp = ping_iter_first(&piter, pbuf, &nid);
+		     stp;
+		     stp = ping_iter_next(&piter, &nid)) {
+			if (route->lr_net == LNET_NID_NET(&nid)) {
 				single_hop = true;
-				if (pbuf->pb_info.pi_ni[i].ns_status ==
-				    LNET_NI_STATUS_UP) {
+				if (*stp == LNET_NI_STATUS_UP) {
 					net_up = true;
 					break;
 				}
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
