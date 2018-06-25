From: Doug Oucharek <doucharek@cray.com>
Date: Mon, 25 Jun 2018 18:22:59 +0000
Subject: [lustre-devel] [PATCH v3 07/26] staging: lustre: libcfs: NUMA
 support
In-Reply-To: <877emnaed8.fsf@notabene.neil.brown.name>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
 <1529875250-11531-8-git-send-email-jsimmons@infradead.org>
 <877emnaed8.fsf@notabene.neil.brown.name>
Message-ID: <A764DED1-A9A8-4FA5-A0F1-922C3E2D822A@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Some background on this NUMA change:

First off, this is just a first step to a bigger set of changes which include changes to the Lustre utilities.  This was done as part of the Multi-Rail feature.  One of the systems that feature is meant to support is the SGI UV system (now HPE) which has a massive number of NUMA nodes connected by a NUMA Link.  There are multiple fabric cards spread throughout the system and Multi-Rail needs to know which fabric cards are nearest to the NUMA node we are running on.  To do that, the ?distance? between NUMA nodes needs to be configured.

This patch is preparing the infrastructure for the Multi-Rail feature to support configuring NUMA node distances.  Technically, this patch should be landing with the Multi-Rail feature (still to be pushed) for it to make proper sense.

Doug

On Jun 24, 2018, at 5:39 PM, NeilBrown <neilb at suse.com<mailto:neilb@suse.com>> wrote:

On Sun, Jun 24 2018, James Simmons wrote:

From: Amir Shehata <amir.shehata at intel.com<mailto:amir.shehata@intel.com>>

This patch adds NUMA node support. NUMA node information is stored
in the CPT table. A NUMA node mask is maintained for the entire
table as well as for each CPT to track the NUMA nodes related to
each of the CPTs. Add new function cfs_cpt_of_node() which returns
the CPT of a particular NUMA node.

I note that you didn't respond to Greg's questions about this patch.
I'll accept it anyway in the interests of moving forward, but I think
his comments were probably valid, and need to be considered at some
stage.

There is a bug though....

Signed-off-by: Amir Shehata <amir.shehata at intel.com<mailto:amir.shehata@intel.com>>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18916
Reviewed-by: Olaf Weber <olaf at sgi.com<mailto:olaf@sgi.com>>
Reviewed-by: Doug Oucharek <dougso at me.com<mailto:dougso@me.com>>
Signed-off-by: James Simmons <jsimmons at infradead.org<mailto:jsimmons@infradead.org>>
---
.../lustre/include/linux/libcfs/libcfs_cpu.h        | 11 +++++++++++
drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c     | 21 +++++++++++++++++++++
2 files changed, 32 insertions(+)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 1b4333d..ff3ecf5 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -103,6 +103,8 @@ struct cfs_cpt_table {
int *ctb_cpu2cpt;
/* all cpus in this partition table */
cpumask_var_t ctb_cpumask;
+ /* shadow HW node to CPU partition ID */
+ int *ctb_node2cpt;
/* all nodes in this partition table */
nodemask_t *ctb_nodemask;
};
@@ -143,6 +145,10 @@ struct cfs_cpt_table {
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
@@ -299,6 +305,11 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
return 0;
}

+static inline int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
+{
+ return 0;
+}
+
static inline int
cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
{
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 33294da..8c5cf7b 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -102,6 +102,15 @@ struct cfs_cpt_table *
memset(cptab->ctb_cpu2cpt, -1,
       nr_cpu_ids * sizeof(cptab->ctb_cpu2cpt[0]));

+ cptab->ctb_node2cpt = kvmalloc_array(nr_node_ids,
+      sizeof(cptab->ctb_node2cpt[0]),
+      GFP_KERNEL);
+ if (!cptab->ctb_node2cpt)
+ goto failed_alloc_node2cpt;
+
+ memset(cptab->ctb_node2cpt, -1,
+        nr_node_ids * sizeof(cptab->ctb_node2cpt[0]));
+
cptab->ctb_parts = kvmalloc_array(ncpt, sizeof(cptab->ctb_parts[0]),
  GFP_KERNEL);
if (!cptab->ctb_parts)
@@ -133,6 +142,8 @@ struct cfs_cpt_table *

kvfree(cptab->ctb_parts);
failed_alloc_ctb_parts:
+ kvfree(cptab->ctb_node2cpt);
+failed_alloc_node2cpt:
kvfree(cptab->ctb_cpu2cpt);
failed_alloc_cpu2cpt:
kfree(cptab->ctb_nodemask);
@@ -150,6 +161,7 @@ struct cfs_cpt_table *
int i;

kvfree(cptab->ctb_cpu2cpt);
+ kvfree(cptab->ctb_node2cpt);

for (i = 0; cptab->ctb_parts && i < cptab->ctb_nparts; i++) {
struct cfs_cpu_partition *part = &cptab->ctb_parts[i];
@@ -515,6 +527,15 @@ struct cfs_cpt_table *
}
EXPORT_SYMBOL(cfs_cpt_of_cpu);

+int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node)
+{
+ if (node < 0 || node > nr_node_ids)
+ return CFS_CPT_ANY;
+
+ return cptab->ctb_node2cpt[node];
+}

So if node == nr_node_ids, we access beyond the end of the ctb_node2cpt array.
Oops.
I've fixed this before applying.

Thanks,
NeilBrown


+EXPORT_SYMBOL(cfs_cpt_of_node);
+
int
cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
{
--
1.8.3.1
_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180625/7c60ef32/attachment-0001.html>
