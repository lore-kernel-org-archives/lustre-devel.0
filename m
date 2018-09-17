From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:31:19 -0400
Subject: [lustre-devel] [PATCH 6/8] lustre: obd: remove OBD ops based stats
In-Reply-To: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
References: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205481-6899-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

Stats maintained via the OBD operations wrappers (obd_setup(),
obd_cleanup(), ...) are less and less interesting to the point that we
should remove them. The only stats files affected by this are
obdfilter.*.stats, obdfilter.*.exports.*.stats and
obdecho.*.stats which are server side only.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-11052
Reviewed-on: https://review.whamcloud.com/32602
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Jesse Hanley <hanleyja@ornl.gov>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h       |  1 -
 drivers/staging/lustre/lustre/include/obd_class.h | 66 +----------------------
 2 files changed, 2 insertions(+), 65 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 44f9b10..8691aec 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -598,7 +598,6 @@ struct obd_device {
 
 	/* Fields used by LProcFS */
 	struct lprocfs_stats	*obd_stats;
-	unsigned int		 obd_cntr_base;
 
 	struct lprocfs_stats	*md_stats;
 	unsigned int		 md_cntr_base;
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index eb0a53d..0c1922e 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -334,33 +334,6 @@ static inline int obd_check_dev_active(struct obd_device *obd)
 	return rc;
 }
 
-#define OBD_COUNTER_OFFSET(op)					\
-	((offsetof(struct obd_ops, op) -			\
-		offsetof(struct obd_ops, iocontrol))		\
-		/ sizeof(((struct obd_ops *)(0))->iocontrol))
-
-#define OBD_COUNTER_INCREMENT(obdx, op)					\
-do {									\
-	if ((obdx)->obd_stats) {					\
-		unsigned int coffset;					\
-		coffset = (unsigned int)((obdx)->obd_cntr_base) +	\
-			OBD_COUNTER_OFFSET(op);				\
-		LASSERT(coffset < (obdx)->obd_stats->ls_num);		\
-		lprocfs_counter_incr((obdx)->obd_stats, coffset);	\
-	}								\
-} while (0)
-
-#define EXP_COUNTER_INCREMENT(export, op)				     \
-do {									     \
-	if ((export)->exp_obd->obd_stats) {				     \
-		unsigned int coffset;					     \
-		coffset = (unsigned int)((export)->exp_obd->obd_cntr_base) + \
-			OBD_COUNTER_OFFSET(op);				     \
-		LASSERT(coffset < (export)->exp_obd->obd_stats->ls_num);     \
-		lprocfs_counter_incr((export)->exp_obd->obd_stats, coffset); \
-	}								     \
-} while (0)
-
 #define MD_COUNTER_OFFSET(op)					\
 	((offsetof(struct md_ops, op) -				\
 		offsetof(struct md_ops, get_root))		\
@@ -422,7 +395,6 @@ static inline int obd_get_info(const struct lu_env *env,
 		       exp->exp_obd->obd_name, __func__);
 		return -ENOTSUPP;
 	}
-	EXP_COUNTER_INCREMENT(exp, get_info);
 
 	rc = OBP(exp->exp_obd, get_info)(env, exp, keylen, key, vallen, val);
 	return rc;
@@ -444,7 +416,6 @@ static inline int obd_set_info_async(const struct lu_env *env,
 		       exp->exp_obd->obd_name, __func__);
 		return -ENOTSUPP;
 	}
-	EXP_COUNTER_INCREMENT(exp, set_info_async);
 
 	rc = OBP(exp->exp_obd, set_info_async)(env, exp, keylen, key, vallen,
 					       val, set);
@@ -506,7 +477,6 @@ static inline int obd_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 			       __func__);
 			return -EOPNOTSUPP;
 		}
-		OBD_COUNTER_INCREMENT(obd, setup);
 		rc = OBP(obd, setup)(obd, cfg);
 	}
 	return rc;
@@ -530,8 +500,6 @@ static inline int obd_precleanup(struct obd_device *obd)
 	if (!obd->obd_type->typ_dt_ops->precleanup)
 		return 0;
 
-	OBD_COUNTER_INCREMENT(obd, precleanup);
-
 	rc = OBP(obd, precleanup)(obd);
 	return rc;
 }
@@ -555,8 +523,6 @@ static inline int obd_cleanup(struct obd_device *obd)
 	if (!obd->obd_type->typ_dt_ops->cleanup)
 		return 0;
 
-	OBD_COUNTER_INCREMENT(obd, cleanup);
-
 	rc = OBP(obd, cleanup)(obd);
 	return rc;
 }
@@ -605,7 +571,6 @@ static inline int obd_process_config(struct obd_device *obd, int datalen,
 		}
 		rc = OBP(obd, process_config)(obd, datalen, data);
 	}
-	OBD_COUNTER_INCREMENT(obd, process_config);
 	obd->obd_process_conf = 0;
 
 	return rc;
@@ -625,7 +590,6 @@ static inline int obd_create(const struct lu_env *env, struct obd_export *exp,
 		       exp->exp_obd->obd_name, __func__);
 		return -EOPNOTSUPP;
 	}
-	EXP_COUNTER_INCREMENT(exp, create);
 
 	rc = OBP(exp->exp_obd, create)(env, exp, obdo);
 	return rc;
@@ -645,7 +609,6 @@ static inline int obd_destroy(const struct lu_env *env, struct obd_export *exp,
 		       exp->exp_obd->obd_name, __func__);
 		return -EOPNOTSUPP;
 	}
-	EXP_COUNTER_INCREMENT(exp, destroy);
 
 	rc = OBP(exp->exp_obd, destroy)(env, exp, obdo);
 	return rc;
@@ -665,7 +628,6 @@ static inline int obd_getattr(const struct lu_env *env, struct obd_export *exp,
 		       exp->exp_obd->obd_name, __func__);
 		return -EOPNOTSUPP;
 	}
-	EXP_COUNTER_INCREMENT(exp, getattr);
 
 	rc = OBP(exp->exp_obd, getattr)(env, exp, oa);
 	return rc;
@@ -685,7 +647,6 @@ static inline int obd_setattr(const struct lu_env *env, struct obd_export *exp,
 		       exp->exp_obd->obd_name, __func__);
 		return -EOPNOTSUPP;
 	}
-	EXP_COUNTER_INCREMENT(exp, setattr);
 
 	rc = OBP(exp->exp_obd, setattr)(env, exp, oa);
 	return rc;
@@ -705,7 +666,6 @@ static inline int obd_add_conn(struct obd_import *imp, struct obd_uuid *uuid,
 		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
 		return -EOPNOTSUPP;
 	}
-	OBD_COUNTER_INCREMENT(obd, add_conn);
 
 	rc = OBP(obd, add_conn)(imp, uuid, priority);
 	return rc;
@@ -724,7 +684,6 @@ static inline int obd_del_conn(struct obd_import *imp, struct obd_uuid *uuid)
 		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
 		return -EOPNOTSUPP;
 	}
-	OBD_COUNTER_INCREMENT(obd, del_conn);
 
 	rc = OBP(obd, del_conn)(imp, uuid);
 	return rc;
@@ -738,8 +697,6 @@ static inline struct obd_uuid *obd_get_uuid(struct obd_export *exp)
 	    !exp->exp_obd->obd_type->typ_dt_ops->get_uuid)
 		return NULL;
 
-	EXP_COUNTER_INCREMENT(exp, get_uuid);
-
 	uuid = OBP(exp->exp_obd, get_uuid)(exp);
 	return uuid;
 }
@@ -768,7 +725,6 @@ static inline int obd_connect(const struct lu_env *env,
 		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
 		return -EOPNOTSUPP;
 	}
-	OBD_COUNTER_INCREMENT(obd, connect);
 
 	rc = OBP(obd, connect)(env, exp, obd, cluuid, data, localdata);
 	/* check that only subset is granted */
@@ -794,8 +750,6 @@ static inline int obd_reconnect(const struct lu_env *env,
 	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->reconnect)
 		return 0;
 
-	OBD_COUNTER_INCREMENT(obd, reconnect);
-
 	rc = OBP(obd, reconnect)(env, exp, obd, cluuid, d, localdata);
 	/* check that only subset is granted */
 	LASSERT(ergo(d, (d->ocd_connect_flags & ocf) == d->ocd_connect_flags));
@@ -815,7 +769,6 @@ static inline int obd_disconnect(struct obd_export *exp)
 		       exp->exp_obd->obd_name, __func__);
 		return -ENOTSUPP;
 	}
-	EXP_COUNTER_INCREMENT(exp, disconnect);
 
 	rc = OBP(exp->exp_obd, disconnect)(exp);
 	return rc;
@@ -828,7 +781,6 @@ static inline int obd_fid_init(struct obd_device *obd, struct obd_export *exp,
 
 	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->fid_init)
 		return 0;
-	OBD_COUNTER_INCREMENT(obd, fid_init);
 
 	rc = OBP(obd, fid_init)(obd, exp, type);
 	return rc;
@@ -840,7 +792,6 @@ static inline int obd_fid_fini(struct obd_device *obd)
 
 	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->fid_fini)
 		return 0;
-	OBD_COUNTER_INCREMENT(obd, fid_fini);
 
 	rc = OBP(obd, fid_fini)(obd);
 	return rc;
@@ -862,7 +813,6 @@ static inline int obd_fid_alloc(const struct lu_env *env,
 		       exp->exp_obd->obd_name, __func__);
 		return -ENOTSUPP;
 	}
-	EXP_COUNTER_INCREMENT(exp, fid_alloc);
 
 	rc = OBP(exp->exp_obd, fid_alloc)(env, exp, fid, op_data);
 	return rc;
@@ -876,7 +826,6 @@ static inline int obd_pool_new(struct obd_device *obd, char *poolname)
 		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
 		return -EOPNOTSUPP;
 	}
-	OBD_COUNTER_INCREMENT(obd, pool_new);
 
 	rc = OBP(obd, pool_new)(obd, poolname);
 	return rc;
@@ -890,7 +839,6 @@ static inline int obd_pool_del(struct obd_device *obd, char *poolname)
 		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
 		return -EOPNOTSUPP;
 	}
-	OBD_COUNTER_INCREMENT(obd, pool_del);
 
 	rc = OBP(obd, pool_del)(obd, poolname);
 	return rc;
@@ -905,7 +853,6 @@ static inline int obd_pool_add(struct obd_device *obd, char *poolname,
 		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
 		return -EOPNOTSUPP;
 	}
-	OBD_COUNTER_INCREMENT(obd, pool_add);
 
 	rc = OBP(obd, pool_add)(obd, poolname, ostname);
 	return rc;
@@ -921,7 +868,6 @@ static inline int obd_pool_rem(struct obd_device *obd,
 		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
 		return -EOPNOTSUPP;
 	}
-	OBD_COUNTER_INCREMENT(obd, pool_rem);
 
 	rc = OBP(obd, pool_rem)(obd, poolname, ostname);
 	return rc;
@@ -966,7 +912,6 @@ static inline int obd_statfs_async(struct obd_export *exp,
 		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
 		return -EOPNOTSUPP;
 	}
-	OBD_COUNTER_INCREMENT(obd, statfs);
 
 	CDEBUG(D_SUPER, "%s: osfs %p age %llu, max_age %llu\n",
 	       obd->obd_name, &obd->obd_osfs, obd->obd_osfs_age, max_age);
@@ -1029,7 +974,6 @@ static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
 		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
 		return -EOPNOTSUPP;
 	}
-	OBD_COUNTER_INCREMENT(obd, statfs);
 
 	CDEBUG(D_SUPER, "osfs %llu, max_age %llu\n",
 	       obd->obd_osfs_age, max_age);
@@ -1071,7 +1015,6 @@ static inline int obd_preprw(const struct lu_env *env, int cmd,
 		       exp->exp_obd->obd_name, __func__);
 		return -ENOTSUPP;
 	}
-	EXP_COUNTER_INCREMENT(exp, preprw);
 
 	rc = OBP(exp->exp_obd, preprw)(env, cmd, exp, oa, objcount, obj, remote,
 				       pages, local);
@@ -1095,7 +1038,6 @@ static inline int obd_commitrw(const struct lu_env *env, int cmd,
 		       exp->exp_obd->obd_name, __func__);
 		return -ENOTSUPP;
 	}
-	EXP_COUNTER_INCREMENT(exp, commitrw);
 
 	rc = OBP(exp->exp_obd, commitrw)(env, cmd, exp, oa, objcount, obj,
 					 rnb, pages, local, orig_rc);
@@ -1116,7 +1058,6 @@ static inline int obd_iocontrol(unsigned int cmd, struct obd_export *exp,
 		       exp->exp_obd->obd_name, __func__);
 		return -ENOTSUPP;
 	}
-	EXP_COUNTER_INCREMENT(exp, iocontrol);
 
 	rc = OBP(exp->exp_obd, iocontrol)(cmd, exp, len, karg, uarg);
 	return rc;
@@ -1130,10 +1071,9 @@ static inline void obd_import_event(struct obd_device *obd,
 		CERROR("NULL device\n");
 		return;
 	}
-	if (obd->obd_set_up && OBP(obd, import_event)) {
-		OBD_COUNTER_INCREMENT(obd, import_event);
+
+	if (obd->obd_set_up && OBP(obd, import_event))
 		OBP(obd, import_event)(obd, imp, event);
-	}
 }
 
 static inline int obd_notify(struct obd_device *obd,
@@ -1156,7 +1096,6 @@ static inline int obd_notify(struct obd_device *obd,
 		return -ENOSYS;
 	}
 
-	OBD_COUNTER_INCREMENT(obd, notify);
 	rc = OBP(obd, notify)(obd, watched, ev);
 	return rc;
 }
@@ -1196,7 +1135,6 @@ static inline int obd_quotactl(struct obd_export *exp,
 		       exp->exp_obd->obd_name, __func__);
 		return -ENOTSUPP;
 	}
-	EXP_COUNTER_INCREMENT(exp, quotactl);
 
 	rc = OBP(exp->exp_obd, quotactl)(exp->exp_obd, exp, oqctl);
 	return rc;
-- 
1.8.3.1
