From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:11 -0400
Subject: [lustre-devel] [PATCH 012/124] staging: lustre: lmv: fix some byte
	order issues
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

In the handler for LL_IOC_LMV_GETSTRIPE convert stripe FIDs from
little to CPU endian when unpacking lmv_user_md. In lmv_unpack_md_v1()
fix a double conversion of the stripe count.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5342
Reviewed-on: http://review.whamcloud.com/11106
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Jian Yu <jian.yu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c   |    8 ++++----
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index c97a4a0..97815cf 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1252,16 +1252,16 @@ lmv_out_free:
 		tmp->lum_stripe_count = 0;
 		tmp->lum_stripe_offset = mdt_index;
 		for (i = 0; i < stripe_count; i++) {
-			struct lu_fid   *fid;
+			struct lu_fid fid;
 
-			fid = &lmm->lmv_md_v1.lmv_stripe_fids[i];
-			mdt_index = ll_get_mdt_idx_by_fid(sbi, fid);
+			fid_le_to_cpu(&fid, &lmm->lmv_md_v1.lmv_stripe_fids[i]);
+			mdt_index = ll_get_mdt_idx_by_fid(sbi, &fid);
 			if (mdt_index < 0) {
 				rc = mdt_index;
 				goto out_tmp;
 			}
 			tmp->lum_objects[i].lum_mds = mdt_index;
-			tmp->lum_objects[i].lum_fid = *fid;
+			tmp->lum_objects[i].lum_fid = fid;
 			tmp->lum_stripe_count++;
 		}
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 11dcbb6..e1fac0b 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2909,7 +2909,7 @@ static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
 	       lsm->lsm_md_hash_type, lsm->lsm_md_layout_version);
 
 	stripe_count = le32_to_cpu(lmm1->lmv_stripe_count);
-	for (i = 0; i < le32_to_cpu(stripe_count); i++) {
+	for (i = 0; i < stripe_count; i++) {
 		fid_le_to_cpu(&lsm->lsm_md_oinfo[i].lmo_fid,
 			      &lmm1->lmv_stripe_fids[i]);
 		rc = lmv_fld_lookup(lmv, &lsm->lsm_md_oinfo[i].lmo_fid,
-- 
1.7.1
