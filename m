From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:56 -0400
Subject: [lustre-devel] [PATCH 16/18] lustre: mdt: don't fetch LOOKUP lock
 for remote object
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Pack parent FID in getattr by FID, which will be used to check whether
child is remote object on parent. The helper function is called
mdt_is_remote_object(). NB, directory shard is not treated as remote
object, because if so, client needs to revalidate shards when dir is
accessed, which will hurt performance much.

For getattr by FID, if object is remote file on parent, don't fetch
LOOKUP lock, otherwise client may see stale dir entries.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13437
Lustre-commit: f9a2da63abab5 ("LU-13437 mdt: don't fetch LOOKUP lock for remote object")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38561
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h       |  2 +-
 fs/lustre/include/obd_class.h |  3 ++-
 fs/lustre/llite/file.c        |  6 +++---
 fs/lustre/llite/llite_lib.c   |  4 ++--
 fs/lustre/lmv/lmv_intent.c    | 19 +++++++++++++------
 fs/lustre/lmv/lmv_internal.h  |  1 +
 fs/lustre/lmv/lmv_obd.c       |  3 ++-
 7 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index f9e0920..438f4ca 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -1004,7 +1004,7 @@ struct md_ops {
 
 	int (*free_lustre_md)(struct obd_export *, struct lustre_md *);
 
-	int (*merge_attr)(struct obd_export *,
+	int (*merge_attr)(struct obd_export *, const struct lu_fid *fid,
 			  const struct lmv_stripe_md *lsm,
 			  struct cl_attr *attr, ldlm_blocking_callback);
 
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 746782b..78f7b16 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1458,6 +1458,7 @@ static inline int md_free_lustre_md(struct obd_export *exp,
 }
 
 static inline int md_merge_attr(struct obd_export *exp,
+				const struct lu_fid *fid,
 				const struct lmv_stripe_md *lsm,
 				struct cl_attr *attr,
 				ldlm_blocking_callback cb)
@@ -1468,7 +1469,7 @@ static inline int md_merge_attr(struct obd_export *exp,
 	if (rc)
 		return rc;
 
-	return MDP(exp->exp_obd, merge_attr)(exp, lsm, attr, cb);
+	return MDP(exp->exp_obd, merge_attr)(exp, fid, lsm, attr, cb);
 }
 
 static inline int md_setxattr(struct obd_export *exp, const struct lu_fid *fid,
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 55ae2b3..1849229 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4500,8 +4500,8 @@ static int ll_inode_revalidate(struct dentry *dentry, enum ldlm_intent_flags op)
 	       PFID(ll_inode2fid(inode)), inode, dentry);
 
 	/* Call getattr by fid, so do not provide name at all. */
-	op_data = ll_prep_md_op_data(NULL, inode, inode, NULL, 0, 0,
-				     LUSTRE_OPC_ANY, NULL);
+	op_data = ll_prep_md_op_data(NULL, dentry->d_parent->d_inode, inode,
+				     NULL, 0, 0, LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
@@ -4548,7 +4548,7 @@ static int ll_merge_md_attr(struct inode *inode)
 		return 0;
 
 	down_read(&lli->lli_lsm_sem);
-	rc = md_merge_attr(ll_i2mdexp(inode), ll_i2info(inode)->lli_lsm_md,
+	rc = md_merge_attr(ll_i2mdexp(inode), &lli->lli_fid, lli->lli_lsm_md,
 			   &attr, ll_md_blocking_ast);
 	up_read(&lli->lli_lsm_sem);
 	if (rc)
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index b30feb0..1a7d805 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1525,8 +1525,8 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	}
 
 	/* validate the lsm */
-	rc = md_merge_attr(ll_i2mdexp(inode), lli->lli_lsm_md, attr,
-			   ll_md_blocking_ast);
+	rc = md_merge_attr(ll_i2mdexp(inode), &lli->lli_fid, lli->lli_lsm_md,
+			   attr, ll_md_blocking_ast);
 	if (!rc) {
 		if (md->body->mbo_valid & OBD_MD_FLNLINK)
 			md->body->mbo_nlink = attr->cat_nlink;
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index a847770..4af449e 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -153,6 +153,7 @@ static int lmv_intent_remote(struct obd_export *exp, struct lookup_intent *it,
 }
 
 int lmv_revalidate_slaves(struct obd_export *exp,
+			  const struct lu_fid *pfid,
 			  const struct lmv_stripe_md *lsm,
 			  ldlm_blocking_callback cb_blocking,
 			  int extra_lock_flags)
@@ -196,7 +197,7 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 		 * which is not needed here.
 		 */
 		memset(op_data, 0, sizeof(*op_data));
-		op_data->op_fid1 = fid;
+		op_data->op_fid1 = *pfid;
 		op_data->op_fid2 = fid;
 
 		tgt = lmv_tgt(lmv, lsm->lsm_md_oinfo[i].lmo_mds);
@@ -444,13 +445,18 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	}
 
 retry:
-	tgt = lmv_locate_tgt(lmv, op_data);
+	if (op_data->op_name) {
+		tgt = lmv_locate_tgt(lmv, op_data);
+		if (!fid_is_sane(&op_data->op_fid2))
+			fid_zero(&op_data->op_fid2);
+	} else if (fid_is_sane(&op_data->op_fid2)) {
+		tgt = lmv_fid2tgt(lmv, &op_data->op_fid2);
+	} else {
+		tgt = lmv_fid2tgt(lmv, &op_data->op_fid1);
+	}
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
-	if (!fid_is_sane(&op_data->op_fid2))
-		fid_zero(&op_data->op_fid2);
-
 	CDEBUG(D_INODE,
 	       "LOOKUP_INTENT with fid1=" DFID ", fid2=" DFID ", name='%s' -> mds #%u\n",
 	       PFID(&op_data->op_fid1), PFID(&op_data->op_fid2),
@@ -470,7 +476,8 @@ static int lmv_intent_lookup(struct obd_export *exp,
 		 * during update_inode process (see ll_update_lsm_md)
 		 */
 		if (lmv_dir_striped(op_data->op_mea2)) {
-			rc = lmv_revalidate_slaves(exp, op_data->op_mea2,
+			rc = lmv_revalidate_slaves(exp, &op_data->op_fid2,
+						   op_data->op_mea2,
 						   cb_blocking,
 						   extra_lock_flags);
 			if (rc != 0)
diff --git a/fs/lustre/lmv/lmv_internal.h b/fs/lustre/lmv/lmv_internal.h
index e42b141..756fa27 100644
--- a/fs/lustre/lmv/lmv_internal.h
+++ b/fs/lustre/lmv/lmv_internal.h
@@ -53,6 +53,7 @@ int lmv_fid_alloc(const struct lu_env *env, struct obd_export *exp,
 		  struct lu_fid *fid, struct md_op_data *op_data);
 
 int lmv_revalidate_slaves(struct obd_export *exp,
+			  const struct lu_fid *pfid,
 			  const struct lmv_stripe_md *lsm,
 			  ldlm_blocking_callback cb_blocking,
 			  int extra_lock_flags);
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index c5f21cd..4131b49 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -3477,6 +3477,7 @@ static int lmv_quotactl(struct obd_device *unused, struct obd_export *exp,
 }
 
 static int lmv_merge_attr(struct obd_export *exp,
+			  const struct lu_fid *fid,
 			  const struct lmv_stripe_md *lsm,
 			  struct cl_attr *attr,
 			  ldlm_blocking_callback cb_blocking)
@@ -3486,7 +3487,7 @@ static int lmv_merge_attr(struct obd_export *exp,
 	if (!lmv_dir_striped(lsm))
 		return 0;
 
-	rc = lmv_revalidate_slaves(exp, lsm, cb_blocking, 0);
+	rc = lmv_revalidate_slaves(exp, fid, lsm, cb_blocking, 0);
 	if (rc < 0)
 		return rc;
 
-- 
1.8.3.1
