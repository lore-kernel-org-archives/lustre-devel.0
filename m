From: James Simmons <jsimmons@infradead.org>
Date: Thu, 11 Jun 2015 15:18:11 -0400
Subject: [lustre-devel] [PATCH v4 5/9] staging:lustre: move LNet NID macros
	to LNet layer
In-Reply-To: <1434050295-10986-1-git-send-email-jsimmons@infradead.org>
References: <1434050295-10986-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1434050295-10986-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Currently several special macros LNet NID macros exist
in libcfs.h and libcfs_private.h. Move those macros
out to the lnet header types.h. The new lnet header
nidstr.h contains LNet NID string data that can be
used by user land LNet utilities and the LNet kernel
drivers.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |   55 --------------
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    1 +
 drivers/staging/lustre/include/linux/lnet/lnet.h   |    5 +-
 drivers/staging/lustre/include/linux/lnet/nidstr.h |   76 ++++++++++++++++++++
 drivers/staging/lustre/include/linux/lnet/types.h  |   33 +++++++++
 .../lustre/lustre/include/lustre/lustre_idl.h      |    1 +
 drivers/staging/lustre/lustre/include/lustre_net.h |    4 +-
 7 files changed, 114 insertions(+), 61 deletions(-)
 create mode 100644 drivers/staging/lustre/include/linux/lnet/nidstr.h

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index d8f8543..ed37d26 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -42,14 +42,10 @@
 #ifndef __LIBCFS_PRIVATE_H__
 #define __LIBCFS_PRIVATE_H__
 
-/* XXX this layering violation is for nidstrings */
-#include "../lnet/types.h"
-
 #ifndef DEBUG_SUBSYSTEM
 # define DEBUG_SUBSYSTEM S_UNDEFINED
 #endif
 
-
 /*
  * When this is on, LASSERT macro includes check for assignment used instead
  * of equality check, but doesn't have unlikely(). Turn this on from time to
@@ -410,36 +406,6 @@ int cfs_percpt_atomic_summary(atomic_t **refs);
  */
 #define CLASSERT(cond) do {switch (42) {case (cond): case 0: break; } } while (0)
 
-/* support decl needed both by kernel and liblustre */
-int	 libcfs_isknown_lnd(int type);
-char       *libcfs_lnd2modname(int type);
-char       *libcfs_lnd2str(int type);
-int	 libcfs_str2lnd(const char *str);
-char       *libcfs_net2str(__u32 net);
-char       *libcfs_nid2str(lnet_nid_t nid);
-__u32       libcfs_str2net(const char *str);
-lnet_nid_t  libcfs_str2nid(const char *str);
-int	 libcfs_str2anynid(lnet_nid_t *nid, const char *str);
-char       *libcfs_id2str(lnet_process_id_t id);
-void	cfs_free_nidlist(struct list_head *list);
-int	 cfs_parse_nidlist(char *str, int len, struct list_head *list);
-int	 cfs_match_nid(lnet_nid_t nid, struct list_head *list);
-
-/** \addtogroup lnet_addr
- * @{ */
-/* how an LNET NID encodes net:address */
-/** extract the address part of an lnet_nid_t */
-#define LNET_NIDADDR(nid)      ((__u32)((nid) & 0xffffffff))
-/** extract the network part of an lnet_nid_t */
-#define LNET_NIDNET(nid)       ((__u32)(((nid) >> 32)) & 0xffffffff)
-/** make an lnet_nid_t from a network part and an address part */
-#define LNET_MKNID(net, addr)   ((((__u64)(net))<<32)|((__u64)(addr)))
-/* how net encodes type:number */
-#define LNET_NETNUM(net)       ((net) & 0xffff)
-#define LNET_NETTYP(net)       (((net) >> 16) & 0xffff)
-#define LNET_MKNET(typ, num)    ((((__u32)(typ))<<16)|((__u32)(num)))
-/** @} lnet_addr */
-
 /* max value for numeric network address */
 #define MAX_NUMERIC_VALUE 0xffffffff
 
@@ -519,25 +485,4 @@ do {						    \
 	ptr += cfs_size_round(len + 1);		 \
 } while (0)
 
-/**
- *  Lustre Network Driver types.
- */
-enum {
-	/* Only add to these values (i.e. don't ever change or redefine them):
-	 * network addresses depend on them... */
-	QSWLND    = 1,
-	SOCKLND   = 2,
-	GMLND     = 3, /* obsolete, keep it so that libcfs_nid2str works */
-	PTLLND    = 4,
-	O2IBLND   = 5,
-	CIBLND    = 6,
-	OPENIBLND = 7,
-	IIBLND    = 8,
-	LOLND     = 9,
-	RALND     = 10,
-	VIBLND    = 11,
-	MXLND     = 12,
-	GNILND    = 13,
-};
-
 #endif
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index c46e0e6..5b3b103 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -42,6 +42,7 @@
 #define __LNET_LIB_LNET_H__
 
 #include "../libcfs/libcfs.h"
+#include "api.h"
 #include "types.h"
 #include "lnet.h"
 #include "lib-types.h"
diff --git a/drivers/staging/lustre/include/linux/lnet/lnet.h b/drivers/staging/lustre/include/linux/lnet/lnet.h
index 8d054a1..8124d8f 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnet.h
@@ -41,9 +41,6 @@
  * User application interface file
  */
 #include "types.h"
-#include "api.h"
-
-#define LNET_NIDSTR_COUNT  1024    /* # of nidstrings */
-#define LNET_NIDSTR_SIZE   32      /* size of each one (see below for usage) */
+#include "nidstr.h"
 
 #endif
diff --git a/drivers/staging/lustre/include/linux/lnet/nidstr.h b/drivers/staging/lustre/include/linux/lnet/nidstr.h
new file mode 100644
index 0000000..8eaed1a
--- /dev/null
+++ b/drivers/staging/lustre/include/linux/lnet/nidstr.h
@@ -0,0 +1,76 @@
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2011, 2014, Intel Corporation.
+ */
+#ifndef _LNET_NIDSTRINGS_H
+#define _LNET_NIDSTRINGS_H
+#include "types.h"
+
+/**
+ *  Lustre Network Driver types.
+ */
+enum {
+	/* Only add to these values (i.e. don't ever change or redefine them):
+	 * network addresses depend on them... */
+	QSWLND		= 1,
+	SOCKLND		= 2,
+	GMLND		= 3,
+	PTLLND		= 4,
+	O2IBLND		= 5,
+	CIBLND		= 6,
+	OPENIBLND	= 7,
+	IIBLND		= 8,
+	LOLND		= 9,
+	RALND		= 10,
+	VIBLND		= 11,
+	MXLND		= 12,
+	GNILND		= 13,
+	GNIIPLND	= 14,
+};
+
+struct list_head;
+
+#define LNET_NIDSTR_COUNT  1024    /* # of nidstrings */
+#define LNET_NIDSTR_SIZE   32      /* size of each one (see below for usage) */
+
+int libcfs_isknown_lnd(int type);
+char *libcfs_lnd2modname(int type);
+char *libcfs_lnd2str(int type);
+int libcfs_str2lnd(const char *str);
+char *libcfs_net2str(__u32 net);
+char *libcfs_nid2str(lnet_nid_t nid);
+__u32 libcfs_str2net(const char *str);
+lnet_nid_t libcfs_str2nid(const char *str);
+int libcfs_str2anynid(lnet_nid_t *nid, const char *str);
+char *libcfs_id2str(lnet_process_id_t id);
+void cfs_free_nidlist(struct list_head *list);
+int cfs_parse_nidlist(char *str, int len, struct list_head *list);
+int cfs_match_nid(lnet_nid_t nid, struct list_head *list);
+bool cfs_nidrange_is_contiguous(struct list_head *nidlist);
+void cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
+			       char *max_nid, size_t nidstr_length);
+
+#endif /* _LNET_NIDSTRINGS_H */
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 68d8139..15528a1 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -77,6 +77,39 @@ typedef __u32 lnet_pid_t;
 
 #define LNET_TIME_FOREVER    (-1)
 
+/* how an LNET NID encodes net:address */
+/** extract the address part of an lnet_nid_t */
+
+static inline __u32 LNET_NIDADDR(lnet_nid_t nid)
+{
+	return nid & 0xffffffff;
+}
+
+static inline __u32 LNET_NIDNET(lnet_nid_t nid)
+{
+	return (nid >> 32) & 0xffffffff;
+}
+
+static inline lnet_nid_t LNET_MKNID(__u32 net, __u32 addr)
+{
+	return (((__u64)net) << 32) | addr;
+}
+
+static inline __u32 LNET_NETNUM(__u32 net)
+{
+	return net & 0xffff;
+}
+
+static inline __u32 LNET_NETTYP(__u32 net)
+{
+	return (net >> 16) & 0xffff;
+}
+
+static inline __u32 LNET_MKNET(__u32 type, __u32 num)
+{
+	return (type << 16) | num;
+}
+
 /**
  * Objects maintained by the LNet are accessed through handles. Handle types
  * have names of the form lnet_handle_xx_t, where xx is one of the two letter
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 305ecbe..4d72d6e 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -92,6 +92,7 @@
 #define _LUSTRE_IDL_H_
 
 #include "../../../include/linux/libcfs/libcfs.h"
+#include "../../../include/linux/lnet/types.h"
 
 /* Defn's shared with user-space. */
 #include "lustre_user.h"
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 998dcd9..77a7de9 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -56,8 +56,8 @@
  */
 
 #include "../../include/linux/libcfs/libcfs.h"
-// #include <obd.h>
-#include "../../include/linux/lnet/lnet.h"
+#include "../../include/linux/lnet/nidstr.h"
+#include "../../include/linux/lnet/api.h"
 #include "lustre/lustre_idl.h"
 #include "lustre_ha.h"
 #include "lustre_sec.h"
-- 
1.7.1
