From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:07 -0500
Subject: [lustre-devel] [PATCH 439/622] lustre: llite: swab LOV EA data in
 ll_getxattr_lov()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-440-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jian Yu <yujian@whamcloud.com>

On PPC client, the LOV EA data returned by getfattr from x86_64 server
was not swabbed to the host endian. While running setfattr, the data was
swabbed in ll_lov_setstripe_ea_info(), which caused magic mis-match in
ll_lov_user_md_size() and then ll_setstripe_ea() returned -ERANGE.

This patch fixed the above issue by swabbing LOV EA data in
ll_getxattr_lov().

WC-bug-id: https://jira.whamcloud.com/browse/LU-12589
Lustre-commit: 5590f5aa94a5 ("LU-12589 llite: swab LOV EA data in ll_getxattr_lov()")
Signed-off-by: Jian Yu <yujian@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35626
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_swab.h |  2 +-
 fs/lustre/llite/dir.c           |  4 ++--
 fs/lustre/llite/file.c          |  4 ++--
 fs/lustre/llite/xattr.c         | 16 ++++++++--------
 fs/lustre/ptlrpc/pack_generic.c | 40 ++++++++++++++++++++++++++++++++++------
 5 files changed, 47 insertions(+), 19 deletions(-)

diff --git a/fs/lustre/include/lustre_swab.h b/fs/lustre/include/lustre_swab.h
index e99e16d..dd3c50c 100644
--- a/fs/lustre/include/lustre_swab.h
+++ b/fs/lustre/include/lustre_swab.h
@@ -86,7 +86,7 @@
 void lustre_swab_lov_comp_md_v1(struct lov_comp_md_v1 *lum);
 void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
 				     int stripe_count);
-void lustre_swab_lov_user_md(struct lov_user_md *lum);
+void lustre_swab_lov_user_md(struct lov_user_md *lum, size_t size);
 void lustre_swab_lov_mds_md(struct lov_mds_md *lmm);
 void lustre_swab_lustre_capa(struct lustre_capa *c);
 void lustre_swab_lustre_capa_key(struct lustre_capa_key *k);
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 3540c18..812f535 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -564,7 +564,7 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 		 */
 		if ((__swab32(lump->lmm_magic) & le32_to_cpu(LOV_MAGIC_MASK)) ==
 		    le32_to_cpu(LOV_MAGIC_MAGIC))
-			lustre_swab_lov_user_md(lump);
+			lustre_swab_lov_user_md(lump, 0);
 	} else {
 		lum_size = sizeof(struct lov_user_md_v1);
 	}
@@ -696,7 +696,7 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 	case LOV_MAGIC_COMP_V1:
 	case LOV_USER_MAGIC_SPECIFIC:
 		if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC)
-			lustre_swab_lov_user_md((struct lov_user_md *)lmm);
+			lustre_swab_lov_user_md((struct lov_user_md *)lmm, 0);
 		break;
 	case LMV_MAGIC_V1:
 		if (cpu_to_le32(LMV_MAGIC) != LMV_MAGIC)
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index fa61b09..6c5b9eb 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1873,7 +1873,7 @@ int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
 	if ((__swab32(lum->lmm_magic) & le32_to_cpu(LOV_MAGIC_MASK)) ==
 	    le32_to_cpu(LOV_MAGIC_MAGIC)) {
 		/* this code will only exist for big-endian systems */
-		lustre_swab_lov_user_md(lum);
+		lustre_swab_lov_user_md(lum, 0);
 	}
 
 	ll_inode_size_lock(inode);
@@ -1956,7 +1956,7 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 				stripe_count = 0;
 		}
 
-		lustre_swab_lov_user_md((struct lov_user_md *)lmm);
+		lustre_swab_lov_user_md((struct lov_user_md *)lmm, 0);
 
 		/* if function called for directory - we should
 		 * avoid swab not existent lsm objects
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index cf1cfd2..4e1ce34 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -320,7 +320,7 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 	if (strncmp(name, "lov.", 4) == 0 &&
 	    (__swab32(((struct lov_user_md *)value)->lmm_magic) &
 	    le32_to_cpu(LOV_MAGIC_MASK)) == le32_to_cpu(LOV_MAGIC_MAGIC))
-		lustre_swab_lov_user_md((struct lov_user_md *)value);
+		lustre_swab_lov_user_md((struct lov_user_md *)value, 0);
 
 	return ll_xattr_set_common(handler, dentry, inode, name, value, size,
 				   flags);
@@ -459,7 +459,6 @@ static ssize_t ll_getxattr_lov(struct inode *inode, void *buf, size_t buf_size)
 		};
 		struct lu_env *env;
 		u16 refcheck;
-		u32 magic;
 
 		if (!obj)
 			return -ENODATA;
@@ -490,12 +489,12 @@ static ssize_t ll_getxattr_lov(struct inode *inode, void *buf, size_t buf_size)
 		 * recognizing layout gen as stripe offset when the
 		 * file is restored. See LU-2809.
 		 */
-		magic = ((struct lov_mds_md *)buf)->lmm_magic;
-		if ((magic & __swab32(LOV_MAGIC_MAGIC)) ==
-		    __swab32(LOV_MAGIC_MAGIC))
-			magic = __swab32(magic);
+		if ((((struct lov_mds_md *)buf)->lmm_magic &
+		    __swab32(LOV_MAGIC_MAGIC)) == __swab32(LOV_MAGIC_MAGIC))
+			lustre_swab_lov_user_md((struct lov_user_md *)buf,
+						cl.cl_size);
 
-		switch (magic) {
+		switch (((struct lov_mds_md *)buf)->lmm_magic) {
 		case LOV_MAGIC_V1:
 		case LOV_MAGIC_V3:
 		case LOV_MAGIC_SPECIFIC:
@@ -505,7 +504,8 @@ static ssize_t ll_getxattr_lov(struct inode *inode, void *buf, size_t buf_size)
 		case LOV_MAGIC_FOREIGN:
 			goto out_env;
 		default:
-			CERROR("Invalid LOV magic %08x\n", magic);
+			CERROR("Invalid LOV magic %08x\n",
+			       ((struct lov_mds_md *)buf)->lmm_magic);
 			rc = -EINVAL;
 			goto out_env;
 		}
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index b066113..6a4ea7a 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -2147,23 +2147,51 @@ void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
 }
 EXPORT_SYMBOL(lustre_swab_lov_user_md_objects);
 
-void lustre_swab_lov_user_md(struct lov_user_md *lum)
+void lustre_swab_lov_user_md(struct lov_user_md *lum, size_t size)
 {
+	struct lov_user_md_v1 *v1;
+	struct lov_user_md_v3 *v3;
+	struct lov_foreign_md *lfm;
+	u16 stripe_count;
+
 	CDEBUG(D_IOCTL, "swabbing lov_user_md\n");
 	switch (lum->lmm_magic) {
 	case __swab32(LOV_MAGIC_V1):
 	case LOV_USER_MAGIC_V1:
-		lustre_swab_lov_user_md_v1((struct lov_user_md_v1 *)lum);
+	{
+		v1 = (struct lov_user_md_v1 *)lum;
+		stripe_count = v1->lmm_stripe_count;
+
+		if (lum->lmm_magic != LOV_USER_MAGIC_V1)
+			__swab16s(&stripe_count);
+
+		lustre_swab_lov_user_md_v1(v1);
+		if (size > sizeof(*v1))
+			lustre_swab_lov_user_md_objects(v1->lmm_objects,
+							stripe_count);
+
 		break;
+	}
 	case __swab32(LOV_MAGIC_V3):
 	case LOV_USER_MAGIC_V3:
-		lustre_swab_lov_user_md_v3((struct lov_user_md_v3 *)lum);
+	{
+		v3 = (struct lov_user_md_v3 *)lum;
+		stripe_count = v3->lmm_stripe_count;
+
+		if (lum->lmm_magic != LOV_USER_MAGIC_V3)
+			__swab16s(&stripe_count);
+
+		lustre_swab_lov_user_md_v3(v3);
+		if (size > sizeof(*v3))
+			lustre_swab_lov_user_md_objects(v3->lmm_objects,
+							stripe_count);
 		break;
+	}
 	case __swab32(LOV_USER_MAGIC_SPECIFIC):
 	case LOV_USER_MAGIC_SPECIFIC:
 	{
-		struct lov_user_md_v3 *v3 = (struct lov_user_md_v3 *)lum;
-		u16 stripe_count = v3->lmm_stripe_count;
+		v3 = (struct lov_user_md_v3 *)lum;
+		stripe_count = v3->lmm_stripe_count;
 
 		if (lum->lmm_magic != LOV_USER_MAGIC_SPECIFIC)
 			__swab16s(&stripe_count);
@@ -2179,7 +2207,7 @@ void lustre_swab_lov_user_md(struct lov_user_md *lum)
 	case __swab32(LOV_MAGIC_FOREIGN):
 	case LOV_USER_MAGIC_FOREIGN:
 	{
-		struct lov_foreign_md *lfm = (struct lov_foreign_md *)lum;
+		lfm = (struct lov_foreign_md *)lum;
 
 		__swab32s(&lfm->lfm_magic);
 		__swab32s(&lfm->lfm_length);
-- 
1.8.3.1
