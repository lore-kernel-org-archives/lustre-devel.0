From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:20:38 -0400
Subject: [lustre-devel] [PATCH v3 14/26] staging: lustre: libcfs: rename i
 to node for cfs_cpt_set_nodemask
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529875250-11531-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Dmitry Eremin <dmitry.eremin@intel.com>

Rename variable i to node to make code easier to understand.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23222
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 8f7de59..a2c1068 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -579,10 +579,10 @@ void cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
 int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt,
 			 const nodemask_t *mask)
 {
-	int i;
+	int node;
 
-	for_each_node_mask(i, *mask) {
-		if (!cfs_cpt_set_node(cptab, cpt, i))
+	for_each_node_mask(node, *mask) {
+		if (!cfs_cpt_set_node(cptab, cpt, node))
 			return 0;
 	}
 
@@ -593,10 +593,10 @@ int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt,
 void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab, int cpt,
 			    const nodemask_t *mask)
 {
-	int i;
+	int node;
 
-	for_each_node_mask(i, *mask)
-		cfs_cpt_unset_node(cptab, cpt, i);
+	for_each_node_mask(node, *mask)
+		cfs_cpt_unset_node(cptab, cpt, node);
 }
 EXPORT_SYMBOL(cfs_cpt_unset_nodemask);
 
-- 
1.8.3.1
