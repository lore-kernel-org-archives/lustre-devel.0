From: James Simmons <jsimmons@infradead.org>
Date: Fri, 23 Oct 2015 15:59:17 -0400
Subject: [lustre-devel] [PATCH 5/5] staging:lustre: Update license and
	copyright for kernel comm
In-Reply-To: <1445630357-27149-1-git-send-email-jsimmons@infradead.org>
References: <1445630357-27149-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1445630357-27149-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: frank zago <fzago@cray.com>

Point to the right place for GNU license. Update Intel copyright.
Update Nathan Rutmans email address. This was broken out of the
original patch 14270.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/14270
Reviewed-by: Nathan Rutman <nathan.rutman@seagate.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre_kernelcomm.h      |    2 +-
 .../lustre/lustre/include/uapi_kernelcomm.h        |    2 +-
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |   11 +++--------
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
index a5baa80..a61263f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
@@ -28,7 +28,7 @@
 /*
  * This file is part of Lustre, http://www.lustre.org/
  *
- * Author: Nathan Rutman <nathan.rutman@sun.com>
+ * Author: Nathan Rutman <nathan.rutman@seagate.com>
  *
  * Kernel <-> userspace communication routines.
  * The definitions below are used in the kernel and userspace.
diff --git a/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h b/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
index 5e0b8de..ad608b7 100644
--- a/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
+++ b/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
@@ -28,7 +28,7 @@
 /*
  * This file is part of Lustre, http://www.lustre.org/
  *
- * Author: Nathan Rutman <nathan.rutman@sun.com>
+ * Author: Nathan Rutman <nathan.rutman@seagate.com>
  *
  * Kernel <-> userspace communication routines.
  * The definitions below are used in the kernel and userspace.
diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index 70bd729..978191a 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
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
@@ -27,13 +23,12 @@
  * Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
- * Author: Nathan Rutman <nathan.rutman@sun.com>
+ * Author: Nathan Rutman <nathan.rutman@seagate.com>
  *
  * Kernel <-> userspace communication routines.
  * Using pipes for all arches.
-- 
1.7.1
