From: y at ccs.ornl.gov <y@ccs.ornl.gov>
Date: Fri,  6 Nov 2015 21:08:03 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: remove IOC_LIBCFS_PING_TEST
	ioctl
Message-ID: <1446862083-23815-1-git-send-email-y>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

The ioctl IOC_LIBCFS_PING_TEST has not been used in
ages. The recent nidstring changes which moved all
the nidstring operations from libcfs to the LNet
layer but this ioctl code was still using an
nidstring operation that was causing an circular
dependency loop between libcfs and LNet.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |    1 -
 drivers/staging/lustre/lustre/libcfs/module.c      |   17 -----------------
 2 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index f5d741f..485ab26 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -110,7 +110,6 @@ struct libcfs_ioctl_handler {
 #define IOC_LIBCFS_CLEAR_DEBUG	     _IOWR('e', 31, long)
 #define IOC_LIBCFS_MARK_DEBUG	      _IOWR('e', 32, long)
 #define IOC_LIBCFS_MEMHOG		  _IOWR('e', 36, long)
-#define IOC_LIBCFS_PING_TEST	       _IOWR('e', 37, long)
 /* lnet ioctls */
 #define IOC_LIBCFS_GET_NI		  _IOWR('e', 50, long)
 #define IOC_LIBCFS_FAIL_NID		_IOWR('e', 51, long)
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 50e8fd2..5e22820 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -274,23 +274,6 @@ static int libcfs_ioctl_int(struct cfs_psdev_file *pfile, unsigned long cmd,
 		}
 		break;
 
-	case IOC_LIBCFS_PING_TEST: {
-		extern void (kping_client)(struct libcfs_ioctl_data *);
-		void (*ping)(struct libcfs_ioctl_data *);
-
-		CDEBUG(D_IOCTL, "doing %d pings to nid %s (%s)\n",
-		       data->ioc_count, libcfs_nid2str(data->ioc_nid),
-		       libcfs_nid2str(data->ioc_nid));
-		ping = symbol_get(kping_client);
-		if (!ping)
-			CERROR("symbol_get failed\n");
-		else {
-			ping(data);
-			symbol_put(kping_client);
-		}
-		return 0;
-	}
-
 	default: {
 		struct libcfs_ioctl_handler *hand;
 
-- 
1.7.1
