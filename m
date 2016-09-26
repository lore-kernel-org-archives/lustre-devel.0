From: James Simmons <jsimmons@infradead.org>
Date: Mon, 26 Sep 2016 10:50:50 -0400
Subject: [lustre-devel] [PATCH 01/37] staging: lustre: llite: add missing
	LMV_MAGIC_V1 case
Message-ID: <1474901450-28730-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

The port to upstream dropped handling the LMV_MAGIC_V1
case for ll_dir_getstripe. This adds it back.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-on: http://review.whamcloud.com/7228
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c           | 4 ++++
 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c | 1 +
 2 files changed, 5 insertions(+)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 705de1c..7f32a53 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -620,6 +620,10 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 		if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC)
 			lustre_swab_lov_user_md_v3((struct lov_user_md_v3 *)lmm);
 		break;
+	case LMV_MAGIC_V1:
+		if (cpu_to_le32(LMV_MAGIC) != LMV_MAGIC)
+			lustre_swab_lmv_mds_md((union lmv_mds_md *)lmm);
+		break;
 	case LMV_USER_MAGIC:
 		if (cpu_to_le32(LMV_USER_MAGIC) != LMV_USER_MAGIC)
 			lustre_swab_lmv_user_md((struct lmv_user_md *)lmm);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index e24d8e1..8717685 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1861,6 +1861,7 @@ void lustre_swab_lmv_mds_md(union lmv_mds_md *lmm)
 		break;
 	}
 }
+EXPORT_SYMBOL(lustre_swab_lmv_mds_md);
 
 void lustre_swab_lmv_user_md(struct lmv_user_md *lum)
 {
-- 
2.7.4
