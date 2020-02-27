From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:53 -0500
Subject: [lustre-devel] [PATCH 485/622] lustre: lmv: use lu_tgt_descs to
 manage tgts
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-486-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Like LOD, use lu_tgt_descs to manage tgts, so that they can
share tgt management code.

TODO: use the same tgt management code for LOV/LFSCK.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11213
Lustre-commit: 59fc1218fccf ("LU-11213 lmv: use lu_tgt_descs to manage tgts")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35218
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradaed.org>
---
 fs/lustre/include/lu_object.h     |  68 +++++
 fs/lustre/include/obd.h           |   5 +-
 fs/lustre/lmv/lmv_intent.c        |  10 +-
 fs/lustre/lmv/lmv_internal.h      |  86 +++---
 fs/lustre/lmv/lmv_obd.c           | 540 +++++++++++++++-----------------------
 fs/lustre/lmv/lmv_qos.c           |  57 ++--
 fs/lustre/lmv/lproc_lmv.c         |  20 +-
 fs/lustre/obdclass/Makefile       |   2 +-
 fs/lustre/obdclass/lu_tgt_descs.c | 192 ++++++++++++++
 9 files changed, 572 insertions(+), 408 deletions(-)
 create mode 100644 fs/lustre/obdclass/lu_tgt_descs.c

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index aed0d4b..c30c06d 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1392,6 +1392,38 @@ struct lu_tgt_desc {
 			ltd_connecting:1;  /* target is connecting */
 };
 
+/* number of pointers at 1st level */
+#define TGT_PTRS		(PAGE_SIZE / sizeof(void *))
+/* number of pointers at 2nd level */
+#define TGT_PTRS_PER_BLOCK	(PAGE_SIZE / sizeof(void *))
+
+struct lu_tgt_desc_idx {
+	struct lu_tgt_desc *ldi_tgt[TGT_PTRS_PER_BLOCK];
+};
+
+struct lu_tgt_descs {
+	/* list of known TGTs */
+	struct lu_tgt_desc_idx	*ltd_tgt_idx[TGT_PTRS];
+	/* Size of the lu_tgts array, granted to be a power of 2 */
+	u32			ltd_tgts_size;
+	/* number of registered TGTs */
+	u32			ltd_tgtnr;
+	/* bitmap of TGTs available */
+	unsigned long		*ltd_tgt_bitmap;
+	/* TGTs scheduled to be deleted */
+	u32			ltd_death_row;
+	/* Table refcount used for delayed deletion */
+	int			ltd_refcount;
+	/* mutex to serialize concurrent updates to the tgt table */
+	struct mutex		ltd_mutex;
+	/* read/write semaphore used for array relocation */
+	struct rw_semaphore	ltd_rw_sem;
+};
+
+#define LTD_TGT(ltd, index)						\
+	((ltd)->ltd_tgt_idx[(index) / TGT_PTRS_PER_BLOCK]		\
+				->ldi_tgt[(index) % TGT_PTRS_PER_BLOCK])
+
 /* QoS data for LOD/LMV */
 struct lu_qos {
 	struct list_head	 lq_svr_list;	/* lu_svr_qos list */
@@ -1412,5 +1444,41 @@ struct lu_qos {
 int lqos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
 u64 lu_prandom_u64_max(u64 ep_ro);
 
+int lu_tgt_descs_init(struct lu_tgt_descs *ltd);
+void lu_tgt_descs_fini(struct lu_tgt_descs *ltd);
+int lu_tgt_descs_add(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt);
+void lu_tgt_descs_del(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt);
+
+static inline struct lu_tgt_desc *ltd_first_tgt(struct lu_tgt_descs *ltd)
+{
+	int index;
+
+	index = find_first_bit(ltd->ltd_tgt_bitmap,
+			       ltd->ltd_tgts_size);
+	return (index < ltd->ltd_tgts_size) ? LTD_TGT(ltd, index) : NULL;
+}
+
+static inline struct lu_tgt_desc *ltd_next_tgt(struct lu_tgt_descs *ltd,
+					       struct lu_tgt_desc *tgt)
+{
+	int index;
+
+	if (!tgt)
+		return NULL;
+
+	index = tgt->ltd_index;
+	LASSERT(index < ltd->ltd_tgts_size);
+	index = find_next_bit(ltd->ltd_tgt_bitmap,
+			      ltd->ltd_tgts_size, index + 1);
+	return (index < ltd->ltd_tgts_size) ? LTD_TGT(ltd, index) : NULL;
+}
+
+#define ltd_foreach_tgt(ltd, tgt) \
+	for (tgt = ltd_first_tgt(ltd); tgt; tgt = ltd_next_tgt(ltd, tgt))
+
+#define ltd_foreach_tgt_safe(ltd, tgt, tmp)				  \
+	for (tgt = ltd_first_tgt(ltd), tmp = ltd_next_tgt(ltd, tgt); tgt; \
+	     tgt = tmp, tmp = ltd_next_tgt(ltd, tgt))
+
 /** @} lu */
 #endif /* __LUSTRE_LU_OBJECT_H */
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index ef37f78..41431f9 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -424,14 +424,13 @@ struct lmv_obd {
 	spinlock_t		lmv_lock;
 	struct lmv_desc		desc;
 
-	struct mutex		lmv_init_mutex;
 	int			connected;
 	int			max_easize;
 	int			max_def_easize;
 	u32			lmv_statfs_start;
 
-	u32			tgts_size; /* size of tgts array */
-	struct lmv_tgt_desc	**tgts;
+	struct lu_tgt_descs     lmv_mdt_descs;
+
 	struct obd_connect_data	conn_data;
 	struct kobject		*lmv_tgts_kobj;
 	void			*lmv_cache;
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index f62cd7c..542b16d 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -83,7 +83,7 @@ static int lmv_intent_remote(struct obd_export *exp, struct lookup_intent *it,
 
 	LASSERT(fid_is_sane(&body->mbo_fid1));
 
-	tgt = lmv_find_target(lmv, &body->mbo_fid1);
+	tgt = lmv_fid2tgt(lmv, &body->mbo_fid1);
 	if (IS_ERR(tgt)) {
 		rc = PTR_ERR(tgt);
 		goto out;
@@ -199,9 +199,9 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 		op_data->op_fid1 = fid;
 		op_data->op_fid2 = fid;
 
-		tgt = lmv_get_target(lmv, lsm->lsm_md_oinfo[i].lmo_mds, NULL);
-		if (IS_ERR(tgt)) {
-			rc = PTR_ERR(tgt);
+		tgt = lmv_tgt(lmv, lsm->lsm_md_oinfo[i].lmo_mds);
+		if (!tgt) {
+			rc = -ENODEV;
 			goto cleanup;
 		}
 
@@ -349,7 +349,7 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 		if (lmv_dir_striped(op_data->op_mea1))
 			op_data->op_fid1 = op_data->op_fid2;
 
-		tgt = lmv_find_target(lmv, &op_data->op_fid2);
+		tgt = lmv_fid2tgt(lmv, &op_data->op_fid2);
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
 
diff --git a/fs/lustre/lmv/lmv_internal.h b/fs/lustre/lmv/lmv_internal.h
index c673656..e0c3ba0 100644
--- a/fs/lustre/lmv/lmv_internal.h
+++ b/fs/lustre/lmv/lmv_internal.h
@@ -70,57 +70,81 @@ static inline struct obd_device *lmv2obd_dev(struct lmv_obd *lmv)
 	return container_of_safe(lmv, struct obd_device, u.lmv);
 }
 
-static inline struct lmv_tgt_desc *
-lmv_get_target(struct lmv_obd *lmv, u32 mdt_idx, int *index)
+static inline struct lu_tgt_desc *
+lmv_tgt(struct lmv_obd *lmv, u32 index)
 {
-	int i;
+	return index < lmv->lmv_mdt_descs.ltd_tgts_size ?
+		LTD_TGT(&lmv->lmv_mdt_descs, index) : NULL;
+}
 
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		if (!lmv->tgts[i])
-			continue;
+static inline bool
+lmv_mdt0_inited(struct lmv_obd *lmv)
+{
+	return lmv->lmv_mdt_descs.ltd_tgt_bitmap &&
+	       test_bit(0, lmv->lmv_mdt_descs.ltd_tgt_bitmap);
+}
 
-		if (lmv->tgts[i]->ltd_index == mdt_idx) {
-			if (index)
-				*index = i;
-			return lmv->tgts[i];
-		}
-	}
+#define lmv_foreach_tgt(lmv, tgt) ltd_foreach_tgt(&(lmv)->lmv_mdt_descs, tgt)
+
+#define lmv_foreach_tgt_safe(lmv, tgt, tmp) \
+	ltd_foreach_tgt_safe(&(lmv)->lmv_mdt_descs, tgt, tmp)
+
+static inline
+struct lu_tgt_desc *lmv_first_connected_tgt(struct lmv_obd *lmv)
+{
+	struct lu_tgt_desc *tgt;
 
-	return ERR_PTR(-ENODEV);
+	tgt = ltd_first_tgt(&lmv->lmv_mdt_descs);
+	while (tgt && !tgt->ltd_exp)
+		tgt = ltd_next_tgt(&lmv->lmv_mdt_descs, tgt);
+
+	return tgt;
 }
 
-static inline int
-lmv_find_target_index(struct lmv_obd *lmv, const struct lu_fid *fid)
+static inline
+struct lu_tgt_desc *lmv_next_connected_tgt(struct lmv_obd *lmv,
+					   struct lu_tgt_desc *tgt)
 {
-	struct lmv_tgt_desc *ltd;
-	u32 mdt_idx = 0;
-	int index = 0;
+	do {
+		tgt = ltd_next_tgt(&lmv->lmv_mdt_descs, tgt);
+	} while (tgt && !tgt->ltd_exp);
 
-	if (lmv->desc.ld_tgt_count > 1) {
-		int rc;
+	return tgt;
+}
 
-		rc = lmv_fld_lookup(lmv, fid, &mdt_idx);
-		if (rc < 0)
-			return rc;
-	}
+#define lmv_foreach_connected_tgt(lmv, tgt) \
+	for (tgt = lmv_first_connected_tgt(lmv); tgt; \
+	     tgt = lmv_next_connected_tgt(lmv, tgt))
 
-	ltd = lmv_get_target(lmv, mdt_idx, &index);
-	if (IS_ERR(ltd))
-		return PTR_ERR(ltd);
+static inline int
+lmv_fid2tgt_index(struct lmv_obd *lmv, const struct lu_fid *fid)
+{
+	u32 mdt_idx;
+	int rc;
+
+	if (lmv->desc.ld_tgt_count < 2)
+		return 0;
 
-	return index;
+	rc = lmv_fld_lookup(lmv, fid, &mdt_idx);
+	if (rc < 0)
+		return rc;
+
+	return mdt_idx;
 }
 
 static inline struct lmv_tgt_desc *
-lmv_find_target(struct lmv_obd *lmv, const struct lu_fid *fid)
+lmv_fid2tgt(struct lmv_obd *lmv, const struct lu_fid *fid)
 {
+	struct lu_tgt_desc *tgt;
 	int index;
 
-	index = lmv_find_target_index(lmv, fid);
+	index = lmv_fid2tgt_index(lmv, fid);
 	if (index < 0)
 		return ERR_PTR(index);
 
-	return lmv->tgts[index];
+	tgt = lmv_tgt(lmv, index);
+
+	return tgt ? tgt : ERR_PTR(-ENODEV);
 }
 
 static inline int lmv_stripe_md_size(int stripe_count)
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 26021bb..8d682b4 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -78,28 +78,24 @@ void lmv_activate_target(struct lmv_obd *lmv, struct lmv_tgt_desc *tgt,
 static int lmv_set_mdc_active(struct lmv_obd *lmv, const struct obd_uuid *uuid,
 			      int activate)
 {
-	struct lmv_tgt_desc *tgt = NULL;
+	struct lu_tgt_desc *tgt = NULL;
 	struct obd_device *obd;
-	u32 i;
 	int rc = 0;
 
 	CDEBUG(D_INFO, "Searching in lmv %p for uuid %s (activate=%d)\n",
 	       lmv, uuid->uuid, activate);
 
 	spin_lock(&lmv->lmv_lock);
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		tgt = lmv->tgts[i];
-		if (!tgt || !tgt->ltd_exp)
-			continue;
-
-		CDEBUG(D_INFO, "Target idx %d is %s conn %#llx\n", i,
-		       tgt->ltd_uuid.uuid, tgt->ltd_exp->exp_handle.h_cookie);
+	lmv_foreach_connected_tgt(lmv, tgt) {
+		CDEBUG(D_INFO, "Target idx %d is %s conn %#llx\n",
+		       tgt->ltd_index, tgt->ltd_uuid.uuid,
+		       tgt->ltd_exp->exp_handle.h_cookie);
 
 		if (obd_uuid_equals(uuid, &tgt->ltd_uuid))
 			break;
 	}
 
-	if (i == lmv->desc.ld_tgt_count) {
+	if (!tgt) {
 		rc = -EINVAL;
 		goto out_lmv_lock;
 	}
@@ -112,7 +108,7 @@ static int lmv_set_mdc_active(struct lmv_obd *lmv, const struct obd_uuid *uuid,
 
 	CDEBUG(D_INFO, "Found OBD %s=%s device %d (%p) type %s at LMV idx %d\n",
 	       obd->obd_name, obd->obd_uuid.uuid, obd->obd_minor, obd,
-	       obd->obd_type->typ_name, i);
+	       obd->obd_type->typ_name, tgt->ltd_index);
 	LASSERT(strcmp(obd->obd_type->typ_name, LUSTRE_MDC_NAME) == 0);
 
 	if (tgt->ltd_active == activate) {
@@ -133,7 +129,7 @@ static int lmv_set_mdc_active(struct lmv_obd *lmv, const struct obd_uuid *uuid,
 static struct obd_uuid *lmv_get_uuid(struct obd_export *exp)
 {
 	struct lmv_obd *lmv = &exp->exp_obd->u.lmv;
-	struct lmv_tgt_desc *tgt = lmv->tgts[0];
+	struct lmv_tgt_desc *tgt = lmv_tgt(lmv, 0);
 
 	return tgt ? obd_get_uuid(tgt->ltd_exp) : NULL;
 }
@@ -235,9 +231,9 @@ static int lmv_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize)
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
-	u32 i;
-	int rc = 0;
+	struct lmv_tgt_desc *tgt;
 	int change = 0;
+	int rc = 0;
 
 	if (lmv->max_easize < easize) {
 		lmv->max_easize = easize;
@@ -254,20 +250,14 @@ static int lmv_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize)
 	if (lmv->connected == 0)
 		return 0;
 
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		struct lmv_tgt_desc *tgt = lmv->tgts[i];
-
-		if (!tgt || !tgt->ltd_exp) {
-			CWARN("%s: NULL export for %d\n", obd->obd_name, i);
-			continue;
-		}
+	lmv_foreach_connected_tgt(lmv, tgt) {
 		if (!tgt->ltd_active)
 			continue;
 
 		rc = md_init_ea_size(tgt->ltd_exp, easize, def_easize);
 		if (rc) {
 			CERROR("%s: obd_init_ea_size() failed on MDT target %d: rc = %d\n",
-			       obd->obd_name, i, rc);
+			       obd->obd_name, tgt->ltd_index, rc);
 			break;
 		}
 	}
@@ -364,15 +354,12 @@ static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 	return 0;
 }
 
-static void lmv_del_target(struct lmv_obd *lmv, int index)
+static void lmv_del_target(struct lmv_obd *lmv, struct lu_tgt_desc *tgt)
 {
-	if (!lmv->tgts[index])
-		return;
-
-	lqos_del_tgt(&lmv->lmv_qos, lmv->tgts[index]);
-
-	kfree(lmv->tgts[index]);
-	lmv->tgts[index] = NULL;
+	LASSERT(tgt);
+	lqos_del_tgt(&lmv->lmv_qos, tgt);
+	lu_tgt_descs_del(&lmv->lmv_mdt_descs, tgt);
+	kfree(tgt);
 }
 
 static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
@@ -381,6 +368,7 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct obd_device *mdc_obd;
 	struct lmv_tgt_desc *tgt;
+	struct lu_tgt_descs *ltd = &lmv->lmv_mdt_descs;
 	int orig_tgt_count = 0;
 	int rc = 0;
 
@@ -394,78 +382,36 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		return -EINVAL;
 	}
 
-	mutex_lock(&lmv->lmv_init_mutex);
-
-	if ((index < lmv->tgts_size) && lmv->tgts[index]) {
-		tgt = lmv->tgts[index];
-		CERROR("%s: UUID %s already assigned at LMV target index %d: rc = %d\n",
-		       obd->obd_name,
-		       obd_uuid2str(&tgt->ltd_uuid), index, -EEXIST);
-		mutex_unlock(&lmv->lmv_init_mutex);
-		return -EEXIST;
-	}
-
-	if (index >= lmv->tgts_size) {
-		/* We need to reallocate the lmv target array. */
-		struct lmv_tgt_desc **newtgts, **old = NULL;
-		u32 newsize = 1;
-		u32 oldsize = 0;
-
-		while (newsize < index + 1)
-			newsize <<= 1;
-		newtgts = kcalloc(newsize, sizeof(*newtgts), GFP_NOFS);
-		if (!newtgts) {
-			mutex_unlock(&lmv->lmv_init_mutex);
-			return -ENOMEM;
-		}
-
-		if (lmv->tgts_size) {
-			memcpy(newtgts, lmv->tgts,
-			       sizeof(*newtgts) * lmv->tgts_size);
-			old = lmv->tgts;
-			oldsize = lmv->tgts_size;
-		}
-
-		lmv->tgts = newtgts;
-		lmv->tgts_size = newsize;
-		smp_rmb();
-		kfree(old);
-
-		CDEBUG(D_CONFIG, "tgts: %p size: %d\n", lmv->tgts,
-		       lmv->tgts_size);
-	}
-
 	tgt = kzalloc(sizeof(*tgt), GFP_NOFS);
-	if (!tgt) {
-		mutex_unlock(&lmv->lmv_init_mutex);
+	if (!tgt)
 		return -ENOMEM;
-	}
 
 	mutex_init(&tgt->ltd_fid_mutex);
 	tgt->ltd_index = index;
 	tgt->ltd_uuid = *uuidp;
 	tgt->ltd_active = 0;
-	lmv->tgts[index] = tgt;
-	if (index >= lmv->desc.ld_tgt_count) {
+
+	mutex_lock(&ltd->ltd_mutex);
+	rc = lu_tgt_descs_add(ltd, tgt);
+	if (!rc && index >= lmv->desc.ld_tgt_count) {
 		orig_tgt_count = lmv->desc.ld_tgt_count;
 		lmv->desc.ld_tgt_count = index + 1;
 	}
+	mutex_unlock(&ltd->ltd_mutex);
 
-	if (!lmv->connected) {
+	if (rc)
+		goto out_tgt;
+
+	if (!lmv->connected)
 		/* lmv_check_connect() will connect this target. */
-		mutex_unlock(&lmv->lmv_init_mutex);
 		return rc;
-	}
 
-	/* Otherwise let's connect it ourselves */
-	mutex_unlock(&lmv->lmv_init_mutex);
 	rc = lmv_connect_mdc(obd, tgt);
 	if (rc) {
-		spin_lock(&lmv->lmv_lock);
-		if (lmv->desc.ld_tgt_count == index + 1)
-			lmv->desc.ld_tgt_count = orig_tgt_count;
+		mutex_lock(&ltd->ltd_mutex);
+		lmv->desc.ld_tgt_count = orig_tgt_count;
 		memset(tgt, 0, sizeof(*tgt));
-		spin_unlock(&lmv->lmv_lock);
+		mutex_unlock(&ltd->ltd_mutex);
 	} else {
 		int easize = sizeof(struct lmv_stripe_md) +
 			     lmv->desc.ld_tgt_count * sizeof(struct lu_fid);
@@ -473,47 +419,46 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 	}
 
 	return rc;
+
+out_tgt:
+	kfree(tgt);
+	return rc;
 }
 
 static int lmv_check_connect(struct obd_device *obd)
 {
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
-	u32 i;
-	int rc;
 	int easize;
+	int rc;
 
 	if (lmv->connected)
 		return 0;
 
-	mutex_lock(&lmv->lmv_init_mutex);
+	mutex_lock(&lmv->lmv_mdt_descs.ltd_mutex);
 	if (lmv->connected) {
-		mutex_unlock(&lmv->lmv_init_mutex);
-		return 0;
+		rc = 0;
+		goto unlock;
 	}
 
 	if (lmv->desc.ld_tgt_count == 0) {
-		mutex_unlock(&lmv->lmv_init_mutex);
-		CERROR("%s: no targets configured.\n", obd->obd_name);
-		return -EINVAL;
+		CERROR("%s: no targets configured: rc = -EINVAL\n",
+		       obd->obd_name);
+		rc = -EINVAL;
+		goto unlock;
 	}
 
-	LASSERT(lmv->tgts);
-
-	if (!lmv->tgts[0]) {
-		mutex_unlock(&lmv->lmv_init_mutex);
-		CERROR("%s: no target configured for index 0.\n",
+	if (!lmv_mdt0_inited(lmv)) {
+		CERROR("%s: no target configured for index 0: rc = -EINVAL.\n",
 		       obd->obd_name);
-		return -EINVAL;
+		rc = -EINVAL;
+		goto unlock;
 	}
 
 	CDEBUG(D_CONFIG, "Time to connect %s to %s\n",
 	       obd->obd_uuid.uuid, obd->obd_name);
 
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		tgt = lmv->tgts[i];
-		if (!tgt)
-			continue;
+	lmv_foreach_tgt(lmv, tgt) {
 		rc = lmv_connect_mdc(obd, tgt);
 		if (rc)
 			goto out_disc;
@@ -522,29 +467,22 @@ static int lmv_check_connect(struct obd_device *obd)
 	lmv->connected = 1;
 	easize = lmv_mds_md_size(lmv->desc.ld_tgt_count, LMV_MAGIC);
 	lmv_init_ea_size(obd->obd_self_export, easize, 0);
-	mutex_unlock(&lmv->lmv_init_mutex);
-	return 0;
+unlock:
+	mutex_unlock(&lmv->lmv_mdt_descs.ltd_mutex);
 
-out_disc:
-	while (i-- > 0) {
-		int rc2;
+	return rc;
 
-		tgt = lmv->tgts[i];
-		if (!tgt)
-			continue;
+out_disc:
+	lmv_foreach_tgt(lmv, tgt) {
 		tgt->ltd_active = 0;
-		if (tgt->ltd_exp) {
-			--lmv->desc.ld_active_tgt_count;
-			rc2 = obd_disconnect(tgt->ltd_exp);
-			if (rc2) {
-				CERROR("LMV target %s disconnect on MDC idx %d: error %d\n",
-				       tgt->ltd_uuid.uuid, i, rc2);
-			}
-		}
+		if (!tgt->ltd_exp)
+			continue;
+
+		--lmv->desc.ld_active_tgt_count;
+		obd_disconnect(tgt->ltd_exp);
 	}
 
-	mutex_unlock(&lmv->lmv_init_mutex);
-	return rc;
+	goto unlock;
 }
 
 static int lmv_disconnect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
@@ -591,27 +529,15 @@ static int lmv_disconnect(struct obd_export *exp)
 {
 	struct obd_device *obd = class_exp2obd(exp);
 	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
 	int rc;
-	u32 i;
 
-	if (!lmv->tgts)
-		goto out_local;
-
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp)
-			continue;
-
-		lmv_disconnect_mdc(obd, lmv->tgts[i]);
-	}
+	lmv_foreach_connected_tgt(lmv, tgt)
+		lmv_disconnect_mdc(obd, tgt);
 
 	if (lmv->lmv_tgts_kobj)
 		kobject_put(lmv->lmv_tgts_kobj);
 
-out_local:
-	/*
-	 * This is the case when no real connection is established by
-	 * lmv_check_connect().
-	 */
 	if (!lmv->connected)
 		class_export_put(exp);
 	rc = class_disconnect(exp);
@@ -631,7 +557,7 @@ static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
 	int remote_gf_size = 0;
 	int rc;
 
-	tgt = lmv_find_target(lmv, &gf->gf_fid);
+	tgt = lmv_fid2tgt(lmv, &gf->gf_fid);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -696,7 +622,7 @@ static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
 		goto out_fid2path;
 	}
 
-	tgt = lmv_find_target(lmv, &gf->gf_fid);
+	tgt = lmv_fid2tgt(lmv, &gf->gf_fid);
 	if (IS_ERR(tgt)) {
 		rc = -EINVAL;
 		goto out_fid2path;
@@ -719,12 +645,13 @@ static int lmv_hsm_req_count(struct lmv_obd *lmv,
 			     const struct hsm_user_request *hur,
 			     const struct lmv_tgt_desc *tgt_mds)
 {
-	u32 i, nr = 0;
 	struct lmv_tgt_desc *curr_tgt;
+	u32 i;
+	int nr = 0;
 
 	/* count how many requests must be sent to the given target */
 	for (i = 0; i < hur->hur_request.hr_itemcount; i++) {
-		curr_tgt = lmv_find_target(lmv, &hur->hur_user_item[i].hui_fid);
+		curr_tgt = lmv_fid2tgt(lmv, &hur->hur_user_item[i].hui_fid);
 		if (IS_ERR(curr_tgt))
 			return PTR_ERR(curr_tgt);
 		if (obd_uuid_equals(&curr_tgt->ltd_uuid, &tgt_mds->ltd_uuid))
@@ -736,17 +663,16 @@ static int lmv_hsm_req_count(struct lmv_obd *lmv,
 static int lmv_hsm_req_build(struct lmv_obd *lmv,
 			     struct hsm_user_request *hur_in,
 			     const struct lmv_tgt_desc *tgt_mds,
-			     struct hsm_user_request *hur_out)
+			      struct hsm_user_request *hur_out)
 {
-	int i, nr_out;
+	u32 i, nr_out;
 	struct lmv_tgt_desc *curr_tgt;
 
 	/* build the hsm_user_request for the given target */
 	hur_out->hur_request = hur_in->hur_request;
 	nr_out = 0;
 	for (i = 0; i < hur_in->hur_request.hr_itemcount; i++) {
-		curr_tgt = lmv_find_target(lmv,
-					   &hur_in->hur_user_item[i].hui_fid);
+		curr_tgt = lmv_fid2tgt(lmv, &hur_in->hur_user_item[i].hui_fid);
 		if (IS_ERR(curr_tgt))
 			return PTR_ERR(curr_tgt);
 		if (obd_uuid_equals(&curr_tgt->ltd_uuid, &tgt_mds->ltd_uuid)) {
@@ -767,20 +693,14 @@ static int lmv_hsm_ct_unregister(struct obd_device *obd, unsigned int cmd,
 				 void __user *uarg)
 {
 	struct lmv_obd *lmv = &obd->u.lmv;
-	u32 i;
+	struct lu_tgt_desc *tgt;
 
 	/* unregister request (call from llapi_hsm_copytool_fini) */
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		struct lmv_tgt_desc *tgt = lmv->tgts[i];
-
-		if (!tgt || !tgt->ltd_exp)
-			continue;
-
+	lmv_foreach_connected_tgt(lmv, tgt)
 		/* best effort: try to clean as much as possible
 		 * (continue on error)
 		 */
-		obd_iocontrol(cmd, lmv->tgts[i]->ltd_exp, len, lk, uarg);
-	}
+		obd_iocontrol(cmd, tgt->ltd_exp, len, lk, uarg);
 
 	/* Whatever the result, remove copytool from kuc groups.
 	 * Unreached coordinators will get EPIPE on next requests
@@ -795,11 +715,12 @@ static int lmv_hsm_ct_register(struct obd_device *obd, unsigned int cmd,
 {
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct file *filp;
-	u32 i, j;
-	int err;
 	bool any_set = false;
 	struct kkuc_ct_data *kcd;
 	size_t kcd_size;
+	struct lu_tgt_desc *tgt;
+	u32 i;
+	int err;
 	int rc = 0;
 
 	filp = fget(lk->lk_wfd);
@@ -838,26 +759,22 @@ static int lmv_hsm_ct_register(struct obd_device *obd, unsigned int cmd,
 	 * In case of failure, unregister from previous MDS,
 	 * except if it because of inactive target.
 	 */
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		struct lmv_tgt_desc *tgt = lmv->tgts[i];
-
-		if (!tgt || !tgt->ltd_exp)
-			continue;
-
+	lmv_foreach_connected_tgt(lmv, tgt) {
 		err = obd_iocontrol(cmd, tgt->ltd_exp, len, lk, uarg);
 		if (err) {
 			if (tgt->ltd_active) {
 				/* permanent error */
 				CERROR("error: iocontrol MDC %s on MDTidx %d cmd %x: err = %d\n",
-				       tgt->ltd_uuid.uuid, i, cmd, err);
+				       tgt->ltd_uuid.uuid, tgt->ltd_index, cmd,
+				       err);
 				rc = err;
 				lk->lk_flags |= LK_FLG_STOP;
+				i = tgt->ltd_index;
 				/* unregister from previous MDS */
-				for (j = 0; j < i; j++) {
-					tgt = lmv->tgts[j];
+				lmv_foreach_connected_tgt(lmv, tgt) {
+					if (tgt->ltd_index >= i)
+						break;
 
-					if (!tgt || !tgt->ltd_exp)
-						continue;
 					obd_iocontrol(cmd, tgt->ltd_exp, len,
 						      lk, uarg);
 				}
@@ -891,11 +808,10 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 {
 	struct obd_device *obddev = class_exp2obd(exp);
 	struct lmv_obd *lmv = &obddev->u.lmv;
-	struct lmv_tgt_desc *tgt = NULL;
-	u32 i = 0;
-	int rc = 0;
+	struct lu_tgt_desc *tgt = NULL;
 	int set = 0;
 	u32 count = lmv->desc.ld_tgt_count;
+	int rc = 0;
 
 	if (count == 0)
 		return -ENOTTY;
@@ -911,7 +827,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		if (index >= count)
 			return -ENODEV;
 
-		tgt = lmv->tgts[index];
+		tgt = lmv_tgt(lmv, index);
 		if (!tgt || !tgt->ltd_active)
 			return -ENODATA;
 
@@ -944,14 +860,11 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 			if (count <= qctl->qc_idx)
 				return -EINVAL;
 
-			tgt = lmv->tgts[qctl->qc_idx];
+			tgt = lmv_tgt(lmv, qctl->qc_idx);
 			if (!tgt || !tgt->ltd_exp)
 				return -EINVAL;
 		} else if (qctl->qc_valid == QC_UUID) {
-			for (i = 0; i < count; i++) {
-				tgt = lmv->tgts[i];
-				if (!tgt)
-					continue;
+			lmv_foreach_tgt(lmv, tgt) {
 				if (!obd_uuid_equals(&tgt->ltd_uuid,
 						     &qctl->obd_uuid))
 					continue;
@@ -965,11 +878,11 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 			return -EINVAL;
 		}
 
-		if (i >= count)
+		if (tgt->ltd_index >= count)
 			return -EAGAIN;
 
 		LASSERT(tgt && tgt->ltd_exp);
-		oqctl = kzalloc(sizeof(*oqctl), GFP_NOFS);
+		oqctl = kzalloc(sizeof(*oqctl), GFP_KERNEL);
 		if (!oqctl)
 			return -ENOMEM;
 
@@ -984,11 +897,11 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		break;
 	}
 	case LL_IOC_GET_CONNECT_FLAGS: {
-		tgt = lmv->tgts[0];
+		tgt = lmv_tgt(lmv, 0);
+		rc = -ENODATA;
 
-		if (!tgt || !tgt->ltd_exp)
-			return -ENODATA;
-		rc = obd_iocontrol(cmd, tgt->ltd_exp, len, karg, uarg);
+		if (tgt && tgt->ltd_exp)
+			rc = obd_iocontrol(cmd, tgt->ltd_exp, len, karg, uarg);
 		break;
 	}
 	case LL_IOC_FID2MDTIDX: {
@@ -1015,7 +928,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 	case LL_IOC_HSM_ACTION: {
 		struct md_op_data *op_data = karg;
 
-		tgt = lmv_find_target(lmv, &op_data->op_fid1);
+		tgt = lmv_fid2tgt(lmv, &op_data->op_fid1);
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
 
@@ -1028,7 +941,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 	case LL_IOC_HSM_PROGRESS: {
 		const struct hsm_progress_kernel *hpk = karg;
 
-		tgt = lmv_find_target(lmv, &hpk->hpk_fid);
+		tgt = lmv_fid2tgt(lmv, &hpk->hpk_fid);
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
 		rc = obd_iocontrol(cmd, tgt->ltd_exp, len, karg, uarg);
@@ -1046,22 +959,17 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		 * the request.
 		 */
 		if (reqcount == 1 || count == 1) {
-			tgt = lmv_find_target(lmv,
-					      &hur->hur_user_item[0].hui_fid);
+			tgt = lmv_fid2tgt(lmv, &hur->hur_user_item[0].hui_fid);
 			if (IS_ERR(tgt))
 				return PTR_ERR(tgt);
 			rc = obd_iocontrol(cmd, tgt->ltd_exp, len, karg, uarg);
 		} else {
 			/* split fid list to their respective MDS */
-			for (i = 0; i < count; i++) {
+			lmv_foreach_connected_tgt(lmv, tgt) {
 				struct hsm_user_request *req;
 				size_t reqlen;
 				int nr, rc1;
 
-				tgt = lmv->tgts[i];
-				if (!tgt || !tgt->ltd_exp)
-					continue;
-
 				nr = lmv_hsm_req_count(lmv, hur, tgt);
 				if (nr < 0)
 					return nr;
@@ -1094,11 +1002,11 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		struct md_op_data *op_data = karg;
 		struct lmv_tgt_desc *tgt1, *tgt2;
 
-		tgt1 = lmv_find_target(lmv, &op_data->op_fid1);
+		tgt1 = lmv_fid2tgt(lmv, &op_data->op_fid1);
 		if (IS_ERR(tgt1))
 			return PTR_ERR(tgt1);
 
-		tgt2 = lmv_find_target(lmv, &op_data->op_fid2);
+		tgt2 = lmv_fid2tgt(lmv, &op_data->op_fid2);
 		if (IS_ERR(tgt2))
 			return PTR_ERR(tgt2);
 
@@ -1122,13 +1030,10 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		break;
 	}
 	default:
-		for (i = 0; i < count; i++) {
+		lmv_foreach_connected_tgt(lmv, tgt) {
 			struct obd_device *mdc_obd;
 			int err;
 
-			tgt = lmv->tgts[i];
-			if (!tgt || !tgt->ltd_exp)
-				continue;
 			/* ll_umount_begin() sets force flag but for lmv, not
 			 * mdc. Let's pass it through
 			 */
@@ -1139,7 +1044,8 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 				if (tgt->ltd_active) {
 					CERROR("%s: error: iocontrol MDC %s on MDTidx %d cmd %x: err = %d\n",
 					       lmv2obd_dev(lmv)->obd_name,
-					       tgt->ltd_uuid.uuid, i, cmd, err);
+					       tgt->ltd_uuid.uuid,
+					       tgt->ltd_index, cmd, err);
 					if (!rc)
 						rc = err;
 				}
@@ -1207,9 +1113,9 @@ int __lmv_fid_alloc(struct lmv_obd *lmv, struct lu_fid *fid, u32 mds)
 	struct lmv_tgt_desc *tgt;
 	int rc;
 
-	tgt = lmv_get_target(lmv, mds, NULL);
-	if (IS_ERR(tgt))
-		return PTR_ERR(tgt);
+	tgt = lmv_tgt(lmv, mds);
+	if (!tgt)
+		return -ENODEV;
 
 	/*
 	 * New seq alloc and FLD setup should be atomic. Otherwise we may find
@@ -1276,11 +1182,6 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		return -EINVAL;
 	}
 
-	lmv->tgts_size = 32U;
-	lmv->tgts = kcalloc(lmv->tgts_size, sizeof(*lmv->tgts), GFP_NOFS);
-	if (!lmv->tgts)
-		return -ENOMEM;
-
 	obd_str2uuid(&lmv->desc.ld_uuid, desc->ld_uuid.uuid);
 	lmv->desc.ld_tgt_count = 0;
 	lmv->desc.ld_active_tgt_count = 0;
@@ -1289,7 +1190,6 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	lmv->max_easize = 0;
 
 	spin_lock_init(&lmv->lmv_lock);
-	mutex_init(&lmv->lmv_init_mutex);
 
 	/* Set up allocation policy (QoS and RR) */
 	INIT_LIST_HEAD(&lmv->lmv_qos.lq_svr_list);
@@ -1321,30 +1221,28 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 
 	rc = fld_client_init(&lmv->lmv_fld, obd->obd_name,
 			     LUSTRE_CLI_FLD_HASH_DHT);
-	if (rc) {
+	if (rc)
 		CERROR("Can't init FLD, err %d\n", rc);
-		return rc;
-	}
 
-	return 0;
+	rc = lu_tgt_descs_init(&lmv->lmv_mdt_descs);
+	if (rc)
+		CWARN("%s: error initialize target table: rc = %d\n",
+		      obd->obd_name, rc);
+
+	return rc;
 }
 
 static int lmv_cleanup(struct obd_device *obd)
 {
 	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lu_tgt_desc *tgt;
+	struct lu_tgt_desc *tmp;
 
 	fld_client_fini(&lmv->lmv_fld);
-	if (lmv->tgts) {
-		int i;
+	lmv_foreach_tgt_safe(lmv, tgt, tmp)
+		lmv_del_target(lmv, tgt);
+	lu_tgt_descs_fini(&lmv->lmv_mdt_descs);
 
-		for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-			if (!lmv->tgts[i])
-				continue;
-			lmv_del_target(lmv, i);
-		}
-		kfree(lmv->tgts);
-		lmv->tgts_size = 0;
-	}
 	return 0;
 }
 
@@ -1423,8 +1321,10 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 	struct obd_device *obd = class_exp2obd(exp);
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct obd_statfs *temp;
+	struct lu_tgt_desc *tgt;
+	u32 i;
+	u32 idx;
 	int rc = 0;
-	u32 i, idx;
 
 	temp = kzalloc(sizeof(*temp), GFP_NOFS);
 	if (!temp)
@@ -1435,15 +1335,14 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++, idx++) {
 		idx = idx % lmv->desc.ld_tgt_count;
-		if (!lmv->tgts[idx] || !lmv->tgts[idx]->ltd_exp)
+		tgt = lmv_tgt(lmv, idx);
+		if (!tgt || !tgt->ltd_exp)
 			continue;
 
-		rc = obd_statfs(env, lmv->tgts[idx]->ltd_exp, temp,
-				max_age, flags);
+		rc = obd_statfs(env, tgt->ltd_exp, temp, max_age, flags);
 		if (rc) {
 			CERROR("%s: can't stat MDS #%d: rc = %d\n",
-			       lmv->tgts[idx]->ltd_exp->exp_obd->obd_name, i,
-			       rc);
+			       tgt->ltd_exp->exp_obd->obd_name, i, rc);
 			goto out_free_temp;
 		}
 
@@ -1524,8 +1423,12 @@ static int lmv_get_root(struct obd_export *exp, const char *fileset,
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lu_tgt_desc *tgt = lmv_tgt(lmv, 0);
+
+	if (!tgt)
+		return -ENODEV;
 
-	return md_get_root(lmv->tgts[0]->ltd_exp, fileset, fid);
+	return md_get_root(tgt->ltd_exp, fileset, fid);
 }
 
 static int lmv_getxattr(struct obd_export *exp, const struct lu_fid *fid,
@@ -1536,7 +1439,7 @@ static int lmv_getxattr(struct obd_export *exp, const struct lu_fid *fid,
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
 
-	tgt = lmv_find_target(lmv, fid);
+	tgt = lmv_fid2tgt(lmv, fid);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -1554,7 +1457,7 @@ static int lmv_setxattr(struct obd_export *exp, const struct lu_fid *fid,
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
 
-	tgt = lmv_find_target(lmv, fid);
+	tgt = lmv_fid2tgt(lmv, fid);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -1569,7 +1472,7 @@ static int lmv_getattr(struct obd_export *exp, struct md_op_data *op_data,
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
 
-	tgt = lmv_find_target(lmv, &op_data->op_fid1);
+	tgt = lmv_fid2tgt(lmv, &op_data->op_fid1);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -1585,7 +1488,7 @@ static int lmv_null_inode(struct obd_export *exp, const struct lu_fid *fid)
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
-	u32 i;
+	struct lu_tgt_desc *tgt;
 
 	CDEBUG(D_INODE, "CBDATA for " DFID "\n", PFID(fid));
 
@@ -1594,11 +1497,8 @@ static int lmv_null_inode(struct obd_export *exp, const struct lu_fid *fid)
 	 * lookup lock in space of MDT storing direntry and update/open lock in
 	 * space of MDT storing inode.
 	 */
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp)
-			continue;
-		md_null_inode(lmv->tgts[i]->ltd_exp, fid);
-	}
+	lmv_foreach_connected_tgt(lmv, tgt)
+		md_null_inode(tgt->ltd_exp, fid);
 
 	return 0;
 }
@@ -1610,7 +1510,7 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
 
-	tgt = lmv_find_target(lmv, &op_data->op_fid1);
+	tgt = lmv_fid2tgt(lmv, &op_data->op_fid1);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -1627,7 +1527,7 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 	struct lmv_tgt_desc *tgt;
 
 	if (!lmv_dir_striped(lsm) || !namelen) {
-		tgt = lmv_find_target(lmv, fid);
+		tgt = lmv_fid2tgt(lmv, fid);
 		if (IS_ERR(tgt))
 			return tgt;
 
@@ -1648,11 +1548,11 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 
 	*fid = oinfo->lmo_fid;
 	*mds = oinfo->lmo_mds;
-	tgt = lmv_get_target(lmv, oinfo->lmo_mds, NULL);
+	tgt = lmv_tgt(lmv, oinfo->lmo_mds);
 
 	CDEBUG(D_INODE, "locate MDT %u parent " DFID "\n", *mds, PFID(fid));
 
-	return tgt;
+	return tgt ? tgt : ERR_PTR(-ENODEV);
 }
 
 /**
@@ -1690,9 +1590,9 @@ struct lmv_tgt_desc *
 	 */
 	if (op_data->op_bias & MDS_CREATE_VOLATILE &&
 	    (int)op_data->op_mds != -1) {
-		tgt = lmv_get_target(lmv, op_data->op_mds, NULL);
-		if (IS_ERR(tgt))
-			return tgt;
+		tgt = lmv_tgt(lmv, op_data->op_mds);
+		if (!tgt)
+			return ERR_PTR(-ENODEV);
 
 		if (lmv_dir_striped(lsm)) {
 			int i;
@@ -1715,7 +1615,10 @@ struct lmv_tgt_desc *
 
 		op_data->op_fid1 = oinfo->lmo_fid;
 		op_data->op_mds = oinfo->lmo_mds;
-		tgt = lmv_get_target(lmv, oinfo->lmo_mds, NULL);
+
+		tgt = lmv_tgt(lmv, oinfo->lmo_mds);
+		if (!tgt)
+			tgt = ERR_PTR(-ENODEV);
 	} else if (op_data->op_code == LUSTRE_OPC_MKDIR &&
 		   lmv_dir_qos_mkdir(op_data->op_default_mea1) &&
 		   !lmv_dir_striped(lsm)) {
@@ -1847,7 +1750,7 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		 * Send the create request to the MDT where the object
 		 * will be located
 		 */
-		tgt = lmv_find_target(lmv, &op_data->op_fid2);
+		tgt = lmv_fid2tgt(lmv, &op_data->op_fid2);
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
 
@@ -1881,7 +1784,7 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 
 	CDEBUG(D_INODE, "ENQUEUE on " DFID "\n", PFID(&op_data->op_fid1));
 
-	tgt = lmv_find_target(lmv, &op_data->op_fid1);
+	tgt = lmv_fid2tgt(lmv, &op_data->op_fid1);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -1958,7 +1861,7 @@ static int lmv_early_cancel(struct obd_export *exp, struct lmv_tgt_desc *tgt,
 		return 0;
 
 	if (!tgt) {
-		tgt = lmv_find_target(lmv, fid);
+		tgt = lmv_fid2tgt(lmv, fid);
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
 	}
@@ -2041,7 +1944,7 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
 	op_data->op_cap = current_cap();
 
-	parent_tgt = lmv_find_target(lmv, &op_data->op_fid1);
+	parent_tgt = lmv_fid2tgt(lmv, &op_data->op_fid1);
 	if (IS_ERR(parent_tgt))
 		return PTR_ERR(parent_tgt);
 
@@ -2068,10 +1971,9 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 
 		/* save it in fid4 temporarily for early cancel */
 		op_data->op_fid4 = lsm->lsm_md_oinfo[rc].lmo_fid;
-		sp_tgt = lmv_get_target(lmv, lsm->lsm_md_oinfo[rc].lmo_mds,
-					NULL);
-		if (IS_ERR(sp_tgt))
-			return PTR_ERR(sp_tgt);
+		sp_tgt = lmv_tgt(lmv, lsm->lsm_md_oinfo[rc].lmo_mds);
+		if (!sp_tgt)
+			return -ENODEV;
 
 		/*
 		 * if parent is being migrated too, fill op_fid2 with target
@@ -2088,17 +1990,15 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 				return rc;
 
 			op_data->op_fid2 = lsm->lsm_md_oinfo[rc].lmo_fid;
-			tp_tgt = lmv_get_target(lmv,
-						lsm->lsm_md_oinfo[rc].lmo_mds,
-						NULL);
-			if (IS_ERR(tp_tgt))
-				return PTR_ERR(tp_tgt);
+			tp_tgt = lmv_tgt(lmv, lsm->lsm_md_oinfo[rc].lmo_mds);
+			if (!tp_tgt)
+				return -ENODEV;
 		}
 	} else {
 		sp_tgt = parent_tgt;
 	}
 
-	child_tgt = lmv_find_target(lmv, &op_data->op_fid3);
+	child_tgt = lmv_fid2tgt(lmv, &op_data->op_fid3);
 	if (IS_ERR(child_tgt))
 		return PTR_ERR(child_tgt);
 
@@ -2121,7 +2021,7 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 	 */
 	if (S_ISDIR(op_data->op_mode) &&
 	    (exp_connect_flags2(exp) & OBD_CONNECT2_DIR_MIGRATE)) {
-		tgt = lmv_find_target(lmv, &target_fid);
+		tgt = lmv_fid2tgt(lmv, &target_fid);
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
 	} else {
@@ -2219,7 +2119,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	 * then it will send the request to the target parent
 	 */
 	if (fid_is_sane(&op_data->op_fid4)) {
-		tgt = lmv_find_target(lmv, &op_data->op_fid4);
+		tgt = lmv_fid2tgt(lmv, &op_data->op_fid4);
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
 	} else {
@@ -2247,7 +2147,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	}
 
 	if (fid_is_sane(&op_data->op_fid3)) {
-		src_tgt = lmv_find_target(lmv, &op_data->op_fid3);
+		src_tgt = lmv_fid2tgt(lmv, &op_data->op_fid3);
 		if (IS_ERR(src_tgt))
 			return PTR_ERR(src_tgt);
 
@@ -2313,7 +2213,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	ptlrpc_req_finished(*request);
 	*request = NULL;
 
-	tgt = lmv_find_target(lmv, &op_data->op_fid4);
+	tgt = lmv_fid2tgt(lmv, &op_data->op_fid4);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -2344,7 +2244,7 @@ static int lmv_setattr(struct obd_export *exp, struct md_op_data *op_data,
 		op_data->op_xvalid);
 
 	op_data->op_flags |= MF_MDC_CANCEL_FID1;
-	tgt = lmv_find_target(lmv, &op_data->op_fid1);
+	tgt = lmv_fid2tgt(lmv, &op_data->op_fid1);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -2358,7 +2258,7 @@ static int lmv_fsync(struct obd_export *exp, const struct lu_fid *fid,
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
 
-	tgt = lmv_find_target(lmv, fid);
+	tgt = lmv_fid2tgt(lmv, fid);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -2465,9 +2365,9 @@ static struct lu_dirent *stripe_dirent_load(struct lmv_dir_ctxt *ctxt,
 			break;
 		}
 
-		tgt = lmv_get_target(ctxt->ldc_lmv, oinfo->lmo_mds, NULL);
-		if (IS_ERR(tgt)) {
-			rc = PTR_ERR(tgt);
+		tgt = lmv_tgt(ctxt->ldc_lmv, oinfo->lmo_mds);
+		if (!tgt) {
+			rc = -ENODEV;
 			break;
 		}
 
@@ -2516,7 +2416,7 @@ static int lmv_file_resync(struct obd_export *exp, struct md_op_data *data)
 	if (rc != 0)
 		return rc;
 
-	tgt = lmv_find_target(lmv, &data->op_fid1);
+	tgt = lmv_fid2tgt(lmv, &data->op_fid1);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -2741,7 +2641,7 @@ static int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
 					     offset, ppage);
 	}
 
-	tgt = lmv_find_target(lmv, &op_data->op_fid1);
+	tgt = lmv_fid2tgt(lmv, &op_data->op_fid1);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -2792,7 +2692,7 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 		return PTR_ERR(parent_tgt);
 
 	if (likely(!fid_is_zero(&op_data->op_fid2))) {
-		tgt = lmv_find_target(lmv, &op_data->op_fid2);
+		tgt = lmv_fid2tgt(lmv, &op_data->op_fid2);
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
 	} else {
@@ -2845,7 +2745,7 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	ptlrpc_req_finished(*request);
 	*request = NULL;
 
-	tgt = lmv_find_target(lmv, &op_data->op_fid2);
+	tgt = lmv_fid2tgt(lmv, &op_data->op_fid2);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -2881,6 +2781,7 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 {
 	struct obd_device *obd;
 	struct lmv_obd *lmv;
+	struct lu_tgt_desc *tgt;
 	int rc = 0;
 
 	obd = class_exp2obd(exp);
@@ -2892,18 +2793,8 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 
 	lmv = &obd->u.lmv;
 	if (keylen >= strlen("remote_flag") && !strcmp(key, "remote_flag")) {
-		int i;
-
 		LASSERT(*vallen == sizeof(u32));
-		for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-			struct lmv_tgt_desc *tgt = lmv->tgts[i];
-
-			/*
-			 * All tgts should be connected when this gets called.
-			 */
-			if (!tgt || !tgt->ltd_exp)
-				continue;
-
+		lmv_foreach_connected_tgt(lmv, tgt) {
 			if (!obd_get_info(env, tgt->ltd_exp, keylen, key,
 					  vallen, val))
 				return 0;
@@ -2916,8 +2807,11 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 		 * Forwarding this request to first MDS, it should know LOV
 		 * desc.
 		 */
-		rc = obd_get_info(env, lmv->tgts[0]->ltd_exp, keylen, key,
-				  vallen, val);
+		tgt = lmv_tgt(lmv, 0);
+		if (!tgt)
+			return -ENODEV;
+
+		rc = obd_get_info(env, tgt->ltd_exp, keylen, key, vallen, val);
 		if (!rc && KEY_IS(KEY_CONN_DATA))
 			exp->exp_connect_data = *(struct obd_connect_data *)val;
 		return rc;
@@ -2937,6 +2831,7 @@ static int lmv_rmfid(struct obd_export *exp, struct fid_array *fa,
 	struct ptlrpc_request_set *set = _set;
 	struct lmv_obd *lmv = &obddev->u.lmv;
 	int tgt_count = lmv->desc.ld_tgt_count;
+	struct lu_tgt_desc *tgt;
 	struct fid_array *fat, **fas = NULL;
 	int i, rc, **rcs = NULL;
 
@@ -2987,11 +2882,11 @@ static int lmv_rmfid(struct obd_export *exp, struct fid_array *fa,
 		fat->fa_fids[fat->fa_nr++] = fa->fa_fids[i];
 	}
 
-	for (i = 0; i < tgt_count; i++) {
-		fat = fas[i];
+	lmv_foreach_connected_tgt(lmv, tgt) {
+		fat = fas[tgt->ltd_index];
 		if (!fat || fat->fa_nr == 0)
 			continue;
-		rc = md_rmfid(lmv->tgts[i]->ltd_exp, fat, rcs[i], set);
+		rc = md_rmfid(tgt->ltd_exp, fat, rcs[tgt->ltd_index], set);
 	}
 
 	rc = ptlrpc_set_wait(NULL, set);
@@ -3062,14 +2957,9 @@ static int lmv_set_info_async(const struct lu_env *env, struct obd_export *exp,
 
 	if (KEY_IS(KEY_READ_ONLY) || KEY_IS(KEY_FLUSH_CTX) ||
 	    KEY_IS(KEY_DEFAULT_EASIZE)) {
-		int i, err = 0;
-
-		for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-			tgt = lmv->tgts[i];
-
-			if (!tgt || !tgt->ltd_exp)
-				continue;
+		int err = 0;
 
+		lmv_foreach_connected_tgt(lmv, tgt) {
 			err = obd_set_info_async(env, tgt->ltd_exp,
 						 keylen, key, vallen, val, set);
 			if (err && rc == 0)
@@ -3272,16 +3162,14 @@ static int lmv_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
-	int rc = 0;
+	struct lu_tgt_desc *tgt;
 	int err;
-	u32 i;
+	int rc = 0;
 
 	LASSERT(fid);
 
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		struct lmv_tgt_desc *tgt = lmv->tgts[i];
-
-		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
+	lmv_foreach_connected_tgt(lmv, tgt) {
+		if (!tgt->ltd_active)
 			continue;
 
 		err = md_cancel_unused(tgt->ltd_exp, fid, policy, mode, flags,
@@ -3297,7 +3185,7 @@ static int lmv_set_lock_data(struct obd_export *exp,
 			     void *data, u64 *bits)
 {
 	struct lmv_obd *lmv = &exp->exp_obd->u.lmv;
-	struct lmv_tgt_desc *tgt = lmv->tgts[0];
+	struct lmv_tgt_desc *tgt = lmv_tgt(lmv, 0);
 
 	if (!tgt || !tgt->ltd_exp)
 		return -EINVAL;
@@ -3315,8 +3203,9 @@ static enum ldlm_mode lmv_lock_match(struct obd_export *exp, u64 flags,
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
 	enum ldlm_mode rc;
-	int tgt;
-	u32 i;
+	struct lu_tgt_desc *tgt;
+	int i;
+	int index;
 
 	CDEBUG(D_INODE, "Lock match for " DFID "\n", PFID(fid));
 
@@ -3326,21 +3215,21 @@ static enum ldlm_mode lmv_lock_match(struct obd_export *exp, u64 flags,
 	 * space of MDT storing inode.  Try the MDT that the FID maps to first,
 	 * since this can be easily found, and only try others if that fails.
 	 */
-	for (i = 0, tgt = lmv_find_target_index(lmv, fid);
+	for (i = 0, index = lmv_fid2tgt_index(lmv, fid);
 	     i < lmv->desc.ld_tgt_count;
-	     i++, tgt = (tgt + 1) % lmv->desc.ld_tgt_count) {
-		if (tgt < 0) {
+	     i++, index = (index + 1) % lmv->desc.ld_tgt_count) {
+		if (index < 0) {
 			CDEBUG(D_HA, "%s: " DFID " is inaccessible: rc = %d\n",
-			       obd->obd_name, PFID(fid), tgt);
-			tgt = 0;
+			       obd->obd_name, PFID(fid), index);
+			index = 0;
 		}
 
-		if (!lmv->tgts[tgt] || !lmv->tgts[tgt]->ltd_exp ||
-		    !lmv->tgts[tgt]->ltd_active)
+		tgt = lmv_tgt(lmv, index);
+		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
 			continue;
 
-		rc = md_lock_match(lmv->tgts[tgt]->ltd_exp, flags, fid,
-				   type, policy, mode, lockh);
+		rc = md_lock_match(tgt->ltd_exp, flags, fid, type, policy, mode,
+				   lockh);
 		if (rc)
 			return rc;
 	}
@@ -3355,7 +3244,7 @@ static int lmv_get_lustre_md(struct obd_export *exp,
 			     struct lustre_md *md)
 {
 	struct lmv_obd *lmv = &exp->exp_obd->u.lmv;
-	struct lmv_tgt_desc *tgt = lmv->tgts[0];
+	struct lmv_tgt_desc *tgt = lmv_tgt(lmv, 0);
 
 	if (!tgt || !tgt->ltd_exp)
 		return -EINVAL;
@@ -3366,7 +3255,7 @@ static int lmv_free_lustre_md(struct obd_export *exp, struct lustre_md *md)
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc *tgt = lmv->tgts[0];
+	struct lmv_tgt_desc *tgt = lmv_tgt(lmv, 0);
 
 	if (md->default_lmv) {
 		lmv_free_memmd(md->default_lmv);
@@ -3389,7 +3278,7 @@ static int lmv_set_open_replay_data(struct obd_export *exp,
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
 
-	tgt = lmv_find_target(lmv, &och->och_fid);
+	tgt = lmv_fid2tgt(lmv, &och->och_fid);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -3403,7 +3292,7 @@ static int lmv_clear_open_replay_data(struct obd_export *exp,
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
 
-	tgt = lmv_find_target(lmv, &och->och_fid);
+	tgt = lmv_fid2tgt(lmv, &och->och_fid);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -3426,7 +3315,7 @@ static int lmv_intent_getattr_async(struct obd_export *exp,
 	if (IS_ERR(ptgt))
 		return PTR_ERR(ptgt);
 
-	ctgt = lmv_find_target(lmv, &op_data->op_fid2);
+	ctgt = lmv_fid2tgt(lmv, &op_data->op_fid1);
 	if (IS_ERR(ctgt))
 		return PTR_ERR(ctgt);
 
@@ -3447,7 +3336,7 @@ static int lmv_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
 
-	tgt = lmv_find_target(lmv, fid);
+	tgt = lmv_fid2tgt(lmv, fid);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -3482,13 +3371,11 @@ static int lmv_quotactl(struct obd_device *unused, struct obd_export *exp,
 {
 	struct obd_device *obd = class_exp2obd(exp);
 	struct lmv_obd *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc *tgt = lmv->tgts[0];
+	struct lmv_tgt_desc *tgt = lmv_tgt(lmv, 0);
 	int rc = 0;
 	u64 curspace = 0, curinodes = 0;
-	u32 i;
 
-	if (!tgt || !tgt->ltd_exp || !tgt->ltd_active ||
-	    !lmv->desc.ld_tgt_count) {
+	if (!tgt || !tgt->ltd_exp || !tgt->ltd_active) {
 		CERROR("master lmv inactive\n");
 		return -EIO;
 	}
@@ -3496,17 +3383,16 @@ static int lmv_quotactl(struct obd_device *unused, struct obd_export *exp,
 	if (oqctl->qc_cmd != Q_GETOQUOTA)
 		return obd_quotactl(tgt->ltd_exp, oqctl);
 
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
+	lmv_foreach_connected_tgt(lmv, tgt) {
 		int err;
 
-		tgt = lmv->tgts[i];
-
-		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
+		if (!tgt->ltd_active)
 			continue;
 
 		err = obd_quotactl(tgt->ltd_exp, oqctl);
 		if (err) {
-			CERROR("getquota on mdt %d failed. %d\n", i, err);
+			CERROR("getquota on mdt %d failed. %d\n",
+			       tgt->ltd_index, err);
 			if (!rc)
 				rc = err;
 		} else {
diff --git a/fs/lustre/lmv/lmv_qos.c b/fs/lustre/lmv/lmv_qos.c
index 85053d2e..0bee7c0 100644
--- a/fs/lustre/lmv/lmv_qos.c
+++ b/fs/lustre/lmv/lmv_qos.c
@@ -77,7 +77,6 @@ static int lmv_qos_calc_ppts(struct lmv_obd *lmv)
 	u64 ba_max, ba_min, ba;
 	u64 ia_max, ia_min, ia;
 	u32 num_active;
-	unsigned int i;
 	int prio_wide;
 	time64_t now, age;
 	u32 maxage = lmv->desc.ld_qos_maxage;
@@ -114,9 +113,8 @@ static int lmv_qos_calc_ppts(struct lmv_obd *lmv)
 	now = ktime_get_real_seconds();
 
 	/* Calculate server penalty per object */
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		tgt = lmv->tgts[i];
-		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
+	lmv_foreach_tgt(lmv, tgt) {
+		if (!tgt->ltd_exp || !tgt->ltd_active)
 			continue;
 
 		/* bavail >> 16 to avoid overflow */
@@ -164,9 +162,8 @@ static int lmv_qos_calc_ppts(struct lmv_obd *lmv)
 		 * we have to double the MDT penalty
 		 */
 		num_active = 2;
-		for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-			tgt = lmv->tgts[i];
-			if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
+		lmv_foreach_tgt(lmv, tgt) {
+			if (!tgt->ltd_exp || !tgt->ltd_active)
 				continue;
 
 			tgt->ltd_qos.ltq_penalty_per_obj <<= 1;
@@ -265,7 +262,6 @@ static int lmv_qos_used(struct lmv_obd *lmv, struct lu_tgt_desc *tgt,
 {
 	struct lu_tgt_qos *ltq;
 	struct lu_svr_qos *svr;
-	unsigned int i;
 
 	ltq = &tgt->ltd_qos;
 	LASSERT(ltq);
@@ -301,9 +297,8 @@ static int lmv_qos_used(struct lmv_obd *lmv, struct lu_tgt_desc *tgt,
 
 	*total_wt = 0;
 	/* Decrease all MDT penalties */
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		ltq = &lmv->tgts[i]->ltd_qos;
-		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
+	lmv_foreach_tgt(lmv, tgt) {
+		if (!tgt->ltd_exp || !tgt->ltd_active)
 			continue;
 
 		if (ltq->ltq_penalty < ltq->ltq_penalty_per_obj)
@@ -311,7 +306,7 @@ static int lmv_qos_used(struct lmv_obd *lmv, struct lu_tgt_desc *tgt,
 		else
 			ltq->ltq_penalty -= ltq->ltq_penalty_per_obj;
 
-		lmv_qos_calc_weight(lmv->tgts[i]);
+		lmv_qos_calc_weight(tgt);
 
 		/* Recalc the total weight of usable osts */
 		if (ltq->ltq_usable)
@@ -319,7 +314,7 @@ static int lmv_qos_used(struct lmv_obd *lmv, struct lu_tgt_desc *tgt,
 
 		CDEBUG(D_OTHER,
 		       "recalc tgt %d usable=%d avail=%llu tgtppo=%llu tgtp=%llu svrppo=%llu svrp=%llu wt=%llu\n",
-		       i, ltq->ltq_usable,
+		       tgt->ltd_index, ltq->ltq_usable,
 		       tgt_statfs_bavail(tgt) >> 10,
 		       ltq->ltq_penalty_per_obj >> 10,
 		       ltq->ltq_penalty >> 10,
@@ -337,7 +332,6 @@ struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
 	u64 total_weight = 0;
 	u64 cur_weight = 0;
 	u64 rand;
-	int i;
 	int rc;
 
 	if (!lmv_qos_is_usable(lmv))
@@ -356,11 +350,7 @@ struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
 		goto unlock;
 	}
 
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		tgt = lmv->tgts[i];
-		if (!tgt)
-			continue;
-
+	lmv_foreach_tgt(lmv, tgt) {
 		tgt->ltd_qos.ltq_usable = 0;
 		if (!tgt->ltd_exp || !tgt->ltd_active)
 			continue;
@@ -372,10 +362,8 @@ struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
 
 	rand = lu_prandom_u64_max(total_weight);
 
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		tgt = lmv->tgts[i];
-
-		if (!tgt || !tgt->ltd_qos.ltq_usable)
+	lmv_foreach_tgt(lmv, tgt) {
+		if (!tgt->ltd_qos.ltq_usable)
 			continue;
 
 		cur_weight += tgt->ltd_qos.ltq_weight;
@@ -404,17 +392,18 @@ struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt)
 
 	spin_lock(&lmv->lmv_qos.lq_rr.lqr_alloc);
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		tgt = lmv->tgts[(i + lmv->lmv_qos_rr_index) %
-				lmv->desc.ld_tgt_count];
-		if (tgt && tgt->ltd_exp && tgt->ltd_active) {
-			*mdt = tgt->ltd_index;
-			lmv->lmv_qos_rr_index =
-				(i + lmv->lmv_qos_rr_index + 1) %
-				lmv->desc.ld_tgt_count;
-			spin_unlock(&lmv->lmv_qos.lq_rr.lqr_alloc);
-
-			return tgt;
-		}
+		tgt = lmv_tgt(lmv,
+			(i + lmv->lmv_qos_rr_index) % lmv->desc.ld_tgt_count);
+		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
+			continue;
+
+		*mdt = tgt->ltd_index;
+		lmv->lmv_qos_rr_index =
+			(i + lmv->lmv_qos_rr_index + 1) %
+			lmv->desc.ld_tgt_count;
+		spin_unlock(&lmv->lmv_qos.lq_rr.lqr_alloc);
+
+		return tgt;
 	}
 	spin_unlock(&lmv->lmv_qos.lq_rr.lqr_alloc);
 
diff --git a/fs/lustre/lmv/lproc_lmv.c b/fs/lustre/lmv/lproc_lmv.c
index 659ebeb..af670f8 100644
--- a/fs/lustre/lmv/lproc_lmv.c
+++ b/fs/lustre/lmv/lproc_lmv.c
@@ -183,14 +183,17 @@ static void *lmv_tgt_seq_start(struct seq_file *p, loff_t *pos)
 {
 	struct obd_device *dev = p->private;
 	struct lmv_obd *lmv = &dev->u.lmv;
+	struct lu_tgt_desc *tgt;
+
+	while (*pos < lmv->lmv_mdt_descs.ltd_tgts_size) {
+		tgt = lmv_tgt(lmv, (u32)*pos);
+		if (tgt)
+			return tgt;
 
-	while (*pos < lmv->tgts_size) {
-		if (lmv->tgts[*pos])
-			return lmv->tgts[*pos];
 		++*pos;
 	}
 
-	return  NULL;
+	return NULL;
 }
 
 static void lmv_tgt_seq_stop(struct seq_file *p, void *v)
@@ -201,11 +204,14 @@ static void *lmv_tgt_seq_next(struct seq_file *p, void *v, loff_t *pos)
 {
 	struct obd_device *dev = p->private;
 	struct lmv_obd *lmv = &dev->u.lmv;
+	struct lu_tgt_desc *tgt;
 
 	++*pos;
-	while (*pos < lmv->tgts_size) {
-		if (lmv->tgts[*pos])
-			return lmv->tgts[*pos];
+	while (*pos < lmv->lmv_mdt_descs.ltd_tgts_size) {
+		tgt = lmv_tgt(lmv, (u32)*pos);
+		if (tgt)
+			return tgt;
+
 		++*pos;
 	}
 
diff --git a/fs/lustre/obdclass/Makefile b/fs/lustre/obdclass/Makefile
index 6d762ed..5718a6d 100644
--- a/fs/lustre/obdclass/Makefile
+++ b/fs/lustre/obdclass/Makefile
@@ -8,4 +8,4 @@ obdclass-y := llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
 	      obdo.o obd_config.o obd_mount.o lu_object.o lu_ref.o \
 	      cl_object.o cl_page.o cl_lock.o cl_io.o kernelcomm.o \
-	      jobid.o integrity.o obd_cksum.o lu_qos.o
+	      jobid.o integrity.o obd_cksum.o lu_qos.o lu_tgt_descs.o
diff --git a/fs/lustre/obdclass/lu_tgt_descs.c b/fs/lustre/obdclass/lu_tgt_descs.c
new file mode 100644
index 0000000..04d6acc
--- /dev/null
+++ b/fs/lustre/obdclass/lu_tgt_descs.c
@@ -0,0 +1,192 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ *
+ * lustre/obdclass/lu_tgt_descs.c
+ *
+ * Lustre target descriptions
+ * These are the only exported functions, they provide some generic
+ * infrastructure for target description management used by LOD/LMV
+ *
+ */
+
+#define DEBUG_SUBSYSTEM S_CLASS
+
+#include <linux/module.h>
+#include <linux/list.h>
+#include <obd_class.h>
+#include <obd_support.h>
+#include <lustre_disk.h>
+#include <lustre_fid.h>
+#include <lu_object.h>
+
+/**
+ * Allocate and initialize target table.
+ *
+ * A helper function to initialize the target table and allocate
+ * a bitmap of the available targets.
+ *
+ * @ltd		target's table to initialize
+ *
+ * Return:	0 on success
+ *		negated errno on error
+ **/
+int lu_tgt_descs_init(struct lu_tgt_descs *ltd)
+{
+	mutex_init(&ltd->ltd_mutex);
+	init_rwsem(&ltd->ltd_rw_sem);
+
+	/*
+	 * the tgt array and bitmap are allocated/grown dynamically as tgts are
+	 * added to the LOD/LMV, see lu_tgt_descs_add()
+	 */
+	ltd->ltd_tgt_bitmap = bitmap_zalloc(BITS_PER_LONG, GFP_NOFS);
+	if (!ltd->ltd_tgt_bitmap)
+		return -ENOMEM;
+
+	ltd->ltd_tgts_size  = BITS_PER_LONG;
+	ltd->ltd_tgtnr      = 0;
+
+	ltd->ltd_death_row = 0;
+	ltd->ltd_refcount  = 0;
+
+	return 0;
+}
+EXPORT_SYMBOL(lu_tgt_descs_init);
+
+/**
+ * Free bitmap and target table pages.
+ *
+ * @ltd		target table
+ */
+void lu_tgt_descs_fini(struct lu_tgt_descs *ltd)
+{
+	int i;
+
+	bitmap_free(ltd->ltd_tgt_bitmap);
+	for (i = 0; i < TGT_PTRS; i++)
+		kfree(ltd->ltd_tgt_idx[i]);
+	ltd->ltd_tgts_size = 0;
+}
+EXPORT_SYMBOL(lu_tgt_descs_fini);
+
+/**
+ * Expand size of target table.
+ *
+ * When the target table is full, we have to extend the table. To do so,
+ * we allocate new memory with some reserve, move data from the old table
+ * to the new one and release memory consumed by the old table.
+ *
+ * @ltd		target table
+ * @newsize	new size of the table
+ *
+ * Return:	0 on success
+ *		-ENOMEM if reallocation failed
+ */
+static int lu_tgt_descs_resize(struct lu_tgt_descs *ltd, u32 newsize)
+{
+	unsigned long *new_bitmap, *old_bitmap = NULL;
+
+	/* someone else has already resize the array */
+	if (newsize <= ltd->ltd_tgts_size)
+		return 0;
+
+	new_bitmap = bitmap_zalloc(newsize, GFP_NOFS);
+	if (!new_bitmap)
+		return -ENOMEM;
+
+	if (ltd->ltd_tgts_size > 0) {
+		/* the bitmap already exists, copy data from old one */
+		bitmap_copy(new_bitmap, ltd->ltd_tgt_bitmap,
+			    ltd->ltd_tgts_size);
+		old_bitmap = ltd->ltd_tgt_bitmap;
+	}
+
+	ltd->ltd_tgts_size  = newsize;
+	ltd->ltd_tgt_bitmap = new_bitmap;
+
+	bitmap_free(old_bitmap);
+
+	CDEBUG(D_CONFIG, "tgt size: %d\n", ltd->ltd_tgts_size);
+
+	return 0;
+}
+
+/**
+ * Add new target to target table.
+ *
+ * Extend target table if it's full, update target table and bitmap.
+ * Notice we need to take ltd_rw_sem exclusively before entry to ensure
+ * atomic switch.
+ *
+ * @ltd		target table
+ * @tgt		new target desc
+ *
+ * Return:	0 on success
+ *		-ENOMEM if reallocation failed
+ *		-EEXIST if target existed
+ */
+int lu_tgt_descs_add(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt)
+{
+	u32 index = tgt->ltd_index;
+	int rc;
+
+	if (index >= ltd->ltd_tgts_size) {
+		u32 newsize = 1;
+
+		while (newsize < index + 1)
+			newsize = newsize << 1;
+
+		rc = lu_tgt_descs_resize(ltd, newsize);
+		if (rc)
+			return rc;
+	} else if (test_bit(index, ltd->ltd_tgt_bitmap)) {
+		return -EEXIST;
+	}
+
+	if (ltd->ltd_tgt_idx[index / TGT_PTRS_PER_BLOCK] == NULL) {
+		ltd->ltd_tgt_idx[index / TGT_PTRS_PER_BLOCK] =
+			kzalloc(sizeof(*ltd->ltd_tgt_idx[0]), GFP_NOFS);
+		if (ltd->ltd_tgt_idx[index / TGT_PTRS_PER_BLOCK] == NULL)
+			return -ENOMEM;
+	}
+
+	LTD_TGT(ltd, tgt->ltd_index) = tgt;
+	set_bit(tgt->ltd_index, ltd->ltd_tgt_bitmap);
+	ltd->ltd_tgtnr++;
+
+	return 0;
+}
+EXPORT_SYMBOL(lu_tgt_descs_add);
+
+/**
+ * Delete target from target table
+ */
+void lu_tgt_descs_del(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt)
+{
+	LTD_TGT(ltd, tgt->ltd_index) = NULL;
+	clear_bit(tgt->ltd_index, ltd->ltd_tgt_bitmap);
+	ltd->ltd_tgtnr--;
+}
+EXPORT_SYMBOL(lu_tgt_descs_del);
-- 
1.8.3.1
