From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:14:56 -0400
Subject: [lustre-devel] [PATCH 07/22] staging: lustre: llite: refactor
 lustre.lov xattr handling
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Niu Yawei <yawei.niu@intel.com>, Bobi Jam <bobijam.xu@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Niu Yawei <yawei.niu@intel.com>

The function ll_xattr_set() contains special code to handle
the lustre specific xattr lustre.lov. Move all this code to
a new function ll_setstripe_ea().

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24851
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 131 +++++++++++++++-------------
 1 file changed, 69 insertions(+), 62 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 55a19a5..1b462e4 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -186,6 +186,73 @@ static int get_hsm_state(struct inode *inode, u32 *hus_states)
 	return rc;
 }
 
+static int ll_setstripe_ea(struct dentry *dentry, struct lov_user_md *lump,
+			   size_t size)
+{
+	struct inode *inode = d_inode(dentry);
+	int rc = 0;
+
+	if (size != 0 && size < sizeof(struct lov_user_md))
+		return -EINVAL;
+
+	/*
+	 * It is possible to set an xattr to a "" value of zero size.
+	 * For this case we are going to treat it as a removal.
+	 */
+	if (!size && lump)
+		lump = NULL;
+
+	/* Attributes that are saved via getxattr will always have
+	 * the stripe_offset as 0.  Instead, the MDS should be
+	 * allowed to pick the starting OST index.   b=17846
+	 */
+	if (lump && lump->lmm_stripe_offset == 0)
+		lump->lmm_stripe_offset = -1;
+
+	/* Avoid anyone directly setting the RELEASED flag. */
+	if (lump && (lump->lmm_pattern & LOV_PATTERN_F_RELEASED)) {
+		/* Only if we have a released flag check if the file
+		 * was indeed archived.
+		 */
+		u32 state = HS_NONE;
+
+		rc = get_hsm_state(inode, &state);
+		if (rc)
+			return rc;
+
+		if (!(state & HS_ARCHIVED)) {
+			CDEBUG(D_VFSTRACE,
+			       "hus_states state = %x, pattern = %x\n",
+				state, lump->lmm_pattern);
+			/*
+			 * Here the state is: real file is not
+			 * archived but user is requesting to set
+			 * the RELEASED flag so we mask off the
+			 * released flag from the request
+			 */
+			lump->lmm_pattern ^= LOV_PATTERN_F_RELEASED;
+		}
+	}
+
+	if (lump && S_ISREG(inode->i_mode)) {
+		__u64 it_flags = FMODE_WRITE;
+		int lum_size;
+
+		lum_size = ll_lov_user_md_size(lump);
+		if (lum_size < 0 || size < lum_size)
+			return 0; /* b=10667: ignore error */
+
+		rc = ll_lov_setstripe_ea_info(inode, dentry, it_flags, lump,
+					      lum_size);
+		/* b=10667: rc always be 0 here for now */
+		rc = 0;
+	} else if (S_ISDIR(inode->i_mode)) {
+		rc = ll_dir_setstripe(inode, lump, 0);
+	}
+
+	return rc;
+}
+
 static int ll_xattr_set(const struct xattr_handler *handler,
 			struct dentry *dentry, struct inode *inode,
 			const char *name, const void *value, size_t size,
@@ -198,73 +265,13 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 	       PFID(ll_inode2fid(inode)), inode, name);
 
 	if (!strcmp(name, "lov")) {
-		struct lov_user_md *lump = (struct lov_user_md *)value;
 		int op_type = flags == XATTR_REPLACE ? LPROC_LL_REMOVEXATTR :
 						       LPROC_LL_SETXATTR;
-		int rc = 0;
 
 		ll_stats_ops_tally(ll_i2sbi(inode), op_type, 1);
 
-		if (size != 0 && size < sizeof(struct lov_user_md))
-			return -EINVAL;
-
-		/*
-		 * It is possible to set an xattr to a "" value of zero size.
-		 * For this case we are going to treat it as a removal.
-		 */
-		if (!size && lump)
-			lump = NULL;
-
-		/* Attributes that are saved via getxattr will always have
-		 * the stripe_offset as 0.  Instead, the MDS should be
-		 * allowed to pick the starting OST index.   b=17846
-		 */
-		if (lump && lump->lmm_stripe_offset == 0)
-			lump->lmm_stripe_offset = -1;
-
-		/* Avoid anyone directly setting the RELEASED flag. */
-		if (lump && (lump->lmm_pattern & LOV_PATTERN_F_RELEASED)) {
-			/* Only if we have a released flag check if the file
-			 * was indeed archived.
-			 */
-			u32 state = HS_NONE;
-
-			rc = get_hsm_state(inode, &state);
-			if (rc)
-				return rc;
-
-			if (!(state & HS_ARCHIVED)) {
-				CDEBUG(D_VFSTRACE,
-				       "hus_states state = %x, pattern = %x\n",
-				state, lump->lmm_pattern);
-				/*
-				 * Here the state is: real file is not
-				 * archived but user is requesting to set
-				 * the RELEASED flag so we mask off the
-				 * released flag from the request
-				 */
-				lump->lmm_pattern ^= LOV_PATTERN_F_RELEASED;
-			}
-		}
-
-		if (lump && S_ISREG(inode->i_mode)) {
-			__u64 it_flags = FMODE_WRITE;
-			int lum_size;
-
-			lum_size = ll_lov_user_md_size(lump);
-			if (lum_size < 0 || size < lum_size)
-				return 0; /* b=10667: ignore error */
-
-			rc = ll_lov_setstripe_ea_info(inode, dentry, it_flags,
-						      lump, lum_size);
-			/* b=10667: rc always be 0 here for now */
-			rc = 0;
-		} else if (S_ISDIR(inode->i_mode)) {
-			rc = ll_dir_setstripe(inode, lump, 0);
-		}
-
-		return rc;
-
+		return ll_setstripe_ea(dentry, (struct lov_user_md *)value,
+				       size);
 	} else if (!strcmp(name, "lma") || !strcmp(name, "link")) {
 		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_SETXATTR, 1);
 		return 0;
-- 
1.8.3.1
