From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:40 -0500
Subject: [lustre-devel] [PATCH 412/622] lnet: Misleading error from
 lnet_is_health_check
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-413-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

In the case of sending to 0 at lo we never set msg_txpeer nor
msg_rxpeer. This results in failing this lnet_is_health_check
condition and a misleading error message. The condition is only an
error the msg status is non-zero.

An additional case where we can have msg_rx_committed, but not
msg_rxpeer is for optimized GETs. In this case we allocate a reply
message but do not set msg_rxpeer.  We cannot perform further health
checking on this message, but it is not an error condition.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12440
Lustre-commit: 6caa6ed07df0 ("LU-12440 lnet: Misleading error from lnet_is_health_check")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/35235
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-msg.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 9ffd874..b70a6c9 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -848,8 +848,13 @@
 
 	if ((msg->msg_tx_committed && !msg->msg_txpeer) ||
 	    (msg->msg_rx_committed && !msg->msg_rxpeer)) {
-		CDEBUG(D_NET, "msg %p failed too early to retry and send\n",
-		       msg);
+		/* The optimized GET case does not set msg_rxpeer, but status
+		 * could be zero. Only print the error message if we have a
+		 * non-zero status.
+		 */
+		if (status)
+			CDEBUG(D_NET, "msg %p status %d cannot retry\n", msg,
+			       status);
 		return false;
 	}
 
-- 
1.8.3.1
