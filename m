From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 16/34] LU-7734 lnet: rename LND peer to
 peer_ni
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763547.32103.18087278859321916658.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

Patch to rename LND peers to peer_ni to reflect the fact that these
constructs reflect an actual connection between a local NI and remote
peer NI.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: I1c25a12eae61d8822a8c4ada2e077a5b2011ba22
Reviewed-on: http://review.whamcloud.com/19307
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Tested-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  232 ++++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  118 ++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  512 ++++++++-------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  662 ++++++++++----------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   66 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  207 +++---
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |    4 
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   14 
 8 files changed, 928 insertions(+), 887 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 64df49146413..71256500f245 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -258,7 +258,7 @@ int kiblnd_unpack_msg(struct kib_msg *msg, int nob)
 	msg->ibm_cksum = msg_cksum;
 
 	if (flip) {
-		/* leave magic unflipped as a clue to peer endianness */
+		/* leave magic unflipped as a clue to peer_ni endianness */
 		msg->ibm_version = version;
 		BUILD_BUG_ON(sizeof(msg->ibm_type) != 1);
 		BUILD_BUG_ON(sizeof(msg->ibm_credits) != 1);
@@ -315,10 +315,10 @@ int kiblnd_unpack_msg(struct kib_msg *msg, int nob)
 	return 0;
 }
 
-int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer **peerp,
+int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer_ni **peerp,
 		       lnet_nid_t nid)
 {
-	struct kib_peer *peer;
+	struct kib_peer_ni *peer_ni;
 	struct kib_net *net = ni->ni_data;
 	int cpt = lnet_cpt_of_nid(nid, ni);
 	unsigned long flags;
@@ -326,23 +326,23 @@ int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer **peerp,
 	LASSERT(net);
 	LASSERT(nid != LNET_NID_ANY);
 
-	peer = kzalloc_cpt(sizeof(*peer), GFP_NOFS, cpt);
-	if (!peer) {
-		CERROR("Cannot allocate peer\n");
+	peer_ni = kzalloc_cpt(sizeof(*peer_ni), GFP_NOFS, cpt);
+	if (!peer_ni) {
+		CERROR("Cannot allocate peer_ni\n");
 		return -ENOMEM;
 	}
 
-	peer->ibp_ni = ni;
-	peer->ibp_nid = nid;
-	peer->ibp_error = 0;
-	peer->ibp_last_alive = 0;
-	peer->ibp_max_frags = kiblnd_cfg_rdma_frags(peer->ibp_ni);
-	peer->ibp_queue_depth = ni->ni_net->net_tunables.lct_peer_tx_credits;
-	atomic_set(&peer->ibp_refcount, 1);  /* 1 ref for caller */
+	peer_ni->ibp_ni = ni;
+	peer_ni->ibp_nid = nid;
+	peer_ni->ibp_error = 0;
+	peer_ni->ibp_last_alive = 0;
+	peer_ni->ibp_max_frags = kiblnd_cfg_rdma_frags(peer_ni->ibp_ni);
+	peer_ni->ibp_queue_depth = ni->ni_net->net_tunables.lct_peer_tx_credits;
+	atomic_set(&peer_ni->ibp_refcount, 1);  /* 1 ref for caller */
 
-	INIT_LIST_HEAD(&peer->ibp_list);     /* not in the peer table yet */
-	INIT_LIST_HEAD(&peer->ibp_conns);
-	INIT_LIST_HEAD(&peer->ibp_tx_queue);
+	INIT_LIST_HEAD(&peer_ni->ibp_list);
+	INIT_LIST_HEAD(&peer_ni->ibp_conns);
+	INIT_LIST_HEAD(&peer_ni->ibp_tx_queue);
 
 	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
@@ -354,93 +354,94 @@ int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer **peerp,
 
 	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
-	*peerp = peer;
+	*peerp = peer_ni;
 	return 0;
 }
 
-void kiblnd_destroy_peer(struct kib_peer *peer)
+void kiblnd_destroy_peer(struct kib_peer_ni *peer_ni)
 {
-	struct kib_net *net = peer->ibp_ni->ni_data;
+	struct kib_net *net = peer_ni->ibp_ni->ni_data;
 
 	LASSERT(net);
-	LASSERT(!atomic_read(&peer->ibp_refcount));
-	LASSERT(!kiblnd_peer_active(peer));
-	LASSERT(kiblnd_peer_idle(peer));
-	LASSERT(list_empty(&peer->ibp_tx_queue));
+	LASSERT(!atomic_read(&peer_ni->ibp_refcount));
+	LASSERT(!kiblnd_peer_active(peer_ni));
+	LASSERT(kiblnd_peer_idle(peer_ni));
+	LASSERT(list_empty(&peer_ni->ibp_tx_queue));
 
-	kfree(peer);
+	kfree(peer_ni);
 
 	/*
-	 * NB a peer's connections keep a reference on their peer until
+	 * NB a peer_ni's connections keep a reference on their peer_ni until
 	 * they are destroyed, so we can be assured that _all_ state to do
-	 * with this peer has been cleaned up when its refcount drops to
+	 * with this peer_ni has been cleaned up when its refcount drops to
 	 * zero.
 	 */
 	atomic_dec(&net->ibn_npeers);
 }
 
-struct kib_peer *kiblnd_find_peer_locked(struct lnet_ni *ni, lnet_nid_t nid)
+struct kib_peer_ni *kiblnd_find_peer_locked(struct lnet_ni *ni, lnet_nid_t nid)
 {
 	/*
 	 * the caller is responsible for accounting the additional reference
 	 * that this creates
 	 */
 	struct list_head *peer_list = kiblnd_nid2peerlist(nid);
-	struct kib_peer *peer;
+	struct kib_peer_ni *peer_ni;
 
-	list_for_each_entry(peer, peer_list, ibp_list) {
-		LASSERT(!kiblnd_peer_idle(peer));
+	list_for_each_entry(peer_ni, peer_list, ibp_list) {
+		LASSERT(!kiblnd_peer_idle(peer_ni));
 
 		/*
-		 * Match a peer if its NID and the NID of the local NI it
+		 * Match a peer_ni if its NID and the NID of the local NI it
 		 * communicates over are the same. Otherwise don't match
-		 * the peer, which will result in a new lnd peer being
+		 * the peer_ni, which will result in a new lnd peer_ni being
 		 * created.
 		 */
-		if (peer->ibp_nid != nid ||
-		    peer->ibp_ni->ni_nid != ni->ni_nid)
+		if (peer_ni->ibp_nid != nid ||
+		    peer_ni->ibp_ni->ni_nid != ni->ni_nid)
 			continue;
 
-		CDEBUG(D_NET, "got peer [%p] -> %s (%d) version: %x\n",
-		       peer, libcfs_nid2str(nid),
-		       atomic_read(&peer->ibp_refcount),
-		       peer->ibp_version);
-		return peer;
+		CDEBUG(D_NET, "got peer_ni [%p] -> %s (%d) version: %x\n",
+		       peer_ni, libcfs_nid2str(nid),
+		       atomic_read(&peer_ni->ibp_refcount),
+		       peer_ni->ibp_version);
+		return peer_ni;
 	}
 	return NULL;
 }
 
-void kiblnd_unlink_peer_locked(struct kib_peer *peer)
+void kiblnd_unlink_peer_locked(struct kib_peer_ni *peer_ni)
 {
-	LASSERT(list_empty(&peer->ibp_conns));
+	LASSERT(list_empty(&peer_ni->ibp_conns));
 
-	LASSERT(kiblnd_peer_active(peer));
-	list_del_init(&peer->ibp_list);
+	LASSERT(kiblnd_peer_active(peer_ni));
+	list_del_init(&peer_ni->ibp_list);
 	/* lose peerlist's ref */
-	kiblnd_peer_decref(peer);
+	kiblnd_peer_decref(peer_ni);
 }
 
 static int kiblnd_get_peer_info(struct lnet_ni *ni, int index,
 				lnet_nid_t *nidp, int *count)
 {
-	struct kib_peer *peer;
+	struct kib_peer_ni *peer_ni;
 	int i;
 	unsigned long flags;
 
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
 	for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++) {
-		list_for_each_entry(peer, &kiblnd_data.kib_peers[i], ibp_list) {
-			LASSERT(!kiblnd_peer_idle(peer));
+		list_for_each_entry(peer_ni, &kiblnd_data.kib_peers[i],
+				    ibp_list) {
+			LASSERT(!kiblnd_peer_idle(peer_ni));
 
-			if (peer->ibp_ni != ni)
+			if (peer_ni->ibp_ni != ni)
 				continue;
 
 			if (index-- > 0)
 				continue;
 
-			*nidp = peer->ibp_nid;
-			*count = atomic_read(&peer->ibp_refcount);
+			*nidp = peer_ni->ibp_nid;
+			*count = atomic_read(&peer_ni->ibp_refcount);
 
 			read_unlock_irqrestore(&kiblnd_data.kib_global_lock,
 					       flags);
@@ -452,34 +453,33 @@ static int kiblnd_get_peer_info(struct lnet_ni *ni, int index,
 	return -ENOENT;
 }
 
-static void kiblnd_del_peer_locked(struct kib_peer *peer)
+static void kiblnd_del_peer_locked(struct kib_peer_ni *peer_ni)
 {
 	struct list_head *ctmp;
 	struct list_head *cnxt;
 	struct kib_conn *conn;
 
-	if (list_empty(&peer->ibp_conns)) {
-		kiblnd_unlink_peer_locked(peer);
+	if (list_empty(&peer_ni->ibp_conns)) {
+		kiblnd_unlink_peer_locked(peer_ni);
 	} else {
-		list_for_each_safe(ctmp, cnxt, &peer->ibp_conns) {
+		list_for_each_safe(ctmp, cnxt, &peer_ni->ibp_conns) {
 			conn = list_entry(ctmp, struct kib_conn, ibc_list);
 
 			kiblnd_close_conn_locked(conn, 0);
 		}
-		/* NB closing peer's last conn unlinked it. */
+		/* NB closing peer_ni's last conn unlinked it. */
 	}
 	/*
-	 * NB peer now unlinked; might even be freed if the peer table had the
-	 * last ref on it.
+	 * NB peer_ni now unlinked; might even be freed if the peer_ni
+	 * table had the last ref on it.
 	 */
 }
 
 static int kiblnd_del_peer(struct lnet_ni *ni, lnet_nid_t nid)
 {
 	LIST_HEAD(zombies);
-	struct list_head *ptmp;
-	struct list_head *pnxt;
-	struct kib_peer *peer;
+	struct kib_peer_ni *pnxt;
+	struct kib_peer_ni *peer_ni;
 	int lo;
 	int hi;
 	int i;
@@ -497,24 +497,24 @@ static int kiblnd_del_peer(struct lnet_ni *ni, lnet_nid_t nid)
 	}
 
 	for (i = lo; i <= hi; i++) {
-		list_for_each_safe(ptmp, pnxt, &kiblnd_data.kib_peers[i]) {
-			peer = list_entry(ptmp, struct kib_peer, ibp_list);
-			LASSERT(!kiblnd_peer_idle(peer));
+		list_for_each_entry_safe(peer_ni, pnxt,
+					 &kiblnd_data.kib_peers[i], ibp_list) {
+			LASSERT(!kiblnd_peer_idle(peer_ni));
 
-			if (peer->ibp_ni != ni)
+			if (peer_ni->ibp_ni != ni)
 				continue;
 
-			if (!(nid == LNET_NID_ANY || peer->ibp_nid == nid))
+			if (!(nid == LNET_NID_ANY || peer_ni->ibp_nid == nid))
 				continue;
 
-			if (!list_empty(&peer->ibp_tx_queue)) {
-				LASSERT(list_empty(&peer->ibp_conns));
+			if (!list_empty(&peer_ni->ibp_tx_queue)) {
+				LASSERT(list_empty(&peer_ni->ibp_conns));
 
-				list_splice_init(&peer->ibp_tx_queue,
+				list_splice_init(&peer_ni->ibp_tx_queue,
 						 &zombies);
 			}
 
-			kiblnd_del_peer_locked(peer);
+			kiblnd_del_peer_locked(peer_ni);
 			rc = 0;	 /* matched something */
 		}
 	}
@@ -528,7 +528,7 @@ static int kiblnd_del_peer(struct lnet_ni *ni, lnet_nid_t nid)
 
 static struct kib_conn *kiblnd_get_conn_by_idx(struct lnet_ni *ni, int index)
 {
-	struct kib_peer *peer;
+	struct kib_peer_ni *peer_ni;
 	struct kib_conn *conn;
 	int i;
 	unsigned long flags;
@@ -536,13 +536,15 @@ static struct kib_conn *kiblnd_get_conn_by_idx(struct lnet_ni *ni, int index)
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
 	for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++) {
-		list_for_each_entry(peer, &kiblnd_data.kib_peers[i], ibp_list) {
-			LASSERT(!kiblnd_peer_idle(peer));
+		list_for_each_entry(peer_ni, &kiblnd_data.kib_peers[i],
+				    ibp_list) {
+			LASSERT(!kiblnd_peer_idle(peer_ni));
 
-			if (peer->ibp_ni != ni)
+			if (peer_ni->ibp_ni != ni)
 				continue;
 
-			list_for_each_entry(conn, &peer->ibp_conns, ibc_list) {
+			list_for_each_entry(conn, &peer_ni->ibp_conns,
+					    ibc_list) {
 				if (index-- > 0)
 					continue;
 
@@ -620,20 +622,23 @@ static int kiblnd_get_completion_vector(struct kib_conn *conn, int cpt)
 	return 1;
 }
 
-struct kib_conn *kiblnd_create_conn(struct kib_peer *peer, struct rdma_cm_id *cmid,
+struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
+				    struct rdma_cm_id *cmid,
 				    int state, int version)
 {
 	/*
 	 * CAVEAT EMPTOR:
-	 * If the new conn is created successfully it takes over the caller's
-	 * ref on 'peer'.  It also "owns" 'cmid' and destroys it when it itself
-	 * is destroyed.  On failure, the caller's ref on 'peer' remains and
-	 * she must dispose of 'cmid'.  (Actually I'd block forever if I tried
-	 * to destroy 'cmid' here since I'm called from the CM which still has
+	 *
+	 * If the new conn is created successfully it takes over the
+	 * caller's ref on 'peer_ni'.  It also "owns" 'cmid' and
+	 * destroys it when it itself is destroyed.  On failure, the
+	 * caller's ref on 'peer_ni' remains and she must dispose of
+	 * 'cmid'.  (Actually I'd block forever if I tried to destroy
+	 * 'cmid' here since I'm called from the CM which still has
 	 * its ref on 'cmid').
 	 */
 	rwlock_t *glock = &kiblnd_data.kib_global_lock;
-	struct kib_net *net = peer->ibp_ni->ni_data;
+	struct kib_net *net = peer_ni->ibp_ni->ni_data;
 	struct kib_dev *dev;
 	struct ib_qp_init_attr *init_qp_attr;
 	struct kib_sched_info *sched;
@@ -650,7 +655,7 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer *peer, struct rdma_cm_id *cm
 
 	dev = net->ibn_dev;
 
-	cpt = lnet_cpt_of_nid(peer->ibp_nid, peer->ibp_ni);
+	cpt = lnet_cpt_of_nid(peer_ni->ibp_nid, peer_ni->ibp_ni);
 	sched = kiblnd_data.kib_scheds[cpt];
 
 	LASSERT(sched->ibs_nthreads > 0);
@@ -658,24 +663,24 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer *peer, struct rdma_cm_id *cm
 	init_qp_attr = kzalloc_cpt(sizeof(*init_qp_attr), GFP_NOFS, cpt);
 	if (!init_qp_attr) {
 		CERROR("Can't allocate qp_attr for %s\n",
-		       libcfs_nid2str(peer->ibp_nid));
+		       libcfs_nid2str(peer_ni->ibp_nid));
 		goto failed_0;
 	}
 
 	conn = kzalloc_cpt(sizeof(*conn), GFP_NOFS, cpt);
 	if (!conn) {
 		CERROR("Can't allocate connection for %s\n",
-		       libcfs_nid2str(peer->ibp_nid));
+		       libcfs_nid2str(peer_ni->ibp_nid));
 		goto failed_1;
 	}
 
 	conn->ibc_state = IBLND_CONN_INIT;
 	conn->ibc_version = version;
-	conn->ibc_peer = peer;		  /* I take the caller's ref */
+	conn->ibc_peer = peer_ni;		  /* I take the caller's ref */
 	cmid->context = conn;		   /* for future CM callbacks */
 	conn->ibc_cmid = cmid;
-	conn->ibc_max_frags = peer->ibp_max_frags;
-	conn->ibc_queue_depth = peer->ibp_queue_depth;
+	conn->ibc_max_frags = peer_ni->ibp_max_frags;
+	conn->ibc_queue_depth = peer_ni->ibp_queue_depth;
 
 	INIT_LIST_HEAD(&conn->ibc_early_rxs);
 	INIT_LIST_HEAD(&conn->ibc_tx_noops);
@@ -834,7 +839,7 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer *peer, struct rdma_cm_id *cm
 void kiblnd_destroy_conn(struct kib_conn *conn)
 {
 	struct rdma_cm_id *cmid = conn->ibc_cmid;
-	struct kib_peer *peer = conn->ibc_peer;
+	struct kib_peer_ni *peer_ni = conn->ibc_peer;
 	int rc;
 
 	LASSERT(!in_interrupt());
@@ -883,26 +888,26 @@ void kiblnd_destroy_conn(struct kib_conn *conn)
 
 	/* See CAVEAT EMPTOR above in kiblnd_create_conn */
 	if (conn->ibc_state != IBLND_CONN_INIT) {
-		struct kib_net *net = peer->ibp_ni->ni_data;
+		struct kib_net *net = peer_ni->ibp_ni->ni_data;
 
-		kiblnd_peer_decref(peer);
+		kiblnd_peer_decref(peer_ni);
 		rdma_destroy_id(cmid);
 		atomic_dec(&net->ibn_nconns);
 	}
 }
 
-int kiblnd_close_peer_conns_locked(struct kib_peer *peer, int why)
+int kiblnd_close_peer_conns_locked(struct kib_peer_ni *peer_ni, int why)
 {
 	struct kib_conn *conn;
 	struct list_head *ctmp;
 	struct list_head *cnxt;
 	int count = 0;
 
-	list_for_each_safe(ctmp, cnxt, &peer->ibp_conns) {
+	list_for_each_safe(ctmp, cnxt, &peer_ni->ibp_conns) {
 		conn = list_entry(ctmp, struct kib_conn, ibc_list);
 
 		CDEBUG(D_NET, "Closing conn -> %s, version: %x, reason: %d\n",
-		       libcfs_nid2str(peer->ibp_nid),
+		       libcfs_nid2str(peer_ni->ibp_nid),
 		       conn->ibc_version, why);
 
 		kiblnd_close_conn_locked(conn, why);
@@ -912,7 +917,7 @@ int kiblnd_close_peer_conns_locked(struct kib_peer *peer, int why)
 	return count;
 }
 
-int kiblnd_close_stale_conns_locked(struct kib_peer *peer,
+int kiblnd_close_stale_conns_locked(struct kib_peer_ni *peer_ni,
 				    int version, __u64 incarnation)
 {
 	struct kib_conn *conn;
@@ -920,7 +925,7 @@ int kiblnd_close_stale_conns_locked(struct kib_peer *peer,
 	struct list_head *cnxt;
 	int count = 0;
 
-	list_for_each_safe(ctmp, cnxt, &peer->ibp_conns) {
+	list_for_each_safe(ctmp, cnxt, &peer_ni->ibp_conns) {
 		conn = list_entry(ctmp, struct kib_conn, ibc_list);
 
 		if (conn->ibc_version     == version &&
@@ -929,7 +934,7 @@ int kiblnd_close_stale_conns_locked(struct kib_peer *peer,
 
 		CDEBUG(D_NET,
 		       "Closing stale conn -> %s version: %x, incarnation:%#llx(%x, %#llx)\n",
-		       libcfs_nid2str(peer->ibp_nid),
+		       libcfs_nid2str(peer_ni->ibp_nid),
 		       conn->ibc_version, conn->ibc_incarnation,
 		       version, incarnation);
 
@@ -942,9 +947,8 @@ int kiblnd_close_stale_conns_locked(struct kib_peer *peer,
 
 static int kiblnd_close_matching_conns(struct lnet_ni *ni, lnet_nid_t nid)
 {
-	struct kib_peer *peer;
-	struct list_head *ptmp;
-	struct list_head *pnxt;
+	struct kib_peer_ni *peer_ni;
+	struct kib_peer_ni *pnxt;
 	int lo;
 	int hi;
 	int i;
@@ -962,17 +966,17 @@ static int kiblnd_close_matching_conns(struct lnet_ni *ni, lnet_nid_t nid)
 	}
 
 	for (i = lo; i <= hi; i++) {
-		list_for_each_safe(ptmp, pnxt, &kiblnd_data.kib_peers[i]) {
-			peer = list_entry(ptmp, struct kib_peer, ibp_list);
-			LASSERT(!kiblnd_peer_idle(peer));
+		list_for_each_entry_safe(peer_ni, pnxt,
+					 &kiblnd_data.kib_peers[i], ibp_list) {
+			LASSERT(!kiblnd_peer_idle(peer_ni));
 
-			if (peer->ibp_ni != ni)
+			if (peer_ni->ibp_ni != ni)
 				continue;
 
-			if (!(nid == LNET_NID_ANY || nid == peer->ibp_nid))
+			if (!(nid == LNET_NID_ANY || nid == peer_ni->ibp_nid))
 				continue;
 
-			count += kiblnd_close_peer_conns_locked(peer, 0);
+			count += kiblnd_close_peer_conns_locked(peer_ni, 0);
 		}
 	}
 
@@ -1043,14 +1047,14 @@ static void kiblnd_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when)
 	time64_t last_alive = 0;
 	time64_t now = ktime_get_seconds();
 	rwlock_t *glock = &kiblnd_data.kib_global_lock;
-	struct kib_peer *peer;
+	struct kib_peer_ni *peer_ni;
 	unsigned long flags;
 
 	read_lock_irqsave(glock, flags);
 
-	peer = kiblnd_find_peer_locked(ni, nid);
-	if (peer)
-		last_alive = peer->ibp_last_alive;
+	peer_ni = kiblnd_find_peer_locked(ni, nid);
+	if (peer_ni)
+		last_alive = peer_ni->ibp_last_alive;
 
 	read_unlock_irqrestore(glock, flags);
 
@@ -1058,14 +1062,14 @@ static void kiblnd_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when)
 		*when = last_alive;
 
 	/*
-	 * peer is not persistent in hash, trigger peer creation
+	 * peer_ni is not persistent in hash, trigger peer_ni creation
 	 * and connection establishment with a NULL tx
 	 */
-	if (!peer)
+	if (!peer_ni)
 		kiblnd_launch_tx(ni, NULL, nid);
 
-	CDEBUG(D_NET, "Peer %s %p, alive %lld secs ago\n",
-	       libcfs_nid2str(nid), peer,
+	CDEBUG(D_NET, "peer_ni %s %p, alive %lld secs ago\n",
+	       libcfs_nid2str(nid), peer_ni,
 	       last_alive ? now - last_alive : -1);
 }
 
@@ -2595,7 +2599,7 @@ static void kiblnd_shutdown(struct lnet_ni *ni)
 		/* nuke all existing peers within this net */
 		kiblnd_del_peer(ni, LNET_NID_ANY);
 
-		/* Wait for all peer state to clean up */
+		/* Wait for all peer_ni state to clean up */
 		i = 2;
 		while (atomic_read(&net->ibn_npeers)) {
 			i++;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 520f586015f4..b1851b529ef8 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -66,7 +66,7 @@
 
 #include <linux/lnet/lib-lnet.h>
 
-#define IBLND_PEER_HASH_SIZE		101	/* # peer lists */
+#define IBLND_PEER_HASH_SIZE		101	/* # peer_ni lists */
 /* # scheduler loops before reschedule */
 #define IBLND_RESCHED			100
 
@@ -96,8 +96,9 @@ extern struct kib_tunables  kiblnd_tunables;
 #define IBLND_MSG_QUEUE_SIZE_V1   8 /* V1 only : # messages/RDMAs in-flight */
 #define IBLND_CREDIT_HIGHWATER_V1 7 /* V1 only : when eagerly to return credits */
 
-#define IBLND_CREDITS_DEFAULT     8 /* default # of peer credits */
-#define IBLND_CREDITS_MAX	  ((typeof(((struct kib_msg *)0)->ibm_credits)) - 1)  /* Max # of peer credits */
+#define IBLND_CREDITS_DEFAULT     8 /* default # of peer_ni credits */
+/* Max # of peer_ni credits */
+#define IBLND_CREDITS_MAX	  ((typeof(((struct kib_msg *)0)->ibm_credits)) - 1)
 
 /* when eagerly to return credits */
 #define IBLND_CREDITS_HIGHWATER(t, v)	((v) == IBLND_MSG_VERSION_1 ? \
@@ -324,7 +325,7 @@ struct kib_data {
 	struct list_head  kib_failed_devs;    /* list head of failed devices */
 	wait_queue_head_t kib_failover_waitq; /* schedulers sleep here */
 	atomic_t kib_nthreads;                /* # live threads */
-	rwlock_t kib_global_lock;    /* stabilize net/dev/peer/conn ops */
+	rwlock_t kib_global_lock;    /* stabilize net/dev/peer_ni/conn ops */
 	struct list_head *kib_peers; /* hash table of all my known peers */
 	int  kib_peer_hash_size;     /* size of kib_peers */
 	void *kib_connd; /* the connd task (serialisation assertions) */
@@ -445,7 +446,7 @@ struct kib_rej {
 	__u16            ibr_version;     /* sender's version */
 	__u8             ibr_why;         /* reject reason */
 	__u8             ibr_padding;     /* padding */
-	__u64            ibr_incarnation; /* incarnation of peer */
+	__u64            ibr_incarnation; /* incarnation of peer_ni */
 	struct kib_connparams ibr_cp;          /* connection parameters */
 } __packed;
 
@@ -453,11 +454,11 @@ struct kib_rej {
 #define IBLND_REJECT_CONN_RACE      1 /* You lost connection race */
 #define IBLND_REJECT_NO_RESOURCES   2 /* Out of memory/conns etc */
 #define IBLND_REJECT_FATAL          3 /* Anything else */
-#define IBLND_REJECT_CONN_UNCOMPAT  4 /* incompatible version peer */
-#define IBLND_REJECT_CONN_STALE     5 /* stale peer */
-/* peer's rdma frags doesn't match mine */
+#define IBLND_REJECT_CONN_UNCOMPAT  4 /* incompatible version peer_ni */
+#define IBLND_REJECT_CONN_STALE     5 /* stale peer_ni */
+/* peer_ni's rdma frags doesn't match mine */
 #define IBLND_REJECT_RDMA_FRAGS	    6
-/* peer's msg queue size doesn't match mine */
+/* peer_ni's msg queue size doesn't match mine */
 #define IBLND_REJECT_MSG_QUEUE_SIZE 7
 
 /***********************************************************************/
@@ -476,7 +477,7 @@ struct kib_rx {					/* receive message */
 
 #define IBLND_POSTRX_DONT_POST    0 /* don't post */
 #define IBLND_POSTRX_NO_CREDIT    1 /* post: no credits */
-#define IBLND_POSTRX_PEER_CREDIT  2 /* post: give peer back 1 credit */
+#define IBLND_POSTRX_PEER_CREDIT  2 /* post: give peer_ni back 1 credit */
 #define IBLND_POSTRX_RSRVD_CREDIT 3 /* post: give self back 1 reserved credit */
 
 struct kib_tx {					/* transmit message */
@@ -485,7 +486,7 @@ struct kib_tx {					/* transmit message */
 	struct kib_conn       *tx_conn;       /* owning conn */
 	short                 tx_sending;     /* # tx callbacks outstanding */
 	short                 tx_queued;      /* queued for sending */
-	short                 tx_waiting;     /* waiting for peer */
+	short                 tx_waiting;     /* waiting for peer_ni */
 	int                   tx_status;      /* LNET completion status */
 	ktime_t			tx_deadline;	/* completion deadline */
 	__u64                 tx_cookie;      /* completion cookie */
@@ -510,14 +511,14 @@ struct kib_connvars {
 
 struct kib_conn {
 	struct kib_sched_info *ibc_sched;      /* scheduler information */
-	struct kib_peer       *ibc_peer;       /* owning peer */
+	struct kib_peer_ni       *ibc_peer;       /* owning peer_ni */
 	struct kib_hca_dev         *ibc_hdev;       /* HCA bound on */
-	struct list_head ibc_list;             /* stash on peer's conn list */
+	struct list_head ibc_list;            /* stash on peer_ni's conn list */
 	struct list_head      ibc_sched_list;  /* schedule for attention */
 	__u16                 ibc_version;     /* version of connection */
 	/* reconnect later */
 	__u16			ibc_reconnect:1;
-	__u64                 ibc_incarnation; /* which instance of the peer */
+	__u64                 ibc_incarnation; /* which instance of the peer_ni */
 	atomic_t              ibc_refcount;    /* # users */
 	int                   ibc_state;       /* what's happening */
 	int                   ibc_nsends_posted; /* # uncompleted sends */
@@ -562,32 +563,32 @@ struct kib_conn {
 #define IBLND_CONN_CLOSING        4	 /* being closed */
 #define IBLND_CONN_DISCONNECTED   5	 /* disconnected */
 
-struct kib_peer {
-	struct list_head ibp_list;        /* stash on global peer list */
+struct kib_peer_ni {
+	struct list_head ibp_list;        /* stash on global peer_ni list */
 	lnet_nid_t       ibp_nid;         /* who's on the other end(s) */
 	struct lnet_ni	*ibp_ni;         /* LNet interface */
 	struct list_head ibp_conns;       /* all active connections */
 	struct kib_conn	*ibp_next_conn;  /* next connection to send on for
 					  * round robin */
 	struct list_head ibp_tx_queue;    /* msgs waiting for a conn */
-	__u64            ibp_incarnation; /* incarnation of peer */
+	__u64            ibp_incarnation; /* incarnation of peer_ni */
 	/* when (in seconds) I was last alive */
 	time64_t		ibp_last_alive;
 	/* # users */
 	atomic_t		ibp_refcount;
-	/* version of peer */
+	/* version of peer_ni */
 	__u16			ibp_version;
 	/* current passive connection attempts */
 	unsigned short		ibp_accepting;
 	/* current active connection attempts */
 	unsigned short		ibp_connecting;
-	/* reconnect this peer later */
+	/* reconnect this peer_ni later */
 	unsigned char		ibp_reconnecting;
 	/* counter of how many times we triggered a conn race */
 	unsigned char		ibp_races;
-	/* # consecutive reconnection attempts to this peer */
+	/* # consecutive reconnection attempts to this peer_ni */
 	unsigned int		ibp_reconnected;
-	/* errno on closing this peer */
+	/* errno on closing this peer_ni */
 	int              ibp_error;
 	/* max map_on_demand */
 	__u16		 ibp_max_frags;
@@ -694,36 +695,37 @@ do {									\
 	}								\
 } while (0)
 
-#define kiblnd_peer_addref(peer)				\
+#define kiblnd_peer_addref(peer_ni)				\
 do {							    \
-	CDEBUG(D_NET, "peer[%p] -> %s (%d)++\n",		\
-	       (peer), libcfs_nid2str((peer)->ibp_nid),	 \
-	       atomic_read(&(peer)->ibp_refcount));	\
-	atomic_inc(&(peer)->ibp_refcount);		  \
+	CDEBUG(D_NET, "peer_ni[%p] -> %s (%d)++\n",		\
+	       (peer_ni), libcfs_nid2str((peer_ni)->ibp_nid),	 \
+	       atomic_read(&(peer_ni)->ibp_refcount));	\
+	atomic_inc(&(peer_ni)->ibp_refcount);		  \
 } while (0)
 
-#define kiblnd_peer_decref(peer)				\
+#define kiblnd_peer_decref(peer_ni)				\
 do {							    \
-	CDEBUG(D_NET, "peer[%p] -> %s (%d)--\n",		\
-	       (peer), libcfs_nid2str((peer)->ibp_nid),	 \
-	       atomic_read(&(peer)->ibp_refcount));	\
-	LASSERT_ATOMIC_POS(&(peer)->ibp_refcount);	      \
-	if (atomic_dec_and_test(&(peer)->ibp_refcount))     \
-		kiblnd_destroy_peer(peer);		      \
+	CDEBUG(D_NET, "peer_ni[%p] -> %s (%d)--\n",		\
+	       (peer_ni), libcfs_nid2str((peer_ni)->ibp_nid),	 \
+	       atomic_read(&(peer_ni)->ibp_refcount));	\
+	LASSERT_ATOMIC_POS(&(peer_ni)->ibp_refcount);	      \
+	if (atomic_dec_and_test(&(peer_ni)->ibp_refcount))     \
+		kiblnd_destroy_peer(peer_ni);		      \
 } while (0)
 
 static inline bool
-kiblnd_peer_connecting(struct kib_peer *peer)
+kiblnd_peer_connecting(struct kib_peer_ni *peer_ni)
 {
-	return peer->ibp_connecting ||
-	       peer->ibp_reconnecting ||
-	       peer->ibp_accepting;
+	return peer_ni->ibp_connecting ||
+	       peer_ni->ibp_reconnecting ||
+	       peer_ni->ibp_accepting;
 }
 
 static inline bool
-kiblnd_peer_idle(struct kib_peer *peer)
+kiblnd_peer_idle(struct kib_peer_ni *peer_ni)
 {
-	return !kiblnd_peer_connecting(peer) && list_empty(&peer->ibp_conns);
+	return !kiblnd_peer_connecting(peer_ni) &&
+		list_empty(&peer_ni->ibp_conns);
 }
 
 static inline struct list_head *
@@ -736,28 +738,28 @@ kiblnd_nid2peerlist(lnet_nid_t nid)
 }
 
 static inline int
-kiblnd_peer_active(struct kib_peer *peer)
+kiblnd_peer_active(struct kib_peer_ni *peer_ni)
 {
-	/* Am I in the peer hash table? */
-	return !list_empty(&peer->ibp_list);
+	/* Am I in the peer_ni hash table? */
+	return !list_empty(&peer_ni->ibp_list);
 }
 
 static inline struct kib_conn *
-kiblnd_get_conn_locked(struct kib_peer *peer)
+kiblnd_get_conn_locked(struct kib_peer_ni *peer_ni)
 {
 	struct list_head *next;
 
-	LASSERT(!list_empty(&peer->ibp_conns));
+	LASSERT(!list_empty(&peer_ni->ibp_conns));
 
 	/* Advance to next connection, be sure to skip the head node */
-	if (!peer->ibp_next_conn ||
-	    peer->ibp_next_conn->ibc_list.next == &peer->ibp_conns)
-		next = peer->ibp_conns.next;
+	if (!peer_ni->ibp_next_conn ||
+	    peer_ni->ibp_next_conn->ibc_list.next == &peer_ni->ibp_conns)
+		next = peer_ni->ibp_conns.next;
 	else
-		next = peer->ibp_next_conn->ibc_list.next;
-	peer->ibp_next_conn = list_entry(next, struct kib_conn, ibc_list);
+		next = peer_ni->ibp_next_conn->ibc_list.next;
+	peer_ni->ibp_next_conn = list_entry(next, struct kib_conn, ibc_list);
 
-	return peer->ibp_next_conn;
+	return peer_ni->ibp_next_conn;
 }
 
 static inline int
@@ -1013,18 +1015,18 @@ int  kiblnd_cm_callback(struct rdma_cm_id *cmid,
 int  kiblnd_translate_mtu(int value);
 
 int  kiblnd_dev_failover(struct kib_dev *dev);
-int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer **peerp,
+int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer_ni **peerp,
 		       lnet_nid_t nid);
-void kiblnd_destroy_peer(struct kib_peer *peer);
-bool kiblnd_reconnect_peer(struct kib_peer *peer);
+void kiblnd_destroy_peer(struct kib_peer_ni *peer_ni);
+bool kiblnd_reconnect_peer(struct kib_peer_ni *peer_ni);
 void kiblnd_destroy_dev(struct kib_dev *dev);
-void kiblnd_unlink_peer_locked(struct kib_peer *peer);
-struct kib_peer *kiblnd_find_peer_locked(struct lnet_ni *ni, lnet_nid_t nid);
-int  kiblnd_close_stale_conns_locked(struct kib_peer *peer,
+void kiblnd_unlink_peer_locked(struct kib_peer_ni *peer_ni);
+struct kib_peer_ni *kiblnd_find_peer_locked(struct lnet_ni *ni, lnet_nid_t nid);
+int  kiblnd_close_stale_conns_locked(struct kib_peer_ni *peer_ni,
 				     int version, __u64 incarnation);
-int  kiblnd_close_peer_conns_locked(struct kib_peer *peer, int why);
+int  kiblnd_close_peer_conns_locked(struct kib_peer_ni *peer_ni, int why);
 
-struct kib_conn *kiblnd_create_conn(struct kib_peer *peer,
+struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 				    struct rdma_cm_id *cmid,
 				    int state, int version);
 void kiblnd_destroy_conn(struct kib_conn *conn);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index f4b76347e1c6..cb752dcd35d9 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -40,8 +40,9 @@
 
 #define MAX_CONN_RACES_BEFORE_ABORT 20
 
-static void kiblnd_peer_alive(struct kib_peer *peer);
-static void kiblnd_peer_connect_failed(struct kib_peer *peer, int active, int error);
+static void kiblnd_peer_alive(struct kib_peer_ni *peer_ni);
+static void kiblnd_peer_connect_failed(struct kib_peer_ni *peer_ni, int active,
+				       int error);
 static void kiblnd_init_tx_msg(struct lnet_ni *ni, struct kib_tx *tx,
 			       int type, int body_nob);
 static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
@@ -62,9 +63,9 @@ kiblnd_tx_done(struct lnet_ni *ni, struct kib_tx *tx)
 
 	LASSERT(net);
 	LASSERT(!in_interrupt());
-	LASSERT(!tx->tx_queued);	       /* mustn't be queued for sending */
-	LASSERT(!tx->tx_sending);	  /* mustn't be awaiting sent callback */
-	LASSERT(!tx->tx_waiting);	      /* mustn't be awaiting peer response */
+	LASSERT(!tx->tx_queued);     /* mustn't be queued for sending */
+	LASSERT(!tx->tx_sending);    /* mustn't be awaiting sent callback */
+	LASSERT(!tx->tx_waiting);    /* mustn't be awaiting peer_ni response */
 	LASSERT(tx->tx_pool);
 
 	kiblnd_unmap_tx(tx);
@@ -414,7 +415,7 @@ kiblnd_handle_rx(struct kib_rx *rx)
 		LASSERT(tx->tx_waiting);
 		/*
 		 * CAVEAT EMPTOR: I could be racing with tx_complete, but...
-		 * (a) I can overwrite tx_msg since my peer has received it!
+		 * (a) I can overwrite tx_msg since my peer_ni has received it!
 		 * (b) tx_waiting set tells tx_complete() it's not done.
 		 */
 		tx->tx_nwrq = 0;		/* overwrite PUT_REQ */
@@ -579,8 +580,8 @@ kiblnd_fmr_map_tx(struct kib_net *net, struct kib_tx *tx, struct kib_rdma_desc *
 	}
 
 	/*
-	 * If rd is not tx_rd, it's going to get sent to a peer, who will need
-	 * the rkey
+	 * If rd is not tx_rd, it's going to get sent to a peer_ni,
+	 * who will need the rkey
 	 */
 	rd->rd_key = tx->fmr.fmr_key;
 	rd->rd_frags[0].rf_addr &= ~hdev->ibh_page_mask;
@@ -611,7 +612,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	int i;
 
 	/*
-	 * If rd is not tx_rd, it's going to get sent to a peer and I'm the
+	 * If rd is not tx_rd, it's going to get sent to a peer_ni and I'm the
 	 * RDMA sink
 	 */
 	tx->tx_dmadir = (rd != tx->tx_rd) ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
@@ -742,8 +743,8 @@ kiblnd_post_tx_locked(struct kib_conn *conn, struct kib_tx *tx, int credit)
 	__must_hold(&conn->ibc_lock)
 {
 	struct kib_msg *msg = tx->tx_msg;
-	struct kib_peer *peer = conn->ibc_peer;
-	struct lnet_ni *ni = peer->ibp_ni;
+	struct kib_peer_ni *peer_ni = conn->ibc_peer;
+	struct lnet_ni *ni = peer_ni->ibp_ni;
 	int ver = conn->ibc_version;
 	int rc;
 	int done;
@@ -761,13 +762,13 @@ kiblnd_post_tx_locked(struct kib_conn *conn, struct kib_tx *tx, int credit)
 	if (conn->ibc_nsends_posted == kiblnd_concurrent_sends(ver, ni)) {
 		/* tx completions outstanding... */
 		CDEBUG(D_NET, "%s: posted enough\n",
-		       libcfs_nid2str(peer->ibp_nid));
+		       libcfs_nid2str(peer_ni->ibp_nid));
 		return -EAGAIN;
 	}
 
 	if (credit && !conn->ibc_credits) {   /* no credits */
 		CDEBUG(D_NET, "%s: no credits\n",
-		       libcfs_nid2str(peer->ibp_nid));
+		       libcfs_nid2str(peer_ni->ibp_nid));
 		return -EAGAIN;
 	}
 
@@ -775,7 +776,7 @@ kiblnd_post_tx_locked(struct kib_conn *conn, struct kib_tx *tx, int credit)
 	    conn->ibc_credits == 1 &&   /* last credit reserved */
 	    msg->ibm_type != IBLND_MSG_NOOP) {      /* for NOOP */
 		CDEBUG(D_NET, "%s: not using last credit\n",
-		       libcfs_nid2str(peer->ibp_nid));
+		       libcfs_nid2str(peer_ni->ibp_nid));
 		return -EAGAIN;
 	}
 
@@ -793,16 +794,17 @@ kiblnd_post_tx_locked(struct kib_conn *conn, struct kib_tx *tx, int credit)
 		 * posted NOOPs complete
 		 */
 		spin_unlock(&conn->ibc_lock);
-		kiblnd_tx_done(peer->ibp_ni, tx);
+		kiblnd_tx_done(peer_ni->ibp_ni, tx);
 		spin_lock(&conn->ibc_lock);
 		CDEBUG(D_NET, "%s(%d): redundant or enough NOOP\n",
-		       libcfs_nid2str(peer->ibp_nid),
+		       libcfs_nid2str(peer_ni->ibp_nid),
 		       conn->ibc_noops_posted);
 		return 0;
 	}
 
-	kiblnd_pack_msg(peer->ibp_ni, msg, ver, conn->ibc_outstanding_credits,
-			peer->ibp_nid, conn->ibc_incarnation);
+	kiblnd_pack_msg(peer_ni->ibp_ni, msg, ver,
+			conn->ibc_outstanding_credits,
+			peer_ni->ibp_nid, conn->ibc_incarnation);
 
 	conn->ibc_credits -= credit;
 	conn->ibc_outstanding_credits = 0;
@@ -844,7 +846,7 @@ kiblnd_post_tx_locked(struct kib_conn *conn, struct kib_tx *tx, int credit)
 		}
 
 		LASSERTF(bad->wr_id == kiblnd_ptr2wreqid(tx, IBLND_WID_TX),
-			 "bad wr_id %llx, opc %d, flags %d, peer: %s\n",
+			 "bad wr_id %llx, opc %d, flags %d, peer_ni: %s\n",
 			 bad->wr_id, bad->opcode, bad->send_flags,
 			 libcfs_nid2str(conn->ibc_peer->ibp_nid));
 		bad = NULL;
@@ -878,15 +880,15 @@ kiblnd_post_tx_locked(struct kib_conn *conn, struct kib_tx *tx, int credit)
 
 	if (conn->ibc_state == IBLND_CONN_ESTABLISHED)
 		CERROR("Error %d posting transmit to %s\n",
-		       rc, libcfs_nid2str(peer->ibp_nid));
+		       rc, libcfs_nid2str(peer_ni->ibp_nid));
 	else
 		CDEBUG(D_NET, "Error %d posting transmit to %s\n",
-		       rc, libcfs_nid2str(peer->ibp_nid));
+		       rc, libcfs_nid2str(peer_ni->ibp_nid));
 
 	kiblnd_close_conn(conn, rc);
 
 	if (done)
-		kiblnd_tx_done(peer->ibp_ni, tx);
+		kiblnd_tx_done(peer_ni->ibp_ni, tx);
 
 	spin_lock(&conn->ibc_lock);
 
@@ -991,12 +993,12 @@ kiblnd_tx_complete(struct kib_tx *tx, int status)
 		conn->ibc_noops_posted--;
 
 	if (failed) {
-		tx->tx_waiting = 0;	     /* don't wait for peer */
+		tx->tx_waiting = 0;	     /* don't wait for peer_ni */
 		tx->tx_status = -EIO;
 	}
 
 	idle = !tx->tx_sending &&	 /* This is the final callback */
-	       !tx->tx_waiting &&	       /* Not waiting for peer */
+	       !tx->tx_waiting &&	       /* Not waiting for peer_ni */
 	       !tx->tx_queued;		  /* Not re-queued (PUT_DONE) */
 	if (idle)
 		list_del(&tx->tx_list);
@@ -1058,7 +1060,7 @@ kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 		type == IBLND_MSG_PUT_DONE);
 
 	if (kiblnd_rd_size(srcrd) > conn->ibc_max_frags << PAGE_SHIFT) {
-		CERROR("RDMA is too large for peer %s (%d), src size: %d dst size: %d\n",
+		CERROR("RDMA is too large for peer_ni %s (%d), src size: %d dst size: %d\n",
 		       libcfs_nid2str(conn->ibc_peer->ibp_nid),
 		       conn->ibc_max_frags << PAGE_SHIFT,
 		       kiblnd_rd_size(srcrd), kiblnd_rd_size(dstrd));
@@ -1080,7 +1082,7 @@ kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 		}
 
 		if (tx->tx_nwrq >= IBLND_MAX_RDMA_FRAGS) {
-			CERROR("RDMA has too many fragments for peer %s (%d), src idx/frags: %d/%d dst idx/frags: %d/%d\n",
+			CERROR("RDMA has too many fragments for peer_ni %s (%d), src idx/frags: %d/%d dst idx/frags: %d/%d\n",
 			       libcfs_nid2str(conn->ibc_peer->ibp_nid),
 			       IBLND_MAX_RDMA_FRAGS,
 			       srcidx, srcrd->rd_nfrags,
@@ -1234,24 +1236,24 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 }
 
 static void
-kiblnd_connect_peer(struct kib_peer *peer)
+kiblnd_connect_peer(struct kib_peer_ni *peer_ni)
 {
 	struct rdma_cm_id *cmid;
 	struct kib_dev *dev;
-	struct kib_net *net = peer->ibp_ni->ni_data;
+	struct kib_net *net = peer_ni->ibp_ni->ni_data;
 	struct sockaddr_in srcaddr;
 	struct sockaddr_in dstaddr;
 	int rc;
 
 	LASSERT(net);
-	LASSERT(peer->ibp_connecting > 0);
+	LASSERT(peer_ni->ibp_connecting > 0);
 
-	cmid = kiblnd_rdma_create_id(kiblnd_cm_callback, peer, RDMA_PS_TCP,
+	cmid = kiblnd_rdma_create_id(kiblnd_cm_callback, peer_ni, RDMA_PS_TCP,
 				     IB_QPT_RC);
 
 	if (IS_ERR(cmid)) {
 		CERROR("Can't create CMID for %s: %ld\n",
-		       libcfs_nid2str(peer->ibp_nid), PTR_ERR(cmid));
+		       libcfs_nid2str(peer_ni->ibp_nid), PTR_ERR(cmid));
 		rc = PTR_ERR(cmid);
 		goto failed;
 	}
@@ -1264,9 +1266,9 @@ kiblnd_connect_peer(struct kib_peer *peer)
 	memset(&dstaddr, 0, sizeof(dstaddr));
 	dstaddr.sin_family = AF_INET;
 	dstaddr.sin_port = htons(*kiblnd_tunables.kib_service);
-	dstaddr.sin_addr.s_addr = htonl(LNET_NIDADDR(peer->ibp_nid));
+	dstaddr.sin_addr.s_addr = htonl(LNET_NIDADDR(peer_ni->ibp_nid));
 
-	kiblnd_peer_addref(peer);	       /* cmid's ref */
+	kiblnd_peer_addref(peer_ni);	       /* cmid's ref */
 
 	if (*kiblnd_tunables.kib_use_priv_port) {
 		rc = kiblnd_resolve_addr(cmid, &srcaddr, &dstaddr,
@@ -1280,23 +1282,23 @@ kiblnd_connect_peer(struct kib_peer *peer)
 	if (rc) {
 		/* Can't initiate address resolution:  */
 		CERROR("Can't resolve addr for %s: %d\n",
-		       libcfs_nid2str(peer->ibp_nid), rc);
+		       libcfs_nid2str(peer_ni->ibp_nid), rc);
 		goto failed2;
 	}
 
 	return;
 
  failed2:
-	kiblnd_peer_connect_failed(peer, 1, rc);
-	kiblnd_peer_decref(peer);	       /* cmid's ref */
+	kiblnd_peer_connect_failed(peer_ni, 1, rc);
+	kiblnd_peer_decref(peer_ni);	       /* cmid's ref */
 	rdma_destroy_id(cmid);
 	return;
  failed:
-	kiblnd_peer_connect_failed(peer, 1, rc);
+	kiblnd_peer_connect_failed(peer_ni, 1, rc);
 }
 
 bool
-kiblnd_reconnect_peer(struct kib_peer *peer)
+kiblnd_reconnect_peer(struct kib_peer_ni *peer_ni)
 {
 	rwlock_t *glock = &kiblnd_data.kib_global_lock;
 	char *reason = NULL;
@@ -1306,12 +1308,12 @@ kiblnd_reconnect_peer(struct kib_peer *peer)
 	INIT_LIST_HEAD(&txs);
 
 	write_lock_irqsave(glock, flags);
-	if (!peer->ibp_reconnecting) {
-		if (peer->ibp_accepting)
+	if (!peer_ni->ibp_reconnecting) {
+		if (peer_ni->ibp_accepting)
 			reason = "accepting";
-		else if (peer->ibp_connecting)
+		else if (peer_ni->ibp_connecting)
 			reason = "connecting";
-		else if (!list_empty(&peer->ibp_conns))
+		else if (!list_empty(&peer_ni->ibp_conns))
 			reason = "connected";
 		else /* connected then closed */
 			reason = "closed";
@@ -1319,37 +1321,37 @@ kiblnd_reconnect_peer(struct kib_peer *peer)
 		goto no_reconnect;
 	}
 
-	LASSERT(!peer->ibp_accepting && !peer->ibp_connecting &&
-		list_empty(&peer->ibp_conns));
-	peer->ibp_reconnecting--;
+	LASSERT(!peer_ni->ibp_accepting && !peer_ni->ibp_connecting &&
+		list_empty(&peer_ni->ibp_conns));
+	peer_ni->ibp_reconnecting--;
 
-	if (!kiblnd_peer_active(peer)) {
-		list_splice_init(&peer->ibp_tx_queue, &txs);
+	if (!kiblnd_peer_active(peer_ni)) {
+		list_splice_init(&peer_ni->ibp_tx_queue, &txs);
 		reason = "unlinked";
 		goto no_reconnect;
 	}
 
-	peer->ibp_connecting++;
-	peer->ibp_reconnected++;
+	peer_ni->ibp_connecting++;
+	peer_ni->ibp_reconnected++;
 	write_unlock_irqrestore(glock, flags);
 
-	kiblnd_connect_peer(peer);
+	kiblnd_connect_peer(peer_ni);
 	return true;
 
 no_reconnect:
 	write_unlock_irqrestore(glock, flags);
 
 	CWARN("Abort reconnection of %s: %s\n",
-	      libcfs_nid2str(peer->ibp_nid), reason);
-	kiblnd_txlist_done(peer->ibp_ni, &txs, -ECONNABORTED);
+	      libcfs_nid2str(peer_ni->ibp_nid), reason);
+	kiblnd_txlist_done(peer_ni->ibp_ni, &txs, -ECONNABORTED);
 	return false;
 }
 
 void
 kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 {
-	struct kib_peer *peer;
-	struct kib_peer *peer2;
+	struct kib_peer_ni *peer_ni;
+	struct kib_peer_ni *peer2;
 	struct kib_conn *conn;
 	rwlock_t *g_lock = &kiblnd_data.kib_global_lock;
 	unsigned long flags;
@@ -1370,10 +1372,10 @@ kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 	 */
 	read_lock_irqsave(g_lock, flags);
 
-	peer = kiblnd_find_peer_locked(ni, nid);
-	if (peer && !list_empty(&peer->ibp_conns)) {
-		/* Found a peer with an established connection */
-		conn = kiblnd_get_conn_locked(peer);
+	peer_ni = kiblnd_find_peer_locked(ni, nid);
+	if (peer_ni && !list_empty(&peer_ni->ibp_conns)) {
+		/* Found a peer_ni with an established connection */
+		conn = kiblnd_get_conn_locked(peer_ni);
 		kiblnd_conn_addref(conn); /* 1 ref for me... */
 
 		read_unlock_irqrestore(g_lock, flags);
@@ -1388,17 +1390,17 @@ kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 	/* Re-try with a write lock */
 	write_lock(g_lock);
 
-	peer = kiblnd_find_peer_locked(ni, nid);
-	if (peer) {
-		if (list_empty(&peer->ibp_conns)) {
-			/* found a peer, but it's still connecting... */
-			LASSERT(kiblnd_peer_connecting(peer));
+	peer_ni = kiblnd_find_peer_locked(ni, nid);
+	if (peer_ni) {
+		if (list_empty(&peer_ni->ibp_conns)) {
+			/* found a peer_ni, but it's still connecting... */
+			LASSERT(kiblnd_peer_connecting(peer_ni));
 			if (tx)
 				list_add_tail(&tx->tx_list,
-					      &peer->ibp_tx_queue);
+					      &peer_ni->ibp_tx_queue);
 			write_unlock_irqrestore(g_lock, flags);
 		} else {
-			conn = kiblnd_get_conn_locked(peer);
+			conn = kiblnd_get_conn_locked(peer_ni);
 			kiblnd_conn_addref(conn); /* 1 ref for me... */
 
 			write_unlock_irqrestore(g_lock, flags);
@@ -1412,10 +1414,10 @@ kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 
 	write_unlock_irqrestore(g_lock, flags);
 
-	/* Allocate a peer ready to add to the peer table and retry */
-	rc = kiblnd_create_peer(ni, &peer, nid);
+	/* Allocate a peer_ni ready to add to the peer_ni table and retry */
+	rc = kiblnd_create_peer(ni, &peer_ni, nid);
 	if (rc) {
-		CERROR("Can't create peer %s\n", libcfs_nid2str(nid));
+		CERROR("Can't create peer_ni %s\n", libcfs_nid2str(nid));
 		if (tx) {
 			tx->tx_status = -EHOSTUNREACH;
 			tx->tx_waiting = 0;
@@ -1429,7 +1431,7 @@ kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 	peer2 = kiblnd_find_peer_locked(ni, nid);
 	if (peer2) {
 		if (list_empty(&peer2->ibp_conns)) {
-			/* found a peer, but it's still connecting... */
+			/* found a peer_ni, but it's still connecting... */
 			LASSERT(kiblnd_peer_connecting(peer2));
 			if (tx)
 				list_add_tail(&tx->tx_list,
@@ -1446,29 +1448,29 @@ kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 			kiblnd_conn_decref(conn); /* ...to here */
 		}
 
-		kiblnd_peer_decref(peer);
+		kiblnd_peer_decref(peer_ni);
 		return;
 	}
 
-	/* Brand new peer */
-	LASSERT(!peer->ibp_connecting);
-	tunables = &peer->ibp_ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
-	peer->ibp_connecting = tunables->lnd_conns_per_peer;
+	/* Brand new peer_ni */
+	LASSERT(!peer_ni->ibp_connecting);
+	tunables = &peer_ni->ibp_ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
+	peer_ni->ibp_connecting = tunables->lnd_conns_per_peer;
 
 	/* always called with a ref on ni, which prevents ni being shutdown */
 	LASSERT(!((struct kib_net *)ni->ni_data)->ibn_shutdown);
 
 	if (tx)
-		list_add_tail(&tx->tx_list, &peer->ibp_tx_queue);
+		list_add_tail(&tx->tx_list, &peer_ni->ibp_tx_queue);
 
-	kiblnd_peer_addref(peer);
-	list_add_tail(&peer->ibp_list, kiblnd_nid2peerlist(nid));
+	kiblnd_peer_addref(peer_ni);
+	list_add_tail(&peer_ni->ibp_list, kiblnd_nid2peerlist(nid));
 
 	write_unlock_irqrestore(g_lock, flags);
 
 	for (i = 0; i < tunables->lnd_conns_per_peer; i++)
-		kiblnd_connect_peer(peer);
-	kiblnd_peer_decref(peer);
+		kiblnd_connect_peer(peer_ni);
+	kiblnd_peer_decref(peer_ni);
 }
 
 int
@@ -1787,7 +1789,7 @@ kiblnd_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
 			CERROR("Can't setup PUT sink for %s: %d\n",
 			       libcfs_nid2str(conn->ibc_peer->ibp_nid), rc);
 			kiblnd_tx_done(ni, tx);
-			/* tell peer it's over */
+			/* tell peer_ni it's over */
 			kiblnd_send_completion(rx->rx_conn, IBLND_MSG_PUT_NAK, rc,
 					       rxmsg->ibm_u.putreq.ibprm_cookie);
 			break;
@@ -1844,15 +1846,15 @@ kiblnd_thread_fini(void)
 }
 
 static void
-kiblnd_peer_alive(struct kib_peer *peer)
+kiblnd_peer_alive(struct kib_peer_ni *peer_ni)
 {
 	/* This is racy, but everyone's only writing ktime_get_seconds() */
-	peer->ibp_last_alive = ktime_get_seconds();
+	peer_ni->ibp_last_alive = ktime_get_seconds();
 	mb();
 }
 
 static void
-kiblnd_peer_notify(struct kib_peer *peer)
+kiblnd_peer_notify(struct kib_peer_ni *peer_ni)
 {
 	int error = 0;
 	time64_t last_alive = 0;
@@ -1860,18 +1862,18 @@ kiblnd_peer_notify(struct kib_peer *peer)
 
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
-	if (kiblnd_peer_idle(peer) && peer->ibp_error) {
-		error = peer->ibp_error;
-		peer->ibp_error = 0;
+	if (kiblnd_peer_idle(peer_ni) && peer_ni->ibp_error) {
+		error = peer_ni->ibp_error;
+		peer_ni->ibp_error = 0;
 
-		last_alive = peer->ibp_last_alive;
+		last_alive = peer_ni->ibp_last_alive;
 	}
 
 	read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
 	if (error)
-		lnet_notify(peer->ibp_ni,
-			    peer->ibp_nid, 0, last_alive);
+		lnet_notify(peer_ni->ibp_ni,
+			    peer_ni->ibp_nid, 0, last_alive);
 }
 
 void
@@ -1885,7 +1887,7 @@ kiblnd_close_conn_locked(struct kib_conn *conn, int error)
 	 * already dealing with it (either to set it up or tear it down).
 	 * Caller holds kib_global_lock exclusively in irq context
 	 */
-	struct kib_peer *peer = conn->ibc_peer;
+	struct kib_peer_ni *peer_ni = conn->ibc_peer;
 	struct kib_dev *dev;
 	unsigned long flags;
 
@@ -1904,10 +1906,10 @@ kiblnd_close_conn_locked(struct kib_conn *conn, int error)
 	    list_empty(&conn->ibc_tx_queue_nocred) &&
 	    list_empty(&conn->ibc_active_txs)) {
 		CDEBUG(D_NET, "closing conn to %s\n",
-		       libcfs_nid2str(peer->ibp_nid));
+		       libcfs_nid2str(peer_ni->ibp_nid));
 	} else {
 		CNETERR("Closing conn to %s: error %d%s%s%s%s%s\n",
-			libcfs_nid2str(peer->ibp_nid), error,
+			libcfs_nid2str(peer_ni->ibp_nid), error,
 			list_empty(&conn->ibc_tx_queue) ? "" : "(sending)",
 			list_empty(&conn->ibc_tx_noops) ? "" : "(sending_noops)",
 			list_empty(&conn->ibc_tx_queue_rsrvd) ? "" : "(sending_rsrvd)",
@@ -1915,19 +1917,19 @@ kiblnd_close_conn_locked(struct kib_conn *conn, int error)
 			list_empty(&conn->ibc_active_txs) ? "" : "(waiting)");
 	}
 
-	dev = ((struct kib_net *)peer->ibp_ni->ni_data)->ibn_dev;
-	if (peer->ibp_next_conn == conn)
+	dev = ((struct kib_net *)peer_ni->ibp_ni->ni_data)->ibn_dev;
+	if (peer_ni->ibp_next_conn == conn)
 		/* clear next_conn so it won't be used */
-		peer->ibp_next_conn = NULL;
+		peer_ni->ibp_next_conn = NULL;
 	list_del(&conn->ibc_list);
 	/* connd (see below) takes over ibc_list's ref */
 
-	if (list_empty(&peer->ibp_conns) &&    /* no more conns */
-	    kiblnd_peer_active(peer)) {	 /* still in peer table */
-		kiblnd_unlink_peer_locked(peer);
+	if (list_empty(&peer_ni->ibp_conns) &&    /* no more conns */
+	    kiblnd_peer_active(peer_ni)) {	 /* still in peer_ni table */
+		kiblnd_unlink_peer_locked(peer_ni);
 
 		/* set/clear error on last conn */
-		peer->ibp_error = conn->ibc_comms_error;
+		peer_ni->ibp_error = conn->ibc_comms_error;
 	}
 
 	kiblnd_set_conn_state(conn, IBLND_CONN_CLOSING);
@@ -2046,7 +2048,7 @@ kiblnd_finalise_conn(struct kib_conn *conn)
 }
 
 static void
-kiblnd_peer_connect_failed(struct kib_peer *peer, int active, int error)
+kiblnd_peer_connect_failed(struct kib_peer_ni *peer_ni, int active, int error)
 {
 	LIST_HEAD(zombies);
 	unsigned long flags;
@@ -2057,52 +2059,52 @@ kiblnd_peer_connect_failed(struct kib_peer *peer, int active, int error)
 	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
 	if (active) {
-		LASSERT(peer->ibp_connecting > 0);
-		peer->ibp_connecting--;
+		LASSERT(peer_ni->ibp_connecting > 0);
+		peer_ni->ibp_connecting--;
 	} else {
-		LASSERT(peer->ibp_accepting > 0);
-		peer->ibp_accepting--;
+		LASSERT(peer_ni->ibp_accepting > 0);
+		peer_ni->ibp_accepting--;
 	}
 
-	if (kiblnd_peer_connecting(peer)) {
+	if (kiblnd_peer_connecting(peer_ni)) {
 		/* another connection attempt under way... */
 		write_unlock_irqrestore(&kiblnd_data.kib_global_lock,
 					flags);
 		return;
 	}
 
-	peer->ibp_reconnected = 0;
-	if (list_empty(&peer->ibp_conns)) {
-		/* Take peer's blocked transmits to complete with error */
-		list_add(&zombies, &peer->ibp_tx_queue);
-		list_del_init(&peer->ibp_tx_queue);
+	peer_ni->ibp_reconnected = 0;
+	if (list_empty(&peer_ni->ibp_conns)) {
+		/* Take peer_ni's blocked transmits to complete with error */
+		list_add(&zombies, &peer_ni->ibp_tx_queue);
+		list_del_init(&peer_ni->ibp_tx_queue);
 
-		if (kiblnd_peer_active(peer))
-			kiblnd_unlink_peer_locked(peer);
+		if (kiblnd_peer_active(peer_ni))
+			kiblnd_unlink_peer_locked(peer_ni);
 
-		peer->ibp_error = error;
+		peer_ni->ibp_error = error;
 	} else {
 		/* Can't have blocked transmits if there are connections */
-		LASSERT(list_empty(&peer->ibp_tx_queue));
+		LASSERT(list_empty(&peer_ni->ibp_tx_queue));
 	}
 
 	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
-	kiblnd_peer_notify(peer);
+	kiblnd_peer_notify(peer_ni);
 
 	if (list_empty(&zombies))
 		return;
 
 	CNETERR("Deleting messages for %s: connection failed\n",
-		libcfs_nid2str(peer->ibp_nid));
+		libcfs_nid2str(peer_ni->ibp_nid));
 
-	kiblnd_txlist_done(peer->ibp_ni, &zombies, -EHOSTUNREACH);
+	kiblnd_txlist_done(peer_ni->ibp_ni, &zombies, -EHOSTUNREACH);
 }
 
 static void
 kiblnd_connreq_done(struct kib_conn *conn, int status)
 {
-	struct kib_peer *peer = conn->ibc_peer;
+	struct kib_peer_ni *peer_ni = conn->ibc_peer;
 	struct kib_tx *tx;
 	struct list_head txs;
 	unsigned long flags;
@@ -2111,21 +2113,21 @@ kiblnd_connreq_done(struct kib_conn *conn, int status)
 	active = (conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT);
 
 	CDEBUG(D_NET, "%s: active(%d), version(%x), status(%d)\n",
-	       libcfs_nid2str(peer->ibp_nid), active,
+	       libcfs_nid2str(peer_ni->ibp_nid), active,
 	       conn->ibc_version, status);
 
 	LASSERT(!in_interrupt());
 	LASSERT((conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT &&
-		 peer->ibp_connecting > 0) ||
+		 peer_ni->ibp_connecting > 0) ||
 		 (conn->ibc_state == IBLND_CONN_PASSIVE_WAIT &&
-		 peer->ibp_accepting > 0));
+		 peer_ni->ibp_accepting > 0));
 
 	kfree(conn->ibc_connvars);
 	conn->ibc_connvars = NULL;
 
 	if (status) {
 		/* failed to establish connection */
-		kiblnd_peer_connect_failed(peer, active, status);
+		kiblnd_peer_connect_failed(peer_ni, active, status);
 		kiblnd_finalise_conn(conn);
 		return;
 	}
@@ -2135,40 +2137,40 @@ kiblnd_connreq_done(struct kib_conn *conn, int status)
 
 	conn->ibc_last_send = ktime_get();
 	kiblnd_set_conn_state(conn, IBLND_CONN_ESTABLISHED);
-	kiblnd_peer_alive(peer);
+	kiblnd_peer_alive(peer_ni);
 
 	/*
-	 * Add conn to peer's list and nuke any dangling conns from a different
-	 * peer instance...
+	 * Add conn to peer_ni's list and nuke any dangling conns from
+	 * a different peer_ni instance...
 	 */
 	kiblnd_conn_addref(conn);	       /* +1 ref for ibc_list */
-	list_add(&conn->ibc_list, &peer->ibp_conns);
-	peer->ibp_reconnected = 0;
+	list_add(&conn->ibc_list, &peer_ni->ibp_conns);
+	peer_ni->ibp_reconnected = 0;
 	if (active)
-		peer->ibp_connecting--;
+		peer_ni->ibp_connecting--;
 	else
-		peer->ibp_accepting--;
+		peer_ni->ibp_accepting--;
 
-	if (!peer->ibp_version) {
-		peer->ibp_version     = conn->ibc_version;
-		peer->ibp_incarnation = conn->ibc_incarnation;
+	if (!peer_ni->ibp_version) {
+		peer_ni->ibp_version     = conn->ibc_version;
+		peer_ni->ibp_incarnation = conn->ibc_incarnation;
 	}
 
-	if (peer->ibp_version     != conn->ibc_version ||
-	    peer->ibp_incarnation != conn->ibc_incarnation) {
-		kiblnd_close_stale_conns_locked(peer, conn->ibc_version,
+	if (peer_ni->ibp_version     != conn->ibc_version ||
+	    peer_ni->ibp_incarnation != conn->ibc_incarnation) {
+		kiblnd_close_stale_conns_locked(peer_ni, conn->ibc_version,
 						conn->ibc_incarnation);
-		peer->ibp_version     = conn->ibc_version;
-		peer->ibp_incarnation = conn->ibc_incarnation;
+		peer_ni->ibp_version     = conn->ibc_version;
+		peer_ni->ibp_incarnation = conn->ibc_incarnation;
 	}
 
 	/* grab pending txs while I have the lock */
-	list_add(&txs, &peer->ibp_tx_queue);
-	list_del_init(&peer->ibp_tx_queue);
+	list_add(&txs, &peer_ni->ibp_tx_queue);
+	list_del_init(&peer_ni->ibp_tx_queue);
 
-	if (!kiblnd_peer_active(peer) ||	/* peer has been deleted */
+	if (!kiblnd_peer_active(peer_ni) ||	/* peer_ni has been deleted */
 	    conn->ibc_comms_error) {       /* error has happened already */
-		struct lnet_ni *ni = peer->ibp_ni;
+		struct lnet_ni *ni = peer_ni->ibp_ni;
 
 		/* start to shut down connection */
 		kiblnd_close_conn_locked(conn, -ECONNABORTED);
@@ -2181,7 +2183,7 @@ kiblnd_connreq_done(struct kib_conn *conn, int status)
 
 	/*
 	 * +1 ref for myself, this connection is visible to other threads
-	 * now, refcount of peer:ibp_conns can be released by connection
+	 * now, refcount of peer_ni:ibp_conns can be released by connection
 	 * close from either a different thread, or the calling of
 	 * kiblnd_check_sends_locked() below. See bz21911 for details.
 	 */
@@ -2227,8 +2229,8 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	struct kib_msg *reqmsg = priv;
 	struct kib_msg *ackmsg;
 	struct kib_dev *ibdev;
-	struct kib_peer *peer;
-	struct kib_peer *peer2;
+	struct kib_peer_ni *peer_ni;
+	struct kib_peer_ni *peer2;
 	struct kib_conn *conn;
 	struct lnet_ni *ni  = NULL;
 	struct kib_net *net = NULL;
@@ -2257,7 +2259,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	    ntohs(peer_addr->sin_port) >= PROT_SOCK) {
 		__u32 ip = ntohl(peer_addr->sin_addr.s_addr);
 
-		CERROR("Peer's port (%pI4h:%hu) is not privileged\n",
+		CERROR("peer_ni's port (%pI4h:%hu) is not privileged\n",
 		       &ip, ntohs(peer_addr->sin_port));
 		goto failed;
 	}
@@ -2272,7 +2274,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	 * o2iblnd-specific protocol changes, or when LNET unifies
 	 * protocols over all LNDs, the initial connection will
 	 * negotiate a protocol version.  I trap this here to avoid
-	 * console errors; the reject tells the peer which protocol I
+	 * console errors; the reject tells the peer_ni which protocol I
 	 * speak.
 	 */
 	if (reqmsg->ibm_magic == LNET_PROTO_MAGIC ||
@@ -2322,7 +2324,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		goto failed;
 	}
 
-	/* I can accept peer's version */
+	/* I can accept peer_ni's version */
 	version = reqmsg->ibm_version;
 
 	if (reqmsg->ibm_type != IBLND_MSG_CONNREQ) {
@@ -2374,17 +2376,17 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		goto failed;
 	}
 
-	/* assume 'nid' is a new peer; create  */
-	rc = kiblnd_create_peer(ni, &peer, nid);
+	/* assume 'nid' is a new peer_ni; create  */
+	rc = kiblnd_create_peer(ni, &peer_ni, nid);
 	if (rc) {
-		CERROR("Can't create peer for %s\n", libcfs_nid2str(nid));
+		CERROR("Can't create peer_ni for %s\n", libcfs_nid2str(nid));
 		rej.ibr_why = IBLND_REJECT_NO_RESOURCES;
 		goto failed;
 	}
 
-	/* We have validated the peer's parameters so use those */
-	peer->ibp_max_frags = max_frags;
-	peer->ibp_queue_depth = reqmsg->ibm_u.connparams.ibcp_queue_depth;
+	/* We have validated the peer_ni's parameters so use those */
+	peer_ni->ibp_max_frags = max_frags;
+	peer_ni->ibp_queue_depth = reqmsg->ibm_u.connparams.ibcp_queue_depth;
 
 	write_lock_irqsave(g_lock, flags);
 
@@ -2410,7 +2412,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 			      libcfs_nid2str(nid), peer2->ibp_version, version,
 			      peer2->ibp_incarnation, reqmsg->ibm_srcstamp);
 
-			kiblnd_peer_decref(peer);
+			kiblnd_peer_decref(peer_ni);
 			rej.ibr_why = IBLND_REJECT_CONN_STALE;
 			goto failed;
 		}
@@ -2432,7 +2434,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 			CDEBUG(D_NET, "Conn race %s\n",
 			       libcfs_nid2str(peer2->ibp_nid));
 
-			kiblnd_peer_decref(peer);
+			kiblnd_peer_decref(peer_ni);
 			rej.ibr_why = IBLND_REJECT_CONN_RACE;
 			goto failed;
 		}
@@ -2440,9 +2442,9 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 			CNETERR("Conn race %s: unresolved after %d attempts, letting lower NID win\n",
 				libcfs_nid2str(peer2->ibp_nid),
 				MAX_CONN_RACES_BEFORE_ABORT);
-		/**
-		 * passive connection is allowed even this peer is waiting for
-		 * reconnection.
+		/*
+		 * passive connection is allowed even this peer_ni is
+		 * waiting for reconnection.
 		 */
 		peer2->ibp_reconnecting = 0;
 		peer2->ibp_races = 0;
@@ -2452,38 +2454,38 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		/**
 		 * Race with kiblnd_launch_tx (active connect) to create peer
 		 * so copy validated parameters since we now know what the
-		 * peer's limits are
+		 * peer_ni's limits are
 		 */
-		peer2->ibp_max_frags = peer->ibp_max_frags;
-		peer2->ibp_queue_depth = peer->ibp_queue_depth;
+		peer2->ibp_max_frags = peer_ni->ibp_max_frags;
+		peer2->ibp_queue_depth = peer_ni->ibp_queue_depth;
 
 		write_unlock_irqrestore(g_lock, flags);
-		kiblnd_peer_decref(peer);
-		peer = peer2;
+		kiblnd_peer_decref(peer_ni);
+		peer_ni = peer2;
 	} else {
-		/* Brand new peer */
-		LASSERT(!peer->ibp_accepting);
-		LASSERT(!peer->ibp_version &&
-			!peer->ibp_incarnation);
+		/* Brand new peer_ni */
+		LASSERT(!peer_ni->ibp_accepting);
+		LASSERT(!peer_ni->ibp_version &&
+			!peer_ni->ibp_incarnation);
 
-		peer->ibp_accepting   = 1;
-		peer->ibp_version     = version;
-		peer->ibp_incarnation = reqmsg->ibm_srcstamp;
+		peer_ni->ibp_accepting   = 1;
+		peer_ni->ibp_version     = version;
+		peer_ni->ibp_incarnation = reqmsg->ibm_srcstamp;
 
 		/* I have a ref on ni that prevents it being shutdown */
 		LASSERT(!net->ibn_shutdown);
 
-		kiblnd_peer_addref(peer);
-		list_add_tail(&peer->ibp_list, kiblnd_nid2peerlist(nid));
+		kiblnd_peer_addref(peer_ni);
+		list_add_tail(&peer_ni->ibp_list, kiblnd_nid2peerlist(nid));
 
 		write_unlock_irqrestore(g_lock, flags);
 	}
 
-	conn = kiblnd_create_conn(peer, cmid, IBLND_CONN_PASSIVE_WAIT,
+	conn = kiblnd_create_conn(peer_ni, cmid, IBLND_CONN_PASSIVE_WAIT,
 				  version);
 	if (!conn) {
-		kiblnd_peer_connect_failed(peer, 0, -ENOMEM);
-		kiblnd_peer_decref(peer);
+		kiblnd_peer_connect_failed(peer_ni, 0, -ENOMEM);
+		kiblnd_peer_decref(peer_ni);
 		rej.ibr_why = IBLND_REJECT_NO_RESOURCES;
 		goto failed;
 	}
@@ -2552,7 +2554,7 @@ kiblnd_check_reconnect(struct kib_conn *conn, int version,
 		       __u64 incarnation, int why, struct kib_connparams *cp)
 {
 	rwlock_t *glock = &kiblnd_data.kib_global_lock;
-	struct kib_peer *peer = conn->ibc_peer;
+	struct kib_peer_ni *peer_ni = conn->ibc_peer;
 	char *reason;
 	int msg_size = IBLND_MSG_SIZE;
 	int frag_num = -1;
@@ -2561,7 +2563,7 @@ kiblnd_check_reconnect(struct kib_conn *conn, int version,
 	unsigned long flags;
 
 	LASSERT(conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT);
-	LASSERT(peer->ibp_connecting > 0);     /* 'conn' at least */
+	LASSERT(peer_ni->ibp_connecting > 0);     /* 'conn' at least */
 
 	if (cp) {
 		msg_size = cp->ibcp_max_msg_size;
@@ -2577,10 +2579,10 @@ kiblnd_check_reconnect(struct kib_conn *conn, int version,
 	 * empty if ibp_version != version because reconnect may be
 	 * initiated by kiblnd_query()
 	 */
-	reconnect = (!list_empty(&peer->ibp_tx_queue) ||
-		     peer->ibp_version != version) &&
-		    peer->ibp_connecting &&
-		    !peer->ibp_accepting;
+	reconnect = (!list_empty(&peer_ni->ibp_tx_queue) ||
+		     peer_ni->ibp_version != version) &&
+		    peer_ni->ibp_connecting &&
+		    !peer_ni->ibp_accepting;
 	if (!reconnect) {
 		reason = "no need";
 		goto out;
@@ -2598,7 +2600,7 @@ kiblnd_check_reconnect(struct kib_conn *conn, int version,
 			reason = "can't negotiate max frags";
 			goto out;
 		}
-		tunables = &peer->ibp_ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
+		tunables = &peer_ni->ibp_ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
 		if (!tunables->lnd_map_on_demand) {
 			reason = "map_on_demand must be enabled";
 			goto out;
@@ -2608,7 +2610,7 @@ kiblnd_check_reconnect(struct kib_conn *conn, int version,
 			goto out;
 		}
 
-		peer->ibp_max_frags = frag_num;
+		peer_ni->ibp_max_frags = frag_num;
 		reason = "rdma fragments";
 		break;
 	}
@@ -2622,7 +2624,7 @@ kiblnd_check_reconnect(struct kib_conn *conn, int version,
 			goto out;
 		}
 
-		peer->ibp_queue_depth = queue_dep;
+		peer_ni->ibp_queue_depth = queue_dep;
 		reason = "queue depth";
 		break;
 
@@ -2640,15 +2642,15 @@ kiblnd_check_reconnect(struct kib_conn *conn, int version,
 	}
 
 	conn->ibc_reconnect = 1;
-	peer->ibp_reconnecting++;
-	peer->ibp_version = version;
+	peer_ni->ibp_reconnecting++;
+	peer_ni->ibp_version = version;
 	if (incarnation)
-		peer->ibp_incarnation = incarnation;
+		peer_ni->ibp_incarnation = incarnation;
 out:
 	write_unlock_irqrestore(glock, flags);
 
 	CNETERR("%s: %s (%s), %x, %x, msg_size: %d, queue_depth: %d/%d, max_frags: %d/%d\n",
-		libcfs_nid2str(peer->ibp_nid),
+		libcfs_nid2str(peer_ni->ibp_nid),
 		reconnect ? "reconnect" : "don't reconnect",
 		reason, IBLND_MSG_VERSION, version, msg_size,
 		conn->ibc_queue_depth, queue_dep,
@@ -2662,7 +2664,7 @@ kiblnd_check_reconnect(struct kib_conn *conn, int version,
 static void
 kiblnd_rejected(struct kib_conn *conn, int reason, void *priv, int priv_nob)
 {
-	struct kib_peer *peer = conn->ibc_peer;
+	struct kib_peer_ni *peer_ni = conn->ibc_peer;
 
 	LASSERT(!in_interrupt());
 	LASSERT(conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT);
@@ -2675,7 +2677,7 @@ kiblnd_rejected(struct kib_conn *conn, int reason, void *priv, int priv_nob)
 
 	case IB_CM_REJ_INVALID_SERVICE_ID:
 		CNETERR("%s rejected: no listener at %d\n",
-			libcfs_nid2str(peer->ibp_nid),
+			libcfs_nid2str(peer_ni->ibp_nid),
 			*kiblnd_tunables.kib_service);
 		break;
 
@@ -2691,7 +2693,7 @@ kiblnd_rejected(struct kib_conn *conn, int reason, void *priv, int priv_nob)
 			 * b) V2 will provide incarnation while rejecting me,
 			 *    -1 will be overwrote.
 			 *
-			 * if I try to connect to a V1 peer with V2 protocol,
+			 * if I try to connect to a V1 peer_ni with V2 protocol,
 			 * it rejected me then upgrade to V2, I have no idea
 			 * about the upgrading and try to reconnect with V1,
 			 * in this case upgraded V2 can find out I'm trying to
@@ -2727,22 +2729,24 @@ kiblnd_rejected(struct kib_conn *conn, int reason, void *priv, int priv_nob)
 			if (rej->ibr_magic != IBLND_MSG_MAGIC &&
 			    rej->ibr_magic != LNET_PROTO_MAGIC) {
 				CERROR("%s rejected: consumer defined fatal error\n",
-				       libcfs_nid2str(peer->ibp_nid));
+				       libcfs_nid2str(peer_ni->ibp_nid));
 				break;
 			}
 
 			if (rej->ibr_version != IBLND_MSG_VERSION &&
 			    rej->ibr_version != IBLND_MSG_VERSION_1) {
 				CERROR("%s rejected: o2iblnd version %x error\n",
-				       libcfs_nid2str(peer->ibp_nid),
+				       libcfs_nid2str(peer_ni->ibp_nid),
 				       rej->ibr_version);
 				break;
 			}
 
 			if (rej->ibr_why     == IBLND_REJECT_FATAL &&
 			    rej->ibr_version == IBLND_MSG_VERSION_1) {
-				CDEBUG(D_NET, "rejected by old version peer %s: %x\n",
-				       libcfs_nid2str(peer->ibp_nid), rej->ibr_version);
+				CDEBUG(D_NET,
+				       "rejected by old version peer_ni %s: %x\n",
+				       libcfs_nid2str(peer_ni->ibp_nid),
+				       rej->ibr_version);
 
 				if (conn->ibc_version != IBLND_MSG_VERSION_1)
 					rej->ibr_why = IBLND_REJECT_CONN_UNCOMPAT;
@@ -2761,17 +2765,17 @@ kiblnd_rejected(struct kib_conn *conn, int reason, void *priv, int priv_nob)
 
 			case IBLND_REJECT_NO_RESOURCES:
 				CERROR("%s rejected: o2iblnd no resources\n",
-				       libcfs_nid2str(peer->ibp_nid));
+				       libcfs_nid2str(peer_ni->ibp_nid));
 				break;
 
 			case IBLND_REJECT_FATAL:
 				CERROR("%s rejected: o2iblnd fatal error\n",
-				       libcfs_nid2str(peer->ibp_nid));
+				       libcfs_nid2str(peer_ni->ibp_nid));
 				break;
 
 			default:
 				CERROR("%s rejected: o2iblnd reason %d\n",
-				       libcfs_nid2str(peer->ibp_nid),
+				       libcfs_nid2str(peer_ni->ibp_nid),
 				       rej->ibr_why);
 				break;
 			}
@@ -2780,7 +2784,7 @@ kiblnd_rejected(struct kib_conn *conn, int reason, void *priv, int priv_nob)
 		/* fall through */
 	default:
 		CNETERR("%s rejected: reason %d, size %d\n",
-			libcfs_nid2str(peer->ibp_nid), reason, priv_nob);
+			libcfs_nid2str(peer_ni->ibp_nid), reason, priv_nob);
 		break;
 	}
 
@@ -2790,8 +2794,8 @@ kiblnd_rejected(struct kib_conn *conn, int reason, void *priv, int priv_nob)
 static void
 kiblnd_check_connreply(struct kib_conn *conn, void *priv, int priv_nob)
 {
-	struct kib_peer *peer = conn->ibc_peer;
-	struct lnet_ni *ni = peer->ibp_ni;
+	struct kib_peer_ni *peer_ni = conn->ibc_peer;
+	struct lnet_ni *ni = peer_ni->ibp_ni;
 	struct kib_net *net = ni->ni_data;
 	struct kib_msg *msg = priv;
 	int ver = conn->ibc_version;
@@ -2802,20 +2806,20 @@ kiblnd_check_connreply(struct kib_conn *conn, void *priv, int priv_nob)
 
 	if (rc) {
 		CERROR("Can't unpack connack from %s: %d\n",
-		       libcfs_nid2str(peer->ibp_nid), rc);
+		       libcfs_nid2str(peer_ni->ibp_nid), rc);
 		goto failed;
 	}
 
 	if (msg->ibm_type != IBLND_MSG_CONNACK) {
 		CERROR("Unexpected message %d from %s\n",
-		       msg->ibm_type, libcfs_nid2str(peer->ibp_nid));
+		       msg->ibm_type, libcfs_nid2str(peer_ni->ibp_nid));
 		rc = -EPROTO;
 		goto failed;
 	}
 
 	if (ver != msg->ibm_version) {
 		CERROR("%s replied version %x is different with requested version %x\n",
-		       libcfs_nid2str(peer->ibp_nid), msg->ibm_version, ver);
+		       libcfs_nid2str(peer_ni->ibp_nid), msg->ibm_version, ver);
 		rc = -EPROTO;
 		goto failed;
 	}
@@ -2823,7 +2827,7 @@ kiblnd_check_connreply(struct kib_conn *conn, void *priv, int priv_nob)
 	if (msg->ibm_u.connparams.ibcp_queue_depth >
 	    conn->ibc_queue_depth) {
 		CERROR("%s has incompatible queue depth %d (<=%d wanted)\n",
-		       libcfs_nid2str(peer->ibp_nid),
+		       libcfs_nid2str(peer_ni->ibp_nid),
 		       msg->ibm_u.connparams.ibcp_queue_depth,
 		       conn->ibc_queue_depth);
 		rc = -EPROTO;
@@ -2833,7 +2837,7 @@ kiblnd_check_connreply(struct kib_conn *conn, void *priv, int priv_nob)
 	if ((msg->ibm_u.connparams.ibcp_max_frags >> IBLND_FRAG_SHIFT) >
 	    conn->ibc_max_frags) {
 		CERROR("%s has incompatible max_frags %d (<=%d wanted)\n",
-		       libcfs_nid2str(peer->ibp_nid),
+		       libcfs_nid2str(peer_ni->ibp_nid),
 		       msg->ibm_u.connparams.ibcp_max_frags >> IBLND_FRAG_SHIFT,
 		       conn->ibc_max_frags);
 		rc = -EPROTO;
@@ -2842,7 +2846,7 @@ kiblnd_check_connreply(struct kib_conn *conn, void *priv, int priv_nob)
 
 	if (msg->ibm_u.connparams.ibcp_max_msg_size > IBLND_MSG_SIZE) {
 		CERROR("%s max message size %d too big (%d max)\n",
-		       libcfs_nid2str(peer->ibp_nid),
+		       libcfs_nid2str(peer_ni->ibp_nid),
 		       msg->ibm_u.connparams.ibcp_max_msg_size,
 		       IBLND_MSG_SIZE);
 		rc = -EPROTO;
@@ -2859,7 +2863,7 @@ kiblnd_check_connreply(struct kib_conn *conn, void *priv, int priv_nob)
 
 	if (rc) {
 		CERROR("Bad connection reply from %s, rc = %d, version: %x max_frags: %d\n",
-		       libcfs_nid2str(peer->ibp_nid), rc,
+		       libcfs_nid2str(peer_ni->ibp_nid), rc,
 		       msg->ibm_version, msg->ibm_u.connparams.ibcp_max_frags);
 		goto failed;
 	}
@@ -2890,7 +2894,7 @@ kiblnd_check_connreply(struct kib_conn *conn, void *priv, int priv_nob)
 static int
 kiblnd_active_connect(struct rdma_cm_id *cmid)
 {
-	struct kib_peer *peer = (struct kib_peer *)cmid->context;
+	struct kib_peer_ni *peer_ni = (struct kib_peer_ni *)cmid->context;
 	struct kib_conn *conn;
 	struct kib_msg *msg;
 	struct rdma_conn_param cp;
@@ -2901,17 +2905,17 @@ kiblnd_active_connect(struct rdma_cm_id *cmid)
 
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
-	incarnation = peer->ibp_incarnation;
-	version = !peer->ibp_version ? IBLND_MSG_VERSION :
-				       peer->ibp_version;
+	incarnation = peer_ni->ibp_incarnation;
+	version = !peer_ni->ibp_version ? IBLND_MSG_VERSION :
+				       peer_ni->ibp_version;
 
 	read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
-	conn = kiblnd_create_conn(peer, cmid, IBLND_CONN_ACTIVE_CONNECT,
+	conn = kiblnd_create_conn(peer_ni, cmid, IBLND_CONN_ACTIVE_CONNECT,
 				  version);
 	if (!conn) {
-		kiblnd_peer_connect_failed(peer, 1, -ENOMEM);
-		kiblnd_peer_decref(peer); /* lose cmid's ref */
+		kiblnd_peer_connect_failed(peer_ni, 1, -ENOMEM);
+		kiblnd_peer_decref(peer_ni); /* lose cmid's ref */
 		return -ENOMEM;
 	}
 
@@ -2928,8 +2932,8 @@ kiblnd_active_connect(struct rdma_cm_id *cmid)
 	msg->ibm_u.connparams.ibcp_max_frags = conn->ibc_max_frags << IBLND_FRAG_SHIFT;
 	msg->ibm_u.connparams.ibcp_max_msg_size = IBLND_MSG_SIZE;
 
-	kiblnd_pack_msg(peer->ibp_ni, msg, version,
-			0, peer->ibp_nid, incarnation);
+	kiblnd_pack_msg(peer_ni->ibp_ni, msg, version,
+			0, peer_ni->ibp_nid, incarnation);
 
 	memset(&cp, 0, sizeof(cp));
 	cp.private_data	= msg;
@@ -2946,7 +2950,7 @@ kiblnd_active_connect(struct rdma_cm_id *cmid)
 	rc = rdma_connect(cmid, &cp);
 	if (rc) {
 		CERROR("Can't connect to %s: %d\n",
-		       libcfs_nid2str(peer->ibp_nid), rc);
+		       libcfs_nid2str(peer_ni->ibp_nid), rc);
 		kiblnd_connreq_done(conn, rc);
 		kiblnd_conn_decref(conn);
 	}
@@ -2957,7 +2961,7 @@ kiblnd_active_connect(struct rdma_cm_id *cmid)
 int
 kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 {
-	struct kib_peer *peer;
+	struct kib_peer_ni *peer_ni;
 	struct kib_conn *conn;
 	int rc;
 
@@ -2976,33 +2980,34 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		return rc;
 
 	case RDMA_CM_EVENT_ADDR_ERROR:
-		peer = (struct kib_peer *)cmid->context;
+		peer_ni = (struct kib_peer_ni *)cmid->context;
 		CNETERR("%s: ADDR ERROR %d\n",
-			libcfs_nid2str(peer->ibp_nid), event->status);
-		kiblnd_peer_connect_failed(peer, 1, -EHOSTUNREACH);
-		kiblnd_peer_decref(peer);
+			libcfs_nid2str(peer_ni->ibp_nid), event->status);
+		kiblnd_peer_connect_failed(peer_ni, 1, -EHOSTUNREACH);
+		kiblnd_peer_decref(peer_ni);
 		return -EHOSTUNREACH;      /* rc destroys cmid */
 
 	case RDMA_CM_EVENT_ADDR_RESOLVED:
-		peer = (struct kib_peer *)cmid->context;
+		peer_ni = (struct kib_peer_ni *)cmid->context;
 
 		CDEBUG(D_NET, "%s Addr resolved: %d\n",
-		       libcfs_nid2str(peer->ibp_nid), event->status);
+		       libcfs_nid2str(peer_ni->ibp_nid), event->status);
 
 		if (event->status) {
 			CNETERR("Can't resolve address for %s: %d\n",
-				libcfs_nid2str(peer->ibp_nid), event->status);
+				libcfs_nid2str(peer_ni->ibp_nid),
+				event->status);
 			rc = event->status;
 		} else {
 			rc = rdma_resolve_route(
 				cmid, *kiblnd_tunables.kib_timeout * 1000);
 			if (!rc) {
-				struct kib_net *net = peer->ibp_ni->ni_data;
+				struct kib_net *net = peer_ni->ibp_ni->ni_data;
 				struct kib_dev *dev = net->ibn_dev;
 
 				CDEBUG(D_NET, "%s: connection bound to "\
 				       "%s:%pI4h:%s\n",
-				       libcfs_nid2str(peer->ibp_nid),
+				       libcfs_nid2str(peer_ni->ibp_nid),
 				       dev->ibd_ifname,
 				       &dev->ibd_ifip, cmid->device->name);
 
@@ -3011,32 +3016,32 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 
 			/* Can't initiate route resolution */
 			CERROR("Can't resolve route for %s: %d\n",
-			       libcfs_nid2str(peer->ibp_nid), rc);
+			       libcfs_nid2str(peer_ni->ibp_nid), rc);
 		}
-		kiblnd_peer_connect_failed(peer, 1, rc);
-		kiblnd_peer_decref(peer);
+		kiblnd_peer_connect_failed(peer_ni, 1, rc);
+		kiblnd_peer_decref(peer_ni);
 		return rc;		      /* rc destroys cmid */
 
 	case RDMA_CM_EVENT_ROUTE_ERROR:
-		peer = (struct kib_peer *)cmid->context;
+		peer_ni = (struct kib_peer_ni *)cmid->context;
 		CNETERR("%s: ROUTE ERROR %d\n",
-			libcfs_nid2str(peer->ibp_nid), event->status);
-		kiblnd_peer_connect_failed(peer, 1, -EHOSTUNREACH);
-		kiblnd_peer_decref(peer);
+			libcfs_nid2str(peer_ni->ibp_nid), event->status);
+		kiblnd_peer_connect_failed(peer_ni, 1, -EHOSTUNREACH);
+		kiblnd_peer_decref(peer_ni);
 		return -EHOSTUNREACH;	   /* rc destroys cmid */
 
 	case RDMA_CM_EVENT_ROUTE_RESOLVED:
-		peer = (struct kib_peer *)cmid->context;
+		peer_ni = (struct kib_peer_ni *)cmid->context;
 		CDEBUG(D_NET, "%s Route resolved: %d\n",
-		       libcfs_nid2str(peer->ibp_nid), event->status);
+		       libcfs_nid2str(peer_ni->ibp_nid), event->status);
 
 		if (!event->status)
 			return kiblnd_active_connect(cmid);
 
 		CNETERR("Can't resolve route for %s: %d\n",
-			libcfs_nid2str(peer->ibp_nid), event->status);
-		kiblnd_peer_connect_failed(peer, 1, event->status);
-		kiblnd_peer_decref(peer);
+			libcfs_nid2str(peer_ni->ibp_nid), event->status);
+		kiblnd_peer_connect_failed(peer_ni, 1, event->status);
+		kiblnd_peer_decref(peer_ni);
 		return event->status;	   /* rc destroys cmid */
 
 	case RDMA_CM_EVENT_UNREACHABLE:
@@ -3177,7 +3182,7 @@ kiblnd_check_conns(int idx)
 	LIST_HEAD(closes);
 	LIST_HEAD(checksends);
 	struct list_head *peers = &kiblnd_data.kib_peers[idx];
-	struct kib_peer *peer;
+	struct kib_peer_ni *peer_ni;
 	struct kib_conn *conn;
 	unsigned long flags;
 
@@ -3188,9 +3193,9 @@ kiblnd_check_conns(int idx)
 	 */
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
-	list_for_each_entry(peer, peers, ibp_list) {
+	list_for_each_entry(peer_ni, peers, ibp_list) {
 
-		list_for_each_entry(conn, &peer->ibp_conns, ibc_list) {
+		list_for_each_entry(conn, &peer_ni->ibp_conns, ibc_list) {
 			int timedout;
 			int sendnoop;
 
@@ -3207,8 +3212,9 @@ kiblnd_check_conns(int idx)
 
 			if (timedout) {
 				CERROR("Timed out RDMA with %s (%lld): c: %u, oc: %u, rc: %u\n",
-				       libcfs_nid2str(peer->ibp_nid),
-				       ktime_get_seconds() - peer->ibp_last_alive,
+				       libcfs_nid2str(peer_ni->ibp_nid),
+				       (ktime_get_seconds() -
+					peer_ni->ibp_last_alive),
 				       conn->ibc_credits,
 				       conn->ibc_outstanding_credits,
 				       conn->ibc_reserved_credits);
@@ -3268,7 +3274,7 @@ kiblnd_disconnect_conn(struct kib_conn *conn)
 }
 
 /**
- * High-water for reconnection to the same peer, reconnection attempt should
+ * High-water for reconnection to the same peer_ni, reconnection attempt should
  * be delayed after trying more than KIB_RECONN_HIGH_RACE.
  */
 #define KIB_RECONN_HIGH_RACE	10
@@ -3302,14 +3308,14 @@ kiblnd_connd(void *arg)
 		dropped_lock = 0;
 
 		if (!list_empty(&kiblnd_data.kib_connd_zombies)) {
-			struct kib_peer *peer = NULL;
+			struct kib_peer_ni *peer_ni = NULL;
 
 			conn = list_entry(kiblnd_data.kib_connd_zombies.next,
 					  struct kib_conn, ibc_list);
 			list_del(&conn->ibc_list);
 			if (conn->ibc_reconnect) {
-				peer = conn->ibc_peer;
-				kiblnd_peer_addref(peer);
+				peer_ni = conn->ibc_peer;
+				kiblnd_peer_addref(peer_ni);
 			}
 
 			spin_unlock_irqrestore(lock, flags);
@@ -3318,13 +3324,13 @@ kiblnd_connd(void *arg)
 			kiblnd_destroy_conn(conn);
 
 			spin_lock_irqsave(lock, flags);
-			if (!peer) {
+			if (!peer_ni) {
 				kfree(conn);
 				continue;
 			}
 
-			conn->ibc_peer = peer;
-			if (peer->ibp_reconnected < KIB_RECONN_HIGH_RACE)
+			conn->ibc_peer = peer_ni;
+			if (peer_ni->ibp_reconnected < KIB_RECONN_HIGH_RACE)
 				list_add_tail(&conn->ibc_list,
 					      &kiblnd_data.kib_reconn_list);
 			else
@@ -3384,7 +3390,7 @@ kiblnd_connd(void *arg)
 			/*
 			 * Time to check for RDMA timeouts on a few more
 			 * peers: I do checks every 'p' seconds on a
-			 * proportion of the peer table and I need to check
+			 * proportion of the peer_ni table and I need to check
 			 * every connection 'n' times within a timeout
 			 * interval, to ensure I detect a timeout on any
 			 * connection within (n+1)/n times the timeout
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index ba1ec35a017a..c14711804d7b 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -104,38 +104,38 @@ ksocknal_create_peer(struct ksock_peer **peerp, struct lnet_ni *ni,
 {
 	int cpt = lnet_cpt_of_nid(id.nid, ni);
 	struct ksock_net *net = ni->ni_data;
-	struct ksock_peer *peer;
+	struct ksock_peer *peer_ni;
 
 	LASSERT(id.nid != LNET_NID_ANY);
 	LASSERT(id.pid != LNET_PID_ANY);
 	LASSERT(!in_interrupt());
 
-	peer = kzalloc_cpt(sizeof(*peer), GFP_NOFS, cpt);
-	if (!peer)
+	peer_ni = kzalloc_cpt(sizeof(*peer_ni), GFP_NOFS, cpt);
+	if (!peer_ni)
 		return -ENOMEM;
 
-	peer->ksnp_ni = ni;
-	peer->ksnp_id = id;
-	atomic_set(&peer->ksnp_refcount, 1);   /* 1 ref for caller */
-	peer->ksnp_closing = 0;
-	peer->ksnp_accepting = 0;
-	peer->ksnp_proto = NULL;
-	peer->ksnp_last_alive = 0;
-	peer->ksnp_zc_next_cookie = SOCKNAL_KEEPALIVE_PING + 1;
-
-	INIT_LIST_HEAD(&peer->ksnp_conns);
-	INIT_LIST_HEAD(&peer->ksnp_routes);
-	INIT_LIST_HEAD(&peer->ksnp_tx_queue);
-	INIT_LIST_HEAD(&peer->ksnp_zc_req_list);
-	spin_lock_init(&peer->ksnp_lock);
+	peer_ni->ksnp_ni = ni;
+	peer_ni->ksnp_id = id;
+	atomic_set(&peer_ni->ksnp_refcount, 1);   /* 1 ref for caller */
+	peer_ni->ksnp_closing = 0;
+	peer_ni->ksnp_accepting = 0;
+	peer_ni->ksnp_proto = NULL;
+	peer_ni->ksnp_last_alive = 0;
+	peer_ni->ksnp_zc_next_cookie = SOCKNAL_KEEPALIVE_PING + 1;
+
+	INIT_LIST_HEAD(&peer_ni->ksnp_conns);
+	INIT_LIST_HEAD(&peer_ni->ksnp_routes);
+	INIT_LIST_HEAD(&peer_ni->ksnp_tx_queue);
+	INIT_LIST_HEAD(&peer_ni->ksnp_zc_req_list);
+	spin_lock_init(&peer_ni->ksnp_lock);
 
 	spin_lock_bh(&net->ksnn_lock);
 
 	if (net->ksnn_shutdown) {
 		spin_unlock_bh(&net->ksnn_lock);
 
-		kfree(peer);
-		CERROR("Can't create peer: network shutdown\n");
+		kfree(peer_ni);
+		CERROR("Can't create peer_ni: network shutdown\n");
 		return -ESHUTDOWN;
 	}
 
@@ -143,31 +143,31 @@ ksocknal_create_peer(struct ksock_peer **peerp, struct lnet_ni *ni,
 
 	spin_unlock_bh(&net->ksnn_lock);
 
-	*peerp = peer;
+	*peerp = peer_ni;
 	return 0;
 }
 
 void
-ksocknal_destroy_peer(struct ksock_peer *peer)
+ksocknal_destroy_peer(struct ksock_peer *peer_ni)
 {
-	struct ksock_net *net = peer->ksnp_ni->ni_data;
+	struct ksock_net *net = peer_ni->ksnp_ni->ni_data;
 
-	CDEBUG(D_NET, "peer %s %p deleted\n",
-	       libcfs_id2str(peer->ksnp_id), peer);
+	CDEBUG(D_NET, "peer_ni %s %p deleted\n",
+	       libcfs_id2str(peer_ni->ksnp_id), peer_ni);
 
-	LASSERT(!atomic_read(&peer->ksnp_refcount));
-	LASSERT(!peer->ksnp_accepting);
-	LASSERT(list_empty(&peer->ksnp_conns));
-	LASSERT(list_empty(&peer->ksnp_routes));
-	LASSERT(list_empty(&peer->ksnp_tx_queue));
-	LASSERT(list_empty(&peer->ksnp_zc_req_list));
+	LASSERT(!atomic_read(&peer_ni->ksnp_refcount));
+	LASSERT(!peer_ni->ksnp_accepting);
+	LASSERT(list_empty(&peer_ni->ksnp_conns));
+	LASSERT(list_empty(&peer_ni->ksnp_routes));
+	LASSERT(list_empty(&peer_ni->ksnp_tx_queue));
+	LASSERT(list_empty(&peer_ni->ksnp_zc_req_list));
 
-	kfree(peer);
+	kfree(peer_ni);
 
 	/*
-	 * NB a peer's connections and routes keep a reference on their peer
+	 * NB a peer_ni's connections and routes keep a reference on their peer
 	 * until they are destroyed, so we can be assured that _all_ state to
-	 * do with this peer has been cleaned up when its refcount drops to
+	 * do with this peer_ni has been cleaned up when its refcount drops to
 	 * zero.
 	 */
 	spin_lock_bh(&net->ksnn_lock);
@@ -179,22 +179,22 @@ struct ksock_peer *
 ksocknal_find_peer_locked(struct lnet_ni *ni, struct lnet_process_id id)
 {
 	struct list_head *peer_list = ksocknal_nid2peerlist(id.nid);
-	struct ksock_peer *peer;
+	struct ksock_peer *peer_ni;
 
-	list_for_each_entry(peer, peer_list, ksnp_list) {
-		LASSERT(!peer->ksnp_closing);
+	list_for_each_entry(peer_ni, peer_list, ksnp_list) {
+		LASSERT(!peer_ni->ksnp_closing);
 
-		if (peer->ksnp_ni != ni)
+		if (peer_ni->ksnp_ni != ni)
 			continue;
 
-		if (peer->ksnp_id.nid != id.nid ||
-		    peer->ksnp_id.pid != id.pid)
+		if (peer_ni->ksnp_id.nid != id.nid ||
+		    peer_ni->ksnp_id.pid != id.pid)
 			continue;
 
-		CDEBUG(D_NET, "got peer [%p] -> %s (%d)\n",
-		       peer, libcfs_id2str(id),
-		       atomic_read(&peer->ksnp_refcount));
-		return peer;
+		CDEBUG(D_NET, "got peer_ni [%p] -> %s (%d)\n",
+		       peer_ni, libcfs_id2str(id),
+		       atomic_read(&peer_ni->ksnp_refcount));
+		return peer_ni;
 	}
 	return NULL;
 }
@@ -202,47 +202,47 @@ ksocknal_find_peer_locked(struct lnet_ni *ni, struct lnet_process_id id)
 struct ksock_peer *
 ksocknal_find_peer(struct lnet_ni *ni, struct lnet_process_id id)
 {
-	struct ksock_peer *peer;
+	struct ksock_peer *peer_ni;
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
-	peer = ksocknal_find_peer_locked(ni, id);
-	if (peer)			/* +1 ref for caller? */
-		ksocknal_peer_addref(peer);
+	peer_ni = ksocknal_find_peer_locked(ni, id);
+	if (peer_ni)			/* +1 ref for caller? */
+		ksocknal_peer_addref(peer_ni);
 	read_unlock(&ksocknal_data.ksnd_global_lock);
 
-	return peer;
+	return peer_ni;
 }
 
 static void
-ksocknal_unlink_peer_locked(struct ksock_peer *peer)
+ksocknal_unlink_peer_locked(struct ksock_peer *peer_ni)
 {
 	int i;
 	__u32 ip;
 	struct ksock_interface *iface;
 
-	for (i = 0; i < peer->ksnp_n_passive_ips; i++) {
+	for (i = 0; i < peer_ni->ksnp_n_passive_ips; i++) {
 		LASSERT(i < LNET_MAX_INTERFACES);
-		ip = peer->ksnp_passive_ips[i];
+		ip = peer_ni->ksnp_passive_ips[i];
 
-		iface = ksocknal_ip2iface(peer->ksnp_ni, ip);
+		iface = ksocknal_ip2iface(peer_ni->ksnp_ni, ip);
 		/*
-		 * All IPs in peer->ksnp_passive_ips[] come from the
+		 * All IPs in peer_ni->ksnp_passive_ips[] come from the
 		 * interface list, therefore the call must succeed.
 		 */
 		LASSERT(iface);
 
-		CDEBUG(D_NET, "peer=%p iface=%p ksni_nroutes=%d\n",
-		       peer, iface, iface->ksni_nroutes);
+		CDEBUG(D_NET, "peer_ni=%p iface=%p ksni_nroutes=%d\n",
+		       peer_ni, iface, iface->ksni_nroutes);
 		iface->ksni_npeers--;
 	}
 
-	LASSERT(list_empty(&peer->ksnp_conns));
-	LASSERT(list_empty(&peer->ksnp_routes));
-	LASSERT(!peer->ksnp_closing);
-	peer->ksnp_closing = 1;
-	list_del(&peer->ksnp_list);
+	LASSERT(list_empty(&peer_ni->ksnp_conns));
+	LASSERT(list_empty(&peer_ni->ksnp_routes));
+	LASSERT(!peer_ni->ksnp_closing);
+	peer_ni->ksnp_closing = 1;
+	list_del(&peer_ni->ksnp_list);
 	/* lose peerlist's ref */
-	ksocknal_peer_decref(peer);
+	ksocknal_peer_decref(peer_ni);
 }
 
 static int
@@ -250,7 +250,7 @@ ksocknal_get_peer_info(struct lnet_ni *ni, int index,
 		       struct lnet_process_id *id, __u32 *myip, __u32 *peer_ip,
 		       int *port, int *conn_count, int *share_count)
 {
-	struct ksock_peer *peer;
+	struct ksock_peer *peer_ni;
 	struct ksock_route *route;
 	int i;
 	int j;
@@ -259,17 +259,17 @@ ksocknal_get_peer_info(struct lnet_ni *ni, int index,
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
 	for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
-		list_for_each_entry(peer, &ksocknal_data.ksnd_peers[i], ksnp_list) {
-
-			if (peer->ksnp_ni != ni)
+		list_for_each_entry(peer_ni, &ksocknal_data.ksnd_peers[i],
+				    ksnp_list) {
+			if (peer_ni->ksnp_ni != ni)
 				continue;
 
-			if (!peer->ksnp_n_passive_ips &&
-			    list_empty(&peer->ksnp_routes)) {
+			if (!peer_ni->ksnp_n_passive_ips &&
+			    list_empty(&peer_ni->ksnp_routes)) {
 				if (index-- > 0)
 					continue;
 
-				*id = peer->ksnp_id;
+				*id = peer_ni->ksnp_id;
 				*myip = 0;
 				*peer_ip = 0;
 				*port = 0;
@@ -279,12 +279,12 @@ ksocknal_get_peer_info(struct lnet_ni *ni, int index,
 				goto out;
 			}
 
-			for (j = 0; j < peer->ksnp_n_passive_ips; j++) {
+			for (j = 0; j < peer_ni->ksnp_n_passive_ips; j++) {
 				if (index-- > 0)
 					continue;
 
-				*id = peer->ksnp_id;
-				*myip = peer->ksnp_passive_ips[j];
+				*id = peer_ni->ksnp_id;
+				*myip = peer_ni->ksnp_passive_ips[j];
 				*peer_ip = 0;
 				*port = 0;
 				*conn_count = 0;
@@ -293,12 +293,12 @@ ksocknal_get_peer_info(struct lnet_ni *ni, int index,
 				goto out;
 			}
 
-			list_for_each_entry(route, &peer->ksnp_routes,
+			list_for_each_entry(route, &peer_ni->ksnp_routes,
 					    ksnr_list) {
 				if (index-- > 0)
 					continue;
 
-				*id = peer->ksnp_id;
+				*id = peer_ni->ksnp_id;
 				*myip = route->ksnr_myipaddr;
 				*peer_ip = route->ksnr_ipaddr;
 				*port = route->ksnr_port;
@@ -318,7 +318,7 @@ static void
 ksocknal_associate_route_conn_locked(struct ksock_route *route,
 				     struct ksock_conn *conn)
 {
-	struct ksock_peer *peer = route->ksnr_peer;
+	struct ksock_peer *peer_ni = route->ksnr_peer;
 	int type = conn->ksnc_type;
 	struct ksock_interface *iface;
 
@@ -329,12 +329,12 @@ ksocknal_associate_route_conn_locked(struct ksock_route *route,
 		if (!route->ksnr_myipaddr) {
 			/* route wasn't bound locally yet (the initial route) */
 			CDEBUG(D_NET, "Binding %s %pI4h to %pI4h\n",
-			       libcfs_id2str(peer->ksnp_id),
+			       libcfs_id2str(peer_ni->ksnp_id),
 			       &route->ksnr_ipaddr,
 			       &conn->ksnc_myipaddr);
 		} else {
 			CDEBUG(D_NET, "Rebinding %s %pI4h from %pI4h to %pI4h\n",
-			       libcfs_id2str(peer->ksnp_id),
+			       libcfs_id2str(peer_ni->ksnp_id),
 			       &route->ksnr_ipaddr,
 			       &route->ksnr_myipaddr,
 			       &conn->ksnc_myipaddr);
@@ -362,33 +362,33 @@ ksocknal_associate_route_conn_locked(struct ksock_route *route,
 }
 
 static void
-ksocknal_add_route_locked(struct ksock_peer *peer, struct ksock_route *route)
+ksocknal_add_route_locked(struct ksock_peer *peer_ni, struct ksock_route *route)
 {
 	struct ksock_conn *conn;
 	struct ksock_route *route2;
 
-	LASSERT(!peer->ksnp_closing);
+	LASSERT(!peer_ni->ksnp_closing);
 	LASSERT(!route->ksnr_peer);
 	LASSERT(!route->ksnr_scheduled);
 	LASSERT(!route->ksnr_connecting);
 	LASSERT(!route->ksnr_connected);
 
 	/* LASSERT(unique) */
-	list_for_each_entry(route2, &peer->ksnp_routes, ksnr_list) {
+	list_for_each_entry(route2, &peer_ni->ksnp_routes, ksnr_list) {
 		if (route2->ksnr_ipaddr == route->ksnr_ipaddr) {
 			CERROR("Duplicate route %s %pI4h\n",
-			       libcfs_id2str(peer->ksnp_id),
+			       libcfs_id2str(peer_ni->ksnp_id),
 			       &route->ksnr_ipaddr);
 			LBUG();
 		}
 	}
 
-	route->ksnr_peer = peer;
-	ksocknal_peer_addref(peer);
-	/* peer's routelist takes over my ref on 'route' */
-	list_add_tail(&route->ksnr_list, &peer->ksnp_routes);
+	route->ksnr_peer = peer_ni;
+	ksocknal_peer_addref(peer_ni);
+	/* peer_ni's routelist takes over my ref on 'route' */
+	list_add_tail(&route->ksnr_list, &peer_ni->ksnp_routes);
 
-	list_for_each_entry(conn, &peer->ksnp_conns, ksnc_list) {
+	list_for_each_entry(conn, &peer_ni->ksnp_conns, ksnc_list) {
 		if (conn->ksnc_ipaddr != route->ksnr_ipaddr)
 			continue;
 
@@ -400,7 +400,7 @@ ksocknal_add_route_locked(struct ksock_peer *peer, struct ksock_route *route)
 static void
 ksocknal_del_route_locked(struct ksock_route *route)
 {
-	struct ksock_peer *peer = route->ksnr_peer;
+	struct ksock_peer *peer_ni = route->ksnr_peer;
 	struct ksock_interface *iface;
 	struct ksock_conn *conn;
 	struct list_head *ctmp;
@@ -409,7 +409,7 @@ ksocknal_del_route_locked(struct ksock_route *route)
 	LASSERT(!route->ksnr_deleted);
 
 	/* Close associated conns */
-	list_for_each_safe(ctmp, cnxt, &peer->ksnp_conns) {
+	list_for_each_safe(ctmp, cnxt, &peer_ni->ksnp_conns) {
 		conn = list_entry(ctmp, struct ksock_conn, ksnc_list);
 
 		if (conn->ksnc_route != route)
@@ -427,15 +427,15 @@ ksocknal_del_route_locked(struct ksock_route *route)
 
 	route->ksnr_deleted = 1;
 	list_del(&route->ksnr_list);
-	ksocknal_route_decref(route);	     /* drop peer's ref */
+	ksocknal_route_decref(route);	     /* drop peer_ni's ref */
 
-	if (list_empty(&peer->ksnp_routes) &&
-	    list_empty(&peer->ksnp_conns)) {
+	if (list_empty(&peer_ni->ksnp_routes) &&
+	    list_empty(&peer_ni->ksnp_conns)) {
 		/*
-		 * I've just removed the last route to a peer with no active
+		 * I've just removed the last route to a peer_ni with no active
 		 * connections
 		 */
-		ksocknal_unlink_peer_locked(peer);
+		ksocknal_unlink_peer_locked(peer_ni);
 	}
 }
 
@@ -443,7 +443,7 @@ int
 ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, __u32 ipaddr,
 		  int port)
 {
-	struct ksock_peer *peer;
+	struct ksock_peer *peer_ni;
 	struct ksock_peer *peer2;
 	struct ksock_route *route;
 	struct ksock_route *route2;
@@ -453,14 +453,14 @@ ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, __u32 ipaddr,
 	    id.pid == LNET_PID_ANY)
 		return -EINVAL;
 
-	/* Have a brand new peer ready... */
-	rc = ksocknal_create_peer(&peer, ni, id);
+	/* Have a brand new peer_ni ready... */
+	rc = ksocknal_create_peer(&peer_ni, ni, id);
 	if (rc)
 		return rc;
 
 	route = ksocknal_create_route(ipaddr, port);
 	if (!route) {
-		ksocknal_peer_decref(peer);
+		ksocknal_peer_decref(peer_ni);
 		return -ENOMEM;
 	}
 
@@ -471,15 +471,15 @@ ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, __u32 ipaddr,
 
 	peer2 = ksocknal_find_peer_locked(ni, id);
 	if (peer2) {
-		ksocknal_peer_decref(peer);
-		peer = peer2;
+		ksocknal_peer_decref(peer_ni);
+		peer_ni = peer2;
 	} else {
-		/* peer table takes my ref on peer */
-		list_add_tail(&peer->ksnp_list,
+		/* peer_ni table takes my ref on peer_ni */
+		list_add_tail(&peer_ni->ksnp_list,
 			      ksocknal_nid2peerlist(id.nid));
 	}
 
-	list_for_each_entry(route2, &peer->ksnp_routes, ksnr_list) {
+	list_for_each_entry(route2, &peer_ni->ksnp_routes, ksnr_list) {
 		if (route2->ksnr_ipaddr == ipaddr) {
 			/* Route already exists, use the old one */
 			ksocknal_route_decref(route);
@@ -488,7 +488,7 @@ ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, __u32 ipaddr,
 		}
 	}
 	/* Route doesn't already exist, add the new one */
-	ksocknal_add_route_locked(peer, route);
+	ksocknal_add_route_locked(peer_ni, route);
 	route->ksnr_share_count++;
 out:
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
@@ -497,7 +497,7 @@ ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, __u32 ipaddr,
 }
 
 static void
-ksocknal_del_peer_locked(struct ksock_peer *peer, __u32 ip)
+ksocknal_del_peer_locked(struct ksock_peer *peer_ni, __u32 ip)
 {
 	struct ksock_conn *conn;
 	struct ksock_route *route;
@@ -505,12 +505,12 @@ ksocknal_del_peer_locked(struct ksock_peer *peer, __u32 ip)
 	struct list_head *nxt;
 	int nshared;
 
-	LASSERT(!peer->ksnp_closing);
+	LASSERT(!peer_ni->ksnp_closing);
 
-	/* Extra ref prevents peer disappearing until I'm done with it */
-	ksocknal_peer_addref(peer);
+	/* Extra ref prevents peer_ni disappearing until I'm done with it */
+	ksocknal_peer_addref(peer_ni);
 
-	list_for_each_safe(tmp, nxt, &peer->ksnp_routes) {
+	list_for_each_safe(tmp, nxt, &peer_ni->ksnp_routes) {
 		route = list_entry(tmp, struct ksock_route, ksnr_list);
 
 		/* no match */
@@ -523,7 +523,7 @@ ksocknal_del_peer_locked(struct ksock_peer *peer, __u32 ip)
 	}
 
 	nshared = 0;
-	list_for_each_safe(tmp, nxt, &peer->ksnp_routes) {
+	list_for_each_safe(tmp, nxt, &peer_ni->ksnp_routes) {
 		route = list_entry(tmp, struct ksock_route, ksnr_list);
 		nshared += route->ksnr_share_count;
 	}
@@ -533,7 +533,7 @@ ksocknal_del_peer_locked(struct ksock_peer *peer, __u32 ip)
 		 * remove everything else if there are no explicit entries
 		 * left
 		 */
-		list_for_each_safe(tmp, nxt, &peer->ksnp_routes) {
+		list_for_each_safe(tmp, nxt, &peer_ni->ksnp_routes) {
 			route = list_entry(tmp, struct ksock_route, ksnr_list);
 
 			/* we should only be removing auto-entries */
@@ -541,24 +541,23 @@ ksocknal_del_peer_locked(struct ksock_peer *peer, __u32 ip)
 			ksocknal_del_route_locked(route);
 		}
 
-		list_for_each_safe(tmp, nxt, &peer->ksnp_conns) {
+		list_for_each_safe(tmp, nxt, &peer_ni->ksnp_conns) {
 			conn = list_entry(tmp, struct ksock_conn, ksnc_list);
 
 			ksocknal_close_conn_locked(conn, 0);
 		}
 	}
 
-	ksocknal_peer_decref(peer);
-	/* NB peer unlinks itself when last conn/route is removed */
+	ksocknal_peer_decref(peer_ni);
+	/* NB peer_ni unlinks itself when last conn/route is removed */
 }
 
 static int
 ksocknal_del_peer(struct lnet_ni *ni, struct lnet_process_id id, __u32 ip)
 {
 	LIST_HEAD(zombies);
-	struct list_head *ptmp;
-	struct list_head *pnxt;
-	struct ksock_peer *peer;
+	struct ksock_peer *pnxt;
+	struct ksock_peer *peer_ni;
 	int lo;
 	int hi;
 	int i;
@@ -575,30 +574,32 @@ ksocknal_del_peer(struct lnet_ni *ni, struct lnet_process_id id, __u32 ip)
 	}
 
 	for (i = lo; i <= hi; i++) {
-		list_for_each_safe(ptmp, pnxt, &ksocknal_data.ksnd_peers[i]) {
-			peer = list_entry(ptmp, struct ksock_peer, ksnp_list);
-
-			if (peer->ksnp_ni != ni)
+		list_for_each_entry_safe(peer_ni, pnxt,
+					 &ksocknal_data.ksnd_peers[i],
+					 ksnp_list) {
+			if (peer_ni->ksnp_ni != ni)
 				continue;
 
-			if (!((id.nid == LNET_NID_ANY || peer->ksnp_id.nid == id.nid) &&
-			      (id.pid == LNET_PID_ANY || peer->ksnp_id.pid == id.pid)))
+			if (!((id.nid == LNET_NID_ANY ||
+			       peer_ni->ksnp_id.nid == id.nid) &&
+			      (id.pid == LNET_PID_ANY ||
+			       peer_ni->ksnp_id.pid == id.pid)))
 				continue;
 
-			ksocknal_peer_addref(peer);     /* a ref for me... */
+			ksocknal_peer_addref(peer_ni);     /* a ref for me... */
 
-			ksocknal_del_peer_locked(peer, ip);
+			ksocknal_del_peer_locked(peer_ni, ip);
 
-			if (peer->ksnp_closing &&
-			    !list_empty(&peer->ksnp_tx_queue)) {
-				LASSERT(list_empty(&peer->ksnp_conns));
-				LASSERT(list_empty(&peer->ksnp_routes));
+			if (peer_ni->ksnp_closing &&
+			    !list_empty(&peer_ni->ksnp_tx_queue)) {
+				LASSERT(list_empty(&peer_ni->ksnp_conns));
+				LASSERT(list_empty(&peer_ni->ksnp_routes));
 
-				list_splice_init(&peer->ksnp_tx_queue,
+				list_splice_init(&peer_ni->ksnp_tx_queue,
 						 &zombies);
 			}
 
-			ksocknal_peer_decref(peer);     /* ...till here */
+			ksocknal_peer_decref(peer_ni);     /* ...till here */
 
 			rc = 0;		 /* matched! */
 		}
@@ -614,20 +615,22 @@ ksocknal_del_peer(struct lnet_ni *ni, struct lnet_process_id id, __u32 ip)
 static struct ksock_conn *
 ksocknal_get_conn_by_idx(struct lnet_ni *ni, int index)
 {
-	struct ksock_peer *peer;
+	struct ksock_peer *peer_ni;
 	struct ksock_conn *conn;
 	int i;
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
 	for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
-		list_for_each_entry(peer, &ksocknal_data.ksnd_peers[i], ksnp_list) {
-			LASSERT(!peer->ksnp_closing);
+		list_for_each_entry(peer_ni, &ksocknal_data.ksnd_peers[i],
+				    ksnp_list) {
+			LASSERT(!peer_ni->ksnp_closing);
 
-			if (peer->ksnp_ni != ni)
+			if (peer_ni->ksnp_ni != ni)
 				continue;
 
-			list_for_each_entry(conn, &peer->ksnp_conns, ksnc_list) {
+			list_for_each_entry(conn, &peer_ni->ksnp_conns,
+					    ksnc_list) {
 				if (index-- > 0)
 					continue;
 
@@ -728,10 +731,10 @@ ksocknal_match_peerip(struct ksock_interface *iface, __u32 *ips, int nips)
 }
 
 static int
-ksocknal_select_ips(struct ksock_peer *peer, __u32 *peerips, int n_peerips)
+ksocknal_select_ips(struct ksock_peer *peer_ni, __u32 *peerips, int n_peerips)
 {
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
-	struct ksock_net *net = peer->ksnp_ni->ni_data;
+	struct ksock_net *net = peer_ni->ksnp_ni->ni_data;
 	struct ksock_interface *iface;
 	struct ksock_interface *best_iface;
 	int n_ips;
@@ -766,26 +769,26 @@ ksocknal_select_ips(struct ksock_peer *peer, __u32 *peerips, int n_peerips)
 	n_ips = (net->ksnn_ninterfaces < 2) ? 0 :
 		min(n_peerips, net->ksnn_ninterfaces);
 
-	for (i = 0; peer->ksnp_n_passive_ips < n_ips; i++) {
+	for (i = 0; peer_ni->ksnp_n_passive_ips < n_ips; i++) {
 		/*	      ^ yes really... */
 
 		/*
 		 * If we have any new interfaces, first tick off all the
-		 * peer IPs that match old interfaces, then choose new
-		 * interfaces to match the remaining peer IPS.
+		 * peer_ni IPs that match old interfaces, then choose new
+		 * interfaces to match the remaining peer_ni IPS.
 		 * We don't forget interfaces we've stopped using; we might
 		 * start using them again...
 		 */
-		if (i < peer->ksnp_n_passive_ips) {
+		if (i < peer_ni->ksnp_n_passive_ips) {
 			/* Old interface. */
-			ip = peer->ksnp_passive_ips[i];
-			best_iface = ksocknal_ip2iface(peer->ksnp_ni, ip);
+			ip = peer_ni->ksnp_passive_ips[i];
+			best_iface = ksocknal_ip2iface(peer_ni->ksnp_ni, ip);
 
-			/* peer passive ips are kept up to date */
+			/* peer_ni passive ips are kept up to date */
 			LASSERT(best_iface);
 		} else {
 			/* choose a new interface */
-			LASSERT(i == peer->ksnp_n_passive_ips);
+			LASSERT(i == peer_ni->ksnp_n_passive_ips);
 
 			best_iface = NULL;
 			best_netmatch = 0;
@@ -795,11 +798,14 @@ ksocknal_select_ips(struct ksock_peer *peer, __u32 *peerips, int n_peerips)
 				iface = &net->ksnn_interfaces[j];
 				ip = iface->ksni_ipaddr;
 
-				for (k = 0; k < peer->ksnp_n_passive_ips; k++)
-					if (peer->ksnp_passive_ips[k] == ip)
+				for (k = 0;
+				     k < peer_ni->ksnp_n_passive_ips;
+				     k++)
+					if (peer_ni->ksnp_passive_ips[k] == ip)
 						break;
 
-				if (k < peer->ksnp_n_passive_ips) /* using it already */
+				if (k < peer_ni->ksnp_n_passive_ips)
+					/* using it already */
 					continue;
 
 				k = ksocknal_match_peerip(iface, peerips,
@@ -822,17 +828,17 @@ ksocknal_select_ips(struct ksock_peer *peer, __u32 *peerips, int n_peerips)
 
 			best_iface->ksni_npeers++;
 			ip = best_iface->ksni_ipaddr;
-			peer->ksnp_passive_ips[i] = ip;
-			peer->ksnp_n_passive_ips = i + 1;
+			peer_ni->ksnp_passive_ips[i] = ip;
+			peer_ni->ksnp_n_passive_ips = i + 1;
 		}
 
-		/* mark the best matching peer IP used */
+		/* mark the best matching peer_ni IP used */
 		j = ksocknal_match_peerip(best_iface, peerips, n_peerips);
 		peerips[j] = 0;
 	}
 
-	/* Overwrite input peer IP addresses */
-	memcpy(peerips, peer->ksnp_passive_ips, n_ips * sizeof(*peerips));
+	/* Overwrite input peer_ni IP addresses */
+	memcpy(peerips, peer_ni->ksnp_passive_ips, n_ips * sizeof(*peerips));
 
 	write_unlock_bh(global_lock);
 
@@ -840,12 +846,12 @@ ksocknal_select_ips(struct ksock_peer *peer, __u32 *peerips, int n_peerips)
 }
 
 static void
-ksocknal_create_routes(struct ksock_peer *peer, int port,
+ksocknal_create_routes(struct ksock_peer *peer_ni, int port,
 		       __u32 *peer_ipaddrs, int npeer_ipaddrs)
 {
 	struct ksock_route *newroute = NULL;
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
-	struct lnet_ni *ni = peer->ksnp_ni;
+	struct lnet_ni *ni = peer_ni->ksnp_ni;
 	struct ksock_net *net = ni->ni_data;
 	struct ksock_route *route;
 	struct ksock_interface *iface;
@@ -888,13 +894,13 @@ ksocknal_create_routes(struct ksock_peer *peer, int port,
 			write_lock_bh(global_lock);
 		}
 
-		if (peer->ksnp_closing) {
-			/* peer got closed under me */
+		if (peer_ni->ksnp_closing) {
+			/* peer_ni got closed under me */
 			break;
 		}
 
 		/* Already got a route? */
-		list_for_each_entry(route, &peer->ksnp_routes, ksnr_list)
+		list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list)
 			if (route->ksnr_ipaddr != newroute->ksnr_ipaddr)
 				goto next_ipaddr;
 
@@ -909,7 +915,8 @@ ksocknal_create_routes(struct ksock_peer *peer, int port,
 			iface = &net->ksnn_interfaces[j];
 
 			/* Using this interface already? */
-			list_for_each_entry(route, &peer->ksnp_routes, ksnr_list)
+			list_for_each_entry(route, &peer_ni->ksnp_routes,
+					    ksnr_list)
 				if (route->ksnr_myipaddr == iface->ksni_ipaddr)
 					goto next_iface;
 
@@ -935,7 +942,7 @@ ksocknal_create_routes(struct ksock_peer *peer, int port,
 		newroute->ksnr_myipaddr = best_iface->ksni_ipaddr;
 		best_iface->ksni_nroutes++;
 
-		ksocknal_add_route_locked(peer, newroute);
+		ksocknal_add_route_locked(peer_ni, newroute);
 		newroute = NULL;
 	next_ipaddr:;
 	}
@@ -977,11 +984,11 @@ ksocknal_accept(struct lnet_ni *ni, struct socket *sock)
 }
 
 static int
-ksocknal_connecting(struct ksock_peer *peer, __u32 ipaddr)
+ksocknal_connecting(struct ksock_peer *peer_ni, __u32 ipaddr)
 {
 	struct ksock_route *route;
 
-	list_for_each_entry(route, &peer->ksnp_routes, ksnr_list) {
+	list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list) {
 		if (route->ksnr_ipaddr == ipaddr)
 			return route->ksnr_connecting;
 	}
@@ -998,7 +1005,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 	__u64 incarnation;
 	struct ksock_conn *conn;
 	struct ksock_conn *conn2;
-	struct ksock_peer *peer = NULL;
+	struct ksock_peer *peer_ni = NULL;
 	struct ksock_peer *peer2;
 	struct ksock_sched *sched;
 	struct ksock_hello_msg *hello;
@@ -1054,21 +1061,21 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 		goto failed_1;
 
 	/*
-	 * Find out/confirm peer's NID and connection type and get the
+	 * Find out/confirm peer_ni's NID and connection type and get the
 	 * vector of interfaces she's willing to let me connect to.
-	 * Passive connections use the listener timeout since the peer sends
+	 * Passive connections use the listener timeout since the peer_ni sends
 	 * eagerly
 	 */
 	if (active) {
-		peer = route->ksnr_peer;
-		LASSERT(ni == peer->ksnp_ni);
+		peer_ni = route->ksnr_peer;
+		LASSERT(ni == peer_ni->ksnp_ni);
 
 		/* Active connection sends HELLO eagerly */
 		hello->kshm_nips = ksocknal_local_ipvec(ni, hello->kshm_ips);
-		peerid = peer->ksnp_id;
+		peerid = peer_ni->ksnp_id;
 
 		write_lock_bh(global_lock);
-		conn->ksnc_proto = peer->ksnp_proto;
+		conn->ksnc_proto = peer_ni->ksnp_proto;
 		write_unlock_bh(global_lock);
 
 		if (!conn->ksnc_proto) {
@@ -1088,7 +1095,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 		peerid.nid = LNET_NID_ANY;
 		peerid.pid = LNET_PID_ANY;
 
-		/* Passive, get protocol from peer */
+		/* Passive, get protocol from peer_ni */
 		conn->ksnc_proto = NULL;
 	}
 
@@ -1103,10 +1110,10 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 	cpt = lnet_cpt_of_nid(peerid.nid, ni);
 
 	if (active) {
-		ksocknal_peer_addref(peer);
+		ksocknal_peer_addref(peer_ni);
 		write_lock_bh(global_lock);
 	} else {
-		rc = ksocknal_create_peer(&peer, ni, peerid);
+		rc = ksocknal_create_peer(&peer_ni, ni, peerid);
 		if (rc)
 			goto failed_1;
 
@@ -1118,61 +1125,61 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 		peer2 = ksocknal_find_peer_locked(ni, peerid);
 		if (!peer2) {
 			/*
-			 * NB this puts an "empty" peer in the peer
+			 * NB this puts an "empty" peer_ni in the peer
 			 * table (which takes my ref)
 			 */
-			list_add_tail(&peer->ksnp_list,
+			list_add_tail(&peer_ni->ksnp_list,
 				      ksocknal_nid2peerlist(peerid.nid));
 		} else {
-			ksocknal_peer_decref(peer);
-			peer = peer2;
+			ksocknal_peer_decref(peer_ni);
+			peer_ni = peer2;
 		}
 
 		/* +1 ref for me */
-		ksocknal_peer_addref(peer);
-		peer->ksnp_accepting++;
+		ksocknal_peer_addref(peer_ni);
+		peer_ni->ksnp_accepting++;
 
 		/*
 		 * Am I already connecting to this guy?  Resolve in
 		 * favour of higher NID...
 		 */
 		if (peerid.nid < ni->ni_nid &&
-		    ksocknal_connecting(peer, conn->ksnc_ipaddr)) {
+		    ksocknal_connecting(peer_ni, conn->ksnc_ipaddr)) {
 			rc = EALREADY;
 			warn = "connection race resolution";
 			goto failed_2;
 		}
 	}
 
-	if (peer->ksnp_closing ||
+	if (peer_ni->ksnp_closing ||
 	    (active && route->ksnr_deleted)) {
-		/* peer/route got closed under me */
+		/* peer_ni/route got closed under me */
 		rc = -ESTALE;
-		warn = "peer/route removed";
+		warn = "peer_ni/route removed";
 		goto failed_2;
 	}
 
-	if (!peer->ksnp_proto) {
+	if (!peer_ni->ksnp_proto) {
 		/*
 		 * Never connected before.
 		 * NB recv_hello may have returned EPROTO to signal my peer
 		 * wants a different protocol than the one I asked for.
 		 */
-		LASSERT(list_empty(&peer->ksnp_conns));
+		LASSERT(list_empty(&peer_ni->ksnp_conns));
 
-		peer->ksnp_proto = conn->ksnc_proto;
-		peer->ksnp_incarnation = incarnation;
+		peer_ni->ksnp_proto = conn->ksnc_proto;
+		peer_ni->ksnp_incarnation = incarnation;
 	}
 
-	if (peer->ksnp_proto != conn->ksnc_proto ||
-	    peer->ksnp_incarnation != incarnation) {
-		/* Peer rebooted or I've got the wrong protocol version */
-		ksocknal_close_peer_conns_locked(peer, 0, 0);
+	if (peer_ni->ksnp_proto != conn->ksnc_proto ||
+	    peer_ni->ksnp_incarnation != incarnation) {
+		/* peer_ni rebooted or I've got the wrong protocol version */
+		ksocknal_close_peer_conns_locked(peer_ni, 0, 0);
 
-		peer->ksnp_proto = NULL;
+		peer_ni->ksnp_proto = NULL;
 		rc = ESTALE;
-		warn = peer->ksnp_incarnation != incarnation ?
-		       "peer rebooted" :
+		warn = peer_ni->ksnp_incarnation != incarnation ?
+		       "peer_ni rebooted" :
 		       "wrong proto version";
 		goto failed_2;
 	}
@@ -1195,7 +1202,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 	 * loopback connection
 	 */
 	if (conn->ksnc_ipaddr != conn->ksnc_myipaddr) {
-		list_for_each_entry(conn2, &peer->ksnp_conns, ksnc_list) {
+		list_for_each_entry(conn2, &peer_ni->ksnp_conns, ksnc_list) {
 
 			if (conn2->ksnc_ipaddr != conn->ksnc_ipaddr ||
 			    conn2->ksnc_myipaddr != conn->ksnc_myipaddr ||
@@ -1223,7 +1230,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 	if (active &&
 	    route->ksnr_ipaddr != conn->ksnc_ipaddr) {
 		CERROR("Route %s %pI4h connected to %pI4h\n",
-		       libcfs_id2str(peer->ksnp_id),
+		       libcfs_id2str(peer_ni->ksnp_id),
 		       &route->ksnr_ipaddr,
 		       &conn->ksnc_ipaddr);
 	}
@@ -1231,10 +1238,10 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 	/*
 	 * Search for a route corresponding to the new connection and
 	 * create an association.  This allows incoming connections created
-	 * by routes in my peer to match my own route entries so I don't
+	 * by routes in my peer_ni to match my own route entries so I don't
 	 * continually create duplicate routes.
 	 */
-	list_for_each_entry(route, &peer->ksnp_routes, ksnr_list) {
+	list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list) {
 		if (route->ksnr_ipaddr != conn->ksnc_ipaddr)
 			continue;
 
@@ -1242,10 +1249,10 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 		break;
 	}
 
-	conn->ksnc_peer = peer;		 /* conn takes my ref on peer */
-	peer->ksnp_last_alive = ktime_get_seconds();
-	peer->ksnp_send_keepalive = 0;
-	peer->ksnp_error = 0;
+	conn->ksnc_peer = peer_ni;	/* conn takes my ref on peer_ni */
+	peer_ni->ksnp_last_alive = ktime_get_seconds();
+	peer_ni->ksnp_send_keepalive = 0;
+	peer_ni->ksnp_error = 0;
 
 	sched = ksocknal_choose_scheduler_locked(cpt);
 	sched->kss_nconns++;
@@ -1256,9 +1263,9 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 	conn->ksnc_tx_bufnob = sock->sk->sk_wmem_queued;
 	conn->ksnc_tx_deadline = ktime_get_seconds() +
 				 *ksocknal_tunables.ksnd_timeout;
-	mb();   /* order with adding to peer's conn list */
+	mb();   /* order with adding to peer_ni's conn list */
 
-	list_add(&conn->ksnc_list, &peer->ksnp_conns);
+	list_add(&conn->ksnc_list, &peer_ni->ksnp_conns);
 	ksocknal_conn_addref(conn);
 
 	ksocknal_new_packet(conn, 0);
@@ -1266,7 +1273,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 	conn->ksnc_zc_capable = ksocknal_lib_zc_capable(conn);
 
 	/* Take packets blocking for this connection. */
-	list_for_each_entry_safe(tx, txtmp, &peer->ksnp_tx_queue, tx_list) {
+	list_for_each_entry_safe(tx, txtmp, &peer_ni->ksnp_tx_queue, tx_list) {
 		int match = conn->ksnc_proto->pro_match_tx(conn, tx,
 							   tx->tx_nonblk);
 
@@ -1295,10 +1302,10 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 
 	if (active) {
 		/* additional routes after interface exchange? */
-		ksocknal_create_routes(peer, conn->ksnc_port,
+		ksocknal_create_routes(peer_ni, conn->ksnc_port,
 				       hello->kshm_ips, hello->kshm_nips);
 	} else {
-		hello->kshm_nips = ksocknal_select_ips(peer, hello->kshm_ips,
+		hello->kshm_nips = ksocknal_select_ips(peer_ni, hello->kshm_ips,
 						       hello->kshm_nips);
 		rc = ksocknal_send_hello(ni, conn, peerid.nid, hello);
 	}
@@ -1321,7 +1328,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 	ksocknal_lib_set_callback(sock, conn);
 
 	if (!active)
-		peer->ksnp_accepting--;
+		peer_ni->ksnp_accepting--;
 
 	write_unlock_bh(global_lock);
 
@@ -1344,12 +1351,12 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 	return rc;
 
  failed_2:
-	if (!peer->ksnp_closing &&
-	    list_empty(&peer->ksnp_conns) &&
-	    list_empty(&peer->ksnp_routes)) {
-		list_add(&zombies, &peer->ksnp_tx_queue);
-		list_del_init(&peer->ksnp_tx_queue);
-		ksocknal_unlink_peer_locked(peer);
+	if (!peer_ni->ksnp_closing &&
+	    list_empty(&peer_ni->ksnp_conns) &&
+	    list_empty(&peer_ni->ksnp_routes)) {
+		list_add(&zombies, &peer_ni->ksnp_tx_queue);
+		list_del_init(&peer_ni->ksnp_tx_queue);
+		ksocknal_unlink_peer_locked(peer_ni);
 	}
 
 	write_unlock_bh(global_lock);
@@ -1375,12 +1382,12 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 		}
 
 		write_lock_bh(global_lock);
-		peer->ksnp_accepting--;
+		peer_ni->ksnp_accepting--;
 		write_unlock_bh(global_lock);
 	}
 
 	ksocknal_txlist_done(ni, &zombies, 1);
-	ksocknal_peer_decref(peer);
+	ksocknal_peer_decref(peer_ni);
 
 failed_1:
 	kvfree(hello);
@@ -1400,15 +1407,15 @@ ksocknal_close_conn_locked(struct ksock_conn *conn, int error)
 	 * connection for the reaper to terminate.
 	 * Caller holds ksnd_global_lock exclusively in irq context
 	 */
-	struct ksock_peer *peer = conn->ksnc_peer;
+	struct ksock_peer *peer_ni = conn->ksnc_peer;
 	struct ksock_route *route;
 	struct ksock_conn *conn2;
 
-	LASSERT(!peer->ksnp_error);
+	LASSERT(!peer_ni->ksnp_error);
 	LASSERT(!conn->ksnc_closing);
 	conn->ksnc_closing = 1;
 
-	/* ksnd_deathrow_conns takes over peer's ref */
+	/* ksnd_deathrow_conns takes over peer_ni's ref */
 	list_del(&conn->ksnc_list);
 
 	route = conn->ksnc_route;
@@ -1417,7 +1424,7 @@ ksocknal_close_conn_locked(struct ksock_conn *conn, int error)
 		LASSERT(!route->ksnr_deleted);
 		LASSERT(route->ksnr_connected & (1 << conn->ksnc_type));
 
-		list_for_each_entry(conn2, &peer->ksnp_conns, ksnc_list) {
+		list_for_each_entry(conn2, &peer_ni->ksnp_conns, ksnc_list) {
 			if (conn2->ksnc_route == route &&
 			    conn2->ksnc_type == conn->ksnc_type)
 				goto conn2_found;
@@ -1429,10 +1436,10 @@ ksocknal_close_conn_locked(struct ksock_conn *conn, int error)
 		ksocknal_route_decref(route);     /* drop conn's ref on route */
 	}
 
-	if (list_empty(&peer->ksnp_conns)) {
-		/* No more connections to this peer */
+	if (list_empty(&peer_ni->ksnp_conns)) {
+		/* No more connections to this peer_ni */
 
-		if (!list_empty(&peer->ksnp_tx_queue)) {
+		if (!list_empty(&peer_ni->ksnp_tx_queue)) {
 			struct ksock_tx *tx;
 
 			LASSERT(conn->ksnc_proto == &ksocknal_protocol_v3x);
@@ -1441,25 +1448,25 @@ ksocknal_close_conn_locked(struct ksock_conn *conn, int error)
 			 * throw them to the last connection...,
 			 * these TXs will be send to /dev/null by scheduler
 			 */
-			list_for_each_entry(tx, &peer->ksnp_tx_queue,
+			list_for_each_entry(tx, &peer_ni->ksnp_tx_queue,
 					    tx_list)
 				ksocknal_tx_prep(conn, tx);
 
 			spin_lock_bh(&conn->ksnc_scheduler->kss_lock);
-			list_splice_init(&peer->ksnp_tx_queue,
+			list_splice_init(&peer_ni->ksnp_tx_queue,
 					 &conn->ksnc_tx_queue);
 			spin_unlock_bh(&conn->ksnc_scheduler->kss_lock);
 		}
 
-		peer->ksnp_proto = NULL;  /* renegotiate protocol version */
-		peer->ksnp_error = error; /* stash last conn close reason */
+		peer_ni->ksnp_proto = NULL;  /* renegotiate protocol version */
+		peer_ni->ksnp_error = error; /* stash last conn close reason */
 
-		if (list_empty(&peer->ksnp_routes)) {
+		if (list_empty(&peer_ni->ksnp_routes)) {
 			/*
 			 * I've just closed last conn belonging to a
-			 * peer with no routes to it
+			 * peer_ni with no routes to it
 			 */
-			ksocknal_unlink_peer_locked(peer);
+			ksocknal_unlink_peer_locked(peer_ni);
 		}
 	}
 
@@ -1473,37 +1480,37 @@ ksocknal_close_conn_locked(struct ksock_conn *conn, int error)
 }
 
 void
-ksocknal_peer_failed(struct ksock_peer *peer)
+ksocknal_peer_failed(struct ksock_peer *peer_ni)
 {
 	int notify = 0;
 	time64_t last_alive = 0;
 
 	/*
 	 * There has been a connection failure or comms error; but I'll only
-	 * tell LNET I think the peer is dead if it's to another kernel and
+	 * tell LNET I think the peer_ni is dead if it's to another kernel and
 	 * there are no connections or connection attempts in existence.
 	 */
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
-	if (!(peer->ksnp_id.pid & LNET_PID_USERFLAG) &&
-	    list_empty(&peer->ksnp_conns) &&
-	    !peer->ksnp_accepting &&
-	    !ksocknal_find_connecting_route_locked(peer)) {
+	if (!(peer_ni->ksnp_id.pid & LNET_PID_USERFLAG) &&
+	    list_empty(&peer_ni->ksnp_conns) &&
+	    !peer_ni->ksnp_accepting &&
+	    !ksocknal_find_connecting_route_locked(peer_ni)) {
 		notify = 1;
-		last_alive = peer->ksnp_last_alive;
+		last_alive = peer_ni->ksnp_last_alive;
 	}
 
 	read_unlock(&ksocknal_data.ksnd_global_lock);
 
 	if (notify)
-		lnet_notify(peer->ksnp_ni, peer->ksnp_id.nid, 0,
+		lnet_notify(peer_ni->ksnp_ni, peer_ni->ksnp_id.nid, 0,
 			    last_alive);
 }
 
 void
 ksocknal_finalize_zcreq(struct ksock_conn *conn)
 {
-	struct ksock_peer *peer = conn->ksnc_peer;
+	struct ksock_peer *peer_ni = conn->ksnc_peer;
 	struct ksock_tx *tx;
 	struct ksock_tx *tmp;
 	LIST_HEAD(zlist);
@@ -1514,9 +1521,10 @@ ksocknal_finalize_zcreq(struct ksock_conn *conn)
 	 */
 	LASSERT(!conn->ksnc_sock);
 
-	spin_lock(&peer->ksnp_lock);
+	spin_lock(&peer_ni->ksnp_lock);
 
-	list_for_each_entry_safe(tx, tmp, &peer->ksnp_zc_req_list, tx_zc_list) {
+	list_for_each_entry_safe(tx, tmp, &peer_ni->ksnp_zc_req_list,
+				 tx_zc_list) {
 		if (tx->tx_conn != conn)
 			continue;
 
@@ -1528,7 +1536,7 @@ ksocknal_finalize_zcreq(struct ksock_conn *conn)
 		list_add(&tx->tx_zc_list, &zlist);
 	}
 
-	spin_unlock(&peer->ksnp_lock);
+	spin_unlock(&peer_ni->ksnp_lock);
 
 	while (!list_empty(&zlist)) {
 		tx = list_entry(zlist.next, struct ksock_tx, tx_zc_list);
@@ -1547,7 +1555,7 @@ ksocknal_terminate_conn(struct ksock_conn *conn)
 	 * ksnc_refcount will eventually hit zero, and then the reaper will
 	 * destroy it.
 	 */
-	struct ksock_peer *peer = conn->ksnc_peer;
+	struct ksock_peer *peer_ni = conn->ksnc_peer;
 	struct ksock_sched *sched = conn->ksnc_scheduler;
 	int failed = 0;
 
@@ -1583,17 +1591,17 @@ ksocknal_terminate_conn(struct ksock_conn *conn)
 	 */
 	conn->ksnc_scheduler->kss_nconns--;
 
-	if (peer->ksnp_error) {
-		/* peer's last conn closed in error */
-		LASSERT(list_empty(&peer->ksnp_conns));
+	if (peer_ni->ksnp_error) {
+		/* peer_ni's last conn closed in error */
+		LASSERT(list_empty(&peer_ni->ksnp_conns));
 		failed = 1;
-		peer->ksnp_error = 0;     /* avoid multiple notifications */
+		peer_ni->ksnp_error = 0;     /* avoid multiple notifications */
 	}
 
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
 	if (failed)
-		ksocknal_peer_failed(peer);
+		ksocknal_peer_failed(peer_ni);
 
 	/*
 	 * The socket is closed on the final put; either here, or in
@@ -1679,14 +1687,15 @@ ksocknal_destroy_conn(struct ksock_conn *conn)
 }
 
 int
-ksocknal_close_peer_conns_locked(struct ksock_peer *peer, __u32 ipaddr, int why)
+ksocknal_close_peer_conns_locked(struct ksock_peer *peer_ni,
+				 __u32 ipaddr, int why)
 {
 	struct ksock_conn *conn;
 	struct list_head *ctmp;
 	struct list_head *cnxt;
 	int count = 0;
 
-	list_for_each_safe(ctmp, cnxt, &peer->ksnp_conns) {
+	list_for_each_safe(ctmp, cnxt, &peer_ni->ksnp_conns) {
 		conn = list_entry(ctmp, struct ksock_conn, ksnc_list);
 
 		if (!ipaddr || conn->ksnc_ipaddr == ipaddr) {
@@ -1701,13 +1710,13 @@ ksocknal_close_peer_conns_locked(struct ksock_peer *peer, __u32 ipaddr, int why)
 int
 ksocknal_close_conn_and_siblings(struct ksock_conn *conn, int why)
 {
-	struct ksock_peer *peer = conn->ksnc_peer;
+	struct ksock_peer *peer_ni = conn->ksnc_peer;
 	__u32 ipaddr = conn->ksnc_ipaddr;
 	int count;
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
-	count = ksocknal_close_peer_conns_locked(peer, ipaddr, why);
+	count = ksocknal_close_peer_conns_locked(peer_ni, ipaddr, why);
 
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
@@ -1717,9 +1726,8 @@ ksocknal_close_conn_and_siblings(struct ksock_conn *conn, int why)
 int
 ksocknal_close_matching_conns(struct lnet_process_id id, __u32 ipaddr)
 {
-	struct ksock_peer *peer;
-	struct list_head *ptmp;
-	struct list_head *pnxt;
+	struct ksock_peer *peer_ni;
+	struct ksock_peer *pnxt;
 	int lo;
 	int hi;
 	int i;
@@ -1736,16 +1744,17 @@ ksocknal_close_matching_conns(struct lnet_process_id id, __u32 ipaddr)
 	}
 
 	for (i = lo; i <= hi; i++) {
-		list_for_each_safe(ptmp, pnxt,
-				   &ksocknal_data.ksnd_peers[i]) {
-			peer = list_entry(ptmp, struct ksock_peer, ksnp_list);
-
-			if (!((id.nid == LNET_NID_ANY || id.nid == peer->ksnp_id.nid) &&
-			      (id.pid == LNET_PID_ANY || id.pid == peer->ksnp_id.pid)))
+		list_for_each_entry_safe(peer_ni, pnxt,
+					 &ksocknal_data.ksnd_peers[i],
+					 ksnp_list) {
+			if (!((id.nid == LNET_NID_ANY ||
+			       id.nid == peer_ni->ksnp_id.nid) &&
+			      (id.pid == LNET_PID_ANY ||
+			       id.pid == peer_ni->ksnp_id.pid)))
 				continue;
 
-			count += ksocknal_close_peer_conns_locked(peer, ipaddr,
-								  0);
+			count += ksocknal_close_peer_conns_locked(peer_ni,
+								  ipaddr, 0);
 		}
 	}
 
@@ -1794,7 +1803,7 @@ ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when)
 	int connect = 1;
 	time64_t last_alive = 0;
 	time64_t now = ktime_get_seconds();
-	struct ksock_peer *peer = NULL;
+	struct ksock_peer *peer_ni = NULL;
 	rwlock_t *glock = &ksocknal_data.ksnd_global_lock;
 	struct lnet_process_id id = {
 		.nid = nid,
@@ -1803,25 +1812,25 @@ ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when)
 
 	read_lock(glock);
 
-	peer = ksocknal_find_peer_locked(ni, id);
-	if (peer) {
+	peer_ni = ksocknal_find_peer_locked(ni, id);
+	if (peer_ni) {
 		struct ksock_conn *conn;
 		int bufnob;
 
-		list_for_each_entry(conn, &peer->ksnp_conns, ksnc_list) {
+		list_for_each_entry(conn, &peer_ni->ksnp_conns, ksnc_list) {
 			bufnob = conn->ksnc_sock->sk->sk_wmem_queued;
 
 			if (bufnob < conn->ksnc_tx_bufnob) {
 				/* something got ACKed */
 				conn->ksnc_tx_deadline = ktime_get_seconds() +
 							 *ksocknal_tunables.ksnd_timeout;
-				peer->ksnp_last_alive = now;
+				peer_ni->ksnp_last_alive = now;
 				conn->ksnc_tx_bufnob = bufnob;
 			}
 		}
 
-		last_alive = peer->ksnp_last_alive;
-		if (!ksocknal_find_connectable_route_locked(peer))
+		last_alive = peer_ni->ksnp_last_alive;
+		if (!ksocknal_find_connectable_route_locked(peer_ni))
 			connect = 0;
 	}
 
@@ -1830,8 +1839,8 @@ ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when)
 	if (last_alive)
 		*when = last_alive * HZ;
 
-	CDEBUG(D_NET, "Peer %s %p, alive %lld secs ago, connect %d\n",
-	       libcfs_nid2str(nid), peer,
+	CDEBUG(D_NET, "peer_ni %s %p, alive %lld secs ago, connect %d\n",
+	       libcfs_nid2str(nid), peer_ni,
 	       last_alive ? now - last_alive : -1,
 	       connect);
 
@@ -1842,15 +1851,15 @@ ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when)
 
 	write_lock_bh(glock);
 
-	peer = ksocknal_find_peer_locked(ni, id);
-	if (peer)
-		ksocknal_launch_all_connections_locked(peer);
+	peer_ni = ksocknal_find_peer_locked(ni, id);
+	if (peer_ni)
+		ksocknal_launch_all_connections_locked(peer_ni);
 
 	write_unlock_bh(glock);
 }
 
 static void
-ksocknal_push_peer(struct ksock_peer *peer)
+ksocknal_push_peer(struct ksock_peer *peer_ni)
 {
 	int index;
 	int i;
@@ -1862,7 +1871,7 @@ ksocknal_push_peer(struct ksock_peer *peer)
 		i = 0;
 		conn = NULL;
 
-		list_for_each_entry(conn, &peer->ksnp_conns, ksnc_list) {
+		list_for_each_entry(conn, &peer_ni->ksnp_conns, ksnc_list) {
 			if (i++ == index) {
 				ksocknal_conn_addref(conn);
 				break;
@@ -1896,22 +1905,22 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	}
 
 	for (tmp = start; tmp <= end; tmp++) {
-		int peer_off; /* searching offset in peer hash table */
+		int peer_off; /* searching offset in peer_ni hash table */
 
 		for (peer_off = 0; ; peer_off++) {
-			struct ksock_peer *peer;
+			struct ksock_peer *peer_ni;
 			int i = 0;
 
 			read_lock(&ksocknal_data.ksnd_global_lock);
-			list_for_each_entry(peer, tmp, ksnp_list) {
+			list_for_each_entry(peer_ni, tmp, ksnp_list) {
 				if (!((id.nid == LNET_NID_ANY ||
-				       id.nid == peer->ksnp_id.nid) &&
+				       id.nid == peer_ni->ksnp_id.nid) &&
 				      (id.pid == LNET_PID_ANY ||
-				       id.pid == peer->ksnp_id.pid)))
+				       id.pid == peer_ni->ksnp_id.pid)))
 					continue;
 
 				if (i++ == peer_off) {
-					ksocknal_peer_addref(peer);
+					ksocknal_peer_addref(peer_ni);
 					break;
 				}
 			}
@@ -1921,8 +1930,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 				break;
 
 			rc = 0;
-			ksocknal_push_peer(peer);
-			ksocknal_peer_decref(peer);
+			ksocknal_push_peer(peer_ni);
+			ksocknal_peer_decref(peer_ni);
 		}
 	}
 	return rc;
@@ -1936,7 +1945,7 @@ ksocknal_add_interface(struct lnet_ni *ni, __u32 ipaddress, __u32 netmask)
 	int rc;
 	int i;
 	int j;
-	struct ksock_peer *peer;
+	struct ksock_peer *peer_ni;
 	struct ksock_route *route;
 
 	if (!ipaddress || !netmask)
@@ -1959,14 +1968,19 @@ ksocknal_add_interface(struct lnet_ni *ni, __u32 ipaddress, __u32 netmask)
 		iface->ksni_npeers = 0;
 
 		for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
-			list_for_each_entry(peer, &ksocknal_data.ksnd_peers[i],
+			list_for_each_entry(peer_ni,
+					    &ksocknal_data.ksnd_peers[i],
 					    ksnp_list) {
 
-				for (j = 0; j < peer->ksnp_n_passive_ips; j++)
-					if (peer->ksnp_passive_ips[j] == ipaddress)
+				for (j = 0;
+				     j < peer_ni->ksnp_n_passive_ips;
+				     j++)
+					if (peer_ni->ksnp_passive_ips[j] ==
+					    ipaddress)
 						iface->ksni_npeers++;
 
-				list_for_each_entry(route, &peer->ksnp_routes,
+				list_for_each_entry(route,
+						    &peer_ni->ksnp_routes,
 						    ksnr_list) {
 					if (route->ksnr_myipaddr == ipaddress)
 						iface->ksni_nroutes++;
@@ -1987,7 +2001,7 @@ ksocknal_add_interface(struct lnet_ni *ni, __u32 ipaddress, __u32 netmask)
 }
 
 static void
-ksocknal_peer_del_interface_locked(struct ksock_peer *peer, __u32 ipaddr)
+ksocknal_peer_del_interface_locked(struct ksock_peer *peer_ni, __u32 ipaddr)
 {
 	struct list_head *tmp;
 	struct list_head *nxt;
@@ -1996,16 +2010,16 @@ ksocknal_peer_del_interface_locked(struct ksock_peer *peer, __u32 ipaddr)
 	int i;
 	int j;
 
-	for (i = 0; i < peer->ksnp_n_passive_ips; i++)
-		if (peer->ksnp_passive_ips[i] == ipaddr) {
-			for (j = i + 1; j < peer->ksnp_n_passive_ips; j++)
-				peer->ksnp_passive_ips[j - 1] =
-					peer->ksnp_passive_ips[j];
-			peer->ksnp_n_passive_ips--;
+	for (i = 0; i < peer_ni->ksnp_n_passive_ips; i++)
+		if (peer_ni->ksnp_passive_ips[i] == ipaddr) {
+			for (j = i + 1; j < peer_ni->ksnp_n_passive_ips; j++)
+				peer_ni->ksnp_passive_ips[j - 1] =
+					peer_ni->ksnp_passive_ips[j];
+			peer_ni->ksnp_n_passive_ips--;
 			break;
 		}
 
-	list_for_each_safe(tmp, nxt, &peer->ksnp_routes) {
+	list_for_each_safe(tmp, nxt, &peer_ni->ksnp_routes) {
 		route = list_entry(tmp, struct ksock_route, ksnr_list);
 
 		if (route->ksnr_myipaddr != ipaddr)
@@ -2019,7 +2033,7 @@ ksocknal_peer_del_interface_locked(struct ksock_peer *peer, __u32 ipaddr)
 		}
 	}
 
-	list_for_each_safe(tmp, nxt, &peer->ksnp_conns) {
+	list_for_each_safe(tmp, nxt, &peer_ni->ksnp_conns) {
 		conn = list_entry(tmp, struct ksock_conn, ksnc_list);
 
 		if (conn->ksnc_myipaddr == ipaddr)
@@ -2032,9 +2046,8 @@ ksocknal_del_interface(struct lnet_ni *ni, __u32 ipaddress)
 {
 	struct ksock_net *net = ni->ni_data;
 	int rc = -ENOENT;
-	struct list_head *tmp;
-	struct list_head *nxt;
-	struct ksock_peer *peer;
+	struct ksock_peer *nxt;
+	struct ksock_peer *peer_ni;
 	__u32 this_ip;
 	int i;
 	int j;
@@ -2056,14 +2069,14 @@ ksocknal_del_interface(struct lnet_ni *ni, __u32 ipaddress)
 		net->ksnn_ninterfaces--;
 
 		for (j = 0; j < ksocknal_data.ksnd_peer_hash_size; j++) {
-			list_for_each_safe(tmp, nxt,
-					   &ksocknal_data.ksnd_peers[j]) {
-				peer = list_entry(tmp, struct ksock_peer, ksnp_list);
-
-				if (peer->ksnp_ni != ni)
+			list_for_each_entry_safe(peer_ni, nxt,
+						 &ksocknal_data.ksnd_peers[j],
+						 ksnp_list) {
+				if (peer_ni->ksnp_ni != ni)
 					continue;
 
-				ksocknal_peer_del_interface_locked(peer, this_ip);
+				ksocknal_peer_del_interface_locked(peer_ni,
+								   this_ip);
 			}
 		}
 	}
@@ -2461,36 +2474,41 @@ ksocknal_base_startup(void)
 static void
 ksocknal_debug_peerhash(struct lnet_ni *ni)
 {
-	struct ksock_peer *peer = NULL;
+	struct ksock_peer *peer_ni = NULL;
 	int i;
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
 	for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
-		list_for_each_entry(peer, &ksocknal_data.ksnd_peers[i], ksnp_list) {
+		list_for_each_entry(peer_ni, &ksocknal_data.ksnd_peers[i],
+				    ksnp_list) {
 			struct ksock_route *route;
 			struct ksock_conn  *conn;
 
-			if (peer->ksnp_ni != ni)
+			if (peer_ni->ksnp_ni != ni)
 				continue;
 
-			CWARN("Active peer on shutdown: %s, ref %d, scnt %d, closing %d, accepting %d, err %d, zcookie %llu, txq %d, zc_req %d\n",
-			      libcfs_id2str(peer->ksnp_id),
-			      atomic_read(&peer->ksnp_refcount),
-			      peer->ksnp_sharecount, peer->ksnp_closing,
-			      peer->ksnp_accepting, peer->ksnp_error,
-			      peer->ksnp_zc_next_cookie,
-			      !list_empty(&peer->ksnp_tx_queue),
-			      !list_empty(&peer->ksnp_zc_req_list));
+			CWARN("Active peer_ni on shutdown: %s, ref %d, scnt %d, closing %d, accepting %d, err %d, zcookie %llu, txq %d, zc_req %d\n",
+			      libcfs_id2str(peer_ni->ksnp_id),
+			      atomic_read(&peer_ni->ksnp_refcount),
+			      peer_ni->ksnp_sharecount, peer_ni->ksnp_closing,
+			      peer_ni->ksnp_accepting, peer_ni->ksnp_error,
+			      peer_ni->ksnp_zc_next_cookie,
+			      !list_empty(&peer_ni->ksnp_tx_queue),
+			      !list_empty(&peer_ni->ksnp_zc_req_list));
 
-			list_for_each_entry(route, &peer->ksnp_routes, ksnr_list) {
+			list_for_each_entry(route, &peer_ni->ksnp_routes,
+					    ksnr_list) {
 				CWARN("Route: ref %d, schd %d, conn %d, cnted %d, del %d\n",
 				      atomic_read(&route->ksnr_refcount),
-				      route->ksnr_scheduled, route->ksnr_connecting,
-				      route->ksnr_connected, route->ksnr_deleted);
+				      route->ksnr_scheduled,
+				      route->ksnr_connecting,
+				      route->ksnr_connected,
+				      route->ksnr_deleted);
 			}
 
-			list_for_each_entry(conn, &peer->ksnp_conns, ksnc_list) {
+			list_for_each_entry(conn, &peer_ni->ksnp_conns,
+					    ksnc_list) {
 				CWARN("Conn: ref %d, sref %d, t %d, c %d\n",
 				      atomic_read(&conn->ksnc_conn_refcount),
 				      atomic_read(&conn->ksnc_sock_refcount),
@@ -2523,7 +2541,7 @@ ksocknal_shutdown(struct lnet_ni *ni)
 	/* Delete all peers */
 	ksocknal_del_peer(ni, anyid, 0);
 
-	/* Wait for all peer state to clean up */
+	/* Wait for all peer_ni state to clean up */
 	i = 2;
 	spin_lock_bh(&net->ksnn_lock);
 	while (net->ksnn_npeers) {
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 2a619291fccc..cc813e4c1422 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -54,7 +54,7 @@
 #define SOCKNAL_NSCHEDS		3
 #define SOCKNAL_NSCHEDS_HIGH	(SOCKNAL_NSCHEDS << 1)
 
-#define SOCKNAL_PEER_HASH_SIZE  101   /* # peer lists */
+#define SOCKNAL_PEER_HASH_SIZE  101   /* # peer_ni lists */
 #define SOCKNAL_RESCHED         100   /* # scheduler loops before reschedule */
 #define SOCKNAL_INSANITY_RECONN 5000  /* connd is trying on reconn infinitely */
 #define SOCKNAL_ENOMEM_RETRY    1     /* seconds between retries */
@@ -142,10 +142,11 @@ struct ksock_tunables {
 	int          *ksnd_credits;            /* # concurrent sends */
 	int          *ksnd_peertxcredits;      /* # concurrent sends to 1 peer
 						*/
-	int          *ksnd_peerrtrcredits;     /* # per-peer router buffer
+	int          *ksnd_peerrtrcredits;     /* # per-peer_ni router buffer
 						* credits
 						*/
-	int          *ksnd_peertimeout;        /* seconds to consider peer dead
+	int          *ksnd_peertimeout;        /* seconds to consider
+						* peer_ni dead
 						*/
 	int          *ksnd_enable_csum;        /* enable check sum */
 	int          *ksnd_inject_csum_error;  /* set non-zero to inject
@@ -185,8 +186,8 @@ struct ksock_nal_data {
 							 */
 	int                     ksnd_nnets;             /* # networks set up */
 	struct list_head        ksnd_nets;              /* list of nets */
-	rwlock_t                ksnd_global_lock;       /* stabilize peer/conn
-							 * ops
+	rwlock_t                ksnd_global_lock;       /* stabilize
+							 * peer_ni/conn ops
 							 */
 	struct list_head        *ksnd_peers;            /* hash table of all my
 							 * known peers
@@ -270,7 +271,7 @@ struct ksock_proto; /* forward ref */
 struct ksock_tx {			   /* transmit packet */
 	struct list_head  tx_list;         /* queue on conn for transmission etc
 					    */
-	struct list_head  tx_zc_list;      /* queue on peer for ZC request */
+	struct list_head  tx_zc_list;      /* queue on peer_ni for ZC request */
 	atomic_t          tx_refcount;     /* tx reference count */
 	int               tx_nob;          /* # packet bytes */
 	int               tx_resid;        /* residual bytes */
@@ -311,9 +312,9 @@ struct ksock_tx {			   /* transmit packet */
 #define SOCKNAL_RX_SLOP         6 /* skipping body */
 
 struct ksock_conn {
-	struct ksock_peer  *ksnc_peer;        /* owning peer */
+	struct ksock_peer  *ksnc_peer;        /* owning peer_ni */
 	struct ksock_route *ksnc_route;       /* owning route */
-	struct list_head   ksnc_list;         /* stash on peer's conn list */
+	struct list_head   ksnc_list;         /* stash on peer_ni's conn list */
 	struct socket      *ksnc_sock;        /* actual socket */
 	void               *ksnc_saved_data_ready;  /* socket's original
 						     * data_ready() callback
@@ -326,8 +327,8 @@ struct ksock_conn {
 	struct ksock_sched *ksnc_scheduler;	/* who schedules this connection
 						 */
 	__u32              ksnc_myipaddr;     /* my IP */
-	__u32              ksnc_ipaddr;       /* peer's IP */
-	int                ksnc_port;         /* peer's port */
+	__u32              ksnc_ipaddr;       /* peer_ni's IP */
+	int                ksnc_port;         /* peer_ni's port */
 	signed int         ksnc_type:3;       /* type of connection, should be
 					       * signed value
 					       */
@@ -382,9 +383,9 @@ struct ksock_conn {
 };
 
 struct ksock_route {
-	struct list_head  ksnr_list;           /* chain on peer route list */
+	struct list_head  ksnr_list;           /* chain on peer_ni route list */
 	struct list_head  ksnr_connd_list;     /* chain on ksnr_connd_routes */
-	struct ksock_peer *ksnr_peer;          /* owning peer */
+	struct ksock_peer *ksnr_peer;          /* owning peer_ni */
 	atomic_t          ksnr_refcount;       /* # users */
 	time64_t	  ksnr_timeout;        /* when (in secs) reconnection
 						* can happen next
@@ -400,7 +401,7 @@ struct ksock_route {
 	unsigned int      ksnr_connected:4;    /* connections established by
 						* type
 						*/
-	unsigned int      ksnr_deleted:1;      /* been removed from peer? */
+	unsigned int      ksnr_deleted:1;      /* been removed from peer_ni? */
 	unsigned int      ksnr_share_count;    /* created explicitly? */
 	int               ksnr_conn_count;     /* # conns established by this
 						* route
@@ -410,7 +411,7 @@ struct ksock_route {
 #define SOCKNAL_KEEPALIVE_PING 1 /* cookie for keepalive ping */
 
 struct ksock_peer {
-	struct list_head   ksnp_list;           /* stash on global peer list */
+	struct list_head   ksnp_list;         /* stash on global peer_ni list */
 	time64_t	   ksnp_last_alive;     /* when (in seconds) I was last
 						 * alive
 						 */
@@ -422,9 +423,12 @@ struct ksock_peer {
 						 */
 	int                ksnp_error;          /* errno on closing last conn */
 	__u64              ksnp_zc_next_cookie; /* ZC completion cookie */
-	__u64              ksnp_incarnation;    /* latest known peer incarnation
+	__u64              ksnp_incarnation;    /* latest known peer_ni
+						 * incarnation
+						 */
+	struct ksock_proto *ksnp_proto;         /* latest known peer_ni
+						 * protocol
 						 */
-	struct ksock_proto *ksnp_proto;         /* latest known peer protocol */
 	struct list_head   ksnp_conns;          /* all active connections */
 	struct list_head   ksnp_routes;         /* routes */
 	struct list_head   ksnp_tx_queue;       /* waiting packets */
@@ -606,20 +610,20 @@ ksocknal_route_decref(struct ksock_route *route)
 }
 
 static inline void
-ksocknal_peer_addref(struct ksock_peer *peer)
+ksocknal_peer_addref(struct ksock_peer *peer_ni)
 {
-	LASSERT(atomic_read(&peer->ksnp_refcount) > 0);
-	atomic_inc(&peer->ksnp_refcount);
+	LASSERT(atomic_read(&peer_ni->ksnp_refcount) > 0);
+	atomic_inc(&peer_ni->ksnp_refcount);
 }
 
-void ksocknal_destroy_peer(struct ksock_peer *peer);
+void ksocknal_destroy_peer(struct ksock_peer *peer_ni);
 
 static inline void
-ksocknal_peer_decref(struct ksock_peer *peer)
+ksocknal_peer_decref(struct ksock_peer *peer_ni)
 {
-	LASSERT(atomic_read(&peer->ksnp_refcount) > 0);
-	if (atomic_dec_and_test(&peer->ksnp_refcount))
-		ksocknal_destroy_peer(peer);
+	LASSERT(atomic_read(&peer_ni->ksnp_refcount) > 0);
+	if (atomic_dec_and_test(&peer_ni->ksnp_refcount))
+		ksocknal_destroy_peer(peer_ni);
 }
 
 int ksocknal_startup(struct lnet_ni *ni);
@@ -636,17 +640,17 @@ struct ksock_peer *ksocknal_find_peer_locked(struct lnet_ni *ni,
 					     struct lnet_process_id id);
 struct ksock_peer *ksocknal_find_peer(struct lnet_ni *ni,
 				      struct lnet_process_id id);
-void ksocknal_peer_failed(struct ksock_peer *peer);
+void ksocknal_peer_failed(struct ksock_peer *peer_ni);
 int ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 			 struct socket *sock, int type);
 void ksocknal_close_conn_locked(struct ksock_conn *conn, int why);
 void ksocknal_terminate_conn(struct ksock_conn *conn);
 void ksocknal_destroy_conn(struct ksock_conn *conn);
-int  ksocknal_close_peer_conns_locked(struct ksock_peer *peer,
+int  ksocknal_close_peer_conns_locked(struct ksock_peer *peer_ni,
 				      __u32 ipaddr, int why);
 int ksocknal_close_conn_and_siblings(struct ksock_conn *conn, int why);
 int ksocknal_close_matching_conns(struct lnet_process_id id, __u32 ipaddr);
-struct ksock_conn *ksocknal_find_conn_locked(struct ksock_peer *peer,
+struct ksock_conn *ksocknal_find_conn_locked(struct ksock_peer *peer_ni,
 					     struct ksock_tx *tx, int nonblk);
 
 int  ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
@@ -661,9 +665,11 @@ void ksocknal_notify(struct lnet_ni *ni, lnet_nid_t gw_nid, int alive);
 void ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when);
 int ksocknal_thread_start(int (*fn)(void *arg), void *arg, char *name);
 void ksocknal_thread_fini(void);
-void ksocknal_launch_all_connections_locked(struct ksock_peer *peer);
-struct ksock_route *ksocknal_find_connectable_route_locked(struct ksock_peer *peer);
-struct ksock_route *ksocknal_find_connecting_route_locked(struct ksock_peer *peer);
+void ksocknal_launch_all_connections_locked(struct ksock_peer *peer_ni);
+struct ksock_route *ksocknal_find_connectable_route_locked(
+	struct ksock_peer *peer_ni);
+struct ksock_route *ksocknal_find_connecting_route_locked(
+	struct ksock_peer *peer_ni);
 int ksocknal_new_packet(struct ksock_conn *conn, int skip);
 int ksocknal_scheduler(void *arg);
 int ksocknal_connd(void *arg);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 32b76727f400..1bf0170503ed 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -375,12 +375,12 @@ static void
 ksocknal_check_zc_req(struct ksock_tx *tx)
 {
 	struct ksock_conn *conn = tx->tx_conn;
-	struct ksock_peer *peer = conn->ksnc_peer;
+	struct ksock_peer *peer_ni = conn->ksnc_peer;
 
 	/*
 	 * Set tx_msg.ksm_zc_cookies[0] to a unique non-zero cookie and add tx
 	 * to ksnp_zc_req_list if some fragment of this message should be sent
-	 * zero-copy.  Our peer will send an ACK containing this cookie when
+	 * zero-copy.  Our peer_ni will send an ACK containing this cookie when
 	 * she has received this message to tell us we can signal completion.
 	 * tx_msg.ksm_zc_cookies[0] remains non-zero while tx is on
 	 * ksnp_zc_req_list.
@@ -400,46 +400,46 @@ ksocknal_check_zc_req(struct ksock_tx *tx)
 	 */
 	ksocknal_tx_addref(tx);
 
-	spin_lock(&peer->ksnp_lock);
+	spin_lock(&peer_ni->ksnp_lock);
 
-	/* ZC_REQ is going to be pinned to the peer */
+	/* ZC_REQ is going to be pinned to the peer_ni */
 	tx->tx_deadline = ktime_get_seconds() +
 			  *ksocknal_tunables.ksnd_timeout;
 
 	LASSERT(!tx->tx_msg.ksm_zc_cookies[0]);
 
-	tx->tx_msg.ksm_zc_cookies[0] = peer->ksnp_zc_next_cookie++;
+	tx->tx_msg.ksm_zc_cookies[0] = peer_ni->ksnp_zc_next_cookie++;
 
-	if (!peer->ksnp_zc_next_cookie)
-		peer->ksnp_zc_next_cookie = SOCKNAL_KEEPALIVE_PING + 1;
+	if (!peer_ni->ksnp_zc_next_cookie)
+		peer_ni->ksnp_zc_next_cookie = SOCKNAL_KEEPALIVE_PING + 1;
 
-	list_add_tail(&tx->tx_zc_list, &peer->ksnp_zc_req_list);
+	list_add_tail(&tx->tx_zc_list, &peer_ni->ksnp_zc_req_list);
 
-	spin_unlock(&peer->ksnp_lock);
+	spin_unlock(&peer_ni->ksnp_lock);
 }
 
 static void
 ksocknal_uncheck_zc_req(struct ksock_tx *tx)
 {
-	struct ksock_peer *peer = tx->tx_conn->ksnc_peer;
+	struct ksock_peer *peer_ni = tx->tx_conn->ksnc_peer;
 
 	LASSERT(tx->tx_msg.ksm_type != KSOCK_MSG_NOOP);
 	LASSERT(tx->tx_zc_capable);
 
 	tx->tx_zc_checked = 0;
 
-	spin_lock(&peer->ksnp_lock);
+	spin_lock(&peer_ni->ksnp_lock);
 
 	if (!tx->tx_msg.ksm_zc_cookies[0]) {
 		/* Not waiting for an ACK */
-		spin_unlock(&peer->ksnp_lock);
+		spin_unlock(&peer_ni->ksnp_lock);
 		return;
 	}
 
 	tx->tx_msg.ksm_zc_cookies[0] = 0;
 	list_del(&tx->tx_zc_list);
 
-	spin_unlock(&peer->ksnp_lock);
+	spin_unlock(&peer_ni->ksnp_lock);
 
 	ksocknal_tx_decref(tx);
 }
@@ -540,14 +540,14 @@ ksocknal_launch_connection_locked(struct ksock_route *route)
 }
 
 void
-ksocknal_launch_all_connections_locked(struct ksock_peer *peer)
+ksocknal_launch_all_connections_locked(struct ksock_peer *peer_ni)
 {
 	struct ksock_route *route;
 
 	/* called holding write lock on ksnd_global_lock */
 	for (;;) {
 		/* launch any/all connections that need it */
-		route = ksocknal_find_connectable_route_locked(peer);
+		route = ksocknal_find_connectable_route_locked(peer_ni);
 		if (!route)
 			return;
 
@@ -556,7 +556,7 @@ ksocknal_launch_all_connections_locked(struct ksock_peer *peer)
 }
 
 struct ksock_conn *
-ksocknal_find_conn_locked(struct ksock_peer *peer, struct ksock_tx *tx,
+ksocknal_find_conn_locked(struct ksock_peer *peer_ni, struct ksock_tx *tx,
 			  int nonblk)
 {
 	struct ksock_conn *c;
@@ -566,7 +566,7 @@ ksocknal_find_conn_locked(struct ksock_peer *peer, struct ksock_tx *tx,
 	int tnob = 0;
 	int fnob = 0;
 
-	list_for_each_entry(c, &peer->ksnp_conns, ksnc_list) {
+	list_for_each_entry(c, &peer_ni->ksnp_conns, ksnc_list) {
 		int nob, rc;
 
 		nob = atomic_read(&c->ksnc_tx_nob) +
@@ -722,12 +722,12 @@ ksocknal_queue_tx_locked(struct ksock_tx *tx, struct ksock_conn *conn)
 }
 
 struct ksock_route *
-ksocknal_find_connectable_route_locked(struct ksock_peer *peer)
+ksocknal_find_connectable_route_locked(struct ksock_peer *peer_ni)
 {
 	time64_t now = ktime_get_seconds();
 	struct ksock_route *route;
 
-	list_for_each_entry(route, &peer->ksnp_routes, ksnr_list) {
+	list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list) {
 		LASSERT(!route->ksnr_connecting || route->ksnr_scheduled);
 
 		/* connections being established */
@@ -756,11 +756,11 @@ ksocknal_find_connectable_route_locked(struct ksock_peer *peer)
 }
 
 struct ksock_route *
-ksocknal_find_connecting_route_locked(struct ksock_peer *peer)
+ksocknal_find_connecting_route_locked(struct ksock_peer *peer_ni)
 {
 	struct ksock_route *route;
 
-	list_for_each_entry(route, &peer->ksnp_routes, ksnr_list) {
+	list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list) {
 
 		LASSERT(!route->ksnr_connecting || route->ksnr_scheduled);
 
@@ -775,7 +775,7 @@ int
 ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 		       struct lnet_process_id id)
 {
-	struct ksock_peer *peer;
+	struct ksock_peer *peer_ni;
 	struct ksock_conn *conn;
 	rwlock_t *g_lock;
 	int retry;
@@ -787,10 +787,11 @@ ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 
 	for (retry = 0;; retry = 1) {
 		read_lock(g_lock);
-		peer = ksocknal_find_peer_locked(ni, id);
-		if (peer) {
-			if (!ksocknal_find_connectable_route_locked(peer)) {
-				conn = ksocknal_find_conn_locked(peer, tx, tx->tx_nonblk);
+		peer_ni = ksocknal_find_peer_locked(ni, id);
+		if (peer_ni) {
+			if (!ksocknal_find_connectable_route_locked(peer_ni)) {
+				conn = ksocknal_find_conn_locked(peer_ni, tx,
+								 tx->tx_nonblk);
 				if (conn) {
 					/*
 					 * I've got no routes that need to be
@@ -809,8 +810,8 @@ ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 
 		write_lock_bh(g_lock);
 
-		peer = ksocknal_find_peer_locked(ni, id);
-		if (peer)
+		peer_ni = ksocknal_find_peer_locked(ni, id);
+		if (peer_ni)
 			break;
 
 		write_unlock_bh(g_lock);
@@ -822,7 +823,7 @@ ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 		}
 
 		if (retry) {
-			CERROR("Can't find peer %s\n", libcfs_id2str(id));
+			CERROR("Can't find peer_ni %s\n", libcfs_id2str(id));
 			return -EHOSTUNREACH;
 		}
 
@@ -830,15 +831,15 @@ ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 				       LNET_NIDADDR(id.nid),
 				       lnet_acceptor_port());
 		if (rc) {
-			CERROR("Can't add peer %s: %d\n",
+			CERROR("Can't add peer_ni %s: %d\n",
 			       libcfs_id2str(id), rc);
 			return rc;
 		}
 	}
 
-	ksocknal_launch_all_connections_locked(peer);
+	ksocknal_launch_all_connections_locked(peer_ni);
 
-	conn = ksocknal_find_conn_locked(peer, tx, tx->tx_nonblk);
+	conn = ksocknal_find_conn_locked(peer_ni, tx, tx->tx_nonblk);
 	if (conn) {
 		/* Connection exists; queue message on it */
 		ksocknal_queue_tx_locked(tx, conn);
@@ -846,14 +847,14 @@ ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 		return 0;
 	}
 
-	if (peer->ksnp_accepting > 0 ||
-	    ksocknal_find_connecting_route_locked(peer)) {
-		/* the message is going to be pinned to the peer */
+	if (peer_ni->ksnp_accepting > 0 ||
+	    ksocknal_find_connecting_route_locked(peer_ni)) {
+		/* the message is going to be pinned to the peer_ni */
 		tx->tx_deadline = ktime_get_seconds() +
 				  *ksocknal_tunables.ksnd_timeout;
 
 		/* Queue the message until a connection is established */
-		list_add_tail(&tx->tx_list, &peer->ksnp_tx_queue);
+		list_add_tail(&tx->tx_list, &peer_ni->ksnp_tx_queue);
 		write_unlock_bh(g_lock);
 		return 0;
 	}
@@ -1167,7 +1168,7 @@ ksocknal_process_receive(struct ksock_conn *conn)
 		conn->ksnc_proto->pro_unpack(&conn->ksnc_msg);
 
 		if (conn->ksnc_peer->ksnp_id.pid & LNET_PID_USERFLAG) {
-			/* Userspace peer */
+			/* Userspace peer_ni */
 			lhdr = &conn->ksnc_msg.ksm_u.lnetmsg.ksnm_hdr;
 			id = &conn->ksnc_peer->ksnp_id;
 
@@ -1667,7 +1668,9 @@ ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 	proto = ksocknal_parse_proto_version(hello);
 	if (!proto) {
 		if (!active) {
-			/* unknown protocol from peer, tell peer my protocol */
+			/* unknown protocol from peer_ni,
+			 * tell peer_ni my protocol
+			 */
 			conn->ksnc_proto = &ksocknal_protocol_v3x;
 #if SOCKNAL_VERSION_DEBUG
 			if (*ksocknal_tunables.ksnd_protocol == 2)
@@ -1708,7 +1711,7 @@ ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 
 	if (!active &&
 	    conn->ksnc_port > LNET_ACCEPTOR_MAX_RESERVED_PORT) {
-		/* Userspace NAL assigns peer process ID from socket */
+		/* Userspace NAL assigns peer_ni process ID from socket */
 		recv_id.pid = conn->ksnc_port | LNET_PID_USERFLAG;
 		recv_id.nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid),
 					 conn->ksnc_ipaddr);
@@ -1720,7 +1723,7 @@ ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 	if (!active) {
 		*peerid = recv_id;
 
-		/* peer determines type */
+		/* peer_ni determines type */
 		conn->ksnc_type = ksocknal_invert_type(hello->kshm_ctype);
 		if (conn->ksnc_type == SOCKLND_CONN_NONE) {
 			CERROR("Unexpected type %d from %s ip %pI4h\n",
@@ -1760,7 +1763,7 @@ static int
 ksocknal_connect(struct ksock_route *route)
 {
 	LIST_HEAD(zombies);
-	struct ksock_peer *peer = route->ksnr_peer;
+	struct ksock_peer *peer_ni = route->ksnr_peer;
 	int type;
 	int wanted;
 	struct socket *sock;
@@ -1781,21 +1784,21 @@ ksocknal_connect(struct ksock_route *route)
 		wanted = ksocknal_route_mask() & ~route->ksnr_connected;
 
 		/*
-		 * stop connecting if peer/route got closed under me, or
+		 * stop connecting if peer_ni/route got closed under me, or
 		 * route got connected while queued
 		 */
-		if (peer->ksnp_closing || route->ksnr_deleted ||
+		if (peer_ni->ksnp_closing || route->ksnr_deleted ||
 		    !wanted) {
 			retry_later = 0;
 			break;
 		}
 
-		/* reschedule if peer is connecting to me */
-		if (peer->ksnp_accepting > 0) {
+		/* reschedule if peer_ni is connecting to me */
+		if (peer_ni->ksnp_accepting > 0) {
 			CDEBUG(D_NET,
-			       "peer %s(%d) already connecting to me, retry later.\n",
-			       libcfs_nid2str(peer->ksnp_id.nid),
-			       peer->ksnp_accepting);
+			       "peer_ni %s(%d) already connecting to me, retry later.\n",
+			       libcfs_nid2str(peer_ni->ksnp_id.nid),
+			       peer_ni->ksnp_accepting);
 			retry_later = 1;
 		}
 
@@ -1817,21 +1820,21 @@ ksocknal_connect(struct ksock_route *route)
 
 		if (ktime_get_seconds() >= deadline) {
 			rc = -ETIMEDOUT;
-			lnet_connect_console_error(rc, peer->ksnp_id.nid,
+			lnet_connect_console_error(rc, peer_ni->ksnp_id.nid,
 						   route->ksnr_ipaddr,
 						   route->ksnr_port);
 			goto failed;
 		}
 
-		rc = lnet_connect(&sock, peer->ksnp_id.nid,
+		rc = lnet_connect(&sock, peer_ni->ksnp_id.nid,
 				  route->ksnr_myipaddr,
 				  route->ksnr_ipaddr, route->ksnr_port);
 		if (rc)
 			goto failed;
 
-		rc = ksocknal_create_conn(peer->ksnp_ni, route, sock, type);
+		rc = ksocknal_create_conn(peer_ni->ksnp_ni, route, sock, type);
 		if (rc < 0) {
-			lnet_connect_console_error(rc, peer->ksnp_id.nid,
+			lnet_connect_console_error(rc, peer_ni->ksnp_id.nid,
 						   route->ksnr_ipaddr,
 						   route->ksnr_port);
 			goto failed;
@@ -1843,8 +1846,8 @@ ksocknal_connect(struct ksock_route *route)
 		 */
 		retry_later = (rc);
 		if (retry_later)
-			CDEBUG(D_NET, "peer %s: conn race, retry later.\n",
-			       libcfs_nid2str(peer->ksnp_id.nid));
+			CDEBUG(D_NET, "peer_ni %s: conn race, retry later.\n",
+			       libcfs_nid2str(peer_ni->ksnp_id.nid));
 
 		write_lock_bh(&ksocknal_data.ksnd_global_lock);
 	}
@@ -1855,10 +1858,10 @@ ksocknal_connect(struct ksock_route *route)
 	if (retry_later) {
 		/*
 		 * re-queue for attention; this frees me up to handle
-		 * the peer's incoming connection request
+		 * the peer_ni's incoming connection request
 		 */
 		if (rc == EALREADY ||
-		    (!rc && peer->ksnp_accepting > 0)) {
+		    (!rc && peer_ni->ksnp_accepting > 0)) {
 			/*
 			 * We want to introduce a delay before next
 			 * attempt to connect if we lost conn race,
@@ -1895,17 +1898,17 @@ ksocknal_connect(struct ksock_route *route)
 	LASSERT(route->ksnr_retry_interval);
 	route->ksnr_timeout = ktime_get_seconds() + route->ksnr_retry_interval;
 
-	if (!list_empty(&peer->ksnp_tx_queue) &&
-	    !peer->ksnp_accepting &&
-	    !ksocknal_find_connecting_route_locked(peer)) {
+	if (!list_empty(&peer_ni->ksnp_tx_queue) &&
+	    !peer_ni->ksnp_accepting &&
+	    !ksocknal_find_connecting_route_locked(peer_ni)) {
 		struct ksock_conn *conn;
 
 		/*
 		 * ksnp_tx_queue is queued on a conn on successful
 		 * connection for V1.x and V2.x
 		 */
-		if (!list_empty(&peer->ksnp_conns)) {
-			conn = list_entry(peer->ksnp_conns.next,
+		if (!list_empty(&peer_ni->ksnp_conns)) {
+			conn = list_entry(peer_ni->ksnp_conns.next,
 					  struct ksock_conn, ksnc_list);
 			LASSERT(conn->ksnc_proto == &ksocknal_protocol_v3x);
 		}
@@ -1914,13 +1917,13 @@ ksocknal_connect(struct ksock_route *route)
 		 * take all the blocked packets while I've got the lock and
 		 * complete below...
 		 */
-		list_splice_init(&peer->ksnp_tx_queue, &zombies);
+		list_splice_init(&peer_ni->ksnp_tx_queue, &zombies);
 	}
 
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
-	ksocknal_peer_failed(peer);
-	ksocknal_txlist_done(peer->ksnp_ni, &zombies, 1);
+	ksocknal_peer_failed(peer_ni);
+	ksocknal_txlist_done(peer_ni->ksnp_ni, &zombies, 1);
 	return 0;
 }
 
@@ -2167,12 +2170,12 @@ ksocknal_connd(void *arg)
 }
 
 static struct ksock_conn *
-ksocknal_find_timed_out_conn(struct ksock_peer *peer)
+ksocknal_find_timed_out_conn(struct ksock_peer *peer_ni)
 {
 	/* We're called with a shared lock on ksnd_global_lock */
 	struct ksock_conn *conn;
 
-	list_for_each_entry(conn, &peer->ksnp_conns, ksnc_list) {
+	list_for_each_entry(conn, &peer_ni->ksnp_conns, ksnc_list) {
 		int error;
 
 		/* Don't need the {get,put}connsock dance to deref ksnc_sock */
@@ -2189,20 +2192,20 @@ ksocknal_find_timed_out_conn(struct ksock_peer *peer)
 			switch (error) {
 			case ECONNRESET:
 				CNETERR("A connection with %s (%pI4h:%d) was reset; it may have rebooted.\n",
-					libcfs_id2str(peer->ksnp_id),
+					libcfs_id2str(peer_ni->ksnp_id),
 					&conn->ksnc_ipaddr,
 					conn->ksnc_port);
 				break;
 			case ETIMEDOUT:
 				CNETERR("A connection with %s (%pI4h:%d) timed out; the network or node may be down.\n",
-					libcfs_id2str(peer->ksnp_id),
+					libcfs_id2str(peer_ni->ksnp_id),
 					&conn->ksnc_ipaddr,
 					conn->ksnc_port);
 				break;
 			default:
 				CNETERR("An unexpected network error %d occurred with %s (%pI4h:%d\n",
 					error,
-					libcfs_id2str(peer->ksnp_id),
+					libcfs_id2str(peer_ni->ksnp_id),
 					&conn->ksnc_ipaddr,
 					conn->ksnc_port);
 				break;
@@ -2216,7 +2219,7 @@ ksocknal_find_timed_out_conn(struct ksock_peer *peer)
 			/* Timed out incomplete incoming message */
 			ksocknal_conn_addref(conn);
 			CNETERR("Timeout receiving from %s (%pI4h:%d), state %d wanted %zd left %d\n",
-				libcfs_id2str(peer->ksnp_id),
+				libcfs_id2str(peer_ni->ksnp_id),
 				&conn->ksnc_ipaddr,
 				conn->ksnc_port,
 				conn->ksnc_rx_state,
@@ -2234,7 +2237,7 @@ ksocknal_find_timed_out_conn(struct ksock_peer *peer)
 			 */
 			ksocknal_conn_addref(conn);
 			CNETERR("Timeout sending data to %s (%pI4h:%d) the network or that node may be down.\n",
-				libcfs_id2str(peer->ksnp_id),
+				libcfs_id2str(peer_ni->ksnp_id),
 				&conn->ksnc_ipaddr,
 				conn->ksnc_port);
 			return conn;
@@ -2245,15 +2248,16 @@ ksocknal_find_timed_out_conn(struct ksock_peer *peer)
 }
 
 static inline void
-ksocknal_flush_stale_txs(struct ksock_peer *peer)
+ksocknal_flush_stale_txs(struct ksock_peer *peer_ni)
 {
 	struct ksock_tx *tx;
 	LIST_HEAD(stale_txs);
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
-	while (!list_empty(&peer->ksnp_tx_queue)) {
-		tx = list_entry(peer->ksnp_tx_queue.next, struct ksock_tx, tx_list);
+	while (!list_empty(&peer_ni->ksnp_tx_queue)) {
+		tx = list_entry(peer_ni->ksnp_tx_queue.next, struct ksock_tx,
+				tx_list);
 
 		if (ktime_get_seconds() < tx->tx_deadline)
 			break;
@@ -2264,11 +2268,11 @@ ksocknal_flush_stale_txs(struct ksock_peer *peer)
 
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
-	ksocknal_txlist_done(peer->ksnp_ni, &stale_txs, 1);
+	ksocknal_txlist_done(peer_ni->ksnp_ni, &stale_txs, 1);
 }
 
 static int
-ksocknal_send_keepalive_locked(struct ksock_peer *peer)
+ksocknal_send_keepalive_locked(struct ksock_peer *peer_ni)
 	__must_hold(&ksocknal_data.ksnd_global_lock)
 {
 	struct ksock_sched *sched;
@@ -2276,27 +2280,27 @@ ksocknal_send_keepalive_locked(struct ksock_peer *peer)
 	struct ksock_tx *tx;
 
 	/* last_alive will be updated by create_conn */
-	if (list_empty(&peer->ksnp_conns))
+	if (list_empty(&peer_ni->ksnp_conns))
 		return 0;
 
-	if (peer->ksnp_proto != &ksocknal_protocol_v3x)
+	if (peer_ni->ksnp_proto != &ksocknal_protocol_v3x)
 		return 0;
 
 	if (*ksocknal_tunables.ksnd_keepalive <= 0 ||
-	    ktime_get_seconds() < peer->ksnp_last_alive +
+	    ktime_get_seconds() < peer_ni->ksnp_last_alive +
 				  *ksocknal_tunables.ksnd_keepalive)
 		return 0;
 
-	if (ktime_get_seconds() < peer->ksnp_send_keepalive)
+	if (ktime_get_seconds() < peer_ni->ksnp_send_keepalive)
 		return 0;
 
 	/*
 	 * retry 10 secs later, so we wouldn't put pressure
-	 * on this peer if we failed to send keepalive this time
+	 * on this peer_ni if we failed to send keepalive this time
 	 */
-	peer->ksnp_send_keepalive = ktime_get_seconds() + 10;
+	peer_ni->ksnp_send_keepalive = ktime_get_seconds() + 10;
 
-	conn = ksocknal_find_conn_locked(peer, NULL, 1);
+	conn = ksocknal_find_conn_locked(peer_ni, NULL, 1);
 	if (conn) {
 		sched = conn->ksnc_scheduler;
 
@@ -2319,7 +2323,7 @@ ksocknal_send_keepalive_locked(struct ksock_peer *peer)
 		return -ENOMEM;
 	}
 
-	if (!ksocknal_launch_packet(peer->ksnp_ni, tx, peer->ksnp_id)) {
+	if (!ksocknal_launch_packet(peer_ni->ksnp_ni, tx, peer_ni->ksnp_id)) {
 		read_lock(&ksocknal_data.ksnd_global_lock);
 		return 1;
 	}
@@ -2334,7 +2338,7 @@ static void
 ksocknal_check_peer_timeouts(int idx)
 {
 	struct list_head *peers = &ksocknal_data.ksnd_peers[idx];
-	struct ksock_peer *peer;
+	struct ksock_peer *peer_ni;
 	struct ksock_conn *conn;
 	struct ksock_tx *tx;
 
@@ -2346,18 +2350,18 @@ ksocknal_check_peer_timeouts(int idx)
 	 */
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
-	list_for_each_entry(peer, peers, ksnp_list) {
+	list_for_each_entry(peer_ni, peers, ksnp_list) {
 		struct ksock_tx *tx_stale;
 		time64_t deadline = 0;
 		int resid = 0;
 		int n = 0;
 
-		if (ksocknal_send_keepalive_locked(peer)) {
+		if (ksocknal_send_keepalive_locked(peer_ni)) {
 			read_unlock(&ksocknal_data.ksnd_global_lock);
 			goto again;
 		}
 
-		conn = ksocknal_find_timed_out_conn(peer);
+		conn = ksocknal_find_timed_out_conn(peer_ni);
 
 		if (conn) {
 			read_unlock(&ksocknal_data.ksnd_global_lock);
@@ -2366,7 +2370,7 @@ ksocknal_check_peer_timeouts(int idx)
 
 			/*
 			 * NB we won't find this one again, but we can't
-			 * just proceed with the next peer, since we dropped
+			 * just proceed with the next peer_ni, since we dropped
 			 * ksnd_global_lock and it might be dead already!
 			 */
 			ksocknal_conn_decref(conn);
@@ -2377,27 +2381,28 @@ ksocknal_check_peer_timeouts(int idx)
 		 * we can't process stale txs right here because we're
 		 * holding only shared lock
 		 */
-		if (!list_empty(&peer->ksnp_tx_queue)) {
-			tx = list_entry(peer->ksnp_tx_queue.next,
+		if (!list_empty(&peer_ni->ksnp_tx_queue)) {
+			tx = list_entry(peer_ni->ksnp_tx_queue.next,
 					struct ksock_tx, tx_list);
 
 			if (ktime_get_seconds() >= tx->tx_deadline) {
-				ksocknal_peer_addref(peer);
+				ksocknal_peer_addref(peer_ni);
 				read_unlock(&ksocknal_data.ksnd_global_lock);
 
-				ksocknal_flush_stale_txs(peer);
+				ksocknal_flush_stale_txs(peer_ni);
 
-				ksocknal_peer_decref(peer);
+				ksocknal_peer_decref(peer_ni);
 				goto again;
 			}
 		}
 
-		if (list_empty(&peer->ksnp_zc_req_list))
+		if (list_empty(&peer_ni->ksnp_zc_req_list))
 			continue;
 
 		tx_stale = NULL;
-		spin_lock(&peer->ksnp_lock);
-		list_for_each_entry(tx, &peer->ksnp_zc_req_list, tx_zc_list) {
+		spin_lock(&peer_ni->ksnp_lock);
+		list_for_each_entry(tx, &peer_ni->ksnp_zc_req_list,
+				    tx_zc_list) {
 			if (ktime_get_seconds() < tx->tx_deadline)
 				break;
 			/* ignore the TX if connection is being closed */
@@ -2409,7 +2414,7 @@ ksocknal_check_peer_timeouts(int idx)
 		}
 
 		if (!tx_stale) {
-			spin_unlock(&peer->ksnp_lock);
+			spin_unlock(&peer_ni->ksnp_lock);
 			continue;
 		}
 
@@ -2418,11 +2423,11 @@ ksocknal_check_peer_timeouts(int idx)
 		conn = tx_stale->tx_conn;
 		ksocknal_conn_addref(conn);
 
-		spin_unlock(&peer->ksnp_lock);
+		spin_unlock(&peer_ni->ksnp_lock);
 		read_unlock(&ksocknal_data.ksnd_global_lock);
 
-		CERROR("Total %d stale ZC_REQs for peer %s detected; the oldest(%p) timed out %lld secs ago, resid: %d, wmem: %d\n",
-		       n, libcfs_nid2str(peer->ksnp_id.nid), tx_stale,
+		CERROR("Total %d stale ZC_REQs for peer_ni %s detected; the oldest(%p) timed out %lld secs ago, resid: %d, wmem: %d\n",
+		       n, libcfs_nid2str(peer_ni->ksnp_id.nid), tx_stale,
 		       ktime_get_seconds() - deadline,
 		       resid, conn->ksnc_sock->sk->sk_wmem_queued);
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 93a02cd6b6b5..33847b9615ed 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -44,7 +44,7 @@ ksocknal_lib_get_conn_addrs(struct ksock_conn *conn)
 	LASSERT(!conn->ksnc_closing);
 
 	if (rc) {
-		CERROR("Error %d getting sock peer IP\n", rc);
+		CERROR("Error %d getting sock peer_ni IP\n", rc);
 		return rc;
 	}
 
@@ -157,7 +157,7 @@ ksocknal_lib_eager_ack(struct ksock_conn *conn)
 	 * Remind the socket to ACK eagerly.  If I don't, the socket might
 	 * think I'm about to send something it could piggy-back the ACK
 	 * on, introducing delay in completing zero-copy sends in my
-	 * peer.
+	 * peer_ni.
 	 */
 	kernel_setsockopt(sock, SOL_TCP, TCP_QUICKACK, (char *)&opt,
 			  sizeof(opt));
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index abfaf5701758..8c10eda382b7 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -367,14 +367,14 @@ ksocknal_match_tx_v3(struct ksock_conn *conn, struct ksock_tx *tx, int nonblk)
 static int
 ksocknal_handle_zcreq(struct ksock_conn *c, __u64 cookie, int remote)
 {
-	struct ksock_peer *peer = c->ksnc_peer;
+	struct ksock_peer *peer_ni = c->ksnc_peer;
 	struct ksock_conn *conn;
 	struct ksock_tx *tx;
 	int rc;
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
-	conn = ksocknal_find_conn_locked(peer, NULL, !!remote);
+	conn = ksocknal_find_conn_locked(peer_ni, NULL, !!remote);
 	if (conn) {
 		struct ksock_sched *sched = conn->ksnc_scheduler;
 
@@ -399,7 +399,7 @@ ksocknal_handle_zcreq(struct ksock_conn *c, __u64 cookie, int remote)
 	if (!tx)
 		return -ENOMEM;
 
-	rc = ksocknal_launch_packet(peer->ksnp_ni, tx, peer->ksnp_id);
+	rc = ksocknal_launch_packet(peer_ni->ksnp_ni, tx, peer_ni->ksnp_id);
 	if (!rc)
 		return 0;
 
@@ -411,7 +411,7 @@ ksocknal_handle_zcreq(struct ksock_conn *c, __u64 cookie, int remote)
 static int
 ksocknal_handle_zcack(struct ksock_conn *conn, __u64 cookie1, __u64 cookie2)
 {
-	struct ksock_peer *peer = conn->ksnc_peer;
+	struct ksock_peer *peer_ni = conn->ksnc_peer;
 	struct ksock_tx *tx;
 	struct ksock_tx *tmp;
 	LIST_HEAD(zlist);
@@ -428,9 +428,9 @@ ksocknal_handle_zcack(struct ksock_conn *conn, __u64 cookie1, __u64 cookie2)
 		return count == 1 ? 0 : -EPROTO;
 	}
 
-	spin_lock(&peer->ksnp_lock);
+	spin_lock(&peer_ni->ksnp_lock);
 
-	list_for_each_entry_safe(tx, tmp, &peer->ksnp_zc_req_list,
+	list_for_each_entry_safe(tx, tmp, &peer_ni->ksnp_zc_req_list,
 				 tx_zc_list) {
 		__u64 c = tx->tx_msg.ksm_zc_cookies[0];
 
@@ -445,7 +445,7 @@ ksocknal_handle_zcack(struct ksock_conn *conn, __u64 cookie1, __u64 cookie2)
 		}
 	}
 
-	spin_unlock(&peer->ksnp_lock);
+	spin_unlock(&peer_ni->ksnp_lock);
 
 	while (!list_empty(&zlist)) {
 		tx = list_entry(zlist.next, struct ksock_tx, tx_zc_list);
