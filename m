From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:25:56 -0400
Subject: [lustre-devel] [PATCH 04/31] lustre: lmv: honour the specified
 stripe index
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Di Wang <di.wang@intel.com>

when creating the striped directory, specified
stripe index should always be used even the parent
has default stripe index.

Signed-off-by: Di Wang <di.wang@intel.com>
WC-id: https://jira.whamcloud.com/browse/LU-8994
Reviewed-on: https://review.whamcloud.com/24777
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c | 44 +++++++++++------------------
 1 file changed, 17 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 3da5a0a..bbb1ddf 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1128,7 +1128,8 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 static int lmv_placement_policy(struct obd_device *obd,
 				struct md_op_data *op_data, u32 *mds)
 {
-	struct lmv_obd	  *lmv = &obd->u.lmv;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_user_md *lum;
 
 	LASSERT(mds);
 
@@ -1137,34 +1138,23 @@ static int lmv_placement_policy(struct obd_device *obd,
 		return 0;
 	}
 
-	if (op_data->op_default_stripe_offset != -1) {
-		*mds = op_data->op_default_stripe_offset;
-		return 0;
-	}
-
-	/**
-	 * If stripe_offset is provided during setdirstripe
-	 * (setdirstripe -i xx), xx MDS will be chosen.
+	lum = op_data->op_data;
+	/* Choose MDS by
+	 * 1. See if the stripe offset is specified by lum.
+	 * 2. Then check if there is default stripe offset.
+	 * 3. Finally choose MDS by name hash if the parent
+	 *    is striped directory. (see lmv_locate_mds()).
 	 */
-	if (op_data->op_cli_flags & CLI_SET_MEA && op_data->op_data) {
-		struct lmv_user_md *lum;
-
-		lum = op_data->op_data;
-		if (le32_to_cpu(lum->lum_stripe_offset) != (__u32)-1) {
-			*mds = le32_to_cpu(lum->lum_stripe_offset);
-		} else {
-			/*
-			 * -1 means default, which will be in the same MDT with
-			 * the stripe
-			 */
-			*mds = op_data->op_mds;
-			lum->lum_stripe_offset = cpu_to_le32(op_data->op_mds);
-		}
+	if (op_data->op_cli_flags & CLI_SET_MEA && lum &&
+	    le32_to_cpu(lum->lum_stripe_offset) != (u32)-1) {
+		*mds = le32_to_cpu(lum->lum_stripe_offset);
+	} else if (op_data->op_default_stripe_offset != (u32)-1) {
+		*mds = op_data->op_default_stripe_offset;
+		op_data->op_mds = *mds;
+		/* Correct the stripe offset in lum */
+		if (lum)
+			lum->lum_stripe_offset = cpu_to_le32(*mds);
 	} else {
-		/*
-		 * Allocate new fid on target according to operation type and
-		 * parent home mds.
-		 */
 		*mds = op_data->op_mds;
 	}
 
-- 
1.8.3.1
