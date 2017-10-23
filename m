From: NeilBrown <neilb@suse.com>
Date: Mon, 23 Oct 2017 11:53:49 +1100
Subject: [lustre-devel] [PATCH 6/9] staging: lustre: ldlm: remove 'flags'
 arg from ldlm_flock_destroy()
In-Reply-To: <150871988297.3340.4522589460981284121.stgit@noble>
References: <150871988297.3340.4522589460981284121.stgit@noble>
Message-ID: <150872002976.3340.17760141414233585370.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org

The only value ever passed in LDLM_FL_WAIT_NOREPROC, so assume that
instead of passing it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |   36 ++++++++++-------------
 1 file changed, 16 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index d5a5742a1171..1bf56892fcf5 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -88,24 +88,23 @@ ldlm_flocks_overlap(struct ldlm_lock *lock, struct ldlm_lock *new)
 }
 
 static inline void
-ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode, __u64 flags)
+ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode)
 {
-	LDLM_DEBUG(lock, "%s(mode: %d, flags: 0x%llx)",
-		   __func__, mode, flags);
+	LDLM_DEBUG(lock, "%s(mode: %d)",
+		   __func__, mode);
 
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
