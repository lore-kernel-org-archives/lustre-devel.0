From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:29 -0400
Subject: [lustre-devel] [PATCH 33/41] staging: lustre: lov: use
	obd_get_info() to get def/max LOV EA sizes
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Use obd_get_info() to get the default and maximum LOV EA sizes (along
with maximum cookiesize) from LOV. Remove the then unused function
obd_size_diskmd() and the unused get info key KEY_LOVDESC. When
computing the maximum LOV EA size use the active OST count
(ld_active_tgt_count) rather than the OST count (ld_tgt_count).

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5814
Reviewed-on: http://review.whamcloud.com/13695
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |    1 -
 drivers/staging/lustre/lustre/include/obd_class.h  |    6 ---
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |   34 ++++++++++----------
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   10 +++++-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   24 +++++++------
 5 files changed, 39 insertions(+), 36 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 4691121..5fa5838 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -667,7 +667,6 @@ enum obd_cleanup_stage {
 #define KEY_INTERMDS	    "inter_mds"
 #define KEY_LAST_ID	     "last_id"
 #define KEY_LAST_FID		"last_fid"
-#define KEY_LOVDESC	     "lovdesc"
 #define KEY_MAX_EASIZE		"max_easize"
 #define KEY_DEFAULT_EASIZE	"default_easize"
 #define KEY_MGSSEC	      "mgssec"
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index a27dbc8..e6ae4a0 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -628,12 +628,6 @@ static inline int obd_packmd(struct obd_export *exp,
 	return rc;
 }
 
-static inline int obd_size_diskmd(struct obd_export *exp,
-				  struct lov_stripe_md *mem_src)
-{
-	return obd_packmd(exp, NULL, mem_src);
-}
-
 static inline int obd_free_diskmd(struct obd_export *exp,
 				  struct lov_mds_md **disk_tgt)
 {
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index 4562643..1558b55 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -47,29 +47,29 @@
  */
 int cl_init_ea_size(struct obd_export *md_exp, struct obd_export *dt_exp)
 {
-	struct lov_stripe_md lsm = { .lsm_magic = LOV_MAGIC_V3 };
-	__u32 valsize = sizeof(struct lov_desc);
-	int rc, easize, def_easize;
-	struct lov_desc desc;
-	__u16 stripes, def_stripes;
-
-	rc = obd_get_info(NULL, dt_exp, sizeof(KEY_LOVDESC), KEY_LOVDESC,
-			  &valsize, &desc);
+	u32 val_size, max_easize, def_easize;
+	int rc;
+
+	val_size = sizeof(max_easize);
+	rc = obd_get_info(NULL, dt_exp, sizeof(KEY_MAX_EASIZE), KEY_MAX_EASIZE,
+			  &val_size, &max_easize);
 	if (rc)
 		return rc;
 
-	stripes = min_t(__u32, desc.ld_tgt_count, LOV_MAX_STRIPE_COUNT);
-	lsm.lsm_stripe_count = stripes;
-	easize = obd_size_diskmd(dt_exp, &lsm);
-
-	def_stripes = min_t(__u32, desc.ld_default_stripe_count,
-			    LOV_MAX_STRIPE_COUNT);
-	lsm.lsm_stripe_count = def_stripes;
-	def_easize = obd_size_diskmd(dt_exp, &lsm);
+	val_size = sizeof(def_easize);
+	rc = obd_get_info(NULL, dt_exp, sizeof(KEY_DEFAULT_EASIZE),
+			  KEY_DEFAULT_EASIZE, &val_size, &def_easize);
+	if (rc)
+		return rc;
 
-	CDEBUG(D_HA, "updating def/max_easize: %d/%d\n", def_easize, easize);
+	/*
+	 * default cookiesize is 0 because from 2.4 server doesn't send
+	 * llog cookies to client.
+	 */
+	CDEBUG(D_HA, "updating def/max_easize: %d/%d\n",
+	       def_easize, max_easize);
 
-	rc = md_init_ea_size(md_exp, easize, def_easize);
+	rc = md_init_ea_size(md_exp, max_easize, def_easize);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 25a06f8..84d5556 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -560,7 +560,15 @@ int ll_get_max_mdsize(struct ll_sb_info *sbi, int *lmmsize)
 {
 	int size, rc;
 
-	*lmmsize = obd_size_diskmd(sbi->ll_dt_exp, NULL);
+	size = sizeof(*lmmsize);
+	rc = obd_get_info(NULL, sbi->ll_dt_exp, sizeof(KEY_MAX_EASIZE),
+			  KEY_MAX_EASIZE, &size, lmmsize);
+	if (rc) {
+		CERROR("%s: cannot get max LOV EA size: rc = %d\n",
+		       sbi->ll_dt_exp->exp_obd->obd_name, rc);
+		return rc;
+	}
+
 	size = sizeof(int);
 	rc = obd_get_info(NULL, sbi->ll_md_exp, sizeof(KEY_MAX_EASIZE),
 			  KEY_MAX_EASIZE, &size, lmmsize);
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index c2a853c..473071c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1244,28 +1244,30 @@ static int lov_get_info(const struct lu_env *env, struct obd_export *exp,
 {
 	struct obd_device *obddev = class_exp2obd(exp);
 	struct lov_obd *lov = &obddev->u.lov;
-	int rc;
+	struct lov_desc *ld = &lov->desc;
+	int rc = 0;
 
 	if (!vallen || !val)
 		return -EFAULT;
 
 	obd_getref(obddev);
 
-	if (KEY_IS(KEY_LOVDESC)) {
-		struct lov_desc *desc_ret = val;
-		*desc_ret = lov->desc;
+	if (KEY_IS(KEY_MAX_EASIZE)) {
+		u32 max_stripe_count = min_t(u32, ld->ld_active_tgt_count,
+					     LOV_MAX_STRIPE_COUNT);
 
-		rc = 0;
-		goto out;
+		*((u32 *)val) = lov_mds_md_size(max_stripe_count, LOV_MAGIC_V3);
+	} else if (KEY_IS(KEY_DEFAULT_EASIZE)) {
+		u32 def_stripe_count = min_t(u32, ld->ld_default_stripe_count,
+					     LOV_MAX_STRIPE_COUNT);
+
+		*((u32 *)val) = lov_mds_md_size(def_stripe_count, LOV_MAGIC_V3);
 	} else if (KEY_IS(KEY_TGT_COUNT)) {
 		*((int *)val) = lov->desc.ld_tgt_count;
-		rc = 0;
-		goto out;
+	} else {
+		rc = -EINVAL;
 	}
 
-	rc = -EINVAL;
-
-out:
 	obd_putref(obddev);
 	return rc;
 }
-- 
1.7.1
