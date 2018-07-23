From: NeilBrown <neilb@suse.com>
Date: Mon, 23 Jul 2018 16:23:04 +1000
Subject: [lustre-devel] [PATCH 6/9] lustre: hold ptlrpc active for
 lustre_start_mgc()
In-Reply-To: <153232696720.26222.9658151633697867322.stgit@noble>
References: <153232696720.26222.9658151633697867322.stgit@noble>
Message-ID: <153232698496.26222.2533442172154163310.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Commit 26f7a294e5ec ("staging: lustre: ptlrpc: move thread creation
out of module initialization") move ptlrpc initialization out of
module_init() and into explicit ptlrpc_inc_ref() calls.
This was added in ll_fill_super with a put_ref in ll_put_super().
Unfortunately this means lustre_fill_super calls lustre_start_mgc()
without first activating ptlrpc.
So move the inc/put ref calls to lustre_fill_super() and
lustre_common_put_super() respectively.

Fixes: 26f7a294e5ec ("staging: lustre: ptlrpc: move thread creation out of module initialization")
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c |   17 +++--------------
 drivers/staging/lustre/lustre/llite/mount.c     |   10 ++++++++--
 2 files changed, 11 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 64cd69cb493d..e6348345505c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -911,15 +911,9 @@ int ll_fill_super(struct super_block *sb)
 
 	CDEBUG(D_VFSTRACE, "VFS Op: sb %p\n", sb);
 
-	err = ptlrpc_inc_ref();
-	if (err)
-		return err;
-
 	cfg = kzalloc(sizeof(*cfg), GFP_NOFS);
-	if (!cfg) {
-		err = -ENOMEM;
-		goto out_put;
-	}
+	if (!cfg)
+		return -ENOMEM;
 
 	try_module_get(THIS_MODULE);
 
@@ -929,8 +923,7 @@ int ll_fill_super(struct super_block *sb)
 	if (!sbi) {
 		module_put(THIS_MODULE);
 		kfree(cfg);
-		err = -ENOMEM;
-		goto out_put;
+		return -ENOMEM;
 	}
 
 	err = ll_options(lsi->lsi_lmd->lmd_opts, &sbi->ll_flags);
@@ -997,9 +990,6 @@ int ll_fill_super(struct super_block *sb)
 		LCONSOLE_WARN("Mounted %s\n", profilenm);
 
 	kfree(cfg);
-out_put:
-	if (err)
-		ptlrpc_dec_ref();
 	return err;
 } /* ll_fill_super */
 
@@ -1071,7 +1061,6 @@ void ll_put_super(struct super_block *sb)
 
 	module_put(THIS_MODULE);
 
-	ptlrpc_dec_ref();
 } /* client_put_super */
 
 struct inode *ll_inode_from_resource_lock(struct ldlm_lock *lock)
diff --git a/drivers/staging/lustre/lustre/llite/mount.c b/drivers/staging/lustre/lustre/llite/mount.c
index 58e8b371f0c4..85f0a7fdcd39 100644
--- a/drivers/staging/lustre/lustre/llite/mount.c
+++ b/drivers/staging/lustre/lustre/llite/mount.c
@@ -596,6 +596,7 @@ int lustre_common_put_super(struct super_block *sb)
 	}
 	/* Drop a ref to the mounted disk */
 	lustre_put_lsi(sb);
+	ptlrpc_dec_ref();
 	return rc;
 }
 
@@ -1131,16 +1132,19 @@ static int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent
 
 	/* Figure out the lmd from the mount options */
 	if (lmd_parse(lmd2_data, lmd)) {
-		lustre_put_lsi(sb);
 		rc = -EINVAL;
-		goto out;
+		goto out_put_lsi;
 	}
 
 	if (lmd_is_client(lmd)) {
 		CDEBUG(D_MOUNT, "Mounting client %s\n", lmd->lmd_profile);
 
+		rc = ptlrpc_inc_ref();
+		if (rc)
+			goto out_put_lsi;
 		rc = lustre_start_mgc(sb);
 		if (rc) {
+			/* This will put_lsi and ptlrpc_dec_ref() */
 			lustre_common_put_super(sb);
 			goto out;
 		}
@@ -1157,6 +1161,8 @@ static int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent
 	 * This is why we do not put it here.
 	 */
 	goto out;
+out_put_lsi:
+	lustre_put_lsi(sb);
 out:
 	if (rc) {
 		CERROR("Unable to mount %s (%d)\n",
