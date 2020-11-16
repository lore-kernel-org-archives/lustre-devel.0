From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:34 -0500
Subject: [lustre-devel] [PATCH 01/28] llite: remove splice_read handling for
 PCC
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

For older kernels with PCC we handled splice_read ourself but
this is no longer needed since generic_file_splice_read() is just
a wrapper around the read_iter() operation. We can safely remove
pcc_file_splice_read(). Use the read_iter() / write_iter()
functions for pccf_file instead of the default file of the passed
in kiocb.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13745
Lustre-commit: 1635dc9de0bc1d ("LU-13745 llite: switch generic_file_splice_read() to use of ->read_iter()")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/39272
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/llite/pcc.c | 33 ++-------------------------------
 fs/lustre/llite/pcc.h |  5 -----
 2 files changed, 2 insertions(+), 36 deletions(-)

diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index 5a4bb33..28ca9cb 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -1592,7 +1592,7 @@ ssize_t pcc_file_read_iter(struct kiocb *iocb,
 	 * filp->f_ops->read_iter uses ->aio_read hook directly
 	 * to add support for ext4-dax.
 	 */
-	result = file->f_op->read_iter(iocb, iter);
+	result = iocb->ki_filp->f_op->read_iter(iocb, iter);
 	iocb->ki_filp = file;
 
 	pcc_io_fini(inode);
@@ -1633,7 +1633,7 @@ ssize_t pcc_file_write_iter(struct kiocb *iocb,
 	 * the normal vfs interface to the local PCC file system,
 	 * the inode lock is not needed.
 	 */
-	result = file->f_op->write_iter(iocb, iter);
+	result = iocb->ki_filp->f_op->write_iter(iocb, iter);
 	iocb->ki_filp = file;
 out:
 	pcc_io_fini(inode);
@@ -1734,35 +1734,6 @@ int pcc_inode_getattr(struct inode *inode, u32 request_mask,
 	return rc;
 }
 
-ssize_t pcc_file_splice_read(struct file *in_file, loff_t *ppos,
-			     struct pipe_inode_info *pipe,
-			     size_t count, unsigned int flags,
-			     bool *cached)
-{
-	struct inode *inode = file_inode(in_file);
-	struct ll_file_data *fd = in_file->private_data;
-	struct file *pcc_file = fd->fd_pcc_file.pccf_file;
-	ssize_t result;
-
-	*cached = false;
-	if (!pcc_file)
-		return 0;
-
-	if (!file_inode(pcc_file)->i_fop->splice_read)
-		return -ENOTSUPP;
-
-	pcc_io_init(inode, PIT_SPLICE_READ, cached);
-	if (!*cached)
-		return 0;
-
-	result = file_inode(pcc_file)->i_fop->splice_read(pcc_file,
-							  ppos, pipe, count,
-							  flags);
-
-	pcc_io_fini(inode);
-	return result;
-}
-
 int pcc_fsync(struct file *file, loff_t start, loff_t end,
 	      int datasync, bool *cached)
 {
diff --git a/fs/lustre/llite/pcc.h b/fs/lustre/llite/pcc.h
index b13f9da8..d3aae9b 100644
--- a/fs/lustre/llite/pcc.h
+++ b/fs/lustre/llite/pcc.h
@@ -184,8 +184,6 @@ enum pcc_io_type {
 	PIT_FAULT,
 	/* fsync system call handling */
 	PIT_FSYNC,
-	/* splice_read system call */
-	PIT_SPLICE_READ,
 	/* open system call */
 	PIT_OPEN,
 };
@@ -241,9 +239,6 @@ ssize_t pcc_file_write_iter(struct kiocb *iocb, struct iov_iter *iter,
 int pcc_inode_getattr(struct inode *inode, u32 request_mask,
 		      unsigned int flags, bool *cached);
 int pcc_inode_setattr(struct inode *inode, struct iattr *attr, bool *cached);
-ssize_t pcc_file_splice_read(struct file *in_file, loff_t *ppos,
-			     struct pipe_inode_info *pipe, size_t count,
-			     unsigned int flags, bool *cached);
 int pcc_fsync(struct file *file, loff_t start, loff_t end,
 	      int datasync, bool *cached);
 int pcc_file_mmap(struct file *file, struct vm_area_struct *vma, bool *cached);
-- 
1.8.3.1
