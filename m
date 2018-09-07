From: NeilBrown <neilb@suse.com>
Date: Fri, 07 Sep 2018 10:49:31 +1000
Subject: [lustre-devel] [PATCH 02/34] lnet: Create struct lnet_net
In-Reply-To: <153628058697.8267.6056114844033479774.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
Message-ID: <153628137129.8267.345070695068208597.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This will contain some fields from lnet_ni, to be shared
between multiple ni on the one network.

For now, only tunables are moved across, using
 struct lnet_ioctl_config_lnd_cmn_tunables
which is changed to use signed values so -1 can be stored.
-1 means "no value"
If the tunables haven't been initialised, then net_tunables_set is
false.  Previously a NULL pointer had this meaning.

A 'struct lnet_net' is allocated as part of lnet_ni_alloc(), and freed
by lnet_ni_free().

This is part of
    8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
       LU-7734 lnet: Multi-Rail local NI split

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |   25 ++++++--
 .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |    8 +--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 -
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |   61 +++++++++++---------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   19 ++++--
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   45 +++++++++------
 drivers/staging/lustre/lnet/lnet/config.c          |   24 ++++++--
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    5 +-
 drivers/staging/lustre/lnet/lnet/peer.c            |    9 ++-
 drivers/staging/lustre/lnet/lnet/router.c          |    8 ++-
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    6 +-
 11 files changed, 129 insertions(+), 83 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 078bc97a9ebf..ead8a4e1125a 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -43,6 +43,7 @@
 
 #include <uapi/linux/lnet/lnet-types.h>
 #include <uapi/linux/lnet/lnetctl.h>
+#include <uapi/linux/lnet/lnet-dlc.h>
 
 /* Max payload size */
 #define LNET_MAX_PAYLOAD      CONFIG_LNET_MAX_PAYLOAD
@@ -252,17 +253,22 @@ struct lnet_tx_queue {
 	struct list_head	tq_delayed;	/* delayed TXs */
 };
 
+struct lnet_net {
+	/* network tunables */
+	struct lnet_ioctl_config_lnd_cmn_tunables net_tunables;
+
+	/*
+	 * boolean to indicate that the tunables have been set and
+	 * shouldn't be reset
+	 */
+	bool			  net_tunables_set;
+};
+
 struct lnet_ni {
 	spinlock_t		  ni_lock;
 	struct list_head	  ni_list;	/* chain on ln_nis */
 	struct list_head	  ni_cptlist;	/* chain on ln_nis_cpt */
-	int			  ni_maxtxcredits; /* # tx credits  */
-	/* # per-peer send credits */
-	int			  ni_peertxcredits;
-	/* # per-peer router buffer credits */
-	int			  ni_peerrtrcredits;
-	/* seconds to consider peer dead */
-	int			  ni_peertimeout;
+
 	/* number of CPTs */
 	int			ni_ncpts;
 
@@ -286,6 +292,9 @@ struct lnet_ni {
 	/* when I was last alive */
 	time64_t		ni_last_alive;
 
+	/* pointer to parent network */
+	struct lnet_net		*ni_net;
+
 	/* my health status */
 	struct lnet_ni_status	*ni_status;
 
@@ -397,7 +406,7 @@ struct lnet_peer_table {
  * lnet_ni::ni_peertimeout has been set to a positive value
  */
 #define lnet_peer_aliveness_enabled(lp) (the_lnet.ln_routing && \
-					 (lp)->lp_ni->ni_peertimeout > 0)
+					 (lp)->lp_ni->ni_net->net_tunables.lct_peer_timeout > 0)
 
 struct lnet_route {
 	struct list_head	 lr_list;	/* chain on net */
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index c1619f411d81..a8eb3b8f9fd7 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -39,10 +39,10 @@
 
 struct lnet_ioctl_config_lnd_cmn_tunables {
 	__u32 lct_version;
-	__u32 lct_peer_timeout;
-	__u32 lct_peer_tx_credits;
-	__u32 lct_peer_rtr_credits;
-	__u32 lct_max_tx_credits;
+	__s32 lct_peer_timeout;
+	__s32 lct_peer_tx_credits;
+	__s32 lct_peer_rtr_credits;
+	__s32 lct_max_tx_credits;
 };
 
 struct lnet_ioctl_config_o2iblnd_tunables {
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index f496e6fcc416..0d17e22c4401 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -337,7 +337,7 @@ int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer **peerp,
 	peer->ibp_error = 0;
 	peer->ibp_last_alive = 0;
 	peer->ibp_max_frags = kiblnd_cfg_rdma_frags(peer->ibp_ni);
-	peer->ibp_queue_depth = ni->ni_peertxcredits;
+	peer->ibp_queue_depth = ni->ni_net->net_tunables.lct_peer_tx_credits;
 	atomic_set(&peer->ibp_refcount, 1);  /* 1 ref for caller */
 
 	INIT_LIST_HEAD(&peer->ibp_list);     /* not in the peer table yet */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 39d07926d603..a1aca4dda38f 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -171,7 +171,7 @@ int kiblnd_msg_queue_size(int version, struct lnet_ni *ni)
 	if (version == IBLND_MSG_VERSION_1)
 		return IBLND_MSG_QUEUE_SIZE_V1;
 	else if (ni)
-		return ni->ni_peertxcredits;
+		return ni->ni_net->net_tunables.lct_peer_tx_credits;
 	else
 		return peer_credits;
 }
@@ -179,6 +179,7 @@ int kiblnd_msg_queue_size(int version, struct lnet_ni *ni)
 int kiblnd_tunables_setup(struct lnet_ni *ni)
 {
 	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
+	struct lnet_ioctl_config_lnd_cmn_tunables *net_tunables;
 
 	/*
 	 * if there was no tunables specified, setup the tunables to be
@@ -204,35 +205,39 @@ int kiblnd_tunables_setup(struct lnet_ni *ni)
 		return -EINVAL;
 	}
 
-	if (!ni->ni_peertimeout)
-		ni->ni_peertimeout = peer_timeout;
+	net_tunables = &ni->ni_net->net_tunables;
 
-	if (!ni->ni_maxtxcredits)
-		ni->ni_maxtxcredits = credits;
+	if (net_tunables->lct_peer_timeout == -1)
+		net_tunables->lct_peer_timeout = peer_timeout;
 
-	if (!ni->ni_peertxcredits)
-		ni->ni_peertxcredits = peer_credits;
+	if (net_tunables->lct_max_tx_credits == -1)
+		net_tunables->lct_max_tx_credits = credits;
 
-	if (!ni->ni_peerrtrcredits)
-		ni->ni_peerrtrcredits = peer_buffer_credits;
+	if (net_tunables->lct_peer_tx_credits == -1)
+		net_tunables->lct_peer_tx_credits = peer_credits;
 
-	if (ni->ni_peertxcredits < IBLND_CREDITS_DEFAULT)
-		ni->ni_peertxcredits = IBLND_CREDITS_DEFAULT;
+	if (net_tunables->lct_peer_rtr_credits == -1)
+		net_tunables->lct_peer_rtr_credits = peer_buffer_credits;
 
-	if (ni->ni_peertxcredits > IBLND_CREDITS_MAX)
-		ni->ni_peertxcredits = IBLND_CREDITS_MAX;
+	if (net_tunables->lct_peer_tx_credits < IBLND_CREDITS_DEFAULT)
+		net_tunables->lct_peer_tx_credits = IBLND_CREDITS_DEFAULT;
 
-	if (ni->ni_peertxcredits > credits)
-		ni->ni_peertxcredits = credits;
+	if (net_tunables->lct_peer_tx_credits > IBLND_CREDITS_MAX)
+		net_tunables->lct_peer_tx_credits = IBLND_CREDITS_MAX;
+
+	if (net_tunables->lct_peer_tx_credits >
+	    net_tunables->lct_max_tx_credits)
+		net_tunables->lct_peer_tx_credits =
+			net_tunables->lct_max_tx_credits;
 
 	if (!tunables->lnd_peercredits_hiw)
 		tunables->lnd_peercredits_hiw = peer_credits_hiw;
 
-	if (tunables->lnd_peercredits_hiw < ni->ni_peertxcredits / 2)
-		tunables->lnd_peercredits_hiw = ni->ni_peertxcredits / 2;
+	if (tunables->lnd_peercredits_hiw < net_tunables->lct_peer_tx_credits / 2)
+		tunables->lnd_peercredits_hiw = net_tunables->lct_peer_tx_credits / 2;
 
-	if (tunables->lnd_peercredits_hiw >= ni->ni_peertxcredits)
-		tunables->lnd_peercredits_hiw = ni->ni_peertxcredits - 1;
+	if (tunables->lnd_peercredits_hiw >= net_tunables->lct_peer_tx_credits)
+		tunables->lnd_peercredits_hiw = net_tunables->lct_peer_tx_credits - 1;
 
 	if (tunables->lnd_map_on_demand <= 0 ||
 	    tunables->lnd_map_on_demand > IBLND_MAX_RDMA_FRAGS) {
@@ -252,21 +257,23 @@ int kiblnd_tunables_setup(struct lnet_ni *ni)
 		if (tunables->lnd_map_on_demand > 0 &&
 		    tunables->lnd_map_on_demand <= IBLND_MAX_RDMA_FRAGS / 8) {
 			tunables->lnd_concurrent_sends =
-						ni->ni_peertxcredits * 2;
+					net_tunables->lct_peer_tx_credits * 2;
 		} else {
-			tunables->lnd_concurrent_sends = ni->ni_peertxcredits;
+			tunables->lnd_concurrent_sends =
+				net_tunables->lct_peer_tx_credits;
 		}
 	}
 
-	if (tunables->lnd_concurrent_sends > ni->ni_peertxcredits * 2)
-		tunables->lnd_concurrent_sends = ni->ni_peertxcredits * 2;
+	if (tunables->lnd_concurrent_sends > net_tunables->lct_peer_tx_credits * 2)
+		tunables->lnd_concurrent_sends = net_tunables->lct_peer_tx_credits * 2;
 
-	if (tunables->lnd_concurrent_sends < ni->ni_peertxcredits / 2)
-		tunables->lnd_concurrent_sends = ni->ni_peertxcredits / 2;
+	if (tunables->lnd_concurrent_sends < net_tunables->lct_peer_tx_credits / 2)
+		tunables->lnd_concurrent_sends = net_tunables->lct_peer_tx_credits / 2;
 
-	if (tunables->lnd_concurrent_sends < ni->ni_peertxcredits) {
+	if (tunables->lnd_concurrent_sends < net_tunables->lct_peer_tx_credits) {
 		CWARN("Concurrent sends %d is lower than message queue size: %d, performance may drop slightly.\n",
-		      tunables->lnd_concurrent_sends, ni->ni_peertxcredits);
+		      tunables->lnd_concurrent_sends,
+		      net_tunables->lct_peer_tx_credits);
 	}
 
 	if (!tunables->lnd_fmr_pool_size)
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 4dde158451ea..4ad885f10235 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2739,12 +2739,19 @@ ksocknal_startup(struct lnet_ni *ni)
 		goto fail_0;
 
 	spin_lock_init(&net->ksnn_lock);
-	net->ksnn_incarnation = ktime_get_real_ns();
-	ni->ni_data = net;
-	ni->ni_peertimeout    = *ksocknal_tunables.ksnd_peertimeout;
-	ni->ni_maxtxcredits   = *ksocknal_tunables.ksnd_credits;
-	ni->ni_peertxcredits  = *ksocknal_tunables.ksnd_peertxcredits;
-	ni->ni_peerrtrcredits = *ksocknal_tunables.ksnd_peerrtrcredits;
+        net->ksnn_incarnation = ktime_get_real_ns();
+        ni->ni_data = net;
+	if (!ni->ni_net->net_tunables_set) {
+		ni->ni_net->net_tunables.lct_peer_timeout =
+			*ksocknal_tunables.ksnd_peertimeout;
+		ni->ni_net->net_tunables.lct_max_tx_credits =
+			*ksocknal_tunables.ksnd_credits;
+		ni->ni_net->net_tunables.lct_peer_tx_credits =
+			*ksocknal_tunables.ksnd_peertxcredits;
+		ni->ni_net->net_tunables.lct_peer_rtr_credits =
+			*ksocknal_tunables.ksnd_peerrtrcredits;
+		ni->ni_net->net_tunables_set = true;
+	}
 
 	net->ksnn_ninterfaces = 0;
 	if (!ni->ni_interfaces[0]) {
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index f9fcce2a5643..cd4189fa7acb 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1036,11 +1036,11 @@ lnet_ni_tq_credits(struct lnet_ni *ni)
 	LASSERT(ni->ni_ncpts >= 1);
 
 	if (ni->ni_ncpts == 1)
-		return ni->ni_maxtxcredits;
+		return ni->ni_net->net_tunables.lct_max_tx_credits;
 
-	credits = ni->ni_maxtxcredits / ni->ni_ncpts;
-	credits = max(credits, 8 * ni->ni_peertxcredits);
-	credits = min(credits, ni->ni_maxtxcredits);
+	credits = ni->ni_net->net_tunables.lct_max_tx_credits / ni->ni_ncpts;
+	credits = max(credits, 8 * ni->ni_net->net_tunables.lct_peer_tx_credits);
+	credits = min(credits, ni->ni_net->net_tunables.lct_max_tx_credits);
 
 	return credits;
 }
@@ -1271,16 +1271,16 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 	 */
 	if (conf) {
 		if (conf->cfg_config_u.cfg_net.net_peer_rtr_credits >= 0)
-			ni->ni_peerrtrcredits =
+			ni->ni_net->net_tunables.lct_peer_rtr_credits =
 				conf->cfg_config_u.cfg_net.net_peer_rtr_credits;
 		if (conf->cfg_config_u.cfg_net.net_peer_timeout >= 0)
-			ni->ni_peertimeout =
+			ni->ni_net->net_tunables.lct_peer_timeout =
 				conf->cfg_config_u.cfg_net.net_peer_timeout;
 		if (conf->cfg_config_u.cfg_net.net_peer_tx_credits != -1)
-			ni->ni_peertxcredits =
+			ni->ni_net->net_tunables.lct_peer_tx_credits =
 				conf->cfg_config_u.cfg_net.net_peer_tx_credits;
 		if (conf->cfg_config_u.cfg_net.net_max_tx_credits >= 0)
-			ni->ni_maxtxcredits =
+			ni->ni_net->net_tunables.lct_max_tx_credits =
 				conf->cfg_config_u.cfg_net.net_max_tx_credits;
 	}
 
@@ -1297,8 +1297,6 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 		goto failed0;
 	}
 
-	LASSERT(ni->ni_peertimeout <= 0 || lnd->lnd_query);
-
 	lnet_net_lock(LNET_LOCK_EX);
 	/* refcount for ln_nis */
 	lnet_ni_addref_locked(ni, 0);
@@ -1314,13 +1312,18 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 		lnet_ni_addref(ni);
 		LASSERT(!the_lnet.ln_loni);
 		the_lnet.ln_loni = ni;
+		ni->ni_net->net_tunables.lct_peer_tx_credits = 0;
+		ni->ni_net->net_tunables.lct_peer_rtr_credits = 0;
+		ni->ni_net->net_tunables.lct_max_tx_credits = 0;
+		ni->ni_net->net_tunables.lct_peer_timeout = 0;
 		return 0;
 	}
 
-	if (!ni->ni_peertxcredits || !ni->ni_maxtxcredits) {
+	if (!ni->ni_net->net_tunables.lct_peer_tx_credits ||
+	    !ni->ni_net->net_tunables.lct_max_tx_credits) {
 		LCONSOLE_ERROR_MSG(0x107, "LNI %s has no %scredits\n",
 				   libcfs_lnd2str(lnd->lnd_type),
-				   !ni->ni_peertxcredits ?
+				   !ni->ni_net->net_tunables.lct_peer_tx_credits ?
 				   "" : "per-peer ");
 		/*
 		 * shutdown the NI since if we get here then it must've already
@@ -1343,9 +1346,11 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 	add_device_randomness(&seed, sizeof(seed));
 
 	CDEBUG(D_LNI, "Added LNI %s [%d/%d/%d/%d]\n",
-	       libcfs_nid2str(ni->ni_nid), ni->ni_peertxcredits,
+	       libcfs_nid2str(ni->ni_nid),
+		ni->ni_net->net_tunables.lct_peer_tx_credits,
 	       lnet_ni_tq_credits(ni) * LNET_CPT_NUMBER,
-	       ni->ni_peerrtrcredits, ni->ni_peertimeout);
+	       ni->ni_net->net_tunables.lct_peer_rtr_credits,
+		ni->ni_net->net_tunables.lct_peer_timeout);
 
 	return 0;
 failed0:
@@ -1667,10 +1672,14 @@ lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_data *config)
 	}
 
 	config->cfg_nid = ni->ni_nid;
-	config->cfg_config_u.cfg_net.net_peer_timeout = ni->ni_peertimeout;
-	config->cfg_config_u.cfg_net.net_max_tx_credits = ni->ni_maxtxcredits;
-	config->cfg_config_u.cfg_net.net_peer_tx_credits = ni->ni_peertxcredits;
-	config->cfg_config_u.cfg_net.net_peer_rtr_credits = ni->ni_peerrtrcredits;
+	config->cfg_config_u.cfg_net.net_peer_timeout =
+		ni->ni_net->net_tunables.lct_peer_timeout;
+	config->cfg_config_u.cfg_net.net_max_tx_credits =
+		ni->ni_net->net_tunables.lct_max_tx_credits;
+	config->cfg_config_u.cfg_net.net_peer_tx_credits =
+		ni->ni_net->net_tunables.lct_peer_tx_credits;
+	config->cfg_config_u.cfg_net.net_peer_rtr_credits =
+		ni->ni_net->net_tunables.lct_peer_rtr_credits;
 
 	net_config->ni_status = ni->ni_status->ns_status;
 
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 091c4f714e84..86a53854e427 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -114,29 +114,38 @@ lnet_ni_free(struct lnet_ni *ni)
 	if (ni->ni_net_ns)
 		put_net(ni->ni_net_ns);
 
+	kvfree(ni->ni_net);
 	kfree(ni);
 }
 
 struct lnet_ni *
-lnet_ni_alloc(__u32 net, struct cfs_expr_list *el, struct list_head *nilist)
+lnet_ni_alloc(__u32 net_id, struct cfs_expr_list *el, struct list_head *nilist)
 {
 	struct lnet_tx_queue *tq;
 	struct lnet_ni *ni;
 	int rc;
 	int i;
+	struct lnet_net		*net;
 
-	if (!lnet_net_unique(net, nilist)) {
+	if (!lnet_net_unique(net_id, nilist)) {
 		LCONSOLE_ERROR_MSG(0x111, "Duplicate network specified: %s\n",
-				   libcfs_net2str(net));
+				   libcfs_net2str(net_id));
 		return NULL;
 	}
 
 	ni = kzalloc(sizeof(*ni), GFP_NOFS);
-	if (!ni) {
+	net = kzalloc(sizeof(*net), GFP_NOFS);
+	if (!ni || !net) {
+		kfree(ni); kfree(net);
 		CERROR("Out of memory creating network %s\n",
-		       libcfs_net2str(net));
+		       libcfs_net2str(net_id));
 		return NULL;
 	}
+	/* initialize global paramters to undefiend */
+	net->net_tunables.lct_peer_timeout = -1;
+	net->net_tunables.lct_max_tx_credits = -1;
+	net->net_tunables.lct_peer_tx_credits = -1;
+	net->net_tunables.lct_peer_rtr_credits = -1;
 
 	spin_lock_init(&ni->ni_lock);
 	INIT_LIST_HEAD(&ni->ni_cptlist);
@@ -160,7 +169,7 @@ lnet_ni_alloc(__u32 net, struct cfs_expr_list *el, struct list_head *nilist)
 		rc = cfs_expr_list_values(el, LNET_CPT_NUMBER, &ni->ni_cpts);
 		if (rc <= 0) {
 			CERROR("Failed to set CPTs for NI %s: %d\n",
-			       libcfs_net2str(net), rc);
+			       libcfs_net2str(net_id), rc);
 			goto failed;
 		}
 
@@ -173,8 +182,9 @@ lnet_ni_alloc(__u32 net, struct cfs_expr_list *el, struct list_head *nilist)
 		ni->ni_ncpts = rc;
 	}
 
+	ni->ni_net = net;
 	/* LND will fill in the address part of the NID */
-	ni->ni_nid = LNET_MKNID(net, 0);
+	ni->ni_nid = LNET_MKNID(net_id, 0);
 
 	/* Store net namespace in which current ni is being created */
 	if (current->nsproxy->net_ns)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index edcafac055ed..f186e6a16d34 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -524,7 +524,8 @@ lnet_peer_is_alive(struct lnet_peer *lp, unsigned long now)
 	    lp->lp_timestamp >= lp->lp_last_alive)
 		return 0;
 
-	deadline = lp->lp_last_alive + lp->lp_ni->ni_peertimeout;
+	deadline = lp->lp_last_alive +
+		lp->lp_ni->ni_net->net_tunables.lct_peer_timeout;
 	alive = deadline > now;
 
 	/* Update obsolete lp_alive except for routers assumed to be dead
@@ -569,7 +570,7 @@ lnet_peer_alive_locked(struct lnet_peer *lp)
 				      libcfs_nid2str(lp->lp_nid),
 				      now, next_query,
 				      lnet_queryinterval,
-				      lp->lp_ni->ni_peertimeout);
+				      lp->lp_ni->ni_net->net_tunables.lct_peer_timeout);
 			return 0;
 		}
 	}
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index d9452c322e4d..b76ac3e051d9 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -342,8 +342,8 @@ lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt)
 		goto out;
 	}
 
-	lp->lp_txcredits = lp->lp_ni->ni_peertxcredits;
-	lp->lp_mintxcredits = lp->lp_ni->ni_peertxcredits;
+	lp->lp_txcredits = lp->lp_ni->ni_net->net_tunables.lct_peer_tx_credits;
+	lp->lp_mintxcredits = lp->lp_ni->ni_net->net_tunables.lct_peer_tx_credits;
 	lp->lp_rtrcredits = lnet_peer_buffer_credits(lp->lp_ni);
 	lp->lp_minrtrcredits = lnet_peer_buffer_credits(lp->lp_ni);
 
@@ -383,7 +383,7 @@ lnet_debug_peer(lnet_nid_t nid)
 
 	CDEBUG(D_WARNING, "%-24s %4d %5s %5d %5d %5d %5d %5d %ld\n",
 	       libcfs_nid2str(lp->lp_nid), lp->lp_refcount,
-	       aliveness, lp->lp_ni->ni_peertxcredits,
+	       aliveness, lp->lp_ni->ni_net->net_tunables.lct_peer_tx_credits,
 	       lp->lp_rtrcredits, lp->lp_minrtrcredits,
 	       lp->lp_txcredits, lp->lp_mintxcredits, lp->lp_txqnob);
 
@@ -438,7 +438,8 @@ lnet_get_peer_info(__u32 peer_index, __u64 *nid,
 
 			*nid = lp->lp_nid;
 			*refcount = lp->lp_refcount;
-			*ni_peer_tx_credits = lp->lp_ni->ni_peertxcredits;
+			*ni_peer_tx_credits =
+				lp->lp_ni->ni_net->net_tunables.lct_peer_tx_credits;
 			*peer_tx_credits = lp->lp_txcredits;
 			*peer_rtr_credits = lp->lp_rtrcredits;
 			*peer_min_rtr_credits = lp->lp_mintxcredits;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 02241fbc9eaa..7d61c5d71426 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -57,9 +57,11 @@ MODULE_PARM_DESC(auto_down, "Automatically mark peers down on comms error");
 int
 lnet_peer_buffer_credits(struct lnet_ni *ni)
 {
+	struct lnet_net *net = ni->ni_net;
+
 	/* NI option overrides LNet default */
-	if (ni->ni_peerrtrcredits > 0)
-		return ni->ni_peerrtrcredits;
+	if (net->net_tunables.lct_peer_rtr_credits > 0)
+		return net->net_tunables.lct_peer_rtr_credits;
 	if (peer_buffer_credits > 0)
 		return peer_buffer_credits;
 
@@ -67,7 +69,7 @@ lnet_peer_buffer_credits(struct lnet_ni *ni)
 	 * As an approximation, allow this peer the same number of router
 	 * buffers as it is allowed outstanding sends
 	 */
-	return ni->ni_peertxcredits;
+	return net->net_tunables.lct_peer_tx_credits;
 }
 
 /* forward ref's */
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 31f4982f7f17..19cea7076057 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -489,7 +489,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 			int nrefs = peer->lp_refcount;
 			time64_t lastalive = -1;
 			char *aliveness = "NA";
-			int maxcr = peer->lp_ni->ni_peertxcredits;
+			int maxcr = peer->lp_ni->ni_net->net_tunables.lct_peer_tx_credits;
 			int txcr = peer->lp_txcredits;
 			int mintxcr = peer->lp_mintxcredits;
 			int rtrcr = peer->lp_rtrcredits;
@@ -704,8 +704,8 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 					      "%-24s %6s %5lld %4d %4d %4d %5d %5d %5d\n",
 					      libcfs_nid2str(ni->ni_nid), stat,
 					      last_alive, *ni->ni_refs[i],
-					      ni->ni_peertxcredits,
-					      ni->ni_peerrtrcredits,
+					      ni->ni_net->net_tunables.lct_peer_tx_credits,
+					      ni->ni_net->net_tunables.lct_peer_rtr_credits,
 					      tq->tq_credits_max,
 					      tq->tq_credits,
 					      tq->tq_credits_min);
