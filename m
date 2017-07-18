From: NeilBrown <neilb@suse.com>
Date: Wed, 19 Jul 2017 09:26:47 +1000
Subject: [lustre-devel] [PATCH 09/12] staging: lustre: ldlm: remove 'flags'
 arg from ldlm_flock_destroy()
In-Reply-To: <150041997277.20736.17112251996623587423.stgit@noble>
References: <150041997277.20736.17112251996623587423.stgit@noble>
Message-ID: <150042040761.20736.2485410555432492945.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

The only value ever passed in LDLM_FL_WAIT_NOREPROC, so assume that
instead of passing it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |   36 ++++++++++-------------
 1 file changed, 16 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 0fb2c882ab4a..9a888e1ce923 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -88,24 +88,23 @@ ldlm_flocks_overlap(struct ldlm_lock *lock, struct ldlm_lock *new)
 }
 
 static inline void
-ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode, __u64 flags)
+ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode)
 {
-	LDLM_DEBUG(lock, "ldlm_flock_destroy(mode: %d, flags: 0x%llx)",
-		   mode, flags);
+	LDLM_DEBUG(lock, "ldlm_flock_destroy(mode: %d)",
+		   mode);
 
 	/* Safe to not lock here, since it should be empty anyway */
 	LASSERT(hlist_unhashed(&lock->l_exp_flock_hash));
 
 	list_del_init(&lock->l_res_link);
-	if (flags == LDLM_FL_WAIT_NOREPROC) {
-		/* client side - set a flag to prevent sending a CANCEL */
-		lock->l_flags |= LDLM_FL_LOCAL_ONLY | LDLM_FL_CBPENDING;
 
-		/* when reaching here, it is under lock_res_and_lock(). Thus,
-		 * need call the nolock version of ldlm_lock_decref_internal
-		 */
-		ldlm_lock_decref_internal_nolock(lock, mode);
-	}
+	/* client side - set a flag to prevent sending a CANCEL */
+	lock->l_flags |= LDLM_FL_LOCAL_ONLY | LDLM_FL_CBPENDING;
+
+	/* when reaching here, it is under lock_res_and_lock(). Thus,
+	 * need call the nolock version of ldlm_lock_decref_internal
+	 */
+	ldlm_lock_decref_internal_nolock(lock, mode);
 
 	ldlm_lock_destroy_nolock(lock);
 }
@@ -208,8 +207,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 			}
 
 			if (added) {
-				ldlm_flock_destroy(lock, mode,
-						   LDLM_FL_WAIT_NOREPROC);
+				ldlm_flock_destroy(lock, mode);
 			} else {
 				new = lock;
 				added = 1;
@@ -233,8 +231,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 					new->l_policy_data.l_flock.end + 1;
 				break;
 			}
-			ldlm_flock_destroy(lock, lock->l_req_mode,
-					   LDLM_FL_WAIT_NOREPROC);
+			ldlm_flock_destroy(lock, lock->l_req_mode);
 			continue;
 		}
 		if (new->l_policy_data.l_flock.end >=
@@ -265,8 +262,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 						NULL, 0, LVB_T_NONE);
 			lock_res_and_lock(req);
 			if (IS_ERR(new2)) {
-				ldlm_flock_destroy(req, lock->l_granted_mode,
-						   LDLM_FL_WAIT_NOREPROC);
+				ldlm_flock_destroy(req, lock->l_granted_mode);
 				return LDLM_ITER_STOP;
 			}
 			goto reprocess;
@@ -323,7 +319,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 	 * could be freed before the completion AST can be sent.
 	 */
 	if (added)
-		ldlm_flock_destroy(req, mode, LDLM_FL_WAIT_NOREPROC);
+		ldlm_flock_destroy(req, mode);
 
 	ldlm_resource_dump(D_INFO, res);
 	return LDLM_ITER_CONTINUE;
@@ -477,7 +473,7 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 			LDLM_DEBUG(lock, "client-side enqueue deadlock received");
 			rc = -EDEADLK;
 		}
-		ldlm_flock_destroy(lock, mode, LDLM_FL_WAIT_NOREPROC);
+		ldlm_flock_destroy(lock, mode);
 		unlock_res_and_lock(lock);
 
 		/* Need to wake up the waiter if we were evicted */
@@ -498,7 +494,7 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 		 * in the lock changes we can decref the appropriate refcount.
 		 */
 		LASSERT(ldlm_is_test_lock(lock));
-		ldlm_flock_destroy(lock, getlk->fl_type, LDLM_FL_WAIT_NOREPROC);
+		ldlm_flock_destroy(lock, getlk->fl_type);
 		switch (lock->l_granted_mode) {
 		case LCK_PR:
 			getlk->fl_type = F_RDLCK;
