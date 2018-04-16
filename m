From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:09:54 -0400
Subject: [lustre-devel] [PATCH 12/25] staging: lustre: libcfs: fix
 libcfs_cpu coding style
In-Reply-To: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523851807-16573-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Dmitry Eremin <dmitry.eremin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

This patch bring the lustre CPT code into alignment with the
Linux kernel coding style.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23304
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |  35 ++++---
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |  70 +++++---------
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   | 107 +++++++++------------
 3 files changed, 86 insertions(+), 126 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index c0922fc..bda81ab 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -43,16 +43,16 @@
  *
  *     Example: if there are 8 cores on the system, while creating a CPT
  *     with cpu_npartitions=4:
- *	      core[0, 1] = partition[0], core[2, 3] = partition[1]
- *	      core[4, 5] = partition[2], core[6, 7] = partition[3]
+ *		core[0, 1] = partition[0], core[2, 3] = partition[1]
+ *		core[4, 5] = partition[2], core[6, 7] = partition[3]
  *
- *	  cpu_npartitions=1:
- *	      core[0, 1, ... 7] = partition[0]
+ *          cpu_npartitions=1:
+ *		core[0, 1, ... 7] = partition[0]
  *
  *   . User can also specify CPU partitions by string pattern
  *
  *     Examples: cpu_partitions="0[0,1], 1[2,3]"
- *	       cpu_partitions="N 0[0-3], 1[4-8]"
+ *		 cpu_partitions="N 0[0-3], 1[4-8]"
  *
  *     The first character "N" means following numbers are numa ID
  *
@@ -92,8 +92,8 @@ struct cfs_cpt_table {
 	u64			ctb_version;
 };
 
-static inline int
-cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
+static inline int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf,
+				      int len)
 {
 	return 0;
 }
@@ -116,8 +116,7 @@ struct cfs_cpt_table {
 /**
  * return total number of CPU partitions in \a cptab
  */
-int
-cfs_cpt_number(struct cfs_cpt_table *cptab);
+int cfs_cpt_number(struct cfs_cpt_table *cptab);
 /**
  * return number of HW cores or hyper-threadings in a CPU partition \a cpt
  */
@@ -167,13 +166,13 @@ struct cfs_cpt_table {
  * add all cpus in \a mask to CPU partition \a cpt
  * return 1 if successfully set all CPUs, otherwise return 0
  */
-int cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab,
-			int cpt, const cpumask_t *mask);
+int cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt,
+			const cpumask_t *mask);
 /**
  * remove all cpus in \a mask from CPU partition \a cpt
  */
-void cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab,
-			   int cpt, const cpumask_t *mask);
+void cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt,
+			   const cpumask_t *mask);
 /**
  * add all cpus in NUMA node \a node to CPU partition \a cpt
  * return 1 if successfully set all CPUs, otherwise return 0
@@ -188,13 +187,13 @@ void cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab,
  * add all cpus in node mask \a mask to CPU partition \a cpt
  * return 1 if successfully set all CPUs, otherwise return 0
  */
-int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab,
-			 int cpt, nodemask_t *mask);
+int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt,
+			 const nodemask_t *mask);
 /**
  * remove all cpus in node mask \a mask from CPU partition \a cpt
  */
-void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
-			    int cpt, nodemask_t *mask);
+void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab, int cpt,
+			    const nodemask_t *mask);
 /**
  * convert partition id \a cpt to numa node id, if there are more than one
  * nodes in this partition, it might return a different node id each time.
@@ -240,7 +239,7 @@ enum {
 
 struct cfs_percpt_lock {
 	/* cpu-partition-table for this lock */
-	struct cfs_cpt_table     *pcl_cptab;
+	struct cfs_cpt_table	 *pcl_cptab;
 	/* exclusively locked */
 	unsigned int		  pcl_locked;
 	/* private lock table */
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 7ac2796..f9fcbb1 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -34,7 +34,7 @@
 #include <linux/libcfs/libcfs.h>
 
 /** Global CPU partition table */
-struct cfs_cpt_table   *cfs_cpt_table __read_mostly;
+struct cfs_cpt_table *cfs_cpt_table __read_mostly;
 EXPORT_SYMBOL(cfs_cpt_table);
 
 #ifndef HAVE_LIBCFS_CPT
@@ -43,8 +43,7 @@
 
 #define CFS_CPT_DISTANCE	1	/* Arbitrary positive value */
 
-struct cfs_cpt_table *
-cfs_cpt_table_alloc(unsigned int ncpt)
+struct cfs_cpt_table *cfs_cpt_table_alloc(unsigned int ncpt)
 {
 	struct cfs_cpt_table *cptab;
 
@@ -67,8 +66,7 @@ struct cfs_cpt_table *
 }
 EXPORT_SYMBOL(cfs_cpt_table_alloc);
 
-void
-cfs_cpt_table_free(struct cfs_cpt_table *cptab)
+void cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 {
 	LASSERT(cptab->ctb_version == CFS_CPU_VERSION_MAGIC);
 
@@ -77,8 +75,7 @@ struct cfs_cpt_table *
 EXPORT_SYMBOL(cfs_cpt_table_free);
 
 #ifdef CONFIG_SMP
-int
-cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
+int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
 {
 	int rc;
 
@@ -105,22 +102,19 @@ int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
 }
 EXPORT_SYMBOL(cfs_cpt_distance_print);
 
-int
-cfs_cpt_number(struct cfs_cpt_table *cptab)
+int cfs_cpt_number(struct cfs_cpt_table *cptab)
 {
 	return 1;
 }
 EXPORT_SYMBOL(cfs_cpt_number);
 
-int
-cfs_cpt_weight(struct cfs_cpt_table *cptab, int cpt)
+int cfs_cpt_weight(struct cfs_cpt_table *cptab, int cpt)
 {
 	return 1;
 }
 EXPORT_SYMBOL(cfs_cpt_weight);
 
-int
-cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt)
+int cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt)
 {
 	return 1;
 }
@@ -132,8 +126,7 @@ cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
 }
 EXPORT_SYMBOL(cfs_cpt_cpumask);
 
-nodemask_t *
-cfs_cpt_nodemask(struct cfs_cpt_table *cptab, int cpt)
+nodemask_t *cfs_cpt_nodemask(struct cfs_cpt_table *cptab, int cpt)
 {
 	return &cptab->ctb_nodemask;
 }
@@ -145,75 +138,67 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 }
 EXPORT_SYMBOL(cfs_cpt_distance);
 
-int
-cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
+int cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 {
 	return 1;
 }
 EXPORT_SYMBOL(cfs_cpt_set_cpu);
 
-void
-cfs_cpt_unset_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
+void cfs_cpt_unset_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 {
 }
 EXPORT_SYMBOL(cfs_cpt_unset_cpu);
 
-int
-cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt, const cpumask_t *mask)
+int cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt,
+			const cpumask_t *mask)
 {
 	return 1;
 }
 EXPORT_SYMBOL(cfs_cpt_set_cpumask);
 
-void
-cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt,
-		      const cpumask_t *mask)
+void cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt,
+			   const cpumask_t *mask)
 {
 }
 EXPORT_SYMBOL(cfs_cpt_unset_cpumask);
 
-int
-cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt, int node)
+int cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt, int node)
 {
 	return 1;
 }
 EXPORT_SYMBOL(cfs_cpt_set_node);
 
-void
-cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
+void cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
 {
 }
 EXPORT_SYMBOL(cfs_cpt_unset_node);
 
-int
-cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt, nodemask_t *mask)
+int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt,
+			 const nodemask_t *mask)
 {
 	return 1;
 }
 EXPORT_SYMBOL(cfs_cpt_set_nodemask);
 
-void
-cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab, int cpt, nodemask_t *mask)
+void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab, int cpt,
+			    const nodemask_t *mask)
 {
 }
 EXPORT_SYMBOL(cfs_cpt_unset_nodemask);
 
-int
-cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
+int cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
 {
 	return 0;
 }
 EXPORT_SYMBOL(cfs_cpt_spread_node);
 
-int
-cfs_cpt_current(struct cfs_cpt_table *cptab, int remap)
+int cfs_cpt_current(struct cfs_cpt_table *cptab, int remap)
 {
 	return 0;
 }
 EXPORT_SYMBOL(cfs_cpt_current);
 
-int
-cfs_cpt_of_cpu(struct cfs_cpt_table *cptab, int cpu)
+int cfs_cpt_of_cpu(struct cfs_cpt_table *cptab, int cpu)
 {
 	return 0;
 }
@@ -225,15 +210,13 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_of_node);
 
-int
-cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
+int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 {
 	return 0;
 }
 EXPORT_SYMBOL(cfs_cpt_bind);
 
-void
-cfs_cpu_fini(void)
+void cfs_cpu_fini(void)
 {
 	if (cfs_cpt_table) {
 		cfs_cpt_table_free(cfs_cpt_table);
@@ -241,8 +224,7 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 	}
 }
 
-int
-cfs_cpu_init(void)
+int cfs_cpu_init(void)
 {
 	cfs_cpt_table = cfs_cpt_table_alloc(1);
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 6d8dcd3..5c9cdf4 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -43,7 +43,7 @@
  *  1 : disable multiple partitions
  * >1 : specify number of partitions
  */
-static int	cpu_npartitions;
+static int cpu_npartitions;
 module_param(cpu_npartitions, int, 0444);
 MODULE_PARM_DESC(cpu_npartitions, "# of CPU partitions");
 
@@ -60,12 +60,11 @@
  *
  * NB: If user specified cpu_pattern, cpu_npartitions will be ignored
  */
-static char	*cpu_pattern = "N";
+static char *cpu_pattern = "N";
 module_param(cpu_pattern, charp, 0444);
 MODULE_PARM_DESC(cpu_pattern, "CPU partitions pattern");
 
-void
-cfs_cpt_table_free(struct cfs_cpt_table *cptab)
+void cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 {
 	int i;
 
@@ -89,8 +88,7 @@
 }
 EXPORT_SYMBOL(cfs_cpt_table_free);
 
-struct cfs_cpt_table *
-cfs_cpt_table_alloc(unsigned int ncpt)
+struct cfs_cpt_table *cfs_cpt_table_alloc(unsigned int ncpt)
 {
 	struct cfs_cpt_table *cptab;
 	int i;
@@ -148,14 +146,13 @@ struct cfs_cpt_table *
 
 	return cptab;
 
- failed:
+failed:
 	cfs_cpt_table_free(cptab);
 	return NULL;
 }
 EXPORT_SYMBOL(cfs_cpt_table_alloc);
 
-int
-cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
+int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
 {
 	char *tmp = buf;
 	int rc = -EFBIG;
@@ -187,7 +184,7 @@ struct cfs_cpt_table *
 	}
 
 	rc = 0;
- out:
+out:
 	if (rc < 0)
 		return rc;
 
@@ -235,15 +232,13 @@ int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
 }
 EXPORT_SYMBOL(cfs_cpt_distance_print);
 
-int
-cfs_cpt_number(struct cfs_cpt_table *cptab)
+int cfs_cpt_number(struct cfs_cpt_table *cptab)
 {
 	return cptab->ctb_nparts;
 }
 EXPORT_SYMBOL(cfs_cpt_number);
 
-int
-cfs_cpt_weight(struct cfs_cpt_table *cptab, int cpt)
+int cfs_cpt_weight(struct cfs_cpt_table *cptab, int cpt)
 {
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
@@ -253,8 +248,7 @@ int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
 }
 EXPORT_SYMBOL(cfs_cpt_weight);
 
-int
-cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt)
+int cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt)
 {
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
@@ -266,8 +260,7 @@ int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
 }
 EXPORT_SYMBOL(cfs_cpt_online);
 
-cpumask_var_t *
-cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
+cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
 {
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
@@ -276,8 +269,7 @@ int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
 }
 EXPORT_SYMBOL(cfs_cpt_cpumask);
 
-nodemask_t *
-cfs_cpt_nodemask(struct cfs_cpt_table *cptab, int cpt)
+nodemask_t *cfs_cpt_nodemask(struct cfs_cpt_table *cptab, int cpt)
 {
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
@@ -423,8 +415,7 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 	}
 }
 
-int
-cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
+int cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 {
 	LASSERT(cpt >= 0 && cpt < cptab->ctb_nparts);
 
@@ -449,8 +440,7 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_set_cpu);
 
-void
-cfs_cpt_unset_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
+void cfs_cpt_unset_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 {
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
@@ -463,7 +453,8 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 		/* caller doesn't know the partition ID */
 		cpt = cptab->ctb_cpu2cpt[cpu];
 		if (cpt < 0) { /* not set in this CPT-table */
-			CDEBUG(D_INFO, "Try to unset cpu %d which is not in CPT-table %p\n",
+			CDEBUG(D_INFO,
+			       "Try to unset cpu %d which is not in CPT-table %p\n",
 			       cpt, cptab);
 			return;
 		}
@@ -482,14 +473,15 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_unset_cpu);
 
-int
-cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt, const cpumask_t *mask)
+int cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt,
+			const cpumask_t *mask)
 {
 	int cpu;
 
 	if (!cpumask_weight(mask) ||
 	    cpumask_any_and(mask, cpu_online_mask) >= nr_cpu_ids) {
-		CDEBUG(D_INFO, "No online CPU is found in the CPU mask for CPU partition %d\n",
+		CDEBUG(D_INFO,
+		       "No online CPU is found in the CPU mask for CPU partition %d\n",
 		       cpt);
 		return 0;
 	}
@@ -503,9 +495,8 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_set_cpumask);
 
-void
-cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt,
-		      const cpumask_t *mask)
+void cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt,
+			   const cpumask_t *mask)
 {
 	int cpu;
 
@@ -514,8 +505,7 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_unset_cpumask);
 
-int
-cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt, int node)
+int cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt, int node)
 {
 	const cpumask_t *mask;
 	int cpu;
@@ -537,8 +527,7 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_set_node);
 
-void
-cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
+void cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
 {
 	const cpumask_t *mask;
 	int cpu;
@@ -558,8 +547,8 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_unset_node);
 
-int
-cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt, nodemask_t *mask)
+int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt,
+			 const nodemask_t *mask)
 {
 	int i;
 
@@ -572,8 +561,8 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_set_nodemask);
 
-void
-cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab, int cpt, nodemask_t *mask)
+void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab, int cpt,
+			    const nodemask_t *mask)
 {
 	int i;
 
@@ -582,8 +571,7 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_unset_nodemask);
 
-int
-cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
+int cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
 {
 	nodemask_t *mask;
 	int weight;
@@ -615,8 +603,7 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_spread_node);
 
-int
-cfs_cpt_current(struct cfs_cpt_table *cptab, int remap)
+int cfs_cpt_current(struct cfs_cpt_table *cptab, int remap)
 {
 	int cpu;
 	int cpt;
@@ -636,8 +623,7 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_current);
 
-int
-cfs_cpt_of_cpu(struct cfs_cpt_table *cptab, int cpu)
+int cfs_cpt_of_cpu(struct cfs_cpt_table *cptab, int cpu)
 {
 	LASSERT(cpu >= 0 && cpu < nr_cpu_ids);
 
@@ -654,8 +640,7 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_of_node);
 
-int
-cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
+int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 {
 	cpumask_var_t *cpumask;
 	nodemask_t *nodemask;
@@ -699,9 +684,8 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
  * Choose max to \a number CPUs from \a node and set them in \a cpt.
  * We always prefer to choose CPU in the same core/socket.
  */
-static int
-cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
-		     cpumask_t *node, int number)
+static int cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
+				cpumask_t *node, int number)
 {
 	cpumask_var_t socket;
 	cpumask_var_t core;
@@ -777,8 +761,7 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 
 #define CPT_WEIGHT_MIN  4u
 
-static unsigned int
-cfs_cpt_num_estimate(void)
+static unsigned int cfs_cpt_num_estimate(void)
 {
 	unsigned int nnode = num_online_nodes();
 	unsigned int ncpu = num_online_cpus();
@@ -820,8 +803,7 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 	return ncpt;
 }
 
-static struct cfs_cpt_table *
-cfs_cpt_table_create(int ncpt)
+static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 {
 	struct cfs_cpt_table *cptab = NULL;
 	cpumask_var_t mask;
@@ -904,9 +886,9 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 
 	return cptab;
 
- failed_mask:
+failed_mask:
 	free_cpumask_var(mask);
- failed:
+failed:
 	CERROR("Failed to setup CPU-partition-table with %d CPU-partitions, online HW nodes: %d, HW cpus: %d.\n",
 	       ncpt, num_online_nodes(), num_online_cpus());
 
@@ -916,8 +898,7 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 	return NULL;
 }
 
-static struct cfs_cpt_table *
-cfs_cpt_table_create_pattern(char *pattern)
+static struct cfs_cpt_table *cfs_cpt_table_create_pattern(char *pattern)
 {
 	struct cfs_cpt_table *cptab;
 	char *str;
@@ -1061,7 +1042,7 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 
 	return cptab;
 
- failed:
+failed:
 	cfs_cpt_table_free(cptab);
 	return NULL;
 }
@@ -1088,8 +1069,7 @@ static int cfs_cpu_dead(unsigned int cpu)
 }
 #endif
 
-void
-cfs_cpu_fini(void)
+void cfs_cpu_fini(void)
 {
 	if (cfs_cpt_table)
 		cfs_cpt_table_free(cfs_cpt_table);
@@ -1101,8 +1081,7 @@ static int cfs_cpu_dead(unsigned int cpu)
 #endif
 }
 
-int
-cfs_cpu_init(void)
+int cfs_cpu_init(void)
 {
 	int ret = 0;
 
@@ -1156,7 +1135,7 @@ static int cfs_cpu_dead(unsigned int cpu)
 		 cfs_cpt_number(cfs_cpt_table));
 	return 0;
 
- failed:
+failed:
 	put_online_cpus();
 	cfs_cpu_fini();
 	return ret;
-- 
1.8.3.1
