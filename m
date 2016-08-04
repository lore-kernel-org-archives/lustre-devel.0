From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:52:52 -0400
Subject: [lustre-devel] [PATCH 16/32] staging: lustre: clio: Reduce memory
	overhead of per-page allocation
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

A page in clio used to occupy 584 bytes, which will use size-1024
slab cache. This patch reduces the per-page overhead to 512 bytes
so it can use size-512 instead.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4793
Reviewed-on: http://review.whamcloud.com/10070
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |   37 +++++---------------
 drivers/staging/lustre/lustre/llite/vvp_internal.h |    6 ++--
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |    4 +-
 drivers/staging/lustre/lustre/lov/lov_io.c         |    6 +--
 drivers/staging/lustre/lustre/lov/lov_page.c       |    1 +
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |   10 +-----
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   12 +-----
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    1 -
 drivers/staging/lustre/lustre/osc/osc_io.c         |    7 +++-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    6 ---
 10 files changed, 26 insertions(+), 64 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 0fa71a5..d269b32 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -690,17 +690,6 @@ enum cl_page_type {
 };
 
 /**
- * Flags maintained for every cl_page.
- */
-enum cl_page_flags {
-	/**
-	 * Set when pagein completes. Used for debugging (read completes at
-	 * most once for a page).
-	 */
-	CPF_READ_COMPLETED = 1 << 0
-};
-
-/**
  * Fields are protected by the lock on struct page, except for atomics and
  * immutables.
  *
@@ -712,26 +701,23 @@ enum cl_page_flags {
 struct cl_page {
 	/** Reference counter. */
 	atomic_t	     cp_ref;
+	/** Transfer error. */
+	int			 cp_error;
 	/** An object this page is a part of. Immutable after creation. */
 	struct cl_object	*cp_obj;
-	/** List of slices. Immutable after creation. */
-	struct list_head	       cp_layers;
 	/** vmpage */
 	struct page		*cp_vmpage;
+	/** Linkage of pages within group. Pages must be owned */
+	struct list_head	 cp_batch;
+	/** List of slices. Immutable after creation. */
+	struct list_head	 cp_layers;
+	/** Linkage of pages within cl_req. */
+	struct list_head         cp_flight;
 	/**
 	 * Page state. This field is const to avoid accidental update, it is
 	 * modified only internally within cl_page.c. Protected by a VM lock.
 	 */
 	const enum cl_page_state cp_state;
-	/** Linkage of pages within group. Protected by cl_page::cp_mutex. */
-	struct list_head		cp_batch;
-	/** Mutex serializing membership of a page in a batch. */
-	struct mutex		cp_mutex;
-	/** Linkage of pages within cl_req. */
-	struct list_head	       cp_flight;
-	/** Transfer error. */
-	int		      cp_error;
-
 	/**
 	 * Page type. Only CPT_TRANSIENT is used so far. Immutable after
 	 * creation.
@@ -744,10 +730,6 @@ struct cl_page {
 	 */
 	struct cl_io	    *cp_owner;
 	/**
-	 * Debug information, the task is owning the page.
-	 */
-	struct task_struct	*cp_task;
-	/**
 	 * Owning IO request in cl_page_state::CPS_PAGEOUT and
 	 * cl_page_state::CPS_PAGEIN states. This field is maintained only in
 	 * the top-level pages. Protected by a VM lock.
@@ -759,8 +741,6 @@ struct cl_page {
 	struct lu_ref_link       cp_obj_ref;
 	/** Link to a queue, for debugging. */
 	struct lu_ref_link       cp_queue_ref;
-	/** Per-page flags from enum cl_page_flags. Protected by a VM lock. */
-	unsigned                 cp_flags;
 	/** Assigned if doing a sync_io */
 	struct cl_sync_io       *cp_sync_io;
 };
@@ -2200,6 +2180,7 @@ static inline void cl_object_page_init(struct cl_object *clob, int size)
 {
 	clob->co_slice_off = cl_object_header(clob)->coh_page_bufsize;
 	cl_object_header(clob)->coh_page_bufsize += cfs_size_round(size);
+	WARN_ON(cl_object_header(clob)->coh_page_bufsize > 512);
 }
 
 static inline void *cl_object_page_slice(struct cl_object *clob,
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 79fc428..99437b8 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -247,9 +247,9 @@ struct vvp_object {
  */
 struct vvp_page {
 	struct cl_page_slice vpg_cl;
-	int		  vpg_defer_uptodate;
-	int		  vpg_ra_used;
-	int		  vpg_write_queued;
+	unsigned int	vpg_defer_uptodate:1,
+			vpg_ra_used:1,
+			vpg_write_queued:1;
 	/**
 	 * Non-empty iff this page is already counted in
 	 * vvp_object::vob_pending_list. This list is only used as a flag,
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 9740568..43d1a3f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -289,8 +289,8 @@ struct lov_lock {
 };
 
 struct lov_page {
-	struct cl_page_slice lps_cl;
-	int		  lps_invalid;
+	struct cl_page_slice	lps_cl;
+	unsigned int		lps_stripe; /* stripe index */
 };
 
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 95126c3..5d47a5a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -244,14 +244,12 @@ void lov_sub_put(struct lov_io_sub *sub)
 
 int lov_page_stripe(const struct cl_page *page)
 {
-	struct lovsub_object *subobj;
 	const struct cl_page_slice *slice;
 
-	slice = cl_page_at(page, &lovsub_device_type);
+	slice = cl_page_at(page, &lov_device_type);
 	LASSERT(slice->cpl_obj);
 
-	subobj = cl2lovsub(slice->cpl_obj);
-	return subobj->lso_index;
+	return cl2lov_page(slice)->lps_stripe;
 }
 
 struct lov_io_sub *lov_page_subio(const struct lu_env *env, struct lov_io *lio,
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index 45b5ae9..00bfaba 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -129,6 +129,7 @@ int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
 	rc = lov_stripe_offset(loo->lo_lsm, offset, stripe, &suboff);
 	LASSERT(rc == 0);
 
+	lpg->lps_stripe = stripe;
 	cl_page_slice_add(page, &lpg->lps_cl, obj, index, &lov_raid0_page_ops);
 
 	sub = lov_sub_get(env, lio, stripe);
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index e72f1fc..4516fff 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -859,9 +859,6 @@ void cl_page_list_add(struct cl_page_list *plist, struct cl_page *page)
 	LASSERT(page->cp_owner);
 	LINVRNT(plist->pl_owner == current);
 
-	lockdep_off();
-	mutex_lock(&page->cp_mutex);
-	lockdep_on();
 	LASSERT(list_empty(&page->cp_batch));
 	list_add_tail(&page->cp_batch, &plist->pl_pages);
 	++plist->pl_nr;
@@ -877,12 +874,10 @@ void cl_page_list_del(const struct lu_env *env, struct cl_page_list *plist,
 		      struct cl_page *page)
 {
 	LASSERT(plist->pl_nr > 0);
+	LASSERT(cl_page_is_vmlocked(env, page));
 	LINVRNT(plist->pl_owner == current);
 
 	list_del_init(&page->cp_batch);
-	lockdep_off();
-	mutex_unlock(&page->cp_mutex);
-	lockdep_on();
 	--plist->pl_nr;
 	lu_ref_del_at(&page->cp_reference, &page->cp_queue_ref, "queue", plist);
 	cl_page_put(env, page);
@@ -959,9 +954,6 @@ void cl_page_list_disown(const struct lu_env *env,
 		LASSERT(plist->pl_nr > 0);
 
 		list_del_init(&page->cp_batch);
-		lockdep_off();
-		mutex_unlock(&page->cp_mutex);
-		lockdep_on();
 		--plist->pl_nr;
 		/*
 		 * cl_page_disown0 rather than usual cl_page_disown() is used,
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index db2dc6b..bd71859 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -151,7 +151,6 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
 		INIT_LIST_HEAD(&page->cp_layers);
 		INIT_LIST_HEAD(&page->cp_batch);
 		INIT_LIST_HEAD(&page->cp_flight);
-		mutex_init(&page->cp_mutex);
 		lu_ref_init(&page->cp_reference);
 		head = o->co_lu.lo_header;
 		list_for_each_entry(o, &head->loh_layers, co_lu.lo_linkage) {
@@ -478,7 +477,6 @@ static void cl_page_owner_clear(struct cl_page *page)
 		LASSERT(page->cp_owner->ci_owned_nr > 0);
 		page->cp_owner->ci_owned_nr--;
 		page->cp_owner = NULL;
-		page->cp_task = NULL;
 	}
 }
 
@@ -562,7 +560,6 @@ static int cl_page_own0(const struct lu_env *env, struct cl_io *io,
 			PASSERT(env, pg, !pg->cp_owner);
 			PASSERT(env, pg, !pg->cp_req);
 			pg->cp_owner = cl_io_top(io);
-			pg->cp_task  = current;
 			cl_page_owner_set(pg);
 			if (pg->cp_state != CPS_FREEING) {
 				cl_page_state_set(env, pg, CPS_OWNED);
@@ -619,7 +616,6 @@ void cl_page_assume(const struct lu_env *env,
 	cl_page_invoid(env, io, pg, CL_PAGE_OP(cpo_assume));
 	PASSERT(env, pg, !pg->cp_owner);
 	pg->cp_owner = cl_io_top(io);
-	pg->cp_task = current;
 	cl_page_owner_set(pg);
 	cl_page_state_set(env, pg, CPS_OWNED);
 }
@@ -860,10 +856,6 @@ void cl_page_completion(const struct lu_env *env,
 	PASSERT(env, pg, pg->cp_state == cl_req_type_state(crt));
 
 	CL_PAGE_HEADER(D_TRACE, env, pg, "%d %d\n", crt, ioret);
-	if (crt == CRT_READ && ioret == 0) {
-		PASSERT(env, pg, !(pg->cp_flags & CPF_READ_COMPLETED));
-		pg->cp_flags |= CPF_READ_COMPLETED;
-	}
 
 	cl_page_state_set(env, pg, CPS_CACHED);
 	if (crt >= CRT_NR)
@@ -989,10 +981,10 @@ void cl_page_header_print(const struct lu_env *env, void *cookie,
 			  lu_printer_t printer, const struct cl_page *pg)
 {
 	(*printer)(env, cookie,
-		   "page@%p[%d %p %d %d %d %p %p %#x]\n",
+		   "page@%p[%d %p %d %d %d %p %p]\n",
 		   pg, atomic_read(&pg->cp_ref), pg->cp_obj,
 		   pg->cp_state, pg->cp_error, pg->cp_type,
-		   pg->cp_owner, pg->cp_req, pg->cp_flags);
+		   pg->cp_owner, pg->cp_req);
 }
 EXPORT_SYMBOL(cl_page_header_print);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 7a27f09..2038885 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -71,7 +71,6 @@ struct osc_async_page {
 	struct client_obd       *oap_cli;
 	struct osc_object       *oap_obj;
 
-	struct ldlm_lock	*oap_ldlm_lock;
 	spinlock_t		 oap_lock;
 };
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 6e3dcd3..69424ea 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -163,7 +163,6 @@ static int osc_io_submit(const struct lu_env *env,
 			continue;
 		}
 
-		cl_page_list_move(qout, qin, page);
 		spin_lock(&oap->oap_lock);
 		oap->oap_async_flags = ASYNC_URGENT|ASYNC_READY;
 		oap->oap_async_flags |= ASYNC_COUNT_STABLE;
@@ -171,6 +170,12 @@ static int osc_io_submit(const struct lu_env *env,
 
 		osc_page_submit(env, opg, crt, brw_flags);
 		list_add_tail(&oap->oap_pending_item, &list);
+
+		if (page->cp_sync_io)
+			cl_page_list_move(qout, qin, page);
+		else /* async IO */
+			cl_page_list_del(env, qin, page);
+
 		if (++queued == max_pages) {
 			queued = 0;
 			result = osc_queue_sync_pages(env, osc, &list, cmd,
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index d231827..042a081 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1882,7 +1882,6 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	struct osc_async_page *tmp;
 	struct cl_req *clerq = NULL;
 	enum cl_req_type crt = (cmd & OBD_BRW_WRITE) ? CRT_WRITE : CRT_READ;
-	struct ldlm_lock *lock = NULL;
 	struct cl_req_attr *crattr = NULL;
 	u64 starting_offset = OBD_OBJECT_EOF;
 	u64 ending_offset = 0;
@@ -1948,7 +1947,6 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 				rc = PTR_ERR(clerq);
 				goto out;
 			}
-			lock = oap->oap_ldlm_lock;
 		}
 		if (mem_tight)
 			oap->oap_brw_flags |= OBD_BRW_MEMALLOC;
@@ -1965,10 +1963,6 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	LASSERT(clerq);
 	crattr->cra_oa = oa;
 	cl_req_attr_set(env, clerq, crattr, ~0ULL);
-	if (lock) {
-		oa->o_handle = lock->l_remote_handle;
-		oa->o_valid |= OBD_MD_FLHANDLE;
-	}
 
 	rc = cl_req_prep(env, clerq);
 	if (rc != 0) {
-- 
1.7.1
