From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:37 -0400
Subject: [lustre-devel] [PATCH 27/30] lustre: ptlrpc: increase sleep time in
 ptlrpc_request_bufs_pack()
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vitaly Fertman <c17818@cray.com>

schedule_timeout_uninterruptible() does not necessarily expire.
Increase the sleeping time in ptlrpc_request_bufs_pack() as 2
seconds is too short, given the 1 second sleep used in the test
suite.

Signed-off-by: Vitaly Fertman <c17818@cray.com>
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8062
Reviewed-on: https://review.whamcloud.com/26815
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index eddb920..6d503d7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -36,7 +36,9 @@
 #define DEBUG_SUBSYSTEM S_RPC
 
 #include <linux/libcfs/libcfs_cpu.h>
+#include <linux/delay.h>
 #include <linux/random.h>
+
 #include <obd_support.h>
 #include <obd_class.h>
 #include <lustre_lib.h>
@@ -763,7 +765,7 @@ int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 			/* The RPC is infected, let the test change the
 			 * fail_loc
 			 */
-			schedule_timeout_uninterruptible(2 * HZ);
+			msleep(4 * MSEC_PER_SEC);
 		}
 	}
 
-- 
1.8.3.1
