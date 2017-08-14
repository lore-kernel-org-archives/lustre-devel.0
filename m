From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:29 -0400
Subject: [lustre-devel] [PATCH 61/64] staging: lustre: ksocklnd: add include
	path to Makefile
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-62-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in the ksocklnd source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/socklnd/Makefile  | 3 +++
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h | 6 +++---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/Makefile b/drivers/staging/lustre/lnet/klnds/socklnd/Makefile
index c011581..a7da1ab 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/Makefile
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/Makefile
@@ -1,3 +1,6 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
 obj-$(CONFIG_LNET) += ksocklnd.o
 
 ksocklnd-y := socklnd.o socklnd_cb.o socklnd_proto.o socklnd_modparams.o socklnd_lib.o
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 88afe09..e6428c4 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -46,9 +46,9 @@
 #include <net/sock.h>
 #include <net/tcp.h>
 
-#include "../../../include/linux/libcfs/libcfs.h"
-#include "../../../include/linux/lnet/lib-lnet.h"
-#include "../../../include/linux/lnet/socklnd.h"
+#include <linux/libcfs/libcfs.h>
+#include <linux/lnet/lib-lnet.h>
+#include <linux/lnet/socklnd.h>
 
 /* assume one thread for each connection type */
 #define SOCKNAL_NSCHEDS		3
-- 
1.8.3.1
