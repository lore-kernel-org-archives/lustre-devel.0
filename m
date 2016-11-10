From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:31:03 -0500
Subject: [lustre-devel] [PATCH 33/35] staging: lustre: hsm: prevent
	migration of HSM archived files
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

The reference copytool cannot handle migration of HSM archive
files. In the MDT migration path check for HSM attributes and fail if
they are present. In the LMV layer allow creation of volatile files
with any MDT index. Add a test to sanity-hsm to ensure that attempting
to migrate an HSM archive file is handled safely.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6866
Reviewed-on: http://review.whamcloud.com/17511
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 9335ffe..0e94a58 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1619,27 +1619,28 @@ struct lmv_tgt_desc*
 	 * ct_restore().
 	 */
 	if (op_data->op_bias & MDS_CREATE_VOLATILE &&
-	    (int)op_data->op_mds != -1 && lsm) {
+	    (int)op_data->op_mds != -1) {
 		int i;
 
 		tgt = lmv_get_target(lmv, op_data->op_mds, NULL);
 		if (IS_ERR(tgt))
 			return tgt;
 
-		/* refill the right parent fid */
-		for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
-			struct lmv_oinfo *oinfo;
+		if (lsm) {
+			/* refill the right parent fid */
+			for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
+				struct lmv_oinfo *oinfo;
 
-			oinfo = &lsm->lsm_md_oinfo[i];
-			if (oinfo->lmo_mds == op_data->op_mds) {
-				*fid = oinfo->lmo_fid;
-				break;
+				oinfo = &lsm->lsm_md_oinfo[i];
+				if (oinfo->lmo_mds == op_data->op_mds) {
+					*fid = oinfo->lmo_fid;
+					break;
+				}
 			}
-		}
 
-		/* Hmm, can not find the stripe by mdt_index(op_mds) */
-		if (i == lsm->lsm_md_stripe_count)
-			tgt = ERR_PTR(-EINVAL);
+			if (i == lsm->lsm_md_stripe_count)
+				*fid = lsm->lsm_md_oinfo[0].lmo_fid;
+		}
 
 		return tgt;
 	}
-- 
1.7.1
