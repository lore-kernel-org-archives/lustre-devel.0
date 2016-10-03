From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:18 -0400
Subject: [lustre-devel] [PATCH 22/41] staging: lustre: obd: remove unused
	LSM parameters
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Remove unused struct lov_stripe_md * parameters from obd_get_info(),
mgc_enqueue(), and osc_brw_prep_request().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5814
Reviewed-on: http://review.whamcloud.com/13426
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |    3 +--
 drivers/staging/lustre/lustre/include/obd_class.h  |    6 ++----
 drivers/staging/lustre/lustre/llite/dir.c          |    2 +-
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |    2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    6 +++---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    8 +++-----
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    3 +--
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    5 ++---
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    9 ++++-----
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    7 ++-----
 11 files changed, 21 insertions(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 5c31376..c72a1e1 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -845,8 +845,7 @@ struct obd_ops {
 	int (*iocontrol)(unsigned int cmd, struct obd_export *exp, int len,
 			 void *karg, void __user *uarg);
 	int (*get_info)(const struct lu_env *env, struct obd_export *,
-			__u32 keylen, void *key, __u32 *vallen, void *val,
-			struct lov_stripe_md *lsm);
+			__u32 keylen, void *key, __u32 *vallen, void *val);
 	int (*set_info_async)(const struct lu_env *, struct obd_export *,
 			      __u32 keylen, void *key,
 			      __u32 vallen, void *val,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index b2ced8b..7a5d75a 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -415,16 +415,14 @@ static inline int class_devno_max(void)
 
 static inline int obd_get_info(const struct lu_env *env,
 			       struct obd_export *exp, __u32 keylen,
-			       void *key, __u32 *vallen, void *val,
-			       struct lov_stripe_md *lsm)
+			       void *key, __u32 *vallen, void *val)
 {
 	int rc;
 
 	EXP_CHECK_DT_OP(exp, get_info);
 	EXP_COUNTER_INCREMENT(exp, get_info);
 
-	rc = OBP(exp->exp_obd, get_info)(env, exp, keylen, key, vallen, val,
-					 lsm);
+	rc = OBP(exp->exp_obd, get_info)(env, exp, keylen, key, vallen, val);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 68675eb..12e9a38 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1535,7 +1535,7 @@ out_quotactl:
 		exp = count ? sbi->ll_md_exp : sbi->ll_dt_exp;
 		vallen = sizeof(count);
 		rc = obd_get_info(NULL, exp, sizeof(KEY_TGT_COUNT),
-				  KEY_TGT_COUNT, &vallen, &count, NULL);
+				  KEY_TGT_COUNT, &vallen, &count);
 		if (rc) {
 			CERROR("get target count failed: %d\n", rc);
 			return rc;
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index fb346c1..07d38e5 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -54,7 +54,7 @@ int cl_init_ea_size(struct obd_export *md_exp, struct obd_export *dt_exp)
 	__u16 stripes, def_stripes;
 
 	rc = obd_get_info(NULL, dt_exp, sizeof(KEY_LOVDESC), KEY_LOVDESC,
-			  &valsize, &desc, NULL);
+			  &valsize, &desc);
 	if (rc)
 		return rc;
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 9112a52..6270301 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -285,7 +285,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 
 	size = sizeof(*data);
 	err = obd_get_info(NULL, sbi->ll_md_exp, sizeof(KEY_CONN_DATA),
-			   KEY_CONN_DATA,  &size, data, NULL);
+			   KEY_CONN_DATA,  &size, data);
 	if (err) {
 		CERROR("%s: Get connect data failed: rc = %d\n",
 		       sbi->ll_md_exp->exp_obd->obd_name, err);
@@ -563,7 +563,7 @@ int ll_get_max_mdsize(struct ll_sb_info *sbi, int *lmmsize)
 	*lmmsize = obd_size_diskmd(sbi->ll_dt_exp, NULL);
 	size = sizeof(int);
 	rc = obd_get_info(NULL, sbi->ll_md_exp, sizeof(KEY_MAX_EASIZE),
-			  KEY_MAX_EASIZE, &size, lmmsize, NULL);
+			  KEY_MAX_EASIZE, &size, lmmsize);
 	if (rc)
 		CERROR("Get max mdsize error rc %d\n", rc);
 
@@ -587,7 +587,7 @@ int ll_get_default_mdsize(struct ll_sb_info *sbi, int *lmmsize)
 
 	size = sizeof(int);
 	rc = obd_get_info(NULL, sbi->ll_md_exp, sizeof(KEY_DEFAULT_EASIZE),
-			  KEY_DEFAULT_EASIZE, &size, lmmsize, NULL);
+			  KEY_DEFAULT_EASIZE, &size, lmmsize);
 	if (rc)
 		CERROR("Get default mdsize error rc %d\n", rc);
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index b401ffb..7bd7e15 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2628,14 +2628,12 @@ static int lmv_precleanup(struct obd_device *obd, enum obd_cleanup_stage stage)
  * \param[in]  key	identifier of key to get value for
  * \param[in]  vallen	size of \a val
  * \param[out] val	pointer to storage location for value
- * \param[in]  lsm	optional striping metadata of object
  *
  * \retval 0		on success
  * \retval negative	negated errno on failure
  */
 static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
-			__u32 keylen, void *key, __u32 *vallen, void *val,
-			struct lov_stripe_md *lsm)
+			__u32 keylen, void *key, __u32 *vallen, void *val)
 {
 	struct obd_device       *obd;
 	struct lmv_obd	  *lmv;
@@ -2667,7 +2665,7 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 				continue;
 
 			if (!obd_get_info(env, tgt->ltd_exp, keylen, key,
-					  vallen, val, NULL))
+					  vallen, val))
 				return 0;
 		}
 		return -EINVAL;
@@ -2683,7 +2681,7 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 		 * desc.
 		 */
 		rc = obd_get_info(env, lmv->tgts[0]->ltd_exp, keylen, key,
-				  vallen, val, NULL);
+				  vallen, val);
 		if (!rc && KEY_IS(KEY_CONN_DATA))
 			exp->exp_connect_data = *(struct obd_connect_data *)val;
 		return rc;
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 30903fc..44f53c7 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1310,8 +1310,7 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 }
 
 static int lov_get_info(const struct lu_env *env, struct obd_export *exp,
-			__u32 keylen, void *key, __u32 *vallen, void *val,
-			struct lov_stripe_md *lsm)
+			__u32 keylen, void *key, __u32 *vallen, void *val)
 {
 	struct obd_device *obddev = class_exp2obd(exp);
 	struct lov_obd *lov = &obddev->u.lov;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 206f5d0..7b9fb90 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1456,7 +1456,7 @@ static int mdc_ioc_fid2path(struct obd_export *exp, struct getinfo_fid2path *gf)
 	/* Val is struct getinfo_fid2path result plus path */
 	vallen = sizeof(*gf) + gf->gf_pathlen;
 
-	rc = obd_get_info(NULL, exp, keylen, key, &vallen, gf, NULL);
+	rc = obd_get_info(NULL, exp, keylen, key, &vallen, gf);
 	if (rc != 0 && rc != -EREMOTE)
 		goto out;
 
@@ -2436,8 +2436,7 @@ static int mdc_set_info_async(const struct lu_env *env,
 }
 
 static int mdc_get_info(const struct lu_env *env, struct obd_export *exp,
-			__u32 keylen, void *key, __u32 *vallen, void *val,
-			struct lov_stripe_md *lsm)
+			__u32 keylen, void *key, __u32 *vallen, void *val)
 {
 	int rc = -EINVAL;
 
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 23374ca..1a0e59a 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -887,8 +887,8 @@ static int mgc_set_mgs_param(struct obd_export *exp,
 }
 
 /* Take a config lock so we can get cancel notifications */
-static int mgc_enqueue(struct obd_export *exp, struct lov_stripe_md *lsm,
-		       __u32 type, ldlm_policy_data_t *policy, __u32 mode,
+static int mgc_enqueue(struct obd_export *exp, __u32 type,
+		       ldlm_policy_data_t *policy, __u32 mode,
 		       __u64 *flags, void *bl_cb, void *cp_cb, void *gl_cb,
 		       void *data, __u32 lvb_len, void *lvb_swabber,
 		       struct lustre_handle *lockh)
@@ -1059,8 +1059,7 @@ static int mgc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 }
 
 static int mgc_get_info(const struct lu_env *env, struct obd_export *exp,
-			__u32 keylen, void *key, __u32 *vallen, void *val,
-			struct lov_stripe_md *unused)
+			__u32 keylen, void *key, __u32 *vallen, void *val)
 {
 	int rc = -EINVAL;
 
@@ -1582,7 +1581,7 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 	       cld->cld_cfg.cfg_instance, cld->cld_cfg.cfg_last_idx + 1);
 
 	/* Get the cfg lock on the llog */
-	rcl = mgc_enqueue(mgc->u.cli.cl_mgc_mgsexp, NULL, LDLM_PLAIN, NULL,
+	rcl = mgc_enqueue(mgc->u.cli.cl_mgc_mgsexp, LDLM_PLAIN, NULL,
 			  LCK_CR, &flags, NULL, NULL, NULL,
 			  cld, 0, NULL, &lockh);
 	if (rcl == 0) {
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 0d3a3b0..59fbc29 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -261,7 +261,7 @@ int lustre_start_mgc(struct super_block *sb)
 
 			rc = obd_get_info(NULL, obd->obd_self_export,
 					  strlen(KEY_CONN_DATA), KEY_CONN_DATA,
-					  &vallen, data, NULL);
+					  &vallen, data);
 			LASSERT(rc == 0);
 			has_ir = OCD_HAS_FLAG(data, IMP_RECOV);
 			if (has_ir ^ !(*flags & LMD_FLG_NOIR)) {
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 21cd48b..0413b88 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1139,8 +1139,7 @@ static u32 osc_checksum_bulk(int nob, u32 pg_count,
 }
 
 static int osc_brw_prep_request(int cmd, struct client_obd *cli,
-				struct obdo *oa,
-				struct lov_stripe_md *lsm, u32 page_count,
+				struct obdo *oa, u32 page_count,
 				struct brw_page **pga,
 				struct ptlrpc_request **reqp,
 				int reserve,
@@ -1557,7 +1556,6 @@ static int osc_brw_redo_request(struct ptlrpc_request *request,
 	rc = osc_brw_prep_request(lustre_msg_get_opc(request->rq_reqmsg) ==
 					OST_WRITE ? OBD_BRW_WRITE : OBD_BRW_READ,
 				  aa->aa_cli, aa->aa_oa,
-				  NULL /* lsm unused by osc currently */,
 				  aa->aa_page_count, aa->aa_ppga,
 				  &new_req, 0, 1);
 	if (rc)
@@ -1902,8 +1900,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	}
 
 	sort_brw_pages(pga, page_count);
-	rc = osc_brw_prep_request(cmd, cli, oa, NULL, page_count,
-				  pga, &req, 1, 0);
+	rc = osc_brw_prep_request(cmd, cli, oa, page_count, pga, &req, 1, 0);
 	if (rc != 0) {
 		CERROR("prep_req failed: %d\n", rc);
 		goto out;
-- 
1.7.1
