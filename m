From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:18:10 -0500
Subject: [lustre-devel] [PATCH 622/622] lnet: use conservative health
 timeouts
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-623-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Use more conservative lnet_transaction_timeout and lnet_retry_count
values by default.  Currently with timeout=10 and retry=3 there is
only a 3s window for the RPC to be sent before it is timed out.
This has caused fault injection rather than fault tolerance.
Increase the default timeout to 50s with retry=2, which is hopefully
long enough to cover virtually all uses, but still allows LNet Health
to be enabled by default and resend before Lustre times out itself.

Fixes: d24c948e4467 ("lnet: setup health timeout defaults")

WC-bug-id: https://jira.whamcloud.com/browse/LU-13145
Lustre-commit: 361e9eaef13c ("LU-13145 lnet: use conservative health timeouts")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/37430
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index ea23471..10ade73 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -141,7 +141,7 @@ static int recovery_interval_set(const char *val,
 		 "Set to 1 to drop asymmetrical route messages.");
 
 #define LNET_TRANSACTION_TIMEOUT_NO_HEALTH_DEFAULT 50
-#define LNET_TRANSACTION_TIMEOUT_HEALTH_DEFAULT 10
+#define LNET_TRANSACTION_TIMEOUT_HEALTH_DEFAULT 50
 
 unsigned int lnet_transaction_timeout = LNET_TRANSACTION_TIMEOUT_HEALTH_DEFAULT;
 static int transaction_to_set(const char *val, const struct kernel_param *kp);
@@ -156,7 +156,7 @@ static int recovery_interval_set(const char *val,
 MODULE_PARM_DESC(lnet_transaction_timeout,
 		 "Maximum number of seconds to wait for a peer response.");
 
-#define LNET_RETRY_COUNT_HEALTH_DEFAULT 3
+#define LNET_RETRY_COUNT_HEALTH_DEFAULT 2
 unsigned int lnet_retry_count = LNET_RETRY_COUNT_HEALTH_DEFAULT;
 static int retry_count_set(const char *val, const struct kernel_param *kp);
 static struct kernel_param_ops param_ops_retry_count = {
-- 
1.8.3.1
