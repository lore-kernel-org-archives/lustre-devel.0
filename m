From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:14 -0500
Subject: [lustre-devel] [PATCH 326/622] lnet: Ensure md is detached when msg
 is not committed
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-327-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

It's possible for lnet_is_health_check() to return "true" when the
message has not hit the network. In this situation the message is
freed without detaching the MD. As a result, requests do not receive
their unlink events and these requests are stuck forever.

A little cleanup is included here:
 - The value of lnet_is_health_check() is only used in one place, so
   we don't need to save the result of it in a variable.
 - We don't need separate logic to detach the md when the send was
   successful. We'll fall through to the finalizing code after
   incrementing the health counters

Cray-bug-id: LUS-7239
WC-bug-id: https://jira.whamcloud.com/browse/LU-12199
Lustre-commit: b65f3a1767ae ("LU-12199 lnet: Ensure md is detached when msg is not committed")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/34885
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-msg.c | 66 +++++++++++++++----------------------------------
 1 file changed, 20 insertions(+), 46 deletions(-)

diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index ad35c3d..dbd8de4 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -784,16 +784,6 @@
 	msg->msg_md = NULL;
 }
 
-static void
-lnet_detach_md(struct lnet_msg *msg, int status)
-{
-	int cpt = lnet_cpt_of_cookie(msg->msg_md->md_lh.lh_cookie);
-
-	lnet_res_lock(cpt);
-	lnet_msg_detach_md(msg, cpt, status);
-	lnet_res_unlock(cpt);
-}
-
 static bool
 lnet_is_health_check(struct lnet_msg *msg)
 {
@@ -881,7 +871,6 @@
 	int cpt;
 	int rc;
 	int i;
-	bool hc;
 
 	LASSERT(!in_interrupt());
 
@@ -890,36 +879,7 @@
 
 	msg->msg_ev.status = status;
 
-	/* if the message is successfully sent, no need to keep the MD around */
-	if (msg->msg_md && !status)
-		lnet_detach_md(msg, status);
-
-again:
-	hc = lnet_is_health_check(msg);
-
-	/* the MD would've been detached from the message if it was
-	 * successfully sent. However, if it wasn't successfully sent the
-	 * MD would be around. And since we recalculate whether to
-	 * health check or not, it's possible that we change our minds and
-	 * we don't want to health check this message. In this case also
-	 * free the MD.
-	 *
-	 * If the message is successful we're going to
-	 * go through the lnet_health_check() function, but that'll just
-	 * increment the appropriate health value and return.
-	 */
-	if (msg->msg_md && !hc)
-		lnet_detach_md(msg, status);
-
-	rc = 0;
-	if (!msg->msg_tx_committed && !msg->msg_rx_committed) {
-		/* not committed to network yet */
-		LASSERT(!msg->msg_onactivelist);
-		kfree(msg);
-		return;
-	}
-
-	if (hc) {
+	if (lnet_is_health_check(msg)) {
 		/* Check the health status of the message. If it has one
 		 * of the errors that we're supposed to handle, and it has
 		 * not timed out, then
@@ -932,13 +892,26 @@
 		 * put on the resend queue.
 		 */
 		if (!lnet_health_check(msg))
+			/* Message is queued for resend */
 			return;
+	}
 
-		/* if we get here then we need to clean up the md because we're
-		 * finalizing the message.
-		 */
-		if (msg->msg_md)
-			lnet_detach_md(msg, status);
+	/* We're not going to resend this message so detach its MD and invoke
+	 * the appropriate callbacks
+	 */
+	if (msg->msg_md) {
+		cpt = lnet_cpt_of_cookie(msg->msg_md->md_lh.lh_cookie);
+		lnet_res_lock(cpt);
+		lnet_msg_detach_md(msg, cpt, status);
+		lnet_res_unlock(cpt);
+	}
+
+again:
+	if (!msg->msg_tx_committed && !msg->msg_rx_committed) {
+		/* not committed to network yet */
+		LASSERT(!msg->msg_onactivelist);
+		kfree(msg);
+		return;
 	}
 
 	/*
@@ -972,6 +945,7 @@
 
 	container->msc_finalizers[my_slot] = current;
 
+	rc = 0;
 	while ((msg = list_first_entry_or_null(&container->msc_finalizing,
 					       struct lnet_msg,
 					       msg_list)) != NULL) {
-- 
1.8.3.1
