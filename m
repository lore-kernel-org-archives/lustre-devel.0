From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:36 -0400
Subject: [lustre-devel] [PATCH 137/151] lnet: reduce discovery timeout
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-138-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Discovery protocol sends a ping (GET) to the peer and expects a
REPLY back with the interface information. Discovery uses the
DEFAULT_PEER_TIMEOUT which 180s. This could lead to extended delay
during mounting if the OSTs are down or if the ping fails for
any reason.

This patch adds a module parameter lnet_transaction_timeout which
defaults to 5 seconds. lnet_transaction_timeout is used for the
discovery timeout.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10800
Lustre-commit: 1cf929df259a ("LU-10800 lnet: reduce discovery timeout")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31663
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  1 +
 net/lnet/lnet/api-ni.c        | 44 +++++++++++++++++++++++++++++++++++++++++++
 net/lnet/lnet/peer.c          | 16 ++++++++--------
 3 files changed, 53 insertions(+), 8 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 3d7867f..22c6152 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -477,6 +477,7 @@ struct lnet_ni *
 bool lnet_is_ni_healthy_locked(struct lnet_ni *ni);
 struct lnet_net *lnet_get_net_locked(u32 net_id);
 
+extern unsigned int lnet_transaction_timeout;
 extern unsigned int lnet_numa_range;
 extern unsigned int lnet_peer_discovery_disabled;
 extern int portal_rotor;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index fc4fe5d..8be3354 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -92,6 +92,13 @@ struct lnet the_lnet = {
 MODULE_PARM_DESC(lnet_peer_discovery_disabled,
 		 "Set to 1 to disable peer discovery on this node.");
 
+unsigned int lnet_transaction_timeout = 5;
+static int transaction_to_set(const char *val, const struct kernel_param *kp);
+module_param_call(lnet_transaction_timeout, transaction_to_set, param_get_int,
+		  &lnet_transaction_timeout, 0444);
+MODULE_PARM_DESC(lnet_transaction_timeout,
+		 "Time in seconds to wait for a REPLY or an ACK");
+
 /*
  * This sequence number keeps track of how many times DLC was used to
  * update the local NIs. It is incremented when a NI is added or
@@ -158,6 +165,43 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 }
 
 static int
+transaction_to_set(const char *val, const struct kernel_param *kp)
+{
+	unsigned int *transaction_to = (unsigned int *)kp->arg;
+	unsigned long value;
+	int rc;
+
+	rc = kstrtoul(val, 0, &value);
+	if (rc) {
+		CERROR("Invalid module parameter value for 'lnet_transaction_timeout'\n");
+		return rc;
+	}
+
+	/* The purpose of locking the api_mutex here is to ensure that
+	 * the correct value ends up stored properly.
+	 */
+	mutex_lock(&the_lnet.ln_api_mutex);
+
+	if (value == 0) {
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		CERROR("Invalid value for lnet_transaction_timeout (%lu).\n",
+		       value);
+		return -EINVAL;
+	}
+
+	if (value == *transaction_to) {
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return 0;
+	}
+
+	*transaction_to = value;
+
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	return 0;
+}
+
+static int
 intf_max_set(const char *val, const struct kernel_param *kp)
 {
 	int value, rc;
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index e2f8c28..1534ab2 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2942,7 +2942,7 @@ static int lnet_peer_rediscover(struct lnet_peer *lp)
  * obsessively re-check the clock. The oldest discovery request will
  * be at the head of the queue.
  */
-static struct lnet_peer *lnet_peer_dc_timed_out(time64_t now)
+static struct lnet_peer *lnet_peer_get_dc_timed_out(time64_t now)
 {
 	struct lnet_peer *lp;
 
@@ -2950,7 +2950,7 @@ static struct lnet_peer *lnet_peer_dc_timed_out(time64_t now)
 		return NULL;
 	lp = list_first_entry(&the_lnet.ln_dc_working,
 			      struct lnet_peer, lp_dc_list);
-	if (now < lp->lp_last_queued + DEFAULT_PEER_TIMEOUT)
+	if (now < lp->lp_last_queued + lnet_transaction_timeout)
 		return NULL;
 	return lp;
 }
@@ -2961,7 +2961,7 @@ static struct lnet_peer *lnet_peer_dc_timed_out(time64_t now)
  * lnet_discovery_event_handler() will proceed from here and complete
  * the cleanup.
  */
-static void lnet_peer_discovery_timeout(struct lnet_peer *lp)
+static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 {
 	struct lnet_handle_md ping_mdh;
 	struct lnet_handle_md push_mdh;
@@ -3010,7 +3010,7 @@ static int lnet_peer_discovery_wait_for_work(void)
 			break;
 		if (!list_empty(&the_lnet.ln_msg_resend))
 			break;
-		if (lnet_peer_dc_timed_out(ktime_get_real_seconds()))
+		if (lnet_peer_get_dc_timed_out(ktime_get_real_seconds()))
 			break;
 		lnet_net_unlock(cpt);
 
@@ -3177,14 +3177,14 @@ static int lnet_peer_discovery(void *arg)
 		 * taking too long. Move all that are found to the
 		 * ln_dc_expired queue and time out any pending
 		 * Ping or Push. We have to drop the lnet_net_lock
-		 * in the loop because lnet_peer_discovery_timeout()
+		 * in the loop because lnet_peer_cancel_discovery()
 		 * calls LNetMDUnlink().
 		 */
 		now = ktime_get_real_seconds();
-		while ((lp = lnet_peer_dc_timed_out(now)) != NULL) {
+		while ((lp = lnet_peer_get_dc_timed_out(now)) != NULL) {
 			list_move(&lp->lp_dc_list, &the_lnet.ln_dc_expired);
 			lnet_net_unlock(LNET_LOCK_EX);
-			lnet_peer_discovery_timeout(lp);
+			lnet_peer_cancel_discovery(lp);
 			lnet_net_lock(LNET_LOCK_EX);
 		}
 
@@ -3208,7 +3208,7 @@ static int lnet_peer_discovery(void *arg)
 				      struct lnet_peer, lp_dc_list);
 		list_move(&lp->lp_dc_list, &the_lnet.ln_dc_expired);
 		lnet_net_unlock(LNET_LOCK_EX);
-		lnet_peer_discovery_timeout(lp);
+		lnet_peer_cancel_discovery(lp);
 		lnet_net_lock(LNET_LOCK_EX);
 	}
 	lnet_net_unlock(LNET_LOCK_EX);
-- 
1.8.3.1
