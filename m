From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:35 -0400
Subject: [lustre-devel] [PATCH 25/30] lustre: llite: check the return value
 of cl_file_inode_init()
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

ll_update_inode() does not check the return value of
cl_file_inode_init(), and it should check.

Signed-off-by: Bobi Jam <bobijam@hotmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9485
Reviewed-on: https://review.whamcloud.com/27658
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index b5bafc4..99d0b72 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1792,13 +1792,15 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct mdt_body *body = md->body;
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	int rc = 0;
 
-	if (body->mbo_valid & OBD_MD_FLEASIZE)
-		cl_file_inode_init(inode, md);
+	if (body->mbo_valid & OBD_MD_FLEASIZE) {
+		rc = cl_file_inode_init(inode, md);
+		if (rc)
+			return rc;
+	}
 
 	if (S_ISDIR(inode->i_mode)) {
-		int rc;
-
 		rc = ll_update_lsm_md(inode, md);
 		if (rc)
 			return rc;
-- 
1.8.3.1
