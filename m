From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:25 -0400
Subject: [lustre-devel] [PATCH 066/151] lustre: clio: no glimpse for data
 immutable file
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-67-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

When merging a layout to an existing file as a mirror, client will
report the size and blocks to the MDT, which will be set to the MDT
object. In that case, if the MDT discovers a mirrored file in
READ_ONLY state, it will report the size and blocks. Clients should
take this advantage and skip glimpse.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
Lustre-commit: ce61bcac8661 ("LU-9771 clio: no glimpse for data immutable file")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/29084
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c                  |  5 +++++
 fs/lustre/lov/lov_io.c                  | 22 ++++++++++++++++------
 include/uapi/linux/lustre/lustre_idl.h  |  1 +
 include/uapi/linux/lustre/lustre_user.h | 11 +++++++++++
 4 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index e1f264d..6f991ed 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -148,6 +148,11 @@ static int ll_close_inode_openhandle(struct inode *inode,
 	ll_prepare_close(inode, op_data, och);
 	switch (bias) {
 	case MDS_CLOSE_LAYOUT_MERGE:
+		/* merge blocks from the victim inode */
+		op_data->op_attr_blocks += ((struct inode *)data)->i_blocks;
+		op_data->op_attr.ia_valid |= ATTR_SIZE;
+		op_data->op_xvalid |= OP_XVALID_BLOCKS;
+		/* fallthrough */
 	case MDS_CLOSE_LAYOUT_SWAP:
 		LASSERT(data);
 		op_data->op_bias |= bias;
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 1415702..c3fd86a 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -257,6 +257,13 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 	}
 
 	case CIT_GLIMPSE:
+		lio->lis_pos = 0;
+		lio->lis_endpos = OBD_OBJECT_EOF;
+
+		if ((obj->lo_lsm->lsm_flags & LCM_FL_FLR_MASK) == LCM_FL_RDONLY)
+			return 1; /* SoM is accurate, no need glimpse */
+		break;
+
 	case CIT_MISC:
 		lio->lis_pos = 0;
 		lio->lis_endpos = OBD_OBJECT_EOF;
@@ -1068,18 +1075,21 @@ int lov_io_init_composite(const struct lu_env *env, struct cl_object *obj,
 {
 	struct lov_io *lio = lov_env_io(env);
 	struct lov_object *lov = cl2lov(obj);
+	int result;
 
 	INIT_LIST_HEAD(&lio->lis_active);
-	io->ci_result = lov_io_slice_init(lio, lov, io);
-	if (io->ci_result)
-		return io->ci_result;
+	result = lov_io_slice_init(lio, lov, io);
+	if (result)
+		goto out;
 
-	io->ci_result = lov_io_subio_init(env, lio, io);
-	if (io->ci_result == 0) {
+	result = lov_io_subio_init(env, lio, io);
+	if (!result) {
 		cl_io_slice_add(io, &lio->lis_cl, obj, &lov_io_ops);
 		atomic_inc(&lov->lo_active_ios);
 	}
-	return io->ci_result;
+out:
+	io->ci_result = result < 0 ? result : 0;
+	return result;
 }
 
 int lov_io_init_empty(const struct lu_env *env, struct cl_object *obj,
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 131f1c9..951d501 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1015,6 +1015,7 @@ struct lov_mds_md_v1 {		/* LOV EA mds/wire data (little-endian) */
 #define XATTR_SECURITY_PREFIX	"security."
 #define XATTR_LUSTRE_PREFIX	"lustre."
 
+#define XATTR_NAME_SOM		"trusted.som"
 #define XATTR_NAME_LOV		"trusted.lov"
 #define XATTR_NAME_LMA		"trusted.lma"
 #define XATTR_NAME_LMV		"trusted.lmv"
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 34c86df..7d9f0d2 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -201,6 +201,17 @@ struct lustre_mdt_attrs {
  */
 #define LMA_OLD_SIZE (sizeof(struct lustre_mdt_attrs) + 5 * sizeof(__u64))
 
+enum {
+	LSOM_FL_VALID = 1 << 0,
+};
+
+struct lustre_som_attrs {
+	__u16	lsa_valid;
+	__u16	lsa_reserved[3];
+	__u64	lsa_size;
+	__u64	lsa_blocks;
+};
+
 /**
  * OST object IDentifier.
  */
-- 
1.8.3.1
