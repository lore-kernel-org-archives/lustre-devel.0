Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8ACFDC0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:50:06 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLmf6BXTz1x69;
	Thu, 30 Jan 2025 06:21:22 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLc5036rz210R
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:13:56 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 2D6BA18236E;
 Thu, 30 Jan 2025 09:11:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 2B9F9106BE17; Thu, 30 Jan 2025 09:11:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:11:09 -0500
Message-ID: <20250130141115.950749-20-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 19/25] lustre: misc: standardize iocontrol
 param handling
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
 Vitaliy Kuznetsov <vkuznetsov@ddn.com>, Tao Lyu <tao.lyu@epfl.ch>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

Validate uarg and karg early in iocontrol processing where needed.
This needs kernel interop for 4.20+ kernels for access_ok().

WC-bug-id: https://jira.whamcloud.com/browse/LU-16634
Lustre-commit: 5eae8514f5f1730fe ("LU-16634 misc: standardize iocontrol param handling")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reported-by: Tao Lyu <tao.lyu@epfl.ch>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50314
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Vitaliy Kuznetsov <vkuznetsov@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c                  | 47 ++++++++++++++++---------
 fs/lustre/llite/llite_lib.c             | 20 +++++++----
 fs/lustre/lmv/lmv_obd.c                 | 28 ++++++++++-----
 fs/lustre/lov/lov_obd.c                 | 26 ++++++++++++--
 fs/lustre/mdc/mdc_request.c             | 24 +++++++------
 fs/lustre/obdclass/class_obd.c          | 12 ++++---
 fs/lustre/obdecho/echo_client.c         |  8 ++++-
 fs/lustre/osc/osc_request.c             | 22 ++++++++++--
 include/uapi/linux/lustre/lustre_user.h |  1 +
 9 files changed, 137 insertions(+), 51 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index d196362a40ca..11006682be1a 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2500,6 +2500,10 @@ static int ll_file_getstripe(struct inode *inode, void __user *lum, size_t size)
 	u16 refcheck;
 	int rc;
 
+	/* exit before doing any work if pointer is bad */
+	if (unlikely(!access_ok(lum, sizeof(struct lov_user_md))))
+		return -EFAULT;
+
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
 		return PTR_ERR(env);
@@ -3826,7 +3830,7 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 	bool lease_broken = false;
 	fmode_t fmode = 0;
 	enum mds_op_bias bias = 0;
-	int fdv;
+	u32 fdv;
 	struct file *layout_file = NULL;
 	void *data = NULL;
 	size_t data_size = 0;
@@ -3873,7 +3877,7 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 		}
 
 		uarg += sizeof(*ioc);
-		if (copy_from_user(&fdv, uarg, sizeof(u32))) {
+		if (copy_from_user(&fdv, uarg, sizeof(fdv))) {
 			rc = -EFAULT;
 			goto out_lease_close;
 		}
@@ -3894,7 +3898,7 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 		bias = MDS_CLOSE_LAYOUT_MERGE;
 		break;
 	case LL_LEASE_LAYOUT_SPLIT: {
-		int mirror_id;
+		u32 mirror_id;
 
 		if (ioc->lil_count != 2) {
 			rc = -EINVAL;
@@ -3902,17 +3906,20 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 		}
 
 		uarg += sizeof(*ioc);
-		if (copy_from_user(&fdv, uarg, sizeof(u32))) {
+		if (copy_from_user(&fdv, uarg, sizeof(fdv))) {
 			rc = -EFAULT;
 			goto out_lease_close;
 		}
 
-		uarg += sizeof(u32);
-		if (copy_from_user(&mirror_id, uarg,
-				   sizeof(u32))) {
+		uarg += sizeof(fdv);
+		if (copy_from_user(&mirror_id, uarg, sizeof(mirror_id))) {
 			rc = -EFAULT;
 			goto out_lease_close;
 		}
+		if (mirror_id >= MIRROR_ID_NEG) {
+			rc = -EINVAL;
+			goto out_lease_close;
+		}
 
 		layout_file = fget(fdv);
 		if (!layout_file) {
@@ -4110,6 +4117,9 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	if (_IOC_TYPE(cmd) == 'T' || _IOC_TYPE(cmd) == 't') /* tty ioctls */
 		return -ENOTTY;
 
+	/* can't do a generic karg == NULL check here, since it is too noisy and
+	 * we need to return -ENOTTY for unsupported ioctls instead of -EINVAL.
+	 */
 	switch (cmd) {
 	case LL_IOC_GETFLAGS:
 		/* Get the current value of the file flags */
@@ -4263,6 +4273,9 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct hsm_user_state *hus;
 		int rc;
 
+		if (!access_ok(uarg, sizeof(*hus)))
+			return -EFAULT;
+
 		hus = kzalloc(sizeof(*hus), GFP_KERNEL);
 		if (!hus)
 			return -ENOMEM;
@@ -4270,17 +4283,16 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
 					     LUSTRE_OPC_ANY, hus);
 		if (IS_ERR(op_data)) {
-			kfree(hus);
-			return PTR_ERR(op_data);
-		}
-
-		rc = obd_iocontrol(cmd, ll_i2mdexp(inode), sizeof(*op_data),
-				   op_data, NULL);
+			rc = PTR_ERR(op_data);
+		} else {
+			rc = obd_iocontrol(cmd, ll_i2mdexp(inode),
+					   sizeof(*op_data), op_data, NULL);
 
-		if (copy_to_user(uarg, hus, sizeof(*hus)))
-			rc = -EFAULT;
+			if (copy_to_user(uarg, hus, sizeof(*hus)))
+				rc = -EFAULT;
 
-		ll_finish_md_op_data(op_data);
+			ll_finish_md_op_data(op_data);
+		}
 		kfree(hus);
 		return rc;
 	}
@@ -4303,6 +4315,9 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		const char *action;
 		int rc;
 
+		if (!access_ok(uarg, sizeof(*hca)))
+			return -EFAULT;
+
 		hca = kzalloc(sizeof(*hca), GFP_KERNEL);
 		if (!hca)
 			return -ENOMEM;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 936a81c65870..751886b47445 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -37,18 +37,18 @@
 #define DEBUG_SUBSYSTEM S_LLITE
 
 #include <linux/cpu.h>
+
+#include <linux/delay.h>
+#include <linux/file.h>
+#include <linux/fs_struct.h>
+#include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/random.h>
 #include <linux/statfs.h>
-#include <linux/file.h>
 #include <linux/types.h>
-#include <linux/mm.h>
-#include <linux/delay.h>
+#include <linux/uaccess.h>
+#include <linux/uidgid.h>
 #include <linux/uuid.h>
-#include <linux/random.h>
-#include <linux/security.h>
-#include <linux/fs_struct.h>
-#include <uapi/linux/mount.h>
 
 #include <linux/libcfs/libcfs_cpu.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
@@ -2887,6 +2887,9 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		struct mdt_body *body;
 		struct md_op_data *op_data;
 
+		if (!access_ok(uarg, sizeof(int)))
+			return -EFAULT;
+
 		op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
 					     LUSTRE_OPC_ANY, NULL);
 		if (IS_ERR(op_data)) {
@@ -2982,6 +2985,9 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		rc = ll_obd_statfs(inode, uarg);
 		break;
 	case LL_IOC_GET_MDTIDX: {
+		if (!access_ok(uarg, sizeof(rc)))
+			return -EFAULT;
+
 		rc = ll_get_mdt_idx(inode);
 		if (rc < 0)
 			break;
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 62385ac9b00f..98ee902d8cb5 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -837,6 +837,23 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 	if (count == 0)
 		return -ENOTTY;
 
+	/* exit early for unknown ioctl types */
+	if (unlikely(_IOC_TYPE(cmd) != 'f' && cmd != IOC_OSC_SET_ACTIVE))
+		return OBD_IOC_ERROR(obd->obd_name, cmd, "unknown", -ENOTTY);
+
+	/* handle commands that don't use @karg first */
+	switch (cmd) {
+	case LL_IOC_GET_CONNECT_FLAGS:
+		tgt = lmv_tgt(lmv, 0);
+		rc = -ENODATA;
+		if (tgt && tgt->ltd_exp)
+			rc = obd_iocontrol(cmd, tgt->ltd_exp, len, NULL, uarg);
+		return rc;
+	}
+
+	if (unlikely(!karg))
+		return OBD_IOC_ERROR(obd->obd_name, cmd, "karg=NULL", -EINVAL);
+
 	switch (cmd) {
 	case IOC_OBD_STATFS: {
 		struct obd_ioctl_data *data = karg;
@@ -926,14 +943,6 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		kfree(oqctl);
 		break;
 	}
-	case LL_IOC_GET_CONNECT_FLAGS: {
-		tgt = lmv_tgt(lmv, 0);
-		rc = -ENODATA;
-
-		if (tgt && tgt->ltd_exp)
-			rc = obd_iocontrol(cmd, tgt->ltd_exp, len, karg, uarg);
-		break;
-	}
 	case LL_IOC_FID2MDTIDX: {
 		struct lu_fid *fid = karg;
 		int mdt_index;
@@ -1076,6 +1085,8 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 						      tgt->ltd_uuid.uuid, err);
 					if (!rc)
 						rc = err;
+					if (unlikely(err == -ENOTTY))
+						break;
 				}
 			} else {
 				set = 1;
@@ -1083,6 +1094,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		}
 		if (!set && !rc)
 			rc = -EIO;
+		break;
 	}
 	return rc;
 }
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 8bfce5001d58..a152f0b2d2ec 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -973,15 +973,28 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	CDEBUG(D_IOCTL, "%s: cmd=%x len=%u karg=%pK uarg=%pK\n",
 	       exp->exp_obd->obd_name, cmd, len, karg, uarg);
 
+	/* exit early for unknown ioctl types */
+	if (unlikely(_IOC_TYPE(cmd) != 'f' && cmd != IOC_OSC_SET_ACTIVE))
+		return OBD_IOC_DEBUG(D_IOCTL, obd->obd_name, cmd, "unknown",
+				     -ENOTTY);
+
+	/* can't do a generic karg == NULL check here, since it is too noisy and
+	 * we need to return -ENOTTY for unsupported ioctls instead of -EINVAL.
+	 */
 	switch (cmd) {
 	case IOC_OBD_STATFS: {
-		struct obd_ioctl_data *data = karg;
+		struct obd_ioctl_data *data;
 		struct obd_device *osc_obd;
 		struct obd_statfs stat_buf = { 0 };
 		struct obd_import *imp;
 		u32 index;
 		u32 flags;
 
+		if (unlikely(!karg))
+			return OBD_IOC_ERROR(obd->obd_name, cmd, "karg=null",
+					     -EINVAL);
+		data = karg;
+
 		memcpy(&index, data->ioc_inlbuf2, sizeof(index));
 		if (index >= count)
 			return -ENODEV;
@@ -1021,11 +1034,16 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		break;
 	}
 	case OBD_IOC_QUOTACTL: {
-		struct if_quotactl *qctl = karg;
+		struct if_quotactl *qctl;
 		struct lov_tgt_desc *tgt = NULL;
 		struct obd_quotactl *oqctl;
 		struct obd_import *imp;
 
+		if (unlikely(!karg))
+			return OBD_IOC_ERROR(obd->obd_name, cmd, "karg=null",
+					     -EINVAL);
+		qctl = karg;
+
 		if (qctl->qc_valid == QC_OSTIDX) {
 			if (count <= qctl->qc_idx)
 				return -EINVAL;
@@ -1107,6 +1125,9 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 						      err);
 					if (!rc)
 						rc = err;
+
+					if (err == -ENOTTY)
+						break;
 				}
 			} else {
 				set = 1;
@@ -1114,6 +1135,7 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		}
 		if (!set && !rc)
 			rc = -EIO;
+		break;
 	}
 	}
 
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 84c4d2888e7d..55a7b5cf1249 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2204,13 +2204,26 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 			 void *karg, void __user *uarg)
 {
 	struct obd_device *obd = exp->exp_obd;
-	struct obd_ioctl_data *data = karg;
+	struct obd_ioctl_data *data;
 	struct obd_import *imp = obd->u.cli.cl_import;
 	int rc;
 
 	CDEBUG(D_IOCTL, "%s: cmd=%x len=%u karg=%pK uarg=%pK\n",
 	       obd->obd_name, cmd, len, karg, uarg);
 
+	/* handle commands that do not need @karg first */
+	switch (cmd) {
+	case LL_IOC_GET_CONNECT_FLAGS:
+		if (copy_to_user(uarg, exp_connect_flags_ptr(exp),
+				 sizeof(*exp_connect_flags_ptr(exp))))
+			return -EFAULT;
+		return 0;
+	}
+
+	if (unlikely(!karg))
+		return OBD_IOC_ERROR(obd->obd_name, cmd, "karg=NULL", -EINVAL);
+	data = karg;
+
 	if (!try_module_get(THIS_MODULE)) {
 		CERROR("%s: cannot get module '%s'\n", obd->obd_name,
 		       module_name(THIS_MODULE));
@@ -2311,15 +2324,6 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		kfree(oqctl);
 		goto out;
 	}
-	case LL_IOC_GET_CONNECT_FLAGS:
-		if (copy_to_user(uarg, exp_connect_flags_ptr(exp),
-				 sizeof(*exp_connect_flags_ptr(exp)))) {
-			rc = -EFAULT;
-			goto out;
-		}
-
-		rc = 0;
-		goto out;
 	case LL_IOC_LOV_SWAP_LAYOUTS:
 		rc = mdc_ioc_swap_layouts(exp, karg);
 		goto out;
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index dd5fcc895f02..3692d57fbcef 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -262,18 +262,17 @@ int obd_ioctl_getdata(struct obd_ioctl_data **datap, int *len, void __user *arg)
 
 	if (copy_from_user(data, arg, hdr.ioc_len)) {
 		rc = -EFAULT;
-		goto free_buf;
+		goto out_free;
 	}
 
 	if (hdr.ioc_len != data->ioc_len) {
 		rc = -EINVAL;
-		goto free_buf;
+		goto out_free;
 	}
 
 	if (obd_ioctl_is_invalid(data)) {
-		CERROR("ioctl not correctly formatted\n");
 		rc = -EINVAL;
-		goto free_buf;
+		goto out_free;
 	}
 
 	if (data->ioc_inllen1) {
@@ -296,7 +295,7 @@ int obd_ioctl_getdata(struct obd_ioctl_data **datap, int *len, void __user *arg)
 
 	return 0;
 
-free_buf:
+out_free:
 	kvfree(data);
 	return rc;
 }
@@ -309,6 +308,9 @@ int class_handle_ioctl(unsigned int cmd, void __user *uarg)
 	int rc = 0, len = 0;
 
 	CDEBUG(D_IOCTL, "obdclass: cmd=%x len=%u uarg=%pK\n", cmd, len, uarg);
+	if (unlikely(_IOC_TYPE(cmd) != 'f' && cmd != IOC_OSC_SET_ACTIVE))
+		return OBD_IOC_ERROR(obd->obd_name, cmd, "unknown", -ENOTTY);
+
 	rc = obd_ioctl_getdata(&data, &len, uarg);
 	if (rc) {
 		CERROR("%s: ioctl data error: rc = %d\n", current->comm, rc);
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 95af2af66918..220ceae89150 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -991,7 +991,7 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	struct echo_device *ed = obd2echo_dev(obd);
 	struct echo_client_obd *ec = ed->ed_ec;
 	struct echo_object *eco;
-	struct obd_ioctl_data *data = karg;
+	struct obd_ioctl_data *data;
 	struct lu_env *env;
 	u16 refcheck;
 	struct obdo *oa;
@@ -1002,6 +1002,12 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	CDEBUG(D_IOCTL, "%s: cmd=%x len=%u karg=%pK uarg=%pK\n",
 	       exp->exp_obd->obd_name, cmd, len, karg, uarg);
 
+	 CDEBUG(D_IOCTL, "%s: cmd=%x len=%u karg=%pK uarg=%pK\n",
+		exp->exp_obd->obd_name, cmd, len, karg, uarg);
+	if (unlikely(!karg))
+		return OBD_IOC_ERROR(obd->obd_name, cmd, "karg=NULL", rc);
+	data = karg;
+
 	oa = &data->ioc_obdo1;
 	if (!(oa->o_valid & OBD_MD_FLGROUP)) {
 		oa->o_valid |= OBD_MD_FLGROUP;
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 8efdd5a8cd8a..061767503401 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -3358,8 +3358,8 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 			 void *karg, void __user *uarg)
 {
 	struct obd_device *obd = exp->exp_obd;
-	struct obd_ioctl_data *data = karg;
-	int rc = 0;
+	struct obd_ioctl_data *data;
+	int rc;
 
 	CDEBUG(D_IOCTL, "%s: cmd=%x len=%u karg=%pK uarg=%pK\n",
 	       obd->obd_name, cmd, len, karg, uarg);
@@ -3371,15 +3371,33 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	}
 	switch (cmd) {
 	case OBD_IOC_CLIENT_RECOVER:
+		if (unlikely(!karg)) {
+			OBD_IOC_ERROR(obd->obd_name, cmd, "karg=NULL",
+				      rc = -EINVAL);
+			break;
+		}
+		data = karg;
 		rc = ptlrpc_recover_import(obd->u.cli.cl_import,
 					   data->ioc_inlbuf1, 0);
 		if (rc > 0)
 			rc = 0;
 		break;
 	case OBD_IOC_GETATTR:
+		if (unlikely(!karg)) {
+			OBD_IOC_ERROR(obd->obd_name, cmd, "karg=NULL",
+				      rc = -EINVAL);
+			break;
+		}
+		data = karg;
 		rc = obd_getattr(NULL, exp, &data->ioc_obdo1);
 		break;
 	case IOC_OSC_SET_ACTIVE:
+		if (unlikely(!karg)) {
+			OBD_IOC_ERROR(obd->obd_name, cmd, "karg=NULL",
+				      rc = -EINVAL);
+			break;
+		}
+		data = karg;
 		rc = ptlrpc_set_import_active(obd->u.cli.cl_import,
 					      data->ioc_offset);
 		break;
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 876d337a3b2b..9c0632856bc8 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -653,6 +653,7 @@ struct lov_comp_md_entry_v1 {
 #define SEQ_ID_MASK		SEQ_ID_MAX
 /* bit 30:16 of lcme_id is used to store mirror id */
 #define MIRROR_ID_MASK		0x7FFF0000
+#define MIRROR_ID_NEG		0x8000
 #define MIRROR_ID_SHIFT		16
 
 static inline __u32 pflr_id(__u16 mirror_id, __u16 seqid)
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
