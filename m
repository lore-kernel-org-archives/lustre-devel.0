From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:55 -0400
Subject: [lustre-devel] [PATCH 16/22] lnet: Correct the default LND timeout
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Default LND timeout is currently too low. To allow for
lnet_retry_count resend attempts within a single
lnet_transaction_timeout window, the LND timeout needs to be less
than lnet_transaction_timeout / lnet_retry_count. If the retry
count is 0, we still want LND timeout to be less than the LNet
transaction timeout.

Also, be sure to update the LND timeout when health is toggled on or
off.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13510
Lustre-commit: 0127d64b8cadd ("LU-13510 lnet: Correct the default LND timeout")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/38481
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  1 -
 net/lnet/lnet/api-ni.c        | 28 +++++++++++++++++++---------
 2 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index a4a323c..a7825f9 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -83,7 +83,6 @@
 
 /* default timeout */
 #define DEFAULT_PEER_TIMEOUT    180
-#define LNET_LND_DEFAULT_TIMEOUT 5
 
 int choose_ipv4_src(u32 *ret, int interface, u32 dst_ipaddr, struct net *ns);
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index a966e64..62b4fa7 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -170,7 +170,15 @@ static int recovery_interval_set(const char *val,
 MODULE_PARM_DESC(lnet_retry_count,
 		 "Maximum number of times to retry transmitting a message");
 
-unsigned int lnet_lnd_timeout = LNET_LND_DEFAULT_TIMEOUT;
+#define LNET_LND_TIMEOUT_DEFAULT ((LNET_TRANSACTION_TIMEOUT_HEALTH_DEFAULT - 1) / \
+				  (LNET_RETRY_COUNT_HEALTH_DEFAULT + 1))
+unsigned int lnet_lnd_timeout = LNET_LND_TIMEOUT_DEFAULT;
+static void lnet_set_lnd_timeout(void)
+{
+	lnet_lnd_timeout = (lnet_transaction_timeout - 1) /
+			   (lnet_retry_count + 1);
+}
+
 unsigned int lnet_current_net_count;
 
 /*
@@ -220,6 +228,7 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 		lnet_transaction_timeout =
 			LNET_TRANSACTION_TIMEOUT_HEALTH_DEFAULT;
 		lnet_retry_count = LNET_RETRY_COUNT_HEALTH_DEFAULT;
+		lnet_set_lnd_timeout();
 	/* if we're turning off health then use the no health timeout
 	 * default.
 	 */
@@ -227,6 +236,7 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 		lnet_transaction_timeout =
 			LNET_TRANSACTION_TIMEOUT_NO_HEALTH_DEFAULT;
 		lnet_retry_count = 0;
+		lnet_set_lnd_timeout();
 	}
 
 	*sensitivity = value;
@@ -385,10 +395,10 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	}
 
 	*transaction_to = value;
-	if (lnet_retry_count == 0)
-		lnet_lnd_timeout = value;
-	else
-		lnet_lnd_timeout = value / lnet_retry_count;
+	/* Update the lnet_lnd_timeout now that we've modified the
+	 * transaction timeout
+	 */
+	lnet_set_lnd_timeout();
 
 	mutex_unlock(&the_lnet.ln_api_mutex);
 
@@ -428,10 +438,10 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 
 	*retry_count = value;
 
-	if (value == 0)
-		lnet_lnd_timeout = lnet_transaction_timeout;
-	else
-		lnet_lnd_timeout = lnet_transaction_timeout / value;
+	/* Update the lnet_lnd_timeout now that we've modified the
+	 * transaction timeout
+	 */
+	lnet_set_lnd_timeout();
 
 	mutex_unlock(&the_lnet.ln_api_mutex);
 
-- 
1.8.3.1
