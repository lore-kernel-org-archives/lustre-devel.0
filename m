From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:09 -0400
Subject: [lustre-devel] [PATCH 13/23] lnet: Add param to control response
 tracking
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Add lnet_response_tracking parameter which will be used to control
the behavior of LNet response tracking.

HPE-bug-id: LUS-8827
WC-bug-id: https://jira.whamcloud.com/browse/LU-13502
Lustre-commit: 5b3747294a4bf ("LU-13502 lnet: Add param to control response tracking")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/38449
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  1 +
 net/lnet/lnet/api-ni.c        | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index b069422..e733807 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -417,6 +417,7 @@ struct lnet_ni *
 struct lnet_ni *lnet_net2ni_addref(u32 net);
 struct lnet_net *lnet_get_net_locked(u32 net_id);
 
+extern unsigned int lnet_response_tracking;
 extern unsigned int lnet_transaction_timeout;
 extern unsigned int lnet_retry_count;
 extern unsigned int lnet_lnd_timeout;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 5f35468..c90ab2e 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -170,6 +170,20 @@ static int recovery_interval_set(const char *val,
 MODULE_PARM_DESC(lnet_retry_count,
 		 "Maximum number of times to retry transmitting a message");
 
+unsigned int lnet_response_tracking = 3;
+static int response_tracking_set(const char *val,
+				 const struct kernel_param *kp);
+static struct kernel_param_ops param_ops_response_tracking = {
+	.set = response_tracking_set,
+	.get = param_get_int,
+};
+
+#define param_check_response_tracking(name, p)  \
+		__param_check(name, p, int)
+module_param(lnet_response_tracking, response_tracking, 0644);
+MODULE_PARM_DESC(lnet_response_tracking,
+		 "(0|1|2|3) LNet Internal Only|GET Reply only|PUT ACK only|Full Tracking (default)");
+
 #define LNET_LND_TIMEOUT_DEFAULT ((LNET_TRANSACTION_TIMEOUT_HEALTH_DEFAULT - 1) / \
 				  (LNET_RETRY_COUNT_HEALTH_DEFAULT + 1))
 unsigned int lnet_lnd_timeout = LNET_LND_TIMEOUT_DEFAULT;
@@ -470,6 +484,29 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	return 0;
 }
 
+static int
+response_tracking_set(const char *val, const struct kernel_param *kp)
+{
+	int rc;
+	unsigned long new_value;
+
+	rc = kstrtoul(val, 0, &new_value);
+	if (rc) {
+		CERROR("Invalid value for 'lnet_response_tracking'\n");
+		return -EINVAL;
+	}
+
+	if (new_value < 0 || new_value > 3) {
+		CWARN("Invalid value (%lu) for 'lnet_response_tracking'\n",
+		      new_value);
+		return -EINVAL;
+	}
+
+	lnet_response_tracking = new_value;
+
+	return 0;
+}
+
 static const char *
 lnet_get_routes(void)
 {
-- 
1.8.3.1
