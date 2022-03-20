Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 67236C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:31:32 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9BE8321EBD1;
	Sun, 20 Mar 2022 06:31:23 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D5DB821CAB7
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:11 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 08BB9EDB;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 04074AB; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:23 -0400
Message-Id: <1647783064-20688-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/50] lustre: sec: allow subdir mount of
 encrypted dir
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sebastien Buisson <sbuisson@ddn.com>

In case of sub-directory mount of an encrypted directory, we need to
retrieve the encryption context of the root inode of the filesystem.
This is done by making the MDT return this upon getattr reply.

Fixes: 71d77bbe7e ("lustre: sec: atomicity of encryption context getting/setting")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15176
Lustre-commit: faf057b46bc770a1a ("LU-15176 sec: allow subdir mount of encrypted dir")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/45407
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 35 +++++++++++++++++++++++++++++++----
 fs/lustre/mdc/mdc_dev.c     |  1 +
 fs/lustre/mdc/mdc_request.c | 28 +++++++++++++++++++++++++---
 fs/lustre/ptlrpc/layout.c   |  3 ++-
 4 files changed, 59 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index e3e871d..1121652 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -251,6 +251,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	u64 valid;
 	int size, err, checksum;
 	bool api32;
+	void *encctx;
+	int encctxlen;
 
 	sbi->ll_md_obd  = class_name2obd(md);
 	if (!sbi->ll_md_obd) {
@@ -625,7 +627,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	/* make root inode
 	 * XXX: move this to after cbd setup?
 	 */
-	valid = OBD_MD_FLGETATTR | OBD_MD_FLBLOCKS | OBD_MD_FLMODEASIZE;
+	valid = OBD_MD_FLGETATTR | OBD_MD_FLBLOCKS | OBD_MD_FLMODEASIZE |
+		OBD_MD_ENCCTX;
 	if (test_bit(LL_SBI_ACL, sbi->ll_flags))
 		valid |= OBD_MD_FLACL;
 
@@ -640,6 +643,14 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	op_data->op_valid = valid;
 
 	err = md_getattr(sbi->ll_md_exp, op_data, &request);
+
+	/* We need enc ctx info, so reset it in op_data to
+	 * prevent it from being freed.
+	 */
+	encctx = op_data->op_file_encctx;
+	encctxlen = op_data->op_file_encctx_size;
+	op_data->op_file_encctx = NULL;
+	op_data->op_file_encctx_size = 0;
 	kfree(op_data);
 	if (err) {
 		CERROR("%s: md_getattr failed for root: rc = %d\n",
@@ -659,15 +670,29 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	api32 = test_bit(LL_SBI_32BIT_API, sbi->ll_flags);
 	root = ll_iget(sb, cl_fid_build_ino(&sbi->ll_root_fid, api32), &lmd);
 	md_free_lustre_md(sbi->ll_md_exp, &lmd);
-	ptlrpc_req_finished(request);
 
 	if (IS_ERR(root)) {
 		lmd_clear_acl(&lmd);
 		err = IS_ERR(root) ? PTR_ERR(root) : -EBADF;
-		CERROR("lustre_lite: bad iget4 for root\n");
+		root = NULL;
+		CERROR("%s: bad ll_iget() for root: rc = %d\n",
+		       sbi->ll_fsname, err);
+		ptlrpc_req_finished(request);
 		goto out_root;
 	}
 
+	if (encctxlen) {
+		CDEBUG(D_SEC,
+		       "server returned encryption ctx for root inode "DFID"\n",
+		       PFID(&sbi->ll_root_fid));
+		err = ll_set_encflags(root, encctx, encctxlen, true);
+		if (err)
+			CWARN("%s: cannot set enc ctx for "DFID": rc = %d\n",
+			      sbi->ll_fsname,
+			      PFID(&sbi->ll_root_fid), err);
+	}
+	ptlrpc_req_finished(request);
+
 	checksum = test_bit(LL_SBI_CHECKSUM, sbi->ll_flags);
 	if (sbi->ll_checksum_set) {
 		err = obd_set_info_async(NULL, sbi->ll_dt_exp,
@@ -3164,9 +3189,11 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 	if (ll_need_32bit_api(ll_i2sbi(i1)))
 		op_data->op_cli_flags |= CLI_API32;
 
-	if (opc == LUSTRE_OPC_LOOKUP || opc == LUSTRE_OPC_CREATE) {
+	if ((i2 && is_root_inode(i2)) ||
+	    opc == LUSTRE_OPC_LOOKUP || opc == LUSTRE_OPC_CREATE) {
 		/* In case of lookup, ll_setup_filename() has already been
 		 * called in ll_lookup_it(), so just take provided name.
+		 * Also take provided name if we are dealing with root inode.
 		 */
 		fname.disk_name.name = (unsigned char *)name;
 		fname.disk_name.len = namelen;
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 0b1d257..de67720 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -1258,6 +1258,7 @@ static int mdc_io_data_version_start(const struct lu_env *env,
 
 	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, 0);
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER, 0);
+	req_capsule_set_size(&req->rq_pill, &RMF_FILE_ENCCTX, RCL_SERVER, 0);
 	ptlrpc_request_set_replen(req);
 
 	req->rq_interpret_reply = mdc_data_version_interpret;
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 1064d9f..f553d44 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -158,7 +158,8 @@ static int mdc_get_root(struct obd_export *exp, const char *fileset,
  * layouts.  --umka
  */
 static int mdc_getattr_common(struct obd_export *exp,
-			      struct ptlrpc_request *req)
+			      struct ptlrpc_request *req,
+			      struct md_op_data *op_data)
 {
 	struct req_capsule *pill = &req->rq_pill;
 	struct mdt_body *body;
@@ -185,6 +186,18 @@ static int mdc_getattr_common(struct obd_export *exp,
 			return -EPROTO;
 	}
 
+	/* If encryption context was returned by MDT, put it in op_data
+	 * so that caller can set it on inode and save an extra getxattr.
+	 */
+	if (op_data && op_data->op_valid & OBD_MD_ENCCTX &&
+	    body->mbo_valid & OBD_MD_ENCCTX) {
+		op_data->op_file_encctx =
+			req_capsule_server_get(pill, &RMF_FILE_ENCCTX);
+		op_data->op_file_encctx_size =
+			req_capsule_get_size(pill, &RMF_FILE_ENCCTX,
+					     RCL_SERVER);
+	}
+
 	return 0;
 }
 
@@ -203,6 +216,7 @@ static int mdc_getattr(struct obd_export *exp, struct md_op_data *op_data,
 		       struct ptlrpc_request **request)
 {
 	struct ptlrpc_request *req;
+	struct obd_device *obd = class_exp2obd(exp);
 	struct obd_import *imp = class_exp2cliimp(exp);
 	u32 acl_bufsize = LUSTRE_POSIX_ACL_MAX_SIZE_OLD;
 	int rc;
@@ -233,9 +247,16 @@ static int mdc_getattr(struct obd_export *exp, struct md_op_data *op_data,
 	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, acl_bufsize);
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     op_data->op_mode);
+	if (exp_connect_encrypt(exp) && op_data->op_valid & OBD_MD_ENCCTX)
+		req_capsule_set_size(&req->rq_pill, &RMF_FILE_ENCCTX,
+				     RCL_SERVER,
+				     obd->u.cli.cl_max_mds_easize);
+	else
+		req_capsule_set_size(&req->rq_pill, &RMF_FILE_ENCCTX,
+				     RCL_SERVER, 0);
 	ptlrpc_request_set_replen(req);
 
-	rc = mdc_getattr_common(exp, req);
+	rc = mdc_getattr_common(exp, req, op_data);
 	if (rc) {
 		if (rc == -ERANGE) {
 			acl_bufsize = min_t(u32,
@@ -289,6 +310,7 @@ static int mdc_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     op_data->op_mode);
 	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, acl_bufsize);
+	req_capsule_set_size(&req->rq_pill, &RMF_FILE_ENCCTX, RCL_SERVER, 0);
 	ptlrpc_request_set_replen(req);
 	if (op_data->op_bias & MDS_FID_OP) {
 		struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
@@ -300,7 +322,7 @@ static int mdc_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 		}
 	}
 
-	rc = mdc_getattr_common(exp, req);
+	rc = mdc_getattr_common(exp, req, NULL);
 	if (rc) {
 		if (rc == -ERANGE) {
 			acl_bufsize = min_t(u32,
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 8e3c97d..8725edd 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -547,7 +547,8 @@
 	&RMF_MDT_MD,
 	&RMF_ACL,
 	&RMF_CAPA1,
-	&RMF_CAPA2
+	&RMF_CAPA2,
+	&RMF_FILE_ENCCTX,
 };
 
 static const struct req_msg_field *mds_setattr_server[] = {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
