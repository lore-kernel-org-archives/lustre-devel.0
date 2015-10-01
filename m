From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:41 -0400
Subject: [lustre-devel] [PATCH 31/32] staging/lustre/ldlm: Remove posix lock
	(flock) deadlock detection
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-32-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

This is server-side code that cannot work on the client
(vfs would do this check on the local node).

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c | 132 ------------------------
 1 file changed, 132 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 57b4edb..0c46a06 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -91,40 +91,6 @@ ldlm_flocks_overlap(struct ldlm_lock *lock, struct ldlm_lock *new)
 		lock->l_policy_data.l_flock.start));
 }
 
-static inline void ldlm_flock_blocking_link(struct ldlm_lock *req,
-					    struct ldlm_lock *lock)
-{
-	/* For server only */
-	if (req->l_export == NULL)
-		return;
-
-	LASSERT(hlist_unhashed(&req->l_exp_flock_hash));
-
-	req->l_policy_data.l_flock.blocking_owner =
-		lock->l_policy_data.l_flock.owner;
-	req->l_policy_data.l_flock.blocking_export =
-		lock->l_export;
-	req->l_policy_data.l_flock.blocking_refs = 0;
-
-	cfs_hash_add(req->l_export->exp_flock_hash,
-		     &req->l_policy_data.l_flock.owner,
-		     &req->l_exp_flock_hash);
-}
-
-static inline void ldlm_flock_blocking_unlink(struct ldlm_lock *req)
-{
-	/* For server only */
-	if (req->l_export == NULL)
-		return;
-
-	check_res_locked(req->l_resource);
-	if (req->l_export->exp_flock_hash != NULL &&
-	    !hlist_unhashed(&req->l_exp_flock_hash))
-		cfs_hash_del(req->l_export->exp_flock_hash,
-			     &req->l_policy_data.l_flock.owner,
-			     &req->l_exp_flock_hash);
-}
-
 static inline void
 ldlm_flock_destroy(struct ldlm_lock *lock, ldlm_mode_t mode, __u64 flags)
 {
@@ -149,79 +115,6 @@ ldlm_flock_destroy(struct ldlm_lock *lock, ldlm_mode_t mode, __u64 flags)
 }
 
 /**
- * POSIX locks deadlock detection code.
- *
- * Given a new lock \a req and an existing lock \a bl_lock it conflicts
- * with, we need to iterate through all blocked POSIX locks for this
- * export and see if there is a deadlock condition arising. (i.e. when
- * one client holds a lock on something and want a lock on something
- * else and at the same time another client has the opposite situation).
- */
-static int
-ldlm_flock_deadlock(struct ldlm_lock *req, struct ldlm_lock *bl_lock)
-{
-	struct obd_export *req_exp = req->l_export;
-	struct obd_export *bl_exp = bl_lock->l_export;
-	__u64 req_owner = req->l_policy_data.l_flock.owner;
-	__u64 bl_owner = bl_lock->l_policy_data.l_flock.owner;
-
-	/* For server only */
-	if (req_exp == NULL)
-		return 0;
-
-	class_export_get(bl_exp);
-	while (1) {
-		struct obd_export *bl_exp_new;
-		struct ldlm_lock *lock = NULL;
-		struct ldlm_flock *flock;
-
-		if (bl_exp->exp_flock_hash != NULL)
-			lock = cfs_hash_lookup(bl_exp->exp_flock_hash,
-					       &bl_owner);
-		if (lock == NULL)
-			break;
-
-		LASSERT(req != lock);
-		flock = &lock->l_policy_data.l_flock;
-		LASSERT(flock->owner == bl_owner);
-		bl_owner = flock->blocking_owner;
-		bl_exp_new = class_export_get(flock->blocking_export);
-		class_export_put(bl_exp);
-
-		cfs_hash_put(bl_exp->exp_flock_hash, &lock->l_exp_flock_hash);
-		bl_exp = bl_exp_new;
-
-		if (bl_owner == req_owner && bl_exp == req_exp) {
-			class_export_put(bl_exp);
-			return 1;
-		}
-	}
-	class_export_put(bl_exp);
-
-	return 0;
-}
-
-static void ldlm_flock_cancel_on_deadlock(struct ldlm_lock *lock,
-					  struct list_head *work_list)
-{
-	CDEBUG(D_INFO, "reprocess deadlock req=%p\n", lock);
-
-	if ((exp_connect_flags(lock->l_export) &
-				OBD_CONNECT_FLOCK_DEAD) == 0) {
-		CERROR(
-		      "deadlock found, but client doesn't support flock canceliation\n");
-	} else {
-		LASSERT(lock->l_completion_ast);
-		LASSERT((lock->l_flags & LDLM_FL_AST_SENT) == 0);
-		lock->l_flags |= LDLM_FL_AST_SENT | LDLM_FL_CANCEL_ON_BLOCK |
-			LDLM_FL_FLOCK_DEADLOCK;
-		ldlm_flock_blocking_unlink(lock);
-		ldlm_resource_unlink_lock(lock);
-		ldlm_add_ast_work_item(lock, NULL, work_list);
-	}
-}
-
-/**
  * Process a granting attempt for flock lock.
  * Must be called under ns lock held.
  *
@@ -307,11 +200,6 @@ reprocess:
 
 			if (!first_enq) {
 				reprocess_failed = 1;
-				if (ldlm_flock_deadlock(req, lock)) {
-					ldlm_flock_cancel_on_deadlock(req,
-							work_list);
-					return LDLM_ITER_CONTINUE;
-				}
 				continue;
 			}
 
@@ -334,17 +222,6 @@ reprocess:
 				return LDLM_ITER_STOP;
 			}
 
-			/* add lock to blocking list before deadlock
-			 * check to prevent race */
-			ldlm_flock_blocking_link(req, lock);
-
-			if (ldlm_flock_deadlock(req, lock)) {
-				ldlm_flock_blocking_unlink(req);
-				ldlm_flock_destroy(req, mode, *flags);
-				*err = -EDEADLK;
-				return LDLM_ITER_STOP;
-			}
-
 			ldlm_resource_add_lock(res, &res->lr_waiting, req);
 			*flags |= LDLM_FL_BLOCK_GRANTED;
 			return LDLM_ITER_STOP;
@@ -360,10 +237,6 @@ reprocess:
 		return LDLM_ITER_STOP;
 	}
 
-	/* In case we had slept on this lock request take it off of the
-	 * deadlock detection hash list. */
-	ldlm_flock_blocking_unlink(req);
-
 	/* Scan the locks owned by this process that overlap this request.
 	 * We may have to merge or split existing locks. */
 
@@ -551,9 +424,7 @@ ldlm_flock_interrupted_wait(void *data)
 
 	lock = ((struct ldlm_flock_wait_data *)data)->fwd_lock;
 
-	/* take lock off the deadlock detection hash list. */
 	lock_res_and_lock(lock);
-	ldlm_flock_blocking_unlink(lock);
 
 	/* client side - set flag to prevent lock from being put on LRU list */
 	lock->l_flags |= LDLM_FL_CBPENDING;
@@ -660,9 +531,6 @@ granted:
 
 	lock_res_and_lock(lock);
 
-	/* take lock off the deadlock detection hash list. */
-	ldlm_flock_blocking_unlink(lock);
-
 	/* ldlm_lock_enqueue() has already placed lock on the granted list. */
 	list_del_init(&lock->l_res_link);
 
-- 
2.1.0
