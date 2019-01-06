From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 16:36:37 -0500
Subject: [lustre-devel] [PATCH 04/14] lustre: llite: improve getdirstripe
 interface
In-Reply-To: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
References: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546810607-6348-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

The user land lustre tools added the ability to choose the DNE2
hashing algorithm. Handle the hash values coming from user land.

Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
WC-bug-id: https://jira.hpdd.intel.com/browse/LU-8314
Reviewed-on: https://review.whamcloud.com/24319
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/uapi/linux/lustre/lustre_idl.h    | 12 ++++++++++++
 .../staging/lustre/include/uapi/linux/lustre/lustre_user.h   |  2 ++
 drivers/staging/lustre/lustre/llite/dir.c                    |  1 +
 3 files changed, 15 insertions(+)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index 26646f9..a42ce9d 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -1968,6 +1968,18 @@ static inline int lmv_mds_md_stripe_count_get(const union lmv_mds_md *lmm)
 	}
 }
 
+static inline int lmv_mds_md_hash_type_get(const union lmv_mds_md *lmm)
+{
+	switch (__le32_to_cpu(lmm->lmv_magic)) {
+	case LMV_MAGIC_V1:
+		return __le32_to_cpu(lmm->lmv_md_v1.lmv_hash_type);
+	case LMV_USER_MAGIC:
+		return __le32_to_cpu(lmm->lmv_user_md.lum_hash_type);
+	default:
+		return -EINVAL;
+	}
+}
+
 enum fld_rpc_opc {
 	FLD_QUERY	= 900,
 	FLD_READ	= 901,
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index 6904d6d..4412dc8 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -443,6 +443,8 @@ enum lmv_hash_type {
 	LMV_HASH_TYPE_FNV_1A_64 = 2,
 };
 
+#define LMV_HASH_TYPE_MAX	LMV_HASH_TYPE_FNV_1A_64 + 1
+
 #define LMV_HASH_NAME_ALL_CHARS		"all_char"
 #define LMV_HASH_NAME_FNV_1A_64		"fnv_1a_64"
 
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index f1c1c9c..86b5c7a 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1315,6 +1315,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		tmp->lum_magic = LMV_MAGIC_V1;
 		tmp->lum_stripe_count = 0;
 		tmp->lum_stripe_offset = mdt_index;
+		tmp->lum_hash_type = lmv_mds_md_hash_type_get(lmm);
 		for (i = 0; i < stripe_count; i++) {
 			struct lu_fid fid;
 
-- 
1.8.3.1
