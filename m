From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:36:54 -0400
Subject: [lustre-devel] [PATCH 09/18] staging: lustre: lov: Get the correct
	address of lmm_objects
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Swapnil Pimpale <spimpale@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Swapnil Pimpale <spimpale@ddn.com>

The introduction of lmm_layout_gen makes the assumption that
lmm_objects is present after lmm_stripe_count incorrect.
Fixed this to get the correct address of lmm_objects when lmmk is cast
to lov_mds_md_v1.

Signed-off-by: Swapnil Pimpale <spimpale@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3162
Reviewed-on: http://review.whamcloud.com/7258
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_pack.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 3925633..2f02be5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -444,8 +444,7 @@ int lov_getstripe(struct obd_export *exp, struct lov_stripe_md *lsm,
 	if (lum.lmm_magic == LOV_USER_MAGIC) {
 		/* User request for v1, we need skip lmm_pool_name */
 		if (lmmk->lmm_magic == LOV_MAGIC_V3) {
-			memmove((char *)(&lmmk->lmm_stripe_count) +
-				sizeof(lmmk->lmm_stripe_count),
+			memmove(((struct lov_mds_md_v1 *)lmmk)->lmm_objects,
 				((struct lov_mds_md_v3 *)lmmk)->lmm_objects,
 				lmmk->lmm_stripe_count *
 				sizeof(struct lov_ost_data_v1));
-- 
1.7.1
