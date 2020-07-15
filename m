From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:58 -0400
Subject: [lustre-devel] [PATCH 17/37] lustre: osc: re-declare ops_from/to to
 shrink osc_page
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

@ops_from and @ops_to is within PAGE_SIZE, use PAGE_SHIFT
bits to limit it is fine, on x86_64 platform, this patch
will reduce another 8 bytes.

Notice, previous @ops_to is exclusive which could be PAGE_SIZE,
this patch change it to inclusive which means max value will be
PAGE_SIZE - 1, and be careful to calculate its length.

After this patch, cl_page size could reduce from 320 to 312 bytes,
and we are able to allocate 13 objects using slab pool for 4K page.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13134
Lustre-commit: 9821754235e24 ("LU-13134 osc: re-declare ops_from/to to shrink osc_page")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/37487
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  8 ++++----
 fs/lustre/osc/osc_cache.c      |  5 +++--
 fs/lustre/osc/osc_page.c       | 21 +++++++++++----------
 3 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index cd08f27..3956ab4 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -507,17 +507,17 @@ struct osc_page {
 	 * An offset within page from which next transfer starts. This is used
 	 * by cl_page_clip() to submit partial page transfers.
 	 */
-	int			ops_from;
+	unsigned int		ops_from:PAGE_SHIFT,
 	/*
-	 * An offset within page at which next transfer ends.
+	 * An offset within page at which next transfer ends(inclusive).
 	 *
 	 * \see osc_page::ops_from.
 	 */
-	int			ops_to;
+				ops_to:PAGE_SHIFT,
 	/*
 	 * Boolean, true iff page is under transfer. Used for sanity checking.
 	 */
-	unsigned		ops_transfer_pinned:1,
+				ops_transfer_pinned:1,
 	/*
 	 * in LRU?
 	 */
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index f811dadb..fe03c0d 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2395,7 +2395,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 
 	oap->oap_cmd = cmd;
 	oap->oap_page_off = ops->ops_from;
-	oap->oap_count = ops->ops_to - ops->ops_from;
+	oap->oap_count = ops->ops_to - ops->ops_from + 1;
 	/*
 	 * No need to hold a lock here,
 	 * since this page is not in any list yet.
@@ -2664,7 +2664,8 @@ int osc_queue_sync_pages(const struct lu_env *env, const struct cl_io *io,
 		++page_count;
 		mppr <<= (page_count > mppr);
 
-		if (unlikely(opg->ops_from > 0 || opg->ops_to < PAGE_SIZE))
+		if (unlikely(opg->ops_from > 0 ||
+			     opg->ops_to < PAGE_SIZE - 1))
 			can_merge = false;
 	}
 
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 2856f30..bb605af 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -211,7 +211,8 @@ static void osc_page_clip(const struct lu_env *env,
 	struct osc_async_page *oap = &opg->ops_oap;
 
 	opg->ops_from = from;
-	opg->ops_to = to;
+	/* argument @to is exclusive, but @ops_to is inclusive */
+	opg->ops_to = to - 1;
 	spin_lock(&oap->oap_lock);
 	oap->oap_async_flags |= ASYNC_COUNT_STABLE;
 	spin_unlock(&oap->oap_lock);
@@ -246,28 +247,28 @@ static void osc_page_touch(const struct lu_env *env,
 };
 
 int osc_page_init(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_page *page, pgoff_t index)
+		  struct cl_page *cl_page, pgoff_t index)
 {
 	struct osc_object *osc = cl2osc(obj);
-	struct osc_page *opg = cl_object_page_slice(obj, page);
+	struct osc_page *opg = cl_object_page_slice(obj, cl_page);
 	struct osc_io *oio = osc_env_io(env);
 	int result;
 
 	opg->ops_from = 0;
-	opg->ops_to = PAGE_SIZE;
+	opg->ops_to = PAGE_SIZE - 1;
 	INIT_LIST_HEAD(&opg->ops_lru);
 
-	result = osc_prep_async_page(osc, opg, page->cp_vmpage,
+	result = osc_prep_async_page(osc, opg, cl_page->cp_vmpage,
 				     cl_offset(obj, index));
 	if (result != 0)
 		return result;
 
 	opg->ops_srvlock = osc_io_srvlock(oio);
-	cl_page_slice_add(page, &opg->ops_cl, obj, &osc_page_ops);
-	page->cp_osc_index = index;
+	cl_page_slice_add(cl_page, &opg->ops_cl, obj, &osc_page_ops);
+	cl_page->cp_osc_index = index;
 
-	/* reserve an LRU space for this page */
-	if (page->cp_type == CPT_CACHEABLE) {
+	/* reserve an LRU space for this cl_page */
+	if (cl_page->cp_type == CPT_CACHEABLE) {
 		result = osc_lru_alloc(env, osc_cli(osc), opg);
 		if (result == 0) {
 			result = radix_tree_preload(GFP_KERNEL);
@@ -308,7 +309,7 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 
 	oap->oap_cmd = crt == CRT_WRITE ? OBD_BRW_WRITE : OBD_BRW_READ;
 	oap->oap_page_off = opg->ops_from;
-	oap->oap_count = opg->ops_to - opg->ops_from;
+	oap->oap_count = opg->ops_to - opg->ops_from + 1;
 	oap->oap_brw_flags = OBD_BRW_SYNC | brw_flags;
 
 	if (oio->oi_cap_sys_resource) {
-- 
1.8.3.1
