Return-Path: <SRS0=EXfh=KK=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDD16C433ED
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:48 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 83C26611C9
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83C26611C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F229721FA83;
	Sat, 15 May 2021 06:06:31 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9F50121CAD2
 for <lustre-devel@lists.lustre.org>; Sat, 15 May 2021 06:06:14 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7DD671006772;
 Sat, 15 May 2021 09:06:12 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 73D9998124; Sat, 15 May 2021 09:06:12 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sat, 15 May 2021 09:06:00 -0400
Message-Id: <1621083970-32463-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
References: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/13] lnet: Local NI must be on same net as
 next-hop
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

When sending to a remote peer we need to restrict our selection of a
local NI to those on the same peer net as the next-hop.

The code currently selects a local NI on the peer net specified by the
lr_lnet field of the lnet_route returned by lnet_find_route_locked().
However, lnet_find_route_locked() may select a next-hop peer NI on any
local peer net - not just lr_lnet.

A redundant assignment to sd->sd_msg->msg_src_nid_param is also
removed. That variable is always set appropriately in
lnet_select_pathway().

HPE-bug-id: LUS-9095
WC-bug-id: https://jira.whamcloud.com/browse/LU-13781
Lustre-commit: 031c087f3847777c ("LU-13781 lnet: Local NI must be on same net as next-hop")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39352
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 26 +++++++++-----------------
 1 file changed, 9 insertions(+), 17 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 6d0637c..3ae0209 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1907,7 +1907,6 @@ struct lnet_ni *
 			     struct lnet_peer **gw_peer)
 {
 	int rc;
-	u32 local_lnet;
 	struct lnet_peer *gw;
 	struct lnet_peer *lp;
 	struct lnet_peer_net *lpn;
@@ -1936,10 +1935,8 @@ struct lnet_ni *
 		if (gwni) {
 			gw = gwni->lpni_peer_net->lpn_peer;
 			lnet_peer_ni_decref_locked(gwni);
-			if (gw->lp_rtr_refcount) {
-				local_lnet = LNET_NIDNET(sd->sd_rtr_nid);
+			if (gw->lp_rtr_refcount)
 				route_found = true;
-			}
 		} else {
 			CWARN("No peer NI for gateway %s. Attempting to find an alternative route.\n",
 			       libcfs_nid2str(sd->sd_rtr_nid));
@@ -2054,31 +2051,26 @@ struct lnet_ni *
 
 		gw = best_route->lr_gateway;
 		LASSERT(gw == gwni->lpni_peer_net->lpn_peer);
-		local_lnet = best_route->lr_lnet;
 	}
 
 	/* Discover this gateway if it hasn't already been discovered.
 	 * This means we might delay the message until discovery has
 	 * completed
 	 */
-	sd->sd_msg->msg_src_nid_param = sd->sd_src_nid;
 	rc = lnet_initiate_peer_discovery(gwni, sd->sd_msg, sd->sd_cpt);
 	if (rc)
 		return rc;
 
 	if (!sd->sd_best_ni) {
-		struct lnet_peer_net *lpeer;
-
-		lpeer = lnet_peer_get_net_locked(gw, local_lnet);
-		sd->sd_best_ni = lnet_find_best_ni_on_spec_net(NULL, gw, lpeer,
+		lpn = gwni->lpni_peer_net;
+		sd->sd_best_ni = lnet_find_best_ni_on_spec_net(NULL, gw, lpn,
 							       sd->sd_md_cpt);
-	}
-
-	if (!sd->sd_best_ni) {
-		CERROR("Internal Error. Expected local ni on %s but non found :%s\n",
-		       libcfs_net2str(local_lnet),
-		       libcfs_nid2str(sd->sd_src_nid));
-		return -EFAULT;
+		if (!sd->sd_best_ni) {
+			CERROR("Internal Error. Expected local ni on %s but non found :%s\n",
+			       libcfs_net2str(lpn->lpn_net_id),
+			       libcfs_nid2str(sd->sd_src_nid));
+			return -EFAULT;
+		}
 	}
 
 	*gw_lpni = gwni;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
