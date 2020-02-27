From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:23 -0500
Subject: [lustre-devel] [PATCH 155/622] lnet: properly error check
 sensitivity
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-156-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Reject setting health sensitivity greater than the maximum health
value.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11530
Lustre-commit: a5c1cd5ec240 ("LU-11530 lnet: properly error check sensitivity")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33392
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 21e0175..a2c648e 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -175,9 +175,11 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 		return 0;
 	}
 
-	if (value == *sensitivity) {
+	if (value > LNET_MAX_HEALTH_VALUE) {
 		mutex_unlock(&the_lnet.ln_api_mutex);
-		return 0;
+		CERROR("Invalid health value. Maximum: %d value = %lu\n",
+		       LNET_MAX_HEALTH_VALUE, value);
+		return -EINVAL;
 	}
 
 	*sensitivity = value;
-- 
1.8.3.1
