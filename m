From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:52 -0400
Subject: [lustre-devel] [PATCH 093/151] lustre: hsm: filter kkuc write by
 client UUID
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-94-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

Add a struct obd_uuid kr_uuid member to struct kkuc_reg to hold the
UUID of the client (super block) that owns the kkuc pipe. Modify
libcfs_kkuc_group_{put,rem,foreach}() to accept a UUID pointer which
filters the kkuc pipes operated on. Modify mdc_hsm_copytool_send() to
pass the UUID of the MDC device when calling
libcfs_kkuc_group_put(). The effect of all this is that HALs received
by a given MDC will only be delivered to copytools registered on the
corresponding mount point.

Remove the cluuid member of struct lmv_obd since it is always the same
as the obd_uuid member of the corresponding struct obd_device. Remove
the kcd_uuid member of struct kkuc_ct_data as it is no longer needed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10341
Lustre-commit: c73736545faf ("LU-10341 hsm: filter kkuc write by client UUID")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30419
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_export.h     |  1 -
 fs/lustre/include/lustre_kernelcomm.h | 12 +++++------
 fs/lustre/include/obd.h               |  1 -
 fs/lustre/lmv/lmv_obd.c               | 38 +++++++++++++++++------------------
 fs/lustre/mdc/mdc_request.c           | 22 +++++++++-----------
 fs/lustre/obdclass/kernelcomm.c       | 26 ++++++++++++++----------
 6 files changed, 50 insertions(+), 50 deletions(-)

diff --git a/fs/lustre/include/lustre_export.h b/fs/lustre/include/lustre_export.h
index 4ac996b..9e2878e 100644
--- a/fs/lustre/include/lustre_export.h
+++ b/fs/lustre/include/lustre_export.h
@@ -267,7 +267,6 @@ static inline int exp_connect_lockahead(struct obd_export *exp)
 #define KKUC_CT_DATA_MAGIC	0x092013cea
 struct kkuc_ct_data {
 	u32			kcd_magic;
-	struct obd_uuid		kcd_uuid;
 	u32			kcd_archive;
 };
 
diff --git a/fs/lustre/include/lustre_kernelcomm.h b/fs/lustre/include/lustre_kernelcomm.h
index 1ed4184..2c8ce19 100644
--- a/fs/lustre/include/lustre_kernelcomm.h
+++ b/fs/lustre/include/lustre_kernelcomm.h
@@ -46,11 +46,11 @@
 
 /* Kernel methods */
 void libcfs_kkuc_init(void);
-int libcfs_kkuc_group_put(unsigned int group, void *payload);
-int libcfs_kkuc_group_add(struct file *fp, int uid, unsigned int group,
-			  void *data, size_t data_len);
-int libcfs_kkuc_group_rem(int uid, unsigned int group);
-int libcfs_kkuc_group_foreach(unsigned int group, libcfs_kkuc_cb_t cb_func,
-			      void *cb_arg);
+int libcfs_kkuc_group_put(const struct obd_uuid *uuid, int group, void *data);
+int libcfs_kkuc_group_add(struct file *fp, const struct obd_uuid *uuid, int uid,
+			  int group, void *data, size_t data_len);
+int libcfs_kkuc_group_rem(const struct obd_uuid *uuid, int uid, int group);
+int libcfs_kkuc_group_foreach(const struct obd_uuid *uuid, int group,
+			      libcfs_kkuc_cb_t cb_func, void *cb_arg);
 
 #endif /* __LUSTRE_KERNELCOMM_H__ */
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index e377526..f252ff0 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -430,7 +430,6 @@ struct lmv_obd {
 	struct lu_client_fld	lmv_fld;
 	spinlock_t		lmv_lock;
 	struct lmv_desc		desc;
-	struct obd_uuid		cluuid;
 
 	struct mutex		lmv_init_mutex;
 	int			connected;
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 47fc22c..b6459f5 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -206,7 +206,6 @@ static int lmv_connect(const struct lu_env *env,
 	exp = class_conn2export(&conn);
 
 	lmv->connected = 0;
-	lmv->cluuid = *cluuid;
 	lmv->conn_data = *data;
 
 	lmv->lmv_tgts_kobj = kobject_create_and_add("target_obds",
@@ -276,8 +275,6 @@ static int lmv_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize)
 static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 {
 	struct lmv_obd *lmv = &obd->u.lmv;
-	struct obd_uuid *cluuid = &lmv->cluuid;
-	struct obd_uuid lmv_mdc_uuid = { "LMV_MDC_UUID" };
 	struct obd_device *mdc_obd;
 	struct obd_export *mdc_exp;
 	struct lu_fld_target target;
@@ -290,16 +287,16 @@ static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 		return -EINVAL;
 	}
 
-	CDEBUG(D_CONFIG, "connect to %s(%s) - %s, %s FOR %s\n",
+	CDEBUG(D_CONFIG, "connect to %s(%s) - %s, %s\n",
 	       mdc_obd->obd_name, mdc_obd->obd_uuid.uuid,
-	       tgt->ltd_uuid.uuid, obd->obd_uuid.uuid, cluuid->uuid);
+	       tgt->ltd_uuid.uuid, obd->obd_uuid.uuid);
 
 	if (!mdc_obd->obd_set_up) {
 		CERROR("target %s is not set up\n", tgt->ltd_uuid.uuid);
 		return -EINVAL;
 	}
 
-	rc = obd_connect(NULL, &mdc_exp, mdc_obd, &lmv_mdc_uuid,
+	rc = obd_connect(NULL, &mdc_exp, mdc_obd, &obd->obd_uuid,
 			 &lmv->conn_data, NULL);
 	if (rc) {
 		CERROR("target %s connect error %d\n", tgt->ltd_uuid.uuid, rc);
@@ -499,7 +496,7 @@ static int lmv_check_connect(struct obd_device *obd)
 	}
 
 	CDEBUG(D_CONFIG, "Time to connect %s to %s\n",
-	       lmv->cluuid.uuid, obd->obd_name);
+	       obd->obd_uuid.uuid, obd->obd_name);
 
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
 		tgt = lmv->tgts[i];
@@ -753,10 +750,11 @@ static int lmv_hsm_req_build(struct lmv_obd *lmv,
 	return 0;
 }
 
-static int lmv_hsm_ct_unregister(struct lmv_obd *lmv, unsigned int cmd, int len,
-				 struct lustre_kernelcomm *lk,
+static int lmv_hsm_ct_unregister(struct obd_device *obd, unsigned int cmd,
+				 int len, struct lustre_kernelcomm *lk,
 				 void __user *uarg)
 {
+	struct lmv_obd *lmv = &obd->u.lmv;
 	u32 i;
 
 	/* unregister request (call from llapi_hsm_copytool_fini) */
@@ -776,20 +774,21 @@ static int lmv_hsm_ct_unregister(struct lmv_obd *lmv, unsigned int cmd, int len,
 	 * Unreached coordinators will get EPIPE on next requests
 	 * and will unregister automatically.
 	 */
-	return libcfs_kkuc_group_rem(lk->lk_uid, lk->lk_group);
+	return libcfs_kkuc_group_rem(&obd->obd_uuid, lk->lk_uid, lk->lk_group);
 }
 
-static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
-			       struct lustre_kernelcomm *lk, void __user *uarg)
+static int lmv_hsm_ct_register(struct obd_device *obd, unsigned int cmd,
+			       int len, struct lustre_kernelcomm *lk,
+			       void __user *uarg)
 {
+	struct lmv_obd *lmv = &obd->u.lmv;
 	struct file *filp;
 	u32 i, j;
 	int err;
 	bool any_set = false;
 	struct kkuc_ct_data kcd = {
 		.kcd_magic	= KKUC_CT_DATA_MAGIC,
-		.kcd_uuid	= lmv->cluuid,
-		.kcd_archive	= lk->lk_data
+		.kcd_archive	= lk->lk_data,
 	};
 	int rc = 0;
 
@@ -797,8 +796,8 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 	if (!filp)
 		return -EBADF;
 
-	rc = libcfs_kkuc_group_add(filp, lk->lk_uid, lk->lk_group,
-				   &kcd, sizeof(kcd));
+	rc = libcfs_kkuc_group_add(filp, &obd->obd_uuid, lk->lk_uid,
+				   lk->lk_group, &kcd, sizeof(kcd));
 	if (rc)
 		goto err_fput;
 
@@ -848,7 +847,7 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 	return 0;
 
 err_kkuc_rem:
-	libcfs_kkuc_group_rem(lk->lk_uid, lk->lk_group);
+	libcfs_kkuc_group_rem(&obd->obd_uuid, lk->lk_uid, lk->lk_group);
 err_fput:
 	fput(filp);
 	return rc;
@@ -1084,9 +1083,9 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		struct lustre_kernelcomm *lk = karg;
 
 		if (lk->lk_flags & LK_FLG_STOP)
-			rc = lmv_hsm_ct_unregister(lmv, cmd, len, lk, uarg);
+			rc = lmv_hsm_ct_unregister(obddev, cmd, len, lk, uarg);
 		else
-			rc = lmv_hsm_ct_register(lmv, cmd, len, lk, uarg);
+			rc = lmv_hsm_ct_register(obddev, cmd, len, lk, uarg);
 		break;
 	}
 	default:
@@ -2562,6 +2561,7 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 
 static int lmv_precleanup(struct obd_device *obd)
 {
+	libcfs_kkuc_group_rem(&obd->obd_uuid, 0, KUC_GRP_HSM);
 	fld_client_debugfs_fini(&obd->u.lmv.lmv_fld);
 	lprocfs_obd_cleanup(obd);
 	ldebugfs_free_md_stats(obd);
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index efa6516..29a4886 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2173,10 +2173,12 @@ static int mdc_ioc_hsm_ct_start(struct obd_export *exp,
 /**
  * Send a message to any listening copytools
  *
+ * @uuid:	obd device UUID
  * @val:	KUC message (kuc_hdr + hsm_action_list)
  * @len:	total length of message
  */
-static int mdc_hsm_copytool_send(size_t len, void *val)
+static int mdc_hsm_copytool_send(const struct obd_uuid *uuid,
+				 size_t len, void *val)
 {
 	struct kuc_hdr *lh = (struct kuc_hdr *)val;
 	struct hsm_action_list *hal = (struct hsm_action_list *)(lh + 1);
@@ -2200,7 +2202,7 @@ static int mdc_hsm_copytool_send(size_t len, void *val)
 	       lh->kuc_msglen, hal->hal_count, hal->hal_fsname);
 
 	/* Broadcast to HSM listeners */
-	return libcfs_kkuc_group_put(KUC_GRP_HSM, lh);
+	return libcfs_kkuc_group_put(uuid, KUC_GRP_HSM, lh);
 }
 
 /**
@@ -2219,9 +2221,6 @@ static int mdc_hsm_ct_reregister(void *data, void *cb_arg)
 	if (!kcd || kcd->kcd_magic != KKUC_CT_DATA_MAGIC)
 		return -EPROTO;
 
-	if (!obd_uuid_equals(&kcd->kcd_uuid, &imp->imp_obd->obd_uuid))
-		return 0;
-
 	CDEBUG(D_HA, "%s: recover copytool registration to MDT (archive=%#x)\n",
 	       imp->imp_obd->obd_name, kcd->kcd_archive);
 	rc = mdc_ioc_hsm_ct_register(imp, kcd->kcd_archive);
@@ -2264,7 +2263,8 @@ static int mdc_set_info_async(const struct lu_env *env,
 		return rc;
 	}
 	if (KEY_IS(KEY_HSM_COPYTOOL_SEND)) {
-		rc = mdc_hsm_copytool_send(vallen, val);
+		rc = mdc_hsm_copytool_send(&imp->imp_obd->obd_uuid, vallen,
+					   val);
 		return rc;
 	}
 	if (KEY_IS(KEY_DEFAULT_EASIZE)) {
@@ -2403,11 +2403,13 @@ static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 	case IMP_EVENT_ACTIVE:
 		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_ACTIVE);
 		/* redo the kuc registration after reconnecting */
-		if (rc == 0)
+		if (rc == 0) {
 			/* re-register HSM agents */
-			rc = libcfs_kkuc_group_foreach(KUC_GRP_HSM,
+			rc = libcfs_kkuc_group_foreach(&imp->imp_obd->obd_uuid,
+						       KUC_GRP_HSM,
 						       mdc_hsm_ct_reregister,
 						       (void *)imp);
+		}
 		break;
 	case IMP_EVENT_OCD: {
 		struct obd_connect_data *ocd = &imp->imp_connect_data;
@@ -2576,10 +2578,6 @@ static int mdc_precleanup(struct obd_device *obd)
 {
 	osc_precleanup_common(obd);
 
-	/* Failsafe, ok if racy */
-	if (atomic_read(&obd->obd_type->typ_refcnt) <= 1)
-		libcfs_kkuc_group_rem(0, KUC_GRP_HSM);
-
 	mdc_changelog_cdev_finish(obd);
 
 	obd_cleanup_client_import(obd);
diff --git a/fs/lustre/obdclass/kernelcomm.c b/fs/lustre/obdclass/kernelcomm.c
index ee998ba..e92a52c 100644
--- a/fs/lustre/obdclass/kernelcomm.c
+++ b/fs/lustre/obdclass/kernelcomm.c
@@ -90,6 +90,7 @@ static int libcfs_kkuc_msg_put(struct file *filp, void *payload)
 /** A single group registration has a uid and a file pointer */
 struct kkuc_reg {
 	struct list_head	kr_chain;
+	struct obd_uuid		kr_uuid;
 	int			kr_uid;
 	struct file	       *kr_fp;
 	char			kr_data[0];
@@ -115,12 +116,13 @@ void libcfs_kkuc_init(void)
 /** Add a receiver to a broadcast group
  *
  * @filp:	pipe to write into
+ * @uuid:	obd device UUID
  * @uid:	identifier for this receiver
  * @group:	group number
  * @data:	user data
  */
-int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
-			  void *data, size_t data_len)
+int libcfs_kkuc_group_add(struct file *filp, const struct obd_uuid *uuid,
+			  int uid, int group, void *data, size_t data_len)
 {
 	struct kkuc_reg *reg;
 
@@ -134,10 +136,11 @@ int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
 		return -EBADF;
 
 	/* freed in group_rem */
-	reg = kmalloc(sizeof(*reg) + data_len, GFP_KERNEL);
+	reg = kzalloc(sizeof(*reg) + data_len, GFP_KERNEL);
 	if (!reg)
 		return -ENOMEM;
 
+	reg->kr_uuid = *uuid;
 	reg->kr_fp = filp;
 	reg->kr_uid = uid;
 	memcpy(reg->kr_data, data, data_len);
@@ -152,7 +155,7 @@ int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
 }
 EXPORT_SYMBOL(libcfs_kkuc_group_add);
 
-int libcfs_kkuc_group_rem(int uid, unsigned int group)
+int libcfs_kkuc_group_rem(const struct obd_uuid *uuid, int uid, int group)
 {
 	struct kkuc_reg *reg, *next;
 
@@ -169,12 +172,13 @@ int libcfs_kkuc_group_rem(int uid, unsigned int group)
 		lh.kuc_transport = KUC_TRANSPORT_GENERIC;
 		lh.kuc_msgtype = KUC_MSG_SHUTDOWN;
 		lh.kuc_msglen = sizeof(lh);
-		libcfs_kkuc_group_put(group, &lh);
+		libcfs_kkuc_group_put(uuid, group, &lh);
 	}
 
 	down_write(&kg_sem);
 	list_for_each_entry_safe(reg, next, &kkuc_groups[group], kr_chain) {
-		if (!uid || (uid == reg->kr_uid)) {
+		if (obd_uuid_equals(uuid, &reg->kr_uuid) &&
+		    (!uid || uid == reg->kr_uid)) {
 			list_del(&reg->kr_chain);
 			CDEBUG(D_HSM, "Removed uid=%d fp=%p from group %d\n",
 			       reg->kr_uid, reg->kr_fp, group);
@@ -189,7 +193,7 @@ int libcfs_kkuc_group_rem(int uid, unsigned int group)
 }
 EXPORT_SYMBOL(libcfs_kkuc_group_rem);
 
-int libcfs_kkuc_group_put(unsigned int group, void *payload)
+int libcfs_kkuc_group_put(const struct obd_uuid *uuid, int group, void *payload)
 {
 	struct kkuc_reg	*reg;
 	int rc = 0;
@@ -210,7 +214,7 @@ int libcfs_kkuc_group_put(unsigned int group, void *payload)
 	}
 
 	list_for_each_entry(reg, &kkuc_groups[group], kr_chain) {
-		if (reg->kr_fp) {
+		if (obd_uuid_equals(uuid, &reg->kr_uuid) && reg->kr_fp) {
 			rc = libcfs_kkuc_msg_put(reg->kr_fp, payload);
 			if (!rc) {
 				one_success = 1;
@@ -240,8 +244,8 @@ int libcfs_kkuc_group_put(unsigned int group, void *payload)
  * @cb_func:	the function to be called.
  * @cb_arg:	extra argument to be passed to the callback function.
  */
-int libcfs_kkuc_group_foreach(unsigned int group, libcfs_kkuc_cb_t cb_func,
-			      void *cb_arg)
+int libcfs_kkuc_group_foreach(const struct obd_uuid *uuid, int group,
+			      libcfs_kkuc_cb_t cb_func, void *cb_arg)
 {
 	struct kkuc_reg *reg;
 	int rc = 0;
@@ -253,7 +257,7 @@ int libcfs_kkuc_group_foreach(unsigned int group, libcfs_kkuc_cb_t cb_func,
 
 	down_read(&kg_sem);
 	list_for_each_entry(reg, &kkuc_groups[group], kr_chain) {
-		if (reg->kr_fp)
+		if (obd_uuid_equals(uuid, &reg->kr_uuid) && reg->kr_fp)
 			rc = cb_func(reg->kr_data, cb_arg);
 	}
 	up_read(&kg_sem);
-- 
1.8.3.1
