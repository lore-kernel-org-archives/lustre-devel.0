From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:09:44 -0400
Subject: [lustre-devel] [PATCH 02/25] staging: lustre: libcfs: rename
 variable i to cpu
In-Reply-To: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523851807-16573-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Dmitry Eremin <dmitry.eremin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Change the name of the variable i used for for_each_cpu() to cpu
for code readability.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23303
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 134b239..d8c190c 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -334,7 +334,7 @@ struct cfs_cpt_table *
 int
 cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt, const cpumask_t *mask)
 {
-	int i;
+	int cpu;
 
 	if (!cpumask_weight(mask) ||
 	    cpumask_any_and(mask, cpu_online_mask) >= nr_cpu_ids) {
@@ -343,8 +343,8 @@ struct cfs_cpt_table *
 		return 0;
 	}
 
-	for_each_cpu(i, mask) {
-		if (!cfs_cpt_set_cpu(cptab, cpt, i))
+	for_each_cpu(cpu, mask) {
+		if (!cfs_cpt_set_cpu(cptab, cpt, cpu))
 			return 0;
 	}
 
@@ -356,10 +356,10 @@ struct cfs_cpt_table *
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
