From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 Nov 2015 13:39:58 -0500
Subject: [lustre-devel] [PATCH 02/10] staging: lustre: remove unnecessary
	EXPORT_SYMBOL in libcfs
In-Reply-To: <1446662406-4590-1-git-send-email-jsimmons@infradead.org>
References: <1446662406-4590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446662406-4590-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: frank zago <fzago@cray.com>

A lot of symbols don't need to be exported at all because they are
only used in the module they belong to.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5829
Reviewed-on: http://review.whamcloud.com/13319
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lustre/libcfs/debug.c       |   10 ----------
 drivers/staging/lustre/lustre/libcfs/hash.c        |   10 ----------
 drivers/staging/lustre/lustre/libcfs/libcfs_mem.c  |    2 --
 .../lustre/lustre/libcfs/linux/linux-debug.c       |    1 -
 4 files changed, 0 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/debug.c b/drivers/staging/lustre/lustre/libcfs/debug.c
index 1d1c671..4272a7c 100644
--- a/drivers/staging/lustre/lustre/libcfs/debug.c
+++ b/drivers/staging/lustre/lustre/libcfs/debug.c
@@ -94,17 +94,14 @@ static struct kernel_param_ops param_ops_debugmb = {
 static unsigned int libcfs_debug_mb;
 module_param(libcfs_debug_mb, debugmb, 0644);
 MODULE_PARM_DESC(libcfs_debug_mb, "Total debug buffer size.");
-EXPORT_SYMBOL(libcfs_debug_mb);
 
 unsigned int libcfs_printk = D_CANTMASK;
 module_param(libcfs_printk, uint, 0644);
 MODULE_PARM_DESC(libcfs_printk, "Lustre kernel debug console mask");
-EXPORT_SYMBOL(libcfs_printk);
 
 unsigned int libcfs_console_ratelimit = 1;
 module_param(libcfs_console_ratelimit, uint, 0644);
 MODULE_PARM_DESC(libcfs_console_ratelimit, "Lustre kernel debug console ratelimit (0 to disable)");
-EXPORT_SYMBOL(libcfs_console_ratelimit);
 
 static int param_set_delay_minmax(const char *val,
 				  const struct kernel_param *kp,
@@ -135,9 +132,7 @@ static int param_get_delay(char *buffer, const struct kernel_param *kp)
 }
 
 unsigned int libcfs_console_max_delay;
-EXPORT_SYMBOL(libcfs_console_max_delay);
 unsigned int libcfs_console_min_delay;
-EXPORT_SYMBOL(libcfs_console_min_delay);
 
 static int param_set_console_max_delay(const char *val,
 				       const struct kernel_param *kp)
@@ -207,10 +202,8 @@ static struct kernel_param_ops param_ops_uintpos = {
 unsigned int libcfs_console_backoff = CDEBUG_DEFAULT_BACKOFF;
 module_param(libcfs_console_backoff, uintpos, 0644);
 MODULE_PARM_DESC(libcfs_console_backoff, "Lustre kernel debug console backoff factor");
-EXPORT_SYMBOL(libcfs_console_backoff);
 
 unsigned int libcfs_debug_binary = 1;
-EXPORT_SYMBOL(libcfs_debug_binary);
 
 unsigned int libcfs_stack = 3 * THREAD_SIZE / 4;
 EXPORT_SYMBOL(libcfs_stack);
@@ -221,7 +214,6 @@ EXPORT_SYMBOL(libcfs_catastrophe);
 unsigned int libcfs_panic_on_lbug = 1;
 module_param(libcfs_panic_on_lbug, uint, 0644);
 MODULE_PARM_DESC(libcfs_panic_on_lbug, "Lustre kernel panic on LBUG");
-EXPORT_SYMBOL(libcfs_panic_on_lbug);
 
 static wait_queue_head_t debug_ctlwq;
 
@@ -572,5 +564,3 @@ void libcfs_debug_set_level(unsigned int debug_level)
 	       debug_level);
 	libcfs_debug = debug_level;
 }
-
-EXPORT_SYMBOL(libcfs_debug_set_level);
diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index 8800d64..f23a11d 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -593,7 +593,6 @@ cfs_hash_bd_move_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd_old,
 	if (unlikely(nbkt->hsb_version == 0))
 		nbkt->hsb_version++;
 }
-EXPORT_SYMBOL(cfs_hash_bd_move_locked);
 
 enum {
 	/** always set, for sanity (avoid ZERO intent) */
@@ -830,21 +829,18 @@ cfs_hash_dual_bd_get(struct cfs_hash *hs, const void *key,
 
 	cfs_hash_bd_order(&bds[0], &bds[1]);
 }
-EXPORT_SYMBOL(cfs_hash_dual_bd_get);
 
 void
 cfs_hash_dual_bd_lock(struct cfs_hash *hs, struct cfs_hash_bd *bds, int excl)
 {
 	cfs_hash_multi_bd_lock(hs, bds, 2, excl);
 }
-EXPORT_SYMBOL(cfs_hash_dual_bd_lock);
 
 void
 cfs_hash_dual_bd_unlock(struct cfs_hash *hs, struct cfs_hash_bd *bds, int excl)
 {
 	cfs_hash_multi_bd_unlock(hs, bds, 2, excl);
 }
-EXPORT_SYMBOL(cfs_hash_dual_bd_unlock);
 
 struct hlist_node *
 cfs_hash_dual_bd_lookup_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
@@ -852,7 +848,6 @@ cfs_hash_dual_bd_lookup_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
 {
 	return cfs_hash_multi_bd_lookup_locked(hs, bds, 2, key);
 }
-EXPORT_SYMBOL(cfs_hash_dual_bd_lookup_locked);
 
 struct hlist_node *
 cfs_hash_dual_bd_findadd_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
@@ -862,7 +857,6 @@ cfs_hash_dual_bd_findadd_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
 	return cfs_hash_multi_bd_findadd_locked(hs, bds, 2, key,
 						hnode, noref);
 }
-EXPORT_SYMBOL(cfs_hash_dual_bd_findadd_locked);
 
 struct hlist_node *
 cfs_hash_dual_bd_finddel_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
@@ -870,7 +864,6 @@ cfs_hash_dual_bd_finddel_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
 {
 	return cfs_hash_multi_bd_finddel_locked(hs, bds, 2, key, hnode);
 }
-EXPORT_SYMBOL(cfs_hash_dual_bd_finddel_locked);
 
 static void
 cfs_hash_buckets_free(struct cfs_hash_bucket **buckets,
@@ -1792,7 +1785,6 @@ cfs_hash_rehash_cancel_locked(struct cfs_hash *hs)
 		cfs_hash_lock(hs, 1);
 	}
 }
-EXPORT_SYMBOL(cfs_hash_rehash_cancel_locked);
 
 void
 cfs_hash_rehash_cancel(struct cfs_hash *hs)
@@ -1801,7 +1793,6 @@ cfs_hash_rehash_cancel(struct cfs_hash *hs)
 	cfs_hash_rehash_cancel_locked(hs);
 	cfs_hash_unlock(hs, 1);
 }
-EXPORT_SYMBOL(cfs_hash_rehash_cancel);
 
 int
 cfs_hash_rehash(struct cfs_hash *hs, int do_rehash)
@@ -1831,7 +1822,6 @@ cfs_hash_rehash(struct cfs_hash *hs, int do_rehash)
 
 	return cfs_hash_rehash_worker(&hs->hs_rehash_wi);
 }
-EXPORT_SYMBOL(cfs_hash_rehash);
 
 static int
 cfs_hash_rehash_bd(struct cfs_hash *hs, struct cfs_hash_bd *old)
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c b/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c
index f4e08da..27cf861 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c
@@ -134,7 +134,6 @@ cfs_percpt_current(void *vars)
 
 	return arr->va_ptrs[cpt];
 }
-EXPORT_SYMBOL(cfs_percpt_current);
 
 void *
 cfs_percpt_index(void *vars, int idx)
@@ -146,7 +145,6 @@ cfs_percpt_index(void *vars, int idx)
 	LASSERT(idx >= 0 && idx < arr->va_count);
 	return arr->va_ptrs[idx];
 }
-EXPORT_SYMBOL(cfs_percpt_index);
 
 /*
  * free variable array, see more detail in cfs_array_alloc
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
index 8689ea7..59c7bf3 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
@@ -195,6 +195,5 @@ void libcfs_unregister_panic_notifier(void)
 	atomic_notifier_chain_unregister(&panic_notifier_list, &libcfs_panic_notifier);
 }
 
-EXPORT_SYMBOL(libcfs_run_upcall);
 EXPORT_SYMBOL(libcfs_run_lbug_upcall);
 EXPORT_SYMBOL(lbug_with_loc);
-- 
1.7.1
