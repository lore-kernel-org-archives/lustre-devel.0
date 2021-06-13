Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0425C48BE8
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:13:10 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 886B561363
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:13:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 886B561363
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1123D21F64E;
	Sun, 13 Jun 2021 16:12:35 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6936021E04C
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:47 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id EC312100BAE2;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EB2179C304; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:35 -0400
Message-Id: <1623625897-17706-26-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 25/27] lnet: Fix destination NID for
 discovery PUSH
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

If we're sending a discovery PUSH after receiving a discovery
REPLY then we want to send via the same NID that the reply was
sent to. This introduces a challenge in selecting an appropriate
destination NID for the PUSH because lnet_select_pathway() will not
run the MR selection algorithm for choosing a peer NI if the source
NI has been specified.

It is reasonable to assume that the NID used by the message
originator in sending the REPLY is a suitable destination for the
discovery PUSH. Thus, we record this NID in the same location we
currently record the lp_disc_src_nid, and use it when sending the
PUSH. With this change, the only other user of lnet_peer_select_nid()
is lnet_peer_send_ping(). In the ping case we do not set a source NID,
so lnet_select_pathway() is free to choose any peer NI. So this change
allows us to get rid of lnet_peer_select_nid() altogether.

Alternatively, we would need to reproduce a lot of the path selection
algorithm inside lnet_peer_select_nid() in order to avoid sending to
unhealthy NIDs. It seems undesirable and unnecessary to duplicate that
logic.

HPE-bug-id: LUS-9333
WC-bug-id: https://jira.whamcloud.com/browse/LU-14660
Lustre-commit: dce2f7d1987711dfd ("LU-14660 lnet: Fix destination NID for discovery PUSH")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/43507
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  2 ++
 net/lnet/lnet/peer.c           | 52 ++++++++++--------------------------------
 2 files changed, 14 insertions(+), 40 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index d898066..cb0a950 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -640,6 +640,8 @@ struct lnet_peer {
 
 	/* source NID to use during discovery */
 	lnet_nid_t		lp_disc_src_nid;
+	/* destination NID to use during discovery */
+	lnet_nid_t		lp_disc_dst_nid;
 
 	/* net to perform discovery on */
 	u32			lp_disc_net_id;
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index d66a302..7630aff 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -221,6 +221,7 @@
 	spin_lock_init(&lp->lp_lock);
 	lp->lp_primary_nid = nid;
 	lp->lp_disc_src_nid = LNET_NID_ANY;
+	lp->lp_disc_dst_nid = LNET_NID_ANY;
 	if (lnet_peers_start_down())
 		lp->lp_alive = false;
 	else
@@ -2515,6 +2516,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	spin_lock(&lp->lp_lock);
 
 	lp->lp_disc_src_nid = ev->target.nid;
+	lp->lp_disc_dst_nid = ev->source.nid;
 
 	/*
 	 * If some kind of error happened the contents of message
@@ -3221,8 +3223,10 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 			 * received by lp, we need to set the discovery source
 			 * NID for new_lp to the NID stored in lp.
 			 */
-			if (lp->lp_disc_src_nid != LNET_NID_ANY)
+			if (lp->lp_disc_src_nid != LNET_NID_ANY) {
 				new_lp->lp_disc_src_nid = lp->lp_disc_src_nid;
+				new_lp->lp_disc_dst_nid = lp->lp_disc_dst_nid;
+			}
 			spin_unlock(&new_lp->lp_lock);
 			spin_unlock(&lp->lp_lock);
 
@@ -3273,41 +3277,10 @@ static int lnet_peer_ping_failed(struct lnet_peer *lp)
 	return rc ? rc : LNET_REDISCOVER_PEER;
 }
 
-/*
- * Select NID to send a Ping or Push to.
- */
-static lnet_nid_t lnet_peer_select_nid(struct lnet_peer *lp)
-{
-	struct lnet_peer_ni *lpni;
-
-	/* Look for a direct-connected NID for this peer. */
-	lpni = NULL;
-	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL) {
-		if (!lnet_get_net_locked(lpni->lpni_peer_net->lpn_net_id))
-			continue;
-		break;
-	}
-	if (lpni)
-		return lpni->lpni_nid;
-
-	/* Look for a routed-connected NID for this peer. */
-	lpni = NULL;
-	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL) {
-		if (!lnet_find_rnet_locked(lpni->lpni_peer_net->lpn_net_id))
-			continue;
-		break;
-	}
-	if (lpni)
-		return lpni->lpni_nid;
-
-	return LNET_NID_ANY;
-}
-
 /* Active side of ping. */
 static int lnet_peer_send_ping(struct lnet_peer *lp)
 __must_hold(&lp->lp_lock)
 {
-	lnet_nid_t pnid;
 	int nnis;
 	int rc;
 	int cpt;
@@ -3319,12 +3292,11 @@ static int lnet_peer_send_ping(struct lnet_peer *lp)
 	cpt = lnet_net_lock_current();
 	/* Refcount for MD. */
 	lnet_peer_addref_locked(lp);
-	pnid = lnet_peer_select_nid(lp);
 	lnet_net_unlock(cpt);
 
 	nnis = max_t(int, lp->lp_data_nnis, LNET_INTERFACES_MIN);
 
-	rc = lnet_send_ping(pnid, &lp->lp_ping_mdh, nnis, lp,
+	rc = lnet_send_ping(lp->lp_primary_nid, &lp->lp_ping_mdh, nnis, lp,
 			    the_lnet.ln_dc_handler, false);
 	/* if LNetMDBind in lnet_send_ping fails we need to decrement the
 	 * refcount on the peer, otherwise LNetMDUnlink will be called
@@ -3445,18 +3417,17 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
 		CERROR("Can't bind push source MD: %d\n", rc);
 		goto fail_error;
 	}
+
 	cpt = lnet_net_lock_current();
 	/* Refcount for MD. */
 	lnet_peer_addref_locked(lp);
 	id.pid = LNET_PID_LUSTRE;
-	id.nid = lnet_peer_select_nid(lp);
+	if (lp->lp_disc_dst_nid != LNET_NID_ANY)
+		id.nid = lp->lp_disc_dst_nid;
+	else
+		id.nid = lp->lp_primary_nid;
 	lnet_net_unlock(cpt);
 
-	if (id.nid == LNET_NID_ANY) {
-		rc = -EHOSTUNREACH;
-		goto fail_unlink;
-	}
-
 	rc = LNetPut(lp->lp_disc_src_nid, lp->lp_push_mdh,
 		     LNET_ACK_REQ, id, LNET_RESERVED_PORTAL,
 		     LNET_PROTO_PING_MATCHBITS, 0, 0);
@@ -3466,6 +3437,7 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
 	 * scratch
 	 */
 	lp->lp_disc_src_nid = LNET_NID_ANY;
+	lp->lp_disc_dst_nid = LNET_NID_ANY;
 	if (rc)
 		goto fail_unlink;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
