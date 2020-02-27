From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:14 -0500
Subject: [lustre-devel] [PATCH 386/622] lustre: uapi: change "space" hash
 type to hash flag
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-387-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Change LMV_HASH_TYPE_SPACE to LMV_HASH_FLAG_SPACE to make it flexible
in directory layout inheritance in the future. But it's still exposed
to user as hash type "space" in "lfs setdirstripe" command to make
it easy to understand.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11213
Lustre-commit: c605ef1dbeb4 ("LU-11213 uapi: change "space" hash type to hash flag")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35318
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_lmv.h          |  5 ++---
 fs/lustre/lmv/lmv_obd.c                 |  4 ++--
 fs/lustre/ptlrpc/wiretest.c             |  2 +-
 include/uapi/linux/lustre/lustre_idl.h  | 10 ----------
 include/uapi/linux/lustre/lustre_user.h | 35 ++++++++++++++++++++++++++-------
 5 files changed, 33 insertions(+), 23 deletions(-)

diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index bb1efb4..b33a6ed 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -55,7 +55,6 @@ struct lmv_stripe_md {
 	struct lmv_oinfo lsm_md_oinfo[0];
 };
 
-/* NB: LMV_HASH_TYPE_SPACE is set in default LMV only */
 static inline bool lmv_is_known_hash_type(u32 type)
 {
 	return (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_FNV_1A_64 ||
@@ -91,9 +90,9 @@ static inline bool lmv_dir_bad_hash(const struct lmv_stripe_md *lsm)
 }
 
 /* NB, this is checking directory default LMV */
-static inline bool lmv_dir_space_hashed(const struct lmv_stripe_md *lsm)
+static inline bool lmv_dir_qos_mkdir(const struct lmv_stripe_md *lsm)
 {
-	return lsm && lsm->lsm_md_hash_type == LMV_HASH_TYPE_SPACE;
+	return lsm && (lsm->lsm_md_hash_type & LMV_HASH_FLAG_SPACE);
 }
 
 static inline bool
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index bd64ebc..ae799db 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1187,7 +1187,7 @@ static u32 lmv_placement_policy(struct obd_device *obd,
 		mdt = le32_to_cpu(lum->lum_stripe_offset);
 	} else if (op_data->op_code == LUSTRE_OPC_MKDIR &&
 		   !lmv_dir_striped(op_data->op_mea1) &&
-		   lmv_dir_space_hashed(op_data->op_default_mea1)) {
+		   lmv_dir_qos_mkdir(op_data->op_default_mea1)) {
 		mdt = op_data->op_mds;
 	} else if (op_data->op_code == LUSTRE_OPC_MKDIR &&
 		   op_data->op_default_mea1 &&
@@ -1716,7 +1716,7 @@ struct lmv_tgt_desc *
 		op_data->op_mds = oinfo->lmo_mds;
 		tgt = lmv_get_target(lmv, oinfo->lmo_mds, NULL);
 	} else if (op_data->op_code == LUSTRE_OPC_MKDIR &&
-		   lmv_dir_space_hashed(op_data->op_default_mea1) &&
+		   lmv_dir_qos_mkdir(op_data->op_default_mea1) &&
 		   !lmv_dir_striped(lsm)) {
 		tgt = lmv_locate_tgt_qos(lmv, &op_data->op_mds);
 		if (tgt == ERR_PTR(-EAGAIN))
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index adc71ff..1d34b15 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1661,8 +1661,8 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(LMV_MAGIC_V1 != 0x0CD20CD0);
 	BUILD_BUG_ON(LMV_MAGIC_STRIPE != 0x0CD40CD0);
 	BUILD_BUG_ON(LMV_HASH_TYPE_MASK != 0x0000ffff);
+	BUILD_BUG_ON(LMV_HASH_FLAG_SPACE != 0x08000000);
 	BUILD_BUG_ON(LMV_HASH_FLAG_MIGRATION != 0x80000000);
-	BUILD_BUG_ON(LMV_HASH_FLAG_DEAD != 0x40000000);
 
 	/* Checks for struct obd_statfs */
 	LASSERTF((int)sizeof(struct obd_statfs) == 144, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 5acf781..5740d42 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2001,16 +2001,6 @@ struct lmv_foreign_md {
 #define LMV_MAGIC_STRIPE 0x0CD40CD0	/* magic for dir sub_stripe */
 #define LMV_MAGIC_FOREIGN 0x0CD50CD0	/* magic for lmv foreign */
 
-/*
- *Right now only the lower part(0-16bits) of lmv_hash_type is being used,
- * and the higher part will be the flag to indicate the status of object,
- * for example the object is being migrated. And the hash function
- * might be interpreted differently with different flags.
- */
-#define LMV_HASH_TYPE_MASK		0x0000ffff
-
-#define LMV_HASH_FLAG_MIGRATION		0x80000000
-#define LMV_HASH_FLAG_DEAD		0x40000000
 
 /**
  * The FNV-1a hash algorithm is as follows:
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index d43170f..86f3111 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -655,16 +655,37 @@ enum lmv_hash_type {
 	LMV_HASH_TYPE_UNKNOWN	= 0,	/* 0 is reserved for testing purpose */
 	LMV_HASH_TYPE_ALL_CHARS = 1,
 	LMV_HASH_TYPE_FNV_1A_64 = 2,
-	LMV_HASH_TYPE_SPACE	= 3,	/*
-					 * distribute subdirs among all MDTs
-					 * with balanced space usage.
-					 */
 	LMV_HASH_TYPE_MAX,
 };
 
-#define LMV_HASH_NAME_ALL_CHARS		"all_char"
-#define LMV_HASH_NAME_FNV_1A_64		"fnv_1a_64"
-#define LMV_HASH_NAME_SPACE		"space"
+#define LMV_HASH_TYPE_DEFAULT LMV_HASH_TYPE_FNV_1A_64
+
+#define LMV_HASH_NAME_ALL_CHARS	"all_char"
+#define LMV_HASH_NAME_FNV_1A_64	"fnv_1a_64"
+
+/* not real hash type, but exposed to user as "space" hash type */
+#define LMV_HASH_NAME_SPACE	"space"
+
+/* Right now only the lower part(0-16bits) of lmv_hash_type is being used,
+ * and the higher part will be the flag to indicate the status of object,
+ * for example the object is being migrated. And the hash function
+ * might be interpreted differently with different flags.
+ */
+#define LMV_HASH_TYPE_MASK		0x0000ffff
+
+/* once this is set on a plain directory default layout, newly created
+ * subdirectories will be distributed on all MDTs by space usage.
+ */
+#define LMV_HASH_FLAG_SPACE		0x08000000
+
+/* The striped directory has ever lost its master LMV EA, then LFSCK
+ * re-generated it. This flag is used to indicate such case. It is an
+ * on-disk flag.
+ */
+#define LMV_HASH_FLAG_LOST_LMV		0x10000000
+
+#define LMV_HASH_FLAG_BAD_TYPE		0x20000000
+#define LMV_HASH_FLAG_MIGRATION		0x80000000
 
 struct lustre_foreign_type {
 	uint32_t lft_type;
-- 
1.8.3.1
