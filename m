From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:00 -0400
Subject: [lustre-devel] [PATCH 041/151] lustre: ptlrpc: migrate pinger to 64
 bit time
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-42-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Change imp_next_ping, cl_*grant_* timer fields, and ti_timeout to
time64_t. With these changes the pinger will be 64 bit time
compliant. This prevents any possible confusion with jiffies.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9019
Lustre-commit: 44bdc137c901 ("LU-9019 ptlrpc: migrate pinger to 64 bit time")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/28035
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h  |  2 +-
 fs/lustre/include/lustre_net.h     |  2 +-
 fs/lustre/include/obd.h            |  6 +++---
 fs/lustre/osc/lproc_osc.c          |  2 +-
 fs/lustre/osc/osc_request.c        | 11 +++++-----
 fs/lustre/ptlrpc/client.c          |  7 +++---
 fs/lustre/ptlrpc/import.c          | 36 +++++++++++++++++++------------
 fs/lustre/ptlrpc/pinger.c          | 44 ++++++++++++++++++--------------------
 fs/lustre/ptlrpc/ptlrpc_internal.h |  2 +-
 fs/lustre/ptlrpc/ptlrpcd.c         |  2 +-
 10 files changed, 60 insertions(+), 54 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index fc1f87c..6e22274 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -250,7 +250,7 @@ struct obd_import {
 	 */
 	struct lustre_handle		imp_remote_handle;
 	/** When to perform next ping. time in jiffies. */
-	unsigned long			imp_next_ping;
+	time64_t			imp_next_ping;
 	/** When we last successfully connected. time in 64bit jiffies */
 	u64				imp_last_success_conn;
 
diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 20ce196..a0a974c 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -2287,7 +2287,7 @@ enum timeout_event {
 typedef int (*timeout_cb_t)(struct timeout_item *, void *);
 int ptlrpc_pinger_add_import(struct obd_import *imp);
 int ptlrpc_pinger_del_import(struct obd_import *imp);
-int ptlrpc_add_timeout_client(int time, enum timeout_event event,
+int ptlrpc_add_timeout_client(time64_t time, enum timeout_event event,
 			      timeout_cb_t cb, void *data,
 			      struct list_head *obd_list);
 int ptlrpc_del_timeout_client(struct list_head *obd_list,
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 3bdde31..9514260 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -117,7 +117,7 @@ struct brw_page {
 
 struct timeout_item {
 	enum timeout_event	ti_event;
-	unsigned long		ti_timeout;
+	time64_t		ti_timeout;
 	timeout_cb_t		ti_cb;
 	void		       *ti_cb_data;
 	struct list_head	ti_obd_list;
@@ -203,9 +203,9 @@ struct client_obd {
 	 */
 	long			cl_reserved_grant;
 	wait_queue_head_t	cl_cache_waiters;	/* waiting for cache/grant */
-	unsigned long		cl_next_shrink_grant;   /* jiffies */
+	time64_t		cl_next_shrink_grant;	/* seconds */
 	struct list_head	cl_grant_shrink_list;	/* Timeout event list */
-	int			cl_grant_shrink_interval; /* seconds */
+	time64_t		cl_grant_shrink_interval; /* seconds */
 
 	/* A chunk is an optimal size used by osc_extent to determine
 	 * the extent size. A chunk is max(PAGE_SIZE, OST block size)
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 8e85863..2a57982 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -326,7 +326,7 @@ static ssize_t grant_shrink_interval_show(struct kobject *kobj,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 
-	return sprintf(buf, "%d\n", obd->u.cli.cl_grant_shrink_interval);
+	return sprintf(buf, "%lld\n", obd->u.cli.cl_grant_shrink_interval);
 }
 
 static ssize_t grant_shrink_interval_store(struct kobject *kobj,
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index e703cf1..b84856d 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -716,9 +716,9 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 
 void osc_update_next_shrink(struct client_obd *cli)
 {
-	cli->cl_next_shrink_grant =
-		jiffies + cli->cl_grant_shrink_interval * HZ;
-	CDEBUG(D_CACHE, "next time %ld to shrink grant\n",
+	cli->cl_next_shrink_grant = ktime_get_seconds() +
+				    cli->cl_grant_shrink_interval;
+	CDEBUG(D_CACHE, "next time %lld to shrink grant\n",
 	       cli->cl_next_shrink_grant);
 }
 
@@ -841,14 +841,13 @@ int osc_shrink_grant_to_target(struct client_obd *cli, u64 target_bytes)
 
 static int osc_should_shrink_grant(struct client_obd *client)
 {
-	unsigned long time = jiffies;
-	unsigned long next_shrink = client->cl_next_shrink_grant;
+	time64_t next_shrink = client->cl_next_shrink_grant;
 
 	if ((client->cl_import->imp_connect_data.ocd_connect_flags &
 	     OBD_CONNECT_GRANT_SHRINK) == 0)
 		return 0;
 
-	if (time_after_eq(time, next_shrink - 5)) {
+	if (ktime_get_seconds() >= next_shrink - 5) {
 		/* Get the current RPC size directly, instead of going via:
 		 * cli_brw_size(obd->u.cli.cl_import->imp_obd->obd_self_export)
 		 * Keep comment here so that it can be found by searching.
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 4888578..fc909a8 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -2206,7 +2206,7 @@ static void ptlrpc_interrupted_set(struct ptlrpc_request_set *set)
 /**
  * Get the smallest timeout in the set; this does NOT set a timeout.
  */
-int ptlrpc_set_next_timeout(struct ptlrpc_request_set *set)
+time64_t ptlrpc_set_next_timeout(struct ptlrpc_request_set *set)
 {
 	time64_t now = ktime_get_real_seconds();
 	int timeout = 0;
@@ -2252,7 +2252,8 @@ int ptlrpc_set_next_timeout(struct ptlrpc_request_set *set)
 int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 {
 	struct ptlrpc_request *req;
-	int rc, timeout;
+	time64_t timeout;
+	int rc;
 
 	if (set->set_producer)
 		(void)ptlrpc_set_producer(set);
@@ -2272,7 +2273,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 		 * wait until all complete, interrupted, or an in-flight
 		 * req times out
 		 */
-		CDEBUG(D_RPCTRACE, "set %p going to sleep for %d seconds\n",
+		CDEBUG(D_RPCTRACE, "set %p going to sleep for %lld seconds\n",
 		       set, timeout);
 
 		if (timeout == 0 && !signal_pending(current)) {
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 67a66a5..3cb9b84 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -218,10 +218,10 @@ void ptlrpc_deactivate_import(struct obd_import *imp)
 }
 EXPORT_SYMBOL(ptlrpc_deactivate_import);
 
-static unsigned int
+static time64_t
 ptlrpc_inflight_deadline(struct ptlrpc_request *req, time64_t now)
 {
-	long dl;
+	time64_t dl;
 
 	if (!(((req->rq_phase == RQ_PHASE_RPC) && !req->rq_waiting) ||
 	      (req->rq_phase == RQ_PHASE_BULK) ||
@@ -246,7 +246,7 @@ static unsigned int ptlrpc_inflight_timeout(struct obd_import *imp)
 {
 	time64_t now = ktime_get_real_seconds();
 	struct ptlrpc_request *req, *n;
-	unsigned int timeout = 0;
+	time64_t timeout = 0;
 
 	spin_lock(&imp->imp_lock);
 	list_for_each_entry_safe(req, n, &imp->imp_sending_list, rq_list)
@@ -265,7 +265,7 @@ static unsigned int ptlrpc_inflight_timeout(struct obd_import *imp)
 void ptlrpc_invalidate_import(struct obd_import *imp)
 {
 	struct ptlrpc_request *req, *n;
-	unsigned int timeout;
+	time64_t timeout;
 	int rc;
 
 	atomic_inc(&imp->imp_inval_count);
@@ -282,6 +282,7 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 	 * no guarantee that some rdma transfer is not in progress right now.
 	 */
 	do {
+		long timeout_jiffies;
 		/* Calculate max timeout for waiting on rpcs to error
 		 * out. Use obd_timeout if calculated value is smaller
 		 * than it.
@@ -298,16 +299,17 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 		}
 
 		CDEBUG(D_RPCTRACE,
-		       "Sleeping %d sec for inflight to error out\n",
+		       "Sleeping %llds for inflight to error out\n",
 		       timeout);
 
 		/* Wait for all requests to error out and call completion
 		 * callbacks. Cap it at obd_timeout -- these should all
 		 * have been locally cancelled by ptlrpc_abort_inflight.
 		 */
+		timeout_jiffies = max_t(long, timeout * HZ, 1);
 		rc = wait_event_idle_timeout(imp->imp_recovery_waitq,
 					     atomic_read(&imp->imp_inflight) == 0,
-					     obd_timeout * HZ);
+					     timeout_jiffies);
 
 		if (rc == 0) {
 			const char *cli_tgt = obd2cli_tgt(imp->imp_obd);
@@ -421,6 +423,7 @@ void ptlrpc_fail_import(struct obd_import *imp, u32 conn_cnt)
 
 int ptlrpc_reconnect_import(struct obd_import *imp)
 {
+	long timeout_jiffies = obd_timeout * HZ;
 	int rc;
 
 	ptlrpc_pinger_force(imp);
@@ -430,7 +433,7 @@ int ptlrpc_reconnect_import(struct obd_import *imp)
 
 	rc = wait_event_idle_timeout(imp->imp_recovery_waitq,
 				     !ptlrpc_import_in_recovery(imp),
-				     obd_timeout * HZ);
+				     timeout_jiffies);
 	CDEBUG(D_HA, "%s: recovery finished s:%s\n", obd2cli_tgt(imp->imp_obd),
 	       ptlrpc_import_state_name(imp->imp_state));
 	return rc == 0 ? -ETIMEDOUT : 0;
@@ -1506,22 +1509,27 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
 	}
 
 	if (ptlrpc_import_in_recovery(imp)) {
-		unsigned long timeout;
+		long timeout_jiffies;
+		time64_t timeout;
 
 		if (AT_OFF) {
 			if (imp->imp_server_timeout)
-				timeout = obd_timeout * HZ / 2;
+				timeout = obd_timeout >> 1;
 			else
-				timeout = obd_timeout * HZ;
+				timeout = obd_timeout;
 		} else {
-			int idx = import_at_get_index(imp,
-				imp->imp_client->cli_request_portal);
-			timeout = at_get(&imp->imp_at.iat_service_estimate[idx]) * HZ;
+			u32 req_portal;
+			int idx;
+
+			req_portal = imp->imp_client->cli_request_portal;
+			idx = import_at_get_index(imp, req_portal);
+			timeout = at_get(&imp->imp_at.iat_service_estimate[idx]);
 		}
 
+		timeout_jiffies = timeout * HZ;
 		if (wait_event_idle_timeout(imp->imp_recovery_waitq,
 					    !ptlrpc_import_in_recovery(imp),
-					    max(timeout, 1UL)) == 0)
+					    max_t(long, timeout_jiffies, 1)) == 0)
 			l_wait_event_abortable(
 				imp->imp_recovery_waitq,
 				!ptlrpc_import_in_recovery(imp));
diff --git a/fs/lustre/ptlrpc/pinger.c b/fs/lustre/ptlrpc/pinger.c
index 6a437f4..762fd0e 100644
--- a/fs/lustre/ptlrpc/pinger.c
+++ b/fs/lustre/ptlrpc/pinger.c
@@ -100,15 +100,15 @@ static int ptlrpc_ping(struct obd_import *imp)
 
 static void ptlrpc_update_next_ping(struct obd_import *imp, int soon)
 {
-	int time = soon ? PING_INTERVAL_SHORT : PING_INTERVAL;
+	time64_t time = soon ? PING_INTERVAL_SHORT : PING_INTERVAL;
 
 	if (imp->imp_state == LUSTRE_IMP_DISCON) {
-		int dtime = max_t(int, CONNECTION_SWITCH_MIN,
+		time64_t dtime = max_t(time64_t, CONNECTION_SWITCH_MIN,
 				  AT_OFF ? 0 :
 				  at_get(&imp->imp_at.iat_net_latency));
 		time = min(time, dtime);
 	}
-	imp->imp_next_ping = jiffies + time * HZ;
+	imp->imp_next_ping = ktime_get_seconds() + time;
 }
 
 static inline int imp_is_deactive(struct obd_import *imp)
@@ -117,23 +117,23 @@ static inline int imp_is_deactive(struct obd_import *imp)
 		OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_IMP_DEACTIVE));
 }
 
-static inline int ptlrpc_next_reconnect(struct obd_import *imp)
+static inline time64_t ptlrpc_next_reconnect(struct obd_import *imp)
 {
 	if (imp->imp_server_timeout)
-		return jiffies + obd_timeout / 2 * HZ;
+		return ktime_get_seconds() + (obd_timeout >> 1);
 	else
-		return jiffies + obd_timeout * HZ;
+		return ktime_get_seconds() + obd_timeout;
 }
 
-static long pinger_check_timeout(unsigned long time)
+static time64_t pinger_check_timeout(time64_t time)
 {
 	struct timeout_item *item;
-	unsigned long timeout = PING_INTERVAL;
+	time64_t timeout = PING_INTERVAL;
 
-	/* The timeout list is a increase order sorted list */
+	/* This list is sorted in increasing timeout order */
 	mutex_lock(&pinger_mutex);
 	list_for_each_entry(item, &timeout_list, ti_chain) {
-		int ti_timeout = item->ti_timeout;
+		time64_t ti_timeout = item->ti_timeout;
 
 		if (timeout > ti_timeout)
 			timeout = ti_timeout;
@@ -141,7 +141,7 @@ static long pinger_check_timeout(unsigned long time)
 	}
 	mutex_unlock(&pinger_mutex);
 
-	return time + timeout * HZ - jiffies;
+	return time + timeout - ktime_get_seconds();
 }
 
 static bool ir_up;
@@ -161,7 +161,7 @@ void ptlrpc_pinger_ir_down(void)
 EXPORT_SYMBOL(ptlrpc_pinger_ir_down);
 
 static void ptlrpc_pinger_process_import(struct obd_import *imp,
-					 unsigned long this_ping)
+					 time64_t this_ping)
 {
 	int level;
 	int force;
@@ -180,8 +180,7 @@ static void ptlrpc_pinger_process_import(struct obd_import *imp,
 
 	imp->imp_force_verify = 0;
 
-	if (time_after_eq(imp->imp_next_ping - 5, this_ping) &&
-	    !force) {
+	if (imp->imp_next_ping - 5 >= this_ping && !force) {
 		spin_unlock(&imp->imp_lock);
 		return;
 	}
@@ -224,8 +223,8 @@ static void ptlrpc_pinger_process_import(struct obd_import *imp,
 
 static void ptlrpc_pinger_main(struct work_struct *ws)
 {
-	unsigned long this_ping = jiffies;
-	long time_to_next_wake;
+	time64_t this_ping = ktime_get_seconds();
+	time64_t time_to_next_wake;
 	struct timeout_item *item;
 	struct obd_import *imp;
 
@@ -238,8 +237,7 @@ static void ptlrpc_pinger_main(struct work_struct *ws)
 			ptlrpc_pinger_process_import(imp, this_ping);
 			/* obd_timeout might have changed */
 			if (imp->imp_pingable && imp->imp_next_ping &&
-			    time_after(imp->imp_next_ping,
-				       this_ping + PING_INTERVAL * HZ))
+			    imp->imp_next_ping > this_ping + PING_INTERVAL)
 				ptlrpc_update_next_ping(imp, 0);
 		}
 		mutex_unlock(&pinger_mutex);
@@ -253,9 +251,9 @@ static void ptlrpc_pinger_main(struct work_struct *ws)
 		 * we will SKIP the next ping at next_ping, and the
 		 * ping will get sent 2 timeouts from now!  Beware.
 		 */
-		CDEBUG(D_INFO, "next wakeup in %ld (%ld)\n",
+		CDEBUG(D_INFO, "next wakeup in %lld (%lld)\n",
 		       time_to_next_wake,
-		       this_ping + PING_INTERVAL * HZ);
+		       this_ping + PING_INTERVAL);
 	} while (time_to_next_wake <= 0);
 
 	queue_delayed_work(pinger_wq, &ping_work,
@@ -357,7 +355,7 @@ int ptlrpc_pinger_del_import(struct obd_import *imp)
  * Register a timeout callback to the pinger list, and the callback will
  * be called when timeout happens.
  */
-static struct timeout_item *ptlrpc_new_timeout(int time,
+static struct timeout_item *ptlrpc_new_timeout(time64_t time,
 					       enum timeout_event event,
 					       timeout_cb_t cb, void *data)
 {
@@ -382,7 +380,7 @@ static struct timeout_item *ptlrpc_new_timeout(int time,
  * Note: the timeout list is an sorted list with increased timeout value.
  */
 static struct timeout_item*
-ptlrpc_pinger_register_timeout(int time, enum timeout_event event,
+ptlrpc_pinger_register_timeout(time64_t time, enum timeout_event event,
 			       timeout_cb_t cb, void *data)
 {
 	struct timeout_item *item, *tmp;
@@ -410,7 +408,7 @@ static struct timeout_item *ptlrpc_new_timeout(int time,
 /* Add a client_obd to the timeout event list, when timeout(@time)
  * happens, the callback(@cb) will be called.
  */
-int ptlrpc_add_timeout_client(int time, enum timeout_event event,
+int ptlrpc_add_timeout_client(time64_t time, enum timeout_event event,
 			      timeout_cb_t cb, void *data,
 			      struct list_head *obd_list)
 {
diff --git a/fs/lustre/ptlrpc/ptlrpc_internal.h b/fs/lustre/ptlrpc/ptlrpc_internal.h
index 201ccdd..40cf7b7 100644
--- a/fs/lustre/ptlrpc/ptlrpc_internal.h
+++ b/fs/lustre/ptlrpc/ptlrpc_internal.h
@@ -69,7 +69,7 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
 void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
 			    struct ptlrpc_request *req);
 void ptlrpc_expired_set(struct ptlrpc_request_set *set);
-int ptlrpc_set_next_timeout(struct ptlrpc_request_set *set);
+time64_t ptlrpc_set_next_timeout(struct ptlrpc_request_set *set);
 void ptlrpc_resend_req(struct ptlrpc_request *request);
 void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req);
 void ptlrpc_assign_next_xid_nolock(struct ptlrpc_request *req);
diff --git a/fs/lustre/ptlrpc/ptlrpcd.c b/fs/lustre/ptlrpc/ptlrpcd.c
index 92b477d..0b73d58 100644
--- a/fs/lustre/ptlrpc/ptlrpcd.c
+++ b/fs/lustre/ptlrpc/ptlrpcd.c
@@ -434,7 +434,7 @@ static int ptlrpcd(void *arg)
 	 * new_req_list and ptlrpcd_check() moves them into the set.
 	 */
 	do {
-		int timeout;
+		time64_t timeout;
 
 		timeout = ptlrpc_set_next_timeout(set);
 
-- 
1.8.3.1
