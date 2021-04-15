Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47E64C433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:00 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E57B1610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:02:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E57B1610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6D75B32F64F;
	Wed, 14 Apr 2021 21:02:56 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 903E532F3FA
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:48 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 5A5CF100F338;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4FE5691893; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:01:58 -0400
Message-Id: <1618459361-17909-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/49] lnet: Prevent discovery on deleted peer
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

We needn't perform any discovery activities on a peer that has had
lnet_peer_del() called on it.

HPE-bug-id: LUS-9192
WC-bug-id: https://jira.whamcloud.com/browse/LU-13895
Lustre-commit: fd32cd817cba336c ("LU-13895 lnet: Prevent discovery on deleted peer"):1
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39605
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |  2 ++
 include/linux/lnet/lib-types.h |  4 ++-
 net/lnet/lnet/peer.c           | 73 ++++++++++++++++++++++++------------------
 3 files changed, 46 insertions(+), 33 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 1efac9b..2741c6f 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -893,6 +893,8 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 {
 	if (!(lp->lp_state & LNET_PEER_MULTI_RAIL))
 		return false;
+	if (lp->lp_state & LNET_PEER_MARK_DELETED)
+		return false;
 	if (lp->lp_state & LNET_PEER_FORCE_PUSH)
 		return true;
 	if (lp->lp_state & LNET_PEER_NO_DISCOVERY)
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index f1f4eac5..2424993 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -750,7 +750,9 @@ struct lnet_peer {
 #define LNET_PEER_RTR_DISCOVERED BIT(17)
 
 /* peer is marked for deletion */
-#define LNET_PEER_MARK_DELETION BIT(18)
+#define LNET_PEER_MARK_DELETION		BIT(18)
+/* lnet_peer_del()/lnet_peer_del_locked() has been called on the peer */
+#define LNET_PEER_MARK_DELETED		BIT(19)
 
 struct lnet_peer_net {
 	/* chain on lp_peer_nets */
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 48f78ef..34153a8 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -450,6 +450,10 @@ void lnet_peer_uninit(void)
 
 	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(peer->lp_primary_nid));
 
+	spin_lock(&peer->lp_lock);
+	peer->lp_state |= LNET_PEER_MARK_DELETED;
+	spin_unlock(&peer->lp_lock);
+
 	lpni = lnet_get_next_peer_ni_locked(peer, NULL, lpni);
 	while (lpni) {
 		lpni2 = lnet_get_next_peer_ni_locked(peer, NULL, lpni);
@@ -462,9 +466,40 @@ void lnet_peer_uninit(void)
 	return rc2;
 }
 
+/* Discovering this peer is taking too long. Cancel any Ping or Push
+ * that discovery is waiting on by unlinking the relevant MDs. The
+ * lnet_discovery_event_handler() will proceed from here and complete
+ * the cleanup.
+ */
+static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
+{
+	struct lnet_handle_md ping_mdh;
+	struct lnet_handle_md push_mdh;
+
+	LNetInvalidateMDHandle(&ping_mdh);
+	LNetInvalidateMDHandle(&push_mdh);
+
+	spin_lock(&lp->lp_lock);
+	if (lp->lp_state & LNET_PEER_PING_SENT) {
+		ping_mdh = lp->lp_ping_mdh;
+		LNetInvalidateMDHandle(&lp->lp_ping_mdh);
+	}
+	if (lp->lp_state & LNET_PEER_PUSH_SENT) {
+		push_mdh = lp->lp_push_mdh;
+		LNetInvalidateMDHandle(&lp->lp_push_mdh);
+	}
+	spin_unlock(&lp->lp_lock);
+
+	if (!LNetMDHandleIsInvalid(ping_mdh))
+		LNetMDUnlink(ping_mdh);
+	if (!LNetMDHandleIsInvalid(push_mdh))
+		LNetMDUnlink(push_mdh);
+}
+
 static int
 lnet_peer_del(struct lnet_peer *peer)
 {
+	lnet_peer_cancel_discovery(peer);
 	lnet_net_lock(LNET_LOCK_EX);
 	lnet_peer_del_locked(peer);
 	lnet_net_unlock(LNET_LOCK_EX);
@@ -2955,6 +2990,10 @@ static int lnet_peer_deletion(struct lnet_peer *lp)
 	CDEBUG(D_NET, "peer %s(%p) state %#x\n",
 	       libcfs_nid2str(lp->lp_primary_nid), lp, lp->lp_state);
 
+	/* no-op if lnet_peer_del() has already been called on this peer */
+	if (lp->lp_state & LNET_PEER_MARK_DELETED)
+		return 0;
+
 	if (the_lnet.ln_dc_state != LNET_DC_STATE_RUNNING)
 		return -ESHUTDOWN;
 
@@ -3382,37 +3421,6 @@ static void lnet_peer_discovery_error(struct lnet_peer *lp, int error)
 }
 
 /*
- * Discovering this peer is taking too long. Cancel any Ping or Push
- * that discovery is waiting on by unlinking the relevant MDs. The
- * lnet_discovery_event_handler() will proceed from here and complete
- * the cleanup.
- */
-static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
-{
-	struct lnet_handle_md ping_mdh;
-	struct lnet_handle_md push_mdh;
-
-	LNetInvalidateMDHandle(&ping_mdh);
-	LNetInvalidateMDHandle(&push_mdh);
-
-	spin_lock(&lp->lp_lock);
-	if (lp->lp_state & LNET_PEER_PING_SENT) {
-		ping_mdh = lp->lp_ping_mdh;
-		LNetInvalidateMDHandle(&lp->lp_ping_mdh);
-	}
-	if (lp->lp_state & LNET_PEER_PUSH_SENT) {
-		push_mdh = lp->lp_push_mdh;
-		LNetInvalidateMDHandle(&lp->lp_push_mdh);
-	}
-	spin_unlock(&lp->lp_lock);
-
-	if (!LNetMDHandleIsInvalid(ping_mdh))
-		LNetMDUnlink(ping_mdh);
-	if (!LNetMDHandleIsInvalid(push_mdh))
-		LNetMDUnlink(push_mdh);
-}
-
-/*
  * Wait for work to be queued or some other change that must be
  * attended to. Returns non-zero if the discovery thread should shut
  * down.
@@ -3566,7 +3574,8 @@ static int lnet_peer_discovery(void *arg)
 			CDEBUG(D_NET, "peer %s(%p) state %#x\n",
 			       libcfs_nid2str(lp->lp_primary_nid), lp,
 			       lp->lp_state);
-			if (lp->lp_state & LNET_PEER_MARK_DELETION)
+			if (lp->lp_state & (LNET_PEER_MARK_DELETION |
+					    LNET_PEER_MARK_DELETED))
 				rc = lnet_peer_deletion(lp);
 			else if (lp->lp_state & LNET_PEER_DATA_PRESENT)
 				rc = lnet_peer_data_present(lp);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
