From: James Simmons <jsimmons@infradead.org>
Date: Thu, 11 Jun 2015 15:18:10 -0400
Subject: [lustre-devel] [PATCH v4 4/9] staging:lustre: merge
	socklnd_lib-linux.h into socklnd.h
In-Reply-To: <1434050295-10986-1-git-send-email-jsimmons@infradead.org>
References: <1434050295-10986-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1434050295-10986-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: John L. Hammond <john.hammond@intel.com>

Originally socklnd_lib-linux.h contained linux specific
wrappers and defines but since the linux kernel is the
only supported platform now we can merge what little
remains in the header into socklnd.h. This is broken
out of the original patch 12932 that was merged to the
Intel/OpenSFS branch.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/12932
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   39 +++++++++-
 .../lustre/lnet/klnds/socklnd/socklnd_lib-linux.h  |   86 --------------------
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |    4 +-
 3 files changed, 40 insertions(+), 89 deletions(-)
 delete mode 100644 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.h

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 53275f9..7125eb9 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -25,16 +25,40 @@
  *
  */
 
+#ifndef _SOCKLND_SOCKLND_H_
+#define _SOCKLND_SOCKLND_H_
+
 #define DEBUG_PORTAL_ALLOC
 #define DEBUG_SUBSYSTEM S_LND
 
-#include "socklnd_lib-linux.h"
+#include <asm/irq.h>
+#include <linux/crc32.h>
+#include <linux/errno.h>
+#include <linux/if.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/kmod.h>
+#include <linux/list.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/stat.h>
+#include <linux/string.h>
+#include <linux/syscalls.h>
+#include <linux/sysctl.h>
+#include <linux/uio.h>
+#include <linux/unistd.h>
+#include <net/sock.h>
+#include <net/tcp.h>
 
 #include "../../../include/linux/libcfs/libcfs.h"
 #include "../../../include/linux/lnet/lnet.h"
 #include "../../../include/linux/lnet/lib-lnet.h"
 #include "../../../include/linux/lnet/socklnd.h"
 
+/* assume one thread for each connection type */
+#define SOCKNAL_NSCHEDS		3
+#define SOCKNAL_NSCHEDS_HIGH	(SOCKNAL_NSCHEDS << 1)
+
 #define SOCKNAL_PEER_HASH_SIZE  101   /* # peer lists */
 #define SOCKNAL_RESCHED         100   /* # scheduler loops before reschedule */
 #define SOCKNAL_INSANITY_RECONN 5000  /* connd is trying on reconn infinitely */
@@ -459,6 +483,17 @@ extern ksock_proto_t ksocknal_protocol_v3x;
 #define CPU_MASK_NONE   0UL
 #endif
 
+static inline __u32 ksocknal_csum(__u32 crc, unsigned char const *p, size_t len)
+{
+#if 1
+	return crc32_le(crc, p, len);
+#else
+	while (len-- > 0)
+		crc = ((crc + 0x100) & ~0xff) | ((crc + *p++) & 0xff) ;
+	return crc;
+#endif
+}
+
 static inline int
 ksocknal_route_mask(void)
 {
@@ -651,3 +686,5 @@ extern void ksocknal_lib_csum_tx(ksock_tx_t *tx);
 
 extern int ksocknal_lib_memory_pressure(ksock_conn_t *conn);
 extern int ksocknal_lib_bind_thread_to_cpu(int id);
+
+#endif /* _SOCKLND_SOCKLND_H_ */
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.h
deleted file mode 100644
index f556388..0000000
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.h
+++ /dev/null
@@ -1,86 +0,0 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2005, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#define DEBUG_PORTAL_ALLOC
-
-#ifndef __LINUX_SOCKNAL_LIB_H__
-#define __LINUX_SOCKNAL_LIB_H__
-
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/mm.h>
-#include <linux/string.h>
-#include <linux/stat.h>
-#include <linux/errno.h>
-#include <linux/unistd.h>
-#include <net/sock.h>
-#include <net/tcp.h>
-#include <linux/uio.h>
-#include <linux/if.h>
-#include <linux/uaccess.h>
-
-#include <asm/irq.h>
-
-#include <linux/fs.h>
-#include <linux/file.h>
-#include <linux/list.h>
-#include <linux/kmod.h>
-#include <linux/sysctl.h>
-#include <asm/div64.h>
-#include <linux/syscalls.h>
-
-#include "../../../include/linux/libcfs/libcfs.h"
-
-#include <linux/crc32.h>
-static inline __u32 ksocknal_csum(__u32 crc, unsigned char const *p, size_t len)
-{
-#if 1
-	return crc32_le(crc, p, len);
-#else
-	while (len-- > 0)
-		crc = ((crc + 0x100) & ~0xff) | ((crc + *p++) & 0xff) ;
-	return crc;
-#endif
-}
-
-#define SOCKNAL_WSPACE(sk)       sk_stream_wspace(sk)
-#define SOCKNAL_MIN_WSPACE(sk)   sk_stream_min_wspace(sk)
-
-/* assume one thread for each connection type */
-#define SOCKNAL_NSCHEDS		3
-#define SOCKNAL_NSCHEDS_HIGH	(SOCKNAL_NSCHEDS << 1)
-
-#endif
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 2b40a9f..3407061 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -616,8 +616,8 @@ ksocknal_write_space(struct sock *sk)
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
 	conn = sk->sk_user_data;
-	wspace = SOCKNAL_WSPACE(sk);
-	min_wpace = SOCKNAL_MIN_WSPACE(sk);
+	wspace = sk_stream_wspace(sk);
+	min_wpace = sk_stream_min_wspace(sk);
 
 	CDEBUG(D_NET, "sk %p wspace %d low water %d conn %p%s%s%s\n",
 	       sk, wspace, min_wpace, conn,
-- 
1.7.1
