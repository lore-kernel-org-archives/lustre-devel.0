From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:43 -0500
Subject: [lustre-devel] [PATCH 295/622] lustre: obdclass: put all service's
 env on the list
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-296-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

to be able to lookup by current thread where it's too
complicated to pass env by argument.

this version has stats to see slow/fast lookups. so, in sanity-benchmark
there were 172850 fast lookups (from per-cpu cache) and 27228 slow lookups
(from rhashtable). going to see the ration in autotest's reports.

Fixes: 8a9e013dad74 ("lustre: ldlm: pass env to lvbo methods")

WC-bug-id: https://jira.whamcloud.com/browse/LU-12034
Lustre-commit: aa82cc83612d ("LU-12034 obdclass: put all service's env on the list")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34566
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h   |   4 ++
 fs/lustre/include/obd_class.h   |  19 +++++---
 fs/lustre/ldlm/ldlm_lockd.c     |  20 +++++++-
 fs/lustre/obdclass/lu_object.c  | 104 +++++++++++++++++++++++++++++++++++++++-
 fs/lustre/obdecho/echo_client.c |   2 +
 fs/lustre/ptlrpc/service.c      |  20 ++++----
 6 files changed, 153 insertions(+), 16 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index a709ad7..c34605c 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1213,6 +1213,10 @@ struct lu_env {
 void lu_env_fini(struct lu_env *env);
 int lu_env_refill(struct lu_env *env);
 
+struct lu_env *lu_env_find(void);
+int lu_env_add(struct lu_env *env);
+void lu_env_remove(struct lu_env *env);
+
 /** @} lu_context */
 
 /**
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index a142d6e..a890d00 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -477,12 +477,19 @@ static inline int obd_precleanup(struct obd_device *obd)
 	int rc;
 
 	if (ldt && d) {
-		struct lu_env env;
-
-		rc = lu_env_init(&env, ldt->ldt_ctx_tags);
-		if (!rc) {
-			ldt->ldt_ops->ldto_device_fini(&env, d);
-			lu_env_fini(&env);
+		struct lu_env *env = lu_env_find();
+		struct lu_env _env;
+
+		if (!env) {
+			env = &_env;
+			rc = lu_env_init(env, ldt->ldt_ctx_tags);
+			LASSERT(!rc);
+			lu_env_add(env);
+		}
+		ldt->ldt_ops->ldto_device_fini(env, d);
+		if (env == &_env) {
+			lu_env_remove(env);
+			lu_env_fini(env);
 		}
 	}
 	if (!obd->obd_type->typ_dt_ops->precleanup)
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index f37d8ef..3b405be 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -846,8 +846,20 @@ static int ldlm_bl_thread_blwi(struct ldlm_bl_pool *blp,
  */
 static int ldlm_bl_thread_main(void *arg)
 {
+	struct lu_env *env;
 	struct ldlm_bl_pool *blp;
 	struct ldlm_bl_thread_data *bltd = arg;
+	int rc;
+
+	env = kzalloc(sizeof(*env), GFP_NOFS);
+	if (!env)
+		return -ENOMEM;
+	rc = lu_env_init(env, LCT_DT_THREAD);
+	if (rc)
+		goto out_env;
+	rc = lu_env_add(env);
+	if (rc)
+		goto out_env_fini;
 
 	blp = bltd->bltd_blp;
 
@@ -888,7 +900,13 @@ static int ldlm_bl_thread_main(void *arg)
 
 	atomic_dec(&blp->blp_num_threads);
 	complete(&blp->blp_comp);
-	return 0;
+
+	lu_env_remove(env);
+out_env_fini:
+	lu_env_fini(env);
+out_env:
+	kfree(env);
+	return rc;
 }
 
 static int ldlm_setup(void);
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index 2ab4977..2f709b0 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -1859,6 +1859,101 @@ static unsigned long lu_cache_shrink_scan(struct shrinker *sk,
 /**
  * Debugging printer function using printk().
  */
+
+struct lu_env_item {
+	struct task_struct	*lei_task;	/* rhashtable key */
+	struct rhash_head	lei_linkage;
+	struct lu_env		*lei_env;
+};
+
+static const struct rhashtable_params lu_env_rhash_params = {
+	.key_len     = sizeof(struct task_struct *),
+	.key_offset  = offsetof(struct lu_env_item, lei_task),
+	.head_offset = offsetof(struct lu_env_item, lei_linkage),
+};
+
+struct rhashtable lu_env_rhash;
+
+struct lu_env_percpu {
+	struct task_struct *lep_task;
+	struct lu_env *lep_env ____cacheline_aligned_in_smp;
+};
+
+static struct lu_env_percpu lu_env_percpu[NR_CPUS];
+
+int lu_env_add(struct lu_env *env)
+{
+	struct lu_env_item *lei, *old;
+
+	LASSERT(env);
+
+	lei = kzalloc(sizeof(*lei), GFP_NOFS);
+	if (!lei)
+		return -ENOMEM;
+
+	lei->lei_task = current;
+	lei->lei_env = env;
+
+	old = rhashtable_lookup_get_insert_fast(&lu_env_rhash,
+						&lei->lei_linkage,
+						lu_env_rhash_params);
+	LASSERT(!old);
+
+	return 0;
+}
+EXPORT_SYMBOL(lu_env_add);
+
+void lu_env_remove(struct lu_env *env)
+{
+	struct lu_env_item *lei;
+	const void *task = current;
+	int i;
+
+	for_each_possible_cpu(i) {
+		if (lu_env_percpu[i].lep_env == env) {
+			LASSERT(lu_env_percpu[i].lep_task == task);
+			lu_env_percpu[i].lep_task = NULL;
+			lu_env_percpu[i].lep_env = NULL;
+		}
+	}
+
+	rcu_read_lock();
+	lei = rhashtable_lookup_fast(&lu_env_rhash, &task,
+				     lu_env_rhash_params);
+	if (lei && rhashtable_remove_fast(&lu_env_rhash, &lei->lei_linkage,
+					  lu_env_rhash_params) == 0)
+		kfree(lei);
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL(lu_env_remove);
+
+struct lu_env *lu_env_find(void)
+{
+	struct lu_env *env = NULL;
+	struct lu_env_item *lei;
+	const void *task = current;
+	int i = get_cpu();
+
+	if (lu_env_percpu[i].lep_task == current) {
+		env = lu_env_percpu[i].lep_env;
+		put_cpu();
+		LASSERT(env);
+		return env;
+	}
+
+	lei = rhashtable_lookup_fast(&lu_env_rhash, &task,
+				     lu_env_rhash_params);
+	if (lei) {
+		env = lei->lei_env;
+		lu_env_percpu[i].lep_task = current;
+		lu_env_percpu[i].lep_env = env;
+	}
+	put_cpu();
+
+	return env;
+}
+EXPORT_SYMBOL(lu_env_find);
+
 static struct shrinker lu_site_shrinker = {
 	.count_objects		= lu_cache_shrink_count,
 	.scan_objects		= lu_cache_shrink_scan,
@@ -1905,6 +2000,11 @@ int lu_global_init(void)
 	 * lu_object/inode cache consuming all the memory.
 	 */
 	result = register_shrinker(&lu_site_shrinker);
+	if (result == 0) {
+		result = rhashtable_init(&lu_env_rhash, &lu_env_rhash_params);
+		if (result != 0)
+			unregister_shrinker(&lu_site_shrinker);
+	}
 	if (result != 0) {
 		/* Order explained in lu_global_fini(). */
 		lu_context_key_degister(&lu_global_key);
@@ -1917,7 +2017,7 @@ int lu_global_init(void)
 		return result;
 	}
 
-	return 0;
+	return result;
 }
 
 /**
@@ -1936,6 +2036,8 @@ void lu_global_fini(void)
 	lu_env_fini(&lu_shrink_env);
 	up_write(&lu_sites_guard);
 
+	rhashtable_destroy(&lu_env_rhash);
+
 	lu_ref_global_fini();
 }
 
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 5ac4519..01d8c04 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -1506,6 +1506,7 @@ static int echo_client_brw_ioctl(const struct lu_env *env, int rw,
 		rc = -ENOMEM;
 		goto out;
 	}
+	lu_env_add(env);
 
 	switch (cmd) {
 	case OBD_IOC_CREATE:		/* may create echo object */
@@ -1572,6 +1573,7 @@ static int echo_client_brw_ioctl(const struct lu_env *env, int rw,
 	}
 
 out:
+	lu_env_remove(env);
 	lu_env_fini(env);
 	kfree(env);
 
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 1513f51..d93cf14 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -2194,11 +2194,14 @@ static int ptlrpc_main(void *arg)
 		rc = -ENOMEM;
 		goto out_srv_fini;
 	}
+	rc = lu_env_add(env);
+	if (rc)
+		goto out_env;
 
 	rc = lu_context_init(&env->le_ctx,
 			     svc->srv_ctx_tags | LCT_REMEMBER | LCT_NOREF);
 	if (rc)
-		goto out_srv_fini;
+		goto out_env_remove;
 
 	thread->t_env = env;
 	env->le_ctx.lc_thread = thread;
@@ -2211,14 +2214,14 @@ static int ptlrpc_main(void *arg)
 
 		CERROR("Failed to post rqbd for %s on CPT %d: %d\n",
 		       svc->srv_name, svcpt->scp_cpt, rc);
-		goto out_srv_fini;
+		goto out_ctx_fini;
 	}
 
 	/* Alloc reply state structure for this one */
 	rs = kvzalloc(svc->srv_max_reply_size, GFP_KERNEL);
 	if (!rs) {
 		rc = -ENOMEM;
-		goto out_srv_fini;
+		goto out_ctx_fini;
 	}
 
 	spin_lock(&svcpt->scp_lock);
@@ -2310,15 +2313,16 @@ static int ptlrpc_main(void *arg)
 
 	ptlrpc_watchdog_disable(&thread->t_watchdog);
 
+out_ctx_fini:
+	lu_context_fini(&env->le_ctx);
+out_env_remove:
+	lu_env_remove(env);
+out_env:
+	kfree(env);
 out_srv_fini:
 	/* deconstruct service thread state created by ptlrpc_start_thread() */
 	if (svc->srv_ops.so_thr_done)
 		svc->srv_ops.so_thr_done(thread);
-
-	if (env) {
-		lu_context_fini(&env->le_ctx);
-		kfree(env);
-	}
 out:
 	CDEBUG(D_RPCTRACE, "%s: service thread [%p:%u] %d exiting: rc = %d\n",
 	       thread->t_name, thread, thread->t_pid, thread->t_id, rc);
-- 
1.8.3.1
