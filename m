From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:10:07 -0400
Subject: [lustre-devel] [PATCH 25/25] staging: lustre: libcfs: merge UMP and
 SMP libcfs cpu header code
In-Reply-To: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523851807-16573-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: James Simmons <uja.ornl@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Currently we have two headers, linux-cpu.h that contains the SMP
version and libcfs_cpu.h contains the UMP version. We can simplify
the headers into a single header which handles both cases.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9859
Reviewed-on: https://review.whamcloud.com/30873
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_cpu.h       | 67 +++++++++++------
 .../lustre/include/linux/libcfs/linux/libcfs.h     |  1 -
 .../lustre/include/linux/libcfs/linux/linux-cpu.h  | 84 ----------------------
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    | 18 ++---
 4 files changed, 52 insertions(+), 118 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 19a3489..0611fcd 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -72,32 +72,55 @@
 #ifndef __LIBCFS_CPU_H__
 #define __LIBCFS_CPU_H__
 
-/* any CPU partition */
-#define CFS_CPT_ANY		(-1)
+#include <linux/cpu.h>
+#include <linux/cpuset.h>
+#include <linux/slab.h>
+#include <linux/topology.h>
+#include <linux/version.h>
 
 #ifdef CONFIG_SMP
-/**
- * print string information of cpt-table
- */
-int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len);
-#else /* !CONFIG_SMP */
+
+/** virtual processing unit */
+struct cfs_cpu_partition {
+	/* CPUs mask for this partition */
+	cpumask_var_t			 cpt_cpumask;
+	/* nodes mask for this partition */
+	nodemask_t			*cpt_nodemask;
+	/* NUMA distance between CPTs */
+	unsigned int			*cpt_distance;
+	/* spread rotor for NUMA allocator */
+	int				 cpt_spread_rotor;
+	/* NUMA node if cpt_nodemask is empty */
+	int				 cpt_node;
+};
+#endif /* CONFIG_SMP */
+
+/** descriptor for CPU partitions */
 struct cfs_cpt_table {
+#ifdef CONFIG_SMP
+	/* spread rotor for NUMA allocator */
+	int				 ctb_spread_rotor;
+	/* maximum NUMA distance between all nodes in table */
+	unsigned int			 ctb_distance;
+	/* partitions tables */
+	struct cfs_cpu_partition	*ctb_parts;
+	/* shadow HW CPU to CPU partition ID */
+	int				*ctb_cpu2cpt;
+	/* shadow HW node to CPU partition ID */
+	int				*ctb_node2cpt;
 	/* # of CPU partitions */
-	int			ctb_nparts;
-	/* cpu mask */
-	cpumask_var_t		ctb_mask;
-	/* node mask */
-	nodemask_t		ctb_nodemask;
-	/* version */
-	u64			ctb_version;
+	int				 ctb_nparts;
+	/* all nodes in this partition table */
+	nodemask_t			*ctb_nodemask;
+#else
+	nodemask_t			 ctb_nodemask;
+#endif /* CONFIG_SMP */
+	/* all cpus in this partition table */
+	cpumask_var_t			 ctb_cpumask;
 };
 
-static inline int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf,
-				      int len)
-{
-	return 0;
-}
-#endif /* CONFIG_SMP */
+/* any CPU partition */
+#define CFS_CPT_ANY		(-1)
 
 extern struct cfs_cpt_table	*cfs_cpt_table;
 
@@ -110,6 +133,10 @@ static inline int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf,
  */
 struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt);
 /**
+ * print string information of cpt-table
+ */
+int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len);
+/**
  * print distance information of cpt-table
  */
 int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len);
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
index 07d3cb2..07610be 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
@@ -78,7 +78,6 @@
 #include <linux/timex.h>
 #include <linux/uaccess.h>
 #include <stdarg.h>
-#include "linux-cpu.h"
 
 #if !defined(__x86_64__)
 # ifdef __ia64__
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
deleted file mode 100644
index ed4351b..0000000
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
+++ /dev/null
@@ -1,84 +0,0 @@
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
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
- * Copyright (c) 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * libcfs/include/libcfs/linux/linux-cpu.h
- *
- * Basic library routines.
- *
- * Author: liang at whamcloud.com
- */
-
-#ifndef __LIBCFS_LINUX_CPU_H__
-#define __LIBCFS_LINUX_CPU_H__
-
-#ifndef __LIBCFS_LIBCFS_H__
-#error Do not #include this file directly. #include <linux/libcfs/libcfs.h> instead
-#endif
-
-#include <linux/cpu.h>
-#include <linux/cpuset.h>
-#include <linux/topology.h>
-
-#ifdef CONFIG_SMP
-
-#define HAVE_LIBCFS_CPT
-
-/** virtual processing unit */
-struct cfs_cpu_partition {
-	/* CPUs mask for this partition */
-	cpumask_var_t			cpt_cpumask;
-	/* nodes mask for this partition */
-	nodemask_t			*cpt_nodemask;
-	/* NUMA distance between CPTs */
-	unsigned int			*cpt_distance;
-	/* spread rotor for NUMA allocator */
-	int				 cpt_spread_rotor;
-	/* NUMA node if cpt_nodemask is empty */
-	int				 cpt_node;
-};
-
-/** descriptor for CPU partitions */
-struct cfs_cpt_table {
-	/* spread rotor for NUMA allocator */
-	int				ctb_spread_rotor;
-	/* maximum NUMA distance between all nodes in table */
-	unsigned int			ctb_distance;
-	/* # of CPU partitions */
-	int				ctb_nparts;
-	/* partitions tables */
-	struct cfs_cpu_partition	*ctb_parts;
-	/* shadow HW CPU to CPU partition ID */
-	int				*ctb_cpu2cpt;
-	/* all cpus in this partition table */
-	cpumask_var_t			ctb_cpumask;
-	/* shadow HW node to CPU partition ID */
-	int				*ctb_node2cpt;
-	/* all nodes in this partition table */
-	nodemask_t			*ctb_nodemask;
-};
-
-#endif /* CONFIG_SMP */
-#endif /* __LIBCFS_LINUX_CPU_H__ */
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 5d7d44d..1df7a1b 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -37,9 +37,7 @@
 struct cfs_cpt_table *cfs_cpt_table __read_mostly;
 EXPORT_SYMBOL(cfs_cpt_table);
 
-#ifndef HAVE_LIBCFS_CPT
-
-#define CFS_CPU_VERSION_MAGIC	   0xbabecafe
+#ifndef CONFIG_SMP
 
 #define CFS_CPT_DISTANCE	1	/* Arbitrary positive value */
 
@@ -54,12 +52,10 @@ struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt)
 
 	cptab = kzalloc(sizeof(*cptab), GFP_NOFS);
 	if (cptab) {
-		cptab->ctb_version = CFS_CPU_VERSION_MAGIC;
-		if (!zalloc_cpumask_var(&cptab->ctb_mask, GFP_NOFS))
+		if (!zalloc_cpumask_var(&cptab->ctb_cpumask, GFP_NOFS))
 			return NULL;
-		cpumask_set_cpu(0, cptab->ctb_mask);
+		cpumask_set_cpu(0, cptab->ctb_cpumask);
 		node_set(0, cptab->ctb_nodemask);
-		cptab->ctb_nparts  = ncpt;
 	}
 
 	return cptab;
@@ -68,13 +64,10 @@ struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt)
 
 void cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 {
-	LASSERT(cptab->ctb_version == CFS_CPU_VERSION_MAGIC);
-
 	kfree(cptab);
 }
 EXPORT_SYMBOL(cfs_cpt_table_free);
 
-#ifdef CONFIG_SMP
 int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
 {
 	int rc;
@@ -87,7 +80,6 @@ int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
 	return rc;
 }
 EXPORT_SYMBOL(cfs_cpt_table_print);
-#endif /* CONFIG_SMP */
 
 int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
 {
@@ -122,7 +114,7 @@ int cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt)
 
 cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
 {
-	return &cptab->ctb_mask;
+	return &cptab->ctb_cpumask;
 }
 EXPORT_SYMBOL(cfs_cpt_cpumask);
 
@@ -231,4 +223,4 @@ int cfs_cpu_init(void)
 	return cfs_cpt_table ? 0 : -1;
 }
 
-#endif /* HAVE_LIBCFS_CPT */
+#endif /* !CONFIG_SMP */
-- 
1.8.3.1
