From: NeilBrown <neilb@suse.com>
Date: Tue, 13 Feb 2018 08:22:36 +1100
Subject: [lustre-devel] [PATCH 07/19] staging: lustre: simplify l_wait_event
 when intr handler but no timeout.
In-Reply-To: <151847037709.22826.16175867257667686132.stgit@noble>
References: <151847037709.22826.16175867257667686132.stgit@noble>
Message-ID: <151847055671.22826.8688568641693262055.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

If l_wait_event() is given a function to be called on a signal,
but no timeout or timeout handler, then the intr function is simply
called at the end if the wait was aborted by a signal.
So a simpler way to write the code (in the one place this case is
used) it to open-code the body of the function after the
wait_event, if -ERESTARTSYS was returned.

Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |   30 +++++------------------
 1 file changed, 7 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 657ab95091a0..411b540b96d9 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -310,24 +310,6 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 	return LDLM_ITER_CONTINUE;
 }
 
-struct ldlm_flock_wait_data {
-	struct ldlm_lock *fwd_lock;
-};
-
-static void
-ldlm_flock_interrupted_wait(void *data)
-{
-	struct ldlm_lock *lock;
-
-	lock = ((struct ldlm_flock_wait_data *)data)->fwd_lock;
-
-	lock_res_and_lock(lock);
-
-	/* client side - set flag to prevent lock from being put on LRU list */
-	ldlm_set_cbpending(lock);
-	unlock_res_and_lock(lock);
-}
-
 /**
  * Flock completion callback function.
  *
@@ -342,8 +324,6 @@ int
 ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 {
 	struct file_lock		*getlk = lock->l_ast_data;
-	struct ldlm_flock_wait_data	fwd;
-	struct l_wait_info		lwi;
 	int				rc = 0;
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT2, 4);
@@ -372,13 +352,17 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 
 	LDLM_DEBUG(lock,
 		   "client-side enqueue returned a blocked lock, sleeping");
-	fwd.fwd_lock = lock;
-	lwi = LWI_TIMEOUT_INTR(0, NULL, ldlm_flock_interrupted_wait, &fwd);
 
 	/* Go to sleep until the lock is granted. */
-	rc = l_wait_event(lock->l_waitq, is_granted_or_cancelled(lock), &lwi);
+	rc = l_wait_event_abortable(lock->l_waitq, is_granted_or_cancelled(lock));
 
 	if (rc) {
+		lock_res_and_lock(lock);
+
+		/* client side - set flag to prevent lock from being put on LRU list */
+		ldlm_set_cbpending(lock);
+		unlock_res_and_lock(lock);
+
 		LDLM_DEBUG(lock, "client-side enqueue waking up: failed (%d)",
 			   rc);
 		return rc;
