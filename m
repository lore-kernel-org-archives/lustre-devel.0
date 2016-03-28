From: James Simmons <jsimmons@infradead.org>
Date: Sun, 27 Mar 2016 20:26:25 -0400
Subject: [lustre-devel] [PATCH 5/9] staging: lustre: libcfs: move all cpt
	handling to libcfs_cpu.h
In-Reply-To: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
References: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459124789-20758-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, frank zago <fzago@cray.com>, James Simmons <uja.ornl@yahoo.com>

Move the CPT handling declartions out of libcfs_private.h to
libcfs_cpu.h where it belongs.

Signed-off-by: frank zago <fzago@cray.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/15913
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |   64 +++++++++++++++++++
 .../lustre/include/linux/libcfs/libcfs_private.h   |   67 --------------------
 2 files changed, 64 insertions(+), 67 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 9e62c59..71ad93b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -203,6 +203,70 @@ int cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt);
  */
 int cfs_cpu_ht_nsiblings(int cpu);
 
+/*
+ * allocate per-cpu-partition data, returned value is an array of pointers,
+ * variable can be indexed by CPU ID.
+ *	cptab != NULL: size of array is number of CPU partitions
+ *	cptab == NULL: size of array is number of HW cores
+ */
+void *cfs_percpt_alloc(struct cfs_cpt_table *cptab, unsigned int size);
+/*
+ * destory per-cpu-partition variable
+ */
+void cfs_percpt_free(void *vars);
+int cfs_percpt_number(void *vars);
+
+#define cfs_percpt_for_each(var, i, vars)		\
+	for (i = 0; i < cfs_percpt_number(vars) &&	\
+		((var) = (vars)[i]) != NULL; i++)
+
+/*
+ * percpu partition lock
+ *
+ * There are some use-cases like this in Lustre:
+ * . each CPU partition has it's own private data which is frequently changed,
+ *   and mostly by the local CPU partition.
+ * . all CPU partitions share some global data, these data are rarely changed.
+ *
+ * LNet is typical example.
+ * CPU partition lock is designed for this kind of use-cases:
+ * . each CPU partition has it's own private lock
+ * . change on private data just needs to take the private lock
+ * . read on shared data just needs to take _any_ of private locks
+ * . change on shared data needs to take _all_ private locks,
+ *   which is slow and should be really rare.
+ */
+enum {
+	CFS_PERCPT_LOCK_EX	= -1,	/* negative */
+};
+
+struct cfs_percpt_lock {
+	/* cpu-partition-table for this lock */
+	struct cfs_cpt_table     *pcl_cptab;
+	/* exclusively locked */
+	unsigned int		  pcl_locked;
+	/* private lock table */
+	spinlock_t		**pcl_locks;
+};
+
+/* return number of private locks */
+#define cfs_percpt_lock_num(pcl)	cfs_cpt_number(pcl->pcl_cptab)
+
+/*
+ * create a cpu-partition lock based on CPU partition table \a cptab,
+ * each private lock has extra \a psize bytes padding data
+ */
+struct cfs_percpt_lock *cfs_percpt_lock_alloc(struct cfs_cpt_table *cptab);
+
+/* destroy a cpu-partition lock */
+void cfs_percpt_lock_free(struct cfs_percpt_lock *pcl);
+
+/* lock private lock \a index of \a pcl */
+void cfs_percpt_lock(struct cfs_percpt_lock *pcl, int index);
+
+/* unlock private lock \a index of \a pcl */
+void cfs_percpt_unlock(struct cfs_percpt_lock *pcl, int index);
+
 /**
  * iterate over all CPU partitions in \a cptab
  */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index a411527..e18b57b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -182,23 +182,6 @@ int libcfs_debug_clear_buffer(void);
 int libcfs_debug_mark_buffer(const char *text);
 
 /*
- * allocate per-cpu-partition data, returned value is an array of pointers,
- * variable can be indexed by CPU ID.
- *	cptable != NULL: size of array is number of CPU partitions
- *	cptable == NULL: size of array is number of HW cores
- */
-void *cfs_percpt_alloc(struct cfs_cpt_table *cptab, unsigned int size);
-/*
- * destroy per-cpu-partition variable
- */
-void  cfs_percpt_free(void *vars);
-int   cfs_percpt_number(void *vars);
-
-#define cfs_percpt_for_each(var, i, vars)		\
-	for (i = 0; i < cfs_percpt_number(vars) &&	\
-		    ((var) = (vars)[i]) != NULL; i++)
-
-/*
  * allocate a variable array, returned value is an array of pointers.
  * Caller can specify length of array by count.
  */
@@ -300,56 +283,6 @@ do {							    \
 #define CFS_ALLOC_PTR(ptr)      LIBCFS_ALLOC(ptr, sizeof(*(ptr)))
 #define CFS_FREE_PTR(ptr)       LIBCFS_FREE(ptr, sizeof(*(ptr)))
 
-/*
- * percpu partition lock
- *
- * There are some use-cases like this in Lustre:
- * . each CPU partition has it's own private data which is frequently changed,
- *   and mostly by the local CPU partition.
- * . all CPU partitions share some global data, these data are rarely changed.
- *
- * LNet is typical example.
- * CPU partition lock is designed for this kind of use-cases:
- * . each CPU partition has it's own private lock
- * . change on private data just needs to take the private lock
- * . read on shared data just needs to take _any_ of private locks
- * . change on shared data needs to take _all_ private locks,
- *   which is slow and should be really rare.
- */
-
-enum {
-	CFS_PERCPT_LOCK_EX	= -1, /* negative */
-};
-
-struct cfs_percpt_lock {
-	/* cpu-partition-table for this lock */
-	struct cfs_cpt_table	*pcl_cptab;
-	/* exclusively locked */
-	unsigned int		pcl_locked;
-	/* private lock table */
-	spinlock_t		**pcl_locks;
-};
-
-/* return number of private locks */
-static inline int
-cfs_percpt_lock_num(struct cfs_percpt_lock *pcl)
-{
-	return cfs_cpt_number(pcl->pcl_cptab);
-}
-
-/*
- * create a cpu-partition lock based on CPU partition table \a cptab,
- * each private lock has extra \a psize bytes padding data
- */
-struct cfs_percpt_lock *cfs_percpt_lock_alloc(struct cfs_cpt_table *cptab);
-/* destroy a cpu-partition lock */
-void cfs_percpt_lock_free(struct cfs_percpt_lock *pcl);
-
-/* lock private lock \a index of \a pcl */
-void cfs_percpt_lock(struct cfs_percpt_lock *pcl, int index);
-/* unlock private lock \a index of \a pcl */
-void cfs_percpt_unlock(struct cfs_percpt_lock *pcl, int index);
-
 /** Compile-time assertion.
 
  * Check an invariant described by a constant expression at compile time by
-- 
1.7.1
