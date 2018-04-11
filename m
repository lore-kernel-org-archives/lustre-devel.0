From: NeilBrown <neilb@suse.com>
Date: Thu, 12 Apr 2018 07:54:49 +1000
Subject: [lustre-devel] [PATCH 19/20] staging: lustre: convert lu_object
 cache to rhashtable
In-Reply-To: <152348312863.12394.11915752362061083241.stgit@noble>
References: <152348312863.12394.11915752362061083241.stgit@noble>
Message-ID: <152348368919.12394.7505057425201912278.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

The lu_object cache is a little more complex than the other lustre
hash tables for two reasons.
1/ there is a debugfs file which displays the contents of the cache,
  so we need to use rhashtable_walk in a way that works for seq_file.

2/ There is a (shared) lru list for objects which are no longer
   referenced, so finding an object needs to consider races with the
   lru as well as with the hash table.

The debugfs file already manages walking the libcfs hash table keeping
a current-position in the private data.  We can fairly easily convert
that to a struct rhashtable_iter.  The debugfs file actually reports
pages, and there are multiple pages per hashtable object.  So as well
as rhashtable_iter, we need the current page index.


For the double-locking, the current code uses direct-access to the
bucket locks that libcfs_hash provides.  rhashtable doesn't provide
that access - callers must provide their own locking or use rcu
techniques.

The lsb_marche_funebre.lock is still used to manage the lru list, but
with this patch it is no longer nested *inside* the hashtable locks,
but instead is outside.  It is used to protect an object with a
refcount of zero.

When purging old objects from an lru, we first set
LU_OBJECT_HEARD_BANSHEE while holding the lsb_marche_funebre.lock,
then remove all the entries from the hashtable separately.

When we find an object in the hashtable with a refcount of zero, we
take the corresponding lsb_marche_funebre.lock and check
LU_OBJECT_HEARD_BANSHEE isn't set.  If it isn't, we can safely
increment the refcount.  If it is, the object is gone.

When removing the last reference from an object, we first take the
lsb_marche_funebre.lock, then decrement the reference and add to the
lru list.

This way, we only ever manipulate an object with a refcount of zero
while holding the lsb_marche_funebre.lock.

As there is nothing to stop us using the resizing capabilities of
rhashtable, the code to try to guess the perfect has size has been
removed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lu_object.h  |    8 
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |   98 ++---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  362 +++++++-------------
 3 files changed, 170 insertions(+), 298 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 85066ece44d6..fab576687608 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -530,9 +530,9 @@ struct lu_object_header {
 	 */
 	__u32		  loh_attr;
 	/**
-	 * Linkage into per-site hash table. Protected by lu_site::ls_guard.
+	 * Linkage into per-site hash table.
 	 */
-	struct hlist_node       loh_hash;
+	struct rhash_head       loh_hash;
 	/**
 	 * Linkage into per-site LRU list. Protected by lu_site::ls_guard.
 	 * memory shared with lru_head for delayed freeing;
@@ -579,7 +579,7 @@ struct lu_site {
 	/**
 	 * objects hash table
 	 */
-	struct cfs_hash	       *ls_obj_hash;
+	struct rhashtable	ls_obj_hash;
 	/*
 	 * buckets for summary data
 	 */
@@ -655,6 +655,8 @@ int lu_object_init(struct lu_object *o,
 void lu_object_fini(struct lu_object *o);
 void lu_object_add_top(struct lu_object_header *h, struct lu_object *o);
 void lu_object_add(struct lu_object *before, struct lu_object *o);
+struct lu_object *lu_object_get_first(struct lu_object_header *h,
+				      struct lu_device *dev);
 
 /**
  * Helpers to initialize and finalize device types.
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 64c3fdbbf0eb..da39375ae43d 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -365,21 +365,13 @@ int cl_sb_fini(struct super_block *sb)
  *
  ****************************************************************************/
 
-struct vvp_pgcache_id {
-	unsigned int		 vpi_bucket;
-	unsigned int		 vpi_depth;
-	u32			 vpi_index;
-
-	unsigned int		 vpi_curdep;
-	struct lu_object_header *vpi_obj;
-};
-
 struct seq_private {
 	struct ll_sb_info	*sbi;
 	struct lu_env		*env;
 	u16			refcheck;
 	struct cl_object	*clob;
-	struct vvp_pgcache_id	id;
+	struct rhashtable_iter	iter;
+	u32			page_index;
 	/*
 	 * prev_pos is the 'pos' of the last object returned
 	 * by ->start of ->next.
@@ -387,79 +379,43 @@ struct seq_private {
 	loff_t			prev_pos;
 };
 
-static int vvp_pgcache_obj_get(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-			       struct hlist_node *hnode, void *data)
-{
-	struct vvp_pgcache_id   *id  = data;
-	struct lu_object_header *hdr = cfs_hash_object(hs, hnode);
-
-	if (lu_object_is_dying(hdr))
-		return 0;
-
-	if (id->vpi_curdep-- > 0)
-		return 0; /* continue */
-
-	cfs_hash_get(hs, hnode);
-	id->vpi_obj = hdr;
-	return 1;
-}
-
-static struct cl_object *vvp_pgcache_obj(const struct lu_env *env,
-					 struct lu_device *dev,
-					 struct vvp_pgcache_id *id)
-{
-	LASSERT(lu_device_is_cl(dev));
-
-	id->vpi_obj    = NULL;
-	id->vpi_curdep = id->vpi_depth;
-
-	cfs_hash_hlist_for_each(dev->ld_site->ls_obj_hash, id->vpi_bucket,
-				vvp_pgcache_obj_get, id);
-	if (id->vpi_obj) {
-		struct lu_object *lu_obj;
-
-		lu_obj = lu_object_locate(id->vpi_obj, dev->ld_type);
-		if (lu_obj) {
-			lu_object_ref_add(lu_obj, "dump", current);
-			return lu2cl(lu_obj);
-		}
-		lu_object_put(env, lu_object_top(id->vpi_obj));
-	}
-	return NULL;
-}
-
 static struct page *vvp_pgcache_current(struct seq_private *priv)
 {
 	struct lu_device *dev = &priv->sbi->ll_cl->cd_lu_dev;
 
+	rhashtable_walk_start(&priv->iter);
 	while(1) {
 		struct inode *inode;
 		int nr;
 		struct page *vmpage;
 
 		if (!priv->clob) {
-			struct cl_object *clob;
-
-			while ((clob = vvp_pgcache_obj(priv->env, dev, &priv->id)) == NULL &&
-			       ++(priv->id.vpi_bucket) < CFS_HASH_NHLIST(dev->ld_site->ls_obj_hash))
-				priv->id.vpi_depth = 0;
-			if (!clob)
+			struct lu_object_header *h;
+			struct lu_object *lu_obj;
+
+			while ((h = rhashtable_walk_next(&priv->iter)) != NULL &&
+			       (lu_obj = lu_object_get_first(h, dev)) == NULL)
+				;
+			if (!h) {
+				rhashtable_walk_stop(&priv->iter);
 				return NULL;
-			priv->clob = clob;
-			priv->id.vpi_index = 0;
+			}
+			priv->clob = lu2cl(lu_obj);
+			lu_object_ref_add(lu_obj, "dump", current);
+			priv->page_index = 0;
 		}
 
 		inode = vvp_object_inode(priv->clob);
-		nr = find_get_pages_contig(inode->i_mapping, priv->id.vpi_index, 1, &vmpage);
+		nr = find_get_pages_contig(inode->i_mapping, priv->page_index, 1, &vmpage);
 		if (nr > 0) {
-			priv->id.vpi_index = vmpage->index;
+			priv->page_index = vmpage->index;
+			rhashtable_walk_stop(&priv->iter);
 			return vmpage;
 		}
 		lu_object_ref_del(&priv->clob->co_lu, "dump", current);
 		cl_object_put(priv->env, priv->clob);
 		priv->clob = NULL;
-		priv->id.vpi_index = 0;
-		priv->id.vpi_depth++;
+		priv->page_index = 0;
 	}
 }
 
@@ -524,7 +480,9 @@ static int vvp_pgcache_show(struct seq_file *f, void *v)
 static void vvp_pgcache_rewind(struct seq_private *priv)
 {
 	if (priv->prev_pos) {
-		memset(&priv->id, 0, sizeof(priv->id));
+		struct lu_site *s = priv->sbi->ll_cl->cd_lu_dev.ld_site;
+		rhashtable_walk_exit(&priv->iter);
+		rhashtable_walk_enter(&s->ls_obj_hash, &priv->iter);
 		priv->prev_pos = 0;
 		if (priv->clob) {
 			lu_object_ref_del(&priv->clob->co_lu, "dump", current);
@@ -536,7 +494,7 @@ static void vvp_pgcache_rewind(struct seq_private *priv)
 
 static struct page *vvp_pgcache_next_page(struct seq_private *priv)
 {
-	priv->id.vpi_index += 1;
+	priv->page_index += 1;
 	return vvp_pgcache_current(priv);
 }
 
@@ -550,7 +508,7 @@ static void *vvp_pgcache_start(struct seq_file *f, loff_t *pos)
 		/* Return the current item */;
 	else {
 		WARN_ON(*pos != priv->prev_pos + 1);
-		priv->id.vpi_index += 1;
+		priv->page_index += 1;
 	}
 
 	priv->prev_pos = *pos;
@@ -582,6 +540,7 @@ static const struct seq_operations vvp_pgcache_ops = {
 static int vvp_dump_pgcache_seq_open(struct inode *inode, struct file *filp)
 {
 	struct seq_private *priv;
+	struct lu_site *s;
 
 	priv = __seq_open_private(filp, &vvp_pgcache_ops, sizeof(*priv));
 	if (!priv)
@@ -590,13 +549,16 @@ static int vvp_dump_pgcache_seq_open(struct inode *inode, struct file *filp)
 	priv->sbi = inode->i_private;
 	priv->env = cl_env_get(&priv->refcheck);
 	priv->clob = NULL;
-	memset(&priv->id, 0, sizeof(priv->id));
 
 	if (IS_ERR(priv->env)) {
 		int err = PTR_ERR(priv->env);
 		seq_release_private(inode, filp);
 		return err;
 	}
+
+	s = priv->sbi->ll_cl->cd_lu_dev.ld_site;
+	rhashtable_walk_enter(&s->ls_obj_hash, &priv->iter);
+
 	return 0;
 }
 
@@ -609,8 +571,8 @@ static int vvp_dump_pgcache_seq_release(struct inode *inode, struct file *file)
 		lu_object_ref_del(&priv->clob->co_lu, "dump", current);
 		cl_object_put(priv->env, priv->clob);
 	}
-
 	cl_env_put(priv->env, &priv->refcheck);
+	rhashtable_walk_exit(&priv->iter);
 	return seq_release_private(inode, file);
 }
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 18019f41c7a8..6ec5b83b3570 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -45,8 +45,6 @@
 
 #include <linux/module.h>
 
-/* hash_long() */
-#include <linux/libcfs/libcfs_hash.h>
 #include <obd_class.h>
 #include <obd_support.h>
 #include <lustre_disk.h>
@@ -88,9 +86,6 @@ enum {
 #define LU_CACHE_NR_LDISKFS_LIMIT	LU_CACHE_NR_UNLIMITED
 #define LU_CACHE_NR_ZFS_LIMIT		256
 
-#define LU_SITE_BITS_MIN	12
-#define LU_SITE_BITS_MAX	24
-#define LU_SITE_BITS_MAX_CL	19
 /**
  * max 256 buckets, we don't want too many buckets because:
  * - consume too much memory (currently max 16K)
@@ -126,6 +121,13 @@ lu_site_wq_from_fid(struct lu_site *site, struct lu_fid *fid)
 	return &bkt->lsb_marche_funebre;
 }
 
+static const struct rhashtable_params obj_hash_params = {
+	.key_len	= sizeof(struct lu_fid),
+	.key_offset	= offsetof(struct lu_object_header, loh_fid),
+	.head_offset	= offsetof(struct lu_object_header, loh_hash),
+	.automatic_shrinking = true,
+};
+
 /**
  * Decrease reference counter on object. If last reference is freed, return
  * object to the cache, unless lu_object_is_dying(o) holds. In the latter
@@ -137,7 +139,6 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 	struct lu_object_header *top;
 	struct lu_site	  *site;
 	struct lu_object	*orig;
-	struct cfs_hash_bd	    bd;
 	const struct lu_fid     *fid;
 
 	top  = o->lo_header;
@@ -151,7 +152,6 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 	 */
 	fid = lu_object_fid(o);
 	if (fid_is_zero(fid)) {
-		LASSERT(!top->loh_hash.next && !top->loh_hash.pprev);
 		LASSERT(list_empty(&top->loh_lru));
 		if (!atomic_dec_and_test(&top->loh_ref))
 			return;
@@ -163,9 +163,8 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 		return;
 	}
 
-	cfs_hash_bd_get(site->ls_obj_hash, &top->loh_fid, &bd);
-
-	if (!cfs_hash_bd_dec_and_lock(site->ls_obj_hash, &bd, &top->loh_ref)) {
+	if (atomic_add_unless(&top->loh_ref, -1, 1)) {
+	still_active:
 		if (lu_object_is_dying(top)) {
 			/*
 			 * somebody may be waiting for this, currently only
@@ -177,6 +176,16 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 		return;
 	}
 
+	bkt = &site->ls_bkts[lu_bkt_hash(site, &top->loh_fid)];
+	spin_lock(&bkt->lsb_marche_funebre.lock);
+	if (!atomic_dec_and_test(&top->loh_ref)) {
+		spin_unlock(&bkt->lsb_marche_funebre.lock);
+		goto still_active;
+	}
+	/* refcount is zero, and cannot be incremented without taking the
+	 * bkt lock, so object is stable.
+	 */
+
 	/*
 	 * When last reference is released, iterate over object
 	 * layers, and notify them that object is no longer busy.
@@ -186,17 +195,13 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 			o->lo_ops->loo_object_release(env, o);
 	}
 
-	bkt = &site->ls_bkts[lu_bkt_hash(site, &top->loh_fid)];
-	spin_lock(&bkt->lsb_marche_funebre.lock);
-
 	if (!lu_object_is_dying(top)) {
 		LASSERT(list_empty(&top->loh_lru));
 		list_add_tail(&top->loh_lru, &bkt->lsb_lru);
 		spin_unlock(&bkt->lsb_marche_funebre.lock);
 		percpu_counter_inc(&site->ls_lru_len_counter);
-		CDEBUG(D_INODE, "Add %p to site lru. hash: %p, bkt: %p\n",
-		       o, site->ls_obj_hash, bkt);
-		cfs_hash_bd_unlock(site->ls_obj_hash, &bd, 1);
+		CDEBUG(D_INODE, "Add %p to site lru. bkt: %p\n",
+		       o, bkt);
 		return;
 	}
 
@@ -204,16 +209,15 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 	 * If object is dying (will not be cached), then removed it
 	 * from hash table (it is already not on the LRU).
 	 *
-	 * This is done with hash table list locked. As the only
+	 * This is done with bucket lock held. As the only
 	 * way to acquire first reference to previously unreferenced
 	 * object is through hash-table lookup (lu_object_find())
-	 * which is done under hash-table, no race with concurrent
+	 * which takes the lock for first reference, no race with concurrent
 	 * object lookup is possible and we can safely destroy object below.
 	 */
 	if (!test_and_set_bit(LU_OBJECT_UNHASHED, &top->loh_flags))
-		cfs_hash_bd_del_locked(site->ls_obj_hash, &bd, &top->loh_hash);
+		rhashtable_remove_fast(&site->ls_obj_hash, &top->loh_hash, obj_hash_params);
 	spin_unlock(&bkt->lsb_marche_funebre.lock);
-	cfs_hash_bd_unlock(site->ls_obj_hash, &bd, 1);
 	/*
 	 * Object was already removed from hash above, can kill it.
 	 */
@@ -233,21 +237,19 @@ void lu_object_unhash(const struct lu_env *env, struct lu_object *o)
 	set_bit(LU_OBJECT_HEARD_BANSHEE, &top->loh_flags);
 	if (!test_and_set_bit(LU_OBJECT_UNHASHED, &top->loh_flags)) {
 		struct lu_site *site = o->lo_dev->ld_site;
-		struct cfs_hash *obj_hash = site->ls_obj_hash;
-		struct cfs_hash_bd bd;
+		struct rhashtable *obj_hash = &site->ls_obj_hash;
+		struct lu_site_bkt_data *bkt;
 
-		cfs_hash_bd_get_and_lock(obj_hash, &top->loh_fid, &bd, 1);
-		if (!list_empty(&top->loh_lru)) {
-			struct lu_site_bkt_data *bkt;
+		bkt = &site->ls_bkts[lu_bkt_hash(site,&top->loh_fid)];
+		spin_lock(&bkt->lsb_marche_funebre.lock);
 
-			bkt = &site->ls_bkts[lu_bkt_hash(site,&top->loh_fid)];
-			spin_lock(&bkt->lsb_marche_funebre.lock);
+		if (!list_empty(&top->loh_lru)) {
 			list_del_init(&top->loh_lru);
-			spin_unlock(&bkt->lsb_marche_funebre.lock);
 			percpu_counter_dec(&site->ls_lru_len_counter);
 		}
-		cfs_hash_bd_del_locked(obj_hash, &bd, &top->loh_hash);
-		cfs_hash_bd_unlock(obj_hash, &bd, 1);
+		spin_unlock(&bkt->lsb_marche_funebre.lock);
+
+		rhashtable_remove_fast(obj_hash, &top->loh_hash, obj_hash_params);
 	}
 }
 EXPORT_SYMBOL(lu_object_unhash);
@@ -419,11 +421,8 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
 
 			LINVRNT(lu_bkt_hash(s, &h->loh_fid) == i);
 
-			/* Cannot remove from hash under current spinlock,
-			 * so set flag to stop object from being found
-			 * by htable_lookup().
-			 */
-			set_bit(LU_OBJECT_HEARD_BANSHEE, &h->loh_flags);
+			rhashtable_remove_fast(&s->ls_obj_hash, &h->loh_hash,
+					       obj_hash_params);
 			list_move(&h->loh_lru, &dispose);
 			percpu_counter_dec(&s->ls_lru_len_counter);
 			if (did_sth == 0)
@@ -445,7 +444,6 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
 						     struct lu_object_header,
 						     loh_lru)) != NULL) {
 			list_del_init(&h->loh_lru);
-			cfs_hash_del(s->ls_obj_hash, &h->loh_fid, &h->loh_hash);
 			lu_object_free(env, lu_object_top(h));
 			lprocfs_counter_incr(s->ls_stats, LU_SS_LRU_PURGED);
 		}
@@ -555,9 +553,9 @@ void lu_object_header_print(const struct lu_env *env, void *cookie,
 	(*printer)(env, cookie, "header@%p[%#lx, %d, " DFID "%s%s%s]",
 		   hdr, hdr->loh_flags, atomic_read(&hdr->loh_ref),
 		   PFID(&hdr->loh_fid),
-		   hlist_unhashed(&hdr->loh_hash) ? "" : " hash",
-		   list_empty((struct list_head *)&hdr->loh_lru) ? \
-		   "" : " lru",
+		   test_bit(LU_OBJECT_UNHASHED,
+			    &hdr->loh_flags) ? "" : " hash",
+		   list_empty(&hdr->loh_lru) ? "" : " lru",
 		   hdr->loh_attr & LOHA_EXISTS ? " exist":"");
 }
 EXPORT_SYMBOL(lu_object_header_print);
@@ -594,39 +592,37 @@ void lu_object_print(const struct lu_env *env, void *cookie,
 EXPORT_SYMBOL(lu_object_print);
 
 static struct lu_object *htable_lookup(struct lu_site *s,
-				       struct cfs_hash_bd *bd,
+				       struct lu_site_bkt_data *bkt,
 				       const struct lu_fid *f,
-				       __u64 *version)
+				       struct lu_object_header *new)
 {
-	struct cfs_hash		*hs = s->ls_obj_hash;
-	struct lu_site_bkt_data *bkt;
 	struct lu_object_header *h;
-	struct hlist_node	*hnode;
-	__u64 ver;
 	wait_queue_entry_t waiter;
 
 retry:
-	ver = cfs_hash_bd_version_get(bd);
-
-	if (*version == ver) {
+	rcu_read_lock();
+	if (new)
+		h = rhashtable_lookup_get_insert_fast(&s->ls_obj_hash, &new->loh_hash,
+						      obj_hash_params);
+	else
+		h = rhashtable_lookup(&s->ls_obj_hash, f, obj_hash_params);
+	if (!h) {
+		/* Not found */
+		if (!new)
+			lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_MISS);
+		rcu_read_unlock();
 		return ERR_PTR(-ENOENT);
 	}
-
-	*version = ver;
-	/* cfs_hash_bd_peek_locked is a somehow "internal" function
-	 * of cfs_hash, it doesn't add refcount on object.
-	 */
-	hnode = cfs_hash_bd_peek_locked(s->ls_obj_hash, bd, (void *)f);
-	if (!hnode) {
-		lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_MISS);
-		return ERR_PTR(-ENOENT);
+	if (atomic_inc_not_zero(&h->loh_ref)) {
+		rcu_read_unlock();
+		return lu_object_top(h);
 	}
 
-	h = container_of(hnode, struct lu_object_header, loh_hash);
-	bkt = &s->ls_bkts[lu_bkt_hash(s, f)];
 	spin_lock(&bkt->lsb_marche_funebre.lock);
 	if (likely(!lu_object_is_dying(h))) {
-		cfs_hash_get(s->ls_obj_hash, hnode);
+		rcu_read_unlock();
+		atomic_inc(&h->loh_ref);
+
 		lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_HIT);
 		if (!list_empty(&h->loh_lru)) {
 			list_del_init(&h->loh_lru);
@@ -635,7 +631,7 @@ static struct lu_object *htable_lookup(struct lu_site *s,
 		spin_unlock(&bkt->lsb_marche_funebre.lock);
 		return lu_object_top(h);
 	}
-	spin_unlock(&bkt->lsb_marche_funebre.lock);
+	rcu_read_unlock();
 
 	/*
 	 * Lookup found an object being destroyed this object cannot be
@@ -647,10 +643,9 @@ static struct lu_object *htable_lookup(struct lu_site *s,
 	add_wait_queue(&bkt->lsb_marche_funebre, &waiter);
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_DEATH_RACE);
-	cfs_hash_bd_unlock(hs, bd, 1);
+	spin_unlock(&bkt->lsb_marche_funebre.lock);
 	schedule();
 	remove_wait_queue(&bkt->lsb_marche_funebre, &waiter);
-	cfs_hash_bd_lock(hs, bd, 1);
 	goto retry;
 }
 
@@ -681,7 +676,7 @@ static void lu_object_limit(const struct lu_env *env, struct lu_device *dev)
 	if (lu_cache_nr == LU_CACHE_NR_UNLIMITED)
 		return;
 
-	size = cfs_hash_size_get(dev->ld_site->ls_obj_hash);
+	size = atomic_read(&dev->ld_site->ls_obj_hash.nelems);
 	nr = (__u64)lu_cache_nr;
 	if (size <= nr)
 		return;
@@ -691,6 +686,35 @@ static void lu_object_limit(const struct lu_env *env, struct lu_device *dev)
 			      false);
 }
 
+/*
+ * Get a 'first' reference to an object that was found while looking
+ * through the hash table.
+ */
+struct lu_object *lu_object_get_first(struct lu_object_header *h,
+				      struct lu_device *dev)
+{
+	struct lu_object *ret;
+	struct lu_site	*s = dev->ld_site;
+
+	if (IS_ERR_OR_NULL(h) || lu_object_is_dying(h))
+		return NULL;
+
+	ret = lu_object_locate(h, dev->ld_type);
+	if (!ret)
+		return ret;
+	if (!atomic_inc_not_zero(&h->loh_ref)) {
+		struct lu_site_bkt_data *bkt = &s->ls_bkts[lu_bkt_hash(s, &h->loh_fid)];
+
+		spin_lock(&bkt->lsb_marche_funebre.lock);
+		if (!lu_object_is_dying(h))
+			atomic_inc(&h->loh_ref);
+		else
+			ret = NULL;
+		spin_unlock(&bkt->lsb_marche_funebre.lock);
+	}
+	return ret;
+}
+
 /**
  * Much like lu_object_find(), but top level device of object is specifically
  * \a dev rather than top level device of the site. This interface allows
@@ -704,9 +728,8 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 	struct lu_object      *o;
 	struct lu_object      *shadow;
 	struct lu_site	*s;
-	struct cfs_hash	    *hs;
-	struct cfs_hash_bd	  bd;
-	__u64		  version = 0;
+	struct rhashtable	*hs;
+	struct lu_site_bkt_data	*bkt;
 
 	/*
 	 * This uses standard index maintenance protocol:
@@ -727,13 +750,11 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 	 *
 	 */
 	s  = dev->ld_site;
-	hs = s->ls_obj_hash;
+	hs = &s->ls_obj_hash;
+	bkt = &s->ls_bkts[lu_bkt_hash(s, f)];
 
-	cfs_hash_bd_get(hs, f, &bd);
 	if (!(conf && conf->loc_flags & LOC_F_NEW)) {
-		cfs_hash_bd_lock(hs, &bd, 0);
-		o = htable_lookup(s, &bd, f, &version);
-		cfs_hash_bd_unlock(hs, &bd, 0);
+		o = htable_lookup(s, bkt, f, NULL);
 
 		if (!IS_ERR(o) || PTR_ERR(o) != -ENOENT)
 			return o;
@@ -748,15 +769,20 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 
 	LASSERT(lu_fid_eq(lu_object_fid(o), f));
 
-	cfs_hash_bd_lock(hs, &bd, 1);
+	if (conf && conf->loc_flags & LOC_F_NEW) {
+		int status = rhashtable_insert_fast(hs, &o->lo_header->loh_hash,
+						    obj_hash_params);
+		if (status == -EEXIST)
+			/* Already existed! go the slow way */
+			shadow = htable_lookup(s, bkt, f, o->lo_header);
+		else if (status)
+			shadow = ERR_PTR(status);
+		else
+			shadow = ERR_PTR(-ENOENT);
+	} else
+		shadow = htable_lookup(s, bkt, f, o->lo_header);
 
-	if (conf && conf->loc_flags & LOC_F_NEW)
-		shadow = ERR_PTR(-ENOENT);
-	else
-		shadow = htable_lookup(s, &bd, f, &version);
 	if (likely(PTR_ERR(shadow) == -ENOENT)) {
-		cfs_hash_bd_add_locked(hs, &bd, &o->lo_header->loh_hash);
-		cfs_hash_bd_unlock(hs, &bd, 1);
 
 		lu_object_limit(env, dev);
 
@@ -764,7 +790,6 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 	}
 
 	lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_RACE);
-	cfs_hash_bd_unlock(hs, &bd, 1);
 	lu_object_free(env, o);
 	return shadow;
 }
@@ -846,14 +871,9 @@ struct lu_site_print_arg {
 	lu_printer_t     lsp_printer;
 };
 
-static int
-lu_site_obj_print(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-		  struct hlist_node *hnode, void *data)
+static void
+lu_site_obj_print(struct lu_object_header *h, struct lu_site_print_arg *arg)
 {
-	struct lu_site_print_arg *arg = (struct lu_site_print_arg *)data;
-	struct lu_object_header  *h;
-
-	h = hlist_entry(hnode, struct lu_object_header, loh_hash);
 	if (!list_empty(&h->loh_layers)) {
 		const struct lu_object *o;
 
@@ -864,7 +884,6 @@ lu_site_obj_print(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 		lu_object_header_print(arg->lsp_env, arg->lsp_cookie,
 				       arg->lsp_printer, h);
 	}
-	return 0;
 }
 
 /**
@@ -878,115 +897,20 @@ void lu_site_print(const struct lu_env *env, struct lu_site *s, void *cookie,
 		.lsp_cookie  = cookie,
 		.lsp_printer = printer,
 	};
-
-	cfs_hash_for_each(s->ls_obj_hash, lu_site_obj_print, &arg);
-}
-EXPORT_SYMBOL(lu_site_print);
-
-/**
- * Return desired hash table order.
- */
-static unsigned long lu_htable_order(struct lu_device *top)
-{
-	unsigned long bits_max = LU_SITE_BITS_MAX;
-	unsigned long cache_size;
-	unsigned long bits;
-
-	if (!strcmp(top->ld_type->ldt_name, LUSTRE_VVP_NAME))
-		bits_max = LU_SITE_BITS_MAX_CL;
-
-	/*
-	 * Calculate hash table size, assuming that we want reasonable
-	 * performance when 20% of total memory is occupied by cache of
-	 * lu_objects.
-	 *
-	 * Size of lu_object is (arbitrary) taken as 1K (together with inode).
-	 */
-	cache_size = totalram_pages;
-
-#if BITS_PER_LONG == 32
-	/* limit hashtable size for lowmem systems to low RAM */
-	if (cache_size > 1 << (30 - PAGE_SHIFT))
-		cache_size = 1 << (30 - PAGE_SHIFT) * 3 / 4;
-#endif
-
-	/* clear off unreasonable cache setting. */
-	if (lu_cache_percent == 0 || lu_cache_percent > LU_CACHE_PERCENT_MAX) {
-		CWARN("obdclass: invalid lu_cache_percent: %u, it must be in the range of (0, %u]. Will use default value: %u.\n",
-		      lu_cache_percent, LU_CACHE_PERCENT_MAX,
-		      LU_CACHE_PERCENT_DEFAULT);
-
-		lu_cache_percent = LU_CACHE_PERCENT_DEFAULT;
-	}
-	cache_size = cache_size / 100 * lu_cache_percent *
-		(PAGE_SIZE / 1024);
-
-	for (bits = 1; (1 << bits) < cache_size; ++bits)
-		;
-	return clamp_t(typeof(bits), bits, LU_SITE_BITS_MIN, bits_max);
-}
-
-static unsigned int lu_obj_hop_hash(struct cfs_hash *hs,
-				    const void *key, unsigned int mask)
-{
-	struct lu_fid  *fid = (struct lu_fid *)key;
-	__u32	   hash;
-
-	hash = fid_flatten32(fid);
-	hash += (hash >> 4) + (hash << 12); /* mixing oid and seq */
-	hash = hash_long(hash, hs->hs_bkt_bits);
-
-	/* give me another random factor */
-	hash -= hash_long((unsigned long)hs, fid_oid(fid) % 11 + 3);
-
-	hash <<= hs->hs_cur_bits - hs->hs_bkt_bits;
-	hash |= (fid_seq(fid) + fid_oid(fid)) & (CFS_HASH_NBKT(hs) - 1);
-
-	return hash & mask;
-}
-
-static void *lu_obj_hop_object(struct hlist_node *hnode)
-{
-	return hlist_entry(hnode, struct lu_object_header, loh_hash);
-}
-
-static void *lu_obj_hop_key(struct hlist_node *hnode)
-{
 	struct lu_object_header *h;
-
-	h = hlist_entry(hnode, struct lu_object_header, loh_hash);
-	return &h->loh_fid;
-}
-
-static int lu_obj_hop_keycmp(const void *key, struct hlist_node *hnode)
-{
-	struct lu_object_header *h;
-
-	h = hlist_entry(hnode, struct lu_object_header, loh_hash);
-	return lu_fid_eq(&h->loh_fid, (struct lu_fid *)key);
-}
-
-static void lu_obj_hop_get(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-	struct lu_object_header *h;
-
-	h = hlist_entry(hnode, struct lu_object_header, loh_hash);
-	atomic_inc(&h->loh_ref);
-}
-
-static void lu_obj_hop_put_locked(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-	LBUG(); /* we should never called it */
+	struct rhashtable_iter iter;
+
+	rhashtable_walk_enter(&s->ls_obj_hash, &iter);
+	rhashtable_walk_start(&iter);
+	while ((h = rhashtable_walk_next(&iter)) != NULL) {
+		if (IS_ERR(h))
+			continue;
+		lu_site_obj_print(h, &arg);
+	}
+	rhashtable_walk_stop(&iter);
+	rhashtable_walk_exit(&iter);
 }
-
-static struct cfs_hash_ops lu_site_hash_ops = {
-	.hs_hash	= lu_obj_hop_hash,
-	.hs_key		= lu_obj_hop_key,
-	.hs_keycmp      = lu_obj_hop_keycmp,
-	.hs_object      = lu_obj_hop_object,
-	.hs_get		= lu_obj_hop_get,
-	.hs_put_locked  = lu_obj_hop_put_locked,
-};
+EXPORT_SYMBOL(lu_site_print);
 
 static void lu_dev_add_linkage(struct lu_site *s, struct lu_device *d)
 {
@@ -1002,9 +926,7 @@ static void lu_dev_add_linkage(struct lu_site *s, struct lu_device *d)
 int lu_site_init(struct lu_site *s, struct lu_device *top)
 {
 	struct lu_site_bkt_data *bkt;
-	unsigned long bits;
 	unsigned long i;
-	char name[16];
 	int rc;
 
 	memset(s, 0, sizeof(*s));
@@ -1014,23 +936,8 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 	if (rc)
 		return -ENOMEM;
 
-	snprintf(name, sizeof(name), "lu_site_%s", top->ld_type->ldt_name);
-	for (bits = lu_htable_order(top); bits >= LU_SITE_BITS_MIN; bits--) {
-		s->ls_obj_hash = cfs_hash_create(name, bits, bits,
-						 bits - LU_SITE_BKT_BITS,
-						 0, 0, 0,
-						 &lu_site_hash_ops,
-						 CFS_HASH_SPIN_BKTLOCK |
-						 CFS_HASH_NO_ITEMREF |
-						 CFS_HASH_DEPTH |
-						 CFS_HASH_ASSERT_EMPTY |
-						 CFS_HASH_COUNTER);
-		if (s->ls_obj_hash)
-			break;
-	}
-
-	if (!s->ls_obj_hash) {
-		CERROR("failed to create lu_site hash with bits: %lu\n", bits);
+	if (rhashtable_init(&s->ls_obj_hash, &obj_hash_params) != 0) {
+		CERROR("failed to create lu_site hash\n");
 		return -ENOMEM;
 	}
 
@@ -1038,8 +945,7 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 	s->ls_bkt_cnt = roundup_pow_of_two(s->ls_bkt_cnt);
 	s->ls_bkts = kvmalloc_array(s->ls_bkt_cnt, sizeof(*bkt), GFP_KERNEL);
 	if (!s->ls_bkts) {
-		cfs_hash_putref(s->ls_obj_hash);
-		s->ls_obj_hash = NULL;
+		rhashtable_destroy(&s->ls_obj_hash);
 		s->ls_bkts = NULL;
 		return -ENOMEM;
 	}
@@ -1052,9 +958,8 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 	s->ls_stats = lprocfs_alloc_stats(LU_SS_LAST_STAT, 0);
 	if (!s->ls_stats) {
 		kvfree(s->ls_bkts);
-		cfs_hash_putref(s->ls_obj_hash);
 		s->ls_bkts = NULL;
-		s->ls_obj_hash = NULL;
+		rhashtable_destroy(&s->ls_obj_hash);
 		return -ENOMEM;
 	}
 
@@ -1097,13 +1002,12 @@ void lu_site_fini(struct lu_site *s)
 
 	percpu_counter_destroy(&s->ls_lru_len_counter);
 
-	if (s->ls_obj_hash) {
-		cfs_hash_putref(s->ls_obj_hash);
-		s->ls_obj_hash = NULL;
+	if (s->ls_bkts) {
+		rhashtable_destroy(&s->ls_obj_hash);
+		kvfree(s->ls_bkts);
+		s->ls_bkts = NULL;
 	}
 
-	kvfree(s->ls_bkts);
-
 	if (s->ls_top_dev) {
 		s->ls_top_dev->ld_site = NULL;
 		lu_ref_del(&s->ls_top_dev->ld_reference, "site-top", s);
@@ -1259,7 +1163,6 @@ int lu_object_header_init(struct lu_object_header *h)
 {
 	memset(h, 0, sizeof(*h));
 	atomic_set(&h->loh_ref, 1);
-	INIT_HLIST_NODE(&h->loh_hash);
 	INIT_LIST_HEAD(&h->loh_lru);
 	INIT_LIST_HEAD(&h->loh_layers);
 	lu_ref_init(&h->loh_reference);
@@ -1274,7 +1177,6 @@ void lu_object_header_fini(struct lu_object_header *h)
 {
 	LASSERT(list_empty(&h->loh_layers));
 	LASSERT(list_empty(&h->loh_lru));
-	LASSERT(hlist_unhashed(&h->loh_hash));
 	lu_ref_fini(&h->loh_reference);
 }
 EXPORT_SYMBOL(lu_object_header_fini);
@@ -1815,7 +1717,7 @@ struct lu_site_stats {
 static void lu_site_stats_get(const struct lu_site *s,
 			      struct lu_site_stats *stats)
 {
-	int cnt = cfs_hash_size_get(s->ls_obj_hash);
+	int cnt = atomic_read(&s->ls_obj_hash.nelems);
 	/* percpu_counter_read_positive() won't accept a const pointer */
 	struct lu_site *s2 = (struct lu_site *)s;
 
@@ -2001,15 +1903,21 @@ static __u32 ls_stats_read(struct lprocfs_stats *stats, int idx)
 int lu_site_stats_print(const struct lu_site *s, struct seq_file *m)
 {
 	struct lu_site_stats stats;
+	const struct bucket_table *tbl;
+	long chains;
 
 	memset(&stats, 0, sizeof(stats));
 	lu_site_stats_get(s, &stats);
 
+	rcu_read_lock();
+	tbl = rht_dereference_rcu(s->ls_obj_hash.tbl, &((struct lu_site *)s)->ls_obj_hash);
+	chains = tbl->size;
+	rcu_read_unlock();
 	seq_printf(m, "%d/%d %d/%ld %d %d %d %d %d %d %d\n",
 		   stats.lss_busy,
 		   stats.lss_total,
 		   stats.lss_populated,
-		   CFS_HASH_NHLIST(s->ls_obj_hash),
+		   chains,
 		   stats.lss_max_search,
 		   ls_stats_read(s->ls_stats, LU_SS_CREATED),
 		   ls_stats_read(s->ls_stats, LU_SS_CACHE_HIT),
