From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 17 May 2018 00:27:11 +0530
Subject: [lustre-devel] [PATCH v2] staging: lustre: Change return type to
 vm_fault_t
Message-ID: <20180516185711.GA6587@jordon-HP-15-Notebook-PC>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Use new return type vm_fault_t for fault handler. For
now, this is just documenting that the function returns
a VM_FAULT value rather than an errno. Once all instances
are converted, vm_fault_t will become a distinct type.

Commit 1c8f422059ae ("mm: change return type to vm_fault_t")

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
v2: updated the change log

 drivers/staging/lustre/lustre/llite/llite_mmap.c | 35 ++++++++++++------------
 1 file changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index c0533bd..5b8fd10 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -231,7 +231,7 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
 	return result;
 }
 
-static inline int to_fault_error(int result)
+static inline vm_fault_t to_fault_error(int result)
 {
 	switch (result) {
 	case 0:
@@ -261,7 +261,7 @@ static inline int to_fault_error(int result)
  * \retval VM_FAULT_ERROR on general error
  * \retval NOPAGE_OOM not have memory for allocate new page
  */
-static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
+static vm_fault_t ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct lu_env	   *env;
 	struct cl_io	    *io;
@@ -269,16 +269,16 @@ static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct page	     *vmpage;
 	unsigned long	    ra_flags;
 	int		      result = 0;
-	int		      fault_ret = 0;
+	vm_fault_t		fault_ret = 0;
 	u16 refcheck;
 
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
-		return PTR_ERR(env);
+		return VM_FAULT_ERROR;
 
 	io = ll_fault_io_init(env, vma, vmf->pgoff, &ra_flags);
 	if (IS_ERR(io)) {
-		result = to_fault_error(PTR_ERR(io));
+		fault_ret = to_fault_error(PTR_ERR(io));
 		goto out;
 	}
 
@@ -319,15 +319,15 @@ static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (result != 0 && !(fault_ret & VM_FAULT_RETRY))
 		fault_ret |= to_fault_error(result);
 
-	CDEBUG(D_MMAP, "%s fault %d/%d\n", current->comm, fault_ret, result);
+	CDEBUG(D_MMAP, "%s fault %x/%d\n", current->comm, fault_ret, result);
 	return fault_ret;
 }
 
-static int ll_fault(struct vm_fault *vmf)
+static vm_fault_t ll_fault(struct vm_fault *vmf)
 {
 	int count = 0;
 	bool printed = false;
-	int result;
+	vm_fault_t result;
 	sigset_t set;
 
 	/* Only SIGKILL and SIGTERM are allowed for fault/nopage/mkwrite
@@ -364,18 +364,19 @@ static int ll_fault(struct vm_fault *vmf)
 	return result;
 }
 
-static int ll_page_mkwrite(struct vm_fault *vmf)
+static vm_fault_t ll_page_mkwrite(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	int count = 0;
 	bool printed = false;
 	bool retry;
-	int result;
+	int err;
+	vm_fault_t ret;
 
 	file_update_time(vma->vm_file);
 	do {
 		retry = false;
-		result = ll_page_mkwrite0(vma, vmf->page, &retry);
+		err = ll_page_mkwrite0(vma, vmf->page, &retry);
 
 		if (!printed && ++count > 16) {
 			const struct dentry *de = vma->vm_file->f_path.dentry;
@@ -387,25 +388,25 @@ static int ll_page_mkwrite(struct vm_fault *vmf)
 		}
 	} while (retry);
 
-	switch (result) {
+	switch (err) {
 	case 0:
 		LASSERT(PageLocked(vmf->page));
-		result = VM_FAULT_LOCKED;
+		ret = VM_FAULT_LOCKED;
 		break;
 	case -ENODATA:
 	case -EAGAIN:
 	case -EFAULT:
-		result = VM_FAULT_NOPAGE;
+		ret = VM_FAULT_NOPAGE;
 		break;
 	case -ENOMEM:
-		result = VM_FAULT_OOM;
+		ret = VM_FAULT_OOM;
 		break;
 	default:
-		result = VM_FAULT_SIGBUS;
+		ret = VM_FAULT_SIGBUS;
 		break;
 	}
 
-	return result;
+	return ret;
 }
 
 /**
-- 
1.9.1
