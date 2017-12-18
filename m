From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 11:46:30 +1100
Subject: [lustre-devel] [PATCH 04/15] staging: lustre: lnet: switch to
 cpumask_var_t
In-Reply-To: <151355781721.6200.2136335532722530242.stgit@noble>
References: <151355781721.6200.2136335532722530242.stgit@noble>
Message-ID: <151355799036.6200.12786177156592779397.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

So that we can use the common cpumask allocation functions,
switch to cpumask_var_t.
We need to be careful not the free a cpumask_var_t until the
variable has been initialized, and it cannot be initialized
directly.
So we must be sure either that it is filled with zeros, or
that zalloc_cpumask_var() has been called on it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |    4 -
 .../lustre/include/linux/libcfs/linux/linux-cpu.h  |    4 -
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    6 +
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |    2 
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |   92 +++++++++-----------
 5 files changed, 49 insertions(+), 59 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 6d132f941281..61bce77fddd6 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -79,7 +79,7 @@
 /**
  * return cpumask of CPU partition \a cpt
  */
-cpumask_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt);
+cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt);
 /**
  * print string information of cpt-table
  */
@@ -96,7 +96,7 @@ struct cfs_cpt_table {
 	u64			ctb_version;
 };
 
-static inline cpumask_t *
+static inline cpumask_var_t *
 cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
 {
 	return NULL;
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
index 854c84358ab4..6035376f2830 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
@@ -49,7 +49,7 @@
 /** virtual processing unit */
 struct cfs_cpu_partition {
 	/* CPUs mask for this partition */
-	cpumask_t			*cpt_cpumask;
+	cpumask_var_t			cpt_cpumask;
 	/* nodes mask for this partition */
 	nodemask_t			*cpt_nodemask;
 	/* spread rotor for NUMA allocator */
@@ -69,7 +69,7 @@ struct cfs_cpt_table {
 	/* shadow HW CPU to CPU partition ID */
 	int				*ctb_cpu2cpt;
 	/* all cpus in this partition table */
-	cpumask_t			*ctb_cpumask;
+	cpumask_var_t			ctb_cpumask;
 	/* all nodes in this partition table */
 	nodemask_t			*ctb_nodemask;
 };
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 039f53d787e4..f9bdf1877794 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -596,7 +596,7 @@ static void kiblnd_setup_mtu_locked(struct rdma_cm_id *cmid)
 
 static int kiblnd_get_completion_vector(struct kib_conn *conn, int cpt)
 {
-	cpumask_t *mask;
+	cpumask_var_t *mask;
 	int vectors;
 	int off;
 	int i;
@@ -611,8 +611,8 @@ static int kiblnd_get_completion_vector(struct kib_conn *conn, int cpt)
 		return 0;
 
 	/* hash NID to CPU id in this partition... */
-	off = do_div(nid, cpumask_weight(mask));
-	for_each_cpu(i, mask) {
+	off = do_div(nid, cpumask_weight(*mask));
+	for_each_cpu(i, *mask) {
 		if (!off--)
 			return i % vectors;
 	}
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index d05c3932b3b9..76291a350406 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -113,7 +113,7 @@ cfs_cpt_nodemask(struct cfs_cpt_table *cptab, int cpt)
 {
 	return &cptab->ctb_nodemask;
 }
-EXPORT_SYMBOL(cfs_cpt_cpumask);
+EXPORT_SYMBOL(cfs_cpt_nodemask);
 
 int
 cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 9a0f6cce1a1d..44e44a999648 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -72,7 +72,7 @@ struct cfs_cpt_data {
 	/* mutex to protect cpt_cpumask */
 	struct mutex		cpt_mutex;
 	/* scratch buffer for set/unset_node */
-	cpumask_t		*cpt_cpumask;
+	cpumask_var_t		cpt_cpumask;
 };
 
 static struct cfs_cpt_data	cpt_data;
@@ -106,8 +106,7 @@ cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 			kfree(part->cpt_nodemask);
 		}
 
-		if (part->cpt_cpumask)
-			LIBCFS_FREE(part->cpt_cpumask, cpumask_size());
+		free_cpumask_var(part->cpt_cpumask);
 	}
 
 	if (cptab->ctb_parts) {
@@ -117,8 +116,7 @@ cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 
 	if (cptab->ctb_nodemask)
 		kfree(cptab->ctb_nodemask);
-	if (cptab->ctb_cpumask)
-		LIBCFS_FREE(cptab->ctb_cpumask, cpumask_size());
+	free_cpumask_var(cptab->ctb_cpumask);
 
 	kfree(cptab);
 }
@@ -136,11 +134,10 @@ cfs_cpt_table_alloc(unsigned int ncpt)
 
 	cptab->ctb_nparts = ncpt;
 
-	LIBCFS_ALLOC(cptab->ctb_cpumask, cpumask_size());
 	cptab->ctb_nodemask = kzalloc(sizeof(*cptab->ctb_nodemask),
 				      GFP_NOFS);
-
-	if (!cptab->ctb_cpumask || !cptab->ctb_nodemask)
+	if (!zalloc_cpumask_var(&cptab->ctb_cpumask, GFP_NOFS) ||
+	    !cptab->ctb_nodemask)
 		goto failed;
 
 	LIBCFS_ALLOC(cptab->ctb_cpu2cpt,
@@ -158,10 +155,10 @@ cfs_cpt_table_alloc(unsigned int ncpt)
 	for (i = 0; i < ncpt; i++) {
 		struct cfs_cpu_partition *part = &cptab->ctb_parts[i];
 
-		LIBCFS_ALLOC(part->cpt_cpumask, cpumask_size());
 		part->cpt_nodemask = kzalloc(sizeof(*part->cpt_nodemask),
 					     GFP_NOFS);
-		if (!part->cpt_cpumask || !part->cpt_nodemask)
+		if (!zalloc_cpumask_var(&part->cpt_cpumask, GFP_NOFS) ||
+		    !part->cpt_nodemask)
 			goto failed;
 	}
 
@@ -252,13 +249,13 @@ cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt)
 }
 EXPORT_SYMBOL(cfs_cpt_online);
 
-cpumask_t *
+cpumask_var_t *
 cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
 {
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
 	return cpt == CFS_CPT_ANY ?
-	       cptab->ctb_cpumask : cptab->ctb_parts[cpt].cpt_cpumask;
+	       &cptab->ctb_cpumask : &cptab->ctb_parts[cpt].cpt_cpumask;
 }
 EXPORT_SYMBOL(cfs_cpt_cpumask);
 
@@ -406,7 +403,6 @@ EXPORT_SYMBOL(cfs_cpt_unset_cpumask);
 int
 cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt, int node)
 {
-	cpumask_t *mask;
 	int rc;
 
 	if (node < 0 || node >= MAX_NUMNODES) {
@@ -417,10 +413,9 @@ cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt, int node)
 
 	mutex_lock(&cpt_data.cpt_mutex);
 
-	mask = cpt_data.cpt_cpumask;
-	cfs_node_to_cpumask(node, mask);
+	cfs_node_to_cpumask(node, cpt_data.cpt_cpumask);
 
-	rc = cfs_cpt_set_cpumask(cptab, cpt, mask);
+	rc = cfs_cpt_set_cpumask(cptab, cpt, cpt_data.cpt_cpumask);
 
 	mutex_unlock(&cpt_data.cpt_mutex);
 
@@ -431,8 +426,6 @@ EXPORT_SYMBOL(cfs_cpt_set_node);
 void
 cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
 {
-	cpumask_t *mask;
-
 	if (node < 0 || node >= MAX_NUMNODES) {
 		CDEBUG(D_INFO,
 		       "Invalid NUMA id %d for CPU partition %d\n", node, cpt);
@@ -441,10 +434,9 @@ cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
 
 	mutex_lock(&cpt_data.cpt_mutex);
 
-	mask = cpt_data.cpt_cpumask;
-	cfs_node_to_cpumask(node, mask);
+	cfs_node_to_cpumask(node, cpt_data.cpt_cpumask);
 
-	cfs_cpt_unset_cpumask(cptab, cpt, mask);
+	cfs_cpt_unset_cpumask(cptab, cpt, cpt_data.cpt_cpumask);
 
 	mutex_unlock(&cpt_data.cpt_mutex);
 }
@@ -559,7 +551,7 @@ EXPORT_SYMBOL(cfs_cpt_of_cpu);
 int
 cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 {
-	cpumask_t *cpumask;
+	cpumask_var_t *cpumask;
 	nodemask_t *nodemask;
 	int rc;
 	int i;
@@ -567,24 +559,24 @@ cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
 	if (cpt == CFS_CPT_ANY) {
-		cpumask = cptab->ctb_cpumask;
+		cpumask = &cptab->ctb_cpumask;
 		nodemask = cptab->ctb_nodemask;
 	} else {
-		cpumask = cptab->ctb_parts[cpt].cpt_cpumask;
+		cpumask = &cptab->ctb_parts[cpt].cpt_cpumask;
 		nodemask = cptab->ctb_parts[cpt].cpt_nodemask;
 	}
 
-	if (cpumask_any_and(cpumask, cpu_online_mask) >= nr_cpu_ids) {
+	if (cpumask_any_and(*cpumask, cpu_online_mask) >= nr_cpu_ids) {
 		CERROR("No online CPU found in CPU partition %d, did someone do CPU hotplug on system? You might need to reload Lustre modules to keep system working well.\n",
 		       cpt);
 		return -EINVAL;
 	}
 
 	for_each_online_cpu(i) {
-		if (cpumask_test_cpu(i, cpumask))
+		if (cpumask_test_cpu(i, *cpumask))
 			continue;
 
-		rc = set_cpus_allowed_ptr(current, cpumask);
+		rc = set_cpus_allowed_ptr(current, *cpumask);
 		set_mems_allowed(*nodemask);
 		if (!rc)
 			schedule(); /* switch to allowed CPU */
@@ -605,8 +597,8 @@ static int
 cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
 		     cpumask_t *node, int number)
 {
-	cpumask_t *socket = NULL;
-	cpumask_t *core = NULL;
+	cpumask_var_t socket;
+	cpumask_var_t core;
 	int rc = 0;
 	int cpu;
 
@@ -624,13 +616,17 @@ cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
 		return 0;
 	}
 
-	/* allocate scratch buffer */
-	LIBCFS_ALLOC(socket, cpumask_size());
-	LIBCFS_ALLOC(core, cpumask_size());
-	if (!socket || !core) {
+	/*
+	 * Allocate scratch buffers
+	 * As we cannot initialize a cpumask_var_t, we need
+	 * to alloc both before we can risk trying to free either
+	 */
+	if (!zalloc_cpumask_var(&socket, GFP_NOFS))
+		rc = -ENOMEM;
+	if (!zalloc_cpumask_var(&core, GFP_NOFS))
 		rc = -ENOMEM;
+	if (rc)
 		goto out;
-	}
 
 	while (!cpumask_empty(node)) {
 		cpu = cpumask_first(node);
@@ -668,10 +664,8 @@ cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
 	}
 
 out:
-	if (socket)
-		LIBCFS_FREE(socket, cpumask_size());
-	if (core)
-		LIBCFS_FREE(core, cpumask_size());
+	free_cpumask_var(socket);
+	free_cpumask_var(core);
 	return rc;
 }
 
@@ -724,7 +718,7 @@ static struct cfs_cpt_table *
 cfs_cpt_table_create(int ncpt)
 {
 	struct cfs_cpt_table *cptab = NULL;
-	cpumask_t *mask = NULL;
+	cpumask_var_t mask;
 	int cpt = 0;
 	int num;
 	int rc;
@@ -757,8 +751,7 @@ cfs_cpt_table_create(int ncpt)
 		goto failed;
 	}
 
-	LIBCFS_ALLOC(mask, cpumask_size());
-	if (!mask) {
+	if (!zalloc_cpumask_var(&mask, GFP_NOFS)){
 		CERROR("Failed to allocate scratch cpumask\n");
 		goto failed;
 	}
@@ -785,7 +778,7 @@ cfs_cpt_table_create(int ncpt)
 
 			rc = cfs_cpt_choose_ncpus(cptab, cpt, mask, n);
 			if (rc < 0)
-				goto failed;
+				goto failed_mask;
 
 			LASSERT(num >= cpumask_weight(part->cpt_cpumask));
 			if (num == cpumask_weight(part->cpt_cpumask))
@@ -798,20 +791,19 @@ cfs_cpt_table_create(int ncpt)
 		CERROR("Expect %d(%d) CPU partitions but got %d(%d), CPU hotplug/unplug while setting?\n",
 		       cptab->ctb_nparts, num, cpt,
 		       cpumask_weight(cptab->ctb_parts[ncpt - 1].cpt_cpumask));
-		goto failed;
+		goto failed_mask;
 	}
 
-	LIBCFS_FREE(mask, cpumask_size());
+	free_cpumask_var(mask);
 
 	return cptab;
 
+ failed_mask:
+	free_cpumask_var(mask);
  failed:
 	CERROR("Failed to setup CPU-partition-table with %d CPU-partitions, online HW nodes: %d, HW cpus: %d.\n",
 	       ncpt, num_online_nodes(), num_online_cpus());
 
-	if (mask)
-		LIBCFS_FREE(mask, cpumask_size());
-
 	if (cptab)
 		cfs_cpt_table_free(cptab);
 
@@ -1014,8 +1006,7 @@ cfs_cpu_fini(void)
 		cpuhp_remove_state_nocalls(lustre_cpu_online);
 	cpuhp_remove_state_nocalls(CPUHP_LUSTRE_CFS_DEAD);
 #endif
-	if (cpt_data.cpt_cpumask)
-		LIBCFS_FREE(cpt_data.cpt_cpumask, cpumask_size());
+	free_cpumask_var(cpt_data.cpt_cpumask);
 }
 
 int
@@ -1027,8 +1018,7 @@ cfs_cpu_init(void)
 
 	memset(&cpt_data, 0, sizeof(cpt_data));
 
-	LIBCFS_ALLOC(cpt_data.cpt_cpumask, cpumask_size());
-	if (!cpt_data.cpt_cpumask) {
+	if (!zalloc_cpumask_var(&cpt_data.cpt_cpumask, GFP_NOFS)) {
 		CERROR("Failed to allocate scratch buffer\n");
 		return -1;
 	}
