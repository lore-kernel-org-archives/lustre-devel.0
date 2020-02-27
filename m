From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:12 -0500
Subject: [lustre-devel] [PATCH 024/622] lustre: llite: rename FSFILT_IOC_*
 to system flags
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

Those definitions were probably created for compatibility. Now that
FS_IOC_* have been existing in kernel for long time, we should use
them to avoid confusion.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10779
Lustre-commit: 7e3fc106d6e7 ("LU-10779 llite: rename FSFILT_IOC_* to system flags")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/31546
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c       | 13 +++++++------
 fs/lustre/llite/file.c      | 19 ++++++++++---------
 fs/lustre/llite/llite_lib.c |  4 ++--
 3 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index f21727b..b006e32 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1108,18 +1108,19 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_IOCTL, 1);
 	switch (cmd) {
-	case FSFILT_IOC_GETFLAGS:
-	case FSFILT_IOC_SETFLAGS:
+	case FS_IOC_GETFLAGS:
+	case FS_IOC_SETFLAGS:
 		return ll_iocontrol(inode, file, cmd, arg);
-	case FSFILT_IOC_GETVERSION_OLD:
 	case FSFILT_IOC_GETVERSION:
+	case FS_IOC_GETVERSION:
 		return put_user(inode->i_generation, (int __user *)arg);
 	/* We need to special case any other ioctls we want to handle,
 	 * to send them to the MDS/OST as appropriate and to properly
 	 * network encode the arg field.
-	case FSFILT_IOC_SETVERSION_OLD:
-	case FSFILT_IOC_SETVERSION:
-	*/
+	 */
+	case FS_IOC_SETVERSION:
+		return -ENOTSUPP;
+
 	case LL_IOC_GET_MDTIDX: {
 		int mdtidx;
 
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index fe965b1..c3fb104b 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3055,12 +3055,19 @@ static long ll_file_set_lease(struct file *file, struct ll_ioc_lease *ioc,
 	case LL_IOC_LOV_GETSTRIPE:
 	case LL_IOC_LOV_GETSTRIPE_NEW:
 		return ll_file_getstripe(inode, (void __user *)arg, 0);
-	case FSFILT_IOC_GETFLAGS:
-	case FSFILT_IOC_SETFLAGS:
+	case FS_IOC_GETFLAGS:
+	case FS_IOC_SETFLAGS:
 		return ll_iocontrol(inode, file, cmd, arg);
-	case FSFILT_IOC_GETVERSION_OLD:
 	case FSFILT_IOC_GETVERSION:
+	case FS_IOC_GETVERSION:
 		return put_user(inode->i_generation, (int __user *)arg);
+	/* We need to special case any other ioctls we want to handle,
+	 * to send them to the MDS/OST as appropriate and to properly
+	 * network encode the arg field.
+	 */
+	case FS_IOC_SETVERSION:
+		return -ENOTSUPP;
+
 	case LL_IOC_GROUP_LOCK:
 		return ll_get_grouplock(inode, file, arg);
 	case LL_IOC_GROUP_UNLOCK:
@@ -3068,12 +3075,6 @@ static long ll_file_set_lease(struct file *file, struct ll_ioc_lease *ioc,
 	case IOC_OBD_STATFS:
 		return ll_obd_statfs(inode, (void __user *)arg);
 
-	/* We need to special case any other ioctls we want to handle,
-	 * to send them to the MDS/OST as appropriate and to properly
-	 * network encode the arg field.
-	case FSFILT_IOC_SETVERSION_OLD:
-	case FSFILT_IOC_SETVERSION:
-	*/
 	case LL_IOC_FLUSHCTX:
 		return ll_flush_ctx(inode);
 	case LL_IOC_PATH2FID: {
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 7580d57..e2c7a4d 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2037,7 +2037,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 	int rc, flags = 0;
 
 	switch (cmd) {
-	case FSFILT_IOC_GETFLAGS: {
+	case FS_IOC_GETFLAGS: {
 		struct mdt_body *body;
 		struct md_op_data *op_data;
 
@@ -2065,7 +2065,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 
 		return put_user(flags, (int __user *)arg);
 	}
-	case FSFILT_IOC_SETFLAGS: {
+	case FS_IOC_SETFLAGS: {
 		struct md_op_data *op_data;
 		struct cl_object *obj;
 		struct iattr *attr;
-- 
1.8.3.1
