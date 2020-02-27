From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:46 -0500
Subject: [lustre-devel] [PATCH 538/622] lustre: llite: file write pos mimatch
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-539-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@whamcloud.com>

In vvp_io_write_start(), after data were successfully written, but
for some reason (e.g. out of quota), the data does not or got
partially commited, so that the file's write position (kiocb->ki_pos)
would be pushed forward falsely, and in the next iteration of write
loop, it fails the assertion

ASSERTION( io->u.ci_rw.rw_iocb.ki_pos == range->cir_pos )

This patch corrects ki_pos if this scenario happens.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12503
Lustre-commit: 1d2aa1513dc4 ("LU-12503 llite: file write pos mimatch")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36021
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/vvp_io.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index aa8f2e1..b3f628c 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -1068,9 +1068,12 @@ static int vvp_io_write_start(const struct lu_env *env,
 	struct cl_object *obj = io->ci_obj;
 	struct inode *inode = vvp_object_inode(obj);
 	struct ll_inode_info *lli = ll_i2info(inode);
+	struct file *file = vio->vui_fd->fd_file;
 	bool lock_inode = !inode_is_locked(inode) && !IS_NOSEC(inode);
 	loff_t pos = io->u.ci_wr.wr.crw_pos;
 	size_t cnt = io->u.ci_wr.wr.crw_count;
+	size_t nob = io->ci_nob;
+	size_t written = 0;
 	ssize_t result = 0;
 
 	down_read(&lli->lli_trunc_sem);
@@ -1135,6 +1138,7 @@ static int vvp_io_write_start(const struct lu_env *env,
 		if (unlikely(lock_inode))
 			inode_unlock(inode);
 
+		written = result;
 		if (result > 0 || result == -EIOCBQUEUED)
 			result = generic_write_sync(vio->vui_iocb, result);
 	}
@@ -1149,6 +1153,15 @@ static int vvp_io_write_start(const struct lu_env *env,
 			       io->ci_nob, result);
 		}
 	}
+	if (vio->vui_iocb->ki_pos != (pos + io->ci_nob - nob)) {
+		CDEBUG(D_VFSTRACE,
+		       "%s: write position mismatch: ki_pos %lld vs. pos %lld, written %ld, commit %ld rc %ld\n",
+		       file_dentry(file)->d_name.name,
+		       vio->vui_iocb->ki_pos, pos + io->ci_nob - nob,
+		       written, io->ci_nob - nob, result);
+		/* rewind ki_pos to where it has successfully committed */
+		vio->vui_iocb->ki_pos = pos + io->ci_nob - nob;
+	}
 	if (result > 0) {
 		set_bit(LLIF_DATA_MODIFIED, &(ll_i2info(inode))->lli_flags);
 
-- 
1.8.3.1
