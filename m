From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Wed, 14 Oct 2015 00:23:34 +0200
Subject: [lustre-devel] [PATCH 3/7] staging: lustre: lu_object.c: replace
 container_of0 by container_of
In-Reply-To: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <c6f08bd387c60ccd36fdebb3a0fe9de7e3c84e0e.1444774232.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Replaces container_of0 by container_of. The only difference between
the two implementations is that container_of0 tries to evade
type casting if the pointer is erroneous or null. The use of
container_of is encouraged to bring lustre one step closer to
community standards.

Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 0d15bd5..82873fb 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -294,7 +294,7 @@ static void lu_object_free(const struct lu_env *env, struct lu_object *o)
 		 * lives as long as possible and ->loo_object_free() methods
 		 * can look at its contents.
 		 */
-		o = container_of0(splice.prev, struct lu_object, lo_linkage);
+		o = container_of(splice.prev, struct lu_object, lo_linkage);
 		list_del_init(&o->lo_linkage);
 		LASSERT(o->lo_ops->loo_object_free != NULL);
 		o->lo_ops->loo_object_free(env, o);
@@ -368,7 +368,7 @@ int lu_site_purge(const struct lu_env *env, struct lu_site *s, int nr)
 		 * races due to the reasons described in lu_object_put().
 		 */
 		while (!list_empty(&dispose)) {
-			h = container_of0(dispose.next,
+			h = container_of(dispose.next,
 					  struct lu_object_header, loh_lru);
 			list_del_init(&h->loh_lru);
 			lu_object_free(env, lu_object_top(h));
@@ -542,7 +542,7 @@ static struct lu_object *htable_lookup(struct lu_site *s,
 		return ERR_PTR(-ENOENT);
 	}
 
-	h = container_of0(hnode, struct lu_object_header, loh_hash);
+	h = container_of(hnode, struct lu_object_header, loh_hash);
 	if (likely(!lu_object_is_dying(h))) {
 		cfs_hash_get(s->ls_obj_hash, hnode);
 		lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_HIT);
-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
