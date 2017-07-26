From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:22 -0400
Subject: [lustre-devel] [PATCH 06/20] staging: lustre: lmv: assume a real
	connection in lmv_connect()
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: "John L. Hammond" <john.hammond@intel.com>

Assume a real connection in lmv_connect(). Mark OBD_CONNECT_REAL
obsolete. Remove the then unnecessary refcount and exp members of
struct lmv_obd. Remove calls to lmv_check_connect(). Disconnect the
export in the appropriate error path of lmv_connect().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7669
Reviewed-on: http://review.whamcloud.com/18018
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: wangdi <di.wang@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   2 +-
 drivers/staging/lustre/lustre/include/obd.h        |   2 -
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   3 -
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |   5 -
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |   2 -
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 161 +++------------------
 6 files changed, 23 insertions(+), 152 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 77995fa..441a2e3 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1122,7 +1122,7 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT_AT		    0x1000000ULL /*client uses AT */
 #define OBD_CONNECT_LRU_RESIZE      0x2000000ULL /*LRU resize feature. */
 #define OBD_CONNECT_MDS_MDS	    0x4000000ULL /*MDS-MDS connection */
-#define OBD_CONNECT_REAL	    0x8000000ULL /*real connection */
+#define OBD_CONNECT_REAL	    0x8000000ULL /* obsolete since 2.8 */
 #define OBD_CONNECT_CHANGE_QS      0x10000000ULL /*Not used since 2.4 */
 #define OBD_CONNECT_CKSUM	   0x20000000ULL /*support several cksum algos*/
 #define OBD_CONNECT_FID		   0x40000000ULL /*FID is supported by server */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 4ce8506..4dfc31e 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -404,12 +404,10 @@ struct lmv_tgt_desc {
 };
 
 struct lmv_obd {
-	int			refcount;
 	struct lu_client_fld	lmv_fld;
 	spinlock_t		lmv_lock;
 	struct lmv_desc		desc;
 	struct obd_uuid		cluuid;
-	struct obd_export	*exp;
 
 	struct mutex		lmv_init_mutex;
 	int			connected;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 974a05d..69d895d 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -222,9 +222,6 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	else
 		sbi->ll_fop = &ll_file_operations_noflock;
 
-	/* real client */
-	data->ocd_connect_flags |= OBD_CONNECT_REAL;
-
 	/* always ping even if server suppress_pings */
 	if (sbi->ll_flags & LL_SBI_ALWAYS_PING)
 		data->ocd_connect_flags &= ~OBD_CONNECT_PINGLESS;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index f49db6c..5f01a0c 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -474,7 +474,6 @@ int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 		    ldlm_blocking_callback cb_blocking,
 		    __u64 extra_lock_flags)
 {
-	struct obd_device *obd = exp->exp_obd;
 	int		rc;
 
 	LASSERT(fid_is_sane(&op_data->op_fid1));
@@ -484,10 +483,6 @@ int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 	       (int)op_data->op_namelen, op_data->op_name,
 	       PFID(&op_data->op_fid1));
 
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
-
 	if (it->it_op & (IT_LOOKUP | IT_GETATTR | IT_LAYOUT))
 		rc = lmv_intent_lookup(exp, op_data, it, reqp, cb_blocking,
 				       extra_lock_flags);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 12731a17..e839b83 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -42,8 +42,6 @@
 #define LL_IT2STR(it)					\
 	((it) ? ldlm_it2str((it)->it_op) : "0")
 
-int lmv_check_connect(struct obd_device *obd);
-
 int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 		    struct lookup_intent *it, struct ptlrpc_request **reqp,
 		    ldlm_blocking_callback cb_blocking,
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 64fcaef..1c9ff24 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -53,6 +53,8 @@
 #include "../include/lustre_kernelcomm.h"
 #include "lmv_internal.h"
 
+static int lmv_check_connect(struct obd_device *obd);
+
 static void lmv_activate_target(struct lmv_obd *lmv,
 				struct lmv_tgt_desc *tgt,
 				int activate)
@@ -183,59 +185,44 @@ static int lmv_notify(struct obd_device *obd, struct obd_device *watched,
 	return rc;
 }
 
-/**
- * This is fake connect function. Its purpose is to initialize lmv and say
- * caller that everything is okay. Real connection will be performed later.
- */
 static int lmv_connect(const struct lu_env *env,
-		       struct obd_export **exp, struct obd_device *obd,
+		       struct obd_export **pexp, struct obd_device *obd,
 		       struct obd_uuid *cluuid, struct obd_connect_data *data,
 		       void *localdata)
 {
 	struct lmv_obd	*lmv = &obd->u.lmv;
 	struct lustre_handle  conn = { 0 };
+	struct obd_export *exp;
 	int		    rc = 0;
 
-	/*
-	 * We don't want to actually do the underlying connections more than
-	 * once, so keep track.
-	 */
-	lmv->refcount++;
-	if (lmv->refcount > 1) {
-		*exp = NULL;
-		return 0;
-	}
-
 	rc = class_connect(&conn, obd, cluuid);
 	if (rc) {
 		CERROR("class_connection() returned %d\n", rc);
 		return rc;
 	}
 
-	*exp = class_conn2export(&conn);
-	class_export_get(*exp);
+	exp = class_conn2export(&conn);
 
-	lmv->exp = *exp;
 	lmv->connected = 0;
 	lmv->cluuid = *cluuid;
-
-	if (data)
-		lmv->conn_data = *data;
+	lmv->conn_data = *data;
 
 	lmv->lmv_tgts_kobj = kobject_create_and_add("target_obds",
 						    &obd->obd_kobj);
-	/*
-	 * All real clients should perform actual connection right away, because
-	 * it is possible, that LMV will not have opportunity to connect targets
-	 * and MDC stuff will be called directly, for instance while reading
-	 * ../mdc/../kbytesfree procfs file, etc.
-	 */
-	if (data && data->ocd_connect_flags & OBD_CONNECT_REAL)
-		rc = lmv_check_connect(obd);
+	rc = lmv_check_connect(obd);
+	if (rc)
+		goto out_sysfs;
+
+	*pexp = exp;
 
-	if (rc && lmv->lmv_tgts_kobj)
+	return rc;
+
+out_sysfs:
+	if (lmv->lmv_tgts_kobj)
 		kobject_put(lmv->lmv_tgts_kobj);
 
+	class_disconnect(exp);
+
 	return rc;
 }
 
@@ -475,7 +462,7 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 	return rc;
 }
 
-int lmv_check_connect(struct obd_device *obd)
+static int lmv_check_connect(struct obd_device *obd)
 {
 	struct lmv_obd       *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc  *tgt;
@@ -519,7 +506,6 @@ int lmv_check_connect(struct obd_device *obd)
 			goto out_disc;
 	}
 
-	class_export_put(lmv->exp);
 	lmv->connected = 1;
 	easize = lmv_mds_md_size(lmv->desc.ld_tgt_count, LMV_MAGIC);
 	lmv_init_ea_size(obd->obd_self_export, easize, 0);
@@ -543,7 +529,7 @@ int lmv_check_connect(struct obd_device *obd)
 			}
 		}
 	}
-	class_disconnect(lmv->exp);
+
 	mutex_unlock(&lmv->lmv_init_mutex);
 	return rc;
 }
@@ -598,13 +584,6 @@ static int lmv_disconnect(struct obd_export *exp)
 	if (!lmv->tgts)
 		goto out_local;
 
-	/*
-	 * Only disconnect the underlying layers on the final disconnect.
-	 */
-	lmv->refcount--;
-	if (lmv->refcount != 0)
-		goto out_local;
-
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
 		if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp)
 			continue;
@@ -623,8 +602,7 @@ static int lmv_disconnect(struct obd_export *exp)
 	if (!lmv->connected)
 		class_export_put(exp);
 	rc = class_disconnect(exp);
-	if (lmv->refcount == 0)
-		lmv->connected = 0;
+	lmv->connected = 0;
 	return rc;
 }
 
@@ -1122,7 +1100,8 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 			err = obd_iocontrol(cmd, tgt->ltd_exp, len, karg, uarg);
 			if (err) {
 				if (tgt->ltd_active) {
-					CERROR("error: iocontrol MDC %s on MDTidx %d cmd %x: err = %d\n",
+					CERROR("%s: error: iocontrol MDC %s on MDTidx %d cmd %x: err = %d\n",
+					       lmv2obd_dev(lmv)->obd_name,
 					       tgt->ltd_uuid.uuid, i, cmd, err);
 					if (!rc)
 						rc = err;
@@ -1368,10 +1347,6 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 	int		    rc = 0;
 	u32 i;
 
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
-
 	temp = kzalloc(sizeof(*temp), GFP_NOFS);
 	if (!temp)
 		return -ENOMEM;
@@ -1418,11 +1393,6 @@ static int lmv_getstatus(struct obd_export *exp,
 {
 	struct obd_device    *obd = exp->exp_obd;
 	struct lmv_obd       *lmv = &obd->u.lmv;
-	int		   rc;
-
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
 
 	return md_getstatus(lmv->tgts[0]->ltd_exp, fid);
 }
@@ -1435,11 +1405,6 @@ static int lmv_getxattr(struct obd_export *exp, const struct lu_fid *fid,
 	struct obd_device      *obd = exp->exp_obd;
 	struct lmv_obd	 *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc    *tgt;
-	int		     rc;
-
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
 
 	tgt = lmv_find_target(lmv, fid);
 	if (IS_ERR(tgt))
@@ -1458,11 +1423,6 @@ static int lmv_setxattr(struct obd_export *exp, const struct lu_fid *fid,
 	struct obd_device      *obd = exp->exp_obd;
 	struct lmv_obd	 *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc    *tgt;
-	int		     rc;
-
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
 
 	tgt = lmv_find_target(lmv, fid);
 	if (IS_ERR(tgt))
@@ -1479,11 +1439,6 @@ static int lmv_getattr(struct obd_export *exp, struct md_op_data *op_data,
 	struct obd_device       *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc     *tgt;
-	int		      rc;
-
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
 
 	tgt = lmv_find_target(lmv, &op_data->op_fid1);
 	if (IS_ERR(tgt))
@@ -1502,11 +1457,6 @@ static int lmv_null_inode(struct obd_export *exp, const struct lu_fid *fid)
 	struct obd_device   *obd = exp->exp_obd;
 	struct lmv_obd      *lmv = &obd->u.lmv;
 	u32 i;
-	int		  rc;
-
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
 
 	CDEBUG(D_INODE, "CBDATA for " DFID "\n", PFID(fid));
 
@@ -1530,11 +1480,6 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 	struct obd_device     *obd = exp->exp_obd;
 	struct lmv_obd	*lmv = &obd->u.lmv;
 	struct lmv_tgt_desc   *tgt;
-	int		    rc;
-
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
 
 	tgt = lmv_find_target(lmv, &op_data->op_fid1);
 	if (IS_ERR(tgt))
@@ -1661,10 +1606,6 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	struct lmv_tgt_desc     *tgt;
 	int		      rc;
 
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
-
 	if (!lmv->desc.ld_active_tgt_count)
 		return -EIO;
 
@@ -1718,11 +1659,6 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	struct obd_device	*obd = exp->exp_obd;
 	struct lmv_obd	   *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc      *tgt;
-	int		       rc;
-
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
 
 	CDEBUG(D_INODE, "ENQUEUE '%s' on " DFID "\n",
 	       LL_IT2STR(it), PFID(&op_data->op_fid1));
@@ -1749,10 +1685,6 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	struct mdt_body	 *body;
 	int		      rc;
 
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
-
 	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
@@ -1845,10 +1777,6 @@ static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 	struct lmv_tgt_desc     *tgt;
 	int		      rc;
 
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
-
 	LASSERT(op_data->op_namelen != 0);
 
 	CDEBUG(D_INODE, "LINK " DFID ":%*s to " DFID "\n",
@@ -1907,10 +1835,6 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	       (int)newlen, new, PFID(&op_data->op_fid2),
 	       op_data->op_mea2 ? op_data->op_mea2->lsm_md_stripe_count : 0);
 
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
-
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
 	op_data->op_cap = cfs_curproc_cap_pack();
@@ -2063,11 +1987,6 @@ static int lmv_setattr(struct obd_export *exp, struct md_op_data *op_data,
 	struct obd_device       *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc     *tgt;
-	int		      rc;
-
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
 
 	CDEBUG(D_INODE, "SETATTR for " DFID ", valid 0x%x\n",
 	       PFID(&op_data->op_fid1), op_data->op_attr.ia_valid);
@@ -2086,11 +2005,6 @@ static int lmv_sync(struct obd_export *exp, const struct lu_fid *fid,
 	struct obd_device	 *obd = exp->exp_obd;
 	struct lmv_obd	    *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc       *tgt;
-	int			rc;
-
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
 
 	tgt = lmv_find_target(lmv, fid);
 	if (IS_ERR(tgt))
@@ -2272,7 +2186,6 @@ static int lmv_read_striped_page(struct obd_export *exp,
 {
 	struct inode *master_inode = op_data->op_data;
 	struct lu_fid master_fid = op_data->op_fid1;
-	struct obd_device *obd = exp->exp_obd;
 	__u64 hash_offset = offset;
 	__u32 ldp_flags;
 	struct page *min_ent_page = NULL;
@@ -2286,10 +2199,6 @@ static int lmv_read_striped_page(struct obd_export *exp,
 	void *area;
 	int rc;
 
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
-
 	/*
 	 * Allocate a page and read entries from all of stripes and fill
 	 * the page by hash order
@@ -2408,11 +2317,6 @@ static int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
-	int rc;
-
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
 
 	if (unlikely(lsm))
 		return lmv_read_striped_page(exp, op_data, cb_op, offset, ppage);
@@ -2460,9 +2364,6 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	int stripe_index = 0;
 	int		     rc;
 
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
 retry_unlink:
 	/* For striped dir, we need to locate the parent as well */
 	if (lsm) {
@@ -2647,10 +2548,6 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 	if (keylen >= strlen("remote_flag") && !strcmp(key, "remote_flag")) {
 		int i;
 
-		rc = lmv_check_connect(obd);
-		if (rc)
-			return rc;
-
 		LASSERT(*vallen == sizeof(__u32));
 		for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
 			struct lmv_tgt_desc *tgt = lmv->tgts[i];
@@ -2669,10 +2566,6 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 	} else if (KEY_IS(KEY_MAX_EASIZE) ||
 		   KEY_IS(KEY_DEFAULT_EASIZE) ||
 		   KEY_IS(KEY_CONN_DATA)) {
-		rc = lmv_check_connect(obd);
-		if (rc)
-			return rc;
-
 		/*
 		 * Forwarding this request to first MDS, it should know LOV
 		 * desc.
@@ -3021,15 +2914,10 @@ static int lmv_intent_getattr_async(struct obd_export *exp,
 	struct lmv_obd	  *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *ptgt = NULL;
 	struct lmv_tgt_desc *ctgt = NULL;
-	int		      rc;
 
 	if (!fid_is_sane(&op_data->op_fid2))
 		return -EINVAL;
 
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
-
 	ptgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
 	if (IS_ERR(ptgt))
 		return PTR_ERR(ptgt);
@@ -3056,11 +2944,6 @@ static int lmv_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 	struct obd_device       *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc     *tgt;
-	int		      rc;
-
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
 
 	tgt = lmv_find_target(lmv, fid);
 	if (IS_ERR(tgt))
-- 
1.8.3.1
