From: Christoph Hellwig <hch@lst.de>
Date: Wed, 16 May 2018 07:43:46 +0200
Subject: [lustre-devel] [PATCH 12/14] lustre: separate errno from VM_FAULT_*
 values
In-Reply-To: <20180516054348.15950-1-hch@lst.de>
References: <20180516054348.15950-1-hch@lst.de>
Message-ID: <20180516054348.15950-13-hch@lst.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, ocfs2-devel@oss.oracle.com, devel@lists.orangefs.org, linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, lustre-devel@lists.lustre.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 .../staging/lustre/lustre/llite/llite_mmap.c  | 37 +++++++------------
 .../lustre/lustre/llite/vvp_internal.h        |  2 +-
 2 files changed, 14 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 214b07554e62..061d98871959 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -231,23 +231,18 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
 	return result;
 }
 
-static inline int to_fault_error(int result)
+static inline vm_fault_t to_fault_error(int result)
 {
 	switch (result) {
 	case 0:
-		result = VM_FAULT_LOCKED;
-		break;
+		return VM_FAULT_LOCKED;
 	case -EFAULT:
-		result = VM_FAULT_NOPAGE;
-		break;
+		return VM_FAULT_NOPAGE;
 	case -ENOMEM:
-		result = VM_FAULT_OOM;
-		break;
+		return VM_FAULT_OOM;
 	default:
-		result = VM_FAULT_SIGBUS;
-		break;
+		return VM_FAULT_SIGBUS;
 	}
-	return result;
 }
 
 /**
@@ -261,7 +256,7 @@ static inline int to_fault_error(int result)
  * \retval VM_FAULT_ERROR on general error
  * \retval NOPAGE_OOM not have memory for allocate new page
  */
-static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
+static vm_fault_t ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct lu_env	   *env;
 	struct cl_io	    *io;
@@ -269,7 +264,7 @@ static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct page	     *vmpage;
 	unsigned long	    ra_flags;
 	int		      result = 0;
-	int		      fault_ret = 0;
+	vm_fault_t	      fault_ret = 0;
 	u16 refcheck;
 
 	env = cl_env_get(&refcheck);
@@ -323,7 +318,7 @@ static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return fault_ret;
 }
 
-static int ll_fault(struct vm_fault *vmf)
+static vm_fault_t ll_fault(struct vm_fault *vmf)
 {
 	int count = 0;
 	bool printed = false;
@@ -364,7 +359,7 @@ static int ll_fault(struct vm_fault *vmf)
 	return result;
 }
 
-static int ll_page_mkwrite(struct vm_fault *vmf)
+static vm_fault_t ll_page_mkwrite(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	int count = 0;
@@ -390,22 +385,16 @@ static int ll_page_mkwrite(struct vm_fault *vmf)
 	switch (result) {
 	case 0:
 		LASSERT(PageLocked(vmf->page));
-		result = VM_FAULT_LOCKED;
-		break;
+		return VM_FAULT_LOCKED;
 	case -ENODATA:
 	case -EAGAIN:
 	case -EFAULT:
-		result = VM_FAULT_NOPAGE;
-		break;
+		return VM_FAULT_NOPAGE;
 	case -ENOMEM:
-		result = VM_FAULT_OOM;
-		break;
+		return VM_FAULT_OOM;
 	default:
-		result = VM_FAULT_SIGBUS;
-		break;
+		return VM_FAULT_SIGBUS;
 	}
-
-	return result;
 }
 
 /**
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 7d3abb43584a..c194966a3d82 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -83,7 +83,7 @@ struct vvp_io {
 			/**
 			 * fault API used bitflags for return code.
 			 */
-			unsigned int    ft_flags;
+			vm_fault_t    ft_flags;
 			/**
 			 * check that flags are from filemap_fault
 			 */
-- 
2.17.0
