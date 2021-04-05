Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10234C43462
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:45 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BFD6D61396
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFD6D61396
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 24CC132895E;
	Mon,  5 Apr 2021 00:51:34 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BEB8321F73C
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:21 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B8EC56CF;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B54C390AA9; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:42 -0400
Message-Id: <1617583870-32029-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/41] lnet: Apply UDSP on local and remote
 NIs
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
Cc: Amir Shehata <ashehata@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Amir Shehata <ashehata@whamcloud.com>

When a peer net, peer ni, local net or local ni are created
apply the UDSPs in the system on these constructs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9121
Lustre-commit: a29151e30d8b89d ("LU-9121 lnet: Apply UDSP on local and remote NIs")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34355
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 26 +++++++++++++++++++++-----
 net/lnet/lnet/peer.c   | 16 ++++++++++++++++
 2 files changed, 37 insertions(+), 5 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 4809c76..9ff2776 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3164,12 +3164,13 @@ int lnet_get_ni_stats(struct lnet_ioctl_element_msg_stats *msg_stats)
 static int lnet_add_net_common(struct lnet_net *net,
 			       struct lnet_ioctl_config_lnd_tunables *tun)
 {
-	u32 net_id;
-	struct lnet_ping_buffer *pbuf;
 	struct lnet_handle_md ping_mdh;
-	int rc;
+	struct lnet_ping_buffer *pbuf;
 	struct lnet_remotenet *rnet;
+	struct lnet_ni *ni;
 	int net_ni_count;
+	u32 net_id;
+	int rc;
 
 	lnet_net_lock(LNET_LOCK_EX);
 	rnet = lnet_find_rnet_locked(net->net_id);
@@ -3219,10 +3220,25 @@ static int lnet_add_net_common(struct lnet_net *net,
 
 	lnet_net_lock(LNET_LOCK_EX);
 	net = lnet_get_net_locked(net_id);
-	lnet_net_unlock(LNET_LOCK_EX);
-
 	LASSERT(net);
 
+	/* apply the UDSPs */
+	rc = lnet_udsp_apply_policies_on_net(net);
+	if (rc)
+		CERROR("Failed to apply UDSPs on local net %s\n",
+		       libcfs_net2str(net->net_id));
+
+	/* At this point we lost track of which NI was just added, so we
+	 * just re-apply the policies on all of the NIs on this net
+	 */
+	list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
+		rc = lnet_udsp_apply_policies_on_ni(ni);
+		if (rc)
+			CERROR("Failed to apply UDSPs on ni %s\n",
+			       libcfs_nid2str(ni->ni_nid));
+	}
+	lnet_net_unlock(LNET_LOCK_EX);
+
 	/*
 	 * Start the acceptor thread if this is the first network
 	 * being added that requires the thread.
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index b4b8edd..8ee5ec3 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -35,6 +35,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
+#include <linux/lnet/udsp.h>
 #include <linux/lnet/lib-lnet.h>
 #include <uapi/linux/lnet/lnet-dlc.h>
 
@@ -1357,6 +1358,8 @@ struct lnet_peer_net *
 			 unsigned int flags)
 {
 	struct lnet_peer_table *ptable;
+	bool new_lpn = false;
+	int rc;
 
 	/* Install the new peer_ni */
 	lnet_net_lock(LNET_LOCK_EX);
@@ -1387,6 +1390,7 @@ struct lnet_peer_net *
 
 	/* Add peer_net to peer */
 	if (!lpn->lpn_peer) {
+		new_lpn = true;
 		lpn->lpn_peer = lp;
 		list_add_tail(&lpn->lpn_peer_nets, &lp->lp_peer_nets);
 		lnet_peer_addref_locked(lp);
@@ -1416,6 +1420,18 @@ struct lnet_peer_net *
 
 	lp->lp_nnis++;
 
+	/* apply UDSPs */
+	if (new_lpn) {
+		rc = lnet_udsp_apply_policies_on_lpn(lpn);
+		if (rc)
+			CERROR("Failed to apply UDSPs on lpn %s\n",
+			       libcfs_net2str(lpn->lpn_net_id));
+	}
+	rc = lnet_udsp_apply_policies_on_lpni(lpni);
+	if (rc)
+		CERROR("Failed to apply UDSPs on lpni %s\n",
+		       libcfs_nid2str(lpni->lpni_nid));
+
 	CDEBUG(D_NET, "peer %s NID %s flags %#x\n",
 	       libcfs_nid2str(lp->lp_primary_nid),
 	       libcfs_nid2str(lpni->lpni_nid), flags);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
