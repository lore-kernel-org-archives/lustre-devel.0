From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:32 -0500
Subject: [lustre-devel] [PATCH 224/622] lustre: llite: Lock inode on tiny
 write if setuid/setgid set
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-225-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Ann Koehler <amk@cray.com>

During a write, the setuid/setgid bits must be reset if they are
enabled and the user does not have the correct permissions. Setting
any file attributes, including setuid and setgid, requires the inode
to be locked. Writes became lockless with the introduction of
LU-1669. Locking the inode in the setuid/setgid case was added to
vvp_io_write_start() as a special case. The inode locking was not
included when support for tiny writes was added with LU-9409. This
mod adds the necessary inode lock/unlock calls to ll_do_tiny_write().

If the inode is not locked when setuid/setgid are reset, the kernel
will issue a one time warning and Lustre may hang trying to get the
inode lock in ll_setattr_raw().

WC-bug-id: https://jira.whamcloud.com/browse/LU-11944
Lustre-commit: f39a552922ca ("LU-11944 llite: Lock inode on tiny write if setuid/setgid set")
Signed-off-by: Ann Koehler <amk@cray.com>
Reviewed-on: https://review.whamcloud.com/34218
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c   | 6 ++++++
 fs/lustre/llite/vvp_io.c | 6 +++---
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 7078734..a73d11f 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1616,6 +1616,7 @@ static ssize_t ll_do_tiny_write(struct kiocb *iocb, struct iov_iter *iter)
 	ssize_t count = iov_iter_count(iter);
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = file_inode(file);
+	bool lock_inode = !IS_NOSEC(inode);
 	ssize_t result = 0;
 
 	/* Restrict writes to single page and < PAGE_SIZE.  See comment@top
@@ -1625,8 +1626,13 @@ static ssize_t ll_do_tiny_write(struct kiocb *iocb, struct iov_iter *iter)
 	    (iocb->ki_pos & (PAGE_SIZE-1)) + count > PAGE_SIZE)
 		return 0;
 
+	if (unlikely(lock_inode))
+		inode_lock(inode);
 	result = __generic_file_write_iter(iocb, iter);
 
+	if (unlikely(lock_inode))
+		inode_unlock(inode);
+
 	/* If the page is not already dirty, ll_tiny_write_begin returns
 	 * -ENODATA.  We continue on to normal write.
 	 */
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 85bb3e0..ad4b39e 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -1037,13 +1037,13 @@ static int vvp_io_write_start(const struct lu_env *env,
 		 * consistency, proper locking to protect against writes,
 		 * trucates, etc. is handled in the higher layers of lustre.
 		 */
-		bool lock_node = !IS_NOSEC(inode);
+		lock_inode = !IS_NOSEC(inode);
 
-		if (lock_node)
+		if (unlikely(lock_inode))
 			inode_lock(inode);
 		result = __generic_file_write_iter(vio->vui_iocb,
 						   vio->vui_iter);
-		if (lock_node)
+		if (unlikely(lock_inode))
 			inode_unlock(inode);
 
 		if (result > 0 || result == -EIOCBQUEUED)
-- 
1.8.3.1
