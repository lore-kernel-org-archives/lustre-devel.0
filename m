From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:46 -0400
Subject: [lustre-devel] [PATCH 07/42] lustre: lov: make various lov_object.c
 function static.
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

These function in lov_object.c and lovsub_object.c are only
used in the file in which they are defined.
So mark them as static.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 52f04bb11195d ("LU-6142 lov: make various lov_object.c function static.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39385
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_cl_internal.h | 12 ------------
 fs/lustre/lov/lov_object.c      | 19 ++++++++++---------
 fs/lustre/lov/lovsub_object.c   |  4 ++--
 3 files changed, 12 insertions(+), 23 deletions(-)

diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 6796d88..7128224 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -599,15 +599,6 @@ struct lov_session {
 
 extern struct kmem_cache *lovsub_object_kmem;
 
-int lov_object_init(const struct lu_env *env, struct lu_object *obj,
-		    const struct lu_object_conf *conf);
-int lovsub_object_init(const struct lu_env *env, struct lu_object *obj,
-		       const struct lu_object_conf *conf);
-int lov_lock_init(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_lock *lock, const struct cl_io *io);
-int lov_io_init(const struct lu_env *env, struct cl_object *obj,
-		struct cl_io *io);
-
 int lov_lock_init_composite(const struct lu_env *env, struct cl_object *obj,
 			    struct cl_lock *lock, const struct cl_io *io);
 int lov_lock_init_empty(const struct lu_env *env, struct cl_object *obj,
@@ -622,8 +613,6 @@ int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
 struct lov_io_sub *lov_sub_get(const struct lu_env *env, struct lov_io *lio,
 			       int stripe);
 
-int lov_page_init(const struct lu_env *env, struct cl_object *ob,
-		  struct cl_page *page, pgoff_t index);
 int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
 			struct cl_page *page, pgoff_t index);
 int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
@@ -638,7 +627,6 @@ struct lu_object *lovsub_object_alloc(const struct lu_env *env,
 				      const struct lu_object_header *hdr,
 				      struct lu_device *dev);
 
-struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov);
 bool lov_page_is_empty(const struct cl_page *page);
 int lov_lsm_entry(const struct lov_stripe_md *lsm, u64 offset);
 int lov_io_layout_at(struct lov_io *lio, u64 offset);
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 6f8f066..7285276 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -80,6 +80,7 @@ struct lov_layout_operations {
 };
 
 static int lov_layout_wait(const struct lu_env *env, struct lov_object *lov);
+static struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov);
 
 static void lov_lsm_put(struct lov_stripe_md *lsm)
 {
@@ -1277,8 +1278,8 @@ static int lov_layout_change(const struct lu_env *unused,
  * Lov object operations.
  *
  */
-int lov_object_init(const struct lu_env *env, struct lu_object *obj,
-		    const struct lu_object_conf *conf)
+static int lov_object_init(const struct lu_env *env, struct lu_object *obj,
+			   const struct lu_object_conf *conf)
 {
 	struct lov_object *lov = lu2lov(obj);
 	struct lov_device *dev = lov_object_dev(lov);
@@ -1402,8 +1403,8 @@ static int lov_object_print(const struct lu_env *env, void *cookie,
 	return LOV_2DISPATCH_NOLOCK(lu2lov(o), llo_print, env, cookie, p, o);
 }
 
-int lov_page_init(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_page *page, pgoff_t index)
+static int lov_page_init(const struct lu_env *env, struct cl_object *obj,
+			 struct cl_page *page, pgoff_t index)
 {
 	return LOV_2DISPATCH_NOLOCK(cl2lov(obj), llo_page_init, env, obj, page,
 				    index);
@@ -1413,8 +1414,8 @@ int lov_page_init(const struct lu_env *env, struct cl_object *obj,
  * Implements cl_object_operations::clo_io_init() method for lov
  * layer. Dispatches to the appropriate layout io initialization method.
  */
-int lov_io_init(const struct lu_env *env, struct cl_object *obj,
-		struct cl_io *io)
+static int lov_io_init(const struct lu_env *env, struct cl_object *obj,
+		       struct cl_io *io)
 {
 	CL_IO_SLICE_CLEAN(lov_env_io(env), lis_preserved);
 
@@ -1455,8 +1456,8 @@ static int lov_attr_update(const struct lu_env *env, struct cl_object *obj,
 	return 0;
 }
 
-int lov_lock_init(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_lock *lock, const struct cl_io *io)
+static int lov_lock_init(const struct lu_env *env, struct cl_object *obj,
+			 struct cl_lock *lock, const struct cl_io *io)
 {
 	/* No need to lock because we've taken one refcount of layout.  */
 	return LOV_2DISPATCH_NOLOCK(cl2lov(obj), llo_lock_init, env, obj, lock,
@@ -2157,7 +2158,7 @@ struct lu_object *lov_object_alloc(const struct lu_env *env,
 	return obj;
 }
 
-struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov)
+static struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov)
 {
 	struct lov_stripe_md *lsm = NULL;
 
diff --git a/fs/lustre/lov/lovsub_object.c b/fs/lustre/lov/lovsub_object.c
index 046f5e8..eef1713 100644
--- a/fs/lustre/lov/lovsub_object.c
+++ b/fs/lustre/lov/lovsub_object.c
@@ -49,8 +49,8 @@
  *
  */
 
-int lovsub_object_init(const struct lu_env *env, struct lu_object *obj,
-		       const struct lu_object_conf *conf)
+static int lovsub_object_init(const struct lu_env *env, struct lu_object *obj,
+			      const struct lu_object_conf *conf)
 {
 	struct lovsub_device *dev = lu2lovsub_dev(obj->lo_dev);
 	struct lu_object *below;
-- 
1.8.3.1
