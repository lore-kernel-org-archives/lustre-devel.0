From: James Simmons <jsimmons@infradead.org>
Date: Wed,  3 Jun 2015 16:43:20 -0400
Subject: [lustre-devel] [PATCH v3 1/8] staging:lustre: assume a kernel build
In-Reply-To: <1433364207-14307-1-git-send-email-jsimmons@infradead.org>
References: <1433364207-14307-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1433364207-14307-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: John L. Hammond <john.hammond@intel.com>

In lnet/lnet/ and lnet/selftest/ assume a kernel build (assume that
__KERNEL__ is defined). Remove some common code only needed for user
space LNet.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/13121
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  215 +-------------------
 .../staging/lustre/include/linux/lnet/lib-types.h  |   20 --
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   69 +------
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |    2 +-
 drivers/staging/lustre/lnet/lnet/lib-md.c          |    6 +-
 drivers/staging/lustre/lnet/lnet/lib-me.c          |    6 +-
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |    2 +-
 7 files changed, 16 insertions(+), 304 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index ff07703..ac3be94 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -49,24 +49,17 @@
 
 extern lnet_t  the_lnet;			/* THE network */
 
-#if  defined(LNET_USE_LIB_FREELIST)
-/* 1 CPT, simplify implementation... */
-# define LNET_CPT_MAX_BITS      0
-
-#else /* KERNEL and no freelist */
-
-# if (BITS_PER_LONG == 32)
+#if (BITS_PER_LONG == 32)
 /* 2 CPTs, allowing more CPTs might make us under memory pressure */
-#  define LNET_CPT_MAX_BITS     1
+# define LNET_CPT_MAX_BITS     1
 
-# else /* 64-bit system */
+#else /* 64-bit system */
 /*
  * 256 CPTs for thousands of CPUs, allowing more CPTs might make us
  * under risk of consuming all lh_cookie.
  */
-#  define LNET_CPT_MAX_BITS     8
-# endif /* BITS_PER_LONG == 32 */
-#endif
+# define LNET_CPT_MAX_BITS     8
+#endif /* BITS_PER_LONG == 32 */
 
 /* max allowed CPT number */
 #define LNET_CPT_MAX	    (1 << LNET_CPT_MAX_BITS)
@@ -175,191 +168,9 @@ lnet_net_lock_current(void)
 
 #define MAX_PORTALS     64
 
-/* these are only used by code with LNET_USE_LIB_FREELIST, but we still
- * exported them to !LNET_USE_LIB_FREELIST for easy implementation */
-#define LNET_FL_MAX_MES		2048
-#define LNET_FL_MAX_MDS		2048
-#define LNET_FL_MAX_EQS		512
-#define LNET_FL_MAX_MSGS	2048    /* Outstanding messages */
-
-#ifdef LNET_USE_LIB_FREELIST
-
-int lnet_freelist_init(lnet_freelist_t *fl, int n, int size);
-void lnet_freelist_fini(lnet_freelist_t *fl);
-
-static inline void *
-lnet_freelist_alloc(lnet_freelist_t *fl)
-{
-	/* ALWAYS called with liblock held */
-	lnet_freeobj_t *o;
-
-	if (list_empty(&fl->fl_list))
-		return NULL;
-
-	o = list_entry(fl->fl_list.next, lnet_freeobj_t, fo_list);
-	list_del(&o->fo_list);
-	return (void *)&o->fo_contents;
-}
-
-static inline void
-lnet_freelist_free(lnet_freelist_t *fl, void *obj)
-{
-	/* ALWAYS called with liblock held */
-	lnet_freeobj_t *o = list_entry(obj, lnet_freeobj_t, fo_contents);
-
-	list_add(&o->fo_list, &fl->fl_list);
-}
-
-static inline lnet_eq_t *
-lnet_eq_alloc(void)
-{
-	/* NEVER called with resource lock held */
-	struct lnet_res_container *rec = &the_lnet.ln_eq_container;
-	lnet_eq_t		  *eq;
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-
-	lnet_res_lock(0);
-	eq = (lnet_eq_t *)lnet_freelist_alloc(&rec->rec_freelist);
-	lnet_res_unlock(0);
-
-	return eq;
-}
-
-static inline void
-lnet_eq_free_locked(lnet_eq_t *eq)
-{
-	/* ALWAYS called with resource lock held */
-	struct lnet_res_container *rec = &the_lnet.ln_eq_container;
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-	lnet_freelist_free(&rec->rec_freelist, eq);
-}
-
-static inline void
-lnet_eq_free(lnet_eq_t *eq)
-{
-	lnet_res_lock(0);
-	lnet_eq_free_locked(eq);
-	lnet_res_unlock(0);
-}
-
-static inline lnet_libmd_t *
-lnet_md_alloc(lnet_md_t *umd)
-{
-	/* NEVER called with resource lock held */
-	struct lnet_res_container *rec = the_lnet.ln_md_containers[0];
-	lnet_libmd_t		  *md;
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-
-	lnet_res_lock(0);
-	md = (lnet_libmd_t *)lnet_freelist_alloc(&rec->rec_freelist);
-	lnet_res_unlock(0);
-
-	if (md != NULL)
-		INIT_LIST_HEAD(&md->md_list);
-
-	return md;
-}
-
-static inline void
-lnet_md_free_locked(lnet_libmd_t *md)
-{
-	/* ALWAYS called with resource lock held */
-	struct lnet_res_container *rec = the_lnet.ln_md_containers[0];
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-	lnet_freelist_free(&rec->rec_freelist, md);
-}
-
-static inline void
-lnet_md_free(lnet_libmd_t *md)
-{
-	lnet_res_lock(0);
-	lnet_md_free_locked(md);
-	lnet_res_unlock(0);
-}
-
-static inline lnet_me_t *
-lnet_me_alloc(void)
-{
-	/* NEVER called with resource lock held */
-	struct lnet_res_container *rec = the_lnet.ln_me_containers[0];
-	lnet_me_t		  *me;
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-
-	lnet_res_lock(0);
-	me = (lnet_me_t *)lnet_freelist_alloc(&rec->rec_freelist);
-	lnet_res_unlock(0);
-
-	return me;
-}
-
-static inline void
-lnet_me_free_locked(lnet_me_t *me)
-{
-	/* ALWAYS called with resource lock held */
-	struct lnet_res_container *rec = the_lnet.ln_me_containers[0];
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-	lnet_freelist_free(&rec->rec_freelist, me);
-}
-
-static inline void
-lnet_me_free(lnet_me_t *me)
-{
-	lnet_res_lock(0);
-	lnet_me_free_locked(me);
-	lnet_res_unlock(0);
-}
-
-static inline lnet_msg_t *
-lnet_msg_alloc(void)
-{
-	/* NEVER called with network lock held */
-	struct lnet_msg_container *msc = the_lnet.ln_msg_containers[0];
-	lnet_msg_t		  *msg;
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-
-	lnet_net_lock(0);
-	msg = (lnet_msg_t *)lnet_freelist_alloc(&msc->msc_freelist);
-	lnet_net_unlock(0);
-
-	if (msg != NULL) {
-		/* NULL pointers, clear flags etc */
-		memset(msg, 0, sizeof(*msg));
-	}
-	return msg;
-}
-
-static inline void
-lnet_msg_free_locked(lnet_msg_t *msg)
-{
-	/* ALWAYS called with network lock held */
-	struct lnet_msg_container *msc = the_lnet.ln_msg_containers[0];
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-	LASSERT(!msg->msg_onactivelist);
-	lnet_freelist_free(&msc->msc_freelist, msg);
-}
-
-static inline void
-lnet_msg_free(lnet_msg_t *msg)
-{
-	lnet_net_lock(0);
-	lnet_msg_free_locked(msg);
-	lnet_net_unlock(0);
-}
-
-#else /* !LNET_USE_LIB_FREELIST */
-
 static inline lnet_eq_t *
 lnet_eq_alloc(void)
 {
-	/* NEVER called with liblock held */
 	lnet_eq_t *eq;
 
 	LIBCFS_ALLOC(eq, sizeof(*eq));
@@ -369,14 +180,12 @@ lnet_eq_alloc(void)
 static inline void
 lnet_eq_free(lnet_eq_t *eq)
 {
-	/* ALWAYS called with resource lock held */
 	LIBCFS_FREE(eq, sizeof(*eq));
 }
 
 static inline lnet_libmd_t *
 lnet_md_alloc(lnet_md_t *umd)
 {
-	/* NEVER called with liblock held */
 	lnet_libmd_t *md;
 	unsigned int  size;
 	unsigned int  niov;
@@ -405,7 +214,6 @@ lnet_md_alloc(lnet_md_t *umd)
 static inline void
 lnet_md_free(lnet_libmd_t *md)
 {
-	/* ALWAYS called with resource lock held */
 	unsigned int  size;
 
 	if ((md->md_options & LNET_MD_KIOV) != 0)
@@ -419,7 +227,6 @@ lnet_md_free(lnet_libmd_t *md)
 static inline lnet_me_t *
 lnet_me_alloc(void)
 {
-	/* NEVER called with liblock held */
 	lnet_me_t *me;
 
 	LIBCFS_ALLOC(me, sizeof(*me));
@@ -429,14 +236,12 @@ lnet_me_alloc(void)
 static inline void
 lnet_me_free(lnet_me_t *me)
 {
-	/* ALWAYS called with resource lock held */
 	LIBCFS_FREE(me, sizeof(*me));
 }
 
 static inline lnet_msg_t *
 lnet_msg_alloc(void)
 {
-	/* NEVER called with liblock held */
 	lnet_msg_t *msg;
 
 	LIBCFS_ALLOC(msg, sizeof(*msg));
@@ -448,18 +253,10 @@ lnet_msg_alloc(void)
 static inline void
 lnet_msg_free(lnet_msg_t *msg)
 {
-	/* ALWAYS called with network lock held */
 	LASSERT(!msg->msg_onactivelist);
 	LIBCFS_FREE(msg, sizeof(*msg));
 }
 
-#define lnet_eq_free_locked(eq)		lnet_eq_free(eq)
-#define lnet_md_free_locked(md)		lnet_md_free(md)
-#define lnet_me_free_locked(me)		lnet_me_free(me)
-#define lnet_msg_free_locked(msg)	lnet_msg_free(msg)
-
-#endif /* LNET_USE_LIB_FREELIST */
-
 lnet_libhandle_t *lnet_res_lh_lookup(struct lnet_res_container *rec,
 				     __u64 cookie);
 void lnet_res_lh_initialize(struct lnet_res_container *rec,
@@ -467,7 +264,6 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 static inline void
 lnet_res_lh_invalidate(lnet_libhandle_t *lh)
 {
-	/* ALWAYS called with resource lock held */
 	/* NB: cookie is still useful, don't reset it */
 	list_del(&lh->lh_hash_chain);
 }
@@ -486,7 +282,6 @@ lnet_eq2handle(lnet_handle_eq_t *handle, lnet_eq_t *eq)
 static inline lnet_eq_t *
 lnet_handle2eq(lnet_handle_eq_t *handle)
 {
-	/* ALWAYS called with resource lock held */
 	lnet_libhandle_t *lh;
 
 	lh = lnet_res_lh_lookup(&the_lnet.ln_eq_container, handle->cookie);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 5053766..41827a0 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -280,20 +280,6 @@ typedef struct lnet_libmd {
 #define LNET_MD_FLAG_AUTO_UNLINK      (1 << 1)
 #define LNET_MD_FLAG_ABORTED	 (1 << 2)
 
-#ifdef LNET_USE_LIB_FREELIST
-typedef struct {
-	void		  *fl_objs;	  /* single contiguous array of objects */
-	int		    fl_nobjs;	 /* the number of them */
-	int		    fl_objsize;       /* the size (including overhead) of each of them */
-	struct list_head	     fl_list;	  /* where they are enqueued */
-} lnet_freelist_t;
-
-typedef struct {
-	struct list_head	     fo_list;	     /* enqueue on fl_list */
-	void		  *fo_contents;	 /* aligned contents */
-} lnet_freeobj_t;
-#endif
-
 typedef struct {
 	/* info about peers we are trying to fail */
 	struct list_head	     tp_list;	     /* ln_test_peers */
@@ -639,9 +625,6 @@ struct lnet_res_container {
 	__u64			rec_lh_cookie;	/* cookie generator */
 	struct list_head		rec_active;	/* active resource list */
 	struct list_head		*rec_lh_hash;	/* handle hash */
-#ifdef LNET_USE_LIB_FREELIST
-	lnet_freelist_t		rec_freelist;	/* freelist for resources */
-#endif
 };
 
 /* message container */
@@ -654,9 +637,6 @@ struct lnet_msg_container {
 	struct list_head		msc_active;	/* active message list */
 	/* threads doing finalization */
 	void			**msc_finalizers;
-#ifdef LNET_USE_LIB_FREELIST
-	lnet_freelist_t		msc_freelist;	/* freelist for messages */
-#endif
 };
 
 /* Router Checker states */
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 2230eb0..0740ab9 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -356,56 +356,6 @@ lnet_counters_reset(void)
 }
 EXPORT_SYMBOL(lnet_counters_reset);
 
-#ifdef LNET_USE_LIB_FREELIST
-
-int
-lnet_freelist_init(lnet_freelist_t *fl, int n, int size)
-{
-	char *space;
-
-	LASSERT(n > 0);
-
-	size += offsetof(lnet_freeobj_t, fo_contents);
-
-	LIBCFS_ALLOC(space, n * size);
-	if (space == NULL)
-		return -ENOMEM;
-
-	INIT_LIST_HEAD(&fl->fl_list);
-	fl->fl_objs = space;
-	fl->fl_nobjs = n;
-	fl->fl_objsize = size;
-
-	do {
-		memset(space, 0, size);
-		list_add((struct list_head *)space, &fl->fl_list);
-		space += size;
-	} while (--n != 0);
-
-	return 0;
-}
-
-void
-lnet_freelist_fini(lnet_freelist_t *fl)
-{
-	struct list_head *el;
-	int count;
-
-	if (fl->fl_nobjs == 0)
-		return;
-
-	count = 0;
-	for (el = fl->fl_list.next; el != &fl->fl_list; el = el->next)
-		count++;
-
-	LASSERT(count == fl->fl_nobjs);
-
-	LIBCFS_FREE(fl->fl_objs, fl->fl_nobjs * fl->fl_objsize);
-	memset(fl, 0, sizeof(*fl));
-}
-
-#endif /* LNET_USE_LIB_FREELIST */
-
 static __u64
 lnet_create_interface_cookie(void)
 {
@@ -462,9 +412,6 @@ lnet_res_container_cleanup(struct lnet_res_container *rec)
 		       count, lnet_res_type2str(rec->rec_type));
 	}
 
-#ifdef LNET_USE_LIB_FREELIST
-	lnet_freelist_fini(&rec->rec_freelist);
-#endif
 	if (rec->rec_lh_hash != NULL) {
 		LIBCFS_FREE(rec->rec_lh_hash,
 			    LNET_LH_HASH_SIZE * sizeof(rec->rec_lh_hash[0]));
@@ -485,13 +432,6 @@ lnet_res_container_setup(struct lnet_res_container *rec,
 
 	rec->rec_type = type;
 	INIT_LIST_HEAD(&rec->rec_active);
-
-#ifdef LNET_USE_LIB_FREELIST
-	memset(&rec->rec_freelist, 0, sizeof(rec->rec_freelist));
-	rc = lnet_freelist_init(&rec->rec_freelist, objnum, objsz);
-	if (rc != 0)
-		goto out;
-#endif
 	rec->rec_lh_cookie = (cpt << LNET_COOKIE_TYPE_BITS) | type;
 
 	/* Arbitrary choice of hash table size */
@@ -635,13 +575,11 @@ lnet_prepare(lnet_pid_t requested_pid)
 		goto failed;
 
 	rc = lnet_res_container_setup(&the_lnet.ln_eq_container, 0,
-				      LNET_COOKIE_TYPE_EQ, LNET_FL_MAX_EQS,
-				      sizeof(lnet_eq_t));
+				      LNET_COOKIE_TYPE_EQ, 0, 0);
 	if (rc != 0)
 		goto failed;
 
-	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_ME, LNET_FL_MAX_MES,
-					  sizeof(lnet_me_t));
+	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_ME, 0, 0);
 	if (recs == NULL) {
 		rc = -ENOMEM;
 		goto failed;
@@ -649,8 +587,7 @@ lnet_prepare(lnet_pid_t requested_pid)
 
 	the_lnet.ln_me_containers = recs;
 
-	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_MD, LNET_FL_MAX_MDS,
-					  sizeof(lnet_libmd_t));
+	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_MD, 0, 0);
 	if (recs == NULL) {
 		rc = -ENOMEM;
 		goto failed;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index 28858fb..f19ce9a 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -191,7 +191,7 @@ LNetEQFree(lnet_handle_eq_t eqh)
 
 	lnet_res_lh_invalidate(&eq->eq_lh);
 	list_del(&eq->eq_list);
-	lnet_eq_free_locked(eq);
+	lnet_eq_free(eq);
  out:
 	lnet_eq_wait_unlock();
 	lnet_res_unlock(LNET_LOCK_EX);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 5856c30..758f5be 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -82,7 +82,7 @@ lnet_md_unlink(lnet_libmd_t *md)
 
 	LASSERT(!list_empty(&md->md_list));
 	list_del_init(&md->md_list);
-	lnet_md_free_locked(md);
+	lnet_md_free(md);
 }
 
 static int
@@ -320,7 +320,7 @@ LNetMDAttach(lnet_handle_me_t meh, lnet_md_t umd,
 	return 0;
 
  failed:
-	lnet_md_free_locked(md);
+	lnet_md_free(md);
 
 	lnet_res_unlock(cpt);
 	return rc;
@@ -381,7 +381,7 @@ LNetMDBind(lnet_md_t umd, lnet_unlink_t unlink, lnet_handle_md_t *handle)
 	return 0;
 
  failed:
-	lnet_md_free_locked(md);
+	lnet_md_free(md);
 
 	lnet_res_unlock(cpt);
 	return rc;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index 09e9008..42fc99e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -172,7 +172,7 @@ LNetMEInsert(lnet_handle_me_t current_meh,
 
 	current_me = lnet_handle2me(&current_meh);
 	if (current_me == NULL) {
-		lnet_me_free_locked(new_me);
+		lnet_me_free(new_me);
 
 		lnet_res_unlock(cpt);
 		return -ENOENT;
@@ -183,7 +183,7 @@ LNetMEInsert(lnet_handle_me_t current_meh,
 	ptl = the_lnet.ln_portals[current_me->me_portal];
 	if (lnet_ptl_is_unique(ptl)) {
 		/* nosense to insertion on unique portal */
-		lnet_me_free_locked(new_me);
+		lnet_me_free(new_me);
 		lnet_res_unlock(cpt);
 		return -EPERM;
 	}
@@ -276,7 +276,7 @@ lnet_me_unlink(lnet_me_t *me)
 	}
 
 	lnet_res_lh_invalidate(&me->me_lh);
-	lnet_me_free_locked(me);
+	lnet_me_free(me);
 }
 
 #if 0
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 65d7595..43977e8 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -427,7 +427,7 @@ lnet_complete_msg_locked(lnet_msg_t *msg, int cpt)
 	}
 
 	lnet_msg_decommit(msg, cpt, status);
-	lnet_msg_free_locked(msg);
+	lnet_msg_free(msg);
 	return 0;
 }
 
-- 
1.7.1
