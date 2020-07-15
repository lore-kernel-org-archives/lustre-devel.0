From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:47 -0400
Subject: [lustre-devel] [PATCH 06/37] lustre: lu_object: convert lu_object
 cache to rhashtable
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

The lu_object cache is a little more complex than the other lustre
hash tables for two reasons.
1/ there is a debugfs file which displays the contents of the cache,
   so we need to use rhashtable_walk in a way that works for seq_file.

2/ There is a (sharded) lru list for objects which are no longer
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

The lsb_waitq.lock is still used to manage the lru list, but with
this patch it is no longer nested *inside* the hashtable locks, but
instead is outside.  It is used to protect an object with a refcount
of zero.

When purging old objects from an lru, we first set
LU_OBJECT_HEARD_BANSHEE while holding the lsb_waitq.lock,
then remove all the entries from the hashtable separately.

When removing the last reference from an object, we first take the
lsb_waitq.lock, then decrement the reference and add to the lru list
or discard it setting LU_OBJECT_UNHASHED.

When we find an object in the hashtable with a refcount of zero, we
take the corresponding lsb_waitq.lock and check that neither
LU_OBJECT_HEARD_BANSHEE or LU_OBJECT_UNHASHED is set.  If neither is,
we can safely increment the refcount.  If either are, the object is
gone.

This way, we only ever manipulate an object with a refcount of zero
while holding the lsb_waitq.lock.

As there is nothing to stop us using the resizing capabilities of
rhashtable, the code to try to guess the perfect hash size has been
removed.

Also: the "is_dying" variable in lu_object_put() is racey - the value
could change the moment it is sampled.  It is also not needed as it is
only used to avoid a wakeup, which is not particularly expensive.
In the same code as comment says that 'top' could not be accessed, but
the code then immediately accesses 'top' to calculate 'bkt'.
So move the initialization of 'bkt' to before 'top' becomes unsafe.

Also: Change "wake_up_all()" to "wake_up()".  wake_up_all() is only
relevant when an exclusive wait is used.

Moving from the libcfs hashtable to rhashtable also gives the
benefit of a very large performance boost.

Before patch:

SUMMARY rate: (of 5 iterations)
   Operation                      Max            Min           Mean        Std Dev
   ---------                      ---            ---           ----        -------
   Directory creation:      12036.610      11091.880      11452.978        318.829
   Directory stat:          25871.734      24232.310      24935.661        574.996
   Directory removal:       12698.769      12239.685      12491.008        149.149
   File creation:           11722.036      11673.961      11692.157         15.966
   File stat:               62304.540      58237.124      60282.003       1479.103
   File read:               24204.811      23889.091      24048.577        110.245
   File removal:             9412.930       9111.828       9217.546        120.894
   Tree creation:            3515.536       3195.627       3442.609        123.792
   Tree removal:              433.917        418.935        428.038          5.545

After patch:

SUMMARY rate: (of 5 iterations)
   Operation                      Max            Min           Mean        Std Dev
   ---------                      ---            ---           ----        -------
   Directory creation:      11873.308        303.626       9371.860       4539.539
   Directory stat:          31116.512      30190.574      30568.091        335.545
   Directory removal:       13082.121      12645.228      12943.239        157.695
   File creation:           12607.135      12293.319      12466.647        138.307
   File stat:              124419.347     105240.996     116919.977       7847.165
   File read:               39707.270      36295.477      38266.011       1328.857
   File removal:             9614.333       9273.931       9477.299        140.201
   Tree creation:            3572.602       3017.580       3339.547        207.061
   Tree removal:              487.687          0.004        282.188        230.659

WC-bug-id: https://jira.whamcloud.com/browse/LU-8130
Lustre-commit: aff14dbc522e1 ("LU-8130 lu_object: convert lu_object cache to rhashtable")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36707
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h  |  20 +-
 fs/lustre/llite/vvp_dev.c      | 105 +++------
 fs/lustre/lov/lovsub_dev.c     |   5 +-
 fs/lustre/obdclass/lu_object.c | 481 +++++++++++++++++++----------------------
 4 files changed, 272 insertions(+), 339 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 2a2f38e..1a6b6e1 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -36,6 +36,7 @@
 
 #include <stdarg.h>
 #include <linux/percpu_counter.h>
+#include <linux/rhashtable.h>
 #include <linux/libcfs/libcfs.h>
 #include <linux/ctype.h>
 #include <obd_target.h>
@@ -469,11 +470,6 @@ enum lu_object_header_flags {
 	 * initialized yet, the object allocator will initialize it.
 	 */
 	LU_OBJECT_INITED	= 2,
-	/**
-	 * Object is being purged, so mustn't be returned by
-	 * htable_lookup()
-	 */
-	LU_OBJECT_PURGING	= 3,
 };
 
 enum lu_object_header_attr {
@@ -496,6 +492,8 @@ enum lu_object_header_attr {
  * it is created for things like not-yet-existing child created by mkdir or
  * create calls. lu_object_operations::loo_exists() can be used to check
  * whether object is backed by persistent storage entity.
+ * Any object containing this structre which might be placed in an
+ * rhashtable via loh_hash MUST be freed using call_rcu() or rcu_kfree().
  */
 struct lu_object_header {
 	/**
@@ -517,9 +515,9 @@ struct lu_object_header {
 	 */
 	u32			loh_attr;
 	/**
-	 * Linkage into per-site hash table. Protected by lu_site::ls_guard.
+	 * Linkage into per-site hash table.
 	 */
-	struct hlist_node	loh_hash;
+	struct rhash_head	loh_hash;
 	/**
 	 * Linkage into per-site LRU list. Protected by lu_site::ls_guard.
 	 */
@@ -566,7 +564,7 @@ struct lu_site {
 	/**
 	 * objects hash table
 	 */
-	struct cfs_hash	       *ls_obj_hash;
+	struct rhashtable	ls_obj_hash;
 	/*
 	 * buckets for summary data
 	 */
@@ -643,6 +641,8 @@ int lu_object_init(struct lu_object *o,
 void lu_object_fini(struct lu_object *o);
 void lu_object_add_top(struct lu_object_header *h, struct lu_object *o);
 void lu_object_add(struct lu_object *before, struct lu_object *o);
+struct lu_object *lu_object_get_first(struct lu_object_header *h,
+				      struct lu_device *dev);
 
 /**
  * Helpers to initialize and finalize device types.
@@ -697,8 +697,8 @@ static inline int lu_site_purge(const struct lu_env *env, struct lu_site *s,
 	return lu_site_purge_objects(env, s, nr, true);
 }
 
-void lu_site_print(const struct lu_env *env, struct lu_site *s, void *cookie,
-		   lu_printer_t printer);
+void lu_site_print(const struct lu_env *env, struct lu_site *s, atomic_t *ref,
+		   int msg_flags, lu_printer_t printer);
 struct lu_object *lu_object_find_at(const struct lu_env *env,
 				    struct lu_device *dev,
 				    const struct lu_fid *f,
diff --git a/fs/lustre/llite/vvp_dev.c b/fs/lustre/llite/vvp_dev.c
index e1d87f9..aa8b2c5 100644
--- a/fs/lustre/llite/vvp_dev.c
+++ b/fs/lustre/llite/vvp_dev.c
@@ -361,21 +361,13 @@ int cl_sb_fini(struct super_block *sb)
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
 struct vvp_seq_private {
 	struct ll_sb_info	*vsp_sbi;
 	struct lu_env		*vsp_env;
 	u16			 vsp_refcheck;
 	struct cl_object	*vsp_clob;
-	struct vvp_pgcache_id	 vsp_id;
+	struct rhashtable_iter	 vsp_iter;
+	u32			 vsp_page_index;
 	/*
 	 * prev_pos is the 'pos' of the last object returned
 	 * by ->start of ->next.
@@ -383,81 +375,43 @@ struct vvp_seq_private {
 	loff_t			 vsp_prev_pos;
 };
 
-static int vvp_pgcache_obj_get(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-			       struct hlist_node *hnode, void *data)
-{
-	struct vvp_pgcache_id *id = data;
-	struct lu_object_header *hdr = cfs_hash_object(hs, hnode);
-
-	if (lu_object_is_dying(hdr))
-		return 1;
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
-	id->vpi_obj = NULL;
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
 static struct page *vvp_pgcache_current(struct vvp_seq_private *priv)
 {
 	struct lu_device *dev = &priv->vsp_sbi->ll_cl->cd_lu_dev;
+	struct lu_object_header *h;
+	struct page *vmpage = NULL;
 
-	while (1) {
+	rhashtable_walk_start(&priv->vsp_iter);
+	while ((h = rhashtable_walk_next(&priv->vsp_iter)) != NULL) {
 		struct inode *inode;
-		struct page *vmpage;
 		int nr;
 
 		if (!priv->vsp_clob) {
-			struct cl_object *clob;
-
-			while ((clob = vvp_pgcache_obj(priv->vsp_env, dev, &priv->vsp_id)) == NULL &&
-			       ++(priv->vsp_id.vpi_bucket) < CFS_HASH_NHLIST(dev->ld_site->ls_obj_hash))
-				priv->vsp_id.vpi_depth = 0;
-			if (!clob)
-				return NULL;
-			priv->vsp_clob = clob;
-			priv->vsp_id.vpi_index = 0;
+			struct lu_object *lu_obj;
+
+			lu_obj = lu_object_get_first(h, dev);
+			if (!lu_obj)
+				continue;
+
+			priv->vsp_clob = lu2cl(lu_obj);
+			lu_object_ref_add(lu_obj, "dump", current);
+			priv->vsp_page_index = 0;
 		}
 
 		inode = vvp_object_inode(priv->vsp_clob);
 		nr = find_get_pages_contig(inode->i_mapping,
-					   priv->vsp_id.vpi_index, 1, &vmpage);
+					   priv->vsp_page_index, 1, &vmpage);
 		if (nr > 0) {
-			priv->vsp_id.vpi_index = vmpage->index;
-			return vmpage;
+			priv->vsp_page_index = vmpage->index;
+			break;
 		}
 		lu_object_ref_del(&priv->vsp_clob->co_lu, "dump", current);
 		cl_object_put(priv->vsp_env, priv->vsp_clob);
 		priv->vsp_clob = NULL;
-		priv->vsp_id.vpi_index = 0;
-		priv->vsp_id.vpi_depth++;
+		priv->vsp_page_index = 0;
 	}
+	rhashtable_walk_stop(&priv->vsp_iter);
+	return vmpage;
 }
 
 #define seq_page_flag(seq, page, flag, has_flags) do {			\
@@ -521,7 +475,10 @@ static int vvp_pgcache_show(struct seq_file *f, void *v)
 static void vvp_pgcache_rewind(struct vvp_seq_private *priv)
 {
 	if (priv->vsp_prev_pos) {
-		memset(&priv->vsp_id, 0, sizeof(priv->vsp_id));
+		struct lu_site *s = priv->vsp_sbi->ll_cl->cd_lu_dev.ld_site;
+
+		rhashtable_walk_exit(&priv->vsp_iter);
+		rhashtable_walk_enter(&s->ls_obj_hash, &priv->vsp_iter);
 		priv->vsp_prev_pos = 0;
 		if (priv->vsp_clob) {
 			lu_object_ref_del(&priv->vsp_clob->co_lu, "dump",
@@ -534,7 +491,7 @@ static void vvp_pgcache_rewind(struct vvp_seq_private *priv)
 
 static struct page *vvp_pgcache_next_page(struct vvp_seq_private *priv)
 {
-	priv->vsp_id.vpi_index += 1;
+	priv->vsp_page_index += 1;
 	return vvp_pgcache_current(priv);
 }
 
@@ -548,7 +505,7 @@ static void *vvp_pgcache_start(struct seq_file *f, loff_t *pos)
 		/* Return the current item */;
 	} else {
 		WARN_ON(*pos != priv->vsp_prev_pos + 1);
-		priv->vsp_id.vpi_index += 1;
+		priv->vsp_page_index += 1;
 	}
 
 	priv->vsp_prev_pos = *pos;
@@ -580,6 +537,7 @@ static void vvp_pgcache_stop(struct seq_file *f, void *v)
 static int vvp_dump_pgcache_seq_open(struct inode *inode, struct file *filp)
 {
 	struct vvp_seq_private *priv;
+	struct lu_site *s;
 
 	priv = __seq_open_private(filp, &vvp_pgcache_ops, sizeof(*priv));
 	if (!priv)
@@ -588,13 +546,16 @@ static int vvp_dump_pgcache_seq_open(struct inode *inode, struct file *filp)
 	priv->vsp_sbi = inode->i_private;
 	priv->vsp_env = cl_env_get(&priv->vsp_refcheck);
 	priv->vsp_clob = NULL;
-	memset(&priv->vsp_id, 0, sizeof(priv->vsp_id));
 	if (IS_ERR(priv->vsp_env)) {
 		int err = PTR_ERR(priv->vsp_env);
 
 		seq_release_private(inode, filp);
 		return err;
 	}
+
+	s = priv->vsp_sbi->ll_cl->cd_lu_dev.ld_site;
+	rhashtable_walk_enter(&s->ls_obj_hash, &priv->vsp_iter);
+
 	return 0;
 }
 
@@ -607,8 +568,8 @@ static int vvp_dump_pgcache_seq_release(struct inode *inode, struct file *file)
 		lu_object_ref_del(&priv->vsp_clob->co_lu, "dump", current);
 		cl_object_put(priv->vsp_env, priv->vsp_clob);
 	}
-
 	cl_env_put(priv->vsp_env, &priv->vsp_refcheck);
+	rhashtable_walk_exit(&priv->vsp_iter);
 	return seq_release_private(inode, file);
 }
 
diff --git a/fs/lustre/lov/lovsub_dev.c b/fs/lustre/lov/lovsub_dev.c
index 69380fc..0555737 100644
--- a/fs/lustre/lov/lovsub_dev.c
+++ b/fs/lustre/lov/lovsub_dev.c
@@ -88,10 +88,7 @@ static struct lu_device *lovsub_device_free(const struct lu_env *env,
 	struct lovsub_device *lsd = lu2lovsub_dev(d);
 	struct lu_device *next = cl2lu_dev(lsd->acid_next);
 
-	if (atomic_read(&d->ld_ref) && d->ld_site) {
-		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, D_ERROR, NULL);
-		lu_site_print(env, d->ld_site, &msgdata, lu_cdebug_printer);
-	}
+	lu_site_print(env, d->ld_site, &d->ld_ref, D_ERROR, lu_cdebug_printer);
 	cl_device_fini(lu2cl_dev(d));
 	kfree(lsd);
 	return next;
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index ec3f6a3..5cd8231 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -41,12 +41,11 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
+#include <linux/delay.h>
 #include <linux/module.h>
 #include <linux/processor.h>
 #include <linux/random.h>
 
-/* hash_long() */
-#include <linux/libcfs/libcfs_hash.h>
 #include <obd_class.h>
 #include <obd_support.h>
 #include <lustre_disk.h>
@@ -85,12 +84,10 @@ enum {
 #define LU_CACHE_NR_MAX_ADJUST		512
 #define LU_CACHE_NR_UNLIMITED		-1
 #define LU_CACHE_NR_DEFAULT		LU_CACHE_NR_UNLIMITED
-#define LU_CACHE_NR_LDISKFS_LIMIT	LU_CACHE_NR_UNLIMITED
-#define LU_CACHE_NR_ZFS_LIMIT		256
 
-#define LU_SITE_BITS_MIN		12
-#define LU_SITE_BITS_MAX		24
-#define LU_SITE_BITS_MAX_CL		19
+#define LU_CACHE_NR_MIN			4096
+#define LU_CACHE_NR_MAX			0x80000000UL
+
 /**
  * Max 256 buckets, we don't want too many buckets because:
  * - consume too much memory (currently max 16K)
@@ -111,7 +108,7 @@ enum {
 static void lu_object_free(const struct lu_env *env, struct lu_object *o);
 static u32 ls_stats_read(struct lprocfs_stats *stats, int idx);
 
-static u32 lu_fid_hash(const void *data, u32 seed)
+static u32 lu_fid_hash(const void *data, u32 len, u32 seed)
 {
 	const struct lu_fid *fid = data;
 
@@ -120,9 +117,17 @@ static u32 lu_fid_hash(const void *data, u32 seed)
 	return seed;
 }
 
+static const struct rhashtable_params obj_hash_params = {
+	.key_len	= sizeof(struct lu_fid),
+	.key_offset	= offsetof(struct lu_object_header, loh_fid),
+	.head_offset	= offsetof(struct lu_object_header, loh_hash),
+	.hashfn		= lu_fid_hash,
+	.automatic_shrinking = true,
+};
+
 static inline int lu_bkt_hash(struct lu_site *s, const struct lu_fid *fid)
 {
-	return lu_fid_hash(fid, s->ls_bkt_seed) &
+	return lu_fid_hash(fid, sizeof(*fid), s->ls_bkt_seed) &
 	       (s->ls_bkt_cnt - 1);
 }
 
@@ -147,9 +152,7 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 	struct lu_object_header *top = o->lo_header;
 	struct lu_site *site = o->lo_dev->ld_site;
 	struct lu_object *orig = o;
-	struct cfs_hash_bd bd;
 	const struct lu_fid *fid = lu_object_fid(o);
-	bool is_dying;
 
 	/*
 	 * till we have full fids-on-OST implemented anonymous objects
@@ -157,7 +160,6 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 	 * so we should not remove it from the site.
 	 */
 	if (fid_is_zero(fid)) {
-		LASSERT(!top->loh_hash.next && !top->loh_hash.pprev);
 		LASSERT(list_empty(&top->loh_lru));
 		if (!atomic_dec_and_test(&top->loh_ref))
 			return;
@@ -169,40 +171,45 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 		return;
 	}
 
-	cfs_hash_bd_get(site->ls_obj_hash, &top->loh_fid, &bd);
-
-	is_dying = lu_object_is_dying(top);
-	if (!cfs_hash_bd_dec_and_lock(site->ls_obj_hash, &bd, &top->loh_ref)) {
-		/* at this point the object reference is dropped and lock is
+	bkt = &site->ls_bkts[lu_bkt_hash(site, &top->loh_fid)];
+	if (atomic_add_unless(&top->loh_ref, -1, 1)) {
+still_active:
+		/*
+		 * At this point the object reference is dropped and lock is
 		 * not taken, so lu_object should not be touched because it
-		 * can be freed by concurrent thread. Use local variable for
-		 * check.
+		 * can be freed by concurrent thread.
+		 *
+		 * Somebody may be waiting for this, currently only used for
+		 * cl_object, see cl_object_put_last().
 		 */
-		if (is_dying) {
-			/*
-			 * somebody may be waiting for this, currently only
-			 * used for cl_object, see cl_object_put_last().
-			 */
-			bkt = &site->ls_bkts[lu_bkt_hash(site, &top->loh_fid)];
-			wake_up_all(&bkt->lsb_waitq);
-		}
+		wake_up(&bkt->lsb_waitq);
+
 		return;
 	}
 
+	spin_lock(&bkt->lsb_waitq.lock);
+	if (!atomic_dec_and_test(&top->loh_ref)) {
+		spin_unlock(&bkt->lsb_waitq.lock);
+		goto still_active;
+	}
+
 	/*
-	 * When last reference is released, iterate over object
-	 * layers, and notify them that object is no longer busy.
+	 * Refcount is zero, and cannot be incremented without taking the bkt
+	 * lock, so object is stable.
+	 */
+
+	/*
+	 * When last reference is released, iterate over object layers, and
+	 * notify them that object is no longer busy.
 	 */
 	list_for_each_entry_reverse(o, &top->loh_layers, lo_linkage) {
 		if (o->lo_ops->loo_object_release)
 			o->lo_ops->loo_object_release(env, o);
 	}
 
-	bkt = &site->ls_bkts[lu_bkt_hash(site, &top->loh_fid)];
-	spin_lock(&bkt->lsb_waitq.lock);
-
-	/* don't use local 'is_dying' here because if was taken without lock
-	 * but here we need the latest actual value of it so check lu_object
+	/*
+	 * Don't use local 'is_dying' here because if was taken without lock but
+	 * here we need the latest actual value of it so check lu_object
 	 * directly here.
 	 */
 	if (!lu_object_is_dying(top)) {
@@ -210,26 +217,26 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 		list_add_tail(&top->loh_lru, &bkt->lsb_lru);
 		spin_unlock(&bkt->lsb_waitq.lock);
 		percpu_counter_inc(&site->ls_lru_len_counter);
-		CDEBUG(D_INODE, "Add %p/%p to site lru. hash: %p, bkt: %p\n",
-		       orig, top, site->ls_obj_hash, bkt);
-		cfs_hash_bd_unlock(site->ls_obj_hash, &bd, 1);
+		CDEBUG(D_INODE, "Add %p/%p to site lru. bkt: %p\n",
+		       orig, top, bkt);
 		return;
 	}
 
 	/*
-	 * If object is dying (will not be cached), then removed it
-	 * from hash table (it is already not on the LRU).
+	 * If object is dying (will not be cached) then removed it from hash
+	 * table (it is already not on the LRU).
 	 *
-	 * This is done with hash table lists locked. As the only
-	 * way to acquire first reference to previously unreferenced
-	 * object is through hash-table lookup (lu_object_find())
-	 * which is done under hash-table, no race with concurrent
-	 * object lookup is possible and we can safely destroy object below.
+	 * This is done with bucket lock held. As the only way to acquire first
+	 * reference to previously unreferenced object is through hash-table
+	 * lookup (lu_object_find()) which takes the lock for first reference,
+	 * no race with concurrent object lookup is possible and we can safely
+	 * destroy object below.
 	 */
 	if (!test_and_set_bit(LU_OBJECT_UNHASHED, &top->loh_flags))
-		cfs_hash_bd_del_locked(site->ls_obj_hash, &bd, &top->loh_hash);
+		rhashtable_remove_fast(&site->ls_obj_hash, &top->loh_hash,
+				       obj_hash_params);
+
 	spin_unlock(&bkt->lsb_waitq.lock);
-	cfs_hash_bd_unlock(site->ls_obj_hash, &bd, 1);
 	/* Object was already removed from hash above, can kill it. */
 	lu_object_free(env, orig);
 }
@@ -247,21 +254,19 @@ void lu_object_unhash(const struct lu_env *env, struct lu_object *o)
 	set_bit(LU_OBJECT_HEARD_BANSHEE, &top->loh_flags);
 	if (!test_and_set_bit(LU_OBJECT_UNHASHED, &top->loh_flags)) {
 		struct lu_site *site = o->lo_dev->ld_site;
-		struct cfs_hash *obj_hash = site->ls_obj_hash;
-		struct cfs_hash_bd bd;
+		struct rhashtable *obj_hash = &site->ls_obj_hash;
+		struct lu_site_bkt_data *bkt;
 
-		cfs_hash_bd_get_and_lock(obj_hash, &top->loh_fid, &bd, 1);
+		bkt = &site->ls_bkts[lu_bkt_hash(site, &top->loh_fid)];
+		spin_lock(&bkt->lsb_waitq.lock);
 		if (!list_empty(&top->loh_lru)) {
-			struct lu_site_bkt_data *bkt;
-
-			bkt = &site->ls_bkts[lu_bkt_hash(site, &top->loh_fid)];
-			spin_lock(&bkt->lsb_waitq.lock);
 			list_del_init(&top->loh_lru);
-			spin_unlock(&bkt->lsb_waitq.lock);
 			percpu_counter_dec(&site->ls_lru_len_counter);
 		}
-		cfs_hash_bd_del_locked(obj_hash, &bd, &top->loh_hash);
-		cfs_hash_bd_unlock(obj_hash, &bd, 1);
+		spin_unlock(&bkt->lsb_waitq.lock);
+
+		rhashtable_remove_fast(obj_hash, &top->loh_hash,
+				       obj_hash_params);
 	}
 }
 EXPORT_SYMBOL(lu_object_unhash);
@@ -445,11 +450,9 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
 
 			LINVRNT(lu_bkt_hash(s, &h->loh_fid) == i);
 
-			/* Cannot remove from hash under current spinlock,
-			 * so set flag to stop object from being found
-			 * by htable_lookup().
-			 */
-			set_bit(LU_OBJECT_PURGING, &h->loh_flags);
+			set_bit(LU_OBJECT_UNHASHED, &h->loh_flags);
+			rhashtable_remove_fast(&s->ls_obj_hash, &h->loh_hash,
+					       obj_hash_params);
 			list_move(&h->loh_lru, &dispose);
 			percpu_counter_dec(&s->ls_lru_len_counter);
 			if (did_sth == 0)
@@ -470,7 +473,6 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
 		while ((h = list_first_entry_or_null(&dispose,
 						     struct lu_object_header,
 						     loh_lru)) != NULL) {
-			cfs_hash_del(s->ls_obj_hash, &h->loh_fid, &h->loh_hash);
 			list_del_init(&h->loh_lru);
 			lu_object_free(env, lu_object_top(h));
 			lprocfs_counter_incr(s->ls_stats, LU_SS_LRU_PURGED);
@@ -582,9 +584,9 @@ void lu_object_header_print(const struct lu_env *env, void *cookie,
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
@@ -621,54 +623,94 @@ void lu_object_print(const struct lu_env *env, void *cookie,
 EXPORT_SYMBOL(lu_object_print);
 
 /*
- * NOTE: htable_lookup() is called with the relevant
- * hash bucket locked, but might drop and re-acquire the lock.
+ * Limit the lu_object cache to a maximum of lu_cache_nr objects.  Because the
+ * calculation for the number of objects to reclaim is not covered by a lock the
+ * maximum number of objects is capped by LU_CACHE_MAX_ADJUST. This ensures
+ * that many concurrent threads will not accidentally purge the entire cache.
  */
-static struct lu_object *htable_lookup(struct lu_site *s,
-				       struct cfs_hash_bd *bd,
+static void lu_object_limit(const struct lu_env *env,
+			    struct lu_device *dev)
+{
+	u64 size, nr;
+
+	if (lu_cache_nr == LU_CACHE_NR_UNLIMITED)
+		return;
+
+	size = atomic_read(&dev->ld_site->ls_obj_hash.nelems);
+	nr = (u64)lu_cache_nr;
+	if (size <= nr)
+		return;
+
+	lu_site_purge_objects(env, dev->ld_site,
+			      min_t(u64, size - nr, LU_CACHE_NR_MAX_ADJUST),
+			      false);
+}
+
+static struct lu_object *htable_lookup(const struct lu_env *env,
+				       struct lu_device *dev,
+				       struct lu_site_bkt_data *bkt,
 				       const struct lu_fid *f,
-				       u64 *version)
+				       struct lu_object_header *new)
 {
+	struct lu_site *s = dev->ld_site;
 	struct lu_object_header *h;
-	struct hlist_node *hnode;
-	u64 ver = cfs_hash_bd_version_get(bd);
 
-	if (*version == ver)
+try_again:
+	rcu_read_lock();
+	if (new)
+		h = rhashtable_lookup_get_insert_fast(&s->ls_obj_hash,
+						      &new->loh_hash,
+						      obj_hash_params);
+	else
+		h = rhashtable_lookup(&s->ls_obj_hash, f, obj_hash_params);
+	if (IS_ERR_OR_NULL(h)) {
+		/* Not found */
+		if (!new)
+			lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_MISS);
+		rcu_read_unlock();
+		if (PTR_ERR(h) == -ENOMEM) {
+			msleep(20);
+			goto try_again;
+		}
+		lu_object_limit(env, dev);
+		if (PTR_ERR(h) == -E2BIG)
+			goto try_again;
+
 		return ERR_PTR(-ENOENT);
+	}
 
-	*version = ver;
-	/* cfs_hash_bd_peek_locked is a somehow "internal" function
-	 * of cfs_hash, it doesn't add refcount on object.
-	 */
-	hnode = cfs_hash_bd_peek_locked(s->ls_obj_hash, bd, (void *)f);
-	if (!hnode) {
+	if (atomic_inc_not_zero(&h->loh_ref)) {
+		rcu_read_unlock();
+		return lu_object_top(h);
+	}
+
+	spin_lock(&bkt->lsb_waitq.lock);
+	if (lu_object_is_dying(h) ||
+	    test_bit(LU_OBJECT_UNHASHED, &h->loh_flags)) {
+		spin_unlock(&bkt->lsb_waitq.lock);
+		rcu_read_unlock();
+		if (new) {
+			/*
+			 * Old object might have already been removed, or will
+			 * be soon.  We need to insert our new object, so
+			 * remove the old one just in case it is still there.
+			 */
+			rhashtable_remove_fast(&s->ls_obj_hash, &h->loh_hash,
+					       obj_hash_params);
+			goto try_again;
+		}
 		lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_MISS);
 		return ERR_PTR(-ENOENT);
 	}
+	/* Now protected by spinlock */
+	rcu_read_unlock();
 
-	h = container_of(hnode, struct lu_object_header, loh_hash);
 	if (!list_empty(&h->loh_lru)) {
-		struct lu_site_bkt_data *bkt;
-
-		bkt = &s->ls_bkts[lu_bkt_hash(s, &h->loh_fid)];
-		spin_lock(&bkt->lsb_waitq.lock);
-		/* Might have just been moved to the dispose list, in which
-		 * case LU_OBJECT_PURGING will be set.  In that case,
-		 * delete it from the hash table immediately.
-		 * When lu_site_purge_objects() tried, it will find it
-		 * isn't there, which is harmless.
-		 */
-		if (test_bit(LU_OBJECT_PURGING, &h->loh_flags)) {
-			spin_unlock(&bkt->lsb_waitq.lock);
-			cfs_hash_bd_del_locked(s->ls_obj_hash, bd, hnode);
-			lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_MISS);
-			return ERR_PTR(-ENOENT);
-		}
 		list_del_init(&h->loh_lru);
-		spin_unlock(&bkt->lsb_waitq.lock);
 		percpu_counter_dec(&s->ls_lru_len_counter);
 	}
-	cfs_hash_get(s->ls_obj_hash, hnode);
+	atomic_inc(&h->loh_ref);
+	spin_unlock(&bkt->lsb_waitq.lock);
 	lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_HIT);
 	return lu_object_top(h);
 }
@@ -687,28 +729,37 @@ static struct lu_object *lu_object_find(const struct lu_env *env,
 }
 
 /*
- * Limit the lu_object cache to a maximum of lu_cache_nr objects.  Because
- * the calculation for the number of objects to reclaim is not covered by
- * a lock the maximum number of objects is capped by LU_CACHE_MAX_ADJUST.
- * This ensures that many concurrent threads will not accidentally purge
- * the entire cache.
+ * Get a 'first' reference to an object that was found while looking through the
+ * hash table.
  */
-static void lu_object_limit(const struct lu_env *env, struct lu_device *dev)
+struct lu_object *lu_object_get_first(struct lu_object_header *h,
+				      struct lu_device *dev)
 {
-	u64 size, nr;
+	struct lu_site *s = dev->ld_site;
+	struct lu_object *ret;
 
-	if (lu_cache_nr == LU_CACHE_NR_UNLIMITED)
-		return;
+	if (IS_ERR_OR_NULL(h) || lu_object_is_dying(h))
+		return NULL;
 
-	size = cfs_hash_size_get(dev->ld_site->ls_obj_hash);
-	nr = (u64)lu_cache_nr;
-	if (size <= nr)
-		return;
+	ret = lu_object_locate(h, dev->ld_type);
+	if (!ret)
+		return ret;
 
-	lu_site_purge_objects(env, dev->ld_site,
-			      min_t(u64, size - nr, LU_CACHE_NR_MAX_ADJUST),
-			      false);
+	if (!atomic_inc_not_zero(&h->loh_ref)) {
+		struct lu_site_bkt_data *bkt;
+
+		bkt = &s->ls_bkts[lu_bkt_hash(s, &h->loh_fid)];
+		spin_lock(&bkt->lsb_waitq.lock);
+		if (!lu_object_is_dying(h) &&
+		    !test_bit(LU_OBJECT_UNHASHED, &h->loh_flags))
+			atomic_inc(&h->loh_ref);
+		else
+			ret = NULL;
+		spin_unlock(&bkt->lsb_waitq.lock);
+	}
+	return ret;
 }
+EXPORT_SYMBOL(lu_object_get_first);
 
 /**
  * Core logic of lu_object_find*() functions.
@@ -725,10 +776,8 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 	struct lu_object *o;
 	struct lu_object *shadow;
 	struct lu_site *s;
-	struct cfs_hash	*hs;
-	struct cfs_hash_bd bd;
 	struct lu_site_bkt_data *bkt;
-	u64 version = 0;
+	struct rhashtable *hs;
 	int rc;
 
 	/*
@@ -750,16 +799,13 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 	 *
 	 */
 	s  = dev->ld_site;
-	hs = s->ls_obj_hash;
+	hs = &s->ls_obj_hash;
 	if (unlikely(OBD_FAIL_PRECHECK(OBD_FAIL_OBD_ZERO_NLINK_RACE)))
 		lu_site_purge(env, s, -1);
 
 	bkt = &s->ls_bkts[lu_bkt_hash(s, f)];
-	cfs_hash_bd_get(hs, f, &bd);
 	if (!(conf && conf->loc_flags & LOC_F_NEW)) {
-		cfs_hash_bd_lock(hs, &bd, 1);
-		o = htable_lookup(s, &bd, f, &version);
-		cfs_hash_bd_unlock(hs, &bd, 1);
+		o = htable_lookup(env, dev, bkt, f, NULL);
 
 		if (!IS_ERR(o)) {
 			if (likely(lu_object_is_inited(o->lo_header)))
@@ -795,29 +841,31 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 
 	CFS_RACE_WAIT(OBD_FAIL_OBD_ZERO_NLINK_RACE);
 
-	cfs_hash_bd_lock(hs, &bd, 1);
-
-	if (conf && conf->loc_flags & LOC_F_NEW)
-		shadow = ERR_PTR(-ENOENT);
-	else
-		shadow = htable_lookup(s, &bd, f, &version);
+	if (conf && conf->loc_flags & LOC_F_NEW) {
+		int status = rhashtable_insert_fast(hs, &o->lo_header->loh_hash,
+						    obj_hash_params);
+		if (status)
+			/* Strange error - go the slow way */
+			shadow = htable_lookup(env, dev, bkt, f, o->lo_header);
+		else
+			shadow = ERR_PTR(-ENOENT);
+	} else {
+		shadow = htable_lookup(env, dev, bkt, f, o->lo_header);
+	}
 	if (likely(PTR_ERR(shadow) == -ENOENT)) {
-		cfs_hash_bd_add_locked(hs, &bd, &o->lo_header->loh_hash);
-		cfs_hash_bd_unlock(hs, &bd, 1);
-
 		/*
+		 * The new object has been successfully inserted.
+		 *
 		 * This may result in rather complicated operations, including
 		 * fld queries, inode loading, etc.
 		 */
 		rc = lu_object_start(env, dev, o, conf);
 		if (rc) {
-			set_bit(LU_OBJECT_HEARD_BANSHEE,
-				&o->lo_header->loh_flags);
 			lu_object_put(env, o);
 			return ERR_PTR(rc);
 		}
 
-		wake_up_all(&bkt->lsb_waitq);
+		wake_up(&bkt->lsb_waitq);
 
 		lu_object_limit(env, dev);
 
@@ -825,10 +873,10 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 	}
 
 	lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_RACE);
-	cfs_hash_bd_unlock(hs, &bd, 1);
 	lu_object_free(env, o);
 
 	if (!(conf && conf->loc_flags & LOC_F_NEW) &&
+	    !IS_ERR(shadow) &&
 	    !lu_object_is_inited(shadow->lo_header)) {
 		wait_event_idle(bkt->lsb_waitq,
 				lu_object_is_inited(shadow->lo_header) ||
@@ -906,14 +954,9 @@ struct lu_site_print_arg {
 	lu_printer_t		 lsp_printer;
 };
 
-static int
-lu_site_obj_print(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-		  struct hlist_node *hnode, void *data)
+static void
+lu_site_obj_print(struct lu_object_header *h, struct lu_site_print_arg *arg)
 {
-	struct lu_site_print_arg *arg = (struct lu_site_print_arg *)data;
-	struct lu_object_header *h;
-
-	h = hlist_entry(hnode, struct lu_object_header, loh_hash);
 	if (!list_empty(&h->loh_layers)) {
 		const struct lu_object *o;
 
@@ -924,36 +967,45 @@ struct lu_site_print_arg {
 		lu_object_header_print(arg->lsp_env, arg->lsp_cookie,
 				       arg->lsp_printer, h);
 	}
-	return 0;
 }
 
 /**
  * Print all objects in @s.
  */
-void lu_site_print(const struct lu_env *env, struct lu_site *s, void *cookie,
-		   lu_printer_t printer)
+void lu_site_print(const struct lu_env *env, struct lu_site *s, atomic_t *ref,
+		   int msg_flag, lu_printer_t printer)
 {
 	struct lu_site_print_arg arg = {
 		.lsp_env	= (struct lu_env *)env,
-		.lsp_cookie	= cookie,
 		.lsp_printer	= printer,
 	};
+	struct rhashtable_iter iter;
+	struct lu_object_header *h;
+	LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, msg_flag, NULL);
+
+	if (!s || !atomic_read(ref))
+		return;
 
-	cfs_hash_for_each(s->ls_obj_hash, lu_site_obj_print, &arg);
+	arg.lsp_cookie = (void *)&msgdata;
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
 EXPORT_SYMBOL(lu_site_print);
 
 /**
  * Return desired hash table order.
  */
-static unsigned long lu_htable_order(struct lu_device *top)
+static void lu_htable_limits(struct lu_device *top)
 {
-	unsigned long bits_max = LU_SITE_BITS_MAX;
 	unsigned long cache_size;
-	unsigned long bits;
-
-	if (!strcmp(top->ld_type->ldt_name, LUSTRE_VVP_NAME))
-		bits_max = LU_SITE_BITS_MAX_CL;
 
 	/*
 	 * Calculate hash table size, assuming that we want reasonable
@@ -979,75 +1031,12 @@ static unsigned long lu_htable_order(struct lu_device *top)
 		lu_cache_percent = LU_CACHE_PERCENT_DEFAULT;
 	}
 	cache_size = cache_size / 100 * lu_cache_percent *
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
-	struct lu_fid *fid = (struct lu_fid *)key;
-	u32 hash;
+		     (PAGE_SIZE / 1024);
 
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
-	struct lu_object_header *h;
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
+	lu_cache_nr = clamp_t(typeof(cache_size), cache_size,
+			      LU_CACHE_NR_MIN, LU_CACHE_NR_MAX);
 }
 
-static void lu_obj_hop_put_locked(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-	LBUG(); /* we should never called it */
-}
-
-static struct cfs_hash_ops lu_site_hash_ops = {
-	.hs_hash	= lu_obj_hop_hash,
-	.hs_key		= lu_obj_hop_key,
-	.hs_keycmp	= lu_obj_hop_keycmp,
-	.hs_object	= lu_obj_hop_object,
-	.hs_get		= lu_obj_hop_get,
-	.hs_put_locked	= lu_obj_hop_put_locked,
-};
-
 static void lu_dev_add_linkage(struct lu_site *s, struct lu_device *d)
 {
 	spin_lock(&s->ls_ld_lock);
@@ -1062,35 +1051,19 @@ static void lu_dev_add_linkage(struct lu_site *s, struct lu_device *d)
 int lu_site_init(struct lu_site *s, struct lu_device *top)
 {
 	struct lu_site_bkt_data *bkt;
-	unsigned long bits;
-	unsigned long i;
-	char name[16];
+	unsigned int i;
 	int rc;
 
 	memset(s, 0, sizeof(*s));
 	mutex_init(&s->ls_purge_mutex);
+	lu_htable_limits(top);
 
 	rc = percpu_counter_init(&s->ls_lru_len_counter, 0, GFP_NOFS);
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
 
@@ -1101,8 +1074,7 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 	s->ls_bkts = kvmalloc_array(s->ls_bkt_cnt, sizeof(*bkt),
 				    GFP_KERNEL | __GFP_ZERO);
 	if (!s->ls_bkts) {
-		cfs_hash_putref(s->ls_obj_hash);
-		s->ls_obj_hash = NULL;
+		rhashtable_destroy(&s->ls_obj_hash);
 		s->ls_bkts = NULL;
 		return -ENOMEM;
 	}
@@ -1116,9 +1088,8 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 	s->ls_stats = lprocfs_alloc_stats(LU_SS_LAST_STAT, 0);
 	if (!s->ls_stats) {
 		kvfree(s->ls_bkts);
-		cfs_hash_putref(s->ls_obj_hash);
-		s->ls_obj_hash = NULL;
 		s->ls_bkts = NULL;
+		rhashtable_destroy(&s->ls_obj_hash);
 		return -ENOMEM;
 	}
 
@@ -1161,13 +1132,12 @@ void lu_site_fini(struct lu_site *s)
 
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
@@ -1323,7 +1293,6 @@ int lu_object_header_init(struct lu_object_header *h)
 {
 	memset(h, 0, sizeof(*h));
 	atomic_set(&h->loh_ref, 1);
-	INIT_HLIST_NODE(&h->loh_hash);
 	INIT_LIST_HEAD(&h->loh_lru);
 	INIT_LIST_HEAD(&h->loh_layers);
 	lu_ref_init(&h->loh_reference);
@@ -1338,7 +1307,6 @@ void lu_object_header_fini(struct lu_object_header *h)
 {
 	LASSERT(list_empty(&h->loh_layers));
 	LASSERT(list_empty(&h->loh_lru));
-	LASSERT(hlist_unhashed(&h->loh_hash));
 	lu_ref_fini(&h->loh_reference);
 }
 EXPORT_SYMBOL(lu_object_header_fini);
@@ -1933,7 +1901,7 @@ struct lu_site_stats {
 static void lu_site_stats_get(const struct lu_site *s,
 			      struct lu_site_stats *stats)
 {
-	int cnt = cfs_hash_size_get(s->ls_obj_hash);
+	int cnt = atomic_read(&s->ls_obj_hash.nelems);
 	/*
 	 * percpu_counter_sum_positive() won't accept a const pointer
 	 * as it does modify the struct by taking a spinlock
@@ -2235,16 +2203,23 @@ static u32 ls_stats_read(struct lprocfs_stats *stats, int idx)
  */
 int lu_site_stats_print(const struct lu_site *s, struct seq_file *m)
 {
+	const struct bucket_table *tbl;
 	struct lu_site_stats stats;
+	unsigned int chains;
 
 	memset(&stats, 0, sizeof(stats));
 	lu_site_stats_get(s, &stats);
 
-	seq_printf(m, "%d/%d %d/%ld %d %d %d %d %d %d %d\n",
+	rcu_read_lock();
+	tbl = rht_dereference_rcu(s->ls_obj_hash.tbl,
+				  &((struct lu_site *)s)->ls_obj_hash);
+	chains = tbl->size;
+	rcu_read_unlock();
+	seq_printf(m, "%d/%d %d/%u %d %d %d %d %d %d %d\n",
 		   stats.lss_busy,
 		   stats.lss_total,
 		   stats.lss_populated,
-		   CFS_HASH_NHLIST(s->ls_obj_hash),
+		   chains,
 		   stats.lss_max_search,
 		   ls_stats_read(s->ls_stats, LU_SS_CREATED),
 		   ls_stats_read(s->ls_stats, LU_SS_CACHE_HIT),
-- 
1.8.3.1
