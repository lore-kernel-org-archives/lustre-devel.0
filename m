From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:40 -0500
Subject: [lustre-devel] [PATCH 292/622] lustre: dne: allow access to striped
 dir with broken layout
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-293-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Sometimes the layout of striped directories may become broken:
* creation/unlink is partially executed on some MDT.
* disk failure or stopped MDS cause some stripe inaccessible.
* software bugs.

In this situation, this directory should still be accessible,
and specially be able to migrate to other active MDTs.

This patch add this support on both server and client: don't
imply stripe FID is sane, and when stripe doesn't exist, skip
it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11907
Lustre-commit: d2725563e7af ("LU-11907 dne: allow access to striped dir with broken layout")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34750
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c       | 17 ++++++++++-------
 fs/lustre/llite/llite_lib.c |  4 ++++
 fs/lustre/lmv/lmv_intent.c  | 16 ++++++++++++++++
 fs/lustre/lmv/lmv_obd.c     | 27 ++++++++++++++++++++++++---
 4 files changed, 54 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index fd7cd2d..f75183b 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -321,7 +321,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 		 */
 		if (file_dentry(filp)->d_parent &&
 		    file_dentry(filp)->d_parent->d_inode) {
-			u64 ibits = MDS_INODELOCK_UPDATE;
+			u64 ibits = MDS_INODELOCK_LOOKUP;
 			struct inode *parent;
 
 			parent = file_dentry(filp)->d_parent->d_inode;
@@ -1551,13 +1551,16 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			struct lu_fid fid;
 
 			fid_le_to_cpu(&fid, &lmm->lmv_md_v1.lmv_stripe_fids[i]);
-			mdt_index = ll_get_mdt_idx_by_fid(sbi, &fid);
-			if (mdt_index < 0) {
-				rc = mdt_index;
-				goto out_tmp;
+			if (fid_is_sane(&fid)) {
+				mdt_index = ll_get_mdt_idx_by_fid(sbi, &fid);
+				if (mdt_index < 0) {
+					rc = mdt_index;
+					goto out_tmp;
+				}
+				tmp->lum_objects[i].lum_mds = mdt_index;
+				tmp->lum_objects[i].lum_fid = fid;
 			}
-			tmp->lum_objects[i].lum_mds = mdt_index;
-			tmp->lum_objects[i].lum_fid = fid;
+
 			tmp->lum_stripe_count++;
 		}
 
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 99cedcf..ba477ad 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1279,6 +1279,10 @@ static int ll_init_lsm_md(struct inode *inode, struct lustre_md *md)
 	for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
 		fid = &lsm->lsm_md_oinfo[i].lmo_fid;
 		LASSERT(!lsm->lsm_md_oinfo[i].lmo_root);
+
+		if (!fid_is_sane(fid))
+			continue;
+
 		/* Unfortunately ll_iget will call ll_update_inode,
 		 * where the initialization of slave inode is slightly
 		 * different, so it reset lsm_md to NULL to avoid
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 84a21a0..ba14e7c 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -162,6 +162,7 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 	struct ptlrpc_request *req = NULL;
 	struct mdt_body *body;
 	struct md_op_data *op_data;
+	int valid_stripe_count = 0;
 	int rc = 0, i;
 
 	/**
@@ -186,6 +187,9 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 		fid = lsm->lsm_md_oinfo[i].lmo_fid;
 		inode = lsm->lsm_md_oinfo[i].lmo_root;
 
+		if (!inode)
+			continue;
+
 		/*
 		 * Prepare op_data for revalidating. Note that @fid2 shluld be
 		 * defined otherwise it will go to server and take new lock
@@ -211,6 +215,12 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 
 		rc = md_intent_lock(tgt->ltd_exp, op_data, &it, &req,
 				    cb_blocking, extra_lock_flags);
+		if (rc == -ENOENT) {
+			/* skip stripe is not exists */
+			rc = 0;
+			continue;
+		}
+
 		if (rc < 0)
 			goto cleanup;
 
@@ -249,12 +259,18 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 			ldlm_lock_decref(lockh, it.it_lock_mode);
 			it.it_lock_mode = 0;
 		}
+
+		valid_stripe_count++;
 	}
 
 cleanup:
 	if (req)
 		ptlrpc_req_finished(req);
 
+	/* if all stripes are invalid, return -ENOENT to notify user */
+	if (!rc && !valid_stripe_count)
+		rc = -ENOENT;
+
 	kfree(op_data);
 	return rc;
 }
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index dc4bd1e..4b5bd36 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -2398,6 +2398,11 @@ static struct lu_dirent *stripe_dirent_load(struct lmv_dir_ctxt *ctxt,
 		}
 
 		oinfo = &op_data->op_mea1->lsm_md_oinfo[stripe_index];
+		if (!oinfo->lmo_root) {
+			rc = -ENOENT;
+			break;
+		}
+
 		tgt = lmv_get_target(ctxt->ldc_lmv, oinfo->lmo_mds, NULL);
 		if (IS_ERR(tgt)) {
 			rc = PTR_ERR(tgt);
@@ -2953,10 +2958,22 @@ static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
 	for (i = 0; i < stripe_count; i++) {
 		fid_le_to_cpu(&lsm->lsm_md_oinfo[i].lmo_fid,
 			      &lmm1->lmv_stripe_fids[i]);
+		/*
+		 * set default value -1, so lmv_locate_tgt() knows this stripe
+		 * target is not initialized.
+		 */
+		lsm->lsm_md_oinfo[i].lmo_mds = (u32)-1;
+		if (!fid_is_sane(&lsm->lsm_md_oinfo[i].lmo_fid))
+			continue;
+
 		rc = lmv_fld_lookup(lmv, &lsm->lsm_md_oinfo[i].lmo_fid,
 				    &lsm->lsm_md_oinfo[i].lmo_mds);
+		if (rc == -ENOENT)
+			continue;
+
 		if (rc)
 			return rc;
+
 		CDEBUG(D_INFO, "unpack fid #%d " DFID "\n", i,
 		       PFID(&lsm->lsm_md_oinfo[i].lmo_fid));
 	}
@@ -2988,9 +3005,10 @@ static int lmv_unpackmd(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 			return 0;
 		}
 
-		for (i = 0; i < lsm->lsm_md_stripe_count; i++)
-			iput(lsm->lsm_md_oinfo[i].lmo_root);
-
+		for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
+			if (lsm->lsm_md_oinfo[i].lmo_root)
+				iput(lsm->lsm_md_oinfo[i].lmo_root);
+		}
 		kvfree(lsm);
 		*lsmp = NULL;
 		return 0;
@@ -3334,6 +3352,9 @@ static int lmv_merge_attr(struct obd_export *exp,
 	for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
 		struct inode *inode = lsm->lsm_md_oinfo[i].lmo_root;
 
+		if (!inode)
+			continue;
+
 		CDEBUG(D_INFO,
 		       "" DFID " size %llu, blocks %llu nlink %u, atime %lld ctime %lld, mtime %lld.\n",
 		       PFID(&lsm->lsm_md_oinfo[i].lmo_fid),
-- 
1.8.3.1
