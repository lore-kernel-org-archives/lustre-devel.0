From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:55:23 -0400
Subject: [lustre-devel] [PATCH 01/10] lustre: lnd: set device capabilities
In-Reply-To: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
References: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543332-28679-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

MLX-4, MLX-5 and OPA support different capabilities. Query the
device and cache the capabilities of the device for future use.

At the time of the patches creation MLX5 could support fast
registration and gaps while MLX4 and OPA only support FMR

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10129
Reviewed-on: https://review.whamcloud.com/30309
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 41 ++++++++++++----------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  5 +++
 2 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index bf969b3..b10658b 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1399,6 +1399,7 @@ static int kiblnd_alloc_fmr_pool(struct kib_fmr_poolset *fps, struct kib_fmr_poo
 		else
 			CERROR("FMRs are not supported\n");
 	}
+	fpo->fpo_is_fmr = true;
 
 	return rc;
 }
@@ -1408,6 +1409,8 @@ static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps, struct kib_fmr_po
 	struct kib_fast_reg_descriptor *frd;
 	int i, rc;
 
+	fpo->fpo_is_fmr = false;
+
 	INIT_LIST_HEAD(&fpo->fast_reg.fpo_pool_list);
 	fpo->fast_reg.fpo_pool_size = 0;
 	for (i = 0; i < fps->fps_pool_size; i++) {
@@ -1469,23 +1472,7 @@ static int kiblnd_create_fmr_pool(struct kib_fmr_poolset *fps,
 	fpo->fpo_hdev = kiblnd_current_hdev(dev);
 	dev_attr = &fpo->fpo_hdev->ibh_ibdev->attrs;
 
-	/* Check for FMR or FastReg support */
-	fpo->fpo_is_fmr = 0;
-	if (fpo->fpo_hdev->ibh_ibdev->alloc_fmr &&
-	    fpo->fpo_hdev->ibh_ibdev->dealloc_fmr &&
-	    fpo->fpo_hdev->ibh_ibdev->map_phys_fmr &&
-	    fpo->fpo_hdev->ibh_ibdev->unmap_fmr) {
-		LCONSOLE_INFO("Using FMR for registration\n");
-		fpo->fpo_is_fmr = 1;
-	} else if (dev_attr->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) {
-		LCONSOLE_INFO("Using FastReg for registration\n");
-	} else {
-		rc = -ENOSYS;
-		LCONSOLE_ERROR_MSG(rc, "IB device does not support FMRs nor FastRegs, can't register memory\n");
-		goto out_fpo;
-	}
-
-	if (fpo->fpo_is_fmr)
+	if (dev->ibd_dev_caps & IBLND_DEV_CAPS_FMR_ENABLED)
 		rc = kiblnd_alloc_fmr_pool(fps, fpo);
 	else
 		rc = kiblnd_alloc_freg_pool(fps, fpo);
@@ -2261,6 +2248,9 @@ static int kiblnd_net_init_pools(struct kib_net *net, struct lnet_ni *ni,
 
 static int kiblnd_hdev_get_attr(struct kib_hca_dev *hdev)
 {
+	struct ib_device_attr *dev_attr = &hdev->ibh_ibdev->attrs;
+	int rc = 0;
+
 	/*
 	 * It's safe to assume a HCA can handle a page size
 	 * matching that of the native system
@@ -2269,7 +2259,22 @@ static int kiblnd_hdev_get_attr(struct kib_hca_dev *hdev)
 	hdev->ibh_page_size  = 1 << PAGE_SHIFT;
 	hdev->ibh_page_mask  = ~((__u64)hdev->ibh_page_size - 1);
 
-	hdev->ibh_mr_size = hdev->ibh_ibdev->attrs.max_mr_size;
+	if (hdev->ibh_ibdev->alloc_fmr &&
+	    hdev->ibh_ibdev->dealloc_fmr &&
+	    hdev->ibh_ibdev->map_phys_fmr &&
+	    hdev->ibh_ibdev->unmap_fmr) {
+		LCONSOLE_INFO("Using FMR for registration\n");
+		hdev->ibh_dev->ibd_dev_caps |= IBLND_DEV_CAPS_FMR_ENABLED;
+	} else if (dev_attr->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) {
+		LCONSOLE_INFO("Using FastReg for registration\n");
+		hdev->ibh_dev->ibd_dev_caps |= IBLND_DEV_CAPS_FASTREG_ENABLED;
+	} else {
+		CERROR("IB device does not support FMRs nor FastRegs, can't register memory: %d\n",
+		       rc);
+		return -ENXIO;
+	}
+
+	hdev->ibh_mr_size = dev_attr->max_mr_size;
 	if (hdev->ibh_mr_size == ~0ULL) {
 		hdev->ibh_mr_shift = 64;
 		return 0;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index a4438d2..9f0a47d 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -73,6 +73,10 @@
 #define IBLND_N_SCHED			2
 #define IBLND_N_SCHED_HIGH		4
 
+#define IBLND_DEV_CAPS_FASTREG_ENABLED		0x1
+#define IBLND_DEV_CAPS_FASTREG_GAPS_SUPPORT	0x2
+#define IBLND_DEV_CAPS_FMR_ENABLED		0x4
+
 struct kib_tunables {
 	int *kib_dev_failover;           /* HCA failover */
 	unsigned int *kib_service;       /* IB service number */
@@ -162,6 +166,7 @@ struct kib_dev {
 	unsigned int ibd_can_failover; /* IPoIB interface is a bonding master */
 	struct list_head   ibd_nets;
 	struct kib_hca_dev *ibd_hdev;
+	u32			ibd_dev_caps;
 };
 
 struct kib_hca_dev {
-- 
1.8.3.1
