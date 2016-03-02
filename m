From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:02:01 -0500
Subject: [lustre-devel] [PATCH 18/27] staging: lustre: make o2iblnd_cb.c
	local functions static
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Frank Zago <fzago@cray.com>

From: Frank Zago <fzago@cray.com>

This reduces the code size by about 1KiB.

Signed-off-by: Frank Zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5396
Reviewed-on: http://review.whamcloud.com/11256
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   10 --------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   25 +++++++++++++------
 2 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 4f09776..4fe38cb 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -939,30 +939,20 @@ int  kiblnd_create_peer(lnet_ni_t *ni, kib_peer_t **peerp, lnet_nid_t nid);
 void kiblnd_destroy_peer(kib_peer_t *peer);
 void kiblnd_destroy_dev(kib_dev_t *dev);
 void kiblnd_unlink_peer_locked(kib_peer_t *peer);
-void kiblnd_peer_alive(kib_peer_t *peer);
 kib_peer_t *kiblnd_find_peer_locked(lnet_nid_t nid);
-void kiblnd_peer_connect_failed(kib_peer_t *peer, int active, int error);
 int  kiblnd_close_stale_conns_locked(kib_peer_t *peer,
 				     int version, __u64 incarnation);
 int  kiblnd_close_peer_conns_locked(kib_peer_t *peer, int why);
 
-void kiblnd_connreq_done(kib_conn_t *conn, int status);
 kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 			       int state, int version);
 void kiblnd_destroy_conn(kib_conn_t *conn);
 void kiblnd_close_conn(kib_conn_t *conn, int error);
 void kiblnd_close_conn_locked(kib_conn_t *conn, int error);
 
-int  kiblnd_init_rdma(kib_conn_t *conn, kib_tx_t *tx, int type,
-		      int nob, kib_rdma_desc_t *dstrd, __u64 dstcookie);
-
 void kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid);
-void kiblnd_queue_tx_locked(kib_tx_t *tx, kib_conn_t *conn);
-void kiblnd_queue_tx(kib_tx_t *tx, kib_conn_t *conn);
-void kiblnd_init_tx_msg(lnet_ni_t *ni, kib_tx_t *tx, int type, int body_nob);
 void kiblnd_txlist_done(lnet_ni_t *ni, struct list_head *txlist,
 			int status);
-void kiblnd_check_sends(kib_conn_t *conn);
 
 void kiblnd_qp_event(struct ib_event *event, void *arg);
 void kiblnd_cq_event(struct ib_event *event, void *arg);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index d955a66..11c0b49 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -40,6 +40,15 @@
 
 #include "o2iblnd.h"
 
+static void kiblnd_peer_alive(kib_peer_t *peer);
+static void kiblnd_peer_connect_failed(kib_peer_t *peer, int active, int error);
+static void kiblnd_check_sends(kib_conn_t *conn);
+static void kiblnd_init_tx_msg(lnet_ni_t *ni, kib_tx_t *tx,
+				int type, int body_nob);
+static int kiblnd_init_rdma(kib_conn_t *conn, kib_tx_t *tx, int type,
+			     int resid, kib_rdma_desc_t *dstrd, __u64 dstcookie);
+static void kiblnd_queue_tx_locked(kib_tx_t *tx, kib_conn_t *conn);
+static void kiblnd_queue_tx(kib_tx_t *tx, kib_conn_t *conn);
 static void kiblnd_unmap_tx(lnet_ni_t *ni, kib_tx_t *tx);
 
 static void
@@ -891,7 +900,7 @@ kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
 	return -EIO;
 }
 
-void
+static void
 kiblnd_check_sends(kib_conn_t *conn)
 {
 	int ver = conn->ibc_version;
@@ -1019,7 +1028,7 @@ kiblnd_tx_complete(kib_tx_t *tx, int status)
 	kiblnd_conn_decref(conn);	       /* ...until here */
 }
 
-void
+static void
 kiblnd_init_tx_msg(lnet_ni_t *ni, kib_tx_t *tx, int type, int body_nob)
 {
 	kib_hca_dev_t *hdev = tx->tx_pool->tpo_hdev;
@@ -1053,7 +1062,7 @@ kiblnd_init_tx_msg(lnet_ni_t *ni, kib_tx_t *tx, int type, int body_nob)
 	tx->tx_nwrq++;
 }
 
-int
+static int
 kiblnd_init_rdma(kib_conn_t *conn, kib_tx_t *tx, int type,
 		 int resid, kib_rdma_desc_t *dstrd, __u64 dstcookie)
 {
@@ -1137,7 +1146,7 @@ kiblnd_init_rdma(kib_conn_t *conn, kib_tx_t *tx, int type,
 	return rc;
 }
 
-void
+static void
 kiblnd_queue_tx_locked(kib_tx_t *tx, kib_conn_t *conn)
 {
 	struct list_head *q;
@@ -1192,7 +1201,7 @@ kiblnd_queue_tx_locked(kib_tx_t *tx, kib_conn_t *conn)
 	list_add_tail(&tx->tx_list, q);
 }
 
-void
+static void
 kiblnd_queue_tx(kib_tx_t *tx, kib_conn_t *conn)
 {
 	spin_lock(&conn->ibc_lock);
@@ -1792,7 +1801,7 @@ kiblnd_thread_fini(void)
 	atomic_dec(&kiblnd_data.kib_nthreads);
 }
 
-void
+static void
 kiblnd_peer_alive(kib_peer_t *peer)
 {
 	/* This is racy, but everyone's only writing cfs_time_current() */
@@ -1993,7 +2002,7 @@ kiblnd_finalise_conn(kib_conn_t *conn)
 	kiblnd_handle_early_rxs(conn);
 }
 
-void
+static void
 kiblnd_peer_connect_failed(kib_peer_t *peer, int active, int error)
 {
 	LIST_HEAD(zombies);
@@ -2047,7 +2056,7 @@ kiblnd_peer_connect_failed(kib_peer_t *peer, int active, int error)
 	kiblnd_txlist_done(peer->ibp_ni, &zombies, -EHOSTUNREACH);
 }
 
-void
+static void
 kiblnd_connreq_done(kib_conn_t *conn, int status)
 {
 	kib_peer_t *peer = conn->ibc_peer;
-- 
1.7.1
