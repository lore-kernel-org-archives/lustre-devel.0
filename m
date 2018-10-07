From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Oct 2018 10:19:37 +1100
Subject: [lustre-devel] [PATCH 02/24] lustre: lnet: configure
 lnet_interfaces_max tunable from dlc
In-Reply-To: <153895417139.16383.3791701638653772865.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
Message-ID: <153895437761.16383.2145517278397754849.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf@sgi.com>

Added the ability to configure lnet_interfaces_max from DLC.
Combined the configure and show of numa range and max interfaces
under a "global" YAML element when configuring using YAML.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: Olaf Weber <olaf@sgi.com>
Reviewed-on: https://review.whamcloud.com/25771
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |    6 +++---
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   16 ++++++++--------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index d88b30d2e76c..706892ca7efb 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -230,9 +230,9 @@ struct lnet_ioctl_peer_cfg {
 	void __user *prcfg_bulk;
 };
 
-struct lnet_ioctl_numa_range {
-	struct libcfs_ioctl_hdr nr_hdr;
-	__u32 nr_range;
+struct lnet_ioctl_set_value {
+	struct libcfs_ioctl_hdr sv_hdr;
+	__u32 sv_value;
 };
 
 struct lnet_ioctl_lnet_stats {
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 6a692d5c4608..8b6400da2836 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -2708,24 +2708,24 @@ LNetCtl(unsigned int cmd, void *arg)
 		return rc;
 
 	case IOC_LIBCFS_SET_NUMA_RANGE: {
-		struct lnet_ioctl_numa_range *numa;
+		struct lnet_ioctl_set_value *numa;
 
 		numa = arg;
-		if (numa->nr_hdr.ioc_len != sizeof(*numa))
+		if (numa->sv_hdr.ioc_len != sizeof(*numa))
 			return -EINVAL;
-		mutex_lock(&the_lnet.ln_api_mutex);
-		lnet_numa_range = numa->nr_range;
-		mutex_unlock(&the_lnet.ln_api_mutex);
+		lnet_net_lock(LNET_LOCK_EX);
+		lnet_numa_range = numa->sv_value;
+		lnet_net_unlock(LNET_LOCK_EX);
 		return 0;
 	}
 
 	case IOC_LIBCFS_GET_NUMA_RANGE: {
-		struct lnet_ioctl_numa_range *numa;
+		struct lnet_ioctl_set_value *numa;
 
 		numa = arg;
-		if (numa->nr_hdr.ioc_len != sizeof(*numa))
+		if (numa->sv_hdr.ioc_len != sizeof(*numa))
 			return -EINVAL;
-		numa->nr_range = lnet_numa_range;
+		numa->sv_value = lnet_numa_range;
 		return 0;
 	}
 
