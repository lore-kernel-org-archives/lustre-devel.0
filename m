From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:03 -0500
Subject: [lustre-devel] [PATCH 135/622] lnet: Fix selftest backward
 compatibility post health
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-136-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sonia Sharma <sharmaso@whamcloud.com>

Post LNet health feature landing, lnet-selftest loses
backward compatibility. This patch fixes that by
adding a new structure lnet_counters_common similar
to lnet_counters(pre-Health version). Now,
lnet_counters_common is the struct that selftest depends on.

Also, adds a struct lnet_counters_health specifically
for health stats.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11422
Lustre-commit: 60f6f2b480b4 ("LU-11422 lnet: Fix selftest backward compatibility post health")
Signed-off-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33242
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h        |  5 ++-
 include/uapi/linux/lnet/lnet-types.h | 58 +++++++++++++++------------
 net/lnet/lnet/api-ni.c               | 78 +++++++++++++++++++++++++-----------
 net/lnet/lnet/lib-move.c             | 18 +++++----
 net/lnet/lnet/lib-msg.c              | 57 +++++++++++++-------------
 net/lnet/lnet/router_proc.c          | 14 ++++---
 net/lnet/selftest/framework.c        | 28 ++++++-------
 net/lnet/selftest/rpc.h              | 10 ++---
 8 files changed, 157 insertions(+), 111 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 4915a87..a1dad9f 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -445,7 +445,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 
 	rspt = kzalloc(sizeof(*rspt), GFP_NOFS);
 	lnet_net_lock(cpt);
-	the_lnet.ln_counters[cpt]->rst_alloc++;
+	the_lnet.ln_counters[cpt]->lct_health.lch_rst_alloc++;
 	lnet_net_unlock(cpt);
 	return rspt;
 }
@@ -455,7 +455,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 {
 	kfree(rspt);
 	lnet_net_lock(cpt);
-	the_lnet.ln_counters[cpt]->rst_alloc--;
+	the_lnet.ln_counters[cpt]->lct_health.lch_rst_alloc--;
 	lnet_net_unlock(cpt);
 }
 
@@ -675,6 +675,7 @@ int lnet_delay_rule_list(int pos, struct lnet_fault_attr *attr,
 
 /** @} lnet_fault_simulation */
 
+void lnet_counters_get_common(struct lnet_counters_common *common);
 void lnet_counters_get(struct lnet_counters *counters);
 void lnet_counters_reset(void);
 
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index 1da72c4..cf263b9 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -275,33 +275,41 @@ struct lnet_ping_info {
 #define LNET_PING_INFO_LONI(PINFO)	((PINFO)->pi_ni[0].ns_nid)
 #define LNET_PING_INFO_SEQNO(PINFO)	((PINFO)->pi_ni[0].ns_status)
 
-struct lnet_counters {
-	__u32	msgs_alloc;
-	__u32	msgs_max;
-	__u32	rst_alloc;
-	__u32	errors;
-	__u32	send_count;
-	__u32	recv_count;
-	__u32	route_count;
-	__u32	drop_count;
-	__u32	resend_count;
-	__u32	response_timeout_count;
-	__u32	local_interrupt_count;
-	__u32	local_dropped_count;
-	__u32	local_aborted_count;
-	__u32	local_no_route_count;
-	__u32	local_timeout_count;
-	__u32	local_error_count;
-	__u32	remote_dropped_count;
-	__u32	remote_error_count;
-	__u32	remote_timeout_count;
-	__u32	network_timeout_count;
-	__u64	send_length;
-	__u64	recv_length;
-	__u64	route_length;
-	__u64	drop_length;
+struct lnet_counters_common {
+	__u32	lcc_msgs_alloc;
+	__u32	lcc_msgs_max;
+	__u32	lcc_errors;
+	__u32	lcc_send_count;
+	__u32	lcc_recv_count;
+	__u32	lcc_route_count;
+	__u32	lcc_drop_count;
+	__u64	lcc_send_length;
+	__u64	lcc_recv_length;
+	__u64	lcc_route_length;
+	__u64	lcc_drop_length;
 } __packed;
 
+struct lnet_counters_health {
+	__u32	lch_rst_alloc;
+	__u32	lch_resend_count;
+	__u32	lch_response_timeout_count;
+	__u32	lch_local_interrupt_count;
+	__u32	lch_local_dropped_count;
+	__u32	lch_local_aborted_count;
+	__u32	lch_local_no_route_count;
+	__u32	lch_local_timeout_count;
+	__u32	lch_local_error_count;
+	__u32	lch_remote_dropped_count;
+	__u32	lch_remote_error_count;
+	__u32	lch_remote_timeout_count;
+	__u32	lch_network_timeout_count;
+};
+
+struct lnet_counters {
+	struct lnet_counters_common lct_common;
+	struct lnet_counters_health lct_health;
+};
+
 #define LNET_NI_STATUS_UP	0x15aac0de
 #define LNET_NI_STATUS_DOWN	0xdeadface
 #define LNET_NI_STATUS_INVALID	0x00000000
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index c81f46f..21e0175 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -682,40 +682,70 @@ static void lnet_assert_wire_constants(void)
 EXPORT_SYMBOL(lnet_unregister_lnd);
 
 void
+lnet_counters_get_common(struct lnet_counters_common *common)
+{
+	struct lnet_counters *ctr;
+	int i;
+
+	memset(common, 0, sizeof(*common));
+
+	lnet_net_lock(LNET_LOCK_EX);
+
+	cfs_percpt_for_each(ctr, i, the_lnet.ln_counters) {
+		common->lcc_msgs_max	 += ctr->lct_common.lcc_msgs_max;
+		common->lcc_msgs_alloc   += ctr->lct_common.lcc_msgs_alloc;
+		common->lcc_errors       += ctr->lct_common.lcc_errors;
+		common->lcc_send_count   += ctr->lct_common.lcc_send_count;
+		common->lcc_recv_count   += ctr->lct_common.lcc_recv_count;
+		common->lcc_route_count  += ctr->lct_common.lcc_route_count;
+		common->lcc_drop_count   += ctr->lct_common.lcc_drop_count;
+		common->lcc_send_length  += ctr->lct_common.lcc_send_length;
+		common->lcc_recv_length  += ctr->lct_common.lcc_recv_length;
+		common->lcc_route_length += ctr->lct_common.lcc_route_length;
+		common->lcc_drop_length  += ctr->lct_common.lcc_drop_length;
+	}
+	lnet_net_unlock(LNET_LOCK_EX);
+}
+EXPORT_SYMBOL(lnet_counters_get_common);
+
+void
 lnet_counters_get(struct lnet_counters *counters)
 {
 	struct lnet_counters *ctr;
+	struct lnet_counters_health *health = &counters->lct_health;
 	int i;
 
 	memset(counters, 0, sizeof(*counters));
 
+	lnet_counters_get_common(&counters->lct_common);
+
 	lnet_net_lock(LNET_LOCK_EX);
 
 	cfs_percpt_for_each(ctr, i, the_lnet.ln_counters) {
-		counters->msgs_max += ctr->msgs_max;
-		counters->msgs_alloc += ctr->msgs_alloc;
-		counters->rst_alloc += ctr->rst_alloc;
-		counters->errors += ctr->errors;
-		counters->resend_count += ctr->resend_count;
-		counters->response_timeout_count += ctr->response_timeout_count;
-		counters->local_interrupt_count += ctr->local_interrupt_count;
-		counters->local_dropped_count += ctr->local_dropped_count;
-		counters->local_aborted_count += ctr->local_aborted_count;
-		counters->local_no_route_count += ctr->local_no_route_count;
-		counters->local_timeout_count += ctr->local_timeout_count;
-		counters->local_error_count += ctr->local_error_count;
-		counters->remote_dropped_count += ctr->remote_dropped_count;
-		counters->remote_error_count += ctr->remote_error_count;
-		counters->remote_timeout_count += ctr->remote_timeout_count;
-		counters->network_timeout_count += ctr->network_timeout_count;
-		counters->send_count += ctr->send_count;
-		counters->recv_count += ctr->recv_count;
-		counters->route_count += ctr->route_count;
-		counters->drop_count += ctr->drop_count;
-		counters->send_length += ctr->send_length;
-		counters->recv_length += ctr->recv_length;
-		counters->route_length += ctr->route_length;
-		counters->drop_length += ctr->drop_length;
+		health->lch_rst_alloc += ctr->lct_health.lch_rst_alloc;
+		health->lch_resend_count += ctr->lct_health.lch_resend_count;
+		health->lch_response_timeout_count +=
+				ctr->lct_health.lch_response_timeout_count;
+		health->lch_local_interrupt_count +=
+				ctr->lct_health.lch_local_interrupt_count;
+		health->lch_local_dropped_count +=
+				ctr->lct_health.lch_local_dropped_count;
+		health->lch_local_aborted_count +=
+				ctr->lct_health.lch_local_aborted_count;
+		health->lch_local_no_route_count +=
+				ctr->lct_health.lch_local_no_route_count;
+		health->lch_local_timeout_count +=
+				ctr->lct_health.lch_local_timeout_count;
+		health->lch_local_error_count +=
+				ctr->lct_health.lch_local_error_count;
+		health->lch_remote_dropped_count +=
+				ctr->lct_health.lch_remote_dropped_count;
+		health->lch_remote_error_count +=
+				ctr->lct_health.lch_remote_error_count;
+		health->lch_remote_timeout_count +=
+				ctr->lct_health.lch_remote_timeout_count;
+		health->lch_network_timeout_count +=
+				ctr->lct_health.lch_network_timeout_count;
 	}
 	lnet_net_unlock(LNET_LOCK_EX);
 }
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 84a30e0..38ee970 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -755,8 +755,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	/* NB 'lp' is always the next hop */
 	if (!(msg->msg_target.pid & LNET_PID_USERFLAG) &&
 	    !lnet_peer_alive_locked(ni, lp, msg)) {
-		the_lnet.ln_counters[cpt]->drop_count++;
-		the_lnet.ln_counters[cpt]->drop_length += msg->msg_len;
+		the_lnet.ln_counters[cpt]->lct_common.lcc_drop_count++;
+		the_lnet.ln_counters[cpt]->lct_common.lcc_drop_length +=
+			msg->msg_len;
 		lnet_net_unlock(cpt);
 		if (msg->msg_txpeer)
 			lnet_incr_stats(&msg->msg_txpeer->lpni_stats,
@@ -2510,7 +2511,7 @@ struct lnet_mt_event_info {
 				lnet_res_unlock(i);
 
 				lnet_net_lock(i);
-				the_lnet.ln_counters[i]->response_timeout_count++;
+				the_lnet.ln_counters[i]->lct_health.lch_response_timeout_count++;
 				lnet_net_unlock(i);
 
 				list_del_init(&rspt->rspt_on_list);
@@ -2595,7 +2596,7 @@ struct lnet_mt_event_info {
 			}
 			lnet_net_lock(cpt);
 			if (!rc)
-				the_lnet.ln_counters[cpt]->resend_count++;
+				the_lnet.ln_counters[cpt]->lct_health.lch_resend_count++;
 		}
 	}
 }
@@ -3346,8 +3347,8 @@ void lnet_monitor_thr_stop(void)
 {
 	lnet_net_lock(cpt);
 	lnet_incr_stats(&ni->ni_stats, msg_type, LNET_STATS_TYPE_DROP);
-	the_lnet.ln_counters[cpt]->drop_count++;
-	the_lnet.ln_counters[cpt]->drop_length += nob;
+	the_lnet.ln_counters[cpt]->lct_common.lcc_drop_count++;
+	the_lnet.ln_counters[cpt]->lct_common.lcc_drop_length += nob;
 	lnet_net_unlock(cpt);
 
 	lnet_ni_recv(ni, private, NULL, 0, 0, 0, nob);
@@ -4329,8 +4330,9 @@ struct lnet_msg *
 
 	lnet_net_lock(cpt);
 	lnet_incr_stats(&ni->ni_stats, LNET_MSG_GET, LNET_STATS_TYPE_DROP);
-	the_lnet.ln_counters[cpt]->drop_count++;
-	the_lnet.ln_counters[cpt]->drop_length += getmd->md_length;
+	the_lnet.ln_counters[cpt]->lct_common.lcc_drop_count++;
+	the_lnet.ln_counters[cpt]->lct_common.lcc_drop_length +=
+		getmd->md_length;
 	lnet_net_unlock(cpt);
 
 	kfree(msg);
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 9b52549..433401f 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -140,7 +140,7 @@
 lnet_msg_commit(struct lnet_msg *msg, int cpt)
 {
 	struct lnet_msg_container *container = the_lnet.ln_msg_containers[cpt];
-	struct lnet_counters *counters = the_lnet.ln_counters[cpt];
+	struct lnet_counters_common *common;
 	s64 timeout_ns;
 
 	/* set the message deadline */
@@ -169,30 +169,31 @@
 	msg->msg_onactivelist = 1;
 	list_add_tail(&msg->msg_activelist, &container->msc_active);
 
-	counters->msgs_alloc++;
-	if (counters->msgs_alloc > counters->msgs_max)
-		counters->msgs_max = counters->msgs_alloc;
+	common = &the_lnet.ln_counters[cpt]->lct_common;
+	common->lcc_msgs_alloc++;
+	if (common->lcc_msgs_alloc > common->lcc_msgs_max)
+		common->lcc_msgs_max = common->lcc_msgs_alloc;
 }
 
 static void
 lnet_msg_decommit_tx(struct lnet_msg *msg, int status)
 {
-	struct lnet_counters *counters;
+	struct lnet_counters_common *common;
 	struct lnet_event *ev = &msg->msg_ev;
 
 	LASSERT(msg->msg_tx_committed);
 	if (status)
 		goto out;
 
-	counters = the_lnet.ln_counters[msg->msg_tx_cpt];
+	common = &the_lnet.ln_counters[msg->msg_tx_cpt]->lct_common;
 	switch (ev->type) {
 	default: /* routed message */
 		LASSERT(msg->msg_routing);
 		LASSERT(msg->msg_rx_committed);
 		LASSERT(!ev->type);
 
-		counters->route_length += msg->msg_len;
-		counters->route_count++;
+		common->lcc_route_length += msg->msg_len;
+		common->lcc_route_count++;
 		goto incr_stats;
 
 	case LNET_EVENT_PUT:
@@ -206,7 +207,7 @@
 	case LNET_EVENT_SEND:
 		LASSERT(!msg->msg_rx_committed);
 		if (msg->msg_type == LNET_MSG_PUT)
-			counters->send_length += msg->msg_len;
+			common->lcc_send_length += msg->msg_len;
 		break;
 
 	case LNET_EVENT_GET:
@@ -220,7 +221,7 @@
 		break;
 	}
 
-	counters->send_count++;
+	common->lcc_send_count++;
 
 incr_stats:
 	if (msg->msg_txpeer)
@@ -239,7 +240,7 @@
 static void
 lnet_msg_decommit_rx(struct lnet_msg *msg, int status)
 {
-	struct lnet_counters *counters;
+	struct lnet_counters_common *common;
 	struct lnet_event *ev = &msg->msg_ev;
 
 	LASSERT(!msg->msg_tx_committed); /* decommitted or never committed */
@@ -248,7 +249,7 @@
 	if (status)
 		goto out;
 
-	counters = the_lnet.ln_counters[msg->msg_rx_cpt];
+	common = &the_lnet.ln_counters[msg->msg_rx_cpt]->lct_common;
 	switch (ev->type) {
 	default:
 		LASSERT(!ev->type);
@@ -268,7 +269,7 @@
 		 */
 		LASSERT(msg->msg_type == LNET_MSG_REPLY ||
 			msg->msg_type == LNET_MSG_GET);
-		counters->send_length += msg->msg_wanted;
+		common->lcc_send_length += msg->msg_wanted;
 		break;
 
 	case LNET_EVENT_PUT:
@@ -285,7 +286,7 @@
 		break;
 	}
 
-	counters->recv_count++;
+	common->lcc_recv_count++;
 
 incr_stats:
 	if (msg->msg_rxpeer)
@@ -297,7 +298,7 @@
 				msg->msg_type,
 				LNET_STATS_TYPE_RECV);
 	if (ev->type == LNET_EVENT_PUT || ev->type == LNET_EVENT_REPLY)
-		counters->recv_length += msg->msg_wanted;
+		common->lcc_recv_length += msg->msg_wanted;
 
 out:
 	lnet_return_rx_credits_locked(msg);
@@ -330,7 +331,7 @@
 	list_del(&msg->msg_activelist);
 	msg->msg_onactivelist = 0;
 
-	the_lnet.ln_counters[cpt2]->msgs_alloc--;
+	the_lnet.ln_counters[cpt2]->lct_common.lcc_msgs_alloc--;
 
 	if (cpt2 != cpt) {
 		lnet_net_unlock(cpt2);
@@ -546,52 +547,54 @@
 {
 	struct lnet_ni *ni = msg->msg_txni;
 	struct lnet_peer_ni *lpni = msg->msg_txpeer;
-	struct lnet_counters *counters = the_lnet.ln_counters[0];
+	struct lnet_counters_health *health;
+
+	health = &the_lnet.ln_counters[0]->lct_health;
 
 	switch (hstatus) {
 	case LNET_MSG_STATUS_LOCAL_INTERRUPT:
 		atomic_inc(&ni->ni_hstats.hlt_local_interrupt);
-		counters->local_interrupt_count++;
+		health->lch_local_interrupt_count++;
 		break;
 	case LNET_MSG_STATUS_LOCAL_DROPPED:
 		atomic_inc(&ni->ni_hstats.hlt_local_dropped);
-		counters->local_dropped_count++;
+		health->lch_local_dropped_count++;
 		break;
 	case LNET_MSG_STATUS_LOCAL_ABORTED:
 		atomic_inc(&ni->ni_hstats.hlt_local_aborted);
-		counters->local_aborted_count++;
+		health->lch_local_aborted_count++;
 		break;
 	case LNET_MSG_STATUS_LOCAL_NO_ROUTE:
 		atomic_inc(&ni->ni_hstats.hlt_local_no_route);
-		counters->local_no_route_count++;
+		health->lch_local_no_route_count++;
 		break;
 	case LNET_MSG_STATUS_LOCAL_TIMEOUT:
 		atomic_inc(&ni->ni_hstats.hlt_local_timeout);
-		counters->local_timeout_count++;
+		health->lch_local_timeout_count++;
 		break;
 	case LNET_MSG_STATUS_LOCAL_ERROR:
 		atomic_inc(&ni->ni_hstats.hlt_local_error);
-		counters->local_error_count++;
+		health->lch_local_error_count++;
 		break;
 	case LNET_MSG_STATUS_REMOTE_DROPPED:
 		if (lpni)
 			atomic_inc(&lpni->lpni_hstats.hlt_remote_dropped);
-		counters->remote_dropped_count++;
+		health->lch_remote_dropped_count++;
 		break;
 	case LNET_MSG_STATUS_REMOTE_ERROR:
 		if (lpni)
 			atomic_inc(&lpni->lpni_hstats.hlt_remote_error);
-		counters->remote_error_count++;
+		health->lch_remote_error_count++;
 		break;
 	case LNET_MSG_STATUS_REMOTE_TIMEOUT:
 		if (lpni)
 			atomic_inc(&lpni->lpni_hstats.hlt_remote_timeout);
-		counters->remote_timeout_count++;
+		health->lch_remote_timeout_count++;
 		break;
 	case LNET_MSG_STATUS_NETWORK_TIMEOUT:
 		if (lpni)
 			atomic_inc(&lpni->lpni_hstats.hlt_network_timeout);
-		counters->network_timeout_count++;
+		health->lch_network_timeout_count++;
 		break;
 	case LNET_MSG_STATUS_OK:
 		break;
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index ebe7993..45abcfb 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -79,6 +79,7 @@ static int proc_lnet_stats(struct ctl_table *table, int write,
 {
 	int rc;
 	struct lnet_counters *ctrs;
+	struct lnet_counters_common common;
 	size_t nob = *lenp;
 	loff_t pos = *ppos;
 	int len;
@@ -102,15 +103,16 @@ static int proc_lnet_stats(struct ctl_table *table, int write,
 	}
 
 	lnet_counters_get(ctrs);
+	common = ctrs->lct_common;
 
 	len = snprintf(tmpstr, tmpsiz,
 		       "%u %u %u %u %u %u %u %llu %llu %llu %llu",
-		       ctrs->msgs_alloc, ctrs->msgs_max,
-		       ctrs->errors,
-		       ctrs->send_count, ctrs->recv_count,
-		       ctrs->route_count, ctrs->drop_count,
-		       ctrs->send_length, ctrs->recv_length,
-		       ctrs->route_length, ctrs->drop_length);
+		       common.lcc_msgs_alloc, common.lcc_msgs_max,
+		       common.lcc_errors,
+		       common.lcc_send_count, common.lcc_recv_count,
+		       common.lcc_route_count, common.lcc_drop_count,
+		       common.lcc_send_length, common.lcc_recv_length,
+		       common.lcc_route_length, common.lcc_drop_length);
 
 	if (pos >= min_t(int, len, strlen(tmpstr)))
 		rc = 0;
diff --git a/net/lnet/selftest/framework.c b/net/lnet/selftest/framework.c
index c8c42b9..00e7363 100644
--- a/net/lnet/selftest/framework.c
+++ b/net/lnet/selftest/framework.c
@@ -82,19 +82,19 @@
 	__swab64s(&(rc).bulk_put);	\
 } while (0)
 
-#define sfw_unpack_lnet_counters(lc)	\
-do {					\
-	__swab32s(&(lc).errors);	\
-	__swab32s(&(lc).msgs_max);	\
-	__swab32s(&(lc).msgs_alloc);	\
-	__swab32s(&(lc).send_count);	\
-	__swab32s(&(lc).recv_count);	\
-	__swab32s(&(lc).drop_count);	\
-	__swab32s(&(lc).route_count);	\
-	__swab64s(&(lc).send_length);	\
-	__swab64s(&(lc).recv_length);	\
-	__swab64s(&(lc).drop_length);	\
-	__swab64s(&(lc).route_length);	\
+#define sfw_unpack_lnet_counters(lc)		\
+do {						\
+	__swab32s(&(lc).lcc_errors);		\
+	__swab32s(&(lc).lcc_msgs_max);		\
+	__swab32s(&(lc).lcc_msgs_alloc);	\
+	__swab32s(&(lc).lcc_send_count);	\
+	__swab32s(&(lc).lcc_recv_count);	\
+	__swab32s(&(lc).lcc_drop_count);	\
+	__swab32s(&(lc).lcc_route_count);	\
+	__swab64s(&(lc).lcc_send_length);	\
+	__swab64s(&(lc).lcc_recv_length);	\
+	__swab64s(&(lc).lcc_drop_length);	\
+	__swab64s(&(lc).lcc_route_length);	\
 } while (0)
 
 #define sfw_test_active(t)	(atomic_read(&(t)->tsi_nactive))
@@ -377,7 +377,7 @@
 		return 0;
 	}
 
-	lnet_counters_get(&reply->str_lnet);
+	lnet_counters_get_common(&reply->str_lnet);
 	srpc_get_counters(&reply->str_rpc);
 
 	/*
diff --git a/net/lnet/selftest/rpc.h b/net/lnet/selftest/rpc.h
index 8ccae3a..6d07452 100644
--- a/net/lnet/selftest/rpc.h
+++ b/net/lnet/selftest/rpc.h
@@ -160,11 +160,11 @@ struct srpc_stat_reqst {
 } __packed;
 
 struct srpc_stat_reply {
-	u32		   str_status;
-	struct lst_sid	   str_sid;
-	struct sfw_counters	str_fw;
-	struct srpc_counters	str_rpc;
-	struct lnet_counters    str_lnet;
+	u32			    str_status;
+	struct lst_sid		    str_sid;
+	struct sfw_counters	    str_fw;
+	struct srpc_counters	    str_rpc;
+	struct lnet_counters_common str_lnet;
 } __packed;
 
 struct test_bulk_req {
-- 
1.8.3.1
