From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:52 +1100
Subject: [lustre-devel] [PATCH 30/32] lustre: remove some "#ifdef CONFIG*"
 from .c files.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231208.26912.7799074082457334373.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

It is Linux policy to avoid #ifdef in C files where
convenient - .h files are OK.

This patch defines a few inline functions which differ
depending on CONFIG_LUSTRE_FS_POSIX_ACL, and removes
some #ifdefs from .c files.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/obd.h        |   21 +++++++++++
 .../staging/lustre/lustre/llite/llite_internal.h   |   29 +++++++++++++++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   39 ++++----------------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    8 ++--
 4 files changed, 61 insertions(+), 36 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 6c984732d9c2..354f7d64e08a 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -37,6 +37,8 @@
 #include <linux/kobject.h>
 #include <linux/spinlock.h>
 #include <linux/sysfs.h>
+#include <linux/fs.h>
+#include <linux/posix_acl.h>
 
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <lustre_lib.h>
@@ -878,6 +880,25 @@ struct lustre_md {
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
+#define OBD_CONNECT_ACL_FLAGS	\
+	(OBD_CONNECT_ACL | OBD_CONNECT_UMASK | OBD_CONNECT_LARGE_ACL)
+#else
+static inline void lmd_clear_acl(struct lustre_md *md)
+{
+}
+
+#define OBD_CONNECT_ACL_FLAGS	(0)
+#endif
+
 struct md_open_data {
 	struct obd_client_handle	*mod_och;
 	struct ptlrpc_request		*mod_open_req;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 83053459f9c7..95ec46779c41 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -246,6 +246,35 @@ struct ll_inode_info {
 	struct list_head		lli_xattrs;/* ll_xattr_entry->xe_list */
 };
 
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
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index e55a4e0f68bf..d4325b49b924 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -209,10 +209,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
-#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
-	data->ocd_connect_flags |= OBD_CONNECT_ACL | OBD_CONNECT_UMASK |
-				   OBD_CONNECT_LARGE_ACL;
-#endif
+
+	data->ocd_connect_flags |= OBD_CONNECT_ACL_FLAGS;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_MDC_LIGHTWEIGHT))
 		/* flag mdc connection as lightweight, only used for test
@@ -512,12 +510,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	ptlrpc_req_finished(request);
 
 	if (IS_ERR(root)) {
-#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
-		if (lmd.posix_acl) {
-			posix_acl_release(lmd.posix_acl);
-			lmd.posix_acl = NULL;
-		}
-#endif
+		lmd_clear_acl(&lmd);
 		err = -EBADF;
 		CERROR("lustre_lite: bad iget4 for root\n");
 		goto out_root;
@@ -1394,13 +1387,8 @@ void ll_clear_inode(struct inode *inode)
 
 	ll_xattr_cache_destroy(inode);
 
-#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	forget_all_cached_acls(inode);
-	if (lli->lli_posix_acl) {
-		posix_acl_release(lli->lli_posix_acl);
-		lli->lli_posix_acl = NULL;
-	}
-#endif
+	lli_clear_acl(lli);
 	lli->lli_inode_magic = LLI_INODE_DEAD;
 
 	if (S_ISDIR(inode->i_mode))
@@ -1825,15 +1813,9 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
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
@@ -2239,12 +2221,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 					     sbi->ll_flags & LL_SBI_32BIT_API),
 				 &md);
 		if (IS_ERR(*inode)) {
-#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
-			if (md.posix_acl) {
-				posix_acl_release(md.posix_acl);
-				md.posix_acl = NULL;
-			}
-#endif
+			lmd_clear_acl(&md);
 			rc = PTR_ERR(*inode);
 			CERROR("new_inode -fatal: rc %d\n", rc);
 			goto out;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index b54c5f1418ae..a0b74244f295 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -543,11 +543,9 @@ static int mdc_get_lustre_md(struct obd_export *exp,
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
 
