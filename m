Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FDE0C433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:19 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id ED05C60230
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED05C60230
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CEF4532F766;
	Wed, 14 Apr 2021 21:03:07 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 436D732F3FA
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:48 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 5898A100F335;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4D22291891; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:01:57 -0400
Message-Id: <1618459361-17909-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/49] lnet: Prevent discovery on peer marked
 deletion
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

If a peer has been marked for deletion then we needn't perform any
other discovery operation on it. Integrate this peer state into the
top level of the discovery state machine so that it is checked before
any other state.

HPE-bug-id: LUS-9192
WC-bug-id: https://jira.whamcloud.com/browse/LU-13895
Lustre-commit: aa7de0af6969df77 ("LU-13895 lnet: Prevent discovery on peer marked deletion")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39604
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 109 ++++++++++++++++++++++++++++++---------------------
 1 file changed, 65 insertions(+), 44 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 8ee5ec3..48f78ef 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2934,6 +2934,68 @@ static bool lnet_is_nid_in_ping_info(lnet_nid_t nid,
 	return false;
 }
 
+/* Delete a peer that has been marked for deletion. NB: when this peer was added
+ * to the discovery queue a reference was taken that will prevent the peer from
+ * actually being freed by this function. After this function exits the
+ * discovery thread should call lnet_peer_discovery_complete() which will
+ * drop that reference as well as wake any waiters that may also be holding a
+ * ref on the peer
+ */
+static int lnet_peer_deletion(struct lnet_peer *lp)
+__must_hold(&lp->lp_lock)
+{
+	struct list_head rlist;
+	struct lnet_route *route, *tmp;
+	int sensitivity = lp->lp_health_sensitivity;
+
+	INIT_LIST_HEAD(&rlist);
+
+	lp->lp_state &= ~(LNET_PEER_DISCOVERING | LNET_PEER_FORCE_PING |
+			  LNET_PEER_FORCE_PUSH);
+	CDEBUG(D_NET, "peer %s(%p) state %#x\n",
+	       libcfs_nid2str(lp->lp_primary_nid), lp, lp->lp_state);
+
+	if (the_lnet.ln_dc_state != LNET_DC_STATE_RUNNING)
+		return -ESHUTDOWN;
+
+	spin_unlock(&lp->lp_lock);
+
+	mutex_lock(&the_lnet.ln_api_mutex);
+
+	lnet_net_lock(LNET_LOCK_EX);
+	/* remove the peer from the discovery work
+	 * queue if it's on there in preparation
+	 * of deleting it.
+	 */
+	if (!list_empty(&lp->lp_dc_list))
+		list_del(&lp->lp_dc_list);
+	list_for_each_entry_safe(route, tmp,
+				 &lp->lp_routes,
+				 lr_gwlist)
+		lnet_move_route(route, NULL, &rlist);
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	/* lnet_peer_del() deletes all the peer NIs owned by this peer */
+	lnet_peer_del(lp);
+
+	list_for_each_entry_safe(route, tmp,
+				 &rlist, lr_list) {
+		/* re-add these routes */
+		lnet_add_route(route->lr_net,
+			       route->lr_hops,
+			       route->lr_nid,
+			       route->lr_priority,
+			       sensitivity);
+		kfree(route);
+	}
+
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	spin_lock(&lp->lp_lock);
+
+	return 0;
+}
+
 /*
  * Update a peer using the data received.
  */
@@ -3504,7 +3566,9 @@ static int lnet_peer_discovery(void *arg)
 			CDEBUG(D_NET, "peer %s(%p) state %#x\n",
 			       libcfs_nid2str(lp->lp_primary_nid), lp,
 			       lp->lp_state);
-			if (lp->lp_state & LNET_PEER_DATA_PRESENT)
+			if (lp->lp_state & LNET_PEER_MARK_DELETION)
+				rc = lnet_peer_deletion(lp);
+			else if (lp->lp_state & LNET_PEER_DATA_PRESENT)
 				rc = lnet_peer_data_present(lp);
 			else if (lp->lp_state & LNET_PEER_PING_FAILED)
 				rc = lnet_peer_ping_failed(lp);
@@ -3536,49 +3600,6 @@ static int lnet_peer_discovery(void *arg)
 				lnet_peer_discovery_complete(lp);
 			if (the_lnet.ln_dc_state == LNET_DC_STATE_STOPPING)
 				break;
-
-			if (lp->lp_state & LNET_PEER_MARK_DELETION) {
-				struct list_head rlist;
-				struct lnet_route *route, *tmp;
-				int sensitivity = lp->lp_health_sensitivity;
-
-				INIT_LIST_HEAD(&rlist);
-
-				/* remove the peer from the discovery work
-				 * queue if it's on there in preparation
-				 * of deleting it.
-				 */
-				if (!list_empty(&lp->lp_dc_list))
-					list_del(&lp->lp_dc_list);
-
-				lnet_net_unlock(LNET_LOCK_EX);
-
-				mutex_lock(&the_lnet.ln_api_mutex);
-
-				lnet_net_lock(LNET_LOCK_EX);
-				list_for_each_entry_safe(route, tmp,
-							 &lp->lp_routes,
-							 lr_gwlist)
-					lnet_move_route(route, NULL, &rlist);
-				lnet_net_unlock(LNET_LOCK_EX);
-
-				/* delete the peer */
-				lnet_peer_del(lp);
-
-				list_for_each_entry_safe(route, tmp,
-							 &rlist, lr_list) {
-					/* re-add these routes */
-					lnet_add_route(route->lr_net,
-						       route->lr_hops,
-						       route->lr_nid,
-						       route->lr_priority,
-						       sensitivity);
-					kfree(route);
-				}
-				mutex_unlock(&the_lnet.ln_api_mutex);
-
-				lnet_net_lock(LNET_LOCK_EX);
-			}
 		}
 
 		lnet_net_unlock(LNET_LOCK_EX);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
