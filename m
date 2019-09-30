From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:41 -0400
Subject: [lustre-devel] [PATCH 022/151] lustre: llite: NULL pointer
 dereference in cl_object_top()
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

During race condition iget5_locked() returns inode without
I_NEW bit for the second thread. If cl_file_inode_init()
failed for the first thread lli_clob isn't valid for
corresponding fid.

But failed inode is marked bad, check it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6436
Seagate-bug-id: MRP-4035
Lustre-commit: 13c8d5e4bebf ("LU-6436 llite: NULL pointer dereference in cl_object_top()")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/27777
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/namei.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index caa759f..9c9acf2 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -133,6 +133,9 @@ struct inode *ll_iget(struct super_block *sb, ino_t hash,
 			inode_has_no_xattr(inode);
 			unlock_new_inode(inode);
 		}
+	} else if (is_bad_inode(inode)) {
+		iput(inode);
+		inode = ERR_PTR(-ESTALE);
 	} else if (!(inode->i_state & (I_FREEING | I_CLEAR))) {
 		rc = ll_update_inode(inode, md);
 		CDEBUG(D_VFSTRACE, "got inode: " DFID "(%p): rc = %d\n",
-- 
1.8.3.1
