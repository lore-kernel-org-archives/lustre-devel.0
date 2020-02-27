From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:09 -0500
Subject: [lustre-devel] [PATCH 081/622] lnet: handle socklnd tx failure
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-82-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Update the socklnd to propagate the health status up to
LNet for handling.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 25c1cb2c4d6f ("LU-9120 lnet: handle socklnd tx failure")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32766
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.h    |  1 +
 net/lnet/klnds/socklnd/socklnd_cb.c | 49 ++++++++++++++++++++++++++++++++++---
 2 files changed, 47 insertions(+), 3 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 04381a0..48884cf 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -289,6 +289,7 @@ struct ksock_tx {				/* transmit packet */
 	time64_t		tx_deadline;	/* when (in secs) tx times out */
 	struct ksock_msg	tx_msg;		/* socklnd message buffer */
 	int			tx_desc_size;	/* size of this descriptor */
+	enum lnet_msg_hstatus	tx_hstatus;	/* health status of tx */
 	union {
 		struct {
 			struct kvec	iov;	/* virt hdr */
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 5b75ea6..d50e0d2 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -56,6 +56,7 @@ struct ksock_tx *
 	tx->tx_zc_aborted = 0;
 	tx->tx_zc_capable = 0;
 	tx->tx_zc_checked = 0;
+	tx->tx_hstatus = LNET_MSG_STATUS_OK;
 	tx->tx_desc_size = size;
 
 	atomic_inc(&ksocknal_data.ksnd_nactive_txs);
@@ -328,18 +329,26 @@ struct ksock_tx *
 ksocknal_tx_done(struct lnet_ni *ni, struct ksock_tx *tx, int rc)
 {
 	struct lnet_msg *lnetmsg = tx->tx_lnetmsg;
+	enum lnet_msg_hstatus hstatus = tx->tx_hstatus;
 
 	LASSERT(ni || tx->tx_conn);
 
-	if (!rc && (tx->tx_resid != 0 || tx->tx_zc_aborted))
+	if (!rc && (tx->tx_resid != 0 || tx->tx_zc_aborted)) {
 		rc = -EIO;
+		hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
+	}
 
 	if (tx->tx_conn)
 		ksocknal_conn_decref(tx->tx_conn);
 
 	ksocknal_free_tx(tx);
-	if (lnetmsg) /* KSOCK_MSG_NOOP go without lnetmsg */
+	if (lnetmsg) { /* KSOCK_MSG_NOOP go without lnetmsg */
+		if (rc)
+			CERROR("tx failure rc = %d, hstatus = %d\n", rc,
+			       hstatus);
+		lnetmsg->msg_health_status = hstatus;
 		lnet_finalize(lnetmsg, rc);
+	}
 }
 
 void
@@ -362,6 +371,20 @@ struct ksock_tx *
 
 		list_del(&tx->tx_list);
 
+		if (tx->tx_hstatus == LNET_MSG_STATUS_OK) {
+			if (error == -ETIMEDOUT)
+				tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_TIMEOUT;
+			else if (error == -ENETDOWN ||
+				 error == -EHOSTUNREACH ||
+				 error == -ENETUNREACH)
+				tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_DROPPED;
+			/* for all other errors we don't want to
+			 * retransmit
+			 */
+			else if (error)
+				tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
+		}
+
 		LASSERT(atomic_read(&tx->tx_refcount) == 1);
 		ksocknal_tx_done(ni, tx, error);
 	}
@@ -481,12 +504,25 @@ struct ksock_tx *
 			wake_up(&ksocknal_data.ksnd_reaper_waitq);
 
 		spin_unlock_bh(&ksocknal_data.ksnd_reaper_lock);
+
+		/* set the health status of the message which determines
+		 * whether we should retry the transmit
+		 */
+		tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
 		return rc;
 	}
 
 	/* Actual error */
 	LASSERT(rc < 0);
 
+	/* set the health status of the message which determines
+	 * whether we should retry the transmit
+	 */
+	if (rc == -ETIMEDOUT)
+		tx->tx_hstatus = LNET_MSG_STATUS_REMOTE_TIMEOUT;
+	else
+		tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
+
 	if (!conn->ksnc_closing) {
 		switch (rc) {
 		case -ECONNRESET:
@@ -509,7 +545,7 @@ struct ksock_tx *
 		ksocknal_uncheck_zc_req(tx);
 
 	/* it's not an error if conn is being closed */
-	ksocknal_close_conn_and_siblings(conn, (conn->ksnc_closing) ? 0 : rc);
+	ksocknal_close_conn_and_siblings(conn, conn->ksnc_closing ? 0 : rc);
 
 	return rc;
 }
@@ -2167,6 +2203,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 {
 	/* We're called with a shared lock on ksnd_global_lock */
 	struct ksock_conn *conn;
+	struct ksock_tx *tx;
 
 	list_for_each_entry(conn, &peer_ni->ksnp_conns, ksnc_list) {
 		int error;
@@ -2229,6 +2266,10 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			 * buffered in the socket's send buffer
 			 */
 			ksocknal_conn_addref(conn);
+			list_for_each_entry(tx, &conn->ksnc_tx_queue,
+					    tx_list)
+				tx->tx_hstatus =
+					LNET_MSG_STATUS_LOCAL_TIMEOUT;
 			CNETERR("Timeout sending data to %s (%pI4h:%d) the network or that node may be down.\n",
 				libcfs_id2str(peer_ni->ksnp_id),
 				&conn->ksnc_ipaddr,
@@ -2255,6 +2296,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		if (ktime_get_seconds() < tx->tx_deadline)
 			break;
 
+		tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_TIMEOUT;
+
 		list_del(&tx->tx_list);
 		list_add_tail(&tx->tx_list, &stale_txs);
 	}
-- 
1.8.3.1
