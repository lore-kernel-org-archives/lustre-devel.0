From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:20 -0400
Subject: [lustre-devel] [PATCH 28/31] lustre: obdclass: improve missing
 operation message
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Some tests in the past reported missing OBD operations, so improve
the error message to include the device name to make it easier to
debug where this is happening.

Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
WC-id: https://jira.whamcloud.com/browse/LU-1095
Reviewed-on: https://review.whamcloud.com/25586
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd_class.h | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 50d5ddb..fd9d99b 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -398,7 +398,7 @@ static inline int obd_check_dev_active(struct obd_device *obd)
 		return -EOPNOTSUPP;				\
 	}							\
 	if (!OBT((exp)->exp_obd) || !MDP((exp)->exp_obd, op)) {	\
-		CERROR("obd_" #op ": dev %s/%d no operation\n", \
+		CERROR("%s: obd_" #op ": dev %d no operation\n",\
 			(exp)->exp_obd->obd_name,		\
 			(exp)->exp_obd->obd_minor);		\
 		return -EOPNOTSUPP;				\
@@ -409,8 +409,8 @@ static inline int obd_check_dev_active(struct obd_device *obd)
 do {									\
 	if (!OBT(obd) || !OBP((obd), op)) {				\
 		if (err)						\
-			CERROR("obd_" #op ": dev %d no operation\n",	\
-				obd->obd_minor);			\
+			CERROR("%s: no obd_" #op " operation\n",	\
+				obd->obd_name);				\
 		return err;						\
 	}								\
 } while (0)
@@ -425,19 +425,15 @@ static inline int obd_check_dev_active(struct obd_device *obd)
 		CERROR("obd_" #op ": cleaned up obd\n");	\
 		return -EOPNOTSUPP;				\
 	}							\
-	if (!OBT((exp)->exp_obd) || !OBP((exp)->exp_obd, op)) {	\
-		CERROR("obd_" #op ": dev %d no operation\n",	\
-			(exp)->exp_obd->obd_minor);		\
-		return -EOPNOTSUPP;				\
-	}							\
+	OBD_CHECK_DT_OP((exp)->exp_obd, op, -EOPNOTSUPP);	\
 } while (0)
 
 #define CTXT_CHECK_OP(ctxt, op, err)					\
 do {									\
 	if (!OBT(ctxt->loc_obd) || !CTXTP((ctxt), op)) {		\
 		if (err)						\
-			CERROR("lop_" #op ": dev %d no operation\n",	\
-				ctxt->loc_obd->obd_minor);		\
+			CERROR("%s: no lop_" #op " operation\n",	\
+				ctxt->loc_obd->obd_name);		\
 		return err;						\
 	}								\
 } while (0)
-- 
1.8.3.1
