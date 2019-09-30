From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:20 -0400
Subject: [lustre-devel] [PATCH 001/151] lnet: fix needed headers for lnet
 headers
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The linux kernel now has a sanity check for the global headers,
activated by  CONFIG_HEADER_TEST=y and CONFIG_KERNEL_HEADER_TEST=y.
Some LNet headers are missing a few headers to allow them to build
properly.

Signed-off-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/libcfs/libcfs_fail.h    | 1 +
 include/linux/libcfs/libcfs_private.h | 3 +++
 include/uapi/linux/lnet/lnetst.h      | 2 ++
 3 files changed, 6 insertions(+)

diff --git a/include/linux/libcfs/libcfs_fail.h b/include/linux/libcfs/libcfs_fail.h
index 0e73eef..f52a82a 100644
--- a/include/linux/libcfs/libcfs_fail.h
+++ b/include/linux/libcfs/libcfs_fail.h
@@ -35,6 +35,7 @@
 
 #include <linux/sched.h>
 #include <linux/wait.h>
+#include <linux/libcfs/libcfs_debug.h>
 
 extern unsigned long cfs_fail_loc;
 extern unsigned int cfs_fail_val;
diff --git a/include/linux/libcfs/libcfs_private.h b/include/linux/libcfs/libcfs_private.h
index 515fd63..2e8cff6 100644
--- a/include/linux/libcfs/libcfs_private.h
+++ b/include/linux/libcfs/libcfs_private.h
@@ -39,6 +39,9 @@
 #ifndef __LIBCFS_PRIVATE_H__
 #define __LIBCFS_PRIVATE_H__
 
+#include <linux/sched.h>
+#include <linux/libcfs/libcfs_debug.h>
+
 #ifndef DEBUG_SUBSYSTEM
 # define DEBUG_SUBSYSTEM S_UNDEFINED
 #endif
diff --git a/include/uapi/linux/lnet/lnetst.h b/include/uapi/linux/lnet/lnetst.h
index 27fcd91..449c5e6 100644
--- a/include/uapi/linux/lnet/lnetst.h
+++ b/include/uapi/linux/lnet/lnetst.h
@@ -38,6 +38,8 @@
 #define __LNET_ST_H__
 
 #include <linux/types.h>
+#include <linux/time.h>
+#include <linux/lnet/lnet-types.h>
 
 #define LST_FEAT_NONE		(0)
 #define LST_FEAT_BULK_LEN	(1 << 0)	/* enable variable page size */
-- 
1.8.3.1
