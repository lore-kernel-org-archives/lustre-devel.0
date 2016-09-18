From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:11 -0400
Subject: [lustre-devel] [PATCH 072/124] staging: lustre: echo: replace
	lov_stripe_md with lov_oinfo
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-73-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

In echo_client replace uses of struct lov_stripe_md with struct
lov_oinfo (since the instances of the former really only contained a
single instance of the latter). Remove the then unneccessary functions
echo_alloc_memmd(), echo_free_memmd(), osc_unpackmd(), and
obd_alloc_memmd(). Remove the struct lov_stripe_md * parameter from
obd_create().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5418
Reviewed-on: http://review.whamcloud.com/12447
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |    3 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |   14 +--
 .../staging/lustre/lustre/obdecho/echo_client.c    |  143 +++++--------------
 drivers/staging/lustre/lustre/osc/osc_request.c    |   44 +------
 4 files changed, 45 insertions(+), 159 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 04a9b97..ca63891 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -867,8 +867,7 @@ struct obd_ops {
 			struct lov_stripe_md **mem_tgt,
 			struct lov_mds_md *disk_src, int disk_len);
 	int (*create)(const struct lu_env *env, struct obd_export *exp,
-		      struct obdo *oa, struct lov_stripe_md **ea,
-		      struct obd_trans_info *oti);
+		      struct obdo *oa, struct obd_trans_info *oti);
 	int (*destroy)(const struct lu_env *env, struct obd_export *exp,
 		       struct obdo *oa, struct lov_stripe_md *ea,
 		       struct obd_trans_info *oti, struct obd_export *md_exp);
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 3245952..2bf2826 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -677,15 +677,6 @@ static inline int obd_unpackmd(struct obd_export *exp,
 	return rc;
 }
 
-/* helper functions */
-static inline int obd_alloc_memmd(struct obd_export *exp,
-				  struct lov_stripe_md **mem_tgt)
-{
-	LASSERT(mem_tgt);
-	LASSERT(!*mem_tgt);
-	return obd_unpackmd(exp, mem_tgt, NULL, 0);
-}
-
 static inline int obd_free_memmd(struct obd_export *exp,
 				 struct lov_stripe_md **mem_tgt)
 {
@@ -699,15 +690,14 @@ static inline int obd_free_memmd(struct obd_export *exp,
 }
 
 static inline int obd_create(const struct lu_env *env, struct obd_export *exp,
-			     struct obdo *obdo, struct lov_stripe_md **ea,
-			     struct obd_trans_info *oti)
+			     struct obdo *obdo, struct obd_trans_info *oti)
 {
 	int rc;
 
 	EXP_CHECK_DT_OP(exp, create);
 	EXP_COUNTER_INCREMENT(exp, create);
 
-	rc = OBP(exp->exp_obd, create)(env, exp, obdo, ea, oti);
+	rc = OBP(exp->exp_obd, create)(env, exp, obdo, oti);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index cddc2d2..e487fda 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -65,14 +65,14 @@ struct echo_object {
 
 	struct echo_device     *eo_dev;
 	struct list_head	      eo_obj_chain;
-	struct lov_stripe_md   *eo_lsm;
+	struct lov_oinfo       *eo_oinfo;
 	atomic_t	    eo_npages;
 	int		     eo_deleted;
 };
 
 struct echo_object_conf {
 	struct cl_object_conf  eoc_cl;
-	struct lov_stripe_md **eoc_md;
+	struct lov_oinfo      **eoc_oinfo;
 };
 
 struct echo_page {
@@ -153,9 +153,6 @@ struct echo_object_conf *cl2echo_conf(const struct cl_object_conf *c)
 }
 
 /** @} echo_helpers */
-
-static struct echo_object *cl_echo_object_find(struct echo_device *d,
-					       struct lov_stripe_md **lsm);
 static int cl_echo_object_put(struct echo_object *eco);
 static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 			      struct page **pages, int npages, int async);
@@ -414,10 +411,13 @@ static int echo_object_init(const struct lu_env *env, struct lu_object *obj,
 	cconf = lu2cl_conf(conf);
 	econf = cl2echo_conf(cconf);
 
-	LASSERT(econf->eoc_md);
-	eco->eo_lsm = *econf->eoc_md;
-	/* clear the lsm pointer so that it won't get freed. */
-	*econf->eoc_md = NULL;
+	LASSERT(econf->eoc_oinfo);
+	/*
+	 * Transfer the oinfo pointer to eco that it won't be
+	 * freed.
+	 */
+	eco->eo_oinfo = *econf->eoc_oinfo;
+	*econf->eoc_oinfo = NULL;
 
 	eco->eo_dev = ed;
 	atomic_set(&eco->eo_npages, 0);
@@ -430,52 +430,6 @@ static int echo_object_init(const struct lu_env *env, struct lu_object *obj,
 	return 0;
 }
 
-/* taken from osc_unpackmd() */
-static int echo_alloc_memmd(struct echo_device *ed,
-			    struct lov_stripe_md **lsmp)
-{
-	int lsm_size;
-
-	/* If export is lov/osc then use their obd method */
-	if (ed->ed_next)
-		return obd_alloc_memmd(ed->ed_ec->ec_exp, lsmp);
-	/* OFD has no unpackmd method, do everything here */
-	lsm_size = lov_stripe_md_size(1);
-
-	LASSERT(!*lsmp);
-	*lsmp = kzalloc(lsm_size, GFP_NOFS);
-	if (!*lsmp)
-		return -ENOMEM;
-
-	(*lsmp)->lsm_oinfo[0] = kzalloc(sizeof(struct lov_oinfo), GFP_NOFS);
-	if (!(*lsmp)->lsm_oinfo[0]) {
-		kfree(*lsmp);
-		return -ENOMEM;
-	}
-
-	loi_init((*lsmp)->lsm_oinfo[0]);
-	(*lsmp)->lsm_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
-	ostid_set_seq_echo(&(*lsmp)->lsm_oi);
-
-	return lsm_size;
-}
-
-static int echo_free_memmd(struct echo_device *ed, struct lov_stripe_md **lsmp)
-{
-	int lsm_size;
-
-	/* If export is lov/osc then use their obd method */
-	if (ed->ed_next)
-		return obd_free_memmd(ed->ed_ec->ec_exp, lsmp);
-	/* OFD has no unpackmd method, do everything here */
-	lsm_size = lov_stripe_md_size(1);
-
-	kfree((*lsmp)->lsm_oinfo[0]);
-	kfree(*lsmp);
-	*lsmp = NULL;
-	return 0;
-}
-
 static void echo_object_free(const struct lu_env *env, struct lu_object *obj)
 {
 	struct echo_object *eco    = cl2echo_obj(lu2cl(obj));
@@ -490,8 +444,7 @@ static void echo_object_free(const struct lu_env *env, struct lu_object *obj)
 	lu_object_fini(obj);
 	lu_object_header_fini(obj->lo_header);
 
-	if (eco->eo_lsm)
-		echo_free_memmd(eco->eo_dev, &eco->eo_lsm);
+	kfree(eco->eo_oinfo);
 	kmem_cache_free(echo_object_kmem, eco);
 }
 
@@ -865,25 +818,21 @@ static struct lu_device_type echo_device_type = {
  */
 
 /* Interfaces to echo client obd device */
-static struct echo_object *cl_echo_object_find(struct echo_device *d,
-					       struct lov_stripe_md **lsmp)
+static struct echo_object *
+cl_echo_object_find(struct echo_device *d, const struct ost_id *oi)
 {
 	struct lu_env *env;
 	struct echo_thread_info *info;
 	struct echo_object_conf *conf;
-	struct lov_stripe_md    *lsm;
+	struct lov_oinfo *oinfo = NULL;
 	struct echo_object *eco;
 	struct cl_object   *obj;
 	struct lu_fid *fid;
 	int refcheck;
 	int rc;
 
-	LASSERT(lsmp);
-	lsm = *lsmp;
-	LASSERT(lsm);
-	LASSERTF(ostid_id(&lsm->lsm_oi) != 0, DOSTID"\n", POSTID(&lsm->lsm_oi));
-	LASSERTF(ostid_seq(&lsm->lsm_oi) == FID_SEQ_ECHO, DOSTID"\n",
-		 POSTID(&lsm->lsm_oi));
+	LASSERTF(ostid_id(oi), DOSTID "\n", POSTID(oi));
+	LASSERTF(ostid_seq(oi) == FID_SEQ_ECHO, DOSTID "\n", POSTID(oi));
 
 	/* Never return an object if the obd is to be freed. */
 	if (echo_dev2cl(d)->cd_lu_dev.ld_obd->obd_stopping)
@@ -896,16 +845,24 @@ static struct echo_object *cl_echo_object_find(struct echo_device *d,
 	info = echo_env_info(env);
 	conf = &info->eti_conf;
 	if (d->ed_next) {
-		struct lov_oinfo *oinfo = lsm->lsm_oinfo[0];
+		oinfo = kzalloc(sizeof(*oinfo), GFP_NOFS);
+		if (!oinfo) {
+			eco = ERR_PTR(-ENOMEM);
+			goto out;
+		}
 
-		LASSERT(oinfo);
-		oinfo->loi_oi = lsm->lsm_oi;
+		oinfo->loi_oi = *oi;
 		conf->eoc_cl.u.coc_oinfo = oinfo;
 	}
-	conf->eoc_md = lsmp;
+
+	/*
+	 * If echo_object_init() is successful then ownership of oinfo
+	 * is transferred to the object.
+	 */
+	conf->eoc_oinfo = &oinfo;
 
 	fid  = &info->eti_fid;
-	rc = ostid_to_fid(fid, &lsm->lsm_oi, 0);
+	rc = ostid_to_fid(fid, (struct ost_id *)oi, 0);
 	if (rc != 0) {
 		eco = ERR_PTR(rc);
 		goto out;
@@ -928,6 +885,7 @@ static struct echo_object *cl_echo_object_find(struct echo_device *d,
 	}
 
 out:
+	kfree(oinfo);
 	cl_env_put(env, &refcheck);
 	return eco;
 }
@@ -1146,7 +1104,6 @@ static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
 {
 	struct echo_object     *eco;
 	struct echo_client_obd *ec = ed->ed_ec;
-	struct lov_stripe_md   *lsm = NULL;
 	int		     rc;
 	int		     created = 0;
 
@@ -1157,30 +1114,19 @@ static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
 		return -EINVAL;
 	}
 
-	rc = echo_alloc_memmd(ed, &lsm);
-	if (rc < 0) {
-		CERROR("Cannot allocate md: rc = %d\n", rc);
-		goto failed;
-	}
-
-	/* setup object ID here */
-	lsm->lsm_oi = oa->o_oi;
+	if (!ostid_id(&oa->o_oi))
+		ostid_set_id(&oa->o_oi, ++last_object_id);
 
-	if (ostid_id(&lsm->lsm_oi) == 0)
-		ostid_set_id(&lsm->lsm_oi, ++last_object_id);
-
-	rc = obd_create(env, ec->ec_exp, oa, &lsm, oti);
+	rc = obd_create(env, ec->ec_exp, oa, oti);
 	if (rc != 0) {
 		CERROR("Cannot create objects: rc = %d\n", rc);
 		goto failed;
 	}
 	created = 1;
 
-	/* See what object ID we were given */
-	oa->o_oi = lsm->lsm_oi;
 	oa->o_valid |= OBD_MD_FLID;
 
-	eco = cl_echo_object_find(ed, &lsm);
+	eco = cl_echo_object_find(ed, &oa->o_oi);
 	if (IS_ERR(eco)) {
 		rc = PTR_ERR(eco);
 		goto failed;
@@ -1191,9 +1137,7 @@ static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
 
  failed:
 	if (created && rc)
-		obd_destroy(env, ec->ec_exp, oa, lsm, oti, NULL);
-	if (lsm)
-		echo_free_memmd(ed, &lsm);
+		obd_destroy(env, ec->ec_exp, oa, NULL, oti, NULL);
 	if (rc)
 		CERROR("create object failed with: rc = %d\n", rc);
 	return rc;
@@ -1202,32 +1146,21 @@ static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
 static int echo_get_object(struct echo_object **ecop, struct echo_device *ed,
 			   struct obdo *oa)
 {
-	struct lov_stripe_md   *lsm = NULL;
 	struct echo_object     *eco;
 	int		     rc;
 
-	if ((oa->o_valid & OBD_MD_FLID) == 0 || ostid_id(&oa->o_oi) == 0) {
-		/* disallow use of object id 0 */
-		CERROR("No valid oid\n");
+	if (!(oa->o_valid & OBD_MD_FLID) || !(oa->o_valid & OBD_MD_FLGROUP) ||
+	    !ostid_id(&oa->o_oi)) {
+		CERROR("invalid oid " DOSTID "\n", POSTID(&oa->o_oi));
 		return -EINVAL;
 	}
 
-	rc = echo_alloc_memmd(ed, &lsm);
-	if (rc < 0)
-		return rc;
-
-	lsm->lsm_oi = oa->o_oi;
-	if (!(oa->o_valid & OBD_MD_FLGROUP))
-		ostid_set_seq_echo(&lsm->lsm_oi);
-
 	rc = 0;
-	eco = cl_echo_object_find(ed, &lsm);
+	eco = cl_echo_object_find(ed, &oa->o_oi);
 	if (!IS_ERR(eco))
 		*ecop = eco;
 	else
 		rc = PTR_ERR(eco);
-	if (lsm)
-		echo_free_memmd(ed, &lsm);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 71f6abe..aefd776 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -398,24 +398,16 @@ static int osc_setattr_async(struct obd_export *exp, struct obd_info *oinfo,
 				      oinfo->oi_cb_up, oinfo, rqset);
 }
 
-static int osc_real_create(struct obd_export *exp, struct obdo *oa,
-			   struct lov_stripe_md **ea,
-			   struct obd_trans_info *oti)
+static int osc_create(const struct lu_env *env, struct obd_export *exp,
+		      struct obdo *oa, struct obd_trans_info *oti)
 {
 	struct ptlrpc_request *req;
 	struct ost_body *body;
-	struct lov_stripe_md *lsm;
 	int rc;
 
 	LASSERT(oa);
-	LASSERT(ea);
-
-	lsm = *ea;
-	if (!lsm) {
-		rc = obd_alloc_memmd(exp, &lsm);
-		if (rc < 0)
-			return rc;
-	}
+	LASSERT(oa->o_valid & OBD_MD_FLGROUP);
+	LASSERT(fid_seq_is_echo(ostid_seq(&oa->o_oi)));
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_CREATE);
 	if (!req) {
@@ -461,13 +453,6 @@ static int osc_real_create(struct obd_export *exp, struct obdo *oa,
 	oa->o_blksize = cli_brw_size(exp->exp_obd);
 	oa->o_valid |= OBD_MD_FLBLKSZ;
 
-	/* XXX LOV STACKING: the lsm that is passed to us from LOV does not
-	 * have valid lsm_oinfo data structs, so don't go touching that.
-	 * This needs to be fixed in a big way.
-	 */
-	lsm->lsm_oi = oa->o_oi;
-	*ea = lsm;
-
 	if (oti && oa->o_valid & OBD_MD_FLCOOKIE) {
 		if (!oti->oti_logcookies)
 			oti->oti_logcookies = &oti->oti_onecookie;
@@ -479,8 +464,6 @@ static int osc_real_create(struct obd_export *exp, struct obdo *oa,
 out_req:
 	ptlrpc_req_finished(req);
 out:
-	if (rc && !*ea)
-		obd_free_memmd(exp, &lsm);
 	return rc;
 }
 
@@ -656,25 +639,6 @@ static int osc_can_send_destroy(struct client_obd *cli)
 	return 0;
 }
 
-static int osc_create(const struct lu_env *env, struct obd_export *exp,
-		      struct obdo *oa, struct lov_stripe_md **ea,
-		      struct obd_trans_info *oti)
-{
-	int rc = 0;
-
-	LASSERT(oa);
-	LASSERT(ea);
-	LASSERT(oa->o_valid & OBD_MD_FLGROUP);
-
-	if (!fid_seq_is_mdt(ostid_seq(&oa->o_oi)))
-		return osc_real_create(exp, oa, ea, oti);
-
-	/* we should not get here anymore */
-	LBUG();
-
-	return rc;
-}
-
 /* Destroy requests can be async always on the client, and we don't even really
  * care about the return code since the client cannot do anything at all about
  * a destroy failure.
-- 
1.7.1
