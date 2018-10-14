From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:58:14 -0400
Subject: [lustre-devel] [PATCH 24/28] lustre: llite: IO accounting of page
 read
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Hongchao Zhang <hongchao@whamcloud.com>

When CONFIG_TASK_IO_ACCOUNTING is used with Lustre, writes are
accounted for but not read.

The accounting is normally done in the kernel for page writeback
and readahead functionlity, Therefore, as Lustre implements its
own readahead, it must also maintain its own accounting on read
(but not for write)

Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-618
Reviewed-on: https://review.whamcloud.com/1636
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/rw.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 9cc0d4fe..55d8b31 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -48,6 +48,7 @@
 #include <linux/pagemap.h>
 /* current_is_kswapd() */
 #include <linux/swap.h>
+#include <linux/task_io_accounting_ops.h>
 #include <linux/bvec.h>
 
 #define DEBUG_SUBSYSTEM S_LLITE
@@ -1137,9 +1138,13 @@ static int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 		       PFID(ll_inode2fid(inode)), rc2, vvp_index(vpg));
 	}
 
-	if (queue->c2_qin.pl_nr > 0)
-		rc = cl_io_submit_rw(env, io, CRT_READ, queue);
+	if (queue->c2_qin.pl_nr > 0) {
+		int count = queue->c2_qin.pl_nr;
 
+		rc = cl_io_submit_rw(env, io, CRT_READ, queue);
+		if (!rc)
+			task_io_account_read(PAGE_SIZE * count);
+	}
 	/*
 	 * Unlock unsent pages in case of error.
 	 */
-- 
1.8.3.1
