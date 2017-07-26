From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:23 -0400
Subject: [lustre-devel] [PATCH 07/20] staging: lustre: lov: Ensure correct
	operation for large object sizes
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Nathaniel Clark <nathaniel.l.clark@intel.com>, James Simmons <jsimmons@infradead.org>

From: Nathaniel Clark <nathaniel.l.clark@intel.com>

If a backing filesystem (ZFS) returns that it supports very large
(LLONG_MAX) object sizes, that should be correctly supported.  This
fixes the check for unitialized stripe_maxbytes in
lsm_unpackmd_common(), so that ZFS can return LLONG_MAX and it will be
okay. This issue is excersized by writing to or past the 2TB boundry
of a singly stripped file.

Signed-off-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7890
Reviewed-on: http://review.whamcloud.com/19066
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_ea.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index ac0bf64..2a8fee8 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -150,9 +150,10 @@ static int lsm_unpackmd_common(struct lov_obd *lov,
 			       struct lov_mds_md *lmm,
 			       struct lov_ost_data_v1 *objects)
 {
-	loff_t stripe_maxbytes = LLONG_MAX;
+	loff_t min_stripe_maxbytes = 0;
 	unsigned int stripe_count;
 	struct lov_oinfo *loi;
+	loff_t lov_bytes;
 	unsigned int i;
 
 	/*
@@ -168,8 +169,6 @@ static int lsm_unpackmd_common(struct lov_obd *lov,
 	stripe_count = lsm_is_released(lsm) ? 0 : lsm->lsm_stripe_count;
 
 	for (i = 0; i < stripe_count; i++) {
-		loff_t tgt_bytes;
-
 		loi = lsm->lsm_oinfo[i];
 		ostid_le_to_cpu(&objects[i].l_ost_oi, &loi->loi_oi);
 		loi->loi_ost_idx = le32_to_cpu(objects[i].l_ost_idx);
@@ -194,17 +193,21 @@ static int lsm_unpackmd_common(struct lov_obd *lov,
 			continue;
 		}
 
-		tgt_bytes = lov_tgt_maxbytes(lov->lov_tgts[loi->loi_ost_idx]);
-		stripe_maxbytes = min_t(loff_t, stripe_maxbytes, tgt_bytes);
+		lov_bytes = lov_tgt_maxbytes(lov->lov_tgts[loi->loi_ost_idx]);
+		if (min_stripe_maxbytes == 0 || lov_bytes < min_stripe_maxbytes)
+			min_stripe_maxbytes = lov_bytes;
 	}
 
-	if (stripe_maxbytes == LLONG_MAX)
-		stripe_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
+	if (min_stripe_maxbytes == 0)
+		min_stripe_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
+
+	stripe_count = lsm->lsm_stripe_count ?: lov->desc.ld_tgt_count;
+	lov_bytes = min_stripe_maxbytes * stripe_count;
 
-	if (!lsm->lsm_stripe_count)
-		lsm->lsm_maxbytes = stripe_maxbytes * lov->desc.ld_tgt_count;
+	if (lov_bytes < min_stripe_maxbytes) /* handle overflow */
+		lsm->lsm_maxbytes = MAX_LFS_FILESIZE;
 	else
-		lsm->lsm_maxbytes = stripe_maxbytes * lsm->lsm_stripe_count;
+		lsm->lsm_maxbytes = lov_bytes;
 
 	return 0;
 }
-- 
1.8.3.1
