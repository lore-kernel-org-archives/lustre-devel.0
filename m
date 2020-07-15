From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:55 -0400
Subject: [lustre-devel] [PATCH 14/37] lustre: remove some "#ifdef CONFIG*"
 from .c files.
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

It is Linux policy to avoid #ifdef in C files where
convenient - .h files are OK.

This patch defines a few inline functions which differ
depending on CONFIG_LUSTRE_FS_POSIX_ACL, and removes
some #ifdefs from .c files.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9679
Lustre-commit: f37e26964a34f ("LU-9679 lustre: remove some "#ifdef CONFIG*" from .c files.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39131
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h          | 21 ++++++++++++++++++++
 fs/lustre/llite/llite_internal.h | 29 +++++++++++++++++++++++++++
 fs/lustre/llite/llite_lib.c      | 43 +++++++++-------------------------------
 fs/lustre/mdc/mdc_request.c      |  8 +++-----
 4 files changed, 62 insertions(+), 39 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 438f4ca..ad2b2f4 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -34,6 +34,8 @@
 #ifndef __OBD_H
 #define __OBD_H
 
+#include <linux/fs.h>
+#include <linux/posix_acl.h>
 #include <linux/kobject.h>
 #include <linux/spinlock.h>
 #include <linux/sysfs.h>
@@ -930,6 +932,25 @@ struct lustre_md {
 	struct mdt_remote_perm		*remote_perm;
 };
 
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
+static inline void lmd_clear_acl(struct lustre_md *md)
+{
+	if (md->posix_acl) {
+		posix_acl_release(md->posix_acl);
+		md->posix_acl = NULL;
+	}
+}
+
+#define OBD_CONNECT_ACL_FLAGS  \
+	(OBD_CONNECT_ACL | OBD_CONNECT_UMASK | OBD_CONNECT_LARGE_ACL)
+#else
+static inline void lmd_clear_acl(struct lustre_md *md)
+{
+}
+
+#define OBD_CONNECT_ACL_FLAGS  (0)
+#endif
+
 struct md_open_data {
 	struct obd_client_handle	*mod_och;
 	struct ptlrpc_request		*mod_open_req;
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 2556dd8..31c528f 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -350,6 +350,35 @@ static inline void trunc_sem_up_write(struct ll_trunc_sem *sem)
 	wake_up_var(&sem->ll_trunc_readers);
 }
 
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
+static inline void lli_clear_acl(struct ll_inode_info *lli)
+{
+	if (lli->lli_posix_acl) {
+		posix_acl_release(lli->lli_posix_acl);
+		lli->lli_posix_acl = NULL;
+	}
+}
+
+static inline void lli_replace_acl(struct ll_inode_info *lli,
+				   struct lustre_md *md)
+{
+	spin_lock(&lli->lli_lock);
+	if (lli->lli_posix_acl)
+		posix_acl_release(lli->lli_posix_acl);
+	lli->lli_posix_acl = md->posix_acl;
+	spin_unlock(&lli->lli_lock);
+}
+#else
+static inline void lli_clear_acl(struct ll_inode_info *lli)
+{
+}
+
+static inline void lli_replace_acl(struct ll_inode_info *lli,
+				   struct lustre_md *md)
+{
+}
+#endif
+
 static inline u32 ll_layout_version_get(struct ll_inode_info *lli)
 {
 	u32 gen;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 1a7d805..c62e182 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -265,10 +265,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
-#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
-	data->ocd_connect_flags |= OBD_CONNECT_ACL | OBD_CONNECT_UMASK |
-				   OBD_CONNECT_LARGE_ACL;
-#endif
+	data->ocd_connect_flags |= OBD_CONNECT_ACL_FLAGS;
 
 	data->ocd_cksum_types = obd_cksum_types_supported_client();
 
@@ -618,13 +615,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	ptlrpc_req_finished(request);
 
 	if (IS_ERR(root)) {
-#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
-		if (lmd.posix_acl) {
-			posix_acl_release(lmd.posix_acl);
-			lmd.posix_acl = NULL;
-		}
-#endif
-		err = -EBADF;
+		lmd_clear_acl(&lmd);
+		err = IS_ERR(root) ? PTR_ERR(root) : -EBADF;
 		CERROR("lustre_lite: bad iget4 for root\n");
 		goto out_root;
 	}
@@ -1584,13 +1576,7 @@ void ll_clear_inode(struct inode *inode)
 
 	ll_xattr_cache_destroy(inode);
 
-#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
-	forget_all_cached_acls(inode);
-	if (lli->lli_posix_acl) {
-		posix_acl_release(lli->lli_posix_acl);
-		lli->lli_posix_acl = NULL;
-	}
-#endif
+	lli_clear_acl(lli);
 	lli->lli_inode_magic = LLI_INODE_DEAD;
 
 	if (S_ISDIR(inode->i_mode))
@@ -2233,15 +2219,9 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 			return rc;
 	}
 
-#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
-	if (body->mbo_valid & OBD_MD_FLACL) {
-		spin_lock(&lli->lli_lock);
-		if (lli->lli_posix_acl)
-			posix_acl_release(lli->lli_posix_acl);
-		lli->lli_posix_acl = md->posix_acl;
-		spin_unlock(&lli->lli_lock);
-	}
-#endif
+	if (body->mbo_valid & OBD_MD_FLACL)
+		lli_replace_acl(lli, md);
+
 	inode->i_ino = cl_fid_build_ino(&body->mbo_fid1,
 					sbi->ll_flags & LL_SBI_32BIT_API);
 	inode->i_generation = cl_fid_build_gen(&body->mbo_fid1);
@@ -2691,13 +2671,8 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 						  sbi->ll_flags & LL_SBI_32BIT_API),
 				 &md);
 		if (IS_ERR(*inode)) {
-#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
-			if (md.posix_acl) {
-				posix_acl_release(md.posix_acl);
-				md.posix_acl = NULL;
-			}
-#endif
-			rc = PTR_ERR(*inode);
+			lmd_clear_acl(&md);
+			rc = IS_ERR(*inode) ? PTR_ERR(*inode) : -ENOMEM;
 			CERROR("new_inode -fatal: rc %d\n", rc);
 			goto out;
 		}
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index d6d9f43..cacc58b 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -675,11 +675,9 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 	}
 
 out:
-	if (rc) {
-#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
-		posix_acl_release(md->posix_acl);
-#endif
-	}
+	if (rc)
+		lmd_clear_acl(md);
+
 	return rc;
 }
 
-- 
1.8.3.1
