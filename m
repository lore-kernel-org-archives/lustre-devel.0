From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:04 -0400
Subject: [lustre-devel] [PATCH 005/124] staging: lustre: obdclass: optimize
	busy loop wait
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Zarochentsev <alexander_zarochentsev@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Alexander Zarochentsev <alexander_zarochentsev@xyratex.com>

two optimizations in the busy loop wait in class_cleanup():
(1) remove unnecessary spinlocks protecting obd_conn_inprogress
    access
(2) replace cond_resched by more suitable yield to unconditionally
    yield the CPU if the condition check fails.

Signed-off-by: Alexander Zarochentsev <alexander_zarochentsev@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5397
Xyratex-bug-id: MRP-1991
Reviewed-on: http://review.whamcloud.com/11198
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/obdclass/obd_config.c    |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 036f396..fddfc9c 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -414,17 +414,12 @@ static int class_cleanup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	}
 	/* Leave this on forever */
 	obd->obd_stopping = 1;
-
-	/* wait for already-arrived-connections to finish. */
-	while (obd->obd_conn_inprogress > 0) {
-		spin_unlock(&obd->obd_dev_lock);
-
-		cond_resched();
-
-		spin_lock(&obd->obd_dev_lock);
-	}
 	spin_unlock(&obd->obd_dev_lock);
 
+	while (obd->obd_conn_inprogress > 0)
+		yield();
+	smp_rmb();
+
 	if (lcfg->lcfg_bufcount >= 2 && LUSTRE_CFG_BUFLEN(lcfg, 1) > 0) {
 		for (flag = lustre_cfg_string(lcfg, 1); *flag != 0; flag++)
 			switch (*flag) {
-- 
1.7.1
