Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id EA5A9C19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:38:42 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyrwf3BkWz23K8;
	Wed,  3 Aug 2022 18:38:42 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwP0vxYz232N
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:29 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B1685100AFF5;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AD60E80795; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:37:51 -0400
Message-Id: <1659577097-19253-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/32] lustre: clio: remove cpo_assume,
 cpo_unassume, cpo_fini
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

Remove the cl_page methods cpo_assume, cpo_unassume, and
cpo_fini. These methods were only implemented by the vvp layer and so
they can be easily inlined into cl_page_assume() and
cl_page_unassume(). Remove vvp_page_delete() by inlining its contents
to cl_page_delete0().

WC-bug-id: https://jira.whamcloud.com/browse/LU-10994
Lustre-commit: 9045894fe0f503333 ("LU-10994 clio: remove cpo_assume, cpo_unassume, cpo_fini")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47373
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  23 --------
 fs/lustre/llite/vvp_page.c    |  71 +------------------------
 fs/lustre/obdclass/cl_page.c  | 119 +++++++++++++++++++++++++-----------------
 3 files changed, 73 insertions(+), 140 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 4460ae1..c66e98c5 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -838,25 +838,6 @@ struct cl_page_operations {
 	 */
 
 	/**
-	 * Called for a page that is already "owned" by @io from VM point of
-	 * view. Optional.
-	 *
-	 * \see cl_page_assume()
-	 * \see vvp_page_assume(), lov_page_assume()
-	 */
-	void (*cpo_assume)(const struct lu_env *env,
-			   const struct cl_page_slice *slice, struct cl_io *io);
-	/** Dual to cl_page_operations::cpo_assume(). Optional. Called
-	 * bottom-to-top when IO releases a page without actually unlocking
-	 * it.
-	 *
-	 * \see cl_page_unassume()
-	 * \see vvp_page_unassume()
-	 */
-	void (*cpo_unassume)(const struct lu_env *env,
-			     const struct cl_page_slice *slice,
-			     struct cl_io *io);
-	/**
 	 * Update file attributes when all we have is this page.  Used for tiny
 	 * writes to update attributes when we don't have a full cl_io.
 	 */
@@ -884,10 +865,6 @@ struct cl_page_operations {
 	 */
 	void (*cpo_delete)(const struct lu_env *env,
 			   const struct cl_page_slice *slice);
-	/** Destructor. Frees resources and slice itself. */
-	void (*cpo_fini)(const struct lu_env *env,
-			 struct cl_page_slice *slice,
-			 struct pagevec *pvec);
 	/**
 	 * Optional debugging helper. Prints given page slice.
 	 *
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index 8875a62..db1cd7c1 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -52,48 +52,6 @@
  * Page operations.
  *
  */
-static void vvp_page_fini(const struct lu_env *env,
-			  struct cl_page_slice *slice,
-			  struct pagevec *pvec)
-{
-	struct vvp_page *vpg = cl2vvp_page(slice);
-	struct page *vmpage = vpg->vpg_page;
-
-	/*
-	 * vmpage->private was already cleared when page was moved into
-	 * VPG_FREEING state.
-	 */
-	LASSERT((struct cl_page *)vmpage->private != slice->cpl_page);
-	LASSERT(vmpage);
-	if (pvec) {
-		if (!pagevec_add(pvec, vmpage))
-			pagevec_release(pvec);
-	} else {
-		put_page(vmpage);
-	}
-}
-
-static void vvp_page_assume(const struct lu_env *env,
-			    const struct cl_page_slice *slice,
-			    struct cl_io *unused)
-{
-	struct page *vmpage = cl2vm_page(slice);
-
-	LASSERT(vmpage);
-	LASSERT(PageLocked(vmpage));
-	wait_on_page_writeback(vmpage);
-}
-
-static void vvp_page_unassume(const struct lu_env *env,
-			      const struct cl_page_slice *slice,
-			      struct cl_io *unused)
-{
-	struct page *vmpage = cl2vm_page(slice);
-
-	LASSERT(vmpage);
-	LASSERT(PageLocked(vmpage));
-}
-
 static void vvp_page_discard(const struct lu_env *env,
 			     const struct cl_page_slice *slice,
 			     struct cl_io *unused)
@@ -105,29 +63,6 @@ static void vvp_page_discard(const struct lu_env *env,
 		ll_ra_stats_inc(vmpage->mapping->host, RA_STAT_DISCARDED);
 }
 
-static void vvp_page_delete(const struct lu_env *env,
-			    const struct cl_page_slice *slice)
-{
-	struct page *vmpage = cl2vm_page(slice);
-	struct cl_page *page = slice->cpl_page;
-
-	LASSERT(PageLocked(vmpage));
-	LASSERT((struct cl_page *)vmpage->private == page);
-
-	/* Drop the reference count held in vvp_page_init */
-	if (refcount_dec_and_test(&page->cp_ref)) {
-		/* It mustn't reach zero here! */
-		LASSERTF(0, "page = %p, refc reached zero\n", page);
-	}
-
-	ClearPagePrivate(vmpage);
-	vmpage->private = 0;
-	/*
-	 * Reference from vmpage to cl_page is removed, but the reference back
-	 * is still here. It is removed later in vvp_page_fini().
-	 */
-}
-
 static int vvp_page_prep_read(const struct lu_env *env,
 			      const struct cl_page_slice *slice,
 			      struct cl_io *unused)
@@ -313,11 +248,7 @@ static int vvp_page_fail(const struct lu_env *env,
 }
 
 static const struct cl_page_operations vvp_page_ops = {
-	.cpo_assume		= vvp_page_assume,
-	.cpo_unassume		= vvp_page_unassume,
 	.cpo_discard		= vvp_page_discard,
-	.cpo_delete		= vvp_page_delete,
-	.cpo_fini		= vvp_page_fini,
 	.cpo_print		= vvp_page_print,
 	.io = {
 		[CRT_READ] = {
@@ -355,7 +286,7 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 				  &vvp_transient_page_ops);
 	} else {
 		get_page(vmpage);
-		/* in cache, decref in vvp_page_delete */
+		/* in cache, decref in cl_page_delete */
 		refcount_inc(&page->cp_ref);
 		SetPagePrivate(vmpage);
 		vmpage->private = (unsigned long)page;
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index cff2c54..6319c3d 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -129,29 +129,39 @@ static void __cl_page_free(struct cl_page *cl_page, unsigned short bufsize)
 	}
 }
 
-static void cl_page_free(const struct lu_env *env, struct cl_page *cl_page,
+static void cl_page_free(const struct lu_env *env, struct cl_page *cp,
 			 struct pagevec *pvec)
 {
-	struct cl_object *obj = cl_page->cp_obj;
+	struct cl_object *obj = cp->cp_obj;
 	unsigned short bufsize = cl_object_header(obj)->coh_page_bufsize;
-	struct cl_page_slice *slice;
-	int i;
+	struct page *vmpage;
 
-	PASSERT(env, cl_page, list_empty(&cl_page->cp_batch));
-	PASSERT(env, cl_page, !cl_page->cp_owner);
-	PASSERT(env, cl_page, cl_page->cp_state == CPS_FREEING);
+	PASSERT(env, cp, list_empty(&cp->cp_batch));
+	PASSERT(env, cp, !cp->cp_owner);
+	PASSERT(env, cp, cp->cp_state == CPS_FREEING);
 
-	cl_page_slice_for_each(cl_page, slice, i) {
-		if (unlikely(slice->cpl_ops->cpo_fini))
-			slice->cpl_ops->cpo_fini(env, slice, pvec);
+	if (cp->cp_type == CPT_CACHEABLE) {
+		/* vmpage->private was already cleared when page was
+		 * moved into CPS_FREEING state.
+		 */
+		vmpage = cp->cp_vmpage;
+		LASSERT(vmpage);
+		LASSERT((struct cl_page *)vmpage->private != cp);
+
+		if (pvec) {
+			if (!pagevec_add(pvec, vmpage))
+				pagevec_release(pvec);
+		} else {
+			put_page(vmpage);
+		}
 	}
-	cl_page->cp_layer_count = 0;
-	lu_object_ref_del_at(&obj->co_lu, &cl_page->cp_obj_ref,
-			     "cl_page", cl_page);
-	if (cl_page->cp_type != CPT_TRANSIENT)
+
+	cp->cp_layer_count = 0;
+	lu_object_ref_del_at(&obj->co_lu, &cp->cp_obj_ref, "cl_page", cp);
+	if (cp->cp_type != CPT_TRANSIENT)
 		cl_object_put(env, obj);
-	lu_ref_fini(&cl_page->cp_reference);
-	__cl_page_free(cl_page, bufsize);
+	lu_ref_fini(&cp->cp_reference);
+	__cl_page_free(cp, bufsize);
 }
 
 static struct cl_page *__cl_page_alloc(struct cl_object *o)
@@ -613,28 +623,27 @@ int cl_page_own_try(const struct lu_env *env, struct cl_io *io,
  *
  * Called when page is already locked by the hosting VM.
  *
- * \pre !cl_page_is_owned(cl_page, io)
- * \post cl_page_is_owned(cl_page, io)
+ * \pre !cl_page_is_owned(cp, io)
+ * \post cl_page_is_owned(cp, io)
  *
  * \see cl_page_operations::cpo_assume()
  */
 void cl_page_assume(const struct lu_env *env,
-		    struct cl_io *io, struct cl_page *cl_page)
+		    struct cl_io *io, struct cl_page *cp)
 {
-	const struct cl_page_slice *slice;
-	int i;
-
-	io = cl_io_top(io);
+	struct page *vmpage;
 
-	cl_page_slice_for_each(cl_page, slice, i) {
-		if (slice->cpl_ops->cpo_assume)
-			(*slice->cpl_ops->cpo_assume)(env, slice, io);
+	if (cp->cp_type == CPT_CACHEABLE) {
+		vmpage = cp->cp_vmpage;
+		LASSERT(vmpage);
+		LASSERT(PageLocked(vmpage));
+		wait_on_page_writeback(vmpage);
 	}
 
-	PASSERT(env, cl_page, !cl_page->cp_owner);
-	cl_page->cp_owner = cl_io_top(io);
-	cl_page_owner_set(cl_page);
-	cl_page_state_set(env, cl_page, CPS_OWNED);
+	PASSERT(env, cp, !cp->cp_owner);
+	cp->cp_owner = cl_io_top(io);
+	cl_page_owner_set(cp);
+	cl_page_state_set(env, cp, CPS_OWNED);
 }
 EXPORT_SYMBOL(cl_page_assume);
 
@@ -644,24 +653,23 @@ void cl_page_assume(const struct lu_env *env,
  * Moves cl_page into cl_page_state::CPS_CACHED without releasing a lock
  * on the underlying VM page (as VM is supposed to do this itself).
  *
- * \pre   cl_page_is_owned(cl_page, io)
- * \post !cl_page_is_owned(cl_page, io)
+ * \pre   cl_page_is_owned(cp, io)
+ * \post !cl_page_is_owned(cp, io)
  *
  * \see cl_page_assume()
  */
 void cl_page_unassume(const struct lu_env *env,
-		      struct cl_io *io, struct cl_page *cl_page)
+		      struct cl_io *io, struct cl_page *cp)
 {
-	const struct cl_page_slice *slice;
-	int i;
+	struct page *vmpage;
 
-	io = cl_io_top(io);
-	cl_page_owner_clear(cl_page);
-	cl_page_state_set(env, cl_page, CPS_CACHED);
+	cl_page_owner_clear(cp);
+	cl_page_state_set(env, cp, CPS_CACHED);
 
-	cl_page_slice_for_each_reverse(cl_page, slice, i) {
-		if (slice->cpl_ops->cpo_unassume)
-			(*slice->cpl_ops->cpo_unassume)(env, slice, io);
+	if (cp->cp_type == CPT_CACHEABLE) {
+		vmpage = cp->cp_vmpage;
+		LASSERT(vmpage);
+		LASSERT(PageLocked(vmpage));
 	}
 }
 EXPORT_SYMBOL(cl_page_unassume);
@@ -721,24 +729,41 @@ void cl_page_discard(const struct lu_env *env,
  * cl_pages, e.g,. in a error handling cl_page_find()->__cl_page_delete()
  * path. Doesn't check page invariant.
  */
-static void __cl_page_delete(const struct lu_env *env,
-			     struct cl_page *cl_page)
+static void __cl_page_delete(const struct lu_env *env, struct cl_page *cp)
 {
 	const struct cl_page_slice *slice;
+	struct page *vmpage;
 	int i;
 
-	PASSERT(env, cl_page, cl_page->cp_state != CPS_FREEING);
+	PASSERT(env, cp, cp->cp_state != CPS_FREEING);
 
 	/*
 	 * Sever all ways to obtain new pointers to @cl_page.
 	 */
-	cl_page_owner_clear(cl_page);
-	__cl_page_state_set(env, cl_page, CPS_FREEING);
+	cl_page_owner_clear(cp);
+	__cl_page_state_set(env, cp, CPS_FREEING);
 
-	cl_page_slice_for_each_reverse(cl_page, slice, i) {
+	cl_page_slice_for_each_reverse(cp, slice, i) {
 		if (slice->cpl_ops->cpo_delete)
 			(*slice->cpl_ops->cpo_delete)(env, slice);
 	}
+
+	if (cp->cp_type == CPT_CACHEABLE) {
+		vmpage = cp->cp_vmpage;
+		LASSERT(PageLocked(vmpage));
+		LASSERT((struct cl_page *)vmpage->private == cp);
+
+		/* Drop the reference count held in vvp_page_init */
+		refcount_dec(&cp->cp_ref);
+		ClearPagePrivate(vmpage);
+		vmpage->private = 0;
+
+		/*
+		 * The reference from vmpage to cl_page is removed,
+		 * but the reference back is still here. It is removed
+		 * later in cl_page_free().
+		 */
+	}
 }
 
 /**
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
