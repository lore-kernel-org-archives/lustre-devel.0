From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:32 -0400
Subject: [lustre-devel] [PATCH 29/38] lustre: llite: replace
 ll_process_config with class_modify_config
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The current method of handling tunables with ll_process_config can
not work with sysfs. So replace ll_process_config handling with
class_modify_config() which can handle both sysfs and debugfs.
This is just to make llite work but eventually the code will be
updated to pass in a kobject to class_process_config().

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/32722
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lustre_disk.h    |  2 ++
 .../staging/lustre/lustre/llite/llite_internal.h   |  4 +--
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 36 ++-----------------
 drivers/staging/lustre/lustre/llite/lproc_llite.c  | 15 ++++----
 drivers/staging/lustre/lustre/llite/super25.c      |  4 ---
 .../staging/lustre/lustre/obdclass/obd_config.c    | 41 +++++++++++++++-------
 6 files changed, 43 insertions(+), 59 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index 6bed07a..7b6421d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -114,6 +114,7 @@ struct lustre_mount_data {
 /****************** superblock additional info *********************/
 
 struct ll_sb_info;
+struct kobject;
 
 struct lustre_sb_info {
 	int			lsi_flags;
@@ -122,6 +123,7 @@ struct lustre_sb_info {
 	struct ll_sb_info	*lsi_llsbi;   /* add'l client sbi info */
 	struct dt_device	*lsi_dt_dev;  /* dt device to access disk fs*/
 	atomic_t		lsi_mounts;  /* references to the srv_mnt */
+	struct kobject		*lsi_kobj;
 	char			lsi_svname[MTI_NAME_MAXLEN];
 	char			lsi_osd_obdname[64];
 	char			lsi_osd_uuid[64];
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 1130ea3..bf679c9 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -678,9 +678,8 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 
 /* llite/lproc_llite.c */
 int ll_debugfs_register_super(struct super_block *sb, const char *name);
-void ll_debugfs_unregister_super(struct ll_sb_info *sbi);
+void ll_debugfs_unregister_super(struct super_block *sb);
 void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, int count);
-void lprocfs_llite_init_vars(struct lprocfs_static_vars *lvars);
 void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 		       struct ll_file_data *file, loff_t pos,
 		       size_t count, int rw);
@@ -851,7 +850,6 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 int ll_get_max_mdsize(struct ll_sb_info *sbi, int *max_mdsize);
 int ll_get_default_mdsize(struct ll_sb_info *sbi, int *default_mdsize);
 int ll_set_default_mdsize(struct ll_sb_info *sbi, int default_mdsize);
-int ll_process_config(struct lustre_cfg *lcfg);
 
 enum {
 	LUSTRE_OPC_MKDIR	= 0,
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 7765060..f0fe21f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -693,7 +693,7 @@ static void client_common_put_super(struct super_block *sb)
 	obd_disconnect(sbi->ll_dt_exp);
 	sbi->ll_dt_exp = NULL;
 
-	ll_debugfs_unregister_super(sbi);
+	ll_debugfs_unregister_super(sb);
 
 	obd_fid_fini(sbi->ll_md_exp->exp_obd);
 	obd_disconnect(sbi->ll_md_exp);
@@ -1020,7 +1020,7 @@ int ll_fill_super(struct super_block *sb)
 
 out_debugfs:
 	if (err < 0)
-		ll_debugfs_unregister_super(sbi);
+		ll_debugfs_unregister_super(sb);
 out_free:
 	kfree(md);
 	kfree(dt);
@@ -2319,38 +2319,6 @@ int ll_obd_statfs(struct inode *inode, void __user *arg)
 	return rc;
 }
 
-int ll_process_config(struct lustre_cfg *lcfg)
-{
-	char *ptr;
-	void *sb;
-	struct lprocfs_static_vars lvars;
-	unsigned long x;
-	int rc = 0;
-
-	lprocfs_llite_init_vars(&lvars);
-
-	/* The instance name contains the sb: lustre-client-aacfe000 */
-	ptr = strrchr(lustre_cfg_string(lcfg, 0), '-');
-	if (!ptr || !*(++ptr))
-		return -EINVAL;
-	rc = kstrtoul(ptr, 16, &x);
-	if (rc != 0)
-		return -EINVAL;
-	sb = (void *)x;
-	/* This better be a real Lustre superblock! */
-	LASSERT(s2lsi((struct super_block *)sb)->lsi_lmd->lmd_magic ==
-		LMD_MAGIC);
-
-	/* Note we have not called client_common_fill_super yet, so
-	 * proc fns must be able to handle that!
-	 */
-	rc = class_process_proc_param(PARAM_LLITE, lvars.obd_vars,
-				      lcfg, sb);
-	if (rc > 0)
-		rc = 0;
-	return rc;
-}
-
 /* this function prepares md_op_data hint for passing ot down to MD stack. */
 struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      struct inode *i1, struct inode *i2,
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 30873fc..1492d70 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1252,6 +1252,7 @@ void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, int count)
 
 int ll_debugfs_register_super(struct super_block *sb, const char *name)
 {
+	struct lustre_sb_info *lsi = s2lsi(sb);
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct dentry *dir;
 	int err, id;
@@ -1329,6 +1330,8 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 	if (err)
 		goto out_ra_stats;
 
+	lsi->lsi_kobj = kobject_get(&sbi->ll_kset.kobj);
+
 	return 0;
 
 out_ra_stats:
@@ -1341,8 +1344,13 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 	return err;
 }
 
-void ll_debugfs_unregister_super(struct ll_sb_info *sbi)
+void ll_debugfs_unregister_super(struct super_block *sb)
 {
+	struct lustre_sb_info *lsi = s2lsi(sb);
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
+
+	kobject_put(lsi->lsi_kobj);
+
 	debugfs_remove_recursive(sbi->ll_debugfs_entry);
 
 	if (sbi->ll_dt_obd)
@@ -1719,8 +1727,3 @@ static ssize_t ll_rw_offset_stats_seq_write(struct file *file,
 }
 
 LPROC_SEQ_FOPS(ll_rw_offset_stats);
-
-void lprocfs_llite_init_vars(struct lprocfs_static_vars *lvars)
-{
-	lvars->obd_vars = lprocfs_llite_obd_vars;
-}
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 2f4306e..562bf329 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -253,8 +253,6 @@ static int __init lustre_init(void)
 	if (rc)
 		goto out_inode_fini_env;
 
-	lustre_register_client_process_config(ll_process_config);
-
 	return 0;
 
 out_inode_fini_env:
@@ -273,8 +271,6 @@ static void __exit lustre_exit(void)
 {
 	lustre_unregister_fs();
 
-	lustre_register_client_process_config(NULL);
-
 	llite_tunables_unregister();
 
 	ll_xattr_fini();
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 823ddb0..9e46eb2 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -814,18 +814,11 @@ void class_del_profiles(void)
 }
 EXPORT_SYMBOL(class_del_profiles);
 
-/* We can't call ll_process_config or lquota_process_config directly because
+/* We can't call lquota_process_config directly because
  * it lives in a module that must be loaded after this one.
  */
-static int (*client_process_config)(struct lustre_cfg *lcfg);
 static int (*quota_process_config)(struct lustre_cfg *lcfg);
 
-void lustre_register_client_process_config(int (*cpc)(struct lustre_cfg *lcfg))
-{
-	client_process_config = cpc;
-}
-EXPORT_SYMBOL(lustre_register_client_process_config);
-
 static int process_param2_config(struct lustre_cfg *lcfg)
 {
 	char *param = lustre_cfg_string(lcfg, 1);
@@ -958,11 +951,35 @@ int class_process_config(struct lustre_cfg *lcfg)
 	}
 	case LCFG_PARAM: {
 		char *tmp;
+
 		/* llite has no obd */
-		if ((class_match_param(lustre_cfg_string(lcfg, 1),
-				       PARAM_LLITE, NULL) == 0) &&
-		    client_process_config) {
-			err = (*client_process_config)(lcfg);
+		if (class_match_param(lustre_cfg_string(lcfg, 1),
+				      PARAM_LLITE, NULL) == 0) {
+			struct lustre_sb_info *lsi;
+			unsigned long addr;
+			ssize_t count;
+
+			/* The instance name contains the sb:
+			 * lustre-client-aacfe000
+			 */
+			tmp = strrchr(lustre_cfg_string(lcfg, 0), '-');
+			if (!tmp || !*(++tmp)) {
+				err = -EINVAL;
+				goto out;
+			}
+
+			if (sscanf(tmp, "%lx", &addr) != 1) {
+				err = -EINVAL;
+				goto out;
+			}
+
+			lsi = s2lsi((struct super_block *)addr);
+			/* This better be a real Lustre superblock! */
+			LASSERT(lsi->lsi_lmd->lmd_magic == LMD_MAGIC);
+
+			count = class_modify_config(lcfg, PARAM_LLITE,
+						    lsi->lsi_kobj);
+			err = count < 0 ? count : 0;
 			goto out;
 		} else if ((class_match_param(lustre_cfg_string(lcfg, 1),
 					      PARAM_SYS, &tmp) == 0)) {
-- 
1.8.3.1
