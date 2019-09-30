From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:27 -0400
Subject: [lustre-devel] [PATCH 128/151] lustre: dom: support DATA_VERSION IO
 type
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-129-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

add support for DATA_VERSION IO type, return from MDT
data version and layout version if requested by CLIO.
Also ensure that version is changed on punch and write
operations.
This fixes HSM archive with DOM files.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10318
Lustre-commit: 1e7fc14bbf48 ("LU-10318 dom: support DATA_VERSION IO type")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30449
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_dev.c                | 119 ++++++++++++++++++++++++++++++++-
 fs/lustre/mdc/mdc_request.c            |   1 -
 fs/lustre/ptlrpc/pack_generic.c        |   4 +-
 fs/lustre/ptlrpc/wiretest.c            |  85 ++++++++++++++++-------
 include/uapi/linux/lustre/lustre_idl.h |   4 +-
 5 files changed, 181 insertions(+), 32 deletions(-)

diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 2de849a..22749ea 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -1114,6 +1114,120 @@ int mdc_io_fsync_start(const struct lu_env *env,
 	return result;
 }
 
+struct mdc_data_version_args {
+	struct osc_io *dva_oio;
+};
+
+static int
+mdc_data_version_interpret(const struct lu_env *env, struct ptlrpc_request *req,
+			   void *arg, int rc)
+{
+	struct mdc_data_version_args *dva = arg;
+	struct osc_io *oio = dva->dva_oio;
+	const struct mdt_body *body;
+
+	if (rc < 0)
+		goto out;
+
+	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
+	if (!body) {
+		rc = -EPROTO;
+		goto out;
+	}
+
+	/* Prepare OBDO from mdt_body for CLIO */
+	oio->oi_oa.o_valid = body->mbo_valid;
+	oio->oi_oa.o_flags = body->mbo_flags;
+	oio->oi_oa.o_data_version = body->mbo_version;
+	oio->oi_oa.o_layout_version = body->mbo_layout_gen;
+
+out:
+	oio->oi_cbarg.opc_rc = rc;
+	complete(&oio->oi_cbarg.opc_sync);
+	return 0;
+}
+
+static int mdc_io_data_version_start(const struct lu_env *env,
+				     const struct cl_io_slice *slice)
+{
+	struct cl_data_version_io *dv = &slice->cis_io->u.ci_data_version;
+	struct osc_io *oio = cl2osc_io(env, slice);
+	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
+	struct osc_object *obj = cl2osc(slice->cis_obj);
+	struct obd_export *exp = osc_export(obj);
+	struct ptlrpc_request *req;
+	struct mdt_body *body;
+	struct mdc_data_version_args *dva;
+	int rc;
+
+	memset(&oio->oi_oa, 0, sizeof(oio->oi_oa));
+	oio->oi_oa.o_oi.oi_fid = *lu_object_fid(osc2lu(obj));
+	oio->oi_oa.o_valid = OBD_MD_FLID;
+
+	init_completion(&cbargs->opc_sync);
+
+	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_MDS_GETATTR);
+	if (!req)
+		return -ENOMEM;
+
+	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_GETATTR);
+	if (rc < 0) {
+		ptlrpc_request_free(req);
+		return rc;
+	}
+
+	body = req_capsule_client_get(&req->rq_pill, &RMF_MDT_BODY);
+	body->mbo_fid1 = *lu_object_fid(osc2lu(obj));
+	body->mbo_valid = OBD_MD_FLID;
+	/* Indicate that data version is needed */
+	body->mbo_valid |= OBD_MD_FLDATAVERSION;
+	body->mbo_flags = 0;
+
+	if (dv->dv_flags & (LL_DV_RD_FLUSH | LL_DV_WR_FLUSH)) {
+		body->mbo_valid |= OBD_MD_FLFLAGS;
+		body->mbo_flags |= OBD_FL_SRVLOCK;
+		if (dv->dv_flags & LL_DV_WR_FLUSH)
+			body->mbo_flags |= OBD_FL_FLUSH;
+	}
+
+	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, 0);
+	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER, 0);
+	ptlrpc_request_set_replen(req);
+
+	req->rq_interpret_reply = mdc_data_version_interpret;
+	BUILD_BUG_ON(sizeof(*dva) > sizeof(req->rq_async_args));
+	dva = ptlrpc_req_async_args(req);
+	dva->dva_oio = oio;
+
+	ptlrpcd_add_req(req);
+
+	return 0;
+}
+
+static void mdc_io_data_version_end(const struct lu_env *env,
+				    const struct cl_io_slice *slice)
+{
+	struct cl_data_version_io *dv = &slice->cis_io->u.ci_data_version;
+	struct osc_io *oio = cl2osc_io(env, slice);
+	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
+
+	wait_for_completion(&cbargs->opc_sync);
+
+	if (cbargs->opc_rc != 0) {
+		slice->cis_io->ci_result = cbargs->opc_rc;
+	} else {
+		slice->cis_io->ci_result = 0;
+		if (!(oio->oi_oa.o_valid &
+		      (OBD_MD_LAYOUT_VERSION | OBD_MD_FLDATAVERSION)))
+			slice->cis_io->ci_result = -ENOTSUPP;
+
+		if (oio->oi_oa.o_valid & OBD_MD_LAYOUT_VERSION)
+			dv->dv_layout_version = oio->oi_oa.o_layout_version;
+		if (oio->oi_oa.o_valid & OBD_MD_FLDATAVERSION)
+			dv->dv_data_version = oio->oi_oa.o_data_version;
+	}
+}
+
 static struct cl_io_operations mdc_io_ops = {
 	.op = {
 		[CIT_READ] = {
@@ -1133,10 +1247,9 @@ int mdc_io_fsync_start(const struct lu_env *env,
 			.cio_start	= mdc_io_setattr_start,
 			.cio_end	= osc_io_setattr_end,
 		},
-		/* no support for data version so far */
 		[CIT_DATA_VERSION] = {
-			.cio_start	= NULL,
-			.cio_end	= NULL,
+			.cio_start	= mdc_io_data_version_start,
+			.cio_end	= mdc_io_data_version_end,
 		},
 		[CIT_FAULT] = {
 			.cio_iter_init	= osc_io_iter_init,
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index e344e78..408bf19 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -722,7 +722,6 @@ int mdc_set_open_replay_data(struct obd_export *exp,
 	}
 
 	rec->cr_fid2 = body->mbo_fid1;
-	rec->cr_ioepoch = body->mbo_ioepoch;
 	rec->cr_old_handle.cookie = body->mbo_handle.cookie;
 	open_req->rq_replay_cb = mdc_replay_open;
 	if (!fid_is_sane(&body->mbo_fid1)) {
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 1face33..f7afc4c 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1741,7 +1741,7 @@ void lustre_swab_mdt_body(struct mdt_body *b)
 	__swab64s(&b->mbo_atime);
 	__swab64s(&b->mbo_ctime);
 	__swab64s(&b->mbo_blocks);
-	__swab64s(&b->mbo_ioepoch);
+	__swab64s(&b->mbo_version);
 	__swab64s(&b->mbo_t_state);
 	__swab32s(&b->mbo_fsuid);
 	__swab32s(&b->mbo_fsgid);
@@ -1752,7 +1752,7 @@ void lustre_swab_mdt_body(struct mdt_body *b)
 	__swab32s(&b->mbo_flags);
 	__swab32s(&b->mbo_rdev);
 	__swab32s(&b->mbo_nlink);
-	BUILD_BUG_ON(offsetof(typeof(*b), mbo_unused2) == 0);
+	__swab32s(&b->mbo_layout_gen);
 	__swab32s(&b->mbo_suppgid);
 	__swab32s(&b->mbo_eadatasize);
 	__swab32s(&b->mbo_aclsize);
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 70ed2cd..68eb33c 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -589,10 +589,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lustre_msg_v2, lm_buflens[0]));
 	LASSERTF((int)sizeof(((struct lustre_msg_v2 *)0)->lm_buflens[0]) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct lustre_msg_v2 *)0)->lm_buflens[0]));
-	LASSERTF(LUSTRE_MSG_MAGIC_V2 == 0x0BD00BD3, "found 0x%.8x\n",
-		 LUSTRE_MSG_MAGIC_V2);
-	LASSERTF(LUSTRE_MSG_MAGIC_V2_SWABBED == 0xD30BD00B, "found 0x%.8x\n",
-		 LUSTRE_MSG_MAGIC_V2_SWABBED);
+	LASSERTF(LUSTRE_MSG_MAGIC_V2 == 0x0bd00bd3UL, "found 0x%.8xUL\n",
+		 (unsigned int)LUSTRE_MSG_MAGIC_V2);
+	LASSERTF(LUSTRE_MSG_MAGIC_V2_SWABBED == 0xd30bd00bUL, "found 0x%.8xUL\n",
+		 (unsigned int)LUSTRE_MSG_MAGIC_V2_SWABBED);
 
 	/* Checks for struct ptlrpc_body */
 	LASSERTF((int)sizeof(struct ptlrpc_body_v3) == 184, "found %lld\n",
@@ -807,22 +807,22 @@ void lustre_assert_wire_constants(void)
 		 (long long)DLM_REPLY_REC_OFF);
 	LASSERTF(MSG_PTLRPC_HEADER_OFF == 31, "found %lld\n",
 		 (long long)MSG_PTLRPC_HEADER_OFF);
-	LASSERTF(PTLRPC_MSG_VERSION == 0x00000003, "found 0x%.8x\n",
-		 PTLRPC_MSG_VERSION);
-	LASSERTF(LUSTRE_VERSION_MASK == 0xffff0000, "found 0x%.8x\n",
-		 LUSTRE_VERSION_MASK);
-	LASSERTF(LUSTRE_OBD_VERSION == 0x00010000, "found 0x%.8x\n",
-		 LUSTRE_OBD_VERSION);
-	LASSERTF(LUSTRE_MDS_VERSION == 0x00020000, "found 0x%.8x\n",
-		 LUSTRE_MDS_VERSION);
-	LASSERTF(LUSTRE_OST_VERSION == 0x00030000, "found 0x%.8x\n",
-		 LUSTRE_OST_VERSION);
-	LASSERTF(LUSTRE_DLM_VERSION == 0x00040000, "found 0x%.8x\n",
-		 LUSTRE_DLM_VERSION);
-	LASSERTF(LUSTRE_LOG_VERSION == 0x00050000, "found 0x%.8x\n",
-		 LUSTRE_LOG_VERSION);
-	LASSERTF(LUSTRE_MGS_VERSION == 0x00060000, "found 0x%.8x\n",
-		 LUSTRE_MGS_VERSION);
+	LASSERTF(PTLRPC_MSG_VERSION == 0x00000003UL, "found 0x%.8xUL\n",
+		 (unsigned int)PTLRPC_MSG_VERSION);
+	LASSERTF(LUSTRE_VERSION_MASK == 0xffff0000UL, "found 0x%.8xUL\n",
+		 (unsigned int)LUSTRE_VERSION_MASK);
+	LASSERTF(LUSTRE_OBD_VERSION == 0x00010000UL, "found 0x%.8xUL\n",
+		 (unsigned int)LUSTRE_OBD_VERSION);
+	LASSERTF(LUSTRE_MDS_VERSION == 0x00020000UL, "found 0x%.8xUL\n",
+		 (unsigned int)LUSTRE_MDS_VERSION);
+	LASSERTF(LUSTRE_OST_VERSION == 0x00030000UL, "found 0x%.8xUL\n",
+		 (unsigned int)LUSTRE_OST_VERSION);
+	LASSERTF(LUSTRE_DLM_VERSION == 0x00040000UL, "found 0x%.8xUL\n",
+		 (unsigned int)LUSTRE_DLM_VERSION);
+	LASSERTF(LUSTRE_LOG_VERSION == 0x00050000UL, "found 0x%.8xUL\n",
+		 (unsigned int)LUSTRE_LOG_VERSION);
+	LASSERTF(LUSTRE_MGS_VERSION == 0x00060000UL, "found 0x%.8xUL\n",
+		 (unsigned int)LUSTRE_MGS_VERSION);
 	LASSERTF(MSGHDR_AT_SUPPORT == 1, "found %lld\n",
 		 (long long)MSGHDR_AT_SUPPORT);
 	LASSERTF(MSGHDR_CKSUM_INCOMPAT18 == 2, "found %lld\n",
@@ -1866,6 +1866,37 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct ll_fid *)0)->f_type) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct ll_fid *)0)->f_type));
 
+	LASSERTF(MDS_CHECK_SPLIT == 0x00000001UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_CHECK_SPLIT);
+	LASSERTF(MDS_CROSS_REF == 0x00000002UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_CROSS_REF);
+	LASSERTF(MDS_VTX_BYPASS == 0x00000004UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_VTX_BYPASS);
+	LASSERTF(MDS_PERM_BYPASS == 0x00000008UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_PERM_BYPASS);
+	LASSERTF(MDS_QUOTA_IGNORE == 0x00000020UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_QUOTA_IGNORE);
+	LASSERTF(MDS_KEEP_ORPHAN == 0x00000080UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_KEEP_ORPHAN);
+	LASSERTF(MDS_RECOV_OPEN == 0x00000100UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_RECOV_OPEN);
+	LASSERTF(MDS_DATA_MODIFIED == 0x00000200UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_DATA_MODIFIED);
+	LASSERTF(MDS_CREATE_VOLATILE == 0x00000400UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_CREATE_VOLATILE);
+	LASSERTF(MDS_OWNEROVERRIDE == 0x00000800UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_OWNEROVERRIDE);
+	LASSERTF(MDS_HSM_RELEASE == 0x00001000UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_HSM_RELEASE);
+	LASSERTF(MDS_CLOSE_LAYOUT_SWAP == 0x00004000UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_CLOSE_LAYOUT_SWAP);
+	LASSERTF(MDS_CLOSE_LAYOUT_MERGE == 0x00008000UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_CLOSE_LAYOUT_MERGE);
+	LASSERTF(MDS_CLOSE_RESYNC_DONE == 0x00010000UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_CLOSE_RESYNC_DONE);
+	LASSERTF(MDS_CLOSE_LAYOUT_SPLIT == 0x00020000UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_CLOSE_LAYOUT_SPLIT);
+
 	/* Checks for struct mdt_body */
 	LASSERTF((int)sizeof(struct mdt_body) == 216, "found %lld\n",
 		 (long long)(int)sizeof(struct mdt_body));
@@ -1905,6 +1936,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct mdt_body, mbo_blocks));
 	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_blocks) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_blocks));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_version) == 88, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_version));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_version) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_version));
 	LASSERTF((int)offsetof(struct mdt_body, mbo_t_state) == 96, "found %lld\n",
 		 (long long)(int)offsetof(struct mdt_body, mbo_t_state));
 	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_t_state) == 8,
@@ -1946,10 +1981,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct mdt_body, mbo_nlink));
 	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_nlink) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_nlink));
-	LASSERTF((int)offsetof(struct mdt_body, mbo_unused2) == 140, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, mbo_unused2));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_unused2) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_unused2));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_layout_gen) == 140, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_layout_gen));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_layout_gen) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_layout_gen));
 	LASSERTF((int)offsetof(struct mdt_body, mbo_suppgid) == 144, "found %lld\n",
 		 (long long)(int)offsetof(struct mdt_body, mbo_suppgid));
 	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_suppgid) == 4, "found %lld\n",
@@ -4398,12 +4433,14 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct hsm_request, hr_data_len));
 	LASSERTF((int)sizeof(((struct hsm_request *)0)->hr_data_len) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct hsm_request *)0)->hr_data_len));
+#ifdef HAVE_SERVER_SUPPORT
 	LASSERTF(HSM_FORCE_ACTION == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)HSM_FORCE_ACTION);
 	LASSERTF(HSM_GHOST_COPY == 0x00000002UL, "found 0x%.8xUL\n",
 		 (unsigned int)HSM_GHOST_COPY);
 
 	/* Checks for struct hsm_user_request */
+#endif
 	LASSERTF((int)sizeof(struct hsm_user_request) == 24, "found %lld\n",
 		 (long long)(int)sizeof(struct hsm_user_request));
 	LASSERTF((int)offsetof(struct hsm_user_request, hur_request) == 0, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 1d8c607..6ef7d45 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1539,7 +1539,7 @@ struct mdt_body {
 	__s64	mbo_atime;
 	__s64	mbo_ctime;
 	__u64	mbo_blocks;	/* XID, in the case of MDS_READPAGE */
-	__u64	mbo_ioepoch;
+	__u64	mbo_version; /* was mbo_ioepoch before 2.11 */
 	__u64	mbo_t_state;	/* transient file state defined in
 				 * enum md_transient_state
 				 * was "ino" until 2.4.0
@@ -1553,7 +1553,7 @@ struct mdt_body {
 	__u32	mbo_flags;	/* LUSTRE_*_FL file attributes */
 	__u32	mbo_rdev;
 	__u32	mbo_nlink;	/* #bytes to read in the case of MDS_READPAGE */
-	__u32	mbo_unused2;	/* was "generation" until 2.4.0 */
+	__u32	mbo_layout_gen;	/* was "generation" until 2.4.0 */
 	__u32	mbo_suppgid;
 	__u32	mbo_eadatasize;
 	__u32	mbo_aclsize;
-- 
1.8.3.1
