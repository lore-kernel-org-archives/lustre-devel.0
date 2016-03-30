From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:48:05 -0400
Subject: [lustre-devel] [PATCH 33/43] staging/lustre/llite: rename ccc_req
	to vvp_req
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-34-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

Rename struct ccc_req to struct vvp_req and move related functions
from lustre/llite/lcommon_cl.c to the new file lustre/llite/vvp_req.c.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/13377
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5971
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |   2 +-
 drivers/staging/lustre/lustre/llite/Makefile       |   3 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   | 104 ------------------
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |   8 +-
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  18 +--
 drivers/staging/lustre/lustre/llite/vvp_req.c      | 121 +++++++++++++++++++++
 6 files changed, 136 insertions(+), 120 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/llite/vvp_req.c

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 104dc9f..918be65 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -140,7 +140,7 @@ struct cl_device_operations {
 	 * cl_req_slice_add().
 	 *
 	 * \see osc_req_init(), lov_req_init(), lovsub_req_init()
-	 * \see ccc_req_init()
+	 * \see vvp_req_init()
 	 */
 	int (*cdo_req_init)(const struct lu_env *env, struct cl_device *dev,
 			    struct cl_req *req);
diff --git a/drivers/staging/lustre/lustre/llite/Makefile b/drivers/staging/lustre/lustre/llite/Makefile
index 24085e2..2ce10ff 100644
--- a/drivers/staging/lustre/lustre/llite/Makefile
+++ b/drivers/staging/lustre/lustre/llite/Makefile
@@ -5,6 +5,7 @@ lustre-y := dcache.o dir.o file.o llite_close.o llite_lib.o llite_nfs.o \
 	    xattr.o xattr_cache.o remote_perm.o llite_rmtacl.o \
 	    rw26.o super25.o statahead.o \
 	    glimpse.o lcommon_cl.o lcommon_misc.o \
-	    vvp_dev.o vvp_page.o vvp_lock.o vvp_io.o vvp_object.o lproc_llite.o
+	    vvp_dev.o vvp_page.o vvp_lock.o vvp_io.o vvp_object.o vvp_req.o \
+	    lproc_llite.o
 
 llite_lloop-y := lloop.o
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 1b11103..d28546a 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -61,14 +61,11 @@
 
 #include "../llite/llite_internal.h"
 
-static const struct cl_req_operations ccc_req_ops;
-
 /*
  * ccc_ prefix stands for "Common Client Code".
  */
 
 static struct kmem_cache *ccc_thread_kmem;
-static struct kmem_cache *ccc_req_kmem;
 
 static struct lu_kmem_descr ccc_caches[] = {
 	{
@@ -77,11 +74,6 @@ static struct lu_kmem_descr ccc_caches[] = {
 		.ckd_size  = sizeof(struct ccc_thread_info),
 	},
 	{
-		.ckd_cache = &ccc_req_kmem,
-		.ckd_name  = "ccc_req_kmem",
-		.ckd_size  = sizeof(struct ccc_req)
-	},
-	{
 		.ckd_cache = NULL
 	}
 };
@@ -116,22 +108,6 @@ struct lu_context_key ccc_key = {
 	.lct_fini = ccc_key_fini
 };
 
-int ccc_req_init(const struct lu_env *env, struct cl_device *dev,
-		 struct cl_req *req)
-{
-	struct ccc_req *vrq;
-	int result;
-
-	vrq = kmem_cache_zalloc(ccc_req_kmem, GFP_NOFS);
-	if (vrq) {
-		cl_req_slice_add(req, &vrq->crq_cl, dev, &ccc_req_ops);
-		result = 0;
-	} else {
-		result = -ENOMEM;
-	}
-	return result;
-}
-
 /**
  * An `emergency' environment used by ccc_inode_fini() when cl_env_get()
  * fails. Access to this environment is serialized by ccc_inode_fini_guard
@@ -184,75 +160,6 @@ void ccc_global_fini(struct lu_device_type *device_type)
 	lu_kmem_fini(ccc_caches);
 }
 
-/*****************************************************************************
- *
- * Transfer operations.
- *
- */
-
-void ccc_req_completion(const struct lu_env *env,
-			const struct cl_req_slice *slice, int ioret)
-{
-	struct ccc_req *vrq;
-
-	if (ioret > 0)
-		cl_stats_tally(slice->crs_dev, slice->crs_req->crq_type, ioret);
-
-	vrq = cl2ccc_req(slice);
-	kmem_cache_free(ccc_req_kmem, vrq);
-}
-
-/**
- * Implementation of struct cl_req_operations::cro_attr_set() for ccc
- * layer. ccc is responsible for
- *
- *    - o_[mac]time
- *
- *    - o_mode
- *
- *    - o_parent_seq
- *
- *    - o_[ug]id
- *
- *    - o_parent_oid
- *
- *    - o_parent_ver
- *
- *    - o_ioepoch,
- *
- */
-void ccc_req_attr_set(const struct lu_env *env,
-		      const struct cl_req_slice *slice,
-		      const struct cl_object *obj,
-		      struct cl_req_attr *attr, u64 flags)
-{
-	struct inode *inode;
-	struct obdo  *oa;
-	u32	      valid_flags;
-
-	oa = attr->cra_oa;
-	inode = vvp_object_inode(obj);
-	valid_flags = OBD_MD_FLTYPE;
-
-	if (slice->crs_req->crq_type == CRT_WRITE) {
-		if (flags & OBD_MD_FLEPOCH) {
-			oa->o_valid |= OBD_MD_FLEPOCH;
-			oa->o_ioepoch = ll_i2info(inode)->lli_ioepoch;
-			valid_flags |= OBD_MD_FLMTIME | OBD_MD_FLCTIME |
-				       OBD_MD_FLUID | OBD_MD_FLGID;
-		}
-	}
-	obdo_from_inode(oa, inode, valid_flags & flags);
-	obdo_set_parent_fid(oa, &ll_i2info(inode)->lli_fid);
-	memcpy(attr->cra_jobid, ll_i2info(inode)->lli_jobid,
-	       JOBSTATS_JOBID_SIZE);
-}
-
-static const struct cl_req_operations ccc_req_ops = {
-	.cro_attr_set   = ccc_req_attr_set,
-	.cro_completion = ccc_req_completion
-};
-
 int cl_setattr_ost(struct inode *inode, const struct iattr *attr)
 {
 	struct lu_env *env;
@@ -301,17 +208,6 @@ again:
 	return result;
 }
 
-/*****************************************************************************
- *
- * Type conversions.
- *
- */
-
-struct ccc_req *cl2ccc_req(const struct cl_req_slice *slice)
-{
-	return container_of0(slice, struct ccc_req, crq_cl);
-}
-
 /**
  * Initialize or update CLIO structures for regular files when new
  * meta-data arrives from the server.
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 030a246..5d3beb6 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -59,6 +59,7 @@
 
 struct kmem_cache *vvp_lock_kmem;
 struct kmem_cache *vvp_object_kmem;
+struct kmem_cache *vvp_req_kmem;
 static struct kmem_cache *vvp_thread_kmem;
 static struct kmem_cache *vvp_session_kmem;
 static struct lu_kmem_descr vvp_caches[] = {
@@ -73,6 +74,11 @@ static struct lu_kmem_descr vvp_caches[] = {
 		.ckd_size  = sizeof(struct vvp_object),
 	},
 	{
+		.ckd_cache = &vvp_req_kmem,
+		.ckd_name  = "vvp_req_kmem",
+		.ckd_size  = sizeof(struct vvp_req),
+	},
+	{
 		.ckd_cache = &vvp_thread_kmem,
 		.ckd_name  = "vvp_thread_kmem",
 		.ckd_size  = sizeof(struct vvp_thread_info),
@@ -145,7 +151,7 @@ static const struct lu_device_operations vvp_lu_ops = {
 };
 
 static const struct cl_device_operations vvp_cl_ops = {
-	.cdo_req_init = ccc_req_init
+	.cdo_req_init = vvp_req_init
 };
 
 static struct lu_device *vvp_device_free(const struct lu_env *env,
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 7af8c44..99e7ef3 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -169,6 +169,7 @@ extern struct lu_context_key vvp_session_key;
 
 extern struct kmem_cache *vvp_lock_kmem;
 extern struct kmem_cache *vvp_object_kmem;
+extern struct kmem_cache *vvp_req_kmem;
 
 struct ccc_thread_info {
 	struct cl_lock		cti_lock;
@@ -313,8 +314,8 @@ struct vvp_lock {
 	struct cl_lock_slice vlk_cl;
 };
 
-struct ccc_req {
-	struct cl_req_slice  crq_cl;
+struct vvp_req {
+	struct cl_req_slice  vrq_cl;
 };
 
 void *ccc_key_init(const struct lu_context *ctx,
@@ -322,19 +323,10 @@ void *ccc_key_init(const struct lu_context *ctx,
 void ccc_key_fini(const struct lu_context *ctx,
 		  struct lu_context_key *key, void *data);
 
-int ccc_req_init(const struct lu_env *env, struct cl_device *dev,
-		 struct cl_req *req);
 void ccc_umount(const struct lu_env *env, struct cl_device *dev);
 int ccc_global_init(struct lu_device_type *device_type);
 void ccc_global_fini(struct lu_device_type *device_type);
 
-void ccc_req_completion(const struct lu_env *env,
-			const struct cl_req_slice *slice, int ioret);
-void ccc_req_attr_set(const struct lu_env *env,
-		      const struct cl_req_slice *slice,
-		      const struct cl_object *obj,
-		      struct cl_req_attr *oa, u64 flags);
-
 static inline struct lu_device *vvp2lu_dev(struct vvp_device *vdv)
 {
 	return &vdv->vdv_cl.cd_lu_dev;
@@ -378,8 +370,6 @@ static inline struct vvp_lock *cl2vvp_lock(const struct cl_lock_slice *slice)
 	return container_of(slice, struct vvp_lock, vlk_cl);
 }
 
-struct ccc_req *cl2ccc_req(const struct cl_req_slice *slice);
-
 int cl_setattr_ost(struct inode *inode, const struct iattr *attr);
 
 int cl_file_inode_init(struct inode *inode, struct lustre_md *md);
@@ -431,6 +421,8 @@ int vvp_lock_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_lock *lock, const struct cl_io *io);
 int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_page *page, pgoff_t index);
+int vvp_req_init(const struct lu_env *env, struct cl_device *dev,
+		 struct cl_req *req);
 struct lu_object *vvp_object_alloc(const struct lu_env *env,
 				   const struct lu_object_header *hdr,
 				   struct lu_device *dev);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_req.c b/drivers/staging/lustre/lustre/llite/vvp_req.c
new file mode 100644
index 0000000..fb88629
--- /dev/null
+++ b/drivers/staging/lustre/lustre/llite/vvp_req.c
@@ -0,0 +1,121 @@
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2011, 2014, Intel Corporation.
+ */
+
+#define DEBUG_SUBSYSTEM S_LLITE
+
+#include "../include/lustre/lustre_idl.h"
+#include "../include/cl_object.h"
+#include "../include/obd.h"
+#include "../include/obd_support.h"
+#include "../include/lustre_lite.h"
+#include "llite_internal.h"
+#include "vvp_internal.h"
+
+static inline struct vvp_req *cl2vvp_req(const struct cl_req_slice *slice)
+{
+	return container_of0(slice, struct vvp_req, vrq_cl);
+}
+
+/**
+ * Implementation of struct cl_req_operations::cro_attr_set() for VVP
+ * layer. VVP is responsible for
+ *
+ *    - o_[mac]time
+ *
+ *    - o_mode
+ *
+ *    - o_parent_seq
+ *
+ *    - o_[ug]id
+ *
+ *    - o_parent_oid
+ *
+ *    - o_parent_ver
+ *
+ *    - o_ioepoch,
+ *
+ */
+void vvp_req_attr_set(const struct lu_env *env,
+		      const struct cl_req_slice *slice,
+		      const struct cl_object *obj,
+		      struct cl_req_attr *attr, u64 flags)
+{
+	struct inode *inode;
+	struct obdo  *oa;
+	u32	      valid_flags;
+
+	oa = attr->cra_oa;
+	inode = vvp_object_inode(obj);
+	valid_flags = OBD_MD_FLTYPE;
+
+	if (slice->crs_req->crq_type == CRT_WRITE) {
+		if (flags & OBD_MD_FLEPOCH) {
+			oa->o_valid |= OBD_MD_FLEPOCH;
+			oa->o_ioepoch = ll_i2info(inode)->lli_ioepoch;
+			valid_flags |= OBD_MD_FLMTIME | OBD_MD_FLCTIME |
+				       OBD_MD_FLUID | OBD_MD_FLGID;
+		}
+	}
+	obdo_from_inode(oa, inode, valid_flags & flags);
+	obdo_set_parent_fid(oa, &ll_i2info(inode)->lli_fid);
+	memcpy(attr->cra_jobid, ll_i2info(inode)->lli_jobid,
+	       JOBSTATS_JOBID_SIZE);
+}
+
+void vvp_req_completion(const struct lu_env *env,
+			const struct cl_req_slice *slice, int ioret)
+{
+	struct vvp_req *vrq;
+
+	if (ioret > 0)
+		cl_stats_tally(slice->crs_dev, slice->crs_req->crq_type, ioret);
+
+	vrq = cl2vvp_req(slice);
+	kmem_cache_free(vvp_req_kmem, vrq);
+}
+
+static const struct cl_req_operations vvp_req_ops = {
+	.cro_attr_set   = vvp_req_attr_set,
+	.cro_completion = vvp_req_completion
+};
+
+int vvp_req_init(const struct lu_env *env, struct cl_device *dev,
+		 struct cl_req *req)
+{
+	struct vvp_req *vrq;
+	int result;
+
+	vrq = kmem_cache_zalloc(vvp_req_kmem, GFP_NOFS);
+	if (vrq) {
+		cl_req_slice_add(req, &vrq->vrq_cl, dev, &vvp_req_ops);
+		result = 0;
+	} else {
+		result = -ENOMEM;
+	}
+	return result;
+}
-- 
2.1.0
