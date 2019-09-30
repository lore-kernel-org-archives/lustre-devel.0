From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:53 -0400
Subject: [lustre-devel] [PATCH 094/151] lustre: dne: allow mkdir with
 specific MDTs
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-95-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Silimiar to create file on specific OSTs, allow 'lfs mkdir' to mkdir
on specific MDTs. This is achieved by allowing 'lfs mkdir -i' specify
multiple MDTs, and adding LMV_USER_MAGIC_SPECIFIC.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8616
Lustre-commit: 087ec276de0b ("LU-8616 dne: allow mkdir with specific MDTs")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30566
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                   | 17 ++++++++++-------
 fs/lustre/ptlrpc/pack_generic.c         | 23 +++++++++++++++++++++++
 include/uapi/linux/lustre/lustre_user.h |  2 ++
 3 files changed, 35 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 8968110..8556fa2 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -402,7 +402,7 @@ static int ll_send_mgc_param(struct obd_export *mgc, char *string)
  *		<0 if the creation is failed.
  */
 static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
-			       const char *dirname, umode_t mode)
+			       size_t len, const char *dirname, umode_t mode)
 {
 	struct inode *parent = dparent->d_inode;
 	struct ptlrpc_request *request = NULL;
@@ -420,7 +420,8 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	};
 	int err;
 
-	if (unlikely(lump->lum_magic != LMV_USER_MAGIC))
+	if (unlikely(lump->lum_magic != LMV_USER_MAGIC &&
+		     lump->lum_magic != LMV_USER_MAGIC_SPECIFIC))
 		return -EINVAL;
 
 	CDEBUG(D_VFSTRACE,
@@ -432,7 +433,8 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	    !(exp_connect_flags(sbi->ll_md_exp) & OBD_CONNECT_DIR_STRIPE))
 		return -EINVAL;
 
-	if (lump->lum_magic != cpu_to_le32(LMV_USER_MAGIC))
+	if (lump->lum_magic != cpu_to_le32(LMV_USER_MAGIC) &&
+	    lump->lum_magic != cpu_to_le32(LMV_USER_MAGIC_SPECIFIC))
 		lustre_swab_lmv_user_md(lump);
 
 	if (!IS_POSIXACL(parent) || !exp_connect_umask(ll_i2mdexp(parent)))
@@ -459,7 +461,7 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	}
 
 	op_data->op_cli_flags |= CLI_SET_MEA;
-	err = md_create(sbi->ll_md_exp, op_data, lump, sizeof(*lump), mode,
+	err = md_create(sbi->ll_md_exp, op_data, lump, len, mode,
 			from_kuid(&init_user_ns, current_fsuid()),
 			from_kgid(&init_user_ns, current_fsgid()),
 			current_cap(), 0, &request);
@@ -1184,8 +1186,9 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		lum = (struct lmv_user_md *)data->ioc_inlbuf2;
 		lumlen = data->ioc_inllen2;
 
-		if (lum->lum_magic != LMV_USER_MAGIC ||
-		    lumlen != sizeof(*lum)) {
+		if ((lum->lum_magic != LMV_USER_MAGIC &&
+		     lum->lum_magic != LMV_USER_MAGIC_SPECIFIC) ||
+		    lumlen < sizeof(*lum)) {
 			CERROR("%s: wrong lum magic %x or size %d: rc = %d\n",
 			       filename, lum->lum_magic, lumlen, -EFAULT);
 			rc = -EINVAL;
@@ -1197,7 +1200,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 #else
 		mode = data->ioc_type;
 #endif
-		rc = ll_dir_setdirstripe(dentry, lum, filename, mode);
+		rc = ll_dir_setdirstripe(dentry, lum, lumlen, filename, mode);
 lmv_out_free:
 		kvfree(data);
 		return rc;
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 7fa2cf7..b9dd3abe 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1960,14 +1960,37 @@ void lustre_swab_lmv_mds_md(union lmv_mds_md *lmm)
 }
 EXPORT_SYMBOL(lustre_swab_lmv_mds_md);
 
+void lustre_swab_lmv_user_md_objects(struct lmv_user_mds_data *lmd,
+				     int stripe_count)
+{
+	int i;
+
+	for (i = 0; i < stripe_count; i++)
+		__swab32s(&(lmd[i].lum_mds));
+}
+EXPORT_SYMBOL(lustre_swab_lmv_user_md_objects);
+
+
 void lustre_swab_lmv_user_md(struct lmv_user_md *lum)
 {
+	u32 count = lum->lum_stripe_count;
+
 	__swab32s(&lum->lum_magic);
 	__swab32s(&lum->lum_stripe_count);
 	__swab32s(&lum->lum_stripe_offset);
 	__swab32s(&lum->lum_hash_type);
 	__swab32s(&lum->lum_type);
 	BUILD_BUG_ON(!offsetof(typeof(*lum), lum_padding1));
+	switch (lum->lum_magic) {
+	case LMV_USER_MAGIC_SPECIFIC:
+		count = lum->lum_stripe_count;
+		/* fallthrough */
+	case __swab32(LMV_USER_MAGIC_SPECIFIC):
+		lustre_swab_lmv_user_md_objects(lum->lum_objects, count);
+		break;
+	default:
+		break;
+	}
 }
 EXPORT_SYMBOL(lustre_swab_lmv_user_md);
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index e9bb3d6..7a44038 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -365,8 +365,10 @@ struct ll_ioc_lease {
 #define LOV_USER_MAGIC_COMP_V1	0x0BD60BD0
 
 #define LMV_USER_MAGIC		0x0CD30CD0	/*default lmv magic*/
+#define LMV_USER_MAGIC_SPECIFIC	0x0CD40CD0
 
 #define LOV_PATTERN_RAID0	0x001
+
 #define LOV_PATTERN_RAID1	0x002
 #define LOV_PATTERN_MDT		0x100
 #define LOV_PATTERN_CMOBD	0x200
-- 
1.8.3.1
