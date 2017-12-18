From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 12:13:20 +1100
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: obdclass: discard
 FS_NEEDS_DEV flag.
In-Reply-To: <151355938405.10227.11903161187102828189.stgit@noble>
References: <151355938405.10227.11903161187102828189.stgit@noble>
Message-ID: <151355960071.10227.7678385187334068429.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Lustre mounts do not need a dev, as we can see from lustre_mount()
calling mount_nodev().  So remove the flag which could cause
confusion elsewhere.

Also format lustre_fs_types so that fields line up.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 2a79a223b98a..d49dc72ccba2 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -1230,11 +1230,11 @@ static void lustre_kill_super(struct super_block *sb)
 /** Register the "lustre" fs type
  */
 static struct file_system_type lustre_fs_type = {
-	.owner	= THIS_MODULE,
-	.name	 = "lustre",
-	.mount	= lustre_mount,
-	.kill_sb      = lustre_kill_super,
-	.fs_flags	= FS_REQUIRES_DEV | FS_RENAME_DOES_D_MOVE,
+	.owner		= THIS_MODULE,
+	.name		= "lustre",
+	.mount		= lustre_mount,
+	.kill_sb	= lustre_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE,
 };
 MODULE_ALIAS_FS("lustre");
 
