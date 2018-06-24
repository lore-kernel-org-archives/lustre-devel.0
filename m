From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:53:48 -0400
Subject: [lustre-devel] [PATCH 4/8] staging: lustre: ksocklnd: move
 remaining time handling to 64 bits
In-Reply-To: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
References: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529877232-15582-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Examination of the ksocklnd time handle revealed that the
code only requires second level precision. Since this is
the case we can move away from using jiffies to time64_t.
This allows us to be independent of the HZ settings in
addition to making it clear what is time handling, using
time64_t verses unsigned long.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9397
Reviewed-on: https://review.whamcloud.com/26813
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  33 +++---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  20 ++--
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 117 ++++++++++-----------
 3 files changed, 83 insertions(+), 87 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 694f1d0..72c98ee 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -1276,7 +1276,7 @@ struct ksock_peer *
 	}
 
 	conn->ksnc_peer = peer;		 /* conn takes my ref on peer */
-	peer->ksnp_last_alive = jiffies;
+	peer->ksnp_last_alive = ktime_get_seconds();
 	peer->ksnp_send_keepalive = 0;
 	peer->ksnp_error = 0;
 
@@ -1284,10 +1284,11 @@ struct ksock_peer *
 	sched->kss_nconns++;
 	conn->ksnc_scheduler = sched;
 
-	conn->ksnc_tx_last_post = jiffies;
+	conn->ksnc_tx_last_post = ktime_get_seconds();
 	/* Set the deadline for the outgoing HELLO to drain */
 	conn->ksnc_tx_bufnob = sock->sk->sk_wmem_queued;
-	conn->ksnc_tx_deadline = jiffies + *ksocknal_tunables.ksnd_timeout * HZ;
+	conn->ksnc_tx_deadline = ktime_get_seconds() +
+				 *ksocknal_tunables.ksnd_timeout;
 	mb();   /* order with adding to peer's conn list */
 
 	list_add(&conn->ksnc_list, &peer->ksnp_conns);
@@ -1515,7 +1516,7 @@ struct ksock_peer *
 ksocknal_peer_failed(struct ksock_peer *peer)
 {
 	int notify = 0;
-	unsigned long last_alive = 0;
+	time64_t last_alive = 0;
 
 	/*
 	 * There has been a connection failure or comms error; but I'll only
@@ -1536,7 +1537,7 @@ struct ksock_peer *
 
 	if (notify)
 		lnet_notify(peer->ksnp_ni, peer->ksnp_id.nid, 0,
-			    last_alive);
+			    last_alive * HZ);
 }
 
 void
@@ -1660,7 +1661,7 @@ struct ksock_peer *
 void
 ksocknal_destroy_conn(struct ksock_conn *conn)
 {
-	unsigned long last_rcv;
+	time64_t last_rcv;
 
 	/* Final coup-de-grace of the reaper */
 	CDEBUG(D_NET, "connection %p\n", conn);
@@ -1677,12 +1678,12 @@ struct ksock_peer *
 	switch (conn->ksnc_rx_state) {
 	case SOCKNAL_RX_LNET_PAYLOAD:
 		last_rcv = conn->ksnc_rx_deadline -
-			   *ksocknal_tunables.ksnd_timeout * HZ;
-		CERROR("Completing partial receive from %s[%d], ip %pI4h:%d, with error, wanted: %zd, left: %d, last alive is %ld secs ago\n",
+			   *ksocknal_tunables.ksnd_timeout;
+		CERROR("Completing partial receive from %s[%d], ip %pI4h:%d, with error, wanted: %zd, left: %d, last alive is %lld secs ago\n",
 		       libcfs_id2str(conn->ksnc_peer->ksnp_id), conn->ksnc_type,
 		       &conn->ksnc_ipaddr, conn->ksnc_port,
 		       iov_iter_count(&conn->ksnc_rx_to), conn->ksnc_rx_nob_left,
-		       (jiffies - last_rcv) / HZ);
+		       ktime_get_seconds() - last_rcv);
 		lnet_finalize(conn->ksnc_peer->ksnp_ni,
 			      conn->ksnc_cookie, -EIO);
 		break;
@@ -1830,8 +1831,8 @@ struct ksock_peer *
 ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, unsigned long *when)
 {
 	int connect = 1;
-	unsigned long last_alive = 0;
-	unsigned long now = jiffies;
+	time64_t last_alive = 0;
+	time64_t now = ktime_get_seconds();
 	struct ksock_peer *peer = NULL;
 	rwlock_t *glock = &ksocknal_data.ksnd_global_lock;
 	struct lnet_process_id id = {
@@ -1851,8 +1852,8 @@ struct ksock_peer *
 
 			if (bufnob < conn->ksnc_tx_bufnob) {
 				/* something got ACKed */
-				conn->ksnc_tx_deadline =
-					jiffies + *ksocknal_tunables.ksnd_timeout * HZ;
+				conn->ksnc_tx_deadline = ktime_get_seconds() +
+							 *ksocknal_tunables.ksnd_timeout;
 				peer->ksnp_last_alive = now;
 				conn->ksnc_tx_bufnob = bufnob;
 			}
@@ -1866,11 +1867,11 @@ struct ksock_peer *
 	read_unlock(glock);
 
 	if (last_alive)
-		*when = last_alive;
+		*when = last_alive * HZ;
 
-	CDEBUG(D_NET, "Peer %s %p, alive %ld secs ago, connect %d\n",
+	CDEBUG(D_NET, "Peer %s %p, alive %lld secs ago, connect %d\n",
 	       libcfs_nid2str(nid), peer,
-	       last_alive ? (now - last_alive) / HZ : -1,
+	       last_alive ? now - last_alive : -1,
 	       connect);
 
 	if (!connect)
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 4e5c89a..20f5de6 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -57,7 +57,7 @@
 #define SOCKNAL_PEER_HASH_SIZE  101   /* # peer lists */
 #define SOCKNAL_RESCHED         100   /* # scheduler loops before reschedule */
 #define SOCKNAL_INSANITY_RECONN 5000  /* connd is trying on reconn infinitely */
-#define SOCKNAL_ENOMEM_RETRY    1     /* jiffies between retries */
+#define SOCKNAL_ENOMEM_RETRY    1     /* seconds between retries */
 
 #define SOCKNAL_SINGLE_FRAG_TX  0     /* disable multi-fragment sends */
 #define SOCKNAL_SINGLE_FRAG_RX  0     /* disable multi-fragment receives */
@@ -210,7 +210,7 @@ struct ksock_nal_data {
 							 * reaper_lock
 							 */
 	wait_queue_head_t       ksnd_reaper_waitq;      /* reaper sleeps here */
-	unsigned long	        ksnd_reaper_waketime;   /* when reaper will wake
+	time64_t		ksnd_reaper_waketime;   /* when reaper will wake
 							 */
 	spinlock_t              ksnd_reaper_lock;       /* serialise */
 
@@ -285,7 +285,7 @@ struct ksock_tx {			   /* transmit packet */
 	struct ksock_conn *tx_conn;        /* owning conn */
 	struct lnet_msg        *tx_lnetmsg;     /* lnet message for lnet_finalize()
 					    */
-	unsigned long     tx_deadline;     /* when (in jiffies) tx times out */
+	time64_t		tx_deadline;	/* when (in secs) tx times out */
 	struct ksock_msg       tx_msg;          /* socklnd message buffer */
 	int               tx_desc_size;    /* size of this descriptor */
 	union {
@@ -340,7 +340,7 @@ struct ksock_conn {
 	struct list_head   ksnc_rx_list;      /* where I enq waiting input or a
 					       * forwarding descriptor
 					       */
-	unsigned long      ksnc_rx_deadline;  /* when (in jiffies) receive times
+	time64_t	   ksnc_rx_deadline;  /* when (in secs) receive times
 					       * out
 					       */
 	__u8               ksnc_rx_started;   /* started receiving a message */
@@ -370,13 +370,13 @@ struct ksock_conn {
 	struct ksock_tx	  *ksnc_tx_carrier;   /* next TX that can carry a LNet
 					       * message or ZC-ACK
 					       */
-	unsigned long      ksnc_tx_deadline;  /* when (in jiffies) tx times out
+	time64_t	   ksnc_tx_deadline;  /* when (in secs) tx times out
 					       */
 	int                ksnc_tx_bufnob;    /* send buffer marker */
 	atomic_t           ksnc_tx_nob;       /* # bytes queued */
 	int		   ksnc_tx_ready;     /* write space */
 	int		   ksnc_tx_scheduled; /* being progressed */
-	unsigned long      ksnc_tx_last_post; /* time stamp of the last posted
+	time64_t	   ksnc_tx_last_post; /* time stamp of the last posted
 					       * TX
 					       */
 };
@@ -386,10 +386,10 @@ struct ksock_route {
 	struct list_head  ksnr_connd_list;     /* chain on ksnr_connd_routes */
 	struct ksock_peer *ksnr_peer;          /* owning peer */
 	atomic_t          ksnr_refcount;       /* # users */
-	unsigned long     ksnr_timeout;        /* when (in jiffies) reconnection
+	time64_t	  ksnr_timeout;        /* when (in secs) reconnection
 						* can happen next
 						*/
-	long              ksnr_retry_interval; /* how long between retries */
+	time64_t	  ksnr_retry_interval; /* how long between retries */
 	__u32             ksnr_myipaddr;       /* my IP */
 	__u32             ksnr_ipaddr;         /* IP address to connect to */
 	int               ksnr_port;           /* port to connect to */
@@ -411,7 +411,7 @@ struct ksock_route {
 
 struct ksock_peer {
 	struct list_head   ksnp_list;           /* stash on global peer list */
-	unsigned long      ksnp_last_alive;     /* when (in jiffies) I was last
+	time64_t	   ksnp_last_alive;     /* when (in seconds) I was last
 						 * alive
 						 */
 	struct lnet_process_id  ksnp_id;	/* who's on the other end(s) */
@@ -432,7 +432,7 @@ struct ksock_peer {
 	struct list_head   ksnp_zc_req_list;    /* zero copy requests wait for
 						 * ACK
 						 */
-	unsigned long      ksnp_send_keepalive; /* time to send keepalive */
+	time64_t	   ksnp_send_keepalive; /* time to send keepalive */
 	struct lnet_ni	   *ksnp_ni;		/* which network */
 	int                ksnp_n_passive_ips;  /* # of... */
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 01b31a6..3f69618 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -221,9 +221,9 @@ struct ksock_tx *
 			 * allocated send buffer bytes < computed; infer
 			 * something got ACKed
 			 */
-			conn->ksnc_tx_deadline =
-				jiffies + *ksocknal_tunables.ksnd_timeout * HZ;
-			conn->ksnc_peer->ksnp_last_alive = jiffies;
+			conn->ksnc_tx_deadline = ktime_get_seconds() +
+						 *ksocknal_tunables.ksnd_timeout;
+			conn->ksnc_peer->ksnp_last_alive = ktime_get_seconds();
 			conn->ksnc_tx_bufnob = bufnob;
 			mb();
 		}
@@ -268,9 +268,9 @@ struct ksock_tx *
 	/* received something... */
 	nob = rc;
 
-	conn->ksnc_peer->ksnp_last_alive = jiffies;
-	conn->ksnc_rx_deadline =
-		jiffies + *ksocknal_tunables.ksnd_timeout * HZ;
+	conn->ksnc_peer->ksnp_last_alive = ktime_get_seconds();
+	conn->ksnc_rx_deadline = ktime_get_seconds() +
+				 *ksocknal_tunables.ksnd_timeout;
 	mb();		       /* order with setting rx_started */
 	conn->ksnc_rx_started = 1;
 
@@ -405,8 +405,8 @@ struct ksock_tx *
 	spin_lock(&peer->ksnp_lock);
 
 	/* ZC_REQ is going to be pinned to the peer */
-	tx->tx_deadline =
-		jiffies + *ksocknal_tunables.ksnd_timeout * HZ;
+	tx->tx_deadline = ktime_get_seconds() +
+			  *ksocknal_tunables.ksnd_timeout;
 
 	LASSERT(!tx->tx_msg.ksm_zc_cookies[0]);
 
@@ -482,8 +482,8 @@ struct ksock_tx *
 		LASSERT(conn->ksnc_tx_scheduled);
 		list_add_tail(&conn->ksnc_tx_list,
 			      &ksocknal_data.ksnd_enomem_conns);
-		if (!time_after_eq(jiffies + SOCKNAL_ENOMEM_RETRY,
-				   ksocknal_data.ksnd_reaper_waketime))
+		if (ktime_get_seconds() + SOCKNAL_ENOMEM_RETRY <
+		    ksocknal_data.ksnd_reaper_waketime)
 			wake_up(&ksocknal_data.ksnd_reaper_waitq);
 
 		spin_unlock_bh(&ksocknal_data.ksnd_reaper_lock);
@@ -591,7 +591,7 @@ struct ksock_conn *
 		case SOCKNAL_MATCH_YES: /* typed connection */
 			if (!typed || tnob > nob ||
 			    (tnob == nob && *ksocknal_tunables.ksnd_round_robin &&
-			     time_after(typed->ksnc_tx_last_post, c->ksnc_tx_last_post))) {
+			     typed->ksnc_tx_last_post > c->ksnc_tx_last_post)) {
 				typed = c;
 				tnob  = nob;
 			}
@@ -600,7 +600,7 @@ struct ksock_conn *
 		case SOCKNAL_MATCH_MAY: /* fallback connection */
 			if (!fallback || fnob > nob ||
 			    (fnob == nob && *ksocknal_tunables.ksnd_round_robin &&
-			     time_after(fallback->ksnc_tx_last_post, c->ksnc_tx_last_post))) {
+			     fallback->ksnc_tx_last_post > c->ksnc_tx_last_post)) {
 				fallback = c;
 				fnob = nob;
 			}
@@ -612,7 +612,7 @@ struct ksock_conn *
 	conn = (typed) ? typed : fallback;
 
 	if (conn)
-		conn->ksnc_tx_last_post = jiffies;
+		conn->ksnc_tx_last_post = ktime_get_seconds();
 
 	return conn;
 }
@@ -677,10 +677,10 @@ struct ksock_conn *
 
 	if (list_empty(&conn->ksnc_tx_queue) && !bufnob) {
 		/* First packet starts the timeout */
-		conn->ksnc_tx_deadline =
-			jiffies + *ksocknal_tunables.ksnd_timeout * HZ;
+		conn->ksnc_tx_deadline = ktime_get_seconds() +
+					 *ksocknal_tunables.ksnd_timeout;
 		if (conn->ksnc_tx_bufnob > 0) /* something got ACKed */
-			conn->ksnc_peer->ksnp_last_alive = jiffies;
+			conn->ksnc_peer->ksnp_last_alive = ktime_get_seconds();
 		conn->ksnc_tx_bufnob = 0;
 		mb(); /* order with adding to tx_queue */
 	}
@@ -728,7 +728,7 @@ struct ksock_conn *
 struct ksock_route *
 ksocknal_find_connectable_route_locked(struct ksock_peer *peer)
 {
-	unsigned long now = jiffies;
+	time64_t now = ktime_get_seconds();
 	struct list_head *tmp;
 	struct ksock_route *route;
 
@@ -746,13 +746,13 @@ struct ksock_route *
 			continue;
 
 		if (!(!route->ksnr_retry_interval || /* first attempt */
-		      time_after_eq(now, route->ksnr_timeout))) {
+		      now >= route->ksnr_timeout)) {
 			CDEBUG(D_NET,
-			       "Too soon to retry route %pI4h (cnted %d, interval %ld, %ld secs later)\n",
+			       "Too soon to retry route %pI4h (cnted %d, interval %lld, %lld secs later)\n",
 			       &route->ksnr_ipaddr,
 			       route->ksnr_connected,
 			       route->ksnr_retry_interval,
-			       (route->ksnr_timeout - now) / HZ);
+			       route->ksnr_timeout - now);
 			continue;
 		}
 
@@ -858,8 +858,8 @@ struct ksock_route *
 	if (peer->ksnp_accepting > 0 ||
 	    ksocknal_find_connecting_route_locked(peer)) {
 		/* the message is going to be pinned to the peer */
-		tx->tx_deadline =
-			jiffies + *ksocknal_tunables.ksnd_timeout * HZ;
+		tx->tx_deadline = ktime_get_seconds() +
+				  *ksocknal_tunables.ksnd_timeout;
 
 		/* Queue the message until a connection is established */
 		list_add_tail(&tx->tx_list, &peer->ksnp_tx_queue);
@@ -1773,11 +1773,11 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	int type;
 	int wanted;
 	struct socket *sock;
-	unsigned long deadline;
+	time64_t deadline;
 	int retry_later = 0;
 	int rc = 0;
 
-	deadline = jiffies + *ksocknal_tunables.ksnd_timeout * HZ;
+	deadline = ktime_get_seconds() + *ksocknal_tunables.ksnd_timeout;
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
@@ -1824,7 +1824,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 		write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
-		if (time_after_eq(jiffies, deadline)) {
+		if (ktime_get_seconds() >= deadline) {
 			rc = -ETIMEDOUT;
 			lnet_connect_console_error(rc, peer->ksnp_id.nid,
 						   route->ksnr_ipaddr,
@@ -1875,8 +1875,9 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			 * so min_reconnectms should be good heuristic
 			 */
 			route->ksnr_retry_interval =
-				*ksocknal_tunables.ksnd_min_reconnectms * HZ / 1000;
-			route->ksnr_timeout = jiffies + route->ksnr_retry_interval;
+				*ksocknal_tunables.ksnd_min_reconnectms / 1000;
+			route->ksnr_timeout = ktime_get_seconds() +
+					      route->ksnr_retry_interval;
 		}
 
 		ksocknal_launch_connection_locked(route);
@@ -1894,14 +1895,14 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	/* This is a retry rather than a new connection */
 	route->ksnr_retry_interval *= 2;
 	route->ksnr_retry_interval =
-		max(route->ksnr_retry_interval,
-		    (long)*ksocknal_tunables.ksnd_min_reconnectms * HZ / 1000);
+		max_t(time64_t, route->ksnr_retry_interval,
+		      *ksocknal_tunables.ksnd_min_reconnectms / 1000);
 	route->ksnr_retry_interval =
-		min(route->ksnr_retry_interval,
-		    (long)*ksocknal_tunables.ksnd_max_reconnectms * HZ / 1000);
+		min_t(time64_t, route->ksnr_retry_interval,
+		      *ksocknal_tunables.ksnd_max_reconnectms / 1000);
 
 	LASSERT(route->ksnr_retry_interval);
-	route->ksnr_timeout = jiffies + route->ksnr_retry_interval;
+	route->ksnr_timeout = ktime_get_seconds() + route->ksnr_retry_interval;
 
 	if (!list_empty(&peer->ksnp_tx_queue) &&
 	    !peer->ksnp_accepting &&
@@ -2044,21 +2045,19 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 static struct ksock_route *
 ksocknal_connd_get_route_locked(signed long *timeout_p)
 {
+	time64_t now = ktime_get_seconds();
 	struct ksock_route *route;
-	unsigned long now;
-
-	now = jiffies;
 
 	/* connd_routes can contain both pending and ordinary routes */
 	list_for_each_entry(route, &ksocknal_data.ksnd_connd_routes,
 			    ksnr_connd_list) {
 		if (!route->ksnr_retry_interval ||
-		    time_after_eq(now, route->ksnr_timeout))
+		    now >= route->ksnr_timeout)
 			return route;
 
 		if (*timeout_p == MAX_SCHEDULE_TIMEOUT ||
-		    (int)*timeout_p > (int)(route->ksnr_timeout - now))
-			*timeout_p = (int)(route->ksnr_timeout - now);
+		    *timeout_p > (signed long)(route->ksnr_timeout - now) * HZ)
+			*timeout_p = (signed long)(route->ksnr_timeout - now) * HZ;
 	}
 
 	return NULL;
@@ -2225,8 +2224,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		}
 
 		if (conn->ksnc_rx_started &&
-		    time_after_eq(jiffies,
-				  conn->ksnc_rx_deadline)) {
+		    ktime_get_seconds() >= conn->ksnc_rx_deadline) {
 			/* Timed out incomplete incoming message */
 			ksocknal_conn_addref(conn);
 			CNETERR("Timeout receiving from %s (%pI4h:%d), state %d wanted %zd left %d\n",
@@ -2241,8 +2239,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 		if ((!list_empty(&conn->ksnc_tx_queue) ||
 		     conn->ksnc_sock->sk->sk_wmem_queued) &&
-		    time_after_eq(jiffies,
-				  conn->ksnc_tx_deadline)) {
+		    ktime_get_seconds() >= conn->ksnc_tx_deadline) {
 			/*
 			 * Timed out messages queued for sending or
 			 * buffered in the socket's send buffer
@@ -2269,8 +2266,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
 	list_for_each_entry_safe(tx, tmp, &peer->ksnp_tx_queue, tx_list) {
-		if (!time_after_eq(jiffies,
-				   tx->tx_deadline))
+		if (ktime_get_seconds() < tx->tx_deadline)
 			break;
 
 		list_del(&tx->tx_list);
@@ -2298,18 +2294,18 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		return 0;
 
 	if (*ksocknal_tunables.ksnd_keepalive <= 0 ||
-	    time_before(jiffies,
-			peer->ksnp_last_alive + *ksocknal_tunables.ksnd_keepalive * HZ))
+	    ktime_get_seconds() < peer->ksnp_last_alive +
+				  *ksocknal_tunables.ksnd_keepalive)
 		return 0;
 
-	if (time_before(jiffies, peer->ksnp_send_keepalive))
+	if (ktime_get_seconds() < peer->ksnp_send_keepalive)
 		return 0;
 
 	/*
 	 * retry 10 secs later, so we wouldn't put pressure
 	 * on this peer if we failed to send keepalive this time
 	 */
-	peer->ksnp_send_keepalive = jiffies + 10 * HZ;
+	peer->ksnp_send_keepalive = ktime_get_seconds() + 10;
 
 	conn = ksocknal_find_conn_locked(peer, NULL, 1);
 	if (conn) {
@@ -2362,8 +2358,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
 	list_for_each_entry(peer, peers, ksnp_list) {
-		unsigned long deadline = 0;
 		struct ksock_tx *tx_stale;
+		time64_t deadline = 0;
 		int resid = 0;
 		int n = 0;
 
@@ -2396,8 +2392,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			tx = list_entry(peer->ksnp_tx_queue.next,
 					struct ksock_tx, tx_list);
 
-			if (time_after_eq(jiffies,
-					  tx->tx_deadline)) {
+			if (ktime_get_seconds() >= tx->tx_deadline) {
 				ksocknal_peer_addref(peer);
 				read_unlock(&ksocknal_data.ksnd_global_lock);
 
@@ -2414,8 +2409,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		tx_stale = NULL;
 		spin_lock(&peer->ksnp_lock);
 		list_for_each_entry(tx, &peer->ksnp_zc_req_list, tx_zc_list) {
-			if (!time_after_eq(jiffies,
-					   tx->tx_deadline))
+			if (ktime_get_seconds() < tx->tx_deadline)
 				break;
 			/* ignore the TX if connection is being closed */
 			if (tx->tx_conn->ksnc_closing)
@@ -2438,9 +2432,9 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		spin_unlock(&peer->ksnp_lock);
 		read_unlock(&ksocknal_data.ksnd_global_lock);
 
-		CERROR("Total %d stale ZC_REQs for peer %s detected; the oldest(%p) timed out %ld secs ago, resid: %d, wmem: %d\n",
+		CERROR("Total %d stale ZC_REQs for peer %s detected; the oldest(%p) timed out %lld secs ago, resid: %d, wmem: %d\n",
 		       n, libcfs_nid2str(peer->ksnp_id.nid), tx_stale,
-		       (jiffies - deadline) / HZ,
+		       ktime_get_seconds() - deadline,
 		       resid, conn->ksnc_sock->sk->sk_wmem_queued);
 
 		ksocknal_close_conn_and_siblings(conn, -ETIMEDOUT);
@@ -2459,10 +2453,10 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	struct ksock_sched *sched;
 	struct list_head enomem_conns;
 	int nenomem_conns;
-	long timeout;
+	time64_t timeout;
 	int i;
 	int peer_index = 0;
-	unsigned long deadline = jiffies;
+	time64_t deadline = ktime_get_seconds();
 
 	INIT_LIST_HEAD(&enomem_conns);
 	init_waitqueue_entry(&wait, current);
@@ -2527,7 +2521,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		}
 
 		/* careful with the jiffy wrap... */
-		while ((timeout = deadline - jiffies) <= 0) {
+		while ((timeout = deadline - ktime_get_seconds()) <= 0) {
 			const int n = 4;
 			const int p = 1;
 			int chunk = ksocknal_data.ksnd_peer_hash_size;
@@ -2552,7 +2546,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 					     ksocknal_data.ksnd_peer_hash_size;
 			}
 
-			deadline = deadline + p * HZ;
+			deadline += p;
 		}
 
 		if (nenomem_conns) {
@@ -2563,7 +2557,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			 */
 			timeout = SOCKNAL_ENOMEM_RETRY;
 		}
-		ksocknal_data.ksnd_reaper_waketime = jiffies + timeout;
+		ksocknal_data.ksnd_reaper_waketime = ktime_get_seconds() +
+						     timeout;
 
 		set_current_state(TASK_INTERRUPTIBLE);
 		add_wait_queue(&ksocknal_data.ksnd_reaper_waitq, &wait);
@@ -2571,7 +2566,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		if (!ksocknal_data.ksnd_shuttingdown &&
 		    list_empty(&ksocknal_data.ksnd_deathrow_conns) &&
 		    list_empty(&ksocknal_data.ksnd_zombie_conns))
-			schedule_timeout(timeout);
+			schedule_timeout(timeout * HZ);
 
 		set_current_state(TASK_RUNNING);
 		remove_wait_queue(&ksocknal_data.ksnd_reaper_waitq, &wait);
-- 
1.8.3.1
