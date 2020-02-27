From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:29 -0500
Subject: [lustre-devel] [PATCH 101/622] lustre: llite: fix setstripe for
 specific osts upon dir
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-102-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

LOV_USER_MAGIC_SPECIFIC function is broken and it
was not available for setting directory.

1) llite doesn't handle LOV_USER_MAGIC_SPECIFIC case
   properly for dir {set,get}_stripe, and ioctl
   LL_IOC_LOV_SETSTRIPE did not alloc enough buf,
   copy ost lists from userspace.

2) lod_get_default_lov_striping() did not handle
   LOV_USER_MAGIC_SPECIFIC type that newly created
   files/dir won't inherit parent setting well.

3) there is not any case to cover lfs setstripe
   '-o' interface which make it hard to figure out
   when this function was broken.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11146
Lustre-commit: 083d62ee6de5 ("LU-11146 lustre: fix setstripe for specific osts upon dir")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/32814
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c | 71 ++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 56 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 751d0183..06f7bd3 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -541,6 +541,21 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 			lum_size = sizeof(struct lmv_user_md);
 			break;
 		}
+		case LOV_USER_MAGIC_SPECIFIC: {
+			struct lov_user_md_v3 *v3 =
+					(struct lov_user_md_v3 *)lump;
+			if (v3->lmm_stripe_count > LOV_MAX_STRIPE_COUNT)
+				return -EINVAL;
+			if (lump->lmm_magic !=
+			    cpu_to_le32(LOV_USER_MAGIC_SPECIFIC)) {
+				lustre_swab_lov_user_md_v3(v3);
+				lustre_swab_lov_user_md_objects(v3->lmm_objects,
+						v3->lmm_stripe_count);
+			}
+			lum_size = lov_user_md_size(v3->lmm_stripe_count,
+						    LOV_USER_MAGIC_SPECIFIC);
+			break;
+		}
 		default: {
 			CDEBUG(D_IOCTL,
 			       "bad userland LOV MAGIC: %#08x != %#08x nor %#08x\n",
@@ -695,6 +710,16 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 		if (cpu_to_le32(LMV_USER_MAGIC) != LMV_USER_MAGIC)
 			lustre_swab_lmv_user_md((struct lmv_user_md *)lmm);
 		break;
+	case LOV_USER_MAGIC_SPECIFIC: {
+		struct lov_user_md_v3 *v3 = (struct lov_user_md_v3 *)lmm;
+
+		if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC) {
+			lustre_swab_lov_user_md_v3(v3);
+			lustre_swab_lov_user_md_objects(v3->lmm_objects,
+							v3->lmm_stripe_count);
+			}
+		}
+		break;
 	default:
 		CERROR("unknown magic: %lX\n", (unsigned long)lmm->lmm_magic);
 		rc = -EPROTO;
@@ -1230,35 +1255,51 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	}
 	case LL_IOC_LOV_SETSTRIPE_NEW:
 	case LL_IOC_LOV_SETSTRIPE: {
-		struct lov_user_md_v3 lumv3;
-		struct lov_user_md_v1 *lumv1 = (struct lov_user_md_v1 *)&lumv3;
+		struct lov_user_md_v3 *lumv3 = NULL;
+		struct lov_user_md_v1 lumv1;
+		struct lov_user_md_v1 *lumv1_ptr = &lumv1;
 		struct lov_user_md_v1 __user *lumv1p = (void __user *)arg;
 		struct lov_user_md_v3 __user *lumv3p = (void __user *)arg;
+		int lum_size;
 
 		int set_default = 0;
 
 		BUILD_BUG_ON(sizeof(struct lov_user_md_v3) <=
 			     sizeof(struct lov_comp_md_v1));
-		BUILD_BUG_ON(sizeof(lumv3) != sizeof(*lumv3p));
-		BUILD_BUG_ON(sizeof(lumv3.lmm_objects[0]) !=
-			     sizeof(lumv3p->lmm_objects[0]));
+		BUILD_BUG_ON(sizeof(*lumv3) != sizeof(*lumv3p));
 		/* first try with v1 which is smaller than v3 */
-		if (copy_from_user(lumv1, lumv1p, sizeof(*lumv1)))
+		if (copy_from_user(&lumv1, lumv1p, sizeof(lumv1)))
 			return -EFAULT;
 
-		if (lumv1->lmm_magic == LOV_USER_MAGIC_V3) {
-			if (copy_from_user(&lumv3, lumv3p, sizeof(lumv3)))
-				return -EFAULT;
-			if (lumv3.lmm_magic != LOV_USER_MAGIC_V3)
-				return -EINVAL;
-		}
-
 		if (is_root_inode(inode))
 			set_default = 1;
 
-		/* in v1 and v3 cases lumv1 points to data */
-		rc = ll_dir_setstripe(inode, lumv1, set_default);
+		switch (lumv1.lmm_magic) {
+		case LOV_USER_MAGIC_V3:
+		case LOV_USER_MAGIC_SPECIFIC:
+			lum_size = ll_lov_user_md_size(&lumv1);
+			if (lum_size < 0)
+				return lum_size;
+			lumv3 = kzalloc(lum_size, GFP_NOFS);
+			if (!lumv3)
+				return -ENOMEM;
+			if (copy_from_user(lumv3, lumv3p, lum_size)) {
+				rc = -EFAULT;
+				goto out;
+			}
+			lumv1_ptr = (struct lov_user_md_v1 *)lumv3;
+			break;
+		case LOV_USER_MAGIC_V1:
+			break;
+		default:
+			rc = -ENOTSUPP;
+			goto out;
+		}
 
+		/* in v1 and v3 cases lumv1 points to data */
+		rc = ll_dir_setstripe(inode, lumv1_ptr, set_default);
+out:
+		kfree(lumv3);
 		return rc;
 	}
 	case LL_IOC_LMV_GETSTRIPE: {
-- 
1.8.3.1
