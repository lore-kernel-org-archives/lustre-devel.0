From: James Simmons <jsimmons@infradead.org>
Date: Thu, 25 Jun 2015 16:59:46 -0400
Subject: [lustre-devel] [PATCH] staging:lustre: remove irq.h from socklnd.h
Message-ID: <1435265986-10375-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The header socklnd.h includes irq.h which is not need
and doesn't exist in the OpenSFS lustre branch. Having
irq.h in socklnd.h does break the build on the m68k
platform. So we can safely remove it.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 7125eb9..8a9d4a0 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -31,7 +31,6 @@
 #define DEBUG_PORTAL_ALLOC
 #define DEBUG_SUBSYSTEM S_LND
 
-#include <asm/irq.h>
 #include <linux/crc32.h>
 #include <linux/errno.h>
 #include <linux/if.h>
-- 
1.7.1
