From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:16 +1000
Subject: [lustre-devel] [PATCH 32/34] LU-7734 lnet: rename peer key_nid to
 prim_nid
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763608.32103.13444702792250303421.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

To make the interface clear, renamed key_nid to
prim_nid to indicate that this parameter refers to
the peer's primary nid.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: I74bd17cdd55ba8d2c52bc28557db149d23ecbfb5
Reviewed-on: http://review.whamcloud.com/23460
Tested-by: Maloo <hpdd-maloo@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |    2 -
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    6 +--
 drivers/staging/lustre/lnet/lnet/peer.c            |   42 ++++++++++----------
 3 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index a5e94619d3f1..d1e2911ab342 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -216,7 +216,7 @@ struct lnet_ioctl_dbg {
 
 struct lnet_ioctl_peer_cfg {
 	struct libcfs_ioctl_hdr prcfg_hdr;
-	lnet_nid_t prcfg_key_nid;
+	lnet_nid_t prcfg_prim_nid;
 	lnet_nid_t prcfg_cfg_nid;
 	__u32 prcfg_idx;
 	bool prcfg_mr;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index ea27d38f78c5..9a09927c346a 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -2728,7 +2728,7 @@ LNetCtl(unsigned int cmd, void *arg)
 			return -EINVAL;
 
 		mutex_lock(&the_lnet.ln_api_mutex);
-		rc = lnet_add_peer_ni_to_peer(cfg->prcfg_key_nid,
+		rc = lnet_add_peer_ni_to_peer(cfg->prcfg_prim_nid,
 					      cfg->prcfg_cfg_nid,
 					      cfg->prcfg_mr);
 		mutex_unlock(&the_lnet.ln_api_mutex);
@@ -2742,7 +2742,7 @@ LNetCtl(unsigned int cmd, void *arg)
 			return -EINVAL;
 
 		mutex_lock(&the_lnet.ln_api_mutex);
-		rc = lnet_del_peer_ni_from_peer(cfg->prcfg_key_nid,
+		rc = lnet_del_peer_ni_from_peer(cfg->prcfg_prim_nid,
 						cfg->prcfg_cfg_nid);
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return rc;
@@ -2785,7 +2785,7 @@ LNetCtl(unsigned int cmd, void *arg)
 			     (cfg->prcfg_bulk + sizeof(*lpni_cri));
 
 		mutex_lock(&the_lnet.ln_api_mutex);
-		rc = lnet_get_peer_info(cfg->prcfg_idx, &cfg->prcfg_key_nid,
+		rc = lnet_get_peer_info(cfg->prcfg_idx, &cfg->prcfg_prim_nid,
 					&cfg->prcfg_cfg_nid, &cfg->prcfg_mr,
 					lpni_cri, lpni_stats);
 		mutex_unlock(&the_lnet.ln_api_mutex);
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 747a4fc8d39f..3a5f9dbf5c96 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -781,18 +781,18 @@ lnet_add_prim_lpni(lnet_nid_t nid)
 }
 
 static int
-lnet_add_peer_ni_to_prim_lpni(lnet_nid_t key_nid, lnet_nid_t nid)
+lnet_add_peer_ni_to_prim_lpni(lnet_nid_t prim_nid, lnet_nid_t nid)
 {
 	struct lnet_peer *peer, *primary_peer;
 	struct lnet_peer_ni *lpni = NULL, *klpni = NULL;
 
-	LASSERT(key_nid != LNET_NID_ANY && nid != LNET_NID_ANY);
+	LASSERT(prim_nid != LNET_NID_ANY && nid != LNET_NID_ANY);
 
 	/*
 	 * key nid must be created by this point. If not then this
 	 * operation is not permitted
 	 */
-	klpni = lnet_find_peer_ni_locked(key_nid);
+	klpni = lnet_find_peer_ni_locked(prim_nid);
 	if (!klpni)
 		return -ENOENT;
 
@@ -809,13 +809,13 @@ lnet_add_peer_ni_to_prim_lpni(lnet_nid_t key_nid, lnet_nid_t nid)
 		 * lpni already exists in the system but it belongs to
 		 * a different peer. We can't re-added it
 		 */
-		if (peer->lp_primary_nid != key_nid && peer->lp_multi_rail) {
+		if (peer->lp_primary_nid != prim_nid && peer->lp_multi_rail) {
 			CERROR("Cannot add NID %s owned by peer %s to peer %s\n",
 			       libcfs_nid2str(lpni->lpni_nid),
 			       libcfs_nid2str(peer->lp_primary_nid),
-			       libcfs_nid2str(key_nid));
+			       libcfs_nid2str(prim_nid));
 			return -EEXIST;
-		} else if (peer->lp_primary_nid == key_nid) {
+		} else if (peer->lp_primary_nid == prim_nid) {
 			/*
 			 * found a peer_ni that is already part of the
 			 * peer. This is a no-op operation.
@@ -824,7 +824,7 @@ lnet_add_peer_ni_to_prim_lpni(lnet_nid_t key_nid, lnet_nid_t nid)
 		}
 
 		/*
-		 * TODO: else if (peer->lp_primary_nid != key_nid &&
+		 * TODO: else if (peer->lp_primary_nid != prim_nid &&
 		 *		  !peer->lp_multi_rail)
 		 * peer is not an MR peer and it will be moved in the next
 		 * step to klpni, so update its flags accordingly.
@@ -895,55 +895,55 @@ lnet_peer_ni_add_non_mr(lnet_nid_t nid)
 
 /*
  * This API handles the following combinations:
- *	Create a primary NI if only the key_nid is provided
+ *	Create a primary NI if only the prim_nid is provided
  *	Create or add an lpni to a primary NI. Primary NI must've already
  *	been created
  *	Create a non-MR peer.
  */
 int
-lnet_add_peer_ni_to_peer(lnet_nid_t key_nid, lnet_nid_t nid, bool mr)
+lnet_add_peer_ni_to_peer(lnet_nid_t prim_nid, lnet_nid_t nid, bool mr)
 {
 	/*
 	 * Caller trying to setup an MR like peer hierarchy but
 	 * specifying it to be non-MR. This is not allowed.
 	 */
-	if (key_nid != LNET_NID_ANY &&
+	if (prim_nid != LNET_NID_ANY &&
 	    nid != LNET_NID_ANY && !mr)
 		return -EPERM;
 
 	/* Add the primary NID of a peer */
-	if (key_nid != LNET_NID_ANY &&
+	if (prim_nid != LNET_NID_ANY &&
 	    nid == LNET_NID_ANY && mr)
-		return lnet_add_prim_lpni(key_nid);
+		return lnet_add_prim_lpni(prim_nid);
 
 	/* Add a NID to an existing peer */
-	if (key_nid != LNET_NID_ANY &&
+	if (prim_nid != LNET_NID_ANY &&
 	    nid != LNET_NID_ANY && mr)
-		return lnet_add_peer_ni_to_prim_lpni(key_nid, nid);
+		return lnet_add_peer_ni_to_prim_lpni(prim_nid, nid);
 
 	/* Add a non-MR peer NI */
-	if (((key_nid != LNET_NID_ANY &&
+	if (((prim_nid != LNET_NID_ANY &&
 	      nid == LNET_NID_ANY) ||
-	     (key_nid == LNET_NID_ANY &&
+	     (prim_nid == LNET_NID_ANY &&
 	      nid != LNET_NID_ANY)) && !mr)
-		return lnet_peer_ni_add_non_mr(key_nid != LNET_NID_ANY ?
-							 key_nid : nid);
+		return lnet_peer_ni_add_non_mr(prim_nid != LNET_NID_ANY ?
+							 prim_nid : nid);
 
 	return 0;
 }
 
 int
-lnet_del_peer_ni_from_peer(lnet_nid_t key_nid, lnet_nid_t nid)
+lnet_del_peer_ni_from_peer(lnet_nid_t prim_nid, lnet_nid_t nid)
 {
 	lnet_nid_t local_nid;
 	struct lnet_peer *peer;
 	struct lnet_peer_ni *lpni;
 	int rc;
 
-	if (key_nid == LNET_NID_ANY)
+	if (prim_nid == LNET_NID_ANY)
 		return -EINVAL;
 
-	local_nid = (nid != LNET_NID_ANY) ? nid : key_nid;
+	local_nid = (nid != LNET_NID_ANY) ? nid : prim_nid;
 
 	lpni = lnet_find_peer_ni_locked(local_nid);
 	if (!lpni)
