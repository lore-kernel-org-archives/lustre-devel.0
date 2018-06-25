From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 Jun 2018 17:42:53 -0400
Subject: [lustre-devel] [PATCH v2 4/7] lustre: libcfs: merge
 linux-tracefile.c into tracefile.c
In-Reply-To: <1529962976-15048-1-git-send-email-jsimmons@infradead.org>
References: <1529962976-15048-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529962976-15048-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

It's good to keep related code together. The merger exposed the
flaws of cfs_print_to_console() so rework it to behavior properly.

Signed-off-by: NeilBrown <neilb@suse.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/Makefile        |   2 +-
 .../staging/lustre/lnet/libcfs/linux-tracefile.c   | 194 ---------------------
 drivers/staging/lustre/lnet/libcfs/tracefile.c     | 184 ++++++++++++++++---
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |  79 ++-------
 4 files changed, 170 insertions(+), 289 deletions(-)
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux-tracefile.c

diff --git a/drivers/staging/lustre/lnet/libcfs/Makefile b/drivers/staging/lustre/lnet/libcfs/Makefile
index 5b13edc..cd96434 100644
--- a/drivers/staging/lustre/lnet/libcfs/Makefile
+++ b/drivers/staging/lustre/lnet/libcfs/Makefile
@@ -4,7 +4,7 @@ ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LNET) += libcfs.o
 
-libcfs-obj-y += linux-tracefile.o linux-debug.o
+libcfs-obj-y += linux-debug.o
 libcfs-obj-y += linux-crypto.o
 libcfs-obj-y += linux-crypto-adler.o
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
deleted file mode 100644
index 3af7722..0000000
--- a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
+++ /dev/null
@@ -1,194 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
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
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#define DEBUG_SUBSYSTEM S_LNET
-#define LUSTRE_TRACEFILE_PRIVATE
-
-#include <linux/slab.h>
-#include <linux/mm.h>
-#include "tracefile.h"
-
-/* percents to share the total debug memory for each type */
-static unsigned int pages_factor[CFS_TCD_TYPE_MAX] = {
-	80,  /* 80% pages for CFS_TCD_TYPE_PROC */
-	10,  /* 10% pages for CFS_TCD_TYPE_SOFTIRQ */
-	10   /* 10% pages for CFS_TCD_TYPE_IRQ */
-};
-
-char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
-
-int cfs_tracefile_init_arch(void)
-{
-	int i;
-	int j;
-	struct cfs_trace_cpu_data *tcd;
-
-	/* initialize trace_data */
-	memset(cfs_trace_data, 0, sizeof(cfs_trace_data));
-	for (i = 0; i < CFS_TCD_TYPE_MAX; i++) {
-		cfs_trace_data[i] =
-			kmalloc_array(num_possible_cpus(),
-				      sizeof(union cfs_trace_data_union),
-				      GFP_KERNEL);
-		if (!cfs_trace_data[i])
-			goto out;
-	}
-
-	/* arch related info initialized */
-	cfs_tcd_for_each(tcd, i, j) {
-		spin_lock_init(&tcd->tcd_lock);
-		tcd->tcd_pages_factor = pages_factor[i];
-		tcd->tcd_type = i;
-		tcd->tcd_cpu = j;
-	}
-
-	for (i = 0; i < num_possible_cpus(); i++)
-		for (j = 0; j < 3; j++) {
-			cfs_trace_console_buffers[i][j] =
-				kmalloc(CFS_TRACE_CONSOLE_BUFFER_SIZE,
-					GFP_KERNEL);
-
-			if (!cfs_trace_console_buffers[i][j])
-				goto out;
-		}
-
-	return 0;
-
-out:
-	cfs_tracefile_fini_arch();
-	pr_err("lnet: Not enough memory\n");
-	return -ENOMEM;
-}
-
-void cfs_tracefile_fini_arch(void)
-{
-	int i;
-	int j;
-
-	for (i = 0; i < num_possible_cpus(); i++)
-		for (j = 0; j < 3; j++) {
-			kfree(cfs_trace_console_buffers[i][j]);
-			cfs_trace_console_buffers[i][j] = NULL;
-		}
-
-	for (i = 0; cfs_trace_data[i]; i++) {
-		kfree(cfs_trace_data[i]);
-		cfs_trace_data[i] = NULL;
-	}
-}
-
-enum cfs_trace_buf_type cfs_trace_buf_idx_get(void)
-{
-	if (in_irq())
-		return CFS_TCD_TYPE_IRQ;
-	if (in_softirq())
-		return CFS_TCD_TYPE_SOFTIRQ;
-	return CFS_TCD_TYPE_PROC;
-}
-
-void
-cfs_set_ptldebug_header(struct ptldebug_header *header,
-			struct libcfs_debug_msg_data *msgdata,
-			unsigned long stack)
-{
-	struct timespec64 ts;
-
-	ktime_get_real_ts64(&ts);
-
-	header->ph_subsys = msgdata->msg_subsys;
-	header->ph_mask = msgdata->msg_mask;
-	header->ph_cpu_id = smp_processor_id();
-	header->ph_type = cfs_trace_buf_idx_get();
-	/* y2038 safe since all user space treats this as unsigned, but
-	 * will overflow in 2106
-	 */
-	header->ph_sec = (u32)ts.tv_sec;
-	header->ph_usec = ts.tv_nsec / NSEC_PER_USEC;
-	header->ph_stack = stack;
-	header->ph_pid = current->pid;
-	header->ph_line_num = msgdata->msg_line;
-	header->ph_extern_pid = 0;
-}
-
-static char *
-dbghdr_to_err_string(struct ptldebug_header *hdr)
-{
-	switch (hdr->ph_subsys) {
-	case S_LND:
-	case S_LNET:
-		return "LNetError";
-	default:
-		return "LustreError";
-	}
-}
-
-static char *
-dbghdr_to_info_string(struct ptldebug_header *hdr)
-{
-	switch (hdr->ph_subsys) {
-	case S_LND:
-	case S_LNET:
-		return "LNet";
-	default:
-		return "Lustre";
-	}
-}
-
-void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
-			  const char *buf, int len, const char *file,
-			  const char *fn)
-{
-	char *prefix = "Lustre", *ptype = NULL;
-
-	if (mask & D_EMERG) {
-		prefix = dbghdr_to_err_string(hdr);
-		ptype = KERN_EMERG;
-	} else if (mask & D_ERROR) {
-		prefix = dbghdr_to_err_string(hdr);
-		ptype = KERN_ERR;
-	} else if (mask & D_WARNING) {
-		prefix = dbghdr_to_info_string(hdr);
-		ptype = KERN_WARNING;
-	} else if (mask & (D_CONSOLE | libcfs_printk)) {
-		prefix = dbghdr_to_info_string(hdr);
-		ptype = KERN_INFO;
-	}
-
-	if (mask & D_CONSOLE) {
-		pr_info("%s%s: %.*s", ptype, prefix, len, buf);
-	} else {
-		pr_info("%s%s: %d:%d:(%s:%d:%s()) %.*s", ptype, prefix,
-			hdr->ph_pid, hdr->ph_extern_pid, file,
-			hdr->ph_line_num, fn, len, buf);
-	}
-}
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 6d567a9..229bbb8 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -37,8 +37,6 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
-#define LUSTRE_TRACEFILE_PRIVATE
-#define pr_fmt(fmt) "Lustre: " fmt
 
 #include <linux/ratelimit.h>
 #include <linux/highmem.h>
@@ -49,9 +47,19 @@
 #include <linux/uaccess.h>
 #include "tracefile.h"
 
-/* XXX move things up to the top, comment */
+#define CFS_TRACE_CONSOLE_BUFFER_SIZE	1024
+#define TCD_MAX_TYPES			8
+
+enum cfs_trace_buf_type {
+	CFS_TCD_TYPE_PROC = 0,
+	CFS_TCD_TYPE_SOFTIRQ,
+	CFS_TCD_TYPE_IRQ,
+	CFS_TCD_TYPE_MAX
+};
+
 union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS] __cacheline_aligned;
 
+char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
 char cfs_tracefile[TRACEFILE_NAME_SIZE];
 long long cfs_tracefile_size = CFS_TRACEFILE_SIZE;
 static struct tracefiled_ctl trace_tctl;
@@ -145,11 +153,35 @@ void cfs_trace_unlock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
 		spin_unlock(&tcd->tcd_lock);
 }
 
-#define cfs_tcd_for_each_type_lock(tcd, i, cpu)			   \
+#define cfs_tcd_for_each(tcd, i, j)					\
+	for (i = 0; cfs_trace_data[i]; i++)				\
+		for (j = 0, ((tcd) = &(*cfs_trace_data[i])[j].tcd);	\
+		     j < num_possible_cpus();				\
+		     j++, (tcd) = &(*cfs_trace_data[i])[j].tcd)
+
+
+#define cfs_tcd_for_each_type_lock(tcd, i, cpu)				\
 	for (i = 0; cfs_trace_data[i] &&				\
 	     (tcd = &(*cfs_trace_data[i])[cpu].tcd) &&			\
 	     cfs_trace_lock_tcd(tcd, 1); cfs_trace_unlock_tcd(tcd, 1), i++)
 
+enum cfs_trace_buf_type cfs_trace_buf_idx_get(void)
+{
+	if (in_irq())
+		return CFS_TCD_TYPE_IRQ;
+	if (in_softirq())
+		return CFS_TCD_TYPE_SOFTIRQ;
+	return CFS_TCD_TYPE_PROC;
+}
+
+static inline char *cfs_trace_get_console_buffer(void)
+{
+	unsigned int i = get_cpu();
+	unsigned int j = cfs_trace_buf_idx_get();
+
+	return cfs_trace_console_buffers[i][j];
+}
+
 static inline struct cfs_trace_cpu_data *
 cfs_trace_get_tcd(void)
 {
@@ -168,6 +200,77 @@ static inline void cfs_trace_put_tcd(struct cfs_trace_cpu_data *tcd)
 	put_cpu();
 }
 
+/* percents to share the total debug memory for each type */
+static unsigned int pages_factor[CFS_TCD_TYPE_MAX] = {
+	80,  /* 80% pages for CFS_TCD_TYPE_PROC */
+	10,  /* 10% pages for CFS_TCD_TYPE_SOFTIRQ */
+	10   /* 10% pages for CFS_TCD_TYPE_IRQ */
+};
+
+int cfs_tracefile_init_arch(void)
+{
+	struct cfs_trace_cpu_data *tcd;
+	int i;
+	int j;
+
+	/* initialize trace_data */
+	memset(cfs_trace_data, 0, sizeof(cfs_trace_data));
+	for (i = 0; i < CFS_TCD_TYPE_MAX; i++) {
+		cfs_trace_data[i] =
+			kmalloc_array(num_possible_cpus(),
+				      sizeof(union cfs_trace_data_union),
+				      GFP_KERNEL);
+		if (!cfs_trace_data[i])
+			goto out_trace_data;
+	}
+
+	/* arch related info initialized */
+	cfs_tcd_for_each(tcd, i, j) {
+		spin_lock_init(&tcd->tcd_lock);
+		tcd->tcd_pages_factor = pages_factor[i];
+		tcd->tcd_type = i;
+		tcd->tcd_cpu = j;
+	}
+
+	for (i = 0; i < num_possible_cpus(); i++)
+		for (j = 0; j < 3; j++) {
+			cfs_trace_console_buffers[i][j] =
+				kmalloc(CFS_TRACE_CONSOLE_BUFFER_SIZE,
+					GFP_KERNEL);
+
+			if (!cfs_trace_console_buffers[i][j])
+				goto out_buffers;
+		}
+
+	return 0;
+
+out_buffers:
+	for (i = 0; cfs_trace_data[i]; i++) {
+		kfree(cfs_trace_data[i]);
+		cfs_trace_data[i] = NULL;
+	}
+out_trace_data:
+	pr_err("lnet: Not enough memory\n");
+	return -ENOMEM;
+}
+
+void cfs_tracefile_fini_arch(void)
+{
+	int i;
+	int j;
+
+	for (i = 0; i < num_possible_cpus(); i++)
+		for (j = 0; j < 3; j++) {
+			kfree(cfs_trace_console_buffers[i][j]);
+			cfs_trace_console_buffers[i][j] = NULL;
+		}
+
+	for (i = 0; cfs_trace_data[i]; i++) {
+		kfree(cfs_trace_data[i]);
+		cfs_trace_data[i] = NULL;
+	}
+}
+
 static inline struct cfs_trace_page *
 cfs_tage_from_list(struct list_head *list)
 {
@@ -216,27 +319,6 @@ static void cfs_tage_to_tail(struct cfs_trace_page *tage,
 	list_move_tail(&tage->linkage, queue);
 }
 
-int cfs_trace_refill_stock(struct cfs_trace_cpu_data *tcd, gfp_t gfp,
-			   struct list_head *stock)
-{
-	int i;
-
-	/*
-	 * XXX nikita: do NOT call portals_debug_msg() (CDEBUG/ENTRY/EXIT)
-	 * from here: this will lead to infinite recursion.
-	 */
-
-	for (i = 0; i + tcd->tcd_cur_stock_pages < TCD_STOCK_PAGES ; ++i) {
-		struct cfs_trace_page *tage;
-
-		tage = cfs_tage_alloc(gfp);
-		if (!tage)
-			break;
-		list_add_tail(&tage->linkage, stock);
-	}
-	return i;
-}
-
 /* return a page that has 'len' bytes left at the end */
 static struct cfs_trace_page *
 cfs_trace_get_tage_try(struct cfs_trace_cpu_data *tcd, unsigned long len)
@@ -340,6 +422,57 @@ static struct cfs_trace_page *cfs_trace_get_tage(struct cfs_trace_cpu_data *tcd,
 	return tage;
 }
 
+
+
+static void cfs_set_ptldebug_header(struct ptldebug_header *header,
+				    struct libcfs_debug_msg_data *msgdata,
+				    unsigned long stack)
+{
+	struct timespec64 ts;
+
+	ktime_get_real_ts64(&ts);
+
+	header->ph_subsys = msgdata->msg_subsys;
+	header->ph_mask = msgdata->msg_mask;
+	header->ph_cpu_id = smp_processor_id();
+	header->ph_type = cfs_trace_buf_idx_get();
+	/* y2038 safe since all user space treats this as unsigned, but
+	 * will overflow in 2106
+	 */
+	header->ph_sec = (u32)ts.tv_sec;
+	header->ph_usec = ts.tv_nsec / NSEC_PER_USEC;
+	header->ph_stack = stack;
+	header->ph_pid = current->pid;
+	header->ph_line_num = msgdata->msg_line;
+	header->ph_extern_pid = 0;
+}
+
+static void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
+				 const char *buf, int len, const char *file,
+				 const char *fn)
+{
+	char *prefix = "Lustre";
+
+	if (hdr->ph_subsys == S_LND || hdr->ph_subsys == S_LNET)
+		prefix = "LNet";
+
+	if (mask & D_EMERG) {
+		pr_emerg("%sError: %d:%d:(%s:%d:%s()) %.*s", prefix,
+			 hdr->ph_pid, hdr->ph_extern_pid, file,
+			 hdr->ph_line_num, fn, len, buf);
+	} else if (mask & D_ERROR) {
+		pr_err("%sError: %d:%d:(%s:%d:%s()) %.*s", prefix,
+		       hdr->ph_pid, hdr->ph_extern_pid, file,
+		       hdr->ph_line_num, fn, len, buf);
+	} else if (mask & D_WARNING) {
+		pr_warning("%s: %d:%d:(%s:%d:%s()) %.*s", prefix,
+			   hdr->ph_pid, hdr->ph_extern_pid, file,
+			   hdr->ph_line_num, fn, len, buf);
+	} else if (mask & (D_CONSOLE | libcfs_printk)) {
+		pr_info("%s: %.*s", prefix, len, buf);
+	}
+}
+
 int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
 		     const char *format, ...)
 {
@@ -531,6 +664,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 	} else {
 		string_buf = cfs_trace_get_console_buffer();
 
+		memset(string_buf, 0, CFS_TRACE_CONSOLE_BUFFER_SIZE);
 		needed = 0;
 		if (format1) {
 			va_copy(ap, args);
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index f49a9ba..4c79009 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -42,13 +42,6 @@
 #include <linux/smp.h>
 #include <linux/libcfs/libcfs.h>
 
-enum cfs_trace_buf_type {
-	CFS_TCD_TYPE_PROC = 0,
-	CFS_TCD_TYPE_SOFTIRQ,
-	CFS_TCD_TYPE_IRQ,
-	CFS_TCD_TYPE_MAX
-};
-
 #define TRACEFILE_NAME_SIZE 1024
 extern char cfs_tracefile[TRACEFILE_NAME_SIZE];
 extern long long cfs_tracefile_size;
@@ -60,9 +53,6 @@ enum cfs_trace_buf_type {
 
 void libcfs_run_debug_log_upcall(char *file);
 
-int  cfs_tracefile_init_arch(void);
-void cfs_tracefile_fini_arch(void);
-
 int cfs_tracefile_dump_all_pages(char *filename);
 void cfs_trace_debug_print(void);
 void cfs_trace_flush_pages(void);
@@ -92,22 +82,6 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 #define TCD_STOCK_PAGES (TCD_MAX_PAGES)
 #define CFS_TRACEFILE_SIZE (500 << 20)
 
-#ifdef LUSTRE_TRACEFILE_PRIVATE
-
-/*
- * Private declare for tracefile
- */
-#define TCD_MAX_PAGES (5 << (20 - PAGE_SHIFT))
-#define TCD_STOCK_PAGES (TCD_MAX_PAGES)
-
-#define CFS_TRACEFILE_SIZE (500 << 20)
-
-/*
- * Size of a buffer for sprinting console messages if we can't get a page
- * from system
- */
-#define CFS_TRACE_CONSOLE_BUFFER_SIZE   1024
-
 union cfs_trace_data_union {
 	struct cfs_trace_cpu_data {
 		/*
@@ -184,58 +158,25 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 	char __pad[L1_CACHE_ALIGN(sizeof(struct cfs_trace_cpu_data))];
 };
 
-#define TCD_MAX_TYPES      8
-extern union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS];
-
-#define cfs_tcd_for_each(tcd, i, j)				       \
-	for (i = 0; cfs_trace_data[i]; i++)				\
-		for (j = 0, ((tcd) = &(*cfs_trace_data[i])[j].tcd);	\
-		     j < num_possible_cpus();				 \
-		     j++, (tcd) = &(*cfs_trace_data[i])[j].tcd)
-
-void cfs_set_ptldebug_header(struct ptldebug_header *header,
-			     struct libcfs_debug_msg_data *m,
-			     unsigned long stack);
-void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
-			  const char *buf, int len, const char *file,
-			  const char *fn);
-
-extern char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
-enum cfs_trace_buf_type cfs_trace_buf_idx_get(void);
-
-static inline char *
-cfs_trace_get_console_buffer(void)
-{
-	unsigned int i = get_cpu();
-	unsigned int j = cfs_trace_buf_idx_get();
-
-	return cfs_trace_console_buffers[i][j];
-}
-
-int cfs_trace_refill_stock(struct cfs_trace_cpu_data *tcd, gfp_t gfp,
-			   struct list_head *stock);
-
 void cfs_trace_assertion_failed(const char *str,
 				struct libcfs_debug_msg_data *m);
 
 /* ASSERTION that is safe to use within the debug system */
-#define __LASSERT(cond)						 \
-do {								    \
+#define __LASSERT(cond)							\
+do {									\
 	if (unlikely(!(cond))) {					\
 		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, D_EMERG, NULL);     \
 		cfs_trace_assertion_failed("ASSERTION("#cond") failed", \
-					   &msgdata);		   \
-	}							       \
+					   &msgdata);			\
+	}								\
 } while (0)
 
-#define __LASSERT_TAGE_INVARIANT(tage)				  \
-do {								    \
-	__LASSERT(tage);					\
-	__LASSERT(tage->page);				  \
-	__LASSERT(tage->used <= PAGE_SIZE);			 \
-	__LASSERT(page_count(tage->page) > 0);		      \
+#define __LASSERT_TAGE_INVARIANT(tage)			\
+do {							\
+	__LASSERT(tage);				\
+	__LASSERT(tage->page);				\
+	__LASSERT(tage->used <= PAGE_SIZE);		\
+	__LASSERT(page_count(tage->page) > 0);		\
 } while (0)
 
-#endif	/* LUSTRE_TRACEFILE_PRIVATE */
-
 #endif /* __LIBCFS_TRACEFILE_H__ */
-- 
1.8.3.1
