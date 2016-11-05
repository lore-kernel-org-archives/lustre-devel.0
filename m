From: Nicholas Hanley <nicholasjhanley@gmail.com>
Date: Sat, 05 Nov 2016 00:03:18 -0000
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: replace space
	indentation with tabs
Message-ID: <20161105000256.11714-1-nicholasjhanley@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jsimmons@infradead.org
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Nicholas Hanley <nicholasjhanley@gmail.com>

This patch fixes all CODE_INDENT checkpatch errors in o2iblnd.

Signed-off-by: Nicholas Hanley <nicholasjhanley@gmail.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 22 +++++++++++-----------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 9e88021..13235b0 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1637,7 +1637,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 {
 	__u64 *pages = tx->tx_pages;
 	bool is_rx = (rd != tx->tx_rd);
-        bool tx_pages_mapped = 0;
+	bool tx_pages_mapped = 0;
 	struct kib_fmr_pool *fpo;
 	int npages = 0;
 	__u64 version;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index b27de88..92692a2 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1912,12 +1912,12 @@ kiblnd_close_conn_locked(struct kib_conn *conn, int error)
 		       libcfs_nid2str(peer->ibp_nid));
 	} else {
 		CNETERR("Closing conn to %s: error %d%s%s%s%s%s\n",
-		        libcfs_nid2str(peer->ibp_nid), error,
-		        list_empty(&conn->ibc_tx_queue) ? "" : "(sending)",
-		        list_empty(&conn->ibc_tx_noops) ? "" : "(sending_noops)",
-		        list_empty(&conn->ibc_tx_queue_rsrvd) ? "" : "(sending_rsrvd)",
-		        list_empty(&conn->ibc_tx_queue_nocred) ? "" : "(sending_nocred)",
-		        list_empty(&conn->ibc_active_txs) ? "" : "(waiting)");
+			libcfs_nid2str(peer->ibp_nid), error,
+			list_empty(&conn->ibc_tx_queue) ? "" : "(sending)",
+			list_empty(&conn->ibc_tx_noops) ? "" : "(sending_noops)",
+			list_empty(&conn->ibc_tx_queue_rsrvd) ? "" : "(sending_rsrvd)",
+			list_empty(&conn->ibc_tx_queue_nocred) ? "" : "(sending_nocred)",
+			list_empty(&conn->ibc_active_txs) ? "" : "(waiting)");
 	}
 
 	dev = ((struct kib_net *)peer->ibp_ni->ni_data)->ibn_dev;
@@ -2643,7 +2643,7 @@ kiblnd_check_reconnect(struct kib_conn *conn, int version,
 	if (incarnation)
 		peer->ibp_incarnation = incarnation;
 out:
-        write_unlock_irqrestore(glock, flags);
+	write_unlock_irqrestore(glock, flags);
 
 	CNETERR("%s: %s (%s), %x, %x, msg_size: %d, queue_depth: %d/%d, max_frags: %d/%d\n",
 		libcfs_nid2str(peer->ibp_nid),
@@ -2651,7 +2651,7 @@ kiblnd_check_reconnect(struct kib_conn *conn, int version,
 		reason, IBLND_MSG_VERSION, version, msg_size,
 		conn->ibc_queue_depth, queue_dep,
 		conn->ibc_max_frags, frag_num);
-        /**
+	/**
 	 * if conn::ibc_reconnect is TRUE, connd will reconnect to the peer
 	 * while destroying the zombie
 	 */
@@ -2976,7 +2976,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 	case RDMA_CM_EVENT_ADDR_ERROR:
 		peer = (struct kib_peer *)cmid->context;
 		CNETERR("%s: ADDR ERROR %d\n",
-		        libcfs_nid2str(peer->ibp_nid), event->status);
+			libcfs_nid2str(peer->ibp_nid), event->status);
 		kiblnd_peer_connect_failed(peer, 1, -EHOSTUNREACH);
 		kiblnd_peer_decref(peer);
 		return -EHOSTUNREACH;      /* rc destroys cmid */
@@ -3021,7 +3021,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 			return kiblnd_active_connect(cmid);
 
 		CNETERR("Can't resolve route for %s: %d\n",
-		        libcfs_nid2str(peer->ibp_nid), event->status);
+			libcfs_nid2str(peer->ibp_nid), event->status);
 		kiblnd_peer_connect_failed(peer, 1, event->status);
 		kiblnd_peer_decref(peer);
 		return event->status;	   /* rc destroys cmid */
@@ -3031,7 +3031,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		LASSERT(conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT ||
 			conn->ibc_state == IBLND_CONN_PASSIVE_WAIT);
 		CNETERR("%s: UNREACHABLE %d\n",
-		        libcfs_nid2str(conn->ibc_peer->ibp_nid), event->status);
+			libcfs_nid2str(conn->ibc_peer->ibp_nid), event->status);
 		kiblnd_connreq_done(conn, -ENETDOWN);
 		kiblnd_conn_decref(conn);
 		return 0;
-- 
2.10.1
