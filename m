From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:50 -0400
Subject: [lustre-devel] [PATCH 051/124] staging: lustre: llite: ensure all
	data flush out when umount
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-52-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Yang Sheng <yang.sheng@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Yang Sheng <yang.sheng@intel.com>

Write out all extents when clear inode. Otherwise we
may lose data while umount.

Signed-off-by: Yang Sheng <yang.sheng@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5584
Reviewed-on: http://review.whamcloud.com/12103
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c |   15 ++++-----------
 1 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 2aab396..5792354 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1909,20 +1909,13 @@ void ll_delete_inode(struct inode *inode)
 		 * osc_extent implementation at LU-1030.
 		 */
 		cl_sync_file_range(inode, 0, OBD_OBJECT_EOF,
-				   CL_FSYNC_DISCARD, 1);
+				   CL_FSYNC_LOCAL, 1);
 
 	truncate_inode_pages_final(&inode->i_data);
 
-	/* Workaround for LU-118 */
-	if (inode->i_data.nrpages) {
-		spin_lock_irq(&inode->i_data.tree_lock);
-		spin_unlock_irq(&inode->i_data.tree_lock);
-		LASSERTF(inode->i_data.nrpages == 0,
-			 "inode="DFID"(%p) nrpages=%lu, see http://jira.whamcloud.com/browse/LU-118\n",
-			 PFID(ll_inode2fid(inode)), inode,
-			 inode->i_data.nrpages);
-	}
-	/* Workaround end */
+	LASSERTF(!inode->i_data.nrpages,
+		 "inode=" DFID "(%p) nrpages=%lu, see http://jira.whamcloud.com/browse/LU-118\n",
+		 PFID(ll_inode2fid(inode)), inode, inode->i_data.nrpages);
 
 	ll_clear_inode(inode);
 	clear_inode(inode);
-- 
1.7.1
