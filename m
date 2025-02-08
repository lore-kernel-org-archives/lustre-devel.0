Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8CFB9C02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:30:41 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWw021kFz1x5M;
	Fri, 07 Feb 2025 16:30:40 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWvv1961z1wsW
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:35 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id E47CC88F9D4;
 Fri,  7 Feb 2025 19:30:32 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id D9A6A106BE16; Fri,  7 Feb 2025 19:30:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:07 -0500
Message-ID: <20250208003027.180076-2-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 01/21] lustre: llite: implicit default LMV
 inherit
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Hongchao Zhang <hongchao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

With implicit default LMV inherit, the inherited default LMV is
not stored on disk, but maintained on client side.

Benefits:
* change of directory default LMV will be populated to all sub levels
  at runtime.
* default LMV will be packed into mkdir request, therefore MDT doesn't
  need to read it from disk, as will improve mkdir performance.

Caveats:
* to disable inherited default LMV on subdir, a default LMV need to be
  set on this subdir explicitly like this:
        "lfs setdirstripe -D -i <subdir_mdt_index> --max-inherit 0"
Changes on client side:
* update inherited default LMV after lookup/open/revalidate.
* pack default LMV in mkdir request.
* add "--raw" option for "lfs getdirstripe -D" to print default LMV
  stored in inode, if directory doesn't have default LMV, or its
  default LMV is implicitly inherited, nothing will be printed.

Changes on MDT side:
* use the default LMV from client in lod_ah_init() to mkdir.
* don't save inherited default LMV in mkdir.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15971
Lustre-commit: 388a185eace0e6b16 ("LU-15971 llite: implicit default LMV inherit")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/47789
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_lmv.h          |  64 ++++++----
 fs/lustre/llite/dcache.c                |  11 +-
 fs/lustre/llite/dir.c                   | 129 ++++++++++---------
 fs/lustre/llite/file.c                  |   9 +-
 fs/lustre/llite/llite_internal.h        |   9 +-
 fs/lustre/llite/llite_lib.c             | 158 ++++++++++++++++++++----
 fs/lustre/llite/namei.c                 |  58 +++++++--
 fs/lustre/llite/statahead.c             |   6 +-
 fs/lustre/mdc/mdc_lib.c                 |   7 ++
 fs/lustre/obdclass/lprocfs_status.c     |   2 +-
 fs/lustre/ptlrpc/wiretest.c             |   2 +
 include/uapi/linux/lustre/lustre_idl.h  |   2 +
 include/uapi/linux/lustre/lustre_user.h |   6 +-
 13 files changed, 344 insertions(+), 119 deletions(-)

diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index 5e3dbc52e846..c3b55d4b63e0 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -82,6 +82,33 @@ static inline bool lmv_dir_bad_hash(const struct lmv_stripe_md *lsm)
 	return !lmv_is_known_hash_type(lsm->lsm_md_hash_type);
 }
 
+static inline u8 lmv_inherit_next(u8 inherit)
+{
+	if (inherit == LMV_INHERIT_END || inherit == LMV_INHERIT_NONE)
+		return LMV_INHERIT_NONE;
+
+	if (inherit == LMV_INHERIT_UNLIMITED || inherit > LMV_INHERIT_MAX)
+		return inherit;
+
+	return inherit - 1;
+}
+
+static inline u8 lmv_inherit_rr_next(u8 inherit_rr)
+{
+	if (inherit_rr == LMV_INHERIT_RR_NONE ||
+	    inherit_rr == LMV_INHERIT_RR_UNLIMITED ||
+	    inherit_rr > LMV_INHERIT_RR_MAX)
+		return inherit_rr;
+
+	return inherit_rr - 1;
+}
+
+static inline bool lmv_is_inheritable(u8 inherit)
+{
+	return inherit == LMV_INHERIT_UNLIMITED ||
+	       (inherit > LMV_INHERIT_END && inherit <= LMV_INHERIT_MAX);
+}
+
 static inline bool
 lsm_md_eq(const struct lmv_stripe_md *lsm1, const struct lmv_stripe_md *lsm2)
 {
@@ -145,6 +172,22 @@ static inline void lsm_md_dump(int mask, const struct lmv_stripe_md *lsm)
 		       i, PFID(&lsm->lsm_md_oinfo[i].lmo_fid));
 }
 
+static inline bool
+lsm_md_inherited(const struct lmv_stripe_md *plsm,
+		 const struct lmv_stripe_md *clsm)
+{
+	return plsm && clsm &&
+	       plsm->lsm_md_magic == clsm->lsm_md_magic &&
+	       plsm->lsm_md_stripe_count == clsm->lsm_md_stripe_count &&
+	       plsm->lsm_md_master_mdt_index ==
+			clsm->lsm_md_master_mdt_index &&
+	       plsm->lsm_md_hash_type == clsm->lsm_md_hash_type &&
+	       lmv_inherit_next(plsm->lsm_md_max_inherit) ==
+			clsm->lsm_md_max_inherit &&
+	       lmv_inherit_rr_next(plsm->lsm_md_max_inherit_rr) ==
+			clsm->lsm_md_max_inherit_rr;
+}
+
 union lmv_mds_md;
 
 void lmv_free_memmd(struct lmv_stripe_md *lsm);
@@ -517,25 +560,4 @@ static inline bool lmv_is_layout_changing(const struct lmv_mds_md_v1 *lmv)
 	       lmv_hash_is_migrating(cpu_to_le32(lmv->lmv_hash_type));
 }
 
-static inline u8 lmv_inherit_next(u8 inherit)
-{
-	if (inherit == LMV_INHERIT_END || inherit == LMV_INHERIT_NONE)
-		return LMV_INHERIT_NONE;
-
-	if (inherit == LMV_INHERIT_UNLIMITED || inherit > LMV_INHERIT_MAX)
-		return inherit;
-
-	return inherit - 1;
-}
-
-static inline u8 lmv_inherit_rr_next(u8 inherit_rr)
-{
-	if (inherit_rr == LMV_INHERIT_RR_NONE ||
-	    inherit_rr == LMV_INHERIT_RR_UNLIMITED ||
-	    inherit_rr > LMV_INHERIT_RR_MAX)
-		return inherit_rr;
-
-	return inherit_rr - 1;
-}
-
 #endif
diff --git a/fs/lustre/llite/dcache.c b/fs/lustre/llite/dcache.c
index d9fb0cdc409f..1abb134f13d2 100644
--- a/fs/lustre/llite/dcache.c
+++ b/fs/lustre/llite/dcache.c
@@ -219,8 +219,9 @@ int ll_revalidate_it_finish(struct ptlrpc_request *request,
 	ll_set_lock_data(ll_i2sbi(inode)->ll_md_exp, inode, it,
 			 &bits);
 	if (bits & MDS_INODELOCK_LOOKUP) {
-		ll_update_dir_depth(de->d_parent->d_inode, inode);
 		d_lustre_revalidate(de);
+		if (S_ISDIR(inode->i_mode))
+			ll_update_dir_depth_dmv(de->d_parent->d_inode, de);
 	}
 
 	return rc;
@@ -263,8 +264,11 @@ static int ll_revalidate_dentry(struct dentry *dentry,
 	 * to this dentry, then its lock has not been revoked and the
 	 * path component is valid.
 	 */
-	if (lookup_flags & LOOKUP_PARENT)
+	if (lookup_flags & LOOKUP_PARENT) {
+		if (dentry->d_inode && S_ISDIR(dentry->d_inode->i_mode))
+			ll_update_dir_depth_dmv(dir, dentry);
 		return 1;
+	}
 
 	/* Symlink - always valid as long as the dentry was found */
 	/* only special case is to prevent ELOOP error from VFS during open
@@ -298,6 +302,9 @@ static int ll_revalidate_dentry(struct dentry *dentry,
 	if (dentry_may_statahead(dir, dentry))
 		ll_revalidate_statahead(dir, &dentry, !d_inode(dentry));
 
+	if (dentry->d_inode && S_ISDIR(dentry->d_inode->i_mode))
+		ll_update_dir_depth_dmv(dir, dentry);
+
 	return 1;
 }
 
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 0f4dc2f1ce5e..25ea565a2f0b 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -655,6 +655,64 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 	return rc;
 }
 
+/* get default LMV from client cache */
+static int ll_dir_get_default_lmv(struct inode *inode, struct lmv_user_md *lum)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	const struct lmv_stripe_md *lsm;
+	bool fs_dmv_got = false;
+	int rc = -ENODATA;
+
+retry:
+	if (lli->lli_default_lsm_md) {
+		down_read(&lli->lli_lsm_sem);
+		lsm = lli->lli_default_lsm_md;
+		if (lsm) {
+			lum->lum_magic = lsm->lsm_md_magic;
+			lum->lum_stripe_count = lsm->lsm_md_stripe_count;
+			lum->lum_stripe_offset = lsm->lsm_md_master_mdt_index;
+			lum->lum_hash_type = lsm->lsm_md_hash_type;
+			lum->lum_max_inherit = lsm->lsm_md_max_inherit;
+			lum->lum_max_inherit_rr = lsm->lsm_md_max_inherit_rr;
+			rc = 0;
+		}
+		up_read(&lli->lli_lsm_sem);
+	}
+
+	if (rc == -ENODATA && !is_root_inode(inode) && !fs_dmv_got) {
+		lli = ll_i2info(inode->i_sb->s_root->d_inode);
+		fs_dmv_got = true;
+		goto retry;
+	}
+
+	if (!rc && fs_dmv_got) {
+		lli = ll_i2info(inode);
+		if (lum->lum_max_inherit != LMV_INHERIT_UNLIMITED) {
+			if (lum->lum_max_inherit == LMV_INHERIT_NONE ||
+			    lum->lum_max_inherit < LMV_INHERIT_END ||
+			    lum->lum_max_inherit > LMV_INHERIT_MAX ||
+			    lum->lum_max_inherit <= lli->lli_dir_depth) {
+				rc = -ENODATA;
+				goto out;
+			}
+			lum->lum_max_inherit -= lli->lli_dir_depth;
+		}
+
+		if (lum->lum_max_inherit_rr != LMV_INHERIT_RR_UNLIMITED) {
+			if (lum->lum_max_inherit_rr == LMV_INHERIT_NONE ||
+			    lum->lum_max_inherit_rr < LMV_INHERIT_RR_END ||
+			    lum->lum_max_inherit_rr > LMV_INHERIT_RR_MAX ||
+			    lum->lum_max_inherit_rr <= lli->lli_dir_depth)
+				lum->lum_max_inherit_rr = LMV_INHERIT_RR_NONE;
+
+			if (lum->lum_max_inherit_rr > lli->lli_dir_depth)
+				lum->lum_max_inherit_rr -= lli->lli_dir_depth;
+		}
+	}
+out:
+	return rc;
+}
+
 int ll_dir_get_default_layout(struct inode *inode, void **plmm, int *plmm_size,
 			      struct ptlrpc_request **request, u64 valid,
 			      enum get_default_layout_type type)
@@ -1634,7 +1692,6 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct lmv_user_md __user *ulmv = uarg;
 		struct lmv_user_md lum;
 		struct ptlrpc_request *request = NULL;
-		struct ptlrpc_request *root_request = NULL;
 		struct lmv_user_md *tmp = NULL;
 		union lmv_mds_md *lmm = NULL;
 		u64 valid = 0;
@@ -1650,6 +1707,19 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (copy_from_user(&lum, ulmv, sizeof(*ulmv)))
 			return -EFAULT;
 
+		/* get default LMV */
+		if (lum.lum_magic == LMV_USER_MAGIC &&
+		    lum.lum_type != LMV_TYPE_RAW) {
+			rc = ll_dir_get_default_lmv(inode, &lum);
+			if (rc)
+				return rc;
+
+			if (copy_to_user(ulmv, &lum, sizeof(lum)))
+				return -EFAULT;
+
+			return 0;
+		}
+
 		max_stripe_count = lum.lum_stripe_count;
 		/*
 		 * lum_magic will indicate which stripe the ioctl will like
@@ -1664,64 +1734,12 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			return -EINVAL;
 
 		rc = ll_dir_getstripe_default(inode, (void **)&lmm, &lmmsize,
-					      &request, &root_request, valid);
+					      &request, NULL, valid);
 		if (rc)
 			goto finish_req;
 
-		/* Get default LMV EA */
+		/* Get default LMV EA in raw mode */
 		if (lum.lum_magic == LMV_USER_MAGIC) {
-			struct lmv_user_md *lum;
-			struct ll_inode_info *lli;
-
-			if (lmmsize > sizeof(*ulmv)) {
-				rc = -EINVAL;
-				goto finish_req;
-			}
-
-			lum = (struct lmv_user_md *)lmm;
-			if (lum->lum_max_inherit == LMV_INHERIT_NONE) {
-				rc = -ENODATA;
-				goto finish_req;
-			}
-
-			if (root_request) {
-				lli = ll_i2info(inode);
-				if (lum->lum_max_inherit !=
-				    LMV_INHERIT_UNLIMITED) {
-					if (lum->lum_max_inherit <
-						LMV_INHERIT_END ||
-					    lum->lum_max_inherit >
-						LMV_INHERIT_MAX ||
-					    lum->lum_max_inherit <=
-						lli->lli_dir_depth) {
-						rc = -ENODATA;
-						goto finish_req;
-					}
-
-					lum->lum_max_inherit -=
-						lli->lli_dir_depth;
-				}
-
-				if (lum->lum_max_inherit_rr !=
-				    LMV_INHERIT_RR_UNLIMITED) {
-					if (lum->lum_max_inherit_rr ==
-						LMV_INHERIT_NONE ||
-					    lum->lum_max_inherit_rr <
-						LMV_INHERIT_RR_END ||
-					    lum->lum_max_inherit_rr >
-						LMV_INHERIT_RR_MAX ||
-					    lum->lum_max_inherit_rr <=
-						lli->lli_dir_depth) {
-						lum->lum_max_inherit_rr =
-							LMV_INHERIT_RR_NONE;
-						goto out_copy;
-					}
-
-					lum->lum_max_inherit_rr -=
-						lli->lli_dir_depth;
-				}
-			}
-out_copy:
 			if (copy_to_user(ulmv, lmm, lmmsize))
 				rc = -EFAULT;
 
@@ -1812,7 +1830,6 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		kfree(tmp);
 finish_req:
 		ptlrpc_req_finished(request);
-		ptlrpc_req_finished(root_request);
 		return rc;
 	}
 	case LL_IOC_RMFID:
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 7899ffdd92fb..aee529098497 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -693,10 +693,8 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 		 * of kernel will deal with that later.
 		 */
 		ll_set_lock_data(sbi->ll_md_exp, inode, itp, &bits);
-		if (bits & MDS_INODELOCK_LOOKUP) {
+		if (bits & MDS_INODELOCK_LOOKUP)
 			d_lustre_revalidate(de);
-			ll_update_dir_depth(parent->d_inode, d_inode(de));
-		}
 
 		/* if DoM bit returned along with LAYOUT bit then there
 		 * can be read-on-open data returned.
@@ -704,6 +702,11 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 		if (bits & MDS_INODELOCK_DOM && bits & MDS_INODELOCK_LAYOUT)
 			ll_dom_finish_open(inode, req);
 	}
+	/* open may not fetch LOOKUP lock, update dir depth and default LMV
+	 * anyway.
+	 */
+	if (!rc && S_ISDIR(de->d_inode->i_mode))
+		ll_update_dir_depth_dmv(parent->d_inode, de);
 
 out:
 	ptlrpc_req_finished(req);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 93743d27739c..746ef983edb8 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -196,7 +196,12 @@ struct ll_inode_info {
 			 * statahead hit ratio is too low, or start statahead
 			 * thread failed.
 			 */
-			unsigned short			lli_sa_enabled:1;
+			unsigned short			lli_sa_enabled:1,
+			/* default LMV is explicitly set in inode on MDT, this
+			 * is for old server, or default LMV is set by
+			 * "lfs setdirstripe -D".
+			 */
+							lli_default_lmv_set:1;
 			/* generation for statahead */
 			unsigned int			lli_sa_generation;
 			/* rw lock protects lli_lsm_md */
@@ -1293,7 +1298,7 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 		       u32 flags);
 int ll_update_inode(struct inode *inode, struct lustre_md *md);
 void ll_update_inode_flags(struct inode *inode, unsigned int ext_flags);
-void ll_update_dir_depth(struct inode *dir, struct inode *inode);
+void ll_update_dir_depth_dmv(struct inode *dir, struct dentry *de);
 int ll_read_inode2(struct inode *inode, void *opaque);
 void ll_truncate_inode_pages_final(struct inode *inode, struct cl_io *io);
 void ll_delete_inode(struct inode *inode);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index b158eccc16c8..afb231ecd70b 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -327,7 +327,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				   OBD_CONNECT2_DOM_LVB |
 				   OBD_CONNECT2_REP_MBITS |
 				   OBD_CONNECT2_ATOMIC_OPEN_LOCK |
-				   OBD_CONNECT2_BATCH_RPC;
+				   OBD_CONNECT2_BATCH_RPC |
+				   OBD_CONNECT2_DMV_IMP_INHERIT;
 
 	if (test_bit(LL_SBI_LRU_RESIZE, sbi->ll_flags))
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
@@ -1607,13 +1608,15 @@ static void ll_update_default_lsm_md(struct inode *inode, struct lustre_md *md)
 
 	if (!md->default_lmv) {
 		/* clear default lsm */
-		if (lli->lli_default_lsm_md) {
+		if (lli->lli_default_lsm_md && lli->lli_default_lmv_set) {
 			down_write(&lli->lli_lsm_sem);
-			if (lli->lli_default_lsm_md) {
+			if (lli->lli_default_lsm_md &&
+			    lli->lli_default_lmv_set) {
 				lmv_free_memmd(lli->lli_default_lsm_md);
 				lli->lli_default_lsm_md = NULL;
+				lli->lli_inherit_depth = 0;
+				lli->lli_default_lmv_set = 0;
 			}
-			lli->lli_inherit_depth = 0;
 			up_write(&lli->lli_lsm_sem);
 		}
 		return;
@@ -1634,6 +1637,7 @@ static void ll_update_default_lsm_md(struct inode *inode, struct lustre_md *md)
 	if (lli->lli_default_lsm_md)
 		lmv_free_memmd(lli->lli_default_lsm_md);
 	lli->lli_default_lsm_md = md->default_lmv;
+	lli->lli_default_lmv_set = 1;
 	lsm_md_dump(D_INODE, md->default_lmv);
 	md->default_lmv = NULL;
 	up_write(&lli->lli_lsm_sem);
@@ -2735,38 +2739,150 @@ static inline bool ll_default_lmv_inherited(struct lmv_stripe_md *pdmv,
 	return true;
 }
 
-/* update directory depth to ROOT, called after LOOKUP lock is fetched. */
-void ll_update_dir_depth(struct inode *dir, struct inode *inode)
+/* if default LMV is implicitly inherited, subdir default LMV is maintained on
+ * client side.
+ */
+int ll_dir_default_lmv_inherit(struct inode *dir, struct inode *inode)
 {
+	struct ll_inode_info *plli = ll_i2info(dir);
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct lmv_stripe_md *plsm;
+	struct lmv_stripe_md *lsm;
+	int rc = 0;
+
+	/* ROOT default LMV is not inherited */
+	if (is_root_inode(dir) ||
+	    !(exp_connect_flags2(ll_i2mdexp(dir)) &
+				 OBD_CONNECT2_DMV_IMP_INHERIT))
+		return 0;
+
+	/* nothing to do if no default LMV on both */
+	if (!plli->lli_default_lsm_md && !lli->lli_default_lsm_md)
+		return 0;
+
+	/* subdir default LMV comes from disk */
+	if (lli->lli_default_lsm_md && lli->lli_default_lmv_set)
+		return 0;
+
+	/* delete subdir default LMV if parent's is deleted or becomes
+	 * uninheritable.
+	 */
+	down_read(&plli->lli_lsm_sem);
+	plsm = plli->lli_default_lsm_md;
+	if (!plsm || !lmv_is_inheritable(plsm->lsm_md_max_inherit)) {
+		if (lli->lli_default_lsm_md && !lli->lli_default_lmv_set) {
+			down_write(&lli->lli_lsm_sem);
+			if (lli->lli_default_lsm_md &&
+			    !lli->lli_default_lmv_set) {
+				lmv_free_memmd(lli->lli_default_lsm_md);
+				lli->lli_default_lsm_md = NULL;
+				lli->lli_inherit_depth = 0;
+			}
+			up_write(&lli->lli_lsm_sem);
+		}
+		rc = 0;
+		goto unlock_parent;
+	}
+
+	/* do nothing if inherited LMV is unchanged */
+	if (lli->lli_default_lsm_md) {
+		rc = 1;
+		down_read(&lli->lli_lsm_sem);
+		if (!lli->lli_default_lmv_set)
+			rc = lsm_md_inherited(plsm, lli->lli_default_lsm_md);
+		up_read(&lli->lli_lsm_sem);
+		if (rc == 1) {
+			rc = 0;
+			goto unlock_parent;
+		}
+	}
+
+	/* inherit default LMV */
+	down_write(&lli->lli_lsm_sem);
+	if (lli->lli_default_lsm_md) {
+		/* checked above, but in case of race, check again with lock */
+		if (lli->lli_default_lmv_set) {
+			rc = 0;
+			goto unlock_child;
+		}
+		/* always update subdir default LMV in case parent's changed */
+		lsm = lli->lli_default_lsm_md;
+	} else {
+		lsm = kzalloc(sizeof(*lsm), GFP_NOFS);
+		if (!lsm) {
+			rc = -ENOMEM;
+			goto unlock_child;
+		}
+		lli->lli_default_lsm_md = lsm;
+	}
+
+	*lsm = *plsm;
+	lsm->lsm_md_max_inherit = lmv_inherit_next(plsm->lsm_md_max_inherit);
+	lsm->lsm_md_max_inherit_rr =
+			lmv_inherit_rr_next(plsm->lsm_md_max_inherit_rr);
+	lli->lli_inherit_depth = plli->lli_inherit_depth + 1;
+
+	lsm_md_dump(D_INODE, lsm);
+
+unlock_child:
+	up_write(&lli->lli_lsm_sem);
+unlock_parent:
+	up_read(&plli->lli_lsm_sem);
+
+	return rc;
+}
+
+/**
+ * Update directory depth and default LMV
+ *
+ * Update directory depth to ROOT and inherit default LMV from parent if
+ * parent's default LMV is inheritable. The default LMV set with command
+ * "lfs setdirstripe -D ..." is stored on MDT, while the inherited default LMV
+ * is generated at runtime on client side.
+ *
+ * \param[in]	dir	parent directory inode
+ * \param[in]	de	dentry
+ */
+void ll_update_dir_depth_dmv(struct inode *dir, struct dentry *de)
+{
+	struct inode *inode = de->d_inode;
 	struct ll_inode_info *plli;
 	struct ll_inode_info *lli;
 
-	if (!S_ISDIR(inode->i_mode))
-		return;
-
+	LASSERT(S_ISDIR(inode->i_mode));
 	if (inode == dir)
 		return;
 
 	plli = ll_i2info(dir);
 	lli = ll_i2info(inode);
 	lli->lli_dir_depth = plli->lli_dir_depth + 1;
-	if (plli->lli_default_lsm_md && lli->lli_default_lsm_md) {
-		down_read(&plli->lli_lsm_sem);
-		down_read(&lli->lli_lsm_sem);
-		if (ll_default_lmv_inherited(plli->lli_default_lsm_md,
+	if (lli->lli_default_lsm_md && lli->lli_default_lmv_set) {
+		if (plli->lli_default_lsm_md) {
+			down_read(&plli->lli_lsm_sem);
+			down_read(&lli->lli_lsm_sem);
+			if (lsm_md_inherited(plli->lli_default_lsm_md,
 					     lli->lli_default_lsm_md))
-			lli->lli_inherit_depth =
-				plli->lli_inherit_depth + 1;
-		else
+				lli->lli_inherit_depth =
+					plli->lli_inherit_depth + 1;
+			else
+				/* in case parent default LMV changed */
+				lli->lli_inherit_depth = 0;
+			up_read(&lli->lli_lsm_sem);
+			up_read(&plli->lli_lsm_sem);
+		} else {
+			/* in case parent default LMV deleted */
 			lli->lli_inherit_depth = 0;
-		up_read(&lli->lli_lsm_sem);
-		up_read(&plli->lli_lsm_sem);
+		}
 	} else {
-		lli->lli_inherit_depth = 0;
+		ll_dir_default_lmv_inherit(dir, inode);
 	}
 
-	CDEBUG(D_INODE, DFID" depth %hu default LMV depth %hu\n",
-	       PFID(&lli->lli_fid), lli->lli_dir_depth, lli->lli_inherit_depth);
+	if (lli->lli_default_lsm_md)
+		CDEBUG(D_INODE,
+		       "%s "DFID" depth %hu %s default LMV inherit depth %hu\n",
+		       de->d_name.name, PFID(&lli->lli_fid), lli->lli_dir_depth,
+		       lli->lli_default_lmv_set ? "server" : "client",
+		       lli->lli_inherit_depth);
 }
 
 void ll_truncate_inode_pages_final(struct inode *inode, struct cl_io *io)
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 85a5902b0598..657ad6fd961d 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -726,10 +726,13 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 
 	if (!it_disposition(it, DISP_LOOKUP_NEG)) {
 		/* We have the "lookup" lock, so unhide dentry */
-		if (bits & MDS_INODELOCK_LOOKUP) {
+		if (bits & MDS_INODELOCK_LOOKUP)
 			d_lustre_revalidate(*de);
-			ll_update_dir_depth(parent, d_inode(*de));
-		}
+		/* open may not fetch LOOKUP lock, update dir depth/dmv anyway
+		 * in case it's used uninitialized.
+		 */
+		if (S_ISDIR(inode->i_mode))
+			ll_update_dir_depth_dmv(parent, *de);
 
 		if (encrypt) {
 			rc = fscrypt_get_encryption_info(inode);
@@ -1424,10 +1427,11 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 	ll_set_lock_data(ll_i2sbi(dir)->ll_md_exp, inode, it, &bits);
 	if (bits & MDS_INODELOCK_LOOKUP) {
 		d_lustre_revalidate(dentry);
-		ll_update_dir_depth(dir, inode);
+		if (S_ISDIR(inode->i_mode))
+			ll_update_dir_depth_dmv(dir, dentry);
 	}
 
-	return rc;
+	return 0;
 }
 
 void ll_update_times(struct ptlrpc_request *request, struct inode *inode)
@@ -1517,6 +1521,9 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 	struct ll_sb_info *sbi = ll_i2sbi(dir);
 	struct fscrypt_str *disk_link = NULL;
 	bool encrypt = false;
+	struct lmv_user_md *lum = NULL;
+	const void *data = NULL;
+	size_t datalen = 0;
 	int err;
 
 	if (unlikely(tgt)) {
@@ -1524,6 +1531,8 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 		rdev = 0;
 		if (!disk_link)
 			return -EINVAL;
+		data = disk_link->name;
+		datalen = disk_link->len;
 	}
 
 again:
@@ -1534,8 +1543,37 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 		goto err_exit;
 	}
 
-	if (S_ISDIR(mode))
+	if (S_ISDIR(mode)) {
 		ll_qos_mkdir_prep(op_data, dir);
+		if ((exp_connect_flags2(ll_i2mdexp(dir)) &
+		     OBD_CONNECT2_DMV_IMP_INHERIT) &&
+		    op_data->op_default_mea1 && !lum) {
+			const struct lmv_stripe_md *lsm;
+
+			/* once DMV_IMP_INHERIT is set, pack default LMV in
+			 * create request.
+			 */
+			lum = kzalloc(sizeof(*lum), GFP_NOFS);
+			if (!lum) {
+				err = -ENOMEM;
+				goto err_exit;
+			}
+			lsm = op_data->op_default_mea1;
+			lum->lum_magic = cpu_to_le32(lsm->lsm_md_magic);
+			lum->lum_stripe_count =
+				cpu_to_le32(lsm->lsm_md_stripe_count);
+			lum->lum_stripe_offset =
+				cpu_to_le32(lsm->lsm_md_master_mdt_index);
+			lum->lum_hash_type =
+				cpu_to_le32(lsm->lsm_md_hash_type);
+			lum->lum_max_inherit = lsm->lsm_md_max_inherit;
+			lum->lum_max_inherit_rr = lsm->lsm_md_max_inherit_rr;
+			lum->lum_pool_name[0] = 0;
+			op_data->op_bias |= MDS_CREATE_DEFAULT_LMV;
+			data = lum;
+			datalen = sizeof(*lum);
+		}
+	}
 
 	if (test_bit(LL_SBI_FILE_SECCTX, sbi->ll_flags)) {
 		err = ll_dentry_init_security(dchild, mode, &dchild->d_name,
@@ -1596,11 +1634,13 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 			dchild->d_sb->s_op->destroy_inode(fakeinode);
 			if (err)
 				goto err_exit;
+
+			data = disk_link->name;
+			datalen = disk_link->len;
 		}
 	}
 
-	err = md_create(sbi->ll_md_exp, op_data, tgt ? disk_link->name : NULL,
-			tgt ? disk_link->len : 0, mode,
+	err = md_create(sbi->ll_md_exp, op_data, data, datalen, mode,
 			from_kuid(&init_user_ns, current_fsuid()),
 			from_kgid(&init_user_ns, current_fsgid()),
 			current_cap(), rdev, &request);
@@ -1727,9 +1767,9 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 err_exit:
 	if (request)
 		ptlrpc_req_finished(request);
-
 	if (!IS_ERR_OR_NULL(op_data))
 		ll_finish_md_op_data(op_data);
+	kfree(lum);
 
 	return err;
 }
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index c820455cc3af..9399b676e582 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -1612,10 +1612,10 @@ static int revalidate_statahead_dentry(struct inode *dir,
 				goto out_unplug;
 			}
 
-			if ((bits & MDS_INODELOCK_LOOKUP) &&
-			    d_lustre_invalid(*dentryp)) {
+			if (bits & MDS_INODELOCK_LOOKUP) {
 				d_lustre_revalidate(*dentryp);
-				ll_update_dir_depth(dir, (*dentryp)->d_inode);
+				if (S_ISDIR(inode->i_mode))
+					ll_update_dir_depth_dmv(dir, *dentryp);
 			}
 
 			ll_intent_release(&it);
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index 077639d5127c..a0d35f0b4932 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -219,6 +219,13 @@ void mdc_create_pack(struct req_capsule *pill, struct md_op_data *op_data,
 		 * create only, and don't restripe if object exists.
 		 */
 		flags |= MDS_OPEN_CREAT;
+	if (op_data->op_bias & MDS_CREATE_DEFAULT_LMV) {
+		/* borrow MDS_OPEN_DEFAULT_LMV flag to indicate parent default
+		 * LMV is packed in create request.
+		 */
+		flags |= MDS_OPEN_DEFAULT_LMV;
+		LASSERT(data);
+	}
 	set_mrc_cr_flags(rec, flags);
 	rec->cr_bias = op_data->op_bias;
 	rec->cr_umask = current_umask();
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 0d669f4dde15..bde287bbb793 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -138,7 +138,7 @@ static const char *const obd_connect_names[] = {
 	"atomic_open_lock",		/* 0x4000000 */
 	"name_encryption",		/* 0x8000000 */
 	"mkdir_replay",			/* 0x10000000 */
-	"dmv_inherit",			/* 0x20000000 */
+	"dmv_imp_inherit",		/* 0x20000000 */
 	"encryption_fid2path",		/* 0x40000000 */
 	NULL
 };
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 45adb33a9c56..8cec6a35c692 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -2164,6 +2164,8 @@ void lustre_assert_wire_constants(void)
 		(unsigned int)MDS_FID_OP);
 	LASSERTF(MDS_MIGRATE_NSONLY == 0x00800000UL, "found 0x%.8xUL\n",
 		(unsigned int)MDS_MIGRATE_NSONLY);
+	LASSERTF(MDS_CREATE_DEFAULT_LMV == 0x01000000UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_CREATE_DEFAULT_LMV);
 
 	/* Checks for struct mdt_body */
 	LASSERTF((int)sizeof(struct mdt_body) == 216, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 187a807d4809..2a7299e6ce46 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1702,6 +1702,8 @@ enum mds_op_bias {
 	MDS_FID_OP		= 1 << 22,
 	/* migrate dirent only */
 	MDS_MIGRATE_NSONLY	= 1 << 23,
+	/* create with default LMV from client */
+	MDS_CREATE_DEFAULT_LMV	= 1 << 24,
 };
 
 #define MDS_CLOSE_INTENT (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP |         \
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 4b49bb9c370a..397d93705d98 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -901,6 +901,8 @@ static inline __u32 lmv_foreign_to_md_stripes(__u32 size)
  */
 enum lmv_type {
 	LMV_TYPE_DEFAULT = 0x0000,
+	/* fetch raw default LMV set on directory inode */
+	LMV_TYPE_RAW	 = 0x0001,
 };
 
 /* lum_max_inherit will be decreased by 1 after each inheritance if it's not
@@ -1303,7 +1305,9 @@ enum la_valid {
 					      * for newly created file
 					      */
 #define MDS_OP_WITH_FID	  020000000000000ULL /* operation carried out by FID */
-#define MDS_OPEN_DEFAULT_LMV  040000000000000ULL /* open fetches default LMV */
+#define MDS_OPEN_DEFAULT_LMV  040000000000000ULL /* open fetches default LMV,
+						  * or mkdir with default LMV
+						  */
 
 /* lustre internal open flags, which should not be set from user space */
 #define MDS_OPEN_FL_INTERNAL (MDS_OPEN_HAS_EA | MDS_OPEN_HAS_OBJS |	\
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
