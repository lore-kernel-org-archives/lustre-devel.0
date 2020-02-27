From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:15 -0500
Subject: [lustre-devel] [PATCH 327/622] lnet: verify msg is commited for
 send/recv
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-328-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Before performing a health check make sure the message
is committed for either send or receive. Otherwise we
can just finalize it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12199
Lustre-commit: fc6b321036f3 ("LU-12199 lnet: verify msg is commited for send/recv")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34797
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-msg.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index dbd8de4..e4253de 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -790,6 +790,20 @@
 	bool hc;
 	int status = msg->msg_ev.status;
 
+	if ((!msg->msg_tx_committed && !msg->msg_rx_committed) ||
+	    !msg->msg_onactivelist) {
+		CDEBUG(D_NET, "msg %p not committed for send or receive\n",
+		       msg);
+		return false;
+	}
+
+	if ((msg->msg_tx_committed && !msg->msg_txpeer) ||
+	    (msg->msg_rx_committed && !msg->msg_rxpeer)) {
+		CDEBUG(D_NET, "msg %p failed too early to retry and send\n",
+		       msg);
+		return false;
+	}
+
 	/* perform a health check for any message committed for transmit */
 	hc = msg->msg_tx_committed;
 
-- 
1.8.3.1
