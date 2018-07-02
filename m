From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:21 -0400
Subject: [lustre-devel] [PATCH 04/18] lustre: obd: rename md_getstatus() to
 md_get_root()
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

Finish the partial renaming of the the OBD MD method
md_getstatus() to md_get_root().

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8035
Reviewed-on: http://review.whamcloud.com/19824
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h       |  2 +-
 drivers/staging/lustre/lustre/include/obd_class.h | 10 +++++-----
 drivers/staging/lustre/lustre/lmv/lmv_obd.c       |  6 +++---
 drivers/staging/lustre/lustre/mdc/mdc_request.c   |  2 +-
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index cd2a2d0..d4574ef 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -920,7 +920,7 @@ struct obd_client_handle {
 struct cl_attr;
 
 struct md_ops {
-	int (*getstatus)(struct obd_export *exp, const char *fileset,
+	int (*get_root)(struct obd_export *exp, const char *fileset,
 			 struct lu_fid *fid);
 	int (*null_inode)(struct obd_export *, const struct lu_fid *);
 	int (*close)(struct obd_export *, struct md_op_data *,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 797986b..20d07f8 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -356,8 +356,8 @@ static inline int obd_check_dev_active(struct obd_device *obd)
 
 #define MD_COUNTER_OFFSET(op)					\
 	((offsetof(struct md_ops, op) -				\
-		offsetof(struct md_ops, getstatus))		\
-		/ sizeof(((struct md_ops *)(0))->getstatus))
+		offsetof(struct md_ops, get_root))		\
+		/ sizeof(((struct md_ops *)(0))->get_root))
 
 #define MD_COUNTER_INCREMENT(obdx, op)				 \
 do {								 \
@@ -1185,9 +1185,9 @@ static inline int md_get_root(struct obd_export *exp, const char *fileset,
 {
 	int rc;
 
-	EXP_CHECK_MD_OP(exp, getstatus);
-	EXP_MD_COUNTER_INCREMENT(exp, getstatus);
-	rc = MDP(exp->exp_obd, getstatus)(exp, fileset, fid);
+	EXP_CHECK_MD_OP(exp, get_root);
+	EXP_MD_COUNTER_INCREMENT(exp, get_root);
+	rc = MDP(exp->exp_obd, get_root)(exp, fileset, fid);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 44fbaa6..71109ba 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1391,8 +1391,8 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 	return rc;
 }
 
-static int lmv_getstatus(struct obd_export *exp, const char *fileset,
-			 struct lu_fid *fid)
+static int lmv_get_root(struct obd_export *exp, const char *fileset,
+			struct lu_fid *fid)
 {
 	struct obd_device    *obd = exp->exp_obd;
 	struct lmv_obd       *lmv = &obd->u.lmv;
@@ -3076,7 +3076,7 @@ static int lmv_merge_attr(struct obd_export *exp,
 };
 
 static struct md_ops lmv_md_ops = {
-	.getstatus		= lmv_getstatus,
+	.get_root		= lmv_get_root,
 	.null_inode		= lmv_null_inode,
 	.close			= lmv_close,
 	.create			= lmv_create,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 2e01f57..7457039 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2747,7 +2747,7 @@ static int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
 };
 
 static struct md_ops mdc_md_ops = {
-	.getstatus		= mdc_get_root,
+	.get_root		= mdc_get_root,
 	.null_inode		= mdc_null_inode,
 	.close			= mdc_close,
 	.create			= mdc_create,
-- 
1.8.3.1
