From: NeilBrown <neilb@suse.com>
Date: Wed, 19 Jul 2017 09:26:47 +1000
Subject: [lustre-devel] [PATCH 07/12] staging: lustre: ldlm: remove 'flags'
 arg from ldlm_process_flock_lock()
In-Reply-To: <150041997277.20736.17112251996623587423.stgit@noble>
References: <150041997277.20736.17112251996623587423.stgit@noble>
Message-ID: <150042040756.20736.13537770572336560890.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

This is only ever set to LDLM_FL_WAIT_NOREPROC, so we can remove the arg
and discard any code that is only run when it doesn't have that value.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |  110 ++++-------------------
 1 file changed, 21 insertions(+), 89 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index fbb627a2f6c1..b6d5a83e61cd 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -122,7 +122,7 @@ ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode, __u64 flags)
  * is released.
  *
  */
-static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags)
+static int ldlm_process_flock_lock(struct ldlm_lock *req)
 {
 	struct ldlm_resource *res = req->l_resource;
 	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
@@ -138,8 +138,8 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags)
 	const struct ldlm_callback_suite null_cbs = { };
 
 	CDEBUG(D_DLMTRACE,
-	       "flags %#llx owner %llu pid %u mode %u start %llu end %llu\n",
-	       *flags, new->l_policy_data.l_flock.owner,
+	       "owner %llu pid %u mode %u start %llu end %llu\n",
+	       new->l_policy_data.l_flock.owner,
 	       new->l_policy_data.l_flock.pid, mode,
 	       req->l_policy_data.l_flock.start,
 	       req->l_policy_data.l_flock.end);
@@ -150,74 +150,16 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags)
 	req->l_blocking_ast = NULL;
 
 reprocess:
-	if ((*flags == LDLM_FL_WAIT_NOREPROC) || (mode == LCK_NL)) {
-		/* This loop determines where this processes locks start
-		 * in the resource lr_granted list.
-		 */
-		list_for_each(tmp, &res->lr_granted) {
-			lock = list_entry(tmp, struct ldlm_lock,
-					  l_res_link);
-			if (ldlm_same_flock_owner(lock, req)) {
-				ownlocks = tmp;
-				break;
-			}
-		}
-	} else {
-		int reprocess_failed = 0;
-
-		lockmode_verify(mode);
-
-		/* This loop determines if there are existing locks
-		 * that conflict with the new lock request.
-		 */
-		list_for_each(tmp, &res->lr_granted) {
-			lock = list_entry(tmp, struct ldlm_lock,
-					  l_res_link);
-
-			if (ldlm_same_flock_owner(lock, req)) {
-				if (!ownlocks)
-					ownlocks = tmp;
-				continue;
-			}
-
-			/* locks are compatible, overlap doesn't matter */
-			if (lockmode_compat(lock->l_granted_mode, mode))
-				continue;
-
-			if (!ldlm_flocks_overlap(lock, req))
-				continue;
-
-			if (*flags & LDLM_FL_BLOCK_NOWAIT) {
-				ldlm_flock_destroy(req, mode, *flags);
-				return LDLM_ITER_STOP;
-			}
-
-			if (*flags & LDLM_FL_TEST_LOCK) {
-				ldlm_flock_destroy(req, mode, *flags);
-				req->l_req_mode = lock->l_granted_mode;
-				req->l_policy_data.l_flock.pid =
-					lock->l_policy_data.l_flock.pid;
-				req->l_policy_data.l_flock.start =
-					lock->l_policy_data.l_flock.start;
-				req->l_policy_data.l_flock.end =
-					lock->l_policy_data.l_flock.end;
-				*flags |= LDLM_FL_LOCK_CHANGED;
-				return LDLM_ITER_STOP;
-			}
-
-			ldlm_resource_add_lock(res, &res->lr_waiting, req);
-			*flags |= LDLM_FL_BLOCK_GRANTED;
-			return LDLM_ITER_STOP;
+	/* This loop determines where this processes locks start
+	 * in the resource lr_granted list.
+	 */
+	list_for_each(tmp, &res->lr_granted) {
+		lock = list_entry(tmp, struct ldlm_lock,
+				  l_res_link);
+		if (ldlm_same_flock_owner(lock, req)) {
+			ownlocks = tmp;
+			break;
 		}
-		if (reprocess_failed)
-			return LDLM_ITER_CONTINUE;
-	}
-
-	if (*flags & LDLM_FL_TEST_LOCK) {
-		ldlm_flock_destroy(req, mode, *flags);
-		req->l_req_mode = LCK_NL;
-		*flags |= LDLM_FL_LOCK_CHANGED;
-		return LDLM_ITER_STOP;
 	}
 
 	/* Scan the locks owned by this process that overlap this request.
@@ -267,7 +209,8 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags)
 			}
 
 			if (added) {
-				ldlm_flock_destroy(lock, mode, *flags);
+				ldlm_flock_destroy(lock, mode,
+						   LDLM_FL_WAIT_NOREPROC);
 			} else {
 				new = lock;
 				added = 1;
@@ -293,7 +236,8 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags)
 					new->l_policy_data.l_flock.end + 1;
 				break;
 			}
-			ldlm_flock_destroy(lock, lock->l_req_mode, *flags);
+			ldlm_flock_destroy(lock, lock->l_req_mode,
+					   LDLM_FL_WAIT_NOREPROC);
 			continue;
 		}
 		if (new->l_policy_data.l_flock.end >=
@@ -325,7 +269,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags)
 			lock_res_and_lock(req);
 			if (IS_ERR(new2)) {
 				ldlm_flock_destroy(req, lock->l_granted_mode,
-						   *flags);
+						   LDLM_FL_WAIT_NOREPROC);
 				return LDLM_ITER_STOP;
 			}
 			goto reprocess;
@@ -354,9 +298,8 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags)
 					     &new2->l_remote_handle,
 					     &new2->l_exp_hash);
 		}
-		if (*flags == LDLM_FL_WAIT_NOREPROC)
-			ldlm_lock_addref_internal_nolock(new2,
-							 lock->l_granted_mode);
+		ldlm_lock_addref_internal_nolock(new2,
+						 lock->l_granted_mode);
 
 		/* insert new2 at lock */
 		ldlm_resource_add_lock(res, ownlocks, new2);
@@ -377,22 +320,13 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags)
 		ldlm_resource_add_lock(res, ownlocks, req);
 	}
 
-	if (*flags != LDLM_FL_WAIT_NOREPROC) {
-		/* The only one possible case for client-side calls flock
-		 * policy function is ldlm_flock_completion_ast inside which
-		 * carries LDLM_FL_WAIT_NOREPROC flag.
-		 */
-		CERROR("Illegal parameter for client-side-only module.\n");
-		LBUG();
-	}
-
 	/* In case we're reprocessing the requested lock we can't destroy
 	 * it until after calling ldlm_add_ast_work_item() above so that laawi()
 	 * can bump the reference count on \a req. Otherwise \a req
 	 * could be freed before the completion AST can be sent.
 	 */
 	if (added)
-		ldlm_flock_destroy(req, mode, *flags);
+		ldlm_flock_destroy(req, mode, LDLM_FL_WAIT_NOREPROC);
 
 	ldlm_resource_dump(D_INFO, res);
 	return LDLM_ITER_CONTINUE;
@@ -582,12 +516,10 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 		getlk->fl_start = (loff_t)lock->l_policy_data.l_flock.start;
 		getlk->fl_end = (loff_t)lock->l_policy_data.l_flock.end;
 	} else {
-		__u64 noreproc = LDLM_FL_WAIT_NOREPROC;
-
 		/* We need to reprocess the lock to do merges or splits
 		 * with existing locks owned by this process.
 		 */
-		ldlm_process_flock_lock(lock, &noreproc);
+		ldlm_process_flock_lock(lock);
 	}
 	unlock_res_and_lock(lock);
 	return rc;
