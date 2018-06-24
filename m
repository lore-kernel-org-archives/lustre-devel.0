From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:20:42 -0400
Subject: [lustre-devel] [PATCH v3 18/26] staging: lustre: libcfs: make
 tolerant to offline CPUs and empty NUMA nodes
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529875250-11531-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Dmitry Eremin <dmitry.eremin@intel.com>

Rework CPU partition code in the way of make it more tolerant to
offline CPUs and empty nodes.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23222
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 132 ++++++++++--------------
 1 file changed, 56 insertions(+), 76 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index ebfa4e3..18925c7 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -461,8 +461,16 @@ int cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 		return 0;
 	}
 
-	LASSERT(!cpumask_test_cpu(cpu, cptab->ctb_cpumask));
-	LASSERT(!cpumask_test_cpu(cpu, cptab->ctb_parts[cpt].cpt_cpumask));
+	if (cpumask_test_cpu(cpu, cptab->ctb_cpumask)) {
+		CDEBUG(D_INFO, "CPU %d is already in cpumask\n", cpu);
+		return 0;
+	}
+
+	if (cpumask_test_cpu(cpu, cptab->ctb_parts[cpt].cpt_cpumask)) {
+		CDEBUG(D_INFO, "CPU %d is already in partition %d cpumask\n",
+		       cpu, cptab->ctb_cpu2cpt[cpu]);
+		return 0;
+	}
 
 	cfs_cpt_add_cpu(cptab, cpt, cpu);
 	cfs_cpt_add_node(cptab, cpt, cpu_to_node(cpu));
@@ -531,8 +539,10 @@ void cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt,
 {
 	int cpu;
 
-	for_each_cpu(cpu, mask)
-		cfs_cpt_unset_cpu(cptab, cpt, cpu);
+	for_each_cpu(cpu, mask) {
+		cfs_cpt_del_cpu(cptab, cpt, cpu);
+		cfs_cpt_del_node(cptab, cpt, cpu_to_node(cpu));
+	}
 }
 EXPORT_SYMBOL(cfs_cpt_unset_cpumask);
 
@@ -583,10 +593,8 @@ int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt,
 {
 	int node;
 
-	for_each_node_mask(node, *mask) {
-		if (!cfs_cpt_set_node(cptab, cpt, node))
-			return 0;
-	}
+	for_each_node_mask(node, *mask)
+		cfs_cpt_set_node(cptab, cpt, node);
 
 	return 1;
 }
@@ -607,7 +615,7 @@ int cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
 	nodemask_t *mask;
 	int weight;
 	int rotor;
-	int node;
+	int node = 0;
 
 	/* convert CPU partition ID to HW node id */
 
@@ -617,20 +625,20 @@ int cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
 	} else {
 		mask = cptab->ctb_parts[cpt].cpt_nodemask;
 		rotor = cptab->ctb_parts[cpt].cpt_spread_rotor++;
+		node  = cptab->ctb_parts[cpt].cpt_node;
 	}
 
 	weight = nodes_weight(*mask);
-	LASSERT(weight > 0);
-
-	rotor %= weight;
+	if (weight > 0) {
+		rotor %= weight;
 
-	for_each_node_mask(node, *mask) {
-		if (!rotor--)
-			return node;
+		for_each_node_mask(node, *mask) {
+			if (!rotor--)
+				return node;
+		}
 	}
 
-	LBUG();
-	return 0;
+	return node;
 }
 EXPORT_SYMBOL(cfs_cpt_spread_node);
 
@@ -723,17 +731,21 @@ static int cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
 	cpumask_var_t core_mask;
 	int rc = 0;
 	int cpu;
+	int i;
 
 	LASSERT(number > 0);
 
 	if (number >= cpumask_weight(node_mask)) {
 		while (!cpumask_empty(node_mask)) {
 			cpu = cpumask_first(node_mask);
+			cpumask_clear_cpu(cpu, node_mask);
+
+			if (!cpu_online(cpu))
+				continue;
 
 			rc = cfs_cpt_set_cpu(cptab, cpt, cpu);
 			if (!rc)
 				return -EINVAL;
-			cpumask_clear_cpu(cpu, node_mask);
 		}
 		return 0;
 	}
@@ -754,24 +766,19 @@ static int cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
 		cpu = cpumask_first(node_mask);
 
 		/* get cpumask for cores in the same socket */
-		cpumask_copy(socket_mask, topology_core_cpumask(cpu));
-		cpumask_and(socket_mask, socket_mask, node_mask);
-
-		LASSERT(!cpumask_empty(socket_mask));
-
+		cpumask_and(socket_mask, topology_core_cpumask(cpu), node_mask);
 		while (!cpumask_empty(socket_mask)) {
-			int i;
-
 			/* get cpumask for hts in the same core */
-			cpumask_copy(core_mask, topology_sibling_cpumask(cpu));
-			cpumask_and(core_mask, core_mask, node_mask);
-
-			LASSERT(!cpumask_empty(core_mask));
+			cpumask_and(core_mask, topology_sibling_cpumask(cpu),
+				    node_mask);
 
 			for_each_cpu(i, core_mask) {
 				cpumask_clear_cpu(i, socket_mask);
 				cpumask_clear_cpu(i, node_mask);
 
+				if (!cpu_online(i))
+					continue;
+
 				rc = cfs_cpt_set_cpu(cptab, cpt, i);
 				if (!rc) {
 					rc = -EINVAL;
@@ -840,23 +847,18 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 	struct cfs_cpt_table *cptab = NULL;
 	cpumask_var_t node_mask;
 	int cpt = 0;
+	int node;
 	int num;
-	int rc;
-	int i;
+	int rem;
+	int rc = 0;
 
-	rc = cfs_cpt_num_estimate();
+	num = cfs_cpt_num_estimate();
 	if (ncpt <= 0)
-		ncpt = rc;
+		ncpt = num;
 
-	if (ncpt > num_online_cpus() || ncpt > 4 * rc) {
+	if (ncpt > num_online_cpus() || ncpt > 4 * num) {
 		CWARN("CPU partition number %d is larger than suggested value (%d), your system may have performance issue or run out of memory while under pressure\n",
-		      ncpt, rc);
-	}
-
-	if (num_online_cpus() % ncpt) {
-		CERROR("CPU number %d is not multiple of cpu_npartition %d, please try different cpu_npartitions value or set pattern string by cpu_pattern=STRING\n",
-		       (int)num_online_cpus(), ncpt);
-		goto failed;
+		      ncpt, num);
 	}
 
 	cptab = cfs_cpt_table_alloc(ncpt);
@@ -865,55 +867,33 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 		goto failed;
 	}
 
-	num = num_online_cpus() / ncpt;
-	if (!num) {
-		CERROR("CPU changed while setting CPU partition\n");
-		goto failed;
-	}
-
 	if (!zalloc_cpumask_var(&node_mask, GFP_NOFS)) {
 		CERROR("Failed to allocate scratch cpumask\n");
 		goto failed;
 	}
 
-	for_each_online_node(i) {
-		cpumask_copy(node_mask, cpumask_of_node(i));
-
-		while (!cpumask_empty(node_mask)) {
-			struct cfs_cpu_partition *part;
-			int n;
-
-			/*
-			 * Each emulated NUMA node has all allowed CPUs in
-			 * the mask.
-			 * End loop when all partitions have assigned CPUs.
-			 */
-			if (cpt == ncpt)
-				break;
-
-			part = &cptab->ctb_parts[cpt];
+	num = num_online_cpus() / ncpt;
+	rem = num_online_cpus() % ncpt;
+	for_each_online_node(node) {
+		cpumask_copy(node_mask, cpumask_of_node(node));
 
-			n = num - cpumask_weight(part->cpt_cpumask);
-			LASSERT(n > 0);
+		while (cpt < ncpt && !cpumask_empty(node_mask)) {
+			struct cfs_cpu_partition *part = &cptab->ctb_parts[cpt];
+			int ncpu = cpumask_weight(part->cpt_cpumask);
 
-			rc = cfs_cpt_choose_ncpus(cptab, cpt, node_mask, n);
+			rc = cfs_cpt_choose_ncpus(cptab, cpt, node_mask,
+						  num - ncpu);
 			if (rc < 0)
 				goto failed_mask;
 
-			LASSERT(num >= cpumask_weight(part->cpt_cpumask));
-			if (num == cpumask_weight(part->cpt_cpumask))
+			ncpu = cpumask_weight(part->cpt_cpumask);
+			if (ncpu == num + !!(rem > 0)) {
 				cpt++;
+				rem--;
+			}
 		}
 	}
 
-	if (cpt != ncpt ||
-	    num != cpumask_weight(cptab->ctb_parts[ncpt - 1].cpt_cpumask)) {
-		CERROR("Expect %d(%d) CPU partitions but got %d(%d), CPU hotplug/unplug while setting?\n",
-		       cptab->ctb_nparts, num, cpt,
-		       cpumask_weight(cptab->ctb_parts[ncpt - 1].cpt_cpumask));
-		goto failed_mask;
-	}
-
 	free_cpumask_var(node_mask);
 
 	return cptab;
-- 
1.8.3.1
