From: James Simmons <jsimmons@infradead.org>
Date: Fri,  6 May 2016 21:30:23 -0400
Subject: [lustre-devel] [PATCH 02/10] staging: lustre: lnet: use struct
	lnet_ioctl_config_data for NI query
In-Reply-To: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
References: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462584631-5388-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

The functions used to query the NI state passes around the
individual fields of struct lnet_ioctl_config_data. To simplify
the code lets just pass struct lnet_ioctl_config directly.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7101
Reviewed-on: http://review.whamcloud.com/16367
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    4 -
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   60 ++++++--------------
 2 files changed, 18 insertions(+), 46 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 1865c85..513a822 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -463,10 +463,6 @@ int lnet_del_route(__u32 net, lnet_nid_t gw_nid);
 void lnet_destroy_routes(void);
 int lnet_get_route(int idx, __u32 *net, __u32 *hops,
 		   lnet_nid_t *gateway, __u32 *alive, __u32 *priority);
-int lnet_get_net_config(int idx, __u32 *cpt_count, __u64 *nid,
-			int *peer_timeout, int *peer_tx_credits,
-			int *peer_rtr_cr, int *max_tx_credits,
-			struct lnet_ioctl_net_config *net_config);
 int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg);
 
 void lnet_router_debugfs_init(void);
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 6340ad1..01e1808 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1648,25 +1648,18 @@ EXPORT_SYMBOL(LNetNIFini);
  * parameters
  *
  * \param[in] ni network       interface structure
- * \param[out] cpt_count       the number of cpts the ni is on
- * \param[out] nid             Network Interface ID
- * \param[out] peer_timeout    NI peer timeout
- * \param[out] peer_tx_crdits  NI peer transmit credits
- * \param[out] peer_rtr_credits NI peer router credits
- * \param[out] max_tx_credits  NI max transmit credit
- * \param[out] net_config      Network configuration
+ * \param[out] config	       NI configuration
  */
 static void
-lnet_fill_ni_info(struct lnet_ni *ni, __u32 *cpt_count, __u64 *nid,
-		  int *peer_timeout, int *peer_tx_credits,
-		  int *peer_rtr_credits, int *max_tx_credits,
-		  struct lnet_ioctl_net_config *net_config)
+lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_data *config)
 {
+	struct lnet_ioctl_net_config *net_config;
 	int i;
 
-	if (!ni)
+	if (!ni || !config)
 		return;
 
+	net_config = (struct lnet_ioctl_net_config *) config->cfg_bulk;
 	if (!net_config)
 		return;
 
@@ -1682,11 +1675,11 @@ lnet_fill_ni_info(struct lnet_ni *ni, __u32 *cpt_count, __u64 *nid,
 			sizeof(net_config->ni_interfaces[i]));
 	}
 
-	*nid = ni->ni_nid;
-	*peer_timeout = ni->ni_peertimeout;
-	*peer_tx_credits = ni->ni_peertxcredits;
-	*peer_rtr_credits = ni->ni_peerrtrcredits;
-	*max_tx_credits = ni->ni_maxtxcredits;
+	config->cfg_nid = ni->ni_nid;
+	config->cfg_config_u.cfg_net.net_peer_timeout = ni->ni_peertimeout;
+	config->cfg_config_u.cfg_net.net_max_tx_credits = ni->ni_maxtxcredits;
+	config->cfg_config_u.cfg_net.net_peer_tx_credits = ni->ni_peertxcredits;
+	config->cfg_config_u.cfg_net.net_peer_rtr_credits = ni->ni_peerrtrcredits;
 
 	net_config->ni_status = ni->ni_status->ns_status;
 
@@ -1696,18 +1689,16 @@ lnet_fill_ni_info(struct lnet_ni *ni, __u32 *cpt_count, __u64 *nid,
 		for (i = 0; i < num_cpts; i++)
 			net_config->ni_cpts[i] = ni->ni_cpts[i];
 
-		*cpt_count = num_cpts;
+		config->cfg_ncpts = num_cpts;
 	}
 }
 
-int
-lnet_get_net_config(int idx, __u32 *cpt_count, __u64 *nid, int *peer_timeout,
-		    int *peer_tx_credits, int *peer_rtr_credits,
-		    int *max_tx_credits,
-		    struct lnet_ioctl_net_config *net_config)
+static int
+lnet_get_net_config(struct lnet_ioctl_config_data *config)
 {
 	struct lnet_ni *ni;
 	struct list_head *tmp;
+	int idx = config->cfg_count;
 	int cpt, i = 0;
 	int rc = -ENOENT;
 
@@ -1719,9 +1710,7 @@ lnet_get_net_config(int idx, __u32 *cpt_count, __u64 *nid, int *peer_timeout,
 
 		ni = list_entry(tmp, lnet_ni_t, ni_list);
 		lnet_ni_lock(ni);
-		lnet_fill_ni_info(ni, cpt_count, nid, peer_timeout,
-				  peer_tx_credits, peer_rtr_credits,
-				  max_tx_credits, net_config);
+		lnet_fill_ni_info(ni, config);
 		lnet_ni_unlock(ni);
 		rc = 0;
 		break;
@@ -1927,27 +1916,14 @@ LNetCtl(unsigned int cmd, void *arg)
 				      &config->cfg_config_u.cfg_route.rtr_priority);
 
 	case IOC_LIBCFS_GET_NET: {
-		struct lnet_ioctl_net_config *net_config;
-		size_t total = sizeof(*config) + sizeof(*net_config);
-
+		size_t total = sizeof(*config) +
+			       sizeof(struct lnet_ioctl_net_config);
 		config = arg;
 
 		if (config->cfg_hdr.ioc_len < total)
 			return -EINVAL;
 
-		net_config = (struct lnet_ioctl_net_config *)
-				config->cfg_bulk;
-		if (!net_config)
-			return -EINVAL;
-
-		return lnet_get_net_config(config->cfg_count,
-					   &config->cfg_ncpts,
-					   &config->cfg_nid,
-					   &config->cfg_config_u.cfg_net.net_peer_timeout,
-					   &config->cfg_config_u.cfg_net.net_peer_tx_credits,
-					   &config->cfg_config_u.cfg_net.net_peer_rtr_credits,
-					   &config->cfg_config_u.cfg_net.net_max_tx_credits,
-					   net_config);
+		return lnet_get_net_config(config);
 	}
 
 	case IOC_LIBCFS_GET_LNET_STATS: {
-- 
1.7.1
