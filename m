From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:41 -0500
Subject: [lustre-devel] [PATCH 473/622] lnet: o2iblnd: remove some unused
 fields.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-474-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

Fields kib_min_reconnect_interval kib_max_reconnect_interval kib_ntx
are never used or set.

ibh_mr_shift is set but never used;
rx_status is used (in a debug message) but never set.

Remove them all.

We could possibly remove ibh_mr_size too. It is only used
for an error message.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 68c04b8fdd5d ("LU-6142 o2iblnd: remove some unused fields.")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35891
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 7 +------
 net/lnet/klnds/o2iblnd/o2iblnd.h | 5 -----
 2 files changed, 1 insertion(+), 11 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index f3176e1..278823f 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2303,7 +2303,6 @@ static int kiblnd_net_init_pools(struct kib_net *net, struct lnet_ni *ni,
 static int kiblnd_hdev_get_attr(struct kib_hca_dev *hdev)
 {
 	struct ib_device_attr *dev_attr = &hdev->ibh_ibdev->attrs;
-	int rc = 0;
 
 	/*
 	 * It's safe to assume a HCA can handle a page size
@@ -2326,15 +2325,11 @@ static int kiblnd_hdev_get_attr(struct kib_hca_dev *hdev)
 			hdev->ibh_dev->ibd_dev_caps |= IBLND_DEV_CAPS_FASTREG_GAPS_SUPPORT;
 	} else {
 		CERROR("IB device does not support FMRs nor FastRegs, can't register memory: %d\n",
-		       rc);
+		       -ENXIO);
 		return -ENXIO;
 	}
 
 	hdev->ibh_mr_size = dev_attr->max_mr_size;
-	if (hdev->ibh_mr_size == ~0ULL) {
-		hdev->ibh_mr_shift = 64;
-		return 0;
-	}
 
 	CERROR("Invalid mr size: %#llx\n", hdev->ibh_mr_size);
 	return -EINVAL;
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 1285ab1..2f2337a 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -76,12 +76,9 @@
 struct kib_tunables {
 	int *kib_dev_failover;		/* HCA failover */
 	unsigned int *kib_service;	/* IB service number */
-	int *kib_min_reconnect_interval; /* first failed connection retry... */
-	int *kib_max_reconnect_interval; /* exponentially increasing to this */
 	int *kib_cksum;			/* checksum struct kib_msg? */
 	int *kib_timeout;		/* comms timeout (seconds) */
 	int *kib_keepalive;		/* keepalive timeout (seconds) */
-	int *kib_ntx;			/* # tx descs */
 	char **kib_default_ipif;	/* default IPoIB interface */
 	int *kib_retry_count;
 	int *kib_rnr_retry_count;
@@ -178,7 +175,6 @@ struct kib_hca_dev {
 	int			ibh_page_shift;	/* page shift of current HCA */
 	int			ibh_page_size;	/* page size of current HCA */
 	u64			ibh_page_mask;	/* page mask of current HCA */
-	int			ibh_mr_shift;	/* bits shift of max MR size */
 	u64			ibh_mr_size;	/* size of MR */
 	struct ib_pd		*ibh_pd;	/* PD */
 	struct kib_dev		*ibh_dev;	/* owner */
@@ -492,7 +488,6 @@ struct kib_rx {					/* receive message */
 	struct list_head	rx_list;	/* queue for attention */
 	struct kib_conn        *rx_conn;	/* owning conn */
 	int			rx_nob;		/* # bytes received (-1 while posted) */
-	enum ib_wc_status	rx_status;	/* completion status */
 	struct kib_msg	       *rx_msg;		/* message buffer (host vaddr) */
 	u64			rx_msgaddr;	/* message buffer (I/O addr) */
 	DEFINE_DMA_UNMAP_ADDR(rx_msgunmap);	/* for dma_unmap_single() */
-- 
1.8.3.1
