From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:01 -0500
Subject: [lustre-devel] [PATCH 553/622] lnet: socklnd: rename struct
 ksock_peer to struct ksock_peer_ni
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-554-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In the OpenSFS tree when typedefs were removed from the socklnd
driver all ksock peers were renamed to struct ksock_peer_ni.
This didn't happened for the linux client so lets bring both
trees in sync.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 93090d9b8250 ("LU-6142 socklnd: remove typedefs from ksocklnd")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/28275
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c       | 78 +++++++++++++++++-----------------
 net/lnet/klnds/socklnd/socklnd.h       | 38 ++++++++---------
 net/lnet/klnds/socklnd/socklnd_cb.c    | 24 +++++------
 net/lnet/klnds/socklnd/socklnd_proto.c |  4 +-
 4 files changed, 72 insertions(+), 72 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index e2a9819..79068f3 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -99,12 +99,12 @@
 }
 
 static int
-ksocknal_create_peer(struct ksock_peer **peerp, struct lnet_ni *ni,
+ksocknal_create_peer(struct ksock_peer_ni **peerp, struct lnet_ni *ni,
 		     struct lnet_process_id id)
 {
 	int cpt = lnet_cpt_of_nid(id.nid, ni);
 	struct ksock_net *net = ni->ni_data;
-	struct ksock_peer *peer_ni;
+	struct ksock_peer_ni *peer_ni;
 
 	LASSERT(id.nid != LNET_NID_ANY);
 	LASSERT(id.pid != LNET_PID_ANY);
@@ -148,7 +148,7 @@
 }
 
 void
-ksocknal_destroy_peer(struct ksock_peer *peer_ni)
+ksocknal_destroy_peer(struct ksock_peer_ni *peer_ni)
 {
 	struct ksock_net *net = peer_ni->ksnp_ni->ni_data;
 
@@ -175,11 +175,11 @@
 	spin_unlock_bh(&net->ksnn_lock);
 }
 
-struct ksock_peer *
+struct ksock_peer_ni *
 ksocknal_find_peer_locked(struct lnet_ni *ni, struct lnet_process_id id)
 {
 	struct list_head *peer_list = ksocknal_nid2peerlist(id.nid);
-	struct ksock_peer *peer_ni;
+	struct ksock_peer_ni *peer_ni;
 
 	list_for_each_entry(peer_ni, peer_list, ksnp_list) {
 		LASSERT(!peer_ni->ksnp_closing);
@@ -199,10 +199,10 @@ struct ksock_peer *
 	return NULL;
 }
 
-struct ksock_peer *
+struct ksock_peer_ni *
 ksocknal_find_peer(struct lnet_ni *ni, struct lnet_process_id id)
 {
-	struct ksock_peer *peer_ni;
+	struct ksock_peer_ni *peer_ni;
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
 	peer_ni = ksocknal_find_peer_locked(ni, id);
@@ -214,7 +214,7 @@ struct ksock_peer *
 }
 
 static void
-ksocknal_unlink_peer_locked(struct ksock_peer *peer_ni)
+ksocknal_unlink_peer_locked(struct ksock_peer_ni *peer_ni)
 {
 	int i;
 	u32 ip;
@@ -250,7 +250,7 @@ struct ksock_peer *
 		       struct lnet_process_id *id, u32 *myip, u32 *peer_ip,
 		       int *port, int *conn_count, int *share_count)
 {
-	struct ksock_peer *peer_ni;
+	struct ksock_peer_ni *peer_ni;
 	struct ksock_route *route;
 	int i;
 	int j;
@@ -318,7 +318,7 @@ struct ksock_peer *
 ksocknal_associate_route_conn_locked(struct ksock_route *route,
 				     struct ksock_conn *conn)
 {
-	struct ksock_peer *peer_ni = route->ksnr_peer;
+	struct ksock_peer_ni *peer_ni = route->ksnr_peer;
 	int type = conn->ksnc_type;
 	struct ksock_interface *iface;
 
@@ -362,7 +362,7 @@ struct ksock_peer *
 }
 
 static void
-ksocknal_add_route_locked(struct ksock_peer *peer_ni, struct ksock_route *route)
+ksocknal_add_route_locked(struct ksock_peer_ni *peer_ni, struct ksock_route *route)
 {
 	struct ksock_conn *conn;
 	struct ksock_route *route2;
@@ -400,7 +400,7 @@ struct ksock_peer *
 static void
 ksocknal_del_route_locked(struct ksock_route *route)
 {
-	struct ksock_peer *peer_ni = route->ksnr_peer;
+	struct ksock_peer_ni *peer_ni = route->ksnr_peer;
 	struct ksock_interface *iface;
 	struct ksock_conn *conn;
 	struct list_head *ctmp;
@@ -443,8 +443,8 @@ struct ksock_peer *
 ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, u32 ipaddr,
 		  int port)
 {
-	struct ksock_peer *peer_ni;
-	struct ksock_peer *peer2;
+	struct ksock_peer_ni *peer_ni;
+	struct ksock_peer_ni *peer2;
 	struct ksock_route *route;
 	struct ksock_route *route2;
 	int rc;
@@ -497,7 +497,7 @@ struct ksock_peer *
 }
 
 static void
-ksocknal_del_peer_locked(struct ksock_peer *peer_ni, u32 ip)
+ksocknal_del_peer_locked(struct ksock_peer_ni *peer_ni, u32 ip)
 {
 	struct ksock_conn *conn;
 	struct ksock_route *route;
@@ -556,8 +556,8 @@ struct ksock_peer *
 ksocknal_del_peer(struct lnet_ni *ni, struct lnet_process_id id, u32 ip)
 {
 	LIST_HEAD(zombies);
-	struct ksock_peer *pnxt;
-	struct ksock_peer *peer_ni;
+	struct ksock_peer_ni *pnxt;
+	struct ksock_peer_ni *peer_ni;
 	int lo;
 	int hi;
 	int i;
@@ -615,7 +615,7 @@ struct ksock_peer *
 static struct ksock_conn *
 ksocknal_get_conn_by_idx(struct lnet_ni *ni, int index)
 {
-	struct ksock_peer *peer_ni;
+	struct ksock_peer_ni *peer_ni;
 	struct ksock_conn *conn;
 	int i;
 
@@ -729,7 +729,7 @@ struct ksock_peer *
 }
 
 static int
-ksocknal_select_ips(struct ksock_peer *peer_ni, u32 *peerips, int n_peerips)
+ksocknal_select_ips(struct ksock_peer_ni *peer_ni, u32 *peerips, int n_peerips)
 {
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
 	struct ksock_net *net = peer_ni->ksnp_ni->ni_data;
@@ -844,7 +844,7 @@ struct ksock_peer *
 }
 
 static void
-ksocknal_create_routes(struct ksock_peer *peer_ni, int port,
+ksocknal_create_routes(struct ksock_peer_ni *peer_ni, int port,
 		       u32 *peer_ipaddrs, int npeer_ipaddrs)
 {
 	struct ksock_route *newroute = NULL;
@@ -984,7 +984,7 @@ struct ksock_peer *
 }
 
 static int
-ksocknal_connecting(struct ksock_peer *peer_ni, u32 ipaddr)
+ksocknal_connecting(struct ksock_peer_ni *peer_ni, u32 ipaddr)
 {
 	struct ksock_route *route;
 
@@ -1005,8 +1005,8 @@ struct ksock_peer *
 	u64 incarnation;
 	struct ksock_conn *conn;
 	struct ksock_conn *conn2;
-	struct ksock_peer *peer_ni = NULL;
-	struct ksock_peer *peer2;
+	struct ksock_peer_ni *peer_ni = NULL;
+	struct ksock_peer_ni *peer2;
 	struct ksock_sched *sched;
 	struct ksock_hello_msg *hello;
 	int cpt;
@@ -1422,7 +1422,7 @@ struct ksock_peer *
 	 * connection for the reaper to terminate.
 	 * Caller holds ksnd_global_lock exclusively in irq context
 	 */
-	struct ksock_peer *peer_ni = conn->ksnc_peer;
+	struct ksock_peer_ni *peer_ni = conn->ksnc_peer;
 	struct ksock_route *route;
 	struct ksock_conn *conn2;
 
@@ -1495,7 +1495,7 @@ struct ksock_peer *
 }
 
 void
-ksocknal_peer_failed(struct ksock_peer *peer_ni)
+ksocknal_peer_failed(struct ksock_peer_ni *peer_ni)
 {
 	int notify = 0;
 	time64_t last_alive = 0;
@@ -1525,7 +1525,7 @@ struct ksock_peer *
 void
 ksocknal_finalize_zcreq(struct ksock_conn *conn)
 {
-	struct ksock_peer *peer_ni = conn->ksnc_peer;
+	struct ksock_peer_ni *peer_ni = conn->ksnc_peer;
 	struct ksock_tx *tx;
 	struct ksock_tx *tmp;
 	LIST_HEAD(zlist);
@@ -1569,7 +1569,7 @@ struct ksock_peer *
 	 * ksnc_refcount will eventually hit zero, and then the reaper will
 	 * destroy it.
 	 */
-	struct ksock_peer *peer_ni = conn->ksnc_peer;
+	struct ksock_peer_ni *peer_ni = conn->ksnc_peer;
 	struct ksock_sched *sched = conn->ksnc_scheduler;
 	int failed = 0;
 
@@ -1703,7 +1703,7 @@ struct ksock_peer *
 }
 
 int
-ksocknal_close_peer_conns_locked(struct ksock_peer *peer_ni,
+ksocknal_close_peer_conns_locked(struct ksock_peer_ni *peer_ni,
 				 u32 ipaddr, int why)
 {
 	struct ksock_conn *conn;
@@ -1726,7 +1726,7 @@ struct ksock_peer *
 int
 ksocknal_close_conn_and_siblings(struct ksock_conn *conn, int why)
 {
-	struct ksock_peer *peer_ni = conn->ksnc_peer;
+	struct ksock_peer_ni *peer_ni = conn->ksnc_peer;
 	u32 ipaddr = conn->ksnc_ipaddr;
 	int count;
 
@@ -1742,8 +1742,8 @@ struct ksock_peer *
 int
 ksocknal_close_matching_conns(struct lnet_process_id id, u32 ipaddr)
 {
-	struct ksock_peer *peer_ni;
-	struct ksock_peer *pnxt;
+	struct ksock_peer_ni *peer_ni;
+	struct ksock_peer_ni *pnxt;
 	int lo;
 	int hi;
 	int i;
@@ -1816,7 +1816,7 @@ struct ksock_peer *
 	int connect = 1;
 	time64_t last_alive = 0;
 	time64_t now = ktime_get_seconds();
-	struct ksock_peer *peer_ni = NULL;
+	struct ksock_peer_ni *peer_ni = NULL;
 	rwlock_t *glock = &ksocknal_data.ksnd_global_lock;
 	struct lnet_process_id id = {
 		.nid = nid,
@@ -1872,7 +1872,7 @@ struct ksock_peer *
 }
 
 static void
-ksocknal_push_peer(struct ksock_peer *peer_ni)
+ksocknal_push_peer(struct ksock_peer_ni *peer_ni)
 {
 	int index;
 	int i;
@@ -1921,7 +1921,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		int peer_off; /* searching offset in peer_ni hash table */
 
 		for (peer_off = 0; ; peer_off++) {
-			struct ksock_peer *peer_ni;
+			struct ksock_peer_ni *peer_ni;
 			int i = 0;
 
 			read_lock(&ksocknal_data.ksnd_global_lock);
@@ -1958,7 +1958,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	int rc;
 	int i;
 	int j;
-	struct ksock_peer *peer_ni;
+	struct ksock_peer_ni *peer_ni;
 	struct ksock_route *route;
 
 	if (!ipaddress || !netmask)
@@ -2014,7 +2014,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 }
 
 static void
-ksocknal_peer_del_interface_locked(struct ksock_peer *peer_ni, u32 ipaddr)
+ksocknal_peer_del_interface_locked(struct ksock_peer_ni *peer_ni, u32 ipaddr)
 {
 	struct list_head *tmp;
 	struct list_head *nxt;
@@ -2059,8 +2059,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 {
 	struct ksock_net *net = ni->ni_data;
 	int rc = -ENOENT;
-	struct ksock_peer *nxt;
-	struct ksock_peer *peer_ni;
+	struct ksock_peer_ni *nxt;
+	struct ksock_peer_ni *peer_ni;
 	u32 this_ip;
 	int i;
 	int j;
@@ -2457,7 +2457,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 static void
 ksocknal_debug_peerhash(struct lnet_ni *ni)
 {
-	struct ksock_peer *peer_ni = NULL;
+	struct ksock_peer_ni *peer_ni = NULL;
 	int i;
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index efdd02e..1e10663 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -262,7 +262,7 @@ struct ksock_nal_data {
  * what the header matched or whether the message needs forwarding.
  */
 struct ksock_conn;  /* forward ref */
-struct ksock_peer;  /* forward ref */
+struct ksock_peer_ni;  /* forward ref */
 struct ksock_route; /* forward ref */
 struct ksock_proto; /* forward ref */
 
@@ -311,7 +311,7 @@ struct ksock_tx {				/* transmit packet */
 #define SOCKNAL_RX_SLOP		6 /* skipping body */
 
 struct ksock_conn {
-	struct ksock_peer      *ksnc_peer;		/* owning peer_ni */
+	struct ksock_peer_ni   *ksnc_peer;		/* owning peer_ni */
 	struct ksock_route     *ksnc_route;		/* owning route */
 	struct list_head	ksnc_list;		/* stash on peer_ni's conn list */
 	struct socket	       *ksnc_sock;		/* actual socket */
@@ -383,7 +383,7 @@ struct ksock_conn {
 struct ksock_route {
 	struct list_head	ksnr_list;		/* chain on peer_ni route list */
 	struct list_head	ksnr_connd_list;	/* chain on ksnr_connd_routes */
-	struct ksock_peer      *ksnr_peer;		/* owning peer_ni */
+	struct ksock_peer_ni   *ksnr_peer;		/* owning peer_ni */
 	atomic_t		ksnr_refcount;		/* # users */
 	time64_t		ksnr_timeout;		/* when (in secs) reconnection
 							 * can happen next
@@ -408,7 +408,7 @@ struct ksock_route {
 
 #define SOCKNAL_KEEPALIVE_PING	1	/* cookie for keepalive ping */
 
-struct ksock_peer {
+struct ksock_peer_ni {
 	struct list_head	ksnp_list;		/* stash on global peer_ni list */
 	time64_t		ksnp_last_alive;	/* when (in seconds) I was last
 							 * alive
@@ -607,16 +607,16 @@ struct ksock_proto {
 }
 
 static inline void
-ksocknal_peer_addref(struct ksock_peer *peer_ni)
+ksocknal_peer_addref(struct ksock_peer_ni *peer_ni)
 {
 	LASSERT(atomic_read(&peer_ni->ksnp_refcount) > 0);
 	atomic_inc(&peer_ni->ksnp_refcount);
 }
 
-void ksocknal_destroy_peer(struct ksock_peer *peer_ni);
+void ksocknal_destroy_peer(struct ksock_peer_ni *peer_ni);
 
 static inline void
-ksocknal_peer_decref(struct ksock_peer *peer_ni)
+ksocknal_peer_decref(struct ksock_peer_ni *peer_ni)
 {
 	LASSERT(atomic_read(&peer_ni->ksnp_refcount) > 0);
 	if (atomic_dec_and_test(&peer_ni->ksnp_refcount))
@@ -633,21 +633,21 @@ int ksocknal_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
 
 int ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, u32 ip,
 		      int port);
-struct ksock_peer *ksocknal_find_peer_locked(struct lnet_ni *ni,
-					     struct lnet_process_id id);
-struct ksock_peer *ksocknal_find_peer(struct lnet_ni *ni,
-				      struct lnet_process_id id);
-void ksocknal_peer_failed(struct ksock_peer *peer_ni);
+struct ksock_peer_ni *ksocknal_find_peer_locked(struct lnet_ni *ni,
+					        struct lnet_process_id id);
+struct ksock_peer_ni *ksocknal_find_peer(struct lnet_ni *ni,
+				         struct lnet_process_id id);
+void ksocknal_peer_failed(struct ksock_peer_ni *peer_ni);
 int ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 			 struct socket *sock, int type);
 void ksocknal_close_conn_locked(struct ksock_conn *conn, int why);
 void ksocknal_terminate_conn(struct ksock_conn *conn);
 void ksocknal_destroy_conn(struct ksock_conn *conn);
-int ksocknal_close_peer_conns_locked(struct ksock_peer *peer_ni,
+int ksocknal_close_peer_conns_locked(struct ksock_peer_ni *peer_ni,
 				     u32 ipaddr, int why);
 int ksocknal_close_conn_and_siblings(struct ksock_conn *conn, int why);
 int ksocknal_close_matching_conns(struct lnet_process_id id, u32 ipaddr);
-struct ksock_conn *ksocknal_find_conn_locked(struct ksock_peer *peer_ni,
+struct ksock_conn *ksocknal_find_conn_locked(struct ksock_peer_ni *peer_ni,
 					     struct ksock_tx *tx, int nonblk);
 
 int ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
@@ -662,11 +662,11 @@ int ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 void ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when);
 int ksocknal_thread_start(int (*fn)(void *arg), void *arg, char *name);
 void ksocknal_thread_fini(void);
-void ksocknal_launch_all_connections_locked(struct ksock_peer *peer_ni);
-struct ksock_route *ksocknal_find_connectable_route_locked(
-	struct ksock_peer *peer_ni);
-struct ksock_route *ksocknal_find_connecting_route_locked(
-	struct ksock_peer *peer_ni);
+void ksocknal_launch_all_connections_locked(struct ksock_peer_ni *peer_ni);
+struct ksock_route *
+ksocknal_find_connectable_route_locked(struct ksock_peer_ni *peer_ni);
+struct ksock_route *
+ksocknal_find_connecting_route_locked(struct ksock_peer_ni *peer_ni);
 int ksocknal_new_packet(struct ksock_conn *conn, int skip);
 int ksocknal_scheduler(void *arg);
 int ksocknal_connd(void *arg);
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 0132727..2b93331 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -394,7 +394,7 @@ struct ksock_tx *
 ksocknal_check_zc_req(struct ksock_tx *tx)
 {
 	struct ksock_conn *conn = tx->tx_conn;
-	struct ksock_peer *peer_ni = conn->ksnc_peer;
+	struct ksock_peer_ni *peer_ni = conn->ksnc_peer;
 
 	/*
 	 * Set tx_msg.ksm_zc_cookies[0] to a unique non-zero cookie and add tx
@@ -440,7 +440,7 @@ struct ksock_tx *
 static void
 ksocknal_uncheck_zc_req(struct ksock_tx *tx)
 {
-	struct ksock_peer *peer_ni = tx->tx_conn->ksnc_peer;
+	struct ksock_peer_ni *peer_ni = tx->tx_conn->ksnc_peer;
 
 	LASSERT(tx->tx_msg.ksm_type != KSOCK_MSG_NOOP);
 	LASSERT(tx->tx_zc_capable);
@@ -581,7 +581,7 @@ struct ksock_tx *
 }
 
 void
-ksocknal_launch_all_connections_locked(struct ksock_peer *peer_ni)
+ksocknal_launch_all_connections_locked(struct ksock_peer_ni *peer_ni)
 {
 	struct ksock_route *route;
 
@@ -597,7 +597,7 @@ struct ksock_tx *
 }
 
 struct ksock_conn *
-ksocknal_find_conn_locked(struct ksock_peer *peer_ni, struct ksock_tx *tx,
+ksocknal_find_conn_locked(struct ksock_peer_ni *peer_ni, struct ksock_tx *tx,
 			  int nonblk)
 {
 	struct ksock_conn *c;
@@ -763,7 +763,7 @@ struct ksock_conn *
 }
 
 struct ksock_route *
-ksocknal_find_connectable_route_locked(struct ksock_peer *peer_ni)
+ksocknal_find_connectable_route_locked(struct ksock_peer_ni *peer_ni)
 {
 	time64_t now = ktime_get_seconds();
 	struct ksock_route *route;
@@ -797,7 +797,7 @@ struct ksock_route *
 }
 
 struct ksock_route *
-ksocknal_find_connecting_route_locked(struct ksock_peer *peer_ni)
+ksocknal_find_connecting_route_locked(struct ksock_peer_ni *peer_ni)
 {
 	struct ksock_route *route;
 
@@ -815,7 +815,7 @@ struct ksock_route *
 ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 		       struct lnet_process_id id)
 {
-	struct ksock_peer *peer_ni;
+	struct ksock_peer_ni *peer_ni;
 	struct ksock_conn *conn;
 	rwlock_t *g_lock;
 	int retry;
@@ -1806,7 +1806,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 ksocknal_connect(struct ksock_route *route)
 {
 	LIST_HEAD(zombies);
-	struct ksock_peer *peer_ni = route->ksnr_peer;
+	struct ksock_peer_ni *peer_ni = route->ksnr_peer;
 	int type;
 	int wanted;
 	struct socket *sock;
@@ -2213,7 +2213,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 }
 
 static struct ksock_conn *
-ksocknal_find_timed_out_conn(struct ksock_peer *peer_ni)
+ksocknal_find_timed_out_conn(struct ksock_peer_ni *peer_ni)
 {
 	/* We're called with a shared lock on ksnd_global_lock */
 	struct ksock_conn *conn;
@@ -2296,7 +2296,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 }
 
 static inline void
-ksocknal_flush_stale_txs(struct ksock_peer *peer_ni)
+ksocknal_flush_stale_txs(struct ksock_peer_ni *peer_ni)
 {
 	struct ksock_tx *tx;
 	LIST_HEAD(stale_txs);
@@ -2322,7 +2322,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 }
 
 static int
-ksocknal_send_keepalive_locked(struct ksock_peer *peer_ni)
+ksocknal_send_keepalive_locked(struct ksock_peer_ni *peer_ni)
 	__must_hold(&ksocknal_data.ksnd_global_lock)
 {
 	struct ksock_sched *sched;
@@ -2388,7 +2388,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 ksocknal_check_peer_timeouts(int idx)
 {
 	struct list_head *peers = &ksocknal_data.ksnd_peers[idx];
-	struct ksock_peer *peer_ni;
+	struct ksock_peer_ni *peer_ni;
 	struct ksock_conn *conn;
 	struct ksock_tx *tx;
 
diff --git a/net/lnet/klnds/socklnd/socklnd_proto.c b/net/lnet/klnds/socklnd/socklnd_proto.c
index 64c0c74..c6ea302 100644
--- a/net/lnet/klnds/socklnd/socklnd_proto.c
+++ b/net/lnet/klnds/socklnd/socklnd_proto.c
@@ -367,7 +367,7 @@
 static int
 ksocknal_handle_zcreq(struct ksock_conn *c, u64 cookie, int remote)
 {
-	struct ksock_peer *peer_ni = c->ksnc_peer;
+	struct ksock_peer_ni *peer_ni = c->ksnc_peer;
 	struct ksock_conn *conn;
 	struct ksock_tx *tx;
 	int rc;
@@ -411,7 +411,7 @@
 static int
 ksocknal_handle_zcack(struct ksock_conn *conn, u64 cookie1, u64 cookie2)
 {
-	struct ksock_peer *peer_ni = conn->ksnc_peer;
+	struct ksock_peer_ni *peer_ni = conn->ksnc_peer;
 	struct ksock_tx *tx;
 	struct ksock_tx *tmp;
 	LIST_HEAD(zlist);
-- 
1.8.3.1
