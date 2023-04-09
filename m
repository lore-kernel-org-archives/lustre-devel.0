Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CF506C77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:26:17 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWKT2Rw5z1yBt;
	Sun,  9 Apr 2023 05:15:57 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWHl4d4Mz1yDc
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:14:26 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 034E1100827C;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0229D2AB; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:54 -0400
Message-Id: <1681042400-15491-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/40] lustre: llite: check read page past
 requested
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

From: Qian Yingjin <qian@ddn.com>

Due to a kernel bug introduced in 5.12 in commit:
cbd59c48ae2bcadc4a7599c29cf32fd3f9b78251
("mm/filemap: use head pages in generic_file_buffered_read")
if the page immediately after the current read is in cache,
the kernel will try to read it.

This attempts to read a page past the end of requested
read from userspace, and so has not been safely locked by
Lustre.

For a page after the end of the current read, check whether
it is under the protection of a DLM lock. If so, we take a
reference on the DLM lock until the page read has finished
and then release the reference.  If the page is not covered
by a DLM lock, then we are racing with the page being
removed from Lustre.  In that case, we return
AOP_TRUNCATED_PAGE, which makes the kernel release its
reference on the page and retry the page read.  This allows
the page to be removed from cache, so the kernel will not
find it and incorrectly attempt to read it again.

NB: Earlier versions of this description refer to stripe
boundaries, but the locking issue can occur whether or
not the page is on a stripe boundary, because dlmlocks
can cover part of a stripe.  (This is rare, but is
allowed.)

WC-bug-id: https://jira.whamcloud.com/browse/LU-16412
Lustre-commit: 2f8f38effac3a9519 ("LU-16412 llite: check read page past requested")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49723
Reviewed-by: Zhenyu Xu <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  2 ++
 fs/lustre/llite/rw.c             | 58 +++++++++++++++++++++++++++++++++++++---
 fs/lustre/llite/vvp_io.c         | 10 +++++--
 3 files changed, 65 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 2223dbb..970b144 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1371,6 +1371,8 @@ struct ll_cl_context {
 	struct cl_io		*lcc_io;
 	struct cl_page		*lcc_page;
 	enum lcc_type		 lcc_type;
+	struct kiocb		*lcc_iocb;
+	struct iov_iter		*lcc_iter;
 };
 
 struct ll_thread_info {
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index dea2af1..d285ae1 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1858,11 +1858,14 @@ int ll_readpage(struct file *file, struct page *vmpage)
 {
 	struct inode *inode = file_inode(file);
 	struct cl_object *clob = ll_i2info(inode)->lli_clob;
-	struct ll_cl_context *lcc;
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	const struct lu_env *env = NULL;
+	struct cl_read_ahead ra = { 0 };
+	struct ll_cl_context *lcc;
 	struct cl_io *io = NULL;
+	struct iov_iter *iter;
 	struct cl_page *page;
-	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct kiocb *iocb;
 	int result;
 
 	if (OBD_FAIL_PRECHECK(OBD_FAIL_LLITE_READPAGE_PAUSE)) {
@@ -1911,6 +1914,8 @@ int ll_readpage(struct file *file, struct page *vmpage)
 		struct ll_readahead_state *ras = &fd->fd_ras;
 		struct lu_env *local_env = NULL;
 
+		CDEBUG(D_VFSTRACE, "fast read pgno: %ld\n", vmpage->index);
+
 		result = -ENODATA;
 
 		/*
@@ -1968,6 +1973,47 @@ int ll_readpage(struct file *file, struct page *vmpage)
 		return result;
 	}
 
+	if (lcc && lcc->lcc_type != LCC_MMAP) {
+		iocb = lcc->lcc_iocb;
+		iter = lcc->lcc_iter;
+
+		CDEBUG(D_VFSTRACE, "pgno:%ld, cnt:%ld, pos:%lld\n",
+		       vmpage->index, iter->count, iocb->ki_pos);
+
+		/*
+		 * This handles a kernel bug introduced in kernel 5.12:
+		 * comment: cbd59c48ae2bcadc4a7599c29cf32fd3f9b78251
+		 * ("mm/filemap: use head pages in generic_file_buffered_read")
+		 *
+		 * See above in this function for a full description of the
+		 * bug.  Briefly, the kernel will try to read 1 more page than
+		 * was actually requested *if that page is already in cache*.
+		 *
+		 * Because this page is beyond the boundary of the requested
+		 * read, Lustre does not lock it as part of the read.  This
+		 * means we must check if there is a valid dlmlock on this
+		 * page and reference it before we attempt to read in the
+		 * page.  If there is not a valid dlmlock, then we are racing
+		 * with dlmlock cancellation and the page is being removed
+		 * from the cache.
+		 *
+		 * That means we should return AOP_TRUNCATED_PAGE, which will
+		 * cause the kernel to retry the read, which should allow the
+		 * page to be removed from cache as the lock is cancelled.
+		 *
+		 * This should never occur except in kernels with the bug
+		 * mentioned above.
+		 */
+		if (cl_offset(clob, vmpage->index) >= iter->count + iocb->ki_pos) {
+			result = cl_io_read_ahead(env, io, vmpage->index, &ra);
+			if (result < 0 || vmpage->index > ra.cra_end_idx) {
+				cl_read_ahead_release(env, &ra);
+				unlock_page(vmpage);
+				return AOP_TRUNCATED_PAGE;
+			}
+		}
+	}
+
 	/**
 	 * Direct read can fall back to buffered read, but DIO is done
 	 * with lockless i/o, and buffered requires LDLM locking, so in
@@ -1979,7 +2025,8 @@ int ll_readpage(struct file *file, struct page *vmpage)
 		unlock_page(vmpage);
 		io->ci_dio_lock = 1;
 		io->ci_need_restart = 1;
-		return -ENOLCK;
+		result = -ENOLCK;
+		goto out;
 	}
 
 	page = cl_page_find(env, clob, vmpage->index, vmpage, CPT_CACHEABLE);
@@ -1999,5 +2046,10 @@ int ll_readpage(struct file *file, struct page *vmpage)
 		unlock_page(vmpage);
 		result = PTR_ERR(page);
 	}
+
+out:
+	if (ra.cra_release)
+		cl_read_ahead_release(env, &ra);
+
 	return result;
 }
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index eacb35b..2da74a2 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -806,6 +806,7 @@ static int vvp_io_read_start(const struct lu_env *env,
 	loff_t pos = io->u.ci_rd.rd.crw_pos;
 	size_t cnt = io->u.ci_rd.rd.crw_count;
 	size_t tot = vio->vui_tot_count;
+	struct ll_cl_context *lcc;
 	int exceed = 0;
 	int result;
 	struct iov_iter iter;
@@ -868,9 +869,14 @@ static int vvp_io_read_start(const struct lu_env *env,
 	file_accessed(file);
 	LASSERT(vio->vui_iocb->ki_pos == pos);
 	iter = *vio->vui_iter;
-	result = generic_file_read_iter(vio->vui_iocb, &iter);
-	goto out;
 
+	lcc = ll_cl_find(inode);
+	lcc->lcc_iter = &iter;
+	lcc->lcc_iocb = vio->vui_iocb;
+	CDEBUG(D_VFSTRACE, "cnt:%ld,iocb pos:%lld\n", lcc->lcc_iter->count,
+	       lcc->lcc_iocb->ki_pos);
+
+	result = generic_file_read_iter(vio->vui_iocb, &iter);
 out:
 	if (result >= 0) {
 		if (result < cnt)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
