From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:48 -0400
Subject: [lustre-devel] [PATCH 54/64 v2] staging: lustre: obdecho: add
	include path to Makefile
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-55-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in the obdecho source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdecho/Makefile     |  3 +++
 .../staging/lustre/lustre/obdecho/echo_client.c    | 24 +++++++++++-----------
 2 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdecho/Makefile b/drivers/staging/lustre/lustre/obdecho/Makefile
index a659a37..6be66fb 100644
--- a/drivers/staging/lustre/lustre/obdecho/Makefile
+++ b/drivers/staging/lustre/lustre/obdecho/Makefile
@@ -1,2 +1,5 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
 obj-$(CONFIG_LUSTRE_FS) += obdecho.o
 obdecho-y := echo_client.o
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 3f28db3..f9808d1 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -31,18 +31,18 @@
  */
 
 #define DEBUG_SUBSYSTEM S_ECHO
-#include "../../include/linux/libcfs/libcfs.h"
-
-#include "../include/obd.h"
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_debug.h"
-#include "../include/lprocfs_status.h"
-#include "../include/cl_object.h"
-#include "../include/lustre_fid.h"
-#include "../include/lustre_acl.h"
-#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
-#include "../include/lustre_net.h"
+#include <linux/libcfs/libcfs.h>
+
+#include <obd.h>
+#include <obd_support.h>
+#include <obd_class.h>
+#include <lustre_debug.h>
+#include <lprocfs_status.h>
+#include <cl_object.h>
+#include <lustre_fid.h>
+#include <lustre_acl.h>
+#include <uapi/linux/lustre/lustre_ioctl.h>
+#include <lustre_net.h>
 
 #include "echo_internal.h"
 
-- 
1.8.3.1
