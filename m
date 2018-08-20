From: James Simmons <jsimmons@infradead.org>
Date: Sun, 19 Aug 2018 22:39:25 -0400
Subject: [lustre-devel] [PATCH v2 01/38] lustre: llite: rename
 ldebugfs_[un]register_mountpoint
Message-ID: <1534732765-22828-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Rename ldebugfs_[un]register_mountpoint() to
ll_debugfs_[un]register_super(). This first
aligns the functions name with the major of
the llite function prototypes by starting
with the ll_* prefix. The use of mountpoint
is not the best way to describe the functions
who's name are being changed. Since this is
managed by struct ll_sb_info, which is the
lustre private instance for struct super_block,
so rename to *_super() instead.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24031
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>

Changelog)
v1) Initial patch
v2) Improved changelog message
---
 drivers/staging/lustre/lustre/llite/llite_internal.h | 6 +++---
 drivers/staging/lustre/lustre/llite/llite_lib.c      | 4 ++--
 drivers/staging/lustre/lustre/llite/lproc_llite.c    | 6 +++---
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 6ed7034..b2cdf75 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -675,9 +675,9 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 void cl_put_grouplock(struct ll_grouplock *cg);
 
 /* llite/lproc_llite.c */
-int ldebugfs_register_mountpoint(struct dentry *parent,
-				 struct super_block *sb, char *osc, char *mdc);
-void ldebugfs_unregister_mountpoint(struct ll_sb_info *sbi);
+int ll_debugfs_register_super(struct dentry *parent,
+			      struct super_block *sb, char *osc, char *mdc);
+void ll_debugfs_unregister_super(struct ll_sb_info *sbi);
 void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, int count);
 void lprocfs_llite_init_vars(struct lprocfs_static_vars *lvars);
 void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index fb3bc16..50ea5fb 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -573,7 +573,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	kfree(osfs);
 
 	if (llite_root) {
-		err = ldebugfs_register_mountpoint(llite_root, sb, dt, md);
+		err = ll_debugfs_register_super(llite_root, sb, dt, md);
 		if (err < 0) {
 			CERROR("%s: could not register mount in debugfs: "
 			       "rc = %d\n", ll_get_fsname(sb, NULL, 0), err);
@@ -679,7 +679,7 @@ static void client_common_put_super(struct super_block *sb)
 	obd_disconnect(sbi->ll_dt_exp);
 	sbi->ll_dt_exp = NULL;
 
-	ldebugfs_unregister_mountpoint(sbi);
+	ll_debugfs_unregister_super(sbi);
 
 	obd_fid_fini(sbi->ll_md_exp->exp_obd);
 	obd_disconnect(sbi->ll_md_exp);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 617aabb..996703d 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1175,8 +1175,8 @@ void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, int count)
 	[RA_STAT_FAILED_REACH_END] = "failed to reach end"
 };
 
-int ldebugfs_register_mountpoint(struct dentry *parent,
-				 struct super_block *sb, char *osc, char *mdc)
+int ll_debugfs_register_super(struct dentry *parent,
+			      struct super_block *sb, char *osc, char *mdc)
 {
 	struct lustre_sb_info *lsi = s2lsi(sb);
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
@@ -1285,7 +1285,7 @@ int ldebugfs_register_mountpoint(struct dentry *parent,
 	return err;
 }
 
-void ldebugfs_unregister_mountpoint(struct ll_sb_info *sbi)
+void ll_debugfs_unregister_super(struct ll_sb_info *sbi)
 {
 	debugfs_remove_recursive(sbi->ll_debugfs_entry);
 	kobject_put(&sbi->ll_kobj);
-- 
1.8.3.1
