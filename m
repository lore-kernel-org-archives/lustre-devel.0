From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:17 -0500
Subject: [lustre-devel] [PATCH 13/26] lov: cleanup white spaces
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The lov code is very messy and difficult to read. Remove excess
white space and properly align data structures so they are easy on
the eyes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  50 +++----
 drivers/staging/lustre/lustre/lov/lov_dev.c        |  62 ++++-----
 drivers/staging/lustre/lustre/lov/lov_internal.h   |  56 ++++----
 drivers/staging/lustre/lustre/lov/lov_io.c         | 136 +++++++++---------
 drivers/staging/lustre/lustre/lov/lov_lock.c       |  34 ++---
 drivers/staging/lustre/lustre/lov/lov_obd.c        |  21 ++-
 drivers/staging/lustre/lustre/lov/lov_object.c     | 154 ++++++++++-----------
 drivers/staging/lustre/lustre/lov/lov_offset.c     |   6 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |   4 +-
 drivers/staging/lustre/lustre/lov/lov_page.c       |  18 +--
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  20 +--
 drivers/staging/lustre/lustre/lov/lov_request.c    |  12 +-
 drivers/staging/lustre/lustre/lov/lovsub_dev.c     |  32 ++---
 drivers/staging/lustre/lustre/lov/lovsub_lock.c    |   4 +-
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |  29 ++--
 drivers/staging/lustre/lustre/lov/lovsub_page.c    |   2 +-
 drivers/staging/lustre/lustre/lov/lproc_lov.c      |  18 +--
 17 files changed, 328 insertions(+), 330 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index d83b8de..22ef7b2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -95,12 +95,12 @@ struct lov_device {
 	/*
 	 * XXX Locking of lov-private data is missing.
 	 */
-	struct cl_device	  ld_cl;
-	struct lov_obd	   *ld_lov;
+	struct cl_device	ld_cl;
+	struct lov_obd	       *ld_lov;
 	/** size of lov_device::ld_target[] array */
-	u32		     ld_target_nr;
-	struct lovsub_device    **ld_target;
-	u32		     ld_flags;
+	u32			ld_target_nr;
+	struct lovsub_device  **ld_target;
+	u32			ld_flags;
 };
 
 /**
@@ -180,7 +180,7 @@ struct lov_layout_raid0 {
  * function corresponding to the current layout type.
  */
 struct lov_object {
-	struct cl_object       lo_cl;
+	struct cl_object	lo_cl;
 	/**
 	 * Serializes object operations with transitions between layout types.
 	 *
@@ -203,15 +203,15 @@ struct lov_object {
 	 * How many IOs are on going on this object. Layout can be changed
 	 * only if there is no active IO.
 	 */
-	atomic_t	       lo_active_ios;
+	atomic_t		lo_active_ios;
 	/**
 	 * Waitq - wait for no one else is using lo_lsm
 	 */
-	wait_queue_head_t	       lo_waitq;
+	wait_queue_head_t	lo_waitq;
 	/**
 	 * Layout metadata. NULL if empty layout.
 	 */
-	struct lov_stripe_md  *lo_lsm;
+	struct lov_stripe_md	*lo_lsm;
 
 	union lov_layout_state {
 		struct lov_layout_state_empty {
@@ -259,9 +259,9 @@ struct lov_lock_sub {
  * lov-specific lock state.
  */
 struct lov_lock {
-	struct cl_lock_slice   lls_cl;
+	struct cl_lock_slice	lls_cl;
 	/** Number of sub-locks in this lock */
-	int		    lls_nr;
+	int			lls_nr;
 	/** sublock array */
 	struct lov_lock_sub     lls_sub[0];
 };
@@ -277,43 +277,43 @@ struct lov_page {
  */
 
 struct lovsub_device {
-	struct cl_device   acid_cl;
-	struct cl_device  *acid_next;
+	struct cl_device	acid_cl;
+	struct cl_device       *acid_next;
 };
 
 struct lovsub_object {
 	struct cl_object_header lso_header;
 	struct cl_object	lso_cl;
 	struct lov_object      *lso_super;
-	int		     lso_index;
+	int			lso_index;
 };
 
 /**
  * Lock state at lovsub layer.
  */
 struct lovsub_lock {
-	struct cl_lock_slice  lss_cl;
+	struct cl_lock_slice	lss_cl;
 };
 
 /**
  * Describe the environment settings for sublocks.
  */
 struct lov_sublock_env {
-	const struct lu_env *lse_env;
-	struct cl_io	*lse_io;
+	const struct lu_env	*lse_env;
+	struct cl_io		*lse_io;
 };
 
 struct lovsub_page {
-	struct cl_page_slice lsb_cl;
+	struct cl_page_slice	lsb_cl;
 };
 
 struct lov_thread_info {
 	struct cl_object_conf   lti_stripe_conf;
-	struct lu_fid	   lti_fid;
-	struct ost_lvb	  lti_lvb;
+	struct lu_fid		lti_fid;
+	struct ost_lvb		lti_lvb;
 	struct cl_2queue	lti_cl2q;
 	struct cl_page_list     lti_plist;
-	wait_queue_entry_t	  lti_waiter;
+	wait_queue_entry_t	lti_waiter;
 };
 
 /**
@@ -354,12 +354,12 @@ struct lov_io_sub {
  */
 struct lov_io {
 	/** super-class */
-	struct cl_io_slice lis_cl;
+	struct cl_io_slice	lis_cl;
 	/**
 	 * Pointer to the object slice. This is a duplicate of
 	 * lov_io::lis_cl::cis_object.
 	 */
-	struct lov_object *lis_object;
+	struct lov_object	*lis_object;
 	/**
 	 * Original end-of-io position for this IO, set by the upper layer as
 	 * cl_io::u::ci_rw::pos + cl_io::u::ci_rw::count. lov remembers this,
@@ -401,8 +401,8 @@ struct lov_io {
 };
 
 struct lov_session {
-	struct lov_io	  ls_io;
-	struct lov_sublock_env ls_subenv;
+	struct lov_io		ls_io;
+	struct lov_sublock_env	ls_subenv;
 };
 
 extern struct lu_device_type lov_device_type;
diff --git a/drivers/staging/lustre/lustre/lov/lov_dev.c b/drivers/staging/lustre/lustre/lov/lov_dev.c
index 67d30fb..a55b3f9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lov_dev.c
@@ -113,9 +113,9 @@ static void lov_key_fini(const struct lu_context *ctx,
 }
 
 struct lu_context_key lov_key = {
-	.lct_tags = LCT_CL_THREAD,
-	.lct_init = lov_key_init,
-	.lct_fini = lov_key_fini
+	.lct_tags	= LCT_CL_THREAD,
+	.lct_init	= lov_key_init,
+	.lct_fini	= lov_key_fini
 };
 
 static void *lov_session_key_init(const struct lu_context *ctx,
@@ -138,9 +138,9 @@ static void lov_session_key_fini(const struct lu_context *ctx,
 }
 
 struct lu_context_key lov_session_key = {
-	.lct_tags = LCT_SESSION,
-	.lct_init = lov_session_key_init,
-	.lct_fini = lov_session_key_fini
+	.lct_tags	= LCT_SESSION,
+	.lct_init	= lov_session_key_init,
+	.lct_fini	= lov_session_key_fini
 };
 
 /* type constructor/destructor: lov_type_{init,fini,start,stop}() */
@@ -181,8 +181,8 @@ static int lov_device_init(const struct lu_env *env, struct lu_device *d,
 
 	lov_foreach_target(ld, i) {
 		struct lovsub_device *lsd;
-		struct cl_device     *cl;
-		struct lov_tgt_desc  *desc;
+		struct cl_device *cl;
+		struct lov_tgt_desc *desc;
 
 		desc = ld->ld_lov->lov_tgts[i];
 		if (!desc)
@@ -230,7 +230,7 @@ static void lov_cl_del_target(const struct lu_env *env, struct lu_device *dev,
 
 static int lov_expand_targets(const struct lu_env *env, struct lov_device *dev)
 {
-	int   result;
+	int result;
 	u32 tgt_size;
 	u32 sub_size;
 
@@ -238,8 +238,8 @@ static int lov_expand_targets(const struct lu_env *env, struct lov_device *dev)
 	tgt_size = dev->ld_lov->lov_tgt_size;
 	sub_size = dev->ld_target_nr;
 	if (sub_size < tgt_size) {
-		struct lovsub_device    **newd;
-		const size_t	      sz   = sizeof(newd[0]);
+		struct lovsub_device **newd;
+		const size_t sz = sizeof(newd[0]);
 
 		newd = kcalloc(tgt_size, sz, GFP_NOFS);
 		if (newd) {
@@ -247,7 +247,7 @@ static int lov_expand_targets(const struct lu_env *env, struct lov_device *dev)
 				memcpy(newd, dev->ld_target, sub_size * sz);
 				kfree(dev->ld_target);
 			}
-			dev->ld_target    = newd;
+			dev->ld_target = newd;
 			dev->ld_target_nr = tgt_size;
 		} else {
 			result = -ENOMEM;
@@ -259,11 +259,11 @@ static int lov_expand_targets(const struct lu_env *env, struct lov_device *dev)
 static int lov_cl_add_target(const struct lu_env *env, struct lu_device *dev,
 			     u32 index)
 {
-	struct obd_device    *obd = dev->ld_obd;
-	struct lov_device    *ld  = lu2lov_dev(dev);
-	struct lov_tgt_desc  *tgt;
+	struct obd_device *obd = dev->ld_obd;
+	struct lov_device *ld  = lu2lov_dev(dev);
+	struct lov_tgt_desc *tgt;
 	struct lovsub_device *lsd;
-	struct cl_device     *cl;
+	struct cl_device *cl;
 	int rc;
 
 	lov_tgts_getref(obd);
@@ -330,8 +330,8 @@ static int lov_process_config(const struct lu_env *env,
 }
 
 static const struct lu_device_operations lov_lu_ops = {
-	.ldo_object_alloc      = lov_object_alloc,
-	.ldo_process_config    = lov_process_config,
+	.ldo_object_alloc	= lov_object_alloc,
+	.ldo_process_config	= lov_process_config,
 };
 
 static struct lu_device *lov_device_alloc(const struct lu_env *env,
@@ -349,7 +349,7 @@ static struct lu_device *lov_device_alloc(const struct lu_env *env,
 
 	cl_device_init(&ld->ld_cl, t);
 	d = lov2lu_dev(ld);
-	d->ld_ops	= &lov_lu_ops;
+	d->ld_ops = &lov_lu_ops;
 
 	/* setup the LOV OBD */
 	obd = class_name2obd(lustre_cfg_string(cfg, 0));
@@ -365,24 +365,24 @@ static struct lu_device *lov_device_alloc(const struct lu_env *env,
 }
 
 static const struct lu_device_type_operations lov_device_type_ops = {
-	.ldto_init = lov_type_init,
-	.ldto_fini = lov_type_fini,
+	.ldto_init		= lov_type_init,
+	.ldto_fini		= lov_type_fini,
 
-	.ldto_start = lov_type_start,
-	.ldto_stop  = lov_type_stop,
+	.ldto_start		= lov_type_start,
+	.ldto_stop		= lov_type_stop,
 
-	.ldto_device_alloc = lov_device_alloc,
-	.ldto_device_free  = lov_device_free,
+	.ldto_device_alloc	= lov_device_alloc,
+	.ldto_device_free	= lov_device_free,
 
-	.ldto_device_init    = lov_device_init,
-	.ldto_device_fini    = lov_device_fini
+	.ldto_device_init	= lov_device_init,
+	.ldto_device_fini	= lov_device_fini
 };
 
 struct lu_device_type lov_device_type = {
-	.ldt_tags     = LU_DEVICE_CL,
-	.ldt_name     = LUSTRE_LOV_NAME,
-	.ldt_ops      = &lov_device_type_ops,
-	.ldt_ctx_tags = LCT_CL_THREAD
+	.ldt_tags		= LU_DEVICE_CL,
+	.ldt_name		= LUSTRE_LOV_NAME,
+	.ldt_ops		= &lov_device_type_ops,
+	.ldt_ctx_tags		= LCT_CL_THREAD
 };
 
 /** @} lov */
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 9708f1b..f69f2d6 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -169,29 +169,29 @@ struct lsm_operations {
  * already a 32-bit value the compiler handles this directly.
  */
 #if BITS_PER_LONG == 64
-# define lov_do_div64(n, base) ({					\
-	u64 __base = (base);					\
-	u64 __rem;							\
-	__rem = ((u64)(n)) % __base;				\
-	(n) = ((u64)(n)) / __base;					\
-	__rem;								\
+# define lov_do_div64(n, base) ({		\
+	u64 __base = (base);			\
+	u64 __rem;				\
+	__rem = ((u64)(n)) % __base;		\
+	(n) = ((u64)(n)) / __base;		\
+	__rem;					\
 })
 #elif BITS_PER_LONG == 32
-# define lov_do_div64(n, base) ({					\
-	u64 __rem;							\
+# define lov_do_div64(n, base) ({					      \
+	u64 __rem;							      \
 	if ((sizeof(base) > 4) && (((base) & 0xffffffff00000000ULL) != 0)) {  \
 		int __remainder;					      \
 		LASSERTF(!((base) & (LOV_MIN_STRIPE_SIZE - 1)), "64 bit lov " \
-			 "division %llu / %llu\n", (n), (u64)(base));    \
-		__remainder = (n) & (LOV_MIN_STRIPE_SIZE - 1);		\
-		(n) >>= LOV_MIN_STRIPE_BITS;				\
-		__rem = do_div(n, (base) >> LOV_MIN_STRIPE_BITS);	\
-		__rem <<= LOV_MIN_STRIPE_BITS;				\
-		__rem += __remainder;					\
-	} else {							\
-		__rem = do_div(n, base);				\
-	}								\
-	__rem;								\
+			 "division %llu / %llu\n", (n), (u64)(base));	      \
+		__remainder = (n) & (LOV_MIN_STRIPE_SIZE - 1);		      \
+		(n) >>= LOV_MIN_STRIPE_BITS;				      \
+		__rem = do_div(n, (base) >> LOV_MIN_STRIPE_BITS);	      \
+		__rem <<= LOV_MIN_STRIPE_BITS;				      \
+		__rem += __remainder;					      \
+	} else {							      \
+		__rem = do_div(n, base);				      \
+	}								      \
+	__rem;								      \
 })
 #endif
 
@@ -215,21 +215,21 @@ struct pool_desc {
 void lov_pool_hash_destroy(struct rhashtable *tbl);
 
 struct lov_request {
-	struct obd_info	  rq_oi;
-	struct lov_request_set  *rq_rqset;
+	struct obd_info		rq_oi;
+	struct lov_request_set *rq_rqset;
 
-	struct list_head	       rq_link;
+	struct list_head	rq_link;
 
-	int		      rq_idx;	/* index in lov->tgts array */
+	int			rq_idx;	/* index in lov->tgts array */
 };
 
 struct lov_request_set {
-	struct obd_info			*set_oi;
-	struct obd_device		*set_obd;
-	int				set_count;
-	atomic_t			set_completes;
-	atomic_t			set_success;
-	struct list_head			set_list;
+	struct obd_info		*set_oi;
+	struct obd_device	*set_obd;
+	int			set_count;
+	atomic_t		set_completes;
+	atomic_t		set_success;
+	struct list_head	set_list;
 };
 
 extern struct kmem_cache *lov_oinfo_slab;
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 47bb618..de43f47 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -91,9 +91,9 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 			   struct lov_io_sub *sub)
 {
 	struct lov_object *lov = lio->lis_object;
-	struct cl_io      *sub_io;
-	struct cl_object  *sub_obj;
-	struct cl_io      *io  = lio->lis_cl.cis_io;
+	struct cl_io *sub_io;
+	struct cl_object *sub_obj;
+	struct cl_io *io = lio->lis_cl.cis_io;
 	int index = lov_comp_entry(sub->sub_subio_index);
 	int stripe = lov_comp_stripe(sub->sub_subio_index);
 	int rc = 0;
@@ -377,11 +377,11 @@ static u64 lov_offset_mod(u64 val, int delta)
 static int lov_io_iter_init(const struct lu_env *env,
 			    const struct cl_io_slice *ios)
 {
-	struct lov_io	*lio = cl2lov_io(env, ios);
+	struct lov_io *lio = cl2lov_io(env, ios);
 	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
 	struct cl_io *io = ios->cis_io;
 	struct lov_layout_entry *le;
-	struct lov_io_sub    *sub;
+	struct lov_io_sub *sub;
 	struct lu_extent ext;
 	int rc = 0;
 	int index;
@@ -461,9 +461,9 @@ static int lov_io_iter_init(const struct lu_env *env,
 static int lov_io_rw_iter_init(const struct lu_env *env,
 			       const struct cl_io_slice *ios)
 {
-	struct lov_io	*lio = cl2lov_io(env, ios);
+	struct lov_io *lio = cl2lov_io(env, ios);
 	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
-	struct cl_io	 *io  = ios->cis_io;
+	struct cl_io *io = ios->cis_io;
 	u64 start = io->u.ci_rw.crw_pos;
 	struct lov_stripe_md_entry *lse;
 	int index;
@@ -872,8 +872,8 @@ static int lov_io_fault_start(const struct lu_env *env,
 			      const struct cl_io_slice *ios)
 {
 	struct cl_fault_io *fio;
-	struct lov_io      *lio;
-	struct lov_io_sub  *sub;
+	struct lov_io *lio;
+	struct lov_io_sub *sub;
 
 	fio = &ios->cis_io->u.ci_fault;
 	lio = cl2lov_io(env, ios);
@@ -906,31 +906,31 @@ static void lov_io_fsync_end(const struct lu_env *env,
 static const struct cl_io_operations lov_io_ops = {
 	.op = {
 		[CIT_READ] = {
-			.cio_fini      = lov_io_fini,
-			.cio_iter_init = lov_io_rw_iter_init,
-			.cio_iter_fini = lov_io_iter_fini,
-			.cio_lock      = lov_io_lock,
-			.cio_unlock    = lov_io_unlock,
-			.cio_start     = lov_io_start,
-			.cio_end       = lov_io_end
+			.cio_fini	= lov_io_fini,
+			.cio_iter_init	= lov_io_rw_iter_init,
+			.cio_iter_fini	= lov_io_iter_fini,
+			.cio_lock	= lov_io_lock,
+			.cio_unlock	= lov_io_unlock,
+			.cio_start	= lov_io_start,
+			.cio_end	= lov_io_end
 		},
 		[CIT_WRITE] = {
-			.cio_fini      = lov_io_fini,
-			.cio_iter_init = lov_io_rw_iter_init,
-			.cio_iter_fini = lov_io_iter_fini,
-			.cio_lock      = lov_io_lock,
-			.cio_unlock    = lov_io_unlock,
-			.cio_start     = lov_io_start,
-			.cio_end       = lov_io_end
+			.cio_fini	= lov_io_fini,
+			.cio_iter_init	= lov_io_rw_iter_init,
+			.cio_iter_fini	= lov_io_iter_fini,
+			.cio_lock	= lov_io_lock,
+			.cio_unlock	= lov_io_unlock,
+			.cio_start	= lov_io_start,
+			.cio_end	= lov_io_end
 		},
 		[CIT_SETATTR] = {
-			.cio_fini      = lov_io_fini,
-			.cio_iter_init = lov_io_setattr_iter_init,
-			.cio_iter_fini = lov_io_iter_fini,
-			.cio_lock      = lov_io_lock,
-			.cio_unlock    = lov_io_unlock,
-			.cio_start     = lov_io_start,
-			.cio_end       = lov_io_end
+			.cio_fini	= lov_io_fini,
+			.cio_iter_init	= lov_io_setattr_iter_init,
+			.cio_iter_fini	= lov_io_iter_fini,
+			.cio_lock	= lov_io_lock,
+			.cio_unlock	= lov_io_unlock,
+			.cio_start	= lov_io_start,
+			.cio_end	= lov_io_end
 		},
 		[CIT_DATA_VERSION] = {
 			.cio_fini	= lov_io_fini,
@@ -942,22 +942,22 @@ static void lov_io_fsync_end(const struct lu_env *env,
 			.cio_end	= lov_io_data_version_end,
 		},
 		[CIT_FAULT] = {
-			.cio_fini      = lov_io_fini,
-			.cio_iter_init = lov_io_iter_init,
-			.cio_iter_fini = lov_io_iter_fini,
-			.cio_lock      = lov_io_lock,
-			.cio_unlock    = lov_io_unlock,
-			.cio_start     = lov_io_fault_start,
-			.cio_end       = lov_io_end
+			.cio_fini	= lov_io_fini,
+			.cio_iter_init	= lov_io_iter_init,
+			.cio_iter_fini	= lov_io_iter_fini,
+			.cio_lock	= lov_io_lock,
+			.cio_unlock	= lov_io_unlock,
+			.cio_start	= lov_io_fault_start,
+			.cio_end	= lov_io_end
 		},
 		[CIT_FSYNC] = {
-			.cio_fini      = lov_io_fini,
-			.cio_iter_init = lov_io_iter_init,
-			.cio_iter_fini = lov_io_iter_fini,
-			.cio_lock      = lov_io_lock,
-			.cio_unlock    = lov_io_unlock,
-			.cio_start     = lov_io_start,
-			.cio_end       = lov_io_fsync_end
+			.cio_fini	= lov_io_fini,
+			.cio_iter_init	= lov_io_iter_init,
+			.cio_iter_fini	= lov_io_iter_fini,
+			.cio_lock	= lov_io_lock,
+			.cio_unlock	= lov_io_unlock,
+			.cio_start	= lov_io_start,
+			.cio_end	= lov_io_fsync_end
 		},
 		[CIT_LADVISE] = {
 			.cio_fini	= lov_io_fini,
@@ -969,12 +969,12 @@ static void lov_io_fsync_end(const struct lu_env *env,
 			.cio_end	= lov_io_end
 		},
 		[CIT_MISC] = {
-			.cio_fini   = lov_io_fini
+			.cio_fini	= lov_io_fini
 		}
 	},
 	.cio_read_ahead			= lov_io_read_ahead,
-	.cio_submit                    = lov_io_submit,
-	.cio_commit_async              = lov_io_commit_async,
+	.cio_submit			= lov_io_submit,
+	.cio_commit_async		= lov_io_commit_async,
 };
 
 /*****************************************************************************
@@ -1013,48 +1013,48 @@ static void lov_empty_impossible(const struct lu_env *env,
 static const struct cl_io_operations lov_empty_io_ops = {
 	.op = {
 		[CIT_READ] = {
-			.cio_fini       = lov_empty_io_fini,
+			.cio_fini	= lov_empty_io_fini,
 		},
 		[CIT_WRITE] = {
-			.cio_fini      = lov_empty_io_fini,
-			.cio_iter_init = LOV_EMPTY_IMPOSSIBLE,
-			.cio_lock      = LOV_EMPTY_IMPOSSIBLE,
-			.cio_start     = LOV_EMPTY_IMPOSSIBLE,
-			.cio_end       = LOV_EMPTY_IMPOSSIBLE
+			.cio_fini	= lov_empty_io_fini,
+			.cio_iter_init	= LOV_EMPTY_IMPOSSIBLE,
+			.cio_lock	= LOV_EMPTY_IMPOSSIBLE,
+			.cio_start	= LOV_EMPTY_IMPOSSIBLE,
+			.cio_end	= LOV_EMPTY_IMPOSSIBLE
 		},
 		[CIT_SETATTR] = {
-			.cio_fini      = lov_empty_io_fini,
-			.cio_iter_init = LOV_EMPTY_IMPOSSIBLE,
-			.cio_lock      = LOV_EMPTY_IMPOSSIBLE,
-			.cio_start     = LOV_EMPTY_IMPOSSIBLE,
-			.cio_end       = LOV_EMPTY_IMPOSSIBLE
+			.cio_fini	= lov_empty_io_fini,
+			.cio_iter_init	= LOV_EMPTY_IMPOSSIBLE,
+			.cio_lock	= LOV_EMPTY_IMPOSSIBLE,
+			.cio_start	= LOV_EMPTY_IMPOSSIBLE,
+			.cio_end	= LOV_EMPTY_IMPOSSIBLE
 		},
 		[CIT_FAULT] = {
-			.cio_fini      = lov_empty_io_fini,
-			.cio_iter_init = LOV_EMPTY_IMPOSSIBLE,
-			.cio_lock      = LOV_EMPTY_IMPOSSIBLE,
-			.cio_start     = LOV_EMPTY_IMPOSSIBLE,
-			.cio_end       = LOV_EMPTY_IMPOSSIBLE
+			.cio_fini	= lov_empty_io_fini,
+			.cio_iter_init	= LOV_EMPTY_IMPOSSIBLE,
+			.cio_lock	= LOV_EMPTY_IMPOSSIBLE,
+			.cio_start	= LOV_EMPTY_IMPOSSIBLE,
+			.cio_end	= LOV_EMPTY_IMPOSSIBLE
 		},
 		[CIT_FSYNC] = {
-			.cio_fini   = lov_empty_io_fini
+			.cio_fini	= lov_empty_io_fini
 		},
 		[CIT_LADVISE] = {
 			.cio_fini	= lov_empty_io_fini
 		},
 		[CIT_MISC] = {
-			.cio_fini   = lov_empty_io_fini
+			.cio_fini	= lov_empty_io_fini
 		}
 	},
 	.cio_submit			= lov_empty_io_submit,
-	.cio_commit_async              = LOV_EMPTY_IMPOSSIBLE
+	.cio_commit_async		= LOV_EMPTY_IMPOSSIBLE
 };
 
 int lov_io_init_composite(const struct lu_env *env, struct cl_object *obj,
 			  struct cl_io *io)
 {
-	struct lov_io       *lio = lov_env_io(env);
-	struct lov_object   *lov = cl2lov(obj);
+	struct lov_io *lio = lov_env_io(env);
+	struct lov_object *lov = cl2lov(obj);
 
 	INIT_LIST_HEAD(&lio->lis_active);
 	io->ci_result = lov_io_slice_init(lio, lov, io);
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index 9a46424..039c902 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -54,9 +54,9 @@ static struct lov_sublock_env *lov_sublock_env_get(const struct lu_env *env,
 						   struct lov_lock_sub *lls)
 {
 	struct lov_sublock_env *subenv;
-	struct lov_io	  *lio    = lov_env_io(env);
-	struct cl_io	   *io     = lio->lis_cl.cis_io;
-	struct lov_io_sub      *sub;
+	struct lov_io *lio = lov_env_io(env);
+	struct cl_io *io = lio->lis_cl.cis_io;
+	struct lov_io_sub *sub;
 
 	subenv = &lov_env_session(env)->ls_subenv;
 
@@ -71,7 +71,7 @@ static struct lov_sublock_env *lov_sublock_env_get(const struct lu_env *env,
 	 */
 	if (!io || !cl_object_same(io->ci_obj, parent->cll_descr.cld_obj)) {
 		subenv->lse_env = env;
-		subenv->lse_io  = io;
+		subenv->lse_io = io;
 	} else {
 		sub = lov_sub_get(env, lio, lls->sub_index);
 		if (!IS_ERR(sub)) {
@@ -154,7 +154,7 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 	 */
 
 	lovlck = kvzalloc(offsetof(struct lov_lock, lls_sub[nr]),
-				 GFP_NOFS);
+			  GFP_NOFS);
 	if (!lovlck)
 		return ERR_PTR(-ENOMEM);
 
@@ -178,11 +178,11 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 				continue;
 
 			LASSERT(!descr->cld_obj);
-			descr->cld_obj   = lovsub2cl(r0->lo_sub[i]);
+			descr->cld_obj = lovsub2cl(r0->lo_sub[i]);
 			descr->cld_start = cl_index(descr->cld_obj, start);
-			descr->cld_end   = cl_index(descr->cld_obj, end);
-			descr->cld_mode  = lock->cll_descr.cld_mode;
-			descr->cld_gid   = lock->cll_descr.cld_gid;
+			descr->cld_end = cl_index(descr->cld_obj, end);
+			descr->cld_mode = lock->cll_descr.cld_mode;
+			descr->cld_gid = lock->cll_descr.cld_gid;
 			descr->cld_enq_flags = lock->cll_descr.cld_enq_flags;
 
 			lls->sub_index = lov_comp_index(index, i);
@@ -244,7 +244,7 @@ static int lov_lock_enqueue(const struct lu_env *env,
 	int rc = 0;
 
 	for (i = 0; i < lovlck->lls_nr; ++i) {
-		struct lov_lock_sub  *lls = &lovlck->lls_sub[i];
+		struct lov_lock_sub *lls = &lovlck->lls_sub[i];
 		struct lov_sublock_env *subenv;
 
 		subenv = lov_sublock_env_get(env, lock, lls);
@@ -293,7 +293,7 @@ static int lov_lock_print(const struct lu_env *env, void *cookie,
 			  lu_printer_t p, const struct cl_lock_slice *slice)
 {
 	struct lov_lock *lck = cl2lov_lock(slice);
-	int	      i;
+	int i;
 
 	(*p)(env, cookie, "%d\n", lck->lls_nr);
 	for (i = 0; i < lck->lls_nr; ++i) {
@@ -307,10 +307,10 @@ static int lov_lock_print(const struct lu_env *env, void *cookie,
 }
 
 static const struct cl_lock_operations lov_lock_ops = {
-	.clo_fini      = lov_lock_fini,
-	.clo_enqueue   = lov_lock_enqueue,
-	.clo_cancel    = lov_lock_cancel,
-	.clo_print     = lov_lock_print
+	.clo_fini	= lov_lock_fini,
+	.clo_enqueue	= lov_lock_enqueue,
+	.clo_cancel	= lov_lock_cancel,
+	.clo_print	= lov_lock_print
 };
 
 int lov_lock_init_composite(const struct lu_env *env, struct cl_object *obj,
@@ -345,8 +345,8 @@ static int lov_empty_lock_print(const struct lu_env *env, void *cookie,
 
 /* XXX: more methods will be added later. */
 static const struct cl_lock_operations lov_empty_lock_ops = {
-	.clo_fini  = lov_empty_lock_fini,
-	.clo_print = lov_empty_lock_print
+	.clo_fini	= lov_empty_lock_fini,
+	.clo_print	= lov_empty_lock_print
 };
 
 int lov_lock_init_empty(const struct lu_env *env, struct cl_object *obj,
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 109dd69..04d0a9e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -425,7 +425,7 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 		CERROR("Unknown event(%d) for uuid %s", ev, uuid->uuid);
 	}
 
- out:
+out:
 	lov_tgts_putref(obd);
 	return index;
 }
@@ -925,7 +925,7 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
 static int lov_statfs_async(struct obd_export *exp, struct obd_info *oinfo,
 			    u64 max_age, struct ptlrpc_request_set *rqset)
 {
-	struct obd_device      *obd = class_exp2obd(exp);
+	struct obd_device *obd = class_exp2obd(exp);
 	struct lov_request_set *set;
 	struct lov_request *req;
 	struct lov_obd *lov;
@@ -997,7 +997,7 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	case IOC_OBD_STATFS: {
 		struct obd_ioctl_data *data = karg;
 		struct obd_device *osc_obd;
-		struct obd_statfs stat_buf = {0};
+		struct obd_statfs stat_buf = { 0 };
 		u32 index;
 		u32 flags;
 
@@ -1281,11 +1281,11 @@ void lov_stripe_unlock(struct lov_stripe_md *md)
 static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 			struct obd_quotactl *oqctl)
 {
-	struct lov_obd      *lov = &obd->u.lov;
+	struct lov_obd *lov = &obd->u.lov;
 	struct lov_tgt_desc *tgt;
-	u64		curspace = 0;
-	u64		bhardlimit = 0;
-	int		  i, rc = 0;
+	u64 curspace = 0;
+	u64 bhardlimit = 0;
+	int i, rc = 0;
 
 	if (oqctl->qc_cmd != Q_GETOQUOTA &&
 	    oqctl->qc_cmd != LUSTRE_Q_SETQUOTA) {
@@ -1336,10 +1336,9 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 }
 
 static struct obd_ops lov_obd_ops = {
-	.owner          = THIS_MODULE,
-	.setup          = lov_setup,
-	.cleanup        = lov_cleanup,
-	/*.process_config       = lov_process_config,*/
+	.owner		= THIS_MODULE,
+	.setup		= lov_setup,
+	.cleanup	= lov_cleanup,
 	.connect        = lov_connect,
 	.disconnect     = lov_disconnect,
 	.statfs         = lov_statfs,
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 72f42fc..397ecc1 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -133,7 +133,7 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 		return -EIO;
 	}
 
-	hdr    = cl_object_header(lov2cl(lov));
+	hdr = cl_object_header(lov2cl(lov));
 	subhdr = cl_object_header(subobj);
 
 	CDEBUG(D_INODE,
@@ -155,7 +155,7 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 		r0->lo_sub[stripe]->lso_index = idx;
 		result = 0;
 	} else {
-		struct lu_object  *old_obj;
+		struct lu_object *old_obj;
 		struct lov_object *old_lov;
 		unsigned int mask = D_INODE;
 
@@ -392,16 +392,16 @@ static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
 			       struct lov_layout_raid0 *r0,
 			       struct lovsub_object *los, int idx)
 {
-	struct cl_object	*sub;
-	struct lu_site	  *site;
+	struct cl_object *sub;
+	struct lu_site *site;
 	wait_queue_head_t *wq;
-	wait_queue_entry_t	  *waiter;
+	wait_queue_entry_t *waiter;
 
 	LASSERT(r0->lo_sub[idx] == los);
 
-	sub  = lovsub2cl(los);
+	sub = lovsub2cl(los);
 	site = sub->co_lu.lo_dev->ld_site;
-	wq   = lu_site_wq_from_fid(site, &sub->co_lu.lo_header->loh_fid);
+	wq = lu_site_wq_from_fid(site, &sub->co_lu.lo_header->loh_fid);
 
 	cl_object_kill(env, sub);
 	/* release a reference to the sub-object and ... */
@@ -570,8 +570,8 @@ static int lov_print_composite(const struct lu_env *env, void *cookie,
 static int lov_print_released(const struct lu_env *env, void *cookie,
 			      lu_printer_t p, const struct lu_object *o)
 {
-	struct lov_object	*lov = lu2lov(o);
-	struct lov_stripe_md	*lsm = lov->lo_lsm;
+	struct lov_object *lov = lu2lov(o);
+	struct lov_stripe_md *lsm = lov->lo_lsm;
 
 	(*p)(env, cookie,
 	     "released: %s, lsm{%p 0x%08X %d %u}:\n",
@@ -684,24 +684,24 @@ static int lov_attr_get_composite(const struct lu_env *env,
 
 static const struct lov_layout_operations lov_dispatch[] = {
 	[LLT_EMPTY] = {
-		.llo_init      = lov_init_empty,
-		.llo_delete    = lov_delete_empty,
-		.llo_fini      = lov_fini_empty,
-		.llo_print     = lov_print_empty,
-		.llo_page_init = lov_page_init_empty,
-		.llo_lock_init = lov_lock_init_empty,
-		.llo_io_init   = lov_io_init_empty,
-		.llo_getattr   = lov_attr_get_empty
+		.llo_init	= lov_init_empty,
+		.llo_delete	= lov_delete_empty,
+		.llo_fini	= lov_fini_empty,
+		.llo_print	= lov_print_empty,
+		.llo_page_init	= lov_page_init_empty,
+		.llo_lock_init	= lov_lock_init_empty,
+		.llo_io_init	= lov_io_init_empty,
+		.llo_getattr	= lov_attr_get_empty
 	},
 	[LLT_RELEASED] = {
-		.llo_init      = lov_init_released,
-		.llo_delete    = lov_delete_empty,
-		.llo_fini      = lov_fini_released,
-		.llo_print     = lov_print_released,
-		.llo_page_init = lov_page_init_empty,
-		.llo_lock_init = lov_lock_init_empty,
-		.llo_io_init   = lov_io_init_released,
-		.llo_getattr   = lov_attr_get_empty
+		.llo_init	= lov_init_released,
+		.llo_delete	= lov_delete_empty,
+		.llo_fini	= lov_fini_released,
+		.llo_print	= lov_print_released,
+		.llo_page_init	= lov_page_init_empty,
+		.llo_lock_init	= lov_lock_init_empty,
+		.llo_io_init	= lov_io_init_released,
+		.llo_getattr	= lov_attr_get_empty
 	},
 	[LLT_COMP] = {
 		.llo_init	= lov_init_composite,
@@ -718,14 +718,14 @@ static int lov_attr_get_composite(const struct lu_env *env,
 /**
  * Performs a double-dispatch based on the layout type of an object.
  */
-#define LOV_2DISPATCH_NOLOCK(obj, op, ...)			      \
-({								      \
-	struct lov_object		      *__obj = (obj);	  \
-	enum lov_layout_type		    __llt;		  \
-									\
-	__llt = __obj->lo_type;					 \
+#define LOV_2DISPATCH_NOLOCK(obj, op, ...)			\
+({								\
+	struct lov_object		      *__obj = (obj);	\
+	enum lov_layout_type		    __llt;		\
+								\
+	__llt = __obj->lo_type;					\
 	LASSERT(__llt < ARRAY_SIZE(lov_dispatch));		\
-	lov_dispatch[__llt].op(__VA_ARGS__);			    \
+	lov_dispatch[__llt].op(__VA_ARGS__);			\
 })
 
 /**
@@ -763,18 +763,18 @@ static inline void lov_conf_thaw(struct lov_object *lov)
 		up_read(&lov->lo_type_guard);
 }
 
-#define LOV_2DISPATCH_MAYLOCK(obj, op, lock, ...)		       \
-({								      \
-	struct lov_object		      *__obj = (obj);	  \
-	int				     __lock = !!(lock);      \
-	typeof(lov_dispatch[0].op(__VA_ARGS__)) __result;	       \
-									\
-	if (__lock)						     \
-		lov_conf_freeze(__obj);					\
-	__result = LOV_2DISPATCH_NOLOCK(obj, op, __VA_ARGS__);	  \
-	if (__lock)						     \
-		lov_conf_thaw(__obj);					\
-	__result;						       \
+#define LOV_2DISPATCH_MAYLOCK(obj, op, lock, ...)		\
+({								\
+	struct lov_object *__obj = (obj);			\
+	int __lock = !!(lock);					\
+	typeof(lov_dispatch[0].op(__VA_ARGS__)) __result;	\
+								\
+	if (__lock)						\
+		lov_conf_freeze(__obj);				\
+	__result = LOV_2DISPATCH_NOLOCK(obj, op, __VA_ARGS__);	\
+	if (__lock)						\
+		lov_conf_thaw(__obj);				\
+	__result;						\
 })
 
 /**
@@ -783,16 +783,16 @@ static inline void lov_conf_thaw(struct lov_object *lov)
 #define LOV_2DISPATCH(obj, op, ...)		     \
 	LOV_2DISPATCH_MAYLOCK(obj, op, 1, __VA_ARGS__)
 
-#define LOV_2DISPATCH_VOID(obj, op, ...)				\
-do {								    \
-	struct lov_object		      *__obj = (obj);	  \
-	enum lov_layout_type		    __llt;		  \
-									\
-	lov_conf_freeze(__obj);						\
-	__llt = __obj->lo_type;					 \
-	LASSERT(__llt < ARRAY_SIZE(lov_dispatch));	\
-	lov_dispatch[__llt].op(__VA_ARGS__);			    \
-	lov_conf_thaw(__obj);						\
+#define LOV_2DISPATCH_VOID(obj, op, ...)			\
+do {								\
+	struct lov_object *__obj = (obj);			\
+	enum lov_layout_type __llt;				\
+								\
+	lov_conf_freeze(__obj);					\
+	__llt = __obj->lo_type;					\
+	LASSERT(__llt < ARRAY_SIZE(lov_dispatch));		\
+	lov_dispatch[__llt].op(__VA_ARGS__);			\
+	lov_conf_thaw(__obj);					\
 } while (0)
 
 static void lov_conf_lock(struct lov_object *lov)
@@ -901,10 +901,10 @@ static int lov_layout_change(const struct lu_env *unused,
 int lov_object_init(const struct lu_env *env, struct lu_object *obj,
 		    const struct lu_object_conf *conf)
 {
-	struct lov_object	    *lov   = lu2lov(obj);
+	struct lov_object *lov = lu2lov(obj);
 	struct lov_device *dev = lov_object_dev(lov);
-	const struct cl_object_conf  *cconf = lu2cl_conf(conf);
-	union  lov_layout_state      *set   = &lov->u;
+	const struct cl_object_conf *cconf = lu2cl_conf(conf);
+	union  lov_layout_state *set = &lov->u;
 	const struct lov_layout_operations *ops;
 	struct lov_stripe_md *lsm = NULL;
 	int rc;
@@ -938,9 +938,9 @@ int lov_object_init(const struct lu_env *env, struct lu_object *obj,
 static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 			const struct cl_object_conf *conf)
 {
-	struct lov_stripe_md	*lsm = NULL;
-	struct lov_object	*lov = cl2lov(obj);
-	int			 result = 0;
+	struct lov_stripe_md *lsm = NULL;
+	struct lov_object *lov = cl2lov(obj);
+	int result = 0;
 
 	if (conf->coc_opc == OBJECT_CONF_SET &&
 	    conf->u.coc_layout.lb_buf) {
@@ -1662,25 +1662,25 @@ static loff_t lov_object_maxbytes(struct cl_object *obj)
 }
 
 static const struct cl_object_operations lov_ops = {
-	.coo_page_init = lov_page_init,
-	.coo_lock_init = lov_lock_init,
-	.coo_io_init   = lov_io_init,
-	.coo_attr_get  = lov_attr_get,
-	.coo_attr_update = lov_attr_update,
-	.coo_conf_set  = lov_conf_set,
-	.coo_getstripe = lov_object_getstripe,
-	.coo_layout_get	 = lov_object_layout_get,
-	.coo_maxbytes	 = lov_object_maxbytes,
-	.coo_fiemap	 = lov_object_fiemap,
+	.coo_page_init		= lov_page_init,
+	.coo_lock_init		= lov_lock_init,
+	.coo_io_init		= lov_io_init,
+	.coo_attr_get		= lov_attr_get,
+	.coo_attr_update	= lov_attr_update,
+	.coo_conf_set		= lov_conf_set,
+	.coo_getstripe		= lov_object_getstripe,
+	.coo_layout_get		= lov_object_layout_get,
+	.coo_maxbytes		= lov_object_maxbytes,
+	.coo_fiemap		= lov_object_fiemap,
 };
 
 static const struct lu_object_operations lov_lu_obj_ops = {
-	.loo_object_init      = lov_object_init,
-	.loo_object_delete    = lov_object_delete,
-	.loo_object_release   = NULL,
-	.loo_object_free      = lov_object_free,
-	.loo_object_print     = lov_object_print,
-	.loo_object_invariant = NULL
+	.loo_object_init	= lov_object_init,
+	.loo_object_delete	= lov_object_delete,
+	.loo_object_release	= NULL,
+	.loo_object_free	= lov_object_free,
+	.loo_object_print	= lov_object_print,
+	.loo_object_invariant	= NULL
 };
 
 struct lu_object *lov_object_alloc(const struct lu_env *env,
@@ -1688,7 +1688,7 @@ struct lu_object *lov_object_alloc(const struct lu_env *env,
 				   struct lu_device *dev)
 {
 	struct lov_object *lov;
-	struct lu_object  *obj;
+	struct lu_object *obj;
 
 	lov = kmem_cache_zalloc(lov_object_kmem, GFP_NOFS);
 	if (lov) {
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index ab02c34..26f5066 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -135,7 +135,7 @@ pgoff_t lov_stripe_pgoff(struct lov_stripe_md *lsm, int index,
 int lov_stripe_offset(struct lov_stripe_md *lsm, int index, u64 lov_off,
 		      int stripeno, u64 *obdoff)
 {
-	unsigned long ssize  = lsm->lsm_entries[index]->lsme_stripe_size;
+	unsigned long ssize = lsm->lsm_entries[index]->lsme_stripe_size;
 	u64 stripe_off, this_stripe, swidth;
 	int ret = 0;
 
@@ -188,7 +188,7 @@ int lov_stripe_offset(struct lov_stripe_md *lsm, int index, u64 lov_off,
 u64 lov_size_to_stripe(struct lov_stripe_md *lsm, int index, u64 file_size,
 		       int stripeno)
 {
-	unsigned long ssize  = lsm->lsm_entries[index]->lsme_stripe_size;
+	unsigned long ssize = lsm->lsm_entries[index]->lsme_stripe_size;
 	u64 stripe_off, this_stripe, swidth;
 
 	if (file_size == OBD_OBJECT_EOF)
@@ -270,7 +270,7 @@ int lov_stripe_intersects(struct lov_stripe_md *lsm, int index, int stripeno,
 /* compute which stripe number "lov_off" will be written into */
 int lov_stripe_number(struct lov_stripe_md *lsm, int index, u64 lov_off)
 {
-	unsigned long ssize  = lsm->lsm_entries[index]->lsme_stripe_size;
+	unsigned long ssize = lsm->lsm_entries[index]->lsme_stripe_size;
 	u64 stripe_off, swidth;
 
 	swidth = stripe_width(lsm, index);
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index fde5160..18ce9f9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -52,7 +52,7 @@
 void lov_dump_lmm_common(int level, void *lmmp)
 {
 	struct lov_mds_md *lmm = lmmp;
-	struct ost_id	oi;
+	struct ost_id oi;
 
 	lmm_oi_le_to_cpu(&oi, &lmm->lmm_oi);
 	CDEBUG(level, "objid " DOSTID ", magic 0x%08x, pattern %#x\n",
@@ -76,7 +76,7 @@ static void lov_dump_lmm_objects(int level, struct lov_ost_data *lod,
 	}
 
 	for (i = 0; i < stripe_count; ++i, ++lod) {
-		struct ost_id	oi;
+		struct ost_id oi;
 
 		ostid_le_to_cpu(&lod->l_ost_oi, &oi);
 		CDEBUG(level, "stripe %u idx %u subobj " DOSTID "\n", i,
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index 90e2981..08485a9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -62,24 +62,24 @@ static int lov_comp_page_print(const struct lu_env *env,
 }
 
 static const struct cl_page_operations lov_comp_page_ops = {
-	.cpo_print  = lov_comp_page_print
+	.cpo_print	= lov_comp_page_print
 };
 
 int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
 			    struct cl_page *page, pgoff_t index)
 {
 	struct lov_object *loo = cl2lov(obj);
-	struct lov_io     *lio = lov_env_io(env);
+	struct lov_io *lio = lov_env_io(env);
 	struct lov_layout_raid0 *r0;
-	struct cl_object  *subobj;
-	struct cl_object  *o;
+	struct cl_object *subobj;
+	struct cl_object *o;
 	struct lov_io_sub *sub;
-	struct lov_page   *lpg = cl_object_page_slice(obj, page);
+	struct lov_page *lpg = cl_object_page_slice(obj, page);
 	u64 offset;
-	u64	    suboff;
-	int		stripe;
+	u64 suboff;
+	int stripe;
 	int entry;
-	int		rc;
+	int rc;
 
 	offset = cl_offset(obj, index);
 	entry = lov_lsm_entry(loo->lo_lsm, offset);
@@ -127,7 +127,7 @@ static int lov_empty_page_print(const struct lu_env *env,
 }
 
 static const struct cl_page_operations lov_empty_page_ops = {
-	.cpo_print = lov_empty_page_print
+	.cpo_print	= lov_empty_page_print
 };
 
 int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 177f5a5..833fac9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -96,9 +96,9 @@ void lov_pool_putref(struct pool_desc *pool)
  */
 #define POOL_IT_MAGIC 0xB001CEA0
 struct pool_iterator {
-	int magic;
-	struct pool_desc *pool;
-	int idx;	/* from 0 to pool_tgt_size - 1 */
+	int			magic;
+	struct pool_desc	*pool;
+	int			idx;	/* from 0 to pool_tgt_size - 1 */
 };
 
 static void *pool_proc_next(struct seq_file *s, void *v, loff_t *pos)
@@ -204,10 +204,10 @@ static int pool_proc_show(struct seq_file *s, void *v)
 }
 
 static const struct seq_operations pool_proc_ops = {
-	.start	  = pool_proc_start,
-	.next	   = pool_proc_next,
-	.stop	   = pool_proc_stop,
-	.show	   = pool_proc_show,
+	.start		= pool_proc_start,
+	.next		= pool_proc_next,
+	.stop		= pool_proc_stop,
+	.show		= pool_proc_show,
 };
 
 static int pool_proc_open(struct inode *inode, struct file *file)
@@ -224,9 +224,9 @@ static int pool_proc_open(struct inode *inode, struct file *file)
 }
 
 static const struct file_operations pool_proc_operations = {
-	.open	   = pool_proc_open,
-	.read	   = seq_read,
-	.llseek	 = seq_lseek,
+	.open		= pool_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
 	.release	= seq_release,
 };
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 45dca36..7f591ba 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -137,12 +137,12 @@ static int lov_check_and_wait_active(struct lov_obd *lov, int ost_idx)
 }
 
 #define LOV_U64_MAX ((u64)~0ULL)
-#define LOV_SUM_MAX(tot, add)					   \
-	do {							    \
-		if ((tot) + (add) < (tot))			      \
-			(tot) = LOV_U64_MAX;			    \
-		else						    \
-			(tot) += (add);				 \
+#define LOV_SUM_MAX(tot, add)			\
+	do {					\
+		if ((tot) + (add) < (tot))	\
+			(tot) = LOV_U64_MAX;	\
+		else				\
+			(tot) += (add);		\
 	} while (0)
 
 static int lov_fini_statfs(struct obd_device *obd, struct obd_statfs *osfs,
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_dev.c b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
index 7e89a2e..69380fc 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
@@ -52,7 +52,7 @@
 static int lovsub_device_init(const struct lu_env *env, struct lu_device *d,
 			      const char *name, struct lu_device *next)
 {
-	struct lovsub_device  *lsd = lu2lovsub_dev(d);
+	struct lovsub_device *lsd = lu2lovsub_dev(d);
 	struct lu_device_type *ldt;
 	int rc;
 
@@ -85,8 +85,8 @@ static struct lu_device *lovsub_device_fini(const struct lu_env *env,
 static struct lu_device *lovsub_device_free(const struct lu_env *env,
 					    struct lu_device *d)
 {
-	struct lovsub_device *lsd  = lu2lovsub_dev(d);
-	struct lu_device     *next = cl2lu_dev(lsd->acid_next);
+	struct lovsub_device *lsd = lu2lovsub_dev(d);
+	struct lu_device *next = cl2lu_dev(lsd->acid_next);
 
 	if (atomic_read(&d->ld_ref) && d->ld_site) {
 		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, D_ERROR, NULL);
@@ -98,16 +98,16 @@ static struct lu_device *lovsub_device_free(const struct lu_env *env,
 }
 
 static const struct lu_device_operations lovsub_lu_ops = {
-	.ldo_object_alloc      = lovsub_object_alloc,
-	.ldo_process_config    = NULL,
-	.ldo_recovery_complete = NULL
+	.ldo_object_alloc		= lovsub_object_alloc,
+	.ldo_process_config		= NULL,
+	.ldo_recovery_complete		= NULL
 };
 
 static struct lu_device *lovsub_device_alloc(const struct lu_env *env,
 					     struct lu_device_type *t,
 					     struct lustre_cfg *cfg)
 {
-	struct lu_device     *d;
+	struct lu_device *d;
 	struct lovsub_device *lsd;
 
 	lsd = kzalloc(sizeof(*lsd), GFP_NOFS);
@@ -117,7 +117,7 @@ static struct lu_device *lovsub_device_alloc(const struct lu_env *env,
 		result = cl_device_init(&lsd->acid_cl, t);
 		if (result == 0) {
 			d = lovsub2lu_dev(lsd);
-			d->ld_ops	 = &lovsub_lu_ops;
+			d->ld_ops = &lovsub_lu_ops;
 		} else {
 			d = ERR_PTR(result);
 		}
@@ -128,20 +128,20 @@ static struct lu_device *lovsub_device_alloc(const struct lu_env *env,
 }
 
 static const struct lu_device_type_operations lovsub_device_type_ops = {
-	.ldto_device_alloc = lovsub_device_alloc,
-	.ldto_device_free  = lovsub_device_free,
+	.ldto_device_alloc	= lovsub_device_alloc,
+	.ldto_device_free	= lovsub_device_free,
 
-	.ldto_device_init    = lovsub_device_init,
-	.ldto_device_fini    = lovsub_device_fini
+	.ldto_device_init	= lovsub_device_init,
+	.ldto_device_fini	= lovsub_device_fini
 };
 
 #define LUSTRE_LOVSUB_NAME	 "lovsub"
 
 struct lu_device_type lovsub_device_type = {
-	.ldt_tags     = LU_DEVICE_CL,
-	.ldt_name     = LUSTRE_LOVSUB_NAME,
-	.ldt_ops      = &lovsub_device_type_ops,
-	.ldt_ctx_tags = LCT_CL_THREAD
+	.ldt_tags		= LU_DEVICE_CL,
+	.ldt_name		= LUSTRE_LOVSUB_NAME,
+	.ldt_ops		= &lovsub_device_type_ops,
+	.ldt_ctx_tags		= LCT_CL_THREAD
 };
 
 /** @} lov */
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_lock.c b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
index ea492be..7b67c92 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
@@ -52,14 +52,14 @@
 static void lovsub_lock_fini(const struct lu_env *env,
 			     struct cl_lock_slice *slice)
 {
-	struct lovsub_lock   *lsl;
+	struct lovsub_lock *lsl;
 
 	lsl = cl2lovsub_lock(slice);
 	kmem_cache_free(lovsub_lock_kmem, lsl);
 }
 
 static const struct cl_lock_operations lovsub_lock_ops = {
-	.clo_fini    = lovsub_lock_fini,
+	.clo_fini	= lovsub_lock_fini,
 };
 
 int lovsub_lock_init(const struct lu_env *env, struct cl_object *obj,
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
index da4b7f1..6ba09f1 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_object.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_object.c
@@ -52,10 +52,9 @@
 int lovsub_object_init(const struct lu_env *env, struct lu_object *obj,
 		       const struct lu_object_conf *conf)
 {
-	struct lovsub_device  *dev   = lu2lovsub_dev(obj->lo_dev);
-	struct lu_object      *below;
-	struct lu_device      *under;
-
+	struct lovsub_device *dev = lu2lovsub_dev(obj->lo_dev);
+	struct lu_object *below;
+	struct lu_device *under;
 	int result;
 
 	under = &dev->acid_next->cd_lu_dev;
@@ -73,7 +72,7 @@ int lovsub_object_init(const struct lu_env *env, struct lu_object *obj,
 static void lovsub_object_free(const struct lu_env *env, struct lu_object *obj)
 {
 	struct lovsub_object *los = lu2lovsub(obj);
-	struct lov_object    *lov = los->lso_super;
+	struct lov_object *lov = los->lso_super;
 
 	/* We can't assume lov was assigned here, because of the shadow
 	 * object handling in lu_object_find.
@@ -146,20 +145,20 @@ static void lovsub_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 }
 
 static const struct cl_object_operations lovsub_ops = {
-	.coo_page_init = lovsub_page_init,
-	.coo_lock_init = lovsub_lock_init,
-	.coo_attr_update = lovsub_attr_update,
+	.coo_page_init		= lovsub_page_init,
+	.coo_lock_init		= lovsub_lock_init,
+	.coo_attr_update	= lovsub_attr_update,
 	.coo_glimpse		= lovsub_object_glimpse,
 	.coo_req_attr_set	= lovsub_req_attr_set
 };
 
 static const struct lu_object_operations lovsub_lu_obj_ops = {
-	.loo_object_init      = lovsub_object_init,
-	.loo_object_delete    = NULL,
-	.loo_object_release   = NULL,
-	.loo_object_free      = lovsub_object_free,
-	.loo_object_print     = lovsub_object_print,
-	.loo_object_invariant = NULL
+	.loo_object_init	= lovsub_object_init,
+	.loo_object_delete	= NULL,
+	.loo_object_release	= NULL,
+	.loo_object_free	= lovsub_object_free,
+	.loo_object_print	= lovsub_object_print,
+	.loo_object_invariant	= NULL
 };
 
 struct lu_object *lovsub_object_alloc(const struct lu_env *env,
@@ -167,7 +166,7 @@ struct lu_object *lovsub_object_alloc(const struct lu_env *env,
 				      struct lu_device *dev)
 {
 	struct lovsub_object *los;
-	struct lu_object     *obj;
+	struct lu_object *obj;
 
 	los = kmem_cache_zalloc(lovsub_object_kmem, GFP_NOFS);
 	if (los) {
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_page.c b/drivers/staging/lustre/lustre/lov/lovsub_page.c
index 915520b..a8aa583 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_page.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_page.c
@@ -53,7 +53,7 @@ static void lovsub_page_fini(const struct lu_env *env,
 }
 
 static const struct cl_page_operations lovsub_page_ops = {
-	.cpo_fini   = lovsub_page_fini
+	.cpo_fini	= lovsub_page_fini
 };
 
 int lovsub_page_init(const struct lu_env *env, struct cl_object *obj,
diff --git a/drivers/staging/lustre/lustre/lov/lproc_lov.c b/drivers/staging/lustre/lustre/lov/lproc_lov.c
index 771c6f8..fc53f23 100644
--- a/drivers/staging/lustre/lustre/lov/lproc_lov.c
+++ b/drivers/staging/lustre/lustre/lov/lproc_lov.c
@@ -239,10 +239,10 @@ static int lov_tgt_seq_show(struct seq_file *p, void *v)
 }
 
 static const struct seq_operations lov_tgt_sops = {
-	.start = lov_tgt_seq_start,
-	.stop = lov_tgt_seq_stop,
-	.next = lov_tgt_seq_next,
-	.show = lov_tgt_seq_show,
+	.start		= lov_tgt_seq_start,
+	.stop		= lov_tgt_seq_stop,
+	.next		= lov_tgt_seq_next,
+	.show		= lov_tgt_seq_show,
 };
 
 static int lov_target_seq_open(struct inode *inode, struct file *file)
@@ -260,11 +260,11 @@ static int lov_target_seq_open(struct inode *inode, struct file *file)
 }
 
 static const struct file_operations lov_debugfs_target_fops = {
-	.owner   = THIS_MODULE,
-	.open    = lov_target_seq_open,
-	.read    = seq_read,
-	.llseek  = seq_lseek,
-	.release = lprocfs_seq_release,
+	.owner		= THIS_MODULE,
+	.open		= lov_target_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= lprocfs_seq_release,
 };
 
 static struct attribute *lov_attrs[] = {
-- 
1.8.3.1
