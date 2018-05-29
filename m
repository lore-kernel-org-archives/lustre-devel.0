From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:22:00 -0400
Subject: [lustre-devel] [PATCH v2 20/25] staging: lustre: libcfs: make
 tolerant to offline CPUs and empty NUMA nodes
In-Reply-To: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1527603725-30560-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Rework CPU partition code in the way of make it more tolerant to
offline CPUs and empty nodes.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23222
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
Changelog:

v1) Initial patch
v2) Rebased patch. No changes in code from earlier patch

 .../lustre/include/linux/libcfs/libcfs_cpu.h       |   2 +
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    | 132 +++++++++------------
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   2 +
 3 files changed, 60 insertions(+), 76 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 9f4ba9d..c0aa0b3 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -91,6 +91,8 @@ struct cfs_cpu_partition {
 	unsigned int			*cpt_distance;
 	/* spread rotor for NUMA allocator */
 	int				cpt_spread_rotor;
+	/* NUMA node if cpt_nodemask is empty */
+	int				cpt_node;
 };
 #endif /* CONFIG_SMP */
 
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 7f1061e..99a9494 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -457,8 +457,16 @@ int cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
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
@@ -527,8 +535,10 @@ void cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt,
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
 
@@ -579,10 +589,8 @@ int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt,
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
@@ -603,7 +611,7 @@ int cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
 	nodemask_t *mask;
 	int weight;
 	int rotor;
-	int node;
+	int node = 0;
 
 	/* convert CPU partition ID to HW node id */
 
@@ -613,20 +621,20 @@ int cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
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
 
@@ -719,17 +727,21 @@ static int cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
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
@@ -750,24 +762,19 @@ static int cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
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
@@ -836,23 +843,18 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
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
@@ -861,55 +863,33 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
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
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 0091273..27bdefa 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -568,6 +568,8 @@
 
 	/* number of CPUs */
 	container->msc_nfinalizers = cfs_cpt_weight(lnet_cpt_table(), cpt);
+	if (container->msc_nfinalizers == 0)
+		container->msc_nfinalizers = 1;
 
 	container->msc_finalizers = kvzalloc_cpt(container->msc_nfinalizers *
 						 sizeof(*container->msc_finalizers),
-- 
1.8.3.1
