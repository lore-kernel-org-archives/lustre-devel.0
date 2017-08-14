From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:03 -0400
Subject: [lustre-devel] [PATCH 35/64] staging: lustre: lnet: delete lnet.h
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-36-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

The header lnet.h is just a bunch of headers included in
a header. Just delete it and include the appropriate
headers where needed.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: https://review.whamcloud.com/28089
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  4 +-
 drivers/staging/lustre/include/linux/lnet/lnet.h   | 44 ----------------------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  1 -
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  1 -
 drivers/staging/lustre/lnet/libcfs/module.c        |  1 -
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |  2 +-
 drivers/staging/lustre/lnet/selftest/conrpc.h      |  1 -
 drivers/staging/lustre/lnet/selftest/console.h     |  1 -
 drivers/staging/lustre/lnet/selftest/selftest.h    |  1 -
 9 files changed, 4 insertions(+), 52 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/lnet.h

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index f534115..9b923ec 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -37,9 +37,11 @@
 
 #include "../libcfs/libcfs.h"
 #include "api.h"
-#include "lnet.h"
 #include "lib-types.h"
 #include "lib-dlc.h"
+#include "types.h"
+#include "lnetctl.h"
+#include "nidstr.h"
 
 extern struct lnet the_lnet;	/* THE network */
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lnet.h b/drivers/staging/lustre/include/linux/lnet/lnet.h
deleted file mode 100644
index 5d1559a..0000000
--- a/drivers/staging/lustre/include/linux/lnet/lnet.h
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
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2012 - 2015, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Seagate, Inc.
- */
-
-#ifndef __LNET_H__
-#define __LNET_H__
-
-/*
- * lnet.h
- *
- * User application interface file
- */
-#include "types.h"
-#include "nidstr.h"
-
-#endif
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 16e437b..8e59506 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -64,7 +64,6 @@
 #define DEBUG_SUBSYSTEM S_LND
 
 #include "../../../include/linux/libcfs/libcfs.h"
-#include "../../../include/linux/lnet/lnet.h"
 #include "../../../include/linux/lnet/lib-lnet.h"
 
 #define IBLND_PEER_HASH_SIZE		101	/* # peer lists */
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 9eb169d..88afe09 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -47,7 +47,6 @@
 #include <net/tcp.h>
 
 #include "../../../include/linux/libcfs/libcfs.h"
-#include "../../../include/linux/lnet/lnet.h"
 #include "../../../include/linux/lnet/lib-lnet.h"
 #include "../../../include/linux/lnet/socklnd.h"
 
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index c388550..9ece869 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -56,7 +56,6 @@
 #include "../../include/linux/libcfs/libcfs_crypto.h"
 #include "../../include/linux/lnet/lib-lnet.h"
 #include "../../include/linux/lnet/lib-dlc.h"
-#include "../../include/linux/lnet/lnet.h"
 #include "tracefile.h"
 
 static struct dentry *lnet_debugfs_root;
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 298533d..cbbd11f 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -37,7 +37,7 @@
 #define DEBUG_SUBSYSTEM S_LNET
 
 #include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lnet.h"
+#include "../../include/linux/lnet/nidstr.h"
 
 /* max value for numeric network address */
 #define MAX_NUMERIC_VALUE 0xffffffff
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index 7141d2c..e2a78b6 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -40,7 +40,6 @@
 #define __LST_CONRPC_H__
 
 #include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lnet.h"
 #include "../../include/linux/lnet/lib-types.h"
 #include "../../include/linux/lnet/lnetst.h"
 #include "rpc.h"
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index e3e11aa..0a9ba06 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -40,7 +40,6 @@
 #define __LST_CONSOLE_H__
 
 #include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lnet.h"
 #include "../../include/linux/lnet/lib-types.h"
 #include "../../include/linux/lnet/lnetst.h"
 #include "selftest.h"
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index b614e6f..bfa4971 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -39,7 +39,6 @@
 #define LNET_ONLY
 
 #include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lnet.h"
 #include "../../include/linux/lnet/lib-lnet.h"
 #include "../../include/linux/lnet/lib-types.h"
 #include "../../include/linux/lnet/lnetst.h"
-- 
1.8.3.1
