From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:44 -0500
Subject: [lustre-devel] [PATCH 116/622] lustre: ptlrpc: add debugging for
 idle connections
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-117-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Add a "debug" parameter for the idle client disconnection so that
it can log disconnect/reconnect events to the console.

Print the idle time in the "import" file.

Enable the connection debugging for all test runs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11128
Lustre-commit: 0aa58d26f5df ("LU-11128 ptlrpc: add debugging for idle connections")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33168
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Nathaniel Clark <nclark@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h   |  1 +
 fs/lustre/obdclass/lprocfs_status.c |  6 ++++--
 fs/lustre/osc/lproc_osc.c           | 34 ++++++++++++++++++++++------------
 fs/lustre/osc/osc_request.c         |  1 +
 fs/lustre/ptlrpc/client.c           |  6 ++++--
 fs/lustre/ptlrpc/import.c           |  4 +++-
 6 files changed, 35 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index c4452e1..1fd6246 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -304,6 +304,7 @@ struct obd_import {
 
 	u32				imp_connect_op;
 	u32				imp_idle_timeout;
+	u32				imp_idle_debug;
 	struct obd_connect_data		imp_connect_data;
 	u64				imp_connect_flags_orig;
 	u64				imp_connect_flags2_orig;
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index fbd46df..747baff 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -802,11 +802,13 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 		   "       current_connection: %s\n"
 		   "       connection_attempts: %u\n"
 		   "       generation: %u\n"
-		   "       in-progress_invalidations: %u\n",
+		   "       in-progress_invalidations: %u\n"
+		   "       idle: %lld sec\n",
 		   nidstr,
 		   imp->imp_conn_cnt,
 		   imp->imp_generation,
-		   atomic_read(&imp->imp_inval_count));
+		   atomic_read(&imp->imp_inval_count),
+		   ktime_get_real_seconds() - imp->imp_last_reply_time);
 	spin_unlock(&imp->imp_lock);
 
 	if (!obd->obd_svc_stats)
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 16de266..f025275 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -622,27 +622,37 @@ static ssize_t idle_timeout_store(struct kobject *kobj, struct attribute *attr,
 					      obd_kset.kobj);
 	struct client_obd *cli = &obd->u.cli;
 	struct ptlrpc_request *req;
+	unsigned int idle_debug = 0;
 	unsigned int val;
 	int rc;
 
-	rc = kstrtouint(buffer, 0, &val);
-	if (rc)
-		return rc;
+	if (strncmp(buffer, "debug", 5) == 0) {
+		idle_debug = D_CONSOLE;
+	} else if (strncmp(buffer, "nodebug", 6) == 0) {
+		idle_debug = D_HA;
+	} else {
+		rc = kstrtouint(buffer, 0, &val);
+		if (rc)
+			return rc;
 
-	if (val > CONNECTION_SWITCH_MAX)
-		return -ERANGE;
+		if (val > CONNECTION_SWITCH_MAX)
+			return -ERANGE;
+	}
 
 	rc = lprocfs_climp_check(obd);
 	if (rc)
 		return rc;
 
-	cli->cl_import->imp_idle_timeout = val;
-
-	/* to initiate the connection if it's in IDLE state */
-	if (!val) {
-		req = ptlrpc_request_alloc(cli->cl_import, &RQF_OST_STATFS);
-		if (req)
-			ptlrpc_req_finished(req);
+	if (idle_debug) {
+		cli->cl_import->imp_idle_timeout = val;
+	} else {
+		/* to initiate the connection if it's in IDLE state */
+		if (!val) {
+			req = ptlrpc_request_alloc(cli->cl_import,
+						   &RQF_OST_STATFS);
+			if (req)
+				ptlrpc_req_finished(req);
+		}
 	}
 	up_read(&obd->u.cli.cl_sem);
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 1a9ed8d..2784e1e 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -3271,6 +3271,7 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	list_add_tail(&cli->cl_shrink_list, &osc_shrink_list);
 	spin_unlock(&osc_shrink_lock);
 	cli->cl_import->imp_idle_timeout = osc_idle_timeout;
+	cli->cl_import->imp_idle_debug = D_HA;
 
 	return rc;
 
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 57b08de..691df1a 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -890,8 +890,10 @@ struct ptlrpc_request *__ptlrpc_request_alloc(struct obd_import *imp,
 	if (unlikely(imp->imp_state == LUSTRE_IMP_IDLE)) {
 		int rc;
 
-		CDEBUG(D_INFO, "%s: connect at new req\n",
-		       imp->imp_obd->obd_name);
+		CDEBUG_LIMIT(imp->imp_idle_debug,
+			     "%s: reconnect after %llds idle\n",
+			     imp->imp_obd->obd_name, ktime_get_real_seconds() -
+						     imp->imp_last_reply_time);
 		spin_lock(&imp->imp_lock);
 		if (imp->imp_state == LUSTRE_IMP_IDLE) {
 			imp->imp_generation++;
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index b90f78c..b11bb2f 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1623,7 +1623,9 @@ int ptlrpc_disconnect_and_idle_import(struct obd_import *imp)
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 
-	CDEBUG(D_INFO, "%s: disconnect\n", imp->imp_obd->obd_name);
+	CDEBUG_LIMIT(imp->imp_idle_debug, "%s: disconnect after %llus idle\n",
+		     imp->imp_obd->obd_name,
+		     ktime_get_real_seconds() - imp->imp_last_reply_time);
 	req->rq_interpret_reply = ptlrpc_disconnect_idle_interpret;
 	ptlrpcd_add_req(req);
 
-- 
1.8.3.1
