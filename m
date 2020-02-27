From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:19 -0500
Subject: [lustre-devel] [PATCH 151/622] lnet: Decrement health on timeout
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-152-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When a response times out we want to decrement the health of the
immediate next hop peer ni, so we don't use that interface if there
are others available.

When sending a message if there is a response tracker associated
with the MD, store the next-hop-nid there. If the response times
out then we can look up the peer_ni using the cached NID, and
decrement its health value.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11472
Lustre-commit: 139d69141b73 ("LU-11472 lnet: Decrement health on timeout")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33308
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |  1 +
 include/linux/lnet/lib-types.h |  2 ++
 net/lnet/lnet/lib-move.c       | 33 ++++++++++++++++++++++++++++++++-
 net/lnet/lnet/lib-msg.c        | 24 +++++++++++++++---------
 4 files changed, 50 insertions(+), 10 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index a1dad9f..ecacd65 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -641,6 +641,7 @@ void lnet_set_reply_msg_len(struct lnet_ni *ni, struct lnet_msg *msg,
 void lnet_finalize(struct lnet_msg *msg, int rc);
 bool lnet_send_error_simulation(struct lnet_msg *msg,
 				enum lnet_msg_hstatus *hstatus);
+void lnet_handle_remote_failure_locked(struct lnet_peer_ni *lpni);
 
 void lnet_drop_message(struct lnet_ni *ni, int cpt, void *private,
 		       unsigned int nob, u32 msg_type);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index b2159b0..ce0caa9 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -81,6 +81,8 @@ struct lnet_rsp_tracker {
 	struct list_head rspt_on_list;
 	/* cpt to lock */
 	int rspt_cpt;
+	/* nid of next hop */
+	lnet_nid_t rspt_next_hop_nid;
 	/* deadline of the REPLY/ACK */
 	ktime_t rspt_deadline;
 	/* parent MD */
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index bbbcd8d..548ea88 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1432,6 +1432,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	u32 send_case = sd->sd_send_case;
 	int rc;
 	u32 routing = send_case & REMOTE_DST;
+	struct lnet_rsp_tracker *rspt;
 
 	/* Increment sequence number of the selected peer so that we
 	 * pick the next one in Round Robin.
@@ -1515,6 +1516,18 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		msg->msg_hdr.dest_nid = cpu_to_le64(msg->msg_txpeer->lpni_nid);
 	}
 
+	/* if we have response tracker block update it with the next hop
+	 * nid
+	 */
+	if (msg->msg_md) {
+		rspt = msg->msg_md->md_rspt_ptr;
+		if (rspt) {
+			rspt->rspt_next_hop_nid = msg->msg_txpeer->lpni_nid;
+			CDEBUG(D_NET, "rspt_next_hop_nid = %s\n",
+			       libcfs_nid2str(rspt->rspt_next_hop_nid));
+		}
+	}
+
 	rc = lnet_post_send_locked(msg, 0);
 	if (!rc)
 		CDEBUG(D_NET, "TRACE: %s(%s:%s) -> %s(%s:%s) : %s try# %d\n",
@@ -2497,6 +2510,9 @@ struct lnet_mt_event_info {
 			if (ktime_compare(ktime_get(),
 					  rspt->rspt_deadline) >= 0 ||
 			    force) {
+				struct lnet_peer_ni *lpni;
+				lnet_nid_t nid;
+
 				md = lnet_handle2md(&rspt->rspt_mdh);
 				if (!md) {
 					LNetInvalidateMDHandle(&rspt->rspt_mdh);
@@ -2515,9 +2531,24 @@ struct lnet_mt_event_info {
 
 				list_del_init(&rspt->rspt_on_list);
 
-				CNETERR("Response timed out: md = %p\n", md);
+				nid = rspt->rspt_next_hop_nid;
+
+				CNETERR("Response timed out: md = %p: nid = %s\n",
+					md, libcfs_nid2str(nid));
 				LNetMDUnlink(rspt->rspt_mdh);
 				lnet_rspt_free(rspt, i);
+
+				/* If there is a timeout on the response
+				 * from the next hop decrement its health
+				 * value so that we don't use it
+				 */
+				lnet_net_lock(0);
+				lpni = lnet_find_peer_ni_locked(nid);
+				if (lpni) {
+					lnet_handle_remote_failure_locked(lpni);
+					lnet_peer_ni_decref_locked(lpni);
+				}
+				lnet_net_unlock(0);
 			} else {
 				lnet_res_unlock(i);
 				break;
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 433401f..f626ca3 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -519,18 +519,13 @@
 	lnet_net_unlock(0);
 }
 
-static void
-lnet_handle_remote_failure(struct lnet_msg *msg)
+void
+lnet_handle_remote_failure_locked(struct lnet_peer_ni *lpni)
 {
-	struct lnet_peer_ni *lpni;
-
-	lpni = msg->msg_txpeer;
-
 	/* lpni could be NULL if we're in the LOLND case */
 	if (!lpni)
 		return;
 
-	lnet_net_lock(0);
 	lnet_dec_healthv_locked(&lpni->lpni_healthv);
 	/* add the peer NI to the recovery queue if it's not already there
 	 * and it's health value is actually below the maximum. It's
@@ -539,6 +534,17 @@
 	 * invoke recovery
 	 */
 	lnet_peer_ni_add_to_recoveryq_locked(lpni);
+}
+
+static void
+lnet_handle_remote_failure(struct lnet_peer_ni *lpni)
+{
+	/* lpni could be NULL if we're in the LOLND case */
+	if (!lpni)
+		return;
+
+	lnet_net_lock(0);
+	lnet_handle_remote_failure_locked(lpni);
 	lnet_net_unlock(0);
 }
 
@@ -679,13 +685,13 @@
 	 * attempt a resend safely.
 	 */
 	case LNET_MSG_STATUS_REMOTE_DROPPED:
-		lnet_handle_remote_failure(msg);
+		lnet_handle_remote_failure(msg->msg_txpeer);
 		goto resend;
 
 	case LNET_MSG_STATUS_REMOTE_ERROR:
 	case LNET_MSG_STATUS_REMOTE_TIMEOUT:
 	case LNET_MSG_STATUS_NETWORK_TIMEOUT:
-		lnet_handle_remote_failure(msg);
+		lnet_handle_remote_failure(msg->msg_txpeer);
 		return -1;
 	default:
 		LBUG();
-- 
1.8.3.1
