From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:21:50 -0400
Subject: [lustre-devel] [PATCH v2 10/25] staging: lustre: libcfs: use
 distance in cpu and node handling
In-Reply-To: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1527603725-30560-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

Take into consideration the location of NUMA nodes and core
when calling cfs_cpt_[un]set_cpu() and cfs_cpt_[un]set_node().
This enables functioning on platforms with 100s of cores and
NUMA nodes.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18916
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
Changelog:

v1) Initial patch
v2) Rebased patch to handle recent libcfs changes

 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 192 ++++++++++++++++++------
 1 file changed, 143 insertions(+), 49 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 2a74e51..9ff9fe9 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -330,11 +330,134 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
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
@@ -348,23 +471,11 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
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
@@ -373,9 +484,6 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 void
 cfs_cpt_unset_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 {
-	int node;
-	int i;
-
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
 	if (cpu < 0 || cpu >= nr_cpu_ids) {
@@ -401,32 +509,8 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
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
 
@@ -444,8 +528,8 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 	}
 
 	for_each_cpu(cpu, mask) {
-		if (!cfs_cpt_set_cpu(cptab, cpt, cpu))
-			return 0;
+		cfs_cpt_add_cpu(cptab, cpt, cpu);
+		cfs_cpt_add_node(cptab, cpt, cpu_to_node(cpu));
 	}
 
 	return 1;
@@ -467,6 +551,7 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt, int node)
 {
 	const cpumask_t *mask;
+	int cpu;
 
 	if (node < 0 || node >= nr_node_ids) {
 		CDEBUG(D_INFO,
@@ -476,7 +561,12 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 
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
 
@@ -484,6 +574,7 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
 {
 	const cpumask_t *mask;
+	int cpu;
 
 	if (node < 0 || node >= nr_node_ids) {
 		CDEBUG(D_INFO,
@@ -493,7 +584,10 @@ unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
 
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
