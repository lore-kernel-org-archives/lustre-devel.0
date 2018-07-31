From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:07 -0400
Subject: [lustre-devel] [PATCH 15/31] lustre: clio: remove unused members
 from struct cl_thread_info
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Dmitry Eremin <dmitry.eremin@intel.com>

The pointer to the topmost ongoing IO in the thread and
other members are not used any more.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
WC-id: https://jira.whamcloud.com/browse/LU-8888
Reviewed-on: https://review.whamcloud.com/24062
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |  1 -
 .../staging/lustre/lustre/obdclass/cl_internal.h   | 45 +---------------------
 drivers/staging/lustre/lustre/obdclass/cl_io.c     | 21 +---------
 drivers/staging/lustre/lustre/obdclass/cl_object.c | 16 +-------
 4 files changed, 4 insertions(+), 79 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 58af22e..382bfe8 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2291,7 +2291,6 @@ int cl_io_commit_async(const struct lu_env *env, struct cl_io *io,
 		       cl_commit_cbt cb);
 int cl_io_read_ahead(const struct lu_env *env, struct cl_io *io,
 		     pgoff_t start, struct cl_read_ahead *ra);
-int cl_io_is_going(const struct lu_env *env);
 
 /**
  * True, iff \a io is an O_APPEND write(2).
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_internal.h b/drivers/staging/lustre/lustre/obdclass/cl_internal.h
index a0db830..8770e32 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_internal.h
+++ b/drivers/staging/lustre/lustre/obdclass/cl_internal.h
@@ -37,57 +37,14 @@
 #ifndef _CL_INTERNAL_H
 #define _CL_INTERNAL_H
 
-#define CLT_PVEC_SIZE (14)
-
-/**
- * Possible levels of the nesting. Currently this is 2: there are "top"
- * entities (files, extent locks), and "sub" entities (stripes and stripe
- * locks). This is used only for debugging counters right now.
- */
-enum clt_nesting_level {
-	CNL_TOP,
-	CNL_SUB,
-	CNL_NR
-};
-
 /**
  * Thread local state internal for generic cl-code.
  */
 struct cl_thread_info {
-	/*
-	 * Common fields.
-	 */
-	struct cl_io	 clt_io;
-	struct cl_2queue     clt_queue;
-
-	/*
-	 * Fields used by cl_lock.c
-	 */
-	struct cl_lock_descr clt_descr;
-	struct cl_page_list  clt_list;
-	/** @} debugging */
-
-	/*
-	 * Fields used by cl_page.c
-	 */
-	struct cl_page      *clt_pvec[CLT_PVEC_SIZE];
-
-	/*
-	 * Fields used by cl_io.c
-	 */
 	/**
-	 * Pointer to the topmost ongoing IO in this thread.
-	 */
-	struct cl_io	*clt_current_io;
-	/**
-	 * Used for submitting a sync io.
+	 * Used for submitting a sync I/O.
 	 */
 	struct cl_sync_io    clt_anchor;
-	/**
-	 * Fields used by cl_lock_discard_pages().
-	 */
-	pgoff_t	      clt_next_index;
-	pgoff_t	      clt_fn_index; /* first non-overlapped index */
 };
 
 struct cl_thread_info *cl_env_info(const struct lu_env *env);
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 2c77e72..3a96d4a 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -68,14 +68,6 @@ static inline int cl_io_is_loopable(const struct cl_io *io)
 }
 
 /**
- * Returns true iff there is an IO ongoing in the given environment.
- */
-int cl_io_is_going(const struct lu_env *env)
-{
-	return cl_env_info(env)->clt_current_io != NULL;
-}
-
-/**
  * cl_io invariant that holds at all times when exported cl_io_*() functions
  * are entered and left.
  */
@@ -100,7 +92,6 @@ static int cl_io_invariant(const struct cl_io *io)
 void cl_io_fini(const struct lu_env *env, struct cl_io *io)
 {
 	struct cl_io_slice    *slice;
-	struct cl_thread_info *info;
 
 	LINVRNT(cl_io_type_is_valid(io->ci_type));
 	LINVRNT(cl_io_invariant(io));
@@ -119,9 +110,6 @@ void cl_io_fini(const struct lu_env *env, struct cl_io *io)
 		slice->cis_io = NULL;
 	}
 	io->ci_state = CIS_FINI;
-	info = cl_env_info(env);
-	if (info->clt_current_io == io)
-		info->clt_current_io = NULL;
 
 	/* sanity check for layout change */
 	switch (io->ci_type) {
@@ -184,11 +172,8 @@ static int cl_io_init0(const struct lu_env *env, struct cl_io *io,
 int cl_io_sub_init(const struct lu_env *env, struct cl_io *io,
 		   enum cl_io_type iot, struct cl_object *obj)
 {
-	struct cl_thread_info *info = cl_env_info(env);
-
 	LASSERT(obj != cl_object_top(obj));
-	if (!info->clt_current_io)
-		info->clt_current_io = io;
+
 	return cl_io_init0(env, io, iot, obj);
 }
 EXPORT_SYMBOL(cl_io_sub_init);
@@ -206,12 +191,8 @@ int cl_io_sub_init(const struct lu_env *env, struct cl_io *io,
 int cl_io_init(const struct lu_env *env, struct cl_io *io,
 	       enum cl_io_type iot, struct cl_object *obj)
 {
-	struct cl_thread_info *info = cl_env_info(env);
-
 	LASSERT(obj == cl_object_top(obj));
-	LASSERT(!info->clt_current_io);
 
-	info->clt_current_io = io;
 	return cl_io_init0(env, io, iot, obj);
 }
 EXPORT_SYMBOL(cl_io_init);
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 42cce2d..d1d7bec 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -973,20 +973,8 @@ struct cl_thread_info *cl_env_info(const struct lu_env *env)
 	return lu_context_key_get(&env->le_ctx, &cl_key);
 }
 
-/* defines cl0_key_{init,fini}() */
-LU_KEY_INIT_FINI(cl0, struct cl_thread_info);
-
-static void *cl_key_init(const struct lu_context *ctx,
-			 struct lu_context_key *key)
-{
-	return cl0_key_init(ctx, key);
-}
-
-static void cl_key_fini(const struct lu_context *ctx,
-			struct lu_context_key *key, void *data)
-{
-	cl0_key_fini(ctx, key, data);
-}
+/* defines cl_key_{init,fini}() */
+LU_KEY_INIT_FINI(cl, struct cl_thread_info);
 
 static struct lu_context_key cl_key = {
 	.lct_tags = LCT_CL_THREAD,
-- 
1.8.3.1
