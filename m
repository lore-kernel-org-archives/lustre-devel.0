From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:49 -0500
Subject: [lustre-devel] [PATCH 481/622] lnet: change ln_mt_waitq to a
 completion.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-482-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

ln_mt_waitq is only waited on by a call to
  wait_event_interruptible_timeout(..., false, timeout);

As 'false' is never 'true', this will always wait for the full
timeout to expire.  So the waitq is effectively pointless.

To acheive the apparent intent of the waitq, change it to a
completion.  The completion adds a 'done' flag to a waitq so we can
wait until a timeout or until a wakeup is requested.

With this, a longer timeout would could be used, but that is left to
a later patch.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12686
Lustre-commit: b81bcc6c6f0c ("LU-12686 lnet: change ln_mt_waitq to a completion.")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35874
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  5 +++--
 net/lnet/lnet/api-ni.c         |  2 +-
 net/lnet/lnet/lib-move.c       | 10 +++++++---
 net/lnet/lnet/lib-msg.c        |  2 +-
 net/lnet/lnet/router.c         |  4 ++--
 5 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 22c2bc6..18d4e4e 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -1145,10 +1145,11 @@ struct lnet {
 	 */
 	bool				ln_nis_from_mod_params;
 
-	/* waitq for the monitor thread. The monitor thread takes care of
+	/*
+	 * completion for the monitor thread. The monitor thread takes care of
 	 * checking routes, timedout messages and resending messages.
 	 */
-	wait_queue_head_t		ln_mt_waitq;
+	struct completion		ln_mt_wait_complete;
 
 	/* per-cpt resend queues */
 	struct list_head		**ln_mt_resendqs;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 79deaac..e66d9dc7 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -486,7 +486,7 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	spin_lock_init(&the_lnet.ln_eq_wait_lock);
 	spin_lock_init(&the_lnet.ln_msg_resend_lock);
 	init_waitqueue_head(&the_lnet.ln_eq_waitq);
-	init_waitqueue_head(&the_lnet.ln_mt_waitq);
+	init_completion(&the_lnet.ln_mt_wait_complete);
 	mutex_init(&the_lnet.ln_lnd_mutex);
 }
 
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 322998a..2f31f06 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3276,8 +3276,12 @@ struct lnet_mt_event_info {
 			       min((unsigned int)alive_router_check_interval /
 					lnet_current_net_count,
 				   lnet_transaction_timeout / 2));
-		wait_event_interruptible_timeout(the_lnet.ln_mt_waitq,
-						 false, HZ * interval);
+		wait_for_completion_interruptible_timeout(&the_lnet.ln_mt_wait_complete,
+							  interval * HZ);
+		/* Must re-init the completion before testing anything,
+		 * including ln_mt_state.
+		 */
+		reinit_completion(&the_lnet.ln_mt_wait_complete);
 	}
 
 	/* Shutting down */
@@ -3539,7 +3543,7 @@ void lnet_monitor_thr_stop(void)
 	lnet_net_unlock(LNET_LOCK_EX);
 
 	/* tell the monitor thread that we're shutting down */
-	wake_up(&the_lnet.ln_mt_waitq);
+	complete(&the_lnet.ln_mt_wait_complete);
 
 	/* block until monitor thread signals that it's done */
 	wait_for_completion(&the_lnet.ln_mt_signal);
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 5c39ce3..d74ff53 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -640,7 +640,7 @@
 
 	list_add_tail(&msg->msg_list, the_lnet.ln_mt_resendqs[msg->msg_tx_cpt]);
 
-	wake_up(&the_lnet.ln_mt_waitq);
+	complete(&the_lnet.ln_mt_wait_complete);
 }
 
 int
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index bc9494d..7246eea 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -674,7 +674,7 @@ static void lnet_shuffle_seed(void)
 		kfree(rnet);
 
 	/* kick start the monitor thread to handle the added route */
-	wake_up(&the_lnet.ln_mt_waitq);
+	complete(&the_lnet.ln_mt_wait_complete);
 
 	return rc;
 }
@@ -1419,7 +1419,7 @@ bool lnet_router_checker_active(void)
 	lnet_net_lock(LNET_LOCK_EX);
 	the_lnet.ln_routing = 1;
 	lnet_net_unlock(LNET_LOCK_EX);
-	wake_up(&the_lnet.ln_mt_waitq);
+	complete(&the_lnet.ln_mt_wait_complete);
 	return 0;
 
 failed:
-- 
1.8.3.1
