From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:04:12 -0400
Subject: [lustre-devel] [PATCH 25/29] staging: lustre: libcfs: make
	libcfs_ioctl.h readable
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Fix up all thw whitescapes and line up the IOCTL defines
so it is readable.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/17643
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |   57 ++++++++++----------
 1 files changed, 29 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index c379d29..48372c4 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -82,41 +82,42 @@ struct libcfs_debug_ioctl_data {
 	unsigned int debug;
 };
 
-/* FIXME check conflict with lustre_lib.h */
-#define LIBCFS_IOC_DEBUG_MASK	     _IOWR('f', 250, long)
+/* 'f' ioctls are defined in lustre_ioctl.h and lustre_user.h except for: */
+#define LIBCFS_IOC_DEBUG_MASK		   _IOWR('f', 250, long)
+#define IOCTL_LIBCFS_TYPE		   long
 
-#define IOC_LIBCFS_TYPE		   'e'
-#define IOC_LIBCFS_MIN_NR		 30
+#define IOC_LIBCFS_TYPE			   ('e')
+#define IOC_LIBCFS_MIN_NR		   30
 /* libcfs ioctls */
 /* IOC_LIBCFS_PANIC obsolete in 2.8.0, was _IOWR('e', 30, IOCTL_LIBCFS_TYPE) */
-#define IOC_LIBCFS_CLEAR_DEBUG	     _IOWR('e', 31, long)
-#define IOC_LIBCFS_MARK_DEBUG	      _IOWR('e', 32, long)
+#define IOC_LIBCFS_CLEAR_DEBUG		   _IOWR('e', 31, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_MARK_DEBUG		   _IOWR('e', 32, IOCTL_LIBCFS_TYPE)
 /* IOC_LIBCFS_MEMHOG obsolete in 2.8.0, was _IOWR('e', 36, IOCTL_LIBCFS_TYPE) */
 /* lnet ioctls */
-#define IOC_LIBCFS_GET_NI		  _IOWR('e', 50, long)
-#define IOC_LIBCFS_FAIL_NID		_IOWR('e', 51, long)
-#define IOC_LIBCFS_NOTIFY_ROUTER	   _IOWR('e', 55, long)
-#define IOC_LIBCFS_UNCONFIGURE	     _IOWR('e', 56, long)
-/*	#define IOC_LIBCFS_PORTALS_COMPATIBILITY   _IOWR('e', 57, long) */
-#define IOC_LIBCFS_LNET_DIST	       _IOWR('e', 58, long)
-#define IOC_LIBCFS_CONFIGURE	       _IOWR('e', 59, long)
-#define IOC_LIBCFS_TESTPROTOCOMPAT	 _IOWR('e', 60, long)
-#define IOC_LIBCFS_PING		    _IOWR('e', 61, long)
-/*	#define IOC_LIBCFS_DEBUG_PEER	      _IOWR('e', 62, long) */
-#define IOC_LIBCFS_LNETST		  _IOWR('e', 63, long)
-#define	IOC_LIBCFS_LNET_FAULT		_IOWR('e', 64, long)
+#define IOC_LIBCFS_GET_NI		   _IOWR('e', 50, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_FAIL_NID		   _IOWR('e', 51, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_NOTIFY_ROUTER	   _IOWR('e', 55, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_UNCONFIGURE		   _IOWR('e', 56, IOCTL_LIBCFS_TYPE)
+/*	 IOC_LIBCFS_PORTALS_COMPATIBILITY  _IOWR('e', 57, IOCTL_LIBCFS_TYPE) */
+#define IOC_LIBCFS_LNET_DIST		   _IOWR('e', 58, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_CONFIGURE		   _IOWR('e', 59, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_TESTPROTOCOMPAT	   _IOWR('e', 60, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_PING			   _IOWR('e', 61, IOCTL_LIBCFS_TYPE)
+/*	IOC_LIBCFS_DEBUG_PEER		   _IOWR('e', 62, IOCTL_LIBCFS_TYPE) */
+#define IOC_LIBCFS_LNETST		   _IOWR('e', 63, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_LNET_FAULT		   _IOWR('e', 64, IOCTL_LIBCFS_TYPE)
 /* lnd ioctls */
-#define IOC_LIBCFS_REGISTER_MYNID	  _IOWR('e', 70, long)
-#define IOC_LIBCFS_CLOSE_CONNECTION	_IOWR('e', 71, long)
-#define IOC_LIBCFS_PUSH_CONNECTION	 _IOWR('e', 72, long)
-#define IOC_LIBCFS_GET_CONN		_IOWR('e', 73, long)
-#define IOC_LIBCFS_DEL_PEER		_IOWR('e', 74, long)
-#define IOC_LIBCFS_ADD_PEER		_IOWR('e', 75, long)
-#define IOC_LIBCFS_GET_PEER		_IOWR('e', 76, long)
+#define IOC_LIBCFS_REGISTER_MYNID	   _IOWR('e', 70, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_CLOSE_CONNECTION	   _IOWR('e', 71, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_PUSH_CONNECTION	   _IOWR('e', 72, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_GET_CONN		   _IOWR('e', 73, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_DEL_PEER		   _IOWR('e', 74, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_ADD_PEER		   _IOWR('e', 75, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_GET_PEER		   _IOWR('e', 76, IOCTL_LIBCFS_TYPE)
 /* ioctl 77 is free for use */
-#define IOC_LIBCFS_ADD_INTERFACE	   _IOWR('e', 78, long)
-#define IOC_LIBCFS_DEL_INTERFACE	   _IOWR('e', 79, long)
-#define IOC_LIBCFS_GET_INTERFACE	   _IOWR('e', 80, long)
+#define IOC_LIBCFS_ADD_INTERFACE	   _IOWR('e', 78, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_DEL_INTERFACE	   _IOWR('e', 79, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_GET_INTERFACE	   _IOWR('e', 80, IOCTL_LIBCFS_TYPE)
 
 /*
  * DLC Specific IOCTL numbers.
-- 
1.7.1
