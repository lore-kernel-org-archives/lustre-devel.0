From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:06 -0400
Subject: [lustre-devel] [PATCH 03/38] lustre: llite: move llite_root and
 llite_kset to lproc_llite.c
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Move llite_root and llite_kset to lproc_llite.c so that all
the sysfs and debugfs code is together.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24031
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |  7 ++---
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 14 ++++-----
 drivers/staging/lustre/lustre/llite/lproc_llite.c  | 34 ++++++++++++++++++++--
 drivers/staging/lustre/lustre/llite/super25.c      | 24 ++++-----------
 4 files changed, 45 insertions(+), 34 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 4053314..2719bc53 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -636,8 +636,8 @@ struct ll_file_data {
 	struct list_head fd_lccs; /* list of ll_cl_context */
 };
 
-extern struct dentry *llite_root;
-extern struct kset *llite_kset;
+void llite_tunables_unregister(void);
+int llite_tunables_register(void);
 
 static inline struct inode *ll_info2i(struct ll_inode_info *lli)
 {
@@ -675,8 +675,7 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 void cl_put_grouplock(struct ll_grouplock *cg);
 
 /* llite/lproc_llite.c */
-int ll_debugfs_register_super(struct dentry *parent,
-			      struct super_block *sb, char *osc, char *mdc);
+int ll_debugfs_register_super(struct super_block *sb, char *osc, char *mdc);
 void ll_debugfs_unregister_super(struct ll_sb_info *sbi);
 void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, int count);
 void lprocfs_llite_init_vars(struct lprocfs_static_vars *lvars);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 437f4cc..d16f5d1 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -57,8 +57,6 @@
 #include "llite_internal.h"
 
 struct kmem_cache *ll_file_data_slab;
-struct dentry *llite_root;
-struct kset *llite_kset;
 
 #ifndef log2
 #define log2(n) ffz(~(n))
@@ -572,13 +570,11 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	kfree(data);
 	kfree(osfs);
 
-	if (llite_root) {
-		err = ll_debugfs_register_super(llite_root, sb, dt, md);
-		if (err < 0) {
-			CERROR("%s: could not register mount in debugfs: "
-			       "rc = %d\n", ll_get_fsname(sb, NULL, 0), err);
-			err = 0;
-		}
+	err = ll_debugfs_register_super(sb, dt, md);
+	if (err < 0) {
+		CERROR("%s: could not register mount in debugfs: rc = %d\n",
+		       ll_get_fsname(sb, NULL, 0), err);
+		err = 0;
 	}
 
 	return err;
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index cae483f..a9ad328 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -39,6 +39,35 @@
 #include "llite_internal.h"
 #include "vvp_internal.h"
 
+static struct dentry *llite_root;
+static struct kset *llite_kset;
+
+int llite_tunables_register(void)
+{
+	int rc = 0;
+
+	llite_kset = kset_create_and_add("llite", NULL, lustre_kobj);
+	if (!llite_kset)
+		return -ENOMEM;
+
+	llite_root = debugfs_create_dir("llite", debugfs_lustre_root);
+	if (IS_ERR_OR_NULL(llite_root)) {
+		rc = llite_root ? PTR_ERR(llite_root) : -ENOMEM;
+		llite_root = NULL;
+		kset_unregister(llite_kset);
+	}
+
+	return rc;
+}
+
+void llite_tunables_unregister(void)
+{
+	kset_unregister(llite_kset);
+
+	debugfs_remove(llite_root);
+	llite_root = NULL;
+}
+
 /* debugfs llite mount point registration */
 static const struct file_operations ll_rw_extents_stats_fops;
 static const struct file_operations ll_rw_extents_stats_pp_fops;
@@ -1175,8 +1204,7 @@ void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, int count)
 	[RA_STAT_FAILED_REACH_END] = "failed to reach end"
 };
 
-int ll_debugfs_register_super(struct dentry *parent,
-			      struct super_block *sb, char *osc, char *mdc)
+int ll_debugfs_register_super(struct super_block *sb, char *osc, char *mdc)
 {
 	struct lustre_sb_info *lsi = s2lsi(sb);
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
@@ -1201,7 +1229,7 @@ int ll_debugfs_register_super(struct dentry *parent,
 	snprintf(name, MAX_STRING_SIZE, "%.*s-%p", len,
 		 lsi->lsi_lmd->lmd_profile, sb);
 
-	dir = debugfs_create_dir(name, parent);
+	dir = debugfs_create_dir(name, llite_root);
 	sbi->ll_debugfs_entry = dir;
 
 	debugfs_create_file("dump_page_cache", 0444, dir, sbi,
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index a3bc57d..2f4306e 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -228,22 +228,13 @@ static int __init lustre_init(void)
 	if (!ll_file_data_slab)
 		goto out_cache;
 
-	llite_root = debugfs_create_dir("llite", debugfs_lustre_root);
-	if (IS_ERR_OR_NULL(llite_root)) {
-		rc = llite_root ? PTR_ERR(llite_root) : -ENOMEM;
-		llite_root = NULL;
+	rc = llite_tunables_register();
+	if (rc)
 		goto out_cache;
-	}
-
-	llite_kset = kset_create_and_add("llite", NULL, lustre_kobj);
-	if (!llite_kset) {
-		rc = -ENOMEM;
-		goto out_debugfs;
-	}
 
 	rc = vvp_global_init();
 	if (rc != 0)
-		goto out_sysfs;
+		goto out_tunables;
 
 	cl_inode_fini_env = cl_env_alloc(&cl_inode_fini_refcheck,
 					 LCT_REMEMBER | LCT_NOREF);
@@ -270,10 +261,8 @@ static int __init lustre_init(void)
 	cl_env_put(cl_inode_fini_env, &cl_inode_fini_refcheck);
 out_vvp:
 	vvp_global_fini();
-out_sysfs:
-	kset_unregister(llite_kset);
-out_debugfs:
-	debugfs_remove(llite_root);
+out_tunables:
+	llite_tunables_unregister();
 out_cache:
 	kmem_cache_destroy(ll_inode_cachep);
 	kmem_cache_destroy(ll_file_data_slab);
@@ -286,8 +275,7 @@ static void __exit lustre_exit(void)
 
 	lustre_register_client_process_config(NULL);
 
-	debugfs_remove(llite_root);
-	kset_unregister(llite_kset);
+	llite_tunables_unregister();
 
 	ll_xattr_fini();
 	cl_env_put(cl_inode_fini_env, &cl_inode_fini_refcheck);
-- 
1.8.3.1
