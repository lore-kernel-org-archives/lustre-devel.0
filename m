From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:40 -0400
Subject: [lustre-devel] [PATCH 01/22] lnet: libcfs: fix CPT handling for UP
 systems
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

If a NULL nodemask or NULL a cpumask are passed to certain Linux
kernel functions can result in a crash. So for the UP case return
the default cpu_online_mask, which should only have one entry,
and the system nodemask defined by node_online_map. We can also
remove some unused inline functions for the UP case.

Fixes: 7b8e2026fb18 ("staging: lustre: remove conditional compilation from libcfs_cpu.c")
WC-bug-id: https://jira.whamcloud.com/browse/LU-9859
Lustre-commit: 83a2dbe9e50d3 ("83a2dbe9e50d3a60312fa40f41052b23a3edb3ca")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/37881
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 include/linux/libcfs/libcfs_cpu.h | 82 ++++++++++-----------------------------
 net/lnet/libcfs/libcfs_cpu.c      |  5 +--
 2 files changed, 23 insertions(+), 64 deletions(-)

diff --git a/include/linux/libcfs/libcfs_cpu.h b/include/linux/libcfs/libcfs_cpu.h
index c354dbd..4b0604a 100644
--- a/include/linux/libcfs/libcfs_cpu.h
+++ b/include/linux/libcfs/libcfs_cpu.h
@@ -85,9 +85,13 @@
 extern struct cfs_cpt_table	*cfs_cpt_tab;
 
 /**
- * return cpumask of CPU partition @cpt
+ * destroy a CPU partition table
  */
-cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt);
+void cfs_cpt_table_free(struct cfs_cpt_table *cptab);
+/**
+ * create a cfs_cpt_table with @ncpt number of partitions
+ */
+struct cfs_cpt_table *cfs_cpt_table_alloc(unsigned int ncpt);
 /**
  * print string information of cpt-table
  */
@@ -109,6 +113,10 @@
  */
 int cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt);
 /**
+ * return cpumask of CPU partition @cpt
+ */
+cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt);
+/**
  * return nodemask of CPU partition @cpt
  */
 nodemask_t *cfs_cpt_nodemask(struct cfs_cpt_table *cptab, int cpt);
@@ -185,6 +193,15 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
 
 #define cfs_cpt_tab ((struct cfs_cpt_table *)NULL)
 
+static inline void cfs_cpt_table_free(struct cfs_cpt_table *cptab)
+{
+}
+
+static inline struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt)
+{
+	return NULL;
+}
+
 static inline int cfs_cpt_table_print(struct cfs_cpt_table *cptab,
 				      char *buf, int len)
 {
@@ -214,7 +231,7 @@ static inline int cfs_cpt_distance_print(struct cfs_cpt_table *cptab,
 static inline cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab,
 					     int cpt)
 {
-	return NULL;
+	return (cpumask_var_t *) cpu_online_mask;
 }
 
 static inline int cfs_cpt_number(struct cfs_cpt_table *cptab)
@@ -227,15 +244,10 @@ static inline int cfs_cpt_weight(struct cfs_cpt_table *cptab, int cpt)
 	return 1;
 }
 
-static inline int cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt)
-{
-	return 1;
-}
-
 static inline nodemask_t *cfs_cpt_nodemask(struct cfs_cpt_table *cptab,
 					   int cpt)
 {
-	return NULL;
+	return &node_online_map;
 }
 
 static inline unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab,
@@ -244,50 +256,12 @@ static inline unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab,
 	return 1;
 }
 
-static inline int cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt,
-				  int cpu)
-{
-	return 1;
-}
-
-static inline void cfs_cpt_unset_cpu(struct cfs_cpt_table *cptab, int cpt,
-				     int cpu)
-{
-}
-
-static inline int cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt,
-				      const cpumask_t *mask)
-{
-	return 1;
-}
-
-static inline void cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt,
-					 const cpumask_t *mask)
-{
-}
-
 static inline int cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt,
 				   int node)
 {
 	return 1;
 }
 
-static inline void cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt,
-				      int node)
-{
-}
-
-static inline int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt,
-				       const nodemask_t *mask)
-{
-	return 1;
-}
-
-static inline void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
-					  int cpt, const nodemask_t *mask)
-{
-}
-
 static inline int cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
 {
 	return 0;
@@ -298,11 +272,6 @@ static inline int cfs_cpt_current(struct cfs_cpt_table *cptab, int remap)
 	return 0;
 }
 
-static inline int cfs_cpt_of_cpu(struct cfs_cpt_table *cptab, int cpu)
-{
-	return 0;
-}
-
 static inline int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
 {
 	return 0;
@@ -324,15 +293,6 @@ static inline void cfs_cpu_fini(void)
 
 #endif /* CONFIG_SMP */
 
-/**
- * destroy a CPU partition table
- */
-void cfs_cpt_table_free(struct cfs_cpt_table *cptab);
-/**
- * create a cfs_cpt_table with @ncpt number of partitions
- */
-struct cfs_cpt_table *cfs_cpt_table_alloc(unsigned int ncpt);
-
 /*
  * allocate per-cpu-partition data, returned value is an array of pointers,
  * variable can be indexed by CPU ID.
diff --git a/net/lnet/libcfs/libcfs_cpu.c b/net/lnet/libcfs/libcfs_cpu.c
index 6363fd7..8969e1f 100644
--- a/net/lnet/libcfs/libcfs_cpu.c
+++ b/net/lnet/libcfs/libcfs_cpu.c
@@ -35,7 +35,6 @@
 #include <linux/sched.h>
 #include <linux/module.h>
 #include <linux/slab.h>
-#include <linux/cache.h>
 
 #include <linux/libcfs/libcfs_cpu.h>
 #include <linux/libcfs/libcfs_string.h>
@@ -1162,13 +1161,13 @@ int cfs_cpu_init(void)
 
 #ifdef CONFIG_HOTPLUG_CPU
 	ret = cpuhp_setup_state_nocalls(CPUHP_LUSTRE_CFS_DEAD,
-					"staging/lustre/cfe:dead", NULL,
+					"fs/lustre/cfe:dead", NULL,
 					cfs_cpu_dead);
 	if (ret < 0)
 		goto failed_cpu_dead;
 
 	ret = cpuhp_setup_state_nocalls(CPUHP_AP_ONLINE_DYN,
-					"staging/lustre/cfe:online",
+					"fs/lustre/cfe:online",
 					cfs_cpu_online, NULL);
 	if (ret < 0)
 		goto failed_cpu_online;
-- 
1.8.3.1
