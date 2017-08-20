From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:28 -0400
Subject: [lustre-devel] [PATCH 34/64 v2] staging: lustre: socklnd: create
	socklnd.h UAPI header
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-35-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Break out the parts from libcfs_debug.h that is used by both user
land and kernel space into a new UAPI header.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: https://review.whamcloud.com/28089
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/socklnd.h    | 10 +----
 .../lustre/include/uapi/linux/lnet/socklnd.h       | 44 ++++++++++++++++++++++
 2 files changed, 45 insertions(+), 9 deletions(-)
 create mode 100644 drivers/staging/lustre/include/uapi/linux/lnet/socklnd.h

diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index a1ae66e..27ce6ce 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -35,15 +35,7 @@
 #define __LNET_LNET_SOCKLND_H__
 
 #include "types.h"
-
-#define SOCKLND_CONN_NONE     (-1)
-#define SOCKLND_CONN_ANY	0
-#define SOCKLND_CONN_CONTROL	1
-#define SOCKLND_CONN_BULK_IN	2
-#define SOCKLND_CONN_BULK_OUT	3
-#define SOCKLND_CONN_NTYPES	4
-
-#define SOCKLND_CONN_ACK	SOCKLND_CONN_BULK_IN
+#include "../../uapi/linux/lnet/socklnd.h"
 
 struct ksock_hello_msg {
 	__u32		kshm_magic;	/* magic number of socklnd message */
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/socklnd.h b/drivers/staging/lustre/include/uapi/linux/lnet/socklnd.h
new file mode 100644
index 0000000..6453e05
--- /dev/null
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/socklnd.h
@@ -0,0 +1,44 @@
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
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ *
+ * #defines shared between socknal implementation and utilities
+ */
+#ifndef __UAPI_LNET_SOCKLND_H__
+#define __UAPI_LNET_SOCKLND_H__
+
+#define SOCKLND_CONN_NONE     (-1)
+#define SOCKLND_CONN_ANY	0
+#define SOCKLND_CONN_CONTROL	1
+#define SOCKLND_CONN_BULK_IN	2
+#define SOCKLND_CONN_BULK_OUT	3
+#define SOCKLND_CONN_NTYPES	4
+
+#define SOCKLND_CONN_ACK	SOCKLND_CONN_BULK_IN
+
+#endif
-- 
1.8.3.1
