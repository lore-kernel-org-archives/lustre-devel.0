From: James Simmons <jsimmons@infradead.org>
Date: Fri,  6 May 2016 21:30:24 -0400
Subject: [lustre-devel] [PATCH 03/10] staging: lustre: lnet: add per NI
	configuration structures
In-Reply-To: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
References: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462584631-5388-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

Currently for LNet all hardware configuration is done with
the modprobe configuration file. These settings are applied
to all hardware instances for a node. That makes it impossible
to configure two different pieces of infiniband hardware that
require very different settings to function. Here we
introduce the infrastructre to allow applying per interface
settings.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7101
Reviewed-on: http://review.whamcloud.com/16367
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-dlc.h    |   29 +++++++++++++++++++-
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +
 drivers/staging/lustre/lnet/lnet/config.c          |    3 ++
 3 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-dlc.h b/drivers/staging/lustre/include/linux/lnet/lib-dlc.h
index 84a19e9..6ce9acc 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-dlc.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-dlc.h
@@ -37,10 +37,37 @@
 #define LNET_MAX_SHOW_NUM_CPT	128
 #define LNET_UNDEFINED_HOPS	((__u32) -1)
 
+struct lnet_ioctl_config_lnd_cmn_tunables {
+	__u32 lct_version;
+	__u32 lct_peer_timeout;
+	__u32 lct_peer_tx_credits;
+	__u32 lct_peer_rtr_credits;
+	__u32 lct_max_tx_credits;
+};
+
+struct lnet_ioctl_config_o2iblnd_tunables {
+	__u32 lnd_version;
+	__u32 lnd_peercredits_hiw;
+	__u32 lnd_map_on_demand;
+	__u32 lnd_concurrent_sends;
+	__u32 lnd_fmr_pool_size;
+	__u32 lnd_fmr_flush_trigger;
+	__u32 lnd_fmr_cache;
+	__u32 pad;
+};
+
+struct lnet_ioctl_config_lnd_tunables {
+	struct lnet_ioctl_config_lnd_cmn_tunables lt_cmn;
+	union {
+		struct lnet_ioctl_config_o2iblnd_tunables lt_o2ib;
+	} lt_tun_u;
+};
+
 struct lnet_ioctl_net_config {
 	char ni_interfaces[LNET_MAX_INTERFACES][LNET_MAX_STR_LEN];
 	__u32 ni_status;
 	__u32 ni_cpts[LNET_MAX_SHOW_NUM_CPT];
+	char cfg_bulk[0];
 };
 
 #define LNET_TINY_BUF_IDX	0
@@ -81,7 +108,7 @@ struct lnet_ioctl_config_data {
 			__s32 net_peer_rtr_credits;
 			__s32 net_max_tx_credits;
 			__u32 net_cksum_algo;
-			__u32 net_pad;
+			__u32 net_interface_count;
 		} cfg_net;
 		struct {
 			__u32 buf_enable;
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 29c72f8..24c4a08 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -273,6 +273,8 @@ typedef struct lnet_ni {
 	int			**ni_refs;	/* percpt reference count */
 	time64_t		  ni_last_alive;/* when I was last alive */
 	lnet_ni_status_t	 *ni_status;	/* my health status */
+	/* per NI LND tunables */
+	struct lnet_ioctl_config_lnd_tunables *ni_lnd_tunables;
 	/* equivalent interfaces to use */
 	char			 *ni_interfaces[LNET_MAX_INTERFACES];
 } lnet_ni_t;
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 449069c..480cc9c 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -107,6 +107,9 @@ lnet_ni_free(struct lnet_ni *ni)
 	if (ni->ni_cpts)
 		cfs_expr_list_values_free(ni->ni_cpts, ni->ni_ncpts);
 
+	if (ni->ni_lnd_tunables)
+		LIBCFS_FREE(ni->ni_lnd_tunables, sizeof(*ni->ni_lnd_tunables));
+
 	for (i = 0; i < LNET_MAX_INTERFACES && ni->ni_interfaces[i]; i++) {
 		LIBCFS_FREE(ni->ni_interfaces[i],
 			    strlen(ni->ni_interfaces[i]) + 1);
-- 
1.7.1
