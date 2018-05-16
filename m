From: Christoph Hellwig <hch@lst.de>
Date: Wed, 16 May 2018 07:43:39 +0200
Subject: [lustre-devel] [PATCH 05/14] ceph: untangle ceph_filemap_fault
In-Reply-To: <20180516054348.15950-1-hch@lst.de>
References: <20180516054348.15950-1-hch@lst.de>
Message-ID: <20180516054348.15950-6-hch@lst.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

Streamline the code to have a somewhat natural flow, and separate the
errno values from the VM_FAULT_* values.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/ceph/addr.c | 100 +++++++++++++++++++++++++------------------------
 1 file changed, 51 insertions(+), 49 deletions(-)

diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 5f7ad3d0df2e..6e80894ca073 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -1428,15 +1428,18 @@ static void ceph_restore_sigs(sigset_t *oldset)
 /*
  * vm ops
  */
-static int ceph_filemap_fault(struct vm_fault *vmf)
+static vm_fault_t ceph_filemap_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct inode *inode = file_inode(vma->vm_file);
+	struct address_space *mapping = inode->i_mapping;
 	struct ceph_inode_info *ci = ceph_inode(inode);
 	struct ceph_file_info *fi = vma->vm_file->private_data;
-	struct page *pinned_page = NULL;
+	struct page *pinned_page = NULL, *page;
 	loff_t off = vmf->pgoff << PAGE_SHIFT;
-	int want, got, ret;
+	int want, got, err = 0;
+	vm_fault_t ret = 0;
+	bool did_fault = false;
 	sigset_t oldset;
 
 	ceph_block_sigs(&oldset);
@@ -1449,9 +1452,9 @@ static int ceph_filemap_fault(struct vm_fault *vmf)
 		want = CEPH_CAP_FILE_CACHE;
 
 	got = 0;
-	ret = ceph_get_caps(ci, CEPH_CAP_FILE_RD, want, -1, &got, &pinned_page);
-	if (ret < 0)
-		goto out_restore;
+	err = ceph_get_caps(ci, CEPH_CAP_FILE_RD, want, -1, &got, &pinned_page);
+	if (err < 0)
+		goto out_errno;
 
 	dout("filemap_fault %p %llu~%zd got cap refs on %s\n",
 	     inode, off, (size_t)PAGE_SIZE, ceph_cap_string(got));
@@ -1462,8 +1465,8 @@ static int ceph_filemap_fault(struct vm_fault *vmf)
 		ceph_add_rw_context(fi, &rw_ctx);
 		ret = filemap_fault(vmf);
 		ceph_del_rw_context(fi, &rw_ctx);
-	} else
-		ret = -EAGAIN;
+		did_fault = true;
+	}
 
 	dout("filemap_fault %p %llu~%zd dropping cap refs on %s ret %d\n",
 	     inode, off, (size_t)PAGE_SIZE, ceph_cap_string(got), ret);
@@ -1471,57 +1474,55 @@ static int ceph_filemap_fault(struct vm_fault *vmf)
 		put_page(pinned_page);
 	ceph_put_cap_refs(ci, got);
 
-	if (ret != -EAGAIN)
+	if (did_fault)
 		goto out_restore;
 
 	/* read inline data */
 	if (off >= PAGE_SIZE) {
 		/* does not support inline data > PAGE_SIZE */
 		ret = VM_FAULT_SIGBUS;
+		goto out_restore;
+	}
+
+	page = find_or_create_page(mapping, 0,
+			mapping_gfp_constraint(mapping, ~__GFP_FS));
+	if (!page) {
+		ret = VM_FAULT_OOM;
+		goto out_inline;
+	}
+
+	err = __ceph_do_getattr(inode, page, CEPH_STAT_CAP_INLINE_DATA, true);
+	if (err < 0 || off >= i_size_read(inode)) {
+		unlock_page(page);
+		put_page(page);
+		if (err < 0)
+			goto out_errno;
+		ret = VM_FAULT_SIGBUS;
 	} else {
-		int ret1;
-		struct address_space *mapping = inode->i_mapping;
-		struct page *page = find_or_create_page(mapping, 0,
-						mapping_gfp_constraint(mapping,
-						~__GFP_FS));
-		if (!page) {
-			ret = VM_FAULT_OOM;
-			goto out_inline;
-		}
-		ret1 = __ceph_do_getattr(inode, page,
-					 CEPH_STAT_CAP_INLINE_DATA, true);
-		if (ret1 < 0 || off >= i_size_read(inode)) {
-			unlock_page(page);
-			put_page(page);
-			if (ret1 < 0)
-				ret = ret1;
-			else
-				ret = VM_FAULT_SIGBUS;
-			goto out_inline;
-		}
-		if (ret1 < PAGE_SIZE)
-			zero_user_segment(page, ret1, PAGE_SIZE);
+		if (err < PAGE_SIZE)
+			zero_user_segment(page, err, PAGE_SIZE);
 		else
 			flush_dcache_page(page);
 		SetPageUptodate(page);
 		vmf->page = page;
 		ret = VM_FAULT_MAJOR | VM_FAULT_LOCKED;
-out_inline:
-		dout("filemap_fault %p %llu~%zd read inline data ret %d\n",
-		     inode, off, (size_t)PAGE_SIZE, ret);
 	}
+
+out_inline:
+	dout("filemap_fault %p %llu~%zd read inline data ret %d\n",
+	     inode, off, (size_t)PAGE_SIZE, ret);
 out_restore:
 	ceph_restore_sigs(&oldset);
-	if (ret < 0)
-		ret = (ret == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
-
 	return ret;
+out_errno:
+	ret = (err == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
+	goto out_restore;
 }
 
 /*
  * Reuse write_begin here for simplicity.
  */
-static int ceph_page_mkwrite(struct vm_fault *vmf)
+static vm_fault_t ceph_page_mkwrite(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct inode *inode = file_inode(vma->vm_file);
@@ -1532,7 +1533,8 @@ static int ceph_page_mkwrite(struct vm_fault *vmf)
 	loff_t off = page_offset(page);
 	loff_t size = i_size_read(inode);
 	size_t len;
-	int want, got, ret;
+	int want, got, err = 0;
+	vm_fault_t ret = 0;
 	sigset_t oldset;
 
 	prealloc_cf = ceph_alloc_cap_flush();
@@ -1547,10 +1549,10 @@ static int ceph_page_mkwrite(struct vm_fault *vmf)
 			lock_page(page);
 			locked_page = page;
 		}
-		ret = ceph_uninline_data(vma->vm_file, locked_page);
+		err = ceph_uninline_data(vma->vm_file, locked_page);
 		if (locked_page)
 			unlock_page(locked_page);
-		if (ret < 0)
+		if (err < 0)
 			goto out_free;
 	}
 
@@ -1567,9 +1569,9 @@ static int ceph_page_mkwrite(struct vm_fault *vmf)
 		want = CEPH_CAP_FILE_BUFFER;
 
 	got = 0;
-	ret = ceph_get_caps(ci, CEPH_CAP_FILE_WR, want, off + len,
+	err = ceph_get_caps(ci, CEPH_CAP_FILE_WR, want, off + len,
 			    &got, NULL);
-	if (ret < 0)
+	if (err < 0)
 		goto out_free;
 
 	dout("page_mkwrite %p %llu~%zd got cap refs on %s\n",
@@ -1587,13 +1589,13 @@ static int ceph_page_mkwrite(struct vm_fault *vmf)
 			break;
 		}
 
-		ret = ceph_update_writeable_page(vma->vm_file, off, len, page);
-		if (ret >= 0) {
+		err = ceph_update_writeable_page(vma->vm_file, off, len, page);
+		if (err >= 0) {
 			/* success.  we'll keep the page locked. */
 			set_page_dirty(page);
 			ret = VM_FAULT_LOCKED;
 		}
-	} while (ret == -EAGAIN);
+	} while (err == -EAGAIN);
 
 	if (ret == VM_FAULT_LOCKED ||
 	    ci->i_inline_version != CEPH_INLINE_NONE) {
@@ -1608,13 +1610,13 @@ static int ceph_page_mkwrite(struct vm_fault *vmf)
 	}
 
 	dout("page_mkwrite %p %llu~%zd dropping cap refs on %s ret %d\n",
-	     inode, off, len, ceph_cap_string(got), ret);
+	     inode, off, len, ceph_cap_string(got), err);
 	ceph_put_cap_refs(ci, got);
 out_free:
 	ceph_restore_sigs(&oldset);
 	ceph_free_cap_flush(prealloc_cf);
-	if (ret < 0)
-		ret = (ret == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
+	if (err < 0)
+		ret = (err == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
 	return ret;
 }
 
-- 
2.17.0
