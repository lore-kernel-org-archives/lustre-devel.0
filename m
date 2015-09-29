From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:52 -0400
Subject: [lustre-devel] [PATCH 09/29] staging/lustre: Remove unused
	functions and definitions from cl_object
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-10-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

cl_object_header_fini, cl_object_has_locks, cl_attr2lvb,
cl_page_list_own, cl_page_list_unmap, cl_2queue_assume,
cl_io_print, cl_enqueue,
also cleanup extern declarations in cl_object.h

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  | 26 ---------
 drivers/staging/lustre/lustre/obdclass/cl_io.c     | 65 ----------------------
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   | 26 ---------
 drivers/staging/lustre/lustre/obdclass/cl_object.c | 41 --------------
 4 files changed, 158 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index b2366ca..b073313 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2733,7 +2733,6 @@ struct cl_object *cl_object_find(const struct lu_env *env, struct cl_device *cd,
 				 const struct cl_object_conf *c);
 
 int  cl_object_header_init(struct cl_object_header *h);
-void cl_object_header_fini(struct cl_object_header *h);
 void cl_object_put	(const struct lu_env *env, struct cl_object *o);
 void cl_object_get	(struct cl_object *o);
 void cl_object_attr_lock  (struct cl_object *o);
@@ -2748,7 +2747,6 @@ int  cl_conf_set	  (const struct lu_env *env, struct cl_object *obj,
 			   const struct cl_object_conf *conf);
 void cl_object_prune      (const struct lu_env *env, struct cl_object *obj);
 void cl_object_kill       (const struct lu_env *env, struct cl_object *obj);
-int  cl_object_has_locks  (struct cl_object *obj);
 
 /**
  * Returns true, iff \a o0 and \a o1 are slices of the same object.
@@ -2935,10 +2933,6 @@ void  cl_lock_release   (const struct lu_env *env, struct cl_lock *lock,
 void  cl_lock_user_add  (const struct lu_env *env, struct cl_lock *lock);
 void  cl_lock_user_del  (const struct lu_env *env, struct cl_lock *lock);
 
-enum cl_lock_state cl_lock_intransit(const struct lu_env *env,
-				     struct cl_lock *lock);
-void cl_lock_extransit(const struct lu_env *env, struct cl_lock *lock,
-		       enum cl_lock_state state);
 int cl_lock_is_intransit(struct cl_lock *lock);
 
 int cl_lock_enqueue_wait(const struct lu_env *env, struct cl_lock *lock,
@@ -2976,8 +2970,6 @@ int cl_lock_enqueue_wait(const struct lu_env *env, struct cl_lock *lock,
  *
  * @{ */
 
-int   cl_enqueue    (const struct lu_env *env, struct cl_lock *lock,
-		     struct cl_io *io, __u32 flags);
 int   cl_wait       (const struct lu_env *env, struct cl_lock *lock);
 void  cl_unuse      (const struct lu_env *env, struct cl_lock *lock);
 int   cl_enqueue_try(const struct lu_env *env, struct cl_lock *lock,
@@ -2996,7 +2988,6 @@ int  cl_queue_match      (const struct list_head *queue,
 			  const struct cl_lock_descr *need);
 
 void cl_lock_mutex_get  (const struct lu_env *env, struct cl_lock *lock);
-int  cl_lock_mutex_try  (const struct lu_env *env, struct cl_lock *lock);
 void cl_lock_mutex_put  (const struct lu_env *env, struct cl_lock *lock);
 int  cl_lock_is_mutexed (struct cl_lock *lock);
 int  cl_lock_nr_mutexed (const struct lu_env *env);
@@ -3062,10 +3053,6 @@ int   cl_io_submit_rw    (const struct lu_env *env, struct cl_io *io,
 int   cl_io_submit_sync  (const struct lu_env *env, struct cl_io *io,
 			  enum cl_req_type iot, struct cl_2queue *queue,
 			  long timeout);
-void  cl_io_rw_advance   (const struct lu_env *env, struct cl_io *io,
-			  size_t nob);
-int   cl_io_cancel       (const struct lu_env *env, struct cl_io *io,
-			  struct cl_page_list *queue);
 int   cl_io_is_going     (const struct lu_env *env);
 
 /**
@@ -3097,9 +3084,6 @@ static inline int cl_io_is_trunc(const struct cl_io *io)
 
 struct cl_io *cl_io_top(struct cl_io *io);
 
-void cl_io_print(const struct lu_env *env, void *cookie,
-		 lu_printer_t printer, const struct cl_io *io);
-
 #define CL_IO_SLICE_CLEAN(foo_io, base)					\
 do {									\
 	typeof(foo_io) __foo_io = (foo_io);				\
@@ -3145,22 +3129,14 @@ void cl_page_list_del    (const struct lu_env *env,
 			  struct cl_page_list *plist, struct cl_page *page);
 void cl_page_list_disown (const struct lu_env *env,
 			  struct cl_io *io, struct cl_page_list *plist);
-int  cl_page_list_own    (const struct lu_env *env,
-			  struct cl_io *io, struct cl_page_list *plist);
-void cl_page_list_assume (const struct lu_env *env,
-			  struct cl_io *io, struct cl_page_list *plist);
 void cl_page_list_discard(const struct lu_env *env,
 			  struct cl_io *io, struct cl_page_list *plist);
-int  cl_page_list_unmap  (const struct lu_env *env,
-			  struct cl_io *io, struct cl_page_list *plist);
 void cl_page_list_fini   (const struct lu_env *env, struct cl_page_list *plist);
 
 void cl_2queue_init     (struct cl_2queue *queue);
 void cl_2queue_add      (struct cl_2queue *queue, struct cl_page *page);
 void cl_2queue_disown   (const struct lu_env *env,
 			 struct cl_io *io, struct cl_2queue *queue);
-void cl_2queue_assume   (const struct lu_env *env,
-			 struct cl_io *io, struct cl_2queue *queue);
 void cl_2queue_discard  (const struct lu_env *env,
 			 struct cl_io *io, struct cl_2queue *queue);
 void cl_2queue_fini     (const struct lu_env *env, struct cl_2queue *queue);
@@ -3253,7 +3229,6 @@ struct cl_env_nest {
 	void *cen_cookie;
 };
 
-struct lu_env *cl_env_peek       (int *refcheck);
 struct lu_env *cl_env_get	(int *refcheck);
 struct lu_env *cl_env_alloc      (int *refcheck, __u32 tags);
 struct lu_env *cl_env_nested_get (struct cl_env_nest *nest);
@@ -3269,7 +3244,6 @@ void	   cl_env_unplant    (struct lu_env *env, int *refcheck);
 /*
  * Misc
  */
-void cl_attr2lvb(struct ost_lvb *lvb, const struct cl_attr *attr);
 void cl_lvb2attr(struct cl_attr *attr, const struct ost_lvb *lvb);
 
 struct cl_device *cl_type_setup(const struct lu_env *env, struct lu_site *site,
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index da0066a..a822a0b 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -1181,32 +1181,6 @@ void cl_page_list_fini(const struct lu_env *env, struct cl_page_list *plist)
 EXPORT_SYMBOL(cl_page_list_fini);
 
 /**
- * Owns all pages in a queue.
- */
-int cl_page_list_own(const struct lu_env *env,
-		     struct cl_io *io, struct cl_page_list *plist)
-{
-	struct cl_page *page;
-	struct cl_page *temp;
-	pgoff_t index = 0;
-	int result;
-
-	LINVRNT(plist->pl_owner == current);
-
-	result = 0;
-	cl_page_list_for_each_safe(page, temp, plist) {
-		LASSERT(index <= page->cp_index);
-		index = page->cp_index;
-		if (cl_page_own(env, io, page) == 0)
-			result = result ?: page->cp_error;
-		else
-			cl_page_list_del(env, plist, page);
-	}
-	return result;
-}
-EXPORT_SYMBOL(cl_page_list_own);
-
-/**
  * Assumes all pages in a queue.
  */
 void cl_page_list_assume(const struct lu_env *env,
@@ -1236,26 +1210,6 @@ void cl_page_list_discard(const struct lu_env *env, struct cl_io *io,
 EXPORT_SYMBOL(cl_page_list_discard);
 
 /**
- * Unmaps all pages in a queue from user virtual memory.
- */
-int cl_page_list_unmap(const struct lu_env *env, struct cl_io *io,
-			struct cl_page_list *plist)
-{
-	struct cl_page *page;
-	int result;
-
-	LINVRNT(plist->pl_owner == current);
-	result = 0;
-	cl_page_list_for_each(page, plist) {
-		result = cl_page_unmap(env, io, page);
-		if (result != 0)
-			break;
-	}
-	return result;
-}
-EXPORT_SYMBOL(cl_page_list_unmap);
-
-/**
  * Initialize dual page queue.
  */
 void cl_2queue_init(struct cl_2queue *queue)
@@ -1297,17 +1251,6 @@ void cl_2queue_discard(const struct lu_env *env,
 EXPORT_SYMBOL(cl_2queue_discard);
 
 /**
- * Assume to own the pages in cl_2queue
- */
-void cl_2queue_assume(const struct lu_env *env,
-		      struct cl_io *io, struct cl_2queue *queue)
-{
-	cl_page_list_assume(env, io, &queue->c2_qin);
-	cl_page_list_assume(env, io, &queue->c2_qout);
-}
-EXPORT_SYMBOL(cl_2queue_assume);
-
-/**
  * Finalize both page lists of a 2-queue.
  */
 void cl_2queue_fini(const struct lu_env *env, struct cl_2queue *queue)
@@ -1341,14 +1284,6 @@ struct cl_io *cl_io_top(struct cl_io *io)
 EXPORT_SYMBOL(cl_io_top);
 
 /**
- * Prints human readable representation of \a io to the \a f.
- */
-void cl_io_print(const struct lu_env *env, void *cookie,
-		 lu_printer_t printer, const struct cl_io *io)
-{
-}
-
-/**
  * Adds request slice to the compound request.
  *
  * This is called by cl_device_operations::cdo_req_init() methods to add a
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index 7c6583a..4294ca6 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -1276,32 +1276,6 @@ static int cl_enqueue_locked(const struct lu_env *env, struct cl_lock *lock,
 }
 
 /**
- * Enqueues a lock.
- *
- * \pre current thread or io owns a hold on lock.
- *
- * \post ergo(result == 0, lock->users increased)
- * \post ergo(result == 0, lock->cll_state == CLS_ENQUEUED ||
- *			 lock->cll_state == CLS_HELD)
- */
-int cl_enqueue(const struct lu_env *env, struct cl_lock *lock,
-	       struct cl_io *io, __u32 enqflags)
-{
-	int result;
-
-	cl_lock_lockdep_acquire(env, lock, enqflags);
-	cl_lock_mutex_get(env, lock);
-	result = cl_enqueue_locked(env, lock, io, enqflags);
-	cl_lock_mutex_put(env, lock);
-	if (result != 0)
-		cl_lock_lockdep_release(env, lock);
-	LASSERT(ergo(result == 0, lock->cll_state == CLS_ENQUEUED ||
-		     lock->cll_state == CLS_HELD));
-	return result;
-}
-EXPORT_SYMBOL(cl_enqueue);
-
-/**
  * Tries to unlock a lock.
  *
  * This function is called to release underlying resource:
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 05e29f8..89ff7f1 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -98,16 +98,6 @@ int cl_object_header_init(struct cl_object_header *h)
 EXPORT_SYMBOL(cl_object_header_init);
 
 /**
- * Finalize cl_object_header.
- */
-void cl_object_header_fini(struct cl_object_header *h)
-{
-	LASSERT(list_empty(&h->coh_locks));
-	lu_object_header_fini(&h->coh_lu);
-}
-EXPORT_SYMBOL(cl_object_header_fini);
-
-/**
  * Returns a cl_object with a given \a fid.
  *
  * Returns either cached or newly created object. Additional reference on the
@@ -363,22 +353,6 @@ void cl_object_prune(const struct lu_env *env, struct cl_object *obj)
 }
 EXPORT_SYMBOL(cl_object_prune);
 
-/**
- * Check if the object has locks.
- */
-int cl_object_has_locks(struct cl_object *obj)
-{
-	struct cl_object_header *head = cl_object_header(obj);
-	int has;
-
-	spin_lock(&head->coh_lock_guard);
-	has = list_empty(&head->coh_locks);
-	spin_unlock(&head->coh_lock_guard);
-
-	return (has == 0);
-}
-EXPORT_SYMBOL(cl_object_has_locks);
-
 void cache_stats_init(struct cache_stats *cs, const char *name)
 {
 	int i;
@@ -929,21 +903,6 @@ void cl_env_nested_put(struct cl_env_nest *nest, struct lu_env *env)
 EXPORT_SYMBOL(cl_env_nested_put);
 
 /**
- * Converts struct cl_attr to struct ost_lvb.
- *
- * \see cl_lvb2attr
- */
-void cl_attr2lvb(struct ost_lvb *lvb, const struct cl_attr *attr)
-{
-	lvb->lvb_size   = attr->cat_size;
-	lvb->lvb_mtime  = attr->cat_mtime;
-	lvb->lvb_atime  = attr->cat_atime;
-	lvb->lvb_ctime  = attr->cat_ctime;
-	lvb->lvb_blocks = attr->cat_blocks;
-}
-EXPORT_SYMBOL(cl_attr2lvb);
-
-/**
  * Converts struct ost_lvb to struct cl_attr.
  *
  * \see cl_attr2lvb
-- 
2.1.0
