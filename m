From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:54 -0500
Subject: [lustre-devel] [PATCH 426/622] lustre: obdclass: 0-nlink race in
 lu_object_find_at()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-427-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

There is a race in lu_object_find_at: in the gap between
lu_object_alloc() and hash insertion, another thread may
have allocated another object for the same file and unlinked
it, so we may get an object with 0-nlink, which will trigger
assertion in osd_object_release().

To avoid such race, initialize object after hash insertion.
But this may cause an uninitialized object found in cache, if
so, wait for the object initialized by the allocator.

To reproduce the race, introduced cfs_race_wait() and
cfs_race_wakeup(): cfs_race_wait() will cause the thread that
calls it wait on the race; while cfs_race_wakeup() will wake
up the waiting thread. Same as cfs_race(), CFS_FAIL_ONCE
should be set together with fail_loc.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12485
Lustre-commit: 2ff420913b97 ("LU-12485 obdclass: 0-nlink race in lu_object_find_at()")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35360
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h      |  15 ++++-
 fs/lustre/include/obd_support.h    |   1 +
 fs/lustre/obdclass/lu_object.c     | 127 ++++++++++++++++++++++++++++---------
 include/linux/libcfs/libcfs_fail.h |  40 +++++++++++-
 4 files changed, 151 insertions(+), 32 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index d2e84a3..1c1a60f 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -461,7 +461,12 @@ enum lu_object_header_flags {
 	/**
 	 * Mark this object has already been taken out of cache.
 	 */
-	LU_OBJECT_UNHASHED = 1,
+	LU_OBJECT_UNHASHED	= 1,
+	/**
+	 * Object is initialized, when object is found in cache, it may not be
+	 * initialized yet, the object allocator will initialize it.
+	 */
+	LU_OBJECT_INITED	= 2
 };
 
 enum lu_object_header_attr {
@@ -656,6 +661,14 @@ static inline int lu_object_is_dying(const struct lu_object_header *h)
 	return test_bit(LU_OBJECT_HEARD_BANSHEE, &h->loh_flags);
 }
 
+/**
+ * Return true if object is initialized.
+ */
+static inline int lu_object_is_inited(const struct lu_object_header *h)
+{
+	return test_bit(LU_OBJECT_INITED, &h->loh_flags);
+}
+
 void lu_object_put(const struct lu_env *env, struct lu_object *o);
 void lu_object_unhash(const struct lu_env *env, struct lu_object *o);
 int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s, int nr,
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index c66b61a..506535b 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -371,6 +371,7 @@
 #define OBD_FAIL_OBD_IDX_READ_BREAK			0x608
 #define OBD_FAIL_OBD_NO_LRU				0x609
 #define OBD_FAIL_OBDCLASS_MODULE_LOAD			0x60a
+#define OBD_FAIL_OBD_ZERO_NLINK_RACE	 0x60b
 
 #define OBD_FAIL_TGT_REPLY_NET				0x700
 #define OBD_FAIL_TGT_CONN_RACE				0x701
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index d8bff3f..6fea1f3 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -67,13 +67,14 @@ struct lu_site_bkt_data {
 	struct list_head		lsb_lru;
 	/**
 	 * Wait-queue signaled when an object in this site is ultimately
-	 * destroyed (lu_object_free()). It is used by lu_object_find() to
-	 * wait before re-trying when object in the process of destruction is
-	 * found in the hash table.
+	 * destroyed (lu_object_free()) or initialized (lu_object_start()).
+	 * It is used by lu_object_find() to wait before re-trying when
+	 * object in the process of destruction is found in the hash table;
+	 * or wait object to be initialized by the allocator.
 	 *
 	 * \see htable_lookup().
 	 */
-	wait_queue_head_t		lsb_marche_funebre;
+	wait_queue_head_t		lsb_waitq;
 };
 
 enum {
@@ -116,7 +117,7 @@ enum {
 
 	cfs_hash_bd_get(site->ls_obj_hash, fid, &bd);
 	bkt = cfs_hash_bd_extra_get(site->ls_obj_hash, &bd);
-	return &bkt->lsb_marche_funebre;
+	return &bkt->lsb_waitq;
 }
 EXPORT_SYMBOL(lu_site_wq_from_fid);
 
@@ -168,7 +169,7 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 			 * somebody may be waiting for this, currently only
 			 * used for cl_object, see cl_object_put_last().
 			 */
-			wake_up_all(&bkt->lsb_marche_funebre);
+			wake_up_all(&bkt->lsb_waitq);
 		}
 		return;
 	}
@@ -255,16 +256,9 @@ void lu_object_unhash(const struct lu_env *env, struct lu_object *o)
  */
 static struct lu_object *lu_object_alloc(const struct lu_env *env,
 					 struct lu_device *dev,
-					 const struct lu_fid *f,
-					 const struct lu_object_conf *conf)
+					 const struct lu_fid *f)
 {
-	struct lu_object *scan;
 	struct lu_object *top;
-	struct list_head *layers;
-	unsigned int init_mask = 0;
-	unsigned int init_flag;
-	int clean;
-	int result;
 
 	/*
 	 * Create top-level object slice. This will also create
@@ -280,6 +274,27 @@ static struct lu_object *lu_object_alloc(const struct lu_env *env,
 	 * after this point.
 	 */
 	top->lo_header->loh_fid = *f;
+
+	return top;
+}
+
+/**
+ * Initialize object.
+ *
+ * This is called after object hash insertion to avoid returning an object with
+ * stale attributes.
+ */
+static int lu_object_start(const struct lu_env *env, struct lu_device *dev,
+			   struct lu_object *top,
+			   const struct lu_object_conf *conf)
+{
+	struct lu_object *scan;
+	struct list_head *layers;
+	unsigned int init_mask = 0;
+	unsigned int init_flag;
+	int clean;
+	int result;
+
 	layers = &top->lo_header->loh_layers;
 
 	do {
@@ -295,10 +310,9 @@ static struct lu_object *lu_object_alloc(const struct lu_env *env,
 			clean = 0;
 			scan->lo_header = top->lo_header;
 			result = scan->lo_ops->loo_object_init(env, scan, conf);
-			if (result != 0) {
-				lu_object_free(env, top);
-				return ERR_PTR(result);
-			}
+			if (result)
+				return result;
+
 			init_mask |= init_flag;
 next:
 			init_flag <<= 1;
@@ -308,15 +322,16 @@ static struct lu_object *lu_object_alloc(const struct lu_env *env,
 	list_for_each_entry_reverse(scan, layers, lo_linkage) {
 		if (scan->lo_ops->loo_object_start) {
 			result = scan->lo_ops->loo_object_start(env, scan);
-			if (result != 0) {
-				lu_object_free(env, top);
-				return ERR_PTR(result);
-			}
+			if (result)
+				return result;
 		}
 	}
 
 	lprocfs_counter_incr(dev->ld_site->ls_stats, LU_SS_CREATED);
-	return top;
+
+	set_bit(LU_OBJECT_INITED, &top->lo_header->loh_flags);
+
+	return 0;
 }
 
 /**
@@ -598,7 +613,6 @@ static struct lu_object *htable_lookup(struct lu_site *s,
 				       const struct lu_fid *f,
 				       u64 *version)
 {
-	struct lu_site_bkt_data *bkt;
 	struct lu_object_header *h;
 	struct hlist_node *hnode;
 	u64 ver = cfs_hash_bd_version_get(bd);
@@ -607,7 +621,6 @@ static struct lu_object *htable_lookup(struct lu_site *s,
 		return ERR_PTR(-ENOENT);
 
 	*version = ver;
-	bkt = cfs_hash_bd_extra_get(s->ls_obj_hash, bd);
 	/* cfs_hash_bd_peek_locked is a somehow "internal" function
 	 * of cfs_hash, it doesn't add refcount on object.
 	 */
@@ -681,7 +694,9 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 	struct lu_site *s;
 	struct cfs_hash	*hs;
 	struct cfs_hash_bd bd;
+	struct lu_site_bkt_data *bkt;
 	u64 version = 0;
+	int rc;
 
 	/*
 	 * This uses standard index maintenance protocol:
@@ -703,26 +718,50 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 	 */
 	s  = dev->ld_site;
 	hs = s->ls_obj_hash;
+	if (unlikely(OBD_FAIL_PRECHECK(OBD_FAIL_OBD_ZERO_NLINK_RACE)))
+		lu_site_purge(env, s, -1);
 
 	cfs_hash_bd_get(hs, f, &bd);
+	bkt = cfs_hash_bd_extra_get(s->ls_obj_hash, &bd);
 	if (!(conf && conf->loc_flags & LOC_F_NEW)) {
 		cfs_hash_bd_lock(hs, &bd, 1);
 		o = htable_lookup(s, &bd, f, &version);
 		cfs_hash_bd_unlock(hs, &bd, 1);
 
-		if (!IS_ERR(o) || PTR_ERR(o) != -ENOENT)
+		if (!IS_ERR(o)) {
+			if (likely(lu_object_is_inited(o->lo_header)))
+				return o;
+
+			wait_event_idle(bkt->lsb_waitq,
+					lu_object_is_inited(o->lo_header) ||
+					lu_object_is_dying(o->lo_header));
+
+			if (lu_object_is_dying(o->lo_header)) {
+				lu_object_put(env, o);
+
+				return ERR_PTR(-ENOENT);
+			}
+
+			return o;
+		}
+
+		if (PTR_ERR(o) != -ENOENT)
 			return o;
 	}
+
 	/*
-	 * Allocate new object. This may result in rather complicated
-	 * operations, including fld queries, inode loading, etc.
+	 * Allocate new object, NB, object is uninitialized in case object
+	 * is changed between allocation and hash insertion, thus the object
+	 * with stale attributes is returned.
 	 */
-	o = lu_object_alloc(env, dev, f, conf);
+	o = lu_object_alloc(env, dev, f);
 	if (IS_ERR(o))
 		return o;
 
 	LASSERT(lu_fid_eq(lu_object_fid(o), f));
 
+	CFS_RACE_WAIT(OBD_FAIL_OBD_ZERO_NLINK_RACE);
+
 	cfs_hash_bd_lock(hs, &bd, 1);
 
 	if (conf && conf->loc_flags & LOC_F_NEW)
@@ -733,6 +772,20 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 		cfs_hash_bd_add_locked(hs, &bd, &o->lo_header->loh_hash);
 		cfs_hash_bd_unlock(hs, &bd, 1);
 
+		/*
+		 * This may result in rather complicated operations, including
+		 * fld queries, inode loading, etc.
+		 */
+		rc = lu_object_start(env, dev, o, conf);
+		if (rc) {
+			set_bit(LU_OBJECT_HEARD_BANSHEE,
+				&o->lo_header->loh_flags);
+			lu_object_put(env, o);
+			return ERR_PTR(rc);
+		}
+
+		wake_up_all(&bkt->lsb_waitq);
+
 		lu_object_limit(env, dev);
 
 		return o;
@@ -741,6 +794,20 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 	lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_RACE);
 	cfs_hash_bd_unlock(hs, &bd, 1);
 	lu_object_free(env, o);
+
+	if (!(conf && conf->loc_flags & LOC_F_NEW) &&
+	    !lu_object_is_inited(shadow->lo_header)) {
+		wait_event_idle(bkt->lsb_waitq,
+				lu_object_is_inited(shadow->lo_header) ||
+				lu_object_is_dying(shadow->lo_header));
+
+		if (lu_object_is_dying(shadow->lo_header)) {
+			lu_object_put(env, shadow);
+
+			return ERR_PTR(-ENOENT);
+		}
+	}
+
 	return shadow;
 }
 EXPORT_SYMBOL(lu_object_find_at);
@@ -998,7 +1065,7 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 	cfs_hash_for_each_bucket(s->ls_obj_hash, &bd, i) {
 		bkt = cfs_hash_bd_extra_get(s->ls_obj_hash, &bd);
 		INIT_LIST_HEAD(&bkt->lsb_lru);
-		init_waitqueue_head(&bkt->lsb_marche_funebre);
+		init_waitqueue_head(&bkt->lsb_waitq);
 	}
 
 	s->ls_stats = lprocfs_alloc_stats(LU_SS_LAST_STAT, 0);
diff --git a/include/linux/libcfs/libcfs_fail.h b/include/linux/libcfs/libcfs_fail.h
index c341567..45166c5 100644
--- a/include/linux/libcfs/libcfs_fail.h
+++ b/include/linux/libcfs/libcfs_fail.h
@@ -187,7 +187,7 @@ static inline void cfs_race(u32 id)
 			CERROR("cfs_race id %x sleeping\n", id);
 			rc = wait_event_interruptible(cfs_race_waitq,
 						      !!cfs_race_state);
-			CERROR("cfs_fail_race id %x awake, rc=%d\n", id, rc);
+			CERROR("cfs_fail_race id %x awake: rc=%d\n", id, rc);
 		} else {
 			CERROR("cfs_fail_race id %x waking\n", id);
 			cfs_race_state = 1;
@@ -198,4 +198,42 @@ static inline void cfs_race(u32 id)
 
 #define CFS_RACE(id) cfs_race(id)
 
+/**
+ * Wait on race.
+ *
+ * The first thread that calls this with a matching fail_loc is put to sleep,
+ * but subseqent callers of this won't sleep. Until another thread that calls
+ * cfs_race_wakeup(), the first thread will be woken up and continue.
+ */
+static inline void cfs_race_wait(u32 id)
+{
+	if (CFS_FAIL_PRECHECK(id)) {
+		if (unlikely(__cfs_fail_check_set(id, 0, CFS_FAIL_LOC_NOSET))) {
+			int rc;
+
+			cfs_race_state = 0;
+			CERROR("cfs_race id %x sleeping\n", id);
+			rc = wait_event_interruptible(cfs_race_waitq,
+						      cfs_race_state != 0);
+			CERROR("cfs_fail_race id %x awake: rc=%d\n", id, rc);
+		}
+	}
+}
+#define CFS_RACE_WAIT(id) cfs_race_wait(id)
+
+/**
+ * Wake up the thread that is waiting on the matching fail_loc.
+ */
+static inline void cfs_race_wakeup(u32 id)
+{
+	if (CFS_FAIL_PRECHECK(id)) {
+		if (likely(!__cfs_fail_check_set(id, 0, CFS_FAIL_LOC_NOSET))) {
+			CERROR("cfs_fail_race id %x waking\n", id);
+			cfs_race_state = 1;
+			wake_up(&cfs_race_waitq);
+		}
+	}
+}
+#define CFS_RACE_WAKEUP(id) cfs_race_wakeup(id)
+
 #endif /* _LIBCFS_FAIL_H */
-- 
1.8.3.1
