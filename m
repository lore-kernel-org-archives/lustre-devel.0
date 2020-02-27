From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:33 -0500
Subject: [lustre-devel] [PATCH 525/622] lustre: pcc: Incorrect size after
 re-attach
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-526-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

The following test case will result in incorrect size for PCC copy:

- Attach a file with size of s1 (s2 > 0) into PCC;
- Detach this file with --keep option, and the data will retain
  on PCC;
- Truncate this file locally or on an remote client to a new size
  s2 (s2 < s1);
- Re-attach the file again. The size of PCC copy is still s1.

To solve this problem, it need to truncate the size of the PCC copy
to the same size of the Lustre copy which will be HSM released
later after finished the data copy (archive) phase.
This patch also adds the handle for the signal pending when the
attach process is killed by an administrator.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13023
Lustre-commmit: 7a810496c2c ("LU-13023 pcc: Incorrect size after re-attach")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/36884
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/pcc.c | 55 ++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 37 insertions(+), 18 deletions(-)

diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index a40f242..550045b 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -2023,16 +2023,21 @@ static int __pcc_inode_create(struct pcc_dataset *dataset,
 	return rc;
 }
 
-/* TODO: Set the project ID for PCC copy */
-int pcc_inode_store_ugpid(struct dentry *dentry, kuid_t uid, kgid_t gid)
+/*
+ * Reset uid, gid or size for the PCC copy masked by @valid.
+ * TODO: Set the project ID for PCC copy.
+ */
+int pcc_inode_reset_iattr(struct dentry *dentry, unsigned int valid,
+			  kuid_t uid, kgid_t gid, loff_t size)
 {
 	struct inode *inode = dentry->d_inode;
 	struct iattr attr;
 	int rc;
 
-	attr.ia_valid = ATTR_UID | ATTR_GID;
+	attr.ia_valid = valid;
 	attr.ia_uid = uid;
 	attr.ia_gid = gid;
+	attr.ia_size = size;
 
 	inode_lock(inode);
 	rc = notify_change(dentry, &attr, NULL);
@@ -2077,8 +2082,8 @@ int pcc_inode_create_fini(struct inode *inode, struct pcc_create_attach *pca)
 		goto out_put;
 	}
 
-	rc = pcc_inode_store_ugpid(pcc_dentry, old_cred->suid,
-				   old_cred->sgid);
+	rc = pcc_inode_reset_iattr(pcc_dentry, ATTR_UID | ATTR_GID,
+				   old_cred->suid, old_cred->sgid, 0);
 	if (rc)
 		goto out_put;
 
@@ -2152,9 +2157,9 @@ static int pcc_filp_write(struct file *filp, const void *buf, ssize_t count,
 	return 0;
 }
 
-static int pcc_copy_data(struct file *src, struct file *dst)
+static ssize_t pcc_copy_data(struct file *src, struct file *dst)
 {
-	int rc = 0;
+	ssize_t rc = 0;
 	ssize_t rc2;
 	loff_t pos, offset = 0;
 	size_t buf_len = 1048576;
@@ -2165,6 +2170,10 @@ static int pcc_copy_data(struct file *src, struct file *dst)
 		return -ENOMEM;
 
 	while (1) {
+		if (signal_pending(current)) {
+			rc = -EINTR;
+			goto out_free;
+		}
 		pos = offset;
 		rc2 = kernel_read(src, buf, buf_len, &pos);
 		if (rc2 < 0) {
@@ -2180,6 +2189,7 @@ static int pcc_copy_data(struct file *src, struct file *dst)
 		offset += rc2;
 	}
 
+	rc = offset;
 out_free:
 	kvfree(buf);
 	return rc;
@@ -2219,6 +2229,7 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 	struct dentry *dentry;
 	struct file *pcc_filp;
 	struct path path;
+	ssize_t ret;
 	int rc;
 
 	rc = pcc_attach_allowed_check(inode);
@@ -2232,27 +2243,35 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 
 	old_cred = override_creds(pcc_super_cred(inode->i_sb));
 	rc = __pcc_inode_create(dataset, &lli->lli_fid, &dentry);
-	if (rc) {
-		revert_creds(old_cred);
+	if (rc)
 		goto out_dataset_put;
-	}
 
 	path.mnt = dataset->pccd_path.mnt;
 	path.dentry = dentry;
-	pcc_filp = dentry_open(&path, O_TRUNC | O_WRONLY | O_LARGEFILE,
-			       current_cred());
+	pcc_filp = dentry_open(&path, O_WRONLY | O_LARGEFILE, current_cred());
 	if (IS_ERR_OR_NULL(pcc_filp)) {
 		rc = pcc_filp ? PTR_ERR(pcc_filp) : -EINVAL;
-		revert_creds(old_cred);
 		goto out_dentry;
 	}
 
-	rc = pcc_inode_store_ugpid(dentry, old_cred->uid, old_cred->gid);
-	revert_creds(old_cred);
+	rc = pcc_inode_reset_iattr(dentry, ATTR_UID | ATTR_GID,
+				   old_cred->uid, old_cred->gid, 0);
 	if (rc)
 		goto out_fput;
 
-	rc = pcc_copy_data(file, pcc_filp);
+	ret = pcc_copy_data(file, pcc_filp);
+	if (ret < 0) {
+		rc = ret;
+		goto out_fput;
+	}
+
+	/*
+	 * It must to truncate the PCC copy to the same size of the Lustre
+	 * copy after copy data. Otherwise, it may get wrong file size after
+	 * re-attach a file. See LU-13023 for details.
+	 */
+	rc = pcc_inode_reset_iattr(dentry, ATTR_SIZE, KUIDT_INIT(0),
+				   KGIDT_INIT(0), ret);
 	if (rc)
 		goto out_fput;
 
@@ -2276,13 +2295,13 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 	fput(pcc_filp);
 out_dentry:
 	if (rc) {
-		old_cred = override_creds(pcc_super_cred(inode->i_sb));
 		(void) pcc_inode_remove(inode, dentry);
-		revert_creds(old_cred);
 		dput(dentry);
 	}
 out_dataset_put:
 	pcc_dataset_put(dataset);
+	revert_creds(old_cred);
+
 	return rc;
 }
 
-- 
1.8.3.1
