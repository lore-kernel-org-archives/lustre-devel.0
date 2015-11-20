From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:36:12 -0500
Subject: [lustre-devel] [PATCH 36/40] staging: lustre: test for sk_sleep
	presence in compact-2.6.h
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-37-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Like Lustre external infiniband stacks create a compatibility
layer to handle various distributions and kernel versions.
Due to this besides the linux kernel sk_sleep can also be
defined by the external infiniband stack. We need to examine
the infiniband stack's headers to see if sk_sleep is available
there as well.

Signed-off-by: James Simmons <jsimmons@infradead.org>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6763
Reviewed-on: http://review.whamcloud.com/15386
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    1 -
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    1 +
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index dbfb069..695b5be 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -38,7 +38,6 @@
 #include <linux/kthread.h>
 #include <linux/uio.h>
 #include <linux/types.h>
-#include <net/sock.h>
 
 #include "types.h"
 
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 61806ce..05eb5b2 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -36,6 +36,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 #include <linux/completion.h>
+#include <net/sock.h>
 #include "../../include/linux/lnet/lib-lnet.h"
 
 static int   accept_port    = 988;
-- 
1.7.1
