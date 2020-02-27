From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:41 -0500
Subject: [lustre-devel] [PATCH 353/622] lnet: net aliveness
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-354-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

If a router is discovered on any interface on the network, then
update the network last alive time and the NI's status to UP.
If a router isn't discovered on any interface on a network,
then change the status of all the interfaces on that network to down.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11299
Lustre-commit: 1d80e9debf99 ("LU-11299 lnet: net aliveness")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34510
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  9 +++++---
 net/lnet/lnet/config.c         |  3 ++-
 net/lnet/lnet/lib-move.c       |  7 +++---
 net/lnet/lnet/router.c         | 52 ++++++++++++++++++++++++++----------------
 net/lnet/lnet/router_proc.c    |  2 +-
 5 files changed, 45 insertions(+), 28 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 56654f5..7b43236 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -397,6 +397,12 @@ struct lnet_net {
 
 	/* dying LND instances */
 	struct list_head	net_ni_zombie;
+
+	/* when I was last alive */
+	time64_t		net_last_alive;
+
+	/* protects access to net_last_alive */
+	spinlock_t		net_lock;
 };
 
 struct lnet_ni {
@@ -431,9 +437,6 @@ struct lnet_ni {
 	/* percpt reference count */
 	int			**ni_refs;
 
-	/* when I was last alive */
-	time64_t		ni_last_alive;
-
 	/* pointer to parent network */
 	struct lnet_net		*ni_net;
 
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 949cdd3..a2a9c79 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -366,8 +366,10 @@ struct lnet_net *
 	INIT_LIST_HEAD(&net->net_ni_list);
 	INIT_LIST_HEAD(&net->net_ni_added);
 	INIT_LIST_HEAD(&net->net_ni_zombie);
+	spin_lock_init(&net->net_lock);
 
 	net->net_id = net_id;
+	net->net_last_alive = ktime_get_real_seconds();
 
 	/* initialize global paramters to undefiend */
 	net->net_tunables.lct_peer_timeout = -1;
@@ -467,7 +469,6 @@ struct lnet_net *
 	else
 		ni->ni_net_ns = NULL;
 
-	ni->ni_last_alive = ktime_get_real_seconds();
 	ni->ni_state = LNET_NI_STATE_INIT;
 	list_add_tail(&ni->ni_netlist, &net->net_ni_added);
 
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index d6cbcd1..ec32d22 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3903,10 +3903,11 @@ void lnet_monitor_thr_stop(void)
 	}
 
 	if (the_lnet.ln_routing &&
-	    ni->ni_last_alive != ktime_get_real_seconds()) {
-		/* NB: so far here is the only place to set NI status to "up */
+	    ni->ni_net->net_last_alive != ktime_get_real_seconds()) {
 		lnet_ni_lock(ni);
-		ni->ni_last_alive = ktime_get_real_seconds();
+		spin_lock(&ni->ni_net->net_lock);
+		ni->ni_net->net_last_alive = ktime_get_real_seconds();
+		spin_unlock(&ni->ni_net->net_lock);
 		if (ni->ni_status &&
 		    ni->ni_status->ns_status == LNET_NI_STATUS_DOWN) {
 			ni->ni_status->ns_status = LNET_NI_STATUS_UP;
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 0a396d9..4ca3c5c 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -742,10 +742,29 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 	}
 }
 
+static inline bool
+lnet_net_set_status_locked(struct lnet_net *net, u32 status)
+{
+	struct lnet_ni *ni;
+	bool update = false;
+
+	list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
+		lnet_ni_lock(ni);
+		if (ni->ni_status &&
+		    ni->ni_status->ns_status != status) {
+			ni->ni_status->ns_status = status;
+			update = true;
+		}
+		lnet_ni_unlock(ni);
+	}
+
+	return update;
+}
+
 static bool
 lnet_update_ni_status_locked(void)
 {
-	struct lnet_ni *ni = NULL;
+	struct lnet_net *net;
 	bool push = false;
 	time64_t now;
 	time64_t timeout;
@@ -755,33 +774,26 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 	timeout = router_ping_timeout + alive_router_check_interval;
 
 	now = ktime_get_real_seconds();
-	while ((ni = lnet_get_next_ni_locked(NULL, ni))) {
-		if (ni->ni_net->net_lnd->lnd_type == LOLND)
+	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
+		if (net->net_lnd->lnd_type == LOLND)
 			continue;
 
-		if (now < ni->ni_last_alive + timeout)
+		if (now < net->net_last_alive + timeout)
 			continue;
 
-		lnet_ni_lock(ni);
+		spin_lock(&net->net_lock);
 		/* re-check with lock */
-		if (now < ni->ni_last_alive + timeout) {
-			lnet_ni_unlock(ni);
+		if (now < net->net_last_alive + timeout) {
+			spin_unlock(&net->net_lock);
 			continue;
 		}
+		spin_unlock(&net->net_lock);
 
-		LASSERT(ni->ni_status);
-
-		if (ni->ni_status->ns_status != LNET_NI_STATUS_DOWN) {
-			CDEBUG(D_NET, "NI(%s:%lld) status changed to down\n",
-			       libcfs_nid2str(ni->ni_nid), timeout);
-			/*
-			 * NB: so far, this is the only place to set
-			 * NI status to "down"
-			 */
-			ni->ni_status->ns_status = LNET_NI_STATUS_DOWN;
-			push = true;
-		}
-		lnet_ni_unlock(ni);
+		/* if the net didn't receive any traffic for past the
+		 * timeout on any of its constituent NIs, then mark all
+		 * the NIs down.
+		 */
+		push = lnet_net_set_status_locked(net, LNET_NI_STATUS_DOWN);
 	}
 
 	return push;
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 9771ef0..2e9342c 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -674,7 +674,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 			int j;
 
 			if (the_lnet.ln_routing)
-				last_alive = now - ni->ni_last_alive;
+				last_alive = now - ni->ni_net->net_last_alive;
 
 			lnet_ni_lock(ni);
 			LASSERT(ni->ni_status);
-- 
1.8.3.1
