From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 14:17:08 -0500
Subject: [lustre-devel] [PATCH 03/13] staging: lustre: Prevent duplicate CT
	registrations
In-Reply-To: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
References: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447010238-25775-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Henri Doreau <henri.doreau@cea.fr>

Associate copytool registration to a given MDC import so that
multiple mounts of the same filesystem do not lead to having the
copytool registered multiple time.

Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3882
Reviewed-on: http://review.whamcloud.com/7612
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../include/linux/libcfs/libcfs_kernelcomm.h       |    6 ++--
 .../staging/lustre/lustre/include/lustre_export.h  |    7 ++++
 .../lustre/lustre/libcfs/kernel_user_comm.c        |   15 +++++---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   39 +++++++++++++++-----
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   22 +++++++----
 5 files changed, 62 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_kernelcomm.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_kernelcomm.h
index 41f3d81..3a89a3b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_kernelcomm.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_kernelcomm.h
@@ -77,7 +77,7 @@ enum kuc_generic_message_type {
 };
 
 /* prototype for callback function on kuc groups */
-typedef int (*libcfs_kkuc_cb_t)(__u32 data, void *cb_arg);
+typedef int (*libcfs_kkuc_cb_t)(void *data, void *cb_arg);
 
 /* KUC Broadcast Groups. This determines which userspace process hears which
  * messages.  Mutliple transports may be used within a group, or multiple
@@ -92,8 +92,8 @@ typedef int (*libcfs_kkuc_cb_t)(__u32 data, void *cb_arg);
 int libcfs_kkuc_msg_put(struct file *fp, void *payload);
 int libcfs_kkuc_group_put(int group, void *payload);
 int libcfs_kkuc_group_add(struct file *fp, int uid, unsigned int group,
-				 __u32 data);
-int libcfs_kkuc_group_rem(int uid, int group);
+			  void *data);
+int libcfs_kkuc_group_rem(int uid, int group, void **pdata);
 int libcfs_kkuc_group_foreach(int group, libcfs_kkuc_cb_t cb_func,
 				     void *cb_arg);
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index 1daf4c5..e0a5171 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -338,6 +338,13 @@ static inline bool imp_connect_disp_stripe(struct obd_import *imp)
 
 struct obd_export *class_conn2export(struct lustre_handle *conn);
 
+#define KKUC_CT_DATA_MAGIC	0x092013cea
+struct kkuc_ct_data {
+	__u32		kcd_magic;
+	struct obd_uuid	kcd_uuid;
+	__u32		kcd_archive;
+};
+
 /** @} export */
 
 #endif /* __EXPORT_H */
diff --git a/drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c b/drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c
index 1a052ac..3b4731a 100644
--- a/drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c
+++ b/drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c
@@ -95,10 +95,10 @@ EXPORT_SYMBOL(libcfs_kkuc_msg_put);
  * group from any fs */
 /** A single group registration has a uid and a file pointer */
 struct kkuc_reg {
-	struct list_head	kr_chain;
-	int		kr_uid;
+	struct list_head kr_chain;
+	int		 kr_uid;
 	struct file	*kr_fp;
-	__u32		kr_data;
+	void		*kr_data;
 };
 
 static struct list_head kkuc_groups[KUC_GRP_MAX+1] = {};
@@ -109,9 +109,10 @@ static DECLARE_RWSEM(kg_sem);
  * @param filp pipe to write into
  * @param uid identifier for this receiver
  * @param group group number
+ * @param data user data
  */
 int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
-			  __u32 data)
+			  void *data)
 {
 	struct kkuc_reg *reg;
 
@@ -145,7 +146,7 @@ int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
 }
 EXPORT_SYMBOL(libcfs_kkuc_group_add);
 
-int libcfs_kkuc_group_rem(int uid, int group)
+int libcfs_kkuc_group_rem(int uid, int group, void **pdata)
 {
 	struct kkuc_reg *reg, *next;
 
@@ -171,6 +172,8 @@ int libcfs_kkuc_group_rem(int uid, int group)
 			       reg->kr_uid, reg->kr_fp, group);
 			if (reg->kr_fp != NULL)
 				fput(reg->kr_fp);
+			if (pdata)
+				*pdata = reg->kr_data;
 			kfree(reg);
 		}
 	}
@@ -213,7 +216,7 @@ EXPORT_SYMBOL(libcfs_kkuc_group_put);
  * Calls a callback function for each link of the given kuc group.
  * @param group the group to call the function on.
  * @param cb_func the function to be called.
- * @param cb_arg iextra argument to be passed to the callback function.
+ * @param cb_arg extra argument to be passed to the callback function.
  */
 int libcfs_kkuc_group_foreach(int group, libcfs_kkuc_cb_t cb_func,
 			      void *cb_arg)
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index a4de9a3..8b2ae38 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -794,7 +794,9 @@ static void lmv_hsm_req_build(struct lmv_obd *lmv,
 static int lmv_hsm_ct_unregister(struct lmv_obd *lmv, unsigned int cmd, int len,
 				 struct lustre_kernelcomm *lk, void *uarg)
 {
-	int	i, rc = 0;
+	struct kkuc_ct_data *kcd = NULL;
+	int rc = 0;
+	__u32 i;
 
 	/* unregister request (call from llapi_hsm_copytool_fini) */
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
@@ -807,17 +809,21 @@ static int lmv_hsm_ct_unregister(struct lmv_obd *lmv, unsigned int cmd, int len,
 	 * Unreached coordinators will get EPIPE on next requests
 	 * and will unregister automatically.
 	 */
-	rc = libcfs_kkuc_group_rem(lk->lk_uid, lk->lk_group);
+	rc = libcfs_kkuc_group_rem(lk->lk_uid, lk->lk_group, (void **)&kcd);
+	if (kcd)
+		kfree(kcd);
+
 	return rc;
 }
 
 static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 			       struct lustre_kernelcomm *lk, void *uarg)
 {
-	struct file	*filp;
-	int		 i, j, err;
-	int		 rc = 0;
-	bool		 any_set = false;
+	struct file *filp;
+	__u32 i, j;
+	int err, rc = 0;
+	bool any_set = false;
+	struct kkuc_ct_data *kcd;
 
 	/* All or nothing: try to register to all MDS.
 	 * In case of failure, unregister from previous MDS,
@@ -854,12 +860,25 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 
 	/* at least one registration done, with no failure */
 	filp = fget(lk->lk_wfd);
-	if (filp == NULL) {
+	if (!filp)
 		return -EBADF;
-	}
-	rc = libcfs_kkuc_group_add(filp, lk->lk_uid, lk->lk_group, lk->lk_data);
-	if (rc != 0 && filp != NULL)
+
+	kcd = kzalloc(sizeof(*kcd), GFP_NOFS);
+	if (!kcd) {
 		fput(filp);
+		return -ENOMEM;
+	}
+	kcd->kcd_magic = KKUC_CT_DATA_MAGIC;
+	kcd->kcd_uuid = lmv->cluuid;
+	kcd->kcd_archive = lk->lk_data;
+
+	rc = libcfs_kkuc_group_add(filp, lk->lk_uid, lk->lk_group, kcd);
+	if (rc) {
+		if (filp)
+			fput(filp);
+		kfree(kcd);
+	}
+
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 294c050..b3a237e 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2020,21 +2020,27 @@ static int mdc_hsm_copytool_send(int len, void *val)
 /**
  * callback function passed to kuc for re-registering each HSM copytool
  * running on MDC, after MDT shutdown/recovery.
- * @param data archive id served by the copytool
+ * @param data copytool registration data
  * @param cb_arg callback argument (obd_import)
  */
-static int mdc_hsm_ct_reregister(__u32 data, void *cb_arg)
+static int mdc_hsm_ct_reregister(void *data, void *cb_arg)
 {
+	struct kkuc_ct_data	*kcd = data;
 	struct obd_import	*imp = (struct obd_import *)cb_arg;
-	__u32			 archive = data;
 	int			 rc;
 
-	CDEBUG(D_HA, "recover copytool registration to MDT (archive=%#x)\n",
-	       archive);
-	rc = mdc_ioc_hsm_ct_register(imp, archive);
+	if (!kcd || kcd->kcd_magic != KKUC_CT_DATA_MAGIC)
+		return -EPROTO;
+
+	if (!obd_uuid_equals(&kcd->kcd_uuid, &imp->imp_obd->obd_uuid))
+		return 0;
+
+	CDEBUG(D_HA, "%s: recover copytool registration to MDT (archive=%#x)\n",
+	       imp->imp_obd->obd_name, kcd->kcd_archive);
+	rc = mdc_ioc_hsm_ct_register(imp, kcd->kcd_archive);
 
 	/* ignore error if the copytool is already registered */
-	return ((rc != 0) && (rc != -EEXIST)) ? rc : 0;
+	return (rc == -EEXIST) ? 0 : rc;
 }
 
 /**
@@ -2384,7 +2390,7 @@ static int mdc_precleanup(struct obd_device *obd, enum obd_cleanup_stage stage)
 	case OBD_CLEANUP_EXPORTS:
 		/* Failsafe, ok if racy */
 		if (obd->obd_type->typ_refcnt <= 1)
-			libcfs_kkuc_group_rem(0, KUC_GRP_HSM);
+			libcfs_kkuc_group_rem(0, KUC_GRP_HSM, NULL);
 
 		obd_cleanup_client_import(obd);
 		ptlrpc_lprocfs_unregister_obd(obd);
-- 
1.7.1
