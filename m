From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:05 -0500
Subject: [lustre-devel] [PATCH 377/622] lustre: llite: console message for
 disabled flock call
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-378-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Xi <lixi@ddn.com>

When flock option is disabled on a Lustre client, any call to
flock() or lockf() would cause a return value with failure.
For applications that don't print proper error message, it is
hard to know the root cause is the missing flock option on Lustre
file system. Thus this patch prints following error message to
the tty that calls flock()/lockf():

"Lustre: flock disabled, mount with '-o [local]flock' to enable"

Such message will print to each file descriptor no more than
once to avoid message flood.

In order to do so, this patch adds support for CDEBUG_LIMIT(D_TTY).
It prints the message to tty. When using this macro, please
note that "\r\n" needs to be the end of the line. Otherwise,
message like "format at $FILE:$LINO:$FUNC doesn't end in '\r\n'"
will be printed to the system message for warning.

Note that LL_FILE_RMTACL should have been removed by
Commit 341f1f0affed ("staging: lustre: remove remote client support")

WC-bug-id: https://jira.whamcloud.com/browse/LU-12349
Lustre-commit: f6497eb3503b ("LU-12349 llite: console message for disabled flock call")
Signed-off-by: Li Xi <lixi@ddn.com>
Reviewed-on: https://review.whamcloud.com/34986
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c                  | 12 ++++++++++++
 include/uapi/linux/lnet/libcfs_debug.h  |  4 ++--
 include/uapi/linux/lustre/lustre_user.h |  2 +-
 3 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 1ed4b14..76a5074 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4275,6 +4275,18 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 static int
 ll_file_noflock(struct file *file, int cmd, struct file_lock *file_lock)
 {
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+
+	/*
+	 * In order to avoid flood of warning messages, only print one message
+	 * for one file. And the entire message rate on the client is limited
+	 * by CDEBUG_LIMIT too.
+	 */
+	if (!(fd->fd_flags & LL_FILE_FLOCK_WARNING)) {
+		fd->fd_flags |= LL_FILE_FLOCK_WARNING;
+		CDEBUG_LIMIT(D_TTY | D_CONSOLE,
+			     "flock disabled, mount with '-o [local]flock' to enable\r\n");
+	}
 	return -EINVAL;
 }
 
diff --git a/include/uapi/linux/lnet/libcfs_debug.h b/include/uapi/linux/lnet/libcfs_debug.h
index 1a68667..6255331 100644
--- a/include/uapi/linux/lnet/libcfs_debug.h
+++ b/include/uapi/linux/lnet/libcfs_debug.h
@@ -106,7 +106,7 @@ struct ptldebug_header {
 #define D_TRACE		0x00000001 /* ENTRY/EXIT markers */
 #define D_INODE		0x00000002
 #define D_SUPER		0x00000004
-#define D_EXT2		0x00000008 /* anything from ext2_debug */
+#define D_TTY		0x00000008 /* notification printed to TTY */
 #define D_MALLOC	0x00000010 /* print malloc, free information */
 #define D_CACHE		0x00000020 /* cache-related items */
 #define D_INFO		0x00000040 /* general information */
@@ -137,7 +137,7 @@ struct ptldebug_header {
 #define D_LAYOUT	0x80000000
 
 #define LIBCFS_DEBUG_MASKS_NAMES {					\
-	"trace", "inode", "super", "ext2", "malloc", "cache", "info",	\
+	"trace", "inode", "super", "tty", "malloc", "cache", "info",	\
 	"ioctl", "neterror", "net", "warning", "buffs", "other",	\
 	"dentry", "nettrace", "page", "dlmtrace", "error", "emerg",	\
 	"ha", "rpctrace", "vfstrace", "reada", "mmap", "config",	\
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 317b236..d43170f 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -385,7 +385,7 @@ struct ll_ioc_lease_id {
 #define LL_FILE_READAHEA	0x00000004
 #define LL_FILE_LOCKED_DIRECTIO 0x00000008 /* client-side locks with dio */
 #define LL_FILE_LOCKLESS_IO	0x00000010 /* server-side locks with cio */
-#define LL_FILE_RMTACL		0x00000020
+#define LL_FILE_FLOCK_WARNING	0x00000020 /* warned about disabled flock */
 
 #define LOV_USER_MAGIC_V1	0x0BD10BD0
 #define LOV_USER_MAGIC		LOV_USER_MAGIC_V1
-- 
1.8.3.1
