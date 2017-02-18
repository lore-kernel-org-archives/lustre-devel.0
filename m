From: James Simmons <jsimmons@infradead.org>
Date: Sat, 18 Feb 2017 16:47:15 -0500
Subject: [lustre-devel] [PATCH 14/14] staging: lustre: lprocfs: move
	lprocfs_stats_[un]lock to a source file
In-Reply-To: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
References: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1487454435-4895-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

When compiling the kernel without optimization, when using GCOV,
the lprocfs_stats_alloc_one() symbol is not properly exported to
other modules and causes the ptlrpc module to fail loading with
an unknown symbol. There is no reason to export the function
lprocfs_stats_alloc_one. The reason is due to the functions
lprocfs_stats_[un]lock being inline functions in a header file.
Lets untangle this mess and turn those inline functions
into real functions in a source file.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8836
Reviewed-on: https://review.whamcloud.com/23773
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lprocfs_status.h | 120 ++-------------------
 .../lustre/lustre/obdclass/lprocfs_status.c        | 111 +++++++++++++++++++
 2 files changed, 121 insertions(+), 110 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 62753da..242abb8 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -374,94 +374,15 @@ int lprocfs_write_frac_helper(const char __user *buffer,
 			      unsigned long count, int *val, int mult);
 int lprocfs_read_frac_helper(char *buffer, unsigned long count,
 			     long val, int mult);
-int lprocfs_stats_alloc_one(struct lprocfs_stats *stats, unsigned int cpuid);
 
-/**
- * Lock statistics structure for access, possibly only on this CPU.
- *
- * The statistics struct may be allocated with per-CPU structures for
- * efficient concurrent update (usually only on server-wide stats), or
- * as a single global struct (e.g. for per-client or per-job statistics),
- * so the required locking depends on the type of structure allocated.
- *
- * For per-CPU statistics, pin the thread to the current cpuid so that
- * will only access the statistics for that CPU.  If the stats structure
- * for the current CPU has not been allocated (or previously freed),
- * allocate it now.  The per-CPU statistics do not need locking since
- * the thread is pinned to the CPU during update.
- *
- * For global statistics, lock the stats structure to prevent concurrent update.
- *
- * \param[in] stats	statistics structure to lock
- * \param[in] opc	type of operation:
- *			LPROCFS_GET_SMP_ID: "lock" and return current CPU index
- *				for incrementing statistics for that CPU
- *			LPROCFS_GET_NUM_CPU: "lock" and return number of used
- *				CPU indices to iterate over all indices
- * \param[out] flags	CPU interrupt saved state for IRQ-safe locking
- *
- * \retval cpuid of current thread or number of allocated structs
- * \retval negative on error (only for opc LPROCFS_GET_SMP_ID + per-CPU stats)
- */
-static inline int lprocfs_stats_lock(struct lprocfs_stats *stats,
-				     enum lprocfs_stats_lock_ops opc,
-				     unsigned long *flags)
-{
-	if (stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) {
-		if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE)
-			spin_lock_irqsave(&stats->ls_lock, *flags);
-		else
-			spin_lock(&stats->ls_lock);
-		return opc == LPROCFS_GET_NUM_CPU ? 1 : 0;
-	}
-
-	switch (opc) {
-	case LPROCFS_GET_SMP_ID: {
-		unsigned int cpuid = get_cpu();
-
-		if (unlikely(!stats->ls_percpu[cpuid])) {
-			int rc = lprocfs_stats_alloc_one(stats, cpuid);
-
-			if (rc < 0) {
-				put_cpu();
-				return rc;
-			}
-		}
-		return cpuid;
-	}
-	case LPROCFS_GET_NUM_CPU:
-		return stats->ls_biggest_alloc_num;
-	default:
-		LBUG();
-	}
-}
-
-/**
- * Unlock statistics structure after access.
- *
- * Unlock the lock acquired via lprocfs_stats_lock() for global statistics,
- * or unpin this thread from the current cpuid for per-CPU statistics.
- *
- * This function must be called using the same arguments as used when calling
- * lprocfs_stats_lock() so that the correct operation can be performed.
- *
- * \param[in] stats	statistics structure to unlock
- * \param[in] opc	type of operation (current cpuid or number of structs)
- * \param[in] flags	CPU interrupt saved state for IRQ-safe locking
- */
-static inline void lprocfs_stats_unlock(struct lprocfs_stats *stats,
-					enum lprocfs_stats_lock_ops opc,
-					unsigned long *flags)
-{
-	if (stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) {
-		if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE)
-			spin_unlock_irqrestore(&stats->ls_lock, *flags);
-		else
-			spin_unlock(&stats->ls_lock);
-	} else if (opc == LPROCFS_GET_SMP_ID) {
-		put_cpu();
-	}
-}
+int lprocfs_stats_alloc_one(struct lprocfs_stats *stats,
+			    unsigned int cpuid);
+int lprocfs_stats_lock(struct lprocfs_stats *stats,
+		       enum lprocfs_stats_lock_ops opc,
+		       unsigned long *flags);
+void lprocfs_stats_unlock(struct lprocfs_stats *stats,
+			  enum lprocfs_stats_lock_ops opc,
+			  unsigned long *flags);
 
 static inline unsigned int
 lprocfs_stats_counter_size(struct lprocfs_stats *stats)
@@ -513,29 +434,8 @@ __s64 lprocfs_read_helper(struct lprocfs_counter *lc,
 			  struct lprocfs_counter_header *header,
 			  enum lprocfs_stats_flags flags,
 			  enum lprocfs_fields_flags field);
-static inline __u64 lprocfs_stats_collector(struct lprocfs_stats *stats,
-					    int idx,
-					    enum lprocfs_fields_flags field)
-{
-	unsigned int i;
-	unsigned int  num_cpu;
-	unsigned long flags	= 0;
-	__u64	      ret	= 0;
-
-	LASSERT(stats);
-
-	num_cpu = lprocfs_stats_lock(stats, LPROCFS_GET_NUM_CPU, &flags);
-	for (i = 0; i < num_cpu; i++) {
-		if (!stats->ls_percpu[i])
-			continue;
-		ret += lprocfs_read_helper(
-				lprocfs_stats_counter_get(stats, i, idx),
-				&stats->ls_cnt_header[idx], stats->ls_flags,
-				field);
-	}
-	lprocfs_stats_unlock(stats, LPROCFS_GET_NUM_CPU, &flags);
-	return ret;
-}
+__u64 lprocfs_stats_collector(struct lprocfs_stats *stats, int idx,
+			      enum lprocfs_fields_flags field);
 
 extern struct lprocfs_stats *
 lprocfs_alloc_stats(unsigned int num, enum lprocfs_stats_flags flags);
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 2c99717..1ec6e37 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -598,6 +598,93 @@ int lprocfs_rd_conn_uuid(struct seq_file *m, void *data)
 }
 EXPORT_SYMBOL(lprocfs_rd_conn_uuid);
 
+/**
+ * Lock statistics structure for access, possibly only on this CPU.
+ *
+ * The statistics struct may be allocated with per-CPU structures for
+ * efficient concurrent update (usually only on server-wide stats), or
+ * as a single global struct (e.g. for per-client or per-job statistics),
+ * so the required locking depends on the type of structure allocated.
+ *
+ * For per-CPU statistics, pin the thread to the current cpuid so that
+ * will only access the statistics for that CPU.  If the stats structure
+ * for the current CPU has not been allocated (or previously freed),
+ * allocate it now.  The per-CPU statistics do not need locking since
+ * the thread is pinned to the CPU during update.
+ *
+ * For global statistics, lock the stats structure to prevent concurrent update.
+ *
+ * \param[in] stats    statistics structure to lock
+ * \param[in] opc      type of operation:
+ *                     LPROCFS_GET_SMP_ID: "lock" and return current CPU index
+ *                             for incrementing statistics for that CPU
+ *                     LPROCFS_GET_NUM_CPU: "lock" and return number of used
+ *                             CPU indices to iterate over all indices
+ * \param[out] flags   CPU interrupt saved state for IRQ-safe locking
+ *
+ * \retval cpuid of current thread or number of allocated structs
+ * \retval negative on error (only for opc LPROCFS_GET_SMP_ID + per-CPU stats)
+ */
+int lprocfs_stats_lock(struct lprocfs_stats *stats,
+		       enum lprocfs_stats_lock_ops opc,
+		       unsigned long *flags)
+{
+	if (stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) {
+		if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE)
+			spin_lock_irqsave(&stats->ls_lock, *flags);
+		else
+			spin_lock(&stats->ls_lock);
+		return opc == LPROCFS_GET_NUM_CPU ? 1 : 0;
+	}
+
+	switch (opc) {
+	case LPROCFS_GET_SMP_ID: {
+		unsigned int cpuid = get_cpu();
+
+		if (unlikely(!stats->ls_percpu[cpuid])) {
+			int rc = lprocfs_stats_alloc_one(stats, cpuid);
+
+			if (rc < 0) {
+				put_cpu();
+				return rc;
+			}
+		}
+		return cpuid;
+	}
+	case LPROCFS_GET_NUM_CPU:
+		return stats->ls_biggest_alloc_num;
+	default:
+		LBUG();
+	}
+}
+
+/**
+ * Unlock statistics structure after access.
+ *
+ * Unlock the lock acquired via lprocfs_stats_lock() for global statistics,
+ * or unpin this thread from the current cpuid for per-CPU statistics.
+ *
+ * This function must be called using the same arguments as used when calling
+ * lprocfs_stats_lock() so that the correct operation can be performed.
+ *
+ * \param[in] stats    statistics structure to unlock
+ * \param[in] opc      type of operation (current cpuid or number of structs)
+ * \param[in] flags    CPU interrupt saved state for IRQ-safe locking
+ */
+void lprocfs_stats_unlock(struct lprocfs_stats *stats,
+			  enum lprocfs_stats_lock_ops opc,
+			  unsigned long *flags)
+{
+	if (stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) {
+		if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE)
+			spin_unlock_irqrestore(&stats->ls_lock, *flags);
+		else
+			spin_unlock(&stats->ls_lock);
+	} else if (opc == LPROCFS_GET_SMP_ID) {
+		put_cpu();
+	}
+}
+
 /** add up per-cpu counters */
 void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 			   struct lprocfs_counter *cnt)
@@ -1146,6 +1233,30 @@ void lprocfs_free_stats(struct lprocfs_stats **statsh)
 }
 EXPORT_SYMBOL(lprocfs_free_stats);
 
+__u64 lprocfs_stats_collector(struct lprocfs_stats *stats, int idx,
+			      enum lprocfs_fields_flags field)
+{
+	unsigned int i;
+	unsigned int  num_cpu;
+	unsigned long flags     = 0;
+	__u64         ret       = 0;
+
+	LASSERT(stats);
+
+	num_cpu = lprocfs_stats_lock(stats, LPROCFS_GET_NUM_CPU, &flags);
+	for (i = 0; i < num_cpu; i++) {
+		if (!stats->ls_percpu[i])
+			continue;
+		ret += lprocfs_read_helper(
+				lprocfs_stats_counter_get(stats, i, idx),
+				&stats->ls_cnt_header[idx], stats->ls_flags,
+				field);
+	}
+	lprocfs_stats_unlock(stats, LPROCFS_GET_NUM_CPU, &flags);
+	return ret;
+}
+EXPORT_SYMBOL(lprocfs_stats_collector);
+
 void lprocfs_clear_stats(struct lprocfs_stats *stats)
 {
 	struct lprocfs_counter		*percpu_cntr;
-- 
1.8.3.1
