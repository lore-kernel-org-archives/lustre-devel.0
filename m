From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:41 -0400
Subject: [lustre-devel] [PATCH 28/80] staging: lustre: lmv: access
	lum_stripe_offset as little endian
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

By the time that a struct lmv_user_md reaches lmv_placement_policy()
it has already been converted to little endian. Therefore use the
appropriate macros around accesses to this this field. This issue was
found by rewriting the definition of struct lmv_user_md to use the
__leXX typedefs and running sparse.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4738
Reviewed-on: http://review.whamcloud.com/9671
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Swapnil Pimpale <spimpale@ddn.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index c005a66..5929994 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1242,15 +1242,15 @@ static int lmv_placement_policy(struct obd_device *obd,
 		struct lmv_user_md *lum;
 
 		lum = op_data->op_data;
-		if (lum->lum_stripe_offset != (__u32)-1) {
-			*mds = lum->lum_stripe_offset;
+		if (le32_to_cpu(lum->lum_stripe_offset) != (__u32)-1) {
+			*mds = le32_to_cpu(lum->lum_stripe_offset);
 		} else {
 			/*
 			 * -1 means default, which will be in the same MDT with
 			 * the stripe
 			 */
 			*mds = op_data->op_mds;
-			lum->lum_stripe_offset = op_data->op_mds;
+			lum->lum_stripe_offset = cpu_to_le32(op_data->op_mds);
 		}
 	} else {
 		/*
-- 
1.7.1
