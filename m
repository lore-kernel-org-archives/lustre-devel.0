From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:20:28 -0400
Subject: [lustre-devel] [PATCH v3 04/26] staging: lustre: libcfs: replace
 MAX_NUMNODES with nr_node_ids
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529875250-11531-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

Replace MAX_NUMNODES which is considered deprocated with
nr_nodes_ids. Looking at page_malloc.c you will see that
nr_nodes_ids is equal to MAX_NUMNODES. MAX_NUMNODES is
actually setup with Kconfig.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18916
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index bdd71a3..ea8d55c 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -399,7 +399,7 @@ struct cfs_cpt_table *
 {
 	const cpumask_t *mask;
 
-	if (node < 0 || node >= MAX_NUMNODES) {
+	if (node < 0 || node >= nr_node_ids) {
 		CDEBUG(D_INFO,
 		       "Invalid NUMA id %d for CPU partition %d\n", node, cpt);
 		return 0;
@@ -416,7 +416,7 @@ struct cfs_cpt_table *
 {
 	const cpumask_t *mask;
 
-	if (node < 0 || node >= MAX_NUMNODES) {
+	if (node < 0 || node >= nr_node_ids) {
 		CDEBUG(D_INFO,
 		       "Invalid NUMA id %d for CPU partition %d\n", node, cpt);
 		return;
@@ -840,7 +840,7 @@ struct cfs_cpt_table *
 		return cptab;
 	}
 
-	high = node ? MAX_NUMNODES - 1 : nr_cpu_ids - 1;
+	high = node ? nr_node_ids - 1 : nr_cpu_ids - 1;
 
 	for (str = strim(pattern), c = 0;; c++) {
 		struct cfs_range_expr *range;
-- 
1.8.3.1
