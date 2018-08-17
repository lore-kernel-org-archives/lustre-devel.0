From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:10 -0400
Subject: [lustre-devel] [PATCH 07/38] lustre: llite: register mountpoint
 before process llog
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Emoly Liu <emoly@whamcloud.com>

In ll_fill_super(), ll_debugfs_register_super() should be
called before lustre_process_log(), otherwise the directory
/sys/fs/lustre/llite/* can't be created in time and the params
"llite.*.*" won't be set correctly.

Also, this patch adds sbi->ll_xattr_cache_set to mark the flag
LL_SBI_XATTR_CACHE already set during lustre_process_log(),
in case that it will be overwritten in client_common_fill_super().

Signed-off-by: Emoly Liu <emoly@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9399
Reviewed-on: https://review.whamcloud.com/27241
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/#/c/32516
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |  5 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 75 ++++++++++++++++------
 drivers/staging/lustre/lustre/llite/lproc_llite.c  | 30 +++------
 3 files changed, 68 insertions(+), 42 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 5577407..9e60c5e 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -461,12 +461,15 @@ struct ll_sb_info {
 	struct obd_uuid	   ll_sb_uuid;
 	struct obd_export	*ll_md_exp;
 	struct obd_export	*ll_dt_exp;
+	struct obd_device	*ll_md_obd;
+	struct obd_device	*ll_dt_obd;
 	struct dentry		*ll_debugfs_entry;
 	struct lu_fid	     ll_root_fid; /* root object fid */
 
 	int		       ll_flags;
 	unsigned int		  ll_umounting:1,
 				  ll_xattr_cache_enabled:1,
+				ll_xattr_cache_set:1, /* already set to 0/1 */
 				  ll_client_common_fill_super_succeeded:1;
 
 	struct lustre_client_ocd  ll_lco;
@@ -674,7 +677,7 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 void cl_put_grouplock(struct ll_grouplock *cg);
 
 /* llite/lproc_llite.c */
-int ll_debugfs_register_super(struct super_block *sb, char *osc, char *mdc);
+int ll_debugfs_register_super(struct super_block *sb);
 void ll_debugfs_unregister_super(struct ll_sb_info *sbi);
 void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, int count);
 void lprocfs_llite_init_vars(struct lprocfs_static_vars *lvars);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index d352287..95568b7 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -156,7 +156,6 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 {
 	struct inode *root = NULL;
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
-	struct obd_device *obd;
 	struct obd_statfs *osfs = NULL;
 	struct ptlrpc_request *request = NULL;
 	struct obd_connect_data *data = NULL;
@@ -166,8 +165,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	u64 valid;
 	int size, err, checksum;
 
-	obd = class_name2obd(md);
-	if (!obd) {
+	sbi->ll_md_obd  = class_name2obd(md);
+	if (!sbi->ll_md_obd) {
 		CERROR("MD %s: not setup or attached\n", md);
 		return -EINVAL;
 	}
@@ -247,8 +246,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	data->ocd_brw_size = MD_MAX_BRW_SIZE;
 
-	err = obd_connect(NULL, &sbi->ll_md_exp, obd, &sbi->ll_sb_uuid,
-			  data, NULL);
+	err = obd_connect(NULL, &sbi->ll_md_exp, sbi->ll_md_obd,
+			  &sbi->ll_sb_uuid, data, NULL);
 	if (err == -EBUSY) {
 		LCONSOLE_ERROR_MSG(0x14f,
 				   "An MDT (md %s) is performing recovery, of which this client is not a part. Please wait for recovery to complete, abort, or time out.\n",
@@ -360,14 +359,19 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 			LCONSOLE_INFO(
 				"%s: disabling xattr cache due to unknown maximum xattr size.\n",
 				dt);
-		} else {
+		} else if (!sbi->ll_xattr_cache_set) {
+			/* If xattr_cache is already set (no matter 0 or 1)
+			 * during processing llog, it won't be enabled here.
+			 */
+			spin_lock(&sbi->ll_lock);
 			sbi->ll_flags |= LL_SBI_XATTR_CACHE;
+			spin_unlock(&sbi->ll_lock);
 			sbi->ll_xattr_cache_enabled = 1;
 		}
 	}
 
-	obd = class_name2obd(dt);
-	if (!obd) {
+	sbi->ll_dt_obd  = class_name2obd(dt);
+	if (!sbi->ll_dt_obd) {
 		CERROR("DT %s: not setup or attached\n", dt);
 		err = -ENODEV;
 		goto out_md_fid;
@@ -414,13 +418,13 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	       data->ocd_connect_flags,
 	       data->ocd_version, data->ocd_grant);
 
-	obd->obd_upcall.onu_owner = &sbi->ll_lco;
-	obd->obd_upcall.onu_upcall = cl_ocd_update;
+	sbi->ll_dt_obd->obd_upcall.onu_owner = &sbi->ll_lco;
+	sbi->ll_dt_obd->obd_upcall.onu_upcall = cl_ocd_update;
 
 	data->ocd_brw_size = DT_MAX_BRW_SIZE;
 
-	err = obd_connect(NULL, &sbi->ll_dt_exp, obd, &sbi->ll_sb_uuid, data,
-			  NULL);
+	err = obd_connect(NULL, &sbi->ll_dt_exp, sbi->ll_dt_obd,
+			  &sbi->ll_sb_uuid, data, NULL);
 	if (err == -EBUSY) {
 		LCONSOLE_ERROR_MSG(0x150,
 				   "An OST (dt %s) is performing recovery, of which this client is not a part.  Please wait for recovery to complete, abort, or time out.\n",
@@ -568,11 +572,26 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	kfree(data);
 	kfree(osfs);
 
-	err = ll_debugfs_register_super(sb, dt, md);
-	if (err < 0) {
-		CERROR("%s: could not register mount in debugfs: rc = %d\n",
-		       ll_get_fsname(sb, NULL, 0), err);
-		err = 0;
+	if (sbi->ll_dt_obd) {
+		err = sysfs_create_link(&sbi->ll_kset.kobj,
+					&sbi->ll_dt_obd->obd_kobj,
+					sbi->ll_dt_obd->obd_type->typ_name);
+		if (err < 0) {
+			CERROR("%s: could not register %s in llite: rc = %d\n",
+			       dt, ll_get_fsname(sb, NULL, 0), err);
+			err = 0;
+		}
+	}
+
+	if (sbi->ll_md_obd) {
+		err = sysfs_create_link(&sbi->ll_kset.kobj,
+					&sbi->ll_md_obd->obd_kobj,
+					sbi->ll_md_obd->obd_type->typ_name);
+		if (err < 0) {
+			CERROR("%s: could not register %s in llite: rc = %d\n",
+			       md, ll_get_fsname(sb, NULL, 0), err);
+			err = 0;
+		}
 	}
 
 	return err;
@@ -583,6 +602,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 out_dt:
 	obd_disconnect(sbi->ll_dt_exp);
 	sbi->ll_dt_exp = NULL;
+	sbi->ll_dt_obd = NULL;
 out_md_fid:
 	obd_fid_fini(sbi->ll_md_exp->exp_obd);
 out_md:
@@ -931,6 +951,16 @@ int ll_fill_super(struct super_block *sb)
 	/* kernel >= 2.6.38 store dentry operations in sb->s_d_op. */
 	sb->s_d_op = &ll_d_ops;
 
+	/* Call ll_debugsfs_register_super() before lustre_process_log()
+	 * so that "llite.*.*" params can be processed correctly.
+	 */
+	err = ll_debugfs_register_super(sb);
+	if (err < 0) {
+		CERROR("%s: could not register mountpoint in llite: rc = %d\n",
+		       ll_get_fsname(sb, NULL, 0), err);
+		err = 0;
+	}
+
 	/* Generate a string unique to this super, in case some joker tries
 	 * to mount the same fs@two mount points.
 	 * Use the address of the super itself.
@@ -942,7 +972,7 @@ int ll_fill_super(struct super_block *sb)
 	/* set up client obds */
 	err = lustre_process_log(sb, profilenm, cfg);
 	if (err < 0)
-		goto out_free;
+		goto out_debugfs;
 
 	/* Profile set with LCFG_MOUNTOPT so we can find our mdc and osc obds */
 	lprof = class_get_profile(profilenm);
@@ -951,7 +981,7 @@ int ll_fill_super(struct super_block *sb)
 				   "The client profile '%s' could not be read from the MGS.  Does that filesystem exist?\n",
 				   profilenm);
 		err = -EINVAL;
-		goto out_free;
+		goto out_debugfs;
 	}
 	CDEBUG(D_CONFIG, "Found profile %s: mdc=%s osc=%s\n", profilenm,
 	       lprof->lp_md, lprof->lp_dt);
@@ -959,13 +989,13 @@ int ll_fill_super(struct super_block *sb)
 	dt = kasprintf(GFP_NOFS, "%s-%p", lprof->lp_dt, cfg->cfg_instance);
 	if (!dt) {
 		err = -ENOMEM;
-		goto out_free;
+		goto out_debugfs;
 	}
 
 	md = kasprintf(GFP_NOFS, "%s-%p", lprof->lp_md, cfg->cfg_instance);
 	if (!md) {
 		err = -ENOMEM;
-		goto out_free;
+		goto out_debugfs;
 	}
 
 	/* connections, registrations, sb setup */
@@ -973,6 +1003,9 @@ int ll_fill_super(struct super_block *sb)
 	if (!err)
 		sbi->ll_client_common_fill_super_succeeded = 1;
 
+out_debugfs:
+	if (err < 0)
+		ll_debugfs_unregister_super(sbi);
 out_free:
 	kfree(md);
 	kfree(dt);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 90140b0..868c9b0 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -924,6 +924,7 @@ static ssize_t xattr_cache_store(struct kobject *kobj,
 		return -ENOTSUPP;
 
 	sbi->ll_xattr_cache_enabled = val;
+	sbi->ll_xattr_cache_set = 1;
 
 	return count;
 }
@@ -1226,11 +1227,10 @@ void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, int count)
 	[RA_STAT_FAILED_REACH_END] = "failed to reach end"
 };
 
-int ll_debugfs_register_super(struct super_block *sb, char *osc, char *mdc)
+int ll_debugfs_register_super(struct super_block *sb)
 {
 	struct lustre_sb_info *lsi = s2lsi(sb);
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
-	struct obd_device *obd;
 	struct dentry *dir;
 	char name[MAX_STRING_SIZE + 1], *ptr;
 	int err, id, len;
@@ -1238,8 +1238,6 @@ int ll_debugfs_register_super(struct super_block *sb, char *osc, char *mdc)
 	name[MAX_STRING_SIZE] = '\0';
 
 	LASSERT(sbi);
-	LASSERT(mdc);
-	LASSERT(osc);
 
 	/* Get fsname */
 	len = strlen(lsi->lsi_lmd->lmd_profile);
@@ -1315,22 +1313,6 @@ int ll_debugfs_register_super(struct super_block *sb, char *osc, char *mdc)
 		goto out;
 
 	err = kset_register(&sbi->ll_kset);
-	if (err)
-		goto out;
-
-	/* MDC info */
-	obd = class_name2obd(mdc);
-
-	err = sysfs_create_link(&sbi->ll_kset.kobj, &obd->obd_kobj,
-				obd->obd_type->typ_name);
-	if (err)
-		goto out;
-
-	/* OSC */
-	obd = class_name2obd(osc);
-
-	err = sysfs_create_link(&sbi->ll_kset.kobj, &obd->obd_kobj,
-				obd->obd_type->typ_name);
 out:
 	if (err) {
 		debugfs_remove_recursive(sbi->ll_debugfs_entry);
@@ -1344,6 +1326,14 @@ void ll_debugfs_unregister_super(struct ll_sb_info *sbi)
 {
 	debugfs_remove_recursive(sbi->ll_debugfs_entry);
 
+	if (sbi->ll_dt_obd)
+		sysfs_remove_link(&sbi->ll_kset.kobj,
+				  sbi->ll_dt_obd->obd_type->typ_name);
+
+	if (sbi->ll_md_obd)
+		sysfs_remove_link(&sbi->ll_kset.kobj,
+				  sbi->ll_md_obd->obd_type->typ_name);
+
 	kset_unregister(&sbi->ll_kset);
 	wait_for_completion(&sbi->ll_kobj_unregister);
 
-- 
1.8.3.1
