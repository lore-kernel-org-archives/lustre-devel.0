From: James Simmons <jsimmons@infradead.org>
Date: Sun, 25 Nov 2018 21:48:18 -0500
Subject: [lustre-devel] [PATCH 02/12] lustre: lnd: create enum kib_dev_caps
In-Reply-To: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1543200508-6838-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Cleanup IBLND_DEV_CAPS_* by creating enum kib_dev_caps and using
the BIT() macros.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/33409
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c |  5 +++--
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h | 12 +++++++-----
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index ecdf4de..281004a 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -656,7 +656,7 @@ static unsigned int kiblnd_send_wrs(struct kib_conn *conn)
 	 * One WR for the LNet message
 	 * And ibc_max_frags for the transfer WRs
 	 */
-	u32 dev_caps = conn->ibc_hdev->ibh_dev->ibd_dev_caps;
+	enum kib_dev_caps dev_caps = conn->ibc_hdev->ibh_dev->ibd_dev_caps;
 	unsigned int ret = 1 + conn->ibc_max_frags;
 
 	/* FastReg needs two extra WRs for map and invalidate */
@@ -1441,7 +1441,8 @@ static int kiblnd_alloc_fmr_pool(struct kib_fmr_poolset *fps, struct kib_fmr_poo
 }
 
 static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps,
-				  struct kib_fmr_pool *fpo, u32 dev_caps)
+				  struct kib_fmr_pool *fpo,
+				  enum kib_dev_caps dev_caps)
 {
 	struct kib_fast_reg_descriptor *frd;
 	int i, rc;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 7f81fe2..0994fae 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -73,10 +73,6 @@
 #define IBLND_N_SCHED			2
 #define IBLND_N_SCHED_HIGH		4
 
-#define IBLND_DEV_CAPS_FASTREG_ENABLED		0x1
-#define IBLND_DEV_CAPS_FASTREG_GAPS_SUPPORT	0x2
-#define IBLND_DEV_CAPS_FMR_ENABLED		0x4
-
 struct kib_tunables {
 	int *kib_dev_failover;           /* HCA failover */
 	unsigned int *kib_service;       /* IB service number */
@@ -152,6 +148,12 @@ struct kib_tunables {
 #define KIB_IFNAME_SIZE	      256
 #endif
 
+enum kib_dev_caps {
+	IBLND_DEV_CAPS_FASTREG_ENABLED		= BIT(0),
+	IBLND_DEV_CAPS_FASTREG_GAPS_SUPPORT	= BIT(1),
+	IBLND_DEV_CAPS_FMR_ENABLED		= BIT(2),
+};
+
 struct kib_dev {
 	struct list_head   ibd_list;            /* chain on kib_devs */
 	struct list_head   ibd_fail_list;       /* chain on kib_failed_devs */
@@ -167,7 +169,7 @@ struct kib_dev {
 	unsigned int ibd_can_failover; /* IPoIB interface is a bonding master */
 	struct list_head   ibd_nets;
 	struct kib_hca_dev *ibd_hdev;
-	u32			ibd_dev_caps;
+	enum kib_dev_caps	ibd_dev_caps;
 };
 
 struct kib_hca_dev {
-- 
1.8.3.1
