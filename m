From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:36:49 -0400
Subject: [lustre-devel] [PATCH 04/18] staging: lustre: libcfs: create array
	of debug names
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Instead of a using a growing case statement to handle
more debugging options create a array to map debug
flags to string names.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3647
Reviewed-on: http://review.whamcloud.com/7243
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: jacques-Charles Lafoucriere <jacques-charles.lafoucriere@cea.fr>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_debug.h     |   13 ++
 drivers/staging/lustre/lnet/libcfs/debug.c         |  126 ++------------------
 2 files changed, 23 insertions(+), 116 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
index 7472a31..5e60c6f 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
@@ -118,6 +118,12 @@ struct ptldebug_header {
 #define S_FID		0x40000000 /* b_new_cmd */
 #define S_FLD		0x80000000 /* b_new_cmd */
 
+#define LIBCFS_DEBUG_SUBSYS_NAMES {					\
+	"undefined", "mdc", "mds", "osc", "ost", "class", "log",	\
+	"llite", "rpc", "mgmt", "lnet", "lnd", "pinger", "filter", "",	\
+	"echo", "ldlm", "lov", "lquota", "osd", "lfsck", "", "", "lmv",	\
+	"", "sec", "gss", "", "mgc", "mgs", "fid", "fld", NULL }
+
 /* Debugging masks (32 bits, non-overlapping) */
 #define D_TRACE		0x00000001 /* ENTRY/EXIT markers */
 #define D_INODE		0x00000002
@@ -151,6 +157,13 @@ struct ptldebug_header {
 
 #define D_HSM	 D_TRACE
 
+#define LIBCFS_DEBUG_MASKS_NAMES {					\
+	"trace", "inode", "super", "ext2", "malloc", "cache", "info",	\
+	"ioctl", "neterror", "net", "warning", "buffs", "other",	\
+	"dentry", "nettrace", "page", "dlmtrace", "error", "emerg",	\
+	"ha", "rpctrace", "vfstrace", "reada", "mmap", "config",	\
+	"console", "quota", "sec", "lfsck", "hsm", NULL }
+
 #define D_CANTMASK   (D_ERROR | D_EMERG | D_WARNING | D_CONSOLE)
 
 #ifndef DEBUG_SUBSYSTEM
diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index c90e510..4753c32 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -232,130 +232,24 @@ int libcfs_panic_in_progress;
 static const char *
 libcfs_debug_subsys2str(int subsys)
 {
-	switch (1 << subsys) {
-	default:
+	static const char *libcfs_debug_subsystems[] = LIBCFS_DEBUG_SUBSYS_NAMES;
+
+	if (subsys >= ARRAY_SIZE(libcfs_debug_subsystems))
 		return NULL;
-	case S_UNDEFINED:
-		return "undefined";
-	case S_MDC:
-		return "mdc";
-	case S_MDS:
-		return "mds";
-	case S_OSC:
-		return "osc";
-	case S_OST:
-		return "ost";
-	case S_CLASS:
-		return "class";
-	case S_LOG:
-		return "log";
-	case S_LLITE:
-		return "llite";
-	case S_RPC:
-		return "rpc";
-	case S_LNET:
-		return "lnet";
-	case S_LND:
-		return "lnd";
-	case S_PINGER:
-		return "pinger";
-	case S_FILTER:
-		return "filter";
-	case S_ECHO:
-		return "echo";
-	case S_LDLM:
-		return "ldlm";
-	case S_LOV:
-		return "lov";
-	case S_LQUOTA:
-		return "lquota";
-	case S_OSD:
-		return "osd";
-	case S_LFSCK:
-		return "lfsck";
-	case S_LMV:
-		return "lmv";
-	case S_SEC:
-		return "sec";
-	case S_GSS:
-		return "gss";
-	case S_MGC:
-		return "mgc";
-	case S_MGS:
-		return "mgs";
-	case S_FID:
-		return "fid";
-	case S_FLD:
-		return "fld";
-	}
+
+	return libcfs_debug_subsystems[subsys];
 }
 
 /* libcfs_debug_token2mask() expects the returned string in lower-case */
 static const char *
 libcfs_debug_dbg2str(int debug)
 {
-	switch (1 << debug) {
-	default:
+	static const char *libcfs_debug_masks[] = LIBCFS_DEBUG_MASKS_NAMES;
+
+	if (debug >= ARRAY_SIZE(libcfs_debug_masks))
 		return NULL;
-	case D_TRACE:
-		return "trace";
-	case D_INODE:
-		return "inode";
-	case D_SUPER:
-		return "super";
-	case D_EXT2:
-		return "ext2";
-	case D_MALLOC:
-		return "malloc";
-	case D_CACHE:
-		return "cache";
-	case D_INFO:
-		return "info";
-	case D_IOCTL:
-		return "ioctl";
-	case D_NETERROR:
-		return "neterror";
-	case D_NET:
-		return "net";
-	case D_WARNING:
-		return "warning";
-	case D_BUFFS:
-		return "buffs";
-	case D_OTHER:
-		return "other";
-	case D_DENTRY:
-		return "dentry";
-	case D_NETTRACE:
-		return "nettrace";
-	case D_PAGE:
-		return "page";
-	case D_DLMTRACE:
-		return "dlmtrace";
-	case D_ERROR:
-		return "error";
-	case D_EMERG:
-		return "emerg";
-	case D_HA:
-		return "ha";
-	case D_RPCTRACE:
-		return "rpctrace";
-	case D_VFSTRACE:
-		return "vfstrace";
-	case D_READA:
-		return "reada";
-	case D_MMAP:
-		return "mmap";
-	case D_CONFIG:
-		return "config";
-	case D_CONSOLE:
-		return "console";
-	case D_QUOTA:
-		return "quota";
-	case D_SEC:
-		return "sec";
-	case D_LFSCK:
-		return "lfsck";
-	}
+
+	return libcfs_debug_masks[debug];
 }
 
 int
-- 
1.7.1
