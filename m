From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:40 -0500
Subject: [lustre-devel] [PATCH 172/622] lustre: hsm: increase upper limit of
 maximum HSM backends registered with MDT
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-173-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Teddy Zheng <teddy@ddn.com>

Lustre only supports at most 32 HSM backends, which limits HSM to be applied
to other features, such as LPCC. This patch breaks the limitation by allowing
the system take any interger number as a valid archive-id.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10114
Lustre-commit: 3bfb6107ba4e ("LU-10114 hsm: increase upper limit of maximum HSM backends registered with MDT")
Signed-off-by: Teddy Zheng <teddy@ddn.com>
Signed-off-by: Li Xi <lixi@ddn.com>
Reviewed-on: https://review.whamcloud.com/32197
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_export.h             |  15 +++-
 fs/lustre/llite/dir.c                         | 115 +++++++++++++++++++++++---
 fs/lustre/llite/file.c                        |  15 ++--
 fs/lustre/llite/llite_lib.c                   |   3 +-
 fs/lustre/lmv/lmv_obd.c                       |  31 +++++--
 fs/lustre/mdc/mdc_request.c                   |  81 +++++++++++++-----
 fs/lustre/ptlrpc/layout.c                     |   2 +-
 include/uapi/linux/lustre/lustre_idl.h        |  10 ++-
 include/uapi/linux/lustre/lustre_kernelcomm.h |  15 +++-
 9 files changed, 235 insertions(+), 52 deletions(-)

diff --git a/fs/lustre/include/lustre_export.h b/fs/lustre/include/lustre_export.h
index 57cf68b..c94efb0 100644
--- a/fs/lustre/include/lustre_export.h
+++ b/fs/lustre/include/lustre_export.h
@@ -276,11 +276,22 @@ static inline int exp_connect_lock_convert(struct obd_export *exp)
 
 struct obd_export *class_conn2export(struct lustre_handle *conn);
 
-#define KKUC_CT_DATA_MAGIC	0x092013cea
+static inline int exp_connect_archive_id_array(struct obd_export *exp)
+{
+	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_ARCHIVE_ID_ARRAY);
+}
+
+enum {
+	/* archive_ids in array format */
+	KKUC_CT_DATA_ARRAY_MAGIC	= 0x092013cea,
+	/* archive_ids in bitmap format */
+	KKUC_CT_DATA_BITMAP_MAGIC	= 0x082018cea,
+};
 
 struct kkuc_ct_data {
 	u32			kcd_magic;
-	u32			kcd_archive;
+	u32			kcd_nr_archives;
+	u32			kcd_archives[0];
 };
 
 /** @} export */
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 3da9d14..f54987a 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -931,19 +931,114 @@ static int ll_ioc_copy_end(struct super_block *sb, struct hsm_copy *copy)
 	return rc ? rc : rc2;
 }
 
-static int copy_and_ioctl(int cmd, struct obd_export *exp,
-			  const void __user *data, size_t size)
+static int copy_and_ct_start(int cmd, struct obd_export *exp,
+			     const struct lustre_kernelcomm __user *data)
 {
-	void *copy;
+	struct lustre_kernelcomm *lk;
+	struct lustre_kernelcomm *tmp;
+	size_t size = sizeof(*lk);
+	size_t new_size;
 	int rc;
+	int i;
 
-	copy = memdup_user(data, size);
-	if (IS_ERR(copy))
-		return PTR_ERR(copy);
+	lk = memdup_user(data, size);
+	if (IS_ERR(lk)) {
+		rc = PTR_ERR(lk);
+		goto out_lk;
+	}
+
+	if (lk->lk_flags & LK_FLG_STOP)
+		goto do_ioctl;
+
+	if (!(lk->lk_flags & LK_FLG_DATANR)) {
+		u32 archive_mask = lk->lk_data_count;
+		int count;
+
+		/* old hsm agent to old MDS */
+		if (!exp_connect_archive_id_array(exp))
+			goto do_ioctl;
+
+		/* old hsm agent to new MDS */
+		lk->lk_flags |= LK_FLG_DATANR;
+
+		if (archive_mask == 0)
+			goto do_ioctl;
+
+		count = hweight32(archive_mask);
+		new_size = offsetof(struct lustre_kernelcomm, lk_data[count]);
+		tmp = kmalloc(new_size, GFP_KERNEL);
+		if (!tmp) {
+			rc = -ENOMEM;
+			goto out_lk;
+		}
+		memcpy(tmp, lk, size);
+		tmp->lk_data_count = count;
+		kfree(lk);
+		lk = tmp;
+		size = new_size;
+
+		count = 0;
+		for (i = 0; i < sizeof(archive_mask) * 8; i++) {
+			if (BIT(i) & archive_mask) {
+				lk->lk_data[count] = i + 1;
+				count++;
+			}
+		}
+		goto do_ioctl;
+	}
+
+	/* new hsm agent to new mds */
+	if (lk->lk_data_count > 0) {
+		new_size = offsetof(struct lustre_kernelcomm,
+				    lk_data[lk->lk_data_count]);
+		tmp = kmalloc(new_size, GFP_KERNEL);
+		if (!tmp) {
+			rc = -ENOMEM;
+			goto out_lk;
+		}
+
+		kfree(lk);
+		lk = tmp;
+		size = new_size;
+
+		if (copy_from_user(lk, data, size)) {
+			rc = -EFAULT;
+			goto out_lk;
+		}
+	}
+
+	/* new hsm agent to old MDS */
+	if (!exp_connect_archive_id_array(exp)) {
+		u32 archives = 0;
+
+		if (lk->lk_data_count > LL_HSM_ORIGIN_MAX_ARCHIVE) {
+			rc = -EINVAL;
+			goto out_lk;
+		}
+
+		for (i = 0; i < lk->lk_data_count; i++) {
+			if (lk->lk_data[i] > LL_HSM_ORIGIN_MAX_ARCHIVE) {
+				rc = -EINVAL;
+				CERROR("%s: archive id %d requested but only [0 - %zu] supported: rc = %d\n",
+				       exp->exp_obd->obd_name, lk->lk_data[i],
+				LL_HSM_ORIGIN_MAX_ARCHIVE, rc);
+				goto out_lk;
+			}
 
-	rc = obd_iocontrol(cmd, exp, size, copy, NULL);
-	kfree(copy);
+			if (lk->lk_data[i] == 0) {
+				archives = 0;
+				break;
+			}
 
+			archives |= BIT(lk->lk_data[i] - 1);
+		}
+		lk->lk_flags &= ~LK_FLG_DATANR;
+		lk->lk_data_count = archives;
+	}
+do_ioctl:
+	rc = obd_iocontrol(cmd, exp, size, lk, NULL);
+out_lk:
+	kfree(lk);
 	return rc;
 }
 
@@ -1671,8 +1766,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (!capable(CAP_SYS_ADMIN))
 			return -EPERM;
 
-		rc = copy_and_ioctl(cmd, sbi->ll_md_exp, (void __user *)arg,
-				    sizeof(struct lustre_kernelcomm));
+		rc = copy_and_ct_start(cmd, sbi->ll_md_exp,
+				       (struct lustre_kernelcomm __user *)arg);
 		return rc;
 
 	case LL_IOC_HSM_COPY_START: {
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 25d7986..7078734 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2397,6 +2397,7 @@ static int ll_swap_layouts(struct file *file1, struct file *file2,
 
 int ll_hsm_state_set(struct inode *inode, struct hsm_state_set *hss)
 {
+	struct obd_export *exp = ll_i2mdexp(inode);
 	struct md_op_data *op_data;
 	int rc;
 
@@ -2411,18 +2412,20 @@ int ll_hsm_state_set(struct inode *inode, struct hsm_state_set *hss)
 	    !capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	/* Detect out-of range archive id */
-	if ((hss->hss_valid & HSS_ARCHIVE_ID) &&
-	    (hss->hss_archive_id > LL_HSM_MAX_ARCHIVE))
-		return -EINVAL;
+	if (!exp_connect_archive_id_array(exp)) {
+		/* Detect out-of range archive id */
+		if ((hss->hss_valid & HSS_ARCHIVE_ID) &&
+		    (hss->hss_archive_id > LL_HSM_ORIGIN_MAX_ARCHIVE))
+			return -EINVAL;
+	}
 
 	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
 				     LUSTRE_OPC_ANY, hss);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	rc = obd_iocontrol(LL_IOC_HSM_STATE_SET, ll_i2mdexp(inode),
-			   sizeof(*op_data), op_data, NULL);
+	rc = obd_iocontrol(LL_IOC_HSM_STATE_SET, exp, sizeof(*op_data),
+			   op_data, NULL);
 
 	ll_finish_md_op_data(op_data);
 
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index b766402..4797ee9 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -212,7 +212,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	data->ocd_connect_flags2 = OBD_CONNECT2_FLR |
 				   OBD_CONNECT2_LOCK_CONVERT |
 				   OBD_CONNECT2_DIR_MIGRATE |
-				   OBD_CONNECT2_SUM_STATFS;
+				   OBD_CONNECT2_SUM_STATFS |
+				   OBD_CONNECT2_ARCHIVE_ID_ARRAY;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 428904c..9f9abd3 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -788,18 +788,39 @@ static int lmv_hsm_ct_register(struct obd_device *obd, unsigned int cmd,
 	u32 i, j;
 	int err;
 	bool any_set = false;
-	struct kkuc_ct_data kcd = {
-		.kcd_magic	= KKUC_CT_DATA_MAGIC,
-		.kcd_archive	= lk->lk_data,
-	};
+	struct kkuc_ct_data *kcd;
+	size_t kcd_size;
 	int rc = 0;
 
 	filp = fget(lk->lk_wfd);
 	if (!filp)
 		return -EBADF;
 
+	if (lk->lk_flags & LK_FLG_DATANR)
+		kcd_size = offsetof(struct kkuc_ct_data,
+				    kcd_archives[lk->lk_data_count]);
+	else
+		kcd_size = sizeof(*kcd);
+
+	kcd = kmalloc(kcd_size, GFP_KERNEL);
+	if (!kcd) {
+		rc = -ENOMEM;
+		goto err_fput;
+	}
+
+	kcd->kcd_nr_archives = lk->lk_data_count;
+	if (lk->lk_flags & LK_FLG_DATANR) {
+		kcd->kcd_magic = KKUC_CT_DATA_ARRAY_MAGIC;
+		if (lk->lk_data_count > 0)
+			memcpy(kcd->kcd_archives, lk->lk_data,
+			       sizeof(*kcd->kcd_archives) * lk->lk_data_count);
+	} else {
+		kcd->kcd_magic = KKUC_CT_DATA_BITMAP_MAGIC;
+	}
+
 	rc = libcfs_kkuc_group_add(filp, &obd->obd_uuid, lk->lk_uid,
-				   lk->lk_group, &kcd, sizeof(kcd));
+				   lk->lk_group, kcd, kcd_size);
+	kfree(kcd);
 	if (rc)
 		goto err_fput;
 
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 6934e57..d702fd1 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -1689,31 +1689,56 @@ static int mdc_ioc_hsm_progress(struct obd_export *exp,
 	return rc;
 }
 
-static int mdc_ioc_hsm_ct_register(struct obd_import *imp, u32 archives)
+/**
+ * Send hsm_ct_register to MDS
+ *
+ * @imp			import
+ * @ archive_count	if in bitmap format, it is the bitmap,
+ *			else it is the count of archive_ids
+ * @archives		if in bitmap format, it is NULL,
+ *			else it is archive_id lists
+ *
+ * Return:		0 on success, negated error code on failure.
+ */
+static int mdc_ioc_hsm_ct_register(struct obd_import *imp, u32 archive_count,
+				   u32 *archives)
 {
-	u32 *archive_mask;
+	u32 *archive_array;
 	struct ptlrpc_request *req;
+	size_t archives_size;
 	int rc;
 
-	req = ptlrpc_request_alloc_pack(imp, &RQF_MDS_HSM_CT_REGISTER,
-					LUSTRE_MDS_VERSION,
-					MDS_HSM_CT_REGISTER);
-	if (!req) {
-		rc = -ENOMEM;
-		goto out;
+	req = ptlrpc_request_alloc(imp, &RQF_MDS_HSM_CT_REGISTER);
+	if (!req)
+		return -ENOMEM;
+
+	if (archives)
+		archives_size = sizeof(*archive_array) * archive_count;
+	else
+		archives_size = sizeof(archive_count);
+
+	req_capsule_set_size(&req->rq_pill, &RMF_MDS_HSM_ARCHIVE,
+			     RCL_CLIENT, archives_size);
+
+	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_HSM_CT_REGISTER);
+	if (rc) {
+		ptlrpc_request_free(req);
+		return -ENOMEM;
 	}
 
 	mdc_pack_body(req, NULL, 0, 0, -1, 0);
 
-	/* Copy hsm_progress struct */
-	archive_mask = req_capsule_client_get(&req->rq_pill,
-					      &RMF_MDS_HSM_ARCHIVE);
-	if (!archive_mask) {
+	archive_array = req_capsule_client_get(&req->rq_pill,
+					       &RMF_MDS_HSM_ARCHIVE);
+	if (!archive_array) {
 		rc = -EPROTO;
 		goto out;
 	}
 
-	*archive_mask = archives;
+	if (archives)
+		memcpy(archive_array, archives, archives_size);
+	else
+		*archive_array = archive_count;
 
 	ptlrpc_request_set_replen(req);
 
@@ -2249,7 +2274,6 @@ static int mdc_ioc_hsm_ct_start(struct obd_export *exp,
 				struct lustre_kernelcomm *lk)
 {
 	struct obd_import *imp = class_exp2cliimp(exp);
-	u32 archive = lk->lk_data;
 	int rc = 0;
 
 	if (lk->lk_group != KUC_GRP_HSM) {
@@ -2264,7 +2288,12 @@ static int mdc_ioc_hsm_ct_start(struct obd_export *exp,
 		/* Unregister with the coordinator */
 		rc = mdc_ioc_hsm_ct_unregister(imp);
 	} else {
-		rc = mdc_ioc_hsm_ct_register(imp, archive);
+		u32 *archives = NULL;
+
+		if ((lk->lk_flags & LK_FLG_DATANR) && lk->lk_data_count > 0)
+			archives = lk->lk_data;
+
+		rc = mdc_ioc_hsm_ct_register(imp, lk->lk_data_count, archives);
 	}
 
 	return rc;
@@ -2314,17 +2343,29 @@ static int mdc_hsm_copytool_send(const struct obd_uuid *uuid,
  */
 static int mdc_hsm_ct_reregister(void *data, void *cb_arg)
 {
-	struct kkuc_ct_data *kcd = data;
 	struct obd_import *imp = (struct obd_import *)cb_arg;
+	struct kkuc_ct_data *kcd = data;
+	u32 *archives = NULL;
 	int rc;
 
-	if (!kcd || kcd->kcd_magic != KKUC_CT_DATA_MAGIC)
+	if (!kcd ||
+	    (kcd->kcd_magic != KKUC_CT_DATA_ARRAY_MAGIC &&
+	     kcd->kcd_magic != KKUC_CT_DATA_BITMAP_MAGIC))
 		return -EPROTO;
 
-	CDEBUG(D_HA, "%s: recover copytool registration to MDT (archive=%#x)\n",
-	       imp->imp_obd->obd_name, kcd->kcd_archive);
-	rc = mdc_ioc_hsm_ct_register(imp, kcd->kcd_archive);
+	if (kcd->kcd_magic == KKUC_CT_DATA_BITMAP_MAGIC) {
+		CDEBUG(D_HA,
+		       "%s: recover copytool registration to MDT (archive=%#x)\n",
+		       imp->imp_obd->obd_name, kcd->kcd_nr_archives);
+	} else {
+		CDEBUG(D_HA,
+		       "%s: recover copytool registration to MDT (archive nr = %u)\n",
+		       imp->imp_obd->obd_name, kcd->kcd_nr_archives);
+		if (kcd->kcd_nr_archives != 0)
+			archives = kcd->kcd_archives;
+	}
 
+	rc = mdc_ioc_hsm_ct_register(imp, kcd->kcd_nr_archives, archives);
 	/* ignore error if the copytool is already registered */
 	return (rc == -EEXIST) ? 0 : rc;
 }
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 92d2fc2..2e74ae1b 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -1127,7 +1127,7 @@ struct req_msg_field RMF_MDS_HSM_USER_ITEM =
 EXPORT_SYMBOL(RMF_MDS_HSM_USER_ITEM);
 
 struct req_msg_field RMF_MDS_HSM_ARCHIVE =
-	DEFINE_MSGF("hsm_archive", 0,
+	DEFINE_MSGF("hsm_archive", RMF_F_STRUCT_ARRAY,
 		    sizeof(u32), lustre_swab_generic_32s, NULL);
 EXPORT_SYMBOL(RMF_MDS_HSM_ARCHIVE);
 
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 8330fe1..599fe86 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -194,12 +194,14 @@ enum {
 	LUSTRE_FID_INIT_OID  = 1UL
 };
 
-/* copytool uses a 32b bitmask field to encode archive-Ids during register
- * with MDT thru kuc.
+/* copytool can use any nonnegative integer to represent archive-Ids during
+ * register with MDT thru kuc.
  * archive num = 0 => all
- * archive num from 1 to 32
+ * archive num from 1 to MAX_U32
  */
-#define LL_HSM_MAX_ARCHIVE (sizeof(__u32) * 8)
+#define LL_HSM_ORIGIN_MAX_ARCHIVE	(sizeof(__u32) * 8)
+/* the max count of archive ids that one agent can support */
+#define LL_HSM_MAX_ARCHIVES_PER_AGENT	1024
 
 /**
  * Different FID Format
diff --git a/include/uapi/linux/lustre/lustre_kernelcomm.h b/include/uapi/linux/lustre/lustre_kernelcomm.h
index d84a8fc..8c5dec7 100644
--- a/include/uapi/linux/lustre/lustre_kernelcomm.h
+++ b/include/uapi/linux/lustre/lustre_kernelcomm.h
@@ -75,17 +75,26 @@ enum kuc_generic_message_type {
 #define KUC_GRP_HSM	0x02
 #define KUC_GRP_MAX	KUC_GRP_HSM
 
-#define LK_FLG_STOP 0x01
+enum lk_flags {
+	LK_FLG_STOP	= 0x0001,
+	LK_FLG_DATANR	= 0x0002,
+};
 #define LK_NOFD -1U
 
-/* kernelcomm control structure, passed from userspace to kernel */
+/* kernelcomm control structure, passed from userspace to kernel.
+ * For compatibility with old copytools, users who pass ARCHIVE_IDs
+ * to kernel using lk_data_count and lk_data should fill lk_flags with
+ * LK_FLG_DATANR. Otherwise kernel will take lk_data_count as bitmap of
+ * ARCHIVE IDs.
+ */
 struct lustre_kernelcomm {
 	__u32 lk_wfd;
 	__u32 lk_rfd;
 	__u32 lk_uid;
 	__u32 lk_group;
-	__u32 lk_data;
+	__u32 lk_data_count;
 	__u32 lk_flags;
+	__u32 lk_data[0];
 } __packed;
 
 #endif	/* __UAPI_LUSTRE_KERNELCOMM_H__ */
-- 
1.8.3.1
