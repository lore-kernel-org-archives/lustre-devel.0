From: NeilBrown <neilb@suse.com>
Date: Thu, 29 Mar 2018 15:26:48 +1100
Subject: [lustre-devel] [PATCH 10/17] staging: lustre: libcfs: discard
 cfs_time_add/sub
In-Reply-To: <152229732768.27689.4800156943561963977.stgit@noble>
References: <152229732768.27689.4800156943561963977.stgit@noble>
Message-ID: <152229760858.27689.1121127347892062619.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

cfs_time_add adds its arguments.
cfs_time_sub subtracts finds the difference.
Discard these and use '+' and '-' directly.

This change highlighted a type error.  The structure field
cr_queued_time was used to store jiffies, but was declared
as time_t (meant for seconds).  So the time is changed to
"unsigned long".

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_time.h      |   12 +---------
 .../lustre/include/linux/libcfs/linux/linux-time.h |    8 +------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   23 +++++++-------------
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    6 ++---
 drivers/staging/lustre/lnet/lnet/router.c          |    5 ++--
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    7 +++---
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    4 ++-
 drivers/staging/lustre/lnet/selftest/timer.c       |    2 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |    5 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    3 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    8 +++----
 drivers/staging/lustre/lustre/osc/osc_object.c     |    3 +--
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |    9 +++-----
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    2 +-
 15 files changed, 32 insertions(+), 67 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
index df7a3f13f3b3..7b41a129f041 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
@@ -40,16 +40,6 @@
  * generic time manipulation functions.
  */
 
-static inline unsigned long cfs_time_add(unsigned long t, long d)
-{
-	return (unsigned long)(t + d);
-}
-
-static inline unsigned long cfs_time_sub(unsigned long t1, unsigned long t2)
-{
-	return (unsigned long)(t1 - t2);
-}
-
 static inline int cfs_time_after(unsigned long t1, unsigned long t2)
 {
 	return time_before(t2, t1);
@@ -62,7 +52,7 @@ static inline int cfs_time_aftereq(unsigned long t1, unsigned long t2)
 
 static inline unsigned long cfs_time_shift(int seconds)
 {
-	return cfs_time_add(jiffies, seconds * HZ);
+	return jiffies + seconds * HZ;
 }
 
 /*
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
index ba115e8c820f..b3a80531bd71 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
@@ -65,15 +65,9 @@ static inline long cfs_duration_sec(long d)
 	return d / msecs_to_jiffies(MSEC_PER_SEC);
 }
 
-static inline u64 cfs_time_add_64(u64 t, u64 d)
-{
-	return t + d;
-}
-
 static inline u64 cfs_time_shift_64(int seconds)
 {
-	return cfs_time_add_64(get_jiffies_64(),
-			       seconds * HZ);
+	return get_jiffies_64() + (u64)seconds * HZ;
 }
 
 static inline int cfs_time_before_64(u64 t1, u64 t2)
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 0efde0009a15..4546618c1c12 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -1682,7 +1682,7 @@ ksocknal_destroy_conn(struct ksock_conn *conn)
 		       libcfs_id2str(conn->ksnc_peer->ksnp_id), conn->ksnc_type,
 		       &conn->ksnc_ipaddr, conn->ksnc_port,
 		       iov_iter_count(&conn->ksnc_rx_to), conn->ksnc_rx_nob_left,
-		       cfs_duration_sec(cfs_time_sub(jiffies, last_rcv)));
+		       cfs_duration_sec(jiffies - last_rcv));
 		lnet_finalize(conn->ksnc_peer->ksnp_ni,
 			      conn->ksnc_cookie, -EIO);
 		break;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index f97da4540b51..5b34c7c030ad 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -481,8 +481,7 @@ ksocknal_process_transmit(struct ksock_conn *conn, struct ksock_tx *tx)
 		LASSERT(conn->ksnc_tx_scheduled);
 		list_add_tail(&conn->ksnc_tx_list,
 			      &ksocknal_data.ksnd_enomem_conns);
-		if (!cfs_time_aftereq(cfs_time_add(jiffies,
-						   SOCKNAL_ENOMEM_RETRY),
+		if (!cfs_time_aftereq(jiffies + SOCKNAL_ENOMEM_RETRY,
 				   ksocknal_data.ksnd_reaper_waketime))
 			wake_up(&ksocknal_data.ksnd_reaper_waitq);
 
@@ -1777,8 +1776,7 @@ ksocknal_connect(struct ksock_route *route)
 	int retry_later = 0;
 	int rc = 0;
 
-	deadline = cfs_time_add(jiffies,
-				*ksocknal_tunables.ksnd_timeout * HZ);
+	deadline = jiffies + *ksocknal_tunables.ksnd_timeout * HZ;
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
@@ -1877,8 +1875,7 @@ ksocknal_connect(struct ksock_route *route)
 			 */
 			route->ksnr_retry_interval =
 				*ksocknal_tunables.ksnd_min_reconnectms * HZ / 1000;
-			route->ksnr_timeout = cfs_time_add(jiffies,
-							   route->ksnr_retry_interval);
+			route->ksnr_timeout = jiffies + route->ksnr_retry_interval;
 		}
 
 		ksocknal_launch_connection_locked(route);
@@ -1903,8 +1900,7 @@ ksocknal_connect(struct ksock_route *route)
 		    (long)*ksocknal_tunables.ksnd_max_reconnectms * HZ / 1000);
 
 	LASSERT(route->ksnr_retry_interval);
-	route->ksnr_timeout = cfs_time_add(jiffies,
-					   route->ksnr_retry_interval);
+	route->ksnr_timeout = jiffies + route->ksnr_retry_interval;
 
 	if (!list_empty(&peer->ksnp_tx_queue) &&
 	    !peer->ksnp_accepting &&
@@ -2302,8 +2298,7 @@ ksocknal_send_keepalive_locked(struct ksock_peer *peer)
 
 	if (*ksocknal_tunables.ksnd_keepalive <= 0 ||
 	    time_before(jiffies,
-			cfs_time_add(peer->ksnp_last_alive,
-				     *ksocknal_tunables.ksnd_keepalive * HZ)))
+			peer->ksnp_last_alive + *ksocknal_tunables.ksnd_keepalive * HZ))
 		return 0;
 
 	if (time_before(jiffies, peer->ksnp_send_keepalive))
@@ -2531,8 +2526,7 @@ ksocknal_reaper(void *arg)
 		}
 
 		/* careful with the jiffy wrap... */
-		while ((timeout = cfs_time_sub(deadline,
-					       jiffies)) <= 0) {
+		while ((timeout = deadline - jiffies) <= 0) {
 			const int n = 4;
 			const int p = 1;
 			int chunk = ksocknal_data.ksnd_peer_hash_size;
@@ -2557,7 +2551,7 @@ ksocknal_reaper(void *arg)
 					     ksocknal_data.ksnd_peer_hash_size;
 			}
 
-			deadline = cfs_time_add(deadline, p * HZ);
+			deadline = deadline + p * HZ;
 		}
 
 		if (nenomem_conns) {
@@ -2568,8 +2562,7 @@ ksocknal_reaper(void *arg)
 			 */
 			timeout = SOCKNAL_ENOMEM_RETRY;
 		}
-		ksocknal_data.ksnd_reaper_waketime =
-			cfs_time_add(jiffies, timeout);
+		ksocknal_data.ksnd_reaper_waketime = jiffies + timeout;
 
 		set_current_state(TASK_INTERRUPTIBLE);
 		add_wait_queue(&ksocknal_data.ksnd_reaper_waitq, &wait);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 289ed876bd81..5574d2148c9d 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -523,8 +523,7 @@ lnet_peer_is_alive(struct lnet_peer *lp, unsigned long now)
 	    cfs_time_aftereq(lp->lp_timestamp, lp->lp_last_alive))
 		return 0;
 
-	deadline = cfs_time_add(lp->lp_last_alive,
-				lp->lp_ni->ni_peertimeout * HZ);
+	deadline = lp->lp_last_alive + lp->lp_ni->ni_peertimeout * HZ;
 	alive = cfs_time_after(deadline, now);
 
 	/* Update obsolete lp_alive except for routers assumed to be dead
@@ -561,8 +560,7 @@ lnet_peer_alive_locked(struct lnet_peer *lp)
 		static const int lnet_queryinterval = 1;
 
 		unsigned long next_query =
-			   cfs_time_add(lp->lp_last_query,
-					lnet_queryinterval * HZ);
+			   lp->lp_last_query + lnet_queryinterval * HZ;
 
 		if (time_before(now, next_query)) {
 			if (lp->lp_alive)
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index ac9b392a0afa..4595a7ad4336 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1010,8 +1010,7 @@ lnet_ping_router_locked(struct lnet_peer *rtr)
 	       rtr->lp_alive, rtr->lp_alive_count, rtr->lp_ping_timestamp);
 
 	if (secs && !rtr->lp_ping_notsent &&
-	    cfs_time_after(now, cfs_time_add(rtr->lp_ping_timestamp,
-					     secs * HZ))) {
+	    cfs_time_after(now, rtr->lp_ping_timestamp + secs * HZ)) {
 		int rc;
 		struct lnet_process_id id;
 		struct lnet_handle_md mdh;
@@ -1753,7 +1752,7 @@ lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, int alive, unsigned long when)
 		CWARN("Ignoring prediction from %s of %s %s %ld seconds in the future\n",
 		      !ni ? "userspace" : libcfs_nid2str(ni->ni_nid),
 		      libcfs_nid2str(nid), alive ? "up" : "down",
-		      cfs_duration_sec(cfs_time_sub(when, now)));
+		      cfs_duration_sec(when - now));
 		return -EINVAL;
 	}
 
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 315d067540c0..e4172311be68 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -331,8 +331,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 			int alive_cnt = peer->lp_alive_count;
 			int alive = peer->lp_alive;
 			int pingsent = !peer->lp_ping_notsent;
-			int last_ping = cfs_duration_sec(cfs_time_sub(now,
-						     peer->lp_ping_timestamp));
+			int last_ping = cfs_duration_sec(now - peer->lp_ping_timestamp);
 			int down_ni = 0;
 			struct lnet_route *rtr;
 
@@ -364,7 +363,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 					      nrefs, nrtrrefs, alive_cnt,
 					      alive ? "up" : "down", last_ping,
 					      pingsent,
-					      cfs_duration_sec(cfs_time_sub(deadline, now)),
+					      cfs_duration_sec(deadline - now),
 					      down_ni, libcfs_nid2str(nid));
 			LASSERT(tmpstr + tmpsiz - s > 0);
 		}
@@ -512,7 +511,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 				unsigned long now = jiffies;
 				long delta;
 
-				delta = cfs_time_sub(now, peer->lp_last_alive);
+				delta = now - peer->lp_last_alive;
 				lastalive = cfs_duration_sec(delta);
 
 				/* No need to mess up peers contents with
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 68e06e06857d..ea4944b9108b 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -500,8 +500,8 @@ lstcon_rpc_trans_interpreter(struct lstcon_rpc_trans *trans,
 
 		nd = crpc->crp_node;
 
-		dur = (long)cfs_time_sub(crpc->crp_stamp,
-		      (unsigned long)console_session.ses_id.ses_stamp);
+		dur = (long)(crpc->crp_stamp -
+			     (unsigned long)console_session.ses_id.ses_stamp);
 		jiffies_to_timeval(dur, &tv);
 
 		if (copy_to_user(&ent->rpe_peer, &nd->nd_id,
diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
index 1b2c5fc81358..1f9d5487e2f5 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.c
+++ b/drivers/staging/lustre/lnet/selftest/timer.c
@@ -157,7 +157,7 @@ stt_check_timers(unsigned long *last)
 
 	while (cfs_time_aftereq(this_slot, *last)) {
 		expired += stt_expire_list(STTIMER_SLOT(this_slot), now);
-		this_slot = cfs_time_sub(this_slot, STTIMER_SLOTTIME);
+		this_slot = this_slot - STTIMER_SLOTTIME;
 	}
 
 	*last = now & STTIMER_SLOTTIMEMASK;
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index f4824d8ec741..d13db55b7242 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -556,7 +556,7 @@ struct ptlrpc_cli_req {
 	/** optional time limit for send attempts */
 	long				 cr_delay_limit;
 	/** time request was first queued */
-	time_t				 cr_queued_time;
+	unsigned long			 cr_queued_time;
 	/** request sent timeval */
 	struct timespec64		 cr_sent_tv;
 	/** time for request really sent out */
@@ -2253,8 +2253,7 @@ static inline int ptlrpc_req_get_repsize(struct ptlrpc_request *req)
 static inline int ptlrpc_send_limit_expired(struct ptlrpc_request *req)
 {
 	if (req->rq_delay_limit != 0 &&
-	    time_before(cfs_time_add(req->rq_queued_time,
-				     req->rq_delay_limit * HZ),
+	    time_before(req->rq_queued_time + req->rq_delay_limit * HZ,
 			jiffies)) {
 		return 1;
 	}
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index ab4dd15c8dd4..150e78c9eb68 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -326,8 +326,7 @@ static void ldlm_handle_gl_callback(struct ptlrpc_request *req,
 	if (lock->l_granted_mode == LCK_PW &&
 	    !lock->l_readers && !lock->l_writers &&
 	    cfs_time_after(jiffies,
-			   cfs_time_add(lock->l_last_used,
-					10 * HZ))) {
+			   lock->l_last_used + 10 * HZ)) {
 		unlock_res_and_lock(lock);
 		if (ldlm_bl_to_thread_lock(ns, NULL, lock))
 			ldlm_handle_bl_callback(ns, NULL, lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 0e1b21c1f06d..6eb42f16040d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1176,13 +1176,12 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 	 * Despite of the LV, It doesn't make sense to keep the lock which
 	 * is unused for ns_max_age time.
 	 */
-	if (cfs_time_after(jiffies,
-			   cfs_time_add(lock->l_last_used, ns->ns_max_age)))
+	if (cfs_time_after(jiffies, lock->l_last_used + ns->ns_max_age))
 		return LDLM_POLICY_CANCEL_LOCK;
 
 	slv = ldlm_pool_get_slv(pl);
 	lvf = ldlm_pool_get_lvf(pl);
-	la = cfs_duration_sec(cfs_time_sub(cur, lock->l_last_used));
+	la = cfs_duration_sec(cur - lock->l_last_used);
 	lv = lvf * la * unused;
 
 	/* Inform pool about current CLV to see it via debugfs. */
@@ -1233,8 +1232,7 @@ static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
 						    int count)
 {
 	if ((added >= count) &&
-	    time_before(jiffies,
-			cfs_time_add(lock->l_last_used, ns->ns_max_age)))
+	    time_before(jiffies, lock->l_last_used + ns->ns_max_age))
 		return LDLM_POLICY_KEEP_LOCK;
 
 	return LDLM_POLICY_CANCEL_LOCK;
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index c5dc894a4c1b..154d1721636e 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -327,8 +327,7 @@ int osc_object_is_contended(struct osc_object *obj)
 	 * I like copy-paste. the code is copied from
 	 * ll_file_is_contended.
 	 */
-	retry_time = cfs_time_add(obj->oo_contention_time,
-				  osc_contention_time * HZ);
+	retry_time = obj->oo_contention_time + osc_contention_time * HZ;
 	if (cfs_time_after(cur_time, retry_time)) {
 		osc_object_clear_contended(obj);
 		return 0;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 57c7db47e249..e836591c5936 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -141,8 +141,7 @@ static long pinger_check_timeout(unsigned long time)
 	}
 	mutex_unlock(&pinger_mutex);
 
-	return cfs_time_sub(cfs_time_add(time, timeout * HZ),
-					 jiffies);
+	return time + timeout * HZ - jiffies;
 }
 
 static bool ir_up;
@@ -238,8 +237,7 @@ static void ptlrpc_pinger_main(struct work_struct *ws)
 			/* obd_timeout might have changed */
 			if (imp->imp_pingable && imp->imp_next_ping &&
 			    cfs_time_after(imp->imp_next_ping,
-					   cfs_time_add(this_ping,
-							PING_INTERVAL * HZ)))
+					   this_ping + PING_INTERVAL * HZ))
 				ptlrpc_update_next_ping(imp, 0);
 		}
 		mutex_unlock(&pinger_mutex);
@@ -255,8 +253,7 @@ static void ptlrpc_pinger_main(struct work_struct *ws)
 		 */
 		CDEBUG(D_INFO, "next wakeup in " CFS_DURATION_T " (%ld)\n",
 		       time_to_next_wake,
-		       cfs_time_add(this_ping,
-				    PING_INTERVAL * HZ));
+		       this_ping + PING_INTERVAL * HZ);
 	} while (time_to_next_wake <= 0);
 
 	queue_delayed_work(pinger_wq, &ping_work,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index fc29efbd9914..e71046db28e5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -1153,7 +1153,7 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 		spin_unlock(&svcpt->scp_at_lock);
 		return;
 	}
-	delay = cfs_time_sub(jiffies, svcpt->scp_at_checktime);
+	delay = jiffies - svcpt->scp_at_checktime;
 	svcpt->scp_at_check = 0;
 
 	if (array->paa_count == 0) {
