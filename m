From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 May 2015 18:46:17 -0400
Subject: [lustre-devel] [PATCH 2/3] staging:lustre: remove kernel defines in
	userland headers
In-Reply-To: <uja.ornl@gmail.com>
References: <uja.ornl@gmail.com>
Message-ID: <1432248378-28912-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

Currently the lnet headers used for user land applications
contain various kernel definations. This is due to the
fact libcfs contains kernel wrappers for user land which
will be going away. This patch sorted the header data
so all kernel containing structures are moved out of
headers that user land will use.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/13792
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    4 -
 .../lustre/include/linux/libcfs/libcfs_private.h   |   51 --
 .../lustre/include/linux/lnet/api-support.h        |   44 --
 drivers/staging/lustre/include/linux/lnet/api.h    |   51 +-
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  249 +-------
 .../staging/lustre/include/linux/lnet/lib-types.h  |  649 +++++++++-----------
 .../lustre/include/linux/lnet/linux/api-support.h  |   42 --
 .../lustre/include/linux/lnet/linux/lib-lnet.h     |   71 ---
 .../lustre/include/linux/lnet/linux/lib-types.h    |   45 --
 .../staging/lustre/include/linux/lnet/linux/lnet.h |   56 --
 .../lustre/include/linux/lnet/lnet-sysctl.h        |   49 --
 drivers/staging/lustre/include/linux/lnet/lnet.h   |   11 +-
 .../staging/lustre/include/linux/lnet/lnetctl.h    |   36 +-
 drivers/staging/lustre/include/linux/lnet/lnetst.h |  665 ++++++++++++--------
 drivers/staging/lustre/include/linux/lnet/nidstr.h |   73 +++
 drivers/staging/lustre/include/linux/lnet/ptllnd.h |   93 ---
 .../lustre/include/linux/lnet/ptllnd_wire.h        |  119 ----
 .../staging/lustre/include/linux/lnet/socklnd.h    |   91 ++--
 drivers/staging/lustre/include/linux/lnet/types.h  |  266 +++++++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    9 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    1 -
 .../lustre/lnet/klnds/socklnd/socklnd_lib-linux.c  |    4 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 -
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  100 +---
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |    2 +-
 drivers/staging/lustre/lnet/lnet/lib-md.c          |    6 +-
 drivers/staging/lustre/lnet/lnet/lib-me.c          |   24 +-
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   22 +-
 drivers/staging/lustre/lnet/lnet/module.c          |    4 +-
 drivers/staging/lustre/lnet/lnet/router.c          |  145 -----
 drivers/staging/lustre/lustre/include/lustre_net.h |    4 +-
 32 files changed, 1149 insertions(+), 1841 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/api-support.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/api-support.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/lib-lnet.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/lib-types.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/lnet.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/lnet-sysctl.h
 create mode 100644 drivers/staging/lustre/include/linux/lnet/nidstr.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/ptllnd.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/ptllnd_wire.h

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index f54bab6..aae9487 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -46,10 +46,6 @@
 
 #include "curproc.h"
 
-#ifndef offsetof
-# define offsetof(typ, memb) ((long)(long_ptr_t)((char *)&(((typ *)0)->memb)))
-#endif
-
 #ifndef ARRAY_SIZE
 #define ARRAY_SIZE(a) ((sizeof(a)) / (sizeof((a)[0])))
 #endif
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index fef8825..6174946 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -410,36 +410,6 @@ int cfs_percpt_atomic_summary(atomic_t **refs);
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
 
@@ -532,25 +502,4 @@ do {						    \
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
diff --git a/drivers/staging/lustre/include/linux/lnet/api-support.h b/drivers/staging/lustre/include/linux/lnet/api-support.h
deleted file mode 100644
index 8f7fa28..0000000
--- a/drivers/staging/lustre/include/linux/lnet/api-support.h
+++ /dev/null
@@ -1,44 +0,0 @@
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
- * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef __LNET_API_SUPPORT_H__
-#define __LNET_API_SUPPORT_H__
-
-#include "linux/api-support.h"
-
-#include "../libcfs/libcfs.h"
-#include "types.h"
-#include "lnet.h"
-
-#endif
diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index cd86517..76fb6fd 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -15,21 +15,19 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
+ * http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
+ *
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
+ * Lustre is a trademark of Seagate, Inc.
  */
 
 #ifndef __LNET_API_H__
@@ -41,20 +39,15 @@
  *
  * LNet is an asynchronous message-passing API, which provides an unreliable
  * connectionless service that can't guarantee any order. It supports OFA IB,
- * TCP/IP, and Cray Portals, and routes between heterogeneous networks.
- *
- * LNet can run both in OS kernel space and in userspace as a library.
+ * TCP/IP, and Cray Interconnects, and routes between heterogeneous networks.
  * @{
  */
 
-#include "../lnet/types.h"
+#include "types.h"
 
 /** \defgroup lnet_init_fini Initialization and cleanup
  * The LNet must be properly initialized before any LNet calls can be made.
  * @{ */
-int LNetInit(void);
-void LNetFini(void);
-
 int LNetNIInit(lnet_pid_t requested_pid);
 int LNetNIFini(void);
 /** @} lnet_init_fini */
@@ -84,6 +77,7 @@ void LNetSnprintHandle(char *str, int str_len, lnet_handle_any_t handle);
 
 /** @} lnet_addr */
 
+
 /** \defgroup lnet_me Match entries
  *
  * A match entry (abbreviated as ME) describes a set of criteria to accept
@@ -98,16 +92,16 @@ void LNetSnprintHandle(char *str, int str_len, lnet_handle_any_t handle);
  * @{ */
 int LNetMEAttach(unsigned int      portal,
 		 lnet_process_id_t match_id_in,
-		 __u64	     match_bits_in,
-		 __u64	     ignore_bits_in,
+		 __u64             match_bits_in,
+		 __u64             ignore_bits_in,
 		 lnet_unlink_t     unlink_in,
 		 lnet_ins_pos_t    pos_in,
 		 lnet_handle_me_t *handle_out);
 
 int LNetMEInsert(lnet_handle_me_t  current_in,
 		 lnet_process_id_t match_id_in,
-		 __u64	     match_bits_in,
-		 __u64	     ignore_bits_in,
+		 __u64             match_bits_in,
+		 __u64             ignore_bits_in,
 		 lnet_unlink_t     unlink_in,
 		 lnet_ins_pos_t    position_in,
 		 lnet_handle_me_t *handle_out);
@@ -128,11 +122,11 @@ int LNetMEUnlink(lnet_handle_me_t current_in);
  * associated with a MD: LNetMDUnlink().
  * @{ */
 int LNetMDAttach(lnet_handle_me_t  current_in,
-		 lnet_md_t	 md_in,
+		 lnet_md_t         md_in,
 		 lnet_unlink_t     unlink_in,
 		 lnet_handle_md_t *handle_out);
 
-int LNetMDBind(lnet_md_t	 md_in,
+int LNetMDBind(lnet_md_t         md_in,
 	       lnet_unlink_t     unlink_in,
 	       lnet_handle_md_t *handle_out);
 
@@ -170,14 +164,15 @@ int LNetEQFree(lnet_handle_eq_t eventq_in);
 int LNetEQGet(lnet_handle_eq_t  eventq_in,
 	      lnet_event_t     *event_out);
 
+
 int LNetEQWait(lnet_handle_eq_t  eventq_in,
 	       lnet_event_t     *event_out);
 
 int LNetEQPoll(lnet_handle_eq_t *eventqs_in,
-	       int	       neq_in,
-	       int	       timeout_ms,
+	       int               neq_in,
+	       int               timeout_ms,
 	       lnet_event_t     *event_out,
-	       int	      *which_eq_out);
+	       int              *which_eq_out);
 /** @} lnet_eq */
 
 /** \defgroup lnet_data Data movement operations
@@ -185,23 +180,24 @@ int LNetEQPoll(lnet_handle_eq_t *eventqs_in,
  * The LNet API provides two data movement operations: LNetPut()
  * and LNetGet().
  * @{ */
-int LNetPut(lnet_nid_t	self,
+int LNetPut(lnet_nid_t        self,
 	    lnet_handle_md_t  md_in,
 	    lnet_ack_req_t    ack_req_in,
 	    lnet_process_id_t target_in,
 	    unsigned int      portal_in,
-	    __u64	     match_bits_in,
+	    __u64             match_bits_in,
 	    unsigned int      offset_in,
-	    __u64	     hdr_data_in);
+	    __u64             hdr_data_in);
 
-int LNetGet(lnet_nid_t	self,
+int LNetGet(lnet_nid_t        self,
 	    lnet_handle_md_t  md_in,
 	    lnet_process_id_t target_in,
 	    unsigned int      portal_in,
-	    __u64	     match_bits_in,
+	    __u64             match_bits_in,
 	    unsigned int      offset_in);
 /** @} lnet_data */
 
+
 /** \defgroup lnet_misc Miscellaneous operations.
  * Miscellaneous operations.
  * @{ */
@@ -209,7 +205,6 @@ int LNetGet(lnet_nid_t	self,
 int LNetSetLazyPortal(int portal);
 int LNetClearLazyPortal(int portal);
 int LNetCtl(unsigned int cmd, void *arg);
-int LNetSetAsync(lnet_process_id_t id, int nasync);
 
 /** @} lnet_misc */
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index c00a2ca..5eacae4 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -15,11 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
+ * http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
@@ -27,56 +23,46 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2011, 2014, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
+ * Lustre is a trademark of Seagate, Inc.
  *
  * lnet/include/lnet/lib-lnet.h
- *
- * Top level include for library side routines
  */
 
 #ifndef __LNET_LIB_LNET_H__
 #define __LNET_LIB_LNET_H__
 
-#include "linux/lib-lnet.h"
 #include "../libcfs/libcfs.h"
-#include "types.h"
+#include "api.h"
 #include "lnet.h"
 #include "lib-types.h"
 
-extern lnet_t  the_lnet;			/* THE network */
-
-#if  defined(LNET_USE_LIB_FREELIST)
-/* 1 CPT, simplify implementation... */
-# define LNET_CPT_MAX_BITS      0
-
-#else /* KERNEL and no freelist */
+extern lnet_t	the_lnet;	/* THE network */
 
-# if (BITS_PER_LONG == 32)
+#if (BITS_PER_LONG == 32)
 /* 2 CPTs, allowing more CPTs might make us under memory pressure */
-#  define LNET_CPT_MAX_BITS     1
+# define LNET_CPT_MAX_BITS     1
 
-# else /* 64-bit system */
+#else /* 64-bit system */
 /*
  * 256 CPTs for thousands of CPUs, allowing more CPTs might make us
  * under risk of consuming all lh_cookie.
  */
-#  define LNET_CPT_MAX_BITS     8
-# endif /* BITS_PER_LONG == 32 */
-#endif
+# define LNET_CPT_MAX_BITS     8
+#endif /* BITS_PER_LONG == 32 */
 
 /* max allowed CPT number */
-#define LNET_CPT_MAX	    (1 << LNET_CPT_MAX_BITS)
+#define LNET_CPT_MAX		(1 << LNET_CPT_MAX_BITS)
 
-#define LNET_CPT_NUMBER	 (the_lnet.ln_cpt_number)
-#define LNET_CPT_BITS	   (the_lnet.ln_cpt_bits)
-#define LNET_CPT_MASK	   ((1ULL << LNET_CPT_BITS) - 1)
+#define LNET_CPT_NUMBER		(the_lnet.ln_cpt_number)
+#define LNET_CPT_BITS		(the_lnet.ln_cpt_bits)
+#define LNET_CPT_MASK		((1ULL << LNET_CPT_BITS) - 1)
 
 /** exclusive lock */
-#define LNET_LOCK_EX	    CFS_PERCPT_LOCK_EX
+#define LNET_LOCK_EX		CFS_PERCPT_LOCK_EX
 
 static inline int lnet_is_wire_handle_none(lnet_handle_wire_t *wh)
 {
@@ -177,191 +163,9 @@ lnet_net_lock_current(void)
 
 #define MAX_PORTALS     64
 
-/* these are only used by code with LNET_USE_LIB_FREELIST, but we still
- * exported them to !LNET_USE_LIB_FREELIST for easy implementation */
-#define LNET_FL_MAX_MES		2048
-#define LNET_FL_MAX_MDS		2048
-#define LNET_FL_MAX_EQS		512
-#define LNET_FL_MAX_MSGS	2048    /* Outstanding messages */
-
-#ifdef LNET_USE_LIB_FREELIST
-
-int lnet_freelist_init(lnet_freelist_t *fl, int n, int size);
-void lnet_freelist_fini(lnet_freelist_t *fl);
-
-static inline void *
-lnet_freelist_alloc(lnet_freelist_t *fl)
-{
-	/* ALWAYS called with liblock held */
-	lnet_freeobj_t *o;
-
-	if (list_empty(&fl->fl_list))
-		return NULL;
-
-	o = list_entry(fl->fl_list.next, lnet_freeobj_t, fo_list);
-	list_del(&o->fo_list);
-	return (void *)&o->fo_contents;
-}
-
-static inline void
-lnet_freelist_free(lnet_freelist_t *fl, void *obj)
-{
-	/* ALWAYS called with liblock held */
-	lnet_freeobj_t *o = list_entry(obj, lnet_freeobj_t, fo_contents);
-
-	list_add(&o->fo_list, &fl->fl_list);
-}
-
 static inline lnet_eq_t *
 lnet_eq_alloc(void)
 {
-	/* NEVER called with resource lock held */
-	struct lnet_res_container *rec = &the_lnet.ln_eq_container;
-	lnet_eq_t		  *eq;
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-
-	lnet_res_lock(0);
-	eq = (lnet_eq_t *)lnet_freelist_alloc(&rec->rec_freelist);
-	lnet_res_unlock(0);
-
-	return eq;
-}
-
-static inline void
-lnet_eq_free_locked(lnet_eq_t *eq)
-{
-	/* ALWAYS called with resource lock held */
-	struct lnet_res_container *rec = &the_lnet.ln_eq_container;
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-	lnet_freelist_free(&rec->rec_freelist, eq);
-}
-
-static inline void
-lnet_eq_free(lnet_eq_t *eq)
-{
-	lnet_res_lock(0);
-	lnet_eq_free_locked(eq);
-	lnet_res_unlock(0);
-}
-
-static inline lnet_libmd_t *
-lnet_md_alloc(lnet_md_t *umd)
-{
-	/* NEVER called with resource lock held */
-	struct lnet_res_container *rec = the_lnet.ln_md_containers[0];
-	lnet_libmd_t		  *md;
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-
-	lnet_res_lock(0);
-	md = (lnet_libmd_t *)lnet_freelist_alloc(&rec->rec_freelist);
-	lnet_res_unlock(0);
-
-	if (md != NULL)
-		INIT_LIST_HEAD(&md->md_list);
-
-	return md;
-}
-
-static inline void
-lnet_md_free_locked(lnet_libmd_t *md)
-{
-	/* ALWAYS called with resource lock held */
-	struct lnet_res_container *rec = the_lnet.ln_md_containers[0];
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-	lnet_freelist_free(&rec->rec_freelist, md);
-}
-
-static inline void
-lnet_md_free(lnet_libmd_t *md)
-{
-	lnet_res_lock(0);
-	lnet_md_free_locked(md);
-	lnet_res_unlock(0);
-}
-
-static inline lnet_me_t *
-lnet_me_alloc(void)
-{
-	/* NEVER called with resource lock held */
-	struct lnet_res_container *rec = the_lnet.ln_me_containers[0];
-	lnet_me_t		  *me;
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-
-	lnet_res_lock(0);
-	me = (lnet_me_t *)lnet_freelist_alloc(&rec->rec_freelist);
-	lnet_res_unlock(0);
-
-	return me;
-}
-
-static inline void
-lnet_me_free_locked(lnet_me_t *me)
-{
-	/* ALWAYS called with resource lock held */
-	struct lnet_res_container *rec = the_lnet.ln_me_containers[0];
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-	lnet_freelist_free(&rec->rec_freelist, me);
-}
-
-static inline void
-lnet_me_free(lnet_me_t *me)
-{
-	lnet_res_lock(0);
-	lnet_me_free_locked(me);
-	lnet_res_unlock(0);
-}
-
-static inline lnet_msg_t *
-lnet_msg_alloc(void)
-{
-	/* NEVER called with network lock held */
-	struct lnet_msg_container *msc = the_lnet.ln_msg_containers[0];
-	lnet_msg_t		  *msg;
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-
-	lnet_net_lock(0);
-	msg = (lnet_msg_t *)lnet_freelist_alloc(&msc->msc_freelist);
-	lnet_net_unlock(0);
-
-	if (msg != NULL) {
-		/* NULL pointers, clear flags etc */
-		memset(msg, 0, sizeof(*msg));
-	}
-	return msg;
-}
-
-static inline void
-lnet_msg_free_locked(lnet_msg_t *msg)
-{
-	/* ALWAYS called with network lock held */
-	struct lnet_msg_container *msc = the_lnet.ln_msg_containers[0];
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-	LASSERT(!msg->msg_onactivelist);
-	lnet_freelist_free(&msc->msc_freelist, msg);
-}
-
-static inline void
-lnet_msg_free(lnet_msg_t *msg)
-{
-	lnet_net_lock(0);
-	lnet_msg_free_locked(msg);
-	lnet_net_unlock(0);
-}
-
-#else /* !LNET_USE_LIB_FREELIST */
-
-static inline lnet_eq_t *
-lnet_eq_alloc(void)
-{
-	/* NEVER called with liblock held */
 	lnet_eq_t *eq;
 
 	LIBCFS_ALLOC(eq, sizeof(*eq));
@@ -371,14 +175,12 @@ lnet_eq_alloc(void)
 static inline void
 lnet_eq_free(lnet_eq_t *eq)
 {
-	/* ALWAYS called with resource lock held */
 	LIBCFS_FREE(eq, sizeof(*eq));
 }
 
 static inline lnet_libmd_t *
 lnet_md_alloc(lnet_md_t *umd)
 {
-	/* NEVER called with liblock held */
 	lnet_libmd_t *md;
 	unsigned int  size;
 	unsigned int  niov;
@@ -407,7 +209,6 @@ lnet_md_alloc(lnet_md_t *umd)
 static inline void
 lnet_md_free(lnet_libmd_t *md)
 {
-	/* ALWAYS called with resource lock held */
 	unsigned int  size;
 
 	if ((md->md_options & LNET_MD_KIOV) != 0)
@@ -421,7 +222,6 @@ lnet_md_free(lnet_libmd_t *md)
 static inline lnet_me_t *
 lnet_me_alloc(void)
 {
-	/* NEVER called with liblock held */
 	lnet_me_t *me;
 
 	LIBCFS_ALLOC(me, sizeof(*me));
@@ -431,14 +231,12 @@ lnet_me_alloc(void)
 static inline void
 lnet_me_free(lnet_me_t *me)
 {
-	/* ALWAYS called with resource lock held */
 	LIBCFS_FREE(me, sizeof(*me));
 }
 
 static inline lnet_msg_t *
 lnet_msg_alloc(void)
 {
-	/* NEVER called with liblock held */
 	lnet_msg_t *msg;
 
 	LIBCFS_ALLOC(msg, sizeof(*msg));
@@ -450,18 +248,10 @@ lnet_msg_alloc(void)
 static inline void
 lnet_msg_free(lnet_msg_t *msg)
 {
-	/* ALWAYS called with network lock held */
 	LASSERT(!msg->msg_onactivelist);
 	LIBCFS_FREE(msg, sizeof(*msg));
 }
 
-#define lnet_eq_free_locked(eq)		lnet_eq_free(eq)
-#define lnet_md_free_locked(md)		lnet_md_free(md)
-#define lnet_me_free_locked(me)		lnet_me_free(me)
-#define lnet_msg_free_locked(msg)	lnet_msg_free(msg)
-
-#endif /* LNET_USE_LIB_FREELIST */
-
 lnet_libhandle_t *lnet_res_lh_lookup(struct lnet_res_container *rec,
 				     __u64 cookie);
 void lnet_res_lh_initialize(struct lnet_res_container *rec,
@@ -644,6 +434,9 @@ lnet_ni_t *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
 lnet_ni_t *lnet_net2ni_locked(__u32 net, int cpt);
 lnet_ni_t *lnet_net2ni(__u32 net);
 
+int lnet_init(void);
+void lnet_fini(void);
+
 int lnet_notify(lnet_ni_t *ni, lnet_nid_t peer, int alive, unsigned long when);
 void lnet_notify_locked(lnet_peer_t *lp, int notifylnd, int alive,
 			unsigned long when);
@@ -737,7 +530,9 @@ void lnet_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 	       unsigned int offset, unsigned int mlen, unsigned int rlen);
 lnet_msg_t *lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *get_msg);
 void lnet_set_reply_msg_len(lnet_ni_t *ni, lnet_msg_t *msg, unsigned int len);
+
 void lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int rc);
+
 void lnet_drop_delayed_msg_list(struct list_head *head, char *reason);
 void lnet_recv_delayed_msg_list(struct list_head *head);
 
@@ -887,12 +682,12 @@ void lnet_peer_tables_destroy(void);
 int lnet_peer_tables_create(void);
 void lnet_debug_peer(lnet_nid_t nid);
 
-static inline void lnet_peer_set_alive(lnet_peer_t *lp)
+static inline void
+lnet_peer_set_alive(lnet_peer_t *lp)
 {
 	lp->lp_last_alive = lp->lp_last_query = get_seconds();
 	if (!lp->lp_alive)
 		lnet_notify_locked(lp, 0, 1, lp->lp_last_alive);
 }
 
-
 #endif
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 5053766..87acf14 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -15,11 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
+ * http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
@@ -27,155 +23,42 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2014, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
+ * Lustre is a trademark of Seagate, Inc.
  *
  * lnet/include/lnet/lib-types.h
- *
- * Types used by the library side routines that do not need to be
- * exposed to the user application
  */
 
 #ifndef __LNET_LIB_TYPES_H__
 #define __LNET_LIB_TYPES_H__
 
-#include "linux/lib-types.h"
-
-#include "../libcfs/libcfs.h"
-#include <linux/list.h>
-#include "types.h"
-
-#define WIRE_ATTR       __attribute__((packed))
-
-/* Packed version of lnet_process_id_t to transfer via network */
-typedef struct {
-	lnet_nid_t nid;
-	lnet_pid_t pid;   /* node id / process id */
-} WIRE_ATTR lnet_process_id_packed_t;
-
-/* The wire handle's interface cookie only matches one network interface in
- * one epoch (i.e. new cookie when the interface restarts or the node
- * reboots).  The object cookie only matches one object on that interface
- * during that object's lifetime (i.e. no cookie re-use). */
-typedef struct {
-	__u64 wh_interface_cookie;
-	__u64 wh_object_cookie;
-} WIRE_ATTR lnet_handle_wire_t;
-
-typedef enum {
-	LNET_MSG_ACK = 0,
-	LNET_MSG_PUT,
-	LNET_MSG_GET,
-	LNET_MSG_REPLY,
-	LNET_MSG_HELLO,
-} lnet_msg_type_t;
-
-/* The variant fields of the portals message header are aligned on an 8
- * byte boundary in the message header.  Note that all types used in these
- * wire structs MUST be fixed size and the smaller types are placed at the
- * end. */
-typedef struct lnet_ack {
-	lnet_handle_wire_t  dst_wmd;
-	__u64	       match_bits;
-	__u32	       mlength;
-} WIRE_ATTR lnet_ack_t;
-
-typedef struct lnet_put {
-	lnet_handle_wire_t  ack_wmd;
-	__u64	       match_bits;
-	__u64	       hdr_data;
-	__u32	       ptl_index;
-	__u32	       offset;
-} WIRE_ATTR lnet_put_t;
-
-typedef struct lnet_get {
-	lnet_handle_wire_t  return_wmd;
-	__u64	       match_bits;
-	__u32	       ptl_index;
-	__u32	       src_offset;
-	__u32	       sink_length;
-} WIRE_ATTR lnet_get_t;
-
-typedef struct lnet_reply {
-	lnet_handle_wire_t  dst_wmd;
-} WIRE_ATTR lnet_reply_t;
-
-typedef struct lnet_hello {
-	__u64	      incarnation;
-	__u32	      type;
-} WIRE_ATTR lnet_hello_t;
+#include <linux/kthread.h>
+#include <linux/uio.h>
+#include <linux/types.h>
+#include <net/sock.h>
 
-typedef struct {
-	lnet_nid_t	  dest_nid;
-	lnet_nid_t	  src_nid;
-	lnet_pid_t	  dest_pid;
-	lnet_pid_t	  src_pid;
-	__u32	       type;	       /* lnet_msg_type_t */
-	__u32	       payload_length;     /* payload data to follow */
-	/*<------__u64 aligned------->*/
-	union {
-		lnet_ack_t   ack;
-		lnet_put_t   put;
-		lnet_get_t   get;
-		lnet_reply_t reply;
-		lnet_hello_t hello;
-	} msg;
-} WIRE_ATTR lnet_hdr_t;
-
-/* A HELLO message contains a magic number and protocol version
- * code in the header's dest_nid, the peer's NID in the src_nid, and
- * LNET_MSG_HELLO in the type field.  All other common fields are zero
- * (including payload_size; i.e. no payload).
- * This is for use by byte-stream LNDs (e.g. TCP/IP) to check the peer is
- * running the same protocol and to find out its NID. These LNDs should
- * exchange HELLO messages when a connection is first established.  Individual
- * LNDs can put whatever else they fancy in lnet_hdr_t::msg.
- */
-typedef struct {
-	__u32   magic;			  /* LNET_PROTO_TCP_MAGIC */
-	__u16   version_major;		  /* increment on incompatible change */
-	__u16   version_minor;		  /* increment on compatible change */
-} WIRE_ATTR lnet_magicversion_t;
-
-/* PROTO MAGIC for LNDs */
-#define LNET_PROTO_IB_MAGIC		 0x0be91b91
-#define LNET_PROTO_RA_MAGIC		 0x0be91b92
-#define LNET_PROTO_QSW_MAGIC		0x0be91b93
-#define LNET_PROTO_GNI_MAGIC		0xb00fbabe /* ask Kim */
-#define LNET_PROTO_TCP_MAGIC		0xeebc0ded
-#define LNET_PROTO_PTL_MAGIC		0x50746C4E /* 'PtlN' unique magic */
-#define LNET_PROTO_MX_MAGIC		 0x4d583130 /* 'MX10'! */
-#define LNET_PROTO_ACCEPTOR_MAGIC	   0xacce7100
-#define LNET_PROTO_PING_MAGIC	       0x70696E67 /* 'ping' */
-
-/* Placeholder for a future "unified" protocol across all LNDs */
-/* Current LNDs that receive a request with this magic will respond with a
- * "stub" reply using their current protocol */
-#define LNET_PROTO_MAGIC		    0x45726963 /* ! */
-
-#define LNET_PROTO_TCP_VERSION_MAJOR	1
-#define LNET_PROTO_TCP_VERSION_MINOR	0
-
-/* Acceptor connection request */
-typedef struct {
-	__u32       acr_magic;		  /* PTL_ACCEPTOR_PROTO_MAGIC */
-	__u32       acr_version;		/* protocol version */
-	__u64       acr_nid;		    /* target NID */
-} WIRE_ATTR lnet_acceptor_connreq_t;
+#include "lnetctl.h"
 
-#define LNET_PROTO_ACCEPTOR_VERSION       1
+/* Max payload size */
+# define LNET_MAX_PAYLOAD      CONFIG_LNET_MAX_PAYLOAD
+# if (LNET_MAX_PAYLOAD < LNET_MTU)
+#  error "LNET_MAX_PAYLOAD too small - error in configure --with-max-payload-mb"
+# elif (LNET_MAX_PAYLOAD > (PAGE_SIZE * LNET_MAX_IOV))
+#   error "LNET_MAX_PAYLOAD too large - error in configure --with-max-payload-mb"
+#  endif
 
 /* forward refs */
 struct lnet_libmd;
 
 typedef struct lnet_msg {
-	struct list_head	    msg_activelist;
-	struct list_head	    msg_list;	   /* Q for credits/MD */
+	struct list_head	msg_activelist;
+	/* Q for credits/MD */
+	struct list_head	msg_list;
 
-	lnet_process_id_t     msg_target;
+	lnet_process_id_t	msg_target;
 	/* where is it from, it's only for building event */
 	lnet_nid_t		msg_from;
 	__u32			msg_type;
@@ -195,110 +78,115 @@ typedef struct lnet_msg {
 	/* ready for pending on RX delay list */
 	unsigned int		msg_rx_ready_delay:1;
 
-	unsigned int	  msg_vmflush:1;      /* VM trying to free memory */
-	unsigned int	  msg_target_is_router:1; /* sending to a router */
-	unsigned int	  msg_routing:1;      /* being forwarded */
-	unsigned int	  msg_ack:1;	  /* ack on finalize (PUT) */
-	unsigned int	  msg_sending:1;      /* outgoing message */
-	unsigned int	  msg_receiving:1;    /* being received */
-	unsigned int	  msg_txcredit:1;     /* taken an NI send credit */
-	unsigned int	  msg_peertxcredit:1; /* taken a peer send credit */
-	unsigned int	  msg_rtrcredit:1;    /* taken a global router credit */
-	unsigned int	  msg_peerrtrcredit:1; /* taken a peer router credit */
-	unsigned int	  msg_onactivelist:1; /* on the activelist */
-
-	struct lnet_peer     *msg_txpeer;	 /* peer I'm sending to */
-	struct lnet_peer     *msg_rxpeer;	 /* peer I received from */
-
-	void		 *msg_private;
-	struct lnet_libmd    *msg_md;
-
-	unsigned int	  msg_len;
-	unsigned int	  msg_wanted;
-	unsigned int	  msg_offset;
-	unsigned int	  msg_niov;
-	struct kvec	 *msg_iov;
-	lnet_kiov_t	  *msg_kiov;
-
-	lnet_event_t	  msg_ev;
-	lnet_hdr_t	    msg_hdr;
+	/* VM trying to free memory */
+	unsigned int		msg_vmflush:1;
+	/* sending to a router */
+	unsigned int		msg_target_is_router:1;
+	/* being forwarded */
+	unsigned int		msg_routing:1;
+	/* ack on finalize (PUT) */
+	unsigned int		msg_ack:1;
+	/* outgoing message */
+	unsigned int		msg_sending:1;
+	/* being received */
+	unsigned int		msg_receiving:1;
+	/* taken an NI send credit */
+	unsigned int		msg_txcredit:1;
+	/* taken a peer send credit */
+	unsigned int		msg_peertxcredit:1;
+	/* taken a global router credit */
+	unsigned int		msg_rtrcredit:1;
+	/* taken a peer router credit */
+	unsigned int		msg_peerrtrcredit:1;
+	/* on the activelist */
+	unsigned int		msg_onactivelist:1;
+
+	/* peer I'm sending to */
+	struct lnet_peer	*msg_txpeer;
+	/* peer I received from */
+	struct lnet_peer	*msg_rxpeer;
+
+	void			*msg_private;
+	struct lnet_libmd	*msg_md;
+
+	unsigned int		msg_len;
+	unsigned int		msg_wanted;
+	unsigned int		msg_offset;
+	unsigned int		msg_niov;
+	struct kvec		*msg_iov;
+	lnet_kiov_t		*msg_kiov;
+
+	lnet_event_t		msg_ev;
+	lnet_hdr_t		msg_hdr;
 } lnet_msg_t;
 
 typedef struct lnet_libhandle {
-	struct list_head	    lh_hash_chain;
-	__u64		 lh_cookie;
+	struct list_head	lh_hash_chain;
+	__u64			lh_cookie;
 } lnet_libhandle_t;
 
 #define lh_entry(ptr, type, member) \
 	((type *)((char *)(ptr)-(char *)(&((type *)0)->member)))
 
 typedef struct lnet_eq {
-	struct list_head		eq_list;
+	struct list_head	eq_list;
 	lnet_libhandle_t	eq_lh;
 	lnet_seq_t		eq_enq_seq;
 	lnet_seq_t		eq_deq_seq;
 	unsigned int		eq_size;
 	lnet_eq_handler_t	eq_callback;
 	lnet_event_t		*eq_events;
-	int			**eq_refs;	/* percpt refcount for EQ */
+	/* percpt refcount for EQ */
+	int			**eq_refs;
 } lnet_eq_t;
 
 typedef struct lnet_me {
-	struct list_head	     me_list;
-	lnet_libhandle_t       me_lh;
-	lnet_process_id_t      me_match_id;
-	unsigned int	   me_portal;
-	unsigned int	   me_pos;		/* hash offset in mt_hash */
-	__u64		  me_match_bits;
-	__u64		  me_ignore_bits;
-	lnet_unlink_t	  me_unlink;
-	struct lnet_libmd     *me_md;
+	struct list_head	me_list;
+	lnet_libhandle_t	me_lh;
+	lnet_process_id_t	me_match_id;
+	unsigned int		me_portal;
+	/* hash offset in mt_hash */
+	unsigned int		me_pos;
+	__u64			me_match_bits;
+	__u64			me_ignore_bits;
+	lnet_unlink_t		me_unlink;
+	struct lnet_libmd	*me_md;
 } lnet_me_t;
 
 typedef struct lnet_libmd {
-	struct list_head	    md_list;
-	lnet_libhandle_t      md_lh;
-	lnet_me_t	    *md_me;
-	char		 *md_start;
-	unsigned int	  md_offset;
-	unsigned int	  md_length;
-	unsigned int	  md_max_size;
-	int		   md_threshold;
-	int		   md_refcount;
-	unsigned int	  md_options;
-	unsigned int	  md_flags;
-	void		 *md_user_ptr;
-	lnet_eq_t	    *md_eq;
-	unsigned int	  md_niov;		/* # frags */
+	struct list_head	md_list;
+	lnet_libhandle_t	md_lh;
+	lnet_me_t		*md_me;
+	char			*md_start;
+	unsigned int		md_offset;
+	unsigned int		md_length;
+	unsigned int		md_max_size;
+	int			md_threshold;
+	int			md_refcount;
+	unsigned int		md_options;
+	unsigned int		md_flags;
+	void			*md_user_ptr;
+	lnet_eq_t		*md_eq;
+	/* # frags */
+	unsigned int		md_niov;
 	union {
-		struct kvec   iov[LNET_MAX_IOV];
-		lnet_kiov_t   kiov[LNET_MAX_IOV];
+		struct kvec	iov[LNET_MAX_IOV];
+		lnet_kiov_t	kiov[LNET_MAX_IOV];
 	} md_iov;
 } lnet_libmd_t;
 
-#define LNET_MD_FLAG_ZOMBIE	   (1 << 0)
-#define LNET_MD_FLAG_AUTO_UNLINK      (1 << 1)
-#define LNET_MD_FLAG_ABORTED	 (1 << 2)
+#define LNET_MD_FLAG_ZOMBIE		(1 << 0)
+#define LNET_MD_FLAG_AUTO_UNLINK	(1 << 1)
+#define LNET_MD_FLAG_ABORTED		(1 << 2)
 
-#ifdef LNET_USE_LIB_FREELIST
+/* info about peers we are trying to fail */
 typedef struct {
-	void		  *fl_objs;	  /* single contiguous array of objects */
-	int		    fl_nobjs;	 /* the number of them */
-	int		    fl_objsize;       /* the size (including overhead) of each of them */
-	struct list_head	     fl_list;	  /* where they are enqueued */
-} lnet_freelist_t;
-
-typedef struct {
-	struct list_head	     fo_list;	     /* enqueue on fl_list */
-	void		  *fo_contents;	 /* aligned contents */
-} lnet_freeobj_t;
-#endif
-
-typedef struct {
-	/* info about peers we are trying to fail */
-	struct list_head	     tp_list;	     /* ln_test_peers */
-	lnet_nid_t	     tp_nid;	      /* matching nid */
-	unsigned int	   tp_threshold;	/* # failures to simulate */
+	/* ln_test_peers */
+	struct list_head	tp_list;
+	/* matching nid */
+	lnet_nid_t		tp_nid;
+	/* # failures to simulate */
+	unsigned int		tp_threshold;
 } lnet_test_peer_t;
 
 #define LNET_COOKIE_TYPE_MD    1
@@ -307,15 +195,17 @@ typedef struct {
 #define LNET_COOKIE_TYPE_BITS  2
 #define LNET_COOKIE_MASK	((1ULL << LNET_COOKIE_TYPE_BITS) - 1ULL)
 
-struct lnet_ni;				  /* forward ref */
+struct lnet_ni;			/* forward ref */
 
+/* fields managed by portals */
 typedef struct lnet_lnd {
-	/* fields managed by portals */
-	struct list_head	    lnd_list;	     /* stash in the LND table */
-	int		   lnd_refcount;	 /* # active instances */
+	/* stash in the LND table */
+	struct list_head	lnd_list;
+	/* # active instances */
+	int			lnd_refcount;
 
 	/* fields initialised by the LND */
-	unsigned int	  lnd_type;
+	__u32			lnd_type;
 
 	int  (*lnd_startup)(struct lnet_ni *ni);
 	void (*lnd_shutdown)(struct lnet_ni *ni);
@@ -366,47 +256,57 @@ typedef struct lnet_lnd {
 
 	/* accept a new connection */
 	int (*lnd_accept)(struct lnet_ni *ni, struct socket *sock);
-
 } lnd_t;
 
-#define LNET_NI_STATUS_UP      0x15aac0de
-#define LNET_NI_STATUS_DOWN    0xdeadface
-#define LNET_NI_STATUS_INVALID 0x00000000
 typedef struct {
-	lnet_nid_t ns_nid;
-	__u32      ns_status;
-	__u32      ns_unused;
+	lnet_nid_t		ns_nid;
+	__u32			ns_status;
+	__u32			ns_unused;
 } WIRE_ATTR lnet_ni_status_t;
 
 struct lnet_tx_queue {
-	int			tq_credits;	/* # tx credits free */
-	int			tq_credits_min;	/* lowest it's been */
-	int			tq_credits_max;	/* total # tx credits */
-	struct list_head		tq_delayed;	/* delayed TXs */
+	/* # tx credits free */
+	int			tq_credits;
+	/* lowest it's been */
+	int			tq_credits_min;
+	/* total # tx credits */
+	int			tq_credits_max;
+	/* delayed TXs */
+	struct list_head	tq_delayed;
 };
 
-#define LNET_MAX_INTERFACES   16
-
 typedef struct lnet_ni {
 	spinlock_t		ni_lock;
-	struct list_head		ni_list;	/* chain on ln_nis */
-	struct list_head		ni_cptlist;	/* chain on ln_nis_cpt */
-	int			ni_maxtxcredits; /* # tx credits  */
+	/* chain on ln_nis */
+	struct list_head	ni_list;
+	/* chain on ln_nis_cpt */
+	struct list_head	ni_cptlist;
+	/* # tx credits  */
+	int			ni_maxtxcredits;
 	/* # per-peer send credits */
 	int			ni_peertxcredits;
 	/* # per-peer router buffer credits */
 	int			ni_peerrtrcredits;
 	/* seconds to consider peer dead */
 	int			ni_peertimeout;
-	int			ni_ncpts;	/* number of CPTs */
-	__u32			*ni_cpts;	/* bond NI on some CPTs */
-	lnet_nid_t		ni_nid;		/* interface's NID */
-	void			*ni_data;	/* instance-specific data */
-	lnd_t			*ni_lnd;	/* procedural interface */
-	struct lnet_tx_queue	**ni_tx_queues;	/* percpt TX queues */
-	int			**ni_refs;	/* percpt reference count */
-	long			ni_last_alive;	/* when I was last alive */
-	lnet_ni_status_t	*ni_status;	/* my health status */
+	/* number of CPTs */
+	int			ni_ncpts;
+	/* bond NI on some CPTs */
+	__u32			*ni_cpts;
+	/* interface's NID */
+	lnet_nid_t		ni_nid;
+	/* instance-specific data */
+	void			*ni_data;
+	/* procedural interface */
+	lnd_t			*ni_lnd;
+	/* percpt TX queues */
+	struct lnet_tx_queue	**ni_tx_queues;
+	/* percpt reference count */
+	int			**ni_refs;
+	/* when I was last alive */
+	long			ni_last_alive;
+	/* my health status */
+	lnet_ni_status_t	*ni_status;
 	/* equivalent interfaces to use */
 	char			*ni_interfaces[LNET_MAX_INTERFACES];
 } lnet_ni_t;
@@ -435,43 +335,72 @@ typedef struct {
 #define LNET_PINGINFO_SIZE offsetof(lnet_ping_info_t, pi_ni[LNET_MAX_RTR_NIS])
 typedef struct {
 	/* chain on the_lnet.ln_zombie_rcd or ln_deathrow_rcd */
-	struct list_head		rcd_list;
-	lnet_handle_md_t	rcd_mdh;	/* ping buffer MD */
-	struct lnet_peer	*rcd_gateway;	/* reference to gateway */
-	lnet_ping_info_t	*rcd_pinginfo;	/* ping buffer */
+	struct list_head	rcd_list;
+	/* ping buffer MD */
+	lnet_handle_md_t	rcd_mdh;
+	/* reference to gateway */
+	struct lnet_peer	*rcd_gateway;
+	/* ping buffer */
+	lnet_ping_info_t	*rcd_pinginfo;
 } lnet_rc_data_t;
 
 typedef struct lnet_peer {
-	struct list_head	lp_hashlist;	  /* chain on peer hash */
-	struct list_head	lp_txq;	       /* messages blocking for tx credits */
-	struct list_head	lp_rtrq;	      /* messages blocking for router credits */
-	struct list_head	lp_rtr_list;	  /* chain on router list */
-	int	       lp_txcredits;	 /* # tx credits available */
-	int	       lp_mintxcredits;      /* low water mark */
-	int	       lp_rtrcredits;	/* # router credits */
-	int	       lp_minrtrcredits;     /* low water mark */
-	unsigned int      lp_alive:1;	   /* alive/dead? */
-	unsigned int      lp_notify:1;	  /* notification outstanding? */
-	unsigned int      lp_notifylnd:1;       /* outstanding notification for LND? */
-	unsigned int      lp_notifying:1;       /* some thread is handling notification */
-	unsigned int      lp_ping_notsent;      /* SEND event outstanding from ping */
-	int	       lp_alive_count;       /* # times router went dead<->alive */
-	long	      lp_txqnob;	    /* bytes queued for sending */
-	unsigned long	lp_timestamp;	 /* time of last aliveness news */
-	unsigned long	lp_ping_timestamp;    /* time of last ping attempt */
-	unsigned long	lp_ping_deadline;     /* != 0 if ping reply expected */
-	unsigned long	lp_last_alive;	/* when I was last alive */
-	unsigned long	lp_last_query;	/* when lp_ni was queried last time */
-	lnet_ni_t	*lp_ni;		/* interface peer is on */
-	lnet_nid_t	lp_nid;	       /* peer's NID */
-	int	       lp_refcount;	  /* # refs */
-	int			lp_cpt;		/* CPT this peer attached on */
+	/* chain on peer hash */
+	struct list_head	lp_hashlist;
+	/* messages blocking for tx credits */
+	struct list_head	lp_txq;
+	/* messages blocking for router credits */
+	struct list_head	lp_rtrq;
+	/* chain on router list */
+	struct list_head	lp_rtr_list;
+	/* # tx credits available */
+	int			lp_txcredits;
+	/* low water mark */
+	int			lp_mintxcredits;
+	/* # router credits */
+	int			lp_rtrcredits;
+	/* low water mark */
+	int			lp_minrtrcredits;
+	/* alive/dead? */
+	unsigned int		lp_alive:1;
+	/* notification outstanding? */
+	unsigned int		lp_notify:1;
+	/* outstanding notification for LND? */
+	unsigned int		lp_notifylnd:1;
+	/* some thread is handling notification */
+	unsigned int		lp_notifying:1;
+	/* SEND event outstanding from ping */
+	unsigned int		lp_ping_notsent;
+	/* # times router went dead<->alive */
+	int			lp_alive_count;
+	/* bytes queued for sending */
+	long			lp_txqnob;
+	/* time of last aliveness news */
+	unsigned long		lp_timestamp;
+	/* time of last ping attempt */
+	unsigned long		lp_ping_timestamp;
+	/* != 0 if ping reply expected */
+	unsigned long		lp_ping_deadline;
+	/* when I was last alive */
+	unsigned long		lp_last_alive;
+	/* when lp_ni was queried last time */
+	unsigned long		lp_last_query;
+	/* interface peer is on */
+	lnet_ni_t		*lp_ni;
+	/* peer's NID */
+	lnet_nid_t		lp_nid;
+	/* # refs */
+	int			lp_refcount;
+	/* CPT this peer attached on */
+	int			lp_cpt;
 	/* # refs from lnet_route_t::lr_gateway */
 	int			lp_rtr_refcount;
 	/* returned RC ping features */
 	unsigned int		lp_ping_feats;
-	struct list_head		lp_routes;	/* routers on this peer */
-	lnet_rc_data_t		*lp_rcd;	/* router checker state */
+	/* routers on this peer */
+	struct list_head	lp_routes;
+	/* router checker state */
+	lnet_rc_data_t		*lp_rcd;
 } lnet_peer_t;
 
 /* peer hash size */
@@ -480,10 +409,14 @@ typedef struct lnet_peer {
 
 /* peer hash table */
 struct lnet_peer_table {
-	int			pt_version;	/* /proc validity stamp */
-	int			pt_number;	/* # peers extant */
-	struct list_head		pt_deathrow;	/* zombie peers */
-	struct list_head		*pt_hash;	/* NID->peer hash */
+	/* /proc validity stamp */
+	int			pt_version;
+	/* # peers extant */
+	int			pt_number;
+	/* zombie peers */
+	struct list_head	pt_deathrow;
+	/* NID->peer hash */
+	struct list_head	*pt_hash;
 };
 
 /* peer aliveness is enabled only on routers for peers in a network where the
@@ -492,14 +425,22 @@ struct lnet_peer_table {
 					 (lp)->lp_ni->ni_peertimeout > 0)
 
 typedef struct {
-	struct list_head		lr_list;	/* chain on net */
-	struct list_head		lr_gwlist;	/* chain on gateway */
-	lnet_peer_t		*lr_gateway;	/* router node */
-	__u32			lr_net;		/* remote network number */
-	int			lr_seq;		/* sequence for round-robin */
-	unsigned int		lr_downis;	/* number of down NIs */
-	unsigned int		lr_hops;	/* how far I am */
-	unsigned int            lr_priority;    /* route priority */
+	/* chain on net */
+	struct list_head	lr_list;
+	/* chain on gateway */
+	struct list_head	lr_gwlist;
+	/* router node */
+	lnet_peer_t		*lr_gateway;
+	/* remote network number */
+	__u32			lr_net;
+	/* sequence for round-robin */
+	int			lr_seq;
+	/* number of down NIs */
+	unsigned int		lr_downis;
+	/* how far I am */
+	unsigned int		lr_hops;
+	/* route priority */
+	unsigned int		lr_priority;
 } lnet_route_t;
 
 #define LNET_REMOTE_NETS_HASH_DEFAULT	(1U << 7)
@@ -507,43 +448,41 @@ typedef struct {
 #define LNET_REMOTE_NETS_HASH_SIZE	(1 << the_lnet.ln_remote_nets_hbits)
 
 typedef struct {
-	struct list_head	      lrn_list;       /* chain on ln_remote_nets_hash */
-	struct list_head	      lrn_routes;     /* routes to me */
-	__u32		   lrn_net;	/* my net number */
+	/* chain on ln_remote_nets_hash */
+	struct list_head	lrn_list;
+	/* routes to me */
+	struct list_head	lrn_routes;
+	/* my net number */
+	__u32			lrn_net;
 } lnet_remotenet_t;
 
 typedef struct {
-	struct list_head rbp_bufs;	     /* my free buffer pool */
-	struct list_head rbp_msgs;	     /* messages blocking for a buffer */
-	int	rbp_npages;	   /* # pages in each buffer */
-	int	rbp_nbuffers;	 /* # buffers */
-	int	rbp_credits;	  /* # free buffers / blocked messages */
-	int	rbp_mincredits;       /* low water mark */
+	/* my free buffer pool */
+	struct list_head	rbp_bufs;
+	/* messages blocking for a buffer */
+	struct list_head	rbp_msgs;
+	/* # pages in each buffer */
+	int			rbp_npages;
+	/* # buffers */
+	int			rbp_nbuffers;
+	/* # free buffers / blocked messages */
+	int			rbp_credits;
+	/* low water mark */
+	int			rbp_mincredits;
 } lnet_rtrbufpool_t;
 
 typedef struct {
-	struct list_head	     rb_list;	     /* chain on rbp_bufs */
-	lnet_rtrbufpool_t     *rb_pool;	     /* owning pool */
-	lnet_kiov_t	    rb_kiov[0];	  /* the buffer space */
+	/* chain on rbp_bufs */
+	struct list_head	rb_list;
+	/* owning pool */
+	lnet_rtrbufpool_t	*rb_pool;
+	/* the buffer space */
+	lnet_kiov_t		rb_kiov[0];
 } lnet_rtrbuf_t;
 
-typedef struct {
-	__u32	msgs_alloc;
-	__u32	msgs_max;
-	__u32	errors;
-	__u32	send_count;
-	__u32	recv_count;
-	__u32	route_count;
-	__u32	drop_count;
-	__u64	send_length;
-	__u64	recv_length;
-	__u64	route_length;
-	__u64	drop_length;
-} WIRE_ATTR lnet_counters_t;
-
-#define LNET_PEER_HASHSIZE   503		/* prime! */
-
-#define LNET_NRBPOOLS	 3		 /* # different router buffer pools */
+#define LNET_PEER_HASHSIZE	503	/* prime! */
+
+#define LNET_NRBPOOLS		3	/* # different router buffer pools */
 
 enum {
 	/* Didn't match anything */
@@ -559,9 +498,9 @@ enum {
 };
 
 /* Options for lnet_portal_t::ptl_options */
-#define LNET_PTL_LAZY	       (1 << 0)
-#define LNET_PTL_MATCH_UNIQUE       (1 << 1)    /* unique match, for RDMA */
-#define LNET_PTL_MATCH_WILDCARD     (1 << 2)    /* wildcard match, request portal */
+#define LNET_PTL_LAZY		(1 << 0)
+#define LNET_PTL_MATCH_UNIQUE	(1 << 1) /* unique match, for RDMA */
+#define LNET_PTL_MATCH_WILDCARD	(1 << 2) /* wildcard match, request portal */
 
 /* parameter for matching operations (GET, PUT) */
 struct lnet_match_info {
@@ -591,13 +530,15 @@ struct lnet_match_info {
 struct lnet_match_table {
 	/* reserved for upcoming patches, CPU partition ID */
 	unsigned int		mt_cpt;
-	unsigned int		mt_portal;      /* portal index */
+	/* portal index */
+	unsigned int		mt_portal;
 	/* match table is set as "enabled" if there's non-exhausted MD
 	 * attached on mt_mhash, it's only valid for wildcard portal */
 	unsigned int		mt_enabled;
 	/* bitmap to flag whether MEs on mt_hash are exhausted or not */
 	__u64			mt_exhausted[LNET_MT_EXHAUSTED_BMAP];
-	struct list_head		*mt_mhash;      /* matching hash */
+	/* matching hash */
+	struct list_head	*mt_mhash;
 };
 
 /* these are only useful for wildcard portal */
@@ -612,21 +553,22 @@ struct lnet_match_table {
 
 typedef struct lnet_portal {
 	spinlock_t		ptl_lock;
-	unsigned int		ptl_index;	/* portal ID, reserved */
+	/* portal ID, reserved */
+	unsigned int		ptl_index;
 	/* flags on this portal: lazy, unique... */
 	unsigned int		ptl_options;
 	/* list of messages which are stealing buffer */
-	struct list_head		ptl_msg_stealing;
+	struct list_head	ptl_msg_stealing;
 	/* messages blocking for MD */
-	struct list_head		ptl_msg_delayed;
+	struct list_head	ptl_msg_delayed;
 	/* Match table for each CPT */
 	struct lnet_match_table	**ptl_mtables;
 	/* spread rotor of incoming "PUT" */
 	unsigned int		ptl_rotor;
 	/* # active entries for this portal */
-	int		     ptl_mt_nmaps;
+	int			ptl_mt_nmaps;
 	/* array of active entries' cpu-partition-id */
-	int		     ptl_mt_maps[0];
+	int			ptl_mt_maps[0];
 } lnet_portal_t;
 
 #define LNET_LH_HASH_BITS	12
@@ -635,28 +577,28 @@ typedef struct lnet_portal {
 
 /* resource container (ME, MD, EQ) */
 struct lnet_res_container {
-	unsigned int		rec_type;	/* container type */
-	__u64			rec_lh_cookie;	/* cookie generator */
-	struct list_head		rec_active;	/* active resource list */
-	struct list_head		*rec_lh_hash;	/* handle hash */
-#ifdef LNET_USE_LIB_FREELIST
-	lnet_freelist_t		rec_freelist;	/* freelist for resources */
-#endif
+	/* container type */
+	unsigned int		rec_type;
+	/* cookie generator */
+	__u64			rec_lh_cookie;
+	/* active resource list */
+	struct list_head	rec_active;
+	/* handle hash */
+	struct list_head	*rec_lh_hash;
 };
 
 /* message container */
 struct lnet_msg_container {
-	int			msc_init;	/* initialized or not */
+	/* initialized or not */
+	int			msc_init;
 	/* max # threads finalizing */
 	int			msc_nfinalizers;
 	/* msgs waiting to complete finalizing */
-	struct list_head		msc_finalizing;
-	struct list_head		msc_active;	/* active message list */
+	struct list_head	msc_finalizing;
+	/* active message list */
+	struct list_head	msc_active;
 	/* threads doing finalization */
 	void			**msc_finalizers;
-#ifdef LNET_USE_LIB_FREELIST
-	lnet_freelist_t		msc_freelist;	/* freelist for messages */
-#endif
 };
 
 /* Router Checker states */
@@ -684,7 +626,7 @@ typedef struct {
 
 	/* Event Queue container */
 	struct lnet_res_container	ln_eq_container;
-	wait_queue_head_t			ln_eq_waitq;
+	wait_queue_head_t		ln_eq_waitq;
 	spinlock_t			ln_eq_wait_lock;
 	unsigned int			ln_remote_nets_hbits;
 
@@ -695,23 +637,25 @@ typedef struct {
 	lnet_counters_t			**ln_counters;
 	struct lnet_peer_table		**ln_peer_tables;
 	/* failure simulation */
-	struct list_head			ln_test_peers;
+	struct list_head		ln_test_peers;
 
-	struct list_head			ln_nis;		/* LND instances */
+	/* LND instances */
+	struct list_head		ln_nis;
 	/* NIs bond on specific CPT(s) */
-	struct list_head			ln_nis_cpt;
+	struct list_head		ln_nis_cpt;
 	/* dying LND instances */
-	struct list_head			ln_nis_zombie;
-	lnet_ni_t			*ln_loni;	/* the loopback NI */
+	struct list_head		ln_nis_zombie;
+	/* the loopback NI */
+	lnet_ni_t			*ln_loni;
 	/* NI to wait for events in */
 	lnet_ni_t			*ln_eq_waitni;
 
 	/* remote networks with routes to them */
-	struct list_head			*ln_remote_nets_hash;
+	struct list_head		*ln_remote_nets_hash;
 	/* validity stamp */
 	__u64				ln_remote_nets_version;
 	/* list of all known routers */
-	struct list_head			ln_routers;
+	struct list_head		ln_routers;
 	/* validity stamp */
 	__u64				ln_routers_version;
 	/* percpt router buffer pools */
@@ -726,15 +670,16 @@ typedef struct {
 	/* router checker's event queue */
 	lnet_handle_eq_t		ln_rc_eqh;
 	/* rcd still pending on net */
-	struct list_head			ln_rcd_deathrow;
+	struct list_head		ln_rcd_deathrow;
 	/* rcd ready for free */
-	struct list_head			ln_rcd_zombie;
+	struct list_head		ln_rcd_zombie;
 	/* serialise startup/shutdown */
 	struct semaphore		ln_rc_signal;
 
 	struct mutex			ln_api_mutex;
 	struct mutex			ln_lnd_mutex;
-	int				ln_init;	/* LNetInit() called? */
+	/* LNetInit() called? */
+	int				ln_init;
 	/* Have I called LNetNIInit myself? */
 	int				ln_niinit_self;
 	/* LNetNIInit/LNetNIFini counter */
@@ -742,12 +687,14 @@ typedef struct {
 	/* shutdown in progress */
 	int				ln_shutdown;
 
-	int				ln_routing;	/* am I a router? */
-	lnet_pid_t			ln_pid;		/* requested pid */
+	/* am I a router? */
+	int				ln_routing;
+	/* requested pid */
+	lnet_pid_t			ln_pid;
 	/* uniquely identifies this ni in this epoch */
 	__u64				ln_interface_cookie;
 	/* registered LNDs */
-	struct list_head			ln_lnds;
+	struct list_head		ln_lnds;
 
 	/* space for network names */
 	char				*ln_network_tokens;
diff --git a/drivers/staging/lustre/include/linux/lnet/linux/api-support.h b/drivers/staging/lustre/include/linux/lnet/linux/api-support.h
deleted file mode 100644
index e237ad6..0000000
--- a/drivers/staging/lustre/include/linux/lnet/linux/api-support.h
+++ /dev/null
@@ -1,42 +0,0 @@
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
- * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef __LINUX_API_SUPPORT_H__
-#define __LINUX_API_SUPPORT_H__
-
-#ifndef __LNET_API_SUPPORT_H__
-#error Do not #include this file directly. #include <lnet /api-support.h> instead
-#endif
-
-#endif
diff --git a/drivers/staging/lustre/include/linux/lnet/linux/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/linux/lib-lnet.h
deleted file mode 100644
index 0f8f04d..0000000
--- a/drivers/staging/lustre/include/linux/lnet/linux/lib-lnet.h
+++ /dev/null
@@ -1,71 +0,0 @@
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
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef __LNET_LINUX_LIB_LNET_H__
-#define __LNET_LINUX_LIB_LNET_H__
-
-#ifndef __LNET_LIB_LNET_H__
-#error Do not #include this file directly. #include <linux/lnet/lib-lnet.h> instead
-#endif
-
-# include <asm/page.h>
-# include <linux/string.h>
-# include <asm/io.h>
-#include "../../libcfs/libcfs.h"
-
-static inline __u64
-lnet_page2phys(struct page *p)
-{
-	/* compiler optimizer will elide unused branches */
-
-	switch (sizeof(typeof(page_to_phys(p)))) {
-	case 4:
-		/* page_to_phys returns a 32 bit physical address.  This must
-		 * be a 32 bit machine with <= 4G memory and we must ensure we
-		 * don't sign extend when converting to 64 bits. */
-		return (unsigned long)page_to_phys(p);
-
-	case 8:
-		/* page_to_phys returns a 64 bit physical address :) */
-		return page_to_phys(p);
-
-	default:
-		LBUG();
-		return 0;
-	}
-}
-
-#define LNET_ROUTER
-
-#endif /* __LNET_LINUX_LIB_LNET_H__ */
diff --git a/drivers/staging/lustre/include/linux/lnet/linux/lib-types.h b/drivers/staging/lustre/include/linux/lnet/linux/lib-types.h
deleted file mode 100644
index 669e8c0..0000000
--- a/drivers/staging/lustre/include/linux/lnet/linux/lib-types.h
+++ /dev/null
@@ -1,45 +0,0 @@
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
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef __LNET_LINUX_LIB_TYPES_H__
-#define __LNET_LINUX_LIB_TYPES_H__
-
-#ifndef __LNET_LIB_TYPES_H__
-#error Do not #include this file directly. #include <linux/lnet/lib-types.h> instead
-#endif
-
-# include <linux/uio.h>
-# include <linux/types.h>
-
-#endif
diff --git a/drivers/staging/lustre/include/linux/lnet/linux/lnet.h b/drivers/staging/lustre/include/linux/lnet/linux/lnet.h
deleted file mode 100644
index 1e888f1..0000000
--- a/drivers/staging/lustre/include/linux/lnet/linux/lnet.h
+++ /dev/null
@@ -1,56 +0,0 @@
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
- * Copyright (c) 2011, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef __LNET_LINUX_LNET_H__
-#define __LNET_LINUX_LNET_H__
-
-#ifndef __LNET_H__
-#error Do not #include this file directly. #include <linux/lnet/lnet.h> instead
-#endif
-
-/*
- * lnet.h
- *
- * User application interface file
- */
-
-#include <linux/uio.h>
-#include <linux/types.h>
-
-#define cfs_tcp_sendpage(sk, page, offset, size, flags) \
-	tcp_sendpage(sk, page, offset, size, flags)
-
-#endif
diff --git a/drivers/staging/lustre/include/linux/lnet/lnet-sysctl.h b/drivers/staging/lustre/include/linux/lnet/lnet-sysctl.h
deleted file mode 100644
index 2dee1b9..0000000
--- a/drivers/staging/lustre/include/linux/lnet/lnet-sysctl.h
+++ /dev/null
@@ -1,49 +0,0 @@
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
- * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef __LNET_SYSCTL_H__
-#define __LNET_SYSCTL_H__
-
-#if defined(CONFIG_SYSCTL)
-
-#define CTL_KRANAL      201
-#define CTL_O2IBLND     205
-#define CTL_PTLLND      206
-#define CTL_QSWNAL      207
-#define CTL_SOCKLND     208
-#define CTL_GNILND      210
-
-#endif
-
-#endif
diff --git a/drivers/staging/lustre/include/linux/lnet/lnet.h b/drivers/staging/lustre/include/linux/lnet/lnet.h
index 75c0ab9..a31b29c 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnet.h
@@ -26,10 +26,12 @@
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
+ *
+ * Copyright (c) 2014, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
+ * Lustre is a trademark of Seagate, Inc.
  */
 
 #ifndef __LNET_H__
@@ -40,12 +42,7 @@
  *
  * User application interface file
  */
-#include "linux/lnet.h"
-
 #include "types.h"
-#include "api.h"
-
-#define LNET_NIDSTR_COUNT  1024    /* # of nidstrings */
-#define LNET_NIDSTR_SIZE   32      /* size of each one (see below for usage) */
+#include "nidstr.h"
 
 #endif
diff --git a/drivers/staging/lustre/include/linux/lnet/lnetctl.h b/drivers/staging/lustre/include/linux/lnet/lnetctl.h
index 98181d3..2b82a06 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetctl.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetctl.h
@@ -14,27 +14,29 @@
  *   along with Portals; if not, write to the Free Software
  *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  *
- * header for libptlctl.a
+ * header for lnet ioctl
  */
-#ifndef _PTLCTL_H_
-#define _PTLCTL_H_
+/*
+ * Copyright (c) 2014, Intel Corporation.
+ */
+#ifndef _LNETCTL_H_
+#define _LNETCTL_H_
 
-#include "../libcfs/libcfs.h"
 #include "types.h"
 
-#define LNET_DEV_ID 0
-#define LNET_DEV_PATH "/dev/lnet"
-#define LNET_DEV_MAJOR 10
-#define LNET_DEV_MINOR 240
-#define OBD_DEV_ID 1
-#define OBD_DEV_NAME "obd"
-#define OBD_DEV_PATH "/dev/" OBD_DEV_NAME
-#define OBD_DEV_MAJOR 10
-#define OBD_DEV_MINOR 241
-#define SMFS_DEV_ID  2
-#define SMFS_DEV_PATH "/dev/snapdev"
-#define SMFS_DEV_MAJOR 10
-#define SMFS_DEV_MINOR 242
+#define LNET_DEV_ID	0
+#define LNET_DEV_PATH	"/dev/lnet"
+#define LNET_DEV_MAJOR	10
+#define LNET_DEV_MINOR	240
+#define OBD_DEV_ID	1
+#define OBD_DEV_NAME	"obd"
+#define OBD_DEV_PATH	"/dev/"	OBD_DEV_NAME
+#define OBD_DEV_MAJOR	10
+#define OBD_DEV_MINOR	241
+#define SMFS_DEV_ID	2
+#define SMFS_DEV_PATH	"/dev/snapdev"
+#define SMFS_DEV_MAJOR	10
+#define SMFS_DEV_MINOR	242
 
 int ptl_initialize(int argc, char **argv);
 int jt_ptl_network(int argc, char **argv);
diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index 885f708..462eae8 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -15,11 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
+ * http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
@@ -27,123 +23,182 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, Intel Corporation.
+ * Copyright (c) 2012, 2014, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
+ * Lustre is a trademark of Seagate, Inc.
  *
  * lnet/include/lnet/lnetst.h
  *
- * Author: Liang Zhen <liangzhen@clusterfs.com>
+ * Author: Liang Zhen <liang.zhen@intel.com>
  */
 
 #ifndef __LNET_ST_H__
 #define __LNET_ST_H__
 
-#include "../libcfs/libcfs.h"
-#include "lnet.h"
-#include "lib-types.h"
-
 #define LST_FEAT_NONE		(0)
 #define LST_FEAT_BULK_LEN	(1 << 0)	/* enable variable page size */
 
 #define LST_FEATS_EMPTY		(LST_FEAT_NONE)
 #define LST_FEATS_MASK		(LST_FEAT_NONE | LST_FEAT_BULK_LEN)
 
-#define LST_NAME_SIZE	   32	      /* max name buffer length */
-
-#define LSTIO_DEBUG	     0xC00	   /* debug */
-#define LSTIO_SESSION_NEW       0xC01	   /* create session */
-#define LSTIO_SESSION_END       0xC02	   /* end session */
-#define LSTIO_SESSION_INFO      0xC03	   /* query session */
-#define LSTIO_GROUP_ADD	 0xC10	   /* add group */
-#define LSTIO_GROUP_LIST	0xC11	   /* list all groups in session */
-#define LSTIO_GROUP_INFO	0xC12	   /* query default information of specified group */
-#define LSTIO_GROUP_DEL	 0xC13	   /* delete group */
-#define LSTIO_NODES_ADD	 0xC14	   /* add nodes to specified group */
-#define LSTIO_GROUP_UPDATE      0xC15	   /* update group */
-#define LSTIO_BATCH_ADD	 0xC20	   /* add batch */
-#define LSTIO_BATCH_START       0xC21	   /* start batch */
-#define LSTIO_BATCH_STOP	0xC22	   /* stop batch */
-#define LSTIO_BATCH_DEL	 0xC23	   /* delete batch */
-#define LSTIO_BATCH_LIST	0xC24	   /* show all batches in the session */
-#define LSTIO_BATCH_INFO	0xC25	   /* show defail of specified batch */
-#define LSTIO_TEST_ADD	  0xC26	   /* add test (to batch) */
-#define LSTIO_BATCH_QUERY       0xC27	   /* query batch status */
-#define LSTIO_STAT_QUERY	0xC30	   /* get stats */
-
-typedef struct {
-	lnet_nid_t	      ses_nid;		/* nid of console node */
-	__u64		   ses_stamp;	      /* time stamp */
-} lst_sid_t;					    /*** session id */
+#define LST_NAME_SIZE		32		/* max name buffer length */
+
+/* debug */
+#define LSTIO_DEBUG		0xC00
+/* create session */
+#define LSTIO_SESSION_NEW	0xC01
+/* end session */
+#define LSTIO_SESSION_END	0xC02
+/* query session */
+#define LSTIO_SESSION_INFO	0xC03
+/* add group */
+#define LSTIO_GROUP_ADD		0xC10
+/* list all groups in session */
+#define LSTIO_GROUP_LIST	0xC11
+/* query default information of specified group */
+#define LSTIO_GROUP_INFO	0xC12
+/* delete group */
+#define LSTIO_GROUP_DEL		0xC13
+/* add nodes to specified group */
+#define LSTIO_NODES_ADD		0xC14
+/* update group */
+#define LSTIO_GROUP_UPDATE	0xC15
+/* add batch */
+#define LSTIO_BATCH_ADD		0xC20
+/* start batch */
+#define LSTIO_BATCH_START	0xC21
+/* stop batch */
+#define LSTIO_BATCH_STOP	0xC22
+/* delete batch */
+#define LSTIO_BATCH_DEL		0xC23
+/* show all batches in the session */
+#define LSTIO_BATCH_LIST	0xC24
+/* show details of specified batch */
+#define LSTIO_BATCH_INFO	0xC25
+/* add test (to batch) */
+#define LSTIO_TEST_ADD		0xC26
+/* query batch status */
+#define LSTIO_BATCH_QUERY	0xC27
+/* get stats */
+#define LSTIO_STAT_QUERY	0xC30
+
+/*** session id */
+typedef struct {
+	/* nid of console node */
+	lnet_nid_t	ses_nid;
+	/* time stamp */
+	__u64		ses_stamp;
+} lst_sid_t;
 
 extern lst_sid_t LST_INVALID_SID;
 
-typedef struct {
-	__u64		   bat_id;		 /* unique id in session */
-} lst_bid_t;					    /*** batch id (group of tests) */
-
-/* Status of test node */
-#define LST_NODE_ACTIVE	 0x1		     /* node in this session */
-#define LST_NODE_BUSY	   0x2		     /* node is taken by other session */
-#define LST_NODE_DOWN	   0x4		     /* node is down */
-#define LST_NODE_UNKNOWN	0x8		     /* node not in session */
-
-typedef struct {
-	lnet_process_id_t       nde_id;		 /* id of node */
-	int		     nde_state;	      /* state of node */
-} lstcon_node_ent_t;				    /*** node entry, for list_group command */
-
-typedef struct {
-	int		     nle_nnode;	      /* # of nodes */
-	int		     nle_nactive;	    /* # of active nodes */
-	int		     nle_nbusy;	      /* # of busy nodes */
-	int		     nle_ndown;	      /* # of down nodes */
-	int		     nle_nunknown;	   /* # of unknown nodes */
-} lstcon_ndlist_ent_t;				  /*** node_list entry, for list_batch command */
-
-typedef struct {
-	int		     tse_type;	       /* test type */
-	int		     tse_loop;	       /* loop count */
-	int		     tse_concur;	     /* concurrency of test */
-} lstcon_test_ent_t;				    /*** test summary entry, for list_batch command */
-
-typedef struct {
-	int		     bae_state;	      /* batch status */
-	int		     bae_timeout;	    /* batch timeout */
-	int		     bae_ntest;	      /* # of tests in the batch */
-} lstcon_batch_ent_t;				   /*** batch summary entry, for list_batch command */
-
-typedef struct {
-	lstcon_ndlist_ent_t     tbe_cli_nle;	    /* client (group) node_list entry */
-	lstcon_ndlist_ent_t     tbe_srv_nle;	    /* server (group) node_list entry */
+/*** batch id (group of tests) */
+typedef struct {
+	/* unique id in session */
+	__u64		bat_id;
+} lst_bid_t;
+
+/*** Status of test node */
+
+/* node in this session */
+#define LST_NODE_ACTIVE		0x1
+/* node is taken by other session */
+#define LST_NODE_BUSY		0x2
+/* node is down */
+#define LST_NODE_DOWN		0x4
+/* node not in session */
+#define LST_NODE_UNKNOWN	0x8
+
+/*** node entry, for list_group command */
+typedef struct {
+	/* id of node */
+	lnet_process_id_t	nde_id;
+	/* state of node */
+	int			nde_state;
+} lstcon_node_ent_t;
+
+/*** node_list entry, for list_batch command */
+typedef struct {
+	/* # of nodes */
+	int	nle_nnode;
+	/* # of active nodes */
+	int	nle_nactive;
+	/* # of busy nodes */
+	int	nle_nbusy;
+	/* # of down nodes */
+	int	nle_ndown;
+	/* # of unknown nodes */
+	int	nle_nunknown;
+} lstcon_ndlist_ent_t;
+
+/*** test summary entry, for list_batch command */
+typedef struct {
+	/* test type */
+	int	tse_type;
+	/* loop count */
+	int	tse_loop;
+	/* concurrency of test */
+	int	tse_concur;
+} lstcon_test_ent_t;
+
+/*** batch summary entry, for list_batch command */
+typedef struct {
+	/* batch status */
+	int	bae_state;
+	/* batch status */
+	int	bae_timeout;
+	/* # of tests in the batch */
+	int	bae_ntest;
+} lstcon_batch_ent_t;
+
+/*** test/batch verbose information entry, for list_batch command */
+typedef struct {
+	/* client (group) node_list entry */
+	lstcon_ndlist_ent_t		tbe_cli_nle;
+	/* server (group) node_list entry */
+	lstcon_ndlist_ent_t		tbe_srv_nle;
 	union {
-		lstcon_test_ent_t  tbe_test;	    /* test entry */
-		lstcon_batch_ent_t tbe_batch;	   /* batch entry */
+		/* test entry */
+		lstcon_test_ent_t	tbe_test;
+		/* batch entry */
+		lstcon_batch_ent_t	tbe_batch;
 	} u;
-} lstcon_test_batch_ent_t;			      /*** test/batch verbose information entry,
-							 *** for list_batch command */
-
-typedef struct {
-	struct list_head	      rpe_link;	       /* link chain */
-	lnet_process_id_t       rpe_peer;	       /* peer's id */
-	struct timeval	  rpe_stamp;	      /* time stamp of RPC */
-	int		     rpe_state;	      /* peer's state */
-	int		     rpe_rpc_errno;	  /* RPC errno */
-
-	lst_sid_t	       rpe_sid;		/* peer's session id */
-	int		     rpe_fwk_errno;	  /* framework errno */
-	int		     rpe_priv[4];	    /* private data */
-	char		    rpe_payload[0];	 /* private reply payload */
+} lstcon_test_batch_ent_t;
+
+typedef struct {
+	/* link chain */
+	struct list_head	rpe_link;
+	/* peer's id */
+	lnet_process_id_t	rpe_peer;
+	/* time stamp of RPC */
+	struct timeval		rpe_stamp;
+	/* peer's state */
+	int			rpe_state;
+	/* RPC errno */
+	int			rpe_rpc_errno;
+	/* peer's session id */
+	lst_sid_t		rpe_sid;
+	/* framework errno */
+	int			rpe_fwk_errno;
+	/* private data */
+	int			rpe_priv[4];
+	/* private reply payload */
+	char			rpe_payload[0];
 } lstcon_rpc_ent_t;
 
 typedef struct {
-	int		     trs_rpc_stat[4];	/* RPCs stat (0: total, 1: failed, 2: finished, 4: reserved */
-	int		     trs_rpc_errno;	  /* RPC errno */
-	int		     trs_fwk_stat[8];	/* framework stat */
-	int		     trs_fwk_errno;	  /* errno of the first remote error */
-	void		   *trs_fwk_private;	/* private framework stat */
+	/* RPCs stat (0: total, 1: failed, 2: finished, 4: reserved */
+	int	trs_rpc_stat[4];
+	/* RPC errno */
+	int	trs_rpc_errno;
+	/* framework stat */
+	int	trs_fwk_stat[8];
+	/* errno of the first remote error */
+	int	trs_fwk_errno;
+	/* private framework stat */
+	void	*trs_fwk_private;
 } lstcon_trans_stat_t;
 
 static inline int
@@ -238,237 +293,351 @@ lstcon_statqry_stat_failure(lstcon_trans_stat_t *stat, int inc)
 
 /* create a session */
 typedef struct {
-	int		     lstio_ses_key;	  /* IN: local key */
-	int		     lstio_ses_timeout;      /* IN: session timeout */
-	int		     lstio_ses_force;	/* IN: force create ? */
+	/* IN: local key */
+	int		lstio_ses_key;
+	/* IN: session timeout */
+	int		lstio_ses_timeout;
+	/* IN: force create ? */
+	int		lstio_ses_force;
 	/** IN: session features */
-	unsigned		lstio_ses_feats;
-	lst_sid_t	      *lstio_ses_idp;	  /* OUT: session id */
-	int		     lstio_ses_nmlen;	/* IN: name length */
-	char		   *lstio_ses_namep;	/* IN: session name */
+	unsigned	lstio_ses_feats;
+	/* OUT: session id */
+	lst_sid_t	*lstio_ses_idp;
+	/* IN: name length */
+	int		lstio_ses_nmlen;
+	/* IN: session name */
+	char		*lstio_ses_namep;
 } lstio_session_new_args_t;
 
 /* query current session */
 typedef struct {
-	lst_sid_t	      *lstio_ses_idp;	  /* OUT: session id */
-	int		    *lstio_ses_keyp;	 /* OUT: local key */
+	/* OUT: session id */
+	lst_sid_t		*lstio_ses_idp;
+	/* OUT: local key */
+	int			*lstio_ses_keyp;
 	/** OUT: session features */
-	unsigned	       *lstio_ses_featp;
-	lstcon_ndlist_ent_t    *lstio_ses_ndinfo;       /* OUT: */
-	int		     lstio_ses_nmlen;	/* IN: name length */
-	char		   *lstio_ses_namep;	/* OUT: session name */
+	unsigned		*lstio_ses_featp;
+	/* OUT: */
+	lstcon_ndlist_ent_t	*lstio_ses_ndinfo;
+	/* IN: name length */
+	int			lstio_ses_nmlen;
+	/* OUT: session name */
+	char			*lstio_ses_namep;
 } lstio_session_info_args_t;
 
 /* delete a session */
 typedef struct {
-	int		     lstio_ses_key;	  /* IN: session key */
+	/* IN: session key */
+	int	lstio_ses_key;
 } lstio_session_end_args_t;
 
-#define LST_OPC_SESSION	 1
-#define LST_OPC_GROUP	   2
-#define LST_OPC_NODES	   3
+#define LST_OPC_SESSION		1
+#define LST_OPC_GROUP		2
+#define LST_OPC_NODES		3
 #define LST_OPC_BATCHCLI	4
 #define LST_OPC_BATCHSRV	5
 
 typedef struct {
-	int		     lstio_dbg_key;	  /* IN: session key */
-	int		     lstio_dbg_type;	 /* IN: debug sessin|batch|group|nodes list */
-	int		     lstio_dbg_flags;	/* IN: reserved debug flags */
-	int		     lstio_dbg_timeout;      /* IN: timeout of debug */
-
-	int		     lstio_dbg_nmlen;	/* IN: len of name */
-	char		   *lstio_dbg_namep;	/* IN: name of group|batch */
-	int		     lstio_dbg_count;	/* IN: # of test nodes to debug */
-	lnet_process_id_t      *lstio_dbg_idsp;	 /* IN: id of test nodes */
-	struct list_head	     *lstio_dbg_resultp;      /* OUT: list head of result buffer */
+	/* IN: session key */
+	int			lstio_dbg_key;
+	/* IN: debug sessin|batch|group|nodes list */
+	int			lstio_dbg_type;
+	/* IN: reserved debug flags */
+	int			lstio_dbg_flags;
+	/* IN: timeout of debug */
+	int			lstio_dbg_timeout;
+	/* IN: len of name */
+	int			lstio_dbg_nmlen;
+	/* IN: name of group|batch */
+	char			*lstio_dbg_namep;
+	/* IN: # of test nodes to debug */
+	int			lstio_dbg_count;
+	/* IN: id of test nodes */
+	lnet_process_id_t	*lstio_dbg_idsp;
+	/* OUT: list head of result buffer */
+	struct list_head	*lstio_dbg_resultp;
 } lstio_debug_args_t;
 
 typedef struct {
-	int		     lstio_grp_key;	  /* IN: session key */
-	int		     lstio_grp_nmlen;	/* IN: name length */
-	char		   *lstio_grp_namep;	/* IN: group name */
+	/* IN: session key */
+	int	lstio_grp_key;
+	/* IN: name length */
+	int	lstio_grp_nmlen;
+	/* IN: group name */
+	char	*lstio_grp_namep;
 } lstio_group_add_args_t;
 
 typedef struct {
-	int		     lstio_grp_key;	  /* IN: session key */
-	int		     lstio_grp_nmlen;	/* IN: name length */
-	char		   *lstio_grp_namep;	/* IN: group name */
+	/* IN: session key */
+	int	lstio_grp_key;
+	/* IN: name length */
+	int	lstio_grp_nmlen;	/* IN: name length */
+	/* IN: group name */
+	char	*lstio_grp_namep;
 } lstio_group_del_args_t;
 
-#define LST_GROUP_CLEAN	 1		       /* remove inactive nodes in the group */
-#define LST_GROUP_REFRESH       2		       /* refresh inactive nodes in the group */
-#define LST_GROUP_RMND	  3		       /* delete nodes from the group */
-
-typedef struct {
-	int		     lstio_grp_key;	  /* IN: session key */
-	int		     lstio_grp_opc;	  /* IN: OPC */
-	int		     lstio_grp_args;	 /* IN: arguments */
-	int		     lstio_grp_nmlen;	/* IN: name length */
-	char		   *lstio_grp_namep;	/* IN: group name */
-	int		     lstio_grp_count;	/* IN: # of nodes id */
-	lnet_process_id_t      *lstio_grp_idsp;	 /* IN: array of nodes */
-	struct list_head	     *lstio_grp_resultp;      /* OUT: list head of result buffer */
+#define LST_GROUP_CLEAN		1	/* remove inactive nodes in the group */
+#define LST_GROUP_REFRESH	2	/* refresh inactive nodes in the group */
+#define LST_GROUP_RMND		3	/* delete nodes from the group */
+
+typedef struct {
+	/* IN: session key */
+	int			lstio_grp_key;
+	/* IN: OPC */
+	int			lstio_grp_opc;
+	/* IN: arguments */
+	int			lstio_grp_args;
+	/* IN: name length */
+	int			lstio_grp_nmlen;
+	/* IN: group name */
+	char			*lstio_grp_namep;
+	/* IN: # of nodes id */
+	int			lstio_grp_count;
+	/* IN: array of nodes */
+	lnet_process_id_t	*lstio_grp_idsp;
+	/* OUT: list head of result buffer */
+	struct list_head	*lstio_grp_resultp;
 } lstio_group_update_args_t;
 
 typedef struct {
-	int		     lstio_grp_key;	  /* IN: session key */
-	int		     lstio_grp_nmlen;	/* IN: name length */
-	char		   *lstio_grp_namep;	/* IN: group name */
-	int		     lstio_grp_count;	/* IN: # of nodes */
+	/* IN: session key */
+	int			lstio_grp_key;
+	/* IN: name length */
+	int			lstio_grp_nmlen;
+	/* IN: group name */
+	char			*lstio_grp_namep;
+	/* IN: # of nodes */
+	int			lstio_grp_count;
 	/** OUT: session features */
-	unsigned	       *lstio_grp_featp;
-	lnet_process_id_t      *lstio_grp_idsp;	 /* IN: nodes */
-	struct list_head	     *lstio_grp_resultp;      /* OUT: list head of result buffer */
+	unsigned		*lstio_grp_featp;
+	/* IN: nodes */
+	lnet_process_id_t	*lstio_grp_idsp;
+	/* OUT: list head of result buffer */
+	struct list_head	*lstio_grp_resultp;
 } lstio_group_nodes_args_t;
 
 typedef struct {
-	int		     lstio_grp_key;	  /* IN: session key */
-	int		     lstio_grp_idx;	  /* IN: group idx */
-	int		     lstio_grp_nmlen;	/* IN: name len */
-	char		   *lstio_grp_namep;	/* OUT: name */
+	/* IN: session key */
+	int	lstio_grp_key;
+	/* IN: group idx */
+	int	lstio_grp_idx;
+	/* IN: name len */
+	int	lstio_grp_nmlen;
+	/* OUT: name */
+	char	*lstio_grp_namep;
 } lstio_group_list_args_t;
 
 typedef struct {
-	int		     lstio_grp_key;	  /* IN: session key */
-	int		     lstio_grp_nmlen;	/* IN: name len */
-	char		   *lstio_grp_namep;	/* IN: name */
-	lstcon_ndlist_ent_t    *lstio_grp_entp;	 /* OUT: description of group */
-
-	int		    *lstio_grp_idxp;	 /* IN/OUT: node index */
-	int		    *lstio_grp_ndentp;       /* IN/OUT: # of nodent */
-	lstcon_node_ent_t      *lstio_grp_dentsp;       /* OUT: nodent array */
+	/* IN: session key */
+	int			lstio_grp_key;
+	/* IN: name len */
+	int			lstio_grp_nmlen;
+	/* IN: name */
+	char			*lstio_grp_namep;
+	/* OUT: description of group */
+	lstcon_ndlist_ent_t	*lstio_grp_entp;
+	/* IN/OUT: node index */
+	int			*lstio_grp_idxp;
+	/* IN/OUT: # of nodent */
+	int			*lstio_grp_ndentp;
+	/* OUT: nodent array */
+	lstcon_node_ent_t	*lstio_grp_dentsp;
 } lstio_group_info_args_t;
 
-#define LST_DEFAULT_BATCH       "batch"		 /* default batch name */
+#define LST_DEFAULT_BATCH	"batch"	/* default batch name */
 
 typedef struct {
-	int		     lstio_bat_key;	  /* IN: session key */
-	int		     lstio_bat_nmlen;	/* IN: name length */
-	char		   *lstio_bat_namep;	/* IN: batch name */
+	/* IN: session key */
+	int	lstio_bat_key;
+	/* IN: name length */
+	int	lstio_bat_nmlen;
+	/* IN: batch name */
+	char	*lstio_bat_namep;
 } lstio_batch_add_args_t;
 
 typedef struct {
-	int		     lstio_bat_key;	  /* IN: session key */
-	int		     lstio_bat_nmlen;	/* IN: name length */
-	char		   *lstio_bat_namep;	/* IN: batch name */
+	/* IN: session key */
+	int	lstio_bat_key;	  /* IN: session key */
+	/* IN: name length */
+	int	lstio_bat_nmlen;
+	/* IN: batch name */
+	char	*lstio_bat_namep;
 } lstio_batch_del_args_t;
 
 typedef struct {
-	int		     lstio_bat_key;	  /* IN: session key */
-	int		     lstio_bat_timeout;      /* IN: timeout for the batch */
-	int		     lstio_bat_nmlen;	/* IN: name length */
-	char		   *lstio_bat_namep;	/* IN: batch name */
-	struct list_head	     *lstio_bat_resultp;      /* OUT: list head of result buffer */
+	/* IN: session key */
+	int			lstio_bat_key;
+	/* IN: timeout for the batch */
+	int			lstio_bat_timeout;
+	/* IN: name length */
+	int			lstio_bat_nmlen;
+	/* IN: batch name */
+	char			*lstio_bat_namep;
+	/* OUT: list head of result buffer */
+	struct list_head	*lstio_bat_resultp;
 } lstio_batch_run_args_t;
 
 typedef struct {
-	int		     lstio_bat_key;	  /* IN: session key */
-	int		     lstio_bat_force;	/* IN: abort unfinished test RPC */
-	int		     lstio_bat_nmlen;	/* IN: name length */
-	char		   *lstio_bat_namep;	/* IN: batch name */
-	struct list_head	     *lstio_bat_resultp;      /* OUT: list head of result buffer */
+	/* IN: session key */
+	int			lstio_bat_key;
+	/* IN: abort unfinished test RPC */
+	int			lstio_bat_force;
+	/* IN: name length */
+	int			lstio_bat_nmlen;
+	/* IN: batch name */
+	char			*lstio_bat_namep;
+	/* OUT: list head of result buffer */
+	struct list_head	*lstio_bat_resultp;
 } lstio_batch_stop_args_t;
 
 typedef struct {
-	int		     lstio_bat_key;	  /* IN: session key */
-	int		     lstio_bat_testidx;      /* IN: test index */
-	int		     lstio_bat_client;       /* IN: is test client? */
-	int		     lstio_bat_timeout;      /* IN: timeout for waiting */
-	int		     lstio_bat_nmlen;	/* IN: name length */
-	char		   *lstio_bat_namep;	/* IN: batch name */
-	struct list_head	     *lstio_bat_resultp;      /* OUT: list head of result buffer */
+	/* IN: session key */
+	int			lstio_bat_key;
+	/* IN: test index */
+	int			lstio_bat_testidx;
+	/* IN: is test client? */
+	int			lstio_bat_client;
+	/* IN: timeout for waiting */
+	int			lstio_bat_timeout;
+	/* IN: name length */
+	int			lstio_bat_nmlen;
+	/* IN: batch name */
+	char			*lstio_bat_namep;
+	/* OUT: list head of result buffer */
+	struct list_head	*lstio_bat_resultp;
 } lstio_batch_query_args_t;
 
 typedef struct {
-	int		     lstio_bat_key;	  /* IN: session key */
-	int		     lstio_bat_idx;	  /* IN: index */
-	int		     lstio_bat_nmlen;	/* IN: name length */
-	char		   *lstio_bat_namep;	/* IN: batch name */
+	/* IN: session key */
+	int	lstio_bat_key;
+	/* IN: index */
+	int	lstio_bat_idx;
+	/* IN: name length */
+	int	lstio_bat_nmlen;
+	/* IN: batch name */
+	char	*lstio_bat_namep;
 } lstio_batch_list_args_t;
 
 typedef struct {
-	int		     lstio_bat_key;	  /* IN: session key */
-	int		     lstio_bat_nmlen;	/* IN: name length */
-	char		   *lstio_bat_namep;	/* IN: name */
-	int		     lstio_bat_server;       /* IN: query server or not */
-	int		     lstio_bat_testidx;      /* IN: test index */
-	lstcon_test_batch_ent_t *lstio_bat_entp;	/* OUT: batch ent */
-
-	int		    *lstio_bat_idxp;	 /* IN/OUT: index of node */
-	int		    *lstio_bat_ndentp;       /* IN/OUT: # of nodent */
-	lstcon_node_ent_t      *lstio_bat_dentsp;       /* array of nodent */
+	/* IN: session key */
+	int			lstio_bat_key;
+	/* IN: name length */
+	int			lstio_bat_nmlen;
+	/* IN: name */
+	char			*lstio_bat_namep;
+	/* IN: query server or not */
+	int			lstio_bat_server;
+	/* IN: test index */
+	int			lstio_bat_testidx;
+	/* OUT: batch ent */
+	lstcon_test_batch_ent_t	*lstio_bat_entp;
+	/* IN/OUT: index of node */
+	int			*lstio_bat_idxp;
+	/* IN/OUT: # of nodent */
+	int			*lstio_bat_ndentp;
+	/* array of nodent */
+	lstcon_node_ent_t	*lstio_bat_dentsp;
 } lstio_batch_info_args_t;
 
 /* add stat in session */
 typedef struct {
-	int		     lstio_sta_key;	  /* IN: session key */
-	int		     lstio_sta_timeout;      /* IN: timeout for stat request */
-	int		     lstio_sta_nmlen;	/* IN: group name length */
-	char		   *lstio_sta_namep;	/* IN: group name */
-	int		     lstio_sta_count;	/* IN: # of pid */
-	lnet_process_id_t      *lstio_sta_idsp;	 /* IN: pid */
-	struct list_head	     *lstio_sta_resultp;      /* OUT: list head of result buffer */
+	/* IN: session key */
+	int			lstio_sta_key;
+	/* IN: timeout for stat request */
+	int			lstio_sta_timeout;
+	/* IN: group name length */
+	int			lstio_sta_nmlen;
+	/* IN: group name */
+	char			*lstio_sta_namep;
+	/* IN: # of pid */
+	int			lstio_sta_count;
+	/* IN: pid */
+	lnet_process_id_t	*lstio_sta_idsp;
+	/* OUT: list head of result buffer */
+	struct list_head	*lstio_sta_resultp;
 } lstio_stat_args_t;
 
 typedef enum {
-	LST_TEST_BULK   = 1,
-	LST_TEST_PING   = 2
+	LST_TEST_BULK	= 1,
+	LST_TEST_PING	= 2
 } lst_test_type_t;
 
 /* create a test in a batch */
-#define LST_MAX_CONCUR	  1024		    /* Max concurrency of test */
-
-typedef struct {
-	int		     lstio_tes_key;	  /* IN: session key */
-	int		     lstio_tes_bat_nmlen;    /* IN: batch name len */
-	char		   *lstio_tes_bat_name;     /* IN: batch name */
-	int		     lstio_tes_type;	 /* IN: test type */
-	int		     lstio_tes_oneside;      /* IN: one sided test */
-	int		     lstio_tes_loop;	 /* IN: loop count */
-	int		     lstio_tes_concur;       /* IN: concurrency */
-
-	int		     lstio_tes_dist;	 /* IN: node distribution in destination groups */
-	int		     lstio_tes_span;	 /* IN: node span in destination groups */
-	int		     lstio_tes_sgrp_nmlen;   /* IN: source group name length */
-	char		   *lstio_tes_sgrp_name;    /* IN: group name */
-	int		     lstio_tes_dgrp_nmlen;   /* IN: destination group name length */
-	char		   *lstio_tes_dgrp_name;    /* IN: group name */
-
-	int		     lstio_tes_param_len;    /* IN: param buffer len */
-	void		   *lstio_tes_param;	/* IN: parameter for specified test:
-							       lstio_bulk_param_t,
-							       lstio_ping_param_t,
-							       ... more */
-	int		    *lstio_tes_retp;	 /* OUT: private returned value */
-	struct list_head	     *lstio_tes_resultp;      /* OUT: list head of result buffer */
+#define LST_MAX_CONCUR	1024	/* Max concurrency of test */
+
+typedef struct {
+	/* IN: session key */
+	int			lstio_tes_key;
+	/* IN: batch name len */
+	int			lstio_tes_bat_nmlen;
+	/* IN: batch name */
+	char			*lstio_tes_bat_name;
+	/* IN: test type */
+	int			lstio_tes_type;
+	/* IN: one sided test */
+	int			lstio_tes_oneside;
+	/* IN: loop count */
+	int			lstio_tes_loop;
+	/* IN: concurrency */
+	int			lstio_tes_concur;
+	/* IN: node distribution in destination groups */
+	int			lstio_tes_dist;
+	/* IN: node span in destination groups */
+	int			lstio_tes_span;
+	/* IN: source group name length */
+	int			lstio_tes_sgrp_nmlen;
+	/* IN: group name */
+	char			*lstio_tes_sgrp_name;
+	/* IN: destination group name length */
+	int			lstio_tes_dgrp_nmlen;
+	/* IN: group name */
+	char			*lstio_tes_dgrp_name;
+	/* IN: param buffer len */
+	int			lstio_tes_param_len;
+	/* IN: parameter for specified test:
+	 *	lstio_bulk_param_t,
+	 *	lstio_ping_param_t,
+	 *	... more */
+	void			*lstio_tes_param;
+	/* OUT: private returned value */
+	int			*lstio_tes_retp;
+	/* OUT: list head of result buffer */
+	struct list_head	*lstio_tes_resultp;
 } lstio_test_args_t;
 
 typedef enum {
-	LST_BRW_READ    = 1,
-	LST_BRW_WRITE   = 2
+	LST_BRW_READ	= 1,
+	LST_BRW_WRITE	= 2
 } lst_brw_type_t;
 
 typedef enum {
-	LST_BRW_CHECK_NONE   = 1,
-	LST_BRW_CHECK_SIMPLE = 2,
-	LST_BRW_CHECK_FULL   = 3
+	LST_BRW_CHECK_NONE	= 1,
+	LST_BRW_CHECK_SIMPLE	= 2,
+	LST_BRW_CHECK_FULL	= 3
 } lst_brw_flags_t;
 
 typedef struct {
-	int		     blk_opc;		/* bulk operation code */
-	int		     blk_size;	       /* size (bytes) */
-	int		     blk_time;	       /* time of running the test*/
-	int		     blk_flags;	      /* reserved flags */
+	/* bulk operation code */
+	int	blk_opc;
+	/* size (bytes) */
+	int	blk_size;	       /* size (bytes) */
+	/* time of running the test*/
+	int	blk_time;
+	/* reserved flags */
+	int	blk_flags;
 } lst_test_bulk_param_t;
 
 typedef struct {
-	int		     png_size;	       /* size of ping message */
-	int		     png_time;	       /* time */
-	int		     png_loop;	       /* loop */
-	int		     png_flags;	      /* reserved flags */
+	/* size of ping message */
+	int	png_size;
+	/* time */
+	int	png_time;
+	/* loop */
+	int	png_loop;
+	/* reserved flags */
+	int	png_flags;
 } lst_test_ping_param_t;
 
-/* more tests */
 typedef struct {
 	__u32 errors;
 	__u32 rpcs_sent;
diff --git a/drivers/staging/lustre/include/linux/lnet/nidstr.h b/drivers/staging/lustre/include/linux/lnet/nidstr.h
new file mode 100644
index 0000000..14cca80
--- /dev/null
+++ b/drivers/staging/lustre/include/linux/lnet/nidstr.h
@@ -0,0 +1,73 @@
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
+/* # of nidstrings */
+#define LNET_NIDSTR_COUNT	1024
+/* size of each one (see below for usage) */
+#define LNET_NIDSTR_SIZE	32
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
+
+#endif /* _LNET_NIDSTRINGS_H */
diff --git a/drivers/staging/lustre/include/linux/lnet/ptllnd.h b/drivers/staging/lustre/include/linux/lnet/ptllnd.h
deleted file mode 100644
index c91d653..0000000
--- a/drivers/staging/lustre/include/linux/lnet/ptllnd.h
+++ /dev/null
@@ -1,93 +0,0 @@
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
- * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lnet/include/lnet/ptllnd.h
- *
- * Author: PJ Kirner <pjkirner@clusterfs.com>
- */
-
-/*
- * The PTLLND was designed to support Portals with
- * Lustre and non-lustre UNLINK semantics.
- * However for now the two targets are Cray Portals
- * on the XT3 and Lustre Portals (for testing) both
- * have Lustre UNLINK semantics, so this is defined
- * by default.
- */
-#define LUSTRE_PORTALS_UNLINK_SEMANTICS
-
-#ifdef _USING_LUSTRE_PORTALS_
-
-/* NIDs are 64-bits on Lustre Portals */
-#define FMT_NID "%llu"
-#define FMT_PID "%d"
-
-/* When using Lustre Portals Lustre completion semantics are imlicit*/
-#define PTL_MD_LUSTRE_COMPLETION_SEMANTICS      0
-
-#else /* _USING_CRAY_PORTALS_ */
-
-/* NIDs are integers on Cray Portals */
-#define FMT_NID "%u"
-#define FMT_PID "%d"
-
-/* When using Cray Portals this is defined in the Cray Portals Header*/
-/*#define PTL_MD_LUSTRE_COMPLETION_SEMANTICS */
-
-/* Can compare handles directly on Cray Portals */
-#define PtlHandleIsEqual(a, b) ((a) == (b))
-
-/* Different error types on Cray Portals*/
-#define ptl_err_t ptl_ni_fail_t
-
-/*
- * The Cray Portals has no maximum number of IOVs.  The
- * maximum is limited only by memory and size of the
- * int parameters (2^31-1).
- * Lustre only really require that the underyling
- * implementation to support at least LNET_MAX_IOV,
- * so for Cray portals we can safely just use that
- * value here.
- *
- */
-#define PTL_MD_MAX_IOV	  LNET_MAX_IOV
-
-#endif
-
-#define FMT_PTLID "ptlid:"FMT_PID"-"FMT_NID
-
-/* Align incoming small request messages to an 8 byte boundary if this is
- * supported to avoid alignment issues on some architectures */
-#ifndef PTL_MD_LOCAL_ALIGN8
-# define PTL_MD_LOCAL_ALIGN8 0
-#endif
diff --git a/drivers/staging/lustre/include/linux/lnet/ptllnd_wire.h b/drivers/staging/lustre/include/linux/lnet/ptllnd_wire.h
deleted file mode 100644
index 808f37b..0000000
--- a/drivers/staging/lustre/include/linux/lnet/ptllnd_wire.h
+++ /dev/null
@@ -1,119 +0,0 @@
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
- * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lnet/include/lnet/ptllnd_wire.h
- *
- * Author: PJ Kirner <pjkirner@clusterfs.com>
- */
-
-/* Minimum buffer size that any peer will post to receive ptllnd messages */
-#define PTLLND_MIN_BUFFER_SIZE  256
-
-/************************************************************************
- * Tunable defaults that {u,k}lnds/ptllnd should have in common.
- */
-
-#define PTLLND_PORTAL	   9	  /* The same portal PTLPRC used when talking to cray portals */
-#define PTLLND_PID	      9	  /* The Portals PID */
-#define PTLLND_PEERCREDITS      8	  /* concurrent sends to 1 peer */
-
-/* Default buffer size for kernel ptllnds (guaranteed eager) */
-#define PTLLND_MAX_KLND_MSG_SIZE 512
-
-/* Default buffer size for catamount ptllnds (not guaranteed eager) - large
- * enough to avoid RDMA for anything sent while control is not in liblustre */
-#define PTLLND_MAX_ULND_MSG_SIZE 512
-
-/************************************************************************
- * Portals LND Wire message format.
- * These are sent in sender's byte order (i.e. receiver flips).
- */
-
-#define PTL_RESERVED_MATCHBITS  0x100	/* below this value is reserved
-					 * above is for bulk data transfer */
-#define LNET_MSG_MATCHBITS       0      /* the value for the message channel */
-
-typedef struct {
-	lnet_hdr_t	kptlim_hdr;	     /* portals header */
-	char	      kptlim_payload[0];      /* piggy-backed payload */
-} WIRE_ATTR kptl_immediate_msg_t;
-
-typedef struct {
-	lnet_hdr_t	kptlrm_hdr;	     /* portals header */
-	__u64	     kptlrm_matchbits;       /* matchbits */
-} WIRE_ATTR kptl_rdma_msg_t;
-
-typedef struct {
-	__u64	     kptlhm_matchbits;       /* matchbits */
-	__u32	     kptlhm_max_msg_size;    /* max message size */
-} WIRE_ATTR kptl_hello_msg_t;
-
-typedef struct {
-	/* First 2 fields fixed FOR ALL TIME */
-	__u32	   ptlm_magic;     /* I'm a Portals LND message */
-	__u16	   ptlm_version;   /* this is my version number */
-	__u8	    ptlm_type;      /* the message type */
-	__u8	    ptlm_credits;   /* returned credits */
-	__u32	   ptlm_nob;       /* # bytes in whole message */
-	__u32	   ptlm_cksum;     /* checksum (0 == no checksum) */
-	__u64	   ptlm_srcnid;    /* sender's NID */
-	__u64	   ptlm_srcstamp;  /* sender's incarnation */
-	__u64	   ptlm_dstnid;    /* destination's NID */
-	__u64	   ptlm_dststamp;  /* destination's incarnation */
-	__u32	   ptlm_srcpid;    /* sender's PID */
-	__u32	   ptlm_dstpid;    /* destination's PID */
-
-	 union {
-		kptl_immediate_msg_t    immediate;
-		kptl_rdma_msg_t	 rdma;
-		kptl_hello_msg_t	hello;
-	} WIRE_ATTR ptlm_u;
-
-} kptl_msg_t;
-
-/* kptl_msg_t::ptlm_credits is only a __u8 */
-#define PTLLND_MSG_MAX_CREDITS ((typeof(((kptl_msg_t *)0)->ptlm_credits)) - 1)
-
-#define PTLLND_MSG_MAGIC		LNET_PROTO_PTL_MAGIC
-#define PTLLND_MSG_VERSION	      0x04
-
-#define PTLLND_RDMA_OK		  0x00
-#define PTLLND_RDMA_FAIL		0x01
-
-#define PTLLND_MSG_TYPE_INVALID	 0x00
-#define PTLLND_MSG_TYPE_PUT	     0x01
-#define PTLLND_MSG_TYPE_GET	     0x02
-#define PTLLND_MSG_TYPE_IMMEDIATE       0x03    /* No bulk data xfer*/
-#define PTLLND_MSG_TYPE_NOOP	    0x04
-#define PTLLND_MSG_TYPE_HELLO	   0x05
-#define PTLLND_MSG_TYPE_NAK	     0x06
diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index 389038b..e62df8c 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -15,89 +15,92 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
+ * http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
+ *
+ * Copyright (c) 2012, 2014 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
+ * Lustre is a trademark of Seagate, Inc.
  *
  * lnet/include/lnet/socklnd.h
- *
- * #defines shared between socknal implementation and utilities
  */
 #ifndef __LNET_LNET_SOCKLND_H__
 #define __LNET_LNET_SOCKLND_H__
 
 #include "types.h"
-#include "lib-types.h"
 
-#define SOCKLND_CONN_NONE     (-1)
+#define SOCKLND_CONN_NONE	(-1)
 #define SOCKLND_CONN_ANY	0
-#define SOCKLND_CONN_CONTROL    1
-#define SOCKLND_CONN_BULK_IN    2
-#define SOCKLND_CONN_BULK_OUT   3
-#define SOCKLND_CONN_NTYPES     4
+#define SOCKLND_CONN_CONTROL	1
+#define SOCKLND_CONN_BULK_IN	2
+#define SOCKLND_CONN_BULK_OUT	3
+#define SOCKLND_CONN_NTYPES	4
 
 #define SOCKLND_CONN_ACK	SOCKLND_CONN_BULK_IN
 
 typedef struct {
-	__u32		   kshm_magic;     /* magic number of socklnd message */
-	__u32		   kshm_version;   /* version of socklnd message */
-	lnet_nid_t	      kshm_src_nid;   /* sender's nid */
-	lnet_nid_t	      kshm_dst_nid;   /* destination nid */
-	lnet_pid_t	      kshm_src_pid;   /* sender's pid */
-	lnet_pid_t	      kshm_dst_pid;   /* destination pid */
-	__u64		   kshm_src_incarnation; /* sender's incarnation */
-	__u64		   kshm_dst_incarnation; /* destination's incarnation */
-	__u32		   kshm_ctype;     /* connection type */
-	__u32		   kshm_nips;      /* # IP addrs */
-	__u32		   kshm_ips[0];    /* IP addrs */
+	/* magic number of socklnd message */
+	__u32		kshm_magic;
+	/* version of socklnd message */
+	__u32		kshm_version;
+	/* sender's nid */
+	lnet_nid_t	kshm_src_nid;
+	/* destination nid */
+	lnet_nid_t	kshm_dst_nid;
+	/* sender's pid */
+	lnet_pid_t	kshm_src_pid;
+	/* destination pid */
+	lnet_pid_t	kshm_dst_pid;
+	/* sender's incarnation */
+	__u64		kshm_src_incarnation;
+	/* destination's incarnation */
+	__u64		kshm_dst_incarnation;
+	/* connection type */
+	__u32		kshm_ctype;
+	/* # IP addrs */
+	__u32		kshm_nips;
+	__u32		kshm_ips[0];
 } WIRE_ATTR ksock_hello_msg_t;
 
 typedef struct {
-	lnet_hdr_t	      ksnm_hdr;       /* lnet hdr */
-
-	/*
-	 * ksnm_payload is removed because of winnt compiler's limitation:
-	 * zero-sized array can only be placed at the tail of [nested]
-	 * structure definitions. lnet payload will be stored just after
-	 * the body of structure ksock_lnet_msg_t
-	 */
+	/* lnet hdr */
+	lnet_hdr_t	ksnm_hdr;
 } WIRE_ATTR ksock_lnet_msg_t;
 
 typedef struct {
-	__u32		   ksm_type;       /* type of socklnd message */
-	__u32		   ksm_csum;       /* checksum if != 0 */
-	__u64		   ksm_zc_cookies[2]; /* Zero-Copy request/ACK cookie */
+	/* type of socklnd message */
+	__u32			ksm_type;
+	/* checksum if != 0 */
+	__u32			ksm_csum;
+	/* Zero-Copy request/ACK cookie */
+	__u64			ksm_zc_cookies[2];
 	union {
-		ksock_lnet_msg_t lnetmsg;       /* lnet message, it's empty if it's NOOP */
+		/* lnet message, it's empty if it's NOOP */
+		ksock_lnet_msg_t lnetmsg;
 	} WIRE_ATTR ksm_u;
 } WIRE_ATTR ksock_msg_t;
 
 static inline void
 socklnd_init_msg(ksock_msg_t *msg, int type)
 {
-	msg->ksm_csum	   = 0;
-	msg->ksm_type	   = type;
-	msg->ksm_zc_cookies[0]  = msg->ksm_zc_cookies[1]  = 0;
+	msg->ksm_csum = 0;
+	msg->ksm_type = type;
+	msg->ksm_zc_cookies[0] = msg->ksm_zc_cookies[1] = 0;
 }
 
-#define KSOCK_MSG_NOOP	  0xc0	    /* ksm_u empty */
-#define KSOCK_MSG_LNET	  0xc1	    /* lnet msg */
+#define KSOCK_MSG_NOOP	0xc0	/* ksm_u empty */
+#define KSOCK_MSG_LNET	0xc1	/* lnet msg */
 
 /* We need to know this number to parse hello msg from ksocklnd in
  * other LND (usocklnd, for example) */
-#define KSOCK_PROTO_V2	  2
-#define KSOCK_PROTO_V3	  3
+#define KSOCK_PROTO_V2	2
+#define KSOCK_PROTO_V3	3
 
 #endif
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 68d8139..53997ae 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -15,11 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
+ * http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
@@ -27,11 +23,11 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2014 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
+ * Lustre is a trademark of Seagate, Inc.
  */
 
 #ifndef __LNET_TYPES_H__
@@ -48,7 +44,7 @@
 /** Portal reserved for LNet's own use.
  * \see lustre/include/lustre/lustre_idl.h for Lustre portal assignments.
  */
-#define LNET_RESERVED_PORTAL      0
+#define LNET_RESERVED_PORTAL	0
 
 /**
  * Address of an end-point in an LNet network.
@@ -74,8 +70,179 @@ typedef __u32 lnet_pid_t;
 
 #define LNET_PID_RESERVED 0xf0000000 /* reserved bits in PID */
 #define LNET_PID_USERFLAG 0x80000000 /* set in userspace peers */
+#define LNET_PID_LUSTRE	  12345
+
+#define LNET_TIME_FOREVER	(-1)
+
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
+#define WIRE_ATTR	__packed
+
+/* Packed version of lnet_process_id_t to transfer via network */
+typedef struct {
+	/* node id / process id */
+	lnet_nid_t nid;
+	lnet_pid_t pid;
+} WIRE_ATTR lnet_process_id_packed_t;
 
-#define LNET_TIME_FOREVER    (-1)
+/* The wire handle's interface cookie only matches one network interface in
+ * one epoch (i.e. new cookie when the interface restarts or the node
+ * reboots).  The object cookie only matches one object on that interface
+ * during that object's lifetime (i.e. no cookie re-use). */
+typedef struct {
+	__u64 wh_interface_cookie;
+	__u64 wh_object_cookie;
+} WIRE_ATTR lnet_handle_wire_t;
+
+typedef enum {
+	LNET_MSG_ACK = 0,
+	LNET_MSG_PUT,
+	LNET_MSG_GET,
+	LNET_MSG_REPLY,
+	LNET_MSG_HELLO,
+} lnet_msg_type_t;
+
+/* The variant fields of the portals message header are aligned on an 8
+ * byte boundary in the message header.  Note that all types used in these
+ * wire structs MUST be fixed size and the smaller types are placed@the
+ * end. */
+typedef struct lnet_ack {
+	lnet_handle_wire_t	dst_wmd;
+	__u64			match_bits;
+	__u32			mlength;
+} WIRE_ATTR lnet_ack_t;
+
+typedef struct lnet_put {
+	lnet_handle_wire_t	ack_wmd;
+	__u64			match_bits;
+	__u64			hdr_data;
+	__u32			ptl_index;
+	__u32			offset;
+} WIRE_ATTR lnet_put_t;
+
+typedef struct lnet_get {
+	lnet_handle_wire_t	return_wmd;
+	__u64			match_bits;
+	__u32			ptl_index;
+	__u32			src_offset;
+	__u32			sink_length;
+} WIRE_ATTR lnet_get_t;
+
+typedef struct lnet_reply {
+	lnet_handle_wire_t	dst_wmd;
+} WIRE_ATTR lnet_reply_t;
+
+typedef struct lnet_hello {
+	__u64			incarnation;
+	__u32			type;
+} WIRE_ATTR lnet_hello_t;
+
+typedef struct {
+	lnet_nid_t	dest_nid;
+	lnet_nid_t	src_nid;
+	lnet_pid_t	dest_pid;
+	lnet_pid_t	src_pid;
+	__u32		type;		/* lnet_msg_type_t */
+	__u32		payload_length;	/* payload data to follow */
+	/*<------__u64 aligned------->*/
+	union {
+		lnet_ack_t	ack;
+		lnet_put_t	put;
+		lnet_get_t	get;
+		lnet_reply_t	reply;
+		lnet_hello_t	hello;
+	} msg;
+} WIRE_ATTR lnet_hdr_t;
+
+/* A HELLO message contains a magic number and protocol version
+ * code in the header's dest_nid, the peer's NID in the src_nid, and
+ * LNET_MSG_HELLO in the type field.  All other common fields are zero
+ * (including payload_size; i.e. no payload).
+ * This is for use by byte-stream LNDs (e.g. TCP/IP) to check the peer is
+ * running the same protocol and to find out its NID. These LNDs should
+ * exchange HELLO messages when a connection is first established.  Individual
+ * LNDs can put whatever else they fancy in lnet_hdr_t::msg.
+ */
+typedef struct {
+	__u32	magic;		/* LNET_PROTO_TCP_MAGIC */
+	__u16	version_major;	/* increment on incompatible change */
+	__u16	version_minor;	/* increment on compatible change */
+} WIRE_ATTR lnet_magicversion_t;
+
+/* PROTO MAGIC for LNDs */
+#define LNET_PROTO_IB_MAGIC		0x0be91b91
+#define LNET_PROTO_GNI_MAGIC		0xb00fbabe /* ask Kim */
+#define LNET_PROTO_TCP_MAGIC		0xeebc0ded
+#define LNET_PROTO_ACCEPTOR_MAGIC	0xacce7100
+#define LNET_PROTO_PING_MAGIC		0x70696E67 /* 'ping' */
+
+/* Placeholder for a future "unified" protocol across all LNDs */
+/* Current LNDs that receive a request with this magic will respond with a
+ * "stub" reply using their current protocol */
+#define LNET_PROTO_MAGIC		0x45726963 /* ! */
+
+#define LNET_PROTO_TCP_VERSION_MAJOR	1
+#define LNET_PROTO_TCP_VERSION_MINOR	0
+
+/* Acceptor connection request */
+typedef struct {
+	__u32	acr_magic;		/* PTL_ACCEPTOR_PROTO_MAGIC */
+	__u32	acr_version;		/* protocol version */
+	__u64	acr_nid;		/* target NID */
+} WIRE_ATTR lnet_acceptor_connreq_t;
+
+#define LNET_PROTO_ACCEPTOR_VERSION	1
+
+typedef struct lnet_counters {
+	__u32	msgs_alloc;
+	__u32	msgs_max;
+	__u32	errors;
+	__u32	send_count;
+	__u32	recv_count;
+	__u32	route_count;
+	__u32	drop_count;
+	__u64	send_length;
+	__u64	recv_length;
+	__u64	route_length;
+	__u64	drop_length;
+} WIRE_ATTR lnet_counters_t;
+
+#define LNET_NI_STATUS_UP	0x15aac0de
+#define LNET_NI_STATUS_DOWN	0xdeadface
+#define LNET_NI_STATUS_INVALID	0x00000000
+
+#define LNET_MAX_INTERFACES	16
 
 /**
  * Objects maintained by the LNet are accessed through handles. Handle types
@@ -195,8 +362,8 @@ typedef struct {
 	 * one must start on page boundary, and all but the last must end on
 	 * page boundary.
 	 */
-	void	    *start;
-	unsigned int     length;
+	void		*start;
+	unsigned int	length;
 	/**
 	 * Specifies the maximum number of operations that can be performed
 	 * on the memory descriptor. An operation is any action that could
@@ -207,7 +374,7 @@ typedef struct {
 	 * there is no bound on the number of operations that may be applied
 	 * to a MD.
 	 */
-	int	      threshold;
+	int		threshold;
 	/**
 	 * Specifies the largest incoming request that the memory descriptor
 	 * should respond to. When the unused portion of a MD (length -
@@ -215,7 +382,7 @@ typedef struct {
 	 * does not respond to further operations. This value is only used
 	 * if the LNET_MD_MAX_SIZE option is set.
 	 */
-	int	      max_size;
+	int		max_size;
 	/**
 	 * Specifies the behavior of the memory descriptor. A bitwise OR
 	 * of the following values can be used:
@@ -252,14 +419,14 @@ typedef struct {
 	 *   region (i.e. sum of all fragment lengths) must not be less than
 	 *   \a max_size.
 	 */
-	unsigned int     options;
+	unsigned int	options;
 	/**
 	 * A user-specified value that is associated with the memory
 	 * descriptor. The value does not need to be a pointer, but must fit
 	 * in the space used by a pointer. This value is recorded in events
 	 * associated with operations on this MD.
 	 */
-	void	    *user_ptr;
+	void		*user_ptr;
 	/**
 	 * A handle for the event queue used to log the operations performed on
 	 * the memory region. If this argument is a NULL handle (i.e. nullified
@@ -276,44 +443,33 @@ typedef struct {
 #define LNET_MTU	(1 << LNET_MTU_BITS)
 
 /** limit on the number of fragments in discontiguous MDs */
-#define LNET_MAX_IOV    256
-
-/* Max payload size */
-# define LNET_MAX_PAYLOAD	CONFIG_LNET_MAX_PAYLOAD
-# if (LNET_MAX_PAYLOAD < LNET_MTU)
-#  error "LNET_MAX_PAYLOAD too small - error in configure --with-max-payload-mb"
-# else
-#  if (LNET_MAX_PAYLOAD > (PAGE_SIZE * LNET_MAX_IOV))
-/*  PAGE_SIZE is a constant: check with cpp! */
-#   error "LNET_MAX_PAYLOAD too large - error in configure --with-max-payload-mb"
-#  endif
-# endif
+#define LNET_MAX_IOV	256
 
 /**
  * Options for the MD structure. See lnet_md_t::options.
  */
-#define LNET_MD_OP_PUT	       (1 << 0)
+#define LNET_MD_OP_PUT		(1 << 0)
 /** See lnet_md_t::options. */
-#define LNET_MD_OP_GET	       (1 << 1)
+#define LNET_MD_OP_GET		(1 << 1)
 /** See lnet_md_t::options. */
 #define LNET_MD_MANAGE_REMOTE	(1 << 2)
-/* unused			    (1 << 3) */
+/* unused			(1 << 3) */
 /** See lnet_md_t::options. */
-#define LNET_MD_TRUNCATE	     (1 << 4)
+#define LNET_MD_TRUNCATE	(1 << 4)
 /** See lnet_md_t::options. */
-#define LNET_MD_ACK_DISABLE	  (1 << 5)
+#define LNET_MD_ACK_DISABLE	(1 << 5)
 /** See lnet_md_t::options. */
 #define LNET_MD_IOVEC		(1 << 6)
 /** See lnet_md_t::options. */
-#define LNET_MD_MAX_SIZE	     (1 << 7)
+#define LNET_MD_MAX_SIZE	(1 << 7)
 /** See lnet_md_t::options. */
-#define LNET_MD_KIOV		 (1 << 8)
+#define LNET_MD_KIOV		(1 << 8)
 
 /* For compatibility with Cray Portals */
-#define LNET_MD_PHYS			 0
+#define LNET_MD_PHYS		 0
 
 /** Infinite threshold on MD operations. See lnet_md_t::threshold */
-#define LNET_MD_THRESH_INF       (-1)
+#define LNET_MD_THRESH_INF	(-1)
 
 /* NB lustre portals uses struct iovec internally! */
 typedef struct iovec lnet_md_iovec_t;
@@ -323,15 +479,15 @@ typedef struct iovec lnet_md_iovec_t;
  */
 typedef struct {
 	/** Pointer to the page where the fragment resides */
-	struct page      *kiov_page;
+	struct page	*kiov_page;
 	/** Length in bytes of the fragment */
-	unsigned int     kiov_len;
+	unsigned int	kiov_len;
 	/**
 	 * Starting offset of the fragment within the page. Note that the
 	 * end of the fragment must not pass the end of the page; i.e.,
 	 * kiov_len + kiov_offset <= PAGE_CACHE_SIZE.
 	 */
-	unsigned int     kiov_offset;
+	unsigned int	kiov_offset;
 } lnet_kiov_t;
 /** @} lnet_md */
 
@@ -379,7 +535,7 @@ typedef enum {
 	LNET_EVENT_UNLINK,
 } lnet_event_kind_t;
 
-#define LNET_SEQ_BASETYPE       long
+#define LNET_SEQ_BASETYPE	long
 typedef unsigned LNET_SEQ_BASETYPE lnet_seq_t;
 #define LNET_SEQ_GT(a, b)	(((signed LNET_SEQ_BASETYPE)((a) - (b))) > 0)
 
@@ -388,23 +544,23 @@ typedef unsigned LNET_SEQ_BASETYPE lnet_seq_t;
  */
 typedef struct {
 	/** The identifier (nid, pid) of the target. */
-	lnet_process_id_t   target;
+	lnet_process_id_t	target;
 	/** The identifier (nid, pid) of the initiator. */
-	lnet_process_id_t   initiator;
+	lnet_process_id_t	initiator;
 	/**
 	 * The NID of the immediate sender. If the request has been forwarded
 	 * by routers, this is the NID of the last hop; otherwise it's the
 	 * same as the initiator.
 	 */
-	lnet_nid_t	  sender;
+	lnet_nid_t		sender;
 	/** Indicates the type of the event. */
-	lnet_event_kind_t   type;
+	lnet_event_kind_t	type;
 	/** The portal table index specified in the request */
-	unsigned int	pt_index;
+	unsigned int		pt_index;
 	/** A copy of the match bits specified in the request. */
-	__u64	       match_bits;
+	__u64			match_bits;
 	/** The length (in bytes) specified in the request. */
-	unsigned int	rlength;
+	unsigned int		rlength;
 	/**
 	 * The length (in bytes) of the data that was manipulated by the
 	 * operation. For truncated operations, the manipulated length will be
@@ -412,47 +568,47 @@ typedef struct {
 	 * see lnet_md_t). For all other operations, the manipulated length
 	 * will be the length of the requested operation, i.e. rlength.
 	 */
-	unsigned int	mlength;
+	unsigned int		mlength;
 	/**
 	 * The handle to the MD associated with the event. The handle may be
 	 * invalid if the MD has been unlinked.
 	 */
-	lnet_handle_md_t    md_handle;
+	lnet_handle_md_t	md_handle;
 	/**
 	 * A snapshot of the state of the MD immediately after the event has
 	 * been processed. In particular, the threshold field in md will
 	 * reflect the value of the threshold after the operation occurred.
 	 */
-	lnet_md_t	   md;
+	lnet_md_t		md;
 	/**
 	 * 64 bits of out-of-band user data. Only valid for LNET_EVENT_PUT.
 	 * \see LNetPut
 	 */
-	__u64	       hdr_data;
+	__u64			hdr_data;
 	/**
 	 * Indicates the completion status of the operation. It's 0 for
 	 * successful operations, otherwise it's an error code.
 	 */
-	int		 status;
+	int			status;
 	/**
 	 * Indicates whether the MD has been unlinked. Note that:
 	 * - An event with unlinked set is the last event on the MD.
 	 * - This field is also set for an explicit LNET_EVENT_UNLINK event.
 	 * \see LNetMDUnlink
 	 */
-	int		 unlinked;
+	int			unlinked;
 	/**
 	 * The displacement (in bytes) into the memory region that the
 	 * operation used. The offset can be determined by the operation for
 	 * a remote managed MD or by the local MD.
 	 * \see lnet_md_t::options
 	 */
-	unsigned int	offset;
+	unsigned int		offset;
 	/**
 	 * The sequence number for this event. Sequence numbers are unique
 	 * to each event.
 	 */
-	volatile lnet_seq_t sequence;
+	volatile lnet_seq_t	sequence;
 } lnet_event_t;
 
 /**
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index be4de56..8a3341e 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1177,7 +1177,7 @@ void kiblnd_map_rx_descs(kib_conn_t *conn)
 
 		CDEBUG(D_NET, "rx %d: %p %#llx(%#llx)\n",
 		       i, rx->rx_msg, rx->rx_msgaddr,
-		       lnet_page2phys(pg) + pg_off);
+		       (__u64)(page_to_phys(pg) + pg_off));
 
 		pg_off += IBLND_MSG_SIZE;
 		LASSERT(pg_off <= PAGE_SIZE);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index cd664d0..32b39a4 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -62,16 +62,15 @@
 
 #define DEBUG_SUBSYSTEM S_LND
 
-#include "../../../include/linux/libcfs/libcfs.h"
-#include "../../../include/linux/lnet/lnet.h"
-#include "../../../include/linux/lnet/lib-lnet.h"
-#include "../../../include/linux/lnet/lnet-sysctl.h"
-
 #include <rdma/rdma_cm.h>
 #include <rdma/ib_cm.h>
 #include <rdma/ib_verbs.h>
 #include <rdma/ib_fmr_pool.h>
 
+#include "../../../include/linux/libcfs/libcfs.h"
+#include "../../../include/linux/lnet/lnet.h"
+#include "../../../include/linux/lnet/lib-lnet.h"
+
 #define IBLND_PEER_HASH_SIZE		101	/* # peer lists */
 /* # scheduler loops before reschedule */
 #define IBLND_RESCHED			100
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index f3b4923..8798e49 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -34,7 +34,6 @@
 #include "../../../include/linux/lnet/lnet.h"
 #include "../../../include/linux/lnet/lib-lnet.h"
 #include "../../../include/linux/lnet/socklnd.h"
-#include "../../../include/linux/lnet/lnet-sysctl.h"
 
 #define SOCKNAL_PEER_HASH_SIZE  101	     /* # peer lists */
 #define SOCKNAL_RESCHED	 100	     /* # scheduler loops before reschedule */
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c
index a93f59c..df0f7d8 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c
@@ -148,8 +148,8 @@ ksocknal_lib_send_kiov(ksock_conn_t *conn, ksock_tx_t *tx)
 			rc = sk->sk_prot->sendpage(sk, page,
 						   offset, fragsize, msgflg);
 		} else {
-			rc = cfs_tcp_sendpage(sk, page, offset, fragsize,
-					      msgflg);
+			rc = tcp_sendpage(sk, page, offset, fragsize,
+					  msgflg);
 		}
 	} else {
 #if SOCKNAL_SINGLE_FRAG_TX || !SOCKNAL_RISK_KMAP_DEADLOCK
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index bd97099..c44d3e0 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -243,8 +243,6 @@ lnet_accept(struct socket *sock, __u32 magic)
 
 		if (magic == le32_to_cpu(LNET_PROTO_TCP_MAGIC))
 			str = "'old' socknal/tcpnal";
-		else if (lnet_accept_magic(magic, LNET_PROTO_RA_MAGIC))
-			str = "'old' ranal";
 		else
 			str = "unrecognised";
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 4a14e51..f9ae9e5 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -364,56 +364,6 @@ lnet_counters_reset(void)
 }
 EXPORT_SYMBOL(lnet_counters_reset);
 
-#ifdef LNET_USE_LIB_FREELIST
-
-int
-lnet_freelist_init(lnet_freelist_t *fl, int n, int size)
-{
-	char *space;
-
-	LASSERT(n > 0);
-
-	size += offsetof(lnet_freeobj_t, fo_contents);
-
-	LIBCFS_ALLOC(space, n * size);
-	if (space == NULL)
-		return -ENOMEM;
-
-	INIT_LIST_HEAD(&fl->fl_list);
-	fl->fl_objs = space;
-	fl->fl_nobjs = n;
-	fl->fl_objsize = size;
-
-	do {
-		memset(space, 0, size);
-		list_add((struct list_head *)space, &fl->fl_list);
-		space += size;
-	} while (--n != 0);
-
-	return 0;
-}
-
-void
-lnet_freelist_fini(lnet_freelist_t *fl)
-{
-	struct list_head       *el;
-	int	       count;
-
-	if (fl->fl_nobjs == 0)
-		return;
-
-	count = 0;
-	for (el = fl->fl_list.next; el != &fl->fl_list; el = el->next)
-		count++;
-
-	LASSERT(count == fl->fl_nobjs);
-
-	LIBCFS_FREE(fl->fl_objs, fl->fl_nobjs * fl->fl_objsize);
-	memset(fl, 0, sizeof(*fl));
-}
-
-#endif /* LNET_USE_LIB_FREELIST */
-
 static __u64
 lnet_create_interface_cookie(void)
 {
@@ -470,9 +420,6 @@ lnet_res_container_cleanup(struct lnet_res_container *rec)
 		       count, lnet_res_type2str(rec->rec_type));
 	}
 
-#ifdef LNET_USE_LIB_FREELIST
-	lnet_freelist_fini(&rec->rec_freelist);
-#endif
 	if (rec->rec_lh_hash != NULL) {
 		LIBCFS_FREE(rec->rec_lh_hash,
 			    LNET_LH_HASH_SIZE * sizeof(rec->rec_lh_hash[0]));
@@ -483,8 +430,7 @@ lnet_res_container_cleanup(struct lnet_res_container *rec)
 }
 
 static int
-lnet_res_container_setup(struct lnet_res_container *rec,
-			 int cpt, int type, int objnum, int objsz)
+lnet_res_container_setup(struct lnet_res_container *rec, int cpt, int type)
 {
 	int	rc = 0;
 	int	i;
@@ -494,12 +440,6 @@ lnet_res_container_setup(struct lnet_res_container *rec,
 	rec->rec_type = type;
 	INIT_LIST_HEAD(&rec->rec_active);
 
-#ifdef LNET_USE_LIB_FREELIST
-	memset(&rec->rec_freelist, 0, sizeof(rec->rec_freelist));
-	rc = lnet_freelist_init(&rec->rec_freelist, objnum, objsz);
-	if (rc != 0)
-		goto out;
-#endif
 	rec->rec_lh_cookie = (cpt << LNET_COOKIE_TYPE_BITS) | type;
 
 	/* Arbitrary choice of hash table size */
@@ -535,7 +475,7 @@ lnet_res_containers_destroy(struct lnet_res_container **recs)
 }
 
 static struct lnet_res_container **
-lnet_res_containers_create(int type, int objnum, int objsz)
+lnet_res_containers_create(int type)
 {
 	struct lnet_res_container	**recs;
 	struct lnet_res_container	*rec;
@@ -550,7 +490,7 @@ lnet_res_containers_create(int type, int objnum, int objsz)
 	}
 
 	cfs_percpt_for_each(rec, i, recs) {
-		rc = lnet_res_container_setup(rec, i, type, objnum, objsz);
+		rc = lnet_res_container_setup(rec, i, type);
 		if (rc != 0) {
 			lnet_res_containers_destroy(recs);
 			return NULL;
@@ -597,7 +537,6 @@ lnet_res_lh_initialize(struct lnet_res_container *rec, lnet_libhandle_t *lh)
 	list_add(&lh->lh_hash_chain, &rec->rec_lh_hash[hash]);
 }
 
-
 int lnet_unprepare(void);
 
 static int
@@ -643,13 +582,11 @@ lnet_prepare(lnet_pid_t requested_pid)
 		goto failed;
 
 	rc = lnet_res_container_setup(&the_lnet.ln_eq_container, 0,
-				      LNET_COOKIE_TYPE_EQ, LNET_FL_MAX_EQS,
-				      sizeof(lnet_eq_t));
+				      LNET_COOKIE_TYPE_EQ);
 	if (rc != 0)
 		goto failed;
 
-	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_ME, LNET_FL_MAX_MES,
-					  sizeof(lnet_me_t));
+	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_ME);
 	if (recs == NULL) {
 		rc = -ENOMEM;
 		goto failed;
@@ -657,8 +594,7 @@ lnet_prepare(lnet_pid_t requested_pid)
 
 	the_lnet.ln_me_containers = recs;
 
-	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_MD, LNET_FL_MAX_MDS,
-					  sizeof(lnet_libmd_t));
+	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_MD);
 	if (recs == NULL) {
 		rc = -ENOMEM;
 		goto failed;
@@ -1171,15 +1107,14 @@ lnet_startup_lndnis(void)
 /**
  * Initialize LNet library.
  *
- * Only userspace program needs to call this function - it's automatically
- * called in the kernel at module loading time. Caller has to call LNetFini()
- * after a call to LNetInit(), if and only if the latter returned 0. It must
- * be called exactly once.
+ * Automatically called at module loading time. Caller has to call
+ * lnet_fini() after a call to lnet_init(), if and only if the latter
+ * returned 0. It must be called exactly once.
  *
  * \return 0 on success, and -ve on failures.
  */
 int
-LNetInit(void)
+lnet_init(void)
 {
 	int	rc;
 
@@ -1232,19 +1167,16 @@ LNetInit(void)
 	lnet_register_lnd(&the_lolnd);
 	return 0;
 }
-EXPORT_SYMBOL(LNetInit);
+EXPORT_SYMBOL(lnet_init);
 
 /**
  * Finalize LNet library.
  *
- * Only userspace program needs to call this function. It can be called
- * at most once.
- *
- * \pre LNetInit() called with success.
- * \pre All LNet users called LNetNIFini() for matching LNetNIInit() calls.
+ * \pre lnet_init() called with success.
+ * \pre All LNet users called lnet_fini() for matching lnet_init() calls.
  */
 void
-LNetFini(void)
+lnet_fini(void)
 {
 	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount == 0);
@@ -1256,7 +1188,7 @@ LNetFini(void)
 
 	the_lnet.ln_init = 0;
 }
-EXPORT_SYMBOL(LNetFini);
+EXPORT_SYMBOL(lnet_fini);
 
 /**
  * Set LNet PID and start LNet interfaces, routing, and forwarding.
@@ -1290,8 +1222,6 @@ LNetNIInit(lnet_pid_t requested_pid)
 		goto out;
 	}
 
-	lnet_get_tunables();
-
 	if (requested_pid == LNET_PID_ANY) {
 		/* Don't instantiate LNET just for me */
 		rc = -ENETDOWN;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index 5470148..fabca5d 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -191,7 +191,7 @@ LNetEQFree(lnet_handle_eq_t eqh)
 
 	lnet_res_lh_invalidate(&eq->eq_lh);
 	list_del(&eq->eq_list);
-	lnet_eq_free_locked(eq);
+	lnet_eq_free(eq);
  out:
 	lnet_eq_wait_unlock();
 	lnet_res_unlock(LNET_LOCK_EX);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 89d660f..57ede1b 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -82,7 +82,7 @@ lnet_md_unlink(lnet_libmd_t *md)
 
 	LASSERT(!list_empty(&md->md_list));
 	list_del_init(&md->md_list);
-	lnet_md_free_locked(md);
+	lnet_md_free(md);
 }
 
 static int
@@ -320,7 +320,7 @@ LNetMDAttach(lnet_handle_me_t meh, lnet_md_t umd,
 	return 0;
 
  failed:
-	lnet_md_free_locked(md);
+	lnet_md_free(md);
 
 	lnet_res_unlock(cpt);
 	return rc;
@@ -381,7 +381,7 @@ LNetMDBind(lnet_md_t umd, lnet_unlink_t unlink, lnet_handle_md_t *handle)
 	return 0;
 
  failed:
-	lnet_md_free_locked(md);
+	lnet_md_free(md);
 
 	lnet_res_unlock(cpt);
 	return rc;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index a3f9292..823df95 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -172,7 +172,7 @@ LNetMEInsert(lnet_handle_me_t current_meh,
 
 	current_me = lnet_handle2me(&current_meh);
 	if (current_me == NULL) {
-		lnet_me_free_locked(new_me);
+		lnet_me_free(new_me);
 
 		lnet_res_unlock(cpt);
 		return -ENOENT;
@@ -183,7 +183,7 @@ LNetMEInsert(lnet_handle_me_t current_meh,
 	ptl = the_lnet.ln_portals[current_me->me_portal];
 	if (lnet_ptl_is_unique(ptl)) {
 		/* nosense to insertion on unique portal */
-		lnet_me_free_locked(new_me);
+		lnet_me_free(new_me);
 		lnet_res_unlock(cpt);
 		return -EPERM;
 	}
@@ -276,23 +276,5 @@ lnet_me_unlink(lnet_me_t *me)
 	}
 
 	lnet_res_lh_invalidate(&me->me_lh);
-	lnet_me_free_locked(me);
+	lnet_me_free(me);
 }
-
-#if 0
-static void
-lib_me_dump(lnet_me_t *me)
-{
-	CWARN("Match Entry %p (%#llx)\n", me,
-	      me->me_lh.lh_cookie);
-
-	CWARN("\tMatch/Ignore\t= %016lx / %016lx\n",
-	      me->me_match_bits, me->me_ignore_bits);
-
-	CWARN("\tMD\t= %p\n", me->md);
-	CWARN("\tprev\t= %p\n",
-	      list_entry(me->me_list.prev, lnet_me_t, me_list));
-	CWARN("\tnext\t= %p\n",
-	      list_entry(me->me_list.next, lnet_me_t, me_list));
-}
-#endif
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index a46ccbf..41a5900 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -427,7 +427,7 @@ lnet_complete_msg_locked(lnet_msg_t *msg, int cpt)
 	}
 
 	lnet_msg_decommit(msg, cpt, status);
-	lnet_msg_free_locked(msg);
+	lnet_msg_free(msg);
 	return 0;
 }
 
@@ -559,35 +559,17 @@ lnet_msg_container_cleanup(struct lnet_msg_container *container)
 			    sizeof(*container->msc_finalizers));
 		container->msc_finalizers = NULL;
 	}
-#ifdef LNET_USE_LIB_FREELIST
-	lnet_freelist_fini(&container->msc_freelist);
-#endif
 	container->msc_init = 0;
 }
 
 int
 lnet_msg_container_setup(struct lnet_msg_container *container, int cpt)
 {
-	int	rc;
-
 	container->msc_init = 1;
 
 	INIT_LIST_HEAD(&container->msc_active);
 	INIT_LIST_HEAD(&container->msc_finalizing);
 
-#ifdef LNET_USE_LIB_FREELIST
-	memset(&container->msc_freelist, 0, sizeof(lnet_freelist_t));
-
-	rc = lnet_freelist_init(&container->msc_freelist,
-				LNET_FL_MAX_MSGS, sizeof(lnet_msg_t));
-	if (rc != 0) {
-		CERROR("Failed to init freelist for message container\n");
-		lnet_msg_container_cleanup(container);
-		return rc;
-	}
-#else
-	rc = 0;
-#endif
 	/* number of CPUs */
 	container->msc_nfinalizers = cfs_cpt_weight(lnet_cpt_table(), cpt);
 
@@ -601,7 +583,7 @@ lnet_msg_container_setup(struct lnet_msg_container *container, int cpt)
 		return -ENOMEM;
 	}
 
-	return rc;
+	return 0;
 }
 
 void
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 72b7fbc..bc74738 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -117,7 +117,7 @@ init_lnet(void)
 
 	mutex_init(&lnet_config_mutex);
 
-	rc = LNetInit();
+	rc = lnet_init();
 	if (rc != 0) {
 		CERROR("LNetInit: error %d\n", rc);
 		return rc;
@@ -143,7 +143,7 @@ fini_lnet(void)
 	rc = libcfs_deregister_ioctl(&lnet_ioctl_handler);
 	LASSERT(rc == 0);
 
-	LNetFini();
+	lnet_fini();
 }
 
 MODULE_AUTHOR("Peter J. Braam <braam@clusterfs.com>");
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 8510bae..6acaaae 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -24,8 +24,6 @@
 #define DEBUG_SUBSYSTEM S_LNET
 #include "../../include/linux/lnet/lib-lnet.h"
 
-#if  defined(LNET_ROUTER)
-
 #define LNET_NRB_TINY_MIN	512	/* min value for each CPT */
 #define LNET_NRB_TINY		(LNET_NRB_TINY_MIN * 4)
 #define LNET_NRB_SMALL_MIN	4096	/* min value for each CPT */
@@ -70,15 +68,6 @@ lnet_peer_buffer_credits(lnet_ni_t *ni)
 
 /* forward ref's */
 static int lnet_router_checker(void *);
-#else
-
-int
-lnet_peer_buffer_credits(lnet_ni_t *ni)
-{
-	return 0;
-}
-
-#endif
 
 static int check_routers_before_use;
 module_param(check_routers_before_use, int, 0444);
@@ -1163,9 +1152,6 @@ lnet_prune_rc_data(int wait_unlink)
 	lnet_net_unlock(LNET_LOCK_EX);
 }
 
-
-#if  defined(LNET_ROUTER)
-
 static int
 lnet_router_checker(void *arg)
 {
@@ -1573,134 +1559,3 @@ lnet_notify(lnet_ni_t *ni, lnet_nid_t nid, int alive, unsigned long when)
 	return 0;
 }
 EXPORT_SYMBOL(lnet_notify);
-
-void
-lnet_get_tunables(void)
-{
-}
-
-#else
-
-int
-lnet_notify(lnet_ni_t *ni, lnet_nid_t nid, int alive, unsigned long when)
-{
-	return -EOPNOTSUPP;
-}
-
-void
-lnet_router_checker(void)
-{
-	static time_t last;
-	static int    running;
-
-	time_t	    now = get_seconds();
-	int	       interval = now - last;
-	int	       rc;
-	__u64	     version;
-	lnet_peer_t      *rtr;
-
-	/* It's no use to call me again within a sec - all intervals and
-	 * timeouts are measured in seconds */
-	if (last != 0 && interval < 2)
-		return;
-
-	if (last != 0 &&
-	    interval > max(live_router_check_interval,
-			   dead_router_check_interval))
-		CNETERR("Checker(%d/%d) not called for %d seconds\n",
-			live_router_check_interval, dead_router_check_interval,
-			interval);
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-
-	lnet_net_lock(0);
-	LASSERT(!running); /* recursion check */
-	running = 1;
-	lnet_net_unlock(0);
-
-	last = now;
-
-	if (the_lnet.ln_rc_state == LNET_RC_STATE_STOPPING)
-		lnet_prune_rc_data(0); /* unlink all rcd and nowait */
-
-	/* consume all pending events */
-	while (1) {
-		int	  i;
-		lnet_event_t ev;
-
-		/* NB ln_rc_eqh must be the 1st in 'eventqs' otherwise the
-		 * recursion breaker in LNetEQPoll would fail */
-		rc = LNetEQPoll(&the_lnet.ln_rc_eqh, 1, 0, &ev, &i);
-		if (rc == 0)   /* no event pending */
-			break;
-
-		/* NB a lost SENT prevents me from pinging a router again */
-		if (rc == -EOVERFLOW) {
-			CERROR("Dropped an event!!!\n");
-			abort();
-		}
-
-		LASSERT(rc == 1);
-
-		lnet_router_checker_event(&ev);
-	}
-
-	if (the_lnet.ln_rc_state == LNET_RC_STATE_STOPPING) {
-		lnet_prune_rc_data(1); /* release rcd */
-		the_lnet.ln_rc_state = LNET_RC_STATE_SHUTDOWN;
-		running = 0;
-		return;
-	}
-
-	LASSERT(the_lnet.ln_rc_state == LNET_RC_STATE_RUNNING);
-
-	lnet_net_lock(0);
-
-	version = the_lnet.ln_routers_version;
-	list_for_each_entry(rtr, &the_lnet.ln_routers, lp_rtr_list) {
-		lnet_ping_router_locked(rtr);
-		LASSERT(version == the_lnet.ln_routers_version);
-	}
-
-	lnet_net_unlock(0);
-
-	running = 0; /* lock only needed for the recursion check */
-}
-
-/* NB lnet_peers_start_down depends on me,
- * so must be called before any peer creation */
-void
-lnet_get_tunables(void)
-{
-	char *s;
-
-	s = getenv("LNET_ROUTER_PING_TIMEOUT");
-	if (s != NULL)
-		router_ping_timeout = atoi(s);
-
-	s = getenv("LNET_LIVE_ROUTER_CHECK_INTERVAL");
-	if (s != NULL)
-		live_router_check_interval = atoi(s);
-
-	s = getenv("LNET_DEAD_ROUTER_CHECK_INTERVAL");
-	if (s != NULL)
-		dead_router_check_interval = atoi(s);
-
-	/* This replaces old lnd_notify mechanism */
-	check_routers_before_use = 1;
-	if (dead_router_check_interval <= 0)
-		dead_router_check_interval = 30;
-}
-
-void
-lnet_rtrpools_free(void)
-{
-}
-
-int
-lnet_rtrpools_alloc(int im_a_arouter)
-{
-	return 0;
-}
-
-#endif
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index e2805bd..b32bc54 100644
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
