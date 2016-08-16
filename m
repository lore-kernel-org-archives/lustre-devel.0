From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:58 -0400
Subject: [lustre-devel] [PATCH 45/80] staging: lustre: llite: Fix the
	deadlock in balance_dirty_pages()
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-46-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

If the page is already dirtied in ll_write_end() and kernel tries
to call balance_dirty_pages() to write back dirty pages in the same
thread, this is deadlock case if the page is already held by clio.

This can also fix the issue of LU-4873.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4977
Reviewed-on: http://review.whamcloud.com/10149
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/rw26.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index c14a1b6..8c8c100 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -506,9 +506,8 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 	env = lcc->lcc_env;
 	io  = lcc->lcc_io;
 
-	if (likely(to == PAGE_SIZE)) /* LU-4873 */
-		/* To avoid deadlock, try to lock page first. */
-		vmpage = grab_cache_page_nowait(mapping, index);
+	/* To avoid deadlock, try to lock page first. */
+	vmpage = grab_cache_page_nowait(mapping, index);
 	if (unlikely(!vmpage || PageDirty(vmpage) || PageWriteback(vmpage))) {
 		struct vvp_io *vio = vvp_env_io(env);
 		struct cl_page_list *plist = &vio->u.write.vui_queue;
@@ -617,6 +616,13 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 			LASSERT(from == 0);
 		vio->u.write.vui_to = from + copied;
 
+		/*
+		 * To address the deadlock in balance_dirty_pages() where
+		 * this dirty page may be written back in the same thread.
+		 */
+		if (PageDirty(vmpage))
+			unplug = true;
+
 		/* We may have one full RPC, commit it soon */
 		if (plist->pl_nr >= PTLRPC_MAX_BRW_PAGES)
 			unplug = true;
-- 
1.7.1
