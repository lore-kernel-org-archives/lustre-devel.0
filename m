From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:22 -0500
Subject: [lustre-devel] [PATCH 094/622] lnet: add global health statistics
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-95-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Added global health statistics

Print that from lnetctl.

lnetctl stats show

lnet_selftest passes the statistics block over the wire. This,
unfortunately, creates an unnecessary backwards compatibility link
for lnet_selftest, which shouldn't be there. This patch breaks
this backwards compatibility, which means lnet_selftest will
not work with older selftest modules.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 15020fd977af ("LU-9120 lnet: add global health statistics")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32949
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h        |  2 ++
 include/uapi/linux/lnet/lnet-types.h | 13 +++++++++++++
 net/lnet/lnet/api-ni.c               | 13 +++++++++++++
 net/lnet/lnet/lib-move.c             | 11 +++++++++++
 net/lnet/lnet/lib-msg.c              | 28 +++++++++++++++++++++++-----
 5 files changed, 62 insertions(+), 5 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 74660d3..e4d9ccc 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -445,6 +445,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 
 	rspt = kzalloc(sizeof(*rspt), GFP_NOFS);
 	lnet_net_lock(cpt);
+	the_lnet.ln_counters[cpt]->rst_alloc++;
 	lnet_net_unlock(cpt);
 	return rspt;
 }
@@ -454,6 +455,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 {
 	kfree(rspt);
 	lnet_net_lock(cpt);
+	the_lnet.ln_counters[cpt]->rst_alloc--;
 	lnet_net_unlock(cpt);
 }
 
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index 2afdd83..1da72c4 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -278,11 +278,24 @@ struct lnet_ping_info {
 struct lnet_counters {
 	__u32	msgs_alloc;
 	__u32	msgs_max;
+	__u32	rst_alloc;
 	__u32	errors;
 	__u32	send_count;
 	__u32	recv_count;
 	__u32	route_count;
 	__u32	drop_count;
+	__u32	resend_count;
+	__u32	response_timeout_count;
+	__u32	local_interrupt_count;
+	__u32	local_dropped_count;
+	__u32	local_aborted_count;
+	__u32	local_no_route_count;
+	__u32	local_timeout_count;
+	__u32	local_error_count;
+	__u32	remote_dropped_count;
+	__u32	remote_error_count;
+	__u32	remote_timeout_count;
+	__u32	network_timeout_count;
 	__u64	send_length;
 	__u64	recv_length;
 	__u64	route_length;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 82703dd..d58006d 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -694,7 +694,20 @@ static void lnet_assert_wire_constants(void)
 	cfs_percpt_for_each(ctr, i, the_lnet.ln_counters) {
 		counters->msgs_max += ctr->msgs_max;
 		counters->msgs_alloc += ctr->msgs_alloc;
+		counters->rst_alloc += ctr->rst_alloc;
 		counters->errors += ctr->errors;
+		counters->resend_count += ctr->resend_count;
+		counters->response_timeout_count += ctr->response_timeout_count;
+		counters->local_interrupt_count += ctr->local_interrupt_count;
+		counters->local_dropped_count += ctr->local_dropped_count;
+		counters->local_aborted_count += ctr->local_aborted_count;
+		counters->local_no_route_count += ctr->local_no_route_count;
+		counters->local_timeout_count += ctr->local_timeout_count;
+		counters->local_error_count += ctr->local_error_count;
+		counters->remote_dropped_count += ctr->remote_dropped_count;
+		counters->remote_error_count += ctr->remote_error_count;
+		counters->remote_timeout_count += ctr->remote_timeout_count;
+		counters->network_timeout_count += ctr->network_timeout_count;
 		counters->send_count += ctr->send_count;
 		counters->recv_count += ctr->recv_count;
 		counters->route_count += ctr->route_count;
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index c33cf8d..6a3704d 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -2501,6 +2501,10 @@ struct lnet_mt_event_info {
 				md->md_rspt_ptr = NULL;
 				lnet_res_unlock(i);
 
+				lnet_net_lock(i);
+				the_lnet.ln_counters[i]->response_timeout_count++;
+				lnet_net_unlock(i);
+
 				list_del_init(&rspt->rspt_on_list);
 
 				CDEBUG(D_NET,
@@ -2567,6 +2571,11 @@ struct lnet_mt_event_info {
 			lnet_peer_ni_decref_locked(lpni);
 
 			lnet_net_unlock(cpt);
+			CDEBUG(D_NET, "resending %s->%s: %s recovery %d\n",
+			       libcfs_nid2str(src_nid),
+			       libcfs_id2str(msg->msg_target),
+			       lnet_msgtyp2str(msg->msg_type),
+			       msg->msg_recovery);
 			rc = lnet_send(src_nid, msg, LNET_NID_ANY);
 			if (rc) {
 				CERROR("Error sending %s to %s: %d\n",
@@ -2576,6 +2585,8 @@ struct lnet_mt_event_info {
 				lnet_finalize(msg, rc);
 			}
 			lnet_net_lock(cpt);
+			if (!rc)
+				the_lnet.ln_counters[cpt]->resend_count++;
 		}
 	}
 }
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index dc51a17..70decc7 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -546,41 +546,52 @@
 {
 	struct lnet_ni *ni = msg->msg_txni;
 	struct lnet_peer_ni *lpni = msg->msg_txpeer;
+	struct lnet_counters *counters = the_lnet.ln_counters[0];
 
 	switch (hstatus) {
 	case LNET_MSG_STATUS_LOCAL_INTERRUPT:
 		atomic_inc(&ni->ni_hstats.hlt_local_interrupt);
+		counters->local_interrupt_count++;
 		break;
 	case LNET_MSG_STATUS_LOCAL_DROPPED:
 		atomic_inc(&ni->ni_hstats.hlt_local_dropped);
+		counters->local_dropped_count++;
 		break;
 	case LNET_MSG_STATUS_LOCAL_ABORTED:
 		atomic_inc(&ni->ni_hstats.hlt_local_aborted);
+		counters->local_aborted_count++;
 		break;
 	case LNET_MSG_STATUS_LOCAL_NO_ROUTE:
 		atomic_inc(&ni->ni_hstats.hlt_local_no_route);
+		counters->local_no_route_count++;
 		break;
 	case LNET_MSG_STATUS_LOCAL_TIMEOUT:
 		atomic_inc(&ni->ni_hstats.hlt_local_timeout);
+		counters->local_timeout_count++;
 		break;
 	case LNET_MSG_STATUS_LOCAL_ERROR:
 		atomic_inc(&ni->ni_hstats.hlt_local_error);
+		counters->local_error_count++;
 		break;
 	case LNET_MSG_STATUS_REMOTE_DROPPED:
 		if (lpni)
 			atomic_inc(&lpni->lpni_hstats.hlt_remote_dropped);
+		counters->remote_dropped_count++;
 		break;
 	case LNET_MSG_STATUS_REMOTE_ERROR:
 		if (lpni)
 			atomic_inc(&lpni->lpni_hstats.hlt_remote_error);
+		counters->remote_error_count++;
 		break;
 	case LNET_MSG_STATUS_REMOTE_TIMEOUT:
 		if (lpni)
 			atomic_inc(&lpni->lpni_hstats.hlt_remote_timeout);
+		counters->remote_timeout_count++;
 		break;
 	case LNET_MSG_STATUS_NETWORK_TIMEOUT:
 		if (lpni)
 			atomic_inc(&lpni->lpni_hstats.hlt_network_timeout);
+		counters->network_timeout_count++;
 		break;
 	case LNET_MSG_STATUS_OK:
 		break;
@@ -601,6 +612,10 @@
 	enum lnet_msg_hstatus hstatus = msg->msg_health_status;
 	bool lo = false;
 
+	/* if we're shutting down no point in handling health. */
+	if (the_lnet.ln_state != LNET_STATE_RUNNING)
+		return -1;
+
 	LASSERT(msg->msg_txni);
 
 	/* if we're sending to the LOLND then the msg_txpeer will not be
@@ -611,15 +626,18 @@
 	else
 		lo = true;
 
-	lnet_incr_hstats(msg, hstatus);
-
 	if (hstatus != LNET_MSG_STATUS_OK &&
 	    ktime_compare(ktime_get(), msg->msg_deadline) >= 0)
 		return -1;
 
-	/* if we're shutting down no point in handling health. */
-	if (the_lnet.ln_state != LNET_STATE_RUNNING)
-		return -1;
+	/* stats are only incremented for errors so avoid wasting time
+	 * incrementing statistics if there is no error.
+	 */
+	if (hstatus != LNET_MSG_STATUS_OK) {
+		lnet_net_lock(0);
+		lnet_incr_hstats(msg, hstatus);
+		lnet_net_unlock(0);
+	}
 
 	CDEBUG(D_NET, "health check: %s->%s: %s: %s\n",
 	       libcfs_nid2str(msg->msg_txni->ni_nid),
-- 
1.8.3.1
