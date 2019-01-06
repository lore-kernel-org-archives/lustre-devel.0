From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:14:04 -0500
Subject: [lustre-devel] [PATCH v2 09/33] lustre: lov: migrate lov raid0 to
 future PFL component handling
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

PFL will change striping from being static to dynamic. The idea
of stripe count will change under this case. So rename the fields
representing stripe index to component index. The raid0 stripe
handing will be replaced with PFL component handling so make the
raid0 a subsystem of PFL handling.

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24850
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  29 +--
 drivers/staging/lustre/lustre/lov/lov_io.c         |  41 +++--
 drivers/staging/lustre/lustre/lov/lov_lock.c       |   8 +-
 drivers/staging/lustre/lustre/lov/lov_object.c     | 196 +++++++++++++--------
 drivers/staging/lustre/lustre/lov/lov_page.c       |  19 +-
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |  13 +-
 6 files changed, 178 insertions(+), 128 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index c6ace49..c44c937 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -108,8 +108,8 @@ struct lov_device {
  */
 enum lov_layout_type {
 	LLT_EMPTY,	/** empty file without body (mknod + truncate) */
-	LLT_RAID0,	/** striped file */
 	LLT_RELEASED,	/** file with no objects (data in HSM) */
+	LLT_COMP,	/** support composite layout */
 	LLT_NR
 };
 
@@ -118,10 +118,10 @@ static inline char *llt2str(enum lov_layout_type llt)
 	switch (llt) {
 	case LLT_EMPTY:
 		return "EMPTY";
-	case LLT_RAID0:
-		return "RAID0";
 	case LLT_RELEASED:
 		return "RELEASED";
+	case LLT_COMP:
+		return "COMPOSITE";
 	case LLT_NR:
 		LBUG();
 	}
@@ -242,7 +242,7 @@ struct lov_lock_sub {
 	 */
 	unsigned int		sub_is_enqueued:1,
 				sub_initialized:1;
-	int		  sub_stripe;
+	int			sub_index;
 };
 
 /**
@@ -258,7 +258,8 @@ struct lov_lock {
 
 struct lov_page {
 	struct cl_page_slice	lps_cl;
-	unsigned int		lps_stripe; /* stripe index */
+	/** layout_entry + stripe index, composed using lov_comp_index() */
+	unsigned int		lps_index;
 };
 
 /*
@@ -309,7 +310,6 @@ struct lov_thread_info {
  * State that lov_io maintains for every sub-io.
  */
 struct lov_io_sub {
-	u16		 sub_stripe;
 	/**
 	 * environment's refcheck.
 	 *
@@ -331,6 +331,7 @@ struct lov_io_sub {
 	 * sub-io's active for the current IO iteration.
 	 */
 	struct list_head	 sub_linkage;
+	u16			sub_subio_index;
 	/**
 	 * sub-io for a stripe. Ideally sub-io's can be stopped and resumed
 	 * independently, with lov acting as a scheduler to maximize overall
@@ -425,12 +426,12 @@ int lov_io_init(const struct lu_env *env, struct cl_object *obj,
 int lovsub_lock_init(const struct lu_env *env, struct cl_object *obj,
 		     struct cl_lock *lock, const struct cl_io *io);
 
-int lov_lock_init_raid0(const struct lu_env *env, struct cl_object *obj,
-			struct cl_lock *lock, const struct cl_io *io);
+int lov_lock_init_composite(const struct lu_env *env, struct cl_object *obj,
+			    struct cl_lock *lock, const struct cl_io *io);
 int lov_lock_init_empty(const struct lu_env *env, struct cl_object *obj,
 			struct cl_lock *lock, const struct cl_io *io);
-int lov_io_init_raid0(const struct lu_env *env, struct cl_object *obj,
-		      struct cl_io *io);
+int lov_io_init_composite(const struct lu_env *env, struct cl_object *obj,
+			  struct cl_io *io);
 int lov_io_init_empty(const struct lu_env *env, struct cl_object *obj,
 		      struct cl_io *io);
 int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
@@ -445,8 +446,8 @@ int lovsub_page_init(const struct lu_env *env, struct cl_object *ob,
 		     struct cl_page *page, pgoff_t index);
 int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
 			struct cl_page *page, pgoff_t index);
-int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
-			struct cl_page *page, pgoff_t index);
+int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
+			    struct cl_page *page, pgoff_t index);
 struct lu_object *lov_object_alloc(const struct lu_env *env,
 				   const struct lu_object_header *hdr,
 				   struct lu_device *dev);
@@ -455,7 +456,6 @@ struct lu_object *lovsub_object_alloc(const struct lu_env *env,
 				      struct lu_device *dev);
 
 struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov);
-int lov_page_stripe(const struct cl_page *page);
 
 #define lov_foreach_target(lov, var)		    \
 	for (var = 0; var < lov_targets_nr(lov); ++var)
@@ -630,9 +630,10 @@ static inline struct lov_thread_info *lov_env_info(const struct lu_env *env)
 
 static inline struct lov_layout_raid0 *lov_r0(struct lov_object *lov)
 {
-	LASSERT(lov->lo_type == LLT_RAID0);
+	LASSERT(lov->lo_type == LLT_COMP);
 	LASSERT(lov->lo_lsm->lsm_magic == LOV_MAGIC ||
 		lov->lo_lsm->lsm_magic == LOV_MAGIC_V3);
+
 	return &lov->u.composite.lo_entries.lle_raid0;
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 2d62566..023b588 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -53,7 +53,7 @@ static void lov_io_sub_fini(const struct lu_env *env, struct lov_io *lio,
 			sub->sub_io_initialized = 0;
 			lio->lis_active_subios--;
 		}
-		if (sub->sub_stripe == lio->lis_single_subio_index)
+		if (sub->sub_subio_index == lio->lis_single_subio_index)
 			lio->lis_single_subio_index = -1;
 		else if (!sub->sub_borrowed)
 			kfree(sub->sub_io);
@@ -143,12 +143,12 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 	struct cl_io      *sub_io;
 	struct cl_object  *sub_obj;
 	struct cl_io      *io  = lio->lis_cl.cis_io;
-	int stripe = sub->sub_stripe;
+	int stripe = sub->sub_subio_index;
 	int rc;
 
 	LASSERT(!sub->sub_io);
 	LASSERT(!sub->sub_env);
-	LASSERT(sub->sub_stripe < lio->lis_stripe_count);
+	LASSERT(sub->sub_subio_index < lio->lis_stripe_count);
 
 	if (unlikely(!lov_r0(lov)->lo_sub[stripe]))
 		return -EIO;
@@ -203,15 +203,15 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 }
 
 struct lov_io_sub *lov_sub_get(const struct lu_env *env,
-			       struct lov_io *lio, int stripe)
+			       struct lov_io *lio, int index)
 {
 	int rc;
-	struct lov_io_sub *sub = &lio->lis_subs[stripe];
+	struct lov_io_sub *sub = &lio->lis_subs[index];
 
-	LASSERT(stripe < lio->lis_stripe_count);
+	LASSERT(index < lio->lis_stripe_count);
 
 	if (!sub->sub_io_initialized) {
-		sub->sub_stripe = stripe;
+		sub->sub_subio_index = index;
 		rc = lov_io_sub_init(env, lio, sub);
 	} else {
 		rc = 0;
@@ -228,14 +228,14 @@ struct lov_io_sub *lov_sub_get(const struct lu_env *env,
  *
  */
 
-int lov_page_stripe(const struct cl_page *page)
+static int lov_page_index(const struct cl_page *page)
 {
 	const struct cl_page_slice *slice;
 
 	slice = cl_page_at(page, &lov_device_type);
 	LASSERT(slice->cpl_obj);
 
-	return cl2lov_page(slice)->lps_stripe;
+	return cl2lov_page(slice)->lps_index;
 }
 
 static int lov_io_subio_init(const struct lu_env *env, struct lov_io *lio,
@@ -630,8 +630,7 @@ static int lov_io_submit(const struct lu_env *env,
 	struct lov_io_sub *sub;
 	struct cl_page_list *plist = &lov_env_info(env)->lti_plist;
 	struct cl_page *page;
-	int stripe;
-
+	int index;
 	int rc = 0;
 
 	if (lio->lis_active_subios == 1) {
@@ -657,16 +656,16 @@ static int lov_io_submit(const struct lu_env *env,
 		page = cl_page_list_first(qin);
 		cl_page_list_move(&cl2q->c2_qin, qin, page);
 
-		stripe = lov_page_stripe(page);
+		index = lov_page_index(page);
 		while (qin->pl_nr > 0) {
 			page = cl_page_list_first(qin);
-			if (stripe != lov_page_stripe(page))
+			if (index != lov_page_index(page))
 				break;
 
 			cl_page_list_move(&cl2q->c2_qin, qin, page);
 		}
 
-		sub = lov_sub_get(env, lio, stripe);
+		sub = lov_sub_get(env, lio, index);
 		if (!IS_ERR(sub)) {
 			rc = cl_io_submit_rw(sub->sub_env, sub->sub_io,
 					     crt, cl2q);
@@ -716,16 +715,16 @@ static int lov_io_commit_async(const struct lu_env *env,
 	cl_page_list_init(plist);
 	while (queue->pl_nr > 0) {
 		int stripe_to = to;
-		int stripe;
+		int index;
 
 		LASSERT(plist->pl_nr == 0);
 		page = cl_page_list_first(queue);
 		cl_page_list_move(plist, queue, page);
 
-		stripe = lov_page_stripe(page);
+		index = lov_page_index(page);
 		while (queue->pl_nr > 0) {
 			page = cl_page_list_first(queue);
-			if (stripe != lov_page_stripe(page))
+			if (index != lov_page_index(page))
 				break;
 
 			cl_page_list_move(plist, queue, page);
@@ -734,7 +733,7 @@ static int lov_io_commit_async(const struct lu_env *env,
 		if (queue->pl_nr > 0) /* still has more pages */
 			stripe_to = PAGE_SIZE;
 
-		sub = lov_sub_get(env, lio, stripe);
+		sub = lov_sub_get(env, lio, index);
 		if (!IS_ERR(sub)) {
 			rc = cl_io_commit_async(sub->sub_env, sub->sub_io,
 						plist, from, stripe_to, cb);
@@ -769,7 +768,7 @@ static int lov_io_fault_start(const struct lu_env *env,
 
 	fio = &ios->cis_io->u.ci_fault;
 	lio = cl2lov_io(env, ios);
-	sub = lov_sub_get(env, lio, lov_page_stripe(fio->ft_page));
+	sub = lov_sub_get(env, lio, lov_page_index(fio->ft_page));
 	if (IS_ERR(sub))
 		return PTR_ERR(sub);
 	sub->sub_io->u.ci_fault.ft_nob = fio->ft_nob;
@@ -941,8 +940,8 @@ static void lov_empty_impossible(const struct lu_env *env,
 	.cio_commit_async              = LOV_EMPTY_IMPOSSIBLE
 };
 
-int lov_io_init_raid0(const struct lu_env *env, struct cl_object *obj,
-		      struct cl_io *io)
+int lov_io_init_composite(const struct lu_env *env, struct cl_object *obj,
+			  struct cl_io *io)
 {
 	struct lov_io       *lio = lov_env_io(env);
 	struct lov_object   *lov = cl2lov(obj);
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index b029210..4340063 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -73,7 +73,7 @@ static struct lov_sublock_env *lov_sublock_env_get(const struct lu_env *env,
 		subenv->lse_env = env;
 		subenv->lse_io  = io;
 	} else {
-		sub = lov_sub_get(env, lio, lls->sub_stripe);
+		sub = lov_sub_get(env, lio, lls->sub_index);
 		if (!IS_ERR(sub)) {
 			subenv->lse_env = sub->sub_env;
 			subenv->lse_io  = sub->sub_io;
@@ -167,7 +167,7 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 			descr->cld_mode  = lock->cll_descr.cld_mode;
 			descr->cld_gid   = lock->cll_descr.cld_gid;
 			descr->cld_enq_flags = lock->cll_descr.cld_enq_flags;
-			lls->sub_stripe = i;
+			lls->sub_index = i;
 
 			/* initialize sub lock */
 			result = lov_sublock_init(env, lock, lls);
@@ -295,8 +295,8 @@ static int lov_lock_print(const struct lu_env *env, void *cookie,
 	.clo_print     = lov_lock_print
 };
 
-int lov_lock_init_raid0(const struct lu_env *env, struct cl_object *obj,
-			struct cl_lock *lock, const struct cl_io *io)
+int lov_lock_init_composite(const struct lu_env *env, struct cl_object *obj,
+			    struct cl_lock *lock, const struct cl_io *io)
 {
 	struct lov_lock *lck;
 	int result = 0;
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 15ed378..f5c6da1 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -110,9 +110,9 @@ static int lov_init_empty(const struct lu_env *env, struct lov_device *dev,
 	return 0;
 }
 
-static void lov_install_raid0(const struct lu_env *env,
-			      struct lov_object *lov,
-			      union lov_layout_state *state)
+static void lov_install_composite(const struct lu_env *env,
+				  struct lov_object *lov,
+				  union lov_layout_state *state)
 {
 }
 
@@ -129,7 +129,7 @@ static struct cl_object *lov_sub_find(const struct lu_env *env,
 }
 
 static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
-			struct cl_object *stripe, struct lov_layout_raid0 *r0,
+			struct cl_object *subobj, struct lov_layout_raid0 *r0,
 			int idx)
 {
 	struct cl_object_header *hdr;
@@ -145,13 +145,13 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 		 * lov_oinfo of lsm_stripe_data which will be freed due to
 		 * this failure.
 		 */
-		cl_object_kill(env, stripe);
-		cl_object_put(env, stripe);
+		cl_object_kill(env, subobj);
+		cl_object_put(env, subobj);
 		return -EIO;
 	}
 
 	hdr    = cl_object_header(lov2cl(lov));
-	subhdr = cl_object_header(stripe);
+	subhdr = cl_object_header(subobj);
 
 	oinfo = lov->lo_lsm->lsm_entries[0]->lsme_oinfo[idx];
 	CDEBUG(D_INODE, DFID "@%p[%d] -> " DFID "@%p: ostid: " DOSTID " idx: %d gen: %d\n",
@@ -166,8 +166,8 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 		subhdr->coh_parent = hdr;
 		spin_unlock(&subhdr->coh_attr_guard);
 		subhdr->coh_nesting = hdr->coh_nesting + 1;
-		lu_object_ref_add(&stripe->co_lu, "lov-parent", lov);
-		r0->lo_sub[idx] = cl2lovsub(stripe);
+		lu_object_ref_add(&subobj->co_lu, "lov-parent", lov);
+		r0->lo_sub[idx] = cl2lovsub(subobj);
 		r0->lo_sub[idx]->lso_super = lov;
 		r0->lo_sub[idx]->lso_index = idx;
 		result = 0;
@@ -184,18 +184,18 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 			/* the object's layout has already changed but isn't
 			 * refreshed
 			 */
-			lu_object_unhash(env, &stripe->co_lu);
+			lu_object_unhash(env, &subobj->co_lu);
 			result = -EAGAIN;
 		} else {
 			mask = D_ERROR;
 			result = -EIO;
 		}
 
-		LU_OBJECT_DEBUG(mask, env, &stripe->co_lu,
+		LU_OBJECT_DEBUG(mask, env, &subobj->co_lu,
 				"stripe %d is already owned.", idx);
 		LU_OBJECT_DEBUG(mask, env, old_obj, "owned.");
 		LU_OBJECT_HEADER(mask, env, lov2lu(lov), "try to own.\n");
-		cl_object_put(env, stripe);
+		cl_object_put(env, subobj);
 	}
 	return result;
 }
@@ -219,7 +219,7 @@ static int lov_page_slice_fixup(struct lov_object *lov,
 static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 			  struct lov_object *lov, struct lov_stripe_md *lsm,
 			  const struct cl_object_conf *conf,
-			  union  lov_layout_state *state)
+			  struct lov_layout_raid0 *r0)
 {
 	int result;
 	int i;
@@ -228,7 +228,6 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 	struct lov_thread_info  *lti     = lov_env_info(env);
 	struct cl_object_conf   *subconf = &lti->lti_stripe_conf;
 	struct lu_fid	   *ofid    = &lti->lti_fid;
-	struct lov_layout_raid0 *r0 = &state->composite.lo_entries.lle_raid0;
 
 	if (lsm->lsm_magic != LOV_MAGIC_V1 && lsm->lsm_magic != LOV_MAGIC_V3) {
 		dump_lsm(D_ERROR, lsm);
@@ -310,6 +309,17 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 	return result;
 }
 
+static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
+			      struct lov_object *lov, struct lov_stripe_md *lsm,
+			      const struct cl_object_conf *conf,
+			      union lov_layout_state *state)
+{
+	struct lov_layout_composite *comp = &state->composite;
+	struct lov_layout_entry *le = &comp->lo_entries;
+
+	return lov_init_raid0(env, dev, lov, lsm, conf, &le->lle_raid0);
+}
+
 static int lov_init_released(const struct lu_env *env, struct lov_device *dev,
 			     struct lov_object *lov, struct lov_stripe_md *lsm,
 			     const struct cl_object_conf *conf,
@@ -337,7 +347,7 @@ static struct cl_object *lov_find_subobj(const struct lu_env *env,
 	int ost_idx;
 	int rc;
 
-	if (lov->lo_type != LLT_RAID0) {
+	if (lov->lo_type != LLT_COMP) {
 		result = NULL;
 		goto out;
 	}
@@ -367,15 +377,14 @@ static int lov_delete_empty(const struct lu_env *env, struct lov_object *lov,
 }
 
 static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
+			       struct lov_layout_raid0 *r0,
 			       struct lovsub_object *los, int idx)
 {
 	struct cl_object	*sub;
-	struct lov_layout_raid0 *r0;
 	struct lu_site	  *site;
 	wait_queue_head_t *wq;
 	wait_queue_entry_t	  *waiter;
 
-	r0  = &lov->u.composite.lo_entries.lle_raid0;
 	LASSERT(r0->lo_sub[idx] == los);
 
 	sub  = lovsub2cl(los);
@@ -415,17 +424,12 @@ static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
 	LASSERT(!r0->lo_sub[idx]);
 }
 
-static int lov_delete_raid0(const struct lu_env *env, struct lov_object *lov,
-			    union lov_layout_state *state)
+static void lov_delete_raid0(const struct lu_env *env, struct lov_object *lov,
+			     struct lov_layout_raid0 *r0)
 {
-	struct lov_layout_raid0 *r0 = &state->composite.lo_entries.lle_raid0;
-	struct lov_stripe_md    *lsm = lov->lo_lsm;
-	int i;
-
-	dump_lsm(D_INODE, lsm);
-
-	lov_layout_wait(env, lov);
 	if (r0->lo_sub) {
+		int i;
+
 		for (i = 0; i < r0->lo_nr; ++i) {
 			struct lovsub_object *los = r0->lo_sub[i];
 
@@ -435,10 +439,24 @@ static int lov_delete_raid0(const struct lu_env *env, struct lov_object *lov,
 				 * If top-level object is to be evicted from
 				 * the cache, so are its sub-objects.
 				 */
-				lov_subobject_kill(env, lov, los, i);
+				lov_subobject_kill(env, lov, r0, los, i);
 			}
 		}
 	}
+}
+
+static int lov_delete_composite(const struct lu_env *env,
+				struct lov_object *lov,
+				union lov_layout_state *state)
+{
+	struct lov_layout_composite *comp = &state->composite;
+	struct lov_layout_entry *entry = &comp->lo_entries;
+
+	dump_lsm(D_INODE, lov->lo_lsm);
+
+	lov_layout_wait(env, lov);
+	lov_delete_raid0(env, lov, &entry->lle_raid0);
+
 	return 0;
 }
 
@@ -448,15 +466,23 @@ static void lov_fini_empty(const struct lu_env *env, struct lov_object *lov,
 	LASSERT(lov->lo_type == LLT_EMPTY || lov->lo_type == LLT_RELEASED);
 }
 
-static void lov_fini_raid0(const struct lu_env *env, struct lov_object *lov,
-			   union lov_layout_state *state)
+static void lov_fini_raid0(const struct lu_env *env,
+			   struct lov_layout_raid0 *r0)
 {
-	struct lov_layout_raid0 *r0 = &state->composite.lo_entries.lle_raid0;
-
 	if (r0->lo_sub) {
 		kvfree(r0->lo_sub);
 		r0->lo_sub = NULL;
 	}
+}
+
+static void lov_fini_composite(const struct lu_env *env,
+			       struct lov_object *lov,
+			       union lov_layout_state *state)
+{
+	struct lov_layout_composite *comp = &state->composite;
+	struct lov_layout_entry *entry = &comp->lo_entries;
+
+	lov_fini_raid0(env, &entry->lle_raid0);
 
 	dump_lsm(D_INODE, lov->lo_lsm);
 	lov_free_memmd(&lov->lo_lsm);
@@ -477,17 +503,10 @@ static int lov_print_empty(const struct lu_env *env, void *cookie,
 }
 
 static int lov_print_raid0(const struct lu_env *env, void *cookie,
-			   lu_printer_t p, const struct lu_object *o)
+			   lu_printer_t p, struct lov_layout_raid0 *r0)
 {
-	struct lov_object	*lov = lu2lov(o);
-	struct lov_layout_raid0	*r0  = lov_r0(lov);
-	struct lov_stripe_md	*lsm = lov->lo_lsm;
-	int			 i;
+	int i;
 
-	(*p)(env, cookie, "stripes: %d, %s, lsm{%p 0x%08X %d %u %u}:\n",
-	     r0->lo_nr, lov->lo_layout_invalid ? "invalid" : "valid", lsm,
-	     lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
-	     lsm->lsm_entries[0]->lsme_stripe_count, lsm->lsm_layout_gen);
 	for (i = 0; i < r0->lo_nr; ++i) {
 		struct lu_object *sub;
 
@@ -501,6 +520,23 @@ static int lov_print_raid0(const struct lu_env *env, void *cookie,
 	return 0;
 }
 
+static int lov_print_composite(const struct lu_env *env, void *cookie,
+			       lu_printer_t p, const struct lu_object *o)
+{
+	struct lov_object *lov = lu2lov(o);
+	struct lov_layout_raid0	*r0 = lov_r0(lov);
+	struct lov_stripe_md *lsm = lov->lo_lsm;
+
+	(*p)(env, cookie, "stripes: %d, %s, lsm{%p 0x%08X %d %u %u}:\n",
+	     r0->lo_nr, lov->lo_layout_invalid ? "invalid" : "valid", lsm,
+	     lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
+	     lsm->lsm_entries[0]->lsme_stripe_count, lsm->lsm_layout_gen);
+
+	lov_print_raid0(env, cookie, p, r0);
+
+	return 0;
+}
+
 static int lov_print_released(const struct lu_env *env, void *cookie,
 			      lu_printer_t p, const struct lu_object *o)
 {
@@ -525,17 +561,13 @@ static int lov_print_released(const struct lu_env *env, void *cookie,
 static int lov_attr_get_empty(const struct lu_env *env, struct cl_object *obj,
 			      struct cl_attr *attr)
 {
-	attr->cat_blocks = 0;
 	return 0;
 }
 
-static int lov_attr_get_raid0(const struct lu_env *env, struct cl_object *obj,
-			      struct cl_attr *attr)
+static int lov_attr_get_raid0(const struct lu_env *env, struct lov_object *lov,
+			      struct cl_attr *attr, struct lov_layout_raid0 *r0)
 {
-	struct lov_object	*lov = cl2lov(obj);
-	struct lov_layout_raid0 *r0 = lov_r0(lov);
-	struct cl_attr		*lov_attr = &r0->lo_attr;
-	int			 result = 0;
+	int result = 0;
 
 	/* this is called w/o holding type guard mutex, so it must be inside
 	 * an on going IO otherwise lsm may be replaced.
@@ -577,22 +609,38 @@ static int lov_attr_get_raid0(const struct lu_env *env, struct cl_object *obj,
 		result = lov_merge_lvb_kms(lsm, lvb, &kms);
 		lov_stripe_unlock(lsm);
 		if (result == 0) {
-			cl_lvb2attr(lov_attr, lvb);
-			lov_attr->cat_kms = kms;
+			cl_lvb2attr(attr, lvb);
+			attr->cat_kms = kms;
 			r0->lo_attr_valid = 1;
 		}
 	}
-	if (result == 0) { /* merge results */
-		attr->cat_blocks = lov_attr->cat_blocks;
-		attr->cat_size = lov_attr->cat_size;
-		attr->cat_kms = lov_attr->cat_kms;
-		if (attr->cat_atime < lov_attr->cat_atime)
-			attr->cat_atime = lov_attr->cat_atime;
-		if (attr->cat_ctime < lov_attr->cat_ctime)
-			attr->cat_ctime = lov_attr->cat_ctime;
-		if (attr->cat_mtime < lov_attr->cat_mtime)
-			attr->cat_mtime = lov_attr->cat_mtime;
-	}
+
+	return result;
+}
+
+static int lov_attr_get_composite(const struct lu_env *env,
+				  struct cl_object *obj,
+				  struct cl_attr *attr)
+{
+	struct lov_object *lov = cl2lov(obj);
+	struct lov_layout_raid0 *r0 = lov_r0(lov);
+	struct cl_attr *lov_attr = &r0->lo_attr;
+	int result;
+
+	result = lov_attr_get_raid0(env, lov, attr, r0);
+	if (result)
+		return result;
+
+	attr->cat_blocks = lov_attr->cat_blocks;
+	attr->cat_size = lov_attr->cat_size;
+	attr->cat_kms = lov_attr->cat_kms;
+	if (attr->cat_atime < lov_attr->cat_atime)
+		attr->cat_atime = lov_attr->cat_atime;
+	if (attr->cat_ctime < lov_attr->cat_ctime)
+		attr->cat_ctime = lov_attr->cat_ctime;
+	if (attr->cat_mtime < lov_attr->cat_mtime)
+		attr->cat_mtime = lov_attr->cat_mtime;
+
 	return result;
 }
 
@@ -608,17 +656,6 @@ static int lov_attr_get_raid0(const struct lu_env *env, struct cl_object *obj,
 		.llo_io_init   = lov_io_init_empty,
 		.llo_getattr   = lov_attr_get_empty
 	},
-	[LLT_RAID0] = {
-		.llo_init      = lov_init_raid0,
-		.llo_delete    = lov_delete_raid0,
-		.llo_fini      = lov_fini_raid0,
-		.llo_install   = lov_install_raid0,
-		.llo_print     = lov_print_raid0,
-		.llo_page_init = lov_page_init_raid0,
-		.llo_lock_init = lov_lock_init_raid0,
-		.llo_io_init   = lov_io_init_raid0,
-		.llo_getattr   = lov_attr_get_raid0
-	},
 	[LLT_RELEASED] = {
 		.llo_init      = lov_init_released,
 		.llo_delete    = lov_delete_empty,
@@ -629,7 +666,18 @@ static int lov_attr_get_raid0(const struct lu_env *env, struct cl_object *obj,
 		.llo_lock_init = lov_lock_init_empty,
 		.llo_io_init   = lov_io_init_released,
 		.llo_getattr   = lov_attr_get_empty
-	}
+	},
+	[LLT_COMP] = {
+		.llo_init	= lov_init_composite,
+		.llo_delete	= lov_delete_composite,
+		.llo_fini	= lov_fini_composite,
+		.llo_install	= lov_install_composite,
+		.llo_print	= lov_print_composite,
+		.llo_page_init	= lov_page_init_composite,
+		.llo_lock_init	= lov_lock_init_composite,
+		.llo_io_init	= lov_io_init_composite,
+		.llo_getattr	= lov_attr_get_composite,
+	},
 };
 
 /**
@@ -659,7 +707,7 @@ static enum lov_layout_type lov_type(struct lov_stripe_md *lsm)
 	if (lsm->lsm_is_released)
 		return LLT_RELEASED;
 
-	return LLT_RAID0;
+	return LLT_COMP;
 }
 
 static inline void lov_conf_freeze(struct lov_object *lov)
@@ -1610,7 +1658,7 @@ int lov_read_and_clear_async_rc(struct cl_object *clob)
 
 		lov_conf_freeze(lov);
 		switch (lov->lo_type) {
-		case LLT_RAID0: {
+		case LLT_COMP: {
 			struct lov_stripe_md *lsm;
 			int i;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index f1c99a2..d94d003 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -50,22 +50,21 @@
  * Lov page operations.
  *
  */
-
-static int lov_raid0_page_print(const struct lu_env *env,
-				const struct cl_page_slice *slice,
-				void *cookie, lu_printer_t printer)
+static int lov_comp_page_print(const struct lu_env *env,
+			       const struct cl_page_slice *slice,
+			       void *cookie, lu_printer_t printer)
 {
 	struct lov_page *lp = cl2lov_page(slice);
 
 	return (*printer)(env, cookie, LUSTRE_LOV_NAME "-page@%p, raid0\n", lp);
 }
 
-static const struct cl_page_operations lov_raid0_page_ops = {
-	.cpo_print  = lov_raid0_page_print
+static const struct cl_page_operations lov_comp_page_ops = {
+	.cpo_print  = lov_comp_page_print
 };
 
-int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
-			struct cl_page *page, pgoff_t index)
+int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
+			    struct cl_page *page, pgoff_t index)
 {
 	struct lov_object *loo = cl2lov(obj);
 	struct lov_layout_raid0 *r0 = lov_r0(loo);
@@ -85,8 +84,8 @@ int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
 	rc = lov_stripe_offset(loo->lo_lsm, offset, stripe, &suboff);
 	LASSERT(rc == 0);
 
-	lpg->lps_stripe = stripe;
-	cl_page_slice_add(page, &lpg->lps_cl, obj, index, &lov_raid0_page_ops);
+	lpg->lps_index = stripe;
+	cl_page_slice_add(page, &lpg->lps_cl, obj, index, &lov_comp_page_ops);
 
 	sub = lov_sub_get(env, lio, stripe);
 	if (IS_ERR(sub))
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
index 7360c16..d3e9537 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_object.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_object.c
@@ -79,11 +79,14 @@ static void lovsub_object_free(const struct lu_env *env, struct lu_object *obj)
 	 * object handling in lu_object_find.
 	 */
 	if (lov) {
-		LASSERT(lov->lo_type == LLT_RAID0);
-		LASSERT(lov->u.composite.lo_entries.lle_raid0.lo_sub[los->lso_index] == los);
-		spin_lock(&lov->u.composite.lo_entries.lle_raid0.lo_sub_lock);
-		lov->u.composite.lo_entries.lle_raid0.lo_sub[los->lso_index] = NULL;
-		spin_unlock(&lov->u.composite.lo_entries.lle_raid0.lo_sub_lock);
+		int stripe = los->lso_index;
+		struct lov_layout_raid0 *r0 = lov_r0(lov);
+
+		LASSERT(lov->lo_type == LLT_COMP);
+		LASSERT(r0->lo_sub[stripe] == los);
+		spin_lock(&r0->lo_sub_lock);
+		r0->lo_sub[stripe] = NULL;
+		spin_unlock(&r0->lo_sub_lock);
 	}
 
 	lu_object_fini(obj);
-- 
1.8.3.1
