From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:31:16 -0400
Subject: [lustre-devel] [PATCH 3/8] lustre: obdclass: Code cleanup
In-Reply-To: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
References: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205481-6899-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Ben Evans <bevans@cray.com>

Remove uuid.c, and unroll class_uuid_unparse
Rewrite CL_ENV_INC and DEC
Remove D_KUC #define

Signed-off-by: Ben Evans <bevans@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9855
Reviewed-on: https://review.whamcloud.com/28458
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd_class.h  | 40 +++++++------------
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  3 +-
 drivers/staging/lustre/lustre/obdclass/Makefile    |  5 +--
 drivers/staging/lustre/lustre/obdclass/cl_object.c | 21 ++++++----
 drivers/staging/lustre/lustre/obdclass/class_obd.c |  1 -
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |  7 ++--
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |  2 +-
 drivers/staging/lustre/lustre/obdclass/uuid.c      | 45 ----------------------
 8 files changed, 34 insertions(+), 90 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/obdclass/uuid.c

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 39a5eca..c6fb2e1 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -497,9 +497,9 @@ static inline int obd_set_info_async(const struct lu_env *env,
 
 static inline int obd_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 {
-	int rc;
 	struct lu_device_type *ldt;
 	struct lu_device *d;
+	int rc;
 
 	ldt = obd->obd_type->typ_lu;
 	if (ldt) {
@@ -536,15 +536,10 @@ static inline int obd_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 
 static inline int obd_precleanup(struct obd_device *obd)
 {
+	struct lu_device_type *ldt = obd->obd_type->typ_lu;
+	struct lu_device *d = obd->obd_lu_dev;
 	int rc;
-	struct lu_device_type *ldt;
-	struct lu_device *d;
 
-	rc = obd_check_dev(obd);
-	if (rc)
-		return rc;
-	ldt = obd->obd_type->typ_lu;
-	d = obd->obd_lu_dev;
 	if (ldt && d) {
 		struct lu_env env;
 
@@ -563,16 +558,10 @@ static inline int obd_precleanup(struct obd_device *obd)
 
 static inline int obd_cleanup(struct obd_device *obd)
 {
+	struct lu_device_type *ldt = obd->obd_type->typ_lu;
+	struct lu_device *d = obd->obd_lu_dev;
 	int rc;
-	struct lu_device_type *ldt;
-	struct lu_device *d;
 
-	rc = obd_check_dev(obd);
-	if (rc)
-		return rc;
-
-	ldt = obd->obd_type->typ_lu;
-	d = obd->obd_lu_dev;
 	if (ldt && d) {
 		struct lu_env env;
 
@@ -613,17 +602,11 @@ static inline void obd_cleanup_client_import(struct obd_device *obd)
 static inline int
 obd_process_config(struct obd_device *obd, int datalen, void *data)
 {
+	struct lu_device_type *ldt = obd->obd_type->typ_lu;
+	struct lu_device *d = obd->obd_lu_dev;
 	int rc;
-	struct lu_device_type *ldt;
-	struct lu_device *d;
-
-	rc = obd_check_dev(obd);
-	if (rc)
-		return rc;
 
 	obd->obd_process_conf = 1;
-	ldt = obd->obd_type->typ_lu;
-	d = obd->obd_lu_dev;
 	if (ldt && d) {
 		struct lu_env env;
 
@@ -1554,9 +1537,12 @@ struct lwp_register_item {
 /* obd_mount.c */
 int lustre_check_exclusion(struct super_block *sb, char *svname);
 
-/* uuid.c  */
-typedef __u8 class_uuid_t[16];
-void class_uuid_unparse(class_uuid_t in, struct obd_uuid *out);
+typedef u8 class_uuid_t[16];
+
+static inline void class_uuid_unparse(class_uuid_t uu, struct obd_uuid *out)
+{
+	sprintf(out->uuid, "%pU", uu);
+}
 
 /* lustre_peer.c    */
 int lustre_uuid_to_peer(const char *uuid, lnet_nid_t *peer_nid, int index);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 3de6e886..22b545e 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -98,7 +98,8 @@ static struct ll_sb_info *ll_init_sbi(void)
 					   SBI_DEFAULT_READAHEAD_WHOLE_MAX;
 
 	ll_generate_random_uuid(uuid);
-	class_uuid_unparse(uuid, &sbi->ll_sb_uuid);
+	sprintf(sbi->ll_sb_uuid.uuid, "%pU", uuid);
+
 	CDEBUG(D_CONFIG, "generated uuid: %s\n", sbi->ll_sb_uuid.uuid);
 
 	sbi->ll_flags |= LL_SBI_VERBOSE;
diff --git a/drivers/staging/lustre/lustre/obdclass/Makefile b/drivers/staging/lustre/lustre/obdclass/Makefile
index 19c8bd9..b1fac48 100644
--- a/drivers/staging/lustre/lustre/obdclass/Makefile
+++ b/drivers/staging/lustre/lustre/obdclass/Makefile
@@ -4,9 +4,8 @@ ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += obdclass.o
 
-obdclass-y := obd_sysfs.o \
-	      llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o debug.o \
-	      genops.o uuid.o lprocfs_status.o lprocfs_counters.o \
+obdclass-y := llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o debug.o \
+	      genops.o obd_sysfs.o lprocfs_status.o lprocfs_counters.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
 	      obdo.o obd_config.o obd_mount.o lu_object.o lu_ref.o \
 	      cl_object.o cl_page.o cl_lock.o cl_io.o kernelcomm.o
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index d1d7bec..09fc7e7 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -572,8 +572,13 @@ struct cl_env {
 	void	     *ce_debug;
 };
 
-#define CL_ENV_INC(counter)
-#define CL_ENV_DEC(counter)
+static void cl_env_inc(enum cache_stats_item item)
+{
+}
+
+static void cl_env_dec(enum cache_stats_item item)
+{
+}
 
 static void cl_env_init0(struct cl_env *cle, void *debug)
 {
@@ -583,7 +588,7 @@ static void cl_env_init0(struct cl_env *cle, void *debug)
 
 	cle->ce_ref = 1;
 	cle->ce_debug = debug;
-	CL_ENV_INC(busy);
+	cl_env_inc(CS_busy);
 }
 
 static struct lu_env *cl_env_new(__u32 ctx_tags, __u32 ses_tags, void *debug)
@@ -614,8 +619,8 @@ static struct lu_env *cl_env_new(__u32 ctx_tags, __u32 ses_tags, void *debug)
 			kmem_cache_free(cl_env_kmem, cle);
 			env = ERR_PTR(rc);
 		} else {
-			CL_ENV_INC(create);
-			CL_ENV_INC(total);
+			cl_env_inc(CS_create);
+			cl_env_inc(CS_total);
 		}
 	} else {
 		env = ERR_PTR(-ENOMEM);
@@ -625,7 +630,7 @@ static struct lu_env *cl_env_new(__u32 ctx_tags, __u32 ses_tags, void *debug)
 
 static void cl_env_fini(struct cl_env *cle)
 {
-	CL_ENV_DEC(total);
+	cl_env_dec(CS_total);
 	lu_context_fini(&cle->ce_lu.le_ctx);
 	lu_context_fini(&cle->ce_ses);
 	kmem_cache_free(cl_env_kmem, cle);
@@ -781,7 +786,7 @@ void cl_env_put(struct lu_env *env, u16 *refcheck)
 	if (--cle->ce_ref == 0) {
 		int cpu = get_cpu();
 
-		CL_ENV_DEC(busy);
+		cl_env_dec(CS_busy);
 		cle->ce_debug = NULL;
 		cl_env_exit(cle);
 		/*
@@ -902,7 +907,7 @@ void cl_env_percpu_put(struct lu_env *env)
 	cle->ce_ref--;
 	LASSERT(cle->ce_ref == 0);
 
-	CL_ENV_DEC(busy);
+	cl_env_dec(CS_busy);
 	cle->ce_debug = NULL;
 
 	put_cpu();
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 2d23608..2103d2a 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -585,7 +585,6 @@ static long obd_class_ioctl(struct file *filp, unsigned int cmd,
 	.fops	= &obd_psdev_fops,
 };
 
-#define OBD_INIT_CHECK
 static int obd_init_checks(void)
 {
 	__u64 u64val, div64val;
diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index 0fcfecf..3b006df 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -37,7 +37,6 @@
  */
 
 #define DEBUG_SUBSYSTEM S_CLASS
-#define D_KUC D_OTHER
 
 #include <linux/file.h>
 #include <linux/libcfs/libcfs.h>
@@ -77,7 +76,7 @@ int libcfs_kkuc_msg_put(struct file *filp, void *payload)
 	if (rc < 0)
 		CWARN("message send failed (%d)\n", rc);
 	else
-		CDEBUG(D_KUC, "Sent message rc=%d, fp=%p\n", rc, filp);
+		CDEBUG(D_HSM, "Sent message rc=%d, fp=%p\n", rc, filp);
 
 	return rc;
 }
@@ -146,7 +145,7 @@ int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
 	list_add(&reg->kr_chain, &kkuc_groups[group]);
 	up_write(&kg_sem);
 
-	CDEBUG(D_KUC, "Added uid=%d fp=%p to group %d\n", uid, filp, group);
+	CDEBUG(D_HSM, "Added uid=%d fp=%p to group %d\n", uid, filp, group);
 
 	return 0;
 }
@@ -176,7 +175,7 @@ int libcfs_kkuc_group_rem(int uid, unsigned int group)
 	list_for_each_entry_safe(reg, next, &kkuc_groups[group], kr_chain) {
 		if (!uid || (uid == reg->kr_uid)) {
 			list_del(&reg->kr_chain);
-			CDEBUG(D_KUC, "Removed uid=%d fp=%p from group %d\n",
+			CDEBUG(D_HSM, "Removed uid=%d fp=%p from group %d\n",
 			       reg->kr_uid, reg->kr_fp, group);
 			if (reg->kr_fp)
 				fput(reg->kr_fp);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index f59e7c4..33a67fd 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -336,7 +336,7 @@ int lustre_start_mgc(struct super_block *sb)
 	}
 
 	ll_generate_random_uuid(uuidc);
-	class_uuid_unparse(uuidc, uuid);
+	sprintf(uuid->uuid, "%pU", uuidc);
 
 	/* Start the MGC */
 	rc = lustre_start_simple(mgcname, LUSTRE_MGC_NAME,
diff --git a/drivers/staging/lustre/lustre/obdclass/uuid.c b/drivers/staging/lustre/lustre/obdclass/uuid.c
deleted file mode 100644
index ec8c6dc..0000000
--- a/drivers/staging/lustre/lustre/obdclass/uuid.c
+++ /dev/null
@@ -1,45 +0,0 @@
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
- * lustre/obdclass/uuid.c
- *
- * Public include file for the UUID library
- */
-
-#define DEBUG_SUBSYSTEM S_CLASS
-
-#include <obd_support.h>
-#include <obd_class.h>
-
-void class_uuid_unparse(class_uuid_t uu, struct obd_uuid *out)
-{
-	sprintf(out->uuid, "%pU", uu);
-}
-EXPORT_SYMBOL(class_uuid_unparse);
-- 
1.8.3.1
