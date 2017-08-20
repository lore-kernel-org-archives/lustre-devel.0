From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:58 -0400
Subject: [lustre-devel] [PATCH 64/64 v2] staging: lustre: lnet: cleanup
	paths for all LNet headers
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-65-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in all the lnet header files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h           |  2 +-
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h      | 14 +++++++-------
 drivers/staging/lustre/include/linux/lnet/lib-types.h     |  4 ++--
 drivers/staging/lustre/include/linux/lnet/socklnd.h       |  4 ++--
 drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h |  4 ++--
 drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h  |  2 +-
 drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h   |  2 +-
 7 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index 01ae62e..9c37f3e 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -44,7 +44,7 @@
  * @{
  */
 
-#include "../../uapi/linux/lnet/lnet-types.h"
+#include <uapi/linux/lnet/lnet-types.h>
 
 /** \defgroup lnet_init_fini Initialization and cleanup
  * The LNet must be properly initialized before any LNet calls can be made.
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index bc55d57..e0968ab 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -35,13 +35,13 @@
 #ifndef __LNET_LIB_LNET_H__
 #define __LNET_LIB_LNET_H__
 
-#include "../libcfs/libcfs.h"
-#include "api.h"
-#include "lib-types.h"
-#include "../../uapi/linux/lnet/lnet-dlc.h"
-#include "../../uapi/linux/lnet/lnet-types.h"
-#include "../../uapi/linux/lnet/lnetctl.h"
-#include "../../uapi/linux/lnet/nidstr.h"
+#include <linux/libcfs/libcfs.h>
+#include <linux/lnet/api.h>
+#include <linux/lnet/lib-types.h>
+#include <uapi/linux/lnet/lnet-dlc.h>
+#include <uapi/linux/lnet/lnet-types.h>
+#include <uapi/linux/lnet/lnetctl.h>
+#include <uapi/linux/lnet/nidstr.h>
 
 extern struct lnet the_lnet;	/* THE network */
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 94d3a53..eea3b8e 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -40,8 +40,8 @@
 #include <linux/types.h>
 #include <linux/completion.h>
 
-#include "../../uapi/linux/lnet/lnet-types.h"
-#include "../../uapi/linux/lnet/lnetctl.h"
+#include <uapi/linux/lnet/lnet-types.h>
+#include <uapi/linux/lnet/lnetctl.h>
 
 /* Max payload size */
 #define LNET_MAX_PAYLOAD      CONFIG_LNET_MAX_PAYLOAD
diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index c24fe45..553fb64 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -34,8 +34,8 @@
 #ifndef __LNET_LNET_SOCKLND_H__
 #define __LNET_LNET_SOCKLND_H__
 
-#include "../../uapi/linux/lnet/lnet-types.h"
-#include "../../uapi/linux/lnet/socklnd.h"
+#include <uapi/linux/lnet/lnet-types.h>
+#include <uapi/linux/lnet/socklnd.h>
 
 struct ksock_hello_msg {
 	__u32		kshm_magic;	/* magic number of socklnd message */
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index a3821d9..e45d828 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -29,8 +29,8 @@
 #ifndef LNET_DLC_H
 #define LNET_DLC_H
 
-#include "libcfs_ioctl.h"
-#include "lnet-types.h"
+#include <uapi/linux/lnet/libcfs_ioctl.h>
+#include <uapi/linux/lnet/lnet-types.h>
 
 #define MAX_NUM_SHOW_ENTRIES	32
 #define LNET_MAX_STR_LEN	128
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
index f7ffc53..d9da625 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
@@ -15,7 +15,7 @@
 #ifndef _LNETCTL_H_
 #define _LNETCTL_H_
 
-#include "lnet-types.h"
+#include <uapi/linux/lnet/lnet-types.h>
 
 /** \addtogroup lnet_fault_simulation
  * @{
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h b/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
index d153c97..882074e 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
@@ -28,7 +28,7 @@
 #ifndef _LNET_NIDSTRINGS_H
 #define _LNET_NIDSTRINGS_H
 
-#include "lnet-types.h"
+#include <uapi/linux/lnet/lnet-types.h>
 
 /**
  *  Lustre Network Driver types.
-- 
1.8.3.1
