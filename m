From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:43:55 -0400
Subject: [lustre-devel] [PATCH 02/58] staging: lustre: obd: rename struct
	lmv_stripe_md field mea to lmv
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Rename struct lmv_stripe_md in struct lustre_md from mea
to lmv.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h     |    2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c     |    4 ++--
 drivers/staging/lustre/lustre/mdc/mdc_request.c |    8 ++++----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index e6fca90..1575c82 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -1031,7 +1031,7 @@ enum {
 struct lustre_md {
 	struct mdt_body	 *body;
 	struct lov_stripe_md    *lsm;
-	struct lmv_stripe_md    *mea;
+	struct lmv_stripe_md    *lmv;
 #ifdef CONFIG_FS_POSIX_ACL
 	struct posix_acl	*posix_acl;
 #endif
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 0e1588a..fac04f0 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2571,8 +2571,8 @@ static int lmv_free_lustre_md(struct obd_export *exp, struct lustre_md *md)
 	struct lmv_obd	  *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt = lmv->tgts[0];
 
-	if (md->mea)
-		obd_free_memmd(exp, (void *)&md->mea);
+	if (md->lmv)
+		obd_free_memmd(exp, (void *)&md->lmv);
 	if (!tgt || !tgt->ltd_exp)
 		return -EINVAL;
 	return md_free_lustre_md(tgt->ltd_exp, md);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index d4cc73b..4fc3f9b 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -504,15 +504,15 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 				goto out;
 			}
 
-			rc = obd_unpackmd(md_exp, (void *)&md->mea, lmv,
+			rc = obd_unpackmd(md_exp, (void *)&md->lmv, lmv,
 					  lmvsize);
 			if (rc < 0)
 				goto out;
 
-			if (rc < sizeof(*md->mea)) {
+			if (rc < sizeof(*md->lmv)) {
 				CDEBUG(D_INFO,
-				       "size too small: rc < sizeof(*md->mea) (%d < %d)\n",
-					rc, (int)sizeof(*md->mea));
+				       "size too small: rc < sizeof(*md->lmv) (%d < %d)\n",
+					rc, (int)sizeof(*md->lmv));
 				rc = -EPROTO;
 				goto out;
 			}
-- 
1.7.1
