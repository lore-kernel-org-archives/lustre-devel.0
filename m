From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Dec 2017 10:01:47 +1100
Subject: [lustre-devel] [PATCH 2/2] staging: lustre: disable preempt while
 sampling processor id.
In-Reply-To: <151363798156.11899.768707943431676479.stgit@noble>
References: <151363798156.11899.768707943431676479.stgit@noble>
Message-ID: <151363810776.11899.1696679196545013564.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Calling smp_processor_id() without disabling preemption
triggers a warning (if CONFIG_DEBUG_PREEMPT).
I think the result of cfs_cpt_current() is only used as a hint for
load balancing, rather than as a precise and stable indicator of
the current CPU.  So it doesn't need to be called with
preemption disabled.

So disable preemption inside cfs_cpt_current() to silence the warning.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index d30650f8dcb4..ca8518b8a3e0 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -517,19 +517,20 @@ EXPORT_SYMBOL(cfs_cpt_spread_node);
 int
 cfs_cpt_current(struct cfs_cpt_table *cptab, int remap)
 {
-	int cpu = smp_processor_id();
-	int cpt = cptab->ctb_cpu2cpt[cpu];
+	int cpu;
+	int cpt;
 
-	if (cpt < 0) {
-		if (!remap)
-			return cpt;
+	preempt_disable();
+	cpu = smp_processor_id();
+	cpt = cptab->ctb_cpu2cpt[cpu];
 
+	if (cpt < 0 && remap) {
 		/* don't return negative value for safety of upper layer,
 		 * instead we shadow the unknown cpu to a valid partition ID
 		 */
 		cpt = cpu % cptab->ctb_nparts;
 	}
-
+	preempt_enable();
 	return cpt;
 }
 EXPORT_SYMBOL(cfs_cpt_current);
