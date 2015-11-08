From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Sun,  8 Nov 2015 22:22:58 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: mdc_request: Remove
	mdc_kuc_reregister wrapper
Message-ID: <1447001578-4161-1-git-send-email-shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove the wrapper function mdc_kuc_reregister() and replace its call
with the function it wrapped. Also, comment has been added for clarity.

Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 294c050..e172be1 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2037,17 +2037,6 @@ static int mdc_hsm_ct_reregister(__u32 data, void *cb_arg)
 	return ((rc != 0) && (rc != -EEXIST)) ? rc : 0;
 }
 
-/**
- * Re-establish all kuc contexts with MDT
- * after MDT shutdown/recovery.
- */
-static int mdc_kuc_reregister(struct obd_import *imp)
-{
-	/* re-register HSM agents */
-	return libcfs_kkuc_group_foreach(KUC_GRP_HSM, mdc_hsm_ct_reregister,
-					 (void *)imp);
-}
-
 static int mdc_set_info_async(const struct lu_env *env,
 			      struct obd_export *exp,
 			      u32 keylen, void *key,
@@ -2210,7 +2199,10 @@ static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_ACTIVE, NULL);
 		/* redo the kuc registration after reconnecting */
 		if (rc == 0)
-			rc = mdc_kuc_reregister(imp);
+			/* re-register HSM agents */
+			rc = libcfs_kkuc_group_foreach(KUC_GRP_HSM,
+						       mdc_hsm_ct_reregister,
+						       (void *)imp);
 		break;
 	case IMP_EVENT_OCD:
 		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_OCD, NULL);
-- 
2.1.0
