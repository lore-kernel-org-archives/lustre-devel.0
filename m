From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:35 -0500
Subject: [lustre-devel] [PATCH 347/622] lnet: handle health for incoming
 messages
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-348-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

In case of routers (as well as for the general case) it's important to
update the health of the ni/lpni for incoming messages. For an lpni
specifically when we receive a message is when we know that the lpni
is up.

A percentage router health is required in order to send a message to a
gateway. That defaults to 100, meaning that a router interface has to
be absolutely healthy in order to send to it. This matches the current
behavior. So if a router interface goes down an its health goes down
significantly, but then it comes back up again; either we receive a
message from it or we discover it and get a reply, then in order to
start using that router interface again we have to boost its health
all the way up to maximum.

This behavior is special cased for routers.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11477
Lustre-commit: 18c850cb91a6 ("LU-11477 lnet: handle health for incoming messages")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33301
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-msg.c | 90 +++++++++++++++++++++++++++++++++++--------------
 1 file changed, 65 insertions(+), 25 deletions(-)

diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 23c3bf4..2cbaff8a 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -598,19 +598,23 @@
 {
 	enum lnet_msg_hstatus hstatus = msg->msg_health_status;
 	bool lo = false;
+	struct lnet_ni *ni;
+	struct lnet_peer_ni *lpni;
 
 	/* if we're shutting down no point in handling health. */
 	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING)
 		return -1;
 
-	LASSERT(msg->msg_txni);
+	LASSERT(msg->msg_tx_committed || msg->msg_rx_committed);
 
 	/* if we're sending to the LOLND then the msg_txpeer will not be
 	 * set. So no need to sanity check it.
 	 */
-	if (LNET_NETTYP(LNET_NIDNET(msg->msg_txni->ni_nid)) != LOLND)
+	if (msg->msg_tx_committed &&
+	    LNET_NETTYP(LNET_NIDNET(msg->msg_txni->ni_nid)) != LOLND)
 		LASSERT(msg->msg_txpeer);
-	else
+	else if (msg->msg_tx_committed &&
+		 LNET_NETTYP(LNET_NIDNET(msg->msg_txni->ni_nid)) == LOLND)
 		lo = true;
 
 	if (hstatus != LNET_MSG_STATUS_OK &&
@@ -626,20 +630,52 @@
 		lnet_net_unlock(0);
 	}
 
+	/* always prefer txni/txpeer if they message is committed for both
+	 * directions.
+	 */
+	if (msg->msg_tx_committed) {
+		ni = msg->msg_txni;
+		lpni = msg->msg_txpeer;
+	} else {
+		ni = msg->msg_rxni;
+		lpni = msg->msg_rxpeer;
+	}
+
+	if (!lo)
+		LASSERT(ni && lpni);
+	else
+		LASSERT(ni);
+
 	CDEBUG(D_NET, "health check: %s->%s: %s: %s\n",
-	       libcfs_nid2str(msg->msg_txni->ni_nid),
-	       (lo) ? "self" : libcfs_nid2str(msg->msg_txpeer->lpni_nid),
+	       libcfs_nid2str(ni->ni_nid),
+	       (lo) ? "self" : libcfs_nid2str(lpni->lpni_nid),
 	       lnet_msgtyp2str(msg->msg_type),
 	       lnet_health_error2str(hstatus));
 
 	switch (hstatus) {
 	case LNET_MSG_STATUS_OK:
-		lnet_inc_healthv(&msg->msg_txni->ni_healthv);
+		/* increment the local ni health weather we successfully
+		 * received or sent a message on it.
+		 */
+		lnet_inc_healthv(&ni->ni_healthv);
 		/* It's possible msg_txpeer is NULL in the LOLND
-		 * case.
+		 * case. Only increment the peer's health if we're
+		 * receiving a message from it. It's the only sure way to
+		 * know that a remote interface is up.
+		 * If this interface is part of a router, then take that
+		 * as indication that the router is fully healthy.
 		 */
-		if (msg->msg_txpeer)
-			lnet_inc_healthv(&msg->msg_txpeer->lpni_healthv);
+		if (lpni && msg->msg_rx_committed) {
+			/* If we're receiving a message from the router or
+			 * I'm a router, then set that lpni's health to
+			 * maximum so we can commence communication
+			 */
+			if (lnet_isrouter(lpni) || the_lnet.ln_routing)
+				lnet_set_healthv(&lpni->lpni_healthv,
+						 LNET_MAX_HEALTH_VALUE);
+			else
+				lnet_inc_healthv(&lpni->lpni_healthv);
+		}
 
 		/* we can finalize this message */
 		return -1;
@@ -648,34 +684,41 @@
 	case LNET_MSG_STATUS_LOCAL_ABORTED:
 	case LNET_MSG_STATUS_LOCAL_NO_ROUTE:
 	case LNET_MSG_STATUS_LOCAL_TIMEOUT:
-		lnet_handle_local_failure(msg->msg_txni);
-		/* add to the re-send queue */
-		goto resend;
+		lnet_handle_local_failure(ni);
+		if (msg->msg_tx_committed)
+			/* add to the re-send queue */
+			goto resend;
+		break;
 
 	/* These errors will not trigger a resend so simply
 	 * finalize the message
 	 */
 	case LNET_MSG_STATUS_LOCAL_ERROR:
-		lnet_handle_local_failure(msg->msg_txni);
+		lnet_handle_local_failure(ni);
 		return -1;
 
 	/* TODO: since the remote dropped the message we can
 	 * attempt a resend safely.
 	 */
 	case LNET_MSG_STATUS_REMOTE_DROPPED:
-		lnet_handle_remote_failure(msg->msg_txpeer);
-		goto resend;
+		lnet_handle_remote_failure(lpni);
+		if (msg->msg_tx_committed)
+			goto resend;
+		break;
 
 	case LNET_MSG_STATUS_REMOTE_ERROR:
 	case LNET_MSG_STATUS_REMOTE_TIMEOUT:
 	case LNET_MSG_STATUS_NETWORK_TIMEOUT:
-		lnet_handle_remote_failure(msg->msg_txpeer);
+		lnet_handle_remote_failure(lpni);
 		return -1;
 	default:
 		LBUG();
 	}
 
 resend:
+	/* we can only resend tx_committed messages */
+	LASSERT(msg->msg_tx_committed);
+
 	/* don't resend recovery messages */
 	if (msg->msg_recovery) {
 		CDEBUG(D_NET, "msg %s->%s is a recovery ping. retry# %d\n",
@@ -783,7 +826,7 @@
 static bool
 lnet_is_health_check(struct lnet_msg *msg)
 {
-	bool hc;
+	bool hc = true;
 	int status = msg->msg_ev.status;
 
 	if ((!msg->msg_tx_committed && !msg->msg_rx_committed) ||
@@ -800,15 +843,12 @@
 		return false;
 	}
 
-	/* perform a health check for any message committed for transmit */
-	hc = msg->msg_tx_committed;
-
 	/* Check for status inconsistencies */
-	if (hc &&
-	    ((!status && msg->msg_health_status != LNET_MSG_STATUS_OK) ||
-	     (status && msg->msg_health_status == LNET_MSG_STATUS_OK))) {
-		CERROR("Msg is in inconsistent state, don't perform health checking (%d, %d)\n",
-		       status, msg->msg_health_status);
+	if ((!status && msg->msg_health_status != LNET_MSG_STATUS_OK) ||
+	    (status && msg->msg_health_status == LNET_MSG_STATUS_OK)) {
+		CDEBUG(D_NET,
+		       "Msg %p is in inconsistent state, don't perform health checking (%d, %d)\n",
+		       msg, status, msg->msg_health_status);
 		hc = false;
 	}
 
-- 
1.8.3.1
