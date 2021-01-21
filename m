Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48BD2C433E0
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:19:01 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F324723A57
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:19:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F324723A57
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 497DE21FF9D;
	Thu, 21 Jan 2021 09:18:08 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DA56A21FB09
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:12 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 6ACC11008489;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 680DE1B49B; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:48 -0500
Message-Id: <1611249422-556-26-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 25/39] lnet: o2iblnd: retry qp creation with
 reduced queue depth
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

If negotiated number of frags * queue depth is too large for
successful qp creation, reduce the queue depth in a loop
until qp creation succeeds or the queue depth dips below 2.
Remember the reduced queue depth value to use for later
connections to the same peer.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12901
Lustre-commit: 8a3ef5713cc4ae ("LU-12901 o2iblnd: retry qp creation with reduced queue depth")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40748
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 33 ++++++++++++++++++++++++++-------
 net/lnet/klnds/o2iblnd/o2iblnd.h |  2 ++
 2 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 9c65524..fc515fc 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -336,6 +336,7 @@ int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer_ni **peerp,
 	peer_ni->ibp_last_alive = 0;
 	peer_ni->ibp_max_frags = IBLND_MAX_RDMA_FRAGS;
 	peer_ni->ibp_queue_depth = ni->ni_net->net_tunables.lct_peer_tx_credits;
+	peer_ni->ibp_queue_depth_mod = 0;	/* try to use the default */
 	atomic_set(&peer_ni->ibp_refcount, 1);  /* 1 ref for caller */
 
 	INIT_LIST_HEAD(&peer_ni->ibp_list);
@@ -795,13 +796,28 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 	init_qp_attr.qp_type = IB_QPT_RC;
 	init_qp_attr.send_cq = cq;
 	init_qp_attr.recv_cq = cq;
-	/* kiblnd_send_wrs() can change the connection's queue depth if
-	 * the maximum work requests for the device is maxed out
-	 */
-	init_qp_attr.cap.max_send_wr = kiblnd_send_wrs(conn);
-	init_qp_attr.cap.max_recv_wr = IBLND_RECV_WRS(conn);
 
-	rc = rdma_create_qp(cmid, conn->ibc_hdev->ibh_pd, &init_qp_attr);
+	if (peer_ni->ibp_queue_depth_mod &&
+	    peer_ni->ibp_queue_depth_mod < peer_ni->ibp_queue_depth) {
+		conn->ibc_queue_depth = peer_ni->ibp_queue_depth_mod;
+		CDEBUG(D_NET, "Use reduced queue depth %u (from %u)\n",
+		       peer_ni->ibp_queue_depth_mod,
+		       peer_ni->ibp_queue_depth);
+	}
+
+	do {
+		/* kiblnd_send_wrs() can change the connection's queue depth if
+		 * the maximum work requests for the device is maxed out
+		 */
+		init_qp_attr.cap.max_send_wr = kiblnd_send_wrs(conn);
+		init_qp_attr.cap.max_recv_wr = IBLND_RECV_WRS(conn);
+		rc = rdma_create_qp(cmid, conn->ibc_hdev->ibh_pd,
+				    &init_qp_attr);
+		if (rc != -ENOMEM || conn->ibc_queue_depth < 2)
+			break;
+		conn->ibc_queue_depth--;
+	} while (rc);
+
 	if (rc) {
 		CERROR("Can't create QP: %d, send_wr: %d, recv_wr: %d, send_sge: %d, recv_sge: %d\n",
 		       rc, init_qp_attr.cap.max_send_wr,
@@ -813,11 +829,14 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 
 	conn->ibc_sched = sched;
 
-	if (conn->ibc_queue_depth != peer_ni->ibp_queue_depth)
+	if (!peer_ni->ibp_queue_depth_mod &&
+	    conn->ibc_queue_depth != peer_ni->ibp_queue_depth) {
 		CWARN("peer %s - queue depth reduced from %u to %u  to allow for qp creation\n",
 		      libcfs_nid2str(peer_ni->ibp_nid),
 		      peer_ni->ibp_queue_depth,
 		      conn->ibc_queue_depth);
+		peer_ni->ibp_queue_depth_mod = conn->ibc_queue_depth;
+	}
 
 	conn->ibc_rxs = kzalloc_cpt(IBLND_RX_MSGS(conn) *
 				    sizeof(*conn->ibc_rxs),
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 1fc68e1..424ca07 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -638,6 +638,8 @@ struct kib_peer_ni {
 	u16			ibp_max_frags;
 	/* max_peer_credits */
 	u16			ibp_queue_depth;
+	/* reduced value which allows conn to be created if max fails */
+	u16			ibp_queue_depth_mod;
 };
 
 extern struct kib_data kiblnd_data;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
