From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:27 -0500
Subject: [lustre-devel] [PATCH 339/622] lnet: simplify
 lnet_handle_local_failure()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-340-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Pass the struct lnet_ni to lnet_handle_local_failure() instead of the
message structure, since nothing else from the message is being
used. This also makes symmetrical with lnet_handle_remote_failure()

WC-bug-id: https://jira.whamcloud.com/browse/LU-11300
Lustre-commit: f8c7dd6f5374 ("LU-11300 lnet: simplify lnet_handle_local_failure()")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33452
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-msg.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index e4253de..23c3bf4 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -461,12 +461,8 @@
 }
 
 static void
-lnet_handle_local_failure(struct lnet_msg *msg)
+lnet_handle_local_failure(struct lnet_ni *local_ni)
 {
-	struct lnet_ni *local_ni;
-
-	local_ni = msg->msg_txni;
-
 	/* the lnet_net_lock(0) is used to protect the addref on the ni
 	 * and the recovery queue.
 	 */
@@ -652,7 +648,7 @@
 	case LNET_MSG_STATUS_LOCAL_ABORTED:
 	case LNET_MSG_STATUS_LOCAL_NO_ROUTE:
 	case LNET_MSG_STATUS_LOCAL_TIMEOUT:
-		lnet_handle_local_failure(msg);
+		lnet_handle_local_failure(msg->msg_txni);
 		/* add to the re-send queue */
 		goto resend;
 
@@ -660,7 +656,7 @@
 	 * finalize the message
 	 */
 	case LNET_MSG_STATUS_LOCAL_ERROR:
-		lnet_handle_local_failure(msg);
+		lnet_handle_local_failure(msg->msg_txni);
 		return -1;
 
 	/* TODO: since the remote dropped the message we can
-- 
1.8.3.1
