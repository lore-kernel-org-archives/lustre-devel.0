Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CF7CCC0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:59:38 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMFW5vSbz212C;
	Sun, 02 Feb 2025 12:49:51 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMCp0kp9z20vy
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:48:21 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E158D18236D;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id DD766106BE19; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:18 -0500
Message-ID: <20250202204633.1148872-19-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 18/33] lustre: misc: replace obsolete ioctl
 numbers
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
 Vitaliy Kuznetsov <vkuznetsov@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

Renumber the OBD_IOC_BARRIER and IOC_OSC_SET_ACTIVE ioctl numbers
to use IOC type 'f' instead of 'g' and 'h', respectively.  Add
compatibility code to handle their deprecation in the future.

Move already-deprecated ioctls OBD_IOC_GETNAME_OLD, OBD_GET_VERSION,
IOC_LIBCFS_GET_NI, and IOC_LIBCFS_PING to lustre_ioctl_old.h also.
Remove other already obsolete ioctl number definitions.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16634
Lustre-commit: 594b780062db7e015 ("LU-16634 misc: replace obsolete ioctl numbers")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50390
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Vitaliy Kuznetsov <vkuznetsov@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_ioctl_old.h     | 85 ++++++++++++++++++++++++
 fs/lustre/llite/file.c                   | 51 +-------------
 fs/lustre/llite/llite_lib.c              | 11 +--
 fs/lustre/lmv/lmv_obd.c                  |  3 +-
 fs/lustre/lov/lov_obd.c                  |  3 +-
 fs/lustre/mdc/mdc_request.c              |  8 ++-
 fs/lustre/obdclass/class_obd.c           | 16 ++---
 fs/lustre/osc/osc_request.c              |  8 ++-
 include/uapi/linux/lnet/libcfs_ioctl.h   |  7 +-
 include/uapi/linux/lustre/lustre_ioctl.h | 47 +++----------
 include/uapi/linux/lustre/lustre_user.h  | 10 +--
 11 files changed, 128 insertions(+), 121 deletions(-)
 create mode 100644 fs/lustre/include/lustre_ioctl_old.h

diff --git a/fs/lustre/include/lustre_ioctl_old.h b/fs/lustre/include/lustre_ioctl_old.h
new file mode 100644
index 000000000000..0806eafad12b
--- /dev/null
+++ b/fs/lustre/include/lustre_ioctl_old.h
@@ -0,0 +1,85 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * This file is part of Lustre, http://www.lustre.org/
+ *
+ * Compatibility for deprecated ioctls that should no longer be used by tools.
+ *
+ * Copyright (c) 2023, DataDirect Networks Storage, all rights reserved.
+ */
+#ifndef __LUSTRE_IOCTL_OLD_H
+#define __LUSTRE_IOCTL_OLD_H
+
+#include <uapi/linux/lnet/libcfs_ioctl.h> /* for IOCTL_LIBCFS_TYPE */
+
+/* ioctl command is deprecated after release v1.v2 */
+#define case_OBD_IOC_DEPRECATED(cmd, dev, v1, v2)			\
+	case cmd:							\
+	if (LUSTRE_VERSION_CODE > OBD_OCD_VERSION(v1, v2, 53, 0)) {	\
+		static bool printed;					\
+		obd_ioctl_msg(__FILE__, __func__, __LINE__,		\
+			      printed ? D_IOCTL : D_WARNING, dev, cmd,	\
+			      "deprecated " #cmd " usage", 0);		\
+		printed = true;						\
+	}
+
+#define case_OBD_IOC_DEPRECATED_FT(cmd, dev, v1, v2)			\
+	case_OBD_IOC_DEPRECATED(cmd, dev, v1, v2)			\
+	fallthrough
+
+#if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(2, 19, 53, 0)
+#define OBD_GET_VERSION		_IOWR('f', 144, OBD_IOC_DATA_TYPE) /*< 2.8.55 */
+#endif
+
+#if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(2, 99, 53, 0)
+/* for binary compatibility until 3.0, no more compiling into tools */
+#define OBD_IOC_GETNAME_OLD	_IOWR('f', 131, OBD_IOC_DATA_TYPE) /*< 2.14.52*/
+
+#define IOC_LIBCFS_GET_NI	_IOWR('e', 50, IOCTL_LIBCFS_TYPE)  /*< 2.15.53*/
+#define IOC_LIBCFS_PING		_IOWR('e', 61, IOCTL_LIBCFS_TYPE)  /*< 2.15.53*/
+
+#if LUSTRE_VERSION_CODE >= OBD_OCD_VERSION(2, 19, 53, 0)
+#define OBD_IOC_BARRIER		_IOWR('g', 5, OBD_IOC_DATA_TYPE)   /*< 2.16.55*/
+#define IOC_OSC_SET_ACTIVE	_IOWR('h', 21, void *)		   /*< 2.16.55*/
+#endif
+
+#endif /* OBD_OCD_VERSION(2, 99, 53, 0) */
+
+/* We don't need *_ALLOW() macros for most ioctls, just a few using a bad
+ * _IOC_TYPE value (i.e. not 'f') so that "early exit" type checks work.
+ */
+#define OBD_IOC_CMD_LATE(cmd, name) unlikely(cmd == name)
+#define OBD_IOC_CMD_GONE(cmd, name) (false)
+
+#ifdef OBD_IOC_BARRIER
+#define OBD_IOC_BARRIER_ALLOW(cmd) OBD_IOC_CMD_LATE(cmd, OBD_IOC_BARRIER)
+#else
+#define OBD_IOC_BARRIER_ALLOW(cmd) OBD_IOC_CMD_GONE(cmd)
+#endif
+#ifdef IOC_OSC_SET_ACTIVE
+#define IOC_OSC_SET_ACTIVE_ALLOW(cmd) OBD_IOC_CMD_LATE(cmd, IOC_OSC_SET_ACTIVE)
+#else
+#define IOC_OSC_SET_ACTIVE_ALLOW(cmd) OBD_IOC_CMD_GONE(cmd)
+#endif
+
+#endif /* __LUSTRE_IOCTL_OLD_H */
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 84c204e5f9ee..fc9095279a4b 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4204,39 +4204,10 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case LL_IOC_LOV_GETSTRIPE:
 	case LL_IOC_LOV_GETSTRIPE_NEW:
 		return ll_file_getstripe(inode, uarg, 0);
-	case FS_IOC_GETFLAGS:
-	case FS_IOC_SETFLAGS:
-		return ll_iocontrol(inode, file, cmd, uarg);
-	case FSFILT_IOC_GETVERSION:
-	case FS_IOC_GETVERSION:
-		return put_user(inode->i_generation, (int __user *)arg);
-	/* We need to special case any other ioctls we want to handle,
-	 * to send them to the MDS/OST as appropriate and to properly
-	 * network encode the arg field.
-	 */
-	case FS_IOC_SETVERSION:
-		return -ENOTSUPP;
-
 	case LL_IOC_GROUP_LOCK:
 		return ll_get_grouplock(inode, file, arg);
 	case LL_IOC_GROUP_UNLOCK:
 		return ll_put_grouplock(inode, file, arg);
-	case IOC_OBD_STATFS:
-		return ll_obd_statfs(inode, uarg);
-
-	case LL_IOC_FLUSHCTX:
-		return ll_flush_ctx(inode);
-	case LL_IOC_PATH2FID: {
-		if (copy_to_user(uarg, ll_inode2fid(inode),
-				 sizeof(struct lu_fid)))
-			return -EFAULT;
-
-		return 0;
-	}
-	case LL_IOC_GETPARENT:
-		return ll_getparent(file, (struct getparent __user *)arg);
-	case OBD_IOC_FID2PATH:
-		return ll_fid2path(inode, uarg);
 	case LL_IOC_DATA_VERSION: {
 		struct ioc_data_version	idv;
 		int rc;
@@ -4246,31 +4217,11 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		idv.idv_flags &= LL_DV_RD_FLUSH | LL_DV_WR_FLUSH;
 		rc = ll_ioc_data_version(inode, &idv);
-		if (rc == 0 && copy_to_user(uarg, &idv,
-					    sizeof(idv)))
+		if (rc == 0 && copy_to_user(uarg, &idv, sizeof(idv)))
 			return -EFAULT;
 
 		return rc;
 	}
-
-	case LL_IOC_GET_MDTIDX: {
-		int mdtidx;
-
-		mdtidx = ll_get_mdt_idx(inode);
-		if (mdtidx < 0)
-			return mdtidx;
-
-		if (put_user(mdtidx, (int __user *)uarg))
-			return -EFAULT;
-
-		return 0;
-	}
-	case OBD_IOC_GETNAME_OLD:
-		fallthrough;
-	case OBD_IOC_GETDTNAME:
-		fallthrough;
-	case OBD_IOC_GETMDNAME:
-		return ll_get_obd_name(inode, cmd, uarg);
 	case LL_IOC_HSM_STATE_GET: {
 		struct md_op_data *op_data;
 		struct hsm_user_state *hus;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 7efa5b0246b8..b158eccc16c8 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -52,6 +52,7 @@
 
 #include <linux/libcfs/libcfs_cpu.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
+#include <lustre_ioctl_old.h>
 #include <lustre_ha.h>
 #include <lustre_dlm.h>
 #include <lprocfs_status.h>
@@ -3059,8 +3060,10 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 	case OBD_IOC_FID2PATH:
 		rc = ll_fid2path(inode, uarg);
 		break;
-	case OBD_IOC_GETNAME_OLD:
-		fallthrough;
+#ifdef OBD_IOC_GETNAME_OLD
+	case_OBD_IOC_DEPRECATED_FT(OBD_IOC_GETNAME_OLD,
+				   sbi->ll_md_exp->exp_obd->obd_name, 2, 16);
+#endif
 	case OBD_IOC_GETDTNAME:
 		fallthrough;
 	case OBD_IOC_GETMDNAME:
@@ -3119,10 +3122,10 @@ void ll_umount_begin(struct super_block *sb)
 
 	ioc_data = kzalloc(sizeof(*ioc_data), GFP_NOFS);
 	if (ioc_data) {
-		obd_iocontrol(IOC_OSC_SET_ACTIVE, sbi->ll_md_exp,
+		obd_iocontrol(OBD_IOC_SET_ACTIVE, sbi->ll_md_exp,
 			      sizeof(*ioc_data), ioc_data, NULL);
 
-		obd_iocontrol(IOC_OSC_SET_ACTIVE, sbi->ll_dt_exp,
+		obd_iocontrol(OBD_IOC_SET_ACTIVE, sbi->ll_dt_exp,
 			      sizeof(*ioc_data), ioc_data, NULL);
 
 		kfree(ioc_data);
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 27c1df26849c..f7c7826d0baf 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -51,6 +51,7 @@
 #include <cl_object.h>
 #include <lustre_fid.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
+#include <lustre_ioctl_old.h>
 #include <lustre_kernelcomm.h>
 #include "lmv_internal.h"
 
@@ -838,7 +839,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		return -ENOTTY;
 
 	/* exit early for unknown ioctl types */
-	if (unlikely(_IOC_TYPE(cmd) != 'f' && cmd != IOC_OSC_SET_ACTIVE))
+	if (unlikely(_IOC_TYPE(cmd) != 'f' && !IOC_OSC_SET_ACTIVE_ALLOW(cmd)))
 		return OBD_IOC_ERROR(obd->obd_name, cmd, "unknown", -ENOTTY);
 
 	/* handle commands that don't use @karg first */
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index a152f0b2d2ec..392395f4c35e 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -47,6 +47,7 @@
 #include <cl_object.h>
 #include <lustre_dlm.h>
 #include <lustre_fid.h>
+#include <lustre_ioctl_old.h>
 #include <lustre_lib.h>
 #include <lustre_net.h>
 #include <uapi/linux/lustre/lustre_param.h>
@@ -974,7 +975,7 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	       exp->exp_obd->obd_name, cmd, len, karg, uarg);
 
 	/* exit early for unknown ioctl types */
-	if (unlikely(_IOC_TYPE(cmd) != 'f' && cmd != IOC_OSC_SET_ACTIVE))
+	if (unlikely(_IOC_TYPE(cmd) != 'f' && !IOC_OSC_SET_ACTIVE_ALLOW(cmd)))
 		return OBD_IOC_DEBUG(D_IOCTL, obd->obd_name, cmd, "unknown",
 				     -ENOTTY);
 
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 55a7b5cf1249..5919e5952c0e 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -49,12 +49,13 @@
 #include <lustre_acl.h>
 #include <lustre_fid.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
+#include <lustre_ioctl_old.h>
 #include <lustre_kernelcomm.h>
 #include <lustre_lmv.h>
 #include <lustre_log.h>
+#include <lustre_osc.h>
 #include <lustre_swab.h>
 #include <obd_class.h>
-#include <lustre_osc.h>
 
 #include "mdc_internal.h"
 
@@ -2260,7 +2261,10 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 			goto out;
 		rc = 0;
 		goto out;
-	case IOC_OSC_SET_ACTIVE:
+#ifdef IOC_OSC_SET_ACTIVE
+	case_OBD_IOC_DEPRECATED_FT(IOC_OSC_SET_ACTIVE, obd->obd_name, 2, 17);
+#endif
+	case OBD_IOC_SET_ACTIVE:
 		rc = ptlrpc_set_import_active(imp, data->ioc_offset);
 		goto out;
 
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index dabd40da5912..ab27cf23ca9a 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -47,6 +47,7 @@
 #include <uapi/linux/lustre/lustre_ioctl.h>
 #include <uapi/linux/lnet/libcfs_ioctl.h>
 #include "llog_internal.h"
+#include <lustre_ioctl_old.h>
 
 /* The following are visible and mutable through /sys/fs/lustre. */
 unsigned int obd_debug_peer_on_timeout;
@@ -341,14 +342,8 @@ int class_handle_ioctl(unsigned int cmd, void __user *uarg)
 		goto out;
 	}
 
-	case OBD_GET_VERSION: {
-		/* This was the method to pass to user land the lustre version.
-		 * Today that information is in the sysfs tree so we can in the
-		 * future remove this.
-		 */
-		BUILD_BUG_ON(OBD_OCD_VERSION(3, 0, 53, 0) <=
-			     LUSTRE_VERSION_CODE);
-
+#ifdef OBD_GET_VERSION
+	case_OBD_IOC_DEPRECATED(OBD_GET_VERSION, "obdclass", 2, 15)
 		if (!data->ioc_inlbuf1) {
 			rc = OBD_IOC_ERROR("obdclass", cmd, "no buffer passed",
 					   -EINVAL);
@@ -361,16 +356,13 @@ int class_handle_ioctl(unsigned int cmd, void __user *uarg)
 			goto out;
 		}
 
-		WARN_ONCE(1,
-			  "ioctl(OBD_GET_VERSION) is deprecated, use llapi_get_version_string() and/or relink\n");
-
 		memcpy(data->ioc_bulk, LUSTRE_VERSION_STRING,
 		       strlen(LUSTRE_VERSION_STRING) + 1);
 
 		if (copy_to_user(uarg, data, len))
 			rc = -EFAULT;
 		goto out;
-	}
+#endif
 	case OBD_IOC_NAME2DEV: {
 		/* Resolve a device name.  This does not change the
 		 * currently selected device.
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 582cd96c304b..128b7d15d760 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -46,11 +46,12 @@
 #include <lustre_ha.h>
 #include <lprocfs_status.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
+#include <lustre_ioctl_old.h>
 #include <lustre_obdo.h>
+#include <lustre_osc.h>
 #include <lustre_fid.h>
 #include <obd_class.h>
 #include <obd.h>
-#include <lustre_osc.h>
 
 #include "osc_internal.h"
 
@@ -3397,7 +3398,10 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		data = karg;
 		rc = obd_getattr(NULL, exp, &data->ioc_obdo1);
 		break;
-	case IOC_OSC_SET_ACTIVE:
+#ifdef IOC_OSC_SET_ACTIVE
+	case_OBD_IOC_DEPRECATED_FT(IOC_OSC_SET_ACTIVE, obd->obd_name, 2, 17);
+#endif
+	case OBD_IOC_SET_ACTIVE:
 		if (unlikely(!karg)) {
 			OBD_IOC_ERROR(obd->obd_name, cmd, "karg=NULL",
 				      rc = -EINVAL);
diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index a77a736c1107..98b61b1f1292 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -89,20 +89,19 @@ struct libcfs_ioctl_data {
 #define IOC_LIBCFS_TYPE			('e')
 #define IOC_LIBCFS_MIN_NR		30
 /* libcfs ioctls */
-/* IOC_LIBCFS_PANIC obsolete in 2.8.0, was _IOWR('e', 30, IOCTL_LIBCFS_TYPE) */
+/* XXX: all of these ioctl definitions are broken, the first parameter
+ * should be IOCTL_LIBCFS_TYPE and the last parameter is the struct size.
+ */
 #define IOC_LIBCFS_CLEAR_DEBUG		_IOWR('e', 31, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_MARK_DEBUG		_IOWR('e', 32, IOCTL_LIBCFS_TYPE)
-/* IOC_LIBCFS_MEMHOG obsolete in 2.8.0, was _IOWR('e', 36, IOCTL_LIBCFS_TYPE) */
 /* lnet ioctls */
 #define IOC_LIBCFS_GET_NI		_IOWR('e', 50, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_FAIL_NID		_IOWR('e', 51, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_NOTIFY_ROUTER	_IOWR('e', 55, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_UNCONFIGURE		_IOWR('e', 56, IOCTL_LIBCFS_TYPE)
-/*	 IOC_LIBCFS_PORTALS_COMPATIBILITY  _IOWR('e', 57, IOCTL_LIBCFS_TYPE) */
 #define IOC_LIBCFS_LNET_DIST		_IOWR('e', 58, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_CONFIGURE		_IOWR('e', 59, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_TESTPROTOCOMPAT	_IOWR('e', 60, IOCTL_LIBCFS_TYPE)
-/* IOC_LIBCFS_PING obsolete in 2.16, was _IOWR('e', 61, IOCTL_LIBCFS_TYPE) */
 #define IOC_LIBCFS_PING_PEER		_IOWR('e', 62, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_LNETST		_IOWR('e', 63, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_LNET_FAULT		_IOWR('e', 64, IOCTL_LIBCFS_TYPE)
diff --git a/include/uapi/linux/lustre/lustre_ioctl.h b/include/uapi/linux/lustre/lustre_ioctl.h
index fb1e6f1c5e8c..fa1f802e9391 100644
--- a/include/uapi/linux/lustre/lustre_ioctl.h
+++ b/include/uapi/linux/lustre/lustre_ioctl.h
@@ -32,6 +32,7 @@
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/lustre/lustre_idl.h>
+#include <linux/lustre/lustre_ver.h>
 
 /*
  * sparse kernel source annotations
@@ -134,7 +135,14 @@ static inline __u32 obd_ioctl_packlen(struct obd_ioctl_data *data)
 
 #define OBD_IOC_CREATE		_IOWR('f', 101, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_DESTROY		_IOW('f', 104, OBD_IOC_DATA_TYPE)
-/*	OBD_IOC_PREALLOCATE	_IOWR('f', 105, OBD_IOC_DATA_TYPE) */
+#define OBD_IOC_BARRIER_V2	_IOW('f', 105, struct obd_ioctl_data)
+#define OBD_IOC_SET_ACTIVE	_IOW('f', 106, struct obd_ioctl_data)
+#if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(2, 19, 53, 0)
+/* for API compatibility until 2.19.x, but prefer to use new IOC values above */
+/* OBD_IOC_BARRIER wrongly defined as _IOWR('f', 261, OBD_IOC_DATA_TYPE) */
+#define OBD_IOC_BARRIER		_IOWR('g', 5, OBD_IOC_DATA_TYPE) /* < 2.16 */
+#define IOC_OSC_SET_ACTIVE	_IOWR('h', 21, void *) /* deprecated 2.16 */
+#endif
 
 #define OBD_IOC_SETATTR		_IOW('f', 107, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_GETATTR		_IOWR('f', 108, OBD_IOC_DATA_TYPE)
@@ -150,42 +158,21 @@ static inline __u32 obd_ioctl_packlen(struct obd_ioctl_data *data)
 #define OBD_IOC_GETDTNAME	_IOR('f', 127, char[MAX_OBD_NAME])
 /* ioctl codes 128-143 are reserved for fsverity */
 #define OBD_IOC_UUID2DEV	_IOWR('f', 130, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_GETNAME_OLD	_IOWR('f', 131, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_GETMDNAME	_IOR('f', 131, char[MAX_OBD_NAME])
-/*	OBD_IOC_LOV_GET_CONFIG	_IOWR('f', 132, OBD_IOC_DATA_TYPE) until 2.14 */
 #define OBD_IOC_CLIENT_RECOVER	_IOW('f', 133, OBD_IOC_DATA_TYPE)
 /* ioctl codes 128-143 are reserved for fsverity */
-/* FS_IOC_ENABLE_VERITY		_IOW('f', 133, struct fsverity_enable_arg) */
-/* FS_IOC_MEASURE_VERITY	_IOW('f', 134, struct fsverity_digest) */
-/* was OBD_IOC_NO_TRANSNO	_IOW('f', 140, OBD_IOC_DATA_TYPE) until 2.14 */
 #define OBD_IOC_SET_READONLY	_IOW('f', 141, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_ABORT_RECOVERY	_IOR('f', 142, OBD_IOC_DATA_TYPE)
 /* ioctl codes 128-143 are reserved for fsverity */
-#define OBD_GET_VERSION		_IOWR('f', 144, OBD_IOC_DATA_TYPE)
-/*	OBD_IOC_GSS_SUPPORT	_IOWR('f', 145, OBD_IOC_DATA_TYPE) */
-/*	OBD_IOC_CLOSE_UUID	_IOWR('f', 147, OBD_IOC_DATA_TYPE) */
-/*	OBD_IOC_CHANGELOG_SEND	_IOW('f', 148, OBD_IOC_DATA_TYPE) */
 #define OBD_IOC_GETDEVICE	_IOWR('f', 149, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_FID2PATH	_IOWR('f', 150, OBD_IOC_DATA_TYPE)
-/*	lustre/lustre_user.h	151-153 */
-/*	OBD_IOC_LOV_SETSTRIPE	154 LL_IOC_LOV_SETSTRIPE */
-/*	OBD_IOC_LOV_GETSTRIPE	155 LL_IOC_LOV_GETSTRIPE */
-/*	OBD_IOC_LOV_SETEA	156 LL_IOC_LOV_SETEA */
-/*	lustre/lustre_user.h	157-159 */
-/*	OBD_IOC_QUOTACHECK	_IOW('f', 160, int) */
-/*	OBD_IOC_POLL_QUOTACHECK	_IOR('f', 161, struct if_quotacheck *) */
+/*	lustre/lustre_user.h	151-159 */
 #define OBD_IOC_QUOTACTL	_IOWR('f', 162, struct if_quotactl)
 /*	lustre/lustre_user.h	163-176 */
 #define OBD_IOC_CHANGELOG_REG	_IOW('f', 177, struct obd_ioctl_data)
 #define OBD_IOC_CHANGELOG_DEREG	_IOW('f', 178, struct obd_ioctl_data)
 #define OBD_IOC_CHANGELOG_CLEAR	_IOW('f', 179, struct obd_ioctl_data)
-/*	OBD_IOC_RECORD		_IOWR('f', 180, OBD_IOC_DATA_TYPE) */
-/*	OBD_IOC_ENDRECORD	_IOWR('f', 181, OBD_IOC_DATA_TYPE) */
-/*	OBD_IOC_PARSE		_IOWR('f', 182, OBD_IOC_DATA_TYPE) */
-/*	OBD_IOC_DORECORD	_IOWR('f', 183, OBD_IOC_DATA_TYPE) */
 #define OBD_IOC_PROCESS_CFG	_IOWR('f', 184, OBD_IOC_DATA_TYPE)
-/*	OBD_IOC_DUMP_LOG	_IOWR('f', 185, OBD_IOC_DATA_TYPE) */
-/*	OBD_IOC_CLEAR_LOG	_IOWR('f', 186, OBD_IOC_DATA_TYPE) */
 #define OBD_IOC_PARAM		_IOW('f', 187, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_POOL		_IOWR('f', 188, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_REPLACE_NIDS	_IOWR('f', 189, OBD_IOC_DATA_TYPE)
@@ -196,27 +183,15 @@ static inline __u32 obd_ioctl_packlen(struct obd_ioctl_data *data)
 #define OBD_IOC_LLOG_CANCEL	_IOWR('f', 193, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_LLOG_REMOVE	_IOWR('f', 194, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_LLOG_CHECK	_IOWR('f', 195, OBD_IOC_DATA_TYPE)
-/*	OBD_IOC_LLOG_CATINFO	_IOWR('f', 196, OBD_IOC_DATA_TYPE) */
 #define OBD_IOC_NODEMAP		_IOWR('f', 197, OBD_IOC_DATA_TYPE)
-
-/*	ECHO_IOC_GET_STRIPE	_IOWR('f', 200, OBD_IOC_DATA_TYPE) */
-/*	ECHO_IOC_SET_STRIPE	_IOWR('f', 201, OBD_IOC_DATA_TYPE) */
-/*	ECHO_IOC_ENQUEUE	_IOWR('f', 202, OBD_IOC_DATA_TYPE) */
-/*	ECHO_IOC_CANCEL		_IOWR('f', 203, OBD_IOC_DATA_TYPE) */
-
 #define OBD_IOC_GET_OBJ_VERSION	_IOR('f', 210, OBD_IOC_DATA_TYPE)
-
 /*	lustre/lustre_user.h	212-217 */
-#define OBD_IOC_GET_MNTOPT	_IOW('f', 220, mntopt_t)
 #define OBD_IOC_ECHO_MD		_IOR('f', 221, struct obd_ioctl_data)
 #define OBD_IOC_ECHO_ALLOC_SEQ	_IOWR('f', 222, struct obd_ioctl_data)
 #define OBD_IOC_START_LFSCK	_IOWR('f', 230, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_STOP_LFSCK	_IOW('f', 231, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_QUERY_LFSCK	_IOR('f', 232, struct obd_ioctl_data)
 #define OBD_IOC_CHLG_POLL	_IOR('f', 233, long)
-/*	lustre/lustre_user.h	240-249 */
-/* was LIBCFS_IOC_DEBUG_MASK   _IOWR('f', 250, long) until 2.11 */
-
-#define IOC_OSC_SET_ACTIVE	_IOWR('h', 21, void *)
+/*	lustre/lustre_user.h	240-253 */
 
 #endif /* _UAPI_LUSTRE_IOCTL_H_ */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 8f648ecd91fa..c098d119f18c 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -316,17 +316,10 @@ struct ll_ioc_lease_id {
 #define LL_IOC_LOV_GETSTRIPE		_IOW('f', 155, long)
 #define LL_IOC_LOV_GETSTRIPE_NEW	_IOR('f', 155, struct lov_user_md)
 #define LL_IOC_LOV_SETEA		_IOW('f', 156, long)
-/*	LL_IOC_RECREATE_OBJ		157 obsolete */
-/*	LL_IOC_RECREATE_FID		158 obsolete */
 #define LL_IOC_GROUP_LOCK		_IOW('f', 158, long)
 #define LL_IOC_GROUP_UNLOCK		_IOW('f', 159, long)
-/* #define LL_IOC_QUOTACHECK		160 OBD_IOC_QUOTACHECK */
-/* #define LL_IOC_POLL_QUOTACHECK	161 OBD_IOC_POLL_QUOTACHECK */
-/* #define LL_IOC_QUOTACTL		162 OBD_IOC_QUOTACTL */
 #define IOC_OBD_STATFS			_IOWR('f', 164, struct obd_statfs *)
-/*	IOC_LOV_GETINFO			165 obsolete */
 #define LL_IOC_FLUSHCTX			_IOW('f', 166, long)
-/* LL_IOC_RMTACL			167 obsolete */
 #define LL_IOC_GETOBDCOUNT		_IOR('f', 168, long)
 #define LL_IOC_LLOOP_ATTACH		_IOWR('f', 169, long)
 #define LL_IOC_LLOOP_DETACH		_IOWR('f', 170, long)
@@ -350,8 +343,7 @@ struct ll_ioc_lease_id {
 						struct lustre_swap_layouts)
 #define LL_IOC_HSM_ACTION		_IOR('f', 220, \
 						struct hsm_current_action)
-/* see <lustre_lib.h> for ioctl numbers 221-232 */
-
+/* see <lustre_lib.h> for ioctl numbers 221-233 */
 #define LL_IOC_LMV_SETSTRIPE		_IOWR('f', 240, struct lmv_user_md)
 #define LL_IOC_LMV_GETSTRIPE		_IOWR('f', 241, struct lmv_user_md)
 #define LL_IOC_RMFID			_IOR('f', 242, struct fid_array)
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
