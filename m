Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0541EC25B50
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:39:57 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15TS5Nq8z22Zx;
	Mon, 23 Jan 2023 15:11:56 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15TJ5yHsz22Zm
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:11:48 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B791CE21;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B36D858987; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:52 -0500
Message-Id: <1674514855-15399-40-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 39/42] lustre: llite: revert: "llite: clear
 stale page's uptodate bit"
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Bobi Jam <bobijam@whamcloud.com>

This reverts commit 23c4c1c09cfebccea37a88a27f122646168cbad4

which caused a bug in cl_page_own() race with ll_releasepage()
and cl_pagevec_put() assertion failure.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16160
Lustre-commit: 84c9618190f9e3a52 ("LU-16160 revert: "llite: clear stale page's uptodate bit")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49541
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Qian Yingjin <qian@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  15 +---
 fs/lustre/llite/rw.c          |  10 +--
 fs/lustre/llite/vvp_io.c      | 124 +++-------------------------------
 fs/lustre/llite/vvp_page.c    |   5 --
 fs/lustre/obdclass/cl_page.c  |  37 +++-------
 5 files changed, 19 insertions(+), 172 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 8be58ffb9f34..41ce0b02e00e 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -768,15 +768,7 @@ struct cl_page {
 	enum cl_page_type		 cp_type:CP_TYPE_BITS;
 	unsigned int			 cp_defer_uptodate:1,
 					 cp_ra_updated:1,
-					 cp_ra_used:1,
-					 /* fault page read grab extra referece */
-					 cp_fault_ref:1,
-					 /**
-					  * if fault page got delete before returned to
-					  * filemap_fault(), defer the vmpage detach/put
-					  * until filemap_fault() has been handled.
-					  */
-					 cp_defer_detach:1;
+					 cp_ra_used:1;
 
 	/* which slab kmem index this memory allocated from */
 	short int			 cp_kmem_index;
@@ -2401,11 +2393,6 @@ int cl_io_lru_reserve(const struct lu_env *env, struct cl_io *io,
 int cl_io_read_ahead(const struct lu_env *env, struct cl_io *io,
 		     pgoff_t start, struct cl_read_ahead *ra);
 
-static inline int cl_io_is_pagefault(const struct cl_io *io)
-{
-	return io->ci_type == CIT_FAULT && !io->u.ci_fault.ft_mkwrite;
-}
-
 /**
  * True, if @io is an O_APPEND write(2).
  */
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 0283af422712..2290b3112380 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1947,15 +1947,7 @@ int ll_readpage(struct file *file, struct page *vmpage)
 			unlock_page(vmpage);
 			result = 0;
 		}
-		if (cl_io_is_pagefault(io) && result == 0) {
-			/**
-			 * page fault, retain the cl_page reference until
-			 * vvp_io_kernel_fault() release it.
-			 */
-			page->cp_fault_ref = 1;
-		} else {
-			cl_page_put(env, page);
-		}
+		cl_page_put(env, page);
 	} else {
 		unlock_page(vmpage);
 		result = PTR_ERR(page);
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 317704172080..eacb35b500e5 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -1302,41 +1302,14 @@ static void vvp_io_rw_end(const struct lu_env *env,
 	trunc_sem_up_read(&lli->lli_trunc_sem);
 }
 
-static void detach_and_deref_page(struct cl_page *clp, struct page *vmpage)
-{
-	if (!clp->cp_defer_detach)
-		return;
-
-	/**
-	 * cl_page_delete0() took a vmpage reference, but not unlink the vmpage
-	 * from its cl_page.
-	 */
-	clp->cp_defer_detach = 0;
-	ClearPagePrivate(vmpage);
-	vmpage->private = 0;
-
-	put_page(vmpage);
-	refcount_dec(&clp->cp_ref);
-}
-
-static int vvp_io_kernel_fault(const struct lu_env *env,
-			       struct vvp_fault_io *cfio)
+static int vvp_io_kernel_fault(struct vvp_fault_io *cfio)
 {
 	struct vm_fault *vmf = cfio->ft_vmf;
-	struct file *vmff = cfio->ft_vma->vm_file;
-	struct address_space *mapping = vmff->f_mapping;
-	struct inode *inode = mapping->host;
-	struct page *vmpage = NULL;
-	struct cl_page *clp = NULL;
-	int rc = 0;
 
-	ll_inode_size_lock(inode);
-retry:
 	cfio->ft_flags = filemap_fault(vmf);
 	cfio->ft_flags_valid = 1;
 
 	if (vmf->page) {
-		/* success, vmpage is locked */
 		CDEBUG(D_PAGE,
 		       "page %p map %p index %lu flags %lx count %u priv %0lx: got addr %p type NOPAGE\n",
 		       vmf->page, vmf->page->mapping, vmf->page->index,
@@ -1348,105 +1321,24 @@ static int vvp_io_kernel_fault(const struct lu_env *env,
 		}
 
 		cfio->ft_vmpage = vmf->page;
-
-		/**
-		 * ll_filemap_fault()->ll_readpage() could get an extra cl_page
-		 * reference. So we have to get the cl_page's to check its
-		 * cp_fault_ref and drop the reference later.
-		 */
-		clp = cl_vmpage_page(vmf->page, NULL);
-
-		goto unlock;
-	}
-
-	/* filemap_fault() fails, vmpage is not locked */
-	if (!clp) {
-		vmpage = find_get_page(mapping, vmf->pgoff);
-		if (vmpage) {
-			lock_page(vmpage);
-			clp = cl_vmpage_page(vmpage, NULL);
-			unlock_page(vmpage);
-		}
+		return 0;
 	}
 
 	if (cfio->ft_flags & (VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV)) {
-		pgoff_t max_idx;
-
-		/**
-		 * ll_filemap_fault()->ll_readpage() could fill vmpage
-		 * correctly, and unlock the vmpage, while memory pressure or
-		 * truncate could detach cl_page from vmpage, and kernel
-		 * filemap_fault() will wait_on_page_locked(vmpage) and find
-		 * out that the vmpage has been cleared its uptodate bit,
-		 * so it returns VM_FAULT_SIGBUS.
-		 *
-		 * In this case, we'd retry the filemap_fault()->ll_readpage()
-		 * to rebuild the cl_page and fill vmpage with uptodated data.
-		 */
-		if (likely(vmpage)) {
-			bool need_retry = false;
-
-			if (clp) {
-				if (clp->cp_defer_detach) {
-					detach_and_deref_page(clp, vmpage);
-					/**
-					 * check i_size to make sure it's not
-					 * over EOF, we don't want to call
-					 * filemap_fault() repeatedly since it
-					 * returns VM_FAULT_SIGBUS without even
-					 * trying if vmf->pgoff is over EOF.
-					 */
-					max_idx = DIV_ROUND_UP(i_size_read(inode),
-							       PAGE_SIZE);
-					if (vmf->pgoff < max_idx)
-						need_retry = true;
-				}
-				if (clp->cp_fault_ref) {
-					clp->cp_fault_ref = 0;
-					/* ref not released in ll_readpage() */
-					cl_page_put(env, clp);
-				}
-				if (need_retry)
-					goto retry;
-			}
-		}
-
 		CDEBUG(D_PAGE, "got addr %p - SIGBUS\n", (void *)vmf->address);
-		rc = -EFAULT;
-		goto unlock;
+		return -EFAULT;
 	}
 
 	if (cfio->ft_flags & VM_FAULT_OOM) {
 		CDEBUG(D_PAGE, "got addr %p - OOM\n", (void *)vmf->address);
-		rc = -ENOMEM;
-		goto unlock;
+		return -ENOMEM;
 	}
 
-	if (cfio->ft_flags & VM_FAULT_RETRY) {
-		rc = -EAGAIN;
-		goto unlock;
-	}
+	if (cfio->ft_flags & VM_FAULT_RETRY)
+		return -EAGAIN;
 
 	CERROR("Unknown error in page fault %d!\n", cfio->ft_flags);
-	rc = -EINVAL;
-unlock:
-	ll_inode_size_unlock(inode);
-	if (clp) {
-		if (clp->cp_defer_detach && vmpage)
-			detach_and_deref_page(clp, vmpage);
-
-		/* additional cl_page ref has been taken in ll_readpage() */
-		if (clp->cp_fault_ref) {
-			clp->cp_fault_ref = 0;
-			/* ref not released in ll_readpage() */
-			cl_page_put(env, clp);
-		}
-		/* ref taken in this function */
-		cl_page_put(env, clp);
-	}
-	if (vmpage)
-		put_page(vmpage);
-	return rc;
+	return -EINVAL;
 }
 
 static void mkwrite_commit_callback(const struct lu_env *env, struct cl_io *io,
@@ -1486,7 +1378,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 		LASSERT(cfio->ft_vmpage);
 		lock_page(cfio->ft_vmpage);
 	} else {
-		result = vvp_io_kernel_fault(env, cfio);
+		result = vvp_io_kernel_fault(cfio);
 		if (result != 0)
 			return result;
 	}
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index 9e8c1588347f..f359596bc32d 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -104,11 +104,6 @@ static void vvp_page_completion_read(const struct lu_env *env,
 		ll_ra_count_put(ll_i2sbi(inode), 1);
 
 	if (ioret == 0)  {
-		/**
-		 * cp_defer_uptodate is used for readahead page, and the
-		 * vmpage Uptodate bit is deferred to set in ll_readpage/
-		 * ll_io_read_page.
-		 */
 		if (!cp->cp_defer_uptodate)
 			SetPageUptodate(vmpage);
 	} else if (cp->cp_defer_uptodate) {
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 3bc1a9b0eb98..7011235a9b3c 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -725,35 +725,16 @@ static void __cl_page_delete(const struct lu_env *env, struct cl_page *cp)
 		LASSERT(PageLocked(vmpage));
 		LASSERT((struct cl_page *)vmpage->private == cp);
 
-		/**
-		 * clear vmpage uptodate bit, since ll_read_ahead_pages()->
-		 * ll_read_ahead_page() could pick up this stale vmpage and
-		 * take it as uptodated.
-		 */
-		ClearPageUptodate(vmpage);
-		/**
-		 * vvp_io_kernel_fault()->ll_readpage() set cp_fault_ref
-		 * and need it to check cl_page to retry the page fault read.
+		/* Drop the reference count held in vvp_page_init */
+		refcount_dec(&cp->cp_ref);
+		ClearPagePrivate(vmpage);
+		vmpage->private = 0;
+
+		/*
+		 * The reference from vmpage to cl_page is removed,
+		 * but the reference back is still here. It is removed
+		 * later in cl_page_free().
 		 */
-		if (cp->cp_fault_ref) {
-			cp->cp_defer_detach = 1;
-			/**
-			 * get a vmpage reference, so that filemap_fault()
-			 * won't free it from pagecache.
-			 */
-			get_page(vmpage);
-		} else {
-			/* Drop the reference count held in vvp_page_init */
-			refcount_dec(&cp->cp_ref);
-			ClearPagePrivate(vmpage);
-			vmpage->private = 0;
-
-			/*
-			 * The reference from vmpage to cl_page is removed,
-			 * but the reference back is still here. It is removed
-			 * later in cl_page_free().
-			 */
-		}
 	}
 }
 
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
