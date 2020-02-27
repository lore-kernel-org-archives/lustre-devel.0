From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:50 -0500
Subject: [lustre-devel] [PATCH 182/622] lustre: llite: Fix style issues for
 llite_nfs.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-183-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch fixes issues reported by checkpatch
for file fs/lustre/llite/llite_nfs.c

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: c648f5ddc3e8 ("LU-6142 llite: Fix style issues for llite_nfs.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/33809
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_nfs.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/llite/llite_nfs.c b/fs/lustre/llite/llite_nfs.c
index 434f92b..de8f707 100644
--- a/fs/lustre/llite/llite_nfs.c
+++ b/fs/lustre/llite/llite_nfs.c
@@ -64,12 +64,11 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 	struct ptlrpc_request *req = NULL;
 	struct inode *inode = NULL;
 	int eadatalen = 0;
-	unsigned long hash = cl_fid_build_ino(fid,
-					      ll_need_32bit_api(sbi));
+	unsigned long hash = cl_fid_build_ino(fid, ll_need_32bit_api(sbi));
 	struct md_op_data *op_data;
 	int rc;
 
-	CDEBUG(D_INFO, "searching inode for:(%lu," DFID ")\n", hash, PFID(fid));
+	CDEBUG(D_INFO, "searching inode for:(%lu,"DFID")\n", hash, PFID(fid));
 
 	inode = ilookup5(sb, hash, ll_test_inode_by_fid, (void *)fid);
 	if (inode)
@@ -79,7 +78,8 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 	if (rc)
 		return ERR_PTR(rc);
 
-	/* Because inode is NULL, ll_prep_md_op_data can not
+	/*
+	 * Because inode is NULL, ll_prep_md_op_data can not
 	 * be used here. So we allocate op_data ourselves
 	 */
 	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
@@ -94,6 +94,10 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 	rc = md_getattr(sbi->ll_md_exp, op_data, &req);
 	kfree(op_data);
 	if (rc) {
+		/*
+		 * Suppress erroneous/confusing messages when NFS
+		 * is out of sync and requests old data.
+		 */
 		CDEBUG(D_INFO, "can't get object attrs, fid " DFID ", rc %d\n",
 		       PFID(fid), rc);
 		return ERR_PTR(rc);
@@ -107,8 +111,8 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 }
 
 struct lustre_nfs_fid {
-	struct lu_fid	lnf_child;
-	struct lu_fid	lnf_parent;
+	struct lu_fid lnf_child;
+	struct lu_fid lnf_parent;
 };
 
 static struct dentry *
-- 
1.8.3.1
