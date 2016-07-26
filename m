From: James Simmons <jsimmons@infradead.org>
Date: Tue, 26 Jul 2016 12:36:37 -0400
Subject: [lustre-devel] [PATCH v2 30/58] staging: lustre: create striped
	directory
In-Reply-To: <1469155491-15265-31-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-31-git-send-email-jsimmons@infradead.org>
Message-ID: <1469550997-2180-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

1. client send create request to the master MDT, which
  will allocate FIDs and create slaves. for all of slaves.

2. Client needs to revalidate slaves during intent getattr
   and open request.

3. lmv_stripe_md will include attributes(size, nlink etc)
   from all of stripe, which will be protected by UPDATE lock.
   client needs to merge these attributes when update inode.

4. send create request to the MDT where the file is located,
   which can help creating master stripe of striped directory.

Changelog

v1) Original submitted patch

v2) fixed lmv_hash_fnv1a function to use do_div64 to fix
    __umoddi3 undefined bug on 32 bit platforms.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3529
Reviewed-on: http://review.whamcloud.com/7196
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |    3 +
 .../lustre/lustre/include/lustre/lustre_idl.h      |   40 +++-
 .../lustre/lustre/include/lustre/lustre_user.h     |   16 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h |    2 +
 drivers/staging/lustre/lustre/include/lustre_lmv.h |   59 +++++
 drivers/staging/lustre/lustre/include/obd.h        |   16 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |   19 ++
 drivers/staging/lustre/lustre/llite/dir.c          |   26 ++-
 drivers/staging/lustre/lustre/llite/file.c         |   40 +++-
 .../staging/lustre/lustre/llite/llite_internal.h   |   12 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  193 +++++++++++++++-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |    7 +-
 drivers/staging/lustre/lustre/llite/namei.c        |   42 +++-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  244 +++++++++++++++++---
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |   32 +++
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  221 +++++++++++++++---
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |    3 +
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   11 +
 18 files changed, 880 insertions(+), 106 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 3cd4a25..0fa71a5 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -191,6 +191,9 @@ struct cl_attr {
 	 * Group identifier for quota purposes.
 	 */
 	gid_t  cat_gid;
+
+	/* nlink of the directory */
+	__u64  cat_nlink;
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 0ad6605..a612080 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1610,6 +1610,7 @@ static inline void lmm_oi_cpu_to_le(struct ost_id *dst_oi,
 #define XATTR_NAME_LOV	  "trusted.lov"
 #define XATTR_NAME_LMA	  "trusted.lma"
 #define XATTR_NAME_LMV	  "trusted.lmv"
+#define XATTR_NAME_DEFAULT_LMV	"trusted.dmv"
 #define XATTR_NAME_LINK	 "trusted.link"
 #define XATTR_NAME_FID	  "trusted.fid"
 #define XATTR_NAME_VERSION      "trusted.version"
@@ -2472,7 +2473,7 @@ struct lmv_desc {
 	__u32 ld_tgt_count;		/* how many MDS's */
 	__u32 ld_active_tgt_count;	 /* how many active */
 	__u32 ld_default_stripe_count;     /* how many objects are used */
-	__u32 ld_pattern;		  /* default MEA_MAGIC_* */
+	__u32 ld_pattern;		  /* default hash pattern */
 	__u64 ld_default_hash_size;
 	__u64 ld_padding_1;		/* also fix lustre_swab_lmv_desc */
 	__u32 ld_padding_2;		/* also fix lustre_swab_lmv_desc */
@@ -2486,6 +2487,43 @@ struct lmv_desc {
 #define LMV_MAGIC_V1	0x0CD10CD0	/* normal stripe lmv magic */
 #define LMV_USER_MAGIC	0x0CD20CD0	/* default lmv magic*/
 #define LMV_MAGIC	LMV_MAGIC_V1
+
+enum lmv_hash_type {
+	LMV_HASH_TYPE_ALL_CHARS = 1,
+	LMV_HASH_TYPE_FNV_1A_64 = 2,
+};
+
+#define LMV_HASH_NAME_ALL_CHARS		"all_char"
+#define LMV_HASH_NAME_FNV_1A_64		"fnv_1a_64"
+
+/**
+ * The FNV-1a hash algorithm is as follows:
+ *     hash = FNV_offset_basis
+ *     for each octet_of_data to be hashed
+ *             hash = hash XOR octet_of_data
+ *             hash = hash ?? FNV_prime
+ *     return hash
+ * http://en.wikipedia.org/wiki/Fowler???Noll???Vo_hash_function#FNV-1a_hash
+ *
+ * http://www.isthe.com/chongo/tech/comp/fnv/index.html#FNV-reference-source
+ * FNV_prime is 2^40 + 2^8 + 0xb3 = 0x100000001b3ULL
+ **/
+#define LUSTRE_FNV_1A_64_PRIME		0x100000001b3ULL
+#define LUSTRE_FNV_1A_64_OFFSET_BIAS	0xcbf29ce484222325ULL
+static inline __u64 lustre_hash_fnv_1a_64(const void *buf, size_t size)
+{
+	__u64 hash = LUSTRE_FNV_1A_64_OFFSET_BIAS;
+	const unsigned char *p = buf;
+	size_t i;
+
+	for (i = 0; i < size; i++) {
+		hash ^= p[i];
+		hash *= LUSTRE_FNV_1A_64_PRIME;
+	}
+
+	return hash;
+}
+
 struct lmv_mds_md_v1 {
 	__u32 lmv_magic;
 	__u32 lmv_stripe_count;		/* stripe count */
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index ef6f38f..d496d0e 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -374,19 +374,17 @@ struct lov_user_mds_data_v3 {
 } __packed;
 #endif
 
-/* keep this to be the same size as lov_user_ost_data_v1 */
 struct lmv_user_mds_data {
 	struct lu_fid	lum_fid;
 	__u32		lum_padding;
 	__u32		lum_mds;
 };
 
-/* lum_type */
-enum {
-	LMV_STRIPE_TYPE = 0,
-	LMV_DEFAULT_TYPE = 1,
-};
-
+/*
+ * Got this according to how get LOV_MAX_STRIPE_COUNT, see above,
+ * (max buffer size - lmv+rpc header) / sizeof(struct lmv_user_mds_data)
+ */
+#define LMV_MAX_STRIPE_COUNT 2000  /* ((12 * 4096 - 256) / 24) */
 #define lmv_user_md lmv_user_md_v1
 struct lmv_user_md_v1 {
 	__u32	lum_magic;	 /* must be the first field */
@@ -399,7 +397,7 @@ struct lmv_user_md_v1 {
 	__u32	lum_padding3;
 	char	lum_pool_name[LOV_MAXPOOLNAME];
 	struct	lmv_user_mds_data  lum_objects[0];
-};
+} __packed;
 
 static inline int lmv_user_md_size(int stripes, int lmm_magic)
 {
@@ -407,6 +405,8 @@ static inline int lmv_user_md_size(int stripes, int lmm_magic)
 		      stripes * sizeof(struct lmv_user_mds_data);
 }
 
+void lustre_swab_lmv_user_md(struct lmv_user_md *lum);
+
 struct ll_recreate_obj {
 	__u64 lrc_id;
 	__u32 lrc_ost_idx;
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index 06958f2..def0193 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -391,6 +391,8 @@ static inline void obd_ioctl_freedata(char *buf, int len)
 #define LOVEA_DELETE_VALUES(size, count, offset) (size == 0 && count == 0 && \
 						 offset == (typeof(offset))(-1))
 
+#define LMVEA_DELETE_VALUES(count, offset) ((count) == 0 && \
+					    (offset) == (typeof(offset))(-1))
 /* #define POISON_BULK 0 */
 
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
index 784d67b..4036fce 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lmv.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lmv.h
@@ -66,4 +66,63 @@ static inline void lmv_free_memmd(struct lmv_stripe_md *lsm)
 {
 	lmv_unpack_md(NULL, &lsm, NULL, 0);
 }
+
+static inline void lmv1_cpu_to_le(struct lmv_mds_md_v1 *lmv_dst,
+				  const struct lmv_mds_md_v1 *lmv_src)
+{
+	int i;
+
+	lmv_dst->lmv_magic = cpu_to_le32(lmv_src->lmv_magic);
+	lmv_dst->lmv_stripe_count = cpu_to_le32(lmv_src->lmv_stripe_count);
+	lmv_dst->lmv_master_mdt_index =
+		cpu_to_le32(lmv_src->lmv_master_mdt_index);
+	lmv_dst->lmv_hash_type = cpu_to_le32(lmv_src->lmv_hash_type);
+	lmv_dst->lmv_layout_version = cpu_to_le32(lmv_src->lmv_layout_version);
+
+	for (i = 0; i < lmv_src->lmv_stripe_count; i++)
+		fid_cpu_to_le(&lmv_dst->lmv_stripe_fids[i],
+			      &lmv_src->lmv_stripe_fids[i]);
+}
+
+static inline void lmv1_le_to_cpu(struct lmv_mds_md_v1 *lmv_dst,
+				  const struct lmv_mds_md_v1 *lmv_src)
+{
+	int i;
+
+	lmv_dst->lmv_magic = le32_to_cpu(lmv_src->lmv_magic);
+	lmv_dst->lmv_stripe_count = le32_to_cpu(lmv_src->lmv_stripe_count);
+	lmv_dst->lmv_master_mdt_index =
+		le32_to_cpu(lmv_src->lmv_master_mdt_index);
+	lmv_dst->lmv_hash_type = le32_to_cpu(lmv_src->lmv_hash_type);
+	lmv_dst->lmv_layout_version = le32_to_cpu(lmv_src->lmv_layout_version);
+
+	for (i = 0; i < lmv_src->lmv_stripe_count; i++)
+		fid_le_to_cpu(&lmv_dst->lmv_stripe_fids[i],
+			      &lmv_src->lmv_stripe_fids[i]);
+}
+
+static inline void lmv_cpu_to_le(union lmv_mds_md *lmv_dst,
+				 const union lmv_mds_md *lmv_src)
+{
+	switch (lmv_src->lmv_magic) {
+	case LMV_MAGIC_V1:
+		lmv1_cpu_to_le(&lmv_dst->lmv_md_v1, &lmv_src->lmv_md_v1);
+		break;
+	default:
+		break;
+	}
+}
+
+static inline void lmv_le_to_cpu(union lmv_mds_md *lmv_dst,
+				 const union lmv_mds_md *lmv_src)
+{
+	switch (le32_to_cpu(lmv_src->lmv_magic)) {
+	case LMV_MAGIC_V1:
+		lmv1_le_to_cpu(&lmv_dst->lmv_md_v1, &lmv_src->lmv_md_v1);
+		break;
+	default:
+		break;
+	}
+}
+
 #endif
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 17b8d22..a9f4e13 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -1022,14 +1022,6 @@ enum {
 };
 
 /* lmv structures */
-#define MEA_MAGIC_LAST_CHAR      0xb2221ca1
-#define MEA_MAGIC_ALL_CHARS      0xb222a11c
-#define MEA_MAGIC_HASH_SEGMENT   0xb222a11b
-
-#define MAX_HASH_SIZE_32	 0x7fffffffUL
-#define MAX_HASH_SIZE	    0x7fffffffffffffffULL
-#define MAX_HASH_HIGHEST_BIT     0x1000000000000000ULL
-
 struct lustre_md {
 	struct mdt_body	 *body;
 	struct lov_stripe_md    *lsm;
@@ -1049,6 +1041,7 @@ struct md_open_data {
 };
 
 struct lookup_intent;
+struct cl_attr;
 
 struct md_ops {
 	int (*getstatus)(struct obd_export *, struct lu_fid *);
@@ -1109,6 +1102,13 @@ struct md_ops {
 
 	int (*free_lustre_md)(struct obd_export *, struct lustre_md *);
 
+	int (*merge_attr)(struct obd_export *,
+			  const struct lmv_stripe_md *lsm,
+			  struct cl_attr *attr);
+
+	int (*update_lsm_md)(struct obd_export *, struct lmv_stripe_md *lsm,
+			     struct mdt_body *, ldlm_blocking_callback);
+
 	int (*set_open_replay_data)(struct obd_export *,
 				    struct obd_client_handle *,
 				    struct lookup_intent *);
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 6482a93..2f111a8 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1559,6 +1559,25 @@ static inline int md_free_lustre_md(struct obd_export *exp,
 	return MDP(exp->exp_obd, free_lustre_md)(exp, md);
 }
 
+static inline int md_update_lsm_md(struct obd_export *exp,
+				   struct lmv_stripe_md *lsm,
+				   struct mdt_body *body,
+				   ldlm_blocking_callback cb)
+{
+	EXP_CHECK_MD_OP(exp, update_lsm_md);
+	EXP_MD_COUNTER_INCREMENT(exp, update_lsm_md);
+	return MDP(exp->exp_obd, update_lsm_md)(exp, lsm, body, cb);
+}
+
+static inline int md_merge_attr(struct obd_export *exp,
+				const struct lmv_stripe_md *lsm,
+				struct cl_attr *attr)
+{
+	EXP_CHECK_MD_OP(exp, merge_attr);
+	EXP_MD_COUNTER_INCREMENT(exp, merge_attr);
+	return MDP(exp->exp_obd, merge_attr)(exp, lsm, attr);
+}
+
 static inline int md_setxattr(struct obd_export *exp, const struct lu_fid *fid,
 			      u64 valid, const char *name,
 			      const char *input, int input_size,
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index a72b486..a0560b6 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -668,7 +668,7 @@ static int ll_send_mgc_param(struct obd_export *mgc, char *string)
 }
 
 static int ll_dir_setdirstripe(struct inode *dir, struct lmv_user_md *lump,
-			       char *filename)
+			       const char *filename)
 {
 	struct ptlrpc_request *request = NULL;
 	struct md_op_data *op_data;
@@ -676,6 +676,26 @@ static int ll_dir_setdirstripe(struct inode *dir, struct lmv_user_md *lump,
 	int mode;
 	int err;
 
+	if (unlikely(lump->lum_magic != LMV_USER_MAGIC))
+		return -EINVAL;
+
+	if (lump->lum_stripe_offset == (__u32)-1) {
+		int mdtidx;
+
+		mdtidx = ll_get_mdt_idx(dir);
+		if (mdtidx < 0)
+			return mdtidx;
+
+		lump->lum_stripe_offset = mdtidx;
+	}
+
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p) name %s stripe_offset %d, stripe_count: %u\n",
+	       PFID(ll_inode2fid(dir)), dir, filename,
+	       (int)lump->lum_stripe_offset, lump->lum_stripe_count);
+
+	if (lump->lum_magic != cpu_to_le32(LMV_USER_MAGIC))
+		lustre_swab_lmv_user_md(lump);
+
 	mode = (~current_umask() & 0755) | S_IFDIR;
 	op_data = ll_prep_md_op_data(NULL, dir, NULL, filename,
 				     strlen(filename), mode, LUSTRE_OPC_MKDIR,
@@ -745,9 +765,6 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	if (lump && lump->lmm_magic == cpu_to_le32(LMV_USER_MAGIC))
-		op_data->op_cli_flags |= CLI_SET_MEA;
-
 	/* swabbing is done in lov_setstripe() on server side */
 	rc = md_setattr(sbi->ll_md_exp, op_data, lump, lum_size,
 			NULL, 0, &req, NULL);
@@ -1424,7 +1441,6 @@ lmv_out_free:
 		}
 
 		*tmp = lum;
-		tmp->lum_type = LMV_STRIPE_TYPE;
 		tmp->lum_stripe_count = 1;
 		mdtindex = ll_get_mdt_idx(inode);
 		if (mdtindex < 0) {
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 58a7401..18fb713 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3015,6 +3015,27 @@ out:
 	return rc;
 }
 
+static int ll_merge_md_attr(struct inode *inode)
+{
+	struct cl_attr attr = { 0 };
+	int rc;
+
+	LASSERT(ll_i2info(inode)->lli_lsm_md);
+	rc = md_merge_attr(ll_i2mdexp(inode), ll_i2info(inode)->lli_lsm_md,
+			   &attr);
+	if (rc)
+		return rc;
+
+	ll_i2info(inode)->lli_stripe_dir_size = attr.cat_size;
+	ll_i2info(inode)->lli_stripe_dir_nlink = attr.cat_nlink;
+
+	ll_i2info(inode)->lli_atime = attr.cat_atime;
+	ll_i2info(inode)->lli_mtime = attr.cat_mtime;
+	ll_i2info(inode)->lli_ctime = attr.cat_ctime;
+
+	return 0;
+}
+
 static int ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 {
 	struct inode *inode = d_inode(dentry);
@@ -3026,6 +3047,13 @@ static int ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 
 	/* if object isn't regular file, don't validate size */
 	if (!S_ISREG(inode->i_mode)) {
+		if (S_ISDIR(inode->i_mode) &&
+		    ll_i2info(inode)->lli_lsm_md) {
+			rc = ll_merge_md_attr(inode);
+			if (rc)
+				return rc;
+		}
+
 		LTIME_S(inode->i_atime) = ll_i2info(inode)->lli_atime;
 		LTIME_S(inode->i_mtime) = ll_i2info(inode)->lli_mtime;
 		LTIME_S(inode->i_ctime) = ll_i2info(inode)->lli_ctime;
@@ -3063,7 +3091,6 @@ int ll_getattr(struct vfsmount *mnt, struct dentry *de, struct kstat *stat)
 	else
 		stat->ino = inode->i_ino;
 	stat->mode = inode->i_mode;
-	stat->nlink = inode->i_nlink;
 	stat->uid = inode->i_uid;
 	stat->gid = inode->i_gid;
 	stat->rdev = inode->i_rdev;
@@ -3071,10 +3098,17 @@ int ll_getattr(struct vfsmount *mnt, struct dentry *de, struct kstat *stat)
 	stat->mtime = inode->i_mtime;
 	stat->ctime = inode->i_ctime;
 	stat->blksize = 1 << inode->i_blkbits;
-
-	stat->size = i_size_read(inode);
 	stat->blocks = inode->i_blocks;
 
+	if (S_ISDIR(inode->i_mode) &&
+	    ll_i2info(inode)->lli_lsm_md) {
+		stat->nlink = lli->lli_stripe_dir_nlink;
+		stat->size = lli->lli_stripe_dir_size;
+	} else {
+		stat->nlink = inode->i_nlink;
+		stat->size = i_size_read(inode);
+	}
+
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 07b6918..f3b8504 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -39,6 +39,7 @@
 
 /* for struct cl_lock_descr and struct cl_io */
 #include "../include/cl_object.h"
+#include "../include/lustre_lmv.h"
 #include "../include/lustre_mdc.h"
 #include "../include/lustre_intent.h"
 #include <linux/compat.h>
@@ -174,7 +175,11 @@ struct ll_inode_info {
 			 */
 			pid_t			   d_opendir_pid;
 			/* directory stripe information */
-			struct lmv_stripe_md		*d_lmv_md;
+			struct lmv_stripe_md		*d_lsm_md;
+			/* striped directory size */
+			loff_t				d_stripe_size;
+			/* striped directory nlink */
+			__u64				d_stripe_nlink;
 		} d;
 
 #define lli_readdir_mutex       u.d.d_readdir_mutex
@@ -182,7 +187,9 @@ struct ll_inode_info {
 #define lli_sai		 u.d.d_sai
 #define lli_sa_lock	     u.d.d_sa_lock
 #define lli_opendir_pid	 u.d.d_opendir_pid
-#define lli_lmv_md		u.d.d_lmv_md
+#define lli_lsm_md		u.d.d_lsm_md
+#define lli_stripe_dir_size	u.d.d_stripe_size
+#define lli_stripe_dir_nlink	u.d.d_stripe_nlink
 
 		/* for non-directory */
 		struct {
@@ -664,6 +671,7 @@ int ll_objects_destroy(struct ptlrpc_request *request,
 		       struct inode *dir);
 struct inode *ll_iget(struct super_block *sb, ino_t hash,
 		      struct lustre_md *lic);
+int ll_test_inode_by_fid(struct inode *inode, void *opaque);
 int ll_md_blocking_ast(struct ldlm_lock *, struct ldlm_lock_desc *,
 		       void *data, int flag);
 struct dentry *ll_splice_alias(struct inode *inode, struct dentry *de);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index eb715be..ef8d87a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -992,6 +992,188 @@ struct inode *ll_inode_from_resource_lock(struct ldlm_lock *lock)
 	return inode;
 }
 
+static void ll_dir_clear_lsm_md(struct inode *inode)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+
+	LASSERT(S_ISDIR(inode->i_mode));
+
+	if (lli->lli_lsm_md) {
+		lmv_free_memmd(lli->lli_lsm_md);
+		lli->lli_lsm_md = NULL;
+	}
+}
+
+static struct inode *ll_iget_anon_dir(struct super_block *sb,
+				      const struct lu_fid *fid,
+				      struct lustre_md *md)
+{
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
+	struct mdt_body *body = md->body;
+	struct inode *inode;
+	ino_t ino;
+
+	ino = cl_fid_build_ino(fid, sbi->ll_flags & LL_SBI_32BIT_API);
+	inode = iget_locked(sb, ino);
+	if (!inode) {
+		CERROR("%s: failed get simple inode "DFID": rc = -ENOENT\n",
+		       ll_get_fsname(sb, NULL, 0), PFID(fid));
+		return ERR_PTR(-ENOENT);
+	}
+
+	if (inode->i_state & I_NEW) {
+		struct ll_inode_info *lli = ll_i2info(inode);
+		struct lmv_stripe_md *lsm = md->lmv;
+
+		inode->i_mode = (inode->i_mode & ~S_IFMT) |
+				(body->mode & S_IFMT);
+		LASSERTF(S_ISDIR(inode->i_mode), "Not slave inode "DFID"\n",
+			 PFID(fid));
+
+		LTIME_S(inode->i_mtime) = 0;
+		LTIME_S(inode->i_atime) = 0;
+		LTIME_S(inode->i_ctime) = 0;
+		inode->i_rdev = 0;
+
+		inode->i_op = &ll_dir_inode_operations;
+		inode->i_fop = &ll_dir_operations;
+		lli->lli_fid = *fid;
+		ll_lli_init(lli);
+
+		LASSERT(lsm);
+		/* master stripe FID */
+		lli->lli_pfid = lsm->lsm_md_oinfo[0].lmo_fid;
+		CDEBUG(D_INODE, "lli %p master "DFID" slave "DFID"\n",
+		       lli, PFID(fid), PFID(&lli->lli_pfid));
+		unlock_new_inode(inode);
+	}
+
+	return inode;
+}
+
+static int ll_init_lsm_md(struct inode *inode, struct lustre_md *md)
+{
+	struct lmv_stripe_md *lsm = md->lmv;
+	struct lu_fid *fid;
+	int i;
+
+	LASSERT(lsm);
+	/*
+	 * XXX sigh, this lsm_root initialization should be in
+	 * LMV layer, but it needs ll_iget right now, so we
+	 * put this here right now.
+	 */
+	for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
+		fid = &lsm->lsm_md_oinfo[i].lmo_fid;
+		LASSERT(!lsm->lsm_md_oinfo[i].lmo_root);
+		if (!i) {
+			lsm->lsm_md_oinfo[i].lmo_root = inode;
+		} else {
+			/*
+			 * Unfortunately ll_iget will call ll_update_inode,
+			 * where the initialization of slave inode is slightly
+			 * different, so it reset lsm_md to NULL to avoid
+			 * initializing lsm for slave inode.
+			 */
+			lsm->lsm_md_oinfo[i].lmo_root =
+				ll_iget_anon_dir(inode->i_sb, fid, md);
+			if (IS_ERR(lsm->lsm_md_oinfo[i].lmo_root)) {
+				int rc = PTR_ERR(lsm->lsm_md_oinfo[i].lmo_root);
+
+				lsm->lsm_md_oinfo[i].lmo_root = NULL;
+				return rc;
+			}
+		}
+	}
+
+	/*
+	 * Here is where the lsm is being initialized(fill lmo_info) after
+	 * client retrieve MD stripe information from MDT.
+	 */
+	return md_update_lsm_md(ll_i2mdexp(inode), lsm, md->body,
+				ll_md_blocking_ast);
+}
+
+static inline int lli_lsm_md_eq(const struct lmv_stripe_md *lsm_md1,
+				const struct lmv_stripe_md *lsm_md2)
+{
+	return lsm_md1->lsm_md_magic == lsm_md2->lsm_md_magic &&
+	       lsm_md1->lsm_md_stripe_count == lsm_md2->lsm_md_stripe_count &&
+	       lsm_md1->lsm_md_master_mdt_index ==
+			lsm_md2->lsm_md_master_mdt_index &&
+	       lsm_md1->lsm_md_hash_type == lsm_md2->lsm_md_hash_type &&
+	       lsm_md1->lsm_md_layout_version ==
+			lsm_md2->lsm_md_layout_version &&
+	       !strcmp(lsm_md1->lsm_md_pool_name,
+		       lsm_md2->lsm_md_pool_name);
+}
+
+static void ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct lmv_stripe_md *lsm = md->lmv;
+	int idx;
+
+	LASSERT(lsm);
+	LASSERT(S_ISDIR(inode->i_mode));
+	if (!lli->lli_lsm_md) {
+		int rc;
+
+		rc = ll_init_lsm_md(inode, md);
+		if (rc) {
+			CERROR("%s: init "DFID" failed: rc = %d\n",
+			       ll_get_fsname(inode->i_sb, NULL, 0),
+			       PFID(&lli->lli_fid), rc);
+			return;
+		}
+		lli->lli_lsm_md = lsm;
+		/*
+		 * set lsm_md to NULL, so the following free lustre_md
+		 * will not free this lsm
+		 */
+		md->lmv = NULL;
+		return;
+	}
+
+	/* Compare the old and new stripe information */
+	if (!lli_lsm_md_eq(lli->lli_lsm_md, lsm)) {
+		CERROR("inode %p %lu mismatch\n"
+		       "    new(%p)     vs     lli_lsm_md(%p):\n"
+		       "    magic:      %x                   %x\n"
+		       "    count:      %x                   %x\n"
+		       "    master:     %x                   %x\n"
+		       "    hash_type:  %x                   %x\n"
+		       "    layout:     %x                   %x\n"
+		       "    pool:       %s                   %s\n",
+		       inode, inode->i_ino, lsm, lli->lli_lsm_md,
+		       lsm->lsm_md_magic, lli->lli_lsm_md->lsm_md_magic,
+		       lsm->lsm_md_stripe_count,
+		       lli->lli_lsm_md->lsm_md_stripe_count,
+		       lsm->lsm_md_master_mdt_index,
+		       lli->lli_lsm_md->lsm_md_master_mdt_index,
+		       lsm->lsm_md_hash_type, lli->lli_lsm_md->lsm_md_hash_type,
+		       lsm->lsm_md_layout_version,
+		       lli->lli_lsm_md->lsm_md_layout_version,
+		       lsm->lsm_md_pool_name,
+		       lli->lli_lsm_md->lsm_md_pool_name);
+		return;
+	}
+
+	for (idx = 0; idx < lli->lli_lsm_md->lsm_md_stripe_count; idx++) {
+		if (!lu_fid_eq(&lli->lli_lsm_md->lsm_md_oinfo[idx].lmo_fid,
+			       &lsm->lsm_md_oinfo[idx].lmo_fid)) {
+			CERROR("%s: FID in lsm mismatch idx %d, old: "DFID" new:"DFID"\n",
+			       ll_get_fsname(inode->i_sb, NULL, 0), idx,
+			       PFID(&lli->lli_lsm_md->lsm_md_oinfo[idx].lmo_fid),
+			       PFID(&lsm->lsm_md_oinfo[idx].lmo_fid));
+			return;
+		}
+	}
+
+	md_update_lsm_md(ll_i2mdexp(inode), ll_i2info(inode)->lli_lsm_md,
+			 md->body, ll_md_blocking_ast);
+}
+
 void ll_clear_inode(struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -1039,7 +1221,9 @@ void ll_clear_inode(struct inode *inode)
 #endif
 	lli->lli_inode_magic = LLI_INODE_DEAD;
 
-	if (!S_ISDIR(inode->i_mode))
+	if (S_ISDIR(inode->i_mode))
+		ll_dir_clear_lsm_md(inode);
+	else
 		LASSERT(list_empty(&lli->lli_agl_list));
 
 	/*
@@ -1484,6 +1668,9 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 			lli->lli_maxbytes = MAX_LFS_FILESIZE;
 	}
 
+	if (S_ISDIR(inode->i_mode) && md->lmv)
+		ll_update_lsm_md(inode, md);
+
 #ifdef CONFIG_FS_POSIX_ACL
 	if (body->valid & OBD_MD_FLACL) {
 		spin_lock(&lli->lli_lock);
@@ -2091,12 +2278,12 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 	ll_i2gids(op_data->op_suppgids, i1, i2);
 	op_data->op_fid1 = *ll_inode2fid(i1);
 	if (S_ISDIR(i1->i_mode))
-		op_data->op_mea1 = ll_i2info(i1)->lli_lmv_md;
+		op_data->op_mea1 = ll_i2info(i1)->lli_lsm_md;
 
 	if (i2) {
 		op_data->op_fid2 = *ll_inode2fid(i2);
 		if (S_ISDIR(i2->i_mode))
-			op_data->op_mea2 = ll_i2info(i2)->lli_lmv_md;
+			op_data->op_mea2 = ll_i2info(i2)->lli_lsm_md;
 	} else {
 		fid_zero(&op_data->op_fid2);
 	}
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 74eb1fc..ab9d5cc 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -73,11 +73,6 @@ void get_uuid2fsid(const char *name, int len, __kernel_fsid_t *fsid)
 	fsid->val[1] = key >> 32;
 }
 
-static int ll_nfs_test_inode(struct inode *inode, void *opaque)
-{
-	return lu_fid_eq(&ll_i2info(inode)->lli_fid, opaque);
-}
-
 struct inode *search_inode_for_lustre(struct super_block *sb,
 				      const struct lu_fid *fid)
 {
@@ -92,7 +87,7 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 
 	CDEBUG(D_INFO, "searching inode for:(%lu,"DFID")\n", hash, PFID(fid));
 
-	inode = ilookup5(sb, hash, ll_nfs_test_inode, (void *)fid);
+	inode = ilookup5(sb, hash, ll_test_inode_by_fid, (void *)fid);
 	if (inode)
 		return inode;
 
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 1e75f5b..e32d08b 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -158,6 +158,11 @@ static void ll_invalidate_negative_children(struct inode *dir)
 	spin_unlock(&dir->i_lock);
 }
 
+int ll_test_inode_by_fid(struct inode *inode, void *opaque)
+{
+	return lu_fid_eq(&ll_i2info(inode)->lli_fid, opaque);
+}
+
 int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		       void *data, int flag)
 {
@@ -253,10 +258,41 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		}
 
 		if ((bits & MDS_INODELOCK_UPDATE) && S_ISDIR(inode->i_mode)) {
-			CDEBUG(D_INODE, "invalidating inode "DFID"\n",
-			       PFID(ll_inode2fid(inode)));
+			struct ll_inode_info *lli = ll_i2info(inode);
+
+			CDEBUG(D_INODE, "invalidating inode "DFID" lli = %p, pfid  = "DFID"\n",
+			       PFID(ll_inode2fid(inode)), lli,
+			       PFID(&lli->lli_pfid));
+
 			truncate_inode_pages(inode->i_mapping, 0);
-			ll_invalidate_negative_children(inode);
+
+			if (unlikely(!fid_is_zero(&lli->lli_pfid))) {
+				struct inode *master_inode = NULL;
+				unsigned long hash;
+
+				/*
+				 * This is slave inode, since all of the child
+				 * dentry is connected on the master inode, so
+				 * we have to invalidate the negative children
+				 * on master inode
+				 */
+				CDEBUG(D_INODE, "Invalidate s"DFID" m"DFID"\n",
+				       PFID(ll_inode2fid(inode)),
+				       PFID(&lli->lli_pfid));
+
+				hash = cl_fid_build_ino(&lli->lli_pfid,
+							ll_need_32bit_api(ll_i2sbi(inode)));
+
+				master_inode = ilookup5(inode->i_sb, hash,
+							ll_test_inode_by_fid,
+							(void *)&lli->lli_pfid);
+				if (master_inode && !IS_ERR(master_inode)) {
+					ll_invalidate_negative_children(master_inode);
+					iput(master_inode);
+				}
+			} else {
+				ll_invalidate_negative_children(inode);
+			}
 		}
 
 		if ((bits & (MDS_INODELOCK_LOOKUP | MDS_INODELOCK_PERM)) &&
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 2f58fda..1b9bbb2 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -150,6 +150,160 @@ out:
 	return rc;
 }
 
+int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
+			  struct lmv_stripe_md *lsm,
+			  ldlm_blocking_callback cb_blocking,
+			  int extra_lock_flags)
+{
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct mdt_body *body;
+	struct md_op_data *op_data;
+	unsigned long size = 0;
+	unsigned long nlink = 0;
+	__s64 atime = 0;
+	__s64 ctime = 0;
+	__s64 mtime = 0;
+	int rc = 0, i;
+
+	/**
+	 * revalidate slaves has some problems, temporarily return,
+	 * we may not need that
+	 */
+	if (lsm->lsm_md_stripe_count <= 1)
+		return 0;
+
+	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
+	if (!op_data)
+		return -ENOMEM;
+
+	/**
+	 * Loop over the stripe information, check validity and update them
+	 * from MDS if needed.
+	 */
+	for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
+		struct lookup_intent it = { .it_op = IT_GETATTR };
+		struct ptlrpc_request *req = NULL;
+		struct lustre_handle *lockh = NULL;
+		struct lmv_tgt_desc *tgt = NULL;
+		struct inode *inode;
+		struct lu_fid fid;
+
+		fid = lsm->lsm_md_oinfo[i].lmo_fid;
+		inode = lsm->lsm_md_oinfo[i].lmo_root;
+		if (!i) {
+			if (mbody) {
+				body = mbody;
+				goto update;
+			} else {
+				goto release_lock;
+			}
+		}
+
+		/*
+		 * Prepare op_data for revalidating. Note that @fid2 shluld be
+		 * defined otherwise it will go to server and take new lock
+		 * which is not needed here.
+		 */
+		memset(op_data, 0, sizeof(*op_data));
+		op_data->op_fid1 = fid;
+		op_data->op_fid2 = fid;
+
+		tgt = lmv_locate_mds(lmv, op_data, &fid);
+		if (IS_ERR(tgt)) {
+			rc = PTR_ERR(tgt);
+			goto cleanup;
+		}
+
+		CDEBUG(D_INODE, "Revalidate slave "DFID" -> mds #%d\n",
+		       PFID(&fid), tgt->ltd_idx);
+
+		rc = md_intent_lock(tgt->ltd_exp, op_data, NULL, 0, &it, 0,
+				    &req, cb_blocking, extra_lock_flags);
+		if (rc < 0)
+			goto cleanup;
+
+		lockh = (struct lustre_handle *)&it.it_lock_handle;
+		if (rc > 0 && !req) {
+			/* slave inode is still valid */
+			CDEBUG(D_INODE, "slave "DFID" is still valid.\n",
+			       PFID(&fid));
+			rc = 0;
+		} else {
+			/* refresh slave from server */
+			body = req_capsule_server_get(&req->rq_pill,
+						      &RMF_MDT_BODY);
+			LASSERT(body);
+update:
+			if (unlikely(body->nlink < 2)) {
+				CERROR("%s: nlink %d < 2 corrupt stripe %d "DFID":" DFID"\n",
+				       obd->obd_name, body->nlink, i,
+				       PFID(&lsm->lsm_md_oinfo[i].lmo_fid),
+				       PFID(&lsm->lsm_md_oinfo[0].lmo_fid));
+
+				if (req)
+					ptlrpc_req_finished(req);
+
+				rc = -EIO;
+				goto cleanup;
+			}
+
+			if (i)
+				md_set_lock_data(tgt->ltd_exp, &lockh->cookie,
+						 inode, NULL);
+
+			i_size_write(inode, body->size);
+			set_nlink(inode, body->nlink);
+			LTIME_S(inode->i_atime) = body->atime;
+			LTIME_S(inode->i_ctime) = body->ctime;
+			LTIME_S(inode->i_mtime) = body->mtime;
+
+			if (req)
+				ptlrpc_req_finished(req);
+		}
+release_lock:
+		size += i_size_read(inode);
+
+		if (i != 0)
+			nlink += inode->i_nlink - 2;
+		else
+			nlink += inode->i_nlink;
+
+		atime = LTIME_S(inode->i_atime) > atime ?
+				LTIME_S(inode->i_atime) : atime;
+		ctime = LTIME_S(inode->i_ctime) > ctime ?
+				LTIME_S(inode->i_ctime) : ctime;
+		mtime = LTIME_S(inode->i_mtime) > mtime ?
+				LTIME_S(inode->i_mtime) : mtime;
+
+		if (it.it_lock_mode && lockh) {
+			ldlm_lock_decref(lockh, it.it_lock_mode);
+			it.it_lock_mode = 0;
+		}
+
+		CDEBUG(D_INODE, "i %d "DFID" size %llu, nlink %u, atime %lu, mtime %lu, ctime %lu.\n",
+		       i, PFID(&fid), i_size_read(inode), inode->i_nlink,
+		       LTIME_S(inode->i_atime), LTIME_S(inode->i_mtime),
+		       LTIME_S(inode->i_ctime));
+	}
+
+	/*
+	 * update attr of master request.
+	 */
+	CDEBUG(D_INODE, "Return refreshed attrs: size = %lu nlink %lu atime %llu ctime %llu mtime %llu for " DFID"\n",
+	       size, nlink, atime, ctime, mtime,
+	       PFID(&lsm->lsm_md_oinfo[0].lmo_fid));
+
+	if (mbody) {
+		mbody->atime = atime;
+		mbody->ctime = ctime;
+		mbody->mtime = mtime;
+	}
+cleanup:
+	kfree(op_data);
+	return rc;
+}
+
 /*
  * IT_OPEN is intended to open (and create, possible) an object. Parent (pid)
  * may be split dir.
@@ -166,9 +320,26 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	struct mdt_body		*body;
 	int			rc;
 
-	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
-	if (IS_ERR(tgt))
-		return PTR_ERR(tgt);
+	if (it->it_flags & MDS_OPEN_BY_FID && fid_is_sane(&op_data->op_fid2)) {
+		if (op_data->op_mea1) {
+			struct lmv_stripe_md *lsm = op_data->op_mea1;
+			const struct lmv_oinfo *oinfo;
+
+			oinfo = lsm_name_to_stripe_info(lsm, op_data->op_name,
+							op_data->op_namelen);
+			op_data->op_fid1 = oinfo->lmo_fid;
+		}
+
+		tgt = lmv_find_target(lmv, &op_data->op_fid2);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
+
+		op_data->op_mds = tgt->ltd_idx;
+	} else {
+		tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
+	}
 
 	/* If it is ready to open the file by FID, do not need
 	 * allocate FID at all, otherwise it will confuse MDT
@@ -205,31 +376,18 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	body = req_capsule_server_get(&(*reqp)->rq_pill, &RMF_MDT_BODY);
 	if (!body)
 		return -EPROTO;
-	/*
-	 * Not cross-ref case, just get out of here.
-	 */
-	if (likely(!(body->valid & OBD_MD_MDS)))
-		return 0;
 
-	/*
-	 * Okay, MDS has returned success. Probably name has been resolved in
-	 * remote inode.
-	 */
-	rc = lmv_intent_remote(exp, lmm, lmmsize, it, &op_data->op_fid1, flags,
-			       reqp, cb_blocking, extra_lock_flags);
-	if (rc != 0) {
-		LASSERT(rc < 0);
-		/*
-		 * This is possible, that some userspace application will try to
-		 * open file as directory and we will have -ENOTDIR here. As
-		 * this is normal situation, we should not print error here,
-		 * only debug info.
-		 */
-		CDEBUG(D_INODE, "Can't handle remote %s: dir " DFID "(" DFID "):%*s: %d\n",
-		       LL_IT2STR(it), PFID(&op_data->op_fid2),
-		       PFID(&op_data->op_fid1), op_data->op_namelen,
-		       op_data->op_name, rc);
-		return rc;
+	/* Not cross-ref case, just get out of here. */
+	if (unlikely((body->valid & OBD_MD_MDS))) {
+		rc = lmv_intent_remote(exp, lmm, lmmsize, it, &op_data->op_fid1,
+				       flags, reqp, cb_blocking,
+				       extra_lock_flags);
+		if (rc != 0)
+			return rc;
+
+		body = req_capsule_server_get(&(*reqp)->rq_pill, &RMF_MDT_BODY);
+		if (!body)
+			return -EPROTO;
 	}
 
 	return rc;
@@ -269,8 +427,23 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	rc = md_intent_lock(tgt->ltd_exp, op_data, lmm, lmmsize, it,
 			    flags, reqp, cb_blocking, extra_lock_flags);
 
-	if (rc < 0 || !*reqp)
+	if (rc < 0)
+		return rc;
+
+	if (!*reqp) {
+		/*
+		 * If RPC happens, lsm information will be revalidated
+		 * during update_inode process (see ll_update_lsm_md)
+		 */
+		if (op_data->op_mea2) {
+			rc = lmv_revalidate_slaves(exp, NULL, op_data->op_mea2,
+						   cb_blocking,
+						   extra_lock_flags);
+			if (rc != 0)
+				return rc;
+		}
 		return rc;
+	}
 
 	/*
 	 * MDS has returned success. Probably name has been resolved in
@@ -279,12 +452,17 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	body = req_capsule_server_get(&(*reqp)->rq_pill, &RMF_MDT_BODY);
 	if (!body)
 		return -EPROTO;
-	/* Not cross-ref case, just get out of here. */
-	if (likely(!(body->valid & OBD_MD_MDS)))
-		return 0;
 
-	rc = lmv_intent_remote(exp, lmm, lmmsize, it, NULL, flags, reqp,
-			       cb_blocking, extra_lock_flags);
+	/* Not cross-ref case, just get out of here. */
+	if (unlikely((body->valid & OBD_MD_MDS))) {
+		rc = lmv_intent_remote(exp, lmm, lmmsize, it, NULL, flags,
+				       reqp, cb_blocking, extra_lock_flags);
+		if (rc != 0)
+			return rc;
+		body = req_capsule_server_get(&(*reqp)->rq_pill, &RMF_MDT_BODY);
+		if (!body)
+			return -EPROTO;
+	}
 
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index f4c917b..ed02927 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -55,6 +55,14 @@ int __lmv_fid_alloc(struct lmv_obd *lmv, struct lu_fid *fid, u32 mds);
 int lmv_fid_alloc(struct obd_export *exp, struct lu_fid *fid,
 		  struct md_op_data *op_data);
 
+int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
+		  const union lmv_mds_md *lmm, int stripe_count);
+
+int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
+			  struct lmv_stripe_md *lsm,
+			  ldlm_blocking_callback cb_blocking,
+			  int extra_lock_flags);
+
 static inline struct lmv_tgt_desc *
 lmv_get_target(struct lmv_obd *lmv, u32 mds)
 {
@@ -94,6 +102,30 @@ static inline int lmv_stripe_md_size(int stripe_count)
 	return sizeof(*lsm) + stripe_count * sizeof(lsm->lsm_md_oinfo[0]);
 }
 
+int lmv_name_to_stripe_index(enum lmv_hash_type hashtype,
+			     unsigned int max_mdt_index,
+			     const char *name, int namelen);
+
+static inline const struct lmv_oinfo *
+lsm_name_to_stripe_info(const struct lmv_stripe_md *lsm, const char *name,
+			int namelen)
+{
+	int stripe_index;
+
+	stripe_index = lmv_name_to_stripe_index(lsm->lsm_md_hash_type,
+						lsm->lsm_md_stripe_count,
+						name, namelen);
+	if (stripe_index < 0)
+		return ERR_PTR(stripe_index);
+
+	LASSERTF(stripe_index < lsm->lsm_md_stripe_count,
+		 "stripe_index = %d, stripe_count = %d hash_type = %x name = %.*s\n",
+		 stripe_index, lsm->lsm_md_stripe_count,
+		 lsm->lsm_md_hash_type, namelen, name);
+
+	return &lsm->lsm_md_oinfo[stripe_index];
+}
+
 struct lmv_tgt_desc
 *lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
 		struct lu_fid *fid);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 6be2afc..da4855d 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -48,11 +48,63 @@
 #include "../include/obd_class.h"
 #include "../include/lustre_lmv.h"
 #include "../include/lprocfs_status.h"
+#include "../include/cl_object.h"
 #include "../include/lustre_lite.h"
 #include "../include/lustre_fid.h"
 #include "../include/lustre_kernelcomm.h"
 #include "lmv_internal.h"
 
+/* This hash is only for testing purpose */
+static inline unsigned int
+lmv_hash_all_chars(unsigned int count, const char *name, int namelen)
+{
+	const unsigned char *p = (const unsigned char *)name;
+	unsigned int c = 0;
+
+	while (--namelen >= 0)
+		c += p[namelen];
+
+	c = c % count;
+
+	return c;
+}
+
+static inline unsigned int
+lmv_hash_fnv1a(unsigned int count, const char *name, int namelen)
+{
+	__u64 hash;
+
+	hash = lustre_hash_fnv_1a_64(name, namelen);
+
+	return do_div(hash, count);
+}
+
+int lmv_name_to_stripe_index(enum lmv_hash_type hashtype,
+			     unsigned int max_mdt_index,
+			     const char *name, int namelen)
+{
+	int idx;
+
+	LASSERT(namelen > 0);
+	if (max_mdt_index <= 1)
+		return 0;
+
+	switch (hashtype) {
+	case LMV_HASH_TYPE_ALL_CHARS:
+		idx = lmv_hash_all_chars(max_mdt_index, name, namelen);
+		break;
+	case LMV_HASH_TYPE_FNV_1A_64:
+		idx = lmv_hash_fnv1a(max_mdt_index, name, namelen);
+		break;
+	default:
+		CERROR("Unknown hash type 0x%x\n", hashtype);
+		return -EINVAL;
+	}
+
+	LASSERT(idx < max_mdt_index);
+	return idx;
+}
+
 static void lmv_activate_target(struct lmv_obd *lmv,
 				struct lmv_tgt_desc *tgt,
 				int activate)
@@ -1174,28 +1226,19 @@ static int lmv_placement_policy(struct obd_device *obd,
 	 * If stripe_offset is provided during setdirstripe
 	 * (setdirstripe -i xx), xx MDS will be chosen.
 	 */
-	if (op_data->op_cli_flags & CLI_SET_MEA) {
+	if (op_data->op_cli_flags & CLI_SET_MEA && op_data->op_data) {
 		struct lmv_user_md *lum;
 
-		lum = (struct lmv_user_md *)op_data->op_data;
-		if (lum->lum_type == LMV_STRIPE_TYPE &&
-		    lum->lum_stripe_offset != -1) {
-			if (lum->lum_stripe_offset >= lmv->desc.ld_tgt_count) {
-				CERROR("%s: Stripe_offset %d > MDT count %d: rc = %d\n",
-				       obd->obd_name,
-				       lum->lum_stripe_offset,
-				       lmv->desc.ld_tgt_count, -ERANGE);
-				return -ERANGE;
-			}
-			*mds = lum->lum_stripe_offset;
-			return 0;
-		}
+		lum = op_data->op_data;
+		*mds = lum->lum_stripe_offset;
+	} else {
+		/*
+		 * Allocate new fid on target according to operation type and
+		 * parent home mds.
+		 */
+		*mds = op_data->op_mds;
 	}
 
-	/* Allocate new fid on target according to operation type and parent
-	 * home mds.
-	 */
-	*mds = op_data->op_mds;
 	return 0;
 }
 
@@ -1597,17 +1640,38 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 	return rc;
 }
 
+/**
+ * Choosing the MDT by name or FID in @op_data.
+ * For non-striped directory, it will locate MDT by fid.
+ * For striped-directory, it will locate MDT by name. And also
+ * it will reset op_fid1 with the FID of the chosen stripe.
+ **/
 struct lmv_tgt_desc
 *lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
 		struct lu_fid *fid)
 {
+	struct lmv_stripe_md *lsm = op_data->op_mea1;
+	const struct lmv_oinfo *oinfo;
 	struct lmv_tgt_desc *tgt;
 
-	tgt = lmv_find_target(lmv, fid);
-	if (IS_ERR(tgt))
+	if (!lsm || lsm->lsm_md_stripe_count <= 1 ||
+	    !op_data->op_namelen) {
+		tgt = lmv_find_target(lmv, fid);
+		if (IS_ERR(tgt))
+			return tgt;
+
+		op_data->op_mds = tgt->ltd_idx;
+
 		return tgt;
+	}
 
-	op_data->op_mds = tgt->ltd_idx;
+	oinfo = lsm_name_to_stripe_info(lsm, op_data->op_name,
+					op_data->op_namelen);
+	*fid = oinfo->lmo_fid;
+	op_data->op_mds = oinfo->lmo_mds;
+	tgt = lmv_get_target(lmv, op_data->op_mds);
+
+	CDEBUG(D_INFO, "locate on mds %u\n", op_data->op_mds);
 
 	return tgt;
 }
@@ -1633,13 +1697,26 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
+	CDEBUG(D_INODE, "CREATE name '%.*s' on "DFID" -> mds #%x\n",
+	       op_data->op_namelen, op_data->op_name, PFID(&op_data->op_fid1),
+	       op_data->op_mds);
+
 	rc = lmv_fid_alloc(exp, &op_data->op_fid2, op_data);
 	if (rc)
 		return rc;
 
-	CDEBUG(D_INODE, "CREATE '%*s' on "DFID" -> mds #%x\n",
-	       op_data->op_namelen, op_data->op_name, PFID(&op_data->op_fid1),
-	       op_data->op_mds);
+	/*
+	 * Send the create request to the MDT where the object
+	 * will be located
+	 */
+	tgt = lmv_find_target(lmv, &op_data->op_fid2);
+	if (IS_ERR(tgt))
+		return PTR_ERR(tgt);
+
+	op_data->op_mds = tgt->ltd_idx;
+
+	CDEBUG(D_INODE, "CREATE obj "DFID" -> mds #%x\n",
+	       PFID(&op_data->op_fid1), op_data->op_mds);
 
 	op_data->op_flags |= MF_MDC_CANCEL_FID1;
 	rc = md_create(tgt->ltd_exp, op_data, data, datalen, mode, uid, gid,
@@ -1889,6 +1966,15 @@ static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
 	op_data->op_cap = cfs_curproc_cap_pack();
+	if (op_data->op_mea2) {
+		struct lmv_stripe_md *lsm = op_data->op_mea2;
+		const struct lmv_oinfo *oinfo;
+
+		oinfo = lsm_name_to_stripe_info(lsm, op_data->op_name,
+						op_data->op_namelen);
+		op_data->op_fid2 = oinfo->lmo_fid;
+	}
+
 	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid2);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
@@ -1914,14 +2000,15 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	struct obd_device       *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc     *src_tgt;
-	struct lmv_tgt_desc     *tgt_tgt;
 	int			rc;
 
 	LASSERT(oldlen != 0);
 
-	CDEBUG(D_INODE, "RENAME %*s in "DFID" to %*s in "DFID"\n",
+	CDEBUG(D_INODE, "RENAME %.*s in "DFID":%d to %.*s in "DFID":%d\n",
 	       oldlen, old, PFID(&op_data->op_fid1),
-	       newlen, new, PFID(&op_data->op_fid2));
+	       op_data->op_mea1 ? op_data->op_mea1->lsm_md_stripe_count : 0,
+	       newlen, new, PFID(&op_data->op_fid2),
+	       op_data->op_mea2 ? op_data->op_mea2->lsm_md_stripe_count : 0);
 
 	rc = lmv_check_connect(obd);
 	if (rc)
@@ -1930,13 +2017,33 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
 	op_data->op_cap = cfs_curproc_cap_pack();
-	src_tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
-	if (IS_ERR(src_tgt))
-		return PTR_ERR(src_tgt);
 
-	tgt_tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid2);
-	if (IS_ERR(tgt_tgt))
-		return PTR_ERR(tgt_tgt);
+	if (op_data->op_mea1) {
+		struct lmv_stripe_md *lsm = op_data->op_mea1;
+		const struct lmv_oinfo *oinfo;
+
+		oinfo = lsm_name_to_stripe_info(lsm, old, oldlen);
+		op_data->op_fid1 = oinfo->lmo_fid;
+		op_data->op_mds = oinfo->lmo_mds;
+		src_tgt = lmv_get_target(lmv, op_data->op_mds);
+		if (IS_ERR(src_tgt))
+			return PTR_ERR(src_tgt);
+	} else {
+		src_tgt = lmv_find_target(lmv, &op_data->op_fid1);
+		if (IS_ERR(src_tgt))
+			return PTR_ERR(src_tgt);
+
+		op_data->op_mds = src_tgt->ltd_idx;
+	}
+
+	if (op_data->op_mea2) {
+		struct lmv_stripe_md *lsm = op_data->op_mea2;
+		const struct lmv_oinfo *oinfo;
+
+		oinfo = lsm_name_to_stripe_info(lsm, new, newlen);
+		op_data->op_fid2 = oinfo->lmo_fid;
+	}
+
 	/*
 	 * LOOKUP lock on src child (fid3) should also be cancelled for
 	 * src_tgt in mdc_rename.
@@ -2568,6 +2675,7 @@ int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 	}
 	return lsm_size;
 }
+EXPORT_SYMBOL(lmv_unpack_md);
 
 int lmv_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
 		 struct lov_mds_md *lmm, int disk_len)
@@ -2741,7 +2849,7 @@ static int lmv_intent_getattr_async(struct obd_export *exp,
 	if (rc)
 		return rc;
 
-	tgt = lmv_find_target(lmv, &op_data->op_fid1);
+	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -2843,6 +2951,49 @@ static int lmv_quotacheck(struct obd_device *unused, struct obd_export *exp,
 	return rc;
 }
 
+int lmv_update_lsm_md(struct obd_export *exp, struct lmv_stripe_md *lsm,
+		      struct mdt_body *body, ldlm_blocking_callback cb_blocking)
+{
+	if (lsm->lsm_md_stripe_count <= 1)
+		return 0;
+
+	return lmv_revalidate_slaves(exp, body, lsm, cb_blocking, 0);
+}
+
+int lmv_merge_attr(struct obd_export *exp, const struct lmv_stripe_md *lsm,
+		   struct cl_attr *attr)
+{
+	int i;
+
+	for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
+		struct inode *inode = lsm->lsm_md_oinfo[i].lmo_root;
+
+		CDEBUG(D_INFO, ""DFID" size %llu, nlink %u, atime %lu ctime %lu, mtime %lu.\n",
+		       PFID(&lsm->lsm_md_oinfo[i].lmo_fid),
+		       i_size_read(inode), inode->i_nlink,
+		       LTIME_S(inode->i_atime), LTIME_S(inode->i_ctime),
+		       LTIME_S(inode->i_mtime));
+
+		/* for slave stripe, it needs to subtract nlink for . and .. */
+		if (i)
+			attr->cat_nlink += inode->i_nlink - 2;
+		else
+			attr->cat_nlink = inode->i_nlink;
+
+		attr->cat_size += i_size_read(inode);
+
+		if (attr->cat_atime < LTIME_S(inode->i_atime))
+			attr->cat_atime = LTIME_S(inode->i_atime);
+
+		if (attr->cat_ctime < LTIME_S(inode->i_ctime))
+			attr->cat_ctime = LTIME_S(inode->i_ctime);
+
+		if (attr->cat_mtime < LTIME_S(inode->i_mtime))
+			attr->cat_mtime = LTIME_S(inode->i_mtime);
+	}
+	return 0;
+}
+
 static struct obd_ops lmv_obd_ops = {
 	.owner		= THIS_MODULE,
 	.setup		= lmv_setup,
@@ -2888,6 +3039,8 @@ static struct md_ops lmv_md_ops = {
 	.lock_match		= lmv_lock_match,
 	.get_lustre_md		= lmv_get_lustre_md,
 	.free_lustre_md		= lmv_free_lustre_md,
+	.update_lsm_md		= lmv_update_lsm_md,
+	.merge_attr		= lmv_merge_attr,
 	.set_open_replay_data	= lmv_set_open_replay_data,
 	.clear_open_replay_data	= lmv_clear_open_replay_data,
 	.intent_getattr_async	= lmv_intent_getattr_async,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 06a1274..626fce5 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -325,6 +325,9 @@ static struct ptlrpc_request *mdc_intent_open_pack(struct obd_export *exp,
 	mdc_open_pack(req, op_data, it->it_create_mode, 0, it->it_flags, lmm,
 		      lmmsize);
 
+	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
+			     obddev->u.cli.cl_max_mds_easize);
+
 	ptlrpc_request_set_replen(req);
 	return req;
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index b514f18..07e23d1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1878,6 +1878,17 @@ void lustre_swab_lov_desc(struct lov_desc *ld)
 }
 EXPORT_SYMBOL(lustre_swab_lov_desc);
 
+void lustre_swab_lmv_user_md(struct lmv_user_md *lum)
+{
+	__swab32s(&lum->lum_magic);
+	__swab32s(&lum->lum_stripe_count);
+	__swab32s(&lum->lum_stripe_offset);
+	__swab32s(&lum->lum_hash_type);
+	__swab32s(&lum->lum_type);
+	CLASSERT(offsetof(typeof(*lum), lum_padding1));
+}
+EXPORT_SYMBOL(lustre_swab_lmv_user_md);
+
 static void print_lum(struct lov_user_md *lum)
 {
 	CDEBUG(D_OTHER, "lov_user_md %p:\n", lum);
-- 
1.7.1
