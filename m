From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:41 -0400
Subject: [lustre-devel] [PATCH 042/124] staging: lustre: obd: change type of
	lmv_tgt_desc->ltd_idx to u32
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-43-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

ltd_idx is used as unsigned.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5577
Reviewed-on: http://review.whamcloud.com/11879
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h    |    2 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c |    8 ++++----
 drivers/staging/lustre/lustre/lmv/lmv_obd.c    |    6 +++---
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c  |    2 +-
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 19230a9..4b72fb9 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -406,7 +406,7 @@ struct lov_obd {
 struct lmv_tgt_desc {
 	struct obd_uuid		ltd_uuid;
 	struct obd_export	*ltd_exp;
-	int			ltd_idx;
+	u32			ltd_idx;
 	struct mutex		ltd_fid_mutex;
 	unsigned long		ltd_active:1; /* target up for requests */
 };
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index f24848f..1952454 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -113,7 +113,7 @@ static int lmv_intent_remote(struct obd_export *exp, struct lookup_intent *it,
 	}
 
 	op_data->op_bias = MDS_CROSS_REF;
-	CDEBUG(D_INODE, "REMOTE_INTENT with fid="DFID" -> mds #%d\n",
+	CDEBUG(D_INODE, "REMOTE_INTENT with fid=" DFID " -> mds #%u\n",
 	       PFID(&body->mbo_fid1), tgt->ltd_idx);
 
 	rc = md_intent_lock(tgt->ltd_exp, op_data, it, &req, cb_blocking,
@@ -202,7 +202,7 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 			goto cleanup;
 		}
 
-		CDEBUG(D_INODE, "Revalidate slave "DFID" -> mds #%d\n",
+		CDEBUG(D_INODE, "Revalidate slave " DFID " -> mds #%u\n",
 		       PFID(&fid), tgt->ltd_idx);
 
 		if (req) {
@@ -349,7 +349,7 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 			return rc;
 	}
 
-	CDEBUG(D_INODE, "OPEN_INTENT with fid1=" DFID ", fid2=" DFID ", name='%s' -> mds #%d\n",
+	CDEBUG(D_INODE, "OPEN_INTENT with fid1=" DFID ", fid2=" DFID ", name='%s' -> mds #%u\n",
 	       PFID(&op_data->op_fid1),
 	       PFID(&op_data->op_fid2), op_data->op_name, tgt->ltd_idx);
 
@@ -427,7 +427,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	if (!fid_is_sane(&op_data->op_fid2))
 		fid_zero(&op_data->op_fid2);
 
-	CDEBUG(D_INODE, "LOOKUP_INTENT with fid1="DFID", fid2="DFID", name='%s' -> mds #%d lsm=%p lsm_magic=%x\n",
+	CDEBUG(D_INODE, "LOOKUP_INTENT with fid1=" DFID ", fid2=" DFID ", name='%s' -> mds #%u lsm=%p lsm_magic=%x\n",
 	       PFID(&op_data->op_fid1), PFID(&op_data->op_fid2),
 	       op_data->op_name ? op_data->op_name : "<NULL>",
 	       tgt->ltd_idx, lsm, !lsm ? -1 : lsm->lsm_md_magic);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 208a44d..b852a65 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1836,7 +1836,7 @@ lmv_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
-	CDEBUG(D_INODE, "ENQUEUE '%s' on "DFID" -> mds #%d\n",
+	CDEBUG(D_INODE, "ENQUEUE '%s' on " DFID " -> mds #%u\n",
 	       LL_IT2STR(it), PFID(&op_data->op_fid1), tgt->ltd_idx);
 
 	rc = md_enqueue(tgt->ltd_exp, einfo, policy, it, op_data, lockh,
@@ -1864,7 +1864,7 @@ lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
-	CDEBUG(D_INODE, "GETATTR_NAME for %*s on "DFID" -> mds #%d\n",
+	CDEBUG(D_INODE, "GETATTR_NAME for %*s on " DFID " -> mds #%u\n",
 	       op_data->op_namelen, op_data->op_name, PFID(&op_data->op_fid1),
 	       tgt->ltd_idx);
 
@@ -2609,7 +2609,7 @@ try_next_stripe:
 	if (rc != 0)
 		return rc;
 
-	CDEBUG(D_INODE, "unlink with fid="DFID"/"DFID" -> mds #%d\n",
+	CDEBUG(D_INODE, "unlink with fid=" DFID "/" DFID " -> mds #%u\n",
 	       PFID(&op_data->op_fid1), PFID(&op_data->op_fid2), tgt->ltd_idx);
 
 	rc = md_unlink(tgt->ltd_exp, op_data, request);
diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
index d2316c0..20bbdfc 100644
--- a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
+++ b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
@@ -169,7 +169,7 @@ static int lmv_tgt_seq_show(struct seq_file *p, void *v)
 
 	if (!tgt)
 		return 0;
-	seq_printf(p, "%d: %s %sACTIVE\n",
+	seq_printf(p, "%u: %s %sACTIVE\n",
 		   tgt->ltd_idx, tgt->ltd_uuid.uuid,
 		   tgt->ltd_active ? "" : "IN");
 	return 0;
-- 
1.7.1
