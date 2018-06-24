From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:20:41 -0400
Subject: [lustre-devel] [PATCH v3 17/26] staging: lustre: libcfs: update
 debug messages
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529875250-11531-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Dmitry Eremin <dmitry.eremin@intel.com>

For cfs_cpt_bind() change the CERROR to CDEBUG. Make the debug
message in cfs_cpt_table_create_pattern() more understandable.
Report rc value for when cfs_cpt_create_table() fails.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23222
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index fcb068a..ebfa4e3 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -484,7 +484,8 @@ void cfs_cpt_unset_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 		/* caller doesn't know the partition ID */
 		cpt = cptab->ctb_cpu2cpt[cpu];
 		if (cpt < 0) { /* not set in this CPT-table */
-			CDEBUG(D_INFO, "Try to unset cpu %d which is not in CPT-table %p\n",
+			CDEBUG(D_INFO,
+			       "Try to unset cpu %d which is not in CPT-table %p\n",
 			       cpt, cptab);
 			return;
 		}
@@ -510,7 +511,8 @@ int cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt,
 
 	if (!cpumask_weight(mask) ||
 	    cpumask_any_and(mask, cpu_online_mask) >= nr_cpu_ids) {
-		CDEBUG(D_INFO, "No online CPU is found in the CPU mask for CPU partition %d\n",
+		CDEBUG(D_INFO,
+		       "No online CPU is found in the CPU mask for CPU partition %d\n",
 		       cpt);
 		return 0;
 	}
@@ -687,7 +689,8 @@ int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 	}
 
 	if (cpumask_any_and(*cpumask, cpu_online_mask) >= nr_cpu_ids) {
-		CERROR("No online CPU found in CPU partition %d, did someone do CPU hotplug on system? You might need to reload Lustre modules to keep system working well.\n",
+		CDEBUG(D_INFO,
+		       "No online CPU found in CPU partition %d, did someone do CPU hotplug on system? You might need to reload Lustre modules to keep system working well.\n",
 		       cpt);
 		return -EINVAL;
 	}
@@ -918,8 +921,8 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 failed_mask:
 	free_cpumask_var(node_mask);
 failed:
-	CERROR("Failed to setup CPU-partition-table with %d CPU-partitions, online HW nodes: %d, HW cpus: %d.\n",
-	       ncpt, num_online_nodes(), num_online_cpus());
+	CERROR("Failed (rc = %d) to setup CPU partition table with %d partitions, online HW NUMA nodes: %d, HW CPU cores: %d.\n",
+	       rc, ncpt, num_online_nodes(), num_online_cpus());
 
 	if (cptab)
 		cfs_cpt_table_free(cptab);
@@ -1034,7 +1037,7 @@ static struct cfs_cpt_table *cfs_cpt_table_create_pattern(char *pattern)
 
 		bracket = strchr(str, ']');
 		if (!bracket) {
-			CERROR("missing right bracket for cpt %d, %s\n",
+			CERROR("Missing right bracket for partition %d, %s\n",
 			       cpt, str);
 			goto failed;
 		}
-- 
1.8.3.1
