From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:45 -0400
Subject: [lustre-devel] [PATCH 01/10] lustre: libcfs: rename
 lustre_*_debugfs to lnet_*_debugfs
In-Reply-To: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
References: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573894-20592-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Both lustre_insert_debugfs() and lustre_remove_debugfs() are only
used by the LNet layer so replace lustre_* with lnet_* to make
the code more consistent.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24688
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/libcfs/libcfs.h |  2 +-
 drivers/staging/lustre/lnet/libcfs/module.c          | 14 +++++++-------
 drivers/staging/lustre/lnet/lnet/router_proc.c       |  2 +-
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 7ac6093..19b2141 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -56,7 +56,7 @@ static inline int notifier_from_ioctl_errno(int err)
 
 extern struct workqueue_struct *cfs_rehash_wq;
 
-void lustre_insert_debugfs(struct ctl_table *table);
+void lnet_insert_debugfs(struct ctl_table *table);
 
 /*
  * Memory
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 35c3959..522650b 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -646,7 +646,7 @@ static const struct file_operations *lnet_debugfs_fops_select(umode_t mode)
 	return &lnet_debugfs_file_operations_rw;
 }
 
-void lustre_insert_debugfs(struct ctl_table *table)
+void lnet_insert_debugfs(struct ctl_table *table)
 {
 	if (!lnet_debugfs_root)
 		lnet_debugfs_root = debugfs_create_dir("lnet", NULL);
@@ -664,9 +664,9 @@ void lustre_insert_debugfs(struct ctl_table *table)
 				    lnet_debugfs_root, table,
 				    lnet_debugfs_fops_select(table->mode));
 }
-EXPORT_SYMBOL_GPL(lustre_insert_debugfs);
+EXPORT_SYMBOL_GPL(lnet_insert_debugfs);
 
-static void lustre_insert_debugfs_links(
+static void lnet_insert_debugfs_links(
 	const struct lnet_debugfs_symlink_def *symlinks)
 {
 	for (; symlinks && symlinks->name; symlinks++)
@@ -674,7 +674,7 @@ static void lustre_insert_debugfs_links(
 				       symlinks->target);
 }
 
-static void lustre_remove_debugfs(void)
+static void lnet_remove_debugfs(void)
 {
 	debugfs_remove_recursive(lnet_debugfs_root);
 
@@ -718,9 +718,9 @@ int libcfs_setup(void)
 		goto err;
 	}
 
-	lustre_insert_debugfs(lnet_table);
+	lnet_insert_debugfs(lnet_table);
 	if (!IS_ERR_OR_NULL(lnet_debugfs_root))
-		lustre_insert_debugfs_links(lnet_debugfs_symlinks);
+		lnet_insert_debugfs_links(lnet_debugfs_symlinks);
 
 	CDEBUG(D_OTHER, "portals setup OK\n");
 out:
@@ -754,7 +754,7 @@ static void libcfs_exit(void)
 {
 	int rc;
 
-	lustre_remove_debugfs();
+	lnet_remove_debugfs();
 
 	if (cfs_rehash_wq)
 		destroy_workqueue(cfs_rehash_wq);
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 53aa0e7..d779445 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -881,7 +881,7 @@ static int proc_lnet_portal_rotor(struct ctl_table *table, int write,
 
 void lnet_router_debugfs_init(void)
 {
-	lustre_insert_debugfs(lnet_table);
+	lnet_insert_debugfs(lnet_table);
 }
 
 void lnet_router_debugfs_fini(void)
-- 
1.8.3.1
