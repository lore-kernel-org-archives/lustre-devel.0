From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Oct 2018 10:19:38 +1100
Subject: [lustre-devel] [PATCH 22/24] lustre: lnet: add enhanced statistics
In-Reply-To: <153895417139.16383.3791701638653772865.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
Message-ID: <153895437840.16383.11395842984054958152.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

Added statistics to track the different types of
LNet messages which are sent/received/dropped

WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: Olaf Weber <olaf@sgi.com>
Reviewed-on: https://review.whamcloud.com/25795
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   12 ++
 .../staging/lustre/include/linux/lnet/lib-types.h  |   20 +++
 .../lustre/include/uapi/linux/lnet/libcfs_ioctl.h  |    3 -
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   45 +++++++-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |  116 +++++++++++++++++++-
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   16 ++-
 drivers/staging/lustre/lnet/lnet/net_fault.c       |    3 -
 drivers/staging/lustre/lnet/lnet/peer.c            |   26 +++-
 8 files changed, 217 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index adb4d0551ef5..91980f60a50d 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -575,7 +575,7 @@ void lnet_set_reply_msg_len(struct lnet_ni *ni, struct lnet_msg *msg,
 void lnet_finalize(struct lnet_msg *msg, int rc);
 
 void lnet_drop_message(struct lnet_ni *ni, int cpt, void *private,
-		       unsigned int nob);
+		       unsigned int nob, __u32 msg_type);
 void lnet_drop_delayed_msg_list(struct list_head *head, char *reason);
 void lnet_recv_delayed_msg_list(struct list_head *head);
 
@@ -825,4 +825,14 @@ lnet_peer_needs_push(struct lnet_peer *lp)
 	return false;
 }
 
+void lnet_incr_stats(struct lnet_element_stats *stats,
+		     enum lnet_msg_type msg_type,
+		     enum lnet_stats_type stats_type);
+
+__u32 lnet_sum_stats(struct lnet_element_stats *stats,
+		     enum lnet_stats_type stats_type);
+
+void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
+			      struct lnet_element_stats *stats);
+
 #endif
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 8543a67420d7..19f7b11a1e44 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -279,10 +279,24 @@ enum lnet_ni_state {
 	LNET_NI_STATE_DELETING
 };
 
+enum lnet_stats_type {
+	LNET_STATS_TYPE_SEND = 0,
+	LNET_STATS_TYPE_RECV,
+	LNET_STATS_TYPE_DROP
+};
+
+struct lnet_comm_count {
+	atomic_t co_get_count;
+	atomic_t co_put_count;
+	atomic_t co_reply_count;
+	atomic_t co_ack_count;
+	atomic_t co_hello_count;
+};
+
 struct lnet_element_stats {
-	atomic_t	send_count;
-	atomic_t	recv_count;
-	atomic_t	drop_count;
+	struct lnet_comm_count el_send_stats;
+	struct lnet_comm_count el_recv_stats;
+	struct lnet_comm_count el_drop_stats;
 };
 
 struct lnet_net {
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
index 60bc9713923e..4590f65c333f 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -145,6 +145,7 @@ struct libcfs_debug_ioctl_data {
 #define IOC_LIBCFS_SET_NUMA_RANGE	_IOWR(IOC_LIBCFS_TYPE, 98, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_NUMA_RANGE	_IOWR(IOC_LIBCFS_TYPE, 99, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_PEER_LIST	_IOWR(IOC_LIBCFS_TYPE, 100, IOCTL_CONFIG_SIZE)
-#define IOC_LIBCFS_MAX_NR		100
+#define IOC_LIBCFS_GET_LOCAL_NI_MSG_STATS  _IOWR(IOC_LIBCFS_TYPE, 101, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_MAX_NR		101
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 0511c6acb9b1..0852118bf803 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -2263,8 +2263,12 @@ lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_ni *cfg_ni,
 	memcpy(&tun->lt_cmn, &ni->ni_net->net_tunables, sizeof(tun->lt_cmn));
 
 	if (stats) {
-		stats->iel_send_count = atomic_read(&ni->ni_stats.send_count);
-		stats->iel_recv_count = atomic_read(&ni->ni_stats.recv_count);
+		stats->iel_send_count = lnet_sum_stats(&ni->ni_stats,
+						       LNET_STATS_TYPE_SEND);
+		stats->iel_recv_count = lnet_sum_stats(&ni->ni_stats,
+						       LNET_STATS_TYPE_RECV);
+		stats->iel_drop_count = lnet_sum_stats(&ni->ni_stats,
+						       LNET_STATS_TYPE_DROP);
 	}
 
 	/*
@@ -2491,6 +2495,29 @@ lnet_get_ni_config(struct lnet_ioctl_config_ni *cfg_ni,
 	return rc;
 }
 
+int lnet_get_ni_stats(struct lnet_ioctl_element_msg_stats *msg_stats)
+{
+	struct lnet_ni *ni;
+	int cpt;
+	int rc = -ENOENT;
+
+	if (!msg_stats)
+		return -EINVAL;
+
+	cpt = lnet_net_lock_current();
+
+	ni = lnet_get_ni_idx_locked(msg_stats->im_idx);
+
+	if (ni) {
+		lnet_usr_translate_stats(msg_stats, &ni->ni_stats);
+		rc = 0;
+	}
+
+	lnet_net_unlock(cpt);
+
+	return rc;
+}
+
 static int lnet_add_net_common(struct lnet_net *net,
 			       struct lnet_ioctl_config_lnd_tunables *tun)
 {
@@ -2956,6 +2983,7 @@ LNetCtl(unsigned int cmd, void *arg)
 		__u32 tun_size;
 
 		cfg_ni = arg;
+
 		/* get the tunables if they are available */
 		if (cfg_ni->lic_cfg_hdr.ioc_len <
 		    sizeof(*cfg_ni) + sizeof(*stats) + sizeof(*tun))
@@ -2975,6 +3003,19 @@ LNetCtl(unsigned int cmd, void *arg)
 		return rc;
 	}
 
+	case IOC_LIBCFS_GET_LOCAL_NI_MSG_STATS: {
+		struct lnet_ioctl_element_msg_stats *msg_stats = arg;
+
+		if (msg_stats->im_hdr.ioc_len != sizeof(*msg_stats))
+			return -EINVAL;
+
+		mutex_lock(&the_lnet.ln_api_mutex);
+		rc = lnet_get_ni_stats(msg_stats);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+
+		return rc;
+	}
+
 	case IOC_LIBCFS_GET_NET: {
 		size_t total = sizeof(*config) +
 			       sizeof(struct lnet_ioctl_net_config);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 2ff329bf91ba..5694d85c713c 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -45,6 +45,104 @@ static int local_nid_dist_zero = 1;
 module_param(local_nid_dist_zero, int, 0444);
 MODULE_PARM_DESC(local_nid_dist_zero, "Reserved");
 
+static inline struct lnet_comm_count *
+get_stats_counts(struct lnet_element_stats *stats,
+		 enum lnet_stats_type stats_type)
+{
+	switch (stats_type) {
+	case LNET_STATS_TYPE_SEND:
+		return &stats->el_send_stats;
+	case LNET_STATS_TYPE_RECV:
+		return &stats->el_recv_stats;
+	case LNET_STATS_TYPE_DROP:
+		return &stats->el_drop_stats;
+	default:
+		CERROR("Unknown stats type\n");
+	}
+
+	return NULL;
+}
+
+void lnet_incr_stats(struct lnet_element_stats *stats,
+		     enum lnet_msg_type msg_type,
+		     enum lnet_stats_type stats_type)
+{
+	struct lnet_comm_count *counts = get_stats_counts(stats, stats_type);
+
+	if (!counts)
+		return;
+
+	switch (msg_type) {
+	case LNET_MSG_ACK:
+		atomic_inc(&counts->co_ack_count);
+		break;
+	case LNET_MSG_PUT:
+		atomic_inc(&counts->co_put_count);
+		break;
+	case LNET_MSG_GET:
+		atomic_inc(&counts->co_get_count);
+		break;
+	case LNET_MSG_REPLY:
+		atomic_inc(&counts->co_reply_count);
+		break;
+	case LNET_MSG_HELLO:
+		atomic_inc(&counts->co_hello_count);
+		break;
+	default:
+		CERROR("There is a BUG in the code. Unknown message type\n");
+		break;
+	}
+}
+
+__u32 lnet_sum_stats(struct lnet_element_stats *stats,
+		     enum lnet_stats_type stats_type)
+{
+	struct lnet_comm_count *counts = get_stats_counts(stats, stats_type);
+
+	if (!counts)
+		return 0;
+
+	return (atomic_read(&counts->co_ack_count) +
+		atomic_read(&counts->co_put_count) +
+		atomic_read(&counts->co_get_count) +
+		atomic_read(&counts->co_reply_count) +
+		atomic_read(&counts->co_hello_count));
+}
+
+static inline void assign_stats(struct lnet_ioctl_comm_count *msg_stats,
+				struct lnet_comm_count *counts)
+{
+	msg_stats->ico_get_count = atomic_read(&counts->co_get_count);
+	msg_stats->ico_put_count = atomic_read(&counts->co_put_count);
+	msg_stats->ico_reply_count = atomic_read(&counts->co_reply_count);
+	msg_stats->ico_ack_count = atomic_read(&counts->co_ack_count);
+	msg_stats->ico_hello_count = atomic_read(&counts->co_hello_count);
+}
+
+void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
+			      struct lnet_element_stats *stats)
+{
+	struct lnet_comm_count *counts;
+
+	LASSERT(msg_stats);
+	LASSERT(stats);
+
+	counts = get_stats_counts(stats, LNET_STATS_TYPE_SEND);
+	if (!counts)
+		return;
+	assign_stats(&msg_stats->im_send_stats, counts);
+
+	counts = get_stats_counts(stats, LNET_STATS_TYPE_RECV);
+	if (!counts)
+		return;
+	assign_stats(&msg_stats->im_recv_stats, counts);
+
+	counts = get_stats_counts(stats, LNET_STATS_TYPE_DROP);
+	if (!counts)
+		return;
+	assign_stats(&msg_stats->im_drop_stats, counts);
+}
+
 int
 lnet_fail_nid(lnet_nid_t nid, unsigned int threshold)
 {
@@ -632,9 +730,13 @@ lnet_post_send_locked(struct lnet_msg *msg, int do_send)
 		the_lnet.ln_counters[cpt]->drop_length += msg->msg_len;
 		lnet_net_unlock(cpt);
 		if (msg->msg_txpeer)
-			atomic_inc(&msg->msg_txpeer->lpni_stats.drop_count);
+			lnet_incr_stats(&msg->msg_txpeer->lpni_stats,
+					msg->msg_type,
+					LNET_STATS_TYPE_DROP);
 		if (msg->msg_txni)
-			atomic_inc(&msg->msg_txni->ni_stats.drop_count);
+			lnet_incr_stats(&msg->msg_txni->ni_stats,
+					msg->msg_type,
+					LNET_STATS_TYPE_DROP);
 
 		CNETERR("Dropping message for %s: peer not alive\n",
 			libcfs_id2str(msg->msg_target));
@@ -1859,9 +1961,11 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 }
 
 void
-lnet_drop_message(struct lnet_ni *ni, int cpt, void *private, unsigned int nob)
+lnet_drop_message(struct lnet_ni *ni, int cpt, void *private, unsigned int nob,
+		  __u32 msg_type)
 {
 	lnet_net_lock(cpt);
+	lnet_incr_stats(&ni->ni_stats, msg_type, LNET_STATS_TYPE_DROP);
 	the_lnet.ln_counters[cpt]->drop_count++;
 	the_lnet.ln_counters[cpt]->drop_length += nob;
 	lnet_net_unlock(cpt);
@@ -2510,7 +2614,7 @@ lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
 	lnet_finalize(msg, rc);
 
  drop:
-	lnet_drop_message(ni, cpt, private, payload_length);
+	lnet_drop_message(ni, cpt, private, payload_length, type);
 	return 0;
 }
 EXPORT_SYMBOL(lnet_parse);
@@ -2546,7 +2650,8 @@ lnet_drop_delayed_msg_list(struct list_head *head, char *reason)
 		 * until that's done
 		 */
 		lnet_drop_message(msg->msg_rxni, msg->msg_rx_cpt,
-				  msg->msg_private, msg->msg_len);
+				  msg->msg_private, msg->msg_len,
+				  msg->msg_type);
 		/*
 		 * NB: message will not generate event because w/o attached MD,
 		 * but we still should give error code so lnet_msg_decommit()
@@ -2786,6 +2891,7 @@ lnet_create_reply_msg(struct lnet_ni *ni, struct lnet_msg *getmsg)
 	cpt = lnet_cpt_of_nid(peer_id.nid, ni);
 
 	lnet_net_lock(cpt);
+	lnet_incr_stats(&ni->ni_stats, LNET_MSG_GET, LNET_STATS_TYPE_DROP);
 	the_lnet.ln_counters[cpt]->drop_count++;
 	the_lnet.ln_counters[cpt]->drop_length += getmd->md_length;
 	lnet_net_unlock(cpt);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index db13d01d366f..7f58cfe25bc2 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -219,9 +219,13 @@ lnet_msg_decommit_tx(struct lnet_msg *msg, int status)
 
 incr_stats:
 	if (msg->msg_txpeer)
-		atomic_inc(&msg->msg_txpeer->lpni_stats.send_count);
+		lnet_incr_stats(&msg->msg_txpeer->lpni_stats,
+				msg->msg_type,
+				LNET_STATS_TYPE_SEND);
 	if (msg->msg_txni)
-		atomic_inc(&msg->msg_txni->ni_stats.send_count);
+		lnet_incr_stats(&msg->msg_txni->ni_stats,
+				msg->msg_type,
+				LNET_STATS_TYPE_SEND);
  out:
 	lnet_return_tx_credits_locked(msg);
 	msg->msg_tx_committed = 0;
@@ -280,9 +284,13 @@ lnet_msg_decommit_rx(struct lnet_msg *msg, int status)
 
 incr_stats:
 	if (msg->msg_rxpeer)
-		atomic_inc(&msg->msg_rxpeer->lpni_stats.recv_count);
+		lnet_incr_stats(&msg->msg_rxpeer->lpni_stats,
+				msg->msg_type,
+				LNET_STATS_TYPE_RECV);
 	if (msg->msg_rxni)
-		atomic_inc(&msg->msg_rxni->ni_stats.recv_count);
+		lnet_incr_stats(&msg->msg_rxni->ni_stats,
+				msg->msg_type,
+				LNET_STATS_TYPE_RECV);
 	if (ev->type == LNET_EVENT_PUT || ev->type == LNET_EVENT_REPLY)
 		counters->recv_length += msg->msg_wanted;
 
diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
index 3841bac1aa0a..e2c746855da9 100644
--- a/drivers/staging/lustre/lnet/lnet/net_fault.c
+++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
@@ -632,7 +632,8 @@ delayed_msg_process(struct list_head *msg_list, bool drop)
 			}
 		}
 
-		lnet_drop_message(ni, cpt, msg->msg_private, msg->msg_len);
+		lnet_drop_message(ni, cpt, msg->msg_private, msg->msg_len,
+				  msg->msg_type);
 		lnet_finalize(msg, rc);
 	}
 }
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 95f72ae39a89..03c1c34517e4 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -3301,6 +3301,7 @@ int lnet_get_peer_info(lnet_nid_t *primary_nid, lnet_nid_t *nidp,
 		       void __user *bulk)
 {
 	struct lnet_ioctl_element_stats *lpni_stats;
+	struct lnet_ioctl_element_msg_stats *lpni_msg_stats;
 	struct lnet_peer_ni_credit_info *lpni_info;
 	struct lnet_peer_ni *lpni;
 	struct lnet_peer *lp;
@@ -3315,7 +3316,8 @@ int lnet_get_peer_info(lnet_nid_t *primary_nid, lnet_nid_t *nidp,
 		goto out;
 	}
 
-	size = sizeof(nid) + sizeof(*lpni_info) + sizeof(*lpni_stats);
+	size = sizeof(nid) + sizeof(*lpni_info) + sizeof(*lpni_stats)
+		+ sizeof(*lpni_msg_stats);
 	size *= lp->lp_nnis;
 	if (size > *sizep) {
 		*sizep = size;
@@ -3337,13 +3339,17 @@ int lnet_get_peer_info(lnet_nid_t *primary_nid, lnet_nid_t *nidp,
 	lpni_stats = kzalloc(sizeof(*lpni_stats), GFP_KERNEL);
 	if (!lpni_stats)
 		goto out_free_info;
+	lpni_msg_stats = kzalloc(sizeof(*lpni_msg_stats), GFP_KERNEL);
+	if (!lpni_msg_stats)
+		goto out_free_stats;
+
 
 	lpni = NULL;
 	rc = -EFAULT;
 	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL) {
 		nid = lpni->lpni_nid;
 		if (copy_to_user(bulk, &nid, sizeof(nid)))
-			goto out_free_stats;
+			goto out_free_msg_stats;
 		bulk += sizeof(nid);
 
 		memset(lpni_info, 0, sizeof(*lpni_info));
@@ -3362,22 +3368,28 @@ int lnet_get_peer_info(lnet_nid_t *primary_nid, lnet_nid_t *nidp,
 		lpni_info->cr_peer_min_tx_credits = lpni->lpni_mintxcredits;
 		lpni_info->cr_peer_tx_qnob = lpni->lpni_txqnob;
 		if (copy_to_user(bulk, lpni_info, sizeof(*lpni_info)))
-			goto out_free_stats;
+			goto out_free_msg_stats;
 		bulk += sizeof(*lpni_info);
 
 		memset(lpni_stats, 0, sizeof(*lpni_stats));
 		lpni_stats->iel_send_count =
-			atomic_read(&lpni->lpni_stats.send_count);
+			lnet_sum_stats(&lpni->lpni_stats, LNET_STATS_TYPE_SEND);
 		lpni_stats->iel_recv_count =
-			atomic_read(&lpni->lpni_stats.recv_count);
+			lnet_sum_stats(&lpni->lpni_stats, LNET_STATS_TYPE_RECV);
 		lpni_stats->iel_drop_count =
-			atomic_read(&lpni->lpni_stats.drop_count);
+			lnet_sum_stats(&lpni->lpni_stats, LNET_STATS_TYPE_DROP);
 		if (copy_to_user(bulk, lpni_stats, sizeof(*lpni_stats)))
-			goto out_free_stats;
+			goto out_free_msg_stats;
 		bulk += sizeof(*lpni_stats);
+		lnet_usr_translate_stats(lpni_msg_stats, &lpni->lpni_stats);
+		if (copy_to_user(bulk, lpni_msg_stats, sizeof(*lpni_msg_stats)))
+			goto out_free_msg_stats;
+		bulk += sizeof(*lpni_msg_stats);
 	}
 	rc = 0;
 
+out_free_msg_stats:
+	kfree(lpni_msg_stats);
 out_free_stats:
 	kfree(lpni_stats);
 out_free_info:
