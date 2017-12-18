From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 12:13:20 +1100
Subject: [lustre-devel] [PATCH 3/4] staging: lustre: obdclass: remove
 vfsmount option from client_fill_super
In-Reply-To: <151355938405.10227.11903161187102828189.stgit@noble>
References: <151355938405.10227.11903161187102828189.stgit@noble>
Message-ID: <151355960078.10227.13624890998823000934.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

This arg is always NULL and is never used.
So discard it from this and related functions.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_disk.h    |    3 +--
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    7 +++----
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    8 +++-----
 4 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index 8f1a22527006..5089ec02dcad 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -141,8 +141,7 @@ struct lustre_sb_info {
 /* obd_mount.c */
 
 int lustre_start_mgc(struct super_block *sb);
-void lustre_register_client_fill_super(int (*cfs)(struct super_block *sb,
-						  struct vfsmount *mnt));
+void lustre_register_client_fill_super(int (*cfs)(struct super_block *sb));
 void lustre_register_kill_super_cb(void (*cfs)(struct super_block *sb));
 int lustre_common_put_super(struct super_block *sb);
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index b133fd00c08c..99e17d0cb3d6 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -792,7 +792,7 @@ int ll_revalidate_it_finish(struct ptlrpc_request *request,
 extern struct super_operations lustre_super_operations;
 
 void ll_lli_init(struct ll_inode_info *lli);
-int ll_fill_super(struct super_block *sb, struct vfsmount *mnt);
+int ll_fill_super(struct super_block *sb);
 void ll_put_super(struct super_block *sb);
 void ll_kill_super(struct super_block *sb);
 struct inode *ll_inode_from_resource_lock(struct ldlm_lock *lock);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index e84719662edf..6735a6f006d2 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -146,8 +146,7 @@ static void ll_free_sbi(struct super_block *sb)
 	kfree(sbi);
 }
 
-static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
-				    struct vfsmount *mnt)
+static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 {
 	struct inode *root = NULL;
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
@@ -867,7 +866,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 	mutex_init(&lli->lli_layout_mutex);
 }
 
-int ll_fill_super(struct super_block *sb, struct vfsmount *mnt)
+int ll_fill_super(struct super_block *sb)
 {
 	struct lustre_profile *lprof = NULL;
 	struct lustre_sb_info *lsi = s2lsi(sb);
@@ -944,7 +943,7 @@ int ll_fill_super(struct super_block *sb, struct vfsmount *mnt)
 	}
 
 	/* connections, registrations, sb setup */
-	err = client_common_fill_super(sb, md, dt, mnt);
+	err = client_common_fill_super(sb, md, dt);
 	if (!err)
 		sbi->ll_client_common_fill_super_succeeded = 1;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index c98c7716a910..8068cbbc8390 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -49,8 +49,7 @@
 #include <lustre_disk.h>
 #include <uapi/linux/lustre/lustre_param.h>
 
-static int (*client_fill_super)(struct super_block *sb,
-				struct vfsmount *mnt);
+static int (*client_fill_super)(struct super_block *sb);
 
 static void (*kill_super_cb)(struct super_block *sb);
 
@@ -1159,7 +1158,7 @@ static int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent
 			}
 			/* Connect and start */
 			/* (should always be ll_fill_super) */
-			rc = (*client_fill_super)(sb, NULL);
+			rc = (*client_fill_super)(sb);
 			/* c_f_s will call lustre_common_put_super on failure */
 		}
 	} else {
@@ -1186,8 +1185,7 @@ static int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent
 /* We can't call ll_fill_super by name because it lives in a module that
  * must be loaded after this one.
  */
-void lustre_register_client_fill_super(int (*cfs)(struct super_block *sb,
-						  struct vfsmount *mnt))
+void lustre_register_client_fill_super(int (*cfs)(struct super_block *sb))
 {
 	client_fill_super = cfs;
 }
