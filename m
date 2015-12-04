From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri,  4 Dec 2015 18:23:08 -0500
Subject: [lustre-devel] [PATCH] staging/lustre: remove IOC_LIBCFS_PING_TEST
	ioctl
Message-ID: <1449271388-3546416-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <jsimmons@infradead.org>

The ioctl IOC_LIBCFS_PING_TEST has not been used in
ages. The recent nidstring changes which moved all
the nidstring operations from libcfs to the LNet
layer but this ioctl code was still using an
nidstring operation that was causing a circular
dependency loop between libcfs and LNet.

Signed-off-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
Would be great to have this accepted to fix the ugly
circular dependency error Lustre is still causing in the Linus'
tree when enabled.

 .../staging/lustre/include/linux/libcfs/libcfs_ioctl.h  |  1 -
 drivers/staging/lustre/lustre/libcfs/module.c           | 17 -----------------
 2 files changed, 18 deletions(-)

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
index 07a6859..e7c2b26 100644
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
2.1.0
