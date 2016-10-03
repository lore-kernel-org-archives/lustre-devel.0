From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:26 -0400
Subject: [lustre-devel] [PATCH 30/41] staging: lustre: quota: remove
	obsolete quota code
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-31-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

Remove the obsolete quotacheck, quotaon and quotaoff, which
were retained for the interoperability with old (< 2.4) client
and server.

Some other obsolete quota code related to LL_IOC_QUOTACTL_18,
Q_INVLIDATE and Q_FINVALIDATE are removed as well.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5975
Reviewed-on: http://review.whamcloud.com/14705
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    6 +-
 .../lustre/lustre/include/lustre/lustre_ioctl.h    |    4 +-
 .../lustre/lustre/include/lustre/lustre_user.h     |   13 +---
 .../lustre/lustre/include/lustre_req_layout.h      |    3 -
 drivers/staging/lustre/lustre/include/obd.h        |    9 ---
 drivers/staging/lustre/lustre/include/obd_class.h  |   12 ----
 .../staging/lustre/lustre/include/obd_support.h    |    6 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    2 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   24 -------
 drivers/staging/lustre/lustre/llite/dir.c          |   65 --------------------
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   31 +---------
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   54 +----------------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   50 ---------------
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    3 -
 drivers/staging/lustre/lustre/osc/osc_quota.c      |   44 -------------
 drivers/staging/lustre/lustre/osc/osc_request.c    |    4 -
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   15 -----
 17 files changed, 15 insertions(+), 330 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 17feb71..7645ed9 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1406,7 +1406,7 @@ enum ost_cmd {
 	OST_STATFS     = 13,
 	OST_SYNC       = 16,
 	OST_SET_INFO   = 17,
-	OST_QUOTACHECK = 18,
+	OST_QUOTACHECK = 18, /* not used since 2.4 */
 	OST_QUOTACTL   = 19,
 	OST_QUOTA_ADJUST_QUNIT = 20, /* not used since 2.4 */
 	OST_LAST_OPC
@@ -1925,7 +1925,7 @@ enum mds_cmd {
 	MDS_SYNC		= 44,
 	MDS_DONE_WRITING	= 45, /* obsolete since 2.8.0 */
 	MDS_SET_INFO		= 46,
-	MDS_QUOTACHECK		= 47,
+	MDS_QUOTACHECK		= 47, /* not used since 2.4 */
 	MDS_QUOTACTL		= 48,
 	MDS_GETXATTR		= 49,
 	MDS_SETXATTR		= 50, /* obsolete, now it's MDS_REINT op */
@@ -2889,7 +2889,7 @@ void lustre_swab_cfg_marker(struct cfg_marker *marker, int swab, int size);
 enum obd_cmd {
 	OBD_PING = 400,
 	OBD_LOG_CANCEL,
-	OBD_QC_CALLBACK,
+	OBD_QC_CALLBACK, /* not used since 2.4 */
 	OBD_IDX_READ,
 	OBD_LAST_OPC
 };
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
index f3d7c94..eb08df3 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
@@ -363,8 +363,8 @@ obd_ioctl_unpack(struct obd_ioctl_data *data, char *pbuf, int max_len)
 /*	OBD_IOC_LOV_GETSTRIPE	155 LL_IOC_LOV_GETSTRIPE */
 /*	OBD_IOC_LOV_SETEA	156 LL_IOC_LOV_SETEA */
 /*	lustre/lustre_user.h	157-159 */
-#define	OBD_IOC_QUOTACHECK	_IOW('f', 160, int)
-#define	OBD_IOC_POLL_QUOTACHECK	_IOR('f', 161, struct if_quotacheck *)
+/*	OBD_IOC_QUOTACHECK	_IOW('f', 160, int) */
+/*	OBD_IOC_POLL_QUOTACHECK	_IOR('f', 161, struct if_quotacheck *) */
 #define OBD_IOC_QUOTACTL	_IOWR('f', 162, struct if_quotactl)
 /*	lustre/lustre_user.h	163-176 */
 #define OBD_IOC_CHANGELOG_REG	_IOW('f', 177, struct obd_ioctl_data)
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 80fecba..856e2f9 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -557,23 +557,18 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 #define Q_FINVALIDATE  0x800104 /* deprecated as of 2.4 */
 
 /* these must be explicitly translated into linux Q_* in ll_dir_ioctl */
-#define LUSTRE_Q_QUOTAON    0x800002     /* turn quotas on */
-#define LUSTRE_Q_QUOTAOFF   0x800003     /* turn quotas off */
+#define LUSTRE_Q_QUOTAON    0x800002	/* deprecated as of 2.4 */
+#define LUSTRE_Q_QUOTAOFF   0x800003	/* deprecated as of 2.4 */
 #define LUSTRE_Q_GETINFO    0x800005     /* get information about quota files */
 #define LUSTRE_Q_SETINFO    0x800006     /* set information about quota files */
 #define LUSTRE_Q_GETQUOTA   0x800007     /* get user quota structure */
 #define LUSTRE_Q_SETQUOTA   0x800008     /* set user quota structure */
 /* lustre-specific control commands */
-#define LUSTRE_Q_INVALIDATE  0x80000b     /* invalidate quota data */
-#define LUSTRE_Q_FINVALIDATE 0x80000c     /* invalidate filter quota data */
+#define LUSTRE_Q_INVALIDATE  0x80000b	/* deprecated as of 2.4 */
+#define LUSTRE_Q_FINVALIDATE 0x80000c	/* deprecated as of 2.4 */
 
 #define UGQUOTA 2       /* set both USRQUOTA and GRPQUOTA */
 
-struct if_quotacheck {
-	char		    obd_type[16];
-	struct obd_uuid	 obd_uuid;
-};
-
 #define IDENTITY_DOWNCALL_MAGIC 0x6d6dd629
 
 /* permission */
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index dd8717e..78857b3 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -165,9 +165,7 @@ extern struct req_format RQF_MDS_REINT_LINK;
 extern struct req_format RQF_MDS_REINT_RENAME;
 extern struct req_format RQF_MDS_REINT_SETATTR;
 extern struct req_format RQF_MDS_REINT_SETXATTR;
-extern struct req_format RQF_MDS_QUOTACHECK;
 extern struct req_format RQF_MDS_QUOTACTL;
-extern struct req_format RQF_QC_CALLBACK;
 extern struct req_format RQF_MDS_SWAP_LAYOUTS;
 /* MDS hsm formats */
 extern struct req_format RQF_MDS_HSM_STATE_GET;
@@ -180,7 +178,6 @@ extern struct req_format RQF_MDS_HSM_REQUEST;
 /* OST req_format */
 extern struct req_format RQF_OST_CONNECT;
 extern struct req_format RQF_OST_DISCONNECT;
-extern struct req_format RQF_OST_QUOTACHECK;
 extern struct req_format RQF_OST_QUOTACTL;
 extern struct req_format RQF_OST_GETATTR;
 extern struct req_format RQF_OST_SETATTR;
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 8372deb..2811901 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -345,13 +345,6 @@ struct client_obd {
 	/* also protected by the poorly named _loi_list_lock lock above */
 	struct osc_async_rc      cl_ar;
 
-	/* used by quotacheck when the servers are older than 2.4 */
-	int		      cl_qchk_stat; /* quotacheck stat of the peer */
-#define CL_NOT_QUOTACHECKED 1   /* client->cl_qchk_stat init value */
-#if OBD_OCD_VERSION(2, 7, 53, 0) < LUSTRE_VERSION_CODE
-#warning "please consider removing quotacheck compatibility code"
-#endif
-
 	/* sequence manager */
 	struct lu_client_seq    *cl_seq;
 
@@ -930,8 +923,6 @@ struct obd_ops {
 	struct obd_uuid *(*get_uuid)(struct obd_export *exp);
 
 	/* quota methods */
-	int (*quotacheck)(struct obd_device *, struct obd_export *,
-			  struct obd_quotactl *);
 	int (*quotactl)(struct obd_device *, struct obd_export *,
 			struct obd_quotactl *);
 
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index cb7160e..8f1d681 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1163,18 +1163,6 @@ static inline int obd_notify_observer(struct obd_device *observer,
 	return rc1 ? rc1 : rc2;
 }
 
-static inline int obd_quotacheck(struct obd_export *exp,
-				 struct obd_quotactl *oqctl)
-{
-	int rc;
-
-	EXP_CHECK_DT_OP(exp, quotacheck);
-	EXP_COUNTER_INCREMENT(exp, quotacheck);
-
-	rc = OBP(exp->exp_obd, quotacheck)(exp->exp_obd, exp, oqctl);
-	return rc;
-}
-
 static inline int obd_quotactl(struct obd_export *exp,
 			       struct obd_quotactl *oqctl)
 {
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 9d2d6f8..1233c34 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -179,7 +179,7 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_MDS_STATFS_LCW_SLEEP    0x12a
 #define OBD_FAIL_MDS_OPEN_CREATE	 0x12b
 #define OBD_FAIL_MDS_OST_SETATTR	 0x12c
-#define OBD_FAIL_MDS_QUOTACHECK_NET      0x12d
+/*	OBD_FAIL_MDS_QUOTACHECK_NET      0x12d obsolete since 2.4 */
 #define OBD_FAIL_MDS_QUOTACTL_NET	0x12e
 #define OBD_FAIL_MDS_CLIENT_ADD	  0x12f
 #define OBD_FAIL_MDS_GETXATTR_NET	0x130
@@ -264,7 +264,7 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_OST_ENOSPC	      0x215
 #define OBD_FAIL_OST_EROFS	       0x216
 #define OBD_FAIL_OST_ENOENT	      0x217
-#define OBD_FAIL_OST_QUOTACHECK_NET      0x218
+/*	OBD_FAIL_OST_QUOTACHECK_NET      0x218 obsolete since 2.4 */
 #define OBD_FAIL_OST_QUOTACTL_NET	0x219
 #define OBD_FAIL_OST_CHECKSUM_RECEIVE    0x21a
 #define OBD_FAIL_OST_CHECKSUM_SEND       0x21b
@@ -373,7 +373,7 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_OBD_PING_NET	    0x600
 #define OBD_FAIL_OBD_LOG_CANCEL_NET      0x601
 #define OBD_FAIL_OBD_LOGD_NET	    0x602
-#define OBD_FAIL_OBD_QC_CALLBACK_NET     0x603
+/*	OBD_FAIL_OBD_QC_CALLBACK_NET     0x603 obsolete since 2.4 */
 #define OBD_FAIL_OBD_DQACQ	       0x604
 #define OBD_FAIL_OBD_LLOG_SETUP	  0x605
 #define OBD_FAIL_OBD_LOG_CANCEL_REP      0x606
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 153e990..f3128b6 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -425,8 +425,6 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 		goto err_import;
 	}
 
-	cli->cl_qchk_stat = CL_NOT_QUOTACHECKED;
-
 	return rc;
 
 err_import:
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index c32b414..12647af 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -511,23 +511,6 @@ static inline void ldlm_callback_errmsg(struct ptlrpc_request *req,
 		CWARN("Send reply failed, maybe cause bug 21636.\n");
 }
 
-static int ldlm_handle_qc_callback(struct ptlrpc_request *req)
-{
-	struct obd_quotactl *oqctl;
-	struct client_obd *cli = &req->rq_export->exp_obd->u.cli;
-
-	oqctl = req_capsule_client_get(&req->rq_pill, &RMF_OBD_QUOTACTL);
-	if (!oqctl) {
-		CERROR("Can't unpack obd_quotactl\n");
-		return -EPROTO;
-	}
-
-	oqctl->qc_stat = ptlrpc_status_ntoh(oqctl->qc_stat);
-
-	cli->cl_qchk_stat = oqctl->qc_stat;
-	return 0;
-}
-
 /* TODO: handle requests in a similar way as MDT: see mdt_handle_common() */
 static int ldlm_callback_handler(struct ptlrpc_request *req)
 {
@@ -577,13 +560,6 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 		rc = ldlm_handle_setinfo(req);
 		ldlm_callback_reply(req, rc);
 		return 0;
-	case OBD_QC_CALLBACK:
-		req_capsule_set(&req->rq_pill, &RQF_QC_CALLBACK);
-		if (OBD_FAIL_CHECK(OBD_FAIL_OBD_QC_CALLBACK_NET))
-			return 0;
-		rc = ldlm_handle_qc_callback(req);
-		ldlm_callback_reply(req, rc);
-		return 0;
 	default:
 		CERROR("unknown opcode %u\n",
 		       lustre_msg_get_opc(req->rq_reqmsg));
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 360d97f..929c32c 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -861,10 +861,6 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 	int rc = 0;
 
 	switch (cmd) {
-	case LUSTRE_Q_INVALIDATE:
-	case LUSTRE_Q_FINVALIDATE:
-	case Q_QUOTAON:
-	case Q_QUOTAOFF:
 	case Q_SETQUOTA:
 	case Q_SETINFO:
 		if (!capable(CFS_CAP_SYS_ADMIN))
@@ -929,10 +925,6 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 		QCTL_COPY(oqctl, qctl);
 		rc = obd_quotactl(sbi->ll_md_exp, oqctl);
 		if (rc) {
-			if (rc != -EALREADY && cmd == Q_QUOTAON) {
-				oqctl->qc_cmd = Q_QUOTAOFF;
-				obd_quotactl(sbi->ll_md_exp, oqctl);
-			}
 			kfree(oqctl);
 			return rc;
 		}
@@ -1369,63 +1361,6 @@ out_req:
 			ll_putname(filename);
 		return rc;
 	}
-	case OBD_IOC_QUOTACHECK: {
-		struct obd_quotactl *oqctl;
-		int error = 0;
-
-		if (!capable(CFS_CAP_SYS_ADMIN))
-			return -EPERM;
-
-		oqctl = kzalloc(sizeof(*oqctl), GFP_NOFS);
-		if (!oqctl)
-			return -ENOMEM;
-		oqctl->qc_type = arg;
-		rc = obd_quotacheck(sbi->ll_md_exp, oqctl);
-		if (rc < 0) {
-			CDEBUG(D_INFO, "md_quotacheck failed: rc %d\n", rc);
-			error = rc;
-		}
-
-		rc = obd_quotacheck(sbi->ll_dt_exp, oqctl);
-		if (rc < 0)
-			CDEBUG(D_INFO, "obd_quotacheck failed: rc %d\n", rc);
-
-		kfree(oqctl);
-		return error ?: rc;
-	}
-	case OBD_IOC_POLL_QUOTACHECK: {
-		struct if_quotacheck *check;
-
-		if (!capable(CFS_CAP_SYS_ADMIN))
-			return -EPERM;
-
-		check = kzalloc(sizeof(*check), GFP_NOFS);
-		if (!check)
-			return -ENOMEM;
-
-		rc = obd_iocontrol(cmd, sbi->ll_md_exp, 0, (void *)check,
-				   NULL);
-		if (rc) {
-			CDEBUG(D_QUOTA, "mdc ioctl %d failed: %d\n", cmd, rc);
-			if (copy_to_user((void __user *)arg, check,
-					 sizeof(*check)))
-				CDEBUG(D_QUOTA, "copy_to_user failed\n");
-			goto out_poll;
-		}
-
-		rc = obd_iocontrol(cmd, sbi->ll_dt_exp, 0, (void *)check,
-				   NULL);
-		if (rc) {
-			CDEBUG(D_QUOTA, "osc ioctl %d failed: %d\n", cmd, rc);
-			if (copy_to_user((void __user *)arg, check,
-					 sizeof(*check)))
-				CDEBUG(D_QUOTA, "copy_to_user failed\n");
-			goto out_poll;
-		}
-out_poll:
-		kfree(check);
-		return rc;
-	}
 	case OBD_IOC_QUOTACTL: {
 		struct if_quotactl *qctl;
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 7bd7e15..67969a8 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1128,9 +1128,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 			mdc_obd = class_exp2obd(tgt->ltd_exp);
 			mdc_obd->obd_force = obddev->obd_force;
 			err = obd_iocontrol(cmd, tgt->ltd_exp, len, karg, uarg);
-			if (err == -ENODATA && cmd == OBD_IOC_POLL_QUOTACHECK) {
-				return err;
-			} else if (err) {
+			if (err) {
 				if (tgt->ltd_active) {
 					CERROR("error: iocontrol MDC %s on MDTidx %d cmd %x: err = %d\n",
 					       tgt->ltd_uuid.uuid, i, cmd, err);
@@ -3243,32 +3241,6 @@ static int lmv_quotactl(struct obd_device *unused, struct obd_export *exp,
 	return rc;
 }
 
-static int lmv_quotacheck(struct obd_device *unused, struct obd_export *exp,
-			  struct obd_quotactl *oqctl)
-{
-	struct obd_device   *obd = class_exp2obd(exp);
-	struct lmv_obd      *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc *tgt;
-	int rc = 0;
-	u32 i;
-
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		int err;
-
-		tgt = lmv->tgts[i];
-		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active) {
-			CERROR("lmv idx %d inactive\n", i);
-			return -EIO;
-		}
-
-		err = obd_quotacheck(tgt->ltd_exp, oqctl);
-		if (err && !rc)
-			rc = err;
-	}
-
-	return rc;
-}
-
 static int lmv_merge_attr(struct obd_export *exp,
 			  const struct lmv_stripe_md *lsm,
 			  struct cl_attr *attr,
@@ -3326,7 +3298,6 @@ static struct obd_ops lmv_obd_ops = {
 	.notify		= lmv_notify,
 	.get_uuid	= lmv_get_uuid,
 	.iocontrol	= lmv_iocontrol,
-	.quotacheck	= lmv_quotacheck,
 	.quotactl	= lmv_quotactl
 };
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 019fe95..c2a853c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1217,8 +1217,6 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 			osc_obd->obd_force = obddev->obd_force;
 			err = obd_iocontrol(cmd, lov->lov_tgts[i]->ltd_exp,
 					    len, karg, uarg);
-			if (err == -ENODATA && cmd == OBD_IOC_POLL_QUOTACHECK)
-				return err;
 			if (err) {
 				if (lov->lov_tgts[i]->ltd_active) {
 					CDEBUG(err == -ENOTTY ?
@@ -1355,12 +1353,8 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 	__u64		bhardlimit = 0;
 	int		  i, rc = 0;
 
-	if (oqctl->qc_cmd != LUSTRE_Q_QUOTAON &&
-	    oqctl->qc_cmd != LUSTRE_Q_QUOTAOFF &&
-	    oqctl->qc_cmd != Q_GETOQUOTA &&
-	    oqctl->qc_cmd != Q_INITQUOTA &&
-	    oqctl->qc_cmd != LUSTRE_Q_SETQUOTA &&
-	    oqctl->qc_cmd != Q_FINVALIDATE) {
+	if (oqctl->qc_cmd != Q_GETOQUOTA &&
+	    oqctl->qc_cmd != LUSTRE_Q_SETQUOTA) {
 		CERROR("bad quota opc %x for lov obd\n", oqctl->qc_cmd);
 		return -EFAULT;
 	}
@@ -1407,49 +1401,6 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 	return rc;
 }
 
-static int lov_quotacheck(struct obd_device *obd, struct obd_export *exp,
-			  struct obd_quotactl *oqctl)
-{
-	struct lov_obd *lov = &obd->u.lov;
-	int	     i, rc = 0;
-
-	obd_getref(obd);
-
-	for (i = 0; i < lov->desc.ld_tgt_count; i++) {
-		if (!lov->lov_tgts[i])
-			continue;
-
-		/* Skip quota check on the administratively disabled OSTs. */
-		if (!lov->lov_tgts[i]->ltd_activate) {
-			CWARN("lov idx %d was administratively disabled, skip quotacheck on it.\n",
-			      i);
-			continue;
-		}
-
-		if (!lov->lov_tgts[i]->ltd_active) {
-			CERROR("lov idx %d inactive\n", i);
-			rc = -EIO;
-			goto out;
-		}
-	}
-
-	for (i = 0; i < lov->desc.ld_tgt_count; i++) {
-		int err;
-
-		if (!lov->lov_tgts[i] || !lov->lov_tgts[i]->ltd_activate)
-			continue;
-
-		err = obd_quotacheck(lov->lov_tgts[i]->ltd_exp, oqctl);
-		if (err && !rc)
-			rc = err;
-	}
-
-out:
-	obd_putref(obd);
-
-	return rc;
-}
-
 static struct obd_ops lov_obd_ops = {
 	.owner          = THIS_MODULE,
 	.setup          = lov_setup,
@@ -1473,7 +1424,6 @@ static struct obd_ops lov_obd_ops = {
 	.getref         = lov_getref,
 	.putref         = lov_putref,
 	.quotactl       = lov_quotactl,
-	.quotacheck     = lov_quotacheck,
 };
 
 struct kmem_cache *lov_oinfo_slab;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 1d1eaa5..b62b29f 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1929,52 +1929,6 @@ static int mdc_ioc_changelog_send(struct obd_device *obd,
 static int mdc_ioc_hsm_ct_start(struct obd_export *exp,
 				struct lustre_kernelcomm *lk);
 
-static int mdc_quotacheck(struct obd_device *unused, struct obd_export *exp,
-			  struct obd_quotactl *oqctl)
-{
-	struct client_obd       *cli = &exp->exp_obd->u.cli;
-	struct ptlrpc_request   *req;
-	struct obd_quotactl     *body;
-	int		      rc;
-
-	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
-					&RQF_MDS_QUOTACHECK, LUSTRE_MDS_VERSION,
-					MDS_QUOTACHECK);
-	if (!req)
-		return -ENOMEM;
-
-	body = req_capsule_client_get(&req->rq_pill, &RMF_OBD_QUOTACTL);
-	*body = *oqctl;
-
-	ptlrpc_request_set_replen(req);
-
-	/* the next poll will find -ENODATA, that means quotacheck is
-	 * going on
-	 */
-	cli->cl_qchk_stat = -ENODATA;
-	rc = ptlrpc_queue_wait(req);
-	if (rc)
-		cli->cl_qchk_stat = rc;
-	ptlrpc_req_finished(req);
-	return rc;
-}
-
-static int mdc_quota_poll_check(struct obd_export *exp,
-				struct if_quotacheck *qchk)
-{
-	struct client_obd *cli = &exp->exp_obd->u.cli;
-	int rc;
-
-	qchk->obd_uuid = cli->cl_target_uuid;
-	memcpy(qchk->obd_type, LUSTRE_MDS_NAME, strlen(LUSTRE_MDS_NAME));
-
-	rc = cli->cl_qchk_stat;
-	/* the client is not the previous one */
-	if (rc == CL_NOT_QUOTACHECKED)
-		rc = -EINTR;
-	return rc;
-}
-
 static int mdc_quotactl(struct obd_device *unused, struct obd_export *exp,
 			struct obd_quotactl *oqctl)
 {
@@ -2129,9 +2083,6 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	case IOC_OSC_SET_ACTIVE:
 		rc = ptlrpc_set_import_active(imp, data->ioc_offset);
 		goto out;
-	case OBD_IOC_POLL_QUOTACHECK:
-		rc = mdc_quota_poll_check(exp, (struct if_quotacheck *)karg);
-		goto out;
 	case OBD_IOC_PING_TARGET:
 		rc = ptlrpc_obd_ping(obd);
 		goto out;
@@ -2794,7 +2745,6 @@ static struct obd_ops mdc_obd_ops = {
 	.process_config = mdc_process_config,
 	.get_uuid       = mdc_get_uuid,
 	.quotactl       = mdc_quotactl,
-	.quotacheck     = mdc_quotacheck
 };
 
 static struct md_ops mdc_md_ops = {
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 64684c4..61bfacb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -190,9 +190,6 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 int osc_quota_chkdq(struct client_obd *cli, const unsigned int qid[]);
 int osc_quotactl(struct obd_device *unused, struct obd_export *exp,
 		 struct obd_quotactl *oqctl);
-int osc_quotacheck(struct obd_device *unused, struct obd_export *exp,
-		   struct obd_quotactl *oqctl);
-int osc_quota_poll_check(struct obd_export *exp, struct if_quotacheck *qchk);
 void osc_inc_unstable_pages(struct ptlrpc_request *req);
 void osc_dec_unstable_pages(struct ptlrpc_request *req);
 bool osc_over_unstable_soft_limit(struct client_obd *cli);
diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
index 194d8ed..acdd91a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_quota.c
+++ b/drivers/staging/lustre/lustre/osc/osc_quota.c
@@ -281,47 +281,3 @@ int osc_quotactl(struct obd_device *unused, struct obd_export *exp,
 
 	return rc;
 }
-
-int osc_quotacheck(struct obd_device *unused, struct obd_export *exp,
-		   struct obd_quotactl *oqctl)
-{
-	struct client_obd *cli = &exp->exp_obd->u.cli;
-	struct ptlrpc_request *req;
-	struct obd_quotactl *body;
-	int rc;
-
-	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
-					&RQF_OST_QUOTACHECK, LUSTRE_OST_VERSION,
-					OST_QUOTACHECK);
-	if (!req)
-		return -ENOMEM;
-
-	body = req_capsule_client_get(&req->rq_pill, &RMF_OBD_QUOTACTL);
-	*body = *oqctl;
-
-	ptlrpc_request_set_replen(req);
-
-	/* the next poll will find -ENODATA, that means quotacheck is going on
-	 */
-	cli->cl_qchk_stat = -ENODATA;
-	rc = ptlrpc_queue_wait(req);
-	if (rc)
-		cli->cl_qchk_stat = rc;
-	ptlrpc_req_finished(req);
-	return rc;
-}
-
-int osc_quota_poll_check(struct obd_export *exp, struct if_quotacheck *qchk)
-{
-	struct client_obd *cli = &exp->exp_obd->u.cli;
-	int rc;
-
-	qchk->obd_uuid = cli->cl_target_uuid;
-	memcpy(qchk->obd_type, LUSTRE_OST_NAME, strlen(LUSTRE_OST_NAME));
-
-	rc = cli->cl_qchk_stat;
-	/* the client is not the previous one */
-	if (rc == CL_NOT_QUOTACHECKED)
-		rc = -EINTR;
-	return rc;
-}
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 2e4d2d5..ab7f82d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2443,9 +2443,6 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		err = ptlrpc_set_import_active(obd->u.cli.cl_import,
 					       data->ioc_offset);
 		goto out;
-	case OBD_IOC_POLL_QUOTACHECK:
-		err = osc_quota_poll_check(exp, karg);
-		goto out;
 	case OBD_IOC_PING_TARGET:
 		err = ptlrpc_obd_ping(obd);
 		goto out;
@@ -2934,7 +2931,6 @@ static struct obd_ops osc_obd_ops = {
 	.import_event   = osc_import_event,
 	.process_config = osc_process_config,
 	.quotactl       = osc_quotactl,
-	.quotacheck     = osc_quotacheck,
 };
 
 extern struct lu_kmem_descr osc_caches[];
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 358c124..f0e0448 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -680,7 +680,6 @@ static struct req_format *req_formats[] = {
 	&RQF_MDS_REINT_RENAME,
 	&RQF_MDS_REINT_SETATTR,
 	&RQF_MDS_REINT_SETXATTR,
-	&RQF_MDS_QUOTACHECK,
 	&RQF_MDS_QUOTACTL,
 	&RQF_MDS_HSM_PROGRESS,
 	&RQF_MDS_HSM_CT_REGISTER,
@@ -690,10 +689,8 @@ static struct req_format *req_formats[] = {
 	&RQF_MDS_HSM_ACTION,
 	&RQF_MDS_HSM_REQUEST,
 	&RQF_MDS_SWAP_LAYOUTS,
-	&RQF_QC_CALLBACK,
 	&RQF_OST_CONNECT,
 	&RQF_OST_DISCONNECT,
-	&RQF_OST_QUOTACHECK,
 	&RQF_OST_QUOTACTL,
 	&RQF_OST_GETATTR,
 	&RQF_OST_SETATTR,
@@ -1179,14 +1176,6 @@ struct req_format RQF_LOG_CANCEL =
 	DEFINE_REQ_FMT0("OBD_LOG_CANCEL", log_cancel_client, empty);
 EXPORT_SYMBOL(RQF_LOG_CANCEL);
 
-struct req_format RQF_MDS_QUOTACHECK =
-	DEFINE_REQ_FMT0("MDS_QUOTACHECK", quotactl_only, empty);
-EXPORT_SYMBOL(RQF_MDS_QUOTACHECK);
-
-struct req_format RQF_OST_QUOTACHECK =
-	DEFINE_REQ_FMT0("OST_QUOTACHECK", quotactl_only, empty);
-EXPORT_SYMBOL(RQF_OST_QUOTACHECK);
-
 struct req_format RQF_MDS_QUOTACTL =
 	DEFINE_REQ_FMT0("MDS_QUOTACTL", quotactl_only, quotactl_only);
 EXPORT_SYMBOL(RQF_MDS_QUOTACTL);
@@ -1195,10 +1184,6 @@ struct req_format RQF_OST_QUOTACTL =
 	DEFINE_REQ_FMT0("OST_QUOTACTL", quotactl_only, quotactl_only);
 EXPORT_SYMBOL(RQF_OST_QUOTACTL);
 
-struct req_format RQF_QC_CALLBACK =
-	DEFINE_REQ_FMT0("QC_CALLBACK", quotactl_only, empty);
-EXPORT_SYMBOL(RQF_QC_CALLBACK);
-
 struct req_format RQF_MDS_GETSTATUS =
 	DEFINE_REQ_FMT0("MDS_GETSTATUS", mdt_body_only, mdt_body_capa);
 EXPORT_SYMBOL(RQF_MDS_GETSTATUS);
-- 
1.7.1
