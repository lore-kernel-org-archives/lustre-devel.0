From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:50 -0400
Subject: [lustre-devel] [PATCH 091/151] lustre: llite: avoid live-lock when
 concurrent mmap()s
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-92-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

Patch is an attempt to delay page-fault retry from Client side for
inode with extents being mmap()'ed, to prevent live-lock situation
to occur with other page's competitors.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10149
Lustre-commit: cd793b4067b6 ("LU-10149 llite: avoid live-lock when concurrent mmap()s")
Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Reviewed-on: https://review.whamcloud.com/30465
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_mmap.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index 59fb400..14080b6 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -38,6 +38,7 @@
 #include <linux/errno.h>
 #include <linux/unistd.h>
 #include <linux/uaccess.h>
+#include <linux/delay.h>
 
 #include <linux/fs.h>
 #include <linux/pagemap.h>
@@ -153,7 +154,7 @@ static int __ll_page_mkwrite(struct vm_area_struct *vma, struct page *vmpage,
 	int result;
 	u16 refcheck;
 	sigset_t old, new;
-	struct inode *inode;
+	struct inode *inode = NULL;
 	struct ll_inode_info *lli;
 
 	env = cl_env_get(&refcheck);
@@ -229,6 +230,17 @@ static int __ll_page_mkwrite(struct vm_area_struct *vma, struct page *vmpage,
 	CDEBUG(D_MMAP, "%s mkwrite with %d\n", current->comm, result);
 	LASSERT(ergo(result == 0, PageLocked(vmpage)));
 
+	/* if page has been unmapped, presumably due to lock reclaim for
+	 * concurrent usage, add some delay before retrying to prevent
+	 * entering live-lock situation with competitors
+	 */
+	if (result == -ENODATA && inode) {
+		CDEBUG(D_MMAP,
+		       "delaying new page-fault for inode %p to prevent live-lock\n",
+		       inode);
+		msleep(20);
+	}
+
 	return result;
 }
 
-- 
1.8.3.1
