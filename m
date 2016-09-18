From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:44 -0400
Subject: [lustre-devel] [PATCH 045/124] staging: lustre: lmv: remove dead
	code
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-46-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

The member lmv_obd->server_timeout and function lmv_set_timeouts()
are not used.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-991
Reviewed-on: http://review.whamcloud.com/11880
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h |    1 -
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |   25 -------------------------
 2 files changed, 0 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 3fbb873..b84600a 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -433,7 +433,6 @@ struct lmv_obd {
 	int			max_def_easize;
 	int			max_cookiesize;
 	int			max_def_cookiesize;
-	int			server_timeout;
 
 	u32			tgts_size; /* size of tgts array */
 	struct lmv_tgt_desc	**tgts;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 53de385..8033ae2 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -302,30 +302,6 @@ static int lmv_connect(const struct lu_env *env,
 	return rc;
 }
 
-static void lmv_set_timeouts(struct obd_device *obd)
-{
-	struct lmv_obd	*lmv;
-	u32 i;
-
-	lmv = &obd->u.lmv;
-	if (lmv->server_timeout == 0)
-		return;
-
-	if (lmv->connected == 0)
-		return;
-
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		struct lmv_tgt_desc *tgt = lmv->tgts[i];
-
-		tgt = lmv->tgts[i];
-		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
-			continue;
-
-		obd_set_info_async(NULL, tgt->ltd_exp, sizeof(KEY_INTERMDS),
-				   KEY_INTERMDS, 0, NULL, NULL);
-	}
-}
-
 static int lmv_init_ea_size(struct obd_export *exp, int easize,
 			    int def_easize, int cookiesize, int def_cookiesize)
 {
@@ -616,7 +592,6 @@ int lmv_check_connect(struct obd_device *obd)
 			goto out_disc;
 	}
 
-	lmv_set_timeouts(obd);
 	class_export_put(lmv->exp);
 	lmv->connected = 1;
 	easize = lmv_mds_md_size(lmv->desc.ld_tgt_count, LMV_MAGIC);
-- 
1.7.1
