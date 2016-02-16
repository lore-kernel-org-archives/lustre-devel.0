From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:53 -0500
Subject: [lustre-devel] [PATCH 21/45] staging/lustre/mdc: Adjust NULL
	comparison codestyle
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-22-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

All instances of "x == NULL" are changed to "!x" and
"x != NULL" to "x"

Also remove some redundant assertions.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/mdc/mdc_lib.c     |  12 +--
 drivers/staging/lustre/lustre/mdc/mdc_locks.c   |  47 +++++-----
 drivers/staging/lustre/lustre/mdc/mdc_reint.c   |  24 ++---
 drivers/staging/lustre/lustre/mdc/mdc_request.c | 116 ++++++++++++------------
 4 files changed, 90 insertions(+), 109 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 7218532..ea2ab23 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -41,8 +41,6 @@
 
 static void __mdc_pack_body(struct mdt_body *b, __u32 suppgid)
 {
-	LASSERT(b != NULL);
-
 	b->suppgid = suppgid;
 	b->uid = from_kuid(&init_user_ns, current_uid());
 	b->gid = from_kgid(&init_user_ns, current_gid());
@@ -83,7 +81,6 @@ void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
 {
 	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
 						    &RMF_MDT_BODY);
-	LASSERT(b != NULL);
 	b->valid = valid;
 	b->eadatasize = ea_size;
 	b->flags = flags;
@@ -323,7 +320,7 @@ void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		return;
 
 	lum = req_capsule_client_get(&req->rq_pill, &RMF_EADATA);
-	if (ea == NULL) { /* Remove LOV EA */
+	if (!ea) { /* Remove LOV EA */
 		lum->lmm_magic = LOV_USER_MAGIC_V1;
 		lum->lmm_stripe_size = 0;
 		lum->lmm_stripe_count = 0;
@@ -346,7 +343,6 @@ void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 
 	CLASSERT(sizeof(struct mdt_rec_reint) == sizeof(struct mdt_rec_unlink));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
-	LASSERT(rec != NULL);
 
 	rec->ul_opcode   = op_data->op_cli_flags & CLI_RM_ENTRY ?
 					REINT_RMENTRY : REINT_UNLINK;
@@ -362,7 +358,7 @@ void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 	rec->ul_bias     = op_data->op_bias;
 
 	tmp = req_capsule_client_get(&req->rq_pill, &RMF_NAME);
-	LASSERT(tmp != NULL);
+	LASSERT(tmp);
 	LOGL0(op_data->op_name, op_data->op_namelen, tmp);
 }
 
@@ -373,7 +369,6 @@ void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 
 	CLASSERT(sizeof(struct mdt_rec_reint) == sizeof(struct mdt_rec_link));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
-	LASSERT(rec != NULL);
 
 	rec->lk_opcode   = REINT_LINK;
 	rec->lk_fsuid    = op_data->op_fsuid; /* current->fsuid; */
@@ -456,10 +451,9 @@ static void mdc_hsm_release_pack(struct ptlrpc_request *req,
 		struct ldlm_lock *lock;
 
 		data = req_capsule_client_get(&req->rq_pill, &RMF_CLOSE_DATA);
-		LASSERT(data != NULL);
 
 		lock = ldlm_handle2lock(&op_data->op_lease_handle);
-		if (lock != NULL) {
+		if (lock) {
 			data->cd_handle = lock->l_remote_handle;
 			ldlm_lock_put(lock);
 		}
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index ef9a1e1..09dd2b3 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -129,7 +129,7 @@ int mdc_set_lock_data(struct obd_export *exp, __u64 *lockh, void *data,
 
 	lock = ldlm_handle2lock((struct lustre_handle *)lockh);
 
-	LASSERT(lock != NULL);
+	LASSERT(lock);
 	lock_res_and_lock(lock);
 	if (lock->l_resource->lr_lvb_inode &&
 	    lock->l_resource->lr_lvb_inode != data) {
@@ -191,12 +191,12 @@ int mdc_null_inode(struct obd_export *exp,
 	struct ldlm_resource *res;
 	struct ldlm_namespace *ns = class_exp2obd(exp)->obd_namespace;
 
-	LASSERTF(ns != NULL, "no namespace passed\n");
+	LASSERTF(ns, "no namespace passed\n");
 
 	fid_build_reg_res_name(fid, &res_id);
 
 	res = ldlm_resource_get(ns, NULL, &res_id, 0, 0);
-	if (res == NULL)
+	if (!res)
 		return 0;
 
 	lock_res(res);
@@ -317,7 +317,7 @@ static struct ptlrpc_request *mdc_intent_open_pack(struct obd_export *exp,
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_LDLM_INTENT_OPEN);
-	if (req == NULL) {
+	if (!req) {
 		ldlm_lock_list_put(&cancels, l_bl_ast, count);
 		return ERR_PTR(-ENOMEM);
 	}
@@ -365,7 +365,7 @@ mdc_intent_getxattr_pack(struct obd_export *exp,
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 					&RQF_LDLM_INTENT_GETXATTR);
-	if (req == NULL)
+	if (!req)
 		return ERR_PTR(-ENOMEM);
 
 	rc = ldlm_prep_enqueue_req(exp, req, &cancels, count);
@@ -409,7 +409,7 @@ static struct ptlrpc_request *mdc_intent_unlink_pack(struct obd_export *exp,
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_LDLM_INTENT_UNLINK);
-	if (req == NULL)
+	if (!req)
 		return ERR_PTR(-ENOMEM);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_NAME, RCL_CLIENT,
@@ -453,7 +453,7 @@ static struct ptlrpc_request *mdc_intent_getattr_pack(struct obd_export *exp,
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_LDLM_INTENT_GETATTR);
-	if (req == NULL)
+	if (!req)
 		return ERR_PTR(-ENOMEM);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_NAME, RCL_CLIENT,
@@ -497,7 +497,7 @@ static struct ptlrpc_request *mdc_intent_layout_pack(struct obd_export *exp,
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				&RQF_LDLM_INTENT_LAYOUT);
-	if (req == NULL)
+	if (!req)
 		return ERR_PTR(-ENOMEM);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_CLIENT, 0);
@@ -530,7 +530,7 @@ mdc_enqueue_pack(struct obd_export *exp, int lvb_len)
 	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_LDLM_ENQUEUE);
-	if (req == NULL)
+	if (!req)
 		return ERR_PTR(-ENOMEM);
 
 	rc = ldlm_prep_enqueue_req(exp, req, NULL, 0);
@@ -573,7 +573,6 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 		rc = 0;
 	} else { /* rc = 0 */
 		lock = ldlm_handle2lock(lockh);
-		LASSERT(lock != NULL);
 
 		/* If the server gave us back a different lock mode, we should
 		 * fix up our variables. */
@@ -586,7 +585,6 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 	}
 
 	lockrep = req_capsule_server_get(pill, &RMF_DLM_REP);
-	LASSERT(lockrep != NULL); /* checked by ldlm_cli_enqueue() */
 
 	intent->it_disposition = (int)lockrep->lock_policy_res1;
 	intent->it_status = (int)lockrep->lock_policy_res2;
@@ -618,7 +616,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 		struct mdt_body *body;
 
 		body = req_capsule_server_get(pill, &RMF_MDT_BODY);
-		if (body == NULL) {
+		if (!body) {
 			CERROR("Can't swab mdt_body\n");
 			return -EPROTO;
 		}
@@ -645,7 +643,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 			 */
 			eadata = req_capsule_server_sized_get(pill, &RMF_MDT_MD,
 							      body->eadatasize);
-			if (eadata == NULL)
+			if (!eadata)
 				return -EPROTO;
 
 			/* save lvb data and length in case this is for layout
@@ -690,7 +688,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 			LASSERT(client_is_remote(exp));
 			perm = req_capsule_server_swab_get(pill, &RMF_ACL,
 						lustre_swab_mdt_remote_perm);
-			if (perm == NULL)
+			if (!perm)
 				return -EPROTO;
 		}
 	} else if (it->it_op & IT_LAYOUT) {
@@ -700,21 +698,21 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 		if (lvb_len > 0) {
 			lvb_data = req_capsule_server_sized_get(pill,
 							&RMF_DLM_LVB, lvb_len);
-			if (lvb_data == NULL)
+			if (!lvb_data)
 				return -EPROTO;
 		}
 	}
 
 	/* fill in stripe data for layout lock */
 	lock = ldlm_handle2lock(lockh);
-	if (lock != NULL && ldlm_has_layout(lock) && lvb_data != NULL) {
+	if (lock && ldlm_has_layout(lock) && lvb_data) {
 		void *lmm;
 
 		LDLM_DEBUG(lock, "layout lock returned by: %s, lvb_len: %d\n",
 			ldlm_it2str(it->it_op), lvb_len);
 
 		lmm = libcfs_kvzalloc(lvb_len, GFP_NOFS);
-		if (lmm == NULL) {
+		if (!lmm) {
 			LDLM_LOCK_PUT(lock);
 			return -ENOMEM;
 		}
@@ -722,17 +720,17 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 
 		/* install lvb_data */
 		lock_res_and_lock(lock);
-		if (lock->l_lvb_data == NULL) {
+		if (!lock->l_lvb_data) {
 			lock->l_lvb_type = LVB_T_LAYOUT;
 			lock->l_lvb_data = lmm;
 			lock->l_lvb_len = lvb_len;
 			lmm = NULL;
 		}
 		unlock_res_and_lock(lock);
-		if (lmm != NULL)
+		if (lmm)
 			kvfree(lmm);
 	}
-	if (lock != NULL)
+	if (lock)
 		LDLM_LOCK_PUT(lock);
 
 	return rc;
@@ -782,7 +780,7 @@ int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 			policy = &getxattr_policy;
 	}
 
-	LASSERT(reqp == NULL);
+	LASSERT(!reqp);
 
 	generation = obddev->u.cli.cl_import->imp_generation;
 resend:
@@ -823,7 +821,7 @@ resend:
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 
-	if (req != NULL && it && it->it_op & IT_CREAT)
+	if (req && it && it->it_op & IT_CREAT)
 		/* ask ptlrpc not to resend on EINPROGRESS since we have our own
 		 * retry logic */
 		req->rq_no_retry_einprogress = 1;
@@ -878,7 +876,6 @@ resend:
 	}
 
 	lockrep = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
-	LASSERT(lockrep != NULL);
 
 	lockrep->lock_policy_res2 =
 		ptlrpc_status_ntoh(lockrep->lock_policy_res2);
@@ -930,7 +927,6 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 	struct ldlm_lock *lock;
 	int rc;
 
-	LASSERT(request != NULL);
 	LASSERT(request != LP_POISON);
 	LASSERT(request->rq_repmsg != LP_POISON);
 
@@ -945,7 +941,7 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 		return rc;
 
 	mdt_body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
-	LASSERT(mdt_body != NULL);      /* mdc_enqueue checked */
+	LASSERT(mdt_body);      /* mdc_enqueue checked */
 
 	/* If we were revalidating a fid/name pair, mark the intent in
 	 * case we fail and get called again from lookup */
@@ -1206,7 +1202,6 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 	}
 
 	lockrep = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
-	LASSERT(lockrep != NULL);
 
 	lockrep->lock_policy_res2 =
 		ptlrpc_status_ntoh(lockrep->lock_policy_res2);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index ac7695a..ddeb4b4 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -88,7 +88,7 @@ int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 	fid_build_reg_res_name(fid, &res_id);
 	res = ldlm_resource_get(exp->exp_obd->obd_namespace,
 				NULL, &res_id, 0, 0);
-	if (res == NULL)
+	if (!res)
 		return 0;
 	LDLM_RESOURCE_ADDREF(res);
 	/* Initialize ibits lock policy. */
@@ -111,8 +111,6 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 	int count = 0, rc;
 	__u64 bits;
 
-	LASSERT(op_data != NULL);
-
 	bits = MDS_INODELOCK_UPDATE;
 	if (op_data->op_attr.ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID))
 		bits |= MDS_INODELOCK_LOOKUP;
@@ -123,7 +121,7 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 						&cancels, LCK_EX, bits);
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_REINT_SETATTR);
-	if (req == NULL) {
+	if (!req) {
 		ldlm_lock_list_put(&cancels, l_bl_ast, count);
 		return -ENOMEM;
 	}
@@ -151,10 +149,10 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 	ptlrpc_request_set_replen(req);
 	if (mod && (op_data->op_flags & MF_EPOCH_OPEN) &&
 	    req->rq_import->imp_replayable) {
-		LASSERT(*mod == NULL);
+		LASSERT(!*mod);
 
 		*mod = obd_mod_alloc();
-		if (*mod == NULL) {
+		if (!*mod) {
 			DEBUG_REQ(D_ERROR, req, "Can't allocate md_open_data");
 		} else {
 			req->rq_replay = 1;
@@ -181,8 +179,6 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 
 		epoch = req_capsule_client_get(&req->rq_pill, &RMF_MDT_EPOCH);
 		body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-		LASSERT(epoch != NULL);
-		LASSERT(body != NULL);
 		epoch->handle = body->handle;
 		epoch->ioepoch = body->ioepoch;
 		req->rq_replay_cb = mdc_replay_open;
@@ -195,7 +191,7 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 	*request = req;
 	if (rc && req->rq_commit_cb) {
 		/* Put an extra reference on \var mod on error case. */
-		if (mod != NULL && *mod != NULL)
+		if (mod && *mod)
 			obd_mod_put(*mod);
 		req->rq_commit_cb(req);
 	}
@@ -237,7 +233,7 @@ rebuild:
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_REINT_CREATE_RMT_ACL);
-	if (req == NULL) {
+	if (!req) {
 		ldlm_lock_list_put(&cancels, l_bl_ast, count);
 		return -ENOMEM;
 	}
@@ -308,7 +304,7 @@ int mdc_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	struct ptlrpc_request *req = *request;
 	int count = 0, rc;
 
-	LASSERT(req == NULL);
+	LASSERT(!req);
 
 	if ((op_data->op_flags & MF_MDC_CANCEL_FID1) &&
 	    (fid_is_sane(&op_data->op_fid1)) &&
@@ -324,7 +320,7 @@ int mdc_unlink(struct obd_export *exp, struct md_op_data *op_data,
 						 MDS_INODELOCK_FULL);
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_REINT_UNLINK);
-	if (req == NULL) {
+	if (!req) {
 		ldlm_lock_list_put(&cancels, l_bl_ast, count);
 		return -ENOMEM;
 	}
@@ -373,7 +369,7 @@ int mdc_link(struct obd_export *exp, struct md_op_data *op_data,
 						 MDS_INODELOCK_UPDATE);
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_MDS_REINT_LINK);
-	if (req == NULL) {
+	if (!req) {
 		ldlm_lock_list_put(&cancels, l_bl_ast, count);
 		return -ENOMEM;
 	}
@@ -429,7 +425,7 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_REINT_RENAME);
-	if (req == NULL) {
+	if (!req) {
 		ldlm_lock_list_put(&cancels, l_bl_ast, count);
 		return -ENOMEM;
 	}
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 4348127..3d00f53 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -83,7 +83,7 @@ static int mdc_getstatus(struct obd_export *exp, struct lu_fid *rootfid)
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
 					&RQF_MDS_GETSTATUS,
 					LUSTRE_MDS_VERSION, MDS_GETSTATUS);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	mdc_pack_body(req, NULL, 0, 0, -1, 0);
@@ -96,7 +96,7 @@ static int mdc_getstatus(struct obd_export *exp, struct lu_fid *rootfid)
 		goto out;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-	if (body == NULL) {
+	if (!body) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -136,7 +136,7 @@ static int mdc_getattr_common(struct obd_export *exp,
 
 	/* sanity check for the reply */
 	body = req_capsule_server_get(pill, &RMF_MDT_BODY);
-	if (body == NULL)
+	if (!body)
 		return -EPROTO;
 
 	CDEBUG(D_NET, "mode: %o\n", body->mode);
@@ -146,7 +146,7 @@ static int mdc_getattr_common(struct obd_export *exp,
 
 		eadata = req_capsule_server_sized_get(pill, &RMF_MDT_MD,
 						      body->eadatasize);
-		if (eadata == NULL)
+		if (!eadata)
 			return -EPROTO;
 	}
 
@@ -156,7 +156,7 @@ static int mdc_getattr_common(struct obd_export *exp,
 		LASSERT(client_is_remote(exp));
 		perm = req_capsule_server_swab_get(pill, &RMF_ACL,
 						lustre_swab_mdt_remote_perm);
-		if (perm == NULL)
+		if (!perm)
 			return -EPROTO;
 	}
 
@@ -176,7 +176,7 @@ static int mdc_getattr(struct obd_export *exp, struct md_op_data *op_data,
 	}
 	*request = NULL;
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_MDS_GETATTR);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_GETATTR);
@@ -214,7 +214,7 @@ static int mdc_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 	*request = NULL;
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_GETATTR_NAME);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	req_capsule_set_size(&req->rq_pill, &RMF_NAME, RCL_CLIENT,
@@ -261,7 +261,7 @@ static int mdc_is_subdir(struct obd_export *exp,
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
 					&RQF_MDS_IS_SUBDIR, LUSTRE_MDS_VERSION,
 					MDS_IS_SUBDIR);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	mdc_is_subdir_pack(req, pfid, cfid, 0);
@@ -290,7 +290,7 @@ static int mdc_xattr_common(struct obd_export *exp,
 
 	*request = NULL;
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), fmt);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	if (xattr_name) {
@@ -425,7 +425,7 @@ static int mdc_unpack_acl(struct ptlrpc_request *req, struct lustre_md *md)
 		return -EPROTO;
 
 	acl = posix_acl_from_xattr(&init_user_ns, buf, body->aclsize);
-	if (acl == NULL)
+	if (!acl)
 		return 0;
 
 	if (IS_ERR(acl)) {
@@ -461,7 +461,6 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 	memset(md, 0, sizeof(*md));
 
 	md->body = req_capsule_server_get(pill, &RMF_MDT_BODY);
-	LASSERT(md->body != NULL);
 
 	if (md->body->valid & OBD_MD_FLEASIZE) {
 		int lmmsize;
@@ -593,17 +592,16 @@ void mdc_replay_open(struct ptlrpc_request *req)
 	struct lustre_handle old;
 	struct mdt_body *body;
 
-	if (mod == NULL) {
+	if (!mod) {
 		DEBUG_REQ(D_ERROR, req,
 			  "Can't properly replay without open data.");
 		return;
 	}
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-	LASSERT(body != NULL);
 
 	och = mod->mod_och;
-	if (och != NULL) {
+	if (och) {
 		struct lustre_handle *file_fh;
 
 		LASSERT(och->och_magic == OBD_CLIENT_HANDLE_MAGIC);
@@ -615,7 +613,7 @@ void mdc_replay_open(struct ptlrpc_request *req)
 		*file_fh = body->handle;
 	}
 	close_req = mod->mod_close_req;
-	if (close_req != NULL) {
+	if (close_req) {
 		__u32 opc = lustre_msg_get_opc(close_req->rq_reqmsg);
 		struct mdt_ioepoch *epoch;
 
@@ -624,7 +622,7 @@ void mdc_replay_open(struct ptlrpc_request *req)
 					       &RMF_MDT_EPOCH);
 		LASSERT(epoch);
 
-		if (och != NULL)
+		if (och)
 			LASSERT(!memcmp(&old, &epoch->handle, sizeof(old)));
 		DEBUG_REQ(D_HA, close_req, "updating close body with new fh");
 		epoch->handle = body->handle;
@@ -635,7 +633,7 @@ void mdc_commit_open(struct ptlrpc_request *req)
 {
 	struct md_open_data *mod = req->rq_cb_data;
 
-	if (mod == NULL)
+	if (!mod)
 		return;
 
 	/**
@@ -675,15 +673,15 @@ int mdc_set_open_replay_data(struct obd_export *exp,
 
 	rec = req_capsule_client_get(&open_req->rq_pill, &RMF_REC_REINT);
 	body = req_capsule_server_get(&open_req->rq_pill, &RMF_MDT_BODY);
-	LASSERT(rec != NULL);
+	LASSERT(rec);
 	/* Incoming message in my byte order (it's been swabbed). */
 	/* Outgoing messages always in my byte order. */
-	LASSERT(body != NULL);
+	LASSERT(body);
 
 	/* Only if the import is replayable, we set replay_open data */
 	if (och && imp->imp_replayable) {
 		mod = obd_mod_alloc();
-		if (mod == NULL) {
+		if (!mod) {
 			DEBUG_REQ(D_ERROR, open_req,
 				  "Can't allocate md_open_data");
 			return 0;
@@ -749,11 +747,11 @@ static int mdc_clear_open_replay_data(struct obd_export *exp,
 	 * It is possible to not have \var mod in a case of eviction between
 	 * lookup and ll_file_open().
 	 **/
-	if (mod == NULL)
+	if (!mod)
 		return 0;
 
 	LASSERT(mod != LP_POISON);
-	LASSERT(mod->mod_open_req != NULL);
+	LASSERT(mod->mod_open_req);
 	mdc_free_open(mod);
 
 	mod->mod_och = NULL;
@@ -804,7 +802,7 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 
 	*request = NULL;
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), req_fmt);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_CLOSE);
@@ -820,8 +818,8 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 	ptlrpc_at_set_req_timeout(req);
 
 	/* Ensure that this close's handle is fixed up during replay. */
-	if (likely(mod != NULL)) {
-		LASSERTF(mod->mod_open_req != NULL &&
+	if (likely(mod)) {
+		LASSERTF(mod->mod_open_req &&
 			 mod->mod_open_req->rq_type != LI_POISON,
 			 "POISONED open %p!\n", mod->mod_open_req);
 
@@ -851,7 +849,7 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 	rc = ptlrpc_queue_wait(req);
 	mdc_put_rpc_lock(obd->u.cli.cl_close_lock, NULL);
 
-	if (req->rq_repmsg == NULL) {
+	if (!req->rq_repmsg) {
 		CDEBUG(D_RPCTRACE, "request failed to send: %p, %d\n", req,
 		       req->rq_status);
 		if (rc == 0)
@@ -867,7 +865,7 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 				rc = -rc;
 		}
 		body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-		if (body == NULL)
+		if (!body)
 			rc = -EPROTO;
 	} else if (rc == -ESTALE) {
 		/**
@@ -877,7 +875,6 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 		 */
 		if (mod) {
 			DEBUG_REQ(D_HA, req, "Reset ESTALE = %d", rc);
-			LASSERT(mod->mod_open_req != NULL);
 			if (mod->mod_open_req->rq_committed)
 				rc = 0;
 		}
@@ -904,7 +901,7 @@ static int mdc_done_writing(struct obd_export *exp, struct md_op_data *op_data,
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_DONE_WRITING);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_DONE_WRITING);
@@ -913,8 +910,8 @@ static int mdc_done_writing(struct obd_export *exp, struct md_op_data *op_data,
 		return rc;
 	}
 
-	if (mod != NULL) {
-		LASSERTF(mod->mod_open_req != NULL &&
+	if (mod) {
+		LASSERTF(mod->mod_open_req &&
 			 mod->mod_open_req->rq_type != LI_POISON,
 			 "POISONED setattr %p!\n", mod->mod_open_req);
 
@@ -941,7 +938,6 @@ static int mdc_done_writing(struct obd_export *exp, struct md_op_data *op_data,
 		 * Let's check if mod exists and return no error in that case
 		 */
 		if (mod) {
-			LASSERT(mod->mod_open_req != NULL);
 			if (mod->mod_open_req->rq_committed)
 				rc = 0;
 		}
@@ -950,7 +946,7 @@ static int mdc_done_writing(struct obd_export *exp, struct md_op_data *op_data,
 	if (mod) {
 		if (rc != 0)
 			mod->mod_close_req = NULL;
-		LASSERT(mod->mod_open_req != NULL);
+		LASSERT(mod->mod_open_req);
 		mdc_free_open(mod);
 
 		/* Since now, mod is accessed through setattr req only,
@@ -979,7 +975,7 @@ static int mdc_readpage(struct obd_export *exp, struct md_op_data *op_data,
 
 restart_bulk:
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_MDS_READPAGE);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_READPAGE);
@@ -993,7 +989,7 @@ restart_bulk:
 
 	desc = ptlrpc_prep_bulk_imp(req, op_data->op_npages, 1, BULK_PUT_SINK,
 				    MDS_BULK_PORTAL);
-	if (desc == NULL) {
+	if (!desc) {
 		ptlrpc_request_free(req);
 		return -ENOMEM;
 	}
@@ -1067,7 +1063,7 @@ static int mdc_statfs(const struct lu_env *env,
 
 	req = ptlrpc_request_alloc_pack(imp, &RQF_MDS_STATFS,
 					LUSTRE_MDS_VERSION, MDS_STATFS);
-	if (req == NULL) {
+	if (!req) {
 		rc = -ENOMEM;
 		goto output;
 	}
@@ -1089,7 +1085,7 @@ static int mdc_statfs(const struct lu_env *env,
 	}
 
 	msfs = req_capsule_server_get(&req->rq_pill, &RMF_OBD_STATFS);
-	if (msfs == NULL) {
+	if (!msfs) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -1162,7 +1158,7 @@ static int mdc_ioc_hsm_progress(struct obd_export *exp,
 
 	req = ptlrpc_request_alloc_pack(imp, &RQF_MDS_HSM_PROGRESS,
 					LUSTRE_MDS_VERSION, MDS_HSM_PROGRESS);
-	if (req == NULL) {
+	if (!req) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -1171,7 +1167,7 @@ static int mdc_ioc_hsm_progress(struct obd_export *exp,
 
 	/* Copy hsm_progress struct */
 	req_hpk = req_capsule_client_get(&req->rq_pill, &RMF_MDS_HSM_PROGRESS);
-	if (req_hpk == NULL) {
+	if (!req_hpk) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -1196,7 +1192,7 @@ static int mdc_ioc_hsm_ct_register(struct obd_import *imp, __u32 archives)
 	req = ptlrpc_request_alloc_pack(imp, &RQF_MDS_HSM_CT_REGISTER,
 					LUSTRE_MDS_VERSION,
 					MDS_HSM_CT_REGISTER);
-	if (req == NULL) {
+	if (!req) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -1206,7 +1202,7 @@ static int mdc_ioc_hsm_ct_register(struct obd_import *imp, __u32 archives)
 	/* Copy hsm_progress struct */
 	archive_mask = req_capsule_client_get(&req->rq_pill,
 					      &RMF_MDS_HSM_ARCHIVE);
-	if (archive_mask == NULL) {
+	if (!archive_mask) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -1231,7 +1227,7 @@ static int mdc_ioc_hsm_current_action(struct obd_export *exp,
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_HSM_ACTION);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_HSM_ACTION);
@@ -1251,7 +1247,7 @@ static int mdc_ioc_hsm_current_action(struct obd_export *exp,
 
 	req_hca = req_capsule_server_get(&req->rq_pill,
 					 &RMF_MDS_HSM_CURRENT_ACTION);
-	if (req_hca == NULL) {
+	if (!req_hca) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -1271,7 +1267,7 @@ static int mdc_ioc_hsm_ct_unregister(struct obd_import *imp)
 	req = ptlrpc_request_alloc_pack(imp, &RQF_MDS_HSM_CT_UNREGISTER,
 					LUSTRE_MDS_VERSION,
 					MDS_HSM_CT_UNREGISTER);
-	if (req == NULL) {
+	if (!req) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -1296,7 +1292,7 @@ static int mdc_ioc_hsm_state_get(struct obd_export *exp,
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_HSM_STATE_GET);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_HSM_STATE_GET);
@@ -1315,7 +1311,7 @@ static int mdc_ioc_hsm_state_get(struct obd_export *exp,
 		goto out;
 
 	req_hus = req_capsule_server_get(&req->rq_pill, &RMF_HSM_USER_STATE);
-	if (req_hus == NULL) {
+	if (!req_hus) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -1337,7 +1333,7 @@ static int mdc_ioc_hsm_state_set(struct obd_export *exp,
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_HSM_STATE_SET);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_HSM_STATE_SET);
@@ -1351,7 +1347,7 @@ static int mdc_ioc_hsm_state_set(struct obd_export *exp,
 
 	/* Copy states */
 	req_hss = req_capsule_client_get(&req->rq_pill, &RMF_HSM_STATE_SET);
-	if (req_hss == NULL) {
+	if (!req_hss) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -1376,7 +1372,7 @@ static int mdc_ioc_hsm_request(struct obd_export *exp,
 	int			 rc;
 
 	req = ptlrpc_request_alloc(imp, &RQF_MDS_HSM_REQUEST);
-	if (req == NULL) {
+	if (!req) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -1397,7 +1393,7 @@ static int mdc_ioc_hsm_request(struct obd_export *exp,
 
 	/* Copy hsm_request struct */
 	req_hr = req_capsule_client_get(&req->rq_pill, &RMF_MDS_HSM_REQUEST);
-	if (req_hr == NULL) {
+	if (!req_hr) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -1405,7 +1401,7 @@ static int mdc_ioc_hsm_request(struct obd_export *exp,
 
 	/* Copy hsm_user_item structs */
 	req_hui = req_capsule_client_get(&req->rq_pill, &RMF_MDS_HSM_USER_ITEM);
-	if (req_hui == NULL) {
+	if (!req_hui) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -1414,7 +1410,7 @@ static int mdc_ioc_hsm_request(struct obd_export *exp,
 
 	/* Copy opaque field */
 	req_opaque = req_capsule_client_get(&req->rq_pill, &RMF_GENERIC_DATA);
-	if (req_opaque == NULL) {
+	if (!req_opaque) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -1513,7 +1509,7 @@ static int mdc_changelog_send_thread(void *csdata)
 
 	/* Set up the remote catalog handle */
 	ctxt = llog_get_context(cs->cs_obd, LLOG_CHANGELOG_REPL_CTXT);
-	if (ctxt == NULL) {
+	if (!ctxt) {
 		rc = -ENOENT;
 		goto out;
 	}
@@ -1597,7 +1593,7 @@ static int mdc_quotacheck(struct obd_device *unused, struct obd_export *exp,
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
 					&RQF_MDS_QUOTACHECK, LUSTRE_MDS_VERSION,
 					MDS_QUOTACHECK);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	body = req_capsule_client_get(&req->rq_pill, &RMF_OBD_QUOTACTL);
@@ -1641,7 +1637,7 @@ static int mdc_quotactl(struct obd_device *unused, struct obd_export *exp,
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
 					&RQF_MDS_QUOTACTL, LUSTRE_MDS_VERSION,
 					MDS_QUOTACTL);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	oqc = req_capsule_client_get(&req->rq_pill, &RMF_OBD_QUOTACTL);
@@ -1695,7 +1691,7 @@ static int mdc_ioc_swap_layouts(struct obd_export *exp,
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_SWAP_LAYOUTS);
-	if (req == NULL) {
+	if (!req) {
 		ldlm_lock_list_put(&cancels, l_bl_ast, count);
 		return -ENOMEM;
 	}
@@ -1881,7 +1877,7 @@ static int mdc_get_info_rpc(struct obd_export *exp,
 	int		     rc = -EINVAL;
 
 	req = ptlrpc_request_alloc(imp, &RQF_MDS_GET_INFO);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	req_capsule_set_size(&req->rq_pill, &RMF_GETINFO_KEY,
@@ -2140,7 +2136,7 @@ static int mdc_sync(struct obd_export *exp, const struct lu_fid *fid,
 
 	*request = NULL;
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_MDS_SYNC);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_SYNC);
@@ -2182,7 +2178,7 @@ static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 		 * Flush current sequence to make client obtain new one
 		 * from server in case of disconnect/reconnect.
 		 */
-		if (cli->cl_seq != NULL)
+		if (cli->cl_seq)
 			seq_client_flush(cli->cl_seq);
 
 		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_INACTIVE, NULL);
@@ -2429,7 +2425,7 @@ static int mdc_get_remote_perm(struct obd_export *exp, const struct lu_fid *fid,
 
 	*request = NULL;
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_MDS_GETATTR);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_GETATTR);
-- 
2.1.0
