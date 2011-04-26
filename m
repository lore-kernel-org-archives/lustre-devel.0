From: Mark Hills <Mark.Hills@framestore.com>
Date: Tue, 26 Apr 2011 17:06:05 +0100 (BST)
Subject: [Lustre-devel] [PATCH] Fix task IO accounting on reads
Message-ID: <alpine.LFD.2.01.1104261356450.21670@sys880.ldn.framestore.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We've often found it inconvenient that reads from Lustre mounts do not 
correctly increment IO counts (/proc/<pid>/io).

Below is a patch which aims to fix this functionality.

The symptom is that writes are accounted for, but not reads. It seems that 
the accounting it normally done in the kernels page writeback and 
readahead functionality. Therefore as Lustre implements its own readahead, 
it must also maintain its own accounting on reads (but not writes).

Is anyone able to confirm this rationale for the location of this 
particular call, and consider the following patch? Thanks.

-- 
Mark

---
 lustre/llite/rw.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lustre/llite/rw.c b/lustre/llite/rw.c
index ccd6a42..c7a84b7 100644
--- a/lustre/llite/rw.c
+++ b/lustre/llite/rw.c
@@ -58,6 +58,7 @@
 #include <linux/mm.h>
 #include <linux/pagemap.h>
 #include <linux/smp_lock.h>
+#include <linux/task_io_accounting_ops.h>
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
@@ -1311,6 +1312,8 @@ static int ll_issue_page_read(struct obd_export *exp,
         if (rc) {
                 LL_CDEBUG_PAGE(D_ERROR, page, "read queue failed: rc %d\n", rc);
                 page_cache_release(page);
+        } else {
+                task_io_account_read(CFS_PAGE_SIZE);
         }
         RETURN(rc);
 }
-- 
1.7.1.1
