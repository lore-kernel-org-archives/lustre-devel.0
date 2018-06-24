From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:20:40 -0400
Subject: [lustre-devel] [PATCH v3 16/26] staging: lustre: libcfs: rename
 cpumask_var_t variables to *_mask
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529875250-11531-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Dmitry Eremin <dmitry.eremin@intel.com>

Because we handle both cpu mask as well as core identifiers it can
easily be confused. To avoid this rename various cpumask_var_t to
have appended *_mask to their names.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23222
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 62 ++++++++++++-------------
 1 file changed, 31 insertions(+), 31 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 5654fbe..fcb068a 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -714,23 +714,23 @@ int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
  * We always prefer to choose CPU in the same core/socket.
  */
 static int cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
-				cpumask_t *node, int number)
+				cpumask_t *node_mask, int number)
 {
-	cpumask_var_t socket;
-	cpumask_var_t core;
+	cpumask_var_t socket_mask;
+	cpumask_var_t core_mask;
 	int rc = 0;
 	int cpu;
 
 	LASSERT(number > 0);
 
-	if (number >= cpumask_weight(node)) {
-		while (!cpumask_empty(node)) {
-			cpu = cpumask_first(node);
+	if (number >= cpumask_weight(node_mask)) {
+		while (!cpumask_empty(node_mask)) {
+			cpu = cpumask_first(node_mask);
 
 			rc = cfs_cpt_set_cpu(cptab, cpt, cpu);
 			if (!rc)
 				return -EINVAL;
-			cpumask_clear_cpu(cpu, node);
+			cpumask_clear_cpu(cpu, node_mask);
 		}
 		return 0;
 	}
@@ -740,34 +740,34 @@ static int cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
 	 * As we cannot initialize a cpumask_var_t, we need
 	 * to alloc both before we can risk trying to free either
 	 */
-	if (!zalloc_cpumask_var(&socket, GFP_NOFS))
+	if (!zalloc_cpumask_var(&socket_mask, GFP_NOFS))
 		rc = -ENOMEM;
-	if (!zalloc_cpumask_var(&core, GFP_NOFS))
+	if (!zalloc_cpumask_var(&core_mask, GFP_NOFS))
 		rc = -ENOMEM;
 	if (rc)
 		goto out;
 
-	while (!cpumask_empty(node)) {
-		cpu = cpumask_first(node);
+	while (!cpumask_empty(node_mask)) {
+		cpu = cpumask_first(node_mask);
 
 		/* get cpumask for cores in the same socket */
-		cpumask_copy(socket, topology_core_cpumask(cpu));
-		cpumask_and(socket, socket, node);
+		cpumask_copy(socket_mask, topology_core_cpumask(cpu));
+		cpumask_and(socket_mask, socket_mask, node_mask);
 
-		LASSERT(!cpumask_empty(socket));
+		LASSERT(!cpumask_empty(socket_mask));
 
-		while (!cpumask_empty(socket)) {
+		while (!cpumask_empty(socket_mask)) {
 			int i;
 
 			/* get cpumask for hts in the same core */
-			cpumask_copy(core, topology_sibling_cpumask(cpu));
-			cpumask_and(core, core, node);
+			cpumask_copy(core_mask, topology_sibling_cpumask(cpu));
+			cpumask_and(core_mask, core_mask, node_mask);
 
-			LASSERT(!cpumask_empty(core));
+			LASSERT(!cpumask_empty(core_mask));
 
-			for_each_cpu(i, core) {
-				cpumask_clear_cpu(i, socket);
-				cpumask_clear_cpu(i, node);
+			for_each_cpu(i, core_mask) {
+				cpumask_clear_cpu(i, socket_mask);
+				cpumask_clear_cpu(i, node_mask);
 
 				rc = cfs_cpt_set_cpu(cptab, cpt, i);
 				if (!rc) {
@@ -778,13 +778,13 @@ static int cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
 				if (!--number)
 					goto out;
 			}
-			cpu = cpumask_first(socket);
+			cpu = cpumask_first(socket_mask);
 		}
 	}
 
 out:
-	free_cpumask_var(socket);
-	free_cpumask_var(core);
+	free_cpumask_var(socket_mask);
+	free_cpumask_var(core_mask);
 	return rc;
 }
 
@@ -835,7 +835,7 @@ static int cfs_cpt_num_estimate(void)
 static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 {
 	struct cfs_cpt_table *cptab = NULL;
-	cpumask_var_t mask;
+	cpumask_var_t node_mask;
 	int cpt = 0;
 	int num;
 	int rc;
@@ -868,15 +868,15 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 		goto failed;
 	}
 
-	if (!zalloc_cpumask_var(&mask, GFP_NOFS)) {
+	if (!zalloc_cpumask_var(&node_mask, GFP_NOFS)) {
 		CERROR("Failed to allocate scratch cpumask\n");
 		goto failed;
 	}
 
 	for_each_online_node(i) {
-		cpumask_copy(mask, cpumask_of_node(i));
+		cpumask_copy(node_mask, cpumask_of_node(i));
 
-		while (!cpumask_empty(mask)) {
+		while (!cpumask_empty(node_mask)) {
 			struct cfs_cpu_partition *part;
 			int n;
 
@@ -893,7 +893,7 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 			n = num - cpumask_weight(part->cpt_cpumask);
 			LASSERT(n > 0);
 
-			rc = cfs_cpt_choose_ncpus(cptab, cpt, mask, n);
+			rc = cfs_cpt_choose_ncpus(cptab, cpt, node_mask, n);
 			if (rc < 0)
 				goto failed_mask;
 
@@ -911,12 +911,12 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 		goto failed_mask;
 	}
 
-	free_cpumask_var(mask);
+	free_cpumask_var(node_mask);
 
 	return cptab;
 
 failed_mask:
-	free_cpumask_var(mask);
+	free_cpumask_var(node_mask);
 failed:
 	CERROR("Failed to setup CPU-partition-table with %d CPU-partitions, online HW nodes: %d, HW cpus: %d.\n",
 	       ncpt, num_online_nodes(), num_online_cpus());
-- 
1.8.3.1
