From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:08 -0500
Subject: [lustre-devel] [PATCH 01/22] staging: lustre: llite: clear
	LLIF_DATA_MODIFIED in atomic
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

This flag should be cleared atomically after the op_data flag
MDS_DATA_MODIFIED is packed. Otherwise, if there exists an
operation to dirty the file again, the state may be missed on
the MDT.

Stop using spin lock lli_lock to protect operations of changing
file flags; using bit operations instead.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6377
Reviewed-on: http://review.whamcloud.com/14100
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c         |   61 +++++++------------
 .../staging/lustre/lustre/llite/llite_internal.h   |   12 ++--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   18 +------
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    7 +--
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   10 +--
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |    7 +-
 6 files changed, 38 insertions(+), 77 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 6c2abb3..ea21e19 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -75,45 +75,39 @@ static void ll_file_data_put(struct ll_file_data *fd)
 		kmem_cache_free(ll_file_data_slab, fd);
 }
 
-void ll_pack_inode2opdata(struct inode *inode, struct md_op_data *op_data,
-			  struct lustre_handle *fh)
+/**
+ * Packs all the attributes into @op_data for the CLOSE rpc.
+ */
+static void ll_prepare_close(struct inode *inode, struct md_op_data *op_data,
+			     struct obd_client_handle *och)
 {
-	op_data->op_fid1 = ll_i2info(inode)->lli_fid;
+	struct ll_inode_info *lli = ll_i2info(inode);
+
+	ll_prep_md_op_data(op_data, inode, NULL, NULL,
+			   0, 0, LUSTRE_OPC_ANY, NULL);
+
 	op_data->op_attr.ia_mode = inode->i_mode;
 	op_data->op_attr.ia_atime = inode->i_atime;
 	op_data->op_attr.ia_mtime = inode->i_mtime;
 	op_data->op_attr.ia_ctime = inode->i_ctime;
 	op_data->op_attr.ia_size = i_size_read(inode);
+	op_data->op_attr.ia_valid |= ATTR_MODE | ATTR_ATIME | ATTR_ATIME_SET |
+				     ATTR_MTIME | ATTR_MTIME_SET |
+				     ATTR_CTIME | ATTR_CTIME_SET;
 	op_data->op_attr_blocks = inode->i_blocks;
 	op_data->op_attr_flags = ll_inode_to_ext_flags(inode->i_flags);
-	if (fh)
-		op_data->op_handle = *fh;
+	op_data->op_handle = och->och_fh;
 
-	if (ll_i2info(inode)->lli_flags & LLIF_DATA_MODIFIED)
+	/*
+	 * For HSM: if inode data has been modified, pack it so that
+	 * MDT can set data dirty flag in the archive.
+	 */
+	if (och->och_flags & FMODE_WRITE &&
+	    test_and_clear_bit(LLIF_DATA_MODIFIED, &lli->lli_flags))
 		op_data->op_bias |= MDS_DATA_MODIFIED;
 }
 
 /**
- * Packs all the attributes into @op_data for the CLOSE rpc.
- */
-static void ll_prepare_close(struct inode *inode, struct md_op_data *op_data,
-			     struct obd_client_handle *och)
-{
-	op_data->op_attr.ia_valid = ATTR_MODE | ATTR_ATIME | ATTR_ATIME_SET |
-					ATTR_MTIME | ATTR_MTIME_SET |
-					ATTR_CTIME | ATTR_CTIME_SET;
-
-	if (!(och->och_flags & FMODE_WRITE))
-		goto out;
-
-	op_data->op_attr.ia_valid |= ATTR_SIZE | ATTR_BLOCKS;
-out:
-	ll_pack_inode2opdata(inode, op_data, &och->och_fh);
-	ll_prep_md_op_data(op_data, inode, NULL, NULL,
-			   0, 0, LUSTRE_OPC_ANY, NULL);
-}
-
-/**
  * Perform a close, possibly with a bias.
  * The meaning of "data" depends on the value of "bias".
  *
@@ -181,17 +175,6 @@ static int ll_close_inode_openhandle(struct obd_export *md_exp,
 		       PFID(ll_inode2fid(inode)), rc);
 	}
 
-	/* DATA_MODIFIED flag was successfully sent on close, cancel data
-	 * modification flag.
-	 */
-	if (rc == 0 && (op_data->op_bias & MDS_DATA_MODIFIED)) {
-		struct ll_inode_info *lli = ll_i2info(inode);
-
-		spin_lock(&lli->lli_lock);
-		lli->lli_flags &= ~LLIF_DATA_MODIFIED;
-		spin_unlock(&lli->lli_lock);
-	}
-
 	if (op_data->op_bias & (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP) &&
 	    !rc) {
 		struct mdt_body *body;
@@ -2888,6 +2871,8 @@ static int ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 		LTIME_S(inode->i_mtime) = ll_i2info(inode)->lli_mtime;
 		LTIME_S(inode->i_ctime) = ll_i2info(inode)->lli_ctime;
 	} else {
+		struct ll_inode_info *lli = ll_i2info(inode);
+
 		/* In case of restore, the MDT has the right size and has
 		 * already send it back without granting the layout lock,
 		 * inode is up-to-date so glimpse is useless.
@@ -2895,7 +2880,7 @@ static int ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 		 * restore the MDT holds the layout lock so the glimpse will
 		 * block up to the end of restore (getattr will block)
 		 */
-		if (!(ll_i2info(inode)->lli_flags & LLIF_FILE_RESTORING))
+		if (!test_bit(LLIF_FILE_RESTORING, &lli->lli_flags))
 			rc = ll_glimpse_size(inode);
 	}
 	return rc;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 50bb328..ac4ce05 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -97,20 +97,20 @@ struct ll_grouplock {
 	unsigned long	 lg_gid;
 };
 
-enum lli_flags {
+enum ll_file_flags {
 	/* File data is modified. */
-	LLIF_DATA_MODIFIED	= BIT(0),
+	LLIF_DATA_MODIFIED	= 0,
 	/* File is being restored */
-	LLIF_FILE_RESTORING	= BIT(1),
+	LLIF_FILE_RESTORING	= 1,
 	/* Xattr cache is attached to the file */
-	LLIF_XATTR_CACHE	= BIT(2),
+	LLIF_XATTR_CACHE	= 2,
 };
 
 struct ll_inode_info {
 	__u32				lli_inode_magic;
-	__u32				lli_flags;
 
 	spinlock_t			lli_lock;
+	unsigned long			lli_flags;
 	struct posix_acl		*lli_posix_acl;
 
 	/* identifying fields for both metadata and data stacks. */
@@ -740,8 +740,6 @@ enum ldlm_mode ll_take_md_lock(struct inode *inode, __u64 bits,
 int ll_file_release(struct inode *inode, struct file *file);
 int ll_release_openhandle(struct inode *, struct lookup_intent *);
 int ll_md_real_close(struct inode *inode, fmode_t fmode);
-void ll_pack_inode2opdata(struct inode *inode, struct md_op_data *op_data,
-			  struct lustre_handle *fh);
 int ll_getattr(struct vfsmount *mnt, struct dentry *de, struct kstat *stat);
 struct posix_acl *ll_get_acl(struct inode *inode, int type);
 int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index dcd9240..2a51efa 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1532,9 +1532,6 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 			 * modified, flag it.
 			 */
 			attr->ia_valid |= MDS_OPEN_OWNEROVERRIDE;
-			spin_lock(&lli->lli_lock);
-			lli->lli_flags |= LLIF_DATA_MODIFIED;
-			spin_unlock(&lli->lli_lock);
 			op_data->op_bias |= MDS_DATA_MODIFIED;
 		}
 	}
@@ -1545,13 +1542,6 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 	if (rc)
 		goto out;
 
-	/* RPC to MDT is sent, cancel data modification flag */
-	if (op_data->op_bias & MDS_DATA_MODIFIED) {
-		spin_lock(&lli->lli_lock);
-		lli->lli_flags &= ~LLIF_DATA_MODIFIED;
-		spin_unlock(&lli->lli_lock);
-	}
-
 	if (!S_ISREG(inode->i_mode) || file_is_released) {
 		rc = 0;
 		goto out;
@@ -1822,7 +1812,7 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 
 	if (body->mbo_valid & OBD_MD_TSTATE) {
 		if (body->mbo_t_state & MS_RESTORE)
-			lli->lli_flags |= LLIF_FILE_RESTORING;
+			set_bit(LLIF_FILE_RESTORING, &lli->lli_flags);
 	}
 
 	return 0;
@@ -2331,8 +2321,6 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
 	op_data->op_cap = cfs_curproc_cap_pack();
-	op_data->op_bias = 0;
-	op_data->op_cli_flags = 0;
 	if ((opc == LUSTRE_OPC_CREATE) && name &&
 	    filename_is_volatile(name, namelen, &op_data->op_mds))
 		op_data->op_bias |= MDS_CREATE_VOLATILE;
@@ -2340,10 +2328,6 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 		op_data->op_mds = 0;
 	op_data->op_data = data;
 
-	/* When called by ll_setattr_raw, file is i1. */
-	if (ll_i2info(i1)->lli_flags & LLIF_DATA_MODIFIED)
-		op_data->op_bias |= MDS_DATA_MODIFIED;
-
 	return op_data;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index b56203b..f50b6c1 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -215,11 +215,8 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
 			result = -EAGAIN;
 		}
 
-		if (result == 0) {
-			spin_lock(&lli->lli_lock);
-			lli->lli_flags |= LLIF_DATA_MODIFIED;
-			spin_unlock(&lli->lli_lock);
-		}
+		if (!result)
+			set_bit(LLIF_DATA_MODIFIED, &lli->lli_flags);
 	}
 
 out_io:
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 2bf3e47..114906d 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -329,8 +329,8 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 			       vio->vui_layout_gen, gen);
 			/* today successful restore is the only possible case */
 			/* restore was done, clear restoring state */
-			ll_i2info(vvp_object_inode(obj))->lli_flags &=
-				~LLIF_FILE_RESTORING;
+			clear_bit(LLIF_FILE_RESTORING,
+				  &ll_i2info(inode)->lli_flags);
 		}
 	}
 }
@@ -982,11 +982,7 @@ static int vvp_io_write_start(const struct lu_env *env,
 		}
 	}
 	if (result > 0) {
-		struct ll_inode_info *lli = ll_i2info(inode);
-
-		spin_lock(&lli->lli_lock);
-		lli->lli_flags |= LLIF_DATA_MODIFIED;
-		spin_unlock(&lli->lli_lock);
+		set_bit(LLIF_DATA_MODIFIED, &(ll_i2info(inode))->lli_flags);
 
 		if (result < cnt)
 			io->ci_continue = 0;
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index 47c1d11..198b051 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -60,7 +60,7 @@ void ll_xattr_fini(void)
 static void ll_xattr_cache_init(struct ll_inode_info *lli)
 {
 	INIT_LIST_HEAD(&lli->lli_xattrs);
-	lli->lli_flags |= LLIF_XATTR_CACHE;
+	set_bit(LLIF_XATTR_CACHE, &lli->lli_flags);
 }
 
 /**
@@ -216,7 +216,7 @@ static int ll_xattr_cache_list(struct list_head *cache,
  */
 static int ll_xattr_cache_valid(struct ll_inode_info *lli)
 {
-	return !!(lli->lli_flags & LLIF_XATTR_CACHE);
+	return test_bit(LLIF_XATTR_CACHE, &lli->lli_flags);
 }
 
 /**
@@ -233,7 +233,8 @@ static int ll_xattr_cache_destroy_locked(struct ll_inode_info *lli)
 
 	while (ll_xattr_cache_del(&lli->lli_xattrs, NULL) == 0)
 		; /* empty loop */
-	lli->lli_flags &= ~LLIF_XATTR_CACHE;
+
+	clear_bit(LLIF_XATTR_CACHE, &lli->lli_flags);
 
 	return 0;
 }
-- 
1.7.1
