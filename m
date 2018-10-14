From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:55:24 -0400
Subject: [lustre-devel] [PATCH 02/10] lustre: o2iblnd: use IB_MR_TYPE_SG_GAPS
In-Reply-To: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
References: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543332-28679-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When allocating fastreg buffers allow the use of IB_MR_TYPE_SG_GAPS
instead of IB_MR_TYPE_MEM_REG, since the fragments we provide
the fast registration API can have gaps. MEM_REG doesn't handle
that case.

There is a performance drop when using IB_MR_TYPE_SG_GAPS and it
is recommended not to use it. To mitigate this, we added a module
parameter, use_fastreg_gaps, which defaults to 0. When allocating
the memory region if this parameter is set to 1 and the hw has
gaps support then use it and output a warning that performance
may drop. Otherwise always use IB_MR_TYPE_MEM_REG. We still want
to give user the choice to use this option.

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10089
Reviewed-on: https://review.whamcloud.com/29551
WC-bug-id: https://jira.whamcloud.com/browse/LU-10394
Reviewed-on: https://review.whamcloud.com/30749
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 24 +++++++++++++++++++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  3 +++
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |  5 +++++
 3 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index b10658b..ca3e9ce 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1404,7 +1404,8 @@ static int kiblnd_alloc_fmr_pool(struct kib_fmr_poolset *fps, struct kib_fmr_poo
 	return rc;
 }
 
-static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps, struct kib_fmr_pool *fpo)
+static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps,
+				  struct kib_fmr_pool *fpo, u32 dev_caps)
 {
 	struct kib_fast_reg_descriptor *frd;
 	int i, rc;
@@ -1414,6 +1415,8 @@ static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps, struct kib_fmr_po
 	INIT_LIST_HEAD(&fpo->fast_reg.fpo_pool_list);
 	fpo->fast_reg.fpo_pool_size = 0;
 	for (i = 0; i < fps->fps_pool_size; i++) {
+		bool fastreg_gaps = false;
+
 		frd = kzalloc_cpt(sizeof(*frd), GFP_NOFS, fps->fps_cpt);
 		if (!frd) {
 			CERROR("Failed to allocate a new fast_reg descriptor\n");
@@ -1421,8 +1424,21 @@ static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps, struct kib_fmr_po
 			goto out;
 		}
 
+		/*
+		 * it is expected to get here if this is an MLX-5 card.
+		 * MLX-4 cards will always use FMR and MLX-5 cards will
+		 * always use fast_reg. It turns out that some MLX-5 cards
+		 * (possibly due to older FW versions) do not natively support
+		 * gaps. So we will need to track them here.
+		 */
+		if ((*kiblnd_tunables.kib_use_fastreg_gaps == 1) &&
+		    (dev_caps & IBLND_DEV_CAPS_FASTREG_GAPS_SUPPORT)) {
+			CWARN("using IB_MR_TYPE_SG_GAPS, expect a performance drop\n");
+			fastreg_gaps = true;
+		}
 		frd->frd_mr = ib_alloc_mr(fpo->fpo_hdev->ibh_pd,
-					  IB_MR_TYPE_MEM_REG,
+					  fastreg_gaps ? IB_MR_TYPE_SG_GAPS :
+							 IB_MR_TYPE_MEM_REG,
 					  LNET_MAX_PAYLOAD / PAGE_SIZE);
 		if (IS_ERR(frd->frd_mr)) {
 			rc = PTR_ERR(frd->frd_mr);
@@ -1475,7 +1491,7 @@ static int kiblnd_create_fmr_pool(struct kib_fmr_poolset *fps,
 	if (dev->ibd_dev_caps & IBLND_DEV_CAPS_FMR_ENABLED)
 		rc = kiblnd_alloc_fmr_pool(fps, fpo);
 	else
-		rc = kiblnd_alloc_freg_pool(fps, fpo);
+		rc = kiblnd_alloc_freg_pool(fps, fpo, dev->ibd_dev_caps);
 	if (rc)
 		goto out_fpo;
 
@@ -2268,6 +2284,8 @@ static int kiblnd_hdev_get_attr(struct kib_hca_dev *hdev)
 	} else if (dev_attr->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) {
 		LCONSOLE_INFO("Using FastReg for registration\n");
 		hdev->ibh_dev->ibd_dev_caps |= IBLND_DEV_CAPS_FASTREG_ENABLED;
+		if (dev_attr->device_cap_flags & IB_DEVICE_SG_GAPS_REG)
+			hdev->ibh_dev->ibd_dev_caps |= IBLND_DEV_CAPS_FASTREG_GAPS_SUPPORT;
 	} else {
 		CERROR("IB device does not support FMRs nor FastRegs, can't register memory: %d\n",
 		       rc);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 9f0a47d..aaf0118 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -94,6 +94,9 @@ struct kib_tunables {
 	int *kib_use_priv_port; /* use privileged port for active connect */
 	int *kib_nscheds;                /* # threads on each CPT */
 	int *kib_wrq_sge;		 /* # sg elements per wrq */
+	bool *kib_use_fastreg_gaps;	 /* enable discontiguous fastreg
+					  * fragment support
+					  */
 };
 
 extern struct kib_tunables  kiblnd_tunables;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 13b19f3..985ccdf 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -111,6 +111,10 @@
 module_param(concurrent_sends, int, 0444);
 MODULE_PARM_DESC(concurrent_sends, "send work-queue sizing");
 
+static bool use_fastreg_gaps;
+module_param(use_fastreg_gaps, bool, 0444);
+MODULE_PARM_DESC(use_fastreg_gaps, "Enable discontiguous fastreg fragment support. Expect performance drop");
+
 #define IBLND_DEFAULT_MAP_ON_DEMAND IBLND_MAX_RDMA_FRAGS
 static int map_on_demand = IBLND_DEFAULT_MAP_ON_DEMAND;
 module_param(map_on_demand, int, 0444);
@@ -165,6 +169,7 @@ struct kib_tunables kiblnd_tunables = {
 	.kib_use_priv_port     = &use_privileged_port,
 	.kib_nscheds		= &nscheds,
 	.kib_wrq_sge		= &wrq_sge,
+	.kib_use_fastreg_gaps	= &use_fastreg_gaps,
 };
 
 static struct lnet_ioctl_config_o2iblnd_tunables default_tunables;
-- 
1.8.3.1
