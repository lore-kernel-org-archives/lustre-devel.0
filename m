From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Oct 2018 10:19:37 +1100
Subject: [lustre-devel] [PATCH 10/24] lustre: lnet: refactor
 lnet_add_peer_ni()
In-Reply-To: <153895417139.16383.3791701638653772865.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
Message-ID: <153895437792.16383.4508869255214195437.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf@sgi.com>

Refactor lnet_add_peer_ni() and the functions called by it. In
particular, lnet_peer_add_nid() adds an lnet_peer_ni to an
existing lnet_peer, lnet_peer_add() adds a new lnet_peer.

lnet_find_or_create_peer_locked() is removed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
Signed-off-by: Olaf Weber <olaf@sgi.com>
Reviewed-on: https://review.whamcloud.com/25780
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Tested-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    1 
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   13 +
 drivers/staging/lustre/lnet/lnet/peer.c            |  230 +++++++-------------
 3 files changed, 92 insertions(+), 152 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 69f45a76f1cc..fc748ffa251d 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -668,7 +668,6 @@ u32 lnet_get_dlc_seq_locked(void);
 struct lnet_peer_ni *lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 						  struct lnet_peer_net *peer_net,
 						  struct lnet_peer_ni *prev);
-struct lnet_peer *lnet_find_or_create_peer_locked(lnet_nid_t dst_nid, int cpt);
 struct lnet_peer_ni *lnet_nid2peerni_locked(lnet_nid_t nid, int cpt);
 struct lnet_peer_ni *lnet_nid2peerni_ex(lnet_nid_t nid, int cpt);
 struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index e8c021622f91..59ae8d0649e5 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1262,11 +1262,18 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		return -ESHUTDOWN;
 	}
 
-	peer = lnet_find_or_create_peer_locked(dst_nid, cpt);
-	if (IS_ERR(peer)) {
+	/*
+	 * lnet_nid2peerni_locked() is the path that will find an
+	 * existing peer_ni, or create one and mark it as having been
+	 * created due to network traffic.
+	 */
+	lpni = lnet_nid2peerni_locked(dst_nid, cpt);
+	if (IS_ERR(lpni)) {
 		lnet_net_unlock(cpt);
-		return PTR_ERR(peer);
+		return PTR_ERR(lpni);
 	}
+	peer = lpni->lpni_peer_net->lpn_peer;
+	lnet_peer_ni_decref_locked(lpni);
 
 	/* If peer is not healthy then can not send anything to it */
 	if (!lnet_is_peer_healthy_locked(peer)) {
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 30a2486712e4..6b7ca5c361b8 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -541,25 +541,6 @@ lnet_find_peer_ni_locked(lnet_nid_t nid)
 	return lpni;
 }
 
-struct lnet_peer *
-lnet_find_or_create_peer_locked(lnet_nid_t dst_nid, int cpt)
-{
-	struct lnet_peer_ni *lpni;
-	struct lnet_peer *lp;
-
-	lpni = lnet_find_peer_ni_locked(dst_nid);
-	if (!lpni) {
-		lpni = lnet_nid2peerni_locked(dst_nid, cpt);
-		if (IS_ERR(lpni))
-			return ERR_CAST(lpni);
-	}
-
-	lp = lpni->lpni_peer_net->lpn_peer;
-	lnet_peer_ni_decref_locked(lpni);
-
-	return lp;
-}
-
 struct lnet_peer_ni *
 lnet_get_peer_ni_idx_locked(int idx, struct lnet_peer_net **lpn,
 			    struct lnet_peer **lp)
@@ -774,131 +755,95 @@ lnet_peer_setup_hierarchy(struct lnet_peer *lp, struct lnet_peer_ni
 	return -ENOMEM;
 }
 
+/*
+ * Create a new peer, with nid as its primary nid.
+ *
+ * It is not an error if the peer already exists, provided that the
+ * given nid is the primary NID.
+ *
+ * Call with the lnet_api_mutex held.
+ */
 static int
-lnet_add_prim_lpni(lnet_nid_t nid)
+lnet_peer_add(lnet_nid_t nid, bool mr)
 {
-	int rc;
-	struct lnet_peer *peer;
+	struct lnet_peer *lp;
 	struct lnet_peer_ni *lpni;
 
 	LASSERT(nid != LNET_NID_ANY);
 
 	/*
-	 * lookup the NID and its peer
-	 *  if the peer doesn't exist, create it.
-	 *  if this is a non-MR peer then change its state to MR and exit.
-	 *  if this is an MR peer and it's a primary NI: NO-OP.
-	 *  if this is an MR peer and it's not a primary NI. Operation not
-	 *     allowed.
-	 *
-	 * The adding and deleting of peer nis is being serialized through
-	 * the api_mutex. So we can look up peers with the mutex locked
-	 * safely. Only when we need to change the ptable, do we need to
-	 * exclusively lock the lnet_net_lock()
+	 * No need for the lnet_net_lock here, because the
+	 * lnet_api_mutex is held.
 	 */
 	lpni = lnet_find_peer_ni_locked(nid);
 	if (!lpni) {
-		rc = lnet_peer_setup_hierarchy(NULL, NULL, nid);
+		int rc = lnet_peer_setup_hierarchy(NULL, NULL, nid);
 		if (rc != 0)
 			return rc;
 		lpni = lnet_find_peer_ni_locked(nid);
+		LASSERT(lpni);
 	}
-
-	LASSERT(lpni);
-
+	lp = lpni->lpni_peer_net->lpn_peer;
 	lnet_peer_ni_decref_locked(lpni);
 
-	peer = lpni->lpni_peer_net->lpn_peer;
-
-	/*
-	 * If we found a lpni with the same nid as the NID we're trying to
-	 * create, then we're trying to create an already existing lpni
-	 * that belongs to a different peer
-	 */
-	if (peer->lp_primary_nid != nid)
+	/* A found peer must have this primary NID */
+	if (lp->lp_primary_nid != nid)
 		return -EEXIST;
 
 	/*
-	 * if we found an lpni that is not a multi-rail, which could occur
+	 * If we found an lpni that is not a multi-rail, which could occur
 	 * if lpni is already created as a non-mr lpni or we just created
 	 * it, then make sure you indicate that this lpni is a primary mr
 	 * capable peer.
 	 *
 	 * TODO: update flags if necessary
 	 */
-	if (!peer->lp_multi_rail && peer->lp_primary_nid == nid)
-		peer->lp_multi_rail = true;
+	if (mr && !lp->lp_multi_rail) {
+		lp->lp_multi_rail = true;
+	} else if (!mr && lp->lp_multi_rail) {
+		/* The mr state is sticky. */
+		CDEBUG(D_NET, "Cannot clear multi-flag from peer %s\n",
+		       libcfs_nid2str(nid));
+	}
 
-	return rc;
+	return 0;
 }
 
 static int
-lnet_add_peer_ni_to_prim_lpni(lnet_nid_t prim_nid, lnet_nid_t nid)
+lnet_peer_add_nid(struct lnet_peer *lp, lnet_nid_t nid, bool mr)
 {
-	struct lnet_peer *peer, *primary_peer;
-	struct lnet_peer_ni *lpni = NULL, *klpni = NULL;
-
-	LASSERT(prim_nid != LNET_NID_ANY && nid != LNET_NID_ANY);
+	struct lnet_peer_ni *lpni;
 
-	/*
-	 * key nid must be created by this point. If not then this
-	 * operation is not permitted
-	 */
-	klpni = lnet_find_peer_ni_locked(prim_nid);
-	if (!klpni)
-		return -ENOENT;
+	LASSERT(lp);
+	LASSERT(nid != LNET_NID_ANY);
 
-	lnet_peer_ni_decref_locked(klpni);
+	if (!mr && !lp->lp_multi_rail) {
+		CERROR("Cannot add nid %s to non-multi-rail peer %s\n",
+		       libcfs_nid2str(nid),
+		       libcfs_nid2str(lp->lp_primary_nid));
+		return -EPERM;
+	}
 
-	primary_peer = klpni->lpni_peer_net->lpn_peer;
+	if (!lp->lp_multi_rail)
+		lp->lp_multi_rail = true;
 
 	lpni = lnet_find_peer_ni_locked(nid);
-	if (lpni) {
-		lnet_peer_ni_decref_locked(lpni);
-
-		peer = lpni->lpni_peer_net->lpn_peer;
-		/*
-		 * lpni already exists in the system but it belongs to
-		 * a different peer. We can't re-added it
-		 */
-		if (peer->lp_primary_nid != prim_nid && peer->lp_multi_rail) {
-			CERROR("Cannot add NID %s owned by peer %s to peer %s\n",
-			       libcfs_nid2str(lpni->lpni_nid),
-			       libcfs_nid2str(peer->lp_primary_nid),
-			       libcfs_nid2str(prim_nid));
-			return -EEXIST;
-		} else if (peer->lp_primary_nid == prim_nid) {
-			/*
-			 * found a peer_ni that is already part of the
-			 * peer. This is a no-op operation.
-			 */
-			return 0;
-		}
-
-		/*
-		 * TODO: else if (peer->lp_primary_nid != prim_nid &&
-		 *		  !peer->lp_multi_rail)
-		 * peer is not an MR peer and it will be moved in the next
-		 * step to klpni, so update its flags accordingly.
-		 * lnet_move_peer_ni()
-		 */
-
-		/*
-		 * TODO: call lnet_update_peer() from here to update the
-		 * flags. This is the case when the lpni you're trying to
-		 * add is already part of the peer. This could've been
-		 * added by the DD previously, so go ahead and do any
-		 * updates to the state if necessary
-		 */
+	if (!lpni)
+		return lnet_peer_setup_hierarchy(lp, NULL, nid);
 
+	if (lpni->lpni_peer_net->lpn_peer != lp) {
+		struct lnet_peer *lp2 = lpni->lpni_peer_net->lpn_peer;
+		CERROR("Cannot add NID %s owned by peer %s to peer %s\n",
+		       libcfs_nid2str(lpni->lpni_nid),
+		       libcfs_nid2str(lp2->lp_primary_nid),
+		       libcfs_nid2str(lp->lp_primary_nid));
+		return -EEXIST;
 	}
 
-	/*
-	 * When we get here we either have found an existing lpni, which
-	 * we can switch to the new peer. Or we need to create one and
-	 * add it to the new peer
-	 */
-	return lnet_peer_setup_hierarchy(primary_peer, lpni, nid);
+	CDEBUG(D_NET, "NID %s is already owned by peer %s\n",
+	       libcfs_nid2str(lpni->lpni_nid),
+	       libcfs_nid2str(lp->lp_primary_nid));
+	return 0;
 }
 
 /*
@@ -929,61 +874,50 @@ lnet_peer_ni_traffic_add(lnet_nid_t nid)
 	return rc;
 }
 
-static int
-lnet_peer_ni_add_non_mr(lnet_nid_t nid)
-{
-	struct lnet_peer_ni *lpni;
-
-	lpni = lnet_find_peer_ni_locked(nid);
-	if (lpni) {
-		CERROR("Cannot add %s as non-mr when it already exists\n",
-		       libcfs_nid2str(nid));
-		lnet_peer_ni_decref_locked(lpni);
-		return -EEXIST;
-	}
-
-	return lnet_peer_setup_hierarchy(NULL, NULL, nid);
-}
-
 /*
  * Implementation of IOC_LIBCFS_ADD_PEER_NI.
  *
  * This API handles the following combinations:
- *   Create a primary NI if only the prim_nid is provided
- *   Create or add an lpni to a primary NI. Primary NI must've already
- *   been created
- *   Create a non-MR peer.
+ *   Create a peer with its primary NI if only the prim_nid is provided
+ *   Add a NID to a peer identified by the prim_nid. The peer identified
+ *   by the prim_nid must already exist.
+ *   The peer being created may be non-MR.
+ *
+ * The caller must hold ln_api_mutex. This prevents the peer from
+ * being created/modified/deleted by a different thread.
  */
 int
 lnet_add_peer_ni(lnet_nid_t prim_nid, lnet_nid_t nid, bool mr)
 {
+	struct lnet_peer *lp = NULL;
+	struct lnet_peer_ni *lpni;
+
+	/* The prim_nid must always be specified */
+	if (prim_nid == LNET_NID_ANY)
+		return -EINVAL;
+
 	/*
-	 * Caller trying to setup an MR like peer hierarchy but
-	 * specifying it to be non-MR. This is not allowed.
+	 * If nid isn't specified, we must create a new peer with
+	 * prim_nid as its primary nid.
 	 */
-	if (prim_nid != LNET_NID_ANY &&
-	    nid != LNET_NID_ANY && !mr)
-		return -EPERM;
-
-	/* Add the primary NID of a peer */
-	if (prim_nid != LNET_NID_ANY &&
-	    nid == LNET_NID_ANY && mr)
-		return lnet_add_prim_lpni(prim_nid);
+	if (nid == LNET_NID_ANY)
+		return lnet_peer_add(prim_nid, mr);
 
-	/* Add a NID to an existing peer */
-	if (prim_nid != LNET_NID_ANY &&
-	    nid != LNET_NID_ANY && mr)
-		return lnet_add_peer_ni_to_prim_lpni(prim_nid, nid);
+	/* Look up the prim_nid, which must exist. */
+	lpni = lnet_find_peer_ni_locked(prim_nid);
+	if (!lpni)
+		return -ENOENT;
+	lnet_peer_ni_decref_locked(lpni);
+	lp = lpni->lpni_peer_net->lpn_peer;
 
-	/* Add a non-MR peer NI */
-	if (((prim_nid != LNET_NID_ANY &&
-	      nid == LNET_NID_ANY) ||
-	     (prim_nid == LNET_NID_ANY &&
-	      nid != LNET_NID_ANY)) && !mr)
-		return lnet_peer_ni_add_non_mr(prim_nid != LNET_NID_ANY ?
-							 prim_nid : nid);
+	if (lp->lp_primary_nid != prim_nid) {
+		CDEBUG(D_NET, "prim_nid %s is not primary for peer %s\n",
+		       libcfs_nid2str(prim_nid),
+		       libcfs_nid2str(lp->lp_primary_nid));
+		return -ENODEV;
+	}
 
-	return 0;
+	return lnet_peer_add_nid(lp, nid, mr);
 }
 
 /*
