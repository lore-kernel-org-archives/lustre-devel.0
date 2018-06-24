From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:20:25 -0400
Subject: [lustre-devel] [PATCH v3 01/26] staging: lustre: libcfs: remove
 useless CPU partition code
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529875250-11531-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Dmitry Eremin <dmitry.eremin@intel.com>

* remove scratch buffer and mutex which guard it.
* remove global cpumask and spinlock which guard it.
* remove cpt_version for checking CPUs state change during setup
  because of just disable CPUs state change during setup.
* remove whole global struct cfs_cpt_data cpt_data.
* remove few unused APIs.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23303
Reviewed-on: https://review.whamcloud.com/25048
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |  32 ++----
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    | 115 +++------------------
 2 files changed, 22 insertions(+), 125 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 61641c4..1b4333d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -93,8 +93,6 @@ struct cfs_cpu_partition {
 
 /** descriptor for CPU partitions */
 struct cfs_cpt_table {
-	/* version, reserved for hotplug */
-	unsigned int			ctb_version;
 	/* spread rotor for NUMA allocator */
 	unsigned int			ctb_spread_rotor;
 	/* # of CPU partitions */
@@ -162,12 +160,12 @@ struct cfs_cpt_table {
  * return 1 if successfully set all CPUs, otherwise return 0
  */
 int cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab,
-			int cpt, cpumask_t *mask);
+			int cpt, const cpumask_t *mask);
 /**
  * remove all cpus in \a mask from CPU partition \a cpt
  */
 void cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab,
-			   int cpt, cpumask_t *mask);
+			   int cpt, const cpumask_t *mask);
 /**
  * add all cpus in NUMA node \a node to CPU partition \a cpt
  * return 1 if successfully set all CPUs, otherwise return 0
@@ -190,20 +188,11 @@ int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab,
 void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
 			    int cpt, nodemask_t *mask);
 /**
- * unset all cpus for CPU partition \a cpt
- */
-void cfs_cpt_clear(struct cfs_cpt_table *cptab, int cpt);
-/**
  * convert partition id \a cpt to numa node id, if there are more than one
  * nodes in this partition, it might return a different node id each time.
  */
 int cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt);
 
-/**
- * return number of HTs in the same core of \a cpu
- */
-int cfs_cpu_ht_nsiblings(int cpu);
-
 int  cfs_cpu_init(void);
 void cfs_cpu_fini(void);
 
@@ -258,13 +247,15 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
 }
 
 static inline int
-cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt, cpumask_t *mask)
+cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt,
+		    const cpumask_t *mask)
 {
 	return 1;
 }
 
 static inline void
-cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt, cpumask_t *mask)
+cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt,
+		      const cpumask_t *mask)
 {
 }
 
@@ -290,11 +281,6 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
 {
 }
 
-static inline void
-cfs_cpt_clear(struct cfs_cpt_table *cptab, int cpt)
-{
-}
-
 static inline int
 cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
 {
@@ -302,12 +288,6 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
 }
 
 static inline int
-cfs_cpu_ht_nsiblings(int cpu)
-{
-	return 1;
-}
-
-static inline int
 cfs_cpt_current(struct cfs_cpt_table *cptab, int remap)
 {
 	return 0;
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 3d1cf45..b363a3d 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -73,19 +73,6 @@
 module_param(cpu_pattern, charp, 0444);
 MODULE_PARM_DESC(cpu_pattern, "CPU partitions pattern");
 
-static struct cfs_cpt_data {
-	/* serialize hotplug etc */
-	spinlock_t		cpt_lock;
-	/* reserved for hotplug */
-	unsigned long		cpt_version;
-	/* mutex to protect cpt_cpumask */
-	struct mutex		cpt_mutex;
-	/* scratch buffer for set/unset_node */
-	cpumask_var_t		cpt_cpumask;
-} cpt_data;
-
-#define CFS_CPU_VERSION_MAGIC	   0xbabecafe
-
 struct cfs_cpt_table *
 cfs_cpt_table_alloc(unsigned int ncpt)
 {
@@ -128,11 +115,6 @@ struct cfs_cpt_table *
 			goto failed;
 	}
 
-	spin_lock(&cpt_data.cpt_lock);
-	/* Reserved for hotplug */
-	cptab->ctb_version = cpt_data.cpt_version;
-	spin_unlock(&cpt_data.cpt_lock);
-
 	return cptab;
 
  failed:
@@ -207,17 +189,6 @@ struct cfs_cpt_table *
 }
 EXPORT_SYMBOL(cfs_cpt_table_print);
 
-static void
-cfs_node_to_cpumask(int node, cpumask_t *mask)
-{
-	const cpumask_t *tmp = cpumask_of_node(node);
-
-	if (tmp)
-		cpumask_copy(mask, tmp);
-	else
-		cpumask_clear(mask);
-}
-
 int
 cfs_cpt_number(struct cfs_cpt_table *cptab)
 {
@@ -370,7 +341,8 @@ struct cfs_cpt_table *
 EXPORT_SYMBOL(cfs_cpt_unset_cpu);
 
 int
-cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt, cpumask_t *mask)
+cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt,
+		    const cpumask_t *mask)
 {
 	int i;
 
@@ -391,7 +363,8 @@ struct cfs_cpt_table *
 EXPORT_SYMBOL(cfs_cpt_set_cpumask);
 
 void
-cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt, cpumask_t *mask)
+cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt,
+		      const cpumask_t *mask)
 {
 	int i;
 
@@ -403,7 +376,7 @@ struct cfs_cpt_table *
 int
 cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt, int node)
 {
-	int rc;
+	const cpumask_t *mask;
 
 	if (node < 0 || node >= MAX_NUMNODES) {
 		CDEBUG(D_INFO,
@@ -411,34 +384,26 @@ struct cfs_cpt_table *
 		return 0;
 	}
 
-	mutex_lock(&cpt_data.cpt_mutex);
-
-	cfs_node_to_cpumask(node, cpt_data.cpt_cpumask);
-
-	rc = cfs_cpt_set_cpumask(cptab, cpt, cpt_data.cpt_cpumask);
+	mask = cpumask_of_node(node);
 
-	mutex_unlock(&cpt_data.cpt_mutex);
-
-	return rc;
+	return cfs_cpt_set_cpumask(cptab, cpt, mask);
 }
 EXPORT_SYMBOL(cfs_cpt_set_node);
 
 void
 cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
 {
+	const cpumask_t *mask;
+
 	if (node < 0 || node >= MAX_NUMNODES) {
 		CDEBUG(D_INFO,
 		       "Invalid NUMA id %d for CPU partition %d\n", node, cpt);
 		return;
 	}
 
-	mutex_lock(&cpt_data.cpt_mutex);
-
-	cfs_node_to_cpumask(node, cpt_data.cpt_cpumask);
-
-	cfs_cpt_unset_cpumask(cptab, cpt, cpt_data.cpt_cpumask);
+	mask = cpumask_of_node(node);
 
-	mutex_unlock(&cpt_data.cpt_mutex);
+	cfs_cpt_unset_cpumask(cptab, cpt, mask);
 }
 EXPORT_SYMBOL(cfs_cpt_unset_node);
 
@@ -466,26 +431,6 @@ struct cfs_cpt_table *
 }
 EXPORT_SYMBOL(cfs_cpt_unset_nodemask);
 
-void
-cfs_cpt_clear(struct cfs_cpt_table *cptab, int cpt)
-{
-	int last;
-	int i;
-
-	if (cpt == CFS_CPT_ANY) {
-		last = cptab->ctb_nparts - 1;
-		cpt = 0;
-	} else {
-		last = cpt;
-	}
-
-	for (; cpt <= last; cpt++) {
-		for_each_cpu(i, cptab->ctb_parts[cpt].cpt_cpumask)
-			cfs_cpt_unset_cpu(cptab, cpt, i);
-	}
-}
-EXPORT_SYMBOL(cfs_cpt_clear);
-
 int
 cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
 {
@@ -758,7 +703,7 @@ struct cfs_cpt_table *
 	}
 
 	for_each_online_node(i) {
-		cfs_node_to_cpumask(i, mask);
+		cpumask_copy(mask, cpumask_of_node(i));
 
 		while (!cpumask_empty(mask)) {
 			struct cfs_cpu_partition *part;
@@ -964,16 +909,8 @@ struct cfs_cpt_table *
 #ifdef CONFIG_HOTPLUG_CPU
 static enum cpuhp_state lustre_cpu_online;
 
-static void cfs_cpu_incr_cpt_version(void)
-{
-	spin_lock(&cpt_data.cpt_lock);
-	cpt_data.cpt_version++;
-	spin_unlock(&cpt_data.cpt_lock);
-}
-
 static int cfs_cpu_online(unsigned int cpu)
 {
-	cfs_cpu_incr_cpt_version();
 	return 0;
 }
 
@@ -981,14 +918,9 @@ static int cfs_cpu_dead(unsigned int cpu)
 {
 	bool warn;
 
-	cfs_cpu_incr_cpt_version();
-
-	mutex_lock(&cpt_data.cpt_mutex);
 	/* if all HTs in a core are offline, it may break affinity */
-	cpumask_copy(cpt_data.cpt_cpumask, topology_sibling_cpumask(cpu));
-	warn = cpumask_any_and(cpt_data.cpt_cpumask,
+	warn = cpumask_any_and(topology_sibling_cpumask(cpu),
 			       cpu_online_mask) >= nr_cpu_ids;
-	mutex_unlock(&cpt_data.cpt_mutex);
 	CDEBUG(warn ? D_WARNING : D_INFO,
 	       "Lustre: can't support CPU plug-out well now, performance and stability could be impacted [CPU %u]\n",
 	       cpu);
@@ -1007,7 +939,6 @@ static int cfs_cpu_dead(unsigned int cpu)
 		cpuhp_remove_state_nocalls(lustre_cpu_online);
 	cpuhp_remove_state_nocalls(CPUHP_LUSTRE_CFS_DEAD);
 #endif
-	free_cpumask_var(cpt_data.cpt_cpumask);
 }
 
 int
@@ -1017,16 +948,6 @@ static int cfs_cpu_dead(unsigned int cpu)
 
 	LASSERT(!cfs_cpt_tab);
 
-	memset(&cpt_data, 0, sizeof(cpt_data));
-
-	if (!zalloc_cpumask_var(&cpt_data.cpt_cpumask, GFP_NOFS)) {
-		CERROR("Failed to allocate scratch buffer\n");
-		return -1;
-	}
-
-	spin_lock_init(&cpt_data.cpt_lock);
-	mutex_init(&cpt_data.cpt_mutex);
-
 #ifdef CONFIG_HOTPLUG_CPU
 	ret = cpuhp_setup_state_nocalls(CPUHP_LUSTRE_CFS_DEAD,
 					"staging/lustre/cfe:dead", NULL,
@@ -1042,6 +963,7 @@ static int cfs_cpu_dead(unsigned int cpu)
 #endif
 	ret = -EINVAL;
 
+	get_online_cpus();
 	if (*cpu_pattern) {
 		char *cpu_pattern_dup = kstrdup(cpu_pattern, GFP_KERNEL);
 
@@ -1067,13 +989,7 @@ static int cfs_cpu_dead(unsigned int cpu)
 		}
 	}
 
-	spin_lock(&cpt_data.cpt_lock);
-	if (cfs_cpt_tab->ctb_version != cpt_data.cpt_version) {
-		spin_unlock(&cpt_data.cpt_lock);
-		CERROR("CPU hotplug/unplug during setup\n");
-		goto failed;
-	}
-	spin_unlock(&cpt_data.cpt_lock);
+	put_online_cpus();
 
 	LCONSOLE(0, "HW nodes: %d, HW CPU cores: %d, npartitions: %d\n",
 		 num_online_nodes(), num_online_cpus(),
@@ -1081,6 +997,7 @@ static int cfs_cpu_dead(unsigned int cpu)
 	return 0;
 
  failed:
+	put_online_cpus();
 	cfs_cpu_fini();
 	return ret;
 }
-- 
1.8.3.1
