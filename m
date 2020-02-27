From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:13 -0500
Subject: [lustre-devel] [PATCH 085/622] lnet: sysfs functions for module
 params
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-86-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Allow transaction timeout and retry count module parameters to be
set and shown via sysfs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 5169827bf790 ("LU-9120 lnet: sysfs functions for module params")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32861
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 84 +++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 77 insertions(+), 7 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index e467d64..38e35bb 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -111,13 +111,27 @@ struct lnet the_lnet = {
 
 unsigned int lnet_transaction_timeout = 5;
 static int transaction_to_set(const char *val, const struct kernel_param *kp);
-module_param_call(lnet_transaction_timeout, transaction_to_set, param_get_int,
-		  &lnet_transaction_timeout, 0444);
+static struct kernel_param_ops param_ops_transaction_timeout = {
+	.set = transaction_to_set,
+	.get = param_get_int,
+};
+
+#define param_check_transaction_timeout(name, p) \
+		__param_check(name, p, int)
+module_param(lnet_transaction_timeout, transaction_timeout, 0644);
 MODULE_PARM_DESC(lnet_transaction_timeout,
-		 "Time in seconds to wait for a REPLY or an ACK");
+		 "Maximum number of seconds to wait for a peer response.");
 
 unsigned int lnet_retry_count;
-module_param(lnet_retry_count, uint, 0444);
+static int retry_count_set(const char *val, const struct kernel_param *kp);
+static struct kernel_param_ops param_ops_retry_count = {
+	.set = retry_count_set,
+	.get = param_get_int,
+};
+
+#define param_check_retry_count(name, p) \
+		__param_check(name, p, int)
+module_param(lnet_retry_count, retry_count, 0644);
 MODULE_PARM_DESC(lnet_retry_count,
 		 "Maximum number of times to retry transmitting a message");
 
@@ -241,10 +255,15 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	 */
 	mutex_lock(&the_lnet.ln_api_mutex);
 
-	if (value == 0) {
+	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return 0;
+	}
+
+	if (value < lnet_retry_count || value == 0) {
 		mutex_unlock(&the_lnet.ln_api_mutex);
-		CERROR("Invalid value for lnet_transaction_timeout (%lu).\n",
-		       value);
+		CERROR("Invalid value for lnet_transaction_timeout (%lu). Has to be greater than lnet_retry_count (%u)\n",
+		       value, lnet_retry_count);
 		return -EINVAL;
 	}
 
@@ -254,6 +273,57 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	}
 
 	*transaction_to = value;
+	if (lnet_retry_count == 0)
+		lnet_lnd_timeout = value;
+	else
+		lnet_lnd_timeout = value / lnet_retry_count;
+
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	return 0;
+}
+
+static int
+retry_count_set(const char *val, const struct kernel_param *kp)
+{
+	int rc;
+	unsigned int *retry_count = (unsigned int *)kp->arg;
+	unsigned long value;
+
+	rc = kstrtoul(val, 0, &value);
+	if (rc) {
+		CERROR("Invalid module parameter value for 'lnet_retry_count'\n");
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
+	if (value > lnet_transaction_timeout) {
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		CERROR("Invalid value for lnet_retry_count (%lu). Has to be smaller than lnet_transaction_timeout (%u)\n",
+		       value, lnet_transaction_timeout);
+		return -EINVAL;
+	}
+
+	if (value == *retry_count) {
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return 0;
+	}
+
+	*retry_count = value;
+
+	if (value == 0)
+		lnet_lnd_timeout = lnet_transaction_timeout;
+	else
+		lnet_lnd_timeout = lnet_transaction_timeout / value;
 
 	mutex_unlock(&the_lnet.ln_api_mutex);
 
-- 
1.8.3.1
