From: James Simmons <jsimmons@infradead.org>
Date: Wed, 14 Jun 2017 11:01:16 -0400
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: lustre: resolve "use
	spaces between elements" checkpatch errors
In-Reply-To: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
References: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1497452481-31124-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Due to the way the DFID was embedded in our debug strings checkpatch
would report the following error:

CHECK: Concatenated strings should use spaces between elements

This patch introduces proper space to resolve these reports.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fid/fid_request.c    |  2 +-
 drivers/staging/lustre/lustre/fld/fld_cache.c      |  6 ++--
 .../lustre/lustre/include/lustre/lustre_idl.h      |  6 ++--
 .../lustre/lustre/include/lustre/lustre_user.h     |  2 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  6 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  4 +--
 drivers/staging/lustre/lustre/llite/dcache.c       |  4 +--
 drivers/staging/lustre/lustre/llite/dir.c          | 12 +++----
 drivers/staging/lustre/lustre/llite/file.c         | 42 +++++++++++-----------
 .../staging/lustre/lustre/llite/llite_internal.h   |  4 +--
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 34 +++++++++---------
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  2 +-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    | 10 +++---
 drivers/staging/lustre/lustre/llite/namei.c        | 38 ++++++++++----------
 drivers/staging/lustre/lustre/llite/rw26.c         |  2 +-
 drivers/staging/lustre/lustre/llite/statahead.c    | 14 ++++----
 drivers/staging/lustre/lustre/llite/symlink.c      |  4 +--
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_object.c   |  2 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |  6 ++--
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |  4 +--
 drivers/staging/lustre/lustre/lmv/lmv_fld.c        |  2 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  6 ++--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 40 ++++++++++-----------
 drivers/staging/lustre/lustre/lov/lov_io.c         |  2 +-
 drivers/staging/lustre/lustre/lov/lov_merge.c      |  4 +--
 drivers/staging/lustre/lustre/lov/lov_object.c     |  7 ++--
 drivers/staging/lustre/lustre/lov/lov_pack.c       |  6 ++--
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  8 ++---
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  6 ++--
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |  2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    | 16 ++++-----
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |  2 +-
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |  2 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |  2 +-
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  | 12 +++----
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |  2 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  2 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |  4 +--
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  8 ++---
 drivers/staging/lustre/lustre/osc/osc_request.c    |  3 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  4 +--
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  2 +-
 45 files changed, 175 insertions(+), 177 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index cd84b42..c05e928 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -279,7 +279,7 @@ int seq_client_alloc_fid(const struct lu_env *env,
 	*fid = seq->lcs_fid;
 	mutex_unlock(&seq->lcs_mutex);
 
-	CDEBUG(D_INFO, "%s: Allocated FID "DFID"\n", seq->lcs_name,  PFID(fid));
+	CDEBUG(D_INFO, "%s: Allocated FID " DFID "\n", seq->lcs_name,  PFID(fid));
 	return rc;
 }
 EXPORT_SYMBOL(seq_client_alloc_fid);
diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index 11f6974..b852fed 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -151,7 +151,7 @@ static void fld_fix_new_list(struct fld_cache *cache)
 			continue;
 
 		LASSERTF(c_range->lsr_start <= n_range->lsr_start,
-			 "cur lsr_start "DRANGE" next lsr_start "DRANGE"\n",
+			 "cur lsr_start " DRANGE " next lsr_start " DRANGE "\n",
 			 PRANGE(c_range), PRANGE(n_range));
 
 		/* check merge possibility with next range */
@@ -349,7 +349,7 @@ static void fld_cache_overlap_handle(struct fld_cache *cache,
 		f_curr->fce_range.lsr_end = new_start;
 		fld_cache_entry_add(cache, f_new, &f_curr->fce_list);
 	} else
-		CERROR("NEW range ="DRANGE" curr = "DRANGE"\n",
+		CERROR("NEW range =" DRANGE " curr = " DRANGE "\n",
 		       PRANGE(range), PRANGE(&f_curr->fce_range));
 }
 
@@ -415,7 +415,7 @@ static int fld_cache_insert_nolock(struct fld_cache *cache,
 	if (!prev)
 		prev = head;
 
-	CDEBUG(D_INFO, "insert range "DRANGE"\n", PRANGE(&f_new->fce_range));
+	CDEBUG(D_INFO, "insert range " DRANGE "\n", PRANGE(&f_new->fce_range));
 	/* Add new entry to cache and lru list. */
 	fld_cache_entry_add(cache, f_new, prev);
 out:
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index df48b8d..77995fa 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -546,7 +546,7 @@ static inline void ostid_set_id(struct ost_id *oi, __u64 oid)
 static inline int fid_set_id(struct lu_fid *fid, __u64 oid)
 {
 	if (unlikely(fid_seq_is_igif(fid->f_seq))) {
-		CERROR("bad IGIF, "DFID"\n", PFID(fid));
+		CERROR("bad IGIF, " DFID "\n", PFID(fid));
 		return -EBADF;
 	}
 
@@ -585,7 +585,7 @@ static inline int ostid_to_fid(struct lu_fid *fid, struct ost_id *ostid,
 	__u64 seq = ostid_seq(ostid);
 
 	if (ost_idx > 0xffff) {
-		CERROR("bad ost_idx, "DOSTID" ost_idx:%u\n", POSTID(ostid),
+		CERROR("bad ost_idx, " DOSTID " ost_idx:%u\n", POSTID(ostid),
 		       ost_idx);
 		return -EBADF;
 	}
@@ -630,7 +630,7 @@ static inline int ostid_to_fid(struct lu_fid *fid, struct ost_id *ostid,
 static inline int fid_to_ostid(const struct lu_fid *fid, struct ost_id *ostid)
 {
 	if (unlikely(fid_seq_is_igif(fid->f_seq))) {
-		CERROR("bad IGIF, "DFID"\n", PFID(fid));
+		CERROR("bad IGIF, " DFID "\n", PFID(fid));
 		return -EBADF;
 	}
 
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 7d8628c..edff8dc 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -532,7 +532,7 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 #define FID_NOBRACE_LEN 40
 #define FID_LEN (FID_NOBRACE_LEN + 2)
 #define DFID_NOBRACE "%#llx:0x%x:0x%x"
-#define DFID "["DFID_NOBRACE"]"
+#define DFID "[" DFID_NOBRACE "]"
 #define PFID(fid) (unsigned long long)(fid)->f_seq, (fid)->f_oid, (fid)->f_ver
 
 /* scanf input parse format for fids in DFID_NOBRACE format
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index b5a1aad..6dc24a7 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -606,7 +606,7 @@ static inline __u32 fid_flatten32(const struct lu_fid *fid)
 static inline int lu_fid_diff(const struct lu_fid *fid1,
 			      const struct lu_fid *fid2)
 {
-	LASSERTF(fid_seq(fid1) == fid_seq(fid2), "fid1:"DFID", fid2:"DFID"\n",
+	LASSERTF(fid_seq(fid1) == fid_seq(fid2), "fid1:" DFID ", fid2:" DFID "\n",
 		 PFID(fid1), PFID(fid2));
 
 	if (fid_is_idif(fid1) && fid_is_idif(fid2))
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 84eeaa5..4028e11 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -445,8 +445,8 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 
 		if (!ldlm_res_eq(&reply->lock_desc.l_resource.lr_name,
 				 &lock->l_resource->lr_name)) {
-			CDEBUG(D_INFO, "remote intent success, locking "DLDLMRES
-				       " instead of "DLDLMRES"\n",
+			CDEBUG(D_INFO, "remote intent success, locking " DLDLMRES
+				       " instead of " DLDLMRES "\n",
 			       PLDLMRES(&reply->lock_desc.l_resource),
 			       PLDLMRES(lock->l_resource));
 
@@ -1677,7 +1677,7 @@ int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
 					   0, flags | LCF_BL_AST, opaque);
 	rc = ldlm_cli_cancel_list(&cancels, count, NULL, flags);
 	if (rc != ELDLM_OK)
-		CERROR("canceling unused lock "DLDLMRES": rc = %d\n",
+		CERROR("canceling unused lock " DLDLMRES ": rc = %d\n",
 		       PLDLMRES(res), rc);
 
 	LDLM_RESOURCE_DELREF(res);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 1c8b0ea..c9ef247 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -849,7 +849,7 @@ static int ldlm_resource_complain(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 	struct ldlm_resource  *res = cfs_hash_object(hs, hnode);
 
 	lock_res(res);
-	CERROR("%s: namespace resource "DLDLMRES
+	CERROR("%s: namespace resource " DLDLMRES
 	       " (%p) refcount nonzero (%d) after lock cleanup; forcing cleanup.\n",
 	       ldlm_ns_name(ldlm_res_to_ns(res)), PLDLMRES(res), res,
 	       atomic_read(&res->lr_refcount) - 1);
@@ -1391,7 +1391,7 @@ void ldlm_resource_dump(int level, struct ldlm_resource *res)
 	if (!((libcfs_debug | D_ERROR) & level))
 		return;
 
-	CDEBUG(level, "--- Resource: "DLDLMRES" (%p) refcount = %d\n",
+	CDEBUG(level, "--- Resource: " DLDLMRES " (%p) refcount = %d\n",
 	       PLDLMRES(res), res, atomic_read(&res->lr_refcount));
 
 	if (!list_empty(&res->lr_granted)) {
diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index 38f8466..d20425f 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -180,7 +180,7 @@ void ll_invalidate_aliases(struct inode *inode)
 {
 	struct dentry *dentry;
 
-	CDEBUG(D_INODE, "marking dentries for ino "DFID"(%p) invalid\n",
+	CDEBUG(D_INODE, "marking dentries for ino " DFID "(%p) invalid\n",
 	       PFID(ll_inode2fid(inode)), inode);
 
 	spin_lock(&inode->i_lock);
@@ -216,7 +216,7 @@ void ll_lookup_finish_locks(struct lookup_intent *it, struct inode *inode)
 	if (it->it_lock_mode && inode) {
 		struct ll_sb_info *sbi = ll_i2sbi(inode);
 
-		CDEBUG(D_DLMTRACE, "setting l_data to inode "DFID"(%p)\n",
+		CDEBUG(D_DLMTRACE, "setting l_data to inode " DFID "(%p)\n",
 		       PFID(ll_inode2fid(inode)), inode);
 		ll_set_lock_data(sbi->ll_md_exp, inode, it, NULL);
 	}
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 13b3592..e8696be 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -303,7 +303,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	struct md_op_data *op_data;
 	int			rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p) pos/size %lu/%llu 32bit_api %d\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p) pos/size %lu/%llu 32bit_api %d\n",
 	       PFID(ll_inode2fid(inode)), inode, (unsigned long)pos,
 	       i_size_read(inode), api32);
 
@@ -419,7 +419,7 @@ static int ll_dir_setdirstripe(struct inode *parent, struct lmv_user_md *lump,
 	if (unlikely(lump->lum_magic != LMV_USER_MAGIC))
 		return -EINVAL;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p) name %s stripe_offset %d, stripe_count: %u\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p) name %s stripe_offset %d, stripe_count: %u\n",
 	       PFID(ll_inode2fid(parent)), parent, dirname,
 	       (int)lump->lum_stripe_offset, lump->lum_stripe_count);
 
@@ -606,7 +606,7 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 	rc = md_getattr(sbi->ll_md_exp, op_data, &req);
 	ll_finish_md_op_data(op_data);
 	if (rc < 0) {
-		CDEBUG(D_INFO, "md_getattr failed on inode "DFID": rc %d\n",
+		CDEBUG(D_INFO, "md_getattr failed on inode " DFID ": rc %d\n",
 		       PFID(ll_inode2fid(inode)), rc);
 		goto out;
 	}
@@ -733,7 +733,7 @@ static int ll_ioc_copy_start(struct super_block *sb, struct hsm_copy *copy)
 		iput(inode);
 		if (rc != 0) {
 			CDEBUG(D_HSM, "Could not read file data version of "
-				      DFID" (rc = %d). Archive request (%#llx) could not be done.\n",
+				      DFID " (rc = %d). Archive request (%#llx) could not be done.\n",
 				      PFID(&copy->hc_hai.hai_fid), rc,
 				      copy->hc_hai.hai_cookie);
 			hpk.hpk_flags |= HP_FLAG_RETRY;
@@ -833,7 +833,7 @@ static int ll_ioc_copy_end(struct super_block *sb, struct hsm_copy *copy)
 		if ((copy->hc_hai.hai_action == HSMA_ARCHIVE) &&
 		    (copy->hc_data_version != data_version)) {
 			CDEBUG(D_HSM, "File data version mismatched. File content was changed during archiving. "
-			       DFID", start:%#llx current:%#llx\n",
+			       DFID ", start:%#llx current:%#llx\n",
 			       PFID(&copy->hc_hai.hai_fid),
 			       copy->hc_data_version, data_version);
 			/* File was changed, send error to cdt. Do not ask for
@@ -1037,7 +1037,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	struct obd_ioctl_data *data;
 	int rc = 0;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), cmd=%#x\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p), cmd=%#x\n",
 	       PFID(ll_inode2fid(inode)), inode, cmd);
 
 	/* asm-ppc{,64} declares TCGETS, et. al. as type 't' not 'T' */
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 67c4b9c..711fbb0 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -316,7 +316,7 @@ int ll_file_release(struct inode *inode, struct file *file)
 	struct ll_inode_info *lli = ll_i2info(inode);
 	int rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p)\n",
 	       PFID(ll_inode2fid(inode)), inode);
 
 	if (!is_root_inode(inode))
@@ -494,7 +494,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 	struct ll_file_data *fd;
 	int rc = 0;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), flags %o\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p), flags %o\n",
 	       PFID(ll_inode2fid(inode)), inode, file->f_flags);
 
 	it = file->private_data; /* XXX: compat macro */
@@ -834,7 +834,7 @@ static int ll_md_blocking_lease_ast(struct ldlm_lock *lock,
 	}
 	rc2 = ll_close_inode_openhandle(inode, och, 0, NULL);
 	if (rc2 < 0)
-		CERROR("%s: error closing file "DFID": %d\n",
+		CERROR("%s: error closing file " DFID ": %d\n",
 		       ll_get_fsname(inode->i_sb, NULL, 0),
 		       PFID(&ll_i2info(inode)->lli_fid), rc2);
 	och = NULL; /* och has been freed in ll_close_inode_openhandle() */
@@ -1665,7 +1665,7 @@ int ll_hsm_release(struct inode *inode)
 	int rc;
 	u16 refcheck;
 
-	CDEBUG(D_INODE, "%s: Releasing file "DFID".\n",
+	CDEBUG(D_INODE, "%s: Releasing file " DFID ".\n",
 	       ll_get_fsname(inode->i_sb, NULL, 0),
 	       PFID(&ll_i2info(inode)->lli_fid));
 
@@ -1928,7 +1928,7 @@ static inline long ll_lease_type_from_fmode(fmode_t fmode)
 	struct ll_file_data	*fd = LUSTRE_FPRIVATE(file);
 	int			 flags, rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p),cmd=%x\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p),cmd=%x\n",
 	       PFID(ll_inode2fid(inode)), inode, cmd);
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_IOCTL, 1);
 
@@ -2263,7 +2263,7 @@ static loff_t ll_file_seek(struct file *file, loff_t offset, int origin)
 
 	retval = offset + ((origin == SEEK_END) ? i_size_read(inode) :
 			   (origin == SEEK_CUR) ? file->f_pos : 0);
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), to=%llu=%#llx(%d)\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p), to=%llu=%#llx(%d)\n",
 	       PFID(ll_inode2fid(inode)), inode, retval, retval, origin);
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_LLSEEK, 1);
 
@@ -2360,7 +2360,7 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	struct ptlrpc_request *req;
 	int rc, err;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p)\n",
 	       PFID(ll_inode2fid(inode)), inode);
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FSYNC, 1);
 
@@ -2422,7 +2422,7 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	int rc;
 	int rc2 = 0;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID" file_lock=%p\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID " file_lock=%p\n",
 	       PFID(ll_inode2fid(inode)), file_lock);
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FLOCK, 1);
@@ -2507,7 +2507,7 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	CDEBUG(D_DLMTRACE, "inode="DFID", pid=%u, flags=%#llx, mode=%u, start=%llu, end=%llu\n",
+	CDEBUG(D_DLMTRACE, "inode=" DFID ", pid=%u, flags=%#llx, mode=%u, start=%llu, end=%llu\n",
 	       PFID(ll_inode2fid(inode)), flock.l_flock.pid, flags,
 	       einfo.ei_mode, flock.l_flock.start, flock.l_flock.end);
 
@@ -2582,7 +2582,7 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	struct qstr qstr;
 	int rc;
 
-	CDEBUG(D_VFSTRACE, "migrate %s under "DFID" to MDT%d\n",
+	CDEBUG(D_VFSTRACE, "migrate %s under " DFID " to MDT%d\n",
 	       name, PFID(ll_inode2fid(parent)), mdtidx);
 
 	op_data = ll_prep_md_op_data(NULL, parent, NULL, name, namelen,
@@ -2617,7 +2617,7 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	inode_lock(child_inode);
 	op_data->op_fid3 = *ll_inode2fid(child_inode);
 	if (!fid_is_sane(&op_data->op_fid3)) {
-		CERROR("%s: migrate %s, but fid "DFID" is insane\n",
+		CERROR("%s: migrate %s, but fid " DFID " is insane\n",
 		       ll_get_fsname(parent->i_sb, NULL, 0), name,
 		       PFID(&op_data->op_fid3));
 		rc = -EINVAL;
@@ -2629,7 +2629,7 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 		goto out_unlock;
 
 	if (rc == mdtidx) {
-		CDEBUG(D_INFO, "%s:"DFID" is already on MDT%d.\n", name,
+		CDEBUG(D_INFO, "%s: " DFID " is already on MDT%d.\n", name,
 		       PFID(&op_data->op_fid3), mdtidx);
 		rc = 0;
 		goto out_unlock;
@@ -2733,7 +2733,7 @@ int ll_have_md_lock(struct inode *inode, __u64 *bits,
 		return 0;
 
 	fid = &ll_i2info(inode)->lli_fid;
-	CDEBUG(D_INFO, "trying to match res "DFID" mode %s\n", PFID(fid),
+	CDEBUG(D_INFO, "trying to match res " DFID " mode %s\n", PFID(fid),
 	       ldlm_lockname[mode]);
 
 	flags = LDLM_FL_BLOCK_GRANTED | LDLM_FL_CBPENDING | LDLM_FL_TEST_LOCK;
@@ -2767,7 +2767,7 @@ enum ldlm_mode ll_take_md_lock(struct inode *inode, __u64 bits,
 	struct lu_fid *fid;
 
 	fid = &ll_i2info(inode)->lli_fid;
-	CDEBUG(D_INFO, "trying to match res "DFID"\n", PFID(fid));
+	CDEBUG(D_INFO, "trying to match res " DFID "\n", PFID(fid));
 
 	return md_lock_match(ll_i2mdexp(inode), flags | LDLM_FL_BLOCK_GRANTED,
 			     fid, LDLM_IBITS, &policy, mode, lockh);
@@ -2792,7 +2792,7 @@ static int ll_inode_revalidate_fini(struct inode *inode, int rc)
 			return 0;
 	} else if (rc != 0) {
 		CDEBUG_LIMIT((rc == -EACCES || rc == -EIDRM) ? D_INFO : D_ERROR,
-			     "%s: revalidate FID "DFID" error: rc = %d\n",
+			     "%s: revalidate FID " DFID " error: rc = %d\n",
 			     ll_get_fsname(inode->i_sb, NULL, 0),
 			     PFID(ll_inode2fid(inode)), rc);
 	}
@@ -2807,7 +2807,7 @@ static int __ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 	struct obd_export *exp;
 	int rc = 0;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p),name=%pd\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p),name=%pd\n",
 	       PFID(ll_inode2fid(inode)), inode, dentry);
 
 	exp = ll_i2mdexp(inode);
@@ -3067,7 +3067,7 @@ int ll_inode_permission(struct inode *inode, int mask)
 			return rc;
 	}
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), inode mode %x mask %o\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p), inode mode %x mask %o\n",
 	       PFID(ll_inode2fid(inode)), inode, inode->i_mode, mask);
 
 	/* squash fsuid/fsgid if needed */
@@ -3322,7 +3322,7 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 	int lmmsize;
 	int rc;
 
-	CDEBUG(D_INODE, DFID" LVB_READY=%d l_lvb_data=%p l_lvb_len=%d\n",
+	CDEBUG(D_INODE, DFID " LVB_READY=%d l_lvb_data=%p l_lvb_len=%d\n",
 	       PFID(ll_inode2fid(inode)), ldlm_is_lvb_ready(lock),
 	       lock->l_lvb_data, lock->l_lvb_len);
 
@@ -3447,7 +3447,7 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 
 	/* wait for IO to complete if it's still being used. */
 	if (wait_layout) {
-		CDEBUG(D_INODE, "%s: "DFID"(%p) wait for layout reconf\n",
+		CDEBUG(D_INODE, "%s: " DFID "(%p) wait for layout reconf\n",
 		       ll_get_fsname(inode->i_sb, NULL, 0),
 		       PFID(&lli->lli_fid), inode);
 
@@ -3458,7 +3458,7 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 		if (rc == 0)
 			rc = -EAGAIN;
 
-		CDEBUG(D_INODE, "%s: file="DFID" waiting layout return: %d.\n",
+		CDEBUG(D_INODE, "%s: file=" DFID " waiting layout return: %d.\n",
 		       ll_get_fsname(inode->i_sb, NULL, 0),
 		       PFID(&lli->lli_fid), rc);
 	}
@@ -3504,7 +3504,7 @@ static int ll_layout_refresh_locked(struct inode *inode)
 	it.it_op = IT_LAYOUT;
 	lockh.cookie = 0ULL;
 
-	LDLM_DEBUG_NOLOCK("%s: requeue layout lock for file "DFID"(%p)",
+	LDLM_DEBUG_NOLOCK("%s: requeue layout lock for file " DFID "(%p)",
 			  ll_get_fsname(inode->i_sb, NULL, 0),
 			  PFID(&lli->lli_fid), inode);
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index d2a0fab..de09ddf 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1253,7 +1253,7 @@ static inline void ll_set_lock_data(struct obd_export *exp, struct inode *inode,
 		 */
 		if (it->it_remote_lock_mode) {
 			handle.cookie = it->it_remote_lock_handle;
-			CDEBUG(D_DLMTRACE, "setting l_data to inode "DFID"%p for remote lock %#llx\n",
+			CDEBUG(D_DLMTRACE, "setting l_data to inode " DFID "%p for remote lock %#llx\n",
 			       PFID(ll_inode2fid(inode)), inode,
 			       handle.cookie);
 			md_set_lock_data(exp, &handle, inode, NULL);
@@ -1261,7 +1261,7 @@ static inline void ll_set_lock_data(struct obd_export *exp, struct inode *inode,
 
 		handle.cookie = it->it_lock_handle;
 
-		CDEBUG(D_DLMTRACE, "setting l_data to inode "DFID"%p for lock %#llx\n",
+		CDEBUG(D_DLMTRACE, "setting l_data to inode " DFID "%p for lock %#llx\n",
 		       PFID(ll_inode2fid(inode)), inode, handle.cookie);
 
 		md_set_lock_data(exp, &handle, inode, &it->it_lock_bits);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index ca5040c..974a05d 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -427,13 +427,13 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 		goto out_lock_cn_cb;
 	}
 	if (!fid_is_sane(&sbi->ll_root_fid)) {
-		CERROR("%s: Invalid root fid "DFID" during mount\n",
+		CERROR("%s: Invalid root fid " DFID " during mount\n",
 		       sbi->ll_md_exp->exp_obd->obd_name,
 		       PFID(&sbi->ll_root_fid));
 		err = -EINVAL;
 		goto out_lock_cn_cb;
 	}
-	CDEBUG(D_SUPER, "rootfid "DFID"\n", PFID(&sbi->ll_root_fid));
+	CDEBUG(D_SUPER, "rootfid " DFID "\n", PFID(&sbi->ll_root_fid));
 
 	sb->s_op = &lustre_super_operations;
 	sb->s_xattr = ll_xattr_handlers;
@@ -1079,7 +1079,7 @@ static struct inode *ll_iget_anon_dir(struct super_block *sb,
 	ino = cl_fid_build_ino(fid, sbi->ll_flags & LL_SBI_32BIT_API);
 	inode = iget_locked(sb, ino);
 	if (!inode) {
-		CERROR("%s: failed get simple inode "DFID": rc = -ENOENT\n",
+		CERROR("%s: failed get simple inode " DFID ": rc = -ENOENT\n",
 		       ll_get_fsname(sb, NULL, 0), PFID(fid));
 		return ERR_PTR(-ENOENT);
 	}
@@ -1090,7 +1090,7 @@ static struct inode *ll_iget_anon_dir(struct super_block *sb,
 
 		inode->i_mode = (inode->i_mode & ~S_IFMT) |
 				(body->mbo_mode & S_IFMT);
-		LASSERTF(S_ISDIR(inode->i_mode), "Not slave inode "DFID"\n",
+		LASSERTF(S_ISDIR(inode->i_mode), "Not slave inode " DFID "\n",
 			 PFID(fid));
 
 		LTIME_S(inode->i_mtime) = 0;
@@ -1106,7 +1106,7 @@ static struct inode *ll_iget_anon_dir(struct super_block *sb,
 		LASSERT(lsm);
 		/* master object FID */
 		lli->lli_pfid = body->mbo_fid1;
-		CDEBUG(D_INODE, "lli %p slave "DFID" master "DFID"\n",
+		CDEBUG(D_INODE, "lli %p slave " DFID " master " DFID "\n",
 		       lli, PFID(fid), PFID(&lli->lli_pfid));
 		unlock_new_inode(inode);
 	}
@@ -1174,7 +1174,7 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	int rc;
 
 	LASSERT(S_ISDIR(inode->i_mode));
-	CDEBUG(D_INODE, "update lsm %p of "DFID"\n", lli->lli_lsm_md,
+	CDEBUG(D_INODE, "update lsm %p of " DFID "\n", lli->lli_lsm_md,
 	       PFID(ll_inode2fid(inode)));
 
 	/* no striped information from request. */
@@ -1187,7 +1187,7 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 			 * migration is done, the temporay MIGRATE layout has
 			 * been removed
 			 */
-			CDEBUG(D_INODE, DFID" finish migration.\n",
+			CDEBUG(D_INODE, DFID " finish migration.\n",
 			       PFID(ll_inode2fid(inode)));
 			lmv_free_memmd(lli->lli_lsm_md);
 			lli->lli_lsm_md = NULL;
@@ -1241,7 +1241,7 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 
 		kfree(attr);
 
-		CDEBUG(D_INODE, "Set lsm %p magic %x to "DFID"\n", lsm,
+		CDEBUG(D_INODE, "Set lsm %p magic %x to " DFID "\n", lsm,
 		       lsm->lsm_md_magic, PFID(ll_inode2fid(inode)));
 		return 0;
 	}
@@ -1251,7 +1251,7 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 		struct lmv_stripe_md *old_lsm = lli->lli_lsm_md;
 		int idx;
 
-		CERROR("%s: inode "DFID"(%p)'s lmv layout mismatch (%p)/(%p) magic:0x%x/0x%x stripe count: %d/%d master_mdt: %d/%d hash_type:0x%x/0x%x layout: 0x%x/0x%x pool:%s/%s\n",
+		CERROR("%s: inode " DFID "(%p)'s lmv layout mismatch (%p)/(%p) magic:0x%x/0x%x stripe count: %d/%d master_mdt: %d/%d hash_type:0x%x/0x%x layout: 0x%x/0x%x pool:%s/%s\n",
 		       ll_get_fsname(inode->i_sb, NULL, 0), PFID(&lli->lli_fid),
 		       inode, lsm, old_lsm,
 		       lsm->lsm_md_magic, old_lsm->lsm_md_magic,
@@ -1266,13 +1266,13 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 		       old_lsm->lsm_md_pool_name);
 
 		for (idx = 0; idx < old_lsm->lsm_md_stripe_count; idx++) {
-			CERROR("%s: sub FIDs in old lsm idx %d, old: "DFID"\n",
+			CERROR("%s: sub FIDs in old lsm idx %d, old: " DFID "\n",
 			       ll_get_fsname(inode->i_sb, NULL, 0), idx,
 			       PFID(&old_lsm->lsm_md_oinfo[idx].lmo_fid));
 		}
 
 		for (idx = 0; idx < lsm->lsm_md_stripe_count; idx++) {
-			CERROR("%s: sub FIDs in new lsm idx %d, new: "DFID"\n",
+			CERROR("%s: sub FIDs in new lsm idx %d, new: " DFID "\n",
 			       ll_get_fsname(inode->i_sb, NULL, 0), idx,
 			       PFID(&lsm->lsm_md_oinfo[idx].lmo_fid));
 		}
@@ -1288,7 +1288,7 @@ void ll_clear_inode(struct inode *inode)
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p)\n",
 	       PFID(ll_inode2fid(inode)), inode);
 
 	if (S_ISDIR(inode->i_mode)) {
@@ -1421,7 +1421,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 	struct md_op_data *op_data = NULL;
 	int rc = 0;
 
-	CDEBUG(D_VFSTRACE, "%s: setattr inode "DFID"(%p) from %llu to %llu, valid %x, hsm_import %d\n",
+	CDEBUG(D_VFSTRACE, "%s: setattr inode " DFID "(%p) from %llu to %llu, valid %x, hsm_import %d\n",
 	       ll_get_fsname(inode->i_sb, NULL, 0), PFID(&lli->lli_fid), inode,
 	       i_size_read(inode), attr->ia_size, attr->ia_valid, hsm_import);
 
@@ -1436,7 +1436,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 		 * needs another check in addition to the VFS check above.
 		 */
 		if (attr->ia_size > ll_file_maxbytes(inode)) {
-			CDEBUG(D_INODE, "file "DFID" too large %llu > %llu\n",
+			CDEBUG(D_INODE, "file " DFID " too large %llu > %llu\n",
 			       PFID(&lli->lli_fid), attr->ia_size,
 			       ll_file_maxbytes(inode));
 			return -EFBIG;
@@ -1785,7 +1785,7 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 		/* FID shouldn't be changed! */
 		if (fid_is_sane(&lli->lli_fid)) {
 			LASSERTF(lu_fid_eq(&lli->lli_fid, &body->mbo_fid1),
-				 "Trying to change FID "DFID" to the "DFID", inode "DFID"(%p)\n",
+				 "Trying to change FID " DFID " to the " DFID ", inode " DFID "(%p)\n",
 				 PFID(&lli->lli_fid), PFID(&body->mbo_fid1),
 				 PFID(ll_inode2fid(inode)), inode);
 		} else {
@@ -1820,7 +1820,7 @@ int ll_read_inode2(struct inode *inode, void *opaque)
 	struct ll_inode_info *lli = ll_i2info(inode);
 	int rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p)\n",
 	       PFID(&lli->lli_fid), inode);
 
 	/* Core attributes from the MDS first.  This is a new inode, and
@@ -1902,7 +1902,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		rc = md_getattr(sbi->ll_md_exp, op_data, &req);
 		ll_finish_md_op_data(op_data);
 		if (rc) {
-			CERROR("%s: failure inode "DFID": rc = %d\n",
+			CERROR("%s: failure inode " DFID ": rc = %d\n",
 			       sbi->ll_md_exp->exp_obd->obd_name,
 			       PFID(ll_inode2fid(inode)), rc);
 			return -abs(rc);
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index cbbfdaf..ccc7ae1 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -378,7 +378,7 @@ static int ll_page_mkwrite(struct vm_fault *vmf)
 		if (!printed && ++count > 16) {
 			const struct dentry *de = vma->vm_file->f_path.dentry;
 
-			CWARN("app(%s): the page %lu of file "DFID" is under heavy contention\n",
+			CWARN("app(%s): the page %lu of file " DFID " is under heavy contention\n",
 			      current->comm, vmf->pgoff,
 			      PFID(ll_inode2fid(de->d_inode)));
 			printed = true;
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 49a930f..e50c637 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -84,7 +84,7 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 	struct  md_op_data    *op_data;
 	int		   rc;
 
-	CDEBUG(D_INFO, "searching inode for:(%lu,"DFID")\n", hash, PFID(fid));
+	CDEBUG(D_INFO, "searching inode for:(%lu," DFID ")\n", hash, PFID(fid));
 
 	inode = ilookup5(sb, hash, ll_test_inode_by_fid, (void *)fid);
 	if (inode)
@@ -109,7 +109,7 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 	rc = md_getattr(sbi->ll_md_exp, op_data, &req);
 	kfree(op_data);
 	if (rc) {
-		CDEBUG(D_INFO, "can't get object attrs, fid "DFID", rc %d\n",
+		CDEBUG(D_INFO, "can't get object attrs, fid " DFID ", rc %d\n",
 		       PFID(fid), rc);
 		return ERR_PTR(rc);
 	}
@@ -195,7 +195,7 @@ static int ll_encode_fh(struct inode *inode, __u32 *fh, int *plen,
 	int fileid_len = sizeof(struct lustre_nfs_fid) / 4;
 	struct lustre_nfs_fid *nfs_fid = (void *)fh;
 
-	CDEBUG(D_INFO, "%s: encoding for ("DFID") maxlen=%d minlen=%d\n",
+	CDEBUG(D_INFO, "%s: encoding for (" DFID ") maxlen=%d minlen=%d\n",
 	       ll_get_fsname(inode->i_sb, NULL, 0),
 	       PFID(ll_inode2fid(inode)), *plen, fileid_len);
 
@@ -312,7 +312,7 @@ int ll_dir_get_parent_fid(struct inode *dir, struct lu_fid *parent_fid)
 
 	sbi = ll_s2sbi(dir->i_sb);
 
-	CDEBUG(D_INFO, "%s: getting parent for ("DFID")\n",
+	CDEBUG(D_INFO, "%s: getting parent for (" DFID ")\n",
 	       ll_get_fsname(dir->i_sb, NULL, 0),
 	       PFID(ll_inode2fid(dir)));
 
@@ -329,7 +329,7 @@ int ll_dir_get_parent_fid(struct inode *dir, struct lu_fid *parent_fid)
 	rc = md_getattr_name(sbi->ll_md_exp, op_data, &req);
 	ll_finish_md_op_data(op_data);
 	if (rc) {
-		CERROR("%s: failure inode "DFID" get parent: rc = %d\n",
+		CERROR("%s: failure inode " DFID " get parent: rc = %d\n",
 		       ll_get_fsname(dir->i_sb, NULL, 0),
 		       PFID(ll_inode2fid(dir)), rc);
 		return rc;
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index d583696..9f118a1 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -86,7 +86,7 @@ static int ll_set_inode(struct inode *inode, void *opaque)
 
 	inode->i_mode = (inode->i_mode & ~S_IFMT) | (body->mbo_mode & S_IFMT);
 	if (unlikely(inode->i_mode == 0)) {
-		CERROR("Invalid inode "DFID" type\n", PFID(&lli->lli_fid));
+		CERROR("Invalid inode " DFID " type\n", PFID(&lli->lli_fid));
 		return -EINVAL;
 	}
 
@@ -134,7 +134,7 @@ struct inode *ll_iget(struct super_block *sb, ino_t hash,
 		}
 	} else if (!(inode->i_state & (I_FREEING | I_CLEAR))) {
 		rc = ll_update_inode(inode, md);
-		CDEBUG(D_VFSTRACE, "got inode: "DFID"(%p): rc = %d\n",
+		CDEBUG(D_VFSTRACE, "got inode: " DFID "(%p): rc = %d\n",
 		       PFID(&md->body->mbo_fid1), inode, rc);
 		if (rc) {
 			if (S_ISDIR(inode->i_mode))
@@ -205,7 +205,7 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 
 		if (!fid_res_name_eq(ll_inode2fid(inode),
 				     &lock->l_resource->lr_name)) {
-			LDLM_ERROR(lock, "data mismatch with object "DFID"(%p)",
+			LDLM_ERROR(lock, "data mismatch with object " DFID "(%p)",
 				   PFID(ll_inode2fid(inode)), inode);
 			LBUG();
 		}
@@ -257,7 +257,7 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 			rc = ll_layout_conf(inode, &conf);
 			if (rc < 0)
 				CDEBUG(D_INODE, "cannot invalidate layout of "
-				       DFID": rc = %d\n",
+				       DFID ": rc = %d\n",
 				       PFID(ll_inode2fid(inode)), rc);
 		}
 
@@ -274,7 +274,7 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		if ((bits & MDS_INODELOCK_UPDATE) && S_ISDIR(inode->i_mode)) {
 			struct ll_inode_info *lli = ll_i2info(inode);
 
-			CDEBUG(D_INODE, "invalidating inode "DFID" lli = %p, pfid  = "DFID"\n",
+			CDEBUG(D_INODE, "invalidating inode " DFID " lli = %p, pfid  = " DFID "\n",
 			       PFID(ll_inode2fid(inode)), lli,
 			       PFID(&lli->lli_pfid));
 
@@ -290,7 +290,7 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 				 * we have to invalidate the negative children
 				 * on master inode
 				 */
-				CDEBUG(D_INODE, "Invalidate s"DFID" m"DFID"\n",
+				CDEBUG(D_INODE, "Invalidate s" DFID " m" DFID "\n",
 				       PFID(ll_inode2fid(inode)),
 				       PFID(&lli->lli_pfid));
 
@@ -542,7 +542,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	if (dentry->d_name.len > ll_i2sbi(parent)->ll_namelen)
 		return ERR_PTR(-ENAMETOOLONG);
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p),intent=%s\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p),intent=%s\n",
 	       dentry, PFID(ll_inode2fid(parent)), parent, LL_IT2STR(it));
 
 	if (d_mountpoint(dentry))
@@ -650,7 +650,7 @@ static struct dentry *ll_lookup_nd(struct inode *parent, struct dentry *dentry,
 	struct lookup_intent *itp, it = { .it_op = IT_GETATTR };
 	struct dentry *de;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p),flags=%u\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p),flags=%u\n",
 	       dentry, PFID(ll_inode2fid(parent)), parent, flags);
 
 	/* Optimize away (CREATE && !OPEN). Let .create handle the race.
@@ -685,7 +685,7 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	struct dentry *de;
 	int rc = 0;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p),file %p,open_flags %x,mode %x opened %d\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p),file %p,open_flags %x,mode %x opened %d\n",
 	       dentry, PFID(ll_inode2fid(dir)), dir, file, open_flags, mode,
 	       *opened);
 
@@ -792,7 +792,7 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
 	 * lock on the inode.  Since we finally have an inode pointer,
 	 * stuff it in the lock.
 	 */
-	CDEBUG(D_DLMTRACE, "setting l_ast_data to inode "DFID"(%p)\n",
+	CDEBUG(D_DLMTRACE, "setting l_ast_data to inode " DFID "(%p)\n",
 	       PFID(ll_inode2fid(dir)), inode);
 	ll_set_lock_data(sbi->ll_md_exp, inode, it, NULL);
  out:
@@ -820,7 +820,7 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 	struct inode *inode;
 	int rc = 0;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p), intent=%s\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p), intent=%s\n",
 	       dentry, PFID(ll_inode2fid(dir)), dir, LL_IT2STR(it));
 
 	rc = it_open_error(DISP_OPEN_CREATE, it);
@@ -844,7 +844,7 @@ void ll_update_times(struct ptlrpc_request *request, struct inode *inode)
 	LASSERT(body);
 	if (body->mbo_valid & OBD_MD_FLMTIME &&
 	    body->mbo_mtime > LTIME_S(inode->i_mtime)) {
-		CDEBUG(D_INODE, "setting fid "DFID" mtime from %lu to %llu\n",
+		CDEBUG(D_INODE, "setting fid " DFID " mtime from %lu to %llu\n",
 		       PFID(ll_inode2fid(inode)), LTIME_S(inode->i_mtime),
 		       body->mbo_mtime);
 		LTIME_S(inode->i_mtime) = body->mbo_mtime;
@@ -942,7 +942,7 @@ static int ll_mknod(struct inode *dir, struct dentry *dchild,
 {
 	int err;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p) mode %o dev %x\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p) mode %o dev %x\n",
 	       dchild, PFID(ll_inode2fid(dir)), dir, mode,
 	       old_encode_dev(rdev));
 
@@ -982,7 +982,7 @@ static int ll_create_nd(struct inode *dir, struct dentry *dentry,
 {
 	int rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p), flags=%u, excl=%d\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p), flags=%u, excl=%d\n",
 	       dentry, PFID(ll_inode2fid(dir)), dir, mode, want_excl);
 
 	rc = ll_mknod(dir, dentry, mode, 0);
@@ -1032,7 +1032,7 @@ static int ll_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 {
 	int err;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir"DFID"(%p)\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir" DFID "(%p)\n",
 	       dentry, PFID(ll_inode2fid(dir)), dir);
 
 	if (!IS_POSIXACL(dir) || !exp_connect_umask(ll_i2mdexp(dir)))
@@ -1052,7 +1052,7 @@ static int ll_rmdir(struct inode *dir, struct dentry *dchild)
 	struct md_op_data *op_data;
 	int rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p)\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p)\n",
 	       dchild, PFID(ll_inode2fid(dir)), dir);
 
 	op_data = ll_prep_md_op_data(NULL, dir, NULL,
@@ -1082,7 +1082,7 @@ static int ll_symlink(struct inode *dir, struct dentry *dentry,
 {
 	int err;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p),target=%.*s\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p),target=%.*s\n",
 	       dentry, PFID(ll_inode2fid(dir)), dir, 3000, oldname);
 
 	err = ll_new_node(dir, dentry, oldname, S_IFLNK | 0777,
@@ -1103,7 +1103,7 @@ static int ll_link(struct dentry *old_dentry, struct inode *dir,
 	struct md_op_data *op_data;
 	int err;
 
-	CDEBUG(D_VFSTRACE, "VFS Op: inode="DFID"(%p), dir="DFID"(%p), target=%pd\n",
+	CDEBUG(D_VFSTRACE, "VFS Op: inode=" DFID "(%p), dir=" DFID "(%p), target=%pd\n",
 	       PFID(ll_inode2fid(src)), src, PFID(ll_inode2fid(dir)), dir,
 	       new_dentry);
 
@@ -1138,7 +1138,7 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 		return -EINVAL;
 
 	CDEBUG(D_VFSTRACE,
-	       "VFS Op:oldname=%pd, src_dir="DFID"(%p), newname=%pd, tgt_dir="DFID"(%p)\n",
+	       "VFS Op:oldname=%pd, src_dir=" DFID "(%p), newname=%pd, tgt_dir=" DFID "(%p)\n",
 	       src_dchild, PFID(ll_inode2fid(src)), src,
 	       tgt_dchild, PFID(ll_inode2fid(tgt)), tgt);
 
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 420f296..22dc6a5 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -327,7 +327,7 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter)
 	if ((file_offset & ~PAGE_MASK) || (count & ~PAGE_MASK))
 		return -EINVAL;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), size=%zd (max %lu), offset=%lld=%llx, pages %zd (max %lu)\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p), size=%zd (max %lu), offset=%lld=%llx, pages %zd (max %lu)\n",
 	       PFID(ll_inode2fid(inode)), inode, count, MAX_DIO_SIZE,
 	       file_offset, file_offset, count >> PAGE_SHIFT,
 	       MAX_DIO_SIZE >> PAGE_SHIFT);
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index fb7c315..9bbca01 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -528,7 +528,7 @@ static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 	}
 
 	CDEBUG(D_READA, "Handling (init) async glimpse: inode = "
-	       DFID", idx = %llu\n", PFID(&lli->lli_fid), index);
+	       DFID ", idx = %llu\n", PFID(&lli->lli_fid), index);
 
 	cl_agl(inode);
 	lli->lli_agl_index = 0;
@@ -536,7 +536,7 @@ static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 	up_write(&lli->lli_glimpse_sem);
 
 	CDEBUG(D_READA, "Handled (init) async glimpse: inode= "
-	       DFID", idx = %llu, rc = %d\n",
+	       DFID ", idx = %llu, rc = %d\n",
 	       PFID(&lli->lli_fid), index, rc);
 
 	iput(inode);
@@ -1008,7 +1008,7 @@ static int ll_statahead_thread(void *arg)
 		sai->sai_in_readpage = 0;
 		if (IS_ERR(page)) {
 			rc = PTR_ERR(page);
-			CDEBUG(D_READA, "error reading dir "DFID" at %llu/%llu: opendir_pid = %u: rc = %d\n",
+			CDEBUG(D_READA, "error reading dir " DFID " at %llu/%llu: opendir_pid = %u: rc = %d\n",
 			       PFID(ll_inode2fid(dir)), pos, sai->sai_index,
 			       lli->lli_opendir_pid, rc);
 			break;
@@ -1105,7 +1105,7 @@ static int ll_statahead_thread(void *arg)
 		if (sa_low_hit(sai)) {
 			rc = -EFAULT;
 			atomic_inc(&sbi->ll_sa_wrong);
-			CDEBUG(D_READA, "Statahead for dir "DFID" hit ratio too low: hit/miss %llu/%llu, sent/replied %llu/%llu, stopping statahead thread: pid %d\n",
+			CDEBUG(D_READA, "Statahead for dir " DFID " hit ratio too low: hit/miss %llu/%llu, sent/replied %llu/%llu, stopping statahead thread: pid %d\n",
 			       PFID(&lli->lli_fid), sai->sai_hit,
 			       sai->sai_miss, sai->sai_sent,
 			       sai->sai_replied, current_pid());
@@ -1211,7 +1211,7 @@ void ll_deauthorize_statahead(struct inode *dir, void *key)
 	LASSERT(lli->lli_opendir_key == key);
 	LASSERT(lli->lli_opendir_pid);
 
-	CDEBUG(D_READA, "deauthorize statahead for "DFID"\n",
+	CDEBUG(D_READA, "deauthorize statahead for " DFID "\n",
 	       PFID(&lli->lli_fid));
 
 	spin_lock(&lli->lli_sa_lock);
@@ -1274,7 +1274,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 			struct ll_inode_info *lli = ll_i2info(dir);
 
 			rc = PTR_ERR(page);
-			CERROR("%s: error reading dir "DFID" at %llu: opendir_pid = %u : rc = %d\n",
+			CERROR("%s: error reading dir " DFID " at %llu: opendir_pid = %u : rc = %d\n",
 			       ll_get_fsname(dir->i_sb, NULL, 0),
 			       PFID(ll_inode2fid(dir)), pos,
 			       lli->lli_opendir_pid, rc);
@@ -1471,7 +1471,7 @@ static int revalidate_statahead_dentry(struct inode *dir,
 			} else if ((*dentryp)->d_inode != inode) {
 				/* revalidate, but inode is recreated */
 				CDEBUG(D_READA,
-				       "%s: stale dentry %pd inode "DFID", statahead inode "DFID"\n",
+				       "%s: stale dentry %pd inode " DFID ", statahead inode " DFID "\n",
 				       ll_get_fsname((*dentryp)->d_inode->i_sb,
 						     NULL, 0),
 				       *dentryp,
diff --git a/drivers/staging/lustre/lustre/llite/symlink.c b/drivers/staging/lustre/lustre/llite/symlink.c
index 60aac42..3cd3348 100644
--- a/drivers/staging/lustre/lustre/llite/symlink.c
+++ b/drivers/staging/lustre/lustre/llite/symlink.c
@@ -72,7 +72,7 @@ static int ll_readlink_internal(struct inode *inode,
 	ll_finish_md_op_data(op_data);
 	if (rc) {
 		if (rc != -ENOENT)
-			CERROR("%s: inode "DFID": rc = %d\n",
+			CERROR("%s: inode " DFID ": rc = %d\n",
 			       ll_get_fsname(inode->i_sb, NULL, 0),
 			       PFID(ll_inode2fid(inode)), rc);
 		goto failed;
@@ -87,7 +87,7 @@ static int ll_readlink_internal(struct inode *inode,
 
 	LASSERT(symlen != 0);
 	if (body->mbo_eadatasize != symlen) {
-		CERROR("%s: inode "DFID": symlink length %d not expected %d\n",
+		CERROR("%s: inode " DFID ": symlink length %d not expected %d\n",
 		       ll_get_fsname(inode->i_sb, NULL, 0),
 		       PFID(ll_inode2fid(inode)), body->mbo_eadatasize - 1,
 		       symlen - 1);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index aa31bc0..c5ba265 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -325,7 +325,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 		io->ci_need_restart = vio->vui_layout_gen != gen;
 		if (io->ci_need_restart) {
 			CDEBUG(D_VFSTRACE,
-			       DFID" layout changed from %d to %d.\n",
+			       DFID " layout changed from %d to %d.\n",
 			       PFID(lu_object_fid(&obj->co_lu)),
 			       vio->vui_layout_gen, gen);
 			/* today successful restore is the only possible case */
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 8e18cf8..9bfd72e 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -70,7 +70,7 @@ static int vvp_object_print(const struct lu_env *env, void *cookie,
 	     atomic_read(&obj->vob_mmap_cnt), inode);
 	if (inode) {
 		lli = ll_i2info(inode);
-		(*p)(env, cookie, "%lu/%u %o %u %d %p "DFID,
+		(*p)(env, cookie, "%lu/%u %o %u %d %p " DFID,
 		     inode->i_ino, inode->i_generation, inode->i_mode,
 		     inode->i_nlink, atomic_read(&inode->i_count),
 		     lli->lli_clob, PFID(&lli->lli_fid));
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 6187bff..bd30abd 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -195,7 +195,7 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 	LASSERT(inode);
 	LASSERT(name);
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), xattr %s\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p), xattr %s\n",
 	       PFID(ll_inode2fid(inode)), inode, name);
 
 	if (!strcmp(name, "lov")) {
@@ -370,7 +370,7 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 #endif
 	int rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p)\n",
 	       PFID(ll_inode2fid(inode)), inode);
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_GETXATTR, 1);
@@ -523,7 +523,7 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 
 	LASSERT(inode);
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p)\n",
 	       PFID(ll_inode2fid(inode)), inode);
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_LISTXATTR, 1);
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index 38f75f6..82cf421 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -311,7 +311,7 @@ static int ll_xattr_find_get_lock(struct inode *inode,
 
 	if (rc < 0) {
 		CDEBUG(D_CACHE,
-		       "md_intent_lock failed with %d for fid "DFID"\n",
+		       "md_intent_lock failed with %d for fid " DFID "\n",
 		       rc, PFID(ll_inode2fid(inode)));
 		mutex_unlock(&lli->lli_xattrs_enq_lock);
 		return rc;
@@ -365,7 +365,7 @@ static int ll_xattr_cache_refill(struct inode *inode, struct lookup_intent *oit)
 	}
 
 	if (oit->it_status < 0) {
-		CDEBUG(D_CACHE, "getxattr intent returned %d for fid "DFID"\n",
+		CDEBUG(D_CACHE, "getxattr intent returned %d for fid " DFID "\n",
 		       oit->it_status, PFID(ll_inode2fid(inode)));
 		rc = oit->it_status;
 		/* xattr data is so large that we don't want to cache it */
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_fld.c b/drivers/staging/lustre/lustre/lmv/lmv_fld.c
index a5265f9..6f8070f 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_fld.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_fld.c
@@ -70,7 +70,7 @@ int lmv_fld_lookup(struct lmv_obd *lmv, const struct lu_fid *fid, u32 *mds)
 		return rc;
 	}
 
-	CDEBUG(D_INODE, "FLD lookup got mds #%x for fid="DFID"\n",
+	CDEBUG(D_INODE, "FLD lookup got mds #%x for fid=" DFID "\n",
 	       *mds, PFID(fid));
 
 	if (*mds >= lmv->desc.ld_tgt_count) {
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index aa42066..f49db6c 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -213,7 +213,7 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 		lockh = (struct lustre_handle *)&it.it_lock_handle;
 		if (rc > 0 && !req) {
 			/* slave inode is still valid */
-			CDEBUG(D_INODE, "slave "DFID" is still valid.\n",
+			CDEBUG(D_INODE, "slave " DFID " is still valid.\n",
 			       PFID(&fid));
 			rc = 0;
 		} else {
@@ -435,7 +435,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 			if (IS_ERR(tgt))
 				return PTR_ERR(tgt);
 
-			CDEBUG(D_INODE, "Try other stripes " DFID"\n",
+			CDEBUG(D_INODE, "Try other stripes " DFID "\n",
 			       PFID(&oinfo->lmo_fid));
 
 			op_data->op_fid1 = oinfo->lmo_fid;
@@ -479,7 +479,7 @@ int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 
 	LASSERT(fid_is_sane(&op_data->op_fid1));
 
-	CDEBUG(D_INODE, "INTENT LOCK '%s' for "DFID" '%*s' on "DFID"\n",
+	CDEBUG(D_INODE, "INTENT LOCK '%s' for " DFID " '%*s' on " DFID "\n",
 	       LL_IT2STR(it), PFID(&op_data->op_fid2),
 	       (int)op_data->op_namelen, op_data->op_name,
 	       PFID(&op_data->op_fid1));
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index b222dfa..63a10a9 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -673,7 +673,7 @@ static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
 		*ptr = '/';
 	}
 
-	CDEBUG(D_INFO, "%s: get path %s "DFID" rec: %llu ln: %u\n",
+	CDEBUG(D_INFO, "%s: get path %s " DFID " rec: %llu ln: %u\n",
 	       tgt->ltd_exp->exp_obd->obd_name,
 	       gf->gf_path, PFID(&gf->gf_fid), gf->gf_recno,
 	       gf->gf_linkno);
@@ -693,7 +693,7 @@ static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
 	}
 
 	if (!fid_is_sane(&gf->gf_fid)) {
-		CERROR("%s: invalid FID "DFID": rc = %d\n",
+		CERROR("%s: invalid FID " DFID ": rc = %d\n",
 		       tgt->ltd_exp->exp_obd->obd_name,
 		       PFID(&gf->gf_fid), -EINVAL);
 		rc = -EINVAL;
@@ -1508,7 +1508,7 @@ static int lmv_null_inode(struct obd_export *exp, const struct lu_fid *fid)
 	if (rc)
 		return rc;
 
-	CDEBUG(D_INODE, "CBDATA for "DFID"\n", PFID(fid));
+	CDEBUG(D_INODE, "CBDATA for " DFID "\n", PFID(fid));
 
 	/*
 	 * With DNE every object can have two locks in different namespaces:
@@ -1540,7 +1540,7 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
-	CDEBUG(D_INODE, "CLOSE "DFID"\n", PFID(&op_data->op_fid1));
+	CDEBUG(D_INODE, "CLOSE " DFID "\n", PFID(&op_data->op_fid1));
 	return md_close(tgt->ltd_exp, op_data, mod, request);
 }
 
@@ -1672,7 +1672,7 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
-	CDEBUG(D_INODE, "CREATE name '%.*s' on "DFID" -> mds #%x\n",
+	CDEBUG(D_INODE, "CREATE name '%.*s' on " DFID " -> mds #%x\n",
 	       (int)op_data->op_namelen, op_data->op_name,
 	       PFID(&op_data->op_fid1), op_data->op_mds);
 
@@ -1694,7 +1694,7 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		CDEBUG(D_CONFIG, "Server doesn't support striped dirs\n");
 	}
 
-	CDEBUG(D_INODE, "CREATE obj "DFID" -> mds #%x\n",
+	CDEBUG(D_INODE, "CREATE obj " DFID " -> mds #%x\n",
 	       PFID(&op_data->op_fid1), op_data->op_mds);
 
 	op_data->op_flags |= MF_MDC_CANCEL_FID1;
@@ -1704,7 +1704,7 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	if (rc == 0) {
 		if (!*request)
 			return rc;
-		CDEBUG(D_INODE, "Created - "DFID"\n", PFID(&op_data->op_fid2));
+		CDEBUG(D_INODE, "Created - " DFID "\n", PFID(&op_data->op_fid2));
 	}
 	return rc;
 }
@@ -1724,7 +1724,7 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	if (rc)
 		return rc;
 
-	CDEBUG(D_INODE, "ENQUEUE '%s' on "DFID"\n",
+	CDEBUG(D_INODE, "ENQUEUE '%s' on " DFID "\n",
 	       LL_IT2STR(it), PFID(&op_data->op_fid1));
 
 	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
@@ -1769,7 +1769,7 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	if (body->mbo_valid & OBD_MD_MDS) {
 		struct lu_fid rid = body->mbo_fid1;
 
-		CDEBUG(D_INODE, "Request attrs for "DFID"\n",
+		CDEBUG(D_INODE, "Request attrs for " DFID "\n",
 		       PFID(&rid));
 
 		tgt = lmv_find_target(lmv, &rid);
@@ -1818,13 +1818,13 @@ static int lmv_early_cancel(struct obd_export *exp, struct lmv_tgt_desc *tgt,
 	}
 
 	if (tgt->ltd_idx != op_tgt) {
-		CDEBUG(D_INODE, "EARLY_CANCEL on "DFID"\n", PFID(fid));
+		CDEBUG(D_INODE, "EARLY_CANCEL on " DFID "\n", PFID(fid));
 		policy.l_inodebits.bits = bits;
 		rc = md_cancel_unused(tgt->ltd_exp, fid, &policy,
 				      mode, LCF_ASYNC, NULL);
 	} else {
 		CDEBUG(D_INODE,
-		       "EARLY_CANCEL skip operation target %d on "DFID"\n",
+		       "EARLY_CANCEL skip operation target %d on " DFID "\n",
 		       op_tgt, PFID(fid));
 		op_data->op_flags |= flag;
 		rc = 0;
@@ -1851,7 +1851,7 @@ static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 
 	LASSERT(op_data->op_namelen != 0);
 
-	CDEBUG(D_INODE, "LINK "DFID":%*s to "DFID"\n",
+	CDEBUG(D_INODE, "LINK " DFID ":%*s to " DFID "\n",
 	       PFID(&op_data->op_fid2), (int)op_data->op_namelen,
 	       op_data->op_name, PFID(&op_data->op_fid1));
 
@@ -1901,7 +1901,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 
 	LASSERT(oldlen != 0);
 
-	CDEBUG(D_INODE, "RENAME %.*s in "DFID":%d to %.*s in "DFID":%d\n",
+	CDEBUG(D_INODE, "RENAME %.*s in " DFID ":%d to %.*s in " DFID ":%d\n",
 	       (int)oldlen, old, PFID(&op_data->op_fid1),
 	       op_data->op_mea1 ? op_data->op_mea1->lsm_md_stripe_count : 0,
 	       (int)newlen, new, PFID(&op_data->op_fid2),
@@ -1916,7 +1916,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_cap = cfs_curproc_cap_pack();
 
 	if (op_data->op_cli_flags & CLI_MIGRATE) {
-		LASSERTF(fid_is_sane(&op_data->op_fid3), "invalid FID "DFID"\n",
+		LASSERTF(fid_is_sane(&op_data->op_fid3), "invalid FID " DFID "\n",
 			 PFID(&op_data->op_fid3));
 
 		if (op_data->op_mea1) {
@@ -2069,7 +2069,7 @@ static int lmv_setattr(struct obd_export *exp, struct md_op_data *op_data,
 	if (rc)
 		return rc;
 
-	CDEBUG(D_INODE, "SETATTR for "DFID", valid 0x%x\n",
+	CDEBUG(D_INODE, "SETATTR for " DFID ", valid 0x%x\n",
 	       PFID(&op_data->op_fid1), op_data->op_attr.ia_valid);
 
 	op_data->op_flags |= MF_MDC_CANCEL_FID1;
@@ -2577,7 +2577,7 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	if (likely(!(body->mbo_valid & OBD_MD_MDS)))
 		return rc;
 
-	CDEBUG(D_INODE, "%s: try unlink to another MDT for "DFID"\n",
+	CDEBUG(D_INODE, "%s: try unlink to another MDT for " DFID "\n",
 	       exp->exp_obd->obd_name, PFID(&body->mbo_fid1));
 
 	/* This is a remote object, try remote MDT, Note: it may
@@ -2781,7 +2781,7 @@ static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
 				    &lsm->lsm_md_oinfo[i].lmo_mds);
 		if (rc)
 			return rc;
-		CDEBUG(D_INFO, "unpack fid #%d "DFID"\n", i,
+		CDEBUG(D_INFO, "unpack fid #%d " DFID "\n", i,
 		       PFID(&lsm->lsm_md_oinfo[i].lmo_fid));
 	}
 
@@ -2925,7 +2925,7 @@ static enum ldlm_mode lmv_lock_match(struct obd_export *exp, __u64 flags,
 	int tgt;
 	u32 i;
 
-	CDEBUG(D_INODE, "Lock match for "DFID"\n", PFID(fid));
+	CDEBUG(D_INODE, "Lock match for " DFID "\n", PFID(fid));
 
 	/*
 	 * With DNE every object can have two locks in different namespaces:
@@ -2937,7 +2937,7 @@ static enum ldlm_mode lmv_lock_match(struct obd_export *exp, __u64 flags,
 	     i < lmv->desc.ld_tgt_count;
 	     i++, tgt = (tgt + 1) % lmv->desc.ld_tgt_count) {
 		if (tgt < 0) {
-			CDEBUG(D_HA, "%s: "DFID" is inaccessible: rc = %d\n",
+			CDEBUG(D_HA, "%s: " DFID " is inaccessible: rc = %d\n",
 			       obd->obd_name, PFID(fid), tgt);
 			tgt = 0;
 		}
@@ -3148,7 +3148,7 @@ static int lmv_merge_attr(struct obd_export *exp,
 	for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
 		struct inode *inode = lsm->lsm_md_oinfo[i].lmo_root;
 
-		CDEBUG(D_INFO, ""DFID" size %llu, blocks %llu nlink %u, atime %lu ctime %lu, mtime %lu.\n",
+		CDEBUG(D_INFO, "" DFID " size %llu, blocks %llu nlink %u, atime %lu ctime %lu, mtime %lu.\n",
 		       PFID(&lsm->lsm_md_oinfo[i].lmo_fid),
 		       i_size_read(inode), (unsigned long long)inode->i_blocks,
 		       inode->i_nlink, LTIME_S(inode->i_atime),
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index df77b25..babf39a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -1021,7 +1021,7 @@ int lov_io_init_empty(const struct lu_env *env, struct cl_object *obj,
 		break;
 	case CIT_FAULT:
 		result = -EFAULT;
-		CERROR("Page fault on a file without stripes: "DFID"\n",
+		CERROR("Page fault on a file without stripes: " DFID "\n",
 		       PFID(lu_object_fid(&obj->co_lu)));
 		break;
 	}
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index 391dfd2..034b4fc 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -57,7 +57,7 @@ int lov_merge_lvb_kms(struct lov_stripe_md *lsm,
 	assert_spin_locked(&lsm->lsm_lock);
 	LASSERT(lsm->lsm_lock_owner == current_pid());
 
-	CDEBUG(D_INODE, "MDT ID "DOSTID" initial value: s=%llu m=%llu a=%llu c=%llu b=%llu\n",
+	CDEBUG(D_INODE, "MDT ID " DOSTID " initial value: s=%llu m=%llu a=%llu c=%llu b=%llu\n",
 	       POSTID(&lsm->lsm_oi), lvb->lvb_size, lvb->lvb_mtime,
 	       lvb->lvb_atime, lvb->lvb_ctime, lvb->lvb_blocks);
 	for (i = 0; i < lsm->lsm_stripe_count; i++) {
@@ -89,7 +89,7 @@ int lov_merge_lvb_kms(struct lov_stripe_md *lsm,
 		if (loi->loi_lvb.lvb_ctime > current_ctime)
 			current_ctime = loi->loi_lvb.lvb_ctime;
 
-		CDEBUG(D_INODE, "MDT ID "DOSTID" on OST[%u]: s=%llu m=%llu a=%llu c=%llu b=%llu\n",
+		CDEBUG(D_INODE, "MDT ID " DOSTID " on OST[%u]: s=%llu m=%llu a=%llu c=%llu b=%llu\n",
 		       POSTID(&lsm->lsm_oi), loi->loi_ost_idx,
 		       loi->loi_lvb.lvb_size, loi->loi_lvb.lvb_mtime,
 		       loi->loi_lvb.lvb_atime, loi->loi_lvb.lvb_ctime,
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index ab3ecfe..d31895e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -153,8 +153,7 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 	subhdr = cl_object_header(stripe);
 
 	oinfo = lov->lo_lsm->lsm_oinfo[idx];
-	CDEBUG(D_INODE, DFID"@%p[%d] -> "DFID"@%p: ostid: "DOSTID
-	       " idx: %d gen: %d\n",
+	CDEBUG(D_INODE, DFID "@%p[%d] -> " DFID "@%p: ostid: " DOSTID " idx: %d gen: %d\n",
 	       PFID(&subhdr->coh_lu.loh_fid), subhdr, idx,
 	       PFID(&hdr->coh_lu.loh_fid), hdr, POSTID(&oinfo->loi_oi),
 	       oinfo->loi_ost_idx, oinfo->loi_ost_gen);
@@ -757,7 +756,7 @@ static int lov_layout_change(const struct lu_env *unused,
 
 	LASSERT(0 <= llt && llt < ARRAY_SIZE(lov_dispatch));
 
-	CDEBUG(D_INODE, DFID" from %s to %s\n",
+	CDEBUG(D_INODE, DFID " from %s to %s\n",
 	       PFID(lu_object_fid(lov2lu(lov))),
 	       llt2str(lov->lo_type), llt2str(llt));
 
@@ -904,7 +903,7 @@ static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 out:
 	lov_conf_unlock(lov);
 	lov_lsm_put(lsm);
-	CDEBUG(D_INODE, DFID" lo_layout_invalid=%d\n",
+	CDEBUG(D_INODE, DFID " lo_layout_invalid=%d\n",
 	       PFID(lu_object_fid(lov2lu(lov))), lov->lo_layout_invalid);
 	return result;
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index e6727ce..638b764 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -56,7 +56,7 @@ void lov_dump_lmm_common(int level, void *lmmp)
 	struct ost_id	oi;
 
 	lmm_oi_le_to_cpu(&oi, &lmm->lmm_oi);
-	CDEBUG(level, "objid "DOSTID", magic 0x%08x, pattern %#x\n",
+	CDEBUG(level, "objid " DOSTID ", magic 0x%08x, pattern %#x\n",
 	       POSTID(&oi), le32_to_cpu(lmm->lmm_magic),
 	       le32_to_cpu(lmm->lmm_pattern));
 	CDEBUG(level, "stripe_size %u, stripe_count %u, layout_gen %u\n",
@@ -80,7 +80,7 @@ static void lov_dump_lmm_objects(int level, struct lov_ost_data *lod,
 		struct ost_id	oi;
 
 		ostid_le_to_cpu(&lod->l_ost_oi, &oi);
-		CDEBUG(level, "stripe %u idx %u subobj "DOSTID"\n", i,
+		CDEBUG(level, "stripe %u idx %u subobj " DOSTID "\n", i,
 		       le32_to_cpu(lod->l_ost_idx), POSTID(&oi));
 	}
 }
@@ -95,7 +95,7 @@ void lov_dump_lmm_v1(int level, struct lov_mds_md_v1 *lmm)
 void lov_dump_lmm_v3(int level, struct lov_mds_md_v3 *lmm)
 {
 	lov_dump_lmm_common(level, lmm);
-	CDEBUG(level, "pool_name "LOV_POOLNAMEF"\n", lmm->lmm_pool_name);
+	CDEBUG(level, "pool_name " LOV_POOLNAMEF "\n", lmm->lmm_pool_name);
 	lov_dump_lmm_objects(level, lmm->lmm_objects,
 			     le16_to_cpu(lmm->lmm_stripe_count));
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 7daa867..1952bbd 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -429,7 +429,7 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 						poolname, new_pool,
 						&pool_proc_operations);
 	if (IS_ERR_OR_NULL(new_pool->pool_debugfs_entry)) {
-		CWARN("Cannot add debugfs pool entry "LOV_POOLNAMEF"\n",
+		CWARN("Cannot add debugfs pool entry " LOV_POOLNAMEF "\n",
 		      poolname);
 		new_pool->pool_debugfs_entry = NULL;
 		lov_pool_putref(new_pool);
@@ -450,7 +450,7 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 		goto out_err;
 	}
 
-	CDEBUG(D_CONFIG, LOV_POOLNAMEF" is pool #%d\n",
+	CDEBUG(D_CONFIG, LOV_POOLNAMEF " is pool #%d\n",
 	       poolname, lov->lov_pool_count);
 
 	return 0;
@@ -531,7 +531,7 @@ int lov_pool_add(struct obd_device *obd, char *poolname, char *ostname)
 	if (rc)
 		goto out;
 
-	CDEBUG(D_CONFIG, "Added %s to "LOV_POOLNAMEF" as member %d\n",
+	CDEBUG(D_CONFIG, "Added %s to " LOV_POOLNAMEF " as member %d\n",
 	       ostname, poolname,  pool_tgt_count(pool));
 
 out:
@@ -575,7 +575,7 @@ int lov_pool_remove(struct obd_device *obd, char *poolname, char *ostname)
 
 	lov_ost_pool_remove(&pool->pool_obds, lov_idx);
 
-	CDEBUG(D_CONFIG, "%s removed from "LOV_POOLNAMEF"\n", ostname,
+	CDEBUG(D_CONFIG, "%s removed from " LOV_POOLNAMEF "\n", ostname,
 	       poolname);
 
 out:
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 9e06078..3eb66ce 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -830,7 +830,7 @@ int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		ptlrpc_req_finished(req);
 		resends++;
 
-		CDEBUG(D_HA, "%s: resend:%d op:%d "DFID"/"DFID"\n",
+		CDEBUG(D_HA, "%s: resend:%d op:%d " DFID "/" DFID "\n",
 		       obddev->obd_name, resends, it->it_op,
 		       PFID(&op_data->op_fid1), PFID(&op_data->op_fid2));
 
@@ -933,7 +933,7 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 
 		LASSERTF(fid_res_name_eq(&mdt_body->mbo_fid1,
 					 &lock->l_resource->lr_name),
-			 "Lock res_id: "DLDLMRES", fid: "DFID"\n",
+			 "Lock res_id: " DLDLMRES ", fid: " DFID "\n",
 			 PLDLMRES(lock->l_resource), PFID(&mdt_body->mbo_fid1));
 		LDLM_LOCK_PUT(lock);
 
@@ -1063,7 +1063,7 @@ int mdc_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 
 	LASSERT(it);
 
-	CDEBUG(D_DLMTRACE, "(name: %.*s,"DFID") in obj "DFID
+	CDEBUG(D_DLMTRACE, "(name: %.*s," DFID ") in obj " DFID
 		", intent: %s flags %#Lo\n", (int)op_data->op_namelen,
 		op_data->op_name, PFID(&op_data->op_fid2),
 		PFID(&op_data->op_fid1), ldlm_it2str(it->it_op),
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index 07b1684..2287bd4 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -227,7 +227,7 @@ int mdc_create(struct obd_export *exp, struct md_op_data *op_data,
 		ptlrpc_req_finished(req);
 		resends++;
 
-		CDEBUG(D_HA, "%s: resend:%d create on "DFID"/"DFID"\n",
+		CDEBUG(D_HA, "%s: resend:%d create on " DFID "/" DFID "\n",
 		       exp->exp_obd->obd_name, resends,
 		       PFID(&op_data->op_fid1), PFID(&op_data->op_fid2));
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 6bc2fb8..1a3fa1b 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -105,7 +105,7 @@ static int mdc_getstatus(struct obd_export *exp, struct lu_fid *rootfid)
 
 	*rootfid = body->mbo_fid1;
 	CDEBUG(D_NET,
-	       "root fid="DFID", last_committed=%llu\n",
+	       "root fid=" DFID ", last_committed=%llu\n",
 	       PFID(rootfid),
 	       lustre_msg_get_last_committed(req->rq_repmsg));
 out:
@@ -713,7 +713,7 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 		/* allocate a FID for volatile file */
 		rc = mdc_fid_alloc(NULL, exp, &op_data->op_fid2, op_data);
 		if (rc < 0) {
-			CERROR("%s: "DFID" failed to allocate FID: %d\n",
+			CERROR("%s: " DFID " failed to allocate FID: %d\n",
 			       obd->obd_name, PFID(&op_data->op_fid1), rc);
 			/* save the errcode and proceed to close */
 			saved_rc = rc;
@@ -753,7 +753,7 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 		/*
 		 * TODO: repeat close after errors
 		 */
-		CWARN("%s: close of FID "DFID" failed, file reference will be dropped when this client unmounts or is evicted\n",
+		CWARN("%s: close of FID " DFID " failed, file reference will be dropped when this client unmounts or is evicted\n",
 		      obd->obd_name, PFID(&op_data->op_fid1));
 		rc = -ENOMEM;
 		goto out;
@@ -1254,7 +1254,7 @@ static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
 		ptlrpc_req_finished(enq_req);
 
 	if (rc < 0) {
-		CERROR("%s: "DFID" lock enqueue fails: rc = %d\n",
+		CERROR("%s: " DFID " lock enqueue fails: rc = %d\n",
 		       exp->exp_obd->obd_name, PFID(&op_data->op_fid1), rc);
 		return rc;
 	}
@@ -1298,7 +1298,7 @@ static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
 					    rp_param.rp_hash64),
 			       mdc_read_page_remote, &rp_param);
 	if (IS_ERR(page)) {
-		CERROR("%s: read cache page: "DFID" at %llu: rc %ld\n",
+		CERROR("%s: read cache page: " DFID " at %llu: rc %ld\n",
 		       exp->exp_obd->obd_name, PFID(&op_data->op_fid1),
 		       rp_param.rp_off, PTR_ERR(page));
 		rc = PTR_ERR(page);
@@ -1308,7 +1308,7 @@ static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
 	wait_on_page_locked(page);
 	(void)kmap(page);
 	if (!PageUptodate(page)) {
-		CERROR("%s: page not updated: "DFID" at %llu: rc %d\n",
+		CERROR("%s: page not updated: " DFID " at %llu: rc %d\n",
 		       exp->exp_obd->obd_name, PFID(&op_data->op_fid1),
 		       rp_param.rp_off, -5);
 		goto fail;
@@ -1316,7 +1316,7 @@ static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
 	if (!PageChecked(page))
 		SetPageChecked(page);
 	if (PageError(page)) {
-		CERROR("%s: page error: "DFID" at %llu: rc %d\n",
+		CERROR("%s: page error: " DFID " at %llu: rc %d\n",
 		       exp->exp_obd->obd_name, PFID(&op_data->op_fid1),
 		       rp_param.rp_off, -5);
 		goto fail;
@@ -1436,7 +1436,7 @@ static int mdc_ioc_fid2path(struct obd_export *exp, struct getinfo_fid2path *gf)
 	memcpy(key, KEY_FID2PATH, sizeof(KEY_FID2PATH));
 	memcpy(key + cfs_size_round(sizeof(KEY_FID2PATH)), gf, sizeof(*gf));
 
-	CDEBUG(D_IOCTL, "path get "DFID" from %llu #%d\n",
+	CDEBUG(D_IOCTL, "path get " DFID " from %llu #%d\n",
 	       PFID(&gf->gf_fid), gf->gf_recno, gf->gf_linkno);
 
 	if (!fid_is_sane(&gf->gf_fid)) {
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 6a76605..eee0b66 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -800,7 +800,7 @@ static int mgc_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		/* We've given up the lock, prepare ourselves to update. */
 		LDLM_DEBUG(lock, "MGC cancel CB");
 
-		CDEBUG(D_MGC, "Lock res "DLDLMRES" (%.8s)\n",
+		CDEBUG(D_MGC, "Lock res " DLDLMRES " (%.8s)\n",
 		       PLDLMRES(lock->l_resource),
 		       (char *)&lock->l_resource->lr_name.name[0]);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index 9d7b593..a343e3a 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -246,7 +246,7 @@ void cl_lock_descr_print(const struct lu_env *env, void *cookie,
 	const struct lu_fid  *fid;
 
 	fid = lu_object_fid(&descr->cld_obj->co_lu);
-	(*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
+	(*printer)(env, cookie, DDESCR "@" DFID, PDESCR(descr), PFID(fid));
 }
 EXPORT_SYMBOL(cl_lock_descr_print);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 71fcc4c..6b8c41b 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -193,7 +193,7 @@ struct cl_page *cl_page_find(const struct lu_env *env,
 
 	hdr = cl_object_header(o);
 
-	CDEBUG(D_PAGE, "%lu@"DFID" %p %lx %d\n",
+	CDEBUG(D_PAGE, "%lu@" DFID " %p %lx %d\n",
 	       idx, PFID(&hdr->coh_lu.loh_fid), vmpage, vmpage->private, type);
 	/* fast path. */
 	if (type == CPT_CACHEABLE) {
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_cat.c b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
index ce8e2f6..8f1533c 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_cat.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
@@ -78,7 +78,7 @@ static int llog_cat_id2handle(const struct lu_env *env,
 		if (ostid_id(&cgl->lgl_oi) == ostid_id(&logid->lgl_oi) &&
 		    ostid_seq(&cgl->lgl_oi) == ostid_seq(&logid->lgl_oi)) {
 			if (cgl->lgl_ogen != logid->lgl_ogen) {
-				CERROR("%s: log "DOSTID" generation %x != %x\n",
+				CERROR("%s: log " DOSTID " generation %x != %x\n",
 				       loghandle->lgh_ctxt->loc_obd->obd_name,
 				       POSTID(&logid->lgl_oi), cgl->lgl_ogen,
 				       logid->lgl_ogen);
@@ -95,7 +95,7 @@ static int llog_cat_id2handle(const struct lu_env *env,
 	rc = llog_open(env, cathandle->lgh_ctxt, &loghandle, logid, NULL,
 		       LLOG_OPEN_EXISTS);
 	if (rc < 0) {
-		CERROR("%s: error opening log id "DOSTID":%x: rc = %d\n",
+		CERROR("%s: error opening log id " DOSTID ":%x: rc = %d\n",
 		       cathandle->lgh_ctxt->loc_obd->obd_name,
 		       POSTID(&logid->lgl_oi), logid->lgl_ogen, rc);
 		return rc;
@@ -152,13 +152,13 @@ static int llog_cat_process_cb(const struct lu_env *env,
 		CERROR("invalid record in catalog\n");
 		return -EINVAL;
 	}
-	CDEBUG(D_HA, "processing log "DOSTID":%x at index %u of catalog "
-	       DOSTID"\n", POSTID(&lir->lid_id.lgl_oi), lir->lid_id.lgl_ogen,
+	CDEBUG(D_HA, "processing log " DOSTID ":%x at index %u of catalog "
+	       DOSTID "\n", POSTID(&lir->lid_id.lgl_oi), lir->lid_id.lgl_ogen,
 	       rec->lrh_index, POSTID(&cat_llh->lgh_id.lgl_oi));
 
 	rc = llog_cat_id2handle(env, cat_llh, &llh, &lir->lid_id);
 	if (rc) {
-		CERROR("%s: cannot find handle for llog "DOSTID": %d\n",
+		CERROR("%s: cannot find handle for llog " DOSTID ": %d\n",
 		       cat_llh->lgh_ctxt->loc_obd->obd_name,
 		       POSTID(&lir->lid_id.lgl_oi), rc);
 		return rc;
@@ -204,7 +204,7 @@ static int llog_cat_process_or_fork(const struct lu_env *env,
 	if (llh->llh_cat_idx > cat_llh->lgh_last_idx) {
 		struct llog_process_cat_data cd;
 
-		CWARN("catlog "DOSTID" crosses index zero\n",
+		CWARN("catlog " DOSTID " crosses index zero\n",
 		      POSTID(&cat_llh->lgh_id.lgl_oi));
 
 		cd.lpcd_first_idx = llh->llh_cat_idx;
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
index 723c212..016046d 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_swab.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
@@ -44,7 +44,7 @@
 static void print_llogd_body(struct llogd_body *d)
 {
 	CDEBUG(D_OTHER, "llogd body: %p\n", d);
-	CDEBUG(D_OTHER, "\tlgd_logid.lgl_oi: "DOSTID"\n",
+	CDEBUG(D_OTHER, "\tlgd_logid.lgl_oi: " DOSTID "\n",
 	       POSTID(&d->lgd_logid.lgl_oi));
 	CDEBUG(D_OTHER, "\tlgd_logid.lgl_ogen: %#x\n", d->lgd_logid.lgl_ogen);
 	CDEBUG(D_OTHER, "\tlgd_ctxt_idx: %#x\n", d->lgd_ctxt_idx);
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 94c8ae5..b7ba351 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -512,7 +512,7 @@ void lu_object_header_print(const struct lu_env *env, void *cookie,
 			    lu_printer_t printer,
 			    const struct lu_object_header *hdr)
 {
-	(*printer)(env, cookie, "header@%p[%#lx, %d, "DFID"%s%s%s]",
+	(*printer)(env, cookie, "header@%p[%#lx, %d, " DFID "%s%s%s]",
 		   hdr, hdr->loh_flags, atomic_read(&hdr->loh_ref),
 		   PFID(&hdr->loh_fid),
 		   hlist_unhashed(&hdr->loh_hash) ? "" : " hash",
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index d476831..1c4a8fe 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -277,7 +277,7 @@ static int echo_page_print(const struct lu_env *env,
 {
 	struct echo_page *ep = cl2echo_page(slice);
 
-	(*printer)(env, cookie, LUSTRE_ECHO_CLIENT_NAME"-page@%p %d vm@%p\n",
+	(*printer)(env, cookie, LUSTRE_ECHO_CLIENT_NAME "-page@%p %d vm@%p\n",
 		   ep, mutex_is_locked(&ep->ep_lock),
 		   slice->cpl_page->cp_vmpage);
 	return 0;
@@ -1121,7 +1121,7 @@ static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
 	}
 	cl_echo_object_put(eco);
 
-	CDEBUG(D_INFO, "oa oid "DOSTID"\n", POSTID(&oa->o_oi));
+	CDEBUG(D_INFO, "oa oid " DOSTID "\n", POSTID(&oa->o_oi));
 
  failed:
 	if (created && rc)
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 33d769c..4db8116 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -472,7 +472,7 @@ static void osc_extent_insert(struct osc_object *obj, struct osc_extent *ext)
 		else if (ext->oe_start > tmp->oe_end)
 			n = &(*n)->rb_right;
 		else
-			EASSERTF(0, tmp, EXTSTR"\n", EXTPARA(ext));
+			EASSERTF(0, tmp, EXTSTR "\n", EXTPARA(ext));
 	}
 	rb_link_node(&ext->oe_node, parent, n);
 	rb_insert_color(&ext->oe_node, &obj->oo_root);
@@ -690,7 +690,7 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 	/* grants has been allocated by caller */
 	LASSERTF(*grants >= chunksize + cli->cl_extent_tax,
 		 "%u/%u/%u.\n", *grants, chunksize, cli->cl_extent_tax);
-	LASSERTF((max_end - cur->oe_start) < max_pages, EXTSTR"\n",
+	LASSERTF((max_end - cur->oe_start) < max_pages, EXTSTR "\n",
 		 EXTPARA(cur));
 
 restart:
@@ -709,7 +709,7 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 		/* if covering by different locks, no chance to match */
 		if (olck->ols_dlmlock != ext->oe_dlmlock) {
 			EASSERTF(!overlapped(ext, cur), ext,
-				 EXTSTR"\n", EXTPARA(cur));
+				 EXTSTR "\n", EXTPARA(cur));
 
 			ext = next_extent(ext);
 			continue;
@@ -732,7 +732,7 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 			 */
 			EASSERTF((ext->oe_start <= cur->oe_start &&
 				  ext->oe_end >= cur->oe_end),
-				 ext, EXTSTR"\n", EXTPARA(cur));
+				 ext, EXTSTR "\n", EXTPARA(cur));
 
 			if (ext->oe_state > OES_CACHE || ext->oe_fsync_wait) {
 				/* for simplicity, we wait for this extent to
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index d8aa3fb..922d0cb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1227,8 +1227,7 @@ static int check_write_checksum(struct obdo *oa,
 		msg = "changed in transit AND doesn't match the original - likely false positive due to mmap IO (bug 11742)"
 			;
 
-	LCONSOLE_ERROR_MSG(0x132, "BAD WRITE CHECKSUM: %s: from %s inode "DFID
-			   " object "DOSTID" extent [%llu-%llu]\n",
+	LCONSOLE_ERROR_MSG(0x132, "BAD WRITE CHECKSUM: %s: from %s inode " DFID " object " DOSTID " extent [%llu-%llu]\n",
 			   msg, libcfs_nid2str(peer->nid),
 			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_seq : (__u64)0,
 			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_oid : 0,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 6466974..1c77792 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -367,8 +367,8 @@ void ptlrpc_at_adj_net_latency(struct ptlrpc_request *req,
 		 */
 		CDEBUG((lustre_msg_get_flags(req->rq_reqmsg) & MSG_RESENT) ?
 		       D_ADAPTTO : D_WARNING,
-		       "Reported service time %u > total measured time "
-		       CFS_DURATION_T"\n", service_time,
+		       "Reported service time %u > total measured time " CFS_DURATION_T "\n",
+		       service_time,
 		       (long)(now - req->rq_sent));
 		return;
 	}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 9456a18..55e8696e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -2089,7 +2089,7 @@ static void dump_obdo(struct obdo *oa)
 
 	CDEBUG(D_RPCTRACE, "obdo: o_valid = %08x\n", valid);
 	if (valid & OBD_MD_FLID)
-		CDEBUG(D_RPCTRACE, "obdo: id = "DOSTID"\n", POSTID(&oa->o_oi));
+		CDEBUG(D_RPCTRACE, "obdo: id = " DOSTID "\n", POSTID(&oa->o_oi));
 	if (valid & OBD_MD_FLFID)
 		CDEBUG(D_RPCTRACE, "obdo: o_parent_seq = %#llx\n",
 		       oa->o_parent_seq);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index b8091c1..759aa6c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -1565,7 +1565,7 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 
 	/* req_in handling should/must be fast */
 	if (ktime_get_real_seconds() - req->rq_arrival_time.tv_sec > 5)
-		DEBUG_REQ(D_WARNING, req, "Slow req_in handling "CFS_DURATION_T"s",
+		DEBUG_REQ(D_WARNING, req, "Slow req_in handling " CFS_DURATION_T "s",
 			  (long)(ktime_get_real_seconds() -
 				 req->rq_arrival_time.tv_sec));
 
-- 
1.8.3.1
