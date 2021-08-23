Return-Path: <SRS0=6+cL=NO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5489FC432BE
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:00 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0546B61360
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:27:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 0546B61360
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A3A4F21CAB4;
	Sun, 22 Aug 2021 19:27:56 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B35DE21CAB1
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 19:27:51 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 29787100BAF9;
 Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1C4CEB6C93; Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 22 Aug 2021 22:27:37 -0400
Message-Id: <1629685666-4533-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
References: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/15] lnet: keep in insync to change due to
 GPU Direct Support
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

Since in the HPC community most people run 10+ year old kernels
Nvidia created their own version of PCI peer2peer which sites
want to use. The OpenSFS supports this special one off out of
tree driver which impacts the LNet code. To keep in sync we
port to the Linux proper tree these changes. This also allows
the potential to support the support PCI peer2peer in the
future. This initial abstract was poorly done so it will have
to be revisted.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14798
Lustre-commit: a7a889f77cec3ad44 ("LU-14798 lnet: add LNet GPU Direct Support")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
lustre-change: https://review.whamcloud.com/37368
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Whamcloud-bug-id: EX-773
Reviewed-on: https://review.whamcloud.com/44110
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h      | 25 +++++++++++++++
 net/lnet/klnds/o2iblnd/o2iblnd.c    |  1 +
 net/lnet/klnds/o2iblnd/o2iblnd.h    |  9 +++---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 16 ++++++++--
 net/lnet/lnet/lib-move.c            | 62 ++++++++++++++++++++++++++++++-------
 5 files changed, 95 insertions(+), 18 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index e951e02..6b97ab9 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -312,8 +312,33 @@ struct lnet_lnd {
 
 	/* accept a new connection */
 	int (*lnd_accept)(struct lnet_ni *ni, struct socket *sock);
+
+	/* get dma_dev priority */
+	unsigned int (*lnd_get_dev_prio)(struct lnet_ni *ni,
+					 unsigned int dev_idx);
 };
 
+/* FIXME !!!!! The abstract for GPU page support (PCI peer2peer)
+ * was done for only the external NVIDIA driver and done very
+ * poorly. Once DRI / TTM supports peer2peer we can redo this
+ * right.
+ */
+static inline unsigned int lnet_get_dev_prio(struct device *dev,
+					     unsigned int dev_idx)
+{
+	return UINT_MAX;
+}
+
+static inline bool lnet_is_rdma_only_page(struct page *page)
+{
+	return false;
+}
+
+static inline unsigned int lnet_get_dev_idx(struct page *page)
+{
+	return false;
+}
+
 struct lnet_tx_queue {
 	int			tq_credits;	/* # tx credits free */
 	int			tq_credits_min;	/* lowest it's been */
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 686581a..a4949d8 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2953,6 +2953,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	.lnd_ctl	= kiblnd_ctl,
 	.lnd_send	= kiblnd_send,
 	.lnd_recv	= kiblnd_recv,
+	.lnd_get_dev_prio = kiblnd_get_dev_prio,
 };
 
 static void ko2inlnd_assert_wire_constants(void)
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 3691bfe..5066f7b 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -858,18 +858,18 @@ static inline void kiblnd_dma_unmap_single(struct ib_device *dev,
 #define KIBLND_UNMAP_ADDR_SET(p, m, a)	do {} while (0)
 #define KIBLND_UNMAP_ADDR(p, m, a)	(a)
 
-static inline int kiblnd_dma_map_sg(struct ib_device *dev,
+static inline int kiblnd_dma_map_sg(struct kib_hca_dev *hdev,
 				    struct scatterlist *sg, int nents,
 				    enum dma_data_direction direction)
 {
-	return ib_dma_map_sg(dev, sg, nents, direction);
+	return ib_dma_map_sg(hdev->ibh_ibdev, sg, nents, direction);
 }
 
-static inline void kiblnd_dma_unmap_sg(struct ib_device *dev,
+static inline void kiblnd_dma_unmap_sg(struct kib_hca_dev *hdev,
 				       struct scatterlist *sg, int nents,
 				       enum dma_data_direction direction)
 {
-	ib_dma_unmap_sg(dev, sg, nents, direction);
+	ib_dma_unmap_sg(hdev->ibh_ibdev, sg, nents, direction);
 }
 
 static inline u64 kiblnd_sg_dma_address(struct ib_device *dev,
@@ -959,3 +959,4 @@ void kiblnd_pack_msg(struct lnet_ni *ni, struct kib_msg *msg, int version,
 int kiblnd_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg);
 int kiblnd_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
 		int delayed, struct iov_iter *to, unsigned int rlen);
+unsigned int kiblnd_get_dev_prio(struct lnet_ni *ni, unsigned int dev_idx);
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 193e75b..8ccd2ab 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -615,7 +615,7 @@ static void kiblnd_unmap_tx(struct kib_tx *tx)
 		kiblnd_fmr_pool_unmap(&tx->tx_fmr, tx->tx_status);
 
 	if (tx->tx_nfrags) {
-		kiblnd_dma_unmap_sg(tx->tx_pool->tpo_hdev->ibh_ibdev,
+		kiblnd_dma_unmap_sg(tx->tx_pool->tpo_hdev,
 				    tx->tx_frags, tx->tx_nfrags, tx->tx_dmadir);
 		tx->tx_nfrags = 0;
 	}
@@ -636,7 +636,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	tx->tx_dmadir = (rd != tx->tx_rd) ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
 	tx->tx_nfrags = nfrags;
 
-	rd->rd_nfrags = kiblnd_dma_map_sg(hdev->ibh_ibdev, tx->tx_frags,
+	rd->rd_nfrags = kiblnd_dma_map_sg(hdev, tx->tx_frags,
 					  tx->tx_nfrags, tx->tx_dmadir);
 
 	for (i = 0, nob = 0; i < rd->rd_nfrags; i++) {
@@ -1721,6 +1721,18 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	lnet_finalize(lntmsg, -EIO);
 }
 
+unsigned int
+kiblnd_get_dev_prio(struct lnet_ni *ni, unsigned int dev_idx)
+{
+	struct kib_net *net = ni->ni_data;
+	struct device *dev = NULL;
+
+	if (net)
+		dev = net->ibn_dev->ibd_hdev->ibh_ibdev->dma_device;
+
+	return lnet_get_dev_prio(dev, dev_idx);
+}
+
 int
 kiblnd_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
 	    int delayed, struct iov_iter *to, unsigned int rlen)
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 33d7e78..035bda3 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1420,16 +1420,38 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	return best_route;
 }
 
+static inline unsigned int
+lnet_dev_prio_of_md(struct lnet_ni *ni, unsigned int dev_idx)
+{
+	if (dev_idx == UINT_MAX)
+		return UINT_MAX;
+
+	if (!ni || !ni->ni_net || !ni->ni_net->net_lnd ||
+	    !ni->ni_net->net_lnd->lnd_get_dev_prio)
+		return UINT_MAX;
+
+	return ni->ni_net->net_lnd->lnd_get_dev_prio(ni, dev_idx);
+}
+
 static struct lnet_ni *
 lnet_get_best_ni(struct lnet_net *local_net, struct lnet_ni *best_ni,
 		 struct lnet_peer *peer, struct lnet_peer_net *peer_net,
-		 int md_cpt)
+		 struct lnet_msg *msg, int md_cpt)
 {
-	struct lnet_ni *ni = NULL;
+	struct lnet_libmd *md = msg->msg_md;
+	unsigned int offset = msg->msg_offset;
 	unsigned int shortest_distance;
+	struct lnet_ni *ni = NULL;
 	int best_credits;
 	int best_healthv;
 	u32 best_sel_prio;
+	unsigned int best_dev_prio;
+	unsigned int dev_idx = UINT_MAX;
+	struct page *page = lnet_get_first_page(md, offset);
+
+	msg->msg_rdma_force = lnet_is_rdma_only_page(page);
+	if (msg->msg_rdma_force)
+		dev_idx = lnet_get_dev_idx(page);
 
 	/* If there is no peer_ni that we can send to on this network,
 	 * then there is no point in looking for a new best_ni here.
@@ -1440,9 +1462,11 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	if (!best_ni) {
 		best_sel_prio = LNET_MAX_SELECTION_PRIORITY;
 		shortest_distance = UINT_MAX;
+		best_dev_prio = UINT_MAX;
 		best_credits = INT_MIN;
 		best_healthv = 0;
 	} else {
+		best_dev_prio = lnet_dev_prio_of_md(best_ni, dev_idx);
 		shortest_distance = cfs_cpt_distance(lnet_cpt_table(), md_cpt,
 						     best_ni->ni_dev_cpt);
 		best_credits = atomic_read(&best_ni->ni_tx_credits);
@@ -1456,6 +1480,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		int ni_healthv;
 		int ni_fatal;
 		u32 ni_sel_prio;
+		unsigned int ni_dev_prio;
 
 		ni_credits = atomic_read(&ni->ni_tx_credits);
 		ni_healthv = atomic_read(&ni->ni_healthv);
@@ -1471,6 +1496,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 					    md_cpt,
 					    ni->ni_dev_cpt);
 
+		ni_dev_prio = lnet_dev_prio_of_md(ni, dev_idx);
+
 		/*
 		 * All distances smaller than the NUMA range
 		 * are treated equally.
@@ -1478,22 +1505,21 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		if (distance < lnet_numa_range)
 			distance = lnet_numa_range;
 
-		/*
-		 * Select on health, shorter distance, available
-		 * credits, then round-robin.
+		/* * Select on health, selection policy, direct dma prio,
+		 * shorter distance, available credits, then round-robin.
 		 */
 		if (ni_fatal)
 			continue;
 
 		if (best_ni)
 			CDEBUG(D_NET,
-			       "compare ni %s [c:%d, d:%d, s:%d, p:%u] with best_ni %s [c:%d, d:%d, s:%d, p:%u]\n",
+			       "compare ni %s [c:%d, d:%d, s:%d, p:%u, g:%u] with best_ni %s [c:%d, d:%d, s:%d, p:%u, g:%u]\n",
 			       libcfs_nid2str(ni->ni_nid), ni_credits, distance,
-			       ni->ni_seq, ni_sel_prio,
+			       ni->ni_seq, ni_sel_prio, ni_dev_prio,
 			       (best_ni) ? libcfs_nid2str(best_ni->ni_nid)
 			       : "not selected", best_credits, shortest_distance,
 			       (best_ni) ? best_ni->ni_seq : 0,
-			       best_sel_prio);
+			       best_sel_prio, best_dev_prio);
 		else
 			goto select_ni;
 
@@ -1507,6 +1533,11 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		else if (ni_sel_prio < best_sel_prio)
 			goto select_ni;
 
+		if (ni_dev_prio > best_dev_prio)
+			continue;
+		else if (ni_dev_prio < best_dev_prio)
+			goto select_ni;
+
 		if (distance > shortest_distance)
 			continue;
 		else if (distance < shortest_distance)
@@ -1522,6 +1553,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 select_ni:
 		best_sel_prio = ni_sel_prio;
+		best_dev_prio = ni_dev_prio;
 		shortest_distance = distance;
 		best_healthv = ni_healthv;
 		best_ni = ni;
@@ -1812,6 +1844,7 @@ struct lnet_ni *
 lnet_find_best_ni_on_spec_net(struct lnet_ni *cur_best_ni,
 			      struct lnet_peer *peer,
 			      struct lnet_peer_net *peer_net,
+			      struct lnet_msg *msg,
 			      int cpt)
 {
 	struct lnet_net *local_net;
@@ -1829,7 +1862,7 @@ struct lnet_ni *
 	 *	3. Round Robin
 	 */
 	best_ni = lnet_get_best_ni(local_net, cur_best_ni,
-				   peer, peer_net, cpt);
+				   peer, peer_net, msg, cpt);
 
 	return best_ni;
 }
@@ -2064,6 +2097,7 @@ struct lnet_ni *
 	if (!sd->sd_best_ni) {
 		lpn = gwni->lpni_peer_net;
 		sd->sd_best_ni = lnet_find_best_ni_on_spec_net(NULL, gw, lpn,
+							       sd->sd_msg,
 							       sd->sd_md_cpt);
 		if (!sd->sd_best_ni) {
 			CERROR("Internal Error. Expected local ni on %s but non found :%s\n",
@@ -2143,7 +2177,7 @@ struct lnet_ni *
 
 struct lnet_ni *
 lnet_find_best_ni_on_local_net(struct lnet_peer *peer, int md_cpt,
-			       bool discovery)
+			       struct lnet_msg *msg, bool discovery)
 {
 	struct lnet_peer_net *lpn = NULL;
 	struct lnet_peer_net *best_lpn = NULL;
@@ -2237,8 +2271,8 @@ struct lnet_ni *
 		/* Select the best NI on the same net as best_lpn chosen
 		 * above
 		 */
-		best_ni = lnet_find_best_ni_on_spec_net(NULL, peer,
-							best_lpn, md_cpt);
+		best_ni = lnet_find_best_ni_on_spec_net(NULL, peer, best_lpn,
+							msg, md_cpt);
 	}
 
 	return best_ni;
@@ -2298,6 +2332,7 @@ struct lnet_ni *
 		best_ni =
 			lnet_find_best_ni_on_spec_net(NULL, sd->sd_peer,
 						      sd->sd_best_lpni->lpni_peer_net,
+						      sd->sd_msg,
 						      sd->sd_md_cpt);
 		/* If there is no best_ni we don't have a route */
 		if (!best_ni) {
@@ -2350,6 +2385,7 @@ struct lnet_ni *
 		sd->sd_best_ni = lnet_find_best_ni_on_spec_net(NULL,
 							       sd->sd_peer,
 							       sd->sd_best_lpni->lpni_peer_net,
+							       sd->sd_msg,
 							       sd->sd_md_cpt);
 		if (!sd->sd_best_ni) {
 			CERROR("Unable to forward message to %s. No local NI available\n",
@@ -2382,6 +2418,7 @@ struct lnet_ni *
 		sd->sd_best_ni =
 		  lnet_find_best_ni_on_spec_net(NULL, sd->sd_peer,
 						sd->sd_best_lpni->lpni_peer_net,
+						sd->sd_msg,
 						sd->sd_md_cpt);
 
 		if (!sd->sd_best_ni) {
@@ -2403,6 +2440,7 @@ struct lnet_ni *
 	 */
 	sd->sd_best_ni = lnet_find_best_ni_on_local_net(sd->sd_peer,
 					sd->sd_md_cpt,
+					sd->sd_msg,
 					lnet_msg_discovery(sd->sd_msg));
 	if (sd->sd_best_ni) {
 		sd->sd_best_lpni =
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
