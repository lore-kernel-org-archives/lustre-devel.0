Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CC845C02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:34:13 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWw86qn5z1xGG;
	Fri, 07 Feb 2025 16:30:48 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWvx6FG2z1x3n
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:37 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id F29D288F9DC;
 Fri,  7 Feb 2025 19:30:32 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id E7B47106BE1A; Fri,  7 Feb 2025 19:30:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:11 -0500
Message-ID: <20250208003027.180076-6-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 05/21] lnet: libcfs: move percpt_lock into
 lnet
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

lnet is the only users of percpt_lock - and there are only two such
locks!
So move the code into lnet, as part of deprecating libcfs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9859
Lustre-commit: c4e2563ff3bfa84ab ("LU-9859 libcfs: move percpt_lock into lnet")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50832
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/libcfs/libcfs_cpu.h             | 62 ------------------
 include/linux/lnet/lib-lnet.h                 |  3 +-
 include/linux/lnet/lock.h                     | 64 +++++++++++++++++++
 net/lnet/libcfs/Makefile                      |  2 +-
 net/lnet/lnet/Makefile                        |  9 +--
 .../{libcfs/libcfs_lock.c => lnet/lock.c}     |  5 +-
 6 files changed, 73 insertions(+), 72 deletions(-)
 create mode 100644 include/linux/lnet/lock.h
 rename net/lnet/{libcfs/libcfs_lock.c => lnet/lock.c} (96%)

diff --git a/include/linux/libcfs/libcfs_cpu.h b/include/linux/libcfs/libcfs_cpu.h
index b4f1b5879e73..bd7ea98cb38f 100644
--- a/include/linux/libcfs/libcfs_cpu.h
+++ b/include/linux/libcfs/libcfs_cpu.h
@@ -333,68 +333,6 @@ int cfs_percpt_number(void *vars);
 	for (i = 0; i < cfs_percpt_number(vars) &&	\
 		((var) = (vars)[i]) != NULL; i++)
 
-/*
- * percpu partition lock
- *
- * There are some use-cases like this in Lustre:
- * . each CPU partition has it's own private data which is frequently changed,
- *   and mostly by the local CPU partition.
- * . all CPU partitions share some global data, these data are rarely changed.
- *
- * LNet is typical example.
- * CPU partition lock is designed for this kind of use-cases:
- * . each CPU partition has it's own private lock
- * . change on private data just needs to take the private lock
- * . read on shared data just needs to take _any_ of private locks
- * . change on shared data needs to take _all_ private locks,
- *   which is slow and should be really rare.
- */
-enum {
-	CFS_PERCPT_LOCK_EX	= -1,	/* negative */
-};
-
-struct cfs_percpt_lock {
-	/* cpu-partition-table for this lock */
-	struct cfs_cpt_table	 *pcl_cptab;
-	/* exclusively locked */
-	unsigned int		  pcl_locked;
-	/* private lock table */
-	spinlock_t		**pcl_locks;
-};
-
-/* return number of private locks */
-#define cfs_percpt_lock_num(pcl)	cfs_cpt_number(pcl->pcl_cptab)
-
-/*
- * create a cpu-partition lock based on CPU partition table @cptab,
- * each private lock has extra @psize bytes padding data
- */
-struct cfs_percpt_lock *cfs_percpt_lock_create(struct cfs_cpt_table *cptab,
-					       struct lock_class_key *keys);
-/* destroy a cpu-partition lock */
-void cfs_percpt_lock_free(struct cfs_percpt_lock *pcl);
-
-/* lock private lock @index of @pcl */
-void cfs_percpt_lock(struct cfs_percpt_lock *pcl, int index);
-
-/* unlock private lock @index of @pcl */
-void cfs_percpt_unlock(struct cfs_percpt_lock *pcl, int index);
-
-#define CFS_PERCPT_LOCK_KEYS	256
-
-/* NB: don't allocate keys dynamically, lockdep needs them to be in ".data" */
-#define cfs_percpt_lock_alloc(cptab)					\
-({									\
-	static struct lock_class_key ___keys[CFS_PERCPT_LOCK_KEYS];	\
-	struct cfs_percpt_lock *___lk;					\
-									\
-	if (cfs_cpt_number(cptab) > CFS_PERCPT_LOCK_KEYS)		\
-		___lk = cfs_percpt_lock_create(cptab, NULL);		\
-	else								\
-		___lk = cfs_percpt_lock_create(cptab, ___keys);		\
-	___lk;								\
-})
-
 /**
  * iterate over all CPU partitions in @cptab
  */
diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 84bb3f2966a7..09cf42995f39 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -49,6 +49,8 @@
 #include <uapi/linux/lnet/lnetctl.h>
 #include <uapi/linux/lnet/nidstr.h>
 
+#include "lock.h"
+
 /* LNET has 0xeXXX */
 #define CFS_FAIL_PTLRPC_OST_BULK_CB2	0xe000
 
@@ -1208,7 +1210,6 @@ u32 lnet_sum_stats(struct lnet_element_stats *stats,
 
 void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 			      struct lnet_element_stats *stats);
-
 static inline void
 lnet_set_route_aliveness(struct lnet_route *route, bool alive)
 {
diff --git a/include/linux/lnet/lock.h b/include/linux/lnet/lock.h
new file mode 100644
index 000000000000..e5e431ccf7c0
--- /dev/null
+++ b/include/linux/lnet/lock.h
@@ -0,0 +1,64 @@
+// SPDX-License-Identifier: GPL-2.0
+
+/* This file is part of Lustre, http://www.lustre.org/
+ *
+ * percpu partition lock
+ *
+ * There are some use-cases like this in Lustre:
+ * . each CPU partition has it's own private data which is frequently changed,
+ *   and mostly by the local CPU partition.
+ * . all CPU partitions share some global data, these data are rarely changed.
+ *
+ * LNet is typical example.
+ * CPU partition lock is designed for this kind of use-cases:
+ * . each CPU partition has it's own private lock
+ * . change on private data just needs to take the private lock
+ * . read on shared data just needs to take _any_ of private locks
+ * . change on shared data needs to take _all_ private locks,
+ *   which is slow and should be really rare.
+ */
+
+enum {
+	CFS_PERCPT_LOCK_EX	= -1,	/* negative */
+};
+
+struct cfs_percpt_lock {
+	/* cpu-partition-table for this lock */
+	struct cfs_cpt_table	 *pcl_cptab;
+	/* exclusively locked */
+	unsigned int		  pcl_locked;
+	/* private lock table */
+	spinlock_t		**pcl_locks;
+};
+
+/* return number of private locks */
+#define cfs_percpt_lock_num(pcl)	cfs_cpt_number(pcl->pcl_cptab)
+
+/* create a cpu-partition lock based on CPU partition table \a cptab,
+ * each private lock has extra \a psize bytes padding data
+ */
+struct cfs_percpt_lock *cfs_percpt_lock_create(struct cfs_cpt_table *cptab,
+					       struct lock_class_key *keys);
+/* destroy a cpu-partition lock */
+void cfs_percpt_lock_free(struct cfs_percpt_lock *pcl);
+
+/* lock private lock \a index of \a pcl */
+void cfs_percpt_lock(struct cfs_percpt_lock *pcl, int index);
+
+/* unlock private lock \a index of \a pcl */
+void cfs_percpt_unlock(struct cfs_percpt_lock *pcl, int index);
+
+#define CFS_PERCPT_LOCK_KEYS	256
+
+/* NB: don't allocate keys dynamically, lockdep needs them to be in ".data" */
+#define cfs_percpt_lock_alloc(cptab)					\
+({									\
+	static struct lock_class_key ___keys[CFS_PERCPT_LOCK_KEYS];	\
+	struct cfs_percpt_lock *___lk;					\
+									\
+	if (cfs_cpt_number(cptab) > CFS_PERCPT_LOCK_KEYS)		\
+		___lk = cfs_percpt_lock_create(cptab, NULL);		\
+	else								\
+		___lk = cfs_percpt_lock_create(cptab, ___keys);		\
+	___lk;								\
+})
diff --git a/net/lnet/libcfs/Makefile b/net/lnet/libcfs/Makefile
index 15a686d76873..0753ea8e618a 100644
--- a/net/lnet/libcfs/Makefile
+++ b/net/lnet/libcfs/Makefile
@@ -8,6 +8,6 @@ libcfs-obj-y += linux-crypto-adler.o
 libcfs-obj-y += debug.o fail.o module.o tracefile.o
 libcfs-obj-y += libcfs_string.o hash.o
 libcfs-obj-$(CONFIG_SMP) += libcfs_cpu.o
-libcfs-obj-y += libcfs_mem.o libcfs_lock.o
+libcfs-obj-y += libcfs_mem.o
 
 libcfs-objs := $(libcfs-obj-y)
diff --git a/net/lnet/lnet/Makefile b/net/lnet/lnet/Makefile
index 9918008ad2d4..e22114bcd817 100644
--- a/net/lnet/lnet/Makefile
+++ b/net/lnet/lnet/Makefile
@@ -2,7 +2,8 @@
 
 obj-$(CONFIG_LNET) += lnet.o
 
-lnet-y := api-ni.o config.o nidstrings.o net_fault.o udsp.o	\
-	  lib-me.o lib-msg.o lib-md.o lib-ptl.o			\
-	  lib-socket.o lib-move.o module.o lo.o			\
-	  router.o router_proc.o acceptor.o peer.o
+lnet-y := api-ni.o config.o nidstrings.o lock.o		\
+	  lib-me.o lib-msg.o lib-md.o lib-ptl.o		\
+	  lib-socket.o lib-move.o module.o lo.o		\
+	  router.o router_proc.o acceptor.o peer.o	\
+	  net_fault.o udsp.o
diff --git a/net/lnet/libcfs/libcfs_lock.c b/net/lnet/lnet/lock.c
similarity index 96%
rename from net/lnet/libcfs/libcfs_lock.c
rename to net/lnet/lnet/lock.c
index 8af77b14ab00..d9d2af597233 100644
--- a/net/lnet/libcfs/libcfs_lock.c
+++ b/net/lnet/lnet/lock.c
@@ -27,10 +27,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/module.h>
-#include <linux/slab.h>
-#include <linux/libcfs/libcfs.h>
-#include <linux/libcfs/libcfs_cpu.h>
+#include <linux/lnet/lib-lnet.h>
 
 /** destroy cpu-partition lock, see libcfs_private.h for more detail */
 void
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
