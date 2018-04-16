From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:09:56 -0400
Subject: [lustre-devel] [PATCH 14/25] staging: lustre: libcfs: rename i to
 node for cfs_cpt_set_nodemask
In-Reply-To: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523851807-16573-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Dmitry Eremin <dmitry.eremin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

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
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 1669669..5f2ab30 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -550,10 +550,10 @@ void cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node)
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
 
@@ -564,10 +564,10 @@ int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt,
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
