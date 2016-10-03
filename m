From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:02 -0400
Subject: [lustre-devel] [PATCH 06/41] staging: lustre: ldlm: remove
	unnecessary EXPORT_SYMBOL
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, frank zago <fzago@cray.com>, James Simmons <jsimmons@infradead.org>

From: frank zago <fzago@cray.com>

A lot of symbols don't need to be exported at all because they are
only used in the module they belong to.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5829
Reviewed-on: http://review.whamcloud.com/13324
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    3 ---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    2 --
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |    6 ------
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    3 ---
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    4 ----
 5 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 3c48b4f..ace8cb2 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -512,7 +512,6 @@ int ldlm_lock_change_resource(struct ldlm_namespace *ns, struct ldlm_lock *lock,
 
 	return 0;
 }
-EXPORT_SYMBOL(ldlm_lock_change_resource);
 
 /** \defgroup ldlm_handles LDLM HANDLES
  * Ways to get hold of locks without any addresses.
@@ -595,7 +594,6 @@ void ldlm_lock2desc(struct ldlm_lock *lock, struct ldlm_lock_desc *desc)
 				    &lock->l_policy_data,
 				    &desc->l_policy_data);
 }
-EXPORT_SYMBOL(ldlm_lock2desc);
 
 /**
  * Add a lock to list of conflicting locks to send AST to.
@@ -1147,7 +1145,6 @@ void ldlm_lock_fail_match_locked(struct ldlm_lock *lock)
 		wake_up_all(&lock->l_waitq);
 	}
 }
-EXPORT_SYMBOL(ldlm_lock_fail_match_locked);
 
 /**
  * Mark lock as "matchable" by OST.
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index fde697e..c32b414 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -858,7 +858,6 @@ int ldlm_get_ref(void)
 
 	return rc;
 }
-EXPORT_SYMBOL(ldlm_get_ref);
 
 void ldlm_put_ref(void)
 {
@@ -875,7 +874,6 @@ void ldlm_put_ref(void)
 	}
 	mutex_unlock(&ldlm_ref_mutex);
 }
-EXPORT_SYMBOL(ldlm_put_ref);
 
 static ssize_t cancel_unused_locks_before_replay_show(struct kobject *kobj,
 						      struct attribute *attr,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 9a1136e..b29c956 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -684,7 +684,6 @@ int ldlm_pool_init(struct ldlm_pool *pl, struct ldlm_namespace *ns,
 
 	return rc;
 }
-EXPORT_SYMBOL(ldlm_pool_init);
 
 void ldlm_pool_fini(struct ldlm_pool *pl)
 {
@@ -698,7 +697,6 @@ void ldlm_pool_fini(struct ldlm_pool *pl)
 	 */
 	POISON(pl, 0x5a, sizeof(*pl));
 }
-EXPORT_SYMBOL(ldlm_pool_fini);
 
 /**
  * Add new taken ldlm lock \a lock into pool \a pl accounting.
@@ -724,7 +722,6 @@ void ldlm_pool_add(struct ldlm_pool *pl, struct ldlm_lock *lock)
 	 * with too long call paths.
 	 */
 }
-EXPORT_SYMBOL(ldlm_pool_add);
 
 /**
  * Remove ldlm lock \a lock from pool \a pl accounting.
@@ -743,7 +740,6 @@ void ldlm_pool_del(struct ldlm_pool *pl, struct ldlm_lock *lock)
 
 	lprocfs_counter_incr(pl->pl_stats, LDLM_POOL_CANCEL_STAT);
 }
-EXPORT_SYMBOL(ldlm_pool_del);
 
 /**
  * Returns current \a pl SLV.
@@ -1095,7 +1091,6 @@ int ldlm_pools_init(void)
 
 	return rc;
 }
-EXPORT_SYMBOL(ldlm_pools_init);
 
 void ldlm_pools_fini(void)
 {
@@ -1104,4 +1099,3 @@ void ldlm_pools_fini(void)
 
 	ldlm_pools_thread_stop();
 }
-EXPORT_SYMBOL(ldlm_pools_fini);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 35ba6f1..98730a3 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1022,7 +1022,6 @@ int ldlm_cli_update_pool(struct ptlrpc_request *req)
 
 	return 0;
 }
-EXPORT_SYMBOL(ldlm_cli_update_pool);
 
 /**
  * Client side lock cancel.
@@ -1125,7 +1124,6 @@ int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
 
 	return count;
 }
-EXPORT_SYMBOL(ldlm_cli_cancel_list_local);
 
 /**
  * Cancel as many locks as possible w/o sending any RPCs (e.g. to write back
@@ -2048,4 +2046,3 @@ int ldlm_replay_locks(struct obd_import *imp)
 
 	return rc;
 }
-EXPORT_SYMBOL(ldlm_replay_locks);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index a09c25a..07cb955 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -999,7 +999,6 @@ void ldlm_namespace_get(struct ldlm_namespace *ns)
 {
 	atomic_inc(&ns->ns_bref);
 }
-EXPORT_SYMBOL(ldlm_namespace_get);
 
 /* This is only for callers that care about refcount */
 static int ldlm_namespace_get_return(struct ldlm_namespace *ns)
@@ -1014,7 +1013,6 @@ void ldlm_namespace_put(struct ldlm_namespace *ns)
 		spin_unlock(&ns->ns_lock);
 	}
 }
-EXPORT_SYMBOL(ldlm_namespace_put);
 
 /** Should be called with ldlm_namespace_lock(client) taken. */
 void ldlm_namespace_move_to_active_locked(struct ldlm_namespace *ns,
@@ -1323,7 +1321,6 @@ void ldlm_dump_all_namespaces(ldlm_side_t client, int level)
 
 	mutex_unlock(ldlm_namespace_lock(client));
 }
-EXPORT_SYMBOL(ldlm_dump_all_namespaces);
 
 static int ldlm_res_hash_dump(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 			      struct hlist_node *hnode, void *arg)
@@ -1360,7 +1357,6 @@ void ldlm_namespace_dump(int level, struct ldlm_namespace *ns)
 	ns->ns_next_dump = cfs_time_shift(10);
 	spin_unlock(&ns->ns_lock);
 }
-EXPORT_SYMBOL(ldlm_namespace_dump);
 
 /**
  * Print information about all locks in this resource to debug log.
-- 
1.7.1
