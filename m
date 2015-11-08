From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 14:17:11 -0500
Subject: [lustre-devel] [PATCH 06/13] staging: lustre: embed kr_data into
	kkuc_reg
In-Reply-To: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
References: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447010238-25775-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Hongchao Zhang <hongchao.zhang@intel.com>

In struct kkuc_reg, the "kr_data" is difficult to be freed
outside of libcfs, then it's better to change it to be
inline data instead of the data pointer.

Signed-off-by: Hongchao Zhang <hongchao.zhang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6485
Reviewed-on: http://review.whamcloud.com/14638
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Robert Read <robert.read@intel.com>
Reviewed-by: Henri Doreau <henri.doreau@cea.fr>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/lustre/include/lustre_kernelcomm.h      |    4 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   22 ++++++-------------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    2 +-
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |   12 ++++------
 4 files changed, 15 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
index bb305f4..235b980 100644
--- a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
@@ -47,8 +47,8 @@ typedef int (*libcfs_kkuc_cb_t)(void *data, void *cb_arg);
 int libcfs_kkuc_msg_put(struct file *fp, void *payload);
 int libcfs_kkuc_group_put(int group, void *payload);
 int libcfs_kkuc_group_add(struct file *fp, int uid, unsigned int group,
-			  void *data);
-int libcfs_kkuc_group_rem(int uid, int group, void **pdata);
+			  void *data, size_t data_len);
+int libcfs_kkuc_group_rem(int uid, int group);
 int libcfs_kkuc_group_foreach(int group, libcfs_kkuc_cb_t cb_func,
 			      void *cb_arg);
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 2ad2904..c2c8b72 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -795,7 +795,6 @@ static void lmv_hsm_req_build(struct lmv_obd *lmv,
 static int lmv_hsm_ct_unregister(struct lmv_obd *lmv, unsigned int cmd, int len,
 				 struct lustre_kernelcomm *lk, void *uarg)
 {
-	struct kkuc_ct_data *kcd = NULL;
 	int rc = 0;
 	__u32 i;
 
@@ -810,9 +809,7 @@ static int lmv_hsm_ct_unregister(struct lmv_obd *lmv, unsigned int cmd, int len,
 	 * Unreached coordinators will get EPIPE on next requests
 	 * and will unregister automatically.
 	 */
-	rc = libcfs_kkuc_group_rem(lk->lk_uid, lk->lk_group, (void **)&kcd);
-	if (kcd)
-		kfree(kcd);
+	rc = libcfs_kkuc_group_rem(lk->lk_uid, lk->lk_group);
 
 	return rc;
 }
@@ -824,7 +821,7 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 	__u32 i, j;
 	int err, rc = 0;
 	bool any_set = false;
-	struct kkuc_ct_data *kcd;
+	struct kkuc_ct_data kcd = { 0 };
 
 	/* All or nothing: try to register to all MDS.
 	 * In case of failure, unregister from previous MDS,
@@ -864,20 +861,15 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 	if (!filp)
 		return -EBADF;
 
-	kcd = kzalloc(sizeof(*kcd), GFP_NOFS);
-	if (!kcd) {
-		fput(filp);
-		return -ENOMEM;
-	}
-	kcd->kcd_magic = KKUC_CT_DATA_MAGIC;
-	kcd->kcd_uuid = lmv->cluuid;
-	kcd->kcd_archive = lk->lk_data;
+	kcd.kcd_magic = KKUC_CT_DATA_MAGIC;
+	kcd.kcd_uuid = lmv->cluuid;
+	kcd.kcd_archive = lk->lk_data;
 
-	rc = libcfs_kkuc_group_add(filp, lk->lk_uid, lk->lk_group, kcd);
+	rc = libcfs_kkuc_group_add(filp, lk->lk_uid, lk->lk_group,
+				   &kcd, sizeof(kcd));
 	if (rc) {
 		if (filp)
 			fput(filp);
-		kfree(kcd);
 	}
 
 	return rc;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index a4c543a..ee1c040 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2391,7 +2391,7 @@ static int mdc_precleanup(struct obd_device *obd, enum obd_cleanup_stage stage)
 	case OBD_CLEANUP_EXPORTS:
 		/* Failsafe, ok if racy */
 		if (obd->obd_type->typ_refcnt <= 1)
-			libcfs_kkuc_group_rem(0, KUC_GRP_HSM, NULL);
+			libcfs_kkuc_group_rem(0, KUC_GRP_HSM);
 
 		obd_cleanup_client_import(obd);
 		ptlrpc_lprocfs_unregister_obd(obd);
diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index e3f5a3c..e290246 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -97,7 +97,7 @@ struct kkuc_reg {
 	struct list_head kr_chain;
 	int		 kr_uid;
 	struct file	*kr_fp;
-	void		*kr_data;
+	char		 kr_data[0];
 };
 
 static struct list_head kkuc_groups[KUC_GRP_MAX+1] = {};
@@ -111,7 +111,7 @@ static DECLARE_RWSEM(kg_sem);
  * @param data user data
  */
 int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
-			  void *data)
+			  void *data, size_t data_len)
 {
 	struct kkuc_reg *reg;
 
@@ -125,13 +125,13 @@ int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
 		return -EBADF;
 
 	/* freed in group_rem */
-	reg = kmalloc(sizeof(*reg), 0);
+	reg = kmalloc(sizeof(*reg) + data_len, 0);
 	if (reg == NULL)
 		return -ENOMEM;
 
 	reg->kr_fp = filp;
 	reg->kr_uid = uid;
-	reg->kr_data = data;
+	memcpy(reg->kr_data, data, data_len);
 
 	down_write(&kg_sem);
 	if (kkuc_groups[group].next == NULL)
@@ -145,7 +145,7 @@ int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
 }
 EXPORT_SYMBOL(libcfs_kkuc_group_add);
 
-int libcfs_kkuc_group_rem(int uid, int group, void **pdata)
+int libcfs_kkuc_group_rem(int uid, int group)
 {
 	struct kkuc_reg *reg, *next;
 
@@ -171,8 +171,6 @@ int libcfs_kkuc_group_rem(int uid, int group, void **pdata)
 			       reg->kr_uid, reg->kr_fp, group);
 			if (reg->kr_fp != NULL)
 				fput(reg->kr_fp);
-			if (pdata)
-				*pdata = reg->kr_data;
 			kfree(reg);
 		}
 	}
-- 
1.7.1
