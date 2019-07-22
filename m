From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:52:09 -0400
Subject: [lustre-devel] [PATCH 02/11] lustre: llite: checkpatch cleanup
In-Reply-To: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
References: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563760338-806-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Many checkpatch errors exist in the llite layer. This address
a good chuck of them. Other are left since future patches will
cleanup those areas. Others will need more code rework so this
patch handles the simple cases. This is a good step forward
toward proper kernel code style compliance.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c            | 18 ++++++++----------
 fs/lustre/llite/file.c           | 24 ++++++++++++------------
 fs/lustre/llite/llite_internal.h |  8 +++++---
 fs/lustre/llite/llite_lib.c      | 26 ++++++++++++++------------
 fs/lustre/llite/llite_nfs.c      |  3 ++-
 fs/lustre/llite/lproc_llite.c    |  8 +++++---
 fs/lustre/llite/namei.c          | 15 ++++++++++-----
 fs/lustre/llite/rw26.c           |  3 ++-
 fs/lustre/llite/statahead.c      | 23 +++++++++++++++--------
 fs/lustre/llite/super25.c        |  3 ++-
 fs/lustre/llite/vvp_dev.c        |  3 ++-
 fs/lustre/llite/vvp_io.c         |  2 +-
 12 files changed, 78 insertions(+), 58 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 1fbfc3a..ba53c1e 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -423,7 +423,8 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	if (unlikely(lump->lum_magic != LMV_USER_MAGIC))
 		return -EINVAL;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p) name %s stripe_offset %d, stripe_count: %u\n",
+	CDEBUG(D_VFSTRACE,
+	       "VFS Op:inode=" DFID "(%p) name %s stripe_offset %d, stripe_count: %u\n",
 	       PFID(ll_inode2fid(parent)), parent, dirname,
 	       (int)lump->lum_stripe_offset, lump->lum_stripe_count);
 
@@ -517,24 +518,20 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 		}
 		case LOV_USER_MAGIC_V3: {
 			if (lump->lmm_magic != cpu_to_le32(LOV_USER_MAGIC_V3))
-				lustre_swab_lov_user_md_v3(
-					(struct lov_user_md_v3 *)lump);
+				lustre_swab_lov_user_md_v3((struct lov_user_md_v3 *)lump);
 			lum_size = sizeof(struct lov_user_md_v3);
 			break;
 		}
 		case LOV_USER_MAGIC_COMP_V1: {
 			if (lump->lmm_magic !=
 			    cpu_to_le32(LOV_USER_MAGIC_COMP_V1))
-				lustre_swab_lov_comp_md_v1(
-					(struct lov_comp_md_v1 *)lump);
-			lum_size = le32_to_cpu(
-				((struct lov_comp_md_v1 *)lump)->lcm_size);
+				lustre_swab_lov_comp_md_v1((struct lov_comp_md_v1 *)lump);
+			lum_size = le32_to_cpu(((struct lov_comp_md_v1 *)lump)->lcm_size);
 			break;
 		}
 		case LMV_USER_MAGIC: {
 			if (lump->lmm_magic != cpu_to_le32(LMV_USER_MAGIC))
-				lustre_swab_lmv_user_md(
-					(struct lmv_user_md *)lump);
+				lustre_swab_lmv_user_md((struct lmv_user_md *)lump);
 			lum_size = sizeof(struct lmv_user_md);
 			break;
 		}
@@ -877,7 +874,8 @@ static int ll_ioc_copy_end(struct super_block *sb, struct hsm_copy *copy)
 		 */
 		if ((copy->hc_hai.hai_action == HSMA_ARCHIVE) &&
 		    (copy->hc_data_version != data_version)) {
-			CDEBUG(D_HSM, "File data version mismatched. File content was changed during archiving. " DFID ", start:%#llx current:%#llx\n",
+			CDEBUG(D_HSM,
+			       "File data version mismatched. File content was changed during archiving. " DFID ", start:%#llx current:%#llx\n",
 			       PFID(&copy->hc_hai.hai_fid),
 			       copy->hc_data_version, data_version);
 			/* File was changed, send error to cdt. Do not ask for
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index fd53a3a..faf4fb8 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -587,7 +587,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 	} else {
 		LASSERT(*och_usecount == 0);
 		if (!it->it_disposition) {
-			struct ll_dentry_data *ldd = ll_d2d(file->f_path.dentry);
+			struct ll_dentry_data *ldd;
 
 			/* We cannot just request lock handle now, new ELC code
 			 * means that one of other OPEN locks for this file
@@ -611,6 +611,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 			 * lookup path only, since ll_iget_for_nfs always calls
 			 * ll_d_init().
 			 */
+			ldd = ll_d2d(file->f_path.dentry);
 			if (ldd && ldd->lld_nfs_dentry) {
 				ldd->lld_nfs_dentry = 0;
 				it->it_flags |= MDS_OPEN_LOCK;
@@ -1460,15 +1461,13 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 		if (lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_V1)) {
 			lustre_swab_lov_user_md_v1((struct lov_user_md_v1 *)lmm);
 			if (S_ISREG(body->mbo_mode))
-				lustre_swab_lov_user_md_objects(
-				 ((struct lov_user_md_v1 *)lmm)->lmm_objects,
-				 stripe_count);
+				lustre_swab_lov_user_md_objects(((struct lov_user_md_v1 *)lmm)->lmm_objects,
+								stripe_count);
 		} else if (lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_V3)) {
 			lustre_swab_lov_user_md_v3((struct lov_user_md_v3 *)lmm);
 			if (S_ISREG(body->mbo_mode))
-				lustre_swab_lov_user_md_objects(
-				 ((struct lov_user_md_v3 *)lmm)->lmm_objects,
-				 stripe_count);
+				lustre_swab_lov_user_md_objects(((struct lov_user_md_v3 *)lmm)->lmm_objects,
+								stripe_count);
 		} else if (lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_COMP_V1)) {
 			lustre_swab_lov_comp_md_v1((struct lov_comp_md_v1 *)lmm);
 		}
@@ -2237,7 +2236,7 @@ int ll_ioctl_fsgetxattr(struct inode *inode, unsigned int cmd,
 		fsxattr.fsx_xflags |= FS_XFLAG_PROJINHERIT;
 	fsxattr.fsx_projid = ll_i2info(inode)->lli_projid;
 	if (copy_to_user((struct fsxattr __user *)arg,
-			  &fsxattr, sizeof(fsxattr)))
+			 &fsxattr, sizeof(fsxattr)))
 		return -EFAULT;
 
 	return 0;
@@ -2344,9 +2343,9 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 		return 0;
 	case LL_IOC_LOV_SETSTRIPE:
 	case LL_IOC_LOV_SETSTRIPE_NEW:
-		return ll_lov_setstripe(inode, file, (void __user *) arg);
+		return ll_lov_setstripe(inode, file, (void __user *)arg);
 	case LL_IOC_LOV_SETEA:
-		return ll_lov_setea(inode, file, (void __user *) arg);
+		return ll_lov_setea(inode, file, (void __user *)arg);
 	case LL_IOC_LOV_SWAP_LAYOUTS: {
 		struct file *file2;
 		struct lustre_swap_layouts lsl;
@@ -2959,7 +2958,8 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	CDEBUG(D_DLMTRACE, "inode=" DFID ", pid=%u, flags=%#llx, mode=%u, start=%llu, end=%llu\n",
+	CDEBUG(D_DLMTRACE,
+	       "inode=" DFID ", pid=%u, flags=%#llx, mode=%u, start=%llu, end=%llu\n",
 	       PFID(ll_inode2fid(inode)), flock.l_flock.pid, flags,
 	       einfo.ei_mode, flock.l_flock.start, flock.l_flock.end);
 
@@ -3167,7 +3167,7 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 static int
 ll_file_noflock(struct file *file, int cmd, struct file_lock *file_lock)
 {
-	return -ENOSYS;
+	return -EINVAL;
 }
 
 /**
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 9da59b1..b8f4e0e 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -267,7 +267,7 @@ static inline bool obd_connect_has_secctx(struct obd_connect_data *data)
 	return data->ocd_connect_flags & OBD_CONNECT_FLAGS2 &&
 	       data->ocd_connect_flags2 & OBD_CONNECT2_FILE_SECCTX;
 #else
-       return false;
+	return false;
 #endif
 }
 
@@ -1079,6 +1079,7 @@ enum ras_update_flags {
 	LL_RAS_HIT  = 0x1,
 	LL_RAS_MMAP = 0x2
 };
+
 void ll_ra_count_put(struct ll_sb_info *sbi, unsigned long len);
 void ll_ra_stats_inc(struct inode *inode, enum ra_stat which);
 
@@ -1096,7 +1097,7 @@ enum ras_update_flags {
 #define LL_SA_RUNNING_DEF	16
 
 #define LL_SA_CACHE_BIT	 5
-#define LL_SA_CACHE_SIZE	(1 << LL_SA_CACHE_BIT)
+#define LL_SA_CACHE_SIZE	BIT(LL_SA_CACHE_BIT)
 #define LL_SA_CACHE_MASK	(LL_SA_CACHE_SIZE - 1)
 
 /* per inode struct, for dir only */
@@ -1256,7 +1257,8 @@ static inline void ll_set_lock_data(struct obd_export *exp, struct inode *inode,
 		 */
 		if (it->it_remote_lock_mode) {
 			handle.cookie = it->it_remote_lock_handle;
-			CDEBUG(D_DLMTRACE, "setting l_data to inode " DFID "%p for remote lock %#llx\n",
+			CDEBUG(D_DLMTRACE,
+			       "setting l_data to inode " DFID "%p for remote lock %#llx\n",
 			       PFID(ll_inode2fid(inode)), inode,
 			       handle.cookie);
 			md_set_lock_data(exp, &handle, inode, NULL);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 4e98eb4..4e09f0f 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -93,7 +93,7 @@ static struct ll_sb_info *ll_init_sbi(void)
 	}
 
 	sbi->ll_ra_info.ra_max_pages_per_file = min(pages / 32,
-					   SBI_DEFAULT_READAHEAD_MAX);
+						    SBI_DEFAULT_READAHEAD_MAX);
 	sbi->ll_ra_info.ra_max_pages = sbi->ll_ra_info.ra_max_pages_per_file;
 	sbi->ll_ra_info.ra_max_read_ahead_whole_pages =
 					   SBI_DEFAULT_READAHEAD_WHOLE_MAX;
@@ -110,10 +110,11 @@ static struct ll_sb_info *ll_init_sbi(void)
 	sbi->ll_flags |= LL_SBI_LAZYSTATFS;
 
 	for (i = 0; i <= LL_PROCESS_HIST_MAX; i++) {
-		spin_lock_init(&sbi->ll_rw_extents_info.pp_extents[i].
-			       pp_r_hist.oh_lock);
-		spin_lock_init(&sbi->ll_rw_extents_info.pp_extents[i].
-			       pp_w_hist.oh_lock);
+		struct per_process_info *pp_ext;
+
+		pp_ext = &sbi->ll_rw_extents_info.pp_extents[i];
+		spin_lock_init(&pp_ext->pp_r_hist.oh_lock);
+		spin_lock_init(&pp_ext->pp_w_hist.oh_lock);
 	}
 
 	/* metadata statahead is enabled by default */
@@ -353,9 +354,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	if (data->ocd_ibits_known & MDS_INODELOCK_XATTR) {
 		if (!(data->ocd_connect_flags & OBD_CONNECT_MAX_EASIZE)) {
-			LCONSOLE_INFO(
-				"%s: disabling xattr cache due to unknown maximum xattr size.\n",
-				dt);
+			LCONSOLE_INFO("%s: disabling xattr cache due to unknown maximum xattr size.\n",
+				      dt);
 		} else if (!sbi->ll_xattr_cache_set) {
 			/* If xattr_cache is already set (no matter 0 or 1)
 			 * during processing llog, it won't be enabled here.
@@ -377,7 +377,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	data->ocd_connect_flags = OBD_CONNECT_GRANT     | OBD_CONNECT_VERSION  |
 				  OBD_CONNECT_REQPORTAL | OBD_CONNECT_BRW_SIZE |
 				  OBD_CONNECT_CANCELSET | OBD_CONNECT_FID      |
-				  OBD_CONNECT_SRVLOCK   | OBD_CONNECT_TRUNCLOCK|
+				  OBD_CONNECT_SRVLOCK   |
+				  OBD_CONNECT_TRUNCLOCK |
 				  OBD_CONNECT_AT	| OBD_CONNECT_OSS_CAPA |
 				  OBD_CONNECT_VBR	| OBD_CONNECT_FULL20   |
 				  OBD_CONNECT_64BITHASH | OBD_CONNECT_MAXBYTES |
@@ -2063,7 +2064,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		return rc;
 	}
 	default:
-		return -ENOSYS;
+		return -EINVAL;
 	}
 
 	return 0;
@@ -2235,8 +2236,9 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 			goto out;
 		}
 
-		*inode = ll_iget(sb, cl_fid_build_ino(&md.body->mbo_fid1,
-					     sbi->ll_flags & LL_SBI_32BIT_API),
+		*inode = ll_iget(sb,
+				 cl_fid_build_ino(&md.body->mbo_fid1,
+						  sbi->ll_flags & LL_SBI_32BIT_API),
 				 &md);
 		if (IS_ERR(*inode)) {
 #ifdef CONFIG_FS_POSIX_ACL
diff --git a/fs/lustre/llite/llite_nfs.c b/fs/lustre/llite/llite_nfs.c
index 9129f47..64bff0a 100644
--- a/fs/lustre/llite/llite_nfs.c
+++ b/fs/lustre/llite/llite_nfs.c
@@ -218,7 +218,8 @@ static int ll_nfs_get_name_filldir(struct dir_context *ctx, const char *name,
 	/* It is hack to access lde_fid for comparison with lgd_fid.
 	 * So the input 'name' must be part of the 'lu_dirent'.
 	 */
-	struct lu_dirent *lde = container_of((void*)name, struct lu_dirent, lde_name);
+	struct lu_dirent *lde = container_of((void *)name, struct lu_dirent,
+					     lde_name);
 	struct ll_getname_data *lgd =
 		container_of(ctx, struct ll_getname_data, ctx);
 	struct lu_fid fid;
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 7cb1c28..99e8a82 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -501,7 +501,8 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 					  const char __user *buffer,
 					  size_t count, loff_t *off)
 {
-	struct super_block *sb = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *m = file->private_data;
+	struct super_block *sb = m->private;
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct cl_client_cache *cache = sbi->ll_cache;
 	struct lu_env *env;
@@ -1094,7 +1095,8 @@ static ssize_t ll_unstable_stats_seq_write(struct file *file,
 					   const char __user *buffer,
 					   size_t count, loff_t *off)
 {
-	struct super_block *sb = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *m = file->private_data;
+	struct super_block *sb = m->private;
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	char kernbuf[128];
 	bool val;
@@ -1320,7 +1322,7 @@ void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, int count)
 }
 EXPORT_SYMBOL(ll_stats_ops_tally);
 
-static const char *ra_stat_string[] = {
+static const char *const ra_stat_string[] = {
 	[RA_STAT_HIT]			= "hits",
 	[RA_STAT_MISS]			= "misses",
 	[RA_STAT_DISTANT_READPAGE]	= "readpage not consecutive",
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index a87c8a2..caa759f 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -263,13 +263,16 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 				       PFID(ll_inode2fid(inode)), rc);
 		}
 
-		if (bits & MDS_INODELOCK_UPDATE)
-			set_bit(LLIF_UPDATE_ATIME, &ll_i2info(inode)->lli_flags);
+		if (bits & MDS_INODELOCK_UPDATE) {
+			set_bit(LLIF_UPDATE_ATIME,
+				&ll_i2info(inode)->lli_flags);
+		}
 
 		if ((bits & MDS_INODELOCK_UPDATE) && S_ISDIR(inode->i_mode)) {
 			struct ll_inode_info *lli = ll_i2info(inode);
 
-			CDEBUG(D_INODE, "invalidating inode " DFID " lli = %p, pfid  = " DFID "\n",
+			CDEBUG(D_INODE,
+			       "invalidating inode " DFID " lli = %p, pfid  = " DFID "\n",
 			       PFID(ll_inode2fid(inode)), lli,
 			       PFID(&lli->lli_pfid));
 
@@ -563,7 +566,8 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 		}
 	}
 
-	if (it->it_op & IT_OPEN && it->it_flags & FMODE_WRITE && sb_rdonly(dentry->d_sb))
+	if (it->it_op & IT_OPEN && it->it_flags & FMODE_WRITE &&
+	    sb_rdonly(dentry->d_sb))
 		return ERR_PTR(-EROFS);
 
 	if (it->it_op & IT_CREAT)
@@ -714,7 +718,8 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	struct dentry *de;
 	int rc = 0;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p),file %p,open_flags %x,mode %x\n",
+	CDEBUG(D_VFSTRACE,
+	       "VFS Op:name=%pd, dir=" DFID "(%p),file %p,open_flags %x,mode %x\n",
 	       dentry, PFID(ll_inode2fid(dir)), dir, file, open_flags, mode);
 
 	/* Only negative dentries enter here */
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index e4ce3b6..805ba32 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -306,7 +306,8 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	if ((file_offset & ~PAGE_MASK) || (count & ~PAGE_MASK))
 		return -EINVAL;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p), size=%zd (max %lu), offset=%lld=%llx, pages %zd (max %lu)\n",
+	CDEBUG(D_VFSTRACE,
+	       "VFS Op:inode=" DFID "(%p), size=%zd (max %lu), offset=%lld=%llx, pages %zd (max %lu)\n",
 	       PFID(ll_inode2fid(inode)), inode, count, MAX_DIO_SIZE,
 	       file_offset, file_offset, count >> PAGE_SHIFT,
 	       MAX_DIO_SIZE >> PAGE_SHIFT);
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 53bab47..797ad06 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -265,8 +265,8 @@ static void sa_free(struct ll_statahead_info *sai, struct sa_entry *entry)
 }
 
 /* called by scanner after use, sa_entry will be killed */
-static void
-sa_put(struct ll_statahead_info *sai, struct sa_entry *entry, struct ll_inode_info *lli)
+static void sa_put(struct ll_statahead_info *sai, struct sa_entry *entry,
+		   struct ll_inode_info *lli)
 {
 	struct sa_entry *tmp, *next;
 
@@ -326,7 +326,8 @@ static void sa_free(struct ll_statahead_info *sai, struct sa_entry *entry)
 	 * LU-9210: ll_statahead_interpet must be able to see this before
 	 * we wake it up
 	 */
-	smp_store_release(&entry->se_state, ret < 0 ? SA_ENTRY_INVA : SA_ENTRY_SUCC);
+	smp_store_release(&entry->se_state,
+			  ret < 0 ? SA_ENTRY_INVA : SA_ENTRY_SUCC);
 
 	return (index == sai->sai_index_wait);
 }
@@ -590,7 +591,8 @@ static void sa_instantiate(struct ll_statahead_info *sai,
 	child = entry->se_inode;
 	if (child) {
 		/* revalidate; unlinked and re-created with the same name */
-		if (unlikely(!lu_fid_eq(&minfo->mi_data.op_fid2, &body->mbo_fid1))) {
+		if (unlikely(!lu_fid_eq(&minfo->mi_data.op_fid2,
+					&body->mbo_fid1))) {
 			entry->se_inode = NULL;
 			iput(child);
 			child = NULL;
@@ -701,6 +703,7 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 			wake_up(&sai->sai_waitq);
 	} else {
 		int first = 0;
+
 		entry->se_minfo = minfo;
 		entry->se_req = ptlrpc_request_addref(req);
 		/*
@@ -881,7 +884,9 @@ static int ll_agl_thread(void *arg)
 	struct inode *dir = d_inode(parent);
 	struct ll_inode_info *plli = ll_i2info(dir);
 	struct ll_inode_info *clli;
-	/* We already own this reference, so it is safe to take it without a lock. */
+	/* We already own this reference, so it is safe to take it without
+	 * a lock.
+	 */
 	struct ll_statahead_info *sai = plli->lli_sai;
 
 	CDEBUG(D_READA, "agl thread started: sai %p, parent %pd\n",
@@ -1113,7 +1118,9 @@ static int ll_statahead_thread(void *arg)
 		sa_handle_callback(sai);
 
 		set_current_state(TASK_IDLE);
-		/* ensure we see the NULL stored by ll_deauthorize_statahead() */
+		/* ensure we see the NULL stored by
+		 * ll_deauthorize_statahead()
+		 */
 		if (!sa_has_callback(sai) &&
 		    smp_load_acquire(&sai->sai_task))
 			schedule();
@@ -1408,8 +1415,8 @@ static int revalidate_statahead_dentry(struct inode *dir,
 		spin_lock(&lli->lli_sa_lock);
 		sai->sai_index_wait = entry->se_index;
 		spin_unlock(&lli->lli_sa_lock);
-		if (0 == wait_event_idle_timeout(sai->sai_waitq,
-						 sa_ready(entry), 30 * HZ)) {
+		if (wait_event_idle_timeout(sai->sai_waitq,
+					    sa_ready(entry), 30 * HZ) == 0) {
 			/*
 			 * entry may not be ready, so it may be used by inflight
 			 * statahead RPC, don't free it.
diff --git a/fs/lustre/llite/super25.c b/fs/lustre/llite/super25.c
index a25d03c..2b65e2f 100644
--- a/fs/lustre/llite/super25.c
+++ b/fs/lustre/llite/super25.c
@@ -89,7 +89,8 @@ struct super_operations lustre_super_operations = {
  *
  * @data:	Mount options (e.g. -o flock,abort_recov)
  */
-static int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent)
+static int lustre_fill_super(struct super_block *sb, void *lmd2_data,
+			     int silent)
 {
 	struct lustre_mount_data *lmd;
 	struct lustre_sb_info *lsi;
diff --git a/fs/lustre/llite/vvp_dev.c b/fs/lustre/llite/vvp_dev.c
index 568943d..4c5a29d 100644
--- a/fs/lustre/llite/vvp_dev.c
+++ b/fs/lustre/llite/vvp_dev.c
@@ -451,7 +451,8 @@ static struct page *vvp_pgcache_current(struct vvp_seq_private *priv)
 		}
 
 		inode = vvp_object_inode(priv->vsp_clob);
-		nr = find_get_pages_contig(inode->i_mapping, priv->vsp_id.vpi_index, 1, &vmpage);
+		nr = find_get_pages_contig(inode->i_mapping,
+					   priv->vsp_id.vpi_index, 1, &vmpage);
 		if (nr > 0) {
 			priv->vsp_id.vpi_index = vmpage->index;
 			return vmpage;
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 225a858..b2160d6 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -641,7 +641,7 @@ static int vvp_io_setattr_time(const struct lu_env *env,
 	struct cl_object *obj = io->ci_obj;
 	struct cl_attr *attr = vvp_env_thread_attr(env);
 	int result;
-	unsigned valid = CAT_CTIME;
+	unsigned int valid = CAT_CTIME;
 
 	cl_object_attr_lock(obj);
 	attr->cat_ctime = io->u.ci_setattr.sa_attr.lvb_ctime;
-- 
1.8.3.1
