From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:11 -0400
Subject: [lustre-devel] [PATCH 08/38] lustre: llite: move lmd_profile
 handling
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The function ll_debugfs_register_super() should only handling
sysfs related things so move the lmd_profile parsing out of
that function.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24031
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_internal.h |  2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c      | 17 ++++++++++++++++-
 drivers/staging/lustre/lustre/llite/lproc_llite.c    | 18 ++----------------
 3 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 9e60c5e..1130ea3 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -677,7 +677,7 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 void cl_put_grouplock(struct ll_grouplock *cg);
 
 /* llite/lproc_llite.c */
-int ll_debugfs_register_super(struct super_block *sb);
+int ll_debugfs_register_super(struct super_block *sb, const char *name);
 void ll_debugfs_unregister_super(struct ll_sb_info *sbi);
 void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, int count);
 void lprocfs_llite_init_vars(struct lprocfs_static_vars *lvars);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 95568b7..ce072da 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -909,6 +909,8 @@ void ll_lli_init(struct ll_inode_info *lli)
 	memset(lli->lli_jobid, 0, LUSTRE_JOBID_SIZE);
 }
 
+#define MAX_STRING_SIZE 128
+
 int ll_fill_super(struct super_block *sb)
 {
 	struct lustre_profile *lprof = NULL;
@@ -917,6 +919,9 @@ int ll_fill_super(struct super_block *sb)
 	char  *dt = NULL, *md = NULL;
 	char  *profilenm = get_profile_name(sb);
 	struct config_llog_instance *cfg;
+	char name[MAX_STRING_SIZE];
+	char *ptr;
+	int len;
 	int    err;
 	static atomic_t ll_bdi_num = ATOMIC_INIT(0);
 
@@ -951,10 +956,20 @@ int ll_fill_super(struct super_block *sb)
 	/* kernel >= 2.6.38 store dentry operations in sb->s_d_op. */
 	sb->s_d_op = &ll_d_ops;
 
+	/* Get fsname */
+	len = strlen(lsi->lsi_lmd->lmd_profile);
+	ptr = strrchr(lsi->lsi_lmd->lmd_profile, '-');
+	if (ptr && (strcmp(ptr, "-client") == 0))
+		len -= 7;
+
+	/* Mount info */
+	snprintf(name, MAX_STRING_SIZE, "%.*s-%p", len,
+		 lsi->lsi_lmd->lmd_profile, sb);
+
 	/* Call ll_debugsfs_register_super() before lustre_process_log()
 	 * so that "llite.*.*" params can be processed correctly.
 	 */
-	err = ll_debugfs_register_super(sb);
+	err = ll_debugfs_register_super(sb, name);
 	if (err < 0) {
 		CERROR("%s: could not register mountpoint in llite: rc = %d\n",
 		       ll_get_fsname(sb, NULL, 0), err);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 868c9b0..4186a8d 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1227,28 +1227,14 @@ void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, int count)
 	[RA_STAT_FAILED_REACH_END] = "failed to reach end"
 };
 
-int ll_debugfs_register_super(struct super_block *sb)
+int ll_debugfs_register_super(struct super_block *sb, const char *name)
 {
-	struct lustre_sb_info *lsi = s2lsi(sb);
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct dentry *dir;
-	char name[MAX_STRING_SIZE + 1], *ptr;
-	int err, id, len;
-
-	name[MAX_STRING_SIZE] = '\0';
+	int err, id;
 
 	LASSERT(sbi);
 
-	/* Get fsname */
-	len = strlen(lsi->lsi_lmd->lmd_profile);
-	ptr = strrchr(lsi->lsi_lmd->lmd_profile, '-');
-	if (ptr && (strcmp(ptr, "-client") == 0))
-		len -= 7;
-
-	/* Mount info */
-	snprintf(name, MAX_STRING_SIZE, "%.*s-%p", len,
-		 lsi->lsi_lmd->lmd_profile, sb);
-
 	dir = debugfs_create_dir(name, llite_root);
 	sbi->ll_debugfs_entry = dir;
 
-- 
1.8.3.1
