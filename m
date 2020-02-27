From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:34 -0500
Subject: [lustre-devel] [PATCH 166/622] lustre: clio: use pagevec_release
 for many pages
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-167-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Dongyang <dongyangli@ddn.com>

When Lustre releases cached pages, it always uses
page_release, even when releasing many pages.

When clearing OST ldlm lock lrus in parallel with lots of
cached data, the ldlm_bl threads spend most of their time
contending for the zone lock taken by page_release.
Also, when osc_lru_reclaim kicks in when there's not enough
LRU slots during I/O, the contention on zone lock kills
I/O performance.

Switching to pagevec when we expect to actually release the
pages (discard_pages, truncate, lru reclaim) brings
significant performance benefits as shown below.

This patch introduces cl_pagevec_put() to release the pages
in batches using pagevec, which is essentially calling
release_pages().

  mpirun -np 48 ior -w -r -t 16m -b 16g -F -e -vv -o ... -i 1 [-B]

                mode         write (GB/s)    read (GB/s)
  master        O_DIRECT     20.8            21.8
  master+patch  O_DIRECT     20.7            22.2
  master        Buffered     11.6            12.3
  master+patch  Buffered     15.3            19.6

Also clean up the dead lovsub_page related code.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9906
Lustre-commit: b4a959eb61bc ("LU-9906 clio: use pagevec_release for many pages")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/28667
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h   |  7 ++++-
 fs/lustre/include/lustre_osc.h  |  1 +
 fs/lustre/llite/vvp_page.c      | 19 ++++++++----
 fs/lustre/lov/Makefile          |  2 +-
 fs/lustre/lov/lov_cl_internal.h | 13 --------
 fs/lustre/lov/lovsub_page.c     | 68 -----------------------------------------
 fs/lustre/obdclass/cl_page.c    | 36 +++++++++++++++-------
 fs/lustre/obdecho/echo_client.c |  3 +-
 fs/lustre/osc/osc_cache.c       | 14 +++++++--
 fs/lustre/osc/osc_page.c        |  5 ++-
 10 files changed, 64 insertions(+), 104 deletions(-)
 delete mode 100644 fs/lustre/lov/lovsub_page.c

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index c96a5b7..3337bbf 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -95,6 +95,7 @@
 #include <linux/radix-tree.h>
 #include <linux/spinlock.h>
 #include <linux/wait.h>
+#include <linux/pagevec.h>
 
 struct inode;
 
@@ -896,7 +897,8 @@ struct cl_page_operations {
 			   const struct cl_page_slice *slice);
 	/** Destructor. Frees resources and slice itself. */
 	void (*cpo_fini)(const struct lu_env *env,
-			 struct cl_page_slice *slice);
+			 struct cl_page_slice *slice,
+			 struct pagevec *pvec);
 	/**
 	 * Optional debugging helper. Prints given page slice.
 	 *
@@ -2147,6 +2149,9 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
 			      enum cl_page_type type);
 void cl_page_get(struct cl_page *page);
 void cl_page_put(const struct lu_env *env, struct cl_page *page);
+void cl_pagevec_put(const struct lu_env *env,
+		    struct cl_page *page,
+		    struct pagevec *pvec);
 void cl_page_print(const struct lu_env *env, void *cookie, lu_printer_t printer,
 		   const struct cl_page *pg);
 void cl_page_header_print(const struct lu_env *env, void *cookie,
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index dabcee0..aa3d4c3 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -179,6 +179,7 @@ struct osc_thread_info {
 	struct lustre_handle	oti_handle;
 	struct cl_page_list	oti_plist;
 	struct cl_io		oti_io;
+	struct pagevec		oti_pagevec;
 	void			*oti_pvec[OTI_PVEC_SIZE];
 	/*
 	 * Fields used by cl_lock_discard_pages().
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index 78a70b5..bd4ec85 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -54,16 +54,22 @@
  *
  */
 
-static void vvp_page_fini_common(struct vvp_page *vpg)
+static void vvp_page_fini_common(struct vvp_page *vpg, struct pagevec *pvec)
 {
 	struct page *vmpage = vpg->vpg_page;
 
 	LASSERT(vmpage);
-	put_page(vmpage);
+	if (pvec) {
+		if (!pagevec_add(pvec, vmpage))
+			pagevec_release(pvec);
+	} else {
+		put_page(vmpage);
+	}
 }
 
 static void vvp_page_fini(const struct lu_env *env,
-			  struct cl_page_slice *slice)
+			  struct cl_page_slice *slice,
+			  struct pagevec *pvec)
 {
 	struct vvp_page *vpg = cl2vvp_page(slice);
 	struct page *vmpage = vpg->vpg_page;
@@ -73,7 +79,7 @@ static void vvp_page_fini(const struct lu_env *env,
 	 * VPG_FREEING state.
 	 */
 	LASSERT((struct cl_page *)vmpage->private != slice->cpl_page);
-	vvp_page_fini_common(vpg);
+	vvp_page_fini_common(vpg, pvec);
 }
 
 static int vvp_page_own(const struct lu_env *env,
@@ -471,13 +477,14 @@ static int vvp_transient_page_is_vmlocked(const struct lu_env *env,
 }
 
 static void vvp_transient_page_fini(const struct lu_env *env,
-				    struct cl_page_slice *slice)
+				    struct cl_page_slice *slice,
+				    struct pagevec *pvec)
 {
 	struct vvp_page *vpg = cl2vvp_page(slice);
 	struct cl_page *clp = slice->cpl_page;
 	struct vvp_object *clobj = cl2vvp(clp->cp_obj);
 
-	vvp_page_fini_common(vpg);
+	vvp_page_fini_common(vpg, pvec);
 	atomic_dec(&clobj->vob_transient_pages);
 }
 
diff --git a/fs/lustre/lov/Makefile b/fs/lustre/lov/Makefile
index abdaac0..2f0b761 100644
--- a/fs/lustre/lov/Makefile
+++ b/fs/lustre/lov/Makefile
@@ -4,5 +4,5 @@ ccflags-y += -I$(srctree)/$(src)/../include
 obj-$(CONFIG_LUSTRE_FS) += lov.o
 lov-y := lov_obd.o lov_pack.o lov_offset.o lov_merge.o \
 	 lov_request.o lov_ea.o lov_dev.o lov_object.o lov_page.o  \
-	 lov_lock.o lov_io.o lovsub_dev.o lovsub_object.o lovsub_page.o      \
+	 lov_lock.o lov_io.o lovsub_dev.o lovsub_object.o \
 	 lov_pool.o lproc_lov.o
diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 875af37..e14567d 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -466,10 +466,6 @@ struct lov_sublock_env {
 	struct cl_io		*lse_io;
 };
 
-struct lovsub_page {
-	struct cl_page_slice	lsb_cl;
-};
-
 struct lov_thread_info {
 	struct cl_object_conf   lti_stripe_conf;
 	struct lu_fid		lti_fid;
@@ -626,8 +622,6 @@ struct lov_io_sub *lov_sub_get(const struct lu_env *env, struct lov_io *lio,
 
 int lov_page_init(const struct lu_env *env, struct cl_object *ob,
 		  struct cl_page *page, pgoff_t index);
-int lovsub_page_init(const struct lu_env *env, struct cl_object *ob,
-		     struct cl_page *page, pgoff_t index);
 int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
 			struct cl_page *page, pgoff_t index);
 int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
@@ -782,13 +776,6 @@ static inline struct lov_page *cl2lov_page(const struct cl_page_slice *slice)
 	return container_of(slice, struct lov_page, lps_cl);
 }
 
-static inline struct lovsub_page *
-cl2lovsub_page(const struct cl_page_slice *slice)
-{
-	LINVRNT(lovsub_is_object(&slice->cpl_obj->co_lu));
-	return container_of(slice, struct lovsub_page, lsb_cl);
-}
-
 static inline struct lov_io *cl2lov_io(const struct lu_env *env,
 				       const struct cl_io_slice *ios)
 {
diff --git a/fs/lustre/lov/lovsub_page.c b/fs/lustre/lov/lovsub_page.c
deleted file mode 100644
index a8aa583..0000000
--- a/fs/lustre/lov/lovsub_page.c
+++ /dev/null
@@ -1,68 +0,0 @@
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
- * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * Implementation of cl_page for LOVSUB layer.
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
- * Lovsub page operations.
- *
- */
-
-static void lovsub_page_fini(const struct lu_env *env,
-			     struct cl_page_slice *slice)
-{
-}
-
-static const struct cl_page_operations lovsub_page_ops = {
-	.cpo_fini	= lovsub_page_fini
-};
-
-int lovsub_page_init(const struct lu_env *env, struct cl_object *obj,
-		     struct cl_page *page, pgoff_t index)
-{
-	struct lovsub_page *lsb = cl_object_page_slice(obj, page);
-
-	cl_page_slice_add(page, &lsb->lsb_cl, obj, index, &lovsub_page_ops);
-	return 0;
-}
-
-/** @} lov */
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 8dbd312..3076f8c 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -90,7 +90,8 @@ static void cl_page_get_trust(struct cl_page *page)
 	return NULL;
 }
 
-static void cl_page_free(const struct lu_env *env, struct cl_page *page)
+static void cl_page_free(const struct lu_env *env, struct cl_page *page,
+			 struct pagevec *pvec)
 {
 	struct cl_object *obj = page->cp_obj;
 	struct cl_page_slice *slice;
@@ -104,7 +105,7 @@ static void cl_page_free(const struct lu_env *env, struct cl_page *page)
 						 cpl_linkage)) != NULL) {
 		list_del_init(page->cp_layers.next);
 		if (unlikely(slice->cpl_ops->cpo_fini))
-			slice->cpl_ops->cpo_fini(env, slice);
+			slice->cpl_ops->cpo_fini(env, slice, pvec);
 	}
 	lu_object_ref_del_at(&obj->co_lu, &page->cp_obj_ref, "cl_page", page);
 	cl_object_put(env, obj);
@@ -152,7 +153,7 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
 								   page, ind);
 				if (result != 0) {
 					__cl_page_delete(env, page);
-					cl_page_free(env, page);
+					cl_page_free(env, page, NULL);
 					page = ERR_PTR(result);
 					break;
 				}
@@ -299,15 +300,13 @@ void cl_page_get(struct cl_page *page)
 EXPORT_SYMBOL(cl_page_get);
 
 /**
- * Releases a reference to a page.
+ * Releases a reference to a page, use the pagevec to release the pages
+ * in batch if provided.
  *
- * When last reference is released, page is returned to the cache, unless it
- * is in cl_page_state::CPS_FREEING state, in which case it is immediately
- * destroyed.
- *
- * \see cl_object_put(), cl_lock_put().
+ * Users need to do a final pagevec_release() to release any trailing pages.
  */
-void cl_page_put(const struct lu_env *env, struct cl_page *page)
+void cl_pagevec_put(const struct lu_env *env, struct cl_page *page,
+		  struct pagevec *pvec)
 {
 	CL_PAGE_HEADER(D_TRACE, env, page, "%d\n",
 		       refcount_read(&page->cp_ref));
@@ -322,9 +321,24 @@ void cl_page_put(const struct lu_env *env, struct cl_page *page)
 		 * Page is no longer reachable by other threads. Tear
 		 * it down.
 		 */
-		cl_page_free(env, page);
+		cl_page_free(env, page, pvec);
 	}
 }
+EXPORT_SYMBOL(cl_pagevec_put);
+
+/**
+ * Releases a reference to a page, wrapper to cl_pagevec_put
+ *
+ * When last reference is released, page is returned to the cache, unless it
+ * is in cl_page_state::CPS_FREEING state, in which case it is immediately
+ * destroyed.
+ *
+ * \see cl_object_put(), cl_lock_put().
+ */
+void cl_page_put(const struct lu_env *env, struct cl_page *page)
+{
+	cl_pagevec_put(env, page, NULL);
+}
 EXPORT_SYMBOL(cl_page_put);
 
 /**
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 0735a5a..5ac4519 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -259,7 +259,8 @@ static void echo_page_completion(const struct lu_env *env,
 }
 
 static void echo_page_fini(const struct lu_env *env,
-			   struct cl_page_slice *slice)
+			   struct cl_page_slice *slice,
+			   struct pagevec *pvec)
 {
 	struct echo_object *eco = cl2echo_obj(slice->cpl_obj);
 
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 961fc6bf..47aee99 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -985,6 +985,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 	struct client_obd *cli = osc_cli(obj);
 	struct osc_async_page *oap;
 	struct osc_async_page *tmp;
+	struct pagevec        *pvec;
 	int pages_in_chunk = 0;
 	int ppc_bits = cli->cl_chunkbits - PAGE_SHIFT;
 	u64 trunc_chunk = trunc_index >> ppc_bits;
@@ -1008,6 +1009,8 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 	io  = osc_env_thread_io(env);
 	io->ci_obj = cl_object_top(osc2cl(obj));
 	io->ci_ignore_layout = 1;
+	pvec = &osc_env_info(env)->oti_pagevec;
+	pagevec_init(pvec);
 	rc = cl_io_init(env, io, CIT_MISC, io->ci_obj);
 	if (rc < 0)
 		goto out;
@@ -1046,11 +1049,13 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 		}
 
 		lu_ref_del(&page->cp_reference, "truncate", current);
-		cl_page_put(env, page);
+		cl_pagevec_put(env, page, pvec);
 
 		--ext->oe_nr_pages;
 		++nr_pages;
 	}
+	pagevec_release(pvec);
+
 	EASSERTF(ergo(ext->oe_start >= trunc_index + !!partial,
 		      ext->oe_nr_pages == 0),
 		ext, "trunc_index %lu, partial %d\n", trunc_index, partial);
@@ -3030,6 +3035,7 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 			  osc_page_gang_cbt cb, void *cbdata)
 {
 	struct osc_page *ops;
+	struct pagevec	*pagevec;
 	void **pvec;
 	pgoff_t idx;
 	unsigned int nr;
@@ -3040,6 +3046,8 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 
 	idx = start;
 	pvec = osc_env_info(env)->oti_pvec;
+	pagevec = &osc_env_info(env)->oti_pagevec;
+	pagevec_init(pagevec);
 	spin_lock(&osc->oo_tree_lock);
 	while ((nr = radix_tree_gang_lookup(&osc->oo_tree, pvec,
 					    idx, OTI_PVEC_SIZE)) > 0) {
@@ -3086,8 +3094,10 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 
 			page = ops->ops_cl.cpl_page;
 			lu_ref_del(&page->cp_reference, "gang_lookup", current);
-			cl_page_put(env, page);
+			cl_pagevec_put(env, page, pagevec);
 		}
+		pagevec_release(pagevec);
+
 		if (nr < OTI_PVEC_SIZE || end_of_region)
 			break;
 
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 9236e02..4dc6c18 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -506,8 +506,10 @@ static void osc_lru_use(struct client_obd *cli, struct osc_page *opg)
 static void discard_pagevec(const struct lu_env *env, struct cl_io *io,
 			    struct cl_page **pvec, int max_index)
 {
+	struct pagevec *pagevec = &osc_env_info(env)->oti_pagevec;
 	int i;
 
+	pagevec_init(pagevec);
 	for (i = 0; i < max_index; i++) {
 		struct cl_page *page = pvec[i];
 
@@ -515,10 +517,11 @@ static void discard_pagevec(const struct lu_env *env, struct cl_io *io,
 		cl_page_delete(env, page);
 		cl_page_discard(env, io, page);
 		cl_page_disown(env, io, page);
-		cl_page_put(env, page);
+		cl_pagevec_put(env, page, pagevec);
 
 		pvec[i] = NULL;
 	}
+	pagevec_release(pagevec);
 }
 
 /**
-- 
1.8.3.1
