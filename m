From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:11 -0500
Subject: [lustre-devel] [PATCH 263/622] lnet: properly cleanup lnet debugfs
 files
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-264-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The function lnet_router_debugfs_remove() is suppose to cleanup
the lnet specific debugfs files but that is not happening at all.
Change lnet_remove_debugfs() from doing the final debugfs lnet
and libcfs cleanup to doing specific debugfs file removal. We
can make libcfs module unloading to directly finish the entire
libcfs and debugfs tree removal instead. With this change we can
make lnet_router_debugfs_fini() call lnet_remove_debugfs().

WC-bug-id: https://jira.whamcloud.com/browse/LU-11986
Lustre-commit: 8cb7ccf54e2d ("LU-11986 lnet: properly cleanup lnet debugfs files")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/34669
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/libcfs/libcfs.h |  1 +
 net/lnet/libcfs/module.c      | 16 ++++++++++++----
 net/lnet/lnet/router_proc.c   |  1 +
 3 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/include/linux/libcfs/libcfs.h b/include/linux/libcfs/libcfs.h
index 33f7477..d3a9754 100644
--- a/include/linux/libcfs/libcfs.h
+++ b/include/linux/libcfs/libcfs.h
@@ -57,6 +57,7 @@ static inline int notifier_from_ioctl_errno(int err)
 extern struct workqueue_struct *cfs_rehash_wq;
 
 void lnet_insert_debugfs(struct ctl_table *table);
+void lnet_remove_debugfs(struct ctl_table *table);
 
 /*
  * Memory
diff --git a/net/lnet/libcfs/module.c b/net/lnet/libcfs/module.c
index 37a3fee..2e803d6 100644
--- a/net/lnet/libcfs/module.c
+++ b/net/lnet/libcfs/module.c
@@ -691,12 +691,18 @@ static void lnet_insert_debugfs_links(
 				       symlinks->target);
 }
 
-static void lnet_remove_debugfs(void)
+void lnet_remove_debugfs(struct ctl_table *table)
 {
-	debugfs_remove_recursive(lnet_debugfs_root);
+	for (; table && table->procname; table++) {
+		struct qstr dname = QSTR_INIT(table->procname,
+					      strlen(table->procname));
+		struct dentry *dentry;
 
-	lnet_debugfs_root = NULL;
+		dentry = d_hash_and_lookup(lnet_debugfs_root, &dname);
+		debugfs_remove(dentry);
+	}
 }
+EXPORT_SYMBOL_GPL(lnet_remove_debugfs);
 
 static DEFINE_MUTEX(libcfs_startup);
 static int libcfs_active;
@@ -771,7 +777,9 @@ static void libcfs_exit(void)
 {
 	int rc;
 
-	lnet_remove_debugfs();
+	/* Remove everthing */
+	debugfs_remove_recursive(lnet_debugfs_root);
+	lnet_debugfs_root = NULL;
 
 	if (cfs_rehash_wq)
 		destroy_workqueue(cfs_rehash_wq);
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 45abcfb..8517411 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -936,4 +936,5 @@ void lnet_router_debugfs_init(void)
 
 void lnet_router_debugfs_fini(void)
 {
+	lnet_remove_debugfs(lnet_table);
 }
-- 
1.8.3.1
