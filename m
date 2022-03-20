Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 50F95C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:33:58 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 92D3721FD55;
	Sun, 20 Mar 2022 06:32:42 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D4F8D21CABE
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:21 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 95340102D;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 92A61D87DE; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:31:00 -0400
Message-Id: <1647783064-20688-47-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 46/50] lnet: o2iblnd: avoid memory copy for
 short msg
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
Cc: Alexey Lyashkov <alexey.lyashkov@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexey Lyashkov <alexey.lyashkov@hpe.com>

Modern cards allow to send a kernel memory data without mapping
or copy to the preallocated buffer.
It reduce a lnet selftest cpu consumption by 3% for messages
less than 4k size.

HPE-bug-id: LUS-1796
WC-bug-id: https://jira.whamcloud.com/browse/LU-14008
Lustre-commit: bebd87cc6c9acc577 ("LU-14008 o2iblnd: avoid memory copy for short msg")
Signed-off-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-on: https://review.whamcloud.com/40262
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c    |  3 +-
 net/lnet/klnds/o2iblnd/o2iblnd.h    |  3 ++
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 63 ++++++++++++++++++++++++++++---------
 3 files changed, 52 insertions(+), 17 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 9ce6082..8dce4179 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -628,10 +628,9 @@ static unsigned int kiblnd_send_wrs(struct kib_conn *conn)
 	 */
 	int ret;
 	int multiplier = 1 + conn->ibc_max_frags;
-	enum kib_dev_caps dev_caps = conn->ibc_hdev->ibh_dev->ibd_dev_caps;
 
 	/* FastReg needs two extra WRs for map and invalidate */
-	if (dev_caps & IBLND_DEV_CAPS_FASTREG_ENABLED)
+	if (IS_FAST_REG_DEV(conn->ibc_hdev->ibh_dev))
 		multiplier += 2;
 
 	/* account for a maximum of ibc_queue_depth in-flight transfers */
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 5a4b4f8..e798695 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -149,6 +149,9 @@ enum kib_dev_caps {
 	IBLND_DEV_CAPS_FASTREG_GAPS_SUPPORT	= BIT(1),
 };
 
+#define IS_FAST_REG_DEV(dev) \
+	((dev)->ibd_dev_caps & IBLND_DEV_CAPS_FASTREG_ENABLED)
+
 struct kib_dev {
 	struct list_head	ibd_list;	/* chain on kib_devs */
 	struct list_head	ibd_fail_list;	/* chain on kib_failed_devs */
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 983599f..a88939e7 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -42,8 +42,11 @@
 static void kiblnd_peer_alive(struct kib_peer_ni *peer_ni);
 static void kiblnd_peer_connect_failed(struct kib_peer_ni *peer_ni, int active,
 				       int error);
-static void kiblnd_init_tx_msg(struct lnet_ni *ni, struct kib_tx *tx,
-			       int type, int body_nob);
+static struct ib_rdma_wr *
+kiblnd_init_tx_msg_payload(struct lnet_ni *ni, struct kib_tx *tx,
+			   int type, int body_nob, int payload_nob);
+#define kiblnd_init_tx_msg(ni, tx, type, body) \
+	kiblnd_init_tx_msg_payload(ni, tx, type, body, 0)
 static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 			    int resid, struct kib_rdma_desc *dstrd,
 			    u64 dstcookie);
@@ -572,7 +575,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	 * in trying to map the memory, because it'll just fail. So
 	 * preemptively fail with an appropriate message
 	 */
-	if ((dev->ibd_dev_caps & IBLND_DEV_CAPS_FASTREG_ENABLED) &&
+	if (IS_FAST_REG_DEV(dev) &&
 	    !(dev->ibd_dev_caps & IBLND_DEV_CAPS_FASTREG_GAPS_SUPPORT) &&
 	    tx->tx_gaps) {
 		CERROR("Using FastReg with no GAPS support, but tx has gaps\n");
@@ -1021,9 +1024,9 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	tx->tx_nsge++;
 }
 
-static void
-kiblnd_init_tx_msg(struct lnet_ni *ni, struct kib_tx *tx, int type,
-		   int body_nob)
+static struct ib_rdma_wr *
+kiblnd_init_tx_msg_payload(struct lnet_ni *ni, struct kib_tx *tx, int type,
+			   int body_nob, int payload)
 {
 	struct ib_rdma_wr *wrq = &tx->tx_wrq[tx->tx_nwrq];
 	int nob = offsetof(struct kib_msg, ibm_u) + body_nob;
@@ -1032,7 +1035,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	LASSERT(tx->tx_nwrq < IBLND_MAX_RDMA_FRAGS + 1);
 	LASSERT(nob <= IBLND_MSG_SIZE);
 
-	kiblnd_init_msg(tx->tx_msg, type, body_nob);
+	kiblnd_init_msg(tx->tx_msg, type, body_nob + payload);
 
 	*wrq = (struct ib_rdma_wr) {
 		.wr = {
@@ -1047,6 +1050,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	kiblnd_init_tx_sge(tx, tx->tx_msgaddr, nob);
 
 	tx->tx_nwrq++;
+	return wrq;
 }
 
 static int
@@ -1654,15 +1658,44 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	ibmsg = tx->tx_msg;
 	lnet_hdr_to_nid4(hdr, &ibmsg->ibm_u.immediate.ibim_hdr);
 
-	rc = copy_from_iter(&ibmsg->ibm_u.immediate.ibim_payload, payload_nob,
-			    &from);
-	if (rc != payload_nob) {
-		kiblnd_pool_free_node(&tx->tx_pool->tpo_pool, &tx->tx_list);
-		return -EFAULT;
-	}
+	if (payload_nob) {
+		struct ib_rdma_wr *wrq;
+		int i;
+
+		nob = offsetof(struct kib_immediate_msg, ibim_payload[0]);
+		wrq = kiblnd_init_tx_msg_payload(ni, tx, IBLND_MSG_IMMEDIATE,
+						 nob, payload_nob);
+
+		rd = tx->tx_rd;
+		rc = kiblnd_setup_rd_kiov(ni, tx, rd,
+					  payload_niov, payload_kiov,
+					  payload_offset, payload_nob);
+		if (rc != 0) {
+			CERROR("Can't setup IMMEDIATE src for %s: %d\n",
+			       libcfs_nidstr(&target->nid), rc);
+			kiblnd_tx_done(tx);
+			return -EIO;
+		}
 
-	nob = offsetof(struct kib_immediate_msg, ibim_payload[payload_nob]);
-	kiblnd_init_tx_msg(ni, tx, IBLND_MSG_IMMEDIATE, nob);
+		/* lets generate a SGE chain */
+		for (i = 0; i < rd->rd_nfrags; i++) {
+			kiblnd_init_tx_sge(tx, rd->rd_frags[i].rf_addr,
+					   rd->rd_frags[i].rf_nob);
+			wrq->wr.num_sge++;
+		}
+	} else {
+		rc = copy_from_iter(&ibmsg->ibm_u.immediate.ibim_payload,
+				    payload_nob, &from);
+		if (rc != payload_nob) {
+			kiblnd_pool_free_node(&tx->tx_pool->tpo_pool,
+					      &tx->tx_list);
+			return -EFAULT;
+		}
+
+		nob = offsetof(struct kib_immediate_msg,
+			       ibim_payload[payload_nob]);
+		kiblnd_init_tx_msg(ni, tx, IBLND_MSG_IMMEDIATE, nob);
+	}
 
 	/* finalise lntmsg on completion */
 	tx->tx_lntmsg[0] = lntmsg;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
