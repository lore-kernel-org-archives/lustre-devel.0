From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:12 -0500
Subject: [lustre-devel] [PATCH 08/26] lustre: convert remaining code to
 kernel types
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Convert the remaining Lustre kernel code to use the proper kernel
types.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fid/fid_lib.c        |  2 +-
 drivers/staging/lustre/lustre/fid/fid_request.c    |  4 +-
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |  4 +-
 drivers/staging/lustre/lustre/fld/fld_cache.c      |  4 +-
 drivers/staging/lustre/lustre/fld/fld_internal.h   | 12 ++--
 drivers/staging/lustre/lustre/fld/fld_request.c    |  8 +--
 drivers/staging/lustre/lustre/llite/dir.c          | 30 ++++-----
 drivers/staging/lustre/lustre/llite/file.c         | 46 +++++++-------
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |  4 +-
 .../staging/lustre/lustre/llite/llite_internal.h   | 74 +++++++++++-----------
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 12 ++--
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  2 +-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    | 12 ++--
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  6 +-
 drivers/staging/lustre/lustre/llite/namei.c        | 16 ++---
 drivers/staging/lustre/lustre/llite/range_lock.c   |  4 +-
 drivers/staging/lustre/lustre/llite/range_lock.h   | 10 +--
 drivers/staging/lustre/lustre/llite/rw.c           | 10 +--
 drivers/staging/lustre/lustre/llite/statahead.c    | 26 ++++----
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       | 12 ++--
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |  6 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  8 +--
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |  2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 50 +++++++--------
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  4 +-
 drivers/staging/lustre/lustre/lov/lov_dev.c        | 10 +--
 drivers/staging/lustre/lustre/lov/lov_internal.h   | 20 +++---
 drivers/staging/lustre/lustre/lov/lov_merge.c      |  8 +--
 drivers/staging/lustre/lustre/lov/lov_obd.c        | 46 +++++++-------
 drivers/staging/lustre/lustre/lov/lov_pack.c       |  2 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  4 +-
 drivers/staging/lustre/lustre/lov/lov_request.c    |  4 +-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   | 24 +++----
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        | 22 +++----
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      | 20 +++---
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |  6 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    | 42 ++++++------
 drivers/staging/lustre/lustre/mgc/mgc_request.c    | 16 ++---
 .../staging/lustre/lustre/obdecho/echo_client.c    |  6 +-
 .../staging/lustre/lustre/obdecho/echo_internal.h  |  2 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 10 +--
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  2 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |  6 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         | 10 +--
 drivers/staging/lustre/lustre/osc/osc_lock.c       | 12 ++--
 drivers/staging/lustre/lustre/osc/osc_object.c     |  2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    | 38 +++++------
 48 files changed, 341 insertions(+), 341 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_lib.c b/drivers/staging/lustre/lustre/fid/fid_lib.c
index ac52b37..6b06847 100644
--- a/drivers/staging/lustre/lustre/fid/fid_lib.c
+++ b/drivers/staging/lustre/lustre/fid/fid_lib.c
@@ -60,7 +60,7 @@
  */
 const struct lu_seq_range LUSTRE_SEQ_SPACE_RANGE = {
 	.lsr_start	= FID_SEQ_NORMAL,
-	.lsr_end	= (__u64)~0ULL,
+	.lsr_end	= (u64)~0ULL,
 };
 
 /* Zero range, used for init and other purposes. */
diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index f91242c..3f79f22 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -52,13 +52,13 @@
 static struct dentry *seq_debugfs_dir;
 
 static int seq_client_rpc(struct lu_client_seq *seq,
-			  struct lu_seq_range *output, __u32 opc,
+			  struct lu_seq_range *output, u32 opc,
 			  const char *opcname)
 {
 	struct obd_export     *exp = seq->lcs_exp;
 	struct ptlrpc_request *req;
 	struct lu_seq_range   *out, *in;
-	__u32                 *op;
+	u32                 *op;
 	unsigned int           debug_mask;
 	int                    rc;
 
diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index aa2df68..d583778 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -50,7 +50,7 @@
 #include "fid_internal.h"
 
 /* Format: [0x64BIT_INT - 0x64BIT_INT] + 32 bytes just in case */
-#define MAX_FID_RANGE_STRLEN (32 + 2 * 2 * sizeof(__u64))
+#define MAX_FID_RANGE_STRLEN (32 + 2 * 2 * sizeof(u64))
 /*
  * Note: this function is only used for testing, it is no safe for production
  * use.
@@ -143,7 +143,7 @@
 			     size_t count, loff_t *off)
 {
 	struct lu_client_seq *seq;
-	__u64  max;
+	u64  max;
 	int rc, val;
 
 	seq = ((struct seq_file *)file->private_data)->private;
diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index a7415c9..749d33b 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -94,7 +94,7 @@ struct fld_cache *fld_cache_init(const char *name,
  */
 void fld_cache_fini(struct fld_cache *cache)
 {
-	__u64 pct;
+	u64 pct;
 
 	LASSERT(cache);
 	fld_cache_flush(cache);
@@ -383,7 +383,7 @@ static int fld_cache_insert_nolock(struct fld_cache *cache,
 	struct list_head *prev = NULL;
 	const u64 new_start  = f_new->fce_range.lsr_start;
 	const u64 new_end  = f_new->fce_range.lsr_end;
-	__u32 new_flags  = f_new->fce_range.lsr_flags;
+	u32 new_flags  = f_new->fce_range.lsr_flags;
 
 	/*
 	 * Duplicate entries are eliminated in insert op.
diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index e1d6aaa..66a0fb6 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -63,15 +63,15 @@
 #include <lustre_fld.h>
 
 struct fld_stats {
-	__u64   fst_count;
-	__u64   fst_cache;
-	__u64   fst_inflight;
+	u64   fst_count;
+	u64   fst_cache;
+	u64   fst_inflight;
 };
 
 struct lu_fld_hash {
 	const char	      *fh_name;
-	int (*fh_hash_func)(struct lu_client_fld *, __u64);
-	struct lu_fld_target *(*fh_scan_func)(struct lu_client_fld *, __u64);
+	int (*fh_hash_func)(struct lu_client_fld *, u64);
+	struct lu_fld_target *(*fh_scan_func)(struct lu_client_fld *, u64);
 };
 
 struct fld_cache_entry {
@@ -130,7 +130,7 @@ enum {
 extern struct lu_fld_hash fld_hash[];
 
 int fld_client_rpc(struct obd_export *exp,
-		   struct lu_seq_range *range, __u32 fld_op,
+		   struct lu_seq_range *range, u32 fld_op,
 		   struct ptlrpc_request **reqp);
 
 extern struct lprocfs_vars fld_client_debugfs_list[];
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 7b0365b..8a915b9 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -193,7 +193,7 @@ int fld_client_add_target(struct lu_client_fld *fld,
 EXPORT_SYMBOL(fld_client_add_target);
 
 /* Remove export from FLD */
-int fld_client_del_target(struct lu_client_fld *fld, __u64 idx)
+int fld_client_del_target(struct lu_client_fld *fld, u64 idx)
 {
 	struct lu_fld_target *target, *tmp;
 
@@ -303,12 +303,12 @@ void fld_client_fini(struct lu_client_fld *fld)
 EXPORT_SYMBOL(fld_client_fini);
 
 int fld_client_rpc(struct obd_export *exp,
-		   struct lu_seq_range *range, __u32 fld_op,
+		   struct lu_seq_range *range, u32 fld_op,
 		   struct ptlrpc_request **reqp)
 {
 	struct ptlrpc_request *req = NULL;
 	struct lu_seq_range   *prange;
-	__u32		 *op;
+	u32		 *op;
 	int		    rc = 0;
 	struct obd_import     *imp;
 
@@ -383,7 +383,7 @@ int fld_client_rpc(struct obd_export *exp,
 }
 
 int fld_client_lookup(struct lu_client_fld *fld, u64 seq, u32 *mds,
-		      __u32 flags, const struct lu_env *env)
+		      u32 flags, const struct lu_env *env)
 {
 	struct lu_seq_range res = { 0 };
 	struct lu_fld_target *target;
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 2459f5c..4520344 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -138,7 +138,7 @@
  *
  */
 struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
-			     __u64 offset)
+			     u64 offset)
 {
 	struct md_callback cb_op;
 	struct page *page;
@@ -180,9 +180,9 @@ void ll_release_page(struct inode *inode, struct page *page, bool remove)
  * IF_* flag shld be converted to particular OS file type in
  * platform llite module.
  */
-static __u16 ll_dirent_type_get(struct lu_dirent *ent)
+static u16 ll_dirent_type_get(struct lu_dirent *ent)
 {
-	__u16 type = 0;
+	u16 type = 0;
 	struct luda_type *lt;
 	int len = 0;
 
@@ -197,11 +197,11 @@ static __u16 ll_dirent_type_get(struct lu_dirent *ent)
 	return type;
 }
 
-int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
+int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 		struct dir_context *ctx)
 {
 	struct ll_sb_info    *sbi	= ll_i2sbi(inode);
-	__u64		   pos		= *ppos;
+	u64		   pos		= *ppos;
 	bool is_api32 = ll_need_32bit_api(sbi);
 	int		   is_hash64 = sbi->ll_flags & LL_SBI_64BIT_HASH;
 	struct page	  *page;
@@ -213,8 +213,8 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 	while (rc == 0 && !done) {
 		struct lu_dirpage *dp;
 		struct lu_dirent  *ent;
-		__u64 hash;
-		__u64 next;
+		u64 hash;
+		u64 next;
 
 		if (IS_ERR(page)) {
 			rc = PTR_ERR(page);
@@ -225,11 +225,11 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 		dp = page_address(page);
 		for (ent = lu_dirent_start(dp); ent && !done;
 		     ent = lu_dirent_next(ent)) {
-			__u16	  type;
+			u16	  type;
 			int	    namelen;
 			struct lu_fid  fid;
-			__u64	  lhash;
-			__u64	  ino;
+			u64	  lhash;
+			u64	  ino;
 
 			hash = le64_to_cpu(ent->lde_hash);
 			if (hash < pos)
@@ -294,7 +294,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	struct inode		*inode	= file_inode(filp);
 	struct ll_file_data	*lfd	= LUSTRE_FPRIVATE(filp);
 	struct ll_sb_info	*sbi	= ll_i2sbi(inode);
-	__u64 pos = lfd ? lfd->lfd_pos : 0;
+	u64 pos = lfd ? lfd->lfd_pos : 0;
 	int			hash64	= sbi->ll_flags & LL_SBI_64BIT_HASH;
 	bool api32 = ll_need_32bit_api(sbi);
 	struct md_op_data *op_data;
@@ -327,7 +327,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 		 */
 		if (file_dentry(filp)->d_parent &&
 		    file_dentry(filp)->d_parent->d_inode) {
-			__u64 ibits = MDS_INODELOCK_UPDATE;
+			u64 ibits = MDS_INODELOCK_UPDATE;
 			struct inode *parent;
 
 			parent = file_dentry(filp)->d_parent->d_inode;
@@ -760,7 +760,7 @@ static int ll_ioc_copy_start(struct super_block *sb, struct hsm_copy *copy)
 	/* For archive request, we need to read the current file version. */
 	if (copy->hc_hai.hai_action == HSMA_ARCHIVE) {
 		struct inode	*inode;
-		__u64		 data_version = 0;
+		u64		 data_version = 0;
 
 		/* Get inode for this fid */
 		inode = search_inode_for_lustre(sb, &copy->hc_hai.hai_fid);
@@ -845,7 +845,7 @@ static int ll_ioc_copy_end(struct super_block *sb, struct hsm_copy *copy)
 	     (copy->hc_hai.hai_action == HSMA_RESTORE)) &&
 	    (copy->hc_errval == 0)) {
 		struct inode	*inode;
-		__u64		 data_version = 0;
+		u64		 data_version = 0;
 
 		/* Get lsm for this fid */
 		inode = search_inode_for_lustre(sb, &copy->hc_hai.hai_fid);
@@ -1522,7 +1522,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case LL_IOC_FID2MDTIDX: {
 		struct obd_export *exp = ll_i2mdexp(inode);
 		struct lu_fid fid;
-		__u32 index;
+		u32 index;
 
 		if (copy_from_user(&fid, (const struct lu_fid __user *)arg,
 				   sizeof(fid)))
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 94574b7..f71e273 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -158,7 +158,7 @@ static int ll_close_inode_openhandle(struct inode *inode,
 	case MDS_HSM_RELEASE:
 		LASSERT(data);
 		op_data->op_bias |= MDS_HSM_RELEASE;
-		op_data->op_data_version = *(__u64 *)data;
+		op_data->op_data_version = *(u64 *)data;
 		op_data->op_lease_handle = och->och_lease_handle;
 		op_data->op_attr.ia_valid |= ATTR_SIZE;
 		op_data->op_xvalid |= OP_XVALID_BLOCKS;
@@ -200,7 +200,7 @@ int ll_md_real_close(struct inode *inode, fmode_t fmode)
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct obd_client_handle **och_p;
 	struct obd_client_handle *och;
-	__u64 *och_usecount;
+	u64 *och_usecount;
 	int rc = 0;
 
 	if (fmode & FMODE_WRITE) {
@@ -243,7 +243,7 @@ static int ll_md_close(struct inode *inode, struct file *file)
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct ll_inode_info *lli = ll_i2info(inode);
 	int lockmode;
-	__u64 flags = LDLM_FL_BLOCK_GRANTED | LDLM_FL_TEST_LOCK;
+	u64 flags = LDLM_FL_BLOCK_GRANTED | LDLM_FL_TEST_LOCK;
 	struct lustre_handle lockh;
 	union ldlm_policy_data policy = {
 		.l_inodebits = { MDS_INODELOCK_OPEN }
@@ -491,7 +491,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 	struct lookup_intent *it, oit = { .it_op = IT_OPEN,
 					  .it_flags = file->f_flags };
 	struct obd_client_handle **och_p = NULL;
-	__u64 *och_usecount = NULL;
+	u64 *och_usecount = NULL;
 	struct ll_file_data *fd;
 	int rc = 0;
 
@@ -813,7 +813,7 @@ static int ll_lease_och_release(struct inode *inode, struct file *file)
  */
 static struct obd_client_handle *
 ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
-	      __u64 open_flags)
+	      u64 open_flags)
 {
 	struct lookup_intent it = { .it_op = IT_OPEN };
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
@@ -1366,7 +1366,7 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 }
 
 int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
-			     __u64 flags, struct lov_user_md *lum,
+			     u64 flags, struct lov_user_md *lum,
 			     int lum_size)
 {
 	struct lookup_intent oit = {
@@ -1483,7 +1483,7 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 static int ll_lov_setea(struct inode *inode, struct file *file,
 			void __user *arg)
 {
-	__u64			 flags = MDS_OPEN_HAS_OBJS | FMODE_WRITE;
+	u64			 flags = MDS_OPEN_HAS_OBJS | FMODE_WRITE;
 	struct lov_user_md	*lump;
 	int			 lum_size = sizeof(struct lov_user_md) +
 					    sizeof(struct lov_user_ost_data);
@@ -1530,7 +1530,7 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 	struct lov_user_md __user *lum = (struct lov_user_md __user *)arg;
 	struct lov_user_md *klum;
 	int lum_size, rc;
-	__u64 flags = FMODE_WRITE;
+	u64 flags = FMODE_WRITE;
 
 	rc = ll_copy_user_md(lum, &klum);
 	if (rc < 0)
@@ -1828,7 +1828,7 @@ int ll_fid2path(struct inode *inode, void __user *arg)
  *		LL_DV_RD_FLUSH: flush dirty pages, LCK_PR on OSTs
  *		LL_DV_WR_FLUSH: drop all caching pages, LCK_PW on OSTs
  */
-int ll_data_version(struct inode *inode, __u64 *data_version, int flags)
+int ll_data_version(struct inode *inode, u64 *data_version, int flags)
 {
 	struct cl_object *obj = ll_i2info(inode)->lli_clob;
 	struct lu_env *env;
@@ -1876,7 +1876,7 @@ int ll_hsm_release(struct inode *inode)
 {
 	struct lu_env *env;
 	struct obd_client_handle *och = NULL;
-	__u64 data_version = 0;
+	u64 data_version = 0;
 	int rc;
 	u16 refcheck;
 
@@ -1933,8 +1933,8 @@ static int ll_swap_layouts(struct file *file1, struct file *file2,
 {
 	struct mdc_swap_layouts	 msl;
 	struct md_op_data	*op_data;
-	__u32			 gid;
-	__u64			 dv;
+	u32			 gid;
+	u64			 dv;
 	struct ll_swap_stack	*llss = NULL;
 	int			 rc;
 
@@ -2186,7 +2186,7 @@ static int ll_file_futimes_3(struct file *file, const struct ll_futimes_3 *lfu)
  * all that data into each client cache with fadvise() may not be, due to
  * much more data being sent to the client.
  */
-static int ll_ladvise(struct inode *inode, struct file *file, __u64 flags,
+static int ll_ladvise(struct inode *inode, struct file *file, u64 flags,
 		      struct llapi_lu_ladvise *ladvise)
 {
 	struct cl_ladvise_io *lio;
@@ -2869,7 +2869,7 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	struct lustre_handle lockh = {0};
 	union ldlm_policy_data flock = { { 0 } };
 	int fl_type = file_lock->fl_type;
-	__u64 flags = 0;
+	u64 flags = 0;
 	int rc;
 	int rc2 = 0;
 
@@ -3179,7 +3179,7 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
  * \param l_req_mode [IN] searched lock mode
  * \retval boolean, true iff all bits are found
  */
-int ll_have_md_lock(struct inode *inode, __u64 *bits,
+int ll_have_md_lock(struct inode *inode, u64 *bits,
 		    enum ldlm_mode l_req_mode)
 {
 	struct lustre_handle lockh;
@@ -3187,7 +3187,7 @@ int ll_have_md_lock(struct inode *inode, __u64 *bits,
 	enum ldlm_mode mode = (l_req_mode == LCK_MINMODE) ?
 			      (LCK_CR | LCK_CW | LCK_PR | LCK_PW) : l_req_mode;
 	struct lu_fid *fid;
-	__u64 flags;
+	u64 flags;
 	int i;
 
 	if (!inode)
@@ -3220,8 +3220,8 @@ int ll_have_md_lock(struct inode *inode, __u64 *bits,
 	return *bits == 0;
 }
 
-enum ldlm_mode ll_take_md_lock(struct inode *inode, __u64 bits,
-			       struct lustre_handle *lockh, __u64 flags,
+enum ldlm_mode ll_take_md_lock(struct inode *inode, u64 bits,
+			       struct lustre_handle *lockh, u64 flags,
 			       enum ldlm_mode mode)
 {
 	union ldlm_policy_data policy = { .l_inodebits = { bits } };
@@ -3261,7 +3261,7 @@ static int ll_inode_revalidate_fini(struct inode *inode, int rc)
 	return rc;
 }
 
-static int __ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
+static int __ll_inode_revalidate(struct dentry *dentry, u64 ibits)
 {
 	struct inode *inode = d_inode(dentry);
 	struct ptlrpc_request *req = NULL;
@@ -3371,7 +3371,7 @@ static int ll_merge_md_attr(struct inode *inode)
 	return 0;
 }
 
-static int ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
+static int ll_inode_revalidate(struct dentry *dentry, u64 ibits)
 {
 	struct inode *inode = d_inode(dentry);
 	int rc;
@@ -3453,7 +3453,7 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 }
 
 static int ll_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
-		     __u64 start, __u64 len)
+		     u64 start, u64 len)
 {
 	int rc;
 	size_t num_bytes;
@@ -3888,7 +3888,7 @@ static int ll_layout_intent(struct inode *inode, struct layout_intent *intent)
  * is finished, this function should be called again to verify that layout
  * is not changed during IO time.
  */
-int ll_layout_refresh(struct inode *inode, __u32 *gen)
+int ll_layout_refresh(struct inode *inode, u32 *gen)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
@@ -3963,7 +3963,7 @@ int ll_layout_write_intent(struct inode *inode, u64 start, u64 end)
 /**
  *  This function send a restore request to the MDT
  */
-int ll_layout_restore(struct inode *inode, loff_t offset, __u64 length)
+int ll_layout_restore(struct inode *inode, loff_t offset, u64 length)
 {
 	struct hsm_user_request	*hur;
 	int			 len, rc;
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index 80563a2..75156d8 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -85,7 +85,7 @@ int cl_ocd_update(struct obd_device *host, struct obd_device *watched,
 {
 	struct lustre_client_ocd *lco;
 	struct client_obd	*cli;
-	__u64 flags;
+	u64 flags;
 	int   result;
 
 	if (!strcmp(watched->obd_type->typ_name, LUSTRE_OSC_NAME) &&
@@ -122,7 +122,7 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 	struct cl_io	   *io;
 	struct cl_lock	 *lock;
 	struct cl_lock_descr   *descr;
-	__u32		   enqflags;
+	u32		   enqflags;
 	u16 refcheck;
 	int		     rc;
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index c680a49..bf7e46f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -113,7 +113,7 @@ enum ll_file_flags {
 };
 
 struct ll_inode_info {
-	__u32				lli_inode_magic;
+	u32				lli_inode_magic;
 
 	spinlock_t			lli_lock;
 	unsigned long			lli_flags;
@@ -130,9 +130,9 @@ struct ll_inode_info {
 	struct obd_client_handle       *lli_mds_read_och;
 	struct obd_client_handle       *lli_mds_write_och;
 	struct obd_client_handle       *lli_mds_exec_och;
-	__u64			   lli_open_fd_read_count;
-	__u64			   lli_open_fd_write_count;
-	__u64			   lli_open_fd_exec_count;
+	u64			   lli_open_fd_read_count;
+	u64			   lli_open_fd_write_count;
+	u64			   lli_open_fd_exec_count;
 	/* Protects access to och pointers and their usage counters */
 	struct mutex			lli_och_mutex;
 
@@ -184,7 +184,7 @@ struct ll_inode_info {
 			 * "dmv" and gets the rest of the default layout itself
 			 * (count, hash, etc).
 			 */
-			__u32				lli_def_stripe_offset;
+			u32				lli_def_stripe_offset;
 		};
 
 		/* for non-directory */
@@ -204,7 +204,7 @@ struct ll_inode_info {
 			struct rw_semaphore		lli_glimpse_sem;
 			unsigned long			lli_glimpse_time;
 			struct list_head		lli_agl_list;
-			__u64				lli_agl_index;
+			u64				lli_agl_index;
 
 			/* for writepage() only to communicate to fsync */
 			int				lli_async_rc;
@@ -236,7 +236,7 @@ struct ll_inode_info {
 	/* mutex to request for layout lock exclusively. */
 	struct mutex			lli_layout_mutex;
 	/* Layout version, protected by lli_layout_lock */
-	__u32				lli_layout_gen;
+	u32				lli_layout_gen;
 	spinlock_t			lli_layout_lock;
 
 	u32				lli_projid;	/* project id */
@@ -246,9 +246,9 @@ struct ll_inode_info {
 	struct list_head		lli_xattrs;/* ll_xattr_entry->xe_list */
 };
 
-static inline __u32 ll_layout_version_get(struct ll_inode_info *lli)
+static inline u32 ll_layout_version_get(struct ll_inode_info *lli)
 {
-	__u32 gen;
+	u32 gen;
 
 	spin_lock(&lli->lli_layout_lock);
 	gen = lli->lli_layout_gen;
@@ -257,7 +257,7 @@ static inline __u32 ll_layout_version_get(struct ll_inode_info *lli)
 	return gen;
 }
 
-static inline void ll_layout_version_set(struct ll_inode_info *lli, __u32 gen)
+static inline void ll_layout_version_set(struct ll_inode_info *lli, u32 gen)
 {
 	spin_lock(&lli->lli_layout_lock);
 	lli->lli_layout_gen = gen;
@@ -267,7 +267,7 @@ static inline void ll_layout_version_set(struct ll_inode_info *lli, __u32 gen)
 int ll_xattr_cache_destroy(struct inode *inode);
 
 int ll_xattr_cache_get(struct inode *inode, const char *name,
-		       char *buffer, size_t size, __u64 valid);
+		       char *buffer, size_t size, u64 valid);
 
 static inline bool obd_connect_has_secctx(struct obd_connect_data *data)
 {
@@ -466,7 +466,7 @@ struct lustre_client_ocd {
 	 * (LOVs) this mount is connected to. This field is updated by
 	 * cl_ocd_update() under ->lco_lock.
 	 */
-	__u64			 lco_flags;
+	u64			 lco_flags;
 	struct mutex		 lco_lock;
 	struct obd_export	*lco_md_exp;
 	struct obd_export	*lco_dt_exp;
@@ -646,8 +646,8 @@ struct ll_readahead_state {
 struct ll_file_data {
 	struct ll_readahead_state fd_ras;
 	struct ll_grouplock fd_grouplock;
-	__u64 lfd_pos;
-	__u32 fd_flags;
+	u64 lfd_pos;
+	u32 fd_flags;
 	fmode_t fd_omode;
 	/* openhandle if lease exists for this file.
 	 * Borrow lli->lli_och_mutex to protect assignment
@@ -672,8 +672,8 @@ static inline struct inode *ll_info2i(struct ll_inode_info *lli)
 	return &lli->lli_vfs_inode;
 }
 
-__u32 ll_i2suppgid(struct inode *i);
-void ll_i2gids(__u32 *suppgids, struct inode *i1, struct inode *i2);
+u32 ll_i2suppgid(struct inode *i);
+void ll_i2gids(u32 *suppgids, struct inode *i1, struct inode *i2);
 
 static inline bool ll_need_32bit_api(struct ll_sb_info *sbi)
 {
@@ -764,12 +764,12 @@ enum {
 /* llite/dir.c */
 extern const struct file_operations ll_dir_operations;
 extern const struct inode_operations ll_dir_inode_operations;
-int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
+int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 		struct dir_context *ctx);
 int ll_get_mdt_idx(struct inode *inode);
 int ll_get_mdt_idx_by_fid(struct ll_sb_info *sbi, const struct lu_fid *fid);
 struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
-			     __u64 offset);
+			     u64 offset);
 void ll_release_page(struct inode *inode, struct page *page, bool remove);
 
 /* llite/namei.c */
@@ -803,10 +803,10 @@ void ll_cl_add(struct file *file, const struct lu_env *env, struct cl_io *io,
 extern const struct file_operations ll_file_operations_flock;
 extern const struct file_operations ll_file_operations_noflock;
 extern const struct inode_operations ll_file_inode_operations;
-int ll_have_md_lock(struct inode *inode, __u64 *bits,
+int ll_have_md_lock(struct inode *inode, u64 *bits,
 		    enum ldlm_mode l_req_mode);
-enum ldlm_mode ll_take_md_lock(struct inode *inode, __u64 bits,
-			       struct lustre_handle *lockh, __u64 flags,
+enum ldlm_mode ll_take_md_lock(struct inode *inode, u64 bits,
+			       struct lustre_handle *lockh, u64 flags,
 			       enum ldlm_mode mode);
 int ll_file_open(struct inode *inode, struct file *file);
 int ll_file_release(struct inode *inode, struct file *file);
@@ -832,7 +832,7 @@ int ll_ioctl_fsgetxattr(struct inode *inode, unsigned int cmd,
 int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 			unsigned long arg);
 int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
-			     __u64 flags, struct lov_user_md *lum,
+			     u64 flags, struct lov_user_md *lum,
 			     int lum_size);
 int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 			     struct lov_mds_md **lmm, int *lmm_size,
@@ -844,7 +844,7 @@ int ll_dir_getstripe(struct inode *inode, void **lmmp, int *lmm_size,
 int ll_fsync(struct file *file, loff_t start, loff_t end, int data);
 int ll_merge_attr(const struct lu_env *env, struct inode *inode);
 int ll_fid2path(struct inode *inode, void __user *arg);
-int ll_data_version(struct inode *inode, __u64 *data_version, int flags);
+int ll_data_version(struct inode *inode, u64 *data_version, int flags);
 int ll_hsm_release(struct inode *inode);
 int ll_hsm_state_set(struct inode *inode, struct hsm_state_set *hss);
 
@@ -904,7 +904,7 @@ enum {
 struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      struct inode *i1, struct inode *i2,
 				      const char *name, size_t namelen,
-				      u32 mode, __u32 opc, void *data);
+				      u32 mode, u32 opc, void *data);
 void ll_finish_md_op_data(struct md_op_data *op_data);
 int ll_get_obd_name(struct inode *inode, unsigned int cmd, unsigned long arg);
 char *ll_get_fsname(struct super_block *sb, char *buf, int buflen);
@@ -935,7 +935,7 @@ static inline ssize_t ll_lov_user_md_size(const struct lov_user_md *lum)
 
 /* llite/llite_nfs.c */
 extern const struct export_operations lustre_export_operations;
-__u32 get_uuid2int(const char *name, int len);
+u32 get_uuid2int(const char *name, int len);
 void get_uuid2fsid(const char *name, int len, __kernel_fsid_t *fsid);
 struct inode *search_inode_for_lustre(struct super_block *sb,
 				      const struct lu_fid *fid);
@@ -995,7 +995,7 @@ static inline struct vvp_io_args *ll_env_args(const struct lu_env *env)
 
 /* llite/llite_mmap.c */
 
-int ll_teardown_mmaps(struct address_space *mapping, __u64 first, __u64 last);
+int ll_teardown_mmaps(struct address_space *mapping, u64 first, u64 last);
 int ll_file_mmap(struct file *file, struct vm_area_struct *vma);
 void policy_from_vma(union ldlm_policy_data *policy, struct vm_area_struct *vma,
 		     unsigned long addr, size_t count);
@@ -1074,7 +1074,7 @@ static inline loff_t ll_file_maxbytes(struct inode *inode)
 
 ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size);
 int ll_xattr_list(struct inode *inode, const char *name, int type,
-		  void *buffer, size_t size, __u64 valid);
+		  void *buffer, size_t size, u64 valid);
 const struct xattr_handler *get_xattr_type(const char *name);
 
 /**
@@ -1114,16 +1114,16 @@ struct ll_statahead_info {
 					     * refcount
 					     */
 	unsigned int	    sai_max;	/* max ahead of lookup */
-	__u64		   sai_sent;       /* stat requests sent count */
-	__u64		   sai_replied;    /* stat requests which received
+	u64		   sai_sent;       /* stat requests sent count */
+	u64		   sai_replied;    /* stat requests which received
 					    * reply
 					    */
-	__u64		   sai_index;      /* index of statahead entry */
-	__u64		   sai_index_wait; /* index of entry which is the
+	u64		   sai_index;      /* index of statahead entry */
+	u64		   sai_index_wait; /* index of entry which is the
 					    * caller is waiting for
 					    */
-	__u64		   sai_hit;	/* hit count */
-	__u64		   sai_miss;       /* miss count:
+	u64		   sai_hit;	/* hit count */
+	u64		   sai_miss;       /* miss count:
 					    * for "ls -al" case, it includes
 					    * hidden dentry miss;
 					    * for "ls -l" case, it does not
@@ -1249,7 +1249,7 @@ static inline int ll_file_nolock(const struct file *file)
 }
 
 static inline void ll_set_lock_data(struct obd_export *exp, struct inode *inode,
-				    struct lookup_intent *it, __u64 *bits)
+				    struct lookup_intent *it, u64 *bits)
 {
 	if (!it->it_lock_set) {
 		struct lustre_handle handle;
@@ -1318,8 +1318,8 @@ static inline void d_lustre_revalidate(struct dentry *dentry)
 }
 
 int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf);
-int ll_layout_refresh(struct inode *inode, __u32 *gen);
-int ll_layout_restore(struct inode *inode, loff_t start, __u64 length);
+int ll_layout_refresh(struct inode *inode, u32 *gen);
+int ll_layout_restore(struct inode *inode, loff_t start, u64 length);
 int ll_layout_write_intent(struct inode *inode, u64 start, u64 end);
 
 int ll_xattr_init(void);
@@ -1341,6 +1341,6 @@ int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
 void cl_inode_fini(struct inode *inode);
 
 u64 cl_fid_build_ino(const struct lu_fid *fid, bool api32);
-__u32 cl_fid_build_gen(const struct lu_fid *fid);
+u32 cl_fid_build_gen(const struct lu_fid *fid);
 
 #endif /* LLITE_INTERNAL_H */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 7b1226b..88b08dd 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2142,7 +2142,7 @@ int ll_remount_fs(struct super_block *sb, int *flags, char *data)
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	char *profilenm = get_profile_name(sb);
 	int err;
-	__u32 read_only;
+	u32 read_only;
 
 	if ((bool)(*flags & SB_RDONLY) != sb_rdonly(sb)) {
 		read_only = *flags & SB_RDONLY;
@@ -2297,7 +2297,7 @@ int ll_obd_statfs(struct inode *inode, void __user *arg)
 	struct obd_export *exp;
 	char *buf = NULL;
 	struct obd_ioctl_data *data = NULL;
-	__u32 type;
+	u32 type;
 	int len = 0, rc;
 
 	if (!inode) {
@@ -2322,15 +2322,15 @@ int ll_obd_statfs(struct inode *inode, void __user *arg)
 		goto out_statfs;
 	}
 
-	if (data->ioc_inllen1 != sizeof(__u32) ||
-	    data->ioc_inllen2 != sizeof(__u32) ||
+	if (data->ioc_inllen1 != sizeof(u32) ||
+	    data->ioc_inllen2 != sizeof(u32) ||
 	    data->ioc_plen1 != sizeof(struct obd_statfs) ||
 	    data->ioc_plen2 != sizeof(struct obd_uuid)) {
 		rc = -EINVAL;
 		goto out_statfs;
 	}
 
-	memcpy(&type, data->ioc_inlbuf1, sizeof(__u32));
+	memcpy(&type, data->ioc_inlbuf1, sizeof(u32));
 	if (type & LL_STATFS_LMV) {
 		exp = sbi->ll_md_exp;
 	} else if (type & LL_STATFS_LOV) {
@@ -2352,7 +2352,7 @@ int ll_obd_statfs(struct inode *inode, void __user *arg)
 struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      struct inode *i1, struct inode *i2,
 				      const char *name, size_t namelen,
-				      u32 mode, __u32 opc, void *data)
+				      u32 mode, u32 opc, void *data)
 {
 	if (!name) {
 		/* Do not reuse namelen for something else. */
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 33e23ee..c6e9f10 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -466,7 +466,7 @@ static void ll_vm_close(struct vm_area_struct *vma)
 /* XXX put nice comment here.  talk about __free_pte -> dirty pages and
  * nopage's reference passing to the pte
  */
-int ll_teardown_mmaps(struct address_space *mapping, __u64 first, __u64 last)
+int ll_teardown_mmaps(struct address_space *mapping, u64 first, u64 last)
 {
 	int rc = -ENOENT;
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 5e91e83..7c5c9b8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -42,12 +42,12 @@
 #include "llite_internal.h"
 #include <linux/exportfs.h>
 
-__u32 get_uuid2int(const char *name, int len)
+u32 get_uuid2int(const char *name, int len)
 {
-	__u32 key0 = 0x12a3fe2d, key1 = 0x37abe8f9;
+	u32 key0 = 0x12a3fe2d, key1 = 0x37abe8f9;
 
 	while (len--) {
-		__u32 key = key1 + (key0 ^ (*name++ * 7152373));
+		u32 key = key1 + (key0 ^ (*name++ * 7152373));
 
 		if (key & 0x80000000)
 			key -= 0x7fffffff;
@@ -59,7 +59,7 @@ __u32 get_uuid2int(const char *name, int len)
 
 void get_uuid2fsid(const char *name, int len, __kernel_fsid_t *fsid)
 {
-	__u64 key = 0, key0 = 0x12a3fe2d, key1 = 0x37abe8f9;
+	u64 key = 0, key0 = 0x12a3fe2d, key1 = 0x37abe8f9;
 
 	while (len--) {
 		key = key1 + (key0 ^ (*name++ * 7152373));
@@ -186,7 +186,7 @@ struct lustre_nfs_fid {
  * 2 -- contains child file handle and parent file handle;
  * 255 -- error.
  */
-static int ll_encode_fh(struct inode *inode, __u32 *fh, int *plen,
+static int ll_encode_fh(struct inode *inode, u32 *fh, int *plen,
 			struct inode *parent)
 {
 	int fileid_len = sizeof(struct lustre_nfs_fid) / 4;
@@ -243,7 +243,7 @@ static int ll_get_name(struct dentry *dentry, char *name,
 		.ctx.actor = ll_nfs_get_name_filldir,
 	};
 	struct md_op_data *op_data;
-	__u64 pos = 0;
+	u64 pos = 0;
 
 	if (!dir || !S_ISDIR(dir->i_mode)) {
 		rc = -ENOTDIR;
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 9404bb7..672de81 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1232,8 +1232,8 @@ static void llite_kobj_release(struct kobject *kobj)
 };
 
 static const struct llite_file_opcode {
-	__u32       opcode;
-	__u32       type;
+	u32       opcode;
+	u32       type;
 	const char *opname;
 } llite_opcode_table[LPROC_LL_FILE_OPCODES] = {
 	/* file operation */
@@ -1352,7 +1352,7 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 
 	/* do counter init */
 	for (id = 0; id < LPROC_LL_FILE_OPCODES; id++) {
-		__u32 type = llite_opcode_table[id].type;
+		u32 type = llite_opcode_table[id].type;
 		void *ptr = NULL;
 
 		if (type & LPROCFS_TYPE_REGS)
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index b5b46f7..8bdf947 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -191,7 +191,7 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		break;
 	case LDLM_CB_CANCELING: {
 		struct inode *inode = ll_inode_from_resource_lock(lock);
-		__u64 bits = lock->l_policy_data.l_inodebits.bits;
+		u64 bits = lock->l_policy_data.l_inodebits.bits;
 
 		/* Inode is set to lock->l_resource->lr_lvb_inode
 		 * for mdc - bug 24555
@@ -348,12 +348,12 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 	return 0;
 }
 
-__u32 ll_i2suppgid(struct inode *i)
+u32 ll_i2suppgid(struct inode *i)
 {
 	if (in_group_p(i->i_gid))
-		return (__u32)from_kgid(&init_user_ns, i->i_gid);
+		return (u32)from_kgid(&init_user_ns, i->i_gid);
 	else
-		return (__u32)(-1);
+		return (u32)(-1);
 }
 
 /* Pack the required supplementary groups into the supplied groups array.
@@ -361,7 +361,7 @@ __u32 ll_i2suppgid(struct inode *i)
  * instead pack one or more groups from the user's supplementary group
  * array in case it might be useful.  Not needed if doing an MDS-side upcall.
  */
-void ll_i2gids(__u32 *suppgids, struct inode *i1, struct inode *i2)
+void ll_i2gids(u32 *suppgids, struct inode *i1, struct inode *i2)
 {
 	LASSERT(i1);
 
@@ -454,7 +454,7 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 			       struct inode *parent, struct dentry **de)
 {
 	struct inode *inode = NULL;
-	__u64 bits = 0;
+	u64 bits = 0;
 	int rc = 0;
 	struct dentry *alias;
 
@@ -536,7 +536,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	struct ptlrpc_request *req = NULL;
 	struct md_op_data *op_data = NULL;
 	struct inode *inode;
-	__u32 opc;
+	u32 opc;
 	int rc;
 
 	if (dentry->d_name.len > ll_i2sbi(parent)->ll_namelen)
@@ -901,7 +901,7 @@ void ll_update_times(struct ptlrpc_request *request, struct inode *inode)
 
 static int ll_new_node(struct inode *dir, struct dentry *dentry,
 		       const char *tgt, umode_t mode, int rdev,
-		       __u32 opc)
+		       u32 opc)
 {
 	struct ptlrpc_request *request = NULL;
 	struct md_op_data *op_data;
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.c b/drivers/staging/lustre/lustre/llite/range_lock.c
index d37da8e..c1f0e1e 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.c
+++ b/drivers/staging/lustre/lustre/llite/range_lock.c
@@ -42,7 +42,7 @@
 #define START(node) ((node)->rl_start)
 #define LAST(node)  ((node)->rl_last)
 
-INTERVAL_TREE_DEFINE(struct range_lock, rl_rb, __u64, __subtree_last,
+INTERVAL_TREE_DEFINE(struct range_lock, rl_rb, u64, __subtree_last,
 		     START, LAST, static, range);
 /**
  * Initialize a range lock tree
@@ -69,7 +69,7 @@ void range_lock_tree_init(struct range_lock_tree *tree)
  * Pre:  Caller should have allocated the range lock node.
  * Post: The range lock node is meant to cover [start, end] region
  */
-int range_lock_init(struct range_lock *lock, __u64 start, __u64 end)
+int range_lock_init(struct range_lock *lock, u64 start, u64 end)
 {
 	RB_CLEAR_NODE(&lock->rl_rb);
 
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.h b/drivers/staging/lustre/lustre/llite/range_lock.h
index 2a0704d..10566da 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.h
+++ b/drivers/staging/lustre/lustre/llite/range_lock.h
@@ -42,8 +42,8 @@
 
 struct range_lock {
 	struct rb_node		rl_rb;
-	__u64			rl_start, rl_last;
-	__u64			__subtree_last;
+	u64			rl_start, rl_last;
+	u64			__subtree_last;
 	/**
 	 * Process to enqueue this lock.
 	 */
@@ -56,17 +56,17 @@ struct range_lock {
 	 * Sequence number of range lock. This number is used to get to know
 	 * the order the locks are queued; this is required for range_cancel().
 	 */
-	__u64			rl_sequence;
+	u64			rl_sequence;
 };
 
 struct range_lock_tree {
 	struct rb_root_cached	rlt_root;
 	spinlock_t		rlt_lock;	/* protect range lock tree */
-	__u64			rlt_sequence;
+	u64			rlt_sequence;
 };
 
 void range_lock_tree_init(struct range_lock_tree *tree);
-int range_lock_init(struct range_lock *lock, __u64 start, __u64 end);
+int range_lock_init(struct range_lock *lock, u64 start, u64 end);
 int  range_lock(struct range_lock_tree *tree, struct range_lock *lock);
 void range_unlock(struct range_lock_tree *tree, struct range_lock *lock);
 #endif
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 55d8b31..e207d7c 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -272,8 +272,8 @@ static inline int stride_io_mode(struct ll_readahead_state *ras)
 stride_pg_count(pgoff_t st_off, unsigned long st_len, unsigned long st_pgs,
 		unsigned long off, unsigned long length)
 {
-	__u64 start = off > st_off ? off - st_off : 0;
-	__u64 end = off + length > st_off ? off + length - st_off : 0;
+	u64 start = off > st_off ? off - st_off : 0;
+	u64 end = off + length > st_off ? off + length - st_off : 0;
 	unsigned long start_left = 0;
 	unsigned long end_left = 0;
 	unsigned long pg_count;
@@ -308,7 +308,7 @@ static inline int stride_io_mode(struct ll_readahead_state *ras)
 
 static int ria_page_count(struct ra_io_arg *ria)
 {
-	__u64 length = ria->ria_end >= ria->ria_start ?
+	u64 length = ria->ria_end >= ria->ria_start ?
 		       ria->ria_end - ria->ria_start + 1 : 0;
 
 	return stride_pg_count(ria->ria_stoff, ria->ria_length,
@@ -445,7 +445,7 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	struct ra_io_arg *ria = &lti->lti_ria;
 	struct cl_object *clob;
 	int ret = 0;
-	__u64 kms;
+	u64 kms;
 
 	clob = io->ci_obj;
 	inode = vvp_object_inode(clob);
@@ -764,7 +764,7 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	 * ras_requests and thus can never trigger this behavior.
 	 */
 	if (ras->ras_requests >= 2 && !ras->ras_request_index) {
-		__u64 kms_pages;
+		u64 kms_pages;
 
 		kms_pages = (i_size_read(inode) + PAGE_SIZE - 1) >>
 			    PAGE_SHIFT;
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 24c2335c..6f5c7ab 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -65,9 +65,9 @@ struct sa_entry {
 	/* link into sai hash table locally */
 	struct list_head	      se_hash;
 	/* entry index in the sai */
-	__u64		   se_index;
+	u64		   se_index;
 	/* low layer ldlm lock handle */
-	__u64		   se_handle;
+	u64		   se_handle;
 	/* entry status */
 	enum se_stat		se_state;
 	/* entry size, contains name */
@@ -163,15 +163,15 @@ static inline int sa_low_hit(struct ll_statahead_info *sai)
  * if the given index is behind of statahead window more than
  * SA_OMITTED_ENTRY_MAX, then it is old.
  */
-static inline int is_omitted_entry(struct ll_statahead_info *sai, __u64 index)
+static inline int is_omitted_entry(struct ll_statahead_info *sai, u64 index)
 {
-	return ((__u64)sai->sai_max + index + SA_OMITTED_ENTRY_MAX <
+	return ((u64)sai->sai_max + index + SA_OMITTED_ENTRY_MAX <
 		 sai->sai_index);
 }
 
 /* allocate sa_entry and hash it to allow scanner process to find it */
 static struct sa_entry *
-sa_alloc(struct dentry *parent, struct ll_statahead_info *sai, __u64 index,
+sa_alloc(struct dentry *parent, struct ll_statahead_info *sai, u64 index,
 	 const char *name, int len, const struct lu_fid *fid)
 {
 	struct ll_inode_info *lli;
@@ -309,7 +309,7 @@ static void sa_free(struct ll_statahead_info *sai, struct sa_entry *entry)
 __sa_make_ready(struct ll_statahead_info *sai, struct sa_entry *entry, int ret)
 {
 	struct list_head *pos = &sai->sai_entries;
-	__u64 index = entry->se_index;
+	u64 index = entry->se_index;
 	struct sa_entry *se;
 
 	LASSERT(!sa_ready(entry));
@@ -492,7 +492,7 @@ static void ll_sai_put(struct ll_statahead_info *sai)
 static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 {
 	struct ll_inode_info *lli   = ll_i2info(inode);
-	__u64		 index = lli->lli_agl_index;
+	u64		 index = lli->lli_agl_index;
 	int		   rc;
 
 	LASSERT(list_empty(&lli->lli_agl_list));
@@ -665,7 +665,7 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 	struct ll_inode_info     *lli = ll_i2info(dir);
 	struct ll_statahead_info *sai = lli->lli_sai;
 	struct sa_entry *entry = (struct sa_entry *)minfo->mi_cbdata;
-	__u64 handle = 0;
+	u64 handle = 0;
 
 	if (it_disposition(it, DISP_LOOKUP_NEG))
 		rc = -ENOENT;
@@ -963,7 +963,7 @@ static int ll_statahead_thread(void *arg)
 	struct ll_sb_info	*sbi    = ll_i2sbi(dir);
 	struct ll_statahead_info *sai = lli->lli_sai;
 	struct page	      *page = NULL;
-	__u64		     pos    = 0;
+	u64		     pos    = 0;
 	int		       first  = 0;
 	int		       rc     = 0;
 	struct md_op_data *op_data;
@@ -998,7 +998,7 @@ static int ll_statahead_thread(void *arg)
 		     ent && sai->sai_task && !sa_low_hit(sai);
 		     ent = lu_dirent_next(ent)) {
 			struct lu_fid fid;
-			__u64 hash;
+			u64 hash;
 			int namelen;
 			char *name;
 
@@ -1228,7 +1228,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 	const struct qstr  *target = &dentry->d_name;
 	struct md_op_data *op_data;
 	struct page	  *page;
-	__u64		 pos    = 0;
+	u64		 pos    = 0;
 	int		   dot_de;
 	int rc = LS_NOT_FIRST_DE;
 
@@ -1259,7 +1259,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 		dp = page_address(page);
 		for (ent = lu_dirent_start(dp); ent;
 		     ent = lu_dirent_next(ent)) {
-			__u64 hash;
+			u64 hash;
 			int namelen;
 			char *name;
 
@@ -1425,7 +1425,7 @@ static int revalidate_statahead_dentry(struct inode *dir,
 		struct inode *inode = entry->se_inode;
 		struct lookup_intent it = { .it_op = IT_GETATTR,
 					    .it_lock_handle = entry->se_handle };
-		__u64 bits;
+		u64 bits;
 
 		rc = md_revalidate_lock(ll_i2mdexp(dir), &it,
 					ll_inode2fid(inode), &bits);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 70d62bf..e8712d8 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -100,7 +100,7 @@ struct vvp_io {
 	/**
 	 * Layout version when this IO is initialized
 	 */
-	__u32			vui_layout_gen;
+	u32			vui_layout_gen;
 	/**
 	 * File descriptor against which IO is done.
 	 */
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index d9f02ae..26a7897 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -188,7 +188,7 @@ static int vvp_prep_size(const struct lu_env *env, struct cl_object *obj,
 			i_size_write(inode, kms);
 			CDEBUG(D_VFSTRACE, DFID " updating i_size %llu\n",
 			       PFID(lu_object_fid(&obj->co_lu)),
-			       (__u64)i_size_read(inode));
+			       (u64)i_size_read(inode));
 		}
 	}
 
@@ -204,7 +204,7 @@ static int vvp_prep_size(const struct lu_env *env, struct cl_object *obj,
  */
 
 static int vvp_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
-				 __u32 enqflags, enum cl_lock_mode mode,
+				 u32 enqflags, enum cl_lock_mode mode,
 			  pgoff_t start, pgoff_t end)
 {
 	struct vvp_io          *vio   = vvp_env_io(env);
@@ -234,7 +234,7 @@ static int vvp_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
 }
 
 static int vvp_io_one_lock(const struct lu_env *env, struct cl_io *io,
-			   __u32 enqflags, enum cl_lock_mode mode,
+			   u32 enqflags, enum cl_lock_mode mode,
 			   loff_t start, loff_t end)
 {
 	struct cl_object *obj = io->ci_obj;
@@ -355,7 +355,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 	}
 
 	if (!io->ci_ignore_layout && io->ci_verify_layout) {
-		__u32 gen = 0;
+		u32 gen = 0;
 
 		/* check layout version */
 		ll_layout_refresh(inode, &gen);
@@ -590,8 +590,8 @@ static int vvp_io_setattr_lock(const struct lu_env *env,
 			       const struct cl_io_slice *ios)
 {
 	struct cl_io  *io  = ios->cis_io;
-	__u64 new_size;
-	__u32 enqflags = 0;
+	u64 new_size;
+	u32 enqflags = 0;
 
 	if (cl_io_is_trunc(io)) {
 		new_size = io->u.ci_setattr.sa_attr.lvb_size;
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index 5da69ba0..bb235e0 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -338,7 +338,7 @@ static int ll_xattr_cache_refill(struct inode *inode)
 	const char *xdata, *xval, *xtail, *xvtail;
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct mdt_body *body;
-	__u32 *xsizes;
+	u32 *xsizes;
 	int rc, i;
 
 	rc = ll_xattr_find_get_lock(inode, &oit, &req);
@@ -373,7 +373,7 @@ static int ll_xattr_cache_refill(struct inode *inode)
 	xval = req_capsule_server_sized_get(&req->rq_pill, &RMF_EAVALS,
 					    body->mbo_aclsize);
 	xsizes = req_capsule_server_sized_get(&req->rq_pill, &RMF_EAVALS_LENS,
-					      body->mbo_max_mdsize * sizeof(__u32));
+					      body->mbo_max_mdsize * sizeof(u32));
 	if (!xdata || !xval || !xsizes) {
 		CERROR("wrong setxattr reply\n");
 		rc = -EPROTO;
@@ -458,7 +458,7 @@ static int ll_xattr_cache_refill(struct inode *inode)
  * \retval -ENODATA no such attr or the list is empty
  */
 int ll_xattr_cache_get(struct inode *inode, const char *name, char *buffer,
-		       size_t size, __u64 valid)
+		       size_t size, u64 valid)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	int rc = 0;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index ba6410e..bc364b6 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -52,7 +52,7 @@ static int lmv_intent_remote(struct obd_export *exp, struct lookup_intent *it,
 			     const struct lu_fid *parent_fid,
 			     struct ptlrpc_request **reqp,
 			     ldlm_blocking_callback cb_blocking,
-			     __u64 extra_lock_flags)
+			     u64 extra_lock_flags)
 {
 	struct obd_device	*obd = exp->exp_obd;
 	struct lmv_obd		*lmv = &obd->u.lmv;
@@ -262,7 +262,7 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 			   struct lookup_intent *it,
 			   struct ptlrpc_request **reqp,
 			   ldlm_blocking_callback cb_blocking,
-			   __u64 extra_lock_flags)
+			   u64 extra_lock_flags)
 {
 	struct obd_device	*obd = exp->exp_obd;
 	struct lmv_obd		*lmv = &obd->u.lmv;
@@ -353,7 +353,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 			     struct lookup_intent *it,
 			     struct ptlrpc_request **reqp,
 			     ldlm_blocking_callback cb_blocking,
-			     __u64 extra_lock_flags)
+			     u64 extra_lock_flags)
 {
 	struct lmv_stripe_md *lsm = op_data->op_mea1;
 	struct obd_device      *obd = exp->exp_obd;
@@ -475,7 +475,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 		    struct lookup_intent *it, struct ptlrpc_request **reqp,
 		    ldlm_blocking_callback cb_blocking,
-		    __u64 extra_lock_flags)
+		    u64 extra_lock_flags)
 {
 	int		rc;
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index f2c41c7..c0881ff 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -46,7 +46,7 @@
 int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 		    struct lookup_intent *it, struct ptlrpc_request **reqp,
 		    ldlm_blocking_callback cb_blocking,
-		    __u64 extra_lock_flags);
+		    u64 extra_lock_flags);
 
 int lmv_fld_lookup(struct lmv_obd *lmv, const struct lu_fid *fid, u32 *mds);
 int __lmv_fid_alloc(struct lmv_obd *lmv, struct lu_fid *fid, u32 mds);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 7e4ffeb..65ae944 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -369,7 +369,7 @@ static void lmv_del_target(struct lmv_obd *lmv, int index)
 }
 
 static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
-			  __u32 index, int gen)
+			  u32 index, int gen)
 {
 	struct lmv_obd      *lmv = &obd->u.lmv;
 	struct obd_device *mdc_obd;
@@ -401,8 +401,8 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 	if (index >= lmv->tgts_size) {
 		/* We need to reallocate the lmv target array. */
 		struct lmv_tgt_desc **newtgts, **old = NULL;
-		__u32 newsize = 1;
-		__u32 oldsize = 0;
+		u32 newsize = 1;
+		u32 oldsize = 0;
 
 		while (newsize < index + 1)
 			newsize <<= 1;
@@ -757,7 +757,7 @@ static int lmv_hsm_ct_unregister(struct lmv_obd *lmv, unsigned int cmd, int len,
 				 struct lustre_kernelcomm *lk,
 				 void __user *uarg)
 {
-	__u32 i;
+	u32 i;
 
 	/* unregister request (call from llapi_hsm_copytool_fini) */
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
@@ -783,7 +783,7 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 			       struct lustre_kernelcomm *lk, void __user *uarg)
 {
 	struct file *filp;
-	__u32 i, j;
+	u32 i, j;
 	int err;
 	bool any_set = false;
 	struct kkuc_ct_data kcd = {
@@ -873,9 +873,9 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		struct obd_ioctl_data *data = karg;
 		struct obd_device *mdc_obd;
 		struct obd_statfs stat_buf = {0};
-		__u32 index;
+		u32 index;
 
-		memcpy(&index, data->ioc_inlbuf2, sizeof(__u32));
+		memcpy(&index, data->ioc_inlbuf2, sizeof(u32));
 		if (index >= count)
 			return -ENODEV;
 
@@ -971,7 +971,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		 * Note: this is from llite(see ll_dir_ioctl()), @uarg does not
 		 * point to user space memory for FID2MDTIDX.
 		 */
-		*(__u32 *)uarg = mdt_index;
+		*(u32 *)uarg = mdt_index;
 		break;
 	}
 	case OBD_IOC_FID2PATH: {
@@ -1292,7 +1292,7 @@ static int lmv_process_config(struct obd_device *obd, u32 len, void *buf)
 	struct lustre_cfg	*lcfg = buf;
 	struct obd_uuid		obd_uuid;
 	int			gen;
-	__u32			index;
+	u32			index;
 	int			rc;
 
 	switch (lcfg->lcfg_command) {
@@ -1327,7 +1327,7 @@ static int lmv_process_config(struct obd_device *obd, u32 len, void *buf)
 }
 
 static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
-		      struct obd_statfs *osfs, __u64 max_age, __u32 flags)
+		      struct obd_statfs *osfs, u64 max_age, u32 flags)
 {
 	struct obd_device     *obd = class_exp2obd(exp);
 	struct lmv_obd	*lmv = &obd->u.lmv;
@@ -1585,7 +1585,7 @@ struct lmv_tgt_desc*
 static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		      const void *data, size_t datalen, umode_t mode,
 		      uid_t uid, gid_t gid, kernel_cap_t cap_effective,
-		      __u64 rdev, struct ptlrpc_request **request)
+		      u64 rdev, struct ptlrpc_request **request)
 {
 	struct obd_device       *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
@@ -1639,7 +1639,7 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 static int
 lmv_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	    const union ldlm_policy_data *policy, struct md_op_data *op_data,
-	    struct lustre_handle *lockh, __u64 extra_lock_flags)
+	    struct lustre_handle *lockh, u64 extra_lock_flags)
 {
 	struct obd_device	*obd = exp->exp_obd;
 	struct lmv_obd	   *lmv = &obd->u.lmv;
@@ -2029,7 +2029,7 @@ static int lmv_fsync(struct obd_export *exp, const struct lu_fid *fid,
 static int lmv_get_min_striped_entry(struct obd_export *exp,
 				     struct md_op_data *op_data,
 				     struct md_callback *cb_op,
-				     __u64 hash_offset, int *stripe_offset,
+				     u64 hash_offset, int *stripe_offset,
 				     struct lu_dirent **entp,
 				     struct page **ppage)
 {
@@ -2046,7 +2046,7 @@ static int lmv_get_min_striped_entry(struct obd_export *exp,
 
 	stripe_count = lsm->lsm_md_stripe_count;
 	for (i = 0; i < stripe_count; i++) {
-		__u64 stripe_hash = hash_offset;
+		u64 stripe_hash = hash_offset;
 		struct lu_dirent *ent = NULL;
 		struct page *page = NULL;
 		struct lu_dirpage *dp;
@@ -2167,12 +2167,12 @@ static int lmv_get_min_striped_entry(struct obd_export *exp,
 static int lmv_read_striped_page(struct obd_export *exp,
 				 struct md_op_data *op_data,
 				 struct md_callback *cb_op,
-				 __u64 offset, struct page **ppage)
+				 u64 offset, struct page **ppage)
 {
 	struct inode *master_inode = op_data->op_data;
 	struct lu_fid master_fid = op_data->op_fid1;
-	__u64 hash_offset = offset;
-	__u32 ldp_flags;
+	u64 hash_offset = offset;
+	u32 ldp_flags;
 	struct page *min_ent_page = NULL;
 	struct page *ent_page = NULL;
 	struct lu_dirent *min_ent = NULL;
@@ -2203,7 +2203,7 @@ static int lmv_read_striped_page(struct obd_export *exp,
 	ent = area;
 	last_ent = ent;
 	do {
-		__u16 ent_size;
+		u16 ent_size;
 
 		/* Find the minum entry from all sub-stripes */
 		rc = lmv_get_min_striped_entry(exp, op_data, cb_op, hash_offset,
@@ -2295,7 +2295,7 @@ static int lmv_read_striped_page(struct obd_export *exp,
 }
 
 static int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
-			 struct md_callback *cb_op, __u64 offset,
+			 struct md_callback *cb_op, u64 offset,
 			 struct page **ppage)
 {
 	struct lmv_stripe_md *lsm = op_data->op_mea1;
@@ -2517,7 +2517,7 @@ static int lmv_precleanup(struct obd_device *obd)
  * \retval negative	negated errno on failure
  */
 static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
-			__u32 keylen, void *key, __u32 *vallen, void *val)
+			u32 keylen, void *key, u32 *vallen, void *val)
 {
 	struct obd_device       *obd;
 	struct lmv_obd	  *lmv;
@@ -2534,7 +2534,7 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 	if (keylen >= strlen("remote_flag") && !strcmp(key, "remote_flag")) {
 		int i;
 
-		LASSERT(*vallen == sizeof(__u32));
+		LASSERT(*vallen == sizeof(u32));
 		for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
 			struct lmv_tgt_desc *tgt = lmv->tgts[i];
 
@@ -2780,7 +2780,7 @@ static int lmv_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 
 static int lmv_set_lock_data(struct obd_export *exp,
 			     const struct lustre_handle *lockh,
-			     void *data, __u64 *bits)
+			     void *data, u64 *bits)
 {
 	struct lmv_obd	  *lmv = &exp->exp_obd->u.lmv;
 	struct lmv_tgt_desc *tgt = lmv->tgts[0];
@@ -2791,7 +2791,7 @@ static int lmv_set_lock_data(struct obd_export *exp,
 	return md_set_lock_data(tgt->ltd_exp, lockh, data, bits);
 }
 
-static enum ldlm_mode lmv_lock_match(struct obd_export *exp, __u64 flags,
+static enum ldlm_mode lmv_lock_match(struct obd_export *exp, u64 flags,
 				     const struct lu_fid *fid,
 				     enum ldlm_type type,
 				     union ldlm_policy_data *policy,
@@ -2925,7 +2925,7 @@ static int lmv_intent_getattr_async(struct obd_export *exp,
 }
 
 static int lmv_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
-			       struct lu_fid *fid, __u64 *bits)
+			       struct lu_fid *fid, u64 *bits)
 {
 	struct obd_device       *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
@@ -2967,7 +2967,7 @@ static int lmv_quotactl(struct obd_device *unused, struct obd_export *exp,
 	struct lmv_obd      *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt = lmv->tgts[0];
 	int rc = 0;
-	__u64 curspace = 0, curinodes = 0;
+	u64 curspace = 0, curinodes = 0;
 	u32 i;
 
 	if (!tgt || !tgt->ltd_exp || !tgt->ltd_active ||
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 5d4c83b..d83b8de 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -98,9 +98,9 @@ struct lov_device {
 	struct cl_device	  ld_cl;
 	struct lov_obd	   *ld_lov;
 	/** size of lov_device::ld_target[] array */
-	__u32		     ld_target_nr;
+	u32		     ld_target_nr;
 	struct lovsub_device    **ld_target;
-	__u32		     ld_flags;
+	u32		     ld_flags;
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/lov/lov_dev.c b/drivers/staging/lustre/lustre/lov/lov_dev.c
index abf2ede..67d30fb 100644
--- a/drivers/staging/lustre/lustre/lov/lov_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lov_dev.c
@@ -218,7 +218,7 @@ static struct lu_device *lov_device_free(const struct lu_env *env,
 }
 
 static void lov_cl_del_target(const struct lu_env *env, struct lu_device *dev,
-			      __u32 index)
+			      u32 index)
 {
 	struct lov_device *ld = lu2lov_dev(dev);
 
@@ -231,8 +231,8 @@ static void lov_cl_del_target(const struct lu_env *env, struct lu_device *dev,
 static int lov_expand_targets(const struct lu_env *env, struct lov_device *dev)
 {
 	int   result;
-	__u32 tgt_size;
-	__u32 sub_size;
+	u32 tgt_size;
+	u32 sub_size;
 
 	result = 0;
 	tgt_size = dev->ld_lov->lov_tgt_size;
@@ -257,7 +257,7 @@ static int lov_expand_targets(const struct lu_env *env, struct lov_device *dev)
 }
 
 static int lov_cl_add_target(const struct lu_env *env, struct lu_device *dev,
-			     __u32 index)
+			     u32 index)
 {
 	struct obd_device    *obd = dev->ld_obd;
 	struct lov_device    *ld  = lu2lov_dev(dev);
@@ -304,7 +304,7 @@ static int lov_process_config(const struct lu_env *env,
 	int cmd;
 	int rc;
 	int gen;
-	__u32 index;
+	u32 index;
 
 	lov_tgts_getref(obd);
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 2b31c99..9708f1b 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -241,7 +241,7 @@ struct lov_request_set {
 
 /* lov_merge.c */
 int lov_merge_lvb_kms(struct lov_stripe_md *lsm, int index,
-		      struct ost_lvb *lvb, __u64 *kms_place);
+		      struct ost_lvb *lvb, u64 *kms_place);
 
 /* lov_offset.c */
 u64 lov_stripe_size(struct lov_stripe_md *lsm, int index, u64 ost_size,
@@ -267,17 +267,17 @@ int lov_prep_statfs_set(struct obd_device *obd, struct obd_info *oinfo,
 void lov_stripe_lock(struct lov_stripe_md *md);
 void lov_stripe_unlock(struct lov_stripe_md *md);
 void lov_fix_desc(struct lov_desc *desc);
-void lov_fix_desc_stripe_size(__u64 *val);
-void lov_fix_desc_stripe_count(__u32 *val);
-void lov_fix_desc_pattern(__u32 *val);
-void lov_fix_desc_qos_maxage(__u32 *val);
+void lov_fix_desc_stripe_size(u64 *val);
+void lov_fix_desc_stripe_count(u32 *val);
+void lov_fix_desc_pattern(u32 *val);
+void lov_fix_desc_qos_maxage(u32 *val);
 u16 lov_get_stripe_count(struct lov_obd *lov, u32 magic, u16 stripe_count);
-int lov_connect_obd(struct obd_device *obd, __u32 index, int activate,
+int lov_connect_obd(struct obd_device *obd, u32 index, int activate,
 		    struct obd_connect_data *data);
 int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg);
 int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
-			    __u32 *indexp, int *genp);
-int lov_del_target(struct obd_device *obd, __u32 index,
+			    u32 *indexp, int *genp);
+int lov_del_target(struct obd_device *obd, u32 index,
 		   struct obd_uuid *uuidp, int gen);
 
 /* lov_pack.c */
@@ -303,8 +303,8 @@ struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, void *buf,
 /* ost_pool methods */
 int lov_ost_pool_init(struct ost_pool *op, unsigned int count);
 int lov_ost_pool_extend(struct ost_pool *op, unsigned int min_count);
-int lov_ost_pool_add(struct ost_pool *op, __u32 idx, unsigned int min_count);
-int lov_ost_pool_remove(struct ost_pool *op, __u32 idx);
+int lov_ost_pool_add(struct ost_pool *op, u32 idx, unsigned int min_count);
+int lov_ost_pool_remove(struct ost_pool *op, u32 idx);
 int lov_ost_pool_free(struct ost_pool *op);
 
 /* high level pool methods */
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index 79edc26..ab0ba12 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -42,12 +42,12 @@
  * uptodate time on the local client.
  */
 int lov_merge_lvb_kms(struct lov_stripe_md *lsm, int index,
-		      struct ost_lvb *lvb, __u64 *kms_place)
+		      struct ost_lvb *lvb, u64 *kms_place)
 {
 	struct lov_stripe_md_entry *lse = lsm->lsm_entries[index];
-	__u64 size = 0;
-	__u64 kms = 0;
-	__u64 blocks = 0;
+	u64 size = 0;
+	u64 kms = 0;
+	u64 blocks = 0;
 	s64 current_mtime = lvb->lvb_mtime;
 	s64 current_atime = lvb->lvb_atime;
 	s64 current_ctime = lvb->lvb_ctime;
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 6959b91..109dd69 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -123,7 +123,7 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 static int lov_notify(struct obd_device *obd, struct obd_device *watched,
 		      enum obd_notify_event ev);
 
-int lov_connect_obd(struct obd_device *obd, __u32 index, int activate,
+int lov_connect_obd(struct obd_device *obd, u32 index, int activate,
 		    struct obd_connect_data *data)
 {
 	struct lov_obd *lov = &obd->u.lov;
@@ -477,7 +477,7 @@ static int lov_notify(struct obd_device *obd, struct obd_device *watched,
 }
 
 static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
-			  __u32 index, int gen, int active)
+			  u32 index, int gen, int active)
 {
 	struct lov_obd *lov = &obd->u.lov;
 	struct lov_tgt_desc *tgt;
@@ -511,9 +511,9 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 	if (index >= lov->lov_tgt_size) {
 		/* We need to reallocate the lov target array. */
 		struct lov_tgt_desc **newtgts, **old = NULL;
-		__u32 newsize, oldsize = 0;
+		u32 newsize, oldsize = 0;
 
-		newsize = max_t(__u32, lov->lov_tgt_size, 2);
+		newsize = max_t(u32, lov->lov_tgt_size, 2);
 		while (newsize < index + 1)
 			newsize <<= 1;
 		newtgts = kcalloc(newsize, sizeof(*newtgts), GFP_NOFS);
@@ -609,7 +609,7 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 }
 
 /* Schedule a target for deletion */
-int lov_del_target(struct obd_device *obd, __u32 index,
+int lov_del_target(struct obd_device *obd, u32 index,
 		   struct obd_uuid *uuidp, int gen)
 {
 	struct lov_obd *lov = &obd->u.lov;
@@ -681,7 +681,7 @@ static void __lov_del_obd(struct obd_device *obd, struct lov_tgt_desc *tgt)
 		class_manual_cleanup(osc_obd);
 }
 
-void lov_fix_desc_stripe_size(__u64 *val)
+void lov_fix_desc_stripe_size(u64 *val)
 {
 	if (*val < LOV_MIN_STRIPE_SIZE) {
 		if (*val != 0)
@@ -695,13 +695,13 @@ void lov_fix_desc_stripe_size(__u64 *val)
 	}
 }
 
-void lov_fix_desc_stripe_count(__u32 *val)
+void lov_fix_desc_stripe_count(u32 *val)
 {
 	if (*val == 0)
 		*val = 1;
 }
 
-void lov_fix_desc_pattern(__u32 *val)
+void lov_fix_desc_pattern(u32 *val)
 {
 	/* from lov_setstripe */
 	if ((*val != 0) && (*val != LOV_PATTERN_RAID0)) {
@@ -710,7 +710,7 @@ void lov_fix_desc_pattern(__u32 *val)
 	}
 }
 
-void lov_fix_desc_qos_maxage(__u32 *val)
+void lov_fix_desc_qos_maxage(u32 *val)
 {
 	if (*val == 0)
 		*val = LOV_DESC_QOS_MAXAGE_DEFAULT;
@@ -843,7 +843,7 @@ static int lov_cleanup(struct obd_device *obd)
 }
 
 int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
-			    __u32 *indexp, int *genp)
+			    u32 *indexp, int *genp)
 {
 	struct obd_uuid obd_uuid;
 	int cmd;
@@ -853,7 +853,7 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
 	case LCFG_LOV_ADD_OBD:
 	case LCFG_LOV_ADD_INA:
 	case LCFG_LOV_DEL_OBD: {
-		__u32 index;
+		u32 index;
 		int gen;
 		/* lov_modify_tgts add  0:lov_mdsA  1:ost1_UUID  2:0  3:1 */
 		if (LUSTRE_CFG_BUFLEN(lcfg, 1) > sizeof(obd_uuid.uuid)) {
@@ -923,7 +923,7 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
 }
 
 static int lov_statfs_async(struct obd_export *exp, struct obd_info *oinfo,
-			    __u64 max_age, struct ptlrpc_request_set *rqset)
+			    u64 max_age, struct ptlrpc_request_set *rqset)
 {
 	struct obd_device      *obd = class_exp2obd(exp);
 	struct lov_request_set *set;
@@ -961,7 +961,7 @@ static int lov_statfs_async(struct obd_export *exp, struct obd_info *oinfo,
 }
 
 static int lov_statfs(const struct lu_env *env, struct obd_export *exp,
-		      struct obd_statfs *osfs, __u64 max_age, __u32 flags)
+		      struct obd_statfs *osfs, u64 max_age, u32 flags)
 {
 	struct ptlrpc_request_set *set = NULL;
 	struct obd_info oinfo = {
@@ -998,10 +998,10 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		struct obd_ioctl_data *data = karg;
 		struct obd_device *osc_obd;
 		struct obd_statfs stat_buf = {0};
-		__u32 index;
-		__u32 flags;
+		u32 index;
+		u32 flags;
 
-		memcpy(&index, data->ioc_inlbuf2, sizeof(__u32));
+		memcpy(&index, data->ioc_inlbuf2, sizeof(u32));
 		if (index >= count)
 			return -ENODEV;
 
@@ -1021,7 +1021,7 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 				       sizeof(struct obd_uuid))))
 			return -EFAULT;
 
-		memcpy(&flags, data->ioc_inlbuf1, sizeof(__u32));
+		memcpy(&flags, data->ioc_inlbuf1, sizeof(u32));
 		flags = flags & LL_STATFS_NODELAY ? OBD_STATFS_NODELAY : 0;
 
 		/* got statfs data */
@@ -1040,7 +1040,7 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		struct obd_ioctl_data *data;
 		struct lov_desc *desc;
 		char *buf = NULL;
-		__u32 *genp;
+		u32 *genp;
 
 		len = 0;
 		if (obd_ioctl_getdata(&buf, &len, uarg))
@@ -1058,7 +1058,7 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 			return -EINVAL;
 		}
 
-		if (sizeof(__u32) * count > data->ioc_inllen3) {
+		if (sizeof(u32) * count > data->ioc_inllen3) {
 			kvfree(buf);
 			return -EINVAL;
 		}
@@ -1067,7 +1067,7 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		memcpy(desc, &lov->desc, sizeof(*desc));
 
 		uuidp = (struct obd_uuid *)data->ioc_inlbuf2;
-		genp = (__u32 *)data->ioc_inlbuf3;
+		genp = (u32 *)data->ioc_inlbuf3;
 		/* the uuid will be empty for deleted OSTs */
 		for (i = 0; i < count; i++, uuidp++, genp++) {
 			if (!lov->lov_tgts[i])
@@ -1172,7 +1172,7 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 }
 
 static int lov_get_info(const struct lu_env *env, struct obd_export *exp,
-			__u32 keylen, void *key, __u32 *vallen, void *val)
+			u32 keylen, void *key, u32 *vallen, void *val)
 {
 	struct obd_device *obddev = class_exp2obd(exp);
 	struct lov_obd *lov = &obddev->u.lov;
@@ -1283,8 +1283,8 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 {
 	struct lov_obd      *lov = &obd->u.lov;
 	struct lov_tgt_desc *tgt;
-	__u64		curspace = 0;
-	__u64		bhardlimit = 0;
+	u64		curspace = 0;
+	u64		bhardlimit = 0;
 	int		  i, rc = 0;
 
 	if (oqctl->qc_cmd != Q_GETOQUOTA &&
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 0a6bb1e..fde5160 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -252,7 +252,7 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 /* Find the max stripecount we should use */
 u16 lov_get_stripe_count(struct lov_obd *lov, u32 magic, u16 stripe_count)
 {
-	__u32 max_stripes = LOV_MAX_STRIPE_COUNT_OLD;
+	u32 max_stripes = LOV_MAX_STRIPE_COUNT_OLD;
 
 	if (!stripe_count)
 		stripe_count = lov->desc.ld_default_stripe_count;
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index b90fb1c..177f5a5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -273,7 +273,7 @@ int lov_ost_pool_extend(struct ost_pool *op, unsigned int min_count)
 	return 0;
 }
 
-int lov_ost_pool_add(struct ost_pool *op, __u32 idx, unsigned int min_count)
+int lov_ost_pool_add(struct ost_pool *op, u32 idx, unsigned int min_count)
 {
 	int rc = 0, i;
 
@@ -298,7 +298,7 @@ int lov_ost_pool_add(struct ost_pool *op, __u32 idx, unsigned int min_count)
 	return rc;
 }
 
-int lov_ost_pool_remove(struct ost_pool *op, __u32 idx)
+int lov_ost_pool_remove(struct ost_pool *op, u32 idx)
 {
 	int i;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index d13e8d1..45dca36 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -136,7 +136,7 @@ static int lov_check_and_wait_active(struct lov_obd *lov, int ost_idx)
 	return rc;
 }
 
-#define LOV_U64_MAX ((__u64)~0ULL)
+#define LOV_U64_MAX ((u64)~0ULL)
 #define LOV_SUM_MAX(tot, add)					   \
 	do {							    \
 		if ((tot) + (add) < (tot))			      \
@@ -188,7 +188,7 @@ static void lov_update_statfs(struct obd_statfs *osfs,
 			      int success)
 {
 	int shift = 0, quit = 0;
-	__u64 tmp;
+	u64 tmp;
 
 	if (success == 0) {
 		memcpy(osfs, lov_sfs, sizeof(*lov_sfs));
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index 6da9046..2b849e8 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -39,20 +39,20 @@
 int mdc_tunables_init(struct obd_device *obd);
 
 void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
-		   __u64 valid, size_t ea_size, __u32 suppgid, u32 flags);
+		   u64 valid, size_t ea_size, u32 suppgid, u32 flags);
 void mdc_swap_layouts_pack(struct ptlrpc_request *req,
 			   struct md_op_data *op_data);
-void mdc_readdir_pack(struct ptlrpc_request *req, __u64 pgoff, size_t size,
+void mdc_readdir_pack(struct ptlrpc_request *req, u64 pgoff, size_t size,
 		      const struct lu_fid *fid);
-void mdc_getattr_pack(struct ptlrpc_request *req, __u64 valid, u32 flags,
+void mdc_getattr_pack(struct ptlrpc_request *req, u64 valid, u32 flags,
 		      struct md_op_data *data, size_t ea_size);
 void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		      void *ea, size_t ealen);
 void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		     const void *data, size_t datalen, umode_t mode, uid_t uid,
-		     gid_t gid, kernel_cap_t capability, __u64 rdev);
+		     gid_t gid, kernel_cap_t capability, u64 rdev);
 void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
-		   umode_t mode, __u64 rdev, __u64 flags, const void *data,
+		   umode_t mode, u64 rdev, u64 flags, const void *data,
 		   size_t datalen);
 void mdc_file_secctx_pack(struct ptlrpc_request *req,
 			  const char *secctx_name,
@@ -68,7 +68,7 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 /* mdc/mdc_locks.c */
 int mdc_set_lock_data(struct obd_export *exp,
 		      const struct lustre_handle *lockh,
-		      void *data, __u64 *bits);
+		      void *data, u64 *bits);
 
 int mdc_null_inode(struct obd_export *exp, const struct lu_fid *fid);
 
@@ -77,7 +77,7 @@ int mdc_intent_lock(struct obd_export *exp,
 		    struct lookup_intent *it,
 		    struct ptlrpc_request **reqp,
 		    ldlm_blocking_callback cb_blocking,
-		    __u64 extra_lock_flags);
+		    u64 extra_lock_flags);
 
 int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		const union ldlm_policy_data *policy,
@@ -86,7 +86,7 @@ int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 
 int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 			    struct list_head *cancels, enum ldlm_mode  mode,
-			    __u64 bits);
+			    u64 bits);
 /* mdc/mdc_request.c */
 int mdc_fid_alloc(const struct lu_env *env, struct obd_export *exp,
 		  struct lu_fid *fid, struct md_op_data *op_data);
@@ -101,7 +101,7 @@ int mdc_set_open_replay_data(struct obd_export *exp,
 
 int mdc_create(struct obd_export *exp, struct md_op_data *op_data,
 	       const void *data, size_t datalen, umode_t mode, uid_t uid,
-	       gid_t gid, kernel_cap_t capability, __u64 rdev,
+	       gid_t gid, kernel_cap_t capability, u64 rdev,
 	       struct ptlrpc_request **request);
 int mdc_link(struct obd_export *exp, struct md_op_data *op_data,
 	     struct ptlrpc_request **request);
@@ -118,12 +118,12 @@ int mdc_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 		      enum ldlm_cancel_flags flags, void *opaque);
 
 int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
-			struct lu_fid *fid, __u64 *bits);
+			struct lu_fid *fid, u64 *bits);
 
 int mdc_intent_getattr_async(struct obd_export *exp,
 			     struct md_enqueue_info *minfo);
 
-enum ldlm_mode mdc_lock_match(struct obd_export *exp, __u64 flags,
+enum ldlm_mode mdc_lock_match(struct obd_export *exp, u64 flags,
 			      const struct lu_fid *fid, enum ldlm_type type,
 			      union ldlm_policy_data *policy,
 			      enum ldlm_mode mode,
@@ -141,7 +141,7 @@ static inline int mdc_prep_elc_req(struct obd_export *exp,
 				 count);
 }
 
-static inline unsigned long hash_x_index(__u64 hash, int hash64)
+static inline unsigned long hash_x_index(u64 hash, int hash64)
 {
 	if (BITS_PER_LONG == 32 && hash64)
 		hash >>= 32;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index a1b1e75..3dfc863 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -42,7 +42,7 @@ static void set_mrc_cr_flags(struct mdt_rec_create *mrc, u64 flags)
 	mrc->cr_flags_h = (u32)(flags >> 32);
 }
 
-static void __mdc_pack_body(struct mdt_body *b, __u32 suppgid)
+static void __mdc_pack_body(struct mdt_body *b, u32 suppgid)
 {
 	b->mbo_suppgid = suppgid;
 	b->mbo_uid = from_kuid(&init_user_ns, current_uid());
@@ -65,7 +65,7 @@ void mdc_swap_layouts_pack(struct ptlrpc_request *req,
 }
 
 void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
-		   __u64 valid, size_t ea_size, __u32 suppgid, u32 flags)
+		   u64 valid, size_t ea_size, u32 suppgid, u32 flags)
 {
 	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
 						    &RMF_MDT_BODY);
@@ -134,7 +134,7 @@ void mdc_file_secctx_pack(struct ptlrpc_request *req, const char *secctx_name,
 	memcpy(buf, secctx, buf_size);
 }
 
-void mdc_readdir_pack(struct ptlrpc_request *req, __u64 pgoff, size_t size,
+void mdc_readdir_pack(struct ptlrpc_request *req, u64 pgoff, size_t size,
 		      const struct lu_fid *fid)
 {
 	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
@@ -151,11 +151,11 @@ void mdc_readdir_pack(struct ptlrpc_request *req, __u64 pgoff, size_t size,
 void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		     const void *data, size_t datalen, umode_t mode,
 		     uid_t uid, gid_t gid, kernel_cap_t cap_effective,
-		     __u64 rdev)
+		     u64 rdev)
 {
 	struct mdt_rec_create	*rec;
 	char			*tmp;
-	__u64			 flags;
+	u64			 flags;
 
 	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_create));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
@@ -189,9 +189,9 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 			     op_data->op_file_secctx_size);
 }
 
-static inline __u64 mds_pack_open_flags(__u64 flags)
+static inline u64 mds_pack_open_flags(u64 flags)
 {
-	__u64 cr_flags = (flags & (FMODE_READ | FMODE_WRITE |
+	u64 cr_flags = (flags & (FMODE_READ | FMODE_WRITE |
 				   MDS_OPEN_FL_INTERNAL));
 	if (flags & O_CREAT)
 		cr_flags |= MDS_OPEN_CREAT;
@@ -218,12 +218,12 @@ static inline __u64 mds_pack_open_flags(__u64 flags)
 
 /* packing of MDS records */
 void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
-		   umode_t mode, __u64 rdev, __u64 flags, const void *lmm,
+		   umode_t mode, u64 rdev, u64 flags, const void *lmm,
 		   size_t lmmlen)
 {
 	struct mdt_rec_create *rec;
 	char *tmp;
-	__u64 cr_flags;
+	u64 cr_flags;
 
 	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_create));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
@@ -268,7 +268,7 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 
 static inline u64 attr_pack(unsigned int ia_valid, enum op_xvalid ia_xvalid)
 {
-	__u64 sa_valid = 0;
+	u64 sa_valid = 0;
 
 	if (ia_valid & ATTR_MODE)
 		sa_valid |= MDS_ATTR_MODE;
@@ -483,7 +483,7 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	}
 }
 
-void mdc_getattr_pack(struct ptlrpc_request *req, __u64 valid, u32 flags,
+void mdc_getattr_pack(struct ptlrpc_request *req, u64 valid, u32 flags,
 		      struct md_op_data *op_data, size_t ea_size)
 {
 	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index a60959d..e16dce6 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -96,7 +96,7 @@ int it_open_error(int phase, struct lookup_intent *it)
 
 /* this must be called on a lockh that is known to have a referenced lock */
 int mdc_set_lock_data(struct obd_export *exp, const struct lustre_handle *lockh,
-		      void *data, __u64 *bits)
+		      void *data, u64 *bits)
 {
 	struct ldlm_lock *lock;
 	struct inode *new_inode = data;
@@ -131,7 +131,7 @@ int mdc_set_lock_data(struct obd_export *exp, const struct lustre_handle *lockh,
 	return 0;
 }
 
-enum ldlm_mode mdc_lock_match(struct obd_export *exp, __u64 flags,
+enum ldlm_mode mdc_lock_match(struct obd_export *exp, u64 flags,
 			      const struct lu_fid *fid, enum ldlm_type type,
 			      union ldlm_policy_data *policy,
 			      enum ldlm_mode mode,
@@ -319,7 +319,7 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 
 	/* pack the intent */
 	lit = req_capsule_client_get(&req->rq_pill, &RMF_LDLM_INTENT);
-	lit->opc = (__u64)it->it_op;
+	lit->opc = (u64)it->it_op;
 
 	/* pack the intended request */
 	mdc_open_pack(req, op_data, it->it_create_mode, 0, it->it_flags, lmm,
@@ -423,7 +423,7 @@ static struct ptlrpc_request *mdc_intent_unlink_pack(struct obd_export *exp,
 
 	/* pack the intent */
 	lit = req_capsule_client_get(&req->rq_pill, &RMF_LDLM_INTENT);
-	lit->opc = (__u64)it->it_op;
+	lit->opc = (u64)it->it_op;
 
 	/* pack the intended request */
 	mdc_unlink_pack(req, op_data);
@@ -463,7 +463,7 @@ static struct ptlrpc_request *mdc_intent_getattr_pack(struct obd_export *exp,
 
 	/* pack the intent */
 	lit = req_capsule_client_get(&req->rq_pill, &RMF_LDLM_INTENT);
-	lit->opc = (__u64)it->it_op;
+	lit->opc = (u64)it->it_op;
 
 	if (obddev->u.cli.cl_default_mds_easize > 0)
 		easize = obddev->u.cli.cl_default_mds_easize;
@@ -504,7 +504,7 @@ static struct ptlrpc_request *mdc_intent_layout_pack(struct obd_export *exp,
 
 	/* pack the intent */
 	lit = req_capsule_client_get(&req->rq_pill, &RMF_LDLM_INTENT);
-	lit->opc = (__u64)it->it_op;
+	lit->opc = (u64)it->it_op;
 
 	/* pack the layout intent request */
 	layout = req_capsule_client_get(&req->rq_pill, &RMF_LAYOUT_INTENT);
@@ -1031,7 +1031,7 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 }
 
 int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
-			struct lu_fid *fid, __u64 *bits)
+			struct lu_fid *fid, u64 *bits)
 {
 	/* We could just return 1 immediately, but since we should only
 	 * be called in revalidate_it if we already have a lock, let's
@@ -1126,7 +1126,7 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
  */
 int mdc_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 		    struct lookup_intent *it, struct ptlrpc_request **reqp,
-		    ldlm_blocking_callback cb_blocking, __u64 extra_lock_flags)
+		    ldlm_blocking_callback cb_blocking, u64 extra_lock_flags)
 {
 	struct ldlm_enqueue_info einfo = {
 		.ei_type	= LDLM_IBITS,
@@ -1192,7 +1192,7 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 	struct lustre_handle     *lockh;
 	struct obd_device	*obddev;
 	struct ldlm_reply	 *lockrep;
-	__u64		     flags = LDLM_FL_HAS_INTENT;
+	u64		     flags = LDLM_FL_HAS_INTENT;
 
 	it    = &minfo->mi_it;
 	lockh = &minfo->mi_lockh;
@@ -1240,7 +1240,7 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 		.l_inodebits = { MDS_INODELOCK_LOOKUP | MDS_INODELOCK_UPDATE }
 	};
 	int		      rc = 0;
-	__u64		    flags = LDLM_FL_HAS_INTENT;
+	u64		    flags = LDLM_FL_HAS_INTENT;
 
 	CDEBUG(D_DLMTRACE,
 	       "name: %.*s in inode " DFID ", intent: %s flags %#Lo\n",
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index bdffe6d..765c908 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -64,7 +64,7 @@ static int mdc_reint(struct ptlrpc_request *request, int level)
  */
 int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 			    struct list_head *cancels, enum ldlm_mode mode,
-			    __u64 bits)
+			    u64 bits)
 {
 	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
 	union ldlm_policy_data policy = {};
@@ -103,7 +103,7 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 	LIST_HEAD(cancels);
 	struct ptlrpc_request *req;
 	int count = 0, rc;
-	__u64 bits;
+	u64 bits;
 
 	bits = MDS_INODELOCK_UPDATE;
 	if (op_data->op_attr.ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID))
@@ -151,7 +151,7 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 int mdc_create(struct obd_export *exp, struct md_op_data *op_data,
 	       const void *data, size_t datalen, umode_t mode,
 	       uid_t uid, gid_t gid, kernel_cap_t cap_effective,
-	       __u64 rdev, struct ptlrpc_request **request)
+	       u64 rdev, struct ptlrpc_request **request)
 {
 	struct ptlrpc_request *req;
 	int level, rc;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 09b30ef..1aee1c5 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -278,7 +278,7 @@ static int mdc_xattr_common(struct obd_export *exp,
 			    int opcode, u64 valid,
 			    const char *xattr_name, const char *input,
 			    int input_size, int output_size, int flags,
-			    __u32 suppgid, struct ptlrpc_request **request)
+			    u32 suppgid, struct ptlrpc_request **request)
 {
 	struct ptlrpc_request *req;
 	int   xattr_namelen = 0;
@@ -594,7 +594,7 @@ void mdc_replay_open(struct ptlrpc_request *req)
 
 	close_req = mod->mod_close_req;
 	if (close_req) {
-		__u32 opc = lustre_msg_get_opc(close_req->rq_reqmsg);
+		u32 opc = lustre_msg_get_opc(close_req->rq_reqmsg);
 		struct mdt_ioepoch *epoch;
 
 		LASSERT(opc == MDS_CLOSE);
@@ -977,8 +977,8 @@ static void mdc_release_page(struct page *page, int remove)
 	put_page(page);
 }
 
-static struct page *mdc_page_locate(struct address_space *mapping, __u64 *hash,
-				    __u64 *start, __u64 *end, int hash64)
+static struct page *mdc_page_locate(struct address_space *mapping, u64 *hash,
+				    u64 *start, u64 *end, int hash64)
 {
 	/*
 	 * Complement of hash is used as an index so that
@@ -1107,8 +1107,8 @@ static void mdc_adjust_dirpages(struct page **pages, int cfs_pgs, int lu_pgs)
 
 	for (i = 0; i < cfs_pgs; i++) {
 		struct lu_dirpage *dp = kmap(pages[i]);
-		__u64 hash_end = le64_to_cpu(dp->ldp_hash_end);
-		__u32 flags = le32_to_cpu(dp->ldp_flags);
+		u64 hash_end = le64_to_cpu(dp->ldp_hash_end);
+		u32 flags = le32_to_cpu(dp->ldp_flags);
 		struct lu_dirpage *first = dp;
 
 		while (--lu_pgs > 0) {
@@ -1159,7 +1159,7 @@ static void mdc_adjust_dirpages(struct page **pages, int cfs_pgs, int lu_pgs)
 /* parameters for readdir page */
 struct readpage_param {
 	struct md_op_data	*rp_mod;
-	__u64			rp_off;
+	u64			rp_off;
 	int			rp_hash64;
 	struct obd_export	*rp_exp;
 	struct md_callback	*rp_cb;
@@ -1234,7 +1234,7 @@ static int mdc_read_page_remote(void *data, struct page *page0)
 	CDEBUG(D_CACHE, "read %d/%d pages\n", rd_pgs, npages);
 	for (i = 1; i < npages; i++) {
 		unsigned long offset;
-		__u64 hash;
+		u64 hash;
 		int ret;
 
 		page = page_pool[i];
@@ -1285,7 +1285,7 @@ static int mdc_read_page_remote(void *data, struct page *page0)
  *			errno(<0) get the page failed
  */
 static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
-			 struct md_callback *cb_op, __u64 hash_offset,
+			 struct md_callback *cb_op, u64 hash_offset,
 			 struct page **ppage)
 {
 	struct lookup_intent it = { .it_op = IT_READDIR };
@@ -1293,8 +1293,8 @@ static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
 	struct inode *dir = op_data->op_data;
 	struct address_space *mapping;
 	struct lu_dirpage *dp;
-	__u64 start = 0;
-	__u64 end = 0;
+	u64 start = 0;
+	u64 end = 0;
 	struct lustre_handle lockh;
 	struct ptlrpc_request *enq_req = NULL;
 	struct readpage_param rp_param;
@@ -1418,7 +1418,7 @@ static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
 
 static int mdc_statfs(const struct lu_env *env,
 		      struct obd_export *exp, struct obd_statfs *osfs,
-		      __u64 max_age, __u32 flags)
+		      u64 max_age, u32 flags)
 {
 	struct obd_device     *obd = class_exp2obd(exp);
 	struct ptlrpc_request *req;
@@ -1476,7 +1476,7 @@ static int mdc_statfs(const struct lu_env *env,
 
 static int mdc_ioc_fid2path(struct obd_export *exp, struct getinfo_fid2path *gf)
 {
-	__u32 keylen, vallen;
+	u32 keylen, vallen;
 	void *key;
 	int rc;
 
@@ -1567,9 +1567,9 @@ static int mdc_ioc_hsm_progress(struct obd_export *exp,
 	return rc;
 }
 
-static int mdc_ioc_hsm_ct_register(struct obd_import *imp, __u32 archives)
+static int mdc_ioc_hsm_ct_register(struct obd_import *imp, u32 archives)
 {
-	__u32			*archive_mask;
+	u32			*archive_mask;
 	struct ptlrpc_request	*req;
 	int			 rc;
 
@@ -1967,7 +1967,7 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	case IOC_OBD_STATFS: {
 		struct obd_statfs stat_buf = {0};
 
-		if (*((__u32 *)data->ioc_inlbuf2) != 0) {
+		if (*((u32 *)data->ioc_inlbuf2) != 0) {
 			rc = -ENODEV;
 			goto out;
 		}
@@ -2056,7 +2056,7 @@ static int mdc_get_info_rpc(struct obd_export *exp,
 	req_capsule_set_size(&req->rq_pill, &RMF_GETINFO_KEY,
 			     RCL_CLIENT, keylen);
 	req_capsule_set_size(&req->rq_pill, &RMF_GETINFO_VALLEN,
-			     RCL_CLIENT, sizeof(__u32));
+			     RCL_CLIENT, sizeof(u32));
 
 	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_GET_INFO);
 	if (rc) {
@@ -2067,7 +2067,7 @@ static int mdc_get_info_rpc(struct obd_export *exp,
 	tmp = req_capsule_client_get(&req->rq_pill, &RMF_GETINFO_KEY);
 	memcpy(tmp, key, keylen);
 	tmp = req_capsule_client_get(&req->rq_pill, &RMF_GETINFO_VALLEN);
-	memcpy(tmp, &vallen, sizeof(__u32));
+	memcpy(tmp, &vallen, sizeof(u32));
 
 	req_capsule_set_size(&req->rq_pill, &RMF_GETINFO_VAL,
 			     RCL_SERVER, vallen);
@@ -2119,7 +2119,7 @@ static void lustre_swab_hal(struct hsm_action_list *h)
 static void lustre_swab_kuch(struct kuc_hdr *l)
 {
 	__swab16s(&l->kuc_magic);
-	/* __u8 l->kuc_transport */
+	/* u8 l->kuc_transport */
 	__swab16s(&l->kuc_msgtype);
 	__swab16s(&l->kuc_msglen);
 }
@@ -2128,7 +2128,7 @@ static int mdc_ioc_hsm_ct_start(struct obd_export *exp,
 				struct lustre_kernelcomm *lk)
 {
 	struct obd_import  *imp = class_exp2cliimp(exp);
-	__u32		    archive = lk->lk_data;
+	u32		    archive = lk->lk_data;
 	int		    rc = 0;
 
 	if (lk->lk_group != KUC_GRP_HSM) {
@@ -2264,7 +2264,7 @@ static int mdc_set_info_async(const struct lu_env *env,
 }
 
 static int mdc_get_info(const struct lu_env *env, struct obd_export *exp,
-			__u32 keylen, void *key, __u32 *vallen, void *val)
+			u32 keylen, void *key, u32 *vallen, void *val)
 {
 	int rc = -EINVAL;
 
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index ca74c75..dc80081 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -53,7 +53,7 @@
 static int mgc_name2resid(char *name, int len, struct ldlm_res_id *res_id,
 			  int type)
 {
-	__u64 resname = 0;
+	u64 resname = 0;
 
 	if (len > sizeof(resname)) {
 		CERROR("name too long: %s\n", name);
@@ -883,10 +883,10 @@ static int mgc_set_mgs_param(struct obd_export *exp,
 }
 
 /* Take a config lock so we can get cancel notifications */
-static int mgc_enqueue(struct obd_export *exp, __u32 type,
-		       union ldlm_policy_data *policy, __u32 mode,
-		       __u64 *flags, void *bl_cb, void *cp_cb, void *gl_cb,
-		       void *data, __u32 lvb_len, void *lvb_swabber,
+static int mgc_enqueue(struct obd_export *exp, u32 type,
+		       union ldlm_policy_data *policy, u32 mode,
+		       u64 *flags, void *bl_cb, void *cp_cb, void *gl_cb,
+		       void *data, u32 lvb_len, void *lvb_swabber,
 		       struct lustre_handle *lockh)
 {
 	struct config_llog_data *cld = data;
@@ -1055,7 +1055,7 @@ static int mgc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 }
 
 static int mgc_get_info(const struct lu_env *env, struct obd_export *exp,
-			__u32 keylen, void *key, __u32 *vallen, void *val)
+			u32 keylen, void *key, u32 *vallen, void *val)
 {
 	int rc = -EINVAL;
 
@@ -1120,7 +1120,7 @@ enum {
 
 static int mgc_apply_recover_logs(struct obd_device *mgc,
 				  struct config_llog_data *cld,
-				  __u64 max_version,
+				  u64 max_version,
 				  void *data, int datalen, bool mne_swab)
 {
 	struct config_llog_instance *cfg = &cld->cld_cfg;
@@ -1597,7 +1597,7 @@ static bool mgc_import_in_recovery(struct obd_import *imp)
 int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 {
 	struct lustre_handle lockh = { 0 };
-	__u64 flags = LDLM_FL_NO_LRU;
+	u64 flags = LDLM_FL_NO_LRU;
 	bool retry = false;
 	int rc = 0, rcl;
 
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 39b7ab1..4f9dbc4 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -85,7 +85,7 @@ struct echo_lock {
 	struct cl_lock_slice   el_cl;
 	struct list_head	     el_chain;
 	struct echo_object    *el_object;
-	__u64		  el_cookie;
+	u64		  el_cookie;
 	atomic_t	   el_refcount;
 };
 
@@ -912,7 +912,7 @@ static int cl_echo_object_put(struct echo_object *eco)
 
 static int __cl_echo_enqueue(struct lu_env *env, struct echo_object *eco,
 			     u64 start, u64 end, int mode,
-			     __u64 *cookie, __u32 enqflags)
+			     u64 *cookie, u32 enqflags)
 {
 	struct cl_io *io;
 	struct cl_lock *lck;
@@ -954,7 +954,7 @@ static int __cl_echo_enqueue(struct lu_env *env, struct echo_object *eco,
 }
 
 static int __cl_echo_cancel(struct lu_env *env, struct echo_device *ed,
-			    __u64 cookie)
+			    u64 cookie)
 {
 	struct echo_client_obd *ec = ed->ed_ec;
 	struct echo_lock       *ecl = NULL;
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_internal.h b/drivers/staging/lustre/lustre/obdecho/echo_internal.h
index 42faa16..ac7a209 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_internal.h
+++ b/drivers/staging/lustre/lustre/obdecho/echo_internal.h
@@ -34,7 +34,7 @@
 
 /* The persistent object (i.e. actually stores stuff!) */
 #define ECHO_PERSISTENT_OBJID    1ULL
-#define ECHO_PERSISTENT_SIZE     ((__u64)(1 << 20))
+#define ECHO_PERSISTENT_SIZE     ((u64)(1 << 20))
 
 /* block size to use for data verification */
 #define OBD_ECHO_BLOCK_SIZE	(4 << 10)
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 7e80a07..bef422c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -880,7 +880,7 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 	int nr_pages = ext->oe_nr_pages;
 	int lost_grant = 0;
 	int blocksize = cli->cl_import->imp_obd->obd_osfs.os_bsize ? : 4096;
-	__u64 last_off = 0;
+	u64 last_off = 0;
 	int last_count = -1;
 
 	OSC_EXTENT_DUMP(D_CACHE, ext, "extent finished.\n");
@@ -991,7 +991,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 	struct osc_async_page *tmp;
 	int pages_in_chunk = 0;
 	int ppc_bits = cli->cl_chunkbits - PAGE_SHIFT;
-	__u64 trunc_chunk = trunc_index >> ppc_bits;
+	u64 trunc_chunk = trunc_index >> ppc_bits;
 	int grants = 0;
 	int nr_pages = 0;
 	int rc = 0;
@@ -1799,7 +1799,7 @@ static int osc_list_maint(struct client_obd *cli, struct osc_object *osc)
  * sync so that the app can get a sync error and break the cycle of queueing
  * pages for which writeback will fail.
  */
-static void osc_process_ar(struct osc_async_rc *ar, __u64 xid,
+static void osc_process_ar(struct osc_async_rc *ar, u64 xid,
 			   int rc)
 {
 	if (rc) {
@@ -1824,7 +1824,7 @@ static void osc_ap_completion(const struct lu_env *env, struct client_obd *cli,
 {
 	struct osc_object *osc = oap->oap_obj;
 	struct lov_oinfo *loi = osc->oo_oinfo;
-	__u64 xid = 0;
+	u64 xid = 0;
 
 	if (oap->oap_request) {
 		xid = ptlrpc_req_xid(oap->oap_request);
@@ -3127,7 +3127,7 @@ static bool check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 		tmp = osc_dlmlock_at_pgoff(env, osc, index,
 					   OSC_DAP_FL_TEST_LOCK);
 		if (tmp) {
-			__u64 end = tmp->l_policy_data.l_extent.end;
+			u64 end = tmp->l_policy_data.l_extent.end;
 			/* Cache the first-non-overlapped index so as to skip
 			 * all pages within [index, oti_fn_index). This is safe
 			 * because if tmp lock is canceled, it will discard
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index c0f58f4..c89c894 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -255,7 +255,7 @@ struct osc_lock {
 	/* underlying DLM lock */
 	struct ldlm_lock		*ols_dlmlock;
 	/* DLM flags with which osc_lock::ols_lock was enqueued */
-	__u64				ols_flags;
+	u64				ols_flags;
 	/* osc_lock::ols_lock handle */
 	struct lustre_handle		ols_handle;
 	struct ldlm_enqueue_info	ols_einfo;
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index c61ef89..4033365 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -91,7 +91,7 @@ static inline void osc_wake_cache_waiters(struct client_obd *cli)
 	wake_up(&cli->cl_cache_waiters);
 }
 
-int osc_shrink_grant_to_target(struct client_obd *cli, __u64 target_bytes);
+int osc_shrink_grant_to_target(struct client_obd *cli, u64 target_bytes);
 void osc_update_next_shrink(struct client_obd *cli);
 
 /*
@@ -103,7 +103,7 @@ typedef int (*osc_enqueue_upcall_f)(void *cookie, struct lustre_handle *lockh,
 				    int rc);
 
 int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
-		     __u64 *flags, union ldlm_policy_data *policy,
+		     u64 *flags, union ldlm_policy_data *policy,
 		     struct ost_lvb *lvb, int kms_valid,
 		     osc_enqueue_upcall_f upcall,
 		     void *cookie, struct ldlm_enqueue_info *einfo,
@@ -111,7 +111,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 
 int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		   enum ldlm_type type, union ldlm_policy_data *policy,
-		   enum ldlm_mode mode, __u64 *flags, void *data,
+		   enum ldlm_mode mode, u64 *flags, void *data,
 		   struct lustre_handle *lockh, int unref);
 
 int osc_setattr_async(struct obd_export *exp, struct obdo *oa,
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 0a7bfe2..cf5b3cc 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -240,7 +240,7 @@ static void osc_page_touch_at(const struct lu_env *env,
 	struct lov_oinfo *loi = cl2osc(obj)->oo_oinfo;
 	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 	int valid;
-	__u64 kms;
+	u64 kms;
 
 	/* offset within stripe */
 	kms = cl_offset(obj, idx) + to;
@@ -454,7 +454,7 @@ static bool trunc_check_cb(const struct lu_env *env, struct cl_io *io,
 {
 	struct cl_page *page = ops->ops_cl.cpl_page;
 	struct osc_async_page *oap;
-	__u64 start = *(__u64 *)cbdata;
+	u64 start = *(u64 *)cbdata;
 
 	oap = &ops->ops_oap;
 	if (oap->oap_cmd & OBD_BRW_WRITE &&
@@ -470,7 +470,7 @@ static bool trunc_check_cb(const struct lu_env *env, struct cl_io *io,
 }
 
 static void osc_trunc_check(const struct lu_env *env, struct cl_io *io,
-			    struct osc_io *oio, __u64 size)
+			    struct osc_io *oio, u64 size)
 {
 	struct cl_object *clob;
 	int partial;
@@ -498,7 +498,7 @@ static int osc_io_setattr_start(const struct lu_env *env,
 	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 	struct obdo *oa = &oio->oi_oa;
 	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
-	__u64 size = io->u.ci_setattr.sa_attr.lvb_size;
+	u64 size = io->u.ci_setattr.sa_attr.lvb_size;
 	unsigned int ia_avalid = io->u.ci_setattr.sa_avalid;
 	enum op_xvalid ia_xvalid = io->u.ci_setattr.sa_xvalid;
 	int result = 0;
@@ -615,7 +615,7 @@ static void osc_io_setattr_end(const struct lu_env *env,
 	}
 
 	if (cl_io_is_trunc(io)) {
-		__u64 size = io->u.ci_setattr.sa_attr.lvb_size;
+		u64 size = io->u.ci_setattr.sa_attr.lvb_size;
 
 		osc_trunc_check(env, io, oio, size);
 		osc_cache_truncate_end(env, oio->oi_trunc);
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 1781243..06d813e 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -153,9 +153,9 @@ static void osc_lock_build_policy(const struct lu_env *env,
 	policy->l_extent.gid = d->cld_gid;
 }
 
-static __u64 osc_enq2ldlm_flags(__u32 enqflags)
+static u64 osc_enq2ldlm_flags(u32 enqflags)
 {
-	__u64 result = 0;
+	u64 result = 0;
 
 	LASSERT((enqflags & ~CEF_MASK) == 0);
 
@@ -200,7 +200,7 @@ static void osc_lock_lvb_update(const struct lu_env *env,
 
 	cl_object_attr_lock(obj);
 	if (dlmlock) {
-		__u64 size;
+		u64 size;
 
 		check_res_locked(dlmlock->l_resource);
 		LASSERT(lvb == dlmlock->l_lvb_data);
@@ -450,7 +450,7 @@ static int __osc_dlm_blocking_ast(const struct lu_env *env,
 	if (obj) {
 		struct ldlm_extent *extent = &dlmlock->l_policy_data.l_extent;
 		struct cl_attr *attr = &osc_env_info(env)->oti_attr;
-		__u64 old_kms;
+		u64 old_kms;
 
 		/* Destroy pages covered by the extent of the DLM lock */
 		result = osc_lock_flush(cl2osc(obj),
@@ -1146,7 +1146,7 @@ int osc_lock_init(const struct lu_env *env,
 		  const struct cl_io *io)
 {
 	struct osc_lock *oscl;
-	__u32 enqflags = lock->cll_descr.cld_enq_flags;
+	u32 enqflags = lock->cll_descr.cld_enq_flags;
 
 	oscl = kmem_cache_zalloc(osc_lock_kmem, GFP_NOFS);
 	if (!oscl)
@@ -1200,7 +1200,7 @@ struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
 	struct lustre_handle lockh;
 	struct ldlm_lock *lock = NULL;
 	enum ldlm_mode mode;
-	__u64 flags;
+	u64 flags;
 
 	ostid_build_res_name(&obj->oo_oinfo->loi_oi, resname);
 	osc_index2policy(policy, osc2cl(obj), index, index);
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index e9ecb77..1097380 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -173,7 +173,7 @@ static int osc_attr_update(const struct lu_env *env, struct cl_object *obj,
 		lvb->lvb_blocks = attr->cat_blocks;
 	if (valid & CAT_KMS) {
 		CDEBUG(D_CACHE, "set kms from %llu to %llu\n",
-		       oinfo->loi_kms, (__u64)attr->cat_kms);
+		       oinfo->loi_kms, (u64)attr->cat_kms);
 		loi_kms_set(oinfo, attr->cat_kms);
 	}
 	return 0;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 2599caa..e92c8ac 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -101,7 +101,7 @@ struct osc_enqueue_args {
 	struct obd_export	*oa_exp;
 	enum ldlm_type		oa_type;
 	enum ldlm_mode		oa_mode;
-	__u64			*oa_flags;
+	u64			*oa_flags;
 	osc_enqueue_upcall_f	oa_upcall;
 	void			*oa_cookie;
 	struct ost_lvb		*oa_lvb;
@@ -535,7 +535,7 @@ int osc_sync_base(struct osc_object *obj, struct obdo *oa,
  */
 static int osc_resource_get_unused(struct obd_export *exp, struct obdo *oa,
 				   struct list_head *cancels,
-				   enum ldlm_mode mode, __u64 lock_flags)
+				   enum ldlm_mode mode, u64 lock_flags)
 {
 	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
 	struct ldlm_res_id res_id;
@@ -783,7 +783,7 @@ static void osc_shrink_grant_local(struct client_obd *cli, struct obdo *oa)
  */
 static int osc_shrink_grant(struct client_obd *cli)
 {
-	__u64 target_bytes = (cli->cl_max_rpcs_in_flight + 1) *
+	u64 target_bytes = (cli->cl_max_rpcs_in_flight + 1) *
 			     (cli->cl_max_pages_per_rpc << PAGE_SHIFT);
 
 	spin_lock(&cli->cl_loi_list_lock);
@@ -794,7 +794,7 @@ static int osc_shrink_grant(struct client_obd *cli)
 	return osc_shrink_grant_to_target(cli, target_bytes);
 }
 
-int osc_shrink_grant_to_target(struct client_obd *cli, __u64 target_bytes)
+int osc_shrink_grant_to_target(struct client_obd *cli, u64 target_bytes)
 {
 	int rc = 0;
 	struct ost_body	*body;
@@ -1000,7 +1000,7 @@ static int check_write_rcs(struct ptlrpc_request *req,
 			   u32 page_count, struct brw_page **pga)
 {
 	int i;
-	__u32 *remote_rcs;
+	u32 *remote_rcs;
 
 	remote_rcs = req_capsule_server_sized_get(&req->rq_pill, &RMF_RCS,
 						  sizeof(*remote_rcs) *
@@ -1055,7 +1055,7 @@ static u32 osc_checksum_bulk(int nob, u32 pg_count,
 			     struct brw_page **pga, int opc,
 			     enum cksum_type cksum_type)
 {
-	__u32 cksum;
+	u32 cksum;
 	int i = 0;
 	struct ahash_request *hdesc;
 	unsigned int bufsize;
@@ -1285,7 +1285,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		oa->o_cksum = body->oa.o_cksum;
 		/* 1 RC per niobuf */
 		req_capsule_set_size(pill, &RMF_RCS, RCL_SERVER,
-				     sizeof(__u32) * niocount);
+				     sizeof(u32) * niocount);
 	} else {
 		if (cli->cl_checksum &&
 		    !sptlrpc_flavor_has_bulk(&req->rq_flvr)) {
@@ -1395,7 +1395,7 @@ static int check_write_checksum(struct obdo *oa,
 				u32 client_cksum, u32 server_cksum,
 				struct osc_brw_async_args *aa)
 {
-	__u32 new_cksum;
+	u32 new_cksum;
 	char *msg;
 	enum cksum_type cksum_type;
 
@@ -1452,7 +1452,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 			&req->rq_import->imp_connection->c_peer;
 	struct client_obd *cli = aa->aa_cli;
 	struct ost_body *body;
-	__u32 client_cksum = 0;
+	u32 client_cksum = 0;
 
 	if (rc < 0 && rc != -EDQUOT) {
 		DEBUG_REQ(D_INFO, req, "Failed request with rc = %d\n", rc);
@@ -1534,7 +1534,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 
 	if (body->oa.o_valid & OBD_MD_FLCKSUM) {
 		static int cksum_counter;
-		__u32 server_cksum = body->oa.o_cksum;
+		u32 server_cksum = body->oa.o_cksum;
 		char *via = "";
 		char *router = "";
 		enum cksum_type cksum_type;
@@ -2050,7 +2050,7 @@ static int osc_set_lock_data(struct ldlm_lock *lock, void *data)
 static int osc_enqueue_fini(struct ptlrpc_request *req,
 			    osc_enqueue_upcall_f upcall, void *cookie,
 			    struct lustre_handle *lockh, enum ldlm_mode mode,
-			    __u64 *flags, int agl, int errcode)
+			    u64 *flags, int agl, int errcode)
 {
 	bool intent = *flags & LDLM_FL_HAS_INTENT;
 	int rc;
@@ -2090,8 +2090,8 @@ static int osc_enqueue_interpret(const struct lu_env *env,
 	struct lustre_handle *lockh = &aa->oa_lockh;
 	enum ldlm_mode mode = aa->oa_mode;
 	struct ost_lvb *lvb = aa->oa_lvb;
-	__u32 lvb_len = sizeof(*lvb);
-	__u64 flags = 0;
+	u32 lvb_len = sizeof(*lvb);
+	u64 flags = 0;
 
 	/* ldlm_cli_enqueue is holding a reference on the lock, so it must
 	 * be valid.
@@ -2143,7 +2143,7 @@ static int osc_enqueue_interpret(const struct lu_env *env,
  * release locks just after they are obtained.
  */
 int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
-		     __u64 *flags, union ldlm_policy_data *policy,
+		     u64 *flags, union ldlm_policy_data *policy,
 		     struct ost_lvb *lvb, int kms_valid,
 		     osc_enqueue_upcall_f upcall, void *cookie,
 		     struct ldlm_enqueue_info *einfo,
@@ -2153,7 +2153,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	struct lustre_handle lockh = { 0 };
 	struct ptlrpc_request *req = NULL;
 	int intent = *flags & LDLM_FL_HAS_INTENT;
-	__u64 match_flags = *flags;
+	u64 match_flags = *flags;
 	enum ldlm_mode mode;
 	int rc;
 
@@ -2292,11 +2292,11 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 
 int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		   enum ldlm_type type, union ldlm_policy_data *policy,
-		   enum ldlm_mode mode, __u64 *flags, void *data,
+		   enum ldlm_mode mode, u64 *flags, void *data,
 		   struct lustre_handle *lockh, int unref)
 {
 	struct obd_device *obd = exp->exp_obd;
-	__u64 lflags = *flags;
+	u64 lflags = *flags;
 	enum ldlm_mode rc;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_MATCH))
@@ -2371,7 +2371,7 @@ static int osc_statfs_interpret(const struct lu_env *env,
 }
 
 static int osc_statfs_async(struct obd_export *exp,
-			    struct obd_info *oinfo, __u64 max_age,
+			    struct obd_info *oinfo, u64 max_age,
 			    struct ptlrpc_request_set *rqset)
 {
 	struct obd_device *obd = class_exp2obd(exp);
@@ -2415,7 +2415,7 @@ static int osc_statfs_async(struct obd_export *exp,
 }
 
 static int osc_statfs(const struct lu_env *env, struct obd_export *exp,
-		      struct obd_statfs *osfs, __u64 max_age, __u32 flags)
+		      struct obd_statfs *osfs, u64 max_age, u32 flags)
 {
 	struct obd_device *obd = class_exp2obd(exp);
 	struct obd_statfs *msfs;
-- 
1.8.3.1
