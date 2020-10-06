From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:00 -0400
Subject: [lustre-devel] [PATCH 21/42] lnet: Loosen restrictions on LNet
 Health params
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <chris.horn@hpe.com>

The functions that set various LNet Health related parameters require
that the parameters be set in a specific order depending on whether
health is enabled or disabled. This is not user-friendly.
 - Don't overwrite lnet_transaction_timeout when health is being
   enabled or disabled.
 - Don't overwrite lnet_retry_count when health is being enabled
   (still set it to zero when health is disabled).
 - Allow lnet_retry_count to be set to 0 when health is disabled
 - Correct off-by-one error in transaction_to_set() to ensure
   lnet_transaction_timeout is greater than lnet_retry_count

HPE-bug-id: LUS-8995
WC-bug-id: https://jira.whamcloud.com/browse/LU-13735
Lustre-commit: b8ff97611717d ("LU-13735 lnet: Loosen restrictions on LNet Health params")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39228
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 35 ++++++++++-------------------------
 1 file changed, 10 insertions(+), 25 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index af2089e..f678ae2 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -140,10 +140,8 @@ static int recovery_interval_set(const char *val,
 MODULE_PARM_DESC(lnet_drop_asym_route,
 		 "Set to 1 to drop asymmetrical route messages.");
 
-#define LNET_TRANSACTION_TIMEOUT_NO_HEALTH_DEFAULT 50
-#define LNET_TRANSACTION_TIMEOUT_HEALTH_DEFAULT 50
-
-unsigned int lnet_transaction_timeout = LNET_TRANSACTION_TIMEOUT_HEALTH_DEFAULT;
+#define LNET_TRANSACTION_TIMEOUT_DEFAULT 50
+unsigned int lnet_transaction_timeout = LNET_TRANSACTION_TIMEOUT_DEFAULT;
 static int transaction_to_set(const char *val, const struct kernel_param *kp);
 static struct kernel_param_ops param_ops_transaction_timeout = {
 	.set = transaction_to_set,
@@ -156,8 +154,8 @@ static int recovery_interval_set(const char *val,
 MODULE_PARM_DESC(lnet_transaction_timeout,
 		 "Maximum number of seconds to wait for a peer response.");
 
-#define LNET_RETRY_COUNT_HEALTH_DEFAULT 2
-unsigned int lnet_retry_count = LNET_RETRY_COUNT_HEALTH_DEFAULT;
+#define LNET_RETRY_COUNT_DEFAULT 2
+unsigned int lnet_retry_count = LNET_RETRY_COUNT_DEFAULT;
 static int retry_count_set(const char *val, const struct kernel_param *kp);
 static struct kernel_param_ops param_ops_retry_count = {
 	.set = retry_count_set,
@@ -184,8 +182,8 @@ static int response_tracking_set(const char *val,
 MODULE_PARM_DESC(lnet_response_tracking,
 		 "(0|1|2|3) LNet Internal Only|GET Reply only|PUT ACK only|Full Tracking (default)");
 
-#define LNET_LND_TIMEOUT_DEFAULT ((LNET_TRANSACTION_TIMEOUT_HEALTH_DEFAULT - 1) / \
-				  (LNET_RETRY_COUNT_HEALTH_DEFAULT + 1))
+#define LNET_LND_TIMEOUT_DEFAULT ((LNET_TRANSACTION_TIMEOUT_DEFAULT - 1) / \
+				  (LNET_RETRY_COUNT_DEFAULT + 1))
 unsigned int lnet_lnd_timeout = LNET_LND_TIMEOUT_DEFAULT;
 static void lnet_set_lnd_timeout(void)
 {
@@ -235,20 +233,7 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 		return -EINVAL;
 	}
 
-	/* if we're turning on health then use the health timeout
-	 * defaults.
-	 */
-	if (*sensitivity == 0 && value != 0) {
-		lnet_transaction_timeout =
-			LNET_TRANSACTION_TIMEOUT_HEALTH_DEFAULT;
-		lnet_retry_count = LNET_RETRY_COUNT_HEALTH_DEFAULT;
-		lnet_set_lnd_timeout();
-	/* if we're turning off health then use the no health timeout
-	 * default.
-	 */
-	} else if (*sensitivity != 0 && value == 0) {
-		lnet_transaction_timeout =
-			LNET_TRANSACTION_TIMEOUT_NO_HEALTH_DEFAULT;
+	if (*sensitivity != 0 && value == 0 && lnet_retry_count != 0) {
 		lnet_retry_count = 0;
 		lnet_set_lnd_timeout();
 	}
@@ -396,7 +381,7 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	 */
 	mutex_lock(&the_lnet.ln_api_mutex);
 
-	if (value < lnet_retry_count || value == 0) {
+	if (value <= lnet_retry_count || value == 0) {
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		CERROR("Invalid value for lnet_transaction_timeout (%lu). Has to be greater than lnet_retry_count (%u)\n",
 		       value, lnet_retry_count);
@@ -437,9 +422,9 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	 */
 	mutex_lock(&the_lnet.ln_api_mutex);
 
-	if (lnet_health_sensitivity == 0) {
+	if (lnet_health_sensitivity == 0 && value > 0) {
 		mutex_unlock(&the_lnet.ln_api_mutex);
-		CERROR("Can not set retry_count when health feature is turned off\n");
+		CERROR("Can not set lnet_retry_count when health feature is turned off\n");
 		return -EINVAL;
 	}
 
-- 
1.8.3.1
