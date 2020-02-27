From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:45 -0500
Subject: [lustre-devel] [PATCH 477/622] lustre: lov: Move page index to top
 level
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-478-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

When doing readahead, we see an amazing amount of time
(~5-8%) just looking up the page index from the lov layer.

In particular, this is more than half the time spent
submitting pages:
         - 14.14% cl_io_submit_rw
            - 13.40% lov_io_submit
               - 8.24% lov_page_index

This requires several indirections, all of which can be
avoided by moving this up to the cl_page struct.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12535
Lustre-commit: 8d6d2914cf85 ("LU-12535 lov: Move page index to top level")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35470
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h   |  2 ++
 fs/lustre/lov/lov_cl_internal.h |  2 --
 fs/lustre/lov/lov_io.c          | 21 +++++----------------
 fs/lustre/lov/lov_page.c        | 10 +++++-----
 4 files changed, 12 insertions(+), 23 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 65fdab9..4c68d7b 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -762,6 +762,8 @@ struct cl_page {
 	struct lu_ref_link		 cp_queue_ref;
 	/** Assigned if doing a sync_io */
 	struct cl_sync_io		*cp_sync_io;
+	/** layout_entry + stripe index, composed using lov_comp_index() */
+	unsigned int			 cp_lov_index;
 };
 
 /**
diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 40bb6f0..8791e69 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -440,8 +440,6 @@ struct lov_lock {
 
 struct lov_page {
 	struct cl_page_slice	lps_cl;
-	/** layout_entry + stripe index, composed using lov_comp_index() */
-	unsigned int		lps_index;
 	/* the layout gen when this page was created */
 	u32			lps_layout_gen;
 };
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index fbed3de..56e4a982 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -189,17 +189,6 @@ struct lov_io_sub *lov_sub_get(const struct lu_env *env,
  * Lov io operations.
  *
  */
-static int lov_page_index(const struct cl_page *page)
-{
-	const struct cl_page_slice *slice;
-
-	slice = cl_page_at(page, &lov_device_type);
-	LASSERT(slice);
-	LASSERT(slice->cpl_obj);
-
-	return cl2lov_page(slice)->lps_index;
-}
-
 static int lov_io_subio_init(const struct lu_env *env, struct lov_io *lio,
 			     struct cl_io *io)
 {
@@ -1105,10 +1094,10 @@ static int lov_io_submit(const struct lu_env *env,
 		cl_2queue_init(cl2q);
 		cl_page_list_move(&cl2q->c2_qin, qin, page);
 
-		index = lov_page_index(page);
+		index = page->cp_lov_index;
 		cl_page_list_for_each_safe(page, tmp, qin) {
 			/* this page is not on this stripe */
-			if (index != lov_page_index(page))
+			if (index != page->cp_lov_index)
 				continue;
 
 			cl_page_list_move(&cl2q->c2_qin, qin, page);
@@ -1171,10 +1160,10 @@ static int lov_io_commit_async(const struct lu_env *env,
 
 		cl_page_list_move(plist, queue, page);
 
-		index = lov_page_index(page);
+		index = page->cp_lov_index;
 		while (queue->pl_nr > 0) {
 			page = cl_page_list_first(queue);
-			if (index != lov_page_index(page))
+			if (index != page->cp_lov_index)
 				break;
 
 			cl_page_list_move(plist, queue, page);
@@ -1218,7 +1207,7 @@ static int lov_io_fault_start(const struct lu_env *env,
 
 	fio = &ios->cis_io->u.ci_fault;
 	lio = cl2lov_io(env, ios);
-	sub = lov_sub_get(env, lio, lov_page_index(fio->ft_page));
+	sub = lov_sub_get(env, lio, fio->ft_page->cp_lov_index);
 	if (IS_ERR(sub))
 		return PTR_ERR(sub);
 	sub->sub_io.u.ci_fault.ft_nob = fio->ft_nob;
diff --git a/fs/lustre/lov/lov_page.c b/fs/lustre/lov/lov_page.c
index c3337706..e73b5ff 100644
--- a/fs/lustre/lov/lov_page.c
+++ b/fs/lustre/lov/lov_page.c
@@ -57,8 +57,8 @@ static int lov_comp_page_print(const struct lu_env *env,
 	struct lov_page *lp = cl2lov_page(slice);
 
 	return (*printer)(env, cookie,
-			  LUSTRE_LOV_NAME "-page@%p, comp index: %x, gen: %u\n",
-			  lp, lp->lps_index, lp->lps_layout_gen);
+			  LUSTRE_LOV_NAME "-page@%p, gen: %u\n",
+			  lp, lp->lps_layout_gen);
 }
 
 static const struct cl_page_operations lov_comp_page_ops = {
@@ -95,11 +95,11 @@ int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
 	rc = lov_stripe_offset(loo->lo_lsm, entry, offset, stripe, &suboff);
 	LASSERT(rc == 0);
 
-	lpg->lps_index = lov_comp_index(entry, stripe);
+	page->cp_lov_index = lov_comp_index(entry, stripe);
 	lpg->lps_layout_gen = loo->lo_lsm->lsm_layout_gen;
 	cl_page_slice_add(page, &lpg->lps_cl, obj, index, &lov_comp_page_ops);
 
-	sub = lov_sub_get(env, lio, lpg->lps_index);
+	sub = lov_sub_get(env, lio, page->cp_lov_index);
 	if (IS_ERR(sub))
 		return PTR_ERR(sub);
 
@@ -136,7 +136,7 @@ int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
 	struct lov_page *lpg = cl_object_page_slice(obj, page);
 	void *addr;
 
-	lpg->lps_index = ~0;
+	page->cp_lov_index = ~0;
 	cl_page_slice_add(page, &lpg->lps_cl, obj, index, &lov_empty_page_ops);
 	addr = kmap(page->cp_vmpage);
 	memset(addr, 0, cl_page_size(obj));
-- 
1.8.3.1
