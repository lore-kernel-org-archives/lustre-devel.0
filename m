From: NeilBrown <neilb@suse.com>
Date: Fri, 07 Sep 2018 10:49:31 +1000
Subject: [lustre-devel] [PATCH 04/34] lnet: embed lnd_tunables in lnet_ni
In-Reply-To: <153628058697.8267.6056114844033479774.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
Message-ID: <153628137138.8267.11270892110905717079.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Instead of a pointer, embed the data struct.
Also other related changes.

This is part of
    8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
       LU-7734 lnet: Multi-Rail local NI split

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    6 ++++
 .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |   10 +++++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 +
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    6 ++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    8 +++---
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |   13 +++-------
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   27 +++++++++-----------
 drivers/staging/lustre/lnet/lnet/config.c          |    2 -
 8 files changed, 36 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index e170eb07a5bf..c5e3363de727 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -302,7 +302,11 @@ struct lnet_ni {
 	struct lnet_ni_status	*ni_status;
 
 	/* per NI LND tunables */
-	struct lnet_ioctl_config_lnd_tunables *ni_lnd_tunables;
+	struct lnet_lnd_tunables ni_lnd_tunables;
+
+	/* lnd tunables set explicitly */
+	bool ni_lnd_tunables_set;
+
 	/*
 	 * equivalent interfaces to use
 	 * This is an array because socklnd bonding can still be configured
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index a8eb3b8f9fd7..ac29f9d24d5d 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -57,11 +57,15 @@ struct lnet_ioctl_config_o2iblnd_tunables {
 	__u16 pad;
 };
 
+struct lnet_lnd_tunables {
+	union {
+		struct lnet_ioctl_config_o2iblnd_tunables lnd_o2ib;
+	} lnd_tun_u;
+};
+
 struct lnet_ioctl_config_lnd_tunables {
 	struct lnet_ioctl_config_lnd_cmn_tunables lt_cmn;
-	union {
-		struct lnet_ioctl_config_o2iblnd_tunables lt_o2ib;
-	} lt_tun_u;
+	struct lnet_lnd_tunables lt_tun;
 };
 
 struct lnet_ioctl_net_config {
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 5e1592b398c1..ade566d20c69 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2122,7 +2122,7 @@ static int kiblnd_net_init_pools(struct kib_net *net, struct lnet_ni *ni,
 	int rc;
 	int i;
 
-	tunables = &ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
+	tunables = &ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
 
 	if (tunables->lnd_fmr_pool_size < *kiblnd_tunables.kib_ntx / 4) {
 		CERROR("Can't set fmr pool size (%d) < ntx / 4(%d)\n",
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 42dc15cef194..522eb150d9a6 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -608,7 +608,7 @@ kiblnd_cfg_rdma_frags(struct lnet_ni *ni)
 	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
 	int mod;
 
-	tunables = &ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
+	tunables = &ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
 	mod = tunables->lnd_map_on_demand;
 	return mod ? mod : IBLND_MAX_RDMA_FRAGS >> IBLND_FRAG_SHIFT;
 }
@@ -627,7 +627,7 @@ kiblnd_concurrent_sends(int version, struct lnet_ni *ni)
 	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
 	int concurrent_sends;
 
-	tunables = &ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
+	tunables = &ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
 	concurrent_sends = tunables->lnd_concurrent_sends;
 
 	if (version == IBLND_MSG_VERSION_1) {
@@ -777,7 +777,7 @@ kiblnd_need_noop(struct kib_conn *conn)
 	struct lnet_ni *ni = conn->ibc_peer->ibp_ni;
 
 	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
-	tunables = &ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
+	tunables = &ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
 
 	if (conn->ibc_outstanding_credits <
 	    IBLND_CREDITS_HIGHWATER(tunables, conn->ibc_version) &&
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index a8d2b4911dab..c266940cb2ae 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1452,7 +1452,7 @@ kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 
 	/* Brand new peer */
 	LASSERT(!peer->ibp_connecting);
-	tunables = &peer->ibp_ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
+	tunables = &peer->ibp_ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
 	peer->ibp_connecting = tunables->lnd_conns_per_peer;
 
 	/* always called with a ref on ni, which prevents ni being shutdown */
@@ -2592,14 +2592,14 @@ kiblnd_check_reconnect(struct kib_conn *conn, int version,
 		break;
 
 	case IBLND_REJECT_RDMA_FRAGS: {
-		struct lnet_ioctl_config_lnd_tunables *tunables;
+		struct lnet_ioctl_config_o2iblnd_tunables *tunables;
 
 		if (!cp) {
 			reason = "can't negotiate max frags";
 			goto out;
 		}
-		tunables = peer->ibp_ni->ni_lnd_tunables;
-		if (!tunables->lt_tun_u.lt_o2ib.lnd_map_on_demand) {
+		tunables = &peer->ibp_ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
+		if (!tunables->lnd_map_on_demand) {
 			reason = "map_on_demand must be enabled";
 			goto out;
 		}
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index a1aca4dda38f..5117594f38fb 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -185,16 +185,11 @@ int kiblnd_tunables_setup(struct lnet_ni *ni)
 	 * if there was no tunables specified, setup the tunables to be
 	 * defaulted
 	 */
-	if (!ni->ni_lnd_tunables) {
-		ni->ni_lnd_tunables = kzalloc(sizeof(*ni->ni_lnd_tunables),
-					      GFP_NOFS);
-		if (!ni->ni_lnd_tunables)
-			return -ENOMEM;
-
-		memcpy(&ni->ni_lnd_tunables->lt_tun_u.lt_o2ib,
+	if (!ni->ni_lnd_tunables_set)
+		memcpy(&ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib,
 		       &default_tunables, sizeof(*tunables));
-	}
-	tunables = &ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
+
+	tunables = &ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
 
 	/* Current API version */
 	tunables->lnd_version = 0;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 0896e75bc3d7..c944fbb155c8 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1198,6 +1198,7 @@ static int
 lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 {
 	struct lnet_ioctl_config_lnd_tunables *lnd_tunables = NULL;
+	struct lnet_lnd_tunables *tun = NULL;
 	int rc = -EINVAL;
 	int lnd_type;
 	struct lnet_lnd *lnd;
@@ -1250,19 +1251,15 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 
 	ni->ni_net->net_lnd = lnd;
 
-	if (conf && conf->cfg_hdr.ioc_len > sizeof(*conf))
+	if (conf && conf->cfg_hdr.ioc_len > sizeof(*conf)) {
 		lnd_tunables = (struct lnet_ioctl_config_lnd_tunables *)conf->cfg_bulk;
+		tun = &lnd_tunables->lt_tun;
+	}
 
-	if (lnd_tunables) {
-		ni->ni_lnd_tunables = kzalloc(sizeof(*ni->ni_lnd_tunables),
-					      GFP_NOFS);
-		if (!ni->ni_lnd_tunables) {
-			mutex_unlock(&the_lnet.ln_lnd_mutex);
-			rc = -ENOMEM;
-			goto failed0;
-		}
-		memcpy(ni->ni_lnd_tunables, lnd_tunables,
-		       sizeof(*ni->ni_lnd_tunables));
+	if (tun) {
+		memcpy(&ni->ni_lnd_tunables, tun,
+		       sizeof(*tun));
+		ni->ni_lnd_tunables_set = true;
 	}
 
 	/*
@@ -1702,15 +1699,15 @@ lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_data *config)
 		tunable_size = config->cfg_hdr.ioc_len - min_size;
 
 	/* Don't copy to much data to user space */
-	min_size = min(tunable_size, sizeof(*ni->ni_lnd_tunables));
+	min_size = min(tunable_size, sizeof(ni->ni_lnd_tunables));
 	lnd_cfg = (struct lnet_ioctl_config_lnd_tunables *)net_config->cfg_bulk;
 
-	if (ni->ni_lnd_tunables && lnd_cfg && min_size) {
-		memcpy(lnd_cfg, ni->ni_lnd_tunables, min_size);
+	if (lnd_cfg && min_size) {
+		memcpy(&lnd_cfg->lt_tun, &ni->ni_lnd_tunables, min_size);
 		config->cfg_config_u.cfg_net.net_interface_count = 1;
 
 		/* Tell user land that kernel side has less data */
-		if (tunable_size > sizeof(*ni->ni_lnd_tunables)) {
+		if (tunable_size > sizeof(ni->ni_lnd_tunables)) {
 			min_size = tunable_size - sizeof(ni->ni_lnd_tunables);
 			config->cfg_hdr.ioc_len -= min_size;
 		}
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 86a53854e427..5646feeb433e 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -105,8 +105,6 @@ lnet_ni_free(struct lnet_ni *ni)
 	if (ni->ni_cpts)
 		cfs_expr_list_values_free(ni->ni_cpts, ni->ni_ncpts);
 
-	kfree(ni->ni_lnd_tunables);
-
 	for (i = 0; i < LNET_MAX_INTERFACES && ni->ni_interfaces[i]; i++)
 		kfree(ni->ni_interfaces[i]);
 
