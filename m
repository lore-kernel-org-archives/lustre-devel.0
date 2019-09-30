From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:29 -0400
Subject: [lustre-devel] [PATCH 130/151] lustre: osc: add a bit to indicate
 osc_page in cache tree
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-131-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

Add osc_page::ops_intree to indicate whether the osc_page is in the
osc_object's cache tree, so that when page cannot insert in the
cache as race happens, the cleanup code won't try to remove it from
the cache.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10244
Lustre-commit: ed91ee6bd642 ("LU-10244 osc: add a bit to indicate osc_page in cache tree")
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-on: https://review.whamcloud.com/30096
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  6 +++++-
 fs/lustre/osc/osc_page.c       | 17 ++++++++++++-----
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 38ae83a8..5ba4f97 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -524,7 +524,11 @@ struct osc_page {
 	/*
 	 * Set if the page must be transferred with OBD_BRW_SRVLOCK.
 	 */
-				ops_srvlock:1;
+				ops_srvlock:1,
+	/**
+	 * If the page is in osc_object::oo_tree.
+	 */
+				ops_intree:1;
 	/*
 	 * lru page list. See osc_lru_{del|use}() in osc_page.c for usage.
 	 */
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 731fd27..9236e02 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -192,12 +192,17 @@ static void osc_page_delete(const struct lu_env *env,
 	osc_lru_del(osc_cli(obj), opg);
 
 	if (slice->cpl_page->cp_type == CPT_CACHEABLE) {
-		void *value;
+		void *value = NULL;
 
 		spin_lock(&obj->oo_tree_lock);
-		value = radix_tree_delete(&obj->oo_tree, osc_index(opg));
-		if (value)
-			--obj->oo_npages;
+		if (opg->ops_intree) {
+			value = radix_tree_delete(&obj->oo_tree,
+						  osc_index(opg));
+			if (value) {
+				--obj->oo_npages;
+				opg->ops_intree = 0;
+			}
+		}
 		spin_unlock(&obj->oo_tree_lock);
 
 		LASSERT(ergo(value, value == opg));
@@ -275,8 +280,10 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 				spin_lock(&osc->oo_tree_lock);
 				result = radix_tree_insert(&osc->oo_tree,
 							   index, opg);
-				if (result == 0)
+				if (result == 0) {
 					++osc->oo_npages;
+					opg->ops_intree = 1;
+				}
 				spin_unlock(&osc->oo_tree_lock);
 
 				radix_tree_preload_end();
-- 
1.8.3.1
