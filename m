From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:57 -0400
Subject: [lustre-devel] [PATCH 118/124] staging: lustre: lmv: fix parent FID
	for migration
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-119-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

If the migrating directory is under striped directory, it needs
to set right stripe FID for its parent.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6263
Reviewed-on: http://review.whamcloud.com/13817
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |   30 ++++++++++++++++++++++----
 1 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index e4cf6d3..00a32e8 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1581,6 +1581,8 @@ lmv_locate_target_for_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
 	struct lmv_tgt_desc *tgt;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_BAD_NAME_HASH)) {
+		if (cfs_fail_val >= lsm->lsm_md_stripe_count)
+			return ERR_PTR(-EBADF);
 		oinfo = &lsm->lsm_md_oinfo[cfs_fail_val];
 	} else {
 		oinfo = lsm_name_to_stripe_info(lsm, name, namelen);
@@ -1588,11 +1590,15 @@ lmv_locate_target_for_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
 			return ERR_CAST(oinfo);
 	}
 
-	*fid = oinfo->lmo_fid;
-	*mds = oinfo->lmo_mds;
-	tgt = lmv_get_target(lmv, *mds, NULL);
+	if (fid)
+		*fid = oinfo->lmo_fid;
+	if (mds)
+		*mds = oinfo->lmo_mds;
+
+	tgt = lmv_get_target(lmv, oinfo->lmo_mds, NULL);
 
-	CDEBUG(D_INFO, "locate on mds %u "DFID"\n", *mds, PFID(fid));
+	CDEBUG(D_INFO, "locate on mds %u " DFID "\n", oinfo->lmo_mds,
+	       PFID(&oinfo->lmo_fid));
 	return tgt;
 }
 
@@ -1955,10 +1961,24 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	if (op_data->op_cli_flags & CLI_MIGRATE) {
 		LASSERTF(fid_is_sane(&op_data->op_fid3), "invalid FID "DFID"\n",
 			 PFID(&op_data->op_fid3));
+
+		if (op_data->op_mea1) {
+			struct lmv_stripe_md *lsm = op_data->op_mea1;
+			struct lmv_tgt_desc *tmp;
+
+			/* Fix the parent fid for striped dir */
+			tmp = lmv_locate_target_for_name(lmv, lsm, old,
+							 oldlen,
+							 &op_data->op_fid1,
+							 NULL);
+			if (IS_ERR(tmp))
+				return PTR_ERR(tmp);
+		}
+
 		rc = lmv_fid_alloc(NULL, exp, &op_data->op_fid2, op_data);
 		if (rc)
 			return rc;
-		src_tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid3);
+		src_tgt = lmv_find_target(lmv, &op_data->op_fid3);
 	} else {
 		if (op_data->op_mea1) {
 			struct lmv_stripe_md *lsm = op_data->op_mea1;
-- 
1.7.1
