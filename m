From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 15:00:12 +0100
Subject: [lustre-devel] [PATCH 7/7] staging: lustre: Rename a jump label for
 module_put() calls
In-Reply-To: <566D7733.1030102@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
Message-ID: <566D79EC.6050104@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 14:05:57 +0100

This issue was detected by using the Coccinelle software.

Choose a jump label according to the current Linux coding style convention.
I suggest to improve this implementation detail by the reuse of a script
like the following for the semantic patch language.

@rename_jump_label exists@
identifier target != put_module, work;
type return_type;
@@
 return_type work(...)
 {
 ... when any
 goto
-target
+put_module
 ;
 ... when any
-target
+put_module
 :
 module_put(...);
 ... when any
 }

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/llite/lloop.c     |  8 ++--
 drivers/staging/lustre/lustre/mdc/mdc_request.c | 52 ++++++++++++-------------
 drivers/staging/lustre/lustre/osc/osc_request.c | 24 ++++++------
 3 files changed, 42 insertions(+), 42 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lloop.c b/drivers/staging/lustre/lustre/llite/lloop.c
index 420d391..ebeef3b 100644
--- a/drivers/staging/lustre/lustre/llite/lloop.c
+++ b/drivers/staging/lustre/lustre/llite/lloop.c
@@ -484,14 +484,14 @@ static int loop_set_fd(struct lloop_device *lo, struct file *unused,
 
 	error = -EBUSY;
 	if (lo->lo_state != LLOOP_UNBOUND)
-		goto out;
+		goto put_module;
 
 	mapping = file->f_mapping;
 	inode = mapping->host;
 
 	error = -EINVAL;
 	if (!S_ISREG(inode->i_mode) || inode->i_sb->s_magic != LL_SUPER_MAGIC)
-		goto out;
+		goto put_module;
 
 	if (!(file->f_mode & FMODE_WRITE))
 		lo_flags |= LO_FLAGS_READ_ONLY;
@@ -500,7 +500,7 @@ static int loop_set_fd(struct lloop_device *lo, struct file *unused,
 
 	if ((loff_t)(sector_t)size != size) {
 		error = -EFBIG;
-		goto out;
+		goto put_module;
 	}
 
 	/* remove all pages in cache so as dirty pages not to be existent. */
@@ -542,7 +542,7 @@ static int loop_set_fd(struct lloop_device *lo, struct file *unused,
 	down(&lo->lo_sem);
 	return 0;
 
-out:
+put_module:
 	/* This is safe: open() is still holding a reference. */
 	module_put(THIS_MODULE);
 	return error;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 2085ba6..eaeca9a 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1734,7 +1734,7 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	switch (cmd) {
 	case OBD_IOC_CHANGELOG_SEND:
 		rc = mdc_ioc_changelog_send(obd, karg);
-		goto out;
+		goto put_module;
 	case OBD_IOC_CHANGELOG_CLEAR: {
 		struct ioc_changelog *icc = karg;
 		struct changelog_setinfo cs = {
@@ -1745,47 +1745,47 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		rc = obd_set_info_async(NULL, exp, strlen(KEY_CHANGELOG_CLEAR),
 					KEY_CHANGELOG_CLEAR, sizeof(cs), &cs,
 					NULL);
-		goto out;
+		goto put_module;
 	}
 	case OBD_IOC_FID2PATH:
 		rc = mdc_ioc_fid2path(exp, karg);
-		goto out;
+		goto put_module;
 	case LL_IOC_HSM_CT_START:
 		rc = mdc_ioc_hsm_ct_start(exp, karg);
 		/* ignore if it was already registered on this MDS. */
 		if (rc == -EEXIST)
 			rc = 0;
-		goto out;
+		goto put_module;
 	case LL_IOC_HSM_PROGRESS:
 		rc = mdc_ioc_hsm_progress(exp, karg);
-		goto out;
+		goto put_module;
 	case LL_IOC_HSM_STATE_GET:
 		rc = mdc_ioc_hsm_state_get(exp, karg);
-		goto out;
+		goto put_module;
 	case LL_IOC_HSM_STATE_SET:
 		rc = mdc_ioc_hsm_state_set(exp, karg);
-		goto out;
+		goto put_module;
 	case LL_IOC_HSM_ACTION:
 		rc = mdc_ioc_hsm_current_action(exp, karg);
-		goto out;
+		goto put_module;
 	case LL_IOC_HSM_REQUEST:
 		rc = mdc_ioc_hsm_request(exp, karg);
-		goto out;
+		goto put_module;
 	case OBD_IOC_CLIENT_RECOVER:
 		rc = ptlrpc_recover_import(imp, data->ioc_inlbuf1, 0);
 		if (rc < 0)
-			goto out;
+			goto put_module;
 		rc = 0;
-		goto out;
+		goto put_module;
 	case IOC_OSC_SET_ACTIVE:
 		rc = ptlrpc_set_import_active(imp, data->ioc_offset);
-		goto out;
+		goto put_module;
 	case OBD_IOC_POLL_QUOTACHECK:
 		rc = mdc_quota_poll_check(exp, (struct if_quotacheck *)karg);
-		goto out;
+		goto put_module;
 	case OBD_IOC_PING_TARGET:
 		rc = ptlrpc_obd_ping(obd);
-		goto out;
+		goto put_module;
 	/*
 	 * Normally IOC_OBD_STATFS, OBD_IOC_QUOTACTL iocontrol are handled by
 	 * LMV instead of MDC. But when the cluster is upgraded from 1.8,
@@ -1798,7 +1798,7 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 
 		if (*((__u32 *) data->ioc_inlbuf2) != 0) {
 			rc = -ENODEV;
-			goto out;
+			goto put_module;
 		}
 
 		/* copy UUID */
@@ -1806,24 +1806,24 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 				 min_t(size_t, data->ioc_plen2,
 					       sizeof(struct obd_uuid)))) {
 			rc = -EFAULT;
-			goto out;
+			goto put_module;
 		}
 
 		rc = mdc_statfs(NULL, obd->obd_self_export, &stat_buf,
 				cfs_time_shift_64(-OBD_STATFS_CACHE_SECONDS),
 				0);
 		if (rc != 0)
-			goto out;
+			goto put_module;
 
 		if (copy_to_user(data->ioc_pbuf1, &stat_buf,
 				 min_t(size_t, data->ioc_plen1,
 					       sizeof(stat_buf)))) {
 			rc = -EFAULT;
-			goto out;
+			goto put_module;
 		}
 
 		rc = 0;
-		goto out;
+		goto put_module;
 	}
 	case OBD_IOC_QUOTACTL: {
 		struct if_quotactl *qctl = karg;
@@ -1832,7 +1832,7 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		oqctl = kzalloc(sizeof(*oqctl), GFP_NOFS);
 		if (!oqctl) {
 			rc = -ENOMEM;
-			goto out;
+			goto put_module;
 		}
 
 		QCTL_COPY(oqctl, qctl);
@@ -1844,26 +1844,26 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		}
 
 		kfree(oqctl);
-		goto out;
+		goto put_module;
 	}
 	case LL_IOC_GET_CONNECT_FLAGS:
 		if (copy_to_user(uarg, exp_connect_flags_ptr(exp),
 				 sizeof(*exp_connect_flags_ptr(exp)))) {
 			rc = -EFAULT;
-			goto out;
+			goto put_module;
 		}
 
 		rc = 0;
-		goto out;
+		goto put_module;
 	case LL_IOC_LOV_SWAP_LAYOUTS:
 		rc = mdc_ioc_swap_layouts(exp, karg);
-		goto out;
+		goto put_module;
 	default:
 		CERROR("unrecognised ioctl: cmd = %#x\n", cmd);
 		rc = -ENOTTY;
-		goto out;
+		goto put_module;
 	}
-out:
+put_module:
 	module_put(THIS_MODULE);
 
 	return rc;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 3a56fb7..3ee1ff8 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2611,7 +2611,7 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		len = 0;
 		if (obd_ioctl_getdata(&buf, &len, uarg)) {
 			err = -EINVAL;
-			goto out;
+			goto put_module;
 		}
 
 		data = (struct obd_ioctl_data *)buf;
@@ -2619,13 +2619,13 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		if (sizeof(*desc) > data->ioc_inllen1) {
 			obd_ioctl_freedata(buf, len);
 			err = -EINVAL;
-			goto out;
+			goto put_module;
 		}
 
 		if (data->ioc_inllen2 < sizeof(uuid)) {
 			obd_ioctl_freedata(buf, len);
 			err = -EINVAL;
-			goto out;
+			goto put_module;
 		}
 
 		desc = (struct lov_desc *)data->ioc_inlbuf1;
@@ -2643,39 +2643,39 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		if (err)
 			err = -EFAULT;
 		obd_ioctl_freedata(buf, len);
-		goto out;
+		goto put_module;
 	}
 	case LL_IOC_LOV_SETSTRIPE:
 		err = obd_alloc_memmd(exp, karg);
 		if (err > 0)
 			err = 0;
-		goto out;
+		goto put_module;
 	case LL_IOC_LOV_GETSTRIPE:
 		err = osc_getstripe(karg, uarg);
-		goto out;
+		goto put_module;
 	case OBD_IOC_CLIENT_RECOVER:
 		err = ptlrpc_recover_import(obd->u.cli.cl_import,
 					    data->ioc_inlbuf1, 0);
 		if (err > 0)
 			err = 0;
-		goto out;
+		goto put_module;
 	case IOC_OSC_SET_ACTIVE:
 		err = ptlrpc_set_import_active(obd->u.cli.cl_import,
 					       data->ioc_offset);
-		goto out;
+		goto put_module;
 	case OBD_IOC_POLL_QUOTACHECK:
 		err = osc_quota_poll_check(exp, karg);
-		goto out;
+		goto put_module;
 	case OBD_IOC_PING_TARGET:
 		err = ptlrpc_obd_ping(obd);
-		goto out;
+		goto put_module;
 	default:
 		CDEBUG(D_INODE, "unrecognised ioctl %#x by %s\n",
 		       cmd, current_comm());
 		err = -ENOTTY;
-		goto out;
+		goto put_module;
 	}
-out:
+put_module:
 	module_put(THIS_MODULE);
 	return err;
 }
-- 
2.6.3
