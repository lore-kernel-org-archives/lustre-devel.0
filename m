From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:02 -0500
Subject: [lustre-devel] [PATCH 434/622] lnet: handle recursion in resend
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-435-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When we're resending a message we have to decommit it first. This
could potentially result in another message being picked up from the
queue and sent, which could fail immediately and be finalized, causing
recursion. This problem was observed when a router was being shutdown.

This patch uses the same mechanism used in lnet_finalize() to limit
recursion. If a thread is already finalizing a message and it gets
into path where it starts finalizing a second, then that message
is queued and handled later.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12402
Lustre-commit: ad9243693c9a ("LU-12402 lnet: handle recursion in resend")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35431
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |   4 +
 net/lnet/lnet/lib-msg.c        | 292 +++++++++++++++++++++++++++--------------
 2 files changed, 194 insertions(+), 102 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 904ef7a..3f81928 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -985,9 +985,13 @@ struct lnet_msg_container {
 	int			  msc_nfinalizers;
 	/* msgs waiting to complete finalizing */
 	struct list_head	  msc_finalizing;
+	/* msgs waiting to be resent */
+	struct list_head	  msc_resending;
 	struct list_head	  msc_active;	/* active message list */
 	/* threads doing finalization */
 	void			**msc_finalizers;
+	/* threads doing resends */
+	void			**msc_resenders;
 };
 
 /* Peer Discovery states */
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 0d6c363..5c39ce3 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -597,6 +597,168 @@
 	}
 }
 
+static void
+lnet_resend_msg_locked(struct lnet_msg *msg)
+{
+	msg->msg_retry_count++;
+
+	/* remove message from the active list and reset it to prepare
+	 * for a resend. Two exceptions to this
+	 *
+	 * 1. the router case. When a message is being routed it is
+	 * committed for rx when received and committed for tx when
+	 * forwarded. We don't want to remove it from the active list, since
+	 * code which handles receiving expects it to remain on the active
+	 * list.
+	 *
+	 * 2. The REPLY case. Reply messages use the same message
+	 * structure for the GET that was received.
+	 */
+	if (!msg->msg_routing && msg->msg_type != LNET_MSG_REPLY) {
+		list_del_init(&msg->msg_activelist);
+		msg->msg_onactivelist = 0;
+	}
+
+	/* The msg_target.nid which was originally set
+	 * when calling LNetGet() or LNetPut() might've
+	 * been overwritten if we're routing this message.
+	 * Call lnet_msg_decommit_tx() to return the credit
+	 * this message consumed. The message will
+	 * consume another credit when it gets resent.
+	 */
+	msg->msg_target.nid = msg->msg_hdr.dest_nid;
+	lnet_msg_decommit_tx(msg, -EAGAIN);
+	msg->msg_sending = 0;
+	msg->msg_receiving = 0;
+	msg->msg_target_is_router = 0;
+
+	CDEBUG(D_NET, "%s->%s:%s:%s - queuing msg (%p) for resend\n",
+	       libcfs_nid2str(msg->msg_hdr.src_nid),
+	       libcfs_nid2str(msg->msg_hdr.dest_nid),
+	       lnet_msgtyp2str(msg->msg_type),
+	       lnet_health_error2str(msg->msg_health_status), msg);
+
+	list_add_tail(&msg->msg_list, the_lnet.ln_mt_resendqs[msg->msg_tx_cpt]);
+
+	wake_up(&the_lnet.ln_mt_waitq);
+}
+
+int
+lnet_check_finalize_recursion_locked(struct lnet_msg *msg,
+				     struct list_head *containerq,
+				     int nworkers, void **workers)
+{
+	int my_slot = -1;
+	int i;
+
+	list_add_tail(&msg->msg_list, containerq);
+
+	for (i = 0; i < nworkers; i++) {
+		if (workers[i] == current)
+			break;
+
+		if (my_slot < 0 && !workers[i])
+			my_slot = i;
+	}
+
+	if (i < nworkers || my_slot < 0)
+		return -1;
+
+	workers[my_slot] = current;
+
+	return my_slot;
+}
+
+int
+lnet_attempt_msg_resend(struct lnet_msg *msg)
+{
+	struct lnet_msg_container *container;
+	int my_slot;
+	int cpt;
+
+	/* we can only resend tx_committed messages */
+	LASSERT(msg->msg_tx_committed);
+
+	/* don't resend recovery messages */
+	if (msg->msg_recovery) {
+		CDEBUG(D_NET, "msg %s->%s is a recovery ping. retry# %d\n",
+		       libcfs_nid2str(msg->msg_from),
+		       libcfs_nid2str(msg->msg_target.nid),
+		       msg->msg_retry_count);
+		return -ENOTRECOVERABLE;
+	}
+
+	/* if we explicitly indicated we don't want to resend then just
+	 * return
+	 */
+	if (msg->msg_no_resend) {
+		CDEBUG(D_NET, "msg %s->%s requested no resend. retry# %d\n",
+		       libcfs_nid2str(msg->msg_from),
+		       libcfs_nid2str(msg->msg_target.nid),
+		       msg->msg_retry_count);
+		return -ENOTRECOVERABLE;
+	}
+
+	/* check if the message has exceeded the number of retries */
+	if (msg->msg_retry_count >= lnet_retry_count) {
+		CNETERR("msg %s->%s exceeded retry count %d\n",
+			libcfs_nid2str(msg->msg_from),
+			libcfs_nid2str(msg->msg_target.nid),
+			msg->msg_retry_count);
+		return -ENOTRECOVERABLE;
+	}
+
+	cpt = msg->msg_tx_cpt;
+	lnet_net_lock(cpt);
+
+	/* check again under lock */
+	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING) {
+		lnet_net_unlock(cpt);
+		return -ESHUTDOWN;
+	}
+
+	container = the_lnet.ln_msg_containers[cpt];
+	my_slot = lnet_check_finalize_recursion_locked(msg,
+						       &container->msc_resending,
+						       container->msc_nfinalizers,
+						       container->msc_resenders);
+	/* enough threads are resending */
+	if (my_slot == -1) {
+		lnet_net_unlock(cpt);
+		return 0;
+	}
+
+	while (!list_empty(&container->msc_resending)) {
+		msg = list_entry(container->msc_resending.next,
+				 struct lnet_msg, msg_list);
+		list_del(&msg->msg_list);
+
+		/* resending the message will require us to call
+		 * lnet_msg_decommit_tx() which will return the credit
+		 * which this message holds. This could trigger another
+		 * queued message to be sent. If that message fails and
+		 * requires a resend we will recurse.
+		 * But since at this point the slot is taken, the message
+		 * will be queued in the container and dealt with
+		 * later. This breaks the recursion.
+		 */
+		lnet_resend_msg_locked(msg);
+	}
+
+	/* msc_resenders is an array of process pointers. Each entry holds
+	 * a pointer to the current process operating on the message. An
+	 * array entry is created per CPT. If the array slot is already
+	 * set, then it means that there is a thread on the CPT currently
+	 * resending a message.
+	 * Once the thread finishes clear the slot to enable the thread to
+	 * take on more resend work.
+	 */
+	container->msc_resenders[my_slot] = NULL;
+	lnet_net_unlock(cpt);
+
+	return 0;
+}
+
 /* Do a health check on the message:
  * return -1 if we're not going to handle the error or
  *   if we've reached the maximum number of retries.
@@ -607,9 +769,9 @@
 lnet_health_check(struct lnet_msg *msg)
 {
 	enum lnet_msg_hstatus hstatus = msg->msg_health_status;
-	bool lo = false;
-	struct lnet_ni *ni;
 	struct lnet_peer_ni *lpni;
+	struct lnet_ni *ni;
+	bool lo = false;
 
 	/* if we're shutting down no point in handling health. */
 	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING)
@@ -697,7 +859,7 @@
 		lnet_handle_local_failure(ni);
 		if (msg->msg_tx_committed)
 			/* add to the re-send queue */
-			goto resend;
+			return lnet_attempt_msg_resend(msg);
 		break;
 
 	/* These errors will not trigger a resend so simply
@@ -713,7 +875,7 @@
 	case LNET_MSG_STATUS_REMOTE_DROPPED:
 		lnet_handle_remote_failure(lpni);
 		if (msg->msg_tx_committed)
-			goto resend;
+			return lnet_attempt_msg_resend(msg);
 		break;
 
 	case LNET_MSG_STATUS_REMOTE_ERROR:
@@ -725,87 +887,8 @@
 		LBUG();
 	}
 
-resend:
-	/* we can only resend tx_committed messages */
-	LASSERT(msg->msg_tx_committed);
-
-	/* don't resend recovery messages */
-	if (msg->msg_recovery) {
-		CDEBUG(D_NET, "msg %s->%s is a recovery ping. retry# %d\n",
-		       libcfs_nid2str(msg->msg_from),
-		       libcfs_nid2str(msg->msg_target.nid),
-		       msg->msg_retry_count);
-		return -1;
-	}
-
-	/* if we explicitly indicated we don't want to resend then just
-	 * return
-	 */
-	if (msg->msg_no_resend) {
-		CDEBUG(D_NET, "msg %s->%s requested no resend. retry# %d\n",
-		       libcfs_nid2str(msg->msg_from),
-		       libcfs_nid2str(msg->msg_target.nid),
-		       msg->msg_retry_count);
-		return -1;
-	}
-
-	/* check if the message has exceeded the number of retries */
-	if (msg->msg_retry_count >= lnet_retry_count) {
-		CNETERR("msg %s->%s exceeded retry count %d\n",
-			libcfs_nid2str(msg->msg_from),
-			libcfs_nid2str(msg->msg_target.nid),
-			msg->msg_retry_count);
-		return -1;
-	}
-	msg->msg_retry_count++;
-
-	lnet_net_lock(msg->msg_tx_cpt);
-
-	/* check again under lock */
-	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING) {
-		lnet_net_unlock(msg->msg_tx_cpt);
-		return -1;
-	}
-
-	/* remove message from the active list and reset it in preparation
-	 * for a resend. Two exception to this
-	 *
-	 * 1. the router case, when a message is committed for rx when
-	 * received, then tx when it is sent. When committed to both tx and
-	 * rx we don't want to remove it from the active list.
-	 *
-	 * 2. The REPLY case since it uses the same msg block for the GET
-	 * that was received.
-	 */
-	if (!msg->msg_routing && msg->msg_type != LNET_MSG_REPLY) {
-		list_del_init(&msg->msg_activelist);
-		msg->msg_onactivelist = 0;
-	}
-
-	/* The msg_target.nid which was originally set
-	 * when calling LNetGet() or LNetPut() might've
-	 * been overwritten if we're routing this message.
-	 * Call lnet_return_tx_credits_locked() to return
-	 * the credit this message consumed. The message will
-	 * consume another credit when it gets resent.
-	 */
-	msg->msg_target.nid = msg->msg_hdr.dest_nid;
-	lnet_msg_decommit_tx(msg, -EAGAIN);
-	msg->msg_sending = 0;
-	msg->msg_receiving = 0;
-	msg->msg_target_is_router = 0;
-
-	CDEBUG(D_NET, "%s->%s:%s:%s - queuing for resend\n",
-	       libcfs_nid2str(msg->msg_hdr.src_nid),
-	       libcfs_nid2str(msg->msg_hdr.dest_nid),
-	       lnet_msgtyp2str(msg->msg_type),
-	       lnet_health_error2str(hstatus));
-
-	list_add_tail(&msg->msg_list, the_lnet.ln_mt_resendqs[msg->msg_tx_cpt]);
-	lnet_net_unlock(msg->msg_tx_cpt);
-
-	wake_up(&the_lnet.ln_mt_waitq);
-	return 0;
+	/* no resend is needed */
+	return -1;
 }
 
 static void
@@ -945,7 +1028,6 @@
 	int my_slot;
 	int cpt;
 	int rc;
-	int i;
 
 	LASSERT(!in_interrupt());
 
@@ -967,7 +1049,6 @@
 		 * put on the resend queue.
 		 */
 		if (!lnet_health_check(msg))
-			/* Message is queued for resend */
 			return;
 	}
 
@@ -998,28 +1079,20 @@
 	lnet_net_lock(cpt);
 
 	container = the_lnet.ln_msg_containers[cpt];
-	list_add_tail(&msg->msg_list, &container->msc_finalizing);
 
-	/*
-	 * Recursion breaker.  Don't complete the message here if I am (or
+	/* Recursion breaker.  Don't complete the message here if I am (or
 	 * enough other threads are) already completing messages
 	 */
-	my_slot = -1;
-	for (i = 0; i < container->msc_nfinalizers; i++) {
-		if (container->msc_finalizers[i] == current)
-			break;
-
-		if (my_slot < 0 && !container->msc_finalizers[i])
-			my_slot = i;
-	}
-
-	if (i < container->msc_nfinalizers || my_slot < 0) {
+	my_slot = lnet_check_finalize_recursion_locked(msg,
+						       &container->msc_finalizing,
+						       container->msc_nfinalizers,
+						       container->msc_finalizers);
+	/* enough threads are resending */
+	if (my_slot == -1) {
 		lnet_net_unlock(cpt);
 		return;
 	}
 
-	container->msc_finalizers[my_slot] = current;
-
 	rc = 0;
 	while ((msg = list_first_entry_or_null(&container->msc_finalizing,
 					       struct lnet_msg,
@@ -1073,6 +1146,10 @@
 
 	kvfree(container->msc_finalizers);
 	container->msc_finalizers = NULL;
+
+	kfree(container->msc_resenders);
+	container->msc_resenders = NULL;
+
 	container->msc_init = 0;
 }
 
@@ -1083,6 +1160,7 @@
 
 	INIT_LIST_HEAD(&container->msc_active);
 	INIT_LIST_HEAD(&container->msc_finalizing);
+	INIT_LIST_HEAD(&container->msc_resending);
 
 	/* number of CPUs */
 	container->msc_nfinalizers = cfs_cpt_weight(lnet_cpt_table(), cpt);
@@ -1099,6 +1177,16 @@
 		return -ENOMEM;
 	}
 
+	container->msc_resenders = kzalloc_cpt(container->msc_nfinalizers *
+					       sizeof(*container->msc_resenders),
+					       GFP_KERNEL, cpt);
+
+	if (!container->msc_resenders) {
+		CERROR("Failed to allocate message resenders\n");
+		lnet_msg_container_cleanup(container);
+		return -ENOMEM;
+	}
+
 	return 0;
 }
 
-- 
1.8.3.1
