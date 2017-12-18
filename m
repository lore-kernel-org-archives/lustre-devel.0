From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 12:13:20 +1100
Subject: [lustre-devel] [PATCH 2/4] staging: lustre: obdclass: remove
 pointless struct lustre_mount_data2
In-Reply-To: <151355938405.10227.11903161187102828189.stgit@noble>
References: <151355938405.10227.11903161187102828189.stgit@noble>
Message-ID: <151355960074.10227.13015552450143881635.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

This is used to pass a void* and NULL to lustre_fill_super().
It is easier just to pass the void*.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   19 ++++---------------
 1 file changed, 4 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index d49dc72ccba2..c98c7716a910 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -1107,20 +1107,14 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 	return -EINVAL;
 }
 
-struct lustre_mount_data2 {
-	void *lmd2_data;
-	struct vfsmount *lmd2_mnt;
-};
-
 /** This is the entry point for the mount call into Lustre.
  * This is called when a server or client is mounted,
  * and this is where we start setting things up.
  * @param data Mount options (e.g. -o flock,abort_recov)
  */
-static int lustre_fill_super(struct super_block *sb, void *data, int silent)
+static int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent)
 {
 	struct lustre_mount_data *lmd;
-	struct lustre_mount_data2 *lmd2 = data;
 	struct lustre_sb_info *lsi;
 	int rc;
 
@@ -1143,7 +1137,7 @@ static int lustre_fill_super(struct super_block *sb, void *data, int silent)
 	obd_zombie_barrier();
 
 	/* Figure out the lmd from the mount options */
-	if (lmd_parse((lmd2->lmd2_data), lmd)) {
+	if (lmd_parse(lmd2_data, lmd)) {
 		lustre_put_lsi(sb);
 		rc = -EINVAL;
 		goto out;
@@ -1165,7 +1159,7 @@ static int lustre_fill_super(struct super_block *sb, void *data, int silent)
 			}
 			/* Connect and start */
 			/* (should always be ll_fill_super) */
-			rc = (*client_fill_super)(sb, lmd2->lmd2_mnt);
+			rc = (*client_fill_super)(sb, NULL);
 			/* c_f_s will call lustre_common_put_super on failure */
 		}
 	} else {
@@ -1209,12 +1203,7 @@ EXPORT_SYMBOL(lustre_register_kill_super_cb);
 static struct dentry *lustre_mount(struct file_system_type *fs_type, int flags,
 				   const char *devname, void *data)
 {
-	struct lustre_mount_data2 lmd2 = {
-		.lmd2_data = data,
-		.lmd2_mnt = NULL
-	};
-
-	return mount_nodev(fs_type, flags, &lmd2, lustre_fill_super);
+	return mount_nodev(fs_type, flags, data, lustre_fill_super);
 }
 
 static void lustre_kill_super(struct super_block *sb)
