From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 12:13:20 +1100
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: obd_mount: fix possible
 race with module unload.
In-Reply-To: <151355938405.10227.11903161187102828189.stgit@noble>
References: <151355938405.10227.11903161187102828189.stgit@noble>
Message-ID: <151355960081.10227.4261861922935137504.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

lustre_fill_super() calls client_fill_super() without holding a
reference to the module containing client_fill_super.  If that
module is unloaded at a bad time, this can crash.

To be able to get a reference to the module using
try_get_module(), we need a pointer to the module.

So replace
  lustre_register_client_fill_super() and
  lustre_register_kill_super_cb()
with a single
  lustre_register_super_ops()
which also passed a module pointer.

Then use a spinlock to ensure the module pointer isn't removed
while try_module_get() is running, and use try_module_get() to
ensure we have a reference before calling client_fill_super().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_disk.h    |    5 ++-
 drivers/staging/lustre/lustre/llite/super25.c      |    6 +---
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   30 +++++++++++++-------
 3 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index 5089ec02dcad..100e993ab00b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -141,8 +141,9 @@ struct lustre_sb_info {
 /* obd_mount.c */
 
 int lustre_start_mgc(struct super_block *sb);
-void lustre_register_client_fill_super(int (*cfs)(struct super_block *sb));
-void lustre_register_kill_super_cb(void (*cfs)(struct super_block *sb));
+void lustre_register_super_ops(struct module *mod,
+			       int (*cfs)(struct super_block *sb),
+			       void (*ksc)(struct super_block *sb));
 int lustre_common_put_super(struct super_block *sb);
 
 int mgc_fsname2resid(char *fsname, struct ldlm_res_id *res_id, int type);
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 0bda111a096e..10105339790e 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -159,8 +159,7 @@ static int __init lustre_init(void)
 	if (rc != 0)
 		goto out_inode_fini_env;
 
-	lustre_register_client_fill_super(ll_fill_super);
-	lustre_register_kill_super_cb(ll_kill_super);
+	lustre_register_super_ops(THIS_MODULE, ll_fill_super, ll_kill_super);
 	lustre_register_client_process_config(ll_process_config);
 
 	return 0;
@@ -181,8 +180,7 @@ static int __init lustre_init(void)
 
 static void __exit lustre_exit(void)
 {
-	lustre_register_client_fill_super(NULL);
-	lustre_register_kill_super_cb(NULL);
+	lustre_register_super_ops(NULL, NULL, NULL);
 	lustre_register_client_process_config(NULL);
 
 	debugfs_remove(llite_root);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 8068cbbc8390..acc1ea773c9c 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -49,8 +49,9 @@
 #include <lustre_disk.h>
 #include <uapi/linux/lustre/lustre_param.h>
 
+static DEFINE_SPINLOCK(client_lock);
+static struct module *client_mod;
 static int (*client_fill_super)(struct super_block *sb);
-
 static void (*kill_super_cb)(struct super_block *sb);
 
 /**************** config llog ********************/
@@ -1143,10 +1144,15 @@ static int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent
 	}
 
 	if (lmd_is_client(lmd)) {
+		bool have_client = false;
 		CDEBUG(D_MOUNT, "Mounting client %s\n", lmd->lmd_profile);
 		if (!client_fill_super)
 			request_module("lustre");
-		if (!client_fill_super) {
+		spin_lock(&client_lock);
+		if (client_fill_super && try_module_get(client_mod))
+			have_client = true;
+		spin_unlock(&client_lock);
+		if (!have_client) {
 			LCONSOLE_ERROR_MSG(0x165, "Nothing registered for client mount! Is the 'lustre' module loaded?\n");
 			lustre_put_lsi(sb);
 			rc = -ENODEV;
@@ -1159,7 +1165,9 @@ static int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent
 			/* Connect and start */
 			/* (should always be ll_fill_super) */
 			rc = (*client_fill_super)(sb);
-			/* c_f_s will call lustre_common_put_super on failure */
+			/* c_f_s will call lustre_common_put_super on failure, otherwise
+			 * c_f_s will have taken another reference to the module */
+			module_put(client_mod);
 		}
 	} else {
 		CERROR("This is client-side-only module, cannot handle server mount.\n");
@@ -1185,17 +1193,17 @@ static int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent
 /* We can't call ll_fill_super by name because it lives in a module that
  * must be loaded after this one.
  */
-void lustre_register_client_fill_super(int (*cfs)(struct super_block *sb))
+void lustre_register_super_ops(struct module *mod,
+			       int (*cfs)(struct super_block *sb),
+			       void (*ksc)(struct super_block *sb))
 {
+	spin_lock(&client_lock);
+	client_mod = mod;
 	client_fill_super = cfs;
+	kill_super_cb = ksc;
+	spin_unlock(&client_lock);
 }
-EXPORT_SYMBOL(lustre_register_client_fill_super);
-
-void lustre_register_kill_super_cb(void (*cfs)(struct super_block *sb))
-{
-	kill_super_cb = cfs;
-}
-EXPORT_SYMBOL(lustre_register_kill_super_cb);
+EXPORT_SYMBOL(lustre_register_super_ops);
 
 /***************** FS registration ******************/
 static struct dentry *lustre_mount(struct file_system_type *fs_type, int flags,
