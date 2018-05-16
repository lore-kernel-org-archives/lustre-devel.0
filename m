From: Christoph Hellwig <hch@lst.de>
Date: Wed, 16 May 2018 07:43:43 +0200
Subject: [lustre-devel] [PATCH 09/14] ubifs: separate errno from VM_FAULT_*
 values
In-Reply-To: <20180516054348.15950-1-hch@lst.de>
References: <20180516054348.15950-1-hch@lst.de>
Message-ID: <20180516054348.15950-10-hch@lst.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, ocfs2-devel@oss.oracle.com, devel@lists.orangefs.org, linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, lustre-devel@lists.lustre.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/ubifs/file.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 1acb2ff505e6..7c1a2e1c3de5 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1513,7 +1513,7 @@ static int ubifs_releasepage(struct page *page, gfp_t unused_gfp_flags)
  * mmap()d file has taken write protection fault and is being made writable.
  * UBIFS must ensure page is budgeted for.
  */
-static int ubifs_vm_page_mkwrite(struct vm_fault *vmf)
+static vm_fault_t ubifs_vm_page_mkwrite(struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
 	struct inode *inode = file_inode(vmf->vma->vm_file);
@@ -1521,6 +1521,7 @@ static int ubifs_vm_page_mkwrite(struct vm_fault *vmf)
 	struct timespec now = current_time(inode);
 	struct ubifs_budget_req req = { .new_page = 1 };
 	int err, update_time;
+	vm_fault_t ret = 0;
 
 	dbg_gen("ino %lu, pg %lu, i_size %lld",	inode->i_ino, page->index,
 		i_size_read(inode));
@@ -1601,8 +1602,8 @@ static int ubifs_vm_page_mkwrite(struct vm_fault *vmf)
 	unlock_page(page);
 	ubifs_release_budget(c, &req);
 	if (err)
-		err = VM_FAULT_SIGBUS;
-	return err;
+		ret = VM_FAULT_SIGBUS;
+	return ret;
 }
 
 static const struct vm_operations_struct ubifs_file_vm_ops = {
-- 
2.17.0
