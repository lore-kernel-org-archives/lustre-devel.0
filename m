From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:22:05 -0400
Subject: [lustre-devel] [PATCH v2 25/25] staging: lustre: ptlrpc: use
 current CPU instead of hardcoded 0
In-Reply-To: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1527603725-30560-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

fix crash if CPU 0 disabled.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8710
Reviewed-on: https://review.whamcloud.com/23305
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
Changelog:

v1) New patch to address crash in ptlrpc

 drivers/staging/lustre/lustre/ptlrpc/service.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 3fd8c74..8e74a45 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -421,7 +421,7 @@ static void ptlrpc_at_timer(struct timer_list *t)
 		 * there are.
 		 */
 		/* weight is # of HTs */
-		if (cpumask_weight(topology_sibling_cpumask(0)) > 1) {
+		if (cpumask_weight(topology_sibling_cpumask(smp_processor_id())) > 1) {
 			/* depress thread factor for hyper-thread */
 			factor = factor - (factor >> 1) + (factor >> 3);
 		}
@@ -2221,15 +2221,16 @@ static int ptlrpc_hr_main(void *arg)
 	struct ptlrpc_hr_thread	*hrt = arg;
 	struct ptlrpc_hr_partition *hrp = hrt->hrt_partition;
 	LIST_HEAD(replies);
-	char threadname[20];
 	int rc;
 
-	snprintf(threadname, sizeof(threadname), "ptlrpc_hr%02d_%03d",
-		 hrp->hrp_cpt, hrt->hrt_id);
 	unshare_fs_struct();
 
 	rc = cfs_cpt_bind(ptlrpc_hr.hr_cpt_table, hrp->hrp_cpt);
 	if (rc != 0) {
+		char threadname[20];
+
+		snprintf(threadname, sizeof(threadname), "ptlrpc_hr%02d_%03d",
+			 hrp->hrp_cpt, hrt->hrt_id);
 		CWARN("Failed to bind %s on CPT %d of CPT table %p: rc = %d\n",
 		      threadname, hrp->hrp_cpt, ptlrpc_hr.hr_cpt_table, rc);
 	}
@@ -2528,7 +2529,7 @@ int ptlrpc_hr_init(void)
 
 	init_waitqueue_head(&ptlrpc_hr.hr_waitq);
 
-	weight = cpumask_weight(topology_sibling_cpumask(0));
+	weight = cpumask_weight(topology_sibling_cpumask(smp_processor_id()));
 
 	cfs_percpt_for_each(hrp, i, ptlrpc_hr.hr_partitions) {
 		hrp->hrp_cpt = i;
-- 
1.8.3.1
