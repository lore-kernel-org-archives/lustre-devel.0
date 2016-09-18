From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:37 -0400
Subject: [lustre-devel] [PATCH 098/124] staging: lustre: lprocfs: cleanup
	stats locking code
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-99-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Add comment blocks on lprocfs_stats_lock() and lprocfs_stats_unlock().
Move common NOPERCPU code out of the switch() statements to reduce
code size and complexity, since it doesn't depend on the opc at all.

Replace switch() in lprocfs_stats_unlock() with a simple if/else,
since the lock opc was already checked in lprocfs_stats_lock().

Add an enum for the lprocfs_stats_lock() operations to make it clear
what the valid values are and allow compiler checking.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5946
Reviewed-on: http://review.whamcloud.com/12872
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lprocfs_status.h |  132 +++++++++++---------
 1 files changed, 74 insertions(+), 58 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index b1a8ca5..cc0713e 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -165,8 +165,10 @@ struct lprocfs_percpu {
 	struct lprocfs_counter lp_cntr[0];
 };
 
-#define LPROCFS_GET_NUM_CPU 0x0001
-#define LPROCFS_GET_SMP_ID  0x0002
+enum lprocfs_stats_lock_ops {
+	LPROCFS_GET_NUM_CPU	= 0x0001, /* number allocated per-CPU stats */
+	LPROCFS_GET_SMP_ID	= 0x0002, /* current stat to be updated */
+};
 
 enum lprocfs_stats_flags {
 	LPROCFS_STATS_FLAG_NONE     = 0x0000, /* per cpu counter */
@@ -371,77 +373,91 @@ int lprocfs_write_frac_helper(const char __user *buffer,
 int lprocfs_read_frac_helper(char *buffer, unsigned long count,
 			     long val, int mult);
 int lprocfs_stats_alloc_one(struct lprocfs_stats *stats, unsigned int cpuid);
-/*
- * \return value
- *      < 0     : on error (only possible for opc as LPROCFS_GET_SMP_ID)
+
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
+ * \param[in] stats	statistics structure to lock
+ * \param[in] opc	type of operation:
+ *			LPROCFS_GET_SMP_ID: "lock" and return current CPU index
+ *				for incrementing statistics for that CPU
+ *			LPROCFS_GET_NUM_CPU: "lock" and return number of used
+ *				CPU indices to iterate over all indices
+ * \param[out] flags	CPU interrupt saved state for IRQ-safe locking
+ *
+ * \retval cpuid of current thread or number of allocated structs
+ * \retval negative on error (only for opc LPROCFS_GET_SMP_ID + per-CPU stats)
  */
-static inline int lprocfs_stats_lock(struct lprocfs_stats *stats, int opc,
+static inline int lprocfs_stats_lock(struct lprocfs_stats *stats,
+				     enum lprocfs_stats_lock_ops opc,
 				     unsigned long *flags)
 {
-	int		rc = 0;
+	if (stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) {
+		if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE)
+			spin_lock_irqsave(&stats->ls_lock, *flags);
+		else
+			spin_lock(&stats->ls_lock);
+		return opc == LPROCFS_GET_NUM_CPU ? 1 : 0;
+	}
 
 	switch (opc) {
-	default:
-		LBUG();
+	case LPROCFS_GET_SMP_ID: {
+		unsigned int cpuid = get_cpu();
+
+		if (unlikely(!stats->ls_percpu[cpuid])) {
+			int rc = lprocfs_stats_alloc_one(stats, cpuid);
 
-	case LPROCFS_GET_SMP_ID:
-		if (stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) {
-			if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE)
-				spin_lock_irqsave(&stats->ls_lock, *flags);
-			else
-				spin_lock(&stats->ls_lock);
-			return 0;
-		} else {
-			unsigned int cpuid = get_cpu();
-
-			if (unlikely(!stats->ls_percpu[cpuid])) {
-				rc = lprocfs_stats_alloc_one(stats, cpuid);
-				if (rc < 0) {
-					put_cpu();
-					return rc;
-				}
+			if (rc < 0) {
+				put_cpu();
+				return rc;
 			}
-			return cpuid;
 		}
-
+		return cpuid;
+	}
 	case LPROCFS_GET_NUM_CPU:
-		if (stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) {
-			if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE)
-				spin_lock_irqsave(&stats->ls_lock, *flags);
-			else
-				spin_lock(&stats->ls_lock);
-			return 1;
-		}
 		return stats->ls_biggest_alloc_num;
+	default:
+		LBUG();
 	}
 }
 
-static inline void lprocfs_stats_unlock(struct lprocfs_stats *stats, int opc,
+/**
+ * Unlock statistics structure after access.
+ *
+ * Unlock the lock acquired via lprocfs_stats_lock() for global statistics,
+ * or unpin this thread from the current cpuid for per-CPU statistics.
+ *
+ * This function must be called using the same arguments as used when calling
+ * lprocfs_stats_lock() so that the correct operation can be performed.
+ *
+ * \param[in] stats	statistics structure to unlock
+ * \param[in] opc	type of operation (current cpuid or number of structs)
+ * \param[in] flags	CPU interrupt saved state for IRQ-safe locking
+ */
+static inline void lprocfs_stats_unlock(struct lprocfs_stats *stats,
+					enum lprocfs_stats_lock_ops opc,
 					unsigned long *flags)
 {
-	switch (opc) {
-	default:
-		LBUG();
-
-	case LPROCFS_GET_SMP_ID:
-		if (stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) {
-			if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE)
-				spin_unlock_irqrestore(&stats->ls_lock, *flags);
-			else
-				spin_unlock(&stats->ls_lock);
-		} else {
-			put_cpu();
-		}
-		return;
-
-	case LPROCFS_GET_NUM_CPU:
-		if (stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) {
-			if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE)
-				spin_unlock_irqrestore(&stats->ls_lock, *flags);
-			else
-				spin_unlock(&stats->ls_lock);
-		}
-		return;
+	if (stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) {
+		if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE)
+			spin_unlock_irqrestore(&stats->ls_lock, *flags);
+		else
+			spin_unlock(&stats->ls_lock);
+	} else if (opc == LPROCFS_GET_SMP_ID) {
+		put_cpu();
 	}
 }
 
-- 
1.7.1
