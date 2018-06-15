From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 12/24] lustre: discard LTIME_S macro
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669049.10587.5561340259770955128.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Rather than using a macro, just access the required
field directly.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_compat.h  |    2 -
 drivers/staging/lustre/lustre/llite/file.c         |   24 +++++++++--------
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    6 ++--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   28 ++++++++++----------
 drivers/staging/lustre/lustre/llite/namei.c        |   16 ++++++-----
 drivers/staging/lustre/lustre/llite/vvp_object.c   |    6 ++--
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |    6 ++--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   16 ++++++-----
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |    6 ++--
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |    4 +--
 drivers/staging/lustre/lustre/obdclass/obdo.c      |   10 ++++---
 11 files changed, 61 insertions(+), 63 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
index 481eb4f31cfa..5e412fa8efbd 100644
--- a/drivers/staging/lustre/lustre/include/lustre_compat.h
+++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
@@ -49,8 +49,6 @@
 #define module_init(a)     late_initcall(a)
 #endif
 
-#define LTIME_S(time)		   (time.tv_sec)
-
 #ifndef QUOTA_OK
 # define QUOTA_OK 0
 #endif
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index e642996db53f..59b5fbc75a51 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -956,13 +956,13 @@ int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 	/* merge timestamps the most recently obtained from mds with
 	 * timestamps obtained from osts
 	 */
-	LTIME_S(inode->i_atime) = lli->lli_atime;
-	LTIME_S(inode->i_mtime) = lli->lli_mtime;
-	LTIME_S(inode->i_ctime) = lli->lli_ctime;
+	inode->i_atime.tv_sec = lli->lli_atime;
+	inode->i_mtime.tv_sec = lli->lli_mtime;
+	inode->i_ctime.tv_sec = lli->lli_ctime;
 
-	mtime = LTIME_S(inode->i_mtime);
-	atime = LTIME_S(inode->i_atime);
-	ctime = LTIME_S(inode->i_ctime);
+	mtime = inode->i_mtime.tv_sec;
+	atime = inode->i_atime.tv_sec;
+	ctime = inode->i_ctime.tv_sec;
 
 	cl_object_attr_lock(obj);
 	rc = cl_object_attr_get(env, obj, attr);
@@ -987,9 +987,9 @@ int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 
 	inode->i_blocks = attr->cat_blocks;
 
-	LTIME_S(inode->i_mtime) = mtime;
-	LTIME_S(inode->i_atime) = atime;
-	LTIME_S(inode->i_ctime) = ctime;
+	inode->i_mtime.tv_sec = mtime;
+	inode->i_atime.tv_sec = atime;
+	inode->i_ctime.tv_sec = ctime;
 
 out_size_unlock:
 	ll_inode_size_unlock(inode);
@@ -2933,9 +2933,9 @@ static int ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 				return rc;
 		}
 
-		LTIME_S(inode->i_atime) = ll_i2info(inode)->lli_atime;
-		LTIME_S(inode->i_mtime) = ll_i2info(inode)->lli_mtime;
-		LTIME_S(inode->i_ctime) = ll_i2info(inode)->lli_ctime;
+		inode->i_atime.tv_sec = ll_i2info(inode)->lli_atime;
+		inode->i_mtime.tv_sec = ll_i2info(inode)->lli_mtime;
+		inode->i_ctime.tv_sec = ll_i2info(inode)->lli_ctime;
 	} else {
 		struct ll_inode_info *lli = ll_i2info(inode);
 
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 9d1f3881f860..6c9fe498dbc3 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -95,9 +95,9 @@ int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
 	io->ci_obj = obj;
 	io->ci_verify_layout = 1;
 
-	io->u.ci_setattr.sa_attr.lvb_atime = LTIME_S(attr->ia_atime);
-	io->u.ci_setattr.sa_attr.lvb_mtime = LTIME_S(attr->ia_mtime);
-	io->u.ci_setattr.sa_attr.lvb_ctime = LTIME_S(attr->ia_ctime);
+	io->u.ci_setattr.sa_attr.lvb_atime = attr->ia_atime.tv_sec;
+	io->u.ci_setattr.sa_attr.lvb_mtime = attr->ia_mtime.tv_sec;
+	io->u.ci_setattr.sa_attr.lvb_ctime = attr->ia_ctime.tv_sec;
 	io->u.ci_setattr.sa_attr.lvb_size = attr->ia_size;
 	io->u.ci_setattr.sa_attr_flags = attr_flags;
 	io->u.ci_setattr.sa_avalid = attr->ia_valid;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index cd0f2517a3b3..d72674873a70 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1108,9 +1108,9 @@ static struct inode *ll_iget_anon_dir(struct super_block *sb,
 		LASSERTF(S_ISDIR(inode->i_mode), "Not slave inode " DFID "\n",
 			 PFID(fid));
 
-		LTIME_S(inode->i_mtime) = 0;
-		LTIME_S(inode->i_atime) = 0;
-		LTIME_S(inode->i_ctime) = 0;
+		inode->i_mtime.tv_sec = 0;
+		inode->i_atime.tv_sec = 0;
+		inode->i_ctime.tv_sec = 0;
 		inode->i_rdev = 0;
 
 		inode->i_op = &ll_dir_inode_operations;
@@ -1486,7 +1486,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 
 	if (attr->ia_valid & (ATTR_MTIME | ATTR_CTIME))
 		CDEBUG(D_INODE, "setting mtime %lu, ctime %lu, now = %llu\n",
-		       LTIME_S(attr->ia_mtime), LTIME_S(attr->ia_ctime),
+		       attr->ia_mtime.tv_sec, attr->ia_ctime.tv_sec,
 		       (s64)ktime_get_real_seconds());
 
 	if (S_ISREG(inode->i_mode))
@@ -1759,23 +1759,23 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 	inode->i_generation = cl_fid_build_gen(&body->mbo_fid1);
 
 	if (body->mbo_valid & OBD_MD_FLATIME) {
-		if (body->mbo_atime > LTIME_S(inode->i_atime))
-			LTIME_S(inode->i_atime) = body->mbo_atime;
+		if (body->mbo_atime > inode->i_atime.tv_sec)
+			inode->i_atime.tv_sec = body->mbo_atime;
 		lli->lli_atime = body->mbo_atime;
 	}
 	if (body->mbo_valid & OBD_MD_FLMTIME) {
-		if (body->mbo_mtime > LTIME_S(inode->i_mtime)) {
+		if (body->mbo_mtime > inode->i_mtime.tv_sec) {
 			CDEBUG(D_INODE,
 			       "setting ino %lu mtime from %lu to %llu\n",
-			       inode->i_ino, LTIME_S(inode->i_mtime),
+			       inode->i_ino, inode->i_mtime.tv_sec,
 			       body->mbo_mtime);
-			LTIME_S(inode->i_mtime) = body->mbo_mtime;
+			inode->i_mtime.tv_sec = body->mbo_mtime;
 		}
 		lli->lli_mtime = body->mbo_mtime;
 	}
 	if (body->mbo_valid & OBD_MD_FLCTIME) {
-		if (body->mbo_ctime > LTIME_S(inode->i_ctime))
-			LTIME_S(inode->i_ctime) = body->mbo_ctime;
+		if (body->mbo_ctime > inode->i_ctime.tv_sec)
+			inode->i_ctime.tv_sec = body->mbo_ctime;
 		lli->lli_ctime = body->mbo_ctime;
 	}
 	if (body->mbo_valid & OBD_MD_FLMODE)
@@ -1848,9 +1848,9 @@ int ll_read_inode2(struct inode *inode, void *opaque)
 	 * it ourselves.  They will be overwritten by either MDS or OST
 	 * attributes - we just need to make sure they aren't newer.
 	 */
-	LTIME_S(inode->i_mtime) = 0;
-	LTIME_S(inode->i_atime) = 0;
-	LTIME_S(inode->i_ctime) = 0;
+	inode->i_mtime.tv_sec = 0;
+	inode->i_atime.tv_sec = 0;
+	inode->i_ctime.tv_sec = 0;
 	inode->i_rdev = 0;
 	rc = ll_update_inode(inode, md);
 	if (rc)
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index d5f6d20afe8c..eb9dc532b353 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -266,9 +266,9 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 			struct ll_inode_info *lli = ll_i2info(inode);
 
 			spin_lock(&lli->lli_lock);
-			LTIME_S(inode->i_mtime) = 0;
-			LTIME_S(inode->i_atime) = 0;
-			LTIME_S(inode->i_ctime) = 0;
+			inode->i_mtime.tv_sec = 0;
+			inode->i_atime.tv_sec = 0;
+			inode->i_ctime.tv_sec = 0;
 			spin_unlock(&lli->lli_lock);
 		}
 
@@ -848,15 +848,15 @@ void ll_update_times(struct ptlrpc_request *request, struct inode *inode)
 
 	LASSERT(body);
 	if (body->mbo_valid & OBD_MD_FLMTIME &&
-	    body->mbo_mtime > LTIME_S(inode->i_mtime)) {
+	    body->mbo_mtime > inode->i_mtime.tv_sec) {
 		CDEBUG(D_INODE, "setting fid " DFID " mtime from %lu to %llu\n",
-		       PFID(ll_inode2fid(inode)), LTIME_S(inode->i_mtime),
+		       PFID(ll_inode2fid(inode)), inode->i_mtime.tv_sec,
 		       body->mbo_mtime);
-		LTIME_S(inode->i_mtime) = body->mbo_mtime;
+		inode->i_mtime.tv_sec = body->mbo_mtime;
 	}
 	if (body->mbo_valid & OBD_MD_FLCTIME &&
-	    body->mbo_ctime > LTIME_S(inode->i_ctime))
-		LTIME_S(inode->i_ctime) = body->mbo_ctime;
+	    body->mbo_ctime > inode->i_ctime.tv_sec)
+		inode->i_ctime.tv_sec = body->mbo_ctime;
 }
 
 static int ll_new_node(struct inode *dir, struct dentry *dentry,
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index b2cb51c8f7f4..301a90d6e5f5 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -170,9 +170,9 @@ static int vvp_object_glimpse(const struct lu_env *env,
 {
 	struct inode *inode = vvp_object_inode(obj);
 
-	lvb->lvb_mtime = LTIME_S(inode->i_mtime);
-	lvb->lvb_atime = LTIME_S(inode->i_atime);
-	lvb->lvb_ctime = LTIME_S(inode->i_ctime);
+	lvb->lvb_mtime = inode->i_mtime.tv_sec;
+	lvb->lvb_atime = inode->i_atime.tv_sec;
+	lvb->lvb_ctime = inode->i_ctime.tv_sec;
 	/*
 	 * LU-417: Add dirty pages block count lest i_blocks reports 0, some
 	 * "cp" or "tar" on remote node may think it's a completely sparse file
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 1e850fdbc623..ba6410e800a7 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -233,9 +233,9 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 			i_size_write(inode, body->mbo_size);
 			inode->i_blocks = body->mbo_blocks;
 			set_nlink(inode, body->mbo_nlink);
-			LTIME_S(inode->i_atime) = body->mbo_atime;
-			LTIME_S(inode->i_ctime) = body->mbo_ctime;
-			LTIME_S(inode->i_mtime) = body->mbo_mtime;
+			inode->i_atime.tv_sec = body->mbo_atime;
+			inode->i_ctime.tv_sec = body->mbo_ctime;
+			inode->i_mtime.tv_sec = body->mbo_mtime;
 		}
 
 		md_set_lock_data(tgt->ltd_exp, lockh, inode, NULL);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 9f427a7c7b03..58c9a8d503ec 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -3030,8 +3030,8 @@ static int lmv_merge_attr(struct obd_export *exp,
 		CDEBUG(D_INFO, "" DFID " size %llu, blocks %llu nlink %u, atime %lu ctime %lu, mtime %lu.\n",
 		       PFID(&lsm->lsm_md_oinfo[i].lmo_fid),
 		       i_size_read(inode), (unsigned long long)inode->i_blocks,
-		       inode->i_nlink, LTIME_S(inode->i_atime),
-		       LTIME_S(inode->i_ctime), LTIME_S(inode->i_mtime));
+		       inode->i_nlink, inode->i_atime.tv_sec,
+		       inode->i_ctime.tv_sec, inode->i_mtime.tv_sec);
 
 		/* for slave stripe, it needs to subtract nlink for . and .. */
 		if (i)
@@ -3042,14 +3042,14 @@ static int lmv_merge_attr(struct obd_export *exp,
 		attr->cat_size += i_size_read(inode);
 		attr->cat_blocks += inode->i_blocks;
 
-		if (attr->cat_atime < LTIME_S(inode->i_atime))
-			attr->cat_atime = LTIME_S(inode->i_atime);
+		if (attr->cat_atime < inode->i_atime.tv_sec)
+			attr->cat_atime = inode->i_atime.tv_sec;
 
-		if (attr->cat_ctime < LTIME_S(inode->i_ctime))
-			attr->cat_ctime = LTIME_S(inode->i_ctime);
+		if (attr->cat_ctime < inode->i_ctime.tv_sec)
+			attr->cat_ctime = inode->i_ctime.tv_sec;
 
-		if (attr->cat_mtime < LTIME_S(inode->i_mtime))
-			attr->cat_mtime = LTIME_S(inode->i_mtime);
+		if (attr->cat_mtime < inode->i_mtime.tv_sec)
+			attr->cat_mtime = inode->i_mtime.tv_sec;
 	}
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index ad7c13be5e3c..9cb4d242d7de 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -293,9 +293,9 @@ static void mdc_setattr_pack_rec(struct mdt_rec_setattr *rec,
 	rec->sa_gid    = from_kgid(&init_user_ns, op_data->op_attr.ia_gid);
 	rec->sa_size   = op_data->op_attr.ia_size;
 	rec->sa_blocks = op_data->op_attr_blocks;
-	rec->sa_atime  = LTIME_S(op_data->op_attr.ia_atime);
-	rec->sa_mtime  = LTIME_S(op_data->op_attr.ia_mtime);
-	rec->sa_ctime  = LTIME_S(op_data->op_attr.ia_ctime);
+	rec->sa_atime  = op_data->op_attr.ia_atime.tv_sec;
+	rec->sa_mtime  = op_data->op_attr.ia_mtime.tv_sec;
+	rec->sa_ctime  = op_data->op_attr.ia_ctime.tv_sec;
 	rec->sa_attr_flags = op_data->op_attr_flags;
 	if ((op_data->op_attr.ia_valid & ATTR_GID) &&
 	    in_group_p(op_data->op_attr.ia_gid))
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index e77c00df0693..b014eb235ce1 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -130,8 +130,8 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 
 	if (op_data->op_attr.ia_valid & (ATTR_MTIME | ATTR_CTIME))
 		CDEBUG(D_INODE, "setting mtime %ld, ctime %ld\n",
-		       LTIME_S(op_data->op_attr.ia_mtime),
-		       LTIME_S(op_data->op_attr.ia_ctime));
+		       op_data->op_attr.ia_mtime.tv_sec,
+		       op_data->op_attr.ia_ctime.tv_sec);
 	mdc_setattr_pack(req, op_data, ea, ealen);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index c4503bc36591..3bc8ca8363de 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -61,19 +61,19 @@ void obdo_from_inode(struct obdo *dst, struct inode *src, u32 valid)
 
 	if (valid & (OBD_MD_FLCTIME | OBD_MD_FLMTIME))
 		CDEBUG(D_INODE, "valid %x, new time %lu/%lu\n",
-		       valid, LTIME_S(src->i_mtime),
-		       LTIME_S(src->i_ctime));
+		       valid, src->i_mtime.tv_sec,
+		       src->i_ctime.tv_sec);
 
 	if (valid & OBD_MD_FLATIME) {
-		dst->o_atime = LTIME_S(src->i_atime);
+		dst->o_atime = src->i_atime.tv_sec;
 		newvalid |= OBD_MD_FLATIME;
 	}
 	if (valid & OBD_MD_FLMTIME) {
-		dst->o_mtime = LTIME_S(src->i_mtime);
+		dst->o_mtime = src->i_mtime.tv_sec;
 		newvalid |= OBD_MD_FLMTIME;
 	}
 	if (valid & OBD_MD_FLCTIME) {
-		dst->o_ctime = LTIME_S(src->i_ctime);
+		dst->o_ctime = src->i_ctime.tv_sec;
 		newvalid |= OBD_MD_FLCTIME;
 	}
 	if (valid & OBD_MD_FLSIZE) {
