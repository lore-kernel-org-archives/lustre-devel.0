Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id AB992C433EF
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:39:16 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 11DE03AD81B;
	Thu, 13 Jan 2022 17:38:50 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B8AD63AD851
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:10 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D5AF5100F333;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D47E6DF4C4; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:53 -0500
Message-Id: <1642124283-10148-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/24] lustre: llite: Add D_IOTRACE
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <pfarrell@whamcloud.com>

In looking in to performance problems, it's very important
to be able to trace the I/O patterns from userspace in to
Lustre, and also understand the key basics of how Lustre
handles that I/O (readahead, RPC generation).

This is best done with a dedicated debug flag - No
userspace tool can provide all this information, and
existing debug flags collect a huge number of unrelated
pieces of, well, debug information.

The goal is for customers to be able to quickly gather log
files of a reasonable size which contain the necessary
information and which can easily be interpreted by
engineering.  This is not possible if the information is
spread out across a number of heavyweight debug flags.

This is a first pass at adding the flag and the debug
required to track basic data I/O.  One significant
omission in the first patch is RPC generation - I have not
decided how best to do that yet.  That will be added in a
future patch.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15137
Lustre-commit: 40d286e11138fc67f ("LU-15317 llite: Add D_IOTRACE")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45752
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c                 | 10 ++++++++++
 fs/lustre/llite/llite_internal.h       |  1 +
 fs/lustre/llite/llite_mmap.c           | 13 ++++++++++---
 fs/lustre/llite/rw.c                   | 10 ++++++++--
 include/uapi/linux/lnet/libcfs_debug.h |  3 ++-
 5 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 05f2f1a..dec0109 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1954,6 +1954,11 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	ktime_t kstart = ktime_get();
 	bool cached;
 
+	CDEBUG(D_VFSTRACE|D_IOTRACE, "file %s:"DFID", ppos: %lld, count: %zu\n",
+	       file_dentry(file)->d_name.name,
+	       PFID(ll_inode2fid(file_inode(file))), iocb->ki_pos,
+	       iov_iter_count(to));
+
 	if (!iov_iter_count(to))
 		return 0;
 
@@ -2075,6 +2080,11 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	ktime_t kstart = ktime_get();
 	int result;
 
+	CDEBUG(D_VFSTRACE|D_IOTRACE, "file %s:"DFID", ppos: %lld, count: %zu\n",
+	       file_dentry(file)->d_name.name,
+	       PFID(ll_inode2fid(file_inode(file))), iocb->ki_pos,
+	       iov_iter_count(from));
+
 	if (!iov_iter_count(from)) {
 		rc_normal = 0;
 		goto out;
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 54f0218..8c7361a 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -885,6 +885,7 @@ struct ll_readahead_work {
 	struct file			*lrw_file;
 	pgoff_t				 lrw_start_idx;
 	pgoff_t				 lrw_end_idx;
+	pid_t				 lrw_user_pid;
 
 	/* async worker to handler read */
 	struct work_struct		 lrw_readahead_work;
diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index 0009c5f..d87a68d 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -377,9 +377,10 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
 	if (cached)
 		goto out;
 
-	CDEBUG(D_MMAP, DFID": vma=%p start=%#lx end=%#lx vm_flags=%#lx\n",
+	CDEBUG(D_MMAP|D_IOTRACE,
+	       DFID": vma=%p start=%#lx end=%#lx vm_flags=%#lx idx=%lu\n",
 	       PFID(&ll_i2info(file_inode(vma->vm_file))->lli_fid),
-	       vma, vma->vm_start, vma->vm_end, vma->vm_flags);
+	       vma, vma->vm_start, vma->vm_end, vma->vm_flags, vmf->pgoff);
 
 	/* Only SIGKILL and SIGTERM are allowed for fault/nopage/mkwrite
 	 * so that it can be killed by admin but not cause segfault by
@@ -440,8 +441,14 @@ static vm_fault_t ll_page_mkwrite(struct vm_fault *vmf)
 	bool retry;
 	bool cached;
 	int err;
-	vm_fault_t ret;
 	ktime_t kstart = ktime_get();
+	vm_fault_t ret;
+
+	CDEBUG(D_MMAP|D_IOTRACE,
+	       DFID": vma=%p start=%#lx end=%#lx vm_flags=%#lx idx=%lu\n",
+	       PFID(&ll_i2info(file_inode(vma->vm_file))->lli_fid),
+	       vma, vma->vm_start, vma->vm_end, vma->vm_flags,
+	       vmf->page->index);
 
 	ret = pcc_page_mkwrite(vma, vmf, &cached);
 	if (cached)
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index c9f29ef..9f6e140 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -595,6 +595,11 @@ static void ll_readahead_handle_work(struct work_struct *wq)
 	inode = file_inode(file);
 	sbi = ll_i2sbi(inode);
 
+	CDEBUG(D_READA|D_IOTRACE,
+	       "%s: async ra from %lu to %lu triggered by user pid %d\n",
+	       file_dentry(file)->d_name.name, work->lrw_start_idx,
+	       work->lrw_end_idx, work->lrw_user_pid);
+
 	env = cl_env_alloc(&refcheck, LCT_NOREF);
 	if (IS_ERR(env)) {
 		rc = PTR_ERR(env);
@@ -1301,7 +1306,7 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	spin_lock(&ras->ras_lock);
 
 	if (!hit)
-		CDEBUG(D_READA, DFID " pages at %lu miss.\n",
+		CDEBUG(D_READA|D_IOTRACE, DFID " pages at %lu miss.\n",
 		       PFID(ll_inode2fid(inode)), index);
 	ll_ra_stats_inc_sbi(sbi, hit ? RA_STAT_HIT : RA_STAT_MISS);
 
@@ -1670,7 +1675,7 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 			skip_index = vvp_index(vpg);
 		rc2 = ll_readahead(env, io, &queue->c2_qin, ras,
 				   uptodate, file, skip_index);
-		CDEBUG(D_READA, DFID " %d pages read ahead at %lu\n",
+		CDEBUG(D_READA|D_IOTRACE, DFID " %d pages read ahead at %lu\n",
 		       PFID(ll_inode2fid(inode)), rc2, vvp_index(vpg));
 	} else if (vvp_index(vpg) == io_start_index &&
 		   io_end_index - io_start_index > 0) {
@@ -1770,6 +1775,7 @@ static int kickoff_async_readahead(struct file *file, unsigned long pages)
 		lrw->lrw_file = get_file(file);
 		lrw->lrw_start_idx = start_idx;
 		lrw->lrw_end_idx = end_idx;
+		lrw->lrw_user_pid = current->pid;
 		spin_lock(&ras->ras_lock);
 		ras->ras_next_readahead_idx = end_idx + 1;
 		ras->ras_async_last_readpage_idx = start_idx;
diff --git a/include/uapi/linux/lnet/libcfs_debug.h b/include/uapi/linux/lnet/libcfs_debug.h
index 4cb6594..bbd9f25 100644
--- a/include/uapi/linux/lnet/libcfs_debug.h
+++ b/include/uapi/linux/lnet/libcfs_debug.h
@@ -106,6 +106,7 @@ struct ptldebug_header {
 #define D_TRACE		0x00000001 /* ENTRY/EXIT markers */
 #define D_INODE		0x00000002
 #define D_SUPER		0x00000004
+#define D_IOTRACE	0x00000008 /* simple, low overhead io tracing */
 #define D_MALLOC	0x00000010 /* print malloc, free information */
 #define D_CACHE		0x00000020 /* cache-related items */
 #define D_INFO		0x00000040 /* general information */
@@ -136,7 +137,7 @@ struct ptldebug_header {
 #define D_LAYOUT	0x80000000
 
 #define LIBCFS_DEBUG_MASKS_NAMES {					\
-	"trace", "inode", "super", "tty", "malloc", "cache", "info",	\
+	"trace", "inode", "super", "iotrace", "malloc", "cache", "info",\
 	"ioctl", "neterror", "net", "warning", "buffs", "other",	\
 	"dentry", "nettrace", "page", "dlmtrace", "error", "emerg",	\
 	"ha", "rpctrace", "vfstrace", "reada", "mmap", "config",	\
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
