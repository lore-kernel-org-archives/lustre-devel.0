From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:58:18 -0400
Subject: [lustre-devel] [PATCH 28/28] lustre: llite: restore lld_nfs_dentry
 handling
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The port of patch for LU-3544 to enable open-by-fid as the default to
the linux lustre client was done incorrectly. It ended dropping the
handling of lld_nfs_dentry for the NFS export case. Lets restore it.

Fixes: c1b66fccf986 ("staging: lustre: fid: do open-by-fid by default")
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index d80bda4..5df2b87 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -589,6 +589,8 @@ int ll_file_open(struct inode *inode, struct file *file)
 	} else {
 		LASSERT(*och_usecount == 0);
 		if (!it->it_disposition) {
+			struct ll_dentry_data *ldd = ll_d2d(file->f_path.dentry);
+
 			/* We cannot just request lock handle now, new ELC code
 			 * means that one of other OPEN locks for this file
 			 * could be cancelled, and since blocking ast handler
@@ -599,11 +601,24 @@ int ll_file_open(struct inode *inode, struct file *file)
 			/*
 			 * Normally called under two situations:
 			 * 1. NFS export.
-			 * 2. revalidate with IT_OPEN (revalidate doesn't
-			 *    execute this intent any more).
+			 * 2. A race/condition on MDS resulting in no open
+			 *    handle to be returned from LOOKUP|OPEN request,
+			 *    for example if the target entry was a symlink.
 			 *
-			 * Always fetch MDS_OPEN_LOCK if this is not setstripe.
+			 * Only fetch MDS_OPEN_LOCK if this is in NFS path,
+			 * marked by a bit set in ll_iget_for_nfs. Clear the
+			 * bit so that it's not confusing later callers.
 			 *
+			 * NB; when ldd is NULL, it must have come via normal
+			 * lookup path only, since ll_iget_for_nfs always calls
+			 * ll_d_init().
+			 */
+			if (ldd && ldd->lld_nfs_dentry) {
+				ldd->lld_nfs_dentry = 0;
+				it->it_flags |= MDS_OPEN_LOCK;
+			}
+
+			/*
 			 * Always specify MDS_OPEN_BY_FID because we don't want
 			 * to get file with different fid.
 			 */
-- 
1.8.3.1
