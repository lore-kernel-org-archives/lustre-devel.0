From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:00 +1100
Subject: [lustre-devel] [PATCH 01/29] lustre: osc_cache: discard oe_intree
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504072.26726.12597270089564992131.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

An rbnode knows if it is in the tree or not, using RB_EMPTY_NODE().
There is no need for an extra flag.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   15 +++++++--------
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |    3 +--
 2 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 93330cb77e94..fbf16547003d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -74,7 +74,7 @@ static inline char *ext_flags(struct osc_extent *ext, char *flags)
 {
 	char *buf = flags;
 	*buf++ = ext->oe_rw ? 'r' : 'w';
-	if (ext->oe_intree)
+	if (!RB_EMPTY_NODE(&ext->oe_node))
 		*buf++ = 'i';
 	if (ext->oe_sync)
 		*buf++ = 'S';
@@ -154,7 +154,7 @@ static inline struct osc_extent *next_extent(struct osc_extent *ext)
 	if (!ext)
 		return NULL;
 
-	LASSERT(ext->oe_intree);
+	LASSERT(!RB_EMPTY_NODE(&ext->oe_node));
 	return rb_extent(rb_next(&ext->oe_node));
 }
 
@@ -163,7 +163,7 @@ static inline struct osc_extent *prev_extent(struct osc_extent *ext)
 	if (!ext)
 		return NULL;
 
-	LASSERT(ext->oe_intree);
+	LASSERT(!RB_EMPTY_NODE(&ext->oe_node));
 	return rb_extent(rb_prev(&ext->oe_node));
 }
 
@@ -393,7 +393,7 @@ static void osc_extent_put(const struct lu_env *env, struct osc_extent *ext)
 		LASSERT(list_empty(&ext->oe_link));
 		LASSERT(atomic_read(&ext->oe_users) == 0);
 		LASSERT(ext->oe_state == OES_INV);
-		LASSERT(!ext->oe_intree);
+		LASSERT(RB_EMPTY_NODE(&ext->oe_node));
 
 		if (ext->oe_dlmlock) {
 			lu_ref_add(&ext->oe_dlmlock->l_reference,
@@ -465,7 +465,7 @@ static void osc_extent_insert(struct osc_object *obj, struct osc_extent *ext)
 	struct rb_node *parent = NULL;
 	struct osc_extent *tmp;
 
-	LASSERT(ext->oe_intree == 0);
+	LASSERT(RB_EMPTY_NODE(&ext->oe_node));
 	LASSERT(ext->oe_obj == obj);
 	LASSERT(osc_object_is_locked(obj));
 	while (*n) {
@@ -482,7 +482,6 @@ static void osc_extent_insert(struct osc_object *obj, struct osc_extent *ext)
 	rb_link_node(&ext->oe_node, parent, n);
 	rb_insert_color(&ext->oe_node, &obj->oo_root);
 	osc_extent_get(ext);
-	ext->oe_intree = 1;
 }
 
 /* caller must have held object lock. */
@@ -491,9 +490,9 @@ static void osc_extent_erase(struct osc_extent *ext)
 	struct osc_object *obj = ext->oe_obj;
 
 	LASSERT(osc_object_is_locked(obj));
-	if (ext->oe_intree) {
+	if (!RB_EMPTY_NODE(&ext->oe_node)) {
 		rb_erase(&ext->oe_node, &obj->oo_root);
-		ext->oe_intree = 0;
+		RB_CLEAR_NODE(&ext->oe_node);
 		/* rbtree held a refcount */
 		osc_extent_put_trust(ext);
 	}
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 077a2b183634..b78deef3963a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -598,9 +598,8 @@ struct osc_extent {
 	/* state of this extent */
 	enum osc_extent_state	oe_state;
 	/* flags for this extent. */
-	unsigned int		oe_intree:1,
 	/* 0 is write, 1 is read */
-				oe_rw:1,
+	unsigned int		oe_rw:1,
 	/* sync extent, queued by osc_queue_sync_pages() */
 				oe_sync:1,
 	/* set if this extent has partial, sync pages.
