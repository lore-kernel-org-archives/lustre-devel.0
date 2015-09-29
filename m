From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:53 -0400
Subject: [lustre-devel] [PATCH 10/29] staging/lustre: Remove unused
	lu_object functions.
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-11-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Quite a bunch of them are only used on the server.
lu_object_put_nocache, lu_object_invariant, lu_dev_del_linkage,
lu_context_tags_update, lu_context_tags_clear, lu_session_tags_update,
lu_session_tags_clear, lu_env_refill_by_tags, lu_printk_printer,
lu_object_assign_fid, lu_object_anon, lu_buf_free, lu_buf_alloc,
lu_buf_realloc, lu_buf_check_and_alloc, lu_buf_check_and_grow

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lu_object.h  |  27 ---
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 241 ---------------------
 2 files changed, 268 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 7756008..e2199c2 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -672,7 +672,6 @@ void lu_object_add_top    (struct lu_object_header *h, struct lu_object *o);
 void lu_object_add	(struct lu_object *before, struct lu_object *o);
 
 void lu_dev_add_linkage(struct lu_site *s, struct lu_device *d);
-void lu_dev_del_linkage(struct lu_site *s, struct lu_device *d);
 
 /**
  * Helpers to initialize and finalize device types.
@@ -710,7 +709,6 @@ static inline int lu_object_is_dying(const struct lu_object_header *h)
 }
 
 void lu_object_put(const struct lu_env *env, struct lu_object *o);
-void lu_object_put_nocache(const struct lu_env *env, struct lu_object *o);
 void lu_object_unhash(const struct lu_env *env, struct lu_object *o);
 
 int lu_site_purge(const struct lu_env *env, struct lu_site *s, int nr);
@@ -1241,14 +1239,6 @@ void lu_context_key_degister_many(struct lu_context_key *k, ...);
 void lu_context_key_revive_many  (struct lu_context_key *k, ...);
 void lu_context_key_quiesce_many (struct lu_context_key *k, ...);
 
-/*
- * update/clear ctx/ses tags.
- */
-void lu_context_tags_update(__u32 tags);
-void lu_context_tags_clear(__u32 tags);
-void lu_session_tags_update(__u32 tags);
-void lu_session_tags_clear(__u32 tags);
-
 /**
  * Environment.
  */
@@ -1266,7 +1256,6 @@ struct lu_env {
 int  lu_env_init  (struct lu_env *env, __u32 tags);
 void lu_env_fini  (struct lu_env *env);
 int  lu_env_refill(struct lu_env *env);
-int  lu_env_refill_by_tags(struct lu_env *env, __u32 ctags, __u32 stags);
 
 /** @} lu_context */
 
@@ -1319,21 +1308,5 @@ struct lu_kmem_descr {
 int  lu_kmem_init(struct lu_kmem_descr *caches);
 void lu_kmem_fini(struct lu_kmem_descr *caches);
 
-void lu_object_assign_fid(const struct lu_env *env, struct lu_object *o,
-			  const struct lu_fid *fid);
-struct lu_object *lu_object_anon(const struct lu_env *env,
-				 struct lu_device *dev,
-				 const struct lu_object_conf *conf);
-
-/** null buffer */
-extern struct lu_buf LU_BUF_NULL;
-
-void lu_buf_free(struct lu_buf *buf);
-void lu_buf_alloc(struct lu_buf *buf, int size);
-void lu_buf_realloc(struct lu_buf *buf, int size);
-
-int lu_buf_check_and_grow(struct lu_buf *buf, int len);
-struct lu_buf *lu_buf_check_and_alloc(struct lu_buf *buf, int len);
-
 /** @} lu */
 #endif /* __LUSTRE_LU_OBJECT_H */
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index c892e82..01d70f0 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -157,17 +157,6 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 EXPORT_SYMBOL(lu_object_put);
 
 /**
- * Put object and don't keep in cache. This is temporary solution for
- * multi-site objects when its layering is not constant.
- */
-void lu_object_put_nocache(const struct lu_env *env, struct lu_object *o)
-{
-	set_bit(LU_OBJECT_HEARD_BANSHEE, &o->lo_header->loh_flags);
-	return lu_object_put(env, o);
-}
-EXPORT_SYMBOL(lu_object_put_nocache);
-
-/**
  * Kill the object and take it out of LRU cache.
  * Currently used by client code for layout change.
  */
@@ -529,23 +518,6 @@ void lu_object_print(const struct lu_env *env, void *cookie,
 }
 EXPORT_SYMBOL(lu_object_print);
 
-/**
- * Check object consistency.
- */
-int lu_object_invariant(const struct lu_object *o)
-{
-	struct lu_object_header *top;
-
-	top = o->lo_header;
-	list_for_each_entry(o, &top->loh_layers, lo_linkage) {
-		if (o->lo_ops->loo_object_invariant != NULL &&
-		    !o->lo_ops->loo_object_invariant(o))
-			return 0;
-	}
-	return 1;
-}
-EXPORT_SYMBOL(lu_object_invariant);
-
 static struct lu_object *htable_lookup(struct lu_site *s,
 				       struct cfs_hash_bd *bd,
 				       const struct lu_fid *f,
@@ -962,14 +934,6 @@ void lu_dev_add_linkage(struct lu_site *s, struct lu_device *d)
 }
 EXPORT_SYMBOL(lu_dev_add_linkage);
 
-void lu_dev_del_linkage(struct lu_site *s, struct lu_device *d)
-{
-	spin_lock(&s->ls_ld_lock);
-	list_del_init(&d->ld_linkage);
-	spin_unlock(&s->ls_ld_lock);
-}
-EXPORT_SYMBOL(lu_dev_del_linkage);
-
 /**
  * Initialize site \a s, with \a d as the top level device.
  */
@@ -1701,42 +1665,6 @@ EXPORT_SYMBOL(lu_context_refill);
 __u32 lu_context_tags_default;
 __u32 lu_session_tags_default;
 
-void lu_context_tags_update(__u32 tags)
-{
-	spin_lock(&lu_keys_guard);
-	lu_context_tags_default |= tags;
-	key_set_version++;
-	spin_unlock(&lu_keys_guard);
-}
-EXPORT_SYMBOL(lu_context_tags_update);
-
-void lu_context_tags_clear(__u32 tags)
-{
-	spin_lock(&lu_keys_guard);
-	lu_context_tags_default &= ~tags;
-	key_set_version++;
-	spin_unlock(&lu_keys_guard);
-}
-EXPORT_SYMBOL(lu_context_tags_clear);
-
-void lu_session_tags_update(__u32 tags)
-{
-	spin_lock(&lu_keys_guard);
-	lu_session_tags_default |= tags;
-	key_set_version++;
-	spin_unlock(&lu_keys_guard);
-}
-EXPORT_SYMBOL(lu_session_tags_update);
-
-void lu_session_tags_clear(__u32 tags)
-{
-	spin_lock(&lu_keys_guard);
-	lu_session_tags_default &= ~tags;
-	key_set_version++;
-	spin_unlock(&lu_keys_guard);
-}
-EXPORT_SYMBOL(lu_session_tags_clear);
-
 int lu_env_init(struct lu_env *env, __u32 tags)
 {
 	int result;
@@ -1768,31 +1696,6 @@ int lu_env_refill(struct lu_env *env)
 }
 EXPORT_SYMBOL(lu_env_refill);
 
-/**
- * Currently, this API will only be used by echo client.
- * Because echo client and normal lustre client will share
- * same cl_env cache. So echo client needs to refresh
- * the env context after it get one from the cache, especially
- * when normal client and echo client co-exist in the same client.
- */
-int lu_env_refill_by_tags(struct lu_env *env, __u32 ctags,
-			  __u32 stags)
-{
-	if ((env->le_ctx.lc_tags & ctags) != ctags) {
-		env->le_ctx.lc_version = 0;
-		env->le_ctx.lc_tags |= ctags;
-	}
-
-	if (env->le_ses && (env->le_ses->lc_tags & stags) != stags) {
-		env->le_ses->lc_version = 0;
-		env->le_ses->lc_tags |= stags;
-	}
-
-	return lu_env_refill(env);
-}
-EXPORT_SYMBOL(lu_env_refill_by_tags);
-
-
 struct lu_site_stats {
 	unsigned	lss_populated;
 	unsigned	lss_max_search;
@@ -1904,29 +1807,9 @@ static unsigned long lu_cache_shrink_scan(struct shrinker *sk,
 	return sc->nr_to_scan - remain;
 }
 
-/*
- * Debugging stuff.
- */
-
-/**
- * Environment to be used in debugger, contains all tags.
- */
-struct lu_env lu_debugging_env;
-
 /**
  * Debugging printer function using printk().
  */
-int lu_printk_printer(const struct lu_env *env,
-		      void *unused, const char *format, ...)
-{
-	va_list args;
-
-	va_start(args, format);
-	vprintk(format, args);
-	va_end(args);
-	return 0;
-}
-
 static struct shrinker lu_site_shrinker = {
 	.count_objects	= lu_cache_shrink_count,
 	.scan_objects	= lu_cache_shrink_scan,
@@ -2069,127 +1952,3 @@ void lu_kmem_fini(struct lu_kmem_descr *caches)
 	}
 }
 EXPORT_SYMBOL(lu_kmem_fini);
-
-/**
- * Temporary solution to be able to assign fid in ->do_create()
- * till we have fully-functional OST fids
- */
-void lu_object_assign_fid(const struct lu_env *env, struct lu_object *o,
-			  const struct lu_fid *fid)
-{
-	struct lu_site		*s = o->lo_dev->ld_site;
-	struct lu_fid		*old = &o->lo_header->loh_fid;
-	struct lu_object	*shadow;
-	wait_queue_t		 waiter;
-	struct cfs_hash		*hs;
-	struct cfs_hash_bd	 bd;
-	__u64			 version = 0;
-
-	LASSERT(fid_is_zero(old));
-
-	hs = s->ls_obj_hash;
-	cfs_hash_bd_get_and_lock(hs, (void *)fid, &bd, 1);
-	shadow = htable_lookup(s, &bd, fid, &waiter, &version);
-	/* supposed to be unique */
-	LASSERT(IS_ERR(shadow) && PTR_ERR(shadow) == -ENOENT);
-	*old = *fid;
-	cfs_hash_bd_add_locked(hs, &bd, &o->lo_header->loh_hash);
-	cfs_hash_bd_unlock(hs, &bd, 1);
-}
-EXPORT_SYMBOL(lu_object_assign_fid);
-
-/**
- * allocates object with 0 (non-assigned) fid
- * XXX: temporary solution to be able to assign fid in ->do_create()
- *      till we have fully-functional OST fids
- */
-struct lu_object *lu_object_anon(const struct lu_env *env,
-				 struct lu_device *dev,
-				 const struct lu_object_conf *conf)
-{
-	struct lu_fid     fid;
-	struct lu_object *o;
-
-	fid_zero(&fid);
-	o = lu_object_alloc(env, dev, &fid, conf);
-
-	return o;
-}
-EXPORT_SYMBOL(lu_object_anon);
-
-struct lu_buf LU_BUF_NULL = {
-	.lb_buf = NULL,
-	.lb_len = 0
-};
-EXPORT_SYMBOL(LU_BUF_NULL);
-
-void lu_buf_free(struct lu_buf *buf)
-{
-	LASSERT(buf);
-	if (buf->lb_buf) {
-		LASSERT(buf->lb_len > 0);
-		kvfree(buf->lb_buf);
-		buf->lb_buf = NULL;
-		buf->lb_len = 0;
-	}
-}
-EXPORT_SYMBOL(lu_buf_free);
-
-void lu_buf_alloc(struct lu_buf *buf, int size)
-{
-	LASSERT(buf);
-	LASSERT(buf->lb_buf == NULL);
-	LASSERT(buf->lb_len == 0);
-	buf->lb_buf = libcfs_kvzalloc(size, GFP_NOFS);
-	if (likely(buf->lb_buf))
-		buf->lb_len = size;
-}
-EXPORT_SYMBOL(lu_buf_alloc);
-
-void lu_buf_realloc(struct lu_buf *buf, int size)
-{
-	lu_buf_free(buf);
-	lu_buf_alloc(buf, size);
-}
-EXPORT_SYMBOL(lu_buf_realloc);
-
-struct lu_buf *lu_buf_check_and_alloc(struct lu_buf *buf, int len)
-{
-	if (buf->lb_buf == NULL && buf->lb_len == 0)
-		lu_buf_alloc(buf, len);
-
-	if ((len > buf->lb_len) && (buf->lb_buf != NULL))
-		lu_buf_realloc(buf, len);
-
-	return buf;
-}
-EXPORT_SYMBOL(lu_buf_check_and_alloc);
-
-/**
- * Increase the size of the \a buf.
- * preserves old data in buffer
- * old buffer remains unchanged on error
- * \retval 0 or -ENOMEM
- */
-int lu_buf_check_and_grow(struct lu_buf *buf, int len)
-{
-	char *ptr;
-
-	if (len <= buf->lb_len)
-		return 0;
-
-	ptr = libcfs_kvzalloc(len, GFP_NOFS);
-	if (ptr == NULL)
-		return -ENOMEM;
-
-	/* Free the old buf */
-	if (buf->lb_buf != NULL) {
-		memcpy(ptr, buf->lb_buf, buf->lb_len);
-		kvfree(buf->lb_buf);
-	}
-
-	buf->lb_buf = ptr;
-	buf->lb_len = len;
-	return 0;
-}
-EXPORT_SYMBOL(lu_buf_check_and_grow);
-- 
2.1.0
