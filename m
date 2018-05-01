From: NeilBrown <neilb@suse.com>
Date: Tue, 01 May 2018 13:52:39 +1000
Subject: [lustre-devel] [PATCH 06/10] staging: lustre: llite: use more
 private data in dump_pgcache
In-Reply-To: <152514658325.17843.11455067361317157487.stgit@noble>
References: <152514658325.17843.11455067361317157487.stgit@noble>
Message-ID: <152514675904.17843.14765347572362739654.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

The dump_page_cache debugfs file allocates and frees an 'env' in each
call to vvp_pgcache_start,next,show.  This is likely to be fast, but
does introduce the need to check for errors.

It is reasonable to allocate a single 'env' when the file is opened,
and use that throughout.

So create 'seq_private' structure which stores the sbi, env, and
refcheck, and attach this to the seqfile.

Then use it throughout instead of allocating 'env' repeatedly.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/vvp_dev.c |  150 ++++++++++++-------------
 1 file changed, 72 insertions(+), 78 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 987c03b058e6..a2619dc04a7f 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -390,6 +390,12 @@ struct vvp_pgcache_id {
 	struct lu_object_header *vpi_obj;
 };
 
+struct seq_private {
+	struct ll_sb_info	*sbi;
+	struct lu_env		*env;
+	u16			refcheck;
+};
+
 static void vvp_pgcache_id_unpack(loff_t pos, struct vvp_pgcache_id *id)
 {
 	BUILD_BUG_ON(sizeof(pos) != sizeof(__u64));
@@ -531,95 +537,71 @@ static void vvp_pgcache_page_show(const struct lu_env *env,
 
 static int vvp_pgcache_show(struct seq_file *f, void *v)
 {
+	struct seq_private	*priv = f->private;
 	loff_t		   pos;
-	struct ll_sb_info       *sbi;
 	struct cl_object	*clob;
-	struct lu_env	   *env;
 	struct vvp_pgcache_id    id;
-	u16 refcheck;
-	int		      result;
 
-	env = cl_env_get(&refcheck);
-	if (!IS_ERR(env)) {
-		pos = *(loff_t *)v;
-		vvp_pgcache_id_unpack(pos, &id);
-		sbi = f->private;
-		clob = vvp_pgcache_obj(env, &sbi->ll_cl->cd_lu_dev, &id);
-		if (clob) {
-			struct inode *inode = vvp_object_inode(clob);
-			struct cl_page *page = NULL;
-			struct page *vmpage;
-
-			result = find_get_pages_contig(inode->i_mapping,
-						       id.vpi_index, 1,
-						       &vmpage);
-			if (result > 0) {
-				lock_page(vmpage);
-				page = cl_vmpage_page(vmpage, clob);
-				unlock_page(vmpage);
-				put_page(vmpage);
-			}
+	pos = *(loff_t *)v;
+	vvp_pgcache_id_unpack(pos, &id);
+	clob = vvp_pgcache_obj(priv->env, &priv->sbi->ll_cl->cd_lu_dev, &id);
+	if (clob) {
+		struct inode *inode = vvp_object_inode(clob);
+		struct cl_page *page = NULL;
+		struct page *vmpage;
+		int result;
+
+		result = find_get_pages_contig(inode->i_mapping,
+					       id.vpi_index, 1,
+					       &vmpage);
+		if (result > 0) {
+			lock_page(vmpage);
+			page = cl_vmpage_page(vmpage, clob);
+			unlock_page(vmpage);
+			put_page(vmpage);
+		}
 
-			seq_printf(f, "%8x@" DFID ": ", id.vpi_index,
-				   PFID(lu_object_fid(&clob->co_lu)));
-			if (page) {
-				vvp_pgcache_page_show(env, f, page);
-				cl_page_put(env, page);
-			} else {
-				seq_puts(f, "missing\n");
-			}
-			lu_object_ref_del(&clob->co_lu, "dump", current);
-			cl_object_put(env, clob);
+		seq_printf(f, "%8x@" DFID ": ", id.vpi_index,
+			   PFID(lu_object_fid(&clob->co_lu)));
+		if (page) {
+			vvp_pgcache_page_show(priv->env, f, page);
+			cl_page_put(priv->env, page);
 		} else {
-			seq_printf(f, "%llx missing\n", pos);
+			seq_puts(f, "missing\n");
 		}
-		cl_env_put(env, &refcheck);
-		result = 0;
+		lu_object_ref_del(&clob->co_lu, "dump", current);
+		cl_object_put(priv->env, clob);
 	} else {
-		result = PTR_ERR(env);
+		seq_printf(f, "%llx missing\n", pos);
 	}
-	return result;
+	return 0;
 }
 
 static void *vvp_pgcache_start(struct seq_file *f, loff_t *pos)
 {
-	struct ll_sb_info *sbi;
-	struct lu_env     *env;
-	u16 refcheck;
-
-	sbi = f->private;
+	struct seq_private	*priv = f->private;
 
-	env = cl_env_get(&refcheck);
-	if (!IS_ERR(env)) {
-		sbi = f->private;
-		if (sbi->ll_site->ls_obj_hash->hs_cur_bits >
-		    64 - PGC_OBJ_SHIFT) {
-			pos = ERR_PTR(-EFBIG);
-		} else {
-			*pos = vvp_pgcache_find(env, &sbi->ll_cl->cd_lu_dev,
-						*pos);
-			if (*pos == ~0ULL)
-				pos = NULL;
-		}
-		cl_env_put(env, &refcheck);
+	if (priv->sbi->ll_site->ls_obj_hash->hs_cur_bits >
+	    64 - PGC_OBJ_SHIFT) {
+		pos = ERR_PTR(-EFBIG);
+	} else {
+		*pos = vvp_pgcache_find(priv->env, &priv->sbi->ll_cl->cd_lu_dev,
+					*pos);
+		if (*pos == ~0ULL)
+			pos = NULL;
 	}
+
 	return pos;
 }
 
 static void *vvp_pgcache_next(struct seq_file *f, void *v, loff_t *pos)
 {
-	struct ll_sb_info *sbi;
-	struct lu_env     *env;
-	u16 refcheck;
+	struct seq_private *priv = f->private;
+
+	*pos = vvp_pgcache_find(priv->env, &priv->sbi->ll_cl->cd_lu_dev, *pos + 1);
+	if (*pos == ~0ULL)
+		pos = NULL;
 
-	env = cl_env_get(&refcheck);
-	if (!IS_ERR(env)) {
-		sbi = f->private;
-		*pos = vvp_pgcache_find(env, &sbi->ll_cl->cd_lu_dev, *pos + 1);
-		if (*pos == ~0ULL)
-			pos = NULL;
-		cl_env_put(env, &refcheck);
-	}
 	return pos;
 }
 
@@ -637,17 +619,29 @@ static const struct seq_operations vvp_pgcache_ops = {
 
 static int vvp_dump_pgcache_seq_open(struct inode *inode, struct file *filp)
 {
-	struct seq_file *seq;
-	int rc;
-
-	rc = seq_open(filp, &vvp_pgcache_ops);
-	if (rc)
-		return rc;
+	struct seq_private *priv;
+
+	priv = __seq_open_private(filp, &vvp_pgcache_ops, sizeof(*priv));
+	if (!priv)
+		return -ENOMEM;
+
+	priv->sbi = inode->i_private;
+	priv->env = cl_env_get(&priv->refcheck);
+	if (IS_ERR(priv->env)) {
+		int err = PTR_ERR(priv->env);
+		seq_release_private(inode, filp);
+		return err;
+	}
+	return 0;
+}
 
-	seq = filp->private_data;
-	seq->private = inode->i_private;
+static int vvp_dump_pgcache_seq_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct seq_private *priv = seq->private;
 
-	return 0;
+	cl_env_put(priv->env, &priv->refcheck);
+	return seq_release_private(inode, file);
 }
 
 const struct file_operations vvp_dump_pgcache_file_ops = {
@@ -655,5 +649,5 @@ const struct file_operations vvp_dump_pgcache_file_ops = {
 	.open    = vvp_dump_pgcache_seq_open,
 	.read    = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release,
+	.release = vvp_dump_pgcache_seq_release,
 };
