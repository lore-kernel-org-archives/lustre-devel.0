From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:08 -0500
Subject: [lustre-devel] [PATCH 080/622] lnet: handle o2iblnd tx failure
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-81-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Monitor the different types of failures that might occur on the
transmit and flag the type of failure to be propagated to LNet
which will handle either by attempting a resend or simply
finalizing the message and propagating a failure to the ULP.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 8cf835e425d8 ("LU-9120 lnet: handle o2iblnd tx failure")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32765
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c    |  2 +-
 net/lnet/klnds/o2iblnd/o2iblnd.h    |  4 ++-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 59 ++++++++++++++++++++++++++++++++-----
 3 files changed, 55 insertions(+), 10 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 825fe30..017fe5f 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -519,7 +519,7 @@ static int kiblnd_del_peer(struct lnet_ni *ni, lnet_nid_t nid)
 
 	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
-	kiblnd_txlist_done(&zombies, -EIO);
+	kiblnd_txlist_done(&zombies, -EIO, LNET_MSG_STATUS_LOCAL_ERROR);
 
 	return rc;
 }
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 9021051..999b58d 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -515,6 +515,7 @@ struct kib_tx {					/* transmit message */
 	short			tx_queued;	/* queued for sending */
 	short			tx_waiting;	/* waiting for peer_ni */
 	int			tx_status;	/* LNET completion status */
+	enum lnet_msg_hstatus	tx_hstatus;	/* health status of the transmit */
 	ktime_t			tx_deadline;	/* completion deadline */
 	u64			tx_cookie;	/* completion cookie */
 	struct lnet_msg	       *tx_lntmsg[2];	/* lnet msgs to finalize on completion */
@@ -1027,7 +1028,8 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 void kiblnd_close_conn_locked(struct kib_conn *conn, int error);
 
 void kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid);
-void kiblnd_txlist_done(struct list_head *txlist, int status);
+void kiblnd_txlist_done(struct list_head *txlist, int status,
+			enum lnet_msg_hstatus hstatus);
 
 void kiblnd_qp_event(struct ib_event *event, void *arg);
 void kiblnd_cq_event(struct ib_event *event, void *arg);
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 60706b4..007058a 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -89,12 +89,17 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 		if (!lntmsg[i])
 			continue;
 
+		/* propagate health status to LNet for requests */
+		if (i == 0 && lntmsg[i])
+			lntmsg[i]->msg_health_status = tx->tx_hstatus;
+
 		lnet_finalize(lntmsg[i], rc);
 	}
 }
 
 void
-kiblnd_txlist_done(struct list_head *txlist, int status)
+kiblnd_txlist_done(struct list_head *txlist, int status,
+		   enum lnet_msg_hstatus hstatus)
 {
 	struct kib_tx *tx;
 
@@ -105,6 +110,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 		/* complete now */
 		tx->tx_waiting = 0;
 		tx->tx_status = status;
+		tx->tx_hstatus = hstatus;
 		kiblnd_tx_done(tx);
 	}
 }
@@ -134,6 +140,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	LASSERT(!tx->tx_nfrags);
 
 	tx->tx_gaps = false;
+	tx->tx_hstatus = LNET_MSG_STATUS_OK;
 
 	return tx;
 }
@@ -265,10 +272,12 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	}
 
 	if (!tx->tx_status) {		/* success so far */
-		if (status < 0) /* failed? */
+		if (status < 0) {	/* failed? */
 			tx->tx_status = status;
-		else if (txtype == IBLND_MSG_GET_REQ)
+			tx->tx_hstatus = LNET_MSG_STATUS_REMOTE_ERROR;
+		} else if (txtype == IBLND_MSG_GET_REQ) {
 			lnet_set_reply_msg_len(ni, tx->tx_lntmsg[1], status);
+		}
 	}
 
 	tx->tx_waiting = 0;
@@ -846,6 +855,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		 * posted NOOPs complete
 		 */
 		spin_unlock(&conn->ibc_lock);
+		tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
 		kiblnd_tx_done(tx);
 		spin_lock(&conn->ibc_lock);
 		CDEBUG(D_NET, "%s(%d): redundant or enough NOOP\n",
@@ -1045,6 +1055,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		conn->ibc_noops_posted--;
 
 	if (failed) {
+		tx->tx_hstatus = LNET_MSG_STATUS_REMOTE_DROPPED;
 		tx->tx_waiting = 0;	/* don't wait for peer_ni */
 		tx->tx_status = -EIO;
 	}
@@ -1393,7 +1404,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	CWARN("Abort reconnection of %s: %s\n",
 	      libcfs_nid2str(peer_ni->ibp_nid), reason);
-	kiblnd_txlist_done(&txs, -ECONNABORTED);
+	kiblnd_txlist_done(&txs, -ECONNABORTED,
+			   LNET_MSG_STATUS_LOCAL_ABORTED);
 	return false;
 }
 
@@ -1471,6 +1483,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		if (tx) {
 			tx->tx_status = -EHOSTUNREACH;
 			tx->tx_waiting = 0;
+			tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
 			kiblnd_tx_done(tx);
 		}
 		return;
@@ -1607,6 +1620,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		if (rc) {
 			CERROR("Can't setup GET sink for %s: %d\n",
 			       libcfs_nid2str(target.nid), rc);
+			tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
 			kiblnd_tx_done(tx);
 			return -EIO;
 		}
@@ -1757,6 +1771,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	return;
 
 failed_1:
+	tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
 	kiblnd_tx_done(tx);
 failed_0:
 	lnet_finalize(lntmsg, -EIO);
@@ -1839,6 +1854,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		if (rc) {
 			CERROR("Can't setup PUT sink for %s: %d\n",
 			       libcfs_nid2str(conn->ibc_peer->ibp_nid), rc);
+			tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
 			kiblnd_tx_done(tx);
 			/* tell peer_ni it's over */
 			kiblnd_send_completion(rx->rx_conn, IBLND_MSG_PUT_NAK,
@@ -2050,13 +2066,34 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		if (txs == &conn->ibc_active_txs) {
 			LASSERT(!tx->tx_queued);
 			LASSERT(tx->tx_waiting || tx->tx_sending);
+			if (conn->ibc_comms_error == -ETIMEDOUT) {
+				if (tx->tx_waiting && !tx->tx_sending)
+					tx->tx_hstatus =
+					  LNET_MSG_STATUS_REMOTE_TIMEOUT;
+				else if (tx->tx_sending)
+					tx->tx_hstatus =
+					  LNET_MSG_STATUS_NETWORK_TIMEOUT;
+			}
 		} else {
 			LASSERT(tx->tx_queued);
+			if (conn->ibc_comms_error == -ETIMEDOUT)
+				tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_TIMEOUT;
+			else
+				tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
 		}
 
 		tx->tx_status = -ECONNABORTED;
 		tx->tx_waiting = 0;
 
+		/* TODO: This makes an assumption that
+		 * kiblnd_tx_complete() will be called for each tx. If
+		 * that event is dropped we could end up with stale
+		 * connections floating around. We'd like to deal with
+		 * that in a better way.
+		 *
+		 * Also that means we can exceed the timeout by many
+		 * seconds.
+		 */
 		if (!tx->tx_sending) {
 			tx->tx_queued = 0;
 			list_del(&tx->tx_list);
@@ -2066,7 +2103,10 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	spin_unlock(&conn->ibc_lock);
 
-	kiblnd_txlist_done(&zombies, -ECONNABORTED);
+	/* aborting transmits occurs when finalizing the connection.
+	 * The connection is finalized on error
+	 */
+	kiblnd_txlist_done(&zombies, -ECONNABORTED, -1);
 }
 
 static void
@@ -2147,7 +2187,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	CNETERR("Deleting messages for %s: connection failed\n",
 		libcfs_nid2str(peer_ni->ibp_nid));
 
-	kiblnd_txlist_done(&zombies, -EHOSTUNREACH);
+	kiblnd_txlist_done(&zombies, error,
+			   LNET_MSG_STATUS_LOCAL_DROPPED);
 }
 
 static void
@@ -2223,7 +2264,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		kiblnd_close_conn_locked(conn, -ECONNABORTED);
 		write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
-		kiblnd_txlist_done(&txs, -ECONNABORTED);
+		kiblnd_txlist_done(&txs, -ECONNABORTED,
+				   LNET_MSG_STATUS_LOCAL_ERROR);
 
 		return;
 	}
@@ -3300,7 +3342,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
 	if (!list_empty(&timedout_txs))
-		kiblnd_txlist_done(&timedout_txs, -ETIMEDOUT);
+		kiblnd_txlist_done(&timedout_txs, -ETIMEDOUT,
+				   LNET_MSG_STATUS_LOCAL_TIMEOUT);
 
 	/*
 	 * Handle timeout by closing the whole
-- 
1.8.3.1
