From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:20:26 -0400
Subject: [lustre-devel] [PATCH v3 02/26] staging: lustre: libcfs: rename
 variable i to cpu
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529875250-11531-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Dmitry Eremin <dmitry.eremin@intel.com>

Change the name of the variable i used for for_each_cpu() to cpu
for code readability.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23303
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index b363a3d..46d3530 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -344,7 +344,7 @@ struct cfs_cpt_table *
 cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt,
 		    const cpumask_t *mask)
 {
-	int i;
+	int cpu;
 
 	if (!cpumask_weight(mask) ||
 	    cpumask_any_and(mask, cpu_online_mask) >= nr_cpu_ids) {
@@ -353,8 +353,8 @@ struct cfs_cpt_table *
 		return 0;
 	}
 
-	for_each_cpu(i, mask) {
-		if (!cfs_cpt_set_cpu(cptab, cpt, i))
+	for_each_cpu(cpu, mask) {
+		if (!cfs_cpt_set_cpu(cptab, cpt, cpu))
 			return 0;
 	}
 
@@ -366,10 +366,10 @@ struct cfs_cpt_table *
 cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt,
 		      const cpumask_t *mask)
 {
-	int i;
+	int cpu;
 
-	for_each_cpu(i, mask)
-		cfs_cpt_unset_cpu(cptab, cpt, i);
+	for_each_cpu(cpu, mask)
+		cfs_cpt_unset_cpu(cptab, cpt, cpu);
 }
 EXPORT_SYMBOL(cfs_cpt_unset_cpumask);
 
-- 
1.8.3.1
