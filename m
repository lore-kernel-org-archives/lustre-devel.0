Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5D186C19F2A
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:38:37 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4LyrwW17KLz23JW;
	Wed,  3 Aug 2022 18:38:35 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwM4Cv5z1y7h
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:27 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id AC700100AFF3;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A39CB8D620; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:37:48 -0400
Message-Id: <1659577097-19253-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/32] lustre: echo: remove client operations
 from echo objects
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: "John L. Hammond" <jhammond@whamcloud.com>

Remove the client (io, page, lock) operations from echo_client
objects. This will facilitate the simplification of CLIO.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10994
Lustre-commit: 6060ee55b194e37e8 ("LU-10994 echo: remove client operations from echo objects")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47240
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdecho/echo_client.c | 542 +---------------------------------------
 1 file changed, 8 insertions(+), 534 deletions(-)

diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 4cc046a..f25ea41 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -70,7 +70,6 @@ struct echo_object {
 	struct echo_device	       *eo_dev;
 	struct list_head		eo_obj_chain;
 	struct lov_oinfo	       *eo_oinfo;
-	atomic_t			eo_npages;
 	int				eo_deleted;
 };
 
@@ -79,19 +78,6 @@ struct echo_object_conf {
 	struct lov_oinfo	      **eoc_oinfo;
 };
 
-struct echo_page {
-	struct cl_page_slice		ep_cl;
-	unsigned long			ep_lock;
-};
-
-struct echo_lock {
-	struct cl_lock_slice		el_cl;
-	struct list_head		el_chain;
-	struct echo_object	       *el_object;
-	u64				el_cookie;
-	atomic_t			el_refcount;
-};
-
 static int echo_client_setup(const struct lu_env *env,
 			     struct obd_device *obd,
 			     struct lustre_cfg *lcfg);
@@ -100,48 +86,34 @@ static int echo_client_setup(const struct lu_env *env,
 /** \defgroup echo_helpers Helper functions
  * @{
  */
-static inline struct echo_device *cl2echo_dev(const struct cl_device *dev)
+static struct echo_device *cl2echo_dev(const struct cl_device *dev)
 {
 	return container_of_safe(dev, struct echo_device, ed_cl);
 }
 
-static inline struct cl_device *echo_dev2cl(struct echo_device *d)
+static struct cl_device *echo_dev2cl(struct echo_device *d)
 {
 	return &d->ed_cl;
 }
 
-static inline struct echo_device *obd2echo_dev(const struct obd_device *obd)
+static struct echo_device *obd2echo_dev(const struct obd_device *obd)
 {
 	return cl2echo_dev(lu2cl_dev(obd->obd_lu_dev));
 }
 
-static inline struct cl_object *echo_obj2cl(struct echo_object *eco)
+static struct cl_object *echo_obj2cl(struct echo_object *eco)
 {
 	return &eco->eo_cl;
 }
 
-static inline struct echo_object *cl2echo_obj(const struct cl_object *o)
+static struct echo_object *cl2echo_obj(const struct cl_object *o)
 {
 	return container_of(o, struct echo_object, eo_cl);
 }
 
-static inline struct echo_page *cl2echo_page(const struct cl_page_slice *s)
-{
-	return container_of(s, struct echo_page, ep_cl);
-}
-
-static inline struct echo_lock *cl2echo_lock(const struct cl_lock_slice *s)
-{
-	return container_of(s, struct echo_lock, el_cl);
-}
-
-static inline struct cl_lock *echo_lock2cl(const struct echo_lock *ecl)
-{
-	return ecl->el_cl.cls_lock;
-}
-
 static struct lu_context_key echo_thread_key;
-static inline struct echo_thread_info *echo_env_info(const struct lu_env *env)
+
+static struct echo_thread_info *echo_env_info(const struct lu_env *env)
 {
 	struct echo_thread_info *info;
 
@@ -158,16 +130,10 @@ struct echo_object_conf *cl2echo_conf(const struct cl_object_conf *c)
 
 /** @} echo_helpers */
 static int cl_echo_object_put(struct echo_object *eco);
-static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
-			      struct page **pages, int npages, int async);
 
 struct echo_thread_info {
 	struct echo_object_conf		eti_conf;
 	struct lustre_md		eti_md;
-
-	struct cl_2queue		eti_queue;
-	struct cl_io			eti_io;
-	struct cl_lock			eti_lock;
 	struct lu_fid			eti_fid;
 	struct lu_fid			eti_fid2;
 };
@@ -177,18 +143,12 @@ struct echo_session_info {
 	unsigned long			dummy;
 };
 
-static struct kmem_cache *echo_lock_kmem;
 static struct kmem_cache *echo_object_kmem;
 static struct kmem_cache *echo_thread_kmem;
 static struct kmem_cache *echo_session_kmem;
 
 static struct lu_kmem_descr echo_caches[] = {
 	{
-		.ckd_cache = &echo_lock_kmem,
-		.ckd_name  = "echo_lock_kmem",
-		.ckd_size  = sizeof(struct echo_lock)
-	},
-	{
 		.ckd_cache = &echo_object_kmem,
 		.ckd_name  = "echo_object_kmem",
 		.ckd_size  = sizeof(struct echo_object)
@@ -208,191 +168,6 @@ struct echo_session_info {
 	}
 };
 
-/** \defgroup echo_page Page operations
- *
- * Echo page operations.
- *
- * @{
- */
-static int echo_page_own(const struct lu_env *env,
-			 const struct cl_page_slice *slice,
-			 struct cl_io *io, int nonblock)
-{
-	struct echo_page *ep = cl2echo_page(slice);
-
-	if (nonblock) {
-		if (test_and_set_bit(0, &ep->ep_lock))
-			return -EAGAIN;
-	} else {
-		while (test_and_set_bit(0, &ep->ep_lock))
-			wait_on_bit(&ep->ep_lock, 0, TASK_UNINTERRUPTIBLE);
-	}
-	return 0;
-}
-
-static void echo_page_disown(const struct lu_env *env,
-			     const struct cl_page_slice *slice,
-			     struct cl_io *io)
-{
-	struct echo_page *ep = cl2echo_page(slice);
-
-	LASSERT(test_bit(0, &ep->ep_lock));
-	clear_and_wake_up_bit(0, &ep->ep_lock);
-}
-
-static void echo_page_discard(const struct lu_env *env,
-			      const struct cl_page_slice *slice,
-			      struct cl_io *unused)
-{
-	cl_page_delete(env, slice->cpl_page);
-}
-
-static int echo_page_is_vmlocked(const struct lu_env *env,
-				 const struct cl_page_slice *slice)
-{
-	if (test_bit(0, &cl2echo_page(slice)->ep_lock))
-		return -EBUSY;
-	return -ENODATA;
-}
-
-static void echo_page_completion(const struct lu_env *env,
-				 const struct cl_page_slice *slice,
-				 int ioret)
-{
-	LASSERT(slice->cpl_page->cp_sync_io);
-}
-
-static void echo_page_fini(const struct lu_env *env,
-			   struct cl_page_slice *slice,
-			   struct pagevec *pvec)
-{
-	struct echo_object *eco = cl2echo_obj(slice->cpl_obj);
-
-	atomic_dec(&eco->eo_npages);
-	put_page(slice->cpl_page->cp_vmpage);
-}
-
-static int echo_page_prep(const struct lu_env *env,
-			  const struct cl_page_slice *slice,
-			  struct cl_io *unused)
-{
-	return 0;
-}
-
-static int echo_page_print(const struct lu_env *env,
-			   const struct cl_page_slice *slice,
-			   void *cookie, lu_printer_t printer)
-{
-	struct echo_page *ep = cl2echo_page(slice);
-
-	(*printer)(env, cookie, LUSTRE_ECHO_CLIENT_NAME "-page@%p %d vm@%p\n",
-		   ep, test_bit(0, &ep->ep_lock),
-		   slice->cpl_page->cp_vmpage);
-	return 0;
-}
-
-static const struct cl_page_operations echo_page_ops = {
-	.cpo_own		= echo_page_own,
-	.cpo_disown		= echo_page_disown,
-	.cpo_discard		= echo_page_discard,
-	.cpo_fini		= echo_page_fini,
-	.cpo_print		= echo_page_print,
-	.cpo_is_vmlocked	= echo_page_is_vmlocked,
-	.io = {
-		[CRT_READ] = {
-			.cpo_prep	= echo_page_prep,
-			.cpo_completion	= echo_page_completion,
-		},
-		[CRT_WRITE] = {
-			.cpo_prep	= echo_page_prep,
-			.cpo_completion	= echo_page_completion,
-		}
-	}
-};
-
-/** @} echo_page */
-
-/** \defgroup echo_lock Locking
- *
- * echo lock operations
- *
- * @{
- */
-static void echo_lock_fini(const struct lu_env *env,
-			   struct cl_lock_slice *slice)
-{
-	struct echo_lock *ecl = cl2echo_lock(slice);
-
-	LASSERT(list_empty(&ecl->el_chain));
-	kmem_cache_free(echo_lock_kmem, ecl);
-}
-
-static const struct cl_lock_operations echo_lock_ops = {
-	.clo_fini		= echo_lock_fini,
-};
-
-/** @} echo_lock */
-
-/** \defgroup echo_cl_ops cl_object operations
- *
- * operations for cl_object
- *
- * @{
- */
-static int echo_page_init(const struct lu_env *env, struct cl_object *obj,
-			  struct cl_page *page, pgoff_t index)
-{
-	struct echo_page *ep = cl_object_page_slice(obj, page);
-	struct echo_object *eco = cl2echo_obj(obj);
-
-	get_page(page->cp_vmpage);
-	/*
-	 * ep_lock is similar to the lock_page() lock, and
-	 * cannot usefully be monitored by lockdep.
-	 * So just a bit in an "unsigned long" and use the
-	 * wait_on_bit() interface to wait for the bit to be clera.
-	 */
-	ep->ep_lock = 0;
-	cl_page_slice_add(page, &ep->ep_cl, obj, &echo_page_ops);
-	atomic_inc(&eco->eo_npages);
-	return 0;
-}
-
-static int echo_io_init(const struct lu_env *env, struct cl_object *obj,
-			struct cl_io *io)
-{
-	return 0;
-}
-
-static int echo_lock_init(const struct lu_env *env,
-			  struct cl_object *obj, struct cl_lock *lock,
-			  const struct cl_io *unused)
-{
-	struct echo_lock *el;
-
-	el = kmem_cache_zalloc(echo_lock_kmem, GFP_NOFS);
-	if (el) {
-		cl_lock_slice_add(lock, &el->el_cl, obj, &echo_lock_ops);
-		el->el_object = cl2echo_obj(obj);
-		INIT_LIST_HEAD(&el->el_chain);
-		atomic_set(&el->el_refcount, 0);
-	}
-	return !el ? -ENOMEM : 0;
-}
-
-static int echo_conf_set(const struct lu_env *env, struct cl_object *obj,
-			 const struct cl_object_conf *conf)
-{
-	return 0;
-}
-
-static const struct cl_object_operations echo_cl_obj_ops = {
-	.coo_page_init		= echo_page_init,
-	.coo_lock_init		= echo_lock_init,
-	.coo_io_init		= echo_io_init,
-	.coo_conf_set		= echo_conf_set
-};
-
 /** @} echo_cl_ops */
 
 /** \defgroup echo_lu_ops lu_object operations
@@ -434,8 +209,7 @@ static int echo_object_init(const struct lu_env *env, struct lu_object *obj,
 	*econf->eoc_oinfo = NULL;
 
 	eco->eo_dev = ed;
-	atomic_set(&eco->eo_npages, 0);
-	cl_object_page_init(lu2cl(obj), sizeof(struct echo_page));
+	cl_object_page_init(lu2cl(obj), 0);
 
 	spin_lock(&ec->ec_lock);
 	list_add_tail(&eco->eo_obj_chain, &ec->ec_objects);
@@ -455,8 +229,6 @@ static void echo_object_delete(const struct lu_env *env, struct lu_object *obj)
 
 	ec = eco->eo_dev->ed_ec;
 
-	LASSERT(atomic_read(&eco->eo_npages) == 0);
-
 	spin_lock(&ec->ec_lock);
 	list_del_init(&eco->eo_obj_chain);
 	spin_unlock(&ec->ec_lock);
@@ -527,7 +299,6 @@ static struct lu_object *echo_object_alloc(const struct lu_env *env,
 		lu_object_init(obj, &hdr->coh_lu, dev);
 		lu_object_add_top(&hdr->coh_lu, obj);
 
-		eco->eo_cl.co_ops = &echo_cl_obj_ops;
 		obj->lo_ops = &echo_lu_obj_ops;
 	}
 	return obj;
@@ -741,15 +512,6 @@ static struct lu_device *echo_device_fini(const struct lu_env *env,
 	return NULL;
 }
 
-static void echo_lock_release(const struct lu_env *env,
-			      struct echo_lock *ecl,
-			      int still_used)
-{
-	struct cl_lock *clk = echo_lock2cl(ecl);
-
-	cl_lock_release(env, clk);
-}
-
 static struct lu_device *echo_device_free(const struct lu_env *env,
 					  struct lu_device *d)
 {
@@ -934,193 +696,6 @@ static int cl_echo_object_put(struct echo_object *eco)
 	return 0;
 }
 
-static int __cl_echo_enqueue(struct lu_env *env, struct echo_object *eco,
-			     u64 start, u64 end, int mode,
-			     u64 *cookie, u32 enqflags)
-{
-	struct cl_io *io;
-	struct cl_lock *lck;
-	struct cl_object *obj;
-	struct cl_lock_descr *descr;
-	struct echo_thread_info *info;
-	int rc = -ENOMEM;
-
-	info = echo_env_info(env);
-	io = &info->eti_io;
-	lck = &info->eti_lock;
-	obj = echo_obj2cl(eco);
-
-	memset(lck, 0, sizeof(*lck));
-	descr = &lck->cll_descr;
-	descr->cld_obj = obj;
-	descr->cld_start = cl_index(obj, start);
-	descr->cld_end = cl_index(obj, end);
-	descr->cld_mode = mode == LCK_PW ? CLM_WRITE : CLM_READ;
-	descr->cld_enq_flags = enqflags;
-	io->ci_obj = obj;
-
-	rc = cl_lock_request(env, io, lck);
-	if (rc == 0) {
-		struct echo_client_obd *ec = eco->eo_dev->ed_ec;
-		struct echo_lock *el;
-
-		el = cl2echo_lock(cl_lock_at(lck, &echo_device_type));
-		spin_lock(&ec->ec_lock);
-		if (list_empty(&el->el_chain)) {
-			list_add(&el->el_chain, &ec->ec_locks);
-			el->el_cookie = ++ec->ec_unique;
-		}
-		atomic_inc(&el->el_refcount);
-		*cookie = el->el_cookie;
-		spin_unlock(&ec->ec_lock);
-	}
-	return rc;
-}
-
-static int __cl_echo_cancel(struct lu_env *env, struct echo_device *ed,
-			    u64 cookie)
-{
-	struct echo_client_obd *ec = ed->ed_ec;
-	struct echo_lock *ecl = NULL;
-	int found = 0, still_used = 0;
-
-	spin_lock(&ec->ec_lock);
-	list_for_each_entry(ecl, &ec->ec_locks, el_chain) {
-		CDEBUG(D_INFO, "ecl: %p, cookie: %#llx\n", ecl, ecl->el_cookie);
-		found = (ecl->el_cookie == cookie);
-		if (found) {
-			if (atomic_dec_and_test(&ecl->el_refcount))
-				list_del_init(&ecl->el_chain);
-			else
-				still_used = 1;
-			break;
-		}
-	}
-	spin_unlock(&ec->ec_lock);
-
-	if (!found)
-		return -ENOENT;
-
-	echo_lock_release(env, ecl, still_used);
-	return 0;
-}
-
-static void echo_commit_callback(const struct lu_env *env, struct cl_io *io,
-				 struct pagevec *pvec)
-{
-	struct echo_thread_info *info;
-	struct cl_2queue *queue;
-	int i = 0;
-
-	info = echo_env_info(env);
-	LASSERT(io == &info->eti_io);
-
-	queue = &info->eti_queue;
-
-	for (i = 0; i < pagevec_count(pvec); i++) {
-		struct page *vmpage = pvec->pages[i];
-		struct cl_page *page = (struct cl_page *)vmpage->private;
-
-		cl_page_list_add(&queue->c2_qout, page, true);
-	}
-}
-
-static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
-			      struct page **pages, int npages, int async)
-{
-	struct lu_env *env;
-	struct echo_thread_info *info;
-	struct cl_object *obj = echo_obj2cl(eco);
-	struct echo_device *ed  = eco->eo_dev;
-	struct cl_2queue *queue;
-	struct cl_io *io;
-	struct cl_page *clp;
-	struct lustre_handle lh = { 0 };
-	size_t page_size = cl_page_size(obj);
-	u16 refcheck;
-	int rc;
-	int i;
-
-	LASSERT((offset & ~PAGE_MASK) == 0);
-	LASSERT(ed->ed_next);
-	env = cl_env_get(&refcheck);
-	if (IS_ERR(env))
-		return PTR_ERR(env);
-
-	info = echo_env_info(env);
-	io = &info->eti_io;
-	queue = &info->eti_queue;
-
-	cl_2queue_init(queue);
-
-	io->ci_ignore_layout = 1;
-	rc = cl_io_init(env, io, CIT_MISC, obj);
-	if (rc < 0)
-		goto out;
-	LASSERT(rc == 0);
-
-	rc = __cl_echo_enqueue(env, eco, offset,
-			       offset + npages * PAGE_SIZE - 1,
-			       rw == READ ? LCK_PR : LCK_PW, &lh.cookie,
-			       CEF_NEVER);
-	if (rc < 0)
-		goto error_lock;
-
-	for (i = 0; i < npages; i++) {
-		LASSERT(pages[i]);
-		clp = cl_page_find(env, obj, cl_index(obj, offset),
-				   pages[i], CPT_TRANSIENT);
-		if (IS_ERR(clp)) {
-			rc = PTR_ERR(clp);
-			break;
-		}
-		LASSERT(clp->cp_type == CPT_TRANSIENT);
-
-		rc = cl_page_own(env, io, clp);
-		if (rc) {
-			LASSERT(clp->cp_state == CPS_FREEING);
-			cl_page_put(env, clp);
-			break;
-		}
-		/*
-		 * Add a page to the incoming page list of 2-queue.
-		 */
-		cl_page_list_add(&queue->c2_qin, clp, true);
-
-		/* drop the reference count for cl_page_find, so that the page
-		 * will be freed in cl_2queue_fini.
-		 */
-		cl_page_put(env, clp);
-		cl_page_clip(env, clp, 0, page_size);
-
-		offset += page_size;
-	}
-
-	if (rc == 0) {
-		enum cl_req_type typ = rw == READ ? CRT_READ : CRT_WRITE;
-
-		async = async && (typ == CRT_WRITE);
-		if (async)
-			rc = cl_io_commit_async(env, io, &queue->c2_qin,
-						0, PAGE_SIZE,
-						echo_commit_callback);
-		else
-			rc = cl_io_submit_sync(env, io, typ, queue, 0);
-		CDEBUG(D_INFO, "echo_client %s write returns %d\n",
-		       async ? "async" : "sync", rc);
-	}
-
-	__cl_echo_cancel(env, ed, lh.cookie);
-error_lock:
-	cl_2queue_discard(env, io, queue);
-	cl_2queue_disown(env, io, queue);
-	cl_2queue_fini(env, queue);
-	cl_io_fini(env, io);
-out:
-	cl_env_put(env, &refcheck);
-	return rc;
-}
-
 /** @} echo_exports */
 
 static u64 last_object_id;
@@ -1264,101 +839,6 @@ static int echo_client_page_debug_check(struct page *page, u64 id,
 	return rc;
 }
 
-static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
-			    struct echo_object *eco, u64 offset,
-			    u64 count, int async)
-{
-	u32 npages;
-	struct brw_page	*pga;
-	struct brw_page	*pgp;
-	struct page **pages;
-	u64 off;
-	int i;
-	int rc;
-	int verify;
-	gfp_t gfp_mask;
-	int brw_flags = 0;
-
-	verify = (ostid_id(&oa->o_oi) != ECHO_PERSISTENT_OBJID &&
-		  (oa->o_valid & OBD_MD_FLFLAGS) != 0 &&
-		  (oa->o_flags & OBD_FL_DEBUG_CHECK) != 0);
-
-	gfp_mask = ((ostid_id(&oa->o_oi) & 2) == 0) ? GFP_KERNEL : GFP_HIGHUSER;
-
-	LASSERT(rw == OBD_BRW_WRITE || rw == OBD_BRW_READ);
-
-	if (count <= 0 ||
-	    (count & (~PAGE_MASK)) != 0)
-		return -EINVAL;
-
-	/* XXX think again with misaligned I/O */
-	npages = count >> PAGE_SHIFT;
-
-	if (rw == OBD_BRW_WRITE)
-		brw_flags = OBD_BRW_ASYNC;
-
-	pga = kcalloc(npages, sizeof(*pga), GFP_NOFS);
-	if (!pga)
-		return -ENOMEM;
-
-	pages = kvmalloc_array(npages, sizeof(*pages),
-			       GFP_KERNEL | __GFP_ZERO);
-	if (!pages) {
-		kfree(pga);
-		return -ENOMEM;
-	}
-
-	for (i = 0, pgp = pga, off = offset;
-	     i < npages;
-	     i++, pgp++, off += PAGE_SIZE) {
-		LASSERT(!pgp->pg);      /* for cleanup */
-
-		rc = -ENOMEM;
-		pgp->pg = alloc_page(gfp_mask);
-		if (!pgp->pg)
-			goto out;
-
-		/* set mapping so page is not considered encrypted */
-		pgp->pg->mapping = ECHO_MAPPING_UNENCRYPTED;
-		pages[i] = pgp->pg;
-		pgp->count = PAGE_SIZE;
-		pgp->off = off;
-		pgp->flag = brw_flags;
-
-		if (verify)
-			echo_client_page_debug_setup(pgp->pg, rw,
-						     ostid_id(&oa->o_oi), off,
-						     pgp->count);
-	}
-
-	/* brw mode can only be used at client */
-	LASSERT(ed->ed_next);
-	rc = cl_echo_object_brw(eco, rw, offset, pages, npages, async);
-
-out:
-	if (rc != 0 || rw != OBD_BRW_READ)
-		verify = 0;
-
-	for (i = 0, pgp = pga; i < npages; i++, pgp++) {
-		if (!pgp->pg)
-			continue;
-
-		if (verify) {
-			int vrc;
-
-			vrc = echo_client_page_debug_check(pgp->pg,
-							   ostid_id(&oa->o_oi),
-							   pgp->off, pgp->count);
-			if (vrc != 0 && rc == 0)
-				rc = vrc;
-		}
-		__free_page(pgp->pg);
-	}
-	kfree(pga);
-	kvfree(pages);
-	return rc;
-}
-
 static int echo_client_prep_commit(const struct lu_env *env,
 				   struct obd_export *exp, int rw,
 				   struct obdo *oa, struct echo_object *eco,
@@ -1491,12 +971,6 @@ static int echo_client_brw_ioctl(const struct lu_env *env, int rw,
 		data->ioc_plen1 = PTLRPC_MAX_BRW_SIZE;
 
 	switch (test_mode) {
-	case 1:
-		/* fall through */
-	case 2:
-		rc = echo_client_kbrw(ed, rw, oa, eco, data->ioc_offset,
-				      data->ioc_count, async);
-		break;
 	case 3:
 		rc = echo_client_prep_commit(env, ec->ec_exp, rw, oa, eco,
 					     data->ioc_offset, data->ioc_count,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
