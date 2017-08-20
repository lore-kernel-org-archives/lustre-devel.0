From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:54 -0400
Subject: [lustre-devel] [PATCH 60/64 v2] staging: lustre: ko2iblnd: add
	include path to Makefile
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-61-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in the ko2iblnd source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile  | 3 +++
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h | 4 ++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile b/drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile
index e0a7aa7..4affe1d 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile
@@ -1,2 +1,5 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
 obj-$(CONFIG_LNET_XPRT_IB) += ko2iblnd.o
 ko2iblnd-y := o2iblnd.o o2iblnd_cb.o o2iblnd_modparams.o
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 8e59506..a1e994a 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -63,8 +63,8 @@
 
 #define DEBUG_SUBSYSTEM S_LND
 
-#include "../../../include/linux/libcfs/libcfs.h"
-#include "../../../include/linux/lnet/lib-lnet.h"
+#include <linux/libcfs/libcfs.h>
+#include <linux/lnet/lib-lnet.h>
 
 #define IBLND_PEER_HASH_SIZE		101	/* # peer lists */
 /* # scheduler loops before reschedule */
-- 
1.8.3.1
