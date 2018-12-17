From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:29:41 -0500
Subject: [lustre-devel] [PATCH 07/28] lustre: lov: embedded raid0 in struct
 lov_layout_composite
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

Create bare bones struct lov_layout_composite that
Make client layer support composite layout.

Plain layout will be stored in LOV layer as a composite layout
containing a single component.

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24850
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/lov/lov_cl_internal.h    | 78 ++++++++++++----------
 drivers/staging/lustre/lustre/lov/lov_object.c     |  8 +--
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |  8 +--
 3 files changed, 50 insertions(+), 44 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index e4f7621..c6ace49 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -129,6 +129,42 @@ static inline char *llt2str(enum lov_layout_type llt)
 	return "";
 }
 
+struct lov_layout_raid0 {
+	unsigned int		lo_nr;
+	/**
+	 * When this is true, lov_object::lo_attr contains
+	 * valid up to date attributes for a top-level
+	 * object. This field is reset to 0 when attributes of
+	 * any sub-object change.
+	 */
+	int			lo_attr_valid;
+	/**
+	 * Array of sub-objects. Allocated when top-object is
+	 * created (lov_init_raid0()).
+	 *
+	 * Top-object is a strict master of its sub-objects:
+	 * it is created before them, and outlives its
+	 * children (this later is necessary so that basic
+	 * functions like cl_object_top() always
+	 * work). Top-object keeps a reference on every
+	 * sub-object.
+	 *
+	 * When top-object is destroyed (lov_delete_raid0())
+	 * it releases its reference to a sub-object and waits
+	 * until the latter is finally destroyed.
+	 */
+	struct lovsub_object  **lo_sub;
+	/**
+	 * protect lo_sub
+	 */
+	spinlock_t		lo_sub_lock;
+	/**
+	 * Cached object attribute, built from sub-object
+	 * attributes.
+	 */
+	struct cl_attr		lo_attr;
+};
+
 /**
  * lov-specific file state.
  *
@@ -178,45 +214,15 @@ struct lov_object {
 	struct lov_stripe_md  *lo_lsm;
 
 	union lov_layout_state {
-		struct lov_layout_raid0 {
-			unsigned int	       lo_nr;
-			/**
-			 * When this is true, lov_object::lo_attr contains
-			 * valid up to date attributes for a top-level
-			 * object. This field is reset to 0 when attributes of
-			 * any sub-object change.
-			 */
-			int		       lo_attr_valid;
-			/**
-			 * Array of sub-objects. Allocated when top-object is
-			 * created (lov_init_raid0()).
-			 *
-			 * Top-object is a strict master of its sub-objects:
-			 * it is created before them, and outlives its
-			 * children (this later is necessary so that basic
-			 * functions like cl_object_top() always
-			 * work). Top-object keeps a reference on every
-			 * sub-object.
-			 *
-			 * When top-object is destroyed (lov_delete_raid0())
-			 * it releases its reference to a sub-object and waits
-			 * until the latter is finally destroyed.
-			 */
-			struct lovsub_object **lo_sub;
-			/**
-			 * protect lo_sub
-			 */
-			spinlock_t		lo_sub_lock;
-			/**
-			 * Cached object attribute, built from sub-object
-			 * attributes.
-			 */
-			struct cl_attr	 lo_attr;
-		} raid0;
 		struct lov_layout_state_empty {
 		} empty;
 		struct lov_layout_state_released {
 		} released;
+		struct lov_layout_composite {
+			struct lov_layout_entry {
+				struct lov_layout_raid0 lle_raid0;
+			} lo_entries;
+		} composite;
 	} u;
 	/**
 	 * Thread that acquired lov_object::lo_type_guard in an exclusive
@@ -627,7 +633,7 @@ static inline struct lov_layout_raid0 *lov_r0(struct lov_object *lov)
 	LASSERT(lov->lo_type == LLT_RAID0);
 	LASSERT(lov->lo_lsm->lsm_magic == LOV_MAGIC ||
 		lov->lo_lsm->lsm_magic == LOV_MAGIC_V3);
-	return &lov->u.raid0;
+	return &lov->u.composite.lo_entries.lle_raid0;
 }
 
 /* lov_pack.c */
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index ad2901a..15ed378 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -228,7 +228,7 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 	struct lov_thread_info  *lti     = lov_env_info(env);
 	struct cl_object_conf   *subconf = &lti->lti_stripe_conf;
 	struct lu_fid	   *ofid    = &lti->lti_fid;
-	struct lov_layout_raid0 *r0      = &state->raid0;
+	struct lov_layout_raid0 *r0 = &state->composite.lo_entries.lle_raid0;
 
 	if (lsm->lsm_magic != LOV_MAGIC_V1 && lsm->lsm_magic != LOV_MAGIC_V3) {
 		dump_lsm(D_ERROR, lsm);
@@ -375,7 +375,7 @@ static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
 	wait_queue_head_t *wq;
 	wait_queue_entry_t	  *waiter;
 
-	r0  = &lov->u.raid0;
+	r0  = &lov->u.composite.lo_entries.lle_raid0;
 	LASSERT(r0->lo_sub[idx] == los);
 
 	sub  = lovsub2cl(los);
@@ -418,7 +418,7 @@ static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
 static int lov_delete_raid0(const struct lu_env *env, struct lov_object *lov,
 			    union lov_layout_state *state)
 {
-	struct lov_layout_raid0 *r0 = &state->raid0;
+	struct lov_layout_raid0 *r0 = &state->composite.lo_entries.lle_raid0;
 	struct lov_stripe_md    *lsm = lov->lo_lsm;
 	int i;
 
@@ -451,7 +451,7 @@ static void lov_fini_empty(const struct lu_env *env, struct lov_object *lov,
 static void lov_fini_raid0(const struct lu_env *env, struct lov_object *lov,
 			   union lov_layout_state *state)
 {
-	struct lov_layout_raid0 *r0 = &state->raid0;
+	struct lov_layout_raid0 *r0 = &state->composite.lo_entries.lle_raid0;
 
 	if (r0->lo_sub) {
 		kvfree(r0->lo_sub);
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
index 13d4520..7360c16 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_object.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_object.c
@@ -80,10 +80,10 @@ static void lovsub_object_free(const struct lu_env *env, struct lu_object *obj)
 	 */
 	if (lov) {
 		LASSERT(lov->lo_type == LLT_RAID0);
-		LASSERT(lov->u.raid0.lo_sub[los->lso_index] == los);
-		spin_lock(&lov->u.raid0.lo_sub_lock);
-		lov->u.raid0.lo_sub[los->lso_index] = NULL;
-		spin_unlock(&lov->u.raid0.lo_sub_lock);
+		LASSERT(lov->u.composite.lo_entries.lle_raid0.lo_sub[los->lso_index] == los);
+		spin_lock(&lov->u.composite.lo_entries.lle_raid0.lo_sub_lock);
+		lov->u.composite.lo_entries.lle_raid0.lo_sub[los->lso_index] = NULL;
+		spin_unlock(&lov->u.composite.lo_entries.lle_raid0.lo_sub_lock);
 	}
 
 	lu_object_fini(obj);
-- 
1.8.3.1
