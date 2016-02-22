From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Feb 2016 17:29:16 -0500
Subject: [lustre-devel] [PATCH 15/24] staging: lustre: improvement to router
	checker
In-Reply-To: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
References: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456180165-1105-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>

From: Amir Shehata <amir.shehata@intel.com>

This patch starts router checker thread all the time.

The router checker only checks routes by ping if
live_router_check_interval or dead_router_check_interval are set
to something other than 0, and there are routes configured.

If these conditions are not met the router checker sleeps until woken
up when a route is added.  It is also woken up whenever the RC is
being stopped to ensure the thread doesn't hang.

In the future when DLC starts configuring the live and dead
router_check_interval parameters, then by manipulating them
the router checker can be turned on and off by the user.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6003
Reviewed-on: http://review.whamcloud.com/13035
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    7 +++
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    1 +
 drivers/staging/lustre/lnet/lnet/router.c          |   51 +++++++++++++++++---
 3 files changed, 52 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index e4a8f6e..06d4656 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -635,6 +635,13 @@ typedef struct {
 	 */
 	bool				  ln_nis_from_mod_params;
 
+	/*
+	 * waitq for router checker.  As long as there are no routes in
+	 * the list, the router checker will sleep on this queue.  when
+	 * routes are added the thread will wake up
+	 */
+	wait_queue_head_t		  ln_rc_waitq;
+
 } lnet_t;
 
 #endif
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index ed121a8..0ec656a 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -98,6 +98,7 @@ lnet_init_locks(void)
 {
 	spin_lock_init(&the_lnet.ln_eq_wait_lock);
 	init_waitqueue_head(&the_lnet.ln_eq_waitq);
+	init_waitqueue_head(&the_lnet.ln_rc_waitq);
 	mutex_init(&the_lnet.ln_lnd_mutex);
 	mutex_init(&the_lnet.ln_api_mutex);
 }
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 511e446..ad9cd44 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -405,6 +405,9 @@ lnet_add_route(__u32 net, unsigned int hops, lnet_nid_t gateway,
 	if (rnet != rnet2)
 		LIBCFS_FREE(rnet, sizeof(*rnet));
 
+	/* indicate to startup the router checker if configured */
+	wake_up(&the_lnet.ln_rc_waitq);
+
 	return rc;
 }
 
@@ -1056,11 +1059,6 @@ lnet_router_checker_start(void)
 		return -EINVAL;
 	}
 
-	if (!the_lnet.ln_routing &&
-	    live_router_check_interval <= 0 &&
-	    dead_router_check_interval <= 0)
-		return 0;
-
 	sema_init(&the_lnet.ln_rc_signal, 0);
 	/*
 	 * EQ size doesn't matter; the callback is guaranteed to get every
@@ -1109,6 +1107,8 @@ lnet_router_checker_stop(void)
 
 	LASSERT(the_lnet.ln_rc_state == LNET_RC_STATE_RUNNING);
 	the_lnet.ln_rc_state = LNET_RC_STATE_STOPPING;
+	/* wakeup the RC thread if it's sleeping */
+	wake_up(&the_lnet.ln_rc_waitq);
 
 	/* block until event callback signals exit */
 	down(&the_lnet.ln_rc_signal);
@@ -1199,6 +1199,33 @@ lnet_prune_rc_data(int wait_unlink)
 	lnet_net_unlock(LNET_LOCK_EX);
 }
 
+/*
+ * This function is called to check if the RC should block indefinitely.
+ * It's called from lnet_router_checker() as well as being passed to
+ * wait_event_interruptible() to avoid the lost wake_up problem.
+ *
+ * When it's called from wait_event_interruptible() it is necessary to
+ * also not sleep if the rc state is not running to avoid a deadlock
+ * when the system is shutting down
+ */
+static inline bool
+lnet_router_checker_active(void)
+{
+	if (the_lnet.ln_rc_state != LNET_RC_STATE_RUNNING)
+		return true;
+
+	/*
+	 * Router Checker thread needs to run when routing is enabled in
+	 * order to call lnet_update_ni_status_locked()
+	 */
+	if (the_lnet.ln_routing)
+		return true;
+
+	return !list_empty(&the_lnet.ln_routers) &&
+		(live_router_check_interval > 0 ||
+		 dead_router_check_interval > 0);
+}
+
 static int
 lnet_router_checker(void *arg)
 {
@@ -1252,8 +1279,18 @@ rescan:
 		 * because kernel counts # active tasks as nr_running
 		 * + nr_uninterruptible.
 		 */
-		set_current_state(TASK_INTERRUPTIBLE);
-		schedule_timeout(cfs_time_seconds(1));
+		/*
+		 * if there are any routes then wakeup every second.  If
+		 * there are no routes then sleep indefinitely until woken
+		 * up by a user adding a route
+		 */
+		if (!lnet_router_checker_active())
+			wait_event_interruptible(the_lnet.ln_rc_waitq,
+						 lnet_router_checker_active());
+		else
+			wait_event_interruptible_timeout(the_lnet.ln_rc_waitq,
+							 false,
+							 cfs_time_seconds(1));
 	}
 
 	LASSERT(the_lnet.ln_rc_state == LNET_RC_STATE_STOPPING);
-- 
1.7.1
