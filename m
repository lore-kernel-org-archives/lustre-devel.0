From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:05 -0500
Subject: [lustre-devel] [PATCH 077/622] lnet: add lnet_health_sensitivity
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-78-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Add lnet_health_senstivity value. This value determines the amount
the NI health value is decremented by. The value defaults to 0,
which turns off the health feature by default. The user needs
to explicitly turn on this feature. The assumption is that many sites
will only have one interface in their nodes. In this case the
health feature will not increase the resiliency of their system.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 63cf744d0fdf ("LU-9120 lnet: add lnet_health_sensitivity")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32762
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  1 +
 net/lnet/lnet/api-ni.c        | 52 +++++++++++++++++++++++++++++++++++++++++++
 net/lnet/lnet/lib-move.c      | 11 ++++++++-
 3 files changed, 63 insertions(+), 1 deletion(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 20b4660..5e13d32 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -479,6 +479,7 @@ struct lnet_ni *
 
 extern unsigned int lnet_transaction_timeout;
 extern unsigned int lnet_numa_range;
+extern unsigned int lnet_health_sensitivity;
 extern unsigned int lnet_peer_discovery_disabled;
 extern int portal_rotor;
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 4e83fa8..9d68434 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -78,6 +78,23 @@ struct lnet the_lnet = {
 MODULE_PARM_DESC(lnet_numa_range,
 		 "NUMA range to consider during Multi-Rail selection");
 
+/* lnet_health_sensitivity determines by how much we decrement the health
+ * value on sending error. The value defaults to 0, which means health
+ * checking is turned off by default.
+ */
+unsigned int lnet_health_sensitivity;
+static int sensitivity_set(const char *val, const struct kernel_param *kp);
+static struct kernel_param_ops param_ops_health_sensitivity = {
+	.set = sensitivity_set,
+	.get = param_get_int,
+};
+
+#define param_check_health_sensitivity(name, p) \
+	__param_check(name, p, int)
+module_param(lnet_health_sensitivity, health_sensitivity, 0644);
+MODULE_PARM_DESC(lnet_health_sensitivity,
+		 "Value to decrement the health value by on error");
+
 static int lnet_interfaces_max = LNET_INTERFACES_MAX_DEFAULT;
 static int intf_max_set(const char *val, const struct kernel_param *kp);
 module_param_call(lnet_interfaces_max, intf_max_set, param_get_int,
@@ -115,6 +132,41 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 			 struct lnet_process_id __user *ids, int n_ids);
 
 static int
+sensitivity_set(const char *val, const struct kernel_param *kp)
+{
+	int rc;
+	unsigned int *sensitivity = (unsigned int *)kp->arg;
+	unsigned long value;
+
+	rc = kstrtoul(val, 0, &value);
+	if (rc) {
+		CERROR("Invalid module parameter value for 'lnet_health_sensitivity'\n");
+		return rc;
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
+	if (value == *sensitivity) {
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return 0;
+	}
+
+	*sensitivity = value;
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
index ab32c6f..38815fd 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1332,6 +1332,16 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		 */
 		if (ni_healthv < best_healthv) {
 			continue;
+		} else if (ni_healthv > best_healthv) {
+			best_healthv = ni_healthv;
+			/* If we're going to prefer this ni because it's
+			 * the healthiest, then we should set the
+			 * shortest_distance in the algorithm in case
+			 * there are multiple NIs with the same health but
+			 * different distances.
+			 */
+			if (distance < shortest_distance)
+				shortest_distance = distance;
 		} else if (distance > shortest_distance) {
 			continue;
 		} else if (distance < shortest_distance) {
@@ -1344,7 +1354,6 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		}
 		best_ni = ni;
 		best_credits = ni_credits;
-		best_healthv = ni_healthv;
 	}
 
 	CDEBUG(D_NET, "selected best_ni %s\n",
-- 
1.8.3.1
