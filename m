Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65F1EC433ED
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:28 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B4ACF61396
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4ACF61396
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7FA7E21F9D7;
	Mon,  5 Apr 2021 00:51:24 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id ACAD021F521
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:18 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8EE9C6B7;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 865D290AAC; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:31 -0400
Message-Id: <1617583870-32029-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/41] lustre: llite: make readahead aware of
 hints
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Cc: Wang Shilong <wshilong@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Wang Shilong <wshilong@ddn.com>

Calling madvise(MADV_SEQUENTIAL) and madvise(MADV_RANDOM) sets the
VM_SEQ_READ and VM_RAND_READ hints in vma->vm_flags.  These should
be used to guide the Lustre readahead for better performance.

Disable the kernel readahead for mmap() pages and use the llite
readahead instead.  There was also a bug in __ll_fault() that would
set both VM_SEQ_READ and VM_RAND_READ at the same time, which was
confusing the detection of the VM_SEQ_READ case, since VM_RAND_READ
was being checked first.

This changes the readahead for mmap from submitting mostly 4KB RPCs
to a large number of 1MB RPCs for the application profiled:

  llite.*.read_ahead_stats     before        patched
  ------------------------     ------        -------
  hits                           2408         135924 samples [pages]
  misses                        34160           2384 samples [pages]

  osc.*.rpc_stats           read before    read patched
  ---------------          -------------  --------------
  pages per rpc            rpcs   % cum%   rpcs   % cum%
     1:                    6542  95  95     351  55  55
     2:                     224   3  99      76  12  67
     4:                      32   0  99      28   4  72
     8:                       2   0  99       9   1  73
    16:                      25   0  99      32   5  78
    32:                       0   0  99       8   1  80
    64:                       0   0  99       5   0  80
   128:                       0   0  99      15   2  83
   256:                       2   0  99     102  16  99
   512:                       0   0  99       0   0  99
  1024:                       1   0 100       3   0 100

Readahead hit rate improved from 6% to 98%, and 4KB RPCs dropped from
95% to 55% and 1MB+ RPCs increased from 0% to 16% (79% of all pages).

Add debug to ll_file_mmap(), ll_fault() and ll_fault_io_init() to
allow tracing VMA state functions for future IO optimizations.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13669
Lustre-commit: 7542820698696ed ("LU-13669 llite: make readahead aware of hints")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/41228
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h | 10 +++++++++-
 fs/lustre/llite/file.c        |  2 ++
 fs/lustre/llite/llite_mmap.c  | 42 ++++++++++++++++++++++--------------------
 fs/lustre/llite/rw.c          | 20 ++++++++++++++++----
 4 files changed, 49 insertions(+), 25 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 4f34e5d..739fe5b 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1974,7 +1974,15 @@ struct cl_io {
 	 * the read IO will check to-be-read OSCs' status, and make fast-switch
 	 * another mirror if some of the OSTs are not healthy.
 	 */
-				ci_tried_all_mirrors:1;
+				ci_tried_all_mirrors:1,
+	/**
+	 * Random read hints, readahead will be disabled.
+	 */
+				ci_rand_read:1,
+	/**
+	 * Sequential read hints.
+	 */
+				ci_seq_read:1;
 	/**
 	 * Bypass quota check
 	 */
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 7c7ac01..fd01e14 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -736,6 +736,8 @@ static int ll_local_open(struct file *file, struct lookup_intent *it,
 	file->private_data = fd;
 	ll_readahead_init(inode, &fd->fd_ras);
 	fd->fd_omode = it->it_flags & (FMODE_READ | FMODE_WRITE | FMODE_EXEC);
+	/* turn off the kernel's read-ahead */
+	file->f_ra.ra_pages = 0;
 
 	/* ll_cl_context initialize */
 	rwlock_init(&fd->fd_lock);
diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index f0be7ba..b9a73e0 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -84,13 +84,11 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
  * @vma		virtual memory area addressed to page fault
  * @env		corespondent lu_env to processing
  * @index	page index corespondent to fault.
- * @ra_flags	vma readahead flags.
  *
- * \return error codes from cl_io_init.
+ * RETURN	error codes from cl_io_init.
  */
 static struct cl_io *
-ll_fault_io_init(struct lu_env *env, struct vm_area_struct *vma,
-		 pgoff_t index, unsigned long *ra_flags)
+ll_fault_io_init(struct lu_env *env, struct vm_area_struct *vma, pgoff_t index)
 {
 	struct file *file = vma->vm_file;
 	struct inode *inode = file_inode(file);
@@ -110,18 +108,15 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 	fio->ft_index = index;
 	fio->ft_executable = vma->vm_flags & VM_EXEC;
 
-	/*
-	 * disable VM_SEQ_READ and use VM_RAND_READ to make sure that
-	 * the kernel will not read other pages not covered by ldlm in
-	 * filemap_nopage. we do our readahead in ll_readpage.
-	 */
-	if (ra_flags)
-		*ra_flags = vma->vm_flags & (VM_RAND_READ | VM_SEQ_READ);
-	vma->vm_flags &= ~VM_SEQ_READ;
-	vma->vm_flags |= VM_RAND_READ;
+	CDEBUG(D_MMAP,
+	       DFID": vma=%p start=%#lx end=%#lx vm_flags=%#lx idx=%lu\n",
+	       PFID(&ll_i2info(inode)->lli_fid), vma, vma->vm_start,
+	       vma->vm_end, vma->vm_flags, fio->ft_index);
 
-	CDEBUG(D_MMAP, "vm_flags: %lx (%lu %d)\n", vma->vm_flags,
-	       fio->ft_index, fio->ft_executable);
+	if (vma->vm_flags & VM_SEQ_READ)
+		io->ci_seq_read = 1;
+	else if (vma->vm_flags & VM_RAND_READ)
+		io->ci_rand_read = 1;
 
 	rc = cl_io_init(env, io, CIT_FAULT, io->ci_obj);
 	if (rc == 0) {
@@ -161,7 +156,7 @@ static int __ll_page_mkwrite(struct vm_area_struct *vma, struct page *vmpage,
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	io = ll_fault_io_init(env, vma, vmpage->index, NULL);
+	io = ll_fault_io_init(env, vma, vmpage->index);
 	if (IS_ERR(io)) {
 		result = PTR_ERR(io);
 		goto out;
@@ -277,7 +272,6 @@ static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct cl_io *io;
 	struct vvp_io *vio = NULL;
 	struct page *vmpage;
-	unsigned long ra_flags;
 	int result = 0;
 	vm_fault_t fault_ret = 0;
 	u16 refcheck;
@@ -314,7 +308,7 @@ static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		fault_ret = 0;
 	}
 
-	io = ll_fault_io_init(env, vma, vmf->pgoff, &ra_flags);
+	io = ll_fault_io_init(env, vma, vmf->pgoff);
 	if (IS_ERR(io)) {
 		fault_ret = to_fault_error(PTR_ERR(io));
 		goto out;
@@ -350,8 +344,6 @@ static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	}
 	cl_io_fini(env, io);
 
-	vma->vm_flags |= ra_flags;
-
 out:
 	cl_env_put(env, &refcheck);
 	if (result != 0 && !(fault_ret & VM_FAULT_RETRY))
@@ -375,6 +367,10 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
 	if (cached)
 		goto out;
 
+	CDEBUG(D_MMAP, DFID": vma=%p start=%#lx end=%#lx vm_flags=%#lx\n",
+	       PFID(&ll_i2info(file_inode(vma->vm_file))->lli_fid),
+	       vma, vma->vm_start, vma->vm_end, vma->vm_flags);
+
 	/* Only SIGKILL and SIGTERM are allowed for fault/nopage/mkwrite
 	 * so that it can be killed by admin but not cause segfault by
 	 * other signals.
@@ -385,6 +381,7 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
 	/* make sure offset is not a negative number */
 	if (vmf->pgoff > (MAX_LFS_FILESIZE >> PAGE_SHIFT))
 		return VM_FAULT_SIGBUS;
+
 restart:
 	result = __ll_fault(vmf->vma, vmf);
 	if (vmf->page &&
@@ -545,6 +542,11 @@ int ll_file_mmap(struct file *file, struct vm_area_struct *vma)
 	bool cached;
 	int rc;
 
+	CDEBUG(D_VFSTRACE | D_MMAP,
+	       "VFS_Op: fid="DFID" vma=%p start=%#lx end=%#lx vm_flags=%#lx\n",
+	       PFID(&ll_i2info(inode)->lli_fid),
+	       vma, vma->vm_start, vma->vm_end, vma->vm_flags);
+
 	if (ll_file_nolock(file))
 		return -EOPNOTSUPP;
 
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 096e015..8bba97f 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1255,7 +1255,7 @@ static bool index_in_stride_window(struct ll_readahead_state *ras,
  */
 static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 		       struct ll_readahead_state *ras, pgoff_t index,
-		       enum ras_update_flags flags)
+		       enum ras_update_flags flags, struct cl_io *io)
 {
 	struct ll_ra_info *ra = &sbi->ll_ra_info;
 	bool hit = flags & LL_RAS_HIT;
@@ -1276,6 +1276,18 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	if (ras->ras_no_miss_check)
 		goto out_unlock;
 
+	if (io && io->ci_rand_read)
+		goto out_unlock;
+
+	if (io && io->ci_seq_read) {
+		if (!hit) {
+			/* to avoid many small read RPC here */
+			ras->ras_window_pages = sbi->ll_ra_info.ra_range_pages;
+			ll_ra_stats_inc_sbi(sbi, RA_STAT_MMAP_RANGE_READ);
+		}
+		goto skip;
+	}
+
 	if (flags & LL_RAS_MMAP) {
 		unsigned long ra_pages;
 
@@ -1594,7 +1606,7 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 			flags |= LL_RAS_HIT;
 		if (!vio->vui_ra_valid)
 			flags |= LL_RAS_MMAP;
-		ras_update(sbi, inode, ras, vvp_index(vpg), flags);
+		ras_update(sbi, inode, ras, vvp_index(vpg), flags, io);
 	}
 
 	cl_2queue_init(queue);
@@ -1613,7 +1625,7 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	io_start_index = cl_index(io->ci_obj, io->u.ci_rw.crw_pos);
 	io_end_index = cl_index(io->ci_obj, io->u.ci_rw.crw_pos +
 				io->u.ci_rw.crw_count - 1);
-	if (ll_readahead_enabled(sbi) && ras) {
+	if (ll_readahead_enabled(sbi) && ras && !io->ci_rand_read) {
 		pgoff_t skip_index = 0;
 
 		if (ras->ras_next_readahead_idx < vvp_index(vpg))
@@ -1802,7 +1814,7 @@ int ll_readpage(struct file *file, struct page *vmpage)
 			 * if the page is hit in cache because non cache page
 			 * case will be handled by slow read later.
 			 */
-			ras_update(sbi, inode, ras, vvp_index(vpg), flags);
+			ras_update(sbi, inode, ras, vvp_index(vpg), flags, io);
 			/* avoid duplicate ras_update() call */
 			vpg->vpg_ra_updated = 1;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
