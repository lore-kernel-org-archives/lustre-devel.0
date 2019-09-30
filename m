From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:48 -0400
Subject: [lustre-devel] [PATCH 089/151] lustre: clio: remove unused cl_lock
 layers
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-90-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

Remove the struct vvp_lock and struct lovsub_lock, omitting these
layers from cl_lock. Adjust cl_lock_enqueue() to allow for empty locks
(corresponding to unstriped files).

WC-bug-id: https://jira.whamcloud.com/browse/LU-10257
Lustre-commit: f168371f40e1 (LU-10257 clio: remove unused cl_lock layers")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30192
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h   | 14 +++----
 fs/lustre/llite/Makefile        |  2 +-
 fs/lustre/llite/vvp_dev.c       |  6 ---
 fs/lustre/llite/vvp_internal.h  | 12 ------
 fs/lustre/llite/vvp_lock.c      | 87 -----------------------------------------
 fs/lustre/llite/vvp_object.c    |  1 -
 fs/lustre/lov/Makefile          |  2 +-
 fs/lustre/lov/lov_cl_internal.h | 27 -------------
 fs/lustre/lov/lov_dev.c         |  6 ---
 fs/lustre/lov/lovsub_lock.c     | 81 --------------------------------------
 fs/lustre/lov/lovsub_object.c   |  4 +-
 fs/lustre/obdclass/cl_lock.c    |  7 +++-
 12 files changed, 13 insertions(+), 236 deletions(-)
 delete mode 100644 fs/lustre/llite/vvp_lock.c
 delete mode 100644 fs/lustre/lov/lovsub_lock.c

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 99534f5..946e6e1 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1058,15 +1058,13 @@ static inline bool __page_in_use(const struct cl_page *page, int refc)
  * (struct cl_lock) and a list of layers (struct cl_lock_slice), linked to
  * cl_lock::cll_layers list through cl_lock_slice::cls_linkage.
  *
- * Typical cl_lock consists of the two layers:
+ * Typical cl_lock consists of one layer:
  *
- *     - vvp_lock (vvp specific data), and
  *     - lov_lock (lov specific data).
  *
  * lov_lock contains an array of sub-locks. Each of these sub-locks is a
  * normal cl_lock: it has a header (struct cl_lock) and a list of layers:
  *
- *     - lovsub_lock, and
  *     - osc_lock
  *
  * Each sub-lock is associated with a cl_object (representing stripe
@@ -1183,7 +1181,7 @@ struct cl_lock {
 /**
  * Per-layer part of cl_lock
  *
- * \see vvp_lock, lov_lock, lovsub_lock, osc_lock
+ * \see lov_lock, osc_lock
  */
 struct cl_lock_slice {
 	struct cl_lock			*cls_lock;
@@ -1198,7 +1196,7 @@ struct cl_lock_slice {
 
 /**
  *
- * \see vvp_lock_ops, lov_lock_ops, lovsub_lock_ops, osc_lock_ops
+ * \see lov_lock_ops, osc_lock_ops
  */
 struct cl_lock_operations {
 	/** @{ */
@@ -1210,8 +1208,7 @@ struct cl_lock_operations {
 	 *		wait on @anchor for resources
 	 *		-ve for failure
 	 *
-	 * \see vvp_lock_enqueue(), lov_lock_enqueue(), lovsub_lock_enqueue(),
-	 * \see osc_lock_enqueue()
+	 * \see lov_lock_enqueue(), osc_lock_enqueue()
 	 */
 	int  (*clo_enqueue)(const struct lu_env *env,
 			    const struct cl_lock_slice *slice,
@@ -1226,8 +1223,7 @@ struct cl_lock_operations {
 	/**
 	 * Destructor. Frees resources and the slice.
 	 *
-	 * \see vvp_lock_fini(), lov_lock_fini(), lovsub_lock_fini(),
-	 * \see osc_lock_fini()
+	 * \see lov_lock_fini(), osc_lock_fini()
 	 */
 	void (*clo_fini)(const struct lu_env *env, struct cl_lock_slice *slice);
 	/**
diff --git a/fs/lustre/llite/Makefile b/fs/lustre/llite/Makefile
index 06e9c05..6d8a33b 100644
--- a/fs/lustre/llite/Makefile
+++ b/fs/lustre/llite/Makefile
@@ -6,7 +6,7 @@ lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
 	    rw.o rw26.o namei.o symlink.o llite_mmap.o range_lock.o \
 	    xattr.o xattr_cache.o xattr_security.o \
 	    super25.o statahead.o glimpse.o lcommon_cl.o lcommon_misc.o \
-	    vvp_dev.o vvp_page.o vvp_lock.o vvp_io.o vvp_object.o \
+	    vvp_dev.o vvp_page.o vvp_io.o vvp_object.o \
 	    lproc_llite.o
 
 lustre-$(CONFIG_FS_POSIX_ACL) += acl.o
diff --git a/fs/lustre/llite/vvp_dev.c b/fs/lustre/llite/vvp_dev.c
index 4c5a29d..9f793e9 100644
--- a/fs/lustre/llite/vvp_dev.c
+++ b/fs/lustre/llite/vvp_dev.c
@@ -55,7 +55,6 @@
  */
 
 static struct kmem_cache *ll_thread_kmem;
-struct kmem_cache *vvp_lock_kmem;
 struct kmem_cache *vvp_object_kmem;
 static struct kmem_cache *vvp_session_kmem;
 static struct kmem_cache *vvp_thread_kmem;
@@ -67,11 +66,6 @@
 		.ckd_size  = sizeof(struct ll_thread_info),
 	},
 	{
-		.ckd_cache = &vvp_lock_kmem,
-		.ckd_name  = "vvp_lock_kmem",
-		.ckd_size  = sizeof(struct vvp_lock),
-	},
-	{
 		.ckd_cache = &vvp_object_kmem,
 		.ckd_name  = "vvp_object_kmem",
 		.ckd_size  = sizeof(struct vvp_object),
diff --git a/fs/lustre/llite/vvp_internal.h b/fs/lustre/llite/vvp_internal.h
index f9a4552..923f866 100644
--- a/fs/lustre/llite/vvp_internal.h
+++ b/fs/lustre/llite/vvp_internal.h
@@ -119,7 +119,6 @@ struct vvp_io {
 extern struct lu_context_key vvp_session_key;
 extern struct lu_context_key vvp_thread_key;
 
-extern struct kmem_cache *vvp_lock_kmem;
 extern struct kmem_cache *vvp_object_kmem;
 
 struct vvp_thread_info {
@@ -247,10 +246,6 @@ struct vvp_device {
 	struct cl_device	*vdv_next;
 };
 
-struct vvp_lock {
-	struct cl_lock_slice	vlk_cl;
-};
-
 void *ccc_key_init(const struct lu_context *ctx,
 		   struct lu_context_key *key);
 void ccc_key_fini(const struct lu_context *ctx,
@@ -296,19 +291,12 @@ static inline struct page *cl2vm_page(const struct cl_page_slice *slice)
 	return cl2vvp_page(slice)->vpg_page;
 }
 
-static inline struct vvp_lock *cl2vvp_lock(const struct cl_lock_slice *slice)
-{
-	return container_of(slice, struct vvp_lock, vlk_cl);
-}
-
 # define CLOBINVRNT(env, clob, expr)					\
 	((void)sizeof(env), (void)sizeof(clob), (void)sizeof(!!(expr)))
 
 int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 		struct cl_io *io);
 int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io);
-int vvp_lock_init(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_lock *lock, const struct cl_io *io);
 int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_page *page, pgoff_t index);
 struct lu_object *vvp_object_alloc(const struct lu_env *env,
diff --git a/fs/lustre/llite/vvp_lock.c b/fs/lustre/llite/vvp_lock.c
deleted file mode 100644
index 4b6c714..0000000
--- a/fs/lustre/llite/vvp_lock.c
+++ /dev/null
@@ -1,87 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2014, 2015, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * Implementation of cl_lock for VVP layer.
- *
- *   Author: Nikita Danilov <nikita.danilov@sun.com>
- */
-
-#define DEBUG_SUBSYSTEM S_LLITE
-
-#include <obd_support.h>
-
-#include "vvp_internal.h"
-
-/*****************************************************************************
- *
- * Vvp lock functions.
- *
- */
-
-static void vvp_lock_fini(const struct lu_env *env, struct cl_lock_slice *slice)
-{
-	struct vvp_lock *vlk = cl2vvp_lock(slice);
-
-	kmem_cache_free(vvp_lock_kmem, vlk);
-}
-
-static int vvp_lock_enqueue(const struct lu_env *env,
-			    const struct cl_lock_slice *slice,
-			    struct cl_io *unused, struct cl_sync_io *anchor)
-{
-	CLOBINVRNT(env, slice->cls_obj, vvp_object_invariant(slice->cls_obj));
-
-	return 0;
-}
-
-static const struct cl_lock_operations vvp_lock_ops = {
-	.clo_fini	= vvp_lock_fini,
-	.clo_enqueue	= vvp_lock_enqueue,
-};
-
-int vvp_lock_init(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_lock *lock, const struct cl_io *unused)
-{
-	struct vvp_lock *vlk;
-	int result;
-
-	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
-
-	vlk = kmem_cache_zalloc(vvp_lock_kmem, GFP_NOFS);
-	if (vlk) {
-		cl_lock_slice_add(lock, &vlk->vlk_cl, obj, &vvp_lock_ops);
-		result = 0;
-	} else {
-		result = -ENOMEM;
-	}
-	return result;
-}
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index 549837f..6606459 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -217,7 +217,6 @@ static void vvp_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 
 static const struct cl_object_operations vvp_ops = {
 	.coo_page_init		= vvp_page_init,
-	.coo_lock_init		= vvp_lock_init,
 	.coo_io_init		= vvp_io_init,
 	.coo_attr_get		= vvp_attr_get,
 	.coo_attr_update	= vvp_attr_update,
diff --git a/fs/lustre/lov/Makefile b/fs/lustre/lov/Makefile
index 62eb769..abdaac0 100644
--- a/fs/lustre/lov/Makefile
+++ b/fs/lustre/lov/Makefile
@@ -5,4 +5,4 @@ obj-$(CONFIG_LUSTRE_FS) += lov.o
 lov-y := lov_obd.o lov_pack.o lov_offset.o lov_merge.o \
 	 lov_request.o lov_ea.o lov_dev.o lov_object.o lov_page.o  \
 	 lov_lock.o lov_io.o lovsub_dev.o lovsub_object.o lovsub_page.o      \
-	 lovsub_lock.o lov_pool.o lproc_lov.o
+	 lov_pool.o lproc_lov.o
diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 095bca0..4472d6f 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -81,7 +81,6 @@
 
 struct lovsub_device;
 struct lovsub_object;
-struct lovsub_lock;
 
 enum lov_device_flags {
 	LOV_DEV_INITIALIZED = 1 << 0
@@ -460,13 +459,6 @@ struct lovsub_object {
 };
 
 /**
- * Lock state@lovsub layer.
- */
-struct lovsub_lock {
-	struct cl_lock_slice	lss_cl;
-};
-
-/**
  * Describe the environment settings for sublocks.
  */
 struct lov_sublock_env {
@@ -607,7 +599,6 @@ struct lov_session {
 extern struct kmem_cache *lov_thread_kmem;
 extern struct kmem_cache *lov_session_kmem;
 
-extern struct kmem_cache *lovsub_lock_kmem;
 extern struct kmem_cache *lovsub_object_kmem;
 
 int lov_object_init(const struct lu_env *env, struct lu_object *obj,
@@ -618,8 +609,6 @@ int lov_lock_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_lock *lock, const struct cl_io *io);
 int lov_io_init(const struct lu_env *env, struct cl_object *obj,
 		struct cl_io *io);
-int lovsub_lock_init(const struct lu_env *env, struct cl_object *obj,
-		     struct cl_lock *lock, const struct cl_io *io);
 
 int lov_lock_init_composite(const struct lu_env *env, struct cl_object *obj,
 			    struct cl_lock *lock, const struct cl_io *io);
@@ -781,22 +770,6 @@ static inline struct lovsub_object *lu2lovsub(const struct lu_object *obj)
 	return container_of(obj, struct lovsub_object, lso_cl.co_lu);
 }
 
-static inline struct lovsub_lock *
-cl2lovsub_lock(const struct cl_lock_slice *slice)
-{
-	LINVRNT(lovsub_is_object(&slice->cls_obj->co_lu));
-	return container_of(slice, struct lovsub_lock, lss_cl);
-}
-
-static inline struct lovsub_lock *cl2sub_lock(const struct cl_lock *lock)
-{
-	const struct cl_lock_slice *slice;
-
-	slice = cl_lock_at(lock, &lovsub_device_type);
-	LASSERT(slice);
-	return cl2lovsub_lock(slice);
-}
-
 static inline struct lov_lock *cl2lov_lock(const struct cl_lock_slice *slice)
 {
 	LINVRNT(lov_is_object(&slice->cls_obj->co_lu));
diff --git a/fs/lustre/lov/lov_dev.c b/fs/lustre/lov/lov_dev.c
index 5ddf49a..46d2e1e 100644
--- a/fs/lustre/lov/lov_dev.c
+++ b/fs/lustre/lov/lov_dev.c
@@ -48,7 +48,6 @@
 struct kmem_cache *lov_thread_kmem;
 struct kmem_cache *lov_session_kmem;
 
-struct kmem_cache *lovsub_lock_kmem;
 struct kmem_cache *lovsub_object_kmem;
 
 struct lu_kmem_descr lov_caches[] = {
@@ -73,11 +72,6 @@ struct lu_kmem_descr lov_caches[] = {
 		.ckd_size  = sizeof(struct lov_session)
 	},
 	{
-		.ckd_cache = &lovsub_lock_kmem,
-		.ckd_name  = "lovsub_lock_kmem",
-		.ckd_size  = sizeof(struct lovsub_lock)
-	},
-	{
 		.ckd_cache = &lovsub_object_kmem,
 		.ckd_name  = "lovsub_object_kmem",
 		.ckd_size  = sizeof(struct lovsub_object)
diff --git a/fs/lustre/lov/lovsub_lock.c b/fs/lustre/lov/lovsub_lock.c
deleted file mode 100644
index 7b67c92..0000000
--- a/fs/lustre/lov/lovsub_lock.c
+++ /dev/null
@@ -1,81 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * Implementation of cl_lock for LOVSUB layer.
- *
- *   Author: Nikita Danilov <nikita.danilov@sun.com>
- */
-
-#define DEBUG_SUBSYSTEM S_LOV
-
-#include "lov_cl_internal.h"
-
-/** \addtogroup lov
- *  @{
- */
-
-/*****************************************************************************
- *
- * Lovsub lock operations.
- *
- */
-
-static void lovsub_lock_fini(const struct lu_env *env,
-			     struct cl_lock_slice *slice)
-{
-	struct lovsub_lock *lsl;
-
-	lsl = cl2lovsub_lock(slice);
-	kmem_cache_free(lovsub_lock_kmem, lsl);
-}
-
-static const struct cl_lock_operations lovsub_lock_ops = {
-	.clo_fini	= lovsub_lock_fini,
-};
-
-int lovsub_lock_init(const struct lu_env *env, struct cl_object *obj,
-		     struct cl_lock *lock, const struct cl_io *io)
-{
-	struct lovsub_lock *lsk;
-	int result;
-
-	lsk = kmem_cache_zalloc(lovsub_lock_kmem, GFP_NOFS);
-	if (lsk) {
-		cl_lock_slice_add(lock, &lsk->lss_cl, obj, &lovsub_lock_ops);
-		result = 0;
-	} else {
-		result = -ENOMEM;
-	}
-	return result;
-}
-
-/** @} lov */
diff --git a/fs/lustre/lov/lovsub_object.c b/fs/lustre/lov/lovsub_object.c
index 6ba09f1..03a6002 100644
--- a/fs/lustre/lov/lovsub_object.c
+++ b/fs/lustre/lov/lovsub_object.c
@@ -61,7 +61,7 @@ int lovsub_object_init(const struct lu_env *env, struct lu_object *obj,
 	below = under->ld_ops->ldo_object_alloc(env, obj->lo_header, under);
 	if (below) {
 		lu_object_add(obj, below);
-		cl_object_page_init(lu2cl(obj), sizeof(struct lovsub_page));
+		cl_object_page_init(lu2cl(obj), 0);
 		result = 0;
 	} else {
 		result = -ENOMEM;
@@ -145,8 +145,6 @@ static void lovsub_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 }
 
 static const struct cl_object_operations lovsub_ops = {
-	.coo_page_init		= lovsub_page_init,
-	.coo_lock_init		= lovsub_lock_init,
 	.coo_attr_update	= lovsub_attr_update,
 	.coo_glimpse		= lovsub_object_glimpse,
 	.coo_req_attr_set	= lovsub_req_attr_set
diff --git a/fs/lustre/obdclass/cl_lock.c b/fs/lustre/obdclass/cl_lock.c
index fe24379..07d0dc8 100644
--- a/fs/lustre/obdclass/cl_lock.c
+++ b/fs/lustre/obdclass/cl_lock.c
@@ -105,7 +105,10 @@ int cl_lock_init(const struct lu_env *env, struct cl_lock *lock,
 
 	INIT_LIST_HEAD(&lock->cll_layers);
 	cl_object_for_each(scan, obj) {
-		result = scan->co_ops->coo_lock_init(env, scan, lock, io);
+		if (scan->co_ops->coo_lock_init)
+			result = scan->co_ops->coo_lock_init(env, scan, lock,
+							     io);
+
 		if (result != 0) {
 			cl_lock_fini(env, lock);
 			break;
@@ -159,7 +162,7 @@ int cl_lock_enqueue(const struct lu_env *env, struct cl_io *io,
 		    struct cl_lock *lock, struct cl_sync_io *anchor)
 {
 	const struct cl_lock_slice *slice;
-	int rc = -EBUSY;
+	int rc = 0;
 
 	list_for_each_entry(slice, &lock->cll_layers, cls_linkage) {
 		if (!slice->cls_ops->clo_enqueue)
-- 
1.8.3.1
