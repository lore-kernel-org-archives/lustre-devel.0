From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:44 -0400
Subject: [lustre-devel] [PATCH 05/22] lustre: llite: use %pd to report
 dentry names.
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Since Linux 3.12, it has been possible use the "%pd" format specifier
to print a dentry name, so use that instead of "%.*s" and having
to pass both the length and the name.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: ef9718e8e9cf8 ("LU-6142 llite: use %pd to report dentry names.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/38442
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Olaf Faaland-LLNL <faaland1@llnl.gov>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c |  4 ++--
 fs/lustre/llite/pcc.c  | 20 ++++++--------------
 2 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index ce50fd9..52f0865 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2810,8 +2810,8 @@ int ll_file_lock_ahead(struct file *file, struct llapi_lu_ladvise *ladvise)
 	int result;
 
 	CDEBUG(D_VFSTRACE,
-	       "Lock request: file=%.*s, inode=%p, mode=%s start=%llu, end=%llu\n",
-	       dentry->d_name.len, dentry->d_name.name, dentry->d_inode,
+	       "Lock request: file=%pd, inode=%p, mode=%s start=%llu, end=%llu\n",
+	       dentry, dentry->d_inode,
 	       user_lockname[ladvise->lla_lockahead_mode], (__u64) start, end);
 
 	cl_mode = cl_mode_user_to_kernel(ladvise->lla_lockahead_mode);
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index 391733e..2adde68 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -1466,7 +1466,6 @@ int pcc_file_open(struct inode *inode, struct file *file)
 	struct pcc_file *pccf = &fd->fd_pcc_file;
 	struct file *pcc_file;
 	struct path *path;
-	struct qstr *dname;
 	bool cached = false;
 	int rc = 0;
 
@@ -1494,9 +1493,7 @@ int pcc_file_open(struct inode *inode, struct file *file)
 	WARN_ON(pccf->pccf_file);
 
 	path = &pcci->pcci_path;
-	dname = &path->dentry->d_name;
-	CDEBUG(D_CACHE, "opening pcc file '%.*s'\n", dname->len,
-	       dname->name);
+	CDEBUG(D_CACHE, "opening pcc file '%pd'\n", path->dentry);
 
 	pcc_file = dentry_open(path, file->f_flags,
 			       pcc_super_cred(inode->i_sb));
@@ -1519,7 +1516,6 @@ void pcc_file_release(struct inode *inode, struct file *file)
 	struct ll_file_data *fd = file->private_data;
 	struct pcc_file *pccf;
 	struct path *path;
-	struct qstr *dname;
 
 	if (!S_ISREG(inode->i_mode) || !fd)
 		return;
@@ -1532,9 +1528,7 @@ void pcc_file_release(struct inode *inode, struct file *file)
 	pcci = ll_i2pcci(inode);
 	LASSERT(pcci);
 	path = &pcci->pcci_path;
-	dname = &path->dentry->d_name;
-	CDEBUG(D_CACHE, "releasing pcc file \"%.*s\"\n", dname->len,
-	       dname->name);
+	CDEBUG(D_CACHE, "releasing pcc file \"%pd\"\n", path->dentry);
 	pcc_inode_put(pcci);
 	fput(pccf->pccf_file);
 	pccf->pccf_file = NULL;
@@ -2005,9 +1999,8 @@ static int pcc_inode_remove(struct inode *inode, struct dentry *pcc_dentry)
 
 	rc = vfs_unlink(pcc_dentry->d_parent->d_inode, pcc_dentry, NULL);
 	if (rc)
-		CWARN("%s: failed to unlink PCC file %.*s, rc = %d\n",
-		      ll_i2sbi(inode)->ll_fsname, pcc_dentry->d_name.len,
-		      pcc_dentry->d_name.name, rc);
+		CWARN("%s: failed to unlink PCC file %pd: rc = %d\n",
+		      ll_i2sbi(inode)->ll_fsname, pcc_dentry, rc);
 
 	return rc;
 }
@@ -2239,9 +2232,8 @@ void pcc_create_attach_cleanup(struct super_block *sb,
 		rc = vfs_unlink(pca->pca_dentry->d_parent->d_inode,
 				pca->pca_dentry, NULL);
 		if (rc)
-			CWARN("failed to unlink PCC file %.*s, rc = %d\n",
-			      pca->pca_dentry->d_name.len,
-			      pca->pca_dentry->d_name.name, rc);
+			CWARN("%s: failed to unlink PCC file %pd: rc = %d\n",
+			      ll_s2sbi(sb)->ll_fsname, pca->pca_dentry, rc);
 		/* ignore the unlink failure */
 		revert_creds(old_cred);
 		dput(pca->pca_dentry);
-- 
1.8.3.1
