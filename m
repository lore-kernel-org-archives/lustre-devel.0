From: NeilBrown <neilb@suse.com>
Date: Tue, 01 May 2018 13:52:39 +1000
Subject: [lustre-devel] [PATCH 09/10] staging: lustre: move remaining code
 from linux-module.c to module.c
In-Reply-To: <152514658325.17843.11455067361317157487.stgit@noble>
References: <152514658325.17843.11455067361317157487.stgit@noble>
Message-ID: <152514675915.17843.13015150157081908310.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

There is no longer any need to keep this code separate,
and now we can remove linux-module.c

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    4 
 drivers/staging/lustre/lnet/libcfs/Makefile        |    1 
 .../lustre/lnet/libcfs/linux/linux-module.c        |  168 --------------------
 drivers/staging/lustre/lnet/libcfs/module.c        |  131 ++++++++++++++++
 4 files changed, 131 insertions(+), 173 deletions(-)
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-module.c

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 9263e151451b..d420449b620e 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -138,10 +138,6 @@ struct libcfs_ioctl_handler {
 int libcfs_register_ioctl(struct libcfs_ioctl_handler *hand);
 int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand);
 
-int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
-			 const struct libcfs_ioctl_hdr __user *uparam);
-int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data);
-
 #define _LIBCFS_H
 
 /**
diff --git a/drivers/staging/lustre/lnet/libcfs/Makefile b/drivers/staging/lustre/lnet/libcfs/Makefile
index e6fda27fdabd..e73515789a11 100644
--- a/drivers/staging/lustre/lnet/libcfs/Makefile
+++ b/drivers/staging/lustre/lnet/libcfs/Makefile
@@ -5,7 +5,6 @@ subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 obj-$(CONFIG_LNET) += libcfs.o
 
 libcfs-linux-objs := linux-tracefile.o linux-debug.o
-libcfs-linux-objs += linux-module.o
 libcfs-linux-objs += linux-crypto.o
 libcfs-linux-objs += linux-crypto-adler.o
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
deleted file mode 100644
index 954b681f9db7..000000000000
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ /dev/null
@@ -1,168 +0,0 @@
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
-
-#include <linux/miscdevice.h>
-#include <linux/libcfs/libcfs.h>
-
-static inline size_t libcfs_ioctl_packlen(struct libcfs_ioctl_data *data)
-{
-	size_t len = sizeof(*data);
-
-	len += cfs_size_round(data->ioc_inllen1);
-	len += cfs_size_round(data->ioc_inllen2);
-	return len;
-}
-
-static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
-{
-	if (data->ioc_hdr.ioc_len > BIT(30)) {
-		CERROR("LIBCFS ioctl: ioc_len larger than 1<<30\n");
-		return true;
-	}
-	if (data->ioc_inllen1 > BIT(30)) {
-		CERROR("LIBCFS ioctl: ioc_inllen1 larger than 1<<30\n");
-		return true;
-	}
-	if (data->ioc_inllen2 > BIT(30)) {
-		CERROR("LIBCFS ioctl: ioc_inllen2 larger than 1<<30\n");
-		return true;
-	}
-	if (data->ioc_inlbuf1 && !data->ioc_inllen1) {
-		CERROR("LIBCFS ioctl: inlbuf1 pointer but 0 length\n");
-		return true;
-	}
-	if (data->ioc_inlbuf2 && !data->ioc_inllen2) {
-		CERROR("LIBCFS ioctl: inlbuf2 pointer but 0 length\n");
-		return true;
-	}
-	if (data->ioc_pbuf1 && !data->ioc_plen1) {
-		CERROR("LIBCFS ioctl: pbuf1 pointer but 0 length\n");
-		return true;
-	}
-	if (data->ioc_pbuf2 && !data->ioc_plen2) {
-		CERROR("LIBCFS ioctl: pbuf2 pointer but 0 length\n");
-		return true;
-	}
-	if (data->ioc_plen1 && !data->ioc_pbuf1) {
-		CERROR("LIBCFS ioctl: plen1 nonzero but no pbuf1 pointer\n");
-		return true;
-	}
-	if (data->ioc_plen2 && !data->ioc_pbuf2) {
-		CERROR("LIBCFS ioctl: plen2 nonzero but no pbuf2 pointer\n");
-		return true;
-	}
-	if ((u32)libcfs_ioctl_packlen(data) != data->ioc_hdr.ioc_len) {
-		CERROR("LIBCFS ioctl: packlen != ioc_len\n");
-		return true;
-	}
-	if (data->ioc_inllen1 &&
-	    data->ioc_bulk[data->ioc_inllen1 - 1] != '\0') {
-		CERROR("LIBCFS ioctl: inlbuf1 not 0 terminated\n");
-		return true;
-	}
-	if (data->ioc_inllen2 &&
-	    data->ioc_bulk[cfs_size_round(data->ioc_inllen1) +
-			   data->ioc_inllen2 - 1] != '\0') {
-		CERROR("LIBCFS ioctl: inlbuf2 not 0 terminated\n");
-		return true;
-	}
-	return false;
-}
-
-int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data)
-{
-	if (libcfs_ioctl_is_invalid(data)) {
-		CERROR("libcfs ioctl: parameter not correctly formatted\n");
-		return -EINVAL;
-	}
-
-	if (data->ioc_inllen1)
-		data->ioc_inlbuf1 = &data->ioc_bulk[0];
-
-	if (data->ioc_inllen2)
-		data->ioc_inlbuf2 = &data->ioc_bulk[0] +
-			cfs_size_round(data->ioc_inllen1);
-
-	return 0;
-}
-
-int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
-			 const struct libcfs_ioctl_hdr __user *uhdr)
-{
-	struct libcfs_ioctl_hdr hdr;
-	int err;
-
-	if (copy_from_user(&hdr, uhdr, sizeof(hdr)))
-		return -EFAULT;
-
-	if (hdr.ioc_version != LIBCFS_IOCTL_VERSION &&
-	    hdr.ioc_version != LIBCFS_IOCTL_VERSION2) {
-		CERROR("libcfs ioctl: version mismatch expected %#x, got %#x\n",
-		       LIBCFS_IOCTL_VERSION, hdr.ioc_version);
-		return -EINVAL;
-	}
-
-	if (hdr.ioc_len < sizeof(hdr)) {
-		CERROR("libcfs ioctl: user buffer too small for ioctl\n");
-		return -EINVAL;
-	}
-
-	if (hdr.ioc_len > LIBCFS_IOC_DATA_MAX) {
-		CERROR("libcfs ioctl: user buffer is too large %d/%d\n",
-		       hdr.ioc_len, LIBCFS_IOC_DATA_MAX);
-		return -EINVAL;
-	}
-
-	*hdr_pp = kvmalloc(hdr.ioc_len, GFP_KERNEL);
-	if (!*hdr_pp)
-		return -ENOMEM;
-
-	if (copy_from_user(*hdr_pp, uhdr, hdr.ioc_len)) {
-		err = -EFAULT;
-		goto free;
-	}
-
-	if ((*hdr_pp)->ioc_version != hdr.ioc_version ||
-	    (*hdr_pp)->ioc_len != hdr.ioc_len) {
-		err = -EINVAL;
-		goto free;
-	}
-
-	return 0;
-
-free:
-	kvfree(*hdr_pp);
-	return err;
-}
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 3fb150a57f49..4c4bf09a78dd 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -95,6 +95,137 @@ int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand)
 }
 EXPORT_SYMBOL(libcfs_deregister_ioctl);
 
+static inline size_t libcfs_ioctl_packlen(struct libcfs_ioctl_data *data)
+{
+	size_t len = sizeof(*data);
+
+	len += cfs_size_round(data->ioc_inllen1);
+	len += cfs_size_round(data->ioc_inllen2);
+	return len;
+}
+
+static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
+{
+	if (data->ioc_hdr.ioc_len > BIT(30)) {
+		CERROR("LIBCFS ioctl: ioc_len larger than 1<<30\n");
+		return true;
+	}
+	if (data->ioc_inllen1 > BIT(30)) {
+		CERROR("LIBCFS ioctl: ioc_inllen1 larger than 1<<30\n");
+		return true;
+	}
+	if (data->ioc_inllen2 > BIT(30)) {
+		CERROR("LIBCFS ioctl: ioc_inllen2 larger than 1<<30\n");
+		return true;
+	}
+	if (data->ioc_inlbuf1 && !data->ioc_inllen1) {
+		CERROR("LIBCFS ioctl: inlbuf1 pointer but 0 length\n");
+		return true;
+	}
+	if (data->ioc_inlbuf2 && !data->ioc_inllen2) {
+		CERROR("LIBCFS ioctl: inlbuf2 pointer but 0 length\n");
+		return true;
+	}
+	if (data->ioc_pbuf1 && !data->ioc_plen1) {
+		CERROR("LIBCFS ioctl: pbuf1 pointer but 0 length\n");
+		return true;
+	}
+	if (data->ioc_pbuf2 && !data->ioc_plen2) {
+		CERROR("LIBCFS ioctl: pbuf2 pointer but 0 length\n");
+		return true;
+	}
+	if (data->ioc_plen1 && !data->ioc_pbuf1) {
+		CERROR("LIBCFS ioctl: plen1 nonzero but no pbuf1 pointer\n");
+		return true;
+	}
+	if (data->ioc_plen2 && !data->ioc_pbuf2) {
+		CERROR("LIBCFS ioctl: plen2 nonzero but no pbuf2 pointer\n");
+		return true;
+	}
+	if ((u32)libcfs_ioctl_packlen(data) != data->ioc_hdr.ioc_len) {
+		CERROR("LIBCFS ioctl: packlen != ioc_len\n");
+		return true;
+	}
+	if (data->ioc_inllen1 &&
+	    data->ioc_bulk[data->ioc_inllen1 - 1] != '\0') {
+		CERROR("LIBCFS ioctl: inlbuf1 not 0 terminated\n");
+		return true;
+	}
+	if (data->ioc_inllen2 &&
+	    data->ioc_bulk[cfs_size_round(data->ioc_inllen1) +
+			   data->ioc_inllen2 - 1] != '\0') {
+		CERROR("LIBCFS ioctl: inlbuf2 not 0 terminated\n");
+		return true;
+	}
+	return false;
+}
+
+static int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data)
+{
+	if (libcfs_ioctl_is_invalid(data)) {
+		CERROR("libcfs ioctl: parameter not correctly formatted\n");
+		return -EINVAL;
+	}
+
+	if (data->ioc_inllen1)
+		data->ioc_inlbuf1 = &data->ioc_bulk[0];
+
+	if (data->ioc_inllen2)
+		data->ioc_inlbuf2 = &data->ioc_bulk[0] +
+			cfs_size_round(data->ioc_inllen1);
+
+	return 0;
+}
+
+static int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
+			 const struct libcfs_ioctl_hdr __user *uhdr)
+{
+	struct libcfs_ioctl_hdr hdr;
+	int err;
+
+	if (copy_from_user(&hdr, uhdr, sizeof(hdr)))
+		return -EFAULT;
+
+	if (hdr.ioc_version != LIBCFS_IOCTL_VERSION &&
+	    hdr.ioc_version != LIBCFS_IOCTL_VERSION2) {
+		CERROR("libcfs ioctl: version mismatch expected %#x, got %#x\n",
+		       LIBCFS_IOCTL_VERSION, hdr.ioc_version);
+		return -EINVAL;
+	}
+
+	if (hdr.ioc_len < sizeof(hdr)) {
+		CERROR("libcfs ioctl: user buffer too small for ioctl\n");
+		return -EINVAL;
+	}
+
+	if (hdr.ioc_len > LIBCFS_IOC_DATA_MAX) {
+		CERROR("libcfs ioctl: user buffer is too large %d/%d\n",
+		       hdr.ioc_len, LIBCFS_IOC_DATA_MAX);
+		return -EINVAL;
+	}
+
+	*hdr_pp = kvmalloc(hdr.ioc_len, GFP_KERNEL);
+	if (!*hdr_pp)
+		return -ENOMEM;
+
+	if (copy_from_user(*hdr_pp, uhdr, hdr.ioc_len)) {
+		err = -EFAULT;
+		goto free;
+	}
+
+	if ((*hdr_pp)->ioc_version != hdr.ioc_version ||
+	    (*hdr_pp)->ioc_len != hdr.ioc_len) {
+		err = -EINVAL;
+		goto free;
+	}
+
+	return 0;
+
+free:
+	kvfree(*hdr_pp);
+	return err;
+}
+
 static int libcfs_ioctl(unsigned long cmd, void __user *uparam)
 {
 	struct libcfs_ioctl_data *data = NULL;
