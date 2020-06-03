From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:58 -0400
Subject: [lustre-devel] [PATCH 19/22] lnet: lnd: Allow independent socklnd
 timeout
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Allow the socklnd timeout to be set independent of
lnet_transaction_timeout and retry_count.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13510
Lustre-commit: 5c2a1267f9471 ("LU-13510 lnd: Allow independent socklnd timeout")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/38460
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c           |  4 ++--
 net/lnet/klnds/socklnd/socklnd.h           |  7 +++++++
 net/lnet/klnds/socklnd/socklnd_cb.c        | 16 ++++++++--------
 net/lnet/klnds/socklnd/socklnd_modparams.c |  2 +-
 4 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index b5d92d3..444b90b 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -1311,7 +1311,7 @@ struct ksock_peer_ni *
 	/* Set the deadline for the outgoing HELLO to drain */
 	conn->ksnc_tx_bufnob = sock->sk->sk_wmem_queued;
 	conn->ksnc_tx_deadline = ktime_get_seconds() +
-				 lnet_get_lnd_timeout();
+				 ksocknal_timeout();
 	mb();   /* order with adding to peer_ni's conn list */
 
 	list_add(&conn->ksnc_list, &peer_ni->ksnp_conns);
@@ -1699,7 +1699,7 @@ struct ksock_peer_ni *
 	switch (conn->ksnc_rx_state) {
 	case SOCKNAL_RX_LNET_PAYLOAD:
 		last_rcv = conn->ksnc_rx_deadline -
-			   lnet_get_lnd_timeout();
+			   ksocknal_timeout();
 		CERROR("Completing partial receive from %s[%d], ip %pI4h:%d, with error, wanted: %zd, left: %d, last alive is %lld secs ago\n",
 		       libcfs_id2str(conn->ksnc_peer->ksnp_id), conn->ksnc_type,
 		       &conn->ksnc_ipaddr, conn->ksnc_port,
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 6c77b75..7d49fff 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -610,6 +610,13 @@ struct ksock_proto {
 		ksocknal_destroy_peer(peer_ni);
 }
 
+static inline int ksocknal_timeout(void)
+{
+	return *ksocknal_tunables.ksnd_timeout ?
+		*ksocknal_tunables.ksnd_timeout :
+		lnet_get_lnd_timeout();
+}
+
 int ksocknal_startup(struct lnet_ni *ni);
 void ksocknal_shutdown(struct lnet_ni *ni);
 int ksocknal_ctl(struct lnet_ni *ni, unsigned int cmd, void *arg);
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index c03f91c7..2759455 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -218,7 +218,7 @@ struct ksock_tx *
 			 * something got ACKed
 			 */
 			conn->ksnc_tx_deadline = ktime_get_seconds() +
-						 lnet_get_lnd_timeout();
+						 ksocknal_timeout();
 			conn->ksnc_peer->ksnp_last_alive = ktime_get_seconds();
 			conn->ksnc_tx_bufnob = bufnob;
 			mb();
@@ -264,7 +264,7 @@ struct ksock_tx *
 
 	conn->ksnc_peer->ksnp_last_alive = ktime_get_seconds();
 	conn->ksnc_rx_deadline = ktime_get_seconds() +
-				 lnet_get_lnd_timeout();
+				 ksocknal_timeout();
 	mb();		/* order with setting rx_started */
 	conn->ksnc_rx_started = 1;
 
@@ -419,7 +419,7 @@ struct ksock_tx *
 
 	/* ZC_REQ is going to be pinned to the peer_ni */
 	tx->tx_deadline = ktime_get_seconds() +
-			  lnet_get_lnd_timeout();
+			  ksocknal_timeout();
 
 	LASSERT(!tx->tx_msg.ksm_zc_cookies[0]);
 
@@ -711,7 +711,7 @@ struct ksock_conn *
 	if (list_empty(&conn->ksnc_tx_queue) && !bufnob) {
 		/* First packet starts the timeout */
 		conn->ksnc_tx_deadline = ktime_get_seconds() +
-					 lnet_get_lnd_timeout();
+					 ksocknal_timeout();
 		if (conn->ksnc_tx_bufnob > 0) /* something got ACKed */
 			conn->ksnc_peer->ksnp_last_alive = ktime_get_seconds();
 		conn->ksnc_tx_bufnob = 0;
@@ -887,7 +887,7 @@ struct ksock_route *
 	    ksocknal_find_connecting_route_locked(peer_ni)) {
 		/* the message is going to be pinned to the peer_ni */
 		tx->tx_deadline = ktime_get_seconds() +
-				  lnet_get_lnd_timeout();
+				  ksocknal_timeout();
 
 		/* Queue the message until a connection is established */
 		list_add_tail(&tx->tx_list, &peer_ni->ksnp_tx_queue);
@@ -1652,7 +1652,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	/* socket type set on active connections - not set on passive */
 	LASSERT(!active == !(conn->ksnc_type != SOCKLND_CONN_NONE));
 
-	timeout = active ? lnet_get_lnd_timeout() :
+	timeout = active ? ksocknal_timeout() :
 			    lnet_acceptor_timeout();
 
 	rc = lnet_sock_read(sock, &hello->kshm_magic,
@@ -1790,7 +1790,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	int retry_later = 0;
 	int rc = 0;
 
-	deadline = ktime_get_seconds() + lnet_get_lnd_timeout();
+	deadline = ktime_get_seconds() + ksocknal_timeout();
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
@@ -2550,7 +2550,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			 * timeout interval.
 			 */
 
-			lnd_timeout = lnet_get_lnd_timeout();
+			lnd_timeout = ksocknal_timeout();
 			if (lnd_timeout > n * p)
 				chunk = (chunk * n * p) / lnd_timeout;
 			if (!chunk)
diff --git a/net/lnet/klnds/socklnd/socklnd_modparams.c b/net/lnet/klnds/socklnd/socklnd_modparams.c
index 35b71ba..b511e54 100644
--- a/net/lnet/klnds/socklnd/socklnd_modparams.c
+++ b/net/lnet/klnds/socklnd/socklnd_modparams.c
@@ -24,7 +24,7 @@
 #include <asm/hypervisor.h>
 #endif
 
-static int sock_timeout = 50;
+static int sock_timeout;
 module_param(sock_timeout, int, 0644);
 MODULE_PARM_DESC(sock_timeout, "dead socket timeout (seconds)");
 
-- 
1.8.3.1
