From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:58:11 -0400
Subject: [lustre-devel] [PATCH 21/28] lustre: llite: enhance vvp_dev data
 structure naming
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The new code that added struct seq_private to the vvp_dev.c code
has very generic naming which doesn't fit the lustre / kernel style.
See http://wiki.lustre.org/Lustre_Coding_Style_Guidelines for the
naming conventions. Rename the struct seq_private and it fields.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/33009
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/vvp_dev.c | 54 ++++++++++++++-------------
 1 file changed, 28 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 31dc3c0..8cc981b 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -391,11 +391,11 @@ struct vvp_pgcache_id {
 	struct lu_object_header *vpi_obj;
 };
 
-struct seq_private {
-	struct ll_sb_info	*sbi;
-	struct lu_env		*env;
-	u16			refcheck;
-	struct cl_object	*clob;
+struct vvp_seq_private {
+	struct ll_sb_info	*vsp_sbi;
+	struct lu_env		*vsp_env;
+	u16			vsp_refcheck;
+	struct cl_object	*vsp_clob;
 };
 
 static void vvp_pgcache_id_unpack(loff_t pos, struct vvp_pgcache_id *id)
@@ -542,52 +542,54 @@ static void vvp_pgcache_page_show(const struct lu_env *env,
 
 static int vvp_pgcache_show(struct seq_file *f, void *v)
 {
-	struct seq_private	*priv = f->private;
+	struct vvp_seq_private *priv = f->private;
 	struct page		*vmpage = v;
 	struct cl_page		*page;
 
 	seq_printf(f, "%8lx@" DFID ": ", vmpage->index,
-		   PFID(lu_object_fid(&priv->clob->co_lu)));
+		   PFID(lu_object_fid(&priv->vsp_clob->co_lu)));
 	lock_page(vmpage);
-	page = cl_vmpage_page(vmpage, priv->clob);
+	page = cl_vmpage_page(vmpage, priv->vsp_clob);
 	unlock_page(vmpage);
 	put_page(vmpage);
 
 	if (page) {
-		vvp_pgcache_page_show(priv->env, f, page);
-		cl_page_put(priv->env, page);
+		vvp_pgcache_page_show(priv->vsp_env, f, page);
+		cl_page_put(priv->vsp_env, page);
 	} else {
 		seq_puts(f, "missing\n");
 	}
-	lu_object_ref_del(&priv->clob->co_lu, "dump", current);
-	cl_object_put(priv->env, priv->clob);
+	lu_object_ref_del(&priv->vsp_clob->co_lu, "dump", current);
+	cl_object_put(priv->vsp_env, priv->vsp_clob);
 
 	return 0;
 }
 
 static void *vvp_pgcache_start(struct seq_file *f, loff_t *pos)
 {
-	struct seq_private	*priv = f->private;
+	struct vvp_seq_private *priv = f->private;
 	struct page *ret;
 
-	if (priv->sbi->ll_site->ls_obj_hash->hs_cur_bits >
+	if (priv->vsp_sbi->ll_site->ls_obj_hash->hs_cur_bits >
 	    64 - PGC_OBJ_SHIFT)
 		ret = ERR_PTR(-EFBIG);
 	else
-		ret = vvp_pgcache_find(priv->env, &priv->sbi->ll_cl->cd_lu_dev,
-				       &priv->clob, pos);
+		ret = vvp_pgcache_find(priv->vsp_env,
+				       &priv->vsp_sbi->ll_cl->cd_lu_dev,
+				       &priv->vsp_clob, pos);
 
 	return ret;
 }
 
 static void *vvp_pgcache_next(struct seq_file *f, void *v, loff_t *pos)
 {
-	struct seq_private *priv = f->private;
+	struct vvp_seq_private *priv = f->private;
 	struct page *ret;
 
 	*pos += 1;
-	ret = vvp_pgcache_find(priv->env, &priv->sbi->ll_cl->cd_lu_dev,
-			       &priv->clob, pos);
+	ret = vvp_pgcache_find(priv->vsp_env,
+			       &priv->vsp_sbi->ll_cl->cd_lu_dev,
+			       &priv->vsp_clob, pos);
 	return ret;
 }
 
@@ -605,16 +607,16 @@ static void vvp_pgcache_stop(struct seq_file *f, void *v)
 
 static int vvp_dump_pgcache_seq_open(struct inode *inode, struct file *filp)
 {
-	struct seq_private *priv;
+	struct vvp_seq_private *priv;
 
 	priv = __seq_open_private(filp, &vvp_pgcache_ops, sizeof(*priv));
 	if (!priv)
 		return -ENOMEM;
 
-	priv->sbi = inode->i_private;
-	priv->env = cl_env_get(&priv->refcheck);
-	if (IS_ERR(priv->env)) {
-		int err = PTR_ERR(priv->env);
+	priv->vsp_sbi = inode->i_private;
+	priv->vsp_env = cl_env_get(&priv->vsp_refcheck);
+	if (IS_ERR(priv->vsp_env)) {
+		int err = PTR_ERR(priv->vsp_env);
 
 		seq_release_private(inode, filp);
 		return err;
@@ -625,9 +627,9 @@ static int vvp_dump_pgcache_seq_open(struct inode *inode, struct file *filp)
 static int vvp_dump_pgcache_seq_release(struct inode *inode, struct file *file)
 {
 	struct seq_file *seq = file->private_data;
-	struct seq_private *priv = seq->private;
+	struct vvp_seq_private *priv = seq->private;
 
-	cl_env_put(priv->env, &priv->refcheck);
+	cl_env_put(priv->vsp_env, &priv->vsp_refcheck);
 	return seq_release_private(inode, file);
 }
 
-- 
1.8.3.1
