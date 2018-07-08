From: James Simmons <jsimmons@infradead.org>
Date: Sat,  7 Jul 2018 20:14:21 -0400
Subject: [lustre-devel] [PATCH v4 07/14] lustre: libcfs: merge
 linux-tracefile.c into tracefile.c
In-Reply-To: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
References: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1531008868-4194-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

It's good to keep related code together.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/libcfs/Makefile        |   2 +-
 .../staging/lustre/lnet/libcfs/linux-tracefile.c   | 186 ---------------------
 drivers/staging/lustre/lnet/libcfs/tracefile.c     | 145 ++++++++++++++++
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |   7 -
 4 files changed, 146 insertions(+), 194 deletions(-)
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
index ef26835..0000000
--- a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
+++ /dev/null
@@ -1,186 +0,0 @@
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
-	struct cfs_trace_cpu_data *tcd;
-	int i;
-	int j;
-
-	/* initialize trace_data */
-	memset(cfs_trace_data, 0, sizeof(cfs_trace_data));
-	for (i = 0; i < CFS_TCD_TYPE_MAX; i++) {
-		cfs_trace_data[i] =
-			kmalloc_array(num_possible_cpus(),
-				      sizeof(union cfs_trace_data_union),
-				      GFP_KERNEL);
-		if (!cfs_trace_data[i])
-			goto out_trace_data;
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
-				goto out_buffers;
-		}
-
-	return 0;
-
-out_buffers:
-	for (i = 0; i < num_possible_cpus(); i++)
-		for (j = 0; j < 3; j++) {
-			kfree(cfs_trace_console_buffers[i][j]);
-			cfs_trace_console_buffers[i][j] = NULL;
-		}
-out_trace_data:
-	for (i = 0; cfs_trace_data[i]; i++) {
-		kfree(cfs_trace_data[i]);
-		cfs_trace_data[i] = NULL;
-	}
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
-void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
-			  const char *buf, int len, const char *file,
-			  const char *fn)
-{
-	char *prefix = "Lustre";
-
-	if (hdr->ph_subsys == S_LND || hdr->ph_subsys == S_LNET)
-		prefix = "LNet";
-
-	if (mask & D_CONSOLE) {
-		if (mask & D_EMERG)
-			pr_emerg("%sError: %.*s", prefix, len, buf);
-		else if (mask & D_ERROR)
-			pr_err("%sError: %.*s", prefix, len, buf);
-		else if (mask & D_WARNING)
-			pr_warn("%s: %.*s", prefix, len, buf);
-		else if (mask & libcfs_printk)
-			pr_info("%s: %.*s", prefix, len, buf);
-	} else {
-		if (mask & D_EMERG)
-			pr_emerg("%sError: %d:%d:(%s:%d:%s()) %.*s", prefix,
-				 hdr->ph_pid, hdr->ph_extern_pid, file,
-				 hdr->ph_line_num, fn, len, buf);
-		else if (mask & D_ERROR)
-			pr_err("%sError: %d:%d:(%s:%d:%s()) %.*s", prefix,
-			       hdr->ph_pid, hdr->ph_extern_pid, file,
-			       hdr->ph_line_num, fn, len, buf);
-		else if (mask & D_WARNING)
-			pr_warn("%s: %d:%d:(%s:%d:%s()) %.*s", prefix,
-				hdr->ph_pid, hdr->ph_extern_pid, file,
-				hdr->ph_line_num, fn, len, buf);
-		else if (mask & (D_CONSOLE | libcfs_printk))
-			pr_info("%s: %.*s", prefix, len, buf);
-	}
-}
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index c46dc56..066476d 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -52,6 +52,7 @@
 /* XXX move things up to the top, comment */
 union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS] __cacheline_aligned;
 
+char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
 char cfs_tracefile[TRACEFILE_NAME_SIZE];
 long long cfs_tracefile_size = CFS_TRACEFILE_SIZE;
 static struct tracefiled_ctl trace_tctl;
@@ -150,6 +151,15 @@ void cfs_trace_unlock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
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
 static inline struct cfs_trace_cpu_data *
 cfs_trace_get_tcd(void)
 {
@@ -168,6 +178,82 @@ static inline void cfs_trace_put_tcd(struct cfs_trace_cpu_data *tcd)
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
+	for (i = 0; i < num_possible_cpus(); i++)
+		for (j = 0; j < 3; j++) {
+			kfree(cfs_trace_console_buffers[i][j]);
+			cfs_trace_console_buffers[i][j] = NULL;
+		}
+out_trace_data:
+	for (i = 0; cfs_trace_data[i]; i++) {
+		kfree(cfs_trace_data[i]);
+		cfs_trace_data[i] = NULL;
+	}
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
@@ -340,6 +426,65 @@ static struct cfs_trace_page *cfs_trace_get_tage(struct cfs_trace_cpu_data *tcd,
 	return tage;
 }
 
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
+	if (mask & D_CONSOLE) {
+		if (mask & D_EMERG)
+			pr_emerg("%sError: %.*s", prefix, len, buf);
+		else if (mask & D_ERROR)
+			pr_err("%sError: %.*s", prefix, len, buf);
+		else if (mask & D_WARNING)
+			pr_warn("%s: %.*s", prefix, len, buf);
+		else if (mask & libcfs_printk)
+			pr_info("%s: %.*s", prefix, len, buf);
+	} else {
+		if (mask & D_EMERG)
+			pr_emerg("%sError: %d:%d:(%s:%d:%s()) %.*s", prefix,
+				 hdr->ph_pid, hdr->ph_extern_pid, file,
+				 hdr->ph_line_num, fn, len, buf);
+		else if (mask & D_ERROR)
+			pr_err("%sError: %d:%d:(%s:%d:%s()) %.*s", prefix,
+			       hdr->ph_pid, hdr->ph_extern_pid, file,
+			       hdr->ph_line_num, fn, len, buf);
+		else if (mask & D_WARNING)
+			pr_warn("%s: %d:%d:(%s:%d:%s()) %.*s", prefix,
+				hdr->ph_pid, hdr->ph_extern_pid, file,
+				hdr->ph_line_num, fn, len, buf);
+		else if (mask & (D_CONSOLE | libcfs_printk))
+			pr_info("%s: %.*s", prefix, len, buf);
+	}
+}
+
 int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
 		     const char *format, ...)
 {
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index 91968cf..399e0bf 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -192,13 +192,6 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 		     j < num_possible_cpus();				 \
 		     j++, (tcd) = &(*cfs_trace_data[i])[j].tcd)
 
-void cfs_set_ptldebug_header(struct ptldebug_header *header,
-			     struct libcfs_debug_msg_data *m,
-			     unsigned long stack);
-void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
-			  const char *buf, int len, const char *file,
-			  const char *fn);
-
 extern char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
 enum cfs_trace_buf_type cfs_trace_buf_idx_get(void);
 
-- 
1.8.3.1
