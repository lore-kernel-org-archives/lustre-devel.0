From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:47:56 -0400
Subject: [lustre-devel] [PATCH 04/25] lustre: lnet: Normalize ioctl interface
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

To avoid backwards compatibility issues between base MR
and Dynamic Discovery standardize the ioctl interface by
bringing in changes to the interface required by
Dynamic Discovery now.

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9119
Reviewed-on: https://review.whamcloud.com/26689
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  5 ++-
 .../lustre/include/uapi/linux/lnet/lnet-dlc.h      | 39 ++++++++++++++++---
 drivers/staging/lustre/lnet/lnet/api-ni.c          | 21 +++++-----
 drivers/staging/lustre/lnet/lnet/peer.c            | 45 ++++++++++++++--------
 4 files changed, 77 insertions(+), 33 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 53cbf6d..f510b9e 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -665,8 +665,9 @@ bool lnet_peer_is_ni_pref_locked(struct lnet_peer_ni *lpni,
 int lnet_add_peer_ni_to_peer(lnet_nid_t key_nid, lnet_nid_t nid, bool mr);
 int lnet_del_peer_ni_from_peer(lnet_nid_t key_nid, lnet_nid_t nid);
 int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
-		       bool *mr, struct lnet_peer_ni_credit_info *peer_ni_info,
-		       struct lnet_ioctl_element_stats *peer_ni_stats);
+		       bool *mr,
+		       struct lnet_peer_ni_credit_info __user *peer_ni_info,
+		       struct lnet_ioctl_element_stats __user *peer_ni_stats);
 int lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
 			  char alivness[LNET_MAX_STR_LEN],
 			  __u32 *cpt_iter, __u32 *refcount,
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index 2594642..e603455 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -104,6 +104,17 @@ struct lnet_ioctl_pool_cfg {
 	__u32 pl_routing;
 };
 
+struct lnet_ioctl_ping_data {
+	struct libcfs_ioctl_hdr ping_hdr;
+
+	__u32 op_param;
+	__u32 ping_count;
+	__u32 ping_flags;
+	bool mr_info;
+	struct lnet_process_id ping_id;
+	struct lnet_process_id __user *ping_buf;
+};
+
 struct lnet_ioctl_config_data {
 	struct libcfs_ioctl_hdr cfg_hdr;
 
@@ -138,10 +149,26 @@ struct lnet_ioctl_config_data {
 	char cfg_bulk[0];
 };
 
+struct lnet_ioctl_comm_count {
+	__u32 ico_get_count;
+	__u32 ico_put_count;
+	__u32 ico_reply_count;
+	__u32 ico_ack_count;
+	__u32 ico_hello_count;
+};
+
 struct lnet_ioctl_element_stats {
-	u32	send_count;
-	u32	recv_count;
-	u32	drop_count;
+	__u32 iel_send_count;
+	__u32 iel_recv_count;
+	__u32 iel_drop_count;
+};
+
+struct lnet_ioctl_element_msg_stats {
+	struct libcfs_ioctl_hdr im_hdr;
+	__u32 im_idx;
+	struct lnet_ioctl_comm_count im_send_stats;
+	struct lnet_ioctl_comm_count im_recv_stats;
+	struct lnet_ioctl_comm_count im_drop_stats;
 };
 
 /*
@@ -196,9 +223,11 @@ struct lnet_ioctl_peer_cfg {
 	struct libcfs_ioctl_hdr prcfg_hdr;
 	lnet_nid_t prcfg_prim_nid;
 	lnet_nid_t prcfg_cfg_nid;
-	__u32 prcfg_idx;
+	__u32 prcfg_count;
 	bool prcfg_mr;
-	char prcfg_bulk[0];
+	__u32 prcfg_state;
+	__u32 prcfg_size;
+	void __user *prcfg_bulk;
 };
 
 struct lnet_ioctl_numa_range {
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 43e8db1..2d430d0 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1904,8 +1904,8 @@ void lnet_lib_exit(void)
 	memcpy(&tun->lt_cmn, &ni->ni_net->net_tunables, sizeof(tun->lt_cmn));
 
 	if (stats) {
-		stats->send_count = atomic_read(&ni->ni_stats.send_count);
-		stats->recv_count = atomic_read(&ni->ni_stats.recv_count);
+		stats->iel_send_count = atomic_read(&ni->ni_stats.send_count);
+		stats->iel_recv_count = atomic_read(&ni->ni_stats.recv_count);
 	}
 
 	/*
@@ -2761,20 +2761,19 @@ u32 lnet_get_dlc_seq_locked(void)
 
 	case IOC_LIBCFS_GET_PEER_NI: {
 		struct lnet_ioctl_peer_cfg *cfg = arg;
-		struct lnet_peer_ni_credit_info *lpni_cri;
-		struct lnet_ioctl_element_stats *lpni_stats;
-		size_t total = sizeof(*cfg) + sizeof(*lpni_cri) +
-			       sizeof(*lpni_stats);
+		struct lnet_peer_ni_credit_info __user *lpni_cri;
+		struct lnet_ioctl_element_stats __user *lpni_stats;
+		size_t usr_size = sizeof(*lpni_cri) + sizeof(*lpni_stats);
 
-		if (cfg->prcfg_hdr.ioc_len < total)
+		if ((cfg->prcfg_hdr.ioc_len != sizeof(*cfg)) ||
+		    (cfg->prcfg_size != usr_size))
 			return -EINVAL;
 
-		lpni_cri = (struct lnet_peer_ni_credit_info *)cfg->prcfg_bulk;
-		lpni_stats = (struct lnet_ioctl_element_stats *)
-			     (cfg->prcfg_bulk + sizeof(*lpni_cri));
+		lpni_cri = cfg->prcfg_bulk;
+		lpni_stats = cfg->prcfg_bulk + sizeof(*lpni_cri);
 
 		mutex_lock(&the_lnet.ln_api_mutex);
-		rc = lnet_get_peer_info(cfg->prcfg_idx, &cfg->prcfg_prim_nid,
+		rc = lnet_get_peer_info(cfg->prcfg_count, &cfg->prcfg_prim_nid,
 					&cfg->prcfg_cfg_nid, &cfg->prcfg_mr,
 					lpni_cri, lpni_stats);
 		mutex_unlock(&the_lnet.ln_api_mutex);
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 3a5f9db..ae3ffca 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -1179,12 +1179,16 @@ struct lnet_peer_ni *
 }
 
 int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
-		       bool *mr, struct lnet_peer_ni_credit_info *peer_ni_info,
-		       struct lnet_ioctl_element_stats *peer_ni_stats)
+		       bool *mr,
+		       struct lnet_peer_ni_credit_info __user *peer_ni_info,
+		       struct lnet_ioctl_element_stats __user *peer_ni_stats)
 {
+	struct lnet_ioctl_element_stats ni_stats;
+	struct lnet_peer_ni_credit_info ni_info;
 	struct lnet_peer_ni *lpni = NULL;
 	struct lnet_peer_net *lpn = NULL;
 	struct lnet_peer *lp = NULL;
+	int rc;
 
 	lpni = lnet_get_peer_ni_idx_locked(idx, &lpn, &lp);
 
@@ -1194,24 +1198,35 @@ int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
 	*primary_nid = lp->lp_primary_nid;
 	*mr = lp->lp_multi_rail;
 	*nid = lpni->lpni_nid;
-	snprintf(peer_ni_info->cr_aliveness, LNET_MAX_STR_LEN, "NA");
+	snprintf(ni_info.cr_aliveness, LNET_MAX_STR_LEN, "NA");
 	if (lnet_isrouter(lpni) ||
 	    lnet_peer_aliveness_enabled(lpni))
-		snprintf(peer_ni_info->cr_aliveness, LNET_MAX_STR_LEN,
+		snprintf(ni_info.cr_aliveness, LNET_MAX_STR_LEN,
 			 lpni->lpni_alive ? "up" : "down");
 
-	peer_ni_info->cr_refcount = atomic_read(&lpni->lpni_refcount);
-	peer_ni_info->cr_ni_peer_tx_credits = lpni->lpni_net ?
+	ni_info.cr_refcount = atomic_read(&lpni->lpni_refcount);
+	ni_info.cr_ni_peer_tx_credits = lpni->lpni_net ?
 		lpni->lpni_net->net_tunables.lct_peer_tx_credits : 0;
-	peer_ni_info->cr_peer_tx_credits = lpni->lpni_txcredits;
-	peer_ni_info->cr_peer_rtr_credits = lpni->lpni_rtrcredits;
-	peer_ni_info->cr_peer_min_rtr_credits = lpni->lpni_minrtrcredits;
-	peer_ni_info->cr_peer_min_tx_credits = lpni->lpni_mintxcredits;
-	peer_ni_info->cr_peer_tx_qnob = lpni->lpni_txqnob;
+	ni_info.cr_peer_tx_credits = lpni->lpni_txcredits;
+	ni_info.cr_peer_rtr_credits = lpni->lpni_rtrcredits;
+	ni_info.cr_peer_min_rtr_credits = lpni->lpni_minrtrcredits;
+	ni_info.cr_peer_min_tx_credits = lpni->lpni_mintxcredits;
+	ni_info.cr_peer_tx_qnob = lpni->lpni_txqnob;
 
-	peer_ni_stats->send_count = atomic_read(&lpni->lpni_stats.send_count);
-	peer_ni_stats->recv_count = atomic_read(&lpni->lpni_stats.recv_count);
-	peer_ni_stats->drop_count = atomic_read(&lpni->lpni_stats.drop_count);
+	ni_stats.iel_send_count = atomic_read(&lpni->lpni_stats.send_count);
+	ni_stats.iel_recv_count = atomic_read(&lpni->lpni_stats.recv_count);
+	ni_stats.iel_drop_count = atomic_read(&lpni->lpni_stats.drop_count);
 
-	return 0;
+	/* If copy_to_user fails */
+	rc = -EFAULT;
+	if (copy_to_user(peer_ni_info, &ni_info, sizeof(ni_info)))
+		goto copy_failed;
+
+	if (copy_to_user(peer_ni_stats, &ni_stats, sizeof(ni_stats)))
+		goto copy_failed;
+
+	rc = 0;
+
+copy_failed:
+	return rc;
 }
-- 
1.8.3.1
