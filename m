From: James Simmons <jsimmons@infradead.org>
Date: Fri, 12 Feb 2016 12:06:06 -0500
Subject: [lustre-devel] [PATCH 08/11] staging: lustre: remove space in LNet
	function declarations
In-Reply-To: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
References: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455296769-5481-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Dorkin <oleg.dorkin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Several function declarations have spacing in them. Lets
remove all those instances reported by checkpatch.pl.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  272 ++++++++++----------
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   22 +-
 drivers/staging/lustre/lnet/selftest/console.h     |    2 +-
 drivers/staging/lustre/lnet/selftest/selftest.h    |   26 +-
 5 files changed, 161 insertions(+), 163 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 288f0d2..16c90ed 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -967,7 +967,7 @@ void kiblnd_queue_tx(kib_tx_t *tx, kib_conn_t *conn);
 void kiblnd_init_tx_msg(lnet_ni_t *ni, kib_tx_t *tx, int type, int body_nob);
 void kiblnd_txlist_done(lnet_ni_t *ni, struct list_head *txlist,
 			int status);
-void kiblnd_check_sends (kib_conn_t *conn);
+void kiblnd_check_sends(kib_conn_t *conn);
 
 void kiblnd_qp_event(struct ib_event *event, void *arg);
 void kiblnd_cq_event(struct ib_event *event, void *arg);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 31b8d46..16c9bac 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -90,7 +90,7 @@ ksocknal_alloc_tx_noop(__u64 cookie, int nonblk)
 }
 
 void
-ksocknal_free_tx (ksock_tx_t *tx)
+ksocknal_free_tx(ksock_tx_t *tx)
 {
 	atomic_dec(&ksocknal_data.ksnd_nactive_txs);
 
@@ -107,7 +107,7 @@ ksocknal_free_tx (ksock_tx_t *tx)
 }
 
 static int
-ksocknal_send_iov (ksock_conn_t *conn, ksock_tx_t *tx)
+ksocknal_send_iov(ksock_conn_t *conn, ksock_tx_t *tx)
 {
 	struct kvec *iov = tx->tx_iov;
 	int nob;
@@ -122,7 +122,7 @@ ksocknal_send_iov (ksock_conn_t *conn, ksock_tx_t *tx)
 		return rc;
 
 	nob = rc;
-	LASSERT (nob <= tx->tx_resid);
+	LASSERT(nob <= tx->tx_resid);
 	tx->tx_resid -= nob;
 
 	/* "consume" iov */
@@ -144,7 +144,7 @@ ksocknal_send_iov (ksock_conn_t *conn, ksock_tx_t *tx)
 }
 
 static int
-ksocknal_send_kiov (ksock_conn_t *conn, ksock_tx_t *tx)
+ksocknal_send_kiov(ksock_conn_t *conn, ksock_tx_t *tx)
 {
 	lnet_kiov_t *kiov = tx->tx_kiov;
 	int nob;
@@ -160,7 +160,7 @@ ksocknal_send_kiov (ksock_conn_t *conn, ksock_tx_t *tx)
 		return rc;
 
 	nob = rc;
-	LASSERT (nob <= tx->tx_resid);
+	LASSERT(nob <= tx->tx_resid);
 	tx->tx_resid -= nob;
 
 	/* "consume" kiov */
@@ -182,7 +182,7 @@ ksocknal_send_kiov (ksock_conn_t *conn, ksock_tx_t *tx)
 }
 
 static int
-ksocknal_transmit (ksock_conn_t *conn, ksock_tx_t *tx)
+ksocknal_transmit(ksock_conn_t *conn, ksock_tx_t *tx)
 {
 	int rc;
 	int bufnob;
@@ -196,7 +196,7 @@ ksocknal_transmit (ksock_conn_t *conn, ksock_tx_t *tx)
 
 	rc = ksocknal_connsock_addref(conn);
 	if (rc != 0) {
-		LASSERT (conn->ksnc_closing);
+		LASSERT(conn->ksnc_closing);
 		return -ESHUTDOWN;
 	}
 
@@ -206,9 +206,9 @@ ksocknal_transmit (ksock_conn_t *conn, ksock_tx_t *tx)
 			ksocknal_data.ksnd_enomem_tx--;
 			rc = -EAGAIN;
 		} else if (tx->tx_niov != 0) {
-			rc = ksocknal_send_iov (conn, tx);
+			rc = ksocknal_send_iov(conn, tx);
 		} else {
-			rc = ksocknal_send_kiov (conn, tx);
+			rc = ksocknal_send_kiov(conn, tx);
 		}
 
 		bufnob = conn->ksnc_sock->sk->sk_wmem_queued;
@@ -240,7 +240,7 @@ ksocknal_transmit (ksock_conn_t *conn, ksock_tx_t *tx)
 		}
 
 		/* socket's wmem_queued now includes 'rc' bytes */
-		atomic_sub (rc, &conn->ksnc_tx_nob);
+		atomic_sub(rc, &conn->ksnc_tx_nob);
 		rc = 0;
 
 	} while (tx->tx_resid != 0);
@@ -250,7 +250,7 @@ ksocknal_transmit (ksock_conn_t *conn, ksock_tx_t *tx)
 }
 
 static int
-ksocknal_recv_iov (ksock_conn_t *conn)
+ksocknal_recv_iov(ksock_conn_t *conn)
 {
 	struct kvec *iov = conn->ksnc_rx_iov;
 	int nob;
@@ -297,7 +297,7 @@ ksocknal_recv_iov (ksock_conn_t *conn)
 }
 
 static int
-ksocknal_recv_kiov (ksock_conn_t *conn)
+ksocknal_recv_kiov(ksock_conn_t *conn)
 {
 	lnet_kiov_t *kiov = conn->ksnc_rx_kiov;
 	int nob;
@@ -344,7 +344,7 @@ ksocknal_recv_kiov (ksock_conn_t *conn)
 }
 
 static int
-ksocknal_receive (ksock_conn_t *conn)
+ksocknal_receive(ksock_conn_t *conn)
 {
 	/*
 	 * Return 1 on success, 0 on EOF, < 0 on error.
@@ -360,15 +360,15 @@ ksocknal_receive (ksock_conn_t *conn)
 
 	rc = ksocknal_connsock_addref(conn);
 	if (rc != 0) {
-		LASSERT (conn->ksnc_closing);
+		LASSERT(conn->ksnc_closing);
 		return -ESHUTDOWN;
 	}
 
 	for (;;) {
 		if (conn->ksnc_rx_niov != 0)
-			rc = ksocknal_recv_iov (conn);
+			rc = ksocknal_recv_iov(conn);
 		else
-			rc = ksocknal_recv_kiov (conn);
+			rc = ksocknal_recv_kiov(conn);
 
 		if (rc <= 0) {
 			/* error/EOF or partial receive */
@@ -394,7 +394,7 @@ ksocknal_receive (ksock_conn_t *conn)
 }
 
 void
-ksocknal_tx_done (lnet_ni_t *ni, ksock_tx_t *tx)
+ksocknal_tx_done(lnet_ni_t *ni, ksock_tx_t *tx)
 {
 	lnet_msg_t *lnetmsg = tx->tx_lnetmsg;
 	int rc = (tx->tx_resid == 0 && !tx->tx_zc_aborted) ? 0 : -EIO;
@@ -407,23 +407,23 @@ ksocknal_tx_done (lnet_ni_t *ni, ksock_tx_t *tx)
 	if (ni == NULL && tx->tx_conn != NULL)
 		ni = tx->tx_conn->ksnc_peer->ksnp_ni;
 
-	ksocknal_free_tx (tx);
+	ksocknal_free_tx(tx);
 	if (lnetmsg != NULL) /* KSOCK_MSG_NOOP go without lnetmsg */
-		lnet_finalize (ni, lnetmsg, rc);
+		lnet_finalize(ni, lnetmsg, rc);
 }
 
 void
-ksocknal_txlist_done (lnet_ni_t *ni, struct list_head *txlist, int error)
+ksocknal_txlist_done(lnet_ni_t *ni, struct list_head *txlist, int error)
 {
 	ksock_tx_t *tx;
 
-	while (!list_empty (txlist)) {
+	while (!list_empty(txlist)) {
 		tx = list_entry(txlist->next, ksock_tx_t, tx_list);
 
 		if (error && tx->tx_lnetmsg != NULL) {
 			CNETERR("Deleting packet type %d len %d %s->%s\n",
-				le32_to_cpu (tx->tx_lnetmsg->msg_hdr.type),
-				le32_to_cpu (tx->tx_lnetmsg->msg_hdr.payload_length),
+				le32_to_cpu(tx->tx_lnetmsg->msg_hdr.type),
+				le32_to_cpu(tx->tx_lnetmsg->msg_hdr.payload_length),
 				libcfs_nid2str(le64_to_cpu(tx->tx_lnetmsg->msg_hdr.src_nid)),
 				libcfs_nid2str(le64_to_cpu(tx->tx_lnetmsg->msg_hdr.dest_nid)));
 		} else if (error) {
@@ -511,20 +511,20 @@ ksocknal_uncheck_zc_req(ksock_tx_t *tx)
 }
 
 static int
-ksocknal_process_transmit (ksock_conn_t *conn, ksock_tx_t *tx)
+ksocknal_process_transmit(ksock_conn_t *conn, ksock_tx_t *tx)
 {
 	int rc;
 
 	if (tx->tx_zc_capable && !tx->tx_zc_checked)
 		ksocknal_check_zc_req(tx);
 
-	rc = ksocknal_transmit (conn, tx);
+	rc = ksocknal_transmit(conn, tx);
 
 	CDEBUG(D_NET, "send(%d) %d\n", tx->tx_resid, rc);
 
 	if (tx->tx_resid == 0) {
 		/* Sent everything OK */
-		LASSERT (rc == 0);
+		LASSERT(rc == 0);
 
 		return 0;
 	}
@@ -543,13 +543,13 @@ ksocknal_process_transmit (ksock_conn_t *conn, ksock_tx_t *tx)
 		spin_lock_bh(&ksocknal_data.ksnd_reaper_lock);
 
 		/* enomem list takes over scheduler's ref... */
-		LASSERT (conn->ksnc_tx_scheduled);
+		LASSERT(conn->ksnc_tx_scheduled);
 		list_add_tail(&conn->ksnc_tx_list,
 			      &ksocknal_data.ksnd_enomem_conns);
 		if (!cfs_time_aftereq(cfs_time_add(cfs_time_current(),
 						   SOCKNAL_ENOMEM_RETRY),
 				   ksocknal_data.ksnd_reaper_waketime))
-			wake_up (&ksocknal_data.ksnd_reaper_waitq);
+			wake_up(&ksocknal_data.ksnd_reaper_waitq);
 
 		spin_unlock_bh(&ksocknal_data.ksnd_reaper_lock);
 		return rc;
@@ -580,14 +580,13 @@ ksocknal_process_transmit (ksock_conn_t *conn, ksock_tx_t *tx)
 		ksocknal_uncheck_zc_req(tx);
 
 	/* it's not an error if conn is being closed */
-	ksocknal_close_conn_and_siblings (conn,
-					  (conn->ksnc_closing) ? 0 : rc);
+	ksocknal_close_conn_and_siblings(conn, (conn->ksnc_closing) ? 0 : rc);
 
 	return rc;
 }
 
 static void
-ksocknal_launch_connection_locked (ksock_route_t *route)
+ksocknal_launch_connection_locked(ksock_route_t *route)
 {
 	/* called holding write lock on ksnd_global_lock */
 
@@ -608,7 +607,7 @@ ksocknal_launch_connection_locked (ksock_route_t *route)
 }
 
 void
-ksocknal_launch_all_connections_locked (ksock_peer_t *peer)
+ksocknal_launch_all_connections_locked(ksock_peer_t *peer)
 {
 	ksock_route_t *route;
 
@@ -633,7 +632,7 @@ ksocknal_find_conn_locked(ksock_peer_t *peer, ksock_tx_t *tx, int nonblk)
 	int tnob = 0;
 	int fnob = 0;
 
-	list_for_each (tmp, &peer->ksnp_conns) {
+	list_for_each(tmp, &peer->ksnp_conns) {
 		ksock_conn_t *c  = list_entry(tmp, ksock_conn_t, ksnc_list);
 		int nob = atomic_read(&c->ksnc_tx_nob) +
 			c->ksnc_sock->sk->sk_wmem_queued;
@@ -685,13 +684,13 @@ ksocknal_tx_prep(ksock_conn_t *conn, ksock_tx_t *tx)
 {
 	conn->ksnc_proto->pro_pack(tx);
 
-	atomic_add (tx->tx_nob, &conn->ksnc_tx_nob);
+	atomic_add(tx->tx_nob, &conn->ksnc_tx_nob);
 	ksocknal_conn_addref(conn); /* +1 ref for tx */
 	tx->tx_conn = conn;
 }
 
 void
-ksocknal_queue_tx_locked (ksock_tx_t *tx, ksock_conn_t *conn)
+ksocknal_queue_tx_locked(ksock_tx_t *tx, ksock_conn_t *conn)
 {
 	ksock_sched_t *sched = conn->ksnc_scheduler;
 	ksock_msg_t *msg = &tx->tx_msg;
@@ -720,16 +719,16 @@ ksocknal_queue_tx_locked (ksock_tx_t *tx, ksock_conn_t *conn)
 	 * We always expect at least 1 mapped fragment containing the
 	 * complete ksocknal message header.
 	 */
-	LASSERT(lnet_iov_nob (tx->tx_niov, tx->tx_iov) +
+	LASSERT(lnet_iov_nob(tx->tx_niov, tx->tx_iov) +
 		lnet_kiov_nob(tx->tx_nkiov, tx->tx_kiov) ==
 		(unsigned int)tx->tx_nob);
 	LASSERT(tx->tx_niov >= 1);
 	LASSERT(tx->tx_resid == tx->tx_nob);
 
-	CDEBUG (D_NET, "Packet %p type %d, nob %d niov %d nkiov %d\n",
-		tx, (tx->tx_lnetmsg != NULL) ? tx->tx_lnetmsg->msg_hdr.type :
-					       KSOCK_MSG_NOOP,
-		tx->tx_nob, tx->tx_niov, tx->tx_nkiov);
+	CDEBUG(D_NET, "Packet %p type %d, nob %d niov %d nkiov %d\n",
+	       tx, (tx->tx_lnetmsg != NULL) ? tx->tx_lnetmsg->msg_hdr.type :
+					      KSOCK_MSG_NOOP,
+	       tx->tx_nob, tx->tx_niov, tx->tx_nkiov);
 
 	/*
 	 * FIXME: SOCK_WMEM_QUEUED and SOCK_ERROR could block in __DARWIN8__
@@ -772,7 +771,7 @@ ksocknal_queue_tx_locked (ksock_tx_t *tx, ksock_conn_t *conn)
 	}
 
 	if (ztx != NULL) {
-		atomic_sub (ztx->tx_nob, &conn->ksnc_tx_nob);
+		atomic_sub(ztx->tx_nob, &conn->ksnc_tx_nob);
 		list_add_tail(&ztx->tx_list, &sched->kss_zombie_noop_txs);
 	}
 
@@ -782,21 +781,21 @@ ksocknal_queue_tx_locked (ksock_tx_t *tx, ksock_conn_t *conn)
 		ksocknal_conn_addref(conn);
 		list_add_tail(&conn->ksnc_tx_list, &sched->kss_tx_conns);
 		conn->ksnc_tx_scheduled = 1;
-		wake_up (&sched->kss_waitq);
+		wake_up(&sched->kss_waitq);
 	}
 
 	spin_unlock_bh(&sched->kss_lock);
 }
 
 ksock_route_t *
-ksocknal_find_connectable_route_locked (ksock_peer_t *peer)
+ksocknal_find_connectable_route_locked(ksock_peer_t *peer)
 {
 	unsigned long now = cfs_time_current();
 	struct list_head *tmp;
 	ksock_route_t *route;
 
-	list_for_each (tmp, &peer->ksnp_routes) {
-		route = list_entry (tmp, ksock_route_t, ksnr_list);
+	list_for_each(tmp, &peer->ksnp_routes) {
+		route = list_entry(tmp, ksock_route_t, ksnr_list);
 
 		LASSERT(!route->ksnr_connecting || route->ksnr_scheduled);
 
@@ -825,13 +824,13 @@ ksocknal_find_connectable_route_locked (ksock_peer_t *peer)
 }
 
 ksock_route_t *
-ksocknal_find_connecting_route_locked (ksock_peer_t *peer)
+ksocknal_find_connecting_route_locked(ksock_peer_t *peer)
 {
 	struct list_head *tmp;
 	ksock_route_t *route;
 
-	list_for_each (tmp, &peer->ksnp_routes) {
-		route = list_entry (tmp, ksock_route_t, ksnr_list);
+	list_for_each(tmp, &peer->ksnp_routes) {
+		route = list_entry(tmp, ksock_route_t, ksnr_list);
 
 		LASSERT(!route->ksnr_connecting || route->ksnr_scheduled);
 
@@ -843,7 +842,7 @@ ksocknal_find_connecting_route_locked (ksock_peer_t *peer)
 }
 
 int
-ksocknal_launch_packet (lnet_ni_t *ni, ksock_tx_t *tx, lnet_process_id_t id)
+ksocknal_launch_packet(lnet_ni_t *ni, ksock_tx_t *tx, lnet_process_id_t id)
 {
 	ksock_peer_t *peer;
 	ksock_conn_t *conn;
@@ -867,7 +866,7 @@ ksocknal_launch_packet (lnet_ni_t *ni, ksock_tx_t *tx, lnet_process_id_t id)
 					 * connecting and I do have an actual
 					 * connection...
 					 */
-					ksocknal_queue_tx_locked (tx, conn);
+					ksocknal_queue_tx_locked(tx, conn);
 					read_unlock(g_lock);
 					return 0;
 				}
@@ -911,19 +910,19 @@ ksocknal_launch_packet (lnet_ni_t *ni, ksock_tx_t *tx, lnet_process_id_t id)
 	conn = ksocknal_find_conn_locked(peer, tx, tx->tx_nonblk);
 	if (conn != NULL) {
 		/* Connection exists; queue message on it */
-		ksocknal_queue_tx_locked (tx, conn);
+		ksocknal_queue_tx_locked(tx, conn);
 		write_unlock_bh(g_lock);
 		return 0;
 	}
 
 	if (peer->ksnp_accepting > 0 ||
-	    ksocknal_find_connecting_route_locked (peer) != NULL) {
+	    ksocknal_find_connecting_route_locked(peer) != NULL) {
 		/* the message is going to be pinned to the peer */
 		tx->tx_deadline =
 			cfs_time_shift(*ksocknal_tunables.ksnd_timeout);
 
 		/* Queue the message until a connection is established */
-		list_add_tail (&tx->tx_list, &peer->ksnp_tx_queue);
+		list_add_tail(&tx->tx_list, &peer->ksnp_tx_queue);
 		write_unlock_bh(g_lock);
 		return 0;
 	}
@@ -960,8 +959,8 @@ ksocknal_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	LASSERT(payload_nob == 0 || payload_niov > 0);
 	LASSERT(payload_niov <= LNET_MAX_IOV);
 	/* payload is either all vaddrs or all pages */
-	LASSERT (!(payload_kiov != NULL && payload_iov != NULL));
-	LASSERT (!in_interrupt ());
+	LASSERT(!(payload_kiov != NULL && payload_iov != NULL));
+	LASSERT(!in_interrupt());
 
 	if (payload_iov != NULL)
 		desc_size = offsetof(ksock_tx_t,
@@ -1033,7 +1032,7 @@ ksocknal_thread_start(int (*fn)(void *arg), void *arg, char *name)
 }
 
 void
-ksocknal_thread_fini (void)
+ksocknal_thread_fini(void)
 {
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 	ksocknal_data.ksnd_nthreads--;
@@ -1041,7 +1040,7 @@ ksocknal_thread_fini (void)
 }
 
 int
-ksocknal_new_packet (ksock_conn_t *conn, int nob_to_skip)
+ksocknal_new_packet(ksock_conn_t *conn, int nob_to_skip)
 {
 	static char ksocknal_slop_buffer[4096];
 
@@ -1080,11 +1079,11 @@ ksocknal_new_packet (ksock_conn_t *conn, int nob_to_skip)
 
 			conn->ksnc_rx_iov = (struct kvec *)&conn->ksnc_rx_iov_space;
 			conn->ksnc_rx_iov[0].iov_base = &conn->ksnc_msg.ksm_u.lnetmsg;
-			conn->ksnc_rx_iov[0].iov_len = sizeof (lnet_hdr_t);
+			conn->ksnc_rx_iov[0].iov_len = sizeof(lnet_hdr_t);
 			break;
 
 		default:
-			LBUG ();
+			LBUG();
 		}
 		conn->ksnc_rx_niov = 1;
 
@@ -1114,7 +1113,7 @@ ksocknal_new_packet (ksock_conn_t *conn, int nob_to_skip)
 		nob_to_skip -= nob;
 
 	} while (nob_to_skip != 0 &&    /* mustn't overflow conn's rx iov */
-		 niov < sizeof(conn->ksnc_rx_iov_space) / sizeof (struct iovec));
+		 niov < sizeof(conn->ksnc_rx_iov_space) / sizeof(struct iovec));
 
 	conn->ksnc_rx_niov = niov;
 	conn->ksnc_rx_kiov = NULL;
@@ -1124,13 +1123,13 @@ ksocknal_new_packet (ksock_conn_t *conn, int nob_to_skip)
 }
 
 static int
-ksocknal_process_receive (ksock_conn_t *conn)
+ksocknal_process_receive(ksock_conn_t *conn)
 {
 	lnet_hdr_t *lhdr;
 	lnet_process_id_t *id;
 	int rc;
 
-	LASSERT (atomic_read(&conn->ksnc_conn_refcount) > 0);
+	LASSERT(atomic_read(&conn->ksnc_conn_refcount) > 0);
 
 	/* NB: sched lock NOT held */
 	/* SOCKNAL_RX_LNET_HEADER is here for backward compatibility */
@@ -1143,7 +1142,7 @@ ksocknal_process_receive (ksock_conn_t *conn)
 		rc = ksocknal_receive(conn);
 
 		if (rc <= 0) {
-			LASSERT (rc != -EAGAIN);
+			LASSERT(rc != -EAGAIN);
 
 			if (rc == 0)
 				CDEBUG(D_NET, "[%p] EOF from %s ip %pI4h:%d\n",
@@ -1159,8 +1158,8 @@ ksocknal_process_receive (ksock_conn_t *conn)
 				       conn->ksnc_port);
 
 			/* it's not an error if conn is being closed */
-			ksocknal_close_conn_and_siblings (conn,
-							  (conn->ksnc_closing) ? 0 : rc);
+			ksocknal_close_conn_and_siblings(conn,
+							 (conn->ksnc_closing) ? 0 : rc);
 			return (rc == 0 ? -ESHUTDOWN : rc);
 		}
 
@@ -1203,7 +1202,7 @@ ksocknal_process_receive (ksock_conn_t *conn)
 		if (conn->ksnc_msg.ksm_zc_cookies[1] != 0) {
 			__u64 cookie = 0;
 
-			LASSERT (conn->ksnc_proto != &ksocknal_protocol_v1x);
+			LASSERT(conn->ksnc_proto != &ksocknal_protocol_v1x);
 
 			if (conn->ksnc_msg.ksm_type == KSOCK_MSG_NOOP)
 				cookie = conn->ksnc_msg.ksm_zc_cookies[0];
@@ -1222,7 +1221,7 @@ ksocknal_process_receive (ksock_conn_t *conn)
 		}
 
 		if (conn->ksnc_msg.ksm_type == KSOCK_MSG_NOOP) {
-			ksocknal_new_packet (conn, 0);
+			ksocknal_new_packet(conn, 0);
 			return 0;       /* NOOP is done and just return */
 		}
 
@@ -1263,14 +1262,14 @@ ksocknal_process_receive (ksock_conn_t *conn)
 		if (rc < 0) {
 			/* I just received garbage: give up on this conn */
 			ksocknal_new_packet(conn, 0);
-			ksocknal_close_conn_and_siblings (conn, rc);
+			ksocknal_close_conn_and_siblings(conn, rc);
 			ksocknal_conn_decref(conn);
 			return -EPROTO;
 		}
 
 		/* I'm racing with ksocknal_recv() */
-		LASSERT (conn->ksnc_rx_state == SOCKNAL_RX_PARSE ||
-			 conn->ksnc_rx_state == SOCKNAL_RX_LNET_PAYLOAD);
+		LASSERT(conn->ksnc_rx_state == SOCKNAL_RX_PARSE ||
+			conn->ksnc_rx_state == SOCKNAL_RX_LNET_PAYLOAD);
 
 		if (conn->ksnc_rx_state != SOCKNAL_RX_LNET_PAYLOAD)
 			return 0;
@@ -1307,14 +1306,14 @@ ksocknal_process_receive (ksock_conn_t *conn)
 
 		if (rc != 0) {
 			ksocknal_new_packet(conn, 0);
-			ksocknal_close_conn_and_siblings (conn, rc);
+			ksocknal_close_conn_and_siblings(conn, rc);
 			return -EPROTO;
 		}
 		/* Fall through */
 
 	case SOCKNAL_RX_SLOP:
 		/* starting new packet? */
-		if (ksocknal_new_packet (conn, conn->ksnc_rx_nob_left))
+		if (ksocknal_new_packet(conn, conn->ksnc_rx_nob_left))
 			return 0;       /* come back later */
 		goto again;	     /* try to finish reading slop now */
 
@@ -1328,9 +1327,9 @@ ksocknal_process_receive (ksock_conn_t *conn)
 }
 
 int
-ksocknal_recv (lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
-	       unsigned int niov, struct kvec *iov, lnet_kiov_t *kiov,
-	       unsigned int offset, unsigned int mlen, unsigned int rlen)
+ksocknal_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
+	      unsigned int niov, struct kvec *iov, lnet_kiov_t *kiov,
+	      unsigned int offset, unsigned int mlen, unsigned int rlen)
 {
 	ksock_conn_t *conn = private;
 	ksock_sched_t *sched = conn->ksnc_scheduler;
@@ -1369,8 +1368,8 @@ ksocknal_recv (lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 	switch (conn->ksnc_rx_state) {
 	case SOCKNAL_RX_PARSE_WAIT:
 		list_add_tail(&conn->ksnc_rx_list, &sched->kss_rx_conns);
-		wake_up (&sched->kss_waitq);
-		LASSERT (conn->ksnc_rx_ready);
+		wake_up(&sched->kss_waitq);
+		LASSERT(conn->ksnc_rx_ready);
 		break;
 
 	case SOCKNAL_RX_PARSE:
@@ -1428,7 +1427,7 @@ int ksocknal_scheduler(void *arg)
 
 		/* Ensure I progress everything semi-fairly */
 
-		if (!list_empty (&sched->kss_rx_conns)) {
+		if (!list_empty(&sched->kss_rx_conns)) {
 			conn = list_entry(sched->kss_rx_conns.next,
 					  ksock_conn_t, ksnc_rx_list);
 			list_del(&conn->ksnc_rx_list);
@@ -1476,7 +1475,7 @@ int ksocknal_scheduler(void *arg)
 			did_something = 1;
 		}
 
-		if (!list_empty (&sched->kss_tx_conns)) {
+		if (!list_empty(&sched->kss_tx_conns)) {
 			LIST_HEAD(zlist);
 
 			if (!list_empty(&sched->kss_zombie_noop_txs)) {
@@ -1486,7 +1485,7 @@ int ksocknal_scheduler(void *arg)
 
 			conn = list_entry(sched->kss_tx_conns.next,
 					  ksock_conn_t, ksnc_tx_list);
-			list_del (&conn->ksnc_tx_list);
+			list_del(&conn->ksnc_tx_list);
 
 			LASSERT(conn->ksnc_tx_scheduled);
 			LASSERT(conn->ksnc_tx_ready);
@@ -1561,7 +1560,7 @@ int ksocknal_scheduler(void *arg)
 				rc = wait_event_interruptible_exclusive(
 					sched->kss_waitq,
 					!ksocknal_sched_cansleep(sched));
-				LASSERT (rc == 0);
+				LASSERT(rc == 0);
 			} else {
 				cond_resched();
 			}
@@ -1579,7 +1578,7 @@ int ksocknal_scheduler(void *arg)
  * Add connection to kss_rx_conns of scheduler
  * and wakeup the scheduler.
  */
-void ksocknal_read_callback (ksock_conn_t *conn)
+void ksocknal_read_callback(ksock_conn_t *conn)
 {
 	ksock_sched_t *sched;
 
@@ -1595,7 +1594,7 @@ void ksocknal_read_callback (ksock_conn_t *conn)
 		/* extra ref for scheduler */
 		ksocknal_conn_addref(conn);
 
-		wake_up (&sched->kss_waitq);
+		wake_up(&sched->kss_waitq);
 	}
 	spin_unlock_bh(&sched->kss_lock);
 }
@@ -1604,7 +1603,7 @@ void ksocknal_read_callback (ksock_conn_t *conn)
  * Add connection to kss_tx_conns of scheduler
  * and wakeup the scheduler.
  */
-void ksocknal_write_callback (ksock_conn_t *conn)
+void ksocknal_write_callback(ksock_conn_t *conn)
 {
 	ksock_sched_t *sched;
 
@@ -1621,14 +1620,14 @@ void ksocknal_write_callback (ksock_conn_t *conn)
 		/* extra ref for scheduler */
 		ksocknal_conn_addref(conn);
 
-		wake_up (&sched->kss_waitq);
+		wake_up(&sched->kss_waitq);
 	}
 
 	spin_unlock_bh(&sched->kss_lock);
 }
 
 static ksock_proto_t *
-ksocknal_parse_proto_version (ksock_hello_msg_t *hello)
+ksocknal_parse_proto_version(ksock_hello_msg_t *hello)
 {
 	__u32 version = 0;
 
@@ -1658,11 +1657,11 @@ ksocknal_parse_proto_version (ksock_hello_msg_t *hello)
 	if (hello->kshm_magic == le32_to_cpu(LNET_PROTO_TCP_MAGIC)) {
 		lnet_magicversion_t *hmv = (lnet_magicversion_t *)hello;
 
-		CLASSERT(sizeof (lnet_magicversion_t) ==
-			 offsetof (ksock_hello_msg_t, kshm_src_nid));
+		CLASSERT(sizeof(lnet_magicversion_t) ==
+			 offsetof(ksock_hello_msg_t, kshm_src_nid));
 
-		if (hmv->version_major == cpu_to_le16 (KSOCK_PROTO_V1_MAJOR) &&
-		    hmv->version_minor == cpu_to_le16 (KSOCK_PROTO_V1_MINOR))
+		if (hmv->version_major == cpu_to_le16(KSOCK_PROTO_V1_MAJOR) &&
+		    hmv->version_minor == cpu_to_le16(KSOCK_PROTO_V1_MINOR))
 			return &ksocknal_protocol_v1x;
 	}
 
@@ -1670,8 +1669,8 @@ ksocknal_parse_proto_version (ksock_hello_msg_t *hello)
 }
 
 int
-ksocknal_send_hello (lnet_ni_t *ni, ksock_conn_t *conn,
-		     lnet_nid_t peer_nid, ksock_hello_msg_t *hello)
+ksocknal_send_hello(lnet_ni_t *ni, ksock_conn_t *conn,
+		    lnet_nid_t peer_nid, ksock_hello_msg_t *hello)
 {
 	/* CAVEAT EMPTOR: this byte flips 'ipaddrs' */
 	ksock_net_t *net = (ksock_net_t *)ni->ni_data;
@@ -1708,9 +1707,9 @@ ksocknal_invert_type(int type)
 }
 
 int
-ksocknal_recv_hello (lnet_ni_t *ni, ksock_conn_t *conn,
-		     ksock_hello_msg_t *hello, lnet_process_id_t *peerid,
-		     __u64 *incarnation)
+ksocknal_recv_hello(lnet_ni_t *ni, ksock_conn_t *conn,
+		    ksock_hello_msg_t *hello, lnet_process_id_t *peerid,
+		    __u64 *incarnation)
 {
 	/* Return < 0	fatal error
 	 *	0	  success
@@ -1731,20 +1730,20 @@ ksocknal_recv_hello (lnet_ni_t *ni, ksock_conn_t *conn,
 	timeout = active ? *ksocknal_tunables.ksnd_timeout :
 			    lnet_acceptor_timeout();
 
-	rc = lnet_sock_read(sock, &hello->kshm_magic, sizeof (hello->kshm_magic), timeout);
+	rc = lnet_sock_read(sock, &hello->kshm_magic, sizeof(hello->kshm_magic), timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading HELLO from %pI4h\n",
 		       rc, &conn->ksnc_ipaddr);
-		LASSERT (rc < 0);
+		LASSERT(rc < 0);
 		return rc;
 	}
 
 	if (hello->kshm_magic != LNET_PROTO_MAGIC &&
 	    hello->kshm_magic != __swab32(LNET_PROTO_MAGIC) &&
-	    hello->kshm_magic != le32_to_cpu (LNET_PROTO_TCP_MAGIC)) {
+	    hello->kshm_magic != le32_to_cpu(LNET_PROTO_TCP_MAGIC)) {
 		/* Unexpected magic! */
 		CERROR("Bad magic(1) %#08x (%#08x expected) from %pI4h\n",
-		       __cpu_to_le32 (hello->kshm_magic),
+		       __cpu_to_le32(hello->kshm_magic),
 		       LNET_PROTO_TCP_MAGIC,
 		       &conn->ksnc_ipaddr);
 		return -EPROTO;
@@ -1851,7 +1850,7 @@ ksocknal_recv_hello (lnet_ni_t *ni, ksock_conn_t *conn,
 }
 
 static int
-ksocknal_connect (ksock_route_t *route)
+ksocknal_connect(ksock_route_t *route)
 {
 	LIST_HEAD(zombies);
 	ksock_peer_t *peer = route->ksnr_peer;
@@ -1903,7 +1902,7 @@ ksocknal_connect (ksock_route_t *route)
 		} else if ((wanted & (1 << SOCKLND_CONN_BULK_IN)) != 0) {
 			type = SOCKLND_CONN_BULK_IN;
 		} else {
-			LASSERT ((wanted & (1 << SOCKLND_CONN_BULK_OUT)) != 0);
+			LASSERT((wanted & (1 << SOCKLND_CONN_BULK_OUT)) != 0);
 			type = SOCKLND_CONN_BULK_OUT;
 		}
 
@@ -1986,7 +1985,7 @@ ksocknal_connect (ksock_route_t *route)
 		min(route->ksnr_retry_interval,
 		    cfs_time_seconds(*ksocknal_tunables.ksnd_max_reconnectms) / 1000);
 
-	LASSERT (route->ksnr_retry_interval != 0);
+	LASSERT(route->ksnr_retry_interval != 0);
 	route->ksnr_timeout = cfs_time_add(cfs_time_current(),
 					   route->ksnr_retry_interval);
 
@@ -1999,10 +1998,10 @@ ksocknal_connect (ksock_route_t *route)
 		 * ksnp_tx_queue is queued on a conn on successful
 		 * connection for V1.x and V2.x
 		 */
-		if (!list_empty (&peer->ksnp_conns)) {
+		if (!list_empty(&peer->ksnp_conns)) {
 			conn = list_entry(peer->ksnp_conns.next,
 					  ksock_conn_t, ksnc_list);
-			LASSERT (conn->ksnc_proto == &ksocknal_protocol_v3x);
+			LASSERT(conn->ksnc_proto == &ksocknal_protocol_v3x);
 		}
 
 		/*
@@ -2159,7 +2158,7 @@ ksocknal_connd_get_route_locked(signed long *timeout_p)
 }
 
 int
-ksocknal_connd (void *arg)
+ksocknal_connd(void *arg)
 {
 	spinlock_t *connd_lock = &ksocknal_data.ksnd_connd_lock;
 	ksock_connreq_t *cr;
@@ -2221,7 +2220,7 @@ ksocknal_connd (void *arg)
 			route = ksocknal_connd_get_route_locked(&timeout);
 		}
 		if (route != NULL) {
-			list_del (&route->ksnr_connd_list);
+			list_del(&route->ksnr_connd_list);
 			ksocknal_data.ksnd_connd_connecting++;
 			spin_unlock_bh(connd_lock);
 			dropped_lock = 1;
@@ -2272,16 +2271,16 @@ ksocknal_connd (void *arg)
 }
 
 static ksock_conn_t *
-ksocknal_find_timed_out_conn (ksock_peer_t *peer)
+ksocknal_find_timed_out_conn(ksock_peer_t *peer)
 {
 	/* We're called with a shared lock on ksnd_global_lock */
 	ksock_conn_t *conn;
 	struct list_head *ctmp;
 
-	list_for_each (ctmp, &peer->ksnp_conns) {
+	list_for_each(ctmp, &peer->ksnp_conns) {
 		int error;
 
-		conn = list_entry (ctmp, ksock_conn_t, ksnc_list);
+		conn = list_entry(ctmp, ksock_conn_t, ksnc_list);
 
 		/* Don't need the {get,put}connsock dance to deref ksnc_sock */
 		LASSERT(!conn->ksnc_closing);
@@ -2362,15 +2361,15 @@ ksocknal_flush_stale_txs(ksock_peer_t *peer)
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
-	while (!list_empty (&peer->ksnp_tx_queue)) {
+	while (!list_empty(&peer->ksnp_tx_queue)) {
 		tx = list_entry(peer->ksnp_tx_queue.next, ksock_tx_t, tx_list);
 
 		if (!cfs_time_aftereq(cfs_time_current(),
 				      tx->tx_deadline))
 			break;
 
-		list_del (&tx->tx_list);
-		list_add_tail (&tx->tx_list, &stale_txs);
+		list_del(&tx->tx_list);
+		list_add_tail(&tx->tx_list, &stale_txs);
 	}
 
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
@@ -2442,7 +2441,7 @@ ksocknal_send_keepalive_locked(ksock_peer_t *peer)
 }
 
 static void
-ksocknal_check_peer_timeouts (int idx)
+ksocknal_check_peer_timeouts(int idx)
 {
 	struct list_head *peers = &ksocknal_data.ksnd_peers[idx];
 	ksock_peer_t *peer;
@@ -2467,12 +2466,12 @@ ksocknal_check_peer_timeouts (int idx)
 			goto again;
 		}
 
-		conn = ksocknal_find_timed_out_conn (peer);
+		conn = ksocknal_find_timed_out_conn(peer);
 
 		if (conn != NULL) {
 			read_unlock(&ksocknal_data.ksnd_global_lock);
 
-			ksocknal_close_conn_and_siblings (conn, -ETIMEDOUT);
+			ksocknal_close_conn_and_siblings(conn, -ETIMEDOUT);
 
 			/*
 			 * NB we won't find this one again, but we can't
@@ -2487,7 +2486,7 @@ ksocknal_check_peer_timeouts (int idx)
 		 * we can't process stale txs right here because we're
 		 * holding only shared lock
 		 */
-		if (!list_empty (&peer->ksnp_tx_queue)) {
+		if (!list_empty(&peer->ksnp_tx_queue)) {
 			ksock_tx_t *tx = list_entry(peer->ksnp_tx_queue.next,
 						    ksock_tx_t, tx_list);
 
@@ -2537,7 +2536,7 @@ ksocknal_check_peer_timeouts (int idx)
 		       cfs_duration_sec(cfs_time_current() - deadline),
 		       resid, conn->ksnc_sock->sk->sk_wmem_queued);
 
-		ksocknal_close_conn_and_siblings (conn, -ETIMEDOUT);
+		ksocknal_close_conn_and_siblings(conn, -ETIMEDOUT);
 		ksocknal_conn_decref(conn);
 		goto again;
 	}
@@ -2546,7 +2545,7 @@ ksocknal_check_peer_timeouts (int idx)
 }
 
 int
-ksocknal_reaper (void *arg)
+ksocknal_reaper(void *arg)
 {
 	wait_queue_t wait;
 	ksock_conn_t *conn;
@@ -2566,11 +2565,10 @@ ksocknal_reaper (void *arg)
 	spin_lock_bh(&ksocknal_data.ksnd_reaper_lock);
 
 	while (!ksocknal_data.ksnd_shuttingdown) {
-		if (!list_empty (&ksocknal_data.ksnd_deathrow_conns)) {
-			conn = list_entry (ksocknal_data. \
-					       ksnd_deathrow_conns.next,
-					       ksock_conn_t, ksnc_list);
-			list_del (&conn->ksnc_list);
+		if (!list_empty(&ksocknal_data.ksnd_deathrow_conns)) {
+			conn = list_entry(ksocknal_data.ksnd_deathrow_conns.next,
+					  ksock_conn_t, ksnc_list);
+			list_del(&conn->ksnc_list);
 
 			spin_unlock_bh(&ksocknal_data.ksnd_reaper_lock);
 
@@ -2581,10 +2579,10 @@ ksocknal_reaper (void *arg)
 			continue;
 		}
 
-		if (!list_empty (&ksocknal_data.ksnd_zombie_conns)) {
-			conn = list_entry (ksocknal_data.ksnd_zombie_conns.\
-					       next, ksock_conn_t, ksnc_list);
-			list_del (&conn->ksnc_list);
+		if (!list_empty(&ksocknal_data.ksnd_zombie_conns)) {
+			conn = list_entry(ksocknal_data.ksnd_zombie_conns.next,
+					  ksock_conn_t, ksnc_list);
+			list_del(&conn->ksnc_list);
 
 			spin_unlock_bh(&ksocknal_data.ksnd_reaper_lock);
 
@@ -2594,7 +2592,7 @@ ksocknal_reaper (void *arg)
 			continue;
 		}
 
-		if (!list_empty (&ksocknal_data.ksnd_enomem_conns)) {
+		if (!list_empty(&ksocknal_data.ksnd_enomem_conns)) {
 			list_add(&enomem_conns,
 				 &ksocknal_data.ksnd_enomem_conns);
 			list_del_init(&ksocknal_data.ksnd_enomem_conns);
@@ -2604,10 +2602,10 @@ ksocknal_reaper (void *arg)
 
 		/* reschedule all the connections that stalled with ENOMEM... */
 		nenomem_conns = 0;
-		while (!list_empty (&enomem_conns)) {
+		while (!list_empty(&enomem_conns)) {
 			conn = list_entry(enomem_conns.next, ksock_conn_t,
 					  ksnc_tx_list);
-			list_del (&conn->ksnc_tx_list);
+			list_del(&conn->ksnc_tx_list);
 
 			sched = conn->ksnc_scheduler;
 
@@ -2645,7 +2643,7 @@ ksocknal_reaper (void *arg)
 				chunk = 1;
 
 			for (i = 0; i < chunk; i++) {
-				ksocknal_check_peer_timeouts (peer_index);
+				ksocknal_check_peer_timeouts(peer_index);
 				peer_index = (peer_index + 1) %
 					     ksocknal_data.ksnd_peer_hash_size;
 			}
@@ -2664,16 +2662,16 @@ ksocknal_reaper (void *arg)
 		ksocknal_data.ksnd_reaper_waketime =
 			cfs_time_add(cfs_time_current(), timeout);
 
-		set_current_state (TASK_INTERRUPTIBLE);
-		add_wait_queue (&ksocknal_data.ksnd_reaper_waitq, &wait);
+		set_current_state(TASK_INTERRUPTIBLE);
+		add_wait_queue(&ksocknal_data.ksnd_reaper_waitq, &wait);
 
 		if (!ksocknal_data.ksnd_shuttingdown &&
-		    list_empty (&ksocknal_data.ksnd_deathrow_conns) &&
-		    list_empty (&ksocknal_data.ksnd_zombie_conns))
+		    list_empty(&ksocknal_data.ksnd_deathrow_conns) &&
+		    list_empty(&ksocknal_data.ksnd_zombie_conns))
 			schedule_timeout(timeout);
 
-		set_current_state (TASK_RUNNING);
-		remove_wait_queue (&ksocknal_data.ksnd_reaper_waitq, &wait);
+		set_current_state(TASK_RUNNING);
+		remove_wait_queue(&ksocknal_data.ksnd_reaper_waitq, &wait);
 
 		spin_lock_bh(&ksocknal_data.ksnd_reaper_lock);
 	}
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index c59ddc2..f84d1ae 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -472,9 +472,9 @@ ksocknal_send_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 	 * Re-organize V2.x message header to V1.x (lnet_hdr_t)
 	 * header and send out
 	 */
-	hmv->magic         = cpu_to_le32 (LNET_PROTO_TCP_MAGIC);
-	hmv->version_major = cpu_to_le16 (KSOCK_PROTO_V1_MAJOR);
-	hmv->version_minor = cpu_to_le16 (KSOCK_PROTO_V1_MINOR);
+	hmv->magic         = cpu_to_le32(LNET_PROTO_TCP_MAGIC);
+	hmv->version_major = cpu_to_le16(KSOCK_PROTO_V1_MAJOR);
+	hmv->version_minor = cpu_to_le16(KSOCK_PROTO_V1_MINOR);
 
 	if (the_lnet.ln_testprotocompat != 0) {
 		/* single-shot proto check */
@@ -490,12 +490,12 @@ ksocknal_send_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 		LNET_UNLOCK();
 	}
 
-	hdr->src_nid = cpu_to_le64 (hello->kshm_src_nid);
-	hdr->src_pid = cpu_to_le32 (hello->kshm_src_pid);
-	hdr->type = cpu_to_le32 (LNET_MSG_HELLO);
-	hdr->payload_length = cpu_to_le32 (hello->kshm_nips * sizeof(__u32));
-	hdr->msg.hello.type = cpu_to_le32 (hello->kshm_ctype);
-	hdr->msg.hello.incarnation = cpu_to_le64 (hello->kshm_src_incarnation);
+	hdr->src_nid = cpu_to_le64(hello->kshm_src_nid);
+	hdr->src_pid = cpu_to_le32(hello->kshm_src_pid);
+	hdr->type = cpu_to_le32(LNET_MSG_HELLO);
+	hdr->payload_length = cpu_to_le32(hello->kshm_nips * sizeof(__u32));
+	hdr->msg.hello.type = cpu_to_le32(hello->kshm_ctype);
+	hdr->msg.hello.incarnation = cpu_to_le64(hello->kshm_src_incarnation);
 
 	rc = lnet_sock_write(sock, hdr, sizeof(*hdr), lnet_acceptor_timeout());
 	if (rc != 0) {
@@ -508,7 +508,7 @@ ksocknal_send_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 		goto out;
 
 	for (i = 0; i < (int) hello->kshm_nips; i++) {
-		hello->kshm_ips[i] = __cpu_to_le32 (hello->kshm_ips[i]);
+		hello->kshm_ips[i] = __cpu_to_le32(hello->kshm_ips[i]);
 	}
 
 	rc = lnet_sock_write(sock, hello->kshm_ips,
@@ -593,7 +593,7 @@ ksocknal_recv_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello,
 	}
 
 	/* ...and check we got what we expected */
-	if (hdr->type != cpu_to_le32 (LNET_MSG_HELLO)) {
+	if (hdr->type != cpu_to_le32(LNET_MSG_HELLO)) {
 		CERROR("Expecting a HELLO hdr, but got type %d from %pI4h\n",
 		       le32_to_cpu(hdr->type),
 		       &conn->ksnc_ipaddr);
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index f7ccaeb..5651b08 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -176,7 +176,7 @@ lstcon_trans_stat(void)
 }
 
 static inline struct list_head *
-lstcon_id2hash (lnet_process_id_t id, struct list_head *hash)
+lstcon_id2hash(lnet_process_id_t id, struct list_head *hash)
 {
 	unsigned int idx = LNET_NIDADDR(id.nid) % LST_NODE_HASHSIZE;
 
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 5781f77..5c299d6 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -94,11 +94,11 @@ struct sfw_test_instance;
 #define SRPC_RDMA_PORTAL              52
 
 static inline srpc_msg_type_t
-srpc_service2request (int service)
+srpc_service2request(int service)
 {
 	switch (service) {
 	default:
-		LBUG ();
+		LBUG();
 	case SRPC_SERVICE_DEBUG:
 		return SRPC_MSG_DEBUG_REQST;
 
@@ -129,7 +129,7 @@ srpc_service2request (int service)
 }
 
 static inline srpc_msg_type_t
-srpc_service2reply (int service)
+srpc_service2reply(int service)
 {
 	return srpc_service2request(service) + 1;
 }
@@ -427,7 +427,7 @@ void sfw_free_pages(struct srpc_server_rpc *rpc);
 void sfw_add_bulk_page(srpc_bulk_t *bk, struct page *pg, int i);
 int sfw_alloc_pages(struct srpc_server_rpc *rpc, int cpt, int npages, int len,
 		    int sink);
-int sfw_make_session (srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply);
+int sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply);
 
 srpc_client_rpc_t *
 srpc_create_client_rpc(lnet_process_id_t peer, int service,
@@ -502,7 +502,7 @@ void sfw_shutdown(void);
 void srpc_shutdown(void);
 
 static inline void
-srpc_destroy_client_rpc (srpc_client_rpc_t *rpc)
+srpc_destroy_client_rpc(srpc_client_rpc_t *rpc)
 {
 	LASSERT(rpc != NULL);
 	LASSERT(!srpc_event_pending(rpc));
@@ -518,10 +518,10 @@ srpc_destroy_client_rpc (srpc_client_rpc_t *rpc)
 }
 
 static inline void
-srpc_init_client_rpc (srpc_client_rpc_t *rpc, lnet_process_id_t peer,
-		      int service, int nbulkiov, int bulklen,
-		      void (*rpc_done)(srpc_client_rpc_t *),
-		      void (*rpc_fini)(srpc_client_rpc_t *), void *priv)
+srpc_init_client_rpc(srpc_client_rpc_t *rpc, lnet_process_id_t peer,
+		     int service, int nbulkiov, int bulklen,
+		     void (*rpc_done)(srpc_client_rpc_t *),
+		     void (*rpc_fini)(srpc_client_rpc_t *), void *priv)
 {
 	LASSERT(nbulkiov <= LNET_MAX_IOV);
 
@@ -557,7 +557,7 @@ srpc_init_client_rpc (srpc_client_rpc_t *rpc, lnet_process_id_t peer,
 }
 
 static inline const char *
-swi_state2str (int state)
+swi_state2str(int state)
 {
 #define STATE2STR(x) case x: return #x
 	switch (state) {
@@ -604,9 +604,9 @@ srpc_wait_service_shutdown(srpc_service_t *sv)
 
 	while (srpc_finish_service(sv) == 0) {
 		i++;
-		CDEBUG (((i & -i) == i) ? D_WARNING : D_NET,
-			"Waiting for %s service to shutdown...\n",
-			sv->sv_name);
+		CDEBUG(((i & -i) == i) ? D_WARNING : D_NET,
+		       "Waiting for %s service to shutdown...\n",
+		       sv->sv_name);
 		selftest_wait_events();
 	}
 }
-- 
1.7.1
