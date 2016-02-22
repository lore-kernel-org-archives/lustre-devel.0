From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Feb 2016 17:29:05 -0500
Subject: [lustre-devel] [PATCH 04/24] staging: lustre: DLC user/kernel space
	glue code
In-Reply-To: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
References: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456180165-1105-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>

From: Amir Shehata <amir.shehata@intel.com>

This is the sixth patch of a set of patches that enables DLC.

This patch enables the user space to call into the kernel space
DLC code.  Added handlers in the LNetCtl function to call
the new functions added for Dynamic Lnet Configuration

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
ntel-bug-id: https://jira.hpdd.intel.com/browse/LU-2456
Reviewed-on: http://review.whamcloud.com/8023
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   22 ++-
 .../staging/lustre/include/linux/lnet/lib-types.h  |    8 +
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  188 ++++++++++++++++++--
 drivers/staging/lustre/lnet/lnet/module.c          |   64 +++++++-
 drivers/staging/lustre/lnet/lnet/peer.c            |   30 ++--
 drivers/staging/lustre/lnet/lnet/router.c          |   67 ++++++--
 6 files changed, 329 insertions(+), 50 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 1157819..5e16fe0 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -39,6 +39,7 @@
 #include "api.h"
 #include "lnet.h"
 #include "lib-types.h"
+#include "lib-dlc.h"
 
 extern lnet_t	the_lnet;	/* THE network */
 
@@ -458,6 +459,12 @@ int lnet_del_route(__u32 net, lnet_nid_t gw_nid);
 void lnet_destroy_routes(void);
 int lnet_get_route(int idx, __u32 *net, __u32 *hops,
 		   lnet_nid_t *gateway, __u32 *alive, __u32 *priority);
+int lnet_get_net_config(int idx, __u32 *cpt_count, __u64 *nid,
+			int *peer_timeout, int *peer_tx_credits,
+			int *peer_rtr_cr, int *max_tx_credits,
+			struct lnet_ioctl_net_config *net_config);
+int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg);
+
 void lnet_router_debugfs_init(void);
 void lnet_router_debugfs_fini(void);
 int  lnet_rtrpools_alloc(int im_a_router);
@@ -467,6 +474,10 @@ int lnet_rtrpools_enable(void);
 void lnet_rtrpools_disable(void);
 void lnet_rtrpools_free(int keep_pools);
 lnet_remotenet_t *lnet_find_net_locked(__u32 net);
+int lnet_dyn_add_ni(lnet_pid_t requested_pid, char *nets,
+		    __s32 peer_timeout, __s32 peer_cr, __s32 peer_buf_cr,
+		    __s32 credits);
+int lnet_dyn_del_ni(__u32 net);
 
 int lnet_islocalnid(lnet_nid_t nid);
 int lnet_islocalnet(__u32 net);
@@ -693,11 +704,12 @@ void lnet_peer_tables_cleanup(lnet_ni_t *ni);
 void lnet_peer_tables_destroy(void);
 int lnet_peer_tables_create(void);
 void lnet_debug_peer(lnet_nid_t nid);
-int lnet_get_peers(int count, __u64 *nid, char *alivness,
-		   int *ncpt, int *refcount,
-		   int *ni_peer_tx_credits, int *peer_tx_credits,
-		   int *peer_rtr_credits, int *peer_min_rtr_credtis,
-		   int *peer_tx_qnob);
+int lnet_get_peer_info(__u32 peer_index, __u64 *nid,
+		       char alivness[LNET_MAX_STR_LEN],
+		       __u32 *cpt_iter, __u32 *refcount,
+		       __u32 *ni_peer_tx_credits, __u32 *peer_tx_credits,
+		       __u32 *peer_rtr_credits, __u32 *peer_min_rtr_credtis,
+		       __u32 *peer_tx_qnob);
 
 static inline void
 lnet_peer_set_alive(lnet_peer_t *lp)
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index b0ba9d8..e4a8f6e 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -627,6 +627,14 @@ typedef struct {
 	/* test protocol compatibility flags */
 	int				  ln_testprotocompat;
 
+	/*
+	 * 0 - load the NIs from the mod params
+	 * 1 - do not load the NIs from the mod params
+	 * Reverse logic to ensure that other calls to LNetNIInit
+	 * need no change
+	 */
+	bool				  ln_nis_from_mod_params;
+
 } lnet_t;
 
 #endif
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index c68d01e..fa65797 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1553,7 +1553,9 @@ LNetNIInit(lnet_pid_t requested_pid)
 	if (rc)
 		goto failed0;
 
-	rc = lnet_parse_networks(&net_head, lnet_get_networks());
+	rc = lnet_parse_networks(&net_head,
+				 !the_lnet.ln_nis_from_mod_params ?
+				 lnet_get_networks() : "");
 	if (rc < 0)
 		goto failed1;
 
@@ -1668,6 +1670,94 @@ LNetNIFini(void)
 }
 EXPORT_SYMBOL(LNetNIFini);
 
+/**
+ * Grabs the ni data from the ni structure and fills the out
+ * parameters
+ *
+ * \param[in] ni network       interface structure
+ * \param[out] cpt_count       the number of cpts the ni is on
+ * \param[out] nid             Network Interface ID
+ * \param[out] peer_timeout    NI peer timeout
+ * \param[out] peer_tx_crdits  NI peer transmit credits
+ * \param[out] peer_rtr_credits NI peer router credits
+ * \param[out] max_tx_credits  NI max transmit credit
+ * \param[out] net_config      Network configuration
+ */
+static void
+lnet_fill_ni_info(struct lnet_ni *ni, __u32 *cpt_count, __u64 *nid,
+		  int *peer_timeout, int *peer_tx_credits,
+		  int *peer_rtr_credits, int *max_tx_credits,
+		  struct lnet_ioctl_net_config *net_config)
+{
+	int i;
+
+	if (!ni)
+		return;
+
+	if (!net_config)
+		return;
+
+	BUILD_BUG_ON(ARRAY_SIZE(ni->ni_interfaces) !=
+		     ARRAY_SIZE(net_config->ni_interfaces));
+
+	for (i = 0; i < ARRAY_SIZE(ni->ni_interfaces); i++) {
+		if (!ni->ni_interfaces[i])
+			break;
+
+		strncpy(net_config->ni_interfaces[i],
+			ni->ni_interfaces[i],
+			sizeof(net_config->ni_interfaces[i]));
+	}
+
+	*nid = ni->ni_nid;
+	*peer_timeout = ni->ni_peertimeout;
+	*peer_tx_credits = ni->ni_peertxcredits;
+	*peer_rtr_credits = ni->ni_peerrtrcredits;
+	*max_tx_credits = ni->ni_maxtxcredits;
+
+	net_config->ni_status = ni->ni_status->ns_status;
+
+	if (ni->ni_cpts) {
+		int num_cpts = min(ni->ni_ncpts, LNET_MAX_SHOW_NUM_CPT);
+
+		for (i = 0; i < num_cpts; i++)
+			net_config->ni_cpts[i] = ni->ni_cpts[i];
+
+		*cpt_count = num_cpts;
+	}
+}
+
+int
+lnet_get_net_config(int idx, __u32 *cpt_count, __u64 *nid, int *peer_timeout,
+		    int *peer_tx_credits, int *peer_rtr_credits,
+		    int *max_tx_credits,
+		    struct lnet_ioctl_net_config *net_config)
+{
+	struct lnet_ni *ni;
+	struct list_head *tmp;
+	int cpt, i = 0;
+	int rc = -ENOENT;
+
+	cpt = lnet_net_lock_current();
+
+	list_for_each(tmp, &the_lnet.ln_nis) {
+		if (i++ != idx)
+			continue;
+
+		ni = list_entry(tmp, lnet_ni_t, ni_list);
+		lnet_ni_lock(ni);
+		lnet_fill_ni_info(ni, cpt_count, nid, peer_timeout,
+				  peer_tx_credits, peer_rtr_credits,
+				  max_tx_credits, net_config);
+		lnet_ni_unlock(ni);
+		rc = 0;
+		break;
+	}
+
+	lnet_net_unlock(cpt);
+	return rc;
+}
+
 int
 lnet_dyn_add_ni(lnet_pid_t requested_pid, char *nets,
 		__s32 peer_timeout, __s32 peer_cr, __s32 peer_buf_cr,
@@ -1759,9 +1849,16 @@ LNetCtl(unsigned int cmd, void *arg)
 		return lnet_fail_nid(data->ioc_nid, data->ioc_count);
 
 	case IOC_LIBCFS_ADD_ROUTE:
+		config = arg;
+
+		if (config->cfg_hdr.ioc_len < sizeof(*config))
+			return -EINVAL;
+
 		mutex_lock(&the_lnet.ln_api_mutex);
-		rc = lnet_add_route(data->ioc_net, data->ioc_count,
-				    data->ioc_nid, data->ioc_priority);
+		rc = lnet_add_route(config->cfg_net,
+				    config->cfg_config_u.cfg_route.rtr_hop,
+				    config->cfg_nid,
+				    config->cfg_config_u.cfg_route.rtr_priority);
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return rc ? rc : lnet_check_routes();
 
@@ -1789,14 +1886,29 @@ LNetCtl(unsigned int cmd, void *arg)
 				      &config->cfg_config_u.cfg_route.rtr_flags,
 				      &config->cfg_config_u.cfg_route.rtr_priority);
 
-	case IOC_LIBCFS_ADD_NET:
-		return 0;
+	case IOC_LIBCFS_GET_NET: {
+		struct lnet_ioctl_net_config *net_config;
+		size_t total = sizeof(*config) + sizeof(*net_config);
 
-	case IOC_LIBCFS_DEL_NET:
-		return 0;
+		config = arg;
 
-	case IOC_LIBCFS_GET_NET:
-		return 0;
+		if (config->cfg_hdr.ioc_len < total)
+			return -EINVAL;
+
+		net_config = (struct lnet_ioctl_net_config *)
+				config->cfg_bulk;
+		if (!net_config)
+			return -EINVAL;
+
+		return lnet_get_net_config(config->cfg_count,
+					   &config->cfg_ncpts,
+					   &config->cfg_nid,
+					   &config->cfg_config_u.cfg_net.net_peer_timeout,
+					   &config->cfg_config_u.cfg_net.net_peer_tx_credits,
+					   &config->cfg_config_u.cfg_net.net_peer_rtr_credits,
+					   &config->cfg_config_u.cfg_net.net_max_tx_credits,
+					   net_config);
+	}
 
 	case IOC_LIBCFS_GET_LNET_STATS: {
 		struct lnet_ioctl_lnet_stats *lnet_stats = arg;
@@ -1809,16 +1921,64 @@ LNetCtl(unsigned int cmd, void *arg)
 	}
 
 	case IOC_LIBCFS_CONFIG_RTR:
+		config = arg;
+
+		if (config->cfg_hdr.ioc_len < sizeof(*config))
+			return -EINVAL;
+
+		mutex_lock(&the_lnet.ln_api_mutex);
+		if (config->cfg_config_u.cfg_buffers.buf_enable) {
+			rc = lnet_rtrpools_enable();
+			mutex_unlock(&the_lnet.ln_api_mutex);
+			return rc;
+		}
+		lnet_rtrpools_disable();
+		mutex_unlock(&the_lnet.ln_api_mutex);
 		return 0;
 
 	case IOC_LIBCFS_ADD_BUF:
-		return 0;
+		config = arg;
 
-	case IOC_LIBCFS_GET_BUF:
-		return 0;
+		if (config->cfg_hdr.ioc_len < sizeof(*config))
+			return -EINVAL;
 
-	case IOC_LIBCFS_GET_PEER_INFO:
-		return 0;
+		mutex_lock(&the_lnet.ln_api_mutex);
+		rc = lnet_rtrpools_adjust(config->cfg_config_u.cfg_buffers.buf_tiny,
+					  config->cfg_config_u.cfg_buffers.buf_small,
+					  config->cfg_config_u.cfg_buffers.buf_large);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return rc;
+
+	case IOC_LIBCFS_GET_BUF: {
+		struct lnet_ioctl_pool_cfg *pool_cfg;
+		size_t total = sizeof(*config) + sizeof(*pool_cfg);
+
+		config = arg;
+
+		if (config->cfg_hdr.ioc_len < total)
+			return -EINVAL;
+
+		pool_cfg = (struct lnet_ioctl_pool_cfg *)config->cfg_bulk;
+		return lnet_get_rtr_pool_cfg(config->cfg_count, pool_cfg);
+	}
+
+	case IOC_LIBCFS_GET_PEER_INFO: {
+		struct lnet_ioctl_peer *peer_info = arg;
+
+		if (peer_info->pr_hdr.ioc_len < sizeof(*peer_info))
+			return -EINVAL;
+
+		return lnet_get_peer_info(peer_info->pr_count,
+			&peer_info->pr_nid,
+			peer_info->pr_lnd_u.pr_peer_credits.cr_aliveness,
+			&peer_info->pr_lnd_u.pr_peer_credits.cr_ncpt,
+			&peer_info->pr_lnd_u.pr_peer_credits.cr_refcount,
+			&peer_info->pr_lnd_u.pr_peer_credits.cr_ni_peer_tx_credits,
+			&peer_info->pr_lnd_u.pr_peer_credits.cr_peer_tx_credits,
+			&peer_info->pr_lnd_u.pr_peer_credits.cr_peer_rtr_credits,
+			&peer_info->pr_lnd_u.pr_peer_credits.cr_peer_min_rtr_credits,
+			&peer_info->pr_lnd_u.pr_peer_credits.cr_peer_tx_qnob);
+	}
 
 	case IOC_LIBCFS_NOTIFY_ROUTER:
 		secs_passed = (ktime_get_real_seconds() - data->ioc_u64[0]);
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 27213f1..e9b1e69 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -85,19 +85,79 @@ lnet_unconfigure(void)
 }
 
 static int
+lnet_dyn_configure(struct libcfs_ioctl_hdr *hdr)
+{
+	struct lnet_ioctl_config_data *conf =
+		(struct lnet_ioctl_config_data *)hdr;
+	int rc;
+
+	if (conf->cfg_hdr.ioc_len < sizeof(*conf))
+		return -EINVAL;
+
+	mutex_lock(&lnet_config_mutex);
+	if (!the_lnet.ln_niinit_self) {
+		rc = -EINVAL;
+		goto out_unlock;
+	}
+	rc = lnet_dyn_add_ni(LUSTRE_SRV_LNET_PID,
+			     conf->cfg_config_u.cfg_net.net_intf,
+			     conf->cfg_config_u.cfg_net.net_peer_timeout,
+			     conf->cfg_config_u.cfg_net.net_peer_tx_credits,
+			     conf->cfg_config_u.cfg_net.net_peer_rtr_credits,
+			     conf->cfg_config_u.cfg_net.net_max_tx_credits);
+out_unlock:
+	mutex_unlock(&lnet_config_mutex);
+
+	return rc;
+}
+
+static int
+lnet_dyn_unconfigure(struct libcfs_ioctl_hdr *hdr)
+{
+	struct lnet_ioctl_config_data *conf =
+		(struct lnet_ioctl_config_data *)hdr;
+	int rc;
+
+	if (conf->cfg_hdr.ioc_len < sizeof(*conf))
+		return -EINVAL;
+
+	mutex_lock(&lnet_config_mutex);
+	if (!the_lnet.ln_niinit_self) {
+		rc = -EINVAL;
+		goto out_unlock;
+	}
+	rc = lnet_dyn_del_ni(conf->cfg_net);
+out_unlock:
+	mutex_unlock(&lnet_config_mutex);
+
+	return rc;
+}
+
+static int
 lnet_ioctl(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
 {
 	int rc;
 
 	switch (cmd) {
-	case IOC_LIBCFS_CONFIGURE:
+	case IOC_LIBCFS_CONFIGURE: {
+		struct libcfs_ioctl_data *data =
+			(struct libcfs_ioctl_data *)hdr;
+
+		if (data->ioc_hdr.ioc_len < sizeof(*data))
+			return -EINVAL;
+
+		the_lnet.ln_nis_from_mod_params = data->ioc_flags;
 		return lnet_configure(NULL);
+	}
 
 	case IOC_LIBCFS_UNCONFIGURE:
 		return lnet_unconfigure();
 
 	case IOC_LIBCFS_ADD_NET:
-		return LNetCtl(cmd, hdr);
+		return lnet_dyn_configure(hdr);
+
+	case IOC_LIBCFS_DEL_NET:
+		return lnet_dyn_unconfigure(hdr);
 
 	default:
 		/*
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 5771708..19c80c9 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -394,16 +394,18 @@ lnet_debug_peer(lnet_nid_t nid)
 	lnet_net_unlock(cpt);
 }
 
-int lnet_get_peers(int count, __u64 *nid, char *aliveness,
-		   int *ncpt, int *refcount,
-		   int *ni_peer_tx_credits, int *peer_tx_credits,
-		   int *peer_rtr_credits, int *peer_min_rtr_credits,
-		   int *peer_tx_qnob)
+int
+lnet_get_peer_info(__u32 peer_index, __u64 *nid,
+		   char aliveness[LNET_MAX_STR_LEN],
+		   __u32 *cpt_iter, __u32 *refcount,
+		   __u32 *ni_peer_tx_credits, __u32 *peer_tx_credits,
+		   __u32 *peer_rtr_credits, __u32 *peer_min_rtr_credits,
+		   __u32 *peer_tx_qnob)
 {
 	struct lnet_peer_table *peer_table;
 	lnet_peer_t *lp;
-	int j;
-	int lncpt, found = 0;
+	bool found = false;
+	int lncpt, j;
 
 	/* get the number of CPTs */
 	lncpt = cfs_percpt_number(the_lnet.ln_peer_tables);
@@ -412,22 +414,22 @@ int lnet_get_peers(int count, __u64 *nid, char *aliveness,
 	 * if the cpt number to be examined is >= the number of cpts in
 	 * the system then indicate that there are no more cpts to examin
 	 */
-	if (*ncpt >= lncpt)
+	if (*cpt_iter >= lncpt)
 		return -ENOENT;
 
 	/* get the current table */
-	peer_table = the_lnet.ln_peer_tables[*ncpt];
+	peer_table = the_lnet.ln_peer_tables[*cpt_iter];
 	/* if the ptable is NULL then there are no more cpts to examine */
 	if (!peer_table)
 		return -ENOENT;
 
-	lnet_net_lock(*ncpt);
+	lnet_net_lock(*cpt_iter);
 
 	for (j = 0; j < LNET_PEER_HASH_SIZE && !found; j++) {
 		struct list_head *peers = &peer_table->pt_hash[j];
 
 		list_for_each_entry(lp, peers, lp_hashlist) {
-			if (count-- > 0)
+			if (peer_index-- > 0)
 				continue;
 
 			snprintf(aliveness, LNET_MAX_STR_LEN, "NA");
@@ -444,12 +446,12 @@ int lnet_get_peers(int count, __u64 *nid, char *aliveness,
 			*peer_min_rtr_credits = lp->lp_mintxcredits;
 			*peer_tx_qnob = lp->lp_txqnob;
 
-			found = 1;
+			found = true;
 		}
 	}
-	lnet_net_unlock(*ncpt);
+	lnet_net_unlock(*cpt_iter);
 
-	*ncpt = lncpt;
+	*cpt_iter = lncpt;
 
 	return found ? 0 : -ENOENT;
 }
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index e62a1b3..7e7afc4 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -542,6 +542,38 @@ lnet_destroy_routes(void)
 	lnet_del_route(LNET_NIDNET(LNET_NID_ANY), LNET_NID_ANY);
 }
 
+int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
+{
+	int i, rc = -ENOENT, j;
+
+	if (!the_lnet.ln_rtrpools)
+		return rc;
+
+	for (i = 0; i < LNET_NRBPOOLS; i++) {
+		lnet_rtrbufpool_t *rbp;
+
+		lnet_net_lock(LNET_LOCK_EX);
+		cfs_percpt_for_each(rbp, j, the_lnet.ln_rtrpools) {
+			if (i++ != idx)
+				continue;
+
+			pool_cfg->pl_pools[i].pl_npages = rbp[i].rbp_npages;
+			pool_cfg->pl_pools[i].pl_nbuffers = rbp[i].rbp_nbuffers;
+			pool_cfg->pl_pools[i].pl_credits = rbp[i].rbp_credits;
+			pool_cfg->pl_pools[i].pl_mincredits = rbp[i].rbp_mincredits;
+			rc = 0;
+			break;
+		}
+		lnet_net_unlock(LNET_LOCK_EX);
+	}
+
+	lnet_net_lock(LNET_LOCK_EX);
+	pool_cfg->pl_routing = the_lnet.ln_routing;
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	return rc;
+}
+
 int
 lnet_get_route(int idx, __u32 *net, __u32 *hops,
 	       lnet_nid_t *gateway, __u32 *alive, __u32 *priority)
@@ -1544,8 +1576,8 @@ lnet_rtrpools_alloc(int im_a_router)
 	return rc;
 }
 
-int
-lnet_rtrpools_adjust(int tiny, int small, int large)
+static int
+lnet_rtrpools_adjust_helper(int tiny, int small, int large)
 {
 	int nrb = 0;
 	int rc = 0;
@@ -1553,19 +1585,10 @@ lnet_rtrpools_adjust(int tiny, int small, int large)
 	lnet_rtrbufpool_t *rtrp;
 
 	/*
-	 * this function doesn't revert the changes if adding new buffers
-	 * failed.  It's up to the user space caller to revert the
-	 * changes.
-	 */
-
-	if (!the_lnet.ln_routing)
-		return 0;
-
-	/*
 	 * If the provided values for each buffer pool are different than the
 	 * configured values, we need to take action.
 	 */
-	if (tiny >= 0 && tiny != tiny_router_buffers) {
+	if (tiny >= 0) {
 		tiny_router_buffers = tiny;
 		nrb = lnet_nrb_tiny_calculate();
 		cfs_percpt_for_each(rtrp, i, the_lnet.ln_rtrpools) {
@@ -1575,7 +1598,7 @@ lnet_rtrpools_adjust(int tiny, int small, int large)
 				return rc;
 		}
 	}
-	if (small >= 0 && small != small_router_buffers) {
+	if (small >= 0) {
 		small_router_buffers = small;
 		nrb = lnet_nrb_small_calculate();
 		cfs_percpt_for_each(rtrp, i, the_lnet.ln_rtrpools) {
@@ -1585,7 +1608,7 @@ lnet_rtrpools_adjust(int tiny, int small, int large)
 				return rc;
 		}
 	}
-	if (large >= 0 && large != large_router_buffers) {
+	if (large >= 0) {
 		large_router_buffers = large;
 		nrb = lnet_nrb_large_calculate();
 		cfs_percpt_for_each(rtrp, i, the_lnet.ln_rtrpools) {
@@ -1600,6 +1623,20 @@ lnet_rtrpools_adjust(int tiny, int small, int large)
 }
 
 int
+lnet_rtrpools_adjust(int tiny, int small, int large)
+{
+	/*
+	 * this function doesn't revert the changes if adding new buffers
+	 * failed.  It's up to the user space caller to revert the
+	 * changes.
+	 */
+	if (!the_lnet.ln_routing)
+		return 0;
+
+	return lnet_rtrpools_adjust_helper(tiny, small, large);
+}
+
+int
 lnet_rtrpools_enable(void)
 {
 	int rc;
@@ -1617,7 +1654,7 @@ lnet_rtrpools_enable(void)
 		 */
 		return lnet_rtrpools_alloc(1);
 
-	rc = lnet_rtrpools_adjust(0, 0, 0);
+	rc = lnet_rtrpools_adjust_helper(0, 0, 0);
 	if (rc)
 		return rc;
 
-- 
1.7.1
