From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:42 -0400
Subject: [lustre-devel] [PATCH 01/37] lustre: osc: fix osc_extent_find()
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

- fix a pre-existing bug - osc_extent_merge() should never try to
  merge two extends with different ->oe_mppr as later alignment
  checks can get confused.
- Remove a redundant list_del_init() which is already included in
  __osc_extent_remove().

Fixes: 85ebb57ddc ("lustre: osc: simplify osc_extent_find()")
WC-bug-id: https://jira.whamcloud.com/browse/LU-9679
Lustre-commit: 80e21cce3dd67 ("LU-9679 osc: simplify osc_extent_find()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/37607
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c | 33 +++++++++++++++------------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 5049aaa..474b711 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -574,6 +574,14 @@ static int osc_extent_merge(const struct lu_env *env, struct osc_extent *cur,
 	if (cur->oe_max_end != victim->oe_max_end)
 		return -ERANGE;
 
+	/*
+	 * In the rare case max_pages_per_rpc (mppr) is changed, don't
+	 * merge extents until after old ones have been sent, or the
+	 * "extents are aligned to RPCs" checks are unhappy.
+	 */
+	if (cur->oe_mppr != victim->oe_mppr)
+		return -ERANGE;
+
 	LASSERT(cur->oe_dlmlock == victim->oe_dlmlock);
 	ppc_bits = osc_cli(obj)->cl_chunkbits - PAGE_SHIFT;
 	chunk_start = cur->oe_start >> ppc_bits;
@@ -601,7 +609,6 @@ static int osc_extent_merge(const struct lu_env *env, struct osc_extent *cur,
 	cur->oe_urgent |= victim->oe_urgent;
 	cur->oe_memalloc |= victim->oe_memalloc;
 	list_splice_init(&victim->oe_pages, &cur->oe_pages);
-	list_del_init(&victim->oe_link);
 	victim->oe_nr_pages = 0;
 
 	osc_extent_get(victim);
@@ -727,8 +734,7 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 		cur->oe_start = descr->cld_start;
 	if (cur->oe_end > max_end)
 		cur->oe_end = max_end;
-	LASSERT(*grants >= chunksize);
-	cur->oe_grants = chunksize;
+	cur->oe_grants = chunksize + cli->cl_grant_extent_tax;
 	cur->oe_mppr = max_pages;
 	if (olck->ols_dlmlock) {
 		LASSERT(olck->ols_hold);
@@ -800,17 +806,8 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 			 */
 			continue;
 
-		/* it's required that an extent must be contiguous at chunk
-		 * level so that we know the whole extent is covered by grant
-		 * (the pages in the extent are NOT required to be contiguous).
-		 * Otherwise, it will be too much difficult to know which
-		 * chunks have grants allocated.
-		 */
-		/* On success, osc_extent_merge() will put cur,
-		 * so we take an extra reference
-		 */
-		osc_extent_get(cur);
 		if (osc_extent_merge(env, ext, cur) == 0) {
+			LASSERT(*grants >= chunksize);
 			*grants -= chunksize;
 			found = osc_extent_hold(ext);
 
@@ -824,19 +821,19 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 
 			break;
 		}
-		osc_extent_put(env, cur);
 	}
 
 	osc_extent_tree_dump(D_CACHE, obj);
 	if (found) {
 		LASSERT(!conflict);
-		LASSERT(found->oe_dlmlock == cur->oe_dlmlock);
-		OSC_EXTENT_DUMP(D_CACHE, found,
-				"found caching ext for %lu.\n", index);
+		if (!IS_ERR(found)) {
+			LASSERT(found->oe_dlmlock == cur->oe_dlmlock);
+			OSC_EXTENT_DUMP(D_CACHE, found,
+					"found caching ext for %lu.\n", index);
+		}
 	} else if (!conflict) {
 		/* create a new extent */
 		EASSERT(osc_extent_is_overlapped(obj, cur) == 0, cur);
-		cur->oe_grants = chunksize + cli->cl_grant_extent_tax;
 		LASSERT(*grants >= cur->oe_grants);
 		*grants -= cur->oe_grants;
 
-- 
1.8.3.1
