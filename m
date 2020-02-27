From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:05 -0500
Subject: [lustre-devel] [PATCH 437/622] lustre: llite: Fix extents_stats
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-438-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

Patch 32517 from LU-8066 that landed in OpenSFS branch changed:
        (1 << LL_HIST_START << i)

to

        BIT(LL_HIST_START << i)

But these are not equivalent because this changes the order
of operations.  The earlier one does the operations in this
order:
        (1 << LL_HIST_START) << i

The new one is this order:
        1 << (LL_HIST_START << i)

Which is quite different, as it's left shifting
LL_HIST_START directly, and LL_HIST_START is a number of
bits.

The goal is really just to start with BIT(LL_HIST_START)
and left shift by one (going from 4K, to 8K, etc) each
time, so just use:
        BIT(LL_HIST_START + i)

The result of this was that all i/os over 8K were placed in
the 4K-8K stat bucket, because the loop exited early.

Also add mmap'ed reads & writes to extents_stats.

Add test for extents_stats.

This was only broken in the OpenSFS branch but we want the
improvements.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12394
Lustre-commit: d31a4dad4e69 ("LU-12394 llite: Fix extents_stats")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35075
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c        | 23 +++++++++++++++++------
 fs/lustre/llite/llite_mmap.c  | 11 +++++++++++
 fs/lustre/llite/lproc_llite.c |  6 +++---
 fs/lustre/llite/vvp_io.c      |  4 ----
 4 files changed, 31 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 35e31ad..fa61b09 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1670,6 +1670,7 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 {
 	struct lu_env *env;
 	struct vvp_io_args *args;
+	struct file *file = iocb->ki_filp;
 	ssize_t result;
 	u16 refcheck;
 	ssize_t rc2;
@@ -1693,7 +1694,7 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	if (cached)
 		return result;
 
-	ll_ras_enter(iocb->ki_filp);
+	ll_ras_enter(file);
 
 	result = ll_do_fast_read(iocb, to);
 	if (result < 0 || iov_iter_count(to) == 0)
@@ -1707,7 +1708,7 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	args->u.normal.via_iter = to;
 	args->u.normal.via_iocb = iocb;
 
-	rc2 = ll_file_io_generic(env, args, iocb->ki_filp, CIT_READ,
+	rc2 = ll_file_io_generic(env, args, file, CIT_READ,
 				 &iocb->ki_pos, iov_iter_count(to));
 	if (rc2 > 0)
 		result += rc2;
@@ -1716,6 +1717,11 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 
 	cl_env_put(env, &refcheck);
 out:
+	if (result > 0)
+		ll_rw_stats_tally(ll_i2sbi(file_inode(file)), current->pid,
+				  LUSTRE_FPRIVATE(file), iocb->ki_pos, result,
+				  READ);
+
 	return result;
 }
 
@@ -1784,6 +1790,7 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	struct lu_env *env;
 	struct vvp_io_args *args;
 	ssize_t rc_tiny = 0, rc_normal;
+	struct file *file = iocb->ki_filp;
 	u16 refcheck;
 	bool cached;
 	int result;
@@ -1812,8 +1819,8 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	 * pages, and we can't do append writes because we can't guarantee the
 	 * required DLM locks are held to protect file size.
 	 */
-	if (ll_sbi_has_tiny_write(ll_i2sbi(file_inode(iocb->ki_filp))) &&
-	    !(iocb->ki_filp->f_flags & (O_DIRECT | O_SYNC | O_APPEND)))
+	if (ll_sbi_has_tiny_write(ll_i2sbi(file_inode(file))) &&
+	    !(file->f_flags & (O_DIRECT | O_SYNC | O_APPEND)))
 		rc_tiny = ll_do_tiny_write(iocb, from);
 
 	/* In case of error, go on and try normal write - Only stop if tiny
@@ -1832,8 +1839,8 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	args->u.normal.via_iter = from;
 	args->u.normal.via_iocb = iocb;
 
-	rc_normal = ll_file_io_generic(env, args, iocb->ki_filp, CIT_WRITE,
-				    &iocb->ki_pos, iov_iter_count(from));
+	rc_normal = ll_file_io_generic(env, args, file, CIT_WRITE,
+				       &iocb->ki_pos, iov_iter_count(from));
 
 	/* On success, combine bytes written. */
 	if (rc_tiny >= 0 && rc_normal > 0)
@@ -1846,6 +1853,10 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 
 	cl_env_put(env, &refcheck);
 out:
+	if (rc_normal > 0)
+		ll_rw_stats_tally(ll_i2sbi(file_inode(file)), current->pid,
+				  LUSTRE_FPRIVATE(file), iocb->ki_pos,
+				  rc_normal, WRITE);
 	return rc_normal;
 }
 
diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index 71799cd..5c13164 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -406,6 +406,12 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
 		result = VM_FAULT_LOCKED;
 	}
 	sigprocmask(SIG_SETMASK, &old, NULL);
+
+	if (vmf->page && result == VM_FAULT_LOCKED)
+		ll_rw_stats_tally(ll_i2sbi(file_inode(vma->vm_file)),
+				  current->pid, LUSTRE_FPRIVATE(vma->vm_file),
+				  cl_offset(NULL, vmf->page->index), PAGE_SIZE,
+				  READ);
 	return result;
 }
 
@@ -459,6 +465,11 @@ static vm_fault_t ll_page_mkwrite(struct vm_fault *vmf)
 		break;
 	}
 
+	if (ret == VM_FAULT_LOCKED)
+		ll_rw_stats_tally(ll_i2sbi(file_inode(vma->vm_file)),
+				  current->pid, LUSTRE_FPRIVATE(vma->vm_file),
+				  cl_offset(NULL, vmf->page->index), PAGE_SIZE,
+				  WRITE);
 	return ret;
 }
 
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 6eb3d33..c2ec3fb 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1937,7 +1937,7 @@ void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 		lprocfs_oh_clear(&io_extents->pp_extents[cur].pp_w_hist);
 	}
 
-	for (i = 0; (count >= (1 << LL_HIST_START << i)) &&
+	for (i = 0; (count >= BIT(LL_HIST_START + i)) &&
 	     (i < (LL_HIST_MAX - 1)); i++)
 		;
 	if (rw == 0) {
@@ -2032,7 +2032,7 @@ static int ll_rw_offset_stats_seq_show(struct seq_file *seq, void *v)
 	for (i = 0; i < LL_OFFSET_HIST_MAX; i++) {
 		if (offset[i].rw_pid != 0)
 			seq_printf(seq,
-				   "%3c %10d %14llu %14llu %17lu %17lu %14llu\n",
+				   "%3c %10d %14llu %14llu %17lu %17lu %14lld\n",
 				   offset[i].rw_op == READ ? 'R' : 'W',
 				   offset[i].rw_pid,
 				   offset[i].rw_range_start,
@@ -2045,7 +2045,7 @@ static int ll_rw_offset_stats_seq_show(struct seq_file *seq, void *v)
 	for (i = 0; i < LL_PROCESS_HIST_MAX; i++) {
 		if (process[i].rw_pid != 0)
 			seq_printf(seq,
-				   "%3c %10d %14llu %14llu %17lu %17lu %14llu\n",
+				   "%3c %10d %14llu %14llu %17lu %17lu %14lld\n",
 				   process[i].rw_op == READ ? 'R' : 'W',
 				   process[i].rw_pid,
 				   process[i].rw_range_start,
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 68455d5..847fb5e 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -791,8 +791,6 @@ static int vvp_io_read_start(const struct lu_env *env,
 		if (result < cnt)
 			io->ci_continue = 0;
 		io->ci_nob += result;
-		ll_rw_stats_tally(ll_i2sbi(inode), current->pid,
-				  vio->vui_fd, pos, result, READ);
 		result = 0;
 	}
 	return result;
@@ -1069,8 +1067,6 @@ static int vvp_io_write_start(const struct lu_env *env,
 
 		if (result < cnt)
 			io->ci_continue = 0;
-		ll_rw_stats_tally(ll_i2sbi(inode), current->pid,
-				  vio->vui_fd, pos, result, WRITE);
 		result = 0;
 	}
 	return result;
-- 
1.8.3.1
