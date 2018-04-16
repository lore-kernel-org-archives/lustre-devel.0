From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:09:46 -0400
Subject: [lustre-devel] [PATCH 04/25] staging: lustre: libcfs: replace
 MAX_NUMNODES with nr_node_ids
In-Reply-To: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523851807-16573-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Amir Shehata <amir.shehata@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Amir Shehata <amir.shehata@intel.com>

Replace depricated MAX_NUMNODES with nr_node_ids.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18916
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index d8c190c..d207ae5 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -368,7 +368,7 @@ struct cfs_cpt_table *
 {
 	const cpumask_t *mask;
 
-	if (node < 0 || node >= MAX_NUMNODES) {
+	if (node < 0 || node >= nr_node_ids) {
 		CDEBUG(D_INFO,
 		       "Invalid NUMA id %d for CPU partition %d\n", node, cpt);
 		return 0;
@@ -385,7 +385,7 @@ struct cfs_cpt_table *
 {
 	const cpumask_t *mask;
 
-	if (node < 0 || node >= MAX_NUMNODES) {
+	if (node < 0 || node >= nr_node_ids) {
 		CDEBUG(D_INFO,
 		       "Invalid NUMA id %d for CPU partition %d\n", node, cpt);
 		return;
@@ -809,7 +809,7 @@ struct cfs_cpt_table *
 		return cptab;
 	}
 
-	high = node ? MAX_NUMNODES - 1 : nr_cpu_ids - 1;
+	high = node ? nr_node_ids - 1 : nr_cpu_ids - 1;
 
 	for (str = strim(pattern), c = 0;; c++) {
 		struct cfs_range_expr *range;
-- 
1.8.3.1
