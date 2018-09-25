From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 18/34] LU-7734 lnet: peer/peer_ni handling
 adjustments
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763556.32103.9233364631803474395.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

A peer can be added by specifying a list of NIDs
	The first NID shall be used as the primary NID. The rest of
	the NIDs will be added under the primary NID

A peer can be added by explicitly specifying the key NID, and then
by adding a set of other NIDs, all done through one API call

If a key NID already exists, but it's not an MR NI, then adding that
Key NID from DLC shall convert that NI to an MR NI

If a key NID already exists, and it is an MR NI, then re-adding the
Key NID shall have no effect

if a Key NID already exists as part of another peer, then adding that
NID as part of another peer or as primary shall fail

if a NID is being added to a peer NI and that NID is a non-MR, then
that NID is moved under the peer and is made to be MR capable

if a NID is being added to a peer and that NID is an MR NID and part
of another peer, then the operation shall fail

if a NID is being added to a peer and it is already part of that Peer
then the operation is a no-op.

Moreover, the code is structured to consider the addition of Dynamic
Discovery in later patches.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: I71f740192a31ae00f83014ca3e9e06b61ae4ecd5
Reviewed-on: http://review.whamcloud.com/20531
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    9 
 .../staging/lustre/include/linux/lnet/lib-types.h  |   10 
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   77 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   32 -
 drivers/staging/lustre/lnet/lnet/peer.c            |  907 +++++++++++---------
 drivers/staging/lustre/lnet/lnet/router.c          |    8 
 6 files changed, 600 insertions(+), 443 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 53a5ee8632a6..55bcd17cd4dc 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -647,13 +647,12 @@ u32 lnet_get_dlc_seq_locked(void);
 struct lnet_peer_ni *lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 						  struct lnet_peer_net *peer_net,
 						  struct lnet_peer_ni *prev);
-int lnet_find_or_create_peer_locked(lnet_nid_t dst_nid, int cpt,
-				    struct lnet_peer **peer);
-int lnet_nid2peerni_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt);
+struct lnet_peer *lnet_find_or_create_peer_locked(lnet_nid_t dst_nid, int cpt);
+struct lnet_peer_ni *lnet_nid2peerni_locked(lnet_nid_t nid, int cpt);
 struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
 void lnet_peer_net_added(struct lnet_net *net);
 lnet_nid_t lnet_peer_primary_nid(lnet_nid_t nid);
-void lnet_peer_tables_cleanup(struct lnet_ni *ni);
+void lnet_peer_tables_cleanup(struct lnet_net *net);
 void lnet_peer_uninit(void);
 int lnet_peer_tables_create(void);
 void lnet_debug_peer(lnet_nid_t nid);
@@ -664,7 +663,7 @@ bool lnet_peer_is_ni_pref_locked(struct lnet_peer_ni *lpni,
 int lnet_add_peer_ni_to_peer(lnet_nid_t key_nid, lnet_nid_t nid, bool mr);
 int lnet_del_peer_ni_from_peer(lnet_nid_t key_nid, lnet_nid_t nid);
 int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
-		       struct lnet_peer_ni_credit_info *peer_ni_info,
+		       bool *mr, struct lnet_peer_ni_credit_info *peer_ni_info,
 		       struct lnet_ioctl_element_stats *peer_ni_stats);
 int lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
 			  char alivness[LNET_MAX_STR_LEN],
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index e17ca716dce1..71ec0eaf8200 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -281,9 +281,9 @@ struct lnet_net {
 	/* chain on the ln_nets */
 	struct list_head	net_list;
 
-	/* net ID, which is compoed of
+	/* net ID, which is composed of
 	 * (net_type << 16) | net_num.
-	 * net_type can be one of the enumarated types defined in
+	 * net_type can be one of the enumerated types defined in
 	 * lnet/include/lnet/nidstr.h */
 	__u32			net_id;
 
@@ -513,11 +513,13 @@ struct lnet_peer_table {
 	/* /proc validity stamp */
 	int			 pt_version;
 	/* # peers extant */
-	int			 pt_number;
+	atomic_t		 pt_number;
 	/* # zombies to go to deathrow (and not there yet) */
 	int			 pt_zombies;
 	/* zombie peers */
-	struct list_head	 pt_deathrow;
+	struct list_head	 pt_zombie_list;
+	/* protect list and count */
+	spinlock_t		 pt_zombie_lock;
 	/* NID->peer hash */
 	struct list_head	*pt_hash;
 };
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index a01858374211..d3db4853c690 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1229,9 +1229,6 @@ lnet_shutdown_lndni(struct lnet_ni *ni)
 	for (i = 0; i < the_lnet.ln_nportals; i++)
 		lnet_clear_lazy_portal(ni, i, "Shutting down NI");
 
-	/* Do peer table cleanup for this ni */
-	lnet_peer_tables_cleanup(ni);
-
 	lnet_net_lock(LNET_LOCK_EX);
 	lnet_clear_zombies_nis_locked(net);
 	lnet_net_unlock(LNET_LOCK_EX);
@@ -1254,6 +1251,12 @@ lnet_shutdown_lndnet(struct lnet_net *net)
 		lnet_net_lock(LNET_LOCK_EX);
 	}
 
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	/* Do peer table cleanup for this net */
+	lnet_peer_tables_cleanup(net);
+
+	lnet_net_lock(LNET_LOCK_EX);
 	/*
 	 * decrement ref count on lnd only when the entire network goes
 	 * away
@@ -2580,12 +2583,15 @@ LNetCtl(unsigned int cmd, void *arg)
 		if (config->cfg_hdr.ioc_len < sizeof(*config))
 			return -EINVAL;
 
-		return lnet_get_route(config->cfg_count,
-				      &config->cfg_net,
-				      &config->cfg_config_u.cfg_route.rtr_hop,
-				      &config->cfg_nid,
-				      &config->cfg_config_u.cfg_route.rtr_flags,
-				      &config->cfg_config_u.cfg_route.rtr_priority);
+		mutex_lock(&the_lnet.ln_api_mutex);
+		rc = lnet_get_route(config->cfg_count,
+				    &config->cfg_net,
+				    &config->cfg_config_u.cfg_route.rtr_hop,
+				    &config->cfg_nid,
+				    &config->cfg_config_u.cfg_route.rtr_flags,
+				    &config->cfg_config_u.cfg_route.rtr_priority);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return rc;
 
 	case IOC_LIBCFS_GET_LOCAL_NI: {
 		struct lnet_ioctl_config_ni *cfg_ni;
@@ -2607,7 +2613,10 @@ LNetCtl(unsigned int cmd, void *arg)
 		tun_size = cfg_ni->lic_cfg_hdr.ioc_len - sizeof(*cfg_ni) -
 			sizeof(*stats);
 
-		return lnet_get_ni_config(cfg_ni, tun, stats, tun_size);
+		mutex_lock(&the_lnet.ln_api_mutex);
+		rc = lnet_get_ni_config(cfg_ni, tun, stats, tun_size);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return rc;
 	}
 
 	case IOC_LIBCFS_GET_NET: {
@@ -2618,7 +2627,10 @@ LNetCtl(unsigned int cmd, void *arg)
 		if (config->cfg_hdr.ioc_len < total)
 			return -EINVAL;
 
-		return lnet_get_net_config(config);
+		mutex_lock(&the_lnet.ln_api_mutex);
+		rc = lnet_get_net_config(config);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return rc;
 	}
 
 	case IOC_LIBCFS_GET_LNET_STATS: {
@@ -2627,7 +2639,9 @@ LNetCtl(unsigned int cmd, void *arg)
 		if (lnet_stats->st_hdr.ioc_len < sizeof(*lnet_stats))
 			return -EINVAL;
 
+		mutex_lock(&the_lnet.ln_api_mutex);
 		lnet_counters_get(&lnet_stats->st_cntrs);
+		mutex_unlock(&the_lnet.ln_api_mutex);
 		return 0;
 	}
 
@@ -2666,7 +2680,9 @@ LNetCtl(unsigned int cmd, void *arg)
 		numa = arg;
 		if (numa->nr_hdr.ioc_len != sizeof(*numa))
 			return -EINVAL;
+		mutex_lock(&the_lnet.ln_api_mutex);
 		lnet_numa_range = numa->nr_range;
+		mutex_unlock(&the_lnet.ln_api_mutex);
 		return 0;
 	}
 
@@ -2690,7 +2706,11 @@ LNetCtl(unsigned int cmd, void *arg)
 			return -EINVAL;
 
 		pool_cfg = (struct lnet_ioctl_pool_cfg *)config->cfg_bulk;
-		return lnet_get_rtr_pool_cfg(config->cfg_count, pool_cfg);
+
+		mutex_lock(&the_lnet.ln_api_mutex);
+		rc = lnet_get_rtr_pool_cfg(config->cfg_count, pool_cfg);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return rc;
 	}
 
 	case IOC_LIBCFS_ADD_PEER_NI: {
@@ -2699,9 +2719,13 @@ LNetCtl(unsigned int cmd, void *arg)
 		if (cfg->prcfg_hdr.ioc_len < sizeof(*cfg))
 			return -EINVAL;
 
-		return lnet_add_peer_ni_to_peer(cfg->prcfg_key_nid,
-						cfg->prcfg_cfg_nid,
-						cfg->prcfg_mr);
+		mutex_lock(&the_lnet.ln_api_mutex);
+		lnet_incr_dlc_seq();
+		rc = lnet_add_peer_ni_to_peer(cfg->prcfg_key_nid,
+					      cfg->prcfg_cfg_nid,
+					      cfg->prcfg_mr);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return rc;
 	}
 
 	case IOC_LIBCFS_DEL_PEER_NI: {
@@ -2710,8 +2734,12 @@ LNetCtl(unsigned int cmd, void *arg)
 		if (cfg->prcfg_hdr.ioc_len < sizeof(*cfg))
 			return -EINVAL;
 
-		return lnet_del_peer_ni_from_peer(cfg->prcfg_key_nid,
-						  cfg->prcfg_cfg_nid);
+		mutex_lock(&the_lnet.ln_api_mutex);
+		lnet_incr_dlc_seq();
+		rc = lnet_del_peer_ni_from_peer(cfg->prcfg_key_nid,
+						cfg->prcfg_cfg_nid);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return rc;
 	}
 
 	case IOC_LIBCFS_GET_PEER_INFO: {
@@ -2720,7 +2748,9 @@ LNetCtl(unsigned int cmd, void *arg)
 		if (peer_info->pr_hdr.ioc_len < sizeof(*peer_info))
 			return -EINVAL;
 
-		return lnet_get_peer_ni_info(peer_info->pr_count,
+		mutex_lock(&the_lnet.ln_api_mutex);
+		rc = lnet_get_peer_ni_info(
+			peer_info->pr_count,
 			&peer_info->pr_nid,
 			peer_info->pr_lnd_u.pr_peer_credits.cr_aliveness,
 			&peer_info->pr_lnd_u.pr_peer_credits.cr_ncpt,
@@ -2730,6 +2760,8 @@ LNetCtl(unsigned int cmd, void *arg)
 			&peer_info->pr_lnd_u.pr_peer_credits.cr_peer_rtr_credits,
 			&peer_info->pr_lnd_u.pr_peer_credits.cr_peer_min_rtr_credits,
 			&peer_info->pr_lnd_u.pr_peer_credits.cr_peer_tx_qnob);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return rc;
 	}
 
 	case IOC_LIBCFS_GET_PEER_NI: {
@@ -2746,9 +2778,12 @@ LNetCtl(unsigned int cmd, void *arg)
 		lpni_stats = (struct lnet_ioctl_element_stats *)
 			     (cfg->prcfg_bulk + sizeof(*lpni_cri));
 
-		return lnet_get_peer_info(cfg->prcfg_idx, &cfg->prcfg_key_nid,
-					  &cfg->prcfg_cfg_nid, lpni_cri,
-					  lpni_stats);
+		mutex_lock(&the_lnet.ln_api_mutex);
+		rc = lnet_get_peer_info(cfg->prcfg_idx, &cfg->prcfg_key_nid,
+					&cfg->prcfg_cfg_nid, &cfg->prcfg_mr,
+					lpni_cri, lpni_stats);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return rc;
 	}
 
 	case IOC_LIBCFS_NOTIFY_ROUTER: {
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 3f28f3b87176..5d9acce26287 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1156,10 +1156,10 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	lpni = NULL;
 	seq = lnet_get_dlc_seq_locked();
 
-	rc = lnet_find_or_create_peer_locked(dst_nid, cpt, &peer);
-	if (rc != 0) {
+	peer = lnet_find_or_create_peer_locked(dst_nid, cpt);
+	if (IS_ERR(peer)) {
 		lnet_net_unlock(cpt);
-		return rc;
+		return PTR_ERR(peer);
 	}
 
 	/* If peer is not healthy then can not send anything to it */
@@ -1364,13 +1364,6 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 			best_credits = ni->ni_tx_queues[cpt]->tq_credits;
 		}
 	}
-	/*
-	 * Now that we selected the NI to use increment its sequence
-	 * number so the Round Robin algorithm will detect that it has
-	 * been used and pick the next NI.
-	 */
-	best_ni->ni_seq++;
-
 	/*
 	 * if the peer is not MR capable, then we should always send to it
 	 * using the first NI in the NET we determined.
@@ -1385,6 +1378,13 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		return -EINVAL;
 	}
 
+	/*
+	 * Now that we selected the NI to use increment its sequence
+	 * number so the Round Robin algorithm will detect that it has
+	 * been used and pick the next NI.
+	 */
+	best_ni->ni_seq++;
+
 	if (routing)
 		goto send;
 
@@ -1452,7 +1452,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		}
 
 		CDEBUG(D_NET, "Best route to %s via %s for %s %d\n",
-			libcfs_nid2str(lpni->lpni_nid),
+			libcfs_nid2str(dst_nid),
 			libcfs_nid2str(best_gw->lpni_nid),
 			lnet_msgtyp2str(msg->msg_type), msg->msg_len);
 
@@ -2065,6 +2065,7 @@ lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
 	lnet_pid_t dest_pid;
 	lnet_nid_t dest_nid;
 	lnet_nid_t src_nid;
+	struct lnet_peer_ni *lpni;
 	__u32 payload_length;
 	__u32 type;
 
@@ -2226,18 +2227,19 @@ lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
 	msg->msg_initiator = lnet_peer_primary_nid(src_nid);
 
 	lnet_net_lock(cpt);
-	rc = lnet_nid2peerni_locked(&msg->msg_rxpeer, from_nid, cpt);
-	if (rc) {
+	lpni = lnet_nid2peerni_locked(from_nid, cpt);
+	if (IS_ERR(lpni)) {
 		lnet_net_unlock(cpt);
-		CERROR("%s, src %s: Dropping %s (error %d looking up sender)\n",
+		CERROR("%s, src %s: Dropping %s (error %ld looking up sender)\n",
 		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
-		       lnet_msgtyp2str(type), rc);
+		       lnet_msgtyp2str(type), PTR_ERR(lpni));
 		kfree(msg);
 		if (rc == -ESHUTDOWN)
 			/* We are shutting down. Don't do anything more */
 			return 0;
 		goto drop;
 	}
+	msg->msg_rxpeer = lpni;
 	msg->msg_rxni = ni;
 	lnet_ni_addref_locked(ni, cpt);
 
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index f626a3fcf00e..c2a04526a59a 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -84,6 +84,8 @@ lnet_peer_tables_destroy(void)
 		if (!hash) /* not initialized */
 			break;
 
+		LASSERT(list_empty(&ptable->pt_zombie_list));
+
 		ptable->pt_hash = NULL;
 		for (j = 0; j < LNET_PEER_HASH_SIZE; j++)
 			LASSERT(list_empty(&hash[j]));
@@ -95,27 +97,179 @@ lnet_peer_tables_destroy(void)
 	the_lnet.ln_peer_tables = NULL;
 }
 
-void lnet_peer_uninit(void)
+static struct lnet_peer_ni *
+lnet_peer_ni_alloc(lnet_nid_t nid)
 {
+	struct lnet_peer_ni *lpni;
+	struct lnet_net *net;
 	int cpt;
-	struct lnet_peer_ni *lpni, *tmp;
-	struct lnet_peer_table *ptable = NULL;
 
-	/* remove all peer_nis from the remote peer and he hash list */
-	list_for_each_entry_safe(lpni, tmp, &the_lnet.ln_remote_peer_ni_list,
-				 lpni_on_remote_peer_ni_list) {
-		list_del_init(&lpni->lpni_on_remote_peer_ni_list);
-		lnet_peer_ni_decref_locked(lpni);
+	cpt = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
+
+	lpni = kzalloc_cpt(sizeof(*lpni), GFP_KERNEL, cpt);
+	if (!lpni)
+		return NULL;
 
-		cpt = lnet_cpt_of_nid_locked(lpni->lpni_nid, NULL);
-		ptable = the_lnet.ln_peer_tables[cpt];
-		ptable->pt_zombies++;
+	INIT_LIST_HEAD(&lpni->lpni_txq);
+	INIT_LIST_HEAD(&lpni->lpni_rtrq);
+	INIT_LIST_HEAD(&lpni->lpni_routes);
+	INIT_LIST_HEAD(&lpni->lpni_hashlist);
+	INIT_LIST_HEAD(&lpni->lpni_on_peer_net_list);
+	INIT_LIST_HEAD(&lpni->lpni_on_remote_peer_ni_list);
 
-		list_del_init(&lpni->lpni_hashlist);
-		lnet_peer_ni_decref_locked(lpni);
+	lpni->lpni_alive = !lnet_peers_start_down(); /* 1 bit!! */
+	lpni->lpni_last_alive = ktime_get_seconds(); /* assumes alive */
+	lpni->lpni_ping_feats = LNET_PING_FEAT_INVAL;
+	lpni->lpni_nid = nid;
+	lpni->lpni_cpt = cpt;
+	lnet_set_peer_ni_health_locked(lpni, true);
+
+	net = lnet_get_net_locked(LNET_NIDNET(nid));
+	lpni->lpni_net = net;
+	if (net) {
+		lpni->lpni_txcredits = net->net_tunables.lct_peer_tx_credits;
+		lpni->lpni_mintxcredits = lpni->lpni_txcredits;
+		lpni->lpni_rtrcredits = lnet_peer_buffer_credits(net);
+		lpni->lpni_minrtrcredits = lpni->lpni_rtrcredits;
+	} else {
+		/*
+		 * This peer_ni is not on a local network, so we
+		 * cannot add the credits here. In case the net is
+		 * added later, add the peer_ni to the remote peer ni
+		 * list so it can be easily found and revisited.
+		 */
+		/* FIXME: per-net implementation instead? */
+		atomic_inc(&lpni->lpni_refcount);
+		list_add_tail(&lpni->lpni_on_remote_peer_ni_list,
+			      &the_lnet.ln_remote_peer_ni_list);
 	}
 
+	/* TODO: update flags */
+
+	return lpni;
+}
+
+static struct lnet_peer_net *
+lnet_peer_net_alloc(u32 net_id)
+{
+	struct lnet_peer_net *lpn;
+
+	lpn = kzalloc_cpt(sizeof(*lpn), GFP_KERNEL, CFS_CPT_ANY);
+	if (!lpn)
+		return NULL;
+
+	INIT_LIST_HEAD(&lpn->lpn_on_peer_list);
+	INIT_LIST_HEAD(&lpn->lpn_peer_nis);
+	lpn->lpn_net_id = net_id;
+
+	return lpn;
+}
+
+static struct lnet_peer *
+lnet_peer_alloc(lnet_nid_t nid)
+{
+	struct lnet_peer *lp;
+
+	lp = kzalloc_cpt(sizeof(*lp), GFP_KERNEL, CFS_CPT_ANY);
+	if (!lp)
+		return NULL;
+
+	INIT_LIST_HEAD(&lp->lp_on_lnet_peer_list);
+	INIT_LIST_HEAD(&lp->lp_peer_nets);
+	lp->lp_primary_nid = nid;
+
+	/* TODO: update flags */
+
+	return lp;
+}
+
+static void
+lnet_try_destroy_peer_hierarchy_locked(struct lnet_peer_ni *lpni)
+{
+	struct lnet_peer_net *peer_net;
+	struct lnet_peer *peer;
+
+	/* TODO: could the below situation happen? accessing an already
+	 * destroyed peer?
+	 */
+	if (!lpni->lpni_peer_net ||
+	    !lpni->lpni_peer_net->lpn_peer)
+		return;
+
+	peer_net = lpni->lpni_peer_net;
+	peer = lpni->lpni_peer_net->lpn_peer;
+
+	list_del_init(&lpni->lpni_on_peer_net_list);
+	lpni->lpni_peer_net = NULL;
+
+	/* if peer_net is empty, then remove it from the peer */
+	if (list_empty(&peer_net->lpn_peer_nis)) {
+		list_del_init(&peer_net->lpn_on_peer_list);
+		peer_net->lpn_peer = NULL;
+		kfree(peer_net);
+
+		/* If the peer is empty then remove it from the
+		 * the_lnet.ln_peers.
+		 */
+		if (list_empty(&peer->lp_peer_nets)) {
+			list_del_init(&peer->lp_on_lnet_peer_list);
+			kfree(peer);
+		}
+	}
+}
+
+/* called with lnet_net_lock LNET_LOCK_EX held */
+static void
+lnet_peer_ni_del_locked(struct lnet_peer_ni *lpni)
+{
+	struct lnet_peer_table *ptable = NULL;
+
+	lnet_peer_remove_from_remote_list(lpni);
+
+	/* remove peer ni from the hash list. */
+	list_del_init(&lpni->lpni_hashlist);
+
+	/* decrement the ref count on the peer table */
+	ptable = the_lnet.ln_peer_tables[lpni->lpni_cpt];
+	LASSERT(atomic_read(&ptable->pt_number) > 0);
+	atomic_dec(&ptable->pt_number);
+
+	/*
+	 * The peer_ni can no longer be found with a lookup. But there
+	 * can be current users, so keep track of it on the zombie
+	 * list until the reference count has gone to zero.
+	 *
+	 * The last reference may be lost in a place where the
+	 * lnet_net_lock locks only a single cpt, and that cpt may not
+	 * be lpni->lpni_cpt. So the zombie list of this peer_table
+	 * has its own lock.
+	 */
+	spin_lock(&ptable->pt_zombie_lock);
+	list_add(&lpni->lpni_hashlist, &ptable->pt_zombie_list);
+	ptable->pt_zombies++;
+	spin_unlock(&ptable->pt_zombie_lock);
+
+	/* no need to keep this peer on the hierarchy anymore */
+	lnet_try_destroy_peer_hierarchy_locked(lpni);
+
+	/* decrement reference on peer */
+	lnet_peer_ni_decref_locked(lpni);
+}
+
+void lnet_peer_uninit(void)
+{
+	struct lnet_peer_ni *lpni, *tmp;
+
+	lnet_net_lock(LNET_LOCK_EX);
+
+	/* remove all peer_nis from the remote peer and the hash list */
+	list_for_each_entry_safe(lpni, tmp, &the_lnet.ln_remote_peer_ni_list,
+				 lpni_on_remote_peer_ni_list)
+		lnet_peer_ni_del_locked(lpni);
+
 	lnet_peer_tables_destroy();
+
+	lnet_net_unlock(LNET_LOCK_EX);
 }
 
 int
@@ -142,6 +296,9 @@ lnet_peer_tables_create(void)
 			return -ENOMEM;
 		}
 
+		spin_lock_init(&ptable->pt_zombie_lock);
+		INIT_LIST_HEAD(&ptable->pt_zombie_list);
+
 		for (j = 0; j < LNET_PEER_HASH_SIZE; j++)
 			INIT_LIST_HEAD(&hash[j]);
 		ptable->pt_hash = hash; /* sign of initialization */
@@ -151,34 +308,55 @@ lnet_peer_tables_create(void)
 }
 
 static void
-lnet_peer_table_cleanup_locked(struct lnet_ni *ni,
+lnet_peer_del_locked(struct lnet_peer *peer)
+{
+	struct lnet_peer_ni *lpni = NULL, *lpni2;
+
+	lpni = lnet_get_next_peer_ni_locked(peer, NULL, lpni);
+	while (lpni) {
+		lpni2 = lnet_get_next_peer_ni_locked(peer, NULL, lpni);
+		lnet_peer_ni_del_locked(lpni);
+		lpni = lpni2;
+	}
+}
+
+static void
+lnet_peer_table_cleanup_locked(struct lnet_net *net,
 			       struct lnet_peer_table *ptable)
 {
 	int i;
-	struct lnet_peer_ni *lp;
+	struct lnet_peer_ni *lpni;
 	struct lnet_peer_ni *tmp;
+	struct lnet_peer *peer;
 
 	for (i = 0; i < LNET_PEER_HASH_SIZE; i++) {
-		list_for_each_entry_safe(lp, tmp, &ptable->pt_hash[i],
+		list_for_each_entry_safe(lpni, tmp, &ptable->pt_hash[i],
 					 lpni_hashlist) {
-			if (ni && ni->ni_net != lp->lpni_net)
+			if (net && net != lpni->lpni_net)
 				continue;
-			list_del_init(&lp->lpni_hashlist);
-			/* Lose hash table's ref */
-			ptable->pt_zombies++;
-			lnet_peer_ni_decref_locked(lp);
+
+			/*
+			 * check if by removing this peer ni we should be
+			 * removing the entire peer.
+			 */
+			peer = lpni->lpni_peer_net->lpn_peer;
+
+			if (peer->lp_primary_nid == lpni->lpni_nid)
+				lnet_peer_del_locked(peer);
+			else
+				lnet_peer_ni_del_locked(lpni);
 		}
 	}
 }
 
 static void
-lnet_peer_table_finalize_wait_locked(struct lnet_peer_table *ptable,
-				     int cpt_locked)
+lnet_peer_ni_finalize_wait(struct lnet_peer_table *ptable)
 {
-	int i;
+	int i = 3;
 
-	for (i = 3; ptable->pt_zombies; i++) {
-		lnet_net_unlock(cpt_locked);
+	spin_lock(&ptable->pt_zombie_lock);
+	while (ptable->pt_zombies) {
+		spin_unlock(&ptable->pt_zombie_lock);
 
 		if (is_power_of_2(i)) {
 			CDEBUG(D_WARNING,
@@ -186,14 +364,14 @@ lnet_peer_table_finalize_wait_locked(struct lnet_peer_table *ptable,
 			       ptable->pt_zombies);
 		}
 		schedule_timeout_uninterruptible(HZ >> 1);
-		lnet_net_lock(cpt_locked);
+		spin_lock(&ptable->pt_zombie_lock);
 	}
+	spin_unlock(&ptable->pt_zombie_lock);
 }
 
 static void
-lnet_peer_table_del_rtrs_locked(struct lnet_ni *ni,
-				struct lnet_peer_table *ptable,
-				int cpt_locked)
+lnet_peer_table_del_rtrs_locked(struct lnet_net *net,
+				struct lnet_peer_table *ptable)
 {
 	struct lnet_peer_ni *lp;
 	struct lnet_peer_ni *tmp;
@@ -203,7 +381,7 @@ lnet_peer_table_del_rtrs_locked(struct lnet_ni *ni,
 	for (i = 0; i < LNET_PEER_HASH_SIZE; i++) {
 		list_for_each_entry_safe(lp, tmp, &ptable->pt_hash[i],
 					 lpni_hashlist) {
-			if (ni->ni_net != lp->lpni_net)
+			if (net != lp->lpni_net)
 				continue;
 
 			if (!lp->lpni_rtr_refcount)
@@ -211,27 +389,27 @@ lnet_peer_table_del_rtrs_locked(struct lnet_ni *ni,
 
 			lpni_nid = lp->lpni_nid;
 
-			lnet_net_unlock(cpt_locked);
+			lnet_net_unlock(LNET_LOCK_EX);
 			lnet_del_route(LNET_NIDNET(LNET_NID_ANY), lpni_nid);
-			lnet_net_lock(cpt_locked);
+			lnet_net_lock(LNET_LOCK_EX);
 		}
 	}
 }
 
 void
-lnet_peer_tables_cleanup(struct lnet_ni *ni)
+lnet_peer_tables_cleanup(struct lnet_net *net)
 {
 	struct lnet_peer_table *ptable;
 	int i;
 
-	LASSERT(the_lnet.ln_shutdown || ni);
+	LASSERT(the_lnet.ln_shutdown || net);
 	/*
 	 * If just deleting the peers for a NI, get rid of any routes these
 	 * peers are gateways for.
 	 */
 	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
 		lnet_net_lock(LNET_LOCK_EX);
-		lnet_peer_table_del_rtrs_locked(ni, ptable, i);
+		lnet_peer_table_del_rtrs_locked(net, ptable);
 		lnet_net_unlock(LNET_LOCK_EX);
 	}
 
@@ -240,16 +418,12 @@ lnet_peer_tables_cleanup(struct lnet_ni *ni)
 	 */
 	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
 		lnet_net_lock(LNET_LOCK_EX);
-		lnet_peer_table_cleanup_locked(ni, ptable);
+		lnet_peer_table_cleanup_locked(net, ptable);
 		lnet_net_unlock(LNET_LOCK_EX);
 	}
 
-	/* Wait until all peers have been destroyed. */
-	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
-		lnet_net_lock(LNET_LOCK_EX);
-		lnet_peer_table_finalize_wait_locked(ptable, i);
-		lnet_net_unlock(LNET_LOCK_EX);
-	}
+	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables)
+		lnet_peer_ni_finalize_wait(ptable);
 }
 
 static struct lnet_peer_ni *
@@ -286,25 +460,23 @@ lnet_find_peer_ni_locked(lnet_nid_t nid)
 	return lpni;
 }
 
-int
-lnet_find_or_create_peer_locked(lnet_nid_t dst_nid, int cpt,
-				struct lnet_peer **peer)
+struct lnet_peer *
+lnet_find_or_create_peer_locked(lnet_nid_t dst_nid, int cpt)
 {
 	struct lnet_peer_ni *lpni;
+	struct lnet_peer *lp;
 
 	lpni = lnet_find_peer_ni_locked(dst_nid);
 	if (!lpni) {
-		int rc;
-
-		rc = lnet_nid2peerni_locked(&lpni, dst_nid, cpt);
-		if (rc != 0)
-			return rc;
+		lpni = lnet_nid2peerni_locked(dst_nid, cpt);
+		if (IS_ERR(lpni))
+			return ERR_CAST(lpni);
 	}
 
-	*peer = lpni->lpni_peer_net->lpn_peer;
+	lp = lpni->lpni_peer_net->lpn_peer;
 	lnet_peer_ni_decref_locked(lpni);
 
-	return 0;
+	return lp;
 }
 
 struct lnet_peer_ni *
@@ -412,269 +584,318 @@ lnet_peer_primary_nid(lnet_nid_t nid)
 	return primary_nid;
 }
 
-static void
-lnet_try_destroy_peer_hierarchy_locked(struct lnet_peer_ni *lpni)
+struct lnet_peer_net *
+lnet_peer_get_net_locked(struct lnet_peer *peer, u32 net_id)
 {
 	struct lnet_peer_net *peer_net;
-	struct lnet_peer *peer;
+	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_on_peer_list) {
+		if (peer_net->lpn_net_id == net_id)
+			return peer_net;
+	}
+	return NULL;
+}
 
-	/* TODO: could the below situation happen? accessing an already
-	 * destroyed peer?
+static int
+lnet_peer_setup_hierarchy(struct lnet_peer *lp, struct lnet_peer_ni
+	 *lpni,
+			  lnet_nid_t nid)
+{
+	struct lnet_peer_net *lpn = NULL;
+	struct lnet_peer_table *ptable;
+	u32 net_id = LNET_NIDNET(nid);
+
+	/*
+	 * Create the peer_ni, peer_net, and peer if they don't exist
+	 * yet.
 	 */
-	if (!lpni->lpni_peer_net ||
-	    !lpni->lpni_peer_net->lpn_peer)
-		return;
+	if (lp) {
+		lpn = lnet_peer_get_net_locked(lp, net_id);
+	} else {
+		lp = lnet_peer_alloc(nid);
+		if (!lp)
+			goto out_enomem;
+	}
 
-	peer_net = lpni->lpni_peer_net;
-	peer = lpni->lpni_peer_net->lpn_peer;
+	if (!lpn) {
+		lpn = lnet_peer_net_alloc(net_id);
+		if (!lpn)
+			goto out_maybe_free_lp;
+	}
 
-	list_del_init(&lpni->lpni_on_peer_net_list);
-	lpni->lpni_peer_net = NULL;
+	if (!lpni) {
+		lpni = lnet_peer_ni_alloc(nid);
+		if (!lpni)
+			goto out_maybe_free_lpn;
+	}
 
-	/* if peer_net is empty, then remove it from the peer */
-	if (list_empty(&peer_net->lpn_peer_nis)) {
-		list_del_init(&peer_net->lpn_on_peer_list);
-		peer_net->lpn_peer = NULL;
-		kfree(peer_net);
+	/* Install the new peer_ni */
+	lnet_net_lock(LNET_LOCK_EX);
+	/* Add peer_ni to global peer table hash, if necessary. */
+	if (list_empty(&lpni->lpni_hashlist)) {
+		ptable = the_lnet.ln_peer_tables[lpni->lpni_cpt];
+		list_add_tail(&lpni->lpni_hashlist,
+			      &ptable->pt_hash[lnet_nid2peerhash(nid)]);
+		ptable->pt_version++;
+		atomic_inc(&ptable->pt_number);
+		atomic_inc(&lpni->lpni_refcount);
+	}
 
-		/* If the peer is empty then remove it from the
-		 * the_lnet.ln_peers
-		 */
-		if (list_empty(&peer->lp_peer_nets)) {
-			list_del_init(&peer->lp_on_lnet_peer_list);
-			kfree(peer);
-		}
+	/* Detach the peer_ni from an existing peer, if necessary. */
+	if (lpni->lpni_peer_net && lpni->lpni_peer_net->lpn_peer != lp)
+		lnet_try_destroy_peer_hierarchy_locked(lpni);
+
+	/* Add peer_ni to peer_net */
+	lpni->lpni_peer_net = lpn;
+	list_add_tail(&lpni->lpni_on_peer_net_list, &lpn->lpn_peer_nis);
+
+	/* Add peer_net to peer */
+	if (!lpn->lpn_peer) {
+		lpn->lpn_peer = lp;
+		list_add_tail(&lpn->lpn_on_peer_list, &lp->lp_peer_nets);
 	}
+
+	/* Add peer to global peer list */
+	if (list_empty(&lp->lp_on_lnet_peer_list))
+		list_add_tail(&lp->lp_on_lnet_peer_list, &the_lnet.ln_peers);
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	return 0;
+
+out_maybe_free_lpn:
+	if (list_empty(&lpn->lpn_on_peer_list))
+		kfree(lpn);
+out_maybe_free_lp:
+	if (list_empty(&lp->lp_on_lnet_peer_list))
+		kfree(lp);
+out_enomem:
+	return -ENOMEM;
 }
 
 static int
-lnet_build_peer_hierarchy(struct lnet_peer_ni *lpni)
+lnet_add_prim_lpni(lnet_nid_t nid)
 {
+	int rc;
 	struct lnet_peer *peer;
-	struct lnet_peer_net *peer_net;
-	__u32 lpni_net = LNET_NIDNET(lpni->lpni_nid);
-
-	peer = NULL;
-	peer_net = NULL;
+	struct lnet_peer_ni *lpni;
 
-	peer = kzalloc(sizeof(*peer), GFP_KERNEL);
-	if (!peer)
-		return -ENOMEM;
+	LASSERT(nid != LNET_NID_ANY);
 
-	peer_net = kzalloc(sizeof(*peer_net), GFP_KERNEL);
-	if (!peer_net) {
-		kfree(peer);
-		return -ENOMEM;
+	/*
+	 * lookup the NID and its peer
+	 *  if the peer doesn't exist, create it.
+	 *  if this is a non-MR peer then change its state to MR and exit.
+	 *  if this is an MR peer and it's a primary NI: NO-OP.
+	 *  if this is an MR peer and it's not a primary NI. Operation not
+	 *     allowed.
+	 *
+	 * The adding and deleting of peer nis is being serialized through
+	 * the api_mutex. So we can look up peers with the mutex locked
+	 * safely. Only when we need to change the ptable, do we need to
+	 * exclusively lock the lnet_net_lock()
+	 */
+	lpni = lnet_find_peer_ni_locked(nid);
+	if (!lpni) {
+		rc = lnet_peer_setup_hierarchy(NULL, NULL, nid);
+		if (rc != 0)
+			return rc;
+		lpni = lnet_find_peer_ni_locked(nid);
 	}
 
-	INIT_LIST_HEAD(&peer->lp_on_lnet_peer_list);
-	INIT_LIST_HEAD(&peer->lp_peer_nets);
-	INIT_LIST_HEAD(&peer_net->lpn_on_peer_list);
-	INIT_LIST_HEAD(&peer_net->lpn_peer_nis);
+	LASSERT(lpni);
 
-	/* build the hierarchy */
-	peer_net->lpn_net_id = lpni_net;
-	peer_net->lpn_peer = peer;
-	lpni->lpni_peer_net = peer_net;
-	peer->lp_primary_nid = lpni->lpni_nid;
-	peer->lp_multi_rail = false;
-	list_add_tail(&peer_net->lpn_on_peer_list, &peer->lp_peer_nets);
-	list_add_tail(&lpni->lpni_on_peer_net_list, &peer_net->lpn_peer_nis);
-	list_add_tail(&peer->lp_on_lnet_peer_list, &the_lnet.ln_peers);
+	lnet_peer_ni_decref_locked(lpni);
 
-	return 0;
-}
+	peer = lpni->lpni_peer_net->lpn_peer;
 
-struct lnet_peer_net *
-lnet_peer_get_net_locked(struct lnet_peer *peer, u32 net_id)
-{
-	struct lnet_peer_net *peer_net;
+	/*
+	 * If we found a lpni with the same nid as the NID we're trying to
+	 * create, then we're trying to create an already existing lpni
+	 * that belongs to a different peer
+	 */
+	if (peer->lp_primary_nid != nid)
+		return -EEXIST;
 
-	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_on_peer_list) {
-		if (peer_net->lpn_net_id == net_id)
-			return peer_net;
-	}
-	return NULL;
+	/*
+	 * if we found an lpni that is not a multi-rail, which could occur
+	 * if lpni is already created as a non-mr lpni or we just created
+	 * it, then make sure you indicate that this lpni is a primary mr
+	 * capable peer.
+	 *
+	 * TODO: update flags if necessary
+	 */
+	if (!peer->lp_multi_rail && peer->lp_primary_nid == nid)
+		peer->lp_multi_rail = true;
+
+	return rc;
 }
 
-/*
- * given the key nid find the peer to add the new peer NID to. If the key
- * nid is NULL, then create a new peer, but first make sure that the NID
- * is unique
- */
-int
-lnet_add_peer_ni_to_peer(lnet_nid_t key_nid, lnet_nid_t nid, bool mr)
+static int
+lnet_add_peer_ni_to_prim_lpni(lnet_nid_t key_nid, lnet_nid_t nid)
 {
-	struct lnet_peer_ni *lpni, *lpni2;
-	struct lnet_peer *peer;
-	struct lnet_peer_net *peer_net, *pn;
-	int cpt, cpt2, rc;
-	struct lnet_peer_table *ptable = NULL;
-	__u32 net_id = LNET_NIDNET(nid);
+	struct lnet_peer *peer, *primary_peer;
+	struct lnet_peer_ni *lpni = NULL, *klpni = NULL;
 
-	if (nid == LNET_NID_ANY)
-		return -EINVAL;
+	LASSERT(key_nid != LNET_NID_ANY && nid != LNET_NID_ANY);
+
+	/*
+	 * key nid must be created by this point. If not then this
+	 * operation is not permitted
+	 */
+	klpni = lnet_find_peer_ni_locked(key_nid);
+	if (!klpni)
+		return -ENOENT;
+
+	lnet_peer_ni_decref_locked(klpni);
+
+	primary_peer = klpni->lpni_peer_net->lpn_peer;
 
-	/* check that nid is unique */
-	cpt = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
-	lnet_net_lock(cpt);
 	lpni = lnet_find_peer_ni_locked(nid);
 	if (lpni) {
 		lnet_peer_ni_decref_locked(lpni);
-		lnet_net_unlock(cpt);
-		return -EEXIST;
-	}
-	lnet_net_unlock(cpt);
 
-	if (key_nid != LNET_NID_ANY) {
-		cpt2 = lnet_nid_cpt_hash(key_nid, LNET_CPT_NUMBER);
-		lnet_net_lock(cpt2);
-		lpni = lnet_find_peer_ni_locked(key_nid);
-		if (!lpni) {
-			lnet_net_unlock(cpt2);
-			/* key_nid refers to a non-existent peer_ni.*/
-			return -EINVAL;
-		}
 		peer = lpni->lpni_peer_net->lpn_peer;
-		peer->lp_multi_rail = mr;
-		lnet_peer_ni_decref_locked(lpni);
-		lnet_net_unlock(cpt2);
-	} else {
-		lnet_net_lock(LNET_LOCK_EX);
-		rc = lnet_nid2peerni_locked(&lpni, nid, LNET_LOCK_EX);
-		if (rc == 0) {
-			lpni->lpni_peer_net->lpn_peer->lp_multi_rail = mr;
-			lnet_peer_ni_decref_locked(lpni);
+		/*
+		 * lpni already exists in the system but it belongs to
+		 * a different peer. We can't re-added it
+		 */
+		if (peer->lp_primary_nid != key_nid && peer->lp_multi_rail) {
+			CERROR("Cannot add NID %s owned by peer %s to peer %s\n",
+			       libcfs_nid2str(lpni->lpni_nid),
+			       libcfs_nid2str(peer->lp_primary_nid),
+			       libcfs_nid2str(key_nid));
+			return -EEXIST;
+		} else if (peer->lp_primary_nid == key_nid) {
+			/*
+			 * found a peer_ni that is already part of the
+			 * peer. This is a no-op operation.
+			 */
+			return 0;
 		}
-		lnet_net_unlock(LNET_LOCK_EX);
-		return rc;
-	}
-
-	lpni = kzalloc_cpt(sizeof(*lpni), GFP_KERNEL, cpt);
-	if (!lpni)
-		return -ENOMEM;
 
-	INIT_LIST_HEAD(&lpni->lpni_txq);
-	INIT_LIST_HEAD(&lpni->lpni_rtrq);
-	INIT_LIST_HEAD(&lpni->lpni_routes);
-	INIT_LIST_HEAD(&lpni->lpni_hashlist);
-	INIT_LIST_HEAD(&lpni->lpni_on_peer_net_list);
-	INIT_LIST_HEAD(&lpni->lpni_on_remote_peer_ni_list);
+		/*
+		 * TODO: else if (peer->lp_primary_nid != key_nid &&
+		 *		  !peer->lp_multi_rail)
+		 * peer is not an MR peer and it will be moved in the next
+		 * step to klpni, so update its flags accordingly.
+		 * lnet_move_peer_ni()
+		 */
 
-	lpni->lpni_alive = !lnet_peers_start_down(); /* 1 bit!! */
-	lpni->lpni_last_alive = ktime_get_seconds(); /* assumes alive */
-	lpni->lpni_ping_feats = LNET_PING_FEAT_INVAL;
-	lpni->lpni_nid = nid;
-	lpni->lpni_cpt = cpt;
-	lnet_set_peer_ni_health_locked(lpni, true);
+		/*
+		 * TODO: call lnet_update_peer() from here to update the
+		 * flags. This is the case when the lpni you're trying to
+		 * add is already part of the peer. This could've been
+		 * added by the DD previously, so go ahead and do any
+		 * updates to the state if necessary
+		 */
 
-	/* allocate here in case we need to add a new peer_net */
-	peer_net = NULL;
-	peer_net = kzalloc(sizeof(*peer_net), GFP_KERNEL);
-	if (!peer_net) {
-		rc = -ENOMEM;
-		kfree(lpni);
-		return rc;
 	}
 
-	lnet_net_lock(LNET_LOCK_EX);
+	/*
+	 * When we get here we either have found an existing lpni, which
+	 * we can switch to the new peer. Or we need to create one and
+	 * add it to the new peer
+	 */
+	return lnet_peer_setup_hierarchy(primary_peer, lpni, nid);
+}
 
-	ptable = the_lnet.ln_peer_tables[cpt];
-	ptable->pt_number++;
-
-	lpni2 = lnet_find_peer_ni_locked(nid);
-	if (lpni2) {
-		lnet_peer_ni_decref_locked(lpni2);
-		/* sanity check that lpni2's peer is what we expect */
-		if (lpni2->lpni_peer_net->lpn_peer != peer)
-			rc = -EEXIST;
-		else
-			rc = -EINVAL;
-
-		ptable->pt_number--;
-		/* another thread has already added it */
-		lnet_net_unlock(LNET_LOCK_EX);
-		kfree(peer_net);
-		return rc;
-	}
+/*
+ * lpni creation initiated due to traffic either sending or receiving.
+ */
+static int
+lnet_peer_ni_traffic_add(lnet_nid_t nid)
+{
+	struct lnet_peer_ni *lpni;
+	int rc = 0;
 
-	lpni->lpni_net = lnet_get_net_locked(LNET_NIDNET(lpni->lpni_nid));
-	if (lpni->lpni_net) {
-		lpni->lpni_txcredits =
-			lpni->lpni_mintxcredits =
-			lpni->lpni_net->net_tunables.lct_peer_tx_credits;
-		lpni->lpni_rtrcredits =
-			lpni->lpni_minrtrcredits =
-			lnet_peer_buffer_credits(lpni->lpni_net);
-	} else {
+	if (nid == LNET_NID_ANY)
+		return -EINVAL;
+
+	/* lnet_net_lock is not needed here because ln_api_lock is held */
+	lpni = lnet_find_peer_ni_locked(nid);
+	if (lpni) {
 		/*
-		 * if you're adding a peer which is not on a local network
-		 * then we can't assign any of the credits. It won't be
-		 * picked for sending anyway. Eventually a network can be
-		 * added, in this case we need to revisit this peer and
-		 * update its credits.
+		 * TODO: lnet_update_primary_nid() but not all of it
+		 * only indicate if we're converting this to MR capable
+		 * Can happen due to DD
 		 */
-
-		/* increment refcount for remote peer list */
-		atomic_inc(&lpni->lpni_refcount);
-		list_add_tail(&lpni->lpni_on_remote_peer_ni_list,
-			      &the_lnet.ln_remote_peer_ni_list);
+		lnet_peer_ni_decref_locked(lpni);
+	} else {
+		rc = lnet_peer_setup_hierarchy(NULL, NULL, nid);
 	}
 
-	/* increment refcount for peer on hash list */
-	atomic_inc(&lpni->lpni_refcount);
+	return rc;
+}
 
-	list_add_tail(&lpni->lpni_hashlist,
-		      &ptable->pt_hash[lnet_nid2peerhash(nid)]);
-	ptable->pt_version++;
+static int
+lnet_peer_ni_add_non_mr(lnet_nid_t nid)
+{
+	struct lnet_peer_ni *lpni;
 
-	/* add the lpni to a net */
-	list_for_each_entry(pn, &peer->lp_peer_nets, lpn_on_peer_list) {
-		if (pn->lpn_net_id == net_id) {
-			list_add_tail(&lpni->lpni_on_peer_net_list,
-				      &pn->lpn_peer_nis);
-			lpni->lpni_peer_net = pn;
-			lnet_net_unlock(LNET_LOCK_EX);
-			kfree(peer_net);
-			return 0;
-		}
+	lpni = lnet_find_peer_ni_locked(nid);
+	if (lpni) {
+		CERROR("Cannot add %s as non-mr when it already exists\n",
+		       libcfs_nid2str(nid));
+		lnet_peer_ni_decref_locked(lpni);
+		return -EEXIST;
 	}
 
-	INIT_LIST_HEAD(&peer_net->lpn_on_peer_list);
-	INIT_LIST_HEAD(&peer_net->lpn_peer_nis);
+	return lnet_peer_setup_hierarchy(NULL, NULL, nid);
+}
 
-	/* build the hierarchy */
-	peer_net->lpn_net_id = net_id;
-	peer_net->lpn_peer = peer;
-	lpni->lpni_peer_net = peer_net;
-	list_add_tail(&lpni->lpni_on_peer_net_list, &peer_net->lpn_peer_nis);
-	list_add_tail(&peer_net->lpn_on_peer_list, &peer->lp_peer_nets);
+/*
+ * This API handles the following combinations:
+ *	Create a primary NI if only the key_nid is provided
+ *	Create or add an lpni to a primary NI. Primary NI must've already
+ *	been created
+ *	Create a non-MR peer.
+ */
+int
+lnet_add_peer_ni_to_peer(lnet_nid_t key_nid, lnet_nid_t nid, bool mr)
+{
+	/*
+	 * Caller trying to setup an MR like peer hierarchy but
+	 * specifying it to be non-MR. This is not allowed.
+	 */
+	if (key_nid != LNET_NID_ANY &&
+	    nid != LNET_NID_ANY && !mr)
+		return -EPERM;
+
+	/* Add the primary NID of a peer */
+	if (key_nid != LNET_NID_ANY &&
+	    nid == LNET_NID_ANY && mr)
+		return lnet_add_prim_lpni(key_nid);
+
+	/* Add a NID to an existing peer */
+	if (key_nid != LNET_NID_ANY &&
+	    nid != LNET_NID_ANY && mr)
+		return lnet_add_peer_ni_to_prim_lpni(key_nid, nid);
+
+	/* Add a non-MR peer NI */
+	if (((key_nid != LNET_NID_ANY &&
+	      nid == LNET_NID_ANY) ||
+	     (key_nid == LNET_NID_ANY &&
+	      nid != LNET_NID_ANY)) && !mr)
+		return lnet_peer_ni_add_non_mr(key_nid != LNET_NID_ANY ?
+							 key_nid : nid);
 
-	lnet_net_unlock(LNET_LOCK_EX);
 	return 0;
 }
 
 int
 lnet_del_peer_ni_from_peer(lnet_nid_t key_nid, lnet_nid_t nid)
 {
-	int cpt;
 	lnet_nid_t local_nid;
 	struct lnet_peer *peer;
-	struct lnet_peer_ni *lpni, *lpni2;
-	struct lnet_peer_table *ptable = NULL;
+	struct lnet_peer_ni *lpni;
 
 	if (key_nid == LNET_NID_ANY)
 		return -EINVAL;
 
 	local_nid = (nid != LNET_NID_ANY) ? nid : key_nid;
-	cpt = lnet_nid_cpt_hash(local_nid, LNET_CPT_NUMBER);
-	lnet_net_lock(LNET_LOCK_EX);
 
 	lpni = lnet_find_peer_ni_locked(local_nid);
-	if (!lpni) {
-		lnet_net_unlock(cpt);
+	if (!lpni)
 		return -EINVAL;
-	}
 	lnet_peer_ni_decref_locked(lpni);
 
 	peer = lpni->lpni_peer_net->lpn_peer;
@@ -685,30 +906,15 @@ lnet_del_peer_ni_from_peer(lnet_nid_t key_nid, lnet_nid_t nid)
 		 * deleting the primary ni is equivalent to deleting the
 		 * entire peer
 		 */
-		lpni = NULL;
-		lpni = lnet_get_next_peer_ni_locked(peer, NULL, lpni);
-		while (lpni) {
-			lpni2 = lnet_get_next_peer_ni_locked(peer, NULL, lpni);
-			cpt = lnet_nid_cpt_hash(lpni->lpni_nid,
-						LNET_CPT_NUMBER);
-			lnet_peer_remove_from_remote_list(lpni);
-			ptable = the_lnet.ln_peer_tables[cpt];
-			ptable->pt_zombies++;
-			list_del_init(&lpni->lpni_hashlist);
-			lnet_peer_ni_decref_locked(lpni);
-			lpni = lpni2;
-		}
+		lnet_net_lock(LNET_LOCK_EX);
+		lnet_peer_del_locked(peer);
 		lnet_net_unlock(LNET_LOCK_EX);
 
 		return 0;
 	}
 
-	lnet_peer_remove_from_remote_list(lpni);
-	cpt = lnet_nid_cpt_hash(lpni->lpni_nid, LNET_CPT_NUMBER);
-	ptable = the_lnet.ln_peer_tables[cpt];
-	ptable->pt_zombies++;
-	list_del_init(&lpni->lpni_hashlist);
-	lnet_peer_ni_decref_locked(lpni);
+	lnet_net_lock(LNET_LOCK_EX);
+	lnet_peer_ni_del_locked(lpni);
 	lnet_net_unlock(LNET_LOCK_EX);
 
 	return 0;
@@ -722,159 +928,70 @@ lnet_destroy_peer_ni_locked(struct lnet_peer_ni *lpni)
 	LASSERT(atomic_read(&lpni->lpni_refcount) == 0);
 	LASSERT(lpni->lpni_rtr_refcount == 0);
 	LASSERT(list_empty(&lpni->lpni_txq));
-	LASSERT(list_empty(&lpni->lpni_hashlist));
 	LASSERT(lpni->lpni_txqnob == 0);
-	LASSERT(lpni->lpni_peer_net);
-	LASSERT(lpni->lpni_peer_net->lpn_peer);
-
-	ptable = the_lnet.ln_peer_tables[lpni->lpni_cpt];
-	LASSERT(ptable->pt_number > 0);
-	ptable->pt_number--;
 
 	lpni->lpni_net = NULL;
 
-	lnet_try_destroy_peer_hierarchy_locked(lpni);
+	/* remove the peer ni from the zombie list */
+	ptable = the_lnet.ln_peer_tables[lpni->lpni_cpt];
+	spin_lock(&ptable->pt_zombie_lock);
+	list_del_init(&lpni->lpni_hashlist);
+	ptable->pt_zombies--;
+	spin_unlock(&ptable->pt_zombie_lock);
 
 	kfree(lpni);
-
-	LASSERT(ptable->pt_zombies > 0);
-	ptable->pt_zombies--;
 }
 
-int
-lnet_nid2peerni_locked(struct lnet_peer_ni **lpnip, lnet_nid_t nid, int cpt)
+struct lnet_peer_ni *
+lnet_nid2peerni_locked(lnet_nid_t nid, int cpt)
 {
 	struct lnet_peer_table *ptable;
 	struct lnet_peer_ni *lpni = NULL;
-	struct lnet_peer_ni *lpni2;
 	int cpt2;
-	int rc = 0;
+	int rc;
 
-	*lpnip = NULL;
 	if (the_lnet.ln_shutdown) /* it's shutting down */
-		return -ESHUTDOWN;
+		return ERR_PTR(-ESHUTDOWN);
 
 	/*
 	 * calculate cpt2 with the standard hash function
-	 * This cpt2 becomes the slot where we'll find or create the peer.
+	 * This cpt2 is the slot where we'll find or create the peer.
 	 */
 	cpt2 = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
-
-	/*
-	 * Any changes to the peer tables happen under exclusive write
-	 * lock. Any reads to the peer tables can be done via a standard
-	 * CPT read lock.
-	 */
-	if (cpt != LNET_LOCK_EX) {
-		lnet_net_unlock(cpt);
-		lnet_net_lock(LNET_LOCK_EX);
-	}
-
 	ptable = the_lnet.ln_peer_tables[cpt2];
 	lpni = lnet_get_peer_ni_locked(ptable, nid);
-	if (lpni) {
-		*lpnip = lpni;
-		if (cpt != LNET_LOCK_EX) {
-			lnet_net_unlock(LNET_LOCK_EX);
-			lnet_net_lock(cpt);
-		}
-		return 0;
-	}
+	if (lpni)
+		return lpni;
 
+	/* Slow path: serialized using the ln_api_mutex. */
+	lnet_net_unlock(cpt);
+	mutex_lock(&the_lnet.ln_api_mutex);
 	/*
-	 * take extra refcount in case another thread has shutdown LNet
-	 * and destroyed locks and peer-table before I finish the allocation
+	 * Shutdown is only set under the ln_api_lock, so a single
+	 * check here is sufficent.
+	 *
+	 * lnet_add_nid_to_peer() also handles the case where we've
+	 * raced and a different thread added the NID.
 	 */
-	ptable->pt_number++;
-	lnet_net_unlock(LNET_LOCK_EX);
-
-	lpni = kzalloc_cpt(sizeof(*lpni), GFP_KERNEL, cpt2);
-	if (!lpni) {
-		rc = -ENOMEM;
-		lnet_net_lock(cpt);
-		goto out;
-	}
-
-	INIT_LIST_HEAD(&lpni->lpni_txq);
-	INIT_LIST_HEAD(&lpni->lpni_rtrq);
-	INIT_LIST_HEAD(&lpni->lpni_routes);
-	INIT_LIST_HEAD(&lpni->lpni_hashlist);
-	INIT_LIST_HEAD(&lpni->lpni_on_peer_net_list);
-	INIT_LIST_HEAD(&lpni->lpni_on_remote_peer_ni_list);
-
-	lpni->lpni_alive = !lnet_peers_start_down(); /* 1 bit!! */
-	lpni->lpni_last_alive = ktime_get_seconds(); /* assumes alive */
-	lpni->lpni_ping_feats = LNET_PING_FEAT_INVAL;
-	lpni->lpni_nid = nid;
-	lpni->lpni_cpt = cpt2;
-	atomic_set(&lpni->lpni_refcount, 2);	/* 1 for caller; 1 for hash */
-
-	rc = lnet_build_peer_hierarchy(lpni);
-	if (rc != 0)
-		goto out;
-
-	lnet_net_lock(LNET_LOCK_EX);
-
 	if (the_lnet.ln_shutdown) {
-		rc = -ESHUTDOWN;
-		goto out;
-	}
-
-	lpni2 = lnet_get_peer_ni_locked(ptable, nid);
-	if (lpni2) {
-		*lpnip = lpni2;
-		goto out;
+		lpni = ERR_PTR(-ESHUTDOWN);
+		goto out_mutex_unlock;
 	}
 
-	lpni->lpni_net = lnet_get_net_locked(LNET_NIDNET(lpni->lpni_nid));
-	if (lpni->lpni_net) {
-		lpni->lpni_txcredits =
-			lpni->lpni_mintxcredits =
-			lpni->lpni_net->net_tunables.lct_peer_tx_credits;
-		lpni->lpni_rtrcredits =
-			lpni->lpni_minrtrcredits =
-			lnet_peer_buffer_credits(lpni->lpni_net);
-	} else {
-		/*
-		 * if you're adding a peer which is not on a local network
-		 * then we can't assign any of the credits. It won't be
-		 * picked for sending anyway. Eventually a network can be
-		 * added, in this case we need to revisit this peer and
-		 * update its credits.
-		 */
-
-		CDEBUG(D_NET, "peer_ni %s is not directly connected\n",
-		       libcfs_nid2str(nid));
-		/* increment refcount for remote peer list */
-		atomic_inc(&lpni->lpni_refcount);
-		list_add_tail(&lpni->lpni_on_remote_peer_ni_list,
-			      &the_lnet.ln_remote_peer_ni_list);
+	rc = lnet_peer_ni_traffic_add(nid);
+	if (rc) {
+		lpni = ERR_PTR(rc);
+		goto out_mutex_unlock;
 	}
 
-	lnet_set_peer_ni_health_locked(lpni, true);
-
-	list_add_tail(&lpni->lpni_hashlist,
-		      &ptable->pt_hash[lnet_nid2peerhash(nid)]);
-	ptable->pt_version++;
-	*lpnip = lpni;
+	lpni = lnet_get_peer_ni_locked(ptable, nid);
+	LASSERT(lpni);
 
-	if (cpt != LNET_LOCK_EX) {
-		lnet_net_unlock(LNET_LOCK_EX);
-		lnet_net_lock(cpt);
-	}
+out_mutex_unlock:
+	mutex_unlock(&the_lnet.ln_api_mutex);
+	lnet_net_lock(cpt);
 
-	return 0;
-out:
-	if (lpni) {
-		lnet_try_destroy_peer_hierarchy_locked(lpni);
-		kfree(lpni);
-	}
-	ptable->pt_number--;
-	if (cpt != LNET_LOCK_EX) {
-		lnet_net_unlock(LNET_LOCK_EX);
-		lnet_net_lock(cpt);
-	}
-	return rc;
+	return lpni;
 }
 
 void
@@ -882,14 +999,13 @@ lnet_debug_peer(lnet_nid_t nid)
 {
 	char *aliveness = "NA";
 	struct lnet_peer_ni *lp;
-	int rc;
 	int cpt;
 
 	cpt = lnet_cpt_of_nid(nid, NULL);
 	lnet_net_lock(cpt);
 
-	rc = lnet_nid2peerni_locked(&lp, nid, cpt);
-	if (rc) {
+	lp = lnet_nid2peerni_locked(nid, cpt);
+	if (IS_ERR(lp)) {
 		lnet_net_unlock(cpt);
 		CDEBUG(D_WARNING, "No peer %s\n", libcfs_nid2str(nid));
 		return;
@@ -973,7 +1089,7 @@ lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
 }
 
 int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
-		       struct lnet_peer_ni_credit_info *peer_ni_info,
+		       bool *mr, struct lnet_peer_ni_credit_info *peer_ni_info,
 		       struct lnet_ioctl_element_stats *peer_ni_stats)
 {
 	struct lnet_peer_ni *lpni = NULL;
@@ -986,6 +1102,7 @@ int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
 		return -ENOENT;
 
 	*primary_nid = lp->lp_primary_nid;
+	*mr = lp->lp_multi_rail;
 	*nid = lpni->lpni_nid;
 	snprintf(peer_ni_info->cr_aliveness, LNET_MAX_STR_LEN, "NA");
 	if (lnet_isrouter(lpni) ||
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 7913914620f3..1c79a19f5a25 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -296,6 +296,7 @@ lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
 	struct lnet_route *route;
 	struct lnet_route *route2;
 	struct lnet_ni *ni;
+	struct lnet_peer_ni *lpni;
 	int add_route;
 	int rc;
 
@@ -332,13 +333,14 @@ lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
 
 	lnet_net_lock(LNET_LOCK_EX);
 
-	rc = lnet_nid2peerni_locked(&route->lr_gateway, gateway, LNET_LOCK_EX);
-	if (rc) {
+	lpni = lnet_nid2peerni_locked(gateway, LNET_LOCK_EX);
+	if (IS_ERR(lpni)) {
 		lnet_net_unlock(LNET_LOCK_EX);
 
 		kfree(route);
 		kfree(rnet);
 
+		rc = PTR_ERR(lpni);
 		if (rc == -EHOSTUNREACH) /* gateway is not on a local net */
 			return rc;	/* ignore the route entry */
 		CERROR("Error %d creating route %s %d %s\n", rc,
@@ -346,7 +348,7 @@ lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
 		       libcfs_nid2str(gateway));
 		return rc;
 	}
-
+	route->lr_gateway = lpni;
 	LASSERT(!the_lnet.ln_shutdown);
 
 	rnet2 = lnet_find_rnet_locked(net);
