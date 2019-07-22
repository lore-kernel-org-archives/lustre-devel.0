From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:23:49 -0400
Subject: [lustre-devel] [PATCH 20/22] ext4: use GFP_NOFS in
 ext4_inode_attach_jinode
In-Reply-To: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563758631-29550-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/ext4/inode.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index bf00dfc..ca72097 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4422,7 +4422,7 @@ int ext4_inode_attach_jinode(struct inode *inode)
 	if (ei->jinode || !EXT4_SB(inode->i_sb)->s_journal)
 		return 0;
 
-	jinode = jbd2_alloc_inode(GFP_KERNEL);
+	jinode = jbd2_alloc_inode(GFP_NOFS);
 	spin_lock(&inode->i_lock);
 	if (!ei->jinode) {
 		if (!jinode) {
-- 
1.8.3.1
