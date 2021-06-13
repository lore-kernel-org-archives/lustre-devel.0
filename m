Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1BD1C48BE8
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:32 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 65CC561363
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65CC561363
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2ACCF21F677;
	Sun, 13 Jun 2021 16:12:11 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5F70921E0A5
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:44 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C8BFF100B055;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C66899C30D; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:23 -0400
Message-Id: <1623625897-17706-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/27] lustre: osc: Batch gang_lookup cbs
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Cc: Patrick Farrell <paf@cray.com>,
 Alexander Zarochentsev <alexander.zarochentsev@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <paf@cray.com>

The osc_page_gang_lookup call backs can be trivially
converted to operate in batches rather than one page at a
time.  This improves cancellation time for locks protecting
large numbers of pages by about 10% (after landing
another optimization (LU-11290 ldlm: page discard speedup)
it shows 6% for canceling a lock for 30GB cached file ).

Truncate to zero time (with one lock protecting many pages)
was improved by about 5-10% as well.  Lock weighing
performance should be improved slightly as well, but is
tricky to benchmark.

HPE-bug-id: LUS-6432
WC-bug-id: https://jira.whamcloud.com/browse/LU-11290
Lustre-commit: 0d6d0b7bc95a82de ("LU-11290 osc: Batch gang_lookup cbs")
Signed-off-by: Patrick Farrell <paf@cray.com>
Signed-off-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-on: https://review.whamcloud.com/33089
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |   7 +-
 fs/lustre/mdc/mdc_dev.c        |  46 +++++++------
 fs/lustre/osc/osc_cache.c      | 147 ++++++++++++++++++++++-------------------
 fs/lustre/osc/osc_io.c         |  33 +++++----
 fs/lustre/osc/osc_lock.c       |  19 ++++--
 5 files changed, 138 insertions(+), 114 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index f83d1e6..0947677 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -629,14 +629,13 @@ static inline void osc_io_unplug(const struct lu_env *env,
 	(void)__osc_io_unplug(env, cli, osc, 0);
 }
 
-typedef bool (*osc_page_gang_cbt)(const struct lu_env *, struct cl_io *,
-				  struct osc_page *, void *);
+typedef bool (*osc_page_gang_cbt)(const struct lu_env *env, struct cl_io *io,
+				  void **pvec, int count, void *cbdata);
 bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 			  struct osc_object *osc, pgoff_t start, pgoff_t end,
 			  osc_page_gang_cbt cb, void *cbdata);
-
 bool osc_discard_cb(const struct lu_env *env, struct cl_io *io,
-		    struct osc_page *ops, void *cbdata);
+		    void **pvec, int count, void *cbdata);
 
 /* osc_dev.c */
 int osc_device_init(const struct lu_env *env, struct lu_device *d,
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 70f8987..0db05b5 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -183,33 +183,37 @@ struct ldlm_lock *mdc_dlmlock_at_pgoff(const struct lu_env *env,
  * Check if page @page is covered by an extra lock or discard it.
  */
 static bool mdc_check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
-				    struct osc_page *ops, void *cbdata)
+				     void **pvec, int count, void *cbdata)
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct osc_object *osc = cbdata;
 	pgoff_t index;
-
-	index = osc_index(ops);
-	if (index >= info->oti_fn_index) {
-		struct ldlm_lock *tmp;
-		struct cl_page *page = ops->ops_cl.cpl_page;
-
-		/* refresh non-overlapped index */
-		tmp = mdc_dlmlock_at_pgoff(env, osc, index,
-					   OSC_DAP_FL_TEST_LOCK | OSC_DAP_FL_AST);
-		if (tmp) {
-			info->oti_fn_index = CL_PAGE_EOF;
-			LDLM_LOCK_PUT(tmp);
-		} else if (cl_page_own(env, io, page) == 0) {
-			/* discard the page */
-			cl_page_discard(env, io, page);
-			cl_page_disown(env, io, page);
-		} else {
-			LASSERT(page->cp_state == CPS_FREEING);
+	int i;
+
+	for (i = 0; i < count; i++) {
+		struct osc_page *ops = pvec[i];
+
+		index = osc_index(ops);
+		if (index >= info->oti_fn_index) {
+			struct ldlm_lock *tmp;
+			struct cl_page *page = ops->ops_cl.cpl_page;
+
+			/* refresh non-overlapped index */
+			tmp = mdc_dlmlock_at_pgoff(env, osc, index,
+						   OSC_DAP_FL_TEST_LOCK | OSC_DAP_FL_AST);
+			if (tmp) {
+				info->oti_fn_index = CL_PAGE_EOF;
+				LDLM_LOCK_PUT(tmp);
+			} else if (cl_page_own(env, io, page) == 0) {
+				/* discard the page */
+				cl_page_discard(env, io, page);
+				cl_page_disown(env, io, page);
+			} else {
+				LASSERT(page->cp_state == CPS_FREEING);
+			}
 		}
+		info->oti_next_index = index + 1;
 	}
-
-	info->oti_next_index = index + 1;
 	return true;
 }
 
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index fc8079a..8dd12b1 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -3171,11 +3171,10 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 		spin_unlock(&osc->oo_tree_lock);
 		tree_lock = false;
 
+		res = (*cb)(env, io, pvec, j, cbdata);
+
 		for (i = 0; i < j; ++i) {
 			ops = pvec[i];
-			if (res)
-				res = (*cb)(env, io, ops, cbdata);
-
 			page = ops->ops_cl.cpl_page;
 			lu_ref_del(&page->cp_reference, "gang_lookup", current);
 			cl_pagevec_put(env, page, pagevec);
@@ -3204,55 +3203,93 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
  * Check if page @page is covered by an extra lock or discard it.
  */
 static bool check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
-				 struct osc_page *ops, void *cbdata)
+				 void **pvec, int count, void *cbdata)
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct osc_object *osc = cbdata;
-	struct cl_page *page = ops->ops_cl.cpl_page;
-	pgoff_t index;
-	bool discard = false;
-
-	index = osc_index(ops);
-	/* negative lock caching */
-	if (index < info->oti_ng_index) {
-		discard = true;
-	} else if (index >= info->oti_fn_index) {
-		struct ldlm_lock *tmp;
-
-		/* refresh non-overlapped index */
-		tmp = osc_dlmlock_at_pgoff(env, osc, index,
-					   OSC_DAP_FL_TEST_LOCK |
-					   OSC_DAP_FL_AST | OSC_DAP_FL_RIGHT);
-		if (tmp) {
-			u64 end = tmp->l_policy_data.l_extent.end;
-			u64 start = tmp->l_policy_data.l_extent.start;
-
-			/* no lock covering this page */
-			if (index < cl_index(osc2cl(osc), start)) {
-				/* no lock at @index, first lock at @start */
-				info->oti_ng_index = cl_index(osc2cl(osc),
-							      start);
+	int i;
+
+	for (i = 0; i < count; i++) {
+		struct osc_page *ops = pvec[i];
+		struct cl_page *page = ops->ops_cl.cpl_page;
+		pgoff_t index = osc_index(ops);
+		bool discard = false;
+
+		/* negative lock caching */
+		if (index < info->oti_ng_index) {
+			discard = true;
+		} else if (index >= info->oti_fn_index) {
+			struct ldlm_lock *tmp;
+
+			/* refresh non-overlapped index */
+			tmp = osc_dlmlock_at_pgoff(env, osc, index,
+						   OSC_DAP_FL_TEST_LOCK |
+						   OSC_DAP_FL_AST | OSC_DAP_FL_RIGHT);
+			if (tmp) {
+				u64 end = tmp->l_policy_data.l_extent.end;
+				u64 start = tmp->l_policy_data.l_extent.start;
+
+				/* no lock covering this page */
+				if (index < cl_index(osc2cl(osc), start)) {
+					/* no lock at @index,
+					 * first lock at @start
+					 */
+					info->oti_ng_index = cl_index(osc2cl(osc),
+								      start);
+					discard = true;
+				} else {
+					/* Cache the first-non-overlapped
+					 * index so as to skip all pages
+					 * within [index, oti_fn_index).
+					 * This is safe because if tmp lock
+					 * is canceled, it will discard these
+					 * pages.
+					 */
+					info->oti_fn_index = cl_index(osc2cl(osc),
+								      end + 1);
+					if (end == OBD_OBJECT_EOF)
+						info->oti_fn_index = CL_PAGE_EOF;
+				}
+				LDLM_LOCK_PUT(tmp);
+			} else {
+				info->oti_ng_index = CL_PAGE_EOF;
 				discard = true;
+			}
+		}
+
+		if (discard) {
+			if (cl_page_own(env, io, page) == 0) {
+				/* discard the page */
+				cl_page_discard(env, io, page);
+				cl_page_disown(env, io, page);
 			} else {
-				/* Cache the first-non-overlapped index so as to
-				 * skip all pages within [index, oti_fn_index).
-				 * This is safe because if tmp lock is canceled,
-				 * it will discard these pages.
-				 */
-				info->oti_fn_index = cl_index(osc2cl(osc),
-							      end + 1);
-				if (end == OBD_OBJECT_EOF)
-					info->oti_fn_index = CL_PAGE_EOF;
+				LASSERT(page->cp_state == CPS_FREEING);
 			}
-			LDLM_LOCK_PUT(tmp);
-		} else {
-			info->oti_ng_index = CL_PAGE_EOF;
-			discard = true;
 		}
+
+		info->oti_next_index = index + 1;
 	}
+	return true;
+}
 
-	if (discard) {
+bool osc_discard_cb(const struct lu_env *env, struct cl_io *io,
+		    void **pvec, int count, void *cbdata)
+{
+	struct osc_thread_info *info = osc_env_info(env);
+	int i;
+
+	for (i = 0; i < count; i++) {
+		struct osc_page *ops = pvec[i];
+		struct cl_page *page = ops->ops_cl.cpl_page;
+
+		/* page is top page. */
+		info->oti_next_index = osc_index(ops) + 1;
 		if (cl_page_own(env, io, page) == 0) {
+			if (page->cp_type == CPT_CACHEABLE &&
+			    PageDirty(cl_page_vmpage(page)))
+				CL_PAGE_DEBUG(D_ERROR, env, page,
+					      "discard dirty page?\n");
+
 			/* discard the page */
 			cl_page_discard(env, io, page);
 			cl_page_disown(env, io, page);
@@ -3261,32 +3298,6 @@ static bool check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 		}
 	}
 
-	info->oti_next_index = index + 1;
-
-	return true;
-}
-
-bool osc_discard_cb(const struct lu_env *env, struct cl_io *io,
-		    struct osc_page *ops, void *cbdata)
-{
-	struct osc_thread_info *info = osc_env_info(env);
-	struct cl_page *page = ops->ops_cl.cpl_page;
-
-	/* page is top page. */
-	info->oti_next_index = osc_index(ops) + 1;
-	if (cl_page_own(env, io, page) == 0) {
-		if (page->cp_type == CPT_CACHEABLE &&
-		    PageDirty(cl_page_vmpage(page)))
-			CL_PAGE_DEBUG(D_ERROR, env, page,
-				      "discard dirty page?\n");
-
-		/* discard the page */
-		cl_page_discard(env, io, page);
-		cl_page_disown(env, io, page);
-	} else {
-		LASSERT(page->cp_state == CPS_FREEING);
-	}
-
 	return true;
 }
 EXPORT_SYMBOL(osc_discard_cb);
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index b792c22..de214ba 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -491,22 +491,27 @@ static int osc_async_upcall(void *a, int rc)
  * Checks that there are no pages being written in the extent being truncated.
  */
 static bool trunc_check_cb(const struct lu_env *env, struct cl_io *io,
-			  struct osc_page *ops, void *cbdata)
+			   void **pvec, int count, void *cbdata)
 {
-	struct cl_page *page = ops->ops_cl.cpl_page;
-	struct osc_async_page *oap;
-	u64 start = *(u64 *)cbdata;
-
-	oap = &ops->ops_oap;
-	if (oap->oap_cmd & OBD_BRW_WRITE &&
-	    !list_empty(&oap->oap_pending_item))
-		CL_PAGE_DEBUG(D_ERROR, env, page, "exists %llu/%s.\n",
-			      start, current->comm);
-
-	if (PageLocked(page->cp_vmpage))
-		CDEBUG(D_CACHE, "page %p index %lu locked for %d.\n",
-		       ops, osc_index(ops), oap->oap_cmd & OBD_BRW_RWMASK);
+	int i;
 
+	for (i = 0; i < count; i++) {
+		struct osc_page *ops = pvec[i];
+		struct cl_page *page = ops->ops_cl.cpl_page;
+		struct osc_async_page *oap;
+		u64 start = *(u64 *)cbdata;
+
+		oap = &ops->ops_oap;
+		if (oap->oap_cmd & OBD_BRW_WRITE &&
+		    !list_empty(&oap->oap_pending_item))
+			CL_PAGE_DEBUG(D_ERROR, env, page, "exists %llu/%s.\n",
+				      start, current->comm);
+
+		if (PageLocked(page->cp_vmpage))
+			CDEBUG(D_CACHE, "page %p index %lu locked for %d.\n",
+			       ops, osc_index(ops),
+			       oap->oap_cmd & OBD_BRW_RWMASK);
+	}
 	return true;
 }
 
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index e0de371..422f3e5 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -647,16 +647,21 @@ int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 EXPORT_SYMBOL(osc_ldlm_glimpse_ast);
 
 static bool weigh_cb(const struct lu_env *env, struct cl_io *io,
-		     struct osc_page *ops, void *cbdata)
+		     void **pvec, int count, void *cbdata)
 {
-	struct cl_page *page = ops->ops_cl.cpl_page;
+	int i;
 
-	if (cl_page_is_vmlocked(env, page) ||
-	    PageDirty(page->cp_vmpage) ||
-	    PageWriteback(page->cp_vmpage))
-		return false;
+	for (i = 0; i < count; i++) {
+		struct osc_page *ops = pvec[i];
+		struct cl_page *page = ops->ops_cl.cpl_page;
 
-	*(pgoff_t *)cbdata = osc_index(ops) + 1;
+		if (cl_page_is_vmlocked(env, page) ||
+		    PageDirty(page->cp_vmpage) ||
+		    PageWriteback(page->cp_vmpage))
+			return false;
+
+		*(pgoff_t *)cbdata = osc_index(ops) + 1;
+	}
 	return true;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
