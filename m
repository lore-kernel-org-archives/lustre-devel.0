From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:42 -0400
Subject: [lustre-devel] [PATCH 043/124] staging: lustre: lmv: change type of
	lmv_obd->tgts_size to u32
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-44-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

tgts_size is used as unsigned.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5577
Reviewed-on: http://review.whamcloud.com/11881
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h |    2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 4b72fb9..27fb4d7 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -435,7 +435,7 @@ struct lmv_obd {
 	int			max_def_cookiesize;
 	int			server_timeout;
 
-	int			tgts_size; /* size of tgts array */
+	u32			tgts_size; /* size of tgts array */
 	struct lmv_tgt_desc	**tgts;
 
 	struct obd_connect_data	conn_data;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index b852a65..53de385 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1355,10 +1355,10 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		return -EINVAL;
 	}
 
-	lmv->tgts = kcalloc(32, sizeof(*lmv->tgts), GFP_NOFS);
+	lmv->tgts_size = 32U;
+	lmv->tgts = kcalloc(lmv->tgts_size, sizeof(*lmv->tgts), GFP_NOFS);
 	if (!lmv->tgts)
 		return -ENOMEM;
-	lmv->tgts_size = 32;
 
 	obd_str2uuid(&lmv->desc.ld_uuid, desc->ld_uuid.uuid);
 	lmv->desc.ld_tgt_count = 0;
-- 
1.7.1
