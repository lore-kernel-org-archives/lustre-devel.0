From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:13 -0400
Subject: [lustre-devel] [PATCH 34/42] lustre: ldlm: pool fixes
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-35-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vitaly Fertman <c17818@cray.com>

At the time the client side recalc period was increased up to 10secs
the grant & cancel rates started showing the speed not in seconds but
in tens of seconds.

At the pool initialization time, the server side recalc job should not
be delayed on client's recalc period.

It may happen an NS time is significant and comparable (or even more)
than the recalc period of the next NS (all the following NS's) in the
list. If the time has been already spent on the next NS, it does not
mean we want to double the delay for the original NS and recalc after
next N secs.

Make lock volume factor more fine grained (default is 100 now vs the
original 1): it is likely to cancel locks on clients twice faster than
server requested is too fast.

Protect missed pl_server_lock_volume update by the pool lock.

Replace ktime_get_real_seconds with ktime_get_seconds for the recal
interval.

HPE-bug-id: LUS-8678
WC-bug-id: https://jira.whamcloud.com/browse/LU-11518
Lustre-commit: 1806d6e8291758a ("LU-11518 ldlm: pool fixes")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Tested-by: Alexander Lezhoev <c17454@cray.com>
Reviewed-on: https://review.whamcloud.com/39563
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h |   4 +-
 fs/lustre/ldlm/ldlm_pool.c     | 129 +++++++++++++++++++++++++++--------------
 fs/lustre/ldlm/ldlm_request.c  |   2 +-
 3 files changed, 88 insertions(+), 47 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 682035a..bc6785f 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -250,8 +250,8 @@ struct ldlm_pool {
 	u64			pl_server_lock_volume;
 	/** Current biggest client lock volume. Protected by pl_lock. */
 	u64			pl_client_lock_volume;
-	/** Lock volume factor. SLV on client is calculated as following:
-	 *  server_slv * lock_volume_factor.
+	/** Lock volume factor, shown in percents in procfs, but internally
+	 *  Client SLV calculated as: server_slv * lock_volume_factor >> 8.
 	 */
 	atomic_t		pl_lock_volume_factor;
 	/** Time when last SLV from server was obtained. */
diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index 9e2a006..c37948a 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -209,13 +209,13 @@ static inline int ldlm_pool_t2gsp(unsigned int t)
  *
  * \pre ->pl_lock is locked.
  */
-static void ldlm_pool_recalc_stats(struct ldlm_pool *pl)
+static void ldlm_pool_recalc_stats(struct ldlm_pool *pl, timeout_t period)
 {
 	int grant_plan = pl->pl_grant_plan;
 	u64 slv = pl->pl_server_lock_volume;
 	int granted = atomic_read(&pl->pl_granted);
-	int grant_rate = atomic_read(&pl->pl_grant_rate);
-	int cancel_rate = atomic_read(&pl->pl_cancel_rate);
+	int grant_rate = atomic_read(&pl->pl_grant_rate) / period;
+	int cancel_rate = atomic_read(&pl->pl_cancel_rate) / period;
 
 	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_SLV_STAT,
 			    slv);
@@ -254,10 +254,10 @@ static void ldlm_cli_pool_pop_slv(struct ldlm_pool *pl)
  */
 static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
 {
-	time64_t recalc_interval_sec;
+	timeout_t recalc_interval_sec;
 	int ret;
 
-	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
+	recalc_interval_sec = ktime_get_seconds() - pl->pl_recalc_time;
 	if (recalc_interval_sec < pl->pl_recalc_period)
 		return 0;
 
@@ -265,7 +265,7 @@ static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
 	/*
 	 * Check if we need to recalc lists now.
 	 */
-	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
+	recalc_interval_sec = ktime_get_seconds() - pl->pl_recalc_time;
 	if (recalc_interval_sec < pl->pl_recalc_period) {
 		spin_unlock(&pl->pl_lock);
 		return 0;
@@ -292,7 +292,7 @@ static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
 	 * Time of LRU resizing might be longer than period,
 	 * so update after LRU resizing rather than before it.
 	 */
-	pl->pl_recalc_time = ktime_get_real_seconds();
+	pl->pl_recalc_time = ktime_get_seconds();
 	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_TIMING_STAT,
 			    recalc_interval_sec);
 	spin_unlock(&pl->pl_lock);
@@ -321,7 +321,9 @@ static int ldlm_cli_pool_shrink(struct ldlm_pool *pl,
 	/*
 	 * Make sure that pool knows last SLV and Limit from obd.
 	 */
+	spin_lock(&pl->pl_lock);
 	ldlm_cli_pool_pop_slv(pl);
+	spin_unlock(&pl->pl_lock);
 
 	spin_lock(&ns->ns_lock);
 	unused = ns->ns_nr_unused;
@@ -341,23 +343,25 @@ static int ldlm_cli_pool_shrink(struct ldlm_pool *pl,
 /**
  * Pool recalc wrapper. Will call either client or server pool recalc callback
  * depending what pool @pl is used.
+ *
+ * Returns	time in seconds for the next recalc of this pool
  */
-static int ldlm_pool_recalc(struct ldlm_pool *pl)
+static timeout_t ldlm_pool_recalc(struct ldlm_pool *pl)
 {
-	u32 recalc_interval_sec;
+	timeout_t recalc_interval_sec;
 	int count;
 
-	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
+	recalc_interval_sec = ktime_get_seconds() - pl->pl_recalc_time;
 	if (recalc_interval_sec > 0) {
 		spin_lock(&pl->pl_lock);
-		recalc_interval_sec = ktime_get_real_seconds() -
+		recalc_interval_sec = ktime_get_seconds() -
 				      pl->pl_recalc_time;
 
 		if (recalc_interval_sec > 0) {
 			/*
-			 * Update pool statistics every 1s.
+			 * Update pool statistics every recalc interval.
 			 */
-			ldlm_pool_recalc_stats(pl);
+			ldlm_pool_recalc_stats(pl, recalc_interval_sec);
 
 			/*
 			 * Zero out all rates and speed for the last period.
@@ -374,20 +378,7 @@ static int ldlm_pool_recalc(struct ldlm_pool *pl)
 				    count);
 	}
 
-	recalc_interval_sec = pl->pl_recalc_time - ktime_get_real_seconds() +
-			      pl->pl_recalc_period;
-	if (recalc_interval_sec <= 0) {
-		/* DEBUG: should be re-removed after LU-4536 is fixed */
-		CDEBUG(D_DLMTRACE,
-		       "%s: Negative interval(%ld), too short period(%ld)\n",
-		       pl->pl_name, (long)recalc_interval_sec,
-		       (long)pl->pl_recalc_period);
-
-		/* Prevent too frequent recalculation. */
-		recalc_interval_sec = 1;
-	}
-
-	return recalc_interval_sec;
+	return pl->pl_recalc_time + pl->pl_recalc_period;
 }
 
 /*
@@ -421,6 +412,7 @@ static int lprocfs_pool_state_seq_show(struct seq_file *m, void *unused)
 	int granted, grant_rate, cancel_rate;
 	int grant_speed, lvf;
 	struct ldlm_pool *pl = m->private;
+	timeout_t period;
 	u64 slv, clv;
 	u32 limit;
 
@@ -429,8 +421,11 @@ static int lprocfs_pool_state_seq_show(struct seq_file *m, void *unused)
 	clv = pl->pl_client_lock_volume;
 	limit = atomic_read(&pl->pl_limit);
 	granted = atomic_read(&pl->pl_granted);
-	grant_rate = atomic_read(&pl->pl_grant_rate);
-	cancel_rate = atomic_read(&pl->pl_cancel_rate);
+	period = ktime_get_seconds() - pl->pl_recalc_time;
+	if (period <= 0)
+		period = 1;
+	grant_rate = atomic_read(&pl->pl_grant_rate) / period;
+	cancel_rate = atomic_read(&pl->pl_cancel_rate) / period;
 	grant_speed = grant_rate - cancel_rate;
 	lvf = atomic_read(&pl->pl_lock_volume_factor);
 	spin_unlock(&pl->pl_lock);
@@ -439,7 +434,7 @@ static int lprocfs_pool_state_seq_show(struct seq_file *m, void *unused)
 		      "  SLV: %llu\n"
 		      "  CLV: %llu\n"
 		      "  LVF: %d\n",
-		      pl->pl_name, slv, clv, lvf);
+		      pl->pl_name, slv, clv, (lvf * 100) >> 8);
 
 	seq_printf(m, "  GR:  %d\n  CR:  %d\n  GS:  %d\n"
 		      "  G:   %d\n  L:   %d\n",
@@ -457,11 +452,15 @@ static ssize_t grant_speed_show(struct kobject *kobj, struct attribute *attr,
 	struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool,
 					    pl_kobj);
 	int grant_speed;
+	timeout_t period;
 
 	spin_lock(&pl->pl_lock);
 	/* serialize with ldlm_pool_recalc */
-	grant_speed = atomic_read(&pl->pl_grant_rate) -
-			atomic_read(&pl->pl_cancel_rate);
+	period = ktime_get_seconds() - pl->pl_recalc_time;
+	if (period <= 0)
+		period = 1;
+	grant_speed = (atomic_read(&pl->pl_grant_rate) -
+		       atomic_read(&pl->pl_cancel_rate)) / period;
 	spin_unlock(&pl->pl_lock);
 	return sprintf(buf, "%d\n", grant_speed);
 }
@@ -477,6 +476,9 @@ static ssize_t grant_speed_show(struct kobject *kobj, struct attribute *attr,
 LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(server_lock_volume, u64);
 LUSTRE_RO_ATTR(server_lock_volume);
 
+LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(client_lock_volume, u64);
+LUSTRE_RO_ATTR(client_lock_volume);
+
 LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(limit, atomic);
 LDLM_POOL_SYSFS_WRITER_NOLOCK_STORE(limit, atomic);
 LUSTRE_RW_ATTR(limit);
@@ -490,16 +492,56 @@ static ssize_t grant_speed_show(struct kobject *kobj, struct attribute *attr,
 LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(grant_rate, atomic);
 LUSTRE_RO_ATTR(grant_rate);
 
-LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(lock_volume_factor, atomic);
-LDLM_POOL_SYSFS_WRITER_NOLOCK_STORE(lock_volume_factor, atomic);
+static ssize_t lock_volume_factor_show(struct kobject *kobj,
+				       struct attribute *attr,
+				       char *buf)
+{
+	struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool, pl_kobj);
+	unsigned long tmp;
+
+	tmp = (atomic_read(&pl->pl_lock_volume_factor) * 100) >> 8;
+	return sprintf(buf, "%lu\n", tmp);
+}
+
+static ssize_t lock_volume_factor_store(struct kobject *kobj,
+					struct attribute *attr,
+					const char *buffer,
+					size_t count)
+{
+	struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool, pl_kobj);
+	unsigned long tmp;
+	int rc;
+
+	rc = kstrtoul(buffer, 10, &tmp);
+	if (rc < 0)
+		return rc;
+
+	tmp = (tmp << 8) / 100;
+	atomic_set(&pl->pl_lock_volume_factor, tmp);
+
+	return count;
+}
 LUSTRE_RW_ATTR(lock_volume_factor);
 
+static ssize_t recalc_time_show(struct kobject *kobj,
+				struct attribute *attr,
+				char *buf)
+{
+	struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool, pl_kobj);
+
+	return scnprintf(buf, PAGE_SIZE, "%llu\n",
+			ktime_get_seconds() - pl->pl_recalc_time);
+}
+LUSTRE_RO_ATTR(recalc_time);
+
 /* These are for pools in /sys/fs/lustre/ldlm/namespaces/.../pool */
 static struct attribute *ldlm_pl_attrs[] = {
 	&lustre_attr_grant_speed.attr,
 	&lustre_attr_grant_plan.attr,
 	&lustre_attr_recalc_period.attr,
 	&lustre_attr_server_lock_volume.attr,
+	&lustre_attr_client_lock_volume.attr,
+	&lustre_attr_recalc_time.attr,
 	&lustre_attr_limit.attr,
 	&lustre_attr_granted.attr,
 	&lustre_attr_cancel_rate.attr,
@@ -625,8 +667,8 @@ int ldlm_pool_init(struct ldlm_pool *pl, struct ldlm_namespace *ns,
 
 	spin_lock_init(&pl->pl_lock);
 	atomic_set(&pl->pl_granted, 0);
-	pl->pl_recalc_time = ktime_get_real_seconds();
-	atomic_set(&pl->pl_lock_volume_factor, 1);
+	pl->pl_recalc_time = ktime_get_seconds();
+	atomic_set(&pl->pl_lock_volume_factor, 1 << 8);
 
 	atomic_set(&pl->pl_grant_rate, 0);
 	atomic_set(&pl->pl_cancel_rate, 0);
@@ -867,7 +909,7 @@ static void ldlm_pools_recalc(struct work_struct *ws)
 	struct ldlm_namespace *ns;
 	struct ldlm_namespace *ns_old = NULL;
 	/* seconds of sleep if no active namespaces */
-	time64_t time = LDLM_POOL_CLI_DEF_RECALC_PERIOD;
+	timeout_t delay = LDLM_POOL_CLI_DEF_RECALC_PERIOD;
 	int nr;
 
 	/*
@@ -933,11 +975,8 @@ static void ldlm_pools_recalc(struct work_struct *ws)
 		 * After setup is done - recalc the pool.
 		 */
 		if (!skip) {
-			time64_t ttime = ldlm_pool_recalc(&ns->ns_pool);
-
-			if (ttime < time)
-				time = ttime;
-
+			delay = min(delay,
+				    ldlm_pool_recalc(&ns->ns_pool));
 			ldlm_namespace_put(ns);
 		}
 	}
@@ -945,12 +984,14 @@ static void ldlm_pools_recalc(struct work_struct *ws)
 	/* Wake up the blocking threads from time to time. */
 	ldlm_bl_thread_wakeup();
 
-	schedule_delayed_work(&ldlm_recalc_pools, time * HZ);
+	schedule_delayed_work(&ldlm_recalc_pools, delay * HZ);
 }
 
 static int ldlm_pools_thread_start(void)
 {
-	schedule_delayed_work(&ldlm_recalc_pools, 0);
+	time64_t delay = LDLM_POOL_CLI_DEF_RECALC_PERIOD;
+
+	schedule_delayed_work(&ldlm_recalc_pools, delay);
 
 	return 0;
 }
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index c235915..a8d6df1 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1388,7 +1388,7 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 	lvf = ldlm_pool_get_lvf(pl);
 	la = div_u64(ktime_to_ns(ktime_sub(cur, lock->l_last_used)),
 		     NSEC_PER_SEC);
-	lv = lvf * la * ns->ns_nr_unused;
+	lv = lvf * la * ns->ns_nr_unused >> 8;
 
 	/* Inform pool about current CLV to see it via debugfs. */
 	ldlm_pool_set_clv(pl, lv);
-- 
1.8.3.1
