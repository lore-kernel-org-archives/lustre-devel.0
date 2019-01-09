From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:01 +1100
Subject: [lustre-devel] [PATCH 08/29] lustre: osc: simplify osc_extent_find()
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504144.26726.6306839878824560964.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

osc_extent_find() contains some code with the same functionality as
osc_extent_merge().  So replace that code with a call to
osc_extent_merge().

This requires that we:
 - set cur->oe_grants earlier, as osc_extent_merge() needs that
 - take an extra temporary ref to cur, as osc_extent_merge()
   will drop the ref we have on success.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |   50 ++++++-------------------
 1 file changed, 12 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index eb8de1503386..848e440ae2a9 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -718,7 +718,8 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 		cur->oe_start = descr->cld_start;
 	if (cur->oe_end > max_end)
 		cur->oe_end = max_end;
-	cur->oe_grants = 0;
+	LASSERT(*grants >= chunksize);
+	cur->oe_grants = chunksize;
 	cur->oe_mppr = max_pages;
 	if (olck->ols_dlmlock) {
 		LASSERT(olck->ols_hold);
@@ -790,58 +791,31 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 			 */
 			continue;
 
-		/* check if they belong to the same rpc slot before trying to
-		 * merge. the extents are not overlapped and contiguous at
-		 * chunk level to get here.
-		 */
-		if (ext->oe_max_end != max_end)
-			/* if they don't belong to the same RPC slot or
-			 * max_pages_per_rpc has ever changed, do not merge.
-			 */
-			continue;
-
-		/* check whether maximum extent size will be hit */
-		if ((ext_chk_end - ext_chk_start + 1) << ppc_bits >
-		    cli->cl_max_extent_pages)
-			continue;
-
 		/* it's required that an extent must be contiguous at chunk
 		 * level so that we know the whole extent is covered by grant
 		 * (the pages in the extent are NOT required to be contiguous).
 		 * Otherwise, it will be too much difficult to know which
 		 * chunks have grants allocated.
 		 */
-
-		/* try to do front merge - extend ext's start */
-		if (chunk + 1 == ext_chk_start) {
-			/* ext must be chunk size aligned */
-			EASSERT((ext->oe_start & ~chunk_mask) == 0, ext);
-
-			/* pull ext's start back to cover cur */
-			ext->oe_start = cur->oe_start;
-			ext->oe_grants += chunksize;
-			LASSERT(*grants >= chunksize);
+		/* On success, osc_extent_merge() will put cur,
+		 * so we take an extra reference
+		 */
+		osc_extent_get(cur);
+		if (osc_extent_merge(env, ext, cur) == 0) {
 			*grants -= chunksize;
-
 			found = osc_extent_hold(ext);
-		} else if (chunk == ext_chk_end + 1) {
-			/* rear merge */
-			ext->oe_end = cur->oe_end;
-			ext->oe_grants += chunksize;
-			LASSERT(*grants >= chunksize);
-			*grants -= chunksize;
 
-			/* try to merge with the next one because we just fill
-			 * in a gap
+			/*
+			 * Try to merge with the next one too because we
+			 * might have just filled in a gap.
 			 */
 			if (osc_extent_merge(env, ext, next_extent(ext)) == 0)
 				/* we can save extent tax from next extent */
 				*grants += cli->cl_grant_extent_tax;
 
-			found = osc_extent_hold(ext);
-		}
-		if (found)
 			break;
+		}
+		osc_extent_put(env, cur);
 	}
 
 	osc_extent_tree_dump(D_CACHE, obj);
