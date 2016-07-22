From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:49 -0400
Subject: [lustre-devel] [PATCH 56/58] staging: lustre: move ioctls to
	lustre_ioctl.h
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-57-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Move ioctl definitions and related functions from lustre_dlm.h,
lustre_lib.h, obd.h, to lustre_ioctl.h. Replace the definitions of
retired ioctls with comment.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4961
Reviewed-on: http://review.whamcloud.com/10139
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Robert Read <robert.read@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_ioctl.h    |  412 ++++++++++++++++++++
 .../lustre/lustre/include/lustre/lustre_user.h     |   21 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   10 -
 drivers/staging/lustre/lustre/include/lustre_lib.h |  284 --------------
 drivers/staging/lustre/lustre/include/obd.h        |   10 -
 drivers/staging/lustre/lustre/llite/dir.c          |    9 +-
 drivers/staging/lustre/lustre/llite/file.c         |    1 +
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    1 +
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    1 +
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    1 +
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    1 +
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    8 +-
 .../lustre/lustre/obdclass/linux/linux-module.c    |    1 +
 .../staging/lustre/lustre/obdclass/obd_config.c    |    1 +
 .../staging/lustre/lustre/obdecho/echo_client.c    |    1 +
 drivers/staging/lustre/lustre/osc/osc_request.c    |    1 +
 16 files changed, 430 insertions(+), 333 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
new file mode 100644
index 0000000..f3d7c94
--- /dev/null
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
@@ -0,0 +1,412 @@
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
+ * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2011, 2015, Intel Corporation.
+ */
+#ifndef LUSTRE_IOCTL_H_
+#define LUSTRE_IOCTL_H_
+
+#include <linux/types.h>
+#include "../../../include/linux/libcfs/libcfs.h"
+#include "lustre_idl.h"
+
+#ifdef __KERNEL__
+# include <linux/ioctl.h>
+# include <linux/string.h>
+# include "../obd_support.h"
+#else /* __KERNEL__ */
+# include <malloc.h>
+# include <string.h>
+#include <libcfs/util/ioctl.h>
+#endif /* !__KERNEL__ */
+
+#if !defined(__KERNEL__) && !defined(LUSTRE_UTILS)
+# error This file is for Lustre internal use only.
+#endif
+
+enum md_echo_cmd {
+	ECHO_MD_CREATE		= 1, /* Open/Create file on MDT */
+	ECHO_MD_MKDIR		= 2, /* Mkdir on MDT */
+	ECHO_MD_DESTROY		= 3, /* Unlink file on MDT */
+	ECHO_MD_RMDIR		= 4, /* Rmdir on MDT */
+	ECHO_MD_LOOKUP		= 5, /* Lookup on MDT */
+	ECHO_MD_GETATTR		= 6, /* Getattr on MDT */
+	ECHO_MD_SETATTR		= 7, /* Setattr on MDT */
+	ECHO_MD_ALLOC_FID	= 8, /* Get FIDs from MDT */
+};
+
+#define OBD_DEV_ID 1
+#define OBD_DEV_NAME "obd"
+#define OBD_DEV_PATH "/dev/" OBD_DEV_NAME
+#define OBD_DEV_MAJOR 10
+#define OBD_DEV_MINOR 241
+
+#define OBD_IOCTL_VERSION	0x00010004
+#define OBD_DEV_BY_DEVNAME	0xffffd0de
+#define OBD_MAX_IOCTL_BUFFER	CONFIG_LUSTRE_OBD_MAX_IOCTL_BUFFER
+
+struct obd_ioctl_data {
+	__u32		ioc_len;
+	__u32		ioc_version;
+
+	union {
+		__u64	ioc_cookie;
+		__u64	ioc_u64_1;
+	};
+	union {
+		__u32	ioc_conn1;
+		__u32	ioc_u32_1;
+	};
+	union {
+		__u32	ioc_conn2;
+		__u32	ioc_u32_2;
+	};
+
+	struct obdo	ioc_obdo1;
+	struct obdo	ioc_obdo2;
+
+	__u64		ioc_count;
+	__u64		ioc_offset;
+	__u32		ioc_dev;
+	__u32		ioc_command;
+
+	__u64		ioc_nid;
+	__u32		ioc_nal;
+	__u32		ioc_type;
+
+	/* buffers the kernel will treat as user pointers */
+	__u32		ioc_plen1;
+	char __user    *ioc_pbuf1;
+	__u32		ioc_plen2;
+	char __user    *ioc_pbuf2;
+
+	/* inline buffers for various arguments */
+	__u32		ioc_inllen1;
+	char	       *ioc_inlbuf1;
+	__u32		ioc_inllen2;
+	char	       *ioc_inlbuf2;
+	__u32		ioc_inllen3;
+	char	       *ioc_inlbuf3;
+	__u32		ioc_inllen4;
+	char	       *ioc_inlbuf4;
+
+	char		ioc_bulk[0];
+};
+
+struct obd_ioctl_hdr {
+	__u32		ioc_len;
+	__u32		ioc_version;
+};
+
+static inline __u32 obd_ioctl_packlen(struct obd_ioctl_data *data)
+{
+	__u32 len = cfs_size_round(sizeof(*data));
+
+	len += cfs_size_round(data->ioc_inllen1);
+	len += cfs_size_round(data->ioc_inllen2);
+	len += cfs_size_round(data->ioc_inllen3);
+	len += cfs_size_round(data->ioc_inllen4);
+
+	return len;
+}
+
+static inline int obd_ioctl_is_invalid(struct obd_ioctl_data *data)
+{
+	if (data->ioc_len > (1 << 30)) {
+		CERROR("OBD ioctl: ioc_len larger than 1<<30\n");
+		return 1;
+	}
+
+	if (data->ioc_inllen1 > (1 << 30)) {
+		CERROR("OBD ioctl: ioc_inllen1 larger than 1<<30\n");
+		return 1;
+	}
+
+	if (data->ioc_inllen2 > (1 << 30)) {
+		CERROR("OBD ioctl: ioc_inllen2 larger than 1<<30\n");
+		return 1;
+	}
+
+	if (data->ioc_inllen3 > (1 << 30)) {
+		CERROR("OBD ioctl: ioc_inllen3 larger than 1<<30\n");
+		return 1;
+	}
+
+	if (data->ioc_inllen4 > (1 << 30)) {
+		CERROR("OBD ioctl: ioc_inllen4 larger than 1<<30\n");
+		return 1;
+	}
+
+	if (data->ioc_inlbuf1 && !data->ioc_inllen1) {
+		CERROR("OBD ioctl: inlbuf1 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (data->ioc_inlbuf2 && !data->ioc_inllen2) {
+		CERROR("OBD ioctl: inlbuf2 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (data->ioc_inlbuf3 && !data->ioc_inllen3) {
+		CERROR("OBD ioctl: inlbuf3 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (data->ioc_inlbuf4 && !data->ioc_inllen4) {
+		CERROR("OBD ioctl: inlbuf4 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (data->ioc_pbuf1 && !data->ioc_plen1) {
+		CERROR("OBD ioctl: pbuf1 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (data->ioc_pbuf2 && !data->ioc_plen2) {
+		CERROR("OBD ioctl: pbuf2 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (!data->ioc_pbuf1 && data->ioc_plen1) {
+		CERROR("OBD ioctl: plen1 set but NULL pointer\n");
+		return 1;
+	}
+
+	if (!data->ioc_pbuf2 && data->ioc_plen2) {
+		CERROR("OBD ioctl: plen2 set but NULL pointer\n");
+		return 1;
+	}
+
+	if (obd_ioctl_packlen(data) > data->ioc_len) {
+		CERROR("OBD ioctl: packlen exceeds ioc_len (%d > %d)\n",
+		       obd_ioctl_packlen(data), data->ioc_len);
+		return 1;
+	}
+
+	return 0;
+}
+
+#ifdef __KERNEL__
+
+int obd_ioctl_getdata(char **buf, int *len, void __user *arg);
+int obd_ioctl_popdata(void __user *arg, void *data, int len);
+
+static inline void obd_ioctl_freedata(char *buf, size_t len)
+{
+	kvfree(buf);
+}
+
+#else /* __KERNEL__ */
+
+static inline int obd_ioctl_pack(struct obd_ioctl_data *data, char **pbuf,
+				 int max_len)
+{
+	char *ptr;
+	struct obd_ioctl_data *overlay;
+
+	data->ioc_len = obd_ioctl_packlen(data);
+	data->ioc_version = OBD_IOCTL_VERSION;
+
+	if (*pbuf && data->ioc_len > max_len) {
+		fprintf(stderr, "pbuf = %p, ioc_len = %u, max_len = %d\n",
+			*pbuf, data->ioc_len, max_len);
+		return -EINVAL;
+	}
+
+	if (!*pbuf)
+		*pbuf = malloc(data->ioc_len);
+
+	if (!*pbuf)
+		return -ENOMEM;
+
+	overlay = (struct obd_ioctl_data *)*pbuf;
+	memcpy(*pbuf, data, sizeof(*data));
+
+	ptr = overlay->ioc_bulk;
+	if (data->ioc_inlbuf1)
+		LOGL(data->ioc_inlbuf1, data->ioc_inllen1, ptr);
+
+	if (data->ioc_inlbuf2)
+		LOGL(data->ioc_inlbuf2, data->ioc_inllen2, ptr);
+
+	if (data->ioc_inlbuf3)
+		LOGL(data->ioc_inlbuf3, data->ioc_inllen3, ptr);
+
+	if (data->ioc_inlbuf4)
+		LOGL(data->ioc_inlbuf4, data->ioc_inllen4, ptr);
+
+	if (obd_ioctl_is_invalid(overlay)) {
+		fprintf(stderr, "invalid ioctl data: ioc_len = %u, max_len = %d\n",
+			data->ioc_len, max_len);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static inline int
+obd_ioctl_unpack(struct obd_ioctl_data *data, char *pbuf, int max_len)
+{
+	char *ptr;
+	struct obd_ioctl_data *overlay;
+
+	if (!pbuf)
+		return 1;
+
+	overlay = (struct obd_ioctl_data *)pbuf;
+
+	/* Preserve the caller's buffer pointers */
+	overlay->ioc_inlbuf1 = data->ioc_inlbuf1;
+	overlay->ioc_inlbuf2 = data->ioc_inlbuf2;
+	overlay->ioc_inlbuf3 = data->ioc_inlbuf3;
+	overlay->ioc_inlbuf4 = data->ioc_inlbuf4;
+
+	memcpy(data, pbuf, sizeof(*data));
+
+	ptr = overlay->ioc_bulk;
+	if (data->ioc_inlbuf1)
+		LOGU(data->ioc_inlbuf1, data->ioc_inllen1, ptr);
+
+	if (data->ioc_inlbuf2)
+		LOGU(data->ioc_inlbuf2, data->ioc_inllen2, ptr);
+
+	if (data->ioc_inlbuf3)
+		LOGU(data->ioc_inlbuf3, data->ioc_inllen3, ptr);
+
+	if (data->ioc_inlbuf4)
+		LOGU(data->ioc_inlbuf4, data->ioc_inllen4, ptr);
+
+	return 0;
+}
+
+#endif /* !__KERNEL__ */
+
+/*
+ * OBD_IOC_DATA_TYPE is only for compatibility reasons with older
+ * Linux Lustre user tools. New ioctls should NOT use this macro as
+ * the ioctl "size". Instead the ioctl should get a "size" argument
+ * which is the actual data type used by the ioctl, to ensure the
+ * ioctl interface is versioned correctly.
+ */
+#define OBD_IOC_DATA_TYPE	long
+
+/*	IOC_LDLM_TEST		_IOWR('f', 40, long) */
+/*	IOC_LDLM_DUMP		_IOWR('f', 41, long) */
+/*	IOC_LDLM_REGRESS_START	_IOWR('f', 42, long) */
+/*	IOC_LDLM_REGRESS_STOP	_IOWR('f', 43, long) */
+
+#define OBD_IOC_CREATE		_IOWR('f', 101, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_DESTROY		_IOW('f', 104, OBD_IOC_DATA_TYPE)
+/*	OBD_IOC_PREALLOCATE	_IOWR('f', 105, OBD_IOC_DATA_TYPE) */
+
+#define OBD_IOC_SETATTR		_IOW('f', 107, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_GETATTR		_IOWR('f', 108, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_READ		_IOWR('f', 109, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_WRITE		_IOWR('f', 110, OBD_IOC_DATA_TYPE)
+
+#define OBD_IOC_STATFS		_IOWR('f', 113, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_SYNC		_IOW('f', 114, OBD_IOC_DATA_TYPE)
+/*	OBD_IOC_READ2		_IOWR('f', 115, OBD_IOC_DATA_TYPE) */
+/*	OBD_IOC_FORMAT		_IOWR('f', 116, OBD_IOC_DATA_TYPE) */
+/*	OBD_IOC_PARTITION	_IOWR('f', 117, OBD_IOC_DATA_TYPE) */
+/*	OBD_IOC_COPY		_IOWR('f', 120, OBD_IOC_DATA_TYPE) */
+/*	OBD_IOC_MIGR		_IOWR('f', 121, OBD_IOC_DATA_TYPE) */
+/*	OBD_IOC_PUNCH		_IOWR('f', 122, OBD_IOC_DATA_TYPE) */
+
+/*	OBD_IOC_MODULE_DEBUG	_IOWR('f', 124, OBD_IOC_DATA_TYPE) */
+#define OBD_IOC_BRW_READ	_IOWR('f', 125, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_BRW_WRITE	_IOWR('f', 126, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_NAME2DEV	_IOWR('f', 127, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_UUID2DEV	_IOWR('f', 130, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_GETNAME		_IOWR('f', 131, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_GETMDNAME	_IOR('f', 131, char[MAX_OBD_NAME])
+#define OBD_IOC_GETDTNAME	OBD_IOC_GETNAME
+#define OBD_IOC_LOV_GET_CONFIG	_IOWR('f', 132, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_CLIENT_RECOVER	_IOW('f', 133, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_PING_TARGET	_IOW('f', 136, OBD_IOC_DATA_TYPE)
+
+/*	OBD_IOC_DEC_FS_USE_COUNT _IO('f', 139) */
+#define OBD_IOC_NO_TRANSNO	_IOW('f', 140, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_SET_READONLY	_IOW('f', 141, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_ABORT_RECOVERY	_IOR('f', 142, OBD_IOC_DATA_TYPE)
+/*	OBD_IOC_ROOT_SQUASH	_IOWR('f', 143, OBD_IOC_DATA_TYPE) */
+#define OBD_GET_VERSION		_IOWR('f', 144, OBD_IOC_DATA_TYPE)
+/*	OBD_IOC_GSS_SUPPORT	_IOWR('f', 145, OBD_IOC_DATA_TYPE) */
+/*	OBD_IOC_CLOSE_UUID	_IOWR('f', 147, OBD_IOC_DATA_TYPE) */
+#define OBD_IOC_CHANGELOG_SEND	_IOW('f', 148, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_GETDEVICE	_IOWR('f', 149, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_FID2PATH	_IOWR('f', 150, OBD_IOC_DATA_TYPE)
+/*	lustre/lustre_user.h	151-153 */
+/*	OBD_IOC_LOV_SETSTRIPE	154 LL_IOC_LOV_SETSTRIPE */
+/*	OBD_IOC_LOV_GETSTRIPE	155 LL_IOC_LOV_GETSTRIPE */
+/*	OBD_IOC_LOV_SETEA	156 LL_IOC_LOV_SETEA */
+/*	lustre/lustre_user.h	157-159 */
+#define	OBD_IOC_QUOTACHECK	_IOW('f', 160, int)
+#define	OBD_IOC_POLL_QUOTACHECK	_IOR('f', 161, struct if_quotacheck *)
+#define OBD_IOC_QUOTACTL	_IOWR('f', 162, struct if_quotactl)
+/*	lustre/lustre_user.h	163-176 */
+#define OBD_IOC_CHANGELOG_REG	_IOW('f', 177, struct obd_ioctl_data)
+#define OBD_IOC_CHANGELOG_DEREG	_IOW('f', 178, struct obd_ioctl_data)
+#define OBD_IOC_CHANGELOG_CLEAR	_IOW('f', 179, struct obd_ioctl_data)
+/*	OBD_IOC_RECORD		_IOWR('f', 180, OBD_IOC_DATA_TYPE) */
+/*	OBD_IOC_ENDRECORD	_IOWR('f', 181, OBD_IOC_DATA_TYPE) */
+/*	OBD_IOC_PARSE		_IOWR('f', 182, OBD_IOC_DATA_TYPE) */
+/*	OBD_IOC_DORECORD	_IOWR('f', 183, OBD_IOC_DATA_TYPE) */
+#define OBD_IOC_PROCESS_CFG	_IOWR('f', 184, OBD_IOC_DATA_TYPE)
+/*	OBD_IOC_DUMP_LOG	_IOWR('f', 185, OBD_IOC_DATA_TYPE) */
+/*	OBD_IOC_CLEAR_LOG	_IOWR('f', 186, OBD_IOC_DATA_TYPE) */
+#define OBD_IOC_PARAM		_IOW('f', 187, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_POOL		_IOWR('f', 188, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_REPLACE_NIDS	_IOWR('f', 189, OBD_IOC_DATA_TYPE)
+
+#define OBD_IOC_CATLOGLIST	_IOWR('f', 190, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_LLOG_INFO	_IOWR('f', 191, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_LLOG_PRINT	_IOWR('f', 192, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_LLOG_CANCEL	_IOWR('f', 193, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_LLOG_REMOVE	_IOWR('f', 194, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_LLOG_CHECK	_IOWR('f', 195, OBD_IOC_DATA_TYPE)
+/*	OBD_IOC_LLOG_CATINFO	_IOWR('f', 196, OBD_IOC_DATA_TYPE) */
+#define OBD_IOC_NODEMAP		_IOWR('f', 197, OBD_IOC_DATA_TYPE)
+
+/*	ECHO_IOC_GET_STRIPE	_IOWR('f', 200, OBD_IOC_DATA_TYPE) */
+/*	ECHO_IOC_SET_STRIPE	_IOWR('f', 201, OBD_IOC_DATA_TYPE) */
+/*	ECHO_IOC_ENQUEUE	_IOWR('f', 202, OBD_IOC_DATA_TYPE) */
+/*	ECHO_IOC_CANCEL		_IOWR('f', 203, OBD_IOC_DATA_TYPE) */
+
+#define OBD_IOC_GET_OBJ_VERSION	_IOR('f', 210, OBD_IOC_DATA_TYPE)
+
+/*	lustre/lustre_user.h	212-217 */
+#define OBD_IOC_GET_MNTOPT	_IOW('f', 220, mntopt_t)
+#define OBD_IOC_ECHO_MD		_IOR('f', 221, struct obd_ioctl_data)
+#define OBD_IOC_ECHO_ALLOC_SEQ	_IOWR('f', 222, struct obd_ioctl_data)
+#define OBD_IOC_START_LFSCK	_IOWR('f', 230, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_STOP_LFSCK	_IOW('f', 231, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_QUERY_LFSCK	_IOR('f', 232, struct obd_ioctl_data)
+/*	lustre/lustre_user.h	240-249 */
+/*	LIBCFS_IOC_DEBUG_MASK	250 */
+
+#define IOC_OSC_SET_ACTIVE	_IOWR('h', 21, void *)
+
+#endif /* LUSTRE_IOCTL_H_ */
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 4746320..75a78a3 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -188,26 +188,20 @@ struct ost_id {
  * *STRIPE* - set/get lov_user_md
  * *INFO    - set/get lov_user_mds_data
  */
-/* see <lustre_lib.h> for ioctl numberss 101-150 */
+/*	lustre_ioctl.h			101-150 */
 #define LL_IOC_GETFLAGS		 _IOR('f', 151, long)
 #define LL_IOC_SETFLAGS		 _IOW('f', 152, long)
 #define LL_IOC_CLRFLAGS		 _IOW('f', 153, long)
-/* LL_IOC_LOV_SETSTRIPE: See also OBD_IOC_LOV_SETSTRIPE */
 #define LL_IOC_LOV_SETSTRIPE	    _IOW('f', 154, long)
-/* LL_IOC_LOV_GETSTRIPE: See also OBD_IOC_LOV_GETSTRIPE */
 #define LL_IOC_LOV_GETSTRIPE	    _IOW('f', 155, long)
-/* LL_IOC_LOV_SETEA: See also OBD_IOC_LOV_SETEA */
 #define LL_IOC_LOV_SETEA		_IOW('f', 156, long)
 #define LL_IOC_RECREATE_OBJ	     _IOW('f', 157, long)
 #define LL_IOC_RECREATE_FID	     _IOW('f', 157, struct lu_fid)
 #define LL_IOC_GROUP_LOCK	       _IOW('f', 158, long)
 #define LL_IOC_GROUP_UNLOCK	     _IOW('f', 159, long)
-/* LL_IOC_QUOTACHECK: See also OBD_IOC_QUOTACHECK */
-#define LL_IOC_QUOTACHECK	       _IOW('f', 160, int)
-/* LL_IOC_POLL_QUOTACHECK: See also OBD_IOC_POLL_QUOTACHECK */
-#define LL_IOC_POLL_QUOTACHECK	  _IOR('f', 161, struct if_quotacheck *)
-/* LL_IOC_QUOTACTL: See also OBD_IOC_QUOTACTL */
-#define LL_IOC_QUOTACTL		 _IOWR('f', 162, struct if_quotactl)
+/* #define LL_IOC_QUOTACHECK		160 OBD_IOC_QUOTACHECK */
+/* #define LL_IOC_POLL_QUOTACHECK	161 OBD_IOC_POLL_QUOTACHECK */
+/* #define LL_IOC_QUOTACTL		162 OBD_IOC_QUOTACTL */
 #define IOC_OBD_STATFS		  _IOWR('f', 164, struct obd_statfs *)
 #define IOC_LOV_GETINFO		 _IOWR('f', 165, struct lov_user_mds_data *)
 #define LL_IOC_FLUSHCTX		 _IOW('f', 166, long)
@@ -221,8 +215,7 @@ struct ost_id {
 #define LL_IOC_GET_CONNECT_FLAGS	_IOWR('f', 174, __u64 *)
 #define LL_IOC_GET_MDTIDX	       _IOR('f', 175, int)
 
-/* see <lustre_lib.h> for ioctl numbers 177-210 */
-
+/*	lustre_ioctl.h			177-210 */
 #define LL_IOC_HSM_STATE_GET		_IOR('f', 211, struct hsm_user_state)
 #define LL_IOC_HSM_STATE_SET		_IOW('f', 212, struct hsm_state_set)
 #define LL_IOC_HSM_CT_START		_IOW('f', 213, struct lustre_kernelcomm)
@@ -255,10 +248,6 @@ struct ost_id {
 #define IOC_MDC_GETFILEINFO     _IOWR(IOC_MDC_TYPE, 22, struct lov_user_mds_data *)
 #define LL_IOC_MDC_GETINFO      _IOWR(IOC_MDC_TYPE, 23, struct lov_user_mds_data *)
 
-/* Keep these for backward compartability. */
-#define LL_IOC_OBD_STATFS       IOC_OBD_STATFS
-#define IOC_MDC_GETSTRIPE       IOC_MDC_GETFILESTRIPE
-
 #define MAX_OBD_NAME 128 /* If this changes, a NEW ioctl must be added */
 
 /* Define O_LOV_DELAY_CREATE to be a mask that is not useful for regular
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index f7805cc..1ec4231 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1282,16 +1282,6 @@ int ldlm_cli_cancel_list(struct list_head *head, int count,
 int intent_disposition(struct ldlm_reply *rep, int flag);
 void intent_set_disposition(struct ldlm_reply *rep, int flag);
 
-/* ioctls for trying requests */
-#define IOC_LDLM_TYPE		   'f'
-#define IOC_LDLM_MIN_NR		 40
-
-#define IOC_LDLM_TEST		   _IOWR('f', 40, long)
-#define IOC_LDLM_DUMP		   _IOWR('f', 41, long)
-#define IOC_LDLM_REGRESS_START	  _IOWR('f', 42, long)
-#define IOC_LDLM_REGRESS_STOP	   _IOWR('f', 43, long)
-#define IOC_LDLM_MAX_NR		 43
-
 /**
  * "Modes" of acquiring lock_res, necessary to tell lockdep that taking more
  * than one lock_res is dead-lock safe.
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index def0193..adb8c47 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -75,7 +75,6 @@ int do_set_info_async(struct obd_import *imp,
 		      struct ptlrpc_request_set *set);
 
 #define OBD_RECOVERY_MAX_TIME (obd_timeout * 18) /* b13079 */
-#define OBD_MAX_IOCTL_BUFFER CONFIG_LUSTRE_OBD_MAX_IOCTL_BUFFER
 
 void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id);
 
@@ -99,289 +98,6 @@ struct obd_client_handle {
 /* statfs_pack.c */
 void statfs_unpack(struct kstatfs *sfs, struct obd_statfs *osfs);
 
-/*
- * For md echo client
- */
-enum md_echo_cmd {
-	ECHO_MD_CREATE       = 1, /* Open/Create file on MDT */
-	ECHO_MD_MKDIR	= 2, /* Mkdir on MDT */
-	ECHO_MD_DESTROY      = 3, /* Unlink file on MDT */
-	ECHO_MD_RMDIR	= 4, /* Rmdir on MDT */
-	ECHO_MD_LOOKUP       = 5, /* Lookup on MDT */
-	ECHO_MD_GETATTR      = 6, /* Getattr on MDT */
-	ECHO_MD_SETATTR      = 7, /* Setattr on MDT */
-	ECHO_MD_ALLOC_FID    = 8, /* Get FIDs from MDT */
-};
-
-/*
- *   OBD IOCTLS
- */
-#define OBD_IOCTL_VERSION 0x00010004
-
-struct obd_ioctl_data {
-	__u32 ioc_len;
-	__u32 ioc_version;
-
-	union {
-		__u64 ioc_cookie;
-		__u64 ioc_u64_1;
-	};
-	union {
-		__u32 ioc_conn1;
-		__u32 ioc_u32_1;
-	};
-	union {
-		__u32 ioc_conn2;
-		__u32 ioc_u32_2;
-	};
-
-	struct obdo ioc_obdo1;
-	struct obdo ioc_obdo2;
-
-	u64	 ioc_count;
-	u64	 ioc_offset;
-	__u32    ioc_dev;
-	__u32    ioc_command;
-
-	__u64 ioc_nid;
-	__u32 ioc_nal;
-	__u32 ioc_type;
-
-	/* buffers the kernel will treat as user pointers */
-	__u32  ioc_plen1;
-	void __user *ioc_pbuf1;
-	__u32  ioc_plen2;
-	void __user *ioc_pbuf2;
-
-	/* inline buffers for various arguments */
-	__u32  ioc_inllen1;
-	char  *ioc_inlbuf1;
-	__u32  ioc_inllen2;
-	char  *ioc_inlbuf2;
-	__u32  ioc_inllen3;
-	char  *ioc_inlbuf3;
-	__u32  ioc_inllen4;
-	char  *ioc_inlbuf4;
-
-	char    ioc_bulk[0];
-};
-
-struct obd_ioctl_hdr {
-	__u32 ioc_len;
-	__u32 ioc_version;
-};
-
-static inline int obd_ioctl_packlen(struct obd_ioctl_data *data)
-{
-	int len = cfs_size_round(sizeof(struct obd_ioctl_data));
-
-	len += cfs_size_round(data->ioc_inllen1);
-	len += cfs_size_round(data->ioc_inllen2);
-	len += cfs_size_round(data->ioc_inllen3);
-	len += cfs_size_round(data->ioc_inllen4);
-	return len;
-}
-
-static inline int obd_ioctl_is_invalid(struct obd_ioctl_data *data)
-{
-	if (data->ioc_len > OBD_MAX_IOCTL_BUFFER) {
-		CERROR("OBD ioctl: ioc_len larger than %d\n",
-		       OBD_MAX_IOCTL_BUFFER);
-		return 1;
-	}
-	if (data->ioc_inllen1 > OBD_MAX_IOCTL_BUFFER) {
-		CERROR("OBD ioctl: ioc_inllen1 larger than ioc_len\n");
-		return 1;
-	}
-	if (data->ioc_inllen2 > OBD_MAX_IOCTL_BUFFER) {
-		CERROR("OBD ioctl: ioc_inllen2 larger than ioc_len\n");
-		return 1;
-	}
-	if (data->ioc_inllen3 > OBD_MAX_IOCTL_BUFFER) {
-		CERROR("OBD ioctl: ioc_inllen3 larger than ioc_len\n");
-		return 1;
-	}
-	if (data->ioc_inllen4 > OBD_MAX_IOCTL_BUFFER) {
-		CERROR("OBD ioctl: ioc_inllen4 larger than ioc_len\n");
-		return 1;
-	}
-	if (data->ioc_inlbuf1 && !data->ioc_inllen1) {
-		CERROR("OBD ioctl: inlbuf1 pointer but 0 length\n");
-		return 1;
-	}
-	if (data->ioc_inlbuf2 && !data->ioc_inllen2) {
-		CERROR("OBD ioctl: inlbuf2 pointer but 0 length\n");
-		return 1;
-	}
-	if (data->ioc_inlbuf3 && !data->ioc_inllen3) {
-		CERROR("OBD ioctl: inlbuf3 pointer but 0 length\n");
-		return 1;
-	}
-	if (data->ioc_inlbuf4 && !data->ioc_inllen4) {
-		CERROR("OBD ioctl: inlbuf4 pointer but 0 length\n");
-		return 1;
-	}
-	if (data->ioc_pbuf1 && !data->ioc_plen1) {
-		CERROR("OBD ioctl: pbuf1 pointer but 0 length\n");
-		return 1;
-	}
-	if (data->ioc_pbuf2 && !data->ioc_plen2) {
-		CERROR("OBD ioctl: pbuf2 pointer but 0 length\n");
-		return 1;
-	}
-	if (data->ioc_plen1 && !data->ioc_pbuf1) {
-		CERROR("OBD ioctl: plen1 set but NULL pointer\n");
-		return 1;
-	}
-	if (data->ioc_plen2 && !data->ioc_pbuf2) {
-		CERROR("OBD ioctl: plen2 set but NULL pointer\n");
-		return 1;
-	}
-	if (obd_ioctl_packlen(data) > data->ioc_len) {
-		CERROR("OBD ioctl: packlen exceeds ioc_len (%d > %d)\n",
-		       obd_ioctl_packlen(data), data->ioc_len);
-		return 1;
-	}
-	return 0;
-}
-
-#include "obd_support.h"
-
-/* function defined in lustre/obdclass/<platform>/<platform>-module.c */
-int obd_ioctl_getdata(char **buf, int *len, void __user *arg);
-int obd_ioctl_popdata(void __user *arg, void *data, int len);
-
-static inline void obd_ioctl_freedata(char *buf, int len)
-{
-	kvfree(buf);
-	return;
-}
-
-/*
- * BSD ioctl description:
- * #define IOC_V1       _IOR(g, n1, long)
- * #define IOC_V2       _IOW(g, n2, long)
- *
- * ioctl(f, IOC_V1, arg);
- * arg will be treated as a long value,
- *
- * ioctl(f, IOC_V2, arg)
- * arg will be treated as a pointer, bsd will call
- * copyin(buf, arg, sizeof(long))
- *
- * To make BSD ioctl handles argument correctly and simplely,
- * we change _IOR to _IOWR so BSD will copyin obd_ioctl_data
- * for us. Does this change affect Linux?  (XXX Liang)
- */
-#define OBD_IOC_DATA_TYPE long
-
-#define OBD_IOC_CREATE		 _IOWR('f', 101, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_DESTROY		_IOW('f', 104, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_PREALLOCATE	    _IOWR('f', 105, OBD_IOC_DATA_TYPE)
-
-#define OBD_IOC_SETATTR		_IOW('f', 107, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_GETATTR		_IOWR ('f', 108, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_READ		   _IOWR('f', 109, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_WRITE		  _IOWR('f', 110, OBD_IOC_DATA_TYPE)
-
-#define OBD_IOC_STATFS		 _IOWR('f', 113, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_SYNC		   _IOW('f', 114, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_READ2		  _IOWR('f', 115, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_FORMAT		 _IOWR('f', 116, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_PARTITION	      _IOWR('f', 117, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_COPY		   _IOWR('f', 120, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_MIGR		   _IOWR('f', 121, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_PUNCH		  _IOWR('f', 122, OBD_IOC_DATA_TYPE)
-
-#define OBD_IOC_MODULE_DEBUG	   _IOWR('f', 124, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_BRW_READ	       _IOWR('f', 125, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_BRW_WRITE	      _IOWR('f', 126, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_NAME2DEV	       _IOWR('f', 127, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_UUID2DEV	       _IOWR('f', 130, OBD_IOC_DATA_TYPE)
-
-#define OBD_IOC_GETNAME		_IOWR('f', 131, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_GETMDNAME	      _IOR('f', 131, char[MAX_OBD_NAME])
-#define OBD_IOC_GETDTNAME	       OBD_IOC_GETNAME
-
-#define OBD_IOC_LOV_GET_CONFIG	 _IOWR('f', 132, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_CLIENT_RECOVER	 _IOW('f', 133, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_PING_TARGET	    _IOW('f', 136, OBD_IOC_DATA_TYPE)
-
-#define OBD_IOC_DEC_FS_USE_COUNT       _IO  ('f', 139)
-#define OBD_IOC_NO_TRANSNO	     _IOW('f', 140, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_SET_READONLY	   _IOW('f', 141, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_ABORT_RECOVERY	 _IOR('f', 142, OBD_IOC_DATA_TYPE)
-
-#define OBD_IOC_ROOT_SQUASH	    _IOWR('f', 143, OBD_IOC_DATA_TYPE)
-
-#define OBD_GET_VERSION		_IOWR ('f', 144, OBD_IOC_DATA_TYPE)
-
-#define OBD_IOC_GSS_SUPPORT	    _IOWR('f', 145, OBD_IOC_DATA_TYPE)
-
-#define OBD_IOC_CLOSE_UUID	     _IOWR ('f', 147, OBD_IOC_DATA_TYPE)
-
-#define OBD_IOC_CHANGELOG_SEND	 _IOW('f', 148, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_GETDEVICE	      _IOWR ('f', 149, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_FID2PATH	       _IOWR ('f', 150, OBD_IOC_DATA_TYPE)
-/* see also <lustre/lustre_user.h> for ioctls 151-153 */
-/* OBD_IOC_LOV_SETSTRIPE: See also LL_IOC_LOV_SETSTRIPE */
-#define OBD_IOC_LOV_SETSTRIPE	  _IOW('f', 154, OBD_IOC_DATA_TYPE)
-/* OBD_IOC_LOV_GETSTRIPE: See also LL_IOC_LOV_GETSTRIPE */
-#define OBD_IOC_LOV_GETSTRIPE	  _IOW('f', 155, OBD_IOC_DATA_TYPE)
-/* OBD_IOC_LOV_SETEA: See also LL_IOC_LOV_SETEA */
-#define OBD_IOC_LOV_SETEA	      _IOW('f', 156, OBD_IOC_DATA_TYPE)
-/* see <lustre/lustre_user.h> for ioctls 157-159 */
-/* OBD_IOC_QUOTACHECK: See also LL_IOC_QUOTACHECK */
-#define OBD_IOC_QUOTACHECK	     _IOW('f', 160, int)
-/* OBD_IOC_POLL_QUOTACHECK: See also LL_IOC_POLL_QUOTACHECK */
-#define OBD_IOC_POLL_QUOTACHECK	_IOR('f', 161, struct if_quotacheck *)
-/* OBD_IOC_QUOTACTL: See also LL_IOC_QUOTACTL */
-#define OBD_IOC_QUOTACTL	       _IOWR('f', 162, struct if_quotactl)
-/* see  also <lustre/lustre_user.h> for ioctls 163-176 */
-#define OBD_IOC_CHANGELOG_REG	  _IOW('f', 177, struct obd_ioctl_data)
-#define OBD_IOC_CHANGELOG_DEREG	_IOW('f', 178, struct obd_ioctl_data)
-#define OBD_IOC_CHANGELOG_CLEAR	_IOW('f', 179, struct obd_ioctl_data)
-#define OBD_IOC_RECORD		 _IOWR('f', 180, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_ENDRECORD	      _IOWR('f', 181, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_PARSE		  _IOWR('f', 182, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_DORECORD	       _IOWR('f', 183, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_PROCESS_CFG	    _IOWR('f', 184, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_DUMP_LOG	       _IOWR('f', 185, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_CLEAR_LOG	      _IOWR('f', 186, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_PARAM		  _IOW('f', 187, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_POOL		   _IOWR('f', 188, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_REPLACE_NIDS	   _IOWR('f', 189, OBD_IOC_DATA_TYPE)
-
-#define OBD_IOC_CATLOGLIST	     _IOWR('f', 190, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_LLOG_INFO	      _IOWR('f', 191, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_LLOG_PRINT	     _IOWR('f', 192, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_LLOG_CANCEL	    _IOWR('f', 193, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_LLOG_REMOVE	    _IOWR('f', 194, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_LLOG_CHECK	     _IOWR('f', 195, OBD_IOC_DATA_TYPE)
-/* OBD_IOC_LLOG_CATINFO is deprecated */
-#define OBD_IOC_LLOG_CATINFO	   _IOWR('f', 196, OBD_IOC_DATA_TYPE)
-
-/*	#define ECHO_IOC_GET_STRIPE    _IOWR('f', 200, OBD_IOC_DATA_TYPE) */
-/*	#define ECHO_IOC_SET_STRIPE    _IOWR('f', 201, OBD_IOC_DATA_TYPE) */
-/*	#define ECHO_IOC_ENQUEUE       _IOWR('f', 202, OBD_IOC_DATA_TYPE) */
-/*	#define ECHO_IOC_CANCEL        _IOWR('f', 203, OBD_IOC_DATA_TYPE) */
-
-#define OBD_IOC_GET_OBJ_VERSION	_IOR('f', 210, OBD_IOC_DATA_TYPE)
-
-/* <lustre/lustre_user.h> defines ioctl number 218-219 */
-#define OBD_IOC_GET_MNTOPT	     _IOW('f', 220, mntopt_t)
-
-#define OBD_IOC_ECHO_MD		_IOR('f', 221, struct obd_ioctl_data)
-#define OBD_IOC_ECHO_ALLOC_SEQ	 _IOWR('f', 222, struct obd_ioctl_data)
-
-#define OBD_IOC_START_LFSCK	       _IOWR('f', 230, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_STOP_LFSCK	       _IOW('f', 231, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_PAUSE_LFSCK	       _IOW('f', 232, OBD_IOC_DATA_TYPE)
-
-/* XXX _IOWR('f', 250, long) has been defined in
- * libcfs/include/libcfs/libcfs_private.h for debug, don't use it
- */
-
 /* Until such time as we get_info the per-stripe maximum from the OST,
  * we define this to be 2T - 4k, which is the ext3 maxbytes.
  */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index cacd472..0dae273 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -35,15 +35,6 @@
 
 #include <linux/spinlock.h>
 
-#define IOC_OSC_TYPE	 'h'
-#define IOC_OSC_MIN_NR       20
-#define IOC_OSC_SET_ACTIVE   _IOWR(IOC_OSC_TYPE, 21, struct obd_device *)
-#define IOC_OSC_MAX_NR       50
-
-#define IOC_MDC_TYPE	 'i'
-#define IOC_MDC_MIN_NR       20
-#define IOC_MDC_MAX_NR       50
-
 #include "lustre/lustre_idl.h"
 #include "lustre_lib.h"
 #include "lu_ref.h"
@@ -623,7 +614,6 @@ struct obd_llog_group {
 
 /* corresponds to one of the obd's */
 #define OBD_DEVICE_MAGIC	0XAB5CD6EF
-#define OBD_DEV_BY_DEVNAME      0xffffd0de
 
 struct lvfs_run_ctxt {
 	struct dt_device *dt;
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 84bec03..257c9a4 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -46,8 +46,8 @@
 
 #include "../include/obd_support.h"
 #include "../include/obd_class.h"
+#include "../include/lustre/lustre_ioctl.h"
 #include "../include/lustre_lib.h"
-#include "../include/lustre/lustre_idl.h"
 #include "../include/lustre_lite.h"
 #include "../include/lustre_dlm.h"
 #include "../include/lustre_fid.h"
@@ -1543,7 +1543,7 @@ finish_req:
 
 	case LL_IOC_LOV_SWAP_LAYOUTS:
 		return -EPERM;
-	case LL_IOC_OBD_STATFS:
+	case IOC_OBD_STATFS:
 		return ll_obd_statfs(inode, (void __user *)arg);
 	case LL_IOC_LOV_GETSTRIPE:
 	case LL_IOC_MDC_GETINFO:
@@ -1708,9 +1708,6 @@ free_lmm:
 		kvfree(lmm);
 		return rc;
 	}
-	case OBD_IOC_LLOG_CATINFO: {
-		return -EOPNOTSUPP;
-	}
 	case OBD_IOC_QUOTACHECK: {
 		struct obd_quotactl *oqctl;
 		int error = 0;
@@ -1768,7 +1765,7 @@ out_poll:
 		kfree(check);
 		return rc;
 	}
-	case LL_IOC_QUOTACTL: {
+	case OBD_IOC_QUOTACTL: {
 		struct if_quotactl *qctl;
 
 		qctl = kzalloc(sizeof(*qctl), GFP_NOFS);
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 1452a14..343f9b9 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -44,6 +44,7 @@
 #include <linux/mount.h>
 #include "llite_internal.h"
 #include "../include/lustre/ll_fiemap.h"
+#include "../include/lustre/lustre_ioctl.h"
 
 #include "../include/cl_object.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index e320400..111264e 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -41,6 +41,7 @@
 #include <linux/types.h>
 #include <linux/mm.h>
 
+#include "../include/lustre/lustre_ioctl.h"
 #include "../include/lustre_lite.h"
 #include "../include/lustre_ha.h"
 #include "../include/lustre_dlm.h"
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index ff0fbd8..18d7ff8 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -51,6 +51,7 @@
 #include "../include/cl_object.h"
 #include "../include/lustre_lite.h"
 #include "../include/lustre_fid.h"
+#include "../include/lustre/lustre_ioctl.h"
 #include "../include/lustre_kernelcomm.h"
 #include "lmv_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 9b92d55..d904f44 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -41,6 +41,7 @@
 #include "../../include/linux/libcfs/libcfs.h"
 
 #include "../include/obd_support.h"
+#include "../include/lustre/lustre_ioctl.h"
 #include "../include/lustre_lib.h"
 #include "../include/lustre_net.h"
 #include "../include/lustre/lustre_idl.h"
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index ce5df23..621ed91 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -39,6 +39,7 @@
 # include <linux/utsname.h>
 
 #include "../include/lustre_acl.h"
+#include "../include/lustre/lustre_ioctl.h"
 #include "../include/obd_class.h"
 #include "../include/lustre_lmv.h"
 #include "../include/lustre_fid.h"
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index d9d2a19..6edf53e 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -40,6 +40,7 @@
 #include "../include/lprocfs_status.h"
 #include <linux/list.h>
 #include "../include/cl_object.h"
+#include "../include/lustre/lustre_ioctl.h"
 #include "llog_internal.h"
 
 struct obd_device *obd_devs[MAX_OBD_DEVICES];
@@ -287,13 +288,6 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 		goto out;
 	}
 
-	case OBD_IOC_CLOSE_UUID: {
-		CDEBUG(D_IOCTL, "closing all connections to uuid %s (NOOP)\n",
-		       data->ioc_inlbuf1);
-		err = 0;
-		goto out;
-	}
-
 	case OBD_IOC_GETDEVICE: {
 		int     index = data->ioc_count;
 		char    *status, *str;
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 33342bf..27a72d8 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -65,6 +65,7 @@
 #include "../../include/obd_support.h"
 #include "../../include/obd_class.h"
 #include "../../include/lprocfs_status.h"
+#include "../../include/lustre/lustre_ioctl.h"
 #include "../../include/lustre_ver.h"
 
 /* buffer MUST be at least the size of obd_ioctl_hdr */
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 0eab123..6d0890f 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -37,6 +37,7 @@
 #define DEBUG_SUBSYSTEM S_CLASS
 #include "../include/obd_class.h"
 #include <linux/string.h>
+#include "../include/lustre/lustre_ioctl.h"
 #include "../include/lustre_log.h"
 #include "../include/lprocfs_status.h"
 #include "../include/lustre_param.h"
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 5b29c4a..2cb487b 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -41,6 +41,7 @@
 #include "../include/cl_object.h"
 #include "../include/lustre_fid.h"
 #include "../include/lustre_acl.h"
+#include "../include/lustre/lustre_ioctl.h"
 #include "../include/lustre_net.h"
 
 #include "echo_internal.h"
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index a2d948f..d231827 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -41,6 +41,7 @@
 
 #include "../include/lustre_ha.h"
 #include "../include/lprocfs_status.h"
+#include "../include/lustre/lustre_ioctl.h"
 #include "../include/lustre_debug.h"
 #include "../include/lustre_param.h"
 #include "../include/lustre_fid.h"
-- 
1.7.1
