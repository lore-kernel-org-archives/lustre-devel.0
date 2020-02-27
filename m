From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:34 -0500
Subject: [lustre-devel] [PATCH 406/622] lustre: llite: swab LOV EA user data
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-407-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jian Yu <yujian@whamcloud.com>

Many sub-tests failed with "Invalid argument" failures
on PPC client because of the endianness issue.

This patch fixes the issue by adding a common function
lustre_swab_lov_user_md() to swab the LOV EA user data.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10100
Lustre-commit: 9d17996766e0 ("LU-10100 llite: swab LOV EA user data")
Signed-off-by: Jian Yu <yujian@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35291
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_swab.h |  1 +
 fs/lustre/llite/dir.c           | 65 ++++++++++--------------------------
 fs/lustre/llite/file.c          | 46 ++++++++++++-------------
 fs/lustre/llite/llite_lib.c     |  4 +--
 fs/lustre/llite/xattr.c         | 25 ++++++++++++--
 fs/lustre/ptlrpc/pack_generic.c | 74 +++++++++++++++++++++++++++++++++--------
 6 files changed, 126 insertions(+), 89 deletions(-)

diff --git a/fs/lustre/include/lustre_swab.h b/fs/lustre/include/lustre_swab.h
index 7e96640..e99e16d 100644
--- a/fs/lustre/include/lustre_swab.h
+++ b/fs/lustre/include/lustre_swab.h
@@ -86,6 +86,7 @@
 void lustre_swab_lov_comp_md_v1(struct lov_comp_md_v1 *lum);
 void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
 				     int stripe_count);
+void lustre_swab_lov_user_md(struct lov_user_md *lum);
 void lustre_swab_lov_mds_md(struct lov_mds_md *lmm);
 void lustre_swab_lustre_capa(struct lustre_capa *c);
 void lustre_swab_lustre_capa_key(struct lustre_capa_key *k);
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 2c39579..f87ddd2 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -525,60 +525,46 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 	int lum_size;
 
 	if (lump) {
-		/*
-		 * This is coming from userspace, so should be in
-		 * local endian.  But the MDS would like it in little
-		 * endian, so we swab it before we send it.
-		 */
 		switch (lump->lmm_magic) {
-		case LOV_USER_MAGIC_V1: {
-			if (lump->lmm_magic != cpu_to_le32(LOV_USER_MAGIC_V1))
-				lustre_swab_lov_user_md_v1(lump);
+		case LOV_USER_MAGIC_V1:
 			lum_size = sizeof(struct lov_user_md_v1);
 			break;
-		}
-		case LOV_USER_MAGIC_V3: {
-			if (lump->lmm_magic != cpu_to_le32(LOV_USER_MAGIC_V3))
-				lustre_swab_lov_user_md_v3((struct lov_user_md_v3 *)lump);
+		case LOV_USER_MAGIC_V3:
 			lum_size = sizeof(struct lov_user_md_v3);
 			break;
-		}
-		case LOV_USER_MAGIC_COMP_V1: {
-			if (lump->lmm_magic !=
-			    cpu_to_le32(LOV_USER_MAGIC_COMP_V1))
-				lustre_swab_lov_comp_md_v1((struct lov_comp_md_v1 *)lump);
-			lum_size = le32_to_cpu(((struct lov_comp_md_v1 *)lump)->lcm_size);
+		case LOV_USER_MAGIC_COMP_V1:
+			lum_size = ((struct lov_comp_md_v1 *)lump)->lcm_size;
 			break;
-		}
-		case LMV_USER_MAGIC: {
+		case LMV_USER_MAGIC:
 			if (lump->lmm_magic != cpu_to_le32(LMV_USER_MAGIC))
 				lustre_swab_lmv_user_md((struct lmv_user_md *)lump);
 			lum_size = sizeof(struct lmv_user_md);
 			break;
-		}
 		case LOV_USER_MAGIC_SPECIFIC: {
 			struct lov_user_md_v3 *v3 =
-					(struct lov_user_md_v3 *)lump;
+				(struct lov_user_md_v3 *)lump;
 			if (v3->lmm_stripe_count > LOV_MAX_STRIPE_COUNT)
 				return -EINVAL;
-			if (lump->lmm_magic !=
-			    cpu_to_le32(LOV_USER_MAGIC_SPECIFIC)) {
-				lustre_swab_lov_user_md_v3(v3);
-				lustre_swab_lov_user_md_objects(v3->lmm_objects,
-						v3->lmm_stripe_count);
-			}
 			lum_size = lov_user_md_size(v3->lmm_stripe_count,
 						    LOV_USER_MAGIC_SPECIFIC);
 			break;
 		}
-		default: {
+		default:
 			CDEBUG(D_IOCTL,
 			       "bad userland LOV MAGIC: %#08x != %#08x nor %#08x\n",
 			       lump->lmm_magic, LOV_USER_MAGIC_V1,
 			       LOV_USER_MAGIC_V3);
 			return -EINVAL;
 		}
-		}
+
+		/*
+		 * This is coming from userspace, so should be in
+		 * local endian.  But the MDS would like it in little
+		 * endian, so we swab it before we send it.
+		 */
+		if ((__swab32(lump->lmm_magic) & le32_to_cpu(LOV_MAGIC_MASK)) ==
+		    le32_to_cpu(LOV_MAGIC_MAGIC))
+			lustre_swab_lov_user_md(lump);
 	} else {
 		lum_size = sizeof(struct lov_user_md_v1);
 	}
@@ -706,16 +692,11 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 	/* We don't swab objects for directories */
 	switch (le32_to_cpu(lmm->lmm_magic)) {
 	case LOV_MAGIC_V1:
-		if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC)
-			lustre_swab_lov_user_md_v1((struct lov_user_md_v1 *)lmm);
-		break;
 	case LOV_MAGIC_V3:
-		if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC)
-			lustre_swab_lov_user_md_v3((struct lov_user_md_v3 *)lmm);
-		break;
 	case LOV_MAGIC_COMP_V1:
+	case LOV_USER_MAGIC_SPECIFIC:
 		if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC)
-			lustre_swab_lov_comp_md_v1((struct lov_comp_md_v1 *)lmm);
+			lustre_swab_lov_user_md((struct lov_user_md *)lmm);
 		break;
 	case LMV_MAGIC_V1:
 		if (cpu_to_le32(LMV_MAGIC) != LMV_MAGIC)
@@ -725,16 +706,6 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 		if (cpu_to_le32(LMV_USER_MAGIC) != LMV_USER_MAGIC)
 			lustre_swab_lmv_user_md((struct lmv_user_md *)lmm);
 		break;
-	case LOV_USER_MAGIC_SPECIFIC: {
-		struct lov_user_md_v3 *v3 = (struct lov_user_md_v3 *)lmm;
-
-		if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC) {
-			lustre_swab_lov_user_md_v3(v3);
-			lustre_swab_lov_user_md_objects(v3->lmm_objects,
-							v3->lmm_stripe_count);
-			}
-		}
-		break;
 	case LMV_MAGIC_FOREIGN: {
 		struct lmv_foreign_md *lfm = (struct lmv_foreign_md *)lmm;
 
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index d313730..5a3e80e 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1852,6 +1852,12 @@ int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
 	};
 	int rc = 0;
 
+	if ((__swab32(lum->lmm_magic) & le32_to_cpu(LOV_MAGIC_MASK)) ==
+	    le32_to_cpu(LOV_MAGIC_MAGIC)) {
+		/* this code will only exist for big-endian systems */
+		lustre_swab_lov_user_md(lum);
+	}
+
 	ll_inode_size_lock(inode);
 	rc = ll_intent_file_open(dentry, lum, lum_size, &oit);
 	if (rc < 0)
@@ -1920,8 +1926,9 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 	 * little endian. We convert it to host endian before
 	 * passing it to userspace.
 	 */
-	if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC) {
-		int stripe_count;
+	if ((lmm->lmm_magic & __swab32(LOV_MAGIC_MAGIC)) ==
+	    __swab32(LOV_MAGIC_MAGIC)) {
+		int stripe_count = 0;
 
 		if (lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_V1) ||
 		    lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_V3)) {
@@ -1931,31 +1938,20 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 				stripe_count = 0;
 		}
 
+		lustre_swab_lov_user_md((struct lov_user_md *)lmm);
+
 		/* if function called for directory - we should
 		 * avoid swab not existent lsm objects
 		 */
-		if (lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_V1)) {
-			lustre_swab_lov_user_md_v1((struct lov_user_md_v1 *)lmm);
-			if (S_ISREG(body->mbo_mode))
-				lustre_swab_lov_user_md_objects(((struct lov_user_md_v1 *)lmm)->lmm_objects,
-								stripe_count);
-		} else if (lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_V3)) {
-			lustre_swab_lov_user_md_v3((struct lov_user_md_v3 *)lmm);
-			if (S_ISREG(body->mbo_mode))
-				lustre_swab_lov_user_md_objects(((struct lov_user_md_v3 *)lmm)->lmm_objects,
-								stripe_count);
-		} else if (lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_COMP_V1)) {
-			lustre_swab_lov_comp_md_v1((struct lov_comp_md_v1 *)lmm);
-		} else if (lmm->lmm_magic ==
-			   cpu_to_le32(LOV_MAGIC_FOREIGN)) {
-			struct lov_foreign_md *lfm;
-
-			lfm = (struct lov_foreign_md *)lmm;
-			__swab32s(&lfm->lfm_magic);
-			__swab32s(&lfm->lfm_length);
-			__swab32s(&lfm->lfm_type);
-			__swab32s(&lfm->lfm_flags);
-		}
+		if (lmm->lmm_magic == LOV_MAGIC_V1 && S_ISREG(body->mbo_mode))
+			lustre_swab_lov_user_md_objects(
+				((struct lov_user_md_v1 *)lmm)->lmm_objects,
+				stripe_count);
+		else if (lmm->lmm_magic == LOV_MAGIC_V3 &&
+			 S_ISREG(body->mbo_mode))
+			lustre_swab_lov_user_md_objects(
+				((struct lov_user_md_v3 *)lmm)->lmm_objects,
+				stripe_count);
 	}
 
 out:
@@ -2040,7 +2036,7 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 
 	cl_lov_delay_create_clear(&file->f_flags);
 out:
-	kfree(klum);
+	kvfree(klum);
 	return rc;
 }
 
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 3e058d2..86be562 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2757,14 +2757,14 @@ ssize_t ll_copy_user_md(const struct lov_user_md __user *md,
 	if (lum_size < 0)
 		goto no_kbuf;
 
-	*kbuf = kzalloc(lum_size, GFP_NOFS);
+	*kbuf = kvzalloc(lum_size, GFP_NOFS);
 	if (!*kbuf) {
 		lum_size = -ENOMEM;
 		goto no_kbuf;
 	}
 
 	if (copy_from_user(*kbuf, md, lum_size) != 0) {
-		kfree(*kbuf);
+		kvfree(*kbuf);
 		*kbuf = NULL;
 		lum_size = -EFAULT;
 	}
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index 9707e78..cf1cfd2 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -40,6 +40,7 @@
 
 #include <obd_support.h>
 #include <lustre_dlm.h>
+#include <lustre_swab.h>
 
 #include "llite_internal.h"
 
@@ -316,6 +317,11 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 		return 0;
 	}
 
+	if (strncmp(name, "lov.", 4) == 0 &&
+	    (__swab32(((struct lov_user_md *)value)->lmm_magic) &
+	    le32_to_cpu(LOV_MAGIC_MASK)) == le32_to_cpu(LOV_MAGIC_MAGIC))
+		lustre_swab_lov_user_md((struct lov_user_md *)value);
+
 	return ll_xattr_set_common(handler, dentry, inode, name, value, size,
 				   flags);
 }
@@ -485,10 +491,25 @@ static ssize_t ll_getxattr_lov(struct inode *inode, void *buf, size_t buf_size)
 		 * file is restored. See LU-2809.
 		 */
 		magic = ((struct lov_mds_md *)buf)->lmm_magic;
-		if (magic == LOV_MAGIC_COMP_V1 || magic == LOV_MAGIC_FOREIGN)
+		if ((magic & __swab32(LOV_MAGIC_MAGIC)) ==
+		    __swab32(LOV_MAGIC_MAGIC))
+			magic = __swab32(magic);
+
+		switch (magic) {
+		case LOV_MAGIC_V1:
+		case LOV_MAGIC_V3:
+		case LOV_MAGIC_SPECIFIC:
+			((struct lov_mds_md *)buf)->lmm_layout_gen = 0;
+			break;
+		case LOV_MAGIC_COMP_V1:
+		case LOV_MAGIC_FOREIGN:
+			goto out_env;
+		default:
+			CERROR("Invalid LOV magic %08x\n", magic);
+			rc = -EINVAL;
 			goto out_env;
+		}
 
-		((struct lov_mds_md *)buf)->lmm_layout_gen = 0;
 out_env:
 		cl_env_put(env, &refcheck);
 
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index f687ecc..7acb4a8 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -2004,6 +2004,8 @@ void lustre_swab_lmv_user_md(struct lmv_user_md *lum)
 	if (lum->lum_magic == LMV_MAGIC_FOREIGN) {
 		__swab32s(&lum->lum_magic);
 		__swab32s(&((struct lmv_foreign_md *)lum)->lfm_length);
+		__swab32s(&((struct lmv_foreign_md *)lum)->lfm_type);
+		__swab32s(&((struct lmv_foreign_md *)lum)->lfm_flags);
 		return;
 	}
 
@@ -2132,18 +2134,6 @@ void lustre_swab_lov_comp_md_v1(struct lov_comp_md_v1 *lum)
 }
 EXPORT_SYMBOL(lustre_swab_lov_comp_md_v1);
 
-void lustre_swab_lov_mds_md(struct lov_mds_md *lmm)
-{
-	CDEBUG(D_IOCTL, "swabbing lov_mds_md\n");
-	__swab32s(&lmm->lmm_magic);
-	__swab32s(&lmm->lmm_pattern);
-	lustre_swab_lmm_oi(&lmm->lmm_oi);
-	__swab32s(&lmm->lmm_stripe_size);
-	__swab16s(&lmm->lmm_stripe_count);
-	__swab16s(&lmm->lmm_layout_gen);
-}
-EXPORT_SYMBOL(lustre_swab_lov_mds_md);
-
 void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
 				     int stripe_count)
 {
@@ -2157,9 +2147,67 @@ void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
 }
 EXPORT_SYMBOL(lustre_swab_lov_user_md_objects);
 
+void lustre_swab_lov_user_md(struct lov_user_md *lum)
+{
+	CDEBUG(D_IOCTL, "swabbing lov_user_md\n");
+	switch (lum->lmm_magic) {
+	case __swab32(LOV_MAGIC_V1):
+	case LOV_USER_MAGIC_V1:
+		lustre_swab_lov_user_md_v1((struct lov_user_md_v1 *)lum);
+		break;
+	case __swab32(LOV_MAGIC_V3):
+	case LOV_USER_MAGIC_V3:
+		lustre_swab_lov_user_md_v3((struct lov_user_md_v3 *)lum);
+		break;
+	case __swab32(LOV_USER_MAGIC_SPECIFIC):
+	case LOV_USER_MAGIC_SPECIFIC:
+	{
+		struct lov_user_md_v3 *v3 = (struct lov_user_md_v3 *)lum;
+		u16 stripe_count = v3->lmm_stripe_count;
+
+		if (lum->lmm_magic != LOV_USER_MAGIC_SPECIFIC)
+			__swab16s(&stripe_count);
+
+		lustre_swab_lov_user_md_v3(v3);
+		lustre_swab_lov_user_md_objects(v3->lmm_objects, stripe_count);
+		break;
+	}
+	case __swab32(LOV_MAGIC_COMP_V1):
+	case LOV_USER_MAGIC_COMP_V1:
+		lustre_swab_lov_comp_md_v1((struct lov_comp_md_v1 *)lum);
+		break;
+	case __swab32(LOV_MAGIC_FOREIGN):
+	case LOV_USER_MAGIC_FOREIGN:
+	{
+		struct lov_foreign_md *lfm = (struct lov_foreign_md *)lum;
+
+		__swab32s(&lfm->lfm_magic);
+		__swab32s(&lfm->lfm_length);
+		__swab32s(&lfm->lfm_type);
+		__swab32s(&lfm->lfm_flags);
+		break;
+	}
+	default:
+		CDEBUG(D_IOCTL, "Invalid LOV magic %08x\n", lum->lmm_magic);
+	}
+}
+EXPORT_SYMBOL(lustre_swab_lov_user_md);
+
+void lustre_swab_lov_mds_md(struct lov_mds_md *lmm)
+{
+	CDEBUG(D_IOCTL, "swabbing lov_mds_md\n");
+	__swab32s(&lmm->lmm_magic);
+	__swab32s(&lmm->lmm_pattern);
+	lustre_swab_lmm_oi(&lmm->lmm_oi);
+	__swab32s(&lmm->lmm_stripe_size);
+	__swab16s(&lmm->lmm_stripe_count);
+	__swab16s(&lmm->lmm_layout_gen);
+}
+EXPORT_SYMBOL(lustre_swab_lov_mds_md);
+
 static void lustre_swab_ldlm_res_id(struct ldlm_res_id *id)
 {
-	int i;
+	int  i;
 
 	for (i = 0; i < RES_NAME_SIZE; i++)
 		__swab64s(&id->name[i]);
-- 
1.8.3.1
