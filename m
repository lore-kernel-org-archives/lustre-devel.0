From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:29 -0500
Subject: [lustre-devel] [PATCH 521/622] lustre: osc: don't re-enable grant
 shrink on reconnect
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-522-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Zarochentsev <c17826@cray.com>

client requests grant shrinking support on each
reconnect and re-enables the capability even it was
explicitly disabled by lctl set_param.

Cray-bug-id: LUS-7585
WC-bug-id: https://jira.whamcloud.com/browse/LU-12759
Lustre-commit: efa3425c5f5a ("LU-12759 osc: don't re-enable grant shrink on reconnect")
Signed-off-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-on: https://review.whamcloud.com/36177
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h |  4 +++-
 fs/lustre/osc/lproc_osc.c         | 32 +++++++++-----------------------
 fs/lustre/osc/osc_request.c       |  4 ++--
 3 files changed, 14 insertions(+), 26 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index c2f98e6..501a896 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -303,7 +303,9 @@ struct obd_import {
 					/* import has tried to connect with server */
 					imp_connect_tried:1,
 					/* connected but not FULL yet */
-					imp_connected:1;
+					imp_connected:1,
+				  /* grant shrink disabled */
+				  imp_grant_shrink_disabled:1;
 
 	u32				imp_connect_op;
 	u32				imp_idle_timeout;
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 8e0088b..2bc7047 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -695,18 +695,17 @@ static ssize_t grant_shrink_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	struct client_obd *cli = &obd->u.cli;
-	struct obd_connect_data *ocd;
+	struct obd_import *imp;
 	ssize_t len;
 
 	len = lprocfs_climp_check(obd);
 	if (len)
 		return len;
 
-	ocd = &cli->cl_import->imp_connect_data;
-
+	imp = obd->u.cli.cl_import;
 	len = snprintf(buf, PAGE_SIZE, "%d\n",
-		       !!OCD_HAS_FLAG(ocd, GRANT_SHRINK));
+		       !imp->imp_grant_shrink_disabled &&
+		       OCD_HAS_FLAG(&imp->imp_connect_data, GRANT_SHRINK));
 	up_read(&obd->u.cli.cl_sem);
 
 	return len;
@@ -717,8 +716,7 @@ static ssize_t grant_shrink_store(struct kobject *kobj, struct attribute *attr,
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	struct client_obd *cli = &dev->u.cli;
-	struct obd_connect_data *ocd;
+	struct obd_import *imp;
 	bool val;
 	int rc;
 
@@ -733,22 +731,10 @@ static ssize_t grant_shrink_store(struct kobject *kobj, struct attribute *attr,
 	if (rc)
 		return rc;
 
-	ocd = &cli->cl_import->imp_connect_data;
-
-	if (!val) {
-		if (OCD_HAS_FLAG(ocd, GRANT_SHRINK))
-			ocd->ocd_connect_flags &= ~OBD_CONNECT_GRANT_SHRINK;
-	} else {
-		/**
-		 * server replied obd_connect_data is always bigger, so
-		 * client's imp_connect_flags_orig are always supported
-		 * by the server
-		 */
-		if (!OCD_HAS_FLAG(ocd, GRANT_SHRINK) &&
-		    cli->cl_import->imp_connect_flags_orig &
-		    OBD_CONNECT_GRANT_SHRINK)
-			ocd->ocd_connect_flags |= OBD_CONNECT_GRANT_SHRINK;
-	}
+	imp = dev->u.cli.cl_import;
+	spin_lock(&imp->imp_lock);
+	imp->imp_grant_shrink_disabled = !val;
+	spin_unlock(&imp->imp_lock);
 
 	up_read(&dev->u.cli.cl_sem);
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 9c43756..39cac7d 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -844,8 +844,8 @@ static int osc_should_shrink_grant(struct client_obd *client)
 	if (!client->cl_import)
 		return 0;
 
-	if ((client->cl_import->imp_connect_data.ocd_connect_flags &
-	     OBD_CONNECT_GRANT_SHRINK) == 0)
+	if (!OCD_HAS_FLAG(&client->cl_import->imp_connect_data, GRANT_SHRINK) ||
+	    client->cl_import->imp_grant_shrink_disabled)
 		return 0;
 
 	if (ktime_get_seconds() >= next_shrink - 5) {
-- 
1.8.3.1
