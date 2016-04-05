From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:36:47 -0400
Subject: [lustre-devel] [PATCH 02/18] staging: lustre: llite: use 64bits
	flags in ll_lov_setea()
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

In ll_lov_setea(), setting MDS_OPEN_HAS_OBJS to an int flags will
result in the flags being overflowed.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3744
Reviewed-on: http://review.whamcloud.com/7312
Reviewed-by: Emoly Liu <emoly.liu@intel.com>
Reviewed-by: Jian Yu <jian.yu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c         |    7 ++++---
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |    6 +++---
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 69b56a8..02b5783 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1363,7 +1363,8 @@ static int ll_lov_recreate_fid(struct inode *inode, unsigned long arg)
 }
 
 int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
-			     int flags, struct lov_user_md *lum, int lum_size)
+			     __u64 flags, struct lov_user_md *lum,
+			     int lum_size)
 {
 	struct lov_stripe_md *lsm = NULL;
 	struct lookup_intent oit = {.it_op = IT_OPEN, .it_flags = flags};
@@ -1487,7 +1488,7 @@ out:
 static int ll_lov_setea(struct inode *inode, struct file *file,
 			unsigned long arg)
 {
-	int			 flags = MDS_OPEN_HAS_OBJS | FMODE_WRITE;
+	__u64			 flags = MDS_OPEN_HAS_OBJS | FMODE_WRITE;
 	struct lov_user_md	*lump;
 	int			 lum_size = sizeof(struct lov_user_md) +
 					    sizeof(struct lov_user_ost_data);
@@ -1521,7 +1522,7 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 	struct lov_user_md_v1 __user *lumv1p = (void __user *)arg;
 	struct lov_user_md_v3 __user *lumv3p = (void __user *)arg;
 	int lum_size, rc;
-	int flags = FMODE_WRITE;
+	__u64 flags = FMODE_WRITE;
 
 	/* first try with v1 which is smaller than v3 */
 	lum_size = sizeof(struct lov_user_md_v1);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index ba24f09..ccbb9be 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -745,7 +745,7 @@ struct posix_acl *ll_get_acl(struct inode *inode, int type);
 int ll_inode_permission(struct inode *inode, int mask);
 
 int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
-			     int flags, struct lov_user_md *lum,
+			     __u64 flags, struct lov_user_md *lum,
 			     int lum_size);
 int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 			     struct lov_mds_md **lmm, int *lmm_size,
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index b68dcc9..6282478 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -243,12 +243,12 @@ int ll_setxattr(struct dentry *dentry, const char *name,
 			lump->lmm_stripe_offset = -1;
 
 		if (lump && S_ISREG(inode->i_mode)) {
-			int flags = FMODE_WRITE;
+			__u64 it_flags = FMODE_WRITE;
 			int lum_size = (lump->lmm_magic == LOV_USER_MAGIC_V1) ?
 				sizeof(*lump) : sizeof(struct lov_user_md_v3);
 
-			rc = ll_lov_setstripe_ea_info(inode, dentry, flags, lump,
-						      lum_size);
+			rc = ll_lov_setstripe_ea_info(inode, dentry, it_flags,
+						      lump, lum_size);
 			/* b10667: rc always be 0 here for now */
 			rc = 0;
 		} else if (S_ISDIR(inode->i_mode)) {
-- 
1.7.1
