Return-Path: <SRS0=JyPa=L7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27591C07E9B
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:34 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3131961A13
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3131961A13
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2FC0A309ED3;
	Wed,  7 Jul 2021 12:11:29 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4905421F888
 for <lustre-devel@lists.lustre.org>; Wed,  7 Jul 2021 12:11:21 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 446E610090E8;
 Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3EDD59D8C0; Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  7 Jul 2021 15:11:07 -0400
Message-Id: <1625685076-1964-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
References: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/15] lnet: Correct distance calculation of
 local NIDs
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

Multi-rail peers can have multiple local NIDs on the same net, but
LNetDist() may only identify a NID as local if it is the first one
returned by lnet_get_next_ni_locked().

We need to check all local NIs to find a match for the target NID
in LNetDist().

Add test to check LNetDist() calculation of local NIDs for a peer with
multiple NIDs on the same net.

HPE-bug-id: LUS-9964
WC-bug-id: https://jira.whamcloud.com/browse/LU-14649
Lustre-commit: 4d0162037415988b ("LU-14649 lnet: Correct distance calculation of local NIDs")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/43498
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 40 +++++++++++++++++++++++++++-------------
 1 file changed, 27 insertions(+), 13 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 3ae0209..33d7e78 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -4981,6 +4981,7 @@ struct lnet_msg *
 	int cpt;
 	u32 order = 2;
 	struct list_head *rn_list;
+	bool matched_dstnet = false;
 
 	/*
 	 * if !local_nid_dist_zero, I don't return a distance of 0 ever
@@ -5007,27 +5008,40 @@ struct lnet_msg *
 			return local_nid_dist_zero ? 0 : 1;
 		}
 
-		if (LNET_NIDNET(ni->ni_nid) == dstnet) {
-			/*
-			 * Check if ni was originally created in
-			 * current net namespace.
-			 * If not, assign order above 0xffff0000,
-			 * to make this ni not a priority.
+		if (!matched_dstnet && LNET_NIDNET(ni->ni_nid) == dstnet) {
+			matched_dstnet = true;
+			/* We matched the destination net, but we may have
+			 * additional local NIs to inspect.
+			 *
+			 * We record the nid and order as appropriate, but
+			 * they may be overwritten if we match local NI above.
 			 */
-			if (current->nsproxy &&
-			    !net_eq(ni->ni_net_ns, current->nsproxy->net_ns))
-				order += 0xffff0000;
 			if (srcnidp)
 				*srcnidp = ni->ni_nid;
-			if (orderp)
-				*orderp = order;
-			lnet_net_unlock(cpt);
-			return 1;
+
+			if (orderp) {
+				/* Check if ni was originally created in
+				 * current net namespace.
+				 * If not, assign order above 0xffff0000,
+				 * to make this ni not a priority.
+				 */
+				if (current->nsproxy &&
+				    !net_eq(ni->ni_net_ns,
+					    current->nsproxy->net_ns))
+					*orderp = order + 0xffff0000;
+				else
+					*orderp = order;
+			}
 		}
 
 		order++;
 	}
 
+	if (matched_dstnet) {
+		lnet_net_unlock(cpt);
+		return 1;
+	}
+
 	rn_list = lnet_net2rnethash(dstnet);
 	list_for_each_entry(rnet, rn_list, lrn_list) {
 		if (rnet->lrn_net == dstnet) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
