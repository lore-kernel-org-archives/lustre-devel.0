From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:08 -0500
Subject: [lustre-devel] [PATCH 36/45] staging/lustre/libcfs: Update comments
	style to match kernel
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-37-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

checkpatch complains that the trailing */ on the multiline comments
should be on it's own line.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/debug.c           | 18 +++++++++---------
 drivers/staging/lustre/lustre/libcfs/fail.c            |  3 ++-
 drivers/staging/lustre/lustre/libcfs/hash.c            | 18 ++++++++++++------
 drivers/staging/lustre/lustre/libcfs/libcfs_lock.c     |  3 ++-
 drivers/staging/lustre/lustre/libcfs/libcfs_string.c   |  3 ++-
 drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c |  9 ++++++---
 .../staging/lustre/lustre/libcfs/linux/linux-crypto.c  |  3 ++-
 .../lustre/lustre/libcfs/linux/linux-tracefile.c       |  3 ++-
 drivers/staging/lustre/lustre/libcfs/prng.c            | 13 +++++++------
 drivers/staging/lustre/lustre/libcfs/tracefile.c       | 14 +++++++++-----
 drivers/staging/lustre/lustre/libcfs/tracefile.h       |  6 ++++--
 drivers/staging/lustre/lustre/libcfs/workitem.c        | 12 ++++++++----
 12 files changed, 65 insertions(+), 40 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/debug.c b/drivers/staging/lustre/lustre/libcfs/debug.c
index fa81582..c90e510 100644
--- a/drivers/staging/lustre/lustre/libcfs/debug.c
+++ b/drivers/staging/lustre/lustre/libcfs/debug.c
@@ -82,7 +82,8 @@ static int libcfs_param_debug_mb_set(const char *val,
 
 /* While debug_mb setting look like unsigned int, in fact
  * it needs quite a bunch of extra processing, so we define special
- * debugmb parameter type with corresponding methods to handle this case */
+ * debugmb parameter type with corresponding methods to handle this case
+ */
 static struct kernel_param_ops param_ops_debugmb = {
 	.set = libcfs_param_debug_mb_set,
 	.get = param_get_uint,
@@ -227,8 +228,7 @@ MODULE_PARM_DESC(libcfs_debug_file_path,
 
 int libcfs_panic_in_progress;
 
-/* libcfs_debug_token2mask() expects the returned
- * string in lower-case */
+/* libcfs_debug_token2mask() expects the returned string in lower-case */
 static const char *
 libcfs_debug_subsys2str(int subsys)
 {
@@ -290,8 +290,7 @@ libcfs_debug_subsys2str(int subsys)
 	}
 }
 
-/* libcfs_debug_token2mask() expects the returned
- * string in lower-case */
+/* libcfs_debug_token2mask() expects the returned string in lower-case */
 static const char *
 libcfs_debug_dbg2str(int debug)
 {
@@ -470,7 +469,8 @@ void libcfs_debug_dumplog(void)
 
 	/* we're being careful to ensure that the kernel thread is
 	 * able to set our state to running as it exits before we
-	 * get to schedule() */
+	 * get to schedule()
+	 */
 	init_waitqueue_entry(&wait, current);
 	set_current_state(TASK_INTERRUPTIBLE);
 	add_wait_queue(&debug_ctlwq, &wait);
@@ -511,7 +511,8 @@ int libcfs_debug_init(unsigned long bufsize)
 	}
 
 	/* If libcfs_debug_mb is set to an invalid value or uninitialized
-	 * then just make the total buffers smp_num_cpus * TCD_MAX_PAGES */
+	 * then just make the total buffers smp_num_cpus * TCD_MAX_PAGES
+	 */
 	if (max > cfs_trace_max_debug_mb() || max < num_possible_cpus()) {
 		max = TCD_MAX_PAGES;
 	} else {
@@ -541,8 +542,7 @@ int libcfs_debug_clear_buffer(void)
 	return 0;
 }
 
-/* Debug markers, although printed by S_LNET
- * should not be be marked as such. */
+/* Debug markers, although printed by S_LNET should not be be marked as such. */
 #undef DEBUG_SUBSYSTEM
 #define DEBUG_SUBSYSTEM S_UNDEFINED
 int libcfs_debug_mark_buffer(const char *text)
diff --git a/drivers/staging/lustre/lustre/libcfs/fail.c b/drivers/staging/lustre/lustre/libcfs/fail.c
index 2783143..dadaf76 100644
--- a/drivers/staging/lustre/lustre/libcfs/fail.c
+++ b/drivers/staging/lustre/lustre/libcfs/fail.c
@@ -97,7 +97,8 @@ int __cfs_fail_check_set(__u32 id, __u32 value, int set)
 	/* Lost race to set CFS_FAILED_BIT. */
 	if (test_and_set_bit(CFS_FAILED_BIT, &cfs_fail_loc)) {
 		/* If CFS_FAIL_ONCE is valid, only one process can fail,
-		 * otherwise multi-process can fail at the same time. */
+		 * otherwise multi-process can fail@the same time.
+		 */
 		if (cfs_fail_loc & CFS_FAIL_ONCE)
 			return 0;
 	}
diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index 414577c..5e2afe4 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -579,7 +579,8 @@ cfs_hash_bd_move_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd_old,
 		return;
 
 	/* use cfs_hash_bd_hnode_add/del, to avoid atomic & refcount ops
-	 * in cfs_hash_bd_del/add_locked */
+	 * in cfs_hash_bd_del/add_locked
+	 */
 	hs->hs_hops->hop_hnode_del(hs, bd_old, hnode);
 	rc = hs->hs_hops->hop_hnode_add(hs, bd_new, hnode);
 	cfs_hash_bd_dep_record(hs, bd_new, rc);
@@ -635,7 +636,8 @@ cfs_hash_bd_lookup_intent(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 	int intent_add = (intent & CFS_HS_LOOKUP_MASK_ADD) != 0;
 
 	/* with this function, we can avoid a lot of useless refcount ops,
-	 * which are expensive atomic operations most time. */
+	 * which are expensive atomic operations most time.
+	 */
 	match = intent_add ? NULL : hnode;
 	hlist_for_each(ehnode, hhead) {
 		if (!cfs_hash_keycmp(hs, key, ehnode))
@@ -1109,7 +1111,8 @@ cfs_hash_destroy(struct cfs_hash *hs)
 					 hs->hs_name, bd.bd_bucket->hsb_index,
 					 bd.bd_offset, bd.bd_bucket->hsb_count);
 				/* can't assert key valicate, because we
-				 * can interrupt rehash */
+				 * can interrupt rehash
+				 */
 				cfs_hash_bd_del_locked(hs, &bd, hnode);
 				cfs_hash_exit(hs, hnode);
 			}
@@ -1160,7 +1163,8 @@ cfs_hash_rehash_bits(struct cfs_hash *hs)
 		return -EAGAIN;
 
 	/* XXX: need to handle case with max_theta != 2.0
-	 *      and the case with min_theta != 0.5 */
+	 *      and the case with min_theta != 0.5
+	 */
 	if ((hs->hs_cur_bits < hs->hs_max_bits) &&
 	    (__cfs_hash_theta(hs) > hs->hs_max_theta))
 		return hs->hs_cur_bits + 1;
@@ -1374,7 +1378,8 @@ cfs_hash_for_each_enter(struct cfs_hash *hs)
 	/* NB: iteration is mostly called by service thread,
 	 * we tend to cancel pending rehash-request, instead of
 	 * blocking service thread, we will relaunch rehash request
-	 * after iteration */
+	 * after iteration
+	 */
 	if (cfs_hash_is_rehashing(hs))
 		cfs_hash_rehash_cancel_locked(hs);
 	cfs_hash_unlock(hs, 1);
@@ -1987,7 +1992,8 @@ void cfs_hash_rehash_key(struct cfs_hash *hs, const void *old_key,
 		cfs_hash_bd_add_locked(hs, &new_bd, hnode);
 	}
 	/* overwrite key inside locks, otherwise may screw up with
-	 * other operations, i.e: rehash */
+	 * other operations, i.e: rehash
+	 */
 	cfs_hash_keycpy(hs, hnode, new_key);
 
 	cfs_hash_multi_bd_unlock(hs, bds, 3, 1);
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c b/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
index 9c64bfd..2de9eea 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
@@ -110,7 +110,8 @@ cfs_percpt_lock(struct cfs_percpt_lock *pcl, int index)
 		if (i == 0) {
 			LASSERT(!pcl->pcl_locked);
 			/* nobody should take private lock after this
-			 * so I wouldn't starve for too long time */
+			 * so I wouldn't starve for too long time
+			 */
 			pcl->pcl_locked = 1;
 		}
 	}
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
index f7cda59..4a2c83b 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
@@ -54,7 +54,8 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 	 * and optionally an operator ('+' or '-').  If an operator
 	 * appears first in <str>, '*oldmask' is used as the starting point
 	 * (relative), otherwise minmask is used (absolute).  An operator
-	 * applies to all following tokens up to the next operator. */
+	 * applies to all following tokens up to the next operator.
+	 */
 	while (*str != '\0') {
 		while (isspace(*str))
 			str++;
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
index 7fb277a..8d6a4ee 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
@@ -525,7 +525,8 @@ cfs_cpt_current(struct cfs_cpt_table *cptab, int remap)
 			return cpt;
 
 		/* don't return negative value for safety of upper layer,
-		 * instead we shadow the unknown cpu to a valid partition ID */
+		 * instead we shadow the unknown cpu to a valid partition ID
+		 */
 		cpt = cpu % cptab->ctb_nparts;
 	}
 
@@ -677,7 +678,8 @@ cfs_cpt_num_estimate(void)
 
 	/* generate reasonable number of CPU partitions based on total number
 	 * of CPUs, Preferred N should be power2 and match this condition:
-	 * 2 * (N - 1)^2 < NCPUS <= 2 * N^2 */
+	 * 2 * (N - 1)^2 < NCPUS <= 2 * N^2
+	 */
 	for (ncpt = 2; ncpu > 2 * ncpt * ncpt; ncpt <<= 1)
 		;
 
@@ -695,7 +697,8 @@ cfs_cpt_num_estimate(void)
  out:
 #if (BITS_PER_LONG == 32)
 	/* config many CPU partitions on 32-bit system could consume
-	 * too much memory */
+	 * too much memory
+	 */
 	ncpt = min(2U, ncpt);
 #endif
 	while (ncpu % ncpt != 0)
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c
index ccc25cd..44d1ad6 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c
@@ -249,7 +249,8 @@ static int cfs_crypto_test_hashes(void)
 	unsigned char	   *data;
 	unsigned int	    j;
 	/* Data block size for testing hash. Maximum
-	 * kmalloc size for 2.6.18 kernel is 128K */
+	 * kmalloc size for 2.6.18 kernel is 128K
+	 */
 	unsigned int	    data_len = 1 * 128 * 1024;
 
 	data = kmalloc(data_len, 0);
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
index 6cff79d..c50e24f 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
@@ -190,7 +190,8 @@ cfs_set_ptldebug_header(struct ptldebug_header *header,
 	header->ph_cpu_id = smp_processor_id();
 	header->ph_type = cfs_trace_buf_idx_get();
 	/* y2038 safe since all user space treats this as unsigned, but
-	 * will overflow in 2106 */
+	 * will overflow in 2106
+	 */
 	header->ph_sec = (u32)ts.tv_sec;
 	header->ph_usec = ts.tv_nsec / NSEC_PER_USEC;
 	header->ph_stack = stack;
diff --git a/drivers/staging/lustre/lustre/libcfs/prng.c b/drivers/staging/lustre/lustre/libcfs/prng.c
index 4147664..c75ae9a 100644
--- a/drivers/staging/lustre/lustre/libcfs/prng.c
+++ b/drivers/staging/lustre/lustre/libcfs/prng.c
@@ -42,11 +42,11 @@
 #include "../../include/linux/libcfs/libcfs.h"
 
 /*
-From: George Marsaglia <geo@stat.fsu.edu>
-Newsgroups: sci.math
-Subject: Re: A RANDOM NUMBER GENERATOR FOR C
-Date: Tue, 30 Sep 1997 05:29:35 -0700
-
+ * From: George Marsaglia <geo@stat.fsu.edu>
+ * Newsgroups: sci.math
+ * Subject: Re: A RANDOM NUMBER GENERATOR FOR C
+ * Date: Tue, 30 Sep 1997 05:29:35 -0700
+ *
  * You may replace the two constants 36969 and 18000 by any
  * pair of distinct constants from this list:
  * 18000 18030 18273 18513 18879 19074 19098 19164 19215 19584
@@ -58,7 +58,8 @@ Date: Tue, 30 Sep 1997 05:29:35 -0700
  * 27960 28320 28380 28689 28710 28794 28854 28959 28980 29013
  * 29379 29889 30135 30345 30459 30714 30903 30963 31059 31083
  * (or any other 16-bit constants k for which both k*2^16-1
- * and k*2^15-1 are prime) */
+ * and k*2^15-1 are prime)
+ */
 
 #define RANDOM_CONST_A 18030
 #define RANDOM_CONST_B 29013
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
index 298135f..b3abec6 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
@@ -317,7 +317,8 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 
 	/* cfs_trace_get_tcd() grabs a lock, which disables preemption and
 	 * pins us to a particular CPU.  This avoids an smp_processor_id()
-	 * warning on Linux when debugging is enabled. */
+	 * warning on Linux when debugging is enabled.
+	 */
 	cfs_set_ptldebug_header(&header, msgdata, CDEBUG_STACK());
 
 	if (!tcd)		/* arch may not log in IRQ context */
@@ -340,7 +341,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 	if (libcfs_debug_binary)
 		known_size += sizeof(header);
 
-	/*/
+	/*
 	 * '2' used because vsnprintf return real size required for output
 	 * _without_ terminating NULL.
 	 * if needed is to small for this format.
@@ -536,7 +537,8 @@ panic_collect_pages(struct page_collection *pc)
 {
 	/* Do the collect_pages job on a single CPU: assumes that all other
 	 * CPUs have been stopped during a panic.  If this isn't true for some
-	 * arch, this will have to be implemented separately in each arch.  */
+	 * arch, this will have to be implemented separately in each arch.
+	 */
 	int			i;
 	int			j;
 	struct cfs_trace_cpu_data *tcd;
@@ -618,7 +620,8 @@ static void put_pages_back(struct page_collection *pc)
 /* Add pages to a per-cpu debug daemon ringbuffer.  This buffer makes sure that
  * we have a good amount of data at all times for dumping during an LBUG, even
  * if we have been steadily writing (and otherwise discarding) pages via the
- * debug daemon. */
+ * debug daemon.
+ */
 static void put_pages_on_tcd_daemon_list(struct page_collection *pc,
 					 struct cfs_trace_cpu_data *tcd)
 {
@@ -730,7 +733,8 @@ int cfs_tracefile_dump_all_pages(char *filename)
 	}
 
 	/* ok, for now, just write the pages.  in the future we'll be building
-	 * iobufs with the pages and calling generic_direct_IO */
+	 * iobufs with the pages and calling generic_direct_IO
+	 */
 	MMSPACE_OPEN;
 	list_for_each_entry_safe(tage, tmp, &pc.pc_pages, linkage) {
 
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.h b/drivers/staging/lustre/lustre/libcfs/tracefile.h
index 2d4dc73..dffe07f 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.h
@@ -101,8 +101,10 @@ int cfs_trace_max_debug_mb(void);
 
 #define CFS_TRACEFILE_SIZE (500 << 20)
 
-/* Size of a buffer for sprinting console messages if we can't get a page
- * from system */
+/*
+ * Size of a buffer for sprinting console messages if we can't get a page
+ * from system
+ */
 #define CFS_TRACE_CONSOLE_BUFFER_SIZE   1024
 
 union cfs_trace_data_union {
diff --git a/drivers/staging/lustre/lustre/libcfs/workitem.c b/drivers/staging/lustre/lustre/libcfs/workitem.c
index e234dfe..08c5b19 100644
--- a/drivers/staging/lustre/lustre/libcfs/workitem.c
+++ b/drivers/staging/lustre/lustre/libcfs/workitem.c
@@ -54,11 +54,13 @@ struct cfs_wi_sched {
 	wait_queue_head_t		ws_waitq;
 	/** concurrent workitems */
 	struct list_head		ws_runq;
-	/** rescheduled running-workitems, a workitem can be rescheduled
+	/**
+	 * rescheduled running-workitems, a workitem can be rescheduled
 	 * while running in wi_action(), but we don't to execute it again
 	 * unless it returns from wi_action(), so we put it on ws_rerunq
 	 * while rescheduling, and move it to runq after it returns
-	 * from wi_action() */
+	 * from wi_action()
+	 */
 	struct list_head		ws_rerunq;
 	/** CPT-table for this scheduler */
 	struct cfs_cpt_table	*ws_cptab;
@@ -261,14 +263,16 @@ static int cfs_wi_scheduler(void *arg)
 
 			LASSERT(wi->wi_scheduled);
 			/* wi is rescheduled, should be on rerunq now, we
-			 * move it to runq so it can run action now */
+			 * move it to runq so it can run action now
+			 */
 			list_move_tail(&wi->wi_list, &sched->ws_runq);
 		}
 
 		if (!list_empty(&sched->ws_runq)) {
 			spin_unlock(&sched->ws_lock);
 			/* don't sleep because some workitems still
-			 * expect me to come back soon */
+			 * expect me to come back soon
+			 */
 			cond_resched();
 			spin_lock(&sched->ws_lock);
 			continue;
-- 
2.1.0
