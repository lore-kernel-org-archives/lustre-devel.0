From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri, 26 Feb 2016 01:49:50 -0500
Subject: [lustre-devel] [PATCH 02/25] staging/lustre/include: Fix style of
	function declarations
In-Reply-To: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
References: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456469413-931943-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This mostly fixes checkpatch complaints about
"Alignment should match open parenthesis" and
"space prohibited between function name and open parenthesis"

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  | 410 ++++++++++-----------
 .../staging/lustre/lustre/include/lprocfs_status.h |   6 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |  10 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h |   2 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |  19 +-
 .../lustre/lustre/include/lustre_req_layout.h      |   4 +-
 drivers/staging/lustre/lustre/include/lustre_sec.h | 128 +++----
 drivers/staging/lustre/lustre/include/obd.h        |   6 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |  14 +-
 9 files changed, 281 insertions(+), 318 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 2a77ea2f8..4b3055d 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -322,7 +322,7 @@ struct cl_object_operations {
 	 *	 to be used instead of newly created.
 	 */
 	int  (*coo_page_init)(const struct lu_env *env, struct cl_object *obj,
-				struct cl_page *page, struct page *vmpage);
+			      struct cl_page *page, struct page *vmpage);
 	/**
 	 * Initialize lock slice for this layer. Called top-to-bottom through
 	 * every object layer when a new cl_lock is instantiated. Layer
@@ -849,7 +849,7 @@ struct cl_page_operations {
 	 * \return the underlying VM page. Optional.
 	 */
 	struct page *(*cpo_vmpage)(const struct lu_env *env,
-				  const struct cl_page_slice *slice);
+				   const struct cl_page_slice *slice);
 	/**
 	 * Called when \a io acquires this page into the exclusive
 	 * ownership. When this method returns, it is guaranteed that the is
@@ -2051,8 +2051,8 @@ struct cl_io_operations {
 		 *
 		 * \see cl_io_operations::cio_iter_fini()
 		 */
-		int (*cio_iter_init) (const struct lu_env *env,
-				      const struct cl_io_slice *slice);
+		int (*cio_iter_init)(const struct lu_env *env,
+				     const struct cl_io_slice *slice);
 		/**
 		 * Finalize io iteration.
 		 *
@@ -2062,8 +2062,8 @@ struct cl_io_operations {
 		 *
 		 * \see cl_io_operations::cio_iter_init()
 		 */
-		void (*cio_iter_fini) (const struct lu_env *env,
-				       const struct cl_io_slice *slice);
+		void (*cio_iter_fini)(const struct lu_env *env,
+				      const struct cl_io_slice *slice);
 		/**
 		 * Collect locks for the current iteration of io.
 		 *
@@ -2073,8 +2073,8 @@ struct cl_io_operations {
 		 * cl_io_lock_add(). Once all locks are collected, they are
 		 * sorted and enqueued in the proper order.
 		 */
-		int  (*cio_lock) (const struct lu_env *env,
-				  const struct cl_io_slice *slice);
+		int  (*cio_lock)(const struct lu_env *env,
+				 const struct cl_io_slice *slice);
 		/**
 		 * Finalize unlocking.
 		 *
@@ -2099,8 +2099,8 @@ struct cl_io_operations {
 		 * Called top-to-bottom at the end of io loop. Here layer
 		 * might wait for an unfinished asynchronous io.
 		 */
-		void (*cio_end)  (const struct lu_env *env,
-				  const struct cl_io_slice *slice);
+		void (*cio_end)(const struct lu_env *env,
+				const struct cl_io_slice *slice);
 		/**
 		 * Called bottom-to-top to notify layers that read/write IO
 		 * iteration finished, with \a nob bytes transferred.
@@ -2111,8 +2111,8 @@ struct cl_io_operations {
 		/**
 		 * Called once per io, bottom-to-top to release io resources.
 		 */
-		void (*cio_fini) (const struct lu_env *env,
-				  const struct cl_io_slice *slice);
+		void (*cio_fini)(const struct lu_env *env,
+				 const struct cl_io_slice *slice);
 	} op[CIT_OP_NR];
 	struct {
 		/**
@@ -2232,7 +2232,7 @@ struct cl_io_lock_link {
 	struct cl_lock      *cill_lock;
 	/** optional destructor */
 	void	       (*cill_fini)(const struct lu_env *env,
-					struct cl_io_lock_link *link);
+				    struct cl_io_lock_link *link);
 };
 
 /**
@@ -2613,7 +2613,7 @@ struct cache_stats {
 };
 
 /** These are not exported so far */
-void cache_stats_init (struct cache_stats *cs, const char *name);
+void cache_stats_init(struct cache_stats *cs, const char *name);
 
 /**
  * Client-side site. This represents particular client stack. "Global"
@@ -2637,8 +2637,8 @@ struct cl_site {
 	atomic_t	  cs_locks_state[CLS_NR];
 };
 
-int  cl_site_init (struct cl_site *s, struct cl_device *top);
-void cl_site_fini (struct cl_site *s);
+int  cl_site_init(struct cl_site *s, struct cl_device *top);
+void cl_site_fini(struct cl_site *s);
 void cl_stack_fini(const struct lu_env *env, struct cl_device *cl);
 
 /**
@@ -2740,26 +2740,26 @@ void cl_req_slice_add(struct cl_req *req, struct cl_req_slice *slice,
 /** \defgroup cl_object cl_object
  * @{
  */
-struct cl_object *cl_object_top (struct cl_object *o);
+struct cl_object *cl_object_top(struct cl_object *o);
 struct cl_object *cl_object_find(const struct lu_env *env, struct cl_device *cd,
 				 const struct lu_fid *fid,
 				 const struct cl_object_conf *c);
 
 int  cl_object_header_init(struct cl_object_header *h);
-void cl_object_put	(const struct lu_env *env, struct cl_object *o);
-void cl_object_get	(struct cl_object *o);
-void cl_object_attr_lock  (struct cl_object *o);
+void cl_object_put(const struct lu_env *env, struct cl_object *o);
+void cl_object_get(struct cl_object *o);
+void cl_object_attr_lock(struct cl_object *o);
 void cl_object_attr_unlock(struct cl_object *o);
-int  cl_object_attr_get   (const struct lu_env *env, struct cl_object *obj,
-			   struct cl_attr *attr);
-int  cl_object_attr_set   (const struct lu_env *env, struct cl_object *obj,
-			   const struct cl_attr *attr, unsigned valid);
-int  cl_object_glimpse    (const struct lu_env *env, struct cl_object *obj,
-			   struct ost_lvb *lvb);
-int  cl_conf_set	  (const struct lu_env *env, struct cl_object *obj,
-			   const struct cl_object_conf *conf);
-void cl_object_prune      (const struct lu_env *env, struct cl_object *obj);
-void cl_object_kill       (const struct lu_env *env, struct cl_object *obj);
+int  cl_object_attr_get(const struct lu_env *env, struct cl_object *obj,
+			struct cl_attr *attr);
+int  cl_object_attr_set(const struct lu_env *env, struct cl_object *obj,
+			const struct cl_attr *attr, unsigned valid);
+int  cl_object_glimpse(const struct lu_env *env, struct cl_object *obj,
+		       struct ost_lvb *lvb);
+int  cl_conf_set(const struct lu_env *env, struct cl_object *obj,
+		 const struct cl_object_conf *conf);
+void cl_object_prune(const struct lu_env *env, struct cl_object *obj);
+void cl_object_kill(const struct lu_env *env, struct cl_object *obj);
 
 /**
  * Returns true, iff \a o0 and \a o1 are slices of the same object.
@@ -2796,34 +2796,26 @@ enum {
 /* callback of cl_page_gang_lookup() */
 typedef int   (*cl_page_gang_cb_t)  (const struct lu_env *, struct cl_io *,
 				     struct cl_page *, void *);
-int	     cl_page_gang_lookup (const struct lu_env *env,
-				     struct cl_object *obj,
-				     struct cl_io *io,
-				     pgoff_t start, pgoff_t end,
-				     cl_page_gang_cb_t cb, void *cbdata);
-struct cl_page *cl_page_lookup      (struct cl_object_header *hdr,
-				     pgoff_t index);
-struct cl_page *cl_page_find	(const struct lu_env *env,
-				     struct cl_object *obj,
-				     pgoff_t idx, struct page *vmpage,
-				     enum cl_page_type type);
-struct cl_page *cl_page_find_sub    (const struct lu_env *env,
-				     struct cl_object *obj,
-				     pgoff_t idx, struct page *vmpage,
+int cl_page_gang_lookup(const struct lu_env *env, struct cl_object *obj,
+			struct cl_io *io, pgoff_t start, pgoff_t end,
+			cl_page_gang_cb_t cb, void *cbdata);
+struct cl_page *cl_page_lookup(struct cl_object_header *hdr, pgoff_t index);
+struct cl_page *cl_page_find(const struct lu_env *env, struct cl_object *obj,
+			     pgoff_t idx, struct page *vmpage,
+			     enum cl_page_type type);
+struct cl_page *cl_page_find_sub(const struct lu_env *env,
+				 struct cl_object *obj,
+				 pgoff_t idx, struct page *vmpage,
 				     struct cl_page *parent);
-void	    cl_page_get	 (struct cl_page *page);
-void	    cl_page_put	 (const struct lu_env *env,
-				     struct cl_page *page);
-void	    cl_page_print       (const struct lu_env *env, void *cookie,
-				     lu_printer_t printer,
-				     const struct cl_page *pg);
-void	    cl_page_header_print(const struct lu_env *env, void *cookie,
-				     lu_printer_t printer,
-				     const struct cl_page *pg);
-struct page     *cl_page_vmpage      (const struct lu_env *env,
-				     struct cl_page *page);
-struct cl_page *cl_vmpage_page      (struct page *vmpage, struct cl_object *obj);
-struct cl_page *cl_page_top	 (struct cl_page *page);
+void cl_page_get(struct cl_page *page);
+void cl_page_put(const struct lu_env *env, struct cl_page *page);
+void cl_page_print(const struct lu_env *env, void *cookie, lu_printer_t printer,
+		   const struct cl_page *pg);
+void cl_page_header_print(const struct lu_env *env, void *cookie,
+			  lu_printer_t printer, const struct cl_page *pg);
+struct page *cl_page_vmpage(const struct lu_env *env, struct cl_page *page);
+struct cl_page *cl_vmpage_page(struct page *vmpage, struct cl_object *obj);
+struct cl_page *cl_page_top(struct cl_page *page);
 
 const struct cl_page_slice *cl_page_at(const struct cl_page *page,
 				       const struct lu_device_type *dtype);
@@ -2835,17 +2827,17 @@ const struct cl_page_slice *cl_page_at(const struct cl_page *page,
  */
 /** @{ */
 
-int  cl_page_own	(const struct lu_env *env,
-			 struct cl_io *io, struct cl_page *page);
-int  cl_page_own_try    (const struct lu_env *env,
-			 struct cl_io *io, struct cl_page *page);
-void cl_page_assume     (const struct lu_env *env,
-			 struct cl_io *io, struct cl_page *page);
-void cl_page_unassume   (const struct lu_env *env,
-			 struct cl_io *io, struct cl_page *pg);
-void cl_page_disown     (const struct lu_env *env,
-			 struct cl_io *io, struct cl_page *page);
-int  cl_page_is_owned   (const struct cl_page *pg, const struct cl_io *io);
+int cl_page_own(const struct lu_env *env,
+		struct cl_io *io, struct cl_page *page);
+int cl_page_own_try(const struct lu_env *env,
+		    struct cl_io *io, struct cl_page *page);
+void cl_page_assume(const struct lu_env *env,
+		    struct cl_io *io, struct cl_page *page);
+void cl_page_unassume(const struct lu_env *env,
+		      struct cl_io *io, struct cl_page *pg);
+void cl_page_disown(const struct lu_env *env,
+		    struct cl_io *io, struct cl_page *page);
+int cl_page_is_owned(const struct cl_page *pg, const struct cl_io *io);
 
 /** @} ownership */
 
@@ -2856,19 +2848,19 @@ int  cl_page_is_owned   (const struct cl_page *pg, const struct cl_io *io);
  * tracking transfer state.
  */
 /** @{ */
-int  cl_page_prep       (const struct lu_env *env, struct cl_io *io,
-			 struct cl_page *pg, enum cl_req_type crt);
-void cl_page_completion (const struct lu_env *env,
-			 struct cl_page *pg, enum cl_req_type crt, int ioret);
-int  cl_page_make_ready (const struct lu_env *env, struct cl_page *pg,
-			 enum cl_req_type crt);
-int  cl_page_cache_add  (const struct lu_env *env, struct cl_io *io,
-			 struct cl_page *pg, enum cl_req_type crt);
-void cl_page_clip       (const struct lu_env *env, struct cl_page *pg,
-			 int from, int to);
-int  cl_page_cancel     (const struct lu_env *env, struct cl_page *page);
-int  cl_page_flush      (const struct lu_env *env, struct cl_io *io,
-			 struct cl_page *pg);
+int cl_page_prep(const struct lu_env *env, struct cl_io *io,
+		 struct cl_page *pg, enum cl_req_type crt);
+void cl_page_completion(const struct lu_env *env,
+			struct cl_page *pg, enum cl_req_type crt, int ioret);
+int cl_page_make_ready(const struct lu_env *env, struct cl_page *pg,
+		       enum cl_req_type crt);
+int cl_page_cache_add(const struct lu_env *env, struct cl_io *io,
+		      struct cl_page *pg, enum cl_req_type crt);
+void cl_page_clip(const struct lu_env *env, struct cl_page *pg,
+		  int from, int to);
+int cl_page_cancel(const struct lu_env *env, struct cl_page *page);
+int cl_page_flush(const struct lu_env *env, struct cl_io *io,
+		  struct cl_page *pg);
 
 /** @} transfer */
 
@@ -2877,24 +2869,22 @@ int  cl_page_flush      (const struct lu_env *env, struct cl_io *io,
  * Functions to discard, delete and export a cl_page.
  */
 /** @{ */
-void    cl_page_discard      (const struct lu_env *env, struct cl_io *io,
-			      struct cl_page *pg);
-void    cl_page_delete       (const struct lu_env *env, struct cl_page *pg);
-int     cl_page_unmap	(const struct lu_env *env, struct cl_io *io,
-			      struct cl_page *pg);
-int     cl_page_is_vmlocked  (const struct lu_env *env,
-			      const struct cl_page *pg);
-void    cl_page_export       (const struct lu_env *env,
-			      struct cl_page *pg, int uptodate);
-int     cl_page_is_under_lock(const struct lu_env *env, struct cl_io *io,
-			      struct cl_page *page);
-loff_t  cl_offset	    (const struct cl_object *obj, pgoff_t idx);
-pgoff_t cl_index	     (const struct cl_object *obj, loff_t offset);
-int     cl_page_size	 (const struct cl_object *obj);
-int     cl_pages_prune       (const struct lu_env *env, struct cl_object *obj);
-
-void cl_lock_print      (const struct lu_env *env, void *cookie,
-			 lu_printer_t printer, const struct cl_lock *lock);
+void cl_page_discard(const struct lu_env *env, struct cl_io *io,
+		     struct cl_page *pg);
+void cl_page_delete(const struct lu_env *env, struct cl_page *pg);
+int cl_page_unmap(const struct lu_env *env, struct cl_io *io,
+		  struct cl_page *pg);
+int cl_page_is_vmlocked(const struct lu_env *env, const struct cl_page *pg);
+void cl_page_export(const struct lu_env *env, struct cl_page *pg, int uptodate);
+int cl_page_is_under_lock(const struct lu_env *env, struct cl_io *io,
+			  struct cl_page *page);
+loff_t cl_offset(const struct cl_object *obj, pgoff_t idx);
+pgoff_t cl_index(const struct cl_object *obj, loff_t offset);
+int cl_page_size(const struct cl_object *obj);
+int cl_pages_prune(const struct lu_env *env, struct cl_object *obj);
+
+void cl_lock_print(const struct lu_env *env, void *cookie,
+		   lu_printer_t printer, const struct cl_lock *lock);
 void cl_lock_descr_print(const struct lu_env *env, void *cookie,
 			 lu_printer_t printer,
 			 const struct cl_lock_descr *descr);
@@ -2933,19 +2923,19 @@ static inline struct cl_lock *cl_lock_at_page(const struct lu_env *env,
 const struct cl_lock_slice *cl_lock_at(const struct cl_lock *lock,
 				       const struct lu_device_type *dtype);
 
-void  cl_lock_get       (struct cl_lock *lock);
-void  cl_lock_get_trust (struct cl_lock *lock);
-void  cl_lock_put       (const struct lu_env *env, struct cl_lock *lock);
-void  cl_lock_hold_add  (const struct lu_env *env, struct cl_lock *lock,
-			 const char *scope, const void *source);
+void cl_lock_get(struct cl_lock *lock);
+void cl_lock_get_trust(struct cl_lock *lock);
+void cl_lock_put(const struct lu_env *env, struct cl_lock *lock);
+void cl_lock_hold_add(const struct lu_env *env, struct cl_lock *lock,
+		      const char *scope, const void *source);
 void cl_lock_hold_release(const struct lu_env *env, struct cl_lock *lock,
 			  const char *scope, const void *source);
-void  cl_lock_unhold    (const struct lu_env *env, struct cl_lock *lock,
-			 const char *scope, const void *source);
-void  cl_lock_release   (const struct lu_env *env, struct cl_lock *lock,
-			 const char *scope, const void *source);
-void  cl_lock_user_add  (const struct lu_env *env, struct cl_lock *lock);
-void  cl_lock_user_del  (const struct lu_env *env, struct cl_lock *lock);
+void cl_lock_unhold(const struct lu_env *env, struct cl_lock *lock,
+		    const char *scope, const void *source);
+void cl_lock_release(const struct lu_env *env, struct cl_lock *lock,
+		     const char *scope, const void *source);
+void cl_lock_user_add(const struct lu_env *env, struct cl_lock *lock);
+void cl_lock_user_del(const struct lu_env *env, struct cl_lock *lock);
 
 int cl_lock_is_intransit(struct cl_lock *lock);
 
@@ -2985,50 +2975,50 @@ int cl_lock_enqueue_wait(const struct lu_env *env, struct cl_lock *lock,
  * @{
  */
 
-int   cl_wait       (const struct lu_env *env, struct cl_lock *lock);
-void  cl_unuse      (const struct lu_env *env, struct cl_lock *lock);
-int   cl_enqueue_try(const struct lu_env *env, struct cl_lock *lock,
-		     struct cl_io *io, __u32 flags);
-int   cl_unuse_try  (const struct lu_env *env, struct cl_lock *lock);
-int   cl_wait_try   (const struct lu_env *env, struct cl_lock *lock);
-int   cl_use_try    (const struct lu_env *env, struct cl_lock *lock, int atomic);
+int cl_wait(const struct lu_env *env, struct cl_lock *lock);
+void cl_unuse(const struct lu_env *env, struct cl_lock *lock);
+int cl_enqueue_try(const struct lu_env *env, struct cl_lock *lock,
+		   struct cl_io *io, __u32 flags);
+int cl_unuse_try(const struct lu_env *env, struct cl_lock *lock);
+int cl_wait_try(const struct lu_env *env, struct cl_lock *lock);
+int cl_use_try(const struct lu_env *env, struct cl_lock *lock, int atomic);
 
 /** @} statemachine */
 
-void cl_lock_signal      (const struct lu_env *env, struct cl_lock *lock);
-int  cl_lock_state_wait  (const struct lu_env *env, struct cl_lock *lock);
-void cl_lock_state_set   (const struct lu_env *env, struct cl_lock *lock,
-			  enum cl_lock_state state);
-int  cl_queue_match      (const struct list_head *queue,
-			  const struct cl_lock_descr *need);
-
-void cl_lock_mutex_get  (const struct lu_env *env, struct cl_lock *lock);
-void cl_lock_mutex_put  (const struct lu_env *env, struct cl_lock *lock);
-int  cl_lock_is_mutexed (struct cl_lock *lock);
-int  cl_lock_nr_mutexed (const struct lu_env *env);
-int  cl_lock_discard_pages(const struct lu_env *env, struct cl_lock *lock);
-int  cl_lock_ext_match  (const struct cl_lock_descr *has,
-			 const struct cl_lock_descr *need);
-int  cl_lock_descr_match(const struct cl_lock_descr *has,
-			 const struct cl_lock_descr *need);
-int  cl_lock_mode_match (enum cl_lock_mode has, enum cl_lock_mode need);
-int  cl_lock_modify     (const struct lu_env *env, struct cl_lock *lock,
-			 const struct cl_lock_descr *desc);
-
-void cl_lock_closure_init (const struct lu_env *env,
-			   struct cl_lock_closure *closure,
-			   struct cl_lock *origin, int wait);
-void cl_lock_closure_fini (struct cl_lock_closure *closure);
-int  cl_lock_closure_build(const struct lu_env *env, struct cl_lock *lock,
-			   struct cl_lock_closure *closure);
-void cl_lock_disclosure   (const struct lu_env *env,
-			   struct cl_lock_closure *closure);
-int  cl_lock_enclosure    (const struct lu_env *env, struct cl_lock *lock,
-			   struct cl_lock_closure *closure);
+void cl_lock_signal(const struct lu_env *env, struct cl_lock *lock);
+int cl_lock_state_wait(const struct lu_env *env, struct cl_lock *lock);
+void cl_lock_state_set(const struct lu_env *env, struct cl_lock *lock,
+		       enum cl_lock_state state);
+int cl_queue_match(const struct list_head *queue,
+		   const struct cl_lock_descr *need);
+
+void cl_lock_mutex_get(const struct lu_env *env, struct cl_lock *lock);
+void cl_lock_mutex_put(const struct lu_env *env, struct cl_lock *lock);
+int cl_lock_is_mutexed(struct cl_lock *lock);
+int cl_lock_nr_mutexed(const struct lu_env *env);
+int cl_lock_discard_pages(const struct lu_env *env, struct cl_lock *lock);
+int cl_lock_ext_match(const struct cl_lock_descr *has,
+		      const struct cl_lock_descr *need);
+int cl_lock_descr_match(const struct cl_lock_descr *has,
+			const struct cl_lock_descr *need);
+int cl_lock_mode_match(enum cl_lock_mode has, enum cl_lock_mode need);
+int cl_lock_modify(const struct lu_env *env, struct cl_lock *lock,
+		   const struct cl_lock_descr *desc);
+
+void cl_lock_closure_init(const struct lu_env *env,
+			  struct cl_lock_closure *closure,
+			  struct cl_lock *origin, int wait);
+void cl_lock_closure_fini(struct cl_lock_closure *closure);
+int cl_lock_closure_build(const struct lu_env *env, struct cl_lock *lock,
+			  struct cl_lock_closure *closure);
+void cl_lock_disclosure(const struct lu_env *env,
+			struct cl_lock_closure *closure);
+int cl_lock_enclosure(const struct lu_env *env, struct cl_lock *lock,
+		      struct cl_lock_closure *closure);
 
 void cl_lock_cancel(const struct lu_env *env, struct cl_lock *lock);
 void cl_lock_delete(const struct lu_env *env, struct cl_lock *lock);
-void cl_lock_error (const struct lu_env *env, struct cl_lock *lock, int error);
+void cl_lock_error(const struct lu_env *env, struct cl_lock *lock, int error);
 void cl_locks_prune(const struct lu_env *env, struct cl_object *obj, int wait);
 
 unsigned long cl_lock_weigh(const struct lu_env *env, struct cl_lock *lock);
@@ -3039,37 +3029,37 @@ unsigned long cl_lock_weigh(const struct lu_env *env, struct cl_lock *lock);
  * @{
  */
 
-int   cl_io_init	 (const struct lu_env *env, struct cl_io *io,
-			  enum cl_io_type iot, struct cl_object *obj);
-int   cl_io_sub_init     (const struct lu_env *env, struct cl_io *io,
-			  enum cl_io_type iot, struct cl_object *obj);
-int   cl_io_rw_init      (const struct lu_env *env, struct cl_io *io,
-			  enum cl_io_type iot, loff_t pos, size_t count);
-int   cl_io_loop	 (const struct lu_env *env, struct cl_io *io);
-
-void  cl_io_fini	 (const struct lu_env *env, struct cl_io *io);
-int   cl_io_iter_init    (const struct lu_env *env, struct cl_io *io);
-void  cl_io_iter_fini    (const struct lu_env *env, struct cl_io *io);
-int   cl_io_lock	 (const struct lu_env *env, struct cl_io *io);
-void  cl_io_unlock       (const struct lu_env *env, struct cl_io *io);
-int   cl_io_start	(const struct lu_env *env, struct cl_io *io);
-void  cl_io_end	  (const struct lu_env *env, struct cl_io *io);
-int   cl_io_lock_add     (const struct lu_env *env, struct cl_io *io,
-			  struct cl_io_lock_link *link);
-int   cl_io_lock_alloc_add(const struct lu_env *env, struct cl_io *io,
-			   struct cl_lock_descr *descr);
-int   cl_io_read_page    (const struct lu_env *env, struct cl_io *io,
-			  struct cl_page *page);
-int   cl_io_prepare_write(const struct lu_env *env, struct cl_io *io,
-			  struct cl_page *page, unsigned from, unsigned to);
-int   cl_io_commit_write (const struct lu_env *env, struct cl_io *io,
-			  struct cl_page *page, unsigned from, unsigned to);
-int   cl_io_submit_rw    (const struct lu_env *env, struct cl_io *io,
-			  enum cl_req_type iot, struct cl_2queue *queue);
-int   cl_io_submit_sync  (const struct lu_env *env, struct cl_io *io,
-			  enum cl_req_type iot, struct cl_2queue *queue,
-			  long timeout);
-int   cl_io_is_going     (const struct lu_env *env);
+int cl_io_init(const struct lu_env *env, struct cl_io *io,
+	       enum cl_io_type iot, struct cl_object *obj);
+int cl_io_sub_init(const struct lu_env *env, struct cl_io *io,
+		   enum cl_io_type iot, struct cl_object *obj);
+int cl_io_rw_init(const struct lu_env *env, struct cl_io *io,
+		  enum cl_io_type iot, loff_t pos, size_t count);
+int cl_io_loop(const struct lu_env *env, struct cl_io *io);
+
+void cl_io_fini(const struct lu_env *env, struct cl_io *io);
+int cl_io_iter_init(const struct lu_env *env, struct cl_io *io);
+void cl_io_iter_fini(const struct lu_env *env, struct cl_io *io);
+int cl_io_lock(const struct lu_env *env, struct cl_io *io);
+void cl_io_unlock(const struct lu_env *env, struct cl_io *io);
+int cl_io_start(const struct lu_env *env, struct cl_io *io);
+void cl_io_end(const struct lu_env *env, struct cl_io *io);
+int cl_io_lock_add(const struct lu_env *env, struct cl_io *io,
+		   struct cl_io_lock_link *link);
+int cl_io_lock_alloc_add(const struct lu_env *env, struct cl_io *io,
+			 struct cl_lock_descr *descr);
+int cl_io_read_page(const struct lu_env *env, struct cl_io *io,
+		    struct cl_page *page);
+int cl_io_prepare_write(const struct lu_env *env, struct cl_io *io,
+			struct cl_page *page, unsigned from, unsigned to);
+int cl_io_commit_write(const struct lu_env *env, struct cl_io *io,
+		       struct cl_page *page, unsigned from, unsigned to);
+int cl_io_submit_rw(const struct lu_env *env, struct cl_io *io,
+		    enum cl_req_type iot, struct cl_2queue *queue);
+int cl_io_submit_sync(const struct lu_env *env, struct cl_io *io,
+		      enum cl_req_type iot, struct cl_2queue *queue,
+		      long timeout);
+int cl_io_is_going(const struct lu_env *env);
 
 /**
  * True, iff \a io is an O_APPEND write(2).
@@ -3136,21 +3126,20 @@ static inline struct cl_page *cl_page_list_last(struct cl_page_list *plist)
 #define cl_page_list_for_each_safe(page, temp, list)		    \
 	list_for_each_entry_safe((page), (temp), &(list)->pl_pages, cp_batch)
 
-void cl_page_list_init   (struct cl_page_list *plist);
-void cl_page_list_add    (struct cl_page_list *plist, struct cl_page *page);
-void cl_page_list_move   (struct cl_page_list *dst, struct cl_page_list *src,
-			  struct cl_page *page);
-void cl_page_list_splice (struct cl_page_list *list,
-			  struct cl_page_list *head);
-void cl_page_list_disown (const struct lu_env *env,
-			  struct cl_io *io, struct cl_page_list *plist);
-
-void cl_2queue_init     (struct cl_2queue *queue);
-void cl_2queue_disown   (const struct lu_env *env,
-			 struct cl_io *io, struct cl_2queue *queue);
-void cl_2queue_discard  (const struct lu_env *env,
-			 struct cl_io *io, struct cl_2queue *queue);
-void cl_2queue_fini     (const struct lu_env *env, struct cl_2queue *queue);
+void cl_page_list_init(struct cl_page_list *plist);
+void cl_page_list_add(struct cl_page_list *plist, struct cl_page *page);
+void cl_page_list_move(struct cl_page_list *dst, struct cl_page_list *src,
+		       struct cl_page *page);
+void cl_page_list_splice(struct cl_page_list *list, struct cl_page_list *head);
+void cl_page_list_disown(const struct lu_env *env,
+			 struct cl_io *io, struct cl_page_list *plist);
+
+void cl_2queue_init(struct cl_2queue *queue);
+void cl_2queue_disown(const struct lu_env *env,
+		      struct cl_io *io, struct cl_2queue *queue);
+void cl_2queue_discard(const struct lu_env *env,
+		       struct cl_io *io, struct cl_2queue *queue);
+void cl_2queue_fini(const struct lu_env *env, struct cl_2queue *queue);
 void cl_2queue_init_page(struct cl_2queue *queue, struct cl_page *page);
 
 /** @} cl_page_list */
@@ -3161,16 +3150,17 @@ void cl_2queue_init_page(struct cl_2queue *queue, struct cl_page *page);
 struct cl_req *cl_req_alloc(const struct lu_env *env, struct cl_page *page,
 			    enum cl_req_type crt, int nr_objects);
 
-void cl_req_page_add  (const struct lu_env *env, struct cl_req *req,
-		       struct cl_page *page);
-void cl_req_page_done (const struct lu_env *env, struct cl_page *page);
-int  cl_req_prep      (const struct lu_env *env, struct cl_req *req);
-void cl_req_attr_set  (const struct lu_env *env, struct cl_req *req,
-		       struct cl_req_attr *attr, u64 flags);
+void cl_req_page_add(const struct lu_env *env, struct cl_req *req,
+		     struct cl_page *page);
+void cl_req_page_done(const struct lu_env *env, struct cl_page *page);
+int  cl_req_prep(const struct lu_env *env, struct cl_req *req);
+void cl_req_attr_set(const struct lu_env *env, struct cl_req *req,
+		     struct cl_req_attr *attr, u64 flags);
 void cl_req_completion(const struct lu_env *env, struct cl_req *req, int ioret);
 
 /** \defgroup cl_sync_io cl_sync_io
- * @{ */
+ * @{
+ */
 
 /**
  * Anchor for synchronous transfer. This is allocated on a stack by thread
@@ -3242,15 +3232,15 @@ struct cl_env_nest {
 	void *cen_cookie;
 };
 
-struct lu_env *cl_env_get	(int *refcheck);
-struct lu_env *cl_env_alloc      (int *refcheck, __u32 tags);
-struct lu_env *cl_env_nested_get (struct cl_env_nest *nest);
-void	   cl_env_put	(struct lu_env *env, int *refcheck);
-void	   cl_env_nested_put (struct cl_env_nest *nest, struct lu_env *env);
-void	  *cl_env_reenter    (void);
-void	   cl_env_reexit     (void *cookie);
-void	   cl_env_implant    (struct lu_env *env, int *refcheck);
-void	   cl_env_unplant    (struct lu_env *env, int *refcheck);
+struct lu_env *cl_env_get(int *refcheck);
+struct lu_env *cl_env_alloc(int *refcheck, __u32 tags);
+struct lu_env *cl_env_nested_get(struct cl_env_nest *nest);
+void cl_env_put(struct lu_env *env, int *refcheck);
+void cl_env_nested_put(struct cl_env_nest *nest, struct lu_env *env);
+void *cl_env_reenter(void);
+void cl_env_reexit(void *cookie);
+void cl_env_implant(struct lu_env *env, int *refcheck);
+void cl_env_unplant(struct lu_env *env, int *refcheck);
 
 /** @} cl_env */
 
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 0d98111..89052b2 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -427,8 +427,7 @@ static inline void lprocfs_stats_unlock(struct lprocfs_stats *stats, int opc,
 	case LPROCFS_GET_SMP_ID:
 		if (stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) {
 			if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE) {
-				spin_unlock_irqrestore(&stats->ls_lock,
-							   *flags);
+				spin_unlock_irqrestore(&stats->ls_lock, *flags);
 			} else {
 				spin_unlock(&stats->ls_lock);
 			}
@@ -440,8 +439,7 @@ static inline void lprocfs_stats_unlock(struct lprocfs_stats *stats, int opc,
 	case LPROCFS_GET_NUM_CPU:
 		if (stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) {
 			if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE) {
-				spin_unlock_irqrestore(&stats->ls_lock,
-							   *flags);
+				spin_unlock_irqrestore(&stats->ls_lock, *flags);
 			} else {
 				spin_unlock(&stats->ls_lock);
 			}
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 284affb..da8bc6e 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -638,15 +638,13 @@ static inline void ostid_set_id(struct ost_id *oi, __u64 oid)
 {
 	if (fid_seq_is_mdt0(ostid_seq(oi))) {
 		if (oid >= IDIF_MAX_OID) {
-			CERROR("Bad %llu to set "DOSTID"\n",
-				oid, POSTID(oi));
+			CERROR("Bad %llu to set " DOSTID "\n", oid, POSTID(oi));
 			return;
 		}
 		oi->oi.oi_id = oid;
 	} else {
 		if (oid > OBIF_MAX_OID) {
-			CERROR("Bad %llu to set "DOSTID"\n",
-				oid, POSTID(oi));
+			CERROR("Bad %llu to set " DOSTID "\n", oid, POSTID(oi));
 			return;
 		}
 		oi->oi_fid.f_oid = oid;
@@ -716,8 +714,8 @@ static inline int ostid_to_fid(struct lu_fid *fid, struct ost_id *ostid,
 		* pass the FID through, no conversion needed.
 		*/
 		if (ostid->oi_fid.f_ver != 0) {
-			CERROR("bad MDT0 id, "DOSTID" ost_idx:%u\n",
-				POSTID(ostid), ost_idx);
+			CERROR("bad MDT0 id, " DOSTID " ost_idx:%u\n",
+			       POSTID(ostid), ost_idx);
 			return -EBADF;
 		}
 		*fid = ostid->oi_fid;
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index ab91879..ab4a923 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -435,7 +435,7 @@ fid_extract_from_res_name(struct lu_fid *fid, const struct ldlm_res_id *res)
  */
 static inline struct ldlm_res_id *
 fid_build_quota_res_name(const struct lu_fid *glb_fid, union lquota_id *qid,
-		      struct ldlm_res_id *res)
+			 struct ldlm_res_id *res)
 {
 	fid_build_reg_res_name(glb_fid, res);
 	res->name[LUSTRE_RES_ID_QUOTA_SEQ_OFF] = fid_seq(&qid->qid_fid);
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index ac08b25..b857055 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -2382,14 +2382,14 @@ void ptlrpc_at_set_req_timeout(struct ptlrpc_request *req);
 struct ptlrpc_request *ptlrpc_request_alloc(struct obd_import *imp,
 					    const struct req_format *format);
 struct ptlrpc_request *ptlrpc_request_alloc_pool(struct obd_import *imp,
-					    struct ptlrpc_request_pool *,
-					    const struct req_format *format);
+						 struct ptlrpc_request_pool *,
+						 const struct req_format *);
 void ptlrpc_request_free(struct ptlrpc_request *request);
 int ptlrpc_request_pack(struct ptlrpc_request *request,
 			__u32 version, int opcode);
-struct ptlrpc_request *ptlrpc_request_alloc_pack(struct obd_import *imp,
-						const struct req_format *format,
-						__u32 version, int opcode);
+struct ptlrpc_request *ptlrpc_request_alloc_pack(struct obd_import *,
+						 const struct req_format *,
+						 __u32, int);
 int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 			     __u32 version, int opcode, char **bufs,
 			     struct ptlrpc_cli_ctx *ctx);
@@ -2509,10 +2509,9 @@ struct ptlrpc_service_conf {
  */
 void ptlrpc_dispatch_difficult_reply(struct ptlrpc_reply_state *rs);
 void ptlrpc_schedule_difficult_reply(struct ptlrpc_reply_state *rs);
-struct ptlrpc_service *ptlrpc_register_service(
-				struct ptlrpc_service_conf *conf,
-				struct kset *parent,
-				struct dentry *debugfs_entry);
+struct ptlrpc_service *ptlrpc_register_service(struct ptlrpc_service_conf *conf,
+					       struct kset *parent,
+					       struct dentry *debugfs_entry);
 
 int ptlrpc_start_threads(struct ptlrpc_service *svc);
 int ptlrpc_unregister_service(struct ptlrpc_service *service);
@@ -2545,7 +2544,7 @@ int ptlrpc_reconnect_import(struct obd_import *imp);
 int ptlrpc_buf_need_swab(struct ptlrpc_request *req, const int inout,
 			 int index);
 void ptlrpc_buf_set_swabbed(struct ptlrpc_request *req, const int inout,
-				int index);
+			    int index);
 int ptlrpc_unpack_rep_msg(struct ptlrpc_request *req, int len);
 int ptlrpc_unpack_req_msg(struct ptlrpc_request *req, int len);
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index b5128e4..b2e67fc 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -107,8 +107,8 @@ void req_capsule_set_size(struct req_capsule *pill,
 			  const struct req_msg_field *field,
 			  enum req_location loc, int size);
 int req_capsule_get_size(const struct req_capsule *pill,
-			  const struct req_msg_field *field,
-			  enum req_location loc);
+			 const struct req_msg_field *field,
+			 enum req_location loc);
 int req_capsule_msg_size(struct req_capsule *pill, enum req_location loc);
 int req_capsule_fmt_size(__u32 magic, const struct req_format *fmt,
 			 enum req_location loc);
diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
index dd1033b..01b4e67 100644
--- a/drivers/staging/lustre/lustre/include/lustre_sec.h
+++ b/drivers/staging/lustre/lustre/include/lustre_sec.h
@@ -351,26 +351,23 @@ struct ptlrpc_ctx_ops {
 	/**
 	 * To determine whether it's suitable to use the \a ctx for \a vcred.
 	 */
-	int     (*match)       (struct ptlrpc_cli_ctx *ctx,
-				struct vfs_cred *vcred);
+	int (*match)(struct ptlrpc_cli_ctx *ctx, struct vfs_cred *vcred);
 
 	/**
 	 * To bring the \a ctx uptodate.
 	 */
-	int     (*refresh)     (struct ptlrpc_cli_ctx *ctx);
+	int (*refresh)(struct ptlrpc_cli_ctx *ctx);
 
 	/**
 	 * Validate the \a ctx.
 	 */
-	int     (*validate)    (struct ptlrpc_cli_ctx *ctx);
+	int (*validate)(struct ptlrpc_cli_ctx *ctx);
 
 	/**
 	 * Force the \a ctx to die.
 	 */
-	void    (*force_die)   (struct ptlrpc_cli_ctx *ctx,
-				int grace);
-	int     (*display)     (struct ptlrpc_cli_ctx *ctx,
-				char *buf, int bufsize);
+	void (*force_die)(struct ptlrpc_cli_ctx *ctx, int grace);
+	int (*display)(struct ptlrpc_cli_ctx *ctx, char *buf, int bufsize);
 
 	/**
 	 * Sign the request message using \a ctx.
@@ -382,8 +379,7 @@ struct ptlrpc_ctx_ops {
 	 *
 	 * \see null_ctx_sign(), plain_ctx_sign(), gss_cli_ctx_sign().
 	 */
-	int     (*sign)	(struct ptlrpc_cli_ctx *ctx,
-				struct ptlrpc_request *req);
+	int (*sign)(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req);
 
 	/**
 	 * Verify the reply message using \a ctx.
@@ -395,8 +391,7 @@ struct ptlrpc_ctx_ops {
 	 *
 	 * \see null_ctx_verify(), plain_ctx_verify(), gss_cli_ctx_verify().
 	 */
-	int     (*verify)      (struct ptlrpc_cli_ctx *ctx,
-				struct ptlrpc_request *req);
+	int (*verify)(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req);
 
 	/**
 	 * Encrypt the request message using \a ctx.
@@ -408,8 +403,7 @@ struct ptlrpc_ctx_ops {
 	 *
 	 * \see gss_cli_ctx_seal().
 	 */
-	int     (*seal)	(struct ptlrpc_cli_ctx *ctx,
-				struct ptlrpc_request *req);
+	int (*seal)(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req);
 
 	/**
 	 * Decrypt the reply message using \a ctx.
@@ -421,8 +415,7 @@ struct ptlrpc_ctx_ops {
 	 *
 	 * \see gss_cli_ctx_unseal().
 	 */
-	int     (*unseal)      (struct ptlrpc_cli_ctx *ctx,
-				struct ptlrpc_request *req);
+	int (*unseal)(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req);
 
 	/**
 	 * Wrap bulk request data. This is called before wrapping RPC
@@ -444,9 +437,9 @@ struct ptlrpc_ctx_ops {
 	 *
 	 * \see plain_cli_wrap_bulk(), gss_cli_ctx_wrap_bulk().
 	 */
-	int     (*wrap_bulk)   (struct ptlrpc_cli_ctx *ctx,
-				struct ptlrpc_request *req,
-				struct ptlrpc_bulk_desc *desc);
+	int (*wrap_bulk)(struct ptlrpc_cli_ctx *ctx,
+			 struct ptlrpc_request *req,
+			 struct ptlrpc_bulk_desc *desc);
 
 	/**
 	 * Unwrap bulk reply data. This is called after wrapping RPC
@@ -461,9 +454,9 @@ struct ptlrpc_ctx_ops {
 	 *
 	 * \see plain_cli_unwrap_bulk(), gss_cli_ctx_unwrap_bulk().
 	 */
-	int     (*unwrap_bulk) (struct ptlrpc_cli_ctx *ctx,
-				struct ptlrpc_request *req,
-				struct ptlrpc_bulk_desc *desc);
+	int (*unwrap_bulk)(struct ptlrpc_cli_ctx *ctx,
+			   struct ptlrpc_request *req,
+			   struct ptlrpc_bulk_desc *desc);
 };
 
 #define PTLRPC_CTX_NEW_BIT	     (0)  /* newly created */
@@ -515,9 +508,9 @@ struct ptlrpc_sec_cops {
 	 *
 	 * \see null_create_sec(), plain_create_sec(), gss_sec_create_kr().
 	 */
-	struct ptlrpc_sec *     (*create_sec)  (struct obd_import *imp,
-						struct ptlrpc_svc_ctx *ctx,
-						struct sptlrpc_flavor *flavor);
+	struct ptlrpc_sec *(*create_sec)(struct obd_import *imp,
+					 struct ptlrpc_svc_ctx *ctx,
+					 struct sptlrpc_flavor *flavor);
 
 	/**
 	 * Destructor of ptlrpc_sec. When called, refcount has been dropped
@@ -525,7 +518,7 @@ struct ptlrpc_sec_cops {
 	 *
 	 * \see null_destroy_sec(), plain_destroy_sec(), gss_sec_destroy_kr().
 	 */
-	void		    (*destroy_sec) (struct ptlrpc_sec *sec);
+	void (*destroy_sec)(struct ptlrpc_sec *sec);
 
 	/**
 	 * Notify that this ptlrpc_sec is going to die. Optionally, policy
@@ -534,7 +527,7 @@ struct ptlrpc_sec_cops {
 	 *
 	 * \see plain_kill_sec(), gss_sec_kill().
 	 */
-	void		    (*kill_sec)    (struct ptlrpc_sec *sec);
+	void (*kill_sec)(struct ptlrpc_sec *sec);
 
 	/**
 	 * Given \a vcred, lookup and/or create its context. The policy module
@@ -544,10 +537,9 @@ struct ptlrpc_sec_cops {
 	 *
 	 * \see null_lookup_ctx(), plain_lookup_ctx(), gss_sec_lookup_ctx_kr().
 	 */
-	struct ptlrpc_cli_ctx * (*lookup_ctx)  (struct ptlrpc_sec *sec,
-						struct vfs_cred *vcred,
-						int create,
-						int remove_dead);
+	struct ptlrpc_cli_ctx *(*lookup_ctx)(struct ptlrpc_sec *sec,
+					     struct vfs_cred *vcred,
+					     int create, int remove_dead);
 
 	/**
 	 * Called then the reference of \a ctx dropped to 0. The policy module
@@ -559,9 +551,8 @@ struct ptlrpc_sec_cops {
 	 *
 	 * \see plain_release_ctx(), gss_sec_release_ctx_kr().
 	 */
-	void		    (*release_ctx) (struct ptlrpc_sec *sec,
-						struct ptlrpc_cli_ctx *ctx,
-						int sync);
+	void (*release_ctx)(struct ptlrpc_sec *sec, struct ptlrpc_cli_ctx *ctx,
+			    int sync);
 
 	/**
 	 * Flush the context cache.
@@ -573,11 +564,8 @@ struct ptlrpc_sec_cops {
 	 *
 	 * \see plain_flush_ctx_cache(), gss_sec_flush_ctx_cache_kr().
 	 */
-	int		     (*flush_ctx_cache)
-					       (struct ptlrpc_sec *sec,
-						uid_t uid,
-						int grace,
-						int force);
+	int (*flush_ctx_cache)(struct ptlrpc_sec *sec, uid_t uid,
+			       int grace, int force);
 
 	/**
 	 * Called periodically by garbage collector to remove dead contexts
@@ -585,7 +573,7 @@ struct ptlrpc_sec_cops {
 	 *
 	 * \see gss_sec_gc_ctx_kr().
 	 */
-	void		    (*gc_ctx)      (struct ptlrpc_sec *sec);
+	void (*gc_ctx)(struct ptlrpc_sec *sec);
 
 	/**
 	 * Given an context \a ctx, install a corresponding reverse service
@@ -593,9 +581,8 @@ struct ptlrpc_sec_cops {
 	 * XXX currently it's only used by GSS module, maybe we should remove
 	 * this from general API.
 	 */
-	int		     (*install_rctx)(struct obd_import *imp,
-						struct ptlrpc_sec *sec,
-						struct ptlrpc_cli_ctx *ctx);
+	int (*install_rctx)(struct obd_import *imp, struct ptlrpc_sec *sec,
+			    struct ptlrpc_cli_ctx *ctx);
 
 	/**
 	 * To allocate request buffer for \a req.
@@ -608,9 +595,8 @@ struct ptlrpc_sec_cops {
 	 *
 	 * \see null_alloc_reqbuf(), plain_alloc_reqbuf(), gss_alloc_reqbuf().
 	 */
-	int		     (*alloc_reqbuf)(struct ptlrpc_sec *sec,
-						struct ptlrpc_request *req,
-						int lustre_msg_size);
+	int (*alloc_reqbuf)(struct ptlrpc_sec *sec, struct ptlrpc_request *req,
+			    int lustre_msg_size);
 
 	/**
 	 * To free request buffer for \a req.
@@ -619,8 +605,7 @@ struct ptlrpc_sec_cops {
 	 *
 	 * \see null_free_reqbuf(), plain_free_reqbuf(), gss_free_reqbuf().
 	 */
-	void		    (*free_reqbuf) (struct ptlrpc_sec *sec,
-						struct ptlrpc_request *req);
+	void (*free_reqbuf)(struct ptlrpc_sec *sec, struct ptlrpc_request *req);
 
 	/**
 	 * To allocate reply buffer for \a req.
@@ -632,9 +617,8 @@ struct ptlrpc_sec_cops {
 	 *
 	 * \see null_alloc_repbuf(), plain_alloc_repbuf(), gss_alloc_repbuf().
 	 */
-	int		     (*alloc_repbuf)(struct ptlrpc_sec *sec,
-						struct ptlrpc_request *req,
-						int lustre_msg_size);
+	int (*alloc_repbuf)(struct ptlrpc_sec *sec, struct ptlrpc_request *req,
+			    int lustre_msg_size);
 
 	/**
 	 * To free reply buffer for \a req.
@@ -645,8 +629,7 @@ struct ptlrpc_sec_cops {
 	 *
 	 * \see null_free_repbuf(), plain_free_repbuf(), gss_free_repbuf().
 	 */
-	void		    (*free_repbuf) (struct ptlrpc_sec *sec,
-						struct ptlrpc_request *req);
+	void (*free_repbuf)(struct ptlrpc_sec *sec, struct ptlrpc_request *req);
 
 	/**
 	 * To expand the request buffer of \a req, thus the \a segment in
@@ -658,15 +641,13 @@ struct ptlrpc_sec_cops {
 	 * \see null_enlarge_reqbuf(), plain_enlarge_reqbuf(),
 	 * gss_enlarge_reqbuf().
 	 */
-	int		     (*enlarge_reqbuf)
-					       (struct ptlrpc_sec *sec,
-						struct ptlrpc_request *req,
-						int segment, int newsize);
+	int (*enlarge_reqbuf)(struct ptlrpc_sec *sec,
+			      struct ptlrpc_request *req,
+			      int segment, int newsize);
 	/*
 	 * misc
 	 */
-	int		     (*display)     (struct ptlrpc_sec *sec,
-						struct seq_file *seq);
+	int (*display)(struct ptlrpc_sec *sec, struct seq_file *seq);
 };
 
 /**
@@ -690,7 +671,7 @@ struct ptlrpc_sec_sops {
 	 *
 	 * \see null_accept(), plain_accept(), gss_svc_accept_kr().
 	 */
-	int		     (*accept)      (struct ptlrpc_request *req);
+	int (*accept)(struct ptlrpc_request *req);
 
 	/**
 	 * Perform security transformation upon reply message.
@@ -702,15 +683,14 @@ struct ptlrpc_sec_sops {
 	 *
 	 * \see null_authorize(), plain_authorize(), gss_svc_authorize().
 	 */
-	int		     (*authorize)   (struct ptlrpc_request *req);
+	int (*authorize)(struct ptlrpc_request *req);
 
 	/**
 	 * Invalidate server context \a ctx.
 	 *
 	 * \see gss_svc_invalidate_ctx().
 	 */
-	void		    (*invalidate_ctx)
-					       (struct ptlrpc_svc_ctx *ctx);
+	void (*invalidate_ctx)(struct ptlrpc_svc_ctx *ctx);
 
 	/**
 	 * Allocate a ptlrpc_reply_state.
@@ -724,28 +704,26 @@ struct ptlrpc_sec_sops {
 	 *
 	 * \see null_alloc_rs(), plain_alloc_rs(), gss_svc_alloc_rs().
 	 */
-	int		     (*alloc_rs)    (struct ptlrpc_request *req,
-						int msgsize);
+	int (*alloc_rs)(struct ptlrpc_request *req, int msgsize);
 
 	/**
 	 * Free a ptlrpc_reply_state.
 	 */
-	void		    (*free_rs)     (struct ptlrpc_reply_state *rs);
+	void (*free_rs)(struct ptlrpc_reply_state *rs);
 
 	/**
 	 * Release the server context \a ctx.
 	 *
 	 * \see gss_svc_free_ctx().
 	 */
-	void		    (*free_ctx)    (struct ptlrpc_svc_ctx *ctx);
+	void (*free_ctx)(struct ptlrpc_svc_ctx *ctx);
 
 	/**
 	 * Install a reverse context based on the server context \a ctx.
 	 *
 	 * \see gss_svc_install_rctx_kr().
 	 */
-	int		     (*install_rctx)(struct obd_import *imp,
-						struct ptlrpc_svc_ctx *ctx);
+	int (*install_rctx)(struct obd_import *imp, struct ptlrpc_svc_ctx *ctx);
 
 	/**
 	 * Prepare buffer for incoming bulk write.
@@ -755,24 +733,24 @@ struct ptlrpc_sec_sops {
 	 *
 	 * \see gss_svc_prep_bulk().
 	 */
-	int		     (*prep_bulk)   (struct ptlrpc_request *req,
-						struct ptlrpc_bulk_desc *desc);
+	int (*prep_bulk)(struct ptlrpc_request *req,
+			 struct ptlrpc_bulk_desc *desc);
 
 	/**
 	 * Unwrap the bulk write data.
 	 *
 	 * \see plain_svc_unwrap_bulk(), gss_svc_unwrap_bulk().
 	 */
-	int		     (*unwrap_bulk) (struct ptlrpc_request *req,
-						struct ptlrpc_bulk_desc *desc);
+	int (*unwrap_bulk)(struct ptlrpc_request *req,
+			   struct ptlrpc_bulk_desc *desc);
 
 	/**
 	 * Wrap the bulk read data.
 	 *
 	 * \see plain_svc_wrap_bulk(), gss_svc_wrap_bulk().
 	 */
-	int		     (*wrap_bulk)   (struct ptlrpc_request *req,
-						struct ptlrpc_bulk_desc *desc);
+	int (*wrap_bulk)(struct ptlrpc_request *req,
+			 struct ptlrpc_bulk_desc *desc);
 };
 
 struct ptlrpc_sec_policy {
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index e63366b..abaacc9 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -937,7 +937,7 @@ struct md_enqueue_info {
 	struct lustre_handle    mi_lockh;
 	struct inode	   *mi_dir;
 	int (*mi_cb)(struct ptlrpc_request *req,
-		struct md_enqueue_info *minfo, int rc);
+		     struct md_enqueue_info *minfo, int rc);
 	__u64		   mi_cbdata;
 	unsigned int	    mi_generation;
 };
@@ -1206,9 +1206,9 @@ struct lsm_operations {
 	void (*lsm_stripe_by_offset)(struct lov_stripe_md *, int *, u64 *,
 				     u64 *);
 	int (*lsm_lmm_verify)(struct lov_mds_md *lmm, int lmm_bytes,
-			       __u16 *stripe_count);
+			      __u16 *stripe_count);
 	int (*lsm_unpackmd)(struct lov_obd *lov, struct lov_stripe_md *lsm,
-			     struct lov_mds_md *lmm);
+			    struct lov_mds_md *lmm);
 };
 
 extern const struct lsm_operations lsm_v1_ops;
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 8515218..706869f 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -87,10 +87,10 @@ int class_name2dev(const char *name);
 struct obd_device *class_name2obd(const char *name);
 int class_uuid2dev(struct obd_uuid *uuid);
 struct obd_device *class_find_client_obd(struct obd_uuid *tgt_uuid,
-					  const char *typ_name,
-					  struct obd_uuid *grp_uuid);
+					 const char *typ_name,
+					 struct obd_uuid *grp_uuid);
 struct obd_device *class_devices_in_group(struct obd_uuid *grp_uuid,
-					   int *next);
+					  int *next);
 struct obd_device *class_num2obd(int num);
 
 int class_notify_sptlrpc_conf(const char *fsname, int namelen);
@@ -198,7 +198,7 @@ extern void (*class_export_dump_hook)(struct obd_export *);
 struct obd_export *class_export_get(struct obd_export *exp);
 void class_export_put(struct obd_export *exp);
 struct obd_export *class_new_export(struct obd_device *obddev,
-				struct obd_uuid *cluuid);
+				    struct obd_uuid *cluuid);
 void class_unlink_export(struct obd_export *exp);
 
 struct obd_import *class_import_get(struct obd_import *);
@@ -208,7 +208,7 @@ void class_destroy_import(struct obd_import *exp);
 
 void class_put_type(struct obd_type *type);
 int class_connect(struct lustre_handle *conn, struct obd_device *obd,
-		struct obd_uuid *cluuid);
+		  struct obd_uuid *cluuid);
 int class_disconnect(struct obd_export *exp);
 void class_fail_export(struct obd_export *exp);
 int class_manual_cleanup(struct obd_device *obd);
@@ -1351,7 +1351,7 @@ static inline int md_getattr(struct obd_export *exp, struct md_op_data *op_data,
 }
 
 static inline int md_null_inode(struct obd_export *exp,
-				   const struct lu_fid *fid)
+				const struct lu_fid *fid)
 {
 	int rc;
 
@@ -1734,7 +1734,7 @@ void class_uuid_unparse(class_uuid_t in, struct obd_uuid *out);
 /* lustre_peer.c    */
 int lustre_uuid_to_peer(const char *uuid, lnet_nid_t *peer_nid, int index);
 int class_add_uuid(const char *uuid, __u64 nid);
-int class_del_uuid (const char *uuid);
+int class_del_uuid(const char *uuid);
 int class_check_uuid(struct obd_uuid *uuid, __u64 nid);
 void class_init_uuidlist(void);
 void class_exit_uuidlist(void);
-- 
2.1.0
