From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:21:55 -0400
Subject: [lustre-devel] [PATCH v2 15/25] staging: lustre: libcfs: rename i
 to node for cfs_cpt_set_nodemask
In-Reply-To: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1527603725-30560-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Rename variable i to node to make code easier to understand.

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

 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 14d5791..bac5601 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -575,10 +575,10 @@ void cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
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
 
@@ -589,10 +589,10 @@ int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt,
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
