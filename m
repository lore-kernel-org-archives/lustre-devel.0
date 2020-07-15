From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:08 -0400
Subject: [lustre-devel] [PATCH 27/37] lnet: socklnd: convert various
 refcounts to refcount_t
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Each of these refcounts exactly follows the expectations of
refcount_t, so change the atomic_t to refcoun_t.

We can remove the LASSERTs on incref/decref as they can now be enabled
at build time with CONFIG_REFCOUNT_FULL

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: db3e51f612069 ("LU-12678 socklnd: convert various refcounts to refcount_t")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39130
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c    | 28 ++++++++++++-------------
 net/lnet/klnds/socklnd/socklnd.h    | 41 +++++++++++++++----------------------
 net/lnet/klnds/socklnd/socklnd_cb.c |  6 +++---
 3 files changed, 33 insertions(+), 42 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 2e11737..22a73c3 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -123,7 +123,7 @@ static int ksocknal_ip2index(__u32 ipaddress, struct lnet_ni *ni)
 	if (!route)
 		return NULL;
 
-	atomic_set(&route->ksnr_refcount, 1);
+	refcount_set(&route->ksnr_refcount, 1);
 	route->ksnr_peer = NULL;
 	route->ksnr_retry_interval = 0;		/* OK to connect at any time */
 	route->ksnr_ipaddr = ipaddr;
@@ -142,7 +142,7 @@ static int ksocknal_ip2index(__u32 ipaddress, struct lnet_ni *ni)
 void
 ksocknal_destroy_route(struct ksock_route *route)
 {
-	LASSERT(!atomic_read(&route->ksnr_refcount));
+	LASSERT(!refcount_read(&route->ksnr_refcount));
 
 	if (route->ksnr_peer)
 		ksocknal_peer_decref(route->ksnr_peer);
@@ -174,7 +174,7 @@ static int ksocknal_ip2index(__u32 ipaddress, struct lnet_ni *ni)
 
 	peer_ni->ksnp_ni = ni;
 	peer_ni->ksnp_id = id;
-	atomic_set(&peer_ni->ksnp_refcount, 1);   /* 1 ref for caller */
+	refcount_set(&peer_ni->ksnp_refcount, 1);   /* 1 ref for caller */
 	peer_ni->ksnp_closing = 0;
 	peer_ni->ksnp_accepting = 0;
 	peer_ni->ksnp_proto = NULL;
@@ -198,7 +198,7 @@ static int ksocknal_ip2index(__u32 ipaddress, struct lnet_ni *ni)
 	CDEBUG(D_NET, "peer_ni %s %p deleted\n",
 	       libcfs_id2str(peer_ni->ksnp_id), peer_ni);
 
-	LASSERT(!atomic_read(&peer_ni->ksnp_refcount));
+	LASSERT(!refcount_read(&peer_ni->ksnp_refcount));
 	LASSERT(!peer_ni->ksnp_accepting);
 	LASSERT(list_empty(&peer_ni->ksnp_conns));
 	LASSERT(list_empty(&peer_ni->ksnp_routes));
@@ -235,7 +235,7 @@ struct ksock_peer_ni *
 
 		CDEBUG(D_NET, "got peer_ni [%p] -> %s (%d)\n",
 		       peer_ni, libcfs_id2str(id),
-		       atomic_read(&peer_ni->ksnp_refcount));
+		       refcount_read(&peer_ni->ksnp_refcount));
 		return peer_ni;
 	}
 	return NULL;
@@ -1069,10 +1069,10 @@ struct ksock_peer_ni *
 	 * 2 ref, 1 for conn, another extra ref prevents socket
 	 * being closed before establishment of connection
 	 */
-	atomic_set(&conn->ksnc_sock_refcount, 2);
+	refcount_set(&conn->ksnc_sock_refcount, 2);
 	conn->ksnc_type = type;
 	ksocknal_lib_save_callback(sock, conn);
-	atomic_set(&conn->ksnc_conn_refcount, 1); /* 1 ref for me */
+	refcount_set(&conn->ksnc_conn_refcount, 1); /* 1 ref for me */
 
 	conn->ksnc_rx_ready = 0;
 	conn->ksnc_rx_scheduled = 0;
@@ -1667,7 +1667,7 @@ struct ksock_peer_ni *
 {
 	/* Queue the conn for the reaper to destroy */
 
-	LASSERT(!atomic_read(&conn->ksnc_conn_refcount));
+	LASSERT(!refcount_read(&conn->ksnc_conn_refcount));
 	spin_lock_bh(&ksocknal_data.ksnd_reaper_lock);
 
 	list_add_tail(&conn->ksnc_list, &ksocknal_data.ksnd_zombie_conns);
@@ -1684,8 +1684,8 @@ struct ksock_peer_ni *
 	/* Final coup-de-grace of the reaper */
 	CDEBUG(D_NET, "connection %p\n", conn);
 
-	LASSERT(!atomic_read(&conn->ksnc_conn_refcount));
-	LASSERT(!atomic_read(&conn->ksnc_sock_refcount));
+	LASSERT(!refcount_read(&conn->ksnc_conn_refcount));
+	LASSERT(!refcount_read(&conn->ksnc_sock_refcount));
 	LASSERT(!conn->ksnc_sock);
 	LASSERT(!conn->ksnc_route);
 	LASSERT(!conn->ksnc_tx_scheduled);
@@ -2412,7 +2412,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 		CWARN("Active peer_ni on shutdown: %s, ref %d, closing %d, accepting %d, err %d, zcookie %llu, txq %d, zc_req %d\n",
 		      libcfs_id2str(peer_ni->ksnp_id),
-		      atomic_read(&peer_ni->ksnp_refcount),
+		      refcount_read(&peer_ni->ksnp_refcount),
 		      peer_ni->ksnp_closing,
 		      peer_ni->ksnp_accepting, peer_ni->ksnp_error,
 		      peer_ni->ksnp_zc_next_cookie,
@@ -2421,7 +2421,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 		list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list) {
 			CWARN("Route: ref %d, schd %d, conn %d, cnted %d, del %d\n",
-			      atomic_read(&route->ksnr_refcount),
+			      refcount_read(&route->ksnr_refcount),
 			      route->ksnr_scheduled,
 			      route->ksnr_connecting,
 			      route->ksnr_connected,
@@ -2430,8 +2430,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 		list_for_each_entry(conn, &peer_ni->ksnp_conns, ksnc_list) {
 			CWARN("Conn: ref %d, sref %d, t %d, c %d\n",
-			      atomic_read(&conn->ksnc_conn_refcount),
-			      atomic_read(&conn->ksnc_sock_refcount),
+			      refcount_read(&conn->ksnc_conn_refcount),
+			      refcount_read(&conn->ksnc_sock_refcount),
 			      conn->ksnc_type, conn->ksnc_closing);
 		}
 		goto done;
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 0a0f0a7..df863f2 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -37,6 +37,7 @@
 #include <linux/list.h>
 #include <linux/mm.h>
 #include <linux/module.h>
+#include <linux/refcount.h>
 #include <linux/stat.h>
 #include <linux/string.h>
 #include <linux/syscalls.h>
@@ -270,7 +271,7 @@ struct ksock_tx {				/* transmit packet */
 	struct list_head	tx_list;	/* queue on conn for transmission etc
 						 */
 	struct list_head	tx_zc_list;	/* queue on peer_ni for ZC request */
-	atomic_t		tx_refcount;	/* tx reference count */
+	refcount_t		tx_refcount;	/* tx reference count */
 	int			tx_nob;		/* # packet bytes */
 	int			tx_resid;	/* residual bytes */
 	int			tx_niov;	/* # packet iovec frags */
@@ -311,8 +312,8 @@ struct ksock_conn {
 	void		       *ksnc_saved_write_space;	/* socket's original
 							 * write_space() callback
 							 */
-	atomic_t		ksnc_conn_refcount;	/* conn refcount */
-	atomic_t		ksnc_sock_refcount;	/* sock refcount */
+	refcount_t		ksnc_conn_refcount;	/* conn refcount */
+	refcount_t		ksnc_sock_refcount;	/* sock refcount */
 	struct ksock_sched     *ksnc_scheduler;		/* who schedules this connection
 							 */
 	u32			ksnc_myipaddr;		/* my IP */
@@ -374,7 +375,7 @@ struct ksock_route {
 	struct list_head	ksnr_list;		/* chain on peer_ni route list */
 	struct list_head	ksnr_connd_list;	/* chain on ksnr_connd_routes */
 	struct ksock_peer_ni   *ksnr_peer;		/* owning peer_ni */
-	atomic_t		ksnr_refcount;		/* # users */
+	refcount_t		ksnr_refcount;		/* # users */
 	time64_t		ksnr_timeout;		/* when (in secs) reconnection
 							 * can happen next
 							 */
@@ -404,7 +405,7 @@ struct ksock_peer_ni {
 							 * alive
 							 */
 	struct lnet_process_id	ksnp_id;		/* who's on the other end(s) */
-	atomic_t		ksnp_refcount;		/* # users */
+	refcount_t		ksnp_refcount;		/* # users */
 	int			ksnp_closing;		/* being closed */
 	int			ksnp_accepting;		/* # passive connections pending
 							 */
@@ -510,8 +511,7 @@ struct ksock_proto {
 static inline void
 ksocknal_conn_addref(struct ksock_conn *conn)
 {
-	LASSERT(atomic_read(&conn->ksnc_conn_refcount) > 0);
-	atomic_inc(&conn->ksnc_conn_refcount);
+	refcount_inc(&conn->ksnc_conn_refcount);
 }
 
 void ksocknal_queue_zombie_conn(struct ksock_conn *conn);
@@ -520,8 +520,7 @@ struct ksock_proto {
 static inline void
 ksocknal_conn_decref(struct ksock_conn *conn)
 {
-	LASSERT(atomic_read(&conn->ksnc_conn_refcount) > 0);
-	if (atomic_dec_and_test(&conn->ksnc_conn_refcount))
+	if (refcount_dec_and_test(&conn->ksnc_conn_refcount))
 		ksocknal_queue_zombie_conn(conn);
 }
 
@@ -532,8 +531,7 @@ struct ksock_proto {
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
 	if (!conn->ksnc_closing) {
-		LASSERT(atomic_read(&conn->ksnc_sock_refcount) > 0);
-		atomic_inc(&conn->ksnc_sock_refcount);
+		refcount_inc(&conn->ksnc_sock_refcount);
 		rc = 0;
 	}
 	read_unlock(&ksocknal_data.ksnd_global_lock);
@@ -544,8 +542,7 @@ struct ksock_proto {
 static inline void
 ksocknal_connsock_decref(struct ksock_conn *conn)
 {
-	LASSERT(atomic_read(&conn->ksnc_sock_refcount) > 0);
-	if (atomic_dec_and_test(&conn->ksnc_sock_refcount)) {
+	if (refcount_dec_and_test(&conn->ksnc_sock_refcount)) {
 		LASSERT(conn->ksnc_closing);
 		sock_release(conn->ksnc_sock);
 		conn->ksnc_sock = NULL;
@@ -556,8 +553,7 @@ struct ksock_proto {
 static inline void
 ksocknal_tx_addref(struct ksock_tx *tx)
 {
-	LASSERT(atomic_read(&tx->tx_refcount) > 0);
-	atomic_inc(&tx->tx_refcount);
+	refcount_inc(&tx->tx_refcount);
 }
 
 void ksocknal_tx_prep(struct ksock_conn *, struct ksock_tx *tx);
@@ -566,16 +562,14 @@ struct ksock_proto {
 static inline void
 ksocknal_tx_decref(struct ksock_tx *tx)
 {
-	LASSERT(atomic_read(&tx->tx_refcount) > 0);
-	if (atomic_dec_and_test(&tx->tx_refcount))
+	if (refcount_dec_and_test(&tx->tx_refcount))
 		ksocknal_tx_done(NULL, tx, 0);
 }
 
 static inline void
 ksocknal_route_addref(struct ksock_route *route)
 {
-	LASSERT(atomic_read(&route->ksnr_refcount) > 0);
-	atomic_inc(&route->ksnr_refcount);
+	refcount_inc(&route->ksnr_refcount);
 }
 
 void ksocknal_destroy_route(struct ksock_route *route);
@@ -583,16 +577,14 @@ struct ksock_proto {
 static inline void
 ksocknal_route_decref(struct ksock_route *route)
 {
-	LASSERT(atomic_read(&route->ksnr_refcount) > 0);
-	if (atomic_dec_and_test(&route->ksnr_refcount))
+	if (refcount_dec_and_test(&route->ksnr_refcount))
 		ksocknal_destroy_route(route);
 }
 
 static inline void
 ksocknal_peer_addref(struct ksock_peer_ni *peer_ni)
 {
-	LASSERT(atomic_read(&peer_ni->ksnp_refcount) > 0);
-	atomic_inc(&peer_ni->ksnp_refcount);
+	refcount_inc(&peer_ni->ksnp_refcount);
 }
 
 void ksocknal_destroy_peer(struct ksock_peer_ni *peer_ni);
@@ -600,8 +592,7 @@ struct ksock_proto {
 static inline void
 ksocknal_peer_decref(struct ksock_peer_ni *peer_ni)
 {
-	LASSERT(atomic_read(&peer_ni->ksnp_refcount) > 0);
-	if (atomic_dec_and_test(&peer_ni->ksnp_refcount))
+	if (refcount_dec_and_test(&peer_ni->ksnp_refcount))
 		ksocknal_destroy_peer(peer_ni);
 }
 
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 936054ee..9b3b604 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -52,7 +52,7 @@ struct ksock_tx *
 	if (!tx)
 		return NULL;
 
-	atomic_set(&tx->tx_refcount, 1);
+	refcount_set(&tx->tx_refcount, 1);
 	tx->tx_zc_aborted = 0;
 	tx->tx_zc_capable = 0;
 	tx->tx_zc_checked = 0;
@@ -381,7 +381,7 @@ struct ksock_tx *
 				tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
 		}
 
-		LASSERT(atomic_read(&tx->tx_refcount) == 1);
+		LASSERT(refcount_read(&tx->tx_refcount) == 1);
 		ksocknal_tx_done(ni, tx, error);
 	}
 }
@@ -1072,7 +1072,7 @@ struct ksock_route *
 	struct lnet_process_id *id;
 	int rc;
 
-	LASSERT(atomic_read(&conn->ksnc_conn_refcount) > 0);
+	LASSERT(refcount_read(&conn->ksnc_conn_refcount) > 0);
 
 	/* NB: sched lock NOT held */
 	/* SOCKNAL_RX_LNET_HEADER is here for backward compatibility */
-- 
1.8.3.1
