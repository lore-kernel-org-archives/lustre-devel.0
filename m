Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id ABD85C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:05 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E0319200EC8;
	Sun, 28 Nov 2021 15:28:03 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3094E200EDC
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:28:01 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 9B12324A;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 98B8EC1AC9; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:43 -0500
Message-Id: <1638142074-5945-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/19] lnet: o2iblnd: Fix logic for unaligned
 transfer
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

It's possible for there to be an offset for the first page of a
transfer. However, there are two bugs with this code in o2iblnd.

The first is that this use-case will require LNET_MAX_IOV + 1 local
RDMA fragments, but we do not specify the correct corresponding values
for the max page list to ib_alloc_fast_reg_page_list(),
ib_alloc_fast_reg_mr(), etc.

The second issue is that the logic in kiblnd_setup_rd_kiov() attempts
to obtain one more scatterlist entry than is actually needed. This
causes the transfer to fail with -EFAULT.

HPE-bug-id: LUS-10407
WC-bug-id: https://jira.whamcloud.com/browse/LU-15092
Lustre-commit: 23a2c92f203ff2f39 ("LU-15092 o2iblnd: Fix logic for unaligned transfer")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/45216
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c    |  2 +-
 net/lnet/klnds/o2iblnd/o2iblnd.h    |  6 ++++--
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 15 +++++++++------
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 36d26b2..9cdc12a 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1392,7 +1392,7 @@ static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps,
 		frd->frd_mr = ib_alloc_mr(fpo->fpo_hdev->ibh_pd,
 					  fastreg_gaps ? IB_MR_TYPE_SG_GAPS :
 							 IB_MR_TYPE_MEM_REG,
-					  LNET_MAX_IOV);
+					  IBLND_MAX_RDMA_FRAGS);
 		if (IS_ERR(frd->frd_mr)) {
 			rc = PTR_ERR(frd->frd_mr);
 			CERROR("Failed to allocate ib_alloc_mr: %d\n", rc);
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 5066f7b..21f8981 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -112,8 +112,10 @@ struct kib_tunables {
 #define IBLND_OOB_CAPABLE(v)	((v) != IBLND_MSG_VERSION_1)
 #define IBLND_OOB_MSGS(v)	(IBLND_OOB_CAPABLE(v) ? 2 : 0)
 
-#define IBLND_MSG_SIZE		(4 << 10)	/* max size of queued messages (inc hdr) */
-#define IBLND_MAX_RDMA_FRAGS	LNET_MAX_IOV	/* max # of fragments supported */
+/* max size of queued messages (inc hdr) */
+#define IBLND_MSG_SIZE		(4 << 10)
+/* max # of fragments supported. + 1 for unaligned case */
+#define IBLND_MAX_RDMA_FRAGS	(LNET_MAX_IOV + 1)
 
 /************************/
 /* derived constants... */
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index a053e7d..db13f41 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -662,6 +662,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	struct scatterlist *sg;
 	int fragnob;
 	int max_nkiov;
+	int sg_count = 0;
 
 	CDEBUG(D_NET, "niov %d offset %d nob %d\n", nkiov, offset, nob);
 
@@ -682,6 +683,12 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	do {
 		LASSERT(nkiov > 0);
 
+		if (!sg) {
+			CERROR("lacking enough sg entries to map tx\n");
+			return -EFAULT;
+		}
+		sg_count++;
+
 		fragnob = min((int)(kiov->bv_len - offset), nob);
 
 		/* We're allowed to start at a non-aligned page offset in
@@ -700,10 +707,6 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		sg_set_page(sg, kiov->bv_page, fragnob,
 			    kiov->bv_offset + offset);
 		sg = sg_next(sg);
-		if (!sg) {
-			CERROR("lacking enough sg entries to map tx\n");
-			return -EFAULT;
-		}
 
 		offset = 0;
 		kiov++;
@@ -711,7 +714,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		nob -= fragnob;
 	} while (nob > 0);
 
-	return kiblnd_map_tx(ni, tx, rd, sg - tx->tx_frags);
+	return kiblnd_map_tx(ni, tx, rd, sg_count);
 }
 
 static int
@@ -1008,7 +1011,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	int nob = offsetof(struct kib_msg, ibm_u) + body_nob;
 
 	LASSERT(tx->tx_nwrq >= 0);
-	LASSERT(tx->tx_nwrq < IBLND_MAX_RDMA_FRAGS + 1);
+	LASSERT(tx->tx_nwrq <= IBLND_MAX_RDMA_FRAGS);
 	LASSERT(nob <= IBLND_MSG_SIZE);
 
 	kiblnd_init_msg(tx->tx_msg, type, body_nob);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
