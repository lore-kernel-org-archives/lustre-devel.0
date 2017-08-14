From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 12:20:55 -0400
Subject: [lustre-devel] [PATCH 05/14] staging: lustre: llite: return from
	ll_adjust_lum() if lump is NULL
In-Reply-To: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
References: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502727664-29438-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

No need to check several times if lump is NULL. Just test once and
return 0 if NULL.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9484
Reviewed-on: https://review.whamcloud.com/27126
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 7a17114..d862189 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -187,15 +187,18 @@ static int ll_adjust_lum(struct inode *inode, struct lov_user_md *lump)
 {
 	int rc = 0;
 
+	if (!lump)
+		return 0;
+
 	/* Attributes that are saved via getxattr will always have
 	 * the stripe_offset as 0.  Instead, the MDS should be
 	 * allowed to pick the starting OST index.   b=17846
 	 */
-	if (lump && lump->lmm_stripe_offset == 0)
+	if (lump->lmm_stripe_offset == 0)
 		lump->lmm_stripe_offset = -1;
 
 	/* Avoid anyone directly setting the RELEASED flag. */
-	if (lump && (lump->lmm_pattern & LOV_PATTERN_F_RELEASED)) {
+	if (lump->lmm_pattern & LOV_PATTERN_F_RELEASED) {
 		/* Only if we have a released flag check if the file
 		 * was indeed archived.
 		 */
-- 
1.8.3.1
