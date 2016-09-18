From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:01 -0400
Subject: [lustre-devel] [PATCH 002/124] staging: lustre: ptlrpc: enlarge
	OST_MAXREQSIZE for 4MB RPC
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Li Xi <lixi@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Li Xi <lixi@ddn.com>

This patch enlarges OST_MAXREQSIZE so as to make the
request size large enough for 4MB RPC.

Signed-off-by: Li Xi <lixi@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4755
Reviewed-on: http://review.whamcloud.com/9599
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 24ddcca..6d82998 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -261,7 +261,10 @@
 
 #define MDS_MAXREQSIZE		(5 * 1024)	/* >= 4736 */
 
-#define OST_MAXREQSIZE		(5 * 1024)
+/**
+ * FIEMAP request can be 4K+ for now
+ */
+#define OST_MAXREQSIZE		(16 * 1024)
 
 /* Macro to hide a typecast. */
 #define ptlrpc_req_async_args(req) ((void *)&req->rq_async_args)
-- 
1.7.1
