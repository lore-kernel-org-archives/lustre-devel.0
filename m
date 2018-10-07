From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Oct 2018 10:19:38 +1100
Subject: [lustre-devel] [PATCH 13/24] lustre: lnet: add LNET_PEER_CONFIGURED
 flag
In-Reply-To: <153895417139.16383.3791701638653772865.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
Message-ID: <153895437804.16383.1008375422641070080.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf@sgi.com>

Add the LNET_PEER_CONFIGURED flag, which indicates that a peer
has been configured by DLC. This is used to enforce that only
DLC can modify such a peer.

This includes some further refactoring of the code that creates
or modifies peers to ensure that the flag is properly passed
through, set, and cleared.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
Signed-off-by: Olaf Weber <olaf@sgi.com>
Reviewed-on: https://review.whamcloud.com/25783
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Tested-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   12 +
 .../staging/lustre/include/linux/lnet/lib-types.h  |    1 
 drivers/staging/lustre/lnet/lnet/peer.c            |  426 +++++++++++++-------
 3 files changed, 290 insertions(+), 149 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 2864bd8a403b..563417510722 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -764,4 +764,16 @@ lnet_peer_is_multi_rail(struct lnet_peer *lp)
 	return lp->lp_state & LNET_PEER_MULTI_RAIL;
 }
 
+static inline bool
+lnet_peer_ni_is_configured(struct lnet_peer_ni *lpni)
+{
+	return lpni->lpni_peer_net->lpn_peer->lp_state & LNET_PEER_CONFIGURED;
+}
+
+static inline bool
+lnet_peer_ni_is_primary(struct lnet_peer_ni *lpni)
+{
+	return lpni->lpni_nid == lpni->lpni_peer_net->lpn_peer->lp_primary_nid;
+}
+
 #endif
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index eff2aed5e5c1..d1721fd01d93 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -513,6 +513,7 @@ struct lnet_peer {
 };
 
 #define LNET_PEER_MULTI_RAIL	BIT(0)
+#define LNET_PEER_CONFIGURED	BIT(1)
 
 struct lnet_peer_net {
 	/* chain on peer block */
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 44a2bf641260..09c1b5516f6b 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -191,10 +191,10 @@ lnet_peer_alloc(lnet_nid_t nid)
 }
 
 static void
-lnet_try_destroy_peer_hierarchy_locked(struct lnet_peer_ni *lpni)
+lnet_peer_detach_peer_ni(struct lnet_peer_ni *lpni)
 {
-	struct lnet_peer_net *peer_net;
-	struct lnet_peer *peer;
+	struct lnet_peer_net *lpn;
+	struct lnet_peer *lp;
 
 	/* TODO: could the below situation happen? accessing an already
 	 * destroyed peer?
@@ -203,24 +203,28 @@ lnet_try_destroy_peer_hierarchy_locked(struct lnet_peer_ni *lpni)
 	    !lpni->lpni_peer_net->lpn_peer)
 		return;
 
-	peer_net = lpni->lpni_peer_net;
-	peer = lpni->lpni_peer_net->lpn_peer;
+	lpn = lpni->lpni_peer_net;
+	lp = lpni->lpni_peer_net->lpn_peer;
+
+	CDEBUG(D_NET, "peer %s NID %s\n",
+	       libcfs_nid2str(lp->lp_primary_nid),
+	       libcfs_nid2str(lpni->lpni_nid));
 
 	list_del_init(&lpni->lpni_on_peer_net_list);
 	lpni->lpni_peer_net = NULL;
 
-	/* if peer_net is empty, then remove it from the peer */
-	if (list_empty(&peer_net->lpn_peer_nis)) {
-		list_del_init(&peer_net->lpn_on_peer_list);
-		peer_net->lpn_peer = NULL;
-		kfree(peer_net);
+	/* if lpn is empty, then remove it from the peer */
+	if (list_empty(&lpn->lpn_peer_nis)) {
+		list_del_init(&lpn->lpn_on_peer_list);
+		lpn->lpn_peer = NULL;
+		kfree(lpn);
 
 		/* If the peer is empty then remove it from the
 		 * the_lnet.ln_peers.
 		 */
-		if (list_empty(&peer->lp_peer_nets)) {
-			list_del_init(&peer->lp_on_lnet_peer_list);
-			kfree(peer);
+		if (list_empty(&lp->lp_peer_nets)) {
+			list_del_init(&lp->lp_on_lnet_peer_list);
+			kfree(lp);
 		}
 	}
 }
@@ -263,10 +267,10 @@ lnet_peer_ni_del_locked(struct lnet_peer_ni *lpni)
 	ptable->pt_zombies++;
 	spin_unlock(&ptable->pt_zombie_lock);
 
-	/* no need to keep this peer on the hierarchy anymore */
-	lnet_try_destroy_peer_hierarchy_locked(lpni);
+	/* no need to keep this peer_ni on the hierarchy anymore */
+	lnet_peer_detach_peer_ni(lpni);
 
-	/* decrement reference on peer */
+	/* decrement reference on peer_ni */
 	lnet_peer_ni_decref_locked(lpni);
 
 	return 0;
@@ -329,6 +333,8 @@ lnet_peer_del_locked(struct lnet_peer *peer)
 	struct lnet_peer_ni *lpni = NULL, *lpni2;
 	int rc = 0, rc2 = 0;
 
+	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(peer->lp_primary_nid));
+
 	lpni = lnet_get_next_peer_ni_locked(peer, NULL, lpni);
 	while (lpni) {
 		lpni2 = lnet_get_next_peer_ni_locked(peer, NULL, lpni);
@@ -352,31 +358,36 @@ lnet_peer_del(struct lnet_peer *peer)
 }
 
 /*
- * Delete a NID from a peer.
- * Implements a few sanity checks.
- * Call with ln_api_mutex held.
+ * Delete a NID from a peer. Call with ln_api_mutex held.
+ *
+ * Error codes:
+ *  -EPERM:  Non-DLC deletion from DLC-configured peer.
+ *  -ENOENT: No lnet_peer_ni corresponding to the nid.
+ *  -ECHILD: The lnet_peer_ni isn't connected to the peer.
+ *  -EBUSY:  The lnet_peer_ni is the primary, and not the only peer_ni.
  */
 static int
-lnet_peer_del_nid(struct lnet_peer *lp, lnet_nid_t nid)
+lnet_peer_del_nid(struct lnet_peer *lp, lnet_nid_t nid, unsigned int flags)
 {
-	struct lnet_peer *lp2;
 	struct lnet_peer_ni *lpni;
+	lnet_nid_t primary_nid = lp->lp_primary_nid;
+	int rc = 0;
 
+	if (!(flags & LNET_PEER_CONFIGURED)) {
+		if (lp->lp_state & LNET_PEER_CONFIGURED) {
+			rc = -EPERM;
+			goto out;
+		}
+	}
 	lpni = lnet_find_peer_ni_locked(nid);
 	if (!lpni) {
-		CERROR("Cannot remove unknown nid %s from peer %s\n",
-		       libcfs_nid2str(nid),
-		       libcfs_nid2str(lp->lp_primary_nid));
-		return -ENOENT;
+		rc = -ENOENT;
+		goto out;
 	}
 	lnet_peer_ni_decref_locked(lpni);
-	lp2 = lpni->lpni_peer_net->lpn_peer;
-	if (lp2 != lp) {
-		CERROR("Nid %s is attached to peer %s, not peer %s\n",
-		       libcfs_nid2str(nid),
-		       libcfs_nid2str(lp2->lp_primary_nid),
-		       libcfs_nid2str(lp->lp_primary_nid));
-		return -EINVAL;
+	if (lp != lpni->lpni_peer_net->lpn_peer) {
+		rc = -ECHILD;
+		goto out;
 	}
 
 	/*
@@ -384,16 +395,19 @@ lnet_peer_del_nid(struct lnet_peer *lp, lnet_nid_t nid)
 	 * is the only NID.
 	 */
 	if (nid == lp->lp_primary_nid && lnet_get_num_peer_nis(lp) != 1) {
-		CERROR("Cannot delete primary NID %s from multi-NID peer\n",
-		       libcfs_nid2str(nid));
-		return -EINVAL;
+		rc = -EBUSY;
+		goto out;
 	}
 
 	lnet_net_lock(LNET_LOCK_EX);
 	lnet_peer_ni_del_locked(lpni);
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	return 0;
+out:
+	CDEBUG(D_NET, "peer %s NID %s flags %#x: %d\n",
+	       libcfs_nid2str(primary_nid), libcfs_nid2str(nid), flags, rc);
+
+	return rc;
 }
 
 static void
@@ -895,46 +909,27 @@ lnet_peer_get_net_locked(struct lnet_peer *peer, u32 net_id)
 	return NULL;
 }
 
+/*
+ * Always returns 0, but it the last function called from functions
+ * that do return an int, so returning 0 here allows the compiler to
+ * do a tail call.
+ */
 static int
-lnet_peer_setup_hierarchy(struct lnet_peer *lp, struct lnet_peer_ni
-	 *lpni,
-			  lnet_nid_t nid)
+lnet_peer_attach_peer_ni(struct lnet_peer *lp,
+			 struct lnet_peer_net *lpn,
+			 struct lnet_peer_ni *lpni,
+			 unsigned int flags)
 {
-	struct lnet_peer_net *lpn = NULL;
 	struct lnet_peer_table *ptable;
-	u32 net_id = LNET_NIDNET(nid);
-
-	/*
-	 * Create the peer_ni, peer_net, and peer if they don't exist
-	 * yet.
-	 */
-	if (lp) {
-		lpn = lnet_peer_get_net_locked(lp, net_id);
-	} else {
-		lp = lnet_peer_alloc(nid);
-		if (!lp)
-			goto out_enomem;
-	}
-
-	if (!lpn) {
-		lpn = lnet_peer_net_alloc(net_id);
-		if (!lpn)
-			goto out_maybe_free_lp;
-	}
-
-	if (!lpni) {
-		lpni = lnet_peer_ni_alloc(nid);
-		if (!lpni)
-			goto out_maybe_free_lpn;
-	}
 
 	/* Install the new peer_ni */
 	lnet_net_lock(LNET_LOCK_EX);
 	/* Add peer_ni to global peer table hash, if necessary. */
 	if (list_empty(&lpni->lpni_hashlist)) {
+		int hash = lnet_nid2peerhash(lpni->lpni_nid);
+
 		ptable = the_lnet.ln_peer_tables[lpni->lpni_cpt];
-		list_add_tail(&lpni->lpni_hashlist,
-			      &ptable->pt_hash[lnet_nid2peerhash(nid)]);
+		list_add_tail(&lpni->lpni_hashlist, &ptable->pt_hash[hash]);
 		ptable->pt_version++;
 		atomic_inc(&ptable->pt_number);
 		atomic_inc(&lpni->lpni_refcount);
@@ -942,7 +937,7 @@ lnet_peer_setup_hierarchy(struct lnet_peer *lp, struct lnet_peer_ni
 
 	/* Detach the peer_ni from an existing peer, if necessary. */
 	if (lpni->lpni_peer_net && lpni->lpni_peer_net->lpn_peer != lp)
-		lnet_try_destroy_peer_hierarchy_locked(lpni);
+		lnet_peer_detach_peer_ni(lpni);
 
 	/* Add peer_ni to peer_net */
 	lpni->lpni_peer_net = lpn;
@@ -957,33 +952,42 @@ lnet_peer_setup_hierarchy(struct lnet_peer *lp, struct lnet_peer_ni
 	/* Add peer to global peer list */
 	if (list_empty(&lp->lp_on_lnet_peer_list))
 		list_add_tail(&lp->lp_on_lnet_peer_list, &the_lnet.ln_peers);
+
+	/* Update peer state */
+	spin_lock(&lp->lp_lock);
+	if (flags & LNET_PEER_CONFIGURED) {
+		if (!(lp->lp_state & LNET_PEER_CONFIGURED))
+			lp->lp_state |= LNET_PEER_CONFIGURED;
+	}
+	if (flags & LNET_PEER_MULTI_RAIL) {
+		if (!(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
+			lp->lp_state |= LNET_PEER_MULTI_RAIL;
+			lnet_peer_clr_non_mr_pref_nids(lp);
+		}
+	}
+	spin_unlock(&lp->lp_lock);
+
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	return 0;
+	CDEBUG(D_NET, "peer %s NID %s flags %#x\n",
+	       libcfs_nid2str(lp->lp_primary_nid),
+	       libcfs_nid2str(lpni->lpni_nid), flags);
 
-out_maybe_free_lpn:
-	if (list_empty(&lpn->lpn_on_peer_list))
-		kfree(lpn);
-out_maybe_free_lp:
-	if (list_empty(&lp->lp_on_lnet_peer_list))
-		kfree(lp);
-out_enomem:
-	return -ENOMEM;
+	return 0;
 }
 
 /*
  * Create a new peer, with nid as its primary nid.
  *
- * It is not an error if the peer already exists, provided that the
- * given nid is the primary NID.
- *
  * Call with the lnet_api_mutex held.
  */
 static int
-lnet_peer_add(lnet_nid_t nid, bool mr)
+lnet_peer_add(lnet_nid_t nid, unsigned int flags)
 {
 	struct lnet_peer *lp;
+	struct lnet_peer_net *lpn;
 	struct lnet_peer_ni *lpni;
+	int rc = 0;
 
 	LASSERT(nid != LNET_NID_ANY);
 
@@ -992,82 +996,153 @@ lnet_peer_add(lnet_nid_t nid, bool mr)
 	 * lnet_api_mutex is held.
 	 */
 	lpni = lnet_find_peer_ni_locked(nid);
-	if (!lpni) {
-		int rc = lnet_peer_setup_hierarchy(NULL, NULL, nid);
-		if (rc != 0)
-			return rc;
-		lpni = lnet_find_peer_ni_locked(nid);
-		LASSERT(lpni);
+	if (lpni) {
+		/* A peer with this NID already exists. */
+		lp = lpni->lpni_peer_net->lpn_peer;
+		lnet_peer_ni_decref_locked(lpni);
+		/*
+		 * This is an error if the peer was configured and the
+		 * primary NID differs or an attempt is made to change
+		 * the Multi-Rail flag. Otherwise the assumption is
+		 * that an existing peer is being modified.
+		 */
+		if (lp->lp_state & LNET_PEER_CONFIGURED) {
+			if (lp->lp_primary_nid != nid)
+				rc = -EEXIST;
+			else if ((lp->lp_state ^ flags) & LNET_PEER_MULTI_RAIL)
+				rc = -EPERM;
+			goto out;
+		}
+		/* Delete and recreate as a configured peer. */
+		lnet_peer_del(lp);
 	}
-	lp = lpni->lpni_peer_net->lpn_peer;
-	lnet_peer_ni_decref_locked(lpni);
 
-	/* A found peer must have this primary NID */
-	if (lp->lp_primary_nid != nid)
-		return -EEXIST;
+	/* Create peer, peer_net, and peer_ni. */
+	rc = -ENOMEM;
+	lp = lnet_peer_alloc(nid);
+	if (!lp)
+		goto out;
+	lpn = lnet_peer_net_alloc(LNET_NIDNET(nid));
+	if (!lpn)
+		goto out_free_lp;
+	lpni = lnet_peer_ni_alloc(nid);
+	if (!lpni)
+		goto out_free_lpn;
 
-	/*
-	 * If we found an lpni that is not a multi-rail, which could occur
-	 * if lpni is already created as a non-mr lpni or we just created
-	 * it, then make sure you indicate that this lpni is a primary mr
-	 * capable peer.
-	 *
-	 * TODO: update flags if necessary
-	 */
-	spin_lock(&lp->lp_lock);
-	if (mr && !(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
-		lp->lp_state |= LNET_PEER_MULTI_RAIL;
-		lnet_peer_clr_non_mr_pref_nids(lp);
-	} else if (!mr && (lp->lp_state & LNET_PEER_MULTI_RAIL)) {
-		/* The mr state is sticky. */
-		CDEBUG(D_NET, "Cannot clear multi-rail flag from peer %s\n",
-		       libcfs_nid2str(nid));
-	}
-	spin_unlock(&lp->lp_lock);
+	return lnet_peer_attach_peer_ni(lp, lpn, lpni, flags);
 
-	return 0;
+out_free_lpn:
+	kfree(lpn);
+out_free_lp:
+	kfree(lp);
+out:
+	CDEBUG(D_NET, "peer %s NID flags %#x: %d\n",
+	       libcfs_nid2str(nid), flags, rc);
+	return rc;
 }
 
+/*
+ * Add a NID to a peer. Call with ln_api_mutex held.
+ *
+ * Error codes:
+ *  -EPERM:    Non-DLC addition to a DLC-configured peer.
+ *  -EEXIST:   The NID was configured by DLC for a different peer.
+ *  -ENOMEM:   Out of memory.
+ *  -ENOTUNIQ: Adding a second peer NID on a single network on a
+ *             non-multi-rail peer.
+ */
 static int
-lnet_peer_add_nid(struct lnet_peer *lp, lnet_nid_t nid, bool mr)
+lnet_peer_add_nid(struct lnet_peer *lp, lnet_nid_t nid, unsigned int flags)
 {
+	struct lnet_peer_net *lpn;
 	struct lnet_peer_ni *lpni;
+	int rc = 0;
 
 	LASSERT(lp);
 	LASSERT(nid != LNET_NID_ANY);
 
-	spin_lock(&lp->lp_lock);
-	if (!mr && !(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
-		spin_unlock(&lp->lp_lock);
-		CERROR("Cannot add nid %s to non-multi-rail peer %s\n",
-		       libcfs_nid2str(nid),
-		       libcfs_nid2str(lp->lp_primary_nid));
-		return -EPERM;
+	/* A configured peer can only be updated through configuration. */
+	if (!(flags & LNET_PEER_CONFIGURED)) {
+		if (lp->lp_state & LNET_PEER_CONFIGURED) {
+			rc = -EPERM;
+			goto out;
+		}
 	}
 
-	if (!(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
-		lp->lp_state |= LNET_PEER_MULTI_RAIL;
-		lnet_peer_clr_non_mr_pref_nids(lp);
+	/*
+	 * The MULTI_RAIL flag can be set but not cleared, because
+	 * that would leave the peer struct in an invalid state.
+	 */
+	if (flags & LNET_PEER_MULTI_RAIL) {
+		spin_lock(&lp->lp_lock);
+		if (!(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
+			lp->lp_state |= LNET_PEER_MULTI_RAIL;
+			lnet_peer_clr_non_mr_pref_nids(lp);
+		}
+		spin_unlock(&lp->lp_lock);
+	} else if (lp->lp_state & LNET_PEER_MULTI_RAIL) {
+		rc = -EPERM;
+		goto out;
 	}
-	spin_unlock(&lp->lp_lock);
 
 	lpni = lnet_find_peer_ni_locked(nid);
-	if (!lpni)
-		return lnet_peer_setup_hierarchy(lp, NULL, nid);
+	if (lpni) {
+		/*
+		 * A peer_ni already exists. This is only a problem if
+		 * it is not connected to this peer and was configured
+		 * by DLC.
+		 */
+		lnet_peer_ni_decref_locked(lpni);
+		if (lpni->lpni_peer_net->lpn_peer == lp)
+			goto out;
+		if (lnet_peer_ni_is_configured(lpni)) {
+			rc = -EEXIST;
+			goto out;
+		}
+		/* If this is the primary NID, destroy the peer. */
+		if (lnet_peer_ni_is_primary(lpni)) {
+			lnet_peer_del(lpni->lpni_peer_net->lpn_peer);
+			lpni = lnet_peer_ni_alloc(nid);
+			if (!lpni) {
+				rc = -ENOMEM;
+				goto out;
+			}
+		}
+	} else {
+		lpni = lnet_peer_ni_alloc(nid);
+		if (!lpni) {
+			rc = -ENOMEM;
+			goto out;
+		}
+	}
 
-	if (lpni->lpni_peer_net->lpn_peer != lp) {
-		struct lnet_peer *lp2 = lpni->lpni_peer_net->lpn_peer;
-		CERROR("Cannot add NID %s owned by peer %s to peer %s\n",
-		       libcfs_nid2str(lpni->lpni_nid),
-		       libcfs_nid2str(lp2->lp_primary_nid),
-		       libcfs_nid2str(lp->lp_primary_nid));
-		return -EEXIST;
+	/*
+	 * Get the peer_net. Check that we're not adding a second
+	 * peer_ni on a peer_net of a non-multi-rail peer.
+	 */
+	lpn = lnet_peer_get_net_locked(lp, LNET_NIDNET(nid));
+	if (!lpn) {
+		lpn = lnet_peer_net_alloc(LNET_NIDNET(nid));
+		if (!lpn) {
+			rc = -ENOMEM;
+			goto out_free_lpni;
+		}
+	} else if (!(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
+		rc = -ENOTUNIQ;
+		goto out_free_lpni;
 	}
 
-	CDEBUG(D_NET, "NID %s is already owned by peer %s\n",
-	       libcfs_nid2str(lpni->lpni_nid),
-	       libcfs_nid2str(lp->lp_primary_nid));
-	return 0;
+	return lnet_peer_attach_peer_ni(lp, lpn, lpni, flags);
+
+out_free_lpni:
+	/* If the peer_ni was allocated above its peer_net pointer is NULL */
+	if (!lpni->lpni_peer_net)
+		kfree(lpni);
+out:
+	CDEBUG(D_NET, "peer %s NID %s flags %#x: %d\n",
+	       libcfs_nid2str(lp->lp_primary_nid), libcfs_nid2str(nid),
+	       flags, rc);
+	return rc;
 }
 
 /*
@@ -1076,25 +1151,53 @@ lnet_peer_add_nid(struct lnet_peer *lp, lnet_nid_t nid, bool mr)
 static int
 lnet_peer_ni_traffic_add(lnet_nid_t nid, lnet_nid_t pref)
 {
+	struct lnet_peer *lp;
+	struct lnet_peer_net *lpn;
 	struct lnet_peer_ni *lpni;
-	int rc;
+	unsigned int flags = 0;
+	int rc = 0;
 
-	if (nid == LNET_NID_ANY)
-		return -EINVAL;
+	if (nid == LNET_NID_ANY) {
+		rc = -EINVAL;
+		goto out;
+	}
 
 	/* lnet_net_lock is not needed here because ln_api_lock is held */
 	lpni = lnet_find_peer_ni_locked(nid);
-	if (!lpni) {
-		rc = lnet_peer_setup_hierarchy(NULL, NULL, nid);
-		if (rc)
-			return rc;
-		lpni = lnet_find_peer_ni_locked(nid);
+	if (lpni) {
+		/*
+		 * We must have raced with another thread. Since we
+		 * know next to nothing about a peer_ni created by
+		 * traffic, we just assume everything is ok and
+		 * return.
+		 */
+		lnet_peer_ni_decref_locked(lpni);
+		goto out;
 	}
+
+	/* Create peer, peer_net, and peer_ni. */
+	rc = -ENOMEM;
+	lp = lnet_peer_alloc(nid);
+	if (!lp)
+		goto out;
+	lpn = lnet_peer_net_alloc(LNET_NIDNET(nid));
+	if (!lpn)
+		goto out_free_lp;
+	lpni = lnet_peer_ni_alloc(nid);
+	if (!lpni)
+		goto out_free_lpn;
 	if (pref != LNET_NID_ANY)
 		lnet_peer_ni_set_non_mr_pref_nid(lpni, pref);
-	lnet_peer_ni_decref_locked(lpni);
 
-	return 0;
+	return lnet_peer_attach_peer_ni(lp, lpn, lpni, flags);
+
+out_free_lpn:
+	kfree(lpn);
+out_free_lp:
+	kfree(lp);
+out:
+	CDEBUG(D_NET, "peer %s: %d\n", libcfs_nid2str(nid), rc);
+	return rc;
 }
 
 /*
@@ -1114,17 +1217,22 @@ lnet_add_peer_ni(lnet_nid_t prim_nid, lnet_nid_t nid, bool mr)
 {
 	struct lnet_peer *lp = NULL;
 	struct lnet_peer_ni *lpni;
+	unsigned int flags;
 
 	/* The prim_nid must always be specified */
 	if (prim_nid == LNET_NID_ANY)
 		return -EINVAL;
 
+	flags = LNET_PEER_CONFIGURED;
+	if (mr)
+		flags |= LNET_PEER_MULTI_RAIL;
+
 	/*
 	 * If nid isn't specified, we must create a new peer with
 	 * prim_nid as its primary nid.
 	 */
 	if (nid == LNET_NID_ANY)
-		return lnet_peer_add(prim_nid, mr);
+		return lnet_peer_add(prim_nid, flags);
 
 	/* Look up the prim_nid, which must exist. */
 	lpni = lnet_find_peer_ni_locked(prim_nid);
@@ -1133,6 +1241,14 @@ lnet_add_peer_ni(lnet_nid_t prim_nid, lnet_nid_t nid, bool mr)
 	lnet_peer_ni_decref_locked(lpni);
 	lp = lpni->lpni_peer_net->lpn_peer;
 
+	/* Peer must have been configured. */
+	if (!(lp->lp_state & LNET_PEER_CONFIGURED)) {
+		CDEBUG(D_NET, "peer %s was not configured\n",
+		       libcfs_nid2str(prim_nid));
+		return -ENOENT;
+	}
+
+	/* Primary NID must match */
 	if (lp->lp_primary_nid != prim_nid) {
 		CDEBUG(D_NET, "prim_nid %s is not primary for peer %s\n",
 		       libcfs_nid2str(prim_nid),
@@ -1140,7 +1256,14 @@ lnet_add_peer_ni(lnet_nid_t prim_nid, lnet_nid_t nid, bool mr)
 		return -ENODEV;
 	}
 
-	return lnet_peer_add_nid(lp, nid, mr);
+	/* Multi-Rail flag must match. */
+	if ((lp->lp_state ^ flags) & LNET_PEER_MULTI_RAIL) {
+		CDEBUG(D_NET, "multi-rail state mismatch for peer %s\n",
+		       libcfs_nid2str(prim_nid));
+		return -EPERM;
+	}
+
+	return lnet_peer_add_nid(lp, nid, flags);
 }
 
 /*
@@ -1159,6 +1282,7 @@ lnet_del_peer_ni(lnet_nid_t prim_nid, lnet_nid_t nid)
 {
 	struct lnet_peer *lp;
 	struct lnet_peer_ni *lpni;
+	unsigned int flags;
 
 	if (prim_nid == LNET_NID_ANY)
 		return -EINVAL;
@@ -1179,7 +1303,11 @@ lnet_del_peer_ni(lnet_nid_t prim_nid, lnet_nid_t nid)
 	if (nid == LNET_NID_ANY || nid == lp->lp_primary_nid)
 		return lnet_peer_del(lp);
 
-	return lnet_peer_del_nid(lp, nid);
+	flags = LNET_PEER_CONFIGURED;
+	if (lp->lp_state & LNET_PEER_MULTI_RAIL)
+		flags |= LNET_PEER_MULTI_RAIL;
+
+	return lnet_peer_del_nid(lp, nid, flags);
 }
 
 void
