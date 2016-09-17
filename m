From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Sat, 17 Sep 2016 20:04:36 +0800
Subject: [lustre-devel] [PATCH] staging: lustre: lmv: mark symbols static
	where possible
Message-ID: <1474113876-20343-1-git-send-email-baoyou.xie@linaro.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, john.hammond@intel.com, di.wang@intel.com, dmitry.eremin@intel.com, jian.yu@intel.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn

We get a few warnings when building kernel with W=1:
drivers/staging/lustre/lustre/lmv/lmv_obd.c:1640:1: warning: no previous prototype for 'lmv_locate_target_for_name' [-Wmissing-prototypes]
drivers/staging/lustre/lustre/lmv/lmv_obd.c:2421:5: warning: no previous prototype for 'lmv_read_page' [-Wmissing-prototypes]
....

In fact, these functions are only used in the file in which they are
declared and don't need a declaration, but can be made static.
so this patch marks these functions with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c | 38 ++++++++++++++++-------------
 1 file changed, 21 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index dc752d5..5783359 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1636,7 +1636,7 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
  * For striped-directory, it will locate MDT by name. And also
  * it will reset op_fid1 with the FID of the chosen stripe.
  **/
-struct lmv_tgt_desc *
+static struct lmv_tgt_desc *
 lmv_locate_target_for_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
 			   const char *name, int namelen, struct lu_fid *fid,
 			   u32 *mds)
@@ -2418,9 +2418,9 @@ static int lmv_read_striped_page(struct obd_export *exp,
 	return rc;
 }
 
-int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
-		  struct md_callback *cb_op, __u64 offset,
-		  struct page **ppage)
+static int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
+			 struct md_callback *cb_op, __u64 offset,
+			 struct page **ppage)
 {
 	struct lmv_stripe_md *lsm = op_data->op_mea1;
 	struct obd_device *obd = exp->exp_obd;
@@ -2771,8 +2771,9 @@ static int lmv_pack_md_v1(const struct lmv_stripe_md *lsm,
 	return 0;
 }
 
-int lmv_pack_md(union lmv_mds_md **lmmp, const struct lmv_stripe_md *lsm,
-		int stripe_count)
+static int
+lmv_pack_md(union lmv_mds_md **lmmp, const struct lmv_stripe_md *lsm,
+	    int stripe_count)
 {
 	int lmm_size = 0, rc = 0;
 	bool allocated = false;
@@ -2966,15 +2967,15 @@ int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 }
 EXPORT_SYMBOL(lmv_unpack_md);
 
-int lmv_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
-		 struct lov_mds_md *lmm, int disk_len)
+static int lmv_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
+			struct lov_mds_md *lmm, int disk_len)
 {
 	return lmv_unpack_md(exp, (struct lmv_stripe_md **)lsmp,
 			     (union lmv_mds_md *)lmm, disk_len);
 }
 
-int lmv_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
-	       struct lov_stripe_md *lsm)
+static int lmv_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
+		      struct lov_stripe_md *lsm)
 {
 	const struct lmv_stripe_md *lmv = (struct lmv_stripe_md *)lsm;
 	struct obd_device *obd = exp->exp_obd;
@@ -3177,9 +3178,10 @@ static int lmv_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 	return rc;
 }
 
-int lmv_get_fid_from_lsm(struct obd_export *exp,
-			 const struct lmv_stripe_md *lsm,
-			 const char *name, int namelen, struct lu_fid *fid)
+static int
+lmv_get_fid_from_lsm(struct obd_export *exp,
+		     const struct lmv_stripe_md *lsm,
+		     const char *name, int namelen, struct lu_fid *fid)
 {
 	const struct lmv_oinfo *oinfo;
 
@@ -3269,14 +3271,16 @@ static int lmv_quotacheck(struct obd_device *unused, struct obd_export *exp,
 	return rc;
 }
 
-int lmv_update_lsm_md(struct obd_export *exp, struct lmv_stripe_md *lsm,
-		      struct mdt_body *body, ldlm_blocking_callback cb_blocking)
+static int
+lmv_update_lsm_md(struct obd_export *exp, struct lmv_stripe_md *lsm,
+		  struct mdt_body *body, ldlm_blocking_callback cb_blocking)
 {
 	return lmv_revalidate_slaves(exp, body, lsm, cb_blocking, 0);
 }
 
-int lmv_merge_attr(struct obd_export *exp, const struct lmv_stripe_md *lsm,
-		   struct cl_attr *attr)
+static int
+lmv_merge_attr(struct obd_export *exp, const struct lmv_stripe_md *lsm,
+	       struct cl_attr *attr)
 {
 	int i;
 
-- 
2.7.4
