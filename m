From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:01 -0400
Subject: [lustre-devel] [PATCH 042/151] lustre: mdc: add cl_device to the MDC
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-43-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhal Pershin <mpershin@whamcloud.com>

Introduce cl_device for MDC so it is able to prepare and send
IO requests to the MDT.

This patch adds basic interfaces for device and object methods.
The common code is exported from OSC for MDC.

WC-bug-id: https://jira.whamcloud.com/browse/LU-3285
Lustre-commit: 68ff85b8858e ("LU-3285 mdc: add cl_device to the MDC")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28009
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  23 +++++
 fs/lustre/mdc/Makefile         |   1 +
 fs/lustre/mdc/mdc_dev.c        | 192 +++++++++++++++++++++++++++++++++++++++++
 fs/lustre/mdc/mdc_internal.h   |   6 ++
 fs/lustre/mdc/mdc_request.c    |   6 +-
 fs/lustre/osc/osc_dev.c        |  22 +++--
 fs/lustre/osc/osc_object.c     |  29 ++++---
 7 files changed, 257 insertions(+), 22 deletions(-)
 create mode 100644 fs/lustre/mdc/mdc_dev.c

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 6c8a9d4..e91fae2 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -489,6 +489,29 @@ void osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
 
 int osc_lock_is_lockless(const struct osc_lock *olck);
 
+/* osc_dev.c */
+int osc_device_init(const struct lu_env *env, struct lu_device *d,
+		    const char *name, struct lu_device *next);
+struct lu_device *osc_device_fini(const struct lu_env *env,
+				  struct lu_device *d);
+struct lu_device *osc_device_free(const struct lu_env *env,
+				  struct lu_device *d);
+
+/* osc_object.c */
+int osc_object_init(const struct lu_env *env, struct lu_object *obj,
+		    const struct lu_object_conf *conf);
+void osc_object_free(const struct lu_env *env, struct lu_object *obj);
+int osc_lvb_print(const struct lu_env *env, void *cookie,
+		  lu_printer_t p, const struct ost_lvb *lvb);
+int osc_object_print(const struct lu_env *env, void *cookie,
+		     lu_printer_t p, const struct lu_object *obj);
+int osc_attr_get(const struct lu_env *env, struct cl_object *obj,
+		 struct cl_attr *attr);
+int osc_attr_update(const struct lu_env *env, struct cl_object *obj,
+		    const struct cl_attr *attr, unsigned int valid);
+int osc_object_glimpse(const struct lu_env *env, const struct cl_object *obj,
+		       struct ost_lvb *lvb);
+
 /****************************************************************************
  *
  * Accessors and type conversions.
diff --git a/fs/lustre/mdc/Makefile b/fs/lustre/mdc/Makefile
index 1aeaa68..2cbc641 100644
--- a/fs/lustre/mdc/Makefile
+++ b/fs/lustre/mdc/Makefile
@@ -2,3 +2,4 @@ ccflags-y += -I$(srctree)/$(src)/../include
 
 obj-$(CONFIG_LUSTRE_FS) += mdc.o
 mdc-y := mdc_changelog.o mdc_request.o mdc_reint.o mdc_lib.o mdc_locks.o lproc_mdc.o
+mdc-y += mdc_dev.o
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
new file mode 100644
index 0000000..aa86d93
--- /dev/null
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -0,0 +1,192 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2017 Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ *
+ * Implementation of cl_device, cl_req for MDC layer.
+ *
+ * Author: Mikhail Pershin <mpershin@whamcloud.com>
+ */
+
+#define DEBUG_SUBSYSTEM S_MDC
+
+#include <obd_class.h>
+#include <lustre_osc.h>
+
+#include "mdc_internal.h"
+
+int mdc_page_init(const struct lu_env *env, struct cl_object *obj,
+		  struct cl_page *page, pgoff_t index)
+{
+	return -ENOTSUPP;
+}
+
+int mdc_lock_init(const struct lu_env *env,
+		  struct cl_object *obj, struct cl_lock *lock,
+		  const struct cl_io *unused)
+{
+	return -ENOTSUPP;
+}
+
+int mdc_io_init(const struct lu_env *env,
+		struct cl_object *obj, struct cl_io *io)
+{
+	return -ENOTSUPP;
+}
+
+/**
+ * Implementation of struct cl_req_operations::cro_attr_set() for MDC
+ * layer. MDC is responsible for struct obdo::o_id and struct obdo::o_seq
+ * fields.
+ */
+static void mdc_req_attr_set(const struct lu_env *env, struct cl_object *obj,
+			     struct cl_req_attr *attr)
+{
+	u64 flags = attr->cra_flags;
+
+	/* Copy object FID to cl_attr */
+	attr->cra_oa->o_oi.oi_fid = *lu_object_fid(&obj->co_lu);
+
+	if (flags & OBD_MD_FLGROUP)
+		attr->cra_oa->o_valid |= OBD_MD_FLGROUP;
+
+	if (flags & OBD_MD_FLID)
+		attr->cra_oa->o_valid |= OBD_MD_FLID;
+}
+
+static const struct cl_object_operations mdc_ops = {
+	.coo_page_init		= mdc_page_init,
+	.coo_lock_init		= mdc_lock_init,
+	.coo_io_init		= mdc_io_init,
+	.coo_attr_get		= osc_attr_get,
+	.coo_attr_update	= osc_attr_update,
+	.coo_glimpse		= osc_object_glimpse,
+	.coo_req_attr_set	= mdc_req_attr_set,
+};
+
+static int mdc_object_init(const struct lu_env *env, struct lu_object *obj,
+			   const struct lu_object_conf *conf)
+{
+	struct osc_object *osc = lu2osc(obj);
+
+	if (osc->oo_initialized)
+		return 0;
+
+	osc->oo_initialized = true;
+
+	return osc_object_init(env, obj, conf);
+}
+
+static void mdc_object_free(const struct lu_env *env, struct lu_object *obj)
+{
+	osc_object_free(env, obj);
+}
+
+static const struct lu_object_operations mdc_lu_obj_ops = {
+	.loo_object_init	= mdc_object_init,
+	.loo_object_delete	= NULL,
+	.loo_object_release	= NULL,
+	.loo_object_free	= mdc_object_free,
+	.loo_object_print	= osc_object_print,
+	.loo_object_invariant	= NULL
+};
+
+struct lu_object *mdc_object_alloc(const struct lu_env *env,
+				   const struct lu_object_header *unused,
+				   struct lu_device *dev)
+{
+	struct osc_object *osc;
+	struct lu_object *obj;
+
+	osc = kmem_cache_zalloc(osc_object_kmem, GFP_NOFS);
+	if (osc) {
+		obj = osc2lu(osc);
+		lu_object_init(obj, NULL, dev);
+		osc->oo_cl.co_ops = &mdc_ops;
+		obj->lo_ops = &mdc_lu_obj_ops;
+		osc->oo_initialized = false;
+	} else {
+		obj = NULL;
+	}
+	return obj;
+}
+
+static int mdc_cl_process_config(const struct lu_env *env,
+				 struct lu_device *d, struct lustre_cfg *cfg)
+{
+	return mdc_process_config(d->ld_obd, 0, cfg);
+}
+
+const struct lu_device_operations mdc_lu_ops = {
+	.ldo_object_alloc	= mdc_object_alloc,
+	.ldo_process_config	= mdc_cl_process_config,
+	.ldo_recovery_complete	= NULL,
+};
+
+static struct lu_device *mdc_device_alloc(const struct lu_env *env,
+					  struct lu_device_type *t,
+					  struct lustre_cfg *cfg)
+{
+	struct lu_device *d;
+	struct osc_device *od;
+	struct obd_device *obd;
+	int rc;
+
+	od = kzalloc(sizeof(*od), GFP_NOFS);
+	if (!od)
+		return ERR_PTR(-ENOMEM);
+
+	cl_device_init(&od->od_cl, t);
+	d = osc2lu_dev(od);
+	d->ld_ops = &mdc_lu_ops;
+
+	/* Setup MDC OBD */
+	obd = class_name2obd(lustre_cfg_string(cfg, 0));
+	if (!obd)
+		return ERR_PTR(-ENODEV);
+
+	rc = mdc_setup(obd, cfg);
+	if (rc < 0) {
+		osc_device_free(env, d);
+		return ERR_PTR(rc);
+	}
+	od->od_exp = obd->obd_self_export;
+	return d;
+}
+
+static const struct lu_device_type_operations mdc_device_type_ops = {
+	.ldto_device_alloc	= mdc_device_alloc,
+	.ldto_device_free	= osc_device_free,
+	.ldto_device_init	= osc_device_init,
+	.ldto_device_fini	= osc_device_fini
+};
+
+struct lu_device_type mdc_device_type = {
+	.ldt_tags		= LU_DEVICE_CL,
+	.ldt_name		= LUSTRE_MDC_NAME,
+	.ldt_ops		= &mdc_device_type_ops,
+	.ldt_ctx_tags		= LCT_CL_THREAD
+};
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index 2b849e8..943b383 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -90,6 +90,9 @@ int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 /* mdc/mdc_request.c */
 int mdc_fid_alloc(const struct lu_env *env, struct obd_export *exp,
 		  struct lu_fid *fid, struct md_op_data *op_data);
+int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg);
+int mdc_process_config(struct obd_device *obd, u32 len, void *buf);
+
 struct obd_client_handle;
 
 int mdc_set_open_replay_data(struct obd_export *exp,
@@ -149,4 +152,7 @@ static inline unsigned long hash_x_index(u64 hash, int hash64)
 	return ~0UL - (hash + !hash);
 }
 
+/* mdc_dev.c */
+extern struct lu_device_type mdc_device_type;
+
 #endif
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index dd90e931..1103c15 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2473,7 +2473,7 @@ static void mdc_llog_finish(struct obd_device *obd)
 		llog_cleanup(NULL, ctxt);
 }
 
-static int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
+int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 {
 	int rc;
 
@@ -2566,7 +2566,7 @@ static int mdc_cleanup(struct obd_device *obd)
 	return client_obd_cleanup(obd);
 }
 
-static int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
+int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
 {
 	struct lustre_cfg *lcfg = buf;
 	size_t count  = class_modify_config(lcfg, PARAM_MDC,
@@ -2635,7 +2635,7 @@ static int __init mdc_init(void)
 		return rc;
 
 	return class_register_type(&mdc_obd_ops, &mdc_md_ops,
-				   LUSTRE_MDC_NAME, NULL);
+				   LUSTRE_MDC_NAME, &mdc_device_type);
 }
 
 static void /*__exit*/ mdc_exit(void)
diff --git a/fs/lustre/osc/osc_dev.c b/fs/lustre/osc/osc_dev.c
index 080c32c..7178e6b 100644
--- a/fs/lustre/osc/osc_dev.c
+++ b/fs/lustre/osc/osc_dev.c
@@ -48,11 +48,16 @@
  */
 
 struct kmem_cache *osc_lock_kmem;
+EXPORT_SYMBOL(osc_lock_kmem);
 struct kmem_cache *osc_object_kmem;
+EXPORT_SYMBOL(osc_object_kmem);
+
 struct kmem_cache *osc_thread_kmem;
 struct kmem_cache *osc_session_kmem;
 struct kmem_cache *osc_extent_kmem;
+EXPORT_SYMBOL(osc_extent_kmem);
 struct kmem_cache *osc_quota_kmem;
+EXPORT_SYMBOL(osc_quota_kmem);
 
 struct lu_kmem_descr osc_caches[] = {
 	{
@@ -162,20 +167,20 @@ static int osc_cl_process_config(const struct lu_env *env,
 	.ldo_recovery_complete	= NULL
 };
 
-static int osc_device_init(const struct lu_env *env, struct lu_device *d,
-			   const char *name, struct lu_device *next)
+int osc_device_init(const struct lu_env *env, struct lu_device *d,
+		    const char *name, struct lu_device *next)
 {
 	return 0;
 }
-
-static struct lu_device *osc_device_fini(const struct lu_env *env,
-					 struct lu_device *d)
+EXPORT_SYMBOL(osc_device_init);
+struct lu_device *osc_device_fini(const struct lu_env *env,
+				  struct lu_device *d)
 {
 	return NULL;
 }
-
-static struct lu_device *osc_device_free(const struct lu_env *env,
-					 struct lu_device *d)
+EXPORT_SYMBOL(osc_device_fini);
+struct lu_device *osc_device_free(const struct lu_env *env,
+				  struct lu_device *d)
 {
 	struct osc_device *od = lu2osc_dev(d);
 
@@ -183,6 +188,7 @@ static struct lu_device *osc_device_free(const struct lu_env *env,
 	kfree(od);
 	return NULL;
 }
+EXPORT_SYMBOL(osc_device_free);
 
 static struct lu_device *osc_device_alloc(const struct lu_env *env,
 					  struct lu_device_type *t,
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index ffa31d5..9ba3785 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -51,8 +51,8 @@
  *
  */
 
-static int osc_object_init(const struct lu_env *env, struct lu_object *obj,
-			   const struct lu_object_conf *conf)
+int osc_object_init(const struct lu_env *env, struct lu_object *obj,
+		    const struct lu_object_conf *conf)
 {
 	struct osc_object *osc = lu2osc(obj);
 	const struct cl_object_conf *cconf = lu2cl_conf(conf);
@@ -82,8 +82,9 @@ static int osc_object_init(const struct lu_env *env, struct lu_object *obj,
 
 	return 0;
 }
+EXPORT_SYMBOL(osc_object_init);
 
-static void osc_object_free(const struct lu_env *env, struct lu_object *obj)
+void osc_object_free(const struct lu_env *env, struct lu_object *obj)
 {
 	struct osc_object *osc = lu2osc(obj);
 
@@ -105,6 +106,7 @@ static void osc_object_free(const struct lu_env *env, struct lu_object *obj)
 	lu_object_fini(obj);
 	kmem_cache_free(osc_object_kmem, osc);
 }
+EXPORT_SYMBOL(osc_object_free);
 
 int osc_lvb_print(const struct lu_env *env, void *cookie,
 		  lu_printer_t p, const struct ost_lvb *lvb)
@@ -114,9 +116,10 @@ int osc_lvb_print(const struct lu_env *env, void *cookie,
 		    lvb->lvb_size, lvb->lvb_mtime, lvb->lvb_atime,
 		    lvb->lvb_ctime, lvb->lvb_blocks);
 }
+EXPORT_SYMBOL(osc_lvb_print);
 
-static int osc_object_print(const struct lu_env *env, void *cookie,
-			    lu_printer_t p, const struct lu_object *obj)
+int osc_object_print(const struct lu_env *env, void *cookie,
+		     lu_printer_t p, const struct lu_object *obj)
 {
 	struct osc_object *osc = lu2osc(obj);
 	struct lov_oinfo *oinfo = osc->oo_oinfo;
@@ -130,9 +133,10 @@ static int osc_object_print(const struct lu_env *env, void *cookie,
 	osc_lvb_print(env, cookie, p, &oinfo->loi_lvb);
 	return 0;
 }
+EXPORT_SYMBOL(osc_object_print);
 
-static int osc_attr_get(const struct lu_env *env, struct cl_object *obj,
-			struct cl_attr *attr)
+int osc_attr_get(const struct lu_env *env, struct cl_object *obj,
+		 struct cl_attr *attr)
 {
 	struct lov_oinfo *oinfo = cl2osc(obj)->oo_oinfo;
 
@@ -140,9 +144,10 @@ static int osc_attr_get(const struct lu_env *env, struct cl_object *obj,
 	attr->cat_kms = oinfo->loi_kms_valid ? oinfo->loi_kms : 0;
 	return 0;
 }
+EXPORT_SYMBOL(osc_attr_get);
 
-static int osc_attr_update(const struct lu_env *env, struct cl_object *obj,
-			   const struct cl_attr *attr, unsigned int valid)
+int osc_attr_update(const struct lu_env *env, struct cl_object *obj,
+		    const struct cl_attr *attr, unsigned int valid)
 {
 	struct lov_oinfo *oinfo = cl2osc(obj)->oo_oinfo;
 	struct ost_lvb *lvb = &oinfo->loi_lvb;
@@ -164,9 +169,10 @@ static int osc_attr_update(const struct lu_env *env, struct cl_object *obj,
 	}
 	return 0;
 }
+EXPORT_SYMBOL(osc_attr_update);
 
-static int osc_object_glimpse(const struct lu_env *env,
-			      const struct cl_object *obj, struct ost_lvb *lvb)
+int osc_object_glimpse(const struct lu_env *env,
+		       const struct cl_object *obj, struct ost_lvb *lvb)
 {
 	struct lov_oinfo *oinfo = cl2osc(obj)->oo_oinfo;
 
@@ -174,6 +180,7 @@ static int osc_object_glimpse(const struct lu_env *env,
 	lvb->lvb_blocks = oinfo->loi_lvb.lvb_blocks;
 	return 0;
 }
+EXPORT_SYMBOL(osc_object_glimpse);
 
 static int osc_object_ast_clear(struct ldlm_lock *lock, void *data)
 {
-- 
1.8.3.1
