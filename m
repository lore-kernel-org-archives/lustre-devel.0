From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:52:51 -0400
Subject: [lustre-devel] [PATCH 15/32] staging: lustre: mdt: add mbo_ prefix
	to members of struct mdt_body
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Rename each member of struct mdt_body, adding the prefix mbo_.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/10202
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   74 +++---
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   14 +-
 drivers/staging/lustre/lustre/llite/dir.c          |   30 +-
 drivers/staging/lustre/lustre/llite/file.c         |   20 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  110 ++++----
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |    6 +-
 drivers/staging/lustre/lustre/llite/namei.c        |   44 ++--
 drivers/staging/lustre/lustre/llite/statahead.c    |    4 +-
 drivers/staging/lustre/lustre/llite/symlink.c      |    6 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |   14 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |   12 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |   38 ++--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   16 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   62 +++---
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   32 ++--
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |    4 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   52 ++--
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   56 ++--
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |  268 ++++++++++----------
 20 files changed, 432 insertions(+), 432 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index bbf0c8d..400ab3c 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2097,43 +2097,43 @@ enum md_transient_state {
 };
 
 struct mdt_body {
-	struct lu_fid  fid1;
-	struct lu_fid  fid2;
-	struct lustre_handle handle;
-	__u64	  valid;
-	__u64	  size;   /* Offset, in the case of MDS_READPAGE */
-	__s64	  mtime;
-	__s64	  atime;
-	__s64	  ctime;
-	__u64	  blocks; /* XID, in the case of MDS_READPAGE */
-	__u64	  ioepoch;
-	__u64	  t_state; /* transient file state defined in
-			    * enum md_transient_state
-			    * was "ino" until 2.4.0
-			    */
-	__u32	  fsuid;
-	__u32	  fsgid;
-	__u32	  capability;
-	__u32	  mode;
-	__u32	  uid;
-	__u32	  gid;
-	__u32	  flags; /* from vfs for pin/unpin, LUSTRE_BFLAG close */
-	__u32	  rdev;
-	__u32	  nlink; /* #bytes to read in the case of MDS_READPAGE */
-	__u32	  unused2; /* was "generation" until 2.4.0 */
-	__u32	  suppgid;
-	__u32	  eadatasize;
-	__u32	  aclsize;
-	__u32	  max_mdsize;
-	__u32	  max_cookiesize;
-	__u32	  uid_h; /* high 32-bits of uid, for FUID */
-	__u32	  gid_h; /* high 32-bits of gid, for FUID */
-	__u32	  padding_5; /* also fix lustre_swab_mdt_body */
-	__u64	  padding_6;
-	__u64	  padding_7;
-	__u64	  padding_8;
-	__u64	  padding_9;
-	__u64	  padding_10;
+	struct lu_fid mbo_fid1;
+	struct lu_fid mbo_fid2;
+	struct lustre_handle mbo_handle;
+	__u64	mbo_valid;
+	__u64	mbo_size;	/* Offset, in the case of MDS_READPAGE */
+	__s64	mbo_mtime;
+	__s64	mbo_atime;
+	__s64	mbo_ctime;
+	__u64	mbo_blocks;	/* XID, in the case of MDS_READPAGE */
+	__u64	mbo_ioepoch;
+	__u64	mbo_t_state;	/* transient file state defined in
+				 * enum md_transient_state
+				 * was "ino" until 2.4.0
+				 */
+	__u32	mbo_fsuid;
+	__u32	mbo_fsgid;
+	__u32	mbo_capability;
+	__u32	mbo_mode;
+	__u32	mbo_uid;
+	__u32	mbo_gid;
+	__u32	mbo_flags;
+	__u32	mbo_rdev;
+	__u32	mbo_nlink;	/* #bytes to read in the case of MDS_READPAGE */
+	__u32	mbo_unused2;	/* was "generation" until 2.4.0 */
+	__u32	mbo_suppgid;
+	__u32	mbo_eadatasize;
+	__u32	mbo_aclsize;
+	__u32	mbo_max_mdsize;
+	__u32	mbo_max_cookiesize;
+	__u32	mbo_uid_h;	/* high 32-bits of uid, for FUID */
+	__u32	mbo_gid_h;	/* high 32-bits of gid, for FUID */
+	__u32	mbo_padding_5;	/* also fix lustre_swab_mdt_body */
+	__u64	mbo_padding_6;
+	__u64	mbo_padding_7;
+	__u64	mbo_padding_8;
+	__u64	mbo_padding_9;
+	__u64	mbo_padding_10;
 }; /* 216 */
 
 void lustre_swab_mdt_body(struct mdt_body *b);
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index bf6f87a..9549fb4 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -163,18 +163,18 @@ static inline void mdc_put_rpc_lock(struct mdc_rpc_lock *lck,
 static inline void mdc_update_max_ea_from_body(struct obd_export *exp,
 					       struct mdt_body *body)
 {
-	if (body->valid & OBD_MD_FLMODEASIZE) {
+	if (body->mbo_valid & OBD_MD_FLMODEASIZE) {
 		struct client_obd *cli = &exp->exp_obd->u.cli;
 
-		if (cli->cl_max_mds_easize < body->max_mdsize) {
-			cli->cl_max_mds_easize = body->max_mdsize;
+		if (cli->cl_max_mds_easize < body->mbo_max_mdsize) {
+			cli->cl_max_mds_easize = body->mbo_max_mdsize;
 			cli->cl_default_mds_easize =
-			    min_t(__u32, body->max_mdsize, PAGE_SIZE);
+			    min_t(__u32, body->mbo_max_mdsize, PAGE_SIZE);
 		}
-		if (cli->cl_max_mds_cookiesize < body->max_cookiesize) {
-			cli->cl_max_mds_cookiesize = body->max_cookiesize;
+		if (cli->cl_max_mds_cookiesize < body->mbo_max_cookiesize) {
+			cli->cl_max_mds_cookiesize = body->mbo_max_cookiesize;
 			cli->cl_default_mds_cookiesize =
-			    min_t(__u32, body->max_cookiesize, PAGE_SIZE);
+			    min_t(__u32, body->mbo_max_cookiesize, PAGE_SIZE);
 		}
 	}
 }
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index a1b5143..9c7fa8f 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -188,8 +188,8 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 	} else if (rc == 0) {
 		body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
 		/* Checked by mdc_readpage() */
-		if (body->valid & OBD_MD_FLSIZE)
-			i_size_write(inode, body->size);
+		if (body->mbo_valid & OBD_MD_FLSIZE)
+			i_size_write(inode, body->mbo_size);
 
 		nrdpgs = (request->rq_bulk->bd_nob_transferred+PAGE_SIZE-1)
 			 >> PAGE_SHIFT;
@@ -894,9 +894,9 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 
-	lmmsize = body->eadatasize;
+	lmmsize = body->mbo_eadatasize;
 
-	if (!(body->valid & (OBD_MD_FLEASIZE | OBD_MD_FLDIREA)) ||
+	if (!(body->mbo_valid & (OBD_MD_FLEASIZE | OBD_MD_FLDIREA)) ||
 	    lmmsize == 0) {
 		rc = -ENODATA;
 		goto out;
@@ -1639,18 +1639,18 @@ skip_lmm:
 			lstat_t st = { 0 };
 
 			st.st_dev     = inode->i_sb->s_dev;
-			st.st_mode    = body->mode;
-			st.st_nlink   = body->nlink;
-			st.st_uid     = body->uid;
-			st.st_gid     = body->gid;
-			st.st_rdev    = body->rdev;
-			st.st_size    = body->size;
+			st.st_mode    = body->mbo_mode;
+			st.st_nlink   = body->mbo_nlink;
+			st.st_uid     = body->mbo_uid;
+			st.st_gid     = body->mbo_gid;
+			st.st_rdev    = body->mbo_rdev;
+			st.st_size    = body->mbo_size;
 			st.st_blksize = PAGE_SIZE;
-			st.st_blocks  = body->blocks;
-			st.st_atime   = body->atime;
-			st.st_mtime   = body->mtime;
-			st.st_ctime   = body->ctime;
-			st.st_ino     = cl_fid_build_ino(&body->fid1,
+			st.st_blocks  = body->mbo_blocks;
+			st.st_atime   = body->mbo_atime;
+			st.st_mtime   = body->mbo_mtime;
+			st.st_ctime   = body->mbo_ctime;
+			st.st_ino     = cl_fid_build_ino(&body->mbo_fid1,
 							 sbi->ll_flags &
 							 LL_SBI_32BIT_API);
 
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index c34455b..8d690d7 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -200,7 +200,7 @@ static int ll_close_inode_openhandle(struct obd_export *md_exp,
 		struct mdt_body *body;
 
 		body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-		if (!(body->valid & OBD_MD_FLRELEASED))
+		if (!(body->mbo_valid & OBD_MD_FLRELEASED))
 			rc = -EBUSY;
 	}
 
@@ -482,8 +482,8 @@ static int ll_och_fill(struct obd_export *md_exp, struct lookup_intent *it,
 	struct mdt_body *body;
 
 	body = req_capsule_server_get(&it->it_request->rq_pill, &RMF_MDT_BODY);
-	och->och_fh = body->handle;
-	och->och_fid = body->fid1;
+	och->och_fh = body->mbo_handle;
+	och->och_fid = body->mbo_fid1;
 	och->och_lease_handle.cookie = it->it_lock_handle;
 	och->och_magic = OBD_CLIENT_HANDLE_MAGIC;
 	och->och_flags = it->it_flags;
@@ -511,7 +511,7 @@ static int ll_local_open(struct file *file, struct lookup_intent *it,
 
 		body = req_capsule_server_get(&it->it_request->rq_pill,
 					      &RMF_MDT_BODY);
-		ll_ioepoch_open(lli, body->ioepoch);
+		ll_ioepoch_open(lli, body->mbo_ioepoch);
 	}
 
 	LUSTRE_FPRIVATE(file) = fd;
@@ -1451,9 +1451,9 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 
-	lmmsize = body->eadatasize;
+	lmmsize = body->mbo_eadatasize;
 
-	if (!(body->valid & (OBD_MD_FLEASIZE | OBD_MD_FLDIREA)) ||
+	if (!(body->mbo_valid & (OBD_MD_FLEASIZE | OBD_MD_FLDIREA)) ||
 	    lmmsize == 0) {
 		rc = -ENODATA;
 		goto out;
@@ -1484,13 +1484,13 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 		 */
 		if (lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_V1)) {
 			lustre_swab_lov_user_md_v1((struct lov_user_md_v1 *)lmm);
-			if (S_ISREG(body->mode))
+			if (S_ISREG(body->mbo_mode))
 				lustre_swab_lov_user_md_objects(
 				 ((struct lov_user_md_v1 *)lmm)->lmm_objects,
 				 stripe_count);
 		} else if (lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_V3)) {
 			lustre_swab_lov_user_md_v3((struct lov_user_md_v3 *)lmm);
-			if (S_ISREG(body->mode))
+			if (S_ISREG(body->mbo_mode))
 				lustre_swab_lov_user_md_objects(
 				 ((struct lov_user_md_v3 *)lmm)->lmm_objects,
 				 stripe_count);
@@ -2861,7 +2861,7 @@ int ll_get_fid_by_name(struct inode *parent, const char *name,
 		goto out_req;
 	}
 	if (fid)
-		*fid = body->fid1;
+		*fid = body->mbo_fid1;
 out_req:
 	ptlrpc_req_finished(req);
 	return rc;
@@ -3583,7 +3583,7 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 		goto out;
 	}
 
-	lmmsize = body->eadatasize;
+	lmmsize = body->mbo_eadatasize;
 	if (lmmsize == 0) /* empty layout */ {
 		rc = 0;
 		goto out;
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 396e4e4..eed464b 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -154,7 +154,7 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 	int result = 0;
 	int refcheck;
 
-	LASSERT(md->body->valid & OBD_MD_FLID);
+	LASSERT(md->body->mbo_valid & OBD_MD_FLID);
 	LASSERT(S_ISREG(inode->i_mode));
 
 	env = cl_env_get(&refcheck);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index dd44ee8..5f6343a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1035,7 +1035,7 @@ static struct inode *ll_iget_anon_dir(struct super_block *sb,
 		struct lmv_stripe_md *lsm = md->lmv;
 
 		inode->i_mode = (inode->i_mode & ~S_IFMT) |
-				(body->mode & S_IFMT);
+				(body->mbo_mode & S_IFMT);
 		LASSERTF(S_ISDIR(inode->i_mode), "Not slave inode "DFID"\n",
 			 PFID(fid));
 
@@ -1051,7 +1051,7 @@ static struct inode *ll_iget_anon_dir(struct super_block *sb,
 
 		LASSERT(lsm);
 		/* master object FID */
-		lli->lli_pfid = body->fid1;
+		lli->lli_pfid = body->mbo_fid1;
 		CDEBUG(D_INODE, "lli %p slave "DFID" master "DFID"\n",
 		       lli, PFID(fid), PFID(&lli->lli_pfid));
 		unlock_new_inode(inode);
@@ -1320,8 +1320,8 @@ static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data,
 	op_data->op_attr.ia_valid = ia_valid;
 
 	/* Extract epoch data if obtained. */
-	op_data->op_handle = md.body->handle;
-	op_data->op_ioepoch = md.body->ioepoch;
+	op_data->op_handle = md.body->mbo_handle;
+	op_data->op_ioepoch = md.body->mbo_ioepoch;
 
 	rc = ll_update_inode(inode, &md);
 	ptlrpc_req_finished(request);
@@ -1689,7 +1689,7 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 	struct lov_stripe_md *lsm = md->lsm;
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 
-	LASSERT((lsm != NULL) == ((body->valid & OBD_MD_FLEASIZE) != 0));
+	LASSERT((lsm != NULL) == ((body->mbo_valid & OBD_MD_FLEASIZE) != 0));
 	if (lsm) {
 		if (!lli->lli_has_smd &&
 		    !(sbi->ll_flags & LL_SBI_LAYOUT_LOCK))
@@ -1709,7 +1709,7 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 	}
 
 #ifdef CONFIG_FS_POSIX_ACL
-	if (body->valid & OBD_MD_FLACL) {
+	if (body->mbo_valid & OBD_MD_FLACL) {
 		spin_lock(&lli->lli_lock);
 		if (lli->lli_posix_acl)
 			posix_acl_release(lli->lli_posix_acl);
@@ -1717,65 +1717,65 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 		spin_unlock(&lli->lli_lock);
 	}
 #endif
-	inode->i_ino = cl_fid_build_ino(&body->fid1,
+	inode->i_ino = cl_fid_build_ino(&body->mbo_fid1,
 					sbi->ll_flags & LL_SBI_32BIT_API);
-	inode->i_generation = cl_fid_build_gen(&body->fid1);
+	inode->i_generation = cl_fid_build_gen(&body->mbo_fid1);
 
-	if (body->valid & OBD_MD_FLATIME) {
-		if (body->atime > LTIME_S(inode->i_atime))
-			LTIME_S(inode->i_atime) = body->atime;
-		lli->lli_atime = body->atime;
+	if (body->mbo_valid & OBD_MD_FLATIME) {
+		if (body->mbo_atime > LTIME_S(inode->i_atime))
+			LTIME_S(inode->i_atime) = body->mbo_atime;
+		lli->lli_atime = body->mbo_atime;
 	}
-	if (body->valid & OBD_MD_FLMTIME) {
-		if (body->mtime > LTIME_S(inode->i_mtime)) {
+	if (body->mbo_valid & OBD_MD_FLMTIME) {
+		if (body->mbo_mtime > LTIME_S(inode->i_mtime)) {
 			CDEBUG(D_INODE, "setting ino %lu mtime from %lu to %llu\n",
 			       inode->i_ino, LTIME_S(inode->i_mtime),
-			       body->mtime);
-			LTIME_S(inode->i_mtime) = body->mtime;
+			       body->mbo_mtime);
+			LTIME_S(inode->i_mtime) = body->mbo_mtime;
 		}
-		lli->lli_mtime = body->mtime;
+		lli->lli_mtime = body->mbo_mtime;
 	}
-	if (body->valid & OBD_MD_FLCTIME) {
-		if (body->ctime > LTIME_S(inode->i_ctime))
-			LTIME_S(inode->i_ctime) = body->ctime;
-		lli->lli_ctime = body->ctime;
+	if (body->mbo_valid & OBD_MD_FLCTIME) {
+		if (body->mbo_ctime > LTIME_S(inode->i_ctime))
+			LTIME_S(inode->i_ctime) = body->mbo_ctime;
+		lli->lli_ctime = body->mbo_ctime;
 	}
-	if (body->valid & OBD_MD_FLMODE)
-		inode->i_mode = (inode->i_mode & S_IFMT)|(body->mode & ~S_IFMT);
-	if (body->valid & OBD_MD_FLTYPE)
-		inode->i_mode = (inode->i_mode & ~S_IFMT)|(body->mode & S_IFMT);
+	if (body->mbo_valid & OBD_MD_FLMODE)
+		inode->i_mode = (inode->i_mode & S_IFMT)|(body->mbo_mode & ~S_IFMT);
+	if (body->mbo_valid & OBD_MD_FLTYPE)
+		inode->i_mode = (inode->i_mode & ~S_IFMT)|(body->mbo_mode & S_IFMT);
 	LASSERT(inode->i_mode != 0);
 	if (S_ISREG(inode->i_mode))
 		inode->i_blkbits = min(PTLRPC_MAX_BRW_BITS + 1,
 				       LL_MAX_BLKSIZE_BITS);
 	else
 		inode->i_blkbits = inode->i_sb->s_blocksize_bits;
-	if (body->valid & OBD_MD_FLUID)
-		inode->i_uid = make_kuid(&init_user_ns, body->uid);
-	if (body->valid & OBD_MD_FLGID)
-		inode->i_gid = make_kgid(&init_user_ns, body->gid);
-	if (body->valid & OBD_MD_FLFLAGS)
-		inode->i_flags = ll_ext_to_inode_flags(body->flags);
-	if (body->valid & OBD_MD_FLNLINK)
-		set_nlink(inode, body->nlink);
-	if (body->valid & OBD_MD_FLRDEV)
-		inode->i_rdev = old_decode_dev(body->rdev);
-
-	if (body->valid & OBD_MD_FLID) {
+	if (body->mbo_valid & OBD_MD_FLUID)
+		inode->i_uid = make_kuid(&init_user_ns, body->mbo_uid);
+	if (body->mbo_valid & OBD_MD_FLGID)
+		inode->i_gid = make_kgid(&init_user_ns, body->mbo_gid);
+	if (body->mbo_valid & OBD_MD_FLFLAGS)
+		inode->i_flags = ll_ext_to_inode_flags(body->mbo_flags);
+	if (body->mbo_valid & OBD_MD_FLNLINK)
+		set_nlink(inode, body->mbo_nlink);
+	if (body->mbo_valid & OBD_MD_FLRDEV)
+		inode->i_rdev = old_decode_dev(body->mbo_rdev);
+
+	if (body->mbo_valid & OBD_MD_FLID) {
 		/* FID shouldn't be changed! */
 		if (fid_is_sane(&lli->lli_fid)) {
-			LASSERTF(lu_fid_eq(&lli->lli_fid, &body->fid1),
+			LASSERTF(lu_fid_eq(&lli->lli_fid, &body->mbo_fid1),
 				 "Trying to change FID "DFID" to the "DFID", inode "DFID"(%p)\n",
-				 PFID(&lli->lli_fid), PFID(&body->fid1),
+				 PFID(&lli->lli_fid), PFID(&body->mbo_fid1),
 				 PFID(ll_inode2fid(inode)), inode);
 		} else {
-			lli->lli_fid = body->fid1;
+			lli->lli_fid = body->mbo_fid1;
 		}
 	}
 
 	LASSERT(fid_seq(&lli->lli_fid) != 0);
 
-	if (body->valid & OBD_MD_FLSIZE) {
+	if (body->mbo_valid & OBD_MD_FLSIZE) {
 		if (exp_connect_som(ll_i2mdexp(inode)) &&
 		    S_ISREG(inode->i_mode)) {
 			struct lustre_handle lockh;
@@ -1802,7 +1802,7 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 					/* Use old size assignment to avoid
 					 * deadlock bz14138 & bz14326
 					 */
-					i_size_write(inode, body->size);
+					i_size_write(inode, body->mbo_size);
 					spin_lock(&lli->lli_lock);
 					lli->lli_flags |= LLIF_MDS_SIZE_LOCK;
 					spin_unlock(&lli->lli_lock);
@@ -1813,18 +1813,18 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 			/* Use old size assignment to avoid
 			 * deadlock bz14138 & bz14326
 			 */
-			i_size_write(inode, body->size);
+			i_size_write(inode, body->mbo_size);
 
 			CDEBUG(D_VFSTRACE, "inode=%lu, updating i_size %llu\n",
-			       inode->i_ino, (unsigned long long)body->size);
+			       inode->i_ino, (unsigned long long)body->mbo_size);
 		}
 
-		if (body->valid & OBD_MD_FLBLOCKS)
-			inode->i_blocks = body->blocks;
+		if (body->mbo_valid & OBD_MD_FLBLOCKS)
+			inode->i_blocks = body->mbo_blocks;
 	}
 
-	if (body->valid & OBD_MD_TSTATE) {
-		if (body->t_state & MS_RESTORE)
+	if (body->mbo_valid & OBD_MD_TSTATE) {
+		if (body->mbo_t_state & MS_RESTORE)
 			lli->lli_flags |= LLIF_FILE_RESTORING;
 	}
 
@@ -1936,7 +1936,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 
 		body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 
-		flags = body->flags;
+		flags = body->mbo_flags;
 
 		ptlrpc_req_finished(req);
 
@@ -2118,9 +2118,9 @@ void ll_open_cleanup(struct super_block *sb, struct ptlrpc_request *open_req)
 	if (!op_data)
 		return;
 
-	op_data->op_fid1 = body->fid1;
-	op_data->op_ioepoch = body->ioepoch;
-	op_data->op_handle = body->handle;
+	op_data->op_fid1 = body->mbo_fid1;
+	op_data->op_ioepoch = body->mbo_ioepoch;
+	op_data->op_handle = body->mbo_handle;
 	op_data->op_mod_time = get_seconds();
 	md_close(exp, op_data, NULL, &close_req);
 	ptlrpc_req_finished(close_req);
@@ -2152,15 +2152,15 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 		 * At this point server returns to client's same fid as client
 		 * generated for creating. So using ->fid1 is okay here.
 		 */
-		if (!fid_is_sane(&md.body->fid1)) {
+		if (!fid_is_sane(&md.body->mbo_fid1)) {
 			CERROR("%s: Fid is insane " DFID "\n",
 			       ll_get_fsname(sb, NULL, 0),
-			       PFID(&md.body->fid1));
+			       PFID(&md.body->mbo_fid1));
 			rc = -EINVAL;
 			goto out;
 		}
 
-		*inode = ll_iget(sb, cl_fid_build_ino(&md.body->fid1,
+		*inode = ll_iget(sb, cl_fid_build_ino(&md.body->mbo_fid1,
 					     sbi->ll_flags & LL_SBI_32BIT_API),
 				 &md);
 		if (IS_ERR(*inode)) {
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 06a8199..ac96d89 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -343,10 +343,10 @@ int ll_dir_get_parent_fid(struct inode *dir, struct lu_fid *parent_fid)
 	 * LU-3952: MDT may lost the FID of its parent, we should not crash
 	 * the NFS server, ll_iget_for_nfs() will handle the error.
 	 */
-	if (body->valid & OBD_MD_FLID) {
+	if (body->mbo_valid & OBD_MD_FLID) {
 		CDEBUG(D_INFO, "parent for " DFID " is " DFID "\n",
-		       PFID(ll_inode2fid(dir)), PFID(&body->fid1));
-		*parent_fid = body->fid1;
+		       PFID(ll_inode2fid(dir)), PFID(&body->mbo_fid1));
+		*parent_fid = body->mbo_fid1;
 	}
 
 	ptlrpc_req_finished(req);
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 581b083..ac0f442 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -56,12 +56,12 @@ static int ll_test_inode(struct inode *inode, void *opaque)
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct lustre_md     *md = opaque;
 
-	if (unlikely(!(md->body->valid & OBD_MD_FLID))) {
+	if (unlikely(!(md->body->mbo_valid & OBD_MD_FLID))) {
 		CERROR("MDS body missing FID\n");
 		return 0;
 	}
 
-	if (!lu_fid_eq(&lli->lli_fid, &md->body->fid1))
+	if (!lu_fid_eq(&lli->lli_fid, &md->body->mbo_fid1))
 		return 0;
 
 	return 1;
@@ -72,20 +72,20 @@ static int ll_set_inode(struct inode *inode, void *opaque)
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct mdt_body *body = ((struct lustre_md *)opaque)->body;
 
-	if (unlikely(!(body->valid & OBD_MD_FLID))) {
+	if (unlikely(!(body->mbo_valid & OBD_MD_FLID))) {
 		CERROR("MDS body missing FID\n");
 		return -EINVAL;
 	}
 
-	lli->lli_fid = body->fid1;
-	if (unlikely(!(body->valid & OBD_MD_FLTYPE))) {
+	lli->lli_fid = body->mbo_fid1;
+	if (unlikely(!(body->mbo_valid & OBD_MD_FLTYPE))) {
 		CERROR("Can not initialize inode " DFID
 		       " without object type: valid = %#llx\n",
-		       PFID(&lli->lli_fid), body->valid);
+		       PFID(&lli->lli_fid), body->mbo_valid);
 		return -EINVAL;
 	}
 
-	inode->i_mode = (inode->i_mode & ~S_IFMT) | (body->mode & S_IFMT);
+	inode->i_mode = (inode->i_mode & ~S_IFMT) | (body->mbo_mode & S_IFMT);
 	if (unlikely(inode->i_mode == 0)) {
 		CERROR("Invalid inode "DFID" type\n", PFID(&lli->lli_fid));
 		return -EINVAL;
@@ -131,7 +131,7 @@ struct inode *ll_iget(struct super_block *sb, ino_t hash,
 	} else if (!(inode->i_state & (I_FREEING | I_CLEAR))) {
 		rc = ll_update_inode(inode, md);
 		CDEBUG(D_VFSTRACE, "got inode: "DFID"(%p): rc = %d\n",
-		       PFID(&md->body->fid1), inode, rc);
+		       PFID(&md->body->mbo_fid1), inode, rc);
 		if (rc) {
 			make_bad_inode(inode);
 			iput(inode);
@@ -774,16 +774,16 @@ void ll_update_times(struct ptlrpc_request *request, struct inode *inode)
 						       &RMF_MDT_BODY);
 
 	LASSERT(body);
-	if (body->valid & OBD_MD_FLMTIME &&
-	    body->mtime > LTIME_S(inode->i_mtime)) {
+	if (body->mbo_valid & OBD_MD_FLMTIME &&
+	    body->mbo_mtime > LTIME_S(inode->i_mtime)) {
 		CDEBUG(D_INODE, "setting fid "DFID" mtime from %lu to %llu\n",
 		       PFID(ll_inode2fid(inode)), LTIME_S(inode->i_mtime),
-		       body->mtime);
-		LTIME_S(inode->i_mtime) = body->mtime;
+		       body->mbo_mtime);
+		LTIME_S(inode->i_mtime) = body->mbo_mtime;
 	}
-	if (body->valid & OBD_MD_FLCTIME &&
-	    body->ctime > LTIME_S(inode->i_ctime))
-		LTIME_S(inode->i_ctime) = body->ctime;
+	if (body->mbo_valid & OBD_MD_FLCTIME &&
+	    body->mbo_ctime > LTIME_S(inode->i_ctime))
+		LTIME_S(inode->i_ctime) = body->mbo_ctime;
 }
 
 static int ll_new_node(struct inode *dir, struct dentry *dentry,
@@ -899,10 +899,10 @@ int ll_objects_destroy(struct ptlrpc_request *request, struct inode *dir)
 
 	/* req is swabbed so this is safe */
 	body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
-	if (!(body->valid & OBD_MD_FLEASIZE))
+	if (!(body->mbo_valid & OBD_MD_FLEASIZE))
 		return 0;
 
-	if (body->eadatasize == 0) {
+	if (body->mbo_eadatasize == 0) {
 		CERROR("OBD_MD_FLEASIZE set but eadatasize zero\n");
 		rc = -EPROTO;
 		goto out;
@@ -914,10 +914,10 @@ int ll_objects_destroy(struct ptlrpc_request *request, struct inode *dir)
 	 * check it is complete and sensible.
 	 */
 	eadata = req_capsule_server_sized_get(&request->rq_pill, &RMF_MDT_MD,
-					      body->eadatasize);
+					      body->mbo_eadatasize);
 	LASSERT(eadata);
 
-	rc = obd_unpackmd(ll_i2dtexp(dir), &lsm, eadata, body->eadatasize);
+	rc = obd_unpackmd(ll_i2dtexp(dir), &lsm, eadata, body->mbo_eadatasize);
 	if (rc < 0) {
 		CERROR("obd_unpackmd: %d\n", rc);
 		goto out;
@@ -931,10 +931,10 @@ int ll_objects_destroy(struct ptlrpc_request *request, struct inode *dir)
 	}
 
 	oa->o_oi = lsm->lsm_oi;
-	oa->o_mode = body->mode & S_IFMT;
+	oa->o_mode = body->mbo_mode & S_IFMT;
 	oa->o_valid = OBD_MD_FLID | OBD_MD_FLTYPE | OBD_MD_FLGROUP;
 
-	if (body->valid & OBD_MD_FLCOOKIE) {
+	if (body->mbo_valid & OBD_MD_FLCOOKIE) {
 		oa->o_valid |= OBD_MD_FLCOOKIE;
 		oti.oti_logcookies =
 			req_capsule_server_sized_get(&request->rq_pill,
@@ -943,7 +943,7 @@ int ll_objects_destroy(struct ptlrpc_request *request, struct inode *dir)
 						     lsm->lsm_stripe_count);
 		if (!oti.oti_logcookies) {
 			oa->o_valid &= ~OBD_MD_FLCOOKIE;
-			body->valid &= ~OBD_MD_FLCOOKIE;
+			body->mbo_valid &= ~OBD_MD_FLCOOKIE;
 		}
 	}
 
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 0a28599..f7fa2c7 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -630,7 +630,7 @@ static void ll_post_statahead(struct ll_statahead_info *sai)
 		/* XXX: No fid in reply, this is probably cross-ref case.
 		 * SA can't handle it yet.
 		 */
-		if (body->valid & OBD_MD_MDS) {
+		if (body->mbo_valid & OBD_MD_MDS) {
 			rc = -EAGAIN;
 			goto out;
 		}
@@ -639,7 +639,7 @@ static void ll_post_statahead(struct ll_statahead_info *sai)
 		 * revalidate.
 		 */
 		/* unlinked and re-created with the same name */
-		if (unlikely(!lu_fid_eq(&minfo->mi_data.op_fid2, &body->fid1))) {
+		if (unlikely(!lu_fid_eq(&minfo->mi_data.op_fid2, &body->mbo_fid1))) {
 			entry->se_inode = NULL;
 			iput(child);
 			child = NULL;
diff --git a/drivers/staging/lustre/lustre/llite/symlink.c b/drivers/staging/lustre/lustre/llite/symlink.c
index 4601be9..47fb799 100644
--- a/drivers/staging/lustre/lustre/llite/symlink.c
+++ b/drivers/staging/lustre/lustre/llite/symlink.c
@@ -80,17 +80,17 @@ static int ll_readlink_internal(struct inode *inode,
 	}
 
 	body = req_capsule_server_get(&(*request)->rq_pill, &RMF_MDT_BODY);
-	if ((body->valid & OBD_MD_LINKNAME) == 0) {
+	if ((body->mbo_valid & OBD_MD_LINKNAME) == 0) {
 		CERROR("OBD_MD_LINKNAME not set on reply\n");
 		rc = -EPROTO;
 		goto failed;
 	}
 
 	LASSERT(symlen != 0);
-	if (body->eadatasize != symlen) {
+	if (body->mbo_eadatasize != symlen) {
 		CERROR("%s: inode "DFID": symlink length %d not expected %d\n",
 		       ll_get_fsname(inode->i_sb, NULL, 0),
-		       PFID(ll_inode2fid(inode)), body->eadatasize - 1,
+		       PFID(ll_inode2fid(inode)), body->mbo_eadatasize - 1,
 		       symlen - 1);
 		rc = -EPROTO;
 		goto failed;
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 146da6b..f252c26 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -263,32 +263,32 @@ getxattr_nocache:
 
 		/* only detect the xattr size */
 		if (size == 0) {
-			rc = body->eadatasize;
+			rc = body->mbo_eadatasize;
 			goto out;
 		}
 
-		if (size < body->eadatasize) {
+		if (size < body->mbo_eadatasize) {
 			CERROR("server bug: replied size %u > %u\n",
-			       body->eadatasize, (int)size);
+			       body->mbo_eadatasize, (int)size);
 			rc = -ERANGE;
 			goto out;
 		}
 
-		if (body->eadatasize == 0) {
+		if (body->mbo_eadatasize == 0) {
 			rc = -ENODATA;
 			goto out;
 		}
 
 		/* do not need swab xattr data */
 		xdata = req_capsule_server_sized_get(&req->rq_pill, &RMF_EADATA,
-						     body->eadatasize);
+						     body->mbo_eadatasize);
 		if (!xdata) {
 			rc = -EFAULT;
 			goto out;
 		}
 
-		memcpy(buffer, xdata, body->eadatasize);
-		rc = body->eadatasize;
+		memcpy(buffer, xdata, body->mbo_eadatasize);
+		rc = body->mbo_eadatasize;
 	}
 
 out_xattr:
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index 8089da8..b66542c 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -380,25 +380,25 @@ static int ll_xattr_cache_refill(struct inode *inode, struct lookup_intent *oit)
 	}
 	/* do not need swab xattr data */
 	xdata = req_capsule_server_sized_get(&req->rq_pill, &RMF_EADATA,
-					     body->eadatasize);
+					     body->mbo_eadatasize);
 	xval = req_capsule_server_sized_get(&req->rq_pill, &RMF_EAVALS,
-					    body->aclsize);
+					    body->mbo_aclsize);
 	xsizes = req_capsule_server_sized_get(&req->rq_pill, &RMF_EAVALS_LENS,
-					      body->max_mdsize * sizeof(__u32));
+					      body->mbo_max_mdsize * sizeof(__u32));
 	if (!xdata || !xval || !xsizes) {
 		CERROR("wrong setxattr reply\n");
 		rc = -EPROTO;
 		goto out_destroy;
 	}
 
-	xtail = xdata + body->eadatasize;
-	xvtail = xval + body->aclsize;
+	xtail = xdata + body->mbo_eadatasize;
+	xvtail = xval + body->mbo_aclsize;
 
 	CDEBUG(D_CACHE, "caching: xdata=%p xtail=%p\n", xdata, xtail);
 
 	ll_xattr_cache_init(lli);
 
-	for (i = 0; i < body->max_mdsize; i++) {
+	for (i = 0; i < body->mbo_max_mdsize; i++) {
 		CDEBUG(D_CACHE, "caching [%s]=%.*s\n", xdata, *xsizes, xval);
 		/* Perform consistency checks: attr names and vals in pill */
 		if (!memchr(xdata, 0, xtail - xdata)) {
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 7f81e78..761ab24 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -69,7 +69,7 @@ static int lmv_intent_remote(struct obd_export *exp, void *lmm,
 	if (!body)
 		return -EPROTO;
 
-	LASSERT((body->valid & OBD_MD_MDS));
+	LASSERT((body->mbo_valid & OBD_MD_MDS));
 
 	/*
 	 * Unfortunately, we have to lie to MDC/MDS to retrieve
@@ -88,9 +88,9 @@ static int lmv_intent_remote(struct obd_export *exp, void *lmm,
 		it->it_request = NULL;
 	}
 
-	LASSERT(fid_is_sane(&body->fid1));
+	LASSERT(fid_is_sane(&body->mbo_fid1));
 
-	tgt = lmv_find_target(lmv, &body->fid1);
+	tgt = lmv_find_target(lmv, &body->mbo_fid1);
 	if (IS_ERR(tgt)) {
 		rc = PTR_ERR(tgt);
 		goto out;
@@ -102,7 +102,7 @@ static int lmv_intent_remote(struct obd_export *exp, void *lmm,
 		goto out;
 	}
 
-	op_data->op_fid1 = body->fid1;
+	op_data->op_fid1 = body->mbo_fid1;
 	/* Sent the parent FID to the remote MDT */
 	if (parent_fid) {
 		/* The parent fid is only for remote open to
@@ -114,12 +114,12 @@ static int lmv_intent_remote(struct obd_export *exp, void *lmm,
 		/* Add object FID to op_fid3, in case it needs to check stale
 		 * (M_CHECK_STALE), see mdc_finish_intent_lock
 		 */
-		op_data->op_fid3 = body->fid1;
+		op_data->op_fid3 = body->mbo_fid1;
 	}
 
 	op_data->op_bias = MDS_CROSS_REF;
 	CDEBUG(D_INODE, "REMOTE_INTENT with fid="DFID" -> mds #%d\n",
-	       PFID(&body->fid1), tgt->ltd_idx);
+	       PFID(&body->mbo_fid1), tgt->ltd_idx);
 
 	rc = md_intent_lock(tgt->ltd_exp, op_data, lmm, lmmsize, it,
 			    flags, &req, cb_blocking, extra_lock_flags);
@@ -227,9 +227,9 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 						      &RMF_MDT_BODY);
 			LASSERT(body);
 
-			if (unlikely(body->nlink < 2)) {
+			if (unlikely(body->mbo_nlink < 2)) {
 				CERROR("%s: nlink %d < 2 corrupt stripe %d "DFID":" DFID"\n",
-				       obd->obd_name, body->nlink, i,
+				       obd->obd_name, body->mbo_nlink, i,
 				       PFID(&lsm->lsm_md_oinfo[i].lmo_fid),
 				       PFID(&lsm->lsm_md_oinfo[0].lmo_fid));
 
@@ -245,11 +245,11 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 				goto cleanup;
 			}
 
-			i_size_write(inode, body->size);
-			set_nlink(inode, body->nlink);
-			LTIME_S(inode->i_atime) = body->atime;
-			LTIME_S(inode->i_ctime) = body->ctime;
-			LTIME_S(inode->i_mtime) = body->mtime;
+			i_size_write(inode, body->mbo_size);
+			set_nlink(inode, body->mbo_nlink);
+			LTIME_S(inode->i_atime) = body->mbo_atime;
+			LTIME_S(inode->i_ctime) = body->mbo_ctime;
+			LTIME_S(inode->i_mtime) = body->mbo_mtime;
 
 			if (req)
 				ptlrpc_req_finished(req);
@@ -288,9 +288,9 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 	       PFID(&lsm->lsm_md_oinfo[0].lmo_fid));
 
 	if (mbody) {
-		mbody->atime = atime;
-		mbody->ctime = ctime;
-		mbody->mtime = mtime;
+		mbody->mbo_atime = atime;
+		mbody->mbo_ctime = ctime;
+		mbody->mbo_mtime = mtime;
 	}
 cleanup:
 	kfree(op_data);
@@ -360,7 +360,7 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	if (rc != 0)
 		return rc;
 	/*
-	 * Nothing is found, do not access body->fid1 as it is zero and thus
+	 * Nothing is found, do not access body->mbo_fid1 as it is zero and thus
 	 * pointless.
 	 */
 	if ((it->it_disposition & DISP_LOOKUP_NEG) &&
@@ -373,7 +373,7 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 		return -EPROTO;
 
 	/* Not cross-ref case, just get out of here. */
-	if (unlikely((body->valid & OBD_MD_MDS))) {
+	if (unlikely((body->mbo_valid & OBD_MD_MDS))) {
 		rc = lmv_intent_remote(exp, lmm, lmmsize, it, &op_data->op_fid1,
 				       flags, reqp, cb_blocking,
 				       extra_lock_flags);
@@ -470,7 +470,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 		return -EPROTO;
 
 	/* Not cross-ref case, just get out of here. */
-	if (unlikely((body->valid & OBD_MD_MDS))) {
+	if (unlikely((body->mbo_valid & OBD_MD_MDS))) {
 		rc = lmv_intent_remote(exp, lmm, lmmsize, it, NULL, flags,
 				       reqp, cb_blocking, extra_lock_flags);
 		if (rc != 0)
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 6917a03..27a6be1 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1813,11 +1813,11 @@ lmv_enqueue_remote(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 
-	if (!(body->valid & OBD_MD_MDS))
+	if (!(body->mbo_valid & OBD_MD_MDS))
 		return 0;
 
 	CDEBUG(D_INODE, "REMOTE_ENQUEUE '%s' on "DFID" -> "DFID"\n",
-	       LL_IT2STR(it), PFID(&op_data->op_fid1), PFID(&body->fid1));
+	       LL_IT2STR(it), PFID(&op_data->op_fid1), PFID(&body->mbo_fid1));
 
 	/*
 	 * We got LOOKUP lock, but we really need attrs.
@@ -1827,7 +1827,7 @@ lmv_enqueue_remote(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	memcpy(&plock, lockh, sizeof(plock));
 	it->it_lock_mode = 0;
 	it->it_request = NULL;
-	fid1 = body->fid1;
+	fid1 = body->mbo_fid1;
 
 	ptlrpc_req_finished(req);
 
@@ -1917,8 +1917,8 @@ lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 		return rc;
 
 	body = req_capsule_server_get(&(*preq)->rq_pill, &RMF_MDT_BODY);
-	if (body->valid & OBD_MD_MDS) {
-		struct lu_fid rid = body->fid1;
+	if (body->mbo_valid & OBD_MD_MDS) {
+		struct lu_fid rid = body->mbo_fid1;
 
 		CDEBUG(D_INODE, "Request attrs for "DFID"\n",
 		       PFID(&rid));
@@ -2433,11 +2433,11 @@ retry:
 		return -EPROTO;
 
 	/* Not cross-ref case, just get out of here. */
-	if (likely(!(body->valid & OBD_MD_MDS)))
+	if (likely(!(body->mbo_valid & OBD_MD_MDS)))
 		return 0;
 
 	CDEBUG(D_INODE, "%s: try unlink to another MDT for "DFID"\n",
-	       exp->exp_obd->obd_name, PFID(&body->fid1));
+	       exp->exp_obd->obd_name, PFID(&body->mbo_fid1));
 
 	/* This is a remote object, try remote MDT, Note: it may
 	 * try more than 1 time here, Considering following case
@@ -2459,7 +2459,7 @@ retry:
 	 * In theory, it might try unlimited time here, but it should
 	 * be very rare case.
 	 */
-	op_data->op_fid2 = body->fid1;
+	op_data->op_fid2 = body->mbo_fid1;
 	ptlrpc_req_finished(*request);
 	*request = NULL;
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 16c3571..813f923 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -37,12 +37,12 @@
 
 static void __mdc_pack_body(struct mdt_body *b, __u32 suppgid)
 {
-	b->suppgid = suppgid;
-	b->uid = from_kuid(&init_user_ns, current_uid());
-	b->gid = from_kgid(&init_user_ns, current_gid());
-	b->fsuid = from_kuid(&init_user_ns, current_fsuid());
-	b->fsgid = from_kgid(&init_user_ns, current_fsgid());
-	b->capability = cfs_curproc_cap_pack();
+	b->mbo_suppgid = suppgid;
+	b->mbo_uid = from_kuid(&init_user_ns, current_uid());
+	b->mbo_gid = from_kgid(&init_user_ns, current_gid());
+	b->mbo_fsuid = from_kuid(&init_user_ns, current_fsuid());
+	b->mbo_fsgid = from_kgid(&init_user_ns, current_fsgid());
+	b->mbo_capability = cfs_curproc_cap_pack();
 }
 
 void mdc_is_subdir_pack(struct ptlrpc_request *req, const struct lu_fid *pfid,
@@ -52,12 +52,12 @@ void mdc_is_subdir_pack(struct ptlrpc_request *req, const struct lu_fid *pfid,
 						    &RMF_MDT_BODY);
 
 	if (pfid) {
-		b->fid1 = *pfid;
-		b->valid = OBD_MD_FLID;
+		b->mbo_fid1 = *pfid;
+		b->mbo_valid = OBD_MD_FLID;
 	}
 	if (cfid)
-		b->fid2 = *cfid;
-	b->flags = flags;
+		b->mbo_fid2 = *cfid;
+	b->mbo_flags = flags;
 }
 
 void mdc_swap_layouts_pack(struct ptlrpc_request *req,
@@ -67,9 +67,9 @@ void mdc_swap_layouts_pack(struct ptlrpc_request *req,
 						    &RMF_MDT_BODY);
 
 	__mdc_pack_body(b, op_data->op_suppgids[0]);
-	b->fid1 = op_data->op_fid1;
-	b->fid2 = op_data->op_fid2;
-	b->valid |= OBD_MD_FLID;
+	b->mbo_fid1 = op_data->op_fid1;
+	b->mbo_fid2 = op_data->op_fid2;
+	b->mbo_valid |= OBD_MD_FLID;
 }
 
 void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
@@ -77,13 +77,13 @@ void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
 {
 	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
 						    &RMF_MDT_BODY);
-	b->valid = valid;
-	b->eadatasize = ea_size;
-	b->flags = flags;
+	b->mbo_valid = valid;
+	b->mbo_eadatasize = ea_size;
+	b->mbo_flags = flags;
 	__mdc_pack_body(b, suppgid);
 	if (fid) {
-		b->fid1 = *fid;
-		b->valid |= OBD_MD_FLID;
+		b->mbo_fid1 = *fid;
+		b->mbo_valid |= OBD_MD_FLID;
 	}
 }
 
@@ -123,12 +123,12 @@ void mdc_readdir_pack(struct ptlrpc_request *req, __u64 pgoff,
 {
 	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
 						    &RMF_MDT_BODY);
-	b->fid1 = *fid;
-	b->valid |= OBD_MD_FLID;
-	b->size = pgoff;		       /* !! */
-	b->nlink = size;			/* !! */
+	b->mbo_fid1 = *fid;
+	b->mbo_valid |= OBD_MD_FLID;
+	b->mbo_size = pgoff;		       /* !! */
+	b->mbo_nlink = size;			/* !! */
 	__mdc_pack_body(b, -1);
-	b->mode = LUDA_FID | LUDA_TYPE;
+	b->mbo_mode = LUDA_FID | LUDA_TYPE;
 }
 
 /* packing of MDS records */
@@ -440,18 +440,18 @@ void mdc_getattr_pack(struct ptlrpc_request *req, __u64 valid, int flags,
 	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
 						    &RMF_MDT_BODY);
 
-	b->valid = valid;
+	b->mbo_valid = valid;
 	if (op_data->op_bias & MDS_CHECK_SPLIT)
-		b->valid |= OBD_MD_FLCKSPLIT;
+		b->mbo_valid |= OBD_MD_FLCKSPLIT;
 	if (op_data->op_bias & MDS_CROSS_REF)
-		b->valid |= OBD_MD_FLCROSSREF;
-	b->eadatasize = ea_size;
-	b->flags = flags;
+		b->mbo_valid |= OBD_MD_FLCROSSREF;
+	b->mbo_eadatasize = ea_size;
+	b->mbo_flags = flags;
 	__mdc_pack_body(b, op_data->op_suppgids[0]);
 
-	b->fid1 = op_data->op_fid1;
-	b->fid2 = op_data->op_fid2;
-	b->valid |= OBD_MD_FLID;
+	b->mbo_fid1 = op_data->op_fid1;
+	b->mbo_fid2 = op_data->op_fid2;
+	b->mbo_valid |= OBD_MD_FLID;
 
 	if (op_data->op_name)
 		mdc_pack_name(req, &RMF_NAME, op_data->op_name,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 20b15f6..551f3d9 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -240,12 +240,12 @@ static void mdc_realloc_openmsg(struct ptlrpc_request *req,
 
 	/* FIXME: remove this explicit offset. */
 	rc = sptlrpc_cli_enlarge_reqbuf(req, DLM_INTENT_REC_OFF + 4,
-					body->eadatasize);
+					body->mbo_eadatasize);
 	if (rc) {
 		CERROR("Can't enlarge segment %d size to %d\n",
-		       DLM_INTENT_REC_OFF + 4, body->eadatasize);
-		body->valid &= ~OBD_MD_FLEASIZE;
-		body->eadatasize = 0;
+		       DLM_INTENT_REC_OFF + 4, body->mbo_eadatasize);
+		body->mbo_valid &= ~OBD_MD_FLEASIZE;
+		body->mbo_eadatasize = 0;
 	}
 }
 
@@ -608,7 +608,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 			mdc_set_open_replay_data(NULL, NULL, it);
 		}
 
-		if ((body->valid & (OBD_MD_FLDIREA | OBD_MD_FLEASIZE)) != 0) {
+		if ((body->mbo_valid & (OBD_MD_FLDIREA | OBD_MD_FLEASIZE)) != 0) {
 			void *eadata;
 
 			mdc_update_max_ea_from_body(exp, body);
@@ -618,7 +618,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 			 * Eventually, obd_unpackmd() will check the contents.
 			 */
 			eadata = req_capsule_server_sized_get(pill, &RMF_MDT_MD,
-							      body->eadatasize);
+							      body->mbo_eadatasize);
 			if (!eadata)
 				return -EPROTO;
 
@@ -626,7 +626,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 			 * lock
 			 */
 			lvb_data = eadata;
-			lvb_len = body->eadatasize;
+			lvb_len = body->mbo_eadatasize;
 
 			/*
 			 * We save the reply LOV EA in case we have to replay a
@@ -642,20 +642,20 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 
 				if (req_capsule_get_size(pill, &RMF_EADATA,
 							 RCL_CLIENT) <
-				    body->eadatasize)
+				    body->mbo_eadatasize)
 					mdc_realloc_openmsg(req, body);
 				else
 					req_capsule_shrink(pill, &RMF_EADATA,
-							   body->eadatasize,
+							   body->mbo_eadatasize,
 							   RCL_CLIENT);
 
 				req_capsule_set_size(pill, &RMF_EADATA,
 						     RCL_CLIENT,
-						     body->eadatasize);
+						     body->mbo_eadatasize);
 
 				lmm = req_capsule_client_get(pill, &RMF_EADATA);
 				if (lmm)
-					memcpy(lmm, eadata, body->eadatasize);
+					memcpy(lmm, eadata, body->mbo_eadatasize);
 			}
 		}
 	} else if (it->it_op & IT_LAYOUT) {
@@ -935,11 +935,11 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 		 * op_fid3 - existent fid - if file only open.
 		 * op_fid3 is saved in lmv_intent_open
 		 */
-		if ((!lu_fid_eq(&op_data->op_fid2, &mdt_body->fid1)) &&
-		    (!lu_fid_eq(&op_data->op_fid3, &mdt_body->fid1))) {
+		if ((!lu_fid_eq(&op_data->op_fid2, &mdt_body->mbo_fid1)) &&
+		    (!lu_fid_eq(&op_data->op_fid3, &mdt_body->mbo_fid1))) {
 			CDEBUG(D_DENTRY, "Found stale data "DFID"("DFID")/"DFID
 			       "\n", PFID(&op_data->op_fid2),
-			       PFID(&op_data->op_fid2), PFID(&mdt_body->fid1));
+			       PFID(&op_data->op_fid2), PFID(&mdt_body->mbo_fid1));
 			return -ESTALE;
 		}
 	}
@@ -986,10 +986,10 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 
 		LDLM_DEBUG(lock, "matching against this");
 
-		LASSERTF(fid_res_name_eq(&mdt_body->fid1,
+		LASSERTF(fid_res_name_eq(&mdt_body->mbo_fid1,
 					 &lock->l_resource->lr_name),
 			 "Lock res_id: "DLDLMRES", fid: "DFID"\n",
-			 PLDLMRES(lock->l_resource), PFID(&mdt_body->fid1));
+			 PLDLMRES(lock->l_resource), PFID(&mdt_body->mbo_fid1));
 		LDLM_LOCK_PUT(lock);
 
 		memcpy(&old_lock, lockh, sizeof(*lockh));
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index c3781a6..9bec049 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -177,8 +177,8 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 
 		epoch = req_capsule_client_get(&req->rq_pill, &RMF_MDT_EPOCH);
 		body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-		epoch->handle = body->handle;
-		epoch->ioepoch = body->ioepoch;
+		epoch->handle = body->mbo_handle;
+		epoch->ioepoch = body->mbo_ioepoch;
 		req->rq_replay_cb = mdc_replay_open;
 	/** bug 3633, open may be committed and estale answer is not error */
 	} else if (rc == -ESTALE && (op_data->op_flags & MF_SOM_CHANGE)) {
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index e880e90..254d6d4 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -100,7 +100,7 @@ static int mdc_getstatus(struct obd_export *exp, struct lu_fid *rootfid)
 		goto out;
 	}
 
-	*rootfid = body->fid1;
+	*rootfid = body->mbo_fid1;
 	CDEBUG(D_NET,
 	       "root fid="DFID", last_committed=%llu\n",
 	       PFID(rootfid),
@@ -138,12 +138,12 @@ static int mdc_getattr_common(struct obd_export *exp,
 	if (!body)
 		return -EPROTO;
 
-	CDEBUG(D_NET, "mode: %o\n", body->mode);
+	CDEBUG(D_NET, "mode: %o\n", body->mbo_mode);
 
 	mdc_update_max_ea_from_body(exp, body);
-	if (body->eadatasize != 0) {
+	if (body->mbo_eadatasize != 0) {
 		eadata = req_capsule_server_sized_get(pill, &RMF_MDT_MD,
-						      body->eadatasize);
+						      body->mbo_eadatasize);
 		if (!eadata)
 			return -EPROTO;
 	}
@@ -399,15 +399,15 @@ static int mdc_unpack_acl(struct ptlrpc_request *req, struct lustre_md *md)
 	void		   *buf;
 	int		     rc;
 
-	if (!body->aclsize)
+	if (!body->mbo_aclsize)
 		return 0;
 
-	buf = req_capsule_server_sized_get(pill, &RMF_ACL, body->aclsize);
+	buf = req_capsule_server_sized_get(pill, &RMF_ACL, body->mbo_aclsize);
 
 	if (!buf)
 		return -EPROTO;
 
-	acl = posix_acl_from_xattr(&init_user_ns, buf, body->aclsize);
+	acl = posix_acl_from_xattr(&init_user_ns, buf, body->mbo_aclsize);
 	if (!acl)
 		return 0;
 
@@ -445,24 +445,24 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 
 	md->body = req_capsule_server_get(pill, &RMF_MDT_BODY);
 
-	if (md->body->valid & OBD_MD_FLEASIZE) {
+	if (md->body->mbo_valid & OBD_MD_FLEASIZE) {
 		int lmmsize;
 		struct lov_mds_md *lmm;
 
-		if (!S_ISREG(md->body->mode)) {
+		if (!S_ISREG(md->body->mbo_mode)) {
 			CDEBUG(D_INFO,
 			       "OBD_MD_FLEASIZE set, should be a regular file, but is not\n");
 			rc = -EPROTO;
 			goto out;
 		}
 
-		if (md->body->eadatasize == 0) {
+		if (md->body->mbo_eadatasize == 0) {
 			CDEBUG(D_INFO,
 			       "OBD_MD_FLEASIZE set, but eadatasize 0\n");
 			rc = -EPROTO;
 			goto out;
 		}
-		lmmsize = md->body->eadatasize;
+		lmmsize = md->body->mbo_eadatasize;
 		lmm = req_capsule_server_sized_get(pill, &RMF_MDT_MD, lmmsize);
 		if (!lmm) {
 			rc = -EPROTO;
@@ -481,24 +481,24 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 			goto out;
 		}
 
-	} else if (md->body->valid & OBD_MD_FLDIREA) {
+	} else if (md->body->mbo_valid & OBD_MD_FLDIREA) {
 		int lmvsize;
 		struct lov_mds_md *lmv;
 
-		if (!S_ISDIR(md->body->mode)) {
+		if (!S_ISDIR(md->body->mbo_mode)) {
 			CDEBUG(D_INFO,
 			       "OBD_MD_FLDIREA set, should be a directory, but is not\n");
 			rc = -EPROTO;
 			goto out;
 		}
 
-		if (md->body->eadatasize == 0) {
+		if (md->body->mbo_eadatasize == 0) {
 			CDEBUG(D_INFO,
 			       "OBD_MD_FLDIREA is set, but eadatasize 0\n");
 			return -EPROTO;
 		}
-		if (md->body->valid & OBD_MD_MEA) {
-			lmvsize = md->body->eadatasize;
+		if (md->body->mbo_valid & OBD_MD_MEA) {
+			lmvsize = md->body->mbo_eadatasize;
 			lmv = req_capsule_server_sized_get(pill, &RMF_MDT_MD,
 							   lmvsize);
 			if (!lmv) {
@@ -522,12 +522,12 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 	}
 	rc = 0;
 
-	if (md->body->valid & OBD_MD_FLACL) {
+	if (md->body->mbo_valid & OBD_MD_FLACL) {
 		/* for ACL, it's possible that FLACL is set but aclsize is zero.
 		 * only when aclsize != 0 there's an actual segment for ACL
 		 * in reply buffer.
 		 */
-		if (md->body->aclsize) {
+		if (md->body->mbo_aclsize) {
 			rc = mdc_unpack_acl(req, md);
 			if (rc)
 				goto out;
@@ -582,9 +582,9 @@ void mdc_replay_open(struct ptlrpc_request *req)
 
 		file_fh = &och->och_fh;
 		CDEBUG(D_HA, "updating handle from %#llx to %#llx\n",
-		       file_fh->cookie, body->handle.cookie);
+		       file_fh->cookie, body->mbo_handle.cookie);
 		old = *file_fh;
-		*file_fh = body->handle;
+		*file_fh = body->mbo_handle;
 	}
 	close_req = mod->mod_close_req;
 	if (close_req) {
@@ -599,7 +599,7 @@ void mdc_replay_open(struct ptlrpc_request *req)
 		if (och)
 			LASSERT(!memcmp(&old, &epoch->handle, sizeof(old)));
 		DEBUG_REQ(D_HA, close_req, "updating close body with new fh");
-		epoch->handle = body->handle;
+		epoch->handle = body->mbo_handle;
 	}
 }
 
@@ -681,11 +681,11 @@ int mdc_set_open_replay_data(struct obd_export *exp,
 		spin_unlock(&open_req->rq_lock);
 	}
 
-	rec->cr_fid2 = body->fid1;
-	rec->cr_ioepoch = body->ioepoch;
-	rec->cr_old_handle.cookie = body->handle.cookie;
+	rec->cr_fid2 = body->mbo_fid1;
+	rec->cr_ioepoch = body->mbo_ioepoch;
+	rec->cr_old_handle.cookie = body->mbo_handle.cookie;
 	open_req->rq_replay_cb = mdc_replay_open;
-	if (!fid_is_sane(&body->fid1)) {
+	if (!fid_is_sane(&body->mbo_fid1)) {
 		DEBUG_REQ(D_ERROR, open_req,
 			  "Saving replay request with insane fid");
 		LBUG();
@@ -746,7 +746,7 @@ static void mdc_close_handle_reply(struct ptlrpc_request *req,
 		epoch = req_capsule_client_get(&req->rq_pill, &RMF_MDT_EPOCH);
 
 		epoch->flags |= MF_SOM_AU;
-		if (repbody->valid & OBD_MD_FLGETATTRLOCK)
+		if (repbody->mbo_valid & OBD_MD_FLGETATTRLOCK)
 			op_data->op_flags |= MF_GETATTR_LOCK;
 	}
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 6ddc9c7..465698b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1674,35 +1674,35 @@ EXPORT_SYMBOL(lustre_swab_lquota_lvb);
 
 void lustre_swab_mdt_body(struct mdt_body *b)
 {
-	lustre_swab_lu_fid(&b->fid1);
-	lustre_swab_lu_fid(&b->fid2);
+	lustre_swab_lu_fid(&b->mbo_fid1);
+	lustre_swab_lu_fid(&b->mbo_fid2);
 	/* handle is opaque */
-	__swab64s(&b->valid);
-	__swab64s(&b->size);
-	__swab64s(&b->mtime);
-	__swab64s(&b->atime);
-	__swab64s(&b->ctime);
-	__swab64s(&b->blocks);
-	__swab64s(&b->ioepoch);
-	__swab64s(&b->t_state);
-	__swab32s(&b->fsuid);
-	__swab32s(&b->fsgid);
-	__swab32s(&b->capability);
-	__swab32s(&b->mode);
-	__swab32s(&b->uid);
-	__swab32s(&b->gid);
-	__swab32s(&b->flags);
-	__swab32s(&b->rdev);
-	__swab32s(&b->nlink);
-	CLASSERT(offsetof(typeof(*b), unused2) != 0);
-	__swab32s(&b->suppgid);
-	__swab32s(&b->eadatasize);
-	__swab32s(&b->aclsize);
-	__swab32s(&b->max_mdsize);
-	__swab32s(&b->max_cookiesize);
-	__swab32s(&b->uid_h);
-	__swab32s(&b->gid_h);
-	CLASSERT(offsetof(typeof(*b), padding_5) != 0);
+	__swab64s(&b->mbo_valid);
+	__swab64s(&b->mbo_size);
+	__swab64s(&b->mbo_mtime);
+	__swab64s(&b->mbo_atime);
+	__swab64s(&b->mbo_ctime);
+	__swab64s(&b->mbo_blocks);
+	__swab64s(&b->mbo_ioepoch);
+	__swab64s(&b->mbo_t_state);
+	__swab32s(&b->mbo_fsuid);
+	__swab32s(&b->mbo_fsgid);
+	__swab32s(&b->mbo_capability);
+	__swab32s(&b->mbo_mode);
+	__swab32s(&b->mbo_uid);
+	__swab32s(&b->mbo_gid);
+	__swab32s(&b->mbo_flags);
+	__swab32s(&b->mbo_rdev);
+	__swab32s(&b->mbo_nlink);
+	CLASSERT(offsetof(typeof(*b), mbo_unused2) != 0);
+	__swab32s(&b->mbo_suppgid);
+	__swab32s(&b->mbo_eadatasize);
+	__swab32s(&b->mbo_aclsize);
+	__swab32s(&b->mbo_max_mdsize);
+	__swab32s(&b->mbo_max_cookiesize);
+	__swab32s(&b->mbo_uid_h);
+	__swab32s(&b->mbo_gid_h);
+	CLASSERT(offsetof(typeof(*b), mbo_padding_5) != 0);
 }
 EXPORT_SYMBOL(lustre_swab_mdt_body);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 8dbaf32..60d03dd 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1350,7 +1350,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lov_mds_md_v1, lmm_objects[0]));
 	LASSERTF((int)sizeof(((struct lov_mds_md_v1 *)0)->lmm_objects[0]) == 24, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_mds_md_v1 *)0)->lmm_objects[0]));
-	CLASSERT(LOV_MAGIC_V1 == 0x0BD10BD0);
+	CLASSERT(LOV_MAGIC_V1 == (0x0BD10000 | 0x0BD0));
 
 	/* Checks for struct lov_mds_md_v3 */
 	LASSERTF((int)sizeof(struct lov_mds_md_v3) == 48, "found %lld\n",
@@ -1388,7 +1388,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lov_mds_md_v3, lmm_objects[0]));
 	LASSERTF((int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_objects[0]) == 24, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_objects[0]));
-	CLASSERT(LOV_MAGIC_V3 == 0x0BD30BD0);
+	CLASSERT(LOV_MAGIC_V3 == (0x0BD30000 | 0x0BD0));
 	LASSERTF(LOV_PATTERN_RAID0 == 0x00000001UL, "found 0x%.8xUL\n",
 		(unsigned)LOV_PATTERN_RAID0);
 	LASSERTF(LOV_PATTERN_RAID1 == 0x00000002UL, "found 0x%.8xUL\n",
@@ -1667,139 +1667,139 @@ void lustre_assert_wire_constants(void)
 	/* Checks for struct mdt_body */
 	LASSERTF((int)sizeof(struct mdt_body) == 216, "found %lld\n",
 		 (long long)(int)sizeof(struct mdt_body));
-	LASSERTF((int)offsetof(struct mdt_body, fid1) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, fid1));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->fid1) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->fid1));
-	LASSERTF((int)offsetof(struct mdt_body, fid2) == 16, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, fid2));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->fid2) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->fid2));
-	LASSERTF((int)offsetof(struct mdt_body, handle) == 32, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, handle));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->handle) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->handle));
-	LASSERTF((int)offsetof(struct mdt_body, valid) == 40, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, valid));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->valid) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->valid));
-	LASSERTF((int)offsetof(struct mdt_body, size) == 48, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, size));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->size) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->size));
-	LASSERTF((int)offsetof(struct mdt_body, mtime) == 56, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, mtime));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->mtime) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->mtime));
-	LASSERTF((int)offsetof(struct mdt_body, atime) == 64, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, atime));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->atime) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->atime));
-	LASSERTF((int)offsetof(struct mdt_body, ctime) == 72, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, ctime));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->ctime) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->ctime));
-	LASSERTF((int)offsetof(struct mdt_body, blocks) == 80, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, blocks));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->blocks) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->blocks));
-	LASSERTF((int)offsetof(struct mdt_body, t_state) == 96, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, t_state));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->t_state) == 8,
+	LASSERTF((int)offsetof(struct mdt_body, mbo_fid1) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_fid1));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_fid1) == 16, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_fid1));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_fid2) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_fid2));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_fid2) == 16, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_fid2));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_handle) == 32, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_handle));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_handle) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_handle));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_valid) == 40, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_valid));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_valid) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_valid));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_size) == 48, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_size));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_size) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_size));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_mtime) == 56, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_mtime));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_mtime) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_mtime));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_atime) == 64, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_atime));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_atime) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_atime));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_ctime) == 72, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_ctime));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_ctime) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_ctime));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_blocks) == 80, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_blocks));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_blocks) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_blocks));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_t_state) == 96, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_t_state));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_t_state) == 8,
 		 "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->t_state));
-	LASSERTF((int)offsetof(struct mdt_body, fsuid) == 104, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, fsuid));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->fsuid) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->fsuid));
-	LASSERTF((int)offsetof(struct mdt_body, fsgid) == 108, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, fsgid));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->fsgid) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->fsgid));
-	LASSERTF((int)offsetof(struct mdt_body, capability) == 112, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, capability));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->capability) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->capability));
-	LASSERTF((int)offsetof(struct mdt_body, mode) == 116, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, mode));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->mode) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->mode));
-	LASSERTF((int)offsetof(struct mdt_body, uid) == 120, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, uid));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->uid) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->uid));
-	LASSERTF((int)offsetof(struct mdt_body, gid) == 124, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, gid));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->gid) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->gid));
-	LASSERTF((int)offsetof(struct mdt_body, flags) == 128, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, flags));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->flags) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->flags));
-	LASSERTF((int)offsetof(struct mdt_body, rdev) == 132, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, rdev));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->rdev) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->rdev));
-	LASSERTF((int)offsetof(struct mdt_body, nlink) == 136, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, nlink));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->nlink) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->nlink));
-	LASSERTF((int)offsetof(struct mdt_body, unused2) == 140, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, unused2));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->unused2) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->unused2));
-	LASSERTF((int)offsetof(struct mdt_body, suppgid) == 144, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, suppgid));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->suppgid) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->suppgid));
-	LASSERTF((int)offsetof(struct mdt_body, eadatasize) == 148, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, eadatasize));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->eadatasize) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->eadatasize));
-	LASSERTF((int)offsetof(struct mdt_body, aclsize) == 152, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, aclsize));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->aclsize) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->aclsize));
-	LASSERTF((int)offsetof(struct mdt_body, max_mdsize) == 156, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, max_mdsize));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->max_mdsize) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->max_mdsize));
-	LASSERTF((int)offsetof(struct mdt_body, max_cookiesize) == 160, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, max_cookiesize));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->max_cookiesize) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->max_cookiesize));
-	LASSERTF((int)offsetof(struct mdt_body, uid_h) == 164, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, uid_h));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->uid_h) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->uid_h));
-	LASSERTF((int)offsetof(struct mdt_body, gid_h) == 168, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, gid_h));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->gid_h) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->gid_h));
-	LASSERTF((int)offsetof(struct mdt_body, padding_5) == 172, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, padding_5));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->padding_5) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->padding_5));
-	LASSERTF((int)offsetof(struct mdt_body, padding_6) == 176, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, padding_6));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->padding_6) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->padding_6));
-	LASSERTF((int)offsetof(struct mdt_body, padding_7) == 184, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, padding_7));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->padding_7) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->padding_7));
-	LASSERTF((int)offsetof(struct mdt_body, padding_8) == 192, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, padding_8));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->padding_8) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->padding_8));
-	LASSERTF((int)offsetof(struct mdt_body, padding_9) == 200, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, padding_9));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->padding_9) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->padding_9));
-	LASSERTF((int)offsetof(struct mdt_body, padding_10) == 208, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, padding_10));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->padding_10) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->padding_10));
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_t_state));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_fsuid) == 104, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_fsuid));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_fsuid) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_fsuid));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_fsgid) == 108, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_fsgid));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_fsgid) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_fsgid));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_capability) == 112, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_capability));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_capability) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_capability));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_mode) == 116, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_mode));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_mode) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_mode));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_uid) == 120, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_uid));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_uid) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_uid));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_gid) == 124, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_gid));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_gid) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_gid));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_flags) == 128, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_flags));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_flags) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_flags));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_rdev) == 132, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_rdev));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_rdev) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_rdev));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_nlink) == 136, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_nlink));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_nlink) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_nlink));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_unused2) == 140, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_unused2));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_unused2) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_unused2));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_suppgid) == 144, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_suppgid));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_suppgid) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_suppgid));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_eadatasize) == 148, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_eadatasize));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_eadatasize) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_eadatasize));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_aclsize) == 152, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_aclsize));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_aclsize) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_aclsize));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_max_mdsize) == 156, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_max_mdsize));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_max_mdsize) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_max_mdsize));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_max_cookiesize) == 160, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_max_cookiesize));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_max_cookiesize) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_max_cookiesize));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_uid_h) == 164, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_uid_h));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_uid_h) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_uid_h));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_gid_h) == 168, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_gid_h));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_gid_h) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_gid_h));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_padding_5) == 172, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_padding_5));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_padding_5) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_padding_5));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_padding_6) == 176, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_padding_6));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_padding_6) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_padding_6));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_padding_7) == 184, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_padding_7));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_padding_7) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_padding_7));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_padding_8) == 192, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_padding_8));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_padding_8) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_padding_8));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_padding_9) == 200, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_padding_9));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_padding_9) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_padding_9));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_padding_10) == 208, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_padding_10));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_padding_10) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_padding_10));
 	LASSERTF(MDS_FMODE_CLOSED == 000000000000UL, "found 0%.11oUL\n",
 		MDS_FMODE_CLOSED);
 	LASSERTF(MDS_FMODE_EXEC == 000000000004UL, "found 0%.11oUL\n",
-- 
1.7.1
