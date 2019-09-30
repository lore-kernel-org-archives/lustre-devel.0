From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:24 -0400
Subject: [lustre-devel] [PATCH 065/151] lustre: flr: add infrastructure to
 create a new mirror
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-66-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

This patch adds the initial code to support file level redundancy
phase 1. Details about the implementation can be read at

http://wiki.lustre.org/File_Level_Replication_High_Level_Design.

Add the definitions for FLR support to the UAPI headers. These
values are also placed in RPC packets to send to the servers.
We expand both enum mds_op_bias and enum lu_xattr_flags with
the 'MERGE' values that cover the FLR support.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
Lustre-commit: b879bbc27db5 ("LU-9771 flr: add infrastructure to create a new mirror")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/29083
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h           |  3 ++-
 fs/lustre/llite/file.c                  | 38 +++++++++++++++++----------
 fs/lustre/lov/lov_ea.c                  |  1 +
 fs/lustre/lov/lov_internal.h            |  3 ++-
 fs/lustre/lov/lov_pack.c                |  1 +
 fs/lustre/mdc/mdc_lib.c                 |  3 +--
 fs/lustre/mdc/mdc_request.c             |  3 ++-
 fs/lustre/ptlrpc/pack_generic.c         |  1 +
 fs/lustre/ptlrpc/wiretest.c             | 18 +++++++++++--
 include/uapi/linux/lustre/lustre_idl.h  |  4 +++
 include/uapi/linux/lustre/lustre_user.h | 46 ++++++++++++++++++++++++++++++++-
 11 files changed, 99 insertions(+), 22 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 05f8d81..9427ad4 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -864,7 +864,8 @@ struct lu_rdpg {
 
 enum lu_xattr_flags {
 	LU_XATTR_REPLACE = (1 << 0),
-	LU_XATTR_CREATE  = (1 << 1)
+	LU_XATTR_CREATE	 = BIT(1),
+	LU_XATTR_MERGE   = BIT(2),
 };
 
 /** @} helpers */
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 0852e37..e1f264d 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -147,9 +147,10 @@ static int ll_close_inode_openhandle(struct inode *inode,
 
 	ll_prepare_close(inode, op_data, och);
 	switch (bias) {
+	case MDS_CLOSE_LAYOUT_MERGE:
 	case MDS_CLOSE_LAYOUT_SWAP:
 		LASSERT(data);
-		op_data->op_bias |= MDS_CLOSE_LAYOUT_SWAP;
+		op_data->op_bias |= bias;
 		op_data->op_data_version = 0;
 		op_data->op_lease_handle = och->och_lease_handle;
 		op_data->op_fid2 = *ll_inode2fid(data);
@@ -175,8 +176,7 @@ static int ll_close_inode_openhandle(struct inode *inode,
 		       md_exp->exp_obd->obd_name, PFID(&lli->lli_fid), rc);
 	}
 
-	if (op_data->op_bias & (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP) &&
-	    !rc) {
+	if (rc == 0 && (op_data->op_bias & bias)) {
 		struct mdt_body *body;
 
 		body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
@@ -948,10 +948,12 @@ static int ll_check_swap_layouts_validity(struct inode *inode1,
 }
 
 static int ll_swap_layouts_close(struct obd_client_handle *och,
-				 struct inode *inode, struct inode *inode2)
+				 struct inode *inode, struct inode *inode2,
+				 int intent)
 {
 	const struct lu_fid *fid1 = ll_inode2fid(inode);
 	const struct lu_fid *fid2;
+	enum mds_op_bias bias;
 	int rc;
 
 	CDEBUG(D_INODE, "%s: biased close of file " DFID "\n",
@@ -970,13 +972,24 @@ static int ll_swap_layouts_close(struct obd_client_handle *och,
 		goto out_free_och;
 	}
 
+	switch (intent) {
+	case SWAP_LAYOUTS_CLOSE:
+		bias = MDS_CLOSE_LAYOUT_SWAP;
+		break;
+	case MERGE_LAYOUTS_CLOSE:
+		bias = MDS_CLOSE_LAYOUT_MERGE;
+		break;
+	default:
+		rc = -EOPNOTSUPP;
+		goto out_free_och;
+	}
+
 	/*
-	 * Close the file and swap layouts between inode & inode2.
+	 * Close the file and {swap,merge} layouts between inode & inode2.
 	 * NB: lease lock handle is released in mdc_close_layout_swap_pack()
 	 * because we still need it to pack l_remote_handle to MDT.
 	 */
-	rc = ll_close_inode_openhandle(inode, och, MDS_CLOSE_LAYOUT_SWAP,
-				       inode2);
+	rc = ll_close_inode_openhandle(inode, och, bias, inode2);
 
 	och = NULL; /* freed in ll_close_inode_openhandle() */
 
@@ -2557,6 +2570,7 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 	case LL_IOC_LOV_SWAP_LAYOUTS: {
 		struct file *file2;
 		struct lustre_swap_layouts lsl;
+		u64 intent;
 
 		if (copy_from_user(&lsl, (char __user *)arg,
 				   sizeof(struct lustre_swap_layouts)))
@@ -2575,16 +2589,12 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 			goto out;
 		}
 
-		if (lsl.sl_flags & SWAP_LAYOUTS_CLOSE) {
+		intent = lsl.sl_flags & INTENT_LAYOUTS_CLOSE;
+		if (intent) {
 			struct obd_client_handle *och = NULL;
 			struct ll_inode_info *lli;
 			struct inode *inode2;
 
-			if (lsl.sl_flags != SWAP_LAYOUTS_CLOSE) {
-				rc = -EINVAL;
-				goto out;
-			}
-
 			lli = ll_i2info(inode);
 			mutex_lock(&lli->lli_och_mutex);
 			if (fd->fd_lease_och) {
@@ -2597,7 +2607,7 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 				goto out;
 			}
 			inode2 = file_inode(file2);
-			rc = ll_swap_layouts_close(och, inode, inode2);
+			rc = ll_swap_layouts_close(och, inode, inode2, intent);
 		} else {
 			rc = ll_swap_layouts(file, file2, &lsl);
 		}
diff --git a/fs/lustre/lov/lov_ea.c b/fs/lustre/lov/lov_ea.c
index 8ecf3eb..081a04f 100644
--- a/fs/lustre/lov/lov_ea.c
+++ b/fs/lustre/lov/lov_ea.c
@@ -446,6 +446,7 @@ static int lsm_verify_comp_md_v1(struct lov_comp_md_v1 *lcm,
 	lsm->lsm_magic = le32_to_cpu(lcm->lcm_magic);
 	lsm->lsm_layout_gen = le32_to_cpu(lcm->lcm_layout_gen);
 	lsm->lsm_entry_count = entry_count;
+	lsm->lsm_mirror_count = le16_to_cpu(lcm->lcm_mirror_count);
 	lsm->lsm_flags = le16_to_cpu(lcm->lcm_flags);
 	lsm->lsm_is_released = true;
 	lsm->lsm_maxbytes = LLONG_MIN;
diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
index 18fe92f..b3712d2 100644
--- a/fs/lustre/lov/lov_internal.h
+++ b/fs/lustre/lov/lov_internal.h
@@ -88,7 +88,8 @@ struct lov_stripe_md {
 	u32		lsm_layout_gen;
 	u16		lsm_flags;
 	bool		lsm_is_released;
-	u32		lsm_entry_count;
+	u16		lsm_mirror_count;
+	u16		lsm_entry_count;
 	struct lov_stripe_md_entry *lsm_entries[];
 };
 
diff --git a/fs/lustre/lov/lov_pack.c b/fs/lustre/lov/lov_pack.c
index c8b55eb..aac5048 100644
--- a/fs/lustre/lov/lov_pack.c
+++ b/fs/lustre/lov/lov_pack.c
@@ -186,6 +186,7 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 	lcmv1->lcm_size = cpu_to_le32(lmm_size);
 	lcmv1->lcm_layout_gen = cpu_to_le32(lsm->lsm_layout_gen);
 	lcmv1->lcm_flags = cpu_to_le16(lsm->lsm_flags);
+	lcmv1->lcm_mirror_count = cpu_to_le16(lsm->lsm_mirror_count);
 	lcmv1->lcm_entry_count = cpu_to_le16(lsm->lsm_entry_count);
 
 	offset = sizeof(*lcmv1) + sizeof(*lcme) * lsm->lsm_entry_count;
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index 6aa9dc2..3601e17 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -431,8 +431,7 @@ static void mdc_intent_close_pack(struct ptlrpc_request *req,
 	struct close_data *data;
 	struct ldlm_lock *lock;
 
-	if (!(bias & (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP |
-		      MDS_RENAME_MIGRATE)))
+	if (!(bias & (MDS_CLOSE_INTENT | MDS_RENAME_MIGRATE)))
 		return;
 
 	data = req_capsule_client_get(&req->rq_pill, &RMF_CLOSE_DATA);
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 655f1c2..a1ed9bf 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -776,7 +776,8 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 			/* save the errcode and proceed to close */
 			saved_rc = rc;
 		}
-	} else if (op_data->op_bias & MDS_CLOSE_LAYOUT_SWAP) {
+	} else if (op_data->op_bias & (MDS_CLOSE_LAYOUT_SWAP |
+				       MDS_CLOSE_LAYOUT_MERGE)) {
 		req_fmt = &RQF_MDS_INTENT_CLOSE;
 	} else {
 		req_fmt = &RQF_MDS_CLOSE;
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index a631dde..eb82eaa 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -2018,6 +2018,7 @@ void lustre_swab_lov_comp_md_v1(struct lov_comp_md_v1 *lum)
 	__swab32s(&lum->lcm_layout_gen);
 	__swab16s(&lum->lcm_flags);
 	__swab16s(&lum->lcm_entry_count);
+	__swab16s(&lum->lcm_mirror_count);
 	BUILD_BUG_ON(offsetof(typeof(*lum), lcm_padding1) == 0);
 	BUILD_BUG_ON(offsetof(typeof(*lum), lcm_padding2) == 0);
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 1092cc2..749effb 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1513,6 +1513,8 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding));
 	LASSERTF(LCME_FL_INIT == 0x00000010UL, "found 0x%.8xUL\n",
 		 (unsigned int)LCME_FL_INIT);
+	LASSERTF(LCME_FL_NEG == 0x80000000UL, "found 0x%.8xUL\n",
+		 (unsigned int)LCME_FL_NEG);
 
 	/* Checks for struct lov_comp_md_v1 */
 	LASSERTF((int)sizeof(struct lov_comp_md_v1) == 32, "found %lld\n",
@@ -1537,9 +1539,13 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lov_comp_md_v1, lcm_entry_count));
 	LASSERTF((int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_entry_count) == 2, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_entry_count));
-	LASSERTF((int)offsetof(struct lov_comp_md_v1, lcm_padding1) == 16, "found %lld\n",
+	LASSERTF((int)offsetof(struct lov_comp_md_v1, lcm_mirror_count) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_v1, lcm_mirror_count));
+	LASSERTF((int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_mirror_count) == 2, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_mirror_count));
+	LASSERTF((int)offsetof(struct lov_comp_md_v1, lcm_padding1) == 18, "found %lld\n",
 		 (long long)(int)offsetof(struct lov_comp_md_v1, lcm_padding1));
-	LASSERTF((int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_padding1) == 8, "found %lld\n",
+	LASSERTF((int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_padding1) == 6, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_padding1));
 	LASSERTF((int)offsetof(struct lov_comp_md_v1, lcm_padding2) == 24, "found %lld\n",
 		 (long long)(int)offsetof(struct lov_comp_md_v1, lcm_padding2));
@@ -1550,6 +1556,14 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_entries[0]) == 48, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_entries[0]));
 	BUILD_BUG_ON(LOV_MAGIC_COMP_V1 != (0x0BD60000 | 0x0BD0));
+	LASSERTF(LCM_FL_NOT_FLR == 0, "found %lld\n",
+		 (long long)LCM_FL_NOT_FLR);
+	LASSERTF(LCM_FL_RDONLY == 1, "found %lld\n",
+		 (long long)LCM_FL_RDONLY);
+	LASSERTF(LCM_FL_WRITE_PENDING == 2, "found %lld\n",
+		 (long long)LCM_FL_WRITE_PENDING);
+	LASSERTF(LCM_FL_SYNC_PENDING == 3, "found %lld\n",
+		 (long long)LCM_FL_SYNC_PENDING);
 
 	/* Checks for struct lmv_mds_md_v1 */
 	LASSERTF((int)sizeof(struct lmv_mds_md_v1) == 56, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 2181386..131f1c9 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1686,8 +1686,12 @@ enum mds_op_bias {
 	MDS_HSM_RELEASE		= 1 << 12,
 	MDS_RENAME_MIGRATE	= 1 << 13,
 	MDS_CLOSE_LAYOUT_SWAP	= 1 << 14,
+	MDS_CLOSE_LAYOUT_MERGE	= 1 << 15,
 };
 
+#define MDS_CLOSE_INTENT (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP |	\
+			  MDS_CLOSE_LAYOUT_MERGE)
+
 /* instance of mdt_reint_rec */
 struct mdt_rec_create {
 	__u32		cr_opcode;
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 4a6ed5e..34c86df 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -424,6 +424,11 @@ static inline bool lu_extent_is_overlapped(struct lu_extent *e1,
 	return e1->e_start < e2->e_end && e2->e_start < e1->e_end;
 }
 
+static inline bool lu_extent_is_whole(struct lu_extent *e)
+{
+	return e->e_start == 0 && e->e_end == LUSTRE_EOF;
+}
+
 enum lov_comp_md_entry_flags {
 	LCME_FL_PRIMARY		= 0x00000001,	/* Not used */
 	LCME_FL_STALE		= 0x00000002,	/* Not used */
@@ -460,17 +465,54 @@ struct lov_comp_md_entry_v1 {
 	__u64			lcme_padding[2];
 } __packed;
 
+#define SEQ_ID_MAX		0x0000FFFF
+#define SEQ_ID_MASK		SEQ_ID_MAX
+/* bit 30:16 of lcme_id is used to store mirror id */
+#define MIRROR_ID_MASK		0x7FFF0000
+#define MIRROR_ID_SHIFT		16
+
+static inline __u32 pflr_id(__u16 mirror_id, __u16 seqid)
+{
+	return ((mirror_id << MIRROR_ID_SHIFT) & MIRROR_ID_MASK) | seqid;
+}
+
+static inline __u16 mirror_id_of(__u32 id)
+{
+	return (id & MIRROR_ID_MASK) >> MIRROR_ID_SHIFT;
+}
+
+/**
+ * on-disk data for lcm_flags. Valid if lcm_magic is LOV_MAGIC_COMP_V1.
+ */
+enum lov_comp_md_flags {
+	/* the least 2 bits are used by FLR to record file state */
+	LCM_FL_NOT_FLR          = 0,
+	LCM_FL_RDONLY           = 1,
+	LCM_FL_WRITE_PENDING    = 2,
+	LCM_FL_SYNC_PENDING     = 3,
+	LCM_FL_FLR_MASK         = 0x3,
+};
+
 struct lov_comp_md_v1 {
 	__u32	lcm_magic;	/* LOV_USER_MAGIC_COMP_V1 */
 	__u32	lcm_size;	/* overall size including this struct */
 	__u32	lcm_layout_gen;
 	__u16	lcm_flags;
 	__u16	lcm_entry_count;
-	__u64	lcm_padding1;
+	/* lcm_mirror_count stores the number of actual mirrors minus 1,
+	 * so that non-flr files will have value 0 meaning 1 mirror.
+	 */
+	__u16	lcm_mirror_count;
+	__u16	lcm_padding1[3];
 	__u64	lcm_padding2;
 	struct lov_comp_md_entry_v1 lcm_entries[0];
 } __packed;
 
+/*
+ * Maximum number of mirrors Lustre can support.
+ */
+#define LUSTRE_MIRROR_COUNT_MAX		16
+
 static inline __u32 lov_user_md_size(__u16 stripes, __u32 lmm_magic)
 {
 	if (stripes == (__u16)-1)
@@ -745,6 +787,8 @@ struct if_quotactl {
 #define SWAP_LAYOUTS_KEEP_MTIME		(1 << 2)
 #define SWAP_LAYOUTS_KEEP_ATIME		(1 << 3)
 #define SWAP_LAYOUTS_CLOSE		(1 << 4)
+#define MERGE_LAYOUTS_CLOSE		(1 << 5)
+#define INTENT_LAYOUTS_CLOSE	(SWAP_LAYOUTS_CLOSE | MERGE_LAYOUTS_CLOSE)
 
 /* Swap XATTR_NAME_HSM as well, only on the MDT so far */
 #define SWAP_LAYOUTS_MDS_HSM		(1 << 31)
-- 
1.8.3.1
