From: NeilBrown <neilb@suse.com>
Date: Tue, 01 May 2018 13:52:39 +1000
Subject: [lustre-devel] [PATCH 05/10] staging: lustre: fold lu_object_new()
 into lu_object_find_at()
In-Reply-To: <152514658325.17843.11455067361317157487.stgit@noble>
References: <152514658325.17843.11455067361317157487.stgit@noble>
Message-ID: <152514675900.17843.13720388713238865482.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

lu_object_new() duplicates a lot of code that is in
lu_object_find_at().
There is no real need for a separate function, it is simpler just
to skip the bits of lu_object_find_at() that we don't
want in the LOC_F_NEW case.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   44 +++++---------------
 1 file changed, 12 insertions(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 93daa52e2535..9721b3af8ea8 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -678,29 +678,6 @@ static void lu_object_limit(const struct lu_env *env, struct lu_device *dev)
 			      false);
 }
 
-static struct lu_object *lu_object_new(const struct lu_env *env,
-				       struct lu_device *dev,
-				       const struct lu_fid *f,
-				       const struct lu_object_conf *conf)
-{
-	struct lu_object	*o;
-	struct cfs_hash	      *hs;
-	struct cfs_hash_bd	    bd;
-
-	o = lu_object_alloc(env, dev, f, conf);
-	if (IS_ERR(o))
-		return o;
-
-	hs = dev->ld_site->ls_obj_hash;
-	cfs_hash_bd_get_and_lock(hs, (void *)f, &bd, 1);
-	cfs_hash_bd_add_locked(hs, &bd, &o->lo_header->loh_hash);
-	cfs_hash_bd_unlock(hs, &bd, 1);
-
-	lu_object_limit(env, dev);
-
-	return o;
-}
-
 /**
  * Much like lu_object_find(), but top level device of object is specifically
  * \a dev rather than top level device of the site. This interface allows
@@ -736,18 +713,18 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 	 * just alloc and insert directly.
 	 *
 	 */
-	if (conf && conf->loc_flags & LOC_F_NEW)
-		return lu_object_new(env, dev, f, conf);
-
 	s  = dev->ld_site;
 	hs = s->ls_obj_hash;
-	cfs_hash_bd_get_and_lock(hs, (void *)f, &bd, 0);
-	o = htable_lookup(s, &bd, f, &version);
-	cfs_hash_bd_unlock(hs, &bd, 0);
 
-	if (!IS_ERR(o) || PTR_ERR(o) != -ENOENT)
-		return o;
+	cfs_hash_bd_get(hs, f, &bd);
+	if (!(conf && conf->loc_flags & LOC_F_NEW)) {
+		cfs_hash_bd_lock(hs, &bd, 0);
+		o = htable_lookup(s, &bd, f, &version);
+		cfs_hash_bd_unlock(hs, &bd, 0);
 
+		if (!IS_ERR(o) || PTR_ERR(o) != -ENOENT)
+			return o;
+	}
 	/*
 	 * Allocate new object. This may result in rather complicated
 	 * operations, including fld queries, inode loading, etc.
@@ -760,7 +737,10 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 
 	cfs_hash_bd_lock(hs, &bd, 1);
 
-	shadow = htable_lookup(s, &bd, f, &version);
+	if (conf && conf->loc_flags & LOC_F_NEW)
+		shadow = ERR_PTR(-ENOENT);
+	else
+		shadow = htable_lookup(s, &bd, f, &version);
 	if (likely(PTR_ERR(shadow) == -ENOENT)) {
 		cfs_hash_bd_add_locked(hs, &bd, &o->lo_header->loh_hash);
 		cfs_hash_bd_unlock(hs, &bd, 1);
