From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:37 -0400
Subject: [lustre-devel] [PATCH 018/151] lustre: osc: prepare OSC code to be
 used from MDC
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhal Pershin <mpershin@whamcloud.com>

Move osc/osc_cl_include.h to include/lustre_osc.h
to be included from both OSC and MDC.

WC-bug-id: https://jira.whamcloud.com/browse/LU-3285
Lustre-commit: 036d987c6d71 ("LU-3285 osc: prepare OSC code to be used from MDC")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/22996
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../osc_cl_internal.h => include/lustre_osc.h}     | 151 ++++++++++++++++-----
 fs/lustre/osc/lproc_osc.c                          |   2 +
 fs/lustre/osc/osc_cache.c                          |   3 +-
 fs/lustre/osc/osc_dev.c                            |  14 +-
 fs/lustre/osc/osc_internal.h                       | 107 +++------------
 fs/lustre/osc/osc_io.c                             |  18 +--
 fs/lustre/osc/osc_lock.c                           |   3 +-
 fs/lustre/osc/osc_object.c                         |  20 +--
 fs/lustre/osc/osc_page.c                           |   4 +-
 fs/lustre/osc/osc_quota.c                          |   2 +
 fs/lustre/osc/osc_request.c                        |   3 +-
 11 files changed, 157 insertions(+), 170 deletions(-)
 rename fs/lustre/{osc/osc_cl_internal.h => include/lustre_osc.h} (86%)

diff --git a/fs/lustre/osc/osc_cl_internal.h b/fs/lustre/include/lustre_osc.h
similarity index 86%
rename from fs/lustre/osc/osc_cl_internal.h
rename to fs/lustre/include/lustre_osc.h
index 5fec6f6..f96583a 100644
--- a/fs/lustre/osc/osc_cl_internal.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -31,22 +31,97 @@
  * Lustre is a trademark of Sun Microsystems, Inc.
  */
 /*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
+ * fs/lustre/include/lustre_osc.h
  *
- * Internal interfaces of OSC layer.
+ * OSC layer structures and methods common for both OSC and MDC.
+ *
+ * This file contains OSC interfaces used by OSC and MDC. Most of them
+ * were just moved from fs/lustre/osc/osc_cl_internal.h for Data-on-MDT
+ * purposes
  *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
- *   Author: Jinshan Xiong <jinshan.xiong@whamcloud.com>
+ *   Author: Jinshan Xiong <jinshan.xiong@gmail.com>
+ *   Author: Mikhail Pershin <mpershin@whamcloud.com>
  */
 
-#ifndef OSC_CL_INTERNAL_H
-#define OSC_CL_INTERNAL_H
+#ifndef LUSTRE_OSC_H
+#define LUSTRE_OSC_H
+
+#include <linux/rhashtable.h>
 
 #include <obd.h>
-/* osc_build_res_name() */
 #include <cl_object.h>
-#include "osc_internal.h"
+
+struct osc_quota_info {
+	/* linkage for quota hash table */
+	struct rhash_head	oqi_hash;
+	u32			oqi_id;
+	struct rcu_head		rcu;
+};
+
+enum async_flags {
+	ASYNC_READY		= 0x1,	/* osc_make_ready will not be called
+					 * before this page is added to an rpc
+					 */
+	ASYNC_URGENT		= 0x2,	/* page must be put into an RPC before
+					 * return
+					 */
+	ASYNC_COUNT_STABLE	= 0x4,	/* osc_refresh_count will not be called
+					 * to give the caller a chance to update
+					 * or cancel the size of the io
+					 */
+	ASYNC_HP = 0x10,
+};
+
+struct osc_async_page {
+	int			oap_magic;
+	unsigned short		oap_cmd;
+
+	struct list_head        oap_pending_item;
+	struct list_head        oap_rpc_item;
+
+	u64			oap_obj_off;
+	unsigned int		oap_page_off;
+	enum async_flags	oap_async_flags;
+
+	struct brw_page		oap_brw_page;
+
+	struct ptlrpc_request	*oap_request;
+	struct client_obd	*oap_cli;
+	struct osc_object	*oap_obj;
+
+	spinlock_t		oap_lock;
+};
+
+#define oap_page	oap_brw_page.pg
+#define oap_count	oap_brw_page.count
+#define oap_brw_flags	oap_brw_page.flag
+
+static inline struct osc_async_page *brw_page2oap(struct brw_page *pga)
+{
+	return container_of(pga, struct osc_async_page, oap_brw_page);
+}
+
+static inline void osc_wake_cache_waiters(struct client_obd *cli)
+{
+	wake_up(&cli->cl_cache_waiters);
+}
+
+struct osc_device {
+	struct cl_device	od_cl;
+	struct obd_export	*od_exp;
+
+	/* Write stats is actually protected by client_obd's lock. */
+	struct osc_stats {
+		u64		os_lockless_writes;	/* by bytes */
+		u64		os_lockless_reads;	/* by bytes */
+		u64		os_lockless_truncates;	/* by times */
+	} od_stats;
+
+	/* configuration item(s) */
+	int			od_contention_time;
+	int			od_lockless_truncate;
+};
 
 /* \defgroup osc osc
  *  @{
@@ -166,6 +241,8 @@ struct osc_object {
 	/* number of active IOs of this object */
 	atomic_t		oo_nr_ios;
 	wait_queue_head_t	oo_io_waitq;
+
+	bool			oo_initialized;
 };
 
 static inline void osc_object_lock(struct osc_object *obj)
@@ -353,21 +430,13 @@ struct osc_page {
 extern struct kmem_cache *osc_thread_kmem;
 extern struct kmem_cache *osc_session_kmem;
 extern struct kmem_cache *osc_extent_kmem;
+extern struct kmem_cache *osc_quota_kmem;
 
-extern struct lu_device_type osc_device_type;
 extern struct lu_context_key osc_key;
 extern struct lu_context_key osc_session_key;
 
 #define OSC_FLAGS (ASYNC_URGENT | ASYNC_READY)
 
-int osc_lock_init(const struct lu_env *env,
-		  struct cl_object *obj, struct cl_lock *lock,
-		  const struct cl_io *io);
-int osc_io_init(const struct lu_env *env,
-		struct cl_object *obj, struct cl_io *io);
-struct lu_object *osc_object_alloc(const struct lu_env *env,
-				   const struct lu_object_header *hdr,
-				   struct lu_device *dev);
 int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_page *page, pgoff_t ind);
 
@@ -413,7 +482,7 @@ void osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
 
 /****************************************************************************
  *
- * Accessors.
+ * Accessors and type conversions.
  *
  */
 
@@ -440,14 +509,8 @@ static inline struct osc_io *osc_env_io(const struct lu_env *env)
 	return &osc_env_session(env)->os_io;
 }
 
-static inline int osc_is_object(const struct lu_object *obj)
-{
-	return obj->lo_dev->ld_type == &osc_device_type;
-}
-
 static inline struct osc_device *lu2osc_dev(const struct lu_device *d)
 {
-	LINVRNT(d->ld_type == &osc_device_type);
 	return container_of(d, struct osc_device, od_cl.cd_lu_dev);
 }
 
@@ -463,7 +526,6 @@ static inline struct client_obd *osc_cli(const struct osc_object *obj)
 
 static inline struct osc_object *cl2osc(const struct cl_object *obj)
 {
-	LINVRNT(osc_is_object(&obj->co_lu));
 	return container_of(obj, struct osc_object, oo_cl);
 }
 
@@ -472,6 +534,36 @@ static inline struct cl_object *osc2cl(const struct osc_object *obj)
 	return (struct cl_object *)&obj->oo_cl;
 }
 
+static inline struct osc_device *obd2osc_dev(const struct obd_device *d)
+{
+	return container_of_safe(d->obd_lu_dev, struct osc_device,
+				 od_cl.cd_lu_dev);
+}
+
+static inline struct lu_device *osc2lu_dev(struct osc_device *osc)
+{
+	return &osc->od_cl.cd_lu_dev;
+}
+
+static inline struct lu_object *osc2lu(struct osc_object *osc)
+{
+	return &osc->oo_cl.co_lu;
+}
+
+static inline struct osc_object *lu2osc(const struct lu_object *obj)
+{
+	return container_of_safe(obj, struct osc_object, oo_cl.co_lu);
+}
+
+static inline struct osc_io *cl2osc_io(const struct lu_env *env,
+				       const struct cl_io_slice *slice)
+{
+	struct osc_io *oio = container_of_safe(slice, struct osc_io, oi_cl);
+
+	LINVRNT(oio == osc_env_io(env));
+	return oio;
+}
+
 static inline enum ldlm_mode osc_cl_lock2ldlm(enum cl_lock_mode mode)
 {
 	LASSERT(mode == CLM_READ || mode == CLM_WRITE || mode == CLM_GROUP);
@@ -496,7 +588,6 @@ static inline enum cl_lock_mode osc_ldlm2cl_lock(enum ldlm_mode mode)
 
 static inline struct osc_page *cl2osc_page(const struct cl_page_slice *slice)
 {
-	LINVRNT(osc_is_object(&slice->cpl_obj->co_lu));
 	return container_of(slice, struct osc_page, ops_cl);
 }
 
@@ -532,15 +623,9 @@ static inline struct osc_page *oap2osc_page(struct osc_async_page *oap)
 
 static inline struct osc_lock *cl2osc_lock(const struct cl_lock_slice *slice)
 {
-	LINVRNT(osc_is_object(&slice->cls_obj->co_lu));
 	return container_of(slice, struct osc_lock, ols_cl);
 }
 
-static inline struct osc_lock *osc_lock_at(const struct cl_lock *lock)
-{
-	return cl2osc_lock(cl_lock_at(lock, &osc_device_type));
-}
-
 static inline int osc_io_srvlock(struct osc_io *oio)
 {
 	return (oio->oi_lockless && !oio->oi_cl.cis_io->ci_no_srvlock);
@@ -667,4 +752,4 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 			  osc_page_gang_cbt cb, void *cbdata);
 /* @} osc */
 
-#endif /* OSC_CL_INTERNAL_H */
+#endif /* LUSTRE_OSC_H */
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index eb724f4..8e85863 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -38,6 +38,8 @@
 #include <obd_class.h>
 #include <lprocfs_status.h>
 #include <linux/seq_file.h>
+#include <lustre_osc.h>
+
 #include "osc_internal.h"
 
 static ssize_t active_show(struct kobject *kobj, struct attribute *attr,
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 46d578e..1d06654 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -38,7 +38,8 @@
 
 #define DEBUG_SUBSYSTEM S_OSC
 
-#include "osc_cl_internal.h"
+#include <lustre_osc.h>
+
 #include "osc_internal.h"
 
 static int extent_debug; /* set it to be true for more debug */
diff --git a/fs/lustre/osc/osc_dev.c b/fs/lustre/osc/osc_dev.c
index 997fa35..080c32c 100644
--- a/fs/lustre/osc/osc_dev.c
+++ b/fs/lustre/osc/osc_dev.c
@@ -39,8 +39,9 @@
 
 /* class_name2obd() */
 #include <obd_class.h>
+#include <lustre_osc.h>
 
-#include "osc_cl_internal.h"
+#include "osc_internal.h"
 
 /** \addtogroup osc
  * @{
@@ -91,17 +92,6 @@ struct lu_kmem_descr osc_caches[] = {
 
 /*****************************************************************************
  *
- * Type conversions.
- *
- */
-
-static struct lu_device *osc2lu_dev(struct osc_device *osc)
-{
-	return &osc->od_cl.cd_lu_dev;
-}
-
-/*****************************************************************************
- *
  * Osc device and device type functions.
  *
  */
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index 95f5b93..af2f237 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -36,70 +36,15 @@
 
 #define OAP_MAGIC 8675309
 
+#include <lustre_osc.h>
+
 extern atomic_t osc_pool_req_count;
 extern unsigned int osc_reqpool_maxreqcount;
 extern struct ptlrpc_request_pool *osc_rq_pool;
 
-struct lu_env;
-
-enum async_flags {
-	ASYNC_READY		= 0x1, /* ap_make_ready will not be
-					* called before this page is
-					* added to an rpc
-					*/
-	ASYNC_URGENT		= 0x2, /* page must be put into an RPC
-					* before return
-					*/
-	ASYNC_COUNT_STABLE	= 0x4, /* ap_refresh_count will not be
-					* called to give the caller a
-					* chance to update or cancel
-					* the size of the io
-					*/
-	ASYNC_HP = 0x10,
-};
-
-struct osc_async_page {
-	int				oap_magic;
-	unsigned short			oap_cmd;
-
-	struct list_head		oap_pending_item;
-	struct list_head		oap_rpc_item;
-
-	u64				oap_obj_off;
-	unsigned int			oap_page_off;
-	enum async_flags		oap_async_flags;
-
-	struct brw_page			oap_brw_page;
-
-	struct ptlrpc_request		*oap_request;
-	struct client_obd		*oap_cli;
-	struct osc_object		*oap_obj;
-
-	spinlock_t			oap_lock;
-};
-
-#define oap_page	oap_brw_page.pg
-#define oap_count	oap_brw_page.count
-#define oap_brw_flags	oap_brw_page.flag
-
-static inline struct osc_async_page *brw_page2oap(struct brw_page *pga)
-{
-	return container_of(pga, struct osc_async_page, oap_brw_page);
-}
-
-static inline void osc_wake_cache_waiters(struct client_obd *cli)
-{
-	wake_up(&cli->cl_cache_waiters);
-}
-
 int osc_shrink_grant_to_target(struct client_obd *cli, u64 target_bytes);
 void osc_update_next_shrink(struct client_obd *cli);
 
-/*
- * cl integration.
- */
-#include <cl_object.h>
-
 typedef int (*osc_enqueue_upcall_f)(void *cookie, struct lustre_handle *lockh,
 				    int rc);
 
@@ -145,6 +90,24 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 
 extern struct lu_device_type osc_device_type;
 
+static inline int osc_is_object(const struct lu_object *obj)
+{
+	return obj->lo_dev->ld_type == &osc_device_type;
+}
+
+static inline struct osc_lock *osc_lock_at(const struct cl_lock *lock)
+{
+	return cl2osc_lock(cl_lock_at(lock, &osc_device_type));
+}
+
+int osc_lock_init(const struct lu_env *env, struct cl_object *obj,
+		  struct cl_lock *lock, const struct cl_io *io);
+int osc_io_init(const struct lu_env *env, struct cl_object *obj,
+		struct cl_io *io);
+struct lu_object *osc_object_alloc(const struct lu_env *env,
+				   const struct lu_object_header *hdr,
+				   struct lu_device *dev);
+
 static inline int osc_recoverable_error(int rc)
 {
 	return (rc == -EIO || rc == -EROFS || rc == -ENOMEM ||
@@ -161,38 +124,8 @@ static inline char *cli_name(struct client_obd *cli)
 	return cli->cl_import->imp_obd->obd_name;
 }
 
-struct osc_device {
-	struct cl_device	od_cl;
-	struct obd_export	*od_exp;
-
-	/* Write stats is actually protected by client_obd's lock. */
-	struct osc_stats {
-		u64	os_lockless_writes;	/* by bytes */
-		u64	os_lockless_reads;	/* by bytes */
-		u64	os_lockless_truncates;	/* by times */
-	}			od_stats;
-
-	/* configuration item(s) */
-	int			od_contention_time;
-	int			od_lockless_truncate;
-};
-
-static inline struct osc_device *obd2osc_dev(const struct obd_device *d)
-{
-	return container_of_safe(d->obd_lu_dev, struct osc_device,
-				 od_cl.cd_lu_dev);
-}
-
 extern struct lu_kmem_descr osc_caches[];
 
-extern struct kmem_cache *osc_quota_kmem;
-struct osc_quota_info {
-	/* linkage for quota hash table */
-	struct rhash_head	oqi_hash;
-	u32			oqi_id;
-	struct rcu_head		rcu;
-};
-
 int osc_quota_setup(struct obd_device *obd);
 int osc_quota_cleanup(struct obd_device *obd);
 int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 0b9ed01..f7169e9 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -39,8 +39,9 @@
 #define DEBUG_SUBSYSTEM S_OSC
 
 #include <lustre_obdo.h>
+#include <lustre_osc.h>
 
-#include "osc_cl_internal.h"
+#include "osc_internal.h"
 
 /** \addtogroup osc
  *  @{
@@ -48,21 +49,6 @@
 
 /*****************************************************************************
  *
- * Type conversions.
- *
- */
-
-static struct osc_io *cl2osc_io(const struct lu_env *env,
-				const struct cl_io_slice *slice)
-{
-	struct osc_io *oio = container_of_safe(slice, struct osc_io, oi_cl);
-
-	LINVRNT(oio == osc_env_io(env));
-	return oio;
-}
-
-/*****************************************************************************
- *
  * io operations.
  *
  */
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 65b734ea..917ae71 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -40,8 +40,9 @@
 
 /* fid_build_reg_res_name() */
 #include <lustre_fid.h>
+#include <lustre_osc.h>
 
-#include "osc_cl_internal.h"
+#include "osc_internal.h"
 
 /** \addtogroup osc
  *  @{
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index 7468729..ffa31d5 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -37,8 +37,9 @@
  */
 
 #define DEBUG_SUBSYSTEM S_OSC
+#include <lustre_osc.h>
 
-#include "osc_cl_internal.h"
+#include "osc_internal.h"
 
 /** \addtogroup osc
  *  @{
@@ -46,23 +47,6 @@
 
 /*****************************************************************************
  *
- * Type conversions.
- *
- */
-
-static struct lu_object *osc2lu(struct osc_object *osc)
-{
-	return &osc->oo_cl.co_lu;
-}
-
-static struct osc_object *lu2osc(const struct lu_object *obj)
-{
-	LINVRNT(osc_is_object(obj));
-	return container_of(obj, struct osc_object, oo_cl.co_lu);
-}
-
-/*****************************************************************************
- *
  * Object operations.
  *
  */
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 8d541df..3576b34 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -39,7 +39,9 @@
 #define DEBUG_SUBSYSTEM S_OSC
 
 #include <linux/math64.h>
-#include "osc_cl_internal.h"
+#include <lustre_osc.h>
+
+#include "osc_internal.h"
 
 static void osc_lru_del(struct client_obd *cli, struct osc_page *opg);
 static void osc_lru_use(struct client_obd *cli, struct osc_page *opg);
diff --git a/fs/lustre/osc/osc_quota.c b/fs/lustre/osc/osc_quota.c
index 5fa85c6..3909e11 100644
--- a/fs/lustre/osc/osc_quota.c
+++ b/fs/lustre/osc/osc_quota.c
@@ -25,6 +25,8 @@
  */
 
 #include <obd_class.h>
+#include <lustre_osc.h>
+
 #include "osc_internal.h"
 
 static const struct rhashtable_params quota_hash_params = {
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index a64b8ab..64c4fd1 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -50,8 +50,9 @@
 #include <lustre_fid.h>
 #include <obd_class.h>
 #include <obd.h>
+#include <lustre_osc.h>
+
 #include "osc_internal.h"
-#include "osc_cl_internal.h"
 
 atomic_t osc_pool_req_count;
 unsigned int osc_reqpool_maxreqcount;
-- 
1.8.3.1
