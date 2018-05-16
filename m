From: Christoph Hellwig <hch@lst.de>
Date: Wed, 16 May 2018 07:43:41 +0200
Subject: [lustre-devel] [PATCH 07/14] ext4: separate errno from VM_FAULT_*
 values
In-Reply-To: <20180516054348.15950-1-hch@lst.de>
References: <20180516054348.15950-1-hch@lst.de>
Message-ID: <20180516054348.15950-8-hch@lst.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/ext4/ext4.h  |  4 ++--
 fs/ext4/inode.c | 30 +++++++++++++++---------------
 2 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index fa52b7dd4542..48592d0edf3e 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2463,8 +2463,8 @@ extern int ext4_writepage_trans_blocks(struct inode *);
 extern int ext4_chunk_trans_blocks(struct inode *, int nrblocks);
 extern int ext4_zero_partial_blocks(handle_t *handle, struct inode *inode,
 			     loff_t lstart, loff_t lend);
-extern int ext4_page_mkwrite(struct vm_fault *vmf);
-extern int ext4_filemap_fault(struct vm_fault *vmf);
+extern vm_fault_t ext4_page_mkwrite(struct vm_fault *vmf);
+extern vm_fault_t ext4_filemap_fault(struct vm_fault *vmf);
 extern qsize_t *ext4_get_reserved_space(struct inode *inode);
 extern int ext4_get_projid(struct inode *inode, kprojid_t *projid);
 extern void ext4_da_update_reserve_space(struct inode *inode,
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 95bc48f5c88b..fe49045a2832 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -6106,27 +6106,27 @@ static int ext4_bh_unmapped(handle_t *handle, struct buffer_head *bh)
 	return !buffer_mapped(bh);
 }
 
-int ext4_page_mkwrite(struct vm_fault *vmf)
+vm_fault_t ext4_page_mkwrite(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = vmf->page;
 	loff_t size;
 	unsigned long len;
-	int ret;
+	vm_fault_t ret;
 	struct file *file = vma->vm_file;
 	struct inode *inode = file_inode(file);
 	struct address_space *mapping = inode->i_mapping;
 	handle_t *handle;
 	get_block_t *get_block;
-	int retries = 0;
+	int retries = 0, err;
 
 	sb_start_pagefault(inode->i_sb);
 	file_update_time(vma->vm_file);
 
 	down_read(&EXT4_I(inode)->i_mmap_sem);
 
-	ret = ext4_convert_inline_data(inode);
-	if (ret)
+	err = ext4_convert_inline_data(inode);
+	if (err)
 		goto out_ret;
 
 	/* Delalloc case is easy... */
@@ -6134,9 +6134,9 @@ int ext4_page_mkwrite(struct vm_fault *vmf)
 	    !ext4_should_journal_data(inode) &&
 	    !ext4_nonda_switch(inode->i_sb)) {
 		do {
-			ret = block_page_mkwrite(vma, vmf,
+			err = block_page_mkwrite(vma, vmf,
 						   ext4_da_get_block_prep);
-		} while (ret == -ENOSPC &&
+		} while (err == -ENOSPC &&
 		       ext4_should_retry_alloc(inode->i_sb, &retries));
 		goto out_ret;
 	}
@@ -6181,8 +6181,8 @@ int ext4_page_mkwrite(struct vm_fault *vmf)
 		ret = VM_FAULT_SIGBUS;
 		goto out;
 	}
-	ret = block_page_mkwrite(vma, vmf, get_block);
-	if (!ret && ext4_should_journal_data(inode)) {
+	err = block_page_mkwrite(vma, vmf, get_block);
+	if (!err && ext4_should_journal_data(inode)) {
 		if (ext4_walk_page_buffers(handle, page_buffers(page), 0,
 			  PAGE_SIZE, NULL, do_journal_get_write_access)) {
 			unlock_page(page);
@@ -6193,24 +6193,24 @@ int ext4_page_mkwrite(struct vm_fault *vmf)
 		ext4_set_inode_state(inode, EXT4_STATE_JDATA);
 	}
 	ext4_journal_stop(handle);
-	if (ret == -ENOSPC && ext4_should_retry_alloc(inode->i_sb, &retries))
+	if (err == -ENOSPC && ext4_should_retry_alloc(inode->i_sb, &retries))
 		goto retry_alloc;
 out_ret:
-	ret = block_page_mkwrite_return(ret);
+	ret = block_page_mkwrite_return(err);
 out:
 	up_read(&EXT4_I(inode)->i_mmap_sem);
 	sb_end_pagefault(inode->i_sb);
 	return ret;
 }
 
-int ext4_filemap_fault(struct vm_fault *vmf)
+vm_fault_t ext4_filemap_fault(struct vm_fault *vmf)
 {
 	struct inode *inode = file_inode(vmf->vma->vm_file);
-	int err;
+	vm_fault_t ret;
 
 	down_read(&EXT4_I(inode)->i_mmap_sem);
-	err = filemap_fault(vmf);
+	ret = filemap_fault(vmf);
 	up_read(&EXT4_I(inode)->i_mmap_sem);
 
-	return err;
+	return ret;
 }
-- 
2.17.0
