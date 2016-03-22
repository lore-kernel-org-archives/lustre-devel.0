From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:04:02 -0400
Subject: [lustre-devel] [PATCH 15/29] staging: lustre: libcfs: move
	libcfs_ioctl_handler stuff to libcfs.h
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <uja.ornl@gmail.com>

From: John L. Hammond <john.hammond@intel.com>

Move all the libcfs_ioctl_handler code from libcfs_ioctl.h to
libcfs.h. The header libcfs_ioctl.h is a uapi header so their
is no reason to keep kernel internals in that header.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/14180
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |   14 ++++++++++++++
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |   13 -------------
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 40af75c..0ce52de 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -119,6 +119,20 @@ void cfs_get_random_bytes(void *buf, int size);
 #include "libcfs_fail.h"
 #include "libcfs_crypto.h"
 
+struct libcfs_ioctl_handler {
+	struct list_head item;
+	int (*handle_ioctl)(unsigned int cmd, struct libcfs_ioctl_hdr *hdr);
+};
+
+#define DECLARE_IOCTL_HANDLER(ident, func)			\
+	struct libcfs_ioctl_handler ident = {			\
+		.item		= LIST_HEAD_INIT(ident.item),	\
+		.handle_ioctl	= func				\
+	}
+
+int libcfs_register_ioctl(struct libcfs_ioctl_handler *hand);
+int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand);
+
 /* container_of depends on "likely" which is defined in libcfs_private.h */
 static inline void *__container_of(void *ptr, unsigned long shift)
 {
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index 01bf8d6..d167d2e 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -91,17 +91,6 @@ do {						    \
 	data.ioc_len = sizeof(data);		    \
 } while (0)
 
-struct libcfs_ioctl_handler {
-	struct list_head item;
-	int (*handle_ioctl)(unsigned int cmd, struct libcfs_ioctl_hdr *hdr);
-};
-
-#define DECLARE_IOCTL_HANDLER(ident, func)		      \
-	struct libcfs_ioctl_handler ident = {		   \
-		/* .item = */ LIST_HEAD_INIT(ident.item),   \
-		/* .handle_ioctl = */ func		      \
-	}
-
 /* FIXME check conflict with lustre_lib.h */
 #define LIBCFS_IOC_DEBUG_MASK	     _IOWR('f', 250, long)
 
@@ -223,8 +212,6 @@ static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
 	return 0;
 }
 
-int libcfs_register_ioctl(struct libcfs_ioctl_handler *hand);
-int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand);
 int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 			 const struct libcfs_ioctl_hdr __user *uparam);
 int libcfs_ioctl_popdata(void __user *arg, void *buf, int size);
-- 
1.7.1
