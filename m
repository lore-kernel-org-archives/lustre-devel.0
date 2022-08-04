Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E05C0C19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:38:46 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyrwk36GXz23Jr;
	Wed,  3 Aug 2022 18:38:46 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwP6FRwz23Hk
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:29 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B4F1A100AFF6;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AA0EA905FD; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:37:50 -0400
Message-Id: <1659577097-19253-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/32] lustre: clio: remove cpo_own and
 cpo_disown
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

Remove the cpo_own and cpo_disown methods from struct
cl_page_operations. These methods were only implemented by the vvp
layer so they can be inlined into cl_page_own0() and
cl_page_disown(). Move most of vvp_page_discard() and all of
vvp_transient_page_discard() into cl_page_discard().

WC-bug-id: https://jira.whamcloud.com/browse/LU-10994
Lustre-commit: 81c6dc423ce4c62a6 ("LU-10994 clio: remove cpo_own and cpo_disown")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47372
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h  | 33 ++++----------
 fs/lustre/llite/llite_lib.c    |  2 +-
 fs/lustre/llite/rw.c           | 49 +++++++++++----------
 fs/lustre/llite/rw26.c         |  6 +--
 fs/lustre/llite/vvp_dev.c      |  3 +-
 fs/lustre/llite/vvp_internal.h |  3 --
 fs/lustre/llite/vvp_page.c     | 86 ++++++------------------------------
 fs/lustre/obdclass/cl_io.c     | 12 +++--
 fs/lustre/obdclass/cl_page.c   | 99 +++++++++++++++++++++++-------------------
 9 files changed, 112 insertions(+), 181 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index db5f610..4460ae1 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -764,6 +764,10 @@ struct cl_page {
 	 * creation.
 	 */
 	enum cl_page_type		 cp_type:CP_TYPE_BITS;
+	unsigned int			 cp_defer_uptodate:1,
+					 cp_ra_updated:1,
+					 cp_ra_used:1;
+
 	/* which slab kmem index this memory allocated from */
 	short int			 cp_kmem_index;
 
@@ -822,7 +826,7 @@ enum cl_req_type {
  *
  * Methods taking an @io argument are for the activity happening in the
  * context of given @io. Page is assumed to be owned by that io, except for
- * the obvious cases (like cl_page_operations::cpo_own()).
+ * the obvious cases.
  *
  * \see vvp_page_ops, lov_page_ops, osc_page_ops
  */
@@ -834,25 +838,6 @@ struct cl_page_operations {
 	 */
 
 	/**
-	 * Called when @io acquires this page into the exclusive
-	 * ownership. When this method returns, it is guaranteed that the is
-	 * not owned by other io, and no transfer is going on against
-	 * it. Optional.
-	 *
-	 * \see cl_page_own()
-	 * \see vvp_page_own(), lov_page_own()
-	 */
-	int  (*cpo_own)(const struct lu_env *env,
-			const struct cl_page_slice *slice,
-			struct cl_io *io, int nonblock);
-	/** Called when ownership it yielded. Optional.
-	 *
-	 * \see cl_page_disown()
-	 * \see vvp_page_disown()
-	 */
-	void (*cpo_disown)(const struct lu_env *env,
-			   const struct cl_page_slice *slice, struct cl_io *io);
-	/**
 	 * Called for a page that is already "owned" by @io from VM point of
 	 * view. Optional.
 	 *
@@ -2290,8 +2275,7 @@ void cl_page_unassume(const struct lu_env *env,
 		      struct cl_io *io, struct cl_page *pg);
 void cl_page_disown(const struct lu_env *env,
 		    struct cl_io *io, struct cl_page *page);
-void __cl_page_disown(const struct lu_env *env,
-		      struct cl_io *io, struct cl_page *pg);
+void __cl_page_disown(const struct lu_env *env, struct cl_page *pg);
 int cl_page_is_owned(const struct cl_page *pg, const struct cl_io *io);
 
 /** @} ownership */
@@ -2544,14 +2528,13 @@ void cl_page_list_splice(struct cl_page_list *list,
 void cl_page_list_del(const struct lu_env *env,
 		      struct cl_page_list *plist, struct cl_page *page);
 void cl_page_list_disown(const struct lu_env *env,
-			 struct cl_io *io, struct cl_page_list *plist);
+			 struct cl_page_list *plist);
 void cl_page_list_discard(const struct lu_env *env,
 			  struct cl_io *io, struct cl_page_list *plist);
 void cl_page_list_fini(const struct lu_env *env, struct cl_page_list *plist);
 
 void cl_2queue_init(struct cl_2queue *queue);
-void cl_2queue_disown(const struct lu_env *env, struct cl_io *io,
-		      struct cl_2queue *queue);
+void cl_2queue_disown(const struct lu_env *env, struct cl_2queue *queue);
 void cl_2queue_discard(const struct lu_env *env, struct cl_io *io,
 		       struct cl_2queue *queue);
 void cl_2queue_fini(const struct lu_env *env, struct cl_2queue *queue);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 6adbf10..b55a30f 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1955,7 +1955,7 @@ int ll_io_zero_page(struct inode *inode, pgoff_t index, pgoff_t offset,
 queuefini2:
 		cl_2queue_discard(env, io, queue);
 queuefini1:
-		cl_2queue_disown(env, io, queue);
+		cl_2queue_disown(env, queue);
 		cl_2queue_fini(env, queue);
 	}
 
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 478ef1b..7c4b8ec 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -195,10 +195,9 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 	enum ra_stat which = _NR_RA_STAT; /* keep gcc happy */
 	struct cl_object *clob = io->ci_obj;
 	struct inode *inode = vvp_object_inode(clob);
-	const char *msg = NULL;
-	struct cl_page *page;
-	struct vvp_page *vpg;
 	struct page *vmpage = NULL;
+	const char *msg = NULL;
+	struct cl_page *cp;
 	int rc = 0;
 
 	switch (hint) {
@@ -233,34 +232,35 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 		goto out;
 	}
 
-	page = cl_page_find(env, clob, vmpage->index, vmpage, CPT_CACHEABLE);
-	if (IS_ERR(page)) {
+	cp = cl_page_find(env, clob, vmpage->index, vmpage, CPT_CACHEABLE);
+	if (IS_ERR(cp)) {
 		which = RA_STAT_FAILED_GRAB_PAGE;
 		msg = "cl_page_find failed";
-		rc = PTR_ERR(page);
+		rc = PTR_ERR(cp);
 		goto out;
 	}
 
-	lu_ref_add(&page->cp_reference, "ra", current);
-	cl_page_assume(env, io, page);
-	vpg = cl2vvp_page(cl_object_page_slice(clob, page));
-	if (!vpg->vpg_defer_uptodate && !PageUptodate(vmpage)) {
+	lu_ref_add(&cp->cp_reference, "ra", current);
+	cl_page_assume(env, io, cp);
+
+	if (!cp->cp_defer_uptodate && !PageUptodate(vmpage)) {
 		if (hint == MAYNEED) {
-			vpg->vpg_defer_uptodate = 1;
-			vpg->vpg_ra_used = 0;
+			cp->cp_defer_uptodate = 1;
+			cp->cp_ra_used = 0;
 		}
-		cl_page_list_add(queue, page, true);
+
+		cl_page_list_add(queue, cp, true);
 	} else {
 		/* skip completed pages */
-		cl_page_unassume(env, io, page);
+		cl_page_unassume(env, io, cp);
 		/* This page is already uptodate, returning a positive number
 		 * to tell the callers about this
 		 */
 		rc = 1;
 	}
 
-	lu_ref_del(&page->cp_reference, "ra", current);
-	cl_page_put(env, page);
+	lu_ref_del(&cp->cp_reference, "ra", current);
+	cl_page_put(env, cp);
 out:
 	if (vmpage) {
 		if (rc)
@@ -695,7 +695,7 @@ static void ll_readahead_handle_work(struct work_struct *wq)
 	cl_page_list_discard(env, io, &queue->c2_qin);
 
 	/* Unlock unsent read pages in case of error. */
-	cl_page_list_disown(env, io, &queue->c2_qin);
+	cl_page_list_disown(env, &queue->c2_qin);
 
 	cl_2queue_fini(env, queue);
 out_io_fini:
@@ -1649,9 +1649,9 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 		unlockpage = false;
 
 	vpg = cl2vvp_page(cl_object_page_slice(page->cp_obj, page));
-	uptodate = vpg->vpg_defer_uptodate;
+	uptodate = page->cp_defer_uptodate;
 
-	if (ll_readahead_enabled(sbi) && !vpg->vpg_ra_updated && ras) {
+	if (ll_readahead_enabled(sbi) && !page->cp_ra_updated && ras) {
 		enum ras_update_flags flags = 0;
 
 		if (uptodate)
@@ -1663,7 +1663,7 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 
 	cl_2queue_init(queue);
 	if (uptodate) {
-		vpg->vpg_ra_used = 1;
+		page->cp_ra_used = 1;
 		SetPageUptodate(page->cp_vmpage);
 		cl_page_disown(env, io, page);
 	} else {
@@ -1740,7 +1740,7 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	cl_page_list_discard(env, io, &queue->c2_qin);
 
 	/* Unlock unsent read pages in case of error. */
-	cl_page_list_disown(env, io, &queue->c2_qin);
+	cl_page_list_disown(env, &queue->c2_qin);
 
 	cl_2queue_fini(env, queue);
 
@@ -1881,7 +1881,7 @@ int ll_readpage(struct file *file, struct page *vmpage)
 		}
 
 		vpg = cl2vvp_page(cl_object_page_slice(page->cp_obj, page));
-		if (vpg->vpg_defer_uptodate) {
+		if (page->cp_defer_uptodate) {
 			enum ras_update_flags flags = LL_RAS_HIT;
 
 			if (lcc && lcc->lcc_type == LCC_MMAP)
@@ -1894,7 +1894,7 @@ int ll_readpage(struct file *file, struct page *vmpage)
 			 */
 			ras_update(sbi, inode, ras, vvp_index(vpg), flags, io);
 			/* avoid duplicate ras_update() call */
-			vpg->vpg_ra_updated = 1;
+			page->cp_ra_updated = 1;
 
 			if (ll_use_fast_io(file, ras, vvp_index(vpg)))
 				result = 0;
@@ -1907,11 +1907,12 @@ int ll_readpage(struct file *file, struct page *vmpage)
 
 		/* export the page and skip io stack */
 		if (result == 0) {
-			vpg->vpg_ra_used = 1;
+			page->cp_ra_used = 1;
 			SetPageUptodate(vmpage);
 		} else {
 			ll_ra_stats_inc_sbi(sbi, RA_STAT_FAILED_FAST_READ);
 		}
+
 		/* release page refcount before unlocking the page to ensure
 		 * the object won't be destroyed in the calling path of
 		 * cl_page_put(). Please see comment in ll_releasepage().
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 8b379ca..7147f0f 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -286,7 +286,7 @@ static unsigned long ll_iov_iter_alignment(struct iov_iter *i)
 	}
 
 	cl_2queue_discard(env, io, queue);
-	cl_2queue_disown(env, io, queue);
+	cl_2queue_disown(env, queue);
 	cl_2queue_fini(env, queue);
 	return rc;
 }
@@ -468,8 +468,8 @@ static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
 		goto out;
 	}
 
-	if (vpg->vpg_defer_uptodate) {
-		vpg->vpg_ra_used = 1;
+	if (pg->cp_defer_uptodate) {
+		pg->cp_ra_used = 1;
 		result = 0;
 		goto out;
 	}
diff --git a/fs/lustre/llite/vvp_dev.c b/fs/lustre/llite/vvp_dev.c
index 0c417d8..99335bd 100644
--- a/fs/lustre/llite/vvp_dev.c
+++ b/fs/lustre/llite/vvp_dev.c
@@ -435,11 +435,10 @@ static void vvp_pgcache_page_show(const struct lu_env *env,
 
 	vpg = cl2vvp_page(cl_page_at(page, &vvp_device_type));
 	vmpage = vpg->vpg_page;
-	seq_printf(seq, " %5i | %p %p %s %s %s | %p " DFID "(%p) %lu %u [",
+	seq_printf(seq, " %5i | %p %p %s %s | %p " DFID "(%p) %lu %u [",
 		   0 /* gen */,
 		   vpg, page,
 		   "none",
-		   vpg->vpg_defer_uptodate ? "du" : "- ",
 		   PageWriteback(vmpage) ? "wb" : "-",
 		   vmpage, PFID(ll_inode2fid(vmpage->mapping->host)),
 		   vmpage->mapping->host, vmpage->index,
diff --git a/fs/lustre/llite/vvp_internal.h b/fs/lustre/llite/vvp_internal.h
index b5e1df2..0e0da76 100644
--- a/fs/lustre/llite/vvp_internal.h
+++ b/fs/lustre/llite/vvp_internal.h
@@ -213,9 +213,6 @@ struct vvp_object {
  */
 struct vvp_page {
 	struct cl_page_slice	vpg_cl;
-	unsigned int		vpg_defer_uptodate:1,
-				vpg_ra_updated:1,
-				vpg_ra_used:1;
 	/** VM page */
 	struct page		*vpg_page;
 };
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index 82ce5ab..8875a62 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -73,32 +73,6 @@ static void vvp_page_fini(const struct lu_env *env,
 	}
 }
 
-static int vvp_page_own(const struct lu_env *env,
-			const struct cl_page_slice *slice, struct cl_io *io,
-			int nonblock)
-{
-	struct vvp_page *vpg = cl2vvp_page(slice);
-	struct page *vmpage = vpg->vpg_page;
-
-	LASSERT(vmpage);
-	if (nonblock) {
-		if (!trylock_page(vmpage))
-			return -EAGAIN;
-
-		if (unlikely(PageWriteback(vmpage))) {
-			unlock_page(vmpage);
-			return -EAGAIN;
-		}
-
-		return 0;
-	}
-
-	lock_page(vmpage);
-	wait_on_page_writeback(vmpage);
-
-	return 0;
-}
-
 static void vvp_page_assume(const struct lu_env *env,
 			    const struct cl_page_slice *slice,
 			    struct cl_io *unused)
@@ -120,31 +94,15 @@ static void vvp_page_unassume(const struct lu_env *env,
 	LASSERT(PageLocked(vmpage));
 }
 
-static void vvp_page_disown(const struct lu_env *env,
-			    const struct cl_page_slice *slice, struct cl_io *io)
-{
-	struct page *vmpage = cl2vm_page(slice);
-
-	LASSERT(vmpage);
-	LASSERT(PageLocked(vmpage));
-
-	unlock_page(cl2vm_page(slice));
-}
-
 static void vvp_page_discard(const struct lu_env *env,
 			     const struct cl_page_slice *slice,
 			     struct cl_io *unused)
 {
-	struct page *vmpage = cl2vm_page(slice);
-	struct vvp_page *vpg = cl2vvp_page(slice);
+	struct cl_page *cp = slice->cpl_page;
+	struct page *vmpage = cp->cp_vmpage;
 
-	LASSERT(vmpage);
-	LASSERT(PageLocked(vmpage));
-
-	if (vpg->vpg_defer_uptodate && !vpg->vpg_ra_used && vmpage->mapping)
+	if (cp->cp_defer_uptodate && !cp->cp_ra_used && vmpage->mapping)
 		ll_ra_stats_inc(vmpage->mapping->host, RA_STAT_DISCARDED);
-
-	generic_error_remove_page(vmpage->mapping, vmpage);
 }
 
 static void vvp_page_delete(const struct lu_env *env,
@@ -227,22 +185,21 @@ static void vvp_page_completion_read(const struct lu_env *env,
 				     const struct cl_page_slice *slice,
 				     int ioret)
 {
-	struct vvp_page *vpg = cl2vvp_page(slice);
-	struct page *vmpage = vpg->vpg_page;
-	struct cl_page *page = slice->cpl_page;
-	struct inode *inode = vvp_object_inode(page->cp_obj);
+	struct cl_page *cp = slice->cpl_page;
+	struct page *vmpage = cp->cp_vmpage;
+	struct inode *inode = vvp_object_inode(cp->cp_obj);
 
 	LASSERT(PageLocked(vmpage));
-	CL_PAGE_HEADER(D_PAGE, env, page, "completing READ with %d\n", ioret);
+	CL_PAGE_HEADER(D_PAGE, env, cp, "completing READ with %d\n", ioret);
 
-	if (vpg->vpg_defer_uptodate)
+	if (cp->cp_defer_uptodate)
 		ll_ra_count_put(ll_i2sbi(inode), 1);
 
 	if (ioret == 0)  {
-		if (!vpg->vpg_defer_uptodate)
+		if (!cp->cp_defer_uptodate)
 			SetPageUptodate(vmpage);
-	} else if (vpg->vpg_defer_uptodate) {
-		vpg->vpg_defer_uptodate = 0;
+	} else if (cp->cp_defer_uptodate) {
+		cp->cp_defer_uptodate = 0;
 		if (ioret == -EAGAIN) {
 			/* mirror read failed, it needs to destroy the page
 			 * because subpage would be from wrong osc when trying
@@ -252,7 +209,7 @@ static void vvp_page_completion_read(const struct lu_env *env,
 		}
 	}
 
-	if (!page->cp_sync_io)
+	if (!cp->cp_sync_io)
 		unlock_page(vmpage);
 }
 
@@ -329,8 +286,8 @@ static int vvp_page_print(const struct lu_env *env,
 	struct vvp_page *vpg = cl2vvp_page(slice);
 	struct page *vmpage = vpg->vpg_page;
 
-	(*printer)(env, cookie, LUSTRE_VVP_NAME "-page@%p(%d:%d) vm@%p ",
-		   vpg, vpg->vpg_defer_uptodate, vpg->vpg_ra_used, vmpage);
+	(*printer)(env, cookie,
+		   LUSTRE_VVP_NAME"-page@%p vm@%p ", vpg, vmpage);
 	if (vmpage) {
 		(*printer)(env, cookie, "%lx %d:%d %lx %lu %slru",
 			   (long)vmpage->flags, page_count(vmpage),
@@ -356,10 +313,8 @@ static int vvp_page_fail(const struct lu_env *env,
 }
 
 static const struct cl_page_operations vvp_page_ops = {
-	.cpo_own		= vvp_page_own,
 	.cpo_assume		= vvp_page_assume,
 	.cpo_unassume		= vvp_page_unassume,
-	.cpo_disown		= vvp_page_disown,
 	.cpo_discard		= vvp_page_discard,
 	.cpo_delete		= vvp_page_delete,
 	.cpo_fini		= vvp_page_fini,
@@ -378,20 +333,7 @@ static int vvp_page_fail(const struct lu_env *env,
 	},
 };
 
-static void vvp_transient_page_discard(const struct lu_env *env,
-				       const struct cl_page_slice *slice,
-				       struct cl_io *unused)
-{
-	struct cl_page *page = slice->cpl_page;
-
-	/*
-	 * For transient pages, remove it from the radix tree.
-	 */
-	cl_page_delete(env, page);
-}
-
 static const struct cl_page_operations vvp_transient_page_ops = {
-	.cpo_discard		= vvp_transient_page_discard,
 	.cpo_print		= vvp_page_print,
 };
 
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index c97ac0f..4246e17 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -911,8 +911,7 @@ void cl_page_list_splice(struct cl_page_list *src, struct cl_page_list *dst)
 /**
  * Disowns pages in a queue.
  */
-void cl_page_list_disown(const struct lu_env *env,
-			 struct cl_io *io, struct cl_page_list *plist)
+void cl_page_list_disown(const struct lu_env *env, struct cl_page_list *plist)
 {
 	struct cl_page *page;
 	struct cl_page *temp;
@@ -930,7 +929,7 @@ void cl_page_list_disown(const struct lu_env *env,
 		/*
 		 * XXX __cl_page_disown() will fail if page is not locked.
 		 */
-		__cl_page_disown(env, io, page);
+		__cl_page_disown(env, page);
 		lu_ref_del_at(&page->cp_reference, &page->cp_queue_ref, "queue",
 			      plist);
 		cl_page_put(env, page);
@@ -990,11 +989,10 @@ void cl_2queue_init(struct cl_2queue *queue)
 /**
  * Disown pages in both lists of a 2-queue.
  */
-void cl_2queue_disown(const struct lu_env *env,
-		      struct cl_io *io, struct cl_2queue *queue)
+void cl_2queue_disown(const struct lu_env *env, struct cl_2queue *queue)
 {
-	cl_page_list_disown(env, io, &queue->c2_qin);
-	cl_page_list_disown(env, io, &queue->c2_qout);
+	cl_page_list_disown(env, &queue->c2_qin);
+	cl_page_list_disown(env, &queue->c2_qout);
 }
 EXPORT_SYMBOL(cl_2queue_disown);
 
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index b5b5448..cff2c54 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -40,6 +40,7 @@
 #include <obd_class.h>
 #include <obd_support.h>
 #include <linux/list.h>
+#include <linux/pagemap.h>
 
 #include <cl_object.h>
 #include "cl_internal.h"
@@ -487,26 +488,22 @@ static void cl_page_owner_set(struct cl_page *page)
 	page->cp_owner->ci_owned_nr++;
 }
 
-void __cl_page_disown(const struct lu_env *env,
-		      struct cl_io *io, struct cl_page *cl_page)
+void __cl_page_disown(const struct lu_env *env, struct cl_page *cp)
 {
-	const struct cl_page_slice *slice;
 	enum cl_page_state state;
-	int i;
+	struct page *vmpage;
 
-	state = cl_page->cp_state;
-	cl_page_owner_clear(cl_page);
+	state = cp->cp_state;
+	cl_page_owner_clear(cp);
 
 	if (state == CPS_OWNED)
-		cl_page_state_set(env, cl_page, CPS_CACHED);
-	/*
-	 * Completion call-backs are executed in the bottom-up order, so that
-	 * uppermost layer (llite), responsible for VFS/VM interaction runs
-	 * last and can release locks safely.
-	 */
-	cl_page_slice_for_each_reverse(cl_page, slice, i) {
-		if (slice->cpl_ops->cpo_disown)
-			(*slice->cpl_ops->cpo_disown)(env, slice, io);
+		cl_page_state_set(env, cp, CPS_CACHED);
+
+	if (cp->cp_type == CPT_CACHEABLE) {
+		vmpage = cp->cp_vmpage;
+		LASSERT(vmpage);
+		LASSERT(PageLocked(vmpage));
+		unlock_page(vmpage);
 	}
 }
 
@@ -539,45 +536,51 @@ int cl_page_is_owned(const struct cl_page *pg, const struct cl_io *io)
  *		another thread, or in IO.
  *
  * \see cl_page_disown()
- * \see cl_page_operations::cpo_own()
  * \see cl_page_own_try()
  * \see cl_page_own
  */
 static int __cl_page_own(const struct lu_env *env, struct cl_io *io,
 			 struct cl_page *cl_page, int nonblock)
 {
-	const struct cl_page_slice *slice;
+	struct page *vmpage = cl_page->cp_vmpage;
 	int result = 0;
-	int i;
-
-	io = cl_io_top(io);
 
 	if (cl_page->cp_state == CPS_FREEING) {
 		result = -ENOENT;
 		goto out;
 	}
 
-	cl_page_slice_for_each(cl_page, slice, i) {
-		if (slice->cpl_ops->cpo_own)
-			result = (*slice->cpl_ops->cpo_own)(env, slice,
-							    io, nonblock);
-		if (result != 0)
-			break;
-	}
-	if (result > 0)
-		result = 0;
+	LASSERT(vmpage);
 
-	if (result == 0) {
-		PASSERT(env, cl_page, !cl_page->cp_owner);
-		cl_page->cp_owner = cl_io_top(io);
-		cl_page_owner_set(cl_page);
-		if (cl_page->cp_state != CPS_FREEING) {
-			cl_page_state_set(env, cl_page, CPS_OWNED);
-		} else {
-			__cl_page_disown(env, io, cl_page);
-			result = -ENOENT;
+	if (cl_page->cp_type == CPT_TRANSIENT) {
+		/* OK */
+	} else if (nonblock) {
+		if (!trylock_page(vmpage)) {
+			result = -EAGAIN;
+			goto out;
 		}
+
+		if (unlikely(PageWriteback(vmpage))) {
+			unlock_page(vmpage);
+			result = -EAGAIN;
+			goto out;
+		}
+	} else {
+		lock_page(vmpage);
+		wait_on_page_writeback(vmpage);
 	}
+
+	PASSERT(env, cl_page, !cl_page->cp_owner);
+	cl_page->cp_owner = cl_io_top(io);
+	cl_page_owner_set(cl_page);
+
+	if (cl_page->cp_state == CPS_FREEING) {
+		__cl_page_disown(env, cl_page);
+		result = -ENOENT;
+		goto out;
+	}
+
+	cl_page_state_set(env, cl_page, CPS_OWNED);
 out:
 	return result;
 }
@@ -672,13 +675,11 @@ void cl_page_unassume(const struct lu_env *env,
  * \post !cl_page_is_owned(pg, io)
  *
  * \see cl_page_own()
- * \see cl_page_operations::cpo_disown()
  */
 void cl_page_disown(const struct lu_env *env,
 		    struct cl_io *io, struct cl_page *pg)
 {
-	io = cl_io_top(io);
-	__cl_page_disown(env, io, pg);
+	__cl_page_disown(env, pg);
 }
 EXPORT_SYMBOL(cl_page_disown);
 
@@ -693,15 +694,25 @@ void cl_page_disown(const struct lu_env *env,
  * \see cl_page_operations::cpo_discard()
  */
 void cl_page_discard(const struct lu_env *env,
-		     struct cl_io *io, struct cl_page *cl_page)
+		     struct cl_io *io, struct cl_page *cp)
 {
 	const struct cl_page_slice *slice;
+	struct page *vmpage;
 	int i;
 
-	cl_page_slice_for_each(cl_page, slice, i) {
+	cl_page_slice_for_each(cp, slice, i) {
 		if (slice->cpl_ops->cpo_discard)
 			(*slice->cpl_ops->cpo_discard)(env, slice, io);
 	}
+
+	if (cp->cp_type == CPT_CACHEABLE) {
+		vmpage = cp->cp_vmpage;
+		LASSERT(vmpage);
+		LASSERT(PageLocked(vmpage));
+		generic_error_remove_page(vmpage->mapping, vmpage);
+	} else {
+		cl_page_delete(env, cp);
+	}
 }
 EXPORT_SYMBOL(cl_page_discard);
 
@@ -813,7 +824,7 @@ int cl_page_prep(const struct lu_env *env, struct cl_io *io,
 
 	if (cl_page->cp_type != CPT_TRANSIENT) {
 		cl_page_slice_for_each(cl_page, slice, i) {
-			if (slice->cpl_ops->cpo_own)
+			if (slice->cpl_ops->io[crt].cpo_prep)
 				result = (*slice->cpl_ops->io[crt].cpo_prep)(env,
 									     slice,
 									     io);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
