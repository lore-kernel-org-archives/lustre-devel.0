From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:23 -0400
Subject: [lustre-devel] [PATCH 10/80] staging: lustre: lmv: remove
	lmv_get_easize
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Completely replace lmv_get_easize with lmv_mds_md_size.
With this change we can delete lmv_get_easize.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_internal.h |    7 -------
 drivers/staging/lustre/lustre/lmv/lmv_obd.c      |    2 +-
 2 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 90a9786..f4c917b 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -55,13 +55,6 @@ int __lmv_fid_alloc(struct lmv_obd *lmv, struct lu_fid *fid, u32 mds);
 int lmv_fid_alloc(struct obd_export *exp, struct lu_fid *fid,
 		  struct md_op_data *op_data);
 
-static inline int lmv_get_easize(struct lmv_obd *lmv)
-{
-	return sizeof(struct lmv_stripe_md) +
-		lmv->desc.ld_tgt_count *
-		sizeof(struct lu_fid);
-}
-
 static inline struct lmv_tgt_desc *
 lmv_get_target(struct lmv_obd *lmv, u32 mds)
 {
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 1ba5900..0b1260d 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -558,7 +558,7 @@ int lmv_check_connect(struct obd_device *obd)
 	lmv_set_timeouts(obd);
 	class_export_put(lmv->exp);
 	lmv->connected = 1;
-	easize = lmv_get_easize(lmv);
+	easize = lmv_mds_md_size(lmv->desc.ld_tgt_count, LMV_MAGIC);
 	lmv_init_ea_size(obd->obd_self_export, easize, 0, 0, 0);
 	mutex_unlock(&lmv->lmv_init_mutex);
 	return 0;
-- 
1.7.1
