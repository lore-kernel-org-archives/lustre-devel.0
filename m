From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:21:56 -0400
Subject: [lustre-devel] [PATCH v2 16/25] staging: lustre: libcfs: rename i
 to cpu for cfs_cpt_bind
In-Reply-To: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1527603725-30560-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Rename variable i to cpu to make code easier to understand.

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
v2) Rebased patch. No changes in code

 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index bac5601..1c10529 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -669,8 +669,8 @@ int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 {
 	cpumask_var_t *cpumask;
 	nodemask_t *nodemask;
+	int cpu;
 	int rc;
-	int i;
 
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
@@ -688,8 +688,8 @@ int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
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
