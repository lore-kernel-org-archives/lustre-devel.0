From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:21:53 -0400
Subject: [lustre-devel] [PATCH v2 13/25] staging: lustre: libcfs: fix
 libcfs_cpu coding style
In-Reply-To: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1527603725-30560-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

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
Changelog:

v1) Initial patch
v2) Rebased patch to handle recent libcfs changes

 .../lustre/include/linux/libcfs/libcfs_cpu.h       | 76 ++++++++----------
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    | 92 ++++++++--------------
 2 files changed, 66 insertions(+), 102 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index d5237d0..2c97adf 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -144,8 +144,7 @@ struct cfs_cpt_table {
 /**
  * return total number of CPU partitions in \a cptab
  */
-int
-cfs_cpt_number(struct cfs_cpt_table *cptab);
+int cfs_cpt_number(struct cfs_cpt_table *cptab);
 /**
  * return number of HW cores or hyper-threadings in a CPU partition \a cpt
  */
@@ -207,25 +206,24 @@ void cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab,
  * remove all cpus in NUMA node \a node from CPU partition \a cpt
  */
 void cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node);
-
 /**
  * add all cpus in node mask \a mask to CPU partition \a cpt
  * return 1 if successfully set all CPUs, otherwise return 0
  */
 int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab,
-			 int cpt, nodemask_t *mask);
+			 int cpt, const nodemask_t *mask);
 /**
  * remove all cpus in node mask \a mask from CPU partition \a cpt
  */
 void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
-			    int cpt, nodemask_t *mask);
+			    int cpt, const nodemask_t *mask);
 /**
  * convert partition id \a cpt to numa node id, if there are more than one
  * nodes in this partition, it might return a different node id each time.
  */
 int cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt);
 
-int  cfs_cpu_init(void);
+int cfs_cpu_init(void);
 void cfs_cpu_fini(void);
 
 #else /* !CONFIG_SMP */
@@ -282,32 +280,29 @@ static inline int cfs_cpt_distance_print(struct cfs_cpt_table *cptab,
 	return rc;
 }
 
-static inline cpumask_var_t *
-cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
+static inline cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab,
+					     int cpt)
 {
 	return &cptab->ctb_cpumask;
 }
 
-static inline int
-cfs_cpt_number(struct cfs_cpt_table *cptab)
+static inline int cfs_cpt_number(struct cfs_cpt_table *cptab)
 {
 	return 1;
 }
 
-static inline int
-cfs_cpt_weight(struct cfs_cpt_table *cptab, int cpt)
+static inline int cfs_cpt_weight(struct cfs_cpt_table *cptab, int cpt)
 {
 	return 1;
 }
 
-static inline int
-cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt)
+static inline int cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt)
 {
 	return 1;
 }
 
-static inline nodemask_t *
-cfs_cpt_nodemask(struct cfs_cpt_table *cptab, int cpt)
+static inline nodemask_t *cfs_cpt_nodemask(struct cfs_cpt_table *cptab,
+					   int cpt)
 {
 	return &cptab->ctb_nodemask;
 }
@@ -318,66 +313,61 @@ static inline unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab,
 	return 1;
 }
 
-static inline int
-cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
+static inline int cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt,
+				  int cpu)
 {
 	return 1;
 }
 
-static inline void
-cfs_cpt_unset_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
+static inline void cfs_cpt_unset_cpu(struct cfs_cpt_table *cptab, int cpt,
+				     int cpu)
 {
 }
 
-static inline int
-cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt,
-		    const cpumask_t *mask)
+static inline int cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt,
+				      const cpumask_t *mask)
 {
 	return 1;
 }
 
-static inline void
-cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt,
-		      const cpumask_t *mask)
+static inline void cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt,
+					 const cpumask_t *mask)
 {
 }
 
-static inline int
-cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt, int node)
+static inline int cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt,
+				   int node)
 {
 	return 1;
 }
 
-static inline void
-cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
+static inline void cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt,
+				      int node)
 {
 }
 
-static inline int
-cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt, nodemask_t *mask)
+static inline int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt,
+				       const nodemask_t *mask)
 {
 	return 1;
 }
 
-static inline void
-cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab, int cpt, nodemask_t *mask)
+static inline void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
+					  int cpt, const nodemask_t *mask)
 {
 }
 
-static inline int
-cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
+static inline int cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
 {
 	return 0;
 }
 
-static inline int
-cfs_cpt_current(struct cfs_cpt_table *cptab, int remap)
+static inline int cfs_cpt_current(struct cfs_cpt_table *cptab, int remap)
 {
 	return 0;
 }
 
-static inline int
-cfs_cpt_of_cpu(struct cfs_cpt_table *cptab, int cpu)
+static inline int cfs_cpt_of_cpu(struct cfs_cpt_table *cptab, int cpu)
 {
 	return 0;
 }
@@ -387,14 +377,12 @@ static inline int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 	return 0;
 }
 
-static inline int
-cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
+static inline int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 {
 	return 0;
 }
 
-static inline int
-cfs_cpu_init(void)
+static inline int cfs_cpu_init(void)
 {
 	cfs_cpt_tab = cfs_cpt_table_alloc(1);
 
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index bf41ba3..fab6675 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -69,8 +69,7 @@
 module_param(cpu_pattern, charp, 0444);
 MODULE_PARM_DESC(cpu_pattern, "CPU partitions pattern");
 
-struct cfs_cpt_table *
-cfs_cpt_table_alloc(unsigned int ncpt)
+struct cfs_cpt_table *cfs_cpt_table_alloc(unsigned int ncpt)
 {
 	struct cfs_cpt_table *cptab;
 	int i;
@@ -161,8 +160,7 @@ struct cfs_cpt_table *
 }
 EXPORT_SYMBOL(cfs_cpt_table_alloc);
 
-void
-cfs_cpt_table_free(struct cfs_cpt_table *cptab)
+void cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 {
 	int i;
 
@@ -186,8 +184,7 @@ struct cfs_cpt_table *
 }
 EXPORT_SYMBOL(cfs_cpt_table_free);
 
-int
-cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
+int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
 {
 	char *tmp = buf;
 	int rc;
@@ -262,15 +259,13 @@ int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
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
 
@@ -280,8 +275,7 @@ int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
 }
 EXPORT_SYMBOL(cfs_cpt_weight);
 
-int
-cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt)
+int cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt)
 {
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
@@ -293,8 +287,7 @@ int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
 }
 EXPORT_SYMBOL(cfs_cpt_online);
 
-cpumask_var_t *
-cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
+cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
 {
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
@@ -303,8 +296,7 @@ int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
 }
 EXPORT_SYMBOL(cfs_cpt_cpumask);
 
-nodemask_t *
-cfs_cpt_nodemask(struct cfs_cpt_table *cptab, int cpt)
+nodemask_t *cfs_cpt_nodemask(struct cfs_cpt_table *cptab, int cpt)
 {
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
@@ -450,8 +442,7 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 	}
 }
 
-int
-cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
+int cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 {
 	LASSERT(cpt >= 0 && cpt < cptab->ctb_nparts);
 
@@ -476,8 +467,7 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_set_cpu);
 
-void
-cfs_cpt_unset_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
+void cfs_cpt_unset_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 {
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
@@ -509,9 +499,8 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_unset_cpu);
 
-int
-cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt,
-		    const cpumask_t *mask)
+int cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt,
+			const cpumask_t *mask)
 {
 	int cpu;
 
@@ -531,9 +520,8 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_set_cpumask);
 
-void
-cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt,
-		      const cpumask_t *mask)
+void cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt,
+			   const cpumask_t *mask)
 {
 	int cpu;
 
@@ -542,8 +530,7 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_unset_cpumask);
 
-int
-cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt, int node)
+int cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt, int node)
 {
 	const cpumask_t *mask;
 	int cpu;
@@ -565,8 +552,7 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_set_node);
 
-void
-cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
+void cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
 {
 	const cpumask_t *mask;
 	int cpu;
@@ -586,8 +572,8 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_unset_node);
 
-int
-cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt, nodemask_t *mask)
+int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt,
+			 const nodemask_t *mask)
 {
 	int i;
 
@@ -600,8 +586,8 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_set_nodemask);
 
-void
-cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab, int cpt, nodemask_t *mask)
+void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab, int cpt,
+			    const nodemask_t *mask)
 {
 	int i;
 
@@ -610,8 +596,7 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_unset_nodemask);
 
-int
-cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
+int cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
 {
 	nodemask_t *mask;
 	int weight;
@@ -643,8 +628,7 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_spread_node);
 
-int
-cfs_cpt_current(struct cfs_cpt_table *cptab, int remap)
+int cfs_cpt_current(struct cfs_cpt_table *cptab, int remap)
 {
 	int cpu;
 	int cpt;
@@ -664,8 +648,7 @@ static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_current);
 
-int
-cfs_cpt_of_cpu(struct cfs_cpt_table *cptab, int cpu)
+int cfs_cpt_of_cpu(struct cfs_cpt_table *cptab, int cpu)
 {
 	LASSERT(cpu >= 0 && cpu < nr_cpu_ids);
 
@@ -682,8 +665,7 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 }
 EXPORT_SYMBOL(cfs_cpt_of_node);
 
-int
-cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
+int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 {
 	cpumask_var_t *cpumask;
 	nodemask_t *nodemask;
@@ -727,9 +709,8 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
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
@@ -805,8 +786,7 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 
 #define CPT_WEIGHT_MIN  4u
 
-static unsigned int
-cfs_cpt_num_estimate(void)
+static unsigned int cfs_cpt_num_estimate(void)
 {
 	unsigned int nnode = num_online_nodes();
 	unsigned int ncpu = num_online_cpus();
@@ -848,8 +828,7 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 	return ncpt;
 }
 
-static struct cfs_cpt_table *
-cfs_cpt_table_create(int ncpt)
+static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 {
 	struct cfs_cpt_table *cptab = NULL;
 	cpumask_var_t mask;
@@ -932,9 +911,9 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 
 	return cptab;
 
- failed_mask:
+failed_mask:
 	free_cpumask_var(mask);
- failed:
+failed:
 	CERROR("Failed to setup CPU-partition-table with %d CPU-partitions, online HW nodes: %d, HW cpus: %d.\n",
 	       ncpt, num_online_nodes(), num_online_cpus());
 
@@ -944,8 +923,7 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 	return NULL;
 }
 
-static struct cfs_cpt_table *
-cfs_cpt_table_create_pattern(char *pattern)
+static struct cfs_cpt_table *cfs_cpt_table_create_pattern(char *pattern)
 {
 	struct cfs_cpt_table *cptab;
 	char *str;
@@ -1089,7 +1067,7 @@ int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 
 	return cptab;
 
- failed:
+failed:
 	cfs_cpt_table_free(cptab);
 	return NULL;
 }
@@ -1116,8 +1094,7 @@ static int cfs_cpu_dead(unsigned int cpu)
 }
 #endif
 
-void
-cfs_cpu_fini(void)
+void cfs_cpu_fini(void)
 {
 	if (cfs_cpt_tab)
 		cfs_cpt_table_free(cfs_cpt_tab);
@@ -1129,8 +1106,7 @@ static int cfs_cpu_dead(unsigned int cpu)
 #endif
 }
 
-int
-cfs_cpu_init(void)
+int cfs_cpu_init(void)
 {
 	int ret;
 
-- 
1.8.3.1
