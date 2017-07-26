From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:21 -0400
Subject: [lustre-devel] [PATCH 05/20] staging: lustre: lov: remove unused
	code
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: "John L. Hammond" <john.hammond@intel.com>

Remove:
  the tested but never set flag OBD_STATFS_PTLRPCD,
  the empty file lustre/lov/lovsub_io.c,
  the unused ld_emerg member of struct lov_device,
  the unused struct lov_device_emerg and supporting functions,
  the unused struct lov_lock_link and supporting functions, and
  the unused, get only, or set only members of struct
  lovsub_device, lovsub_lock, lov_sublock_env, lov_thread_info,
  lov_io_sub, lov_io, lov_request, and lov_request_set.
Reduce the scope of several functions from lov_request.c.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5814
Reviewed-on: http://review.whamcloud.com/14878
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd_class.h  |   9 +-
 drivers/staging/lustre/lustre/lov/Makefile         |   2 +-
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  90 -------------
 drivers/staging/lustre/lustre/lov/lov_dev.c        |  85 ------------
 drivers/staging/lustre/lustre/lov/lov_internal.h   |  27 ----
 drivers/staging/lustre/lustre/lov/lov_io.c         | 144 ++++++---------------
 drivers/staging/lustre/lustre/lov/lov_lock.c       |  11 --
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   3 +-
 drivers/staging/lustre/lustre/lov/lov_page.c       |   1 -
 drivers/staging/lustre/lustre/lov/lov_request.c    |  40 +-----
 drivers/staging/lustre/lustre/lov/lovsub_dev.c     |   1 -
 drivers/staging/lustre/lustre/lov/lovsub_io.c      |  51 --------
 drivers/staging/lustre/lustre/lov/lovsub_lock.c    |   2 -
 13 files changed, 53 insertions(+), 413 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/lov/lovsub_io.c

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 083a6ff..a6a4b2f 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -46,14 +46,7 @@
 #define OBD_STATFS_FROM_CACHE   0x0002  /* the statfs callback should not update
 					 * obd_osfs_age
 					 */
-#define OBD_STATFS_PTLRPCD      0x0004  /* requests will be sent via ptlrpcd
-					 * instead of a specific set. This
-					 * means that we cannot rely on the set
-					 * interpret routine to be called.
-					 * lov_statfs_fini() must thus be called
-					 * by the request interpret routine
-					 */
-#define OBD_STATFS_FOR_MDT0	0x0008	/* The statfs is only for retrieving
+#define OBD_STATFS_FOR_MDT0	0x0004	/* The statfs is only for retrieving
 					 * information from MDT0.
 					 */
 
diff --git a/drivers/staging/lustre/lustre/lov/Makefile b/drivers/staging/lustre/lustre/lov/Makefile
index e4cc0db..ea93add 100644
--- a/drivers/staging/lustre/lustre/lov/Makefile
+++ b/drivers/staging/lustre/lustre/lov/Makefile
@@ -2,4 +2,4 @@ obj-$(CONFIG_LUSTRE_FS) += lov.o
 lov-y := lov_obd.o lov_pack.o lov_offset.o lov_merge.o \
 	 lov_request.o lov_ea.o lov_dev.o lov_object.o lov_page.o  \
 	 lov_lock.o lov_io.o lovsub_dev.o lovsub_object.o lovsub_page.o      \
-	 lovsub_lock.o lovsub_io.o lov_pool.o lproc_lov.o
+	 lovsub_lock.o lov_pool.o lproc_lov.o
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index e889d3a..38281b2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -92,35 +92,6 @@ enum lov_device_flags {
  * Upper half.
  */
 
-/**
- * Resources that are used in memory-cleaning path, and whose allocation
- * cannot fail even when memory is tight. They are preallocated in sufficient
- * quantities in lov_device::ld_emerg[], and access to them is serialized
- * lov_device::ld_mutex.
- */
-struct lov_device_emerg {
-	/**
-	 * Page list used to submit IO when memory is in pressure.
-	 */
-	struct cl_page_list emrg_page_list;
-	/**
-	 * sub-io's shared by all threads accessing this device when memory is
-	 * too low to allocate sub-io's dynamically.
-	 */
-	struct cl_io	emrg_subio;
-	/**
-	 * Environments used by sub-io's in
-	 * lov_device_emerg::emrg_subio.
-	 */
-	struct lu_env      *emrg_env;
-	/**
-	 * Refchecks for lov_device_emerg::emrg_env.
-	 *
-	 * \see cl_env_get()
-	 */
-	u16		 emrg_refcheck;
-};
-
 struct lov_device {
 	/*
 	 * XXX Locking of lov-private data is missing.
@@ -131,14 +102,6 @@ struct lov_device {
 	__u32		     ld_target_nr;
 	struct lovsub_device    **ld_target;
 	__u32		     ld_flags;
-
-	/** Emergency resources used in memory-cleansing paths. */
-	struct lov_device_emerg **ld_emrg;
-	/**
-	 * Serializes access to lov_device::ld_emrg in low-memory
-	 * conditions.
-	 */
-	struct mutex		  ld_mutex;
 };
 
 /**
@@ -299,8 +262,6 @@ struct lov_page {
 
 struct lovsub_device {
 	struct cl_device   acid_cl;
-	struct lov_device *acid_super;
-	int		acid_idx;
 	struct cl_device  *acid_next;
 };
 
@@ -312,42 +273,10 @@ struct lovsub_object {
 };
 
 /**
- * A link between a top-lock and a sub-lock. Separate data-structure is
- * necessary, because top-locks and sub-locks are in M:N relationship.
- *
- * \todo This can be optimized for a (by far) most frequent case of a single
- * top-lock per sub-lock.
- */
-struct lov_lock_link {
-	struct lov_lock *lll_super;
-	/** An index within parent lock. */
-	int	      lll_idx;
-	/**
-	 * A linkage into per sub-lock list of all corresponding top-locks,
-	 * hanging off lovsub_lock::lss_parents.
-	 */
-	struct list_head       lll_list;
-};
-
-/**
  * Lock state at lovsub layer.
  */
 struct lovsub_lock {
 	struct cl_lock_slice  lss_cl;
-	/**
-	 * List of top-locks that have given sub-lock as their part. Protected
-	 * by cl_lock::cll_guard mutex.
-	 */
-	struct list_head	    lss_parents;
-	/**
-	 * Top-lock that initiated current operation on this sub-lock. This is
-	 * only set during top-to-bottom lock operations like enqueue, and is
-	 * used to optimize state change notification. Protected by
-	 * cl_lock::cll_guard mutex.
-	 *
-	 * \see lovsub_lock_state_one().
-	 */
-	struct cl_lock       *lss_active;
 };
 
 /**
@@ -356,7 +285,6 @@ struct lovsub_lock {
 struct lov_sublock_env {
 	const struct lu_env *lse_env;
 	struct cl_io	*lse_io;
-	struct lov_io_sub   *lse_sub;
 };
 
 struct lovsub_page {
@@ -366,12 +294,10 @@ struct lovsub_page {
 struct lov_thread_info {
 	struct cl_object_conf   lti_stripe_conf;
 	struct lu_fid	   lti_fid;
-	struct cl_lock_descr    lti_ldescr;
 	struct ost_lvb	  lti_lvb;
 	struct cl_2queue	lti_cl2q;
 	struct cl_page_list     lti_plist;
 	wait_queue_entry_t	  lti_waiter;
-	struct cl_attr          lti_attr;
 };
 
 /**
@@ -385,7 +311,6 @@ struct lov_io_sub {
 	 * \see cl_env_get()
 	 */
 	u16			 sub_refcheck;
-	u16			 sub_reenter;
 	/**
 	 * true, iff cl_io_init() was successfully executed against
 	 * lov_io_sub::sub_io.
@@ -445,7 +370,6 @@ struct lov_io {
 	 */
 	u64	    lis_endpos;
 
-	int		lis_mem_frozen;
 	int		lis_stripe_count;
 	int		lis_active_subios;
 
@@ -485,8 +409,6 @@ struct lov_session {
 extern struct kmem_cache *lovsub_lock_kmem;
 extern struct kmem_cache *lovsub_object_kmem;
 
-extern struct kmem_cache *lov_lock_link_kmem;
-
 int lov_object_init(const struct lu_env *env, struct lu_object *obj,
 		    const struct lu_object_conf *conf);
 int lovsub_object_init(const struct lu_env *env, struct lu_object *obj,
@@ -508,15 +430,9 @@ int lov_io_init_empty(const struct lu_env *env, struct cl_object *obj,
 		      struct cl_io *io);
 int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
 			 struct cl_io *io);
-void lov_lock_unlink(const struct lu_env *env, struct lov_lock_link *link,
-		     struct lovsub_lock *sub);
 
 struct lov_io_sub *lov_sub_get(const struct lu_env *env, struct lov_io *lio,
 			       int stripe);
-void lov_sub_put(struct lov_io_sub *sub);
-int lov_sublock_modify(const struct lu_env *env, struct lov_lock *lov,
-		       struct lovsub_lock *sublock,
-		       const struct cl_lock_descr *d, int idx);
 
 int lov_page_init(const struct lu_env *env, struct cl_object *ob,
 		  struct cl_page *page, pgoff_t index);
@@ -533,12 +449,6 @@ struct lu_object *lovsub_object_alloc(const struct lu_env *env,
 				      const struct lu_object_header *hdr,
 				      struct lu_device *dev);
 
-struct lov_lock_link *lov_lock_link_find(const struct lu_env *env,
-					 struct lov_lock *lck,
-					 struct lovsub_lock *sub);
-struct lov_io_sub *lov_page_subio(const struct lu_env *env, struct lov_io *lio,
-				  const struct cl_page_slice *slice);
-
 struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov);
 int lov_page_stripe(const struct cl_page *page);
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_dev.c b/drivers/staging/lustre/lustre/lov/lov_dev.c
index 7301f6e5..531b4fe 100644
--- a/drivers/staging/lustre/lustre/lov/lov_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lov_dev.c
@@ -50,11 +50,6 @@
 struct kmem_cache *lovsub_lock_kmem;
 struct kmem_cache *lovsub_object_kmem;
 
-struct kmem_cache *lov_lock_link_kmem;
-
-/** Lock class of lov_device::ld_mutex. */
-static struct lock_class_key cl_lov_device_mutex_class;
-
 struct lu_kmem_descr lov_caches[] = {
 	{
 		.ckd_cache = &lov_lock_kmem,
@@ -87,11 +82,6 @@ struct lu_kmem_descr lov_caches[] = {
 		.ckd_size  = sizeof(struct lovsub_object)
 	},
 	{
-		.ckd_cache = &lov_lock_link_kmem,
-		.ckd_name  = "lov_lock_link_kmem",
-		.ckd_size  = sizeof(struct lov_lock_link)
-	},
-	{
 		.ckd_cache = NULL
 	}
 };
@@ -204,8 +194,6 @@ static int lov_device_init(const struct lu_env *env, struct lu_device *d,
 			break;
 		}
 		lsd = cl2lovsub_dev(cl);
-		lsd->acid_idx = i;
-		lsd->acid_super = ld;
 		ld->ld_target[i] = lsd;
 	}
 
@@ -217,34 +205,13 @@ static int lov_device_init(const struct lu_env *env, struct lu_device *d,
 	return rc;
 }
 
-static void lov_emerg_free(struct lov_device_emerg **emrg, int nr)
-{
-	int i;
-
-	for (i = 0; i < nr; ++i) {
-		struct lov_device_emerg *em;
-
-		em = emrg[i];
-		if (em) {
-			LASSERT(em->emrg_page_list.pl_nr == 0);
-			if (em->emrg_env)
-				cl_env_put(em->emrg_env, &em->emrg_refcheck);
-			kfree(em);
-		}
-	}
-	kfree(emrg);
-}
-
 static struct lu_device *lov_device_free(const struct lu_env *env,
 					 struct lu_device *d)
 {
 	struct lov_device *ld = lu2lov_dev(d);
-	const int	  nr = ld->ld_target_nr;
 
 	cl_device_fini(lu2cl_dev(d));
 	kfree(ld->ld_target);
-	if (ld->ld_emrg)
-		lov_emerg_free(ld->ld_emrg, nr);
 	kfree(ld);
 	return NULL;
 }
@@ -260,41 +227,6 @@ static void lov_cl_del_target(const struct lu_env *env, struct lu_device *dev,
 	}
 }
 
-static struct lov_device_emerg **lov_emerg_alloc(int nr)
-{
-	struct lov_device_emerg **emerg;
-	int i;
-	int result;
-
-	emerg = kcalloc(nr, sizeof(emerg[0]), GFP_NOFS);
-	if (!emerg)
-		return ERR_PTR(-ENOMEM);
-	for (result = i = 0; i < nr && result == 0; i++) {
-		struct lov_device_emerg *em;
-
-		em = kzalloc(sizeof(*em), GFP_NOFS);
-		if (em) {
-			emerg[i] = em;
-			cl_page_list_init(&em->emrg_page_list);
-			em->emrg_env = cl_env_alloc(&em->emrg_refcheck,
-						    LCT_REMEMBER | LCT_NOREF);
-			if (!IS_ERR(em->emrg_env)) {
-				em->emrg_env->le_ctx.lc_cookie = 0x2;
-			} else {
-				result = PTR_ERR(em->emrg_env);
-				em->emrg_env = NULL;
-			}
-		} else {
-			result = -ENOMEM;
-		}
-	}
-	if (result != 0) {
-		lov_emerg_free(emerg, nr);
-		emerg = ERR_PTR(result);
-	}
-	return emerg;
-}
-
 static int lov_expand_targets(const struct lu_env *env, struct lov_device *dev)
 {
 	int   result;
@@ -306,29 +238,17 @@ static int lov_expand_targets(const struct lu_env *env, struct lov_device *dev)
 	sub_size = dev->ld_target_nr;
 	if (sub_size < tgt_size) {
 		struct lovsub_device    **newd;
-		struct lov_device_emerg **emerg;
 		const size_t	      sz   = sizeof(newd[0]);
 
-		emerg = lov_emerg_alloc(tgt_size);
-		if (IS_ERR(emerg))
-			return PTR_ERR(emerg);
-
 		newd = kcalloc(tgt_size, sz, GFP_NOFS);
 		if (newd) {
-			mutex_lock(&dev->ld_mutex);
 			if (sub_size > 0) {
 				memcpy(newd, dev->ld_target, sub_size * sz);
 				kfree(dev->ld_target);
 			}
 			dev->ld_target    = newd;
 			dev->ld_target_nr = tgt_size;
-
-			if (dev->ld_emrg)
-				lov_emerg_free(dev->ld_emrg, sub_size);
-			dev->ld_emrg = emerg;
-			mutex_unlock(&dev->ld_mutex);
 		} else {
-			lov_emerg_free(emerg, tgt_size);
 			result = -ENOMEM;
 		}
 	}
@@ -362,8 +282,6 @@ static int lov_cl_add_target(const struct lu_env *env, struct lu_device *dev,
 				   tgt->ltd_obd->obd_lu_dev);
 		if (!IS_ERR(cl)) {
 			lsd = cl2lovsub_dev(cl);
-			lsd->acid_idx = index;
-			lsd->acid_super = ld;
 			ld->ld_target[index] = lsd;
 		} else {
 			CERROR("add failed (%d), deleting %s\n", rc,
@@ -428,9 +346,6 @@ static struct lu_device *lov_device_alloc(const struct lu_env *env,
 	d = lov2lu_dev(ld);
 	d->ld_ops	= &lov_lu_ops;
 
-	mutex_init(&ld->ld_mutex);
-	lockdep_set_class(&ld->ld_mutex, &cl_lov_device_mutex_class);
-
 	/* setup the LOV OBD */
 	obd = class_name2obd(lustre_cfg_string(cfg, 0));
 	LASSERT(obd);
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 774499c..9905df2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -161,42 +161,21 @@ struct lov_request {
 	struct list_head	       rq_link;
 
 	int		      rq_idx;	/* index in lov->tgts array */
-	int		      rq_stripe;     /* stripe number */
-	int		      rq_complete;
-	int		      rq_rc;
-
-	u32		      rq_oabufs;
-	u32		      rq_pgaidx;
 };
 
 struct lov_request_set {
 	struct obd_info			*set_oi;
-	atomic_t			set_refcount;
-	struct obd_export		*set_exp;
-	/* XXX: There is @set_exp already, however obd_statfs gets obd_device
-	 * only.
-	 */
 	struct obd_device		*set_obd;
 	int				set_count;
 	atomic_t			set_completes;
 	atomic_t			set_success;
-	atomic_t			set_finish_checked;
 	struct list_head			set_list;
-	wait_queue_head_t			set_waitq;
 };
 
 extern struct kmem_cache *lov_oinfo_slab;
 
 extern struct lu_kmem_descr lov_caches[];
 
-void lov_finish_set(struct lov_request_set *set);
-
-static inline void lov_put_reqset(struct lov_request_set *set)
-{
-	if (atomic_dec_and_test(&set->set_refcount))
-		lov_finish_set(set);
-}
-
 #define lov_uuid2str(lv, index) \
 	(char *)((lv)->lov_tgts[index]->ltd_uuid.uuid)
 
@@ -217,15 +196,9 @@ pgoff_t lov_stripe_pgoff(struct lov_stripe_md *lsm, pgoff_t stripe_index,
 			 int stripe);
 
 /* lov_request.c */
-int lov_prep_getattr_set(struct obd_export *exp, struct obd_info *oinfo,
-			 struct lov_request_set **reqset);
-int lov_fini_getattr_set(struct lov_request_set *set);
 int lov_prep_statfs_set(struct obd_device *obd, struct obd_info *oinfo,
 			struct lov_request_set **reqset);
-int lov_fini_statfs(struct obd_device *obd, struct obd_statfs *osfs,
-		    int success);
 int lov_fini_statfs_set(struct lov_request_set *set);
-int lov_statfs_interpret(struct ptlrpc_request_set *rqset, void *data, int rc);
 
 /* lov_obd.c */
 void lov_stripe_lock(struct lov_stripe_md *md);
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 3e37353..f6b5df7 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -43,24 +43,12 @@
  *  @{
  */
 
-static inline void lov_sub_enter(struct lov_io_sub *sub)
-{
-	sub->sub_reenter++;
-}
-
-static inline void lov_sub_exit(struct lov_io_sub *sub)
-{
-	sub->sub_reenter--;
-}
-
 static void lov_io_sub_fini(const struct lu_env *env, struct lov_io *lio,
 			    struct lov_io_sub *sub)
 {
 	if (sub->sub_io) {
 		if (sub->sub_io_initialized) {
-			lov_sub_enter(sub);
 			cl_io_fini(sub->sub_env, sub->sub_io);
-			lov_sub_exit(sub);
 			sub->sub_io_initialized = 0;
 			lio->lis_active_subios--;
 		}
@@ -142,13 +130,11 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 			   struct lov_io_sub *sub)
 {
 	struct lov_object *lov = lio->lis_object;
-	struct lov_device *ld  = lu2lov_dev(lov2cl(lov)->co_lu.lo_dev);
 	struct cl_io      *sub_io;
 	struct cl_object  *sub_obj;
 	struct cl_io      *io  = lio->lis_cl.cis_io;
-
 	int stripe = sub->sub_stripe;
-	int result;
+	int rc;
 
 	LASSERT(!sub->sub_io);
 	LASSERT(!sub->sub_env);
@@ -157,63 +143,53 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 	if (unlikely(!lov_r0(lov)->lo_sub[stripe]))
 		return -EIO;
 
-	result = 0;
 	sub->sub_io_initialized = 0;
 	sub->sub_borrowed = 0;
 
-	if (lio->lis_mem_frozen) {
-		LASSERT(mutex_is_locked(&ld->ld_mutex));
-		sub->sub_io  = &ld->ld_emrg[stripe]->emrg_subio;
-		sub->sub_env = ld->ld_emrg[stripe]->emrg_env;
-		sub->sub_borrowed = 1;
-	} else {
-		sub->sub_env = cl_env_get(&sub->sub_refcheck);
-		if (IS_ERR(sub->sub_env))
-			result = PTR_ERR(sub->sub_env);
+	/* obtain new environment */
+	sub->sub_env = cl_env_get(&sub->sub_refcheck);
+	if (IS_ERR(sub->sub_env)) {
+		rc = PTR_ERR(sub->sub_env);
+		goto fini_lov_io;
+	}
 
-		if (result == 0) {
-			/*
-			 * First sub-io. Use ->lis_single_subio to
-			 * avoid dynamic allocation.
-			 */
-			if (lio->lis_active_subios == 0) {
-				sub->sub_io = &lio->lis_single_subio;
-				lio->lis_single_subio_index = stripe;
-			} else {
-				sub->sub_io = kzalloc(sizeof(*sub->sub_io),
-						      GFP_NOFS);
-				if (!sub->sub_io)
-					result = -ENOMEM;
-			}
+	/*
+	 * First sub-io. Use ->lis_single_subio to
+	 * avoid dynamic allocation.
+	 */
+	if (lio->lis_active_subios == 0) {
+		sub->sub_io = &lio->lis_single_subio;
+		lio->lis_single_subio_index = stripe;
+	} else {
+		sub->sub_io = kzalloc(sizeof(*sub->sub_io),
+				      GFP_NOFS);
+		if (!sub->sub_io) {
+			rc = -ENOMEM;
+			goto fini_lov_io;
 		}
 	}
 
-	if (result == 0) {
-		sub_obj = lovsub2cl(lov_r0(lov)->lo_sub[stripe]);
-		sub_io  = sub->sub_io;
-
-		sub_io->ci_obj    = sub_obj;
-		sub_io->ci_result = 0;
-
-		sub_io->ci_parent  = io;
-		sub_io->ci_lockreq = io->ci_lockreq;
-		sub_io->ci_type    = io->ci_type;
-		sub_io->ci_no_srvlock = io->ci_no_srvlock;
-		sub_io->ci_noatime = io->ci_noatime;
-
-		lov_sub_enter(sub);
-		result = cl_io_sub_init(sub->sub_env, sub_io,
-					io->ci_type, sub_obj);
-		lov_sub_exit(sub);
-		if (result >= 0) {
-			lio->lis_active_subios++;
-			sub->sub_io_initialized = 1;
-			result = 0;
-		}
+	sub_obj = lovsub2cl(lov_r0(lov)->lo_sub[stripe]);
+	sub_io = sub->sub_io;
+
+	sub_io->ci_obj = sub_obj;
+	sub_io->ci_result = 0;
+	sub_io->ci_parent = io;
+	sub_io->ci_lockreq = io->ci_lockreq;
+	sub_io->ci_type = io->ci_type;
+	sub_io->ci_no_srvlock = io->ci_no_srvlock;
+	sub_io->ci_noatime = io->ci_noatime;
+
+	rc = cl_io_sub_init(sub->sub_env, sub_io, io->ci_type, sub_obj);
+	if (rc >= 0) {
+		lio->lis_active_subios++;
+		sub->sub_io_initialized = 1;
+		rc = 0;
 	}
-	if (result != 0)
+fini_lov_io:
+	if (rc)
 		lov_io_sub_fini(env, lio, sub);
-	return result;
+	return rc;
 }
 
 struct lov_io_sub *lov_sub_get(const struct lu_env *env,
@@ -230,16 +206,10 @@ struct lov_io_sub *lov_sub_get(const struct lu_env *env,
 	} else {
 		rc = 0;
 	}
-	if (rc == 0)
-		lov_sub_enter(sub);
-	else
+	if (rc < 0)
 		sub = ERR_PTR(rc);
-	return sub;
-}
 
-void lov_sub_put(struct lov_io_sub *sub)
-{
-	lov_sub_exit(sub);
+	return sub;
 }
 
 /*****************************************************************************
@@ -258,22 +228,6 @@ int lov_page_stripe(const struct cl_page *page)
 	return cl2lov_page(slice)->lps_stripe;
 }
 
-struct lov_io_sub *lov_page_subio(const struct lu_env *env, struct lov_io *lio,
-				  const struct cl_page_slice *slice)
-{
-	struct lov_stripe_md *lsm  = lio->lis_object->lo_lsm;
-	struct cl_page       *page = slice->cpl_page;
-	int stripe;
-
-	LASSERT(lio->lis_cl.cis_io);
-	LASSERT(cl2lov(slice->cpl_obj) == lio->lis_object);
-	LASSERT(lsm);
-	LASSERT(lio->lis_nr_subios > 0);
-
-	stripe = lov_page_stripe(page);
-	return lov_sub_get(env, lio, stripe);
-}
-
 static int lov_io_subio_init(const struct lu_env *env, struct lov_io *lio,
 			     struct cl_io *io)
 {
@@ -431,12 +385,10 @@ static int lov_io_iter_init(const struct lu_env *env,
 
 		lov_io_sub_inherit(sub->sub_io, lio, stripe, start, end);
 		rc = cl_io_iter_init(sub->sub_env, sub->sub_io);
-		if (rc)
+		if (rc) {
 			cl_io_iter_fini(sub->sub_env, sub->sub_io);
-		lov_sub_put(sub);
-		if (rc)
 			break;
-
+		}
 		CDEBUG(D_VFSTRACE, "shrink: %d [%llu, %llu)\n",
 		       stripe, start, end);
 
@@ -488,9 +440,7 @@ static int lov_io_call(const struct lu_env *env, struct lov_io *lio,
 	int rc = 0;
 
 	list_for_each_entry(sub, &lio->lis_active, sub_linkage) {
-		lov_sub_enter(sub);
 		rc = iofunc(sub->sub_env, sub->sub_io);
-		lov_sub_exit(sub);
 		if (rc)
 			break;
 
@@ -610,7 +560,6 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	rc = cl_io_read_ahead(sub->sub_env, sub->sub_io,
 			      cl_index(lovsub2cl(r0->lo_sub[stripe]), suboff),
 			      ra);
-	lov_sub_put(sub);
 
 	CDEBUG(D_READA, DFID " cra_end = %lu, stripes = %d, rc = %d\n",
 	       PFID(lu_object_fid(lov2lu(loo))), ra->cra_end, r0->lo_nr, rc);
@@ -679,7 +628,6 @@ static int lov_io_submit(const struct lu_env *env,
 		LASSERT(sub->sub_io == &lio->lis_single_subio);
 		rc = cl_io_submit_rw(sub->sub_env, sub->sub_io,
 				     crt, queue);
-		lov_sub_put(sub);
 		return rc;
 	}
 
@@ -707,7 +655,6 @@ static int lov_io_submit(const struct lu_env *env,
 		if (!IS_ERR(sub)) {
 			rc = cl_io_submit_rw(sub->sub_env, sub->sub_io,
 					     crt, cl2q);
-			lov_sub_put(sub);
 		} else {
 			rc = PTR_ERR(sub);
 		}
@@ -746,7 +693,6 @@ static int lov_io_commit_async(const struct lu_env *env,
 		LASSERT(sub->sub_io == &lio->lis_single_subio);
 		rc = cl_io_commit_async(sub->sub_env, sub->sub_io, queue,
 					from, to, cb);
-		lov_sub_put(sub);
 		return rc;
 	}
 
@@ -777,7 +723,6 @@ static int lov_io_commit_async(const struct lu_env *env,
 		if (!IS_ERR(sub)) {
 			rc = cl_io_commit_async(sub->sub_env, sub->sub_io,
 						plist, from, stripe_to, cb);
-			lov_sub_put(sub);
 		} else {
 			rc = PTR_ERR(sub);
 			break;
@@ -813,7 +758,6 @@ static int lov_io_fault_start(const struct lu_env *env,
 	if (IS_ERR(sub))
 		return PTR_ERR(sub);
 	sub->sub_io->u.ci_fault.ft_nob = fio->ft_nob;
-	lov_sub_put(sub);
 	return lov_io_start(env, ios);
 }
 
@@ -828,9 +772,7 @@ static void lov_io_fsync_end(const struct lu_env *env,
 	list_for_each_entry(sub, &lio->lis_active, sub_linkage) {
 		struct cl_io *subio = sub->sub_io;
 
-		lov_sub_enter(sub);
 		lov_io_end_wrapper(sub->sub_env, subio);
-		lov_sub_exit(sub);
 
 		if (subio->ci_result == 0)
 			*written += subio->u.ci_fsync.fi_nr_written;
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index 8502128..7d0d3ea 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -71,13 +71,11 @@ static struct lov_sublock_env *lov_sublock_env_get(const struct lu_env *env,
 	if (!io || !cl_object_same(io->ci_obj, parent->cll_descr.cld_obj)) {
 		subenv->lse_env = env;
 		subenv->lse_io  = io;
-		subenv->lse_sub = NULL;
 	} else {
 		sub = lov_sub_get(env, lio, lls->sub_stripe);
 		if (!IS_ERR(sub)) {
 			subenv->lse_env = sub->sub_env;
 			subenv->lse_io  = sub->sub_io;
-			subenv->lse_sub = sub;
 		} else {
 			subenv = (void *)sub;
 		}
@@ -85,12 +83,6 @@ static struct lov_sublock_env *lov_sublock_env_get(const struct lu_env *env,
 	return subenv;
 }
 
-static void lov_sublock_env_put(struct lov_sublock_env *subenv)
-{
-	if (subenv && subenv->lse_sub)
-		lov_sub_put(subenv->lse_sub);
-}
-
 static int lov_sublock_init(const struct lu_env *env,
 			    const struct cl_lock *parent,
 			    struct lov_lock_sub *lls)
@@ -102,7 +94,6 @@ static int lov_sublock_init(const struct lu_env *env,
 	if (!IS_ERR(subenv)) {
 		result = cl_lock_init(subenv->lse_env, &lls->sub_lock,
 				      subenv->lse_io);
-		lov_sublock_env_put(subenv);
 	} else {
 		/* error occurs. */
 		result = PTR_ERR(subenv);
@@ -244,7 +235,6 @@ static int lov_lock_enqueue(const struct lu_env *env,
 		}
 		rc = cl_lock_enqueue(subenv->lse_env, subenv->lse_io,
 				     &lls->sub_lock, anchor);
-		lov_sublock_env_put(subenv);
 		if (rc != 0)
 			break;
 
@@ -272,7 +262,6 @@ static void lov_lock_cancel(const struct lu_env *env,
 		subenv = lov_sublock_env_get(env, lock, lls);
 		if (!IS_ERR(subenv)) {
 			cl_lock_cancel(subenv->lse_env, sublock);
-			lov_sublock_env_put(subenv);
 		} else {
 			CL_LOCK_DEBUG(D_ERROR, env, slice->cls_lock,
 				      "lov_lock_cancel fails with %ld.\n",
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 25f15da..f27b11f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -947,7 +947,8 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
 	return rc;
 }
 
-int lov_statfs_interpret(struct ptlrpc_request_set *rqset, void *data, int rc)
+static int
+lov_statfs_interpret(struct ptlrpc_request_set *rqset, void *data, int rc)
 {
 	struct lov_request_set *lovset = (struct lov_request_set *)data;
 	int err;
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index 62ceb6d..de43c60 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -100,7 +100,6 @@ int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
 				break;
 		}
 	}
-	lov_sub_put(sub);
 
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 3a74791..70636e5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -43,13 +43,10 @@ static void lov_init_set(struct lov_request_set *set)
 	set->set_count = 0;
 	atomic_set(&set->set_completes, 0);
 	atomic_set(&set->set_success, 0);
-	atomic_set(&set->set_finish_checked, 0);
 	INIT_LIST_HEAD(&set->set_list);
-	atomic_set(&set->set_refcount, 1);
-	init_waitqueue_head(&set->set_waitq);
 }
 
-void lov_finish_set(struct lov_request_set *set)
+static void lov_finish_set(struct lov_request_set *set)
 {
 	struct list_head *pos, *n;
 
@@ -66,32 +63,12 @@ void lov_finish_set(struct lov_request_set *set)
 	kfree(set);
 }
 
-static int lov_set_finished(struct lov_request_set *set, int idempotent)
-{
-	int completes = atomic_read(&set->set_completes);
-
-	CDEBUG(D_INFO, "check set %d/%d\n", completes, set->set_count);
-
-	if (completes == set->set_count) {
-		if (idempotent)
-			return 1;
-		if (atomic_inc_return(&set->set_finish_checked) == 1)
-			return 1;
-	}
-	return 0;
-}
-
 static void lov_update_set(struct lov_request_set *set,
 			   struct lov_request *req, int rc)
 {
-	req->rq_complete = 1;
-	req->rq_rc = rc;
-
 	atomic_inc(&set->set_completes);
 	if (rc == 0)
 		atomic_inc(&set->set_success);
-
-	wake_up(&set->set_waitq);
 }
 
 static void lov_set_add_req(struct lov_request *req,
@@ -173,8 +150,8 @@ static int lov_check_and_wait_active(struct lov_obd *lov, int ost_idx)
 			(tot) += (add);				 \
 	} while (0)
 
-int lov_fini_statfs(struct obd_device *obd, struct obd_statfs *osfs,
-		    int success)
+static int lov_fini_statfs(struct obd_device *obd, struct obd_statfs *osfs,
+			   int success)
 {
 	if (success) {
 		__u32 expected_stripes = lov_get_stripecnt(&obd->u.lov,
@@ -205,7 +182,9 @@ int lov_fini_statfs_set(struct lov_request_set *set)
 		rc = lov_fini_statfs(set->set_obd, set->set_oi->oi_osfs,
 				     atomic_read(&set->set_success));
 	}
-	lov_put_reqset(set);
+
+	lov_finish_set(set);
+
 	return rc;
 }
 
@@ -307,14 +286,7 @@ static int cb_statfs_update(void *cookie, int rc)
 out_update:
 	lov_update_statfs(osfs, lov_sfs, success);
 	obd_putref(lovobd);
-
 out:
-	if (set->set_oi->oi_flags & OBD_STATFS_PTLRPCD &&
-	    lov_set_finished(set, 0)) {
-		lov_statfs_interpret(NULL, set, set->set_count !=
-				     atomic_read(&set->set_success));
-	}
-
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_dev.c b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
index 5d6536f..d4646a0 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
@@ -77,7 +77,6 @@ static struct lu_device *lovsub_device_fini(const struct lu_env *env,
 
 	lsd = lu2lovsub_dev(d);
 	next = cl2lu_dev(lsd->acid_next);
-	lsd->acid_super = NULL;
 	lsd->acid_next = NULL;
 	return next;
 }
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_io.c b/drivers/staging/lustre/lustre/lov/lovsub_io.c
deleted file mode 100644
index 6a98202..0000000
--- a/drivers/staging/lustre/lustre/lov/lovsub_io.c
+++ /dev/null
@@ -1,51 +0,0 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * Implementation of cl_io for LOVSUB layer.
- *
- *   Author: Nikita Danilov <nikita.danilov@sun.com>
- */
-
-#define DEBUG_SUBSYSTEM S_LOV
-
-#include "lov_cl_internal.h"
-
-/** \addtogroup lov
- *  @{
- */
-
-/*****************************************************************************
- *
- * Lovsub io operations.
- *
- */
-
-/* All trivial */
-
-/** @} lov */
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_lock.c b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
index 38f9b73..d29f0bb 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
@@ -54,7 +54,6 @@ static void lovsub_lock_fini(const struct lu_env *env,
 	struct lovsub_lock   *lsl;
 
 	lsl = cl2lovsub_lock(slice);
-	LASSERT(list_empty(&lsl->lss_parents));
 	kmem_cache_free(lovsub_lock_kmem, lsl);
 }
 
@@ -70,7 +69,6 @@ int lovsub_lock_init(const struct lu_env *env, struct cl_object *obj,
 
 	lsk = kmem_cache_zalloc(lovsub_lock_kmem, GFP_NOFS);
 	if (lsk) {
-		INIT_LIST_HEAD(&lsk->lss_parents);
 		cl_lock_slice_add(lock, &lsk->lss_cl, obj, &lovsub_lock_ops);
 		result = 0;
 	} else {
-- 
1.8.3.1
