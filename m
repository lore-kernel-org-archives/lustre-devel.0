From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 10/34] LU-7734 lnet: configure peers from DLC
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763522.32103.731439682287514589.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

This patch adds the ability to configure peers from the DLC
interface.

When a peer is added a primary NID should be provided. If none is
provided then the first NID in the list of NIDs will be used
as the primary NID.

Basic error checking is done at the DLC level to ensure properly
formatted NIDs. However, if a NID is a duplicate, this will be
detected when adding it in the kernel. Operation is halted, which
means some peer NIDs might have already been added, but not the
entire set. It's the role of the caller to backtrack and remove that
peer that failed to add.

When deleting a peer a primary NID or a normal NID can be provided.
If a standard NID is provided, then the peer is found, and the
primary NID is compared to the peer ni. If they are the same the
entire peer is deleted. Otherwise, only the identified peer ni is
deleted. If a set of NIDs are provided each one will be removed
from the peer identified by the peer NID in turn.

The existing show peer credits API can be used to show peer
information.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: Iaf588a062b44d74305aa9aa7d31c7341c6c384b9
Reviewed-on: http://review.whamcloud.com/18476
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Tested-by: Maloo <hpdd-maloo@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   20 +
 .../staging/lustre/include/linux/lnet/lib-types.h  |    4 
 .../lustre/include/uapi/linux/lnet/libcfs_ioctl.h  |    5 
 .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |   32 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   39 ++
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    4 
 drivers/staging/lustre/lnet/lnet/peer.c            |  387 ++++++++++++++++++--
 drivers/staging/lustre/lnet/lnet/router.c          |    2 
 8 files changed, 433 insertions(+), 60 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 6ffe5c1c9925..11642f8aee90 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -645,21 +645,25 @@ struct lnet_peer_ni *lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 int lnet_find_or_create_peer_locked(lnet_nid_t dst_nid, int cpt,
 				    struct lnet_peer **peer);
 int lnet_nid2peerni_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt);
-struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid, int cpt);
+struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
 void lnet_peer_tables_cleanup(struct lnet_ni *ni);
-void lnet_peer_tables_destroy(void);
+void lnet_peer_uninit(void);
 int lnet_peer_tables_create(void);
 void lnet_debug_peer(lnet_nid_t nid);
 struct lnet_peer_net *lnet_peer_get_net_locked(struct lnet_peer *peer,
 					       u32 net_id);
 bool lnet_peer_is_ni_pref_locked(struct lnet_peer_ni *lpni,
 				 struct lnet_ni *ni);
-int lnet_get_peer_info(__u32 peer_index, __u64 *nid,
-		       char alivness[LNET_MAX_STR_LEN],
-		       __u32 *cpt_iter, __u32 *refcount,
-		       __u32 *ni_peer_tx_credits, __u32 *peer_tx_credits,
-		       __u32 *peer_rtr_credits, __u32 *peer_min_rtr_credtis,
-		       __u32 *peer_tx_qnob);
+int lnet_add_peer_ni_to_peer(lnet_nid_t key_nid, lnet_nid_t nid);
+int lnet_del_peer_ni_from_peer(lnet_nid_t key_nid, lnet_nid_t nid);
+int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
+		       struct lnet_peer_ni_credit_info *peer_ni_info);
+int lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
+			  char alivness[LNET_MAX_STR_LEN],
+			  __u32 *cpt_iter, __u32 *refcount,
+			  __u32 *ni_peer_tx_credits, __u32 *peer_tx_credits,
+			  __u32 *peer_rtr_credits, __u32 *peer_min_rtr_credtis,
+			  __u32 *peer_tx_qnob);
 
 static inline bool
 lnet_is_peer_ni_healthy_locked(struct lnet_peer_ni *lpni)
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index d935d273716d..22b141cb6cff 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -388,6 +388,8 @@ struct lnet_rc_data {
 
 struct lnet_peer_ni {
 	struct list_head	lpni_on_peer_net_list;
+	/* chain on remote peer list */
+	struct list_head	lpni_on_remote_peer_ni_list;
 	/* chain on peer hash */
 	struct list_head	 lpni_hashlist;
 	/* messages blocking for tx credits */
@@ -732,6 +734,8 @@ struct lnet {
 	struct lnet_peer_table		**ln_peer_tables;
 	/* list of configured or discovered peers */
 	struct list_head		ln_peers;
+	/* list of peer nis not on a local network */
+	struct list_head		ln_remote_peer_ni_list;
 	/* failure simulation */
 	struct list_head		  ln_test_peers;
 	struct list_head		  ln_drop_rules;
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
index cce6b58e3682..d5a3e7c85aa4 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -136,6 +136,9 @@ struct libcfs_debug_ioctl_data {
 #define IOC_LIBCFS_GET_BUF		_IOWR(IOC_LIBCFS_TYPE, 89, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_PEER_INFO	_IOWR(IOC_LIBCFS_TYPE, 90, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_LNET_STATS	_IOWR(IOC_LIBCFS_TYPE, 91, IOCTL_CONFIG_SIZE)
-#define IOC_LIBCFS_MAX_NR		91
+#define IOC_LIBCFS_ADD_PEER_NI		_IOWR(IOC_LIBCFS_TYPE, 92, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_DEL_PEER_NI		_IOWR(IOC_LIBCFS_TYPE, 93, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_GET_PEER_NI		_IOWR(IOC_LIBCFS_TYPE, 94, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_MAX_NR		94
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index ac29f9d24d5d..9c4e05e1b683 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -126,26 +126,36 @@ struct lnet_ioctl_config_data {
 	char cfg_bulk[0];
 };
 
+struct lnet_peer_ni_credit_info {
+	char cr_aliveness[LNET_MAX_STR_LEN];
+	__u32 cr_refcount;
+	__s32 cr_ni_peer_tx_credits;
+	__s32 cr_peer_tx_credits;
+	__s32 cr_peer_rtr_credits;
+	__s32 cr_peer_min_rtr_credits;
+	__u32 cr_peer_tx_qnob;
+	__u32 cr_ncpt;
+};
+
 struct lnet_ioctl_peer {
 	struct libcfs_ioctl_hdr pr_hdr;
 	__u32 pr_count;
 	__u32 pr_pad;
-	__u64 pr_nid;
+	lnet_nid_t pr_nid;
 
 	union {
-		struct {
-			char cr_aliveness[LNET_MAX_STR_LEN];
-			__u32 cr_refcount;
-			__u32 cr_ni_peer_tx_credits;
-			__u32 cr_peer_tx_credits;
-			__u32 cr_peer_rtr_credits;
-			__u32 cr_peer_min_rtr_credits;
-			__u32 cr_peer_tx_qnob;
-			__u32 cr_ncpt;
-		} pr_peer_credits;
+		struct lnet_peer_ni_credit_info  pr_peer_credits;
 	} pr_lnd_u;
 };
 
+struct lnet_ioctl_peer_cfg {
+	struct libcfs_ioctl_hdr prcfg_hdr;
+	lnet_nid_t prcfg_key_nid;
+	lnet_nid_t prcfg_cfg_nid;
+	__u32 prcfg_idx;
+	char prcfg_bulk[0];
+};
+
 struct lnet_ioctl_lnet_stats {
 	struct libcfs_ioctl_hdr st_hdr;
 	struct lnet_counters st_cntrs;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index e8e0bc45d8aa..710f8a0be934 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -552,6 +552,7 @@ lnet_prepare(lnet_pid_t requested_pid)
 
 	INIT_LIST_HEAD(&the_lnet.ln_test_peers);
 	INIT_LIST_HEAD(&the_lnet.ln_peers);
+	INIT_LIST_HEAD(&the_lnet.ln_remote_peer_ni_list);
 	INIT_LIST_HEAD(&the_lnet.ln_nets);
 	INIT_LIST_HEAD(&the_lnet.ln_routers);
 	INIT_LIST_HEAD(&the_lnet.ln_drop_rules);
@@ -646,7 +647,7 @@ lnet_unprepare(void)
 	lnet_res_container_cleanup(&the_lnet.ln_eq_container);
 
 	lnet_msg_containers_destroy();
-	lnet_peer_tables_destroy();
+	lnet_peer_uninit();
 	lnet_rtrpools_free(0);
 
 	if (the_lnet.ln_counters) {
@@ -2318,13 +2319,33 @@ LNetCtl(unsigned int cmd, void *arg)
 		return lnet_get_rtr_pool_cfg(config->cfg_count, pool_cfg);
 	}
 
+	case IOC_LIBCFS_ADD_PEER_NI: {
+		struct lnet_ioctl_peer_cfg *cfg = arg;
+
+		if (cfg->prcfg_hdr.ioc_len < sizeof(*cfg))
+			return -EINVAL;
+
+		return lnet_add_peer_ni_to_peer(cfg->prcfg_key_nid,
+						cfg->prcfg_cfg_nid);
+	}
+
+	case IOC_LIBCFS_DEL_PEER_NI: {
+		struct lnet_ioctl_peer_cfg *cfg = arg;
+
+		if (cfg->prcfg_hdr.ioc_len < sizeof(*cfg))
+			return -EINVAL;
+
+		return lnet_del_peer_ni_from_peer(cfg->prcfg_key_nid,
+						  cfg->prcfg_cfg_nid);
+	}
+
 	case IOC_LIBCFS_GET_PEER_INFO: {
 		struct lnet_ioctl_peer *peer_info = arg;
 
 		if (peer_info->pr_hdr.ioc_len < sizeof(*peer_info))
 			return -EINVAL;
 
-		return lnet_get_peer_info(peer_info->pr_count,
+		return lnet_get_peer_ni_info(peer_info->pr_count,
 			&peer_info->pr_nid,
 			peer_info->pr_lnd_u.pr_peer_credits.cr_aliveness,
 			&peer_info->pr_lnd_u.pr_peer_credits.cr_ncpt,
@@ -2336,6 +2357,20 @@ LNetCtl(unsigned int cmd, void *arg)
 			&peer_info->pr_lnd_u.pr_peer_credits.cr_peer_tx_qnob);
 	}
 
+	case IOC_LIBCFS_GET_PEER_NI: {
+		struct lnet_ioctl_peer_cfg *cfg = arg;
+		struct lnet_peer_ni_credit_info *lpni_cri;
+		size_t total = sizeof(*cfg) + sizeof(*lpni_cri);
+
+		if (cfg->prcfg_hdr.ioc_len < total)
+			return -EINVAL;
+
+		lpni_cri = (struct lnet_peer_ni_credit_info *)cfg->prcfg_bulk;
+
+		return lnet_get_peer_info(cfg->prcfg_idx, &cfg->prcfg_key_nid,
+					  &cfg->prcfg_cfg_nid, lpni_cri);
+	}
+
 	case IOC_LIBCFS_NOTIFY_ROUTER: {
 		time64_t deadline = ktime_get_real_seconds() - data->ioc_u64[0];
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 54e3093355c2..fbf209610ff9 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1307,7 +1307,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		 * received the message on if possible. If not, then pick
 		 * a peer_ni to send to
 		 */
-		best_lpni = lnet_find_peer_ni_locked(dst_nid, cpt);
+		best_lpni = lnet_find_peer_ni_locked(dst_nid);
 		if (best_lpni) {
 			lnet_peer_ni_decref_locked(best_lpni);
 			goto send;
@@ -1348,7 +1348,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 			libcfs_nid2str(best_gw->lpni_nid),
 			lnet_msgtyp2str(msg->msg_type), msg->msg_len);
 
-		best_lpni = lnet_find_peer_ni_locked(dst_nid, cpt);
+		best_lpni = lnet_find_peer_ni_locked(dst_nid);
 		LASSERT(best_lpni);
 		lnet_peer_ni_decref_locked(best_lpni);
 
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index edba1b1d87cc..d081440579e0 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -38,6 +38,65 @@
 #include <linux/lnet/lib-lnet.h>
 #include <uapi/linux/lnet/lnet-dlc.h>
 
+static void
+lnet_peer_remove_from_remote_list(struct lnet_peer_ni *lpni)
+{
+	if (!list_empty(&lpni->lpni_on_remote_peer_ni_list)) {
+		list_del_init(&lpni->lpni_on_remote_peer_ni_list);
+		lnet_peer_ni_decref_locked(lpni);
+	}
+}
+
+void
+lnet_peer_tables_destroy(void)
+{
+	struct lnet_peer_table *ptable;
+	struct list_head *hash;
+	int i;
+	int j;
+
+	if (!the_lnet.ln_peer_tables)
+		return;
+
+	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
+		hash = ptable->pt_hash;
+		if (!hash) /* not initialized */
+			break;
+
+		ptable->pt_hash = NULL;
+		for (j = 0; j < LNET_PEER_HASH_SIZE; j++)
+			LASSERT(list_empty(&hash[j]));
+
+		kvfree(hash);
+	}
+
+	cfs_percpt_free(the_lnet.ln_peer_tables);
+	the_lnet.ln_peer_tables = NULL;
+}
+
+void lnet_peer_uninit(void)
+{
+	int cpt;
+	struct lnet_peer_ni *lpni, *tmp;
+	struct lnet_peer_table *ptable = NULL;
+
+	/* remove all peer_nis from the remote peer and he hash list */
+	list_for_each_entry_safe(lpni, tmp, &the_lnet.ln_remote_peer_ni_list,
+				 lpni_on_remote_peer_ni_list) {
+		list_del_init(&lpni->lpni_on_remote_peer_ni_list);
+		lnet_peer_ni_decref_locked(lpni);
+
+		cpt = lnet_cpt_of_nid_locked(lpni->lpni_nid, NULL);
+		ptable = the_lnet.ln_peer_tables[cpt];
+		ptable->pt_zombies++;
+
+		list_del_init(&lpni->lpni_hashlist);
+		lnet_peer_ni_decref_locked(lpni);
+	}
+
+	lnet_peer_tables_destroy();
+}
+
 int
 lnet_peer_tables_create(void)
 {
@@ -70,33 +129,6 @@ lnet_peer_tables_create(void)
 	return 0;
 }
 
-void
-lnet_peer_tables_destroy(void)
-{
-	struct lnet_peer_table *ptable;
-	struct list_head *hash;
-	int i;
-	int j;
-
-	if (!the_lnet.ln_peer_tables)
-		return;
-
-	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
-		hash = ptable->pt_hash;
-		if (!hash) /* not initialized */
-			break;
-
-		ptable->pt_hash = NULL;
-		for (j = 0; j < LNET_PEER_HASH_SIZE; j++)
-			LASSERT(list_empty(&hash[j]));
-
-		kvfree(hash);
-	}
-
-	cfs_percpt_free(the_lnet.ln_peer_tables);
-	the_lnet.ln_peer_tables = NULL;
-}
-
 static void
 lnet_peer_table_cleanup_locked(struct lnet_ni *ni,
 			       struct lnet_peer_table *ptable)
@@ -219,10 +251,13 @@ lnet_get_peer_ni_locked(struct lnet_peer_table *ptable, lnet_nid_t nid)
 }
 
 struct lnet_peer_ni *
-lnet_find_peer_ni_locked(lnet_nid_t nid, int cpt)
+lnet_find_peer_ni_locked(lnet_nid_t nid)
 {
 	struct lnet_peer_ni *lpni;
 	struct lnet_peer_table *ptable;
+	int cpt;
+
+	cpt = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
 
 	ptable = the_lnet.ln_peer_tables[cpt];
 	lpni = lnet_get_peer_ni_locked(ptable, nid);
@@ -236,7 +271,7 @@ lnet_find_or_create_peer_locked(lnet_nid_t dst_nid, int cpt,
 {
 	struct lnet_peer_ni *lpni;
 
-	lpni = lnet_find_peer_ni_locked(dst_nid, cpt);
+	lpni = lnet_find_peer_ni_locked(dst_nid);
 	if (!lpni) {
 		int rc;
 
@@ -251,6 +286,25 @@ lnet_find_or_create_peer_locked(lnet_nid_t dst_nid, int cpt,
 	return 0;
 }
 
+struct lnet_peer_ni *
+lnet_get_peer_ni_idx_locked(int idx, struct lnet_peer_net **lpn,
+			    struct lnet_peer **lp)
+{
+	struct lnet_peer_ni	*lpni;
+
+	list_for_each_entry((*lp), &the_lnet.ln_peers, lp_on_lnet_peer_list) {
+		list_for_each_entry((*lpn), &((*lp)->lp_peer_nets),
+				    lpn_on_peer_list) {
+			list_for_each_entry(lpni, &((*lpn)->lpn_peer_nis),
+					    lpni_on_peer_net_list)
+				if (idx-- == 0)
+					return lpni;
+		}
+	}
+
+	return NULL;
+}
+
 struct lnet_peer_ni *
 lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 			     struct lnet_peer_net *peer_net,
@@ -403,6 +457,223 @@ lnet_peer_get_net_locked(struct lnet_peer *peer, u32 net_id)
 	return NULL;
 }
 
+/*
+ * given the key nid find the peer to add the new peer NID to. If the key
+ * nid is NULL, then create a new peer, but first make sure that the NID
+ * is unique
+ */
+int
+lnet_add_peer_ni_to_peer(lnet_nid_t key_nid, lnet_nid_t nid)
+{
+	struct lnet_peer_ni *lpni, *lpni2;
+	struct lnet_peer *peer;
+	struct lnet_peer_net *peer_net, *pn;
+	int cpt, cpt2, rc;
+	struct lnet_peer_table *ptable = NULL;
+	__u32 net_id = LNET_NIDNET(nid);
+
+	if (nid == LNET_NID_ANY)
+		return -EINVAL;
+
+	/* check that nid is unique */
+	cpt = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
+	lnet_net_lock(cpt);
+	lpni = lnet_find_peer_ni_locked(nid);
+	if (lpni) {
+		lnet_peer_ni_decref_locked(lpni);
+		lnet_net_unlock(cpt);
+		return -EEXIST;
+	}
+	lnet_net_unlock(cpt);
+
+	if (key_nid != LNET_NID_ANY) {
+		cpt2 = lnet_nid_cpt_hash(key_nid, LNET_CPT_NUMBER);
+		lnet_net_lock(cpt2);
+		lpni = lnet_find_peer_ni_locked(key_nid);
+		if (!lpni) {
+			lnet_net_unlock(cpt2);
+			/* key_nid refers to a non-existent peer_ni.*/
+			return -EINVAL;
+		}
+		peer = lpni->lpni_peer_net->lpn_peer;
+		peer->lp_multi_rail = true;
+		lnet_peer_ni_decref_locked(lpni);
+		lnet_net_unlock(cpt2);
+	} else {
+		lnet_net_lock(LNET_LOCK_EX);
+		rc = lnet_nid2peerni_locked(&lpni, nid, LNET_LOCK_EX);
+		if (rc == 0) {
+			lpni->lpni_peer_net->lpn_peer->lp_multi_rail = true;
+			lnet_peer_ni_decref_locked(lpni);
+		}
+		lnet_net_unlock(LNET_LOCK_EX);
+		return rc;
+	}
+
+	lpni = kzalloc_cpt(sizeof(*lpni), GFP_KERNEL, cpt);
+	if (!lpni)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&lpni->lpni_txq);
+	INIT_LIST_HEAD(&lpni->lpni_rtrq);
+	INIT_LIST_HEAD(&lpni->lpni_routes);
+	INIT_LIST_HEAD(&lpni->lpni_hashlist);
+	INIT_LIST_HEAD(&lpni->lpni_on_peer_net_list);
+	INIT_LIST_HEAD(&lpni->lpni_on_remote_peer_ni_list);
+
+	lpni->lpni_alive = !lnet_peers_start_down(); /* 1 bit!! */
+	lpni->lpni_last_alive = ktime_get_seconds(); /* assumes alive */
+	lpni->lpni_ping_feats = LNET_PING_FEAT_INVAL;
+	lpni->lpni_nid = nid;
+	lpni->lpni_cpt = cpt;
+	lnet_set_peer_ni_health_locked(lpni, true);
+
+	/* allocate here in case we need to add a new peer_net */
+	peer_net = NULL;
+	peer_net = kzalloc(sizeof(*peer_net), GFP_KERNEL);
+	if (!peer_net) {
+		rc = -ENOMEM;
+		kfree(lpni);
+		return rc;
+	}
+
+	lnet_net_lock(LNET_LOCK_EX);
+
+	ptable = the_lnet.ln_peer_tables[cpt];
+	ptable->pt_number++;
+
+	lpni2 = lnet_find_peer_ni_locked(nid);
+	if (lpni2) {
+		lnet_peer_ni_decref_locked(lpni2);
+		/* sanity check that lpni2's peer is what we expect */
+		if (lpni2->lpni_peer_net->lpn_peer != peer)
+			rc = -EEXIST;
+		else
+			rc = -EINVAL;
+
+		ptable->pt_number--;
+		/* another thread has already added it */
+		lnet_net_unlock(LNET_LOCK_EX);
+		kfree(peer_net);
+		return rc;
+	}
+
+	lpni->lpni_net = lnet_get_net_locked(LNET_NIDNET(lpni->lpni_nid));
+	if (lpni->lpni_net) {
+		lpni->lpni_txcredits =
+			lpni->lpni_mintxcredits =
+			lpni->lpni_net->net_tunables.lct_peer_tx_credits;
+		lpni->lpni_rtrcredits =
+			lpni->lpni_minrtrcredits =
+			lnet_peer_buffer_credits(lpni->lpni_net);
+	} else {
+		/*
+		 * if you're adding a peer which is not on a local network
+		 * then we can't assign any of the credits. It won't be
+		 * picked for sending anyway. Eventually a network can be
+		 * added, in this case we need to revisit this peer and
+		 * update its credits.
+		 */
+
+		/* increment refcount for remote peer list */
+		atomic_inc(&lpni->lpni_refcount);
+		list_add_tail(&lpni->lpni_on_remote_peer_ni_list,
+			      &the_lnet.ln_remote_peer_ni_list);
+	}
+
+	/* increment refcount for peer on hash list */
+	atomic_inc(&lpni->lpni_refcount);
+
+	list_add_tail(&lpni->lpni_hashlist,
+		      &ptable->pt_hash[lnet_nid2peerhash(nid)]);
+	ptable->pt_version++;
+
+	/* add the lpni to a net */
+	list_for_each_entry(pn, &peer->lp_peer_nets, lpn_on_peer_list) {
+		if (pn->lpn_net_id == net_id) {
+			list_add_tail(&lpni->lpni_on_peer_net_list,
+				      &pn->lpn_peer_nis);
+			lpni->lpni_peer_net = pn;
+			lnet_net_unlock(LNET_LOCK_EX);
+			kfree(peer_net);
+			return 0;
+		}
+	}
+
+	INIT_LIST_HEAD(&peer_net->lpn_on_peer_list);
+	INIT_LIST_HEAD(&peer_net->lpn_peer_nis);
+
+	/* build the hierarchy */
+	peer_net->lpn_net_id = net_id;
+	peer_net->lpn_peer = peer;
+	lpni->lpni_peer_net = peer_net;
+	list_add_tail(&lpni->lpni_on_peer_net_list, &peer_net->lpn_peer_nis);
+	list_add_tail(&peer_net->lpn_on_peer_list, &peer->lp_peer_nets);
+
+	lnet_net_unlock(LNET_LOCK_EX);
+	return 0;
+}
+
+int
+lnet_del_peer_ni_from_peer(lnet_nid_t key_nid, lnet_nid_t nid)
+{
+	int cpt;
+	lnet_nid_t local_nid;
+	struct lnet_peer *peer;
+	struct lnet_peer_ni *lpni, *lpni2;
+	struct lnet_peer_table *ptable = NULL;
+
+	if (key_nid == LNET_NID_ANY)
+		return -EINVAL;
+
+	local_nid = (nid != LNET_NID_ANY) ? nid : key_nid;
+	cpt = lnet_nid_cpt_hash(local_nid, LNET_CPT_NUMBER);
+	lnet_net_lock(LNET_LOCK_EX);
+
+	lpni = lnet_find_peer_ni_locked(local_nid);
+	if (!lpni) {
+		lnet_net_unlock(cpt);
+		return -EINVAL;
+	}
+	lnet_peer_ni_decref_locked(lpni);
+
+	peer = lpni->lpni_peer_net->lpn_peer;
+	LASSERT(peer);
+
+	if (peer->lp_primary_nid == lpni->lpni_nid) {
+		/*
+		 * deleting the primary ni is equivalent to deleting the
+		 * entire peer
+		 */
+		lpni = NULL;
+		lpni = lnet_get_next_peer_ni_locked(peer, NULL, lpni);
+		while (lpni) {
+			lpni2 = lnet_get_next_peer_ni_locked(peer, NULL, lpni);
+			cpt = lnet_nid_cpt_hash(lpni->lpni_nid,
+						LNET_CPT_NUMBER);
+			lnet_peer_remove_from_remote_list(lpni);
+			ptable = the_lnet.ln_peer_tables[cpt];
+			ptable->pt_zombies++;
+			list_del_init(&lpni->lpni_hashlist);
+			lnet_peer_ni_decref_locked(lpni);
+			lpni = lpni2;
+		}
+		lnet_net_unlock(LNET_LOCK_EX);
+
+		return 0;
+	}
+
+	lnet_peer_remove_from_remote_list(lpni);
+	cpt = lnet_nid_cpt_hash(lpni->lpni_nid, LNET_CPT_NUMBER);
+	ptable = the_lnet.ln_peer_tables[cpt];
+	ptable->pt_zombies++;
+	list_del_init(&lpni->lpni_hashlist);
+	lnet_peer_ni_decref_locked(lpni);
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	return 0;
+}
+
 void
 lnet_destroy_peer_ni_locked(struct lnet_peer_ni *lpni)
 {
@@ -487,6 +758,9 @@ lnet_nid2peerni_locked(struct lnet_peer_ni **lpnip, lnet_nid_t nid, int cpt)
 	INIT_LIST_HEAD(&lpni->lpni_txq);
 	INIT_LIST_HEAD(&lpni->lpni_rtrq);
 	INIT_LIST_HEAD(&lpni->lpni_routes);
+	INIT_LIST_HEAD(&lpni->lpni_hashlist);
+	INIT_LIST_HEAD(&lpni->lpni_on_peer_net_list);
+	INIT_LIST_HEAD(&lpni->lpni_on_remote_peer_ni_list);
 
 	lpni->lpni_alive = !lnet_peers_start_down(); /* 1 bit!! */
 	lpni->lpni_last_alive = ktime_get_seconds(); /* assumes alive */
@@ -521,8 +795,20 @@ lnet_nid2peerni_locked(struct lnet_peer_ni **lpnip, lnet_nid_t nid, int cpt)
 			lpni->lpni_minrtrcredits =
 			lnet_peer_buffer_credits(lpni->lpni_net);
 	} else {
+		/*
+		 * if you're adding a peer which is not on a local network
+		 * then we can't assign any of the credits. It won't be
+		 * picked for sending anyway. Eventually a network can be
+		 * added, in this case we need to revisit this peer and
+		 * update its credits.
+		 */
+
 		CDEBUG(D_NET, "peer_ni %s is not directly connected\n",
 		       libcfs_nid2str(nid));
+		/* increment refcount for remote peer list */
+		atomic_inc(&lpni->lpni_refcount);
+		list_add_tail(&lpni->lpni_on_remote_peer_ni_list,
+			      &the_lnet.ln_remote_peer_ni_list);
 	}
 
 	lnet_set_peer_ni_health_locked(lpni, true);
@@ -584,12 +870,12 @@ lnet_debug_peer(lnet_nid_t nid)
 }
 
 int
-lnet_get_peer_info(__u32 peer_index, __u64 *nid,
-		   char aliveness[LNET_MAX_STR_LEN],
-		   __u32 *cpt_iter, __u32 *refcount,
-		   __u32 *ni_peer_tx_credits, __u32 *peer_tx_credits,
-		   __u32 *peer_rtr_credits, __u32 *peer_min_rtr_credits,
-		   __u32 *peer_tx_qnob)
+lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
+		      char aliveness[LNET_MAX_STR_LEN],
+		      __u32 *cpt_iter, __u32 *refcount,
+		      __u32 *ni_peer_tx_credits, __u32 *peer_tx_credits,
+		      __u32 *peer_rtr_credits, __u32 *peer_min_rtr_credits,
+		      __u32 *peer_tx_qnob)
 {
 	struct lnet_peer_table *peer_table;
 	struct lnet_peer_ni *lp;
@@ -645,3 +931,34 @@ lnet_get_peer_info(__u32 peer_index, __u64 *nid,
 
 	return found ? 0 : -ENOENT;
 }
+
+int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
+		       struct lnet_peer_ni_credit_info *peer_ni_info)
+{
+	struct lnet_peer_ni *lpni = NULL;
+	struct lnet_peer_net *lpn = NULL;
+	struct lnet_peer *lp = NULL;
+
+	lpni = lnet_get_peer_ni_idx_locked(idx, &lpn, &lp);
+
+	if (!lpni)
+		return -ENOENT;
+
+	*primary_nid = lp->lp_primary_nid;
+	*nid = lpni->lpni_nid;
+	snprintf(peer_ni_info->cr_aliveness, LNET_MAX_STR_LEN, "NA");
+	if (lnet_isrouter(lpni) ||
+	    lnet_peer_aliveness_enabled(lpni))
+		snprintf(peer_ni_info->cr_aliveness, LNET_MAX_STR_LEN,
+			 lpni->lpni_alive ? "up" : "down");
+
+	peer_ni_info->cr_refcount = atomic_read(&lpni->lpni_refcount);
+	peer_ni_info->cr_ni_peer_tx_credits = lpni->lpni_net ?
+		lpni->lpni_net->net_tunables.lct_peer_tx_credits : 0;
+	peer_ni_info->cr_peer_tx_credits = lpni->lpni_txcredits;
+	peer_ni_info->cr_peer_rtr_credits = lpni->lpni_rtrcredits;
+	peer_ni_info->cr_peer_min_rtr_credits = lpni->lpni_mintxcredits;
+	peer_ni_info->cr_peer_tx_qnob = lpni->lpni_txqnob;
+
+	return 0;
+}
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index de037a77671d..7913914620f3 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1734,7 +1734,7 @@ lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, int alive, time64_t when)
 		return -ESHUTDOWN;
 	}
 
-	lp = lnet_find_peer_ni_locked(nid, cpt);
+	lp = lnet_find_peer_ni_locked(nid);
 	if (!lp) {
 		/* nid not found */
 		lnet_net_unlock(cpt);
