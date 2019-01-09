From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:01 +1100
Subject: [lustre-devel] [PATCH 06/29] lustre: osc: use overlapped()
 consistently.
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504133.26726.5055625028157924201.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

osc_extent_is_overlapped() open-codes exactly the test that
overlapped() performs.
So use overlapped() instead, to make the code more obviously
consistent.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index cab1a4f99cc2..dd3c87124aa5 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -313,6 +313,11 @@ static int osc_extent_sanity_check0(struct osc_extent *ext,
 	__res;								\
 })
 
+static inline int overlapped(struct osc_extent *ex1, struct osc_extent *ex2)
+{
+	return !(ex1->oe_end < ex2->oe_start || ex2->oe_end < ex1->oe_start);
+}
+
 /**
  * sanity check - to make sure there is no overlapped extent in the tree.
  */
@@ -329,8 +334,7 @@ static int osc_extent_is_overlapped(struct osc_object *obj,
 	for (tmp = first_extent(obj); tmp; tmp = next_extent(tmp)) {
 		if (tmp == ext)
 			continue;
-		if (tmp->oe_end >= ext->oe_start &&
-		    tmp->oe_start <= ext->oe_end)
+		if (overlapped(tmp, ext))
 			return 1;
 	}
 	return 0;
@@ -655,11 +659,6 @@ void osc_extent_release(const struct lu_env *env, struct osc_extent *ext)
 	osc_extent_put(env, ext);
 }
 
-static inline int overlapped(struct osc_extent *ex1, struct osc_extent *ex2)
-{
-	return !(ex1->oe_end < ex2->oe_start || ex2->oe_end < ex1->oe_start);
-}
-
 /**
  * Find or create an extent which includes @index, core function to manage
  * extent tree.
