From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:40 -0400
Subject: [lustre-devel] [PATCH 101/124] staging: lustre: libcfs: check mask
	returned by cpumask_of_node
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-102-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>, James Simmons <jsimmons@infradead.org>

From: Liang Zhen <liang.zhen@intel.com>

cpumask_of_node can return NULL if NUMA node is unavailable,
in this case cfs_node_to_cpumask will try to copy from NULL
and cause kernel panic.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5751
Reviewed-on: http://review.whamcloud.com/13207
Reviewed-by: Li Wei <wei.g.li@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index b52518c..e8b1a61 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -74,6 +74,17 @@ struct cfs_cpt_data {
 
 static struct cfs_cpt_data	cpt_data;
 
+static void
+cfs_node_to_cpumask(int node, cpumask_t *mask)
+{
+	const cpumask_t *tmp = cpumask_of_node(node);
+
+	if (tmp)
+		cpumask_copy(mask, tmp);
+	else
+		cpumask_clear(mask);
+}
+
 void
 cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 {
@@ -403,7 +414,7 @@ cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt, int node)
 	mutex_lock(&cpt_data.cpt_mutex);
 
 	mask = cpt_data.cpt_cpumask;
-	cpumask_copy(mask, cpumask_of_node(node));
+	cfs_node_to_cpumask(node, mask);
 
 	rc = cfs_cpt_set_cpumask(cptab, cpt, mask);
 
@@ -427,7 +438,7 @@ cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
 	mutex_lock(&cpt_data.cpt_mutex);
 
 	mask = cpt_data.cpt_cpumask;
-	cpumask_copy(mask, cpumask_of_node(node));
+	cfs_node_to_cpumask(node, mask);
 
 	cfs_cpt_unset_cpumask(cptab, cpt, mask);
 
@@ -749,7 +760,7 @@ cfs_cpt_table_create(int ncpt)
 	}
 
 	for_each_online_node(i) {
-		cpumask_copy(mask, cpumask_of_node(i));
+		cfs_node_to_cpumask(i, mask);
 
 		while (!cpumask_empty(mask)) {
 			struct cfs_cpu_partition *part;
-- 
1.7.1
