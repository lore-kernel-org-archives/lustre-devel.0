From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:52 -0500
Subject: [lustre-devel] [PATCH 24/60] staging: lustre: lustre: Remove old
	commented out code
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ben Evans <bevans@cray.com>, James Simmons <jsimmons@infradead.org>

From: Ben Evans <bevans@cray.com>

These #if 0 blocks have been in place for years. Assume
they are not used and remove them

Signed-off-by: Ben Evans <bevans@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8058
Reviewed-on: http://review.whamcloud.com/20416
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h     | 2 --
 drivers/staging/lustre/lustre/lmv/lmv_obd.c     | 9 +--------
 drivers/staging/lustre/lustre/mdc/mdc_request.c | 8 +-------
 3 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 5c217c0..ab47078 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -483,8 +483,6 @@ enum obd_notify_event {
 	OBD_NOTIFY_ACTIVE,
 	/* Device deactivated */
 	OBD_NOTIFY_INACTIVE,
-	/* Device disconnected */
-	OBD_NOTIFY_DISCON,
 	/* Connect data for import were changed */
 	OBD_NOTIFY_OCD,
 	/* Sync request */
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 5926461..271e189 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -173,14 +173,7 @@ static int lmv_notify(struct obd_device *obd, struct obd_device *watched,
 		 */
 		obd->obd_self_export->exp_connect_data = *conn_data;
 	}
-#if 0
-	else if (ev == OBD_NOTIFY_DISCON) {
-		/*
-		 * For disconnect event, flush fld cache for failout MDS case.
-		 */
-		fld_client_flush(&lmv->lmv_fld);
-	}
-#endif
+
 	/*
 	 * Pass the notification up the chain.
 	 */
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 2cfd913..02f57d8 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2465,13 +2465,6 @@ static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 	LASSERT(imp->imp_obd == obd);
 
 	switch (event) {
-	case IMP_EVENT_DISCON: {
-#if 0
-		/* XXX Pass event up to OBDs stack. used only for FLD now */
-		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_DISCON, NULL);
-#endif
-		break;
-	}
 	case IMP_EVENT_INACTIVE: {
 		struct client_obd *cli = &obd->u.cli;
 		/*
@@ -2503,6 +2496,7 @@ static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 	case IMP_EVENT_OCD:
 		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_OCD, NULL);
 		break;
+	case IMP_EVENT_DISCON:
 	case IMP_EVENT_DEACTIVATE:
 	case IMP_EVENT_ACTIVATE:
 		break;
-- 
1.8.3.1
