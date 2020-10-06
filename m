From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:56 -0400
Subject: [lustre-devel] [PATCH 17/42] lustre: llite: move iov iter forward
 by ourself
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Newer kernel will reward iov iter back to original
position for direct IO, see following codes:

	iov_iter_revert(from, write_len -
       			iov_iter_count(from));--------->here
out:
	return written;
}
EXPORT_SYMBOL(generic_file_direct_write);

This break assumptions from Lustre and caused problem
when Lustre need split one IO to several io loop, considering
4M block IO for 1 MiB stripe file, it will submit first 1MiB IO
4 times and caused data corruptions finally.

Since generic kernel varies from different kernel versions,
we'd better fix this problem by move iov iter forward by
Lustre itself.

Added a new test cases aiocp.c is copied from xfstests,
with codes style cleanups to make checkpatch.pl happy.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13846
Lustre-commit: 689714eb511d3 ("LU-13846 llite: move iov iter forward by ourself")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/39565
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/vvp_io.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 59da56d..3a2e1cc 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -518,6 +518,12 @@ static void vvp_io_advance(const struct lu_env *env,
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
+	/*
+	 * Since 3.16(26978b8b4) vfs revert iov iter to
+	 * original position even io succeed, so instead
+	 * of relying on VFS, we move iov iter by ourselves.
+	 */
+	iov_iter_advance(vio->vui_iter, nob);
 	vio->vui_tot_count -= nob;
 	iov_iter_reexpand(vio->vui_iter, vio->vui_tot_count);
 }
@@ -771,11 +777,12 @@ static int vvp_io_read_start(const struct lu_env *env,
 	struct inode *inode = vvp_object_inode(obj);
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct file *file = vio->vui_fd->fd_file;
-	int result;
 	loff_t pos = io->u.ci_rd.rd.crw_pos;
 	size_t cnt = io->u.ci_rd.rd.crw_count;
 	size_t tot = vio->vui_tot_count;
 	int exceed = 0;
+	int result;
+	struct iov_iter iter;
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
@@ -825,7 +832,8 @@ static int vvp_io_read_start(const struct lu_env *env,
 	/* BUG: 5972 */
 	file_accessed(file);
 	LASSERT(vio->vui_iocb->ki_pos == pos);
-	result = generic_file_read_iter(vio->vui_iocb, vio->vui_iter);
+	iter = *vio->vui_iter;
+	result = generic_file_read_iter(vio->vui_iocb, &iter);
 	goto out;
 
 out:
@@ -1184,8 +1192,7 @@ static int vvp_io_write_start(const struct lu_env *env,
 
 		if (unlikely(lock_inode))
 			inode_lock(inode);
-		result = __generic_file_write_iter(vio->vui_iocb,
-						   vio->vui_iter);
+		result = __generic_file_write_iter(vio->vui_iocb, &iter);
 		if (unlikely(lock_inode))
 			inode_unlock(inode);
 
@@ -1223,11 +1230,6 @@ static int vvp_io_write_start(const struct lu_env *env,
 		 * successfully committed.
 		 */
 		vio->vui_iocb->ki_pos = pos + io->ci_nob - nob;
-		iov_iter_advance(&iter, io->ci_nob - nob);
-		vio->vui_iter->iov = iter.iov;
-		vio->vui_iter->nr_segs = iter.nr_segs;
-		vio->vui_iter->iov_offset = iter.iov_offset;
-		vio->vui_iter->count = iter.count;
 	}
 	if (result > 0 || result == -EIOCBQUEUED) {
 		set_bit(LLIF_DATA_MODIFIED, &(ll_i2info(inode))->lli_flags);
-- 
1.8.3.1
