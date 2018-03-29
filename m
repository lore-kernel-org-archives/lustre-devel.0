From: NeilBrown <neilb@suse.com>
Date: Thu, 29 Mar 2018 15:26:48 +1100
Subject: [lustre-devel] [PATCH 04/17] staging: lustre: remove unused hash
 tables.
In-Reply-To: <152229732768.27689.4800156943561963977.stgit@noble>
References: <152229732768.27689.4800156943561963977.stgit@noble>
Message-ID: <152229760834.27689.17845742683913841545.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

exp_lock_hash and exp_flock_hash are unused in
the client, so remove all references.

Also remove unused hashtable size definitions.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   10 -------
 .../staging/lustre/lustre/include/lustre_export.h  |    7 -----
 .../staging/lustre/lustre/include/obd_support.h    |   18 -------------
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   11 +-------
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   14 ----------
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   27 +-------------------
 drivers/staging/lustre/lustre/obdclass/genops.c    |    2 -
 7 files changed, 3 insertions(+), 86 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 7407acf60cf8..5a355fbab401 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -629,16 +629,6 @@ struct ldlm_lock {
 	 * Tree node for ldlm_extent.
 	 */
 	struct ldlm_interval	*l_tree_node;
-	/**
-	 * Per export hash of locks.
-	 * Protected by per-bucket exp->exp_lock_hash locks.
-	 */
-	struct hlist_node	l_exp_hash;
-	/**
-	 * Per export hash of flock locks.
-	 * Protected by per-bucket exp->exp_flock_hash locks.
-	 */
-	struct hlist_node	l_exp_flock_hash;
 	/**
 	 * Requested mode.
 	 * Protected by lr_lock.
diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index 40cd168ed2ea..19ce13bc8ee6 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -102,13 +102,6 @@ struct obd_export {
 	struct ptlrpc_connection *exp_connection;
 	/** Connection count value from last successful reconnect rpc */
 	__u32		     exp_conn_cnt;
-	/** Hash list of all ldlm locks granted on this export */
-	struct cfs_hash	       *exp_lock_hash;
-	/**
-	 * Hash list for Posix lock deadlock detection, added with
-	 * ldlm_lock::l_exp_flock_hash.
-	 */
-	struct cfs_hash	       *exp_flock_hash;
 	struct list_head		exp_outstanding_replies;
 	struct list_head		exp_uncommitted_replies;
 	spinlock_t		  exp_uncommitted_replies_lock;
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 8595091b8b86..eb2d6cb6b40b 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -67,27 +67,9 @@ extern char obd_jobid_var[];
 #define HASH_UUID_BKT_BITS 5
 #define HASH_UUID_CUR_BITS 7
 #define HASH_UUID_MAX_BITS 12
-#define HASH_NID_BKT_BITS 5
-#define HASH_NID_CUR_BITS 7
-#define HASH_NID_MAX_BITS 12
-#define HASH_NID_STATS_BKT_BITS 5
-#define HASH_NID_STATS_CUR_BITS 7
-#define HASH_NID_STATS_MAX_BITS 12
-#define HASH_LQE_BKT_BITS 5
-#define HASH_LQE_CUR_BITS 7
-#define HASH_LQE_MAX_BITS 12
 #define HASH_CONN_BKT_BITS 5
 #define HASH_CONN_CUR_BITS 5
 #define HASH_CONN_MAX_BITS 15
-#define HASH_EXP_LOCK_BKT_BITS  5
-#define HASH_EXP_LOCK_CUR_BITS  7
-#define HASH_EXP_LOCK_MAX_BITS  16
-#define HASH_CL_ENV_BKT_BITS    5
-#define HASH_CL_ENV_BITS	10
-#define HASH_JOB_STATS_BKT_BITS 5
-#define HASH_JOB_STATS_CUR_BITS 7
-#define HASH_JOB_STATS_MAX_BITS 12
-
 /* Timeout definitions */
 #define OBD_TIMEOUT_DEFAULT	     100
 /* Time to wait for all clients to reconnect during recovery (hard limit) */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 411b540b96d9..94f3b1e49896 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -83,9 +83,6 @@ ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode)
 	LDLM_DEBUG(lock, "%s(mode: %d)",
 		   __func__, mode);
 
-	/* Safe to not lock here, since it should be empty anyway */
-	LASSERT(hlist_unhashed(&lock->l_exp_flock_hash));
-
 	list_del_init(&lock->l_res_link);
 
 	/* client side - set a flag to prevent sending a CANCEL */
@@ -263,15 +260,9 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 		lock->l_policy_data.l_flock.start =
 			new->l_policy_data.l_flock.end + 1;
 		new2->l_conn_export = lock->l_conn_export;
-		if (lock->l_export) {
+		if (lock->l_export)
 			new2->l_export = class_export_lock_get(lock->l_export,
 							       new2);
-			if (new2->l_export->exp_lock_hash &&
-			    hlist_unhashed(&new2->l_exp_hash))
-				cfs_hash_add(new2->l_export->exp_lock_hash,
-					     &new2->l_remote_handle,
-					     &new2->l_exp_hash);
-		}
 		ldlm_lock_addref_internal_nolock(new2,
 						 lock->l_granted_mode);
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 95bea351d21d..b8fd778d9832 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -318,18 +318,6 @@ static int ldlm_lock_destroy_internal(struct ldlm_lock *lock)
 	}
 	ldlm_set_destroyed(lock);
 
-	if (lock->l_export && lock->l_export->exp_lock_hash) {
-		/* NB: it's safe to call cfs_hash_del() even lock isn't
-		 * in exp_lock_hash.
-		 */
-		/* In the function below, .hs_keycmp resolves to
-		 * ldlm_export_lock_keycmp()
-		 */
-		/* coverity[overrun-buffer-val] */
-		cfs_hash_del(lock->l_export->exp_lock_hash,
-			     &lock->l_remote_handle, &lock->l_exp_hash);
-	}
-
 	ldlm_lock_remove_from_lru(lock);
 	class_handle_unhash(&lock->l_handle);
 
@@ -419,8 +407,6 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 	lock->l_blocking_lock = NULL;
 	INIT_LIST_HEAD(&lock->l_sl_mode);
 	INIT_LIST_HEAD(&lock->l_sl_policy);
-	INIT_HLIST_NODE(&lock->l_exp_hash);
-	INIT_HLIST_NODE(&lock->l_exp_flock_hash);
 
 	lprocfs_counter_incr(ldlm_res_to_ns(resource)->ns_stats,
 			     LDLM_NSS_LOCKS);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index be43958e4090..8e79f5e073ff 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -405,19 +405,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	cleanup_phase = 0;
 
 	lock_res_and_lock(lock);
-	/* Key change rehash lock in per-export hash with new key */
-	if (exp->exp_lock_hash) {
-		/* In the function below, .hs_keycmp resolves to
-		 * ldlm_export_lock_keycmp()
-		 */
-		/* coverity[overrun-buffer-val] */
-		cfs_hash_rehash_key(exp->exp_lock_hash,
-				    &lock->l_remote_handle,
-				    &reply->lock_handle,
-				    &lock->l_exp_hash);
-	} else {
-		lock->l_remote_handle = reply->lock_handle;
-	}
+	lock->l_remote_handle = reply->lock_handle;
 
 	*flags = ldlm_flags_from_wire(reply->lock_flags);
 	lock->l_flags |= ldlm_flags_from_wire(reply->lock_flags &
@@ -1884,18 +1872,7 @@ static int replay_lock_interpret(const struct lu_env *env,
 
 	/* Key change rehash lock in per-export hash with new key */
 	exp = req->rq_export;
-	if (exp && exp->exp_lock_hash) {
-		/* In the function below, .hs_keycmp resolves to
-		 * ldlm_export_lock_keycmp()
-		 */
-		/* coverity[overrun-buffer-val] */
-		cfs_hash_rehash_key(exp->exp_lock_hash,
-				    &lock->l_remote_handle,
-				    &reply->lock_handle,
-				    &lock->l_exp_hash);
-	} else {
-		lock->l_remote_handle = reply->lock_handle;
-	}
+	lock->l_remote_handle = reply->lock_handle;
 
 	LDLM_DEBUG(lock, "replayed lock:");
 	ptlrpc_import_recovery_state_machine(req->rq_import);
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 63ccbabb4c5a..86e22472719a 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -721,8 +721,6 @@ struct obd_export *class_new_export(struct obd_device *obd,
 		return ERR_PTR(-ENOMEM);
 
 	export->exp_conn_cnt = 0;
-	export->exp_lock_hash = NULL;
-	export->exp_flock_hash = NULL;
 	atomic_set(&export->exp_refcount, 2);
 	atomic_set(&export->exp_rpc_count, 0);
 	atomic_set(&export->exp_cb_count, 0);
