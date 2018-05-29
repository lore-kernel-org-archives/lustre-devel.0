From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:21:45 -0400
Subject: [lustre-devel] [PATCH v2 05/25] staging: lustre: libcfs: replace
 MAX_NUMNODES with nr_node_ids
In-Reply-To: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1527603725-30560-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

Replace MAX_NUMNODES which is considered deprocated with
nr_nodes_ids. Looking at page_malloc.c you will see that
nr_nodes_ids is equal to MAX_NUMNODES. MAX_NUMNODES is
actually setup with Kconfig.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18916
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
Changelog:

v1) Initial patch
v2) Same code but added in more details in commit message

 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index b67a60c..d3017e8 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -395,7 +395,7 @@ struct cfs_cpt_table *
 {
 	const cpumask_t *mask;
 
-	if (node < 0 || node >= MAX_NUMNODES) {
+	if (node < 0 || node >= nr_node_ids) {
 		CDEBUG(D_INFO,
 		       "Invalid NUMA id %d for CPU partition %d\n", node, cpt);
 		return 0;
@@ -412,7 +412,7 @@ struct cfs_cpt_table *
 {
 	const cpumask_t *mask;
 
-	if (node < 0 || node >= MAX_NUMNODES) {
+	if (node < 0 || node >= nr_node_ids) {
 		CDEBUG(D_INFO,
 		       "Invalid NUMA id %d for CPU partition %d\n", node, cpt);
 		return;
@@ -836,7 +836,7 @@ struct cfs_cpt_table *
 		return cptab;
 	}
 
-	high = node ? MAX_NUMNODES - 1 : nr_cpu_ids - 1;
+	high = node ? nr_node_ids - 1 : nr_cpu_ids - 1;
 
 	for (str = strim(pattern), c = 0;; c++) {
 		struct cfs_range_expr *range;
-- 
1.8.3.1
