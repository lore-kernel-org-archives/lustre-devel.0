Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id BEBDDC77B70
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 14:11:12 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T6g06lxz22Tf;
	Mon, 17 Apr 2023 06:53:47 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0T1S2s7mz21C6
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:49:16 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A45F61008495;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A3052372; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:15 -0400
Message-Id: <1681739243-29375-20-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 19/27] lustre: misc: remove unnecessary ioctl
 typecasts
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

Declare "void __user *uarg" in the ioctl handling code so
that it isn't typecast on every access in the ioctl handler.
Unnecessary typecast risks hiding compiler warnings and bugs.

Convert indentation to tabs for lines previously using spaces.
Change local variable declarations to use only a single space.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16634
Lustre-commit: 4a1465577e1310ce09 ("LU-16634 misc: remove unnecessary ioctl typecasts")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50333
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Vitaliy Kuznetsov <vkuznetsov@ddn.com>
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h    |   2 +-
 fs/lustre/llite/dir.c            |  62 +++++++++--------
 fs/lustre/llite/file.c           | 142 +++++++++++++++++----------------------
 fs/lustre/llite/llite_internal.h |  14 ++--
 fs/lustre/llite/llite_lib.c      |  15 ++---
 fs/lustre/obdclass/class_obd.c   |  16 ++---
 6 files changed, 115 insertions(+), 136 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 123a214..0c95c3c 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -58,7 +58,7 @@
 
 /* OBD Operations Declarations */
 struct obd_device *class_exp2obd(struct obd_export *exp);
-int class_handle_ioctl(unsigned int cmd, unsigned long arg);
+int class_handle_ioctl(unsigned int cmd, void __user *uarg);
 int lustre_get_jobid(char *jobid, size_t len);
 void jobid_cache_fini(void);
 int jobid_cache_init(void);
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 871dd93..6bb95ad 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1464,6 +1464,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	struct inode *inode = file_inode(file);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct obd_ioctl_data *data;
+	void __user *uarg = (void __user *)arg;
 	int rc = 0;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p), cmd=%#x\n",
@@ -1477,7 +1478,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	switch (cmd) {
 	case FS_IOC_GETFLAGS:
 	case FS_IOC_SETFLAGS:
-		return ll_iocontrol(inode, file, cmd, arg);
+		return ll_iocontrol(inode, file, cmd, uarg);
 	case FSFILT_IOC_GETVERSION:
 	case FS_IOC_GETVERSION:
 		return put_user(inode->i_generation, (int __user *)arg);
@@ -1504,7 +1505,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		int namelen, len = 0;
 		char *filename;
 
-		rc = obd_ioctl_getdata(&data, &len, (void __user *)arg);
+		rc = obd_ioctl_getdata(&data, &len, uarg);
 		if (rc)
 			return rc;
 
@@ -1537,7 +1538,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		int len;
 		int rc;
 
-		rc = obd_ioctl_getdata(&data, &len, (void __user *)arg);
+		rc = obd_ioctl_getdata(&data, &len, uarg);
 		if (rc)
 			return rc;
 
@@ -1591,11 +1592,10 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return rc;
 	}
 	case LL_IOC_LMV_SET_DEFAULT_STRIPE: {
-		struct lmv_user_md __user *ulump;
+		struct lmv_user_md __user *ulump = uarg;
 		struct lmv_user_md lum;
 		int rc;
 
-		ulump = (struct lmv_user_md __user *)arg;
 		if (copy_from_user(&lum, ulump, sizeof(lum)))
 			return -EFAULT;
 
@@ -1611,8 +1611,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct lov_user_md_v3 *lumv3 = NULL;
 		struct lov_user_md_v1 lumv1;
 		struct lov_user_md_v1 *lumv1_ptr = &lumv1;
-		struct lov_user_md_v1 __user *lumv1p = (void __user *)arg;
-		struct lov_user_md_v3 __user *lumv3p = (void __user *)arg;
+		struct lov_user_md_v1 __user *lumv1p = uarg;
+		struct lov_user_md_v3 __user *lumv3p = uarg;
 		int lum_size = 0;
 
 		int set_default = 0;
@@ -1656,7 +1656,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return rc;
 	}
 	case LL_IOC_LMV_GETSTRIPE: {
-		struct lmv_user_md __user *ulmv;
+		struct lmv_user_md __user *ulmv = uarg;
 		struct lmv_user_md lum;
 		struct ptlrpc_request *request = NULL;
 		struct ptlrpc_request *root_request = NULL;
@@ -1881,7 +1881,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (cmd == IOC_MDC_GETFILEINFO_V1 ||
 		    cmd == IOC_MDC_GETFILEINFO_V2 ||
 		    cmd == IOC_MDC_GETFILESTRIPE) {
-			filename = ll_getname((const char __user *)arg);
+			filename = ll_getname(uarg);
 			if (IS_ERR(filename))
 				return PTR_ERR(filename);
 
@@ -2064,7 +2064,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (!qctl)
 			return -ENOMEM;
 
-		if (copy_from_user(qctl, (void __user *)arg, sizeof(*qctl))) {
+		if (copy_from_user(qctl, uarg, sizeof(*qctl))) {
 			rc = -EFAULT;
 			goto out_quotactl;
 		}
@@ -2082,7 +2082,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		rc = quotactl_ioctl(inode->i_sb, qctl);
 		if ((rc == 0 || rc == -ENODATA) &&
-		    copy_to_user((void __user *)arg, qctl, sizeof(*qctl)))
+		    copy_to_user(uarg, qctl, sizeof(*qctl)))
 			rc = -EFAULT;
 out_quotactl:
 		kfree(qctl);
@@ -2093,7 +2093,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case OBD_IOC_GETDTNAME:
 		fallthrough;
 	case OBD_IOC_GETMDNAME:
-		return ll_get_obd_name(inode, cmd, arg);
+		return ll_get_obd_name(inode, cmd, uarg);
 	case LL_IOC_FLUSHCTX:
 		return ll_flush_ctx(inode);
 	case LL_IOC_GETOBDCOUNT: {
@@ -2119,18 +2119,18 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return 0;
 	}
 	case LL_IOC_PATH2FID:
-		if (copy_to_user((void __user *)arg, ll_inode2fid(inode),
+		if (copy_to_user(uarg, ll_inode2fid(inode),
 				 sizeof(struct lu_fid)))
 			return -EFAULT;
 		return 0;
 	case LL_IOC_GET_CONNECT_FLAGS: {
 		return obd_iocontrol(cmd, sbi->ll_md_exp, 0, NULL,
-				     (void __user *)arg);
+				     uarg);
 	}
 	case OBD_IOC_FID2PATH:
-		return ll_fid2path(inode, (void __user *)arg);
+		return ll_fid2path(inode, uarg);
 	case LL_IOC_GETPARENT:
-		return ll_getparent(file, (void __user *)arg);
+		return ll_getparent(file, uarg);
 	case LL_IOC_FID2MDTIDX: {
 		struct obd_export *exp = ll_i2mdexp(inode);
 		struct lu_fid fid;
@@ -2152,7 +2152,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct hsm_user_request	*hur;
 		ssize_t	totalsize;
 
-		hur = memdup_user((void __user *)arg, sizeof(*hur));
+		hur = memdup_user(uarg, sizeof(*hur));
 		if (IS_ERR(hur))
 			return PTR_ERR(hur);
 
@@ -2171,7 +2171,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			return -ENOMEM;
 
 		/* Copy the whole struct */
-		if (copy_from_user(hur, (void __user *)arg, totalsize)) {
+		if (copy_from_user(hur, uarg, totalsize)) {
 			kvfree(hur);
 			return -EFAULT;
 		}
@@ -2207,7 +2207,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct hsm_progress_kernel hpk;
 		struct hsm_progress hp;
 
-		if (copy_from_user(&hp, (void __user *)arg, sizeof(hp)))
+		if (copy_from_user(&hp, uarg, sizeof(hp)))
 			return -EFAULT;
 
 		hpk.hpk_fid = hp.hp_fid;
@@ -2270,7 +2270,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		int len;
 		int rc;
 
-		rc = obd_ioctl_getdata(&data, &len, (void __user *)arg);
+		rc = obd_ioctl_getdata(&data, &len, uarg);
 		if (rc)
 			return rc;
 
@@ -2306,11 +2306,11 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return rc;
 	}
 	case FS_IOC_FSGETXATTR:
-		return ll_ioctl_fsgetxattr(inode, cmd, arg);
+		return ll_ioctl_fsgetxattr(inode, cmd, uarg);
 	case FS_IOC_FSSETXATTR:
-		return ll_ioctl_fssetxattr(inode, cmd, arg);
+		return ll_ioctl_fssetxattr(inode, cmd, uarg);
 	case LL_IOC_PROJECT:
-		return ll_ioctl_project(file, cmd, arg);
+		return ll_ioctl_project(file, cmd, uarg);
 	case LL_IOC_PCC_DETACH_BY_FID: {
 		struct lu_pcc_detach_fid *detach;
 		struct lu_fid *fid;
@@ -2360,35 +2360,33 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case FS_IOC_SET_ENCRYPTION_POLICY:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return fscrypt_ioctl_set_policy(file, (const void __user *)arg);
+		return fscrypt_ioctl_set_policy(file, uarg);
 	case FS_IOC_GET_ENCRYPTION_POLICY_EX:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return fscrypt_ioctl_get_policy_ex(file, (void __user *)arg);
+		return fscrypt_ioctl_get_policy_ex(file, uarg);
 	case FS_IOC_ADD_ENCRYPTION_KEY:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		rc = fscrypt_ioctl_add_key(file, (void __user *)arg);
+		rc = fscrypt_ioctl_add_key(file, uarg);
 		if (!rc)
 			sptlrpc_enc_pool_add_user();
 		return rc;
 	case FS_IOC_REMOVE_ENCRYPTION_KEY:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return fscrypt_ioctl_remove_key(file, (void __user *)arg);
+		return fscrypt_ioctl_remove_key(file, uarg);
 	case FS_IOC_REMOVE_ENCRYPTION_KEY_ALL_USERS:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return fscrypt_ioctl_remove_key_all_users(file,
-							  (void __user *)arg);
+		return fscrypt_ioctl_remove_key_all_users(file, uarg);
 	case FS_IOC_GET_ENCRYPTION_KEY_STATUS:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return fscrypt_ioctl_get_key_status(file, (void __user *)arg);
+		return fscrypt_ioctl_get_key_status(file, uarg);
 #endif
 	default:
-		return obd_iocontrol(cmd, sbi->ll_dt_exp, 0, NULL,
-				     (void __user *)arg);
+		return obd_iocontrol(cmd, sbi->ll_dt_exp, 0, NULL, uarg);
 	}
 }
 
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index b96efb1..44197a8 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1382,7 +1382,7 @@ static int ll_lease_close(struct obd_client_handle *och, struct inode *inode,
  * After lease is taken, send the RPC MDS_REINT_RESYNC to the MDT
  */
 static int ll_lease_file_resync(struct obd_client_handle *och,
-				struct inode *inode, unsigned long arg)
+				struct inode *inode, void __user *uarg)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct md_op_data *op_data;
@@ -1395,8 +1395,7 @@ static int ll_lease_file_resync(struct obd_client_handle *och,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	if (copy_from_user(&ioc, (struct ll_ioc_lease_id __user *)arg,
-			   sizeof(ioc)))
+	if (copy_from_user(&ioc, uarg, sizeof(ioc)))
 		return -EFAULT;
 
 	/* before starting file resync, it's necessary to clean up page cache
@@ -2496,7 +2495,7 @@ static int ll_file_getstripe(struct inode *inode, void __user *lum, size_t size)
 static int ll_lov_setstripe(struct inode *inode, struct file *file,
 			    void __user *arg)
 {
-	struct lov_user_md __user *lum = (struct lov_user_md __user *)arg;
+	struct lov_user_md __user *lum = arg;
 	struct lov_user_md *klum;
 	int lum_size, rc;
 	u64 flags = FMODE_WRITE;
@@ -2556,8 +2555,9 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 	if (file->f_flags & O_NONBLOCK) {
 		if (!mutex_trylock(&lli->lli_group_mutex))
 			return -EAGAIN;
-	} else
+	} else {
 		mutex_lock(&lli->lli_group_mutex);
+	}
 
 	if (fd->fd_flags & LL_FILE_GROUP_LOCKED) {
 		CWARN("group lock already existed with gid %lu\n",
@@ -3622,22 +3622,19 @@ static int ll_lock_noexpand(struct file *file, int flags)
 }
 
 int ll_ioctl_fsgetxattr(struct inode *inode, unsigned int cmd,
-			unsigned long arg)
+			void __user *uarg)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct fsxattr fsxattr;
 
-	if (copy_from_user(&fsxattr,
-			   (const struct fsxattr __user *)arg,
-			   sizeof(fsxattr)))
+	if (copy_from_user(&fsxattr, uarg, sizeof(fsxattr)))
 		return -EFAULT;
 
 	fsxattr.fsx_xflags = ll_inode_flags_to_xflags(inode->i_flags);
 	if (test_bit(LLIF_PROJECT_INHERIT, &lli->lli_flags))
 		fsxattr.fsx_xflags |= FS_XFLAG_PROJINHERIT;
 	fsxattr.fsx_projid = ll_i2info(inode)->lli_projid;
-	if (copy_to_user((struct fsxattr __user *)arg,
-			 &fsxattr, sizeof(fsxattr)))
+	if (copy_to_user(uarg, &fsxattr, sizeof(fsxattr)))
 		return -EFAULT;
 
 	return 0;
@@ -3730,21 +3727,18 @@ static int ll_set_project(struct inode *inode, u32 xflags, u32 projid)
 }
 
 int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
-			unsigned long arg)
+			void __user *uarg)
 {
 	struct fsxattr fsxattr;
 
-	if (copy_from_user(&fsxattr,
-			   (const struct fsxattr __user *)arg,
-			   sizeof(fsxattr)))
+	if (copy_from_user(&fsxattr, uarg, sizeof(fsxattr)))
 		return -EFAULT;
 
 	return ll_set_project(inode, fsxattr.fsx_xflags,
 			      fsxattr.fsx_projid);
 }
 
-int ll_ioctl_project(struct file *file, unsigned int cmd,
-		     unsigned long arg)
+int ll_ioctl_project(struct file *file, unsigned int cmd, void __user *uarg)
 {
 	struct lu_project lu_project;
 	struct dentry *dentry = file_dentry(file);
@@ -3752,9 +3746,7 @@ int ll_ioctl_project(struct file *file, unsigned int cmd,
 	struct dentry *child_dentry = NULL;
 	int rc = 0, name_len;
 
-	if (copy_from_user(&lu_project,
-			   (const struct lu_project __user *)arg,
-			   sizeof(lu_project)))
+	if (copy_from_user(&lu_project, uarg, sizeof(lu_project)))
 		return -EFAULT;
 
 	/* apply child dentry if name is valid */
@@ -3790,8 +3782,7 @@ int ll_ioctl_project(struct file *file, unsigned int cmd,
 			     &ll_i2info(inode)->lli_flags))
 			lu_project.project_xflags |= FS_XFLAG_PROJINHERIT;
 		lu_project.project_id = ll_i2info(inode)->lli_projid;
-		if (copy_to_user((struct lu_project __user *)arg,
-				 &lu_project, sizeof(lu_project))) {
+		if (copy_to_user(uarg, &lu_project, sizeof(lu_project))) {
 			rc = -EFAULT;
 			goto out;
 		}
@@ -3807,7 +3798,7 @@ int ll_ioctl_project(struct file *file, unsigned int cmd,
 }
 
 static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
-				 unsigned long arg)
+				 void __user *uarg)
 {
 	struct inode *inode = file_inode(file);
 	struct ll_file_data *fd = file->private_data;
@@ -3851,7 +3842,7 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 			goto out_lease_close;
 		}
 
-		if (copy_from_user(data, (void __user *)arg, data_size)) {
+		if (copy_from_user(data, uarg, data_size)) {
 			rc = -EFAULT;
 			goto out_lease_close;
 		}
@@ -3864,8 +3855,8 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 			goto out_lease_close;
 		}
 
-		arg += sizeof(*ioc);
-		if (copy_from_user(&fdv, (void __user *)arg, sizeof(u32))) {
+		uarg += sizeof(*ioc);
+		if (copy_from_user(&fdv, uarg, sizeof(u32))) {
 			rc = -EFAULT;
 			goto out_lease_close;
 		}
@@ -3893,14 +3884,14 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 			goto out_lease_close;
 		}
 
-		arg += sizeof(*ioc);
-		if (copy_from_user(&fdv, (void __user *)arg, sizeof(u32))) {
+		uarg += sizeof(*ioc);
+		if (copy_from_user(&fdv, uarg, sizeof(u32))) {
 			rc = -EFAULT;
 			goto out_lease_close;
 		}
 
-		arg += sizeof(u32);
-		if (copy_from_user(&mirror_id, (void __user *)arg,
+		uarg += sizeof(u32);
+		if (copy_from_user(&mirror_id, uarg,
 				   sizeof(u32))) {
 			rc = -EFAULT;
 			goto out_lease_close;
@@ -3925,8 +3916,8 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 		if (IS_ENCRYPTED(inode))
 			return -EOPNOTSUPP;
 
-		arg += sizeof(*ioc);
-		if (copy_from_user(&param.pa_archive_id, (void __user *)arg,
+		uarg += sizeof(*ioc);
+		if (copy_from_user(&param.pa_archive_id, uarg,
 				   sizeof(u32))) {
 			rc2 = -EFAULT;
 			goto out_lease_close;
@@ -3986,7 +3977,7 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 }
 
 static long ll_file_set_lease(struct file *file, struct ll_ioc_lease *ioc,
-			      unsigned long arg)
+			      void __user *uarg)
 {
 	struct inode *inode = file_inode(file);
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -4009,7 +4000,7 @@ static long ll_file_set_lease(struct file *file, struct ll_ioc_lease *ioc,
 		fmode = FMODE_READ;
 		break;
 	case LL_LEASE_UNLCK:
-		return ll_file_unlock_lease(file, ioc, arg);
+		return ll_file_unlock_lease(file, ioc, uarg);
 	default:
 		return -EINVAL;
 	}
@@ -4024,7 +4015,7 @@ static long ll_file_set_lease(struct file *file, struct ll_ioc_lease *ioc,
 		return PTR_ERR(och);
 
 	if (ioc->lil_flags & LL_LEASE_RESYNC) {
-		rc = ll_lease_file_resync(och, inode, arg);
+		rc = ll_lease_file_resync(och, inode, uarg);
 		if (rc) {
 			ll_lease_close(och, inode, NULL);
 			return rc;
@@ -4091,6 +4082,7 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 {
 	struct inode *inode = file_inode(file);
 	struct ll_file_data *fd = file->private_data;
+	void __user *uarg = (void __user *)arg;
 	int flags, rc;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p),cmd=%x\n",
@@ -4129,15 +4121,14 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		return 0;
 	case LL_IOC_LOV_SETSTRIPE:
 	case LL_IOC_LOV_SETSTRIPE_NEW:
-		return ll_lov_setstripe(inode, file, (void __user *)arg);
+		return ll_lov_setstripe(inode, file, uarg);
 	case LL_IOC_LOV_SETEA:
-		return ll_lov_setea(inode, file, (void __user *)arg);
+		return ll_lov_setea(inode, file, uarg);
 	case LL_IOC_LOV_SWAP_LAYOUTS: {
 		struct file *file2;
 		struct lustre_swap_layouts lsl;
 
-		if (copy_from_user(&lsl, (char __user *)arg,
-				   sizeof(struct lustre_swap_layouts)))
+		if (copy_from_user(&lsl, uarg, sizeof(lsl)))
 			return -EFAULT;
 
 		if ((file->f_flags & O_ACCMODE) == O_RDONLY)
@@ -4180,10 +4171,10 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 	}
 	case LL_IOC_LOV_GETSTRIPE:
 	case LL_IOC_LOV_GETSTRIPE_NEW:
-		return ll_file_getstripe(inode, (void __user *)arg, 0);
+		return ll_file_getstripe(inode, uarg, 0);
 	case FS_IOC_GETFLAGS:
 	case FS_IOC_SETFLAGS:
-		return ll_iocontrol(inode, file, cmd, arg);
+		return ll_iocontrol(inode, file, cmd, uarg);
 	case FSFILT_IOC_GETVERSION:
 	case FS_IOC_GETVERSION:
 		return put_user(inode->i_generation, (int __user *)arg);
@@ -4199,12 +4190,12 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 	case LL_IOC_GROUP_UNLOCK:
 		return ll_put_grouplock(inode, file, arg);
 	case IOC_OBD_STATFS:
-		return ll_obd_statfs(inode, (void __user *)arg);
+		return ll_obd_statfs(inode, uarg);
 
 	case LL_IOC_FLUSHCTX:
 		return ll_flush_ctx(inode);
 	case LL_IOC_PATH2FID: {
-		if (copy_to_user((void __user *)arg, ll_inode2fid(inode),
+		if (copy_to_user(uarg, ll_inode2fid(inode),
 				 sizeof(struct lu_fid)))
 			return -EFAULT;
 
@@ -4213,17 +4204,17 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 	case LL_IOC_GETPARENT:
 		return ll_getparent(file, (struct getparent __user *)arg);
 	case OBD_IOC_FID2PATH:
-		return ll_fid2path(inode, (void __user *)arg);
+		return ll_fid2path(inode, uarg);
 	case LL_IOC_DATA_VERSION: {
 		struct ioc_data_version	idv;
 		int rc;
 
-		if (copy_from_user(&idv, (char __user *)arg, sizeof(idv)))
+		if (copy_from_user(&idv, uarg, sizeof(idv)))
 			return -EFAULT;
 
 		idv.idv_flags &= LL_DV_RD_FLUSH | LL_DV_WR_FLUSH;
 		rc = ll_ioc_data_version(inode, &idv);
-		if (rc == 0 && copy_to_user((char __user *)arg, &idv,
+		if (rc == 0 && copy_to_user(uarg, &idv,
 					    sizeof(idv)))
 			return -EFAULT;
 
@@ -4237,7 +4228,7 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		if (mdtidx < 0)
 			return mdtidx;
 
-		if (put_user(mdtidx, (int __user *)arg))
+		if (put_user(mdtidx, (int __user *)uarg))
 			return -EFAULT;
 
 		return 0;
@@ -4247,7 +4238,7 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 	case OBD_IOC_GETDTNAME:
 		fallthrough;
 	case OBD_IOC_GETMDNAME:
-		return ll_get_obd_name(inode, cmd, arg);
+		return ll_get_obd_name(inode, cmd, uarg);
 	case LL_IOC_HSM_STATE_GET: {
 		struct md_op_data *op_data;
 		struct hsm_user_state *hus;
@@ -4267,7 +4258,7 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		rc = obd_iocontrol(cmd, ll_i2mdexp(inode), sizeof(*op_data),
 				   op_data, NULL);
 
-		if (copy_to_user((void __user *)arg, hus, sizeof(*hus)))
+		if (copy_to_user(uarg, hus, sizeof(*hus)))
 			rc = -EFAULT;
 
 		ll_finish_md_op_data(op_data);
@@ -4278,7 +4269,7 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		struct hsm_state_set *hss;
 		int rc;
 
-		hss = memdup_user((char __user *)arg, sizeof(*hss));
+		hss = memdup_user(uarg, sizeof(*hss));
 		if (IS_ERR(hss))
 			return PTR_ERR(hss);
 
@@ -4323,7 +4314,7 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 			       hca->hca_location.offset, hca->hca_location.length);
 		}
 
-		if (copy_to_user((char __user *)arg, hca, sizeof(*hca)))
+		if (copy_to_user(uarg, hca, sizeof(*hca)))
 			rc = -EFAULT;
 skip_copy:
 		ll_finish_md_op_data(op_data);
@@ -4338,10 +4329,10 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 	case LL_IOC_SET_LEASE: {
 		struct ll_ioc_lease ioc;
 
-		if (copy_from_user(&ioc, (void __user *)arg, sizeof(ioc)))
+		if (copy_from_user(&ioc, uarg, sizeof(ioc)))
 			return -EFAULT;
 
-		return ll_file_set_lease(file, &ioc, arg);
+		return ll_file_set_lease(file, &ioc, uarg);
 	}
 	case LL_IOC_GET_LEASE: {
 		struct ll_inode_info *lli = ll_i2info(inode);
@@ -4367,7 +4358,7 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 	case LL_IOC_HSM_IMPORT: {
 		struct hsm_user_import *hui;
 
-		hui = memdup_user((void __user *)arg, sizeof(*hui));
+		hui = memdup_user(uarg, sizeof(*hui));
 		if (IS_ERR(hui))
 			return PTR_ERR(hui);
 
@@ -4377,11 +4368,9 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		return rc;
 	}
 	case LL_IOC_FUTIMES_3: {
-		const struct ll_futimes_3 __user *lfu_user;
 		struct ll_futimes_3 lfu;
 
-		lfu_user = (const struct ll_futimes_3 __user *)arg;
-		if (copy_from_user(&lfu, lfu_user, sizeof(lfu)))
+		if (copy_from_user(&lfu, uarg, sizeof(lfu)))
 			return -EFAULT;
 
 		return ll_file_futimes_3(file, &lfu);
@@ -4394,7 +4383,7 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		int i;
 
 		rc = 0;
-		u_ladvise_hdr = (void __user *)arg;
+		u_ladvise_hdr = uarg;
 		k_ladvise_hdr = kzalloc(alloc_size, GFP_KERNEL);
 		if (!k_ladvise_hdr)
 			return -ENOMEM;
@@ -4479,15 +4468,15 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		if (!(file->f_flags & O_DIRECT))
 			return -EINVAL;
 
-		fd->fd_designated_mirror = (u32)arg;
+		fd->fd_designated_mirror = arg;
 		return 0;
 	}
 	case FS_IOC_FSGETXATTR:
-		return ll_ioctl_fsgetxattr(inode, cmd, arg);
+		return ll_ioctl_fsgetxattr(inode, cmd, uarg);
 	case FS_IOC_FSSETXATTR:
-		return ll_ioctl_fssetxattr(inode, cmd, arg);
+		return ll_ioctl_fssetxattr(inode, cmd, uarg);
 	case LL_IOC_PROJECT:
-		return ll_ioctl_project(file, cmd, arg);
+		return ll_ioctl_project(file, cmd, uarg);
 	case BLKSSZGET:
 		return put_user(PAGE_SIZE, (int __user *)arg);
 	case LL_IOC_HEAT_GET: {
@@ -4495,7 +4484,7 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		struct lu_heat *heat;
 		int size;
 
-		if (copy_from_user(&uheat, (void __user *)arg, sizeof(uheat)))
+		if (copy_from_user(&uheat, uarg, sizeof(uheat)))
 			return -EFAULT;
 
 		if (uheat.lh_count > OBD_HEAT_COUNT)
@@ -4508,14 +4497,14 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 
 		heat->lh_count = uheat.lh_count;
 		ll_heat_get(inode, heat);
-		rc = copy_to_user((char __user *)arg, heat, size);
+		rc = copy_to_user(uarg, heat, size);
 		kfree(heat);
 		return rc ? -EFAULT : 0;
 	}
 	case LL_IOC_HEAT_SET: {
 		u64 flags;
 
-		if (copy_from_user(&flags, (void __user *)arg, sizeof(flags)))
+		if (copy_from_user(&flags, uarg, sizeof(flags)))
 			return -EFAULT;
 
 		rc = ll_heat_set(inode, flags);
@@ -4528,9 +4517,7 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		if (!detach)
 			return -ENOMEM;
 
-		if (copy_from_user(detach,
-				   (const struct lu_pcc_detach __user *)arg,
-				   sizeof(*detach))) {
+		if (copy_from_user(detach, uarg, sizeof(*detach))) {
 			rc = -EFAULT;
 			goto out_detach_free;
 		}
@@ -4551,8 +4538,7 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		return rc;
 	}
 	case LL_IOC_PCC_STATE: {
-		struct lu_pcc_state __user *ustate =
-			(struct lu_pcc_state __user *)arg;
+		struct lu_pcc_state __user *ustate = uarg;
 		struct lu_pcc_state *state;
 
 		state = kzalloc(sizeof(*state), GFP_KERNEL);
@@ -4581,28 +4567,27 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 	case FS_IOC_SET_ENCRYPTION_POLICY:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return fscrypt_ioctl_set_policy(file, (const void __user *)arg);
+		return fscrypt_ioctl_set_policy(file, uarg);
 	case FS_IOC_GET_ENCRYPTION_POLICY_EX:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return fscrypt_ioctl_get_policy_ex(file, (void __user *)arg);
+		return fscrypt_ioctl_get_policy_ex(file, uarg);
 	case FS_IOC_ADD_ENCRYPTION_KEY:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return fscrypt_ioctl_add_key(file, (void __user *)arg);
+		return fscrypt_ioctl_add_key(file, uarg);
 	case FS_IOC_REMOVE_ENCRYPTION_KEY:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return fscrypt_ioctl_remove_key(file, (void __user *)arg);
+		return fscrypt_ioctl_remove_key(file, uarg);
 	case FS_IOC_REMOVE_ENCRYPTION_KEY_ALL_USERS:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return fscrypt_ioctl_remove_key_all_users(file,
-							  (void __user *)arg);
+		return fscrypt_ioctl_remove_key_all_users(file, uarg);
 	case FS_IOC_GET_ENCRYPTION_KEY_STATUS:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return fscrypt_ioctl_get_key_status(file, (void __user *)arg);
+		return fscrypt_ioctl_get_key_status(file, uarg);
 #endif
 
 	case LL_IOC_UNLOCK_FOREIGN: {
@@ -4619,8 +4604,7 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 	}
 
 	default:
-		return obd_iocontrol(cmd, ll_i2dtexp(inode), 0, NULL,
-				     (void __user *)arg);
+		return obd_iocontrol(cmd, ll_i2dtexp(inode), 0, NULL, uarg);
 	}
 }
 
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index fdc0f89..6590399 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1222,12 +1222,10 @@ int ll_get_fid_by_name(struct inode *parent, const char *name,
 int ll_inode_permission(struct inode *inode, int mask);
 int ll_ioctl_check_project(struct inode *inode, u32 xflags, u32 projid);
 int ll_ioctl_fsgetxattr(struct inode *inode, unsigned int cmd,
-			unsigned long arg);
+			void __user *uarg);
 int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
-			unsigned long arg);
-int ll_ioctl_project(struct file *file, unsigned int cmd,
-		     unsigned long arg);
-
+			void __user *uarg);
+int ll_ioctl_project(struct file *file, unsigned int cmd, void __user *uarg);
 int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
 			     u64 flags, struct lov_user_md *lum,
 			     int lum_size);
@@ -1290,7 +1288,7 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 void ll_truncate_inode_pages_final(struct inode *inode, struct cl_io *io);
 void ll_delete_inode(struct inode *inode);
 int ll_iocontrol(struct inode *inode, struct file *file,
-		 unsigned int cmd, unsigned long arg);
+		 unsigned int cmd, void __user *uarg);
 int ll_flush_ctx(struct inode *inode);
 void ll_umount_begin(struct super_block *sb);
 int ll_remount_fs(struct super_block *sb, int *flags, char *data);
@@ -1298,7 +1296,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 void ll_dirty_page_discard_warn(struct inode *inode, int ioret);
 int ll_prep_inode(struct inode **inode, struct req_capsule *pill,
 		  struct super_block *sb, struct lookup_intent *it);
-int ll_obd_statfs(struct inode *inode, void __user *arg);
+int ll_obd_statfs(struct inode *inode, void __user *uarg);
 int ll_get_max_mdsize(struct ll_sb_info *sbi, int *max_mdsize);
 int ll_get_default_mdsize(struct ll_sb_info *sbi, int *default_mdsize);
 int ll_set_default_mdsize(struct ll_sb_info *sbi, int default_mdsize);
@@ -1310,7 +1308,7 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      u32 mode, enum md_op_code opc,
 				      void *data);
 void ll_finish_md_op_data(struct md_op_data *op_data);
-int ll_get_obd_name(struct inode *inode, unsigned int cmd, unsigned long arg);
+int ll_get_obd_name(struct inode *inode, unsigned int cmd, void __user *uarg);
 void ll_compute_rootsquash_state(struct ll_sb_info *sbi);
 ssize_t ll_copy_user_md(const struct lov_user_md __user *md,
 			struct lov_user_md **kbuf);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 049cd23..913e096 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2853,7 +2853,7 @@ void ll_delete_inode(struct inode *inode)
 }
 
 int ll_iocontrol(struct inode *inode, struct file *file,
-		 unsigned int cmd, unsigned long arg)
+		 unsigned int cmd, void __user *uarg)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ptlrpc_request *req = NULL;
@@ -2891,7 +2891,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 
 		ptlrpc_req_finished(req);
 
-		return put_user(flags, (int __user *)arg);
+		return put_user(flags, (int __user *)uarg);
 	}
 	case FS_IOC_SETFLAGS: {
 		struct md_op_data *op_data;
@@ -2899,7 +2899,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		struct iattr *attr;
 		struct fsxattr fa = { 0 };
 
-		if (get_user(flags, (int __user *)arg))
+		if (get_user(flags, (int __user *)uarg))
 			return -EFAULT;
 
 		fa.fsx_projid = ll_i2info(inode)->lli_projid;
@@ -3219,7 +3219,7 @@ int ll_prep_inode(struct inode **inode, struct req_capsule *pill,
 	return rc;
 }
 
-int ll_obd_statfs(struct inode *inode, void __user *arg)
+int ll_obd_statfs(struct inode *inode, void __user *uarg)
 {
 	struct ll_sb_info *sbi = NULL;
 	struct obd_export *exp;
@@ -3238,7 +3238,7 @@ int ll_obd_statfs(struct inode *inode, void __user *arg)
 		goto out_statfs;
 	}
 
-	rc = obd_ioctl_getdata(&data, &len, arg);
+	rc = obd_ioctl_getdata(&data, &len, uarg);
 	if (rc)
 		goto out_statfs;
 
@@ -3491,7 +3491,7 @@ int ll_show_options(struct seq_file *seq, struct dentry *dentry)
 /**
  * Get obd name by cmd, and copy out to user space
  */
-int ll_get_obd_name(struct inode *inode, unsigned int cmd, unsigned long arg)
+int ll_get_obd_name(struct inode *inode, unsigned int cmd, void __user *uarg)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct obd_device *obd;
@@ -3506,8 +3506,7 @@ int ll_get_obd_name(struct inode *inode, unsigned int cmd, unsigned long arg)
 	if (!obd)
 		return -ENOENT;
 
-	if (copy_to_user((void __user *)arg, obd->obd_name,
-			 strlen(obd->obd_name) + 1))
+	if (copy_to_user(uarg, obd->obd_name, strlen(obd->obd_name) + 1))
 		return -EFAULT;
 
 	return 0;
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index 67a9422..a7a2a6c 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -277,14 +277,14 @@ int obd_ioctl_getdata(struct obd_ioctl_data **datap, int *len, void __user *arg)
 }
 EXPORT_SYMBOL(obd_ioctl_getdata);
 
-int class_handle_ioctl(unsigned int cmd, unsigned long arg)
+int class_handle_ioctl(unsigned int cmd, void __user *uarg)
 {
 	struct obd_ioctl_data *data;
 	struct obd_device *obd = NULL;
 	int err = 0, len = 0;
 
 	CDEBUG(D_IOCTL, "cmd = %x\n", cmd);
-	if (obd_ioctl_getdata(&data, &len, (void __user *)arg)) {
+	if (obd_ioctl_getdata(&data, &len, uarg)) {
 		CERROR("OBD ioctl: data error\n");
 		return -EINVAL;
 	}
@@ -341,7 +341,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 		memcpy(data->ioc_bulk, LUSTRE_VERSION_STRING,
 		       strlen(LUSTRE_VERSION_STRING) + 1);
 
-		if (copy_to_user((void __user *)arg, data, len))
+		if (copy_to_user(uarg, data, len))
 			err = -EFAULT;
 		goto out;
 	}
@@ -359,7 +359,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 			goto out;
 		}
 
-		if (copy_to_user((void __user *)arg, data, sizeof(*data)))
+		if (copy_to_user(uarg, data, sizeof(*data)))
 			err = -EFAULT;
 		goto out;
 	}
@@ -396,7 +396,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 		CDEBUG(D_IOCTL, "device name %s, dev %d\n", data->ioc_inlbuf1,
 		       dev);
 
-		if (copy_to_user((void __user *)arg, data, sizeof(*data)))
+		if (copy_to_user(uarg, data, sizeof(*data)))
 			err = -EFAULT;
 		goto out;
 	}
@@ -438,7 +438,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 			 obd->obd_name, obd->obd_uuid.uuid,
 			 atomic_read(&obd->obd_refcount));
 
-		if (copy_to_user((void __user *)arg, data, len))
+		if (copy_to_user(uarg, data, len))
 			err = -EFAULT;
 		goto out;
 	}
@@ -479,7 +479,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 	if (err)
 		goto out;
 
-	if (copy_to_user((void __user *)arg, data, len))
+	if (copy_to_user(uarg, data, len))
 		err = -EFAULT;
 out:
 	kvfree(data);
@@ -497,7 +497,7 @@ static long obd_class_ioctl(struct file *filp, unsigned int cmd,
 	if ((cmd & 0xffffff00) == ((int)'T') << 8) /* ignore all tty ioctls */
 		return -ENOTTY;
 
-	return class_handle_ioctl(cmd, (unsigned long)arg);
+	return class_handle_ioctl(cmd, (void __user *)arg);
 }
 
 /* declare character device */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
