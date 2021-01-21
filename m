Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D48CDC433E0
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:19:13 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7000123A57
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:19:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7000123A57
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3716521FFE7;
	Thu, 21 Jan 2021 09:18:17 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 98B5721FBE8
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:15 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 88B721008493;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 878CD1B49C; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:58 -0500
Message-Id: <1611249422-556-36-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 35/39] lnet: o2iblnd: remove FMR-pool support.
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

Linux 5.8 removes the FMR-pool API.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13783
Lustre-commit: 6fd5c8bef83aaf ("LU-13783 o2iblnd: make FMR-pool support optional.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/40287
Reviewed-by: Sergey Gorenko <sergeygo@nvidia.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c    | 268 +++++++++++-------------------------
 net/lnet/klnds/o2iblnd/o2iblnd.h    |   6 -
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c |  27 +---
 3 files changed, 81 insertions(+), 220 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index fc515fc..9147d17 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1313,27 +1313,23 @@ static void kiblnd_map_tx_pool(struct kib_tx_pool *tpo)
 
 static void kiblnd_destroy_fmr_pool(struct kib_fmr_pool *fpo)
 {
-	LASSERT(!fpo->fpo_map_count);
+	struct kib_fast_reg_descriptor *frd;
+	int i = 0;
 
-	if (!IS_ERR_OR_NULL(fpo->fmr.fpo_fmr_pool)) {
-		ib_destroy_fmr_pool(fpo->fmr.fpo_fmr_pool);
-	} else {
-		struct kib_fast_reg_descriptor *frd;
-		int i = 0;
+	LASSERT(!fpo->fpo_map_count);
 
-		while (!list_empty(&fpo->fast_reg.fpo_pool_list)) {
-			frd = list_first_entry(&fpo->fast_reg.fpo_pool_list,
-					       struct kib_fast_reg_descriptor,
-					       frd_list);
-			list_del(&frd->frd_list);
-			ib_dereg_mr(frd->frd_mr);
-			kfree(frd);
-			i++;
-		}
-		if (i < fpo->fast_reg.fpo_pool_size)
-			CERROR("FastReg pool still has %d regions registered\n",
-			       fpo->fast_reg.fpo_pool_size - i);
+	while (!list_empty(&fpo->fast_reg.fpo_pool_list)) {
+		frd = list_first_entry(&fpo->fast_reg.fpo_pool_list,
+				       struct kib_fast_reg_descriptor,
+				       frd_list);
+		list_del(&frd->frd_list);
+		ib_dereg_mr(frd->frd_mr);
+		kfree(frd);
+		i++;
 	}
+	if (i < fpo->fast_reg.fpo_pool_size)
+		CERROR("FastReg pool still has %d regions registered\n",
+		       fpo->fast_reg.fpo_pool_size - i);
 
 	if (fpo->fpo_hdev)
 		kiblnd_hdev_decref(fpo->fpo_hdev);
@@ -1370,34 +1366,6 @@ static void kiblnd_destroy_fmr_pool_list(struct list_head *head)
 	return max(IBLND_FMR_POOL_FLUSH, size);
 }
 
-static int kiblnd_alloc_fmr_pool(struct kib_fmr_poolset *fps, struct kib_fmr_pool *fpo)
-{
-	struct ib_fmr_pool_param param = {
-		.max_pages_per_fmr	= LNET_MAX_IOV,
-		.page_shift		= PAGE_SHIFT,
-		.access			= (IB_ACCESS_LOCAL_WRITE |
-					   IB_ACCESS_REMOTE_WRITE),
-		.pool_size		= fps->fps_pool_size,
-		.dirty_watermark	= fps->fps_flush_trigger,
-		.flush_function		= NULL,
-		.flush_arg		= NULL,
-		.cache			= !!fps->fps_cache
-	};
-	int rc = 0;
-
-	fpo->fmr.fpo_fmr_pool = ib_create_fmr_pool(fpo->fpo_hdev->ibh_pd,
-						   &param);
-	if (IS_ERR(fpo->fmr.fpo_fmr_pool)) {
-		rc = PTR_ERR(fpo->fmr.fpo_fmr_pool);
-		if (rc != -ENOSYS)
-			CERROR("Failed to create FMR pool: %d\n", rc);
-		else
-			CERROR("FMRs are not supported\n");
-	}
-
-	return rc;
-}
-
 static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps,
 				  struct kib_fmr_pool *fpo,
 				  enum kib_dev_caps dev_caps)
@@ -1481,10 +1449,7 @@ static int kiblnd_create_fmr_pool(struct kib_fmr_poolset *fps,
 	fpo->fpo_hdev = kiblnd_current_hdev(dev);
 	dev_attr = &fpo->fpo_hdev->ibh_ibdev->attrs;
 
-	if (dev->ibd_dev_caps & IBLND_DEV_CAPS_FMR_ENABLED)
-		rc = kiblnd_alloc_fmr_pool(fps, fpo);
-	else
-		rc = kiblnd_alloc_freg_pool(fps, fpo, dev->ibd_dev_caps);
+	rc = kiblnd_alloc_freg_pool(fps, fpo, dev->ibd_dev_caps);
 	if (rc)
 		goto out_fpo;
 
@@ -1568,61 +1533,25 @@ static int kiblnd_fmr_pool_is_idle(struct kib_fmr_pool *fpo, time64_t now)
 	return now >= fpo->fpo_deadline;
 }
 
-static int
-kiblnd_map_tx_pages(struct kib_tx *tx, struct kib_rdma_desc *rd)
-{
-	u64 *pages = tx->tx_pages;
-	struct kib_hca_dev *hdev;
-	int npages;
-	int size;
-	int i;
-
-	hdev = tx->tx_pool->tpo_hdev;
-
-	for (i = 0, npages = 0; i < rd->rd_nfrags; i++) {
-		for (size = 0; size <  rd->rd_frags[i].rf_nob;
-		     size += hdev->ibh_page_size) {
-			pages[npages++] = (rd->rd_frags[i].rf_addr &
-					   hdev->ibh_page_mask) + size;
-		}
-	}
-
-	return npages;
-}
-
 void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status)
 {
+	struct kib_fast_reg_descriptor *frd = fmr->fmr_frd;
 	LIST_HEAD(zombies);
 	struct kib_fmr_pool *fpo = fmr->fmr_pool;
 	struct kib_fmr_poolset *fps;
 	time64_t now = ktime_get_seconds();
 	struct kib_fmr_pool *tmp;
-	int rc;
 
 	if (!fpo)
 		return;
 
 	fps = fpo->fpo_owner;
-	if (!IS_ERR_OR_NULL(fpo->fmr.fpo_fmr_pool)) {
-		if (fmr->fmr_pfmr) {
-			ib_fmr_pool_unmap(fmr->fmr_pfmr);
-			fmr->fmr_pfmr = NULL;
-		}
-
-		if (status) {
-			rc = ib_flush_fmr_pool(fpo->fmr.fpo_fmr_pool);
-			LASSERT(!rc);
-		}
-	} else {
-		struct kib_fast_reg_descriptor *frd = fmr->fmr_frd;
-
-		if (frd) {
-			frd->frd_valid = false;
-			spin_lock(&fps->fps_lock);
-			list_add_tail(&frd->frd_list, &fpo->fast_reg.fpo_pool_list);
-			spin_unlock(&fps->fps_lock);
-			fmr->fmr_frd = NULL;
-		}
+	if (frd) {
+		frd->frd_valid = false;
+		spin_lock(&fps->fps_lock);
+		list_add_tail(&frd->frd_list, &fpo->fast_reg.fpo_pool_list);
+		spin_unlock(&fps->fps_lock);
+		fmr->fmr_frd = NULL;
 	}
 	fmr->fmr_pool = NULL;
 
@@ -1649,11 +1578,8 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 			struct kib_rdma_desc *rd, u32 nob, u64 iov,
 			struct kib_fmr *fmr)
 {
-	u64 *pages = tx->tx_pages;
 	bool is_rx = (rd != tx->tx_rd);
-	bool tx_pages_mapped = false;
 	struct kib_fmr_pool *fpo;
-	int npages = 0;
 	u64 version;
 	int rc;
 
@@ -1664,96 +1590,65 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 		fpo->fpo_deadline = ktime_get_seconds() + IBLND_POOL_DEADLINE;
 		fpo->fpo_map_count++;
 
-		if (!IS_ERR_OR_NULL(fpo->fmr.fpo_fmr_pool)) {
-			struct ib_pool_fmr *pfmr;
+		if (!list_empty(&fpo->fast_reg.fpo_pool_list)) {
+			struct kib_fast_reg_descriptor *frd;
+			struct ib_reg_wr *wr;
+			struct ib_mr *mr;
+			int n;
 
+			frd = list_first_entry(&fpo->fast_reg.fpo_pool_list,
+					       struct kib_fast_reg_descriptor,
+					       frd_list);
+			list_del(&frd->frd_list);
 			spin_unlock(&fps->fps_lock);
 
-			if (!tx_pages_mapped) {
-				npages = kiblnd_map_tx_pages(tx, rd);
-				tx_pages_mapped = 1;
-			}
+			mr = frd->frd_mr;
 
-			pfmr = ib_fmr_pool_map_phys(fpo->fmr.fpo_fmr_pool,
-						    pages, npages, iov);
-			if (likely(!IS_ERR(pfmr))) {
-				fmr->fmr_key = is_rx ? pfmr->fmr->rkey :
-						       pfmr->fmr->lkey;
-				fmr->fmr_frd = NULL;
-				fmr->fmr_pfmr = pfmr;
-				fmr->fmr_pool = fpo;
-				return 0;
+			if (!frd->frd_valid) {
+				u32 key = is_rx ? mr->rkey : mr->lkey;
+				struct ib_send_wr *inv_wr;
+
+				inv_wr = &frd->frd_inv_wr;
+				memset(inv_wr, 0, sizeof(*inv_wr));
+				inv_wr->opcode = IB_WR_LOCAL_INV;
+				inv_wr->wr_id = IBLND_WID_MR;
+				inv_wr->ex.invalidate_rkey = key;
+
+				/* Bump the key */
+				key = ib_inc_rkey(key);
+				ib_update_fast_reg_key(mr, key);
 			}
-			rc = PTR_ERR(pfmr);
-		} else {
-			if (!list_empty(&fpo->fast_reg.fpo_pool_list)) {
-				struct kib_fast_reg_descriptor *frd;
-				struct ib_reg_wr *wr;
-				struct ib_mr *mr;
-				int n;
-
-				frd = list_first_entry(&fpo->fast_reg.fpo_pool_list,
-						       struct kib_fast_reg_descriptor,
-						       frd_list);
-				list_del(&frd->frd_list);
-				spin_unlock(&fps->fps_lock);
-
-				mr = frd->frd_mr;
-
-				if (!frd->frd_valid) {
-					u32 key = is_rx ? mr->rkey : mr->lkey;
-					struct ib_send_wr *inv_wr;
-
-					inv_wr = &frd->frd_inv_wr;
-					memset(inv_wr, 0, sizeof(*inv_wr));
-					inv_wr->opcode = IB_WR_LOCAL_INV;
-					inv_wr->wr_id = IBLND_WID_MR;
-					inv_wr->ex.invalidate_rkey = key;
-
-					/* Bump the key */
-					key = ib_inc_rkey(key);
-					ib_update_fast_reg_key(mr, key);
-				}
-
-				n = ib_map_mr_sg(mr, tx->tx_frags,
-						 rd->rd_nfrags, NULL,
-						 PAGE_SIZE);
-				if (unlikely(n != rd->rd_nfrags)) {
-					CERROR("Failed to map mr %d/%d elements\n",
-					       n, rd->rd_nfrags);
-					return n < 0 ? n : -EINVAL;
-				}
-
-				/* Prepare FastReg WR */
-				wr = &frd->frd_fastreg_wr;
-				memset(wr, 0, sizeof(*wr));
-				wr->wr.opcode = IB_WR_REG_MR;
-				wr->wr.wr_id = IBLND_WID_MR;
-				wr->wr.num_sge = 0;
-				wr->wr.send_flags = 0;
-				wr->mr = mr;
-				wr->key = is_rx ? mr->rkey : mr->lkey;
-				wr->access = (IB_ACCESS_LOCAL_WRITE |
-					      IB_ACCESS_REMOTE_WRITE);
-
-				fmr->fmr_key = is_rx ? mr->rkey : mr->lkey;
-				fmr->fmr_frd = frd;
-				fmr->fmr_pfmr = NULL;
-				fmr->fmr_pool = fpo;
-				return 0;
+
+			n = ib_map_mr_sg(mr, tx->tx_frags,
+					 rd->rd_nfrags, NULL,
+					 PAGE_SIZE);
+			if (unlikely(n != rd->rd_nfrags)) {
+				CERROR("Failed to map mr %d/%d elements\n",
+				       n, rd->rd_nfrags);
+				return n < 0 ? n : -EINVAL;
 			}
-			spin_unlock(&fps->fps_lock);
-			rc = -EAGAIN;
-		}
 
-		spin_lock(&fps->fps_lock);
-		fpo->fpo_map_count--;
-		if (rc != -EAGAIN) {
-			spin_unlock(&fps->fps_lock);
-			return rc;
+			/* Prepare FastReg WR */
+			wr = &frd->frd_fastreg_wr;
+			memset(wr, 0, sizeof(*wr));
+			wr->wr.opcode = IB_WR_REG_MR;
+			wr->wr.wr_id = IBLND_WID_MR;
+			wr->wr.num_sge = 0;
+			wr->wr.send_flags = 0;
+			wr->mr = mr;
+			wr->key = is_rx ? mr->rkey : mr->lkey;
+			wr->access = (IB_ACCESS_LOCAL_WRITE |
+				      IB_ACCESS_REMOTE_WRITE);
+
+			fmr->fmr_key = is_rx ? mr->rkey : mr->lkey;
+			fmr->fmr_frd = frd;
+			fmr->fmr_pool = fpo;
+			return 0;
 		}
 
 		/* EAGAIN and ... */
+		rc = -EAGAIN;
+		fpo->fpo_map_count--;
 		if (version != fps->fps_version) {
 			spin_unlock(&fps->fps_lock);
 			goto again;
@@ -2353,32 +2248,25 @@ static int kiblnd_hdev_get_attr(struct kib_hca_dev *hdev)
 	hdev->ibh_page_size = 1 << PAGE_SHIFT;
 	hdev->ibh_page_mask = ~((u64)hdev->ibh_page_size - 1);
 
-	if (hdev->ibh_ibdev->ops.alloc_fmr &&
-	    hdev->ibh_ibdev->ops.dealloc_fmr &&
-	    hdev->ibh_ibdev->ops.map_phys_fmr &&
-	    hdev->ibh_ibdev->ops.unmap_fmr) {
-		LCONSOLE_INFO("Using FMR for registration\n");
-		hdev->ibh_dev->ibd_dev_caps |= IBLND_DEV_CAPS_FMR_ENABLED;
-	} else if (dev_attr->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) {
+	hdev->ibh_mr_size = dev_attr->max_mr_size;
+	hdev->ibh_max_qp_wr = dev_attr->max_qp_wr;
+
+	if (dev_attr->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) {
 		LCONSOLE_INFO("Using FastReg for registration\n");
 		hdev->ibh_dev->ibd_dev_caps |= IBLND_DEV_CAPS_FASTREG_ENABLED;
 		if (dev_attr->device_cap_flags & IB_DEVICE_SG_GAPS_REG)
 			hdev->ibh_dev->ibd_dev_caps |= IBLND_DEV_CAPS_FASTREG_GAPS_SUPPORT;
 	} else {
-		CERROR("IB device does not support FMRs nor FastRegs, can't register memory: %d\n",
+		CERROR("IB device does not support FastRegs, can't register memory: %d\n",
 		       -ENXIO);
 		return -ENXIO;
 	}
 
-	hdev->ibh_mr_size = dev_attr->max_mr_size;
-	hdev->ibh_max_qp_wr = dev_attr->max_qp_wr;
-
 	rc2 = kiblnd_port_get_attr(hdev);
 	if (rc2 != 0)
-		return rc2;
+		CERROR("Invalid mr size: %#llx\n", hdev->ibh_mr_size);
 
-	CERROR("Invalid mr size: %#llx\n", hdev->ibh_mr_size);
-	return -EINVAL;
+	return rc2;
 }
 
 void kiblnd_hdev_destroy(struct kib_hca_dev *hdev)
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 424ca07..12d220c 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -60,7 +60,6 @@
 #include <rdma/rdma_cm.h>
 #include <rdma/ib_cm.h>
 #include <rdma/ib_verbs.h>
-#include <rdma/ib_fmr_pool.h>
 
 #define DEBUG_SUBSYSTEM S_LND
 
@@ -146,7 +145,6 @@ struct kib_tunables {
 enum kib_dev_caps {
 	IBLND_DEV_CAPS_FASTREG_ENABLED		= BIT(0),
 	IBLND_DEV_CAPS_FASTREG_GAPS_SUPPORT	= BIT(1),
-	IBLND_DEV_CAPS_FMR_ENABLED		= BIT(2),
 };
 
 struct kib_dev {
@@ -281,9 +279,6 @@ struct kib_fmr_pool {
 	struct kib_hca_dev	*fpo_hdev;	/* device for this pool */
 	struct kib_fmr_poolset	*fpo_owner;	/* owner of this pool */
 	union {
-		struct {
-			struct ib_fmr_pool	*fpo_fmr_pool; /* IB FMR pool */
-		} fmr;
 		struct { /* For fast registration */
 			struct list_head	fpo_pool_list;
 			int			fpo_pool_size;
@@ -296,7 +291,6 @@ struct kib_fmr_pool {
 
 struct kib_fmr {
 	struct kib_fmr_pool		*fmr_pool;	/* pool of FMR */
-	struct ib_pool_fmr		*fmr_pfmr;	/* IB pool fmr */
 	struct kib_fast_reg_descriptor	*fmr_frd;
 	u32				 fmr_key;
 };
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 5cd367e5..c799453 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -575,23 +575,6 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 		return -EPROTONOSUPPORT;
 	}
 
-	/*
-	 * FMR does not support gaps but the tx has gaps then
-	 * we should make sure that the number of fragments we'll be sending
-	 * over fits within the number of fragments negotiated on the
-	 * connection, otherwise, we won't be able to RDMA the data.
-	 * We need to maintain the number of fragments negotiation on the
-	 * connection for backwards compatibility.
-	 */
-	if (tx->tx_gaps && (dev->ibd_dev_caps & IBLND_DEV_CAPS_FMR_ENABLED)) {
-		if (tx->tx_conn &&
-		    tx->tx_conn->ibc_max_frags <= rd->rd_nfrags) {
-			CERROR("TX number of frags (%d) is <= than connection number of frags (%d). Consider setting peer's map_on_demand to 256\n",
-			       tx->tx_nfrags, tx->tx_conn->ibc_max_frags);
-			return -EFBIG;
-		}
-	}
-
 	fps = net->ibn_fmr_ps[cpt];
 	rc = kiblnd_fmr_pool_map(fps, tx, rd, nob, 0, &tx->tx_fmr);
 	if (rc) {
@@ -606,14 +589,10 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	 */
 	rd->rd_key = tx->tx_fmr.fmr_key;
 	/*
-	 * for FastReg or FMR with no gaps we can accumulate all
+	 * for FastReg with no gaps we can accumulate all
 	 * the fragments in one FastReg or FMR fragment.
 	 */
-	if (((dev->ibd_dev_caps & IBLND_DEV_CAPS_FMR_ENABLED) && !tx->tx_gaps) ||
-	    (dev->ibd_dev_caps & IBLND_DEV_CAPS_FASTREG_ENABLED)) {
-		/* FMR requires zero based address */
-		if (dev->ibd_dev_caps & IBLND_DEV_CAPS_FMR_ENABLED)
-			rd->rd_frags[0].rf_addr &= ~hdev->ibh_page_mask;
+	if (dev->ibd_dev_caps & IBLND_DEV_CAPS_FASTREG_ENABLED) {
 		rd->rd_frags[0].rf_nob = nob;
 		rd->rd_nfrags = 1;
 	} else {
@@ -633,7 +612,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 
 static void kiblnd_unmap_tx(struct kib_tx *tx)
 {
-	if (tx->tx_fmr.fmr_pfmr || tx->tx_fmr.fmr_frd)
+	if (tx->tx_fmr.fmr_frd)
 		kiblnd_fmr_pool_unmap(&tx->tx_fmr, tx->tx_status);
 
 	if (tx->tx_nfrags) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
