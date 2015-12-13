From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 14:54:12 +0100
Subject: [lustre-devel] [PATCH 2/7] staging: lustre: Rename a jump label for
 ptlrpc_req_finished() calls
In-Reply-To: <566D7733.1030102@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
Message-ID: <566D7884.5050407@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 10:33:38 +0100

This issue was detected by using the Coccinelle software.

Choose a jump label according to the current Linux coding style convention.
I suggest to improve this implementation detail by the reuse of a script
like the following for the semantic patch language.

@rename_jump_label exists@
identifier work;
type return_type;
@@
 return_type work(...)
 {
 ... when any
 goto
-out
+finish_request
 ;
 ... when any
-out
+finish_request
 :
 ptlrpc_req_finished(...);
 ... when any
 }

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/llite/file.c         | 26 +++++------
 drivers/staging/lustre/lustre/llite/namei.c        | 12 ++---
 drivers/staging/lustre/lustre/llite/xattr.c        | 20 ++++----
 drivers/staging/lustre/lustre/mdc/mdc_request.c    | 54 +++++++++++-----------
 drivers/staging/lustre/lustre/osc/osc_request.c    | 28 +++++------
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c | 22 ++++-----
 6 files changed, 81 insertions(+), 81 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 31cd6b3..b94df54 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -427,27 +427,27 @@ static int ll_intent_file_open(struct dentry *dentry, void *lmm,
 		*/
 		if (!it_disposition(itp, DISP_OPEN_OPEN) ||
 		     it_open_error(DISP_OPEN_OPEN, itp))
-			goto out;
+			goto finish_request;
 		ll_release_openhandle(inode, itp);
-		goto out;
+		goto finish_request;
 	}
 
 	if (it_disposition(itp, DISP_LOOKUP_NEG)) {
 		rc = -ENOENT;
-		goto out;
+		goto finish_request;
 	}
 
 	if (rc != 0 || it_open_error(DISP_OPEN_OPEN, itp)) {
 		rc = rc ? rc : it_open_error(DISP_OPEN_OPEN, itp);
 		CDEBUG(D_VFSTRACE, "lock enqueue: err: %d\n", rc);
-		goto out;
+		goto finish_request;
 	}
 
 	rc = ll_prep_inode(&inode, req, NULL, itp);
 	if (!rc && itp->d.lustre.it_lock_mode)
 		ll_set_lock_data(sbi->ll_md_exp, inode, itp, NULL);
 
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 	ll_intent_drop_lock(itp);
 
@@ -2900,13 +2900,13 @@ static int __ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 		oit.it_create_mode &= ~M_CHECK_STALE;
 		if (rc < 0) {
 			rc = ll_inode_revalidate_fini(inode, rc);
-			goto out;
+			goto finish_request;
 		}
 
 		rc = ll_revalidate_it_finish(req, &oit, inode);
 		if (rc != 0) {
 			ll_intent_release(&oit);
-			goto out;
+			goto finish_request;
 		}
 
 		/* Unlinked? Unhash dentry, so it is not picked up later by
@@ -2946,7 +2946,7 @@ static int __ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 
 		rc = ll_prep_inode(&inode, req, NULL, NULL);
 	}
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -3315,25 +3315,25 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 	if (body == NULL) {
 		rc = -EPROTO;
-		goto out;
+		goto finish_request;
 	}
 
 	lmmsize = body->eadatasize;
 	if (lmmsize == 0) /* empty layout */ {
 		rc = 0;
-		goto out;
+		goto finish_request;
 	}
 
 	lmm = req_capsule_server_sized_get(&req->rq_pill, &RMF_EADATA, lmmsize);
 	if (lmm == NULL) {
 		rc = -EFAULT;
-		goto out;
+		goto finish_request;
 	}
 
 	lvbdata = libcfs_kvzalloc(lmmsize, GFP_NOFS);
 	if (lvbdata == NULL) {
 		rc = -ENOMEM;
-		goto out;
+		goto finish_request;
 	}
 
 	memcpy(lvbdata, lmm, lmmsize);
@@ -3345,7 +3345,7 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 	lock->l_lvb_len = lmmsize;
 	unlock_res_and_lock(lock);
 
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 2113dd4..7501f70 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -686,7 +686,7 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
 	rc = ll_prep_inode(&inode, request, dir->i_sb, it);
 	if (rc) {
 		inode = ERR_PTR(rc);
-		goto out;
+		goto finish_request;
 	}
 
 	LASSERT(hlist_empty(&inode->i_dentry));
@@ -697,7 +697,7 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
 	CDEBUG(D_DLMTRACE, "setting l_ast_data to inode %p (%lu/%u)\n",
 	       inode, inode->i_ino, inode->i_generation);
 	ll_set_lock_data(sbi->ll_md_exp, inode, it, NULL);
- out:
+ finish_request:
 	ptlrpc_req_finished(request);
 	return inode;
 }
@@ -960,13 +960,13 @@ static int ll_unlink(struct inode *dir, struct dentry *dentry)
 	rc = md_unlink(ll_i2sbi(dir)->ll_md_exp, op_data, &request);
 	ll_finish_md_op_data(op_data);
 	if (rc)
-		goto out;
+		goto finish_request;
 
 	ll_update_times(request, dir);
 	ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_UNLINK, 1);
 
 	rc = ll_objects_destroy(request, dir);
- out:
+ finish_request:
 	ptlrpc_req_finished(request);
 	return rc;
 }
@@ -1059,11 +1059,11 @@ static int ll_link(struct dentry *old_dentry, struct inode *dir,
 	err = md_link(sbi->ll_md_exp, op_data, &request);
 	ll_finish_md_op_data(op_data);
 	if (err)
-		goto out;
+		goto finish_request;
 
 	ll_update_times(request, dir);
 	ll_stats_ops_tally(sbi, LPROC_LL_LINK, 1);
-out:
+finish_request:
 	ptlrpc_req_finished(request);
 	return err;
 }
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 660b8ac..8d3287c 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -390,19 +390,19 @@ getxattr_nocache:
 		/* only detect the xattr size */
 		if (size == 0) {
 			rc = body->eadatasize;
-			goto out;
+			goto finish_request;
 		}
 
 		if (size < body->eadatasize) {
 			CERROR("server bug: replied size %u > %u\n",
 				body->eadatasize, (int)size);
 			rc = -ERANGE;
-			goto out;
+			goto finish_request;
 		}
 
 		if (body->eadatasize == 0) {
 			rc = -ENODATA;
-			goto out;
+			goto finish_request;
 		}
 
 		/* do not need swab xattr data */
@@ -410,7 +410,7 @@ getxattr_nocache:
 							body->eadatasize);
 		if (!xdata) {
 			rc = -EFAULT;
-			goto out;
+			goto finish_request;
 		}
 
 		memcpy(buffer, xdata, body->eadatasize);
@@ -425,14 +425,14 @@ getxattr_nocache:
 					(posix_acl_xattr_header *)buffer, rc);
 		if (IS_ERR(acl)) {
 			rc = PTR_ERR(acl);
-			goto out;
+			goto finish_request;
 		}
 
 		rc = ee_add(&sbi->ll_et, current_pid(), ll_inode2fid(inode),
 			    xattr_type, acl);
 		if (unlikely(rc < 0)) {
 			lustre_ext_acl_xattr_free(acl);
-			goto out;
+			goto finish_request;
 		}
 	}
 #endif
@@ -444,7 +444,7 @@ out_xattr:
 			ll_get_fsname(inode->i_sb, NULL, 0), rc);
 		sbi->ll_flags &= ~LL_SBI_USER_XATTR;
 	}
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -555,7 +555,7 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 
 	rc = ll_getxattr_common(inode, NULL, buffer, size, OBD_MD_FLXATTRLS);
 	if (rc < 0)
-		goto out;
+		goto finish_request;
 
 	if (buffer != NULL) {
 		struct ll_sb_info *sbi = ll_i2sbi(inode);
@@ -589,7 +589,7 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 
 	if (rc2 < 0) {
 		rc2 = 0;
-		goto out;
+		goto finish_request;
 	} else if (S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)) {
 		const int prefix_len = sizeof(XATTR_LUSTRE_PREFIX) - 1;
 		const size_t name_len   = sizeof("lov") - 1;
@@ -608,7 +608,7 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 		}
 		rc2 = total_len;
 	}
-out:
+finish_request:
 	ptlrpc_req_finished(request);
 	rc = rc + rc2;
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 920b1e9..2a76685 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -92,12 +92,12 @@ static int mdc_getstatus(struct obd_export *exp, struct lu_fid *rootfid)
 
 	rc = ptlrpc_queue_wait(req);
 	if (rc)
-		goto out;
+		goto finish_request;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 	if (body == NULL) {
 		rc = -EPROTO;
-		goto out;
+		goto finish_request;
 	}
 
 	*rootfid = body->fid1;
@@ -105,7 +105,7 @@ static int mdc_getstatus(struct obd_export *exp, struct lu_fid *rootfid)
 	       "root fid="DFID", last_committed=%llu\n",
 	       PFID(rootfid),
 	       lustre_msg_get_last_committed(req->rq_repmsg));
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -1084,17 +1084,17 @@ static int mdc_statfs(const struct lu_env *env,
 		/* check connection error first */
 		if (imp->imp_connect_error)
 			rc = imp->imp_connect_error;
-		goto out;
+		goto finish_request;
 	}
 
 	msfs = req_capsule_server_get(&req->rq_pill, &RMF_OBD_STATFS);
 	if (msfs == NULL) {
 		rc = -EPROTO;
-		goto out;
+		goto finish_request;
 	}
 
 	*osfs = *msfs;
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 output:
 	class_import_put(imp);
@@ -1163,7 +1163,7 @@ static int mdc_ioc_hsm_progress(struct obd_export *exp,
 					LUSTRE_MDS_VERSION, MDS_HSM_PROGRESS);
 	if (req == NULL) {
 		rc = -ENOMEM;
-		goto out;
+		goto finish_request;
 	}
 
 	mdc_pack_body(req, NULL, OBD_MD_FLRMTPERM, 0, 0, 0);
@@ -1172,7 +1172,7 @@ static int mdc_ioc_hsm_progress(struct obd_export *exp,
 	req_hpk = req_capsule_client_get(&req->rq_pill, &RMF_MDS_HSM_PROGRESS);
 	if (req_hpk == NULL) {
 		rc = -EPROTO;
-		goto out;
+		goto finish_request;
 	}
 
 	*req_hpk = *hpk;
@@ -1181,7 +1181,7 @@ static int mdc_ioc_hsm_progress(struct obd_export *exp,
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_queue_wait(req);
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -1197,7 +1197,7 @@ static int mdc_ioc_hsm_ct_register(struct obd_import *imp, __u32 archives)
 					MDS_HSM_CT_REGISTER);
 	if (req == NULL) {
 		rc = -ENOMEM;
-		goto out;
+		goto finish_request;
 	}
 
 	mdc_pack_body(req, NULL, OBD_MD_FLRMTPERM, 0, 0, 0);
@@ -1207,7 +1207,7 @@ static int mdc_ioc_hsm_ct_register(struct obd_import *imp, __u32 archives)
 					      &RMF_MDS_HSM_ARCHIVE);
 	if (archive_mask == NULL) {
 		rc = -EPROTO;
-		goto out;
+		goto finish_request;
 	}
 
 	*archive_mask = archives;
@@ -1215,7 +1215,7 @@ static int mdc_ioc_hsm_ct_register(struct obd_import *imp, __u32 archives)
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_queue_wait(req);
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -1246,18 +1246,18 @@ static int mdc_ioc_hsm_current_action(struct obd_export *exp,
 
 	rc = mdc_queue_wait(req);
 	if (rc)
-		goto out;
+		goto finish_request;
 
 	req_hca = req_capsule_server_get(&req->rq_pill,
 					 &RMF_MDS_HSM_CURRENT_ACTION);
 	if (req_hca == NULL) {
 		rc = -EPROTO;
-		goto out;
+		goto finish_request;
 	}
 
 	*hca = *req_hca;
 
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -1272,7 +1272,7 @@ static int mdc_ioc_hsm_ct_unregister(struct obd_import *imp)
 					MDS_HSM_CT_UNREGISTER);
 	if (req == NULL) {
 		rc = -ENOMEM;
-		goto out;
+		goto finish_request;
 	}
 
 	mdc_pack_body(req, NULL, OBD_MD_FLRMTPERM, 0, 0, 0);
@@ -1280,7 +1280,7 @@ static int mdc_ioc_hsm_ct_unregister(struct obd_import *imp)
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_queue_wait(req);
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -1311,17 +1311,17 @@ static int mdc_ioc_hsm_state_get(struct obd_export *exp,
 
 	rc = mdc_queue_wait(req);
 	if (rc)
-		goto out;
+		goto finish_request;
 
 	req_hus = req_capsule_server_get(&req->rq_pill, &RMF_HSM_USER_STATE);
 	if (req_hus == NULL) {
 		rc = -EPROTO;
-		goto out;
+		goto finish_request;
 	}
 
 	*hus = *req_hus;
 
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -1352,14 +1352,14 @@ static int mdc_ioc_hsm_state_set(struct obd_export *exp,
 	req_hss = req_capsule_client_get(&req->rq_pill, &RMF_HSM_STATE_SET);
 	if (req_hss == NULL) {
 		rc = -EPROTO;
-		goto out;
+		goto finish_request;
 	}
 	*req_hss = *hss;
 
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_queue_wait(req);
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -1377,7 +1377,7 @@ static int mdc_ioc_hsm_request(struct obd_export *exp,
 	req = ptlrpc_request_alloc(imp, &RQF_MDS_HSM_REQUEST);
 	if (req == NULL) {
 		rc = -ENOMEM;
-		goto out;
+		goto finish_request;
 	}
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDS_HSM_USER_ITEM, RCL_CLIENT,
@@ -1398,7 +1398,7 @@ static int mdc_ioc_hsm_request(struct obd_export *exp,
 	req_hr = req_capsule_client_get(&req->rq_pill, &RMF_MDS_HSM_REQUEST);
 	if (req_hr == NULL) {
 		rc = -EPROTO;
-		goto out;
+		goto finish_request;
 	}
 	*req_hr = hur->hur_request;
 
@@ -1406,7 +1406,7 @@ static int mdc_ioc_hsm_request(struct obd_export *exp,
 	req_hui = req_capsule_client_get(&req->rq_pill, &RMF_MDS_HSM_USER_ITEM);
 	if (req_hui == NULL) {
 		rc = -EPROTO;
-		goto out;
+		goto finish_request;
 	}
 	memcpy(req_hui, hur->hur_user_item,
 	       hur->hur_request.hr_itemcount * sizeof(struct hsm_user_item));
@@ -1415,14 +1415,14 @@ static int mdc_ioc_hsm_request(struct obd_export *exp,
 	req_opaque = req_capsule_client_get(&req->rq_pill, &RMF_GENERIC_DATA);
 	if (req_opaque == NULL) {
 		rc = -EPROTO;
-		goto out;
+		goto finish_request;
 	}
 	memcpy(req_opaque, hur_data(hur), hur->hur_request.hr_data_len);
 
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_queue_wait(req);
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index d6c1447..3a56fb7 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -291,12 +291,12 @@ static int osc_getattr(const struct lu_env *env, struct obd_export *exp,
 
 	rc = ptlrpc_queue_wait(req);
 	if (rc)
-		goto out;
+		goto finish_request;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_OST_BODY);
 	if (body == NULL) {
 		rc = -EPROTO;
-		goto out;
+		goto finish_request;
 	}
 
 	CDEBUG(D_INODE, "mode: %o\n", body->oa.o_mode);
@@ -306,7 +306,7 @@ static int osc_getattr(const struct lu_env *env, struct obd_export *exp,
 	oinfo->oi_oa->o_blksize = cli_brw_size(exp->exp_obd);
 	oinfo->oi_oa->o_valid |= OBD_MD_FLBLKSZ;
 
- out:
+ finish_request:
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -336,18 +336,18 @@ static int osc_setattr(const struct lu_env *env, struct obd_export *exp,
 
 	rc = ptlrpc_queue_wait(req);
 	if (rc)
-		goto out;
+		goto finish_request;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_OST_BODY);
 	if (body == NULL) {
 		rc = -EPROTO;
-		goto out;
+		goto finish_request;
 	}
 
 	lustre_get_wire_obdo(&req->rq_import->imp_connect_data, oinfo->oi_oa,
 			     &body->oa);
 
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -1276,7 +1276,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 
 	if (desc == NULL) {
 		rc = -ENOMEM;
-		goto out;
+		goto finish_request;
 	}
 	/* NB request now owns desc and will free it when it gets freed */
 
@@ -1407,7 +1407,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	*reqp = req;
 	return 0;
 
- out:
+ finish_request:
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -2513,17 +2513,17 @@ static int osc_statfs(const struct lu_env *env, struct obd_export *exp,
 
 	rc = ptlrpc_queue_wait(req);
 	if (rc)
-		goto out;
+		goto finish_request;
 
 	msfs = req_capsule_server_get(&req->rq_pill, &RMF_OBD_STATFS);
 	if (msfs == NULL) {
 		rc = -EPROTO;
-		goto out;
+		goto finish_request;
 	}
 
 	*osfs = *msfs;
 
- out:
+ finish_request:
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -2718,16 +2718,16 @@ static int osc_get_info(const struct lu_env *env, struct obd_export *exp,
 		ptlrpc_request_set_replen(req);
 		rc = ptlrpc_queue_wait(req);
 		if (rc)
-			goto out;
+			goto finish_request;
 
 		reply = req_capsule_server_get(&req->rq_pill, &RMF_OBD_ID);
 		if (reply == NULL) {
 			rc = -EPROTO;
-			goto out;
+			goto finish_request;
 		}
 
 		*((u64 *)val) = *reply;
-	out:
+	finish_request:
 		ptlrpc_req_finished(req);
 		return rc;
 	} else if (KEY_IS(KEY_FIEMAP)) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
index 5122205..150d2ec 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
@@ -176,26 +176,26 @@ static int llog_client_next_block(const struct lu_env *env,
 	ptlrpc_request_set_replen(req);
 	rc = ptlrpc_queue_wait(req);
 	if (rc)
-		goto out;
+		goto finish_request;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_LLOGD_BODY);
 	if (body == NULL) {
 		rc = -EFAULT;
-		goto out;
+		goto finish_request;
 	}
 
 	/* The log records are swabbed as they are processed */
 	ptr = req_capsule_server_get(&req->rq_pill, &RMF_EADATA);
 	if (ptr == NULL) {
 		rc = -EFAULT;
-		goto out;
+		goto finish_request;
 	}
 
 	*cur_idx = body->lgd_saved_index;
 	*cur_offset = body->lgd_cur_offset;
 
 	memcpy(buf, ptr, len);
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 err_exit:
 	LLOG_CLIENT_EXIT(loghandle->lgh_ctxt, imp);
@@ -233,22 +233,22 @@ static int llog_client_prev_block(const struct lu_env *env,
 
 	rc = ptlrpc_queue_wait(req);
 	if (rc)
-		goto out;
+		goto finish_request;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_LLOGD_BODY);
 	if (body == NULL) {
 		rc = -EFAULT;
-		goto out;
+		goto finish_request;
 	}
 
 	ptr = req_capsule_server_get(&req->rq_pill, &RMF_EADATA);
 	if (ptr == NULL) {
 		rc = -EFAULT;
-		goto out;
+		goto finish_request;
 	}
 
 	memcpy(buf, ptr, len);
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 err_exit:
 	LLOG_CLIENT_EXIT(loghandle->lgh_ctxt, imp);
@@ -282,12 +282,12 @@ static int llog_client_read_header(const struct lu_env *env,
 	ptlrpc_request_set_replen(req);
 	rc = ptlrpc_queue_wait(req);
 	if (rc)
-		goto out;
+		goto finish_request;
 
 	hdr = req_capsule_server_get(&req->rq_pill, &RMF_LLOG_LOG_HDR);
 	if (hdr == NULL) {
 		rc = -EFAULT;
-		goto out;
+		goto finish_request;
 	}
 
 	memcpy(handle->lgh_hdr, hdr, sizeof(*hdr));
@@ -305,7 +305,7 @@ static int llog_client_read_header(const struct lu_env *env,
 		CERROR("you may need to re-run lconf --write_conf.\n");
 		rc = -EIO;
 	}
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 err_exit:
 	LLOG_CLIENT_EXIT(handle->lgh_ctxt, imp);
-- 
2.6.3
