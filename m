From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:38 -0500
Subject: [lustre-devel] [PATCH 410/622] lustre: obd: add rmfid support
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-411-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

a new RPC_REINT_RMFID has been introduced by the patch.
it's supposed to be used with corresponding llapi_rmfid()
to unlink a batch of MDS files by their FIDs. the caller
has to have permission to modify parent dir(s) and the objects
themselves.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12090
Lustre-commit: 1fd63fcb045c ("LU-12090 utils: lfs rmfid")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34449
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_req_layout.h   |  2 +
 fs/lustre/include/obd.h                 |  2 +
 fs/lustre/include/obd_class.h           | 12 ++++
 fs/lustre/include/obd_support.h         |  1 +
 fs/lustre/llite/dir.c                   | 54 +++++++++++++++++-
 fs/lustre/lmv/lmv_obd.c                 | 98 +++++++++++++++++++++++++++++++++
 fs/lustre/mdc/mdc_request.c             | 76 ++++++++++++++++++++++++-
 fs/lustre/ptlrpc/layout.c               | 25 +++++++++
 fs/lustre/ptlrpc/lproc_ptlrpc.c         |  1 +
 fs/lustre/ptlrpc/wiretest.c             |  4 +-
 include/uapi/linux/lustre/lustre_idl.h  |  1 +
 include/uapi/linux/lustre/lustre_user.h | 10 ++++
 12 files changed, 283 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index dca4ef4..feb5e77 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -165,6 +165,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_format RQF_MDS_SWAP_LAYOUTS;
 extern struct req_format RQF_MDS_REINT_MIGRATE;
 extern struct req_format RQF_MDS_REINT_RESYNC;
+extern struct req_format RQF_MDS_RMFID;
 /* MDS hsm formats */
 extern struct req_format RQF_MDS_HSM_STATE_GET;
 extern struct req_format RQF_MDS_HSM_STATE_SET;
@@ -236,6 +237,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_msg_field RMF_CLOSE_DATA;
 extern struct req_msg_field RMF_FILE_SECCTX_NAME;
 extern struct req_msg_field RMF_FILE_SECCTX;
+extern struct req_msg_field RMF_FID_ARRAY;
 
 /*
  * connection handle received in MDS_CONNECT request.
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 53d078e..886c697 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -1039,6 +1039,8 @@ struct md_ops {
 
 	int (*unpackmd)(struct obd_export *exp, struct lmv_stripe_md **plsm,
 			const union lmv_mds_md *lmv, size_t lmv_size);
+	int (*rmfid)(struct obd_export *exp, struct fid_array *fa, int *rcs,
+		     struct ptlrpc_request_set *set);
 };
 
 static inline struct md_open_data *obd_mod_alloc(void)
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index b8afa5a..bc01eca 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1663,6 +1663,18 @@ static inline int md_unpackmd(struct obd_export *exp,
 	return MDP(exp->exp_obd, unpackmd)(exp, plsm, lmm, lmm_size);
 }
 
+static inline int md_rmfid(struct obd_export *exp, struct fid_array *fa,
+			   int *rcs, struct ptlrpc_request_set *set)
+{
+	int rc;
+
+	rc = exp_check_ops(exp);
+	if (rc)
+		return rc;
+
+	return MDP(exp->exp_obd, rmfid)(exp, fa, rcs, set);
+}
+
 /* OBD Metadata Support */
 
 int obd_init_caches(void);
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 23f6bae..c66b61a 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -194,6 +194,7 @@
 #define OBD_FAIL_MDS_CHANGELOG_INIT			0x151
 #define OBD_FAIL_MDS_REINT_MULTI_NET			0x159
 #define OBD_FAIL_MDS_REINT_MULTI_NET_REP		0x15a
+#define OBD_FAIL_MDS_RMFID_NET		 0x166
 
 /* layout lock */
 #define OBD_FAIL_MDS_NO_LL_GETATTR			0x170
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index f87ddd2..3540c18 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1180,6 +1180,57 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 	return rc;
 }
 
+int ll_rmfid(struct file *file, void __user *arg)
+{
+	const struct fid_array __user *ufa = arg;
+	struct fid_array *lfa = NULL;
+	size_t size;
+	unsigned int nr;
+	int i, rc, *rcs = NULL;
+
+	if (!capable(CAP_DAC_READ_SEARCH) &&
+	    !(ll_i2sbi(file_inode(file))->ll_flags & LL_SBI_USER_FID2PATH))
+		return -EPERM;
+	/* Only need to get the buflen */
+	if (get_user(nr, &ufa->fa_nr))
+		return -EFAULT;
+	/* DoS protection */
+	if (nr > OBD_MAX_FIDS_IN_ARRAY)
+		return -E2BIG;
+
+	size = offsetof(struct fid_array, fa_fids[nr]);
+	lfa = kzalloc(size, GFP_NOFS);
+	if (!lfa)
+		return -ENOMEM;
+	rcs = kcalloc(nr, sizeof(int), GFP_NOFS);
+	if (!rcs) {
+		rc = -ENOMEM;
+		goto free_lfa;
+	}
+
+	if (copy_from_user(lfa, arg, size)) {
+		rc = -EFAULT;
+		goto free_rcs;
+	}
+
+	/* Call mdc_iocontrol */
+	rc = md_rmfid(ll_i2mdexp(file_inode(file)), lfa, rcs, NULL);
+	if (!rc) {
+		for (i = 0; i < nr; i++)
+			if (rcs[i])
+				lfa->fa_fids[i].f_ver = rcs[i];
+		if (copy_to_user(arg, lfa, size))
+			rc = -EFAULT;
+	}
+
+free_rcs:
+	kfree(rcs);
+free_lfa:
+	kfree(lfa);
+
+	return rc;
+}
+
 /* This function tries to get a single name component,
  * to send to the server. No actual path traversal involved,
  * so we limit to NAME_MAX
@@ -1544,7 +1595,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		ptlrpc_req_finished(request);
 		return rc;
 	}
-
+	case LL_IOC_RMFID:
+		return ll_rmfid(file, (void __user *)arg);
 	case LL_IOC_LOV_SWAP_LAYOUTS:
 		return -EPERM;
 	case IOC_OBD_STATFS:
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index e9f9c36..d323250 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -2930,6 +2930,103 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 	return -EINVAL;
 }
 
+static int lmv_rmfid(struct obd_export *exp, struct fid_array *fa,
+		     int *__rcs, struct ptlrpc_request_set *_set)
+{
+	struct obd_device *obddev = class_exp2obd(exp);
+	struct ptlrpc_request_set *set = _set;
+	struct lmv_obd *lmv = &obddev->u.lmv;
+	int tgt_count = lmv->desc.ld_tgt_count;
+	struct fid_array *fat, **fas = NULL;
+	int i, rc, **rcs = NULL;
+
+	if (!set) {
+		set = ptlrpc_prep_set();
+		if (!set)
+			return -ENOMEM;
+	}
+
+	/* split FIDs by targets */
+	fas = kcalloc(tgt_count, sizeof(fas), GFP_NOFS);
+	if (!fas) {
+		rc = -ENOMEM;
+		goto out;
+	}
+	rcs = kcalloc(tgt_count, sizeof(int *), GFP_NOFS);
+	if (!rcs) {
+		rc = -ENOMEM;
+		goto out_fas;
+	}
+
+	for (i = 0; i < fa->fa_nr; i++) {
+		unsigned int idx;
+
+		rc = lmv_fld_lookup(lmv, &fa->fa_fids[i], &idx);
+		if (rc) {
+			CDEBUG(D_OTHER, "can't lookup "DFID": rc = %d\n",
+			       PFID(&fa->fa_fids[i]), rc);
+			continue;
+		}
+		LASSERT(idx < tgt_count);
+		if (!fas[idx])
+			fas[idx] = kzalloc(offsetof(struct fid_array,
+						    fa_fids[fa->fa_nr]),
+					   GFP_NOFS);
+		if (!fas[idx]) {
+			rc = -ENOMEM;
+			goto out;
+		}
+		if (!rcs[idx])
+			rcs[idx] = kcalloc(fa->fa_nr, sizeof(int), GFP_NOFS);
+		if (!rcs[idx]) {
+			rc = -ENOMEM;
+			goto out;
+		}
+
+		fat = fas[idx];
+		fat->fa_fids[fat->fa_nr++] = fa->fa_fids[i];
+	}
+
+	for (i = 0; i < tgt_count; i++) {
+		fat = fas[i];
+		if (!fat || fat->fa_nr == 0)
+			continue;
+		rc = md_rmfid(lmv->tgts[i]->ltd_exp, fat, rcs[i], set);
+	}
+
+	rc = ptlrpc_set_wait(NULL, set);
+	if (rc == 0) {
+		int j = 0;
+
+		for (i = 0; i < tgt_count; i++) {
+			fat = fas[i];
+			if (!fat || fat->fa_nr == 0)
+				continue;
+			/* copy FIDs back */
+			memcpy(fa->fa_fids + j, fat->fa_fids,
+			       fat->fa_nr * sizeof(struct lu_fid));
+			/* copy rcs back */
+			memcpy(__rcs + j, rcs[i], fat->fa_nr * sizeof(**rcs));
+			j += fat->fa_nr;
+		}
+	}
+	if (set != _set)
+		ptlrpc_set_destroy(set);
+
+out:
+	for (i = 0; i < tgt_count; i++) {
+		if (fas)
+			kfree(fas[i]);
+		if (rcs)
+			kfree(rcs[i]);
+	}
+	kfree(rcs);
+out_fas:
+	kfree(fas);
+
+	return rc;
+}
+
 /**
  * Asynchronously set by key a value associated with a LMV device.
  *
@@ -3517,6 +3614,7 @@ static int lmv_merge_attr(struct obd_export *exp,
 	.revalidate_lock	= lmv_revalidate_lock,
 	.get_fid_from_lsm	= lmv_get_fid_from_lsm,
 	.unpackmd		= lmv_unpackmd,
+	.rmfid			= lmv_rmfid,
 };
 
 static int __init lmv_init(void)
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 7bc6196..693c455 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2585,6 +2585,79 @@ static int mdc_fsync(struct obd_export *exp, const struct lu_fid *fid,
 	return rc;
 }
 
+struct mdc_rmfid_args {
+	int *mra_rcs;
+	int mra_nr;
+};
+
+int mdc_rmfid_interpret(const struct lu_env *env, struct ptlrpc_request *req,
+			  void *args, int rc)
+{
+	struct mdc_rmfid_args *aa;
+	int *rcs, size;
+
+	if (!rc) {
+		aa = ptlrpc_req_async_args(aa, req);
+
+		size = req_capsule_get_size(&req->rq_pill, &RMF_RCS,
+					    RCL_SERVER);
+		LASSERT(size == sizeof(int) * aa->mra_nr);
+		rcs = req_capsule_server_get(&req->rq_pill, &RMF_RCS);
+		LASSERT(rcs);
+		LASSERT(aa->mra_rcs);
+		LASSERT(aa->mra_nr);
+		memcpy(aa->mra_rcs, rcs, size);
+	}
+
+	return rc;
+}
+
+static int mdc_rmfid(struct obd_export *exp, struct fid_array *fa,
+		     int *rcs, struct ptlrpc_request_set *set)
+{
+	struct ptlrpc_request *req;
+	struct mdc_rmfid_args *aa;
+	struct mdt_body *b;
+	struct lu_fid *tmp;
+	int rc, flen;
+
+	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_MDS_RMFID);
+	if (!req)
+		return -ENOMEM;
+
+	flen = fa->fa_nr * sizeof(struct lu_fid);
+	req_capsule_set_size(&req->rq_pill, &RMF_FID_ARRAY,
+			     RCL_CLIENT, flen);
+	req_capsule_set_size(&req->rq_pill, &RMF_FID_ARRAY,
+			     RCL_SERVER, flen);
+	req_capsule_set_size(&req->rq_pill, &RMF_RCS,
+			     RCL_SERVER, fa->fa_nr * sizeof(u32));
+	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_RMFID);
+	if (rc) {
+		ptlrpc_request_free(req);
+		return rc;
+	}
+	tmp = req_capsule_client_get(&req->rq_pill, &RMF_FID_ARRAY);
+	memcpy(tmp, fa->fa_fids, flen);
+
+	mdc_pack_body(req, NULL, 0, 0, -1, 0);
+	b = req_capsule_client_get(&req->rq_pill, &RMF_MDT_BODY);
+	b->mbo_ctime = ktime_get_real_seconds();
+
+	ptlrpc_request_set_replen(req);
+
+	LASSERT(rcs);
+	aa = ptlrpc_req_async_args(aa, req);
+	aa->mra_rcs = rcs;
+	aa->mra_nr = fa->fa_nr;
+	req->rq_interpret_reply = mdc_rmfid_interpret;
+
+	ptlrpc_set_add_req(set, req);
+	ptlrpc_check_set(NULL, set);
+
+	return rc;
+}
+
 static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 			    enum obd_import_event event)
 {
@@ -2886,7 +2959,8 @@ static int mdc_cleanup(struct obd_device *obd)
 	.set_open_replay_data	= mdc_set_open_replay_data,
 	.clear_open_replay_data	= mdc_clear_open_replay_data,
 	.intent_getattr_async	= mdc_intent_getattr_async,
-	.revalidate_lock	= mdc_revalidate_lock
+	.revalidate_lock	= mdc_revalidate_lock,
+	.rmfid			= mdc_rmfid,
 };
 
 static int __init mdc_init(void)
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index c10b593..fb60558 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -318,6 +318,21 @@
 	&RMF_DLM_REQ
 };
 
+static const struct req_msg_field *mds_rmfid_client[] = {
+	&RMF_PTLRPC_BODY,
+	&RMF_MDT_BODY,
+	&RMF_FID_ARRAY,
+	&RMF_CAPA1,
+	&RMF_CAPA2,
+};
+
+static const struct req_msg_field *mds_rmfid_server[] = {
+	&RMF_PTLRPC_BODY,
+	&RMF_MDT_BODY,
+	&RMF_FID_ARRAY,
+	&RMF_RCS,
+};
+
 static const struct req_msg_field *obd_connect_client[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_TGTUUID,
@@ -731,6 +746,7 @@
 	&RQF_MDS_HSM_ACTION,
 	&RQF_MDS_HSM_REQUEST,
 	&RQF_MDS_SWAP_LAYOUTS,
+	&RQF_MDS_RMFID,
 	&RQF_OST_CONNECT,
 	&RQF_OST_DISCONNECT,
 	&RQF_OST_QUOTACTL,
@@ -929,6 +945,10 @@ struct req_msg_field RMF_NAME =
 	DEFINE_MSGF("name", RMF_F_STRING, -1, NULL, NULL);
 EXPORT_SYMBOL(RMF_NAME);
 
+struct req_msg_field RMF_FID_ARRAY =
+	DEFINE_MSGF("fid_array", 0, -1, NULL, NULL);
+EXPORT_SYMBOL(RMF_FID_ARRAY);
+
 struct req_msg_field RMF_SYMTGT =
 	DEFINE_MSGF("symtgt", RMF_F_STRING, -1, NULL, NULL);
 EXPORT_SYMBOL(RMF_SYMTGT);
@@ -1511,6 +1531,11 @@ struct req_format RQF_MDS_WRITEPAGE =
 			mdt_body_capa, mdt_body_only);
 EXPORT_SYMBOL(RQF_MDS_WRITEPAGE);
 
+struct req_format RQF_MDS_RMFID =
+	DEFINE_REQ_FMT0("MDS_RMFID", mds_rmfid_client,
+			mds_rmfid_server);
+EXPORT_SYMBOL(RQF_MDS_RMFID);
+
 struct req_format RQF_LLOG_ORIGIN_HANDLE_CREATE =
 	DEFINE_REQ_FMT0("LLOG_ORIGIN_HANDLE_CREATE",
 			llog_origin_handle_create_client, llogd_body_only);
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 700e109..d52a08a 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -96,6 +96,7 @@
 	{ MDS_HSM_CT_REGISTER,			"mds_hsm_ct_register" },
 	{ MDS_HSM_CT_UNREGISTER,		"mds_hsm_ct_unregister" },
 	{ MDS_SWAP_LAYOUTS,			"mds_swap_layouts" },
+	{ MDS_RMFID,				"mds_rmfid" },
 	{ LDLM_ENQUEUE,				"ldlm_enqueue" },
 	{ LDLM_CONVERT,				"ldlm_convert" },
 	{ LDLM_CANCEL,				"ldlm_cancel" },
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 1d34b15..9298c97 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -178,7 +178,9 @@ void lustre_assert_wire_constants(void)
 		 (long long)MDS_HSM_CT_UNREGISTER);
 	LASSERTF(MDS_SWAP_LAYOUTS == 61, "found %lld\n",
 		 (long long)MDS_SWAP_LAYOUTS);
-	LASSERTF(MDS_LAST_OPC == 62, "found %lld\n",
+	LASSERTF(MDS_RMFID == 62, "found %lld\n",
+		 (long long)MDS_RMFID);
+	LASSERTF(MDS_LAST_OPC == 63, "found %lld\n",
 		 (long long)MDS_LAST_OPC);
 	LASSERTF(REINT_SETATTR == 1, "found %lld\n",
 		 (long long)REINT_SETATTR);
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 5740d42..87251ee 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1443,6 +1443,7 @@ enum mds_cmd {
 	MDS_HSM_CT_REGISTER	= 59,
 	MDS_HSM_CT_UNREGISTER	= 60,
 	MDS_SWAP_LAYOUTS	= 61,
+	MDS_RMFID		= 62,
 	MDS_LAST_OPC
 };
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 9c849ce..db36ce5 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -348,6 +348,7 @@ struct ll_ioc_lease_id {
 
 #define LL_IOC_LMV_SETSTRIPE		_IOWR('f', 240, struct lmv_user_md)
 #define LL_IOC_LMV_GETSTRIPE		_IOWR('f', 241, struct lmv_user_md)
+#define LL_IOC_RMFID			_IOR('f', 242, struct fid_array)
 #define LL_IOC_SET_LEASE		_IOWR('f', 243, struct ll_ioc_lease)
 #define LL_IOC_SET_LEASE_OLD		_IOWR('f', 243, long)
 #define LL_IOC_GET_LEASE		_IO('f', 244)
@@ -2149,6 +2150,15 @@ struct lu_pcc_state {
 	char	pccs_path[PATH_MAX];
 };
 
+struct fid_array {
+	__u32 fa_nr;
+	/* make header's size equal lu_fid */
+	__u32 fa_padding0;
+	__u64 fa_padding1;
+	struct lu_fid fa_fids[0];
+};
+#define OBD_MAX_FIDS_IN_ARRAY	4096
+
 /** @} lustreuser */
 
 #endif /* _LUSTRE_USER_H */
-- 
1.8.3.1
