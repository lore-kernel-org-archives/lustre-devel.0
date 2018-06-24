From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:20:33 -0400
Subject: [lustre-devel] [PATCH v3 09/26] staging: lustre: libcfs: use
 distance in cpu and node handling
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529875250-11531-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

Take into consideration the location of NUMA nodes and core
when calling cfs_cpt_[un]set_cpu() and cfs_cpt_[un]set_node().
This enables functioning on platforms with 100s of cores and
NUMA nodes.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18916
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 192 ++++++++++++++++++------
 1 file changed, 143 insertions(+), 49 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index b315fb2..3b4a9dc 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -334,11 +334,134 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 }
 EXPORT_SYMBOL(cfs_cpt_distance);
 
+/*
+ * Calculate the maximum NUMA distance between all nodes in the
+ * from_mask and all nodes in the to_mask.
+ */
+static unsigned int cfs_cpt_distance_calculate(nodemask_t *from_mask,
+					       nodemask_t *to_mask)
+{
+	unsigned int maximum;
+	unsigned int distance;
+	int from;
+	int to;
+
+	maximum = 0;
+	for_each_node_mask(from, *from_mask) {
+		for_each_node_mask(to, *to_mask) {
+			distance = node_distance(from, to);
+			if (maximum < distance)
+				maximum = distance;
+		}
+	}
+	return maximum;
+}
+
+static void cfs_cpt_add_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
+{
+	cptab->ctb_cpu2cpt[cpu] = cpt;
+
+	cpumask_set_cpu(cpu, cptab->ctb_cpumask);
+	cpumask_set_cpu(cpu, cptab->ctb_parts[cpt].cpt_cpumask);
+}
+
+static void cfs_cpt_del_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
+{
+	cpumask_clear_cpu(cpu, cptab->ctb_parts[cpt].cpt_cpumask);
+	cpumask_clear_cpu(cpu, cptab->ctb_cpumask);
+
+	cptab->ctb_cpu2cpt[cpu] = -1;
+}
+
+static void cfs_cpt_add_node(struct cfs_cpt_table *cptab, int cpt, int node)
+{
+	struct cfs_cpu_partition *part;
+
+	if (!node_isset(node, *cptab->ctb_nodemask)) {
+		unsigned int dist;
+
+		/* first time node is added to the CPT table */
+		node_set(node, *cptab->ctb_nodemask);
+		cptab->ctb_node2cpt[node] = cpt;
+
+		dist = cfs_cpt_distance_calculate(cptab->ctb_nodemask,
+						  cptab->ctb_nodemask);
+		cptab->ctb_distance = dist;
+	}
+
+	part = &cptab->ctb_parts[cpt];
+	if (!node_isset(node, *part->cpt_nodemask)) {
+		int cpt2;
+
+		/* first time node is added to this CPT */
+		node_set(node, *part->cpt_nodemask);
+		for (cpt2 = 0; cpt2 < cptab->ctb_nparts; cpt2++) {
+			struct cfs_cpu_partition *part2;
+			unsigned int dist;
+
+			part2 = &cptab->ctb_parts[cpt2];
+			dist = cfs_cpt_distance_calculate(part->cpt_nodemask,
+							  part2->cpt_nodemask);
+			part->cpt_distance[cpt2] = dist;
+			dist = cfs_cpt_distance_calculate(part2->cpt_nodemask,
+							  part->cpt_nodemask);
+			part2->cpt_distance[cpt] = dist;
+		}
+	}
+}
+
+static void cfs_cpt_del_node(struct cfs_cpt_table *cptab, int cpt, int node)
+{
+	struct cfs_cpu_partition *part = &cptab->ctb_parts[cpt];
+	int cpu;
+
+	for_each_cpu(cpu, part->cpt_cpumask) {
+		/* this CPT has other CPU belonging to this node? */
+		if (cpu_to_node(cpu) == node)
+			break;
+	}
+
+	if (cpu >= nr_cpu_ids && node_isset(node,  *part->cpt_nodemask)) {
+		int cpt2;
+
+		/* No more CPUs in the node for this CPT. */
+		node_clear(node, *part->cpt_nodemask);
+		for (cpt2 = 0; cpt2 < cptab->ctb_nparts; cpt2++) {
+			struct cfs_cpu_partition *part2;
+			unsigned int dist;
+
+			part2 = &cptab->ctb_parts[cpt2];
+			if (node_isset(node, *part2->cpt_nodemask))
+				cptab->ctb_node2cpt[node] = cpt2;
+
+			dist = cfs_cpt_distance_calculate(part->cpt_nodemask,
+							  part2->cpt_nodemask);
+			part->cpt_distance[cpt2] = dist;
+			dist = cfs_cpt_distance_calculate(part2->cpt_nodemask,
+							  part->cpt_nodemask);
+			part2->cpt_distance[cpt] = dist;
+		}
+	}
+
+	for_each_cpu(cpu, cptab->ctb_cpumask) {
+		/* this CPT-table has other CPUs belonging to this node? */
+		if (cpu_to_node(cpu) == node)
+			break;
+	}
+
+	if (cpu >= nr_cpu_ids && node_isset(node, *cptab->ctb_nodemask)) {
+		/* No more CPUs in the table for this node. */
+		node_clear(node, *cptab->ctb_nodemask);
+		cptab->ctb_node2cpt[node] = -1;
+		cptab->ctb_distance =
+			cfs_cpt_distance_calculate(cptab->ctb_nodemask,
+						   cptab->ctb_nodemask);
+	}
+}
+
 int
 cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 {
-	int node;
-
 	LASSERT(cpt >= 0 && cpt < cptab->ctb_nparts);
 
 	if (cpu < 0 || cpu >= nr_cpu_ids || !cpu_online(cpu)) {
@@ -352,23 +475,11 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 		return 0;
 	}
 
-	cptab->ctb_cpu2cpt[cpu] = cpt;
-
 	LASSERT(!cpumask_test_cpu(cpu, cptab->ctb_cpumask));
 	LASSERT(!cpumask_test_cpu(cpu, cptab->ctb_parts[cpt].cpt_cpumask));
 
-	cpumask_set_cpu(cpu, cptab->ctb_cpumask);
-	cpumask_set_cpu(cpu, cptab->ctb_parts[cpt].cpt_cpumask);
-
-	node = cpu_to_node(cpu);
-
-	/* first CPU of @node in this CPT table */
-	if (!node_isset(node, *cptab->ctb_nodemask))
-		node_set(node, *cptab->ctb_nodemask);
-
-	/* first CPU of @node in this partition */
-	if (!node_isset(node, *cptab->ctb_parts[cpt].cpt_nodemask))
-		node_set(node, *cptab->ctb_parts[cpt].cpt_nodemask);
+	cfs_cpt_add_cpu(cptab, cpt, cpu);
+	cfs_cpt_add_node(cptab, cpt, cpu_to_node(cpu));
 
 	return 1;
 }
@@ -377,9 +488,6 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 void
 cfs_cpt_unset_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 {
-	int node;
-	int i;
-
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
 	if (cpu < 0 || cpu >= nr_cpu_ids) {
@@ -405,32 +513,8 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 	LASSERT(cpumask_test_cpu(cpu, cptab->ctb_parts[cpt].cpt_cpumask));
 	LASSERT(cpumask_test_cpu(cpu, cptab->ctb_cpumask));
 
-	cpumask_clear_cpu(cpu, cptab->ctb_parts[cpt].cpt_cpumask);
-	cpumask_clear_cpu(cpu, cptab->ctb_cpumask);
-	cptab->ctb_cpu2cpt[cpu] = -1;
-
-	node = cpu_to_node(cpu);
-
-	LASSERT(node_isset(node, *cptab->ctb_parts[cpt].cpt_nodemask));
-	LASSERT(node_isset(node, *cptab->ctb_nodemask));
-
-	for_each_cpu(i, cptab->ctb_parts[cpt].cpt_cpumask) {
-		/* this CPT has other CPU belonging to this node? */
-		if (cpu_to_node(i) == node)
-			break;
-	}
-
-	if (i >= nr_cpu_ids)
-		node_clear(node, *cptab->ctb_parts[cpt].cpt_nodemask);
-
-	for_each_cpu(i, cptab->ctb_cpumask) {
-		/* this CPT-table has other CPU belonging to this node? */
-		if (cpu_to_node(i) == node)
-			break;
-	}
-
-	if (i >= nr_cpu_ids)
-		node_clear(node, *cptab->ctb_nodemask);
+	cfs_cpt_del_cpu(cptab, cpt, cpu);
+	cfs_cpt_del_node(cptab, cpt, cpu_to_node(cpu));
 }
 EXPORT_SYMBOL(cfs_cpt_unset_cpu);
 
@@ -448,8 +532,8 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 	}
 
 	for_each_cpu(cpu, mask) {
-		if (!cfs_cpt_set_cpu(cptab, cpt, cpu))
-			return 0;
+		cfs_cpt_add_cpu(cptab, cpt, cpu);
+		cfs_cpt_add_node(cptab, cpt, cpu_to_node(cpu));
 	}
 
 	return 1;
@@ -471,6 +555,7 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt, int node)
 {
 	const cpumask_t *mask;
+	int cpu;
 
 	if (node < 0 || node >= nr_node_ids) {
 		CDEBUG(D_INFO,
@@ -480,7 +565,12 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 
 	mask = cpumask_of_node(node);
 
-	return cfs_cpt_set_cpumask(cptab, cpt, mask);
+	for_each_cpu(cpu, mask)
+		cfs_cpt_add_cpu(cptab, cpt, cpu);
+
+	cfs_cpt_add_node(cptab, cpt, node);
+
+	return 1;
 }
 EXPORT_SYMBOL(cfs_cpt_set_node);
 
@@ -488,6 +578,7 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
 {
 	const cpumask_t *mask;
+	int cpu;
 
 	if (node < 0 || node >= nr_node_ids) {
 		CDEBUG(D_INFO,
@@ -497,7 +588,10 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 
 	mask = cpumask_of_node(node);
 
-	cfs_cpt_unset_cpumask(cptab, cpt, mask);
+	for_each_cpu(cpu, mask)
+		cfs_cpt_del_cpu(cptab, cpt, cpu);
+
+	cfs_cpt_del_node(cptab, cpt, node);
 }
 EXPORT_SYMBOL(cfs_cpt_unset_node);
 
-- 
1.8.3.1
