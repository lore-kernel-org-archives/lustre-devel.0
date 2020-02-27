From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:07 -0500
Subject: [lustre-devel] [PATCH 319/622] lnet: setup health timeout defaults
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-320-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Enable health feature by default.
Setup transaction timeout to a default 10 seconds and
retry count to 3 when health is enabled. When health
is disabled set default transaction timeout to 50.
When toggling between health enabled/disabled the defaults
will always kick in.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11816
Lustre-commit: 8632e94aeb7e ("LU-11816 lnet: setup health timeout defaults")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34252
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 55 +++++++++++++++++++++++++-------------------------
 1 file changed, 28 insertions(+), 27 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 1388bd4..aeb9d92 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -79,10 +79,10 @@ struct lnet the_lnet = {
 		 "NUMA range to consider during Multi-Rail selection");
 
 /* lnet_health_sensitivity determines by how much we decrement the health
- * value on sending error. The value defaults to 0, which means health
- * checking is turned off by default.
+ * value on sending error. The value defaults to 100, which means health
+ * interface health is decremented by 100 points every failure.
  */
-unsigned int lnet_health_sensitivity;
+unsigned int lnet_health_sensitivity = 100;
 static int sensitivity_set(const char *val, const struct kernel_param *kp);
 static struct kernel_param_ops param_ops_health_sensitivity = {
 	.set = sensitivity_set,
@@ -140,7 +140,10 @@ static int recovery_interval_set(const char *val,
 MODULE_PARM_DESC(lnet_drop_asym_route,
 		 "Set to 1 to drop asymmetrical route messages.");
 
-unsigned int lnet_transaction_timeout = 50;
+#define LNET_TRANSACTION_TIMEOUT_NO_HEALTH_DEFAULT 50
+#define LNET_TRANSACTION_TIMEOUT_HEALTH_DEFAULT 10
+
+unsigned int lnet_transaction_timeout = LNET_TRANSACTION_TIMEOUT_HEALTH_DEFAULT;
 static int transaction_to_set(const char *val, const struct kernel_param *kp);
 static struct kernel_param_ops param_ops_transaction_timeout = {
 	.set = transaction_to_set,
@@ -153,7 +156,8 @@ static int recovery_interval_set(const char *val,
 MODULE_PARM_DESC(lnet_transaction_timeout,
 		 "Maximum number of seconds to wait for a peer response.");
 
-unsigned int lnet_retry_count;
+#define LNET_RETRY_COUNT_HEALTH_DEFAULT 3
+unsigned int lnet_retry_count = LNET_RETRY_COUNT_HEALTH_DEFAULT;
 static int retry_count_set(const char *val, const struct kernel_param *kp);
 static struct kernel_param_ops param_ops_retry_count = {
 	.set = retry_count_set,
@@ -201,11 +205,6 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	 */
 	mutex_lock(&the_lnet.ln_api_mutex);
 
-	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
-		mutex_unlock(&the_lnet.ln_api_mutex);
-		return 0;
-	}
-
 	if (value > LNET_MAX_HEALTH_VALUE) {
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		CERROR("Invalid health value. Maximum: %d value = %lu\n",
@@ -213,6 +212,22 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 		return -EINVAL;
 	}
 
+	/* if we're turning on health then use the health timeout
+	 * defaults.
+	 */
+	if (*sensitivity == 0 && value != 0) {
+		lnet_transaction_timeout =
+			LNET_TRANSACTION_TIMEOUT_HEALTH_DEFAULT;
+		lnet_retry_count = LNET_RETRY_COUNT_HEALTH_DEFAULT;
+	/* if we're turning off health then use the no health timeout
+	 * default.
+	 */
+	} else if (*sensitivity != 0 && value == 0) {
+		lnet_transaction_timeout =
+			LNET_TRANSACTION_TIMEOUT_NO_HEALTH_DEFAULT;
+		lnet_retry_count = 0;
+	}
+
 	*sensitivity = value;
 
 	mutex_unlock(&the_lnet.ln_api_mutex);
@@ -243,11 +258,6 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	 */
 	mutex_lock(&the_lnet.ln_api_mutex);
 
-	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
-		mutex_unlock(&the_lnet.ln_api_mutex);
-		return 0;
-	}
-
 	*interval = value;
 
 	mutex_unlock(&the_lnet.ln_api_mutex);
@@ -353,11 +363,6 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	 */
 	mutex_lock(&the_lnet.ln_api_mutex);
 
-	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
-		mutex_unlock(&the_lnet.ln_api_mutex);
-		return 0;
-	}
-
 	if (value < lnet_retry_count || value == 0) {
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		CERROR("Invalid value for lnet_transaction_timeout (%lu). Has to be greater than lnet_retry_count (%u)\n",
@@ -399,9 +404,10 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	 */
 	mutex_lock(&the_lnet.ln_api_mutex);
 
-	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
+	if (lnet_health_sensitivity == 0) {
 		mutex_unlock(&the_lnet.ln_api_mutex);
-		return 0;
+		CERROR("Can not set retry_count when health feature is turned off\n");
+		return -EINVAL;
 	}
 
 	if (value > lnet_transaction_timeout) {
@@ -411,11 +417,6 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 		return -EINVAL;
 	}
 
-	if (value == *retry_count) {
-		mutex_unlock(&the_lnet.ln_api_mutex);
-		return 0;
-	}
-
 	*retry_count = value;
 
 	if (value == 0)
-- 
1.8.3.1
