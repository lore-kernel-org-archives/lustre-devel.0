From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:58 -0500
Subject: [lustre-devel] [PATCH 22/40] staging: lustre: Fixes to make lnetctl
	function as expected.
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

During testing of the lnetctl utility I ran into some
issues. One of the problems is when you print out help
for peer_credits you get help for stats. With this patch
the help option for peer_credits is set to return the
proper help message.

The second problem was for grabbing stats data. No data
was returned but instead it reported a error. The reason
for this is that libcfs_ioctl_getdata() test to see if the
size of the data passed in is less than the struct
libcfs_ioctl_data in size. For the stats function its
data structure struct lnet_ioctl_lnet_stats is smaller
than what is allowed. Instead of checking if the data
is less than libcfs_ioctl_data in size we check to ensure
that the data is not smaller than the ioctl hdr data which
is universal.

The bug in libcfs_ioctl_getdata() exposed a bunch of cases
with new ioctls that don't check to see if the data imported
from userland equals the size reported in the ioctl hdr
data. We address those cases in this patch as well.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5935
Reviewed-on: http://review.whamcloud.com/12782
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   36 ++++++++++++++++++++
 .../lustre/lustre/libcfs/linux/linux-module.c      |    2 +-
 2 files changed, 37 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index e40c657..7657f88 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1872,6 +1872,10 @@ LNetCtl(unsigned int cmd, void *arg)
 
 	case IOC_LIBCFS_ADD_ROUTE:
 		config = arg;
+
+		if (config->cfg_hdr.ioc_len < sizeof(*config))
+			return -EINVAL;
+
 		mutex_lock(&the_lnet.ln_api_mutex);
 		rc = lnet_add_route(config->cfg_net,
 				    config->cfg_config_u.cfg_route.rtr_hop,
@@ -1883,6 +1887,10 @@ LNetCtl(unsigned int cmd, void *arg)
 
 	case IOC_LIBCFS_DEL_ROUTE:
 		config = arg;
+
+		if (config->cfg_hdr.ioc_len < sizeof(*config))
+			return -EINVAL;
+
 		mutex_lock(&the_lnet.ln_api_mutex);
 		rc = lnet_del_route(config->cfg_net, config->cfg_nid);
 		mutex_unlock(&the_lnet.ln_api_mutex);
@@ -1890,6 +1898,10 @@ LNetCtl(unsigned int cmd, void *arg)
 
 	case IOC_LIBCFS_GET_ROUTE:
 		config = arg;
+
+		if (config->cfg_hdr.ioc_len < sizeof(*config))
+			return -EINVAL;
+
 		return lnet_get_route(config->cfg_count,
 				      &config->cfg_net,
 				      &config->cfg_config_u.cfg_route.rtr_hop,
@@ -1900,8 +1912,13 @@ LNetCtl(unsigned int cmd, void *arg)
 
 	case IOC_LIBCFS_GET_NET: {
 		struct lnet_ioctl_net_config *net_config;
+		size_t total = sizeof(*config) + sizeof(*net_config);
 
 		config = arg;
+
+		if (config->cfg_hdr.ioc_len < total)
+			return -EINVAL;
+
 		net_config = (struct lnet_ioctl_net_config *)
 				config->cfg_bulk;
 		if (!config || !net_config)
@@ -1925,12 +1942,19 @@ LNetCtl(unsigned int cmd, void *arg)
 	{
 		struct lnet_ioctl_lnet_stats *lnet_stats = arg;
 
+		if (lnet_stats->st_hdr.ioc_len < sizeof(*lnet_stats))
+			return -EINVAL;
+
 		lnet_counters_get(&lnet_stats->st_cntrs);
 		return 0;
 	}
 
 	case IOC_LIBCFS_CONFIG_RTR:
 		config = arg;
+
+		if (config->cfg_hdr.ioc_len < sizeof(*config))
+			return -EINVAL;
+
 		mutex_lock(&the_lnet.ln_api_mutex);
 		if (config->cfg_config_u.cfg_buffers.buf_enable) {
 			rc = lnet_rtrpools_enable();
@@ -1943,6 +1967,10 @@ LNetCtl(unsigned int cmd, void *arg)
 
 	case IOC_LIBCFS_ADD_BUF:
 		config = arg;
+
+		if (config->cfg_hdr.ioc_len < sizeof(*config))
+			return -EINVAL;
+
 		mutex_lock(&the_lnet.ln_api_mutex);
 		rc = lnet_rtrpools_adjust(config->cfg_config_u.cfg_buffers.
 						buf_tiny,
@@ -1955,8 +1983,13 @@ LNetCtl(unsigned int cmd, void *arg)
 
 	case IOC_LIBCFS_GET_BUF: {
 		struct lnet_ioctl_pool_cfg *pool_cfg;
+		size_t total = sizeof(*config) + sizeof(*pool_cfg);
 
 		config = arg;
+
+		if (config->cfg_hdr.ioc_len < total)
+			return -EINVAL;
+
 		pool_cfg = (struct lnet_ioctl_pool_cfg *)config->cfg_bulk;
 		return lnet_get_rtr_pool_cfg(config->cfg_count, pool_cfg);
 	}
@@ -1964,6 +1997,9 @@ LNetCtl(unsigned int cmd, void *arg)
 	case IOC_LIBCFS_GET_PEER_INFO: {
 		struct lnet_ioctl_peer *peer_info = arg;
 
+		if (peer_info->pr_hdr.ioc_len < sizeof(*peer_info))
+			return -EINVAL;
+
 		return lnet_get_peer_info(peer_info->pr_count,
 			&peer_info->pr_nid,
 			peer_info->pr_lnd_u.pr_peer_credits.cr_aliveness,
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
index 50a5464..9414746 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
@@ -73,7 +73,7 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 		return -EINVAL;
 	}
 
-	if (hdr.ioc_len < sizeof(struct libcfs_ioctl_data)) {
+	if (hdr.ioc_len < sizeof(struct libcfs_ioctl_hdr)) {
 		CERROR("libcfs ioctl: user buffer too small for ioctl\n");
 		return -EINVAL;
 	}
-- 
1.7.1
