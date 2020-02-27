From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:31 -0500
Subject: [lustre-devel] [PATCH 103/622] lustre: protocol: MDT as a statfs
 proxy
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-104-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

MDT can act as a proxy for statfs data. this should
make df faster (RTT vs RTT*(#MDTs+1)) and enable
idling connections so that clients don't connect to
each OST just to report statfs data. the protocol
has been changing slightly to let MDT differentiate
self and aggregated statfs.

also, obd_statfs has got a new field "granted" where
OST reports how much space has been granted to the
requesting MDT so that space can be added to available
space.

client's NID is used to distribute MDS_STATFS among
MDTS.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10018
Lustre-commit: b500d5193360 ("LU-10018 protocol: MDT as a statfs proxy")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/29136
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h                 |  1 +
 fs/lustre/include/obd_class.h           |  7 +++-
 fs/lustre/include/obd_support.h         |  2 +
 fs/lustre/llite/llite_lib.c             |  9 ++++-
 fs/lustre/lmv/lmv_obd.c                 | 65 ++++++++++++++++++++++++++-------
 fs/lustre/mdc/mdc_request.c             | 13 +++++++
 fs/lustre/ptlrpc/layout.c               |  2 +-
 fs/lustre/ptlrpc/pack_generic.c         |  2 +-
 fs/lustre/ptlrpc/wiretest.c             |  8 ++--
 include/uapi/linux/lustre/lustre_idl.h  |  3 +-
 include/uapi/linux/lustre/lustre_user.h |  7 ++--
 11 files changed, 92 insertions(+), 27 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 175a99f..9286755 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -442,6 +442,7 @@ struct lmv_obd {
 
 	u32			tgts_size; /* size of tgts array */
 	struct lmv_tgt_desc	**tgts;
+	int			lmv_statfs_start;
 
 	struct obd_connect_data	conn_data;
 	struct kobject		*lmv_tgts_kobj;
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 0153c50..a3ef5d5 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -47,6 +47,8 @@
 #define OBD_STATFS_FROM_CACHE   0x0002
 /* the statfs is only for retrieving information from MDT0 */
 #define OBD_STATFS_FOR_MDT0	0x0004
+/* get aggregated statfs from MDT */
+#define OBD_STATFS_SUM		0x0008
 
 /* OBD Device Declarations */
 extern rwlock_t obd_dev_lock;
@@ -947,7 +949,10 @@ static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
 
 	CDEBUG(D_SUPER, "osfs %lld, max_age %lld\n",
 	       obd->obd_osfs_age, max_age);
-	if (obd->obd_osfs_age < max_age) {
+	/* ignore cache if aggregated isn't expected */
+	if (obd->obd_osfs_age < max_age ||
+	    ((obd->obd_osfs.os_state & OS_STATE_SUM) &&
+	     !(flags & OBD_STATFS_SUM))) {
 		rc = OBP(obd, statfs)(env, exp, osfs, max_age, flags);
 		if (rc == 0) {
 			spin_lock(&obd->obd_osfs_lock);
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 28becfa..3d14723 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -137,7 +137,9 @@
 #define OBD_FAIL_MDS_GET_ROOT_NET			0x11b
 #define OBD_FAIL_MDS_GET_ROOT_PACK			0x11c
 #define OBD_FAIL_MDS_STATFS_PACK			0x11d
+#define OBD_FAIL_MDS_STATFS_SUM_PACK			0x11d
 #define OBD_FAIL_MDS_STATFS_NET				0x11e
+#define OBD_FAIL_MDS_STATFS_SUM_NET			0x11e
 #define OBD_FAIL_MDS_GETATTR_NAME_NET			0x11f
 #define OBD_FAIL_MDS_PIN_NET				0x120
 #define OBD_FAIL_MDS_UNPIN_NET				0x121
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index c04146f..8b3e2a3 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -211,7 +211,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	data->ocd_connect_flags2 = OBD_CONNECT2_FLR |
 				   OBD_CONNECT2_LOCK_CONVERT |
-				   OBD_CONNECT2_DIR_MIGRATE;
+				   OBD_CONNECT2_DIR_MIGRATE |
+				   OBD_CONNECT2_SUM_STATFS;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
@@ -1751,6 +1752,9 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 	       osfs->os_bavail, osfs->os_blocks, osfs->os_ffree,
 	       osfs->os_files);
 
+	if (osfs->os_state & OS_STATE_SUM)
+		goto out;
+
 	if (sbi->ll_flags & LL_SBI_LAZYSTATFS)
 		flags |= OBD_STATFS_NODELAY;
 
@@ -1779,6 +1783,7 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 		osfs->os_ffree = obd_osfs.os_ffree;
 	}
 
+out:
 	return rc;
 }
 
@@ -1793,7 +1798,7 @@ int ll_statfs(struct dentry *de, struct kstatfs *sfs)
 	ll_stats_ops_tally(ll_s2sbi(sb), LPROC_LL_STAFS, 1);
 
 	/* Some amount of caching on the client is allowed */
-	rc = ll_statfs_internal(ll_s2sbi(sb), &osfs, 0);
+	rc = ll_statfs_internal(ll_s2sbi(sb), &osfs, OBD_STATFS_SUM);
 	if (rc)
 		return rc;
 
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index c7bf8c7..90a46c4 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1325,6 +1325,33 @@ static int lmv_process_config(struct obd_device *obd, u32 len, void *buf)
 	return rc;
 }
 
+static int lmv_select_statfs_mdt(struct lmv_obd *lmv, u32 flags)
+{
+	int i;
+
+	if (flags & OBD_STATFS_FOR_MDT0)
+		return 0;
+
+	if (lmv->lmv_statfs_start || lmv->desc.ld_tgt_count == 1)
+		return lmv->lmv_statfs_start;
+
+	/* choose initial MDT for this client */
+	for (i = 0;; i++) {
+		struct lnet_process_id lnet_id;
+
+		if (LNetGetId(i, &lnet_id) == -ENOENT)
+			break;
+
+		if (LNET_NETTYP(LNET_NIDNET(lnet_id.nid)) != LOLND) {
+			lmv->lmv_statfs_start =
+				lnet_id.nid % lmv->desc.ld_tgt_count;
+			break;
+		}
+	}
+
+	return lmv->lmv_statfs_start;
+}
+
 static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 		      struct obd_statfs *osfs, time64_t max_age, u32 flags)
 {
@@ -1332,41 +1359,51 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct obd_statfs *temp;
 	int rc = 0;
-	u32 i;
+	u32 i, idx;
 
 	temp = kzalloc(sizeof(*temp), GFP_NOFS);
 	if (!temp)
 		return -ENOMEM;
 
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp)
+	/* distribute statfs among MDTs */
+	idx = lmv_select_statfs_mdt(lmv, flags);
+
+	for (i = 0; i < lmv->desc.ld_tgt_count; i++, idx++) {
+		idx = idx % lmv->desc.ld_tgt_count;
+		if (!lmv->tgts[idx] || !lmv->tgts[idx]->ltd_exp)
 			continue;
 
-		rc = obd_statfs(env, lmv->tgts[i]->ltd_exp, temp,
+		rc = obd_statfs(env, lmv->tgts[idx]->ltd_exp, temp,
 				max_age, flags);
 		if (rc) {
 			CERROR("can't stat MDS #%d (%s), error %d\n", i,
-			       lmv->tgts[i]->ltd_exp->exp_obd->obd_name,
+			       lmv->tgts[idx]->ltd_exp->exp_obd->obd_name,
 			       rc);
 			goto out_free_temp;
 		}
 
+		if (temp->os_state & OS_STATE_SUM ||
+		    flags == OBD_STATFS_FOR_MDT0) {
+			/* Reset to the last aggregated values
+			 * and don't sum with non-aggrated data.
+			 * If the statfs is from mount, it needs to retrieve
+			 * necessary information from MDT0. i.e. mount does
+			 * not need the merged osfs from all of MDT. Also
+			 * clients can be mounted as long as MDT0 is in
+			 * service
+			 */
+			*osfs = *temp;
+			break;
+		}
+
 		if (i == 0) {
 			*osfs = *temp;
-			/* If the statfs is from mount, it will needs
-			 * retrieve necessary information from MDT0.
-			 * i.e. mount does not need the merged osfs
-			 * from all of MDT.
-			 * And also clients can be mounted as long as
-			 * MDT0 is in service
-			 */
-			if (flags & OBD_STATFS_FOR_MDT0)
-				goto out_free_temp;
 		} else {
 			osfs->os_bavail += temp->os_bavail;
 			osfs->os_blocks += temp->os_blocks;
 			osfs->os_ffree += temp->os_ffree;
 			osfs->os_files += temp->os_files;
+			osfs->os_granted += temp->os_granted;
 		}
 	}
 
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index b173937..3341761 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -1495,6 +1495,19 @@ static int mdc_statfs(const struct lu_env *env,
 		goto output;
 	}
 
+	if ((flags & OBD_STATFS_SUM) &&
+	    (exp_connect_flags2(exp) & OBD_CONNECT2_SUM_STATFS)) {
+		/* request aggregated states */
+		struct mdt_body *body;
+
+		body = req_capsule_client_get(&req->rq_pill, &RMF_MDT_BODY);
+		if (!body) {
+			rc = -EPROTO;
+			goto out;
+		}
+		body->mbo_valid = OBD_MD_FLAGSTATFS;
+	}
+
 	ptlrpc_request_set_replen(req);
 
 	if (flags & OBD_STATFS_NODELAY) {
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 70344b9..225a73e 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -1252,7 +1252,7 @@ struct req_format RQF_MDS_GET_ROOT =
 EXPORT_SYMBOL(RQF_MDS_GET_ROOT);
 
 struct req_format RQF_MDS_STATFS =
-	DEFINE_REQ_FMT0("MDS_STATFS", empty, obd_statfs_server);
+	DEFINE_REQ_FMT0("MDS_STATFS", mdt_body_only, obd_statfs_server);
 EXPORT_SYMBOL(RQF_MDS_STATFS);
 
 struct req_format RQF_MDS_SYNC =
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index d09cf3f..e71f79d 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1645,7 +1645,7 @@ void lustre_swab_obd_statfs(struct obd_statfs *os)
 	__swab32s(&os->os_state);
 	__swab32s(&os->os_fprecreated);
 	BUILD_BUG_ON(offsetof(typeof(*os), os_fprecreated) == 0);
-	BUILD_BUG_ON(offsetof(typeof(*os), os_spare2) == 0);
+	__swab32s(&os->os_granted);
 	BUILD_BUG_ON(offsetof(typeof(*os), os_spare3) == 0);
 	BUILD_BUG_ON(offsetof(typeof(*os), os_spare4) == 0);
 	BUILD_BUG_ON(offsetof(typeof(*os), os_spare5) == 0);
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 1afbb41..30083c2 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1696,10 +1696,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obd_statfs, os_fprecreated));
 	LASSERTF((int)sizeof(((struct obd_statfs *)0)->os_fprecreated) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct obd_statfs *)0)->os_fprecreated));
-	LASSERTF((int)offsetof(struct obd_statfs, os_spare2) == 112, "found %lld\n",
-		 (long long)(int)offsetof(struct obd_statfs, os_spare2));
-	LASSERTF((int)sizeof(((struct obd_statfs *)0)->os_spare2) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct obd_statfs *)0)->os_spare2));
+	LASSERTF((int)offsetof(struct obd_statfs, os_granted) == 112, "found %lld\n",
+		 (long long)(int)offsetof(struct obd_statfs, os_granted));
+	LASSERTF((int)sizeof(((struct obd_statfs *)0)->os_granted) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct obd_statfs *)0)->os_granted));
 	LASSERTF((int)offsetof(struct obd_statfs, os_spare3) == 116, "found %lld\n",
 		 (long long)(int)offsetof(struct obd_statfs, os_spare3));
 	LASSERTF((int)sizeof(((struct obd_statfs *)0)->os_spare3) == 4, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 249a3d5..c65663a 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -793,6 +793,7 @@ struct ptlrpc_body_v2 {
 							 */
 #define OBD_CONNECT2_DIR_MIGRATE	0x4ULL		/* migrate striped dir
 							 */
+#define OBD_CONNECT2_SUM_STATFS		0x8ULL /* MDT return aggregated stats */
 #define OBD_CONNECT2_FLR		0x20ULL		/* FLR support */
 #define OBD_CONNECT2_WBC_INTENTS	0x40ULL /* create/unlink/... intents
 						 * for wbc, also operations
@@ -1167,7 +1168,7 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 #define OBD_MD_FLXATTRLS	(0x0000002000000000ULL) /* xattr list */
 #define OBD_MD_FLXATTRRM	(0x0000004000000000ULL) /* xattr remove */
 #define OBD_MD_FLACL		(0x0000008000000000ULL) /* ACL */
-/*	OBD_MD_FLRMTPERM	(0x0000010000000000ULL) remote perm, obsolete */
+#define OBD_MD_FLAGSTATFS	(0x0000010000000000ULL) /* aggregated statfs */
 #define OBD_MD_FLMDSCAPA	(0x0000020000000000ULL) /* MDS capability */
 #define OBD_MD_FLOSSCAPA	(0x0000040000000000ULL) /* OSS capability */
 /*	OBD_MD_FLCKSPLIT	(0x0000080000000000ULL) obsolete 2.3.58*/
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 421c977..f25bb9b 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -104,6 +104,7 @@ enum obd_statfs_state {
 	OS_STATE_NOPRECREATE	= 0x00000004, /**< no object precreation */
 	OS_STATE_ENOSPC		= 0x00000020, /**< not enough free space */
 	OS_STATE_ENOINO		= 0x00000040, /**< not enough inodes */
+	OS_STATE_SUM		= 0x00000100, /**< aggregated for all tagrets */
 };
 
 struct obd_statfs {
@@ -121,9 +122,9 @@ struct obd_statfs {
 	__u32	os_fprecreated;	/* objs available now to the caller
 				 * used in QoS code to find preferred OSTs
 				 */
-	__u32	os_spare2;	/* Unused padding fields.  Remember */
-	__u32	os_spare3;	/* to fix lustre_swab_obd_statfs() */
-	__u32	os_spare4;
+	__u32	os_granted;	/* space granted for MDS */
+	__u32	os_spare3;	/* Unused padding fields.  Remember */
+	__u32	os_spare4;	/* to fix lustre_swab_obd_statfs() */
 	__u32	os_spare5;
 	__u32	os_spare6;
 	__u32	os_spare7;
-- 
1.8.3.1
