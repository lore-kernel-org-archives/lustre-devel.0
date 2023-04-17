Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A11DDC77B76
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 14:11:42 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T7C67yvz22V9;
	Mon, 17 Apr 2023 06:54:15 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0T1V41bDz21CV
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:49:18 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A92BC1008496;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A7D49375; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:16 -0400
Message-Id: <1681739243-29375-21-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 20/27] lustre: llite: move common ioctl code
 to ll_iocontrol()
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
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

Move common ioctl cases from ll_dir_ioctl() and ll_file_ioctl()
into ll_iocontrol() to avoid duplicate code.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16634
Lustre-commit: 3be425883918528ef9 ("LU-16634 llite: move common ioctl code to ll_iocontrol()")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50335
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Vitaliy Kuznetsov <vkuznetsov@ddn.com>
Reviewed-by: Timothy Day <timday@amazon.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c       |  92 ++-------------------------
 fs/lustre/llite/file.c      |  57 ++---------------
 fs/lustre/llite/llite_lib.c | 152 ++++++++++++++++++++++++++++++++++++++------
 3 files changed, 143 insertions(+), 158 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 6bb95ad..9caff36 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1476,31 +1476,6 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_IOCTL, 1);
 	switch (cmd) {
-	case FS_IOC_GETFLAGS:
-	case FS_IOC_SETFLAGS:
-		return ll_iocontrol(inode, file, cmd, uarg);
-	case FSFILT_IOC_GETVERSION:
-	case FS_IOC_GETVERSION:
-		return put_user(inode->i_generation, (int __user *)arg);
-	/* We need to special case any other ioctls we want to handle,
-	 * to send them to the MDS/OST as appropriate and to properly
-	 * network encode the arg field.
-	 */
-	case FS_IOC_SETVERSION:
-		return -ENOTSUPP;
-
-	case LL_IOC_GET_MDTIDX: {
-		int mdtidx;
-
-		mdtidx = ll_get_mdt_idx(inode);
-		if (mdtidx < 0)
-			return mdtidx;
-
-		if (put_user((int)mdtidx, (int __user *)arg))
-			return -EFAULT;
-
-		return 0;
-	}
 	case IOC_MDC_LOOKUP: {
 		int namelen, len = 0;
 		char *filename;
@@ -1840,23 +1815,10 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		ptlrpc_req_finished(root_request);
 		return rc;
 	}
-
-	case LL_IOC_UNLOCK_FOREIGN:
-		/* if not a foreign symlink do nothing */
-		if (ll_foreign_is_removable(dentry, true)) {
-			CDEBUG(D_INFO,
-			       "prevent rmdir of non-foreign dir ("DFID")\n",
-			       PFID(ll_inode2fid(inode)));
-			return -EOPNOTSUPP;
-		}
-		return 0;
-
 	case LL_IOC_RMFID:
 		return ll_rmfid(file, (void __user *)arg);
 	case LL_IOC_LOV_SWAP_LAYOUTS:
 		return -EPERM;
-	case IOC_OBD_STATFS:
-		return ll_obd_statfs(inode, (void __user *)arg);
 	case LL_IOC_LOV_GETSTRIPE:
 	case LL_IOC_LOV_GETSTRIPE_NEW:
 	case LL_IOC_MDC_GETINFO_V1:
@@ -2088,14 +2050,6 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		kfree(qctl);
 		return rc;
 	}
-	case OBD_IOC_GETNAME_OLD:
-		fallthrough;
-	case OBD_IOC_GETDTNAME:
-		fallthrough;
-	case OBD_IOC_GETMDNAME:
-		return ll_get_obd_name(inode, cmd, uarg);
-	case LL_IOC_FLUSHCTX:
-		return ll_flush_ctx(inode);
 	case LL_IOC_GETOBDCOUNT: {
 		int count, vallen;
 		struct obd_export *exp;
@@ -2118,11 +2072,6 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		return 0;
 	}
-	case LL_IOC_PATH2FID:
-		if (copy_to_user(uarg, ll_inode2fid(inode),
-				 sizeof(struct lu_fid)))
-			return -EFAULT;
-		return 0;
 	case LL_IOC_GET_CONNECT_FLAGS: {
 		return obd_iocontrol(cmd, sbi->ll_md_exp, 0, NULL,
 				     uarg);
@@ -2305,12 +2254,6 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		return rc;
 	}
-	case FS_IOC_FSGETXATTR:
-		return ll_ioctl_fsgetxattr(inode, cmd, uarg);
-	case FS_IOC_FSSETXATTR:
-		return ll_ioctl_fssetxattr(inode, cmd, uarg);
-	case LL_IOC_PROJECT:
-		return ll_ioctl_project(file, cmd, uarg);
 	case LL_IOC_PCC_DETACH_BY_FID: {
 		struct lu_pcc_detach_fid *detach;
 		struct lu_fid *fid;
@@ -2356,38 +2299,13 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		kfree(detach);
 		return rc;
 	}
-#ifdef CONFIG_FS_ENCRYPTION
-	case FS_IOC_SET_ENCRYPTION_POLICY:
-		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
-			return -EOPNOTSUPP;
-		return fscrypt_ioctl_set_policy(file, uarg);
-	case FS_IOC_GET_ENCRYPTION_POLICY_EX:
-		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
-			return -EOPNOTSUPP;
-		return fscrypt_ioctl_get_policy_ex(file, uarg);
-	case FS_IOC_ADD_ENCRYPTION_KEY:
-		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
-			return -EOPNOTSUPP;
-		rc = fscrypt_ioctl_add_key(file, uarg);
-		if (!rc)
-			sptlrpc_enc_pool_add_user();
-		return rc;
-	case FS_IOC_REMOVE_ENCRYPTION_KEY:
-		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
-			return -EOPNOTSUPP;
-		return fscrypt_ioctl_remove_key(file, uarg);
-	case FS_IOC_REMOVE_ENCRYPTION_KEY_ALL_USERS:
-		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
-			return -EOPNOTSUPP;
-		return fscrypt_ioctl_remove_key_all_users(file, uarg);
-	case FS_IOC_GET_ENCRYPTION_KEY_STATUS:
-		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
-			return -EOPNOTSUPP;
-		return fscrypt_ioctl_get_key_status(file, uarg);
-#endif
 	default:
-		return obd_iocontrol(cmd, sbi->ll_dt_exp, 0, NULL, uarg);
+		rc = ll_iocontrol(inode, file, cmd, uarg);
+		if (rc == -ENOTTY)
+			rc = obd_iocontrol(cmd, sbi->ll_dt_exp, 0, NULL, uarg);
+		break;
 	}
+	return rc;
 }
 
 static loff_t ll_dir_seek(struct file *file, loff_t offset, int origin)
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 44197a8..ceac08c 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4083,7 +4083,7 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 	struct inode *inode = file_inode(file);
 	struct ll_file_data *fd = file->private_data;
 	void __user *uarg = (void __user *)arg;
-	int flags, rc;
+	int flags, rc = 0;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p),cmd=%x\n",
 	       PFID(ll_inode2fid(inode)), inode, cmd);
@@ -4471,14 +4471,6 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		fd->fd_designated_mirror = arg;
 		return 0;
 	}
-	case FS_IOC_FSGETXATTR:
-		return ll_ioctl_fsgetxattr(inode, cmd, uarg);
-	case FS_IOC_FSSETXATTR:
-		return ll_ioctl_fssetxattr(inode, cmd, uarg);
-	case LL_IOC_PROJECT:
-		return ll_ioctl_project(file, cmd, uarg);
-	case BLKSSZGET:
-		return put_user(PAGE_SIZE, (int __user *)arg);
 	case LL_IOC_HEAT_GET: {
 		struct lu_heat uheat;
 		struct lu_heat *heat;
@@ -4563,49 +4555,14 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		kfree(state);
 		return rc;
 	}
-#ifdef CONFIG_FS_ENCRYPTION
-	case FS_IOC_SET_ENCRYPTION_POLICY:
-		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
-			return -EOPNOTSUPP;
-		return fscrypt_ioctl_set_policy(file, uarg);
-	case FS_IOC_GET_ENCRYPTION_POLICY_EX:
-		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
-			return -EOPNOTSUPP;
-		return fscrypt_ioctl_get_policy_ex(file, uarg);
-	case FS_IOC_ADD_ENCRYPTION_KEY:
-		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
-			return -EOPNOTSUPP;
-		return fscrypt_ioctl_add_key(file, uarg);
-	case FS_IOC_REMOVE_ENCRYPTION_KEY:
-		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
-			return -EOPNOTSUPP;
-		return fscrypt_ioctl_remove_key(file, uarg);
-	case FS_IOC_REMOVE_ENCRYPTION_KEY_ALL_USERS:
-		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
-			return -EOPNOTSUPP;
-		return fscrypt_ioctl_remove_key_all_users(file, uarg);
-	case FS_IOC_GET_ENCRYPTION_KEY_STATUS:
-		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
-			return -EOPNOTSUPP;
-		return fscrypt_ioctl_get_key_status(file, uarg);
-#endif
-
-	case LL_IOC_UNLOCK_FOREIGN: {
-		struct dentry *dentry = file_dentry(file);
-
-		/* if not a foreign symlink do nothing */
-		if (ll_foreign_is_removable(dentry, true)) {
-			CDEBUG(D_INFO,
-			       "prevent unlink of non-foreign file ("DFID")\n",
-			       PFID(ll_inode2fid(inode)));
-			return -EOPNOTSUPP;
-		}
-		return 0;
-	}
-
 	default:
-		return obd_iocontrol(cmd, ll_i2dtexp(inode), 0, NULL, uarg);
+		rc = ll_iocontrol(inode, file, cmd, uarg);
+		if (rc == -ENOTTY)
+			rc = obd_iocontrol(cmd, ll_i2dtexp(inode), 0, NULL, uarg);
+		break;
 	}
+
+	return rc;
 }
 
 loff_t ll_lseek(struct file *file, loff_t offset, int whence)
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 913e096..c54ca1f 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2852,24 +2852,32 @@ void ll_delete_inode(struct inode *inode)
 	clear_inode(inode);
 }
 
+/* ioctl commands shared between files and directories */
 int ll_iocontrol(struct inode *inode, struct file *file,
 		 unsigned int cmd, void __user *uarg)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ptlrpc_request *req = NULL;
-	int rc, flags = 0;
+	int rc = 0, flags = 0;
 
 	switch (cmd) {
+	case BLKSSZGET:
+		rc = put_user(PAGE_SIZE, (int __user *)uarg);
+		break;
+	case FSFILT_IOC_GETVERSION:
+	case FS_IOC_GETVERSION:
+		rc = put_user(inode->i_generation, (int __user *)uarg);
+		break;
 	case FS_IOC_GETFLAGS: {
 		struct mdt_body *body;
 		struct md_op_data *op_data;
 
-		op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL,
-					     0, 0, LUSTRE_OPC_ANY,
-					     NULL);
-		if (IS_ERR(op_data))
-			return PTR_ERR(op_data);
-
+		op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
+					     LUSTRE_OPC_ANY, NULL);
+		if (IS_ERR(op_data)) {
+			rc = PTR_ERR(op_data);
+			break;
+		}
 		op_data->op_valid = OBD_MD_FLFLAGS;
 		rc = md_getattr(sbi->ll_md_exp, op_data, &req);
 		ll_finish_md_op_data(op_data);
@@ -2877,7 +2885,8 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 			CERROR("%s: failure inode " DFID ": rc = %d\n",
 			       sbi->ll_md_exp->exp_obd->obd_name,
 			       PFID(ll_inode2fid(inode)), rc);
-			return -abs(rc);
+			rc = -abs(rc);
+			break;
 		}
 
 		body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
@@ -2891,7 +2900,8 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 
 		ptlrpc_req_finished(req);
 
-		return put_user(flags, (int __user *)uarg);
+		rc = put_user(flags, (int __user *)uarg);
+		break;
 	}
 	case FS_IOC_SETFLAGS: {
 		struct md_op_data *op_data;
@@ -2899,8 +2909,10 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		struct iattr *attr;
 		struct fsxattr fa = { 0 };
 
-		if (get_user(flags, (int __user *)uarg))
-			return -EFAULT;
+		if (get_user(flags, (int __user *)uarg)) {
+			rc = -EFAULT;
+			break;
+		}
 
 		fa.fsx_projid = ll_i2info(inode)->lli_projid;
 		if (flags & LUSTRE_PROJINHERIT_FL)
@@ -2909,12 +2921,14 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		rc = ll_ioctl_check_project(inode, fa.fsx_xflags,
 					    fa.fsx_projid);
 		if (rc)
-			return rc;
+			break;
 
 		op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
 					     LUSTRE_OPC_ANY, NULL);
-		if (IS_ERR(op_data))
-			return PTR_ERR(op_data);
+		if (IS_ERR(op_data)) {
+			rc = PTR_ERR(op_data);
+			break;
+		}
 
 		op_data->op_attr_flags = flags;
 		op_data->op_xvalid |= OP_XVALID_FLAGS;
@@ -2922,27 +2936,123 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		ll_finish_md_op_data(op_data);
 		ptlrpc_req_finished(req);
 		if (rc)
-			return rc;
+			break;
 
 		ll_update_inode_flags(inode, flags);
 
 		obj = ll_i2info(inode)->lli_clob;
 		if (!obj)
-			return 0;
+			break;
 
 		attr = kzalloc(sizeof(*attr), GFP_NOFS);
-		if (!attr)
-			return -ENOMEM;
+		if (!attr) {
+			rc = -ENOMEM;
+			break;
+		}
 
 		rc = cl_setattr_ost(obj, attr, OP_XVALID_FLAGS, flags);
 		kfree(attr);
-		return rc;
+		break;
+	}
+	case FS_IOC_FSGETXATTR:
+		rc = ll_ioctl_fsgetxattr(inode, cmd, uarg);
+		break;
+	case FS_IOC_FSSETXATTR:
+		rc = ll_ioctl_fssetxattr(inode, cmd, uarg);
+		break;
+	case LL_IOC_PROJECT:
+		rc = ll_ioctl_project(file, cmd, uarg);
+		break;
+	case IOC_OBD_STATFS:
+		rc = ll_obd_statfs(inode, uarg);
+		break;
+	case LL_IOC_GET_MDTIDX: {
+		rc = ll_get_mdt_idx(inode);
+		if (rc < 0)
+			break;
+
+		if (put_user(rc, (int __user *)uarg))
+			rc = -EFAULT;
+
+		break;
+	}
+	case LL_IOC_FLUSHCTX:
+		rc = ll_flush_ctx(inode);
+		break;
+#ifdef CONFIG_FS_ENCRYPTION
+	case FS_IOC_ADD_ENCRYPTION_KEY:
+		if (ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			rc = fscrypt_ioctl_add_key(file, uarg);
+		else
+			rc = -EOPNOTSUPP;
+		break;
+	case FS_IOC_GET_ENCRYPTION_KEY_STATUS:
+		if (ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			rc = fscrypt_ioctl_get_key_status(file, uarg);
+		else
+			rc = -EOPNOTSUPP;
+		break;
+	case FS_IOC_GET_ENCRYPTION_POLICY_EX:
+		if (ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			rc = fscrypt_ioctl_get_policy_ex(file, uarg);
+		else
+			rc = -EOPNOTSUPP;
+		break;
+	case FS_IOC_SET_ENCRYPTION_POLICY:
+		if (ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			rc = fscrypt_ioctl_set_policy(file, uarg);
+		else
+			rc = -EOPNOTSUPP;
+		break;
+	case FS_IOC_REMOVE_ENCRYPTION_KEY:
+		if (ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			rc = fscrypt_ioctl_remove_key(file, uarg);
+		else
+			rc = -EOPNOTSUPP;
+		break;
+	case FS_IOC_REMOVE_ENCRYPTION_KEY_ALL_USERS:
+		if (ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			rc = fscrypt_ioctl_remove_key_all_users(file, uarg);
+		else
+			rc = -EOPNOTSUPP;
+		break;
+#endif
+	case LL_IOC_GETPARENT:
+		rc = ll_getparent(file, uarg);
+		break;
+	case LL_IOC_PATH2FID:
+		if (copy_to_user(uarg, ll_inode2fid(inode),
+				 sizeof(struct lu_fid)))
+			rc = -EFAULT;
+		break;
+	case LL_IOC_UNLOCK_FOREIGN: {
+		struct dentry *dentry = file_dentry(file);
+
+		/* if not a foreign symlink do nothing */
+		if (ll_foreign_is_removable(dentry, true)) {
+			CDEBUG(D_INFO,
+			       "prevent unlink of non-foreign file ("DFID")\n",
+			       PFID(ll_inode2fid(inode)));
+			rc = -EOPNOTSUPP;
+		}
+		break;
 	}
+	case OBD_IOC_FID2PATH:
+		rc = ll_fid2path(inode, uarg);
+		break;
+	case OBD_IOC_GETNAME_OLD:
+		fallthrough;
+	case OBD_IOC_GETDTNAME:
+		fallthrough;
+	case OBD_IOC_GETMDNAME:
+		rc = ll_get_obd_name(inode, cmd, uarg);
+		break;
 	default:
-		return -EINVAL;
+		rc = ENOTTY;
+		break;
 	}
 
-	return 0;
+	return rc;
 }
 
 int ll_flush_ctx(struct inode *inode)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
