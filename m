From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:16 -0400
Subject: [lustre-devel] [PATCH 117/151] lustre: flr: split a mirror from
 mirrored file
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-118-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

Splits a mirror with mirror_id out of a mirrored file.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10420
Lustre-commit: 23b2d4781899 ("LU-10420 flr: split a mirror from mirrored file")
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-on: https://review.whamcloud.com/30388
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h           |  1 +
 fs/lustre/include/lustre_mds.h          |  5 +++
 fs/lustre/include/obd.h                 |  2 ++
 fs/lustre/llite/file.c                  | 54 +++++++++++++++++++++++++++++++--
 fs/lustre/llite/llite_lib.c             |  3 +-
 fs/lustre/mdc/mdc_lib.c                 |  4 ++-
 include/uapi/linux/lustre/lustre_idl.h  |  8 +++--
 include/uapi/linux/lustre/lustre_user.h |  3 +-
 8 files changed, 72 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index e1979be..e49954c 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -847,6 +847,7 @@ enum lu_xattr_flags {
 	LU_XATTR_REPLACE = (1 << 0),
 	LU_XATTR_CREATE	 = BIT(1),
 	LU_XATTR_MERGE   = BIT(2),
+	LU_XATTR_SPLIT	 = BIT(3),
 };
 
 /** @} helpers */
diff --git a/fs/lustre/include/lustre_mds.h b/fs/lustre/include/lustre_mds.h
index 18fe0e3..2510fe0 100644
--- a/fs/lustre/include/lustre_mds.h
+++ b/fs/lustre/include/lustre_mds.h
@@ -54,6 +54,11 @@ struct mds_group_info {
 	int			group;
 };
 
+struct md_rejig_data {
+	struct md_object	*mrd_obj;
+	u16			mrd_mirror_id;
+};
+
 #define MDD_OBD_NAME     "mdd_obd"
 #define MDD_OBD_UUID     "mdd_obd_uuid"
 
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 1cb37a0..2db2596 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -780,6 +780,8 @@ struct md_op_data {
 	u32			op_default_stripe_offset;
 
 	u32			op_projid;
+
+	u16			op_mirror_id;
 };
 
 struct md_callback {
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 9d60587..92f4a43 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -50,6 +50,11 @@
 #include <cl_object.h>
 #include "llite_internal.h"
 
+struct split_param {
+	struct inode	*sp_inode;
+	u16		sp_mirror_id;
+};
+
 static int
 ll_put_grouplock(struct inode *inode, struct file *file, unsigned long arg);
 
@@ -153,13 +158,22 @@ static int ll_close_inode_openhandle(struct inode *inode,
 		op_data->op_attr.ia_valid |= ATTR_SIZE;
 		op_data->op_xvalid |= OP_XVALID_BLOCKS;
 		/* fallthrough */
-	case MDS_CLOSE_LAYOUT_SWAP:
+	case MDS_CLOSE_LAYOUT_SPLIT:
+	case MDS_CLOSE_LAYOUT_SWAP: {
+		struct split_param *sp = data;
+
 		LASSERT(data);
 		op_data->op_bias |= bias;
 		op_data->op_data_version = 0;
 		op_data->op_lease_handle = och->och_lease_handle;
-		op_data->op_fid2 = *ll_inode2fid(data);
+		if (bias == MDS_CLOSE_LAYOUT_SPLIT) {
+			op_data->op_fid2 = *ll_inode2fid(sp->sp_inode);
+			op_data->op_mirror_id = sp->sp_mirror_id;
+		} else {
+			op_data->op_fid2 = *ll_inode2fid(data);
+		}
 		break;
+	}
 
 	case MDS_CLOSE_RESYNC_DONE: {
 		struct ll_ioc_lease *ioc = data;
@@ -2659,6 +2673,7 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct obd_client_handle *och = NULL;
+	struct split_param sp;
 	bool lease_broken;
 	fmode_t fmode = 0;
 	enum mds_op_bias bias = 0;
@@ -2732,6 +2747,40 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 		bias = MDS_CLOSE_LAYOUT_MERGE;
 		break;
 	}
+	case LL_LEASE_LAYOUT_SPLIT: {
+		int fdv;
+		int mirror_id;
+
+		if (ioc->lil_count != 2) {
+			rc = -EINVAL;
+			goto out;
+		}
+
+		arg += sizeof(*ioc);
+		if (copy_from_user(&fdv, (void __user *)arg, sizeof(u32))) {
+			rc = -EFAULT;
+			goto out;
+		}
+
+		arg += sizeof(u32);
+		if (copy_from_user(&mirror_id, (void __user *)arg,
+				   sizeof(u32))) {
+			rc = -EFAULT;
+			goto out;
+		}
+
+		layout_file = fget(fdv);
+		if (!layout_file) {
+			rc = -EBADF;
+			goto out;
+		}
+
+		sp.sp_inode = file_inode(layout_file);
+		sp.sp_mirror_id = (u16)mirror_id;
+		data = &sp;
+		bias = MDS_CLOSE_LAYOUT_SPLIT;
+		break;
+	}
 	default:
 		/* without close intent */
 		break;
@@ -2754,6 +2803,7 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 		kfree(data);
 		break;
 	case LL_LEASE_LAYOUT_MERGE:
+	case LL_LEASE_LAYOUT_SPLIT:
 		if (layout_file)
 			fput(layout_file);
 		break;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 4f4234d..2a7ef64 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2427,11 +2427,10 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
 	op_data->op_cap = current_cap();
+	op_data->op_mds = 0;
 	if ((opc == LUSTRE_OPC_CREATE) && name &&
 	    filename_is_volatile(name, namelen, &op_data->op_mds))
 		op_data->op_bias |= MDS_CREATE_VOLATILE;
-	else
-		op_data->op_mds = 0;
 	op_data->op_data = data;
 
 	return op_data;
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index dc5dac4..1031a01 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -451,7 +451,9 @@ static void mdc_close_intent_pack(struct ptlrpc_request *req,
 	data->cd_data_version = op_data->op_data_version;
 	data->cd_fid = op_data->op_fid2;
 
-	if (bias & MDS_CLOSE_RESYNC_DONE) {
+	if (bias & MDS_CLOSE_LAYOUT_SPLIT) {
+		data->cd_mirror_id = op_data->op_mirror_id;
+	} else if (bias & MDS_CLOSE_RESYNC_DONE) {
 		struct close_data_resync_done *sync = &data->cd_resync;
 
 		BUILD_BUG_ON(sizeof(data->cd_resync) > sizeof(data->cd_reserved));
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 4b33104..6dce6f1 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1654,10 +1654,12 @@ enum mds_op_bias {
 	MDS_CLOSE_LAYOUT_SWAP	= 1 << 14,
 	MDS_CLOSE_LAYOUT_MERGE	= 1 << 15,
 	MDS_CLOSE_RESYNC_DONE	= 1 << 16,
+	MDS_CLOSE_LAYOUT_SPLIT	= 1 << 17,
 };
 
-#define MDS_CLOSE_INTENT (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP |	\
-			  MDS_CLOSE_LAYOUT_MERGE | MDS_CLOSE_RESYNC_DONE)
+#define MDS_CLOSE_INTENT (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP |         \
+			  MDS_CLOSE_LAYOUT_MERGE | MDS_CLOSE_LAYOUT_SPLIT | \
+			  MDS_CLOSE_RESYNC_DONE)
 
 /* instance of mdt_reint_rec */
 struct mdt_rec_create {
@@ -2863,6 +2865,8 @@ struct close_data {
 	union {
 		__u64				cd_reserved[8];
 		struct close_data_resync_done	cd_resync;
+		/* split close */
+		__u16				cd_mirror_id;
 	};
 };
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index f3fa24b..cea7d13 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -254,6 +254,7 @@ enum ll_lease_flags {
 	LL_LEASE_RESYNC		= 0x1,
 	LL_LEASE_RESYNC_DONE	= 0x2,
 	LL_LEASE_LAYOUT_MERGE	= 0x4,
+	LL_LEASE_LAYOUT_SPLIT	= 0x8,
 };
 
 #define IOC_IDS_MAX	4096
@@ -766,7 +767,7 @@ struct identity_downcall_data {
 };
 
 /* lustre volatile file support
- * file name header: .^L^S^T^R:volatile"
+ * file name header: ".^L^S^T^R:volatile"
  */
 #define LUSTRE_VOLATILE_HDR	".\x0c\x13\x14\x12:VOLATILE"
 #define LUSTRE_VOLATILE_HDR_LEN	14
-- 
1.8.3.1
