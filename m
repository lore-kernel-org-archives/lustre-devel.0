From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:50 -0400
Subject: [lustre-devel] [PATCH 57/58] staging: lustre: llite: add error
	handler in inode prepare phase
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-58-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Add error handler during inode inialization, so inode will
become bad inode if something bad happens during inode prepare
phase, otherwise the striped directory will not get its layout
and being mis-regarded as normal directory.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4930
Reviewed-on: http://review.whamcloud.com/10170
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |    4 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   66 +++++++++++--------
 drivers/staging/lustre/lustre/llite/namei.c        |   59 ++++++++++--------
 3 files changed, 72 insertions(+), 57 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 120aca3..e101dd8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -766,8 +766,8 @@ int ll_setattr(struct dentry *de, struct iattr *attr);
 int ll_statfs(struct dentry *de, struct kstatfs *sfs);
 int ll_statfs_internal(struct super_block *sb, struct obd_statfs *osfs,
 		       __u64 max_age, __u32 flags);
-void ll_update_inode(struct inode *inode, struct lustre_md *md);
-void ll_read_inode2(struct inode *inode, void *opaque);
+int ll_update_inode(struct inode *inode, struct lustre_md *md);
+int ll_read_inode2(struct inode *inode, void *opaque);
 void ll_delete_inode(struct inode *inode);
 int ll_iocontrol(struct inode *inode, struct file *file,
 		 unsigned int cmd, unsigned long arg);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 111264e..ea79ca3 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -464,7 +464,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	md_free_lustre_md(sbi->ll_md_exp, &lmd);
 	ptlrpc_req_finished(request);
 
-	if (!(root)) {
+	if (IS_ERR(root)) {
 		if (lmd.lsm)
 			obd_free_memmd(sbi->ll_dt_exp, &lmd.lsm);
 #ifdef CONFIG_FS_POSIX_ACL
@@ -1109,11 +1109,11 @@ static inline int lli_lsm_md_eq(const struct lmv_stripe_md *lsm_md1,
 		       lsm_md2->lsm_md_pool_name);
 }
 
-static void ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
+static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct lmv_stripe_md *lsm = md->lmv;
-	int idx;
+	int idx, rc;
 
 	LASSERT(S_ISDIR(inode->i_mode));
 	CDEBUG(D_INODE, "update lsm %p of "DFID"\n", lli->lli_lsm_md,
@@ -1122,7 +1122,7 @@ static void ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	/* no striped information from request. */
 	if (!lsm) {
 		if (!lli->lli_lsm_md) {
-			return;
+			return 0;
 		} else if (lli->lli_lsm_md->lsm_md_magic == LMV_MAGIC_MIGRATE) {
 			/*
 			 * migration is done, the temporay MIGRATE layout has
@@ -1132,27 +1132,22 @@ static void ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 			       PFID(ll_inode2fid(inode)));
 			lmv_free_memmd(lli->lli_lsm_md);
 			lli->lli_lsm_md = NULL;
-			return;
+			return 0;
 		} else {
 			/*
 			 * The lustre_md from req does not include stripeEA,
 			 * see ll_md_setattr
 			 */
-			return;
+			return 0;
 		}
 	}
 
 	/* set the directory layout */
 	if (!lli->lli_lsm_md) {
-		int rc;
-
 		rc = ll_init_lsm_md(inode, md);
-		if (rc) {
-			CERROR("%s: init "DFID" failed: rc = %d\n",
-			       ll_get_fsname(inode->i_sb, NULL, 0),
-			       PFID(&lli->lli_fid), rc);
-			return;
-		}
+		if (rc)
+			return rc;
+
 		lli->lli_lsm_md = lsm;
 		/*
 		 * set lsm_md to NULL, so the following free lustre_md
@@ -1161,7 +1156,7 @@ static void ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 		md->lmv = NULL;
 		CDEBUG(D_INODE, "Set lsm %p magic %x to "DFID"\n", lsm,
 		       lsm->lsm_md_magic, PFID(ll_inode2fid(inode)));
-		return;
+		return 0;
 	}
 
 	/* Compare the old and new stripe information */
@@ -1185,7 +1180,7 @@ static void ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 		       lli->lli_lsm_md->lsm_md_layout_version,
 		       lsm->lsm_md_pool_name,
 		       lli->lli_lsm_md->lsm_md_pool_name);
-		return;
+		return -EIO;
 	}
 
 	for (idx = 0; idx < lli->lli_lsm_md->lsm_md_stripe_count; idx++) {
@@ -1195,12 +1190,13 @@ static void ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 			       ll_get_fsname(inode->i_sb, NULL, 0), idx,
 			       PFID(&lli->lli_lsm_md->lsm_md_oinfo[idx].lmo_fid),
 			       PFID(&lsm->lsm_md_oinfo[idx].lmo_fid));
-			return;
+			return -EIO;
 		}
 	}
 
-	md_update_lsm_md(ll_i2mdexp(inode), ll_i2info(inode)->lli_lsm_md,
-			 md->body, ll_md_blocking_ast);
+	rc = md_update_lsm_md(ll_i2mdexp(inode), ll_i2info(inode)->lli_lsm_md,
+			      md->body, ll_md_blocking_ast);
+	return rc;
 }
 
 void ll_clear_inode(struct inode *inode)
@@ -1252,7 +1248,7 @@ void ll_clear_inode(struct inode *inode)
 
 	if (S_ISDIR(inode->i_mode))
 		ll_dir_clear_lsm_md(inode);
-	else
+	if (S_ISREG(inode->i_mode) && !is_bad_inode(inode))
 		LASSERT(list_empty(&lli->lli_agl_list));
 
 	/*
@@ -1320,7 +1316,7 @@ static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data,
 	op_data->op_handle = md.body->handle;
 	op_data->op_ioepoch = md.body->ioepoch;
 
-	ll_update_inode(inode, &md);
+	rc = ll_update_inode(inode, &md);
 	ptlrpc_req_finished(request);
 
 	return rc;
@@ -1679,7 +1675,7 @@ void ll_inode_size_unlock(struct inode *inode)
 	mutex_unlock(&lli->lli_size_mutex);
 }
 
-void ll_update_inode(struct inode *inode, struct lustre_md *md)
+int ll_update_inode(struct inode *inode, struct lustre_md *md)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct mdt_body *body = md->body;
@@ -1697,8 +1693,13 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 			lli->lli_maxbytes = MAX_LFS_FILESIZE;
 	}
 
-	if (S_ISDIR(inode->i_mode))
-		ll_update_lsm_md(inode, md);
+	if (S_ISDIR(inode->i_mode)) {
+		int rc;
+
+		rc = ll_update_lsm_md(inode, md);
+		if (rc)
+			return rc;
+	}
 
 #ifdef CONFIG_FS_POSIX_ACL
 	if (body->valid & OBD_MD_FLACL) {
@@ -1819,12 +1820,15 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 		if (body->t_state & MS_RESTORE)
 			lli->lli_flags |= LLIF_FILE_RESTORING;
 	}
+
+	return 0;
 }
 
-void ll_read_inode2(struct inode *inode, void *opaque)
+int ll_read_inode2(struct inode *inode, void *opaque)
 {
 	struct lustre_md *md = opaque;
 	struct ll_inode_info *lli = ll_i2info(inode);
+	int rc;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
 	       PFID(&lli->lli_fid), inode);
@@ -1840,7 +1844,9 @@ void ll_read_inode2(struct inode *inode, void *opaque)
 	LTIME_S(inode->i_atime) = 0;
 	LTIME_S(inode->i_ctime) = 0;
 	inode->i_rdev = 0;
-	ll_update_inode(inode, md);
+	rc = ll_update_inode(inode, md);
+	if (rc)
+		return rc;
 
 	/* OIDEBUG(inode); */
 
@@ -1861,6 +1867,8 @@ void ll_read_inode2(struct inode *inode, void *opaque)
 		init_special_inode(inode, inode->i_mode,
 				   inode->i_rdev);
 	}
+
+	return 0;
 }
 
 void ll_delete_inode(struct inode *inode)
@@ -2127,7 +2135,9 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 		goto cleanup;
 
 	if (*inode) {
-		ll_update_inode(*inode, &md);
+		rc = ll_update_inode(*inode, &md);
+		if (rc)
+			goto out;
 	} else {
 		LASSERT(sb);
 
@@ -2146,7 +2156,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 		*inode = ll_iget(sb, cl_fid_build_ino(&md.body->fid1,
 					     sbi->ll_flags & LL_SBI_32BIT_API),
 				 &md);
-		if (!*inode) {
+		if (IS_ERR(*inode)) {
 #ifdef CONFIG_FS_POSIX_ACL
 			if (md.posix_acl) {
 				posix_acl_release(md.posix_acl);
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 41591dd..5dcedb0 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -96,41 +96,46 @@ static int ll_set_inode(struct inode *inode, void *opaque)
 	return 0;
 }
 
-/*
- * Get an inode by inode number (already instantiated by the intent lookup).
- * Returns inode or NULL
+/**
+ * Get an inode by inode number(@hash), which is already instantiated by
+ * the intent lookup).
  */
 struct inode *ll_iget(struct super_block *sb, ino_t hash,
 		      struct lustre_md *md)
 {
 	struct inode	 *inode;
+	int rc = 0;
 
 	LASSERT(hash != 0);
 	inode = iget5_locked(sb, hash, ll_test_inode, ll_set_inode, md);
-
-	if (inode) {
-		if (inode->i_state & I_NEW) {
-			int rc = 0;
-
-			ll_read_inode2(inode, md);
-			if (S_ISREG(inode->i_mode) &&
-			    !ll_i2info(inode)->lli_clob) {
-				CDEBUG(D_INODE,
-				       "%s: apply lsm %p to inode " DFID ".\n",
-				       ll_get_fsname(sb, NULL, 0), md->lsm,
-				       PFID(ll_inode2fid(inode)));
-				rc = cl_file_inode_init(inode, md);
-			}
-			if (rc != 0) {
-				iget_failed(inode);
-				inode = NULL;
-			} else {
-				unlock_new_inode(inode);
-			}
-		} else if (!(inode->i_state & (I_FREEING | I_CLEAR))) {
-			ll_update_inode(inode, md);
-			CDEBUG(D_VFSTRACE, "got inode: "DFID"(%p)\n",
-			       PFID(&md->body->fid1), inode);
+	if (!inode)
+		return ERR_PTR(-ENOMEM);
+
+	if (inode->i_state & I_NEW) {
+		rc = ll_read_inode2(inode, md);
+		if (!rc && S_ISREG(inode->i_mode) &&
+		    !ll_i2info(inode)->lli_clob) {
+			CDEBUG(D_INODE, "%s: apply lsm %p to inode "DFID"\n",
+			       ll_get_fsname(sb, NULL, 0), md->lsm,
+			       PFID(ll_inode2fid(inode)));
+			rc = cl_file_inode_init(inode, md);
+		}
+		if (rc) {
+			make_bad_inode(inode);
+			unlock_new_inode(inode);
+			iput(inode);
+			inode = ERR_PTR(rc);
+		} else {
+			unlock_new_inode(inode);
+		}
+	} else if (!(inode->i_state & (I_FREEING | I_CLEAR))) {
+		rc = ll_update_inode(inode, md);
+		CDEBUG(D_VFSTRACE, "got inode: "DFID"(%p): rc = %d\n",
+		       PFID(&md->body->fid1), inode, rc);
+		if (rc) {
+			make_bad_inode(inode);
+			iput(inode);
+			inode = ERR_PTR(rc);
 		}
 	}
 	return inode;
-- 
1.7.1
