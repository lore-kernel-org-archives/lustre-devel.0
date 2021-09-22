Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA30EC433F5
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:18 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 85EE860F4C
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 85EE860F4C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CF7D121CBCE;
	Tue, 21 Sep 2021 19:21:17 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1C4E321E0B4
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:08 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 14E1C358;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0C8C6FF4A3; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:44 -0400
Message-Id: <1632277201-6920-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/24] lnet: change lp_disc_*_nid to struct
 lnet_nid
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

Change lp_disc_src_nid and lp_disc_dst_nid in struct lnet_peer to
struct lnet_nid.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: f38529cd3a1722119 ("LU-10391 lnet: change lp_disc_*_nid to struct lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/44620
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  4 ++--
 net/lnet/lnet/peer.c           | 20 ++++++++++----------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index f980f2f..ba900e8 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -672,9 +672,9 @@ struct lnet_peer {
 	struct lnet_nid		lp_primary_nid;
 
 	/* source NID to use during discovery */
-	lnet_nid_t		lp_disc_src_nid;
+	struct lnet_nid		lp_disc_src_nid;
 	/* destination NID to use during discovery */
-	lnet_nid_t		lp_disc_dst_nid;
+	struct lnet_nid		lp_disc_dst_nid;
 
 	/* net to perform discovery on */
 	u32			lp_disc_net_id;
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 7f2c6f3..17f99ee 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -224,8 +224,8 @@
 	init_waitqueue_head(&lp->lp_dc_waitq);
 	spin_lock_init(&lp->lp_lock);
 	lp->lp_primary_nid = nid;
-	lp->lp_disc_src_nid = LNET_NID_ANY;
-	lp->lp_disc_dst_nid = LNET_NID_ANY;
+	lp->lp_disc_src_nid = LNET_ANY_NID;
+	lp->lp_disc_dst_nid = LNET_ANY_NID;
 	if (lnet_peers_start_down())
 		lp->lp_alive = false;
 	else
@@ -2635,8 +2635,8 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 
 	spin_lock(&lp->lp_lock);
 
-	lp->lp_disc_src_nid = ev->target.nid;
-	lp->lp_disc_dst_nid = ev->source.nid;
+	lnet_nid4_to_nid(ev->target.nid, &lp->lp_disc_src_nid);
+	lnet_nid4_to_nid(ev->source.nid, &lp->lp_disc_dst_nid);
 
 	/*
 	 * If some kind of error happened the contents of message
@@ -3367,7 +3367,7 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 			 * received by lp, we need to set the discovery source
 			 * NID for new_lp to the NID stored in lp.
 			 */
-			if (lp->lp_disc_src_nid != LNET_NID_ANY) {
+			if (!LNET_NID_IS_ANY(&lp->lp_disc_src_nid)) {
 				new_lp->lp_disc_src_nid = lp->lp_disc_src_nid;
 				new_lp->lp_disc_dst_nid = lp->lp_disc_dst_nid;
 			}
@@ -3567,13 +3567,13 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
 	/* Refcount for MD. */
 	lnet_peer_addref_locked(lp);
 	id.pid = LNET_PID_LUSTRE;
-	if (lp->lp_disc_dst_nid != LNET_NID_ANY)
-		id.nid = lp->lp_disc_dst_nid;
+	if (!LNET_NID_IS_ANY(&lp->lp_disc_dst_nid))
+		id.nid = lnet_nid_to_nid4(&lp->lp_disc_dst_nid);
 	else
 		id.nid = lnet_nid_to_nid4(&lp->lp_primary_nid);
 	lnet_net_unlock(cpt);
 
-	rc = LNetPut(lp->lp_disc_src_nid, lp->lp_push_mdh,
+	rc = LNetPut(lnet_nid_to_nid4(&lp->lp_disc_src_nid), lp->lp_push_mdh,
 		     LNET_ACK_REQ, id, LNET_RESERVED_PORTAL,
 		     LNET_PROTO_PING_MATCHBITS, 0, 0);
 	/* reset the discovery nid. There is no need to restrict sending
@@ -3581,8 +3581,8 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
 	 * get set to a specific NID, if we initiate discovery from the
 	 * scratch
 	 */
-	lp->lp_disc_src_nid = LNET_NID_ANY;
-	lp->lp_disc_dst_nid = LNET_NID_ANY;
+	lp->lp_disc_src_nid = LNET_ANY_NID;
+	lp->lp_disc_dst_nid = LNET_ANY_NID;
 	if (rc)
 		goto fail_unlink;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
