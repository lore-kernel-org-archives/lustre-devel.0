From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:04:11 -0400
Subject: [lustre-devel] [PATCH 24/29] staging: lustre: libcfs: move function
	declarations from libcfs_ioctl.h
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Move the function declartions that are used only by
kernel space to libcfs.h This makes libcfs_ioctl.h
a offical uapi header now.
Move large inline functions out of libcfs_ioctl.h to
the source file linux-module.c belonging to libcfs.
This code is only used by the core of libcfs and such
inline functions don't belong in a uapi header file.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/17643
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    3 +++
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |    4 ----
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 1cd1879..6a8e0d0 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -112,6 +112,9 @@ struct libcfs_ioctl_handler {
 int libcfs_register_ioctl(struct libcfs_ioctl_handler *hand);
 int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand);
 
+int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
+			 const struct libcfs_ioctl_hdr __user *uparam);
+int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data);
 int libcfs_ioctl(unsigned long cmd, void *arg);
 
 /* container_of depends on "likely" which is defined in libcfs_private.h */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index 3af13e4..c379d29 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -138,8 +138,4 @@ struct libcfs_debug_ioctl_data {
 #define IOC_LIBCFS_GET_LNET_STATS	_IOWR(IOC_LIBCFS_TYPE, 91, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_MAX_NR		91
 
-int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
-			 const struct libcfs_ioctl_hdr __user *uparam);
-int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data);
-
 #endif /* __LIBCFS_IOCTL_H__ */
-- 
1.7.1
