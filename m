From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:11 -0400
Subject: [lustre-devel] [PATCH 30/37] lustre: llite: annotate non-owner
 locking
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-31-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

The lli_lsm_sem locks taken by ll_prep_md_op_data() are sometimes
released by a different thread.  This confuses lockdep unless we
explain the situation.

So use down_read_non_owner() and up_read_non_owner().

WC-bug-id: https://jira.whamcloud.com/browse/LU-9679
Lustre-commit: f34392412fe22 ("LU-9679 llite: annotate non-owner locking")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39234
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index c62e182..f52d2b5 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2783,12 +2783,12 @@ int ll_obd_statfs(struct inode *inode, void __user *arg)
 void ll_unlock_md_op_lsm(struct md_op_data *op_data)
 {
 	if (op_data->op_mea2_sem) {
-		up_read(op_data->op_mea2_sem);
+		up_read_non_owner(op_data->op_mea2_sem);
 		op_data->op_mea2_sem = NULL;
 	}
 
 	if (op_data->op_mea1_sem) {
-		up_read(op_data->op_mea1_sem);
+		up_read_non_owner(op_data->op_mea1_sem);
 		op_data->op_mea1_sem = NULL;
 	}
 }
@@ -2823,7 +2823,7 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 	op_data->op_code = opc;
 
 	if (S_ISDIR(i1->i_mode)) {
-		down_read(&ll_i2info(i1)->lli_lsm_sem);
+		down_read_non_owner(&ll_i2info(i1)->lli_lsm_sem);
 		op_data->op_mea1_sem = &ll_i2info(i1)->lli_lsm_sem;
 		op_data->op_mea1 = ll_i2info(i1)->lli_lsm_md;
 		op_data->op_default_mea1 = ll_i2info(i1)->lli_default_lsm_md;
@@ -2833,7 +2833,10 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 		op_data->op_fid2 = *ll_inode2fid(i2);
 		if (S_ISDIR(i2->i_mode)) {
 			if (i2 != i1) {
-				down_read(&ll_i2info(i2)->lli_lsm_sem);
+				/* i2 is typically a child of i1, and MUST be
+				 * further from the root to avoid deadlocks.
+				 */
+				down_read_non_owner(&ll_i2info(i2)->lli_lsm_sem);
 				op_data->op_mea2_sem =
 						&ll_i2info(i2)->lli_lsm_sem;
 			}
-- 
1.8.3.1
