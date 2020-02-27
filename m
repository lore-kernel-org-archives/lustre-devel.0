From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:58 -0500
Subject: [lustre-devel] [PATCH 430/622] lustre: obdecho: reuse an cl env
 cache for obdecho survey
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-431-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <c17817@cray.com>

obdecho environment is already CL_thread type, so
easy to reuse cl_env cache instead of allocate env on each
ioctl call. It reduce cpu usage dramatically.

Cray-bug-id: LUS-7552
WC-bug-id: https://jira.whamcloud.com/browse/LU-12578
Lustre-commit: 55c33b70c46f ("LU-12578 obdecho: reuse an cl env cache for obdecho survey")
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-on: https://review.whamcloud.com/35700
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h   |  9 ++++++
 fs/lustre/obdclass/cl_object.c  |  6 ++--
 fs/lustre/obdclass/lu_object.c  | 68 +++++++++++++++++++++++++++++++++++++++--
 fs/lustre/obdecho/echo_client.c | 28 +++++++++++------
 4 files changed, 97 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 1c1a60f..b00fad8 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1208,6 +1208,14 @@ void *lu_context_key_get(const struct lu_context *ctx,
 void lu_context_key_revive_many(struct lu_context_key *k, ...);
 void lu_context_key_quiesce_many(struct lu_context_key *k, ...);
 
+/*
+ * update/clear ctx/ses tags.
+ */
+void lu_context_tags_update(u32 tags);
+void lu_context_tags_clear(u32 tags);
+void lu_session_tags_update(u32 tags);
+void lu_session_tags_clear(u32 tags);
+
 /**
  * Environment.
  */
@@ -1225,6 +1233,7 @@ struct lu_env {
 int lu_env_init(struct lu_env *env, u32 tags);
 void lu_env_fini(struct lu_env *env);
 int lu_env_refill(struct lu_env *env);
+int lu_env_refill_by_tags(struct lu_env *env, u32 ctags, u32 stags);
 
 struct lu_env *lu_env_find(void);
 int lu_env_add(struct lu_env *env);
diff --git a/fs/lustre/obdclass/cl_object.c b/fs/lustre/obdclass/cl_object.c
index b323eb4..57b3a9a 100644
--- a/fs/lustre/obdclass/cl_object.c
+++ b/fs/lustre/obdclass/cl_object.c
@@ -788,8 +788,10 @@ void cl_env_put(struct lu_env *env, u16 *refcheck)
 		 * with the standard tags.
 		 */
 		if (cl_envs[cpu].cec_count < cl_envs_cached_max &&
-		    (env->le_ctx.lc_tags & ~LCT_HAS_EXIT) == LCT_CL_THREAD &&
-		    (env->le_ses->lc_tags & ~LCT_HAS_EXIT) == LCT_SESSION) {
+		    (env->le_ctx.lc_tags & ~LCT_HAS_EXIT) ==
+			lu_context_tags_default &&
+		    (env->le_ses->lc_tags & ~LCT_HAS_EXIT) ==
+			lu_session_tags_default) {
 			read_lock(&cl_envs[cpu].cec_guard);
 			list_add(&cle->ce_linkage, &cl_envs[cpu].cec_envs);
 			cl_envs[cpu].cec_count++;
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index 6fea1f3..dccff91 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -1778,8 +1778,44 @@ int lu_context_refill(struct lu_context *ctx)
  * predefined when the lu_device type are registered, during the module probe
  * phase.
  */
-u32 lu_context_tags_default;
-u32 lu_session_tags_default;
+u32 lu_context_tags_default = LCT_CL_THREAD;
+u32 lu_session_tags_default = LCT_SESSION;
+
+void lu_context_tags_update(__u32 tags)
+{
+	spin_lock(&lu_context_remembered_guard);
+	lu_context_tags_default |= tags;
+	atomic_inc(&key_set_version);
+	spin_unlock(&lu_context_remembered_guard);
+}
+EXPORT_SYMBOL(lu_context_tags_update);
+
+void lu_context_tags_clear(__u32 tags)
+{
+	spin_lock(&lu_context_remembered_guard);
+	lu_context_tags_default &= ~tags;
+	atomic_inc(&key_set_version);
+	spin_unlock(&lu_context_remembered_guard);
+}
+EXPORT_SYMBOL(lu_context_tags_clear);
+
+void lu_session_tags_update(__u32 tags)
+{
+	spin_lock(&lu_context_remembered_guard);
+	lu_session_tags_default |= tags;
+	atomic_inc(&key_set_version);
+	spin_unlock(&lu_context_remembered_guard);
+}
+EXPORT_SYMBOL(lu_session_tags_update);
+
+void lu_session_tags_clear(__u32 tags)
+{
+	spin_lock(&lu_context_remembered_guard);
+	lu_session_tags_default &= ~tags;
+	atomic_inc(&key_set_version);
+	spin_unlock(&lu_context_remembered_guard);
+}
+EXPORT_SYMBOL(lu_session_tags_clear);
 
 int lu_env_init(struct lu_env *env, u32 tags)
 {
@@ -1801,6 +1837,34 @@ void lu_env_fini(struct lu_env *env)
 }
 EXPORT_SYMBOL(lu_env_fini);
 
+/**
+ * Currently, this API will only be used by echo client.
+ * Because echo client and normal lustre client will share
+ * same cl_env cache. So echo client needs to refresh
+ * the env context after it get one from the cache, especially
+ * when normal client and echo client co-exist in the same client.
+ */
+int lu_env_refill_by_tags(struct lu_env *env, u32 ctags,
+			  u32 stags)
+{
+	int result;
+
+	if ((env->le_ctx.lc_tags & ctags) != ctags) {
+		env->le_ctx.lc_version = 0;
+		env->le_ctx.lc_tags |= ctags;
+	}
+
+	if (env->le_ses && (env->le_ses->lc_tags & stags) != stags) {
+		env->le_ses->lc_version = 0;
+		env->le_ses->lc_tags |= stags;
+	}
+
+	result = lu_env_refill(env);
+
+	return result;
+}
+EXPORT_SYMBOL(lu_env_refill_by_tags);
+
 int lu_env_refill(struct lu_env *env)
 {
 	int result;
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 01d8c04..84823ec 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -50,6 +50,10 @@
  * @{
  */
 
+/* echo thread key have a CL_THREAD flag, which set cl_env function directly */
+#define ECHO_DT_CTX_TAG (LCT_REMEMBER | LCT_DT_THREAD)
+#define ECHO_SES_TAG    (LCT_REMEMBER | LCT_SESSION | LCT_SERVER_SESSION)
+
 struct echo_device {
 	struct cl_device		ed_cl;
 	struct echo_client_obd	       *ed_ec;
@@ -1481,6 +1485,7 @@ static int echo_client_brw_ioctl(const struct lu_env *env, int rw,
 	struct echo_object *eco;
 	struct obd_ioctl_data *data = karg;
 	struct lu_env *env;
+	u16 refcheck;
 	struct obdo *oa;
 	struct lu_fid fid;
 	int rw = OBD_BRW_READ;
@@ -1497,16 +1502,14 @@ static int echo_client_brw_ioctl(const struct lu_env *env, int rw,
 	if (rc < 0)
 		return rc;
 
-	env = kzalloc(sizeof(*env), GFP_NOFS);
-	if (!env)
-		return -ENOMEM;
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return PTR_ERR(env);
 
-	rc = lu_env_init(env, LCT_DT_THREAD);
-	if (rc) {
-		rc = -ENOMEM;
-		goto out;
-	}
 	lu_env_add(env);
+	rc = lu_env_refill_by_tags(env, ECHO_DT_CTX_TAG, ECHO_SES_TAG);
+	if (rc != 0)
+		goto out;
 
 	switch (cmd) {
 	case OBD_IOC_CREATE:		/* may create echo object */
@@ -1574,8 +1577,7 @@ static int echo_client_brw_ioctl(const struct lu_env *env, int rw,
 
 out:
 	lu_env_remove(env);
-	lu_env_fini(env);
-	kfree(env);
+	cl_env_put(env, &refcheck);
 
 	return rc;
 }
@@ -1606,6 +1608,9 @@ static int echo_client_setup(const struct lu_env *env,
 	INIT_LIST_HEAD(&ec->ec_locks);
 	ec->ec_unique = 0;
 
+	lu_context_tags_update(ECHO_DT_CTX_TAG);
+	lu_session_tags_update(ECHO_SES_TAG);
+
 	ocd = kzalloc(sizeof(*ocd), GFP_NOFS);
 	if (!ocd)
 		return -ENOMEM;
@@ -1642,6 +1647,9 @@ static int echo_client_cleanup(struct obd_device *obddev)
 		return -EBUSY;
 	}
 
+	lu_session_tags_clear(ECHO_SES_TAG & ~LCT_SESSION);
+	lu_context_tags_clear(ECHO_DT_CTX_TAG);
+
 	LASSERT(refcount_read(&ec->ec_exp->exp_refcount) > 0);
 	rc = obd_disconnect(ec->ec_exp);
 	if (rc != 0)
-- 
1.8.3.1
