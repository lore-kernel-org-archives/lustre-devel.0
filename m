From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:07 -0400
Subject: [lustre-devel] [PATCH 068/124] staging: lustre: lov: remove unused
	{get, set}_info handlers
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-69-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

In LOV and OSC remove handlers for the obsolete get and set info keys:
KEY_CAPA_KEY, KEY_CONNECT_FLAG, KEY_EVICT_BY_NID, KEY_LAST_ID,
KEY_LOCK_TO_STRIPE, KEY_MDS_CONN, KEY_NEXT_ID.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5814
Reviewed-on: http://review.whamcloud.com/12445
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h     |    4 -
 drivers/staging/lustre/lustre/lov/lov_obd.c     |  132 ++---------------------
 drivers/staging/lustre/lustre/osc/osc_request.c |   46 +--------
 3 files changed, 10 insertions(+), 172 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 2d25e40..6eac63e 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -681,20 +681,16 @@ enum obd_cleanup_stage {
 #define KEY_INTERMDS	    "inter_mds"
 #define KEY_LAST_ID	     "last_id"
 #define KEY_LAST_FID		"last_fid"
-#define KEY_LOCK_TO_STRIPE      "lock_to_stripe"
 #define KEY_LOVDESC	     "lovdesc"
 #define KEY_MAX_EASIZE		"max_easize"
 #define KEY_DEFAULT_EASIZE	"default_easize"
-#define KEY_MDS_CONN	    "mds_conn"
 #define KEY_MGSSEC	      "mgssec"
-#define KEY_NEXT_ID	     "next_id"
 #define KEY_READ_ONLY	   "read-only"
 #define KEY_REGISTER_TARGET     "register_target"
 #define KEY_SET_FS	      "set_fs"
 #define KEY_TGT_COUNT	   "tgt_count"
 /*      KEY_SET_INFO in lustre_idl.h */
 #define KEY_SPTLRPC_CONF	"sptlrpc_conf"
-#define KEY_CONNECT_FLAG	"connect_flags"
 
 #define KEY_CACHE_SET		"cache_set"
 #define KEY_CACHE_LRU_SHRINK	"cache_lru_shrink"
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index a54cd70..2ee4b19 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1862,73 +1862,14 @@ static int lov_get_info(const struct lu_env *env, struct obd_export *exp,
 {
 	struct obd_device *obddev = class_exp2obd(exp);
 	struct lov_obd *lov = &obddev->u.lov;
-	int i, rc;
+	int rc;
 
 	if (!vallen || !val)
 		return -EFAULT;
 
 	obd_getref(obddev);
 
-	if (KEY_IS(KEY_LOCK_TO_STRIPE)) {
-		struct {
-			char name[16];
-			struct ldlm_lock *lock;
-		} *data = key;
-		struct ldlm_res_id *res_id = &data->lock->l_resource->lr_name;
-		struct lov_oinfo *loi;
-		__u32 *stripe = val;
-
-		if (*vallen < sizeof(*stripe)) {
-			rc = -EFAULT;
-			goto out;
-		}
-		*vallen = sizeof(*stripe);
-
-		/* XXX This is another one of those bits that will need to
-		 * change if we ever actually support nested LOVs.  It uses
-		 * the lock's export to find out which stripe it is.
-		 */
-		/* XXX - it's assumed all the locks for deleted OSTs have
-		 * been cancelled. Also, the export for deleted OSTs will
-		 * be NULL and won't match the lock's export.
-		 */
-		for (i = 0; i < lsm->lsm_stripe_count; i++) {
-			loi = lsm->lsm_oinfo[i];
-			if (lov_oinfo_is_dummy(loi))
-				continue;
-
-			if (!lov->lov_tgts[loi->loi_ost_idx])
-				continue;
-			if (lov->lov_tgts[loi->loi_ost_idx]->ltd_exp ==
-			    data->lock->l_conn_export &&
-			    ostid_res_name_eq(&loi->loi_oi, res_id)) {
-				*stripe = i;
-				rc = 0;
-				goto out;
-			}
-		}
-		LDLM_ERROR(data->lock, "lock on inode without such object");
-		dump_lsm(D_ERROR, lsm);
-		rc = -ENXIO;
-		goto out;
-	} else if (KEY_IS(KEY_LAST_ID)) {
-		struct obd_id_info *info = val;
-		__u32 size = sizeof(u64);
-		struct lov_tgt_desc *tgt;
-
-		LASSERT(*vallen == sizeof(struct obd_id_info));
-		tgt = lov->lov_tgts[info->idx];
-
-		if (!tgt || !tgt->ltd_active) {
-			rc = -ESRCH;
-			goto out;
-		}
-
-		rc = obd_get_info(env, tgt->ltd_exp, keylen, key,
-				  &size, info->data, NULL);
-		rc = 0;
-		goto out;
-	} else if (KEY_IS(KEY_LOVDESC)) {
+	if (KEY_IS(KEY_LOVDESC)) {
 		struct lov_desc *desc_ret = val;
 		*desc_ret = lov->desc;
 
@@ -1937,22 +1878,6 @@ static int lov_get_info(const struct lu_env *env, struct obd_export *exp,
 	} else if (KEY_IS(KEY_FIEMAP)) {
 		rc = lov_fiemap(lov, keylen, key, vallen, val, lsm);
 		goto out;
-	} else if (KEY_IS(KEY_CONNECT_FLAG)) {
-		struct lov_tgt_desc *tgt;
-		__u64 ost_idx = *((__u64 *)val);
-
-		LASSERT(*vallen == sizeof(__u64));
-		LASSERT(ost_idx < lov->desc.ld_tgt_count);
-		tgt = lov->lov_tgts[ost_idx];
-
-		if (!tgt || !tgt->ltd_exp) {
-			rc = -ESRCH;
-			goto out;
-		}
-
-		*((__u64 *)val) = exp_connect_flags(tgt->ltd_exp);
-		rc = 0;
-		goto out;
 	} else if (KEY_IS(KEY_TGT_COUNT)) {
 		*((int *)val) = lov->desc.ld_tgt_count;
 		rc = 0;
@@ -1975,8 +1900,7 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 	u32 count;
 	int i, rc = 0, err;
 	struct lov_tgt_desc *tgt;
-	unsigned int incr = 0, check_uuid = 0, do_inactive = 0, no_set = 0;
-	unsigned int next_id = 0, mds_con = 0;
+	int do_inactive = 0, no_set = 0;
 
 	if (!set) {
 		no_set = 1;
@@ -1988,18 +1912,8 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 	obd_getref(obddev);
 	count = lov->desc.ld_tgt_count;
 
-	if (KEY_IS(KEY_NEXT_ID)) {
-		count = vallen / sizeof(struct obd_id_info);
-		vallen = sizeof(u64);
-		incr = sizeof(struct obd_id_info);
-		do_inactive = 1;
-		next_id = 1;
-	} else if (KEY_IS(KEY_CHECKSUM)) {
+	if (KEY_IS(KEY_CHECKSUM)) {
 		do_inactive = 1;
-	} else if (KEY_IS(KEY_EVICT_BY_NID)) {
-		/* use defaults:  do_inactive = incr = 0; */
-	} else if (KEY_IS(KEY_MDS_CONN)) {
-		mds_con = 1;
 	} else if (KEY_IS(KEY_CACHE_SET)) {
 		LASSERT(!lov->lov_cache);
 		lov->lov_cache = val;
@@ -2007,11 +1921,9 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		cl_cache_incref(lov->lov_cache);
 	}
 
-	for (i = 0; i < count; i++, val = (char *)val + incr) {
-		if (next_id)
-			tgt = lov->lov_tgts[((struct obd_id_info *)val)->idx];
-		else
-			tgt = lov->lov_tgts[i];
+	for (i = 0; i < count; i++) {
+		tgt = lov->lov_tgts[i];
+
 		/* OST was disconnected */
 		if (!tgt || !tgt->ltd_exp)
 			continue;
@@ -2020,34 +1932,8 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		if (!tgt->ltd_active && !do_inactive)
 			continue;
 
-		if (mds_con) {
-			struct mds_group_info *mgi;
-
-			LASSERT(vallen == sizeof(*mgi));
-			mgi = (struct mds_group_info *)val;
-
-			/* Only want a specific OSC */
-			if (mgi->uuid && !obd_uuid_equals(mgi->uuid,
-							  &tgt->ltd_uuid))
-				continue;
-
-			err = obd_set_info_async(env, tgt->ltd_exp,
-						 keylen, key, sizeof(int),
-						 &mgi->group, set);
-		} else if (next_id) {
-			err = obd_set_info_async(env, tgt->ltd_exp,
-						 keylen, key, vallen,
-					((struct obd_id_info *)val)->data, set);
-		} else {
-			/* Only want a specific OSC */
-			if (check_uuid &&
-			    !obd_uuid_equals(val, &tgt->ltd_uuid))
-				continue;
-
-			err = obd_set_info_async(env, tgt->ltd_exp,
-						 keylen, key, vallen, val, set);
-		}
-
+		err = obd_set_info_async(env, tgt->ltd_exp, keylen, key,
+					 vallen, val, set);
 		if (!rc)
 			rc = err;
 	}
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 11c376e..1b6491a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2733,51 +2733,7 @@ static int osc_get_info(const struct lu_env *env, struct obd_export *exp,
 	if (!vallen || !val)
 		return -EFAULT;
 
-	if (KEY_IS(KEY_LOCK_TO_STRIPE)) {
-		__u32 *stripe = val;
-		*vallen = sizeof(*stripe);
-		*stripe = 0;
-		return 0;
-	} else if (KEY_IS(KEY_LAST_ID)) {
-		struct ptlrpc_request *req;
-		u64 *reply;
-		char *tmp;
-		int rc;
-
-		req = ptlrpc_request_alloc(class_exp2cliimp(exp),
-					   &RQF_OST_GET_INFO_LAST_ID);
-		if (!req)
-			return -ENOMEM;
-
-		req_capsule_set_size(&req->rq_pill, &RMF_SETINFO_KEY,
-				     RCL_CLIENT, keylen);
-		rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_GET_INFO);
-		if (rc) {
-			ptlrpc_request_free(req);
-			return rc;
-		}
-
-		tmp = req_capsule_client_get(&req->rq_pill, &RMF_SETINFO_KEY);
-		memcpy(tmp, key, keylen);
-
-		req->rq_no_delay = 1;
-		req->rq_no_resend = 1;
-		ptlrpc_request_set_replen(req);
-		rc = ptlrpc_queue_wait(req);
-		if (rc)
-			goto out;
-
-		reply = req_capsule_server_get(&req->rq_pill, &RMF_OBD_ID);
-		if (!reply) {
-			rc = -EPROTO;
-			goto out;
-		}
-
-		*((u64 *)val) = *reply;
-out:
-		ptlrpc_req_finished(req);
-		return rc;
-	} else if (KEY_IS(KEY_FIEMAP)) {
+	if (KEY_IS(KEY_FIEMAP)) {
 		struct ll_fiemap_info_key *fm_key = key;
 		struct ldlm_res_id res_id;
 		ldlm_policy_data_t policy;
-- 
1.7.1
