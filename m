From: NeilBrown <neilb@suse.com>
Date: Thu, 12 Apr 2018 07:54:49 +1000
Subject: [lustre-devel] [PATCH 18/20] staging: lustre: change how
 "dump_page_cache" walks a hash table
In-Reply-To: <152348312863.12394.11915752362061083241.stgit@noble>
References: <152348312863.12394.11915752362061083241.stgit@noble>
Message-ID: <152348368915.12394.10633296946135270444.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

The "dump_page_cache" seq_file currently tries to encode
a location in the hash table into a 64bit file index so that
the seq_file can seek to any location.

This is not necessary with the current implementation of seq_file.
seq_file performs any seeks needed itself by rewinding and calling
->next and ->show until the required index is reached.

The required behaviour of ->next is that it always return the next
object after the last one returned by either ->start or ->next.
It can ignore the ppos, but should increment it.

The required behaviour of ->start is one of:
1/ if *ppos is 0, then return the first object
2/ if *ppos is the same value that was passed to the most recent call
   to either ->start or ->next, then return the same object again
3/ if *ppos is anything else, return the next object after the most
   recently returned one.

To implement this we store a vvp_pgcache_id (index into hash table)
in the seq_private data structure, and also store 'prev_pos' as the
last value passed to either ->start or ->next.

We remove all converstion of an id to a pos, and any limits on the
size of the vpi_depth.

vvp_pgcache_obj_get() is changed to ignore dying objects so that
vvp_pgcache_obj only returns NULL when it reaches the end of a hash
chain, and so vpi_bucket needs to be incremented.

A reference to the current ->clob pointer is now kept as long as we
are iterating over the pages in a given object, so we don't have to
try to find it again (and possibly fail) for each page.

And the ->start and ->next functions are changed as described above.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/vvp_dev.c |  173 +++++++++++--------------
 1 file changed, 79 insertions(+), 94 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 39a85e967368..64c3fdbbf0eb 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -365,22 +365,6 @@ int cl_sb_fini(struct super_block *sb)
  *
  ****************************************************************************/
 
-/*
- * To represent contents of a page cache as a byte stream, following
- * information if encoded in 64bit offset:
- *
- *       - file hash bucket in lu_site::ls_hash[]       28bits
- *
- *       - how far file is from bucket head	      4bits
- *
- *       - page index				   32bits
- *
- * First two data identify a file in the cache uniquely.
- */
-
-#define PGC_OBJ_SHIFT (32 + 4)
-#define PGC_DEPTH_SHIFT (32)
-
 struct vvp_pgcache_id {
 	unsigned int		 vpi_bucket;
 	unsigned int		 vpi_depth;
@@ -395,37 +379,26 @@ struct seq_private {
 	struct lu_env		*env;
 	u16			refcheck;
 	struct cl_object	*clob;
+	struct vvp_pgcache_id	id;
+	/*
+	 * prev_pos is the 'pos' of the last object returned
+	 * by ->start of ->next.
+	 */
+	loff_t			prev_pos;
 };
 
-static void vvp_pgcache_id_unpack(loff_t pos, struct vvp_pgcache_id *id)
-{
-	BUILD_BUG_ON(sizeof(pos) != sizeof(__u64));
-
-	id->vpi_index  = pos & 0xffffffff;
-	id->vpi_depth  = (pos >> PGC_DEPTH_SHIFT) & 0xf;
-	id->vpi_bucket = (unsigned long long)pos >> PGC_OBJ_SHIFT;
-}
-
-static loff_t vvp_pgcache_id_pack(struct vvp_pgcache_id *id)
-{
-	return
-		((__u64)id->vpi_index) |
-		((__u64)id->vpi_depth  << PGC_DEPTH_SHIFT) |
-		((__u64)id->vpi_bucket << PGC_OBJ_SHIFT);
-}
-
 static int vvp_pgcache_obj_get(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 			       struct hlist_node *hnode, void *data)
 {
 	struct vvp_pgcache_id   *id  = data;
 	struct lu_object_header *hdr = cfs_hash_object(hs, hnode);
 
+	if (lu_object_is_dying(hdr))
+		return 0;
+
 	if (id->vpi_curdep-- > 0)
 		return 0; /* continue */
 
-	if (lu_object_is_dying(hdr))
-		return 1;
-
 	cfs_hash_get(hs, hnode);
 	id->vpi_obj = hdr;
 	return 1;
@@ -437,7 +410,6 @@ static struct cl_object *vvp_pgcache_obj(const struct lu_env *env,
 {
 	LASSERT(lu_device_is_cl(dev));
 
-	id->vpi_depth &= 0xf;
 	id->vpi_obj    = NULL;
 	id->vpi_curdep = id->vpi_depth;
 
@@ -452,55 +424,42 @@ static struct cl_object *vvp_pgcache_obj(const struct lu_env *env,
 			return lu2cl(lu_obj);
 		}
 		lu_object_put(env, lu_object_top(id->vpi_obj));
-
-	} else if (id->vpi_curdep > 0) {
-		id->vpi_depth = 0xf;
 	}
 	return NULL;
 }
 
-static struct page *vvp_pgcache_find(const struct lu_env *env,
-				     struct lu_device *dev,
-				     struct cl_object **clobp, loff_t *pos)
+static struct page *vvp_pgcache_current(struct seq_private *priv)
 {
-	struct cl_object     *clob;
-	struct lu_site       *site;
-	struct vvp_pgcache_id id;
-
-	site = dev->ld_site;
-	vvp_pgcache_id_unpack(*pos, &id);
-
-	while (1) {
-		if (id.vpi_bucket >= CFS_HASH_NHLIST(site->ls_obj_hash))
-			return NULL;
-		clob = vvp_pgcache_obj(env, dev, &id);
-		if (clob) {
-			struct inode *inode = vvp_object_inode(clob);
-			struct page *vmpage;
-			int nr;
-
-			nr = find_get_pages_contig(inode->i_mapping,
-						   id.vpi_index, 1, &vmpage);
-			if (nr > 0) {
-				id.vpi_index = vmpage->index;
-				/* Cant support over 16T file */
-				if (vmpage->index <= 0xffffffff) {
-					*clobp = clob;
-					*pos = vvp_pgcache_id_pack(&id);
-					return vmpage;
-				}
-				put_page(vmpage);
-			}
-
-			lu_object_ref_del(&clob->co_lu, "dump", current);
-			cl_object_put(env, clob);
+	struct lu_device *dev = &priv->sbi->ll_cl->cd_lu_dev;
+
+	while(1) {
+		struct inode *inode;
+		int nr;
+		struct page *vmpage;
+
+		if (!priv->clob) {
+			struct cl_object *clob;
+
+			while ((clob = vvp_pgcache_obj(priv->env, dev, &priv->id)) == NULL &&
+			       ++(priv->id.vpi_bucket) < CFS_HASH_NHLIST(dev->ld_site->ls_obj_hash))
+				priv->id.vpi_depth = 0;
+			if (!clob)
+				return NULL;
+			priv->clob = clob;
+			priv->id.vpi_index = 0;
+		}
+
+		inode = vvp_object_inode(priv->clob);
+		nr = find_get_pages_contig(inode->i_mapping, priv->id.vpi_index, 1, &vmpage);
+		if (nr > 0) {
+			priv->id.vpi_index = vmpage->index;
+			return vmpage;
 		}
-		/* to the next object. */
-		++id.vpi_depth;
-		id.vpi_depth &= 0xf;
-		if (id.vpi_depth == 0 && ++id.vpi_bucket == 0)
-			return NULL;
-		id.vpi_index = 0;
+		lu_object_ref_del(&priv->clob->co_lu, "dump", current);
+		cl_object_put(priv->env, priv->clob);
+		priv->clob = NULL;
+		priv->id.vpi_index = 0;
+		priv->id.vpi_depth++;
 	}
 }
 
@@ -558,36 +517,54 @@ static int vvp_pgcache_show(struct seq_file *f, void *v)
 	} else {
 		seq_puts(f, "missing\n");
 	}
-	lu_object_ref_del(&priv->clob->co_lu, "dump", current);
-	cl_object_put(priv->env, priv->clob);
 
 	return 0;
 }
 
+static void vvp_pgcache_rewind(struct seq_private *priv)
+{
+	if (priv->prev_pos) {
+		memset(&priv->id, 0, sizeof(priv->id));
+		priv->prev_pos = 0;
+		if (priv->clob) {
+			lu_object_ref_del(&priv->clob->co_lu, "dump", current);
+			cl_object_put(priv->env, priv->clob);
+		}
+		priv->clob = NULL;
+	}
+}
+
+static struct page *vvp_pgcache_next_page(struct seq_private *priv)
+{
+	priv->id.vpi_index += 1;
+	return vvp_pgcache_current(priv);
+}
+
 static void *vvp_pgcache_start(struct seq_file *f, loff_t *pos)
 {
 	struct seq_private	*priv = f->private;
-	struct page *ret;
 
-	if (priv->sbi->ll_site->ls_obj_hash->hs_cur_bits >
-	    64 - PGC_OBJ_SHIFT)
-		ret = ERR_PTR(-EFBIG);
-	else
-		ret = vvp_pgcache_find(priv->env, &priv->sbi->ll_cl->cd_lu_dev,
-				       &priv->clob, pos);
+	if (*pos == 0)
+		vvp_pgcache_rewind(priv);
+	else if (*pos == priv->prev_pos)
+		/* Return the current item */;
+	else {
+		WARN_ON(*pos != priv->prev_pos + 1);
+		priv->id.vpi_index += 1;
+	}
 
-	return ret;
+	priv->prev_pos = *pos;
+	return vvp_pgcache_current(priv);
 }
 
 static void *vvp_pgcache_next(struct seq_file *f, void *v, loff_t *pos)
 {
 	struct seq_private *priv = f->private;
-	struct page *ret;
 
+	WARN_ON(*pos != priv->prev_pos);
 	*pos += 1;
-	ret = vvp_pgcache_find(priv->env, &priv->sbi->ll_cl->cd_lu_dev,
-			       &priv->clob, pos);
-	return ret;
+	priv->prev_pos = *pos;
+	return vvp_pgcache_next_page(priv);
 }
 
 static void vvp_pgcache_stop(struct seq_file *f, void *v)
@@ -612,6 +589,9 @@ static int vvp_dump_pgcache_seq_open(struct inode *inode, struct file *filp)
 
 	priv->sbi = inode->i_private;
 	priv->env = cl_env_get(&priv->refcheck);
+	priv->clob = NULL;
+	memset(&priv->id, 0, sizeof(priv->id));
+
 	if (IS_ERR(priv->env)) {
 		int err = PTR_ERR(priv->env);
 		seq_release_private(inode, filp);
@@ -625,6 +605,11 @@ static int vvp_dump_pgcache_seq_release(struct inode *inode, struct file *file)
 	struct seq_file *seq = file->private_data;
 	struct seq_private *priv = seq->private;
 
+	if (priv->clob) {
+		lu_object_ref_del(&priv->clob->co_lu, "dump", current);
+		cl_object_put(priv->env, priv->clob);
+	}
+
 	cl_env_put(priv->env, &priv->refcheck);
 	return seq_release_private(inode, file);
 }
