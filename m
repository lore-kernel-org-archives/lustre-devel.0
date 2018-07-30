From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 19:16:32 -0400
Subject: [lustre-devel] [PATCH 1/3] lustre: obd: migrate lustre_fill_super()
 to llite
In-Reply-To: <1532992594-2576-1-git-send-email-jsimmons@infradead.org>
References: <1532992594-2576-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1532992594-2576-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Currently both obdclass and ptlrpc are built as separate modules
with ptlrpc being a child of obdclass. A recent change placed
ptlrpc_[inc|dec]_ref() into the obdclass code i.e obd_mount.c
which now causes a curricular module dependency. Examining the
code the bulk use of these functions are in lustre_fill_super().
So move lustre_fill_super() to the llite layer where it really
belongs. This change also allows lustre_fill_super() to be
simplified and we can push lustre_fill_super() instead of
ll_fill_super(). Also ptlrpc_dec_ref() needed to be pulled out
of lustre_common_put_super() as well. Once obdclass and ptlrpc
are combined into one module we can restore ptlrpc_dec_rec()
in lustre_common_put_super().

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lustre_disk.h    |   9 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   3 +
 drivers/staging/lustre/lustre/llite/super25.c      |  83 +++++++++++++-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 125 +++++----------------
 4 files changed, 115 insertions(+), 105 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index 1a6d421..772ecc9 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -141,10 +141,13 @@ struct lustre_sb_info {
 
 /* obd_mount.c */
 
+struct lustre_sb_info *lustre_init_lsi(struct super_block *sb);
+int lustre_put_lsi(struct super_block *sb);
+int lmd_parse(char *options, struct lustre_mount_data *lmd);
 int lustre_start_mgc(struct super_block *sb);
-void lustre_register_super_ops(struct module *mod,
-			       int (*cfs)(struct super_block *sb),
-			       void (*ksc)(struct super_block *sb));
+void lustre_register_super_ops(int (*cfs)(struct super_block *sb, void *data,
+					  int silent),
+                               void (*ksc)(struct super_block *sb));
 int lustre_common_put_super(struct super_block *sb);
 
 int mgc_fsname2resid(char *fsname, struct ldlm_res_id *res_id, int type);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 5c8d0fe..87a929c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -914,6 +914,7 @@ int ll_fill_super(struct super_block *sb)
 	cfg = kzalloc(sizeof(*cfg), GFP_NOFS);
 	if (!cfg) {
 		lustre_common_put_super(sb);
+		ptlrpc_dec_ref();
 		return -ENOMEM;
 	}
 
@@ -926,6 +927,7 @@ int ll_fill_super(struct super_block *sb)
 		module_put(THIS_MODULE);
 		kfree(cfg);
 		lustre_common_put_super(sb);
+		ptlrpc_dec_ref();
 		return -ENOMEM;
 	}
 
@@ -1059,6 +1061,7 @@ void ll_put_super(struct super_block *sb)
 	lsi->lsi_llsbi = NULL;
 
 	lustre_common_put_super(sb);
+	ptlrpc_dec_ref();
 
 	cl_env_cache_purge(~0);
 
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index d335f29..de43d58 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -83,6 +83,85 @@ struct super_operations lustre_super_operations = {
 };
 MODULE_ALIAS_FS("lustre");
 
+/** This is the entry point for the mount call into Lustre.
+ * This is called when a server or client is mounted,
+ * and this is where we start setting things up.
+ * @param data Mount options (e.g. -o flock,abort_recov)
+ */
+int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent)
+{
+	struct lustre_mount_data *lmd;
+	struct lustre_sb_info *lsi;
+	int rc;
+
+	CDEBUG(D_SUPER | D_CONFIG | D_VFSTRACE, "VFS Op: sb %p\n", sb);
+
+	lsi = lustre_init_lsi(sb);
+	if (!lsi)
+		return -ENOMEM;
+	lmd = lsi->lsi_lmd;
+
+	/*
+	 * Disable lockdep during mount, because mount locking patterns are
+	 * `special'.
+	 */
+	lockdep_off();
+
+	/*
+	 * LU-639: the obd cleanup of last mount may not finish yet, wait here.
+	 */
+	obd_zombie_barrier();
+
+	/* Figure out the lmd from the mount options */
+	if (lmd_parse(lmd2_data, lmd)) {
+		rc = -EINVAL;
+		goto out_put_lsi;
+	}
+
+	if (lmd_is_client(lmd)) {
+		CDEBUG(D_SUPER | D_CONFIG, "Mounting client %s\n",
+		       lmd->lmd_profile);
+		rc = ptlrpc_inc_ref();
+		if (rc)
+			goto out_put_lsi;
+
+		rc = lustre_start_mgc(sb);
+		if (rc) {
+			/* This will put_lsi and ptlrpc_dec_ref() */
+			lustre_common_put_super(sb);
+			ptlrpc_dec_ref();
+			goto out;
+		}
+
+		/* Connect and start */
+		rc = ll_fill_super(sb);
+
+		/*
+		 * c_f_s will call lustre_common_put_super on failure, otherwise
+		 * c_f_s will have taken another reference to the module
+		 */
+	} else {
+		CERROR("This is client-side-only module, cannot handle server mount.\n");
+		rc = -EINVAL;
+	}
+	/* If error happens in fill_super() call, @lsi will be killed there.
+	 * This is why we do not put it here.
+	 */
+	goto out;
+out_put_lsi:
+	lustre_put_lsi(sb);
+out:
+	if (rc) {
+		CERROR("Unable to mount %s (%d)\n",
+		       s2lsi(sb) ? lmd->lmd_dev : "", rc);
+	} else {
+		CDEBUG(D_SUPER, "Mount %s complete\n",
+		       lmd->lmd_dev);
+	}
+	lockdep_on();
+	return rc;
+}
+
 static int __init lustre_init(void)
 {
 	int rc;
@@ -145,7 +224,7 @@ static int __init lustre_init(void)
 	if (rc != 0)
 		goto out_inode_fini_env;
 
-	lustre_register_super_ops(THIS_MODULE, ll_fill_super, ll_kill_super);
+	lustre_register_super_ops(lustre_fill_super, ll_kill_super);
 	lustre_register_client_process_config(ll_process_config);
 
 	return 0;
@@ -166,7 +245,7 @@ static int __init lustre_init(void)
 
 static void __exit lustre_exit(void)
 {
-	lustre_register_super_ops(NULL, NULL, NULL);
+	lustre_register_super_ops(NULL, NULL);
 	lustre_register_client_process_config(NULL);
 
 	debugfs_remove(llite_root);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 1bd5613..ac841f4 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -50,8 +50,8 @@
 #include <uapi/linux/lustre/lustre_param.h>
 
 static DEFINE_SPINLOCK(client_lock);
-static struct module *client_mod;
-static int (*client_fill_super)(struct super_block *sb);
+static int (*client_fill_super)(struct super_block *sb, void *data,
+                                int silent);
 static void (*kill_super_cb)(struct super_block *sb);
 
 /**************** config llog ********************/
@@ -430,6 +430,7 @@ int lustre_start_mgc(struct super_block *sb)
 	kfree(niduuid);
 	return rc;
 }
+EXPORT_SYMBOL(lustre_start_mgc);
 
 static int lustre_stop_mgc(struct super_block *sb)
 {
@@ -507,7 +508,7 @@ static int lustre_stop_mgc(struct super_block *sb)
 
 /***************** lustre superblock **************/
 
-static struct lustre_sb_info *lustre_init_lsi(struct super_block *sb)
+struct lustre_sb_info *lustre_init_lsi(struct super_block *sb)
 {
 	struct lustre_sb_info *lsi;
 
@@ -532,6 +533,7 @@ static struct lustre_sb_info *lustre_init_lsi(struct super_block *sb)
 
 	return lsi;
 }
+EXPORT_SYMBOL(lustre_init_lsi);
 
 static int lustre_free_lsi(struct super_block *sb)
 {
@@ -567,7 +569,7 @@ static int lustre_free_lsi(struct super_block *sb)
 /* The lsi has one reference for every server that is using the disk -
  * e.g. MDT, MGS, and potentially MGC
  */
-static int lustre_put_lsi(struct super_block *sb)
+int lustre_put_lsi(struct super_block *sb)
 {
 	struct lustre_sb_info *lsi = s2lsi(sb);
 
@@ -578,6 +580,7 @@ static int lustre_put_lsi(struct super_block *sb)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(lustre_put_lsi);
 
 /*** SERVER NAME ***
  * <FSNAME><SEPARATOR><TYPE><INDEX>
@@ -686,7 +689,12 @@ int lustre_common_put_super(struct super_block *sb)
 	}
 	/* Drop a ref to the mounted disk */
 	lustre_put_lsi(sb);
-	ptlrpc_dec_ref();
+	/* !!! FIXME !!!!! */
+	/* ptlrpc_dec_ref() should go here but will
+	 * cause curricular module dependencies. Once
+	 * obdclass and ptlrpc are merged into one
+	 * module ptlrpc_dec_ref() can come back here
+	 */
 	return rc;
 }
 EXPORT_SYMBOL(lustre_common_put_super);
@@ -992,7 +1000,7 @@ static int lmd_parse_nidlist(char *buf, char **endh)
  * e.g. mount -v -t lustre -o abort_recov uml1:uml2:/lustre-client /mnt/lustre
  * dev is passed as device=uml1:/lustre by mount.lustre
  */
-static int lmd_parse(char *options, struct lustre_mount_data *lmd)
+int lmd_parse(char *options, struct lustre_mount_data *lmd)
 {
 	char *s1, *s2, *devname = NULL;
 	struct lustre_mount_data *raw = (struct lustre_mount_data *)options;
@@ -1216,106 +1224,16 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 	CERROR("Bad mount options %s\n", options);
 	return -EINVAL;
 }
-
-/** This is the entry point for the mount call into Lustre.
- * This is called when a server or client is mounted,
- * and this is where we start setting things up.
- * @param data Mount options (e.g. -o flock,abort_recov)
- */
-static int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent)
-{
-	struct lustre_mount_data *lmd;
-	struct lustre_sb_info *lsi;
-	int rc;
-
-	CDEBUG(D_MOUNT | D_VFSTRACE, "VFS Op: sb %p\n", sb);
-
-	lsi = lustre_init_lsi(sb);
-	if (!lsi)
-		return -ENOMEM;
-	lmd = lsi->lsi_lmd;
-
-	/*
-	 * Disable lockdep during mount, because mount locking patterns are
-	 * `special'.
-	 */
-	lockdep_off();
-
-	/*
-	 * LU-639: the obd cleanup of last mount may not finish yet, wait here.
-	 */
-	obd_zombie_barrier();
-
-	/* Figure out the lmd from the mount options */
-	if (lmd_parse(lmd2_data, lmd)) {
-		rc = -EINVAL;
-		goto out_put_lsi;
-	}
-
-	if (lmd_is_client(lmd)) {
-		bool have_client = false;
-		CDEBUG(D_MOUNT, "Mounting client %s\n", lmd->lmd_profile);
-		if (!client_fill_super)
-			request_module("lustre");
-		rc = ptlrpc_inc_ref();
-		if (rc)
-			goto out_put_lsi;
-		spin_lock(&client_lock);
-		if (client_fill_super && try_module_get(client_mod))
-			have_client = true;
-		spin_unlock(&client_lock);
-		if (!have_client) {
-			LCONSOLE_ERROR_MSG(0x165, "Nothing registered for client mount! Is the 'lustre' module loaded?\n");
-			lustre_put_lsi(sb);
-			rc = -ENODEV;
-		} else {
-			rc = lustre_start_mgc(sb);
-			if (rc) {
-				/* This will put_lsi and ptlrpc_dec_ref() */
-				lustre_common_put_super(sb);
-				goto out;
-			}
-			/* Connect and start */
-			/* (should always be ll_fill_super) */
-			rc = (*client_fill_super)(sb);
-			/*
-			 * c_f_s will call lustre_common_put_super on failure, otherwise
-			 * c_f_s will have taken another reference to the module
-			 */
-			module_put(client_mod);
-		}
-	} else {
-		CERROR("This is client-side-only module, cannot handle server mount.\n");
-		rc = -EINVAL;
-	}
-
-	/* If error happens in fill_super() call, @lsi will be killed there.
-	 * This is why we do not put it here.
-	 */
-	goto out;
-out_put_lsi:
-	lustre_put_lsi(sb);
-out:
-	if (rc) {
-		CERROR("Unable to mount %s (%d)\n",
-		       s2lsi(sb) ? lmd->lmd_dev : "", rc);
-	} else {
-		CDEBUG(D_SUPER, "Mount %s complete\n",
-		       lmd->lmd_dev);
-	}
-	lockdep_on();
-	return rc;
-}
+EXPORT_SYMBOL(lmd_parse);
 
 /* We can't call ll_fill_super by name because it lives in a module that
  * must be loaded after this one.
  */
-void lustre_register_super_ops(struct module *mod,
-			       int (*cfs)(struct super_block *sb),
+void lustre_register_super_ops(int (*cfs)(struct super_block *sb, void *data,
+					  int silent),
 			       void (*ksc)(struct super_block *sb))
 {
 	spin_lock(&client_lock);
-	client_mod = mod;
 	client_fill_super = cfs;
 	kill_super_cb = ksc;
 	spin_unlock(&client_lock);
@@ -1326,7 +1244,14 @@ void lustre_register_super_ops(struct module *mod,
 static struct dentry *lustre_mount(struct file_system_type *fs_type, int flags,
 				   const char *devname, void *data)
 {
-	return mount_nodev(fs_type, flags, data, lustre_fill_super);
+	struct dentry *root;
+
+	spin_lock(&client_lock);
+	if (!client_fill_super)
+		request_module("lustre");
+	root = mount_nodev(fs_type, flags, data, client_fill_super);
+	spin_unlock(&client_lock);
+	return root;
 }
 
 static void lustre_kill_super(struct super_block *sb)
-- 
1.8.3.1
