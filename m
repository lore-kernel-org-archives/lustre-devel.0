From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:55 -0500
Subject: [lustre-devel] [PATCH 247/622] lustre: misc: remove
 LIBCFS_IOC_DEBUG_MASK ioctl
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-248-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Remove the LIBCFS_IOC_DEBUG_MASK ioctl, since the debug and subsystem
mask can be modified via sysfs for a long time, and tools have not
used this ioctl since 2.6.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6202
Lustre-commit: 70f932c7bfc5 ("LU-6202 misc: remove LIBCFS_IOC_DEBUG_MASK ioctl")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33692
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/class_obd.c           | 9 ---------
 include/uapi/linux/lnet/libcfs_ioctl.h   | 8 --------
 include/uapi/linux/lustre/lustre_ioctl.h | 2 +-
 3 files changed, 1 insertion(+), 18 deletions(-)

diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index 373a8d2..609b4cc 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -274,18 +274,9 @@ int obd_ioctl_getdata(struct obd_ioctl_data **datap, int *len, void __user *arg)
 int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 {
 	struct obd_ioctl_data *data;
-	struct libcfs_debug_ioctl_data *debug_data;
 	struct obd_device *obd = NULL;
 	int err = 0, len = 0;
 
-	/* only for debugging */
-	if (cmd == LIBCFS_IOC_DEBUG_MASK) {
-		debug_data = (struct libcfs_debug_ioctl_data *)arg;
-		libcfs_subsystem_debug = debug_data->subs;
-		libcfs_debug = debug_data->debug;
-		return 0;
-	}
-
 	CDEBUG(D_IOCTL, "cmd = %x\n", cmd);
 	if (obd_ioctl_getdata(&data, &len, (void __user *)arg)) {
 		CERROR("OBD ioctl: data error\n");
diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index dfb73f7..455ed78 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -77,14 +77,6 @@ struct libcfs_ioctl_data {
 	char ioc_bulk[0];
 };
 
-struct libcfs_debug_ioctl_data {
-	struct libcfs_ioctl_hdr hdr;
-	unsigned int subs;
-	unsigned int debug;
-};
-
-/* 'f' ioctls are defined in lustre_ioctl.h and lustre_user.h except for: */
-#define LIBCFS_IOC_DEBUG_MASK		_IOWR('f', 250, long)
 #define IOCTL_LIBCFS_TYPE		long
 
 #define IOC_LIBCFS_TYPE			('e')
diff --git a/include/uapi/linux/lustre/lustre_ioctl.h b/include/uapi/linux/lustre/lustre_ioctl.h
index 30eb120..b067cc6 100644
--- a/include/uapi/linux/lustre/lustre_ioctl.h
+++ b/include/uapi/linux/lustre/lustre_ioctl.h
@@ -222,7 +222,7 @@ static inline __u32 obd_ioctl_packlen(struct obd_ioctl_data *data)
 #define OBD_IOC_STOP_LFSCK	_IOW('f', 231, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_QUERY_LFSCK	_IOR('f', 232, struct obd_ioctl_data)
 /*	lustre/lustre_user.h	240-249 */
-/*	LIBCFS_IOC_DEBUG_MASK	250 */
+/* was LIBCFS_IOC_DEBUG_MASK   _IOWR('f', 250, long) until 2.11 */
 
 #define IOC_OSC_SET_ACTIVE	_IOWR('h', 21, void *)
 
-- 
1.8.3.1
