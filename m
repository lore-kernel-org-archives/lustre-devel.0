From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:47:36 -0400
Subject: [lustre-devel] [PATCH 04/43] staging/lustre: Reintroduce global env
	list
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

This reverts a patch that was merged before lustre client
was introduced into the staging tree, so it's not in the history.

The performance dropped a lot when memory reclaim process kicked
in as ll_releasepage() was called to destroy lustre pages. It turned
out that big overhead to allocate cl_env and keys on the fly so we
have to revert this patch.

The original problem for the reverted patch would be solved in a
follow on patch instead.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/7888
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3321
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |  1 +
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |  3 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  2 +
 drivers/staging/lustre/lustre/obdclass/cl_object.c | 90 ++++++++++++++++++++--
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  2 +
 5 files changed, 92 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index fb971de..e611f79 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -3241,6 +3241,7 @@ void *cl_env_reenter(void);
 void cl_env_reexit(void *cookie);
 void cl_env_implant(struct lu_env *env, int *refcheck);
 void cl_env_unplant(struct lu_env *env, int *refcheck);
+unsigned int cl_env_cache_purge(unsigned int nr);
 
 /** @} cl_env */
 
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index d80bcedd..f68c368 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -146,10 +146,11 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 
 	rc = cl_io_init(env, io, CIT_MISC, io->ci_obj);
 	if (rc) {
+		cl_io_fini(env, io);
+		cl_env_put(env, &refcheck);
 		/* Does not make sense to take GL for released layout */
 		if (rc > 0)
 			rc = -ENOTSUPP;
-		cl_env_put(env, &refcheck);
 		return rc;
 	}
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 6d6bb33..673d31e 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -999,6 +999,8 @@ void ll_put_super(struct super_block *sb)
 
 	lustre_common_put_super(sb);
 
+	cl_env_cache_purge(~0);
+
 	module_put(THIS_MODULE);
 } /* client_put_super */
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 43e299d..0772706 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -492,6 +492,13 @@ EXPORT_SYMBOL(cl_site_stats_print);
  * bz20044, bz22683.
  */
 
+static LIST_HEAD(cl_envs);
+static unsigned int cl_envs_cached_nr;
+static unsigned int cl_envs_cached_max = 128; /* XXX: prototype: arbitrary limit
+					       * for now.
+					       */
+static DEFINE_SPINLOCK(cl_envs_guard);
+
 struct cl_env {
 	void	     *ce_magic;
 	struct lu_env     ce_lu;
@@ -697,6 +704,39 @@ static void cl_env_fini(struct cl_env *cle)
 	kmem_cache_free(cl_env_kmem, cle);
 }
 
+static struct lu_env *cl_env_obtain(void *debug)
+{
+	struct cl_env *cle;
+	struct lu_env *env;
+
+	spin_lock(&cl_envs_guard);
+	LASSERT(equi(cl_envs_cached_nr == 0, list_empty(&cl_envs)));
+	if (cl_envs_cached_nr > 0) {
+		int rc;
+
+		cle = container_of(cl_envs.next, struct cl_env, ce_linkage);
+		list_del_init(&cle->ce_linkage);
+		cl_envs_cached_nr--;
+		spin_unlock(&cl_envs_guard);
+
+		env = &cle->ce_lu;
+		rc = lu_env_refill(env);
+		if (rc == 0) {
+			cl_env_init0(cle, debug);
+			lu_context_enter(&env->le_ctx);
+			lu_context_enter(&cle->ce_ses);
+		} else {
+			cl_env_fini(cle);
+			env = ERR_PTR(rc);
+		}
+	} else {
+		spin_unlock(&cl_envs_guard);
+		env = cl_env_new(lu_context_tags_default,
+				 lu_session_tags_default, debug);
+	}
+	return env;
+}
+
 static inline struct cl_env *cl_env_container(struct lu_env *env)
 {
 	return container_of(env, struct cl_env, ce_lu);
@@ -727,6 +767,8 @@ static struct lu_env *cl_env_peek(int *refcheck)
  * Returns lu_env: if there already is an environment associated with the
  * current thread, it is returned, otherwise, new environment is allocated.
  *
+ * Allocations are amortized through the global cache of environments.
+ *
  * \param refcheck pointer to a counter used to detect environment leaks. In
  * the usual case cl_env_get() and cl_env_put() are called in the same lexical
  * scope and pointer to the same integer is passed as \a refcheck. This is
@@ -740,10 +782,7 @@ struct lu_env *cl_env_get(int *refcheck)
 
 	env = cl_env_peek(refcheck);
 	if (!env) {
-		env = cl_env_new(lu_context_tags_default,
-				 lu_session_tags_default,
-				 __builtin_return_address(0));
-
+		env = cl_env_obtain(__builtin_return_address(0));
 		if (!IS_ERR(env)) {
 			struct cl_env *cle;
 
@@ -787,6 +826,32 @@ static void cl_env_exit(struct cl_env *cle)
 }
 
 /**
+ * Finalizes and frees a given number of cached environments. This is done to
+ * (1) free some memory (not currently hooked into VM), or (2) release
+ * references to modules.
+ */
+unsigned int cl_env_cache_purge(unsigned int nr)
+{
+	struct cl_env *cle;
+
+	spin_lock(&cl_envs_guard);
+	for (; !list_empty(&cl_envs) && nr > 0; --nr) {
+		cle = container_of(cl_envs.next, struct cl_env, ce_linkage);
+		list_del_init(&cle->ce_linkage);
+		LASSERT(cl_envs_cached_nr > 0);
+		cl_envs_cached_nr--;
+		spin_unlock(&cl_envs_guard);
+
+		cl_env_fini(cle);
+		spin_lock(&cl_envs_guard);
+	}
+	LASSERT(equi(cl_envs_cached_nr == 0, list_empty(&cl_envs)));
+	spin_unlock(&cl_envs_guard);
+	return nr;
+}
+EXPORT_SYMBOL(cl_env_cache_purge);
+
+/**
  * Release an environment.
  *
  * Decrement \a env reference counter. When counter drops to 0, nothing in
@@ -808,7 +873,22 @@ void cl_env_put(struct lu_env *env, int *refcheck)
 		cl_env_detach(cle);
 		cle->ce_debug = NULL;
 		cl_env_exit(cle);
-		cl_env_fini(cle);
+		/*
+		 * Don't bother to take a lock here.
+		 *
+		 * Return environment to the cache only when it was allocated
+		 * with the standard tags.
+		 */
+		if (cl_envs_cached_nr < cl_envs_cached_max &&
+		    (env->le_ctx.lc_tags & ~LCT_HAS_EXIT) == LCT_CL_THREAD &&
+		    (env->le_ses->lc_tags & ~LCT_HAS_EXIT) == LCT_SESSION) {
+			spin_lock(&cl_envs_guard);
+			list_add(&cle->ce_linkage, &cl_envs);
+			cl_envs_cached_nr++;
+			spin_unlock(&cl_envs_guard);
+		} else {
+			cl_env_fini(cle);
+		}
 	}
 }
 EXPORT_SYMBOL(cl_env_put);
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 69fdcee..770d5bd 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -55,6 +55,7 @@
 #include "../include/lustre_disk.h"
 #include "../include/lustre_fid.h"
 #include "../include/lu_object.h"
+#include "../include/cl_object.h"
 #include "../include/lu_ref.h"
 #include <linux/list.h>
 
@@ -1468,6 +1469,7 @@ void lu_context_key_quiesce(struct lu_context_key *key)
 		/*
 		 * XXX layering violation.
 		 */
+		cl_env_cache_purge(~0);
 		key->lct_tags |= LCT_QUIESCENT;
 		/*
 		 * XXX memory barrier has to go here.
-- 
2.1.0
