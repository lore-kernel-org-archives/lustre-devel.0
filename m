From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:15 -0500
Subject: [lustre-devel] [PATCH 447/622] lustre: lmv: disable remote file
 statahead
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-448-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Remote file statahead is not supported, because such file needs
two RPCs to fetch both LOOKUP and GETATTR lock, on LOOKUP success
we only know file FID, thus can't prepare an inode correctly.

Disable this to avoid noise messages and confusion.

Update sanity.sh test_60g.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11681
Lustre-commit: 02b5a407081c ("LU-11681 lmv: disable remote file statahead")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33930
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index d323250..26021bb 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -3416,25 +3416,28 @@ static int lmv_intent_getattr_async(struct obd_export *exp,
 	struct md_op_data *op_data = &minfo->mi_data;
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc *tgt = NULL;
+	struct lmv_tgt_desc *ptgt = NULL;
+	struct lmv_tgt_desc *ctgt;
 
 	if (!fid_is_sane(&op_data->op_fid2))
 		return -EINVAL;
 
-	tgt = lmv_find_target(lmv, &op_data->op_fid1);
-	if (IS_ERR(tgt))
-		return PTR_ERR(tgt);
+	ptgt = lmv_locate_tgt(lmv, op_data);
+	if (IS_ERR(ptgt))
+		return PTR_ERR(ptgt);
+
+	ctgt = lmv_find_target(lmv, &op_data->op_fid2);
+	if (IS_ERR(ctgt))
+		return PTR_ERR(ctgt);
 
 	/*
-	 * no special handle for remote dir, which needs to fetch both LOOKUP
-	 * lock on parent, and then UPDATE lock on child MDT, which makes all
-	 * complicated because this is done async. So only LOOKUP lock is
-	 * fetched for remote dir, but considering remote dir is rare case,
-	 * and not supporting it in statahead won't cause any issue, just leave
-	 * it as is.
+	 * remote object needs two RPCs to lookup and getattr, considering the
+	 * complexity don't support statahead for now.
 	 */
+	if (ctgt != ptgt)
+		return -EREMOTE;
 
-	return md_intent_getattr_async(tgt->ltd_exp, minfo);
+	return md_intent_getattr_async(ptgt->ltd_exp, minfo);
 }
 
 static int lmv_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
-- 
1.8.3.1
