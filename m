Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 06101C25B50
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:07:24 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Hb1LhCz1yGG;
	Mon, 23 Jan 2023 15:03:23 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15F320h1z1y34
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:01:11 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 28E546C9;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 23FB458987; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:18 -0500
Message-Id: <1674514855-15399-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/42] lnet: change lnet_find_best_lpni to
 handle large NIDs
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

Currently lnet_find_best_lpni() only handles small NID addresses
for the dst_nid. Change this to large NID address to allow IPv6
and other large address protocols.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 4c0c01e29c891d100 ("LU-10391 lnet: change lnet_find_best_lpni to handle large NIDs")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49181
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 net/lnet/lnet/lib-move.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index f602492ee75f..95abe4f15c48 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1114,7 +1114,7 @@ lnet_return_rx_credits_locked(struct lnet_msg *msg)
 }
 
 static struct lnet_peer_ni *
-lnet_select_peer_ni(struct lnet_ni *best_ni, lnet_nid_t dst_nid,
+lnet_select_peer_ni(struct lnet_ni *best_ni, struct lnet_nid *dst_nid,
 		    struct lnet_peer *peer,
 		    struct lnet_peer_ni *best_lpni,
 		    struct lnet_peer_net *peer_net)
@@ -1220,7 +1220,7 @@ lnet_select_peer_ni(struct lnet_ni *best_ni, lnet_nid_t dst_nid,
 	/* if we still can't find a peer ni then we can't reach it */
 	if (!best_lpni) {
 		u32 net_id = (peer_net) ? peer_net->lpn_net_id :
-			     LNET_NIDNET(dst_nid);
+			     LNET_NID_NET(dst_nid);
 		CDEBUG(D_NET, "no peer_ni found on peer net %s\n",
 		       libcfs_net2str(net_id));
 		return NULL;
@@ -1242,7 +1242,7 @@ lnet_select_peer_ni(struct lnet_ni *best_ni, lnet_nid_t dst_nid,
  * ones.
  */
 static inline struct lnet_peer_ni *
-lnet_find_best_lpni(struct lnet_ni *lni, lnet_nid_t dst_nid,
+lnet_find_best_lpni(struct lnet_ni *lni, struct lnet_nid *dst_nid,
 		    struct lnet_peer *peer, u32 net_id)
 {
 	struct lnet_peer_net *peer_net;
@@ -1350,7 +1350,7 @@ lnet_find_route_locked(struct lnet_remotenet *rnet, u32 src_net,
 			 * src_net provided. If the src_net is LNET_NID_ANY,
 			 * then select the best interface available.
 			 */
-			lpni = lnet_find_best_lpni(NULL, LNET_NID_ANY,
+			lpni = lnet_find_best_lpni(NULL, NULL,
 						   route->lr_gateway,
 						   src_net);
 			if (!lpni) {
@@ -1395,8 +1395,7 @@ lnet_find_route_locked(struct lnet_remotenet *rnet, u32 src_net,
 		 * src_net provided. If the src_net is LNET_NID_ANY,
 		 * then select the best interface available.
 		 */
-		lpni = lnet_find_best_lpni(NULL, LNET_NID_ANY,
-					   route->lr_gateway,
+		lpni = lnet_find_best_lpni(NULL, NULL, route->lr_gateway,
 					   src_net);
 		if (!lpni) {
 			CDEBUG(D_NET,
@@ -2108,7 +2107,7 @@ lnet_handle_find_routed_path(struct lnet_send_data *sd,
 			       libcfs_net2str(best_lpn->lpn_net_id));
 
 			sd->sd_best_lpni = lnet_find_best_lpni(sd->sd_best_ni,
-							       lnet_nid_to_nid4(&sd->sd_dst_nid),
+							       &sd->sd_dst_nid,
 							       lp,
 							       best_lpn->lpn_net_id);
 			if (!sd->sd_best_lpni) {
@@ -2540,8 +2539,7 @@ lnet_handle_any_mr_dsta(struct lnet_send_data *sd)
 					lnet_msg_discovery(sd->sd_msg));
 	if (sd->sd_best_ni) {
 		sd->sd_best_lpni =
-		  lnet_find_best_lpni(sd->sd_best_ni,
-				      lnet_nid_to_nid4(&sd->sd_dst_nid),
+		  lnet_find_best_lpni(sd->sd_best_ni, &sd->sd_dst_nid,
 				      sd->sd_peer,
 				      sd->sd_best_ni->ni_net->net_id);
 
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
