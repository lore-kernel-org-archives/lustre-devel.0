From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Oct 2018 10:19:38 +1100
Subject: [lustre-devel] [PATCH 14/24] lustre: lnet: reference counts on
 lnet_peer/lnet_peer_net
In-Reply-To: <153895417139.16383.3791701638653772865.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
Message-ID: <153895437808.16383.1725584261522697360.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf@sgi.com>

Peer discovery will be keeping track of lnet_peer structures,
so there will be references to an lnet_peer independent of
the references implied by lnet_peer_ni structures. Manage
this by adding explicit reference counts to lnet_peer_net and
lnet_peer.

Each lnet_peer_net has a hold on the lnet_peer it links to
with its lpn_peer pointer. This hold is only removed when that
pointer is assigned a new value or the lnet_peer_net is freed.
Just removing an lnet_peer_net from the lp_peer_nets list does
not release this hold, it just prevents new lookups of the
lnet_peer_net via the lnet_peer.

Each lnet_peer_ni has a hold on the lnet_peer_net it links to
with its lpni_peer_net pointer. This hold is only removed when
that pointer is assigned a new value or the lnet_peer_ni is
freed. Just removing an lnet_peer_ni from the lpn_peer_nis
list does not release this hold, it just prevents new lookups
of the lnet_peer_ni via the lnet_peer_net.

This ensures that given a lnet_peer_ni *lpni, we can rely on
lpni->lpni_peer_net->lpn_peer pointing to a valid lnet_peer.

Keep a count of the total number of lnet_peer_ni attached to
an lnet_peer in lp_nnis.

Split the global ln_peers list into per-lnet_peer_table lists.
The CPT of the peer table in which the lnet_peer is linked is
stored in lp_cpt.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
Signed-off-by: Olaf Weber <olaf@sgi.com>
Reviewed-on: https://review.whamcloud.com/25784
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Tested-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   49 +++--
 .../staging/lustre/include/linux/lnet/lib-types.h  |   50 ++++-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    1 
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    8 -
 drivers/staging/lustre/lnet/lnet/peer.c            |  210 ++++++++++++++------
 5 files changed, 227 insertions(+), 91 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 563417510722..aad25eb0011b 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -310,6 +310,36 @@ lnet_handle2me(struct lnet_handle_me *handle)
 	return lh_entry(lh, struct lnet_me, me_lh);
 }
 
+static inline void
+lnet_peer_net_addref_locked(struct lnet_peer_net *lpn)
+{
+	atomic_inc(&lpn->lpn_refcount);
+}
+
+void lnet_destroy_peer_net_locked(struct lnet_peer_net *lpn);
+
+static inline void
+lnet_peer_net_decref_locked(struct lnet_peer_net *lpn)
+{
+	if (atomic_dec_and_test(&lpn->lpn_refcount))
+		lnet_destroy_peer_net_locked(lpn);
+}
+
+static inline void
+lnet_peer_addref_locked(struct lnet_peer *lp)
+{
+	atomic_inc(&lp->lp_refcount);
+}
+
+void lnet_destroy_peer_locked(struct lnet_peer *lp);
+
+static inline void
+lnet_peer_decref_locked(struct lnet_peer *lp)
+{
+	if (atomic_dec_and_test(&lp->lp_refcount))
+		lnet_destroy_peer_locked(lp);
+}
+
 static inline void
 lnet_peer_ni_addref_locked(struct lnet_peer_ni *lp)
 {
@@ -695,21 +725,6 @@ int lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
 			  __u32 *peer_rtr_credits, __u32 *peer_min_rtr_credtis,
 			  __u32 *peer_tx_qnob);
 
-static inline __u32
-lnet_get_num_peer_nis(struct lnet_peer *peer)
-{
-	struct lnet_peer_net *lpn;
-	struct lnet_peer_ni *lpni;
-	__u32 count = 0;
-
-	list_for_each_entry(lpn, &peer->lp_peer_nets, lpn_on_peer_list)
-		list_for_each_entry(lpni, &lpn->lpn_peer_nis,
-				    lpni_on_peer_net_list)
-			count++;
-
-	return count;
-}
-
 static inline bool
 lnet_is_peer_ni_healthy_locked(struct lnet_peer_ni *lpni)
 {
@@ -728,7 +743,7 @@ lnet_is_peer_net_healthy_locked(struct lnet_peer_net *peer_net)
 	struct lnet_peer_ni *lpni;
 
 	list_for_each_entry(lpni, &peer_net->lpn_peer_nis,
-			    lpni_on_peer_net_list) {
+			    lpni_peer_nis) {
 		if (lnet_is_peer_ni_healthy_locked(lpni))
 			return true;
 	}
@@ -741,7 +756,7 @@ lnet_is_peer_healthy_locked(struct lnet_peer *peer)
 {
 	struct lnet_peer_net *peer_net;
 
-	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_on_peer_list) {
+	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_peer_nets) {
 		if (lnet_is_peer_net_healthy_locked(peer_net))
 			return true;
 	}
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index d1721fd01d93..260619e19bde 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -411,7 +411,8 @@ struct lnet_rc_data {
 };
 
 struct lnet_peer_ni {
-	struct list_head	lpni_on_peer_net_list;
+	/* chain on lpn_peer_nis */
+	struct list_head	lpni_peer_nis;
 	/* chain on remote peer list */
 	struct list_head	lpni_on_remote_peer_ni_list;
 	/* chain on peer hash */
@@ -496,8 +497,8 @@ struct lnet_peer_ni {
 #define LNET_PEER_NI_NON_MR_PREF	BIT(0)
 
 struct lnet_peer {
-	/* chain on global peer list */
-	struct list_head	lp_on_lnet_peer_list;
+	/* chain on pt_peer_list */
+	struct list_head	lp_peer_list;
 
 	/* list of peer nets */
 	struct list_head	lp_peer_nets;
@@ -505,6 +506,15 @@ struct lnet_peer {
 	/* primary NID of the peer */
 	lnet_nid_t		lp_primary_nid;
 
+	/* CPT of peer_table */
+	int			lp_cpt;
+
+	/* number of NIDs on this peer */
+	int			lp_nnis;
+
+	/* reference count */
+	atomic_t		lp_refcount;
+
 	/* lock protecting peer state flags */
 	spinlock_t		lp_lock;
 
@@ -516,8 +526,8 @@ struct lnet_peer {
 #define LNET_PEER_CONFIGURED	BIT(1)
 
 struct lnet_peer_net {
-	/* chain on peer block */
-	struct list_head	lpn_on_peer_list;
+	/* chain on lp_peer_nets */
+	struct list_head	lpn_peer_nets;
 
 	/* list of peer_nis on this network */
 	struct list_head	lpn_peer_nis;
@@ -527,21 +537,45 @@ struct lnet_peer_net {
 
 	/* Net ID */
 	__u32			lpn_net_id;
+
+	/* reference count */
+	atomic_t		lpn_refcount;
 };
 
 /* peer hash size */
 #define LNET_PEER_HASH_BITS	9
 #define LNET_PEER_HASH_SIZE	(1 << LNET_PEER_HASH_BITS)
 
-/* peer hash table */
+/*
+ * peer hash table - one per CPT
+ *
+ * protected by lnet_net_lock/EX for update
+ *    pt_version
+ *    pt_number
+ *    pt_hash[...]
+ *    pt_peer_list
+ *    pt_peers
+ *    pt_peer_nnids
+ * protected by pt_zombie_lock:
+ *    pt_zombie_list
+ *    pt_zombies
+ *
+ * pt_zombie lock nests inside lnet_net_lock
+ */
 struct lnet_peer_table {
 	/* /proc validity stamp */
 	int			 pt_version;
 	/* # peers extant */
 	atomic_t		 pt_number;
+	/* peers */
+	struct list_head	pt_peer_list;
+	/* # peers */
+	int			pt_peers;
+	/* # NIDS on listed peers */
+	int			pt_peer_nnids;
 	/* # zombies to go to deathrow (and not there yet) */
 	int			 pt_zombies;
-	/* zombie peers */
+	/* zombie peers_ni */
 	struct list_head	 pt_zombie_list;
 	/* protect list and count */
 	spinlock_t		 pt_zombie_lock;
@@ -785,8 +819,6 @@ struct lnet {
 	struct lnet_msg_container	**ln_msg_containers;
 	struct lnet_counters		**ln_counters;
 	struct lnet_peer_table		**ln_peer_tables;
-	/* list of configured or discovered peers */
-	struct list_head		ln_peers;
 	/* list of peer nis not on a local network */
 	struct list_head		ln_remote_peer_ni_list;
 	/* failure simulation */
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index d64ae2939abc..c48bcb8722a0 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -625,7 +625,6 @@ lnet_prepare(lnet_pid_t requested_pid)
 	the_lnet.ln_pid = requested_pid;
 
 	INIT_LIST_HEAD(&the_lnet.ln_test_peers);
-	INIT_LIST_HEAD(&the_lnet.ln_peers);
 	INIT_LIST_HEAD(&the_lnet.ln_remote_peer_ni_list);
 	INIT_LIST_HEAD(&the_lnet.ln_nets);
 	INIT_LIST_HEAD(&the_lnet.ln_routers);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 99d8b22356bb..4c1eef907dc7 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1388,7 +1388,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 			peer_net = lnet_peer_get_net_locked(
 				peer, LNET_NIDNET(best_lpni->lpni_nid));
 			list_for_each_entry(lpni, &peer_net->lpn_peer_nis,
-					    lpni_on_peer_net_list) {
+					    lpni_peer_nis) {
 				if (lpni->lpni_pref_nnids == 0)
 					continue;
 				LASSERT(lpni->lpni_pref_nnids == 1);
@@ -1411,7 +1411,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 			}
 			lpni = list_entry(peer_net->lpn_peer_nis.next,
 					  struct lnet_peer_ni,
-					  lpni_on_peer_net_list);
+					  lpni_peer_nis);
 		}
 		/* Set preferred NI if necessary. */
 		if (lpni->lpni_pref_nnids == 0)
@@ -1443,7 +1443,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	 * then the best route is chosen. If all routes are equal then
 	 * they are used in round robin.
 	 */
-	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_on_peer_list) {
+	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_peer_nets) {
 		if (!lnet_is_peer_net_healthy_locked(peer_net))
 			continue;
 
@@ -1453,7 +1453,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 
 			lpni = list_entry(peer_net->lpn_peer_nis.next,
 					  struct lnet_peer_ni,
-					  lpni_on_peer_net_list);
+					  lpni_peer_nis);
 
 			net_gw = lnet_find_route_locked(NULL,
 							lpni->lpni_nid,
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 09c1b5516f6b..d7a0a2f3bdd9 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -118,7 +118,7 @@ lnet_peer_ni_alloc(lnet_nid_t nid)
 	INIT_LIST_HEAD(&lpni->lpni_rtrq);
 	INIT_LIST_HEAD(&lpni->lpni_routes);
 	INIT_LIST_HEAD(&lpni->lpni_hashlist);
-	INIT_LIST_HEAD(&lpni->lpni_on_peer_net_list);
+	INIT_LIST_HEAD(&lpni->lpni_peer_nis);
 	INIT_LIST_HEAD(&lpni->lpni_on_remote_peer_ni_list);
 
 	spin_lock_init(&lpni->lpni_lock);
@@ -150,7 +150,7 @@ lnet_peer_ni_alloc(lnet_nid_t nid)
 			      &the_lnet.ln_remote_peer_ni_list);
 	}
 
-	/* TODO: update flags */
+	CDEBUG(D_NET, "%p nid %s\n", lpni, libcfs_nid2str(lpni->lpni_nid));
 
 	return lpni;
 }
@@ -164,13 +164,32 @@ lnet_peer_net_alloc(u32 net_id)
 	if (!lpn)
 		return NULL;
 
-	INIT_LIST_HEAD(&lpn->lpn_on_peer_list);
+	INIT_LIST_HEAD(&lpn->lpn_peer_nets);
 	INIT_LIST_HEAD(&lpn->lpn_peer_nis);
 	lpn->lpn_net_id = net_id;
 
+	CDEBUG(D_NET, "%p net %s\n", lpn, libcfs_net2str(lpn->lpn_net_id));
+
 	return lpn;
 }
 
+void
+lnet_destroy_peer_net_locked(struct lnet_peer_net *lpn)
+{
+	struct lnet_peer *lp;
+
+	CDEBUG(D_NET, "%p net %s\n", lpn, libcfs_net2str(lpn->lpn_net_id));
+
+	LASSERT(atomic_read(&lpn->lpn_refcount) == 0);
+	LASSERT(list_empty(&lpn->lpn_peer_nis));
+	LASSERT(list_empty(&lpn->lpn_peer_nets));
+	lp = lpn->lpn_peer;
+	lpn->lpn_peer = NULL;
+	kfree(lpn);
+
+	lnet_peer_decref_locked(lp);
+}
+
 static struct lnet_peer *
 lnet_peer_alloc(lnet_nid_t nid)
 {
@@ -180,53 +199,73 @@ lnet_peer_alloc(lnet_nid_t nid)
 	if (!lp)
 		return NULL;
 
-	INIT_LIST_HEAD(&lp->lp_on_lnet_peer_list);
+	INIT_LIST_HEAD(&lp->lp_peer_list);
 	INIT_LIST_HEAD(&lp->lp_peer_nets);
 	spin_lock_init(&lp->lp_lock);
 	lp->lp_primary_nid = nid;
+	lp->lp_cpt = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
 
-	/* TODO: update flags */
+	CDEBUG(D_NET, "%p nid %s\n", lp, libcfs_nid2str(lp->lp_primary_nid));
 
 	return lp;
 }
 
+void
+lnet_destroy_peer_locked(struct lnet_peer *lp)
+{
+	CDEBUG(D_NET, "%p nid %s\n", lp, libcfs_nid2str(lp->lp_primary_nid));
+
+	LASSERT(atomic_read(&lp->lp_refcount) == 0);
+	LASSERT(list_empty(&lp->lp_peer_nets));
+	LASSERT(list_empty(&lp->lp_peer_list));
+
+	kfree(lp);
+}
+
+/*
+ * Detach a peer_ni from its peer_net. If this was the last peer_ni on
+ * that peer_net, detach the peer_net from the peer.
+ *
+ * Call with lnet_net_lock/EX held
+ */
 static void
-lnet_peer_detach_peer_ni(struct lnet_peer_ni *lpni)
+lnet_peer_detach_peer_ni_locked(struct lnet_peer_ni *lpni)
 {
+	struct lnet_peer_table *ptable;
 	struct lnet_peer_net *lpn;
 	struct lnet_peer *lp;
 
-	/* TODO: could the below situation happen? accessing an already
-	 * destroyed peer?
+	/*
+	 * Belts and suspenders: gracefully handle teardown of a
+	 * partially connected peer_ni.
 	 */
-	if (!lpni->lpni_peer_net ||
-	    !lpni->lpni_peer_net->lpn_peer)
-		return;
-
 	lpn = lpni->lpni_peer_net;
-	lp = lpni->lpni_peer_net->lpn_peer;
 
-	CDEBUG(D_NET, "peer %s NID %s\n",
-	       libcfs_nid2str(lp->lp_primary_nid),
-	       libcfs_nid2str(lpni->lpni_nid));
-
-	list_del_init(&lpni->lpni_on_peer_net_list);
-	lpni->lpni_peer_net = NULL;
+	list_del_init(&lpni->lpni_peer_nis);
+	/*
+	 * If there are no lpni's left, we detach lpn from
+	 * lp_peer_nets, so it cannot be found anymore.
+	 */
+	if (list_empty(&lpn->lpn_peer_nis))
+		list_del_init(&lpn->lpn_peer_nets);
 
-	/* if lpn is empty, then remove it from the peer */
-	if (list_empty(&lpn->lpn_peer_nis)) {
-		list_del_init(&lpn->lpn_on_peer_list);
-		lpn->lpn_peer = NULL;
-		kfree(lpn);
+	/* Update peer NID count. */
+	lp = lpn->lpn_peer;
+	ptable = the_lnet.ln_peer_tables[lp->lp_cpt];
+	lp->lp_nnis--;
+	ptable->pt_peer_nnids--;
 
-		/* If the peer is empty then remove it from the
-		 * the_lnet.ln_peers.
-		 */
-		if (list_empty(&lp->lp_peer_nets)) {
-			list_del_init(&lp->lp_on_lnet_peer_list);
-			kfree(lp);
-		}
+	/*
+	 * If there are no more peer nets, make the peer unfindable
+	 * via the peer_tables.
+	 */
+	if (list_empty(&lp->lp_peer_nets)) {
+		list_del_init(&lp->lp_peer_list);
+		ptable->pt_peers--;
 	}
+	CDEBUG(D_NET, "peer %s NID %s\n",
+	       libcfs_nid2str(lp->lp_primary_nid),
+	       libcfs_nid2str(lpni->lpni_nid));
 }
 
 /* called with lnet_net_lock LNET_LOCK_EX held */
@@ -268,9 +307,9 @@ lnet_peer_ni_del_locked(struct lnet_peer_ni *lpni)
 	spin_unlock(&ptable->pt_zombie_lock);
 
 	/* no need to keep this peer_ni on the hierarchy anymore */
-	lnet_peer_detach_peer_ni(lpni);
+	lnet_peer_detach_peer_ni_locked(lpni);
 
-	/* decrement reference on peer_ni */
+	/* remove hashlist reference on peer_ni */
 	lnet_peer_ni_decref_locked(lpni);
 
 	return 0;
@@ -319,6 +358,8 @@ lnet_peer_tables_create(void)
 		spin_lock_init(&ptable->pt_zombie_lock);
 		INIT_LIST_HEAD(&ptable->pt_zombie_list);
 
+		INIT_LIST_HEAD(&ptable->pt_peer_list);
+
 		for (j = 0; j < LNET_PEER_HASH_SIZE; j++)
 			INIT_LIST_HEAD(&hash[j]);
 		ptable->pt_hash = hash; /* sign of initialization */
@@ -394,7 +435,7 @@ lnet_peer_del_nid(struct lnet_peer *lp, lnet_nid_t nid, unsigned int flags)
 	 * This function only allows deletion of the primary NID if it
 	 * is the only NID.
 	 */
-	if (nid == lp->lp_primary_nid && lnet_get_num_peer_nis(lp) != 1) {
+	if (nid == lp->lp_primary_nid && lp->lp_nnis != 1) {
 		rc = -EBUSY;
 		goto out;
 	}
@@ -560,15 +601,34 @@ struct lnet_peer_ni *
 lnet_get_peer_ni_idx_locked(int idx, struct lnet_peer_net **lpn,
 			    struct lnet_peer **lp)
 {
+	struct lnet_peer_table	*ptable;
 	struct lnet_peer_ni	*lpni;
+	int			lncpt;
+	int			cpt;
+
+	lncpt = cfs_percpt_number(the_lnet.ln_peer_tables);
 
-	list_for_each_entry((*lp), &the_lnet.ln_peers, lp_on_lnet_peer_list) {
+	for (cpt = 0; cpt < lncpt; cpt++) {
+		ptable = the_lnet.ln_peer_tables[cpt];
+		if (ptable->pt_peer_nnids > idx)
+			break;
+		idx -= ptable->pt_peer_nnids;
+	}
+	if (cpt >= lncpt)
+		return NULL;
+
+	list_for_each_entry((*lp), &ptable->pt_peer_list, lp_peer_list) {
+		if ((*lp)->lp_nnis <= idx) {
+			idx -= (*lp)->lp_nnis;
+			continue;
+		}
 		list_for_each_entry((*lpn), &((*lp)->lp_peer_nets),
-				    lpn_on_peer_list) {
+				    lpn_peer_nets) {
 			list_for_each_entry(lpni, &((*lpn)->lpn_peer_nis),
-					    lpni_on_peer_net_list)
+					    lpni_peer_nis) {
 				if (idx-- == 0)
 					return lpni;
+			}
 		}
 	}
 
@@ -584,18 +644,21 @@ lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 	struct lnet_peer_net *net = peer_net;
 
 	if (!prev) {
-		if (!net)
+		if (!net) {
+			if (list_empty(&peer->lp_peer_nets))
+				return NULL;
+
 			net = list_entry(peer->lp_peer_nets.next,
 					 struct lnet_peer_net,
-					 lpn_on_peer_list);
+					 lpn_peer_nets);
+		}
 		lpni = list_entry(net->lpn_peer_nis.next, struct lnet_peer_ni,
-				  lpni_on_peer_net_list);
+				  lpni_peer_nis);
 
 		return lpni;
 	}
 
-	if (prev->lpni_on_peer_net_list.next ==
-	    &prev->lpni_peer_net->lpn_peer_nis) {
+	if (prev->lpni_peer_nis.next == &prev->lpni_peer_net->lpn_peer_nis) {
 		/*
 		 * if you reached the end of the peer ni list and the peer
 		 * net is specified then there are no more peer nis in that
@@ -608,25 +671,25 @@ lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 		 * we reached the end of this net ni list. move to the
 		 * next net
 		 */
-		if (prev->lpni_peer_net->lpn_on_peer_list.next ==
+		if (prev->lpni_peer_net->lpn_peer_nets.next ==
 		    &peer->lp_peer_nets)
 			/* no more nets and no more NIs. */
 			return NULL;
 
 		/* get the next net */
-		net = list_entry(prev->lpni_peer_net->lpn_on_peer_list.next,
+		net = list_entry(prev->lpni_peer_net->lpn_peer_nets.next,
 				 struct lnet_peer_net,
-				 lpn_on_peer_list);
+				 lpn_peer_nets);
 		/* get the ni on it */
 		lpni = list_entry(net->lpn_peer_nis.next, struct lnet_peer_ni,
-				  lpni_on_peer_net_list);
+				  lpni_peer_nis);
 
 		return lpni;
 	}
 
 	/* there are more nis left */
-	lpni = list_entry(prev->lpni_on_peer_net_list.next,
-			  struct lnet_peer_ni, lpni_on_peer_net_list);
+	lpni = list_entry(prev->lpni_peer_nis.next,
+			  struct lnet_peer_ni, lpni_peer_nis);
 
 	return lpni;
 }
@@ -902,7 +965,7 @@ struct lnet_peer_net *
 lnet_peer_get_net_locked(struct lnet_peer *peer, u32 net_id)
 {
 	struct lnet_peer_net *peer_net;
-	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_on_peer_list) {
+	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_peer_nets) {
 		if (peer_net->lpn_net_id == net_id)
 			return peer_net;
 	}
@@ -910,15 +973,20 @@ lnet_peer_get_net_locked(struct lnet_peer *peer, u32 net_id)
 }
 
 /*
- * Always returns 0, but it the last function called from functions
+ * Attach a peer_ni to a peer_net and peer. This function assumes
+ * peer_ni is not already attached to the peer_net/peer. The peer_ni
+ * may be attached to a different peer, in which case it will be
+ * properly detached first. The whole operation is done atomically.
+ *
+ * Always returns 0.  This is the last function called from functions
  * that do return an int, so returning 0 here allows the compiler to
  * do a tail call.
  */
 static int
 lnet_peer_attach_peer_ni(struct lnet_peer *lp,
-			 struct lnet_peer_net *lpn,
-			 struct lnet_peer_ni *lpni,
-			 unsigned int flags)
+				struct lnet_peer_net *lpn,
+				struct lnet_peer_ni *lpni,
+				unsigned int flags)
 {
 	struct lnet_peer_table *ptable;
 
@@ -932,26 +1000,38 @@ lnet_peer_attach_peer_ni(struct lnet_peer *lp,
 		list_add_tail(&lpni->lpni_hashlist, &ptable->pt_hash[hash]);
 		ptable->pt_version++;
 		atomic_inc(&ptable->pt_number);
+		/* This is the 1st refcount on lpni. */
 		atomic_inc(&lpni->lpni_refcount);
 	}
 
 	/* Detach the peer_ni from an existing peer, if necessary. */
-	if (lpni->lpni_peer_net && lpni->lpni_peer_net->lpn_peer != lp)
-		lnet_peer_detach_peer_ni(lpni);
+	if (lpni->lpni_peer_net) {
+		LASSERT(lpni->lpni_peer_net != lpn);
+		LASSERT(lpni->lpni_peer_net->lpn_peer != lp);
+		lnet_peer_detach_peer_ni_locked(lpni);
+		lnet_peer_net_decref_locked(lpni->lpni_peer_net);
+		lpni->lpni_peer_net = NULL;
+	}
 
 	/* Add peer_ni to peer_net */
 	lpni->lpni_peer_net = lpn;
-	list_add_tail(&lpni->lpni_on_peer_net_list, &lpn->lpn_peer_nis);
+	list_add_tail(&lpni->lpni_peer_nis, &lpn->lpn_peer_nis);
+	lnet_peer_net_addref_locked(lpn);
 
 	/* Add peer_net to peer */
 	if (!lpn->lpn_peer) {
 		lpn->lpn_peer = lp;
-		list_add_tail(&lpn->lpn_on_peer_list, &lp->lp_peer_nets);
+		list_add_tail(&lpn->lpn_peer_nets, &lp->lp_peer_nets);
+		lnet_peer_addref_locked(lp);
+	}
+
+	/* Add peer to global peer list, if necessary */
+	ptable = the_lnet.ln_peer_tables[lp->lp_cpt];
+	if (list_empty(&lp->lp_peer_list)) {
+		list_add_tail(&lp->lp_peer_list, &ptable->pt_peer_list);
+		ptable->pt_peers++;
 	}
 
-	/* Add peer to global peer list */
-	if (list_empty(&lp->lp_on_lnet_peer_list))
-		list_add_tail(&lp->lp_on_lnet_peer_list, &the_lnet.ln_peers);
 
 	/* Update peer state */
 	spin_lock(&lp->lp_lock);
@@ -967,6 +1047,8 @@ lnet_peer_attach_peer_ni(struct lnet_peer *lp,
 	}
 	spin_unlock(&lp->lp_lock);
 
+	lp->lp_nnis++;
+	the_lnet.ln_peer_tables[lp->lp_cpt]->pt_peer_nnids++;
 	lnet_net_unlock(LNET_LOCK_EX);
 
 	CDEBUG(D_NET, "peer %s NID %s flags %#x\n",
@@ -1314,12 +1396,17 @@ void
 lnet_destroy_peer_ni_locked(struct lnet_peer_ni *lpni)
 {
 	struct lnet_peer_table *ptable;
+	struct lnet_peer_net *lpn;
+
+	CDEBUG(D_NET, "%p nid %s\n", lpni, libcfs_nid2str(lpni->lpni_nid));
 
 	LASSERT(atomic_read(&lpni->lpni_refcount) == 0);
 	LASSERT(lpni->lpni_rtr_refcount == 0);
 	LASSERT(list_empty(&lpni->lpni_txq));
 	LASSERT(lpni->lpni_txqnob == 0);
 
+	lpn = lpni->lpni_peer_net;
+	lpni->lpni_peer_net = NULL;
 	lpni->lpni_net = NULL;
 
 	/* remove the peer ni from the zombie list */
@@ -1332,6 +1419,8 @@ lnet_destroy_peer_ni_locked(struct lnet_peer_ni *lpni)
 	if (lpni->lpni_pref_nnids > 1)
 		kfree(lpni->lpni_pref.nids);
 	kfree(lpni);
+
+	lnet_peer_net_decref_locked(lpn);
 }
 
 struct lnet_peer_ni *
@@ -1518,6 +1607,7 @@ lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
 	return found ? 0 : -ENOENT;
 }
 
+/* ln_api_mutex is held, which keeps the peer list stable */
 int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
 		       bool *mr,
 		       struct lnet_peer_ni_credit_info __user *peer_ni_info,
