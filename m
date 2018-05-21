From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:12 +1000
Subject: [lustre-devel] [PATCH 15/30] staging: lustre: make
 lnet_debugfs_symlink_def local to libcfs/modules.c
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731289.24196.12947865370399815083.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

This type is only used in libcfs/module.c, so make it local to there.
If any other module ever wanted to add its own symlinks,
it would probably be easiest to export lnet_debugfs_root
and just call debugfs_create_symlink as required.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    8 +------
 drivers/staging/lustre/lnet/libcfs/module.c        |   23 +++++++++++++++-----
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    2 +-
 3 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index ab77cf83af0f..947fba9445dc 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -110,13 +110,7 @@ extern char lnet_debug_log_upcall[1024];
 
 extern struct workqueue_struct *cfs_rehash_wq;
 
-struct lnet_debugfs_symlink_def {
-	char *name;
-	char *target;
-};
-
-void lustre_insert_debugfs(struct ctl_table *table,
-			   const struct lnet_debugfs_symlink_def *symlinks);
+void lustre_insert_debugfs(struct ctl_table *table);
 int lprocfs_call_handler(void *data, int write, loff_t *ppos,
 			 void __user *buffer, size_t *lenp,
 			 int (*handler)(void *data, int write, loff_t pos,
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index b3a7c1a912ba..3e535d82df27 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -60,6 +60,11 @@
 #include <uapi/linux/lnet/lnet-dlc.h>
 #include "tracefile.h"
 
+struct lnet_debugfs_symlink_def {
+	char *name;
+	char *target;
+};
+
 static struct dentry *lnet_debugfs_root;
 
 BLOCKING_NOTIFIER_HEAD(libcfs_ioctl_list);
@@ -620,8 +625,7 @@ static const struct file_operations *lnet_debugfs_fops_select(umode_t mode)
 	return &lnet_debugfs_file_operations_rw;
 }
 
-void lustre_insert_debugfs(struct ctl_table *table,
-			   const struct lnet_debugfs_symlink_def *symlinks)
+void lustre_insert_debugfs(struct ctl_table *table)
 {
 	if (!lnet_debugfs_root)
 		lnet_debugfs_root = debugfs_create_dir("lnet", NULL);
@@ -630,19 +634,24 @@ void lustre_insert_debugfs(struct ctl_table *table,
 	if (IS_ERR_OR_NULL(lnet_debugfs_root))
 		return;
 
-	/* We don't save the dentry returned in next two calls, because
-	 * we don't call debugfs_remove() but rather remove_recursive()
+	/*
+	 * We don't save the dentry returned because we don't call
+	 * debugfs_remove() but rather remove_recursive()
 	 */
 	for (; table->procname; table++)
 		debugfs_create_file(table->procname, table->mode,
 				    lnet_debugfs_root, table,
 				    lnet_debugfs_fops_select(table->mode));
+}
+EXPORT_SYMBOL_GPL(lustre_insert_debugfs);
 
+static void lustre_insert_debugfs_links(
+	const struct lnet_debugfs_symlink_def *symlinks)
+{
 	for (; symlinks && symlinks->name; symlinks++)
 		debugfs_create_symlink(symlinks->name, lnet_debugfs_root,
 				       symlinks->target);
 }
-EXPORT_SYMBOL_GPL(lustre_insert_debugfs);
 
 static void lustre_remove_debugfs(void)
 {
@@ -688,7 +697,9 @@ int libcfs_setup(void)
 		goto err;
 	}
 
-	lustre_insert_debugfs(lnet_table, lnet_debugfs_symlinks);
+	lustre_insert_debugfs(lnet_table);
+	if (!IS_ERR_OR_NULL(lnet_debugfs_root))
+		lustre_insert_debugfs_links(lnet_debugfs_symlinks);
 
 	CDEBUG(D_OTHER, "portals setup OK\n");
 out:
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 015dccbc4a58..36ae5b016985 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -900,7 +900,7 @@ static struct ctl_table lnet_table[] = {
 
 void lnet_router_debugfs_init(void)
 {
-	lustre_insert_debugfs(lnet_table, NULL);
+	lustre_insert_debugfs(lnet_table);
 }
 
 void lnet_router_debugfs_fini(void)
