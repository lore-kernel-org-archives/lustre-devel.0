From: Tobin C Harding <me@tobin.cc>
Date: Mon, 23 May 2016 20:17:46 +1000
Subject: [lustre-devel] [PATCH] staging: lustre: set function scope with
	static
Message-ID: <1463998666-4636-1-git-send-email-me@tobin.cc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

A number of function definitions were found to be candidates for
static scoping. This patch adds static to these functions.

Signed-off-by: Tobin C Harding <me@tobin.cc>
---
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |  8 ++++----
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  6 +++---
 drivers/staging/lustre/lustre/llite/vvp_req.c      | 12 ++++++------
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |  2 +-
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 47101de..c63def9 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -150,8 +150,8 @@ struct lu_context_key vvp_session_key = {
 	.lct_fini = vvp_session_key_fini
 };
 
-void *vvp_thread_key_init(const struct lu_context *ctx,
-			  struct lu_context_key *key)
+static void *vvp_thread_key_init(const struct lu_context *ctx,
+				 struct lu_context_key *key)
 {
 	struct vvp_thread_info *vti;
 
@@ -161,8 +161,8 @@ void *vvp_thread_key_init(const struct lu_context *ctx,
 	return vti;
 }
 
-void vvp_thread_key_fini(const struct lu_context *ctx,
-			 struct lu_context_key *key, void *data)
+static void vvp_thread_key_fini(const struct lu_context *ctx,
+				struct lu_context_key *key, void *data)
 {
 	struct vvp_thread_info *vti = data;
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 5bf9592..e26e0f8 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -47,8 +47,8 @@
 #include "llite_internal.h"
 #include "vvp_internal.h"
 
-struct vvp_io *cl2vvp_io(const struct lu_env *env,
-			 const struct cl_io_slice *slice)
+static struct vvp_io *cl2vvp_io(const struct lu_env *env,
+				const struct cl_io_slice *slice)
 {
 	struct vvp_io *vio;
 
@@ -1259,7 +1259,7 @@ static int vvp_io_read_page(const struct lu_env *env,
 	return 0;
 }
 
-void vvp_io_end(const struct lu_env *env, const struct cl_io_slice *ios)
+static void vvp_io_end(const struct lu_env *env, const struct cl_io_slice *ios)
 {
 	CLOBINVRNT(env, ios->cis_io->ci_obj,
 		   vvp_object_invariant(ios->cis_io->ci_obj));
diff --git a/drivers/staging/lustre/lustre/llite/vvp_req.c b/drivers/staging/lustre/lustre/llite/vvp_req.c
index fb88629..9fe9d6c 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_req.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_req.c
@@ -60,10 +60,10 @@ static inline struct vvp_req *cl2vvp_req(const struct cl_req_slice *slice)
  *    - o_ioepoch,
  *
  */
-void vvp_req_attr_set(const struct lu_env *env,
-		      const struct cl_req_slice *slice,
-		      const struct cl_object *obj,
-		      struct cl_req_attr *attr, u64 flags)
+static void vvp_req_attr_set(const struct lu_env *env,
+			     const struct cl_req_slice *slice,
+			     const struct cl_object *obj,
+			     struct cl_req_attr *attr, u64 flags)
 {
 	struct inode *inode;
 	struct obdo  *oa;
@@ -87,8 +87,8 @@ void vvp_req_attr_set(const struct lu_env *env,
 	       JOBSTATS_JOBID_SIZE);
 }
 
-void vvp_req_completion(const struct lu_env *env,
-			const struct cl_req_slice *slice, int ioret)
+static void vvp_req_completion(const struct lu_env *env,
+			       const struct cl_req_slice *slice, int ioret)
 {
 	struct vvp_req *vrq;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index e0c90ad..bc4e1e4 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -192,7 +192,7 @@ static int lustre_start_simple(char *obdname, char *type, char *uuid,
 	return rc;
 }
 
-DEFINE_MUTEX(mgc_start_lock);
+static DEFINE_MUTEX(mgc_start_lock);
 
 /** Set up a mgc obd to process startup logs
  *
-- 
2.8.2
