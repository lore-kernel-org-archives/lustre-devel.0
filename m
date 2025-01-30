Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id AB810C0218F
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:28:22 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLd93pT5z214h;
	Thu, 30 Jan 2025 06:14:53 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLYP0QzGz1xP1
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:11:37 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D982617D1ED;
 Thu, 30 Jan 2025 09:11:32 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id D3C0B106BE17; Thu, 30 Jan 2025 09:11:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:10:52 -0500
Message-ID: <20250130141115.950749-3-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 02/25] lustre: obdclass: improve iocontrol
 error messages
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
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Vitaliy Kuznetsov <vkuznetsov@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

Add consistent CDEBUG() messages for iocontrol handlers.
Add helpers OBD_IOC_ERROR() and OBD_IOC_DEBUG() to print the
iocontrol parameters consistently in case of an error.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16634
Lustre-commit: 1f4825eff026321a8 ("LU-16634 obdclass: improve iocontrol error messages")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50334
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Vitaliy Kuznetsov <vkuznetsov@ddn.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h   |   7 ++
 fs/lustre/llite/dir.c           |   7 +-
 fs/lustre/llite/file.c          |  30 +++---
 fs/lustre/lmv/lmv_obd.c         |   9 +-
 fs/lustre/lov/lov_obd.c         |  13 ++-
 fs/lustre/mdc/mdc_request.c     |   8 +-
 fs/lustre/obdclass/class_obd.c  | 162 ++++++++++++++++++--------------
 fs/lustre/obdecho/echo_client.c |   9 +-
 fs/lustre/osc/osc_request.c     |   8 +-
 9 files changed, 146 insertions(+), 107 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 2b66bc46168c..eef9bfb91f4d 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1836,4 +1836,11 @@ struct attribute *get_attr_starts_with(const struct kobj_type *typ,
 	return _get_attr_matches(typ, name, len, _attr_name_starts_with);
 }
 
+int obd_ioctl_msg(const char *file, const char *func, int line, int level,
+		  const char *name, unsigned int cmd, const char *msg, int rc);
+#define OBD_IOC_DEBUG(level, dev, cmd, msg, rc)	\
+	obd_ioctl_msg(__FILE__, __func__, __LINE__, level, dev, cmd, msg, rc)
+#define OBD_IOC_ERROR(dev, cmd, msg, rc)	\
+	obd_ioctl_msg(__FILE__, __func__, __LINE__, D_ERROR, dev, cmd, msg, rc)
+
 #endif /* __LINUX_OBD_CLASS_H */
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 9caff36c9bef..2e44f9bb3895 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1467,8 +1467,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	void __user *uarg = (void __user *)arg;
 	int rc = 0;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p), cmd=%#x\n",
-	       PFID(ll_inode2fid(inode)), inode, cmd);
+	CDEBUG(D_VFSTRACE|D_IOCTL, "VFS Op:inode="DFID"(%pK) cmd=%x arg=%lx\n",
+	       PFID(ll_inode2fid(inode)), inode, cmd, arg);
 
 	/* asm-ppc{,64} declares TCGETS, et. al. as type 't' not 'T' */
 	if (_IOC_TYPE(cmd) == 'T' || _IOC_TYPE(cmd) == 't') /* tty ioctls */
@@ -2063,7 +2063,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		rc = obd_get_info(NULL, exp, sizeof(KEY_TGT_COUNT),
 				  KEY_TGT_COUNT, &vallen, &count);
 		if (rc) {
-			CERROR("get target count failed: %d\n", rc);
+			CERROR("%s: get target count failed: rc = %d\n",
+			       sbi->ll_fsname, rc);
 			return rc;
 		}
 
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 24904acb28e0..9307007c3e18 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4099,8 +4099,8 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	void __user *uarg = (void __user *)arg;
 	int flags, rc = 0;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p),cmd=%x\n",
-	       PFID(ll_inode2fid(inode)), inode, cmd);
+	CDEBUG(D_VFSTRACE|D_IOCTL, "VFS Op:inode="DFID"(%pK) cmd=%x arg=%lx\n",
+	       PFID(ll_inode2fid(inode)), inode, cmd, arg);
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_IOCTL, 1);
 
 	/* asm-ppc{,64} declares TCGETS, et. al. as type 't' not 'T' */
@@ -4123,9 +4123,11 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (cmd == LL_IOC_SETFLAGS) {
 			if ((flags & LL_FILE_IGNORE_LOCK) &&
 			    !(file->f_flags & O_DIRECT)) {
-				CERROR("%s: unable to disable locking on non-O_DIRECT file\n",
-				       current->comm);
-				return -EINVAL;
+				rc = -EINVAL;
+				CERROR("%s: unable to disable locking on non-O_DIRECT file "DFID": rc = %d\n",
+				       current->comm, PFID(ll_inode2fid(inode)),
+				       rc);
+				return rc;
 			}
 
 			fd->fd_flags |= flags;
@@ -4865,32 +4867,30 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 		einfo.ei_mode = LCK_PW;
 		break;
 	default:
-		CDEBUG(D_INFO, "Unknown fcntl lock type: %d\n", fl_type);
-		return -ENOTSUPP;
+		rc = -EINVAL;
+		CERROR("%s: fcntl from '%s' unknown lock type=%d: rc = %d\n",
+		       sbi->ll_fsname, current->comm, fl_type, rc);
+		return rc;
 	}
 
 	switch (cmd) {
 	case F_SETLKW:
-#ifdef F_SETLKW64
 	case F_SETLKW64:
-#endif
 		flags = 0;
 		break;
 	case F_SETLK:
-#ifdef F_SETLK64
 	case F_SETLK64:
-#endif
 		flags = LDLM_FL_BLOCK_NOWAIT;
 		break;
 	case F_GETLK:
-#ifdef F_GETLK64
 	case F_GETLK64:
-#endif
 		flags = LDLM_FL_TEST_LOCK;
 		break;
 	default:
-		CERROR("unknown fcntl lock command: %d\n", cmd);
-		return -EINVAL;
+		rc = -EINVAL;
+		CERROR("%s: fcntl from '%s' unknown lock command=%d: rc = %d\n",
+		       sbi->ll_fsname, current->comm, cmd, rc);
+		return rc;
 	}
 
 	/*
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 54f86736e9bf..62385ac9b00f 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -831,6 +831,9 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 	u32 count = lmv->lmv_mdt_count;
 	int rc = 0;
 
+	CDEBUG(D_IOCTL, "%s: cmd=%x len=%u karg=%pK uarg=%pK\n",
+	       exp->exp_obd->obd_name, cmd, len, karg, uarg);
+
 	if (count == 0)
 		return -ENOTTY;
 
@@ -1069,10 +1072,8 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 			err = obd_iocontrol(cmd, tgt->ltd_exp, len, karg, uarg);
 			if (err) {
 				if (tgt->ltd_active) {
-					CERROR("%s: error: iocontrol MDC %s on MDTidx %d cmd %x: err = %d\n",
-					       lmv2obd_dev(lmv)->obd_name,
-					       tgt->ltd_uuid.uuid,
-					       tgt->ltd_index, cmd, err);
+					OBD_IOC_ERROR(obd->obd_name, cmd,
+						      tgt->ltd_uuid.uuid, err);
 					if (!rc)
 						rc = err;
 				}
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index d2fe8c32097a..8bfce5001d58 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -970,6 +970,9 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	struct lov_obd *lov = &obd->u.lov;
 	int i = 0, rc = 0, count = lov->desc.ld_tgt_count;
 
+	CDEBUG(D_IOCTL, "%s: cmd=%x len=%u karg=%pK uarg=%pK\n",
+	       exp->exp_obd->obd_name, cmd, len, karg, uarg);
+
 	switch (cmd) {
 	case IOC_OBD_STATFS: {
 		struct obd_ioctl_data *data = karg;
@@ -1097,11 +1100,11 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 					    len, karg, uarg);
 			if (err) {
 				if (lov->lov_tgts[i]->ltd_active) {
-					CDEBUG_LIMIT(err == -ENOTTY ?
-						     D_IOCTL : D_WARNING,
-						     "iocontrol OSC %s on OST idx %d cmd %x: err = %d\n",
-						     lov_uuid2str(lov, i),
-						     i, cmd, err);
+					OBD_IOC_DEBUG(err == -ENOTTY ?
+						      D_IOCTL : D_WARNING,
+						      obd->obd_name, cmd,
+						      lov_uuid2str(lov, i),
+						      err);
 					if (!rc)
 						rc = err;
 				}
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 15e58e84ddbb..84c4d2888e7d 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2208,6 +2208,9 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	struct obd_import *imp = obd->u.cli.cl_import;
 	int rc;
 
+	CDEBUG(D_IOCTL, "%s: cmd=%x len=%u karg=%pK uarg=%pK\n",
+	       obd->obd_name, cmd, len, karg, uarg);
+
 	if (!try_module_get(THIS_MODULE)) {
 		CERROR("%s: cannot get module '%s'\n", obd->obd_name,
 		       module_name(THIS_MODULE));
@@ -2321,9 +2324,8 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		rc = mdc_ioc_swap_layouts(exp, karg);
 		goto out;
 	default:
-		CERROR("unrecognised ioctl: cmd = %#x\n", cmd);
-		rc = -ENOTTY;
-		goto out;
+		rc = OBD_IOC_ERROR(obd->obd_name, cmd, "unrecognized", -ENOTTY);
+		break;
 	}
 out:
 	module_put(THIS_MODULE);
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index a7a2a6c127c3..dd5fcc895f02 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -82,6 +82,29 @@ EXPORT_SYMBOL(at_early_margin);
 int at_extra = 30;
 EXPORT_SYMBOL(at_extra);
 
+int obd_ioctl_msg(const char *file, const char *func, int line, int level,
+		  const char *name, unsigned int cmd, const char *msg, int rc)
+{
+	static struct cfs_debug_limit_state cdls;
+	static char *dirs[] = {
+		[_IOC_NONE]		= "_IO",
+		[_IOC_READ]		= "_IOR",
+		[_IOC_WRITE]		= "_IOW",
+		[_IOC_READ|_IOC_WRITE]	= "_IOWR",
+	};
+	char type;
+
+	type = _IOC_TYPE(cmd);
+	__CDEBUG_WITH_LOC(file, func, line, level, &cdls,
+			  "%s: iocontrol from '%s' cmd=%x %s('%c', %u, %u) %s: rc = %d\n",
+			  name, current->comm, cmd,
+			  dirs[_IOC_DIR(cmd)] ?: "_IO?",
+			  isprint(type) ? type : '?', _IOC_NR(cmd),
+			  _IOC_SIZE(cmd), msg, rc);
+	return rc;
+}
+EXPORT_SYMBOL(obd_ioctl_msg);
+
 static int class_resolve_dev_name(u32 len, const char *name)
 {
 	int rc;
@@ -199,26 +222,27 @@ int obd_ioctl_getdata(struct obd_ioctl_data **datap, int *len, void __user *arg)
 	struct obd_ioctl_data *data;
 	struct obd_ioctl_hdr hdr;
 	int offset = 0;
-	int err;
+	int rc = -EINVAL;
 
 	if (copy_from_user(&hdr, arg, sizeof(hdr)))
 		return -EFAULT;
 
 	if (hdr.ioc_version != OBD_IOCTL_VERSION) {
-		CERROR("Version mismatch kernel (%x) vs application (%x)\n",
-		       OBD_IOCTL_VERSION, hdr.ioc_version);
-		return -EINVAL;
+		CERROR("%s: kernel/user version mismatch (%x != %x): rc = %d\n",
+		       current->comm, OBD_IOCTL_VERSION, hdr.ioc_version, rc);
+		return rc;
 	}
 
 	if (hdr.ioc_len > OBD_MAX_IOCTL_BUFFER) {
-		CERROR("User buffer len %d exceeds %d max buffer\n",
-		       hdr.ioc_len, OBD_MAX_IOCTL_BUFFER);
-		return -EINVAL;
+		CERROR("%s: user buffer len %d exceeds %d max: rc = %d\n",
+		       current->comm, hdr.ioc_len, OBD_MAX_IOCTL_BUFFER, rc);
+		return rc;
 	}
 
-	if (hdr.ioc_len < sizeof(struct obd_ioctl_data)) {
-		CERROR("User buffer too small for ioctl (%d)\n", hdr.ioc_len);
-		return -EINVAL;
+	if (hdr.ioc_len < sizeof(*data)) {
+		CERROR("%s: user buffer %d too small for ioctl %zu: rc = %d\n",
+		       current->comm, hdr.ioc_len, sizeof(*data), rc);
+		return rc;
 	}
 
 	/* When there are lots of processes calling vmalloc on multi-core
@@ -228,26 +252,27 @@ int obd_ioctl_getdata(struct obd_ioctl_data **datap, int *len, void __user *arg)
 	 */
 	data = kvzalloc(hdr.ioc_len, GFP_KERNEL);
 	if (!data) {
-		CERROR("Cannot allocate control buffer of len %d\n",
-		       hdr.ioc_len);
-		return -EINVAL;
+		rc = -ENOMEM;
+		CERROR("%s: cannot allocate control buffer len %d: rc = %d\n",
+		       current->comm, hdr.ioc_len, rc);
+		return rc;
 	}
 	*len = hdr.ioc_len;
 	*datap = data;
 
 	if (copy_from_user(data, arg, hdr.ioc_len)) {
-		err = -EFAULT;
+		rc = -EFAULT;
 		goto free_buf;
 	}
 
 	if (hdr.ioc_len != data->ioc_len) {
-		err = -EINVAL;
+		rc = -EINVAL;
 		goto free_buf;
 	}
 
 	if (obd_ioctl_is_invalid(data)) {
 		CERROR("ioctl not correctly formatted\n");
-		err = -EINVAL;
+		rc = -EINVAL;
 		goto free_buf;
 	}
 
@@ -273,7 +298,7 @@ int obd_ioctl_getdata(struct obd_ioctl_data **datap, int *len, void __user *arg)
 
 free_buf:
 	kvfree(data);
-	return err;
+	return rc;
 }
 EXPORT_SYMBOL(obd_ioctl_getdata);
 
@@ -281,12 +306,13 @@ int class_handle_ioctl(unsigned int cmd, void __user *uarg)
 {
 	struct obd_ioctl_data *data;
 	struct obd_device *obd = NULL;
-	int err = 0, len = 0;
+	int rc = 0, len = 0;
 
-	CDEBUG(D_IOCTL, "cmd = %x\n", cmd);
-	if (obd_ioctl_getdata(&data, &len, uarg)) {
-		CERROR("OBD ioctl: data error\n");
-		return -EINVAL;
+	CDEBUG(D_IOCTL, "obdclass: cmd=%x len=%u uarg=%pK\n", cmd, len, uarg);
+	rc = obd_ioctl_getdata(&data, &len, uarg);
+	if (rc) {
+		CERROR("%s: ioctl data error: rc = %d\n", current->comm, rc);
+		return rc;
 	}
 
 	switch (cmd) {
@@ -294,28 +320,26 @@ int class_handle_ioctl(unsigned int cmd, void __user *uarg)
 		struct lustre_cfg *lcfg;
 
 		if (!data->ioc_plen1 || !data->ioc_pbuf1) {
-			CERROR("No config buffer passed!\n");
-			err = -EINVAL;
+			rc = OBD_IOC_ERROR("obdclass", cmd, "no config buffer",
+					   -EINVAL);
 			goto out;
 		}
 		lcfg = kzalloc(data->ioc_plen1, GFP_NOFS);
 		if (!lcfg) {
-			err = -ENOMEM;
+			rc = -ENOMEM;
 			goto out;
 		}
-		if (copy_from_user(lcfg, data->ioc_pbuf1, data->ioc_plen1))
-			err = -EFAULT;
-		if (!err)
-			err = lustre_cfg_sanity_check(lcfg, data->ioc_plen1);
-		if (!err)
-			err = class_process_config(lcfg);
+		rc = copy_from_user(lcfg, data->ioc_pbuf1, data->ioc_plen1);
+		if (!rc)
+			rc = lustre_cfg_sanity_check(lcfg, data->ioc_plen1);
+		if (!rc)
+			rc = class_process_config(lcfg);
 
 		kfree(lcfg);
 		goto out;
 	}
 
 	case OBD_GET_VERSION: {
-
 		/* This was the method to pass to user land the lustre version.
 		 * Today that information is in the sysfs tree so we can in the
 		 * future remove this.
@@ -324,14 +348,14 @@ int class_handle_ioctl(unsigned int cmd, void __user *uarg)
 			     LUSTRE_VERSION_CODE);
 
 		if (!data->ioc_inlbuf1) {
-			CERROR("No buffer passed in ioctl\n");
-			err = -EINVAL;
+			rc = OBD_IOC_ERROR("obdclass", cmd, "no buffer passed",
+					   -EINVAL);
 			goto out;
 		}
 
 		if (strlen(LUSTRE_VERSION_STRING) + 1 > data->ioc_inllen1) {
-			CERROR("ioctl buffer too small to hold version\n");
-			err = -EINVAL;
+			rc = OBD_IOC_ERROR("obdclass", cmd, "buffer too small",
+					   -EINVAL);
 			goto out;
 		}
 
@@ -342,7 +366,7 @@ int class_handle_ioctl(unsigned int cmd, void __user *uarg)
 		       strlen(LUSTRE_VERSION_STRING) + 1);
 
 		if (copy_to_user(uarg, data, len))
-			err = -EFAULT;
+			rc = -EFAULT;
 		goto out;
 	}
 	case OBD_IOC_NAME2DEV: {
@@ -355,30 +379,28 @@ int class_handle_ioctl(unsigned int cmd, void __user *uarg)
 					     data->ioc_inlbuf1);
 		data->ioc_dev = dev;
 		if (dev < 0) {
-			err = -EINVAL;
+			rc = -EINVAL;
 			goto out;
 		}
 
 		if (copy_to_user(uarg, data, sizeof(*data)))
-			err = -EFAULT;
+			rc = -EFAULT;
 		goto out;
 	}
 
 	case OBD_IOC_UUID2DEV: {
-		/* Resolve a device uuid.  This does not change the
-		 * currently selected device.
-		 */
-		int dev;
+		/* Resolve device uuid, does not change current selected dev */
 		struct obd_uuid uuid;
+		int dev;
 
 		if (!data->ioc_inllen1 || !data->ioc_inlbuf1) {
-			CERROR("No UUID passed!\n");
-			err = -EINVAL;
+			rc = OBD_IOC_ERROR("obdclass", cmd, "no UUID passed",
+					   -EINVAL);
 			goto out;
 		}
 		if (data->ioc_inlbuf1[data->ioc_inllen1 - 1] != 0) {
-			CERROR("UUID not NUL terminated!\n");
-			err = -EINVAL;
+			rc = OBD_IOC_ERROR("obdclass", cmd, "unterminated UUID",
+					   -EINVAL);
 			goto out;
 		}
 
@@ -389,7 +411,7 @@ int class_handle_ioctl(unsigned int cmd, void __user *uarg)
 		if (dev == -1) {
 			CDEBUG(D_IOCTL, "No device for UUID %s!\n",
 			       data->ioc_inlbuf1);
-			err = -EINVAL;
+			rc = -EINVAL;
 			goto out;
 		}
 
@@ -397,28 +419,28 @@ int class_handle_ioctl(unsigned int cmd, void __user *uarg)
 		       dev);
 
 		if (copy_to_user(uarg, data, sizeof(*data)))
-			err = -EFAULT;
+			rc = -EFAULT;
 		goto out;
 	}
 
 	case OBD_IOC_GETDEVICE: {
-		int     index = data->ioc_count;
-		char    *status, *str;
+		int index = data->ioc_count;
+		char *status, *str;
 
 		if (!data->ioc_inlbuf1) {
-			CERROR("No buffer passed in ioctl\n");
-			err = -EINVAL;
+			rc = OBD_IOC_ERROR("obdclass", cmd, "no buffer passed",
+					    -EINVAL);
 			goto out;
 		}
-		if (data->ioc_inllen1 < 128) {
-			CERROR("ioctl buffer too small to hold version\n");
-			err = -EINVAL;
+		if (data->ioc_inllen1 < MAX_OBD_NAME) {
+			rc = OBD_IOC_ERROR("obdclass", cmd, "too small version",
+					   -EINVAL);
 			goto out;
 		}
 
 		obd = class_num2obd(index);
 		if (!obd) {
-			err = -ENOENT;
+			rc = -ENOENT;
 			goto out;
 		}
 
@@ -439,51 +461,51 @@ int class_handle_ioctl(unsigned int cmd, void __user *uarg)
 			 atomic_read(&obd->obd_refcount));
 
 		if (copy_to_user(uarg, data, len))
-			err = -EFAULT;
+			rc = -EFAULT;
 		goto out;
 	}
 	}
 
 	if (data->ioc_dev == OBD_DEV_BY_DEVNAME) {
 		if (data->ioc_inllen4 <= 0 || !data->ioc_inlbuf4) {
-			err = -EINVAL;
+			rc = -EINVAL;
 			goto out;
 		}
 		if (strnlen(data->ioc_inlbuf4, MAX_OBD_NAME) >= MAX_OBD_NAME) {
-			err = -EINVAL;
+			rc = -EINVAL;
 			goto out;
 		}
 		obd = class_name2obd(data->ioc_inlbuf4);
 	} else if (data->ioc_dev < class_devno_max()) {
 		obd = class_num2obd(data->ioc_dev);
 	} else {
-		CERROR("OBD ioctl: No device\n");
-		err = -EINVAL;
+		rc = OBD_IOC_ERROR("obdclass", cmd, "no device", -EINVAL);
 		goto out;
 	}
 
 	if (!obd) {
-		CERROR("OBD ioctl : No Device %d\n", data->ioc_dev);
-		err = -EINVAL;
+		rc = OBD_IOC_ERROR(data->ioc_inlbuf4, cmd, "no device found",
+				   -EINVAL);
 		goto out;
 	}
 	LASSERT(obd->obd_magic == OBD_DEVICE_MAGIC);
 
 	if (!obd->obd_set_up || obd->obd_stopping) {
-		CERROR("OBD ioctl: device not setup %d\n", data->ioc_dev);
-		err = -EINVAL;
+		rc = -EINVAL;
+		CERROR("obdclass: device %d not set up: rc = %d\n",
+		       data->ioc_dev, rc);
 		goto out;
 	}
 
-	err = obd_iocontrol(cmd, obd->obd_self_export, len, data, NULL);
-	if (err)
+	rc = obd_iocontrol(cmd, obd->obd_self_export, len, data, NULL);
+	if (rc)
 		goto out;
 
 	if (copy_to_user(uarg, data, len))
-		err = -EFAULT;
+		rc = -EFAULT;
 out:
 	kvfree(data);
-	return err;
+	return rc;
 } /* class_handle_ioctl */
 
 /* to control /dev/obd */
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index d7de6e48c7cb..95af2af66918 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -999,6 +999,9 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	int rw = OBD_BRW_READ;
 	int rc = 0;
 
+	CDEBUG(D_IOCTL, "%s: cmd=%x len=%u karg=%pK uarg=%pK\n",
+	       exp->exp_obd->obd_name, cmd, len, karg, uarg);
+
 	oa = &data->ioc_obdo1;
 	if (!(oa->o_valid & OBD_MD_FLGROUP)) {
 		oa->o_valid |= OBD_MD_FLGROUP;
@@ -1076,11 +1079,9 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	case OBD_IOC_BRW_READ:
 		rc = echo_client_brw_ioctl(env, rw, exp, data);
 		goto out;
-
 	default:
-		CERROR("echo_ioctl(): unrecognised ioctl %#x\n", cmd);
-		rc = -ENOTTY;
-		goto out;
+		rc = OBD_IOC_ERROR(obd->obd_name, cmd, "unrecognized", -ENOTTY);
+		break;
 	}
 
 out:
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 35dd009b3507..e0955c11191b 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -3359,6 +3359,9 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	struct obd_ioctl_data *data = karg;
 	int rc = 0;
 
+	CDEBUG(D_IOCTL, "%s: cmd=%x len=%u karg=%pK uarg=%pK\n",
+	       obd->obd_name, cmd, len, karg, uarg);
+
 	if (!try_module_get(THIS_MODULE)) {
 		CERROR("%s: cannot get module '%s'\n", obd->obd_name,
 		       module_name(THIS_MODULE));
@@ -3379,9 +3382,8 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 					      data->ioc_offset);
 		break;
 	default:
-		CDEBUG(D_INODE, "%s: unrecognised ioctl %#x by %s\n",
-		       obd->obd_name, cmd, current->comm);
-		rc = -ENOTTY;
+		rc = OBD_IOC_DEBUG(D_IOCTL, obd->obd_name, cmd, "unrecognized",
+				   -ENOTTY);
 		break;
 	}
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
