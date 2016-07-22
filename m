From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:22 -0400
Subject: [lustre-devel] [PATCH 29/58] staging: lustre: lmv: replace
	obd_free_memmd with lmv_free_memmd
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Use lmv_free_memmd for proper cleanup instead of
the generic obd_free_memmd.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 0b1260d..6be2afc 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2692,7 +2692,7 @@ static int lmv_free_lustre_md(struct obd_export *exp, struct lustre_md *md)
 	struct lmv_tgt_desc *tgt = lmv->tgts[0];
 
 	if (md->lmv)
-		obd_free_memmd(exp, (void *)&md->lmv);
+		lmv_free_memmd(md->lmv);
 	if (!tgt || !tgt->ltd_exp)
 		return -EINVAL;
 	return md_free_lustre_md(tgt->ltd_exp, md);
-- 
1.7.1
