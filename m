From: James Simmons <jsimmons@infradead.org>
Date: Wed,  3 Jun 2015 16:43:27 -0400
Subject: [lustre-devel] [PATCH v3 8/8] staging:lustre: Update license and
	copyright for the LNET headers
In-Reply-To: <1433364207-14307-1-git-send-email-jsimmons@infradead.org>
References: <1433364207-14307-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1433364207-14307-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Point to the right place for GNU license. Update Intel copyright.

Signed-off-by: James Simmons <jsimmons at infradead.org
---
 drivers/staging/lustre/include/linux/lnet/api.h    |   13 +++++--------
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   10 +++-------
 .../staging/lustre/include/linux/lnet/lib-types.h  |   13 +++----------
 drivers/staging/lustre/include/linux/lnet/lnet.h   |   10 ++++------
 drivers/staging/lustre/include/linux/lnet/lnetst.h |   12 ++++--------
 drivers/staging/lustre/include/linux/lnet/nidstr.h |    3 ++-
 .../staging/lustre/include/linux/lnet/socklnd.h    |   12 ++++--------
 drivers/staging/lustre/include/linux/lnet/types.h  |   10 +++-------
 8 files changed, 28 insertions(+), 55 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index 2eb0a05..9493d5e 100644
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
+ * Copyright (c) 2011 - 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
+ * Lustre is a trademark of Seagate, Inc.
  */
 
 #ifndef __LNET_API_H__
@@ -41,9 +39,8 @@
  *
  * LNet is an asynchronous message-passing API, which provides an unreliable
  * connectionless service that can't guarantee any order. It supports OFA IB,
- * TCP/IP, and Cray Portals, and routes between heterogeneous networks.
+ * TCP/IP, and Cray Interconnects, and routes between heterogeneous networks.
  *
- * LNet can run both in OS kernel space and in userspace as a library.
  * @{
  */
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 982b3ad..b82bbcf 100644
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
@@ -27,11 +23,11 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012 - 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
+ * Lustre is a trademark of Seagate, Inc.
  *
  * lnet/include/lnet/lib-lnet.h
  */
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index adf3286..532820a 100644
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
@@ -27,16 +23,13 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012 - 2015, Intel Corporation.
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
diff --git a/drivers/staging/lustre/include/linux/lnet/lnet.h b/drivers/staging/lustre/include/linux/lnet/lnet.h
index 8124d8f..5d1559a 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnet.h
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
+ * Copyright (c) 2012 - 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
+ * Lustre is a trademark of Seagate, Inc.
  */
 
 #ifndef __LNET_H__
diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index e7ae40b..0ec9343 100644
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
@@ -27,15 +23,15 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, Intel Corporation.
+ * Copyright (c) 2011 - 2015, Intel Corporation.
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
diff --git a/drivers/staging/lustre/include/linux/lnet/nidstr.h b/drivers/staging/lustre/include/linux/lnet/nidstr.h
index 8eaed1a..a627be9 100644
--- a/drivers/staging/lustre/include/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/linux/lnet/nidstr.h
@@ -23,10 +23,11 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2014, Intel Corporation.
+ * Copyright (c) 2011 - 2015, Intel Corporation.
  */
 #ifndef _LNET_NIDSTRINGS_H
 #define _LNET_NIDSTRINGS_H
+
 #include "types.h"
 
 /**
diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index 4c790bd..599c9f6 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -15,25 +15,21 @@
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
+ * Copyright (c) 2012 - 2015, Intel Corporation.
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
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 00a42f8..259aedd 100644
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
+ * Copyright (c) 2012 - 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
+ * Lustre is a trademark of Seagate, Inc.
  */
 
 #ifndef __LNET_TYPES_H__
-- 
1.7.1
