From: James Simmons <jsimmons@infradead.org>
Date: Mon, 19 Sep 2016 13:27:05 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: ptlrpc: re-export
	lustre_swab_[lmv|lov]_mds_md
Message-ID: <1474306025-1942-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Being over zealous in removing unused EXPORT_SYMBOLs two functions
lustre_swab_[lmv|lov]_mds_md exports were removed. They need to be
exported so this patch restores those EXPORT_SYMBOLS. Same mistake
was done when porting to the upstream client.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: http://review.whamcloud.com/14545
Reviewed-on: http://review.whamcloud.com/15159
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6486
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 1349bf6..8717685 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1861,6 +1861,7 @@ void lustre_swab_lmv_mds_md(union lmv_mds_md *lmm)
 		break;
 	}
 }
+EXPORT_SYMBOL(lustre_swab_lmv_mds_md);
 
 void lustre_swab_lmv_user_md(struct lmv_user_md *lum)
 {
@@ -1914,6 +1915,7 @@ void lustre_swab_lov_mds_md(struct lov_mds_md *lmm)
 	__swab16s(&lmm->lmm_stripe_count);
 	__swab16s(&lmm->lmm_layout_gen);
 }
+EXPORT_SYMBOL(lustre_swab_lov_mds_md);
 
 void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
 				     int stripe_count)
-- 
1.7.1
