Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id F08BCC36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:41:23 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2w94nDJz211L;
	Fri, 21 Mar 2025 06:14:17 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2nd0zYWz1y7N
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:08:37 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 9BB5617B5AA;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 9AAAC106BE16; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:07:04 -0400
Message-ID: <20250321130711.3257092-22-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 21/27] lustre: llite: create
 fileattr_[get|set] functions
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

Move the code for FS_IOC_SETFLAGS and GETFLAGS into their
functions. This is done ahead of the >fileattr_get/set
inode_operations API that hasn't stabilize just yet.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15969
Lustre-commit: d7aa8de396f585e70 ("LU-15969 llite: add support for  ->fileattr_get/set")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51107
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c           |   3 +-
 fs/lustre/llite/llite_internal.h |   1 +
 fs/lustre/llite/llite_lib.c      | 180 ++++++++++++++++++-------------
 fs/lustre/llite/namei.c          |   2 +
 4 files changed, 109 insertions(+), 77 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 8564ee4a879c..48c4245d61b3 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3711,7 +3711,7 @@ int ll_ioctl_check_project(struct inode *inode, u32 xflags,
 	return 0;
 }
 
-static int ll_set_project(struct inode *inode, u32 xflags, u32 projid)
+int ll_set_project(struct inode *inode, u32 xflags, u32 projid)
 {
 	struct ptlrpc_request *req = NULL;
 	struct md_op_data *op_data;
@@ -5778,6 +5778,7 @@ const struct inode_operations ll_file_inode_operations = {
 	.listxattr		= ll_listxattr,
 	.fiemap			= ll_fiemap,
 	.get_acl		= ll_get_acl,
+	.set_acl		= ll_set_acl,
 };
 
 const struct file_operations *ll_select_file_operations(struct ll_sb_info *sbi)
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 755fdae77709..2db240f07b83 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1262,6 +1262,7 @@ int ll_get_fid_by_name(struct inode *parent, const char *name,
 		       int namelen, struct lu_fid *fid, struct inode **inode);
 int ll_inode_permission(struct inode *inode, int mask);
 int ll_ioctl_check_project(struct inode *inode, u32 xflags, u32 projid);
+int ll_set_project(struct inode *inode, u32 xflags, u32 projid);
 int ll_ioctl_fsgetxattr(struct inode *inode, unsigned int cmd,
 			void __user *uarg);
 int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index b4d5b3dca0a7..39b8074bd306 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -3001,13 +3001,103 @@ void ll_delete_inode(struct inode *inode)
 	clear_inode(inode);
 }
 
+static int fileattr_get(struct inode *inode, int *flags, u32 *xflags,
+			u32 *projid)
+{
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct ptlrpc_request *req = NULL;
+	struct md_op_data *op_data;
+	struct mdt_body *body;
+	int rc;
+
+	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL,
+				     0, 0, LUSTRE_OPC_ANY,
+				     NULL);
+	if (IS_ERR(op_data))
+		return PTR_ERR(op_data);
+
+	op_data->op_valid = OBD_MD_FLFLAGS;
+	rc = md_getattr(sbi->ll_md_exp, op_data, &req);
+	ll_finish_md_op_data(op_data);
+	if (rc) {
+		CERROR("%s: failure inode "DFID": rc = %d\n",
+		       sbi->ll_md_exp->exp_obd->obd_name,
+		       PFID(ll_inode2fid(inode)), rc);
+		return -abs(rc);
+	}
+
+	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
+
+	*flags = body->mbo_flags;
+	/* if Lustre specific LUSTRE_ENCRYPT_FL flag is set, also set
+	 * ext4 equivalent to please lsattr and other e2fsprogs tools
+	 */
+	if (*flags & LUSTRE_ENCRYPT_FL)
+		*flags |= STATX_ATTR_ENCRYPTED;
+
+	ptlrpc_req_finished(req);
+
+	*xflags = ll_inode_flags_to_xflags(inode->i_flags);
+	if (test_bit(LLIF_PROJECT_INHERIT, &ll_i2info(inode)->lli_flags))
+		*xflags |= FS_XFLAG_PROJINHERIT;
+	*projid = ll_i2info(inode)->lli_projid;
+
+	return 0;
+}
+
+static int fileattr_set(struct inode *inode, int flags)
+{
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct ptlrpc_request *req = NULL;
+	struct md_op_data *op_data;
+	struct cl_object *obj;
+	struct fsxattr fa = { 0 };
+	struct iattr *attr;
+	int rc;
+
+	fa.fsx_projid = ll_i2info(inode)->lli_projid;
+	if (flags & LUSTRE_PROJINHERIT_FL)
+		fa.fsx_xflags = FS_XFLAG_PROJINHERIT;
+
+	rc = ll_ioctl_check_project(inode, fa.fsx_xflags,
+				    fa.fsx_projid);
+	if (rc)
+		return rc;
+
+	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
+				     LUSTRE_OPC_ANY, NULL);
+	if (IS_ERR(op_data))
+		return PTR_ERR(op_data);
+
+	op_data->op_attr_flags = flags;
+	op_data->op_xvalid |= OP_XVALID_FLAGS;
+	rc = md_setattr(sbi->ll_md_exp, op_data, NULL, 0, &req);
+	ll_finish_md_op_data(op_data);
+	ptlrpc_req_finished(req);
+	if (rc)
+		return rc;
+
+	ll_update_inode_flags(inode, flags);
+
+	obj = ll_i2info(inode)->lli_clob;
+	if (!obj)
+		return 0;
+
+	attr = kzalloc(sizeof(*attr), GFP_KERNEL);
+	if (!attr)
+		return -ENOMEM;
+
+	rc = cl_setattr_ost(obj, attr, OP_XVALID_FLAGS, flags);
+	kfree(attr);
+
+	return rc;
+}
+
 /* ioctl commands shared between files and directories */
 int ll_iocontrol(struct inode *inode, struct file *file,
 		 unsigned int cmd, void __user *uarg)
 {
-	struct ll_sb_info *sbi = ll_i2sbi(inode);
-	struct ptlrpc_request *req = NULL;
-	int rc = 0, flags = 0;
+	int rc;
 
 	switch (cmd) {
 	case BLKSSZGET:
@@ -3018,92 +3108,29 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		rc = put_user(inode->i_generation, (int __user *)uarg);
 		break;
 	case FS_IOC_GETFLAGS: {
-		struct mdt_body *body;
-		struct md_op_data *op_data;
+		u32 xflags = 0, projid = 0;
+		int flags = 0;
 
-		if (!access_ok(uarg, sizeof(int)))
-			return -EFAULT;
-
-		op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
-					     LUSTRE_OPC_ANY, NULL);
-		if (IS_ERR(op_data)) {
-			rc = PTR_ERR(op_data);
-			break;
-		}
-		op_data->op_valid = OBD_MD_FLFLAGS;
-		rc = md_getattr(sbi->ll_md_exp, op_data, &req);
-		ll_finish_md_op_data(op_data);
-		if (rc) {
-			CERROR("%s: failure inode " DFID ": rc = %d\n",
-			       sbi->ll_md_exp->exp_obd->obd_name,
-			       PFID(ll_inode2fid(inode)), rc);
-			rc = -abs(rc);
+		if (!access_ok(uarg, sizeof(int))) {
+			rc = -EFAULT;
 			break;
 		}
 
-		body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
+		rc = fileattr_get(file->f_inode, &flags, &xflags, &projid);
+		if (rc == 0)
+			rc = put_user(flags, (int __user *)uarg);
 
-		flags = body->mbo_flags;
-		/* if Lustre specific LUSTRE_ENCRYPT_FL flag is set, also set
-		 * ext4 equivalent to please lsattr and other e2fsprogs tools
-		 */
-		if (flags & LUSTRE_ENCRYPT_FL)
-			flags |= STATX_ATTR_ENCRYPTED;
-
-		ptlrpc_req_finished(req);
-
-		rc = put_user(flags, (int __user *)uarg);
 		break;
 	}
 	case FS_IOC_SETFLAGS: {
-		struct md_op_data *op_data;
-		struct cl_object *obj;
-		struct iattr *attr;
-		struct fsxattr fa = { 0 };
+		int flags = 0;
 
 		if (get_user(flags, (int __user *)uarg)) {
 			rc = -EFAULT;
 			break;
 		}
 
-		fa.fsx_projid = ll_i2info(inode)->lli_projid;
-		if (flags & LUSTRE_PROJINHERIT_FL)
-			fa.fsx_xflags = FS_XFLAG_PROJINHERIT;
-
-		rc = ll_ioctl_check_project(inode, fa.fsx_xflags,
-					    fa.fsx_projid);
-		if (rc)
-			break;
-
-		op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
-					     LUSTRE_OPC_ANY, NULL);
-		if (IS_ERR(op_data)) {
-			rc = PTR_ERR(op_data);
-			break;
-		}
-
-		op_data->op_attr_flags = flags;
-		op_data->op_xvalid |= OP_XVALID_FLAGS;
-		rc = md_setattr(sbi->ll_md_exp, op_data, NULL, 0, &req);
-		ll_finish_md_op_data(op_data);
-		ptlrpc_req_finished(req);
-		if (rc)
-			break;
-
-		ll_update_inode_flags(inode, flags);
-
-		obj = ll_i2info(inode)->lli_clob;
-		if (!obj)
-			break;
-
-		attr = kzalloc(sizeof(*attr), GFP_NOFS);
-		if (!attr) {
-			rc = -ENOMEM;
-			break;
-		}
-
-		rc = cl_setattr_ost(obj, attr, OP_XVALID_FLAGS, flags);
-		kfree(attr);
+		rc = fileattr_set(file->f_inode, flags);
 		break;
 	}
 	case FS_IOC_FSGETXATTR:
@@ -3197,7 +3224,8 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		break;
 #ifdef OBD_IOC_GETNAME_OLD
 	case_OBD_IOC_DEPRECATED_FT(OBD_IOC_GETNAME_OLD,
-				   sbi->ll_md_exp->exp_obd->obd_name, 2, 16);
+				   ll_i2sbi(inode)->ll_md_exp->exp_obd->obd_name,
+				   2, 16);
 #endif
 	case OBD_IOC_GETDTNAME:
 		fallthrough;
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 79df426fcbbb..1d21626588ec 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -2227,6 +2227,7 @@ const struct inode_operations ll_dir_inode_operations = {
 	.permission		= ll_inode_permission,
 	.listxattr		= ll_listxattr,
 	.get_acl		= ll_get_acl,
+	.set_acl		= ll_set_acl,
 };
 
 const struct inode_operations ll_special_inode_operations = {
@@ -2235,4 +2236,5 @@ const struct inode_operations ll_special_inode_operations = {
 	.permission		= ll_inode_permission,
 	.listxattr		= ll_listxattr,
 	.get_acl		= ll_get_acl,
+	.set_acl		= ll_set_acl,
 };
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
