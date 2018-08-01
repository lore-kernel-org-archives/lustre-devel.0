From: NeilBrown <neilb@suse.com>
Date: Wed, 01 Aug 2018 13:17:22 +1000
Subject: [lustre-devel] [PATCH 1/3] lustre: obd: migrate
 lustre_fill_super() to llite
In-Reply-To: <87tvogrtbj.fsf@notabene.neil.brown.name>
References: <1532992594-2576-1-git-send-email-jsimmons@infradead.org>
 <1532992594-2576-2-git-send-email-jsimmons@infradead.org>
 <87tvogrtbj.fsf@notabene.neil.brown.name>
Message-ID: <8736vyrd19.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jul 31 2018, NeilBrown wrote:

> On Mon, Jul 30 2018, James Simmons wrote:
>
>> Currently both obdclass and ptlrpc are built as separate modules
>> with ptlrpc being a child of obdclass. A recent change placed
>> ptlrpc_[inc|dec]_ref() into the obdclass code i.e obd_mount.c
>> which now causes a curricular module dependency. Examining the
>
> Oops, that was careless - sorry about that.
> Maybe I should just revert that patch .... but that probably
> doesn't actually make things easier.  Let's go with your fix.

Actually, I changed my mind - sorry.

I've reverted the offending patch, and written a patch that just
moves the minimum from obdclass to llite.
There is room for further cleaning up...

Thanks,
NeilBrown

From cb6578971fd9e1d1dedb6e88629741dcf8e31318 Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.com>
Date: Wed, 1 Aug 2018 10:09:39 +1000
Subject: [PATCH] lustre: move client mounting from obdclass to llite.

Mounting a lustre client is currently handled
in obdclass, using services from llite.
This requires obdclass to load the llite module
and set up inter-module linkage.

The purpose of this was for common code to support both
client and server mounts.  This isn't really a good idea
and need to go.  When we add the server, it will use a
separate filesystem type.

So move the mounting code from obdclass/obd_mount to llite/super25
and remove the inter-module linkages.
Add some EXPORT_SYMBOL() so that llite can access some helpers
that remain in obdclass.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_disk.h    |   7 +-
 drivers/staging/lustre/lustre/llite/super25.c      | 116 +++++++++++++++-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   4 -
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 152 +--------------------
 4 files changed, 125 insertions(+), 154 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index 1a6d421ea64b..1d18b2fd210d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -142,13 +142,14 @@ struct lustre_sb_info {
 /* obd_mount.c */
 
 int lustre_start_mgc(struct super_block *sb);
-void lustre_register_super_ops(struct module *mod,
-			       int (*cfs)(struct super_block *sb),
-			       void (*ksc)(struct super_block *sb));
 int lustre_common_put_super(struct super_block *sb);
 
 int mgc_fsname2resid(char *fsname, struct ldlm_res_id *res_id, int type);
 
+struct lustre_sb_info *lustre_init_lsi(struct super_block *sb);
+int lustre_put_lsi(struct super_block *sb);
+int lmd_parse(char *options, struct lustre_mount_data *lmd);
+
 /** @} disk */
 
 #endif /* _LUSTRE_DISK_H */
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index d335f29556c2..966b0564c952 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -32,6 +32,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LLITE
+#define D_MOUNT (D_SUPER | D_CONFIG/*|D_WARNING */)
 
 #include <linux/module.h>
 #include <linux/types.h>
@@ -81,8 +82,115 @@ struct super_operations lustre_super_operations = {
 	.remount_fs    = ll_remount_fs,
 	.show_options  = ll_show_options,
 };
+
+/** This is the entry point for the mount call into Lustre.
+ * This is called when a server or client is mounted,
+ * and this is where we start setting things up.
+ * @param data Mount options (e.g. -o flock,abort_recov)
+ */
+static int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent)
+{
+	struct lustre_mount_data *lmd;
+	struct lustre_sb_info *lsi;
+	int rc;
+
+	CDEBUG(D_MOUNT | D_VFSTRACE, "VFS Op: sb %p\n", sb);
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
+		lustre_put_lsi(sb);
+		rc = -EINVAL;
+		goto out;
+	}
+
+	if (lmd_is_client(lmd)) {
+		CDEBUG(D_MOUNT, "Mounting client %s\n", lmd->lmd_profile);
+
+		rc = lustre_start_mgc(sb);
+		if (rc) {
+			lustre_common_put_super(sb);
+			goto out;
+		}
+		/* Connect and start */
+		rc = ll_fill_super(sb);
+		/*
+		 * c_f_s will call lustre_common_put_super on failure, otherwise
+		 * c_f_s will have taken another reference to the module
+		 */
+	} else {
+		CERROR("This is client-side-only module, cannot handle server mount.\n");
+		rc = -EINVAL;
+	}
+
+	/* If error happens in fill_super() call, @lsi will be killed there.
+	 * This is why we do not put it here.
+	 */
+	goto out;
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
+/***************** FS registration ******************/
+static struct dentry *lustre_mount(struct file_system_type *fs_type, int flags,
+				   const char *devname, void *data)
+{
+	return mount_nodev(fs_type, flags, data, lustre_fill_super);
+}
+
+static void lustre_kill_super(struct super_block *sb)
+{
+	struct lustre_sb_info *lsi = s2lsi(sb);
+
+	if (lsi)
+		ll_kill_super(sb);
+
+	kill_anon_super(sb);
+}
+
+/** Register the "lustre" fs type
+ */
+static struct file_system_type lustre_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "lustre",
+	.mount		= lustre_mount,
+	.kill_sb	= lustre_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE,
+};
 MODULE_ALIAS_FS("lustre");
 
+int lustre_register_fs(void)
+{
+	return register_filesystem(&lustre_fs_type);
+}
+
+int lustre_unregister_fs(void)
+{
+	return unregister_filesystem(&lustre_fs_type);
+}
 static int __init lustre_init(void)
 {
 	int rc;
@@ -145,7 +253,10 @@ static int __init lustre_init(void)
 	if (rc != 0)
 		goto out_inode_fini_env;
 
-	lustre_register_super_ops(THIS_MODULE, ll_fill_super, ll_kill_super);
+	rc = lustre_register_fs();
+	if (rc)
+		goto out_inode_fini_env;
+
 	lustre_register_client_process_config(ll_process_config);
 
 	return 0;
@@ -166,7 +277,8 @@ static int __init lustre_init(void)
 
 static void __exit lustre_exit(void)
 {
-	lustre_register_super_ops(NULL, NULL, NULL);
+	lustre_unregister_fs();
+
 	lustre_register_client_process_config(NULL);
 
 	debugfs_remove(llite_root);
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 81a4c666bb69..9d389288bea4 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -513,15 +513,11 @@ static int __init obdclass_init(void)
 	if (err)
 		return err;
 
-	err = lustre_register_fs();
-
 	return err;
 }
 
 static void obdclass_exit(void)
 {
-	lustre_unregister_fs();
-
 	misc_deregister(&obd_psdev);
 	llog_info_fini();
 	cl_global_fini();
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 39911dcb0fd9..f0f00b779cf1 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -49,11 +49,6 @@
 #include <lustre_disk.h>
 #include <uapi/linux/lustre/lustre_param.h>
 
-static DEFINE_SPINLOCK(client_lock);
-static struct module *client_mod;
-static int (*client_fill_super)(struct super_block *sb);
-static void (*kill_super_cb)(struct super_block *sb);
-
 /**************** config llog ********************/
 
 /** Get a config log from the MGS and process it.
@@ -430,6 +425,7 @@ int lustre_start_mgc(struct super_block *sb)
 	kfree(niduuid);
 	return rc;
 }
+EXPORT_SYMBOL(lustre_start_mgc);
 
 static int lustre_stop_mgc(struct super_block *sb)
 {
@@ -507,7 +503,7 @@ static int lustre_stop_mgc(struct super_block *sb)
 
 /***************** lustre superblock **************/
 
-static struct lustre_sb_info *lustre_init_lsi(struct super_block *sb)
+struct lustre_sb_info *lustre_init_lsi(struct super_block *sb)
 {
 	struct lustre_sb_info *lsi;
 
@@ -532,6 +528,7 @@ static struct lustre_sb_info *lustre_init_lsi(struct super_block *sb)
 
 	return lsi;
 }
+EXPORT_SYMBOL(lustre_init_lsi);
 
 static int lustre_free_lsi(struct super_block *sb)
 {
@@ -567,7 +564,7 @@ static int lustre_free_lsi(struct super_block *sb)
 /* The lsi has one reference for every server that is using the disk -
  * e.g. MDT, MGS, and potentially MGC
  */
-static int lustre_put_lsi(struct super_block *sb)
+int lustre_put_lsi(struct super_block *sb)
 {
 	struct lustre_sb_info *lsi = s2lsi(sb);
 
@@ -578,6 +575,7 @@ static int lustre_put_lsi(struct super_block *sb)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(lustre_put_lsi);
 
 /*** SERVER NAME ***
  * <FSNAME><SEPARATOR><TYPE><INDEX>
@@ -991,7 +989,7 @@ static int lmd_parse_nidlist(char *buf, char **endh)
  * e.g. mount -v -t lustre -o abort_recov uml1:uml2:/lustre-client /mnt/lustre
  * dev is passed as device=uml1:/lustre by mount.lustre
  */
-static int lmd_parse(char *options, struct lustre_mount_data *lmd)
+int lmd_parse(char *options, struct lustre_mount_data *lmd)
 {
 	char *s1, *s2, *devname = NULL;
 	struct lustre_mount_data *raw = (struct lustre_mount_data *)options;
@@ -1215,141 +1213,5 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 	CERROR("Bad mount options %s\n", options);
 	return -EINVAL;
 }
+EXPORT_SYMBOL(lmd_parse);
 
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
-		lustre_put_lsi(sb);
-		rc = -EINVAL;
-		goto out;
-	}
-
-	if (lmd_is_client(lmd)) {
-		bool have_client = false;
-		CDEBUG(D_MOUNT, "Mounting client %s\n", lmd->lmd_profile);
-		if (!client_fill_super)
-			request_module("lustre");
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
-
-/* We can't call ll_fill_super by name because it lives in a module that
- * must be loaded after this one.
- */
-void lustre_register_super_ops(struct module *mod,
-			       int (*cfs)(struct super_block *sb),
-			       void (*ksc)(struct super_block *sb))
-{
-	spin_lock(&client_lock);
-	client_mod = mod;
-	client_fill_super = cfs;
-	kill_super_cb = ksc;
-	spin_unlock(&client_lock);
-}
-EXPORT_SYMBOL(lustre_register_super_ops);
-
-/***************** FS registration ******************/
-static struct dentry *lustre_mount(struct file_system_type *fs_type, int flags,
-				   const char *devname, void *data)
-{
-	return mount_nodev(fs_type, flags, data, lustre_fill_super);
-}
-
-static void lustre_kill_super(struct super_block *sb)
-{
-	struct lustre_sb_info *lsi = s2lsi(sb);
-
-	if (kill_super_cb && lsi)
-		(*kill_super_cb)(sb);
-
-	kill_anon_super(sb);
-}
-
-/** Register the "lustre" fs type
- */
-static struct file_system_type lustre_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "lustre",
-	.mount		= lustre_mount,
-	.kill_sb	= lustre_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE,
-};
-MODULE_ALIAS_FS("lustre");
-
-int lustre_register_fs(void)
-{
-	return register_filesystem(&lustre_fs_type);
-}
-
-int lustre_unregister_fs(void)
-{
-	return unregister_filesystem(&lustre_fs_type);
-}
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180801/37c46d70/attachment-0001.sig>
