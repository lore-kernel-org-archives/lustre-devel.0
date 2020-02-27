From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:29 -0500
Subject: [lustre-devel] [PATCH 041/622] lustre: lmv: dir page is released
 while in use
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-42-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

When popping stripe dirent, if it reaches page end,
stripe_dirent_next() releases current page and then reads next one,
but current dirent is still in use, as will cause wrong values used,
and trigger assertion.

This patch changes to not read next page upon reaching end, but
leave it to next dirent read.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9857
Lustre-commit: b51e8d6b53a3 ("LU-9857 lmv: dir page is released while in use")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32180
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c | 123 +++++++++++++++++++++++-------------------------
 1 file changed, 60 insertions(+), 63 deletions(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index d0f626f..c7bf8c7 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -2016,7 +2016,7 @@ struct lmv_dir_ctxt {
 	struct stripe_dirent	 ldc_stripes[0];
 };
 
-static inline void put_stripe_dirent(struct stripe_dirent *stripe)
+static inline void stripe_dirent_unload(struct stripe_dirent *stripe)
 {
 	if (stripe->sd_page) {
 		kunmap(stripe->sd_page);
@@ -2031,62 +2031,77 @@ static inline void put_lmv_dir_ctxt(struct lmv_dir_ctxt *ctxt)
 	int i;
 
 	for (i = 0; i < ctxt->ldc_count; i++)
-		put_stripe_dirent(&ctxt->ldc_stripes[i]);
+		stripe_dirent_unload(&ctxt->ldc_stripes[i]);
 }
 
-static struct lu_dirent *stripe_dirent_next(struct lmv_dir_ctxt *ctxt,
+/* if @ent is dummy, or . .., get next */
+static struct lu_dirent *stripe_dirent_get(struct lmv_dir_ctxt *ctxt,
+					   struct lu_dirent *ent,
+					   int stripe_index)
+{
+	for (; ent; ent = lu_dirent_next(ent)) {
+		/* Skip dummy entry */
+		if (le16_to_cpu(ent->lde_namelen) == 0)
+			continue;
+
+		/* skip . and .. for other stripes */
+		if (stripe_index &&
+		    (strncmp(ent->lde_name, ".",
+			     le16_to_cpu(ent->lde_namelen)) == 0 ||
+		     strncmp(ent->lde_name, "..",
+			     le16_to_cpu(ent->lde_namelen)) == 0))
+			continue;
+
+		if (le64_to_cpu(ent->lde_hash) >= ctxt->ldc_hash)
+			break;
+	}
+
+	return ent;
+}
+
+static struct lu_dirent *stripe_dirent_load(struct lmv_dir_ctxt *ctxt,
 					    struct stripe_dirent *stripe,
 					    int stripe_index)
 {
+	struct md_op_data *op_data = ctxt->ldc_op_data;
+	struct lmv_oinfo *oinfo;
+	struct lu_fid fid = op_data->op_fid1;
+	struct inode *inode = op_data->op_data;
+	struct lmv_tgt_desc *tgt;
 	struct lu_dirent *ent = stripe->sd_ent;
 	u64 hash = ctxt->ldc_hash;
-	u64 end;
 	int rc = 0;
 
 	LASSERT(stripe == &ctxt->ldc_stripes[stripe_index]);
-
-	if (stripe->sd_eof)
-		return NULL;
-
-	if (ent) {
-		ent = lu_dirent_next(ent);
-		if (!ent) {
-check_eof:
-			end = le64_to_cpu(stripe->sd_dp->ldp_hash_end);
-
-			LASSERTF(hash <= end, "hash %llx end %llx\n",
-				 hash, end);
+	LASSERT(!ent);
+
+	do {
+		if (stripe->sd_page) {
+			u64 end = le64_to_cpu(stripe->sd_dp->ldp_hash_end);
+
+			/* @hash should be the last dirent hash */
+			LASSERTF(hash <= end,
+				 "ctxt@%p stripe@%p hash %llx end %llx\n",
+				 ctxt, stripe, hash, end);
+			/* unload last page */
+			stripe_dirent_unload(stripe);
+			/* eof */
 			if (end == MDS_DIR_END_OFF) {
 				stripe->sd_ent = NULL;
 				stripe->sd_eof = true;
-				return NULL;
+				break;
 			}
-
-			put_stripe_dirent(stripe);
 			hash = end;
 		}
-	}
-
-	if (!ent) {
-		struct md_op_data *op_data = ctxt->ldc_op_data;
-		struct lmv_oinfo *oinfo;
-		struct lu_fid fid = op_data->op_fid1;
-		struct inode *inode = op_data->op_data;
-		struct lmv_tgt_desc *tgt;
-
-		LASSERT(!stripe->sd_page);
 
 		oinfo = &op_data->op_mea1->lsm_md_oinfo[stripe_index];
 		tgt = lmv_get_target(ctxt->ldc_lmv, oinfo->lmo_mds, NULL);
 		if (IS_ERR(tgt)) {
 			rc = PTR_ERR(tgt);
-			goto out;
+			break;
 		}
 
-		/*
-		 * op_data will be shared by each stripe, so we need
-		 * reset these value for each stripe
-		 */
+		/* op_data is shared by stripes, reset after use */
 		op_data->op_fid1 = oinfo->lmo_fid;
 		op_data->op_fid2 = oinfo->lmo_fid;
 		op_data->op_data = oinfo->lmo_root;
@@ -2099,42 +2114,24 @@ static struct lu_dirent *stripe_dirent_next(struct lmv_dir_ctxt *ctxt,
 		op_data->op_data = inode;
 
 		if (rc)
-			goto out;
-
-		stripe->sd_dp = page_address(stripe->sd_page);
-		ent = lu_dirent_start(stripe->sd_dp);
-	}
-
-	for (; ent; ent = lu_dirent_next(ent)) {
-		/* Skip dummy entry */
-		if (!le16_to_cpu(ent->lde_namelen))
-			continue;
-
-		/* skip . and .. for other stripes */
-		if (stripe_index &&
-		    (strncmp(ent->lde_name, ".",
-			     le16_to_cpu(ent->lde_namelen)) == 0 ||
-		     strncmp(ent->lde_name, "..",
-			     le16_to_cpu(ent->lde_namelen)) == 0))
-			continue;
-
-		if (le64_to_cpu(ent->lde_hash) >= hash)
 			break;
-	}
 
-	if (!ent)
-		goto check_eof;
+		stripe->sd_dp = page_address(stripe->sd_page);
+		ent = stripe_dirent_get(ctxt, lu_dirent_start(stripe->sd_dp),
+					stripe_index);
+		/* in case a page filled with ., .. and dummy, read next */
+	} while (!ent);
 
-out:
 	stripe->sd_ent = ent;
-	/* treat error as eof, so dir can be partially accessed */
 	if (rc) {
-		put_stripe_dirent(stripe);
+		LASSERT(!ent);
+		/* treat error as eof, so dir can be partially accessed */
 		stripe->sd_eof = true;
 		LCONSOLE_WARN("dir " DFID " stripe %d readdir failed: %d, directory is partially accessed!\n",
 			      PFID(&ctxt->ldc_op_data->op_fid1), stripe_index,
 			      rc);
 	}
+
 	return ent;
 }
 
@@ -2186,8 +2183,7 @@ static struct lu_dirent *lmv_dirent_next(struct lmv_dir_ctxt *ctxt)
 			continue;
 
 		if (!stripe->sd_ent) {
-			/* locate starting entry */
-			stripe_dirent_next(ctxt, stripe, i);
+			stripe_dirent_load(ctxt, stripe, i);
 			if (!stripe->sd_ent) {
 				LASSERT(stripe->sd_eof);
 				continue;
@@ -2208,7 +2204,8 @@ static struct lu_dirent *lmv_dirent_next(struct lmv_dir_ctxt *ctxt)
 		stripe = &ctxt->ldc_stripes[min];
 		ent = stripe->sd_ent;
 		/* pop found dirent */
-		stripe_dirent_next(ctxt, stripe, min);
+		stripe->sd_ent = stripe_dirent_get(ctxt, lu_dirent_next(ent),
+						   min);
 	}
 
 	return ent;
-- 
1.8.3.1
