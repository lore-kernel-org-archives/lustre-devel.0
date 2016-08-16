From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:32 -0400
Subject: [lustre-devel] [PATCH 79/80] staging: lustre: lnet: lock
	improvement for ko2iblnd
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-80-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>, Doug Oucharek <doug.s.oucharek@intel.com>, James Simmons <jsimmons@infradead.org>

From: Liang Zhen <liang.zhen@intel.com>

kiblnd_check_sends() takes conn::ibc_lock at the begin and release
this lock at the end, this is inefficient because most use-case
needs to explicitly release ibc_lock before caling this function.

This patches changes it to kiblnd_check_sends_locked() and avoid
unnecessary lock dances.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7099
Reviewed-on: http://review.whamcloud.com/20322
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   46 ++++++++------------
 1 files changed, 18 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 6cd78ea..6d1b14a 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -38,7 +38,6 @@
 
 static void kiblnd_peer_alive(struct kib_peer *peer);
 static void kiblnd_peer_connect_failed(struct kib_peer *peer, int active, int error);
-static void kiblnd_check_sends(struct kib_conn *conn);
 static void kiblnd_init_tx_msg(lnet_ni_t *ni, struct kib_tx *tx,
 				int type, int body_nob);
 static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
@@ -46,6 +45,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 static void kiblnd_queue_tx_locked(struct kib_tx *tx, struct kib_conn *conn);
 static void kiblnd_queue_tx(struct kib_tx *tx, struct kib_conn *conn);
 static void kiblnd_unmap_tx(lnet_ni_t *ni, struct kib_tx *tx);
+static void kiblnd_check_sends_locked(struct kib_conn *conn);
 
 static void
 kiblnd_tx_done(lnet_ni_t *ni, struct kib_tx *tx)
@@ -211,9 +211,9 @@ kiblnd_post_rx(struct kib_rx *rx, int credit)
 		conn->ibc_outstanding_credits++;
 	else
 		conn->ibc_reserved_credits++;
+	kiblnd_check_sends_locked(conn);
 	spin_unlock(&conn->ibc_lock);
 
-	kiblnd_check_sends(conn);
 out:
 	kiblnd_conn_decref(conn);
 	return rc;
@@ -344,8 +344,8 @@ kiblnd_handle_rx(struct kib_rx *rx)
 		    !IBLND_OOB_CAPABLE(conn->ibc_version)) /* v1 only */
 			conn->ibc_outstanding_credits++;
 
+		kiblnd_check_sends_locked(conn);
 		spin_unlock(&conn->ibc_lock);
-		kiblnd_check_sends(conn);
 	}
 
 	switch (msg->ibm_type) {
@@ -800,7 +800,7 @@ kiblnd_post_tx_locked(struct kib_conn *conn, struct kib_tx *tx, int credit)
 	      conn->ibc_noops_posted == IBLND_OOB_MSGS(ver)))) {
 		/*
 		 * OK to drop when posted enough NOOPs, since
-		 * kiblnd_check_sends will queue NOOP again when
+		 * kiblnd_check_sends_locked will queue NOOP again when
 		 * posted NOOPs complete
 		 */
 		spin_unlock(&conn->ibc_lock);
@@ -905,7 +905,7 @@ kiblnd_post_tx_locked(struct kib_conn *conn, struct kib_tx *tx, int credit)
 }
 
 static void
-kiblnd_check_sends(struct kib_conn *conn)
+kiblnd_check_sends_locked(struct kib_conn *conn)
 {
 	int ver = conn->ibc_version;
 	lnet_ni_t *ni = conn->ibc_peer->ibp_ni;
@@ -918,8 +918,6 @@ kiblnd_check_sends(struct kib_conn *conn)
 		return;
 	}
 
-	spin_lock(&conn->ibc_lock);
-
 	LASSERT(conn->ibc_nsends_posted <= kiblnd_concurrent_sends(ver, ni));
 	LASSERT(!IBLND_OOB_CAPABLE(ver) ||
 		conn->ibc_noops_posted <= IBLND_OOB_MSGS(ver));
@@ -969,8 +967,6 @@ kiblnd_check_sends(struct kib_conn *conn)
 		if (kiblnd_post_tx_locked(conn, tx, credit))
 			break;
 	}
-
-	spin_unlock(&conn->ibc_lock);
 }
 
 static void
@@ -1016,16 +1012,11 @@ kiblnd_tx_complete(struct kib_tx *tx, int status)
 	if (idle)
 		list_del(&tx->tx_list);
 
-	kiblnd_conn_addref(conn);	       /* 1 ref for me.... */
-
+	kiblnd_check_sends_locked(conn);
 	spin_unlock(&conn->ibc_lock);
 
 	if (idle)
 		kiblnd_tx_done(conn->ibc_peer->ibp_ni, tx);
-
-	kiblnd_check_sends(conn);
-
-	kiblnd_conn_decref(conn);	       /* ...until here */
 }
 
 static void
@@ -1204,9 +1195,8 @@ kiblnd_queue_tx(struct kib_tx *tx, struct kib_conn *conn)
 {
 	spin_lock(&conn->ibc_lock);
 	kiblnd_queue_tx_locked(tx, conn);
+	kiblnd_check_sends_locked(conn);
 	spin_unlock(&conn->ibc_lock);
-
-	kiblnd_check_sends(conn);
 }
 
 static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
@@ -2183,14 +2173,11 @@ kiblnd_connreq_done(struct kib_conn *conn, int status)
 		return;
 	}
 
-	/**
-	 * refcount taken by cmid is not reliable after I released the glock
-	 * because this connection is visible to other threads now, another
-	 * thread can find and close this connection right after I released
-	 * the glock, if kiblnd_cm_callback for RDMA_CM_EVENT_DISCONNECTED is
-	 * called, it can release the connection refcount taken by cmid.
-	 * It means the connection could be destroyed before I finish my
-	 * operations on it.
+	/*
+	 * +1 ref for myself, this connection is visible to other threads
+	 * now, refcount of peer:ibp_conns can be released by connection
+	 * close from either a different thread, or the calling of
+	 * kiblnd_check_sends_locked() below. See bz21911 for details.
 	 */
 	kiblnd_conn_addref(conn);
 	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
@@ -2202,10 +2189,9 @@ kiblnd_connreq_done(struct kib_conn *conn, int status)
 
 		kiblnd_queue_tx_locked(tx, conn);
 	}
+	kiblnd_check_sends_locked(conn);
 	spin_unlock(&conn->ibc_lock);
 
-	kiblnd_check_sends(conn);
-
 	/* schedule blocked rxs */
 	kiblnd_handle_early_rxs(conn);
 
@@ -3233,7 +3219,11 @@ kiblnd_check_conns(int idx)
 	 */
 	list_for_each_entry_safe(conn, temp, &checksends, ibc_connd_list) {
 		list_del(&conn->ibc_connd_list);
-		kiblnd_check_sends(conn);
+
+		spin_lock(&conn->ibc_lock);
+		kiblnd_check_sends_locked(conn);
+		spin_unlock(&conn->ibc_lock);
+
 		kiblnd_conn_decref(conn);
 	}
 }
-- 
1.7.1
