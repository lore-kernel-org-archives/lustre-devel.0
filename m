From: NeilBrown <neilb@suse.com>
Date: Mon, 16 Apr 2018 10:42:37 +1000
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: move stack-check macros
 to libcfs_debug.h
In-Reply-To: <152383910760.23409.2327082725637657049.stgit@noble>
References: <152383910760.23409.2327082725637657049.stgit@noble>
Message-ID: <152383935730.23409.6748888065027051683.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

CDEBUG_STACK() and CHECK_STACK() are macros to help with
debugging, so move them from
   drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
to
   drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h

This seems a more fitting location, and is a step towards
removing linux/libcfs.h and simplifying the include file structure.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_debug.h     |   32 ++++++++++++++++++++
 .../lustre/include/linux/libcfs/linux/libcfs.h     |   31 -------------------
 2 files changed, 32 insertions(+), 31 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
index 9290a19429e7..0dc7b91efe7c 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
@@ -62,6 +62,38 @@ int libcfs_debug_str2mask(int *mask, const char *str, int is_subsys);
 extern unsigned int libcfs_catastrophe;
 extern unsigned int libcfs_panic_on_lbug;
 
+/* Enable debug-checks on stack size - except on x86_64 */
+#if !defined(__x86_64__)
+# ifdef __ia64__
+#  define CDEBUG_STACK() (THREAD_SIZE -				 \
+			  ((unsigned long)__builtin_dwarf_cfa() &       \
+			   (THREAD_SIZE - 1)))
+# else
+#  define CDEBUG_STACK() (THREAD_SIZE -				 \
+			  ((unsigned long)__builtin_frame_address(0) &  \
+			   (THREAD_SIZE - 1)))
+# endif /* __ia64__ */
+
+#define __CHECK_STACK(msgdata, mask, cdls)			      \
+do {								    \
+	if (unlikely(CDEBUG_STACK() > libcfs_stack)) {		  \
+		LIBCFS_DEBUG_MSG_DATA_INIT(msgdata, D_WARNING, NULL);   \
+		libcfs_stack = CDEBUG_STACK();			  \
+		libcfs_debug_msg(msgdata,			       \
+				 "maximum lustre stack %lu\n",	  \
+				 CDEBUG_STACK());		       \
+		(msgdata)->msg_mask = mask;			     \
+		(msgdata)->msg_cdls = cdls;			     \
+		dump_stack();					   \
+	      /*panic("LBUG");*/					\
+	}							       \
+} while (0)
+#define CFS_CHECK_STACK(msgdata, mask, cdls)  __CHECK_STACK(msgdata, mask, cdls)
+#else /* __x86_64__ */
+#define CFS_CHECK_STACK(msgdata, mask, cdls) do {} while (0)
+#define CDEBUG_STACK() (0L)
+#endif /* __x86_64__ */
+
 #ifndef DEBUG_SUBSYSTEM
 # define DEBUG_SUBSYSTEM S_UNDEFINED
 #endif
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
index 07d3cb2217d1..83aec9c7698f 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
@@ -80,35 +80,4 @@
 #include <stdarg.h>
 #include "linux-cpu.h"
 
-#if !defined(__x86_64__)
-# ifdef __ia64__
-#  define CDEBUG_STACK() (THREAD_SIZE -				 \
-			  ((unsigned long)__builtin_dwarf_cfa() &       \
-			   (THREAD_SIZE - 1)))
-# else
-#  define CDEBUG_STACK() (THREAD_SIZE -				 \
-			  ((unsigned long)__builtin_frame_address(0) &  \
-			   (THREAD_SIZE - 1)))
-# endif /* __ia64__ */
-
-#define __CHECK_STACK(msgdata, mask, cdls)			      \
-do {								    \
-	if (unlikely(CDEBUG_STACK() > libcfs_stack)) {		  \
-		LIBCFS_DEBUG_MSG_DATA_INIT(msgdata, D_WARNING, NULL);   \
-		libcfs_stack = CDEBUG_STACK();			  \
-		libcfs_debug_msg(msgdata,			       \
-				 "maximum lustre stack %lu\n",	  \
-				 CDEBUG_STACK());		       \
-		(msgdata)->msg_mask = mask;			     \
-		(msgdata)->msg_cdls = cdls;			     \
-		dump_stack();					   \
-	      /*panic("LBUG");*/					\
-	}							       \
-} while (0)
-#define CFS_CHECK_STACK(msgdata, mask, cdls)  __CHECK_STACK(msgdata, mask, cdls)
-#else /* __x86_64__ */
-#define CFS_CHECK_STACK(msgdata, mask, cdls) do {} while (0)
-#define CDEBUG_STACK() (0L)
-#endif /* __x86_64__ */
-
 #endif /* _LINUX_LIBCFS_H */
