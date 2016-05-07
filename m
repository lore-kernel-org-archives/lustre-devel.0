From: James Simmons <jsimmons@infradead.org>
Date: Fri,  6 May 2016 21:30:28 -0400
Subject: [lustre-devel] [PATCH 07/10] staging: lustre: o2iblnd: per NI
	map-on-demand value
In-Reply-To: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
References: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462584631-5388-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

Enables support of different map-on-demand values per NI.  This is
required to support OPA coexistence with MLX5 cards.  MLX5 does not
support FMR, which is enabled via map-on-demand.  However OPA's
performance is greatly enahanced when FMR is enabled.  In order
to enable coexistence of both of these two types of cards we
need to be able to set different map-on-demand values for both NIs.

This patch also lays the ground work for other per NI tunables to
be added in future patches.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7101
Reviewed-on: http://review.whamcloud.com/16367
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   66 ++++++++++------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   35 +++++----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   13 ++-
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |   84 +++++++++++++------
 4 files changed, 125 insertions(+), 73 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 84a15d4..7711d96 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1283,16 +1283,22 @@ static void kiblnd_map_tx_pool(kib_tx_pool_t *tpo)
 	}
 }
 
-struct ib_mr *kiblnd_find_rd_dma_mr(kib_hca_dev_t *hdev, kib_rdma_desc_t *rd,
+struct ib_mr *kiblnd_find_rd_dma_mr(struct lnet_ni *ni, kib_rdma_desc_t *rd,
 				    int negotiated_nfrags)
 {
-	__u16 nfrags = (negotiated_nfrags != -1) ?
-			negotiated_nfrags : *kiblnd_tunables.kib_map_on_demand;
+	kib_net_t *net = ni->ni_data;
+	kib_hca_dev_t *hdev = net->ibn_dev->ibd_hdev;
+	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
+	__u16 nfrags;
+	int mod;
+
+	tunables = &ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
+	mod = tunables->lnd_map_on_demand;
+	nfrags = (negotiated_nfrags != -1) ? negotiated_nfrags : mod;
 
 	LASSERT(hdev->ibh_mrs);
 
-	if (*kiblnd_tunables.kib_map_on_demand > 0 &&
-	    nfrags <= rd->rd_nfrags)
+	if (mod > 0 && nfrags <= rd->rd_nfrags)
 		return NULL;
 
 	return hdev->ibh_mrs;
@@ -1337,16 +1343,20 @@ static void kiblnd_destroy_fmr_pool_list(struct list_head *head)
 	}
 }
 
-static int kiblnd_fmr_pool_size(int ncpts)
+static int
+kiblnd_fmr_pool_size(struct lnet_ioctl_config_o2iblnd_tunables *tunables,
+		     int ncpts)
 {
-	int size = *kiblnd_tunables.kib_fmr_pool_size / ncpts;
+	int size = tunables->lnd_fmr_pool_size / ncpts;
 
 	return max(IBLND_FMR_POOL, size);
 }
 
-static int kiblnd_fmr_flush_trigger(int ncpts)
+static int
+kiblnd_fmr_flush_trigger(struct lnet_ioctl_config_o2iblnd_tunables *tunables,
+			 int ncpts)
 {
-	int size = *kiblnd_tunables.kib_fmr_flush_trigger / ncpts;
+	int size = tunables->lnd_fmr_flush_trigger / ncpts;
 
 	return max(IBLND_FMR_POOL_FLUSH, size);
 }
@@ -1362,7 +1372,7 @@ static int kiblnd_alloc_fmr_pool(kib_fmr_poolset_t *fps, kib_fmr_pool_t *fpo)
 		.dirty_watermark   = fps->fps_flush_trigger,
 		.flush_function    = NULL,
 		.flush_arg         = NULL,
-		.cache             = !!*kiblnd_tunables.kib_fmr_cache};
+		.cache             = !!fps->fps_cache };
 	int rc = 0;
 
 	fpo->fmr.fpo_fmr_pool = ib_create_fmr_pool(fpo->fpo_hdev->ibh_pd,
@@ -1508,9 +1518,10 @@ static void kiblnd_fini_fmr_poolset(kib_fmr_poolset_t *fps)
 	}
 }
 
-static int kiblnd_init_fmr_poolset(kib_fmr_poolset_t *fps, int cpt,
-				   kib_net_t *net, int pool_size,
-				   int flush_trigger)
+static int
+kiblnd_init_fmr_poolset(kib_fmr_poolset_t *fps, int cpt, int ncpts,
+			kib_net_t *net,
+			struct lnet_ioctl_config_o2iblnd_tunables *tunables)
 {
 	kib_fmr_pool_t *fpo;
 	int rc;
@@ -1519,8 +1530,11 @@ static int kiblnd_init_fmr_poolset(kib_fmr_poolset_t *fps, int cpt,
 
 	fps->fps_net = net;
 	fps->fps_cpt = cpt;
-	fps->fps_pool_size = pool_size;
-	fps->fps_flush_trigger = flush_trigger;
+
+	fps->fps_pool_size = kiblnd_fmr_pool_size(tunables, ncpts);
+	fps->fps_flush_trigger = kiblnd_fmr_flush_trigger(tunables, ncpts);
+	fps->fps_cache = tunables->lnd_fmr_cache;
+
 	spin_lock_init(&fps->fps_lock);
 	INIT_LIST_HEAD(&fps->fps_pool_list);
 	INIT_LIST_HEAD(&fps->fps_failed_pool_list);
@@ -2151,25 +2165,28 @@ static void kiblnd_net_fini_pools(kib_net_t *net)
 	}
 }
 
-static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
+static int kiblnd_net_init_pools(kib_net_t *net, lnet_ni_t *ni, __u32 *cpts,
+				 int ncpts)
 {
+	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
 	unsigned long flags;
 	int cpt;
-	int		rc = 0;
+	int rc;
 	int i;
 
+	tunables = &ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
+
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
-	if (!*kiblnd_tunables.kib_map_on_demand) {
+	if (!tunables->lnd_map_on_demand) {
 		read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 		goto create_tx_pool;
 	}
 
 	read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
-	if (*kiblnd_tunables.kib_fmr_pool_size <
-	    *kiblnd_tunables.kib_ntx / 4) {
+	if (tunables->lnd_fmr_pool_size < *kiblnd_tunables.kib_ntx / 4) {
 		CERROR("Can't set fmr pool size (%d) < ntx / 4(%d)\n",
-		       *kiblnd_tunables.kib_fmr_pool_size,
+		       tunables->lnd_fmr_pool_size,
 		       *kiblnd_tunables.kib_ntx / 4);
 		rc = -EINVAL;
 		goto failed;
@@ -2199,9 +2216,8 @@ static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
 
 	for (i = 0; i < ncpts; i++) {
 		cpt = !cpts ? i : cpts[i];
-		rc = kiblnd_init_fmr_poolset(net->ibn_fmr_ps[cpt], cpt, net,
-					     kiblnd_fmr_pool_size(ncpts),
-					     kiblnd_fmr_flush_trigger(ncpts));
+		rc = kiblnd_init_fmr_poolset(net->ibn_fmr_ps[cpt], cpt, ncpts,
+					     net, tunables);
 		if (rc) {
 			CERROR("Can't initialize FMR pool for CPT %d: %d\n",
 			       cpt, rc);
@@ -2962,7 +2978,7 @@ static int kiblnd_startup(lnet_ni_t *ni)
 	if (rc)
 		goto failed;
 
-	rc = kiblnd_net_init_pools(net, ni->ni_cpts, ni->ni_ncpts);
+	rc = kiblnd_net_init_pools(net, ni, ni->ni_cpts, ni->ni_ncpts);
 	if (rc) {
 		CERROR("Failed to initialize NI pools: %d\n", rc);
 		goto failed;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index fffae0c..d458773 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -87,18 +87,10 @@ typedef struct {
 	int *kib_timeout;                /* comms timeout (seconds) */
 	int *kib_keepalive;              /* keepalive timeout (seconds) */
 	int *kib_ntx;                    /* # tx descs */
-	int *kib_peercredits_hiw;        /* # when eagerly to return credits */
 	char **kib_default_ipif;         /* default IPoIB interface */
 	int *kib_retry_count;
 	int *kib_rnr_retry_count;
-	int *kib_concurrent_sends;       /* send work queue sizing */
 	int *kib_ib_mtu;                 /* IB MTU */
-	int *kib_map_on_demand;          /* map-on-demand if RD has more */
-					 /* fragments than this value, 0 */
-					 /* disable map-on-demand */
-	int *kib_fmr_pool_size;          /* # FMRs in pool */
-	int *kib_fmr_flush_trigger;      /* When to trigger FMR flush */
-	int *kib_fmr_cache;              /* enable FMR pool cache? */
 	int *kib_require_priv_port;      /* accept only privileged ports */
 	int *kib_use_priv_port; /* use privileged port for active connect */
 	int *kib_nscheds;                /* # threads on each CPT */
@@ -112,9 +104,10 @@ extern kib_tunables_t  kiblnd_tunables;
 #define IBLND_CREDITS_DEFAULT     8 /* default # of peer credits */
 #define IBLND_CREDITS_MAX	  ((typeof(((kib_msg_t *) 0)->ibm_credits)) - 1)  /* Max # of peer credits */
 
-#define IBLND_CREDITS_HIGHWATER(v) ((v) == IBLND_MSG_VERSION_1 ? \
-				     IBLND_CREDIT_HIGHWATER_V1 : \
-				     *kiblnd_tunables.kib_peercredits_hiw) /* when eagerly to return credits */
+/* when eagerly to return credits */
+#define IBLND_CREDITS_HIGHWATER(t, v)	((v) == IBLND_MSG_VERSION_1 ? \
+					IBLND_CREDIT_HIGHWATER_V1 : \
+					t->lnd_peercredits_hiw)
 
 #define kiblnd_rdma_create_id(cb, dev, ps, qpt) rdma_create_id(&init_net, \
 							       cb, dev, \
@@ -260,6 +253,7 @@ typedef struct {
 	int                   fps_cpt;             /* CPT id */
 	int                   fps_pool_size;
 	int                   fps_flush_trigger;
+	int		      fps_cache;
 	int                   fps_increasing;      /* is allocating new pool */
 	unsigned long         fps_next_retry;      /* time stamp for retry if*/
 						   /* failed to allocate */
@@ -614,7 +608,11 @@ int kiblnd_msg_queue_size(int version, struct lnet_ni *ni);
 static inline int
 kiblnd_cfg_rdma_frags(struct lnet_ni *ni)
 {
-	int mod = *kiblnd_tunables.kib_map_on_demand;
+	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
+	int mod;
+
+	tunables = &ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
+	mod = tunables->lnd_map_on_demand;
 	return mod ? mod : IBLND_MAX_RDMA_FRAGS;
 }
 
@@ -629,9 +627,11 @@ kiblnd_rdma_frags(int version, struct lnet_ni *ni)
 static inline int
 kiblnd_concurrent_sends(int version, struct lnet_ni *ni)
 {
+	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
 	int concurrent_sends;
 
-	concurrent_sends = *kiblnd_tunables.kib_concurrent_sends;
+	tunables = &ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
+	concurrent_sends = tunables->lnd_concurrent_sends;
 
 	if (version == IBLND_MSG_VERSION_1) {
 		if (concurrent_sends > IBLND_MSG_QUEUE_SIZE_V1 * 2)
@@ -766,10 +766,14 @@ kiblnd_send_keepalive(kib_conn_t *conn)
 static inline int
 kiblnd_need_noop(kib_conn_t *conn)
 {
+	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
+	lnet_ni_t *ni = conn->ibc_peer->ibp_ni;
+
 	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
+	tunables = &ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
 
 	if (conn->ibc_outstanding_credits <
-	    IBLND_CREDITS_HIGHWATER(conn->ibc_version) &&
+	    IBLND_CREDITS_HIGHWATER(tunables, conn->ibc_version) &&
 	    !kiblnd_send_keepalive(conn))
 		return 0; /* No need to send NOOP */
 
@@ -977,8 +981,7 @@ static inline unsigned int kiblnd_sg_dma_len(struct ib_device *dev,
 #define KIBLND_CONN_PARAM(e)     ((e)->param.conn.private_data)
 #define KIBLND_CONN_PARAM_LEN(e) ((e)->param.conn.private_data_len)
 
-struct ib_mr *kiblnd_find_rd_dma_mr(kib_hca_dev_t *hdev,
-				    kib_rdma_desc_t *rd,
+struct ib_mr *kiblnd_find_rd_dma_mr(struct lnet_ni *ni, kib_rdma_desc_t *rd,
 				    int negotiated_nfrags);
 void kiblnd_map_rx_descs(kib_conn_t *conn);
 void kiblnd_unmap_rx_descs(kib_conn_t *conn);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index c3bd7fa..c4daf95 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -612,8 +612,8 @@ static void kiblnd_unmap_tx(lnet_ni_t *ni, kib_tx_t *tx)
 static int kiblnd_map_tx(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
 			 int nfrags)
 {
-	kib_hca_dev_t *hdev = tx->tx_pool->tpo_hdev;
 	kib_net_t *net = ni->ni_data;
+	kib_hca_dev_t *hdev = net->ibn_dev->ibd_hdev;
 	struct ib_mr *mr    = NULL;
 	__u32 nob;
 	int i;
@@ -636,7 +636,7 @@ static int kiblnd_map_tx(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
 		nob += rd->rd_frags[i].rf_nob;
 	}
 
-	mr = kiblnd_find_rd_dma_mr(hdev, rd, tx->tx_conn ?
+	mr = kiblnd_find_rd_dma_mr(ni, rd, tx->tx_conn ?
 				   tx->tx_conn->ibc_max_frags : -1);
 	if (mr) {
 		/* found pre-mapping MR */
@@ -2585,12 +2585,15 @@ kiblnd_check_reconnect(kib_conn_t *conn, int version,
 		reason = "Unknown";
 		break;
 
-	case IBLND_REJECT_RDMA_FRAGS:
+	case IBLND_REJECT_RDMA_FRAGS: {
+		struct lnet_ioctl_config_lnd_tunables *tunables;
+
 		if (!cp) {
 			reason = "can't negotiate max frags";
 			goto out;
 		}
-		if (!*kiblnd_tunables.kib_map_on_demand) {
+		tunables = peer->ibp_ni->ni_lnd_tunables;
+		if (!tunables->lt_tun_u.lt_o2ib.lnd_map_on_demand) {
 			reason = "map_on_demand must be enabled";
 			goto out;
 		}
@@ -2602,7 +2605,7 @@ kiblnd_check_reconnect(kib_conn_t *conn, int version,
 		peer->ibp_max_frags = frag_num;
 		reason = "rdma fragments";
 		break;
-
+	}
 	case IBLND_REJECT_MSG_QUEUE_SIZE:
 		if (!cp) {
 			reason = "can't negotiate queue depth";
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index e50a9cf..f8fdd4a 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -152,16 +152,10 @@ kib_tunables_t kiblnd_tunables = {
 	.kib_timeout           = &timeout,
 	.kib_keepalive         = &keepalive,
 	.kib_ntx               = &ntx,
-	.kib_peercredits_hiw   = &peer_credits_hiw,
 	.kib_default_ipif      = &ipif_name,
 	.kib_retry_count       = &retry_count,
 	.kib_rnr_retry_count   = &rnr_retry_count,
-	.kib_concurrent_sends  = &concurrent_sends,
 	.kib_ib_mtu            = &ib_mtu,
-	.kib_map_on_demand     = &map_on_demand,
-	.kib_fmr_pool_size     = &fmr_pool_size,
-	.kib_fmr_flush_trigger = &fmr_flush_trigger,
-	.kib_fmr_cache         = &fmr_cache,
 	.kib_require_priv_port = &require_privileged_port,
 	.kib_use_priv_port     = &use_privileged_port,
 	.kib_nscheds           = &nscheds
@@ -182,6 +176,26 @@ int kiblnd_msg_queue_size(int version, lnet_ni_t *ni)
 
 int kiblnd_tunables_setup(struct lnet_ni *ni)
 {
+	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
+
+	/*
+	 * if there was no tunables specified, setup the tunables to be
+	 * defaulted
+	 */
+	if (!ni->ni_lnd_tunables) {
+		LIBCFS_ALLOC(ni->ni_lnd_tunables,
+			     sizeof(*ni->ni_lnd_tunables));
+		if (!ni->ni_lnd_tunables)
+			return -ENOMEM;
+
+		memcpy(&ni->ni_lnd_tunables->lt_tun_u.lt_o2ib,
+		       &default_tunables, sizeof(*tunables));
+	}
+	tunables = &ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
+
+	/* Current API version */
+	tunables->lnd_version = 0;
+
 	if (kiblnd_translate_mtu(*kiblnd_tunables.kib_ib_mtu) < 0) {
 		CERROR("Invalid ib_mtu %d, expected 256/512/1024/2048/4096\n",
 		       *kiblnd_tunables.kib_ib_mtu);
@@ -209,38 +223,54 @@ int kiblnd_tunables_setup(struct lnet_ni *ni)
 	if (ni->ni_peertxcredits > credits)
 		ni->ni_peertxcredits = credits;
 
-	if (*kiblnd_tunables.kib_peercredits_hiw < ni->ni_peertxcredits / 2)
-		*kiblnd_tunables.kib_peercredits_hiw = ni->ni_peertxcredits / 2;
+	if (!tunables->lnd_peercredits_hiw)
+		tunables->lnd_peercredits_hiw = peer_credits_hiw;
 
-	if (*kiblnd_tunables.kib_peercredits_hiw >= ni->ni_peertxcredits)
-		*kiblnd_tunables.kib_peercredits_hiw = ni->ni_peertxcredits - 1;
+	if (tunables->lnd_peercredits_hiw < ni->ni_peertxcredits / 2)
+		tunables->lnd_peercredits_hiw = ni->ni_peertxcredits / 2;
 
-	if (*kiblnd_tunables.kib_map_on_demand < 0 ||
-	    *kiblnd_tunables.kib_map_on_demand > IBLND_MAX_RDMA_FRAGS)
-		*kiblnd_tunables.kib_map_on_demand = 0; /* disable map-on-demand */
+	if (tunables->lnd_peercredits_hiw >= ni->ni_peertxcredits)
+		tunables->lnd_peercredits_hiw = ni->ni_peertxcredits - 1;
 
-	if (*kiblnd_tunables.kib_map_on_demand == 1)
-		*kiblnd_tunables.kib_map_on_demand = 2; /* don't make sense to create map if only one fragment */
+	if (tunables->lnd_map_on_demand < 0 ||
+	    tunables->lnd_map_on_demand > IBLND_MAX_RDMA_FRAGS) {
+		/* disable map-on-demand */
+		tunables->lnd_map_on_demand = 0;
+	}
 
-	if (!*kiblnd_tunables.kib_concurrent_sends) {
-		if (*kiblnd_tunables.kib_map_on_demand > 0 &&
-		    *kiblnd_tunables.kib_map_on_demand <= IBLND_MAX_RDMA_FRAGS / 8)
-			*kiblnd_tunables.kib_concurrent_sends = ni->ni_peertxcredits * 2;
-		else
-			*kiblnd_tunables.kib_concurrent_sends = ni->ni_peertxcredits;
+	if (tunables->lnd_map_on_demand == 1) {
+		/* don't make sense to create map if only one fragment */
+		tunables->lnd_map_on_demand = 2;
 	}
 
-	if (*kiblnd_tunables.kib_concurrent_sends > ni->ni_peertxcredits * 2)
-		*kiblnd_tunables.kib_concurrent_sends = ni->ni_peertxcredits * 2;
+	if (!tunables->lnd_concurrent_sends) {
+		if (tunables->lnd_map_on_demand > 0 &&
+		    tunables->lnd_map_on_demand <= IBLND_MAX_RDMA_FRAGS / 8) {
+			tunables->lnd_concurrent_sends =
+						ni->ni_peertxcredits * 2;
+		} else {
+			tunables->lnd_concurrent_sends = ni->ni_peertxcredits;
+		}
+	}
+
+	if (tunables->lnd_concurrent_sends > ni->ni_peertxcredits * 2)
+		tunables->lnd_concurrent_sends = ni->ni_peertxcredits * 2;
 
-	if (*kiblnd_tunables.kib_concurrent_sends < ni->ni_peertxcredits / 2)
-		*kiblnd_tunables.kib_concurrent_sends = ni->ni_peertxcredits / 2;
+	if (tunables->lnd_concurrent_sends < ni->ni_peertxcredits / 2)
+		tunables->lnd_concurrent_sends = ni->ni_peertxcredits / 2;
 
-	if (*kiblnd_tunables.kib_concurrent_sends < ni->ni_peertxcredits) {
+	if (tunables->lnd_concurrent_sends < ni->ni_peertxcredits) {
 		CWARN("Concurrent sends %d is lower than message queue size: %d, performance may drop slightly.\n",
-		      *kiblnd_tunables.kib_concurrent_sends, ni->ni_peertxcredits);
+		      tunables->lnd_concurrent_sends, ni->ni_peertxcredits);
 	}
 
+	if (!tunables->lnd_fmr_pool_size)
+		tunables->lnd_fmr_pool_size = fmr_pool_size;
+	if (!tunables->lnd_fmr_flush_trigger)
+		tunables->lnd_fmr_flush_trigger = fmr_flush_trigger;
+	if (!tunables->lnd_fmr_cache)
+		tunables->lnd_fmr_cache = fmr_cache;
+
 	return 0;
 }
 
-- 
1.7.1
