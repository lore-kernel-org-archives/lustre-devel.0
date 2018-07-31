From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:21 -0400
Subject: [lustre-devel] [PATCH 29/31] lustre: llite: ignore layout for
 ll_writepages()
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

ll_writepages() would be called inside the direct IO context and
if the layout has been changed during this time, the layout_conf()
has to wait for active IO to complete before applying the layout
change, this is a case of deadlock.

It should ignore layout to avoid this problem. This is safe as long
as pages exist, the layout won't be changed on this client.

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
WC-id: https://jira.whamcloud.com/browse/LU-9129
Reviewed-on: https://review.whamcloud.com/25474
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/rw.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 59747da..49ac723 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -1000,13 +1000,11 @@ int ll_writepage(struct page *vmpage, struct writeback_control *wbc)
 int ll_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
 	struct inode *inode = mapping->host;
-	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	loff_t start;
 	loff_t end;
 	enum cl_fsync_mode mode;
 	int range_whole = 0;
 	int result;
-	int ignore_layout = 0;
 
 	if (wbc->range_cyclic) {
 		start = mapping->writeback_index << PAGE_SHIFT;
@@ -1024,17 +1022,14 @@ int ll_writepages(struct address_space *mapping, struct writeback_control *wbc)
 	if (wbc->sync_mode == WB_SYNC_ALL)
 		mode = CL_FSYNC_LOCAL;
 
-	if (sbi->ll_umounting)
-		/* if the mountpoint is being umounted, all pages have to be
-		 * evicted to avoid hitting LBUG when truncate_inode_pages()
-		 * is called later on.
-		 */
-		ignore_layout = 1;
-
 	if (!ll_i2info(inode)->lli_clob)
 		return 0;
 
-	result = cl_sync_file_range(inode, start, end, mode, ignore_layout);
+	/* for directio, it would call writepages() to evict cached pages
+	 * inside the IO context of write, which will cause deadlock at
+	 * layout_conf since it waits for active IOs to complete.
+	 */
+	result = cl_sync_file_range(inode, start, end, mode, 1);
 	if (result > 0) {
 		wbc->nr_to_write -= result;
 		result = 0;
-- 
1.8.3.1
