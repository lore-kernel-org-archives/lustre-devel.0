From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:38 -0400
Subject: [lustre-devel] [PATCH 28/32] staging/lustre/ldlm: Remove server
	side code from pool support.
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-29-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Server-side scanning is not really used in the client code,
so it's ok to drop it.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   3 -
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     | 348 +--------------------
 2 files changed, 13 insertions(+), 338 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 49b5a07..3cca07e 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -213,7 +213,6 @@ struct ldlm_pool_ops {
 	/** Cancel at least \a nr locks from pool \a pl */
 	int (*po_shrink)(struct ldlm_pool *pl, int nr,
 			 gfp_t gfp_mask);
-	int (*po_setup)(struct ldlm_pool *pl, int limit);
 };
 
 /** One second for pools thread check interval. Each pool has own period. */
@@ -1347,7 +1346,6 @@ void unlock_res_and_lock(struct ldlm_lock *lock);
  * There are not used outside of ldlm.
  * @{
  */
-int ldlm_pools_recalc(ldlm_side_t client);
 int ldlm_pools_init(void);
 void ldlm_pools_fini(void);
 
@@ -1356,7 +1354,6 @@ int ldlm_pool_init(struct ldlm_pool *pl, struct ldlm_namespace *ns,
 int ldlm_pool_shrink(struct ldlm_pool *pl, int nr,
 		     gfp_t gfp_mask);
 void ldlm_pool_fini(struct ldlm_pool *pl);
-int ldlm_pool_setup(struct ldlm_pool *pl, int limit);
 int ldlm_pool_recalc(struct ldlm_pool *pl);
 __u32 ldlm_pool_get_lvf(struct ldlm_pool *pl);
 __u64 ldlm_pool_get_slv(struct ldlm_pool *pl);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index dac1b6f..78d1baf 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -214,70 +214,6 @@ static inline int ldlm_pool_t2gsp(unsigned int t)
 }
 
 /**
- * Recalculates next grant limit on passed \a pl.
- *
- * \pre ->pl_lock is locked.
- */
-static void ldlm_pool_recalc_grant_plan(struct ldlm_pool *pl)
-{
-	int granted, grant_step, limit;
-
-	limit = ldlm_pool_get_limit(pl);
-	granted = atomic_read(&pl->pl_granted);
-
-	grant_step = ldlm_pool_t2gsp(pl->pl_recalc_period);
-	grant_step = ((limit - granted) * grant_step) / 100;
-	pl->pl_grant_plan = granted + grant_step;
-	limit = (limit * 5) >> 2;
-	if (pl->pl_grant_plan > limit)
-		pl->pl_grant_plan = limit;
-}
-
-/**
- * Recalculates next SLV on passed \a pl.
- *
- * \pre ->pl_lock is locked.
- */
-static void ldlm_pool_recalc_slv(struct ldlm_pool *pl)
-{
-	int granted;
-	int grant_plan;
-	int round_up;
-	__u64 slv;
-	__u64 slv_factor;
-	__u64 grant_usage;
-	__u32 limit;
-
-	slv = pl->pl_server_lock_volume;
-	grant_plan = pl->pl_grant_plan;
-	limit = ldlm_pool_get_limit(pl);
-	granted = atomic_read(&pl->pl_granted);
-	round_up = granted < limit;
-
-	grant_usage = max_t(int, limit - (granted - grant_plan), 1);
-
-	/*
-	 * Find out SLV change factor which is the ratio of grant usage
-	 * from limit. SLV changes as fast as the ratio of grant plan
-	 * consumption. The more locks from grant plan are not consumed
-	 * by clients in last interval (idle time), the faster grows
-	 * SLV. And the opposite, the more grant plan is over-consumed
-	 * (load time) the faster drops SLV.
-	 */
-	slv_factor = grant_usage << LDLM_POOL_SLV_SHIFT;
-	do_div(slv_factor, limit);
-	slv = slv * slv_factor;
-	slv = dru(slv, LDLM_POOL_SLV_SHIFT, round_up);
-
-	if (slv > ldlm_pool_slv_max(limit))
-		slv = ldlm_pool_slv_max(limit);
-	else if (slv < ldlm_pool_slv_min(limit))
-		slv = ldlm_pool_slv_min(limit);
-
-	pl->pl_server_lock_volume = slv;
-}
-
-/**
  * Recalculates next stats on passed \a pl.
  *
  * \pre ->pl_lock is locked.
@@ -303,147 +239,6 @@ static void ldlm_pool_recalc_stats(struct ldlm_pool *pl)
 }
 
 /**
- * Sets current SLV into obd accessible via ldlm_pl2ns(pl)->ns_obd.
- */
-static void ldlm_srv_pool_push_slv(struct ldlm_pool *pl)
-{
-	struct obd_device *obd;
-
-	/*
-	 * Set new SLV in obd field for using it later without accessing the
-	 * pool. This is required to avoid race between sending reply to client
-	 * with new SLV and cleanup server stack in which we can't guarantee
-	 * that namespace is still alive. We know only that obd is alive as
-	 * long as valid export is alive.
-	 */
-	obd = ldlm_pl2ns(pl)->ns_obd;
-	LASSERT(obd != NULL);
-	write_lock(&obd->obd_pool_lock);
-	obd->obd_pool_slv = pl->pl_server_lock_volume;
-	write_unlock(&obd->obd_pool_lock);
-}
-
-/**
- * Recalculates all pool fields on passed \a pl.
- *
- * \pre ->pl_lock is not locked.
- */
-static int ldlm_srv_pool_recalc(struct ldlm_pool *pl)
-{
-	time64_t recalc_interval_sec;
-
-	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
-	if (recalc_interval_sec < pl->pl_recalc_period)
-		return 0;
-
-	spin_lock(&pl->pl_lock);
-	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
-	if (recalc_interval_sec < pl->pl_recalc_period) {
-		spin_unlock(&pl->pl_lock);
-		return 0;
-	}
-	/*
-	 * Recalc SLV after last period. This should be done
-	 * _before_ recalculating new grant plan.
-	 */
-	ldlm_pool_recalc_slv(pl);
-
-	/*
-	 * Make sure that pool informed obd of last SLV changes.
-	 */
-	ldlm_srv_pool_push_slv(pl);
-
-	/*
-	 * Update grant_plan for new period.
-	 */
-	ldlm_pool_recalc_grant_plan(pl);
-
-	pl->pl_recalc_time = ktime_get_real_seconds();
-	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_TIMING_STAT,
-			    recalc_interval_sec);
-	spin_unlock(&pl->pl_lock);
-	return 0;
-}
-
-/**
- * This function is used on server side as main entry point for memory
- * pressure handling. It decreases SLV on \a pl according to passed
- * \a nr and \a gfp_mask.
- *
- * Our goal here is to decrease SLV such a way that clients hold \a nr
- * locks smaller in next 10h.
- */
-static int ldlm_srv_pool_shrink(struct ldlm_pool *pl,
-				int nr, gfp_t gfp_mask)
-{
-	__u32 limit;
-
-	/*
-	 * VM is asking how many entries may be potentially freed.
-	 */
-	if (nr == 0)
-		return atomic_read(&pl->pl_granted);
-
-	/*
-	 * Client already canceled locks but server is already in shrinker
-	 * and can't cancel anything. Let's catch this race.
-	 */
-	if (atomic_read(&pl->pl_granted) == 0)
-		return 0;
-
-	spin_lock(&pl->pl_lock);
-
-	/*
-	 * We want shrinker to possibly cause cancellation of @nr locks from
-	 * clients or grant approximately @nr locks smaller next intervals.
-	 *
-	 * This is why we decreased SLV by @nr. This effect will only be as
-	 * long as one re-calc interval (1s these days) and this should be
-	 * enough to pass this decreased SLV to all clients. On next recalc
-	 * interval pool will either increase SLV if locks load is not high
-	 * or will keep on same level or even decrease again, thus, shrinker
-	 * decreased SLV will affect next recalc intervals and this way will
-	 * make locking load lower.
-	 */
-	if (nr < pl->pl_server_lock_volume) {
-		pl->pl_server_lock_volume = pl->pl_server_lock_volume - nr;
-	} else {
-		limit = ldlm_pool_get_limit(pl);
-		pl->pl_server_lock_volume = ldlm_pool_slv_min(limit);
-	}
-
-	/*
-	 * Make sure that pool informed obd of last SLV changes.
-	 */
-	ldlm_srv_pool_push_slv(pl);
-	spin_unlock(&pl->pl_lock);
-
-	/*
-	 * We did not really free any memory here so far, it only will be
-	 * freed later may be, so that we return 0 to not confuse VM.
-	 */
-	return 0;
-}
-
-/**
- * Setup server side pool \a pl with passed \a limit.
- */
-static int ldlm_srv_pool_setup(struct ldlm_pool *pl, int limit)
-{
-	struct obd_device *obd;
-
-	obd = ldlm_pl2ns(pl)->ns_obd;
-	LASSERT(obd != NULL && obd != LP_POISON);
-	LASSERT(obd->obd_type != LP_POISON);
-	write_lock(&obd->obd_pool_lock);
-	obd->obd_pool_limit = limit;
-	write_unlock(&obd->obd_pool_lock);
-
-	ldlm_pool_set_limit(pl, limit);
-	return 0;
-}
-
-/**
  * Sets SLV and Limit from ldlm_pl2ns(pl)->ns_obd tp passed \a pl.
  */
 static void ldlm_cli_pool_pop_slv(struct ldlm_pool *pl)
@@ -554,12 +349,6 @@ static int ldlm_cli_pool_shrink(struct ldlm_pool *pl,
 		return ldlm_cancel_lru(ns, nr, LCF_ASYNC, LDLM_CANCEL_SHRINK);
 }
 
-static const struct ldlm_pool_ops ldlm_srv_pool_ops = {
-	.po_recalc = ldlm_srv_pool_recalc,
-	.po_shrink = ldlm_srv_pool_shrink,
-	.po_setup  = ldlm_srv_pool_setup
-};
-
 static const struct ldlm_pool_ops ldlm_cli_pool_ops = {
 	.po_recalc = ldlm_cli_pool_recalc,
 	.po_shrink = ldlm_cli_pool_shrink
@@ -640,20 +429,6 @@ int ldlm_pool_shrink(struct ldlm_pool *pl, int nr,
 }
 EXPORT_SYMBOL(ldlm_pool_shrink);
 
-/**
- * Pool setup wrapper. Will call either client or server pool recalc callback
- * depending what pool \a pl is used.
- *
- * Sets passed \a limit into pool \a pl.
- */
-int ldlm_pool_setup(struct ldlm_pool *pl, int limit)
-{
-	if (pl->pl_ops->po_setup != NULL)
-		return pl->pl_ops->po_setup(pl, limit);
-	return 0;
-}
-EXPORT_SYMBOL(ldlm_pool_setup);
-
 static int lprocfs_pool_state_seq_show(struct seq_file *m, void *unused)
 {
 	int granted, grant_rate, cancel_rate;
@@ -896,17 +671,10 @@ int ldlm_pool_init(struct ldlm_pool *pl, struct ldlm_namespace *ns,
 	snprintf(pl->pl_name, sizeof(pl->pl_name), "ldlm-pool-%s-%d",
 		 ldlm_ns_name(ns), idx);
 
-	if (client == LDLM_NAMESPACE_SERVER) {
-		pl->pl_ops = &ldlm_srv_pool_ops;
-		ldlm_pool_set_limit(pl, LDLM_POOL_HOST_L);
-		pl->pl_recalc_period = LDLM_POOL_SRV_DEF_RECALC_PERIOD;
-		pl->pl_server_lock_volume = ldlm_pool_slv_max(LDLM_POOL_HOST_L);
-	} else {
-		ldlm_pool_set_limit(pl, 1);
-		pl->pl_server_lock_volume = 0;
-		pl->pl_ops = &ldlm_cli_pool_ops;
-		pl->pl_recalc_period = LDLM_POOL_CLI_DEF_RECALC_PERIOD;
-	}
+	ldlm_pool_set_limit(pl, 1);
+	pl->pl_server_lock_volume = 0;
+	pl->pl_ops = &ldlm_cli_pool_ops;
+	pl->pl_recalc_period = LDLM_POOL_CLI_DEF_RECALC_PERIOD;
 	pl->pl_client_lock_volume = 0;
 	rc = ldlm_pool_debugfs_init(pl);
 	if (rc)
@@ -1148,20 +916,7 @@ static unsigned long ldlm_pools_scan(ldlm_side_t client, int nr, gfp_t gfp_mask)
 	 * we only decrease the SLV in server pools shrinker, return
 	 * SHRINK_STOP to kernel to avoid needless loop. LU-1128
 	 */
-	return (client == LDLM_NAMESPACE_SERVER) ? SHRINK_STOP : freed;
-}
-
-static unsigned long ldlm_pools_srv_count(struct shrinker *s,
-					  struct shrink_control *sc)
-{
-	return ldlm_pools_count(LDLM_NAMESPACE_SERVER, sc->gfp_mask);
-}
-
-static unsigned long ldlm_pools_srv_scan(struct shrinker *s,
-					 struct shrink_control *sc)
-{
-	return ldlm_pools_scan(LDLM_NAMESPACE_SERVER, sc->nr_to_scan,
-			       sc->gfp_mask);
+	return freed;
 }
 
 static unsigned long ldlm_pools_cli_count(struct shrinker *s,
@@ -1177,82 +932,14 @@ static unsigned long ldlm_pools_cli_scan(struct shrinker *s,
 			       sc->gfp_mask);
 }
 
-int ldlm_pools_recalc(ldlm_side_t client)
+static int ldlm_pools_recalc(ldlm_side_t client)
 {
-	__u32 nr_l = 0, nr_p = 0, l;
 	struct ldlm_namespace *ns;
 	struct ldlm_namespace *ns_old = NULL;
-	int nr, equal = 0;
+	int nr;
 	int time = 50; /* seconds of sleep if no active namespaces */
 
 	/*
-	 * No need to setup pool limit for client pools.
-	 */
-	if (client == LDLM_NAMESPACE_SERVER) {
-		/*
-		 * Check all modest namespaces first.
-		 */
-		mutex_lock(ldlm_namespace_lock(client));
-		list_for_each_entry(ns, ldlm_namespace_list(client),
-					ns_list_chain) {
-			if (ns->ns_appetite != LDLM_NAMESPACE_MODEST)
-				continue;
-
-			l = ldlm_pool_granted(&ns->ns_pool);
-			if (l == 0)
-				l = 1;
-
-			/*
-			 * Set the modest pools limit equal to their avg granted
-			 * locks + ~6%.
-			 */
-			l += dru(l, LDLM_POOLS_MODEST_MARGIN_SHIFT, 0);
-			ldlm_pool_setup(&ns->ns_pool, l);
-			nr_l += l;
-			nr_p++;
-		}
-
-		/*
-		 * Make sure that modest namespaces did not eat more that 2/3
-		 * of limit.
-		 */
-		if (nr_l >= 2 * (LDLM_POOL_HOST_L / 3)) {
-			CWARN("\"Modest\" pools eat out 2/3 of server locks limit (%d of %lu). This means that you have too many clients for this amount of server RAM. Upgrade server!\n",
-			      nr_l, LDLM_POOL_HOST_L);
-			equal = 1;
-		}
-
-		/*
-		 * The rest is given to greedy namespaces.
-		 */
-		list_for_each_entry(ns, ldlm_namespace_list(client),
-				    ns_list_chain) {
-			if (!equal && ns->ns_appetite != LDLM_NAMESPACE_GREEDY)
-				continue;
-
-			if (equal) {
-				/*
-				 * In the case 2/3 locks are eaten out by
-				 * modest pools, we re-setup equal limit
-				 * for _all_ pools.
-				 */
-				l = LDLM_POOL_HOST_L /
-					ldlm_namespace_nr_read(client);
-			} else {
-				/*
-				 * All the rest of greedy pools will have
-				 * all locks in equal parts.
-				 */
-				l = (LDLM_POOL_HOST_L - nr_l) /
-					(ldlm_namespace_nr_read(client) -
-					 nr_p);
-			}
-			ldlm_pool_setup(&ns->ns_pool, l);
-		}
-		mutex_unlock(ldlm_namespace_lock(client));
-	}
-
-	/*
 	 * Recalc at least ldlm_namespace_nr_read(client) namespaces.
 	 */
 	for (nr = ldlm_namespace_nr_read(client); nr > 0; nr--) {
@@ -1330,7 +1017,7 @@ EXPORT_SYMBOL(ldlm_pools_recalc);
 static int ldlm_pools_thread_main(void *arg)
 {
 	struct ptlrpc_thread *thread = (struct ptlrpc_thread *)arg;
-	int s_time, c_time;
+	int c_time;
 
 	thread_set_flags(thread, SVC_RUNNING);
 	wake_up(&thread->t_ctl_waitq);
@@ -1344,14 +1031,13 @@ static int ldlm_pools_thread_main(void *arg)
 		/*
 		 * Recal all pools on this tick.
 		 */
-		s_time = ldlm_pools_recalc(LDLM_NAMESPACE_SERVER);
 		c_time = ldlm_pools_recalc(LDLM_NAMESPACE_CLIENT);
 
 		/*
 		 * Wait until the next check time, or until we're
 		 * stopped.
 		 */
-		lwi = LWI_TIMEOUT(cfs_time_seconds(min(s_time, c_time)),
+		lwi = LWI_TIMEOUT(cfs_time_seconds(c_time),
 				  NULL, NULL);
 		l_wait_event(thread->t_ctl_waitq,
 			     thread_is_stopping(thread) ||
@@ -1418,12 +1104,6 @@ static void ldlm_pools_thread_stop(void)
 	ldlm_pools_thread = NULL;
 }
 
-static struct shrinker ldlm_pools_srv_shrinker = {
-	.count_objects	= ldlm_pools_srv_count,
-	.scan_objects	= ldlm_pools_srv_scan,
-	.seeks		= DEFAULT_SEEKS,
-};
-
 static struct shrinker ldlm_pools_cli_shrinker = {
 	.count_objects	= ldlm_pools_cli_count,
 	.scan_objects	= ldlm_pools_cli_scan,
@@ -1435,20 +1115,18 @@ int ldlm_pools_init(void)
 	int rc;
 
 	rc = ldlm_pools_thread_start();
-	if (rc == 0) {
-		register_shrinker(&ldlm_pools_srv_shrinker);
+	if (rc == 0)
 		register_shrinker(&ldlm_pools_cli_shrinker);
-	}
+
 	return rc;
 }
 EXPORT_SYMBOL(ldlm_pools_init);
 
 void ldlm_pools_fini(void)
 {
-	if (ldlm_pools_thread) {
-		unregister_shrinker(&ldlm_pools_srv_shrinker);
+	if (ldlm_pools_thread)
 		unregister_shrinker(&ldlm_pools_cli_shrinker);
-	}
+
 	ldlm_pools_thread_stop();
 }
 EXPORT_SYMBOL(ldlm_pools_fini);
-- 
2.1.0
