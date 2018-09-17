From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:31:18 -0400
Subject: [lustre-devel] [PATCH 5/8] lustre: obd: remove obd_{get,put}ref()
In-Reply-To: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
References: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205481-6899-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

obd_getref() and obd_putref() are only used in the lov layer and only
implemented by the lov layer. So they can be removed in favor of
direct calls. Rename lov_{get,put}ref() to lov_tgts_{get,put}ref()
since they do not manage references on the lov device but on its
targets array.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-11051
Reviewed-on: https://review.whamcloud.com/32529
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h       |  7 ----
 drivers/staging/lustre/lustre/include/obd_class.h | 16 ---------
 drivers/staging/lustre/lustre/lov/lov_dev.c       | 12 ++++---
 drivers/staging/lustre/lustre/lov/lov_internal.h  |  2 ++
 drivers/staging/lustre/lustre/lov/lov_obd.c       | 44 +++++++++++------------
 drivers/staging/lustre/lustre/lov/lov_pool.c      | 10 +++---
 drivers/staging/lustre/lustre/lov/lov_request.c   |  4 +--
 7 files changed, 39 insertions(+), 56 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 50e97b4..44f9b10 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -882,13 +882,6 @@ struct obd_ops {
 			char *ostname);
 	int (*pool_rem)(struct obd_device *obd, char *poolname,
 			char *ostname);
-	void (*getref)(struct obd_device *obd);
-	void (*putref)(struct obd_device *obd);
-	/*
-	 * NOTE: If adding ops, add another LPROCFS_OBD_OP_INIT() line
-	 * to lprocfs_alloc_obd_stats() in obdclass/lprocfs_status.c.
-	 * Also, add a wrapper function in include/linux/obd_class.h.
-	 */
 };
 
 /* lmv structures */
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index aab1092..eb0a53d 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -927,22 +927,6 @@ static inline int obd_pool_rem(struct obd_device *obd,
 	return rc;
 }
 
-static inline void obd_getref(struct obd_device *obd)
-{
-	if (obd->obd_type && OBP(obd, getref)) {
-		OBD_COUNTER_INCREMENT(obd, getref);
-		OBP(obd, getref)(obd);
-	}
-}
-
-static inline void obd_putref(struct obd_device *obd)
-{
-	if (obd->obd_type && OBP(obd, putref)) {
-		OBD_COUNTER_INCREMENT(obd, putref);
-		OBP(obd, putref)(obd);
-	}
-}
-
 static inline int obd_init_export(struct obd_export *exp)
 {
 	int rc = 0;
diff --git a/drivers/staging/lustre/lustre/lov/lov_dev.c b/drivers/staging/lustre/lustre/lov/lov_dev.c
index c7db234..abf2ede 100644
--- a/drivers/staging/lustre/lustre/lov/lov_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lov_dev.c
@@ -266,7 +266,7 @@ static int lov_cl_add_target(const struct lu_env *env, struct lu_device *dev,
 	struct cl_device     *cl;
 	int rc;
 
-	obd_getref(obd);
+	lov_tgts_getref(obd);
 
 	tgt = obd->u.lov.lov_tgts[index];
 
@@ -291,7 +291,9 @@ static int lov_cl_add_target(const struct lu_env *env, struct lu_device *dev,
 			rc = PTR_ERR(cl);
 		}
 	}
-	obd_putref(obd);
+
+	lov_tgts_putref(obd);
+
 	return rc;
 }
 
@@ -304,7 +306,7 @@ static int lov_process_config(const struct lu_env *env,
 	int gen;
 	__u32 index;
 
-	obd_getref(obd);
+	lov_tgts_getref(obd);
 
 	cmd = cfg->lcfg_command;
 	rc = lov_process_config_base(d->ld_obd, cfg, &index, &gen);
@@ -321,7 +323,9 @@ static int lov_process_config(const struct lu_env *env,
 			break;
 		}
 	}
-	obd_putref(obd);
+
+	lov_tgts_putref(obd);
+
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index dbb79d4..44a997e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -207,6 +207,8 @@ int lov_prep_statfs_set(struct obd_device *obd, struct obd_info *oinfo,
 int lov_fini_statfs_set(struct lov_request_set *set);
 
 /* lov_obd.c */
+void lov_tgts_getref(struct obd_device *obd);
+void lov_tgts_putref(struct obd_device *obd);
 void lov_stripe_lock(struct lov_stripe_md *md);
 void lov_stripe_unlock(struct lov_stripe_md *md);
 void lov_fix_desc(struct lov_desc *desc);
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 3483f9b..6959b91 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -62,7 +62,7 @@
 /* Keep a refcount of lov->tgt usage to prevent racing with addition/deletion.
  * Any function that expects lov_tgts to remain stationary must take a ref.
  */
-static void lov_getref(struct obd_device *obd)
+void lov_tgts_getref(struct obd_device *obd)
 {
 	struct lov_obd *lov = &obd->u.lov;
 
@@ -74,7 +74,7 @@ static void lov_getref(struct obd_device *obd)
 
 static void __lov_del_obd(struct obd_device *obd, struct lov_tgt_desc *tgt);
 
-static void lov_putref(struct obd_device *obd)
+void lov_tgts_putref(struct obd_device *obd)
 {
 	struct lov_obd *lov = &obd->u.lov;
 
@@ -231,7 +231,7 @@ static int lov_connect(const struct lu_env *env,
 	if (data)
 		lov->lov_ocd = *data;
 
-	obd_getref(obd);
+	lov_tgts_getref(obd);
 
 	lov->lov_tgts_kobj = kobject_create_and_add("target_obds",
 						    &obd->obd_kset.kobj);
@@ -258,7 +258,7 @@ static int lov_connect(const struct lu_env *env,
 			       obd->obd_name, rc);
 		}
 	}
-	obd_putref(obd);
+	lov_tgts_putref(obd);
 
 	return 0;
 }
@@ -326,7 +326,7 @@ static int lov_disconnect(struct obd_export *exp)
 	/* Let's hold another reference so lov_del_obd doesn't spin through
 	 * putref every time
 	 */
-	obd_getref(obd);
+	lov_tgts_getref(obd);
 
 	for (i = 0; i < lov->desc.ld_tgt_count; i++) {
 		if (lov->lov_tgts[i] && lov->lov_tgts[i]->ltd_exp) {
@@ -335,7 +335,7 @@ static int lov_disconnect(struct obd_export *exp)
 		}
 	}
 
-	obd_putref(obd);
+	lov_tgts_putref(obd);
 
 out:
 	rc = class_disconnect(exp); /* bz 9811 */
@@ -359,7 +359,7 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 	CDEBUG(D_INFO, "Searching in lov %p for uuid %s event(%d)\n",
 	       lov, uuid->uuid, ev);
 
-	obd_getref(obd);
+	lov_tgts_getref(obd);
 	for (index = 0; index < lov->desc.ld_tgt_count; index++) {
 		tgt = lov->lov_tgts[index];
 		if (!tgt)
@@ -426,7 +426,7 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 	}
 
  out:
-	obd_putref(obd);
+	lov_tgts_putref(obd);
 	return index;
 }
 
@@ -574,7 +574,7 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		return 0;
 	}
 
-	obd_getref(obd);
+	lov_tgts_getref(obd);
 
 	rc = lov_connect_obd(obd, index, active, &lov->lov_ocd);
 	if (rc)
@@ -604,7 +604,7 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		       obd_uuid2str(&tgt->ltd_uuid));
 		lov_del_target(obd, index, NULL, 0);
 	}
-	obd_putref(obd);
+	lov_tgts_putref(obd);
 	return rc;
 }
 
@@ -624,7 +624,7 @@ int lov_del_target(struct obd_device *obd, __u32 index,
 
 	/* to make sure there's no ongoing lov_notify() now */
 	down_write(&lov->lov_notify_lock);
-	obd_getref(obd);
+	lov_tgts_getref(obd);
 
 	if (!lov->lov_tgts[index]) {
 		CERROR("LOV target at index %d is not setup.\n", index);
@@ -647,9 +647,9 @@ int lov_del_target(struct obd_device *obd, __u32 index,
 
 	lov->lov_tgts[index]->ltd_reap = 1;
 	lov->lov_death_row++;
-	/* we really delete it from obd_putref */
+	/* we really delete it from lov_tgts_putref */
 out:
-	obd_putref(obd);
+	lov_tgts_putref(obd);
 	up_write(&lov->lov_notify_lock);
 
 	return rc;
@@ -812,7 +812,7 @@ static int lov_cleanup(struct obd_device *obd)
 	if (lov->lov_tgts) {
 		int i;
 
-		obd_getref(obd);
+		lov_tgts_getref(obd);
 		for (i = 0; i < lov->desc.ld_tgt_count; i++) {
 			if (!lov->lov_tgts[i])
 				continue;
@@ -829,7 +829,7 @@ static int lov_cleanup(struct obd_device *obd)
 				       atomic_read(&lov->lov_refcount));
 			lov_del_target(obd, i, NULL, 0);
 		}
-		obd_putref(obd);
+		lov_tgts_putref(obd);
 		kfree(lov->lov_tgts);
 		lov->lov_tgt_size = 0;
 	}
@@ -1182,7 +1182,7 @@ static int lov_get_info(const struct lu_env *env, struct obd_export *exp,
 	if (!vallen || !val)
 		return -EFAULT;
 
-	obd_getref(obddev);
+	lov_tgts_getref(obddev);
 
 	if (KEY_IS(KEY_MAX_EASIZE)) {
 		u32 max_stripe_count = min_t(u32, ld->ld_active_tgt_count,
@@ -1200,7 +1200,7 @@ static int lov_get_info(const struct lu_env *env, struct obd_export *exp,
 		rc = -EINVAL;
 	}
 
-	obd_putref(obddev);
+	lov_tgts_putref(obddev);
 	return rc;
 }
 
@@ -1222,7 +1222,7 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 			return -ENOMEM;
 	}
 
-	obd_getref(obddev);
+	lov_tgts_getref(obddev);
 	count = lov->desc.ld_tgt_count;
 
 	if (KEY_IS(KEY_CHECKSUM)) {
@@ -1251,7 +1251,7 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 			rc = err;
 	}
 
-	obd_putref(obddev);
+	lov_tgts_putref(obddev);
 	if (no_set) {
 		err = ptlrpc_set_wait(set);
 		if (!rc)
@@ -1294,7 +1294,7 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 	}
 
 	/* for lov tgt */
-	obd_getref(obd);
+	lov_tgts_getref(obd);
 	for (i = 0; i < lov->desc.ld_tgt_count; i++) {
 		int err;
 
@@ -1326,7 +1326,7 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 			bhardlimit += oqctl->qc_dqblk.dqb_bhardlimit;
 		}
 	}
-	obd_putref(obd);
+	lov_tgts_putref(obd);
 
 	if (oqctl->qc_cmd == Q_GETOQUOTA) {
 		oqctl->qc_dqblk.dqb_curspace = curspace;
@@ -1352,8 +1352,6 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 	.pool_rem       = lov_pool_remove,
 	.pool_add       = lov_pool_add,
 	.pool_del       = lov_pool_del,
-	.getref         = lov_getref,
-	.putref         = lov_putref,
 	.quotactl       = lov_quotactl,
 };
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index b2a88ba..c79c2ae 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -470,7 +470,7 @@ int lov_pool_add(struct obd_device *obd, char *poolname, char *ostname)
 	obd_str2uuid(&ost_uuid, ostname);
 
 	/* search ost in lov array */
-	obd_getref(obd);
+	lov_tgts_getref(obd);
 	for (lov_idx = 0; lov_idx < lov->desc.ld_tgt_count; lov_idx++) {
 		if (!lov->lov_tgts[lov_idx])
 			continue;
@@ -492,8 +492,9 @@ int lov_pool_add(struct obd_device *obd, char *poolname, char *ostname)
 	       ostname, poolname,  pool_tgt_count(pool));
 
 out:
-	obd_putref(obd);
+	lov_tgts_putref(obd);
 	lov_pool_putref(pool);
+
 	return rc;
 }
 
@@ -517,7 +518,7 @@ int lov_pool_remove(struct obd_device *obd, char *poolname, char *ostname)
 
 	obd_str2uuid(&ost_uuid, ostname);
 
-	obd_getref(obd);
+	lov_tgts_getref(obd);
 	/* search ost in lov array, to get index */
 	for (lov_idx = 0; lov_idx < lov->desc.ld_tgt_count; lov_idx++) {
 		if (!lov->lov_tgts[lov_idx])
@@ -540,7 +541,8 @@ int lov_pool_remove(struct obd_device *obd, char *poolname, char *ostname)
 	       poolname);
 
 out:
-	obd_putref(obd);
+	lov_tgts_putref(obd);
 	lov_pool_putref(pool);
+
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index cb8567f..8ca13ed 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -266,7 +266,7 @@ static int cb_statfs_update(void *cookie, int rc)
 	if (rc)
 		goto out;
 
-	obd_getref(lovobd);
+	lov_tgts_getref(lovobd);
 	tgt = lov->lov_tgts[lovreq->rq_idx];
 	if (!tgt || !tgt->ltd_active)
 		goto out_update;
@@ -280,7 +280,7 @@ static int cb_statfs_update(void *cookie, int rc)
 
 out_update:
 	lov_update_statfs(osfs, lov_sfs, success);
-	obd_putref(lovobd);
+	lov_tgts_putref(lovobd);
 out:
 	return 0;
 }
-- 
1.8.3.1
