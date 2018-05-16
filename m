From: Christoph Hellwig <hch@lst.de>
Date: Wed, 16 May 2018 07:43:40 +0200
Subject: [lustre-devel] [PATCH 06/14] btrfs: separate errno from VM_FAULT_*
 values
In-Reply-To: <20180516054348.15950-1-hch@lst.de>
References: <20180516054348.15950-1-hch@lst.de>
Message-ID: <20180516054348.15950-7-hch@lst.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, ocfs2-devel@oss.oracle.com, devel@lists.orangefs.org, linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, lustre-devel@lists.lustre.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/btrfs/ctree.h |  2 +-
 fs/btrfs/inode.c | 19 ++++++++++---------
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index 1485cd130e2b..02a0de73c1d1 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -3203,7 +3203,7 @@ int btrfs_merge_bio_hook(struct page *page, unsigned long offset,
 			 size_t size, struct bio *bio,
 			 unsigned long bio_flags);
 void btrfs_set_range_writeback(void *private_data, u64 start, u64 end);
-int btrfs_page_mkwrite(struct vm_fault *vmf);
+vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf);
 int btrfs_readpage(struct file *file, struct page *page);
 void btrfs_evict_inode(struct inode *inode);
 int btrfs_write_inode(struct inode *inode, struct writeback_control *wbc);
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index ec9db248c499..f4f03f0f4556 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -8824,7 +8824,7 @@ static void btrfs_invalidatepage(struct page *page, unsigned int offset,
  * beyond EOF, then the page is guaranteed safe against truncation until we
  * unlock the page.
  */
-int btrfs_page_mkwrite(struct vm_fault *vmf)
+vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
 	struct inode *inode = file_inode(vmf->vma->vm_file);
@@ -8836,7 +8836,8 @@ int btrfs_page_mkwrite(struct vm_fault *vmf)
 	char *kaddr;
 	unsigned long zero_start;
 	loff_t size;
-	int ret;
+	vm_fault_t ret;
+	int err;
 	int reserved = 0;
 	u64 reserved_space;
 	u64 page_start;
@@ -8858,14 +8859,14 @@ int btrfs_page_mkwrite(struct vm_fault *vmf)
 	 * end up waiting indefinitely to get a lock on the page currently
 	 * being processed by btrfs_page_mkwrite() function.
 	 */
-	ret = btrfs_delalloc_reserve_space(inode, &data_reserved, page_start,
+	err = btrfs_delalloc_reserve_space(inode, &data_reserved, page_start,
 					   reserved_space);
-	if (!ret) {
-		ret = file_update_time(vmf->vma->vm_file);
+	if (!err) {
+		err = file_update_time(vmf->vma->vm_file);
 		reserved = 1;
 	}
-	if (ret) {
-		if (ret == -ENOMEM)
+	if (err) {
+		if (err == -ENOMEM)
 			ret = VM_FAULT_OOM;
 		else /* -ENOSPC, -EIO, etc */
 			ret = VM_FAULT_SIGBUS;
@@ -8927,9 +8928,9 @@ int btrfs_page_mkwrite(struct vm_fault *vmf)
 			  EXTENT_DO_ACCOUNTING | EXTENT_DEFRAG,
 			  0, 0, &cached_state);
 
-	ret = btrfs_set_extent_delalloc(inode, page_start, end, 0,
+	err = btrfs_set_extent_delalloc(inode, page_start, end, 0,
 					&cached_state, 0);
-	if (ret) {
+	if (err) {
 		unlock_extent_cached(io_tree, page_start, page_end,
 				     &cached_state);
 		ret = VM_FAULT_SIGBUS;
-- 
2.17.0
