From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:45 -0500
Subject: [lustre-devel] [PATCH 357/622] lustre: lmv: reuse object alloc QoS
 code from LOD
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-358-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Reuse the same object alloc QoS code as LOD, but the QoS code is
not moved to lower layer module, instead it's copied to LMV, because
it involves almost all LMV code, which is too big a change and should
be done separately in the future.

And for LMV round-robin object allocation, because we only need to
allocate one object, use the MDT index saved and update it to next
MDT.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11213
Lustre-commit: b601eb35e97a ("LU-11213 lmv: reuse object alloc QoS code from LOD")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34657
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h          |  88 +++++++
 fs/lustre/include/obd.h                |  36 +--
 fs/lustre/lmv/Makefile                 |   2 +-
 fs/lustre/lmv/lmv_intent.c             |  10 +-
 fs/lustre/lmv/lmv_internal.h           |   8 +-
 fs/lustre/lmv/lmv_obd.c                | 106 +++++---
 fs/lustre/lmv/lmv_qos.c                | 446 +++++++++++++++++++++++++++++++++
 fs/lustre/lmv/lproc_lmv.c              | 108 +++++++-
 fs/lustre/obdclass/Makefile            |   2 +-
 fs/lustre/obdclass/lu_qos.c            | 166 ++++++++++++
 include/uapi/linux/lustre/lustre_idl.h |   2 +
 11 files changed, 896 insertions(+), 78 deletions(-)
 create mode 100644 fs/lustre/lmv/lmv_qos.c
 create mode 100644 fs/lustre/obdclass/lu_qos.c

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index c34605c..0f3e3be 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1303,5 +1303,93 @@ struct lu_kmem_descr {
 extern u32 lu_context_tags_default;
 extern u32 lu_session_tags_default;
 
+/* Generic subset of OSTs */
+struct ost_pool {
+	u32		   *op_array;	/* array of index of
+					 * lov_obd->lov_tgts
+					 */
+	unsigned int	    op_count;	/* number of OSTs in the array */
+	unsigned int	    op_size;	/* allocated size of lp_array */
+	struct rw_semaphore op_rw_sem;	/* to protect ost_pool use */
+};
+
+/* round-robin QoS data for LOD/LMV */
+struct lu_qos_rr {
+	spinlock_t		 lqr_alloc;	/* protect allocation index */
+	u32			 lqr_start_idx;	/* start index of new inode */
+	u32			 lqr_offset_idx;/* aliasing for start_idx */
+	int			 lqr_start_count;/* reseed counter */
+	struct ost_pool		 lqr_pool;	/* round-robin optimized list */
+	unsigned long		 lqr_dirty:1;	/* recalc round-robin list */
+};
+
+/* QoS data per MDS/OSS */
+struct lu_svr_qos {
+	struct obd_uuid		 lsq_uuid;	/* ptlrpc's c_remote_uuid */
+	struct list_head	 lsq_svr_list;	/* link to lq_svr_list */
+	u64			 lsq_bavail;	/* total bytes avail on svr */
+	u64			 lsq_iavail;	/* tital inode avail on svr */
+	u64			 lsq_penalty;	/* current penalty */
+	u64			 lsq_penalty_per_obj; /* penalty decrease
+						       * every obj
+						       */
+	time64_t		 lsq_used;	/* last used time, seconds */
+	u32			 lsq_tgt_count;	/* number of tgts on this svr */
+	u32			 lsq_id;	/* unique svr id */
+};
+
+/* QoS data per MDT/OST */
+struct lu_tgt_qos {
+	struct lu_svr_qos	*ltq_svr;	/* svr info */
+	u64			 ltq_penalty;	/* current penalty */
+	u64			 ltq_penalty_per_obj; /* penalty decrease
+						       * every obj
+						       */
+	u64			 ltq_weight;	/* net weighting */
+	time64_t		 ltq_used;	/* last used time, seconds */
+	bool			 ltq_usable:1;	/* usable for striping */
+};
+
+/* target descriptor */
+struct lu_tgt_desc {
+	union {
+		struct dt_device	*ltd_tgt;
+		struct obd_device	*ltd_obd;
+	};
+	struct obd_export		*ltd_exp;
+	struct obd_uuid			ltd_uuid;
+	u32				ltd_index;
+	u32				ltd_gen;
+	struct list_head		ltd_kill;
+	struct ptlrpc_thread		*ltd_recovery_thread;
+	struct mutex			ltd_fid_mutex;
+	struct lu_tgt_qos		ltd_qos; /* qos info per target */
+	struct obd_statfs		ltd_statfs;
+	time64_t			ltd_statfs_age;
+	unsigned long	ltd_active:1,	/* is this target up for requests */
+			ltd_activate:1,	/* should target be activated */
+			ltd_reap:1,	/* should this target be deleted */
+			ltd_got_update_log:1, /* Already got update log */
+			ltd_connecting:1;  /* target is connecting */
+};
+
+/* QoS data for LOD/LMV */
+struct lu_qos {
+	struct list_head	 lq_svr_list;	/* lu_svr_qos list */
+	struct rw_semaphore	 lq_rw_sem;
+	u32			 lq_active_svr_count;
+	unsigned int		 lq_prio_free;   /* priority for free space */
+	unsigned int		 lq_threshold_rr;/* priority for rr */
+	struct lu_qos_rr	 lq_rr;          /* round robin qos data */
+	unsigned long		 lq_dirty:1,     /* recalc qos data */
+				 lq_same_space:1,/* the servers all have approx.
+						  * the same space avail
+						  */
+				 lq_reset:1;     /* zero current penalties */
+};
+
+int lqos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
+int lqos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
+
 /** @} lu */
 #endif /* __LUSTRE_LU_OBJECT_H */
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index e815584..2f878d6 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -87,7 +87,7 @@ struct obd_info {
 	/* OBD_STATFS_* flags */
 	u64			oi_flags;
 	struct obd_device      *oi_obd;
-	struct lmv_tgt_desc    *oi_tgt;
+	struct lu_tgt_desc     *oi_tgt;
 	/* lsm data specific for every OSC. */
 	struct lov_stripe_md   *oi_md;
 	/* statfs data specific for every OSC, if needed at all. */
@@ -377,28 +377,10 @@ struct echo_client_obd {
 	u64			ec_unique;
 };
 
-/* Generic subset of OSTs */
-struct ost_pool {
-	u32			*op_array;  /* array of index of lov_obd->lov_tgts */
-	unsigned int		 op_count;  /* number of OSTs in the array */
-	unsigned int		 op_size;   /* allocated size of lp_array */
-	struct rw_semaphore	 op_rw_sem; /* to protect ost_pool use */
-};
-
 /* allow statfs data caching for 1 second */
 #define OBD_STATFS_CACHE_SECONDS 1
 
-struct lov_tgt_desc {
-	struct list_head	ltd_kill;
-	struct obd_uuid		ltd_uuid;
-	struct obd_device      *ltd_obd;
-	struct obd_export      *ltd_exp;
-	u32			ltd_gen;
-	u32			ltd_index;   /* index in lov_obd->tgts */
-	unsigned long		ltd_active:1,/* is this target up for requests */
-				ltd_activate:1,/* should  target be activated */
-				ltd_reap:1;  /* should this target be deleted */
-};
+#define lov_tgt_desc lu_tgt_desc
 
 struct lov_md_tgt_desc {
 	struct obd_device *lmtd_mdc;
@@ -431,16 +413,7 @@ struct lov_obd {
 	struct lov_md_tgt_desc	*lov_mdc_tgts;
 };
 
-struct lmv_tgt_desc {
-	struct obd_uuid		ltd_uuid;
-	struct obd_device	*ltd_obd;
-	struct obd_export      *ltd_exp;
-	u32			ltd_idx;
-	struct mutex		ltd_fid_mutex;
-	struct obd_statfs	ltd_statfs;
-	time64_t		ltd_statfs_age;
-	unsigned long		ltd_active:1; /* target up for requests */
-};
+#define lmv_tgt_desc lu_tgt_desc
 
 struct lmv_obd {
 	struct lu_client_fld	lmv_fld;
@@ -458,6 +431,9 @@ struct lmv_obd {
 	struct obd_connect_data	conn_data;
 	struct kobject		*lmv_tgts_kobj;
 	void			*lmv_cache;
+
+	struct lu_qos		lmv_qos;
+	u32			lmv_qos_rr_index;
 };
 
 struct niobuf_local {
diff --git a/fs/lustre/lmv/Makefile b/fs/lustre/lmv/Makefile
index ad470bf..6f9a19c 100644
--- a/fs/lustre/lmv/Makefile
+++ b/fs/lustre/lmv/Makefile
@@ -1,4 +1,4 @@
 ccflags-y += -I$(srctree)/$(src)/../include
 
 obj-$(CONFIG_LUSTRE_FS) += lmv.o
-lmv-y := lmv_obd.o lmv_intent.o lmv_fld.o lproc_lmv.o
+lmv-y := lmv_obd.o lmv_intent.o lmv_fld.o lproc_lmv.o lmv_qos.o
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 6017375..3efd977 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -108,7 +108,7 @@ static int lmv_intent_remote(struct obd_export *exp, struct lookup_intent *it,
 
 	op_data->op_bias = MDS_CROSS_REF;
 	CDEBUG(D_INODE, "REMOTE_INTENT with fid=" DFID " -> mds #%u\n",
-	       PFID(&body->mbo_fid1), tgt->ltd_idx);
+	       PFID(&body->mbo_fid1), tgt->ltd_index);
 
 	/* ask for security context upon intent */
 	if (it->it_op & (IT_LOOKUP | IT_GETATTR | IT_OPEN) &&
@@ -206,7 +206,7 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 		}
 
 		CDEBUG(D_INODE, "Revalidate slave " DFID " -> mds #%u\n",
-		       PFID(&fid), tgt->ltd_idx);
+		       PFID(&fid), tgt->ltd_index);
 
 		if (req) {
 			ptlrpc_req_finished(req);
@@ -353,7 +353,7 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
 
-		op_data->op_mds = tgt->ltd_idx;
+		op_data->op_mds = tgt->ltd_index;
 	} else {
 		LASSERT(fid_is_sane(&op_data->op_fid1));
 		LASSERT(fid_is_zero(&op_data->op_fid2));
@@ -380,7 +380,7 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	CDEBUG(D_INODE,
 	       "OPEN_INTENT with fid1=" DFID ", fid2=" DFID ", name='%s' -> mds #%u\n",
 	       PFID(&op_data->op_fid1),
-	       PFID(&op_data->op_fid2), op_data->op_name, tgt->ltd_idx);
+	       PFID(&op_data->op_fid2), op_data->op_name, tgt->ltd_index);
 
 	rc = md_intent_lock(tgt->ltd_exp, op_data, it, reqp, cb_blocking,
 			    extra_lock_flags);
@@ -465,7 +465,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	       "LOOKUP_INTENT with fid1=" DFID ", fid2=" DFID ", name='%s' -> mds #%u\n",
 	       PFID(&op_data->op_fid1), PFID(&op_data->op_fid2),
 	       op_data->op_name ? op_data->op_name : "<NULL>",
-	       tgt->ltd_idx);
+	       tgt->ltd_index);
 
 	op_data->op_bias &= ~MDS_CROSS_REF;
 
diff --git a/fs/lustre/lmv/lmv_internal.h b/fs/lustre/lmv/lmv_internal.h
index 9974ec5..c673656 100644
--- a/fs/lustre/lmv/lmv_internal.h
+++ b/fs/lustre/lmv/lmv_internal.h
@@ -60,6 +60,8 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 
 int lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 		     struct ptlrpc_request **preq);
+void lmv_activate_target(struct lmv_obd *lmv, struct lmv_tgt_desc *tgt,
+			 int activate);
 
 int lmv_statfs_check_update(struct obd_device *obd, struct lmv_tgt_desc *tgt);
 
@@ -77,7 +79,7 @@ static inline struct obd_device *lmv2obd_dev(struct lmv_obd *lmv)
 		if (!lmv->tgts[i])
 			continue;
 
-		if (lmv->tgts[i]->ltd_idx == mdt_idx) {
+		if (lmv->tgts[i]->ltd_index == mdt_idx) {
 			if (index)
 				*index = i;
 			return lmv->tgts[i];
@@ -192,6 +194,10 @@ static inline bool lmv_dir_retry_check_update(struct md_op_data *op_data)
 struct lmv_tgt_desc *lmv_locate_tgt(struct lmv_obd *lmv,
 				    struct md_op_data *op_data);
 
+/* lmv_qos.c */
+struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt);
+struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt);
+
 /* lproc_lmv.c */
 int lmv_tunables_init(struct obd_device *obd);
 
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 02dfd35..20ae322 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -57,9 +57,8 @@
 
 static int lmv_check_connect(struct obd_device *obd);
 
-static void lmv_activate_target(struct lmv_obd *lmv,
-				struct lmv_tgt_desc *tgt,
-				int activate)
+void lmv_activate_target(struct lmv_obd *lmv, struct lmv_tgt_desc *tgt,
+			 int activate)
 {
 	if (tgt->ltd_active == activate)
 		return;
@@ -315,7 +314,7 @@ static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 
 	target.ft_srv = NULL;
 	target.ft_exp = mdc_exp;
-	target.ft_idx = tgt->ltd_idx;
+	target.ft_idx = tgt->ltd_index;
 
 	fld_client_add_target(&lmv->lmv_fld, &target);
 
@@ -345,6 +344,12 @@ static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 
 	md_init_ea_size(tgt->ltd_exp, lmv->max_easize, lmv->max_def_easize);
 
+	rc = lqos_add_tgt(&lmv->lmv_qos, tgt);
+	if (rc) {
+		obd_disconnect(mdc_exp);
+		return rc;
+	}
+
 	CDEBUG(D_CONFIG, "Connected to %s(%s) successfully (%d)\n",
 	       mdc_obd->obd_name, mdc_obd->obd_uuid.uuid,
 	       atomic_read(&obd->obd_refcount));
@@ -364,6 +369,8 @@ static void lmv_del_target(struct lmv_obd *lmv, int index)
 	if (!lmv->tgts[index])
 		return;
 
+	lqos_del_tgt(&lmv->lmv_qos, lmv->tgts[index]);
+
 	kfree(lmv->tgts[index]);
 	lmv->tgts[index] = NULL;
 }
@@ -435,7 +442,7 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 	}
 
 	mutex_init(&tgt->ltd_fid_mutex);
-	tgt->ltd_idx = index;
+	tgt->ltd_index = index;
 	tgt->ltd_uuid = *uuidp;
 	tgt->ltd_active = 0;
 	lmv->tgts[index] = tgt;
@@ -1099,7 +1106,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 			return -EINVAL;
 
 		/* only files on same MDT can have their layouts swapped */
-		if (tgt1->ltd_idx != tgt2->ltd_idx)
+		if (tgt1->ltd_index != tgt2->ltd_index)
 			return -EPERM;
 
 		rc = obd_iocontrol(cmd, tgt1->ltd_exp, len, karg, uarg);
@@ -1253,6 +1260,8 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 {
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_desc *desc;
+	struct lnet_process_id lnet_id;
+	int i = 0;
 	int rc;
 
 	if (LUSTRE_CFG_BUFLEN(lcfg, 1) < 1) {
@@ -1275,13 +1284,35 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	obd_str2uuid(&lmv->desc.ld_uuid, desc->ld_uuid.uuid);
 	lmv->desc.ld_tgt_count = 0;
 	lmv->desc.ld_active_tgt_count = 0;
-	lmv->desc.ld_qos_maxage = 60;
+	lmv->desc.ld_qos_maxage = LMV_DESC_QOS_MAXAGE_DEFAULT;
 	lmv->max_def_easize = 0;
 	lmv->max_easize = 0;
 
 	spin_lock_init(&lmv->lmv_lock);
 	mutex_init(&lmv->lmv_init_mutex);
 
+	/* Set up allocation policy (QoS and RR) */
+	INIT_LIST_HEAD(&lmv->lmv_qos.lq_svr_list);
+	init_rwsem(&lmv->lmv_qos.lq_rw_sem);
+	lmv->lmv_qos.lq_dirty = 1;
+	lmv->lmv_qos.lq_rr.lqr_dirty = 1;
+	lmv->lmv_qos.lq_reset = 1;
+	/* Default priority is toward free space balance */
+	lmv->lmv_qos.lq_prio_free = 232;
+	/* Default threshold for rr (roughly 17%) */
+	lmv->lmv_qos.lq_threshold_rr = 43;
+
+	/*
+	 * initialize rr_index to lower 32bit of netid, so that client
+	 * can distribute subdirs evenly from the beginning.
+	 */
+	while (LNetGetId(i++, &lnet_id) != -ENOENT) {
+		if (LNET_NETTYP(LNET_NIDNET(lnet_id.nid)) != LOLND) {
+			lmv->lmv_qos_rr_index = (u32)lnet_id.nid;
+			break;
+		}
+	}
+
 	rc = lmv_tunables_init(obd);
 	if (rc)
 		CWARN("%s: error adding LMV sysfs/debugfs files: rc = %d\n",
@@ -1462,6 +1493,7 @@ static int lmv_statfs_update(void *cookie, int rc)
 		tgt->ltd_statfs = *osfs;
 		tgt->ltd_statfs_age = ktime_get_seconds();
 		spin_unlock(&lmv->lmv_lock);
+		lmv->lmv_qos.lq_dirty = 1;
 	}
 
 	return rc;
@@ -1541,7 +1573,7 @@ static int lmv_getattr(struct obd_export *exp, struct md_op_data *op_data,
 		return PTR_ERR(tgt);
 
 	if (op_data->op_flags & MF_GET_MDT_IDX) {
-		op_data->op_mds = tgt->ltd_idx;
+		op_data->op_mds = tgt->ltd_index;
 		return 0;
 	}
 
@@ -1585,17 +1617,6 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 	return md_close(tgt->ltd_exp, op_data, mod, request);
 }
 
-static struct lmv_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
-{
-	static unsigned int rr_index;
-
-	/* locate MDT round-robin is the first step */
-	*mdt = rr_index % lmv->tgts_size;
-	rr_index++;
-
-	return lmv->tgts[*mdt];
-}
-
 static struct lmv_tgt_desc *
 lmv_locate_tgt_by_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
 		       const char *name, int namelen, struct lu_fid *fid,
@@ -1609,7 +1630,7 @@ static struct lmv_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
 		if (IS_ERR(tgt))
 			return tgt;
 
-		*mds = tgt->ltd_idx;
+		*mds = tgt->ltd_index;
 		return tgt;
 	}
 
@@ -1698,12 +1719,18 @@ struct lmv_tgt_desc *
 		   lmv_dir_space_hashed(op_data->op_default_mea1) &&
 		   !lmv_dir_striped(lsm)) {
 		tgt = lmv_locate_tgt_qos(lmv, &op_data->op_mds);
+		if (tgt == ERR_PTR(-EAGAIN))
+			tgt = lmv_locate_tgt_rr(lmv, &op_data->op_mds);
 		/*
 		 * only update statfs when mkdir under dir with "space" hash,
 		 * this means the cached statfs may be stale, and current mkdir
 		 * may not follow QoS accurately, but it's not serious, and it
 		 * avoids periodic statfs when client doesn't mkdir under
 		 * "space" hashed directories.
+		 *
+		 * TODO: after MDT support QoS object allocation, also update
+		 * statfs for 'lfs mkdir -i -1 ...", currently it's done in user
+		 * space.
 		 */
 		if (!IS_ERR(tgt)) {
 			struct obd_device *obd;
@@ -1823,7 +1850,7 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
 
-		op_data->op_mds = tgt->ltd_idx;
+		op_data->op_mds = tgt->ltd_index;
 	}
 
 	CDEBUG(D_INODE, "CREATE obj " DFID " -> mds #%x\n",
@@ -1858,7 +1885,7 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		return PTR_ERR(tgt);
 
 	CDEBUG(D_INODE, "ENQUEUE on " DFID " -> mds #%u\n",
-	       PFID(&op_data->op_fid1), tgt->ltd_idx);
+	       PFID(&op_data->op_fid1), tgt->ltd_index);
 
 	return md_enqueue(tgt->ltd_exp, einfo, policy, op_data, lockh,
 			  extra_lock_flags);
@@ -1881,7 +1908,7 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 
 	CDEBUG(D_INODE, "GETATTR_NAME for %*s on " DFID " -> mds #%u\n",
 	       (int)op_data->op_namelen, op_data->op_name,
-	       PFID(&op_data->op_fid1), tgt->ltd_idx);
+	       PFID(&op_data->op_fid1), tgt->ltd_index);
 
 	rc = md_getattr_name(tgt->ltd_exp, op_data, preq);
 	if (rc == -ENOENT && lmv_dir_retry_check_update(op_data)) {
@@ -1935,7 +1962,7 @@ static int lmv_early_cancel(struct obd_export *exp, struct lmv_tgt_desc *tgt,
 			return PTR_ERR(tgt);
 	}
 
-	if (tgt->ltd_idx != op_tgt) {
+	if (tgt->ltd_index != op_tgt) {
 		CDEBUG(D_INODE, "EARLY_CANCEL on " DFID "\n", PFID(fid));
 		policy.l_inodebits.bits = bits;
 		rc = md_cancel_unused(tgt->ltd_exp, fid, &policy,
@@ -1981,7 +2008,7 @@ static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 	 * Cancel UPDATE lock on child (fid1).
 	 */
 	op_data->op_flags |= MF_MDC_CANCEL_FID2;
-	rc = lmv_early_cancel(exp, NULL, op_data, tgt->ltd_idx, LCK_EX,
+	rc = lmv_early_cancel(exp, NULL, op_data, tgt->ltd_index, LCK_EX,
 			      MDS_INODELOCK_UPDATE, MF_MDC_CANCEL_FID1);
 	if (rc != 0)
 		return rc;
@@ -2075,7 +2102,7 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 		return PTR_ERR(child_tgt);
 
 	if (!S_ISDIR(op_data->op_mode) && tp_tgt)
-		rc = __lmv_fid_alloc(lmv, &target_fid, tp_tgt->ltd_idx);
+		rc = __lmv_fid_alloc(lmv, &target_fid, tp_tgt->ltd_index);
 	else
 		rc = lmv_fid_alloc(NULL, exp, &target_fid, op_data);
 	if (rc)
@@ -2101,7 +2128,7 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 	}
 
 	/* cancel UPDATE lock of parent master object */
-	rc = lmv_early_cancel(exp, parent_tgt, op_data, tgt->ltd_idx, LCK_EX,
+	rc = lmv_early_cancel(exp, parent_tgt, op_data, tgt->ltd_index, LCK_EX,
 			      MDS_INODELOCK_UPDATE, MF_MDC_CANCEL_FID1);
 	if (rc)
 		return rc;
@@ -2126,14 +2153,14 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_fid4 = target_fid;
 
 	/* cancel UPDATE locks of target parent */
-	rc = lmv_early_cancel(exp, tp_tgt, op_data, tgt->ltd_idx, LCK_EX,
+	rc = lmv_early_cancel(exp, tp_tgt, op_data, tgt->ltd_index, LCK_EX,
 			      MDS_INODELOCK_UPDATE, MF_MDC_CANCEL_FID2);
 	if (rc)
 		return rc;
 
 	/* cancel LOOKUP lock of source if source is remote object */
 	if (child_tgt != sp_tgt) {
-		rc = lmv_early_cancel(exp, sp_tgt, op_data, tgt->ltd_idx,
+		rc = lmv_early_cancel(exp, sp_tgt, op_data, tgt->ltd_index,
 				      LCK_EX, MDS_INODELOCK_LOOKUP,
 				      MF_MDC_CANCEL_FID3);
 		if (rc)
@@ -2141,7 +2168,7 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 	}
 
 	/* cancel ELC locks of source */
-	rc = lmv_early_cancel(exp, child_tgt, op_data, tgt->ltd_idx, LCK_EX,
+	rc = lmv_early_cancel(exp, child_tgt, op_data, tgt->ltd_index, LCK_EX,
 			      MDS_INODELOCK_ELC, MF_MDC_CANCEL_FID3);
 	if (rc)
 		return rc;
@@ -2201,7 +2228,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_flags |= MF_MDC_CANCEL_FID4;
 
 	/* cancel UPDATE locks of target parent */
-	rc = lmv_early_cancel(exp, tp_tgt, op_data, tgt->ltd_idx, LCK_EX,
+	rc = lmv_early_cancel(exp, tp_tgt, op_data, tgt->ltd_index, LCK_EX,
 			      MDS_INODELOCK_UPDATE, MF_MDC_CANCEL_FID2);
 	if (rc != 0)
 		return rc;
@@ -2210,7 +2237,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 		/* cancel LOOKUP lock of target on target parent */
 		if (tgt != tp_tgt) {
 			rc = lmv_early_cancel(exp, tp_tgt, op_data,
-					      tgt->ltd_idx, LCK_EX,
+					      tgt->ltd_index, LCK_EX,
 					      MDS_INODELOCK_LOOKUP,
 					      MF_MDC_CANCEL_FID4);
 			if (rc != 0)
@@ -2224,7 +2251,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 			return PTR_ERR(src_tgt);
 
 		/* cancel ELC locks of source */
-		rc = lmv_early_cancel(exp, src_tgt, op_data, tgt->ltd_idx,
+		rc = lmv_early_cancel(exp, src_tgt, op_data, tgt->ltd_index,
 				      LCK_EX, MDS_INODELOCK_ELC,
 				      MF_MDC_CANCEL_FID3);
 		if (rc != 0)
@@ -2239,7 +2266,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 		return PTR_ERR(sp_tgt);
 
 	/* cancel UPDATE locks of source parent */
-	rc = lmv_early_cancel(exp, sp_tgt, op_data, tgt->ltd_idx, LCK_EX,
+	rc = lmv_early_cancel(exp, sp_tgt, op_data, tgt->ltd_index, LCK_EX,
 			      MDS_INODELOCK_UPDATE, MF_MDC_CANCEL_FID1);
 	if (rc != 0)
 		return rc;
@@ -2248,7 +2275,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 		/* cancel LOOKUP lock of source on source parent */
 		if (src_tgt != sp_tgt) {
 			rc = lmv_early_cancel(exp, sp_tgt, op_data,
-					      tgt->ltd_idx, LCK_EX,
+					      tgt->ltd_index, LCK_EX,
 					      MDS_INODELOCK_LOOKUP,
 					      MF_MDC_CANCEL_FID3);
 			if (rc != 0)
@@ -2293,7 +2320,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 		/* cancel LOOKUP lock of target on target parent */
 		if (tgt != tp_tgt) {
 			rc = lmv_early_cancel(exp, tp_tgt, op_data,
-					      tgt->ltd_idx, LCK_EX,
+					      tgt->ltd_index, LCK_EX,
 					      MDS_INODELOCK_LOOKUP,
 					      MF_MDC_CANCEL_FID4);
 			if (rc != 0)
@@ -2781,17 +2808,18 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_flags |= MF_MDC_CANCEL_FID1 | MF_MDC_CANCEL_FID3;
 
 	if (parent_tgt != tgt)
-		rc = lmv_early_cancel(exp, parent_tgt, op_data, tgt->ltd_idx,
+		rc = lmv_early_cancel(exp, parent_tgt, op_data, tgt->ltd_index,
 				      LCK_EX, MDS_INODELOCK_LOOKUP,
 				      MF_MDC_CANCEL_FID3);
 
-	rc = lmv_early_cancel(exp, NULL, op_data, tgt->ltd_idx, LCK_EX,
+	rc = lmv_early_cancel(exp, NULL, op_data, tgt->ltd_index, LCK_EX,
 			      MDS_INODELOCK_ELC, MF_MDC_CANCEL_FID3);
 	if (rc)
 		return rc;
 
 	CDEBUG(D_INODE, "unlink with fid=" DFID "/" DFID " -> mds #%u\n",
-	       PFID(&op_data->op_fid1), PFID(&op_data->op_fid2), tgt->ltd_idx);
+	       PFID(&op_data->op_fid1), PFID(&op_data->op_fid2),
+	       tgt->ltd_index);
 
 	rc = md_unlink(tgt->ltd_exp, op_data, request);
 	if (rc == -ENOENT && lmv_dir_retry_check_update(op_data)) {
diff --git a/fs/lustre/lmv/lmv_qos.c b/fs/lustre/lmv/lmv_qos.c
new file mode 100644
index 0000000..e323398
--- /dev/null
+++ b/fs/lustre/lmv/lmv_qos.c
@@ -0,0 +1,446 @@
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
+ * lustre/lmv/lmv_qos.c
+ *
+ * LMV QoS.
+ * These are the only exported functions, they provide some generic
+ * infrastructure for object allocation QoS
+ *
+ */
+
+#define DEBUG_SUBSYSTEM S_LMV
+
+#include <asm/div64.h>
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <lustre_swab.h>
+#include <obd_class.h>
+
+#include "lmv_internal.h"
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
+ * Calculate penalties per-tgt and per-server
+ *
+ * Re-calculate penalties when the configuration changes, active targets
+ * change and after statfs refresh (all these are reflected by lq_dirty flag).
+ * On every MDT and MDS: decay the penalty by half for every 8x the update
+ * interval that the device has been idle. That gives lots of time for the
+ * statfs information to be updated (which the penalty is only a proxy for),
+ * and avoids penalizing MDS/MDTs under light load.
+ * See lmv_qos_calc_weight() for how penalties are factored into the weight.
+ *
+ * @lmv			LMV device
+ *
+ * Return:		0 on success
+ *			-EAGAIN	if the number of MDTs isn't enough or all
+ *			MDT spaces are almost the same
+ */
+static int lmv_qos_calc_ppts(struct lmv_obd *lmv)
+{
+	struct lu_qos *qos = &lmv->lmv_qos;
+	struct lu_tgt_desc *tgt;
+	struct lu_svr_qos *svr;
+	u64 ba_max, ba_min, ba;
+	u64 ia_max, ia_min, ia;
+	u32 num_active;
+	unsigned int i;
+	int prio_wide;
+	time64_t now, age;
+	u32 maxage = lmv->desc.ld_qos_maxage;
+	int rc = 0;
+
+
+	if (!qos->lq_dirty)
+		goto out;
+
+	num_active = lmv->desc.ld_active_tgt_count;
+	if (num_active < 2) {
+		rc = -EAGAIN;
+		goto out;
+	}
+
+	/* find bavail on each server */
+	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
+		svr->lsq_bavail = 0;
+		svr->lsq_iavail = 0;
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
+	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
+		tgt = lmv->tgts[i];
+		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
+			continue;
+
+		/* bavail >> 16 to avoid overflow */
+		ba = tgt_statfs_bavail(tgt) >> 16;
+		if (!ba)
+			continue;
+
+		ba_min = min(ba, ba_min);
+		ba_max = max(ba, ba_max);
+
+		/* iavail >> 8 to avoid overflow */
+		ia = tgt_statfs_iavail(tgt) >> 8;
+		if (!ia)
+			continue;
+
+		ia_min = min(ia, ia_min);
+		ia_max = max(ia, ia_max);
+
+		/* Count the number of usable MDS's */
+		if (tgt->ltd_qos.ltq_svr->lsq_bavail == 0)
+			qos->lq_active_svr_count++;
+		tgt->ltd_qos.ltq_svr->lsq_bavail += ba;
+		tgt->ltd_qos.ltq_svr->lsq_iavail += ia;
+
+		/*
+		 * per-MDT penalty is
+		 * prio * bavail * iavail / (num_tgt - 1) / 2
+		 */
+		tgt->ltd_qos.ltq_penalty_per_obj = prio_wide * ba * ia;
+		do_div(tgt->ltd_qos.ltq_penalty_per_obj, num_active - 1);
+		tgt->ltd_qos.ltq_penalty_per_obj >>= 1;
+
+		age = (now - tgt->ltd_qos.ltq_used) >> 3;
+		if (qos->lq_reset || age > 32 * maxage)
+			tgt->ltd_qos.ltq_penalty = 0;
+		else if (age > maxage)
+			/* Decay tgt penalty. */
+			tgt->ltd_qos.ltq_penalty >>= (age / maxage);
+	}
+
+	num_active = qos->lq_active_svr_count;
+	if (num_active < 2) {
+		/*
+		 * If there's only 1 MDS, we can't penalize it, so instead
+		 * we have to double the MDT penalty
+		 */
+		num_active = 2;
+		for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
+			tgt = lmv->tgts[i];
+			if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
+				continue;
+
+			tgt->ltd_qos.ltq_penalty_per_obj <<= 1;
+		}
+	}
+
+	/*
+	 * Per-MDS penalty is
+	 * prio * bavail * iavail / server_tgts / (num_svr - 1) / 2
+	 */
+	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
+		ba = svr->lsq_bavail;
+		ia = svr->lsq_iavail;
+		svr->lsq_penalty_per_obj = prio_wide * ba  * ia;
+		do_div(ba, svr->lsq_tgt_count * (num_active - 1));
+		svr->lsq_penalty_per_obj >>= 1;
+
+		age = (now - svr->lsq_used) >> 3;
+		if (qos->lq_reset || age > 32 * maxage)
+			svr->lsq_penalty = 0;
+		else if (age > maxage)
+			/* Decay server penalty. */
+			svr->lsq_penalty >>= age / maxage;
+	}
+
+	qos->lq_dirty = 0;
+	qos->lq_reset = 0;
+
+	/*
+	 * If each MDT has almost same free space, do rr allocation for better
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
+
+static inline bool lmv_qos_is_usable(struct lmv_obd *lmv)
+{
+	if (!lmv->lmv_qos.lq_dirty && lmv->lmv_qos.lq_same_space)
+		return false;
+
+	if (lmv->desc.ld_active_tgt_count < 2)
+		return false;
+
+	return true;
+}
+
+/**
+ * Calculate weight for a given MDT.
+ *
+ * The final MDT weight is bavail >> 16 * iavail >> 8 minus the MDT and MDS
+ * penalties.  See lmv_qos_calc_ppts() for how penalties are calculated.
+ *
+ * \param[in] tgt	MDT target descriptor
+ */
+static void lmv_qos_calc_weight(struct lu_tgt_desc *tgt)
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
+
+/**
+ * Re-calculate weights.
+ *
+ * The function is called when some target was used for a new object. In
+ * this case we should re-calculate all the weights to keep new allocations
+ * balanced well.
+ *
+ * \param[in] lmv	LMV device
+ * \param[in] tgt	target where a new object was placed
+ * \param[out] total_wt	new total weight for the pool
+ *
+ * \retval		0
+ */
+static int lmv_qos_used(struct lmv_obd *lmv, struct lu_tgt_desc *tgt,
+			u64 *total_wt)
+{
+	struct lu_tgt_qos *ltq;
+	struct lu_svr_qos *svr;
+	unsigned int i;
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
+	/* mark the MDS and MDT as recently used */
+	ltq->ltq_used = svr->lsq_used = ktime_get_real_seconds();
+
+	/* Set max penalties for this MDT and MDS */
+	ltq->ltq_penalty += ltq->ltq_penalty_per_obj *
+			    lmv->desc.ld_active_tgt_count;
+	svr->lsq_penalty += svr->lsq_penalty_per_obj *
+		lmv->lmv_qos.lq_active_svr_count;
+
+	/* Decrease all MDS penalties */
+	list_for_each_entry(svr, &lmv->lmv_qos.lq_svr_list, lsq_svr_list) {
+		if (svr->lsq_penalty < svr->lsq_penalty_per_obj)
+			svr->lsq_penalty = 0;
+		else
+			svr->lsq_penalty -= svr->lsq_penalty_per_obj;
+	}
+
+	*total_wt = 0;
+	/* Decrease all MDT penalties */
+	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
+		ltq = &lmv->tgts[i]->ltd_qos;
+		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
+			continue;
+
+		if (ltq->ltq_penalty < ltq->ltq_penalty_per_obj)
+			ltq->ltq_penalty = 0;
+		else
+			ltq->ltq_penalty -= ltq->ltq_penalty_per_obj;
+
+		lmv_qos_calc_weight(lmv->tgts[i]);
+
+		/* Recalc the total weight of usable osts */
+		if (ltq->ltq_usable)
+			*total_wt += ltq->ltq_weight;
+
+		CDEBUG(D_OTHER,
+		       "recalc tgt %d usable=%d avail=%llu tgtppo=%llu tgtp=%llu svrppo=%llu svrp=%llu wt=%llu\n",
+		       i, ltq->ltq_usable,
+		       tgt_statfs_bavail(tgt) >> 10,
+		       ltq->ltq_penalty_per_obj >> 10,
+		       ltq->ltq_penalty >> 10,
+		       ltq->ltq_svr->lsq_penalty_per_obj >> 10,
+		       ltq->ltq_svr->lsq_penalty >> 10,
+		       ltq->ltq_weight >> 10);
+	}
+
+	return 0;
+}
+
+struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
+{
+	struct lu_tgt_desc *tgt;
+	u64 total_weight = 0;
+	u64 cur_weight = 0;
+	u64 rand;
+	int i;
+	int rc;
+
+	if (!lmv_qos_is_usable(lmv))
+		return ERR_PTR(-EAGAIN);
+
+	down_write(&lmv->lmv_qos.lq_rw_sem);
+
+	if (!lmv_qos_is_usable(lmv)) {
+		tgt = ERR_PTR(-EAGAIN);
+		goto unlock;
+	}
+
+	rc = lmv_qos_calc_ppts(lmv);
+	if (rc) {
+		tgt = ERR_PTR(rc);
+		goto unlock;
+	}
+
+	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
+		tgt = lmv->tgts[i];
+		if (!tgt)
+			continue;
+
+		tgt->ltd_qos.ltq_usable = 0;
+		if (!tgt->ltd_exp || !tgt->ltd_active)
+			continue;
+
+		tgt->ltd_qos.ltq_usable = 1;
+		lmv_qos_calc_weight(tgt);
+		total_weight += tgt->ltd_qos.ltq_weight;
+	}
+
+	if (total_weight) {
+#if BITS_PER_LONG == 32
+		/*
+		 * If total_weight > 32-bit, first generate the high
+		 * 32 bits of the random number, then add in the low
+		 * 32 bits (truncated to the upper limit, if needed)
+		 */
+		if (total_weight > 0xffffffffULL)
+			rand = (u64)(prandom_u32_max(
+				(unsigned int)(total_weight >> 32)) << 32;
+		else
+			rand = 0;
+
+		if (rand == (total_weight & 0xffffffff00000000ULL))
+			rand |= prandom_u32_max((unsigned int)total_weight);
+		else
+			rand |= prandom_u32();
+
+#else
+		rand = ((u64)prandom_u32() << 32 | prandom_u32()) %
+			total_weight;
+#endif
+	} else {
+		rand = 0;
+	}
+
+	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
+		tgt = lmv->tgts[i];
+
+		if (!tgt || !tgt->ltd_qos.ltq_usable)
+			continue;
+
+		cur_weight += tgt->ltd_qos.ltq_weight;
+		if (cur_weight < rand)
+			continue;
+
+		*mdt = tgt->ltd_index;
+		lmv_qos_used(lmv, tgt, &total_weight);
+		rc = 0;
+		goto unlock;
+	}
+
+	/* no proper target found */
+	tgt = ERR_PTR(-EAGAIN);
+	goto unlock;
+unlock:
+	up_write(&lmv->lmv_qos.lq_rw_sem);
+
+	return tgt;
+}
+
+struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt)
+{
+	struct lu_tgt_desc *tgt;
+	int i;
+
+	spin_lock(&lmv->lmv_qos.lq_rr.lqr_alloc);
+	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
+		tgt = lmv->tgts[(i + lmv->lmv_qos_rr_index) %
+				lmv->desc.ld_tgt_count];
+		if (tgt && tgt->ltd_exp && tgt->ltd_active) {
+			*mdt = tgt->ltd_index;
+			lmv->lmv_qos_rr_index =
+				(i + lmv->lmv_qos_rr_index + 1) %
+				lmv->desc.ld_tgt_count;
+			spin_unlock(&lmv->lmv_qos.lq_rr.lqr_alloc);
+
+			return tgt;
+		}
+	}
+	spin_unlock(&lmv->lmv_qos.lq_rr.lqr_alloc);
+
+	return ERR_PTR(-ENODEV);
+}
diff --git a/fs/lustre/lmv/lproc_lmv.c b/fs/lustre/lmv/lproc_lmv.c
index 170ed564..659ebeb 100644
--- a/fs/lustre/lmv/lproc_lmv.c
+++ b/fs/lustre/lmv/lproc_lmv.c
@@ -76,6 +76,109 @@ static ssize_t desc_uuid_show(struct kobject *kobj, struct attribute *attr,
 }
 LUSTRE_RO_ATTR(desc_uuid);
 
+static ssize_t qos_maxage_show(struct kobject *kobj,
+			       struct attribute *attr,
+			       char *buf)
+{
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+
+	return sprintf(buf, "%u\n", dev->u.lmv.desc.ld_qos_maxage);
+}
+
+static ssize_t qos_maxage_store(struct kobject *kobj,
+				struct attribute *attr,
+				const char *buffer,
+				size_t count)
+{
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	unsigned int val;
+	int rc;
+
+	rc = kstrtouint(buffer, 0, &val);
+	if (rc)
+		return rc;
+
+	dev->u.lmv.desc.ld_qos_maxage = val;
+
+	return count;
+}
+LUSTRE_RW_ATTR(qos_maxage);
+
+static ssize_t qos_prio_free_show(struct kobject *kobj,
+				  struct attribute *attr,
+				  char *buf)
+{
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+
+	return sprintf(buf, "%u%%\n",
+		       (dev->u.lmv.lmv_qos.lq_prio_free * 100 + 255) >> 8);
+}
+
+static ssize_t qos_prio_free_store(struct kobject *kobj,
+				   struct attribute *attr,
+				   const char *buffer,
+				   size_t count)
+{
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct lmv_obd *lmv = &dev->u.lmv;
+	unsigned int val;
+	int rc;
+
+	rc = kstrtouint(buffer, 0, &val);
+	if (rc)
+		return rc;
+
+	if (val > 100)
+		return -EINVAL;
+
+	lmv->lmv_qos.lq_prio_free = (val << 8) / 100;
+	lmv->lmv_qos.lq_dirty = 1;
+	lmv->lmv_qos.lq_reset = 1;
+
+	return count;
+}
+LUSTRE_RW_ATTR(qos_prio_free);
+
+static ssize_t qos_threshold_rr_show(struct kobject *kobj,
+				     struct attribute *attr,
+				     char *buf)
+{
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+
+	return sprintf(buf, "%u%%\n",
+		       (dev->u.lmv.lmv_qos.lq_threshold_rr * 100 + 255) >> 8);
+}
+
+static ssize_t qos_threshold_rr_store(struct kobject *kobj,
+				      struct attribute *attr,
+				      const char *buffer,
+				      size_t count)
+{
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct lmv_obd *lmv = &dev->u.lmv;
+	unsigned int val;
+	int rc;
+
+	rc = kstrtouint(buffer, 0, &val);
+	if (rc)
+		return rc;
+
+	if (val > 100)
+		return -EINVAL;
+
+	lmv->lmv_qos.lq_threshold_rr = (val << 8) / 100;
+	lmv->lmv_qos.lq_dirty = 1;
+
+	return count;
+}
+LUSTRE_RW_ATTR(qos_threshold_rr);
+
 static void *lmv_tgt_seq_start(struct seq_file *p, loff_t *pos)
 {
 	struct obd_device *dev = p->private;
@@ -117,7 +220,7 @@ static int lmv_tgt_seq_show(struct seq_file *p, void *v)
 		return 0;
 
 	seq_printf(p, "%u: %s %sACTIVE\n",
-		   tgt->ltd_idx, tgt->ltd_uuid.uuid,
+		   tgt->ltd_index, tgt->ltd_uuid.uuid,
 		   tgt->ltd_active ? "" : "IN");
 	return 0;
 }
@@ -156,6 +259,9 @@ static int lmv_target_seq_open(struct inode *inode, struct file *file)
 	&lustre_attr_activeobd.attr,
 	&lustre_attr_desc_uuid.attr,
 	&lustre_attr_numobd.attr,
+	&lustre_attr_qos_maxage.attr,
+	&lustre_attr_qos_prio_free.attr,
+	&lustre_attr_qos_threshold_rr.attr,
 	NULL,
 };
 
diff --git a/fs/lustre/obdclass/Makefile b/fs/lustre/obdclass/Makefile
index 25d2e1d..6d762ed 100644
--- a/fs/lustre/obdclass/Makefile
+++ b/fs/lustre/obdclass/Makefile
@@ -8,4 +8,4 @@ obdclass-y := llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
 	      obdo.o obd_config.o obd_mount.o lu_object.o lu_ref.o \
 	      cl_object.o cl_page.o cl_lock.o cl_io.o kernelcomm.o \
-	      jobid.o integrity.o obd_cksum.o
+	      jobid.o integrity.o obd_cksum.o lu_qos.o
diff --git a/fs/lustre/obdclass/lu_qos.c b/fs/lustre/obdclass/lu_qos.c
new file mode 100644
index 0000000..4ee3f59
--- /dev/null
+++ b/fs/lustre/obdclass/lu_qos.c
@@ -0,0 +1,166 @@
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
+ * lustre/obdclass/lu_qos.c
+ *
+ * Lustre QoS.
+ * These are the only exported functions, they provide some generic
+ * infrastructure for object allocation QoS
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
+ * Add a new target to Quality of Service (QoS) target table.
+ *
+ * Add a new MDT/OST target to the structure representing an OSS. Resort the
+ * list of known MDSs/OSSs by the number of MDTs/OSTs attached to each MDS/OSS.
+ * The MDS/OSS list is protected internally and no external locking is required.
+ *
+ * @qos		lu_qos data
+ * @ltd		target description
+ *
+ * Return:	0 on success
+ *		-ENOMEM	on error
+ */
+int lqos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd)
+{
+	struct lu_svr_qos *svr = NULL;
+	struct lu_svr_qos *tempsvr;
+	struct obd_export *exp = ltd->ltd_exp;
+	int found = 0;
+	u32 id = 0;
+	int rc = 0;
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
+		svr = kmalloc(sizeof(*svr), GFP_NOFS);
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
+	ltd->ltd_qos.ltq_svr = svr;
+
+	CDEBUG(D_OTHER, "add tgt %s to server %s (%d targets)\n",
+	       obd_uuid2str(&ltd->ltd_uuid), obd_uuid2str(&svr->lsq_uuid),
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
+EXPORT_SYMBOL(lqos_add_tgt);
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
+ *		-ENOENT	if no server was found
+ */
+int lqos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd)
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
+EXPORT_SYMBOL(lqos_del_tgt);
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 86395b7..a26f3ae 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1931,6 +1931,8 @@ struct mdt_rec_reint {
 	__u16		rr_padding_4; /* also fix lustre_swab_mdt_rec_reint */
 };
 
+#define LMV_DESC_QOS_MAXAGE_DEFAULT 60  /* Seconds */
+
 /* lmv structures */
 struct lmv_desc {
 	__u32 ld_tgt_count;		/* how many MDS's */
-- 
1.8.3.1
