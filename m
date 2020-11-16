From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:50 -0500
Subject: [lustre-devel] [PATCH 17/28] lustre: ptlrpc: decrease time between
 reconnection
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <alexander.boyko@hpe.com>

When a connection get a timeout or get an error reply from a sever,
the next attempt happens after PING_INTERVAL. It is equal to
obd_timeout/4. When a first reconnection fails, a second go to
failover pair. And a third connection go to a original server.
Only 3 reconnection before server evicts client base on blocking
ast timeout. Some times a first failed and the last is a bit late,
so client is evicted. It is better to try reconnect with a timeout
equal to a connection request deadline, it would increase a number
of attempts in 5 times for a large obd_timeout. For example,
    obd_timeout=200
     - [ 1597902357, CONNECTING ]
     - [ 1597902357, FULL ]
     - [ 1597902422, DISCONN ]
     - [ 1597902422, CONNECTING ]
     - [ 1597902433, DISCONN ]
     - [ 1597902473, CONNECTING ]
     - [ 1597902473, DISCONN ] <- ENODEV from a failover pair
     - [ 1597902523, CONNECTING ]
     - [ 1597902539, DISCONN ]

The patch adds a logic to wakeup pinger for failed connection request
with ETIMEDOUT or ENODEV. It adds imp_next_ping processing for
ptlrpc_pinger_main() time_to_next_wake calculation, and fixes setting
of imp_next_ping value.

HPE-bug-id: LUS-8520
WC-bug-id: https://jira.whamcloud.com/browse/LU-14031
Lustre-commit: de8ed5f19f0413 ("LU-14031 ptlrpc: decrease time between reconnection")
Signed-off-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-on: https://review.whamcloud.com/40244
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/events.c |  5 ++++
 fs/lustre/ptlrpc/import.c | 36 ++++++++++++++++++++++-
 fs/lustre/ptlrpc/niobuf.c |  2 --
 fs/lustre/ptlrpc/pinger.c | 73 ++++++++++++++++++++++++++++++-----------------
 4 files changed, 87 insertions(+), 29 deletions(-)

diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index 0943612..fe33600 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -59,6 +59,11 @@ void request_out_callback(struct lnet_event *ev)
 
 	DEBUG_REQ(D_NET, req, "type %d, status %d", ev->type, ev->status);
 
+	/* Do not update imp_next_ping for connection request */
+	if (lustre_msg_get_opc(req->rq_reqmsg) !=
+	    req->rq_import->imp_connect_op)
+		ptlrpc_pinger_sending_on_import(req->rq_import);
+
 	sptlrpc_request_out_callback(req);
 
 	spin_lock(&req->rq_lock);
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 4e573cd..21ce593 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1037,7 +1037,6 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		 */
 		imp->imp_force_reconnect = ptlrpc_busy_reconnect(rc);
 		spin_unlock(&imp->imp_lock);
-		ptlrpc_maybe_ping_import_soon(imp);
 		goto out;
 	}
 
@@ -1303,6 +1302,8 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 
 	if (rc) {
 		bool inact = false;
+		time64_t now = ktime_get_seconds();
+		time64_t next_connect;
 
 		import_set_state_nolock(imp, LUSTRE_IMP_DISCON);
 		if (rc == -EACCES) {
@@ -1344,7 +1345,28 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 				import_set_state_nolock(imp, LUSTRE_IMP_CLOSED);
 				inact = true;
 			}
+		} else if (rc == -ENODEV || rc == -ETIMEDOUT) {
+			/* ENODEV means there is no service, force reconnection
+			 * to a pair if attempt happen ptlrpc_next_reconnect
+			 * before now. ETIMEDOUT could be set during network
+			 * error and do not guarantee request deadline happened.
+			 */
+			struct obd_import_conn *conn;
+			time64_t reconnect_time;
+
+			/* Same as ptlrpc_next_reconnect, but in past */
+			reconnect_time = now - INITIAL_CONNECT_TIMEOUT;
+			list_for_each_entry(conn, &imp->imp_conn_list,
+					    oic_item) {
+				if (conn->oic_last_attempt <= reconnect_time) {
+					imp->imp_force_verify = 1;
+					break;
+				}
+			}
 		}
+
+		next_connect = imp->imp_conn_current->oic_last_attempt +
+			       (request->rq_deadline - request->rq_sent);
 		spin_unlock(&imp->imp_lock);
 
 		if (inact)
@@ -1353,6 +1375,18 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		if (rc == -EPROTO)
 			return rc;
 
+		/* adjust imp_next_ping to request deadline + 1 and reschedule
+		 * a pinger if import lost processing during CONNECTING or far
+		 * away from request deadline. It could happen when connection
+		 * was initiated outside of pinger, like
+		 * ptlrpc_set_import_discon().
+		 */
+		if (!imp->imp_force_verify && (imp->imp_next_ping <= now ||
+		    imp->imp_next_ping > next_connect)) {
+			imp->imp_next_ping = max(now, next_connect) + 1;
+			ptlrpc_pinger_wake_up();
+		}
+
 		ptlrpc_maybe_ping_import_soon(imp);
 
 		CDEBUG(D_HA, "recovery of %s on %s failed (%d)\n",
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 924b9c4..a1e6581 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -701,8 +701,6 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	request->rq_deadline = request->rq_sent + request->rq_timeout +
 			       ptlrpc_at_get_net_latency(request);
 
-	ptlrpc_pinger_sending_on_import(imp);
-
 	DEBUG_REQ(D_INFO, request, "send flags=%x",
 		  lustre_msg_get_flags(request->rq_reqmsg));
 	rc = ptl_send_buf(&request->rq_req_md_h,
diff --git a/fs/lustre/ptlrpc/pinger.c b/fs/lustre/ptlrpc/pinger.c
index e23ba3c..178153c 100644
--- a/fs/lustre/ptlrpc/pinger.c
+++ b/fs/lustre/ptlrpc/pinger.c
@@ -108,6 +108,21 @@ static bool ptlrpc_check_import_is_idle(struct obd_import *imp)
 	return true;
 }
 
+static void ptlrpc_update_next_ping(struct obd_import *imp, int soon)
+{
+#ifdef CONFIG_LUSTRE_FS_PINGER
+	time64_t time = soon ? PING_INTERVAL_SHORT : PING_INTERVAL;
+
+	if (imp->imp_state == LUSTRE_IMP_DISCON) {
+		time64_t dtime = max_t(time64_t, CONNECTION_SWITCH_MIN,
+				  AT_OFF ? 0 :
+				  at_get(&imp->imp_at.iat_net_latency));
+		time = min(time, dtime);
+	}
+	imp->imp_next_ping = ktime_get_seconds() + time;
+#endif
+}
+
 static int ptlrpc_ping(struct obd_import *imp)
 {
 	struct ptlrpc_request *req;
@@ -125,26 +140,17 @@ static int ptlrpc_ping(struct obd_import *imp)
 
 	DEBUG_REQ(D_INFO, req, "pinging %s->%s",
 		  imp->imp_obd->obd_uuid.uuid, obd2cli_tgt(imp->imp_obd));
+	/* Updating imp_next_ping early, it allows pinger_check_timeout to
+	 * see an actual time for next awake. request_out_callback update
+	 * happens at another thread, and ptlrpc_pinger_main may sleep
+	 * already.
+	 */
+	ptlrpc_update_next_ping(imp, 0);
 	ptlrpcd_add_req(req);
 
 	return 0;
 }
 
-static void ptlrpc_update_next_ping(struct obd_import *imp, int soon)
-{
-#ifdef CONFIG_LUSTRE_FS_PINGER
-	time64_t time = soon ? PING_INTERVAL_SHORT : PING_INTERVAL;
-
-	if (imp->imp_state == LUSTRE_IMP_DISCON) {
-		time64_t dtime = max_t(time64_t, CONNECTION_SWITCH_MIN,
-				  AT_OFF ? 0 :
-				  at_get(&imp->imp_at.iat_net_latency));
-		time = min(time, dtime);
-	}
-	imp->imp_next_ping = ktime_get_seconds() + time;
-#endif
-}
-
 static inline int imp_is_deactive(struct obd_import *imp)
 {
 	return (imp->imp_deactive ||
@@ -153,17 +159,32 @@ static inline int imp_is_deactive(struct obd_import *imp)
 
 static inline time64_t ptlrpc_next_reconnect(struct obd_import *imp)
 {
-	if (imp->imp_server_timeout)
-		return ktime_get_seconds() + (obd_timeout >> 1);
-	else
-		return ktime_get_seconds() + obd_timeout;
+	return ktime_get_seconds() + INITIAL_CONNECT_TIMEOUT;
 }
 
-static time64_t pinger_check_timeout(time64_t time)
+static timeout_t pinger_check_timeout(time64_t time)
 {
-	time64_t timeout = PING_INTERVAL;
+	timeout_t timeout = PING_INTERVAL;
+	timeout_t next_timeout;
+	time64_t now;
+	struct list_head *iter;
+	struct obd_import *imp;
+
+	mutex_lock(&pinger_mutex);
+	now = ktime_get_seconds();
+	/* Process imports to find a nearest next ping */
+	list_for_each(iter, &pinger_imports) {
+		imp = list_entry(iter, struct obd_import, imp_pinger_chain);
+		if (!imp->imp_pingable || imp->imp_next_ping < now)
+			continue;
+		next_timeout = imp->imp_next_ping - now;
+		/* make sure imp_next_ping in the future from time */
+		if (next_timeout > (now - time) && timeout > next_timeout)
+			timeout = next_timeout;
+	}
+	mutex_unlock(&pinger_mutex);
 
-	return time + timeout - ktime_get_seconds();
+	return timeout - (now - time);
 }
 
 static bool ir_up;
@@ -245,7 +266,8 @@ static void ptlrpc_pinger_process_import(struct obd_import *imp,
 
 static void ptlrpc_pinger_main(struct work_struct *ws)
 {
-	time64_t this_ping, time_after_ping, time_to_next_wake;
+	time64_t this_ping, time_after_ping;
+	timeout_t time_to_next_wake;
 	struct obd_import *imp;
 
 	do {
@@ -276,9 +298,8 @@ static void ptlrpc_pinger_main(struct work_struct *ws)
 		 * we will SKIP the next ping at next_ping, and the
 		 * ping will get sent 2 timeouts from now!  Beware.
 		 */
-		CDEBUG(D_INFO, "next wakeup in %lld (%lld)\n",
-		       time_to_next_wake,
-		       this_ping + PING_INTERVAL);
+		CDEBUG(D_INFO, "next wakeup in %d (%lld)\n",
+		       time_to_next_wake, this_ping + PING_INTERVAL);
 	} while (time_to_next_wake <= 0);
 
 	queue_delayed_work(pinger_wq, &ping_work,
-- 
1.8.3.1
