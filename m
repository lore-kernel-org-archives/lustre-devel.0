From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:25 -0500
Subject: [lustre-devel] [PATCH 157/622] lnet: configure recovery interval
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-158-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Added a module parameter to configure the interval between each
recovery ping. Some sites might not want to ping failed NIDs once
a second and might desire a longer interval. The interval defaults
to 1 second.
Monitor thread now wakes up depending on the smallest interval
it needs to monitor

WC-bug-id: https://jira.whamcloud.com/browse/LU-11468
Lustre-commit: dc1f5f08b420 ("LU-11468 lnet: configure recovery interval")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33309
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  1 +
 net/lnet/lnet/api-ni.c        | 52 +++++++++++++++++++++++++++++++++++++++++++
 net/lnet/lnet/lib-move.c      | 24 +++++++++++++-------
 3 files changed, 69 insertions(+), 8 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index ecacd65..26095a6 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -502,6 +502,7 @@ struct lnet_ni *
 extern unsigned int lnet_retry_count;
 extern unsigned int lnet_numa_range;
 extern unsigned int lnet_health_sensitivity;
+extern unsigned int lnet_recovery_interval;
 extern unsigned int lnet_peer_discovery_disabled;
 extern int portal_rotor;
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index a2c648e..c4f698d 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -95,6 +95,23 @@ struct lnet the_lnet = {
 MODULE_PARM_DESC(lnet_health_sensitivity,
 		 "Value to decrement the health value by on error");
 
+/* lnet_recovery_interval determines how often we should perform recovery
+ * on unhealthy interfaces.
+ */
+unsigned int lnet_recovery_interval = 1;
+static int recovery_interval_set(const char *val,
+				 const struct kernel_param *kp);
+static struct kernel_param_ops param_ops_recovery_interval = {
+	.set = recovery_interval_set,
+	.get = param_get_int,
+};
+
+#define param_check_recovery_interval(name, p) \
+		__param_check(name, p, int)
+module_param(lnet_recovery_interval, recovery_interval, 0644);
+MODULE_PARM_DESC(lnet_recovery_interval,
+		 "Interval to recover unhealthy interfaces in seconds");
+
 static int lnet_interfaces_max = LNET_INTERFACES_MAX_DEFAULT;
 static int intf_max_set(const char *val, const struct kernel_param *kp);
 module_param_call(lnet_interfaces_max, intf_max_set, param_get_int,
@@ -190,6 +207,41 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 }
 
 static int
+recovery_interval_set(const char *val, const struct kernel_param *kp)
+{
+	int rc;
+	unsigned int *interval = (unsigned int *)kp->arg;
+	unsigned long value;
+
+	rc = kstrtoul(val, 0, &value);
+	if (rc) {
+		CERROR("Invalid module parameter value for 'lnet_recovery_interval'\n");
+		return rc;
+	}
+
+	if (value < 1) {
+		CERROR("lnet_recovery_interval must be@least 1 second\n");
+		return -EINVAL;
+	}
+
+	/* The purpose of locking the api_mutex here is to ensure that
+	 * the correct value ends up stored properly.
+	 */
+	mutex_lock(&the_lnet.ln_api_mutex);
+
+	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return 0;
+	}
+
+	*interval = value;
+
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	return 0;
+}
+
+static int
 discovery_set(const char *val, const struct kernel_param *kp)
 {
 	int rc;
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 548ea88..434aa09 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3074,7 +3074,10 @@ struct lnet_mt_event_info {
 static int
 lnet_monitor_thread(void *arg)
 {
-	int wakeup_counter = 0;
+	time64_t recovery_timeout = 0;
+	time64_t rsp_timeout = 0;
+	int interval;
+	time64_t now;
 
 	/* The monitor thread takes care of the following:
 	 *  1. Checks the aliveness of routers
@@ -3086,20 +3089,23 @@ struct lnet_mt_event_info {
 	 *     and pings them.
 	 */
 	while (the_lnet.ln_mt_state == LNET_MT_STATE_RUNNING) {
+		now = ktime_get_real_seconds();
+
 		if (lnet_router_checker_active())
 			lnet_check_routers();
 
 		lnet_resend_pending_msgs();
 
-		wakeup_counter++;
-		if (wakeup_counter >= lnet_transaction_timeout / 2) {
+		if (now >= rsp_timeout) {
 			lnet_finalize_expired_responses(false);
-			wakeup_counter = 0;
+			rsp_timeout = now + (lnet_transaction_timeout / 2);
 		}
 
-		lnet_recover_local_nis();
-
-		lnet_recover_peer_nis();
+		if (now >= recovery_timeout) {
+			lnet_recover_local_nis();
+			lnet_recover_peer_nis();
+			recovery_timeout = now + lnet_recovery_interval;
+		}
 
 		/* TODO do we need to check if we should sleep without
 		 * timeout?  Technically, an active system will always
@@ -3109,8 +3115,10 @@ struct lnet_mt_event_info {
 		 * cases where we get a complaint that an idle thread
 		 * is waking up unnecessarily.
 		 */
+		interval = min(lnet_recovery_interval,
+			       lnet_transaction_timeout / 2);
 		wait_event_interruptible_timeout(the_lnet.ln_mt_waitq,
-						 false, HZ);
+						 false, HZ * interval);
 	}
 
 	/* clean up the router checker */
-- 
1.8.3.1
