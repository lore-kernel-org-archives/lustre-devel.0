From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:58 -0500
Subject: [lustre-devel] [PATCH 310/622] lustre: obdclass: remove unprotected
 access to lu_object
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-311-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

The check of lu_object_is_dying() is done after reference
drop and without lock, so can access freed object if concurrent
thread did final put.

The patch saves object state right before atomic_dec_and_lock()
and checks it after check, so object is not being accessed

WC-bug-id: https://jira.whamcloud.com/browse/LU-11204
Lustre-commit: 336cf0f2f3a9 ("LU-11204 obdclass: remove unprotected access to lu_object")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34960
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lu_object.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index 2f709b0..bafd817 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -128,22 +128,18 @@ enum {
 void lu_object_put(const struct lu_env *env, struct lu_object *o)
 {
 	struct lu_site_bkt_data *bkt;
-	struct lu_object_header *top;
-	struct lu_site *site;
-	struct lu_object *orig;
+	struct lu_object_header *top = o->lo_header;
+	struct lu_site *site = o->lo_dev->ld_site;
+	struct lu_object *orig = o;
 	struct cfs_hash_bd bd;
-	const struct lu_fid *fid;
-
-	top  = o->lo_header;
-	site = o->lo_dev->ld_site;
-	orig = o;
+	const struct lu_fid *fid = lu_object_fid(o);
+	bool is_dying;
 
 	/*
 	 * till we have full fids-on-OST implemented anonymous objects
 	 * are possible in OSP. such an object isn't listed in the site
 	 * so we should not remove it from the site.
 	 */
-	fid = lu_object_fid(o);
 	if (fid_is_zero(fid)) {
 		LASSERT(!top->loh_hash.next && !top->loh_hash.pprev);
 		LASSERT(list_empty(&top->loh_lru));
@@ -160,8 +156,14 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 	cfs_hash_bd_get(site->ls_obj_hash, &top->loh_fid, &bd);
 	bkt = cfs_hash_bd_extra_get(site->ls_obj_hash, &bd);
 
+	is_dying = lu_object_is_dying(top);
 	if (!cfs_hash_bd_dec_and_lock(site->ls_obj_hash, &bd, &top->loh_ref)) {
-		if (lu_object_is_dying(top)) {
+		/* at this point the object reference is dropped and lock is
+		 * not taken, so lu_object should not be touched because it
+		 * can be freed by concurrent thread. Use local variable for
+		 * check.
+		 */
+		if (is_dying) {
 			/*
 			 * somebody may be waiting for this, currently only
 			 * used for cl_object, see cl_object_put_last().
@@ -180,6 +182,10 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 			o->lo_ops->loo_object_release(env, o);
 	}
 
+	/* don't use local 'is_dying' here because if was taken without lock
+	 * but here we need the latest actual value of it so check lu_object
+	 * directly here.
+	 */
 	if (!lu_object_is_dying(top)) {
 		LASSERT(list_empty(&top->loh_lru));
 		list_add_tail(&top->loh_lru, &bkt->lsb_lru);
-- 
1.8.3.1
