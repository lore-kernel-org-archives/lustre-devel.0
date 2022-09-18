Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id BB1CBC6FA86
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:23:19 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbn33447z1yDm;
	Sat, 17 Sep 2022 22:23:19 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVbm413d5z1yCV
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:28 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id F02CD8F0D;
 Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id ED238E8B94; Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:22:03 -0400
Message-Id: <1663478534-19917-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/24] lustre: clio: remove cpo_prep and
 cpo_make_ready
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

Remove the cpo_prep and cpo_make_ready methods from struct
cl_page_operations. These methods were only implemented by the vvp
layer and so they can be easily inlined into cl_page_prep() and
cl_page_make_ready().

WC-bug-id: https://jira.whamcloud.com/browse/LU-10994
Lustre-commit: ca161cfbcbf04bffb ("LU-10994 clio: remove cpo_prep and cpo_make_ready")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47399
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  28 +----------
 fs/lustre/llite/vvp_page.c    |  83 --------------------------------
 fs/lustre/obdclass/cl_page.c  | 109 ++++++++++++++++++++++--------------------
 3 files changed, 59 insertions(+), 161 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 492c704..b19d521 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -895,22 +895,8 @@ struct cl_page_operations {
 	 */
 	struct {
 		/**
-		 * Called when a page is submitted for a transfer as a part of
-		 * cl_page_list.
-		 *
-		 * Return:	0 if page is eligible for submission;
-		 *		-EALREADY skip this page;
-		 *		-ve if error.
-		 *
-		 * \see cl_page_prep()
-		 */
-		int  (*cpo_prep)(const struct lu_env *env,
-				 const struct cl_page_slice *slice,
-				 struct cl_io *io);
-		/**
 		 * Completion handler. This is guaranteed to be eventually
-		 * fired after cl_page_operations::cpo_prep() or
-		 * cl_page_operations::cpo_make_ready() call.
+		 * fired after cl_page_prep() or cl_page_make_ready() call.
 		 *
 		 * This method can be called in a non-blocking context. It is
 		 * guaranteed however, that the page involved and its object
@@ -922,18 +908,6 @@ struct cl_page_operations {
 		void (*cpo_completion)(const struct lu_env *env,
 				       const struct cl_page_slice *slice,
 				       int ioret);
-		/**
-		 * Called when cached page is about to be added to the
-		 * ptlrpc request as a part of req formation.
-		 *
-		 * Return	0 proceed with this page;
-		 *		-EAGAIN skip this page;
-		 *		-ve error.
-		 *
-		 * \see cl_page_make_ready()
-		 */
-		int  (*cpo_make_ready)(const struct lu_env *env,
-				       const struct cl_page_slice *slice);
 	} io[CRT_NR];
 	/**
 	 * Tell transfer engine that only [to, from] part of a page should be
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index f27bbfa..7c80908 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -63,33 +63,6 @@ static void vvp_page_discard(const struct lu_env *env,
 		ll_ra_stats_inc(vmpage->mapping->host, RA_STAT_DISCARDED);
 }
 
-static int vvp_page_prep_read(const struct lu_env *env,
-			      const struct cl_page_slice *slice,
-			      struct cl_io *unused)
-{
-	/* Skip the page already marked as PG_uptodate. */
-	return PageUptodate(cl2vm_page(slice)) ? -EALREADY : 0;
-}
-
-static int vvp_page_prep_write(const struct lu_env *env,
-			       const struct cl_page_slice *slice,
-			       struct cl_io *unused)
-{
-	struct page *vmpage = cl2vm_page(slice);
-	struct cl_page *pg = slice->cpl_page;
-
-	LASSERT(PageLocked(vmpage));
-	LASSERT(!PageDirty(vmpage));
-
-	/* ll_writepage path is not a sync write, so need to set page writeback
-	 * flag
-	 */
-	if (!pg->cp_sync_io)
-		set_page_writeback(vmpage);
-
-	return 0;
-}
-
 /**
  * Handles page transfer errors at VM level.
  *
@@ -173,70 +146,14 @@ static void vvp_page_completion_write(const struct lu_env *env,
 	}
 }
 
-/**
- * Implements cl_page_operations::cpo_make_ready() method.
- *
- * This is called to yank a page from the transfer cache and to send it out as
- * a part of transfer. This function try-locks the page. If try-lock failed,
- * page is owned by some concurrent IO, and should be skipped (this is bad,
- * but hopefully rare situation, as it usually results in transfer being
- * shorter than possible).
- *
- * Return:	0 success, page can be placed into transfer
- *
- *		-EAGAIN page is either used by concurrent IO has been
- *		truncated. Skip it.
- */
-static int vvp_page_make_ready(const struct lu_env *env,
-			       const struct cl_page_slice *slice)
-{
-	struct page *vmpage = cl2vm_page(slice);
-	struct cl_page *pg = slice->cpl_page;
-	int result = 0;
-
-	lock_page(vmpage);
-	if (clear_page_dirty_for_io(vmpage)) {
-		LASSERT(pg->cp_state == CPS_CACHED);
-		/* This actually clears the dirty bit in the radix tree. */
-		set_page_writeback(vmpage);
-		CL_PAGE_HEADER(D_PAGE, env, pg, "readied\n");
-	} else if (pg->cp_state == CPS_PAGEOUT) {
-		/* is it possible for osc_flush_async_page() to already
-		 * make it ready?
-		 */
-		result = -EALREADY;
-	} else {
-		CL_PAGE_DEBUG(D_ERROR, env, pg, "Unexpecting page state %d.\n",
-			      pg->cp_state);
-		LBUG();
-	}
-	unlock_page(vmpage);
-	return result;
-}
-
-static int vvp_page_fail(const struct lu_env *env,
-			 const struct cl_page_slice *slice)
-{
-	/*
-	 * Cached read?
-	 */
-	LBUG();
-
-	return 0;
-}
-
 static const struct cl_page_operations vvp_page_ops = {
 	.cpo_discard		= vvp_page_discard,
 	.io = {
 		[CRT_READ] = {
-			.cpo_prep	= vvp_page_prep_read,
 			.cpo_completion	= vvp_page_completion_read,
-			.cpo_make_ready = vvp_page_fail,
 		},
 		[CRT_WRITE] = {
-			.cpo_prep	= vvp_page_prep_write,
 			.cpo_completion = vvp_page_completion_write,
-			.cpo_make_ready = vvp_page_make_ready,
 		},
 	},
 };
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 6fbbfa8..2e3374c 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -826,45 +826,38 @@ static void cl_page_io_start(const struct lu_env *env,
 }
 
 /**
- * Prepares page for immediate transfer. cl_page_operations::cpo_prep() is
- * called top-to-bottom. Every layer either agrees to submit this page (by
- * returning 0), or requests to omit this page (by returning -EALREADY). Layer
- * handling interactions with the VM also has to inform VM that page is under
- * transfer now.
+ * Prepares page for immediate transfer. Return -EALREADY if this page
+ * should be omitted from transfer.
  */
 int cl_page_prep(const struct lu_env *env, struct cl_io *io,
-		 struct cl_page *cl_page, enum cl_req_type crt)
+		 struct cl_page *cp, enum cl_req_type crt)
 {
-	const struct cl_page_slice *slice;
-	int result = 0;
-	int i;
+	struct page *vmpage = cp->cp_vmpage;
+	int rc;
 
-	/*
-	 * this has to be called bottom-to-top, so that llite can set up
-	 * PG_writeback without risking other layers deciding to skip this
-	 * page.
-	 */
-	if (crt >= CRT_NR)
-		return -EINVAL;
-
-	if (cl_page->cp_type != CPT_TRANSIENT) {
-		cl_page_slice_for_each(cl_page, slice, i) {
-			if (slice->cpl_ops->io[crt].cpo_prep)
-				result = (*slice->cpl_ops->io[crt].cpo_prep)(env,
-									     slice,
-									     io);
-			if (result != 0)
-				break;
+	if (cp->cp_type == CPT_TRANSIENT) {
+		/* Nothing to do. */
+	} else if (crt == CRT_READ) {
+		if (PageUptodate(vmpage)) {
+			rc = -EALREADY;
+			goto out;
 		}
-	}
+	} else {
+		LASSERT(PageLocked(vmpage));
+		LASSERT(!PageDirty(vmpage));
 
-	if (result >= 0) {
-		result = 0;
-		cl_page_io_start(env, cl_page, crt);
+		/* ll_writepage path is not a sync write, so need to
+		 * set page writeback flag
+		 */
+		if (!cp->cp_sync_io)
+			set_page_writeback(vmpage);
 	}
+	cl_page_io_start(env, cp, crt);
+	rc = 0;
+out:
+	CL_PAGE_HEADER(D_TRACE, env, cp, "%d %d\n", crt, rc);
 
-	CL_PAGE_HEADER(D_TRACE, env, cl_page, "%d %d\n", crt, result);
-	return result;
+	return rc;
 }
 EXPORT_SYMBOL(cl_page_prep);
 
@@ -919,35 +912,49 @@ void cl_page_completion(const struct lu_env *env,
  *
  * \pre  cl_page->cp_state == CPS_CACHED
  * \post cl_page->cp_state == CPS_PAGEIN || cl_page->cp_state == CPS_PAGEOUT
- *
- * \see cl_page_operations::cpo_make_ready()
  */
-int cl_page_make_ready(const struct lu_env *env, struct cl_page *cl_page,
+int cl_page_make_ready(const struct lu_env *env, struct cl_page *cp,
 		       enum cl_req_type crt)
 {
-	const struct cl_page_slice *slice;
-	int result = 0;
-	int i;
+	struct page *vmpage = cp->cp_vmpage;
+	int rc = 0;
 
-	if (crt >= CRT_NR)
-		return -EINVAL;
+	PASSERT(env, cp, crt == CRT_WRITE);
 
-	cl_page_slice_for_each(cl_page, slice, i) {
-		if (slice->cpl_ops->io[crt].cpo_make_ready)
-			result = (*slice->cpl_ops->io[crt].cpo_make_ready)(env,
-									   slice);
-		if (result != 0)
-			break;
+	if (cp->cp_type == CPT_TRANSIENT)
+		goto out;
+
+	lock_page(vmpage);
+
+	if (clear_page_dirty_for_io(vmpage)) {
+		LASSERT(cp->cp_state == CPS_CACHED);
+		/* This actually clears the dirty bit in the
+		 * radix tree.
+		 */
+		set_page_writeback(vmpage);
+		CL_PAGE_HEADER(D_PAGE, env, cp, "readied\n");
+	} else if (cp->cp_state == CPS_PAGEOUT) {
+		/* is it possible for osc_flush_async_page()
+		 * to already make it ready?
+		 */
+		rc = -EALREADY;
+	} else {
+		CL_PAGE_DEBUG(D_ERROR, env, cp,
+			      "unexpecting page state %d\n",
+			      cp->cp_state);
+		LBUG();
 	}
 
-	if (result >= 0) {
-		PASSERT(env, cl_page, cl_page->cp_state == CPS_CACHED);
-		cl_page_io_start(env, cl_page, crt);
-		result = 0;
+	unlock_page(vmpage);
+out:
+	if (rc == 0) {
+		PASSERT(env, cp, cp->cp_state == CPS_CACHED);
+		cl_page_io_start(env, cp, crt);
 	}
-	CL_PAGE_HEADER(D_TRACE, env, cl_page, "%d %d\n", crt, result);
 
-	return result;
+	CL_PAGE_HEADER(D_TRACE, env, cp, "%d %d\n", crt, rc);
+
+	return rc;
 }
 EXPORT_SYMBOL(cl_page_make_ready);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
