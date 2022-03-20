Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6EEBBC433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:33:54 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BDBE021FD48;
	Sun, 20 Mar 2022 06:32:39 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1F3FC21CB5B
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:13 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 18DC9EE1;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 16EE8DD6ED; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:28 -0400
Message-Id: <1647783064-20688-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/50] lnet: o2iblnd: avoid static allocation
 for msg tx
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

tx msg handling simplification, just push
a lnet header message in same list as other.

Cray-bug-id: LUS-1796
WC-bug-id: https://jira.whamcloud.com/browse/LU-14008
Lustre-commit: 7d12b98d3f8294ca0 ("LU-14008 o2iblnd: avoid static allocation for msg tx")
Signed-off-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-on: https://review.whamcloud.com/40261
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c    |  5 +++--
 net/lnet/klnds/o2iblnd/o2iblnd.h    |  2 --
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 42 ++++++++++++++++++++++++-------------
 3 files changed, 30 insertions(+), 19 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 76f5e7f..9ce6082 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2010,8 +2010,9 @@ static int kiblnd_create_tx_pool(struct kib_poolset *ps, int size,
 		if (!tx->tx_wrq)
 			break;
 
-		tx->tx_sge = kzalloc_cpt((1 + IBLND_MAX_RDMA_FRAGS) *
-					 wrq_sge * sizeof(*tx->tx_sge),
+		/* +1 is for the lnet header/message itself */
+		tx->tx_sge = kzalloc_cpt((1 + IBLND_MAX_RDMA_FRAGS * wrq_sge) *
+					 sizeof(*tx->tx_sge),
 					 GFP_KERNEL, ps->ps_cpt);
 		if (!tx->tx_sge)
 			break;
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 4fb651e..5a4b4f8 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -408,8 +408,6 @@ struct kib_tx {					/* transmit message */
 	struct kib_msg	       *tx_msg;		/* message buffer (host vaddr) */
 	u64			tx_msgaddr;	/* message buffer (I/O addr) */
 	DEFINE_DMA_UNMAP_ADDR(tx_msgunmap);	/* for dma_unmap_single() */
-	/** sge for tx_msgaddr */
-	struct ib_sge		tx_msgsge;
 	int			tx_nwrq;	/* # send work items */
 	/* # used scatter/gather elements */
 	int			tx_nsge;
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 8168a26..d657366 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1002,32 +1002,44 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 }
 
 static void
+kiblnd_init_tx_sge(struct kib_tx *tx, u64 addr, unsigned int len)
+{
+	struct ib_sge *sge = &tx->tx_sge[tx->tx_nsge];
+	struct kib_hca_dev *hdev = tx->tx_pool->tpo_hdev;
+
+	*sge = (struct ib_sge) {
+		.lkey = hdev->ibh_pd->local_dma_lkey,
+		.addr = addr,
+		.length = len,
+	};
+
+	tx->tx_nsge++;
+}
+
+static void
 kiblnd_init_tx_msg(struct lnet_ni *ni, struct kib_tx *tx, int type,
 		   int body_nob)
 {
-	struct kib_hca_dev *hdev = tx->tx_pool->tpo_hdev;
-	struct ib_sge *sge = &tx->tx_msgsge;
 	struct ib_rdma_wr *wrq = &tx->tx_wrq[tx->tx_nwrq];
 	int nob = offsetof(struct kib_msg, ibm_u) + body_nob;
 
 	LASSERT(tx->tx_nwrq >= 0);
-	LASSERT(tx->tx_nwrq <= IBLND_MAX_RDMA_FRAGS);
+	LASSERT(tx->tx_nwrq < IBLND_MAX_RDMA_FRAGS + 1);
 	LASSERT(nob <= IBLND_MSG_SIZE);
 
 	kiblnd_init_msg(tx->tx_msg, type, body_nob);
 
-	sge->lkey = hdev->ibh_pd->local_dma_lkey;
-	sge->addr = tx->tx_msgaddr;
-	sge->length = nob;
-
-	memset(wrq, 0, sizeof(*wrq));
-
-	wrq->wr.next = NULL;
-	wrq->wr.wr_id = kiblnd_ptr2wreqid(tx, IBLND_WID_TX);
-	wrq->wr.sg_list = sge;
-	wrq->wr.num_sge = 1;
-	wrq->wr.opcode = IB_WR_SEND;
-	wrq->wr.send_flags = IB_SEND_SIGNALED;
+	*wrq = (struct ib_rdma_wr) {
+		.wr = {
+			.wr_id	= kiblnd_ptr2wreqid(tx, IBLND_WID_TX),
+			.num_sge = 1,
+			.sg_list = &tx->tx_sge[tx->tx_nsge],
+			.opcode = IB_WR_SEND,
+			.send_flags = IB_SEND_SIGNALED,
+		},
+	};
+
+	kiblnd_init_tx_sge(tx, tx->tx_msgaddr, nob);
 
 	tx->tx_nwrq++;
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
