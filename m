From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:59 -0500
Subject: [lustre-devel] [PATCH 311/622] lustre: push rcu_barrier() before
 destroying slab
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-312-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

From rcubarrier.txt:

"
We could try placing a synchronize_rcu() in the module-exit code path,
but this is not sufficient. Although synchronize_rcu() does wait for a
grace period to elapse, it does not wait for the callbacks to complete.

One might be tempted to try several back-to-back synchronize_rcu()
calls, but this is still not guaranteed to work. If there is a very
heavy RCU-callback load, then some of the callbacks might be deferred
in order to allow other processing to proceed. Such deferral is required
in realtime kernels in order to avoid excessive scheduling latencies.

We instead need the rcu_barrier() primitive. This primitive is similar
to synchronize_rcu(), but instead of waiting solely for a grace
period to elapse, it also waits for all outstanding RCU callbacks to
complete. Pseudo-code using rcu_barrier() is as follows:

   1. Prevent any new RCU callbacks from being posted.
   2. Execute rcu_barrier().
   3. Allow the module to be unloaded.
"

So use synchronize_rcu() in ldlm_exit() is not safe enough, and we might
still hit use-after-free problem, also we missed rcu_barrier() when destroy
inode cache, this is simiar idea what current local filesystem does.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12374
Lustre-commit: 1f7613968c80 ("LU-12374 lustre: push rcu_barrier() before destroying slab")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/35030
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lockd.c | 6 +++---
 fs/lustre/llite/super25.c   | 5 +++++
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 3b405be..79dab6e 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -1204,10 +1204,10 @@ void ldlm_exit(void)
 	kmem_cache_destroy(ldlm_resource_slab);
 	/*
 	 * ldlm_lock_put() use RCU to call ldlm_lock_free, so need call
-	 * synchronize_rcu() to wait a grace period elapsed, so that
-	 * ldlm_lock_free() get a chance to be called.
+	 * rcu_barrier() to wait all outstanding RCU callbacks to complete,
+	 * so that ldlm_lock_free() get a chance to be called.
 	 */
-	synchronize_rcu();
+	rcu_barrier();
 	kmem_cache_destroy(ldlm_lock_slab);
 	kmem_cache_destroy(ldlm_interval_tree_slab);
 }
diff --git a/fs/lustre/llite/super25.c b/fs/lustre/llite/super25.c
index 133fe2a..6cae48c 100644
--- a/fs/lustre/llite/super25.c
+++ b/fs/lustre/llite/super25.c
@@ -271,6 +271,11 @@ static void __exit lustre_exit(void)
 	cl_env_put(cl_inode_fini_env, &cl_inode_fini_refcheck);
 	vvp_global_fini();
 
+	/*
+	 * Make sure all delayed rcu free inodes are flushed before we
+	 * destroy cache.
+	 */
+	rcu_barrier();
 	kmem_cache_destroy(ll_inode_cachep);
 	kmem_cache_destroy(ll_file_data_slab);
 }
-- 
1.8.3.1
