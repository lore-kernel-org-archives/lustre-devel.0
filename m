From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:14:58 -0400
Subject: [lustre-devel] [PATCH 09/22] staging: lustre: llite: break up
 ll_setstripe_ea function
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Bobi Jam <bobijam.xu@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Bobi Jam <bobijam.xu@intel.com>

Place all the handling of information of trusted.lov that
is not stripe related into the new function ll_adjust_lum().
Now ll_setstripe_ea() only handles striping information.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9484
Reviewed-on: https://review.whamcloud.com/27126
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 37 +++++++++++++++++++----------
 1 file changed, 24 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index c1600b9..78ce85b 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -186,22 +186,10 @@ static int get_hsm_state(struct inode *inode, u32 *hus_states)
 	return rc;
 }
 
-static int ll_setstripe_ea(struct dentry *dentry, struct lov_user_md *lump,
-			   size_t size)
+static int ll_adjust_lum(struct inode *inode, struct lov_user_md *lump)
 {
-	struct inode *inode = d_inode(dentry);
 	int rc = 0;
 
-	if (size != 0 && size < sizeof(struct lov_user_md))
-		return -EINVAL;
-
-	/*
-	 * It is possible to set an xattr to a "" value of zero size.
-	 * For this case we are going to treat it as a removal.
-	 */
-	if (!size && lump)
-		lump = NULL;
-
 	/* Attributes that are saved via getxattr will always have
 	 * the stripe_offset as 0.  Instead, the MDS should be
 	 * allowed to pick the starting OST index.   b=17846
@@ -234,6 +222,29 @@ static int ll_setstripe_ea(struct dentry *dentry, struct lov_user_md *lump,
 		}
 	}
 
+	return rc;
+}
+
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
+	rc = ll_adjust_lum(inode, lump);
+	if (rc)
+		return rc;
+
 	if (lump && S_ISREG(inode->i_mode)) {
 		__u64 it_flags = FMODE_WRITE;
 		int lum_size;
-- 
1.8.3.1
