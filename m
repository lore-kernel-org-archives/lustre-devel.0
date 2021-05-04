Return-Path: <SRS0=WSMT=J7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EC25C433B4
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:46 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 51DC9611AD
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51DC9611AD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0128421F887;
	Mon,  3 May 2021 17:10:34 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2A01E21F3B4
 for <lustre-devel@lists.lustre.org>; Mon,  3 May 2021 17:10:23 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 286CBEDF;
 Mon,  3 May 2021 20:10:20 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 228D98AD46; Mon,  3 May 2021 20:10:20 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  3 May 2021 20:10:08 -0400
Message-Id: <1620087016-17857-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
References: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/14] lnet: Ensure proper peer, peer NI,
 peer net hierarchy
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

The MR design dictates that the peer nets and peer NIs are ordered
such that the peer net and peer NI for a peer's primary NID appears
first, followed by other peer NIs in the primary NID's peer net,
followed by other peer nets/NIs. This ordering is broken and it can
result in tripping an assertion if the primary NID of a peer is
deleted. Modify lnet_peer_attach_peer_ni() to check whether the
NI being attached is the peer's primary, and place it, and its
associated peer net, appropriately.

Modify lnet_peer_set_primary_nid() so that it updates the
lp_primary_nid before calling lnet_peer_add_nid() so that
lnet_peer_attach_peer_ni() can detect the situation where the
primary is changing and act appropriately.

Finally, modify lnet_peer_merge_data() to enforce the hierarchy
after it has finished merging the contents of the ping buffer. This
ensures we maintain the correct hierarchy in certain edge cases where
we've needed to reconcile two peers. e.g. if a peer adds a new
interface, the discovery push may arrive from that new interface
which will result in a second peer object being created which will
need to be reconciled with the original peer object.

HPE-bug-id: LUS-9630
WC-bug-id: https://jira.whamcloud.com/browse/LU-13806
Lustre-commit: 9eb9474c41c823c7 ("LU-13806 lnet: Ensure proper peer, peer NI, peer net hierarchy")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/40985
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 41 +++++++++++++++++++++++++++++++++++++----
 1 file changed, 37 insertions(+), 4 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 0ec1460..db00514 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1428,7 +1428,10 @@ struct lnet_peer_net *
 
 	/* Add peer_ni to peer_net */
 	lpni->lpni_peer_net = lpn;
-	list_add_tail(&lpni->lpni_peer_nis, &lpn->lpn_peer_nis);
+	if (lp->lp_primary_nid == lpni->lpni_nid)
+		list_add(&lpni->lpni_peer_nis, &lpn->lpn_peer_nis);
+	else
+		list_add_tail(&lpni->lpni_peer_nis, &lpn->lpn_peer_nis);
 	lnet_update_peer_net_healthv(lpni);
 	lnet_peer_net_addref_locked(lpn);
 
@@ -1436,7 +1439,10 @@ struct lnet_peer_net *
 	if (!lpn->lpn_peer) {
 		new_lpn = true;
 		lpn->lpn_peer = lp;
-		list_add_tail(&lpn->lpn_peer_nets, &lp->lp_peer_nets);
+		if (lp->lp_primary_nid == lpni->lpni_nid)
+			list_add(&lpn->lpn_peer_nets, &lp->lp_peer_nets);
+		else
+			list_add_tail(&lpn->lpn_peer_nets, &lp->lp_peer_nets);
 		lnet_peer_addref_locked(lp);
 	}
 
@@ -1678,10 +1684,14 @@ struct lnet_peer_net *
 
 	if (lp->lp_primary_nid == nid)
 		goto out;
+
+	lp->lp_primary_nid = nid;
+
 	rc = lnet_peer_add_nid(lp, nid, flags);
-	if (rc)
+	if (rc) {
+		lp->lp_primary_nid = old;
 		goto out;
-	lp->lp_primary_nid = nid;
+	}
 out:
 	CDEBUG(D_NET, "peer %s NID %s: %d\n",
 	       libcfs_nid2str(old), libcfs_nid2str(nid), rc);
@@ -2777,6 +2787,7 @@ static void lnet_discovery_event_handler(struct lnet_event *event)
 static int lnet_peer_merge_data(struct lnet_peer *lp,
 				struct lnet_ping_buffer *pbuf)
 {
+	struct lnet_peer_net *lpn;
 	struct lnet_peer_ni *lpni;
 	lnet_nid_t *curnis = NULL;
 	struct lnet_ni_status *addnis = NULL;
@@ -2902,6 +2913,28 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 				goto out;
 		}
 	}
+
+	/* The peer net for the primary NID should be the first entry in the
+	 * peer's lp_peer_nets list, and the peer NI for the primary NID should
+	 * be the first entry in its peer net's lpn_peer_nis list.
+	 */
+	lpni = lnet_find_peer_ni_locked(pbuf->pb_info.pi_ni[1].ns_nid);
+	if (!lpni) {
+		CERROR("Internal error: Failed to lookup peer NI for primary NID: %s\n",
+		       libcfs_nid2str(pbuf->pb_info.pi_ni[1].ns_nid));
+		goto out;
+	}
+
+	lnet_peer_ni_decref_locked(lpni);
+
+	lpn = lpni->lpni_peer_net;
+	if (lpn->lpn_peer_nets.prev != &lp->lp_peer_nets)
+		list_move(&lpn->lpn_peer_nets, &lp->lp_peer_nets);
+
+	if (lpni->lpni_peer_nis.prev != &lpni->lpni_peer_net->lpn_peer_nis)
+		list_move(&lpni->lpni_peer_nis,
+			  &lpni->lpni_peer_net->lpn_peer_nis);
+
 	/*
 	 * Errors other than -ENOMEM are due to peers having been
 	 * configured with DLC. Ignore these because DLC overrides
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
