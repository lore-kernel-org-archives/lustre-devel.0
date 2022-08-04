Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 44771C19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:38:39 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4LyrwY12k0z23Jn;
	Wed,  3 Aug 2022 18:38:37 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwN2XjYz21H0
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:28 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id AFBE8100AFF4;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A6A928D626; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:37:49 -0400
Message-Id: <1659577097-19253-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/32] lustre: clio: remove cl_page_export()
 and cl_page_is_vmlocked()
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

Remove cl_page_export() and cl_page_is_vmlocked(), replacing them with
direct calls to PageSetUptodate() and PageLoecked().

WC-bug-id: https://jira.whamcloud.com/browse/LU-10994
Lustre-commit: 3d52a7c5753e80e78 ("LU-10994 clio: remove cl_page_export() and cl_page_is_vmlocked()")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47241
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h | 22 ---------------------
 fs/lustre/llite/file.c        |  2 +-
 fs/lustre/llite/rw.c          |  4 ++--
 fs/lustre/llite/vvp_page.c    | 31 +----------------------------
 fs/lustre/lov/lov_page.c      |  2 +-
 fs/lustre/obdclass/cl_io.c    |  1 -
 fs/lustre/obdclass/cl_page.c  | 46 -------------------------------------------
 fs/lustre/osc/osc_lock.c      |  2 +-
 8 files changed, 6 insertions(+), 104 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 5be89d6..db5f610 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -872,26 +872,6 @@ struct cl_page_operations {
 			     const struct cl_page_slice *slice,
 			     struct cl_io *io);
 	/**
-	 * Announces whether the page contains valid data or not by @uptodate.
-	 *
-	 * \see cl_page_export()
-	 * \see vvp_page_export()
-	 */
-	void  (*cpo_export)(const struct lu_env *env,
-			    const struct cl_page_slice *slice, int uptodate);
-	/**
-	 * Checks whether underlying VM page is locked (in the suitable
-	 * sense). Used for assertions.
-	 *
-	 * Return:	-EBUSY means page is protected by a lock of a given
-	 *		mode;
-	 *		-ENODATA when page is not protected by a lock;
-	 *		0 this layer cannot decide. (Should never happen.)
-	 */
-	int (*cpo_is_vmlocked)(const struct lu_env *env,
-			       const struct cl_page_slice *slice);
-
-	/**
 	 * Update file attributes when all we have is this page.  Used for tiny
 	 * writes to update attributes when we don't have a full cl_io.
 	 */
@@ -2346,10 +2326,8 @@ int cl_page_flush(const struct lu_env *env, struct cl_io *io,
 void cl_page_discard(const struct lu_env *env, struct cl_io *io,
 		     struct cl_page *pg);
 void cl_page_delete(const struct lu_env *env, struct cl_page *pg);
-int cl_page_is_vmlocked(const struct lu_env *env, const struct cl_page *pg);
 void cl_page_touch(const struct lu_env *env, const struct cl_page *pg,
 		   size_t to);
-void cl_page_export(const struct lu_env *env, struct cl_page *pg, int uptodate);
 loff_t cl_offset(const struct cl_object *obj, pgoff_t idx);
 pgoff_t cl_index(const struct cl_object *obj, loff_t offset);
 size_t cl_page_size(const struct cl_object *obj);
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index efe117d..0e71b3a 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -587,7 +587,7 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req)
 			put_page(vmpage);
 			break;
 		}
-		cl_page_export(env, page, 1);
+		SetPageUptodate(vmpage);
 		cl_page_put(env, page);
 		unlock_page(vmpage);
 		put_page(vmpage);
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index c807217..478ef1b 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1664,7 +1664,7 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	cl_2queue_init(queue);
 	if (uptodate) {
 		vpg->vpg_ra_used = 1;
-		cl_page_export(env, page, 1);
+		SetPageUptodate(page->cp_vmpage);
 		cl_page_disown(env, io, page);
 	} else {
 		anchor = &vvp_env_info(env)->vti_anchor;
@@ -1908,7 +1908,7 @@ int ll_readpage(struct file *file, struct page *vmpage)
 		/* export the page and skip io stack */
 		if (result == 0) {
 			vpg->vpg_ra_used = 1;
-			cl_page_export(env, page, 1);
+			SetPageUptodate(vmpage);
 		} else {
 			ll_ra_stats_inc_sbi(sbi, RA_STAT_FAILED_FAST_READ);
 		}
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index 7744e9b..82ce5ab 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -170,26 +170,6 @@ static void vvp_page_delete(const struct lu_env *env,
 	 */
 }
 
-static void vvp_page_export(const struct lu_env *env,
-			    const struct cl_page_slice *slice,
-			    int uptodate)
-{
-	struct page *vmpage = cl2vm_page(slice);
-
-	LASSERT(vmpage);
-	LASSERT(PageLocked(vmpage));
-	if (uptodate)
-		SetPageUptodate(vmpage);
-	else
-		ClearPageUptodate(vmpage);
-}
-
-static int vvp_page_is_vmlocked(const struct lu_env *env,
-				const struct cl_page_slice *slice)
-{
-	return PageLocked(cl2vm_page(slice)) ? -EBUSY : -ENODATA;
-}
-
 static int vvp_page_prep_read(const struct lu_env *env,
 			      const struct cl_page_slice *slice,
 			      struct cl_io *unused)
@@ -260,7 +240,7 @@ static void vvp_page_completion_read(const struct lu_env *env,
 
 	if (ioret == 0)  {
 		if (!vpg->vpg_defer_uptodate)
-			cl_page_export(env, page, 1);
+			SetPageUptodate(vmpage);
 	} else if (vpg->vpg_defer_uptodate) {
 		vpg->vpg_defer_uptodate = 0;
 		if (ioret == -EAGAIN) {
@@ -382,8 +362,6 @@ static int vvp_page_fail(const struct lu_env *env,
 	.cpo_disown		= vvp_page_disown,
 	.cpo_discard		= vvp_page_discard,
 	.cpo_delete		= vvp_page_delete,
-	.cpo_export		= vvp_page_export,
-	.cpo_is_vmlocked	= vvp_page_is_vmlocked,
 	.cpo_fini		= vvp_page_fini,
 	.cpo_print		= vvp_page_print,
 	.io = {
@@ -412,15 +390,8 @@ static void vvp_transient_page_discard(const struct lu_env *env,
 	cl_page_delete(env, page);
 }
 
-static int vvp_transient_page_is_vmlocked(const struct lu_env *env,
-					  const struct cl_page_slice *slice)
-{
-	return -EBUSY;
-}
-
 static const struct cl_page_operations vvp_transient_page_ops = {
 	.cpo_discard		= vvp_transient_page_discard,
-	.cpo_is_vmlocked	= vvp_transient_page_is_vmlocked,
 	.cpo_print		= vvp_page_print,
 };
 
diff --git a/fs/lustre/lov/lov_page.c b/fs/lustre/lov/lov_page.c
index bd6ba79..a22b71f 100644
--- a/fs/lustre/lov/lov_page.c
+++ b/fs/lustre/lov/lov_page.c
@@ -144,7 +144,7 @@ int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
 	addr = kmap(page->cp_vmpage);
 	memset(addr, 0, cl_page_size(obj));
 	kunmap(page->cp_vmpage);
-	cl_page_export(env, page, 1);
+	SetPageUptodate(page->cp_vmpage);
 	return 0;
 }
 
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 6dd029a..c97ac0f 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -849,7 +849,6 @@ void cl_page_list_del(const struct lu_env *env, struct cl_page_list *plist,
 		      struct cl_page *page)
 {
 	LASSERT(plist->pl_nr > 0);
-	LASSERT(cl_page_is_vmlocked(env, page));
 
 	list_del_init(&page->cp_batch);
 	--plist->pl_nr;
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 9326743..b5b5448 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -760,52 +760,6 @@ void cl_page_delete(const struct lu_env *env, struct cl_page *pg)
 }
 EXPORT_SYMBOL(cl_page_delete);
 
-/**
- * Marks page up-to-date.
- *
- * Call cl_page_operations::cpo_export() through all layers top-to-bottom. The
- * layer responsible for VM interaction has to mark/clear page as up-to-date
- * by the @uptodate argument.
- *
- * \see cl_page_operations::cpo_export()
- */
-void cl_page_export(const struct lu_env *env, struct cl_page *cl_page,
-		    int uptodate)
-{
-	const struct cl_page_slice *slice;
-	int i;
-
-	cl_page_slice_for_each(cl_page, slice, i) {
-		if (slice->cpl_ops->cpo_export)
-			(*slice->cpl_ops->cpo_export)(env, slice, uptodate);
-	}
-}
-EXPORT_SYMBOL(cl_page_export);
-
-/**
- * Returns true, if @cl_page is VM locked in a suitable sense by the calling
- * thread.
- */
-int cl_page_is_vmlocked(const struct lu_env *env,
-			const struct cl_page *cl_page)
-{
-	const struct cl_page_slice *slice;
-	int result;
-
-	slice = cl_page_slice_get(cl_page, 0);
-	PASSERT(env, cl_page, slice->cpl_ops->cpo_is_vmlocked);
-	/*
-	 * Call ->cpo_is_vmlocked() directly instead of going through
-	 * CL_PAGE_INVOKE(), because cl_page_is_vmlocked() is used by
-	 * cl_page_invariant().
-	 */
-	result = slice->cpl_ops->cpo_is_vmlocked(env, slice);
-	PASSERT(env, cl_page, result == -EBUSY || result == -ENODATA);
-
-	return result == -EBUSY;
-}
-EXPORT_SYMBOL(cl_page_is_vmlocked);
-
 void cl_page_touch(const struct lu_env *env,
 		   const struct cl_page *cl_page, size_t to)
 {
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index eb3cb58..c8f8502 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -644,7 +644,7 @@ static bool weigh_cb(const struct lu_env *env, struct cl_io *io,
 		struct osc_page *ops = pvec[i];
 		struct cl_page *page = ops->ops_cl.cpl_page;
 
-		if (cl_page_is_vmlocked(env, page) ||
+		if (PageLocked(page->cp_vmpage) ||
 		    PageDirty(page->cp_vmpage) ||
 		    PageWriteback(page->cp_vmpage))
 			return false;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
