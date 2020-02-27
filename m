From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:07:57 -0500
Subject: [lustre-devel] [PATCH 009/622] lustre: llite: reorganize variable
 and data structures
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

This patch covers the bits missed in the patch series
"Lustre IO stack simplifications and cleanups" from the OpenSFS
branch for the LU-5971 work. Details of the original push can
be viewed at https://lore.kernel.org/patchwork/cover/662900.
No Fixed is provided since the staging patch series was broken
up into a much larger patch set.

WC-bug-id: https://jira.whamcloud.com/browse/LU-5971
Lustre-commit: 6eda93c7b5f6 ("LU-5971 llite: reorganize variable and data structures")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: http://review.whamcloud.com/13714
Reviewed-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c           |  1 +
 fs/lustre/llite/glimpse.c        |  1 +
 fs/lustre/llite/lcommon_cl.c     |  5 ++---
 fs/lustre/llite/lcommon_misc.c   | 24 ++++++++++++------------
 fs/lustre/llite/llite_internal.h |  8 ++++----
 fs/lustre/llite/llite_lib.c      |  4 ++--
 fs/lustre/llite/super25.c        |  1 +
 fs/lustre/llite/vvp_dev.c        |  1 +
 fs/lustre/llite/vvp_internal.h   | 13 +++----------
 fs/lustre/llite/vvp_io.c         |  4 ++--
 10 files changed, 29 insertions(+), 33 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index fe4340d..fe965b1 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -49,6 +49,7 @@
 
 #include <cl_object.h>
 #include "llite_internal.h"
+#include "vvp_internal.h"
 
 struct split_param {
 	struct inode	*sp_inode;
diff --git a/fs/lustre/llite/glimpse.c b/fs/lustre/llite/glimpse.c
index de1a31f..3441904 100644
--- a/fs/lustre/llite/glimpse.c
+++ b/fs/lustre/llite/glimpse.c
@@ -47,6 +47,7 @@
 
 #include <cl_object.h>
 #include "llite_internal.h"
+#include "vvp_internal.h"
 
 static const struct cl_lock_descr whole_file = {
 	.cld_start = 0,
diff --git a/fs/lustre/llite/lcommon_cl.c b/fs/lustre/llite/lcommon_cl.c
index 988855b..978e05b 100644
--- a/fs/lustre/llite/lcommon_cl.c
+++ b/fs/lustre/llite/lcommon_cl.c
@@ -30,8 +30,6 @@
  * This file is part of Lustre, http://www.lustre.org/
  * Lustre is a trademark of Sun Microsystems, Inc.
  *
- * cl code used by vvp (and other Lustre clients in the future).
- *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
  */
 
@@ -63,6 +61,7 @@
  * Vvp device and device type functions.
  *
  */
+#include "vvp_internal.h"
 
 /**
  * An `emergency' environment used by cl_inode_fini() when cl_env_get()
@@ -282,7 +281,7 @@ u64 cl_fid_build_ino(const struct lu_fid *fid, bool api32)
 		return fid_flatten(fid);
 }
 
-/**
+/*
  * build inode generation from passed @fid.  If our FID overflows the 32-bit
  * inode number then return a non-zero generation to distinguish them.
  */
diff --git a/fs/lustre/llite/lcommon_misc.c b/fs/lustre/llite/lcommon_misc.c
index 29daf5b..48503d6 100644
--- a/fs/lustre/llite/lcommon_misc.c
+++ b/fs/lustre/llite/lcommon_misc.c
@@ -46,7 +46,7 @@
  * maximum-sized (= maximum striped) EA and cookie without having to
  * calculate this (via a call into the LOV + OSCs) each time we make an RPC.
  */
-int cl_init_ea_size(struct obd_export *md_exp, struct obd_export *dt_exp)
+static int cl_init_ea_size(struct obd_export *md_exp, struct obd_export *dt_exp)
 {
 	u32 val_size, max_easize, def_easize;
 	int rc;
@@ -115,7 +115,7 @@ int cl_ocd_update(struct obd_device *host, struct obd_device *watched,
 #define GROUPLOCK_SCOPE "grouplock"
 
 int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
-		     struct ll_grouplock *cg)
+		     struct ll_grouplock *lg)
 {
 	struct lu_env	  *env;
 	struct cl_io	   *io;
@@ -160,22 +160,22 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 		return rc;
 	}
 
-	cg->lg_env  = env;
-	cg->lg_io   = io;
-	cg->lg_lock = lock;
-	cg->lg_gid  = gid;
+	lg->lg_env = env;
+	lg->lg_io = io;
+	lg->lg_lock = lock;
+	lg->lg_gid = gid;
 
 	return 0;
 }
 
-void cl_put_grouplock(struct ll_grouplock *cg)
+void cl_put_grouplock(struct ll_grouplock *lg)
 {
-	struct lu_env  *env  = cg->lg_env;
-	struct cl_io   *io   = cg->lg_io;
-	struct cl_lock *lock = cg->lg_lock;
+	struct lu_env *env  = lg->lg_env;
+	struct cl_io *io   = lg->lg_io;
+	struct cl_lock *lock = lg->lg_lock;
 
-	LASSERT(cg->lg_env);
-	LASSERT(cg->lg_gid);
+	LASSERT(lg->lg_env);
+	LASSERT(lg->lg_gid);
 
 	cl_lock_release(env, lock);
 	cl_io_fini(env, io);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 3192340..fbe93a4 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -707,7 +707,6 @@ static inline bool ll_sbi_has_tiny_write(struct ll_sb_info *sbi)
 void ll_ras_enter(struct file *f);
 
 /* llite/lcommon_misc.c */
-int cl_init_ea_size(struct obd_export *md_exp, struct obd_export *dt_exp);
 int cl_ocd_update(struct obd_device *host, struct obd_device *watched,
 		  enum obd_notify_event ev, void *owner);
 int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
@@ -975,9 +974,9 @@ struct ll_cl_context {
 
 struct ll_thread_info {
 	struct iov_iter		lti_iter;
-	struct vvp_io_args   lti_args;
-	struct ra_io_arg     lti_ria;
-	struct ll_cl_context lti_io_ctx;
+	struct vvp_io_args	lti_args;
+	struct ra_io_arg	lti_ria;
+	struct ll_cl_context	lti_io_ctx;
 };
 
 extern struct lu_context_key ll_thread_key;
@@ -1165,6 +1164,7 @@ struct ll_statahead_info {
 blkcnt_t dirty_cnt(struct inode *inode);
 
 int __cl_glimpse_size(struct inode *inode, int agl);
+
 int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 		    struct inode *inode, struct cl_object *clob, int agl);
 
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index e1932ae..aaa8ad2 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2542,7 +2542,7 @@ void ll_dirty_page_discard_warn(struct page *page, int ioret)
 {
 	char *buf, *path = NULL;
 	struct dentry *dentry = NULL;
-	struct vvp_object *obj = cl_inode2vvp(page->mapping->host);
+	struct inode *inode = page->mapping->host;
 
 	/* this can be called inside spin lock so use GFP_ATOMIC. */
 	buf = (char *)__get_free_page(GFP_ATOMIC);
@@ -2556,7 +2556,7 @@ void ll_dirty_page_discard_warn(struct page *page, int ioret)
 	       "%s: dirty page discard: %s/fid: " DFID "/%s may get corrupted (rc %d)\n",
 	       ll_get_fsname(page->mapping->host->i_sb, NULL, 0),
 	       s2lsi(page->mapping->host->i_sb)->lsi_lmd->lmd_dev,
-	       PFID(&obj->vob_header.coh_lu.loh_fid),
+	       PFID(ll_inode2fid(inode)),
 	       (path && !IS_ERR(path)) ? path : "", ioret);
 
 	if (dentry)
diff --git a/fs/lustre/llite/super25.c b/fs/lustre/llite/super25.c
index 2b65e2f..133fe2a 100644
--- a/fs/lustre/llite/super25.c
+++ b/fs/lustre/llite/super25.c
@@ -42,6 +42,7 @@
 #include <linux/fs.h>
 #include <lprocfs_status.h>
 #include "llite_internal.h"
+#include "vvp_internal.h"
 
 static struct kmem_cache *ll_inode_cachep;
 
diff --git a/fs/lustre/llite/vvp_dev.c b/fs/lustre/llite/vvp_dev.c
index 9f793e9..e1d87f9 100644
--- a/fs/lustre/llite/vvp_dev.c
+++ b/fs/lustre/llite/vvp_dev.c
@@ -93,6 +93,7 @@ static void *ll_thread_key_init(const struct lu_context *ctx,
 	info = kmem_cache_zalloc(ll_thread_kmem, GFP_NOFS);
 	if (!info)
 		info = ERR_PTR(-ENOMEM);
+
 	return info;
 }
 
diff --git a/fs/lustre/llite/vvp_internal.h b/fs/lustre/llite/vvp_internal.h
index 96f10d2..7a463cb 100644
--- a/fs/lustre/llite/vvp_internal.h
+++ b/fs/lustre/llite/vvp_internal.h
@@ -166,7 +166,7 @@ static inline struct cl_io *vvp_env_thread_io(const struct lu_env *env)
 }
 
 struct vvp_session {
-	struct vvp_io	cs_ios;
+	struct vvp_io	vs_ios;
 };
 
 static inline struct vvp_session *vvp_env_session(const struct lu_env *env)
@@ -181,11 +181,11 @@ static inline struct vvp_session *vvp_env_session(const struct lu_env *env)
 
 static inline struct vvp_io *vvp_env_io(const struct lu_env *env)
 {
-	return &vvp_env_session(env)->cs_ios;
+	return &vvp_env_session(env)->vs_ios;
 }
 
 /**
- * ccc-private object state.
+ * VPP-private object state.
  */
 struct vvp_object {
 	struct cl_object_header vob_header;
@@ -246,13 +246,6 @@ struct vvp_device {
 	struct cl_device	*vdv_next;
 };
 
-void *ccc_key_init(const struct lu_context *ctx,
-		   struct lu_context_key *key);
-void ccc_key_fini(const struct lu_context *ctx,
-		  struct lu_context_key *key, void *data);
-
-void ccc_umount(const struct lu_env *env, struct cl_device *dev);
-
 static inline struct lu_device *vvp2lu_dev(struct vvp_device *vdv)
 {
 	return &vdv->vdv_cl.cd_lu_dev;
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 6145064..37bf942 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -416,10 +416,10 @@ static enum cl_lock_mode vvp_mode_from_vma(struct vm_area_struct *vma)
 static int vvp_mmap_locks(const struct lu_env *env,
 			  struct vvp_io *vio, struct cl_io *io)
 {
-	struct vvp_thread_info *cti = vvp_env_info(env);
+	struct vvp_thread_info *vti = vvp_env_info(env);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct  *vma;
-	struct cl_lock_descr *descr = &cti->vti_descr;
+	struct cl_lock_descr *descr = &vti->vti_descr;
 	union ldlm_policy_data policy;
 	unsigned long addr;
 	ssize_t	count;
-- 
1.8.3.1
