From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:16 -0500
Subject: [lustre-devel] [PATCH 12/26] lmv: cleanup white spaces
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The lmv code is very messy and difficult to read. Remove excess
white space and properly align data structures so they are easy on
the eyes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_intent.c |  38 +--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c    | 334 ++++++++++++-------------
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c  |  24 +-
 3 files changed, 198 insertions(+), 198 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index bc364b6..8892426 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -54,15 +54,15 @@ static int lmv_intent_remote(struct obd_export *exp, struct lookup_intent *it,
 			     ldlm_blocking_callback cb_blocking,
 			     u64 extra_lock_flags)
 {
-	struct obd_device	*obd = exp->exp_obd;
-	struct lmv_obd		*lmv = &obd->u.lmv;
-	struct ptlrpc_request	*req = NULL;
-	struct lustre_handle	plock;
-	struct md_op_data	*op_data;
-	struct lmv_tgt_desc	*tgt;
-	struct mdt_body		*body;
-	int			pmode;
-	int			rc = 0;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct ptlrpc_request *req = NULL;
+	struct lustre_handle plock;
+	struct md_op_data *op_data;
+	struct lmv_tgt_desc *tgt;
+	struct mdt_body	*body;
+	int pmode;
+	int rc = 0;
 
 	body = req_capsule_server_get(&(*reqp)->rq_pill, &RMF_MDT_BODY);
 	if (!body)
@@ -264,11 +264,11 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 			   ldlm_blocking_callback cb_blocking,
 			   u64 extra_lock_flags)
 {
-	struct obd_device	*obd = exp->exp_obd;
-	struct lmv_obd		*lmv = &obd->u.lmv;
-	struct lmv_tgt_desc	*tgt;
-	struct mdt_body		*body;
-	int			rc;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
+	struct mdt_body	*body;
+	int rc;
 
 	if (it->it_flags & MDS_OPEN_BY_FID) {
 		LASSERT(fid_is_sane(&op_data->op_fid2));
@@ -356,11 +356,11 @@ static int lmv_intent_lookup(struct obd_export *exp,
 			     u64 extra_lock_flags)
 {
 	struct lmv_stripe_md *lsm = op_data->op_mea1;
-	struct obd_device      *obd = exp->exp_obd;
-	struct lmv_obd	 *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc    *tgt = NULL;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt = NULL;
 	struct mdt_body	*body;
-	int		     rc = 0;
+	int rc = 0;
 
 	/*
 	 * If it returns ERR_PTR(-EBADFD) then it is an unknown hash type
@@ -477,7 +477,7 @@ int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 		    ldlm_blocking_callback cb_blocking,
 		    u64 extra_lock_flags)
 {
-	int		rc;
+	int rc;
 
 	LASSERT(fid_is_sane(&op_data->op_fid1));
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 65ae944..1c7379b 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -80,9 +80,9 @@ static int lmv_set_mdc_active(struct lmv_obd *lmv, const struct obd_uuid *uuid,
 			      int activate)
 {
 	struct lmv_tgt_desc *tgt = NULL;
-	struct obd_device      *obd;
-	u32		     i;
-	int		     rc = 0;
+	struct obd_device *obd;
+	u32 i;
+	int rc = 0;
 
 	CDEBUG(D_INFO, "Searching in lmv %p for uuid %s (activate=%d)\n",
 	       lmv, uuid->uuid, activate);
@@ -126,7 +126,7 @@ static int lmv_set_mdc_active(struct lmv_obd *lmv, const struct obd_uuid *uuid,
 	       activate ? "" : "in");
 	lmv_activate_target(lmv, tgt, activate);
 
- out_lmv_lock:
+out_lmv_lock:
 	spin_unlock(&lmv->lmv_lock);
 	return rc;
 }
@@ -143,9 +143,9 @@ static int lmv_notify(struct obd_device *obd, struct obd_device *watched,
 		      enum obd_notify_event ev)
 {
 	struct obd_connect_data *conn_data;
-	struct lmv_obd	  *lmv = &obd->u.lmv;
-	struct obd_uuid	 *uuid;
-	int		      rc = 0;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct obd_uuid	*uuid;
+	int rc = 0;
 
 	if (strcmp(watched->obd_type->typ_name, LUSTRE_MDC_NAME)) {
 		CERROR("unexpected notification of %s %s!\n",
@@ -192,10 +192,10 @@ static int lmv_connect(const struct lu_env *env,
 		       struct obd_uuid *cluuid, struct obd_connect_data *data,
 		       void *localdata)
 {
-	struct lmv_obd	*lmv = &obd->u.lmv;
-	struct lustre_handle  conn = { 0 };
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lustre_handle conn = { 0 };
 	struct obd_export *exp;
-	int		    rc = 0;
+	int rc = 0;
 
 	rc = class_connect(&conn, obd, cluuid);
 	if (rc) {
@@ -234,11 +234,11 @@ static int lmv_connect(const struct lu_env *env,
 
 static int lmv_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize)
 {
-	struct obd_device   *obd = exp->exp_obd;
-	struct lmv_obd      *lmv = &obd->u.lmv;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
 	u32 i;
-	int		  rc = 0;
-	int		  change = 0;
+	int rc = 0;
+	int change = 0;
 
 	if (lmv->max_easize < easize) {
 		lmv->max_easize = easize;
@@ -277,13 +277,13 @@ static int lmv_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize)
 
 static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 {
-	struct lmv_obd	  *lmv = &obd->u.lmv;
-	struct obd_uuid	 *cluuid = &lmv->cluuid;
-	struct obd_uuid	  lmv_mdc_uuid = { "LMV_MDC_UUID" };
-	struct obd_device       *mdc_obd;
-	struct obd_export       *mdc_exp;
-	struct lu_fld_target     target;
-	int		      rc;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct obd_uuid *cluuid = &lmv->cluuid;
+	struct obd_uuid lmv_mdc_uuid = { "LMV_MDC_UUID" };
+	struct obd_device *mdc_obd;
+	struct obd_export *mdc_exp;
+	struct lu_fld_target target;
+	int rc;
 
 	mdc_obd = class_find_client_obd(&tgt->ltd_uuid, LUSTRE_MDC_NAME,
 					&obd->obd_uuid);
@@ -371,11 +371,11 @@ static void lmv_del_target(struct lmv_obd *lmv, int index)
 static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 			  u32 index, int gen)
 {
-	struct lmv_obd      *lmv = &obd->u.lmv;
+	struct lmv_obd *lmv = &obd->u.lmv;
 	struct obd_device *mdc_obd;
 	struct lmv_tgt_desc *tgt;
 	int orig_tgt_count = 0;
-	int		  rc = 0;
+	int rc = 0;
 
 	CDEBUG(D_CONFIG, "Target uuid: %s. index %d\n", uuidp->uuid, index);
 
@@ -470,11 +470,11 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 
 static int lmv_check_connect(struct obd_device *obd)
 {
-	struct lmv_obd       *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc  *tgt;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
 	u32 i;
-	int		   rc;
-	int		   easize;
+	int rc;
+	int easize;
 
 	if (lmv->connected)
 		return 0;
@@ -518,7 +518,7 @@ static int lmv_check_connect(struct obd_device *obd)
 	mutex_unlock(&lmv->lmv_init_mutex);
 	return 0;
 
- out_disc:
+out_disc:
 	while (i-- > 0) {
 		int rc2;
 
@@ -542,9 +542,9 @@ static int lmv_check_connect(struct obd_device *obd)
 
 static int lmv_disconnect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 {
-	struct lmv_obd	 *lmv = &obd->u.lmv;
-	struct obd_device      *mdc_obd;
-	int		     rc;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct obd_device *mdc_obd;
+	int rc;
 
 	mdc_obd = class_exp2obd(tgt->ltd_exp);
 
@@ -582,9 +582,9 @@ static int lmv_disconnect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 
 static int lmv_disconnect(struct obd_export *exp)
 {
-	struct obd_device     *obd = class_exp2obd(exp);
-	struct lmv_obd	*lmv = &obd->u.lmv;
-	int		    rc;
+	struct obd_device *obd = class_exp2obd(exp);
+	struct lmv_obd *lmv = &obd->u.lmv;
+	int rc;
 	u32 i;
 
 	if (!lmv->tgts)
@@ -615,14 +615,14 @@ static int lmv_disconnect(struct obd_export *exp)
 static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
 			void __user *uarg)
 {
-	struct obd_device	*obddev = class_exp2obd(exp);
-	struct lmv_obd		*lmv = &obddev->u.lmv;
+	struct obd_device *obddev = class_exp2obd(exp);
+	struct lmv_obd *lmv = &obddev->u.lmv;
 	struct getinfo_fid2path *gf = karg;
-	struct lmv_tgt_desc     *tgt;
+	struct lmv_tgt_desc *tgt;
 	struct getinfo_fid2path *remote_gf = NULL;
 	struct lu_fid root_fid;
-	int			remote_gf_size = 0;
-	int			rc;
+	int remote_gf_size = 0;
+	int rc;
 
 	tgt = lmv_find_target(lmv, &gf->gf_fid);
 	if (IS_ERR(tgt))
@@ -711,7 +711,7 @@ static int lmv_hsm_req_count(struct lmv_obd *lmv,
 			     const struct lmv_tgt_desc *tgt_mds)
 {
 	u32 i, nr = 0;
-	struct lmv_tgt_desc    *curr_tgt;
+	struct lmv_tgt_desc *curr_tgt;
 
 	/* count how many requests must be sent to the given target */
 	for (i = 0; i < hur->hur_request.hr_itemcount; i++) {
@@ -729,8 +729,8 @@ static int lmv_hsm_req_build(struct lmv_obd *lmv,
 			     const struct lmv_tgt_desc *tgt_mds,
 			     struct hsm_user_request *hur_out)
 {
-	int			i, nr_out;
-	struct lmv_tgt_desc    *curr_tgt;
+	int i, nr_out;
+	struct lmv_tgt_desc *curr_tgt;
 
 	/* build the hsm_user_request for the given target */
 	hur_out->hur_request = hur_in->hur_request;
@@ -857,12 +857,12 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 			 int len, void *karg, void __user *uarg)
 {
-	struct obd_device    *obddev = class_exp2obd(exp);
-	struct lmv_obd       *lmv = &obddev->u.lmv;
+	struct obd_device *obddev = class_exp2obd(exp);
+	struct lmv_obd *lmv = &obddev->u.lmv;
 	struct lmv_tgt_desc *tgt = NULL;
 	u32 i = 0;
-	int		   rc = 0;
-	int		   set = 0;
+	int rc = 0;
+	int set = 0;
 	u32 count = lmv->desc.ld_tgt_count;
 
 	if (count == 0)
@@ -872,7 +872,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 	case IOC_OBD_STATFS: {
 		struct obd_ioctl_data *data = karg;
 		struct obd_device *mdc_obd;
-		struct obd_statfs stat_buf = {0};
+		struct obd_statfs stat_buf = { 0 };
 		u32 index;
 
 		memcpy(&index, data->ioc_inlbuf2, sizeof(u32));
@@ -981,7 +981,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 	case LL_IOC_HSM_STATE_GET:
 	case LL_IOC_HSM_STATE_SET:
 	case LL_IOC_HSM_ACTION: {
-		struct md_op_data	*op_data = karg;
+		struct md_op_data *op_data = karg;
 
 		tgt = lmv_find_target(lmv, &op_data->op_fid1);
 		if (IS_ERR(tgt))
@@ -1059,8 +1059,8 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		break;
 	}
 	case LL_IOC_LOV_SWAP_LAYOUTS: {
-		struct md_op_data	*op_data = karg;
-		struct lmv_tgt_desc	*tgt1, *tgt2;
+		struct md_op_data *op_data = karg;
+		struct lmv_tgt_desc *tgt1, *tgt2;
 
 		tgt1 = lmv_find_target(lmv, &op_data->op_fid1);
 		if (IS_ERR(tgt1))
@@ -1162,8 +1162,8 @@ static int lmv_placement_policy(struct obd_device *obd,
 
 int __lmv_fid_alloc(struct lmv_obd *lmv, struct lu_fid *fid, u32 mds)
 {
-	struct lmv_tgt_desc	*tgt;
-	int			 rc;
+	struct lmv_tgt_desc *tgt;
+	int rc;
 
 	tgt = lmv_get_target(lmv, mds, NULL);
 	if (IS_ERR(tgt))
@@ -1197,10 +1197,10 @@ int __lmv_fid_alloc(struct lmv_obd *lmv, struct lu_fid *fid, u32 mds)
 int lmv_fid_alloc(const struct lu_env *env, struct obd_export *exp,
 		  struct lu_fid *fid, struct md_op_data *op_data)
 {
-	struct obd_device     *obd = class_exp2obd(exp);
-	struct lmv_obd	*lmv = &obd->u.lmv;
-	u32		       mds = 0;
-	int		    rc;
+	struct obd_device *obd = class_exp2obd(exp);
+	struct lmv_obd *lmv = &obd->u.lmv;
+	u32 mds = 0;
+	int rc;
 
 	LASSERT(op_data);
 	LASSERT(fid);
@@ -1223,9 +1223,9 @@ int lmv_fid_alloc(const struct lu_env *env, struct obd_export *exp,
 
 static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 {
-	struct lmv_obd	     *lmv = &obd->u.lmv;
-	struct lmv_desc	    *desc;
-	int			 rc;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_desc *desc;
+	int rc;
 
 	if (LUSTRE_CFG_BUFLEN(lcfg, 1) < 1) {
 		CERROR("LMV setup requires a descriptor\n");
@@ -1270,7 +1270,7 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 
 static int lmv_cleanup(struct obd_device *obd)
 {
-	struct lmv_obd   *lmv = &obd->u.lmv;
+	struct lmv_obd *lmv = &obd->u.lmv;
 
 	fld_client_fini(&lmv->lmv_fld);
 	if (lmv->tgts) {
@@ -1289,11 +1289,11 @@ static int lmv_cleanup(struct obd_device *obd)
 
 static int lmv_process_config(struct obd_device *obd, u32 len, void *buf)
 {
-	struct lustre_cfg	*lcfg = buf;
-	struct obd_uuid		obd_uuid;
-	int			gen;
-	u32			index;
-	int			rc;
+	struct lustre_cfg *lcfg = buf;
+	struct obd_uuid	obd_uuid;
+	int gen;
+	u32 index;
+	int rc;
 
 	switch (lcfg->lcfg_command) {
 	case LCFG_ADD_MDC:
@@ -1329,10 +1329,10 @@ static int lmv_process_config(struct obd_device *obd, u32 len, void *buf)
 static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 		      struct obd_statfs *osfs, u64 max_age, u32 flags)
 {
-	struct obd_device     *obd = class_exp2obd(exp);
-	struct lmv_obd	*lmv = &obd->u.lmv;
-	struct obd_statfs     *temp;
-	int		    rc = 0;
+	struct obd_device *obd = class_exp2obd(exp);
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct obd_statfs *temp;
+	int rc = 0;
 	u32 i;
 
 	temp = kzalloc(sizeof(*temp), GFP_NOFS);
@@ -1379,8 +1379,8 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 static int lmv_get_root(struct obd_export *exp, const char *fileset,
 			struct lu_fid *fid)
 {
-	struct obd_device    *obd = exp->exp_obd;
-	struct lmv_obd       *lmv = &obd->u.lmv;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
 
 	return md_get_root(lmv->tgts[0]->ltd_exp, fileset, fid);
 }
@@ -1389,9 +1389,9 @@ static int lmv_getxattr(struct obd_export *exp, const struct lu_fid *fid,
 			u64 obd_md_valid, const char *name, size_t buf_size,
 			struct ptlrpc_request **req)
 {
-	struct obd_device      *obd = exp->exp_obd;
-	struct lmv_obd	 *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc    *tgt;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
 
 	tgt = lmv_find_target(lmv, fid);
 	if (IS_ERR(tgt))
@@ -1407,9 +1407,9 @@ static int lmv_setxattr(struct obd_export *exp, const struct lu_fid *fid,
 			unsigned int xattr_flags, u32 suppgid,
 			struct ptlrpc_request **req)
 {
-	struct obd_device      *obd = exp->exp_obd;
-	struct lmv_obd	 *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc    *tgt;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
 
 	tgt = lmv_find_target(lmv, fid);
 	if (IS_ERR(tgt))
@@ -1422,9 +1422,9 @@ static int lmv_setxattr(struct obd_export *exp, const struct lu_fid *fid,
 static int lmv_getattr(struct obd_export *exp, struct md_op_data *op_data,
 		       struct ptlrpc_request **request)
 {
-	struct obd_device       *obd = exp->exp_obd;
-	struct lmv_obd	  *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc     *tgt;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
 
 	tgt = lmv_find_target(lmv, &op_data->op_fid1);
 	if (IS_ERR(tgt))
@@ -1440,8 +1440,8 @@ static int lmv_getattr(struct obd_export *exp, struct md_op_data *op_data,
 
 static int lmv_null_inode(struct obd_export *exp, const struct lu_fid *fid)
 {
-	struct obd_device   *obd = exp->exp_obd;
-	struct lmv_obd      *lmv = &obd->u.lmv;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
 	u32 i;
 
 	CDEBUG(D_INODE, "CBDATA for " DFID "\n", PFID(fid));
@@ -1463,9 +1463,9 @@ static int lmv_null_inode(struct obd_export *exp, const struct lu_fid *fid)
 static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 		     struct md_open_data *mod, struct ptlrpc_request **request)
 {
-	struct obd_device     *obd = exp->exp_obd;
-	struct lmv_obd	*lmv = &obd->u.lmv;
-	struct lmv_tgt_desc   *tgt;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
 
 	tgt = lmv_find_target(lmv, &op_data->op_fid1);
 	if (IS_ERR(tgt))
@@ -1587,10 +1587,10 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		      uid_t uid, gid_t gid, kernel_cap_t cap_effective,
 		      u64 rdev, struct ptlrpc_request **request)
 {
-	struct obd_device       *obd = exp->exp_obd;
-	struct lmv_obd	  *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc     *tgt;
-	int		      rc;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
+	int rc;
 
 	if (!lmv->desc.ld_active_tgt_count)
 		return -EIO;
@@ -1641,9 +1641,9 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	    const union ldlm_policy_data *policy, struct md_op_data *op_data,
 	    struct lustre_handle *lockh, u64 extra_lock_flags)
 {
-	struct obd_device	*obd = exp->exp_obd;
-	struct lmv_obd	   *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc      *tgt;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
 
 	CDEBUG(D_INODE, "ENQUEUE on " DFID "\n", PFID(&op_data->op_fid1));
 
@@ -1662,12 +1662,12 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 		 struct ptlrpc_request **preq)
 {
-	struct ptlrpc_request   *req = NULL;
-	struct obd_device       *obd = exp->exp_obd;
-	struct lmv_obd	  *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc     *tgt;
-	struct mdt_body	 *body;
-	int		      rc;
+	struct ptlrpc_request *req = NULL;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
+	struct mdt_body	*body;
+	int rc;
 
 	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
 	if (IS_ERR(tgt))
@@ -1707,7 +1707,7 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	return rc;
 }
 
-#define md_op_data_fid(op_data, fl)		     \
+#define md_op_data_fid(op_data, fl)			\
 	(fl == MF_MDC_CANCEL_FID1 ? &op_data->op_fid1 : \
 	 fl == MF_MDC_CANCEL_FID2 ? &op_data->op_fid2 : \
 	 fl == MF_MDC_CANCEL_FID3 ? &op_data->op_fid3 : \
@@ -1718,11 +1718,11 @@ static int lmv_early_cancel(struct obd_export *exp, struct lmv_tgt_desc *tgt,
 			    struct md_op_data *op_data, int op_tgt,
 			    enum ldlm_mode mode, int bits, int flag)
 {
-	struct lu_fid	  *fid = md_op_data_fid(op_data, flag);
-	struct obd_device      *obd = exp->exp_obd;
-	struct lmv_obd	 *lmv = &obd->u.lmv;
+	struct lu_fid *fid = md_op_data_fid(op_data, flag);
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
 	union ldlm_policy_data policy = { { 0 } };
-	int		     rc = 0;
+	int rc = 0;
 
 	if (!fid_is_sane(fid))
 		return 0;
@@ -1756,10 +1756,10 @@ static int lmv_early_cancel(struct obd_export *exp, struct lmv_tgt_desc *tgt,
 static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 		    struct ptlrpc_request **request)
 {
-	struct obd_device       *obd = exp->exp_obd;
-	struct lmv_obd	  *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc     *tgt;
-	int		      rc;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
+	int rc;
 
 	LASSERT(op_data->op_namelen != 0);
 
@@ -1803,13 +1803,13 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 		      const char *new, size_t newlen,
 		      struct ptlrpc_request **request)
 {
-	struct obd_device       *obd = exp->exp_obd;
-	struct lmv_obd	  *lmv = &obd->u.lmv;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
 	struct obd_export *target_exp;
-	struct lmv_tgt_desc     *src_tgt;
+	struct lmv_tgt_desc *src_tgt;
 	struct lmv_tgt_desc *tgt_tgt;
 	struct mdt_body *body;
-	int			rc;
+	int rc;
 
 	LASSERT(oldlen != 0);
 
@@ -1968,9 +1968,9 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 static int lmv_setattr(struct obd_export *exp, struct md_op_data *op_data,
 		       void *ea, size_t ealen, struct ptlrpc_request **request)
 {
-	struct obd_device       *obd = exp->exp_obd;
-	struct lmv_obd	  *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc     *tgt;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
 
 	CDEBUG(D_INODE, "SETATTR for " DFID ", valid 0x%x/0x%x\n",
 	       PFID(&op_data->op_fid1), op_data->op_attr.ia_valid,
@@ -1987,9 +1987,9 @@ static int lmv_setattr(struct obd_export *exp, struct md_op_data *op_data,
 static int lmv_fsync(struct obd_export *exp, const struct lu_fid *fid,
 		     struct ptlrpc_request **request)
 {
-	struct obd_device	 *obd = exp->exp_obd;
-	struct lmv_obd	    *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc       *tgt;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
 
 	tgt = lmv_find_target(lmv, fid);
 	if (IS_ERR(tgt))
@@ -2341,13 +2341,13 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 		      struct ptlrpc_request **request)
 {
 	struct lmv_stripe_md *lsm = op_data->op_mea1;
-	struct obd_device    *obd = exp->exp_obd;
-	struct lmv_obd	  *lmv = &obd->u.lmv;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *parent_tgt = NULL;
-	struct lmv_tgt_desc     *tgt = NULL;
-	struct mdt_body		*body;
+	struct lmv_tgt_desc *tgt = NULL;
+	struct mdt_body	*body;
 	int stripe_index = 0;
-	int		     rc;
+	int rc;
 
 retry_unlink:
 	/* For striped dir, we need to locate the parent as well */
@@ -2519,9 +2519,9 @@ static int lmv_precleanup(struct obd_device *obd)
 static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 			u32 keylen, void *key, u32 *vallen, void *val)
 {
-	struct obd_device       *obd;
-	struct lmv_obd	  *lmv;
-	int		      rc = 0;
+	struct obd_device *obd;
+	struct lmv_obd *lmv;
+	int rc = 0;
 
 	obd = class_exp2obd(exp);
 	if (!obd) {
@@ -2590,9 +2590,9 @@ static int lmv_set_info_async(const struct lu_env *env, struct obd_export *exp,
 			      u32 keylen, void *key, u32 vallen,
 			      void *val, struct ptlrpc_request_set *set)
 {
-	struct lmv_tgt_desc    *tgt;
-	struct obd_device      *obd;
-	struct lmv_obd	 *lmv;
+	struct lmv_tgt_desc *tgt;
+	struct obd_device *obd;
+	struct lmv_obd *lmv;
 	int rc = 0;
 
 	obd = class_exp2obd(exp);
@@ -2756,10 +2756,10 @@ static int lmv_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 			     enum ldlm_mode mode, enum ldlm_cancel_flags flags,
 			     void *opaque)
 {
-	struct obd_device       *obd = exp->exp_obd;
-	struct lmv_obd	  *lmv = &obd->u.lmv;
-	int		      rc = 0;
-	int		      err;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	int rc = 0;
+	int err;
 	u32 i;
 
 	LASSERT(fid);
@@ -2782,7 +2782,7 @@ static int lmv_set_lock_data(struct obd_export *exp,
 			     const struct lustre_handle *lockh,
 			     void *data, u64 *bits)
 {
-	struct lmv_obd	  *lmv = &exp->exp_obd->u.lmv;
+	struct lmv_obd *lmv = &exp->exp_obd->u.lmv;
 	struct lmv_tgt_desc *tgt = lmv->tgts[0];
 
 	if (!tgt || !tgt->ltd_exp)
@@ -2798,9 +2798,9 @@ static enum ldlm_mode lmv_lock_match(struct obd_export *exp, u64 flags,
 				     enum ldlm_mode mode,
 				     struct lustre_handle *lockh)
 {
-	struct obd_device       *obd = exp->exp_obd;
-	struct lmv_obd	  *lmv = &obd->u.lmv;
-	enum ldlm_mode	      rc;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	enum ldlm_mode rc;
 	int tgt;
 	u32 i;
 
@@ -2840,7 +2840,7 @@ static int lmv_get_lustre_md(struct obd_export *exp,
 			     struct obd_export *md_exp,
 			     struct lustre_md *md)
 {
-	struct lmv_obd	  *lmv = &exp->exp_obd->u.lmv;
+	struct lmv_obd *lmv = &exp->exp_obd->u.lmv;
 	struct lmv_tgt_desc *tgt = lmv->tgts[0];
 
 	if (!tgt || !tgt->ltd_exp)
@@ -2850,8 +2850,8 @@ static int lmv_get_lustre_md(struct obd_export *exp,
 
 static int lmv_free_lustre_md(struct obd_export *exp, struct lustre_md *md)
 {
-	struct obd_device       *obd = exp->exp_obd;
-	struct lmv_obd	  *lmv = &obd->u.lmv;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt = lmv->tgts[0];
 
 	if (md->lmv) {
@@ -2867,9 +2867,9 @@ static int lmv_set_open_replay_data(struct obd_export *exp,
 				    struct obd_client_handle *och,
 				    struct lookup_intent *it)
 {
-	struct obd_device       *obd = exp->exp_obd;
-	struct lmv_obd	  *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc     *tgt;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
 
 	tgt = lmv_find_target(lmv, &och->och_fid);
 	if (IS_ERR(tgt))
@@ -2881,9 +2881,9 @@ static int lmv_set_open_replay_data(struct obd_export *exp,
 static int lmv_clear_open_replay_data(struct obd_export *exp,
 				      struct obd_client_handle *och)
 {
-	struct obd_device       *obd = exp->exp_obd;
-	struct lmv_obd	  *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc     *tgt;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
 
 	tgt = lmv_find_target(lmv, &och->och_fid);
 	if (IS_ERR(tgt))
@@ -2895,9 +2895,9 @@ static int lmv_clear_open_replay_data(struct obd_export *exp,
 static int lmv_intent_getattr_async(struct obd_export *exp,
 				    struct md_enqueue_info *minfo)
 {
-	struct md_op_data       *op_data = &minfo->mi_data;
-	struct obd_device       *obd = exp->exp_obd;
-	struct lmv_obd	  *lmv = &obd->u.lmv;
+	struct md_op_data *op_data = &minfo->mi_data;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *ptgt = NULL;
 	struct lmv_tgt_desc *ctgt = NULL;
 
@@ -2927,9 +2927,9 @@ static int lmv_intent_getattr_async(struct obd_export *exp,
 static int lmv_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 			       struct lu_fid *fid, u64 *bits)
 {
-	struct obd_device       *obd = exp->exp_obd;
-	struct lmv_obd	  *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc     *tgt;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
 
 	tgt = lmv_find_target(lmv, fid);
 	if (IS_ERR(tgt))
@@ -2963,8 +2963,8 @@ static int lmv_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 static int lmv_quotactl(struct obd_device *unused, struct obd_export *exp,
 			struct obd_quotactl *oqctl)
 {
-	struct obd_device   *obd = class_exp2obd(exp);
-	struct lmv_obd      *lmv = &obd->u.lmv;
+	struct obd_device *obd = class_exp2obd(exp);
+	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt = lmv->tgts[0];
 	int rc = 0;
 	u64 curspace = 0, curinodes = 0;
@@ -3045,20 +3045,20 @@ static int lmv_merge_attr(struct obd_export *exp,
 }
 
 static struct obd_ops lmv_obd_ops = {
-	.owner		= THIS_MODULE,
-	.setup		= lmv_setup,
-	.cleanup	= lmv_cleanup,
-	.precleanup	= lmv_precleanup,
-	.process_config	= lmv_process_config,
-	.connect	= lmv_connect,
-	.disconnect	= lmv_disconnect,
-	.statfs		= lmv_statfs,
-	.get_info	= lmv_get_info,
-	.set_info_async	= lmv_set_info_async,
-	.notify		= lmv_notify,
-	.get_uuid	= lmv_get_uuid,
-	.iocontrol	= lmv_iocontrol,
-	.quotactl	= lmv_quotactl
+	.owner			= THIS_MODULE,
+	.setup			= lmv_setup,
+	.cleanup		= lmv_cleanup,
+	.precleanup		= lmv_precleanup,
+	.process_config		= lmv_process_config,
+	.connect		= lmv_connect,
+	.disconnect		= lmv_disconnect,
+	.statfs			= lmv_statfs,
+	.get_info		= lmv_get_info,
+	.set_info_async		= lmv_set_info_async,
+	.notify			= lmv_notify,
+	.get_uuid		= lmv_get_uuid,
+	.iocontrol		= lmv_iocontrol,
+	.quotactl		= lmv_quotactl
 };
 
 static struct md_ops lmv_md_ops = {
diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
index 4e30026..e40473c 100644
--- a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
+++ b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
@@ -78,8 +78,8 @@ static ssize_t desc_uuid_show(struct kobject *kobj, struct attribute *attr,
 
 static void *lmv_tgt_seq_start(struct seq_file *p, loff_t *pos)
 {
-	struct obd_device       *dev = p->private;
-	struct lmv_obd	  *lmv = &dev->u.lmv;
+	struct obd_device *dev = p->private;
+	struct lmv_obd *lmv = &dev->u.lmv;
 
 	while (*pos < lmv->tgts_size) {
 		if (lmv->tgts[*pos])
@@ -96,8 +96,8 @@ static void lmv_tgt_seq_stop(struct seq_file *p, void *v)
 
 static void *lmv_tgt_seq_next(struct seq_file *p, void *v, loff_t *pos)
 {
-	struct obd_device       *dev = p->private;
-	struct lmv_obd	  *lmv = &dev->u.lmv;
+	struct obd_device *dev = p->private;
+	struct lmv_obd *lmv = &dev->u.lmv;
 
 	++*pos;
 	while (*pos < lmv->tgts_size) {
@@ -106,12 +106,12 @@ static void *lmv_tgt_seq_next(struct seq_file *p, void *v, loff_t *pos)
 		++*pos;
 	}
 
-	return  NULL;
+	return NULL;
 }
 
 static int lmv_tgt_seq_show(struct seq_file *p, void *v)
 {
-	struct lmv_tgt_desc     *tgt = v;
+	struct lmv_tgt_desc *tgt = v;
 
 	if (!tgt)
 		return 0;
@@ -123,16 +123,16 @@ static int lmv_tgt_seq_show(struct seq_file *p, void *v)
 }
 
 static const struct seq_operations lmv_tgt_sops = {
-	.start		 = lmv_tgt_seq_start,
-	.stop		  = lmv_tgt_seq_stop,
-	.next		  = lmv_tgt_seq_next,
-	.show		  = lmv_tgt_seq_show,
+	.start		= lmv_tgt_seq_start,
+	.stop		= lmv_tgt_seq_stop,
+	.next		= lmv_tgt_seq_next,
+	.show		= lmv_tgt_seq_show,
 };
 
 static int lmv_target_seq_open(struct inode *inode, struct file *file)
 {
-	struct seq_file	 *seq;
-	int		     rc;
+	struct seq_file *seq;
+	int rc;
 
 	rc = seq_open(file, &lmv_tgt_sops);
 	if (rc)
-- 
1.8.3.1
