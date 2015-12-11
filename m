From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Date: Fri, 11 Dec 2015 18:04:23 -0500
Subject: [lustre-devel] [PATCH v2 4/6] Fix another C compiler whine: set but
	not used
In-Reply-To: <1449875065-35182-1-git-send-email-Valdis.Kletnieks@vt.edu>
References: <1449875065-35182-1-git-send-email-Valdis.Kletnieks@vt.edu>
Message-ID: <1449875065-35182-5-git-send-email-Valdis.Kletnieks@vt.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

  CC [M]  drivers/staging/lustre/lustre/libcfs/module.o
drivers/staging/lustre/lustre/libcfs/module.c: In function 'lustre_insert_debugfs':
drivers/staging/lustre/lustre/libcfs/module.c:670:17: warning: variable 'entry' set but not used [-Wunused-but-set-variable]
  struct dentry *entry;
                     ^

Just ignore the dentry returned, and add a comment that we *know*
we're not really leaking the dentry because something else will be able
to reap it via recursion.

Signed-off-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
---
 drivers/staging/lustre/lustre/libcfs/module.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 96d9d4651a51..4438dc426b54 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -667,8 +667,6 @@ static const struct file_operations lnet_debugfs_file_operations = {
 void lustre_insert_debugfs(struct ctl_table *table,
 			   const struct lnet_debugfs_symlink_def *symlinks)
 {
-	struct dentry *entry;
-
 	if (lnet_debugfs_root == NULL)
 		lnet_debugfs_root = debugfs_create_dir("lnet", NULL);
 
@@ -676,15 +674,17 @@ void lustre_insert_debugfs(struct ctl_table *table,
 	if (IS_ERR_OR_NULL(lnet_debugfs_root))
 		return;
 
+	/* We don't save the dentry returned in next two calls, because
+	 * we don't call debugfs_remove() but rather remove_recursive()
+	 */
 	for (; table->procname; table++)
-		entry = debugfs_create_file(table->procname, table->mode,
-					    lnet_debugfs_root, table,
-					    &lnet_debugfs_file_operations);
+		debugfs_create_file(table->procname, table->mode,
+				    lnet_debugfs_root, table,
+				    &lnet_debugfs_file_operations);
 
 	for (; symlinks && symlinks->name; symlinks++)
-		entry = debugfs_create_symlink(symlinks->name,
-					       lnet_debugfs_root,
-					       symlinks->target);
+		debugfs_create_symlink(symlinks->name, lnet_debugfs_root,
+				       symlinks->target);
 
 }
 EXPORT_SYMBOL_GPL(lustre_insert_debugfs);
-- 
2.6.3
