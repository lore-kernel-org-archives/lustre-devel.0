From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:02:05 -0500
Subject: [lustre-devel] [PATCH 22/27] staging: lustre: make ko2iblnd connect
	parameters persistent
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>

From: Amir Shehata <amir.shehata@intel.com>

Store map-on-demand and peertx credits in the peer, since the peer
is persistent. Also made sure that when assigning the parameters
received on the connection to the peer structure through create,
that if another peer is added before grabbing the lock we assign
these parameters to it as well.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3322
Reviewed-on: http://review.whamcloud.com/17074
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   14 +++-----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    6 +++-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   38 ++++++++++++++------
 3 files changed, 37 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 0b1ffbe..56c221b 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -335,6 +335,8 @@ int kiblnd_create_peer(lnet_ni_t *ni, kib_peer_t **peerp, lnet_nid_t nid)
 	peer->ibp_nid = nid;
 	peer->ibp_error = 0;
 	peer->ibp_last_alive = 0;
+	peer->ibp_max_frags = IBLND_CFG_RDMA_FRAGS;
+	peer->ibp_queue_depth = *kiblnd_tunables.kib_peertxcredits;
 	atomic_set(&peer->ibp_refcount, 1);  /* 1 ref for caller */
 
 	INIT_LIST_HEAD(&peer->ibp_list);     /* not in the peer table yet */
@@ -631,7 +633,7 @@ static int kiblnd_get_completion_vector(kib_conn_t *conn, int cpt)
 }
 
 kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
-			       int state, int version, kib_connparams_t *cp)
+			       int state, int version)
 {
 	/*
 	 * CAVEAT EMPTOR:
@@ -685,14 +687,8 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 	conn->ibc_peer = peer;		  /* I take the caller's ref */
 	cmid->context = conn;		   /* for future CM callbacks */
 	conn->ibc_cmid = cmid;
-
-	if (!cp) {
-		conn->ibc_max_frags = IBLND_CFG_RDMA_FRAGS;
-		conn->ibc_queue_depth = *kiblnd_tunables.kib_peertxcredits;
-	} else {
-		conn->ibc_max_frags = cp->ibcp_max_frags;
-		conn->ibc_queue_depth = cp->ibcp_queue_depth;
-	}
+	conn->ibc_max_frags = peer->ibp_max_frags;
+	conn->ibc_queue_depth = peer->ibp_queue_depth;
 
 	INIT_LIST_HEAD(&conn->ibc_early_rxs);
 	INIT_LIST_HEAD(&conn->ibc_tx_noops);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 59a26c4..3db1413 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -586,6 +586,10 @@ typedef struct kib_peer {
 	int              ibp_error;       /* errno on closing this peer */
 	unsigned long    ibp_last_alive;  /* when (in jiffies) I was last alive
 					   */
+	/* max map_on_demand */
+	__u16		 ibp_max_frags;
+	/* max_peer_credits */
+	__u16		 ibp_queue_depth;
 } kib_peer_t;
 
 extern kib_data_t kiblnd_data;
@@ -946,7 +950,7 @@ int  kiblnd_close_stale_conns_locked(kib_peer_t *peer,
 int  kiblnd_close_peer_conns_locked(kib_peer_t *peer, int why);
 
 kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
-			       int state, int version, kib_connparams_t *cp);
+			       int state, int version);
 void kiblnd_destroy_conn(kib_conn_t *conn);
 void kiblnd_close_conn(kib_conn_t *conn, int error);
 void kiblnd_close_conn_locked(kib_conn_t *conn, int error);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 22420c0..fb3873a 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2323,6 +2323,10 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		goto failed;
 	}
 
+	/* We have validated the peer's parameters so use those */
+	peer->ibp_max_frags = reqmsg->ibm_u.connparams.ibcp_max_frags;
+	peer->ibp_queue_depth = reqmsg->ibm_u.connparams.ibcp_queue_depth;
+
 	write_lock_irqsave(g_lock, flags);
 
 	peer2 = kiblnd_find_peer_locked(nid);
@@ -2361,6 +2365,14 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		peer2->ibp_accepting++;
 		kiblnd_peer_addref(peer2);
 
+		/**
+		 * Race with kiblnd_launch_tx (active connect) to create peer
+		 * so copy validated parameters since we now know what the
+		 * peer's limits are
+		 */
+		peer2->ibp_max_frags = peer->ibp_max_frags;
+		peer2->ibp_queue_depth = peer->ibp_queue_depth;
+
 		write_unlock_irqrestore(g_lock, flags);
 		kiblnd_peer_decref(peer);
 		peer = peer2;
@@ -2383,8 +2395,8 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		write_unlock_irqrestore(g_lock, flags);
 	}
 
-	conn = kiblnd_create_conn(peer, cmid, IBLND_CONN_PASSIVE_WAIT, version,
-				  &reqmsg->ibm_u.connparams);
+	conn = kiblnd_create_conn(peer, cmid, IBLND_CONN_PASSIVE_WAIT,
+				  version);
 	if (!conn) {
 		kiblnd_peer_connect_failed(peer, 0, -ENOMEM);
 		kiblnd_peer_decref(peer);
@@ -2397,8 +2409,8 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	 * CM callback doesn't destroy cmid.
 	 */
 	conn->ibc_incarnation      = reqmsg->ibm_srcstamp;
-	conn->ibc_credits          = reqmsg->ibm_u.connparams.ibcp_queue_depth;
-	conn->ibc_reserved_credits = reqmsg->ibm_u.connparams.ibcp_queue_depth;
+	conn->ibc_credits          = conn->ibc_queue_depth;
+	conn->ibc_reserved_credits = conn->ibc_queue_depth;
 	LASSERT(conn->ibc_credits + conn->ibc_reserved_credits +
 		IBLND_OOB_MSGS(version) <= IBLND_RX_MSGS(conn));
 
@@ -2407,10 +2419,8 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 
 	kiblnd_init_msg(ackmsg, IBLND_MSG_CONNACK,
 			sizeof(ackmsg->ibm_u.connparams));
-	ackmsg->ibm_u.connparams.ibcp_queue_depth =
-		reqmsg->ibm_u.connparams.ibcp_queue_depth;
-	ackmsg->ibm_u.connparams.ibcp_max_frags =
-		reqmsg->ibm_u.connparams.ibcp_max_frags;
+	ackmsg->ibm_u.connparams.ibcp_queue_depth = conn->ibc_queue_depth;
+	ackmsg->ibm_u.connparams.ibcp_max_frags = conn->ibc_max_frags;
 	ackmsg->ibm_u.connparams.ibcp_max_msg_size = IBLND_MSG_SIZE;
 
 	kiblnd_pack_msg(ni, ackmsg, version, 0, nid, reqmsg->ibm_srcstamp);
@@ -2495,6 +2505,9 @@ kiblnd_reconnect(kib_conn_t *conn, int version,
 		break;
 
 	case IBLND_REJECT_RDMA_FRAGS:
+		if (!cp)
+			goto failed;
+
 		if (conn->ibc_max_frags <= cp->ibcp_max_frags) {
 			CNETERR("Unsupported max frags, peer supports %d\n",
 				cp->ibcp_max_frags);
@@ -2504,18 +2517,21 @@ kiblnd_reconnect(kib_conn_t *conn, int version,
 			goto failed;
 		}
 
-		conn->ibc_max_frags = cp->ibcp_max_frags;
+		peer->ibp_max_frags = cp->ibcp_max_frags;
 		reason = "rdma fragments";
 		break;
 
 	case IBLND_REJECT_MSG_QUEUE_SIZE:
+		if (!cp)
+			goto failed;
+
 		if (conn->ibc_queue_depth <= cp->ibcp_queue_depth) {
 			CNETERR("Unsupported queue depth, peer supports %d\n",
 				cp->ibcp_queue_depth);
 			goto failed;
 		}
 
-		conn->ibc_queue_depth = cp->ibcp_queue_depth;
+		peer->ibp_queue_depth = cp->ibcp_queue_depth;
 		reason = "queue depth";
 		break;
 
@@ -2796,7 +2812,7 @@ kiblnd_active_connect(struct rdma_cm_id *cmid)
 	read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
 	conn = kiblnd_create_conn(peer, cmid, IBLND_CONN_ACTIVE_CONNECT,
-				  version, NULL);
+				  version);
 	if (!conn) {
 		kiblnd_peer_connect_failed(peer, 1, -ENOMEM);
 		kiblnd_peer_decref(peer); /* lose cmid's ref */
-- 
1.7.1
