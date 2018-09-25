From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 17/34] LU-7734 lnet: Add peer_ni and NI stats
 for DLC
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763552.32103.13888609534957205718.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Doug Oucharek <doug.s.oucharek@intel.com>

This patch adds three stats to the peer_ni and NI structures:
send_count, recv_count, and drop_count. These stats get printed
when you do an "lnetctl net show -v" (for NI) and
"lnetctl peer show" (for peer_ni).

Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Change-Id: Ic41c88cbc68dba677151d87a1fab53a48d36ea29
Reviewed-on: http://review.whamcloud.com/20170
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Tested-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    3 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |   11 +++++++
 .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |    6 ++++
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   32 +++++++++++++++-----
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    4 +++
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |    8 +++++
 drivers/staging/lustre/lnet/lnet/peer.c            |    7 ++++
 7 files changed, 61 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 08fc4abad332..53a5ee8632a6 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -664,7 +664,8 @@ bool lnet_peer_is_ni_pref_locked(struct lnet_peer_ni *lpni,
 int lnet_add_peer_ni_to_peer(lnet_nid_t key_nid, lnet_nid_t nid, bool mr);
 int lnet_del_peer_ni_from_peer(lnet_nid_t key_nid, lnet_nid_t nid);
 int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
-		       struct lnet_peer_ni_credit_info *peer_ni_info);
+		       struct lnet_peer_ni_credit_info *peer_ni_info,
+		       struct lnet_ioctl_element_stats *peer_ni_stats);
 int lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
 			  char alivness[LNET_MAX_STR_LEN],
 			  __u32 *cpt_iter, __u32 *refcount,
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index dbcd9b3da914..e17ca716dce1 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -271,6 +271,12 @@ enum lnet_ni_state {
 	LNET_NI_STATE_DELETING
 };
 
+struct lnet_element_stats {
+	atomic_t	send_count;
+	atomic_t	recv_count;
+	atomic_t	drop_count;
+};
+
 struct lnet_net {
 	/* chain on the ln_nets */
 	struct list_head	net_list;
@@ -348,6 +354,9 @@ struct lnet_ni {
 	/* lnd tunables set explicitly */
 	bool ni_lnd_tunables_set;
 
+	/* NI statistics */
+	struct lnet_element_stats ni_stats;
+
 	/* physical device CPT */
 	int			dev_cpt;
 
@@ -403,6 +412,8 @@ struct lnet_peer_ni {
 	struct list_head	 lpni_rtrq;
 	/* chain on router list */
 	struct list_head	 lpni_rtr_list;
+	/* statistics kept on each peer NI */
+	struct lnet_element_stats lpni_stats;
 	/* # tx credits available */
 	int			 lpni_txcredits;
 	struct lnet_peer_net	*lpni_peer_net;
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index 8be322dd4bd2..b31b69c25ef2 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -142,6 +142,12 @@ struct lnet_ioctl_config_data {
 	char cfg_bulk[0];
 };
 
+struct lnet_ioctl_element_stats {
+	u32	send_count;
+	u32	recv_count;
+	u32	drop_count;
+};
+
 /*
  * lnet_ioctl_config_ni
  *  This structure describes an NI configuration. There are multiple components
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 2d5d657de058..a01858374211 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1881,6 +1881,7 @@ static int lnet_handle_dbg_task(struct lnet_ioctl_dbg *dbg,
 static void
 lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_ni *cfg_ni,
 		  struct lnet_ioctl_config_lnd_tunables *tun,
+		  struct lnet_ioctl_element_stats *stats,
 		  __u32 tun_size)
 {
 	size_t min_size = 0;
@@ -1906,6 +1907,11 @@ lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_ni *cfg_ni,
 
 	memcpy(&tun->lt_cmn, &ni->ni_net->net_tunables, sizeof(tun->lt_cmn));
 
+	if (stats) {
+		stats->send_count = atomic_read(&ni->ni_stats.send_count);
+		stats->recv_count = atomic_read(&ni->ni_stats.recv_count);
+	}
+
 	/*
 	 * tun->lt_tun will always be present, but in order to be
 	 * backwards compatible, we need to deal with the cases when
@@ -2102,13 +2108,14 @@ lnet_get_net_config(struct lnet_ioctl_config_data *config)
 int
 lnet_get_ni_config(struct lnet_ioctl_config_ni *cfg_ni,
 		   struct lnet_ioctl_config_lnd_tunables *tun,
+		   struct lnet_ioctl_element_stats *stats,
 		   __u32 tun_size)
 {
 	struct lnet_ni *ni;
 	int cpt;
 	int rc = -ENOENT;
 
-	if (!cfg_ni || !tun)
+	if (!cfg_ni || !tun || !stats)
 		return -EINVAL;
 
 	cpt = lnet_net_lock_current();
@@ -2118,7 +2125,7 @@ lnet_get_ni_config(struct lnet_ioctl_config_ni *cfg_ni,
 	if (ni) {
 		rc = 0;
 		lnet_ni_lock(ni);
-		lnet_fill_ni_info(ni, cfg_ni, tun, tun_size);
+		lnet_fill_ni_info(ni, cfg_ni, tun, stats, tun_size);
 		lnet_ni_unlock(ni);
 	}
 
@@ -2583,20 +2590,24 @@ LNetCtl(unsigned int cmd, void *arg)
 	case IOC_LIBCFS_GET_LOCAL_NI: {
 		struct lnet_ioctl_config_ni *cfg_ni;
 		struct lnet_ioctl_config_lnd_tunables *tun = NULL;
+		struct lnet_ioctl_element_stats *stats;
 		__u32 tun_size;
 
 		cfg_ni = arg;
 		/* get the tunables if they are available */
 		if (cfg_ni->lic_cfg_hdr.ioc_len <
-		    sizeof(*cfg_ni) + sizeof(*tun))
+		    sizeof(*cfg_ni) + sizeof(*stats) + sizeof(*tun))
 			return -EINVAL;
 
+		stats = (struct lnet_ioctl_element_stats *)
+			cfg_ni->lic_bulk;
 		tun = (struct lnet_ioctl_config_lnd_tunables *)
-				cfg_ni->lic_bulk;
+				(cfg_ni->lic_bulk + sizeof(*stats));
 
-		tun_size = cfg_ni->lic_cfg_hdr.ioc_len - sizeof(*cfg_ni);
+		tun_size = cfg_ni->lic_cfg_hdr.ioc_len - sizeof(*cfg_ni) -
+			sizeof(*stats);
 
-		return lnet_get_ni_config(cfg_ni, tun, tun_size);
+		return lnet_get_ni_config(cfg_ni, tun, stats, tun_size);
 	}
 
 	case IOC_LIBCFS_GET_NET: {
@@ -2724,15 +2735,20 @@ LNetCtl(unsigned int cmd, void *arg)
 	case IOC_LIBCFS_GET_PEER_NI: {
 		struct lnet_ioctl_peer_cfg *cfg = arg;
 		struct lnet_peer_ni_credit_info *lpni_cri;
-		size_t total = sizeof(*cfg) + sizeof(*lpni_cri);
+		struct lnet_ioctl_element_stats *lpni_stats;
+		size_t total = sizeof(*cfg) + sizeof(*lpni_cri) +
+			       sizeof(*lpni_stats);
 
 		if (cfg->prcfg_hdr.ioc_len < total)
 			return -EINVAL;
 
 		lpni_cri = (struct lnet_peer_ni_credit_info *)cfg->prcfg_bulk;
+		lpni_stats = (struct lnet_ioctl_element_stats *)
+			     (cfg->prcfg_bulk + sizeof(*lpni_cri));
 
 		return lnet_get_peer_info(cfg->prcfg_idx, &cfg->prcfg_key_nid,
-					  &cfg->prcfg_cfg_nid, lpni_cri);
+					  &cfg->prcfg_cfg_nid, lpni_cri,
+					  lpni_stats);
 	}
 
 	case IOC_LIBCFS_NOTIFY_ROUTER: {
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 6c5bb953a6d3..3f28f3b87176 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -614,6 +614,10 @@ lnet_post_send_locked(struct lnet_msg *msg, int do_send)
 		the_lnet.ln_counters[cpt]->drop_count++;
 		the_lnet.ln_counters[cpt]->drop_length += msg->msg_len;
 		lnet_net_unlock(cpt);
+		if (msg->msg_txpeer)
+			atomic_inc(&msg->msg_txpeer->lpni_stats.drop_count);
+		if (msg->msg_txni)
+			atomic_inc(&msg->msg_txni->ni_stats.drop_count);
 
 		CNETERR("Dropping message for %s: peer not alive\n",
 			libcfs_id2str(msg->msg_target));
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 8628899e1631..aa28b6a12f81 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -215,6 +215,10 @@ lnet_msg_decommit_tx(struct lnet_msg *msg, int status)
 	}
 
 	counters->send_count++;
+	if (msg->msg_txpeer)
+		atomic_inc(&msg->msg_txpeer->lpni_stats.send_count);
+	if (msg->msg_txni)
+		atomic_inc(&msg->msg_txni->ni_stats.send_count);
  out:
 	lnet_return_tx_credits_locked(msg);
 	msg->msg_tx_committed = 0;
@@ -270,6 +274,10 @@ lnet_msg_decommit_rx(struct lnet_msg *msg, int status)
 	}
 
 	counters->recv_count++;
+	if (msg->msg_rxpeer)
+		atomic_inc(&msg->msg_rxpeer->lpni_stats.recv_count);
+	if (msg->msg_rxni)
+		atomic_inc(&msg->msg_rxni->ni_stats.recv_count);
 	if (ev->type == LNET_EVENT_PUT || ev->type == LNET_EVENT_REPLY)
 		counters->recv_length += msg->msg_wanted;
 
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index ecbd276703f1..f626a3fcf00e 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -973,7 +973,8 @@ lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
 }
 
 int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
-		       struct lnet_peer_ni_credit_info *peer_ni_info)
+		       struct lnet_peer_ni_credit_info *peer_ni_info,
+		       struct lnet_ioctl_element_stats *peer_ni_stats)
 {
 	struct lnet_peer_ni *lpni = NULL;
 	struct lnet_peer_net *lpn = NULL;
@@ -1000,5 +1001,9 @@ int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
 	peer_ni_info->cr_peer_min_rtr_credits = lpni->lpni_mintxcredits;
 	peer_ni_info->cr_peer_tx_qnob = lpni->lpni_txqnob;
 
+	peer_ni_stats->send_count = atomic_read(&lpni->lpni_stats.send_count);
+	peer_ni_stats->recv_count = atomic_read(&lpni->lpni_stats.recv_count);
+	peer_ni_stats->drop_count = atomic_read(&lpni->lpni_stats.drop_count);
+
 	return 0;
 }
