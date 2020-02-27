From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:12 -0500
Subject: [lustre-devel] [PATCH 084/622] lnet: calculate the lnd timeout
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-85-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Calculate the LND timeout based on the transaction timeout
and the retry count. Both of these are user defined values. Whenever
they are set the lnd timeout is calculated. The LNDs use these
timeouts instead of the LND timeout module parameter.

Retry count can be set to 0, which means no retries. In that case the
LND timeout will default to 5 seconds, which is the same as the
default transaction timeout.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 84f3af43c4bd ("LU-9120 lnet: calculate the lnd timeout")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32770
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h       |  2 ++
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 20 +++++++++++---------
 net/lnet/klnds/socklnd/socklnd.c    |  6 +++---
 net/lnet/klnds/socklnd/socklnd_cb.c | 22 ++++++++++++----------
 net/lnet/lnet/api-ni.c              |  9 +++++++++
 5 files changed, 37 insertions(+), 22 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index ace0d51..5500e3f 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -85,6 +85,7 @@
 extern struct kmem_cache *lnet_small_mds_cachep; /* <= LNET_SMALL_MD_SIZE bytes
 						  * MDs kmem_cache
 						  */
+#define LNET_LND_DEFAULT_TIMEOUT 5
 
 static inline int lnet_is_route_alive(struct lnet_route *route)
 {
@@ -676,6 +677,7 @@ void lnet_copy_kiov2iter(struct iov_iter *to,
 struct page *lnet_kvaddr_to_page(unsigned long vaddr);
 int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset);
 
+unsigned int lnet_get_lnd_timeout(void);
 void lnet_register_lnd(struct lnet_lnd *lnd);
 void lnet_unregister_lnd(struct lnet_lnd *lnd);
 
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 007058a..c6e8e73 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1205,7 +1205,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	LASSERT(!tx->tx_queued);	/* not queued for sending already */
 	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
 
-	timeout_ns = *kiblnd_tunables.kib_timeout * NSEC_PER_SEC;
+	timeout_ns = lnet_get_lnd_timeout() * NSEC_PER_SEC;
 	tx->tx_queued = 1;
 	tx->tx_deadline = ktime_add_ns(ktime_get(), timeout_ns);
 
@@ -1333,14 +1333,14 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	if (*kiblnd_tunables.kib_use_priv_port) {
 		rc = kiblnd_resolve_addr(cmid, &srcaddr, &dstaddr,
-					 *kiblnd_tunables.kib_timeout * 1000);
+					 lnet_get_lnd_timeout() * 1000);
 	} else {
 		rc = rdma_resolve_addr(cmid,
 				       (struct sockaddr *)&srcaddr,
 				       (struct sockaddr *)&dstaddr,
-				       *kiblnd_tunables.kib_timeout * 1000);
+				       lnet_get_lnd_timeout() * 1000);
 	}
-	if (rc) {
+	if (rc != 0) {
 		/* Can't initiate address resolution:  */
 		CERROR("Can't resolve addr for %s: %d\n",
 		       libcfs_nid2str(peer_ni->ibp_nid), rc);
@@ -3097,8 +3097,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 				event->status);
 			rc = event->status;
 		} else {
-			rc = rdma_resolve_route(
-				cmid, *kiblnd_tunables.kib_timeout * 1000);
+			rc = rdma_resolve_route(cmid,
+						lnet_get_lnd_timeout() * 1000);
 			if (!rc) {
 				struct kib_net *net = peer_ni->ibp_ni->ni_data;
 				struct kib_dev *dev = net->ibn_dev;
@@ -3499,6 +3499,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			const int n = 4;
 			const int p = 1;
 			int chunk = kiblnd_data.kib_peer_hash_size;
+			unsigned int lnd_timeout;
 
 			spin_unlock_irqrestore(lock, flags);
 			dropped_lock = 1;
@@ -3512,9 +3513,10 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			 * connection within (n+1)/n times the timeout
 			 * interval.
 			 */
-			if (*kiblnd_tunables.kib_timeout > n * p)
-				chunk = (chunk * n * p) /
-					*kiblnd_tunables.kib_timeout;
+
+			lnd_timeout = lnet_get_lnd_timeout();
+			if (lnd_timeout > n * p)
+				chunk = (chunk * n * p) / lnd_timeout;
 			if (!chunk)
 				chunk = 1;
 
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 03fa706..891d3bd 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -1284,7 +1284,7 @@ struct ksock_peer *
 	/* Set the deadline for the outgoing HELLO to drain */
 	conn->ksnc_tx_bufnob = sock->sk->sk_wmem_queued;
 	conn->ksnc_tx_deadline = ktime_get_seconds() +
-				 *ksocknal_tunables.ksnd_timeout;
+				 lnet_get_lnd_timeout();
 	mb();   /* order with adding to peer_ni's conn list */
 
 	list_add(&conn->ksnc_list, &peer_ni->ksnp_conns);
@@ -1674,7 +1674,7 @@ struct ksock_peer *
 	switch (conn->ksnc_rx_state) {
 	case SOCKNAL_RX_LNET_PAYLOAD:
 		last_rcv = conn->ksnc_rx_deadline -
-			   *ksocknal_tunables.ksnd_timeout;
+			   lnet_get_lnd_timeout();
 		CERROR("Completing partial receive from %s[%d], ip %pI4h:%d, with error, wanted: %zd, left: %d, last alive is %lld secs ago\n",
 		       libcfs_id2str(conn->ksnc_peer->ksnp_id), conn->ksnc_type,
 		       &conn->ksnc_ipaddr, conn->ksnc_port,
@@ -1849,7 +1849,7 @@ struct ksock_peer *
 			if (bufnob < conn->ksnc_tx_bufnob) {
 				/* something got ACKed */
 				conn->ksnc_tx_deadline = ktime_get_seconds() +
-							 *ksocknal_tunables.ksnd_timeout;
+							 lnet_get_lnd_timeout();
 				peer_ni->ksnp_last_alive = now;
 				conn->ksnc_tx_bufnob = bufnob;
 			}
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index d50e0d2..8bc23d2 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -222,7 +222,7 @@ struct ksock_tx *
 			 * something got ACKed
 			 */
 			conn->ksnc_tx_deadline = ktime_get_seconds() +
-						 *ksocknal_tunables.ksnd_timeout;
+						 lnet_get_lnd_timeout();
 			conn->ksnc_peer->ksnp_last_alive = ktime_get_seconds();
 			conn->ksnc_tx_bufnob = bufnob;
 			mb();
@@ -268,7 +268,7 @@ struct ksock_tx *
 
 	conn->ksnc_peer->ksnp_last_alive = ktime_get_seconds();
 	conn->ksnc_rx_deadline = ktime_get_seconds() +
-				 *ksocknal_tunables.ksnd_timeout;
+				 lnet_get_lnd_timeout();
 	mb();		/* order with setting rx_started */
 	conn->ksnc_rx_started = 1;
 
@@ -423,7 +423,7 @@ struct ksock_tx *
 
 	/* ZC_REQ is going to be pinned to the peer_ni */
 	tx->tx_deadline = ktime_get_seconds() +
-			  *ksocknal_tunables.ksnd_timeout;
+			  lnet_get_lnd_timeout();
 
 	LASSERT(!tx->tx_msg.ksm_zc_cookies[0]);
 
@@ -705,7 +705,7 @@ struct ksock_conn *
 	if (list_empty(&conn->ksnc_tx_queue) && !bufnob) {
 		/* First packet starts the timeout */
 		conn->ksnc_tx_deadline = ktime_get_seconds() +
-					 *ksocknal_tunables.ksnd_timeout;
+					 lnet_get_lnd_timeout();
 		if (conn->ksnc_tx_bufnob > 0) /* something got ACKed */
 			conn->ksnc_peer->ksnp_last_alive = ktime_get_seconds();
 		conn->ksnc_tx_bufnob = 0;
@@ -881,7 +881,7 @@ struct ksock_route *
 	    ksocknal_find_connecting_route_locked(peer_ni)) {
 		/* the message is going to be pinned to the peer_ni */
 		tx->tx_deadline = ktime_get_seconds() +
-				  *ksocknal_tunables.ksnd_timeout;
+				  lnet_get_lnd_timeout();
 
 		/* Queue the message until a connection is established */
 		list_add_tail(&tx->tx_list, &peer_ni->ksnp_tx_queue);
@@ -1663,7 +1663,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	/* socket type set on active connections - not set on passive */
 	LASSERT(!active == !(conn->ksnc_type != SOCKLND_CONN_NONE));
 
-	timeout = active ? *ksocknal_tunables.ksnd_timeout :
+	timeout = active ? lnet_get_lnd_timeout() :
 			    lnet_acceptor_timeout();
 
 	rc = lnet_sock_read(sock, &hello->kshm_magic,
@@ -1801,7 +1801,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	int retry_later = 0;
 	int rc = 0;
 
-	deadline = ktime_get_seconds() + *ksocknal_tunables.ksnd_timeout;
+	deadline = ktime_get_seconds() + lnet_get_lnd_timeout();
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
@@ -2552,6 +2552,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			const int n = 4;
 			const int p = 1;
 			int chunk = ksocknal_data.ksnd_peer_hash_size;
+			unsigned int lnd_timeout;
 
 			/*
 			 * Time to check for timeouts on a few more peers: I do
@@ -2561,9 +2562,10 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			 * timeout on any connection within (n+1)/n times the
 			 * timeout interval.
 			 */
-			if (*ksocknal_tunables.ksnd_timeout > n * p)
-				chunk = (chunk * n * p) /
-					*ksocknal_tunables.ksnd_timeout;
+
+			lnd_timeout = lnet_get_lnd_timeout();
+			if (lnd_timeout > n * p)
+				chunk = (chunk * n * p) / lnd_timeout;
 			if (!chunk)
 				chunk = 1;
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index a54fe2c..e467d64 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -121,6 +121,8 @@ struct lnet the_lnet = {
 MODULE_PARM_DESC(lnet_retry_count,
 		 "Maximum number of times to retry transmitting a message");
 
+unsigned int lnet_lnd_timeout = LNET_LND_DEFAULT_TIMEOUT;
+
 /*
  * This sequence number keeps track of how many times DLC was used to
  * update the local NIs. It is incremented when a NI is added or
@@ -570,6 +572,13 @@ static void lnet_assert_wire_constants(void)
 	return NULL;
 }
 
+unsigned int
+lnet_get_lnd_timeout(void)
+{
+	return lnet_lnd_timeout;
+}
+EXPORT_SYMBOL(lnet_get_lnd_timeout);
+
 void
 lnet_register_lnd(struct lnet_lnd *lnd)
 {
-- 
1.8.3.1
