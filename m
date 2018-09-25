From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 15/34] LU-7734 lnet: handle N NIs to 1 LND
 peer
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763544.32103.10828937501297905304.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

This patch changes o2iblnd only, as socklnd already handles this
case. In the new design you can have multiple NIs communicating
to one peer. In the o2ilbnd the kib_peer has a pointer to the NI
which implies a 1:1 relationship.

This patch changes kiblnd_find_peer_locked() to use the peer NID
and the NI NID as the key. This way a new peer will be created for
each unique NI/peer_NI pair.

This is similar to how socklnd handles this case.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: Ifab7764489757ea473b15c46c1a22ef9ceeeceea
Reviewed-on: http://review.whamcloud.com/19306
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Tested-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   13 ++++++++++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    8 ++++----
 3 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 2e71abbf8a0c..64df49146413 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -379,7 +379,7 @@ void kiblnd_destroy_peer(struct kib_peer *peer)
 	atomic_dec(&net->ibn_npeers);
 }
 
-struct kib_peer *kiblnd_find_peer_locked(lnet_nid_t nid)
+struct kib_peer *kiblnd_find_peer_locked(struct lnet_ni *ni, lnet_nid_t nid)
 {
 	/*
 	 * the caller is responsible for accounting the additional reference
@@ -391,7 +391,14 @@ struct kib_peer *kiblnd_find_peer_locked(lnet_nid_t nid)
 	list_for_each_entry(peer, peer_list, ibp_list) {
 		LASSERT(!kiblnd_peer_idle(peer));
 
-		if (peer->ibp_nid != nid)
+		/*
+		 * Match a peer if its NID and the NID of the local NI it
+		 * communicates over are the same. Otherwise don't match
+		 * the peer, which will result in a new lnd peer being
+		 * created.
+		 */
+		if (peer->ibp_nid != nid ||
+		    peer->ibp_ni->ni_nid != ni->ni_nid)
 			continue;
 
 		CDEBUG(D_NET, "got peer [%p] -> %s (%d) version: %x\n",
@@ -1041,7 +1048,7 @@ static void kiblnd_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when)
 
 	read_lock_irqsave(glock, flags);
 
-	peer = kiblnd_find_peer_locked(nid);
+	peer = kiblnd_find_peer_locked(ni, nid);
 	if (peer)
 		last_alive = peer->ibp_last_alive;
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 522eb150d9a6..520f586015f4 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -1019,7 +1019,7 @@ void kiblnd_destroy_peer(struct kib_peer *peer);
 bool kiblnd_reconnect_peer(struct kib_peer *peer);
 void kiblnd_destroy_dev(struct kib_dev *dev);
 void kiblnd_unlink_peer_locked(struct kib_peer *peer);
-struct kib_peer *kiblnd_find_peer_locked(lnet_nid_t nid);
+struct kib_peer *kiblnd_find_peer_locked(struct lnet_ni *ni, lnet_nid_t nid);
 int  kiblnd_close_stale_conns_locked(struct kib_peer *peer,
 				     int version, __u64 incarnation);
 int  kiblnd_close_peer_conns_locked(struct kib_peer *peer, int why);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index af8f863b6a68..f4b76347e1c6 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1370,7 +1370,7 @@ kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 	 */
 	read_lock_irqsave(g_lock, flags);
 
-	peer = kiblnd_find_peer_locked(nid);
+	peer = kiblnd_find_peer_locked(ni, nid);
 	if (peer && !list_empty(&peer->ibp_conns)) {
 		/* Found a peer with an established connection */
 		conn = kiblnd_get_conn_locked(peer);
@@ -1388,7 +1388,7 @@ kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 	/* Re-try with a write lock */
 	write_lock(g_lock);
 
-	peer = kiblnd_find_peer_locked(nid);
+	peer = kiblnd_find_peer_locked(ni, nid);
 	if (peer) {
 		if (list_empty(&peer->ibp_conns)) {
 			/* found a peer, but it's still connecting... */
@@ -1426,7 +1426,7 @@ kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 
 	write_lock_irqsave(g_lock, flags);
 
-	peer2 = kiblnd_find_peer_locked(nid);
+	peer2 = kiblnd_find_peer_locked(ni, nid);
 	if (peer2) {
 		if (list_empty(&peer2->ibp_conns)) {
 			/* found a peer, but it's still connecting... */
@@ -2388,7 +2388,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 
 	write_lock_irqsave(g_lock, flags);
 
-	peer2 = kiblnd_find_peer_locked(nid);
+	peer2 = kiblnd_find_peer_locked(ni, nid);
 	if (peer2) {
 		if (!peer2->ibp_version) {
 			peer2->ibp_version     = version;
