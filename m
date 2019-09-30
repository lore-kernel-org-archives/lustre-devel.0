From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:38 -0400
Subject: [lustre-devel] [PATCH 019/151] lustre: statahead: support striped
 directory
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Current statahead will getattr by fid, but for striped directory,
it needs to fix its parent fid to stripe fid, which needs file
name, so pack file name in md_op_data.

Remove check for remote dir check in lmv_intent_getattr_async(),
which is not necessary, and not checking it won't cause anything
wrong, while the code is simpler.

WC-bug-id: https://jira.whamcloud.com/browse/LU-5106
Lustre-commit: 9e7952c045a3 ("LU-5106 statahead: support striped directory")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/27683
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: wangdi <di.wang@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/statahead.c |  3 ++-
 fs/lustre/lmv/lmv_obd.c     | 27 +++++++++++----------------
 2 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 797ad06..8fc4471 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -749,7 +749,8 @@ static void sa_fini_data(struct md_enqueue_info *minfo)
 	if (!minfo)
 		return ERR_PTR(-ENOMEM);
 
-	op_data = ll_prep_md_op_data(&minfo->mi_data, dir, child, NULL, 0, 0,
+	op_data = ll_prep_md_op_data(&minfo->mi_data, dir, child,
+				     entry->se_qstr.name, entry->se_qstr.len, 0,
 				     LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data)) {
 		kfree(minfo);
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index acef43d..946c757 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -2904,30 +2904,25 @@ static int lmv_intent_getattr_async(struct obd_export *exp,
 	struct md_op_data *op_data = &minfo->mi_data;
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc *ptgt = NULL;
-	struct lmv_tgt_desc *ctgt = NULL;
+	struct lmv_tgt_desc *tgt = NULL;
 
 	if (!fid_is_sane(&op_data->op_fid2))
 		return -EINVAL;
 
-	ptgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
-	if (IS_ERR(ptgt))
-		return PTR_ERR(ptgt);
-
-	ctgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid2);
-	if (IS_ERR(ctgt))
-		return PTR_ERR(ctgt);
+	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
+	if (IS_ERR(tgt))
+		return PTR_ERR(tgt);
 
 	/*
-	 * if child is on remote MDT, we need 2 async RPCs to fetch both LOOKUP
-	 * lock on parent, and UPDATE lock on child MDT, which makes all
-	 * complicated. Considering remote dir is rare case, and not supporting
-	 * it in statahead won't cause any issue, drop its support for now.
+	 * no special handle for remote dir, which needs to fetch both LOOKUP
+	 * lock on parent, and then UPDATE lock on child MDT, which makes all
+	 * complicated because this is done async. So only LOOKUP lock is
+	 * fetched for remote dir, but considering remote dir is rare case,
+	 * and not supporting it in statahead won't cause any issue, just leave
+	 * it as is.
 	 */
-	if (ptgt != ctgt)
-		return -ENOTSUPP;
 
-	return md_intent_getattr_async(ptgt->ltd_exp, minfo);
+	return md_intent_getattr_async(tgt->ltd_exp, minfo);
 }
 
 static int lmv_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
-- 
1.8.3.1
