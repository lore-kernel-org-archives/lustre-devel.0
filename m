From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:11 -0500
Subject: [lustre-devel] [PATCH 083/622] lnet: add retry count
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-84-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Added a module parameter to define the number of retries on a
message. It defaults to 0, which means no retries will be attempted.
Each message will keep track of the number of times it has been
retransmitted. When queuing it on the resend queue, the retry count
will be checked and if it's exceeded, then the message will be
finalized.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 20e23980eae2 ("LU-9120 lnet: add retry count")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32769
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  | 1 +
 include/linux/lnet/lib-types.h | 2 ++
 net/lnet/lnet/api-ni.c         | 5 +++++
 net/lnet/lnet/lib-msg.c        | 8 +++++++-
 4 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index b8ca114..ace0d51 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -478,6 +478,7 @@ struct lnet_ni *
 struct lnet_net *lnet_get_net_locked(u32 net_id);
 
 extern unsigned int lnet_transaction_timeout;
+extern unsigned int lnet_retry_count;
 extern unsigned int lnet_numa_range;
 extern unsigned int lnet_health_sensitivity;
 extern unsigned int lnet_peer_discovery_disabled;
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 19b83a4..1108e3b 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -103,6 +103,8 @@ struct lnet_msg {
 	enum lnet_msg_hstatus	msg_health_status;
 	/* This is a recovery message */
 	bool			msg_recovery;
+	/* the number of times a transmission has been retried */
+	int			msg_retry_count;
 	/* flag to indicate that we do not want to resend this message */
 	bool			msg_no_resend;
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 97d9be5..a54fe2c 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -116,6 +116,11 @@ struct lnet the_lnet = {
 MODULE_PARM_DESC(lnet_transaction_timeout,
 		 "Time in seconds to wait for a REPLY or an ACK");
 
+unsigned int lnet_retry_count;
+module_param(lnet_retry_count, uint, 0444);
+MODULE_PARM_DESC(lnet_retry_count,
+		 "Maximum number of times to retry transmitting a message");
+
 /*
  * This sequence number keeps track of how many times DLC was used to
  * update the local NIs. It is incremented when a NI is added or
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 046923b..9841e14 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -556,7 +556,8 @@
 }
 
 /* Do a health check on the message:
- * return -1 if we're not going to handle the error
+ * return -1 if we're not going to handle the error or
+ *   if we've reached the maximum number of retries.
  *   success case will return -1 as well
  * return 0 if it the message is requeued for send
  */
@@ -646,6 +647,11 @@
 	if (msg->msg_no_resend)
 		return -1;
 
+	/* check if the message has exceeded the number of retries */
+	if (msg->msg_retry_count >= lnet_retry_count)
+		return -1;
+	msg->msg_retry_count++;
+
 	lnet_net_lock(msg->msg_tx_cpt);
 
 	/* remove message from the active list and reset it in preparation
-- 
1.8.3.1
