From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:20:39 -0400
Subject: [lustre-devel] [PATCH v3 15/26] staging: lustre: libcfs: rename i
 to cpu for cfs_cpt_bind
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529875250-11531-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Dmitry Eremin <dmitry.eremin@intel.com>

Rename variable i to cpu to make code easier to understand.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23222
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index a2c1068..5654fbe 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -673,8 +673,8 @@ int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 {
 	cpumask_var_t *cpumask;
 	nodemask_t *nodemask;
+	int cpu;
 	int rc;
-	int i;
 
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
@@ -692,8 +692,8 @@ int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 		return -EINVAL;
 	}
 
-	for_each_online_cpu(i) {
-		if (cpumask_test_cpu(i, *cpumask))
+	for_each_online_cpu(cpu) {
+		if (cpumask_test_cpu(cpu, *cpumask))
 			continue;
 
 		rc = set_cpus_allowed_ptr(current, *cpumask);
-- 
1.8.3.1
