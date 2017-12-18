From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 12:25:19 +1100
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: libcfs: use a workqueue
 for rehash work.
In-Reply-To: <151356013394.15912.9645528414310488005.stgit@noble>
References: <151356013394.15912.9645528414310488005.stgit@noble>
Message-ID: <151356031911.15912.4212899869566992358.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

lustre has a work-item queuing scheme that provides the
same functionality as linux work_queues.
To make the code easier for linux devs to follow, change
to use work_queues.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    2 
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    6 +
 drivers/staging/lustre/lnet/libcfs/hash.c          |   82 +++++---------------
 drivers/staging/lustre/lnet/libcfs/module.c        |   16 ++--
 4 files changed, 31 insertions(+), 75 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 6ad8867e5451..dcdc05dde6b8 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -126,7 +126,7 @@ extern struct miscdevice libcfs_dev;
  */
 extern char lnet_debug_log_upcall[1024];
 
-extern struct cfs_wi_sched *cfs_sched_rehash;
+extern struct workqueue_struct *cfs_rehash_wq;
 
 struct lnet_debugfs_symlink_def {
 	char *name;
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 5a27220cc608..0506f1d45757 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -248,7 +248,7 @@ struct cfs_hash {
 	/** # of iterators (caller of cfs_hash_for_each_*) */
 	u32				hs_iterators;
 	/** rehash workitem */
-	struct cfs_workitem		hs_rehash_wi;
+	struct work_struct		hs_rehash_work;
 	/** refcount on this hash table */
 	atomic_t			hs_refcount;
 	/** rehash buckets-table */
@@ -265,7 +265,7 @@ struct cfs_hash {
 	/** bits when we found the max depth */
 	unsigned int			hs_dep_bits;
 	/** workitem to output max depth */
-	struct cfs_workitem		hs_dep_wi;
+	struct work_struct		hs_dep_work;
 #endif
 	/** name of htable */
 	char				hs_name[0];
@@ -738,7 +738,7 @@ u64 cfs_hash_size_get(struct cfs_hash *hs);
  */
 void cfs_hash_rehash_cancel_locked(struct cfs_hash *hs);
 void cfs_hash_rehash_cancel(struct cfs_hash *hs);
-int  cfs_hash_rehash(struct cfs_hash *hs, int do_rehash);
+void cfs_hash_rehash(struct cfs_hash *hs, int do_rehash);
 void cfs_hash_rehash_key(struct cfs_hash *hs, const void *old_key,
 			 void *new_key, struct hlist_node *hnode);
 
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index aabe29eef85c..f7b3c9306456 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -114,7 +114,7 @@ module_param(warn_on_depth, uint, 0644);
 MODULE_PARM_DESC(warn_on_depth, "warning when hash depth is high.");
 #endif
 
-struct cfs_wi_sched *cfs_sched_rehash;
+struct workqueue_struct *cfs_rehash_wq;
 
 static inline void
 cfs_hash_nl_lock(union cfs_hash_lock *lock, int exclusive) {}
@@ -519,7 +519,7 @@ cfs_hash_bd_dep_record(struct cfs_hash *hs, struct cfs_hash_bd *bd, int dep_cur)
 	hs->hs_dep_bits = hs->hs_cur_bits;
 	spin_unlock(&hs->hs_dep_lock);
 
-	cfs_wi_schedule(cfs_sched_rehash, &hs->hs_dep_wi);
+	queue_work(cfs_rehash_wq, &hs->hs_dep_work);
 # endif
 }
 
@@ -937,12 +937,12 @@ cfs_hash_buckets_realloc(struct cfs_hash *hs, struct cfs_hash_bucket **old_bkts,
  * @flags    - CFS_HASH_REHASH enable synamic hash resizing
  *	     - CFS_HASH_SORT enable chained hash sort
  */
-static int cfs_hash_rehash_worker(struct cfs_workitem *wi);
+static void cfs_hash_rehash_worker(struct work_struct *work);
 
 #if CFS_HASH_DEBUG_LEVEL >= CFS_HASH_DEBUG_1
-static int cfs_hash_dep_print(struct cfs_workitem *wi)
+static void cfs_hash_dep_print(struct work_struct *work)
 {
-	struct cfs_hash *hs = container_of(wi, struct cfs_hash, hs_dep_wi);
+	struct cfs_hash *hs = container_of(work, struct cfs_hash, hs_dep_work);
 	int dep;
 	int bkt;
 	int off;
@@ -966,21 +966,12 @@ static int cfs_hash_dep_print(struct cfs_workitem *wi)
 static void cfs_hash_depth_wi_init(struct cfs_hash *hs)
 {
 	spin_lock_init(&hs->hs_dep_lock);
-	cfs_wi_init(&hs->hs_dep_wi, hs, cfs_hash_dep_print);
+	INIT_WORK(&hs->hs_dep_work, cfs_hash_dep_print);
 }
 
 static void cfs_hash_depth_wi_cancel(struct cfs_hash *hs)
 {
-	if (cfs_wi_deschedule(cfs_sched_rehash, &hs->hs_dep_wi))
-		return;
-
-	spin_lock(&hs->hs_dep_lock);
-	while (hs->hs_dep_bits) {
-		spin_unlock(&hs->hs_dep_lock);
-		cond_resched();
-		spin_lock(&hs->hs_dep_lock);
-	}
-	spin_unlock(&hs->hs_dep_lock);
+	cancel_work_sync(&hs->hs_dep_work);
 }
 
 #else /* CFS_HASH_DEBUG_LEVEL < CFS_HASH_DEBUG_1 */
@@ -1042,7 +1033,7 @@ cfs_hash_create(char *name, unsigned int cur_bits, unsigned int max_bits,
 	hs->hs_ops = ops;
 	hs->hs_extra_bytes = extra_bytes;
 	hs->hs_rehash_bits = 0;
-	cfs_wi_init(&hs->hs_rehash_wi, hs, cfs_hash_rehash_worker);
+	INIT_WORK(&hs->hs_rehash_work, cfs_hash_rehash_worker);
 	cfs_hash_depth_wi_init(hs);
 
 	if (cfs_hash_with_rehash(hs))
@@ -1362,6 +1353,7 @@ cfs_hash_for_each_enter(struct cfs_hash *hs)
 
 	cfs_hash_lock(hs, 1);
 	hs->hs_iterators++;
+	cfs_hash_unlock(hs, 1);
 
 	/* NB: iteration is mostly called by service thread,
 	 * we tend to cancel pending rehash-request, instead of
@@ -1369,8 +1361,7 @@ cfs_hash_for_each_enter(struct cfs_hash *hs)
 	 * after iteration
 	 */
 	if (cfs_hash_is_rehashing(hs))
-		cfs_hash_rehash_cancel_locked(hs);
-	cfs_hash_unlock(hs, 1);
+		cfs_hash_rehash_cancel(hs);
 }
 
 static void
@@ -1771,43 +1762,14 @@ EXPORT_SYMBOL(cfs_hash_for_each_key);
  * this approach assumes a reasonably uniform hashing function.  The
  * theta thresholds for @hs are tunable via cfs_hash_set_theta().
  */
-void
-cfs_hash_rehash_cancel_locked(struct cfs_hash *hs)
-{
-	int i;
-
-	/* need hold cfs_hash_lock(hs, 1) */
-	LASSERT(cfs_hash_with_rehash(hs) &&
-		!cfs_hash_with_no_lock(hs));
-
-	if (!cfs_hash_is_rehashing(hs))
-		return;
-
-	if (cfs_wi_deschedule(cfs_sched_rehash, &hs->hs_rehash_wi)) {
-		hs->hs_rehash_bits = 0;
-		return;
-	}
-
-	for (i = 2; cfs_hash_is_rehashing(hs); i++) {
-		cfs_hash_unlock(hs, 1);
-		/* raise console warning while waiting too long */
-		CDEBUG(is_power_of_2(i >> 3) ? D_WARNING : D_INFO,
-		       "hash %s is still rehashing, rescheded %d\n",
-		       hs->hs_name, i - 1);
-		cond_resched();
-		cfs_hash_lock(hs, 1);
-	}
-}
-
 void
 cfs_hash_rehash_cancel(struct cfs_hash *hs)
 {
-	cfs_hash_lock(hs, 1);
-	cfs_hash_rehash_cancel_locked(hs);
-	cfs_hash_unlock(hs, 1);
+	LASSERT(cfs_hash_with_rehash(hs));
+	cancel_work_sync(&hs->hs_rehash_work);
 }
 
-int
+void
 cfs_hash_rehash(struct cfs_hash *hs, int do_rehash)
 {
 	int rc;
@@ -1819,21 +1781,21 @@ cfs_hash_rehash(struct cfs_hash *hs, int do_rehash)
 	rc = cfs_hash_rehash_bits(hs);
 	if (rc <= 0) {
 		cfs_hash_unlock(hs, 1);
-		return rc;
+		return;
 	}
 
 	hs->hs_rehash_bits = rc;
 	if (!do_rehash) {
 		/* launch and return */
-		cfs_wi_schedule(cfs_sched_rehash, &hs->hs_rehash_wi);
+		queue_work(cfs_rehash_wq, &hs->hs_rehash_work);
 		cfs_hash_unlock(hs, 1);
-		return 0;
+		return;
 	}
 
 	/* rehash right now */
 	cfs_hash_unlock(hs, 1);
 
-	return cfs_hash_rehash_worker(&hs->hs_rehash_wi);
+	cfs_hash_rehash_worker(&hs->hs_rehash_work);
 }
 
 static int
@@ -1867,10 +1829,10 @@ cfs_hash_rehash_bd(struct cfs_hash *hs, struct cfs_hash_bd *old)
 	return c;
 }
 
-static int
-cfs_hash_rehash_worker(struct cfs_workitem *wi)
+static void
+cfs_hash_rehash_worker(struct work_struct *work)
 {
-	struct cfs_hash *hs = container_of(wi, struct cfs_hash, hs_rehash_wi);
+	struct cfs_hash *hs = container_of(work, struct cfs_hash, hs_rehash_work);
 	struct cfs_hash_bucket **bkts;
 	struct cfs_hash_bd bd;
 	unsigned int old_size;
@@ -1954,8 +1916,6 @@ cfs_hash_rehash_worker(struct cfs_workitem *wi)
 	hs->hs_cur_bits = hs->hs_rehash_bits;
 out:
 	hs->hs_rehash_bits = 0;
-	if (rc == -ESRCH) /* never be scheduled again */
-		cfs_wi_exit(cfs_sched_rehash, wi);
 	bsize = cfs_hash_bkt_size(hs);
 	cfs_hash_unlock(hs, 1);
 	/* can't refer to @hs anymore because it could be destroyed */
@@ -1963,8 +1923,6 @@ cfs_hash_rehash_worker(struct cfs_workitem *wi)
 		cfs_hash_buckets_free(bkts, bsize, new_size, old_size);
 	if (rc)
 		CDEBUG(D_INFO, "early quit of rehashing: %d\n", rc);
-	/* return 1 only if cfs_wi_exit is called */
-	return rc == -ESRCH;
 }
 
 /**
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index ff4b0cec1bbe..0254593b7f01 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -553,12 +553,10 @@ static int libcfs_init(void)
 		goto cleanup_deregister;
 	}
 
-	/* max to 4 threads, should be enough for rehash */
-	rc = min(cfs_cpt_weight(cfs_cpt_table, CFS_CPT_ANY), 4);
-	rc = cfs_wi_sched_create("cfs_rh", cfs_cpt_table, CFS_CPT_ANY,
-				 rc, &cfs_sched_rehash);
-	if (rc) {
-		CERROR("Startup workitem scheduler: error: %d\n", rc);
+	cfs_rehash_wq = alloc_workqueue("cfs_rh", WQ_SYSFS, 4);
+	if (!cfs_rehash_wq) {
+		CERROR("Failed to start rehash workqueue.\n");
+		rc = -ENOMEM;
 		goto cleanup_deregister;
 	}
 
@@ -589,9 +587,9 @@ static void libcfs_exit(void)
 
 	lustre_remove_debugfs();
 
-	if (cfs_sched_rehash) {
-		cfs_wi_sched_destroy(cfs_sched_rehash);
-		cfs_sched_rehash = NULL;
+	if (cfs_rehash_wq) {
+		destroy_workqueue(cfs_rehash_wq);
+		cfs_rehash_wq = NULL;
 	}
 
 	cfs_crypto_unregister();
