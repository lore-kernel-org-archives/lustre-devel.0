From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:11 -0500
Subject: [lustre-devel] [PATCH 323/622] lnet: fix list corruption
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-324-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

In shutdown the resend queues are cleared and freed. The monitor
thread state is set to shutdown. It is possible to get lnet_finalize()
called after the queues are freed. The code checks for ln_state to see
if we're shutting down. But in this case we should really be checking
ln_mt_state. The monitor thread is the one that matters in this case,
because it's the one which allocates and frees the resend queues.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12249
Lustre-commit: d799ac910cd6 ("LU-12249 lnet: fix list corruption")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34778
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 10 ++++++++++
 net/lnet/lnet/lib-msg.c  |  8 +++++++-
 2 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 0ee3a55..8bce3a9 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3135,7 +3135,9 @@ struct lnet_mt_event_info {
 	lnet_prune_rc_data(1);
 
 	/* Shutting down */
+	lnet_net_lock(LNET_LOCK_EX);
 	the_lnet.ln_mt_state = LNET_MT_STATE_SHUTDOWN;
+	lnet_net_unlock(LNET_LOCK_EX);
 
 	/* signal that the monitor thread is exiting */
 	complete(&the_lnet.ln_mt_signal);
@@ -3349,7 +3351,9 @@ int lnet_monitor_thr_start(void)
 
 	init_completion(&the_lnet.ln_mt_signal);
 
+	lnet_net_lock(LNET_LOCK_EX);
 	the_lnet.ln_mt_state = LNET_MT_STATE_RUNNING;
+	lnet_net_unlock(LNET_LOCK_EX);
 	task = kthread_run(lnet_monitor_thread, NULL, "monitor_thread");
 	if (IS_ERR(task)) {
 		rc = PTR_ERR(task);
@@ -3363,13 +3367,17 @@ int lnet_monitor_thr_start(void)
 	return 0;
 
 clean_thread:
+	lnet_net_lock(LNET_LOCK_EX);
 	the_lnet.ln_mt_state = LNET_MT_STATE_STOPPING;
+	lnet_net_unlock(LNET_LOCK_EX);
 	/* block until event callback signals exit */
 	wait_for_completion(&the_lnet.ln_mt_signal);
 	/* clean up */
 	lnet_router_cleanup();
 free_mem:
+	lnet_net_lock(LNET_LOCK_EX);
 	the_lnet.ln_mt_state = LNET_MT_STATE_SHUTDOWN;
+	lnet_net_unlock(LNET_LOCK_EX);
 	lnet_rsp_tracker_clean();
 	lnet_clean_local_ni_recoveryq();
 	lnet_clean_peer_ni_recoveryq();
@@ -3390,7 +3398,9 @@ void lnet_monitor_thr_stop(void)
 		return;
 
 	LASSERT(the_lnet.ln_mt_state == LNET_MT_STATE_RUNNING);
+	lnet_net_lock(LNET_LOCK_EX);
 	the_lnet.ln_mt_state = LNET_MT_STATE_STOPPING;
+	lnet_net_unlock(LNET_LOCK_EX);
 
 	/* tell the monitor thread that we're shutting down */
 	wake_up(&the_lnet.ln_mt_waitq);
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index a245942..ad35c3d 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -604,7 +604,7 @@
 	bool lo = false;
 
 	/* if we're shutting down no point in handling health. */
-	if (the_lnet.ln_state != LNET_STATE_RUNNING)
+	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING)
 		return -1;
 
 	LASSERT(msg->msg_txni);
@@ -712,6 +712,12 @@
 
 	lnet_net_lock(msg->msg_tx_cpt);
 
+	/* check again under lock */
+	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING) {
+		lnet_net_unlock(msg->msg_tx_cpt);
+		return -1;
+	}
+
 	/* remove message from the active list and reset it in preparation
 	 * for a resend. Two exception to this
 	 *
-- 
1.8.3.1
