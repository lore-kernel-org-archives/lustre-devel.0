From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:53 -0500
Subject: [lustre-devel] [PATCH 125/622] lustre: osc: move obdo_cache to OSC
 code
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-126-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

The obdo_cache slab is only used by the OSC code today, so it does
not need to be allocated in obdclass on servers.  Move it to only
be allocated when the OSC module is loaded.

Rename obdo_cachep to osc_obdo_kmem to match other slab caches
created by the OSC.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10899
Lustre-commit: 48df66be72c9 ("LU-10899 osc: move obdo_cache to OSC code")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33141
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  1 +
 fs/lustre/include/obd_class.h  |  3 ---
 fs/lustre/obdclass/genops.c    | 10 ----------
 fs/lustre/osc/osc_dev.c        |  8 ++++++--
 fs/lustre/osc/osc_request.c    | 11 +++++------
 5 files changed, 12 insertions(+), 21 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index dc8071a..dabcee0 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -557,6 +557,7 @@ struct osc_brw_async_args {
 extern struct kmem_cache *osc_session_kmem;
 extern struct kmem_cache *osc_extent_kmem;
 extern struct kmem_cache *osc_quota_kmem;
+extern struct kmem_cache *osc_obdo_kmem;
 
 extern struct lu_context_key osc_key;
 extern struct lu_context_key osc_session_key;
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index a3ef5d5..01eb385 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1651,9 +1651,6 @@ static inline int md_unpackmd(struct obd_export *exp,
 int obd_init_caches(void);
 void obd_cleanup_caches(void);
 
-/* support routines */
-extern struct kmem_cache *obdo_cachep;
-
 typedef int (*register_lwp_cb)(void *data);
 
 struct lwp_register_item {
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index a122332..e5e2f73 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -46,8 +46,6 @@
 static struct obd_device *obd_devs[MAX_OBD_DEVICES];
 
 static struct kmem_cache *obd_device_cachep;
-struct kmem_cache *obdo_cachep;
-EXPORT_SYMBOL(obdo_cachep);
 
 static struct kobj_type class_ktype;
 static struct workqueue_struct *zombie_wq;
@@ -645,8 +643,6 @@ void obd_cleanup_caches(void)
 {
 	kmem_cache_destroy(obd_device_cachep);
 	obd_device_cachep = NULL;
-	kmem_cache_destroy(obdo_cachep);
-	obdo_cachep = NULL;
 }
 
 int obd_init_caches(void)
@@ -658,12 +654,6 @@ int obd_init_caches(void)
 	if (!obd_device_cachep)
 		goto out;
 
-	LASSERT(!obdo_cachep);
-	obdo_cachep = kmem_cache_create("ll_obdo_cache", sizeof(struct obdo),
-					0, 0, NULL);
-	if (!obdo_cachep)
-		goto out;
-
 	return 0;
 out:
 	obd_cleanup_caches();
diff --git a/fs/lustre/osc/osc_dev.c b/fs/lustre/osc/osc_dev.c
index 3d0687a..b8bf75a 100644
--- a/fs/lustre/osc/osc_dev.c
+++ b/fs/lustre/osc/osc_dev.c
@@ -55,9 +55,8 @@
 struct kmem_cache *osc_thread_kmem;
 struct kmem_cache *osc_session_kmem;
 struct kmem_cache *osc_extent_kmem;
-EXPORT_SYMBOL(osc_extent_kmem);
 struct kmem_cache *osc_quota_kmem;
-EXPORT_SYMBOL(osc_quota_kmem);
+struct kmem_cache *osc_obdo_kmem;
 
 struct lu_kmem_descr osc_caches[] = {
 	{
@@ -91,6 +90,11 @@ struct lu_kmem_descr osc_caches[] = {
 		.ckd_size  = sizeof(struct osc_quota_info)
 	},
 	{
+		.ckd_cache = &osc_obdo_kmem,
+		.ckd_name  = "osc_obdo_kmem",
+		.ckd_size  = sizeof(struct obdo)
+	},
+	{
 		.ckd_cache = NULL
 	}
 };
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 2784e1e..e968360 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -749,7 +749,7 @@ static int osc_shrink_grant_interpret(const struct lu_env *env,
 	LASSERT(body);
 	osc_update_grant(cli, body);
 out:
-	kmem_cache_free(obdo_cachep, oa);
+	kmem_cache_free(osc_obdo_kmem, oa);
 	return rc;
 }
 
@@ -2115,7 +2115,7 @@ static int brw_interpret(const struct lu_env *env,
 			cl_object_attr_update(env, obj, attr, valid);
 		cl_object_attr_unlock(obj);
 	}
-	kmem_cache_free(obdo_cachep, aa->aa_oa);
+	kmem_cache_free(osc_obdo_kmem, aa->aa_oa);
 
 	if (lustre_msg_get_opc(req->rq_reqmsg) == OST_WRITE && rc == 0)
 		osc_inc_unstable_pages(req);
@@ -2223,7 +2223,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		goto out;
 	}
 
-	oa = kmem_cache_zalloc(obdo_cachep, GFP_NOFS);
+	oa = kmem_cache_zalloc(osc_obdo_kmem, GFP_NOFS);
 	if (!oa) {
 		rc = -ENOMEM;
 		goto out;
@@ -2349,8 +2349,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	if (rc != 0) {
 		LASSERT(!req);
 
-		if (oa)
-			kmem_cache_free(obdo_cachep, oa);
+		kmem_cache_free(osc_obdo_kmem, oa);
 		kfree(pga);
 		/* this should happen rarely and is pretty bad, it makes the
 		 * pending list not follow the dirty order
@@ -2960,7 +2959,7 @@ int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		struct obdo *oa;
 
 		aa = ptlrpc_req_async_args(aa, req);
-		oa = kmem_cache_zalloc(obdo_cachep, GFP_NOFS);
+		oa = kmem_cache_zalloc(osc_obdo_kmem, GFP_NOFS);
 		if (!oa) {
 			ptlrpc_req_finished(req);
 			return -ENOMEM;
-- 
1.8.3.1
