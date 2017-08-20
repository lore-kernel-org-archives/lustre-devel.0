From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:57 -0400
Subject: [lustre-devel] [PATCH 63/64 v2] staging: lustre: libcfs: cleanup
	paths for libcfs headers
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-64-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in all the libcfs header files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   | 24 +++++++++++-----------
 .../lustre/include/linux/libcfs/libcfs_debug.h     |  2 +-
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 3a5ebc2..b48e2f0 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -36,18 +36,18 @@
 #include <linux/gfp.h>
 #include <linux/list.h>
 
-#include "../../uapi/linux/lnet/libcfs_ioctl.h"
-#include "linux/libcfs.h"
-#include "libcfs_debug.h"
-#include "libcfs_private.h"
-#include "libcfs_cpu.h"
-#include "libcfs_prim.h"
-#include "libcfs_time.h"
-#include "libcfs_string.h"
-#include "libcfs_workitem.h"
-#include "libcfs_hash.h"
-#include "libcfs_fail.h"
-#include "curproc.h"
+#include <uapi/linux/lnet/libcfs_ioctl.h>
+#include <linux/libcfs/linux/libcfs.h>
+#include <linux/libcfs/libcfs_debug.h>
+#include <linux/libcfs/libcfs_private.h>
+#include <linux/libcfs/libcfs_cpu.h>
+#include <linux/libcfs/libcfs_prim.h>
+#include <linux/libcfs/libcfs_time.h>
+#include <linux/libcfs/libcfs_string.h>
+#include <linux/libcfs/libcfs_workitem.h>
+#include <linux/libcfs/libcfs_hash.h>
+#include <linux/libcfs/libcfs_fail.h>
+#include <linux/libcfs/curproc.h>
 
 #define LIBCFS_VERSION "0.7.0"
 
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
index 91d141d..e7c3741 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
@@ -38,7 +38,7 @@
 #ifndef __LIBCFS_DEBUG_H__
 #define __LIBCFS_DEBUG_H__
 
-#include "../../uapi/linux/lnet/libcfs_debug.h"
+#include <uapi/linux/lnet/libcfs_debug.h>
 
 /*
  *  Debugging
-- 
1.8.3.1
