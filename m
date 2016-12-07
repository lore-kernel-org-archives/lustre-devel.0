From: James Simmons <jsimmons@infradead.org>
Date: Wed,  7 Dec 2016 17:49:12 -0500
Subject: [lustre-devel] [PATCH v2] staging: lustre: osc: handle osc eviction
	correctly
Message-ID: <1481150952-16339-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Cleanup everything if an OSC is being evicted.
Group lock is not well supported yet.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6271
Reviewed-on: http://review.whamcloud.com/14989
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
Changelog:

v1) Initial patch
v2) Remove ergo macro usage

 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  3 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 25 ++++-----
 .../staging/lustre/lustre/osc/osc_cl_internal.h    | 11 ++--
 drivers/staging/lustre/lustre/osc/osc_internal.h   |  2 +
 drivers/staging/lustre/lustre/osc/osc_io.c         | 60 +++++++++++++++++-----
 drivers/staging/lustre/lustre/osc/osc_object.c     | 19 +++++++
 drivers/staging/lustre/lustre/osc/osc_request.c    | 42 ++++++++++++---
 7 files changed, 124 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index a4a291a..cdb5bd1 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1131,8 +1131,7 @@ static int lock_matches(struct ldlm_lock *lock, struct lock_match_data *data)
 	if (!data->lmd_unref && LDLM_HAVE_MASK(lock, GONE))
 		return INTERVAL_ITER_CONT;
 
-	if ((data->lmd_flags & LDLM_FL_LOCAL_ONLY) &&
-	    !ldlm_is_local(lock))
+	if (!equi(data->lmd_flags & LDLM_FL_LOCAL_ONLY, ldlm_is_local(lock)))
 		return INTERVAL_ITER_CONT;
 
 	if (data->lmd_flags & LDLM_FL_TEST_LOCK) {
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index b0f030c..a7f57f5 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -247,7 +247,7 @@ static int osc_extent_sanity_check0(struct osc_extent *ext,
 		goto out;
 	}
 
-	if (ext->oe_dlmlock) {
+	if (ext->oe_dlmlock && !ldlm_is_failed(ext->oe_dlmlock)) {
 		struct ldlm_extent *extent;
 
 		extent = &ext->oe_dlmlock->l_policy_data.l_extent;
@@ -2710,8 +2710,8 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 /**
  * Called by osc_io_setattr_start() to freeze and destroy covering extents.
  */
-int osc_cache_truncate_start(const struct lu_env *env, struct osc_io *oio,
-			     struct osc_object *obj, __u64 size)
+int osc_cache_truncate_start(const struct lu_env *env, struct osc_object *obj,
+			     u64 size, struct osc_extent **extp)
 {
 	struct client_obd *cli = osc_cli(obj);
 	struct osc_extent *ext;
@@ -2808,9 +2808,11 @@ int osc_cache_truncate_start(const struct lu_env *env, struct osc_io *oio,
 			/* we need to hold this extent in OES_TRUNC state so
 			 * that no writeback will happen. This is to avoid
 			 * BUG 17397.
+			 * Only partial truncate can reach here, if @size is
+			 * not zero, the caller should provide a valid @extp.
 			 */
-			LASSERT(!oio->oi_trunc);
-			oio->oi_trunc = osc_extent_get(ext);
+			LASSERT(!*extp);
+			*extp = osc_extent_get(ext);
 			OSC_EXTENT_DUMP(D_CACHE, ext,
 					"trunc at %llu\n", size);
 		}
@@ -2836,13 +2838,10 @@ int osc_cache_truncate_start(const struct lu_env *env, struct osc_io *oio,
 /**
  * Called after osc_io_setattr_end to add oio->oi_trunc back to cache.
  */
-void osc_cache_truncate_end(const struct lu_env *env, struct osc_io *oio,
-			    struct osc_object *obj)
+void osc_cache_truncate_end(const struct lu_env *env, struct osc_extent *ext)
 {
-	struct osc_extent *ext = oio->oi_trunc;
-
-	oio->oi_trunc = NULL;
 	if (ext) {
+		struct osc_object *obj = ext->oe_obj;
 		bool unplug = false;
 
 		EASSERT(ext->oe_nr_pages > 0, ext);
@@ -3183,8 +3182,10 @@ static int discard_cb(const struct lu_env *env, struct cl_io *io,
 	/* page is top page. */
 	info->oti_next_index = osc_index(ops) + 1;
 	if (cl_page_own(env, io, page) == 0) {
-		KLASSERT(ergo(page->cp_type == CPT_CACHEABLE,
-			      !PageDirty(cl_page_vmpage(page))));
+		if (page->cp_type == CPT_CACHEABLE &&
+		    PageDirty(cl_page_vmpage(page)))
+			CL_PAGE_DEBUG(D_ERROR, env, page,
+				      "discard dirty page?\n");
 
 		/* discard the page */
 		cl_page_discard(env, io, page);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index cce55a9..c09ab97d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -159,6 +159,10 @@ struct osc_object {
 	/* Protect osc_lock this osc_object has */
 	spinlock_t		oo_ol_spin;
 	struct list_head	oo_ol_list;
+
+	/** number of active IOs of this object */
+	atomic_t		oo_nr_ios;
+	wait_queue_head_t	oo_io_waitq;
 };
 
 static inline void osc_object_lock(struct osc_object *obj)
@@ -399,10 +403,9 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 			 struct osc_page *ops);
 int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 			 struct list_head *list, int cmd, int brw_flags);
-int osc_cache_truncate_start(const struct lu_env *env, struct osc_io *oio,
-			     struct osc_object *obj, __u64 size);
-void osc_cache_truncate_end(const struct lu_env *env, struct osc_io *oio,
-			    struct osc_object *obj);
+int osc_cache_truncate_start(const struct lu_env *env, struct osc_object *obj,
+			     u64 size, struct osc_extent **extp);
+void osc_cache_truncate_end(const struct lu_env *env, struct osc_extent *ext);
 int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 			      pgoff_t start, pgoff_t end, int hp, int discard);
 int osc_cache_wait_range(const struct lu_env *env, struct osc_object *obj,
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 688783d..d9837b7 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -218,4 +218,6 @@ struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
 				       struct osc_object *obj, pgoff_t index,
 				       enum osc_dap_flags flags);
 
+int osc_object_invalidate(const struct lu_env *env, struct osc_object *osc);
+
 #endif /* OSC_INTERNAL_H */
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 228a97c..d96f4f2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -330,8 +330,25 @@ static int osc_io_commit_async(const struct lu_env *env,
 	return result;
 }
 
-static int osc_io_rw_iter_init(const struct lu_env *env,
-			       const struct cl_io_slice *ios)
+static int osc_io_iter_init(const struct lu_env *env,
+			    const struct cl_io_slice *ios)
+{
+	struct osc_object *osc = cl2osc(ios->cis_obj);
+	struct obd_import *imp = osc_cli(osc)->cl_import;
+	int rc = -EIO;
+
+	spin_lock(&imp->imp_lock);
+	if (likely(!imp->imp_invalid)) {
+		atomic_inc(&osc->oo_nr_ios);
+		rc = 0;
+	}
+	spin_unlock(&imp->imp_lock);
+
+	return rc;
+}
+
+static int osc_io_write_iter_init(const struct lu_env *env,
+				  const struct cl_io_slice *ios)
 {
 	struct cl_io *io = ios->cis_io;
 	struct osc_io *oio = osc_env_io(env);
@@ -342,7 +359,7 @@ static int osc_io_rw_iter_init(const struct lu_env *env,
 	unsigned long max_pages;
 
 	if (cl_io_is_append(io))
-		return 0;
+		return osc_io_iter_init(env, ios);
 
 	npages = io->u.ci_rw.crw_count >> PAGE_SHIFT;
 	if (io->u.ci_rw.crw_pos & ~PAGE_MASK)
@@ -374,11 +391,21 @@ static int osc_io_rw_iter_init(const struct lu_env *env,
 		(void)ptlrpcd_queue_work(cli->cl_lru_work);
 	}
 
-	return 0;
+	return osc_io_iter_init(env, ios);
+}
+
+static void osc_io_iter_fini(const struct lu_env *env,
+			     const struct cl_io_slice *ios)
+{
+	struct osc_object *osc = cl2osc(ios->cis_obj);
+
+	LASSERT(atomic_read(&osc->oo_nr_ios) > 0);
+	if (atomic_dec_and_test(&osc->oo_nr_ios))
+		wake_up_all(&osc->oo_io_waitq);
 }
 
-static void osc_io_rw_iter_fini(const struct lu_env *env,
-				const struct cl_io_slice *ios)
+static void osc_io_write_iter_fini(const struct lu_env *env,
+				   const struct cl_io_slice *ios)
 {
 	struct osc_io *oio = osc_env_io(env);
 	struct osc_object *osc = cl2osc(ios->cis_obj);
@@ -389,6 +416,8 @@ static void osc_io_rw_iter_fini(const struct lu_env *env,
 		oio->oi_lru_reserved = 0;
 	}
 	oio->oi_write_osclock = NULL;
+
+	osc_io_iter_fini(env, ios);
 }
 
 static int osc_io_fault_start(const struct lu_env *env,
@@ -479,7 +508,8 @@ static int osc_io_setattr_start(const struct lu_env *env,
 
 	/* truncate cache dirty pages first */
 	if (cl_io_is_trunc(io))
-		result = osc_cache_truncate_start(env, oio, cl2osc(obj), size);
+		result = osc_cache_truncate_start(env, cl2osc(obj), size,
+						  &oio->oi_trunc);
 
 	if (result == 0 && oio->oi_lockless == 0) {
 		cl_object_attr_lock(obj);
@@ -589,10 +619,8 @@ static void osc_io_setattr_end(const struct lu_env *env,
 		__u64 size = io->u.ci_setattr.sa_attr.lvb_size;
 
 		osc_trunc_check(env, io, oio, size);
-		if (oio->oi_trunc) {
-			osc_cache_truncate_end(env, oio, cl2osc(obj));
-			oio->oi_trunc = NULL;
-		}
+		osc_cache_truncate_end(env, oio->oi_trunc);
+		oio->oi_trunc = NULL;
 	}
 }
 
@@ -832,17 +860,21 @@ static void osc_io_end(const struct lu_env *env,
 static const struct cl_io_operations osc_io_ops = {
 	.op = {
 		[CIT_READ] = {
+			.cio_iter_init	= osc_io_iter_init,
+			.cio_iter_fini	= osc_io_iter_fini,
 			.cio_start  = osc_io_read_start,
 			.cio_fini   = osc_io_fini
 		},
 		[CIT_WRITE] = {
-			.cio_iter_init = osc_io_rw_iter_init,
-			.cio_iter_fini = osc_io_rw_iter_fini,
+			.cio_iter_init	= osc_io_write_iter_init,
+			.cio_iter_fini	= osc_io_write_iter_fini,
 			.cio_start  = osc_io_write_start,
 			.cio_end    = osc_io_end,
 			.cio_fini   = osc_io_fini
 		},
 		[CIT_SETATTR] = {
+			.cio_iter_init	= osc_io_iter_init,
+			.cio_iter_fini	= osc_io_iter_fini,
 			.cio_start  = osc_io_setattr_start,
 			.cio_end    = osc_io_setattr_end
 		},
@@ -851,6 +883,8 @@ static void osc_io_end(const struct lu_env *env,
 			.cio_end	= osc_io_data_version_end,
 		},
 		[CIT_FAULT] = {
+			.cio_iter_init	= osc_io_iter_init,
+			.cio_iter_fini	= osc_io_iter_fini,
 			.cio_start  = osc_io_fault_start,
 			.cio_end    = osc_io_end,
 			.cio_fini   = osc_io_fini
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index e0c3324..d3e5ca7 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -78,6 +78,9 @@ static int osc_object_init(const struct lu_env *env, struct lu_object *obj,
 	INIT_LIST_HEAD(&osc->oo_write_item);
 	INIT_LIST_HEAD(&osc->oo_read_item);
 
+	atomic_set(&osc->oo_nr_ios, 0);
+	init_waitqueue_head(&osc->oo_io_waitq);
+
 	osc->oo_root.rb_node = NULL;
 	INIT_LIST_HEAD(&osc->oo_hp_exts);
 	INIT_LIST_HEAD(&osc->oo_urgent_exts);
@@ -112,6 +115,7 @@ static void osc_object_free(const struct lu_env *env, struct lu_object *obj)
 	LASSERT(atomic_read(&osc->oo_nr_reads) == 0);
 	LASSERT(atomic_read(&osc->oo_nr_writes) == 0);
 	LASSERT(list_empty(&osc->oo_ol_list));
+	LASSERT(!atomic_read(&osc->oo_nr_ios));
 
 	lu_object_fini(obj);
 	kmem_cache_free(osc_object_kmem, osc);
@@ -444,4 +448,19 @@ struct lu_object *osc_object_alloc(const struct lu_env *env,
 	return obj;
 }
 
+int osc_object_invalidate(const struct lu_env *env, struct osc_object *osc)
+{
+	struct l_wait_info lwi = { 0 };
+
+	CDEBUG(D_INODE, "Invalidate osc object: %p, # of active IOs: %d\n",
+	       osc, atomic_read(&osc->oo_nr_ios));
+
+	l_wait_event(osc->oo_io_waitq, !atomic_read(&osc->oo_nr_ios), &lwi);
+
+	/* Discard all pages of this object. */
+	osc_cache_truncate_start(env, osc, 0, NULL);
+
+	return 0;
+}
+
 /** @} osc */
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 7143564..757ddfa 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2479,6 +2479,33 @@ static int osc_disconnect(struct obd_export *exp)
 	return rc;
 }
 
+static int osc_ldlm_resource_invalidate(struct cfs_hash *hs,
+					struct cfs_hash_bd *bd,
+					struct hlist_node *hnode, void *arg)
+{
+	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
+	struct osc_object *osc = NULL;
+	struct lu_env *env = arg;
+	struct ldlm_lock *lock;
+
+	lock_res(res);
+	list_for_each_entry(lock, &res->lr_granted, l_res_link) {
+		if (lock->l_ast_data && !osc) {
+			osc = lock->l_ast_data;
+			cl_object_get(osc2cl(osc));
+		}
+		lock->l_ast_data = NULL;
+	}
+	unlock_res(res);
+
+	if (osc) {
+		osc_object_invalidate(env, osc);
+		cl_object_put(env, osc2cl(osc));
+	}
+
+	return 0;
+}
+
 static int osc_import_event(struct obd_device *obd,
 			    struct obd_import *imp,
 			    enum obd_import_event event)
@@ -2506,17 +2533,18 @@ static int osc_import_event(struct obd_device *obd,
 		struct lu_env *env;
 		int refcheck;
 
+		ldlm_namespace_cleanup(ns, LDLM_FL_LOCAL_ONLY);
+
 		env = cl_env_get(&refcheck);
 		if (!IS_ERR(env)) {
-			/* Reset grants */
-			cli = &obd->u.cli;
-			/* all pages go to failing rpcs due to the invalid
-			 * import
-			 */
-			osc_io_unplug(env, cli, NULL);
+			osc_io_unplug(env, &obd->u.cli, NULL);
 
-			ldlm_namespace_cleanup(ns, LDLM_FL_LOCAL_ONLY);
+			cfs_hash_for_each_nolock(ns->ns_rs_hash,
+						 osc_ldlm_resource_invalidate,
+						 env, 0);
 			cl_env_put(env, &refcheck);
+
+			ldlm_namespace_cleanup(ns, LDLM_FL_LOCAL_ONLY);
 		} else {
 			rc = PTR_ERR(env);
 		}
-- 
1.8.3.1
