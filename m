From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:58 -0500
Subject: [lustre-devel] [PATCH 25/28] lustre: sec: restrict fallocate on
 encrypted files
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

For now, ll_fallocate only supports standard preallocation.
Anyway, encrypted inodes can't handle collapse range or zero range or
insert range since we would need to re-encrypt blocks with a different
IV or XTS tweak (which are based on the logical block number).
So make sure we return -EOPNOTSUPP in this case, like what ext4 does.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: a7870fb9568bf ("LU-12275 sec: restrict fallocate on encrypted files")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/39220
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 4a3c534..02cc2d6 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4927,6 +4927,17 @@ long ll_fallocate(struct file *filp, int mode, loff_t offset, loff_t len)
 	struct inode *inode = filp->f_path.dentry->d_inode;
 
 	/*
+	 * Encrypted inodes can't handle collapse range or zero range or insert
+	 * range since we would need to re-encrypt blocks with a different IV or
+	 * XTS tweak (which are based on the logical block number).
+	 * Similar to what ext4 does.
+	 */
+	if (IS_ENCRYPTED(inode) &&
+	    (mode & (FALLOC_FL_COLLAPSE_RANGE | FALLOC_FL_INSERT_RANGE |
+		     FALLOC_FL_ZERO_RANGE)))
+		return -EOPNOTSUPP;
+
+	/*
 	 * Only mode == 0 (which is standard prealloc) is supported now.
 	 * Punch is not supported yet.
 	 */
-- 
1.8.3.1
