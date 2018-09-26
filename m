From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:16 -0400
Subject: [lustre-devel] [PATCH 24/25] lustre: socklnd: propagate errors on
 send failure
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf.weber@hpe.com>

When an attempt to send a message fails, for example because no
connection could be established with the remote address, socklnd
drops the message. For a PUT or REPLY message with non-zero
payload, ksocknal_tx_done() calls lnet_finalize() with -EIO
as the error code. But for an ACK or GET message there is no
payload, and lnet_finalize() is called with 0 (no error) as the
error code. This leaves upper layers to rely on other means to
determine that sending the message did actually fail, and that
(for example) no REPLY will ever answer a failed GET.

Add an error code parameter to ksocknal_tx_done().

In ksocknal_txlist_done() change the 0/1 'error' indicator to be
an actual error code that is passed on the ksocknal_tx_done().
Update the callers of ksocknal_txlist_done() to pass in the error
code if they have encountered an error.

Signed-off-by: Olaf Weber <olaf.weber@hpe.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9119
Reviewed-on: https://review.whamcloud.com/26691
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c    | 11 +++++++++--
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h    |  4 ++--
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 15 +++++++--------
 3 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 1a49f5e..b2f0148 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -607,7 +607,7 @@ struct ksock_peer *
 
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
-	ksocknal_txlist_done(ni, &zombies, 1);
+	ksocknal_txlist_done(ni, &zombies, -ENETDOWN);
 
 	return rc;
 }
@@ -1023,6 +1023,7 @@ struct ksock_peer *
 	int cpt;
 	struct ksock_tx *tx;
 	struct ksock_tx *txtmp;
+	int rc2;
 	int rc;
 	int active;
 	char *warn = NULL;
@@ -1406,7 +1407,13 @@ struct ksock_peer *
 		write_unlock_bh(global_lock);
 	}
 
-	ksocknal_txlist_done(ni, &zombies, 1);
+	/*
+	 * If we get here without an error code, just use -EALREADY.
+	 * Depending on how we got here, the error may be positive
+	 * or negative. Normalize the value for ksocknal_txlist_done().
+	 */
+	rc2 = (rc == 0 ? -EALREADY : (rc > 0 ? -rc : rc));
+	ksocknal_txlist_done(ni, &zombies, rc2);
 	ksocknal_peer_decref(peer_ni);
 
 failed_1:
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 95ca2aa..82e3523 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -582,14 +582,14 @@ struct ksock_proto {
 }
 
 void ksocknal_tx_prep(struct ksock_conn *, struct ksock_tx *tx);
-void ksocknal_tx_done(struct lnet_ni *ni, struct ksock_tx *tx);
+void ksocknal_tx_done(struct lnet_ni *ni, struct ksock_tx *tx, int error);
 
 static inline void
 ksocknal_tx_decref(struct ksock_tx *tx)
 {
 	LASSERT(atomic_read(&tx->tx_refcount) > 0);
 	if (atomic_dec_and_test(&tx->tx_refcount))
-		ksocknal_tx_done(NULL, tx);
+		ksocknal_tx_done(NULL, tx, 0);
 }
 
 static inline void
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 73321a7..dc9a129 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -328,19 +328,18 @@ struct ksock_tx *
 }
 
 void
-ksocknal_tx_done(struct lnet_ni *ni, struct ksock_tx *tx)
+ksocknal_tx_done(struct lnet_ni *ni, struct ksock_tx *tx, int rc)
 {
 	struct lnet_msg *lnetmsg = tx->tx_lnetmsg;
-	int rc = (!tx->tx_resid && !tx->tx_zc_aborted) ? 0 : -EIO;
 
 	LASSERT(ni || tx->tx_conn);
 
+	if (!rc && (tx->tx_resid != 0 || tx->tx_zc_aborted))
+		rc = -EIO;
+
 	if (tx->tx_conn)
 		ksocknal_conn_decref(tx->tx_conn);
 
-	if (!ni && tx->tx_conn)
-		ni = tx->tx_conn->ksnc_peer->ksnp_ni;
-
 	ksocknal_free_tx(tx);
 	if (lnetmsg) /* KSOCK_MSG_NOOP go without lnetmsg */
 		lnet_finalize(lnetmsg, rc);
@@ -367,7 +366,7 @@ struct ksock_tx *
 		list_del(&tx->tx_list);
 
 		LASSERT(atomic_read(&tx->tx_refcount) == 1);
-		ksocknal_tx_done(ni, tx);
+		ksocknal_tx_done(ni, tx, error);
 	}
 }
 
@@ -1923,7 +1922,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
 	ksocknal_peer_failed(peer_ni);
-	ksocknal_txlist_done(peer_ni->ksnp_ni, &zombies, 1);
+	ksocknal_txlist_done(peer_ni->ksnp_ni, &zombies, rc);
 	return 0;
 }
 
@@ -2268,7 +2267,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
-	ksocknal_txlist_done(peer_ni->ksnp_ni, &stale_txs, 1);
+	ksocknal_txlist_done(peer_ni->ksnp_ni, &stale_txs, -ETIMEDOUT);
 }
 
 static int
-- 
1.8.3.1
