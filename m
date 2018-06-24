From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:53:50 -0400
Subject: [lustre-devel] [PATCH 6/8] staging: lustre: lnet: move ping and
 delay injection to time64_t
In-Reply-To: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
References: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529877232-15582-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Migrate away from jiffies for the pinger to time_64_t to one make
it clear its for time keeping and secondly to ensure the behavior
is consistent across any nodes. Besides the lnet pinger code
move the lnet delay injection code to time64_t as well.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9019
Reviewed-on: https://review.whamcloud.com/30658
WC-bug-id: https://jira.whamcloud.com/browse/LU-10672
Reviewed-on: https://review.whamcloud.com/31339
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  8 +--
 .../staging/lustre/include/linux/lnet/lib-types.h  | 13 ++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 11 ++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  4 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 10 +--
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  4 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          | 14 +++--
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 24 ++++----
 drivers/staging/lustre/lnet/lnet/net_fault.c       | 72 ++++++++++------------
 drivers/staging/lustre/lnet/lnet/peer.c            |  2 +-
 drivers/staging/lustre/lnet/lnet/router.c          | 35 +++++------
 drivers/staging/lustre/lnet/lnet/router_proc.c     | 27 ++++----
 13 files changed, 110 insertions(+), 116 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 973c17a..6b6289c 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -404,9 +404,9 @@ struct lnet_ni *
 void lnet_lib_exit(void);
 
 int lnet_notify(struct lnet_ni *ni, lnet_nid_t peer, int alive,
-		unsigned long when);
+		time64_t when);
 void lnet_notify_locked(struct lnet_peer *lp, int notifylnd, int alive,
-			unsigned long when);
+			time64_t when);
 int lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway_nid,
 		   unsigned int priority);
 int lnet_check_routes(void);
@@ -643,8 +643,8 @@ int lnet_get_peer_info(__u32 peer_index, __u64 *nid,
 static inline void
 lnet_peer_set_alive(struct lnet_peer *lp)
 {
-	lp->lp_last_query = jiffies;
-	lp->lp_last_alive = jiffies;
+	lp->lp_last_query = ktime_get_seconds();
+	lp->lp_last_alive = lp->lp_last_query;
 	if (!lp->lp_alive)
 		lnet_notify_locked(lp, 0, 1, lp->lp_last_alive);
 }
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index cfe8ee4..6d4106f 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -239,8 +239,7 @@ struct lnet_lnd {
 	void (*lnd_notify)(struct lnet_ni *ni, lnet_nid_t peer, int alive);
 
 	/* query of peer aliveness */
-	void (*lnd_query)(struct lnet_ni *ni, lnet_nid_t peer,
-			  unsigned long *when);
+	void (*lnd_query)(struct lnet_ni *ni, lnet_nid_t peer, time64_t *when);
 
 	/* accept a new connection */
 	int (*lnd_accept)(struct lnet_ni *ni, struct socket *sock);
@@ -334,17 +333,17 @@ struct lnet_peer {
 						  * dead<->alive
 						  */
 	long			 lp_txqnob;	 /* ytes queued for sending */
-	unsigned long		 lp_timestamp;	 /* time of last aliveness
+	time64_t		 lp_timestamp;	 /* time of last aliveness
 						  * news
 						  */
-	unsigned long		 lp_ping_timestamp;/* time of last ping
+	time64_t		 lp_ping_timestamp;/* time of last ping
 						    * attempt
 						    */
-	unsigned long		 lp_ping_deadline; /* != 0 if ping reply
+	time64_t		 lp_ping_deadline; /* != 0 if ping reply
 						    * expected
 						    */
-	unsigned long		 lp_last_alive;	/* when I was last alive */
-	unsigned long		 lp_last_query;	/* when lp_ni was queried
+	time64_t		 lp_last_alive;	/* when I was last alive */
+	time64_t		 lp_last_query;	/* when lp_ni was queried
 						 * last time
 						 */
 	struct lnet_ni		*lp_ni;		/* interface peer is on */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 5761e3d..edae4eb 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1039,11 +1039,10 @@ static int kiblnd_ctl(struct lnet_ni *ni, unsigned int cmd, void *arg)
 	return rc;
 }
 
-static void kiblnd_query(struct lnet_ni *ni, lnet_nid_t nid,
-			 unsigned long *when)
+static void kiblnd_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when)
 {
-	unsigned long last_alive = 0;
-	unsigned long now = jiffies;
+	time64_t last_alive = 0;
+	time64_t now = ktime_get_seconds();
 	rwlock_t *glock = &kiblnd_data.kib_global_lock;
 	struct kib_peer *peer;
 	unsigned long flags;
@@ -1066,9 +1065,9 @@ static void kiblnd_query(struct lnet_ni *ni, lnet_nid_t nid,
 	if (!peer)
 		kiblnd_launch_tx(ni, NULL, nid);
 
-	CDEBUG(D_NET, "Peer %s %p, alive %ld secs ago\n",
+	CDEBUG(D_NET, "Peer %s %p, alive %lld secs ago\n",
 	       libcfs_nid2str(nid), peer,
-	       last_alive ? (now - last_alive) / HZ : -1);
+	       last_alive ? now - last_alive : -1);
 }
 
 static void kiblnd_free_pages(struct kib_pages *p)
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 217503f..1b141cc 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -571,8 +571,8 @@ struct kib_peer {
 					  * round robin */
 	struct list_head ibp_tx_queue;    /* msgs waiting for a conn */
 	__u64            ibp_incarnation; /* incarnation of peer */
-	/* when (in jiffies) I was last alive */
-	unsigned long		ibp_last_alive;
+	/* when (in seconds) I was last alive */
+	time64_t		ibp_last_alive;
 	/* # users */
 	atomic_t		ibp_refcount;
 	/* version of peer */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 47eb8b4..b046f00 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1847,8 +1847,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 static void
 kiblnd_peer_alive(struct kib_peer *peer)
 {
-	/* This is racy, but everyone's only writing jiffies */
-	peer->ibp_last_alive = jiffies;
+	/* This is racy, but everyone's only writing ktime_get_seconds() */
+	peer->ibp_last_alive = ktime_get_seconds();
 	mb();
 }
 
@@ -1856,7 +1856,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 kiblnd_peer_notify(struct kib_peer *peer)
 {
 	int error = 0;
-	unsigned long last_alive = 0;
+	time64_t last_alive = 0;
 	unsigned long flags;
 
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
@@ -3216,9 +3216,9 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			}
 
 			if (timedout) {
-				CERROR("Timed out RDMA with %s (%lu): c: %u, oc: %u, rc: %u\n",
+				CERROR("Timed out RDMA with %s (%lld): c: %u, oc: %u, rc: %u\n",
 				       libcfs_nid2str(peer->ibp_nid),
-				       (jiffies - peer->ibp_last_alive) / HZ,
+				       ktime_get_seconds() - peer->ibp_last_alive,
 				       conn->ibc_credits,
 				       conn->ibc_outstanding_credits,
 				       conn->ibc_reserved_credits);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 72c98ee..c6e74ee 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -1537,7 +1537,7 @@ struct ksock_peer *
 
 	if (notify)
 		lnet_notify(peer->ksnp_ni, peer->ksnp_id.nid, 0,
-			    last_alive * HZ);
+			    last_alive);
 }
 
 void
@@ -1828,7 +1828,7 @@ struct ksock_peer *
 }
 
 void
-ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, unsigned long *when)
+ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when)
 {
 	int connect = 1;
 	time64_t last_alive = 0;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 20f5de6..2a61929 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -658,7 +658,7 @@ int  ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 void ksocknal_queue_tx_locked(struct ksock_tx *tx, struct ksock_conn *conn);
 void ksocknal_txlist_done(struct lnet_ni *ni, struct list_head *txlist, int error);
 void ksocknal_notify(struct lnet_ni *ni, lnet_nid_t gw_nid, int alive);
-void ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, unsigned long *when);
+void ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when);
 int ksocknal_thread_start(int (*fn)(void *arg), void *arg, char *name);
 void ksocknal_thread_fini(void);
 void ksocknal_launch_all_connections_locked(struct ksock_peer *peer);
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 20dce34..d8d76ab 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1888,7 +1888,6 @@ void lnet_lib_exit(void)
 	struct lnet_process_id id = {0};
 	struct lnet_ni *ni;
 	int rc;
-	unsigned long secs_passed;
 
 	BUILD_BUG_ON(LIBCFS_IOC_DATA_MAX <
 		     sizeof(struct lnet_ioctl_net_config) +
@@ -2028,12 +2027,17 @@ void lnet_lib_exit(void)
 			&peer_info->pr_lnd_u.pr_peer_credits.cr_peer_tx_qnob);
 	}
 
-	case IOC_LIBCFS_NOTIFY_ROUTER:
-		secs_passed = (ktime_get_real_seconds() - data->ioc_u64[0]);
-		secs_passed *= msecs_to_jiffies(MSEC_PER_SEC);
+	case IOC_LIBCFS_NOTIFY_ROUTER: {
+		time64_t deadline = ktime_get_real_seconds() - data->ioc_u64[0];
 
+		/* The deadline passed in by the user should be some time in
+		 * seconds in the future since the UNIX epoch. We have to map
+		 * that deadline to the wall clock.
+		 */
+		deadline += ktime_get_seconds();
 		return lnet_notify(NULL, data->ioc_nid, data->ioc_flags,
-				   jiffies - secs_passed);
+				   deadline);
+	}
 
 	case IOC_LIBCFS_LNET_DIST:
 		rc = LNetDist(data->ioc_nid, &data->ioc_nid, &data->ioc_u32[1]);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index f8eaf8f..e8092b1 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -492,7 +492,7 @@
 static void
 lnet_ni_query_locked(struct lnet_ni *ni, struct lnet_peer *lp)
 {
-	unsigned long last_alive = 0;
+	time64_t last_alive = 0;
 
 	LASSERT(lnet_peer_aliveness_enabled(lp));
 	LASSERT(ni->ni_lnd->lnd_query);
@@ -501,7 +501,7 @@
 	ni->ni_lnd->lnd_query(ni, lp->lp_nid, &last_alive);
 	lnet_net_lock(lp->lp_cpt);
 
-	lp->lp_last_query = jiffies;
+	lp->lp_last_query = ktime_get_seconds();
 
 	if (last_alive) /* NI has updated timestamp */
 		lp->lp_last_alive = last_alive;
@@ -512,7 +512,7 @@
 lnet_peer_is_alive(struct lnet_peer *lp, unsigned long now)
 {
 	int alive;
-	unsigned long deadline;
+	time64_t deadline;
 
 	LASSERT(lnet_peer_aliveness_enabled(lp));
 
@@ -520,11 +520,11 @@
 	 * ignore the initial assumed death (see lnet_peers_start_down()).
 	 */
 	if (!lp->lp_alive && lp->lp_alive_count > 0 &&
-	    time_after_eq(lp->lp_timestamp, lp->lp_last_alive))
+	    lp->lp_timestamp >= lp->lp_last_alive)
 		return 0;
 
-	deadline = lp->lp_last_alive + lp->lp_ni->ni_peertimeout * HZ;
-	alive = time_after(deadline, now);
+	deadline = lp->lp_last_alive + lp->lp_ni->ni_peertimeout;
+	alive = deadline > now;
 
 	/* Update obsolete lp_alive except for routers assumed to be dead
 	 * initially, because router checker would update aliveness in this
@@ -544,7 +544,7 @@
 static int
 lnet_peer_alive_locked(struct lnet_peer *lp)
 {
-	unsigned long now = jiffies;
+	time64_t now = ktime_get_seconds();
 
 	if (!lnet_peer_aliveness_enabled(lp))
 		return -ENODEV;
@@ -558,15 +558,15 @@
 	 */
 	if (lp->lp_last_query) {
 		static const int lnet_queryinterval = 1;
+		time64_t next_query;
 
-		unsigned long next_query =
-			   lp->lp_last_query + lnet_queryinterval * HZ;
+		next_query = lp->lp_last_query + lnet_queryinterval;
 
-		if (time_before(now, next_query)) {
+		if (now < next_query) {
 			if (lp->lp_alive)
-				CWARN("Unexpected aliveness of peer %s: %d < %d (%d/%d)\n",
+				CWARN("Unexpected aliveness of peer %s: %lld < %lld (%d/%d)\n",
 				      libcfs_nid2str(lp->lp_nid),
-				      (int)now, (int)next_query,
+				      now, next_query,
 				      lnet_queryinterval,
 				      lp->lp_ni->ni_peertimeout);
 			return 0;
diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
index 0066394..cb1f905 100644
--- a/drivers/staging/lustre/lnet/lnet/net_fault.c
+++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
@@ -57,9 +57,9 @@ struct lnet_drop_rule {
 	/**
 	 * seconds to drop the next message, it's exclusive with dr_drop_at
 	 */
-	unsigned long		dr_drop_time;
+	time64_t		dr_drop_time;
 	/** baseline to caculate dr_drop_time */
-	unsigned long		dr_time_base;
+	time64_t		dr_time_base;
 	/** statistic of dropped messages */
 	struct lnet_fault_stat	dr_stat;
 };
@@ -169,9 +169,10 @@ struct lnet_drop_rule {
 
 	rule->dr_attr = *attr;
 	if (attr->u.drop.da_interval) {
-		rule->dr_time_base = jiffies + attr->u.drop.da_interval * HZ;
-		rule->dr_drop_time = jiffies +
-			prandom_u32_max(attr->u.drop.da_interval) * HZ;
+		rule->dr_time_base = ktime_get_seconds() +
+				     attr->u.drop.da_interval;
+		rule->dr_drop_time = ktime_get_seconds() +
+				     prandom_u32_max(attr->u.drop.da_interval);
 	} else {
 		rule->dr_drop_at = prandom_u32_max(attr->u.drop.da_rate);
 	}
@@ -279,9 +280,10 @@ struct lnet_drop_rule {
 		if (attr->u.drop.da_rate) {
 			rule->dr_drop_at = prandom_u32_max(attr->u.drop.da_rate);
 		} else {
-			rule->dr_drop_time = jiffies +
-				prandom_u32_max(attr->u.drop.da_interval) * HZ;
-			rule->dr_time_base = jiffies + attr->u.drop.da_interval * HZ;
+			rule->dr_drop_time = ktime_get_seconds() +
+				prandom_u32_max(attr->u.drop.da_interval);
+			rule->dr_time_base = ktime_get_seconds() +
+					     attr->u.drop.da_interval;
 		}
 		spin_unlock(&rule->dr_lock);
 	}
@@ -306,19 +308,19 @@ struct lnet_drop_rule {
 	/* match this rule, check drop rate now */
 	spin_lock(&rule->dr_lock);
 	if (rule->dr_drop_time) { /* time based drop */
-		unsigned long now = jiffies;
+		time64_t now = ktime_get_seconds();
 
 		rule->dr_stat.fs_count++;
-		drop = time_after_eq(now, rule->dr_drop_time);
+		drop = now >= rule->dr_drop_time;
 		if (drop) {
-			if (time_after(now, rule->dr_time_base))
+			if (now > rule->dr_time_base)
 				rule->dr_time_base = now;
 
 			rule->dr_drop_time = rule->dr_time_base +
-				prandom_u32_max(attr->u.drop.da_interval) * HZ;
-			rule->dr_time_base += attr->u.drop.da_interval * HZ;
+				prandom_u32_max(attr->u.drop.da_interval);
+			rule->dr_time_base += attr->u.drop.da_interval;
 
-			CDEBUG(D_NET, "Drop Rule %s->%s: next drop : %lu\n",
+			CDEBUG(D_NET, "Drop Rule %s->%s: next drop : %lld\n",
 			       libcfs_nid2str(attr->fa_src),
 			       libcfs_nid2str(attr->fa_dst),
 			       rule->dr_drop_time);
@@ -404,9 +406,9 @@ struct lnet_delay_rule {
 	/**
 	 * seconds to delay the next message, it's exclusive with dl_delay_at
 	 */
-	unsigned long		dl_delay_time;
+	time64_t		dl_delay_time;
 	/** baseline to caculate dl_delay_time */
-	unsigned long		dl_time_base;
+	time64_t		dl_time_base;
 	/** jiffies to send the next delayed message */
 	unsigned long		dl_msg_send;
 	/** delayed message list */
@@ -436,12 +438,6 @@ struct delay_daemon_data {
 
 static struct delay_daemon_data	delay_dd;
 
-static unsigned long
-round_timeout(unsigned long timeout)
-{
-	return (unsigned int)rounddown(timeout, HZ) + HZ;
-}
-
 static void
 delay_rule_decref(struct lnet_delay_rule *rule)
 {
@@ -472,19 +468,19 @@ struct delay_daemon_data {
 	/* match this rule, check delay rate now */
 	spin_lock(&rule->dl_lock);
 	if (rule->dl_delay_time) { /* time based delay */
-		unsigned long now = jiffies;
+		time64_t now = ktime_get_seconds();
 
 		rule->dl_stat.fs_count++;
-		delay = time_after_eq(now, rule->dl_delay_time);
+		delay = now >= rule->dl_delay_time;
 		if (delay) {
-			if (time_after(now, rule->dl_time_base))
+			if (now > rule->dl_time_base)
 				rule->dl_time_base = now;
 
 			rule->dl_delay_time = rule->dl_time_base +
-				prandom_u32_max(attr->u.delay.la_interval) * HZ;
-			rule->dl_time_base += attr->u.delay.la_interval * HZ;
+				prandom_u32_max(attr->u.delay.la_interval);
+			rule->dl_time_base += attr->u.delay.la_interval;
 
-			CDEBUG(D_NET, "Delay Rule %s->%s: next delay : %lu\n",
+			CDEBUG(D_NET, "Delay Rule %s->%s: next delay : %lld\n",
 			       libcfs_nid2str(attr->fa_src),
 			       libcfs_nid2str(attr->fa_dst),
 			       rule->dl_delay_time);
@@ -512,8 +508,7 @@ struct delay_daemon_data {
 	rule->dl_stat.u.delay.ls_delayed++;
 
 	list_add_tail(&msg->msg_list, &rule->dl_msg_list);
-	msg->msg_delay_send = round_timeout(
-			jiffies + attr->u.delay.la_latency * HZ);
+	msg->msg_delay_send = ktime_get_seconds() + attr->u.delay.la_latency;
 	if (rule->dl_msg_send == -1) {
 		rule->dl_msg_send = msg->msg_delay_send;
 		mod_timer(&rule->dl_timer, rule->dl_msg_send);
@@ -562,7 +557,7 @@ struct delay_daemon_data {
 {
 	struct lnet_msg *msg;
 	struct lnet_msg *tmp;
-	unsigned long now = jiffies;
+	time64_t now = ktime_get_seconds();
 
 	if (!all && rule->dl_msg_send > now)
 		return;
@@ -767,9 +762,10 @@ struct delay_daemon_data {
 
 	rule->dl_attr = *attr;
 	if (attr->u.delay.la_interval) {
-		rule->dl_time_base = jiffies + attr->u.delay.la_interval * HZ;
-		rule->dl_delay_time = jiffies + 
-			prandom_u32_max(attr->u.delay.la_interval) * HZ;
+		rule->dl_time_base = ktime_get_seconds() +
+				     attr->u.delay.la_interval;
+		rule->dl_delay_time = ktime_get_seconds() +
+				      prandom_u32_max(attr->u.delay.la_interval);
 	} else {
 		rule->dl_delay_at = prandom_u32_max(attr->u.delay.la_rate);
 	}
@@ -919,10 +915,10 @@ struct delay_daemon_data {
 		if (attr->u.delay.la_rate) {
 			rule->dl_delay_at = prandom_u32_max(attr->u.delay.la_rate);
 		} else {
-			rule->dl_delay_time =
-				jiffies + prandom_u32_max(
-					attr->u.delay.la_interval) * HZ;
-			rule->dl_time_base = jiffies + attr->u.delay.la_interval * HZ;
+			rule->dl_delay_time = ktime_get_seconds() +
+				prandom_u32_max(attr->u.delay.la_interval);
+			rule->dl_time_base = ktime_get_seconds() +
+					     attr->u.delay.la_interval;
 		}
 		spin_unlock(&rule->dl_lock);
 	}
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 5829414..6ce175d 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -315,7 +315,7 @@ struct lnet_peer *
 	lp->lp_alive_count = 0;
 	lp->lp_timestamp = 0;
 	lp->lp_alive = !lnet_peers_start_down(); /* 1 bit!! */
-	lp->lp_last_alive = jiffies; /* assumes alive */
+	lp->lp_last_alive = ktime_get_seconds(); /* assumes alive */
 	lp->lp_last_query = 0; /* haven't asked NI yet */
 	lp->lp_ping_timestamp = 0;
 	lp->lp_ping_feats = LNET_PING_FEAT_INVAL;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 6267d5e..3f84df6 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -101,9 +101,9 @@
 
 void
 lnet_notify_locked(struct lnet_peer *lp, int notifylnd, int alive,
-		   unsigned long when)
+		   time64_t when)
 {
-	if (time_before(when, lp->lp_timestamp)) { /* out of date information */
+	if (lp->lp_timestamp > when) { /* out of date information */
 		CDEBUG(D_NET, "Out of date\n");
 		return;
 	}
@@ -765,7 +765,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	 * we ping alive routers to try to detect router death before
 	 * apps get burned).
 	 */
-	lnet_notify_locked(lp, 1, !event->status, jiffies);
+	lnet_notify_locked(lp, 1, !event->status, ktime_get_seconds());
 
 	/*
 	 * The router checker will wake up very shortly and do the
@@ -832,7 +832,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 {
 	struct lnet_ni *ni;
 	time64_t now;
-	int timeout;
+	time64_t timeout;
 
 	LASSERT(the_lnet.ln_routing);
 
@@ -857,7 +857,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 		LASSERT(ni->ni_status);
 
 		if (ni->ni_status->ns_status != LNET_NI_STATUS_DOWN) {
-			CDEBUG(D_NET, "NI(%s:%d) status changed to down\n",
+			CDEBUG(D_NET, "NI(%s:%lld) status changed to down\n",
 			       libcfs_nid2str(ni->ni_nid), timeout);
 			/*
 			 * NB: so far, this is the only place to set
@@ -976,13 +976,13 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 lnet_ping_router_locked(struct lnet_peer *rtr)
 {
 	struct lnet_rc_data *rcd = NULL;
-	unsigned long now = jiffies;
-	int secs;
+	time64_t now = ktime_get_seconds();
+	time64_t secs;
 
 	lnet_peer_addref_locked(rtr);
 
 	if (rtr->lp_ping_deadline && /* ping timed out? */
-	    time_after(now, rtr->lp_ping_deadline))
+	    now > rtr->lp_ping_deadline)
 		lnet_notify_locked(rtr, 1, 0, now);
 
 	/* Run any outstanding notifications */
@@ -1004,13 +1004,13 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	secs = lnet_router_check_interval(rtr);
 
 	CDEBUG(D_NET,
-	       "rtr %s %d: deadline %lu ping_notsent %d alive %d alive_count %d lp_ping_timestamp %lu\n",
+	       "rtr %s %lldd: deadline %lld ping_notsent %d alive %d alive_count %d lp_ping_timestamp %lld\n",
 	       libcfs_nid2str(rtr->lp_nid), secs,
 	       rtr->lp_ping_deadline, rtr->lp_ping_notsent,
 	       rtr->lp_alive, rtr->lp_alive_count, rtr->lp_ping_timestamp);
 
 	if (secs && !rtr->lp_ping_notsent &&
-	    time_after(now, rtr->lp_ping_timestamp + secs * HZ)) {
+	    now > rtr->lp_ping_timestamp + secs) {
 		int rc;
 		struct lnet_process_id id;
 		struct lnet_handle_md mdh;
@@ -1025,8 +1025,8 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 		mdh = rcd->rcd_mdh;
 
 		if (!rtr->lp_ping_deadline) {
-			rtr->lp_ping_deadline =
-				jiffies + router_ping_timeout * HZ;
+			rtr->lp_ping_deadline = ktime_get_seconds() +
+						router_ping_timeout;
 		}
 
 		lnet_net_unlock(rtr->lp_cpt);
@@ -1726,10 +1726,10 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 int
-lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, int alive, unsigned long when)
+lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, int alive, time64_t when)
 {
 	struct lnet_peer *lp = NULL;
-	unsigned long now = jiffies;
+	time64_t now = ktime_get_seconds();
 	int cpt = lnet_cpt_of_nid(nid);
 
 	LASSERT(!in_interrupt());
@@ -1748,11 +1748,10 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	}
 
 	/* can't do predictions... */
-	if (time_after(when, now)) {
-		CWARN("Ignoring prediction from %s of %s %s %ld seconds in the future\n",
+	if (when > now) {
+		CWARN("Ignoring prediction from %s of %s %s %lld seconds in the future\n",
 		      !ni ? "userspace" : libcfs_nid2str(ni->ni_nid),
-		      libcfs_nid2str(nid), alive ? "up" : "down",
-		      (when - now) / HZ);
+		      libcfs_nid2str(nid), alive ? "up" : "down", when - now);
 		return -EINVAL;
 	}
 
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index ae4b7f5..c0d30970 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -323,14 +323,14 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 
 		if (peer) {
 			lnet_nid_t nid = peer->lp_nid;
-			unsigned long now = jiffies;
-			unsigned long deadline = peer->lp_ping_deadline;
+			time64_t now = ktime_get_seconds();
+			time64_t deadline = peer->lp_ping_deadline;
 			int nrefs = peer->lp_refcount;
 			int nrtrrefs = peer->lp_rtr_refcount;
 			int alive_cnt = peer->lp_alive_count;
 			int alive = peer->lp_alive;
 			int pingsent = !peer->lp_ping_notsent;
-			int last_ping = (now - peer->lp_ping_timestamp) / HZ;
+			time64_t last_ping = now - peer->lp_ping_timestamp;
 			int down_ni = 0;
 			struct lnet_route *rtr;
 
@@ -351,18 +351,17 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 
 			if (!deadline)
 				s += snprintf(s, tmpstr + tmpsiz - s,
-					      "%-4d %7d %9d %6s %12d %9d %8s %7d %s\n",
+					      "%-4d %7d %9d %6s %12llu %9d %8s %7d %s\n",
 					      nrefs, nrtrrefs, alive_cnt,
 					      alive ? "up" : "down", last_ping,
 					      pingsent, "NA", down_ni,
 					      libcfs_nid2str(nid));
 			else
 				s += snprintf(s, tmpstr + tmpsiz - s,
-					      "%-4d %7d %9d %6s %12d %9d %8lu %7d %s\n",
+					      "%-4d %7d %9d %6s %12llu %9d %8llu %7d %s\n",
 					      nrefs, nrtrrefs, alive_cnt,
 					      alive ? "up" : "down", last_ping,
-					      pingsent,
-					      (deadline - now) / HZ,
+					      pingsent, deadline - now,
 					      down_ni, libcfs_nid2str(nid));
 			LASSERT(tmpstr + tmpsiz - s > 0);
 		}
@@ -493,7 +492,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 		if (peer) {
 			lnet_nid_t nid = peer->lp_nid;
 			int nrefs = peer->lp_refcount;
-			int lastalive = -1;
+			time64_t lastalive = -1;
 			char *aliveness = "NA";
 			int maxcr = peer->lp_ni->ni_peertxcredits;
 			int txcr = peer->lp_txcredits;
@@ -507,11 +506,9 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 				aliveness = peer->lp_alive ? "up" : "down";
 
 			if (lnet_peer_aliveness_enabled(peer)) {
-				unsigned long now = jiffies;
-				long delta;
+				time64_t now = ktime_get_seconds();
 
-				delta = now - peer->lp_last_alive;
-				lastalive = (delta) / HZ;
+				lastalive = now - peer->lp_last_alive;
 
 				/* No need to mess up peers contents with
 				 * arbitrarily long integers - it suffices to
@@ -524,7 +521,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 			lnet_net_unlock(cpt);
 
 			s += snprintf(s, tmpstr + tmpsiz - s,
-				      "%-24s %4d %5s %5d %5d %5d %5d %5d %5d %d\n",
+				      "%-24s %4d %5s %5lld %5d %5d %5d %5d %5d %d\n",
 				      libcfs_nid2str(nid), nrefs, aliveness,
 				      lastalive, maxcr, rtrcr, minrtrcr, txcr,
 				      mintxcr, txqnob);
@@ -679,7 +676,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 			struct lnet_tx_queue *tq;
 			char *stat;
 			time64_t now = ktime_get_real_seconds();
-			int last_alive = -1;
+			time64_t last_alive = -1;
 			int i;
 			int j;
 
@@ -714,7 +711,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 					lnet_net_lock(i);
 
 				s += snprintf(s, tmpstr + tmpsiz - s,
-					      "%-24s %6s %5d %4d %4d %4d %5d %5d %5d\n",
+					      "%-24s %6s %5lld %4d %4d %4d %5d %5d %5d\n",
 					      libcfs_nid2str(ni->ni_nid), stat,
 					      last_alive, *ni->ni_refs[i],
 					      ni->ni_peertxcredits,
-- 
1.8.3.1
