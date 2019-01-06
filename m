From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 16:36:44 -0500
Subject: [lustre-devel] [PATCH 11/14] lustre: llite: conditionally set
 it_flags in ll_file_open
In-Reply-To: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
References: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546810607-6348-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

For ll_file_open the it->it_flags is always setting the
MDS_OPEN_LOCK bit but it should only be set when
lld_nfs_dentry is set.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index b390971..3647618 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -620,7 +620,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 			 * Always specify MDS_OPEN_BY_FID because we don't want
 			 * to get file with different fid.
 			 */
-			it->it_flags |= MDS_OPEN_LOCK | MDS_OPEN_BY_FID;
+			it->it_flags |= MDS_OPEN_BY_FID;
 			rc = ll_intent_file_open(file->f_path.dentry,
 						 NULL, 0, it);
 			if (rc)
-- 
1.8.3.1
