From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:02:09 -0500
Subject: [lustre-devel] [PATCH 26/27] staging: lustre: avoid intensive
	reconnecting for ko2iblnd
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

When there is a connection race between two nodes and one side
of the connection is rejected by the other side. o2iblnd will
reconnect immediately, this is going to generate a lot of
trashes if:

 - race winner is slow and can't send out connecting request
   in short time.
 - remote side leaves a cmid in TIMEWAIT state, which will reject
   future connection requests

To resolve this problem, this patch changed the reconnection
behave: reconnection is submitted by connd only if a zombie
connection is being destroyed and there is a pending
reconnection request for the corresponding peer.

Also, after a few rejections, reconnection will have a time
interval between each attempt.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7569
Reviewed-on: http://review.whamcloud.com/17892
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Tested-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   40 +--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   54 +++-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  280 ++++++++++++++------
 3 files changed, 258 insertions(+), 116 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 56c221b..135ccf1 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -364,9 +364,7 @@ void kiblnd_destroy_peer(kib_peer_t *peer)
 	LASSERT(net);
 	LASSERT(!atomic_read(&peer->ibp_refcount));
 	LASSERT(!kiblnd_peer_active(peer));
-	LASSERT(!peer->ibp_connecting);
-	LASSERT(!peer->ibp_accepting);
-	LASSERT(list_empty(&peer->ibp_conns));
+	LASSERT(kiblnd_peer_idle(peer));
 	LASSERT(list_empty(&peer->ibp_tx_queue));
 
 	LIBCFS_FREE(peer, sizeof(*peer));
@@ -392,10 +390,7 @@ kib_peer_t *kiblnd_find_peer_locked(lnet_nid_t nid)
 
 	list_for_each(tmp, peer_list) {
 		peer = list_entry(tmp, kib_peer_t, ibp_list);
-
-		LASSERT(peer->ibp_connecting > 0 || /* creating conns */
-			 peer->ibp_accepting > 0 ||
-			 !list_empty(&peer->ibp_conns));  /* active conn */
+		LASSERT(!kiblnd_peer_idle(peer));
 
 		if (peer->ibp_nid != nid)
 			continue;
@@ -432,9 +427,7 @@ static int kiblnd_get_peer_info(lnet_ni_t *ni, int index,
 	for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++) {
 		list_for_each(ptmp, &kiblnd_data.kib_peers[i]) {
 			peer = list_entry(ptmp, kib_peer_t, ibp_list);
-			LASSERT(peer->ibp_connecting > 0 ||
-				peer->ibp_accepting > 0 ||
-				!list_empty(&peer->ibp_conns));
+			LASSERT(!kiblnd_peer_idle(peer));
 
 			if (peer->ibp_ni != ni)
 				continue;
@@ -502,9 +495,7 @@ static int kiblnd_del_peer(lnet_ni_t *ni, lnet_nid_t nid)
 	for (i = lo; i <= hi; i++) {
 		list_for_each_safe(ptmp, pnxt, &kiblnd_data.kib_peers[i]) {
 			peer = list_entry(ptmp, kib_peer_t, ibp_list);
-			LASSERT(peer->ibp_connecting > 0 ||
-				peer->ibp_accepting > 0 ||
-				!list_empty(&peer->ibp_conns));
+			LASSERT(!kiblnd_peer_idle(peer));
 
 			if (peer->ibp_ni != ni)
 				continue;
@@ -545,9 +536,7 @@ static kib_conn_t *kiblnd_get_conn_by_idx(lnet_ni_t *ni, int index)
 	for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++) {
 		list_for_each(ptmp, &kiblnd_data.kib_peers[i]) {
 			peer = list_entry(ptmp, kib_peer_t, ibp_list);
-			LASSERT(peer->ibp_connecting > 0 ||
-				peer->ibp_accepting > 0 ||
-				!list_empty(&peer->ibp_conns));
+			LASSERT(!kiblnd_peer_idle(peer));
 
 			if (peer->ibp_ni != ni)
 				continue;
@@ -837,14 +826,14 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 	return conn;
 
  failed_2:
-	kiblnd_destroy_conn(conn);
+	kiblnd_destroy_conn(conn, true);
  failed_1:
 	LIBCFS_FREE(init_qp_attr, sizeof(*init_qp_attr));
  failed_0:
 	return NULL;
 }
 
-void kiblnd_destroy_conn(kib_conn_t *conn)
+void kiblnd_destroy_conn(kib_conn_t *conn, bool free_conn)
 {
 	struct rdma_cm_id *cmid = conn->ibc_cmid;
 	kib_peer_t *peer = conn->ibc_peer;
@@ -984,9 +973,7 @@ static int kiblnd_close_matching_conns(lnet_ni_t *ni, lnet_nid_t nid)
 	for (i = lo; i <= hi; i++) {
 		list_for_each_safe(ptmp, pnxt, &kiblnd_data.kib_peers[i]) {
 			peer = list_entry(ptmp, kib_peer_t, ibp_list);
-			LASSERT(peer->ibp_connecting > 0 ||
-				peer->ibp_accepting > 0 ||
-				!list_empty(&peer->ibp_conns));
+			LASSERT(!kiblnd_peer_idle(peer));
 
 			if (peer->ibp_ni != ni)
 				continue;
@@ -1071,12 +1058,8 @@ static void kiblnd_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 	read_lock_irqsave(glock, flags);
 
 	peer = kiblnd_find_peer_locked(nid);
-	if (peer) {
-		LASSERT(peer->ibp_connecting > 0 || /* creating conns */
-			 peer->ibp_accepting > 0 ||
-			 !list_empty(&peer->ibp_conns));  /* active conn */
+	if (peer)
 		last_alive = peer->ibp_last_alive;
-	}
 
 	read_unlock_irqrestore(glock, flags);
 
@@ -2368,6 +2351,8 @@ static void kiblnd_base_shutdown(void)
 			LASSERT(list_empty(&kiblnd_data.kib_peers[i]));
 		LASSERT(list_empty(&kiblnd_data.kib_connd_zombies));
 		LASSERT(list_empty(&kiblnd_data.kib_connd_conns));
+		LASSERT(list_empty(&kiblnd_data.kib_reconn_list));
+		LASSERT(list_empty(&kiblnd_data.kib_reconn_wait));
 
 		/* flag threads to terminate; wake and wait for them to die */
 		kiblnd_data.kib_shutdown = 1;
@@ -2506,6 +2491,9 @@ static int kiblnd_base_startup(void)
 	spin_lock_init(&kiblnd_data.kib_connd_lock);
 	INIT_LIST_HEAD(&kiblnd_data.kib_connd_conns);
 	INIT_LIST_HEAD(&kiblnd_data.kib_connd_zombies);
+	INIT_LIST_HEAD(&kiblnd_data.kib_reconn_list);
+	INIT_LIST_HEAD(&kiblnd_data.kib_reconn_wait);
+
 	init_waitqueue_head(&kiblnd_data.kib_connd_waitq);
 	init_waitqueue_head(&kiblnd_data.kib_failover_waitq);
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 6a4c4ac..bfcbdd1 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -348,6 +348,16 @@ typedef struct {
 	void *kib_connd; /* the connd task (serialisation assertions) */
 	struct list_head kib_connd_conns;   /* connections to setup/teardown */
 	struct list_head kib_connd_zombies; /* connections with zero refcount */
+	/* connections to reconnect */
+	struct list_head	kib_reconn_list;
+	/* peers wait for reconnection */
+	struct list_head	kib_reconn_wait;
+	/**
+	 * The second that peers are pulled out from \a kib_reconn_wait
+	 * for reconnection.
+	 */
+	time64_t		kib_reconn_sec;
+
 	wait_queue_head_t kib_connd_waitq;  /* connection daemon sleeps here */
 	spinlock_t kib_connd_lock;          /* serialise */
 	struct ib_qp_attr kib_error_qpa;    /* QP->ERROR */
@@ -525,6 +535,8 @@ typedef struct kib_conn {
 	struct list_head ibc_list;             /* stash on peer's conn list */
 	struct list_head      ibc_sched_list;  /* schedule for attention */
 	__u16                 ibc_version;     /* version of connection */
+	/* reconnect later */
+	__u16			ibc_reconnect:1;
 	__u64                 ibc_incarnation; /* which instance of the peer */
 	atomic_t              ibc_refcount;    /* # users */
 	int                   ibc_state;       /* what's happening */
@@ -574,18 +586,25 @@ typedef struct kib_peer {
 	struct list_head ibp_list;        /* stash on global peer list */
 	lnet_nid_t       ibp_nid;         /* who's on the other end(s) */
 	lnet_ni_t        *ibp_ni;         /* LNet interface */
-	atomic_t         ibp_refcount;    /* # users */
 	struct list_head ibp_conns;       /* all active connections */
 	struct list_head ibp_tx_queue;    /* msgs waiting for a conn */
-	__u16            ibp_version;     /* version of peer */
 	__u64            ibp_incarnation; /* incarnation of peer */
-	int              ibp_connecting;  /* current active connection attempts
-					   */
-	int              ibp_accepting;   /* current passive connection attempts
-					   */
-	int              ibp_error;       /* errno on closing this peer */
-	unsigned long    ibp_last_alive;  /* when (in jiffies) I was last alive
-					   */
+	/* when (in jiffies) I was last alive */
+	unsigned long		ibp_last_alive;
+	/* # users */
+	atomic_t		ibp_refcount;
+	/* version of peer */
+	__u16			ibp_version;
+	/* current passive connection attempts */
+	unsigned short		ibp_accepting;
+	/* current active connection attempts */
+	unsigned short		ibp_connecting;
+	/* reconnect this peer later */
+	unsigned short		ibp_reconnecting:1;
+	/* # consecutive reconnection attempts to this peer */
+	unsigned int		ibp_reconnected;
+	/* errno on closing this peer */
+	int              ibp_error;
 	/* max map_on_demand */
 	__u16		 ibp_max_frags;
 	/* max_peer_credits */
@@ -667,6 +686,20 @@ do {							    \
 		kiblnd_destroy_peer(peer);		      \
 } while (0)
 
+static inline bool
+kiblnd_peer_connecting(kib_peer_t *peer)
+{
+	return peer->ibp_connecting ||
+	       peer->ibp_reconnecting ||
+	       peer->ibp_accepting;
+}
+
+static inline bool
+kiblnd_peer_idle(kib_peer_t *peer)
+{
+	return !kiblnd_peer_connecting(peer) && list_empty(&peer->ibp_conns);
+}
+
 static inline struct list_head *
 kiblnd_nid2peerlist(lnet_nid_t nid)
 {
@@ -943,6 +976,7 @@ int  kiblnd_translate_mtu(int value);
 int  kiblnd_dev_failover(kib_dev_t *dev);
 int  kiblnd_create_peer(lnet_ni_t *ni, kib_peer_t **peerp, lnet_nid_t nid);
 void kiblnd_destroy_peer(kib_peer_t *peer);
+bool kiblnd_reconnect_peer(kib_peer_t *peer);
 void kiblnd_destroy_dev(kib_dev_t *dev);
 void kiblnd_unlink_peer_locked(kib_peer_t *peer);
 kib_peer_t *kiblnd_find_peer_locked(lnet_nid_t nid);
@@ -952,7 +986,7 @@ int  kiblnd_close_peer_conns_locked(kib_peer_t *peer, int why);
 
 kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 			       int state, int version);
-void kiblnd_destroy_conn(kib_conn_t *conn);
+void kiblnd_destroy_conn(kib_conn_t *conn, bool free_conn);
 void kiblnd_close_conn(kib_conn_t *conn, int error);
 void kiblnd_close_conn_locked(kib_conn_t *conn, int error);
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 1c62875..9e7efc8 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1258,6 +1258,7 @@ kiblnd_connect_peer(kib_peer_t *peer)
 
 	LASSERT(net);
 	LASSERT(peer->ibp_connecting > 0);
+	LASSERT(!peer->ibp_reconnecting);
 
 	cmid = kiblnd_rdma_create_id(kiblnd_cm_callback, peer, RDMA_PS_TCP,
 				     IB_QPT_RC);
@@ -1313,6 +1314,56 @@ kiblnd_connect_peer(kib_peer_t *peer)
 	kiblnd_peer_connect_failed(peer, 1, rc);
 }
 
+bool
+kiblnd_reconnect_peer(kib_peer_t *peer)
+{
+	rwlock_t *glock = &kiblnd_data.kib_global_lock;
+	char *reason = NULL;
+	struct list_head txs;
+	unsigned long flags;
+
+	INIT_LIST_HEAD(&txs);
+
+	write_lock_irqsave(glock, flags);
+	if (!peer->ibp_reconnecting) {
+		if (peer->ibp_accepting)
+			reason = "accepting";
+		else if (peer->ibp_connecting)
+			reason = "connecting";
+		else if (!list_empty(&peer->ibp_conns))
+			reason = "connected";
+		else /* connected then closed */
+			reason = "closed";
+
+		goto no_reconnect;
+	}
+
+	LASSERT(!peer->ibp_accepting && !peer->ibp_connecting &&
+		list_empty(&peer->ibp_conns));
+	peer->ibp_reconnecting = 0;
+
+	if (!kiblnd_peer_active(peer)) {
+		list_splice_init(&peer->ibp_tx_queue, &txs);
+		reason = "unlinked";
+		goto no_reconnect;
+	}
+
+	peer->ibp_connecting++;
+	peer->ibp_reconnected++;
+	write_unlock_irqrestore(glock, flags);
+
+	kiblnd_connect_peer(peer);
+	return true;
+
+no_reconnect:
+	write_unlock_irqrestore(glock, flags);
+
+	CWARN("Abort reconnection of %s: %s\n",
+	      libcfs_nid2str(peer->ibp_nid), reason);
+	kiblnd_txlist_done(peer->ibp_ni, &txs, -ECONNABORTED);
+	return false;
+}
+
 void
 kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 {
@@ -1358,8 +1409,7 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 	if (peer) {
 		if (list_empty(&peer->ibp_conns)) {
 			/* found a peer, but it's still connecting... */
-			LASSERT(peer->ibp_connecting ||
-				peer->ibp_accepting);
+			LASSERT(kiblnd_peer_connecting(peer));
 			if (tx)
 				list_add_tail(&tx->tx_list,
 					      &peer->ibp_tx_queue);
@@ -1397,8 +1447,7 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 	if (peer2) {
 		if (list_empty(&peer2->ibp_conns)) {
 			/* found a peer, but it's still connecting... */
-			LASSERT(peer2->ibp_connecting ||
-				peer2->ibp_accepting);
+			LASSERT(kiblnd_peer_connecting(peer2));
 			if (tx)
 				list_add_tail(&tx->tx_list,
 					      &peer2->ibp_tx_queue);
@@ -1818,10 +1867,7 @@ kiblnd_peer_notify(kib_peer_t *peer)
 
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
-	if (list_empty(&peer->ibp_conns) &&
-	    !peer->ibp_accepting &&
-	    !peer->ibp_connecting &&
-	    peer->ibp_error) {
+	if (kiblnd_peer_idle(peer) && peer->ibp_error) {
 		error = peer->ibp_error;
 		peer->ibp_error = 0;
 
@@ -2021,14 +2067,14 @@ kiblnd_peer_connect_failed(kib_peer_t *peer, int active, int error)
 		peer->ibp_accepting--;
 	}
 
-	if (peer->ibp_connecting ||
-	    peer->ibp_accepting) {
+	if (kiblnd_peer_connecting(peer)) {
 		/* another connection attempt under way... */
 		write_unlock_irqrestore(&kiblnd_data.kib_global_lock,
 					flags);
 		return;
 	}
 
+	peer->ibp_reconnected = 0;
 	if (list_empty(&peer->ibp_conns)) {
 		/* Take peer's blocked transmits to complete with error */
 		list_add(&zombies, &peer->ibp_tx_queue);
@@ -2101,6 +2147,7 @@ kiblnd_connreq_done(kib_conn_t *conn, int status)
 	 */
 	kiblnd_conn_addref(conn);	       /* +1 ref for ibc_list */
 	list_add(&conn->ibc_list, &peer->ibp_conns);
+	peer->ibp_reconnected = 0;
 	if (active)
 		peer->ibp_connecting--;
 	else
@@ -2356,10 +2403,16 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		if (peer2->ibp_incarnation != reqmsg->ibm_srcstamp ||
 		    peer2->ibp_version     != version) {
 			kiblnd_close_peer_conns_locked(peer2, -ESTALE);
+
+			if (kiblnd_peer_active(peer2)) {
+				peer2->ibp_incarnation = reqmsg->ibm_srcstamp;
+				peer2->ibp_version = version;
+			}
 			write_unlock_irqrestore(g_lock, flags);
 
-			CWARN("Conn stale %s [old ver: %x, new ver: %x]\n",
-			      libcfs_nid2str(nid), peer2->ibp_version, version);
+			CWARN("Conn stale %s version %x/%x incarnation %llu/%llu\n",
+			      libcfs_nid2str(nid), peer2->ibp_version, version,
+			      peer2->ibp_incarnation, reqmsg->ibm_srcstamp);
 
 			kiblnd_peer_decref(peer);
 			rej.ibr_why = IBLND_REJECT_CONN_STALE;
@@ -2378,6 +2431,11 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 			goto failed;
 		}
 
+		/**
+		 * passive connection is allowed even this peer is waiting for
+		 * reconnection.
+		 */
+		peer2->ibp_reconnecting = 0;
 		peer2->ibp_accepting++;
 		kiblnd_peer_addref(peer2);
 
@@ -2479,75 +2537,79 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 }
 
 static void
-kiblnd_reconnect(kib_conn_t *conn, int version,
-		 __u64 incarnation, int why, kib_connparams_t *cp)
+kiblnd_check_reconnect(kib_conn_t *conn, int version,
+		       __u64 incarnation, int why, kib_connparams_t *cp)
 {
+	rwlock_t *glock = &kiblnd_data.kib_global_lock;
 	kib_peer_t *peer = conn->ibc_peer;
 	char *reason;
-	int retry = 0;
+	int msg_size = IBLND_MSG_SIZE;
+	int frag_num = -1;
+	int queue_dep = -1;
+	bool reconnect;
 	unsigned long flags;
 
 	LASSERT(conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT);
 	LASSERT(peer->ibp_connecting > 0);     /* 'conn' at least */
+	LASSERT(!peer->ibp_reconnecting);
 
-	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
+	if (cp) {
+		msg_size = cp->ibcp_max_msg_size;
+		frag_num = cp->ibcp_max_frags;
+		queue_dep = cp->ibcp_queue_depth;
+	}
 
-	/*
+	write_lock_irqsave(glock, flags);
+	/**
 	 * retry connection if it's still needed and no other connection
 	 * attempts (active or passive) are in progress
 	 * NB: reconnect is still needed even when ibp_tx_queue is
 	 * empty if ibp_version != version because reconnect may be
 	 * initiated by kiblnd_query()
 	 */
-	if ((!list_empty(&peer->ibp_tx_queue) ||
-	     peer->ibp_version != version) &&
-	    peer->ibp_connecting == 1 &&
-	    !peer->ibp_accepting) {
-		retry = 1;
-		peer->ibp_connecting++;
-
-		peer->ibp_version     = version;
-		peer->ibp_incarnation = incarnation;
+	reconnect = (!list_empty(&peer->ibp_tx_queue) ||
+		     peer->ibp_version != version) &&
+		    peer->ibp_connecting == 1 &&
+		    !peer->ibp_accepting;
+	if (!reconnect) {
+		reason = "no need";
+		goto out;
 	}
 
-	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
-
-	if (!retry)
-		return;
-
 	switch (why) {
 	default:
 		reason = "Unknown";
 		break;
 
 	case IBLND_REJECT_RDMA_FRAGS:
-		if (!cp)
-			goto failed;
-
-		if (conn->ibc_max_frags <= cp->ibcp_max_frags) {
-			CNETERR("Unsupported max frags, peer supports %d\n",
-				cp->ibcp_max_frags);
-			goto failed;
-		} else if (!*kiblnd_tunables.kib_map_on_demand) {
-			CNETERR("map_on_demand must be enabled to support map_on_demand peers\n");
-			goto failed;
+		if (!cp) {
+			reason = "can't negotiate max frags";
+			goto out;
+		}
+		if (!*kiblnd_tunables.kib_map_on_demand) {
+			reason = "map_on_demand must be enabled";
+			goto out;
+		}
+		if (conn->ibc_max_frags <= frag_num) {
+			reason = "unsupported max frags";
+			goto out;
 		}
 
-		peer->ibp_max_frags = cp->ibcp_max_frags;
+		peer->ibp_max_frags = frag_num;
 		reason = "rdma fragments";
 		break;
 
 	case IBLND_REJECT_MSG_QUEUE_SIZE:
-		if (!cp)
-			goto failed;
-
-		if (conn->ibc_queue_depth <= cp->ibcp_queue_depth) {
-			CNETERR("Unsupported queue depth, peer supports %d\n",
-				cp->ibcp_queue_depth);
-			goto failed;
+		if (!cp) {
+			reason = "can't negotiate queue depth";
+			goto out;
+		}
+		if (conn->ibc_queue_depth <= queue_dep) {
+			reason = "unsupported queue depth";
+			goto out;
 		}
 
-		peer->ibp_queue_depth = cp->ibcp_queue_depth;
+		peer->ibp_queue_depth = queue_dep;
 		reason = "queue depth";
 		break;
 
@@ -2564,20 +2626,24 @@ kiblnd_reconnect(kib_conn_t *conn, int version,
 		break;
 	}
 
-	CNETERR("%s: retrying (%s), %x, %x, queue_dep: %d, max_frag: %d, msg_size: %d\n",
-		libcfs_nid2str(peer->ibp_nid),
-		reason, IBLND_MSG_VERSION, version,
-		conn->ibc_queue_depth, conn->ibc_max_frags,
-		cp ? cp->ibcp_max_msg_size : IBLND_MSG_SIZE);
-
-	kiblnd_connect_peer(peer);
-	return;
-failed:
-	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
-	peer->ibp_connecting--;
-	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
+	conn->ibc_reconnect = 1;
+	peer->ibp_reconnecting = 1;
+	peer->ibp_version = version;
+	if (incarnation)
+		peer->ibp_incarnation = incarnation;
+out:
+        write_unlock_irqrestore(glock, flags);
 
-	return;
+	CNETERR("%s: %s (%s), %x, %x, msg_size: %d, queue_depth: %d/%d, max_frags: %d/%d\n",
+		libcfs_nid2str(peer->ibp_nid),
+		reconnect ? "reconnect" : "don't reconnect",
+		reason, IBLND_MSG_VERSION, version, msg_size,
+		conn->ibc_queue_depth, queue_dep,
+		conn->ibc_max_frags, frag_num);
+        /**
+	 * if conn::ibc_reconnect is TRUE, connd will reconnect to the peer
+	 * while destroying the zombie
+	 */
 }
 
 static void
@@ -2590,8 +2656,8 @@ kiblnd_rejected(kib_conn_t *conn, int reason, void *priv, int priv_nob)
 
 	switch (reason) {
 	case IB_CM_REJ_STALE_CONN:
-		kiblnd_reconnect(conn, IBLND_MSG_VERSION, 0,
-				 IBLND_REJECT_CONN_STALE, NULL);
+		kiblnd_check_reconnect(conn, IBLND_MSG_VERSION, 0,
+				       IBLND_REJECT_CONN_STALE, NULL);
 		break;
 
 	case IB_CM_REJ_INVALID_SERVICE_ID:
@@ -2675,8 +2741,9 @@ kiblnd_rejected(kib_conn_t *conn, int reason, void *priv, int priv_nob)
 			case IBLND_REJECT_CONN_UNCOMPAT:
 			case IBLND_REJECT_MSG_QUEUE_SIZE:
 			case IBLND_REJECT_RDMA_FRAGS:
-				kiblnd_reconnect(conn, rej->ibr_version,
-						 incarnation, rej->ibr_why, cp);
+				kiblnd_check_reconnect(conn, rej->ibr_version,
+						       incarnation,
+						       rej->ibr_why, cp);
 				break;
 
 			case IBLND_REJECT_NO_RESOURCES:
@@ -3180,9 +3247,21 @@ kiblnd_disconnect_conn(kib_conn_t *conn)
 	kiblnd_peer_notify(conn->ibc_peer);
 }
 
+/**
+ * High-water for reconnection to the same peer, reconnection attempt should
+ * be delayed after trying more than KIB_RECONN_HIGH_RACE.
+ */
+#define KIB_RECONN_HIGH_RACE	10
+/**
+ * Allow connd to take a break and handle other things after consecutive
+ * reconnection attemps.
+ */
+#define KIB_RECONN_BREAK	100
+
 int
 kiblnd_connd(void *arg)
 {
+	spinlock_t *lock= &kiblnd_data.kib_connd_lock;
 	wait_queue_t wait;
 	unsigned long flags;
 	kib_conn_t *conn;
@@ -3197,23 +3276,40 @@ kiblnd_connd(void *arg)
 	init_waitqueue_entry(&wait, current);
 	kiblnd_data.kib_connd = current;
 
-	spin_lock_irqsave(&kiblnd_data.kib_connd_lock, flags);
+	spin_lock_irqsave(lock, flags);
 
 	while (!kiblnd_data.kib_shutdown) {
+		int reconn = 0;
+
 		dropped_lock = 0;
 
 		if (!list_empty(&kiblnd_data.kib_connd_zombies)) {
+			kib_peer_t *peer = NULL;
+
 			conn = list_entry(kiblnd_data.kib_connd_zombies.next,
 					  kib_conn_t, ibc_list);
 			list_del(&conn->ibc_list);
+			if (conn->ibc_reconnect) {
+				peer = conn->ibc_peer;
+				kiblnd_peer_addref(peer);
+			}
 
-			spin_unlock_irqrestore(&kiblnd_data.kib_connd_lock,
-					       flags);
+			spin_unlock_irqrestore(lock, flags);
 			dropped_lock = 1;
 
-			kiblnd_destroy_conn(conn);
+			kiblnd_destroy_conn(conn, !peer);
 
-			spin_lock_irqsave(&kiblnd_data.kib_connd_lock, flags);
+			spin_lock_irqsave(lock, flags);
+			if (!peer)
+				continue;
+
+			conn->ibc_peer = peer;
+			if (peer->ibp_reconnected < KIB_RECONN_HIGH_RACE)
+				list_add_tail(&conn->ibc_list,
+					      &kiblnd_data.kib_reconn_list);
+			else
+				list_add_tail(&conn->ibc_list,
+					      &kiblnd_data.kib_reconn_wait);
 		}
 
 		if (!list_empty(&kiblnd_data.kib_connd_conns)) {
@@ -3221,14 +3317,38 @@ kiblnd_connd(void *arg)
 					  kib_conn_t, ibc_list);
 			list_del(&conn->ibc_list);
 
-			spin_unlock_irqrestore(&kiblnd_data.kib_connd_lock,
-					       flags);
+			spin_unlock_irqrestore(lock, flags);
 			dropped_lock = 1;
 
 			kiblnd_disconnect_conn(conn);
 			kiblnd_conn_decref(conn);
 
-			spin_lock_irqsave(&kiblnd_data.kib_connd_lock, flags);
+			spin_lock_irqsave(lock, flags);
+		}
+
+		while (reconn < KIB_RECONN_BREAK) {
+			if (kiblnd_data.kib_reconn_sec !=
+			    ktime_get_real_seconds()) {
+				kiblnd_data.kib_reconn_sec = ktime_get_real_seconds();
+				list_splice_init(&kiblnd_data.kib_reconn_wait,
+						 &kiblnd_data.kib_reconn_list);
+			}
+
+			if (list_empty(&kiblnd_data.kib_reconn_list))
+				break;
+
+			conn = list_entry(kiblnd_data.kib_reconn_list.next,
+					  kib_conn_t, ibc_list);
+			list_del(&conn->ibc_list);
+
+			spin_unlock_irqrestore(lock, flags);
+			dropped_lock = 1;
+
+			reconn += kiblnd_reconnect_peer(conn->ibc_peer);
+			kiblnd_peer_decref(conn->ibc_peer);
+			LIBCFS_FREE(conn, sizeof(*conn));
+
+			spin_lock_irqsave(lock, flags);
 		}
 
 		/* careful with the jiffy wrap... */
@@ -3238,7 +3358,7 @@ kiblnd_connd(void *arg)
 			const int p = 1;
 			int chunk = kiblnd_data.kib_peer_hash_size;
 
-			spin_unlock_irqrestore(&kiblnd_data.kib_connd_lock, flags);
+			spin_unlock_irqrestore(lock, flags);
 			dropped_lock = 1;
 
 			/*
@@ -3263,7 +3383,7 @@ kiblnd_connd(void *arg)
 			}
 
 			deadline += msecs_to_jiffies(p * MSEC_PER_SEC);
-			spin_lock_irqsave(&kiblnd_data.kib_connd_lock, flags);
+			spin_lock_irqsave(lock, flags);
 		}
 
 		if (dropped_lock)
@@ -3272,15 +3392,15 @@ kiblnd_connd(void *arg)
 		/* Nothing to do for 'timeout'  */
 		set_current_state(TASK_INTERRUPTIBLE);
 		add_wait_queue(&kiblnd_data.kib_connd_waitq, &wait);
-		spin_unlock_irqrestore(&kiblnd_data.kib_connd_lock, flags);
+		spin_unlock_irqrestore(lock, flags);
 
 		schedule_timeout(timeout);
 
 		remove_wait_queue(&kiblnd_data.kib_connd_waitq, &wait);
-		spin_lock_irqsave(&kiblnd_data.kib_connd_lock, flags);
+		spin_lock_irqsave(lock, flags);
 	}
 
-	spin_unlock_irqrestore(&kiblnd_data.kib_connd_lock, flags);
+	spin_unlock_irqrestore(lock, flags);
 
 	kiblnd_thread_fini();
 	return 0;
-- 
1.7.1
