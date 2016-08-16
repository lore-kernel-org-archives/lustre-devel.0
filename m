From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:27 -0400
Subject: [lustre-devel] [PATCH 14/80] staging: lustre: delete striped
	directory
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Add delete striped directory, it includes

1. enable sync log between MDTs, so slave objects will
   be delete by unlink log, which is similar as deleting ost
   object.

2. retrieve layout information of striped directory on MDT,
   then lock all of the slave objects before unlink.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-on: http://review.whamcloud.com/7445
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |    1 +
 drivers/staging/lustre/lustre/include/lustre_fid.h |    1 +
 drivers/staging/lustre/lustre/llite/dir.c          |   10 ---
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |    5 ++
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   75 +++++++++++++++-----
 5 files changed, 65 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 60051a5..f7805cc 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -968,6 +968,7 @@ struct ldlm_enqueue_info {
 	void *ei_cb_cp;  /** lock completion callback */
 	void *ei_cb_gl;  /** lock glimpse callback */
 	void *ei_cbdata; /** Data to be passed into callbacks. */
+	unsigned int ei_enq_slave:1; /* whether enqueue slave stripes */
 };
 
 extern struct obd_ops ldlm_obd_ops;
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 743671a..61f3930 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -229,6 +229,7 @@ enum local_oid {
 	MDD_LOV_OBJ_OSEQ	= 4121UL,
 	LFSCK_NAMESPACE_OID     = 4122UL,
 	REMOTE_PARENT_DIR_OID	= 4123UL,
+	SLAVE_LLOG_CATALOGS_OID	= 4124UL,
 };
 
 static inline void lu_local_obj_fid(struct lu_fid *fid, __u32 oid)
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 5288750..96ae7d5 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -679,16 +679,6 @@ static int ll_dir_setdirstripe(struct inode *dir, struct lmv_user_md *lump,
 	if (unlikely(lump->lum_magic != LMV_USER_MAGIC))
 		return -EINVAL;
 
-	if (lump->lum_stripe_offset == (__u32)-1) {
-		int mdtidx;
-
-		mdtidx = ll_get_mdt_idx(dir);
-		if (mdtidx < 0)
-			return mdtidx;
-
-		lump->lum_stripe_offset = mdtidx;
-	}
-
 	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p) name %s stripe_offset %d, stripe_count: %u\n",
 	       PFID(ll_inode2fid(dir)), dir, filename,
 	       (int)lump->lum_stripe_offset, lump->lum_stripe_count);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 1b9bbb2..5313dfc 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -244,6 +244,11 @@ update:
 				if (req)
 					ptlrpc_req_finished(req);
 
+				if (it.it_lock_mode && lockh) {
+					ldlm_lock_decref(lockh, it.it_lock_mode);
+					it.it_lock_mode = 0;
+				}
+
 				rc = -EIO;
 				goto cleanup;
 			}
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index da4855d..81dcc0a 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -101,6 +101,9 @@ int lmv_name_to_stripe_index(enum lmv_hash_type hashtype,
 		return -EINVAL;
 	}
 
+	CDEBUG(D_INFO, "name %.*s hash_type %d idx %d\n", namelen, name,
+	       hashtype, idx);
+
 	LASSERT(idx < max_mdt_index);
 	return idx;
 }
@@ -1230,7 +1233,16 @@ static int lmv_placement_policy(struct obd_device *obd,
 		struct lmv_user_md *lum;
 
 		lum = op_data->op_data;
-		*mds = lum->lum_stripe_offset;
+		if (lum->lum_stripe_offset != (__u32)-1) {
+			*mds = lum->lum_stripe_offset;
+		} else {
+			/*
+			 * -1 means default, which will be in the same MDT with
+			 * the stripe
+			 */
+			*mds = op_data->op_mds;
+			lum->lum_stripe_offset = op_data->op_mds;
+		}
 	} else {
 		/*
 		 * Allocate new fid on target according to operation type and
@@ -1646,12 +1658,28 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
  * For striped-directory, it will locate MDT by name. And also
  * it will reset op_fid1 with the FID of the chosen stripe.
  **/
+struct lmv_tgt_desc *
+lmv_locate_target_for_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
+			   const char *name, int namelen, struct lu_fid *fid,
+			   u32 *mds)
+{
+	const struct lmv_oinfo *oinfo;
+	struct lmv_tgt_desc *tgt;
+
+	oinfo = lsm_name_to_stripe_info(lsm, name, namelen);
+	*fid = oinfo->lmo_fid;
+	*mds = oinfo->lmo_mds;
+	tgt = lmv_get_target(lmv, *mds);
+
+	CDEBUG(D_INFO, "locate on mds %u "DFID"\n", *mds, PFID(fid));
+	return tgt;
+}
+
 struct lmv_tgt_desc
 *lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
 		struct lu_fid *fid)
 {
 	struct lmv_stripe_md *lsm = op_data->op_mea1;
-	const struct lmv_oinfo *oinfo;
 	struct lmv_tgt_desc *tgt;
 
 	if (!lsm || lsm->lsm_md_stripe_count <= 1 ||
@@ -1665,15 +1693,9 @@ struct lmv_tgt_desc
 		return tgt;
 	}
 
-	oinfo = lsm_name_to_stripe_info(lsm, op_data->op_name,
-					op_data->op_namelen);
-	*fid = oinfo->lmo_fid;
-	op_data->op_mds = oinfo->lmo_mds;
-	tgt = lmv_get_target(lmv, op_data->op_mds);
-
-	CDEBUG(D_INFO, "locate on mds %u\n", op_data->op_mds);
-
-	return tgt;
+	return lmv_locate_target_for_name(lmv, lsm, op_data->op_name,
+					  op_data->op_namelen, fid,
+					  &op_data->op_mds);
 }
 
 static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
@@ -2075,6 +2097,9 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 				      LCK_EX, MDS_INODELOCK_FULL,
 				      MF_MDC_CANCEL_FID4);
 
+	CDEBUG(D_INODE, DFID":m%d to "DFID"\n", PFID(&op_data->op_fid1),
+	       op_data->op_mds, PFID(&op_data->op_fid2));
+
 	if (rc == 0)
 		rc = md_rename(src_tgt->ltd_exp, op_data, old, oldlen,
 			       new, newlen, request);
@@ -2288,12 +2313,26 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 		return rc;
 retry:
 	/* Send unlink requests to the MDT where the child is located */
-	if (likely(!fid_is_zero(&op_data->op_fid2)))
-		tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid2);
-	else
+	if (likely(!fid_is_zero(&op_data->op_fid2))) {
+		tgt = lmv_find_target(lmv, &op_data->op_fid2);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
+
+		/* For striped dir, we need to locate the parent as well */
+		if (op_data->op_mea1 &&
+		    op_data->op_mea1->lsm_md_stripe_count > 1) {
+			LASSERT(op_data->op_name && op_data->op_namelen);
+			lmv_locate_target_for_name(lmv, op_data->op_mea1,
+						   op_data->op_name,
+						   op_data->op_namelen,
+						   &op_data->op_fid1,
+						   &op_data->op_mds);
+		}
+	} else {
 		tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
-	if (IS_ERR(tgt))
-		return PTR_ERR(tgt);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
+	}
 
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
@@ -2799,8 +2838,10 @@ static int lmv_free_lustre_md(struct obd_export *exp, struct lustre_md *md)
 	struct lmv_obd	  *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt = lmv->tgts[0];
 
-	if (md->lmv)
+	if (md->lmv) {
 		lmv_free_memmd(md->lmv);
+		md->lmv = NULL;
+	}
 	if (!tgt || !tgt->ltd_exp)
 		return -EINVAL;
 	return md_free_lustre_md(tgt->ltd_exp, md);
-- 
1.7.1
