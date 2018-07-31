From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:08 -0400
Subject: [lustre-devel] [PATCH 16/31] lustre: obd: remove OBD_NOTIFY_SYNC{,
 _NONBLOCK}
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

None of the OBD notify handlers listen for OBD_NOTIFY_SYNC{,_NONBLOCK}
events so remove them and related code in lov_notify().

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-id: https://jira.whamcloud.com/browse/LU-8403
Reviewed-on: https://review.whamcloud.com/21421
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h |  3 --
 drivers/staging/lustre/lustre/lov/lov_obd.c | 52 +++++------------------------
 2 files changed, 9 insertions(+), 46 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 62f85a1..5bf2be8 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -491,9 +491,6 @@ enum obd_notify_event {
 	OBD_NOTIFY_INACTIVE,
 	/* Connect data for import were changed */
 	OBD_NOTIFY_OCD,
-	/* Sync request */
-	OBD_NOTIFY_SYNC_NONBLOCK,
-	OBD_NOTIFY_SYNC,
 	/* Configuration event */
 	OBD_NOTIFY_CONFIG,
 	/* Administratively deactivate/activate event */
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 0dd471c..85d3b29 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -429,10 +429,8 @@ static int lov_notify(struct obd_device *obd, struct obd_device *watched,
 	struct lov_obd *lov = &obd->u.lov;
 
 	down_read(&lov->lov_notify_lock);
-	if (!lov->lov_connects) {
-		up_read(&lov->lov_notify_lock);
-		return rc;
-	}
+	if (!lov->lov_connects)
+		goto out_notify_lock;
 
 	if (ev == OBD_NOTIFY_ACTIVE || ev == OBD_NOTIFY_INACTIVE ||
 	    ev == OBD_NOTIFY_ACTIVATE || ev == OBD_NOTIFY_DEACTIVATE) {
@@ -441,12 +439,13 @@ static int lov_notify(struct obd_device *obd, struct obd_device *watched,
 		LASSERT(watched);
 
 		if (strcmp(watched->obd_type->typ_name, LUSTRE_OSC_NAME)) {
-			up_read(&lov->lov_notify_lock);
 			CERROR("unexpected notification of %s %s!\n",
 			       watched->obd_type->typ_name,
 			       watched->obd_name);
-			return -EINVAL;
+			rc = -EINVAL;
+			goto out_notify_lock;
 		}
+
 		uuid = &watched->u.cli.cl_target_uuid;
 
 		/* Set OSC as active before notifying the observer, so the
@@ -454,53 +453,20 @@ static int lov_notify(struct obd_device *obd, struct obd_device *watched,
 		 */
 		rc = lov_set_osc_active(obd, uuid, ev);
 		if (rc < 0) {
-			up_read(&lov->lov_notify_lock);
 			CERROR("event(%d) of %s failed: %d\n", ev,
 			       obd_uuid2str(uuid), rc);
-			return rc;
+			goto out_notify_lock;
 		}
 		/* active event should be pass lov target index as data */
 		data = &rc;
 	}
 
 	/* Pass the notification up the chain. */
-	if (watched) {
-		rc = obd_notify_observer(obd, watched, ev, data);
-	} else {
-		/* NULL watched means all osc's in the lov (only for syncs) */
-		/* sync event should be send lov idx as data */
-		struct lov_obd *lov = &obd->u.lov;
-		int i, is_sync;
-
-		data = &i;
-		is_sync = (ev == OBD_NOTIFY_SYNC) ||
-			  (ev == OBD_NOTIFY_SYNC_NONBLOCK);
-
-		obd_getref(obd);
-		for (i = 0; i < lov->desc.ld_tgt_count; i++) {
-			if (!lov->lov_tgts[i])
-				continue;
-
-			/* don't send sync event if target not
-			 * connected/activated
-			 */
-			if (is_sync &&  !lov->lov_tgts[i]->ltd_active)
-				continue;
-
-			rc = obd_notify_observer(obd, lov->lov_tgts[i]->ltd_obd,
-						 ev, data);
-			if (rc) {
-				CERROR("%s: notify %s of %s failed %d\n",
-				       obd->obd_name,
-				       obd->obd_observer->obd_name,
-				       lov->lov_tgts[i]->ltd_obd->obd_name,
-				       rc);
-			}
-		}
-		obd_putref(obd);
-	}
+	rc = obd_notify_observer(obd, watched, ev, data);
 
+out_notify_lock:
 	up_read(&lov->lov_notify_lock);
+
 	return rc;
 }
 
-- 
1.8.3.1
