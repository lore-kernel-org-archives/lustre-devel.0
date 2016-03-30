From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:48:09 -0400
Subject: [lustre-devel] [PATCH 37/43] staging/lustre/llite: Remove
	ccc_global_{init, fini}()
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-38-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, John Hammond <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: John Hammond <john.hammond@intel.com>

Merge their contents into vvp_global_{init,fini}() and
{init,exit}_lustre_lite().
Rename ccc_inode_fini_* to cl_inode_fini_*.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/13714
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5971
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   | 53 +++++-----------------
 .../staging/lustre/lustre/llite/llite_internal.h   |  7 +--
 drivers/staging/lustre/lustre/llite/super25.c      | 14 +++++-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      | 25 ++++++----
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  4 +-
 5 files changed, 46 insertions(+), 57 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 5b523e33..164737a 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -72,49 +72,18 @@
  */
 
 /**
- * An `emergency' environment used by ccc_inode_fini() when cl_env_get()
- * fails. Access to this environment is serialized by ccc_inode_fini_guard
+ * An `emergency' environment used by cl_inode_fini() when cl_env_get()
+ * fails. Access to this environment is serialized by cl_inode_fini_guard
  * mutex.
  */
-static struct lu_env *ccc_inode_fini_env;
+struct lu_env *cl_inode_fini_env;
+int cl_inode_fini_refcheck;
 
 /**
  * A mutex serializing calls to slp_inode_fini() under extreme memory
  * pressure, when environments cannot be allocated.
  */
-static DEFINE_MUTEX(ccc_inode_fini_guard);
-static int dummy_refcheck;
-
-int ccc_global_init(struct lu_device_type *device_type)
-{
-	int result;
-
-	result = lu_device_type_init(device_type);
-	if (result)
-		return result;
-
-	ccc_inode_fini_env = cl_env_alloc(&dummy_refcheck,
-					  LCT_REMEMBER | LCT_NOREF);
-	if (IS_ERR(ccc_inode_fini_env)) {
-		result = PTR_ERR(ccc_inode_fini_env);
-		goto out_device;
-	}
-
-	ccc_inode_fini_env->le_ctx.lc_cookie = 0x4;
-	return 0;
-out_device:
-	lu_device_type_fini(device_type);
-	return result;
-}
-
-void ccc_global_fini(struct lu_device_type *device_type)
-{
-	if (ccc_inode_fini_env) {
-		cl_env_put(ccc_inode_fini_env, &dummy_refcheck);
-		ccc_inode_fini_env = NULL;
-	}
-	lu_device_type_fini(device_type);
-}
+static DEFINE_MUTEX(cl_inode_fini_guard);
 
 int cl_setattr_ost(struct inode *inode, const struct iattr *attr)
 {
@@ -286,10 +255,10 @@ void cl_inode_fini(struct inode *inode)
 		env = cl_env_get(&refcheck);
 		emergency = IS_ERR(env);
 		if (emergency) {
-			mutex_lock(&ccc_inode_fini_guard);
-			LASSERT(ccc_inode_fini_env);
-			cl_env_implant(ccc_inode_fini_env, &refcheck);
-			env = ccc_inode_fini_env;
+			mutex_lock(&cl_inode_fini_guard);
+			LASSERT(cl_inode_fini_env);
+			cl_env_implant(cl_inode_fini_env, &refcheck);
+			env = cl_inode_fini_env;
 		}
 		/*
 		 * cl_object cache is a slave to inode cache (which, in turn
@@ -301,8 +270,8 @@ void cl_inode_fini(struct inode *inode)
 		cl_object_put_last(env, clob);
 		lli->lli_clob = NULL;
 		if (emergency) {
-			cl_env_unplant(ccc_inode_fini_env, &refcheck);
-			mutex_unlock(&ccc_inode_fini_guard);
+			cl_env_unplant(cl_inode_fini_env, &refcheck);
+			mutex_unlock(&cl_inode_fini_guard);
 		} else {
 			cl_env_put(env, &refcheck);
 		}
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index a6ee2fe..993cee8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -984,9 +984,6 @@ void free_rmtperm_hash(struct hlist_head *hash);
 int ll_update_remote_perm(struct inode *inode, struct mdt_remote_perm *perm);
 int lustre_check_remote_perm(struct inode *inode, int mask);
 
-/* llite/llite_cl.c */
-extern struct lu_device_type vvp_device_type;
-
 /**
  * Common IO arguments for various VFS I/O interfaces.
  */
@@ -1371,4 +1368,8 @@ void ll_xattr_fini(void);
 int ll_page_sync_io(const struct lu_env *env, struct cl_io *io,
 		    struct cl_page *page, enum cl_req_type crt);
 
+/* lcommon_cl.c */
+extern struct lu_env *cl_inode_fini_env;
+extern int cl_inode_fini_refcheck;
+
 #endif /* LLITE_INTERNAL_H */
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 61856d3..415750b 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -164,9 +164,18 @@ static int __init lustre_init(void)
 	if (rc != 0)
 		goto out_sysfs;
 
+	cl_inode_fini_env = cl_env_alloc(&cl_inode_fini_refcheck,
+					 LCT_REMEMBER | LCT_NOREF);
+	if (IS_ERR(cl_inode_fini_env)) {
+		rc = PTR_ERR(cl_inode_fini_env);
+		goto out_vvp;
+	}
+
+	cl_inode_fini_env->le_ctx.lc_cookie = 0x4;
+
 	rc = ll_xattr_init();
 	if (rc != 0)
-		goto out_vvp;
+		goto out_inode_fini_env;
 
 	lustre_register_client_fill_super(ll_fill_super);
 	lustre_register_kill_super_cb(ll_kill_super);
@@ -174,6 +183,8 @@ static int __init lustre_init(void)
 
 	return 0;
 
+out_inode_fini_env:
+	cl_env_put(cl_inode_fini_env, &cl_inode_fini_refcheck);
 out_vvp:
 	vvp_global_fini();
 out_sysfs:
@@ -198,6 +209,7 @@ static void __exit lustre_exit(void)
 	kset_unregister(llite_kset);
 
 	ll_xattr_fini();
+	cl_env_put(cl_inode_fini_env, &cl_inode_fini_refcheck);
 	vvp_global_fini();
 
 	kmem_cache_destroy(ll_inode_cachep);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index c27cb1a..2b1025c 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -298,20 +298,27 @@ struct lu_device_type vvp_device_type = {
  */
 int vvp_global_init(void)
 {
-	int result;
+	int rc;
 
-	result = lu_kmem_init(vvp_caches);
-	if (result == 0) {
-		result = ccc_global_init(&vvp_device_type);
-		if (result != 0)
-			lu_kmem_fini(vvp_caches);
-	}
-	return result;
+	rc = lu_kmem_init(vvp_caches);
+	if (rc != 0)
+		return rc;
+
+	rc = lu_device_type_init(&vvp_device_type);
+	if (rc != 0)
+		goto out_kmem;
+
+	return 0;
+
+out_kmem:
+	lu_kmem_fini(vvp_caches);
+
+	return rc;
 }
 
 void vvp_global_fini(void)
 {
-	ccc_global_fini(&vvp_device_type);
+	lu_device_type_fini(&vvp_device_type);
 	lu_kmem_fini(vvp_caches);
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 0e15202..fe29fb5 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -164,6 +164,8 @@ struct vvp_io {
 	bool		vui_ra_valid;
 };
 
+extern struct lu_device_type vvp_device_type;
+
 extern struct lu_context_key vvp_session_key;
 extern struct lu_context_key vvp_thread_key;
 
@@ -324,8 +326,6 @@ void ccc_key_fini(const struct lu_context *ctx,
 		  struct lu_context_key *key, void *data);
 
 void ccc_umount(const struct lu_env *env, struct cl_device *dev);
-int ccc_global_init(struct lu_device_type *device_type);
-void ccc_global_fini(struct lu_device_type *device_type);
 
 static inline struct lu_device *vvp2lu_dev(struct vvp_device *vdv)
 {
-- 
2.1.0
