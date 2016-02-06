From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Sat,  6 Feb 2016 02:01:50 -0500
Subject: [lustre-devel] [PATCH 1/2] staging/lustre/libcfs: Properly handle
	debugfs read- and write-only files
In-Reply-To: <1454742111-2231460-1-git-send-email-green@linuxhacker.ru>
References: <1454742111-2231460-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1454742111-2231460-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

It turns out that unlike procfs, debugfs does not really enforce
permissions for root (similar to regular filesystems), so we need
to ensure we are not providing ->write() method to read-only files
and ->read() method for write-only files at registration.

This fixes a couple of crashes on unexpected access.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/module.c | 27 +++++++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index d5a047b..611607a 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -502,13 +502,36 @@ static ssize_t lnet_debugfs_write(struct file *filp, const char __user *buf,
 	return error;
 }
 
-static const struct file_operations lnet_debugfs_file_operations = {
+static const struct file_operations lnet_debugfs_file_operations_rw = {
 	.open		= simple_open,
 	.read		= lnet_debugfs_read,
 	.write		= lnet_debugfs_write,
 	.llseek		= default_llseek,
 };
 
+static const struct file_operations lnet_debugfs_file_operations_ro = {
+	.open		= simple_open,
+	.read		= lnet_debugfs_read,
+	.llseek		= default_llseek,
+};
+
+static const struct file_operations lnet_debugfs_file_operations_wo = {
+	.open		= simple_open,
+	.write		= lnet_debugfs_write,
+	.llseek		= default_llseek,
+};
+
+static const struct file_operations *lnet_debugfs_fops_select(umode_t mode)
+{
+	if (!(mode & S_IWUGO))
+		return &lnet_debugfs_file_operations_ro;
+
+	if (!(mode & S_IRUGO))
+		return &lnet_debugfs_file_operations_wo;
+
+	return &lnet_debugfs_file_operations_rw;
+}
+
 void lustre_insert_debugfs(struct ctl_table *table,
 			   const struct lnet_debugfs_symlink_def *symlinks)
 {
@@ -525,7 +548,7 @@ void lustre_insert_debugfs(struct ctl_table *table,
 	for (; table->procname; table++)
 		debugfs_create_file(table->procname, table->mode,
 				    lnet_debugfs_root, table,
-				    &lnet_debugfs_file_operations);
+				    lnet_debugfs_fops_select(table->mode));
 
 	for (; symlinks && symlinks->name; symlinks++)
 		debugfs_create_symlink(symlinks->name, lnet_debugfs_root,
-- 
2.1.0
