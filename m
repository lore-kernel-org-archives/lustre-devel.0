From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:31 -0400
Subject: [lustre-devel] [PATCH 072/151] lustre: lov: skip empty pages in
 lov_io_submit()
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-73-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

empty page doesn't have corresponding bottem half so it should be
completed in the LOV layer.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
Lustre-commit: ec7eb7a932b7 ("LU-9771 lov: skip empty pages in lov_io_submit()")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/29094
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_cl_internal.h |  1 +
 fs/lustre/lov/lov_io.c          | 26 +++++++++++++-------------
 fs/lustre/lov/lov_page.c        |  8 ++++++++
 3 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index ad4a3d3..095bca0 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -651,6 +651,7 @@ struct lu_object *lovsub_object_alloc(const struct lu_env *env,
 				      struct lu_device *dev);
 
 struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov);
+bool lov_page_is_empty(const struct cl_page *page);
 int lov_lsm_entry(const struct lov_stripe_md *lsm, u64 offset);
 int lov_io_layout_at(struct lov_io *lio, u64 offset);
 
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 457fa3c..8e4ff6c 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -990,24 +990,20 @@ static int lov_io_submit(const struct lu_env *env,
 	int index;
 	int rc = 0;
 
-	if (lio->lis_nr_subios == 1) {
-		int idx = lio->lis_single_subio_index;
-
-		sub = lov_sub_get(env, lio, idx);
-		LASSERT(!IS_ERR(sub));
-		LASSERT(sub == &lio->lis_single_subio);
-		rc = cl_io_submit_rw(sub->sub_env, &sub->sub_io,
-				     crt, queue);
-		return rc;
-	}
-
 	cl_page_list_init(plist);
 	while (qin->pl_nr > 0) {
 		struct cl_2queue *cl2q = &lov_env_info(env)->lti_cl2q;
 
-		cl_2queue_init(cl2q);
-
 		page = cl_page_list_first(qin);
+		if (lov_page_is_empty(page)) {
+			cl_page_list_move(&queue->c2_qout, qin, page);
+
+			cl_page_prep(env, ios->cis_io, page, crt);
+			cl_page_completion(env, page, crt, 0);
+			continue;
+		}
+
+		cl_2queue_init(cl2q);
 		cl_page_list_move(&cl2q->c2_qin, qin, page);
 
 		index = lov_page_index(page);
@@ -1055,6 +1051,8 @@ static int lov_io_commit_async(const struct lu_env *env,
 	if (lio->lis_nr_subios == 1) {
 		int idx = lio->lis_single_subio_index;
 
+		LASSERT(!lov_page_is_empty(cl_page_list_first(queue)));
+
 		sub = lov_sub_get(env, lio, idx);
 		LASSERT(!IS_ERR(sub));
 		LASSERT(sub == &lio->lis_single_subio);
@@ -1070,6 +1068,8 @@ static int lov_io_commit_async(const struct lu_env *env,
 
 		LASSERT(plist->pl_nr == 0);
 		page = cl_page_list_first(queue);
+		LASSERT(!lov_page_is_empty(page));
+
 		cl_page_list_move(plist, queue, page);
 
 		index = lov_page_index(page);
diff --git a/fs/lustre/lov/lov_page.c b/fs/lustre/lov/lov_page.c
index 327bcd3..22548f4 100644
--- a/fs/lustre/lov/lov_page.c
+++ b/fs/lustre/lov/lov_page.c
@@ -136,6 +136,7 @@ int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
 	struct lov_page *lpg = cl_object_page_slice(obj, page);
 	void *addr;
 
+	lpg->lps_index = ~0;
 	cl_page_slice_add(page, &lpg->lps_cl, obj, index, &lov_empty_page_ops);
 	addr = kmap(page->cp_vmpage);
 	memset(addr, 0, cl_page_size(obj));
@@ -144,4 +145,11 @@ int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
 	return 0;
 }
 
+bool lov_page_is_empty(const struct cl_page *page)
+{
+	const struct cl_page_slice *slice = cl_page_at(page, &lov_device_type);
+
+	LASSERT(slice);
+	return slice->cpl_ops == &lov_empty_page_ops;
+}
 /** @} lov */
-- 
1.8.3.1
