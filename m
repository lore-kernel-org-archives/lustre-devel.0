From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:31 -0500
Subject: [lustre-devel] [PATCH 583/622] lustre: uapi: turn struct
 lustre_nfs_fid to userland fhandle
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-584-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Quentin Bouget <quentin.bouget@cea.fr>

Rename struct lustre_nfs_fid to struct lustre_file_handle and move
it to UAPI header lustre_user.h so we can use it with the fhandle
API such as name_to_handle_at().

WC-bug-id: https://jira.whamcloud.com/browse/LU-12806
Lustre-commit: 7ff384eee194 ("LU-12806 llapi: use name_to_handle_at in llapi_fd2fid")
Signed-off-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-on: https://review.whamcloud.com/36292
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_nfs.c             | 23 +++++++++--------------
 include/uapi/linux/lustre/lustre_user.h |  6 ++++++
 2 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/llite/llite_nfs.c b/fs/lustre/llite/llite_nfs.c
index 2ac5ad9..a57ab51 100644
--- a/fs/lustre/llite/llite_nfs.c
+++ b/fs/lustre/llite/llite_nfs.c
@@ -110,11 +110,6 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 	return inode;
 }
 
-struct lustre_nfs_fid {
-	struct lu_fid lnf_child;
-	struct lu_fid lnf_parent;
-};
-
 static struct dentry *
 ll_iget_for_nfs(struct super_block *sb,
 		struct lu_fid *fid, struct lu_fid *parent)
@@ -177,8 +172,8 @@ struct lustre_nfs_fid {
 static int ll_encode_fh(struct inode *inode, u32 *fh, int *plen,
 			struct inode *parent)
 {
-	int fileid_len = sizeof(struct lustre_nfs_fid) / 4;
-	struct lustre_nfs_fid *nfs_fid = (void *)fh;
+	int fileid_len = sizeof(struct lustre_file_handle) / 4;
+	struct lustre_file_handle *lfh = (void *)fh;
 
 	CDEBUG(D_INFO, "%s: encoding for (" DFID ") maxlen=%d minlen=%d\n",
 	       ll_i2sbi(inode)->ll_fsname,
@@ -189,11 +184,11 @@ static int ll_encode_fh(struct inode *inode, u32 *fh, int *plen,
 		return FILEID_INVALID;
 	}
 
-	nfs_fid->lnf_child = *ll_inode2fid(inode);
+	lfh->lfh_child = *ll_inode2fid(inode);
 	if (parent)
-		nfs_fid->lnf_parent = *ll_inode2fid(parent);
+		lfh->lfh_parent = *ll_inode2fid(parent);
 	else
-		fid_zero(&nfs_fid->lnf_parent);
+		fid_zero(&lfh->lfh_parent);
 	*plen = fileid_len;
 
 	return FILEID_LUSTRE;
@@ -264,23 +259,23 @@ static int ll_get_name(struct dentry *dentry, char *name,
 static struct dentry *ll_fh_to_dentry(struct super_block *sb, struct fid *fid,
 				      int fh_len, int fh_type)
 {
-	struct lustre_nfs_fid *nfs_fid = (struct lustre_nfs_fid *)fid;
+	struct lustre_file_handle *lfh = (struct lustre_file_handle *)fid;
 
 	if (fh_type != FILEID_LUSTRE)
 		return ERR_PTR(-EPROTO);
 
-	return ll_iget_for_nfs(sb, &nfs_fid->lnf_child, &nfs_fid->lnf_parent);
+	return ll_iget_for_nfs(sb, &lfh->lfh_child, &lfh->lfh_parent);
 }
 
 static struct dentry *ll_fh_to_parent(struct super_block *sb, struct fid *fid,
 				      int fh_len, int fh_type)
 {
-	struct lustre_nfs_fid *nfs_fid = (struct lustre_nfs_fid *)fid;
+	struct lustre_file_handle *lfh = (struct lustre_file_handle *)fid;
 
 	if (fh_type != FILEID_LUSTRE)
 		return ERR_PTR(-EPROTO);
 
-	return ll_iget_for_nfs(sb, &nfs_fid->lnf_parent, NULL);
+	return ll_iget_for_nfs(sb, &lfh->lfh_parent, NULL);
 }
 
 int ll_dir_get_parent_fid(struct inode *dir, struct lu_fid *parent_fid)
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 12b1f78..1c36114 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -164,6 +164,12 @@ static inline bool fid_is_zero(const struct lu_fid *fid)
 	return !fid->f_seq && !fid->f_oid;
 }
 
+/* The data name_to_handle_at() places in a struct file_handle (at f_handle) */
+struct lustre_file_handle {
+	struct lu_fid lfh_child;
+	struct lu_fid lfh_parent;
+};
+
 struct ost_layout {
 	__u32	ol_stripe_size;
 	__u32	ol_stripe_count;
-- 
1.8.3.1
