From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:52:44 -0400
Subject: [lustre-devel] [PATCH 08/32] staging: lustre: llite: a few fixes
	about readdir of striped dir.
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, Li Xi <lixi@ddn.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Normally we know the value of op_mea1 when ll_readdir is called.
In the case of '.' or '..' op_mea1 is unknown so for that case
fetch the real parents FID.

Signed-off-by: wang di <di.wang@intel.com>
Signed-off-by: Li Xi <lixi@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4603
Reviewed-on: http://review.whamcloud.com/9191
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Li Xi <pkuelelixi@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c          |   27 +++++++++++++++++
 .../staging/lustre/lustre/llite/llite_internal.h   |    1 +
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |   31 ++++++++++++++------
 3 files changed, 50 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 924b5df..3fed80d 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -622,6 +622,33 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 		goto out;
 	}
 
+	if (unlikely(op_data->op_mea1)) {
+		/*
+		 * This is only needed for striped dir to fill ..,
+		 * see lmv_read_page
+		 */
+		if (file_dentry(filp)->d_parent &&
+		    file_dentry(filp)->d_parent->d_inode) {
+			__u64 ibits = MDS_INODELOCK_UPDATE;
+			struct inode *parent;
+
+			parent = file_dentry(filp)->d_parent->d_inode;
+			if (ll_have_md_lock(parent, &ibits, LCK_MINMODE))
+				op_data->op_fid3 = *ll_inode2fid(parent);
+		}
+
+		/*
+		 * If it can not find in cache, do lookup .. on the master
+		 * object
+		 */
+		if (fid_is_zero(&op_data->op_fid3)) {
+			rc = ll_dir_get_parent_fid(inode, &op_data->op_fid3);
+			if (rc) {
+				ll_finish_md_op_data(op_data);
+				return rc;
+			}
+		}
+	}
 	ctx->pos = pos;
 	rc = ll_dir_read(inode, &pos, op_data, ctx);
 	pos = ctx->pos;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 3d7fa9a..43269aa 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -812,6 +812,7 @@ __u32 get_uuid2int(const char *name, int len);
 void get_uuid2fsid(const char *name, int len, __kernel_fsid_t *fsid);
 struct inode *search_inode_for_lustre(struct super_block *sb,
 				      const struct lu_fid *fid);
+int ll_dir_get_parent_fid(struct inode *dir, struct lu_fid *parent_fid);
 
 /* llite/symlink.c */
 extern const struct inode_operations ll_fast_symlink_inode_operations;
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index ab9d5cc..06a8199 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -302,14 +302,12 @@ static struct dentry *ll_fh_to_parent(struct super_block *sb, struct fid *fid,
 	return ll_iget_for_nfs(sb, &nfs_fid->lnf_parent, NULL);
 }
 
-static struct dentry *ll_get_parent(struct dentry *dchild)
+int ll_dir_get_parent_fid(struct inode *dir, struct lu_fid *parent_fid)
 {
 	struct ptlrpc_request *req = NULL;
-	struct inode	  *dir = d_inode(dchild);
 	struct ll_sb_info     *sbi;
-	struct dentry	 *result = NULL;
 	struct mdt_body       *body;
-	static char	   dotdot[] = "..";
+	static const char dotdot[] = "..";
 	struct md_op_data     *op_data;
 	int		   rc;
 	int		      lmmsize;
@@ -324,13 +322,13 @@ static struct dentry *ll_get_parent(struct dentry *dchild)
 
 	rc = ll_get_default_mdsize(sbi, &lmmsize);
 	if (rc != 0)
-		return ERR_PTR(rc);
+		return rc;
 
 	op_data = ll_prep_md_op_data(NULL, dir, NULL, dotdot,
 				     strlen(dotdot), lmmsize,
 				     LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
-		return (void *)op_data;
+		return PTR_ERR(op_data);
 
 	rc = md_getattr_name(sbi->ll_md_exp, op_data, &req);
 	ll_finish_md_op_data(op_data);
@@ -338,7 +336,7 @@ static struct dentry *ll_get_parent(struct dentry *dchild)
 		CERROR("%s: failure inode "DFID" get parent: rc = %d\n",
 		       ll_get_fsname(dir->i_sb, NULL, 0),
 		       PFID(ll_inode2fid(dir)), rc);
-		return ERR_PTR(rc);
+		return rc;
 	}
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 	/*
@@ -348,11 +346,26 @@ static struct dentry *ll_get_parent(struct dentry *dchild)
 	if (body->valid & OBD_MD_FLID) {
 		CDEBUG(D_INFO, "parent for " DFID " is " DFID "\n",
 		       PFID(ll_inode2fid(dir)), PFID(&body->fid1));
+		*parent_fid = body->fid1;
 	}
-	result = ll_iget_for_nfs(dir->i_sb, &body->fid1, NULL);
 
 	ptlrpc_req_finished(req);
-	return result;
+	return 0;
+}
+
+static struct dentry *ll_get_parent(struct dentry *dchild)
+{
+	struct lu_fid parent_fid = { 0 };
+	struct dentry *dentry;
+	int rc;
+
+	rc = ll_dir_get_parent_fid(dchild->d_inode, &parent_fid);
+	if (rc)
+		return ERR_PTR(rc);
+
+	dentry = ll_iget_for_nfs(dchild->d_inode->i_sb, &parent_fid, NULL);
+
+	return dentry;
 }
 
 const struct export_operations lustre_export_operations = {
-- 
1.7.1
