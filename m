From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Feb 2016 17:29:22 -0500
Subject: [lustre-devel] [PATCH 21/24] staging: lustre: use sock.h in only
	acceptor.c
In-Reply-To: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
References: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456180165-1105-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

On some platforms having sock.h in lib-types.h would collide with
other included header files being used in the LNet layer. Looking
at what was needed from sock.h only acceptor.c is dependent on it.
To avoid these issues we just use sock.h only in acceptor.c.

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
index f588e06..c10f03b 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -38,7 +38,6 @@
 #include <linux/kthread.h>
 #include <linux/uio.h>
 #include <linux/types.h>
-#include <net/sock.h>
 
 #include "types.h"
 
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 3468433..1452bb3 100644
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
