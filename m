From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:12 -0400
Subject: [lustre-devel] [PATCH 073/124] staging: lustre: llite: remove
	ll_objects_destroy()
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-74-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Remove ll_objects_destroy(). This function is not needed for
interoperability with servers of version 2.4 or higher.

Remove the then unused function lov_destroy() and its supporting
functions. Remove the lsm_destroy method of struct lsm_operations.

Remove the unused struct lov_stripe_md, MD export, and capa parameters
from obd_destroy() and its implementations.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5814
Reviewed-on: http://review.whamcloud.com/12618
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |    5 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |    6 +-
 drivers/staging/lustre/lustre/llite/file.c         |    6 --
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 -
 drivers/staging/lustre/lustre/llite/namei.c        |   73 ------------------
 drivers/staging/lustre/lustre/lov/lov_ea.c         |    8 --
 drivers/staging/lustre/lustre/lov/lov_internal.h   |    5 -
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   54 --------------
 drivers/staging/lustre/lustre/lov/lov_request.c    |   78 --------------------
 .../staging/lustre/lustre/obdecho/echo_client.c    |    5 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    3 +-
 11 files changed, 6 insertions(+), 239 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index ca63891..cd7f552 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -869,8 +869,7 @@ struct obd_ops {
 	int (*create)(const struct lu_env *env, struct obd_export *exp,
 		      struct obdo *oa, struct obd_trans_info *oti);
 	int (*destroy)(const struct lu_env *env, struct obd_export *exp,
-		       struct obdo *oa, struct lov_stripe_md *ea,
-		       struct obd_trans_info *oti, struct obd_export *md_exp);
+		       struct obdo *oa, struct obd_trans_info *oti);
 	int (*setattr)(const struct lu_env *, struct obd_export *exp,
 		       struct obd_info *oinfo, struct obd_trans_info *oti);
 	int (*setattr_async)(struct obd_export *exp, struct obd_info *oinfo,
@@ -1058,8 +1057,6 @@ struct md_ops {
 
 struct lsm_operations {
 	void (*lsm_free)(struct lov_stripe_md *);
-	int (*lsm_destroy)(struct lov_stripe_md *, struct obdo *oa,
-			   struct obd_export *md_exp);
 	void (*lsm_stripe_by_index)(struct lov_stripe_md *, int *, u64 *,
 				    u64 *);
 	void (*lsm_stripe_by_offset)(struct lov_stripe_md *, int *, u64 *,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 2bf2826..9836aed 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -702,16 +702,14 @@ static inline int obd_create(const struct lu_env *env, struct obd_export *exp,
 }
 
 static inline int obd_destroy(const struct lu_env *env, struct obd_export *exp,
-			      struct obdo *obdo, struct lov_stripe_md *ea,
-			      struct obd_trans_info *oti,
-			      struct obd_export *md_exp)
+			      struct obdo *obdo, struct obd_trans_info *oti)
 {
 	int rc;
 
 	EXP_CHECK_DT_OP(exp, destroy);
 	EXP_COUNTER_INCREMENT(exp, destroy);
 
-	rc = OBP(exp->exp_obd, destroy)(env, exp, obdo, ea, oti, md_exp);
+	rc = OBP(exp->exp_obd, destroy)(env, exp, obdo, oti);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index a562b11..0b3b387 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -189,12 +189,6 @@ static int ll_close_inode_openhandle(struct obd_export *md_exp,
 		spin_unlock(&lli->lli_lock);
 	}
 
-	if (rc == 0) {
-		rc = ll_objects_destroy(req, inode);
-		if (rc)
-			CERROR("inode %lu ll_objects destroy: rc = %d\n",
-			       inode->i_ino, rc);
-	}
 	if (rc == 0 && op_data->op_bias & MDS_HSM_RELEASE) {
 		struct mdt_body *body;
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index bdfdff5..0dc47f2 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -721,8 +721,6 @@ void ll_release_page(struct inode *inode, struct page *page, bool remove);
 /* llite/namei.c */
 extern const struct inode_operations ll_special_inode_operations;
 
-int ll_objects_destroy(struct ptlrpc_request *request,
-		       struct inode *dir);
 struct inode *ll_iget(struct super_block *sb, ino_t hash,
 		      struct lustre_md *lic);
 int ll_test_inode_by_fid(struct inode *inode, void *opaque);
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 494140a..1dd5df5 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -890,77 +890,6 @@ static int ll_create_nd(struct inode *dir, struct dentry *dentry,
 	return rc;
 }
 
-int ll_objects_destroy(struct ptlrpc_request *request, struct inode *dir)
-{
-	struct mdt_body *body;
-	struct lov_mds_md *eadata;
-	struct lov_stripe_md *lsm = NULL;
-	struct obd_trans_info oti = { 0 };
-	struct obdo *oa;
-	int rc;
-
-	/* req is swabbed so this is safe */
-	body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
-	if (!(body->mbo_valid & OBD_MD_FLEASIZE))
-		return 0;
-
-	if (body->mbo_eadatasize == 0) {
-		CERROR("OBD_MD_FLEASIZE set but eadatasize zero\n");
-		rc = -EPROTO;
-		goto out;
-	}
-
-	/* The MDS sent back the EA because we unlinked the last reference
-	 * to this file. Use this EA to unlink the objects on the OST.
-	 * It's opaque so we don't swab here; we leave it to obd_unpackmd() to
-	 * check it is complete and sensible.
-	 */
-	eadata = req_capsule_server_sized_get(&request->rq_pill, &RMF_MDT_MD,
-					      body->mbo_eadatasize);
-	LASSERT(eadata);
-
-	rc = obd_unpackmd(ll_i2dtexp(dir), &lsm, eadata, body->mbo_eadatasize);
-	if (rc < 0) {
-		CERROR("obd_unpackmd: %d\n", rc);
-		goto out;
-	}
-	LASSERT(rc >= sizeof(*lsm));
-
-	oa = kmem_cache_zalloc(obdo_cachep, GFP_NOFS);
-	if (!oa) {
-		rc = -ENOMEM;
-		goto out_free_memmd;
-	}
-
-	oa->o_oi = lsm->lsm_oi;
-	oa->o_mode = body->mbo_mode & S_IFMT;
-	oa->o_valid = OBD_MD_FLID | OBD_MD_FLTYPE | OBD_MD_FLGROUP;
-
-	if (body->mbo_valid & OBD_MD_FLCOOKIE) {
-		oa->o_valid |= OBD_MD_FLCOOKIE;
-		oti.oti_logcookies =
-			req_capsule_server_sized_get(&request->rq_pill,
-						     &RMF_LOGCOOKIES,
-						   sizeof(struct llog_cookie) *
-						     lsm->lsm_stripe_count);
-		if (!oti.oti_logcookies) {
-			oa->o_valid &= ~OBD_MD_FLCOOKIE;
-			body->mbo_valid &= ~OBD_MD_FLCOOKIE;
-		}
-	}
-
-	rc = obd_destroy(NULL, ll_i2dtexp(dir), oa, lsm, &oti,
-			 ll_i2mdexp(dir));
-	if (rc)
-		CERROR("obd destroy objid "DOSTID" error %d\n",
-		       POSTID(&lsm->lsm_oi), rc);
-out_free_memmd:
-	obd_free_memmd(ll_i2dtexp(dir), &lsm);
-	kmem_cache_free(obdo_cachep, oa);
-out:
-	return rc;
-}
-
 /* ll_unlink() doesn't update the inode with the new link count.
  * Instead, ll_ddelete() and ll_d_iput() will update it based upon if there
  * is any lock existing. They will recycle dentries and inodes based upon locks
@@ -994,7 +923,6 @@ static int ll_unlink(struct inode *dir, struct dentry *dchild)
 	ll_update_times(request, dir);
 	ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_UNLINK, 1);
 
-	rc = ll_objects_destroy(request, dir);
  out:
 	ptlrpc_req_finished(request);
 	return rc;
@@ -1130,7 +1058,6 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 		ll_update_times(request, src);
 		ll_update_times(request, tgt);
 		ll_stats_ops_tally(sbi, LPROC_LL_RENAME, 1);
-		err = ll_objects_destroy(request, src);
 	}
 
 	ptlrpc_req_finished(request);
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 9f0b5b7..214c561 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -147,12 +147,6 @@ lsm_stripe_by_offset_plain(struct lov_stripe_md *lsm, int *stripeno,
 		*swidth = (u64)lsm->lsm_stripe_size * lsm->lsm_stripe_count;
 }
 
-static int lsm_destroy_plain(struct lov_stripe_md *lsm, struct obdo *oa,
-			     struct obd_export *md_exp)
-{
-	return 0;
-}
-
 /* Find minimum stripe maxbytes value.  For inactive or
  * reconnecting targets use LUSTRE_EXT3_STRIPE_MAXBYTES.
  */
@@ -246,7 +240,6 @@ static int lsm_unpackmd_v1(struct lov_obd *lov, struct lov_stripe_md *lsm,
 
 const struct lsm_operations lsm_v1_ops = {
 	.lsm_free	    = lsm_free_plain,
-	.lsm_destroy	 = lsm_destroy_plain,
 	.lsm_stripe_by_index    = lsm_stripe_by_index_plain,
 	.lsm_stripe_by_offset   = lsm_stripe_by_offset_plain,
 	.lsm_lmm_verify	 = lsm_lmm_verify_v1,
@@ -336,7 +329,6 @@ static int lsm_unpackmd_v3(struct lov_obd *lov, struct lov_stripe_md *lsm,
 
 const struct lsm_operations lsm_v3_ops = {
 	.lsm_free	    = lsm_free_plain,
-	.lsm_destroy	 = lsm_destroy_plain,
 	.lsm_stripe_by_index    = lsm_stripe_by_index_plain,
 	.lsm_stripe_by_offset   = lsm_stripe_by_offset_plain,
 	.lsm_lmm_verify	 = lsm_lmm_verify_v3,
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 5ddaeda..0e5fc2e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -155,11 +155,6 @@ int lov_update_common_set(struct lov_request_set *set,
 int lov_prep_getattr_set(struct obd_export *exp, struct obd_info *oinfo,
 			 struct lov_request_set **reqset);
 int lov_fini_getattr_set(struct lov_request_set *set);
-int lov_prep_destroy_set(struct obd_export *exp, struct obd_info *oinfo,
-			 struct obdo *src_oa, struct lov_stripe_md *lsm,
-			 struct obd_trans_info *oti,
-			 struct lov_request_set **reqset);
-int lov_fini_destroy_set(struct lov_request_set *set);
 int lov_prep_setattr_set(struct obd_export *exp, struct obd_info *oinfo,
 			 struct obd_trans_info *oti,
 			 struct lov_request_set **reqset);
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index f433515..9b12159 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -980,59 +980,6 @@ do {									    \
 		 "%p->lsm_magic=%x\n", (lsmp), (lsmp)->lsm_magic);	      \
 } while (0)
 
-static int lov_destroy(const struct lu_env *env, struct obd_export *exp,
-		       struct obdo *oa, struct lov_stripe_md *lsm,
-		       struct obd_trans_info *oti, struct obd_export *md_exp)
-{
-	struct lov_request_set *set;
-	struct obd_info oinfo;
-	struct lov_request *req;
-	struct lov_obd *lov;
-	int rc = 0, err = 0;
-
-	ASSERT_LSM_MAGIC(lsm);
-
-	if (!exp || !exp->exp_obd)
-		return -ENODEV;
-
-	if (oa->o_valid & OBD_MD_FLCOOKIE) {
-		LASSERT(oti);
-		LASSERT(oti->oti_logcookies);
-	}
-
-	lov = &exp->exp_obd->u.lov;
-	obd_getref(exp->exp_obd);
-	rc = lov_prep_destroy_set(exp, &oinfo, oa, lsm, oti, &set);
-	if (rc)
-		goto out;
-
-	list_for_each_entry(req, &set->set_list, rq_link) {
-		if (oa->o_valid & OBD_MD_FLCOOKIE)
-			oti->oti_logcookies = set->set_cookies + req->rq_stripe;
-
-		err = obd_destroy(env, lov->lov_tgts[req->rq_idx]->ltd_exp,
-				  req->rq_oi.oi_oa, NULL, oti, NULL);
-		err = lov_update_common_set(set, req, err);
-		if (err) {
-			CERROR("%s: destroying objid "DOSTID" subobj "
-			       DOSTID" on OST idx %d: rc = %d\n",
-			       exp->exp_obd->obd_name, POSTID(&oa->o_oi),
-			       POSTID(&req->rq_oi.oi_oa->o_oi),
-			       req->rq_idx, err);
-			if (!rc)
-				rc = err;
-		}
-	}
-
-	if (rc == 0)
-		rc = lsm_op_find(lsm->lsm_magic)->lsm_destroy(lsm, oa, md_exp);
-
-	err = lov_fini_destroy_set(set);
-out:
-	obd_putref(exp->exp_obd);
-	return rc ? rc : err;
-}
-
 static int lov_getattr_interpret(struct ptlrpc_request_set *rqset,
 				 void *data, int rc)
 {
@@ -2081,7 +2028,6 @@ static struct obd_ops lov_obd_ops = {
 	.statfs_async   = lov_statfs_async,
 	.packmd         = lov_packmd,
 	.unpackmd       = lov_unpackmd,
-	.destroy        = lov_destroy,
 	.getattr_async  = lov_getattr_async,
 	.setattr_async  = lov_setattr_async,
 	.iocontrol      = lov_iocontrol,
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 4099b51..09dcaf4 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -325,84 +325,6 @@ out_set:
 	return rc;
 }
 
-int lov_fini_destroy_set(struct lov_request_set *set)
-{
-	if (!set)
-		return 0;
-	LASSERT(set->set_exp);
-	if (atomic_read(&set->set_completes)) {
-		/* FIXME update qos data here */
-	}
-
-	lov_put_reqset(set);
-
-	return 0;
-}
-
-int lov_prep_destroy_set(struct obd_export *exp, struct obd_info *oinfo,
-			 struct obdo *src_oa, struct lov_stripe_md *lsm,
-			 struct obd_trans_info *oti,
-			 struct lov_request_set **reqset)
-{
-	struct lov_request_set *set;
-	struct lov_obd *lov = &exp->exp_obd->u.lov;
-	int rc = 0, i;
-
-	set = kzalloc(sizeof(*set), GFP_NOFS);
-	if (!set)
-		return -ENOMEM;
-	lov_init_set(set);
-
-	set->set_exp = exp;
-	set->set_oi = oinfo;
-	set->set_oi->oi_md = lsm;
-	set->set_oi->oi_oa = src_oa;
-	if (oti && src_oa->o_valid & OBD_MD_FLCOOKIE)
-		set->set_cookies = oti->oti_logcookies;
-
-	for (i = 0; i < lsm->lsm_stripe_count; i++) {
-		struct lov_oinfo *loi;
-		struct lov_request *req;
-
-		loi = lsm->lsm_oinfo[i];
-		if (lov_oinfo_is_dummy(loi))
-			continue;
-
-		if (!lov_check_and_wait_active(lov, loi->loi_ost_idx)) {
-			CDEBUG(D_HA, "lov idx %d inactive\n", loi->loi_ost_idx);
-			continue;
-		}
-
-		req = kzalloc(sizeof(*req), GFP_NOFS);
-		if (!req) {
-			rc = -ENOMEM;
-			goto out_set;
-		}
-
-		req->rq_stripe = i;
-		req->rq_idx = loi->loi_ost_idx;
-
-		req->rq_oi.oi_oa = kmem_cache_zalloc(obdo_cachep, GFP_NOFS);
-		if (!req->rq_oi.oi_oa) {
-			kfree(req);
-			rc = -ENOMEM;
-			goto out_set;
-		}
-		memcpy(req->rq_oi.oi_oa, src_oa, sizeof(*req->rq_oi.oi_oa));
-		req->rq_oi.oi_oa->o_oi = loi->loi_oi;
-		lov_set_add_req(req, set);
-	}
-	if (!set->set_count) {
-		rc = -EIO;
-		goto out_set;
-	}
-	*reqset = set;
-	return rc;
-out_set:
-	lov_fini_destroy_set(set);
-	return rc;
-}
-
 int lov_fini_setattr_set(struct lov_request_set *set)
 {
 	int rc = 0;
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index e487fda..91d28b5 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1137,7 +1137,7 @@ static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
 
  failed:
 	if (created && rc)
-		obd_destroy(env, ec->ec_exp, oa, NULL, oti, NULL);
+		obd_destroy(env, ec->ec_exp, oa, oti);
 	if (rc)
 		CERROR("create object failed with: rc = %d\n", rc);
 	return rc;
@@ -1546,8 +1546,7 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 
 		rc = echo_get_object(&eco, ed, oa);
 		if (rc == 0) {
-			rc = obd_destroy(env, ec->ec_exp, oa, NULL,
-					 &dummy_oti, NULL);
+			rc = obd_destroy(env, ec->ec_exp, oa, &dummy_oti);
 			if (rc == 0)
 				eco->eo_deleted = 1;
 			echo_put_object(eco);
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index aefd776..59ce7a8 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -651,8 +651,7 @@ static int osc_can_send_destroy(struct client_obd *cli)
  * cookies to the MDS after committing destroy transactions.
  */
 static int osc_destroy(const struct lu_env *env, struct obd_export *exp,
-		       struct obdo *oa, struct lov_stripe_md *ea,
-		       struct obd_trans_info *oti, struct obd_export *md_export)
+		       struct obdo *oa, struct obd_trans_info *oti)
 {
 	struct client_obd *cli = &exp->exp_obd->u.cli;
 	struct ptlrpc_request *req;
-- 
1.7.1
