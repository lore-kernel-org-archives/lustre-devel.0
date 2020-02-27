From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:19 -0500
Subject: [lustre-devel] [PATCH 091/622] lnet: Add ioctl to get health stats
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-92-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

At the time of this patch the sysfs statistics features is
still in development. Therefore, using ioctl to get the stats
from LNet.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 10958cac798d ("LU-9120 lnet: Add ioctl to get health stats")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32776
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h          |  1 +
 include/uapi/linux/lnet/libcfs_ioctl.h |  3 ++-
 include/uapi/linux/lnet/lnet-dlc.h     | 31 ++++++++++++++++-----
 net/lnet/lnet/api-ni.c                 | 49 ++++++++++++++++++++++++++++++++++
 net/lnet/lnet/peer.c                   | 29 ++++++++++++++++----
 5 files changed, 101 insertions(+), 12 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index bd6ea90..ba237df 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -823,6 +823,7 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 			  u32 *ni_peer_tx_credits, u32 *peer_tx_credits,
 			  u32 *peer_rtr_credits, u32 *peer_min_rtr_credtis,
 			  u32 *peer_tx_qnob);
+int lnet_get_peer_ni_hstats(struct lnet_ioctl_peer_ni_hstats *stats);
 
 static inline bool
 lnet_is_peer_ni_healthy_locked(struct lnet_peer_ni *lpni)
diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index 458a634..683d508 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -149,6 +149,7 @@ struct libcfs_debug_ioctl_data {
 #define IOC_LIBCFS_GET_PEER_LIST	_IOWR(IOC_LIBCFS_TYPE, 100, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_LOCAL_NI_MSG_STATS  _IOWR(IOC_LIBCFS_TYPE, 101, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_SET_HEALHV		_IOWR(IOC_LIBCFS_TYPE, 102, IOCTL_CONFIG_SIZE)
-#define IOC_LIBCFS_MAX_NR		102
+#define IOC_LIBCFS_GET_LOCAL_HSTATS	_IOWR(IOC_LIBCFS_TYPE, 103, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_MAX_NR		103
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index 2d3aad8..8e9850c 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -163,6 +163,31 @@ struct lnet_ioctl_element_stats {
 	__u32 iel_drop_count;
 };
 
+enum lnet_health_type {
+	LNET_HEALTH_TYPE_LOCAL_NI = 0,
+	LNET_HEALTH_TYPE_PEER_NI,
+};
+
+struct lnet_ioctl_local_ni_hstats {
+	struct libcfs_ioctl_hdr hlni_hdr;
+	lnet_nid_t hlni_nid;
+	__u32 hlni_local_interrupt;
+	__u32 hlni_local_dropped;
+	__u32 hlni_local_aborted;
+	__u32 hlni_local_no_route;
+	__u32 hlni_local_timeout;
+	__u32 hlni_local_error;
+	__s32 hlni_health_value;
+};
+
+struct lnet_ioctl_peer_ni_hstats {
+	__u32 hlpni_remote_dropped;
+	__u32 hlpni_remote_timeout;
+	__u32 hlpni_remote_error;
+	__u32 hlpni_network_timeout;
+	__s32 hlpni_health_value;
+};
+
 struct lnet_ioctl_element_msg_stats {
 	struct libcfs_ioctl_hdr im_hdr;
 	__u32 im_idx;
@@ -230,12 +255,6 @@ struct lnet_ioctl_peer_cfg {
 	void __user *prcfg_bulk;
 };
 
-
-enum lnet_health_type {
-	LNET_HEALTH_TYPE_LOCAL_NI = 0,
-	LNET_HEALTH_TYPE_PEER_NI,
-};
-
 struct lnet_ioctl_reset_health_cfg {
 	struct libcfs_ioctl_hdr rh_hdr;
 	enum lnet_health_type rh_type;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 0cadb2a..14a8f2c 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3192,6 +3192,42 @@ u32 lnet_get_dlc_seq_locked(void)
 	lnet_net_unlock(LNET_LOCK_EX);
 }
 
+static int
+lnet_get_local_ni_hstats(struct lnet_ioctl_local_ni_hstats *stats)
+{
+	int cpt, rc = 0;
+	struct lnet_ni *ni;
+	lnet_nid_t nid = stats->hlni_nid;
+
+	cpt = lnet_net_lock_current();
+	ni = lnet_nid2ni_locked(nid, cpt);
+
+	if (!ni) {
+		rc = -ENOENT;
+		goto unlock;
+	}
+
+	stats->hlni_local_interrupt =
+		atomic_read(&ni->ni_hstats.hlt_local_interrupt);
+	stats->hlni_local_dropped =
+		atomic_read(&ni->ni_hstats.hlt_local_dropped);
+	stats->hlni_local_aborted =
+		atomic_read(&ni->ni_hstats.hlt_local_aborted);
+	stats->hlni_local_no_route =
+		atomic_read(&ni->ni_hstats.hlt_local_no_route);
+	stats->hlni_local_timeout =
+		atomic_read(&ni->ni_hstats.hlt_local_timeout);
+	stats->hlni_local_error =
+		atomic_read(&ni->ni_hstats.hlt_local_error);
+	stats->hlni_health_value =
+		atomic_read(&ni->ni_healthv);
+
+unlock:
+	lnet_net_unlock(cpt);
+
+	return rc;
+}
+
 /**
  * LNet ioctl handler.
  *
@@ -3399,6 +3435,19 @@ u32 lnet_get_dlc_seq_locked(void)
 		return rc;
 	}
 
+	case IOC_LIBCFS_GET_LOCAL_HSTATS: {
+		struct lnet_ioctl_local_ni_hstats *stats = arg;
+
+		if (stats->hlni_hdr.ioc_len < sizeof(*stats))
+			return -EINVAL;
+
+		mutex_lock(&the_lnet.ln_api_mutex);
+		rc = lnet_get_local_ni_hstats(stats);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+
+		return rc;
+	}
+
 	case IOC_LIBCFS_ADD_PEER_NI: {
 		struct lnet_ioctl_peer_cfg *cfg = arg;
 
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 9dbb3bd4..4a38ca6 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3339,6 +3339,7 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 {
 	struct lnet_ioctl_element_stats *lpni_stats;
 	struct lnet_ioctl_element_msg_stats *lpni_msg_stats;
+	struct lnet_ioctl_peer_ni_hstats *lpni_hstats;
 	struct lnet_peer_ni_credit_info *lpni_info;
 	struct lnet_peer_ni *lpni;
 	struct lnet_peer *lp;
@@ -3354,7 +3355,7 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 	}
 
 	size = sizeof(nid) + sizeof(*lpni_info) + sizeof(*lpni_stats) +
-	       sizeof(*lpni_msg_stats);
+	       sizeof(*lpni_msg_stats) + sizeof(*lpni_hstats);
 	size *= lp->lp_nnis;
 	if (size > cfg->prcfg_size) {
 		cfg->prcfg_size = size;
@@ -3380,6 +3381,9 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 	lpni_msg_stats = kzalloc(sizeof(*lpni_msg_stats), GFP_KERNEL);
 	if (!lpni_msg_stats)
 		goto out_free_stats;
+	lpni_hstats = kzalloc(sizeof(*lpni_hstats), GFP_NOFS);
+	if (!lpni_hstats)
+		goto out_free_msg_stats;
 
 
 	lpni = NULL;
@@ -3387,7 +3391,7 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL) {
 		nid = lpni->lpni_nid;
 		if (copy_to_user(bulk, &nid, sizeof(nid)))
-			goto out_free_msg_stats;
+			goto out_free_hstats;
 		bulk += sizeof(nid);
 
 		memset(lpni_info, 0, sizeof(*lpni_info));
@@ -3406,7 +3410,7 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 		lpni_info->cr_peer_min_tx_credits = lpni->lpni_mintxcredits;
 		lpni_info->cr_peer_tx_qnob = lpni->lpni_txqnob;
 		if (copy_to_user(bulk, lpni_info, sizeof(*lpni_info)))
-			goto out_free_msg_stats;
+			goto out_free_hstats;
 		bulk += sizeof(*lpni_info);
 
 		memset(lpni_stats, 0, sizeof(*lpni_stats));
@@ -3417,15 +3421,30 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 		lpni_stats->iel_drop_count =
 			lnet_sum_stats(&lpni->lpni_stats, LNET_STATS_TYPE_DROP);
 		if (copy_to_user(bulk, lpni_stats, sizeof(*lpni_stats)))
-			goto out_free_msg_stats;
+			goto out_free_hstats;
 		bulk += sizeof(*lpni_stats);
 		lnet_usr_translate_stats(lpni_msg_stats, &lpni->lpni_stats);
 		if (copy_to_user(bulk, lpni_msg_stats, sizeof(*lpni_msg_stats)))
-			goto out_free_msg_stats;
+			goto out_free_hstats;
 		bulk += sizeof(*lpni_msg_stats);
+		lpni_hstats->hlpni_network_timeout =
+			atomic_read(&lpni->lpni_hstats.hlt_network_timeout);
+		lpni_hstats->hlpni_remote_dropped =
+			atomic_read(&lpni->lpni_hstats.hlt_remote_dropped);
+		lpni_hstats->hlpni_remote_timeout =
+			atomic_read(&lpni->lpni_hstats.hlt_remote_timeout);
+		lpni_hstats->hlpni_remote_error =
+			atomic_read(&lpni->lpni_hstats.hlt_remote_error);
+		lpni_hstats->hlpni_health_value =
+			atomic_read(&lpni->lpni_healthv);
+		if (copy_to_user(bulk, lpni_hstats, sizeof(*lpni_hstats)))
+			goto out_free_hstats;
+		bulk += sizeof(*lpni_hstats);
 	}
 	rc = 0;
 
+out_free_hstats:
+	kfree(lpni_hstats);
 out_free_msg_stats:
 	kfree(lpni_msg_stats);
 out_free_stats:
-- 
1.8.3.1
