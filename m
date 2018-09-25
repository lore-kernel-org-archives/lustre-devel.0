From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 14/34] LU-7734 lnet: handle non-MR peers
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763540.32103.13948722910331939075.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

Add the ability to declare a peer to be non-MR from the DLC
interface. By default if a peer is configured from DLC it is
assumed to be MR capable, except when the non-mr flag is set.

For non-MR peers always use the same NI to communicate with it.
If multiple NIs are used to communicate with a non-MR peer the
peer will consider that it's talking to different peers which could
cause upper layers to be confused.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: Ie3ec45f5f44fa7d72e3e0335b1383f9c3cc92627
Reviewed-on: http://review.whamcloud.com/19305
Tested-by: Jenkins
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Tested-by: Maloo <hpdd-maloo@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   17 ++++++++++++++++-
 .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |    1 +
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    3 ++-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   13 +++++++++++++
 drivers/staging/lustre/lnet/lnet/peer.c            |    7 ++++---
 5 files changed, 36 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 0259cd2251ed..08fc4abad332 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -661,7 +661,7 @@ struct lnet_peer_net *lnet_peer_get_net_locked(struct lnet_peer *peer,
 					       u32 net_id);
 bool lnet_peer_is_ni_pref_locked(struct lnet_peer_ni *lpni,
 				 struct lnet_ni *ni);
-int lnet_add_peer_ni_to_peer(lnet_nid_t key_nid, lnet_nid_t nid);
+int lnet_add_peer_ni_to_peer(lnet_nid_t key_nid, lnet_nid_t nid, bool mr);
 int lnet_del_peer_ni_from_peer(lnet_nid_t key_nid, lnet_nid_t nid);
 int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
 		       struct lnet_peer_ni_credit_info *peer_ni_info);
@@ -672,6 +672,21 @@ int lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
 			  __u32 *peer_rtr_credits, __u32 *peer_min_rtr_credtis,
 			  __u32 *peer_tx_qnob);
 
+static inline __u32
+lnet_get_num_peer_nis(struct lnet_peer *peer)
+{
+	struct lnet_peer_net *lpn;
+	struct lnet_peer_ni *lpni;
+	__u32 count = 0;
+
+	list_for_each_entry(lpn, &peer->lp_peer_nets, lpn_on_peer_list)
+		list_for_each_entry(lpni, &lpn->lpn_peer_nis,
+				    lpni_on_peer_net_list)
+			count++;
+
+	return count;
+}
+
 static inline bool
 lnet_is_peer_ni_healthy_locked(struct lnet_peer_ni *lpni)
 {
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index 5eaaf0eae470..8be322dd4bd2 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -211,6 +211,7 @@ struct lnet_ioctl_peer_cfg {
 	lnet_nid_t prcfg_key_nid;
 	lnet_nid_t prcfg_cfg_nid;
 	__u32 prcfg_idx;
+	bool prcfg_mr;
 	char prcfg_bulk[0];
 };
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 67a3301258d4..2d5d657de058 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -2689,7 +2689,8 @@ LNetCtl(unsigned int cmd, void *arg)
 			return -EINVAL;
 
 		return lnet_add_peer_ni_to_peer(cfg->prcfg_key_nid,
-						cfg->prcfg_cfg_nid);
+						cfg->prcfg_cfg_nid,
+						cfg->prcfg_mr);
 	}
 
 	case IOC_LIBCFS_DEL_PEER_NI: {
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 5153de984ede..6c5bb953a6d3 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1164,6 +1164,12 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		return -EHOSTUNREACH;
 	}
 
+	if (!peer->lp_multi_rail && lnet_get_num_peer_nis(peer) > 1) {
+		CERROR("peer %s is declared to be non MR capable, yet configured with more than one NID\n",
+		       libcfs_nid2str(dst_nid));
+		return -EINVAL;
+	}
+
 	/*
 	 * STEP 1: first jab at determineing best_ni
 	 * if src_nid is explicitly specified, then best_ni is already
@@ -1361,6 +1367,13 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	 */
 	best_ni->ni_seq++;
 
+	/*
+	 * if the peer is not MR capable, then we should always send to it
+	 * using the first NI in the NET we determined.
+	 */
+	if (!peer->lp_multi_rail && local_net)
+		best_ni = lnet_net2ni_locked(local_net->net_id, cpt);
+
 	if (!best_ni) {
 		lnet_net_unlock(cpt);
 		LCONSOLE_WARN("No local ni found to send from to %s\n",
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index bde7b6214668..ecbd276703f1 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -477,6 +477,7 @@ lnet_build_peer_hierarchy(struct lnet_peer_ni *lpni)
 	peer_net->lpn_peer = peer;
 	lpni->lpni_peer_net = peer_net;
 	peer->lp_primary_nid = lpni->lpni_nid;
+	peer->lp_multi_rail = false;
 	list_add_tail(&peer_net->lpn_on_peer_list, &peer->lp_peer_nets);
 	list_add_tail(&lpni->lpni_on_peer_net_list, &peer_net->lpn_peer_nis);
 	list_add_tail(&peer->lp_on_lnet_peer_list, &the_lnet.ln_peers);
@@ -502,7 +503,7 @@ lnet_peer_get_net_locked(struct lnet_peer *peer, u32 net_id)
  * is unique
  */
 int
-lnet_add_peer_ni_to_peer(lnet_nid_t key_nid, lnet_nid_t nid)
+lnet_add_peer_ni_to_peer(lnet_nid_t key_nid, lnet_nid_t nid, bool mr)
 {
 	struct lnet_peer_ni *lpni, *lpni2;
 	struct lnet_peer *peer;
@@ -535,14 +536,14 @@ lnet_add_peer_ni_to_peer(lnet_nid_t key_nid, lnet_nid_t nid)
 			return -EINVAL;
 		}
 		peer = lpni->lpni_peer_net->lpn_peer;
-		peer->lp_multi_rail = true;
+		peer->lp_multi_rail = mr;
 		lnet_peer_ni_decref_locked(lpni);
 		lnet_net_unlock(cpt2);
 	} else {
 		lnet_net_lock(LNET_LOCK_EX);
 		rc = lnet_nid2peerni_locked(&lpni, nid, LNET_LOCK_EX);
 		if (rc == 0) {
-			lpni->lpni_peer_net->lpn_peer->lp_multi_rail = true;
+			lpni->lpni_peer_net->lpn_peer->lp_multi_rail = mr;
 			lnet_peer_ni_decref_locked(lpni);
 		}
 		lnet_net_unlock(LNET_LOCK_EX);
