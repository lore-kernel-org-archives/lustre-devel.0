From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:14 -0500
Subject: [lustre-devel] [PATCH 086/622] lnet: timeout delayed REPLYs and ACKs
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-87-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When a GET or a PUT which require an ACK are sent, add a response
tracker block on a percpt queue. When the REPLY/ACK are received
then remove the block from the percpt queue. The monitor thread
will wake up periodically to check if any of the blocks have
expired and if so, it will send a timeout event to the ULP and
flag the MD as stale, then unlink.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: a57fa1176e74 ("LU-9120 lnet: timeout delayed REPLYs and ACKs")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32771
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |  20 ++++
 include/linux/lnet/lib-types.h |  20 ++++
 net/lnet/lnet/lib-move.c       | 210 ++++++++++++++++++++++++++++++++++++++++-
 net/lnet/lnet/lib-msg.c        |   9 ++
 4 files changed, 258 insertions(+), 1 deletion(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 5500e3f..c2191e5 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -438,6 +438,25 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 	lnet_net_unlock(0);
 }
 
+static inline struct lnet_rsp_tracker *
+lnet_rspt_alloc(int cpt)
+{
+	struct lnet_rsp_tracker *rspt;
+
+	rspt = kzalloc(sizeof(*rspt), GFP_NOFS);
+	lnet_net_lock(cpt);
+	lnet_net_unlock(cpt);
+	return rspt;
+}
+
+static inline void
+lnet_rspt_free(struct lnet_rsp_tracker *rspt, int cpt)
+{
+	kfree(rspt);
+	lnet_net_lock(cpt);
+	lnet_net_unlock(cpt);
+}
+
 void lnet_ni_free(struct lnet_ni *ni);
 void lnet_net_free(struct lnet_net *net);
 
@@ -614,6 +633,7 @@ struct lnet_msg *lnet_create_reply_msg(struct lnet_ni *ni,
 				       struct lnet_msg *get_msg);
 void lnet_set_reply_msg_len(struct lnet_ni *ni, struct lnet_msg *msg,
 			    unsigned int len);
+void lnet_detach_rsp_tracker(struct lnet_libmd *md, int cpt);
 
 void lnet_finalize(struct lnet_msg *msg, int rc);
 
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 1108e3b..d815a87 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -75,6 +75,17 @@ enum lnet_msg_hstatus {
 	LNET_MSG_STATUS_NETWORK_TIMEOUT
 };
 
+struct lnet_rsp_tracker {
+	/* chain on the waiting list */
+	struct list_head rspt_on_list;
+	/* cpt to lock */
+	int rspt_cpt;
+	/* deadline of the REPLY/ACK */
+	ktime_t rspt_deadline;
+	/* parent MD */
+	struct lnet_handle_md rspt_mdh;
+};
+
 struct lnet_msg {
 	struct list_head	msg_activelist;
 	struct list_head	msg_list;	/* Q for credits/MD */
@@ -201,6 +212,7 @@ struct lnet_libmd {
 	unsigned int		 md_flags;
 	unsigned int		 md_niov;	/* # frags at end of struct */
 	void			*md_user_ptr;
+	struct lnet_rsp_tracker	*md_rspt_ptr;
 	struct lnet_eq		*md_eq;
 	struct lnet_handle_md	 md_bulk_handle;
 	union {
@@ -1102,6 +1114,14 @@ struct lnet {
 	struct list_head		ln_mt_localNIRecovq;
 	/* local NIs to recover */
 	struct list_head		ln_mt_peerNIRecovq;
+	/*
+	 * An array of queues for GET/PUT waiting for REPLY/ACK respectively.
+	 * There are CPT number of queues. Since response trackers will be
+	 * added on the fast path we can't afford to grab the exclusive
+	 * net lock to protect these queues. The CPT will be calculated
+	 * based on the mdh cookie.
+	 */
+	struct list_head		**ln_mt_rstq;
 	/* recovery eq handler */
 	struct lnet_handle_eq		ln_mt_eqh;
 
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 5224490..55cbf57 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -2418,6 +2418,110 @@ struct lnet_mt_event_info {
 	lnet_nid_t mt_nid;
 };
 
+void
+lnet_detach_rsp_tracker(struct lnet_libmd *md, int cpt)
+{
+	struct lnet_rsp_tracker *rspt;
+
+	/* msg has a refcount on the MD so the MD is not going away.
+	 * The rspt queue for the cpt is protected by
+	 * the lnet_net_lock(cpt). cpt is the cpt of the MD cookie.
+	 */
+	lnet_res_lock(cpt);
+	if (!md->md_rspt_ptr) {
+		lnet_res_unlock(cpt);
+		return;
+	}
+	rspt = md->md_rspt_ptr;
+	md->md_rspt_ptr = NULL;
+
+	/* debug code */
+	LASSERT(rspt->rspt_cpt == cpt);
+
+	/* invalidate the handle to indicate that a response has been
+	 * received, which will then lead the monitor thread to clean up
+	 * the rspt block.
+	 */
+	LNetInvalidateMDHandle(&rspt->rspt_mdh);
+	lnet_res_unlock(cpt);
+}
+
+static void
+lnet_finalize_expired_responses(bool force)
+{
+	struct lnet_libmd *md;
+	struct list_head local_queue;
+	struct lnet_rsp_tracker *rspt, *tmp;
+	int i;
+
+	if (!the_lnet.ln_mt_rstq)
+		return;
+
+	cfs_cpt_for_each(i, lnet_cpt_table()) {
+		INIT_LIST_HEAD(&local_queue);
+
+		lnet_net_lock(i);
+		if (!the_lnet.ln_mt_rstq[i]) {
+			lnet_net_unlock(i);
+			continue;
+		}
+		list_splice_init(the_lnet.ln_mt_rstq[i], &local_queue);
+		lnet_net_unlock(i);
+
+		list_for_each_entry_safe(rspt, tmp, &local_queue,
+					 rspt_on_list) {
+			/* The rspt mdh will be invalidated when a response
+			 * is received or whenever we want to discard the
+			 * block the monitor thread will walk the queue
+			 * and clean up any rsts with an invalid mdh.
+			 * The monitor thread will walk the queue until
+			 * the first unexpired rspt block. This means that
+			 * some rspt blocks which received their
+			 * corresponding responses will linger in the
+			 * queue until they are cleaned up eventually.
+			 */
+			lnet_res_lock(i);
+			if (LNetMDHandleIsInvalid(rspt->rspt_mdh)) {
+				lnet_res_unlock(i);
+				list_del_init(&rspt->rspt_on_list);
+				lnet_rspt_free(rspt, i);
+				continue;
+			}
+
+			if (ktime_compare(ktime_get(),
+					  rspt->rspt_deadline) >= 0 ||
+			    force) {
+				md = lnet_handle2md(&rspt->rspt_mdh);
+				if (!md) {
+					LNetInvalidateMDHandle(&rspt->rspt_mdh);
+					lnet_res_unlock(i);
+					list_del_init(&rspt->rspt_on_list);
+					lnet_rspt_free(rspt, i);
+					continue;
+				}
+				LASSERT(md->md_rspt_ptr == rspt);
+				md->md_rspt_ptr = NULL;
+				lnet_res_unlock(i);
+
+				list_del_init(&rspt->rspt_on_list);
+
+				CDEBUG(D_NET,
+				       "Response timed out: md = %p\n", md);
+				LNetMDUnlink(rspt->rspt_mdh);
+				lnet_rspt_free(rspt, i);
+			} else {
+				lnet_res_unlock(i);
+				break;
+			}
+		}
+
+		lnet_net_lock(i);
+		if (!list_empty(&local_queue))
+			list_splice(&local_queue, the_lnet.ln_mt_rstq[i]);
+		lnet_net_unlock(i);
+	}
+}
+
 static void
 lnet_resend_pending_msgs_locked(struct list_head *resendq, int cpt)
 {
@@ -2900,6 +3004,8 @@ struct lnet_mt_event_info {
 static int
 lnet_monitor_thread(void *arg)
 {
+	int wakeup_counter = 0;
+
 	/* The monitor thread takes care of the following:
 	 *  1. Checks the aliveness of routers
 	 *  2. Checks if there are messages on the resend queue to resend
@@ -2915,6 +3021,12 @@ struct lnet_mt_event_info {
 
 		lnet_resend_pending_msgs();
 
+		wakeup_counter++;
+		if (wakeup_counter >= lnet_transaction_timeout / 2) {
+			lnet_finalize_expired_responses(false);
+			wakeup_counter = 0;
+		}
+
 		lnet_recover_local_nis();
 
 		lnet_recover_peer_nis();
@@ -3095,6 +3207,29 @@ struct lnet_mt_event_info {
 	}
 }
 
+static int
+lnet_rsp_tracker_create(void)
+{
+	struct list_head **rstqs;
+
+	rstqs = lnet_create_array_of_queues();
+	if (!rstqs)
+		return -ENOMEM;
+
+	the_lnet.ln_mt_rstq = rstqs;
+
+	return 0;
+}
+
+static void
+lnet_rsp_tracker_clean(void)
+{
+	lnet_finalize_expired_responses(true);
+
+	cfs_percpt_free(the_lnet.ln_mt_rstq);
+	the_lnet.ln_mt_rstq = NULL;
+}
+
 int lnet_monitor_thr_start(void)
 {
 	int rc = 0;
@@ -3107,6 +3242,10 @@ int lnet_monitor_thr_start(void)
 	if (rc)
 		return rc;
 
+	rc = lnet_rsp_tracker_create();
+	if (rc)
+		goto clean_queues;
+
 	rc = LNetEQAlloc(0, lnet_mt_event_handler, &the_lnet.ln_mt_eqh);
 	if (rc != 0) {
 		CERROR("Can't allocate monitor thread EQ: %d\n", rc);
@@ -3141,6 +3280,7 @@ int lnet_monitor_thr_start(void)
 	lnet_router_cleanup();
 free_mem:
 	the_lnet.ln_mt_state = LNET_MT_STATE_SHUTDOWN;
+	lnet_rsp_tracker_clean();
 	lnet_clean_local_ni_recoveryq();
 	lnet_clean_peer_ni_recoveryq();
 	lnet_clean_resendqs();
@@ -3148,6 +3288,7 @@ int lnet_monitor_thr_start(void)
 	LNetInvalidateEQHandle(&the_lnet.ln_mt_eqh);
 	return rc;
 clean_queues:
+	lnet_rsp_tracker_clean();
 	lnet_clean_local_ni_recoveryq();
 	lnet_clean_peer_ni_recoveryq();
 	lnet_clean_resendqs();
@@ -3173,6 +3314,7 @@ void lnet_monitor_thr_stop(void)
 
 	/* perform cleanup tasks */
 	lnet_router_cleanup();
+	lnet_rsp_tracker_clean();
 	lnet_clean_local_ni_recoveryq();
 	lnet_clean_peer_ni_recoveryq();
 	lnet_clean_resendqs();
@@ -3917,6 +4059,41 @@ void lnet_monitor_thr_stop(void)
 	}
 }
 
+static void
+lnet_attach_rsp_tracker(struct lnet_rsp_tracker *rspt, int cpt,
+			struct lnet_libmd *md, struct lnet_handle_md mdh)
+{
+	s64 timeout_ns;
+
+	/* MD has a refcount taken by message so it's not going away.
+	 * The MD however can be looked up. We need to secure the access
+	 * to the md_rspt_ptr by taking the res_lock.
+	 * The rspt can be accessed without protection up to when it gets
+	 * added to the list.
+	 */
+
+	/* debug code */
+	LASSERT(!md->md_rspt_ptr);
+
+	/* we'll use that same event in case we never get a response  */
+	rspt->rspt_mdh = mdh;
+	rspt->rspt_cpt = cpt;
+	timeout_ns = lnet_transaction_timeout * NSEC_PER_SEC;
+	rspt->rspt_deadline = ktime_add_ns(ktime_get(), timeout_ns);
+
+	lnet_res_lock(cpt);
+	/* store the rspt so we can access it when we get the REPLY */
+	md->md_rspt_ptr = rspt;
+	lnet_res_unlock(cpt);
+
+	/* add to the list of tracked responses. It's added to tail of the
+	 * list in order to expire all the older entries first.
+	 */
+	lnet_net_lock(cpt);
+	list_add_tail(&rspt->rspt_on_list, the_lnet.ln_mt_rstq[cpt]);
+	lnet_net_unlock(cpt);
+}
+
 /**
  * Initiate an asynchronous PUT operation.
  *
@@ -3968,6 +4145,7 @@ void lnet_monitor_thr_stop(void)
 	u64 match_bits, unsigned int offset,
 	u64 hdr_data)
 {
+	struct lnet_rsp_tracker *rspt = NULL;
 	struct lnet_msg *msg;
 	struct lnet_libmd *md;
 	int cpt;
@@ -3991,6 +4169,17 @@ void lnet_monitor_thr_stop(void)
 	msg->msg_vmflush = !!(current->flags & PF_MEMALLOC);
 
 	cpt = lnet_cpt_of_cookie(mdh.cookie);
+
+	if (ack == LNET_ACK_REQ) {
+		rspt = lnet_rspt_alloc(cpt);
+		if (!rspt) {
+			CERROR("Dropping PUT to %s: ENOMEM on response tracker\n",
+			       libcfs_id2str(target));
+			return -ENOMEM;
+		}
+		INIT_LIST_HEAD(&rspt->rspt_on_list);
+	}
+
 	lnet_res_lock(cpt);
 
 	md = lnet_handle2md(&mdh);
@@ -4003,6 +4192,7 @@ void lnet_monitor_thr_stop(void)
 			       md->md_me->me_portal);
 		lnet_res_unlock(cpt);
 
+		kfree(rspt);
 		kfree(msg);
 		return -ENOENT;
 	}
@@ -4035,11 +4225,15 @@ void lnet_monitor_thr_stop(void)
 
 	lnet_build_msg_event(msg, LNET_EVENT_SEND);
 
+	if (ack == LNET_ACK_REQ)
+		lnet_attach_rsp_tracker(rspt, cpt, md, mdh);
+
 	rc = lnet_send(self, msg, LNET_NID_ANY);
 	if (rc) {
 		CNETERR("Error sending PUT to %s: %d\n",
 			libcfs_id2str(target), rc);
 		msg->msg_no_resend = true;
+		lnet_detach_rsp_tracker(msg->msg_md, cpt);
 		lnet_finalize(msg, rc);
 	}
 
@@ -4180,6 +4374,7 @@ struct lnet_msg *
 	struct lnet_process_id target, unsigned int portal,
 	u64 match_bits, unsigned int offset, bool recovery)
 {
+	struct lnet_rsp_tracker *rspt;
 	struct lnet_msg *msg;
 	struct lnet_libmd *md;
 	int cpt;
@@ -4201,9 +4396,18 @@ struct lnet_msg *
 		return -ENOMEM;
 	}
 
+	cpt = lnet_cpt_of_cookie(mdh.cookie);
+
+	rspt = lnet_rspt_alloc(cpt);
+	if (!rspt) {
+		CERROR("Dropping GET to %s: ENOMEM on response tracker\n",
+		       libcfs_id2str(target));
+		return -ENOMEM;
+	}
+	INIT_LIST_HEAD(&rspt->rspt_on_list);
+
 	msg->msg_recovery = recovery;
 
-	cpt = lnet_cpt_of_cookie(mdh.cookie);
 	lnet_res_lock(cpt);
 
 	md = lnet_handle2md(&mdh);
@@ -4218,6 +4422,7 @@ struct lnet_msg *
 		lnet_res_unlock(cpt);
 
 		kfree(msg);
+		kfree(rspt);
 		return -ENOENT;
 	}
 
@@ -4242,11 +4447,14 @@ struct lnet_msg *
 
 	lnet_build_msg_event(msg, LNET_EVENT_SEND);
 
+	lnet_attach_rsp_tracker(rspt, cpt, md, mdh);
+
 	rc = lnet_send(self, msg, LNET_NID_ANY);
 	if (rc < 0) {
 		CNETERR("Error sending GET to %s: %d\n",
 			libcfs_id2str(target), rc);
 		msg->msg_no_resend = true;
+		lnet_detach_rsp_tracker(msg->msg_md, cpt);
 		lnet_finalize(msg, rc);
 	}
 
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 9841e14..5046648 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -777,6 +777,15 @@
 
 	msg->msg_ev.status = status;
 
+	/* if this is an ACK or a REPLY then make sure to remove the
+	 * response tracker.
+	 */
+	if (msg->msg_ev.type == LNET_EVENT_REPLY ||
+	    msg->msg_ev.type == LNET_EVENT_ACK) {
+		cpt = lnet_cpt_of_cookie(msg->msg_md->md_lh.lh_cookie);
+		lnet_detach_rsp_tracker(msg->msg_md, cpt);
+	}
+
 	/* if the message is successfully sent, no need to keep the MD around */
 	if (msg->msg_md && !status)
 		lnet_detach_md(msg, status);
-- 
1.8.3.1
