From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:01 +1100
Subject: [lustre-devel] [PATCH 05/29] lustre: osc: convert oe_refc and
 oe_users to kref and refcount_
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504126.26726.9018865558337243745.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

oe_refc is used like a kref, so make it one.
oe_users isn't quite, as it is initialised to 0, so make it a
refcount_t.

As cl_object_put() needs an 'env', we cannot quite use
kref_put() as intended.  Maybe that can be fixed one day.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   73 ++++++++++++--------
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |    4 +
 2 files changed, 45 insertions(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 6771675dd520..cab1a4f99cc2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -114,8 +114,8 @@ static const char *oes_strings[] = {
 		/* ----- extent part 0 ----- */				      \
 		__ext, EXTPARA(__ext),					      \
 		/* ----- part 1 ----- */				      \
-		atomic_read(&__ext->oe_refc),				      \
-		atomic_read(&__ext->oe_users),				      \
+		kref_read(&__ext->oe_refc),				      \
+		refcount_read(&__ext->oe_users),			      \
 		list_empty_marker(&__ext->oe_link),			      \
 		oes_strings[__ext->oe_state], ext_flags(__ext, __buf),	      \
 		__ext->oe_obj,						      \
@@ -188,12 +188,12 @@ static int osc_extent_sanity_check0(struct osc_extent *ext,
 		goto out;
 	}
 
-	if (atomic_read(&ext->oe_refc) <= 0) {
+	if (kref_read(&ext->oe_refc) <= 0) {
 		rc = 20;
 		goto out;
 	}
 
-	if (atomic_read(&ext->oe_refc) < atomic_read(&ext->oe_users)) {
+	if (kref_read(&ext->oe_refc) < refcount_read(&ext->oe_users)) {
 		rc = 30;
 		goto out;
 	}
@@ -206,7 +206,7 @@ static int osc_extent_sanity_check0(struct osc_extent *ext,
 			rc = 0;
 		goto out;
 	case OES_ACTIVE:
-		if (atomic_read(&ext->oe_users) == 0) {
+		if (refcount_read(&ext->oe_users) == 0) {
 			rc = 40;
 			goto out;
 		}
@@ -230,7 +230,7 @@ static int osc_extent_sanity_check0(struct osc_extent *ext,
 		}
 		/* fall through */
 	default:
-		if (atomic_read(&ext->oe_users) > 0) {
+		if (refcount_read(&ext->oe_users) > 0) {
 			rc = 70;
 			goto out;
 		}
@@ -360,8 +360,8 @@ static struct osc_extent *osc_extent_alloc(struct osc_object *obj)
 	RB_CLEAR_NODE(&ext->oe_node);
 	ext->oe_obj = obj;
 	cl_object_get(osc2cl(obj));
-	atomic_set(&ext->oe_refc, 1);
-	atomic_set(&ext->oe_users, 0);
+	kref_init(&ext->oe_refc);
+	refcount_set(&ext->oe_users, 0);
 	INIT_LIST_HEAD(&ext->oe_link);
 	ext->oe_state = OES_INV;
 	INIT_LIST_HEAD(&ext->oe_pages);
@@ -371,35 +371,48 @@ static struct osc_extent *osc_extent_alloc(struct osc_object *obj)
 	return ext;
 }
 
-static void osc_extent_free(struct osc_extent *ext)
+static void osc_extent_free(struct kref *kref)
 {
+	struct osc_extent *ext = container_of(kref, struct osc_extent,
+					      oe_refc);
+
+	LASSERT(list_empty(&ext->oe_link));
+	LASSERT(refcount_read(&ext->oe_users) == 0);
+	LASSERT(ext->oe_state == OES_INV);
+	LASSERT(RB_EMPTY_NODE(&ext->oe_node));
+
+	if (ext->oe_dlmlock) {
+		lu_ref_add(&ext->oe_dlmlock->l_reference,
+			   "osc_extent", ext);
+		LDLM_LOCK_PUT(ext->oe_dlmlock);
+		ext->oe_dlmlock = NULL;
+	}
+#if 0
+	// When cl_object_put drop the need for 'env',
+	// this code can be enabled.
+	cl_object_put(osc2cl(ext->oe_obj));
+
 	kmem_cache_free(osc_extent_kmem, ext);
+#endif
 }
 
 static struct osc_extent *osc_extent_get(struct osc_extent *ext)
 {
-	LASSERT(atomic_read(&ext->oe_refc) >= 0);
-	atomic_inc(&ext->oe_refc);
+	LASSERT(kref_read(&ext->oe_refc) >= 0);
+	kref_get(&ext->oe_refc);
 	return ext;
 }
 
 static void osc_extent_put(const struct lu_env *env, struct osc_extent *ext)
 {
-	LASSERT(atomic_read(&ext->oe_refc) > 0);
-	if (atomic_dec_and_test(&ext->oe_refc)) {
-		LASSERT(list_empty(&ext->oe_link));
-		LASSERT(atomic_read(&ext->oe_users) == 0);
-		LASSERT(ext->oe_state == OES_INV);
-		LASSERT(RB_EMPTY_NODE(&ext->oe_node));
-
-		if (ext->oe_dlmlock) {
-			lu_ref_add(&ext->oe_dlmlock->l_reference,
-				   "osc_extent", ext);
-			LDLM_LOCK_PUT(ext->oe_dlmlock);
-			ext->oe_dlmlock = NULL;
-		}
+	LASSERT(kref_read(&ext->oe_refc) > 0);
+	if (kref_put(&ext->oe_refc, osc_extent_free)) {
+		/* This should be in osc_extent_free(), but
+		 * while we need to pass 'env' it cannot be.
+		 */
 		cl_object_put(env, osc2cl(ext->oe_obj));
-		osc_extent_free(ext);
+
+		kmem_cache_free(osc_extent_kmem, ext);
 	}
 }
 
@@ -410,9 +423,9 @@ static void osc_extent_put(const struct lu_env *env, struct osc_extent *ext)
  */
 static void osc_extent_put_trust(struct osc_extent *ext)
 {
-	LASSERT(atomic_read(&ext->oe_refc) > 1);
+	LASSERT(kref_read(&ext->oe_refc) > 1);
 	assert_osc_object_is_locked(ext->oe_obj);
-	atomic_dec(&ext->oe_refc);
+	osc_extent_put(NULL, ext);
 }
 
 /**
@@ -505,7 +518,7 @@ static struct osc_extent *osc_extent_hold(struct osc_extent *ext)
 		osc_extent_state_set(ext, OES_ACTIVE);
 		osc_update_pending(obj, OBD_BRW_WRITE, -ext->oe_nr_pages);
 	}
-	atomic_inc(&ext->oe_users);
+	refcount_inc(&ext->oe_users);
 	list_del_init(&ext->oe_link);
 	return osc_extent_get(ext);
 }
@@ -599,11 +612,11 @@ void osc_extent_release(const struct lu_env *env, struct osc_extent *ext)
 	struct osc_object *obj = ext->oe_obj;
 	struct client_obd *cli = osc_cli(obj);
 
-	LASSERT(atomic_read(&ext->oe_users) > 0);
+	LASSERT(refcount_read(&ext->oe_users) > 0);
 	LASSERT(sanity_check(ext) == 0);
 	LASSERT(ext->oe_grants > 0);
 
-	if (atomic_dec_and_lock(&ext->oe_users, &obj->oo_lock)) {
+	if (refcount_dec_and_lock(&ext->oe_users, &obj->oo_lock)) {
 		LASSERT(ext->oe_state == OES_ACTIVE);
 		if (ext->oe_trunc_pending) {
 			/* a truncate process is waiting for this extent.
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index aa1b753fc88d..b1a1d241cc6c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -579,9 +579,9 @@ struct osc_extent {
 	/* osc_object of this extent */
 	struct osc_object	*oe_obj;
 	/* refcount, removed from red-black tree if reaches zero. */
-	atomic_t		oe_refc;
+	struct kref		oe_refc;
 	/* busy if non-zero */
-	atomic_t		oe_users;
+	refcount_t		oe_users;
 	/* link list of osc_object's oo_{hp|urgent|locking}_exts. */
 	struct list_head	oe_link;
 	/* state of this extent */
