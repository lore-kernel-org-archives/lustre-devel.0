From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:29 -0400
Subject: [lustre-devel] [PATCH 26/38] lustre: obd: merge both top lustre
 sysfs attributes
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The top of the lustre sysfs tree is handled by two sets of
attributes, one in sysctl.c and the other in modules.c.
Worst is the the sysfs attributes in sysctl.c are never
cleaned up. So merge all the sysfs handling in sysctl.c
into the one managed in modules.c. Additionally now all
the top level attributes will be cleaned up. This eliminates
the sysctl.c file as well.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9431
Reviewed-on: https://review.whamcloud.com/30143
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd_class.h  |   3 -
 drivers/staging/lustre/lustre/obdclass/Makefile    |   2 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   4 -
 drivers/staging/lustre/lustre/obdclass/module.c    |  97 ++++++++++++
 drivers/staging/lustre/lustre/obdclass/sysctl.c    | 162 ---------------------
 5 files changed, 98 insertions(+), 170 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/obdclass/sysctl.c

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index e250bc3..02a3f97 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1553,9 +1553,6 @@ struct lwp_register_item {
 int lustre_register_fs(void);
 int lustre_check_exclusion(struct super_block *sb, char *svname);
 
-/* sysctl.c */
-int obd_sysctl_init(void);
-
 /* uuid.c  */
 typedef __u8 class_uuid_t[16];
 void class_uuid_unparse(class_uuid_t in, struct obd_uuid *out);
diff --git a/drivers/staging/lustre/lustre/obdclass/Makefile b/drivers/staging/lustre/lustre/obdclass/Makefile
index 686bd54..5d050f0 100644
--- a/drivers/staging/lustre/lustre/obdclass/Makefile
+++ b/drivers/staging/lustre/lustre/obdclass/Makefile
@@ -4,7 +4,7 @@ ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += obdclass.o
 
-obdclass-y := module.o sysctl.o \
+obdclass-y := module.o \
 	      llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o debug.o \
 	      genops.o uuid.o lprocfs_status.o lprocfs_counters.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 8100184..bbffede 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -494,10 +494,6 @@ static int __init obdclass_init(void)
 	if (err)
 		goto cleanup_caches;
 
-	err = obd_sysctl_init();
-	if (err)
-		goto cleanup_class_procfs;
-
 	err = lu_global_init();
 	if (err)
 		goto cleanup_class_procfs;
diff --git a/drivers/staging/lustre/lustre/obdclass/module.c b/drivers/staging/lustre/lustre/obdclass/module.c
index 0ce2617..27b3849 100644
--- a/drivers/staging/lustre/lustre/obdclass/module.c
+++ b/drivers/staging/lustre/lustre/obdclass/module.c
@@ -274,6 +274,93 @@ struct miscdevice obd_psdev = {
 	.fops  = &obd_psdev_fops,
 };
 
+struct static_lustre_uintvalue_attr {
+	struct {
+		struct attribute attr;
+		ssize_t (*show)(struct kobject *kobj, struct attribute *attr,
+				char *buf);
+		ssize_t (*store)(struct kobject *kobj, struct attribute *attr,
+				 const char *buf, size_t len);
+	} u;
+	int *value;
+};
+
+static ssize_t static_uintvalue_show(struct kobject *kobj,
+				     struct attribute *attr,
+				     char *buf)
+{
+	struct static_lustre_uintvalue_attr *lattr = (void *)attr;
+
+	return sprintf(buf, "%d\n", *lattr->value);
+}
+
+static ssize_t static_uintvalue_store(struct kobject *kobj,
+				      struct attribute *attr,
+				      const char *buffer, size_t count)
+{
+	struct static_lustre_uintvalue_attr *lattr = (void *)attr;
+	unsigned int val;
+	int rc;
+
+	rc = kstrtouint(buffer, 10, &val);
+	if (rc)
+		return rc;
+
+	*lattr->value = val;
+
+	return count;
+}
+
+#define LUSTRE_STATIC_UINT_ATTR(name, value)				\
+static struct static_lustre_uintvalue_attr lustre_sattr_##name =        \
+	{ __ATTR(name, 0644, static_uintvalue_show,			\
+		 static_uintvalue_store), value }
+
+LUSTRE_STATIC_UINT_ATTR(timeout, &obd_timeout);
+LUSTRE_STATIC_UINT_ATTR(debug_peer_on_timeout, &obd_debug_peer_on_timeout);
+LUSTRE_STATIC_UINT_ATTR(dump_on_timeout, &obd_dump_on_timeout);
+LUSTRE_STATIC_UINT_ATTR(dump_on_eviction, &obd_dump_on_eviction);
+LUSTRE_STATIC_UINT_ATTR(at_min, &at_min);
+LUSTRE_STATIC_UINT_ATTR(at_max, &at_max);
+LUSTRE_STATIC_UINT_ATTR(at_extra, &at_extra);
+LUSTRE_STATIC_UINT_ATTR(at_early_margin, &at_early_margin);
+LUSTRE_STATIC_UINT_ATTR(at_history, &at_history);
+
+static ssize_t max_dirty_mb_show(struct kobject *kobj, struct attribute *attr,
+				 char *buf)
+{
+	return sprintf(buf, "%lu\n",
+		       obd_max_dirty_pages / (1 << (20 - PAGE_SHIFT)));
+}
+
+static ssize_t max_dirty_mb_store(struct kobject *kobj, struct attribute *attr,
+				  const char *buffer, size_t count)
+{
+	unsigned long val;
+	int rc;
+
+	rc = kstrtoul(buffer, 10, &val);
+	if (rc)
+		return rc;
+
+	val *= 1 << (20 - PAGE_SHIFT); /* convert to pages */
+
+	if (val > ((totalram_pages / 10) * 9)) {
+		/* Somebody wants to assign too much memory to dirty pages */
+		return -EINVAL;
+	}
+
+	if (val < 4 << (20 - PAGE_SHIFT)) {
+		/* Less than 4 Mb for dirty cache is also bad */
+		return -EINVAL;
+	}
+
+	obd_max_dirty_pages = val;
+
+	return count;
+}
+LUSTRE_RW_ATTR(max_dirty_mb);
+
 static ssize_t version_show(struct kobject *kobj, struct attribute *attr,
 			    char *buf)
 {
@@ -390,6 +477,16 @@ static ssize_t jobid_name_store(struct kobject *kobj, struct attribute *attr,
 	&lustre_attr_health_check.attr,
 	&lustre_attr_jobid_name.attr,
 	&lustre_attr_jobid_var.attr,
+	&lustre_sattr_timeout.u.attr,
+	&lustre_attr_max_dirty_mb.attr,
+	&lustre_sattr_debug_peer_on_timeout.u.attr,
+	&lustre_sattr_dump_on_timeout.u.attr,
+	&lustre_sattr_dump_on_eviction.u.attr,
+	&lustre_sattr_at_min.u.attr,
+	&lustre_sattr_at_max.u.attr,
+	&lustre_sattr_at_extra.u.attr,
+	&lustre_sattr_at_early_margin.u.attr,
+	&lustre_sattr_at_history.u.attr,
 	NULL,
 };
 
diff --git a/drivers/staging/lustre/lustre/obdclass/sysctl.c b/drivers/staging/lustre/lustre/obdclass/sysctl.c
deleted file mode 100644
index f8760b2..0000000
--- a/drivers/staging/lustre/lustre/obdclass/sysctl.c
+++ /dev/null
@@ -1,162 +0,0 @@
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
- * Copyright (c) 1999, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, 2015, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#include <linux/module.h>
-#include <linux/sysctl.h>
-#include <linux/sched.h>
-#include <linux/mm.h>
-#include <linux/slab.h>
-#include <linux/stat.h>
-#include <linux/ctype.h>
-#include <linux/bitops.h>
-#include <linux/uaccess.h>
-#include <linux/utsname.h>
-
-#define DEBUG_SUBSYSTEM S_CLASS
-
-#include <obd_support.h>
-#include <lprocfs_status.h>
-#include <obd_class.h>
-
-struct static_lustre_uintvalue_attr {
-	struct {
-		struct attribute attr;
-		ssize_t (*show)(struct kobject *kobj, struct attribute *attr,
-				char *buf);
-		ssize_t (*store)(struct kobject *kobj, struct attribute *attr,
-				 const char *buf, size_t len);
-	} u;
-	int *value;
-};
-
-static ssize_t static_uintvalue_show(struct kobject *kobj,
-				     struct attribute *attr,
-				     char *buf)
-{
-	struct static_lustre_uintvalue_attr *lattr = (void *)attr;
-
-	return sprintf(buf, "%d\n", *lattr->value);
-}
-
-static ssize_t static_uintvalue_store(struct kobject *kobj,
-				      struct attribute *attr,
-				      const char *buffer, size_t count)
-{
-	struct static_lustre_uintvalue_attr *lattr  = (void *)attr;
-	int rc;
-	unsigned int val;
-
-	rc = kstrtouint(buffer, 10, &val);
-	if (rc)
-		return rc;
-
-	*lattr->value = val;
-
-	return count;
-}
-
-#define LUSTRE_STATIC_UINT_ATTR(name, value) \
-static struct static_lustre_uintvalue_attr lustre_sattr_##name =	\
-					{__ATTR(name, 0644,		\
-						static_uintvalue_show,	\
-						static_uintvalue_store),\
-					  value }
-
-LUSTRE_STATIC_UINT_ATTR(timeout, &obd_timeout);
-
-static ssize_t max_dirty_mb_show(struct kobject *kobj, struct attribute *attr,
-				 char *buf)
-{
-	return sprintf(buf, "%lu\n",
-		       obd_max_dirty_pages / (1 << (20 - PAGE_SHIFT)));
-}
-
-static ssize_t max_dirty_mb_store(struct kobject *kobj, struct attribute *attr,
-				  const char *buffer, size_t count)
-{
-	int rc;
-	unsigned long val;
-
-	rc = kstrtoul(buffer, 10, &val);
-	if (rc)
-		return rc;
-
-	val *= 1 << (20 - PAGE_SHIFT); /* convert to pages */
-
-	if (val > ((totalram_pages / 10) * 9)) {
-		/* Somebody wants to assign too much memory to dirty pages */
-		return -EINVAL;
-	}
-
-	if (val < 4 << (20 - PAGE_SHIFT)) {
-		/* Less than 4 Mb for dirty cache is also bad */
-		return -EINVAL;
-	}
-
-	obd_max_dirty_pages = val;
-
-	return count;
-}
-LUSTRE_RW_ATTR(max_dirty_mb);
-
-LUSTRE_STATIC_UINT_ATTR(debug_peer_on_timeout, &obd_debug_peer_on_timeout);
-LUSTRE_STATIC_UINT_ATTR(dump_on_timeout, &obd_dump_on_timeout);
-LUSTRE_STATIC_UINT_ATTR(dump_on_eviction, &obd_dump_on_eviction);
-LUSTRE_STATIC_UINT_ATTR(at_min, &at_min);
-LUSTRE_STATIC_UINT_ATTR(at_max, &at_max);
-LUSTRE_STATIC_UINT_ATTR(at_extra, &at_extra);
-LUSTRE_STATIC_UINT_ATTR(at_early_margin, &at_early_margin);
-LUSTRE_STATIC_UINT_ATTR(at_history, &at_history);
-
-static struct attribute *lustre_attrs[] = {
-	&lustre_sattr_timeout.u.attr,
-	&lustre_attr_max_dirty_mb.attr,
-	&lustre_sattr_debug_peer_on_timeout.u.attr,
-	&lustre_sattr_dump_on_timeout.u.attr,
-	&lustre_sattr_dump_on_eviction.u.attr,
-	&lustre_sattr_at_min.u.attr,
-	&lustre_sattr_at_max.u.attr,
-	&lustre_sattr_at_extra.u.attr,
-	&lustre_sattr_at_early_margin.u.attr,
-	&lustre_sattr_at_history.u.attr,
-	NULL,
-};
-
-static const struct attribute_group lustre_attr_group = {
-	.attrs = lustre_attrs,
-};
-
-int obd_sysctl_init(void)
-{
-	return sysfs_create_group(&lustre_kset->kobj, &lustre_attr_group);
-}
-- 
1.8.3.1
