From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:58 -0500
Subject: [lustre-devel] [PATCH 190/622] lustre: lov: cl_cache could miss
 initialize
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-191-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Yang Sheng <ys@whamcloud.com>

The cl_cache may be missed initialize when we mount
a client with deactivate osc and then active it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11658
Lustre-commit: 42e83c44eb5a ("LU-11658 lov: cl_cache could miss initialize")
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33650
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_obd.c | 46 +++++++++++++++++++++++++++++-----------------
 1 file changed, 29 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index a16c663..08d7edc 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -360,23 +360,6 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 		tgt = lov->lov_tgts[index];
 		if (!tgt)
 			continue;
-		/*
-		 * LU-642, initially inactive OSC could miss the obd_connect,
-		 * we make up for it here.
-		 */
-		if (ev == OBD_NOTIFY_ACTIVATE && !tgt->ltd_exp &&
-		    obd_uuid_equals(uuid, &tgt->ltd_uuid)) {
-			struct obd_uuid lov_osc_uuid = {"LOV_OSC_UUID"};
-
-			obd_connect(NULL, &tgt->ltd_exp, tgt->ltd_obd,
-				    &lov_osc_uuid, &lov->lov_ocd, NULL);
-		}
-		if (!tgt->ltd_exp)
-			continue;
-
-		CDEBUG(D_INFO, "lov idx %d is %s conn %#llx\n",
-		       index, obd_uuid2str(&tgt->ltd_uuid),
-		       tgt->ltd_exp->exp_handle.h_cookie);
 		if (obd_uuid_equals(uuid, &tgt->ltd_uuid))
 			break;
 	}
@@ -389,6 +372,31 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 	if (ev == OBD_NOTIFY_DEACTIVATE || ev == OBD_NOTIFY_ACTIVATE) {
 		activate = (ev == OBD_NOTIFY_ACTIVATE) ? 1 : 0;
 
+		/*
+		 * LU-642, initially inactive OSC could miss the obd_connect,
+		 * we make up for it here.
+		 */
+		if (activate && !tgt->ltd_exp) {
+			int rc;
+			struct obd_uuid lov_osc_uuid = {"LOV_OSC_UUID"};
+
+			rc = obd_connect(NULL, &tgt->ltd_exp, tgt->ltd_obd,
+					 &lov_osc_uuid, &lov->lov_ocd, NULL);
+			if (rc || !tgt->ltd_exp) {
+				index = rc;
+				goto out;
+			}
+			rc = obd_set_info_async(NULL, tgt->ltd_exp,
+						sizeof(KEY_CACHE_SET),
+						KEY_CACHE_SET,
+						sizeof(struct cl_client_cache),
+						lov->lov_cache, NULL);
+			if (rc < 0) {
+				index = rc;
+				goto out;
+			}
+		}
+
 		if (lov->lov_tgts[index]->ltd_activate == activate) {
 			CDEBUG(D_INFO, "OSC %s already %sactivate!\n",
 			       uuid->uuid, activate ? "" : "de");
@@ -421,6 +429,10 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 		CERROR("Unknown event(%d) for uuid %s", ev, uuid->uuid);
 	}
 
+	if (tgt->ltd_exp)
+		CDEBUG(D_INFO, "%s: lov idx %d conn %llx\n", obd_uuid2str(uuid),
+		       index, tgt->ltd_exp->exp_handle.h_cookie);
+
 out:
 	lov_tgts_putref(obd);
 	return index;
-- 
1.8.3.1
