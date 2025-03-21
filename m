Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A0D52C36001
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:20:04 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2pj4bM9z1yCh;
	Fri, 21 Mar 2025 06:09:33 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2mR3tMtz1xdm
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:07:35 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 6C36088F9D7;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 68FC6106BE17; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:51 -0400
Message-ID: <20250321130711.3257092-9-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 08/27] lustre: llite: call
 truncate_inode_pages() in inode lock
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Bobi Jam <bobijam@whamcloud.com>

In some cases vvp_prune()->truncate_inode_pages() is get called
without IO context, we need protect it with inode lock as well.

So we add ll_inode_info::lli_inode_lock_owner and set it according to
vfs lock rules (Documentation/filesystems/Locking or
Documentation/filesystems/locking.rst), so before calling
truncate_inode_pages(), we'd lock the inode if it's not locked in
vfs.

Fixes: 7ce53b7f2e ("lustre: llite: call truncate_inode_pages() under inode lock")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16637
Lustre-commit: 51d62f2122fee14fb ("LU-16637 llite: call truncate_inode_pages() in inode lock")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50857
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h    |  14 +++
 fs/lustre/llite/dir.c            |   4 +-
 fs/lustre/llite/file.c           |  18 ++--
 fs/lustre/llite/llite_internal.h |  39 +++++++-
 fs/lustre/llite/llite_lib.c      |  42 ++++++---
 fs/lustre/llite/llite_nfs.c      |   4 +-
 fs/lustre/llite/namei.c          | 151 ++++++++++++++++++++++++-------
 fs/lustre/llite/vvp_io.c         |   8 +-
 fs/lustre/llite/vvp_object.c     |  57 ++++++++++--
 fs/lustre/llite/xattr.c          |  52 +++++++----
 fs/lustre/lov/lov_object.c       |  58 ++++++++++--
 fs/lustre/obdclass/cl_object.c   |  17 ++++
 12 files changed, 369 insertions(+), 95 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 9871b695a4fb..9b90a2c4d2ba 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -297,6 +297,13 @@ struct cl_layout {
 	bool			cl_is_released;
 };
 
+enum coo_inode_opc {
+	COIO_INODE_LOCK,
+	COIO_INODE_UNLOCK,
+	COIO_SIZE_LOCK,
+	COIO_SIZE_UNLOCK,
+};
+
 /**
  * Operations implemented for each cl object layer.
  *
@@ -424,6 +431,11 @@ struct cl_object_operations {
 	int (*coo_object_flush)(const struct lu_env *env,
 				struct cl_object *obj,
 				struct ldlm_lock *lock);
+	/**
+	 * operate upon inode. Used in LOV to lock/unlock inode from vvp layer.
+	 */
+	int (*coo_inode_ops)(const struct lu_env *env, struct cl_object *obj,
+			     enum coo_inode_opc opc, void *data);
 };
 
 /**
@@ -2150,6 +2162,8 @@ int cl_object_layout_get(const struct lu_env *env, struct cl_object *obj,
 loff_t cl_object_maxbytes(struct cl_object *obj);
 int cl_object_flush(const struct lu_env *env, struct cl_object *obj,
 		    struct ldlm_lock *lock);
+int cl_object_inode_ops(const struct lu_env *env, struct cl_object *obj,
+			enum coo_inode_opc opc, void *data);
 
 
 /**
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 93f8a27aace3..a7a419abf45a 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -2307,7 +2307,7 @@ static loff_t ll_dir_seek(struct file *file, loff_t offset, int origin)
 	bool api32 = ll_need_32bit_api(sbi);
 	loff_t ret = -EINVAL;
 
-	inode_lock(inode);
+	ll_inode_lock(inode);
 	switch (origin) {
 	case SEEK_SET:
 		break;
@@ -2347,7 +2347,7 @@ static loff_t ll_dir_seek(struct file *file, loff_t offset, int origin)
 	}
 
 out:
-	inode_unlock(inode);
+	ll_inode_unlock(inode);
 	return ret;
 }
 
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index aee529098497..448aea7ceb12 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2194,11 +2194,11 @@ static ssize_t ll_do_tiny_write(struct kiocb *iocb, struct iov_iter *iter)
 		return 0;
 
 	if (unlikely(lock_inode))
-		inode_lock(inode);
+		ll_inode_lock(inode);
 	result = __generic_file_write_iter(iocb, iter);
 
 	if (unlikely(lock_inode))
-		inode_unlock(inode);
+		ll_inode_unlock(inode);
 
 	/* If the page is not already dirty, ll_tiny_write_begin returns
 	 * -ENODATA.  We continue on to normal write.
@@ -2918,9 +2918,9 @@ static int fid2path_for_enc_file(struct inode *parent, char *gfpath,
 		if (enckey == 0 || nameenc == 0)
 			continue;
 
-		inode_lock(parent);
+		ll_inode_lock(parent);
 		de = lookup_one_len(p, de_parent, len);
-		inode_unlock(parent);
+		ll_inode_unlock(parent);
 		if (IS_ERR_OR_NULL(de) || !de->d_inode) {
 			dput(de_parent);
 			rc = -ENODATA;
@@ -3344,6 +3344,7 @@ static int ll_hsm_import(struct inode *inode, struct file *file,
 
 	inode_lock(inode);
 
+	/* inode lock owner set in ll_setattr_raw() */
 	rc = ll_setattr_raw(file->f_path.dentry, attr, 0, true);
 	if (rc == -ENODATA)
 		rc = 0;
@@ -3391,6 +3392,7 @@ static int ll_file_futimes_3(struct file *file, const struct ll_futimes_3 *lfu)
 		return -EINVAL;
 
 	inode_lock(inode);
+	/* inode lock owner set in ll_setattr_raw()*/
 	rc = ll_setattr_raw(file_dentry(file), &ia, OP_XVALID_CTIME_SET,
 			    false);
 	inode_unlock(inode);
@@ -3783,10 +3785,10 @@ int ll_ioctl_project(struct file *file, unsigned int cmd, void __user *uarg)
 	/* apply child dentry if name is valid */
 	name_len = strnlen(lu_project.project_name, NAME_MAX);
 	if (name_len > 0 && name_len <= NAME_MAX) {
-		inode_lock(inode);
+		ll_inode_lock(inode);
 		child_dentry = lookup_one_len(lu_project.project_name,
 					      dentry, name_len);
-		inode_unlock(inode);
+		ll_inode_unlock(inode);
 		if (IS_ERR(child_dentry)) {
 			rc = PTR_ERR(child_dentry);
 			goto out;
@@ -5021,7 +5023,7 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 		goto out_iput;
 	}
 
-	inode_lock(child_inode);
+	ll_inode_lock(child_inode);
 	op_data->op_fid3 = *ll_inode2fid(child_inode);
 	if (!fid_is_sane(&op_data->op_fid3)) {
 		CERROR("%s: migrate %s, but fid " DFID " is insane\n",
@@ -5105,7 +5107,7 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 	if (!rc)
 		clear_nlink(child_inode);
 out_unlock:
-	inode_unlock(child_inode);
+	ll_inode_unlock(child_inode);
 	ll_finish_md_op_data(op_data);
 out_iput:
 	iput(child_inode);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index ddcd88ed948d..755fdae77709 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -94,7 +94,7 @@ struct ll_grouplock {
 	unsigned long	 lg_gid;
 };
 
-enum ll_file_flags {
+enum ll_inode_flags {
 	/* File data is modified. */
 	LLIF_DATA_MODIFIED	= 0,
 	/* File is being restored */
@@ -109,6 +109,7 @@ enum ll_file_flags {
 	LLIF_UPDATE_ATIME	= 4,
 	/* foreign file/dir can be unlinked unconditionnaly */
 	LLIF_FOREIGN_REMOVABLE	= 5,
+	/* 6 is not used for now */
 	/* Xattr cache is filled */
 	LLIF_XATTR_CACHE_FILLED	= 7,
 };
@@ -215,7 +216,8 @@ struct ll_inode_info {
 		/* for non-directory */
 		struct {
 			struct mutex			lli_size_mutex;
-			char			       *lli_symlink_name;
+			struct task_struct		*lli_size_lock_owner;
+			char				*lli_symlink_name;
 			struct ll_trunc_sem		lli_trunc_sem;
 			struct range_lock_tree		lli_write_tree;
 			struct mutex			lli_setattr_mutex;
@@ -300,6 +302,8 @@ struct ll_inode_info {
 	struct list_head		lli_xattrs; /* ll_xattr_entry->xe_list */
 	struct list_head		lli_lccs; /* list of ll_cl_context */
 	seqlock_t			lli_page_inv_lock;
+
+	struct task_struct		*lli_inode_lock_owner;
 };
 
 static inline void ll_trunc_sem_init(struct ll_trunc_sem *sem)
@@ -566,6 +570,35 @@ static inline struct pcc_inode *ll_i2pcci(struct inode *inode)
 	return ll_i2info(inode)->lli_pcc_inode;
 }
 
+static inline void ll_set_inode_lock_owner(struct inode *inode)
+{
+	ll_i2info(inode)->lli_inode_lock_owner = current;
+}
+
+static inline void ll_clear_inode_lock_owner(struct inode *inode)
+{
+	ll_i2info(inode)->lli_inode_lock_owner = NULL;
+}
+
+static inline struct task_struct *ll_get_inode_lock_owner(struct inode *inode)
+{
+	return ll_i2info(inode)->lli_inode_lock_owner;
+}
+
+/* lock inode and set inode lock owener */
+static inline void ll_inode_lock(struct inode *inode)
+{
+	inode_lock(inode);
+	ll_set_inode_lock_owner(inode);
+}
+
+/* clear inode lock owner and unlock it */
+static inline void ll_inode_unlock(struct inode *inode)
+{
+	ll_clear_inode_lock_owner(inode);
+	inode_unlock(inode);
+}
+
 /* default to use at least 16M for fast read if possible */
 #define RA_REMAIN_WINDOW_MIN			MiB_TO_PAGES(16UL)
 
@@ -1294,7 +1327,7 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md);
 void ll_update_inode_flags(struct inode *inode, unsigned int ext_flags);
 void ll_update_dir_depth_dmv(struct inode *dir, struct dentry *de);
 int ll_read_inode2(struct inode *inode, void *opaque);
-void ll_truncate_inode_pages_final(struct inode *inode, struct cl_io *io);
+void ll_truncate_inode_pages_final(struct inode *inode);
 void ll_delete_inode(struct inode *inode);
 int ll_iocontrol(struct inode *inode, struct file *file,
 		 unsigned int cmd, void __user *uarg);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 99b2982fa322..9adb7ef4ffac 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1225,6 +1225,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 	/* ll_cl_context initialize */
 	INIT_LIST_HEAD(&lli->lli_lccs);
 	seqlock_init(&lli->lli_page_inv_lock);
+	lli->lli_inode_lock_owner = NULL;
 }
 
 int ll_fill_super(struct super_block *sb)
@@ -1865,10 +1866,10 @@ static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data)
 	 */
 	op_data->op_attr.ia_valid &= ~(TIMES_SET_FLAGS | ATTR_SIZE);
 	if (S_ISREG(inode->i_mode))
-		inode_lock(inode);
+		ll_inode_lock(inode);
 	rc = simple_setattr(dentry, &op_data->op_attr);
 	if (S_ISREG(inode->i_mode))
-		inode_unlock(inode);
+		ll_inode_unlock(inode);
 	op_data->op_attr.ia_valid = ia_valid;
 
 	rc = ll_update_inode(inode, &md);
@@ -2099,6 +2100,9 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 	ktime_t kstart = ktime_get();
 	int rc = 0;
 
+	/* VFS has locked the inode before calling this */
+	ll_set_inode_lock_owner(inode);
+
 	CDEBUG(D_VFSTRACE, "%s: setattr inode " DFID "(%p) from %llu to %llu, valid %x, hsm_import %d\n",
 	       ll_i2sbi(inode)->ll_fsname, PFID(&lli->lli_fid), inode,
 	       i_size_read(inode), attr->ia_size, attr->ia_valid, hsm_import);
@@ -2107,7 +2111,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 		/* Check new size against VFS/VM file size limit and rlimit */
 		rc = inode_newsize_ok(inode, attr->ia_size);
 		if (rc)
-			return rc;
+			goto clear;
 
 		/* The maximum Lustre file size is variable, based on the
 		 * OST maximum object size and number of stripes.  This
@@ -2117,7 +2121,8 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 			CDEBUG(D_INODE, "file " DFID " too large %llu > %llu\n",
 			       PFID(&lli->lli_fid), attr->ia_size,
 			       ll_file_maxbytes(inode));
-			return -EFBIG;
+			rc = -EFBIG;
+			goto clear;
 		}
 
 		attr->ia_valid |= ATTR_MTIME | ATTR_CTIME;
@@ -2126,8 +2131,10 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 	/* POSIX: check before ATTR_*TIME_SET set (from setattr_prepare) */
 	if (attr->ia_valid & TIMES_SET_FLAGS) {
 		if ((!uid_eq(current_fsuid(), inode->i_uid)) &&
-		    !capable(CAP_FOWNER))
-			return -EPERM;
+		    !capable(CAP_FOWNER)) {
+			rc = -EPERM;
+			goto clear;
+		}
 	}
 
 	/* We mark all of the fields "set" so MDS/OST does not re-set them */
@@ -2153,7 +2160,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 		       (s64)ktime_get_real_seconds());
 
 	if (S_ISREG(inode->i_mode))
-		inode_unlock(inode);
+		ll_inode_unlock(inode);
 
 	/*
 	 * We always do an MDS RPC, even if we're only changing the size;
@@ -2339,7 +2346,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 		ll_finish_md_op_data(op_data);
 
 	if (S_ISREG(inode->i_mode)) {
-		inode_lock(inode);
+		ll_inode_lock(inode);
 		if ((attr->ia_valid & ATTR_SIZE) && !hsm_import)
 			inode_dio_wait(inode);
 		/* Once we've got the i_mutex, it's safe to set the S_NOSEC
@@ -2355,6 +2362,8 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 		ll_stats_ops_tally(ll_i2sbi(inode), attr->ia_valid & ATTR_SIZE ?
 					LPROC_LL_TRUNC : LPROC_LL_SETATTR,
 				   ktime_us_delta(ktime_get(), kstart));
+clear:
+	ll_clear_inode_lock_owner(inode);
 
 	return rc;
 }
@@ -2553,6 +2562,7 @@ void ll_inode_size_lock(struct inode *inode)
 
 	lli = ll_i2info(inode);
 	mutex_lock(&lli->lli_size_mutex);
+	lli->lli_size_lock_owner = current;
 }
 
 void ll_inode_size_unlock(struct inode *inode)
@@ -2560,6 +2570,7 @@ void ll_inode_size_unlock(struct inode *inode)
 	struct ll_inode_info *lli;
 
 	lli = ll_i2info(inode);
+	lli->lli_size_lock_owner = NULL;
 	mutex_unlock(&lli->lli_size_mutex);
 }
 
@@ -2890,14 +2901,16 @@ void ll_update_dir_depth_dmv(struct inode *dir, struct dentry *de)
 		       lli->lli_inherit_depth);
 }
 
-void ll_truncate_inode_pages_final(struct inode *inode, struct cl_io *io)
+void ll_truncate_inode_pages_final(struct inode *inode)
 {
 	struct address_space *mapping = &inode->i_data;
 	unsigned long nrpages;
 	unsigned long flags;
 
-	LASSERTF(io == NULL || inode_is_locked(inode), "io %p (type %d)\n",
-		 io, io ? io->ci_type : 0);
+	LASSERTF((inode->i_state & I_FREEING) || inode_is_locked(inode),
+		 DFID ":inode %p state %#lx, lli_flags %#lx\n",
+		 PFID(ll_inode2fid(inode)), inode, inode->i_state,
+		 ll_i2info(inode)->lli_flags);
 
 	truncate_inode_pages_final(mapping);
 
@@ -2915,10 +2928,11 @@ void ll_truncate_inode_pages_final(struct inode *inode, struct cl_io *io)
 		xa_unlock_irqrestore(&mapping->i_pages, flags);
 	} /* Workaround end */
 
-	LASSERTF(nrpages == 0, "%s: inode="DFID"(%p) nrpages=%lu io %p (io_type %d), see https://jira.whamcloud.com/browse/LU-118\n",
+	LASSERTF(nrpages == 0,
+		 "%s: inode="DFID"(%p) nrpages=%lu state %#lx, lli_flags %#lx, see https://jira.whamcloud.com/browse/LU-118\n",
 		 ll_i2sbi(inode)->ll_fsname,
 		 PFID(ll_inode2fid(inode)), inode, nrpages,
-		 io, io  ? io->ci_type : 0);
+		 inode->i_state, ll_i2info(inode)->lli_flags);
 }
 
 int ll_read_inode2(struct inode *inode, void *opaque)
@@ -2982,7 +2996,7 @@ void ll_delete_inode(struct inode *inode)
 				   CL_FSYNC_LOCAL : CL_FSYNC_DISCARD, 1);
 	}
 
-	ll_truncate_inode_pages_final(inode, NULL);
+	ll_truncate_inode_pages_final(inode);
 	ll_clear_inode(inode);
 	clear_inode(inode);
 }
diff --git a/fs/lustre/llite/llite_nfs.c b/fs/lustre/llite/llite_nfs.c
index d505c206a62e..1fd74a11709e 100644
--- a/fs/lustre/llite/llite_nfs.c
+++ b/fs/lustre/llite/llite_nfs.c
@@ -219,9 +219,9 @@ static int ll_get_name(struct dentry *dentry, char *name,
 		goto out;
 	}
 
-	inode_lock(dir);
+	ll_inode_lock(dir);
 	rc = ll_dir_read(dir, &pos, op_data, &lgd.ctx, NULL);
-	inode_unlock(dir);
+	ll_inode_unlock(dir);
 	ll_finish_md_op_data(op_data);
 	if (!rc && !lgd.lgd_found)
 		rc = -ENOENT;
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 657ad6fd961d..6159f8975847 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1098,7 +1098,10 @@ static struct dentry *ll_lookup_nd(struct inode *parent, struct dentry *dentry,
 				   unsigned int flags)
 {
 	struct lookup_intent *itp, it = { .it_op = IT_GETATTR };
-	struct dentry *de;
+	struct dentry *de = NULL;
+
+	/* VFS has locked the inode before calling this */
+	ll_set_inode_lock_owner(parent);
 
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p),flags=%u\n",
 	       dentry, PFID(ll_inode2fid(parent)), parent, flags);
@@ -1109,7 +1112,7 @@ static struct dentry *ll_lookup_nd(struct inode *parent, struct dentry *dentry,
 	 */
 	if ((flags & LOOKUP_CREATE) && !(flags & LOOKUP_OPEN) &&
 	    (inode_permission(parent, MAY_WRITE | MAY_EXEC) == 0))
-		return NULL;
+		goto clear;
 
 	if (flags & (LOOKUP_PARENT | LOOKUP_OPEN | LOOKUP_CREATE))
 		itp = NULL;
@@ -1121,6 +1124,9 @@ static struct dentry *ll_lookup_nd(struct inode *parent, struct dentry *dentry,
 	if (itp)
 		ll_intent_release(itp);
 
+clear:
+	ll_clear_inode_lock_owner(parent);
+
 	return de;
 }
 
@@ -1144,6 +1150,9 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	int open_threshold;
 	int rc = 0;
 
+	/* VFS has locked the inode before calling this */
+	ll_set_inode_lock_owner(dir);
+
 	CDEBUG(D_VFSTRACE,
 	       "VFS Op:name=%pd, dir=" DFID "(%p), file %p, open_flags %x, mode %x\n",
 	       dentry, PFID(ll_inode2fid(dir)), dir, file, open_flags, mode);
@@ -1157,8 +1166,10 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 		 * even though there's a minuscle chance it might succeed.
 		 * Either way it's a valid race to just return -ENOENT here.
 		 */
-		if (!(open_flags & O_CREAT))
-			return -ENOENT;
+		if (!(open_flags & O_CREAT)) {
+			rc = -ENOENT;
+			goto clear;
+		}
 
 		/* Otherwise we just unhash it to be rehashed afresh via
 		 * lookup if necessary
@@ -1167,8 +1178,10 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	}
 
 	it = kzalloc(sizeof(*it), GFP_NOFS);
-	if (!it)
-		return -ENOMEM;
+	if (!it) {
+		rc = -ENOMEM;
+		goto clear;
+	}
 
 	it->it_op = IT_OPEN;
 	if (open_flags & O_CREAT) {
@@ -1319,6 +1332,8 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 out_release:
 	ll_intent_release(it);
 	kfree(it);
+clear:
+	ll_clear_inode_lock_owner(dir);
 
 	return rc;
 }
@@ -1780,6 +1795,9 @@ static int ll_mknod(struct inode *dir, struct dentry *dchild,
 	ktime_t kstart = ktime_get();
 	int err;
 
+	/* VFS has locked the inode before calling this */
+	ll_set_inode_lock_owner(dir);
+
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p) mode %o dev %x\n",
 	       dchild, PFID(ll_inode2fid(dir)), dir, mode,
 	       old_encode_dev(rdev));
@@ -1811,6 +1829,7 @@ static int ll_mknod(struct inode *dir, struct dentry *dchild,
 	if (!err)
 		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_MKNOD,
 				   ktime_us_delta(ktime_get(), kstart));
+	ll_clear_inode_lock_owner(dir);
 
 	return err;
 }
@@ -1824,6 +1843,9 @@ static int ll_create_nd(struct inode *dir, struct dentry *dentry,
 	ktime_t kstart = ktime_get();
 	int rc;
 
+	/* VFS has locked the inode before calling this */
+	ll_set_inode_lock_owner(dir);
+
 	CFS_FAIL_TIMEOUT(OBD_FAIL_LLITE_CREATE_FILE_PAUSE, cfs_fail_val);
 
 	CDEBUG(D_VFSTRACE,
@@ -1839,6 +1861,8 @@ static int ll_create_nd(struct inode *dir, struct dentry *dentry,
 		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_CREATE,
 				   ktime_us_delta(ktime_get(), kstart));
 
+	ll_clear_inode_lock_owner(dir);
+
 	return rc;
 }
 
@@ -1850,19 +1874,27 @@ static int ll_unlink(struct inode *dir, struct dentry *dchild)
 	ktime_t kstart = ktime_get();
 	int rc;
 
+	/* VFS has locked the inodes before calling this */
+	ll_set_inode_lock_owner(dir);
+	ll_set_inode_lock_owner(dchild->d_inode);
+
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd,dir=%lu/%u(%p)\n",
 	       dchild, dir->i_ino, dir->i_generation, dir);
 
 	/* some foreign file/dir may not be allowed to be unlinked */
-	if (!ll_foreign_is_removable(dchild, false))
-		return -EPERM;
+	if (!ll_foreign_is_removable(dchild, false)) {
+		rc = -EPERM;
+		goto clear;
+	}
 
 	op_data = ll_prep_md_op_data(NULL, dir, NULL,
 				     dchild->d_name.name,
 				     dchild->d_name.len,
 				     0, LUSTRE_OPC_ANY, NULL);
-	if (IS_ERR(op_data))
-		return PTR_ERR(op_data);
+	if (IS_ERR(op_data)) {
+		rc = PTR_ERR(op_data);
+		goto clear;
+	}
 
 	op_data->op_fid3 = *ll_inode2fid(dchild->d_inode);
 	/* notify lower layer if inode has dirty pages */
@@ -1889,11 +1921,15 @@ static int ll_unlink(struct inode *dir, struct dentry *dchild)
 	}
 
 	ll_update_times(request, dir);
-	ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_UNLINK,
+out:
+	ptlrpc_req_finished(request);
+	if (!rc)
+		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_UNLINK,
 				   ktime_us_delta(ktime_get(), kstart));
+clear:
+	ll_clear_inode_lock_owner(dir);
+	ll_clear_inode_lock_owner(dchild->d_inode);
 
- out:
-	ptlrpc_req_finished(request);
 	return rc;
 }
 
@@ -1902,6 +1938,9 @@ static int ll_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 	ktime_t kstart = ktime_get();
 	int err;
 
+	/* VFS has locked the inode before calling this */
+	ll_set_inode_lock_owner(dir);
+
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir" DFID "(%p)\n",
 	       dentry, PFID(ll_inode2fid(dir)), dir);
 
@@ -1914,6 +1953,8 @@ static int ll_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_MKDIR,
 				   ktime_us_delta(ktime_get(), kstart));
 
+	ll_clear_inode_lock_owner(dir);
+
 	return err;
 }
 
@@ -1924,19 +1965,27 @@ static int ll_rmdir(struct inode *dir, struct dentry *dchild)
 	struct md_op_data *op_data;
 	int rc;
 
+	/* VFS has locked the inodes before calling this */
+	ll_set_inode_lock_owner(dir);
+	ll_set_inode_lock_owner(dchild->d_inode);
+
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p)\n",
 	       dchild, PFID(ll_inode2fid(dir)), dir);
 
 	/* some foreign dir may not be allowed to be removed */
-	if (!ll_foreign_is_removable(dchild, false))
-		return -EPERM;
+	if (!ll_foreign_is_removable(dchild, false)) {
+		rc = -EPERM;
+		goto out;
+	}
 
 	op_data = ll_prep_md_op_data(NULL, dir, NULL,
 				     dchild->d_name.name,
 				     dchild->d_name.len,
 				     S_IFDIR, LUSTRE_OPC_ANY, NULL);
-	if (IS_ERR(op_data))
-		return PTR_ERR(op_data);
+	if (IS_ERR(op_data)) {
+		rc = PTR_ERR(op_data);
+		goto out;
+	}
 
 	if (dchild->d_inode)
 		op_data->op_fid3 = *ll_inode2fid(dchild->d_inode);
@@ -1965,6 +2014,9 @@ static int ll_rmdir(struct inode *dir, struct dentry *dchild)
 	}
 
 	ptlrpc_req_finished(request);
+out:
+	ll_clear_inode_lock_owner(dir);
+	ll_clear_inode_lock_owner(dchild->d_inode);
 
 	return rc;
 }
@@ -1977,13 +2029,16 @@ static int ll_symlink(struct inode *dir, struct dentry *dchild,
 	struct fscrypt_str disk_link;
 	int err;
 
+	/* VFS has locked the inode before calling this */
+	ll_set_inode_lock_owner(dir);
+
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p),target=%.*s\n",
 	       dchild, PFID(ll_inode2fid(dir)), dir, 3000, oldpath);
 
 	err = fscrypt_prepare_symlink(dir, oldpath, len, dir->i_sb->s_blocksize,
 				      &disk_link);
 	if (err)
-		return err;
+		goto out;
 
 	err = ll_new_node(dir, dchild, oldpath, S_IFLNK | 0777,
 			  (u64)&disk_link, LUSTRE_OPC_SYMLINK);
@@ -1994,6 +2049,8 @@ static int ll_symlink(struct inode *dir, struct dentry *dchild,
 	if (!err)
 		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_SYMLINK,
 				   ktime_us_delta(ktime_get(), kstart));
+out:
+	ll_clear_inode_lock_owner(dir);
 
 	return err;
 }
@@ -2008,6 +2065,10 @@ static int ll_link(struct dentry *old_dentry, struct inode *dir,
 	ktime_t kstart = ktime_get();
 	int err;
 
+	/* VFS has locked the inodes before calling this */
+	ll_set_inode_lock_owner(src);
+	ll_set_inode_lock_owner(dir);
+
 	CDEBUG(D_VFSTRACE,
 	       "VFS Op: inode=" DFID "(%p), dir=" DFID "(%p), target=%pd\n",
 	       PFID(ll_inode2fid(src)), src, PFID(ll_inode2fid(dir)), dir,
@@ -2015,13 +2076,15 @@ static int ll_link(struct dentry *old_dentry, struct inode *dir,
 
 	err = fscrypt_prepare_link(old_dentry, dir, new_dentry);
 	if (err)
-		return err;
+		goto clear;
 
 	op_data = ll_prep_md_op_data(NULL, src, dir, new_dentry->d_name.name,
 				     new_dentry->d_name.len,
 				     0, LUSTRE_OPC_ANY, NULL);
-	if (IS_ERR(op_data))
-		return PTR_ERR(op_data);
+	if (IS_ERR(op_data)) {
+		err = PTR_ERR(op_data);
+		goto clear;
+	}
 
 	err = md_link(sbi->ll_md_exp, op_data, &request);
 	ll_finish_md_op_data(op_data);
@@ -2033,6 +2096,10 @@ static int ll_link(struct dentry *old_dentry, struct inode *dir,
 			   ktime_us_delta(ktime_get(), kstart));
 out:
 	ptlrpc_req_finished(request);
+clear:
+	ll_clear_inode_lock_owner(src);
+	ll_clear_inode_lock_owner(dir);
+
 	return err;
 }
 
@@ -2048,25 +2115,38 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 	umode_t mode = 0;
 	int err;
 
-	if (flags)
-		return -EINVAL;
+	/* VFS has locked the inodes before calling this */
+	ll_set_inode_lock_owner(src);
+	ll_set_inode_lock_owner(tgt);
+	if (tgt_dchild->d_inode)
+		ll_set_inode_lock_owner(tgt_dchild->d_inode);
+
+	if (flags) {
+		err = -EINVAL;
+		goto out;
+	}
 
 	CDEBUG(D_VFSTRACE,
 	       "VFS Op:oldname=%pd, src_dir=" DFID "(%p), newname=%pd, tgt_dir=" DFID "(%p)\n",
 	       src_dchild, PFID(ll_inode2fid(src)), src,
 	       tgt_dchild, PFID(ll_inode2fid(tgt)), tgt);
 
-	if (unlikely(d_mountpoint(src_dchild) || d_mountpoint(tgt_dchild)))
-		return -EBUSY;
+	if (unlikely(d_mountpoint(src_dchild) || d_mountpoint(tgt_dchild))) {
+		err = -EBUSY;
+		goto out;
+	}
 
 	err = fscrypt_prepare_rename(src, src_dchild, tgt, tgt_dchild, flags);
 	if (err)
-		return err;
+		goto out;
+
 	/* we prevent an encrypted file from being renamed
 	 * into an unencrypted dir
 	 */
-	if (IS_ENCRYPTED(src) && !IS_ENCRYPTED(tgt))
-		return -EXDEV;
+	if (IS_ENCRYPTED(src) && !IS_ENCRYPTED(tgt)) {
+		err = -EXDEV;
+		goto out;
+	}
 
 	if (src_dchild->d_inode)
 		mode = src_dchild->d_inode->i_mode;
@@ -2076,8 +2156,10 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 
 	op_data = ll_prep_md_op_data(NULL, src, tgt, NULL, 0, mode,
 				     LUSTRE_OPC_ANY, NULL);
-	if (IS_ERR(op_data))
-		return PTR_ERR(op_data);
+	if (IS_ERR(op_data)) {
+		err = PTR_ERR(op_data);
+		goto out;
+	}
 
 	/* If the client is using a subdir mount and does a rename to what it
 	 * sees as /.fscrypt, interpret it as the .fscrypt dir at fs root.
@@ -2095,11 +2177,11 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 
 	err = ll_setup_filename(src, &src_dchild->d_name, 1, &foldname, NULL);
 	if (err)
-		return err;
+		goto out;
 	err = ll_setup_filename(tgt, &tgt_dchild->d_name, 1, &fnewname, NULL);
 	if (err) {
 		fscrypt_free_filename(&foldname);
-		return err;
+		goto out;
 	}
 	err = md_rename(sbi->ll_md_exp, op_data,
 			foldname.disk_name.name, foldname.disk_name.len,
@@ -2119,6 +2201,11 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 		ll_stats_ops_tally(sbi, LPROC_LL_RENAME,
 				   ktime_us_delta(ktime_get(), kstart));
 	}
+out:
+	ll_clear_inode_lock_owner(src);
+	ll_clear_inode_lock_owner(tgt);
+	if (d_inode(tgt_dchild))
+		ll_clear_inode_lock_owner(d_inode(tgt_dchild));
 
 	return err;
 }
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index c5f479c6f7e2..acc9c2935485 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -1258,10 +1258,10 @@ static int vvp_io_write_start(const struct lu_env *env,
 		iter = *vio->vui_iter;
 
 		if (unlikely(lock_inode))
-			inode_lock(inode);
+			ll_inode_lock(inode);
 		result = __generic_file_write_iter(vio->vui_iocb, &iter);
 		if (unlikely(lock_inode))
-			inode_unlock(inode);
+			ll_inode_unlock(inode);
 
 		written = result;
 		if (result > 0)
@@ -1641,7 +1641,7 @@ static int vvp_io_lseek_start(const struct lu_env *env,
 	struct inode *inode = vvp_object_inode(io->ci_obj);
 	u64 start = io->u.ci_lseek.ls_start;
 
-	inode_lock(inode);
+	ll_inode_lock(inode);
 	inode_dio_wait(inode);
 
 	/* At the moment we have DLM lock so just update inode
@@ -1664,7 +1664,7 @@ static void vvp_io_lseek_end(const struct lu_env *env,
 	if (io->u.ci_lseek.ls_result > i_size_read(inode))
 		io->u.ci_lseek.ls_result = -ENXIO;
 
-	inode_unlock(inode);
+	ll_inode_unlock(inode);
 }
 
 static const struct cl_io_operations vvp_io_ops = {
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index f4b2f8921b6c..bc7870620355 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -153,7 +153,6 @@ static int vvp_conf_set(const struct lu_env *env, struct cl_object *obj,
 
 static int vvp_prune(const struct lu_env *env, struct cl_object *obj)
 {
-	struct cl_io *io = vvp_env_io(env)->vui_cl.cis_io;
 	struct inode *inode = vvp_object_inode(obj);
 	int rc;
 
@@ -164,14 +163,16 @@ static int vvp_prune(const struct lu_env *env, struct cl_object *obj)
 		return rc;
 	}
 
-	if (io != NULL)
-		inode_lock(inode);
+	if (ll_get_inode_lock_owner(inode) != current)
+		/* ask LOV get inode lock then lo_type_guard */
+		return -EAGAIN;
 
-	ll_truncate_inode_pages_final(inode, io);
-	mapping_clear_exiting(inode->i_mapping);
+	LASSERTF(inode_is_locked(inode), DFID ":inode %p lli_flags %#lx\n",
+		 PFID(lu_object_fid(&obj->co_lu)), inode,
+		 ll_i2info(inode)->lli_flags);
 
-	if (io != NULL)
-		inode_unlock(inode);
+	ll_truncate_inode_pages_final(inode);
+	mapping_clear_exiting(inode->i_mapping);
 
 	return 0;
 }
@@ -224,6 +225,45 @@ static void vvp_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 	memcpy(attr->cra_jobid, &lli->lli_jobid, sizeof(attr->cra_jobid));
 }
 
+static int vvp_inode_ops(const struct lu_env *env, struct cl_object *obj,
+			 enum coo_inode_opc opc, void *data)
+{
+	struct inode *inode = vvp_object_inode(obj);
+	int rc = 0;
+
+	switch (opc) {
+	case COIO_INODE_LOCK:
+		if (ll_get_inode_lock_owner(inode) != current)
+			ll_inode_lock(inode);
+		else
+			rc = -EALREADY;
+		break;
+	case COIO_INODE_UNLOCK:
+		if (ll_get_inode_lock_owner(inode) == current)
+			ll_inode_unlock(inode);
+		else
+			rc = -ENOLCK;
+		break;
+	case COIO_SIZE_LOCK:
+		if (ll_i2info(inode)->lli_size_lock_owner != current)
+			ll_inode_size_lock(inode);
+		else
+			rc = -EALREADY;
+		break;
+	case COIO_SIZE_UNLOCK:
+		if (ll_i2info(inode)->lli_size_lock_owner == current)
+			ll_inode_size_unlock(inode);
+		else
+			rc = -ENOLCK;
+		break;
+	default:
+		rc = -EINVAL;
+		break;
+	}
+
+	return rc;
+}
+
 static const struct cl_object_operations vvp_ops = {
 	.coo_page_init		= vvp_page_init,
 	.coo_io_init		= vvp_io_init,
@@ -232,7 +272,8 @@ static const struct cl_object_operations vvp_ops = {
 	.coo_conf_set		= vvp_conf_set,
 	.coo_prune		= vvp_prune,
 	.coo_glimpse		= vvp_object_glimpse,
-	.coo_req_attr_set	= vvp_req_attr_set
+	.coo_req_attr_set	= vvp_req_attr_set,
+	.coo_inode_ops		= vvp_inode_ops,
 };
 
 static int __vvp_object_init(const struct lu_env *env,
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index ceaad604a55b..930e890554fd 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -94,6 +94,9 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 	u64 valid;
 	int rc;
 
+	/* VFS has locked the inode before calling this */
+	ll_set_inode_lock_owner(inode);
+
 	/* When setxattr() is called with a size of 0 the value is
 	 * unconditionally replaced by "". When removexattr() is
 	 * called we get a NULL value and XATTR_REPLACE for flags.
@@ -120,20 +123,24 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 
 	/*FIXME: enable IMA when the conditions are ready */
 	if (handler->flags == XATTR_SECURITY_T &&
-	    (!strcmp(name, "ima") || !strcmp(name, "evm")))
-		return -EOPNOTSUPP;
+	    (!strcmp(name, "ima") || !strcmp(name, "evm"))) {
+		rc = -EOPNOTSUPP;
+		goto out;
+	}
 
 	rc = ll_security_secctx_name_filter(sbi, handler->flags, name);
 	if (rc)
-		return rc;
+		goto out;
 
 	/*
 	 * In user.* namespace, only regular files and directories can have
 	 * extended attributes.
 	 */
 	if (handler->flags == XATTR_USER_T) {
-		if (!S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
-			return -EPERM;
+		if (!S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode)) {
+			rc = -EPERM;
+			goto out;
+		}
 	}
 
 	/* This check is required for compatibility with 2.14, in which
@@ -143,12 +150,16 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 	 * When new files/dirs are created in an encrypted dir, the enc
 	 * context is set directly in the create request.
 	 */
-	if (handler->flags == XATTR_SECURITY_T && strcmp(name, "c") == 0)
-		return -EPERM;
+	if (handler->flags == XATTR_SECURITY_T && strcmp(name, "c") == 0) {
+		rc = -EPERM;
+		goto out;
+	}
 
 	fullname = kasprintf(GFP_KERNEL, "%s%s", xattr_prefix(handler), name);
-	if (!fullname)
-		return -ENOMEM;
+	if (!fullname) {
+		rc = -ENOMEM;
+		goto out;
+	}
 
 	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode), valid, fullname,
 			 pv, size, flags, ll_i2suppgid(inode), &req);
@@ -158,7 +169,7 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 			LCONSOLE_INFO("Disabling user_xattr feature because it is not supported on the server\n");
 			clear_bit(LL_SBI_USER_XATTR, sbi->ll_flags);
 		}
-		return rc;
+		goto out;
 	}
 	ll_i2info(inode)->lli_synced_to_mds = false;
 
@@ -167,8 +178,10 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 	ll_stats_ops_tally(ll_i2sbi(inode), valid == OBD_MD_FLXATTRRM ?
 				LPROC_LL_REMOVEXATTR : LPROC_LL_SETXATTR,
 			   ktime_us_delta(ktime_get(), kstart));
+out:
+	ll_clear_inode_lock_owner(inode);
 
-	return 0;
+	return rc;
 }
 
 static int get_hsm_state(struct inode *inode, u32 *hus_states)
@@ -329,11 +342,14 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 	ktime_t kstart = ktime_get();
 	int op_type = flags == XATTR_REPLACE ? LPROC_LL_REMOVEXATTR :
 					       LPROC_LL_SETXATTR;
-	int rc;
+	int rc = 0;
 
 	LASSERT(inode);
 	LASSERT(name);
 
+	/* VFS has locked the inode before calling this */
+	ll_set_inode_lock_owner(inode);
+
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p), xattr %s\n",
 	       PFID(ll_inode2fid(inode)), inode, name);
 
@@ -343,11 +359,11 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 				       size);
 		ll_stats_ops_tally(ll_i2sbi(inode), op_type,
 				   ktime_us_delta(ktime_get(), kstart));
-		return rc;
+		goto out;
 	} else if (!strcmp(name, "lma") || !strcmp(name, "link")) {
 		ll_stats_ops_tally(ll_i2sbi(inode), op_type,
 				   ktime_us_delta(ktime_get(), kstart));
-		return 0;
+		goto out;
 	}
 
 	if (strncmp(name, "lov.", 4) == 0 &&
@@ -355,8 +371,12 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 	    le32_to_cpu(LOV_MAGIC_MASK)) == le32_to_cpu(LOV_MAGIC_MAGIC))
 		lustre_swab_lov_user_md((struct lov_user_md *)value, 0);
 
-	return ll_xattr_set_common(handler, dentry, inode, name, value, size,
-				   flags);
+	rc = ll_xattr_set_common(handler, dentry, inode, name, value, size,
+				 flags);
+out:
+	ll_clear_inode_lock_owner(inode);
+
+	return rc;
 }
 
 int ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index bc0f0a772d1d..27f005c807fe 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -317,10 +317,11 @@ static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
 	LASSERT(!r0->lo_sub[idx]);
 }
 
-static void lov_delete_raid0(const struct lu_env *env, struct lov_object *lov,
+static int lov_delete_raid0(const struct lu_env *env, struct lov_object *lov,
 			     struct lov_layout_entry *lle)
 {
 	struct lov_layout_raid0 *r0 = &lle->lle_raid0;
+	int rc;
 
 	if (r0->lo_sub) {
 		int i;
@@ -329,7 +330,9 @@ static void lov_delete_raid0(const struct lu_env *env, struct lov_object *lov,
 			struct lovsub_object *los = r0->lo_sub[i];
 
 			if (los) {
-				cl_object_prune(env, &los->lso_cl);
+				rc = cl_object_prune(env, &los->lso_cl);
+				if (rc)
+					return rc;
 				/*
 				 * If top-level object is to be evicted from
 				 * the cache, so are its sub-objects.
@@ -338,6 +341,8 @@ static void lov_delete_raid0(const struct lu_env *env, struct lov_object *lov,
 			}
 		}
 	}
+
+	return 0;
 }
 
 static void lov_fini_raid0(const struct lu_env *env,
@@ -848,6 +853,7 @@ static int lov_delete_composite(const struct lu_env *env,
 				union lov_layout_state *state)
 {
 	struct lov_layout_entry *entry;
+	int rc;
 
 	dump_lsm(D_INODE, lov->lo_lsm);
 
@@ -856,7 +862,9 @@ static int lov_delete_composite(const struct lu_env *env,
 		if (entry->lle_lsme && lsme_is_foreign(entry->lle_lsme))
 			continue;
 
-		lov_delete_raid0(env, lov, entry);
+		rc = lov_delete_raid0(env, lov, entry);
+		if (rc)
+			return rc;
 	}
 
 	return 0;
@@ -1339,6 +1347,9 @@ static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 {
 	struct lov_stripe_md *lsm = NULL;
 	struct lov_object *lov = cl2lov(obj);
+	struct cl_object *top = cl_object_top(obj);
+	bool unlock_inode = false;
+	bool lock_inode_size = false;
 	int result = 0;
 
 	if (conf->coc_opc == OBJECT_CONF_SET &&
@@ -1357,6 +1368,7 @@ static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 		goto out_lsm;
 	}
 
+retry:
 	lov_conf_lock(lov);
 	if (conf->coc_opc == OBJECT_CONF_WAIT) {
 		if (test_bit(LO_LAYOUT_INVALID, &lov->lo_obj_flags) &&
@@ -1408,13 +1420,47 @@ static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 	}
 
 	result = lov_layout_change(env, lov, lsm, conf);
-	if (result)
+	if (result) {
+		if (result == -EAGAIN) {
+			/**
+			 * we need unlocked lov conf and get inode lock.
+			 * It's possible we have already taken inode's size
+			 * mutex, so we need keep such lock order, lest deadlock
+			 * happens:
+			 *   inode lock		(ll_inode_lock())
+			 *   inode size lock	(ll_inode_size_lock())
+			 *   lov conf lock	(lov_conf_lock())
+			 *
+			 * e.g.
+			 *   vfs_setxattr		 inode locked
+			 *     ll_lov_setstripe_ea_info	 inode size locked
+			 *       ll_prep_inode
+			 *         ll_file_inode_init
+			 *           cl_conf_set
+			 *             lov_conf_set      lov conf locked
+			 */
+			lov_conf_unlock(lov);
+			if (cl_object_inode_ops(env, top, COIO_SIZE_UNLOCK,
+						NULL) == 0)
+				lock_inode_size = true;
+
+			/* take lock in order */
+			if (cl_object_inode_ops(env, top, COIO_INODE_LOCK,
+						NULL) == 0)
+				unlock_inode = true;
+			if (lock_inode_size)
+				cl_object_inode_ops(env, top, COIO_SIZE_LOCK,
+						    NULL);
+			goto retry;
+		}
 		set_bit(LO_LAYOUT_INVALID, &lov->lo_obj_flags);
-	else
+	} else {
 		clear_bit(LO_LAYOUT_INVALID, &lov->lo_obj_flags);
-
+	}
 out:
 	lov_conf_unlock(lov);
+	if (unlock_inode)
+		cl_object_inode_ops(env, top, COIO_INODE_UNLOCK, NULL);
 out_lsm:
 	lov_lsm_put(lsm);
 	CDEBUG(D_INODE, DFID " lo_layout_invalid=%u\n",
diff --git a/fs/lustre/obdclass/cl_object.c b/fs/lustre/obdclass/cl_object.c
index 28bf1e433c25..7c4a73590bed 100644
--- a/fs/lustre/obdclass/cl_object.c
+++ b/fs/lustre/obdclass/cl_object.c
@@ -409,6 +409,23 @@ int cl_object_flush(const struct lu_env *env, struct cl_object *obj,
 }
 EXPORT_SYMBOL(cl_object_flush);
 
+int cl_object_inode_ops(const struct lu_env *env, struct cl_object *top,
+			enum coo_inode_opc opc, void *data)
+{
+	struct cl_object *obj;
+	int rc = 0;
+
+	cl_object_for_each(obj, top) {
+		if (obj->co_ops->coo_inode_ops) {
+			rc = obj->co_ops->coo_inode_ops(env, obj, opc, data);
+			if (rc)
+				break;
+		}
+	}
+	return rc;
+}
+EXPORT_SYMBOL(cl_object_inode_ops);
+
 /**
  * Helper function removing all object locks, and marking object for
  * deletion. All object pages must have been deleted at this point.
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
