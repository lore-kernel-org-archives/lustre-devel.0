From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:57 -0500
Subject: [lustre-devel] [PATCH 19/19] staging: lustre: lnet: cleanup some of
	the > 80 line issues
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Cleanup some of the checkpatch over 80 character lines
reported.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   31 ++++++++++-----
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   40 +++++++++++++-------
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |    6 ++-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   26 ++++++++++---
 drivers/staging/lustre/lnet/selftest/conrpc.c      |   10 +++--
 drivers/staging/lustre/lnet/selftest/conrpc.h      |    3 +-
 drivers/staging/lustre/lnet/selftest/console.c     |   17 +++++---
 drivers/staging/lustre/lnet/selftest/framework.c   |   15 +++++--
 drivers/staging/lustre/lnet/selftest/rpc.c         |    3 +-
 9 files changed, 101 insertions(+), 50 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index cbc9a9c..b74cf63 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -96,7 +96,8 @@
 }
 
 static int
-ksocknal_create_peer(struct ksock_peer **peerp, lnet_ni_t *ni, lnet_process_id_t id)
+ksocknal_create_peer(struct ksock_peer **peerp, lnet_ni_t *ni,
+		     lnet_process_id_t id)
 {
 	int cpt = lnet_cpt_of_nid(id.nid);
 	struct ksock_net *net = ni->ni_data;
@@ -319,7 +320,8 @@ struct ksock_peer *
 }
 
 static void
-ksocknal_associate_route_conn_locked(struct ksock_route *route, struct ksock_conn *conn)
+ksocknal_associate_route_conn_locked(struct ksock_route *route,
+				     struct ksock_conn *conn)
 {
 	struct ksock_peer *peer = route->ksnr_peer;
 	int type = conn->ksnc_type;
@@ -821,7 +823,8 @@ struct ksock_peer *
 				if (k < peer->ksnp_n_passive_ips) /* using it already */
 					continue;
 
-				k = ksocknal_match_peerip(iface, peerips, n_peerips);
+				k = ksocknal_match_peerip(iface, peerips,
+							  n_peerips);
 				xor = ip ^ peerips[k];
 				this_netmatch = !(xor & iface->ksni_netmask) ? 1 : 0;
 
@@ -1302,8 +1305,11 @@ struct ksock_peer *
 
 	/* Take packets blocking for this connection. */
 	list_for_each_entry_safe(tx, txtmp, &peer->ksnp_tx_queue, tx_list) {
-		if (conn->ksnc_proto->pro_match_tx(conn, tx, tx->tx_nonblk) == SOCKNAL_MATCH_NO)
-				continue;
+		int match = conn->ksnc_proto->pro_match_tx(conn, tx,
+							   tx->tx_nonblk);
+
+		if (match == SOCKNAL_MATCH_NO)
+			continue;
 
 		list_del(&tx->tx_list);
 		ksocknal_queue_tx_locked(tx, conn);
@@ -1493,8 +1499,8 @@ struct ksock_peer *
 			spin_unlock_bh(&conn->ksnc_scheduler->kss_lock);
 		}
 
-		peer->ksnp_proto = NULL;	/* renegotiate protocol version */
-		peer->ksnp_error = error;       /* stash last conn close reason */
+		peer->ksnp_proto = NULL;  /* renegotiate protocol version */
+		peer->ksnp_error = error; /* stash last conn close reason */
 
 		if (list_empty(&peer->ksnp_routes)) {
 			/*
@@ -1786,7 +1792,8 @@ struct ksock_peer *
 			      (id.pid == LNET_PID_ANY || id.pid == peer->ksnp_id.pid)))
 				continue;
 
-			count += ksocknal_close_peer_conns_locked(peer, ipaddr, 0);
+			count += ksocknal_close_peer_conns_locked(peer, ipaddr,
+								  0);
 		}
 	}
 
@@ -2026,7 +2033,10 @@ static int ksocknal_push(lnet_ni_t *ni, lnet_process_id_t id)
 		}
 
 		rc = 0;
-		/* NB only new connections will pay attention to the new interface! */
+		/*
+		 * NB only new connections will pay attention to the
+		 * new interface!
+		 */
 	}
 
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
@@ -2200,8 +2210,9 @@ static int ksocknal_push(lnet_ni_t *ni, lnet_process_id_t id)
 		int txmem;
 		int rxmem;
 		int nagle;
-		struct ksock_conn *conn = ksocknal_get_conn_by_idx(ni, data->ioc_count);
+		struct ksock_conn *conn;
 
+		conn = ksocknal_get_conn_by_idx(ni, data->ioc_count);
 		if (!conn)
 			return -ENOENT;
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index f31f4a1..972f609 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -620,7 +620,8 @@ struct ksock_tx *
 }
 
 struct ksock_conn *
-ksocknal_find_conn_locked(struct ksock_peer *peer, struct ksock_tx *tx, int nonblk)
+ksocknal_find_conn_locked(struct ksock_peer *peer, struct ksock_tx *tx,
+			  int nonblk)
 {
 	struct list_head *tmp;
 	struct ksock_conn *conn;
@@ -630,10 +631,12 @@ struct ksock_conn *
 	int fnob = 0;
 
 	list_for_each(tmp, &peer->ksnp_conns) {
-		struct ksock_conn *c  = list_entry(tmp, struct ksock_conn, ksnc_list);
-		int nob = atomic_read(&c->ksnc_tx_nob) +
-			c->ksnc_sock->sk->sk_wmem_queued;
-		int rc;
+		struct ksock_conn *c;
+		int nob, rc;
+
+		c = list_entry(tmp, struct ksock_conn, ksnc_list);
+		nob = atomic_read(&c->ksnc_tx_nob) +
+		      c->ksnc_sock->sk->sk_wmem_queued;
 
 		LASSERT(!c->ksnc_closing);
 		LASSERT(c->ksnc_proto &&
@@ -752,9 +755,9 @@ struct ksock_conn *
 		LASSERT(msg->ksm_zc_cookies[1]);
 		LASSERT(conn->ksnc_proto->pro_queue_tx_zcack);
 
+		/* ZC ACK piggybacked on ztx release tx later */
 		if (conn->ksnc_proto->pro_queue_tx_zcack(conn, tx, 0))
-			ztx = tx; /* ZC ACK piggybacked on ztx release tx later */
-
+			ztx = tx;
 	} else {
 		/*
 		 * It's a normal packet - can it piggback a noop zc-ack that
@@ -796,7 +799,8 @@ struct ksock_route *
 
 		LASSERT(!route->ksnr_connecting || route->ksnr_scheduled);
 
-		if (route->ksnr_scheduled)      /* connections being established */
+		/* connections being established */
+		if (route->ksnr_scheduled)
 			continue;
 
 		/* all route types connected ? */
@@ -1514,7 +1518,10 @@ int ksocknal_scheduler(void *arg)
 			rc = ksocknal_process_transmit(conn, tx);
 
 			if (rc == -ENOMEM || rc == -EAGAIN) {
-				/* Incomplete send: replace tx on HEAD of tx_queue */
+				/*
+				 * Incomplete send: replace tx on HEAD of
+				 * tx_queue
+				 */
 				spin_lock_bh(&sched->kss_lock);
 				list_add(&tx->tx_list, &conn->ksnc_tx_queue);
 			} else {
@@ -1724,7 +1731,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	timeout = active ? *ksocknal_tunables.ksnd_timeout :
 			    lnet_acceptor_timeout();
 
-	rc = lnet_sock_read(sock, &hello->kshm_magic, sizeof(hello->kshm_magic), timeout);
+	rc = lnet_sock_read(sock, &hello->kshm_magic,
+			    sizeof(hello->kshm_magic), timeout);
 	if (rc) {
 		CERROR("Error %d reading HELLO from %pI4h\n",
 		       rc, &conn->ksnc_ipaddr);
@@ -1798,7 +1806,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	    conn->ksnc_port > LNET_ACCEPTOR_MAX_RESERVED_PORT) {
 		/* Userspace NAL assigns peer process ID from socket */
 		recv_id.pid = conn->ksnc_port | LNET_PID_USERFLAG;
-		recv_id.nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid), conn->ksnc_ipaddr);
+		recv_id.nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid),
+					 conn->ksnc_ipaddr);
 	} else {
 		recv_id.nid = hello->kshm_src_nid;
 		recv_id.pid = hello->kshm_src_pid;
@@ -1882,7 +1891,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		if (peer->ksnp_accepting > 0) {
 			CDEBUG(D_NET,
 			       "peer %s(%d) already connecting to me, retry later.\n",
-			       libcfs_nid2str(peer->ksnp_id.nid), peer->ksnp_accepting);
+			       libcfs_nid2str(peer->ksnp_id.nid),
+			       peer->ksnp_accepting);
 			retry_later = 1;
 		}
 
@@ -2241,7 +2251,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 		/* Nothing to do for 'timeout'  */
 		set_current_state(TASK_INTERRUPTIBLE);
-		add_wait_queue_exclusive(&ksocknal_data.ksnd_connd_waitq, &wait);
+		add_wait_queue_exclusive(&ksocknal_data.ksnd_connd_waitq,
+					 &wait);
 		spin_unlock_bh(connd_lock);
 
 		nloops = 0;
@@ -2371,7 +2382,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	struct ksock_conn *conn;
 	struct ksock_tx *tx;
 
-	if (list_empty(&peer->ksnp_conns)) /* last_alive will be updated by create_conn */
+	/* last_alive will be updated by create_conn */
+	if (list_empty(&peer->ksnp_conns))
 		return 0;
 
 	if (peer->ksnp_proto != &ksocknal_protocol_v3x)
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 6c95e98..4bcab4b 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -202,7 +202,8 @@
 				fragnob = sum;
 
 			conn->ksnc_rx_csum = ksocknal_csum(conn->ksnc_rx_csum,
-							   iov[i].iov_base, fragnob);
+							   iov[i].iov_base,
+							   fragnob);
 		}
 		conn->ksnc_msg.ksm_csum = saved_csum;
 	}
@@ -291,7 +292,8 @@
 }
 
 int
-ksocknal_lib_get_conn_tunables(struct ksock_conn *conn, int *txmem, int *rxmem, int *nagle)
+ksocknal_lib_get_conn_tunables(struct ksock_conn *conn, int *txmem,
+			       int *rxmem, int *nagle)
 {
 	struct socket *sock = conn->ksnc_sock;
 	int len;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index 82e174f..8f0ff6c 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -194,7 +194,10 @@
 	}
 
 	if (!tx->tx_msg.ksm_zc_cookies[0]) {
-		/* NOOP tx has only one ZC-ACK cookie, can carry at least one more */
+		/*
+		 * NOOP tx has only one ZC-ACK cookie,
+		 * can carry at least one more
+		 */
 		if (tx->tx_msg.ksm_zc_cookies[1] > cookie) {
 			tx->tx_msg.ksm_zc_cookies[0] = tx->tx_msg.ksm_zc_cookies[1];
 			tx->tx_msg.ksm_zc_cookies[1] = cookie;
@@ -203,7 +206,10 @@
 		}
 
 		if (tx->tx_msg.ksm_zc_cookies[0] - tx->tx_msg.ksm_zc_cookies[1] > 2) {
-			/* not likely to carry more ACKs, skip it to simplify logic */
+			/*
+			 * not likely to carry more ACKs, skip it
+			 * to simplify logic
+			 */
 			ksocknal_next_tx_carrier(conn);
 		}
 
@@ -237,7 +243,10 @@
 		}
 
 	} else {
-		/* ksm_zc_cookies[0] < ksm_zc_cookies[1], it is range of cookies */
+		/*
+		 * ksm_zc_cookies[0] < ksm_zc_cookies[1],
+		 * it is range of cookies
+		 */
 		if (cookie >= tx->tx_msg.ksm_zc_cookies[0] &&
 		    cookie <= tx->tx_msg.ksm_zc_cookies[1]) {
 			CWARN("%s: duplicated ZC cookie: %llu\n",
@@ -425,7 +434,8 @@
 				 tx_zc_list) {
 		__u64 c = tx->tx_msg.ksm_zc_cookies[0];
 
-		if (c == cookie1 || c == cookie2 || (cookie1 < c && c < cookie2)) {
+		if (c == cookie1 || c == cookie2 ||
+		    (cookie1 < c && c < cookie2)) {
 			tx->tx_msg.ksm_zc_cookies[0] = 0;
 			list_del(&tx->tx_zc_list);
 			list_add(&tx->tx_zc_list, &zlist);
@@ -639,7 +649,8 @@
 }
 
 static int
-ksocknal_recv_hello_v2(struct ksock_conn *conn, ksock_hello_msg_t *hello, int timeout)
+ksocknal_recv_hello_v2(struct ksock_conn *conn, ksock_hello_msg_t *hello,
+		       int timeout)
 {
 	struct socket *sock = conn->ksnc_sock;
 	int rc;
@@ -737,7 +748,10 @@
 		tx->tx_nob = offsetof(ksock_msg_t,  ksm_u.lnetmsg.ksnm_hdr);
 		tx->tx_resid = offsetof(ksock_msg_t,  ksm_u.lnetmsg.ksnm_hdr);
 	}
-	/* Don't checksum before start sending, because packet can be piggybacked with ACK */
+	/*
+	 * Don't checksum before start sending, because packet can be
+	 * piggybacked with ACK
+	 */
 }
 
 static void
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 3d071b4..994422c 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -87,7 +87,8 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 
 static int
 lstcon_rpc_init(struct lstcon_node *nd, int service, unsigned int feats,
-		int bulk_npg, int bulk_len, int embedded, struct lstcon_rpc *crpc)
+		int bulk_npg, int bulk_len, int embedded,
+		struct lstcon_rpc *crpc)
 {
 	crpc->crp_rpc = sfw_create_rpc(nd->nd_id, service,
 				       feats, bulk_npg, bulk_len,
@@ -292,8 +293,8 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 
 		spin_lock(&rpc->crpc_lock);
 
-		if (!crpc->crp_posted ||	/* not posted */
-		    crpc->crp_stamp) {		/* rpc done or aborted already */
+		if (!crpc->crp_posted || /* not posted */
+		    crpc->crp_stamp) {	 /* rpc done or aborted already */
 			if (!crpc->crp_stamp) {
 				crpc->crp_stamp = cfs_time_current();
 				crpc->crp_status = -EINTR;
@@ -778,7 +779,8 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 }
 
 static int
-lstcon_bulkrpc_v0_prep(lst_test_bulk_param_t *param, struct srpc_test_reqst *req)
+lstcon_bulkrpc_v0_prep(lst_test_bulk_param_t *param,
+		       struct srpc_test_reqst *req)
 {
 	struct test_bulk_req *brq = &req->tsr_u.bulk_v0;
 
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index 27ba639..e629e87 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -131,7 +131,8 @@ int  lstcon_rpc_trans_interpreter(struct lstcon_rpc_trans *trans,
 				  lstcon_rpc_readent_func_t readent);
 void lstcon_rpc_trans_abort(struct lstcon_rpc_trans *trans, int error);
 void lstcon_rpc_trans_destroy(struct lstcon_rpc_trans *trans);
-void lstcon_rpc_trans_addreq(struct lstcon_rpc_trans *trans, struct lstcon_rpc *req);
+void lstcon_rpc_trans_addreq(struct lstcon_rpc_trans *trans,
+			     struct lstcon_rpc *req);
 int  lstcon_rpc_trans_postwait(struct lstcon_rpc_trans *trans, int timeout);
 int  lstcon_rpc_pinger_start(void);
 void lstcon_rpc_pinger_stop(void);
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index faa5320..f2d11fa 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -86,7 +86,7 @@
 	if (!create)
 		return -ENOENT;
 
-	LIBCFS_ALLOC(*ndpp, sizeof(struct lstcon_node) + sizeof(struct lstcon_ndlink));
+	LIBCFS_ALLOC(*ndpp, sizeof(*ndpp) + sizeof(*ndl));
 	if (!*ndpp)
 		return -ENOMEM;
 
@@ -131,12 +131,12 @@
 	list_del(&ndl->ndl_link);
 	list_del(&ndl->ndl_hlink);
 
-	LIBCFS_FREE(nd, sizeof(struct lstcon_node) + sizeof(struct lstcon_ndlink));
+	LIBCFS_FREE(nd, sizeof(*nd) + sizeof(*ndl));
 }
 
 static int
-lstcon_ndlink_find(struct list_head *hash,
-		   lnet_process_id_t id, struct lstcon_ndlink **ndlpp, int create)
+lstcon_ndlink_find(struct list_head *hash, lnet_process_id_t id,
+		   struct lstcon_ndlink **ndlpp, int create)
 {
 	unsigned int idx = LNET_NIDADDR(id.nid) % LST_NODE_HASHSIZE;
 	struct lstcon_ndlink *ndl;
@@ -230,7 +230,8 @@
 	grp->grp_ref++;
 }
 
-static void lstcon_group_ndlink_release(struct lstcon_group *, struct lstcon_ndlink *);
+static void lstcon_group_ndlink_release(struct lstcon_group *,
+					struct lstcon_ndlink *);
 
 static void
 lstcon_group_drain(struct lstcon_group *grp, int keep)
@@ -1183,7 +1184,8 @@
 }
 
 static int
-lstcon_test_nodes_add(struct lstcon_test *test, struct list_head __user *result_up)
+lstcon_test_nodes_add(struct lstcon_test *test,
+		      struct list_head __user *result_up)
 {
 	struct lstcon_rpc_trans *trans;
 	struct lstcon_group *grp;
@@ -1366,7 +1368,8 @@
 }
 
 static int
-lstcon_test_find(struct lstcon_batch *batch, int idx, struct lstcon_test **testpp)
+lstcon_test_find(struct lstcon_batch *batch, int idx,
+		 struct lstcon_test **testpp)
 {
 	struct lstcon_test *test;
 
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 8f9ee3f..48dcc33 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -131,7 +131,8 @@
 }
 
 static int
-sfw_register_test(struct srpc_service *service, struct sfw_test_client_ops *cliops)
+sfw_register_test(struct srpc_service *service,
+		  struct sfw_test_client_ops *cliops)
 {
 	struct sfw_test_case *tsc;
 
@@ -469,7 +470,8 @@
 }
 
 static int
-sfw_remove_session(struct srpc_rmsn_reqst *request, struct srpc_rmsn_reply *reply)
+sfw_remove_session(struct srpc_rmsn_reqst *request,
+		   struct srpc_rmsn_reply *reply)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
 
@@ -501,7 +503,8 @@
 }
 
 static int
-sfw_debug_session(struct srpc_debug_reqst *request, struct srpc_debug_reply *reply)
+sfw_debug_session(struct srpc_debug_reqst *request,
+		  struct srpc_debug_reply *reply)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
 
@@ -1064,7 +1067,8 @@
 }
 
 static int
-sfw_query_batch(struct sfw_batch *tsb, int testidx, struct srpc_batch_reply *reply)
+sfw_query_batch(struct sfw_batch *tsb, int testidx,
+		struct srpc_batch_reply *reply)
 {
 	struct sfw_test_instance *tsi;
 
@@ -1179,7 +1183,8 @@
 }
 
 static int
-sfw_control_batch(struct srpc_batch_reqst *request, struct srpc_batch_reply *reply)
+sfw_control_batch(struct srpc_batch_reqst *request,
+		  struct srpc_batch_reply *reply)
 {
 	struct sfw_session *sn = sfw_data.fw_session;
 	int rc = 0;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 0498c56..ce9de8c 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -696,7 +696,8 @@ struct srpc_bulk *
 
 /* called with sv->sv_lock held */
 static void
-srpc_service_recycle_buffer(struct srpc_service_cd *scd, struct srpc_buffer *buf)
+srpc_service_recycle_buffer(struct srpc_service_cd *scd,
+			    struct srpc_buffer *buf)
 __must_hold(&scd->scd_lock)
 {
 	if (!scd->scd_svc->sv_shuttingdown && scd->scd_buf_adjust >= 0) {
-- 
1.7.1
