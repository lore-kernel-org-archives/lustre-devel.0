From: James Simmons <jsimmons@infradead.org>
Date: Wed, 21 Oct 2015 21:52:40 -0400
Subject: [lustre-devel] [PATCH 02/11] staging: lustre: move nidstring
	handling to LNet layer
In-Reply-To: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
References: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1445478769-21203-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Moved the source file nidstring.c from libcfs to lnet
since that is the only place it is used. With the
move of nidstring to lnet some functions in libcfs
need to be exported. In later patches those functions
that are only used by LNet also will be moved to the
LNet layer. Also add in missing MAX_NUMERIC_VALUE
defination.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/Makefile          |    2 +-
 .../{lustre/libcfs => lnet/lnet}/nidstrings.c      |   13 +++++++++----
 drivers/staging/lustre/lustre/libcfs/Makefile      |    2 +-
 .../staging/lustre/lustre/libcfs/libcfs_string.c   |    4 ++++
 4 files changed, 15 insertions(+), 6 deletions(-)
 rename drivers/staging/lustre/{lustre/libcfs => lnet/lnet}/nidstrings.c (99%)

diff --git a/drivers/staging/lustre/lnet/lnet/Makefile b/drivers/staging/lustre/lnet/lnet/Makefile
index 52492fb..e276fe2 100644
--- a/drivers/staging/lustre/lnet/lnet/Makefile
+++ b/drivers/staging/lustre/lnet/lnet/Makefile
@@ -1,6 +1,6 @@
 obj-$(CONFIG_LNET) += lnet.o
 
-lnet-y := api-ni.o config.o					\
+lnet-y := api-ni.o config.o nidstrings.o			\
 	  lib-me.o lib-msg.o lib-eq.o lib-md.o lib-ptl.o	\
 	  lib-socket.o lib-move.o module.o lo.o			\
 	  router.o router_proc.o acceptor.o peer.o
diff --git a/drivers/staging/lustre/lustre/libcfs/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
similarity index 99%
rename from drivers/staging/lustre/lustre/libcfs/nidstrings.c
rename to drivers/staging/lustre/lnet/lnet/nidstrings.c
index a54594a..81ec3a8 100644
--- a/drivers/staging/lustre/lustre/libcfs/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -33,7 +33,7 @@
  * This file is part of Lustre, http://www.lustre.org/
  * Lustre is a trademark of Sun Microsystems, Inc.
  *
- * libcfs/libcfs/nidstrings.c
+ * lnet/lnet/nidstrings.c
  *
  * Author: Phil Schwan <phil@clusterfs.com>
  */
@@ -43,6 +43,9 @@
 #include "../../include/linux/libcfs/libcfs.h"
 #include "../../include/linux/lnet/lnet.h"
 
+/* max value for numeric network address */
+#define MAX_NUMERIC_VALUE 0xffffffff
+
 /* CAVEAT VENDITOR! Keep the canonical string representation of nets/nids
  * consistent in all conversion functions.  Some code fragments are copied
  * around for the sake of clarity...
@@ -64,12 +67,13 @@ void libcfs_init_nidstrings(void)
 {
 	spin_lock_init(&libcfs_nidstring_lock);
 }
+EXPORT_SYMBOL(libcfs_init_nidstrings);
 
-static char *
+char *
 libcfs_next_nidstring(void)
 {
-	char	  *str;
-	unsigned long  flags;
+	char *str;
+	unsigned long flags;
 
 	spin_lock_irqsave(&libcfs_nidstring_lock, flags);
 
@@ -80,6 +84,7 @@ libcfs_next_nidstring(void)
 	spin_unlock_irqrestore(&libcfs_nidstring_lock, flags);
 	return str;
 }
+EXPORT_SYMBOL(libcfs_next_nidstring);
 
 static int libcfs_lo_str2addr(const char *str, int nob, __u32 *addr)
 {
diff --git a/drivers/staging/lustre/lustre/libcfs/Makefile b/drivers/staging/lustre/lustre/libcfs/Makefile
index ec98f44..03d3f3d 100644
--- a/drivers/staging/lustre/lustre/libcfs/Makefile
+++ b/drivers/staging/lustre/lustre/libcfs/Makefile
@@ -10,7 +10,7 @@ libcfs-linux-objs += linux-mem.o
 
 libcfs-linux-objs := $(addprefix linux/,$(libcfs-linux-objs))
 
-libcfs-all-objs := debug.o fail.o nidstrings.o module.o tracefile.o \
+libcfs-all-objs := debug.o fail.o module.o tracefile.o \
 		   libcfs_string.o hash.o kernel_user_comm.o \
 		   prng.o workitem.o libcfs_cpu.o \
 		   libcfs_mem.o libcfs_lock.o
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
index bbfef98..896185f 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
@@ -214,6 +214,7 @@ cfs_gettok(struct cfs_lstr *next, char delim, struct cfs_lstr *res)
 	res->ls_len = end - res->ls_str + 1;
 	return 1;
 }
+EXPORT_SYMBOL(cfs_gettok);
 
 /**
  * Converts string to integer.
@@ -242,6 +243,7 @@ cfs_str2num_check(char *str, int nob, unsigned *num,
 
 	return (*num >= min && *num <= max);
 }
+EXPORT_SYMBOL(cfs_str2num_check);
 
 /**
  * Parses \<range_expr\> token of the syntax. If \a bracketed is false,
@@ -406,6 +408,7 @@ cfs_expr_list_match(__u32 value, struct cfs_expr_list *expr_list)
 
 	return 0;
 }
+EXPORT_SYMBOL(cfs_expr_list_match);
 
 /**
  * Convert express list (\a expr_list) to an array of all matched values
@@ -558,6 +561,7 @@ cfs_expr_list_free_list(struct list_head *list)
 		cfs_expr_list_free(el);
 	}
 }
+EXPORT_SYMBOL(cfs_expr_list_free_list);
 
 int
 cfs_ip_addr_parse(char *str, int len, struct list_head *list)
-- 
1.7.1
