From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Oct 2018 10:19:38 +1100
Subject: [lustre-devel] [PATCH 12/24] lustre: lnet: preferred NIs for
 non-Multi-Rail peers
In-Reply-To: <153895417139.16383.3791701638653772865.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
Message-ID: <153895437800.16383.15417431282816541221.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf@sgi.com>

When a node sends a message to a peer NI, there may be
a preferred local NI that should be the source of the
message. This is in particular the case for non-Multi-
Rail (NMR) peers, as an NMR peer depends in some cases
on the source address of a message to correctly identify
its origin. (This as opposed to using a UUID provided by
a higher protocol layer.)

Implement this by keeping an array of preferred local
NIDs in the lnet_peer_ni structure. The case where only
a single NID needs to be stored is optimized so that this
can be done without needing to allocate any memory.

A flag in the lnet_peer_ni, LNET_PEER_NI_NON_MR_PREF,
indicates that the preferred NI was automatically added
for an NMR peer. Note that a peer which has not been
explicitly configured as Multi-Rail will be treated as
non-Multi-Rail until proven otherwise. These automatic
preferences will be cleared if the peer is changed to
Multi-Rail.

- lnet_peer_ni_set_non_mr_pref_nid()
  set NMR preferred NI for peer_ni
- lnet_peer_ni_clr_non_mr_pref_nid()
  clear NMR preferred NI for peer_ni
- lnet_peer_clr_non_mr_pref_nids()
  clear NMR preferred NIs for all peer_ni

- lnet_peer_add_pref_nid()
  add a preferred NID
- lnet_peer_del_pref_nid()
  delete a preferred NID

WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
Signed-off-by: Olaf Weber <olaf@sgi.com>
Reviewed-on: https://review.whamcloud.com/25782
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Tested-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    7 -
 .../staging/lustre/include/linux/lnet/lib-types.h  |   10 +
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   49 +++-
 drivers/staging/lustre/lnet/lnet/peer.c            |  257 +++++++++++++++++++-
 4 files changed, 285 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 75b47628c70e..2864bd8a403b 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -668,7 +668,8 @@ u32 lnet_get_dlc_seq_locked(void);
 struct lnet_peer_ni *lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 						  struct lnet_peer_net *peer_net,
 						  struct lnet_peer_ni *prev);
-struct lnet_peer_ni *lnet_nid2peerni_locked(lnet_nid_t nid, int cpt);
+struct lnet_peer_ni *lnet_nid2peerni_locked(lnet_nid_t nid, lnet_nid_t pref,
+					    int cpt);
 struct lnet_peer_ni *lnet_nid2peerni_ex(lnet_nid_t nid, int cpt);
 struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
 void lnet_peer_net_added(struct lnet_net *net);
@@ -679,8 +680,8 @@ int lnet_peer_tables_create(void);
 void lnet_debug_peer(lnet_nid_t nid);
 struct lnet_peer_net *lnet_peer_get_net_locked(struct lnet_peer *peer,
 					       u32 net_id);
-bool lnet_peer_is_ni_pref_locked(struct lnet_peer_ni *lpni,
-				 struct lnet_ni *ni);
+bool lnet_peer_is_pref_nid_locked(struct lnet_peer_ni *lpni, lnet_nid_t nid);
+int lnet_peer_ni_set_non_mr_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid);
 int lnet_add_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid, bool mr);
 int lnet_del_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid);
 int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 602978a1c86e..eff2aed5e5c1 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -481,14 +481,20 @@ struct lnet_peer_ni {
 	unsigned int		 lpni_ping_feats;
 	/* routers on this peer */
 	struct list_head	 lpni_routes;
-	/* array of preferred local nids */
-	lnet_nid_t		*lpni_pref_nids;
+	/* preferred local nids: if only one, use lpni_pref.nid */
+	union lpni_pref {
+		lnet_nid_t	nid;
+		lnet_nid_t	*nids;
+	} lpni_pref;
 	/* number of preferred NIDs in lnpi_pref_nids */
 	u32			lpni_pref_nnids;
 	/* router checker state */
 	struct lnet_rc_data	*lpni_rcd;
 };
 
+/* Preferred path added due to traffic on non-MR peer_ni */
+#define LNET_PEER_NI_NON_MR_PREF	BIT(0)
+
 struct lnet_peer {
 	/* chain on global peer list */
 	struct list_head	lp_on_lnet_peer_list;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 0d0ad30bb164..99d8b22356bb 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1267,7 +1267,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	 * existing peer_ni, or create one and mark it as having been
 	 * created due to network traffic.
 	 */
-	lpni = lnet_nid2peerni_locked(dst_nid, cpt);
+	lpni = lnet_nid2peerni_locked(dst_nid, LNET_NID_ANY, cpt);
 	if (IS_ERR(lpni)) {
 		lnet_net_unlock(cpt);
 		return PTR_ERR(lpni);
@@ -1281,14 +1281,6 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		return -EHOSTUNREACH;
 	}
 
-	if (!lnet_peer_is_multi_rail(peer) &&
-	    lnet_get_num_peer_nis(peer) > 1) {
-		lnet_net_unlock(cpt);
-		CERROR("peer %s is declared to be non MR capable, yet configured with more than one NID\n",
-		       libcfs_nid2str(dst_nid));
-		return -EINVAL;
-	}
-
 	/*
 	 * STEP 1: first jab at determining best_ni
 	 * if src_nid is explicitly specified, then best_ni is already
@@ -1373,8 +1365,14 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	}
 
 	/*
-	 * if the peer is not MR capable, then we should always send to it
-	 * using the first NI in the NET we determined.
+	 * We must use a consistent source address when sending to a
+	 * non-MR peer. However, a non-MR peer can have multiple NIDs
+	 * on multiple networks, and we may even need to talk to this
+	 * peer on multiple networks -- certain types of
+	 * load-balancing configuration do this.
+	 *
+	 * So we need to pick the NI the peer prefers for this
+	 * particular network.
 	 */
 	if (!lnet_peer_is_multi_rail(peer)) {
 		if (!best_lpni) {
@@ -1384,10 +1382,26 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 			return -EHOSTUNREACH;
 		}
 
-		/* best ni could be set because src_nid was provided */
+		/* best ni is already set if src_nid was provided */
+		if (!best_ni) {
+			/* Get the target peer_ni */
+			peer_net = lnet_peer_get_net_locked(
+				peer, LNET_NIDNET(best_lpni->lpni_nid));
+			list_for_each_entry(lpni, &peer_net->lpn_peer_nis,
+					    lpni_on_peer_net_list) {
+				if (lpni->lpni_pref_nnids == 0)
+					continue;
+				LASSERT(lpni->lpni_pref_nnids == 1);
+				best_ni = lnet_nid2ni_locked(
+					lpni->lpni_pref.nid, cpt);
+				break;
+			}
+		}
+		/* if best_ni is still not set just pick one */
 		if (!best_ni) {
 			best_ni = lnet_net2ni_locked(
 				best_lpni->lpni_net->net_id, cpt);
+			/* If there is no best_ni we don't have a route */
 			if (!best_ni) {
 				lnet_net_unlock(cpt);
 				CERROR("no path to %s from net %s\n",
@@ -1395,7 +1409,13 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 				       libcfs_net2str(best_lpni->lpni_net->net_id));
 				return -EHOSTUNREACH;
 			}
+			lpni = list_entry(peer_net->lpn_peer_nis.next,
+					  struct lnet_peer_ni,
+					  lpni_on_peer_net_list);
 		}
+		/* Set preferred NI if necessary. */
+		if (lpni->lpni_pref_nnids == 0)
+			lnet_peer_ni_set_non_mr_pref_nid(lpni, best_ni->ni_nid);
 	}
 
 	/*
@@ -1593,7 +1613,8 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		 */
 		if (!lnet_is_peer_ni_healthy_locked(lpni))
 			continue;
-		ni_is_pref = lnet_peer_is_ni_pref_locked(lpni, best_ni);
+		ni_is_pref = lnet_peer_is_pref_nid_locked(lpni,
+							  best_ni->ni_nid);
 
 		/* if this is a preferred peer use it */
 		if (!preferred && ni_is_pref) {
@@ -2380,7 +2401,7 @@ lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
 	}
 
 	lnet_net_lock(cpt);
-	lpni = lnet_nid2peerni_locked(from_nid, cpt);
+	lpni = lnet_nid2peerni_locked(from_nid, ni->ni_nid, cpt);
 	if (IS_ERR(lpni)) {
 		lnet_net_unlock(cpt);
 		CERROR("%s, src %s: Dropping %s (error %ld looking up sender)\n",
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index cc2b926b76e4..44a2bf641260 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -617,18 +617,233 @@ lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 	return lpni;
 }
 
+/*
+ * Test whether a ni is a preferred ni for this peer_ni, e.g, whether
+ * this is a preferred point-to-point path. Call with lnet_net_lock in
+ * shared mmode.
+ */
 bool
-lnet_peer_is_ni_pref_locked(struct lnet_peer_ni *lpni, struct lnet_ni *ni)
+lnet_peer_is_pref_nid_locked(struct lnet_peer_ni *lpni, lnet_nid_t nid)
 {
 	int i;
 
+	if (lpni->lpni_pref_nnids == 0)
+		return false;
+	if (lpni->lpni_pref_nnids == 1)
+		return lpni->lpni_pref.nid == nid;
 	for (i = 0; i < lpni->lpni_pref_nnids; i++) {
-		if (lpni->lpni_pref_nids[i] == ni->ni_nid)
+		if (lpni->lpni_pref.nids[i] == nid)
 			return true;
 	}
 	return false;
 }
 
+/*
+ * Set a single ni as preferred, provided no preferred ni is already
+ * defined. Only to be used for non-multi-rail peer_ni.
+ */
+int
+lnet_peer_ni_set_non_mr_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid)
+{
+	int rc = 0;
+
+	spin_lock(&lpni->lpni_lock);
+	if (nid == LNET_NID_ANY) {
+		rc = -EINVAL;
+	} else if (lpni->lpni_pref_nnids > 0) {
+		rc = -EPERM;
+	} else if (lpni->lpni_pref_nnids == 0) {
+		lpni->lpni_pref.nid = nid;
+		lpni->lpni_pref_nnids = 1;
+		lpni->lpni_state |= LNET_PEER_NI_NON_MR_PREF;
+	}
+	spin_unlock(&lpni->lpni_lock);
+
+	CDEBUG(D_NET, "peer %s nid %s: %d\n",
+	       libcfs_nid2str(lpni->lpni_nid), libcfs_nid2str(nid), rc);
+	return rc;
+}
+
+/*
+ * Clear the preferred NID from a non-multi-rail peer_ni, provided
+ * this preference was set by lnet_peer_ni_set_non_mr_pref_nid().
+ */
+int
+lnet_peer_ni_clr_non_mr_pref_nid(struct lnet_peer_ni *lpni)
+{
+	int rc = 0;
+
+	spin_lock(&lpni->lpni_lock);
+	if (lpni->lpni_state & LNET_PEER_NI_NON_MR_PREF) {
+		lpni->lpni_pref_nnids = 0;
+		lpni->lpni_state &= ~LNET_PEER_NI_NON_MR_PREF;
+	} else if (lpni->lpni_pref_nnids == 0) {
+		rc = -ENOENT;
+	} else {
+		rc = -EPERM;
+	}
+	spin_unlock(&lpni->lpni_lock);
+
+	CDEBUG(D_NET, "peer %s: %d\n",
+	       libcfs_nid2str(lpni->lpni_nid), rc);
+	return rc;
+}
+
+/*
+ * Clear the preferred NIDs from a non-multi-rail peer.
+ */
+void
+lnet_peer_clr_non_mr_pref_nids(struct lnet_peer *lp)
+{
+	struct lnet_peer_ni *lpni = NULL;
+
+	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL)
+		lnet_peer_ni_clr_non_mr_pref_nid(lpni);
+}
+
+int
+lnet_peer_add_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid)
+{
+	lnet_nid_t *nids = NULL;
+	lnet_nid_t *oldnids = NULL;
+	struct lnet_peer *lp = lpni->lpni_peer_net->lpn_peer;
+	int size;
+	int i;
+	int rc = 0;
+
+	if (nid == LNET_NID_ANY) {
+		rc = -EINVAL;
+		goto out;
+	}
+
+	if (lpni->lpni_pref_nnids == 1 && lpni->lpni_pref.nid == nid) {
+		rc = -EEXIST;
+		goto out;
+	}
+
+	/* A non-MR node may have only one preferred NI per peer_ni */
+	if (lpni->lpni_pref_nnids > 0) {
+		if (!(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
+			rc = -EPERM;
+			goto out;
+		}
+	}
+
+	if (lpni->lpni_pref_nnids != 0) {
+		size = sizeof(*nids) * (lpni->lpni_pref_nnids + 1);
+		nids = kzalloc_cpt(size, GFP_KERNEL, lpni->lpni_cpt);
+		if (!nids) {
+			rc = -ENOMEM;
+			goto out;
+		}
+		for (i = 0; i < lpni->lpni_pref_nnids; i++) {
+			if (lpni->lpni_pref.nids[i] == nid) {
+				kfree(nids);
+				rc = -EEXIST;
+				goto out;
+			}
+			nids[i] = lpni->lpni_pref.nids[i];
+		}
+		nids[i] = nid;
+	}
+
+	lnet_net_lock(LNET_LOCK_EX);
+	spin_lock(&lpni->lpni_lock);
+	if (lpni->lpni_pref_nnids == 0) {
+		lpni->lpni_pref.nid = nid;
+	} else {
+		oldnids = lpni->lpni_pref.nids;
+		lpni->lpni_pref.nids = nids;
+	}
+	lpni->lpni_pref_nnids++;
+	lpni->lpni_state &= ~LNET_PEER_NI_NON_MR_PREF;
+	spin_unlock(&lpni->lpni_lock);
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	kfree(oldnids);
+out:
+	if (rc == -EEXIST && (lpni->lpni_state & LNET_PEER_NI_NON_MR_PREF)) {
+		spin_lock(&lpni->lpni_lock);
+		lpni->lpni_state &= ~LNET_PEER_NI_NON_MR_PREF;
+		spin_unlock(&lpni->lpni_lock);
+	}
+	CDEBUG(D_NET, "peer %s nid %s: %d\n",
+	       libcfs_nid2str(lp->lp_primary_nid), libcfs_nid2str(nid), rc);
+	return rc;
+}
+
+int
+lnet_peer_del_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid)
+{
+	lnet_nid_t *nids = NULL;
+	lnet_nid_t *oldnids = NULL;
+	struct lnet_peer *lp = lpni->lpni_peer_net->lpn_peer;
+	int size;
+	int i, j;
+	int rc = 0;
+
+	if (lpni->lpni_pref_nnids == 0) {
+		rc = -ENOENT;
+		goto out;
+	}
+
+	if (lpni->lpni_pref_nnids == 1) {
+		if (lpni->lpni_pref.nid != nid) {
+			rc = -ENOENT;
+			goto out;
+		}
+	} else if (lpni->lpni_pref_nnids == 2) {
+		if (lpni->lpni_pref.nids[0] != nid &&
+		    lpni->lpni_pref.nids[1] != nid) {
+			rc = -ENOENT;
+			goto out;
+		}
+	} else {
+		size = sizeof(*nids) * (lpni->lpni_pref_nnids - 1);
+		nids = kzalloc_cpt(size, GFP_KERNEL, lpni->lpni_cpt);
+		if (!nids) {
+			rc = -ENOMEM;
+			goto out;
+		}
+		for (i = 0, j = 0; i < lpni->lpni_pref_nnids; i++) {
+			if (lpni->lpni_pref.nids[i] != nid)
+				continue;
+			nids[j++] = lpni->lpni_pref.nids[i];
+		}
+		/* Check if we actually removed a nid. */
+		if (j == lpni->lpni_pref_nnids) {
+			kfree(nids);
+			rc = -ENOENT;
+			goto out;
+		}
+	}
+
+	lnet_net_lock(LNET_LOCK_EX);
+	spin_lock(&lpni->lpni_lock);
+	if (lpni->lpni_pref_nnids == 1) {
+		lpni->lpni_pref.nid = LNET_NID_ANY;
+	} else if (lpni->lpni_pref_nnids == 2) {
+		oldnids = lpni->lpni_pref.nids;
+		if (oldnids[0] == nid)
+			lpni->lpni_pref.nid = oldnids[1];
+		else
+			lpni->lpni_pref.nid = oldnids[2];
+	} else {
+		oldnids = lpni->lpni_pref.nids;
+		lpni->lpni_pref.nids = nids;
+	}
+	lpni->lpni_pref_nnids--;
+	lpni->lpni_state &= ~LNET_PEER_NI_NON_MR_PREF;
+	spin_unlock(&lpni->lpni_lock);
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	kfree(oldnids);
+out:
+	CDEBUG(D_NET, "peer %s nid %s: %d\n",
+	       libcfs_nid2str(lp->lp_primary_nid), libcfs_nid2str(nid), rc);
+	return rc;
+}
+
 lnet_nid_t
 lnet_peer_primary_nid_locked(lnet_nid_t nid)
 {
@@ -653,7 +868,7 @@ LNetPrimaryNID(lnet_nid_t nid)
 	int cpt;
 
 	cpt = lnet_net_lock_current();
-	lpni = lnet_nid2peerni_locked(nid, cpt);
+	lpni = lnet_nid2peerni_locked(nid, LNET_NID_ANY, cpt);
 	if (IS_ERR(lpni)) {
 		rc = PTR_ERR(lpni);
 		goto out_unlock;
@@ -802,6 +1017,7 @@ lnet_peer_add(lnet_nid_t nid, bool mr)
 	spin_lock(&lp->lp_lock);
 	if (mr && !(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
 		lp->lp_state |= LNET_PEER_MULTI_RAIL;
+		lnet_peer_clr_non_mr_pref_nids(lp);
 	} else if (!mr && (lp->lp_state & LNET_PEER_MULTI_RAIL)) {
 		/* The mr state is sticky. */
 		CDEBUG(D_NET, "Cannot clear multi-rail flag from peer %s\n",
@@ -829,8 +1045,10 @@ lnet_peer_add_nid(struct lnet_peer *lp, lnet_nid_t nid, bool mr)
 		return -EPERM;
 	}
 
-	if (!(lp->lp_state & LNET_PEER_MULTI_RAIL))
+	if (!(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
 		lp->lp_state |= LNET_PEER_MULTI_RAIL;
+		lnet_peer_clr_non_mr_pref_nids(lp);
+	}
 	spin_unlock(&lp->lp_lock);
 
 	lpni = lnet_find_peer_ni_locked(nid);
@@ -856,28 +1074,27 @@ lnet_peer_add_nid(struct lnet_peer *lp, lnet_nid_t nid, bool mr)
  * lpni creation initiated due to traffic either sending or receiving.
  */
 static int
-lnet_peer_ni_traffic_add(lnet_nid_t nid)
+lnet_peer_ni_traffic_add(lnet_nid_t nid, lnet_nid_t pref)
 {
 	struct lnet_peer_ni *lpni;
-	int rc = 0;
+	int rc;
 
 	if (nid == LNET_NID_ANY)
 		return -EINVAL;
 
 	/* lnet_net_lock is not needed here because ln_api_lock is held */
 	lpni = lnet_find_peer_ni_locked(nid);
-	if (lpni) {
-		/*
-		 * TODO: lnet_update_primary_nid() but not all of it
-		 * only indicate if we're converting this to MR capable
-		 * Can happen due to DD
-		 */
-		lnet_peer_ni_decref_locked(lpni);
-	} else {
+	if (!lpni) {
 		rc = lnet_peer_setup_hierarchy(NULL, NULL, nid);
+		if (rc)
+			return rc;
+		lpni = lnet_find_peer_ni_locked(nid);
 	}
+	if (pref != LNET_NID_ANY)
+		lnet_peer_ni_set_non_mr_pref_nid(lpni, pref);
+	lnet_peer_ni_decref_locked(lpni);
 
-	return rc;
+	return 0;
 }
 
 /*
@@ -984,6 +1201,8 @@ lnet_destroy_peer_ni_locked(struct lnet_peer_ni *lpni)
 	ptable->pt_zombies--;
 	spin_unlock(&ptable->pt_zombie_lock);
 
+	if (lpni->lpni_pref_nnids > 1)
+		kfree(lpni->lpni_pref.nids);
 	kfree(lpni);
 }
 
@@ -1006,7 +1225,7 @@ lnet_nid2peerni_ex(lnet_nid_t nid, int cpt)
 
 	lnet_net_unlock(cpt);
 
-	rc = lnet_peer_ni_traffic_add(nid);
+	rc = lnet_peer_ni_traffic_add(nid, LNET_NID_ANY);
 	if (rc) {
 		lpni = ERR_PTR(rc);
 		goto out_net_relock;
@@ -1022,7 +1241,7 @@ lnet_nid2peerni_ex(lnet_nid_t nid, int cpt)
 }
 
 struct lnet_peer_ni *
-lnet_nid2peerni_locked(lnet_nid_t nid, int cpt)
+lnet_nid2peerni_locked(lnet_nid_t nid, lnet_nid_t pref, int cpt)
 {
 	struct lnet_peer_ni *lpni = NULL;
 	int rc;
@@ -1061,7 +1280,7 @@ lnet_nid2peerni_locked(lnet_nid_t nid, int cpt)
 		goto out_mutex_unlock;
 	}
 
-	rc = lnet_peer_ni_traffic_add(nid);
+	rc = lnet_peer_ni_traffic_add(nid, pref);
 	if (rc) {
 		lpni = ERR_PTR(rc);
 		goto out_mutex_unlock;
@@ -1087,7 +1306,7 @@ lnet_debug_peer(lnet_nid_t nid)
 	cpt = lnet_cpt_of_nid(nid, NULL);
 	lnet_net_lock(cpt);
 
-	lp = lnet_nid2peerni_locked(nid, cpt);
+	lp = lnet_nid2peerni_locked(nid, LNET_NID_ANY, cpt);
 	if (IS_ERR(lp)) {
 		lnet_net_unlock(cpt);
 		CDEBUG(D_WARNING, "No peer %s\n", libcfs_nid2str(nid));
