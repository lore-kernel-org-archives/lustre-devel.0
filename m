From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:59 -0500
Subject: [lustre-devel] [PATCH 551/622] lustre: llite: don't cache
 MDS_OPEN_LOCK for volatile files
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-552-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The kernels knfsd constantly opens and closes files for each
access which can result in a continuous stream of open+close RPCs
being send to the MDS. To avoid this Lustre created a special
flag, ll_nfs_dentry, which enables caching of the MDS_OPEN_LOCK
on the client. The fhandles API also uses the same exportfs layer
as NFS which indirectly ends up caching the MDS_OPEN_LOCK as well.
This is okay for normal files except for Lustre's special volatile
files that are used for HSM restore. It is expected on the last
close of a Lustre volatile file that it is no longer accessable.
To ensure this behavior is kept don't cache MDS_OPEN_LOCK for
volatile files.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8585
Lustre-commit: 6a3a842add0e ("LU-8585 llite: don't cache MDS_OPEN_LOCK for volatile files")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/36641
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index d196da8..a3c36a7 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -798,6 +798,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 	} else {
 		LASSERT(*och_usecount == 0);
 		if (!it->it_disposition) {
+			struct dentry *dentry = file_dentry(file);
 			struct ll_dentry_data *ldd;
 
 			/* We cannot just request lock handle now, new ELC code
@@ -822,10 +823,13 @@ int ll_file_open(struct inode *inode, struct file *file)
 			 * lookup path only, since ll_iget_for_nfs always calls
 			 * ll_d_init().
 			 */
-			ldd = ll_d2d(file->f_path.dentry);
+			ldd = ll_d2d(dentry);
 			if (ldd && ldd->lld_nfs_dentry) {
 				ldd->lld_nfs_dentry = 0;
-				it->it_flags |= MDS_OPEN_LOCK;
+				if (!filename_is_volatile(dentry->d_name.name,
+							  dentry->d_name.len,
+							  NULL))
+					it->it_flags |= MDS_OPEN_LOCK;
 			}
 
 			/*
@@ -833,8 +837,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 			 * to get file with different fid.
 			 */
 			it->it_flags |= MDS_OPEN_BY_FID;
-			rc = ll_intent_file_open(file->f_path.dentry,
-						 NULL, 0, it);
+			rc = ll_intent_file_open(dentry, NULL, 0, it);
 			if (rc)
 				goto out_openerr;
 
-- 
1.8.3.1
