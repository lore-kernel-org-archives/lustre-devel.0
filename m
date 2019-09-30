From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:52 -0400
Subject: [lustre-devel] [PATCH 033/151] lnet: resolve unsafe list access
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Use list_for_each_entry_safe() when accessing messages on pending
queue. Remove the message from the list before calling lnet_finalize()
or lnet_send().

When destroying the peer make sure to queue all pending messages on
a global list. We can not resend them at this point because the
cpt lock is held. Unlocking the cpt lock could lead to an inconsistent
state. Use the discovery thread to check if the global list is not
empty and if so resend all messages on the list. Use a new spin
lock to protect the resend message list. I steered clear from reusing
an existing lock because LNet locking is complex and reusing a lock
will add to this complexity. Using a new lock makes the code easier
to understand.

Verify that all lists are empty before destroying the peer_ni

WC-bug-id: https://jira.whamcloud.com/browse/LU-9921
Lustre-commit: 62c3c8d14856 ("LU-9921 lnet: resolve unsafe list access")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28723
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  4 +++
 net/lnet/lnet/api-ni.c         | 15 ++++++++++
 net/lnet/lnet/peer.c           | 68 ++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 85 insertions(+), 2 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 6d2d83a..a5cbf07 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -945,6 +945,10 @@ struct lnet {
 	struct list_head		ln_net_zombie;
 	/* the loopback NI */
 	struct lnet_ni		       *ln_loni;
+	/* resend messages list */
+	struct list_head		ln_msg_resend;
+	/* spin lock to protect the msg resend list */
+	spinlock_t			ln_msg_resend_lock;
 
 	/* remote networks with routes to them */
 	struct list_head	       *ln_remote_nets_hash;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index bc3f808..b038010 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -211,6 +211,7 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 lnet_init_locks(void)
 {
 	spin_lock_init(&the_lnet.ln_eq_wait_lock);
+	spin_lock_init(&the_lnet.ln_msg_resend_lock);
 	init_waitqueue_head(&the_lnet.ln_eq_waitq);
 	init_waitqueue_head(&the_lnet.ln_rc_waitq);
 	mutex_init(&the_lnet.ln_lnd_mutex);
@@ -1652,6 +1653,10 @@ static void lnet_push_target_fini(void)
 lnet_shutdown_lndnets(void)
 {
 	struct lnet_net *net;
+	struct list_head resend;
+	struct lnet_msg *msg, *tmp;
+
+	INIT_LIST_HEAD(&resend);
 
 	/* NB called holding the global mutex */
 
@@ -1682,6 +1687,15 @@ static void lnet_push_target_fini(void)
 					       net_list)) != NULL)
 		lnet_shutdown_lndnet(net);
 
+	spin_lock(&the_lnet.ln_msg_resend_lock);
+	list_splice(&the_lnet.ln_msg_resend, &resend);
+	spin_unlock(&the_lnet.ln_msg_resend_lock);
+
+	list_for_each_entry_safe(msg, tmp, &resend, msg_list) {
+		list_del_init(&msg->msg_list);
+		lnet_finalize(msg, -ECANCELED);
+	}
+
 	lnet_net_lock(LNET_LOCK_EX);
 	the_lnet.ln_state = LNET_STATE_SHUTDOWN;
 	lnet_net_unlock(LNET_LOCK_EX);
@@ -2025,6 +2039,7 @@ int lnet_lib_init(void)
 	INIT_LIST_HEAD(&the_lnet.ln_lnds);
 	INIT_LIST_HEAD(&the_lnet.ln_net_zombie);
 	INIT_LIST_HEAD(&the_lnet.ln_rcd_zombie);
+	INIT_LIST_HEAD(&the_lnet.ln_msg_resend);
 	INIT_LIST_HEAD(&the_lnet.ln_rcd_deathrow);
 
 	/*
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 34e61f8..d7a2e3b 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -231,6 +231,22 @@
 	if (lp->lp_data)
 		lnet_ping_buffer_decref(lp->lp_data);
 
+	/* if there are messages still on the pending queue, then make
+	 * sure to queue them on the ln_msg_resend list so they can be
+	 * resent at a later point if the discovery thread is still
+	 * running.
+	 * If the discovery thread has stopped, then the wakeup will be a
+	 * no-op, and it is expected the lnet_shutdown_lndnets() will
+	 * eventually be called, which will traverse this list and
+	 * finalize the messages on the list.
+	 * We can not resend them now because we're holding the cpt lock.
+	 * Releasing the lock can cause an inconsistent state
+	 */
+	spin_lock(&the_lnet.ln_msg_resend_lock);
+	list_splice(&lp->lp_dc_pendq, &the_lnet.ln_msg_resend);
+	spin_unlock(&the_lnet.ln_msg_resend_lock);
+	wake_up(&the_lnet.ln_dc_waitq);
+
 	kfree(lp);
 }
 
@@ -1532,6 +1548,8 @@ struct lnet_peer_net *
 	LASSERT(lpni->lpni_rtr_refcount == 0);
 	LASSERT(list_empty(&lpni->lpni_txq));
 	LASSERT(lpni->lpni_txqnob == 0);
+	LASSERT(list_empty(&lpni->lpni_peer_nis));
+	LASSERT(list_empty(&lpni->lpni_on_remote_peer_ni_list));
 
 	lpn = lpni->lpni_peer_net;
 	lpni->lpni_peer_net = NULL;
@@ -1730,7 +1748,7 @@ static int lnet_peer_queue_for_discovery(struct lnet_peer *lp)
  */
 static void lnet_peer_discovery_complete(struct lnet_peer *lp)
 {
-	struct lnet_msg *msg = NULL;
+	struct lnet_msg *msg, *tmp;
 	int rc = 0;
 	struct list_head pending_msgs;
 
@@ -1746,7 +1764,8 @@ static void lnet_peer_discovery_complete(struct lnet_peer *lp)
 	lnet_net_unlock(LNET_LOCK_EX);
 
 	/* iterate through all pending messages and send them again */
-	list_for_each_entry(msg, &pending_msgs, msg_list) {
+	list_for_each_entry_safe(msg, tmp, &pending_msgs, msg_list) {
+		list_del_init(&msg->msg_list);
 		if (lp->lp_dc_error) {
 			lnet_finalize(msg, lp->lp_dc_error);
 			continue;
@@ -2970,6 +2989,8 @@ static int lnet_peer_discovery_wait_for_work(void)
 			break;
 		if (!list_empty(&the_lnet.ln_dc_request))
 			break;
+		if (!list_empty(&the_lnet.ln_msg_resend))
+			break;
 		if (lnet_peer_dc_timed_out(ktime_get_real_seconds()))
 			break;
 		lnet_net_unlock(cpt);
@@ -2995,6 +3016,47 @@ static int lnet_peer_discovery_wait_for_work(void)
 	return rc;
 }
 
+/* Messages that were pending on a destroyed peer will be put on a global
+ * resend list. The message resend list will be checked by
+ * the discovery thread when it wakes up, and will resend messages. These
+ * messages can still be sendable in the case the lpni which was the initial
+ * cause of the message re-queue was transferred to another peer.
+ *
+ * It is possible that LNet could be shutdown while we're iterating
+ * through the list. lnet_shudown_lndnets() will attempt to access the
+ * resend list, but will have to wait until the spinlock is released, by
+ * which time there shouldn't be any more messages on the resend list.
+ * During shutdown lnet_send() will fail and lnet_finalize() will be called
+ * for the messages so they can be released. The other case is that
+ * lnet_shudown_lndnets() can finalize all the messages before this
+ * function can visit the resend list, in which case this function will be
+ * a no-op.
+ */
+static void lnet_resend_msgs(void)
+{
+	struct lnet_msg *msg, *tmp;
+	struct list_head resend;
+	int rc;
+
+	INIT_LIST_HEAD(&resend);
+
+	spin_lock(&the_lnet.ln_msg_resend_lock);
+	list_splice(&the_lnet.ln_msg_resend, &resend);
+	spin_unlock(&the_lnet.ln_msg_resend_lock);
+
+	list_for_each_entry_safe(msg, tmp, &resend, msg_list) {
+		list_del_init(&msg->msg_list);
+		rc = lnet_send(msg->msg_src_nid_param, msg,
+			       msg->msg_rtr_nid_param);
+		if (rc < 0) {
+			CNETERR("Error sending %s to %s: %d\n",
+				lnet_msgtyp2str(msg->msg_type),
+				libcfs_id2str(msg->msg_target), rc);
+			lnet_finalize(msg, rc);
+		}
+	}
+}
+
 /* The discovery thread. */
 static int lnet_peer_discovery(void *arg)
 {
@@ -3008,6 +3070,8 @@ static int lnet_peer_discovery(void *arg)
 		if (lnet_peer_discovery_wait_for_work())
 			break;
 
+		lnet_resend_msgs();
+
 		if (lnet_push_target_resize_needed())
 			lnet_push_target_resize();
 
-- 
1.8.3.1
