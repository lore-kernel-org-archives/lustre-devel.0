From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:15 -0500
Subject: [lustre-devel] [PATCH 11/26] llite: cleanup white spaces
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The llite code is very messy and difficult to read. Remove excess
white space and properly align data structures so they are easy on
the eyes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c          | 114 ++++++-------
 drivers/staging/lustre/lustre/llite/file.c         | 180 ++++++++++-----------
 drivers/staging/lustre/lustre/llite/glimpse.c      |  18 +--
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  24 +--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  52 +++---
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  52 +++---
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |  42 ++---
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  80 ++++-----
 drivers/staging/lustre/lustre/llite/namei.c        |  49 +++---
 drivers/staging/lustre/lustre/llite/rw.c           |   2 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  57 ++++---
 drivers/staging/lustre/lustre/llite/statahead.c    | 133 +++++++--------
 drivers/staging/lustre/lustre/llite/super25.c      |  16 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      | 104 ++++++------
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  56 +++----
 drivers/staging/lustre/lustre/llite/vvp_io.c       | 169 ++++++++++---------
 drivers/staging/lustre/lustre/llite/vvp_object.c   |  30 ++--
 drivers/staging/lustre/lustre/llite/vvp_page.c     |  88 +++++-----
 drivers/staging/lustre/lustre/llite/xattr.c        |  48 +++---
 19 files changed, 658 insertions(+), 656 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 4520344..fd1af4a 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -200,13 +200,13 @@ static u16 ll_dirent_type_get(struct lu_dirent *ent)
 int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 		struct dir_context *ctx)
 {
-	struct ll_sb_info    *sbi	= ll_i2sbi(inode);
-	u64		   pos		= *ppos;
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	u64 pos = *ppos;
 	bool is_api32 = ll_need_32bit_api(sbi);
-	int		   is_hash64 = sbi->ll_flags & LL_SBI_64BIT_HASH;
-	struct page	  *page;
-	bool		   done = false;
-	int		   rc = 0;
+	int is_hash64 = sbi->ll_flags & LL_SBI_64BIT_HASH;
+	struct page *page;
+	bool done = false;
+	int rc = 0;
 
 	page = ll_get_dir_page(inode, op_data, pos);
 
@@ -225,11 +225,11 @@ int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 		dp = page_address(page);
 		for (ent = lu_dirent_start(dp); ent && !done;
 		     ent = lu_dirent_next(ent)) {
-			u16	  type;
-			int	    namelen;
-			struct lu_fid  fid;
-			u64	  lhash;
-			u64	  ino;
+			u16 type;
+			int namelen;
+			struct lu_fid fid;
+			u64 lhash;
+			u64 ino;
 
 			hash = le64_to_cpu(ent->lde_hash);
 			if (hash < pos)
@@ -291,14 +291,14 @@ int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 
 static int ll_readdir(struct file *filp, struct dir_context *ctx)
 {
-	struct inode		*inode	= file_inode(filp);
-	struct ll_file_data	*lfd	= LUSTRE_FPRIVATE(filp);
-	struct ll_sb_info	*sbi	= ll_i2sbi(inode);
+	struct inode *inode = file_inode(filp);
+	struct ll_file_data *lfd = LUSTRE_FPRIVATE(filp);
+	struct ll_sb_info *sbi	= ll_i2sbi(inode);
 	u64 pos = lfd ? lfd->lfd_pos : 0;
-	int			hash64	= sbi->ll_flags & LL_SBI_64BIT_HASH;
+	int hash64 = sbi->ll_flags & LL_SBI_64BIT_HASH;
 	bool api32 = ll_need_32bit_api(sbi);
 	struct md_op_data *op_data;
-	int			rc;
+	int rc;
 
 	CDEBUG(D_VFSTRACE,
 	       "VFS Op:inode=" DFID "(%p) pos/size %lu/%llu 32bit_api %d\n",
@@ -626,7 +626,7 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 		     struct ptlrpc_request **request, u64 valid)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
-	struct mdt_body   *body;
+	struct mdt_body *body;
 	struct lov_mds_md *lmm = NULL;
 	struct ptlrpc_request *req = NULL;
 	int rc, lmmsize;
@@ -744,8 +744,8 @@ int ll_get_mdt_idx(struct inode *inode)
  */
 static int ll_ioc_copy_start(struct super_block *sb, struct hsm_copy *copy)
 {
-	struct ll_sb_info		*sbi = ll_s2sbi(sb);
-	struct hsm_progress_kernel	 hpk;
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
+	struct hsm_progress_kernel hpk;
 	int rc2, rc = 0;
 
 	/* Forge a hsm_progress based on data from copy. */
@@ -759,8 +759,8 @@ static int ll_ioc_copy_start(struct super_block *sb, struct hsm_copy *copy)
 
 	/* For archive request, we need to read the current file version. */
 	if (copy->hc_hai.hai_action == HSMA_ARCHIVE) {
-		struct inode	*inode;
-		u64		 data_version = 0;
+		struct inode *inode;
+		u64 data_version = 0;
 
 		/* Get inode for this fid */
 		inode = search_inode_for_lustre(sb, &copy->hc_hai.hai_fid);
@@ -819,8 +819,8 @@ static int ll_ioc_copy_start(struct super_block *sb, struct hsm_copy *copy)
  */
 static int ll_ioc_copy_end(struct super_block *sb, struct hsm_copy *copy)
 {
-	struct ll_sb_info		*sbi = ll_s2sbi(sb);
-	struct hsm_progress_kernel	 hpk;
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
+	struct hsm_progress_kernel hpk;
 	int rc2, rc = 0;
 
 	/* If you modify the logic here, also check llapi_hsm_copy_end(). */
@@ -844,8 +844,8 @@ static int ll_ioc_copy_end(struct super_block *sb, struct hsm_copy *copy)
 	if (((copy->hc_hai.hai_action == HSMA_ARCHIVE) ||
 	     (copy->hc_hai.hai_action == HSMA_RESTORE)) &&
 	    (copy->hc_errval == 0)) {
-		struct inode	*inode;
-		u64		 data_version = 0;
+		struct inode *inode;
+		u64 data_version = 0;
 
 		/* Get lsm for this fid */
 		inode = search_inode_for_lustre(sb, &copy->hc_hai.hai_fid);
@@ -1160,13 +1160,13 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	}
 	case LL_IOC_LMV_SETSTRIPE: {
 		struct lmv_user_md  *lum;
-		char		*buf = NULL;
-		char		*filename;
-		int		 namelen = 0;
-		int		 lumlen = 0;
+		char *buf = NULL;
+		char *filename;
+		int namelen = 0;
+		int lumlen = 0;
 		umode_t mode;
-		int		 len;
-		int		 rc;
+		int len;
+		int rc;
 
 		rc = obd_ioctl_getdata(&buf, &len, (void __user *)arg);
 		if (rc)
@@ -1428,21 +1428,21 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			struct lov_user_mds_data __user *lmdp;
 			lstat_t st = { 0 };
 
-			st.st_dev     = inode->i_sb->s_dev;
-			st.st_mode    = body->mbo_mode;
-			st.st_nlink   = body->mbo_nlink;
-			st.st_uid     = body->mbo_uid;
-			st.st_gid     = body->mbo_gid;
-			st.st_rdev    = body->mbo_rdev;
-			st.st_size    = body->mbo_size;
+			st.st_dev = inode->i_sb->s_dev;
+			st.st_mode = body->mbo_mode;
+			st.st_nlink = body->mbo_nlink;
+			st.st_uid = body->mbo_uid;
+			st.st_gid = body->mbo_gid;
+			st.st_rdev = body->mbo_rdev;
+			st.st_size = body->mbo_size;
 			st.st_blksize = PAGE_SIZE;
-			st.st_blocks  = body->mbo_blocks;
-			st.st_atime   = body->mbo_atime;
-			st.st_mtime   = body->mbo_mtime;
-			st.st_ctime   = body->mbo_ctime;
-			st.st_ino     = cl_fid_build_ino(&body->mbo_fid1,
-							 sbi->ll_flags &
-							 LL_SBI_32BIT_API);
+			st.st_blocks = body->mbo_blocks;
+			st.st_atime = body->mbo_atime;
+			st.st_mtime = body->mbo_mtime;
+			st.st_ctime = body->mbo_ctime;
+			st.st_ino = cl_fid_build_ino(&body->mbo_fid1,
+						     sbi->ll_flags &
+						     LL_SBI_32BIT_API);
 
 			lmdp = (struct lov_user_mds_data __user *)arg;
 			if (copy_to_user(&lmdp->lmd_st, &st, sizeof(st))) {
@@ -1538,7 +1538,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	}
 	case LL_IOC_HSM_REQUEST: {
 		struct hsm_user_request	*hur;
-		ssize_t			 totalsize;
+		ssize_t	totalsize;
 
 		hur = memdup_user((void __user *)arg, sizeof(*hur));
 		if (IS_ERR(hur))
@@ -1592,8 +1592,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return rc;
 	}
 	case LL_IOC_HSM_PROGRESS: {
-		struct hsm_progress_kernel	hpk;
-		struct hsm_progress		hp;
+		struct hsm_progress_kernel hpk;
+		struct hsm_progress hp;
 
 		if (copy_from_user(&hp, (void __user *)arg, sizeof(hp)))
 			return -EFAULT;
@@ -1622,7 +1622,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 	case LL_IOC_HSM_COPY_START: {
 		struct hsm_copy	*copy;
-		int		 rc;
+		int rc;
 
 		copy = memdup_user((char __user *)arg, sizeof(*copy));
 		if (IS_ERR(copy))
@@ -1637,7 +1637,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	}
 	case LL_IOC_HSM_COPY_END: {
 		struct hsm_copy	*copy;
-		int		 rc;
+		int rc;
 
 		copy = memdup_user((char __user *)arg, sizeof(*copy));
 		if (IS_ERR(copy))
@@ -1756,11 +1756,11 @@ static int ll_dir_release(struct inode *inode, struct file *file)
 }
 
 const struct file_operations ll_dir_operations = {
-	.llseek   = ll_dir_seek,
-	.open     = ll_dir_open,
-	.release  = ll_dir_release,
-	.read     = generic_read_dir,
-	.iterate_shared  = ll_readdir,
-	.unlocked_ioctl   = ll_dir_ioctl,
-	.fsync    = ll_fsync,
+	.llseek			= ll_dir_seek,
+	.open			= ll_dir_open,
+	.release		= ll_dir_release,
+	.read			= generic_read_dir,
+	.iterate_shared		= ll_readdir,
+	.unlocked_ioctl		= ll_dir_ioctl,
+	.fsync			= ll_fsync,
 };
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index f71e273..6afaa90 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1119,7 +1119,7 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 				      file->f_flags & O_DIRECT ||
 				      IS_SYNC(inode);
 	}
-	io->ci_obj     = ll_i2info(inode)->lli_clob;
+	io->ci_obj = ll_i2info(inode)->lli_clob;
 	io->ci_lockreq = CILR_MAYBE;
 	if (ll_file_nolock(file)) {
 		io->ci_lockreq = CILR_NEVER;
@@ -1137,10 +1137,10 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 		   loff_t *ppos, size_t count)
 {
 	struct ll_inode_info *lli = ll_i2info(file_inode(file));
-	struct ll_file_data  *fd  = LUSTRE_FPRIVATE(file);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct vvp_io *vio = vvp_env_io(env);
 	struct range_lock range;
-	struct cl_io	 *io;
+	struct cl_io *io;
 	ssize_t result = 0;
 	int rc = 0;
 
@@ -1311,9 +1311,9 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 
 static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 {
-	struct lu_env      *env;
+	struct lu_env *env;
 	struct vvp_io_args *args;
-	ssize_t	     result;
+	ssize_t result;
 	u16 refcheck;
 	ssize_t rc2;
 
@@ -1346,9 +1346,9 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
  */
 static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 {
-	struct lu_env      *env;
+	struct lu_env *env;
 	struct vvp_io_args *args;
-	ssize_t	     result;
+	ssize_t result;
 	u16 refcheck;
 
 	env = cl_env_get(&refcheck);
@@ -1393,7 +1393,7 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 			     struct ptlrpc_request **request)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
-	struct mdt_body  *body;
+	struct mdt_body *body;
 	struct lov_mds_md *lmm = NULL;
 	struct ptlrpc_request *req = NULL;
 	struct md_op_data *op_data;
@@ -1439,7 +1439,7 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 
 	/*
 	 * This is coming from the MDS, so is probably in
-	 * little endian.  We convert it to host endian before
+	 * little endian. We convert it to host endian before
 	 * passing it to userspace.
 	 */
 	if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC) {
@@ -1483,11 +1483,11 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 static int ll_lov_setea(struct inode *inode, struct file *file,
 			void __user *arg)
 {
-	u64			 flags = MDS_OPEN_HAS_OBJS | FMODE_WRITE;
-	struct lov_user_md	*lump;
-	int			 lum_size = sizeof(struct lov_user_md) +
-					    sizeof(struct lov_user_ost_data);
-	int			 rc;
+	u64 flags = MDS_OPEN_HAS_OBJS | FMODE_WRITE;
+	struct lov_user_md *lump;
+	int lum_size = sizeof(struct lov_user_md) +
+		       sizeof(struct lov_user_ost_data);
+	int rc;
 
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
@@ -1562,11 +1562,11 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 static int
 ll_get_grouplock(struct inode *inode, struct file *file, unsigned long arg)
 {
-	struct ll_inode_info   *lli = ll_i2info(inode);
-	struct ll_file_data    *fd = LUSTRE_FPRIVATE(file);
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct cl_object *obj = lli->lli_clob;
-	struct ll_grouplock    grouplock;
-	int		     rc;
+	struct ll_grouplock grouplock;
+	int rc;
 
 	if (arg == 0) {
 		CWARN("group id for group lock must not be 0\n");
@@ -1635,9 +1635,9 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 static int ll_put_grouplock(struct inode *inode, struct file *file,
 			    unsigned long arg)
 {
-	struct ll_inode_info   *lli = ll_i2info(inode);
-	struct ll_file_data    *fd = LUSTRE_FPRIVATE(file);
-	struct ll_grouplock    grouplock;
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct ll_grouplock grouplock;
 
 	spin_lock(&lli->lli_lock);
 	if (!(fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
@@ -1931,12 +1931,12 @@ struct ll_swap_stack {
 static int ll_swap_layouts(struct file *file1, struct file *file2,
 			   struct lustre_swap_layouts *lsl)
 {
-	struct mdc_swap_layouts	 msl;
-	struct md_op_data	*op_data;
-	u32			 gid;
-	u64			 dv;
-	struct ll_swap_stack	*llss = NULL;
-	int			 rc;
+	struct mdc_swap_layouts msl;
+	struct md_op_data *op_data;
+	u32 gid;
+	u64 dv;
+	struct ll_swap_stack *llss = NULL;
+	int rc;
 
 	llss = kzalloc(sizeof(*llss), GFP_KERNEL);
 	if (!llss)
@@ -2041,8 +2041,8 @@ static int ll_swap_layouts(struct file *file1, struct file *file2,
 
 int ll_hsm_state_set(struct inode *inode, struct hsm_state_set *hss)
 {
-	struct md_op_data	*op_data;
-	int			 rc;
+	struct md_op_data *op_data;
+	int rc;
 
 	/* Detect out-of range masks */
 	if ((hss->hss_setmask | hss->hss_clearmask) & ~HSM_FLAGS_MASK)
@@ -2076,9 +2076,9 @@ int ll_hsm_state_set(struct inode *inode, struct hsm_state_set *hss)
 static int ll_hsm_import(struct inode *inode, struct file *file,
 			 struct hsm_user_import *hui)
 {
-	struct hsm_state_set	*hss = NULL;
-	struct iattr		*attr = NULL;
-	int			 rc;
+	struct hsm_state_set *hss = NULL;
+	struct iattr *attr = NULL;
+	int rc;
 
 	if (!S_ISREG(inode->i_mode))
 		return -EINVAL;
@@ -2303,9 +2303,9 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 static long
 ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
-	struct inode		*inode = file_inode(file);
-	struct ll_file_data	*fd = LUSTRE_FPRIVATE(file);
-	int			 flags, rc;
+	struct inode *inode = file_inode(file);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	int flags, rc;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p),cmd=%x\n",
 	       PFID(ll_inode2fid(inode)), inode, cmd);
@@ -2434,7 +2434,7 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 		return ll_fid2path(inode, (void __user *)arg);
 	case LL_IOC_DATA_VERSION: {
 		struct ioc_data_version	idv;
-		int			rc;
+		int rc;
 
 		if (copy_from_user(&idv, (char __user *)arg, sizeof(idv)))
 			return -EFAULT;
@@ -2464,9 +2464,9 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 	case OBD_IOC_GETMDNAME:
 		return ll_get_obd_name(inode, cmd, arg);
 	case LL_IOC_HSM_STATE_GET: {
-		struct md_op_data	*op_data;
-		struct hsm_user_state	*hus;
-		int			 rc;
+		struct md_op_data *op_data;
+		struct hsm_user_state *hus;
+		int rc;
 
 		hus = kzalloc(sizeof(*hus), GFP_KERNEL);
 		if (!hus)
@@ -2490,8 +2490,8 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 		return rc;
 	}
 	case LL_IOC_HSM_STATE_SET: {
-		struct hsm_state_set	*hss;
-		int			 rc;
+		struct hsm_state_set *hss;
+		int rc;
 
 		hss = memdup_user((char __user *)arg, sizeof(*hss));
 		if (IS_ERR(hss))
@@ -2503,9 +2503,9 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 		return rc;
 	}
 	case LL_IOC_HSM_ACTION: {
-		struct md_op_data		*op_data;
-		struct hsm_current_action	*hca;
-		int				 rc;
+		struct md_op_data *op_data;
+		struct hsm_current_action *hca;
+		int rc;
 
 		hca = kzalloc(sizeof(*hca), GFP_KERNEL);
 		if (!hca)
@@ -3564,56 +3564,56 @@ int ll_inode_permission(struct inode *inode, int mask)
 
 /* -o localflock - only provides locally consistent flock locks */
 const struct file_operations ll_file_operations = {
-	.read_iter = ll_file_read_iter,
-	.write_iter = ll_file_write_iter,
-	.unlocked_ioctl = ll_file_ioctl,
-	.open	   = ll_file_open,
-	.release	= ll_file_release,
-	.mmap	   = ll_file_mmap,
-	.llseek	 = ll_file_seek,
-	.splice_read    = generic_file_splice_read,
-	.fsync	  = ll_fsync,
-	.flush	  = ll_flush
+	.read_iter		= ll_file_read_iter,
+	.write_iter		= ll_file_write_iter,
+	.unlocked_ioctl		= ll_file_ioctl,
+	.open			= ll_file_open,
+	.release		= ll_file_release,
+	.mmap			= ll_file_mmap,
+	.llseek			= ll_file_seek,
+	.splice_read		= generic_file_splice_read,
+	.fsync			= ll_fsync,
+	.flush			= ll_flush
 };
 
 const struct file_operations ll_file_operations_flock = {
-	.read_iter    = ll_file_read_iter,
-	.write_iter   = ll_file_write_iter,
-	.unlocked_ioctl = ll_file_ioctl,
-	.open	   = ll_file_open,
-	.release	= ll_file_release,
-	.mmap	   = ll_file_mmap,
-	.llseek	 = ll_file_seek,
-	.splice_read    = generic_file_splice_read,
-	.fsync	  = ll_fsync,
-	.flush	  = ll_flush,
-	.flock	  = ll_file_flock,
-	.lock	   = ll_file_flock
+	.read_iter		= ll_file_read_iter,
+	.write_iter		= ll_file_write_iter,
+	.unlocked_ioctl		= ll_file_ioctl,
+	.open			= ll_file_open,
+	.release		= ll_file_release,
+	.mmap			= ll_file_mmap,
+	.llseek			= ll_file_seek,
+	.splice_read		= generic_file_splice_read,
+	.fsync			= ll_fsync,
+	.flush			= ll_flush,
+	.flock			= ll_file_flock,
+	.lock			= ll_file_flock
 };
 
 /* These are for -o noflock - to return ENOSYS on flock calls */
 const struct file_operations ll_file_operations_noflock = {
-	.read_iter    = ll_file_read_iter,
-	.write_iter   = ll_file_write_iter,
-	.unlocked_ioctl = ll_file_ioctl,
-	.open	   = ll_file_open,
-	.release	= ll_file_release,
-	.mmap	   = ll_file_mmap,
-	.llseek	 = ll_file_seek,
-	.splice_read    = generic_file_splice_read,
-	.fsync	  = ll_fsync,
-	.flush	  = ll_flush,
-	.flock	  = ll_file_noflock,
-	.lock	   = ll_file_noflock
+	.read_iter		= ll_file_read_iter,
+	.write_iter		= ll_file_write_iter,
+	.unlocked_ioctl		= ll_file_ioctl,
+	.open			= ll_file_open,
+	.release		= ll_file_release,
+	.mmap			= ll_file_mmap,
+	.llseek			= ll_file_seek,
+	.splice_read		= generic_file_splice_read,
+	.fsync			= ll_fsync,
+	.flush			= ll_flush,
+	.flock			= ll_file_noflock,
+	.lock			= ll_file_noflock
 };
 
 const struct inode_operations ll_file_inode_operations = {
-	.setattr	= ll_setattr,
-	.getattr	= ll_getattr,
-	.permission	= ll_inode_permission,
-	.listxattr	= ll_listxattr,
-	.fiemap		= ll_fiemap,
-	.get_acl	= ll_get_acl,
+	.setattr		= ll_setattr,
+	.getattr		= ll_getattr,
+	.permission		= ll_inode_permission,
+	.listxattr		= ll_listxattr,
+	.fiemap			= ll_fiemap,
+	.get_acl		= ll_get_acl,
 };
 
 int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf)
@@ -3746,7 +3746,7 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 			      struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct ll_sb_info    *sbi = ll_i2sbi(inode);
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ldlm_lock *lock;
 	struct cl_object_conf conf;
 	int rc = 0;
@@ -3834,10 +3834,10 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
  */
 static int ll_layout_intent(struct inode *inode, struct layout_intent *intent)
 {
-	struct ll_inode_info  *lli = ll_i2info(inode);
-	struct ll_sb_info     *sbi = ll_i2sbi(inode);
-	struct md_op_data     *op_data;
-	struct lookup_intent   it;
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct md_op_data *op_data;
+	struct lookup_intent it;
 	struct ptlrpc_request *req;
 	int rc;
 
@@ -3966,7 +3966,7 @@ int ll_layout_write_intent(struct inode *inode, u64 start, u64 end)
 int ll_layout_restore(struct inode *inode, loff_t offset, u64 length)
 {
 	struct hsm_user_request	*hur;
-	int			 len, rc;
+	int len, rc;
 
 	len = sizeof(struct hsm_user_request) +
 	      sizeof(struct hsm_user_item);
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index d8712a3..27c233d 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -65,7 +65,7 @@ blkcnt_t dirty_cnt(struct inode *inode)
 {
 	blkcnt_t cnt = 0;
 	struct vvp_object *vob = cl_inode2vvp(inode);
-	void	      *results[1];
+	void *results[1];
 
 	if (inode->i_mapping)
 		cnt += radix_tree_gang_lookup_tag(&inode->i_mapping->i_pages,
@@ -80,7 +80,7 @@ blkcnt_t dirty_cnt(struct inode *inode)
 int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 		    struct inode *inode, struct cl_object *clob, int agl)
 {
-	const struct lu_fid  *fid   = lu_object_fid(&clob->co_lu);
+	const struct lu_fid *fid = lu_object_fid(&clob->co_lu);
 	struct cl_lock *lock = vvp_env_lock(env);
 	struct cl_lock_descr *descr = &lock->cll_descr;
 	int result = 0;
@@ -140,10 +140,10 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 static int cl_io_get(struct inode *inode, struct lu_env **envout,
 		     struct cl_io **ioout, u16 *refcheck)
 {
-	struct lu_env	  *env;
-	struct cl_io	   *io;
-	struct ll_inode_info	*lli = ll_i2info(inode);
-	struct cl_object       *clob = lli->lli_clob;
+	struct lu_env *env;
+	struct cl_io *io;
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct cl_object *clob = lli->lli_clob;
 	int result;
 
 	if (S_ISREG(inode->i_mode)) {
@@ -175,9 +175,9 @@ int __cl_glimpse_size(struct inode *inode, int agl)
 	 * cl_glimpse_size(), which doesn't make sense: glimpse locks are not
 	 * blocking anyway.
 	 */
-	struct lu_env	  *env = NULL;
-	struct cl_io	   *io  = NULL;
-	int		     result;
+	struct lu_env *env = NULL;
+	struct cl_io *io  = NULL;
+	int result;
 	u16 refcheck;
 
 	result = cl_io_get(inode, &env, &io, &refcheck);
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index ade3b12..afcaa5e 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -83,8 +83,8 @@ int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
 		   enum op_xvalid xvalid, unsigned int attr_flags)
 {
 	struct lu_env *env;
-	struct cl_io  *io;
-	int	    result;
+	struct cl_io *io;
+	int result;
 	u16 refcheck;
 
 	env = cl_env_get(&refcheck);
@@ -137,11 +137,11 @@ int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
  */
 int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 {
-	struct lu_env	*env;
+	struct lu_env *env;
 	struct ll_inode_info *lli;
-	struct cl_object     *clob;
-	struct lu_site       *site;
-	struct lu_fid	*fid;
+	struct cl_object *clob;
+	struct lu_site *site;
+	struct lu_fid *fid;
 	struct cl_object_conf conf = {
 		.coc_inode = inode,
 		.u = {
@@ -159,8 +159,8 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 		return PTR_ERR(env);
 
 	site = ll_i2sbi(inode)->ll_site;
-	lli  = ll_i2info(inode);
-	fid  = &lli->lli_fid;
+	lli = ll_i2info(inode);
+	fid = &lli->lli_fid;
 	LASSERT(fid_is_sane(fid));
 
 	if (!lli->lli_clob) {
@@ -207,7 +207,7 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 static void cl_object_put_last(struct lu_env *env, struct cl_object *obj)
 {
 	struct lu_object_header *header = obj->co_lu.lo_header;
-	wait_queue_entry_t	   waiter;
+	wait_queue_entry_t waiter;
 
 	if (unlikely(atomic_read(&header->loh_ref) != 1)) {
 		struct lu_site *site = obj->co_lu.lo_dev->ld_site;
@@ -234,9 +234,9 @@ static void cl_object_put_last(struct lu_env *env, struct cl_object *obj)
 
 void cl_inode_fini(struct inode *inode)
 {
-	struct lu_env	   *env;
-	struct ll_inode_info    *lli  = ll_i2info(inode);
-	struct cl_object	*clob = lli->lli_clob;
+	struct lu_env *env;
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct cl_object *clob = lli->lli_clob;
 	u16 refcheck;
 	int emergency;
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 88b08dd..8e09fdd7 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -185,25 +185,25 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	data->ocd_grant_blkbits = PAGE_SHIFT;
 
 	/* indicate the features supported by this client */
-	data->ocd_connect_flags = OBD_CONNECT_IBITS    | OBD_CONNECT_NODEVOH  |
-				  OBD_CONNECT_ATTRFID  |
-				  OBD_CONNECT_VERSION  | OBD_CONNECT_BRW_SIZE |
-				  OBD_CONNECT_CANCELSET | OBD_CONNECT_FID     |
-				  OBD_CONNECT_AT       | OBD_CONNECT_LOV_V3   |
-				  OBD_CONNECT_VBR	| OBD_CONNECT_FULL20  |
+	data->ocd_connect_flags = OBD_CONNECT_IBITS	| OBD_CONNECT_NODEVOH  |
+				  OBD_CONNECT_ATTRFID	|
+				  OBD_CONNECT_VERSION	| OBD_CONNECT_BRW_SIZE |
+				  OBD_CONNECT_CANCELSET | OBD_CONNECT_FID      |
+				  OBD_CONNECT_AT	| OBD_CONNECT_LOV_V3   |
+				  OBD_CONNECT_VBR	| OBD_CONNECT_FULL20   |
 				  OBD_CONNECT_64BITHASH |
 				  OBD_CONNECT_EINPROGRESS |
-				  OBD_CONNECT_JOBSTATS | OBD_CONNECT_LVB_TYPE |
-				  OBD_CONNECT_LAYOUTLOCK |
-				  OBD_CONNECT_PINGLESS |
-				  OBD_CONNECT_MAX_EASIZE |
-				  OBD_CONNECT_FLOCK_DEAD |
+				  OBD_CONNECT_JOBSTATS	| OBD_CONNECT_LVB_TYPE |
+				  OBD_CONNECT_LAYOUTLOCK  |
+				  OBD_CONNECT_PINGLESS	|
+				  OBD_CONNECT_MAX_EASIZE  |
+				  OBD_CONNECT_FLOCK_DEAD  |
 				  OBD_CONNECT_DISP_STRIPE | OBD_CONNECT_LFSCK |
 				  OBD_CONNECT_OPEN_BY_FID |
-				  OBD_CONNECT_DIR_STRIPE |
-				  OBD_CONNECT_BULK_MBITS |
-				  OBD_CONNECT_SUBTREE |
-				  OBD_CONNECT_FLAGS2 | OBD_CONNECT_MULTIMODRPCS;
+				  OBD_CONNECT_DIR_STRIPE  |
+				  OBD_CONNECT_BULK_MBITS  |
+				  OBD_CONNECT_SUBTREE	  |
+				  OBD_CONNECT_FLAGS2	  | OBD_CONNECT_MULTIMODRPCS;
 
 	data->ocd_connect_flags2 = 0;
 
@@ -382,9 +382,9 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_VBR	| OBD_CONNECT_FULL20   |
 				  OBD_CONNECT_64BITHASH | OBD_CONNECT_MAXBYTES |
 				  OBD_CONNECT_EINPROGRESS |
-				  OBD_CONNECT_JOBSTATS | OBD_CONNECT_LVB_TYPE |
-				  OBD_CONNECT_LAYOUTLOCK |
-				  OBD_CONNECT_PINGLESS | OBD_CONNECT_LFSCK |
+				  OBD_CONNECT_JOBSTATS	| OBD_CONNECT_LVB_TYPE |
+				  OBD_CONNECT_LAYOUTLOCK  |
+				  OBD_CONNECT_PINGLESS	| OBD_CONNECT_LFSCK |
 				  OBD_CONNECT_BULK_MBITS;
 
 	data->ocd_connect_flags2 = 0;
@@ -913,13 +913,13 @@ int ll_fill_super(struct super_block *sb)
 	struct lustre_profile *lprof = NULL;
 	struct lustre_sb_info *lsi = s2lsi(sb);
 	struct ll_sb_info *sbi;
-	char  *dt = NULL, *md = NULL;
-	char  *profilenm = get_profile_name(sb);
+	char *dt = NULL, *md = NULL;
+	char *profilenm = get_profile_name(sb);
 	struct config_llog_instance *cfg;
 	char name[MAX_STRING_SIZE];
 	char *ptr;
 	int len;
-	int    err;
+	int err;
 	static atomic_t ll_bdi_num = ATOMIC_INIT(0);
 
 	CDEBUG(D_VFSTRACE, "VFS Op: sb %p\n", sb);
@@ -2073,7 +2073,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 
 int ll_flush_ctx(struct inode *inode)
 {
-	struct ll_sb_info  *sbi = ll_i2sbi(inode);
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
 
 	CDEBUG(D_SEC, "flush context for user %d\n",
 	       from_kuid(&init_user_ns, current_uid()));
@@ -2186,10 +2186,10 @@ int ll_remount_fs(struct super_block *sb, int *flags, char *data)
  */
 void ll_open_cleanup(struct super_block *sb, struct ptlrpc_request *open_req)
 {
-	struct mdt_body			*body;
-	struct md_op_data		*op_data;
-	struct ptlrpc_request		*close_req = NULL;
-	struct obd_export		*exp	   = ll_s2sbi(sb)->ll_md_exp;
+	struct mdt_body	*body;
+	struct md_op_data *op_data;
+	struct ptlrpc_request *close_req = NULL;
+	struct obd_export *exp = ll_s2sbi(sb)->ll_md_exp;
 
 	body = req_capsule_server_get(&open_req->rq_pill, &RMF_MDT_BODY);
 	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index c6e9f10..f5aaaf7 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -90,11 +90,11 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 ll_fault_io_init(struct lu_env *env, struct vm_area_struct *vma,
 		 pgoff_t index, unsigned long *ra_flags)
 {
-	struct file	       *file = vma->vm_file;
-	struct inode	       *inode = file_inode(file);
-	struct cl_io	       *io;
-	struct cl_fault_io     *fio;
-	int			rc;
+	struct file *file = vma->vm_file;
+	struct inode *inode = file_inode(file);
+	struct cl_io *io;
+	struct cl_fault_io *fio;
+	int rc;
 
 	if (ll_file_nolock(file))
 		return ERR_PTR(-EOPNOTSUPP);
@@ -105,7 +105,7 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 	LASSERT(io->ci_obj);
 
 	fio = &io->u.ci_fault;
-	fio->ft_index      = index;
+	fio->ft_index = index;
 	fio->ft_executable = vma->vm_flags & VM_EXEC;
 
 	/*
@@ -146,14 +146,14 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 static int __ll_page_mkwrite(struct vm_area_struct *vma, struct page *vmpage,
 			     bool *retry)
 {
-	struct lu_env	   *env;
-	struct cl_io	    *io;
-	struct vvp_io	   *vio;
-	int		      result;
+	struct lu_env *env;
+	struct cl_io *io;
+	struct vvp_io *vio;
+	int result;
 	u16 refcheck;
-	sigset_t	     old, new;
-	struct inode	     *inode;
-	struct ll_inode_info     *lli;
+	sigset_t old, new;
+	struct inode *inode;
+	struct ll_inode_info *lli;
 
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
@@ -173,7 +173,7 @@ static int __ll_page_mkwrite(struct vm_area_struct *vma, struct page *vmpage,
 	io->u.ci_fault.ft_writable = 1;
 
 	vio = vvp_env_io(env);
-	vio->u.fault.ft_vma    = vma;
+	vio->u.fault.ft_vma = vma;
 	vio->u.fault.ft_vmpage = vmpage;
 
 	siginitsetinv(&new, sigmask(SIGKILL) | sigmask(SIGTERM));
@@ -263,13 +263,13 @@ static inline vm_fault_t to_fault_error(int result)
  */
 static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	struct lu_env	   *env;
-	struct cl_io	    *io;
-	struct vvp_io	   *vio = NULL;
-	struct page	     *vmpage;
-	unsigned long	    ra_flags;
-	int		      result = 0;
-	vm_fault_t		fault_ret = 0;
+	struct lu_env *env;
+	struct cl_io *io;
+	struct vvp_io *vio = NULL;
+	struct page *vmpage;
+	unsigned long ra_flags;
+	int result = 0;
+	vm_fault_t fault_ret = 0;
 	u16 refcheck;
 
 	env = cl_env_get(&refcheck);
@@ -307,8 +307,8 @@ static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	result = io->ci_result;
 	if (result == 0) {
 		vio = vvp_env_io(env);
-		vio->u.fault.ft_vma       = vma;
-		vio->u.fault.ft_vmpage    = NULL;
+		vio->u.fault.ft_vma = vma;
+		vio->u.fault.ft_vmpage = NULL;
 		vio->u.fault.ft_vmf = vmf;
 		vio->u.fault.ft_flags = 0;
 		vio->u.fault.ft_flags_valid = false;
@@ -444,7 +444,7 @@ static vm_fault_t ll_page_mkwrite(struct vm_fault *vmf)
  */
 static void ll_vm_open(struct vm_area_struct *vma)
 {
-	struct inode *inode    = file_inode(vma->vm_file);
+	struct inode *inode = file_inode(vma->vm_file);
 	struct vvp_object *vob = cl_inode2vvp(inode);
 
 	LASSERT(atomic_read(&vob->vob_mmap_cnt) >= 0);
@@ -456,8 +456,8 @@ static void ll_vm_open(struct vm_area_struct *vma)
  */
 static void ll_vm_close(struct vm_area_struct *vma)
 {
-	struct inode      *inode = file_inode(vma->vm_file);
-	struct vvp_object *vob   = cl_inode2vvp(inode);
+	struct inode *inode = file_inode(vma->vm_file);
+	struct vvp_object *vob = cl_inode2vvp(inode);
 
 	atomic_dec(&vob->vob_mmap_cnt);
 	LASSERT(atomic_read(&vob->vob_mmap_cnt) >= 0);
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 7c5c9b8..3f34073 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -76,14 +76,14 @@ void get_uuid2fsid(const char *name, int len, __kernel_fsid_t *fsid)
 struct inode *search_inode_for_lustre(struct super_block *sb,
 				      const struct lu_fid *fid)
 {
-	struct ll_sb_info     *sbi = ll_s2sbi(sb);
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct ptlrpc_request *req = NULL;
-	struct inode	  *inode = NULL;
-	int		   eadatalen = 0;
-	unsigned long	      hash = cl_fid_build_ino(fid,
-						      ll_need_32bit_api(sbi));
-	struct  md_op_data    *op_data;
-	int		   rc;
+	struct inode *inode = NULL;
+	int eadatalen = 0;
+	unsigned long hash = cl_fid_build_ino(fid,
+					      ll_need_32bit_api(sbi));
+	struct md_op_data *op_data;
+	int rc;
 
 	CDEBUG(D_INFO, "searching inode for:(%lu," DFID ")\n", hash, PFID(fid));
 
@@ -123,15 +123,15 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 }
 
 struct lustre_nfs_fid {
-	struct lu_fid   lnf_child;
-	struct lu_fid   lnf_parent;
+	struct lu_fid	lnf_child;
+	struct lu_fid	lnf_parent;
 };
 
 static struct dentry *
 ll_iget_for_nfs(struct super_block *sb,
 		struct lu_fid *fid, struct lu_fid *parent)
 {
-	struct inode  *inode;
+	struct inode *inode;
 	struct dentry *result;
 
 	if (!fid_is_sane(fid))
@@ -179,7 +179,7 @@ struct lustre_nfs_fid {
 
 /**
  * \a connectable - is nfsd will connect himself or this should be done
- *		  at lustre
+ *		    at lustre
  *
  * The return value is file handle type:
  * 1 -- contains child file handle;
@@ -297,12 +297,12 @@ static struct dentry *ll_fh_to_parent(struct super_block *sb, struct fid *fid,
 int ll_dir_get_parent_fid(struct inode *dir, struct lu_fid *parent_fid)
 {
 	struct ptlrpc_request *req = NULL;
-	struct ll_sb_info     *sbi;
-	struct mdt_body       *body;
+	struct ll_sb_info *sbi;
+	struct mdt_body *body;
 	static const char dotdot[] = "..";
-	struct md_op_data     *op_data;
-	int		   rc;
-	int		      lmmsize;
+	struct md_op_data *op_data;
+	int rc;
+	int lmmsize;
 
 	LASSERT(dir && S_ISDIR(dir->i_mode));
 
@@ -361,9 +361,9 @@ static struct dentry *ll_get_parent(struct dentry *dchild)
 }
 
 const struct export_operations lustre_export_operations = {
-	.get_parent = ll_get_parent,
-	.encode_fh  = ll_encode_fh,
-	.get_name   = ll_get_name,
-	.fh_to_dentry = ll_fh_to_dentry,
-	.fh_to_parent = ll_fh_to_parent,
+	.get_parent	= ll_get_parent,
+	.encode_fh	= ll_encode_fh,
+	.get_name	= ll_get_name,
+	.fh_to_dentry	= ll_fh_to_dentry,
+	.fh_to_parent	= ll_fh_to_parent,
 };
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 672de81..001bed9 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -452,8 +452,8 @@ static ssize_t max_read_ahead_whole_mb_store(struct kobject *kobj,
 
 static int ll_max_cached_mb_seq_show(struct seq_file *m, void *v)
 {
-	struct super_block     *sb    = m->private;
-	struct ll_sb_info      *sbi   = ll_s2sbi(sb);
+	struct super_block *sb = m->private;
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct cl_client_cache *cache = sbi->ll_cache;
 	int shift = 20 - PAGE_SHIFT;
 	long max_cached_mb;
@@ -1050,8 +1050,8 @@ static ssize_t fast_read_store(struct kobject *kobj,
 
 static int ll_unstable_stats_seq_show(struct seq_file *m, void *v)
 {
-	struct super_block     *sb    = m->private;
-	struct ll_sb_info      *sbi   = ll_s2sbi(sb);
+	struct super_block *sb = m->private;
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct cl_client_cache *cache = sbi->ll_cache;
 	long pages;
 	int mb;
@@ -1232,9 +1232,9 @@ static void llite_kobj_release(struct kobject *kobj)
 };
 
 static const struct llite_file_opcode {
-	u32       opcode;
-	u32       type;
-	const char *opname;
+	u32		opcode;
+	u32		type;
+	const char	*opname;
 } llite_opcode_table[LPROC_LL_FILE_OPCODES] = {
 	/* file operation */
 	{ LPROC_LL_DIRTY_HITS,     LPROCFS_TYPE_REGS, "dirty_pages_hits" },
@@ -1247,31 +1247,31 @@ static void llite_kobj_release(struct kobject *kobj)
 				   "brw_read" },
 	{ LPROC_LL_BRW_WRITE,      LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_PAGES,
 				   "brw_write" },
-	{ LPROC_LL_IOCTL,	  LPROCFS_TYPE_REGS, "ioctl" },
+	{ LPROC_LL_IOCTL,	   LPROCFS_TYPE_REGS, "ioctl" },
 	{ LPROC_LL_OPEN,	   LPROCFS_TYPE_REGS, "open" },
-	{ LPROC_LL_RELEASE,	LPROCFS_TYPE_REGS, "close" },
-	{ LPROC_LL_MAP,	    LPROCFS_TYPE_REGS, "mmap" },
-	{ LPROC_LL_FAULT,		LPROCFS_TYPE_REGS, "page_fault" },
-	{ LPROC_LL_MKWRITE,		LPROCFS_TYPE_REGS, "page_mkwrite" },
-	{ LPROC_LL_LLSEEK,	 LPROCFS_TYPE_REGS, "seek" },
-	{ LPROC_LL_FSYNC,	  LPROCFS_TYPE_REGS, "fsync" },
-	{ LPROC_LL_READDIR,	LPROCFS_TYPE_REGS, "readdir" },
+	{ LPROC_LL_RELEASE,	   LPROCFS_TYPE_REGS, "close" },
+	{ LPROC_LL_MAP,		   LPROCFS_TYPE_REGS, "mmap" },
+	{ LPROC_LL_FAULT,	   LPROCFS_TYPE_REGS, "page_fault" },
+	{ LPROC_LL_MKWRITE,	   LPROCFS_TYPE_REGS, "page_mkwrite" },
+	{ LPROC_LL_LLSEEK,	   LPROCFS_TYPE_REGS, "seek" },
+	{ LPROC_LL_FSYNC,	   LPROCFS_TYPE_REGS, "fsync" },
+	{ LPROC_LL_READDIR,	   LPROCFS_TYPE_REGS, "readdir" },
 	/* inode operation */
-	{ LPROC_LL_SETATTR,	LPROCFS_TYPE_REGS, "setattr" },
-	{ LPROC_LL_TRUNC,	  LPROCFS_TYPE_REGS, "truncate" },
-	{ LPROC_LL_FLOCK,	  LPROCFS_TYPE_REGS, "flock" },
-	{ LPROC_LL_GETATTR,	LPROCFS_TYPE_REGS, "getattr" },
+	{ LPROC_LL_SETATTR,	   LPROCFS_TYPE_REGS, "setattr" },
+	{ LPROC_LL_TRUNC,	   LPROCFS_TYPE_REGS, "truncate" },
+	{ LPROC_LL_FLOCK,	   LPROCFS_TYPE_REGS, "flock" },
+	{ LPROC_LL_GETATTR,	   LPROCFS_TYPE_REGS, "getattr" },
 	/* dir inode operation */
-	{ LPROC_LL_CREATE,	 LPROCFS_TYPE_REGS, "create" },
+	{ LPROC_LL_CREATE,	   LPROCFS_TYPE_REGS, "create" },
 	{ LPROC_LL_LINK,	   LPROCFS_TYPE_REGS, "link" },
-	{ LPROC_LL_UNLINK,	 LPROCFS_TYPE_REGS, "unlink" },
-	{ LPROC_LL_SYMLINK,	LPROCFS_TYPE_REGS, "symlink" },
-	{ LPROC_LL_MKDIR,	  LPROCFS_TYPE_REGS, "mkdir" },
-	{ LPROC_LL_RMDIR,	  LPROCFS_TYPE_REGS, "rmdir" },
-	{ LPROC_LL_MKNOD,	  LPROCFS_TYPE_REGS, "mknod" },
-	{ LPROC_LL_RENAME,	 LPROCFS_TYPE_REGS, "rename" },
+	{ LPROC_LL_UNLINK,	   LPROCFS_TYPE_REGS, "unlink" },
+	{ LPROC_LL_SYMLINK,	   LPROCFS_TYPE_REGS, "symlink" },
+	{ LPROC_LL_MKDIR,	   LPROCFS_TYPE_REGS, "mkdir" },
+	{ LPROC_LL_RMDIR,	   LPROCFS_TYPE_REGS, "rmdir" },
+	{ LPROC_LL_MKNOD,	   LPROCFS_TYPE_REGS, "mknod" },
+	{ LPROC_LL_RENAME,	   LPROCFS_TYPE_REGS, "rename" },
 	/* special inode operation */
-	{ LPROC_LL_STAFS,	  LPROCFS_TYPE_REGS, "statfs" },
+	{ LPROC_LL_STAFS,	   LPROCFS_TYPE_REGS, "statfs" },
 	{ LPROC_LL_ALLOC_INODE,    LPROCFS_TYPE_REGS, "alloc_inode" },
 	{ LPROC_LL_SETXATTR,       LPROCFS_TYPE_REGS, "setxattr" },
 	{ LPROC_LL_GETXATTR,       LPROCFS_TYPE_REGS, "getxattr" },
@@ -1301,19 +1301,19 @@ void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, int count)
 EXPORT_SYMBOL(ll_stats_ops_tally);
 
 static const char *ra_stat_string[] = {
-	[RA_STAT_HIT] = "hits",
-	[RA_STAT_MISS] = "misses",
-	[RA_STAT_DISTANT_READPAGE] = "readpage not consecutive",
-	[RA_STAT_MISS_IN_WINDOW] = "miss inside window",
-	[RA_STAT_FAILED_GRAB_PAGE] = "failed grab_cache_page",
-	[RA_STAT_FAILED_MATCH] = "failed lock match",
-	[RA_STAT_DISCARDED] = "read but discarded",
-	[RA_STAT_ZERO_LEN] = "zero length file",
-	[RA_STAT_ZERO_WINDOW] = "zero size window",
-	[RA_STAT_EOF] = "read-ahead to EOF",
-	[RA_STAT_MAX_IN_FLIGHT] = "hit max r-a issue",
-	[RA_STAT_WRONG_GRAB_PAGE] = "wrong page from grab_cache_page",
-	[RA_STAT_FAILED_REACH_END] = "failed to reach end"
+	[RA_STAT_HIT]			= "hits",
+	[RA_STAT_MISS]			= "misses",
+	[RA_STAT_DISTANT_READPAGE]	= "readpage not consecutive",
+	[RA_STAT_MISS_IN_WINDOW]	= "miss inside window",
+	[RA_STAT_FAILED_GRAB_PAGE]	= "failed grab_cache_page",
+	[RA_STAT_FAILED_MATCH]		= "failed lock match",
+	[RA_STAT_DISCARDED]		= "read but discarded",
+	[RA_STAT_ZERO_LEN]		= "zero length file",
+	[RA_STAT_ZERO_WINDOW]		= "zero size window",
+	[RA_STAT_EOF]			= "read-ahead to EOF",
+	[RA_STAT_MAX_IN_FLIGHT]		= "hit max r-a issue",
+	[RA_STAT_WRONG_GRAB_PAGE]	= "wrong page from grab_cache_page",
+	[RA_STAT_FAILED_REACH_END]	= "failed to reach end"
 };
 
 int ll_debugfs_register_super(struct super_block *sb, const char *name)
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 8bdf947..a87c8a2 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -53,7 +53,7 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 static int ll_test_inode(struct inode *inode, void *opaque)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct lustre_md     *md = opaque;
+	struct lustre_md *md = opaque;
 
 	if (unlikely(!(md->body->mbo_valid & OBD_MD_FLID))) {
 		CERROR("MDS body missing FID\n");
@@ -102,7 +102,7 @@ static int ll_set_inode(struct inode *inode, void *opaque)
 struct inode *ll_iget(struct super_block *sb, ino_t hash,
 		      struct lustre_md *md)
 {
-	struct inode	 *inode;
+	struct inode *inode;
 	int rc = 0;
 
 	LASSERT(hash != 0);
@@ -499,8 +499,9 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		 */
 		/* Check that parent has UPDATE lock. */
 		struct lookup_intent parent_it = {
-					.it_op = IT_GETATTR,
-					.it_lock_handle = 0 };
+			.it_op = IT_GETATTR,
+			.it_lock_handle = 0
+		};
 		struct lu_fid fid = ll_i2info(parent)->lli_fid;
 
 		/* If it is striped directory, get the real stripe parent */
@@ -1255,28 +1256,28 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 }
 
 const struct inode_operations ll_dir_inode_operations = {
-	.mknod	      = ll_mknod,
-	.atomic_open	    = ll_atomic_open,
-	.lookup	     = ll_lookup_nd,
-	.create	     = ll_create_nd,
+	.mknod			= ll_mknod,
+	.atomic_open		= ll_atomic_open,
+	.lookup			= ll_lookup_nd,
+	.create			= ll_create_nd,
 	/* We need all these non-raw things for NFSD, to not patch it. */
-	.unlink	     = ll_unlink,
-	.mkdir	      = ll_mkdir,
-	.rmdir	      = ll_rmdir,
-	.symlink	    = ll_symlink,
-	.link	       = ll_link,
-	.rename		= ll_rename,
-	.setattr	    = ll_setattr,
-	.getattr	    = ll_getattr,
-	.permission	 = ll_inode_permission,
-	.listxattr	  = ll_listxattr,
-	.get_acl	    = ll_get_acl,
+	.unlink			= ll_unlink,
+	.mkdir			= ll_mkdir,
+	.rmdir			= ll_rmdir,
+	.symlink		= ll_symlink,
+	.link			= ll_link,
+	.rename			= ll_rename,
+	.setattr		= ll_setattr,
+	.getattr		= ll_getattr,
+	.permission		= ll_inode_permission,
+	.listxattr		= ll_listxattr,
+	.get_acl		= ll_get_acl,
 };
 
 const struct inode_operations ll_special_inode_operations = {
-	.setattr	= ll_setattr,
-	.getattr	= ll_getattr,
-	.permission     = ll_inode_permission,
-	.listxattr      = ll_listxattr,
-	.get_acl	    = ll_get_acl,
+	.setattr		= ll_setattr,
+	.getattr		= ll_getattr,
+	.permission		= ll_inode_permission,
+	.listxattr		= ll_listxattr,
+	.get_acl		= ll_get_acl,
 };
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index e207d7c..af983ee 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -309,7 +309,7 @@ static inline int stride_io_mode(struct ll_readahead_state *ras)
 static int ria_page_count(struct ra_io_arg *ria)
 {
 	u64 length = ria->ria_end >= ria->ria_start ?
-		       ria->ria_end - ria->ria_start + 1 : 0;
+		     ria->ria_end - ria->ria_start + 1 : 0;
 
 	return stride_pg_count(ria->ria_stoff, ria->ria_length,
 			       ria->ria_pages, ria->ria_start,
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 9843c9e..e4ce3b6 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -67,9 +67,9 @@
 static void ll_invalidatepage(struct page *vmpage, unsigned int offset,
 			      unsigned int length)
 {
-	struct inode     *inode;
-	struct lu_env    *env;
-	struct cl_page   *page;
+	struct inode *inode;
+	struct lu_env *env;
+	struct cl_page *page;
 	struct cl_object *obj;
 
 	LASSERT(PageLocked(vmpage));
@@ -101,9 +101,9 @@ static void ll_invalidatepage(struct page *vmpage, unsigned int offset,
 
 static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
 {
-	struct lu_env     *env;
-	struct cl_object  *obj;
-	struct cl_page    *page;
+	struct lu_env *env;
+	struct cl_object *obj;
+	struct cl_page *page;
 	struct address_space *mapping;
 	int result = 0;
 
@@ -177,9 +177,9 @@ static ssize_t ll_direct_IO_seg(const struct lu_env *env, struct cl_io *io,
 				loff_t file_offset, struct page **pages,
 				int page_count)
 {
-	struct cl_page    *clp;
-	struct cl_2queue  *queue;
-	struct cl_object  *obj = io->ci_obj;
+	struct cl_page *clp;
+	struct cl_2queue *queue;
+	struct cl_object *obj = io->ci_obj;
 	int i;
 	ssize_t rc = 0;
 	size_t page_size = cl_page_size(obj);
@@ -214,8 +214,8 @@ static ssize_t ll_direct_IO_seg(const struct lu_env *env, struct cl_io *io,
 			struct page *vmpage = cl_page_vmpage(clp);
 			struct page *src_page;
 			struct page *dst_page;
-			void       *src;
-			void       *dst;
+			void *src;
+			void *dst;
 
 			src_page = (rw == WRITE) ? pages[i] : vmpage;
 			dst_page = (rw == WRITE) ? vmpage : pages[i];
@@ -386,11 +386,11 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
 				   struct cl_page *pg)
 {
-	struct cl_attr *attr   = vvp_env_thread_attr(env);
-	struct cl_object *obj  = io->ci_obj;
-	struct vvp_page *vpg   = cl_object_page_slice(obj, pg);
-	loff_t          offset = cl_offset(obj, vvp_index(vpg));
-	int             result;
+	struct cl_attr *attr = vvp_env_thread_attr(env);
+	struct cl_object *obj = io->ci_obj;
+	struct vvp_page *vpg = cl_object_page_slice(obj, pg);
+	loff_t offset = cl_offset(obj, vvp_index(vpg));
+	int result;
 
 	cl_object_attr_lock(obj);
 	result = cl_object_attr_get(env, obj, attr);
@@ -421,7 +421,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 {
 	struct ll_cl_context *lcc;
 	const struct lu_env *env = NULL;
-	struct cl_io   *io;
+	struct cl_io *io;
 	struct cl_page *page = NULL;
 	struct cl_object *clob = ll_i2info(mapping->host)->lli_clob;
 	pgoff_t index = pos >> PAGE_SHIFT;
@@ -594,8 +594,7 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 #ifdef CONFIG_MIGRATION
 static int ll_migratepage(struct address_space *mapping,
 			  struct page *newpage, struct page *page,
-			  enum migrate_mode mode
-		)
+			  enum migrate_mode mode)
 {
 	/* Always fail page migration until we have a proper implementation */
 	return -EIO;
@@ -603,16 +602,16 @@ static int ll_migratepage(struct address_space *mapping,
 #endif
 
 const struct address_space_operations ll_aops = {
-	.readpage	= ll_readpage,
-	.direct_IO      = ll_direct_IO,
-	.writepage      = ll_writepage,
-	.writepages     = ll_writepages,
-	.set_page_dirty = __set_page_dirty_nobuffers,
-	.write_begin    = ll_write_begin,
-	.write_end      = ll_write_end,
-	.invalidatepage = ll_invalidatepage,
-	.releasepage    = (void *)ll_releasepage,
+	.readpage		= ll_readpage,
+	.direct_IO		= ll_direct_IO,
+	.writepage		= ll_writepage,
+	.writepages		= ll_writepages,
+	.set_page_dirty		= __set_page_dirty_nobuffers,
+	.write_begin		= ll_write_begin,
+	.write_end		= ll_write_end,
+	.invalidatepage		= ll_invalidatepage,
+	.releasepage		= (void *)ll_releasepage,
 #ifdef CONFIG_MIGRATION
-	.migratepage    = ll_migratepage,
+	.migratepage		= ll_migratepage,
 #endif
 };
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 6f5c7ab..0c305ba 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -61,25 +61,25 @@ enum se_stat {
  */
 struct sa_entry {
 	/* link into sai_interim_entries or sai_entries */
-	struct list_head	      se_list;
+	struct list_head	se_list;
 	/* link into sai hash table locally */
-	struct list_head	      se_hash;
+	struct list_head	se_hash;
 	/* entry index in the sai */
-	u64		   se_index;
+	u64			se_index;
 	/* low layer ldlm lock handle */
-	u64		   se_handle;
+	u64			se_handle;
 	/* entry status */
 	enum se_stat		se_state;
 	/* entry size, contains name */
-	int		     se_size;
+	int			se_size;
 	/* pointer to async getattr enqueue info */
-	struct md_enqueue_info *se_minfo;
+	struct md_enqueue_info	*se_minfo;
 	/* pointer to the async getattr request */
-	struct ptlrpc_request  *se_req;
+	struct ptlrpc_request	*se_req;
 	/* pointer to the target inode */
-	struct inode	   *se_inode;
+	struct inode		*se_inode;
 	/* entry name */
-	struct qstr	     se_qstr;
+	struct qstr		se_qstr;
 	/* entry fid */
 	struct lu_fid		se_fid;
 };
@@ -175,9 +175,9 @@ static inline int is_omitted_entry(struct ll_statahead_info *sai, u64 index)
 	 const char *name, int len, const struct lu_fid *fid)
 {
 	struct ll_inode_info *lli;
-	struct sa_entry   *entry;
-	int		   entry_size;
-	char		 *dname;
+	struct sa_entry *entry;
+	int entry_size;
+	char *dname;
 
 	entry_size = sizeof(struct sa_entry) + (len & ~3) + 4;
 	entry = kzalloc(entry_size, GFP_NOFS);
@@ -368,9 +368,9 @@ static void sa_free(struct ll_statahead_info *sai, struct sa_entry *entry)
 static void ll_agl_add(struct ll_statahead_info *sai,
 		       struct inode *inode, int index)
 {
-	struct ll_inode_info *child  = ll_i2info(inode);
+	struct ll_inode_info *child = ll_i2info(inode);
 	struct ll_inode_info *parent = ll_i2info(sai->sai_dentry->d_inode);
-	int		   added  = 0;
+	int added = 0;
 
 	spin_lock(&child->lli_agl_lock);
 	if (child->lli_agl_index == 0) {
@@ -398,7 +398,7 @@ static struct ll_statahead_info *ll_sai_alloc(struct dentry *dentry)
 {
 	struct ll_inode_info *lli = ll_i2info(dentry->d_inode);
 	struct ll_statahead_info *sai;
-	int		       i;
+	int i;
 
 	sai = kzalloc(sizeof(*sai), GFP_NOFS);
 	if (!sai)
@@ -491,9 +491,9 @@ static void ll_sai_put(struct ll_statahead_info *sai)
 /* Do NOT forget to drop inode refcount when into sai_agls. */
 static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 {
-	struct ll_inode_info *lli   = ll_i2info(inode);
-	u64		 index = lli->lli_agl_index;
-	int		   rc;
+	struct ll_inode_info *lli = ll_i2info(inode);
+	u64 index = lli->lli_agl_index;
+	int rc;
 
 	LASSERT(list_empty(&lli->lli_agl_list));
 
@@ -569,12 +569,12 @@ static void sa_instantiate(struct ll_statahead_info *sai,
 			   struct sa_entry *entry)
 {
 	struct inode *dir = sai->sai_dentry->d_inode;
-	struct inode	   *child;
+	struct inode *child;
 	struct md_enqueue_info *minfo;
-	struct lookup_intent   *it;
-	struct ptlrpc_request  *req;
+	struct lookup_intent *it;
+	struct ptlrpc_request *req;
 	struct mdt_body	*body;
-	int		     rc    = 0;
+	int rc = 0;
 
 	LASSERT(entry->se_handle != 0);
 
@@ -660,9 +660,9 @@ static void sa_handle_callback(struct ll_statahead_info *sai)
 static int ll_statahead_interpret(struct ptlrpc_request *req,
 				  struct md_enqueue_info *minfo, int rc)
 {
-	struct lookup_intent     *it  = &minfo->mi_it;
-	struct inode	     *dir = minfo->mi_dir;
-	struct ll_inode_info     *lli = ll_i2info(dir);
+	struct lookup_intent *it = &minfo->mi_it;
+	struct inode *dir = minfo->mi_dir;
+	struct ll_inode_info *lli = ll_i2info(dir);
 	struct ll_statahead_info *sai = lli->lli_sai;
 	struct sa_entry *entry = (struct sa_entry *)minfo->mi_cbdata;
 	u64 handle = 0;
@@ -738,9 +738,9 @@ static void sa_fini_data(struct md_enqueue_info *minfo)
 static struct md_enqueue_info *
 sa_prep_data(struct inode *dir, struct inode *child, struct sa_entry *entry)
 {
-	struct md_enqueue_info   *minfo;
+	struct md_enqueue_info *minfo;
 	struct ldlm_enqueue_info *einfo;
-	struct md_op_data	*op_data;
+	struct md_op_data *op_data;
 
 	minfo = kzalloc(sizeof(*minfo), GFP_NOFS);
 	if (!minfo)
@@ -762,11 +762,11 @@ static void sa_fini_data(struct md_enqueue_info *minfo)
 	minfo->mi_cbdata = entry;
 
 	einfo = &minfo->mi_einfo;
-	einfo->ei_type   = LDLM_IBITS;
-	einfo->ei_mode   = it_to_lock_mode(&minfo->mi_it);
-	einfo->ei_cb_bl  = ll_md_blocking_ast;
-	einfo->ei_cb_cp  = ldlm_completion_ast;
-	einfo->ei_cb_gl  = NULL;
+	einfo->ei_type = LDLM_IBITS;
+	einfo->ei_mode = it_to_lock_mode(&minfo->mi_it);
+	einfo->ei_cb_bl = ll_md_blocking_ast;
+	einfo->ei_cb_cp = ldlm_completion_ast;
+	einfo->ei_cb_gl = NULL;
 	einfo->ei_cbdata = NULL;
 
 	return minfo;
@@ -775,8 +775,8 @@ static void sa_fini_data(struct md_enqueue_info *minfo)
 /* async stat for file not found in dcache */
 static int sa_lookup(struct inode *dir, struct sa_entry *entry)
 {
-	struct md_enqueue_info   *minfo;
-	int		       rc;
+	struct md_enqueue_info *minfo;
+	int rc;
 
 	minfo = sa_prep_data(dir, NULL, entry);
 	if (IS_ERR(minfo))
@@ -799,10 +799,12 @@ static int sa_lookup(struct inode *dir, struct sa_entry *entry)
 static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 			 struct dentry *dentry)
 {
-	struct inode	     *inode = d_inode(dentry);
-	struct lookup_intent      it = { .it_op = IT_GETATTR,
-					 .it_lock_handle = 0 };
-	struct md_enqueue_info   *minfo;
+	struct inode *inode = d_inode(dentry);
+	struct lookup_intent it = {
+		.it_op = IT_GETATTR,
+		.it_lock_handle = 0
+	};
+	struct md_enqueue_info *minfo;
 	int rc;
 
 	if (unlikely(!inode))
@@ -841,12 +843,12 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 static void sa_statahead(struct dentry *parent, const char *name, int len,
 			 const struct lu_fid *fid)
 {
-	struct inode	     *dir    = d_inode(parent);
-	struct ll_inode_info     *lli    = ll_i2info(dir);
-	struct ll_statahead_info *sai    = lli->lli_sai;
-	struct dentry	    *dentry = NULL;
+	struct inode *dir = d_inode(parent);
+	struct ll_inode_info *lli = ll_i2info(dir);
+	struct ll_statahead_info *sai = lli->lli_sai;
+	struct dentry *dentry = NULL;
 	struct sa_entry *entry;
-	int		       rc;
+	int rc;
 
 	entry = sa_alloc(parent, sai, sai->sai_index, name, len, fid);
 	if (IS_ERR(entry))
@@ -875,10 +877,10 @@ static void sa_statahead(struct dentry *parent, const char *name, int len,
 /* async glimpse (agl) thread main function */
 static int ll_agl_thread(void *arg)
 {
-	struct dentry	    *parent = arg;
-	struct inode	     *dir    = d_inode(parent);
-	struct ll_inode_info     *plli   = ll_i2info(dir);
-	struct ll_inode_info     *clli;
+	struct dentry *parent = arg;
+	struct inode *dir = d_inode(parent);
+	struct ll_inode_info *plli = ll_i2info(dir);
+	struct ll_inode_info *clli;
 	/* We already own this reference, so it is safe to take it without a lock. */
 	struct ll_statahead_info *sai = plli->lli_sai;
 
@@ -929,7 +931,7 @@ static int ll_agl_thread(void *arg)
 /* start agl thread */
 static void ll_start_agl(struct dentry *parent, struct ll_statahead_info *sai)
 {
-	struct ll_inode_info  *plli;
+	struct ll_inode_info *plli;
 	struct task_struct *task;
 
 	CDEBUG(D_READA, "start agl thread: sai %p, parent %pd\n",
@@ -957,15 +959,15 @@ static void ll_start_agl(struct dentry *parent, struct ll_statahead_info *sai)
 /* statahead thread main function */
 static int ll_statahead_thread(void *arg)
 {
-	struct dentry	    *parent = arg;
-	struct inode	     *dir    = d_inode(parent);
-	struct ll_inode_info     *lli   = ll_i2info(dir);
-	struct ll_sb_info	*sbi    = ll_i2sbi(dir);
+	struct dentry *parent = arg;
+	struct inode *dir = d_inode(parent);
+	struct ll_inode_info *lli = ll_i2info(dir);
+	struct ll_sb_info *sbi = ll_i2sbi(dir);
 	struct ll_statahead_info *sai = lli->lli_sai;
-	struct page	      *page = NULL;
-	u64		     pos    = 0;
-	int		       first  = 0;
-	int		       rc     = 0;
+	struct page *page = NULL;
+	u64 pos = 0;
+	int first = 0;
+	int rc = 0;
 	struct md_op_data *op_data;
 
 	CDEBUG(D_READA, "statahead thread starting: sai %p, parent %pd\n",
@@ -980,7 +982,7 @@ static int ll_statahead_thread(void *arg)
 
 	while (pos != MDS_DIR_END_OFF && sai->sai_task) {
 		struct lu_dirpage *dp;
-		struct lu_dirent  *ent;
+		struct lu_dirent *ent;
 
 		sai->sai_in_readpage = 1;
 		page = ll_get_dir_page(dir, op_data, pos);
@@ -1225,11 +1227,11 @@ enum {
 /* file is first dirent under @dir */
 static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 {
-	const struct qstr  *target = &dentry->d_name;
+	const struct qstr *target = &dentry->d_name;
 	struct md_op_data *op_data;
-	struct page	  *page;
-	u64		 pos    = 0;
-	int		   dot_de;
+	struct page *page;
+	u64 pos = 0;
+	int dot_de;
 	int rc = LS_NOT_FIRST_DE;
 
 	op_data = ll_prep_md_op_data(NULL, dir, dir, NULL, 0, 0,
@@ -1243,7 +1245,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 
 	while (1) {
 		struct lu_dirpage *dp;
-		struct lu_dirent  *ent;
+		struct lu_dirent *ent;
 
 		if (IS_ERR(page)) {
 			struct ll_inode_info *lli = ll_i2info(dir);
@@ -1423,8 +1425,10 @@ static int revalidate_statahead_dentry(struct inode *dir,
 	if (smp_load_acquire(&entry->se_state) == SA_ENTRY_SUCC &&
 	    entry->se_inode) {
 		struct inode *inode = entry->se_inode;
-		struct lookup_intent it = { .it_op = IT_GETATTR,
-					    .it_lock_handle = entry->se_handle };
+		struct lookup_intent it = {
+			.it_op = IT_GETATTR,
+			.it_lock_handle = entry->se_handle
+		};
 		u64 bits;
 
 		rc = md_revalidate_lock(ll_i2mdexp(dir), &it,
@@ -1517,7 +1521,6 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 		goto out;
 	}
 
-
 	sai = ll_sai_alloc(parent);
 	if (!sai) {
 		rc = -ENOMEM;
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 3ad0b11..c2b1668 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -73,14 +73,14 @@ static void ll_destroy_inode(struct inode *inode)
 
 /* exported operations */
 struct super_operations lustre_super_operations = {
-	.alloc_inode   = ll_alloc_inode,
-	.destroy_inode = ll_destroy_inode,
-	.evict_inode   = ll_delete_inode,
-	.put_super     = ll_put_super,
-	.statfs	= ll_statfs,
-	.umount_begin  = ll_umount_begin,
-	.remount_fs    = ll_remount_fs,
-	.show_options  = ll_show_options,
+	.alloc_inode		= ll_alloc_inode,
+	.destroy_inode		= ll_destroy_inode,
+	.evict_inode		= ll_delete_inode,
+	.put_super		= ll_put_super,
+	.statfs			= ll_statfs,
+	.umount_begin		= ll_umount_begin,
+	.remount_fs		= ll_remount_fs,
+	.show_options		= ll_show_options,
 };
 
 /** This is the entry point for the mount call into Lustre.
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 4e55599..c10ca6e 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -111,9 +111,9 @@ static void ll_thread_key_fini(const struct lu_context *ctx,
 }
 
 struct lu_context_key ll_thread_key = {
-	.lct_tags = LCT_CL_THREAD,
-	.lct_init = ll_thread_key_init,
-	.lct_fini = ll_thread_key_fini
+	.lct_tags	= LCT_CL_THREAD,
+	.lct_init	= ll_thread_key_init,
+	.lct_fini	= ll_thread_key_fini
 };
 
 static void *vvp_session_key_init(const struct lu_context *ctx,
@@ -136,9 +136,9 @@ static void vvp_session_key_fini(const struct lu_context *ctx,
 }
 
 struct lu_context_key vvp_session_key = {
-	.lct_tags = LCT_SESSION,
-	.lct_init = vvp_session_key_init,
-	.lct_fini = vvp_session_key_fini
+	.lct_tags	= LCT_SESSION,
+	.lct_init	= vvp_session_key_init,
+	.lct_fini	= vvp_session_key_fini
 };
 
 static void *vvp_thread_key_init(const struct lu_context *ctx,
@@ -161,24 +161,24 @@ static void vvp_thread_key_fini(const struct lu_context *ctx,
 }
 
 struct lu_context_key vvp_thread_key = {
-	.lct_tags = LCT_CL_THREAD,
-	.lct_init = vvp_thread_key_init,
-	.lct_fini = vvp_thread_key_fini
+	.lct_tags	= LCT_CL_THREAD,
+	.lct_init	= vvp_thread_key_init,
+	.lct_fini	= vvp_thread_key_fini
 };
 
 /* type constructor/destructor: vvp_type_{init,fini,start,stop}(). */
 LU_TYPE_INIT_FINI(vvp, &vvp_thread_key, &ll_thread_key, &vvp_session_key);
 
 static const struct lu_device_operations vvp_lu_ops = {
-	.ldo_object_alloc      = vvp_object_alloc
+	.ldo_object_alloc	= vvp_object_alloc
 };
 
 static struct lu_device *vvp_device_free(const struct lu_env *env,
 					 struct lu_device *d)
 {
-	struct vvp_device *vdv  = lu2vvp_dev(d);
-	struct cl_site    *site = lu2cl_site(d->ld_site);
-	struct lu_device  *next = cl2lu_dev(vdv->vdv_next);
+	struct vvp_device *vdv = lu2vvp_dev(d);
+	struct cl_site *site = lu2cl_site(d->ld_site);
+	struct lu_device *next = cl2lu_dev(vdv->vdv_next);
 
 	if (d->ld_site) {
 		cl_site_fini(site);
@@ -194,8 +194,8 @@ static struct lu_device *vvp_device_alloc(const struct lu_env *env,
 					  struct lustre_cfg *cfg)
 {
 	struct vvp_device *vdv;
-	struct lu_device  *lud;
-	struct cl_site    *site;
+	struct lu_device *lud;
+	struct cl_site *site;
 	int rc;
 
 	vdv = kzalloc(sizeof(*vdv), GFP_NOFS);
@@ -229,7 +229,7 @@ static struct lu_device *vvp_device_alloc(const struct lu_env *env,
 static int vvp_device_init(const struct lu_env *env, struct lu_device *d,
 			   const char *name, struct lu_device *next)
 {
-	struct vvp_device  *vdv;
+	struct vvp_device *vdv;
 	int rc;
 
 	vdv = lu2vvp_dev(d);
@@ -254,23 +254,23 @@ static struct lu_device *vvp_device_fini(const struct lu_env *env,
 }
 
 static const struct lu_device_type_operations vvp_device_type_ops = {
-	.ldto_init = vvp_type_init,
-	.ldto_fini = vvp_type_fini,
+	.ldto_init		= vvp_type_init,
+	.ldto_fini		= vvp_type_fini,
 
-	.ldto_start = vvp_type_start,
-	.ldto_stop  = vvp_type_stop,
+	.ldto_start		= vvp_type_start,
+	.ldto_stop		= vvp_type_stop,
 
-	.ldto_device_alloc = vvp_device_alloc,
+	.ldto_device_alloc	= vvp_device_alloc,
 	.ldto_device_free	= vvp_device_free,
 	.ldto_device_init	= vvp_device_init,
 	.ldto_device_fini	= vvp_device_fini,
 };
 
 struct lu_device_type vvp_device_type = {
-	.ldt_tags     = LU_DEVICE_CL,
-	.ldt_name     = LUSTRE_VVP_NAME,
-	.ldt_ops      = &vvp_device_type_ops,
-	.ldt_ctx_tags = LCT_CL_THREAD
+	.ldt_tags		= LU_DEVICE_CL,
+	.ldt_name		= LUSTRE_VVP_NAME,
+	.ldt_ops		= &vvp_device_type_ops,
+	.ldt_ctx_tags		= LCT_CL_THREAD
 };
 
 /**
@@ -312,8 +312,8 @@ void vvp_global_fini(void)
 int cl_sb_init(struct super_block *sb)
 {
 	struct ll_sb_info *sbi;
-	struct cl_device  *cl;
-	struct lu_env     *env;
+	struct cl_device *cl;
+	struct lu_env *env;
 	int rc = 0;
 	u16 refcheck;
 
@@ -336,10 +336,10 @@ int cl_sb_init(struct super_block *sb)
 int cl_sb_fini(struct super_block *sb)
 {
 	struct ll_sb_info *sbi;
-	struct lu_env     *env;
-	struct cl_device  *cld;
+	struct lu_env *env;
+	struct cl_device *cld;
 	u16 refcheck;
-	int		result;
+	int result;
 
 	sbi = ll_s2sbi(sb);
 	env = cl_env_get(&refcheck);
@@ -378,20 +378,20 @@ struct vvp_pgcache_id {
 struct vvp_seq_private {
 	struct ll_sb_info	*vsp_sbi;
 	struct lu_env		*vsp_env;
-	u16			vsp_refcheck;
+	u16			 vsp_refcheck;
 	struct cl_object	*vsp_clob;
-	struct vvp_pgcache_id	vsp_id;
+	struct vvp_pgcache_id	 vsp_id;
 	/*
 	 * prev_pos is the 'pos' of the last object returned
 	 * by ->start of ->next.
 	 */
-	loff_t			vsp_prev_pos;
+	loff_t			 vsp_prev_pos;
 };
 
 static int vvp_pgcache_obj_get(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 			       struct hlist_node *hnode, void *data)
 {
-	struct vvp_pgcache_id   *id  = data;
+	struct vvp_pgcache_id *id = data;
 	struct lu_object_header *hdr = cfs_hash_object(hs, hnode);
 
 	if (lu_object_is_dying(hdr))
@@ -411,7 +411,7 @@ static struct cl_object *vvp_pgcache_obj(const struct lu_env *env,
 {
 	LASSERT(lu_device_is_cl(dev));
 
-	id->vpi_obj    = NULL;
+	id->vpi_obj = NULL;
 	id->vpi_curdep = id->vpi_depth;
 
 	cfs_hash_hlist_for_each(dev->ld_site->ls_obj_hash, id->vpi_bucket,
@@ -464,19 +464,19 @@ static struct page *vvp_pgcache_current(struct vvp_seq_private *priv)
 	}
 }
 
-#define seq_page_flag(seq, page, flag, has_flags) do {		  \
-	if (test_bit(PG_##flag, &(page)->flags)) {		  \
+#define seq_page_flag(seq, page, flag, has_flags) do {			\
+	if (test_bit(PG_##flag, &(page)->flags)) {			\
 		seq_printf(seq, "%s"#flag, has_flags ? "|" : "");       \
-		has_flags = 1;					  \
-	}							       \
+		has_flags = 1;						\
+	}								\
 } while (0)
 
 static void vvp_pgcache_page_show(const struct lu_env *env,
 				  struct seq_file *seq, struct cl_page *page)
 {
 	struct vvp_page *vpg;
-	struct page      *vmpage;
-	int	      has_flags;
+	struct page *vmpage;
+	int has_flags;
 
 	vpg = cl2vvp_page(cl_page_at(page, &vvp_device_type));
 	vmpage = vpg->vpg_page;
@@ -502,8 +502,8 @@ static void vvp_pgcache_page_show(const struct lu_env *env,
 static int vvp_pgcache_show(struct seq_file *f, void *v)
 {
 	struct vvp_seq_private *priv = f->private;
-	struct page		*vmpage = v;
-	struct cl_page		*page;
+	struct page *vmpage = v;
+	struct cl_page *page;
 
 	seq_printf(f, "%8lx@" DFID ": ", vmpage->index,
 		   PFID(lu_object_fid(&priv->vsp_clob->co_lu)));
@@ -575,10 +575,10 @@ static void vvp_pgcache_stop(struct seq_file *f, void *v)
 }
 
 static const struct seq_operations vvp_pgcache_ops = {
-	.start = vvp_pgcache_start,
-	.next  = vvp_pgcache_next,
-	.stop  = vvp_pgcache_stop,
-	.show  = vvp_pgcache_show
+	.start	= vvp_pgcache_start,
+	.next	= vvp_pgcache_next,
+	.stop	= vvp_pgcache_stop,
+	.show	= vvp_pgcache_show
 };
 
 static int vvp_dump_pgcache_seq_open(struct inode *inode, struct file *filp)
@@ -617,9 +617,9 @@ static int vvp_dump_pgcache_seq_release(struct inode *inode, struct file *file)
 }
 
 const struct file_operations vvp_dump_pgcache_file_ops = {
-	.owner   = THIS_MODULE,
-	.open    = vvp_dump_pgcache_seq_open,
-	.read    = seq_read,
-	.llseek	 = seq_lseek,
-	.release = vvp_dump_pgcache_seq_release,
+	.owner		= THIS_MODULE,
+	.open		= vvp_dump_pgcache_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= vvp_dump_pgcache_seq_release,
 };
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index e8712d8..102d143 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -53,12 +53,12 @@
  */
 struct vvp_io {
 	/** super class */
-	struct cl_io_slice     vui_cl;
-	struct cl_io_lock_link vui_link;
+	struct cl_io_slice	vui_cl;
+	struct cl_io_lock_link	vui_link;
 	/**
 	 * I/O vector information to or from which read/write is going.
 	 */
-	struct iov_iter *vui_iter;
+	struct iov_iter		*vui_iter;
 	/**
 	 * Total size for the left IO.
 	 */
@@ -70,30 +70,30 @@ struct vvp_io {
 			 * Inode modification time that is checked across DLM
 			 * lock request.
 			 */
-			time64_t	    ft_mtime;
-			struct vm_area_struct *ft_vma;
+			time64_t		ft_mtime;
+			struct vm_area_struct	*ft_vma;
 			/**
 			 *  locked page returned from vvp_io
 			 */
-			struct page	    *ft_vmpage;
+			struct page		*ft_vmpage;
 			/**
 			 * kernel fault info
 			 */
-			struct vm_fault *ft_vmf;
+			struct vm_fault		*ft_vmf;
 			/**
 			 * fault API used bitflags for return code.
 			 */
-			unsigned int    ft_flags;
+			unsigned int		ft_flags;
 			/**
 			 * check that flags are from filemap_fault
 			 */
-			bool		ft_flags_valid;
+			bool			ft_flags_valid;
 		} fault;
 		struct {
-			struct cl_page_list vui_queue;
-			unsigned long vui_written;
-			int vui_from;
-			int vui_to;
+			struct cl_page_list	vui_queue;
+			unsigned long		vui_written;
+			int			vui_from;
+			int			vui_to;
 		} write;
 	} u;
 
@@ -108,10 +108,10 @@ struct vvp_io {
 	struct kiocb		*vui_iocb;
 
 	/* Readahead state. */
-	pgoff_t	vui_ra_start;
-	pgoff_t	vui_ra_count;
+	pgoff_t			vui_ra_start;
+	pgoff_t			vui_ra_count;
 	/* Set when vui_ra_{start,count} have been initialized. */
-	bool		vui_ra_valid;
+	bool			vui_ra_valid;
 };
 
 extern struct lu_device_type vvp_device_type;
@@ -131,7 +131,7 @@ struct vvp_thread_info {
 
 static inline struct vvp_thread_info *vvp_env_info(const struct lu_env *env)
 {
-	struct vvp_thread_info      *vti;
+	struct vvp_thread_info *vti;
 
 	vti = lu_context_key_get(&env->le_ctx, &vvp_thread_key);
 	LASSERT(vti);
@@ -166,7 +166,7 @@ static inline struct cl_io *vvp_env_thread_io(const struct lu_env *env)
 }
 
 struct vvp_session {
-	struct vvp_io cs_ios;
+	struct vvp_io	cs_ios;
 };
 
 static inline struct vvp_session *vvp_env_session(const struct lu_env *env)
@@ -189,8 +189,8 @@ static inline struct vvp_io *vvp_env_io(const struct lu_env *env)
  */
 struct vvp_object {
 	struct cl_object_header vob_header;
-	struct cl_object        vob_cl;
-	struct inode           *vob_inode;
+	struct cl_object	vob_cl;
+	struct inode	       *vob_inode;
 
 	/**
 	 * Number of transient pages.  This is no longer protected by i_sem,
@@ -223,12 +223,12 @@ struct vvp_object {
  * VVP-private page state.
  */
 struct vvp_page {
-	struct cl_page_slice vpg_cl;
-	unsigned int	vpg_defer_uptodate:1,
-			vpg_ra_updated:1,
-			vpg_ra_used:1;
+	struct cl_page_slice	vpg_cl;
+	unsigned int		vpg_defer_uptodate:1,
+				vpg_ra_updated:1,
+				vpg_ra_used:1;
 	/** VM page */
-	struct page	  *vpg_page;
+	struct page		*vpg_page;
 };
 
 static inline struct vvp_page *cl2vvp_page(const struct cl_page_slice *slice)
@@ -242,12 +242,12 @@ static inline pgoff_t vvp_index(struct vvp_page *vvp)
 }
 
 struct vvp_device {
-	struct cl_device    vdv_cl;
-	struct cl_device   *vdv_next;
+	struct cl_device	vdv_cl;
+	struct cl_device	*vdv_next;
 };
 
 struct vvp_lock {
-	struct cl_lock_slice vlk_cl;
+	struct cl_lock_slice	vlk_cl;
 };
 
 void *ccc_key_init(const struct lu_context *ctx,
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 26a7897..593b10c 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -63,8 +63,8 @@ static struct vvp_io *cl2vvp_io(const struct lu_env *env,
 static bool can_populate_pages(const struct lu_env *env, struct cl_io *io,
 			       struct inode *inode)
 {
-	struct ll_inode_info	*lli = ll_i2info(inode);
-	struct vvp_io		*vio = vvp_env_io(env);
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct vvp_io *vio = vvp_env_io(env);
 	bool rc = true;
 
 	switch (io->ci_type) {
@@ -120,9 +120,9 @@ static int vvp_prep_size(const struct lu_env *env, struct cl_object *obj,
 			 struct cl_io *io, loff_t start, size_t count,
 			 int *exceed)
 {
-	struct cl_attr *attr  = vvp_env_thread_attr(env);
-	struct inode   *inode = vvp_object_inode(obj);
-	loff_t	  pos   = start + count - 1;
+	struct cl_attr *attr = vvp_env_thread_attr(env);
+	struct inode *inode = vvp_object_inode(obj);
+	loff_t pos = start + count - 1;
 	loff_t kms;
 	int result;
 
@@ -205,11 +205,11 @@ static int vvp_prep_size(const struct lu_env *env, struct cl_object *obj,
 
 static int vvp_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
 				 u32 enqflags, enum cl_lock_mode mode,
-			  pgoff_t start, pgoff_t end)
+				 pgoff_t start, pgoff_t end)
 {
-	struct vvp_io          *vio   = vvp_env_io(env);
-	struct cl_lock_descr   *descr = &vio->vui_link.cill_descr;
-	struct cl_object       *obj   = io->ci_obj;
+	struct vvp_io *vio = vvp_env_io(env);
+	struct cl_lock_descr *descr = &vio->vui_link.cill_descr;
+	struct cl_object *obj = io->ci_obj;
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
@@ -222,11 +222,11 @@ static int vvp_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
 		descr->cld_gid  = vio->vui_fd->fd_grouplock.lg_gid;
 		enqflags |= CEF_LOCK_MATCH;
 	} else {
-		descr->cld_mode  = mode;
+		descr->cld_mode = mode;
 	}
-	descr->cld_obj   = obj;
+	descr->cld_obj = obj;
 	descr->cld_start = start;
-	descr->cld_end   = end;
+	descr->cld_end  = end;
 	descr->cld_enq_flags = enqflags;
 
 	cl_io_lock_add(env, io, &vio->vui_link);
@@ -267,8 +267,8 @@ static void vvp_io_write_iter_fini(const struct lu_env *env,
 static int vvp_io_fault_iter_init(const struct lu_env *env,
 				  const struct cl_io_slice *ios)
 {
-	struct vvp_io *vio   = cl2vvp_io(env, ios);
-	struct inode  *inode = vvp_object_inode(ios->cis_obj);
+	struct vvp_io *vio = cl2vvp_io(env, ios);
+	struct inode *inode = vvp_object_inode(ios->cis_obj);
 
 	LASSERT(inode == file_inode(vio->vui_fd->fd_file));
 	vio->u.fault.ft_mtime = inode->i_mtime.tv_sec;
@@ -277,9 +277,9 @@ static int vvp_io_fault_iter_init(const struct lu_env *env,
 
 static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 {
-	struct cl_io     *io  = ios->cis_io;
+	struct cl_io *io = ios->cis_io;
 	struct cl_object *obj = io->ci_obj;
-	struct vvp_io    *vio = cl2vvp_io(env, ios);
+	struct vvp_io *vio = cl2vvp_io(env, ios);
 	struct inode *inode = vvp_object_inode(obj);
 	int rc;
 
@@ -376,7 +376,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 static void vvp_io_fault_fini(const struct lu_env *env,
 			      const struct cl_io_slice *ios)
 {
-	struct cl_io   *io   = ios->cis_io;
+	struct cl_io *io = ios->cis_io;
 	struct cl_page *page = io->u.ci_fault.ft_page;
 
 	CLOBINVRNT(env, io->ci_obj, vvp_object_invariant(io->ci_obj));
@@ -405,13 +405,13 @@ static int vvp_mmap_locks(const struct lu_env *env,
 			  struct vvp_io *vio, struct cl_io *io)
 {
 	struct vvp_thread_info *cti = vvp_env_info(env);
-	struct mm_struct       *mm = current->mm;
+	struct mm_struct *mm = current->mm;
 	struct vm_area_struct  *vma;
-	struct cl_lock_descr   *descr = &cti->vti_descr;
+	struct cl_lock_descr *descr = &cti->vti_descr;
 	union ldlm_policy_data policy;
-	unsigned long	   addr;
-	ssize_t		 count;
-	int		 result = 0;
+	unsigned long addr;
+	ssize_t	count;
+	int result = 0;
 	struct iov_iter i;
 	struct iovec iov;
 
@@ -492,7 +492,7 @@ static void vvp_io_advance(const struct lu_env *env,
 			   size_t nob)
 {
 	struct cl_object *obj = ios->cis_io->ci_obj;
-	struct vvp_io	 *vio = cl2vvp_io(env, ios);
+	struct vvp_io *vio = cl2vvp_io(env, ios);
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
@@ -533,7 +533,7 @@ static int vvp_io_rw_lock(const struct lu_env *env, struct cl_io *io,
 static int vvp_io_read_lock(const struct lu_env *env,
 			    const struct cl_io_slice *ios)
 {
-	struct cl_io	 *io = ios->cis_io;
+	struct cl_io *io = ios->cis_io;
 	struct cl_io_rw_common *rd = &io->u.ci_rd.rd;
 	int result;
 
@@ -546,7 +546,7 @@ static int vvp_io_read_lock(const struct lu_env *env,
 static int vvp_io_fault_lock(const struct lu_env *env,
 			     const struct cl_io_slice *ios)
 {
-	struct cl_io *io   = ios->cis_io;
+	struct cl_io *io = ios->cis_io;
 	struct vvp_io *vio = cl2vvp_io(env, ios);
 	/*
 	 * XXX LDLM_FL_CBPENDING
@@ -567,10 +567,10 @@ static int vvp_io_write_lock(const struct lu_env *env,
 
 	if (io->u.ci_wr.wr_append) {
 		start = 0;
-		end   = OBD_OBJECT_EOF;
+		end = OBD_OBJECT_EOF;
 	} else {
 		start = io->u.ci_wr.wr.crw_pos;
-		end   = start + io->u.ci_wr.wr.crw_count - 1;
+		end = start + io->u.ci_wr.wr.crw_count - 1;
 	}
 	return vvp_io_rw_lock(env, io, CLM_WRITE, start, end);
 }
@@ -589,7 +589,7 @@ static int vvp_io_setattr_iter_init(const struct lu_env *env,
 static int vvp_io_setattr_lock(const struct lu_env *env,
 			       const struct cl_io_slice *ios)
 {
-	struct cl_io  *io  = ios->cis_io;
+	struct cl_io *io = ios->cis_io;
 	u64 new_size;
 	u32 enqflags = 0;
 
@@ -619,7 +619,7 @@ static int vvp_io_setattr_lock(const struct lu_env *env,
 
 static int vvp_do_vmtruncate(struct inode *inode, size_t size)
 {
-	int     result;
+	int result;
 	/*
 	 * Only ll_inode_size_lock is taken at this level.
 	 */
@@ -637,9 +637,9 @@ static int vvp_do_vmtruncate(struct inode *inode, size_t size)
 static int vvp_io_setattr_time(const struct lu_env *env,
 			       const struct cl_io_slice *ios)
 {
-	struct cl_io       *io    = ios->cis_io;
-	struct cl_object   *obj   = io->ci_obj;
-	struct cl_attr     *attr  = vvp_env_thread_attr(env);
+	struct cl_io *io = ios->cis_io;
+	struct cl_object *obj = io->ci_obj;
+	struct cl_attr *attr = vvp_env_thread_attr(env);
 	int result;
 	unsigned valid = CAT_CTIME;
 
@@ -662,8 +662,8 @@ static int vvp_io_setattr_time(const struct lu_env *env,
 static int vvp_io_setattr_start(const struct lu_env *env,
 				const struct cl_io_slice *ios)
 {
-	struct cl_io	*io    = ios->cis_io;
-	struct inode	*inode = vvp_object_inode(io->ci_obj);
+	struct cl_io *io = ios->cis_io;
+	struct inode *inode = vvp_object_inode(io->ci_obj);
 	struct ll_inode_info *lli = ll_i2info(inode);
 
 	if (cl_io_is_trunc(io)) {
@@ -683,7 +683,7 @@ static int vvp_io_setattr_start(const struct lu_env *env,
 static void vvp_io_setattr_end(const struct lu_env *env,
 			       const struct cl_io_slice *ios)
 {
-	struct cl_io *io    = ios->cis_io;
+	struct cl_io *io = ios->cis_io;
 	struct inode *inode = vvp_object_inode(io->ci_obj);
 	struct ll_inode_info *lli = ll_i2info(inode);
 
@@ -716,18 +716,17 @@ static void vvp_io_setattr_fini(const struct lu_env *env,
 static int vvp_io_read_start(const struct lu_env *env,
 			     const struct cl_io_slice *ios)
 {
-	struct vvp_io     *vio   = cl2vvp_io(env, ios);
-	struct cl_io      *io    = ios->cis_io;
-	struct cl_object  *obj   = io->ci_obj;
-	struct inode      *inode = vvp_object_inode(obj);
+	struct vvp_io *vio = cl2vvp_io(env, ios);
+	struct cl_io *io = ios->cis_io;
+	struct cl_object *obj = io->ci_obj;
+	struct inode *inode = vvp_object_inode(obj);
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct file       *file  = vio->vui_fd->fd_file;
-
-	int     result;
-	loff_t  pos = io->u.ci_rd.rd.crw_pos;
-	long    cnt = io->u.ci_rd.rd.crw_count;
-	long    tot = vio->vui_tot_count;
-	int     exceed = 0;
+	struct file *file = vio->vui_fd->fd_file;
+	int result;
+	loff_t pos = io->u.ci_rd.rd.crw_pos;
+	long cnt = io->u.ci_rd.rd.crw_count;
+	long tot = vio->vui_tot_count;
+	int exceed = 0;
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
@@ -956,10 +955,10 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 static int vvp_io_write_start(const struct lu_env *env,
 			      const struct cl_io_slice *ios)
 {
-	struct vvp_io      *vio   = cl2vvp_io(env, ios);
-	struct cl_io       *io    = ios->cis_io;
-	struct cl_object   *obj   = io->ci_obj;
-	struct inode       *inode = vvp_object_inode(obj);
+	struct vvp_io *vio = cl2vvp_io(env, ios);
+	struct cl_io *io = ios->cis_io;
+	struct cl_object *obj = io->ci_obj;
+	struct inode *inode = vvp_object_inode(obj);
 	struct ll_inode_info *lli = ll_i2info(inode);
 	bool lock_inode = !inode_is_locked(inode) && !IS_NOSEC(inode);
 	loff_t pos = io->u.ci_wr.wr.crw_pos;
@@ -1111,19 +1110,19 @@ static void mkwrite_commit_callback(const struct lu_env *env, struct cl_io *io,
 static int vvp_io_fault_start(const struct lu_env *env,
 			      const struct cl_io_slice *ios)
 {
-	struct vvp_io       *vio     = cl2vvp_io(env, ios);
-	struct cl_io	*io      = ios->cis_io;
-	struct cl_object    *obj     = io->ci_obj;
-	struct inode        *inode   = vvp_object_inode(obj);
+	struct vvp_io *vio = cl2vvp_io(env, ios);
+	struct cl_io *io = ios->cis_io;
+	struct cl_object *obj = io->ci_obj;
+	struct inode *inode = vvp_object_inode(obj);
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct cl_fault_io  *fio     = &io->u.ci_fault;
-	struct vvp_fault_io *cfio    = &vio->u.fault;
-	loff_t	       offset;
-	int		  result  = 0;
-	struct page	  *vmpage  = NULL;
-	struct cl_page      *page;
-	loff_t	       size;
-	pgoff_t		     last_index;
+	struct cl_fault_io *fio = &io->u.ci_fault;
+	struct vvp_fault_io *cfio = &vio->u.fault;
+	loff_t offset;
+	int result = 0;
+	struct page *vmpage = NULL;
+	struct cl_page *page;
+	loff_t size;
+	pgoff_t last_index;
 
 	down_read(&lli->lli_trunc_sem);
 
@@ -1318,40 +1317,40 @@ static int vvp_io_read_ahead(const struct lu_env *env,
 	.op = {
 		[CIT_READ] = {
 			.cio_fini	= vvp_io_fini,
-			.cio_lock      = vvp_io_read_lock,
-			.cio_start     = vvp_io_read_start,
+			.cio_lock	= vvp_io_read_lock,
+			.cio_start	= vvp_io_read_start,
 			.cio_end	= vvp_io_rw_end,
 			.cio_advance	= vvp_io_advance,
 		},
 		[CIT_WRITE] = {
-			.cio_fini      = vvp_io_fini,
-			.cio_iter_init = vvp_io_write_iter_init,
-			.cio_iter_fini = vvp_io_write_iter_fini,
-			.cio_lock      = vvp_io_write_lock,
-			.cio_start     = vvp_io_write_start,
+			.cio_fini	= vvp_io_fini,
+			.cio_iter_init	= vvp_io_write_iter_init,
+			.cio_iter_fini	= vvp_io_write_iter_fini,
+			.cio_lock	= vvp_io_write_lock,
+			.cio_start	= vvp_io_write_start,
 			.cio_end	= vvp_io_rw_end,
-			.cio_advance   = vvp_io_advance,
+			.cio_advance	= vvp_io_advance,
 		},
 		[CIT_SETATTR] = {
-			.cio_fini       = vvp_io_setattr_fini,
-			.cio_iter_init  = vvp_io_setattr_iter_init,
-			.cio_lock       = vvp_io_setattr_lock,
-			.cio_start      = vvp_io_setattr_start,
+			.cio_fini	= vvp_io_setattr_fini,
+			.cio_iter_init	= vvp_io_setattr_iter_init,
+			.cio_lock	= vvp_io_setattr_lock,
+			.cio_start	= vvp_io_setattr_start,
 			.cio_end	= vvp_io_setattr_end
 		},
 		[CIT_FAULT] = {
-			.cio_fini      = vvp_io_fault_fini,
-			.cio_iter_init = vvp_io_fault_iter_init,
-			.cio_lock      = vvp_io_fault_lock,
-			.cio_start     = vvp_io_fault_start,
-			.cio_end       = vvp_io_fault_end,
+			.cio_fini	= vvp_io_fault_fini,
+			.cio_iter_init	= vvp_io_fault_iter_init,
+			.cio_lock	= vvp_io_fault_lock,
+			.cio_start	= vvp_io_fault_start,
+			.cio_end	= vvp_io_fault_end,
 		},
 		[CIT_FSYNC] = {
-			.cio_start  = vvp_io_fsync_start,
-			.cio_fini   = vvp_io_fini
+			.cio_start	= vvp_io_fsync_start,
+			.cio_fini	= vvp_io_fini
 		},
 		[CIT_MISC] = {
-			.cio_fini   = vvp_io_fini
+			.cio_fini	= vvp_io_fini
 		},
 		[CIT_LADVISE] = {
 			.cio_fini	= vvp_io_fini
@@ -1363,9 +1362,9 @@ static int vvp_io_read_ahead(const struct lu_env *env,
 int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 		struct cl_io *io)
 {
-	struct vvp_io      *vio   = vvp_env_io(env);
-	struct inode       *inode = vvp_object_inode(obj);
-	int		 result;
+	struct vvp_io *vio = vvp_env_io(env);
+	struct inode *inode = vvp_object_inode(obj);
+	int result;
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 86e077b..1637972 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -50,7 +50,7 @@
 
 int vvp_object_invariant(const struct cl_object *obj)
 {
-	struct inode *inode  = vvp_object_inode(obj);
+	struct inode *inode = vvp_object_inode(obj);
 	struct ll_inode_info *lli = ll_i2info(inode);
 
 	return (S_ISREG(inode->i_mode) || inode->i_mode == 0) &&
@@ -60,8 +60,8 @@ int vvp_object_invariant(const struct cl_object *obj)
 static int vvp_object_print(const struct lu_env *env, void *cookie,
 			    lu_printer_t p, const struct lu_object *o)
 {
-	struct vvp_object    *obj   = lu2vvp(o);
-	struct inode	 *inode = obj->vob_inode;
+	struct vvp_object *obj = lu2vvp(o);
+	struct inode *inode = obj->vob_inode;
 	struct ll_inode_info *lli;
 
 	(*p)(env, cookie, "(%d %d) inode: %p ",
@@ -209,13 +209,13 @@ static void vvp_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 }
 
 static const struct cl_object_operations vvp_ops = {
-	.coo_page_init = vvp_page_init,
-	.coo_lock_init = vvp_lock_init,
-	.coo_io_init   = vvp_io_init,
-	.coo_attr_get  = vvp_attr_get,
-	.coo_attr_update = vvp_attr_update,
-	.coo_conf_set  = vvp_conf_set,
-	.coo_prune     = vvp_prune,
+	.coo_page_init		= vvp_page_init,
+	.coo_lock_init		= vvp_lock_init,
+	.coo_io_init		= vvp_io_init,
+	.coo_attr_get		= vvp_attr_get,
+	.coo_attr_update	= vvp_attr_update,
+	.coo_conf_set		= vvp_conf_set,
+	.coo_prune		= vvp_prune,
 	.coo_glimpse		= vvp_object_glimpse,
 	.coo_req_attr_set	= vvp_req_attr_set
 };
@@ -235,8 +235,8 @@ static int vvp_object_init(const struct lu_env *env, struct lu_object *obj,
 {
 	struct vvp_device *dev = lu2vvp_dev(obj->lo_dev);
 	struct vvp_object *vob = lu2vvp(obj);
-	struct lu_object  *below;
-	struct lu_device  *under;
+	struct lu_object *below;
+	struct lu_device *under;
 	int result;
 
 	under = &dev->vdv_next->cd_lu_dev;
@@ -272,8 +272,8 @@ static void vvp_object_free(const struct lu_env *env, struct lu_object *obj)
 struct vvp_object *cl_inode2vvp(struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct cl_object     *obj = lli->lli_clob;
-	struct lu_object     *lu;
+	struct cl_object *obj = lli->lli_clob;
+	struct lu_object *lu;
 
 	lu = lu_object_locate(obj->co_lu.lo_header, &vvp_device_type);
 	LASSERT(lu);
@@ -285,7 +285,7 @@ struct lu_object *vvp_object_alloc(const struct lu_env *env,
 				   struct lu_device *dev)
 {
 	struct vvp_object *vob;
-	struct lu_object  *obj;
+	struct lu_object *obj;
 
 	vob = kmem_cache_zalloc(vvp_object_kmem, GFP_NOFS);
 	if (vob) {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index dcc4d8f..77bf923 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -65,8 +65,8 @@ static void vvp_page_fini_common(struct vvp_page *vpg)
 static void vvp_page_fini(const struct lu_env *env,
 			  struct cl_page_slice *slice)
 {
-	struct vvp_page *vpg     = cl2vvp_page(slice);
-	struct page     *vmpage  = vpg->vpg_page;
+	struct vvp_page *vpg = cl2vvp_page(slice);
+	struct page *vmpage = vpg->vpg_page;
 
 	/*
 	 * vmpage->private was already cleared when page was moved into
@@ -80,8 +80,8 @@ static int vvp_page_own(const struct lu_env *env,
 			const struct cl_page_slice *slice, struct cl_io *io,
 			int nonblock)
 {
-	struct vvp_page *vpg    = cl2vvp_page(slice);
-	struct page     *vmpage = vpg->vpg_page;
+	struct vvp_page *vpg = cl2vvp_page(slice);
+	struct page *vmpage = vpg->vpg_page;
 
 	LASSERT(vmpage);
 	if (nonblock) {
@@ -138,8 +138,8 @@ static void vvp_page_discard(const struct lu_env *env,
 			     const struct cl_page_slice *slice,
 			     struct cl_io *unused)
 {
-	struct page	   *vmpage  = cl2vm_page(slice);
-	struct vvp_page      *vpg     = cl2vvp_page(slice);
+	struct page *vmpage = cl2vm_page(slice);
+	struct vvp_page *vpg = cl2vvp_page(slice);
 
 	LASSERT(vmpage);
 	LASSERT(PageLocked(vmpage));
@@ -153,10 +153,10 @@ static void vvp_page_discard(const struct lu_env *env,
 static void vvp_page_delete(const struct lu_env *env,
 			    const struct cl_page_slice *slice)
 {
-	struct page       *vmpage = cl2vm_page(slice);
-	struct inode     *inode  = vmpage->mapping->host;
-	struct cl_object *obj    = slice->cpl_obj;
-	struct cl_page   *page   = slice->cpl_page;
+	struct page *vmpage = cl2vm_page(slice);
+	struct inode *inode = vmpage->mapping->host;
+	struct cl_object *obj = slice->cpl_obj;
+	struct cl_page *page = slice->cpl_page;
 	int refc;
 
 	LASSERT(PageLocked(vmpage));
@@ -252,10 +252,10 @@ static void vvp_page_completion_read(const struct lu_env *env,
 				     const struct cl_page_slice *slice,
 				     int ioret)
 {
-	struct vvp_page *vpg    = cl2vvp_page(slice);
-	struct page     *vmpage = vpg->vpg_page;
-	struct cl_page  *page   = slice->cpl_page;
-	struct inode    *inode  = vvp_object_inode(page->cp_obj);
+	struct vvp_page *vpg = cl2vvp_page(slice);
+	struct page *vmpage = vpg->vpg_page;
+	struct cl_page *page = slice->cpl_page;
+	struct inode *inode = vvp_object_inode(page->cp_obj);
 
 	LASSERT(PageLocked(vmpage));
 	CL_PAGE_HEADER(D_PAGE, env, page, "completing READ with %d\n", ioret);
@@ -278,9 +278,9 @@ static void vvp_page_completion_write(const struct lu_env *env,
 				      const struct cl_page_slice *slice,
 				      int ioret)
 {
-	struct vvp_page *vpg     = cl2vvp_page(slice);
-	struct cl_page  *pg     = slice->cpl_page;
-	struct page     *vmpage = vpg->vpg_page;
+	struct vvp_page *vpg = cl2vvp_page(slice);
+	struct cl_page *pg = slice->cpl_page;
+	struct page *vmpage = vpg->vpg_page;
 
 	CL_PAGE_HEADER(D_PAGE, env, pg, "completing WRITE with %d\n", ioret);
 
@@ -345,7 +345,7 @@ static int vvp_page_print(const struct lu_env *env,
 			  void *cookie, lu_printer_t printer)
 {
 	struct vvp_page *vpg = cl2vvp_page(slice);
-	struct page     *vmpage = vpg->vpg_page;
+	struct page *vmpage = vpg->vpg_page;
 
 	(*printer)(env, cookie, LUSTRE_VVP_NAME "-page@%p(%d:%d) vm@%p ",
 		   vpg, vpg->vpg_defer_uptodate, vpg->vpg_ra_used, vmpage);
@@ -374,26 +374,26 @@ static int vvp_page_fail(const struct lu_env *env,
 }
 
 static const struct cl_page_operations vvp_page_ops = {
-	.cpo_own	   = vvp_page_own,
-	.cpo_assume	= vvp_page_assume,
-	.cpo_unassume      = vvp_page_unassume,
-	.cpo_disown	= vvp_page_disown,
-	.cpo_discard       = vvp_page_discard,
-	.cpo_delete	= vvp_page_delete,
-	.cpo_export	= vvp_page_export,
-	.cpo_is_vmlocked   = vvp_page_is_vmlocked,
-	.cpo_fini	  = vvp_page_fini,
-	.cpo_print	 = vvp_page_print,
+	.cpo_own		= vvp_page_own,
+	.cpo_assume		= vvp_page_assume,
+	.cpo_unassume		= vvp_page_unassume,
+	.cpo_disown		= vvp_page_disown,
+	.cpo_discard		= vvp_page_discard,
+	.cpo_delete		= vvp_page_delete,
+	.cpo_export		= vvp_page_export,
+	.cpo_is_vmlocked	= vvp_page_is_vmlocked,
+	.cpo_fini		= vvp_page_fini,
+	.cpo_print		= vvp_page_print,
 	.io = {
 		[CRT_READ] = {
 			.cpo_prep	= vvp_page_prep_read,
-			.cpo_completion  = vvp_page_completion_read,
+			.cpo_completion	= vvp_page_completion_read,
 			.cpo_make_ready = vvp_page_fail,
 		},
 		[CRT_WRITE] = {
 			.cpo_prep	= vvp_page_prep_write,
-			.cpo_completion  = vvp_page_completion_write,
-			.cpo_make_ready  = vvp_page_make_ready,
+			.cpo_completion = vvp_page_completion_write,
+			.cpo_make_ready = vvp_page_make_ready,
 		},
 	},
 };
@@ -446,8 +446,8 @@ static void vvp_transient_page_discard(const struct lu_env *env,
 static int vvp_transient_page_is_vmlocked(const struct lu_env *env,
 					  const struct cl_page_slice *slice)
 {
-	struct inode    *inode = vvp_object_inode(slice->cpl_obj);
-	int	locked;
+	struct inode *inode = vvp_object_inode(slice->cpl_obj);
+	int locked;
 
 	locked = !inode_trylock(inode);
 	if (!locked)
@@ -474,22 +474,22 @@ static void vvp_transient_page_fini(const struct lu_env *env,
 }
 
 static const struct cl_page_operations vvp_transient_page_ops = {
-	.cpo_own	   = vvp_transient_page_own,
-	.cpo_assume	= vvp_transient_page_assume,
-	.cpo_unassume      = vvp_transient_page_unassume,
-	.cpo_disown	= vvp_transient_page_disown,
-	.cpo_discard       = vvp_transient_page_discard,
-	.cpo_fini	  = vvp_transient_page_fini,
-	.cpo_is_vmlocked   = vvp_transient_page_is_vmlocked,
-	.cpo_print	 = vvp_page_print,
+	.cpo_own		= vvp_transient_page_own,
+	.cpo_assume		= vvp_transient_page_assume,
+	.cpo_unassume		= vvp_transient_page_unassume,
+	.cpo_disown		= vvp_transient_page_disown,
+	.cpo_discard		= vvp_transient_page_discard,
+	.cpo_fini		= vvp_transient_page_fini,
+	.cpo_is_vmlocked	= vvp_transient_page_is_vmlocked,
+	.cpo_print		= vvp_page_print,
 	.io = {
 		[CRT_READ] = {
 			.cpo_prep	= vvp_transient_page_prep,
-			.cpo_completion  = vvp_transient_page_completion,
+			.cpo_completion = vvp_transient_page_completion,
 		},
 		[CRT_WRITE] = {
 			.cpo_prep	= vvp_transient_page_prep,
-			.cpo_completion  = vvp_transient_page_completion,
+			.cpo_completion	= vvp_transient_page_completion,
 		}
 	}
 };
@@ -498,7 +498,7 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_page *page, pgoff_t index)
 {
 	struct vvp_page *vpg = cl_object_page_slice(obj, page);
-	struct page     *vmpage = page->cp_vmpage;
+	struct page *vmpage = page->cp_vmpage;
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 0670ed3..22f178a 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -631,45 +631,45 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 }
 
 static const struct xattr_handler ll_user_xattr_handler = {
-	.prefix = XATTR_USER_PREFIX,
-	.flags = XATTR_USER_T,
-	.get = ll_xattr_get_common,
-	.set = ll_xattr_set_common,
+	.prefix		= XATTR_USER_PREFIX,
+	.flags		= XATTR_USER_T,
+	.get		= ll_xattr_get_common,
+	.set		= ll_xattr_set_common,
 };
 
 static const struct xattr_handler ll_trusted_xattr_handler = {
-	.prefix = XATTR_TRUSTED_PREFIX,
-	.flags = XATTR_TRUSTED_T,
-	.get = ll_xattr_get,
-	.set = ll_xattr_set,
+	.prefix		= XATTR_TRUSTED_PREFIX,
+	.flags		= XATTR_TRUSTED_T,
+	.get		= ll_xattr_get,
+	.set		= ll_xattr_set,
 };
 
 static const struct xattr_handler ll_security_xattr_handler = {
-	.prefix = XATTR_SECURITY_PREFIX,
-	.flags = XATTR_SECURITY_T,
-	.get = ll_xattr_get_common,
-	.set = ll_xattr_set_common,
+	.prefix		= XATTR_SECURITY_PREFIX,
+	.flags		= XATTR_SECURITY_T,
+	.get		= ll_xattr_get_common,
+	.set		= ll_xattr_set_common,
 };
 
 static const struct xattr_handler ll_acl_access_xattr_handler = {
-	.name = XATTR_NAME_POSIX_ACL_ACCESS,
-	.flags = XATTR_ACL_ACCESS_T,
-	.get = ll_xattr_get_common,
-	.set = ll_xattr_set_common,
+	.name		= XATTR_NAME_POSIX_ACL_ACCESS,
+	.flags		= XATTR_ACL_ACCESS_T,
+	.get		= ll_xattr_get_common,
+	.set		= ll_xattr_set_common,
 };
 
 static const struct xattr_handler ll_acl_default_xattr_handler = {
-	.name = XATTR_NAME_POSIX_ACL_DEFAULT,
-	.flags = XATTR_ACL_DEFAULT_T,
-	.get = ll_xattr_get_common,
-	.set = ll_xattr_set_common,
+	.name		= XATTR_NAME_POSIX_ACL_DEFAULT,
+	.flags		= XATTR_ACL_DEFAULT_T,
+	.get		= ll_xattr_get_common,
+	.set		= ll_xattr_set_common,
 };
 
 static const struct xattr_handler ll_lustre_xattr_handler = {
-	.prefix = XATTR_LUSTRE_PREFIX,
-	.flags = XATTR_LUSTRE_T,
-	.get = ll_xattr_get,
-	.set = ll_xattr_set,
+	.prefix		= XATTR_LUSTRE_PREFIX,
+	.flags		= XATTR_LUSTRE_T,
+	.get		= ll_xattr_get,
+	.set		= ll_xattr_set,
 };
 
 const struct xattr_handler *ll_xattr_handlers[] = {
-- 
1.8.3.1
