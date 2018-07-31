From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:11 -0400
Subject: [lustre-devel] [PATCH 19/31] lustre: obd: remove OBD_NOTIFY_CONFIG
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

None of the OBD notify handlers listen for the OBD_NOTIFY_CONFIG
event so remove it and its sole use in server_start_targets()
which is on the server side.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-id: https://jira.whamcloud.com/browse/LU-8403
Reviewed-on: https://review.whamcloud.com/21422
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 5bf2be8..10e3bb8 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -491,8 +491,6 @@ enum obd_notify_event {
 	OBD_NOTIFY_INACTIVE,
 	/* Connect data for import were changed */
 	OBD_NOTIFY_OCD,
-	/* Configuration event */
-	OBD_NOTIFY_CONFIG,
 	/* Administratively deactivate/activate event */
 	OBD_NOTIFY_DEACTIVATE,
 	OBD_NOTIFY_ACTIVATE
-- 
1.8.3.1
