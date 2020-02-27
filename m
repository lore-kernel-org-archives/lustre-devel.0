From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:54 -0500
Subject: [lustre-devel] [PATCH 306/622] lustre: dne: add new dir hash type
 "space"
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-307-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Add a new hash type "space", if this is set on default LMV of
a directory, its subdirs will be created on all MDTs with
balanced space usage.

* new hash type LMV_HASH_TYPE_SPACE.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11213
Lustre-commit: a24f61532927 ("LU-11213 dne: add new dir hash type "space"")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34358
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_user.h | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index dc39265..22a0144 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -650,12 +650,16 @@ enum lmv_hash_type {
 	LMV_HASH_TYPE_UNKNOWN	= 0,	/* 0 is reserved for testing purpose */
 	LMV_HASH_TYPE_ALL_CHARS = 1,
 	LMV_HASH_TYPE_FNV_1A_64 = 2,
+	LMV_HASH_TYPE_SPACE	= 3,	/*
+					 * distribute subdirs among all MDTs
+					 * with balanced space usage.
+					 */
+	LMV_HASH_TYPE_MAX,
 };
 
-#define LMV_HASH_TYPE_MAX	LMV_HASH_TYPE_FNV_1A_64 + 1
-
 #define LMV_HASH_NAME_ALL_CHARS		"all_char"
 #define LMV_HASH_NAME_FNV_1A_64		"fnv_1a_64"
+#define LMV_HASH_NAME_SPACE		"space"
 
 struct lustre_foreign_type {
 	uint32_t lft_type;
@@ -685,7 +689,7 @@ struct lmv_user_md_v1 {
 	__u32	lum_stripe_count;	/* dirstripe count */
 	__u32	lum_stripe_offset;	/* MDT idx for default dirstripe */
 	__u32	lum_hash_type;		/* Dir stripe policy */
-	__u32	lum_type;		/* LMV type: default or normal */
+	__u32	lum_type;		/* LMV type: default */
 	__u32	lum_padding1;
 	__u32	lum_padding2;
 	__u32	lum_padding3;
@@ -703,6 +707,15 @@ static inline __u32 lmv_foreign_to_md_stripes(__u32 size)
 	       sizeof(struct lmv_user_mds_data);
 }
 
+/*
+ * NB, historically default layout didn't set type, but use XATTR name to differ
+ * from normal layout, for backward compatibility, define LMV_TYPE_DEFAULT 0x0,
+ * and still use the same method.
+ */
+enum lmv_type {
+	LMV_TYPE_DEFAULT = 0x0000,
+};
+
 static inline int lmv_user_md_size(int stripes, int lmm_magic)
 {
 	int size = sizeof(struct lmv_user_md);
-- 
1.8.3.1
