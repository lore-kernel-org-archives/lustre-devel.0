From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:33 -0400
Subject: [lustre-devel] [PATCH 23/30] lustre: osc: adds radix_tree_preload
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexandr Boyko <c17825@cray.com>

The client fail with next error osc_page_init())
ASSERTION( result == 0 ) in low memory conditions.

The patch fixes the problem above by adding
radix_tree_preload.

Signed-off-by: Alexandr Boyko <c17825@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9579
Seagate-bug-id: MRP-4424
Reviewed-on: https://review.whamcloud.com/27372
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_page.c | 33 ++++++++++++++++------------
 1 file changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 189e3e78..ada1eda 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -256,32 +256,37 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 {
 	struct osc_object *osc = cl2osc(obj);
 	struct osc_page *opg = cl_object_page_slice(obj, page);
+	struct osc_io *oio = osc_env_io(env);
 	int result;
 
 	opg->ops_from = 0;
 	opg->ops_to = PAGE_SIZE;
+	INIT_LIST_HEAD(&opg->ops_lru);
 
 	result = osc_prep_async_page(osc, opg, page->cp_vmpage,
 				     cl_offset(obj, index));
-	if (result == 0) {
-		struct osc_io *oio = osc_env_io(env);
+	if (result != 0)
+		return result;
 
-		opg->ops_srvlock = osc_io_srvlock(oio);
-		cl_page_slice_add(page, &opg->ops_cl, obj, index,
-				  &osc_page_ops);
-	}
-	INIT_LIST_HEAD(&opg->ops_lru);
+	opg->ops_srvlock = osc_io_srvlock(oio);
+	cl_page_slice_add(page, &opg->ops_cl, obj, index,
+			  &osc_page_ops);
 
 	/* reserve an LRU space for this page */
-	if (page->cp_type == CPT_CACHEABLE && result == 0) {
+	if (page->cp_type == CPT_CACHEABLE) {
 		result = osc_lru_alloc(env, osc_cli(osc), opg);
 		if (result == 0) {
-			spin_lock(&osc->oo_tree_lock);
-			result = radix_tree_insert(&osc->oo_tree, index, opg);
-			if (result == 0)
-				++osc->oo_npages;
-			spin_unlock(&osc->oo_tree_lock);
-			LASSERT(result == 0);
+			result = radix_tree_preload(GFP_KERNEL);
+			if (result == 0) {
+				spin_lock(&osc->oo_tree_lock);
+				result = radix_tree_insert(&osc->oo_tree,
+							   index, opg);
+				if (result == 0)
+					++osc->oo_npages;
+				spin_unlock(&osc->oo_tree_lock);
+
+				radix_tree_preload_end();
+			}
 		}
 	}
 
-- 
1.8.3.1
