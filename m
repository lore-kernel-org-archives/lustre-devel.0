From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:36 -0400
Subject: [lustre-devel] [PATCH v2 15/46] staging/lustre/obd: remove struct
	client_obd_lock
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-16-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

Remove the definition of struct client_obd_lock and the functions
client_obd_list_{init,lock,unlock,done}(). Use spinlock_t for the
cl_{loi,lru}_list_lock members of struct client_obd and call
spin_{lock,unlock}() directly.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/fld/fld_request.c    | 14 ++---
 drivers/staging/lustre/lustre/include/linux/obd.h  | 67 ----------------------
 drivers/staging/lustre/lustre/include/obd.h        |  9 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  4 +-
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |  8 +--
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        | 18 +++---
 drivers/staging/lustre/lustre/osc/lproc_osc.c      | 38 ++++++------
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 50 ++++++++--------
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  2 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       | 24 ++++----
 drivers/staging/lustre/lustre/osc/osc_request.c    | 46 +++++++--------
 11 files changed, 105 insertions(+), 175 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index a3d122d..2dfdb51 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -64,9 +64,9 @@ static int fld_req_avail(struct client_obd *cli, struct mdc_cache_waiter *mcw)
 {
 	int rc;
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	rc = list_empty(&mcw->mcw_entry);
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 	return rc;
 };
 
@@ -75,15 +75,15 @@ static void fld_enter_request(struct client_obd *cli)
 	struct mdc_cache_waiter mcw;
 	struct l_wait_info lwi = { 0 };
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	if (cli->cl_r_in_flight >= cli->cl_max_rpcs_in_flight) {
 		list_add_tail(&mcw.mcw_entry, &cli->cl_cache_waiters);
 		init_waitqueue_head(&mcw.mcw_waitq);
-		client_obd_list_unlock(&cli->cl_loi_list_lock);
+		spin_unlock(&cli->cl_loi_list_lock);
 		l_wait_event(mcw.mcw_waitq, fld_req_avail(cli, &mcw), &lwi);
 	} else {
 		cli->cl_r_in_flight++;
-		client_obd_list_unlock(&cli->cl_loi_list_lock);
+		spin_unlock(&cli->cl_loi_list_lock);
 	}
 }
 
@@ -92,7 +92,7 @@ static void fld_exit_request(struct client_obd *cli)
 	struct list_head *l, *tmp;
 	struct mdc_cache_waiter *mcw;
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	cli->cl_r_in_flight--;
 	list_for_each_safe(l, tmp, &cli->cl_cache_waiters) {
 
@@ -106,7 +106,7 @@ static void fld_exit_request(struct client_obd *cli)
 		cli->cl_r_in_flight++;
 		wake_up(&mcw->mcw_waitq);
 	}
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 }
 
 static int fld_rrb_hash(struct lu_client_fld *fld, u64 seq)
diff --git a/drivers/staging/lustre/lustre/include/linux/obd.h b/drivers/staging/lustre/lustre/include/linux/obd.h
index 3907bf4..e1063e8 100644
--- a/drivers/staging/lustre/lustre/include/linux/obd.h
+++ b/drivers/staging/lustre/lustre/include/linux/obd.h
@@ -55,71 +55,4 @@ struct ll_iattr {
 	unsigned int	ia_attr_flags;
 };
 
-#define CLIENT_OBD_LIST_LOCK_DEBUG 1
-
-struct client_obd_lock {
-	spinlock_t		lock;
-
-	unsigned long       time;
-	struct task_struct *task;
-	const char	 *func;
-	int		 line;
-};
-
-static inline void __client_obd_list_lock(struct client_obd_lock *lock,
-					  const char *func, int line)
-{
-	unsigned long cur = jiffies;
-
-	while (1) {
-		if (spin_trylock(&lock->lock)) {
-			LASSERT(!lock->task);
-			lock->task = current;
-			lock->func = func;
-			lock->line = line;
-			lock->time = jiffies;
-			break;
-		}
-
-		if (time_before(cur + 5 * HZ, jiffies) &&
-		    time_before(lock->time + 5 * HZ, jiffies)) {
-			struct task_struct *task = lock->task;
-
-			if (!task)
-				continue;
-
-			LCONSOLE_WARN("%s:%d: lock %p was acquired by <%s:%d:%s:%d> for %lu seconds.\n",
-				      current->comm, current->pid,
-				      lock, task->comm, task->pid,
-				      lock->func, lock->line,
-				      (jiffies - lock->time) / HZ);
-			LCONSOLE_WARN("====== for current process =====\n");
-			dump_stack();
-			LCONSOLE_WARN("====== end =======\n");
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			schedule_timeout(1000 * HZ);
-		}
-		cpu_relax();
-	}
-}
-
-#define client_obd_list_lock(lock) \
-	__client_obd_list_lock(lock, __func__, __LINE__)
-
-static inline void client_obd_list_unlock(struct client_obd_lock *lock)
-{
-	LASSERT(lock->task);
-	lock->task = NULL;
-	lock->time = jiffies;
-	spin_unlock(&lock->lock);
-}
-
-static inline void client_obd_list_lock_init(struct client_obd_lock *lock)
-{
-	spin_lock_init(&lock->lock);
-}
-
-static inline void client_obd_list_lock_done(struct client_obd_lock *lock)
-{}
-
 #endif /* __LINUX_OBD_H */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 15c514c..84cc001 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -37,6 +37,7 @@
 #ifndef __OBD_H
 #define __OBD_H
 
+#include <linux/spinlock.h>
 #include "linux/obd.h"
 
 #define IOC_OSC_TYPE	 'h'
@@ -293,14 +294,10 @@ struct client_obd {
 	 * blocking everywhere, but we don't want to slow down fast-path of
 	 * our main platform.)
 	 *
-	 * Exact type of ->cl_loi_list_lock is defined in arch/obd.h together
-	 * with client_obd_list_{un,}lock() and
-	 * client_obd_list_lock_{init,done}() functions.
-	 *
 	 * NB by Jinshan: though field names are still _loi_, but actually
 	 * osc_object{}s are in the list.
 	 */
-	struct client_obd_lock	       cl_loi_list_lock;
+	spinlock_t		       cl_loi_list_lock;
 	struct list_head	       cl_loi_ready_list;
 	struct list_head	       cl_loi_hp_ready_list;
 	struct list_head	       cl_loi_write_list;
@@ -327,7 +324,7 @@ struct client_obd {
 	atomic_t		 cl_lru_shrinkers;
 	atomic_t		 cl_lru_in_list;
 	struct list_head	 cl_lru_list; /* lru page list */
-	struct client_obd_lock   cl_lru_list_lock; /* page list protector */
+	spinlock_t		 cl_lru_list_lock; /* page list protector */
 
 	/* number of in flight destroy rpcs is limited to max_rpcs_in_flight */
 	atomic_t	     cl_destroy_in_flight;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index b586d5a..b497ce4 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -314,7 +314,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	INIT_LIST_HEAD(&cli->cl_loi_hp_ready_list);
 	INIT_LIST_HEAD(&cli->cl_loi_write_list);
 	INIT_LIST_HEAD(&cli->cl_loi_read_list);
-	client_obd_list_lock_init(&cli->cl_loi_list_lock);
+	spin_lock_init(&cli->cl_loi_list_lock);
 	atomic_set(&cli->cl_pending_w_pages, 0);
 	atomic_set(&cli->cl_pending_r_pages, 0);
 	cli->cl_r_in_flight = 0;
@@ -333,7 +333,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	atomic_set(&cli->cl_lru_busy, 0);
 	atomic_set(&cli->cl_lru_in_list, 0);
 	INIT_LIST_HEAD(&cli->cl_lru_list);
-	client_obd_list_lock_init(&cli->cl_lru_list_lock);
+	spin_lock_init(&cli->cl_lru_list_lock);
 
 	init_waitqueue_head(&cli->cl_destroy_waitq);
 	atomic_set(&cli->cl_destroy_in_flight, 0);
diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index 38f267a..5c7a15d 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -49,9 +49,9 @@ static ssize_t max_rpcs_in_flight_show(struct kobject *kobj,
 					      obd_kobj);
 	struct client_obd *cli = &dev->u.cli;
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	len = sprintf(buf, "%u\n", cli->cl_max_rpcs_in_flight);
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	return len;
 }
@@ -74,9 +74,9 @@ static ssize_t max_rpcs_in_flight_store(struct kobject *kobj,
 	if (val < 1 || val > MDC_MAX_RIF_MAX)
 		return -ERANGE;
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	cli->cl_max_rpcs_in_flight = val;
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	return count;
 }
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index b3bfdcb..bd29eb7 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -481,9 +481,9 @@ static int mdc_req_avail(struct client_obd *cli, struct mdc_cache_waiter *mcw)
 {
 	int rc;
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	rc = list_empty(&mcw->mcw_entry);
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 	return rc;
 };
 
@@ -497,23 +497,23 @@ int mdc_enter_request(struct client_obd *cli)
 	struct mdc_cache_waiter mcw;
 	struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	if (cli->cl_r_in_flight >= cli->cl_max_rpcs_in_flight) {
 		list_add_tail(&mcw.mcw_entry, &cli->cl_cache_waiters);
 		init_waitqueue_head(&mcw.mcw_waitq);
-		client_obd_list_unlock(&cli->cl_loi_list_lock);
+		spin_unlock(&cli->cl_loi_list_lock);
 		rc = l_wait_event(mcw.mcw_waitq, mdc_req_avail(cli, &mcw),
 				  &lwi);
 		if (rc) {
-			client_obd_list_lock(&cli->cl_loi_list_lock);
+			spin_lock(&cli->cl_loi_list_lock);
 			if (list_empty(&mcw.mcw_entry))
 				cli->cl_r_in_flight--;
 			list_del_init(&mcw.mcw_entry);
-			client_obd_list_unlock(&cli->cl_loi_list_lock);
+			spin_unlock(&cli->cl_loi_list_lock);
 		}
 	} else {
 		cli->cl_r_in_flight++;
-		client_obd_list_unlock(&cli->cl_loi_list_lock);
+		spin_unlock(&cli->cl_loi_list_lock);
 	}
 	return rc;
 }
@@ -523,7 +523,7 @@ void mdc_exit_request(struct client_obd *cli)
 	struct list_head *l, *tmp;
 	struct mdc_cache_waiter *mcw;
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	cli->cl_r_in_flight--;
 	list_for_each_safe(l, tmp, &cli->cl_cache_waiters) {
 		if (cli->cl_r_in_flight >= cli->cl_max_rpcs_in_flight) {
@@ -538,5 +538,5 @@ void mdc_exit_request(struct client_obd *cli)
 	}
 	/* Empty waiting list? Decrease reqs in-flight number */
 
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 }
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index e6e2029..911e505 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -121,9 +121,9 @@ static ssize_t max_rpcs_in_flight_store(struct kobject *kobj,
 		atomic_add(added, &osc_pool_req_count);
 	}
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	cli->cl_max_rpcs_in_flight = val;
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	return count;
 }
@@ -139,9 +139,9 @@ static ssize_t max_dirty_mb_show(struct kobject *kobj,
 	long val;
 	int mult;
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	val = cli->cl_dirty_max;
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	mult = 1 << 20;
 	return lprocfs_read_frac_helper(buf, PAGE_SIZE, val, mult);
@@ -169,10 +169,10 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj,
 	    pages_number > totalram_pages / 4) /* 1/4 of RAM */
 		return -ERANGE;
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	cli->cl_dirty_max = (u32)(pages_number << PAGE_CACHE_SHIFT);
 	osc_wake_cache_waiters(cli);
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	return count;
 }
@@ -247,9 +247,9 @@ static ssize_t cur_dirty_bytes_show(struct kobject *kobj,
 	struct client_obd *cli = &dev->u.cli;
 	int len;
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	len = sprintf(buf, "%lu\n", cli->cl_dirty);
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	return len;
 }
@@ -264,9 +264,9 @@ static ssize_t cur_grant_bytes_show(struct kobject *kobj,
 	struct client_obd *cli = &dev->u.cli;
 	int len;
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	len = sprintf(buf, "%lu\n", cli->cl_avail_grant);
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	return len;
 }
@@ -287,12 +287,12 @@ static ssize_t cur_grant_bytes_store(struct kobject *kobj,
 		return rc;
 
 	/* this is only for shrinking grant */
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	if (val >= cli->cl_avail_grant) {
-		client_obd_list_unlock(&cli->cl_loi_list_lock);
+		spin_unlock(&cli->cl_loi_list_lock);
 		return -EINVAL;
 	}
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	if (cli->cl_import->imp_state == LUSTRE_IMP_FULL)
 		rc = osc_shrink_grant_to_target(cli, val);
@@ -311,9 +311,9 @@ static ssize_t cur_lost_grant_bytes_show(struct kobject *kobj,
 	struct client_obd *cli = &dev->u.cli;
 	int len;
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	len = sprintf(buf, "%lu\n", cli->cl_lost_grant);
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	return len;
 }
@@ -585,9 +585,9 @@ static ssize_t max_pages_per_rpc_store(struct kobject *kobj,
 	if (val == 0 || val > ocd->ocd_brw_size >> PAGE_CACHE_SHIFT) {
 		return -ERANGE;
 	}
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	cli->cl_max_pages_per_rpc = val;
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	return count;
 }
@@ -631,7 +631,7 @@ static int osc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 
 	ktime_get_real_ts64(&now);
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 
 	seq_printf(seq, "snapshot_time:	 %llu.%9lu (secs.usecs)\n",
 		   (s64)now.tv_sec, (unsigned long)now.tv_nsec);
@@ -715,7 +715,7 @@ static int osc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 			break;
 	}
 
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 74607933..c510659 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1373,7 +1373,7 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 static void osc_consume_write_grant(struct client_obd *cli,
 				    struct brw_page *pga)
 {
-	assert_spin_locked(&cli->cl_loi_list_lock.lock);
+	assert_spin_locked(&cli->cl_loi_list_lock);
 	LASSERT(!(pga->flag & OBD_BRW_FROM_GRANT));
 	atomic_inc(&obd_dirty_pages);
 	cli->cl_dirty += PAGE_CACHE_SIZE;
@@ -1389,7 +1389,7 @@ static void osc_consume_write_grant(struct client_obd *cli,
 static void osc_release_write_grant(struct client_obd *cli,
 				    struct brw_page *pga)
 {
-	assert_spin_locked(&cli->cl_loi_list_lock.lock);
+	assert_spin_locked(&cli->cl_loi_list_lock);
 	if (!(pga->flag & OBD_BRW_FROM_GRANT)) {
 		return;
 	}
@@ -1408,7 +1408,7 @@ static void osc_release_write_grant(struct client_obd *cli,
  * To avoid sleeping with object lock held, it's good for us allocate enough
  * grants before entering into critical section.
  *
- * client_obd_list_lock held by caller
+ * spin_lock held by caller
  */
 static int osc_reserve_grant(struct client_obd *cli, unsigned int bytes)
 {
@@ -1442,11 +1442,11 @@ static void __osc_unreserve_grant(struct client_obd *cli,
 static void osc_unreserve_grant(struct client_obd *cli,
 				unsigned int reserved, unsigned int unused)
 {
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	__osc_unreserve_grant(cli, reserved, unused);
 	if (unused > 0)
 		osc_wake_cache_waiters(cli);
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 }
 
 /**
@@ -1467,7 +1467,7 @@ static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
 {
 	int grant = (1 << cli->cl_chunkbits) + cli->cl_extent_tax;
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	atomic_sub(nr_pages, &obd_dirty_pages);
 	cli->cl_dirty -= nr_pages << PAGE_CACHE_SHIFT;
 	cli->cl_lost_grant += lost_grant;
@@ -1479,7 +1479,7 @@ static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
 		cli->cl_avail_grant += grant;
 	}
 	osc_wake_cache_waiters(cli);
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 	CDEBUG(D_CACHE, "lost %u grant: %lu avail: %lu dirty: %lu\n",
 	       lost_grant, cli->cl_lost_grant,
 	       cli->cl_avail_grant, cli->cl_dirty);
@@ -1491,9 +1491,9 @@ static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
  */
 static void osc_exit_cache(struct client_obd *cli, struct osc_async_page *oap)
 {
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	osc_release_write_grant(cli, &oap->oap_brw_page);
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 }
 
 /**
@@ -1532,9 +1532,9 @@ static int ocw_granted(struct client_obd *cli, struct osc_cache_waiter *ocw)
 {
 	int rc;
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	rc = list_empty(&ocw->ocw_entry);
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 	return rc;
 }
 
@@ -1556,7 +1556,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 
 	OSC_DUMP_GRANT(cli, "need:%d.\n", bytes);
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 
 	/* force the caller to try sync io.  this can jump the list
 	 * of queued writes and create a discontiguous rpc stream
@@ -1587,7 +1587,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	while (cli->cl_dirty > 0 || cli->cl_w_in_flight > 0) {
 		list_add_tail(&ocw.ocw_entry, &cli->cl_cache_waiters);
 		ocw.ocw_rc = 0;
-		client_obd_list_unlock(&cli->cl_loi_list_lock);
+		spin_unlock(&cli->cl_loi_list_lock);
 
 		osc_io_unplug_async(env, cli, NULL);
 
@@ -1596,7 +1596,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 
 		rc = l_wait_event(ocw.ocw_waitq, ocw_granted(cli, &ocw), &lwi);
 
-		client_obd_list_lock(&cli->cl_loi_list_lock);
+		spin_lock(&cli->cl_loi_list_lock);
 
 		/* l_wait_event is interrupted by signal */
 		if (rc < 0) {
@@ -1615,7 +1615,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 		}
 	}
 out:
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 	OSC_DUMP_GRANT(cli, "returned %d.\n", rc);
 	return rc;
 }
@@ -1776,9 +1776,9 @@ static int osc_list_maint(struct client_obd *cli, struct osc_object *osc)
 {
 	int is_ready;
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	is_ready = __osc_list_maint(cli, osc);
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	return is_ready;
 }
@@ -1829,10 +1829,10 @@ static void osc_ap_completion(const struct lu_env *env, struct client_obd *cli,
 	oap->oap_interrupted = 0;
 
 	if (oap->oap_cmd & OBD_BRW_WRITE && xid > 0) {
-		client_obd_list_lock(&cli->cl_loi_list_lock);
+		spin_lock(&cli->cl_loi_list_lock);
 		osc_process_ar(&cli->cl_ar, xid, rc);
 		osc_process_ar(&loi->loi_ar, xid, rc);
-		client_obd_list_unlock(&cli->cl_loi_list_lock);
+		spin_unlock(&cli->cl_loi_list_lock);
 	}
 
 	rc = osc_completion(env, oap, oap->oap_cmd, rc);
@@ -2133,7 +2133,7 @@ static void osc_check_rpcs(const struct lu_env *env, struct client_obd *cli)
 		}
 
 		cl_object_get(obj);
-		client_obd_list_unlock(&cli->cl_loi_list_lock);
+		spin_unlock(&cli->cl_loi_list_lock);
 		lu_object_ref_add_at(&obj->co_lu, &link, "check", current);
 
 		/* attempt some read/write balancing by alternating between
@@ -2180,7 +2180,7 @@ static void osc_check_rpcs(const struct lu_env *env, struct client_obd *cli)
 		lu_object_ref_del_at(&obj->co_lu, &link, "check", current);
 		cl_object_put(env, obj);
 
-		client_obd_list_lock(&cli->cl_loi_list_lock);
+		spin_lock(&cli->cl_loi_list_lock);
 	}
 }
 
@@ -2197,9 +2197,9 @@ static int osc_io_unplug0(const struct lu_env *env, struct client_obd *cli,
 		 * potential stack overrun problem. LU-2859
 		 */
 		atomic_inc(&cli->cl_lru_shrinkers);
-		client_obd_list_lock(&cli->cl_loi_list_lock);
+		spin_lock(&cli->cl_loi_list_lock);
 		osc_check_rpcs(env, cli);
-		client_obd_list_unlock(&cli->cl_loi_list_lock);
+		spin_unlock(&cli->cl_loi_list_lock);
 		atomic_dec(&cli->cl_lru_shrinkers);
 	} else {
 		CDEBUG(D_CACHE, "Queue writeback work for client %p.\n", cli);
@@ -2332,9 +2332,9 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 			grants = 0;
 
 		/* it doesn't need any grant to dirty this page */
-		client_obd_list_lock(&cli->cl_loi_list_lock);
+		spin_lock(&cli->cl_loi_list_lock);
 		rc = osc_enter_cache_try(cli, oap, grants, 0);
-		client_obd_list_unlock(&cli->cl_loi_list_lock);
+		spin_unlock(&cli->cl_loi_list_lock);
 		if (rc == 0) { /* try failed */
 			grants = 0;
 			need_release = 1;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 89552d7..bb34b53a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -608,7 +608,7 @@ enum osc_extent_state {
  *
  * LOCKING ORDER
  * =============
- * page lock -> client_obd_list_lock -> object lock(osc_object::oo_lock)
+ * page lock -> cl_loi_list_lock -> object lock(osc_object::oo_lock)
  */
 struct osc_extent {
 	/** red-black tree node */
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index e02dd33..5b31351 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -456,11 +456,11 @@ void osc_lru_add_batch(struct client_obd *cli, struct list_head *plist)
 	}
 
 	if (npages > 0) {
-		client_obd_list_lock(&cli->cl_lru_list_lock);
+		spin_lock(&cli->cl_lru_list_lock);
 		list_splice_tail(&lru, &cli->cl_lru_list);
 		atomic_sub(npages, &cli->cl_lru_busy);
 		atomic_add(npages, &cli->cl_lru_in_list);
-		client_obd_list_unlock(&cli->cl_lru_list_lock);
+		spin_unlock(&cli->cl_lru_list_lock);
 
 		/* XXX: May set force to be true for better performance */
 		if (osc_cache_too_much(cli))
@@ -482,14 +482,14 @@ static void __osc_lru_del(struct client_obd *cli, struct osc_page *opg)
 static void osc_lru_del(struct client_obd *cli, struct osc_page *opg)
 {
 	if (opg->ops_in_lru) {
-		client_obd_list_lock(&cli->cl_lru_list_lock);
+		spin_lock(&cli->cl_lru_list_lock);
 		if (!list_empty(&opg->ops_lru)) {
 			__osc_lru_del(cli, opg);
 		} else {
 			LASSERT(atomic_read(&cli->cl_lru_busy) > 0);
 			atomic_dec(&cli->cl_lru_busy);
 		}
-		client_obd_list_unlock(&cli->cl_lru_list_lock);
+		spin_unlock(&cli->cl_lru_list_lock);
 
 		atomic_inc(cli->cl_lru_left);
 		/* this is a great place to release more LRU pages if
@@ -513,9 +513,9 @@ static void osc_lru_use(struct client_obd *cli, struct osc_page *opg)
 	 * ops_lru should be empty
 	 */
 	if (opg->ops_in_lru && !list_empty(&opg->ops_lru)) {
-		client_obd_list_lock(&cli->cl_lru_list_lock);
+		spin_lock(&cli->cl_lru_list_lock);
 		__osc_lru_del(cli, opg);
-		client_obd_list_unlock(&cli->cl_lru_list_lock);
+		spin_unlock(&cli->cl_lru_list_lock);
 		atomic_inc(&cli->cl_lru_busy);
 	}
 }
@@ -572,7 +572,7 @@ int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 	pvec = (struct cl_page **)osc_env_info(env)->oti_pvec;
 	io = &osc_env_info(env)->oti_io;
 
-	client_obd_list_lock(&cli->cl_lru_list_lock);
+	spin_lock(&cli->cl_lru_list_lock);
 	maxscan = min(target << 1, atomic_read(&cli->cl_lru_in_list));
 	list_for_each_entry_safe(opg, temp, &cli->cl_lru_list, ops_lru) {
 		struct cl_page *page;
@@ -592,7 +592,7 @@ int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 			struct cl_object *tmp = page->cp_obj;
 
 			cl_object_get(tmp);
-			client_obd_list_unlock(&cli->cl_lru_list_lock);
+			spin_unlock(&cli->cl_lru_list_lock);
 
 			if (clobj) {
 				discard_pagevec(env, io, pvec, index);
@@ -608,7 +608,7 @@ int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 			io->ci_ignore_layout = 1;
 			rc = cl_io_init(env, io, CIT_MISC, clobj);
 
-			client_obd_list_lock(&cli->cl_lru_list_lock);
+			spin_lock(&cli->cl_lru_list_lock);
 
 			if (rc != 0)
 				break;
@@ -640,17 +640,17 @@ int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 		/* Don't discard and free the page with cl_lru_list held */
 		pvec[index++] = page;
 		if (unlikely(index == OTI_PVEC_SIZE)) {
-			client_obd_list_unlock(&cli->cl_lru_list_lock);
+			spin_unlock(&cli->cl_lru_list_lock);
 			discard_pagevec(env, io, pvec, index);
 			index = 0;
 
-			client_obd_list_lock(&cli->cl_lru_list_lock);
+			spin_lock(&cli->cl_lru_list_lock);
 		}
 
 		if (++count >= target)
 			break;
 	}
-	client_obd_list_unlock(&cli->cl_lru_list_lock);
+	spin_unlock(&cli->cl_lru_list_lock);
 
 	if (clobj) {
 		discard_pagevec(env, io, pvec, index);
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 1e378e6..372bd26 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -801,7 +801,7 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 	LASSERT(!(oa->o_valid & bits));
 
 	oa->o_valid |= bits;
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	oa->o_dirty = cli->cl_dirty;
 	if (unlikely(cli->cl_dirty - cli->cl_dirty_transit >
 		     cli->cl_dirty_max)) {
@@ -833,7 +833,7 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 	oa->o_grant = cli->cl_avail_grant + cli->cl_reserved_grant;
 	oa->o_dropped = cli->cl_lost_grant;
 	cli->cl_lost_grant = 0;
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 	CDEBUG(D_CACHE, "dirty: %llu undirty: %u dropped %u grant: %llu\n",
 	       oa->o_dirty, oa->o_undirty, oa->o_dropped, oa->o_grant);
 
@@ -849,9 +849,9 @@ void osc_update_next_shrink(struct client_obd *cli)
 
 static void __osc_update_grant(struct client_obd *cli, u64 grant)
 {
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	cli->cl_avail_grant += grant;
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 }
 
 static void osc_update_grant(struct client_obd *cli, struct ost_body *body)
@@ -889,10 +889,10 @@ out:
 
 static void osc_shrink_grant_local(struct client_obd *cli, struct obdo *oa)
 {
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	oa->o_grant = cli->cl_avail_grant / 4;
 	cli->cl_avail_grant -= oa->o_grant;
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 	if (!(oa->o_valid & OBD_MD_FLFLAGS)) {
 		oa->o_valid |= OBD_MD_FLFLAGS;
 		oa->o_flags = 0;
@@ -911,10 +911,10 @@ static int osc_shrink_grant(struct client_obd *cli)
 	__u64 target_bytes = (cli->cl_max_rpcs_in_flight + 1) *
 			     (cli->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT);
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	if (cli->cl_avail_grant <= target_bytes)
 		target_bytes = cli->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT;
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	return osc_shrink_grant_to_target(cli, target_bytes);
 }
@@ -924,7 +924,7 @@ int osc_shrink_grant_to_target(struct client_obd *cli, __u64 target_bytes)
 	int rc = 0;
 	struct ost_body	*body;
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	/* Don't shrink if we are already above or below the desired limit
 	 * We don't want to shrink below a single RPC, as that will negatively
 	 * impact block allocation and long-term performance.
@@ -933,10 +933,10 @@ int osc_shrink_grant_to_target(struct client_obd *cli, __u64 target_bytes)
 		target_bytes = cli->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT;
 
 	if (target_bytes >= cli->cl_avail_grant) {
-		client_obd_list_unlock(&cli->cl_loi_list_lock);
+		spin_unlock(&cli->cl_loi_list_lock);
 		return 0;
 	}
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	body = kzalloc(sizeof(*body), GFP_NOFS);
 	if (!body)
@@ -944,10 +944,10 @@ int osc_shrink_grant_to_target(struct client_obd *cli, __u64 target_bytes)
 
 	osc_announce_cached(cli, &body->oa, 0);
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	body->oa.o_grant = cli->cl_avail_grant - target_bytes;
 	cli->cl_avail_grant = target_bytes;
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 	if (!(body->oa.o_valid & OBD_MD_FLFLAGS)) {
 		body->oa.o_valid |= OBD_MD_FLFLAGS;
 		body->oa.o_flags = 0;
@@ -1035,7 +1035,7 @@ static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 	 * race is tolerable here: if we're evicted, but imp_state already
 	 * left EVICTED state, then cl_dirty must be 0 already.
 	 */
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	if (cli->cl_import->imp_state == LUSTRE_IMP_EVICTED)
 		cli->cl_avail_grant = ocd->ocd_grant;
 	else
@@ -1053,7 +1053,7 @@ static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 
 	/* determine the appropriate chunk size used by osc_extent. */
 	cli->cl_chunkbits = max_t(int, PAGE_CACHE_SHIFT, ocd->ocd_blocksize);
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	CDEBUG(D_CACHE, "%s, setting cl_avail_grant: %ld cl_lost_grant: %ld chunk bits: %d\n",
 	       cli->cl_import->imp_obd->obd_name,
@@ -1827,7 +1827,7 @@ static int brw_interpret(const struct lu_env *env,
 	osc_release_ppga(aa->aa_ppga, aa->aa_page_count);
 	ptlrpc_lprocfs_brw(req, req->rq_bulk->bd_nob_transferred);
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	/* We need to decrement before osc_ap_completion->osc_wake_cache_waiters
 	 * is called so we know whether to go to sync BRWs or wait for more
 	 * RPCs to complete
@@ -1837,7 +1837,7 @@ static int brw_interpret(const struct lu_env *env,
 	else
 		cli->cl_r_in_flight--;
 	osc_wake_cache_waiters(cli);
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	osc_io_unplug(env, cli, NULL);
 	return rc;
@@ -2005,7 +2005,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	if (tmp)
 		tmp->oap_request = ptlrpc_request_addref(req);
 
-	client_obd_list_lock(&cli->cl_loi_list_lock);
+	spin_lock(&cli->cl_loi_list_lock);
 	starting_offset >>= PAGE_CACHE_SHIFT;
 	if (cmd == OBD_BRW_READ) {
 		cli->cl_r_in_flight++;
@@ -2020,7 +2020,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		lprocfs_oh_tally_log2(&cli->cl_write_offset_hist,
 				      starting_offset + 1);
 	}
-	client_obd_list_unlock(&cli->cl_loi_list_lock);
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	DEBUG_REQ(D_INODE, req, "%d pages, aa %p. now %dr/%dw in flight",
 		  page_count, aa, cli->cl_r_in_flight,
@@ -3005,12 +3005,12 @@ static int osc_reconnect(const struct lu_env *env,
 	if (data && (data->ocd_connect_flags & OBD_CONNECT_GRANT)) {
 		long lost_grant;
 
-		client_obd_list_lock(&cli->cl_loi_list_lock);
+		spin_lock(&cli->cl_loi_list_lock);
 		data->ocd_grant = (cli->cl_avail_grant + cli->cl_dirty) ?:
 				2 * cli_brw_size(obd);
 		lost_grant = cli->cl_lost_grant;
 		cli->cl_lost_grant = 0;
-		client_obd_list_unlock(&cli->cl_loi_list_lock);
+		spin_unlock(&cli->cl_loi_list_lock);
 
 		CDEBUG(D_RPCTRACE, "ocd_connect_flags: %#llx ocd_version: %d ocd_grant: %d, lost: %ld.\n",
 		       data->ocd_connect_flags,
@@ -3060,10 +3060,10 @@ static int osc_import_event(struct obd_device *obd,
 	switch (event) {
 	case IMP_EVENT_DISCON: {
 		cli = &obd->u.cli;
-		client_obd_list_lock(&cli->cl_loi_list_lock);
+		spin_lock(&cli->cl_loi_list_lock);
 		cli->cl_avail_grant = 0;
 		cli->cl_lost_grant = 0;
-		client_obd_list_unlock(&cli->cl_loi_list_lock);
+		spin_unlock(&cli->cl_loi_list_lock);
 		break;
 	}
 	case IMP_EVENT_INACTIVE: {
-- 
2.1.0
