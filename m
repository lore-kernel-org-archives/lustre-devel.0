From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:44 -0400
Subject: [lustre-devel] [PATCH 025/151] lustre: llite: Reduce overhead for
 ll_do_fast_read
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

In ll_do_fast_read, looking up a cl_env adds some overhead,
and can also cause spinlock contention on older kernels.

Fast read can safely use the preallocated percpu cl_env, so
do that to reduce overhead.

SLES numbers on recent Xeon, CentOS numbers on VMs on
older hardware.  SLES has queued spinlocks and scales
perfectly with multiple threads, with or without this
patch.  CentOS scales poorly at small I/O sizes without
this patch.

SLES is SLES12SP2, CentOS is CentOS 7.3.

SLES:
1 thread
         8b   1K   1M
Without: 23   2200 6800
With:    27.5 2500 7200

4 threads
         8b   1K    1M
Without: 90   8700  27000
With:    108  10000 28000

Earlier kernel (CentOS 7.3):
1 thread
         8b  1K   1M
Without: 9   1000 5100
with:    12  1300 5800

4 threads
         8b  1K   1M
Without: 22  2400 17000
With:    48  4900 20000

WC-bug-id: https://jira.whamcloud.com/browse/LU-9749
Lustre-commit: c084c6215851 ("LU-9749 llite: Reduce overhead for ll_do_fast_read")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/27970
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 16 ++++++----------
 fs/lustre/llite/rw.c   | 29 ++++++++++++++++++++---------
 2 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index bc5eebb..53b4620 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1270,15 +1270,13 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
  * doesn't make the situation worse on single node but it may interleave write
  * results from multiple nodes due to short read handling in ll_file_aio_read().
  *
- * @env:	lu_env
  * @iocb:	kiocb from kernel
  * @iter:	user space buffers where the data will be copied
  *
  * Returns:	number of bytes have been read, or error code if error occurred.
  */
 static ssize_t
-ll_do_fast_read(const struct lu_env *env, struct kiocb *iocb,
-		struct iov_iter *iter)
+ll_do_fast_read(struct kiocb *iocb, struct iov_iter *iter)
 {
 	ssize_t result;
 
@@ -1292,9 +1290,7 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 	if (iocb->ki_filp->f_flags & O_DIRECT)
 		return 0;
 
-	ll_cl_add(iocb->ki_filp, env, NULL, LCC_RW);
 	result = generic_file_read_iter(iocb, iter);
-	ll_cl_remove(iocb->ki_filp, env);
 
 	/*
 	 * If the first page is not in cache, generic_file_aio_read() will be
@@ -1319,14 +1315,14 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	u16 refcheck;
 	ssize_t rc2;
 
+	result = ll_do_fast_read(iocb, to);
+	if (result < 0 || iov_iter_count(to) == 0)
+		goto out;
+
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	result = ll_do_fast_read(env, iocb, to);
-	if (result < 0 || iov_iter_count(to) == 0)
-		goto out;
-
 	args = ll_env_args(env);
 	args->u.normal.via_iter = to;
 	args->u.normal.via_iocb = iocb;
@@ -1338,8 +1334,8 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	else if (result == 0)
 		result = rc2;
 
-out:
 	cl_env_put(env, &refcheck);
+out:
 	return result;
 }
 
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index e66aa67..32f028db 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1158,22 +1158,21 @@ int ll_readpage(struct file *file, struct page *vmpage)
 {
 	struct cl_object *clob = ll_i2info(file_inode(file))->lli_clob;
 	struct ll_cl_context *lcc;
-	const struct lu_env  *env;
-	struct cl_io   *io;
+	const struct lu_env *env = NULL;
+	struct cl_io *io = NULL;
 	struct cl_page *page;
 	int result;
 
 	lcc = ll_cl_find(file);
-	if (!lcc) {
-		unlock_page(vmpage);
-		return -EIO;
+	if (lcc) {
+		env = lcc->lcc_env;
+		io = lcc->lcc_io;
 	}
 
-	env = lcc->lcc_env;
-	io = lcc->lcc_io;
 	if (!io) { /* fast read */
 		struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 		struct ll_readahead_state *ras = &fd->fd_ras;
+		struct lu_env *local_env = NULL;
 		struct inode *inode = file_inode(file);
 		struct vvp_page *vpg;
 
@@ -1189,11 +1188,16 @@ int ll_readpage(struct file *file, struct page *vmpage)
 			return result;
 		}
 
+		if (!env) {
+			local_env = cl_env_percpu_get();
+			env = local_env;
+		}
+
 		vpg = cl2vvp_page(cl_object_page_slice(page->cp_obj, page));
 		if (vpg->vpg_defer_uptodate) {
 			enum ras_update_flags flags = LL_RAS_HIT;
 
-			if (lcc->lcc_type == LCC_MMAP)
+			if (lcc && lcc->lcc_type == LCC_MMAP)
 				flags |= LL_RAS_MMAP;
 
 			/*
@@ -1220,8 +1224,15 @@ int ll_readpage(struct file *file, struct page *vmpage)
 			}
 		}
 
-		unlock_page(vmpage);
+		/* release page refcount before unlocking the page to ensure
+		 * the object won't be destroyed in the calling path of
+		 * cl_page_put(). Please see comment in ll_releasepage().
+		 */
 		cl_page_put(env, page);
+		unlock_page(vmpage);
+		if (local_env)
+			cl_env_percpu_put(local_env);
+
 		return result;
 	}
 
-- 
1.8.3.1
