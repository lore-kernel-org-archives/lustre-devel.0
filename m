From: James Simmons <jsimmons@infradead.org>
Date: Thu,  5 May 2016 14:53:07 -0400
Subject: [lustre-devel] [PATCH 8/8] staging: lustre: o2iblnd: Add Fast Reg
	memory registration support
In-Reply-To: <1462474387-11406-1-git-send-email-jsimmons@infradead.org>
References: <1462474387-11406-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462474387-11406-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, Li Dongyang <dongyang.li@anu.edu.au>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

FMR is deprecated and it not supported by the mlx5 driver.
This patch adds memory management extensions support as
backup of FMR. This was combined with the work from
Li Dongyang to make it work with the latest kernels.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: Li Dongyang <dongyang.li@anu.edu.au>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5783
Reviewed-on: http://review.whamcloud.com/17606
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  239 +++++++++++++++++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   25 ++-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   50 +++--
 3 files changed, 258 insertions(+), 56 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index fc29d5c..2bb300c 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1302,8 +1302,24 @@ static void kiblnd_destroy_fmr_pool(kib_fmr_pool_t *fpo)
 {
 	LASSERT(!fpo->fpo_map_count);
 
-	if (fpo->fmr.fpo_fmr_pool)
-		ib_destroy_fmr_pool(fpo->fmr.fpo_fmr_pool);
+	if (fpo->fpo_is_fmr) {
+		if (fpo->fmr.fpo_fmr_pool)
+			ib_destroy_fmr_pool(fpo->fmr.fpo_fmr_pool);
+	} else {
+		struct kib_fast_reg_descriptor *frd, *tmp;
+		int i = 0;
+
+		list_for_each_entry_safe(frd, tmp, &fpo->fast_reg.fpo_pool_list,
+					 frd_list) {
+			list_del(&frd->frd_list);
+			ib_dereg_mr(frd->frd_mr);
+			LIBCFS_FREE(frd, sizeof(*frd));
+			i++;
+		}
+		if (i < fpo->fast_reg.fpo_pool_size)
+			CERROR("FastReg pool still has %d regions registered\n",
+			       fpo->fast_reg.fpo_pool_size - i);
+	}
 
 	if (fpo->fpo_hdev)
 		kiblnd_hdev_decref(fpo->fpo_hdev);
@@ -1362,10 +1378,61 @@ static int kiblnd_alloc_fmr_pool(kib_fmr_poolset_t *fps, kib_fmr_pool_t *fpo)
 	return rc;
 }
 
+static int kiblnd_alloc_freg_pool(kib_fmr_poolset_t *fps, kib_fmr_pool_t *fpo)
+{
+	struct kib_fast_reg_descriptor *frd, *tmp;
+	int i, rc;
+
+	INIT_LIST_HEAD(&fpo->fast_reg.fpo_pool_list);
+	fpo->fast_reg.fpo_pool_size = 0;
+	for (i = 0; i < fps->fps_pool_size; i++) {
+		LIBCFS_CPT_ALLOC(frd, lnet_cpt_table(), fps->fps_cpt,
+				 sizeof(*frd));
+		if (!frd) {
+			CERROR("Failed to allocate a new fast_reg descriptor\n");
+			rc = -ENOMEM;
+			goto out;
+		}
+
+		frd->frd_mr = ib_alloc_mr(fpo->fpo_hdev->ibh_pd,
+					  IB_MR_TYPE_MEM_REG,
+					  LNET_MAX_PAYLOAD / PAGE_SIZE);
+		if (IS_ERR(frd->frd_mr)) {
+			rc = PTR_ERR(frd->frd_mr);
+			CERROR("Failed to allocate ib_alloc_mr: %d\n", rc);
+			frd->frd_mr = NULL;
+			goto out_middle;
+		}
+
+		frd->frd_valid = true;
+
+		list_add_tail(&frd->frd_list, &fpo->fast_reg.fpo_pool_list);
+		fpo->fast_reg.fpo_pool_size++;
+	}
+
+	return 0;
+
+out_middle:
+	if (frd->frd_mr)
+		ib_dereg_mr(frd->frd_mr);
+	LIBCFS_FREE(frd, sizeof(*frd));
+
+out:
+	list_for_each_entry_safe(frd, tmp, &fpo->fast_reg.fpo_pool_list,
+				 frd_list) {
+		list_del(&frd->frd_list);
+		ib_dereg_mr(frd->frd_mr);
+		LIBCFS_FREE(frd, sizeof(*frd));
+	}
+
+	return rc;
+}
+
 static int kiblnd_create_fmr_pool(kib_fmr_poolset_t *fps,
 				  kib_fmr_pool_t **pp_fpo)
 {
 	kib_dev_t *dev = fps->fps_net->ibn_dev;
+	struct ib_device_attr *dev_attr;
 	kib_fmr_pool_t *fpo;
 	int rc;
 
@@ -1374,20 +1441,28 @@ static int kiblnd_create_fmr_pool(kib_fmr_poolset_t *fps,
 		return -ENOMEM;
 
 	fpo->fpo_hdev = kiblnd_current_hdev(dev);
+	dev_attr = &fpo->fpo_hdev->ibh_ibdev->attrs;
 
-	/* Check for FMR support */
+	/* Check for FMR or FastReg support */
+	fpo->fpo_is_fmr = 0;
 	if (fpo->fpo_hdev->ibh_ibdev->alloc_fmr &&
 	    fpo->fpo_hdev->ibh_ibdev->dealloc_fmr &&
 	    fpo->fpo_hdev->ibh_ibdev->map_phys_fmr &&
 	    fpo->fpo_hdev->ibh_ibdev->unmap_fmr) {
 		LCONSOLE_INFO("Using FMR for registration\n");
+		fpo->fpo_is_fmr = 1;
+	} else if (dev_attr->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) {
+		LCONSOLE_INFO("Using FastReg for registration\n");
 	} else {
 		rc = -ENOSYS;
-		LCONSOLE_ERROR_MSG(rc, "IB device does not support FMRs, can't register memory\n");
+		LCONSOLE_ERROR_MSG(rc, "IB device does not support FMRs nor FastRegs, can't register memory\n");
 		goto out_fpo;
 	}
 
-	rc = kiblnd_alloc_fmr_pool(fps, fpo);
+	if (fpo->fpo_is_fmr)
+		rc = kiblnd_alloc_fmr_pool(fps, fpo);
+	else
+		rc = kiblnd_alloc_freg_pool(fps, fpo);
 	if (rc)
 		goto out_fpo;
 
@@ -1466,6 +1541,28 @@ static int kiblnd_fmr_pool_is_idle(kib_fmr_pool_t *fpo, unsigned long now)
 	return cfs_time_aftereq(now, fpo->fpo_deadline);
 }
 
+static int
+kiblnd_map_tx_pages(kib_tx_t *tx, kib_rdma_desc_t *rd)
+{
+	__u64 *pages = tx->tx_pages;
+	kib_hca_dev_t *hdev;
+	int npages;
+	int size;
+	int i;
+
+	hdev = tx->tx_pool->tpo_hdev;
+
+	for (i = 0, npages = 0; i < rd->rd_nfrags; i++) {
+		for (size = 0; size <  rd->rd_frags[i].rf_nob;
+		     size += hdev->ibh_page_size) {
+			pages[npages++] = (rd->rd_frags[i].rf_addr &
+					   hdev->ibh_page_mask) + size;
+		}
+	}
+
+	return npages;
+}
+
 void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status)
 {
 	LIST_HEAD(zombies);
@@ -1479,17 +1576,28 @@ void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status)
 		return;
 
 	fps = fpo->fpo_owner;
-	if (fmr->fmr_pfmr) {
-		rc = ib_fmr_pool_unmap(fmr->fmr_pfmr);
-		LASSERT(!rc);
-		fmr->fmr_pfmr = NULL;
-	}
+	if (fpo->fpo_is_fmr) {
+		if (fmr->fmr_pfmr) {
+			rc = ib_fmr_pool_unmap(fmr->fmr_pfmr);
+			LASSERT(!rc);
+			fmr->fmr_pfmr = NULL;
+		}
 
-	if (status) {
-		rc = ib_flush_fmr_pool(fpo->fmr.fpo_fmr_pool);
-		LASSERT(!rc);
-	}
+		if (status) {
+			rc = ib_flush_fmr_pool(fpo->fmr.fpo_fmr_pool);
+			LASSERT(!rc);
+		}
+	} else {
+		struct kib_fast_reg_descriptor *frd = fmr->fmr_frd;
 
+		if (frd) {
+			frd->frd_valid = false;
+			spin_lock(&fps->fps_lock);
+			list_add_tail(&frd->frd_list, &fpo->fast_reg.fpo_pool_list);
+			spin_unlock(&fps->fps_lock);
+			fmr->fmr_frd = NULL;
+		}
+	}
 	fmr->fmr_pool = NULL;
 
 	spin_lock(&fps->fps_lock);
@@ -1511,11 +1619,15 @@ void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status)
 		kiblnd_destroy_fmr_pool_list(&zombies);
 }
 
-int kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, __u64 *pages, int npages,
-			__u32 nob, __u64 iov, bool is_rx, kib_fmr_t *fmr)
+int kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, kib_tx_t *tx,
+			kib_rdma_desc_t *rd, __u32 nob, __u64 iov,
+			kib_fmr_t *fmr)
 {
-	struct ib_pool_fmr *pfmr;
+	__u64 *pages = tx->tx_pages;
+	bool is_rx = (rd != tx->tx_rd);
+        bool tx_pages_mapped = 0;
 	kib_fmr_pool_t *fpo;
+	int npages = 0;
 	__u64 version;
 	int rc;
 
@@ -1525,18 +1637,89 @@ int kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, __u64 *pages, int npages,
 	list_for_each_entry(fpo, &fps->fps_pool_list, fpo_list) {
 		fpo->fpo_deadline = cfs_time_shift(IBLND_POOL_DEADLINE);
 		fpo->fpo_map_count++;
-		spin_unlock(&fps->fps_lock);
 
-		pfmr = ib_fmr_pool_map_phys(fpo->fmr.fpo_fmr_pool,
-					    pages, npages, iov);
-		if (likely(!IS_ERR(pfmr))) {
-			fmr->fmr_key = is_rx ? pfmr->fmr->rkey :
-					       pfmr->fmr->lkey;
-			fmr->fmr_pfmr = pfmr;
-			fmr->fmr_pool = fpo;
-			return 0;
+		if (fpo->fpo_is_fmr) {
+			struct ib_pool_fmr *pfmr;
+
+			spin_unlock(&fps->fps_lock);
+
+			if (!tx_pages_mapped) {
+				npages = kiblnd_map_tx_pages(tx, rd);
+				tx_pages_mapped = 1;
+			}
+
+			pfmr = ib_fmr_pool_map_phys(fpo->fmr.fpo_fmr_pool,
+						    pages, npages, iov);
+			if (likely(!IS_ERR(pfmr))) {
+				fmr->fmr_key = is_rx ? pfmr->fmr->rkey :
+						       pfmr->fmr->lkey;
+				fmr->fmr_frd = NULL;
+				fmr->fmr_pfmr = pfmr;
+				fmr->fmr_pool = fpo;
+				return 0;
+			}
+			rc = PTR_ERR(pfmr);
+		} else {
+			if (!list_empty(&fpo->fast_reg.fpo_pool_list)) {
+				struct kib_fast_reg_descriptor *frd;
+				struct ib_reg_wr *wr;
+				struct ib_mr *mr;
+				int n;
+
+				frd = list_first_entry(&fpo->fast_reg.fpo_pool_list,
+						       struct kib_fast_reg_descriptor,
+						       frd_list);
+				list_del(&frd->frd_list);
+				spin_unlock(&fps->fps_lock);
+
+				mr = frd->frd_mr;
+
+				if (!frd->frd_valid) {
+					__u32 key = is_rx ? mr->rkey : mr->lkey;
+					struct ib_send_wr *inv_wr;
+
+					inv_wr = &frd->frd_inv_wr;
+					memset(inv_wr, 0, sizeof(*inv_wr));
+					inv_wr->opcode = IB_WR_LOCAL_INV;
+					inv_wr->wr_id = IBLND_WID_MR;
+					inv_wr->ex.invalidate_rkey = key;
+
+					/* Bump the key */
+					key = ib_inc_rkey(key);
+					ib_update_fast_reg_key(mr, key);
+				}
+
+				n = ib_map_mr_sg(mr, tx->tx_frags,
+						 tx->tx_nfrags, PAGE_SIZE);
+				if (unlikely(n != tx->tx_nfrags)) {
+					CERROR("Failed to map mr %d/%d elements\n",
+					       n, tx->tx_nfrags);
+					return n < 0 ? n : -EINVAL;
+				}
+
+				mr->iova = iov;
+
+				/* Prepare FastReg WR */
+				wr = &frd->frd_fastreg_wr;
+				memset(wr, 0, sizeof(*wr));
+				wr->wr.opcode = IB_WR_REG_MR;
+				wr->wr.wr_id = IBLND_WID_MR;
+				wr->wr.num_sge = 0;
+				wr->wr.send_flags = 0;
+				wr->mr = mr;
+				wr->key = is_rx ? mr->rkey : mr->lkey;
+				wr->access = (IB_ACCESS_LOCAL_WRITE |
+					      IB_ACCESS_REMOTE_WRITE);
+
+				fmr->fmr_key = is_rx ? mr->rkey : mr->lkey;
+				fmr->fmr_frd = frd;
+				fmr->fmr_pfmr = NULL;
+				fmr->fmr_pool = fpo;
+				return 0;
+			}
+			spin_unlock(&fps->fps_lock);
+			rc = -EBUSY;
 		}
-		rc = PTR_ERR(pfmr);
 
 		spin_lock(&fps->fps_lock);
 		fpo->fpo_map_count--;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 277e633..52245e0 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -291,6 +291,14 @@ typedef struct {
 						   /* failed to allocate */
 } kib_fmr_poolset_t;
 
+struct kib_fast_reg_descriptor { /* For fast registration */
+	struct list_head		 frd_list;
+	struct ib_send_wr		 frd_inv_wr;
+	struct ib_reg_wr		 frd_fastreg_wr;
+	struct ib_mr			*frd_mr;
+	bool				 frd_valid;
+};
+
 typedef struct {
 	struct list_head      fpo_list;            /* chain on pool list */
 	struct kib_hca_dev    *fpo_hdev;           /* device for this pool */
@@ -299,16 +307,22 @@ typedef struct {
 		struct {
 			struct ib_fmr_pool *fpo_fmr_pool; /* IB FMR pool */
 		} fmr;
+		struct { /* For fast registration */
+			struct list_head    fpo_pool_list;
+			int		    fpo_pool_size;
+		} fast_reg;
 	};
 	unsigned long         fpo_deadline;        /* deadline of this pool */
 	int                   fpo_failed;          /* fmr pool is failed */
 	int                   fpo_map_count;       /* # of mapped FMR */
+	int		      fpo_is_fmr;
 } kib_fmr_pool_t;
 
 typedef struct {
-	kib_fmr_pool_t        *fmr_pool;           /* pool of FMR */
-	struct ib_pool_fmr    *fmr_pfmr;           /* IB pool fmr */
-	u32		       fmr_key;
+	kib_fmr_pool_t			*fmr_pool;	/* pool of FMR */
+	struct ib_pool_fmr		*fmr_pfmr;	/* IB pool fmr */
+	struct kib_fast_reg_descriptor	*fmr_frd;
+	u32				 fmr_key;
 } kib_fmr_t;
 
 typedef struct kib_net {
@@ -961,8 +975,9 @@ void kiblnd_unmap_rx_descs(kib_conn_t *conn);
 void kiblnd_pool_free_node(kib_pool_t *pool, struct list_head *node);
 struct list_head *kiblnd_pool_alloc_node(kib_poolset_t *ps);
 
-int  kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, __u64 *pages, int npages,
-			 __u32 nob, __u64 iov, bool is_rx, kib_fmr_t *fmr);
+int  kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, kib_tx_t *tx,
+			 kib_rdma_desc_t *rd, __u32 nob, __u64 iov,
+			 kib_fmr_t *fmr);
 void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status);
 
 int  kiblnd_tunables_init(void);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 7d1c750..c10e615 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -564,34 +564,20 @@ static int
 kiblnd_fmr_map_tx(kib_net_t *net, kib_tx_t *tx, kib_rdma_desc_t *rd, __u32 nob)
 {
 	kib_hca_dev_t *hdev;
-	__u64 *pages = tx->tx_pages;
 	kib_fmr_poolset_t *fps;
-	int npages;
-	int size;
 	int cpt;
 	int rc;
-	int i;
 
 	LASSERT(tx->tx_pool);
 	LASSERT(tx->tx_pool->tpo_pool.po_owner);
 
 	hdev = tx->tx_pool->tpo_hdev;
-
-	for (i = 0, npages = 0; i < rd->rd_nfrags; i++) {
-		for (size = 0; size <  rd->rd_frags[i].rf_nob;
-			       size += hdev->ibh_page_size) {
-			pages[npages++] = (rd->rd_frags[i].rf_addr &
-					    hdev->ibh_page_mask) + size;
-		}
-	}
-
 	cpt = tx->tx_pool->tpo_pool.po_owner->ps_cpt;
 
 	fps = net->ibn_fmr_ps[cpt];
-	rc = kiblnd_fmr_pool_map(fps, pages, npages, nob, 0, (rd != tx->tx_rd),
-				 &tx->fmr);
+	rc = kiblnd_fmr_pool_map(fps, tx, rd, nob, 0, &tx->fmr);
 	if (rc) {
-		CERROR("Can't map %d pages: %d\n", npages, rc);
+		CERROR("Can't map %u bytes: %d\n", nob, rc);
 		return rc;
 	}
 
@@ -849,14 +835,26 @@ kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
 		/* close_conn will launch failover */
 		rc = -ENETDOWN;
 	} else {
-		struct ib_send_wr *wrq = &tx->tx_wrq[tx->tx_nwrq - 1].wr;
+		struct kib_fast_reg_descriptor *frd = tx->fmr.fmr_frd;
+		struct ib_send_wr *bad = &tx->tx_wrq[tx->tx_nwrq - 1].wr;
+		struct ib_send_wr *wrq = &tx->tx_wrq[0].wr;
+
+		if (frd) {
+			if (!frd->frd_valid) {
+				wrq = &frd->frd_inv_wr;
+				wrq->next = &frd->frd_fastreg_wr.wr;
+			} else {
+				wrq = &frd->frd_fastreg_wr.wr;
+			}
+			frd->frd_fastreg_wr.wr.next = &tx->tx_wrq[0].wr;
+		}
 
-		LASSERTF(wrq->wr_id == kiblnd_ptr2wreqid(tx, IBLND_WID_TX),
+		LASSERTF(bad->wr_id == kiblnd_ptr2wreqid(tx, IBLND_WID_TX),
 			 "bad wr_id %llx, opc %d, flags %d, peer: %s\n",
-			 wrq->wr_id, wrq->opcode, wrq->send_flags,
-		libcfs_nid2str(conn->ibc_peer->ibp_nid));
-		wrq = NULL;
-		rc = ib_post_send(conn->ibc_cmid->qp, &tx->tx_wrq->wr, &wrq);
+			 bad->wr_id, bad->opcode, bad->send_flags,
+			 libcfs_nid2str(conn->ibc_peer->ibp_nid));
+		bad = NULL;
+		rc = ib_post_send(conn->ibc_cmid->qp, wrq, &bad);
 	}
 
 	conn->ibc_last_send = jiffies;
@@ -1064,7 +1062,7 @@ kiblnd_init_rdma(kib_conn_t *conn, kib_tx_t *tx, int type,
 	kib_msg_t *ibmsg = tx->tx_msg;
 	kib_rdma_desc_t *srcrd = tx->tx_rd;
 	struct ib_sge *sge = &tx->tx_sge[0];
-	struct ib_rdma_wr *wrq = &tx->tx_wrq[0], *next;
+	struct ib_rdma_wr *wrq, *next;
 	int rc  = resid;
 	int srcidx = 0;
 	int dstidx = 0;
@@ -3428,6 +3426,12 @@ kiblnd_complete(struct ib_wc *wc)
 	default:
 		LBUG();
 
+	case IBLND_WID_MR:
+		if (wc->status != IB_WC_SUCCESS &&
+		    wc->status != IB_WC_WR_FLUSH_ERR)
+			CNETERR("FastReg failed: %d\n", wc->status);
+		break;
+
 	case IBLND_WID_RDMA:
 		/*
 		 * We only get RDMA completion notification if it fails.  All
-- 
1.7.1
