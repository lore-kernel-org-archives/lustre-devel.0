From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:09:49 -0400
Subject: [lustre-devel] [PATCH 07/25] staging: lustre: libcfs: NUMA support
In-Reply-To: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523851807-16573-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Amir Shehata <amir.shehata@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Amir Shehata <amir.shehata@intel.com>

This patch adds NUMA node support. NUMA node information is stored
in the CPT table. A NUMA node mask is maintained for the entire
table as well as for each CPT to track the NUMA nodes related to
each of the CPTs. Add new function cfs_cpt_of_node() which returns
the CPT of a particular NUMA node.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18916
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/libcfs/libcfs_cpu.h  |  4 ++++
 .../lustre/include/linux/libcfs/linux/linux-cpu.h     |  2 ++
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c       |  6 ++++++
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c  | 19 +++++++++++++++++++
 4 files changed, 31 insertions(+)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 070f8fe..839ec02 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -139,6 +139,10 @@ struct cfs_cpt_table {
  */
 int cfs_cpt_of_cpu(struct cfs_cpt_table *cptab, int cpu);
 /**
+ * shadow HW node ID \a NODE to CPU-partition ID by \a cptab
+ */
+int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node);
+/**
  * bind current thread on a CPU-partition \a cpt of \a cptab
  */
 int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt);
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
index e8bbbaa..1bed0ba 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
@@ -68,6 +68,8 @@ struct cfs_cpt_table {
 	int				*ctb_cpu2cpt;
 	/* all cpus in this partition table */
 	cpumask_var_t			ctb_cpumask;
+	/* shadow HW node to CPU partition ID */
+	int				*ctb_node2cpt;
 	/* all nodes in this partition table */
 	nodemask_t			*ctb_nodemask;
 };
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 5ea294f..e6d1512 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -198,6 +198,12 @@ cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
 }
 EXPORT_SYMBOL(cfs_cpt_of_cpu);
 
+int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
+{
+	return 0;
+}
+EXPORT_SYMBOL(cfs_cpt_of_node);
+
 int
 cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 {
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 741db69..fd0c451 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -70,6 +70,7 @@
 	int i;
 
 	kvfree(cptab->ctb_cpu2cpt);
+	kvfree(cptab->ctb_node2cpt);
 
 	for (i = 0; cptab->ctb_parts && i < cptab->ctb_nparts; i++) {
 		struct cfs_cpu_partition *part = &cptab->ctb_parts[i];
@@ -114,6 +115,15 @@ struct cfs_cpt_table *
 	memset(cptab->ctb_cpu2cpt, -1,
 	       nr_cpu_ids * sizeof(cptab->ctb_cpu2cpt[0]));
 
+	cptab->ctb_node2cpt = kvmalloc_array(nr_node_ids,
+					     sizeof(cptab->ctb_node2cpt[0]),
+					     GFP_KERNEL);
+	if (!cptab->ctb_node2cpt)
+		goto failed;
+
+	memset(cptab->ctb_node2cpt, -1,
+	       nr_node_ids * sizeof(cptab->ctb_node2cpt[0]));
+
 	cptab->ctb_parts = kvmalloc_array(ncpt, sizeof(cptab->ctb_parts[0]),
 					  GFP_KERNEL);
 	if (!cptab->ctb_parts)
@@ -484,6 +494,15 @@ struct cfs_cpt_table *
 }
 EXPORT_SYMBOL(cfs_cpt_of_cpu);
 
+int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
+{
+	if (node < 0 || node > nr_node_ids)
+		return CFS_CPT_ANY;
+
+	return cptab->ctb_node2cpt[node];
+}
+EXPORT_SYMBOL(cfs_cpt_of_node);
+
 int
 cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 {
-- 
1.8.3.1
