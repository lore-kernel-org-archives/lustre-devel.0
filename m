From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:49 -0400
Subject: [lustre-devel] [PATCH 030/151] lnet: fix memory leak and
 lnet_interfaces_max
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-31-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Free buffer allocated for discover command.

Set lnet_interfaces_max to LNET_INTERFACES_MAX_DEFAULT if
it's not defined or if it's being set to something below
LNET_INTERFACES_MIN.

For lnet_ping() and lnet_discover() if the provided space
can fit more NIDs than lnet_interfaces_max then ensure only
lnet_interfaces_max is copied into the buffer.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9909
Lustre-commit: 81d4f7a25319 ("LU-9909 lnet: fix memory leak and lnet_interfaces_max")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28702
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 47f4f2a..78fd05f 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -170,8 +170,8 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 
 	if (value < LNET_INTERFACES_MIN) {
 		CWARN("max interfaces provided are too small, setting to %d\n",
-		      LNET_INTERFACES_MIN);
-		value = LNET_INTERFACES_MIN;
+		      LNET_INTERFACES_MAX_DEFAULT);
+		value = LNET_INTERFACES_MAX_DEFAULT;
 	}
 
 	*(int *)kp->arg = value;
@@ -3407,9 +3407,15 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 	int rc2;
 
 	/* n_ids limit is arbitrary */
-	if (n_ids <= 0 || n_ids > lnet_interfaces_max || id.nid == LNET_NID_ANY)
+	if (n_ids <= 0 || id.nid == LNET_NID_ANY)
 		return -EINVAL;
 
+	/* if the user buffer has more space than the lnet_interfaces_max
+	 * then only fill it up to lnet_interfaces_max
+	 */
+	if (n_ids > lnet_interfaces_max)
+		n_ids = lnet_interfaces_max;
+
 	if (id.pid == LNET_PID_ANY)
 		id.pid = LNET_PID_LUSTRE;
 
@@ -3575,13 +3581,18 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 	int max_intf = lnet_interfaces_max;
 
 	if (n_ids <= 0 ||
-	    id.nid == LNET_NID_ANY ||
-	    n_ids > max_intf)
+	    id.nid == LNET_NID_ANY)
 		return -EINVAL;
 
 	if (id.pid == LNET_PID_ANY)
 		id.pid = LNET_PID_LUSTRE;
 
+	/* if the user buffer has more space than the max_intf
+	 * then only fill it up to max_intf
+	 */
+	if (n_ids > max_intf)
+		n_ids = max_intf;
+
 	buf = kcalloc(n_ids, sizeof(*buf), GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
-- 
1.8.3.1
