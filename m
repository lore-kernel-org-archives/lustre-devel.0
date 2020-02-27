From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:01 -0500
Subject: [lustre-devel] [PATCH 313/622] lustre: mdc: add async statfs
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-314-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Add obd_statfs_async() interface for MDC, the statfs request
is sent by ptlrpcd.

This statfs result is for each MDT separately, it's different
from current cached statfs which is aggregated statfs of all
MDTs.

The max age of statfs result is decided by lmv_desc.ld_qos_maxage.

It will deactivate MDC on failure, and activate MDC on success.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11213
Lustre-commit: 7f412954ad38 ("LU-11213 mdc: add async statfs")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34359
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h       |  4 ++++
 fs/lustre/include/obd_class.h | 18 +++-------------
 fs/lustre/lmv/lmv_internal.h  |  2 ++
 fs/lustre/lmv/lmv_obd.c       | 44 +++++++++++++++++++++++++++++++++++++++
 fs/lustre/mdc/mdc_request.c   | 48 +++++++++++++++++++++++++++++++++++++++++++
 fs/lustre/osc/osc_request.c   | 16 +++++++++++++++
 6 files changed, 117 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index fb77df7..e815584 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -86,6 +86,8 @@ static inline void loi_kms_set(struct lov_oinfo *oinfo, u64 kms)
 struct obd_info {
 	/* OBD_STATFS_* flags */
 	u64			oi_flags;
+	struct obd_device      *oi_obd;
+	struct lmv_tgt_desc    *oi_tgt;
 	/* lsm data specific for every OSC. */
 	struct lov_stripe_md   *oi_md;
 	/* statfs data specific for every OSC, if needed at all. */
@@ -435,6 +437,8 @@ struct lmv_tgt_desc {
 	struct obd_export      *ltd_exp;
 	u32			ltd_idx;
 	struct mutex		ltd_fid_mutex;
+	struct obd_statfs	ltd_statfs;
+	time64_t		ltd_statfs_age;
 	unsigned long		ltd_active:1; /* target up for requests */
 };
 
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index a890d00..58c743c 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -912,21 +912,9 @@ static inline int obd_statfs_async(struct obd_export *exp,
 
 	CDEBUG(D_SUPER, "%s: age %lld, max_age %lld\n",
 	       obd->obd_name, obd->obd_osfs_age, max_age);
-	if (obd->obd_osfs_age < max_age) {
-		rc = OBP(obd, statfs_async)(exp, oinfo, max_age, rqset);
-	} else {
-		CDEBUG(D_SUPER,
-		       "%s: use %p cache blocks %llu/%llu objects %llu/%llu\n",
-		       obd->obd_name, &obd->obd_osfs,
-		       obd->obd_osfs.os_bavail, obd->obd_osfs.os_blocks,
-		       obd->obd_osfs.os_ffree, obd->obd_osfs.os_files);
-		spin_lock(&obd->obd_osfs_lock);
-		memcpy(oinfo->oi_osfs, &obd->obd_osfs, sizeof(*oinfo->oi_osfs));
-		spin_unlock(&obd->obd_osfs_lock);
-		oinfo->oi_flags |= OBD_STATFS_FROM_CACHE;
-		if (oinfo->oi_cb_up)
-			oinfo->oi_cb_up(oinfo, 0);
-	}
+
+	rc = OBP(obd, statfs_async)(exp, oinfo, max_age, rqset);
+
 	return rc;
 }
 
diff --git a/fs/lustre/lmv/lmv_internal.h b/fs/lustre/lmv/lmv_internal.h
index e434919..b4c5297 100644
--- a/fs/lustre/lmv/lmv_internal.h
+++ b/fs/lustre/lmv/lmv_internal.h
@@ -61,6 +61,8 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 int lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 		     struct ptlrpc_request **preq);
 
+int lmv_statfs_check_update(struct obd_device *obd, struct lmv_tgt_desc *tgt);
+
 static inline struct obd_device *lmv2obd_dev(struct lmv_obd *lmv)
 {
 	return container_of_safe(lmv, struct obd_device, u.lmv);
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 48cd41a..4365533 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -349,6 +349,8 @@ static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 	       mdc_obd->obd_name, mdc_obd->obd_uuid.uuid,
 	       atomic_read(&obd->obd_refcount));
 
+	lmv_statfs_check_update(obd, tgt);
+
 	if (lmv->lmv_tgts_kobj)
 		/* Even if we failed to create the link, that's fine */
 		rc = sysfs_create_link(lmv->lmv_tgts_kobj,
@@ -1276,6 +1278,7 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	obd_str2uuid(&lmv->desc.ld_uuid, desc->ld_uuid.uuid);
 	lmv->desc.ld_tgt_count = 0;
 	lmv->desc.ld_active_tgt_count = 0;
+	lmv->desc.ld_qos_maxage = 60;
 	lmv->max_def_easize = 0;
 	lmv->max_easize = 0;
 
@@ -1445,6 +1448,47 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 	return rc;
 }
 
+static int lmv_statfs_update(void *cookie, int rc)
+{
+	struct obd_info *oinfo = cookie;
+	struct obd_device *obd = oinfo->oi_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt = oinfo->oi_tgt;
+	struct obd_statfs *osfs = oinfo->oi_osfs;
+
+	/*
+	 * NB: don't deactivate TGT upon error, because we may not trigger async
+	 * statfs any longer, then there is no chance to activate TGT.
+	 */
+	if (!rc) {
+		spin_lock(&lmv->lmv_lock);
+		tgt->ltd_statfs = *osfs;
+		tgt->ltd_statfs_age = ktime_get_seconds();
+		spin_unlock(&lmv->lmv_lock);
+	}
+
+	return rc;
+}
+
+/* update tgt statfs async if it's ld_qos_maxage old */
+int lmv_statfs_check_update(struct obd_device *obd, struct lmv_tgt_desc *tgt)
+{
+	struct obd_info oinfo = {
+		.oi_obd	= obd,
+		.oi_tgt = tgt,
+		.oi_cb_up = lmv_statfs_update,
+	};
+	int rc;
+
+	if (ktime_get_seconds() - tgt->ltd_statfs_age <
+	    obd->u.lmv.desc.ld_qos_maxage)
+		return 0;
+
+	rc = obd_statfs_async(tgt->ltd_exp, &oinfo, 0, NULL);
+
+	return rc;
+}
+
 static int lmv_get_root(struct obd_export *exp, const char *fileset,
 			struct lu_fid *fid)
 {
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index c834891..a26efa1 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -1570,6 +1570,53 @@ static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
 	goto out_unlock;
 }
 
+static int mdc_statfs_interpret(const struct lu_env *env,
+				struct ptlrpc_request *req, void *args, int rc)
+{
+	struct obd_info *oinfo = args;
+	struct obd_statfs *osfs;
+
+	if (!rc) {
+		osfs = req_capsule_server_get(&req->rq_pill, &RMF_OBD_STATFS);
+		if (!osfs)
+			return -EPROTO;
+
+		oinfo->oi_osfs = osfs;
+
+		CDEBUG(D_CACHE,
+		       "blocks=%llu free=%llu avail=%llu objects=%llu free=%llu state=%x\n",
+			osfs->os_blocks, osfs->os_bfree, osfs->os_bavail,
+			osfs->os_files, osfs->os_ffree, osfs->os_state);
+	}
+
+	oinfo->oi_cb_up(oinfo, rc);
+
+	return rc;
+}
+
+static int mdc_statfs_async(struct obd_export *exp,
+			    struct obd_info *oinfo, time64_t max_age,
+			    struct ptlrpc_request_set *unused)
+{
+	struct ptlrpc_request *req;
+	struct obd_info *aa;
+
+	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp), &RQF_MDS_STATFS,
+					LUSTRE_MDS_VERSION, MDS_STATFS);
+	if (!req)
+		return -ENOMEM;
+
+	ptlrpc_request_set_replen(req);
+	req->rq_interpret_reply = mdc_statfs_interpret;
+
+	aa = ptlrpc_req_async_args(aa, req);
+	*aa = *oinfo;
+
+	ptlrpcd_add_req(req);
+
+	return 0;
+}
+
 static int mdc_statfs(const struct lu_env *env,
 		      struct obd_export *exp, struct obd_statfs *osfs,
 		      time64_t max_age, u32 flags)
@@ -2802,6 +2849,7 @@ static int mdc_cleanup(struct obd_device *obd)
 	.iocontrol		= mdc_iocontrol,
 	.set_info_async		= mdc_set_info_async,
 	.statfs			= mdc_statfs,
+	.statfs_async		= mdc_statfs_async,
 	.fid_init		= client_fid_init,
 	.fid_fini		= client_fid_fini,
 	.fid_alloc		= mdc_fid_alloc,
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index a988cbf..f929908 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2736,6 +2736,22 @@ static int osc_statfs_async(struct obd_export *exp,
 	struct osc_async_args *aa;
 	int rc;
 
+	if (obd->obd_osfs_age >= max_age) {
+		CDEBUG(D_SUPER,
+		       "%s: use %p cache blocks %llu/%llu objects %llu/%llu\n",
+		       obd->obd_name, &obd->obd_osfs,
+		       obd->obd_osfs.os_bavail, obd->obd_osfs.os_blocks,
+		       obd->obd_osfs.os_ffree, obd->obd_osfs.os_files);
+		spin_lock(&obd->obd_osfs_lock);
+		memcpy(oinfo->oi_osfs, &obd->obd_osfs, sizeof(*oinfo->oi_osfs));
+		spin_unlock(&obd->obd_osfs_lock);
+		oinfo->oi_flags |= OBD_STATFS_FROM_CACHE;
+		if (oinfo->oi_cb_up)
+			oinfo->oi_cb_up(oinfo, 0);
+
+		return 0;
+	}
+
 	/* We could possibly pass max_age in the request (as an absolute
 	 * timestamp or a "seconds.usec ago") so the target can avoid doing
 	 * extra calls into the filesystem if that isn't necessary (e.g.
-- 
1.8.3.1
