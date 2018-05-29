From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:21:48 -0400
Subject: [lustre-devel] [PATCH v2 08/25] staging: lustre: libcfs: NUMA
 support
In-Reply-To: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1527603725-30560-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <jsimmons@infradead.org>

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
Changelog:

v1) Initial patch
v2) Rebased patch to handle recent libcfs changes

 .../lustre/include/linux/libcfs/libcfs_cpu.h        | 11 +++++++++++
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c     | 21 +++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 3626969..487625d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -103,6 +103,8 @@ struct cfs_cpt_table {
 	struct cfs_cpu_partition	*ctb_parts;
 	/* shadow HW CPU to CPU partition ID */
 	int				*ctb_cpu2cpt;
+	/* shadow HW node to CPU partition ID */
+	int				*ctb_node2cpt;
 	/* all nodes in this partition table */
 	nodemask_t			*ctb_nodemask;
 #else
@@ -157,6 +159,10 @@ struct cfs_cpt_table {
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
@@ -345,6 +351,11 @@ static inline int cfs_cpt_table_print(struct cfs_cpt_table *cptab,
 	return 0;
 }
 
+static inline int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
+{
+	return 0;
+}
+
 static inline int
 cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 {
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 3f855a8..f616073 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -98,6 +98,15 @@ struct cfs_cpt_table *
 	memset(cptab->ctb_cpu2cpt, -1,
 	       nr_cpu_ids * sizeof(cptab->ctb_cpu2cpt[0]));
 
+	cptab->ctb_node2cpt = kvmalloc_array(nr_node_ids,
+					     sizeof(cptab->ctb_node2cpt[0]),
+					     GFP_KERNEL);
+	if (!cptab->ctb_node2cpt)
+		goto failed_alloc_node2cpt;
+
+	memset(cptab->ctb_node2cpt, -1,
+	       nr_node_ids * sizeof(cptab->ctb_node2cpt[0]));
+
 	cptab->ctb_parts = kvmalloc_array(ncpt, sizeof(cptab->ctb_parts[0]),
 					  GFP_KERNEL);
 	if (!cptab->ctb_parts)
@@ -129,6 +138,8 @@ struct cfs_cpt_table *
 
 	kvfree(cptab->ctb_parts);
 failed_alloc_ctb_parts:
+	kvfree(cptab->ctb_node2cpt);
+failed_alloc_node2cpt:
 	kvfree(cptab->ctb_cpu2cpt);
 failed_alloc_cpu2cpt:
 	kfree(cptab->ctb_nodemask);
@@ -146,6 +157,7 @@ struct cfs_cpt_table *
 	int i;
 
 	kvfree(cptab->ctb_cpu2cpt);
+	kvfree(cptab->ctb_node2cpt);
 
 	for (i = 0; cptab->ctb_parts && i < cptab->ctb_nparts; i++) {
 		struct cfs_cpu_partition *part = &cptab->ctb_parts[i];
@@ -511,6 +523,15 @@ struct cfs_cpt_table *
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
