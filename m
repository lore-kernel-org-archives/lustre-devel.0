From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:42 -0500
Subject: [lustre-devel] [PATCH 12/35] staging: lustre: clio: get rid of
	cl_req
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Implement cl_req_attr_set with a cl_object operation.
Get rid of cl_req and related function and data structures.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6943
Reviewed-on: http://review.whamcloud.com/15833
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |  242 ++------------------
 drivers/staging/lustre/lustre/llite/Makefile       |    2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |   11 -
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |    4 -
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |   12 -
 drivers/staging/lustre/lustre/llite/vvp_internal.h |    8 -
 drivers/staging/lustre/lustre/llite/vvp_object.c   |   23 ++-
 drivers/staging/lustre/lustre/llite/vvp_req.c      |  115 ---------
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |   26 --
 drivers/staging/lustre/lustre/lov/lov_dev.c        |   52 -----
 drivers/staging/lustre/lustre/lov/lovsub_dev.c     |   61 -----
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |   22 ++-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |  231 +------------------
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   19 +--
 .../staging/lustre/lustre/obdecho/echo_client.c    |    4 -
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    9 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   21 +-
 drivers/staging/lustre/lustre/osc/osc_dev.c        |   13 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |  133 -----------
 drivers/staging/lustre/lustre/osc/osc_object.c     |   73 ++++++-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  127 ++++-------
 21 files changed, 200 insertions(+), 1008 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/llite/vvp_req.c

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 3fe26e7..dc68561 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -59,10 +59,6 @@
  *		 read/write system call it is associated with the single user
  *		 thread, that issued the system call).
  *
- *   - cl_req      represents a collection of pages for a transfer. cl_req is
- *		 constructed by req-forming engine that tries to saturate
- *		 transport with large and continuous transfers.
- *
  * Terminology
  *
  *     - to avoid confusion high-level I/O operation like read or write system
@@ -103,11 +99,8 @@
 struct inode;
 
 struct cl_device;
-struct cl_device_operations;
 
 struct cl_object;
-struct cl_object_page_operations;
-struct cl_object_lock_operations;
 
 struct cl_page;
 struct cl_page_slice;
@@ -120,27 +113,7 @@
 struct cl_io;
 struct cl_io_slice;
 
-struct cl_req;
-struct cl_req_slice;
-
-/**
- * Operations for each data device in the client stack.
- *
- * \see vvp_cl_ops, lov_cl_ops, lovsub_cl_ops, osc_cl_ops
- */
-struct cl_device_operations {
-	/**
-	 * Initialize cl_req. This method is called top-to-bottom on all
-	 * devices in the stack to get them a chance to allocate layer-private
-	 * data, and to attach them to the cl_req by calling
-	 * cl_req_slice_add().
-	 *
-	 * \see osc_req_init(), lov_req_init(), lovsub_req_init()
-	 * \see vvp_req_init()
-	 */
-	int (*cdo_req_init)(const struct lu_env *env, struct cl_device *dev,
-			    struct cl_req *req);
-};
+struct cl_req_attr;
 
 /**
  * Device in the client stack.
@@ -150,8 +123,6 @@ struct cl_device_operations {
 struct cl_device {
 	/** Super-class. */
 	struct lu_device		   cd_lu_dev;
-	/** Per-layer operation vector. */
-	const struct cl_device_operations *cd_ops;
 };
 
 /** \addtogroup cl_object cl_object
@@ -435,6 +406,12 @@ struct cl_object_operations {
 	 * Get maximum size of the object.
 	 */
 	loff_t (*coo_maxbytes)(struct cl_object *obj);
+	/**
+	 * Set request attributes.
+	 */
+	void (*coo_req_attr_set)(const struct lu_env *env,
+				 struct cl_object *obj,
+				 struct cl_req_attr *attr);
 };
 
 /**
@@ -626,7 +603,7 @@ enum cl_page_state {
 	 *
 	 *     - [cl_page_state::CPS_PAGEOUT] page is dirty, the
 	 *     req-formation engine decides that it wants to include this page
-	 *     into an cl_req being constructed, and yanks it from the cache;
+	 *     into an RPC being constructed, and yanks it from the cache;
 	 *
 	 *     - [cl_page_state::CPS_FREEING] VM callback is executed to
 	 *     evict the page form the memory;
@@ -695,7 +672,7 @@ enum cl_page_state {
 	 * Page is being read in, as a part of a transfer. This is quite
 	 * similar to the cl_page_state::CPS_PAGEOUT state, except that
 	 * read-in is always "immediate"---there is no such thing a sudden
-	 * construction of read cl_req from cached, presumably not up to date,
+	 * construction of read request from cached, presumably not up to date,
 	 * pages.
 	 *
 	 * Underlying VM page is locked for the duration of transfer.
@@ -749,8 +726,6 @@ struct cl_page {
 	struct list_head	 cp_batch;
 	/** List of slices. Immutable after creation. */
 	struct list_head	 cp_layers;
-	/** Linkage of pages within cl_req. */
-	struct list_head         cp_flight;
 	/**
 	 * Page state. This field is const to avoid accidental update, it is
 	 * modified only internally within cl_page.c. Protected by a VM lock.
@@ -767,12 +742,6 @@ struct cl_page {
 	 * by sub-io. Protected by a VM lock.
 	 */
 	struct cl_io	    *cp_owner;
-	/**
-	 * Owning IO request in cl_page_state::CPS_PAGEOUT and
-	 * cl_page_state::CPS_PAGEIN states. This field is maintained only in
-	 * the top-level pages. Protected by a VM lock.
-	 */
-	struct cl_req	   *cp_req;
 	/** List of references to this page, for debugging. */
 	struct lu_ref	    cp_reference;
 	/** Link to an object, for debugging. */
@@ -814,7 +783,6 @@ enum cl_lock_mode {
 
 /**
  * Requested transfer type.
- * \ingroup cl_req
  */
 enum cl_req_type {
 	CRT_READ,
@@ -930,8 +898,7 @@ struct cl_page_operations {
 	/**
 	 * \name transfer
 	 *
-	 * Transfer methods. See comment on cl_req for a description of
-	 * transfer formation and life-cycle.
+	 * Transfer methods.
 	 *
 	 * @{
 	 */
@@ -977,7 +944,7 @@ struct cl_page_operations {
 				       int ioret);
 		/**
 		 * Called when cached page is about to be added to the
-		 * cl_req as a part of req formation.
+		 * ptlrpc request as a part of req formation.
 		 *
 		 * \return    0       : proceed with this page;
 		 * \return    -EAGAIN : skip this page;
@@ -1879,179 +1846,20 @@ struct cl_io {
 
 /** @} cl_io */
 
-/** \addtogroup cl_req cl_req
- * @{
- */
-/** \struct cl_req
- * Transfer.
- *
- * There are two possible modes of transfer initiation on the client:
- *
- *     - immediate transfer: this is started when a high level io wants a page
- *       or a collection of pages to be transferred right away. Examples:
- *       read-ahead, synchronous read in the case of non-page aligned write,
- *       page write-out as a part of extent lock cancellation, page write-out
- *       as a part of memory cleansing. Immediate transfer can be both
- *       cl_req_type::CRT_READ and cl_req_type::CRT_WRITE;
- *
- *     - opportunistic transfer (cl_req_type::CRT_WRITE only), that happens
- *       when io wants to transfer a page to the server some time later, when
- *       it can be done efficiently. Example: pages dirtied by the write(2)
- *       path.
- *
- * In any case, transfer takes place in the form of a cl_req, which is a
- * representation for a network RPC.
- *
- * Pages queued for an opportunistic transfer are cached until it is decided
- * that efficient RPC can be composed of them. This decision is made by "a
- * req-formation engine", currently implemented as a part of osc
- * layer. Req-formation depends on many factors: the size of the resulting
- * RPC, whether or not multi-object RPCs are supported by the server,
- * max-rpc-in-flight limitations, size of the dirty cache, etc.
- *
- * For the immediate transfer io submits a cl_page_list, that req-formation
- * engine slices into cl_req's, possibly adding cached pages to some of
- * the resulting req's.
- *
- * Whenever a page from cl_page_list is added to a newly constructed req, its
- * cl_page_operations::cpo_prep() layer methods are called. At that moment,
- * page state is atomically changed from cl_page_state::CPS_OWNED to
- * cl_page_state::CPS_PAGEOUT or cl_page_state::CPS_PAGEIN, cl_page::cp_owner
- * is zeroed, and cl_page::cp_req is set to the
- * req. cl_page_operations::cpo_prep() method at the particular layer might
- * return -EALREADY to indicate that it does not need to submit this page
- * at all. This is possible, for example, if page, submitted for read,
- * became up-to-date in the meantime; and for write, the page don't have
- * dirty bit marked. \see cl_io_submit_rw()
- *
- * Whenever a cached page is added to a newly constructed req, its
- * cl_page_operations::cpo_make_ready() layer methods are called. At that
- * moment, page state is atomically changed from cl_page_state::CPS_CACHED to
- * cl_page_state::CPS_PAGEOUT, and cl_page::cp_req is set to
- * req. cl_page_operations::cpo_make_ready() method at the particular layer
- * might return -EAGAIN to indicate that this page is not eligible for the
- * transfer right now.
- *
- * FUTURE
- *
- * Plan is to divide transfers into "priority bands" (indicated when
- * submitting cl_page_list, and queuing a page for the opportunistic transfer)
- * and allow glueing of cached pages to immediate transfers only within single
- * band. This would make high priority transfers (like lock cancellation or
- * memory pressure induced write-out) really high priority.
- *
- */
-
 /**
  * Per-transfer attributes.
  */
 struct cl_req_attr {
+	enum cl_req_type cra_type;
+	u64		 cra_flags;
+	struct cl_page	*cra_page;
+
 	/** Generic attributes for the server consumption. */
 	struct obdo	*cra_oa;
 	/** Jobid */
 	char		 cra_jobid[LUSTRE_JOBID_SIZE];
 };
 
-/**
- * Transfer request operations definable at every layer.
- *
- * Concurrency: transfer formation engine synchronizes calls to all transfer
- * methods.
- */
-struct cl_req_operations {
-	/**
-	 * Invoked top-to-bottom by cl_req_prep() when transfer formation is
-	 * complete (all pages are added).
-	 *
-	 * \see osc_req_prep()
-	 */
-	int  (*cro_prep)(const struct lu_env *env,
-			 const struct cl_req_slice *slice);
-	/**
-	 * Called top-to-bottom to fill in \a oa fields. This is called twice
-	 * with different flags, see bug 10150 and osc_build_req().
-	 *
-	 * \param obj an object from cl_req which attributes are to be set in
-	 *	    \a oa.
-	 *
-	 * \param oa struct obdo where attributes are placed
-	 *
-	 * \param flags \a oa fields to be filled.
-	 */
-	void (*cro_attr_set)(const struct lu_env *env,
-			     const struct cl_req_slice *slice,
-			     const struct cl_object *obj,
-			     struct cl_req_attr *attr, u64 flags);
-	/**
-	 * Called top-to-bottom from cl_req_completion() to notify layers that
-	 * transfer completed. Has to free all state allocated by
-	 * cl_device_operations::cdo_req_init().
-	 */
-	void (*cro_completion)(const struct lu_env *env,
-			       const struct cl_req_slice *slice, int ioret);
-};
-
-/**
- * A per-object state that (potentially multi-object) transfer request keeps.
- */
-struct cl_req_obj {
-	/** object itself */
-	struct cl_object   *ro_obj;
-	/** reference to cl_req_obj::ro_obj. For debugging. */
-	struct lu_ref_link  ro_obj_ref;
-	/* something else? Number of pages for a given object? */
-};
-
-/**
- * Transfer request.
- *
- * Transfer requests are not reference counted, because IO sub-system owns
- * them exclusively and knows when to free them.
- *
- * Life cycle.
- *
- * cl_req is created by cl_req_alloc() that calls
- * cl_device_operations::cdo_req_init() device methods to allocate per-req
- * state in every layer.
- *
- * Then pages are added (cl_req_page_add()), req keeps track of all objects it
- * contains pages for.
- *
- * Once all pages were collected, cl_page_operations::cpo_prep() method is
- * called top-to-bottom. At that point layers can modify req, let it pass, or
- * deny it completely. This is to support things like SNS that have transfer
- * ordering requirements invisible to the individual req-formation engine.
- *
- * On transfer completion (or transfer timeout, or failure to initiate the
- * transfer of an allocated req), cl_req_operations::cro_completion() method
- * is called, after execution of cl_page_operations::cpo_completion() of all
- * req's pages.
- */
-struct cl_req {
-	enum cl_req_type      crq_type;
-	/** A list of pages being transferred */
-	struct list_head	    crq_pages;
-	/** Number of pages in cl_req::crq_pages */
-	unsigned	      crq_nrpages;
-	/** An array of objects which pages are in ->crq_pages */
-	struct cl_req_obj    *crq_o;
-	/** Number of elements in cl_req::crq_objs[] */
-	unsigned	      crq_nrobjs;
-	struct list_head	    crq_layers;
-};
-
-/**
- * Per-layer state for request.
- */
-struct cl_req_slice {
-	struct cl_req    *crs_req;
-	struct cl_device *crs_dev;
-	struct list_head	crs_linkage;
-	const struct cl_req_operations *crs_ops;
-};
-
-/* @} cl_req */
-
 enum cache_stats_item {
 	/** how many cache lookups were performed */
 	CS_lookup = 0,
@@ -2196,9 +2004,6 @@ void cl_lock_slice_add(struct cl_lock *lock, struct cl_lock_slice *slice,
 		       const struct cl_lock_operations *ops);
 void cl_io_slice_add(struct cl_io *io, struct cl_io_slice *slice,
 		     struct cl_object *obj, const struct cl_io_operations *ops);
-void cl_req_slice_add(struct cl_req *req, struct cl_req_slice *slice,
-		      struct cl_device *dev,
-		      const struct cl_req_operations *ops);
 /** @} helpers */
 
 /** \defgroup cl_object cl_object
@@ -2567,19 +2372,8 @@ void cl_2queue_discard(const struct lu_env *env,
 
 /** @} cl_page_list */
 
-/** \defgroup cl_req cl_req
- * @{
- */
-struct cl_req *cl_req_alloc(const struct lu_env *env, struct cl_page *page,
-			    enum cl_req_type crt, int nr_objects);
-
-void cl_req_page_add(const struct lu_env *env, struct cl_req *req,
-		     struct cl_page *page);
-void cl_req_page_done(const struct lu_env *env, struct cl_page *page);
-int  cl_req_prep(const struct lu_env *env, struct cl_req *req);
-void cl_req_attr_set(const struct lu_env *env, struct cl_req *req,
-		     struct cl_req_attr *attr, u64 flags);
-void cl_req_completion(const struct lu_env *env, struct cl_req *req, int ioret);
+void cl_req_attr_set(const struct lu_env *env, struct cl_object *obj,
+		     struct cl_req_attr *attr);
 
 /** \defgroup cl_sync_io cl_sync_io
  * @{
@@ -2615,8 +2409,6 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 
 /** @} cl_sync_io */
 
-/** @} cl_req */
-
 /** \defgroup cl_env cl_env
  *
  * lu_env handling for a client.
diff --git a/drivers/staging/lustre/lustre/llite/Makefile b/drivers/staging/lustre/lustre/llite/Makefile
index ca9c275..322d4fa 100644
--- a/drivers/staging/lustre/lustre/llite/Makefile
+++ b/drivers/staging/lustre/lustre/llite/Makefile
@@ -3,5 +3,5 @@ lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
 	    rw.o rw26.o namei.o symlink.o llite_mmap.o range_lock.o \
 	    xattr.o xattr_cache.o xattr_security.o \
 	    super25.o statahead.o glimpse.o lcommon_cl.o lcommon_misc.o \
-	    vvp_dev.o vvp_page.o vvp_lock.o vvp_io.o vvp_object.o vvp_req.o \
+	    vvp_dev.o vvp_page.o vvp_lock.o vvp_io.o vvp_object.o \
 	    lproc_llite.o
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 8bd1eb8..f635efa 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -662,8 +662,6 @@ enum {
 	LPROC_LL_WRITE_BYTES,
 	LPROC_LL_BRW_READ,
 	LPROC_LL_BRW_WRITE,
-	LPROC_LL_OSC_READ,
-	LPROC_LL_OSC_WRITE,
 	LPROC_LL_IOCTL,
 	LPROC_LL_OPEN,
 	LPROC_LL_RELEASE,
@@ -1214,15 +1212,6 @@ struct ll_dio_pages {
 	int	   ldp_nr;
 };
 
-static inline void cl_stats_tally(struct cl_device *dev, enum cl_req_type crt,
-				  int rc)
-{
-	int opc = (crt == CRT_READ) ? LPROC_LL_OSC_READ :
-				      LPROC_LL_OSC_WRITE;
-
-	ll_stats_ops_tally(ll_s2sbi(cl2vvp_dev(dev)->vdv_sb), opc, rc);
-}
-
 ssize_t ll_direct_rw_pages(const struct lu_env *env, struct cl_io *io,
 			   int rw, struct inode *inode,
 			   struct ll_dio_pages *pv);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 23fda9d..03682c1 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1060,10 +1060,6 @@ static void llite_sb_release(struct kobject *kobj)
 				   "brw_read" },
 	{ LPROC_LL_BRW_WRITE,      LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_PAGES,
 				   "brw_write" },
-	{ LPROC_LL_OSC_READ,       LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_BYTES,
-				   "osc_read" },
-	{ LPROC_LL_OSC_WRITE,      LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_BYTES,
-				   "osc_write" },
 	{ LPROC_LL_IOCTL,	  LPROCFS_TYPE_REGS, "ioctl" },
 	{ LPROC_LL_OPEN,	   LPROCFS_TYPE_REGS, "open" },
 	{ LPROC_LL_RELEASE,	LPROCFS_TYPE_REGS, "close" },
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index cab95ac..12c129f 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -55,7 +55,6 @@
 static struct kmem_cache *ll_thread_kmem;
 struct kmem_cache *vvp_lock_kmem;
 struct kmem_cache *vvp_object_kmem;
-struct kmem_cache *vvp_req_kmem;
 static struct kmem_cache *vvp_session_kmem;
 static struct kmem_cache *vvp_thread_kmem;
 
@@ -76,11 +75,6 @@
 		.ckd_size  = sizeof(struct vvp_object),
 	},
 	{
-		.ckd_cache = &vvp_req_kmem,
-		.ckd_name  = "vvp_req_kmem",
-		.ckd_size  = sizeof(struct vvp_req),
-	},
-	{
 		.ckd_cache = &vvp_session_kmem,
 		.ckd_name  = "vvp_session_kmem",
 		.ckd_size  = sizeof(struct vvp_session)
@@ -177,10 +171,6 @@ struct lu_context_key vvp_thread_key = {
 	.ldo_object_alloc      = vvp_object_alloc
 };
 
-static const struct cl_device_operations vvp_cl_ops = {
-	.cdo_req_init = vvp_req_init
-};
-
 static struct lu_device *vvp_device_free(const struct lu_env *env,
 					 struct lu_device *d)
 {
@@ -213,7 +203,6 @@ struct lu_context_key vvp_thread_key = {
 	lud = &vdv->vdv_cl.cd_lu_dev;
 	cl_device_init(&vdv->vdv_cl, t);
 	vvp2lu_dev(vdv)->ld_ops = &vvp_lu_ops;
-	vdv->vdv_cl.cd_ops = &vvp_cl_ops;
 
 	site = kzalloc(sizeof(*site), GFP_NOFS);
 	if (site) {
@@ -332,7 +321,6 @@ int cl_sb_init(struct super_block *sb)
 		cl = cl_type_setup(env, NULL, &vvp_device_type,
 				   sbi->ll_dt_exp->exp_obd->obd_lu_dev);
 		if (!IS_ERR(cl)) {
-			cl2vvp_dev(cl)->vdv_sb = sb;
 			sbi->ll_cl = cl;
 			sbi->ll_site = cl2lu_dev(cl)->ld_site;
 		}
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index afed7db..c60d041 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -120,7 +120,6 @@ struct vvp_io {
 
 extern struct kmem_cache *vvp_lock_kmem;
 extern struct kmem_cache *vvp_object_kmem;
-extern struct kmem_cache *vvp_req_kmem;
 
 struct vvp_thread_info {
 	struct cl_lock		vti_lock;
@@ -242,7 +241,6 @@ static inline pgoff_t vvp_index(struct vvp_page *vvp)
 
 struct vvp_device {
 	struct cl_device    vdv_cl;
-	struct super_block *vdv_sb;
 	struct cl_device   *vdv_next;
 };
 
@@ -250,10 +248,6 @@ struct vvp_lock {
 	struct cl_lock_slice vlk_cl;
 };
 
-struct vvp_req {
-	struct cl_req_slice  vrq_cl;
-};
-
 void *ccc_key_init(const struct lu_context *ctx,
 		   struct lu_context_key *key);
 void ccc_key_fini(const struct lu_context *ctx,
@@ -316,8 +310,6 @@ int vvp_lock_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_lock *lock, const struct cl_io *io);
 int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_page *page, pgoff_t index);
-int vvp_req_init(const struct lu_env *env, struct cl_device *dev,
-		 struct cl_req *req);
 struct lu_object *vvp_object_alloc(const struct lu_env *env,
 				   const struct lu_object_header *hdr,
 				   struct lu_device *dev);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index cc0f3da..8e18cf8 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -184,6 +184,26 @@ static int vvp_object_glimpse(const struct lu_env *env,
 	return 0;
 }
 
+static void vvp_req_attr_set(const struct lu_env *env, struct cl_object *obj,
+			     struct cl_req_attr *attr)
+{
+	u64 valid_flags = OBD_MD_FLTYPE;
+	struct inode *inode;
+	struct obdo *oa;
+
+	oa = attr->cra_oa;
+	inode = vvp_object_inode(obj);
+
+	if (attr->cra_type == CRT_WRITE)
+		valid_flags |= OBD_MD_FLMTIME | OBD_MD_FLCTIME |
+			       OBD_MD_FLUID | OBD_MD_FLGID;
+	obdo_from_inode(oa, inode, valid_flags & attr->cra_flags);
+	obdo_set_parent_fid(oa, &ll_i2info(inode)->lli_fid);
+	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_INVALID_PFID))
+		oa->o_parent_oid++;
+	memcpy(attr->cra_jobid, ll_i2info(inode)->lli_jobid, LUSTRE_JOBID_SIZE);
+}
+
 static const struct cl_object_operations vvp_ops = {
 	.coo_page_init = vvp_page_init,
 	.coo_lock_init = vvp_lock_init,
@@ -192,7 +212,8 @@ static int vvp_object_glimpse(const struct lu_env *env,
 	.coo_attr_update = vvp_attr_update,
 	.coo_conf_set  = vvp_conf_set,
 	.coo_prune     = vvp_prune,
-	.coo_glimpse   = vvp_object_glimpse
+	.coo_glimpse		= vvp_object_glimpse,
+	.coo_req_attr_set	= vvp_req_attr_set
 };
 
 static int vvp_object_init0(const struct lu_env *env,
diff --git a/drivers/staging/lustre/lustre/llite/vvp_req.c b/drivers/staging/lustre/lustre/llite/vvp_req.c
deleted file mode 100644
index a8892e4..0000000
--- a/drivers/staging/lustre/lustre/llite/vvp_req.c
+++ /dev/null
@@ -1,115 +0,0 @@
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
- * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, 2014, Intel Corporation.
- */
-
-#define DEBUG_SUBSYSTEM S_LLITE
-
-#include "../include/lustre/lustre_idl.h"
-#include "../include/cl_object.h"
-#include "../include/obd.h"
-#include "../include/obd_support.h"
-#include "llite_internal.h"
-#include "vvp_internal.h"
-
-static inline struct vvp_req *cl2vvp_req(const struct cl_req_slice *slice)
-{
-	return container_of0(slice, struct vvp_req, vrq_cl);
-}
-
-/**
- * Implementation of struct cl_req_operations::cro_attr_set() for VVP
- * layer. VVP is responsible for
- *
- *    - o_[mac]time
- *
- *    - o_mode
- *
- *    - o_parent_seq
- *
- *    - o_[ug]id
- *
- *    - o_parent_oid
- *
- *    - o_parent_ver
- *
- */
-static void vvp_req_attr_set(const struct lu_env *env,
-			     const struct cl_req_slice *slice,
-			     const struct cl_object *obj,
-			     struct cl_req_attr *attr, u64 flags)
-{
-	struct inode *inode;
-	struct obdo  *oa;
-	u32	      valid_flags;
-
-	oa = attr->cra_oa;
-	inode = vvp_object_inode(obj);
-	valid_flags = OBD_MD_FLTYPE;
-
-	if (slice->crs_req->crq_type == CRT_WRITE)
-		valid_flags |= OBD_MD_FLMTIME | OBD_MD_FLCTIME |
-			       OBD_MD_FLUID | OBD_MD_FLGID;
-	obdo_from_inode(oa, inode, valid_flags & flags);
-	obdo_set_parent_fid(oa, &ll_i2info(inode)->lli_fid);
-	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_INVALID_PFID))
-		oa->o_parent_oid++;
-	memcpy(attr->cra_jobid, ll_i2info(inode)->lli_jobid,
-	       LUSTRE_JOBID_SIZE);
-}
-
-static void vvp_req_completion(const struct lu_env *env,
-			       const struct cl_req_slice *slice, int ioret)
-{
-	struct vvp_req *vrq;
-
-	if (ioret > 0)
-		cl_stats_tally(slice->crs_dev, slice->crs_req->crq_type, ioret);
-
-	vrq = cl2vvp_req(slice);
-	kmem_cache_free(vvp_req_kmem, vrq);
-}
-
-static const struct cl_req_operations vvp_req_ops = {
-	.cro_attr_set   = vvp_req_attr_set,
-	.cro_completion = vvp_req_completion
-};
-
-int vvp_req_init(const struct lu_env *env, struct cl_device *dev,
-		 struct cl_req *req)
-{
-	struct vvp_req *vrq;
-	int result;
-
-	vrq = kmem_cache_zalloc(vvp_req_kmem, GFP_NOFS);
-	if (vrq) {
-		cl_req_slice_add(req, &vrq->vrq_cl, dev, &vvp_req_ops);
-		result = 0;
-	} else {
-		result = -ENOMEM;
-	}
-	return result;
-}
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index a08e41d..c49a34b 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -472,20 +472,6 @@ struct lov_session {
 	struct lov_sublock_env ls_subenv;
 };
 
-/**
- * State of transfer for lov.
- */
-struct lov_req {
-	struct cl_req_slice lr_cl;
-};
-
-/**
- * State of transfer for lovsub.
- */
-struct lovsub_req {
-	struct cl_req_slice lsrq_cl;
-};
-
 extern struct lu_device_type lov_device_type;
 extern struct lu_device_type lovsub_device_type;
 
@@ -496,11 +482,9 @@ struct lovsub_req {
 extern struct kmem_cache *lov_object_kmem;
 extern struct kmem_cache *lov_thread_kmem;
 extern struct kmem_cache *lov_session_kmem;
-extern struct kmem_cache *lov_req_kmem;
 
 extern struct kmem_cache *lovsub_lock_kmem;
 extern struct kmem_cache *lovsub_object_kmem;
-extern struct kmem_cache *lovsub_req_kmem;
 
 extern struct kmem_cache *lov_lock_link_kmem;
 
@@ -699,11 +683,6 @@ static inline int lovsub_is_object(const struct lu_object *obj)
 	return container_of0(slice, struct lov_page, lps_cl);
 }
 
-static inline struct lov_req *cl2lov_req(const struct cl_req_slice *slice)
-{
-	return container_of0(slice, struct lov_req, lr_cl);
-}
-
 static inline struct lovsub_page *
 cl2lovsub_page(const struct cl_page_slice *slice)
 {
@@ -711,11 +690,6 @@ static inline int lovsub_is_object(const struct lu_object *obj)
 	return container_of0(slice, struct lovsub_page, lsb_cl);
 }
 
-static inline struct lovsub_req *cl2lovsub_req(const struct cl_req_slice *slice)
-{
-	return container_of0(slice, struct lovsub_req, lsrq_cl);
-}
-
 static inline struct lov_io *cl2lov_io(const struct lu_env *env,
 				       const struct cl_io_slice *ios)
 {
diff --git a/drivers/staging/lustre/lustre/lov/lov_dev.c b/drivers/staging/lustre/lustre/lov/lov_dev.c
index 056ae2e..7301f6e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lov_dev.c
@@ -46,11 +46,9 @@
 struct kmem_cache *lov_object_kmem;
 struct kmem_cache *lov_thread_kmem;
 struct kmem_cache *lov_session_kmem;
-struct kmem_cache *lov_req_kmem;
 
 struct kmem_cache *lovsub_lock_kmem;
 struct kmem_cache *lovsub_object_kmem;
-struct kmem_cache *lovsub_req_kmem;
 
 struct kmem_cache *lov_lock_link_kmem;
 
@@ -79,11 +77,6 @@ struct lu_kmem_descr lov_caches[] = {
 		.ckd_size  = sizeof(struct lov_session)
 	},
 	{
-		.ckd_cache = &lov_req_kmem,
-		.ckd_name  = "lov_req_kmem",
-		.ckd_size  = sizeof(struct lov_req)
-	},
-	{
 		.ckd_cache = &lovsub_lock_kmem,
 		.ckd_name  = "lovsub_lock_kmem",
 		.ckd_size  = sizeof(struct lovsub_lock)
@@ -94,11 +87,6 @@ struct lu_kmem_descr lov_caches[] = {
 		.ckd_size  = sizeof(struct lovsub_object)
 	},
 	{
-		.ckd_cache = &lovsub_req_kmem,
-		.ckd_name  = "lovsub_req_kmem",
-		.ckd_size  = sizeof(struct lovsub_req)
-	},
-	{
 		.ckd_cache = &lov_lock_link_kmem,
 		.ckd_name  = "lov_lock_link_kmem",
 		.ckd_size  = sizeof(struct lov_lock_link)
@@ -110,25 +98,6 @@ struct lu_kmem_descr lov_caches[] = {
 
 /*****************************************************************************
  *
- * Lov transfer operations.
- *
- */
-
-static void lov_req_completion(const struct lu_env *env,
-			       const struct cl_req_slice *slice, int ioret)
-{
-	struct lov_req *lr;
-
-	lr = cl2lov_req(slice);
-	kmem_cache_free(lov_req_kmem, lr);
-}
-
-static const struct cl_req_operations lov_req_ops = {
-	.cro_completion = lov_req_completion
-};
-
-/*****************************************************************************
- *
  * Lov device and device type functions.
  *
  */
@@ -248,26 +217,6 @@ static int lov_device_init(const struct lu_env *env, struct lu_device *d,
 	return rc;
 }
 
-static int lov_req_init(const struct lu_env *env, struct cl_device *dev,
-			struct cl_req *req)
-{
-	struct lov_req *lr;
-	int result;
-
-	lr = kmem_cache_zalloc(lov_req_kmem, GFP_NOFS);
-	if (lr) {
-		cl_req_slice_add(req, &lr->lr_cl, dev, &lov_req_ops);
-		result = 0;
-	} else {
-		result = -ENOMEM;
-	}
-	return result;
-}
-
-static const struct cl_device_operations lov_cl_ops = {
-	.cdo_req_init = lov_req_init
-};
-
 static void lov_emerg_free(struct lov_device_emerg **emrg, int nr)
 {
 	int i;
@@ -478,7 +427,6 @@ static int lov_process_config(const struct lu_env *env,
 	cl_device_init(&ld->ld_cl, t);
 	d = lov2lu_dev(ld);
 	d->ld_ops	= &lov_lu_ops;
-	ld->ld_cl.cd_ops = &lov_cl_ops;
 
 	mutex_init(&ld->ld_mutex);
 	lockdep_set_class(&ld->ld_mutex, &cl_lov_device_mutex_class);
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_dev.c b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
index b519a19..5d6536f 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
@@ -44,46 +44,6 @@
 
 /*****************************************************************************
  *
- * Lovsub transfer operations.
- *
- */
-
-static void lovsub_req_completion(const struct lu_env *env,
-				  const struct cl_req_slice *slice, int ioret)
-{
-	struct lovsub_req *lsr;
-
-	lsr = cl2lovsub_req(slice);
-	kmem_cache_free(lovsub_req_kmem, lsr);
-}
-
-/**
- * Implementation of struct cl_req_operations::cro_attr_set() for lovsub
- * layer. Lov and lovsub are responsible only for struct obdo::o_stripe_idx
- * field, which is filled there.
- */
-static void lovsub_req_attr_set(const struct lu_env *env,
-				const struct cl_req_slice *slice,
-				const struct cl_object *obj,
-				struct cl_req_attr *attr, u64 flags)
-{
-	struct lovsub_object *subobj;
-
-	subobj = cl2lovsub(obj);
-	/*
-	 * There is no OBD_MD_* flag for obdo::o_stripe_idx, so set it
-	 * unconditionally. It never changes anyway.
-	 */
-	attr->cra_oa->o_stripe_idx = subobj->lso_index;
-}
-
-static const struct cl_req_operations lovsub_req_ops = {
-	.cro_attr_set   = lovsub_req_attr_set,
-	.cro_completion = lovsub_req_completion
-};
-
-/*****************************************************************************
- *
  * Lov-sub device and device type functions.
  *
  */
@@ -137,32 +97,12 @@ static int lovsub_device_init(const struct lu_env *env, struct lu_device *d,
 	return next;
 }
 
-static int lovsub_req_init(const struct lu_env *env, struct cl_device *dev,
-			   struct cl_req *req)
-{
-	struct lovsub_req *lsr;
-	int result;
-
-	lsr = kmem_cache_zalloc(lovsub_req_kmem, GFP_NOFS);
-	if (lsr) {
-		cl_req_slice_add(req, &lsr->lsrq_cl, dev, &lovsub_req_ops);
-		result = 0;
-	} else {
-		result = -ENOMEM;
-	}
-	return result;
-}
-
 static const struct lu_device_operations lovsub_lu_ops = {
 	.ldo_object_alloc      = lovsub_object_alloc,
 	.ldo_process_config    = NULL,
 	.ldo_recovery_complete = NULL
 };
 
-static const struct cl_device_operations lovsub_cl_ops = {
-	.cdo_req_init = lovsub_req_init
-};
-
 static struct lu_device *lovsub_device_alloc(const struct lu_env *env,
 					     struct lu_device_type *t,
 					     struct lustre_cfg *cfg)
@@ -178,7 +118,6 @@ static int lovsub_req_init(const struct lu_env *env, struct cl_device *dev,
 		if (result == 0) {
 			d = lovsub2lu_dev(lsd);
 			d->ld_ops	 = &lovsub_lu_ops;
-			lsd->acid_cl.cd_ops = &lovsub_cl_ops;
 		} else {
 			d = ERR_PTR(result);
 		}
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
index a2bac7a..011296e 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_object.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_object.c
@@ -116,11 +116,31 @@ static int lovsub_object_glimpse(const struct lu_env *env,
 	return cl_object_glimpse(env, &los->lso_super->lo_cl, lvb);
 }
 
+/**
+ * Implementation of struct cl_object_operations::coo_req_attr_set() for lovsub
+ * layer. Lov and lovsub are responsible only for struct obdo::o_stripe_idx
+ * field, which is filled there.
+ */
+static void lovsub_req_attr_set(const struct lu_env *env, struct cl_object *obj,
+				struct cl_req_attr *attr)
+{
+	struct lovsub_object *subobj = cl2lovsub(obj);
+
+	cl_req_attr_set(env, &subobj->lso_super->lo_cl, attr);
+
+	/*
+	 * There is no OBD_MD_* flag for obdo::o_stripe_idx, so set it
+	 * unconditionally. It never changes anyway.
+	 */
+	attr->cra_oa->o_stripe_idx = subobj->lso_index;
+}
+
 static const struct cl_object_operations lovsub_ops = {
 	.coo_page_init = lovsub_page_init,
 	.coo_lock_init = lovsub_lock_init,
 	.coo_attr_update = lovsub_attr_update,
-	.coo_glimpse   = lovsub_object_glimpse
+	.coo_glimpse		= lovsub_object_glimpse,
+	.coo_req_attr_set	= lovsub_req_attr_set
 };
 
 static const struct lu_object_operations lovsub_lu_obj_ops = {
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index af8e4d6..3f42457 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -1045,235 +1045,18 @@ struct cl_io *cl_io_top(struct cl_io *io)
 EXPORT_SYMBOL(cl_io_top);
 
 /**
- * Adds request slice to the compound request.
- *
- * This is called by cl_device_operations::cdo_req_init() methods to add a
- * per-layer state to the request. New state is added at the end of
- * cl_req::crq_layers list, that is, it is at the bottom of the stack.
- *
- * \see cl_lock_slice_add(), cl_page_slice_add(), cl_io_slice_add()
- */
-void cl_req_slice_add(struct cl_req *req, struct cl_req_slice *slice,
-		      struct cl_device *dev,
-		      const struct cl_req_operations *ops)
-{
-	list_add_tail(&slice->crs_linkage, &req->crq_layers);
-	slice->crs_dev = dev;
-	slice->crs_ops = ops;
-	slice->crs_req = req;
-}
-EXPORT_SYMBOL(cl_req_slice_add);
-
-static void cl_req_free(const struct lu_env *env, struct cl_req *req)
-{
-	unsigned i;
-
-	LASSERT(list_empty(&req->crq_pages));
-	LASSERT(req->crq_nrpages == 0);
-	LINVRNT(list_empty(&req->crq_layers));
-	LINVRNT(equi(req->crq_nrobjs > 0, req->crq_o));
-
-	if (req->crq_o) {
-		for (i = 0; i < req->crq_nrobjs; ++i) {
-			struct cl_object *obj = req->crq_o[i].ro_obj;
-
-			if (obj) {
-				lu_object_ref_del_at(&obj->co_lu,
-						     &req->crq_o[i].ro_obj_ref,
-						     "cl_req", req);
-				cl_object_put(env, obj);
-			}
-		}
-		kfree(req->crq_o);
-	}
-	kfree(req);
-}
-
-static int cl_req_init(const struct lu_env *env, struct cl_req *req,
-		       struct cl_page *page)
-{
-	struct cl_device     *dev;
-	struct cl_page_slice *slice;
-	int result;
-
-	result = 0;
-	list_for_each_entry(slice, &page->cp_layers, cpl_linkage) {
-		dev = lu2cl_dev(slice->cpl_obj->co_lu.lo_dev);
-		if (dev->cd_ops->cdo_req_init) {
-			result = dev->cd_ops->cdo_req_init(env, dev, req);
-			if (result != 0)
-				break;
-		}
-	}
-	return result;
-}
-
-/**
- * Invokes per-request transfer completion call-backs
- * (cl_req_operations::cro_completion()) bottom-to-top.
- */
-void cl_req_completion(const struct lu_env *env, struct cl_req *req, int rc)
-{
-	struct cl_req_slice *slice;
-
-	/*
-	 * for the lack of list_for_each_entry_reverse_safe()...
-	 */
-	while (!list_empty(&req->crq_layers)) {
-		slice = list_entry(req->crq_layers.prev,
-				   struct cl_req_slice, crs_linkage);
-		list_del_init(&slice->crs_linkage);
-		if (slice->crs_ops->cro_completion)
-			slice->crs_ops->cro_completion(env, slice, rc);
-	}
-	cl_req_free(env, req);
-}
-EXPORT_SYMBOL(cl_req_completion);
-
-/**
- * Allocates new transfer request.
- */
-struct cl_req *cl_req_alloc(const struct lu_env *env, struct cl_page *page,
-			    enum cl_req_type crt, int nr_objects)
-{
-	struct cl_req *req;
-
-	LINVRNT(nr_objects > 0);
-
-	req = kzalloc(sizeof(*req), GFP_NOFS);
-	if (req) {
-		int result;
-
-		req->crq_type = crt;
-		INIT_LIST_HEAD(&req->crq_pages);
-		INIT_LIST_HEAD(&req->crq_layers);
-
-		req->crq_o = kcalloc(nr_objects, sizeof(req->crq_o[0]),
-				     GFP_NOFS);
-		if (req->crq_o) {
-			req->crq_nrobjs = nr_objects;
-			result = cl_req_init(env, req, page);
-		} else {
-			result = -ENOMEM;
-		}
-		if (result != 0) {
-			cl_req_completion(env, req, result);
-			req = ERR_PTR(result);
-		}
-	} else {
-		req = ERR_PTR(-ENOMEM);
-	}
-	return req;
-}
-EXPORT_SYMBOL(cl_req_alloc);
-
-/**
- * Adds a page to a request.
- */
-void cl_req_page_add(const struct lu_env *env,
-		     struct cl_req *req, struct cl_page *page)
-{
-	struct cl_object  *obj;
-	struct cl_req_obj *rqo;
-	unsigned int i;
-
-	LASSERT(list_empty(&page->cp_flight));
-	LASSERT(!page->cp_req);
-
-	CL_PAGE_DEBUG(D_PAGE, env, page, "req %p, %d, %u\n",
-		      req, req->crq_type, req->crq_nrpages);
-
-	list_add_tail(&page->cp_flight, &req->crq_pages);
-	++req->crq_nrpages;
-	page->cp_req = req;
-	obj = cl_object_top(page->cp_obj);
-	for (i = 0, rqo = req->crq_o; obj != rqo->ro_obj; ++i, ++rqo) {
-		if (!rqo->ro_obj) {
-			rqo->ro_obj = obj;
-			cl_object_get(obj);
-			lu_object_ref_add_at(&obj->co_lu, &rqo->ro_obj_ref,
-					     "cl_req", req);
-			break;
-		}
-	}
-	LASSERT(i < req->crq_nrobjs);
-}
-EXPORT_SYMBOL(cl_req_page_add);
-
-/**
- * Removes a page from a request.
- */
-void cl_req_page_done(const struct lu_env *env, struct cl_page *page)
-{
-	struct cl_req *req = page->cp_req;
-
-	LASSERT(!list_empty(&page->cp_flight));
-	LASSERT(req->crq_nrpages > 0);
-
-	list_del_init(&page->cp_flight);
-	--req->crq_nrpages;
-	page->cp_req = NULL;
-}
-EXPORT_SYMBOL(cl_req_page_done);
-
-/**
- * Notifies layers that request is about to depart by calling
- * cl_req_operations::cro_prep() top-to-bottom.
- */
-int cl_req_prep(const struct lu_env *env, struct cl_req *req)
-{
-	unsigned int i;
-	int result;
-	const struct cl_req_slice *slice;
-
-	/*
-	 * Check that the caller of cl_req_alloc() didn't lie about the number
-	 * of objects.
-	 */
-	for (i = 0; i < req->crq_nrobjs; ++i)
-		LASSERT(req->crq_o[i].ro_obj);
-
-	result = 0;
-	list_for_each_entry(slice, &req->crq_layers, crs_linkage) {
-		if (slice->crs_ops->cro_prep) {
-			result = slice->crs_ops->cro_prep(env, slice);
-			if (result != 0)
-				break;
-		}
-	}
-	return result;
-}
-EXPORT_SYMBOL(cl_req_prep);
-
-/**
  * Fills in attributes that are passed to server together with transfer. Only
  * attributes from \a flags may be touched. This can be called multiple times
  * for the same request.
  */
-void cl_req_attr_set(const struct lu_env *env, struct cl_req *req,
-		     struct cl_req_attr *attr, u64 flags)
+void cl_req_attr_set(const struct lu_env *env, struct cl_object *obj,
+		     struct cl_req_attr *attr)
 {
-	const struct cl_req_slice *slice;
-	struct cl_page	    *page;
-	unsigned int i;
-
-	LASSERT(!list_empty(&req->crq_pages));
-
-	/* Take any page to use as a model. */
-	page = list_entry(req->crq_pages.next, struct cl_page, cp_flight);
-
-	for (i = 0; i < req->crq_nrobjs; ++i) {
-		list_for_each_entry(slice, &req->crq_layers, crs_linkage) {
-			const struct cl_page_slice *scan;
-			const struct cl_object     *obj;
-
-			scan = cl_page_at(page,
-					  slice->crs_dev->cd_lu_dev.ld_type);
-			obj = scan->cpl_obj;
-			if (slice->crs_ops->cro_attr_set)
-				slice->crs_ops->cro_attr_set(env, slice, obj,
-							     attr + i, flags);
-		}
+	struct cl_object *scan;
+
+	cl_object_for_each(scan, obj) {
+		if (scan->co_ops->coo_req_attr_set)
+			scan->co_ops->coo_req_attr_set(env, scan, attr);
 	}
 }
 EXPORT_SYMBOL(cl_req_attr_set);
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 40b7bee..bdc0aa5 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -99,7 +99,6 @@ static void cl_page_free(const struct lu_env *env, struct cl_page *page)
 
 	PASSERT(env, page, list_empty(&page->cp_batch));
 	PASSERT(env, page, !page->cp_owner);
-	PASSERT(env, page, !page->cp_req);
 	PASSERT(env, page, page->cp_state == CPS_FREEING);
 
 	while (!list_empty(&page->cp_layers)) {
@@ -150,7 +149,6 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
 		page->cp_type = type;
 		INIT_LIST_HEAD(&page->cp_layers);
 		INIT_LIST_HEAD(&page->cp_batch);
-		INIT_LIST_HEAD(&page->cp_flight);
 		lu_ref_init(&page->cp_reference);
 		head = o->co_lu.lo_header;
 		list_for_each_entry(o, &head->loh_layers, co_lu.lo_linkage) {
@@ -528,7 +526,6 @@ static int cl_page_own0(const struct lu_env *env, struct cl_io *io,
 					io, nonblock);
 		if (result == 0) {
 			PASSERT(env, pg, !pg->cp_owner);
-			PASSERT(env, pg, !pg->cp_req);
 			pg->cp_owner = cl_io_top(io);
 			cl_page_owner_set(pg);
 			if (pg->cp_state != CPS_FREEING) {
@@ -821,8 +818,6 @@ void cl_page_completion(const struct lu_env *env,
 	struct cl_sync_io *anchor = pg->cp_sync_io;
 
 	PASSERT(env, pg, crt < CRT_NR);
-	/* cl_page::cp_req already cleared by the caller (osc_completion()) */
-	PASSERT(env, pg, !pg->cp_req);
 	PASSERT(env, pg, pg->cp_state == cl_req_type_state(crt));
 
 	CL_PAGE_HEADER(D_TRACE, env, pg, "%d %d\n", crt, ioret);
@@ -836,16 +831,8 @@ void cl_page_completion(const struct lu_env *env,
 	if (anchor) {
 		LASSERT(pg->cp_sync_io == anchor);
 		pg->cp_sync_io = NULL;
-	}
-	/*
-	 * As page->cp_obj is pinned by a reference from page->cp_req, it is
-	 * safe to call cl_page_put() without risking object destruction in a
-	 * non-blocking context.
-	 */
-	cl_page_put(env, pg);
-
-	if (anchor)
 		cl_sync_io_note(env, anchor, ioret);
+	}
 }
 EXPORT_SYMBOL(cl_page_completion);
 
@@ -927,10 +914,10 @@ void cl_page_header_print(const struct lu_env *env, void *cookie,
 			  lu_printer_t printer, const struct cl_page *pg)
 {
 	(*printer)(env, cookie,
-		   "page@%p[%d %p %d %d %p %p]\n",
+		   "page@%p[%d %p %d %d %p]\n",
 		   pg, atomic_read(&pg->cp_ref), pg->cp_obj,
 		   pg->cp_state, pg->cp_type,
-		   pg->cp_owner, pg->cp_req);
+		   pg->cp_owner);
 }
 EXPORT_SYMBOL(cl_page_header_print);
 
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 25ecfb3..5490761 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -505,9 +505,6 @@ static int echo_object_print(const struct lu_env *env, void *cookie,
 
 /** @} echo_lu_dev_ops */
 
-static const struct cl_device_operations echo_device_cl_ops = {
-};
-
 /** \defgroup echo_init Setup and teardown
  *
  * Init and fini functions for echo client.
@@ -620,7 +617,6 @@ static void echo_session_key_fini(const struct lu_context *ctx,
 		goto out_free;
 
 	cd->cd_lu_dev.ld_ops = &echo_device_lu_ops;
-	cd->cd_ops = &echo_device_cl_ops;
 
 	obd = class_name2obd(lustre_cfg_string(cfg, 0));
 	LASSERT(obd);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index b939c9c..d17ec32 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1337,14 +1337,6 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 		 "cp_state:%u, cmd:%d\n", page->cp_state, cmd);
 	LASSERT(opg->ops_transfer_pinned);
 
-	/*
-	 * page->cp_req can be NULL if io submission failed before
-	 * cl_req was allocated.
-	 */
-	if (page->cp_req)
-		cl_req_page_done(env, page);
-	LASSERT(!page->cp_req);
-
 	crt = cmd == OBD_BRW_READ ? CRT_READ : CRT_WRITE;
 	/* Clear opg->ops_transfer_pinned before VM lock is released. */
 	opg->ops_transfer_pinned = 0;
@@ -1372,6 +1364,7 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 	lu_ref_del(&page->cp_reference, "transfer", page);
 
 	cl_page_completion(env, page, crt, rc);
+	cl_page_put(env, page);
 
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 513397a..e525110 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -86,13 +86,6 @@ struct osc_io {
 };
 
 /**
- * State of transfer for osc.
- */
-struct osc_req {
-	struct cl_req_slice    or_cl;
-};
-
-/**
  * State maintained by osc layer for the duration of a system call.
  */
 struct osc_session {
@@ -115,6 +108,7 @@ struct osc_thread_info {
 	pgoff_t			oti_next_index;
 	pgoff_t			oti_fn_index; /* first non-overlapped index */
 	struct cl_sync_io	oti_anchor;
+	struct cl_req_attr	oti_req_attr;
 };
 
 struct osc_object {
@@ -362,7 +356,6 @@ struct osc_page {
 extern struct kmem_cache *osc_object_kmem;
 extern struct kmem_cache *osc_thread_kmem;
 extern struct kmem_cache *osc_session_kmem;
-extern struct kmem_cache *osc_req_kmem;
 extern struct kmem_cache *osc_extent_kmem;
 
 extern struct lu_device_type osc_device_type;
@@ -376,8 +369,6 @@ int osc_lock_init(const struct lu_env *env,
 		  const struct cl_io *io);
 int osc_io_init(const struct lu_env *env,
 		struct cl_object *obj, struct cl_io *io);
-int osc_req_init(const struct lu_env *env, struct cl_device *dev,
-		 struct cl_req *req);
 struct lu_object *osc_object_alloc(const struct lu_env *env,
 				   const struct lu_object_header *hdr,
 				   struct lu_device *dev);
@@ -534,6 +525,16 @@ static inline pgoff_t osc_index(struct osc_page *opg)
 	return (struct osc_page *)container_of(oap, struct osc_page, ops_oap);
 }
 
+static inline struct osc_page *
+osc_cl_page_osc(struct cl_page *page, struct osc_object *osc)
+{
+	const struct cl_page_slice *slice;
+
+	LASSERT(osc);
+	slice = cl_object_page_slice(&osc->oo_cl, page);
+	return cl2osc_page(slice);
+}
+
 static inline struct osc_lock *cl2osc_lock(const struct cl_lock_slice *slice)
 {
 	LINVRNT(osc_is_object(&slice->cls_obj->co_lu));
diff --git a/drivers/staging/lustre/lustre/osc/osc_dev.c b/drivers/staging/lustre/lustre/osc/osc_dev.c
index 83d30c1..89f288b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_dev.c
+++ b/drivers/staging/lustre/lustre/osc/osc_dev.c
@@ -29,7 +29,7 @@
  * This file is part of Lustre, http://www.lustre.org/
  * Lustre is a trademark of Sun Microsystems, Inc.
  *
- * Implementation of cl_device, cl_req for OSC layer.
+ * Implementation of cl_device, for OSC layer.
  *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
  */
@@ -49,7 +49,6 @@
 struct kmem_cache *osc_object_kmem;
 struct kmem_cache *osc_thread_kmem;
 struct kmem_cache *osc_session_kmem;
-struct kmem_cache *osc_req_kmem;
 struct kmem_cache *osc_extent_kmem;
 struct kmem_cache *osc_quota_kmem;
 
@@ -75,11 +74,6 @@ struct lu_kmem_descr osc_caches[] = {
 		.ckd_size  = sizeof(struct osc_session)
 	},
 	{
-		.ckd_cache = &osc_req_kmem,
-		.ckd_name  = "osc_req_kmem",
-		.ckd_size  = sizeof(struct osc_req)
-	},
-	{
 		.ckd_cache = &osc_extent_kmem,
 		.ckd_name  = "osc_extent_kmem",
 		.ckd_size  = sizeof(struct osc_extent)
@@ -178,10 +172,6 @@ static int osc_cl_process_config(const struct lu_env *env,
 	.ldo_recovery_complete = NULL
 };
 
-static const struct cl_device_operations osc_cl_ops = {
-	.cdo_req_init = osc_req_init
-};
-
 static int osc_device_init(const struct lu_env *env, struct lu_device *d,
 			   const char *name, struct lu_device *next)
 {
@@ -220,7 +210,6 @@ static int osc_device_init(const struct lu_env *env, struct lu_device *d,
 	cl_device_init(&od->od_cl, t);
 	d = osc2lu_dev(od);
 	d->ld_ops = &osc_lu_ops;
-	od->od_cl.cd_ops = &osc_cl_ops;
 
 	/* Setup OSC OBD */
 	obd = class_name2obd(lustre_cfg_string(cfg, 0));
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index e0f81a4..439ba64 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -49,12 +49,6 @@
  *
  */
 
-static struct osc_req *cl2osc_req(const struct cl_req_slice *slice)
-{
-	LINVRNT(slice->crs_dev->cd_lu_dev.ld_type == &osc_device_type);
-	return container_of0(slice, struct osc_req, or_cl);
-}
-
 static struct osc_io *cl2osc_io(const struct lu_env *env,
 				const struct cl_io_slice *slice)
 {
@@ -64,20 +58,6 @@
 	return oio;
 }
 
-static struct osc_page *osc_cl_page_osc(struct cl_page *page,
-					struct osc_object *osc)
-{
-	const struct cl_page_slice *slice;
-
-	if (osc)
-		slice = cl_object_page_slice(&osc->oo_cl, page);
-	else
-		slice = cl_page_at(page, &osc_device_type);
-	LASSERT(slice);
-
-	return cl2osc_page(slice);
-}
-
 /*****************************************************************************
  *
  * io operations.
@@ -894,103 +874,6 @@ static void osc_io_end(const struct lu_env *env,
  *
  */
 
-static int osc_req_prep(const struct lu_env *env,
-			const struct cl_req_slice *slice)
-{
-	return 0;
-}
-
-static void osc_req_completion(const struct lu_env *env,
-			       const struct cl_req_slice *slice, int ioret)
-{
-	struct osc_req *or;
-
-	or = cl2osc_req(slice);
-	kmem_cache_free(osc_req_kmem, or);
-}
-
-/**
- * Implementation of struct cl_req_operations::cro_attr_set() for osc
- * layer. osc is responsible for struct obdo::o_id and struct obdo::o_seq
- * fields.
- */
-static void osc_req_attr_set(const struct lu_env *env,
-			     const struct cl_req_slice *slice,
-			     const struct cl_object *obj,
-			     struct cl_req_attr *attr, u64 flags)
-{
-	struct lov_oinfo *oinfo;
-	struct cl_req *clerq;
-	struct cl_page *apage; /* _some_ page in @clerq */
-	struct ldlm_lock *lock;  /* _some_ lock protecting @apage */
-	struct osc_page *opg;
-	struct obdo *oa;
-	struct ost_lvb *lvb;
-
-	oinfo = cl2osc(obj)->oo_oinfo;
-	lvb = &oinfo->loi_lvb;
-	oa = attr->cra_oa;
-
-	if ((flags & OBD_MD_FLMTIME) != 0) {
-		oa->o_mtime = lvb->lvb_mtime;
-		oa->o_valid |= OBD_MD_FLMTIME;
-	}
-	if ((flags & OBD_MD_FLATIME) != 0) {
-		oa->o_atime = lvb->lvb_atime;
-		oa->o_valid |= OBD_MD_FLATIME;
-	}
-	if ((flags & OBD_MD_FLCTIME) != 0) {
-		oa->o_ctime = lvb->lvb_ctime;
-		oa->o_valid |= OBD_MD_FLCTIME;
-	}
-	if (flags & OBD_MD_FLGROUP) {
-		ostid_set_seq(&oa->o_oi, ostid_seq(&oinfo->loi_oi));
-		oa->o_valid |= OBD_MD_FLGROUP;
-	}
-	if (flags & OBD_MD_FLID) {
-		ostid_set_id(&oa->o_oi, ostid_id(&oinfo->loi_oi));
-		oa->o_valid |= OBD_MD_FLID;
-	}
-	if (flags & OBD_MD_FLHANDLE) {
-		clerq = slice->crs_req;
-		LASSERT(!list_empty(&clerq->crq_pages));
-		apage = container_of(clerq->crq_pages.next,
-				     struct cl_page, cp_flight);
-		opg = osc_cl_page_osc(apage, NULL);
-		lock = osc_dlmlock_at_pgoff(env, cl2osc(obj), osc_index(opg),
-					    OSC_DAP_FL_TEST_LOCK | OSC_DAP_FL_CANCELING);
-		if (!lock && !opg->ops_srvlock) {
-			struct ldlm_resource *res;
-			struct ldlm_res_id *resname;
-
-			CL_PAGE_DEBUG(D_ERROR, env, apage, "uncovered page!\n");
-
-			resname = &osc_env_info(env)->oti_resname;
-			ostid_build_res_name(&oinfo->loi_oi, resname);
-			res = ldlm_resource_get(
-				osc_export(cl2osc(obj))->exp_obd->obd_namespace,
-				NULL, resname, LDLM_EXTENT, 0);
-			ldlm_resource_dump(D_ERROR, res);
-
-			dump_stack();
-			LBUG();
-		}
-
-		/* check for lockless io. */
-		if (lock) {
-			oa->o_handle = lock->l_remote_handle;
-			oa->o_valid |= OBD_MD_FLHANDLE;
-			LDLM_LOCK_PUT(lock);
-		}
-	}
-}
-
-static const struct cl_req_operations osc_req_ops = {
-	.cro_prep       = osc_req_prep,
-	.cro_attr_set   = osc_req_attr_set,
-	.cro_completion = osc_req_completion
-};
-
 int osc_io_init(const struct lu_env *env,
 		struct cl_object *obj, struct cl_io *io)
 {
@@ -1001,20 +884,4 @@ int osc_io_init(const struct lu_env *env,
 	return 0;
 }
 
-int osc_req_init(const struct lu_env *env, struct cl_device *dev,
-		 struct cl_req *req)
-{
-	struct osc_req *or;
-	int result;
-
-	or = kmem_cache_zalloc(osc_req_kmem, GFP_NOFS);
-	if (or) {
-		cl_req_slice_add(req, &or->or_cl, dev, &osc_req_ops);
-		result = 0;
-	} else {
-		result = -ENOMEM;
-	}
-	return result;
-}
-
 /** @} osc */
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index a6dafbf..ca1f8cd 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -335,6 +335,76 @@ int osc_object_is_contended(struct osc_object *obj)
 	return 1;
 }
 
+/**
+ * Implementation of struct cl_object_operations::coo_req_attr_set() for osc
+ * layer. osc is responsible for struct obdo::o_id and struct obdo::o_seq
+ * fields.
+ */
+static void osc_req_attr_set(const struct lu_env *env, struct cl_object *obj,
+			     struct cl_req_attr *attr)
+{
+	u64 flags = attr->cra_flags;
+	struct lov_oinfo *oinfo;
+	struct ost_lvb *lvb;
+	struct obdo *oa;
+
+	oinfo = cl2osc(obj)->oo_oinfo;
+	lvb = &oinfo->loi_lvb;
+	oa = attr->cra_oa;
+
+	if (flags & OBD_MD_FLMTIME) {
+		oa->o_mtime = lvb->lvb_mtime;
+		oa->o_valid |= OBD_MD_FLMTIME;
+	}
+	if (flags & OBD_MD_FLATIME) {
+		oa->o_atime = lvb->lvb_atime;
+		oa->o_valid |= OBD_MD_FLATIME;
+	}
+	if (flags & OBD_MD_FLCTIME) {
+		oa->o_ctime = lvb->lvb_ctime;
+		oa->o_valid |= OBD_MD_FLCTIME;
+	}
+	if (flags & OBD_MD_FLGROUP) {
+		ostid_set_seq(&oa->o_oi, ostid_seq(&oinfo->loi_oi));
+		oa->o_valid |= OBD_MD_FLGROUP;
+	}
+	if (flags & OBD_MD_FLID) {
+		ostid_set_id(&oa->o_oi, ostid_id(&oinfo->loi_oi));
+		oa->o_valid |= OBD_MD_FLID;
+	}
+	if (flags & OBD_MD_FLHANDLE) {
+		struct ldlm_lock *lock;
+		struct osc_page *opg;
+
+		opg = osc_cl_page_osc(attr->cra_page, cl2osc(obj));
+		lock = osc_dlmlock_at_pgoff(env, cl2osc(obj), osc_index(opg),
+					    OSC_DAP_FL_TEST_LOCK | OSC_DAP_FL_CANCELING);
+		if (!lock && !opg->ops_srvlock) {
+			struct ldlm_resource *res;
+			struct ldlm_res_id *resname;
+
+			CL_PAGE_DEBUG(D_ERROR, env, attr->cra_page,
+				      "uncovered page!\n");
+
+			resname = &osc_env_info(env)->oti_resname;
+			ostid_build_res_name(&oinfo->loi_oi, resname);
+			res = ldlm_resource_get(
+				osc_export(cl2osc(obj))->exp_obd->obd_namespace,
+				NULL, resname, LDLM_EXTENT, 0);
+			ldlm_resource_dump(D_ERROR, res);
+
+			LBUG();
+		}
+
+		/* check for lockless io. */
+		if (lock) {
+			oa->o_handle = lock->l_remote_handle;
+			oa->o_valid |= OBD_MD_FLHANDLE;
+			LDLM_LOCK_PUT(lock);
+		}
+	}
+}
+
 static const struct cl_object_operations osc_ops = {
 	.coo_page_init = osc_page_init,
 	.coo_lock_init = osc_lock_init,
@@ -343,7 +413,8 @@ int osc_object_is_contended(struct osc_object *obj)
 	.coo_attr_update = osc_attr_update,
 	.coo_glimpse   = osc_object_glimpse,
 	.coo_prune	 = osc_object_prune,
-	.coo_fiemap	 = osc_object_fiemap,
+	.coo_fiemap		= osc_object_fiemap,
+	.coo_req_attr_set	= osc_req_attr_set
 };
 
 static const struct lu_object_operations osc_lu_obj_ops = {
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 3daca63..9b0b94b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -68,7 +68,6 @@ struct osc_brw_async_args {
 	struct client_obd *aa_cli;
 	struct list_head	 aa_oaps;
 	struct list_head	 aa_exts;
-	struct cl_req     *aa_clerq;
 };
 
 struct osc_async_args {
@@ -1600,8 +1599,6 @@ static int brw_interpret(const struct lu_env *env,
 	LASSERT(list_empty(&aa->aa_exts));
 	LASSERT(list_empty(&aa->aa_oaps));
 
-	cl_req_completion(env, aa->aa_clerq, rc < 0 ? rc :
-			  req->rq_bulk->bd_nob_transferred);
 	osc_release_ppga(aa->aa_ppga, aa->aa_page_count);
 	ptlrpc_lprocfs_brw(req, req->rq_bulk->bd_nob_transferred);
 
@@ -1654,9 +1651,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	struct osc_brw_async_args *aa = NULL;
 	struct obdo *oa = NULL;
 	struct osc_async_page *oap;
-	struct osc_async_page *tmp;
-	struct cl_req *clerq = NULL;
-	enum cl_req_type crt = (cmd & OBD_BRW_WRITE) ? CRT_WRITE : CRT_READ;
+	struct osc_object *obj = NULL;
 	struct cl_req_attr *crattr = NULL;
 	u64 starting_offset = OBD_OBJECT_EOF;
 	u64 ending_offset = 0;
@@ -1664,6 +1659,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	int mem_tight = 0;
 	int page_count = 0;
 	bool soft_sync = false;
+	bool interrupted = false;
 	int i;
 	int rc;
 	struct ost_body *body;
@@ -1675,32 +1671,15 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	list_for_each_entry(ext, ext_list, oe_link) {
 		LASSERT(ext->oe_state == OES_RPC);
 		mem_tight |= ext->oe_memalloc;
-		list_for_each_entry(oap, &ext->oe_pages, oap_pending_item) {
-			++page_count;
-			list_add_tail(&oap->oap_rpc_item, &rpc_list);
-			if (starting_offset > oap->oap_obj_off)
-				starting_offset = oap->oap_obj_off;
-			else
-				LASSERT(oap->oap_page_off == 0);
-			if (ending_offset < oap->oap_obj_off + oap->oap_count)
-				ending_offset = oap->oap_obj_off +
-						oap->oap_count;
-			else
-				LASSERT(oap->oap_page_off + oap->oap_count ==
-					PAGE_SIZE);
-		}
+		page_count += ext->oe_nr_pages;
+		if (!obj)
+			obj = ext->oe_obj;
 	}
 
 	soft_sync = osc_over_unstable_soft_limit(cli);
 	if (mem_tight)
 		mpflag = cfs_memory_pressure_get_and_set();
 
-	crattr = kzalloc(sizeof(*crattr), GFP_NOFS);
-	if (!crattr) {
-		rc = -ENOMEM;
-		goto out;
-	}
-
 	pga = kcalloc(page_count, sizeof(*pga), GFP_NOFS);
 	if (!pga) {
 		rc = -ENOMEM;
@@ -1714,40 +1693,43 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	}
 
 	i = 0;
-	list_for_each_entry(oap, &rpc_list, oap_rpc_item) {
-		struct cl_page *page = oap2cl_page(oap);
-
-		if (!clerq) {
-			clerq = cl_req_alloc(env, page, crt,
-					     1 /* only 1-object rpcs for now */);
-			if (IS_ERR(clerq)) {
-				rc = PTR_ERR(clerq);
-				goto out;
-			}
+	list_for_each_entry(ext, ext_list, oe_link) {
+		list_for_each_entry(oap, &ext->oe_pages, oap_pending_item) {
+			if (mem_tight)
+				oap->oap_brw_flags |= OBD_BRW_MEMALLOC;
+			if (soft_sync)
+				oap->oap_brw_flags |= OBD_BRW_SOFT_SYNC;
+			pga[i] = &oap->oap_brw_page;
+			pga[i]->off = oap->oap_obj_off + oap->oap_page_off;
+			i++;
+
+			list_add_tail(&oap->oap_rpc_item, &rpc_list);
+			if (starting_offset == OBD_OBJECT_EOF ||
+			    starting_offset > oap->oap_obj_off)
+				starting_offset = oap->oap_obj_off;
+			else
+				LASSERT(!oap->oap_page_off);
+			if (ending_offset < oap->oap_obj_off + oap->oap_count)
+				ending_offset = oap->oap_obj_off +
+						oap->oap_count;
+			else
+				LASSERT(oap->oap_page_off + oap->oap_count ==
+					PAGE_SIZE);
+			if (oap->oap_interrupted)
+				interrupted = true;
 		}
-		if (mem_tight)
-			oap->oap_brw_flags |= OBD_BRW_MEMALLOC;
-		if (soft_sync)
-			oap->oap_brw_flags |= OBD_BRW_SOFT_SYNC;
-		pga[i] = &oap->oap_brw_page;
-		pga[i]->off = oap->oap_obj_off + oap->oap_page_off;
-		CDEBUG(0, "put page %p index %lu oap %p flg %x to pga\n",
-		       pga[i]->pg, oap->oap_page->index, oap,
-		       pga[i]->flag);
-		i++;
-		cl_req_page_add(env, clerq, page);
 	}
 
-	/* always get the data for the obdo for the rpc */
-	LASSERT(clerq);
-	crattr->cra_oa = oa;
-	cl_req_attr_set(env, clerq, crattr, ~0ULL);
+	/* first page in the list */
+	oap = list_entry(rpc_list.next, typeof(*oap), oap_rpc_item);
 
-	rc = cl_req_prep(env, clerq);
-	if (rc != 0) {
-		CERROR("cl_req_prep failed: %d\n", rc);
-		goto out;
-	}
+	crattr = &osc_env_info(env)->oti_req_attr;
+	memset(crattr, 0, sizeof(*crattr));
+	crattr->cra_type = (cmd & OBD_BRW_WRITE) ? CRT_WRITE : CRT_READ;
+	crattr->cra_flags = ~0ULL;
+	crattr->cra_page = oap2cl_page(oap);
+	crattr->cra_oa = oa;
+	cl_req_attr_set(env, osc2cl(obj), crattr);
 
 	sort_brw_pages(pga, page_count);
 	rc = osc_brw_prep_request(cmd, cli, oa, page_count, pga, &req, 1, 0);
@@ -1759,8 +1741,10 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	req->rq_commit_cb = brw_commit;
 	req->rq_interpret_reply = brw_interpret;
 
-	if (mem_tight != 0)
-		req->rq_memalloc = 1;
+	req->rq_memalloc = mem_tight != 0;
+	oap->oap_request = ptlrpc_request_addref(req);
+	if (interrupted && !req->rq_intr)
+		ptlrpc_mark_interrupted(req);
 
 	/* Need to update the timestamps after the request is built in case
 	 * we race with setattr (locally or in queue at OST).  If OST gets
@@ -1770,9 +1754,8 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	 */
 	body = req_capsule_client_get(&req->rq_pill, &RMF_OST_BODY);
 	crattr->cra_oa = &body->oa;
-	cl_req_attr_set(env, clerq, crattr,
-			OBD_MD_FLMTIME | OBD_MD_FLCTIME | OBD_MD_FLATIME);
-
+	crattr->cra_flags = OBD_MD_FLMTIME | OBD_MD_FLCTIME | OBD_MD_FLATIME;
+	cl_req_attr_set(env, osc2cl(obj), crattr);
 	lustre_msg_set_jobid(req->rq_reqmsg, crattr->cra_jobid);
 
 	CLASSERT(sizeof(*aa) <= sizeof(req->rq_async_args));
@@ -1781,24 +1764,6 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	list_splice_init(&rpc_list, &aa->aa_oaps);
 	INIT_LIST_HEAD(&aa->aa_exts);
 	list_splice_init(ext_list, &aa->aa_exts);
-	aa->aa_clerq = clerq;
-
-	/* queued sync pages can be torn down while the pages
-	 * were between the pending list and the rpc
-	 */
-	tmp = NULL;
-	list_for_each_entry(oap, &aa->aa_oaps, oap_rpc_item) {
-		/* only one oap gets a request reference */
-		if (!tmp)
-			tmp = oap;
-		if (oap->oap_interrupted && !req->rq_intr) {
-			CDEBUG(D_INODE, "oap %p in req %p interrupted\n",
-			       oap, req);
-			ptlrpc_mark_interrupted(req);
-		}
-	}
-	if (tmp)
-		tmp->oap_request = ptlrpc_request_addref(req);
 
 	spin_lock(&cli->cl_loi_list_lock);
 	starting_offset >>= PAGE_SHIFT;
@@ -1829,8 +1794,6 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	if (mem_tight != 0)
 		cfs_memory_pressure_restore(mpflag);
 
-	kfree(crattr);
-
 	if (rc != 0) {
 		LASSERT(!req);
 
@@ -1846,8 +1809,6 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 			list_del_init(&ext->oe_link);
 			osc_extent_finish(env, ext, 0, rc);
 		}
-		if (clerq && !IS_ERR(clerq))
-			cl_req_completion(env, clerq, rc);
 	}
 	return rc;
 }
-- 
1.7.1
