From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:06 -0500
Subject: [lustre-devel] [PATCH 078/622] lnet: add monitor thread
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-79-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Refactored the router checker thread to be the monitor thread.
The monitor thread will check router aliveness, expires messages
on the active list, recover local and remote NIs and resend messages.

In this patch it only checks router aliveness.

A deadline on the message is also added to keep track of when this
message should expire.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: b01e6fce1c98 ("LU-9120 lnet: add monitor thread")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32763
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |  11 ++-
 include/linux/lnet/lib-types.h |  27 +++----
 net/lnet/lnet/api-ni.c         |  12 ++--
 net/lnet/lnet/lib-move.c       |  98 ++++++++++++++++++++++++++
 net/lnet/lnet/lib-msg.c        |   9 ++-
 net/lnet/lnet/router.c         | 156 +++++++++++++----------------------------
 6 files changed, 185 insertions(+), 128 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 5e13d32..2c3f665 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -714,8 +714,15 @@ int lnet_sock_connect(struct socket **sockp, int *fatal,
 int lnet_peers_start_down(void);
 int lnet_peer_buffer_credits(struct lnet_net *net);
 
-int lnet_router_checker_start(void);
-void lnet_router_checker_stop(void);
+int lnet_monitor_thr_start(void);
+void lnet_monitor_thr_stop(void);
+
+bool lnet_router_checker_active(void);
+void lnet_check_routers(void);
+int lnet_router_pre_mt_start(void);
+void lnet_router_post_mt_start(void);
+void lnet_prune_rc_data(int wait_unlink);
+void lnet_router_cleanup(void);
 void lnet_router_ni_update_locked(struct lnet_peer_ni *gw, u32 net);
 void lnet_swap_pinginfo(struct lnet_ping_buffer *pbuf);
 
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 0ed325a..e1a56a1 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -79,6 +79,12 @@ struct lnet_msg {
 	lnet_nid_t		msg_src_nid_param;
 	lnet_nid_t		msg_rtr_nid_param;
 
+	/*
+	 * Deadline for the message after which it will be finalized if it
+	 * has not completed.
+	 */
+	ktime_t			msg_deadline;
+
 	/* committed for sending */
 	unsigned int		msg_tx_committed:1;
 	/* CPT # this message committed for sending */
@@ -905,9 +911,9 @@ struct lnet_msg_container {
 
 /* Router Checker states */
 enum lnet_rc_state {
-	LNET_RC_STATE_SHUTDOWN,	/* not started */
-	LNET_RC_STATE_RUNNING,	/* started up OK */
-	LNET_RC_STATE_STOPPING,	/* telling thread to stop */
+	LNET_MT_STATE_SHUTDOWN,	/* not started */
+	LNET_MT_STATE_RUNNING,	/* started up OK */
+	LNET_MT_STATE_STOPPING,	/* telling thread to stop */
 };
 
 /* LNet states */
@@ -1014,8 +1020,8 @@ struct lnet {
 	/* discovery startup/shutdown state */
 	int				ln_dc_state;
 
-	/* router checker startup/shutdown state */
-	enum lnet_rc_state		ln_rc_state;
+	/* monitor thread startup/shutdown state */
+	enum lnet_rc_state		ln_mt_state;
 	/* router checker's event queue */
 	struct lnet_handle_eq		ln_rc_eqh;
 	/* rcd still pending on net */
@@ -1023,7 +1029,7 @@ struct lnet {
 	/* rcd ready for free */
 	struct list_head		ln_rcd_zombie;
 	/* serialise startup/shutdown */
-	struct completion		ln_rc_signal;
+	struct completion		ln_mt_signal;
 
 	struct mutex			ln_api_mutex;
 	struct mutex			ln_lnd_mutex;
@@ -1053,13 +1059,10 @@ struct lnet {
 	 */
 	bool				ln_nis_from_mod_params;
 
-	/*
-	 * waitq for router checker.  As long as there are no routes in
-	 * the list, the router checker will sleep on this queue.  when
-	 * routes are added the thread will wake up
+	/* waitq for the monitor thread. The monitor thread takes care of
+	 * checking routes, timedout messages and resending messages.
 	 */
-	wait_queue_head_t		ln_rc_waitq;
-
+	wait_queue_head_t		ln_mt_waitq;
 };
 
 #endif
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 9d68434..418d65e 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -309,7 +309,7 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	spin_lock_init(&the_lnet.ln_eq_wait_lock);
 	spin_lock_init(&the_lnet.ln_msg_resend_lock);
 	init_waitqueue_head(&the_lnet.ln_eq_waitq);
-	init_waitqueue_head(&the_lnet.ln_rc_waitq);
+	init_waitqueue_head(&the_lnet.ln_mt_waitq);
 	mutex_init(&the_lnet.ln_lnd_mutex);
 }
 
@@ -2281,13 +2281,13 @@ void lnet_lib_exit(void)
 
 	lnet_ping_target_update(pbuf, ping_mdh);
 
-	rc = lnet_router_checker_start();
+	rc = lnet_monitor_thr_start();
 	if (rc)
 		goto err_stop_ping;
 
 	rc = lnet_push_target_init();
 	if (rc != 0)
-		goto err_stop_router_checker;
+		goto err_stop_monitor_thr;
 
 	rc = lnet_peer_discovery_start();
 	if (rc != 0)
@@ -2302,8 +2302,8 @@ void lnet_lib_exit(void)
 
 err_destroy_push_target:
 	lnet_push_target_fini();
-err_stop_router_checker:
-	lnet_router_checker_stop();
+err_stop_monitor_thr:
+	lnet_monitor_thr_stop();
 err_stop_ping:
 	lnet_ping_target_fini();
 err_acceptor_stop:
@@ -2353,7 +2353,7 @@ void lnet_lib_exit(void)
 		lnet_router_debugfs_fini();
 		lnet_peer_discovery_stop();
 		lnet_push_target_fini();
-		lnet_router_checker_stop();
+		lnet_monitor_thr_stop();
 		lnet_ping_target_fini();
 
 		/* Teardown fns that use my own API functions BEFORE here */
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 38815fd..418e3ad 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -818,6 +818,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		}
 	}
 
+	/* unset the tx_delay flag as we're going to send it now */
+	msg->msg_tx_delayed = 0;
+
 	if (do_send) {
 		lnet_net_unlock(cpt);
 		lnet_ni_send(ni, msg);
@@ -914,6 +917,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	msg->msg_niov = rbp->rbp_npages;
 	msg->msg_kiov = &rb->rb_kiov[0];
 
+	/* unset the msg-rx_delayed flag since we're receiving the message */
+	msg->msg_rx_delayed = 0;
+
 	if (do_recv) {
 		int cpt = msg->msg_rx_cpt;
 
@@ -2383,6 +2389,98 @@ struct lnet_ni *
 	return 0;
 }
 
+static int
+lnet_monitor_thread(void *arg)
+{
+	/* The monitor thread takes care of the following:
+	 *  1. Checks the aliveness of routers
+	 *  2. Checks if there are messages on the resend queue to resend
+	 *     them.
+	 *  3. Check if there are any NIs on the local recovery queue and
+	 *     pings them
+	 *  4. Checks if there are any NIs on the remote recovery queue
+	 *     and pings them.
+	 */
+	while (the_lnet.ln_mt_state == LNET_MT_STATE_RUNNING) {
+		if (lnet_router_checker_active())
+			lnet_check_routers();
+
+		/* TODO do we need to check if we should sleep without
+		 * timeout?  Technically, an active system will always
+		 * have messages in flight so this check will always
+		 * evaluate to false. And on an idle system do we care
+		 * if we wake up every 1 second? Although, we've seen
+		 * cases where we get a complaint that an idle thread
+		 * is waking up unnecessarily.
+		 */
+		wait_event_interruptible_timeout(the_lnet.ln_mt_waitq,
+						 false, HZ);
+	}
+
+	/* clean up the router checker */
+	lnet_prune_rc_data(1);
+
+	/* Shutting down */
+	the_lnet.ln_mt_state = LNET_MT_STATE_SHUTDOWN;
+
+	/* signal that the monitor thread is exiting */
+	complete(&the_lnet.ln_mt_signal);
+
+	return 0;
+}
+
+int lnet_monitor_thr_start(void)
+{
+	int rc;
+	struct task_struct *task;
+
+	LASSERT(the_lnet.ln_mt_state == LNET_MT_STATE_SHUTDOWN);
+
+	init_completion(&the_lnet.ln_mt_signal);
+
+	/* Pre monitor thread start processing */
+	rc = lnet_router_pre_mt_start();
+	if (!rc)
+		return rc;
+
+	the_lnet.ln_mt_state = LNET_MT_STATE_RUNNING;
+	task = kthread_run(lnet_monitor_thread, NULL, "monitor_thread");
+	if (IS_ERR(task)) {
+		rc = PTR_ERR(task);
+		CERROR("Can't start monitor thread: %d\n", rc);
+		/* block until event callback signals exit */
+		wait_for_completion(&the_lnet.ln_mt_signal);
+
+		/* clean up */
+		lnet_router_cleanup();
+		the_lnet.ln_mt_state = LNET_MT_STATE_SHUTDOWN;
+		return -ENOMEM;
+	}
+
+	/* post monitor thread start processing */
+	lnet_router_post_mt_start();
+
+	return 0;
+}
+
+void lnet_monitor_thr_stop(void)
+{
+	if (the_lnet.ln_mt_state == LNET_MT_STATE_SHUTDOWN)
+		return;
+
+	LASSERT(the_lnet.ln_mt_state == LNET_MT_STATE_RUNNING);
+	the_lnet.ln_mt_state = LNET_MT_STATE_STOPPING;
+
+	/* tell the monitor thread that we're shutting down */
+	wake_up(&the_lnet.ln_mt_waitq);
+
+	/* block until monitor thread signals that it's done */
+	wait_for_completion(&the_lnet.ln_mt_signal);
+	LASSERT(the_lnet.ln_mt_state == LNET_MT_STATE_SHUTDOWN);
+
+	lnet_router_cleanup();
+}
+
 void
 lnet_drop_message(struct lnet_ni *ni, int cpt, void *private, unsigned int nob,
 		  u32 msg_type)
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index a7062f6..7869b96 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -141,13 +141,17 @@
 {
 	struct lnet_msg_container *container = the_lnet.ln_msg_containers[cpt];
 	struct lnet_counters *counters = the_lnet.ln_counters[cpt];
+	s64 timeout_ns;
+
+	/* set the message deadline */
+	timeout_ns = lnet_transaction_timeout * NSEC_PER_SEC;
+	msg->msg_deadline = ktime_add_ns(ktime_get(), timeout_ns);
 
 	/* routed message can be committed for both receiving and sending */
 	LASSERT(!msg->msg_tx_committed);
 
 	if (msg->msg_sending) {
 		LASSERT(!msg->msg_receiving);
-
 		msg->msg_tx_cpt = cpt;
 		msg->msg_tx_committed = 1;
 		if (msg->msg_rx_committed) { /* routed message REPLY */
@@ -161,8 +165,9 @@
 	}
 
 	LASSERT(!msg->msg_onactivelist);
+
 	msg->msg_onactivelist = 1;
-	list_add(&msg->msg_activelist, &container->msc_active);
+	list_add_tail(&msg->msg_activelist, &container->msc_active);
 
 	counters->msgs_alloc++;
 	if (counters->msgs_alloc > counters->msgs_max)
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 278807d..3f9d8c5 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -70,9 +70,6 @@
 	return net->net_tunables.lct_peer_tx_credits;
 }
 
-/* forward ref's */
-static int lnet_router_checker(void *);
-
 static int check_routers_before_use;
 module_param(check_routers_before_use, int, 0444);
 MODULE_PARM_DESC(check_routers_before_use, "Assume routers are down and ping them before use");
@@ -423,8 +420,8 @@ static void lnet_shuffle_seed(void)
 	if (rnet != rnet2)
 		kfree(rnet);
 
-	/* indicate to startup the router checker if configured */
-	wake_up(&the_lnet.ln_rc_waitq);
+	/* kick start the monitor thread to handle the added route */
+	wake_up(&the_lnet.ln_mt_waitq);
 
 	return rc;
 }
@@ -809,7 +806,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	struct lnet_peer_ni *rtr;
 	int all_known;
 
-	LASSERT(the_lnet.ln_rc_state == LNET_RC_STATE_RUNNING);
+	LASSERT(the_lnet.ln_mt_state == LNET_MT_STATE_RUNNING);
 
 	for (;;) {
 		int cpt = lnet_net_lock_current();
@@ -1038,7 +1035,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	lnet_ni_notify_locked(ni, rtr);
 
 	if (!lnet_isrouter(rtr) ||
-	    the_lnet.ln_rc_state != LNET_RC_STATE_RUNNING) {
+	    the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING) {
 		/* router table changed or router checker is shutting down */
 		lnet_peer_ni_decref_locked(rtr);
 		return;
@@ -1092,14 +1089,9 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	lnet_peer_ni_decref_locked(rtr);
 }
 
-int
-lnet_router_checker_start(void)
+int lnet_router_pre_mt_start(void)
 {
-	struct task_struct *task;
 	int rc;
-	int eqsz = 0;
-
-	LASSERT(the_lnet.ln_rc_state == LNET_RC_STATE_SHUTDOWN);
 
 	if (check_routers_before_use &&
 	    dead_router_check_interval <= 0) {
@@ -1107,27 +1099,17 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 		return -EINVAL;
 	}
 
-	init_completion(&the_lnet.ln_rc_signal);
-
 	rc = LNetEQAlloc(0, lnet_router_checker_event, &the_lnet.ln_rc_eqh);
 	if (rc) {
-		CERROR("Can't allocate EQ(%d): %d\n", eqsz, rc);
+		CERROR("Can't allocate EQ(0): %d\n", rc);
 		return -ENOMEM;
 	}
 
-	the_lnet.ln_rc_state = LNET_RC_STATE_RUNNING;
-	task = kthread_run(lnet_router_checker, NULL, "router_checker");
-	if (IS_ERR(task)) {
-		rc = PTR_ERR(task);
-		CERROR("Can't start router checker thread: %d\n", rc);
-		/* block until event callback signals exit */
-		wait_for_completion(&the_lnet.ln_rc_signal);
-		rc = LNetEQFree(the_lnet.ln_rc_eqh);
-		LASSERT(!rc);
-		the_lnet.ln_rc_state = LNET_RC_STATE_SHUTDOWN;
-		return -ENOMEM;
-	}
+	return 0;
+}
 
+void lnet_router_post_mt_start(void)
+{
 	if (check_routers_before_use) {
 		/*
 		 * Note that a helpful side-effect of pinging all known routers
@@ -1136,33 +1118,17 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 		 */
 		lnet_wait_known_routerstate();
 	}
-
-	return 0;
 }
 
-void
-lnet_router_checker_stop(void)
+void lnet_router_cleanup(void)
 {
 	int rc;
 
-	if (the_lnet.ln_rc_state == LNET_RC_STATE_SHUTDOWN)
-		return;
-
-	LASSERT(the_lnet.ln_rc_state == LNET_RC_STATE_RUNNING);
-	the_lnet.ln_rc_state = LNET_RC_STATE_STOPPING;
-	/* wakeup the RC thread if it's sleeping */
-	wake_up(&the_lnet.ln_rc_waitq);
-
-	/* block until event callback signals exit */
-	wait_for_completion(&the_lnet.ln_rc_signal);
-	LASSERT(the_lnet.ln_rc_state == LNET_RC_STATE_SHUTDOWN);
-
 	rc = LNetEQFree(the_lnet.ln_rc_eqh);
-	LASSERT(!rc);
+	LASSERT(rc == 0);
 }
 
-static void
-lnet_prune_rc_data(int wait_unlink)
+void lnet_prune_rc_data(int wait_unlink)
 {
 	struct lnet_rc_data *rcd;
 	struct lnet_rc_data *tmp;
@@ -1170,7 +1136,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	struct list_head head;
 	int i = 2;
 
-	if (likely(the_lnet.ln_rc_state == LNET_RC_STATE_RUNNING &&
+	if (likely(the_lnet.ln_mt_state == LNET_MT_STATE_RUNNING &&
 		   list_empty(&the_lnet.ln_rcd_deathrow) &&
 		   list_empty(&the_lnet.ln_rcd_zombie)))
 		return;
@@ -1179,7 +1145,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 
 	lnet_net_lock(LNET_LOCK_EX);
 
-	if (the_lnet.ln_rc_state != LNET_RC_STATE_RUNNING) {
+	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING) {
 		/* router checker is stopping, prune all */
 		list_for_each_entry(lp, &the_lnet.ln_routers,
 				    lpni_rtr_list) {
@@ -1242,18 +1208,12 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 /*
- * This function is called to check if the RC should block indefinitely.
- * It's called from lnet_router_checker() as well as being passed to
- * wait_event_interruptible() to avoid the lost wake_up problem.
- *
- * When it's called from wait_event_interruptible() it is necessary to
- * also not sleep if the rc state is not running to avoid a deadlock
- * when the system is shutting down
+ * This function is called from the monitor thread to check if there are
+ * any active routers that need to be checked.
  */
-static inline bool
-lnet_router_checker_active(void)
+bool lnet_router_checker_active(void)
 {
-	if (the_lnet.ln_rc_state != LNET_RC_STATE_RUNNING)
+	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING)
 		return true;
 
 	/*
@@ -1263,70 +1223,54 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	if (the_lnet.ln_routing)
 		return true;
 
+	/* if there are routers that need to be cleaned up then do so */
+	if (!list_empty(&the_lnet.ln_rcd_deathrow) ||
+	    !list_empty(&the_lnet.ln_rcd_zombie))
+		return true;
+
 	return !list_empty(&the_lnet.ln_routers) &&
 		(live_router_check_interval > 0 ||
 		 dead_router_check_interval > 0);
 }
 
-static int
-lnet_router_checker(void *arg)
+void
+lnet_check_routers(void)
 {
 	struct lnet_peer_ni *rtr;
+	u64 version;
+	int cpt;
+	int cpt2;
 
-	while (the_lnet.ln_rc_state == LNET_RC_STATE_RUNNING) {
-		u64 version;
-		int cpt;
-		int cpt2;
-
-		cpt = lnet_net_lock_current();
+	cpt = lnet_net_lock_current();
 rescan:
-		version = the_lnet.ln_routers_version;
+	version = the_lnet.ln_routers_version;
 
-		list_for_each_entry(rtr, &the_lnet.ln_routers, lpni_rtr_list) {
-			cpt2 = rtr->lpni_cpt;
-			if (cpt != cpt2) {
-				lnet_net_unlock(cpt);
-				cpt = cpt2;
-				lnet_net_lock(cpt);
-				/* the routers list has changed */
-				if (version != the_lnet.ln_routers_version)
-					goto rescan;
-			}
-
-			lnet_ping_router_locked(rtr);
-
-			/* NB dropped lock */
-			if (version != the_lnet.ln_routers_version) {
-				/* the routers list has changed */
+	list_for_each_entry(rtr, &the_lnet.ln_routers, lpni_rtr_list) {
+		cpt2 = rtr->lpni_cpt;
+		if (cpt != cpt2) {
+			lnet_net_unlock(cpt);
+			cpt = cpt2;
+			lnet_net_lock(cpt);
+			/* the routers list has changed */
+			if (version != the_lnet.ln_routers_version)
 				goto rescan;
-			}
 		}
 
-		if (the_lnet.ln_routing)
-			lnet_update_ni_status_locked();
-
-		lnet_net_unlock(cpt);
-
-		lnet_prune_rc_data(0); /* don't wait for UNLINK */
+		lnet_ping_router_locked(rtr);
 
-		/*
-		 * if there are any routes then wakeup every second.  If
-		 * there are no routes then sleep indefinitely until woken
-		 * up by a user adding a route
-		 */
-		if (!lnet_router_checker_active())
-			wait_event_idle(the_lnet.ln_rc_waitq,
-					lnet_router_checker_active());
-		else
-			schedule_timeout_idle(HZ);
+		/* NB dropped lock */
+		if (version != the_lnet.ln_routers_version) {
+			/* the routers list has changed */
+			goto rescan;
+		}
 	}
 
-	lnet_prune_rc_data(1); /* wait for UNLINK */
+	if (the_lnet.ln_routing)
+		lnet_update_ni_status_locked();
 
-	the_lnet.ln_rc_state = LNET_RC_STATE_SHUTDOWN;
-	complete(&the_lnet.ln_rc_signal);
-	/* The unlink event callback will signal final completion */
-	return 0;
+	lnet_net_unlock(cpt);
+
+	lnet_prune_rc_data(0); /* don't wait for UNLINK */
 }
 
 void
-- 
1.8.3.1
