From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:47:55 -0400
Subject: [lustre-devel] [PATCH 03/25] lustre: lnet: remove debug ioctl
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf.weber@hpe.com>

Remove a debug ioctl that was added to allow for debug
messages from user space. However, the code is currently
not being used.

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Signed-off-by: Olaf Weber <olaf.weber@hpe.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9119
Reviewed-on: https://review.whamcloud.com/26688
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lnet/libcfs_ioctl.h  |  3 +--
 .../lustre/include/uapi/linux/lnet/lnet-dlc.h      | 22 --------------------
 drivers/staging/lustre/lnet/lnet/api-ni.c          | 24 ----------------------
 3 files changed, 1 insertion(+), 48 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
index a231f6d..2a9beed 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -144,7 +144,6 @@ struct libcfs_debug_ioctl_data {
 #define IOC_LIBCFS_GET_LOCAL_NI		_IOWR(IOC_LIBCFS_TYPE, 97, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_SET_NUMA_RANGE	_IOWR(IOC_LIBCFS_TYPE, 98, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_NUMA_RANGE	_IOWR(IOC_LIBCFS_TYPE, 99, IOCTL_CONFIG_SIZE)
-#define IOC_LIBCFS_DBG			_IOWR(IOC_LIBCFS_TYPE, 100, IOCTL_CONFIG_SIZE)
-#define IOC_LIBCFS_MAX_NR		100
+#define IOC_LIBCFS_MAX_NR		99
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index d1e2911..2594642 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -94,10 +94,6 @@ struct lnet_ioctl_net_config {
 /* # different router buffer pools */
 #define LNET_NRBPOOLS		(LNET_LARGE_BUF_IDX + 1)
 
-enum lnet_dbg_task {
-	LNET_DBG_INCR_DLC_SEQ = 0
-};
-
 struct lnet_ioctl_pool_cfg {
 	struct {
 		__u32 pl_npages;
@@ -196,24 +192,6 @@ struct lnet_ioctl_peer {
 	} pr_lnd_u;
 };
 
-struct lnet_dbg_task_info {
-	/*
-	 * TODO: a union can be added if the task requires more
-	 * information from user space to be carried out in kernel space.
-	 */
-};
-
-/*
- * This structure is intended to allow execution of debugging tasks. This
- * is not intended to be backwards compatible. Extra tasks can be added in
- * the future
- */
-struct lnet_ioctl_dbg {
-	struct libcfs_ioctl_hdr dbg_hdr;
-	enum lnet_dbg_task dbg_task;
-	char dbg_bulk[0];
-};
-
 struct lnet_ioctl_peer_cfg {
 	struct libcfs_ioctl_hdr prcfg_hdr;
 	lnet_nid_t prcfg_prim_nid;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 9a09927..43e8db1 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1866,17 +1866,6 @@ void lnet_lib_exit(void)
 }
 EXPORT_SYMBOL(LNetNIFini);
 
-static int lnet_handle_dbg_task(struct lnet_ioctl_dbg *dbg,
-				struct lnet_dbg_task_info *dbg_info)
-{
-	switch (dbg->dbg_task) {
-	case LNET_DBG_INCR_DLC_SEQ:
-		lnet_incr_dlc_seq();
-	}
-
-	return 0;
-}
-
 /**
  * Grabs the ni data from the ni structure and fills the out
  * parameters
@@ -2845,19 +2834,6 @@ u32 lnet_get_dlc_seq_locked(void)
 		return 0;
 	}
 
-	case IOC_LIBCFS_DBG: {
-		struct lnet_ioctl_dbg *dbg = arg;
-		struct lnet_dbg_task_info *dbg_info;
-		size_t total = sizeof(*dbg) + sizeof(*dbg_info);
-
-		if (dbg->dbg_hdr.ioc_len < total)
-			return -EINVAL;
-
-		dbg_info = (struct lnet_dbg_task_info *)dbg->dbg_bulk;
-
-		return lnet_handle_dbg_task(dbg, dbg_info);
-	}
-
 	default:
 		ni = lnet_net2ni_addref(data->ioc_net);
 		if (!ni)
-- 
1.8.3.1
