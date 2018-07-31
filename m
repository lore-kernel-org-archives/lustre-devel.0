From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:00 -0400
Subject: [lustre-devel] [PATCH 08/31] lustre: llite: don't zero timestamps
 internally
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Niu Yawei <yawei.niu@intel.com>

In ll_md_blocking_ast(), we zero all timestamps to avoid these
'leftovers' interfering the new timestamps from MDS, especially
when the timestamps are set back by other clients. It's not
quite right to change timestamps in this way, because:

1. The pending lock can be matched by getattr, so these zero
   timestamps can be fetched by application in a small race window.

2. It doesn't make sense to zero the mtime and ctime, because we
   always use the newest ctime and mtime from MDS when do attributes
   merge, they won't interfere new timestamps set by other clients.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-id: https://jira.whamcloud.com/browse/LU-9033
Reviewed-on: https://review.whamcloud.com/24984
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c           | 4 +++-
 drivers/staging/lustre/lustre/llite/llite_internal.h | 5 +++++
 drivers/staging/lustre/lustre/llite/namei.c          | 6 +-----
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 684877c..e4aefb5 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1024,8 +1024,10 @@ int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 	 * POSIX. Solving this problem needs to send an RPC to MDT for each
 	 * read, this will hurt performance.
 	 */
-	if (inode->i_atime.tv_sec < lli->lli_atime)
+	if (inode->i_atime.tv_sec < lli->lli_atime || lli->lli_update_atime) {
 		inode->i_atime.tv_sec = lli->lli_atime;
+		lli->lli_update_atime = 0;
+	}
 	inode->i_mtime.tv_sec = lli->lli_mtime;
 	inode->i_ctime.tv_sec = lli->lli_ctime;
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 8399501..f6c8daf 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -138,6 +138,11 @@ struct ll_inode_info {
 	s64				lli_ctime;
 	spinlock_t			lli_agl_lock;
 
+	/* update atime from MDS no matter if it's older than
+	 * local inode atime.
+	 */
+	unsigned int			lli_update_atime:1;
+
 	/* Try to make the d::member and f::member are aligned. Before using
 	 * these members, make clear whether it is directory or not.
 	 */
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 134cc31..e541f78 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -265,11 +265,7 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		if (bits & MDS_INODELOCK_UPDATE) {
 			struct ll_inode_info *lli = ll_i2info(inode);
 
-			spin_lock(&lli->lli_lock);
-			inode->i_mtime.tv_sec = 0;
-			inode->i_atime.tv_sec = 0;
-			inode->i_ctime.tv_sec = 0;
-			spin_unlock(&lli->lli_lock);
+			lli->lli_update_atime = 1;
 		}
 
 		if ((bits & MDS_INODELOCK_UPDATE) && S_ISDIR(inode->i_mode)) {
-- 
1.8.3.1
