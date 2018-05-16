From: Christoph Hellwig <hch@lst.de>
Date: Wed, 16 May 2018 07:43:42 +0200
Subject: [lustre-devel] [PATCH 08/14] ocfs2: separate errno from VM_FAULT_*
 values
In-Reply-To: <20180516054348.15950-1-hch@lst.de>
References: <20180516054348.15950-1-hch@lst.de>
Message-ID: <20180516054348.15950-9-hch@lst.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/ocfs2/mmap.c | 36 +++++++++++++++++++-----------------
 1 file changed, 19 insertions(+), 17 deletions(-)

diff --git a/fs/ocfs2/mmap.c b/fs/ocfs2/mmap.c
index fb9a20e3d608..e75c1fc5333e 100644
--- a/fs/ocfs2/mmap.c
+++ b/fs/ocfs2/mmap.c
@@ -44,11 +44,11 @@
 #include "ocfs2_trace.h"
 
 
-static int ocfs2_fault(struct vm_fault *vmf)
+static vm_fault_t ocfs2_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	sigset_t oldset;
-	int ret;
+	vm_fault_t ret;
 
 	ocfs2_block_signals(&oldset);
 	ret = filemap_fault(vmf);
@@ -59,10 +59,10 @@ static int ocfs2_fault(struct vm_fault *vmf)
 	return ret;
 }
 
-static int __ocfs2_page_mkwrite(struct file *file, struct buffer_head *di_bh,
-				struct page *page)
+static vm_fault_t __ocfs2_page_mkwrite(struct file *file,
+		struct buffer_head *di_bh, struct page *page)
 {
-	int ret = VM_FAULT_NOPAGE;
+	vm_fault_t ret = VM_FAULT_NOPAGE;
 	struct inode *inode = file_inode(file);
 	struct address_space *mapping = inode->i_mapping;
 	loff_t pos = page_offset(page);
@@ -71,6 +71,7 @@ static int __ocfs2_page_mkwrite(struct file *file, struct buffer_head *di_bh,
 	struct page *locked_page = NULL;
 	void *fsdata;
 	loff_t size = i_size_read(inode);
+	int err;
 
 	last_index = (size - 1) >> PAGE_SHIFT;
 
@@ -105,12 +106,12 @@ static int __ocfs2_page_mkwrite(struct file *file, struct buffer_head *di_bh,
 	if (page->index == last_index)
 		len = ((size - 1) & ~PAGE_MASK) + 1;
 
-	ret = ocfs2_write_begin_nolock(mapping, pos, len, OCFS2_WRITE_MMAP,
+	err = ocfs2_write_begin_nolock(mapping, pos, len, OCFS2_WRITE_MMAP,
 				       &locked_page, &fsdata, di_bh, page);
-	if (ret) {
-		if (ret != -ENOSPC)
-			mlog_errno(ret);
-		if (ret == -ENOMEM)
+	if (err) {
+		if (err != -ENOSPC)
+			mlog_errno(err);
+		if (err == -ENOMEM)
 			ret = VM_FAULT_OOM;
 		else
 			ret = VM_FAULT_SIGBUS;
@@ -121,20 +122,21 @@ static int __ocfs2_page_mkwrite(struct file *file, struct buffer_head *di_bh,
 		ret = VM_FAULT_NOPAGE;
 		goto out;
 	}
-	ret = ocfs2_write_end_nolock(mapping, pos, len, len, fsdata);
-	BUG_ON(ret != len);
+	err = ocfs2_write_end_nolock(mapping, pos, len, len, fsdata);
+	BUG_ON(err != len);
 	ret = VM_FAULT_LOCKED;
 out:
 	return ret;
 }
 
-static int ocfs2_page_mkwrite(struct vm_fault *vmf)
+static vm_fault_t ocfs2_page_mkwrite(struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
 	struct inode *inode = file_inode(vmf->vma->vm_file);
 	struct buffer_head *di_bh = NULL;
 	sigset_t oldset;
-	int ret;
+	vm_fault_t ret = 0;
+	int err;
 
 	sb_start_pagefault(inode->i_sb);
 	ocfs2_block_signals(&oldset);
@@ -144,10 +146,10 @@ static int ocfs2_page_mkwrite(struct vm_fault *vmf)
 	 * node. Taking the data lock will also ensure that we don't
 	 * attempt page truncation as part of a downconvert.
 	 */
-	ret = ocfs2_inode_lock(inode, &di_bh, 1);
-	if (ret < 0) {
+	err = ocfs2_inode_lock(inode, &di_bh, 1);
+	if (err < 0) {
 		mlog_errno(ret);
-		if (ret == -ENOMEM)
+		if (err == -ENOMEM)
 			ret = VM_FAULT_OOM;
 		else
 			ret = VM_FAULT_SIGBUS;
-- 
2.17.0
