From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:52:12 -0400
Subject: [lustre-devel] [PATCH 05/11] lustre: lmv: checkpatch cleanup
In-Reply-To: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
References: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563760338-806-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Many checkpatch errors exist in the lmv layer. This address
a good chuck of them. Other are left since future patches will
cleanup those areas. Others will need more code rework so this
patch handles the simple cases. This is a good step forward
toward proper kernel code style compliance.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_intent.c |  9 ++++++---
 fs/lustre/lmv/lmv_obd.c    | 22 ++++++++++++++--------
 2 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 8892426..818bb72 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -222,7 +222,8 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 						      &RMF_MDT_BODY);
 			if (!body) {
 				if (it.it_lock_mode && lockh) {
-					ldlm_lock_decref(lockh, it.it_lock_mode);
+					ldlm_lock_decref(lockh,
+							 it.it_lock_mode);
 					it.it_lock_mode = 0;
 				}
 
@@ -309,7 +310,8 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 			return rc;
 	}
 
-	CDEBUG(D_INODE, "OPEN_INTENT with fid1=" DFID ", fid2=" DFID ", name='%s' -> mds #%u\n",
+	CDEBUG(D_INODE,
+	       "OPEN_INTENT with fid1=" DFID ", fid2=" DFID ", name='%s' -> mds #%u\n",
 	       PFID(&op_data->op_fid1),
 	       PFID(&op_data->op_fid2), op_data->op_name, tgt->ltd_idx);
 
@@ -387,7 +389,8 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	if (!fid_is_sane(&op_data->op_fid2))
 		fid_zero(&op_data->op_fid2);
 
-	CDEBUG(D_INODE, "LOOKUP_INTENT with fid1=" DFID ", fid2=" DFID ", name='%s' -> mds #%u lsm=%p lsm_magic=%x\n",
+	CDEBUG(D_INODE,
+	       "LOOKUP_INTENT with fid1=" DFID ", fid2=" DFID ", name='%s' -> mds #%u lsm=%p lsm_magic=%x\n",
 	       PFID(&op_data->op_fid1), PFID(&op_data->op_fid2),
 	       op_data->op_name ? op_data->op_name : "<NULL>",
 	       tgt->ltd_idx, lsm, !lsm ? -1 : lsm->lsm_md_magic);
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 64ebaf3..1c43022 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1630,7 +1630,8 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	if (rc == 0) {
 		if (!*request)
 			return rc;
-		CDEBUG(D_INODE, "Created - " DFID "\n", PFID(&op_data->op_fid2));
+		CDEBUG(D_INODE, "Created - " DFID "\n",
+		       PFID(&op_data->op_fid2));
 	}
 	return rc;
 }
@@ -1749,8 +1750,8 @@ static int lmv_early_cancel(struct obd_export *exp, struct lmv_tgt_desc *tgt,
 }
 
 /*
- * llite passes fid of an target inode in op_data->op_fid1 and id of directory in
- * op_data->op_fid2
+ * llite passes fid of an target inode in op_data->op_fid1 and id of
+ * directory in op_data->op_fid2
  */
 static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 		    struct ptlrpc_request **request)
@@ -1823,7 +1824,8 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_cap = current_cap();
 
 	if (op_data->op_cli_flags & CLI_MIGRATE) {
-		LASSERTF(fid_is_sane(&op_data->op_fid3), "invalid FID " DFID "\n",
+		LASSERTF(fid_is_sane(&op_data->op_fid3),
+			 "invalid FID " DFID "\n",
 			 PFID(&op_data->op_fid3));
 
 		if (op_data->op_mea1) {
@@ -2302,8 +2304,10 @@ static int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
 
-	if (unlikely(lsm))
-		return lmv_read_striped_page(exp, op_data, cb_op, offset, ppage);
+	if (unlikely(lsm)) {
+		return lmv_read_striped_page(exp, op_data, cb_op,
+					     offset, ppage);
+	}
 
 	tgt = lmv_find_target(lmv, &op_data->op_fid1);
 	if (IS_ERR(tgt))
@@ -2647,7 +2651,8 @@ static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
 	if (cplen >= sizeof(lsm->lsm_md_pool_name))
 		return -E2BIG;
 
-	CDEBUG(D_INFO, "unpack lsm count %d, master %d hash_type %d layout_version %d\n",
+	CDEBUG(D_INFO,
+	       "unpack lsm count %d, master %d hash_type %d layout_version %d\n",
 	       lsm->lsm_md_stripe_count, lsm->lsm_md_master_mdt_index,
 	       lsm->lsm_md_hash_type, lsm->lsm_md_layout_version);
 
@@ -3016,7 +3021,8 @@ static int lmv_merge_attr(struct obd_export *exp,
 	for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
 		struct inode *inode = lsm->lsm_md_oinfo[i].lmo_root;
 
-		CDEBUG(D_INFO, "" DFID " size %llu, blocks %llu nlink %u, atime %lld ctime %lld, mtime %lld.\n",
+		CDEBUG(D_INFO,
+		       "" DFID " size %llu, blocks %llu nlink %u, atime %lld ctime %lld, mtime %lld.\n",
 		       PFID(&lsm->lsm_md_oinfo[i].lmo_fid),
 		       i_size_read(inode), (unsigned long long)inode->i_blocks,
 		       inode->i_nlink, inode->i_atime.tv_sec,
-- 
1.8.3.1
