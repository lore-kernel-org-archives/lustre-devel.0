From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:13 -0500
Subject: [lustre-devel] [PATCH 505/622] lustre: obdclass: lu_tgt_descs
 cleanup
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-506-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

This patch cleans up code about lu_tgt_descs, so that it's cleaner
to add MDT object QoS allocation support:
* rename struct ost_pool to lu_tgt_pool.
* put struct lu_qos, lmv_desc/lov_desc and lu_tgt_pool into struct
  lu_tgt_descs because it's more natural to manage these data there
  and fewer arguments are needed to pass around in related functions.
* remove lu_tgt_descs.ltd_tgtnr, use
  lu_tgt_descs.ltd_lov_desc.ld_tgt_count instead, because they are
  duplicate.
* other cleanups.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12624
Lustre-commit: 45222b2ef279 ("LU-12624 obdclass: lu_tgt_descs cleanup")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35824
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h     |  81 +++---
 fs/lustre/include/obd.h           |   7 +-
 fs/lustre/lmv/lmv_fld.c           |   6 +-
 fs/lustre/lmv/lmv_internal.h      |   2 +-
 fs/lustre/lmv/lmv_obd.c           | 118 ++++-----
 fs/lustre/lmv/lproc_lmv.c         |  19 +-
 fs/lustre/lov/lov_internal.h      |  14 +-
 fs/lustre/lov/lov_pool.c          |  10 +-
 fs/lustre/obdclass/Makefile       |   2 +-
 fs/lustre/obdclass/lu_qos.c       | 512 --------------------------------------
 fs/lustre/obdclass/lu_tgt_descs.c | 509 ++++++++++++++++++++++++++++++++++++-
 11 files changed, 618 insertions(+), 662 deletions(-)
 delete mode 100644 fs/lustre/obdclass/lu_qos.c

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index eaf20ea..e92f12f 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1322,14 +1322,14 @@ struct lu_kmem_descr {
 extern u32 lu_context_tags_default;
 extern u32 lu_session_tags_default;
 
-/* Generic subset of OSTs */
-struct ost_pool {
+/* Generic subset of tgts */
+struct lu_tgt_pool {
 	u32		   *op_array;	/* array of index of
 					 * lov_obd->lov_tgts
 					 */
-	unsigned int	    op_count;	/* number of OSTs in the array */
-	unsigned int	    op_size;	/* allocated size of lp_array */
-	struct rw_semaphore op_rw_sem;	/* to protect ost_pool use */
+	unsigned int	    op_count;	/* number of tgts in the array */
+	unsigned int	    op_size;	/* allocated size of op_array */
+	struct rw_semaphore op_rw_sem;	/* to protect lu_tgt_pool use */
 };
 
 /* round-robin QoS data for LOD/LMV */
@@ -1338,7 +1338,7 @@ struct lu_qos_rr {
 	u32			 lqr_start_idx;	/* start index of new inode */
 	u32			 lqr_offset_idx;/* aliasing for start_idx */
 	int			 lqr_start_count;/* reseed counter */
-	struct ost_pool		 lqr_pool;	/* round-robin optimized list */
+	struct lu_tgt_pool	 lqr_pool;	/* round-robin optimized list */
 	unsigned long		 lqr_dirty:1;	/* recalc round-robin list */
 };
 
@@ -1401,13 +1401,30 @@ struct lu_tgt_desc_idx {
 	struct lu_tgt_desc *ldi_tgt[TGT_PTRS_PER_BLOCK];
 };
 
+/* QoS data for LOD/LMV */
+struct lu_qos {
+	struct list_head	 lq_svr_list;	 /* lu_svr_qos list */
+	struct rw_semaphore	 lq_rw_sem;
+	u32			 lq_active_svr_count;
+	unsigned int		 lq_prio_free;	 /* priority for free space */
+	unsigned int		 lq_threshold_rr;/* priority for rr */
+	struct lu_qos_rr	 lq_rr;		 /* round robin qos data */
+	unsigned long		 lq_dirty:1,	 /* recalc qos data */
+				 lq_same_space:1,/* the servers all have approx.
+						  * the same space avail
+						  */
+				 lq_reset:1;	 /* zero current penalties */
+};
+
 struct lu_tgt_descs {
+	union {
+		struct lov_desc		ltd_lov_desc;
+		struct lmv_desc		ltd_lmv_desc;
+	};
 	/* list of known TGTs */
 	struct lu_tgt_desc_idx	*ltd_tgt_idx[TGT_PTRS];
 	/* Size of the lu_tgts array, granted to be a power of 2 */
 	u32			ltd_tgts_size;
-	/* number of registered TGTs */
-	u32			ltd_tgtnr;
 	/* bitmap of TGTs available */
 	unsigned long		*ltd_tgt_bitmap;
 	/* TGTs scheduled to be deleted */
@@ -1418,43 +1435,31 @@ struct lu_tgt_descs {
 	struct mutex		ltd_mutex;
 	/* read/write semaphore used for array relocation */
 	struct rw_semaphore	ltd_rw_sem;
+	/* QoS */
+	struct lu_qos		ltd_qos;
+	/* all tgts in a packed array */
+	struct lu_tgt_pool	ltd_tgt_pool;
+	/* true if tgt is MDT */
+	bool			ltd_is_mdt;
 };
 
 #define LTD_TGT(ltd, index)						\
-	((ltd)->ltd_tgt_idx[(index) / TGT_PTRS_PER_BLOCK]		\
-				->ldi_tgt[(index) % TGT_PTRS_PER_BLOCK])
+	 (ltd)->ltd_tgt_idx[(index) / TGT_PTRS_PER_BLOCK]		\
+			->ldi_tgt[(index) % TGT_PTRS_PER_BLOCK]
 
-/* QoS data for LOD/LMV */
-struct lu_qos {
-	struct list_head	 lq_svr_list;	/* lu_svr_qos list */
-	struct rw_semaphore	 lq_rw_sem;
-	u32			 lq_active_svr_count;
-	unsigned int		 lq_prio_free;   /* priority for free space */
-	unsigned int		 lq_threshold_rr;/* priority for rr */
-	struct lu_qos_rr	 lq_rr;          /* round robin qos data */
-	unsigned long		 lq_dirty:1,     /* recalc qos data */
-				 lq_same_space:1,/* the servers all have approx.
-						  * the same space avail
-						  */
-				 lq_reset:1;     /* zero current penalties */
-};
-
-void lu_qos_rr_init(struct lu_qos_rr *lqr);
-int lqos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
-int lqos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
-bool lqos_is_usable(struct lu_qos *qos, u32 active_tgt_nr);
-int lqos_calc_penalties(struct lu_qos *qos, struct lu_tgt_descs *ltd,
-			u32 active_tgt_nr, u32 maxage, bool is_mdt);
-void lqos_calc_weight(struct lu_tgt_desc *tgt);
-int lqos_recalc_weight(struct lu_qos *qos, struct lu_tgt_descs *ltd,
-		       struct lu_tgt_desc *tgt, u32 active_tgt_nr,
-		       u64 *total_wt);
 u64 lu_prandom_u64_max(u64 ep_ro);
+void lu_qos_rr_init(struct lu_qos_rr *lqr);
+int lu_qos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
+void lu_tgt_qos_weight_calc(struct lu_tgt_desc *tgt);
 
-int lu_tgt_descs_init(struct lu_tgt_descs *ltd);
+int lu_tgt_descs_init(struct lu_tgt_descs *ltd, bool is_mdt);
 void lu_tgt_descs_fini(struct lu_tgt_descs *ltd);
-int lu_tgt_descs_add(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt);
-void lu_tgt_descs_del(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt);
+int ltd_add_tgt(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt);
+void ltd_del_tgt(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt);
+bool ltd_qos_is_usable(struct lu_tgt_descs *ltd);
+int ltd_qos_penalties_calc(struct lu_tgt_descs *ltd);
+int ltd_qos_update(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt,
+		   u64 *total_wt);
 
 static inline struct lu_tgt_desc *ltd_first_tgt(struct lu_tgt_descs *ltd)
 {
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 41431f9..4ba70c7 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -394,7 +394,7 @@ struct lov_md_tgt_desc {
 struct lov_obd {
 	struct lov_desc		desc;
 	struct lov_tgt_desc   **lov_tgts;	/* sparse array */
-	struct ost_pool		lov_packed;	/* all OSTs in a packed array */
+	struct lu_tgt_pool	lov_packed;	/* all OSTs in a packed array */
 	struct mutex		lov_lock;
 	struct obd_connect_data lov_ocd;
 	atomic_t		lov_refcount;
@@ -422,7 +422,6 @@ struct lov_obd {
 struct lmv_obd {
 	struct lu_client_fld	lmv_fld;
 	spinlock_t		lmv_lock;
-	struct lmv_desc		desc;
 
 	int			connected;
 	int			max_easize;
@@ -435,10 +434,12 @@ struct lmv_obd {
 	struct kobject		*lmv_tgts_kobj;
 	void			*lmv_cache;
 
-	struct lu_qos		lmv_qos;
 	u32			lmv_qos_rr_index;
 };
 
+#define lmv_mdt_count	lmv_mdt_descs.ltd_lmv_desc.ld_tgt_count
+#define lmv_qos		lmv_mdt_descs.ltd_qos
+
 struct niobuf_local {
 	u64			lnb_file_offset;
 	u32			lnb_page_offset;
diff --git a/fs/lustre/lmv/lmv_fld.c b/fs/lustre/lmv/lmv_fld.c
index ef2c866..ea1ef72 100644
--- a/fs/lustre/lmv/lmv_fld.c
+++ b/fs/lustre/lmv/lmv_fld.c
@@ -75,11 +75,11 @@ int lmv_fld_lookup(struct lmv_obd *lmv, const struct lu_fid *fid, u32 *mds)
 	CDEBUG(D_INODE, "FLD lookup got mds #%x for fid=" DFID "\n",
 	       *mds, PFID(fid));
 
-	if (*mds >= lmv->desc.ld_tgt_count) {
+	if (*mds >= lmv->lmv_mdt_descs.ltd_tgts_size) {
 		rc = -EINVAL;
 		CERROR("%s: FLD lookup got invalid mds #%x (max: %x) for fid=" DFID ": rc = %d\n",
-		       obd->obd_name, *mds, lmv->desc.ld_tgt_count, PFID(fid),
-		       rc);
+		       obd->obd_name, *mds, lmv->lmv_mdt_descs.ltd_tgts_size,
+		       PFID(fid), rc);
 	}
 	return rc;
 }
diff --git a/fs/lustre/lmv/lmv_internal.h b/fs/lustre/lmv/lmv_internal.h
index d95fa3f..70d86676 100644
--- a/fs/lustre/lmv/lmv_internal.h
+++ b/fs/lustre/lmv/lmv_internal.h
@@ -122,7 +122,7 @@ struct lu_tgt_desc *lmv_next_connected_tgt(struct lmv_obd *lmv,
 	u32 mdt_idx;
 	int rc;
 
-	if (lmv->desc.ld_tgt_count < 2)
+	if (lmv->lmv_mdt_count < 2)
 		return 0;
 
 	rc = lmv_fld_lookup(lmv, fid, &mdt_idx);
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 2959b18..84be905 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -64,7 +64,8 @@ void lmv_activate_target(struct lmv_obd *lmv, struct lmv_tgt_desc *tgt,
 		return;
 
 	tgt->ltd_active = activate;
-	lmv->desc.ld_active_tgt_count += (activate ? 1 : -1);
+	lmv->lmv_mdt_descs.ltd_lmv_desc.ld_active_tgt_count +=
+		(activate ? 1 : -1);
 	tgt->ltd_exp->exp_obd->obd_inactive = !activate;
 }
 
@@ -330,11 +331,11 @@ static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 
 	tgt->ltd_active = 1;
 	tgt->ltd_exp = mdc_exp;
-	lmv->desc.ld_active_tgt_count++;
+	lmv->lmv_mdt_descs.ltd_lmv_desc.ld_active_tgt_count++;
 
 	md_init_ea_size(tgt->ltd_exp, lmv->max_easize, lmv->max_def_easize);
 
-	rc = lqos_add_tgt(&lmv->lmv_qos, tgt);
+	rc = lu_qos_add_tgt(&lmv->lmv_qos, tgt);
 	if (rc) {
 		obd_disconnect(mdc_exp);
 		return rc;
@@ -357,8 +358,7 @@ static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 static void lmv_del_target(struct lmv_obd *lmv, struct lu_tgt_desc *tgt)
 {
 	LASSERT(tgt);
-	lqos_del_tgt(&lmv->lmv_qos, tgt);
-	lu_tgt_descs_del(&lmv->lmv_mdt_descs, tgt);
+	ltd_del_tgt(&lmv->lmv_mdt_descs, tgt);
 	kfree(tgt);
 }
 
@@ -369,7 +369,6 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 	struct obd_device *mdc_obd;
 	struct lmv_tgt_desc *tgt;
 	struct lu_tgt_descs *ltd = &lmv->lmv_mdt_descs;
-	int orig_tgt_count = 0;
 	int rc = 0;
 
 	CDEBUG(D_CONFIG, "Target uuid: %s. index %d\n", uuidp->uuid, index);
@@ -392,11 +391,7 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 	tgt->ltd_active = 0;
 
 	mutex_lock(&ltd->ltd_mutex);
-	rc = lu_tgt_descs_add(ltd, tgt);
-	if (!rc && index >= lmv->desc.ld_tgt_count) {
-		orig_tgt_count = lmv->desc.ld_tgt_count;
-		lmv->desc.ld_tgt_count = index + 1;
-	}
+	rc = ltd_add_tgt(ltd, tgt);
 	mutex_unlock(&ltd->ltd_mutex);
 
 	if (rc)
@@ -407,14 +402,10 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		return rc;
 
 	rc = lmv_connect_mdc(obd, tgt);
-	if (rc) {
-		mutex_lock(&ltd->ltd_mutex);
-		lmv->desc.ld_tgt_count = orig_tgt_count;
-		memset(tgt, 0, sizeof(*tgt));
-		mutex_unlock(&ltd->ltd_mutex);
-	} else {
+	if (!rc) {
 		int easize = sizeof(struct lmv_stripe_md) +
-			     lmv->desc.ld_tgt_count * sizeof(struct lu_fid);
+			     lmv->lmv_mdt_count * sizeof(struct lu_fid);
+
 		lmv_init_ea_size(obd->obd_self_export, easize, 0);
 	}
 
@@ -441,7 +432,7 @@ static int lmv_check_connect(struct obd_device *obd)
 		goto unlock;
 	}
 
-	if (lmv->desc.ld_tgt_count == 0) {
+	if (!lmv->lmv_mdt_count) {
 		CERROR("%s: no targets configured: rc = -EINVAL\n",
 		       obd->obd_name);
 		rc = -EINVAL;
@@ -465,7 +456,7 @@ static int lmv_check_connect(struct obd_device *obd)
 	}
 
 	lmv->connected = 1;
-	easize = lmv_mds_md_size(lmv->desc.ld_tgt_count, LMV_MAGIC);
+	easize = lmv_mds_md_size(lmv->lmv_mdt_count, LMV_MAGIC);
 	lmv_init_ea_size(obd->obd_self_export, easize, 0);
 unlock:
 	mutex_unlock(&lmv->lmv_mdt_descs.ltd_mutex);
@@ -478,7 +469,7 @@ static int lmv_check_connect(struct obd_device *obd)
 		if (!tgt->ltd_exp)
 			continue;
 
-		--lmv->desc.ld_active_tgt_count;
+		--lmv->lmv_mdt_descs.ltd_lmv_desc.ld_active_tgt_count;
 		obd_disconnect(tgt->ltd_exp);
 	}
 
@@ -810,7 +801,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 	struct lmv_obd *lmv = &obddev->u.lmv;
 	struct lu_tgt_desc *tgt = NULL;
 	int set = 0;
-	u32 count = lmv->desc.ld_tgt_count;
+	u32 count = lmv->lmv_mdt_count;
 	int rc = 0;
 
 	if (count == 0)
@@ -824,7 +815,8 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		u32 index;
 
 		memcpy(&index, data->ioc_inlbuf2, sizeof(u32));
-		if (index >= count)
+
+		if (index >= lmv->lmv_mdt_descs.ltd_tgts_size)
 			return -ENODEV;
 
 		tgt = lmv_tgt(lmv, index);
@@ -857,12 +849,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		struct obd_quotactl *oqctl;
 
 		if (qctl->qc_valid == QC_MDTIDX) {
-			if (count <= qctl->qc_idx)
-				return -EINVAL;
-
 			tgt = lmv_tgt(lmv, qctl->qc_idx);
-			if (!tgt || !tgt->ltd_exp)
-				return -EINVAL;
 		} else if (qctl->qc_valid == QC_UUID) {
 			lmv_foreach_tgt(lmv, tgt) {
 				if (!obd_uuid_equals(&tgt->ltd_uuid,
@@ -878,10 +865,9 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 			return -EINVAL;
 		}
 
-		if (tgt->ltd_index >= count)
-			return -EAGAIN;
+		if (!tgt || !tgt->ltd_exp)
+			return -EINVAL;
 
-		LASSERT(tgt && tgt->ltd_exp);
 		oqctl = kzalloc(sizeof(*oqctl), GFP_KERNEL);
 		if (!oqctl)
 			return -ENOMEM;
@@ -1069,7 +1055,7 @@ static u32 lmv_placement_policy(struct obd_device *obd,
 	struct lmv_user_md *lum;
 	u32 mdt;
 
-	if (lmv->desc.ld_tgt_count == 1)
+	if (lmv->lmv_mdt_count == 1)
 		return 0;
 
 	lum = op_data->op_data;
@@ -1182,27 +1168,17 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		return -EINVAL;
 	}
 
-	obd_str2uuid(&lmv->desc.ld_uuid, desc->ld_uuid.uuid);
-	lmv->desc.ld_tgt_count = 0;
-	lmv->desc.ld_active_tgt_count = 0;
-	lmv->desc.ld_qos_maxage = LMV_DESC_QOS_MAXAGE_DEFAULT;
+	obd_str2uuid(&lmv->lmv_mdt_descs.ltd_lmv_desc.ld_uuid,
+		     desc->ld_uuid.uuid);
+	lmv->lmv_mdt_descs.ltd_lmv_desc.ld_tgt_count = 0;
+	lmv->lmv_mdt_descs.ltd_lmv_desc.ld_active_tgt_count = 0;
+	lmv->lmv_mdt_descs.ltd_lmv_desc.ld_qos_maxage =
+		LMV_DESC_QOS_MAXAGE_DEFAULT;
 	lmv->max_def_easize = 0;
 	lmv->max_easize = 0;
 
 	spin_lock_init(&lmv->lmv_lock);
 
-	/* Set up allocation policy (QoS and RR) */
-	INIT_LIST_HEAD(&lmv->lmv_qos.lq_svr_list);
-	init_rwsem(&lmv->lmv_qos.lq_rw_sem);
-	lmv->lmv_qos.lq_dirty = 1;
-	lmv->lmv_qos.lq_reset = 1;
-	/* Default priority is toward free space balance */
-	lmv->lmv_qos.lq_prio_free = 232;
-	/* Default threshold for rr (roughly 17%) */
-	lmv->lmv_qos.lq_threshold_rr = 43;
-
-	lu_qos_rr_init(&lmv->lmv_qos.lq_rr);
-
 	/*
 	 * initialize rr_index to lower 32bit of netid, so that client
 	 * can distribute subdirs evenly from the beginning.
@@ -1224,7 +1200,7 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	if (rc)
 		CERROR("Can't init FLD, err %d\n", rc);
 
-	rc = lu_tgt_descs_init(&lmv->lmv_mdt_descs);
+	rc = lu_tgt_descs_init(&lmv->lmv_mdt_descs, true);
 	if (rc)
 		CWARN("%s: error initialize target table: rc = %d\n",
 		      obd->obd_name, rc);
@@ -1292,7 +1268,7 @@ static int lmv_select_statfs_mdt(struct lmv_obd *lmv, u32 flags)
 	if (flags & OBD_STATFS_FOR_MDT0)
 		return 0;
 
-	if (lmv->lmv_statfs_start || lmv->desc.ld_tgt_count == 1)
+	if (lmv->lmv_statfs_start || lmv->lmv_mdt_count == 1)
 		return lmv->lmv_statfs_start;
 
 	/* choose initial MDT for this client */
@@ -1306,8 +1282,8 @@ static int lmv_select_statfs_mdt(struct lmv_obd *lmv, u32 flags)
 			/* We dont need a full 64-bit modulus, just enough
 			 * to distribute the requests across MDTs evenly.
 			 */
-			lmv->lmv_statfs_start =
-				(u32)lnet_id.nid % lmv->desc.ld_tgt_count;
+			lmv->lmv_statfs_start = (u32)lnet_id.nid %
+						lmv->lmv_mdt_count;
 			break;
 		}
 	}
@@ -1333,8 +1309,8 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 	/* distribute statfs among MDTs */
 	idx = lmv_select_statfs_mdt(lmv, flags);
 
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++, idx++) {
-		idx = idx % lmv->desc.ld_tgt_count;
+	for (i = 0; i < lmv->lmv_mdt_descs.ltd_tgts_size; i++, idx++) {
+		idx = idx % lmv->lmv_mdt_descs.ltd_tgts_size;
 		tgt = lmv_tgt(lmv, idx);
 		if (!tgt || !tgt->ltd_exp)
 			continue;
@@ -1410,7 +1386,7 @@ int lmv_statfs_check_update(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 	int rc;
 
 	if (ktime_get_seconds() - tgt->ltd_statfs_age <
-	    obd->u.lmv.desc.ld_qos_maxage)
+	    obd->u.lmv.lmv_mdt_descs.ltd_lmv_desc.ld_qos_maxage)
 		return 0;
 
 	rc = obd_statfs_async(tgt->ltd_exp, &oinfo, 0, NULL);
@@ -1526,19 +1502,17 @@ static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
 	u64 rand;
 	int rc;
 
-	if (!lqos_is_usable(&lmv->lmv_qos, lmv->desc.ld_active_tgt_count))
+	if (!ltd_qos_is_usable(&lmv->lmv_mdt_descs))
 		return ERR_PTR(-EAGAIN);
 
 	down_write(&lmv->lmv_qos.lq_rw_sem);
 
-	if (!lqos_is_usable(&lmv->lmv_qos, lmv->desc.ld_active_tgt_count)) {
+	if (!ltd_qos_is_usable(&lmv->lmv_mdt_descs)) {
 		tgt = ERR_PTR(-EAGAIN);
 		goto unlock;
 	}
 
-	rc = lqos_calc_penalties(&lmv->lmv_qos, &lmv->lmv_mdt_descs,
-				 lmv->desc.ld_active_tgt_count,
-				 lmv->desc.ld_qos_maxage, true);
+	rc = ltd_qos_penalties_calc(&lmv->lmv_mdt_descs);
 	if (rc) {
 		tgt = ERR_PTR(rc);
 		goto unlock;
@@ -1550,7 +1524,7 @@ static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
 			continue;
 
 		tgt->ltd_qos.ltq_usable = 1;
-		lqos_calc_weight(tgt);
+		lu_tgt_qos_weight_calc(tgt);
 		total_weight += tgt->ltd_qos.ltq_weight;
 	}
 
@@ -1565,9 +1539,7 @@ static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
 			continue;
 
 		*mdt = tgt->ltd_index;
-		lqos_recalc_weight(&lmv->lmv_qos, &lmv->lmv_mdt_descs, tgt,
-				   lmv->desc.ld_active_tgt_count,
-				   &total_weight);
+		ltd_qos_update(&lmv->lmv_mdt_descs, tgt, &total_weight);
 		rc = 0;
 		goto unlock;
 	}
@@ -1588,14 +1560,16 @@ static struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt)
 	int index;
 
 	spin_lock(&lmv->lmv_qos.lq_rr.lqr_alloc);
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		index = (i + lmv->lmv_qos_rr_index) % lmv->desc.ld_tgt_count;
+	for (i = 0; i < lmv->lmv_mdt_descs.ltd_tgts_size; i++) {
+		index = (i + lmv->lmv_qos_rr_index) %
+			lmv->lmv_mdt_descs.ltd_tgts_size;
 		tgt = lmv_tgt(lmv, index);
 		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
 			continue;
 
 		*mdt = tgt->ltd_index;
-		lmv->lmv_qos_rr_index = (*mdt + 1) % lmv->desc.ld_tgt_count;
+		lmv->lmv_qos_rr_index = (*mdt + 1) %
+					lmv->lmv_mdt_descs.ltd_tgts_size;
 		spin_unlock(&lmv->lmv_qos.lq_rr.lqr_alloc);
 
 		return tgt;
@@ -1791,7 +1765,7 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	struct lmv_tgt_desc *tgt;
 	int rc;
 
-	if (!lmv->desc.ld_active_tgt_count)
+	if (!lmv->lmv_mdt_descs.ltd_lmv_desc.ld_active_tgt_count)
 		return -EIO;
 
 	if (lmv_dir_bad_hash(op_data->op_mea1))
@@ -2903,7 +2877,7 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 			exp->exp_connect_data = *(struct obd_connect_data *)val;
 		return rc;
 	} else if (KEY_IS(KEY_TGT_COUNT)) {
-		*((int *)val) = lmv->desc.ld_tgt_count;
+		*((int *)val) = lmv->lmv_mdt_descs.ltd_tgts_size;
 		return 0;
 	}
 
@@ -2917,7 +2891,7 @@ static int lmv_rmfid(struct obd_export *exp, struct fid_array *fa,
 	struct obd_device *obddev = class_exp2obd(exp);
 	struct ptlrpc_request_set *set = _set;
 	struct lmv_obd *lmv = &obddev->u.lmv;
-	int tgt_count = lmv->desc.ld_tgt_count;
+	int tgt_count = lmv->lmv_mdt_count;
 	struct lu_tgt_desc *tgt;
 	struct fid_array *fat, **fas = NULL;
 	int i, rc, **rcs = NULL;
@@ -3303,8 +3277,8 @@ static enum ldlm_mode lmv_lock_match(struct obd_export *exp, u64 flags,
 	 * since this can be easily found, and only try others if that fails.
 	 */
 	for (i = 0, index = lmv_fid2tgt_index(lmv, fid);
-	     i < lmv->desc.ld_tgt_count;
-	     i++, index = (index + 1) % lmv->desc.ld_tgt_count) {
+	     i < lmv->lmv_mdt_descs.ltd_tgts_size;
+	     i++, index = (index + 1) % lmv->lmv_mdt_descs.ltd_tgts_size) {
 		if (index < 0) {
 			CDEBUG(D_HA, "%s: " DFID " is inaccessible: rc = %d\n",
 			       obd->obd_name, PFID(fid), index);
diff --git a/fs/lustre/lmv/lproc_lmv.c b/fs/lustre/lmv/lproc_lmv.c
index af670f8..79e27b3 100644
--- a/fs/lustre/lmv/lproc_lmv.c
+++ b/fs/lustre/lmv/lproc_lmv.c
@@ -45,10 +45,8 @@ static ssize_t numobd_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	struct lmv_desc *desc;
 
-	desc = &dev->u.lmv.desc;
-	return sprintf(buf, "%u\n", desc->ld_tgt_count);
+	return sprintf(buf, "%u\n", dev->u.lmv.lmv_mdt_count);
 }
 LUSTRE_RO_ATTR(numobd);
 
@@ -57,10 +55,9 @@ static ssize_t activeobd_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	struct lmv_desc *desc;
 
-	desc = &dev->u.lmv.desc;
-	return sprintf(buf, "%u\n", desc->ld_active_tgt_count);
+	return sprintf(buf, "%u\n",
+		     dev->u.lmv.lmv_mdt_descs.ltd_lmv_desc.ld_active_tgt_count);
 }
 LUSTRE_RO_ATTR(activeobd);
 
@@ -69,10 +66,9 @@ static ssize_t desc_uuid_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	struct lmv_desc *desc;
 
-	desc = &dev->u.lmv.desc;
-	return sprintf(buf, "%s\n", desc->ld_uuid.uuid);
+	return sprintf(buf, "%s\n",
+		       dev->u.lmv.lmv_mdt_descs.ltd_lmv_desc.ld_uuid.uuid);
 }
 LUSTRE_RO_ATTR(desc_uuid);
 
@@ -83,7 +79,8 @@ static ssize_t qos_maxage_show(struct kobject *kobj,
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 
-	return sprintf(buf, "%u\n", dev->u.lmv.desc.ld_qos_maxage);
+	return sprintf(buf, "%u\n",
+		       dev->u.lmv.lmv_mdt_descs.ltd_lmv_desc.ld_qos_maxage);
 }
 
 static ssize_t qos_maxage_store(struct kobject *kobj,
@@ -100,7 +97,7 @@ static ssize_t qos_maxage_store(struct kobject *kobj,
 	if (rc)
 		return rc;
 
-	dev->u.lmv.desc.ld_qos_maxage = val;
+	dev->u.lmv.lmv_mdt_descs.ltd_lmv_desc.ld_qos_maxage = val;
 
 	return count;
 }
diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
index d235abe..3725d1e 100644
--- a/fs/lustre/lov/lov_internal.h
+++ b/fs/lustre/lov/lov_internal.h
@@ -221,7 +221,7 @@ struct lsm_operations {
 
 struct pool_desc {
 	char			 pool_name[LOV_MAXPOOLNAME + 1];
-	struct ost_pool		 pool_obds;
+	struct lu_tgt_pool	 pool_obds;
 	atomic_t		 pool_refcount;
 	struct rhash_head	 pool_hash;		/* access by poolname */
 	union {
@@ -322,12 +322,12 @@ struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, void *buf,
 
 #define LOV_MDC_TGT_MAX 256
 
-/* ost_pool methods */
-int lov_ost_pool_init(struct ost_pool *op, unsigned int count);
-int lov_ost_pool_extend(struct ost_pool *op, unsigned int min_count);
-int lov_ost_pool_add(struct ost_pool *op, u32 idx, unsigned int min_count);
-int lov_ost_pool_remove(struct ost_pool *op, u32 idx);
-int lov_ost_pool_free(struct ost_pool *op);
+/* lu_tgt_pool methods */
+int lov_ost_pool_init(struct lu_tgt_pool *op, unsigned int count);
+int lov_ost_pool_extend(struct lu_tgt_pool *op, unsigned int min_count);
+int lov_ost_pool_add(struct lu_tgt_pool *op, u32 idx, unsigned int min_count);
+int lov_ost_pool_remove(struct lu_tgt_pool *op, u32 idx);
+int lov_ost_pool_free(struct lu_tgt_pool *op);
 
 /* high level pool methods */
 int lov_pool_new(struct obd_device *obd, char *poolname);
diff --git a/fs/lustre/lov/lov_pool.c b/fs/lustre/lov/lov_pool.c
index a0552fb..9ab81cb 100644
--- a/fs/lustre/lov/lov_pool.c
+++ b/fs/lustre/lov/lov_pool.c
@@ -231,7 +231,7 @@ static int pool_proc_open(struct inode *inode, struct file *file)
 };
 
 #define LOV_POOL_INIT_COUNT 2
-int lov_ost_pool_init(struct ost_pool *op, unsigned int count)
+int lov_ost_pool_init(struct lu_tgt_pool *op, unsigned int count)
 {
 	if (count == 0)
 		count = LOV_POOL_INIT_COUNT;
@@ -249,7 +249,7 @@ int lov_ost_pool_init(struct ost_pool *op, unsigned int count)
 }
 
 /* Caller must hold write op_rwlock */
-int lov_ost_pool_extend(struct ost_pool *op, unsigned int min_count)
+int lov_ost_pool_extend(struct lu_tgt_pool *op, unsigned int min_count)
 {
 	int new_count;
 	u32 *new;
@@ -273,7 +273,7 @@ int lov_ost_pool_extend(struct ost_pool *op, unsigned int min_count)
 	return 0;
 }
 
-int lov_ost_pool_add(struct ost_pool *op, u32 idx, unsigned int min_count)
+int lov_ost_pool_add(struct lu_tgt_pool *op, u32 idx, unsigned int min_count)
 {
 	int rc = 0, i;
 
@@ -298,7 +298,7 @@ int lov_ost_pool_add(struct ost_pool *op, u32 idx, unsigned int min_count)
 	return rc;
 }
 
-int lov_ost_pool_remove(struct ost_pool *op, u32 idx)
+int lov_ost_pool_remove(struct lu_tgt_pool *op, u32 idx)
 {
 	int i;
 
@@ -318,7 +318,7 @@ int lov_ost_pool_remove(struct ost_pool *op, u32 idx)
 	return -EINVAL;
 }
 
-int lov_ost_pool_free(struct ost_pool *op)
+int lov_ost_pool_free(struct lu_tgt_pool *op)
 {
 	if (op->op_size == 0)
 		return 0;
diff --git a/fs/lustre/obdclass/Makefile b/fs/lustre/obdclass/Makefile
index 5718a6d..9693a5e 100644
--- a/fs/lustre/obdclass/Makefile
+++ b/fs/lustre/obdclass/Makefile
@@ -8,4 +8,4 @@ obdclass-y := llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
 	      obdo.o obd_config.o obd_mount.o lu_object.o lu_ref.o \
 	      cl_object.o cl_page.o cl_lock.o cl_io.o kernelcomm.o \
-	      jobid.o integrity.o obd_cksum.o lu_qos.o lu_tgt_descs.o
+	      jobid.o integrity.o obd_cksum.o lu_tgt_descs.o
diff --git a/fs/lustre/obdclass/lu_qos.c b/fs/lustre/obdclass/lu_qos.c
deleted file mode 100644
index 13ab4a7..0000000
--- a/fs/lustre/obdclass/lu_qos.c
+++ /dev/null
@@ -1,512 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- *
- * lustre/obdclass/lu_qos.c
- *
- * Lustre QoS.
- * These are the only exported functions, they provide some generic
- * infrastructure for object allocation QoS
- *
- */
-
-#define DEBUG_SUBSYSTEM S_CLASS
-
-#include <linux/module.h>
-#include <linux/list.h>
-#include <linux/random.h>
-#include <obd_class.h>
-#include <obd_support.h>
-#include <lustre_disk.h>
-#include <lustre_fid.h>
-#include <lu_object.h>
-
-void lu_qos_rr_init(struct lu_qos_rr *lqr)
-{
-	spin_lock_init(&lqr->lqr_alloc);
-	lqr->lqr_dirty = 1;
-}
-EXPORT_SYMBOL(lu_qos_rr_init);
-
-/**
- * Add a new target to Quality of Service (QoS) target table.
- *
- * Add a new MDT/OST target to the structure representing an OSS. Resort the
- * list of known MDSs/OSSs by the number of MDTs/OSTs attached to each MDS/OSS.
- * The MDS/OSS list is protected internally and no external locking is required.
- *
- * @qos		lu_qos data
- * @ltd		target description
- *
- * Return:	0 on success
- *		-ENOMEM	on error
- */
-int lqos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd)
-{
-	struct lu_svr_qos *svr = NULL;
-	struct lu_svr_qos *tempsvr;
-	struct obd_export *exp = ltd->ltd_exp;
-	int found = 0;
-	u32 id = 0;
-	int rc = 0;
-
-	down_write(&qos->lq_rw_sem);
-	/*
-	 * a bit hacky approach to learn NID of corresponding connection
-	 * but there is no official API to access information like this
-	 * with OSD API.
-	 */
-	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
-		if (obd_uuid_equals(&svr->lsq_uuid,
-				    &exp->exp_connection->c_remote_uuid)) {
-			found++;
-			break;
-		}
-		if (svr->lsq_id > id)
-			id = svr->lsq_id;
-	}
-
-	if (!found) {
-		svr = kmalloc(sizeof(*svr), GFP_NOFS);
-		if (!svr) {
-			rc = -ENOMEM;
-			goto out;
-		}
-		memcpy(&svr->lsq_uuid, &exp->exp_connection->c_remote_uuid,
-		       sizeof(svr->lsq_uuid));
-		++id;
-		svr->lsq_id = id;
-	} else {
-		/* Assume we have to move this one */
-		list_del(&svr->lsq_svr_list);
-	}
-
-	svr->lsq_tgt_count++;
-	ltd->ltd_qos.ltq_svr = svr;
-
-	CDEBUG(D_OTHER, "add tgt %s to server %s (%d targets)\n",
-	       obd_uuid2str(&ltd->ltd_uuid), obd_uuid2str(&svr->lsq_uuid),
-	       svr->lsq_tgt_count);
-
-	/*
-	 * Add sorted by # of tgts.  Find the first entry that we're
-	 * bigger than...
-	 */
-	list_for_each_entry(tempsvr, &qos->lq_svr_list, lsq_svr_list) {
-		if (svr->lsq_tgt_count > tempsvr->lsq_tgt_count)
-			break;
-	}
-	/*
-	 * ...and add before it.  If we're the first or smallest, tempsvr
-	 * points to the list head, and we add to the end.
-	 */
-	list_add_tail(&svr->lsq_svr_list, &tempsvr->lsq_svr_list);
-
-	qos->lq_dirty = 1;
-	qos->lq_rr.lqr_dirty = 1;
-
-out:
-	up_write(&qos->lq_rw_sem);
-	return rc;
-}
-EXPORT_SYMBOL(lqos_add_tgt);
-
-/**
- * Remove MDT/OST target from QoS table.
- *
- * Removes given MDT/OST target from QoS table and releases related
- * MDS/OSS structure if no target remain on the MDS/OSS.
- *
- * @qos		lu_qos data
- * @ltd		target description
- *
- * Return:	0 on success
- *		-ENOENT	if no server was found
- */
-int lqos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd)
-{
-	struct lu_svr_qos *svr;
-	int rc = 0;
-
-	down_write(&qos->lq_rw_sem);
-	svr = ltd->ltd_qos.ltq_svr;
-	if (!svr) {
-		rc = -ENOENT;
-		goto out;
-	}
-
-	svr->lsq_tgt_count--;
-	if (svr->lsq_tgt_count == 0) {
-		CDEBUG(D_OTHER, "removing server %s\n",
-		       obd_uuid2str(&svr->lsq_uuid));
-		list_del(&svr->lsq_svr_list);
-		ltd->ltd_qos.ltq_svr = NULL;
-		kfree(svr);
-	}
-
-	qos->lq_dirty = 1;
-	qos->lq_rr.lqr_dirty = 1;
-out:
-	up_write(&qos->lq_rw_sem);
-	return rc;
-}
-EXPORT_SYMBOL(lqos_del_tgt);
-
-/**
- * lu_prandom_u64_max - returns a pseudo-random u64 number in interval
- * [0, ep_ro)
- *
- * #ep_ro	right open interval endpoint
- *
- * Return:	a pseudo-random 64-bit number that is in interval [0, ep_ro).
- */
-u64 lu_prandom_u64_max(u64 ep_ro)
-{
-	u64 rand = 0;
-
-	if (ep_ro) {
-#if BITS_PER_LONG == 32
-		/*
-		 * If ep_ro > 32-bit, first generate the high
-		 * 32 bits of the random number, then add in the low
-		 * 32 bits (truncated to the upper limit, if needed)
-		 */
-		if (ep_ro > 0xffffffffULL)
-			rand = prandom_u32_max((u32)(ep_ro >> 32)) << 32;
-
-		if (rand == (ep_ro & 0xffffffff00000000ULL))
-			rand |= prandom_u32_max((u32)ep_ro);
-		else
-			rand |= prandom_u32();
-#else
-		rand = ((u64)prandom_u32() << 32 | prandom_u32()) % ep_ro;
-#endif
-	}
-
-	return rand;
-}
-EXPORT_SYMBOL(lu_prandom_u64_max);
-
-static inline u64 tgt_statfs_bavail(struct lu_tgt_desc *tgt)
-{
-	struct obd_statfs *statfs = &tgt->ltd_statfs;
-
-	return statfs->os_bavail * statfs->os_bsize;
-}
-
-static inline u64 tgt_statfs_iavail(struct lu_tgt_desc *tgt)
-{
-	return tgt->ltd_statfs.os_ffree;
-}
-
-/**
- * Calculate penalties per-tgt and per-server
- *
- * Re-calculate penalties when the configuration changes, active targets
- * change and after statfs refresh (all these are reflected by lq_dirty flag).
- * On every tgt and server: decay the penalty by half for every 8x the update
- * interval that the device has been idle. That gives lots of time for the
- * statfs information to be updated (which the penalty is only a proxy for),
- * and avoids penalizing server/tgt under light load.
- * See lqos_calc_weight() for how penalties are factored into the weight.
- *
- * @qos			lu_qos
- * @ltd			lu_tgt_descs
- * @active_tgt_nr	active tgt number
- * @ maxage		qos max age
- * @is_mdt		MDT will count inode usage
- *
- * Return:		0 on success
- *			-EAGAIN the number of tgt isn't enough or all
- *			tgt spaces are almost the same
- */
-int lqos_calc_penalties(struct lu_qos *qos, struct lu_tgt_descs *ltd,
-			u32 active_tgt_nr, u32 maxage, bool is_mdt)
-{
-	struct lu_tgt_desc *tgt;
-	struct lu_svr_qos *svr;
-	u64 ba_max, ba_min, ba;
-	u64 ia_max, ia_min, ia = 1;
-	u32 num_active;
-	int prio_wide;
-	time64_t now, age;
-	int rc;
-
-	if (!qos->lq_dirty) {
-		rc = 0;
-		goto out;
-	}
-
-	num_active = active_tgt_nr - 1;
-	if (num_active < 1) {
-		rc = -EAGAIN;
-		goto out;
-	}
-
-	/* find bavail on each server */
-	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
-		svr->lsq_bavail = 0;
-		/* if inode is not counted, set to 1 to ignore */
-		svr->lsq_iavail = is_mdt ? 0 : 1;
-	}
-	qos->lq_active_svr_count = 0;
-
-	/*
-	 * How badly user wants to select targets "widely" (not recently chosen
-	 * and not on recent MDS's).  As opposed to "freely" (free space avail.)
-	 * 0-256
-	 */
-	prio_wide = 256 - qos->lq_prio_free;
-
-	ba_min = (u64)(-1);
-	ba_max = 0;
-	ia_min = (u64)(-1);
-	ia_max = 0;
-	now = ktime_get_real_seconds();
-
-	/* Calculate server penalty per object */
-	ltd_foreach_tgt(ltd, tgt) {
-		if (!tgt->ltd_active)
-			continue;
-
-		/* when inode is counted, bavail >> 16 to avoid overflow */
-		ba = tgt_statfs_bavail(tgt);
-		if (is_mdt)
-			ba >>= 16;
-		else
-			ba >>= 8;
-		if (!ba)
-			continue;
-
-		ba_min = min(ba, ba_min);
-		ba_max = max(ba, ba_max);
-
-		/* Count the number of usable servers */
-		if (tgt->ltd_qos.ltq_svr->lsq_bavail == 0)
-			qos->lq_active_svr_count++;
-		tgt->ltd_qos.ltq_svr->lsq_bavail += ba;
-
-		if (is_mdt) {
-			/* iavail >> 8 to avoid overflow */
-			ia = tgt_statfs_iavail(tgt) >> 8;
-			if (!ia)
-				continue;
-
-			ia_min = min(ia, ia_min);
-			ia_max = max(ia, ia_max);
-
-			tgt->ltd_qos.ltq_svr->lsq_iavail += ia;
-		}
-
-		/*
-		 * per-tgt penalty is
-		 * prio * bavail * iavail / (num_tgt - 1) / 2
-		 */
-		tgt->ltd_qos.ltq_penalty_per_obj = prio_wide * ba * ia >> 8;
-		do_div(tgt->ltd_qos.ltq_penalty_per_obj, num_active);
-		tgt->ltd_qos.ltq_penalty_per_obj >>= 1;
-
-		age = (now - tgt->ltd_qos.ltq_used) >> 3;
-		if (qos->lq_reset || age > 32 * maxage)
-			tgt->ltd_qos.ltq_penalty = 0;
-		else if (age > maxage)
-			/* Decay tgt penalty. */
-			tgt->ltd_qos.ltq_penalty >>= (age / maxage);
-	}
-
-	num_active = qos->lq_active_svr_count - 1;
-	if (num_active < 1) {
-		/*
-		 * If there's only 1 server, we can't penalize it, so instead
-		 * we have to double the tgt penalty
-		 */
-		num_active = 1;
-		ltd_foreach_tgt(ltd, tgt) {
-			if (!tgt->ltd_active)
-				continue;
-
-			tgt->ltd_qos.ltq_penalty_per_obj <<= 1;
-		}
-	}
-
-	/*
-	 * Per-server penalty is
-	 * prio * bavail * iavail / server_tgts / (num_svr - 1) / 2
-	 */
-	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
-		ba = svr->lsq_bavail;
-		ia = svr->lsq_iavail;
-		svr->lsq_penalty_per_obj = prio_wide * ba  * ia >> 8;
-		do_div(ba, svr->lsq_tgt_count * num_active);
-		svr->lsq_penalty_per_obj >>= 1;
-
-		age = (now - svr->lsq_used) >> 3;
-		if (qos->lq_reset || age > 32 * maxage)
-			svr->lsq_penalty = 0;
-		else if (age > maxage)
-			/* Decay server penalty. */
-			svr->lsq_penalty >>= age / maxage;
-	}
-
-	qos->lq_dirty = 0;
-	qos->lq_reset = 0;
-
-	/*
-	 * If each tgt has almost same free space, do rr allocation for better
-	 * creation performance
-	 */
-	qos->lq_same_space = 0;
-	if ((ba_max * (256 - qos->lq_threshold_rr)) >> 8 < ba_min &&
-	    (ia_max * (256 - qos->lq_threshold_rr)) >> 8 < ia_min) {
-		qos->lq_same_space = 1;
-		/* Reset weights for the next time we enter qos mode */
-		qos->lq_reset = 1;
-	}
-	rc = 0;
-
-out:
-	if (!rc && qos->lq_same_space)
-		return -EAGAIN;
-
-	return rc;
-}
-EXPORT_SYMBOL(lqos_calc_penalties);
-
-bool lqos_is_usable(struct lu_qos *qos, u32 active_tgt_nr)
-{
-	if (!qos->lq_dirty && qos->lq_same_space)
-		return false;
-
-	if (active_tgt_nr < 2)
-		return false;
-
-	return true;
-}
-EXPORT_SYMBOL(lqos_is_usable);
-
-/**
- * Calculate weight for a given tgt.
- *
- * The final tgt weight is bavail >> 16 * iavail >> 8 minus the tgt and server
- * penalties.  See lqos_calc_ppts() for how penalties are calculated.
- *
- * @tgt		target descriptor
- */
-void lqos_calc_weight(struct lu_tgt_desc *tgt)
-{
-	struct lu_tgt_qos *ltq = &tgt->ltd_qos;
-	u64 temp, temp2;
-
-	temp = (tgt_statfs_bavail(tgt) >> 16) * (tgt_statfs_iavail(tgt) >> 8);
-	temp2 = ltq->ltq_penalty + ltq->ltq_svr->lsq_penalty;
-	if (temp < temp2)
-		ltq->ltq_weight = 0;
-	else
-		ltq->ltq_weight = temp - temp2;
-}
-EXPORT_SYMBOL(lqos_calc_weight);
-
-/**
- * Re-calculate weights.
- *
- * The function is called when some target was used for a new object. In
- * this case we should re-calculate all the weights to keep new allocations
- * balanced well.
- *
- * @qos			lu_qos
- * @ltd			lu_tgt_descs
- * @tgt			target where a new object was placed
- * @active_tgt_nr	active tgt number
- * @total_wt		new total weight for the pool
- *
- * Return:		0
- */
-int lqos_recalc_weight(struct lu_qos *qos, struct lu_tgt_descs *ltd,
-		       struct lu_tgt_desc *tgt, u32 active_tgt_nr,
-		       u64 *total_wt)
-{
-	struct lu_tgt_qos *ltq;
-	struct lu_svr_qos *svr;
-
-	ltq = &tgt->ltd_qos;
-	LASSERT(ltq);
-
-	/* Don't allocate on this device anymore, until the next alloc_qos */
-	ltq->ltq_usable = 0;
-
-	svr = ltq->ltq_svr;
-
-	/*
-	 * Decay old penalty by half (we're adding max penalty, and don't
-	 * want it to run away.)
-	 */
-	ltq->ltq_penalty >>= 1;
-	svr->lsq_penalty >>= 1;
-
-	/* mark the server and tgt as recently used */
-	ltq->ltq_used = svr->lsq_used = ktime_get_real_seconds();
-
-	/* Set max penalties for this tgt and server */
-	ltq->ltq_penalty += ltq->ltq_penalty_per_obj * active_tgt_nr;
-	svr->lsq_penalty += svr->lsq_penalty_per_obj * active_tgt_nr;
-
-	/* Decrease all MDS penalties */
-	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
-		if (svr->lsq_penalty < svr->lsq_penalty_per_obj)
-			svr->lsq_penalty = 0;
-		else
-			svr->lsq_penalty -= svr->lsq_penalty_per_obj;
-	}
-
-	*total_wt = 0;
-	/* Decrease all tgt penalties */
-	ltd_foreach_tgt(ltd, tgt) {
-		if (!tgt->ltd_active)
-			continue;
-
-		if (ltq->ltq_penalty < ltq->ltq_penalty_per_obj)
-			ltq->ltq_penalty = 0;
-		else
-			ltq->ltq_penalty -= ltq->ltq_penalty_per_obj;
-
-		lqos_calc_weight(tgt);
-
-		/* Recalc the total weight of usable osts */
-		if (ltq->ltq_usable)
-			*total_wt += ltq->ltq_weight;
-
-		CDEBUG(D_OTHER,
-		       "recalc tgt %d usable=%d avail=%llu tgtppo=%llu tgtp=%llu svrppo=%llu svrp=%llu wt=%llu\n",
-		       tgt->ltd_index, ltq->ltq_usable,
-		       tgt_statfs_bavail(tgt) >> 10,
-		       ltq->ltq_penalty_per_obj >> 10,
-		       ltq->ltq_penalty >> 10,
-		       ltq->ltq_svr->lsq_penalty_per_obj >> 10,
-		       ltq->ltq_svr->lsq_penalty >> 10,
-		       ltq->ltq_weight >> 10);
-	}
-
-	return 0;
-}
-EXPORT_SYMBOL(lqos_recalc_weight);
diff --git a/fs/lustre/obdclass/lu_tgt_descs.c b/fs/lustre/obdclass/lu_tgt_descs.c
index 04d6acc..60c50a0 100644
--- a/fs/lustre/obdclass/lu_tgt_descs.c
+++ b/fs/lustre/obdclass/lu_tgt_descs.c
@@ -35,6 +35,7 @@
 
 #include <linux/module.h>
 #include <linux/list.h>
+#include <linux/random.h>
 #include <obd_class.h>
 #include <obd_support.h>
 #include <lustre_disk.h>
@@ -42,17 +43,221 @@
 #include <lu_object.h>
 
 /**
+ * lu_prandom_u64_max - returns a pseudo-random u64 number in interval
+ * [0, ep_ro)
+ *
+ * @ep_ro	right open interval endpoint
+ *
+ * Return:	a pseudo-random 64-bit number that is in interval [0, ep_ro).
+ */
+u64 lu_prandom_u64_max(u64 ep_ro)
+{
+	u64 rand = 0;
+
+	if (ep_ro) {
+#if BITS_PER_LONG == 32
+		/*
+		 * If ep_ro > 32-bit, first generate the high
+		 * 32 bits of the random number, then add in the low
+		 * 32 bits (truncated to the upper limit, if needed)
+		 */
+		if (ep_ro > 0xffffffffULL)
+			rand = prandom_u32_max((u32)(ep_ro >> 32)) << 32;
+
+		if (rand == (ep_ro & 0xffffffff00000000ULL))
+			rand |= prandom_u32_max((u32)ep_ro);
+		else
+			rand |= prandom_u32();
+#else
+		rand = ((u64)prandom_u32() << 32 | prandom_u32()) % ep_ro;
+#endif
+	}
+
+	return rand;
+}
+EXPORT_SYMBOL(lu_prandom_u64_max);
+
+void lu_qos_rr_init(struct lu_qos_rr *lqr)
+{
+	spin_lock_init(&lqr->lqr_alloc);
+	lqr->lqr_dirty = 1;
+}
+EXPORT_SYMBOL(lu_qos_rr_init);
+
+/**
+ * Add a new target to Quality of Service (QoS) target table.
+ *
+ * Add a new MDT/OST target to the structure representing an OSS. Resort the
+ * list of known MDSs/OSSs by the number of MDTs/OSTs attached to each MDS/OSS.
+ * The MDS/OSS list is protected internally and no external locking is required.
+ *
+ * @qos		lu_qos data
+ * @tgt		target description
+ *
+ * Return:	0 on success
+ *		-ENOMEM on error
+ */
+int lu_qos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *tgt)
+{
+	struct lu_svr_qos *svr = NULL;
+	struct lu_svr_qos *tempsvr;
+	struct obd_export *exp = tgt->ltd_exp;
+	int found = 0;
+	u32 id = 0;
+	int rc = 0;
+
+	/* tgt not connected, this function will be called again later */
+	if (!exp)
+		return 0;
+
+	down_write(&qos->lq_rw_sem);
+	/*
+	 * a bit hacky approach to learn NID of corresponding connection
+	 * but there is no official API to access information like this
+	 * with OSD API.
+	 */
+	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
+		if (obd_uuid_equals(&svr->lsq_uuid,
+				    &exp->exp_connection->c_remote_uuid)) {
+			found++;
+			break;
+		}
+		if (svr->lsq_id > id)
+			id = svr->lsq_id;
+	}
+
+	if (!found) {
+		svr = kzalloc(sizeof(*svr), GFP_NOFS);
+		if (!svr) {
+			rc = -ENOMEM;
+			goto out;
+		}
+		memcpy(&svr->lsq_uuid, &exp->exp_connection->c_remote_uuid,
+		       sizeof(svr->lsq_uuid));
+		++id;
+		svr->lsq_id = id;
+	} else {
+		/* Assume we have to move this one */
+		list_del(&svr->lsq_svr_list);
+	}
+
+	svr->lsq_tgt_count++;
+	tgt->ltd_qos.ltq_svr = svr;
+
+	CDEBUG(D_OTHER, "add tgt %s to server %s (%d targets)\n",
+	       obd_uuid2str(&tgt->ltd_uuid), obd_uuid2str(&svr->lsq_uuid),
+	       svr->lsq_tgt_count);
+
+	/*
+	 * Add sorted by # of tgts.  Find the first entry that we're
+	 * bigger than...
+	 */
+	list_for_each_entry(tempsvr, &qos->lq_svr_list, lsq_svr_list) {
+		if (svr->lsq_tgt_count > tempsvr->lsq_tgt_count)
+			break;
+	}
+	/*
+	 * ...and add before it.  If we're the first or smallest, tempsvr
+	 * points to the list head, and we add to the end.
+	 */
+	list_add_tail(&svr->lsq_svr_list, &tempsvr->lsq_svr_list);
+
+	qos->lq_dirty = 1;
+	qos->lq_rr.lqr_dirty = 1;
+
+out:
+	up_write(&qos->lq_rw_sem);
+	return rc;
+}
+EXPORT_SYMBOL(lu_qos_add_tgt);
+
+/**
+ * Remove MDT/OST target from QoS table.
+ *
+ * Removes given MDT/OST target from QoS table and releases related
+ * MDS/OSS structure if no target remain on the MDS/OSS.
+ *
+ * @qos		lu_qos data
+ * @ltd		target description
+ *
+ * Return:	0 on success
+ *		-ENOENT if no server was found
+ */
+static int lu_qos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd)
+{
+	struct lu_svr_qos *svr;
+	int rc = 0;
+
+	down_write(&qos->lq_rw_sem);
+	svr = ltd->ltd_qos.ltq_svr;
+	if (!svr) {
+		rc = -ENOENT;
+		goto out;
+	}
+
+	svr->lsq_tgt_count--;
+	if (svr->lsq_tgt_count == 0) {
+		CDEBUG(D_OTHER, "removing server %s\n",
+		       obd_uuid2str(&svr->lsq_uuid));
+		list_del(&svr->lsq_svr_list);
+		ltd->ltd_qos.ltq_svr = NULL;
+		kfree(svr);
+	}
+
+	qos->lq_dirty = 1;
+	qos->lq_rr.lqr_dirty = 1;
+out:
+	up_write(&qos->lq_rw_sem);
+	return rc;
+}
+
+static inline u64 tgt_statfs_bavail(struct lu_tgt_desc *tgt)
+{
+	struct obd_statfs *statfs = &tgt->ltd_statfs;
+
+	return statfs->os_bavail * statfs->os_bsize;
+}
+
+static inline u64 tgt_statfs_iavail(struct lu_tgt_desc *tgt)
+{
+	return tgt->ltd_statfs.os_ffree;
+}
+
+/**
+ * Calculate weight for a given tgt.
+ *
+ * The final tgt weight is bavail >> 16 * iavail >> 8 minus the tgt and server
+ * penalties.  See ltd_qos_penalties_calc() for how penalties are calculated.
+ *
+ * @tgt		target descriptor
+ */
+void lu_tgt_qos_weight_calc(struct lu_tgt_desc *tgt)
+{
+	struct lu_tgt_qos *ltq = &tgt->ltd_qos;
+	u64 temp, temp2;
+
+	temp = (tgt_statfs_bavail(tgt) >> 16) * (tgt_statfs_iavail(tgt) >> 8);
+	temp2 = ltq->ltq_penalty + ltq->ltq_svr->lsq_penalty;
+	if (temp < temp2)
+		ltq->ltq_weight = 0;
+	else
+		ltq->ltq_weight = temp - temp2;
+}
+EXPORT_SYMBOL(lu_tgt_qos_weight_calc);
+
+/**
  * Allocate and initialize target table.
  *
  * A helper function to initialize the target table and allocate
  * a bitmap of the available targets.
  *
  * @ltd		target's table to initialize
+ * @is_mdt	target table for MDTs
  *
  * Return:	0 on success
  *		negated errno on error
  **/
-int lu_tgt_descs_init(struct lu_tgt_descs *ltd)
+int lu_tgt_descs_init(struct lu_tgt_descs *ltd, bool is_mdt)
 {
 	mutex_init(&ltd->ltd_mutex);
 	init_rwsem(&ltd->ltd_rw_sem);
@@ -66,11 +271,22 @@ int lu_tgt_descs_init(struct lu_tgt_descs *ltd)
 		return -ENOMEM;
 
 	ltd->ltd_tgts_size  = BITS_PER_LONG;
-	ltd->ltd_tgtnr      = 0;
-
 	ltd->ltd_death_row = 0;
 	ltd->ltd_refcount  = 0;
 
+	/* Set up allocation policy (QoS and RR) */
+	INIT_LIST_HEAD(&ltd->ltd_qos.lq_svr_list);
+	init_rwsem(&ltd->ltd_qos.lq_rw_sem);
+	ltd->ltd_qos.lq_dirty = 1;
+	ltd->ltd_qos.lq_reset = 1;
+	/* Default priority is toward free space balance */
+	ltd->ltd_qos.lq_prio_free = 232;
+	/* Default threshold for rr (roughly 17%) */
+	ltd->ltd_qos.lq_threshold_rr = 43;
+	ltd->ltd_is_mdt = is_mdt;
+
+	lu_qos_rr_init(&ltd->ltd_qos.lq_rr);
+
 	return 0;
 }
 EXPORT_SYMBOL(lu_tgt_descs_init);
@@ -147,7 +363,7 @@ static int lu_tgt_descs_resize(struct lu_tgt_descs *ltd, u32 newsize)
  *		-ENOMEM if reallocation failed
  *		-EEXIST if target existed
  */
-int lu_tgt_descs_add(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt)
+int ltd_add_tgt(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt)
 {
 	u32 index = tgt->ltd_index;
 	int rc;
@@ -174,19 +390,294 @@ int lu_tgt_descs_add(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt)
 
 	LTD_TGT(ltd, tgt->ltd_index) = tgt;
 	set_bit(tgt->ltd_index, ltd->ltd_tgt_bitmap);
-	ltd->ltd_tgtnr++;
+
+	ltd->ltd_lov_desc.ld_tgt_count++;
+	if (tgt->ltd_active)
+		ltd->ltd_lov_desc.ld_active_tgt_count++;
 
 	return 0;
 }
-EXPORT_SYMBOL(lu_tgt_descs_add);
+EXPORT_SYMBOL(ltd_add_tgt);
 
 /**
  * Delete target from target table
  */
-void lu_tgt_descs_del(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt)
+void ltd_del_tgt(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt)
 {
+	lu_qos_del_tgt(&ltd->ltd_qos, tgt);
 	LTD_TGT(ltd, tgt->ltd_index) = NULL;
 	clear_bit(tgt->ltd_index, ltd->ltd_tgt_bitmap);
-	ltd->ltd_tgtnr--;
+	ltd->ltd_lov_desc.ld_tgt_count--;
+	if (tgt->ltd_active)
+		ltd->ltd_lov_desc.ld_active_tgt_count--;
+}
+EXPORT_SYMBOL(ltd_del_tgt);
+
+/**
+ * Whether QoS data is up-to-date and QoS can be applied.
+ */
+bool ltd_qos_is_usable(struct lu_tgt_descs *ltd)
+{
+	if (!ltd->ltd_qos.lq_dirty && ltd->ltd_qos.lq_same_space)
+		return false;
+
+	if (ltd->ltd_lov_desc.ld_active_tgt_count < 2)
+		return false;
+
+	return true;
+}
+EXPORT_SYMBOL(ltd_qos_is_usable);
+
+/**
+ * Calculate penalties per-tgt and per-server
+ *
+ * Re-calculate penalties when the configuration changes, active targets
+ * change and after statfs refresh (all these are reflected by lq_dirty flag).
+ * On every tgt and server: decay the penalty by half for every 8x the update
+ * interval that the device has been idle. That gives lots of time for the
+ * statfs information to be updated (which the penalty is only a proxy for),
+ * and avoids penalizing server/tgt under light load.
+ * See lu_qos_tgt_weight_calc() for how penalties are factored into the weight.
+ *
+ * \param[in] ltd		lu_tgt_descs
+ *
+ * \retval 0		on success
+ * \retval -EAGAIN	the number of tgt isn't enough or all tgt spaces are
+ *			almost the same
+ */
+int ltd_qos_penalties_calc(struct lu_tgt_descs *ltd)
+{
+	struct lu_qos *qos = &ltd->ltd_qos;
+	struct lov_desc *desc = &ltd->ltd_lov_desc;
+	struct lu_tgt_desc *tgt;
+	struct lu_svr_qos *svr;
+	u64 ba_max, ba_min, ba;
+	u64 ia_max, ia_min, ia = 1;
+	u32 num_active;
+	int prio_wide;
+	time64_t now, age;
+	int rc;
+
+	if (!qos->lq_dirty) {
+		rc = 0;
+		goto out;
+	}
+
+	num_active = desc->ld_active_tgt_count - 1;
+	if (num_active < 1) {
+		rc = -EAGAIN;
+		goto out;
+	}
+
+	/* find bavail on each server */
+	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
+		svr->lsq_bavail = 0;
+		/* if inode is not counted, set to 1 to ignore */
+		svr->lsq_iavail = ltd->ltd_is_mdt ? 0 : 1;
+	}
+	qos->lq_active_svr_count = 0;
+
+	/*
+	 * How badly user wants to select targets "widely" (not recently chosen
+	 * and not on recent MDS's).  As opposed to "freely" (free space avail.)
+	 * 0-256
+	 */
+	prio_wide = 256 - qos->lq_prio_free;
+
+	ba_min = (u64)(-1);
+	ba_max = 0;
+	ia_min = (u64)(-1);
+	ia_max = 0;
+	now = ktime_get_real_seconds();
+
+	/* Calculate server penalty per object */
+	ltd_foreach_tgt(ltd, tgt) {
+		if (!tgt->ltd_active)
+			continue;
+
+		/* when inode is counted, bavail >> 16 to avoid overflow */
+		ba = tgt_statfs_bavail(tgt);
+		if (ltd->ltd_is_mdt)
+			ba >>= 16;
+		else
+			ba >>= 8;
+		if (!ba)
+			continue;
+
+		ba_min = min(ba, ba_min);
+		ba_max = max(ba, ba_max);
+
+		/* Count the number of usable servers */
+		if (tgt->ltd_qos.ltq_svr->lsq_bavail == 0)
+			qos->lq_active_svr_count++;
+		tgt->ltd_qos.ltq_svr->lsq_bavail += ba;
+
+		if (ltd->ltd_is_mdt) {
+			/* iavail >> 8 to avoid overflow */
+			ia = tgt_statfs_iavail(tgt) >> 8;
+			if (!ia)
+				continue;
+
+			ia_min = min(ia, ia_min);
+			ia_max = max(ia, ia_max);
+
+			tgt->ltd_qos.ltq_svr->lsq_iavail += ia;
+		}
+
+		/*
+		 * per-tgt penalty is
+		 * prio * bavail * iavail / (num_tgt - 1) / 2
+		 */
+		tgt->ltd_qos.ltq_penalty_per_obj = prio_wide * ba * ia;
+		do_div(tgt->ltd_qos.ltq_penalty_per_obj, num_active);
+		tgt->ltd_qos.ltq_penalty_per_obj >>= 1;
+
+		age = (now - tgt->ltd_qos.ltq_used) >> 3;
+		if (qos->lq_reset || age > 32 * desc->ld_qos_maxage)
+			tgt->ltd_qos.ltq_penalty = 0;
+		else if (age > desc->ld_qos_maxage)
+			/* Decay tgt penalty. */
+			tgt->ltd_qos.ltq_penalty >>= age / desc->ld_qos_maxage;
+	}
+
+	num_active = qos->lq_active_svr_count - 1;
+	if (num_active < 1) {
+		/*
+		 * If there's only 1 server, we can't penalize it, so instead
+		 * we have to double the tgt penalty
+		 */
+		num_active = 1;
+		ltd_foreach_tgt(ltd, tgt) {
+			if (!tgt->ltd_active)
+				continue;
+
+			tgt->ltd_qos.ltq_penalty_per_obj <<= 1;
+		}
+	}
+
+	/*
+	 * Per-server penalty is
+	 * prio * bavail * iavail / server_tgts / (num_svr - 1) / 2
+	 */
+	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
+		ba = svr->lsq_bavail;
+		ia = svr->lsq_iavail;
+		svr->lsq_penalty_per_obj = prio_wide * ba  * ia;
+		do_div(ba, svr->lsq_tgt_count * num_active);
+		svr->lsq_penalty_per_obj >>= 1;
+
+		age = (now - svr->lsq_used) >> 3;
+		if (qos->lq_reset || age > 32 * desc->ld_qos_maxage)
+			svr->lsq_penalty = 0;
+		else if (age > desc->ld_qos_maxage)
+			/* Decay server penalty. */
+			svr->lsq_penalty >>= age / desc->ld_qos_maxage;
+	}
+
+	qos->lq_dirty = 0;
+	qos->lq_reset = 0;
+
+	/*
+	 * If each tgt has almost same free space, do rr allocation for better
+	 * creation performance
+	 */
+	qos->lq_same_space = 0;
+	if ((ba_max * (256 - qos->lq_threshold_rr)) >> 8 < ba_min &&
+	    (ia_max * (256 - qos->lq_threshold_rr)) >> 8 < ia_min) {
+		qos->lq_same_space = 1;
+		/* Reset weights for the next time we enter qos mode */
+		qos->lq_reset = 1;
+	}
+	rc = 0;
+
+out:
+	if (!rc && qos->lq_same_space)
+		return -EAGAIN;
+
+	return rc;
+}
+EXPORT_SYMBOL(ltd_qos_penalties_calc);
+
+/**
+ * Re-calculate penalties and weights of all tgts.
+ *
+ * The function is called when some target was used for a new object. In
+ * this case we should re-calculate all the weights to keep new allocations
+ * balanced well.
+ *
+ * \param[in] ltd		lu_tgt_descs
+ * \param[in] tgt		recently used tgt
+ * \param[out] total_wt		new total weight for the pool
+ *
+ * \retval		0
+ */
+int ltd_qos_update(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt,
+		   u64 *total_wt)
+{
+	struct lu_qos *qos = &ltd->ltd_qos;
+	struct lu_tgt_qos *ltq;
+	struct lu_svr_qos *svr;
+
+	ltq = &tgt->ltd_qos;
+	LASSERT(ltq);
+
+	/* Don't allocate on this device anymore, until the next alloc_qos */
+	ltq->ltq_usable = 0;
+
+	svr = ltq->ltq_svr;
+
+	/*
+	 * Decay old penalty by half (we're adding max penalty, and don't
+	 * want it to run away.)
+	 */
+	ltq->ltq_penalty >>= 1;
+	svr->lsq_penalty >>= 1;
+
+	/* mark the server and tgt as recently used */
+	ltq->ltq_used = svr->lsq_used = ktime_get_real_seconds();
+
+	/* Set max penalties for this tgt and server */
+	ltq->ltq_penalty += ltq->ltq_penalty_per_obj *
+			    ltd->ltd_lov_desc.ld_active_tgt_count;
+	svr->lsq_penalty += svr->lsq_penalty_per_obj *
+			    ltd->ltd_lov_desc.ld_active_tgt_count;
+
+	/* Decrease all MDS penalties */
+	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
+		if (svr->lsq_penalty < svr->lsq_penalty_per_obj)
+			svr->lsq_penalty = 0;
+		else
+			svr->lsq_penalty -= svr->lsq_penalty_per_obj;
+	}
+
+	*total_wt = 0;
+	/* Decrease all tgt penalties */
+	ltd_foreach_tgt(ltd, tgt) {
+		if (!tgt->ltd_active)
+			continue;
+
+		if (ltq->ltq_penalty < ltq->ltq_penalty_per_obj)
+			ltq->ltq_penalty = 0;
+		else
+			ltq->ltq_penalty -= ltq->ltq_penalty_per_obj;
+
+		lu_tgt_qos_weight_calc(tgt);
+
+		/* Recalc the total weight of usable osts */
+		if (ltq->ltq_usable)
+			*total_wt += ltq->ltq_weight;
+
+		CDEBUG(D_OTHER,
+		       "recalc tgt %d usable=%d avail=%llu tgtppo=%llu tgtp=%llu svrppo=%llu svrp=%llu wt=%llu\n",
+		       tgt->ltd_index, ltq->ltq_usable,
+		       tgt_statfs_bavail(tgt) >> 10,
+		       ltq->ltq_penalty_per_obj >> 10,
+		       ltq->ltq_penalty >> 10,
+		       ltq->ltq_svr->lsq_penalty_per_obj >> 10,
+		       ltq->ltq_svr->lsq_penalty >> 10,
+		       ltq->ltq_weight >> 10);
+	}
+
+	return 0;
 }
-EXPORT_SYMBOL(lu_tgt_descs_del);
+EXPORT_SYMBOL(ltd_qos_update);
-- 
1.8.3.1
