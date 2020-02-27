From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:42 -0500
Subject: [lustre-devel] [PATCH 174/622] lnet: increase lnet transaction
 timeout
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-175-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sonia Sharma <sharmaso@whamcloud.com>

Increase the new LNet Health transaction timeout to the original
50s value, to avoid spurious lnet-selftest failures and expected
false timeouts under load.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11389
Lustre-commit: 73fdd1579d87 ("LU-11389 lnet: increase lnet transaction timeout")
Signed-off-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33231
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Nunez <jnunez@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 25592db..3ee10da 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -126,7 +126,7 @@ static int recovery_interval_set(const char *val,
 MODULE_PARM_DESC(lnet_peer_discovery_disabled,
 		 "Set to 1 to disable peer discovery on this node.");
 
-unsigned int lnet_transaction_timeout = 5;
+unsigned int lnet_transaction_timeout = 50;
 static int transaction_to_set(const char *val, const struct kernel_param *kp);
 static struct kernel_param_ops param_ops_transaction_timeout = {
 	.set = transaction_to_set,
-- 
1.8.3.1
